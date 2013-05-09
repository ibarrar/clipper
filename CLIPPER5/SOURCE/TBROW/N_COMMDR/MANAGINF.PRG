/*****
 *
 * MANAGINF.PRG
 *
 *
 * RMAKE manager
 *
 */

FUNCTION Info( nTop, nRight )
   LOCAL cClr, cScr

   // Save
   cClr := SETCOLOR("W+/RB")
   cScr := SAVESCREEN( 4, 5, 18, 66 )

   // Screen
   Shadow( 5, 7, 18, 66 )
   SCROLL( 4, 5, 17, 64 )
   @  4, 5 TO 17,64

   // This is the useless part of the program!
   //
   // Blah, blah, blah, blah, blah
   //
   @  5, 8 SAY "The CA-Clipper File Manager V1.5"
   @  7, 8 SAY "This program uses several features of CA-Clipper 5.2:"
   @  8, 8 SAY "codeblocks, TBrowse class, multi-dimensional arrays,"
   @  9, 8 SAY "Get objects, and also the CA-Clipper's make utility:"
   @ 10, 8 SAY "RMAKE.EXE"
   @ 16, 8 SAY "Strike any key to resume..."

   // Keep the clock running
   WhatKey( , {|| SETPOS(  0, 71 ),;
                  DEVOUT( TIME(), "N/BG" ) } )

   // Put it Back
   SETCOLOR(cClr)
   RESTSCREEN( 4, 5, 18, 66, cScr )
   RETURN (NIL)

// EOF - MANGINF.PRG //
