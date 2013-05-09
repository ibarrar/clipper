/*****
 *
 * TBR7.PRG
 *
 *
 * Clipper tbr7 /N /W
 * RTLINK FILE tbr7
 *
 */

#include "inkey.ch"
#include "setcurs.ch"

#define     COLSEP     CHR(32)  + CHR(179) + CHR(32)
#define     HEADSEP    CHR(205) + CHR(209) + CHR(205)
#define     FOOTSEP    CHR(205) + CHR(207) + CHR(205)
#define     MYCOLORS   "W+/BG,N/W,W/N,N," +;
                       "GR+/W,N/BG,B+/BG,GR+/BG"


FUNCTION Main()
   LOCAL b, column, nKey, aColors, bData, cScreen
   LOCAL lLogic := .F.
   LOCAL col

   cScreen := savescreen()
   SET SCOREBOARD OFF
   SET CONFIRM    ON

   USE test INDEX test3 NEW
   SETCURSOR(SC_NONE)
   SETCOLOR("N/W")
   SCROLL()
   @  2, 6 TO 22,72 DOUBLE COLOR "W+/BG"
   @ MAXROW(), 0 SAY ;
     PADC("F10 - Insert/Delete columns      ESC - Quit",;
     MAXCOL() + 1) COLOR "W+/RB"

   b := TBrowseDB( 3, 7, 21, 71 )
   b:colorSpec := MYCOLORS
   b:colSep    := COLSEP
   b:headSep   := HEADSEP
   b:footSep   := FOOTSEP

   // TBColumn objects
   column := TBColumnNew( "Field 1", {|| test->fld1} )
   column:footing := "First"
   b:addColumn( column )
   column := TBColumnNew( "Field 2", {|| test->fld2} )
   b:addColumn( column )
   column := TBColumnNew( "Field 7", {|| test->fld7} )
   b:addColumn( column )
   column := TBColumnNew( "Field 5", {|| test->fld5} )
   column:footing := "Last"
   b:addColumn( column )
   b:freeze := 1

   WHILE .T.
      IF  ( b:colPos <= b:freeze )
         b:colPos := b:freeze + 1

      ENDIF

      ForceStable( b )

      IF ( b:hitTop .OR. b:hitBottom )
        TONE(238,5,1)
        TONE(330,5,1)
      ENDIF
      nKey := INKEY(0)

      // Process key
      IF !TBMoveCursor( b, nKey )
         IF ( nKey == K_ESC )
            SCROLL()
            EXIT

         ELSEIF ( nKey == K_F10 )
            IF lLogic
               lLogic := .F.
               // insColumn is a method which allows a column
               // object to be inserted into the middle of a
               // browse. The return value is a reference to
               // the column object being inserted
               b:insColumn( b:colPos, col )

            ELSE
               lLogic := .T.
               // delColumn is a method which allows a column
               // object to be deleted from a browse. The return
               // value is a reference to the column object being
               // deleted
               col := b:delColumn( b:colPos )

            ENDIF

            // refreshAll() is automatic when you
            // insert/delete a column

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

// EOF - TBR7.PRG //
