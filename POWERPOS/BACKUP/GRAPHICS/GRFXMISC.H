/*
* System......... Graphics Interface Library for Clipper 
* Program I.D.... GrfxMisc.H
* Description.... Header file for Graphics Miscellaneous Function 
*                  
* Author......... jay ocampo
* Date Started... June 1994
*/



/* Define Constant parameters for gGrfxConfg() */
#define  MAXX_CFG           1  /* Get Maximum Column X in pixels                */
#define  MAXY_CFG           2  /* Get Maximum Row Y in pixels                   */
#define  XCURR_CFG          3  /* Get Current Column position in pixels         */
#define  YCURR_CFG          4  /* Get Current Row position in pixels            */
#define  CHAR_WIDTH_CFG     5  /* Get Average Width of String passed in pixels  */
#define  CHAR_HEIGHT_CFG    6  /* Get Average Width of String passed in pixels  */
#define  GMODE_CFG          7  /* Get Current Graphics Mode                     */
#define  FCOLOR_CFG         8  /* Get Current Foreground Color                  */
#define  BCOLOR_CFG         9  /* Get Current Background Color                  */
#define  CFONT_CFG         10  /* Get Current Font Setting                      */
#define  CFSIZE_CFG        11  /* Get Current Character Size                    */
#define  ISEGAVGA_CFG      12  /* Check if Graphics Driver is a EGA or VGA      */


/* Defined Constant parameter for gGrfxSetNw() */
#define  XMOVE_SET          1
#define  YMOVE_SET          2
#define  FCOLOR_SET         3
#define  BCOLOR_SET         4
#define  GMODE_SET          5
#define  SCR_ACTIVE_SET     6
#define  SCR_VISUAL_SET     7
