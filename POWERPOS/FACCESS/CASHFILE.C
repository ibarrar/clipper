/*
 * System.......... PowerPos for Spectrum
 * Program I.D.....
 * Author..........
 * Date Started....
 * Dialect.........
 * Remarks......... Called by the local server application
*/
#include <string.h>

#include "filesys.api"
#include "extend.h"
#include "cashfile.h"
#include "faccess.h"

#pragma check_stack-
#pragma intrinsic (memcmp)

static long position = -1L;

static int search_sequential(int handle,void far *data, CASHRECORD far *crecord);

int cashier_search_and_get( void far *receive_buffer, unsigned recvLen,
                            void far *data, unsigned dataLen,
                            char far *path, unsigned pathlen )
{
  void far *filename;
  int handle,retval;
  CASHRECORD far *crecord;  

  if ( recvLen != sizeof(CASHRECORD) )
      return(INV_RECV_PARAM);
  
  if ( dataLen != sizeof(crecord->cashier_code) ) 
      return(INV_SEND_PARAM);     

  if (( filename = _xalloc(13+pathlen)) == NULL)
      return(MEM_ALLOC_ERR);

  _bset( filename,0x0,13+pathlen);    
  _bcopy(filename,path,pathlen);
  _bcopy((char *) filename+pathlen,CASHIER_FILE_NAME,sizeof(CASHIER_FILE_NAME) );

  handle = _fsOpen( filename, FO_READWRITE | FO_SHARED );

  _xfree( filename );

  if (_fsError())
     return (FILE_OPEN_ERR);

  crecord = receive_buffer;   
  
  retval = search_sequential(handle,data,crecord);
  
  _fsClose( handle );  

  if ((char) crecord->deleted == '*' )
     retval = CODE_NOT_FOUND;

  return ( retval );
}

int cashier_search_and_put( void far *data, unsigned dataLen,
                            char far *path, unsigned pathlen )
{
  void far *filename;
  int handle,retval;
  CASHRECORD far *crecord;
  CASHRECORD cashier;
  char code[4];

  if ( dataLen != sizeof(CASHRECORD) ) 
      return(INV_SEND_PARAM);

  if (( filename = _xalloc(13+pathlen)) == NULL)
      return(MEM_ALLOC_ERR);

  _bset( filename,0x0,13+pathlen);    
  _bcopy(filename,path,pathlen);
  _bcopy((char *) filename+pathlen,CASHIER_FILE_NAME,sizeof(CASHIER_FILE_NAME) );

  handle = _fsOpen( filename, FO_READWRITE | FO_SHARED );

#ifdef AUTO_CREATE

  if ( _fsError() == 2 )  /* if file is not found */
  {
     cashier_create(path, pathlen);         
     handle = _fsOpen( filename, FO_READWRITE | FO_SHARED );
  }   
  
#endif  

  _xfree( filename );  
  
  if (_fsError())
     return (FILE_OPEN_ERR);       
     
  _bset( code,0x0,sizeof(code));
  _bcopy(code,data,sizeof(cashier.cashier_code));     

  crecord = data;   
  
  retval = search_sequential(handle,data,&cashier);

  if ( retval != NORMAL )
    _fsSeek( handle, 0L, FS_END ); 
  
  if ( _fsWrite( handle,(char *) crecord, sizeof(CASHRECORD) ) != sizeof(CASHRECORD) )
      retval = FILE_WRITE_ERR;  
  else
      retval = NORMAL;    

  _fsClose( handle );

  return ( retval );
}


int cashier_search_and_del( void far *data, unsigned dataLen,
                            char far *path, unsigned pathlen )
{
  void far *filename;
  int handle,retval;
  CASHRECORD cashier;
  char code[4];

  if ( dataLen != sizeof(cashier.cashier_code) ) 
      return(INV_SEND_PARAM);

  _bset( code,0x0,sizeof(code));
  _bcopy(code,data,sizeof(cashier.cashier_code));

  if (( filename = _xalloc(13+pathlen)) == NULL)
      return(MEM_ALLOC_ERR);

  _bset( filename,0x0,13+pathlen);    
  _bcopy(filename,path,pathlen);
  _bcopy((char *) filename+pathlen,CASHIER_FILE_NAME,sizeof(CASHIER_FILE_NAME) );

  handle = _fsOpen( filename, FO_READWRITE | FO_SHARED );

  _xfree( filename );

  if (_fsError())
     return (FILE_OPEN_ERR);
     
  _bset( code,0x0,sizeof(code));
  _bcopy(code,data,sizeof(cashier.cashier_code));     

  retval = search_sequential(handle,code,&cashier);

  if ( retval == NORMAL )
  {
    cashier.deleted = '*' ;
    _fsWrite( handle,(char *) &cashier, sizeof(CASHRECORD) );
  }  

  _fsClose( handle );

  return ( retval );
}

static int search_sequential(int handle,void far *data, CASHRECORD far *crecord)
{
  long offset = 0L;

  _fsSeek(handle, 0L, FS_SET);
  
  while (_fsRead(handle, (char far *)crecord, sizeof(CASHRECORD)) == sizeof(CASHRECORD))
  {
     if ( (memcmp(crecord->cashier_code,data,3) == 0) )
     {
        offset = _fsSeek(handle, 0L, FS_RELATIVE);
        offset -= sizeof(CASHRECORD);
        _fsSeek( handle,offset, FS_SET);
        return(NORMAL);
     }
  }  
  return(CODE_NOT_FOUND);
}


int cashier_create(void far *path, unsigned pathlen)
{
  void far *filename;
  int handle;

   if (( filename = _xalloc(13+pathlen)) == NULL)
   {
       return(MEM_ALLOC_ERR);
   }    

   _bset( filename,0x0,13+pathlen);    
   _bcopy(filename,path,pathlen);
   _bcopy((char *) filename+pathlen,CASHIER_FILE_NAME,sizeof(CASHIER_FILE_NAME) );
 
   handle = _fsCreate( filename, FC_NORMAL );

   _xfree( filename );

   if (_fsError())
      return (FILE_CREATE_ERR);

   _fsClose(handle);
  return (NORMAL);
}

#ifdef BROWSE_FUNCTIONS

int cashier_get_first( void far *receive_buffer, unsigned recvLen,
                       char far *path, unsigned pathlen )
{
  void far *filename;
  int handle,retv= NORMAL ;
  CASHRECORD far *cashier;

  if ( recvLen != sizeof(CASHRECORD) )
     return (INV_RECV_PARAM);

  if (( filename = _xalloc(13+pathlen)) == NULL)
  {
     return(MEM_ALLOC_ERR);
  }    

  _bset( filename,0x0,13+pathlen);    
  _bcopy(filename,path,pathlen);
  _bcopy((char *) filename+pathlen,CASHIER_FILE_NAME,sizeof(CASHIER_FILE_NAME) );
  
  handle = _fsOpen( filename, FO_READWRITE | FO_SHARED );

  _xfree( filename );

  if (_fsError())
     return (FILE_OPEN_ERR);

  cashier = receive_buffer;

  _fsSeek( handle, 0L, FS_SET ); 
  
  if ( _fsRead( handle,(char *) cashier , sizeof(CASHRECORD) ) != sizeof(CASHRECORD) )
       retv = BTRIEVE_ENDOFFILE ;
  else 
  {
       retv = NORMAL;
       position = 0L;
  }
                  
  _fsClose( handle );

  return ( retv );    
}


int cashier_get_next( void far *receive_buffer, unsigned recvLen,
                      char far *path, unsigned pathlen )
{
  void far *filename;
  int handle,retv;
  CASHRECORD far *cashier;

  if ( recvLen != sizeof(CASHRECORD) )
     return (INV_RECV_PARAM);

  if (( filename = _xalloc(13+pathlen)) == NULL)
  {
     return(MEM_ALLOC_ERR);
  }    

  _bset( filename,0x0,13+pathlen);    
  _bcopy(filename,path,pathlen);
  _bcopy((char *) filename+pathlen,CASHIER_FILE_NAME,sizeof(CASHIER_FILE_NAME) );
  
  handle = _fsOpen( filename, FO_READWRITE | FO_SHARED );

  _xfree( filename );

  if (_fsError())
     return (FILE_OPEN_ERR);

  cashier =  receive_buffer;

  if ( position != -1L )
     _fsSeek( handle, position+sizeof(CASHRECORD), FS_SET );
  else    
     _fsSeek( handle, 0L, FS_SET ); 
       
  if ( _fsRead( handle,(char *) cashier , sizeof(CASHRECORD) ) != sizeof(CASHRECORD) )
       retv = BTRIEVE_ENDOFFILE ;
  else 
  {
       retv = NORMAL;
       position += sizeof(CASHRECORD);
  }
                  
  _fsClose( handle );

  return ( retv );    
}


int cashier_get_previous( void far *receive_buffer, unsigned recvLen,
                      char far *path, unsigned pathlen )
{
  void far *filename;
  int handle,retv;
  CASHRECORD far *cashier;

  if ( recvLen != sizeof(CASHRECORD) )
     return (INV_RECV_PARAM);

  if (( filename = _xalloc(13+pathlen)) == NULL)
  {
     return(MEM_ALLOC_ERR);
  }    

  _bset( filename,0x0,13+pathlen);    
  _bcopy(filename,path,pathlen);
  _bcopy((char *) filename+pathlen,CASHIER_FILE_NAME,sizeof(CASHIER_FILE_NAME) );
  
  handle = _fsOpen( filename, FO_READWRITE | FO_SHARED );

  _xfree( filename );

  if (_fsError())
     return (FILE_OPEN_ERR);

  cashier =  receive_buffer;

  if ( position < sizeof(CASHRECORD) )
  {
     _fsSeek( handle, 0L, FS_SET);
     retv = BTRIEVE_BEGOFFILE;
  }   
  else
  {
     _fsSeek( handle, position - sizeof(CASHRECORD), FS_SET );
     retv = NORMAL;
     position -= sizeof(CASHRECORD);
  }   
     
  if ( _fsRead( handle,(char *) cashier , sizeof(CASHRECORD) ) != sizeof(CASHRECORD) )
       position = ( _fsSeek( handle, 0L, FS_RELATIVE ) - sizeof(CASHRECORD));
  
                  
  _fsClose( handle );

  return ( retv );    
}


int cashier_get_last( void far *receive_buffer, unsigned recvLen,
                      char far *path, unsigned pathlen )
{
  void far *filename;
  int handle,retv;
  CASHRECORD far *cashier;

  if ( recvLen != sizeof(CASHRECORD) )
     return (INV_RECV_PARAM);

  if (( filename = _xalloc(13+pathlen)) == NULL)
  {
     return(MEM_ALLOC_ERR);
  }    

  _bset( filename,0x0,13+pathlen);    
  _bcopy(filename,path,pathlen);
  _bcopy((char *) filename+pathlen,CASHIER_FILE_NAME,sizeof(CASHIER_FILE_NAME) );
  
  handle = _fsOpen( filename, FO_READWRITE | FO_SHARED );

  _xfree( filename );

  if (_fsError())
     return (FILE_OPEN_ERR);

  cashier =  receive_buffer;

  position = _fsSeek( handle, 0L, FS_END );  

  position = _fsSeek( handle, position-sizeof(CASHRECORD) , FS_SET );

  if ( position < 0 )
    position = 0;
       
  if ( _fsRead( handle,(char *) cashier , sizeof(CASHRECORD) ) != sizeof(CASHRECORD) )
       retv = BTRIEVE_ENDOFFILE ;
  else 
       retv = NORMAL;
                  
  _fsClose( handle );

  return ( retv );    
}

#endif



/* EOF */




