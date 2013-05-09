/*****
 *
 * TBR5.PRG
 *
 * Clipper tbr5 /N /W
 * RTLINK FILE tbr5
 *
 */

#include "inkey.ch"
#include "setcurs.ch"

#define     COLSEP     CHR(32) + CHR(179) + CHR(32)
#define     HEADSEP    CHR(205) + CHR(209) + CHR(205)
#define     FOOTSEP    CHR(205) + CHR(207) + CHR(205)
#define     MYCOLORS   "W+/BG,N/W,W/N,N," +;
                       "GR+/W,N/BG,B+/BG,GR+/BG"

FUNCTION Main()
   LOCAL b, column, nKey, aColors, oTemp, cScreen

   cScreen := savescreen()
   SET SCOREBOARD OFF
   SET CONFIRM    ON

   USE test INDEX test3 NEW
   SETCURSOR(SC_NONE)
   SETCOLOR("N/W")
   SCROLL()
   @  2, 6 TO 22,72 DOUBLE COLOR "W+/BG"
   @ MAXROW(), 0 SAY PADC("F10 - Change colors on last column  ESC - Quit",;
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
   // cargo
   // is an instance variable of ANY DATA TYPE, allowing
   // arbitrary information to be attached to a TBColumn object and
   // retrieved later
   column:cargo   := {|x| Recolor(x) }
   b:addColumn( column )
   column := TBColumnNew( "Field 5", {|| test->fld5} )
   column:cargo   := {|x| Recolor(x) }
   column:footing := "Last;Column"
   b:addColumn( column )

   b:freeze := 1

   WHILE .T.
      IF  ( b:colPos <= b:freeze )
         b:colPos := b:freeze + 1

      ENDIF

      // Stabilization
      ForceStable( b )

      IF ( b:stable )
         IF ( b:hitTop .OR. b:hitBottom )
            TONE(87.3,1)
            TONE(40,3.5)

         ENDIF
         nKey := INKEY(0)

      ENDIF

      // Process key
      IF !TBMoveCursor( b, nKey )
         IF ( nKey == K_ESC )
            SCROLL()
            EXIT

         ELSEIF ( nKey == K_F10 )
            // Check to see if you are at the right place
            // oTemp is a reference to the current column
            oTemp := b:getColumn( b:colPos )
            IF (oTemp:cargo != NIL)
               oTemp:colorBlock := EVAL( oTemp:cargo, oTemp )

               b:configure()
               // Causes the TBrowse object to
               // re-examine all instance variables and TBColumn
               // objects, and them reconfigure its internal settings
               // as required

               b:refreshAll()
               // Internally marks all data rows as
               // invalid, causing them to be refilled and redisplayed
               // during the NEXT stabilize loop

            ENDIF

         ENDIF

      ENDIF

   END
   restscreen(,,,,cScreen)
   RETURN (NIL)

STATIC FUNCTION Recolor(oCol)
   LOCAL GetList := {}  // For the Get System
   LOCAL cScr  := SAVESCREEN( 6, 20, 15, 39 )
   LOCAL cClr  := SETCOLOR( "W+/W,W/N" )
   LOCAL nCurs := SETCURSOR(SC_NORMAL)
   LOCAL nMenu := 3, nNum := 0.00
   LOCAL colorBlock

   // Check to see if field is numeric
   IF VALTYPE(EVAL(oCol:block)) != "N"
      RETURN (NIL)

   ENDIF
   // This is not a beautiful screen but it works!
   SCROLL( 6, 20, 15, 39 )
   @  6,20 TO 15,39 DOUBLE
   @  7,22 SAY "Select" COLOR "W+/W"
   @  9,22 PROMPT "Less Than"
   @ 10,22 PROMPT "Greater Than"
   @ 11,22 PROMPT "Equal to"
   MENU TO nMenu

   @ 14,22 SAY "Value:" GET nNum PICTURE "999999.99"
   READ

   // Here you decide what color you will use in your column
   IF nMenu == 1
      colorBlock := { |y| IF(y < nNum, { 7, 2 },;
	                          { 1, 2 }) }
   ELSEIF nMenu == 2
      colorBlock := { |y| IF(y > nNum, { 6, 2 },;
	                          { 1, 2 }) }
   ELSE
      colorBlock := { |y| IF(y == nNum, { 8, 2 },;
	                          { 1, 2 }) }

   ENDIF
   SETCURSOR(nCurs)
   SETCOLOR(cClr)
   RESTSCREEN( 6, 20, 15, 39, cScr )

   // And return the proper block
   RETURN (colorBlock)

/*****
 *
 * Forces stabilization
 *
 */

STATIC FUNCTION ForceStable( obj )
   // DISPBEGIN()/DISPEND()
   // They buffer your screen output so,
   // everything is going to show up at
   // the same time
   // This is useful to give the feeling of
   // speed even in slow machines
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

// EOF - TBR5.PRG //
