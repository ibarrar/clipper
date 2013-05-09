/*
 * System........ PowerPos for Spectrum
 * Program I.D... return.c
 * Author........ Rollie Castro Ibarra Jr.
 * Date Started.. Aug 8 1997
 * Modified...... Aug 8 1997
 * Dialect....... MicroSoft C
 
*/

/*
#include "stdlib.h"
#include "stdio.h"
#include "string.h"
*/

#include "extend.h"
#include "faccess.h"
#include "btrieve.h"
#include "return.h"

#pragma check_stack-

static char filePosBlock[128];
static int bufLen;
static int posLen;
static long position = -1L;

/* declare the RETURN buffer */
static RETURN_RECORD returndata;

static int return_open_file( char * path, unsigned int path_len);
static int return_close_file( void );

int return_create( void far *path, unsigned pathlen )
{

  void far *filename;
  FileSpecType far *fileSpecBuf;
  int retv,specLen;

  /* declare the RETURN_RECORD, RETURN buffer  and RETURN key structures... */

  /* determine where to SEEK... */
 if (( filename = _xalloc(13+pathlen)) == NULL )
     return ( MEM_ALLOC_ERR );

  _bset( filename, 0x0, 13+pathlen );
  _bcopy( filename,path,pathlen );
  _bcopy((char *) filename+pathlen,RETURN_FILE_NAME,sizeof(RETURN_FILE_NAME));

  if (( fileSpecBuf = _xalloc(sizeof(FileSpecType))) == NULL )
  {
    _xfree( filename );
    return (MEM_ALLOC_ERR);
  }    

  _bset(fileSpecBuf, 0x0, sizeof(fileSpecBuf) );
  
  specLen = sizeof(FileSpecType);
    
  fileSpecBuf->recordLength = sizeof(RETURN_RECORD);
  fileSpecBuf->pageSize = 1024;
  fileSpecBuf->indexCount = 1;             /* With one key     */
  fileSpecBuf->fileFlags = 0;              /* Default settings */
  fileSpecBuf->keySpecBuf.keyPos = 1;
  fileSpecBuf->keySpecBuf.keyLen = RET_PLUCODE_LEN;
  fileSpecBuf->keySpecBuf.keyFlag = 0;     /* Standard         */
  fileSpecBuf->keySpecBuf.keyType = 0;     /* String type      */

  retv = BTRV(B_CREATE, filePosBlock, (char *) fileSpecBuf, &specLen, filename, 0);
  
  _xfree(fileSpecBuf);  
  _xfree(filename);
  
  if(retv != NORMAL)
  {   
      return (BTRIEVE_CREATE_ERR);
  }    
  
  return NORMAL;
}

static int return_open_file(char * path , unsigned int path_len )
{
 void far *filename;
 int retv = NORMAL;

 /* do the btrieve seek and form the frame parameter... */      
 if (( filename = _xalloc(13+path_len)) == NULL )
       return ( MEM_ALLOC_ERR );

   _bset(filename,0x0,13+path_len);
   _bcopy(filename,path,path_len);
   _bcopy((char *)filename+path_len,RETURN_FILE_NAME,sizeof(RETURN_FILE_NAME));                   
   
   posLen = sizeof(position);
   bufLen = sizeof(RETURN_RECORD);
   /* open the standard btrieve file (RETURN.IDX)... */            
   retv = BTRV (B_OPEN, filePosBlock,(char *) &returndata, &bufLen, filename, 0 );


#ifdef AUTO_CREATE   
   if ( retv == 12 ) /* status for file not found */
   {
     retv = return_create( path, path_len );      

     if ( retv != NORMAL )
     {
        _xfree(filename);           
        return retv;
     }
        
     /* open the standard btrieve file (RETURN.IDX)... */            
     retv = BTRV (B_OPEN, filePosBlock,(char *) &returndata, &bufLen, filename, 0 );        
   }        
#endif     

   _xfree(filename);           
   
   if (  retv  != NORMAL )
       retv = BTRIEVE_OPEN_ERR ;
   
 return retv;      
}

static int return_close_file( void )
{
  return BTRV (B_CLOSE, filePosBlock,(char *) &returndata, &bufLen, NULL, 0 );    
}

int return_search_and_get(void far *receive_buffer, unsigned recvLen,
                          void far *data, unsigned sendLen,
                          void far *path, unsigned pathlen )
{

  int retv;
  unsigned char code[15];
  RETURN_RECORD *returned;

  if ( recvLen != sizeof( RETURN_RECORD ) )
     return ( INV_RECV_PARAM );

  if ( sendLen != sizeof(returned->plu_code) )
     return ( INV_SEND_PARAM );

  returned = receive_buffer;
  _bset(code,0x0,sizeof(code));

  _bcopy(code,data,sendLen);
       
  if (( retv = return_open_file(path,pathlen)) != NORMAL )
     return retv;
  
  /* issue a btrieve seek (GET EQUAL) request... */
  retv = BTRV (B_GETEQ, filePosBlock, (char *) returned, &bufLen, code, 0);      

  if ( retv != NORMAL )
      retv = CODE_NOT_FOUND;
  else
  {
     posLen = sizeof(position);
     BTRV ( B_GETPOSI, filePosBlock, (char *) &position, &posLen, code, 0);
  }

  return_close_file();
     
  return ( retv );
       
}                          


int return_search_and_put(void far *data, unsigned datalen,
                          void far *path, unsigned pathlen )
{                     
   char code[15];  
   int retv;
   RETURN_RECORD far *returned;
  
   if (datalen != sizeof(RETURN_RECORD))
     return (INV_SEND_PARAM);

   /* yes my data is the data sent from clipper */  

   returned = data;
   
   _bset(code,0x0,sizeof(code));
   _bcopy(code,data,sizeof(returned->plu_code));
   
   if (( retv = return_open_file(path,pathlen)) != NORMAL )
      return retv;
     
   /* issue a btrieve seek (GET EQUAL) request... */
   retv = BTRV (B_GETEQ, filePosBlock, (char *) &returndata, &bufLen, code, 0);   

   if ( retv != NORMAL )
   {
     retv = BTRV(B_INSERT, filePosBlock, (char *) returned, &bufLen, code, 0);
   
     if (retv != NORMAL)
	 retv = BTRIEVE_INSERT_ERR;
   }
   else
   {     

     /* overwrite the record */
     retv = BTRV(B_UPDATE, filePosBlock, (char *) returned, &bufLen, code, 0);

     if (retv != NORMAL)
        retv = BTRIEVE_UPDATE_ERR;
   
   }       
          
   /* close the standard Btrieve file ... */      
   return_close_file();             
   
   return (retv);
}
    
  
int return_search_and_delete(void far *data, unsigned datalen,
                             void far *path, unsigned pathlen )
                           
{

 char code[15];  
 int retv;

   if (datalen != sizeof(returndata.plu_code))
     return (INV_SEND_PARAM);

   _bset(code,0x0,sizeof(code));
   _bcopy(code,data,sizeof(returndata.plu_code));
   
   if (( retv = return_open_file(path,pathlen)) != NORMAL )
      return retv;
     
   /* issue a btrieve seek (GET EQUAL) request... */

   retv = BTRV (B_GETEQ, filePosBlock, (char *) &returndata, &bufLen, code, 0);   

   if ( retv == NORMAL )
      retv = BTRV(B_DELETE,filePosBlock, (char*) &returndata, &bufLen,code,0);          
   else
      retv = NORMAL;
  
  return_close_file();    

 return (retv);
}


int return_get_first(void far *receive_buffer, unsigned recvLen,
                     void far *path, unsigned pathlen )
{
  int retv;
  unsigned char code[15];

  RETURN_RECORD far *returned;

  if ( recvLen != sizeof(RETURN_RECORD) )
    return (INV_RECV_PARAM);

  returned = receive_buffer;
  _bset ( code, 0x0, sizeof(code) );

  if (( retv = return_open_file (path,pathlen) ) != NORMAL )
     return retv;

  /* issue a btrieve seek (GET FIRST) request... */
  retv = BTRV (B_GETFIRST, filePosBlock, (char *) returned, &bufLen, code, 0 );

  if ( retv != NORMAL )
     retv = BTRIEVE_ENDOFFILE;
  else
  {
     posLen = sizeof(position);
     BTRV (B_GETPOSI, filePosBlock, (char *) &position, &posLen, code, 0 );           
  }  

  return_close_file();
       
  return (retv);
}


int return_get_next(void far *receive_buffer, unsigned recvLen,
                    void far *path, unsigned pathlen )
{
   int retv;
   char code[15];
   RETURN_RECORD far *returned;
   
   if ( recvLen != sizeof(RETURN_RECORD))
      return (INV_SEND_PARAM );      
             
   returned = receive_buffer;

   if ( (retv = return_open_file (path,pathlen) ) != NORMAL )
      return retv;

   /* check first if btrieve is in valid positioning */
   if ( position == -1L)
   {
     /* invalid positioning get first record */ 
     BTRV (B_GETFIRST, filePosBlock, (char *)returned, &bufLen, code, 0 );
   }
   else
   {
     _bcopy(returned,(char *)&position,sizeof(position));
     retv = BTRV(B_DIRECT, filePosBlock, (char *) returned, &bufLen, code, 0 );
   }     

   /* issue a btrieve seek (GET NEXT) request... */
   retv = BTRV (B_GETNEXT, filePosBlock, (char *) returned, &bufLen, code, 0 );

   if (retv != NORMAL)
       retv =  BTRIEVE_ENDOFFILE;
   else
       retv = BTRV (B_GETPOSI, filePosBlock, (char *) &position, &posLen, code, 0 );           

   return_close_file();
          
   return (retv);
}


int return_get_previous(void far *receive_buffer, unsigned recvLen,
                      void far *path, unsigned pathlen )
{
   int retv;
   unsigned char code[15];
   RETURN_RECORD far *returned;   
   
   if ( recvLen != sizeof(RETURN_RECORD))
      return (INV_SEND_PARAM );      
             
   returned = receive_buffer;

   if ( (retv = return_open_file (path,pathlen) ) != NORMAL )
      return retv;

   /* check first if btrieve is in valid positioning */
   if (position == -1L)
   {
     /* invalid positioning get first record */ 
     BTRV (B_GETFIRST, filePosBlock, (char *) returned, &bufLen, code, 0 );
   }
   else
   {
     _bcopy(returned,(char *)&position, sizeof(position) );
     retv =  BTRV(B_DIRECT, filePosBlock, (char *) returned, &bufLen, code, 0);
   }     
      
   /* issue a btrieve seek (GET NEXT) request... */
   retv = BTRV (B_GETPREV, filePosBlock, (char *) returned, &bufLen, code, 0 );

   if (retv != NORMAL)
       retv =  BTRIEVE_BEGOFFILE;
   else
       retv = BTRV (B_GETPOSI, filePosBlock, (char *) &position, &posLen, code, 0 );

   return_close_file();
       
   return (retv);
}


int return_get_last(void far *receive_buffer, unsigned recvLen,
                    void far *path, unsigned pathlen )
{
   int retv;
   unsigned char code[15];

   RETURN_RECORD far *returned;
   
   if ( recvLen != sizeof(RETURN_RECORD) )
      return (INV_RECV_PARAM );
             
   returned = receive_buffer;
   _bset ( code, 0x0, sizeof(code) );

   if ( (retv = return_open_file (path,pathlen) ) != NORMAL )
      return retv;

   /* issue a btrieve seek (GET LAST) request... */
   retv = BTRV (B_GETLAST, filePosBlock, (char *) returned, &bufLen, code, 0 );


   if ( retv != NORMAL )
     retv = BTRIEVE_BEGOFFILE;
   else
   {   
     retv = BTRV (B_GETPOSI, filePosBlock, (char *) &position, &posLen, code, 0 );                
   }
   
   return_close_file();
       
   return (retv);
}


/* Eof() */
  