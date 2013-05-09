/*
 * System........ PowerPos for Spectrum
 * Program I.D... clrkfile.c
 * Author........ Rollie Castro Ibarra Jr.
 * Date Started.. Sept 6 1996
 * Modified...... Sept 6 1996
 * Dialect....... MicroSoft C
*/

#include "extend.h"
#include "faccess.h"
#include "clrkfile.h"
#include "btrieve.h"

#pragma check_stack-

static char filePosBlock[128];
static int bufLen;
static int posLen;
static long position = -1L;

/* declare the CLERK buffer, and CLERK key structures... */
static CLERK_RECORD clerkdata;

static int clerk_open_file(char * path, unsigned int path_len );
static int clerk_close_file( void );

int clerk_create(void far *path, unsigned pathlen)
{
  void far * filename;
  FileSpecType far * fileSpecBuf;    
  int  retv,specLen;
    
  /* determine where is the file... */
  if (( filename = _xalloc(13+pathlen)) == NULL)
      return(MEM_ALLOC_ERR);

  _bset( filename,0x0,13+pathlen);
  _bcopy(filename,path,pathlen);
  _bcopy((char *) filename+pathlen,CLERK_IDX_FILE_NAME,sizeof(CLERK_IDX_FILE_NAME));

  if (( fileSpecBuf = _xalloc(sizeof(FileSpecType)) ) == NULL)
  {
      _xfree( filename ); 
      return (MEM_ALLOC_ERR);
  }    

  _bset(fileSpecBuf, 0x0, sizeof(fileSpecBuf) );
  
  specLen = sizeof(FileSpecType);

  fileSpecBuf->recordLength = sizeof(CLERK_RECORD);
  fileSpecBuf->pageSize = 1024;
  fileSpecBuf->indexCount = 1;                /* With one key     */
  fileSpecBuf->fileFlags = 0;                  /* Default settings */
  fileSpecBuf->keySpecBuf.keyPos =  1;
  fileSpecBuf->keySpecBuf.keyLen =  6;
  fileSpecBuf->keySpecBuf.keyFlag = 0;         /* Standard         */
  fileSpecBuf->keySpecBuf.keyType = 0;         /* String type      */

  retv = BTRV(B_CREATE, filePosBlock, (char *) fileSpecBuf, &specLen, filename, 0);

  _xfree(fileSpecBuf);
  _xfree(filename);

#ifdef DEBUG 
  printf("\n status creating clerk btrieve file : %d",retv);
#endif    
  
  if(retv != NORMAL)
      return (BTRIEVE_CREATE_ERR);

  return NORMAL;
}

static int clerk_open_file(char * path , unsigned int path_len )
{
 void far *filename;
 int retv = NORMAL;

 /* do the btrieve seek and form the frame parameter... */      
 if (( filename = _xalloc(13+path_len)) == NULL )
       return ( MEM_ALLOC_ERR );

   _bset(filename,0x0,13+path_len);
   _bcopy(filename,path,path_len);
   _bcopy((char *)filename+path_len,CLERK_IDX_FILE_NAME,sizeof(CLERK_IDX_FILE_NAME));                   
   
   posLen = sizeof(position);
   bufLen = sizeof(CLERK_RECORD);
   /* open the standard btrieve file (CLERK.IDX)... */            
   retv = BTRV (B_OPEN, filePosBlock,(char *) &clerkdata, &bufLen, filename, 0 );


#ifdef AUTO_CREATE   
   if ( retv == 12 ) /* status for file not found */
   {
     retv = clerk_create( path, path_len );      

     if ( retv != NORMAL )
     {
        _xfree(filename);           
        return retv;
     }
        
     /* open the standard btrieve file (CLERK.IDX)... */            
     retv = BTRV (B_OPEN, filePosBlock,(char *) &clerkdata, &bufLen, filename, 0 );        
   }        
#endif     

   _xfree(filename);           
   
   if (  retv  != NORMAL )
       retv = BTRIEVE_OPEN_ERR ;
   
 return retv;      
}

int clerk_close_file( void )
{
  return BTRV (B_CLOSE, filePosBlock,(char *) &clerkdata, &bufLen, NULL, 0 );    
}

int clerk_search_and_get(void far *receive_buffer, unsigned recvLen,
                         void far *data, unsigned sendLen,
                         void far *path, unsigned pathlen )
{
   int retv;
   unsigned char code[7];
   CLERK_RECORD far *clrk;
   
   if ( recvLen != sizeof(CLERK_RECORD) )
      return (INV_RECV_PARAM );

   if ( sendLen != sizeof(clrk->clerk_code) )
      return (INV_SEND_PARAM );

   clrk = receive_buffer;
   _bset (code, 0x0, sizeof(code));   

   /* get the CLERK code to search... */
   /* data is in ASCII */
   _bcopy(code,data,sendLen);

   if ((retv = clerk_open_file(path,pathlen)) != NORMAL )
       return retv;

   /* issue a btrieve seek (GET EQUAL) request... */
   retv = BTRV (B_GETEQ, filePosBlock, (char *)clrk, &bufLen, code, 0 );       

   if ( retv == NORMAL )
   {
     if ( clrk->deleted == '*' )
         retv = CODE_NOT_FOUND;
   }

   if ( retv != NORMAL )
     retv = CODE_NOT_FOUND;
   else
   {
     posLen = sizeof(position);
     BTRV (B_GETPOSI, filePosBlock, (char *) &position, &posLen, code, 0 );
   }  

   clerk_close_file();
      
   
  return (retv);
}


int clerk_search_and_put(void far *data, unsigned datalen,
                        void far *path, unsigned pathlen )
{
   char code[7];  
   int retv;
   
   CLERK_RECORD far *clrk;
  
   if (datalen != sizeof(CLERK_RECORD))
     return (INV_SEND_PARAM);

   /* yes my data is the data sent from clipper */  

   clrk = data;
   
   _bset(code,0x0,sizeof(code));
   _bcopy(code,data,sizeof(clrk->clerk_code));

   if ( ( retv = clerk_open_file(path,pathlen)) != NORMAL )
      return retv;

   /* issue a btrieve seek (GET EQUAL) request... */
   retv = BTRV (B_GETEQ, filePosBlock, (char *) &clerkdata, &bufLen, code, 0);

   if ( retv == NORMAL )
   {
     clrk->deleted    = ' ';
     
     /*clrk->quantity.n += clerkdata.quantity.n;
     clrk->amount.n   += clerkdata.amount.n;
     clrk->discount.n += clerkdata.discount.n;
     clrk->ptd_qty.n  += clerkdata.ptd_qty.n;
     clrk->ptd_amt.n  += clerkdata.ptd_amt.n;
     clrk->ptd_dsc.n  += clerkdata.ptd_dsc.n;      
     */
      retv = BTRV (B_UPDATE, filePosBlock, (char *) clrk, &bufLen, code, 0);
      if ( retv !=  NORMAL )
         retv = BTRIEVE_UPDATE_ERR;
   }
   else
   {
      clrk->deleted = ' ';

      retv = BTRV(B_INSERT, filePosBlock, (char *) clrk, &bufLen, code, 0);

      if (retv != NORMAL)
          retv = BTRIEVE_INSERT_ERR;
   }

   clerk_close_file();
         
   return (retv);                              

}


int clerk_search_and_delete(void far *data, unsigned datalen,                          
                            void far *path, unsigned pathlen )
{
    char code[7];
    int retv;


    if ( datalen != sizeof(clerkdata.clerk_code) )
       return ( INV_SEND_PARAM );
    
    /* initialize local variables with zeroes... */

    _bset (code, 0x0, sizeof(code));       

    /* get the CLERK code to search... */

    _bcopy(code,data,sizeof(clerkdata.clerk_code));

    if ( ( retv = clerk_open_file(path,pathlen)) != NORMAL )
      return retv;

    /* issue a btrieve seek (GET EQUAL) request... */

    retv = BTRV (B_GETEQ, filePosBlock, (char *) &clerkdata, &bufLen, code, 0);
        
    if (retv == NORMAL)
    {

       if (( clerkdata.quantity.n + clerkdata.amount.n + clerkdata.discount.n +
             clerkdata.ptd_qty.n  + clerkdata.ptd_amt.n + clerkdata.ptd_dsc.n ) != 0 )
       {
         clerkdata.deleted = '*';
         retv = BTRV (B_UPDATE, filePosBlock, (char *) &clerkdata, &bufLen, code, 0);
         if (retv != NORMAL)
            retv = BTRIEVE_UPDATE_ERR;
       }        
       else
       {
         retv = BTRV (B_DELETE, filePosBlock, (char *) &clerkdata, &bufLen, code, 0);
         if (retv != NORMAL )
             retv = BTRIEVE_DELETE_ERR;
       }     
         
    }
    else
     retv = CODE_NOT_FOUND;

    clerk_close_file();    
       
  return(retv);
}

int clerk_get_first(void far *receive_buffer, unsigned recvLen,
                   void far *path, unsigned pathlen )
{
  int retv;
  unsigned char code[7];

  CLERK_RECORD far *clrk;

  if ( recvLen != sizeof(CLERK_RECORD) )
    return (INV_RECV_PARAM);

  clrk = receive_buffer;
  _bset ( code, 0x0, sizeof(code) );

  if (( retv = clerk_open_file (path,pathlen) ) != NORMAL )
     return retv;

  /* issue a btrieve seek (GET FIRST) request... */
  retv = BTRV (B_GETFIRST, filePosBlock, (char *) clrk, &bufLen, code, 0 );

  while ( retv == NORMAL  &&  clrk->deleted == '*' )
  {
     retv = BTRV (B_GETNEXT, filePosBlock, (char *) clrk, &bufLen, code, 0 );           
  }
     
  if ( retv != NORMAL )
     retv = BTRIEVE_ENDOFFILE;
  else
  {
     posLen = sizeof(position);
     BTRV (B_GETPOSI, filePosBlock, (char *) &position, &posLen, code, 0 );           
  }  

  clerk_close_file();
       
  return (retv);
}


int clerk_get_next(void far *receive_buffer, unsigned recvLen,
                   void far *path, unsigned pathlen )
{
   int retv;
   char code[7];
   CLERK_RECORD far *clrk;
   
   if ( recvLen != sizeof(CLERK_RECORD))
      return (INV_SEND_PARAM );      
             
   clrk = receive_buffer;

   if ( (retv = clerk_open_file (path,pathlen) ) != NORMAL )
      return retv;

   /* check first if btrieve is in valid positioning */
   if ( position == -1L)
   {
     /* invalid positioning get first record */ 
     BTRV (B_GETFIRST, filePosBlock, (char *)clrk, &bufLen, code, 0 );
   }
   else
   {
     _bcopy(clrk,(char *)&position,sizeof(position));
     retv = BTRV(B_DIRECT, filePosBlock, (char *) clrk, &bufLen, code, 0 );
   }     

   /* issue a btrieve seek (GET NEXT) request... */
   retv = BTRV (B_GETNEXT, filePosBlock, (char *) clrk, &bufLen, code, 0 );

   while ( retv == NORMAL  &&  clrk->deleted == '*' )   
   {
      retv = BTRV (B_GETNEXT, filePosBlock, (char *) clrk, &bufLen, code, 0 );
   }        

   if (retv != NORMAL)
   {
       retv =  BTRIEVE_ENDOFFILE;
   }    
   else
   {
     retv = BTRV (B_GETPOSI, filePosBlock, (char *) &position, &posLen, code, 0 );           
   }         

   clerk_close_file();
          
   return (retv);
}


int clerk_get_previous(void far *receive_buffer, unsigned recvLen,
                       void far *path, unsigned pathlen )
{
   int retv;
   unsigned char code[7];
   CLERK_RECORD far *clrk;
   
   if ( recvLen != sizeof(CLERK_RECORD))
      return (INV_SEND_PARAM );      
             
   clrk = receive_buffer;

   if ( (retv = clerk_open_file (path,pathlen) ) != NORMAL )
      return retv;

   /* check first if btrieve is in valid positioning */
   if (position == -1L)
   {
     /* invalid positioning get first record */ 
     BTRV (B_GETFIRST, filePosBlock, (char *) clrk, &bufLen, code, 0 );
   }
   else
   {
     _bcopy(clrk,(char *)&position, sizeof(position) );
     retv =  BTRV(B_DIRECT, filePosBlock, (char *) clrk, &bufLen, code, 0);
   }     
      
   /* issue a btrieve seek (GET NEXT) request... */
   retv = BTRV (B_GETPREV, filePosBlock, (char *) clrk, &bufLen, code, 0 );

   while ( retv == NORMAL  &&  clrk->deleted == '*' )   
   {
      retv = BTRV (B_GETPREV, filePosBlock, (char *) clrk, &bufLen, code, 0 );           
   }        

   if (retv != NORMAL)
   {
       retv =  BTRIEVE_BEGOFFILE;
   }    
   else
   {
       retv = BTRV (B_GETPOSI, filePosBlock, (char *) &position, &posLen, code, 0 );           
   }                

   clerk_close_file();
       
   return (retv);
}


int clerk_get_last(void far *receive_buffer, unsigned recvLen,
                   void far *path, unsigned pathlen )
{
   int retv;
   unsigned char code[7];

   CLERK_RECORD far *clrk;
   
   if ( recvLen != sizeof(CLERK_RECORD) )
      return (INV_RECV_PARAM );
             
   clrk = receive_buffer;
   _bset ( code, 0x0, sizeof(code) );

   if ( (retv = clerk_open_file (path,pathlen) ) != NORMAL )
      return retv;

   /* issue a btrieve seek (GET LAST) request... */
   retv = BTRV (B_GETLAST, filePosBlock, (char *) clrk, &bufLen, code, 0 );

   while ( retv == NORMAL  &&  clrk->deleted == '*' )   
   {
      retv = BTRV (B_GETPREV, filePosBlock, (char *) clrk, &bufLen, code, 0 );           
   }

   if ( retv != NORMAL )
     retv = BTRIEVE_BEGOFFILE;
   else
   {   
     retv = BTRV (B_GETPOSI, filePosBlock, (char *) &position, &posLen, code, 0 );                
   }
   
   clerk_close_file();
       
   return (retv);
}


/* EOF */


