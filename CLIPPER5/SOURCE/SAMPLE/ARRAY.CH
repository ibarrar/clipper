/***
*
*  Array.ch
*
*  Header file for array functions contained in Array.prg
*
*  Copyright (c) 1993, Computer Associates International Inc.
*  All rights reserved.
*
*  Usage: place #include "Array.ch" at the top of any program file
*         that uses a function from Array.prg.
*/

// Comparison blocks to be used with AComp()
#define AC_MAX     {|x,y| x > y }              // Element with maximum value
#define AC_MIN     {|x,y| x < y }              // Element with minimum value
#define AC_MAXLEN {|x,y| LEN( x ) > LEN( y ) } // Element with maximum length
#define AC_MINLEN {|x,y| LEN( x ) < LEN( y ) } // Element with minimum length
