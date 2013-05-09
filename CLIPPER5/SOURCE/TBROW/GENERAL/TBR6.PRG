/*****
 *
 * TBR6.PRG
 *
 *
 * Clipper tbr6 /N /W
 * RTLINK FILE tbr6
 *
 */

#include "inkey.ch"
#include "setcurs.ch"

#define     THAT_PLACE    2
#define     COLSEP        CHR(32)  + CHR(179) + CHR(32)
#define     HEADSEP       CHR(205) + CHR(209) + CHR(205)
#define     FOOTSEP       CHR(205) + CHR(207) + CHR(205)
#define     MYCOLORS      "W+/BG,N/W,W/N,N," +;
                          "GR+/W,N/BG,B+/BG,GR+/BG"

FUNCTION Main()
   LOCAL b, column, nKey, aColors, bData, cScreen

   cScreen := savescreen()
   SET SCOREBOARD OFF
   SET CONFIRM    ON

   USE test INDEX test3 NEW
   SETCURSOR(SC_NONE)

   SETCOLOR("N/W")
   SCROLL()
   @  2, 6 TO 22,72 DOUBLE COLOR "W+/BG"
   @ MAXROW(), 0 SAY ;
     PADC("F10 - Change columns      ESC - Quit",;
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
   column := TBColumnNew( "Field 3", {|| test->fld3} )
   b:addColumn( column )
   column := TBColumnNew( "Field 4", {|| test->fld4} )
   b:addColumn( column )
   column := TBColumnNew( "Field 5", {|| test->fld5} )
   column:footing := "Last"
   b:addColumn( column )

   b:freeze := 1

   // cargo
   // This is the same principle used in TBColumn:cargo
   // But now we will use TBrowse:cargo
   b:cargo := {|| ChangeIt() }

   WHILE .T.
      IF  ( b:colPos <= b:freeze )
         b:colPos := b:freeze + 1

      ENDIF

      ForceStable( b )

      IF ( b:hitTop .OR. b:hitBottom )
         TONE(87.3,1)
         TONE(40,3.5)

      ENDIF
      nKey := INKEY(0)

      // Process key
      IF !TBMoveCursor( b, nKey )
         IF ( nKey == K_ESC )
            SCROLL()
            EXIT

         ELSEIF ( nKey == K_F10 )
            b:setColumn( THAT_PLACE, EVAL( b:cargo ) )
            // You do not need to issue neither a configure()
            // nor a refreshAll() because setColumn() causes
            // a new configuration and refresh automatically

         ENDIF

      ENDIF

   END
   restscreen(,,,,cScreen)
   RETURN (NIL)

STATIC FUNCTION ChangeIt()
   LOCAL column
   STATIC IsItTheFirstTime := .T.
   IF IsItTheFirstTime
      IsItTheFirstTime := .F.
      column := TBColumnNew( "Field 7", {|| test->fld7} )

   ELSE
      IsItTheFirstTime := .T.
      column := TBColumnNew( "Field 2", {|| test->fld2} )

   ENDIF
   RETURN (column)

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

// EOF - TBR6.PRG //
