/***
*
*  Box.ch
*
*  Standard definitions for Clipper box drawing commands
*
*  Copyright (c) 1990-1993, Computer Associates International, Inc.
*  All rights reserved.
*
*/

// Single-line box
#define	B_SINGLE 		( CHR(218) + CHR(196) + CHR(191) + CHR(179) + ;
                          CHR(217) + CHR(196) + CHR(192) + CHR(179)   )

// Double-line box
#define B_DOUBLE		( CHR(201) + CHR(205) + CHR(187) + CHR(186) + ;
                       CHR(188) + CHR(205) + CHR(200) + CHR(186)   )

// Single-line top, double-line sides
#define B_SINGLE_DOUBLE	( CHR(214) + CHR(196) + CHR(183) + CHR(186) + ;
                          CHR(189) + CHR(196) + CHR(211) + CHR(186)   )

// Double-line top, single-line sides
#define	B_DOUBLE_SINGLE	( CHR(213) + CHR(205) + CHR(184) + CHR(179) + ;
                             CHR(190) + CHR(205) + CHR(212) + CHR(179)   )


#define _BOX_CH

