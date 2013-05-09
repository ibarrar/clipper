/*
 * System........ PowerPos for Spectrum
 * Program I.D... plu_file.c
 * Author........ Rollie Castro Ibarra Jr.
 * Date Started.. September 2 1996
 * Modified...... December 27 1996
 * Dialect....... MicroSoft C
*/

#include <string.h>

#include "extend.h"
#include "faccess.h"
#include "btrieve.h"
#include "plu_temp.h"

#pragma check_stack-
#pragma intrinsic (memcmp)


static char   filePosBlock[128];
static int    bufLen;
static int    posLen;
static long   position = -1L;
static PLUTEMP_RECORD tmpdata;

int plutmp_create(void far *path, unsigned pathlen )
{
  void far *filename;
  FileSpecType far *fileSpecBuf;
  int retv,specLen;

  /* determine where to SEEK... */
  if (( filename = _xalloc(13+pathlen)) == NULL )
     return ( MEM_ALLOC_ERR );

  _bset( filename, 0x0, 13+pathlen );
  _bcopy( filename,path,pathlen );
  _bcopy((char *) filename+pathlen,PLUTEMP_FILE_NAME,sizeof(PLUTEMP_FILE_NAME));  

  if (( fileSpecBuf = _xalloc(sizeof(FileSpecType))) == NULL )
  {
    _xfree( filename );
    return  (MEM_ALLOC_ERR);
  }    
  

  _bset(fileSpecBuf, 0x0, sizeof(fileSpecBuf) );
  
  specLen = sizeof(FileSpecType);
    
  fileSpecBuf->recordLength = sizeof(PLUTEMP_RECORD);
  fileSpecBuf->pageSize = 1024;
  fileSpecBuf->indexCount = 1;             /* With one key     */
  fileSpecBuf->fileFlags = 0;              /* Default settings */
  fileSpecBuf->keySpecBuf.keyPos = 1;
  fileSpecBuf->keySpecBuf.keyLen = PLU_CODE_LEN;
  fileSpecBuf->keySpecBuf.keyFlag = 1;     /* Standard         */
  fileSpecBuf->keySpecBuf.keyType = 0;     /* String type      */

  retv = BTRV(B_CREATE, filePosBlock, (char *) fileSpecBuf, &specLen, filename, 0);
   
  _xfree(fileSpecBuf);  
  _xfree(filename);  

#ifdef DEBUG 
  printf("\n status creating plu btrieve file : %d",retv);
#endif  
    
  if(retv != NORMAL)
       return (BTRIEVE_CREATE_ERR);

  return NORMAL;
}

static int plutmp_open_file(char * path , unsigned int path_len )
{

 void far *filename;
 int retv = NORMAL;


 /* do the btrieve seek and form the frame parameter... */      
 if (( filename = _xalloc(13+path_len)) == NULL )
       return ( MEM_ALLOC_ERR );

 _bset(filename,0x0,13+path_len);
 _bcopy(filename,path,path_len);
 _bcopy((char *)filename+path_len,PLUTEMP_FILE_NAME,sizeof(PLUTEMP_FILE_NAME));                   
   
 posLen = sizeof(position);
 bufLen = sizeof(PLUTEMP_RECORD);
 /* open the standard btrieve file (PLUTEMP.IDX)... */            
 retv = BTRV (B_OPEN, filePosBlock,(char *) &tmpdata, &bufLen, filename, 0 );


#ifdef AUTO_CREATE   
   if ( retv == 12 ) /* status for file not found */
   {
     retv = plutmp_create( path, path_len );      

     if ( retv != NORMAL )
     {
        _xfree(filename);           
        return retv;
     }
        
     /* open the standard btrieve file (PLUITEMS.IDX)... */            
     retv = BTRV (B_OPEN, filePosBlock,(char *) &tmpdata, &bufLen, filename, 0 );        
   }        
#endif     

  _xfree(filename);           
   
  if (  retv  != NORMAL )
       retv = BTRIEVE_OPEN_ERR ;

 return retv;      
}


static int plutmp_close_file( void )
{
  return BTRV (B_CLOSE, filePosBlock,(char *) &tmpdata, &bufLen, NULL, 0 );    
}


int plutmp_search_and_put(void far *data, unsigned datalen,
                          void far *path, unsigned pathlen )
{                     
   char code[15];  
   int retv;
   PLUTEMP_INPUT far *putBuff;
  
   if (datalen != sizeof(PLUTEMP_INPUT))
     return (INV_SEND_PARAM);
   
   _bset(code,0x0,sizeof(code));
   _bcopy(code,data,sizeof(putBuff->plu_code));

   if ((retv = plutmp_open_file(path,pathlen)) != NORMAL )
       return retv;

   /* issue a btrieve seek (GET EQUAL) request... */

   retv = BTRV( B_GETEQ, filePosBlock, (char *) &tmpdata, &bufLen, code, 0 );

   putBuff = data;
   
   _bcopy(tmpdata.plu_code,putBuff->plu_code,PLU_CODE_LEN);
   _bcopy(tmpdata.plu_dept,putBuff->plu_dept,PLU_DEPT_LEN);
   _bcopy(tmpdata.plu_desc,putBuff->plu_desc,PLU_DESC_LEN);
   tmpdata.plu_pric.n  =  putBuff->plu_pric.n;
   
   if ( retv == NORMAL )
   {
     /* increment the counters and */
     tmpdata.quantity.n +=  putBuff->quantity.n;
     tmpdata.discount.n +=  putBuff->discount.n;
     tmpdata.amount.n   +=  putBuff->plu_pric.n;

     if ( putBuff->level.n  == 1 )
     {
       tmpdata.pl1_qty.n += putBuff->quantity.n;
       tmpdata.pl1_amt.n += putBuff->plu_pric.n;
     }
     else if ( putBuff->level.n == 2 )
     {
       tmpdata.pl2_qty.n += putBuff->quantity.n;
       tmpdata.pl2_amt.n += putBuff->plu_pric.n;
     }
     else if ( putBuff->level.n == 3 )
     {
       tmpdata.pl3_qty.n += putBuff->quantity.n;
       tmpdata.pl3_amt.n += putBuff->plu_pric.n;
     }
     else if ( putBuff->level.n == 4 )
     {
       tmpdata.pl4_qty.n += putBuff->quantity.n;
       tmpdata.pl4_amt.n += putBuff->plu_pric.n;
     }
     else if ( putBuff->level.n == 5 )
     {
       tmpdata.pl5_qty.n += putBuff->quantity.n;
       tmpdata.pl5_amt.n += putBuff->plu_pric.n;
     }
     else
     {
       tmpdata.pl0_qty.n += putBuff->quantity.n;
       tmpdata.pl0_amt.n += putBuff->plu_pric.n;
     }
                
     /* overwrite the whole record with the new one */
     retv = BTRV (B_UPDATE, filePosBlock, (char *) &tmpdata, &bufLen, code, 0);
     if (retv != NORMAL)
        retv = BTRIEVE_UPDATE_ERR;
   }    
   else
   {
   
     tmpdata.quantity.n =  putBuff->quantity.n;
     tmpdata.discount.n =  putBuff->discount.n;
     tmpdata.amount.n   =  putBuff->plu_pric.n;

     if ( putBuff->level.n  == 1 )
     {
       tmpdata.pl1_qty.n = putBuff->quantity.n;
       tmpdata.pl1_amt.n = putBuff->plu_pric.n;
     }
     else if ( putBuff->level.n == 2 )
     {
       tmpdata.pl2_qty.n = putBuff->quantity.n;
       tmpdata.pl2_amt.n = putBuff->plu_pric.n;
     }
     else if ( putBuff->level.n == 3 )
     {
       tmpdata.pl3_qty.n = putBuff->quantity.n;
       tmpdata.pl3_amt.n = putBuff->plu_pric.n;
     }
     else if ( putBuff->level.n == 4 )
     {
       tmpdata.pl4_qty.n = putBuff->quantity.n;
       tmpdata.pl4_amt.n = putBuff->plu_pric.n;
     }
     else if ( putBuff->level.n == 5 )
     {
       tmpdata.pl5_qty.n = putBuff->quantity.n;
       tmpdata.pl5_amt.n = putBuff->plu_pric.n;
     }
     else
     {
       tmpdata.pl0_qty.n += putBuff->quantity.n;
       tmpdata.pl0_amt.n += putBuff->plu_pric.n;
     }
      
     retv = BTRV(B_INSERT, filePosBlock, (char *) &tmpdata, &bufLen, code, 0);
     if (retv != NORMAL)
         retv = BTRIEVE_INSERT_ERR;
   }   
             
   plutmp_close_file();
        
   return (retv);
}
      
int plutmp_search_and_find(void far *receive_buffer, unsigned recvLen,
                          void far *data, unsigned sendLen,
                          void far *path, unsigned pathlen )
{

  int retv;
  unsigned char code[15];
  PLUTEMP_RECORD far *getBuff;
    
  if ( recvLen != sizeof( PLUTEMP_RECORD ) )
     return ( INV_RECV_PARAM );

  if ( sendLen != sizeof(getBuff->plu_code) )
     return ( INV_SEND_PARAM );

  _bset ( code,0x0, sizeof(code) );
  _bcopy( code, data, sendLen );

  if ( (retv = plutmp_open_file(path,pathlen)) != NORMAL )
        return retv;

  getBuff = receive_buffer;

  if ( memcmp(code,"++++++++++++++",sizeof(getBuff->plu_code)) == 0 )
  {
     if ( position == -1L )
       retv = BTRV (B_GETFIRST, filePosBlock, (char *) getBuff, &bufLen, code, 0 );
     else
     {
       _bcopy(getBuff,(char *)&position, sizeof(position) );
       retv =  BTRV(B_DIRECT, filePosBlock, (char *) getBuff, &bufLen, code, 0);
     }    
     
  }
  else
    retv = BTRV (B_GETGE, filePosBlock, (char *) getBuff, &bufLen, code, 0);

  if ( retv == NORMAL )
      retv = BTRV (B_GETNEXT, filePosBlock, (char *) &tmpdata, &bufLen, code, 0);                     
  else
      retv = CODE_NOT_FOUND; 

  if (retv ==  NORMAL)
     retv = BTRV (B_GETPOSI, filePosBlock, (char *) &position, &posLen, code, 0 );     

  plutmp_close_file();  
  
  return( retv );
}                          


int plutmp_search_and_delete(void far *data, unsigned datalen,
                             void far *path, unsigned pathlen )
{                     
   char code[15];  
   int retv;
  
   if (datalen != sizeof(tmpdata.plu_code))
       return (INV_SEND_PARAM);
   
   _bset(code,0x0,sizeof(code));
   _bcopy(code,data,sizeof(tmpdata.plu_code));
 
   if ((retv = plutmp_open_file(path,pathlen)) != NORMAL )
       return retv;

   
   /* issue a btrieve seek (GET EQUAL) request... */

   retv = BTRV (B_GETEQ, filePosBlock, (char *) &tmpdata, &bufLen, code, 0);
   
   if ( retv == NORMAL )
   {
     /* overwrite the whole record with the new one */
     retv = BTRV (B_DELETE, filePosBlock, (char *) &tmpdata, &bufLen, code, 0);
     
     if (retv != NORMAL)
         retv = BTRIEVE_DELETE_ERR;
   }

   plutmp_close_file();  
                
   return (retv);
}
      

/* Eof */
