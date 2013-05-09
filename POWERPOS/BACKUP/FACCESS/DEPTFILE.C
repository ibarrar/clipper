/*
 * System........ PowerPos for Spectrum
 * Program I.D... deptfile.c
 * Author........ Rollie C. Ibarra Jr.
 * Date Started.. Sept 6 1996
 * Modified...... Sept 6 1996
 * Dialect....... MicroSoft C
*/
#include <string.h>

#include "extend.h"
#include "faccess.h"
#include "deptfile.h"
#include "btrieve.h"

#pragma check_stack-
#pragma intrinsic (memcmp)

static char filePosBlock[128];
static int  bufLen;
static int  posLen;
static long position = -1L;

/* declare the DEPT buffer, and DEPT key structures... */
static DEPT_RECORD deptdata;

static void dept_close_file( void );
static int dept_open_file(char * path, unsigned int path_len );


int dept_create(void far *path, unsigned pathlen)
{
  void far * filename;
  FileSpecType far * fileSpecBuf;    
  int  retv,specLen;
    
  /* determine where is the file... */
  if (( filename = _xalloc(13+pathlen)) == NULL)
      return(MEM_ALLOC_ERR);

  _bset( filename,0x0,13+pathlen);
  _bcopy(filename,path,pathlen);
  _bcopy((char *) filename+pathlen,DEPT_IDX_FILE_NAME,sizeof(DEPT_IDX_FILE_NAME));

  if (( fileSpecBuf = _xalloc(sizeof(FileSpecType)) ) == NULL)
  {
      _xfree( filename ); 
      return (MEM_ALLOC_ERR);
  }    

  _bset(fileSpecBuf, 0x0, sizeof(fileSpecBuf) );
  
  specLen = sizeof(FileSpecType);

  fileSpecBuf->recordLength = sizeof(DEPT_RECORD);
  fileSpecBuf->pageSize = 1024;
  fileSpecBuf->indexCount = 1;                /* With one key     */
  fileSpecBuf->fileFlags = 0;                  /* Default settings */
  fileSpecBuf->keySpecBuf.keyPos =  1;
  fileSpecBuf->keySpecBuf.keyLen =  4;
  fileSpecBuf->keySpecBuf.keyFlag = 0;         /* Standard         */
  fileSpecBuf->keySpecBuf.keyType = 0;         /* String type      */

  retv = BTRV(B_CREATE, filePosBlock, (char *) fileSpecBuf, &specLen, filename, 0);

  _xfree(fileSpecBuf);
  _xfree(filename);

#ifdef DEBUG 
  printf("\n status creating dept btrieve file : %d",retv);
#endif    
  
  if(retv != NORMAL)
      return (BTRIEVE_CREATE_ERR);

  return NORMAL;
}

static int dept_open_file(char * path, unsigned int path_len )
{
  void far *filename;
  int retv = NORMAL;

  /* do the btrieve seek and form the frame parameter... */      
  if (( filename = _xalloc(13+path_len)) == NULL )
       return ( MEM_ALLOC_ERR );

   _bset(filename,0x0,13+path_len);
   _bcopy(filename,path,path_len);
   _bcopy((char *)filename+path_len,DEPT_IDX_FILE_NAME,sizeof(DEPT_IDX_FILE_NAME));
   
   posLen = sizeof(position);
   bufLen = sizeof(DEPT_RECORD);
   /* open the standard btrieve file (DEPTITEMS.IDX)... */            
   retv = BTRV (B_OPEN, filePosBlock,(char *) &deptdata, &bufLen, filename, 0 );

#ifdef AUTO_CREATE   
   if ( retv == 12 ) /* status for file not found */
   {
     retv = dept_create( path, path_len );      

     if ( retv != NORMAL )
     {
        _xfree(filename);           
        return retv;
     }
        
     /* open the standard btrieve file (DEPTITEMS.IDX)... */            
     retv = BTRV (B_OPEN, filePosBlock,(char * ) &deptdata, &bufLen, filename, 0 );        
   }        
#endif     

   _xfree(filename);           
   
   if (  retv  != NORMAL )
       retv = BTRIEVE_OPEN_ERR ;

 return retv;      
}

static void dept_close_file( void )
{
   BTRV (B_CLOSE, filePosBlock,(char *) &deptdata, &bufLen, NULL, 0 );    
}  
  
   

int dept_search_and_get(void far *receive_buffer, unsigned recvLen,
                        void far *data, unsigned sendLen,
                        void far *path, unsigned pathlen )
{
   int retv;
   unsigned char code[5];
   DEPT_RECORD far *dept;
   
   if ( recvLen != sizeof(DEPT_RECORD) )
      return (INV_RECV_PARAM );

   if ( sendLen != sizeof(dept->dp_code) )
      return (INV_SEND_PARAM );

   dept = receive_buffer;
   _bset (code, 0x0, sizeof(code));   

   /* get the DEPT code to search... */
   /* data is in ASCII */
   _bcopy(code,data,sizeof(dept->dp_code));

   if ((retv = dept_open_file(path,pathlen)) != NORMAL )
       return retv;

   /* issue a btrieve seek (GET EQUAL) request... */
   retv = BTRV (B_GETEQ, filePosBlock, (char *)dept, &bufLen, code, 0 );       

   if ( retv == NORMAL )
   {
     if ( dept->deleted == '*' )
         retv = CODE_NOT_FOUND;
   }

   if ( retv != NORMAL )
     retv = CODE_NOT_FOUND;
   else
   {
     posLen = sizeof(position);
     BTRV (B_GETPOSI, filePosBlock, (char *) &position, &posLen, code, 0 );
   }  

   dept_close_file();      
   
  return (retv);
}


int dept_search_and_put(void far *data, unsigned datalen,
                        void far *path, unsigned pathlen )
{
   char code[5];  
   int retv;
   
   DEPT_RECORD far *dept;
  
   if (datalen != sizeof(DEPT_RECORD))
     return (INV_SEND_PARAM);

   /* yes my data is the data sent from clipper */  

   dept = data;
   
   _bset(code,0x0,sizeof(code));
   _bcopy(code,data,sizeof(dept->dp_code));


   if ( ( retv = dept_open_file(path,pathlen)) != NORMAL )
      return retv;

   /* issue a btrieve seek (GET EQUAL) request... */
   retv = BTRV (B_GETEQ, filePosBlock, (char *) &deptdata, &bufLen, code, 0);

   if ( retv == NORMAL )
   {
     dept->deleted    = ' ';
     dept->quantity.n = deptdata.quantity.n;
     dept->amount.n   = deptdata.amount.n;
     dept->discount.n = deptdata.discount.n;
     dept->ptd_qty.n  = deptdata.ptd_qty.n;
     dept->ptd_amt.n  = deptdata.ptd_amt.n;
     dept->ptd_dsc.n  = deptdata.ptd_dsc.n;

      retv = BTRV (B_UPDATE, filePosBlock, (char *) dept, &bufLen, code, 0);
      if ( retv !=  NORMAL )
         retv = BTRIEVE_UPDATE_ERR;
   }
   else
   {
      dept->deleted = ' ';

      retv = BTRV(B_INSERT, filePosBlock, (char *) dept, &bufLen, code, 0);

      if (retv != NORMAL)
          retv = BTRIEVE_INSERT_ERR;
   }

   dept_close_file();
         
   return (retv);                              

}

int dept_search_and_delete(void far *data, unsigned datalen,                          
                           void far *path, unsigned pathlen )
{
    char code[5];
    int retv;


    if ( datalen != sizeof(deptdata.dp_code) )
       return ( INV_SEND_PARAM );
    
    /* initialize local variables with zeroes... */

    _bset (code, 0x0, sizeof(code));       

    /* get the DEPT code to search... */

    _bcopy(code,data,sizeof(deptdata.dp_code));

    if ( ( retv = dept_open_file(path,pathlen)) != NORMAL )
      return retv;

    /* issue a btrieve seek (GET EQUAL) request... */

    retv = BTRV (B_GETEQ, filePosBlock, (char *) &deptdata, &bufLen, code, 0);
        
    if (retv == NORMAL)
    {

       if (( deptdata.quantity.n + deptdata.amount.n + deptdata.discount.n +
             deptdata.ptd_qty.n  + deptdata.ptd_amt.n + deptdata.ptd_dsc.n ) != 0 )
       {
         deptdata.deleted = '*';
         retv = BTRV (B_UPDATE, filePosBlock, (char *) &deptdata, &bufLen, code, 0);
         if (retv != NORMAL)
            retv = BTRIEVE_UPDATE_ERR;
       }        
       else
       {
         retv = BTRV (B_DELETE, filePosBlock, (char *) &deptdata, &bufLen, code, 0);
         if (retv != NORMAL )
             retv = BTRIEVE_DELETE_ERR;
       }     
         
    }
    else
     retv = CODE_NOT_FOUND;

    dept_close_file();    
       
  return(retv);
}


int dept_get_first(void far *receive_buffer, unsigned recvLen,
                   void far *path, unsigned pathlen )
{
  int retv;
  unsigned char code[5];

  DEPT_RECORD far *dept;

  if ( recvLen != sizeof(DEPT_RECORD) )
    return (INV_RECV_PARAM);

  dept = receive_buffer;
  _bset ( code, 0x0, sizeof(code) );

  if (( retv = dept_open_file (path,pathlen) ) != NORMAL )
     return retv;

  /* issue a btrieve seek (GET FIRST) request... */
  retv = BTRV (B_GETFIRST, filePosBlock, (char *) dept, &bufLen, code, 0 );

  while ( retv == NORMAL  &&  dept->deleted == '*' )
  {
     retv = BTRV (B_GETNEXT, filePosBlock, (char *) dept, &bufLen, code, 0 );           
  }
     
  if ( retv != NORMAL )
     retv = BTRIEVE_ENDOFFILE;
  else
  {
     posLen = sizeof(position);
     BTRV (B_GETPOSI, filePosBlock, (char *) &position, &posLen, code, 0 );           
  }  

  dept_close_file();
       
  return (retv);
}


int dept_get_next(void far *receive_buffer, unsigned recvLen,
                 void far *path, unsigned pathlen )
{
   int retv;
   char code[5];
   DEPT_RECORD far *dept;
   
   if ( recvLen != sizeof(DEPT_RECORD))
      return (INV_SEND_PARAM );      
             
   dept = receive_buffer;

   if ( (retv = dept_open_file (path,pathlen) ) != NORMAL )
      return retv;

   /* check first if btrieve is in valid positioning */
   if ( position == -1L)
   {
     /* invalid positioning get first record */ 
     BTRV (B_GETFIRST, filePosBlock, (char *)dept, &bufLen, code, 0 );
   }
   else
   {
     _bcopy(dept,(char *)&position,sizeof(position));
     retv = BTRV(B_DIRECT, filePosBlock, (char *) dept, &bufLen, code, 0 );
   }     

   /* issue a btrieve seek (GET NEXT) request... */
   retv = BTRV (B_GETNEXT, filePosBlock, (char *) dept, &bufLen, code, 0 );

   while ( retv == NORMAL  &&  dept->deleted == '*' )   
   {
      retv = BTRV (B_GETNEXT, filePosBlock, (char *) dept, &bufLen, code, 0 );
   }        

   if (retv != NORMAL)
   {
       retv =  BTRIEVE_ENDOFFILE;
   }    
   else
   {

     retv = BTRV (B_GETPOSI, filePosBlock, (char *) &position, &posLen, code, 0 );           
   }         

   dept_close_file();
          
   return (retv);
}


int dept_get_previous(void far *receive_buffer, unsigned recvLen,
                     void far *path, unsigned pathlen )
{
   int retv;
   unsigned char code[5];
   DEPT_RECORD far *dept;
   
   if ( recvLen != sizeof(DEPT_RECORD))
      return (INV_SEND_PARAM );      
             
   dept = receive_buffer;

   if ( (retv = dept_open_file (path,pathlen) ) != NORMAL )
      return retv;

   /* check first if btrieve is in valid positioning */
   if (position == -1L)
   {
     /* invalid positioning get first record */ 
     BTRV (B_GETFIRST, filePosBlock, (char *) dept, &bufLen, code, 0 );
   }
   else
   {
     _bcopy(dept,(char *)&position, sizeof(position) );
     retv =  BTRV(B_DIRECT, filePosBlock, (char *) dept, &bufLen, code, 0);
   }     
      
   /* issue a btrieve seek (GET NEXT) request... */
   retv = BTRV (B_GETPREV, filePosBlock, (char *) dept, &bufLen, code, 0 );

   while ( retv == NORMAL  &&  dept->deleted == '*' )   
   {
      retv = BTRV (B_GETPREV, filePosBlock, (char *) dept, &bufLen, code, 0 );           
   }        

   if (retv != NORMAL)
   {
       retv =  BTRIEVE_BEGOFFILE;
   }    
   else
   {
       retv = BTRV (B_GETPOSI, filePosBlock, (char *) &position, &posLen, code, 0 );           
   }                

   dept_close_file();
       
   return (retv);
}


int dept_get_last(void far *receive_buffer, unsigned recvLen,
                        void far *path, unsigned pathlen )
{
   int retv;
   unsigned char code[5];

   DEPT_RECORD far *dept;
   
   if ( recvLen != sizeof(DEPT_RECORD) )
      return (INV_RECV_PARAM );
             
   dept = receive_buffer;
   _bset ( code, 0x0, sizeof(code) );

   if ( (retv = dept_open_file (path,pathlen) ) != NORMAL )
      return retv;

   /* issue a btrieve seek (GET FIRST) request... */
   retv = BTRV (B_GETLAST, filePosBlock, (char *) dept, &bufLen, code, 0 );

   while ( retv == NORMAL  &&  dept->deleted == '*' )   
   {
      retv = BTRV (B_GETPREV, filePosBlock, (char *) dept, &bufLen, code, 0 );           
   }

   if ( retv != NORMAL )
     retv = BTRIEVE_BEGOFFILE;
   else
   {   
     retv = BTRV (B_GETPOSI, filePosBlock, (char *) &position, &posLen, code, 0 );                
   }
   
   dept_close_file();
       
   return (retv);
}


int dpcount_search_and_get(void far *data, unsigned datalen,                          
                           void far *receive_buffer, unsigned recvlen,
                           void far *path, unsigned pathlen, int parameter )
{
   char code[5];
   DP_COUNT_OUT far *getBuf;
   int retv;
   
   if ( recvlen != sizeof(DP_COUNT_OUT)  )
      return (INV_RECV_PARAM);

   if ( datalen != sizeof(getBuf->dept_code) )
      return (INV_SEND_PARAM);

   retv = dept_open_file(path,pathlen);
   
   if ( retv != NORMAL )
      return retv;
   
   getBuf = receive_buffer;
   _bset( code, 0x0, sizeof(code) );  
   _bcopy(code,data,datalen);    

   if ( memcmp(code,"++++",sizeof(getBuf->dept_code)) == 0 )
   {
   
      if ( position == -1L)
           retv = BTRV (B_GETFIRST, filePosBlock, (char *) &deptdata, &bufLen, code, 0 );       
      else
      {
          _bcopy(&deptdata,(char *)&position, sizeof(position) );
          retv =  BTRV(B_DIRECT, filePosBlock, (char *) &deptdata, &bufLen, code, 0);
      }  
   }   
   else
     retv = BTRV (B_GETGE, filePosBlock, (char *) &deptdata, &bufLen, code, 0 );       
    
   if ( retv == NORMAL)
   {
     /* save the data to the return block */
     _bcopy(getBuf->dept_code,&deptdata.dp_code,DEP_CODE_LEN);
     _bcopy(getBuf->dept_desc,&deptdata.dp_desc,DEP_DESC_LEN);
     getBuf->quantity.n = deptdata.quantity.n;
     getBuf->amount.n   = deptdata.amount.n;
     getBuf->discount.n = deptdata.discount.n;     
     getBuf->ptd_qty.n  = deptdata.ptd_qty.n;
     getBuf->ptd_amt.n  = deptdata.ptd_amt.n;     
     getBuf->ptd_dsc.n  = deptdata.ptd_dsc.n;
   }  
   
   /* now get the next record possible */   
   retv = BTRV (B_GETNEXT, filePosBlock, (char *) &deptdata, &bufLen, code, 0);               

   if (parameter) /* zero skip */
   {
      while (retv == NORMAL)   
      {

        if (( deptdata.quantity.n + deptdata.amount.n + deptdata.discount.n ) != 0)
            break;                           
                  
        retv = BTRV (B_GETNEXT, filePosBlock, (char *) &deptdata , &bufLen, code, 0);                    

      }                           
   }  

   if (retv ==  NORMAL)
      retv = BTRV (B_GETPOSI, filePosBlock, (char *) &position, &posLen, code, 0 );           

   dept_close_file();
   
   return(retv);
}


int dpcount_search_and_put(void far *data, unsigned datalen,
                           void far *path, unsigned pathlen, int par)
{

   DP_COUNT_IN far * putBuf;       
   int retv = BTRIEVE_OPEN_ERR;
   char code[5];
   
   if ( datalen != sizeof(DP_COUNT_IN) ) /* amount + quantity and code */
      return (INV_SEND_PARAM);

   retv = dept_open_file (path,pathlen);
   
   if ( retv != NORMAL )
      return retv;
               
   putBuf = data;

   _bcopy(code,data,sizeof(putBuf->dept_code));
   
   retv = BTRV (B_GETEQ, filePosBlock, (char *) &deptdata, &bufLen, code, 0);

   if ( retv == NORMAL )
   {         
      if ( par == 1 ) {
        deptdata.quantity.n = 0;
        deptdata.amount.n   = 0;
        deptdata.discount.n = 0;
      }else if ( par == 2 ) {      
        deptdata.ptd_qty.n  = 0;
        deptdata.ptd_amt.n  = 0;
        deptdata.ptd_dsc.n  = 0;
      }else {
        deptdata.quantity.n += putBuf->quantity.n;
        deptdata.amount.n   += putBuf->amount.n;
        deptdata.discount.n += putBuf->discount.n;
        deptdata.ptd_qty.n  += putBuf->quantity.n;
        deptdata.ptd_amt.n  += putBuf->amount.n;
        deptdata.ptd_dsc.n  += putBuf->discount.n;           
      }             

      retv = BTRV (B_UPDATE, filePosBlock, (char *) &deptdata, &bufLen, code, 0);
      
      if ( retv != NORMAL )
         retv = BTRIEVE_UPDATE_ERR;
         
   }else if ( retv == 4 )
   {
      
      _bset(&deptdata,0x0,sizeof(deptdata));
      _bcopy(deptdata.dp_code,putBuf->dept_code,sizeof(putBuf->dept_code));      
      _bcopy(&deptdata.dp_desc,"AUTO ADD DEPARTMENT.",DEP_DESC_LEN);     
      deptdata.quantity.n = putBuf->quantity.n;
      deptdata.amount.n   = putBuf->amount.n;
      deptdata.discount.n = putBuf->discount.n;
      deptdata.ptd_qty.n  = putBuf->quantity.n;
      deptdata.ptd_amt.n  = putBuf->amount.n;
      deptdata.ptd_dsc.n  = putBuf->discount.n;           

      retv = BTRV (B_INSERT, filePosBlock, (char *) &deptdata, &bufLen, code, 0);
     
     if ( retv != NORMAL )
      retv = CODE_NOT_FOUND;
   }   

   dept_close_file();      
         
   return(retv);
}

                                            
/* EOF */