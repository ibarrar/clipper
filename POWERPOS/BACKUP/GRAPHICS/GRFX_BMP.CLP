/*
* System......... Graphics Library Routine for CLIPPER
* Program I.D.... Grfx_BMP.C
* Description.... Windows BMP File Viewer Function
*
* Author......... jay ocampo
* Date Started... October 1994
* Dialect........ Turbo C++
* Remarks........
*
*/

#ifdef __TINY__
#error GRAPHLIB will not run in the tiny model.
#endif


#include "extend.h"          // Clipper API header file
#include "filesys.api"

/*#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <conio.h>
#include <io.h>
#include <alloc.h>
#include <fcntl.h>
#include <errno.h>*/

#include <graphics.h>


#include "grfx_api.h"
#include "grfx_bmp.h"



CLIPPER gLoad_BMP(void)
{
  /** Define C-variables to hold Clipper parameters **/

  char *cBMPfile;          // BMP filename
  int iLeft, iTop;         // Upper left corner of box
  int iRight, iBottom;     // Lower right corner of box

  /** Define local variables **/

  int status;


  if ( PCOUNT < 1)
  {
       _retni(grINVP);
	  return;
  }

  iLeft   =  END_PARM;
  iTop    =  END_PARM;
  iRight  =  END_PARM;
  iBottom =  END_PARM;

  if (ISCHAR(1))
     cBMPfile = _parc(1);
  else
  {
       _retni(grINVP);
       return;
  }


  if (ISNUM(2))
  {
      iLeft   = _parni(2);
      iLeft   = iscale(iLeft  , SCALE_X , SCR_SCALE);
  }


  if (ISNUM(3))
  {
      iTop    = _parni(3);
      iTop    = iscale(iTop   , SCALE_Y , SCR_SCALE);
  }

  if (ISNUM(4))
  {
      iRight  = _parni(4);
      iRight  = iscale(iRight , SCALE_X , SCR_SCALE);
  }

  if (ISNUM(5))
  {
     iBottom = _parni(5);
     iBottom = iscale(iBottom, SCALE_Y , SCR_SCALE);
  }

  status = load_bmp( cBMPfile, iLeft, iTop, iRight, iBottom );

  _retni(status);

}

/*
Parameter List
cBMPfile         -> BMP (path and) file name

Optional parameter List
iLeft, iTop      -> Upper left corner of box
iRight, iBottom  -> Lower right corner of box

Optional Parameter = END_PARM if not explicitly passed
*/

int load_bmp(char *cBMPfile, int iLeft, int iTop, int iRight, int iBottom )
{


   struct xBITMAPINFOHEADER bmih;                      // BMP Info Header structure
   unsigned char *aColorPal;                           // BMP Color Palette array
   unsigned char *scanline;                            // BMP Scanline character buffer
   unsigned long bfOffBits;                            // BMP file offset
   int width;                                          // width ( in pixels ) of BMP picture
   int depth;                                          // integer indicative of COLOR format
   FHANDLE fbmp;
   int imgcnt;                                         // number of color palette
   int disp_width;                                     // width ( in pixels ) to display
   int rowbytes;                                       // calculated length of scanline buffer
   int iCtr;                                           // counter variable

   fbmp = _fsOpen(cBMPfile,FO_READ|FO_SHARED ); // Open bitmap file
   
   if( _fsError() )
     return(grBMP_IOERROR-10);

   // Check if Valid BMP file then
   // retrieve start of BMP file

   bfOffBits = BMP_Offset(fbmp);

   // Check BMP file offset
   if ( bfOffBits <= 0L )
      return((int)bfOffBits);

   // Read BMP Info Header
   if( _fsRead(fbmp,(BYTEP)&bmih, sizeof(bmih)) <= 0 )
      return(grBMP_IOERROR-20);

   width  = (int) bmih.biWidth;
   depth  = bmih.biBitCount;

   // Check for BMP compression format
   if ( (int) bmih.biCompression != xBI_NONE )
       return(grBMP_UNSUPPORTED);

   /* Check for BMP Color format
        Color formats supported are :
           1  ->  for monochrome color format
           4  ->  for 16-color format
        Color formats NOT supported are :
           8  ->  for 256 color format due to large memory requirement
           24 ->  for 24-color format due to slow image processing
   */

   if ( depth != 1 && depth != 4 )
       return(grBMP_UNSUPPORTED);

   // Determine palette size
   imgcnt = 0;
   if( imgcnt < 24 )
      imgcnt = 1 << depth;

   // Allocate memory for Color Palette
   if ((aColorPal = (unsigned char *) _xalloc(imgcnt)) == NULL)
      return(grBMP_NOMEMORY);


   // Load Color Palette to aColorPal array
   BMP_Palette( fbmp, imgcnt, aColorPal );

   // position to start of bitmap
   _fsSeek( fbmp, bfOffBits, FS_SET );

   if ( _fserror())
   {
      _fsClose(fbmp);
      return(grBMP_IOERROR-30);
   }

   // calculate size of a scan line buffer
   rowbytes = (width + 3) / 4;
   rowbytes *= 4;

   // Allocate memory for scanline of BMP picture
   if ((scanline = (char *) _xalloc(rowbytes)) == NULL)
      return(grBMP_NOMEMORY);

   _bset(scanline, '\0', rowbytes);


   // Handle omitted coordinate parameters

   if ( iLeft == END_PARM  && iRight == END_PARM  )
      {
        iLeft  = (getmaxx() + 1 - width)  / 2;
        iRight = iLeft + width;
      }

   if ( iTop == END_PARM  && iBottom == END_PARM  )
      {
        iTop  = (getmaxy() + 1 -  (int)bmih.biHeight ) / 2;
        iBottom = iTop + (int)bmih.biHeight;
      }

   if ( iLeft == END_PARM )
        iLeft = 0;

   if ( iRight == END_PARM )
        iRight = iLeft + width;

   if ( iTop == END_PARM )
        iTop = 0;

   if ( iBottom == END_PARM )
        iBottom = iTop + (int)bmih.biHeight;

   if ((iRight - iLeft) < width)
       disp_width = iRight - iLeft;
   else
       disp_width = width;

   for( iCtr = (int)bmih.biHeight - 1; iCtr >= 0 ; iCtr-- )
   {
      BMP_Decoder(fbmp, depth, scanline, width );
      if ( iCtr <= iBottom - iTop)
         Put_Scanline( aColorPal, scanline, disp_width, iLeft, iTop + iCtr );
   }

   _fsClose( fbmp );                    // close BMP file handle
   _xfree(scanline);                    // release allocated memory for scanline
   _xfree(aColorPal);                   // release allocated memory for Color Palette

   return(grBMP_OKAY);
}



/*--------------------------------------------------------------------------*/


unsigned long BMP_Offset( FHANDLE fbmp )
{
   struct xBITMAPFILEHEADER bmfh;
   long offset;
   long nbytes;


   // Read BMP File Header
   if( _fsRead(fbmp, (BYTEP)&bmfh, sizeof(bmfh)) <= 0 )
        return((long)grBMP_IOERROR-40);


   // Check if File is a Valid BMP file
   if( bmfh.bfType != BMP_SIGNATURE_WORD )
        return((long)grBMP_INVALID );

   // determine which format version is used from structure size field
   offset = _fsSeek( fbmp, 0, FS_RELATIVE );
   nbytes = 0;
   _fsRead( fbmp, (BYTEP)&nbytes, sizeof(long) );
   _fsSeek( fbmp, offset, FS_SET );

   // Check the error code returned by file i/o operation
   //   if ( errno == EACCES || errno == EBADF )
   //        return((long)grBMP_IOERROR-50);

   // Check if image format is a Windows 3.0 (and later version)  BMP format

   if( nbytes != SIZE_BMP_HEADER )
      return((long)grBMP_UNSUPPORTED);

   return(bmfh.bfOffBits);

}



/*--------------------------------------------------------------------------*/



int BMP_Palette( FHANDLE fbmp, int imgcnt, unsigned char *aColorPal )
{
   struct xRGBPAL    imgpal;       // image palette
   struct palettetype pal;
   int  i;

   // Note :
   //   Skip Reading and Loading of Color Palette since the altered
   //   screen colors do not coincide with the COLOR CONSTANTS in C++.
   //   Example: For MONOCHROME Bitmap palette, the COLOR BLUE constant
   //            displays WHITE.

/*   // eliminate Warning "fbmp" not used message
   // by checking BMP file handle value
   if (fbmp == NULL)
      return 0;
*/      

   /*

   // grab a copy of the palette
   getpalette(&pal);


   for( i=0; i<imgcnt; i++ )
     {

       if( _fsRead(fbmp, &imgpal, 3*SIZE_BMP_PALETTE, ) == NULL )
           return(grBMP_IOERROR);

       // position file pointer after Reserved byte
       if (_fsSeek( fbmp, SIZE_BMP_PALETTE, FS_RELATIVE ) == -1L)
          return(grBMP_IOERROR);

       // set the device palette
       imgpal.red >>= 2;
       imgpal.grn >>= 2;
       imgpal.blu >>= 2;

       setrgbpalette(pal.colors[i], imgpal.red, imgpal.grn, imgpal.blu);
     }
  */ 	

  // Assign fixed color palette

  if ( imgcnt == 2 )
    {
      aColorPal[0]  = BLACK;
      aColorPal[1]  = WHITE;
    }
  else
    {
      aColorPal[0]  = BLACK;
      aColorPal[1]  = RED;
      aColorPal[2]  = GREEN;
      aColorPal[3]  = BROWN;
      aColorPal[4]  = BLUE;
      aColorPal[5]  = MAGENTA;
      aColorPal[6]  = CYAN;
      aColorPal[7]  = DARKGRAY;
      aColorPal[8]  = LIGHTGRAY;
      aColorPal[9]  = LIGHTRED;
      aColorPal[10] = LIGHTGREEN;
      aColorPal[11] = YELLOW;
      aColorPal[12] = LIGHTBLUE;
      aColorPal[13] = LIGHTMAGENTA;
      aColorPal[14] = LIGHTCYAN;
      aColorPal[15] = WHITE;
    }

   return imgcnt;
}


/*--------------------------------------------------------------------------*/


int BMP_Decoder(FHANDLE bmp_file, int pxl_size, unsigned char *buf, int npxls )
{
  int i, j, k, nbytes;
  int x;
  int m;
  int p1, p2;


  switch( pxl_size )
   {
      case 1 :
	 nbytes = (npxls + 7) / 8;
	 nbytes = (nbytes + 3) / 4;
	 nbytes *= 4;
	 while( npxls > 0 )
	 {
	    nbytes--;
	    _fsRead(bmp_file,(BYTEP)&x,1);
	    m = 0x80;
	    while( (npxls > 0) && (m != 0) )
	    {
	       *buf++ = (x & m) ? 1 : 0;
	       m >>= 1;
	       npxls--;
	    }
	 }
      if (nbytes > 0)
         _fsSeek(bmp_file, (long)nbytes, FS_RELATIVE );

	 break;

      case 4 :
	 nbytes = (npxls + 1) / 2;
	 nbytes = (nbytes + 3) / 4;
	 nbytes *= 4;
	 while( npxls > 0 )
	 {
	    nbytes--;
       _fsRead(bmp_file,(BYTEP)&x,1);
	    p2 = x & 0x0F;
	    p1 = (x>>4) & 0x0F;
	    *buf++ = p1;
	    npxls--;
	    *buf++ = p2;
	    npxls--;
	 }
      if (nbytes > 0)
         _fsSeek(bmp_file, (long)nbytes, FS_RELATIVE );

      break;


      case 8 :
  	 // 256-Color BMP format
	 // large memory requirement
         nbytes = (npxls + 3) / 4;
         nbytes *= 4;
         _fsRead(bmp_file,buf, npxls);
         nbytes -= npxls;
         if (nbytes > 0)
            _fsSeek(bmp_file, (long)nbytes, FS_RELATIVE);
         break;

      case 24 :
	 // 24-Color BMP format
	 // slow image processing
         nbytes = (npxls*3 + 3) / 4;
         nbytes *= 4;
         _fsRead(bmp_file, buf, 3*npxls);
         nbytes -= npxls*3;
         if (nbytes > 0)
            _fsSeek(bmp_file, (long)nbytes, FS_RELATIVE);
	 // reorder bgr to rgb
         for( i=0, j=0; i<npxls; i++, j+=3 )
         {
            k = buf[j];
            buf[j] = buf[j+2];
            buf[j+2] = k;
         }
         break;

      default:
	 return(grBMP_UNSUPPORTED);
         // break;
   }


/*   if ( errno == EACCES || errno == EBADF )
       return(grBMP_IOERROR-60);
   else
   */
       return(grBMP_OKAY);

}



/*--------------------------------------------------------------------------*/



void Put_Scanline( unsigned char *aColorPal, char *scanline, int width , int icol, int irow )
{
  int iCtr, icolor;

  for( iCtr = 0; iCtr < width; iCtr++)
    {

      icolor = (int) scanline[iCtr];            // get scan line pixel value
      icolor = (int) aColorPal[icolor];         // use color from Color Palette array
      putpixel(iCtr + icol, irow, icolor);
    }
}


/*--------------------------------------------------------------------------*/


