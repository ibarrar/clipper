/*****
 *
 * TBR2.PRG
 *
 * Clipper tbr2 /N /W
 * RTLINK FILE tbr2
 *
 */

// Include Header Files
// This will make handling keystrokes
// a lot easier!
#include "inkey.ch"

FUNCTION Main()
   LOCAL b, column, nKey, cScreen

   cScreen := savescreen()
   SET SCOREBOARD OFF
   SET CONFIRM    ON

   USE test INDEX test3 NEW

   SETCOLOR("N/W")
   SCROLL()
   SETCOLOR("W+/BG,GR+/B")
   SCROLL( 2, 6, 22, 72 )
   @ 2, 6 TO 22,72 DOUBLE

   b := TBrowseDB( 3, 7, 21, 71 )

   // This time, we will use header and columns separators:
   // colSep contains an optional character used to draw a
   // vertical separator if there is another column to the
   // left of it.
   // headSep contains an optional character string used
   // to draw a horizontal separator between the heading and
   // data values.

   b:headSep := CHR(205) + CHR(209) + CHR(205) // мям
   b:colSep  := CHR(32) + CHR(179) + CHR(32)   //  Ё

   // This example uses five fields.
   column := TBColumnNew( "Field 1", {|| test->fld1} )
   b:addColumn( column )
   column := TBColumnNew( "Field 2", {|| test->fld2} )
   b:addColumn( column )
   column := TBColumnNew( "Field 3", {|| test->fld3} )
   b:addColumn( column )
   column := TBColumnNew( "Field 4", {|| test->fld4} )
   b:addColumn( column )
   column := TBColumnNew( "Field 5", {|| test->fld5} )
   b:addColumn( column )

   WHILE .T.
      // Stabilization
      WHILE ( !b:stabilize() )
         nKey := INKEY()
         IF ( nKey != 0 )
            EXIT // abort if a key is waiting

         ENDIF

      END

      IF ( b:stable )
         nKey := INKEY(0)

      ENDIF
      // Up to this point nothing changed. But we need to
      // include a keystroke handler to handle our cursor
      // movement methods

      // Process a key.
      // Choose the cursor movement method
      // based on the key pressed
      // The key definitions K_XXXX
      // are in inkey.ch header file
      IF ( nKey == K_DOWN )
         b:down()

      ELSEIF ( nKey == K_UP )
         b:up()

      ELSEIF ( nKey == K_PGDN )
         b:pageDown()

      ELSEIF ( nKey == K_PGUP )
         b:pageUp()

      ELSEIF ( nKey == K_CTRL_PGUP )
         b:goTop()

      ELSEIF ( nKey == K_CTRL_PGDN )
         b:goBottom()

      ELSEIF ( nKey == K_RIGHT )
         b:right()

      ELSEIF ( nKey == K_LEFT )
         b:left()

      ELSEIF ( nKey == K_HOME )
         b:home()

      ELSEIF ( nKey == K_END )
         b:end()

      ELSEIF ( nKey == K_CTRL_LEFT )
         b:panLeft()

      ELSEIF ( nKey == K_CTRL_RIGHT )
         b:panRight()

      ELSEIF ( nKey == K_CTRL_HOME )
         b:panHome()

      ELSEIF ( nKey == K_CTRL_END )
         b:panEnd()

      ELSEIF ( nKey == K_ESC )
         SCROLL()
         EXIT

      ENDIF

   END
   restscreen(,,,,cScreen)
   RETURN (NIL)

// EOF - TBR2.PRG //
