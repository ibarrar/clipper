/***
*
*  Readkey.prg
*
*  Summer '87 READKEY() Compatibility Routine
*
*  Copyright (c) 1993, Computer Associates International Inc.
*  All rights reserved.
*
*/

#include "Inkey.ch"


/***
*
*	READKEY()
*
*	Return a number representing the key pressed to exit from full-screen mode
*
*	Note: Differences between dBASE's READKEY() and Clipper's LASTKEY():
*
*         Exit Key:      dBASE:      Clipper:
*         ---------      ------      --------
*         Backspace         0        no exit
*         ^D, ^L            1        no exit
*         Lt arrow          2        no exit
*         Rt arrow          3        no exit
*         Up arrow          4        no exit
*         Dn arrow          5        no exit
*         PgUp              6          18
*         PgDn              7           3
*         Esc, ^Q          12          27 (Esc only)
*         ^End, ^W         14          23 (^W only)
*         type past end    15        ascii of last char typed
*         Enter            15          13
*         ^Home            33        no exit
*         ^PgUp            34        no exit
*         ^PgDn            35        no exit
*         F1               36        no exit
*
*         dBASE III adds 256 to the exit code if the user changed anything.
*         Clipper uses its UPDATED() function to determine if anything
*         has changed.
*/
FUNCTION READKEY()

	DO CASE
   CASE LASTKEY() == K_UP
      RETURN  ( 4 + IF( UPDATED(), 256, 0 ))

   CASE LASTKEY() == K_DOWN
      RETURN  ( 5 + IF( UPDATED(), 256, 0 ))

   CASE LASTKEY() == K_PGUP
      RETURN  ( 6 + IF( UPDATED(), 256, 0 ))

   CASE LASTKEY() == K_PGDN
      RETURN  ( 7 + IF( UPDATED(), 256, 0 ))

   CASE LASTKEY() == K_ESC
      RETURN ( 12 + IF( UPDATED(), 256, 0 ))

   CASE LASTKEY() == K_CTRL_W
      RETURN ( 14 + IF( UPDATED(), 256, 0 ))

   CASE LASTKEY() == K_ENTER
      RETURN ( 15 + IF( UPDATED(), 256, 0 ))

   CASE LASTKEY() == K_CTRL_PGUP
      RETURN ( 34 + IF( UPDATED(), 256, 0 ))

   CASE LASTKEY() == K_CTRL_PGDN
      RETURN ( 35 + IF( UPDATED(), 256, 0 ))

   CASE LASTKEY() >= K_SPACE                    // Type past end
      RETURN ( 15 + IF( UPDATED(), 256, 0 ))

   OTHERWISE
      RETURN ( 0 )

	ENDCASE

   RETURN ( 0 )      // This never executes...

