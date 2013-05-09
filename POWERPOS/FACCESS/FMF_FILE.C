#include <stdio.h>
#include <stdlib.h>

#include "fmf_file.h"
#include "extend.h"
#include "filesys.api"
#include "faccess.h"

#pragma check_stack-

static int handle;
static int open = 0;
static long position = -1L;

static fmf_file_open(void far *path, unsigned pathlen);

int fmf_search_and_get (void far *receive_buffer, unsigned recvlen,
                        void far *data, unsigned datalen,
                        void far *path, unsigned pathlen )
{  
   FMF_RECORD *fmf;
   char asc_recno[9];
   unsigned long offset   = 0L;
   unsigned long currRec  = 0L;
   int  retv = NORMAL;
         
   if (recvlen != sizeof(FMF_RECORD) ) 
       return(INV_RECV_PARAM);

   if (datalen != sizeof(fmf->trans_no) )
       return(INV_SEND_PARAM);      
      
   /* convert the parameter record_no into long & return if LESS THAN 1... */
   _bset(asc_recno,0x0,sizeof(asc_recno));   
   _bcopy(asc_recno,data,datalen);
   
   currRec = atol (asc_recno);

   if (  currRec < 1L )
     return (INVALID_REC_NO);

   offset = (currRec-1)*sizeof(FMF_RECORD);

   if ( (retv = fmf_file_open(path,pathlen)) != NORMAL )
      return retv;   

   fmf = receive_buffer;
         
   /* position the pointer and read the record... */
   if ( _fsSeek( handle, offset, FS_SET ) == offset )
   { 
      if ( _fsRead(handle,(char *) fmf, sizeof(FMF_RECORD)) != sizeof(FMF_RECORD) )          
       retv = FILE_READ_ERR;      
   }
   else  
       retv = CODE_NOT_FOUND;
      
#ifdef DEBUG
    printf("Normal return \n");
#endif    
   return(retv);
}

static fmf_file_open(void far *path, unsigned pathlen)
{
 void far *filename;

 if ( open == 0 )
 {
    if (( filename = _xalloc(13+pathlen)) == NULL)
       return(MEM_ALLOC_ERR);

	_bset( filename,0x0,13+pathlen);    
	_bcopy(filename,path,pathlen);
	_bcopy((char *) filename+pathlen,FMF_FILE_NAME,sizeof(FMF_FILE_NAME));

	/* open the text file in read ONLY, binary mode, and deny writing... */

	 handle = _fsOpen( filename,  FO_READ | FO_SHARED );   

	 _xfree( filename );   

	 if ( _fsError() )
		  return( FILE_OPEN_ERR );
	 else    
	 {
		  open = 1;
		  return ( NORMAL );
	 }   

 }
 else
    return( NORMAL );   
} 

int  fmf_close_file( void )
{
  if ( open )
     _fsClose(handle);

  open = 0;   

  return NORMAL;       
}


int fmf_delete(void far *path, unsigned pathlen)
{
  void far *filename;

  if (open)
    fmf_close_file();

  if (( filename = _xalloc(13+pathlen)) == NULL)
     return(MEM_ALLOC_ERR);

  _bset( filename,0x0,13+pathlen);    
  _bcopy(filename,path,pathlen);
  _bcopy((char *) filename+pathlen,FMF_FILE_NAME,sizeof(FMF_FILE_NAME));

  _fsCreate(filename,FC_NORMAL);

  _xfree(filename);
        
  if (_fsError())
  {
    return (FILE_DELETE_ERR);
  }
  
  return NORMAL;
}


int fmf_comp_last_trans_no(void far *receive_buffer, unsigned recvLen,
                           char far *path, unsigned pathlen)
{
  unsigned long offset = 0L;
  unsigned long currec = 0L;
  void far *return_val;
  int retv = NORMAL;

  if ( recvLen < 8 )
     return (INV_RECV_PARAM);

  if ( ( retv = fmf_file_open(path,pathlen) ) != NORMAL )
     return retv;

  /* go to the end of file and get the file size... */

  offset = _fsSeek(handle, 0L, FS_END);

  /* compute for the offset to read the last record... */

  currec = (unsigned long) (offset/sizeof(FMF_RECORD));

  return_val =  receive_buffer;
  
  _bset(return_val,0x0,recvLen);

  sprintf(return_val,"%08ld",currec);
  
  return (NORMAL);
}

#ifdef BROWSE_FUNCTIONS
int fmf_get_first( void far *receive_buffer, unsigned recvLen,
                       char far *path, unsigned pathlen )
{
  int retv= NORMAL ;
  FMF_RECORD far *fmf;

  if ( recvLen != sizeof(FMF_RECORD) )
     return (INV_RECV_PARAM);

  if (( retv = fmf_file_open(path,pathlen) ) != NORMAL )
      return retv;
      
  fmf = receive_buffer;

  _fsSeek( handle, 0L, FS_SET ); 
  
  if ( _fsRead( handle,(char *) fmf , sizeof(FMF_RECORD) ) != sizeof(FMF_RECORD) )
       retv = BTRIEVE_ENDOFFILE ;
  else 
  {
       retv = NORMAL;
       position = 0L;
  }
                  
  return ( retv );    
}


int fmf_get_next( void far *receive_buffer, unsigned recvLen,
                      char far *path, unsigned pathlen )
{
  int retv;
  FMF_RECORD far *fmf;

  if ( recvLen != sizeof(FMF_RECORD) )
     return (INV_RECV_PARAM);

  if (( retv = fmf_file_open(path,pathlen) ) != NORMAL )
      return retv;
      
  fmf =  receive_buffer;

  if ( position != -1L )
     _fsSeek( handle, position+sizeof(FMF_RECORD), FS_SET );
  else    
     _fsSeek( handle, 0L, FS_SET ); 
       
  if ( _fsRead( handle,(char *) fmf , sizeof(FMF_RECORD) ) != sizeof(FMF_RECORD) )
       retv = BTRIEVE_ENDOFFILE ;
  else 
  {
       retv = NORMAL;
       position += sizeof(FMF_RECORD);
  }
                  
  return ( retv );    
}


int fmf_get_previous( void far *receive_buffer, unsigned recvLen,
                      char far *path, unsigned pathlen )
{
  int retv;
  FMF_RECORD far *fmf;

  if ( recvLen != sizeof(FMF_RECORD) )
     return (INV_RECV_PARAM);

  if (( retv = fmf_file_open(path,pathlen) ) != NORMAL )
      return retv;     

  fmf =  receive_buffer;

  if ( position < sizeof(FMF_RECORD) )
  {
     _fsSeek( handle, 0L, FS_SET);
     retv = BTRIEVE_BEGOFFILE;
  }   
  else
  {
     _fsSeek( handle, position - sizeof(FMF_RECORD), FS_SET );
     retv = NORMAL;
     position -= sizeof(FMF_RECORD);
  }   
     
  if ( _fsRead( handle,(char *) fmf , sizeof(FMF_RECORD) ) != sizeof(FMF_RECORD) )
       position = ( _fsSeek( handle, 0L, FS_RELATIVE ) - sizeof(FMF_RECORD));
  
                  
  return ( retv );    
}


int fmf_get_last( void far *receive_buffer, unsigned recvLen,
                      char far *path, unsigned pathlen )
{
  int retv;
  FMF_RECORD far *fmf;

  if ( recvLen != sizeof(FMF_RECORD) )
     return (INV_RECV_PARAM);

  if (( retv = fmf_file_open(path,pathlen) ) != NORMAL )
      return retv;     

  fmf =  receive_buffer;

  position = _fsSeek( handle, 0L, FS_END );  

  position = _fsSeek( handle, position-sizeof(FMF_RECORD) , FS_SET );

  if ( position < 0 )
    position = 0;
       
  if ( _fsRead( handle,(char *) fmf, sizeof(FMF_RECORD) ) != sizeof(FMF_RECORD) )
       retv = BTRIEVE_ENDOFFILE ;
  else 
       retv = NORMAL;
                  
  return ( retv );    
}


#endif

/* EOF */    