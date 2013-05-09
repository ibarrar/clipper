/*
* System......... Graphics Library Routine for CLIPPER
* Program I.D.... GScrSave.C
* Description.... Save Screen Routine 
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
#include <stdlib.h>  */
#include <graphics.h>

#include "grfx_api.h"
#include "grfxscrn.h"

int cScrnSave( int iLeft, int iTop, int iRight, int iBottom, 
               char *cScrFile, int iMoveFlag );


CLIPPER gScrnSave(void)
{
  /** Define C-variables to hold Clipper parameters **/

  int iLeft, iTop;      	                 /* Upper left corner of screen region to save */
  int iRight, iBottom; 	                  /* Lower right corner of screen region to save */
  char *cScrFile;        	               /* Screen Swap file */
  int iMoveFlag;                          /* Optional Row & Column movement parameter*/

  int status;                             /* return value */


  if (PCOUNT < 5)            		       /* Check parameters */
     {
       _retni(grSCR_BADPARAM);
       return;
     }

  /** Assign Default **/
  iMoveFlag = MSCALE;

  /** Assign Clipper parameters to C-data types **/

  iLeft   = _parni(1);
  iTop    = _parni(2);
  iRight  = _parni(3);
  iBottom = _parni(4);
  cScrFile = _parc(5);

  if(ISNUM(6))
     iMoveFlag = _parni(6);
  	
  status = cScrnSave( iLeft, iTop, iRight, iBottom, cScrFile, iMoveFlag);

  _retni(status);
    
}

/*--------------------------------------------------------------------------*/


int cScrnSave( int iLeft, int iTop, int iRight, int iBottom, 
               char *cScrFile, int iMoveFlag )
{
   /* 
      Parameter List
      iLeft, iTop      -> Upper left corner of box  
      iRight, iBottom  -> Lower right corner of box
      cScrFile         -> Screen Swap file

	 Optional Parameter List
      MoveFlag         -> defaults to MSCALE if not passed

      Optional Parameter = END_PARM if not explicitly passed
   */
   
   struct xScrFileHEADER  xScr;              // Screen file header
   FHANDLE fhandle;                          // Screen file handle
   unsigned char *imgbuf;                    // image buffer
   unsigned int isize;                       // image size variable
   unsigned int iRowCnt;                     // row counter
   unsigned int irowdif;                     // row increment variable
   int iCnt;                                 // image counter


   if(iMoveFlag != MPIXEL)
     {
       iLeft   = iscale(iLeft  , SCALE_X , SCR_SCALE);
       iTop    = iscale(iTop   , SCALE_Y , SCR_SCALE);
       iRight  = iscale(iRight , SCALE_X , SCR_SCALE);
       iBottom = iscale(iBottom, SCALE_Y , SCR_SCALE);
      }


   // Open screen output
   fhandle = _fsOpen(cScrFile, FO_WRITE|FO_EXCLUSIVE);

   if ( _fsError() )
      return( grSCR_IOERROR );

   // determine the size of the image
   isize = imagesize(iLeft, iTop, iRight, iBottom);


   // Initialize Screen file header
   xScr.scrType = SCR_SIGNATURE_WORD;         // signature - 'FEMA'
   xScr.lOffBits = sizeof(xScr);              // file offset
   xScr.iBackColor = getbkcolor();            // background/clear color
   xScr.iLeft = iLeft;                        // left coordinate
   xScr.iTop = iTop;                          // top coordinate
   xScr.iWidth = iRight - iLeft;              // width in pixels
   xScr.iHeight = iBottom - iTop;             // height in pixels
   xScr.iImgCount = 1;                        // number of images stored
   xScr.iRowIncr = xScr.iHeight ;             // row increment
   xScr.iSizeImage = isize;                   // image size in bytes
   xScr.iLastImage = isize;                   // image size in bytes

   // Write Screen File Header
   _fsWrite(fhandle, (BYTEP)&xScr, sizeof(xScr));

   if ( xScr.iSizeImage > IMAGE_BUF_SIZE )
      {
        xScr.iImgCount = ( xScr.iSizeImage / IMAGE_BUF_SIZE) + 1;
        xScr.iRowIncr  = (xScr.iHeight / xScr.iImgCount) + 1;
      }
   else
     {
        xScr.iImgCount = 1;
        xScr.iRowIncr  = xScr.iHeight;
      }


   iCnt = 1;
   iRowCnt = iTop;
   irowdif = xScr.iRowIncr;

   // determine image size of portion of screen image
   isize = imagesize(iLeft, iTop, iRight, iTop + irowdif);

   // allocate largest memory required to hold the image
   imgbuf = _xalloc(isize);
   if (imgbuf == NULL)
      {
        _fsClose(fhandle);
        return( grSCR_NOMEMORY );
      }


   while( iRowCnt < iBottom )
    {

     // make sure to save only what is specified
     if ( iRowCnt + irowdif > iBottom )
          irowdif = iBottom - iRowCnt;

     isize = imagesize(iLeft, iRowCnt, iRight, iRowCnt + irowdif);

     // store the image size
     if( iCnt == xScr.iImgCount )
         xScr.iLastImage = isize;
     else
         xScr.iSizeImage = isize;

     // grab the image
     getimage(iLeft, iRowCnt, iRight, iRowCnt + irowdif, imgbuf);

     // Write Image buffer to Screen file
     _fsWrite(fhandle, imgbuf, isize );

     iRowCnt += irowdif + 1;
     ++iCnt;

    }

   // Reposition file pointer to start of file
   _fsSeek(fhandle, 0L, FS_SET);

   // Re-write updated screen file Header
   _fsWrite(fhandle, (BYTEP)&xScr, sizeof(xScr));


   // Clean-up code
   _xfree(imgbuf);
   _fsClose(fhandle);

   /*
   if (iClearFlag)
      {
        // set the fill style
        setfillstyle(SOLID_FILL, xScr.iBackColor );

        // clear the rectangular region
        bar(iLeft, iTop, iRight, iBottom);
      }
   */

   return( grSCR_OKAY );
}
