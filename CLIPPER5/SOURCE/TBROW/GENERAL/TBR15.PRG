/*****
 *
 * TBR15.PRG
 *
 *
 * Clipper tbr15 /N /W
 * RTLINK FILE tbr15
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
     "Shift between browses",;
     MAXCOL() + 1) COLOR "W+/RB"

   // Opening first file
   USE test INDEX test3 NEW
   // Opening second file
   // For the example use the same
   // test file with another name
   COPY FILE test.dbf TO test1.dbf
   USE test1 NEW

   // First file
   SELECT test

   SETCOLOR("BG/B,GR+/W,,,BG/N")
   SCROLL( 2, 6, 10, 72 )
   @  2, 6 TO 10,72 DOUBLE
   b := TBrowseDB( 3, 7, 9, 71 )
   b:colSep  := COLSEP
   b:headSep := HEADSEP
   b:footSep := FOOTSEP

   SETCOLOR("N/BG,W+/RB,,,N/BG")
   SCROLL( 12, 6, 22, 72 )
   @ 12, 6 TO 22,72 DOUBLE
   c := TBrowseDB( 13, 7, 21, 71 )
   c:colSep  := COLSEP
   c:headSep := HEADSEP
   c:footSep := FOOTSEP

   // TBColumn objects
   // First file
   column := TBColumnNew( "Field 1", {|| test->fld1} )
   column:footing := "Browse #1"
   b:addColumn( column )
   column := TBColumnNew( "Field 2", {|| test->fld2} )
   b:addColumn( column )
   column := TBColumnNew( "Field 3", {|| test->fld3} )
   b:addColumn( column )
   column := TBColumnNew( "Field 4", {|| test->fld4} )
   b:addColumn( column )

   // TBColumn Objects
   // Second File
   column := TBColumnNew( "Field 5", {|| test1->fld5} )
   column:footing := "Browse #2"
   c:addColumn( column )
   column := TBColumnNew( "Field 6", {|| test1->fld6} )
   c:addColumn( column )
   column := TBColumnNew( "Field 7", {|| test1->fld7} )
   c:addColumn( column )

   // Remember: The variable contains a REFERENCE
   // to the object

   // First stabilize the unselected
   // object
   ForceStable( c )
   c:deHilite()
   // Dehilite cell in the unselected object
   // Actually, this is not mandatory but, you know,
   // is going to be a little "weird" if you have
   // highlighted "cells" in both browses
   // The user is going to ask you in which one she/he is
   // currently on...

   // This is going to be the current object
   w := b

   WHILE .T.
      ForceStable( w )

      IF ( w:hitTop .OR. w:hitBottom )
         TONE(87.3,1)
         TONE(40,3.5)

      ENDIF
      nKey := INKEY(0)

      // Process key
      IF !TBMoveCursor( w, nKey )
         IF ( nKey == K_ESC )
            SCROLL()
            EXIT

         ELSEIF ( nKey == K_TAB )
            // Change Current Browse
            // First dehilite cell
            w:deHilite()

            // Change the Current Browse
            IF w == b
               w := c
               SELECT test1

            ELSE
               w := b
               SELECT test

            ENDIF

            // Hilite the Cell
            w:hilite()

         ENDIF

      ENDIF

   END
   restscreen(,,,,cScreen)
   RETURN (NIL)

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

/*****
 *
 * Cursor Movement Methods
 *
 */

STATIC FUNCTION TBMoveCursor( o, nKey )
   LOCAL nFound
   STATIC aKeys := ;
       { K_DOWN      , {|obj| obj:down()},;
         K_UP        , {|obj| obj:up()},;
         K_PGDN      , {|obj| obj:pageDown()},;
         K_PGUP      , {|obj| obj:pageUp()},;
         K_CTRL_PGUP , {|obj| obj:goTop()},;
         K_CTRL_PGDN , {|obj| obj:goBottom()},;
         K_RIGHT     , {|obj| obj:right()},;
         K_LEFT      , {|obj| obj:left()},;
         K_HOME      , {|obj| obj:home()},;
         K_END       , {|obj| obj:end()},;
         K_CTRL_LEFT , {|obj| obj:panLeft()},;
         K_CTRL_RIGHT, {|obj| obj:panRight()},;
         K_CTRL_HOME , {|obj| obj:panHome()},;
         K_CTRL_END  , {|obj| obj:panEnd()} }

   nFound := ASCAN( aKeys, nKey )
   IF (nFound != 0)
      EVAL( aKeys[++nFound], o )

   ENDIF
   RETURN (nFound != 0)

// EOF - TBR15.PRG //
