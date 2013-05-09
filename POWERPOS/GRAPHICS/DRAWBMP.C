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



#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <conio.h>
#include <io.h>
#include <alloc.h>
#include <fcntl.h>
#include <errno.h>
#include <graphics.h>


#include "grfx_api.h"
#include "draw_bmp.h"





int main(void)
{
  /** Define C-variables to hold Clipper parameters **/

  char *cBMPfile = "TEST.BMP";          // BMP filename
  int iLeft   = 0;
  int iTop    = 0;
  int iRight  = 639;
  int iBottom = 479;
  int    GraphDriver;             /* The Graphics device driver           */
  int    GraphMode;               /* The Graphics mode value              */
  int    ErrorCode;               /* Reports any graphics errors          */

  ErrorCode = grOk;

  GraphDriver = DETECT;                 /* Request auto-detection       */
  initgraph( &GraphDriver, &GraphMode, "" );
  ErrorCode = graphresult();            /* Read result of initialization*/
  if( ErrorCode != grOk )               /* Error occured during init    */
    {
      printf("\nError Code = %d", ErrorCode);
      return(ErrorCode);
     }


  load_bmp(cBMPfile, iLeft, iTop, iRight, iBottom );

  getch();

  closegraph();

  return(0);
}

/*--------------------------------------------------------------------------*/
int load_bmp(char *cBMPfile, int iLeft, int iTop, int iRight, int iBottom )
{


   struct xBITMAPINFOHEADER bmih;                      // BMP Info Header structure
   unsigned char *aColorPal;                           // BMP Color Palette array
   unsigned char *scanline;                            // BMP Scanline character buffer
   unsigned long bfOffBits;                            // BMP file offset
   int width;                                          // width ( in pixels ) of BMP picture
   int depth;                                          // integer indicative of COLOR format
   FILE *fbmp;                                         // BMP file handle
   int imgcnt;                                         // number of color palette
   int disp_width;                                     // width ( in pixels ) to display
   int rowbytes;                                       // calculated length of scanline buffer
   int iCtr;                                           // counter variable


   _fmode = O_BINARY;                      // force BINARY mode on all succeeding file i/o

   fbmp = fopen(cBMPfile, "r" ); // Open bitmap file
   if( fbmp == NULL )
     return(grBMP_IOERROR);

   // Check if Valid BMP file then
   // retrieve start of BMP file

   bfOffBits = BMP_Offset(fbmp);

   // Check BMP file offset
   if ( bfOffBits <= 0L )
      return((int)bfOffBits);

   // Read BMP Info Header
   if( fread(&bmih, sizeof(bmih), 1, fbmp) <= 0 )
      return(grBMP_IOERROR);

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
   if ((aColorPal = (unsigned char *) malloc(imgcnt)) == NULL)
      return(grBMP_NOMEMORY);


   // Load Color Palette to aColorPal array
   BMP_Palette( fbmp, imgcnt, aColorPal );

   // position to start of bitmap
   if (fseek( fbmp, bfOffBits, SEEK_SET ) == -1L)
      return(grBMP_IOERROR);

   // calculate size of a scan line buffer
   rowbytes = (width + 3) / 4;
   rowbytes *= 4;

   // Allocate memory for scanline of BMP picture
   if ((scanline = (char *) malloc(rowbytes)) == NULL)
      return(grBMP_NOMEMORY);

   memset(scanline, '\0', rowbytes);


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

   fclose( fbmp );                      // close BMP file handle
   free(scanline);                    // release allocated memory for scanline
   free(aColorPal);                   // release allocated memory for Color Palette

   return(grBMP_OKAY);
}




/*--------------------------------------------------------------------------*/


unsigned long BMP_Offset( FILE *fbmp )
{
   struct xBITMAPFILEHEADER bmfh;
   long offset;
   long nbytes;


   // Read BMP File Header
   if( fread(&bmfh, sizeof(bmfh), 1, fbmp) <= 0 )
        return((long)grBMP_IOERROR);


   // Check if File is a Valid BMP file
   if( bmfh.bfType != BMP_SIGNATURE_WORD )
        return((long)grBMP_INVALID );

   // determine which format version is used from structure size field
   offset = ftell( fbmp );
   nbytes = 0;
   fread( &nbytes, sizeof(long), 1, fbmp);
   fseek( fbmp, offset, SEEK_SET );

   // Check the error code returned by file i/o operation
   if ( errno == EACCES || errno == EBADF )
        return((long)grBMP_IOERROR);

   // Check if image format is a Windows 3.0 (and later version)  BMP format

   if( nbytes != SIZE_BMP_HEADER )
      return((long)grBMP_UNSUPPORTED);

   return(bmfh.bfOffBits);

}


/*--------------------------------------------------------------------------*/



int BMP_Palette( FILE *fbmp, int imgcnt, unsigned char *aColorPal )
{
   struct xRGBPAL    imgpal;       // image palette
   struct palettetype pal;
   int  i;

   /*
     Note :
          The Color Palette does not exactly match the default COLOR palette
          in C++.  The .BMP palette supported by this routine are 16-color and
          2-color (monochrome) format.  To make sure that .BMP has the
          supported color palette, use Windows PaintBrush program to load the
          particular bitmap file then save it as 16-color or monochrome .BMP
          format.

          A corresponding color array is used in displaying the bitmap scan line
          (instead of the actual color index) to preserve the COLOR CONSTANT
          used by other routines.
          Example: For MONOCHROME Bitmap palette, the COLOR BLUE constant
                   displays WHITE.
   */

   // eliminate Warning "fbmp" not used message
   // by checking BMP file handle value
   if (fbmp == NULL)
       return(grBMP_IOERROR);

   // grab a copy of the palette
   getpalette(&pal);

  // Assign fixed color palette
  if ( imgcnt == 2 )
    {
      aColorPal[0]  = BLACK;
      aColorPal[1]  = WHITE;
      return(grBMP_OKAY);
    }

   for( i=0; i<imgcnt; i++ )
     {

       if( fread(&imgpal, SIZE_BMP_PALETTE, 3, fbmp ) == NULL )
           return(grBMP_IOERROR);

       // position file pointer after Reserved byte
       if (fseek( fbmp, SIZE_BMP_PALETTE, SEEK_CUR ) == -1L)
          return(grBMP_IOERROR);

       // set the device palette
       imgpal.red >>= 2;
       imgpal.grn >>= 2;
       imgpal.blu >>= 2;

       //setrgbpalette(i, imgpal.red, imgpal.grn, imgpal.blu);
       setrgbpalette(pal.colors[i], imgpal.red, imgpal.grn, imgpal.blu);

   }

  /*
  // If Bitmap has a different set of color palette, load it in Windows
  // PaintBrush to change color palette to the values below
  setrgbpalette(pal.colors[BLUE        ],  128 >> 2, 0   >> 2, 0   >> 2);
  setrgbpalette(pal.colors[GREEN       ],  0   >> 2, 128 >> 2, 0   >> 2);
  setrgbpalette(pal.colors[CYAN        ],  128 >> 2, 128 >> 2, 0   >> 2);
  setrgbpalette(pal.colors[RED         ],  0   >> 2, 0   >> 2, 128 >> 2);
  setrgbpalette(pal.colors[MAGENTA     ],  128 >> 2, 0   >> 2, 128 >> 2);
  setrgbpalette(pal.colors[BROWN       ],  0   >> 2, 128 >> 2, 128 >> 2);
  setrgbpalette(pal.colors[DARKGRAY    ],  128 >> 2, 128 >> 2, 128 >> 2);
  setrgbpalette(pal.colors[LIGHTGRAY   ],  192 >> 2, 192 >> 2, 192 >> 2);
  setrgbpalette(pal.colors[LIGHTBLUE   ],  255 >> 2, 0   >> 2, 0   >> 2);
  setrgbpalette(pal.colors[LIGHTGREEN  ],  0   >> 2, 255 >> 2, 0   >> 2);
  setrgbpalette(pal.colors[LIGHTCYAN   ],  255 >> 2, 255 >> 2, 0   >> 2);
  setrgbpalette(pal.colors[LIGHTRED    ],  0   >> 2, 0   >> 2, 255 >> 2);
  setrgbpalette(pal.colors[LIGHTMAGENTA],  255 >> 2, 0   >> 2, 255 >> 2);
  setrgbpalette(pal.colors[YELLOW      ],  0   >> 2, 255 >> 2, 255 >> 2);
  */

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


   return(grBMP_OKAY);
}




/*--------------------------------------------------------------------------*/


int BMP_Decoder(FILE *bmp_file, int pxl_size, unsigned char *buf, int npxls )
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
	    x = fgetc(bmp_file);
	    m = 0x80;
	    while( (npxls > 0) && (m != 0) )
	    {
	       *buf++ = (x & m) ? 1 : 0;
	       m >>= 1;
	       npxls--;
	    }
	 }
      if (nbytes > 0)
         fseek(bmp_file, (long)nbytes, SEEK_CUR);


	 break;

      case 4 :
	 nbytes = (npxls + 1) / 2;
	 nbytes = (nbytes + 3) / 4;
	 nbytes *= 4;
	 while( npxls > 0 )
	 {
	    nbytes--;
	    x = fgetc(bmp_file);
	    p2 = x & 0x0F;
	    p1 = (x>>4) & 0x0F;
	    *buf++ = p1;
	    npxls--;
	    *buf++ = p2;
	    npxls--;
	 }
      if (nbytes > 0)
         fseek(bmp_file, (long)nbytes, SEEK_CUR);

      break;


      case 8 :
  	 // 256-Color BMP format
	 // large memory requirement
         nbytes = (npxls + 3) / 4;
         nbytes *= 4;
         fread(buf, npxls, 1, bmp_file);
         nbytes -= npxls;
         if (nbytes > 0)
            fseek(bmp_file, (long)nbytes, SEEK_CUR);
         break;

      case 24 :
	 // 24-Color BMP format
	 // slow image processing
         nbytes = (npxls*3 + 3) / 4;
         nbytes *= 4;
         fread(buf, npxls , 3, bmp_file);
         nbytes -= npxls*3;
         if (nbytes > 0)
            fseek(bmp_file, (long)nbytes, SEEK_CUR);
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

   
   if ( errno == EACCES || errno == EBADF )
       return(grBMP_IOERROR);
   else
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


