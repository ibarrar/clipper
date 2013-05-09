#include <string.h>
#include "extend.h"
#include "faccess.h"
#include "plucount.h"
#include "plu_file.h"
#include "btrieve.h"

#pragma check_stack-

static char pctropen = 0;
static long pctr_pos = -1L;
static char filePosBlock[128];

static int plucount_create(void far *path, unsigned pathlen);
static int plucount_open_file(char * path , unsigned int path_len );
       int plucount_close_file( void );

static int plucount_create(void far *path, unsigned pathlen)
{

  void far * filename;
  FileSpecType far * fileSpecBuf;    
  int  retv,specLen;
  
  /* determine where is the file... */
  if (( filename = _xalloc(13+pathlen)) == NULL)
      return(MEM_ALLOC_ERR);

  _bset( filename,0x0,13+pathlen);
  _bcopy(filename,path,pathlen);
  _bcopy((char *) filename+pathlen,PLU_CTR_FILE_NAME,sizeof(PLU_CTR_FILE_NAME));

  if (( fileSpecBuf = _xalloc(sizeof(FileSpecType)) ) == NULL)
  {
      _xfree( filename ); 
      return (MEM_ALLOC_ERR);
  }    

  _bset(fileSpecBuf, 0x0, sizeof(fileSpecBuf) );
  
  specLen = sizeof(FileSpecType);
    
  fileSpecBuf->recordLength = sizeof(PLUCOUNTER);
  fileSpecBuf->pageSize = 1024;
  fileSpecBuf->indexCount = 1;                /* With two key     */
  fileSpecBuf->fileFlags = 0;                 /* Default settings */
  fileSpecBuf->keySpecBuf.keyPos = PLU_CODE_OFF;
  fileSpecBuf->keySpecBuf.keyLen = PLU_CODE_LEN;
  fileSpecBuf->keySpecBuf.keyFlag = 0;        /* Standard         */
  fileSpecBuf->keySpecBuf.keyType = 0;        /* String type      */

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

static int plucount_open_file(char * path , unsigned int path_len )
{
 void far *filename;
 int retv = NORMAL;
 int bufLen;
 PLUCOUNTER plucounter;

 if (pctropen == 0 )
 {

 /* do the btrieve seek and form the frame parameter... */      
 if (( filename = _xalloc(13+path_len)) == NULL )
       return ( MEM_ALLOC_ERR );

   _bset(filename,0x0,13+path_len);
   _bcopy(filename,path,path_len);
   _bcopy((char *)filename+path_len,PLU_CTR_FILE_NAME,sizeof(PLU_CTR_FILE_NAME));
   
   bufLen = sizeof(PLUCOUNTER);
   
   /* open the standard btrieve file (PLUITEMS.CTR)... */
   retv = BTRV (B_OPEN, filePosBlock,(char *) &plucounter, &bufLen, filename, 0 );

#ifdef AUTO_CREATE   
   if ( retv == 12 ) /* status for file not found */
   {
     retv = plucount_create( path, path_len );

     if ( retv != NORMAL )
     {
        _xfree(filename);           
        return retv;
     }
        
     /* open the standard btrieve file (PLUITEMS.CTR)... */            
     retv = BTRV (B_OPEN, filePosBlock,(char *) &plucounter, &bufLen, filename, 0 );
   }        
#endif     

   _xfree(filename);
   
   if (  retv  != NORMAL )
       retv = BTRIEVE_OPEN_ERR ;
   else
       pctropen = 1;   
 }  
 
 return retv;      
}

int plucount_close_file( void )
{

  PLUCOUNTER plucounter;
  int bufLen = sizeof(PLUCOUNTER);
  
  pctropen = 0;
  pctr_pos = -1L;
  
  return BTRV (B_CLOSE, filePosBlock,(char *) &plucounter, &bufLen, NULL, 0 );
}


int plucount_search_and_get(void far *receive_buffer, unsigned recvlen,
                            void far *data, unsigned sendlen, 
                            void far *path, unsigned pathlen, int parameter )
{

   PLU_CTR_OUT far *getBuf;      
   PLUCOUNTER plucounter;
   PLURECORD plu;
   char code[15];
   int retv;
   int buflen;
   
   if ( recvlen != ( sizeof(PLU_CTR_OUT) ) )
      return (INV_RECV_PARAM);

   if ( sendlen != (sizeof(getBuf->plu_code)) )   
      return (INV_SEND_PARAM);
      
   retv = plucount_open_file(path,pathlen);
   
   if ( retv != NORMAL )
      return retv;
   
   getBuf = receive_buffer;
   _bset( code,0x0,sizeof(code));   
   _bcopy( code,data,sizeof(getBuf->plu_code) );
        
   if ( memcmp(code,"+++++++++++++++",sizeof(getBuf->plu_code)) == 0 ) 
   {
     buflen = sizeof(PLUCOUNTER);    
     if ( pctr_pos == -1L )
     {
        retv = BTRV(B_GETFIRST, filePosBlock,(char *) &plucounter, &buflen, code, 0);
     }   
     else
     {  
        _bcopy(&plucounter, (char*) &pctr_pos, sizeof(pctr_pos) );
        retv = BTRV(B_DIRECT, filePosBlock, (char *) &plucounter, &buflen, code, 0);
        retv = BTRV(B_GETNEXT, filePosBlock, (char *) &plucounter, &buflen, code, 0);
     }

     if ( parameter )
     {
           while ( retv == NORMAL && plucounter.plu_qty.n == 0 &&
                   plucounter.plu_amt.n == 0 &&
                   plucounter.plu_dsc.n == 0 &&
                   plucounter.plu_cst.n == 0 )
           {  
             retv = BTRV(B_GETNEXT, filePosBlock, (char *) &plucounter, &buflen, code, 0);     
           }  
                   
     }   
   }
   else if ( memcmp(code,"---------------",sizeof(getBuf->plu_code)) == 0 ) 
   {
     buflen = sizeof(PLUCOUNTER);    
     retv = BTRV(B_GETFIRST, filePosBlock,(char *) &plucounter, &buflen, code, 0);
     if ( parameter )
     {
           while ( retv == NORMAL && plucounter.plu_qty.n == 0 &&
                   plucounter.plu_amt.n == 0 &&
                   plucounter.plu_dsc.n == 0 &&
                   plucounter.plu_cst.n == 0 )
           {  
             retv = BTRV(B_GETNEXT, filePosBlock, (char *) &plucounter, &buflen, code, 0);     
           }  
                   
     }   
   }
   else
   {    
     buflen = sizeof(PLUCOUNTER);
     retv = BTRV( B_GETEQ, filePosBlock, (char *) &plucounter, &buflen, code, 0 );
   }  

   if (retv == NORMAL)   
   {
      retv = plu_search_and_get(&plu, sizeof(PLURECORD), code, sizeof(getBuf->plu_code), path, pathlen, 0);   

      if ( retv != NORMAL )
      {
          plu.stock.n = 0;
          _bset(plu.item_code,' ',sizeof(plu.item_code));
          _bset(plu.item_desc,' ',sizeof(plu.item_desc));
          retv = NORMAL;
      }    
   }   
   _bcopy(getBuf->plu_code,plucounter.plu_code,sizeof(getBuf->plu_code));
   _bcopy(getBuf->item_code,plu.item_code,sizeof(getBuf->item_code));
   _bcopy(getBuf->item_desc,plu.item_desc,sizeof(getBuf->item_desc));
   getBuf->stock.n = plu.stock.n;
   getBuf->plu_qty.n = plucounter.plu_qty.n;
   getBuf->plu_amt.n = plucounter.plu_amt.n;
   getBuf->plu_cst.n = plucounter.plu_cst.n;
   getBuf->plu_dsc.n = plucounter.plu_dsc.n;
   getBuf->pl0_qty.n = plucounter.pl0_qty.n;
   getBuf->pl0_amt.n = plucounter.pl0_amt.n;
   getBuf->pl0_cst.n = plucounter.pl0_cst.n;
   getBuf->pl0_dsc.n = plucounter.pl0_dsc.n;
   getBuf->pl1_qty.n = plucounter.pl1_qty.n;
   getBuf->pl1_amt.n = plucounter.pl1_amt.n;
   getBuf->pl1_cst.n = plucounter.pl1_cst.n;
   getBuf->pl1_dsc.n = plucounter.pl1_dsc.n;
   getBuf->pl2_qty.n = plucounter.pl2_qty.n;
   getBuf->pl2_amt.n = plucounter.pl2_amt.n;
   getBuf->pl2_cst.n = plucounter.pl2_cst.n;
   getBuf->pl2_dsc.n = plucounter.pl2_dsc.n;
   getBuf->pl3_qty.n = plucounter.pl3_qty.n;
   getBuf->pl3_amt.n = plucounter.pl3_amt.n;
   getBuf->pl3_cst.n = plucounter.pl3_cst.n;
   getBuf->pl3_dsc.n = plucounter.pl3_dsc.n;
   getBuf->pl4_qty.n = plucounter.pl4_qty.n;
   getBuf->pl4_amt.n = plucounter.pl4_amt.n;
   getBuf->pl4_cst.n = plucounter.pl4_cst.n;
   getBuf->pl4_dsc.n = plucounter.pl4_dsc.n;
   getBuf->pl5_qty.n = plucounter.pl5_qty.n;
   getBuf->pl5_amt.n = plucounter.pl5_amt.n;
   getBuf->pl5_cst.n = plucounter.pl5_cst.n;
   getBuf->pl5_dsc.n = plucounter.pl5_dsc.n;            

   if ( retv != NORMAL )
     _bset(getBuf,' ',recvlen);
   else 
   {
      buflen = sizeof(pctr_pos);
      retv = BTRV (B_GETPOSI, filePosBlock, (char *) &pctr_pos, &buflen, code, 0 );  
   }
   return(retv);
}


int plucount_search_and_put(void far *data, unsigned datalen,
                            void far *path, unsigned pathlen, int par)
{

   PLU_CTR_IN far * putkey;    
   PLUCOUNTER plucounter;
   PLURECORD  plu;
   int retv = BTRIEVE_OPEN_ERR;
   int bufLen;
   char code[15];
   int found = 1;
   
   if ( datalen != sizeof(PLU_CTR_IN) ) /* amount + quantity and code */
      return (INV_SEND_PARAM);

   retv = plucount_open_file (path,pathlen);
   
   if ( retv != NORMAL )
      return retv;
               
   putkey = data;
   
   _bcopy(code,0x0,sizeof(code));
   _bcopy(code,data,sizeof(putkey->plu_code));
   retv = plu_search_and_get(&plu, sizeof(PLURECORD), code, sizeof(putkey->plu_code), path, pathlen, 0);

   if (retv != NORMAL)
     plu.unit_cost.n = 0;

   bufLen = sizeof(PLUCOUNTER);
   retv = BTRV (B_GETEQ, filePosBlock, (char *) &plucounter, &bufLen, code, 0);

   if ( retv == CODE_NOT_FOUND )
   {    
     _bcopy(plucounter.plu_code,data,sizeof(plucounter.plu_code));
     plucounter.plu_qty.n = plucounter.pl0_qty.n = plucounter.pl1_qty.n = plucounter.pl2_qty.n = plucounter.pl3_qty.n = plucounter.pl4_qty.n = plucounter.pl5_qty.n = 0;
     plucounter.plu_amt.n = plucounter.pl0_amt.n = plucounter.pl1_amt.n = plucounter.pl2_amt.n = plucounter.pl3_amt.n = plucounter.pl4_amt.n = plucounter.pl5_amt.n = 0;
     plucounter.plu_cst.n = plucounter.pl0_cst.n = plucounter.pl1_cst.n = plucounter.pl2_cst.n = plucounter.pl3_cst.n = plucounter.pl4_cst.n = plucounter.pl5_cst.n = 0;
     plucounter.plu_dsc.n = plucounter.pl0_dsc.n = plucounter.pl1_dsc.n = plucounter.pl2_dsc.n = plucounter.pl3_dsc.n = plucounter.pl4_dsc.n = plucounter.pl5_dsc.n = 0;     
     _bcopy(code,0x0,sizeof(code));
     _bcopy(code,data,sizeof(putkey->plu_code));
     retv = NORMAL;
     found = 0;
   }        
            
   if ( retv == NORMAL )
   {  
      /* if par is set to 1 clear all daily counter */
      if ( par )
      {
        plucounter.plu_qty.n = plucounter.pl0_qty.n = plucounter.pl1_qty.n = plucounter.pl2_qty.n = plucounter.pl3_qty.n = plucounter.pl4_qty.n = plucounter.pl5_qty.n = 0;
        plucounter.plu_amt.n = plucounter.pl0_amt.n = plucounter.pl1_amt.n = plucounter.pl2_amt.n = plucounter.pl3_amt.n = plucounter.pl4_amt.n = plucounter.pl5_amt.n = 0;
        plucounter.plu_cst.n = plucounter.pl0_cst.n = plucounter.pl1_cst.n = plucounter.pl2_cst.n = plucounter.pl3_cst.n = plucounter.pl4_cst.n = plucounter.pl5_cst.n = 0;
        plucounter.plu_dsc.n = plucounter.pl0_dsc.n = plucounter.pl1_dsc.n = plucounter.pl2_dsc.n = plucounter.pl3_dsc.n = plucounter.pl4_dsc.n = plucounter.pl5_dsc.n = 0;           
      }  
      else
      {
        plucounter.plu_qty.n += putkey->quantity.n;
        plucounter.plu_amt.n += putkey->amount.n;
        plucounter.plu_dsc.n += putkey->discount.n;
        plucounter.plu_cst.n += (putkey->quantity.n * plu.unit_cost.n);

        if (putkey->level.n == 1)
        {
                 plucounter.pl1_qty.n += putkey->quantity.n;
                 plucounter.pl1_amt.n += putkey->amount.n;
                 plucounter.pl1_dsc.n += putkey->discount.n;
                 plucounter.pl1_cst.n += (putkey->quantity.n * plu.unit_cost.n);
        }else if (putkey->level.n == 2)
        {
                 plucounter.pl2_qty.n += putkey->quantity.n;
                 plucounter.pl2_amt.n += putkey->amount.n;
                 plucounter.pl2_dsc.n += putkey->discount.n;
                 plucounter.pl2_cst.n += (putkey->quantity.n * plu.unit_cost.n);
        }else if (putkey->level.n == 3)
        { 
                 plucounter.pl3_qty.n += putkey->quantity.n;
                 plucounter.pl3_amt.n += putkey->amount.n;
                 plucounter.pl3_dsc.n += putkey->discount.n;
                 plucounter.pl3_cst.n += (putkey->quantity.n * plu.unit_cost.n);

        }else if (putkey->level.n == 4)
        {
                 plucounter.pl4_qty.n += putkey->quantity.n;
                 plucounter.pl4_amt.n += putkey->amount.n;
                 plucounter.pl4_dsc.n += putkey->discount.n;
                 plucounter.pl4_cst.n += (putkey->quantity.n * plu.unit_cost.n);
        }else if (putkey->level.n == 5) 
        {
                 plucounter.pl5_qty.n += putkey->quantity.n;
                 plucounter.pl5_amt.n += putkey->amount.n;
                 plucounter.pl5_dsc.n += putkey->discount.n;
                 plucounter.pl5_cst.n += (putkey->quantity.n * plu.unit_cost.n);
        }else
        {
                 plucounter.pl0_qty.n += putkey->quantity.n;
                 plucounter.pl0_amt.n += putkey->amount.n;
                 plucounter.pl0_dsc.n += putkey->discount.n;
                 plucounter.pl0_cst.n += (putkey->quantity.n * plu.unit_cost.n);
        }        
      } 

      if ( found )
         retv = BTRV( B_UPDATE, filePosBlock, (char *) &plucounter, &bufLen, code, 0 );
      else
         retv = BTRV( B_INSERT, filePosBlock, (char *) &plucounter, &bufLen, code, 0 );      
     
      if ( retv )
         retv = BTRIEVE_UPDATE_ERR; 
   }   
         
   return(retv);
}

