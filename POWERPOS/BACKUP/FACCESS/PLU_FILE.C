/*
 * System........ PowerPos for Spectrum
 * Program I.D... plu_file.c
 * Author........ Rollie Castro Ibarra Jr.
 * Date Started.. Sept 2 1996
 * Modified...... Sept 6 1996
 * Dialect....... MicroSoft C
*/

#include <string.h>

#include "extend.h"
#include "faccess.h"
#include "plu_file.h"
#include "btrieve.h"

#pragma check_stack-
#pragma intrinsic (memcmp)

static char   order  = -1;
static char   open   = 0;
static char   filePosBlock[128];
static int    bufLen;
static int    posLen;
static long   position = -1L;

/* declare the PLU, PLU buffer, and PLU key structures... */
static PLURECORD pludata;

static int plu_open_file(char * path , unsigned int path_len );
/* static void plu_close_file( void ); */

typedef struct {
    int    recordLength;
    int    pageSize;
    int    indexCount;
    char   notUsed[4];
    int    fileFlags;
    char   reserve2[2];
    int    preAlloc;
    struct KeySpecType keySpecBuf[3];  /* We will use one key */
} FileSpecType2;

int plu_create(void far *path, unsigned pathlen)
{

  void far * filename;
  FileSpecType2 far * fileSpecBuf;    
  int  retv,specLen;
  
  /* determine where is the file... */
  if (( filename = _xalloc(13+pathlen)) == NULL)
      return(MEM_ALLOC_ERR);

  _bset( filename,0x0,13+pathlen);
  _bcopy(filename,path,pathlen);
  _bcopy((char *) filename+pathlen,PLU_IDX_FILE_NAME,sizeof(PLU_IDX_FILE_NAME));

  if (( fileSpecBuf = _xalloc(sizeof(FileSpecType2)) ) == NULL)
  {
      _xfree( filename ); 
      return (MEM_ALLOC_ERR);
  }    

  _bset(fileSpecBuf, 0x0, sizeof(fileSpecBuf) );
  
  specLen = sizeof(FileSpecType2);
    
  fileSpecBuf->recordLength = sizeof(PLURECORD);
  fileSpecBuf->pageSize = 1024;
  fileSpecBuf->indexCount = 3;                /* With two key     */
  fileSpecBuf->fileFlags = 0;                 /* Default settings */
  fileSpecBuf->keySpecBuf[0].keyPos = PLU_CODE_OFF;
  fileSpecBuf->keySpecBuf[0].keyLen = PLU_CODE_LEN;
  fileSpecBuf->keySpecBuf[0].keyFlag = 0;     /* Standard         */
  fileSpecBuf->keySpecBuf[0].keyType = 0;     /* String type      */
  fileSpecBuf->keySpecBuf[1].keyPos = PLU_ITEM_OFF;
  fileSpecBuf->keySpecBuf[1].keyLen = PLU_ITEM_LEN;
  fileSpecBuf->keySpecBuf[1].keyFlag = 3;     /* Dup & Modify     */
  fileSpecBuf->keySpecBuf[1].keyType = 0;     /* String type      */  
  fileSpecBuf->keySpecBuf[2].keyPos = PLU_DESC_OFF;
  fileSpecBuf->keySpecBuf[2].keyLen = PLU_DESC_LEN;
  fileSpecBuf->keySpecBuf[2].keyFlag = 3;     /* Dup & Modify     */
  fileSpecBuf->keySpecBuf[2].keyType = 0;     /* String type      */    

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

static int plu_open_file(char * path , unsigned int path_len )
{
 void far *filename;
 int retv = NORMAL;

 if (open == 0)
 {

 /* do the btrieve seek and form the frame parameter... */      
 if (( filename = _xalloc(13+path_len)) == NULL )
       return ( MEM_ALLOC_ERR );

   _bset(filename,0x0,13+path_len);
   _bcopy(filename,path,path_len);
   _bcopy((char *)filename+path_len,PLU_IDX_FILE_NAME,sizeof(PLU_IDX_FILE_NAME));                   
   
   posLen = sizeof(position);
   bufLen = sizeof(PLURECORD);
   /* open the standard btrieve file (PLUITEMS.IDX)... */            
   retv = BTRV (B_OPEN, filePosBlock,(char *) &pludata, &bufLen, filename, 0 );


#ifdef AUTO_CREATE   
   if ( retv == 12 ) /* status for file not found */
   {
     retv = plu_create( path, path_len );      

     if ( retv != NORMAL )
     {
        _xfree(filename);           
        return retv;
     }
        
     /* open the standard btrieve file (PLUITEMS.IDX)... */            
     retv = BTRV (B_OPEN, filePosBlock,(char *) &pludata, &bufLen, filename, 0 );        
   }        
#endif     

   _xfree(filename);           
   
   if (  retv  != NORMAL )
       retv = BTRIEVE_OPEN_ERR ;
   else
       open = 1;   
 }  
 return retv;      
}

int plu_close_file( void )
{
  open = 0;
  position = -1L;
  
  return BTRV (B_CLOSE, filePosBlock,(char *) &pludata, &bufLen, NULL, 0 );    
}

int plu_search_and_get(void far *receive_buffer, unsigned recvLen,
                       void far *data, unsigned sendLen,
                       void far *path, unsigned pathlen,
                       unsigned parameter) 
{
   int retv;
   unsigned char search_code[21];
   
   PLURECORD far *plu;
   
   if ( recvLen != sizeof(PLURECORD) )
      return (INV_RECV_PARAM );
          
   if ( sendLen < sizeof(plu->plu_code) )
      return (INV_SEND_PARAM );
   
   plu = receive_buffer;
   _bset ( search_code, 0x0, sizeof(search_code) );

   /* get the PLU code to search... */
   /* data is in ASCII */
   _bcopy(search_code,data,sendLen);

   retv = plu_open_file(path,pathlen);

   if ( retv != NORMAL )
      return retv;
             
   /* issue a btrieve seek (GET EQUAL) request... */
   retv = BTRV (B_GETEQ, filePosBlock, (char *) plu, &bufLen, search_code, parameter );

   if ( retv == NORMAL )
   {
        if ( plu->deleted == '*' )
          retv = CODE_NOT_FOUND ;
#ifdef DEBUG
        else  
          printf("\n was found on bar code index ");         
#endif          
   }       
   else if ( retv == 4 )  /* try to search the item code for results */   
   {
      _bset (search_code, 0x0, sizeof(search_code));
      _bcopy(search_code,(char *) data+2, sizeof(plu->item_code));     
      
      retv = BTRV (B_GETEQ, filePosBlock, (char *) plu, &bufLen, search_code, 1 );

      if ( retv == NORMAL )
      {
           if ( plu->deleted == '*' )
              retv = CODE_NOT_FOUND ;
#ifdef DEBUG
           else  
              printf("\n was found on item code index ");         
#endif                        
      }
      else if ( retv == 4 && sendLen == sizeof(plu->item_desc ) )
      {
         _bset (search_code, 0x0, sizeof(search_code));
         _bcopy(search_code,data, sizeof(plu->item_desc));     
         
         retv = BTRV (B_GETGE, filePosBlock, (char *) plu, &bufLen, search_code, 2 ); 
      }                                  
   }       

   if ( retv != NORMAL )
     retv = CODE_NOT_FOUND;
   else
   {
     posLen = sizeof(position);
     BTRV (B_GETPOSI, filePosBlock, (char *) &position, &posLen, search_code, parameter );
   }  

       
   return (retv);
}


int plu_search_and_put(void far *data, unsigned datalen,
                       void far *path, unsigned pathlen )
{                     
   char code[15];  
   int retv;
   
   PLURECORD far *plu;
  
   if (datalen != sizeof(PLURECORD) )
     return (INV_SEND_PARAM);

   /* yes my data is the data sent from clipper */       
   plu = data;
   
   _bset(code,0x0,sizeof(code));
   _bcopy(code,data,sizeof(pludata.plu_code));

   retv = plu_open_file(path,pathlen);

   if ( retv != NORMAL )
      return retv;

   /* issue a btrieve seek (GET EQUAL) request... */
   retv = BTRV (B_GETEQ, filePosBlock, (char *) &pludata, &bufLen, code, 0);

   if ( retv == NORMAL )
   {
      plu->deleted = ' ' ;
      
      retv = BTRV (B_UPDATE, filePosBlock, (char *) plu, &bufLen, code, 0);
      if ( retv !=  NORMAL )
         retv = BTRIEVE_UPDATE_ERR;
   }
   else
   {
      plu->deleted = ' ';
      
      retv = BTRV(B_INSERT, filePosBlock, (char *) plu, &bufLen, code, 0);

      if (retv != NORMAL)
          retv = BTRIEVE_INSERT_ERR;
   }

         
   return (retv);       
}

int plu_search_and_delete(void far *data, unsigned datalen,                          
                          void far *path, unsigned pathlen )
{
    char code[15];
    int retv;

    if ( datalen != sizeof(pludata.plu_code) )
       return ( INV_SEND_PARAM );
    
    /* initialize local variables with zeroes... */

    _bset (code, 0x0, sizeof(code));

    /* get the PLU code to search... */

    _bcopy(code,data,sizeof(pludata.plu_code));

    retv = plu_open_file(path,pathlen);

    if ( retv != NORMAL )
        return retv;
    
    /* issue a btrieve seek (GET EQUAL) request... */
    retv = BTRV (B_GETEQ, filePosBlock, (char *) &pludata, &bufLen, code, 0);
        
    if (retv == NORMAL)
    {
       pludata.deleted = '*';
       retv = BTRV (B_UPDATE, filePosBlock, (char *) &pludata, &bufLen, code, 0);
       if (retv != NORMAL)
             retv = BTRIEVE_UPDATE_ERR;          
    }
    else
     retv = CODE_NOT_FOUND;
    
    
  return(retv);
}


int plu_get_first(void far *receive_buffer, unsigned recvLen,
                  void far *path, unsigned pathlen,
                  unsigned parameter) 
{
   int retv;
   unsigned char code[21];

   PLURECORD far *plu;
   
   if ( recvLen != sizeof(PLURECORD) )
      return (INV_RECV_PARAM );
             
   plu = receive_buffer;
   _bset ( code, 0x0, sizeof(code) );

   if ( ( retv = plu_open_file (path,pathlen)) != NORMAL )
      return retv;

   /* issue a btrieve seek (GET FIRST) request... */
   retv = BTRV (B_GETFIRST, filePosBlock, (char *) plu, &bufLen, code, parameter );

   while ( retv == NORMAL  &&  plu->deleted == '*' )   
   {
      retv = BTRV (B_GETNEXT, filePosBlock, (char *) plu, &bufLen, code, parameter );           
   }

   if ( retv != NORMAL )
     retv = BTRIEVE_ENDOFFILE;
   else
   {
     posLen = sizeof(position);
     BTRV (B_GETPOSI, filePosBlock, (char *) &position, &posLen, code, parameter );           
   }  

       
   return (retv);
}


int plu_get_next(void far *receive_buffer, unsigned recvLen,
                 void far *path, unsigned pathlen,
                 unsigned parameter) 
{
   int retv;
   char code[21];
   PLURECORD far *plu;
   
   if ( recvLen != sizeof(PLURECORD))
      return (INV_SEND_PARAM );      
             
   plu = receive_buffer;

   retv = plu_open_file (path,pathlen);
   
   if ( retv != NORMAL )
      return retv;

   /* check first if btrieve is in valid positioning */
   if ( position == -1L)
   {
     /* invalid positioning get first record */ 
     BTRV (B_GETFIRST, filePosBlock, (char *) plu, &bufLen, code, parameter );
   }
   else
   {
     _bcopy(plu,(char *)&position,sizeof(position));
     retv = BTRV(B_DIRECT, filePosBlock, (char *) plu, &bufLen, code, parameter);
   }     

   /* issue a btrieve seek (GET NEXT) request... */
   retv = BTRV (B_GETNEXT, filePosBlock, (char *) plu, &bufLen, code, parameter );

   while ( retv == NORMAL  &&  plu->deleted == '*' )   
   {
      retv = BTRV (B_GETNEXT, filePosBlock, (char *) plu, &bufLen, code, parameter );           
   }        

   if (retv != NORMAL)
   {
       retv =  BTRIEVE_ENDOFFILE;
   }    
   else
   {
     retv = BTRV (B_GETPOSI, filePosBlock, (char *) &position, &posLen, code, parameter );           
   }         

       
   return (retv);
}


int plu_get_previous(void far *receive_buffer, unsigned recvLen,
                     void far *path, unsigned pathlen,
                    unsigned parameter) 
{
   int retv;
   unsigned char code[21];
   PLURECORD far *plu;
   
   if ( recvLen != sizeof(PLURECORD))
      return (INV_SEND_PARAM );      
             
   plu = receive_buffer;

   retv = plu_open_file (path,pathlen);
   
   if ( retv != NORMAL )
      return retv;

   /* check first if btrieve is in valid positioning */
   if (position == -1L)
   {
     /* invalid positioning get first record */ 
     BTRV (B_GETFIRST, filePosBlock, (char *) plu, &bufLen, code, parameter );
   }
   else
   {
     _bcopy(plu,(char *)&position, sizeof(position) );
     retv =  BTRV(B_DIRECT, filePosBlock, (char *) plu, &bufLen, code, parameter);
   }     
      
   /* issue a btrieve seek (GET NEXT) request... */
   retv = BTRV (B_GETPREV, filePosBlock, (char *) plu, &bufLen, code, parameter );

   while ( retv == NORMAL  &&  plu->deleted == '*' )   
   {
      retv = BTRV (B_GETPREV, filePosBlock, (char *) plu, &bufLen, code, parameter );           
   }        

   if (retv != NORMAL)
   {
       retv =  BTRIEVE_BEGOFFILE;
   }    
   else
   {
       retv = BTRV (B_GETPOSI, filePosBlock, (char *) &position, &posLen, code, parameter );           
   }                

       
   return (retv);
}


int plu_get_last(void far *receive_buffer, unsigned recvLen,
                        void far *path, unsigned pathlen,
                        unsigned parameter) 
{
   int retv;
   unsigned char code[15];

   PLURECORD far *plu;
   
   if ( recvLen != sizeof(PLURECORD) )
      return (INV_RECV_PARAM );
             
   plu = receive_buffer;
   _bset ( code, 0x0, sizeof(code) );

   retv = plu_open_file (path,pathlen);
   
   if ( retv != NORMAL )
      return retv;


   /* issue a btrieve seek (GET FIRST) request... */
   retv = BTRV (B_GETLAST, filePosBlock, (char *) plu, &bufLen, code, parameter );

   while ( retv == NORMAL  &&  plu->deleted == '*' )   
   {
      retv = BTRV (B_GETPREV, filePosBlock, (char *) plu, &bufLen, code, parameter );           
   }

   if ( retv != NORMAL )
     retv = BTRIEVE_BEGOFFILE;
   else
   {   
     retv = BTRV (B_GETPOSI, filePosBlock, (char *) &position, &posLen, code, parameter );                
   }
   
       
   return (retv);
}


/* EOF */
