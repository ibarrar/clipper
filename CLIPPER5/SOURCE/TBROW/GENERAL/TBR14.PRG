/*****
 *
 * TBR14.PRG
 *
 *
 * Clipper tbr14 /N /W
 * RTLINK FILE tbr14
 *
 */

// Include Header Files
#include "inkey.ch"
#include "setcurs.ch"

#define     COLSEP     CHR(32)  + CHR(179) + CHR(32)
#define     HEADSEP    CHR(205) + CHR(209) + CHR(205)
#define     FOOTSEP    CHR(205) + CHR(207) + CHR(205)
#define     MYCOLORS   "W+/BG,N/W,W/N,N," +;
                       "GR+/W,N/BG,B+/BG,GR+/BG,W+/B"

FUNCTION Main()
   LOCAL b, column, nKey, cScreen

   cScreen := savescreen()
   SET SCOREBOARD OFF
   SET CONFIRM    ON

   USE test INDEX test3 NEW

   SETCURSOR(SC_NONE)
   SETCOLOR("N/W")
   SCROLL()
   @  2, 6 TO 22,72 DOUBLE COLOR "W+/BG"

   b := TBrowseDB( 3, 7, 21, 71 )
   b:colorSpec := MYCOLORS
   b:colSep    := COLSEP
   b:headSep   := HEADSEP

   // TBColumn objects
   column         := TBColumnNew( "Field 4", {|| test->fld4})
   b:addColumn( column )
   column         := TBColumnNew( "Field 5", {|| test->fld5})
   b:addColumn( column )
   column         := TBColumnNew()
   column:heading := "Field 4 * Field 5"
   // Also, add a "picture"
   column:block   := {|| TRANSFORM(test->fld4 * test->fld5,;
                                   "999,999,999.99")}
   b:addColumn( column )

   WHILE .T.
      ForceStable( b )

      IF ( b:hitTop .OR. b:hitBottom )
         TONE(87.3,1)
         TONE(40,3.5)

      ENDIF
      nKey := INKEY(0)

      IF !TBMoveCursor( b, nKey )
         IF ( nKey == K_ESC )
            SCROLL()
            EXIT

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

// EOF - TBR14.PRG //
