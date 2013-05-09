/*****
 *
 * TBR16.PRG
 *
 *
 * Clipper tbr16 /N /W
 * RTLINK FILE tbr16
 *
 */

#include "inkey.ch"
#include "setcurs.ch"

#define     COLSEP     CHR(32)  + CHR(179) + CHR(32)
#define     HEADSEP    CHR(205) + CHR(209) + CHR(205)
#define     FOOTSEP    CHR(205) + CHR(207) + CHR(205)

FUNCTION Main()
   LOCAL b, column, nKey, c, w, cScreen

   cScreen := savescreen()
   SET SCOREBOARD OFF
   SET CONFIRM    ON
   SETCURSOR(SC_NONE)
   SETCOLOR("N/W")
   SCROLL()
   @ MAXROW(), 0 SAY ;
     PADR("ESC - Quit          TAB - "+;
     "Shift between browses"+;
     "         F9 - Move columns",;
     MAXCOL() + 1) COLOR "W+/RB"

   USE test INDEX test3 NEW

   // Create first Tbrowse object
   SETCOLOR("BG/B,GR+/W,,,BG/N")
   SCROLL( 2, 6, 10, 72 )
   @  2, 6 TO 10,72 DOUBLE
   b := TBrowseDB( 3, 7, 9, 71 )
   b:colorSpec := "BG/B,GR+/W,,,BG/N"
   b:colSep    := COLSEP
   b:headSep   := HEADSEP
   b:footSep   := FOOTSEP

   SETCOLOR("N/BG,W+/RB,,,N/BG")
   SCROLL( 12, 6, 22, 72 )
   @ 12, 6 TO 22,72 DOUBLE
   c := TBrowseDB( 13, 7, 21, 71 )
   c:colorSpec := "N/BG,W+/RB,,,N/BG"
   c:colSep    := COLSEP
   c:headSep   := HEADSEP
   c:footSep   := FOOTSEP

   // TBColumn objects
   // First Browse
   //
   column := TBColumnNew( "Field 1", {|| test->fld1} )
   column:footing := "Browse #1"
   b:addColumn( column )
   column := TBColumnNew( "Field 2", {|| test->fld2} )
   column:footing := "Browse #1"
   b:addColumn( column )
   column := TBColumnNew( "Field 3", {|| test->fld3} )
   column:footing := "Browse #1"
   b:addColumn( column )
   column := TBColumnNew( "Field 4", {|| test->fld4} )
   column:footing := "Browse #1"
   b:addColumn( column )

   // Second Browse
   //
   column := TBColumnNew( "Field 5", {|| test->fld5} )
   column:footing := "Browse #2"
   c:addColumn( column )
   column := TBColumnNew( "Field 6", {|| test->fld6} )
   column:footing := "Browse #2"
   c:addColumn( column )
   column := TBColumnNew( "Field 7", {|| test->fld7} )
   column:footing := "Browse #2"
   c:addColumn( column )

   // First stabilize second object
   ForceStable(c)
   // Dehilite cell in the unselected object
   c:deHilite()
   // Current object will be the first one
   w := b

   WHILE .T.
      // Stabilize current object
      ForceStable( w )

      IF ( w:hitTop .OR. w:hitBottom )
         TONE(87.3,1)
         TONE(40,3.5)

      ENDIF
      nKey := INKEY(0)

      // Process key
      IF !TBMoveCursor( nKey, w )
         IF ( nKey == K_ESC )
            SCROLL()
            EXIT

         ELSEIF ( nKey == K_F9 )
            // Current column will be transfered
            // from one browse to another but, only if you
            // have more than one column in the current
            // selected one
            IF w:colCount > 1
               // Take the column out
               column := w:delColumn(w:colPos)
               IF w == b
                  // insert column at current position
                  c:insColumn(c:colPos, column)
                  // Stabilize
                  ForceStable( c )
                  c:deHilite()

               ENDIF
               IF w == c
                  b:insColumn(b:colPos, column)
                  ForceStable( b )
                  b:deHilite()

               ENDIF
               // To be in the safe side
               ForceStable( w )
            ELSE
               ALERT("You have to have more than one column;"+;
                    "in the current browse in order to;"+;
                    "move columns away",;
                    {"Continue"})

            ENDIF

         ELSEIF ( nKey == K_TAB )
            // Change Current Browse
            // First dehilite cell
            w:deHilite()

            // Change the Current Browse
            IF(w == b, w := c, w := b)

            // Hilite the Cell
            w:hilite()

         ENDIF

      ENDIF

   END
   restscreen(,,,,cScreen)
   RETURN (NIL)

/*****
 *
 * Cursor Movement Methods
 *
 */

STATIC FUNCTION TBMoveCursor( nKey, oObj )
   LOCAL nFound
   LOCAL aKeys := ;
       { K_DOWN      , {|b| b:down()},;
         K_UP        , {|b| b:up()},;
         K_PGDN      , {|b| b:pageDown()},;
         K_PGUP      , {|b| b:pageUp()},;
         K_CTRL_PGUP , {|b| b:goTop()},;
         K_CTRL_PGDN , {|b| b:goBottom()},;
         K_RIGHT     , {|b| b:right()},;
         K_LEFT      , {|b| b:left()},;
         K_HOME      , {|b| b:home()},;
         K_END       , {|b| b:end()},;
         K_CTRL_LEFT , {|b| b:panLeft()},;
         K_CTRL_RIGHT, {|b| b:panRight()},;
         K_CTRL_HOME , {|b| b:panHome()},;
         K_CTRL_END  , {|b| b:panEnd()} }

   nFound := ASCAN( aKeys, nKey )
   IF (nFound != 0)
      EVAL( aKeys[++nFound], oObj )

   ENDIF
   RETURN (nFound != 0)

/*****
 *
 * Forces stabilization
 *
 */

STATIC FUNCTION ForceStable( obj )
   DISPBEGIN()
   WHILE !obj:stabilize()
   END
   DISPEND()
   RETURN (NIL)

// EOF - TBR16.PRG //
