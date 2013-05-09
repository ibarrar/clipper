/*
* System......... Graphics Interface Library for Clipper 
* Program I.D.... Grfx_API.H
* Description.... Header file for C++ Graphics Functions    
* Author......... jay ocampo
* Date Started... June 1994
*/


#include "grfxcomn.h"                       // Common Utilities prototypes
#include "grfx_asm.h"                       // Assembly routine prototypes



#ifdef __cplusplus
extern "C" {
#endif


/***** font drivers *****/

/* !!   These "functions" are NOT user-callable,   !! */
/* !! they are there just so you can link in fonts !! */

/*  Used by registerfont function                     */
/*
void           _Cdecl      script_font(void);
void           _Cdecl     simplex_font(void);
void           _Cdecl triplex_scr_font(void);
void           _Cdecl     complex_font(void);
void           _Cdecl    european_font(void);
void           _Cdecl        bold_font(void);
*/

/*  Used by registerfontfar function                     */
extern int far _Cdecl      script_font_far[];
extern int far _Cdecl     simplex_font_far[];
extern int far _Cdecl triplex_scr_font_far[];
extern int far _Cdecl     complex_font_far[];
extern int far _Cdecl    european_font_far[];
extern int far _Cdecl        bold_font_far[];


#ifdef __cplusplus
}
#endif

#ifdef __cplusplus

  int max(int value1, int value2);

  int max(int value1, int value2)
  {
     return ( (value1 > value2) ? value1 : value2);
  }

  int min(int value1, int value2);

  int min(int value1, int value2)
  {
     return ( (value1 < value2) ? value1 : value2);
  }

#endif


/*  Global Function Declaration for GRFX_LIB.LIB */

int cTextInfo(int iObjPtr);
int cStrWidth(char *textstring);

/*  Define Statements start here  */

#define GRFXBUFSIZE 500                 /* internal graphics buffer size */


/* Defined Constants for nMoveFlag (Row and Column Movements parameter */
#define MSCALE     0                    /* Row & Column movement is scaled -- from (0,0) home position */
#define MPIXEL     1                    /* Use Col & Row parameters are (x, y) coordinate : NOT RECOMMENDED !!! */
#define MFIX       2                    /* Row & Column movement is fixed -- from (0,0) home position */
#define MROWREL    3                    /* Row movement is relative to current Row position  */
#define MCOLREL    4                    /* Column movement is relative to current Col position */
#define MBOTHREL   5                    /* Row & Column is relative to current (Col, Row) position */


#define SCALE_X         (getmaxx())
#define SCALE_Y         (getmaxy())
#define NFONTS          11
#define END_PARM        -32768          // Explicit Param to Signal End of parameter list
#define SCR_SCALE       100             // Scale Row & Column from 0 TO 100
#define Y_MAGDIV        1920            // (480 * 4) Divisor of Stroked Font character height
#define X_MAGDIV        2560            // (640 * 4) Divisor of Stroked Font character width

#define THIN_THICK_LINE  5              // Additional User Defined Line Style
#define BUTTON_UP_LINE   6              // Additional User Defined Line Style
#define BUTTON_DWN_LINE  7              // Additional User Defined Line Style

#define THIN_THICK_ADJ   5              // Adjustment (in pixels) for the inner box


/*  Define Addt'l Graphics Code Error Constants
    for CLIPPER Interface Functions
*/
#define  grNORMAL                0
#define  grINVP                 -1

