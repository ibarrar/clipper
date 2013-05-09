/*
 * System.......... PowerPos for Spectrum
 * Program I.D..... itemfile.c
 * Author.......... Rollie C. Ibarra Jr.
 * Date Started.... Sept 1, 1996
 * Dialect......... C called by faccess.c main module 
 * Module ......... Used for file access of itemtran file
 * Remarks......... Called by the local server application 
*/


#include <string.h>
#include <stdlib.h>
#include "filesys.api"

#include "extend.h"
#include "itemfile.h"
#include "faccess.h"

#pragma check_stack-

int itemtran_append ( void far *data, unsigned datalen, char far *machno,
                      void far *path, unsigned pathlen, int parm )
{
   void far *filename;
   int handle;
   ITEMRECORD far *irecord;

   if (datalen != sizeof(ITEMRECORD))
      return(INV_SEND_PARAM);

   if (( filename = _xalloc(13+pathlen)) == NULL)
       return(MEM_ALLOC_ERR);

   _bset( filename,0x0,13+pathlen);    
   _bcopy(filename,path,pathlen);
   strcat(filename,ITEMTRAN_FILE_NAME);
     
   strcat(filename,machno);
   if (parm)
     strcat(filename,".LOC");
   else  
     strcat(filename,".TXT");   

   handle = _fsOpen( filename, FO_READWRITE | FO_SHARED );

   if ( _fsError() == 2 )
   {
      handle = _fsCreate( filename, FC_NORMAL );
   }   

   _xfree( filename );   

   if (_fsError())
      return (FILE_OPEN_ERR);
      
   _fsSeek(handle,0L,FS_END);

   irecord = data;

   irecord->crlf[0] = 13;
   irecord->crlf[1] = 10;

   if (_fsWrite(handle,(char far *)irecord, sizeof(ITEMRECORD)) != sizeof(ITEMRECORD))
   {
      _fsClose(handle);
      return(FILE_WRITE_ERR);
   }
   
   _fsClose(handle);
   return NORMAL;
}

