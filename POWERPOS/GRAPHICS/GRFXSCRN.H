/*
* System......... Graphics Interface Library for Clipper 
* Program I.D.... GrfxScrn.H
* Description.... Header file for gScrnSave(), gScrnRest() and
*                 other Screen Functions
* Author......... jay ocampo
* Date Started... November 1994
*/



// *** Defined constants ***

#define IMAGE_BUF_SIZE     15360       // 15K - memory limit for image buffer

#define SCR_SIGNATURE_WORD 0x414D4546  // "FEMA"


/*--------------------------------------------------------------------------*/


// *** Status Codes for Screen Save/Restore operation ***

enum grSCRStatusCodes
{
   grSCR_OKAY        =  0 ,
   grSCR_INVALID     = -1 ,
   grSCR_ENDOFIMAGE  = -2 ,
   grSCR_IOERROR     = -3 ,
   grSCR_NOMEMORY    = -4 ,
   grSCR_BADPARAM    = -5 ,
   grSCR_UNSUPPORTED = -6
};



/*--------------------------------------------------------------------------*/


// *** xSCRFILEHEADER  structure definition ***

typedef struct xScrFileHEADER
{
   unsigned long  scrType;      // signature - 'BM'
   unsigned long  lOffBits;     // file pointer offset
   unsigned int   iBackColor;   // background color/ clear color
   unsigned int   iLeft;        // left coordinate ( in pixels )
   unsigned int   iTop;         // top coordinate  ( in pixels )
   unsigned int   iWidth;       // whole image width (in pixels)
   unsigned int   iHeight;      // whole image height (in pixels)
   unsigned int   iImgCount;    // number of times image is subdivided
   unsigned int   iRowIncr;     // row increment from the top coordinate
   unsigned int   iSizeImage;   // image size (in bytes)
   unsigned int   iLastImage;   // image size (in bytes) of last image
};


     