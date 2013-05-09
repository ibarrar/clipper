/*
* System......... Graphics Library Routine for CLIPPER
* Program I.D.... GScrRest.C
* Description.... Restore Screen Routine 
*
* Author......... jay ocampo
* Date Started... November 1994
* Dialect........ Turbo C++
* Remarks........
*
*/

#ifdef __TINY__
#error GRAPHLIB will not run in the tiny model.
#endif

#include "extend.h"
#include "filesys.api"

/*#include <dos.h>
#include <stdio.h>
#include <stdlib.h>*/

#include <graphics.h>

#include "grfx_api.h"
#include "grfxscrn.h"


int cScrnRest( int iLeft, int iTop, char *cScrFile,
               int image_ops, int iDelFlag, int iMoveFlag );


CLIPPER gScrnRest(void)
{
  /** Define C-variables to hold Clipper parameters **/

  int iLeft, iTop;                          /* Upper left corner of screen region to save */
  char *cScrFile;        	            /* Screen Swap file */
  int image_ops;                            /* Put image operation */
  int iDelFlag;                             /* Delete Swap file flag */
  int iMoveFlag;                            /* Optional Row & Column movement parameter*/
  

  int status;                               /* return value */


  if (PCOUNT < 3)            		    /* Check parameters */
     {
       _retni(grSCR_BADPARAM);
       return;
     }

  /** Assign Default **/
  image_ops = COPY_PUT;
  iDelFlag  = TRUE;
  iMoveFlag = MSCALE;


  /** Assign Clipper parameters to C-data types **/

  iLeft   = _parni(1);
  iTop    = _parni(2);
  cScrFile = _parc(3);

  if(ISNUM(4))
     image_ops = _parni(4);

  if(ISNUM(5))
     iDelFlag = _parni(5);

  if(ISNUM(6))
     iMoveFlag = _parni(6);

  status =  cScrnRest( iLeft, iTop, cScrFile, image_ops, iDelFlag, iMoveFlag );


  _retni(status);

}

/*--------------------------------------------------------------------------*/



int cScrnRest( int iLeft, int iTop, char *cScrFile,
               int image_ops, int iDelFlag, int iMoveFlag )
{
   struct xScrFileHEADER  xScr;              // Screen file header
   FHANDLE fhandle;                          // Screen file handle
   unsigned char *imgbuf;                    // image buffer
   unsigned int isize;                       // image size variable
   unsigned int iRowCnt;                     // row counter
   int iCnt;                                 // image counter


   if(iMoveFlag != MPIXEL)
     {
       iLeft   = iscale(iLeft  , SCALE_X , SCR_SCALE);
       iTop    = iscale(iTop   , SCALE_Y , SCR_SCALE);
      }


   // Open screen input file
   fhandle = _fsOpen(cScrFile, FO_READ|FO_SHARED);

   if (_fsError())
      return( grSCR_IOERROR );

   // Read Screen File Header
   _fsRead(fhandle,(BYTEP)&xScr, sizeof(xScr));

   // Check Screen file for signature word
   if ( xScr.scrType != SCR_SIGNATURE_WORD)
      {
         _fsClose(fhandle);
         return( grSCR_UNSUPPORTED );
      }

   // Position file pointer to start of screen image
   _fsSeek(fhandle, xScr.lOffBits , FS_SET);

   isize = max( xScr.iSizeImage, xScr.iLastImage);

   // allocate largest memory required to hold the image
   imgbuf = _xalloc(isize);

   if (imgbuf == NULL)
      {
         _fsClose(fhandle);
         return( grSCR_NOMEMORY );
      }


   iRowCnt = iTop;

   for ( iCnt = 1; iCnt <= xScr.iImgCount; iCnt++ )
    {

      if( iCnt == xScr.iImgCount )
          isize = xScr.iLastImage;
      else
          isize = xScr.iSizeImage;

      // Read Image buffer
      _fsRead(fhandle, imgbuf, isize);

      // display the image
      putimage(iLeft, iRowCnt, imgbuf, image_ops);

      iRowCnt += xScr.iRowIncr + 1;

    }

   // clean-up code
   _xfree(imgbuf);
   _fsClose(fhandle);

   // delete screen file
   if (iDelFlag)
      _fsDelete (cScrFile);

   return( grSCR_OKAY );
}

