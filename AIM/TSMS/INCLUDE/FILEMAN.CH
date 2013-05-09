/*****
*  
*  Fileman.ch
*  Include file for Fileman.prg
*
*  Copyright (c) Nantucket Corporation, 1990.  All rights reserved.
*  David R. Alison
*
*/

// The elements in aFileMan
#define  FM_ROWTOP         1
#define  FM_COLTOP         2
#define  FM_ROWBOTTOM      3
#define  FM_COLBOTTOM      4
#define  FM_COLOR          5
#define  FM_PATH           6
#define  FM_RETURNFILE     7
#define  FM_OLDCOLOR       8
#define  FM_OLDSCREEN      9
#define  FM_OLDSELECT      10

#define  FM_ELEMENTS       10

// The elements in aTab
#define  TB_ROWTOP         1
#define  TB_COLTOP         2
#define  TB_ROWBOTTOM      3
#define  TB_COLBOTTOM      4
#define  TB_COLOR          5
#define  TB_POSITION       6

#define  TB_ELEMENTS       6

// The main menu items
#define  MN_LOOK           1
#define  MN_COPY           2
#define  MN_RENAME         3
#define  MN_DELETE         4
#define  MN_PRINT          5
#define  MN_OPEN           6

// The Up and Down arrows, highlight and background char's for the thumb tab
#define  TB_UPARROW        CHR(  24 )
#define  TB_DNARROW        CHR(  25 )
#define  TB_HIGHLIGHT      CHR( 178 )
#define  TB_BACKGROUND     CHR( 176 )

// The checkmark for the tagged files
#define  FM_CHECK          CHR( 251 )

// Other definitions
#define  FM_SINGLEFRAME    "ÚÄ¿³ÙÄÀ³"
#define  FM_SINGLEBORDER   "Ã´ÂÁ"
#define  FM_DOUBLEFRAME    "ÉÍ»º¼ÍÈº"
#define  FM_DOUBLEBORDER   "Ì¹ËÊ"
#define  FM_LEFT           1
#define  FM_RIGHT          2
#define  FM_TOP            3
#define  FM_BOTTOM         4
#define  FM_HORIZONTAL     2
#define  FM_VERTICAL       4
#define  K_SPACE           32

