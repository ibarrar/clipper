/*
* System......... Graphics Interface Library for Clipper 
* Program I.D.... Grfx_BMP.H
* Description.... Header file for gLoad_BMP() Function 
* Remarks........ This file duplicates structure and member names from 
*                 Borland C++ windows.h
* Author......... jay ocampo
* Date Started... October 1994
*/




// *** Defined constants ***

#define BMP_SIGNATURE_WORD 0x4D42     // "BM" 
#define SIZE_BMP_PALETTE   1         
#define SIZE_BMP_HEADER    40



// *** Status Codes for Bitmap operation ***

enum grBMPStatusCodes
{
   grBMP_OKAY        =  0 ,
   grBMP_ENDOFIMAGE  = -1 ,
   grBMP_ENDOFFILE   = -3 ,
   grBMP_IOERROR     = -4 ,
   grBMP_NOMEMORY    = -5 ,
   grBMP_OUTOFSYNC   = -6 ,
   grBMP_OVERFLOW    = -7 ,
   grBMP_BADPARAM    = -8 ,
   grBMP_UNSUPPORTED = -9 ,
   grBMP_INVALID     = -10
};


// *** Bitmap compression schemes constants ***

enum BiCompressionMethods
{
   xBI_NONE = 0,
   xBI_RGB  = 0,
   xBI_RLE4 = 2,
   xBI_RLE8 = 1
};


/*--------------------------------------------------------------------------*/


// *** xBITMAPFILEHEADER  structure definition ***

typedef struct xBITMAPFILEHEADER
{
   unsigned short bfType;        // signature - 'BM'
   unsigned long  bfSize;        // file size in bytes
   unsigned short bfReserved1;   // 0
   unsigned short bfReserved2;   // 0
   unsigned long  bfOffBits;     // offset to bitmap
};


// *** xBITMAPINFOHEADER structure definition

typedef struct xBITMAPINFOHEADER
{
   unsigned long  biSize;          // size of this struct
   long           biWidth;         // bmap width in pixels
   long           biHeight;        // bmap height in pixels
   unsigned short biPlanes;        // num planes - always 1
   unsigned short biBitCount;      // bits per pixel
   unsigned long  biCompression;   // compression flag
   unsigned long  biSizeImage;     // image size in bytes
   long           biXPelsPerMeter; // horz resolution
   long           biYPelsPerMeter; // vert resolution
   unsigned long  biClrUsed;       // 0 -> color table size
   unsigned long  biClrImportant;  // important color count
};


// *** BMP ( Red-Green-Blue ) Color Palette Structure ***

typedef struct xRGBPAL
{
   unsigned char red;
   unsigned char grn;
   unsigned char blu;
};



/*--------------------------------------------------------------------------*/

// *** Declare BMP function prototype ***



int load_bmp( char *fn, int iLeft, int iTop, int nright, int iBottom );
int BMP_Palette( FILE *fbmp, int depth, unsigned char *aColorPal );
int BMP_Decode(FILE *bmp_file, int pxl_size, unsigned char *buf, int npxls );
void Put_Scanline( unsigned char *aColorPal, char *scanline, int width , int icol, int irow );
unsigned long BMP_Offset( FILE *fbmp );
