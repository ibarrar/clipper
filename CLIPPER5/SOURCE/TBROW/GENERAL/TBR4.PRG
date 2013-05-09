/*****
 *
 * TBR4.PRG
 *
 *
 * Clipper tbr4 /N /W
 * RTLINK FILE tbr4
 *
 */

// Include Header Files
#include "inkey.ch"
#include "setcurs.ch"

#define     COLSEP     CHR(32) + CHR(179) + CHR(32)
#define     HEADSEP    CHR(205) + CHR(209) + CHR(205)
#define     FOOTSEP    CHR(205) + CHR(207) + CHR(205)

FUNCTION Main()
   LOCAL b, column, nKey, aColors, cScreen

   cScreen := savescreen()
   SET SCOREBOARD OFF
   SET CONFIRM    ON

   USE test INDEX test3 NEW
   SETCURSOR(SC_NONE)

   SETCOLOR("N/W")
   SCROLL()
   @ 2, 6 TO 22,72 DOUBLE COLOR "W+/BG"

   b:= TBrowseDB( 3, 7, 21, 71 )
   // Now, we will use some colors for this column
   // Use the instance variable colorSpec, which contains a
   // character string defining a color table to the browse
   // display.
   // As a default, the current SETCOLOR() is copied into this
   // variable
   // As a matter of fact some of my color preferrences
   // are a disaster
   b:colorSpec := "W+/BG,N/W,W/N,N,GR+/W,N/BG,B+/BG,GR+/BG"

   b:colSep  := COLSEP
   b:headSep := HEADSEP
   b:footSep := FOOTSEP

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
   column:colorBlock := { |y| ;
      IF(y <= 3, { 6, 2 }, IF(y >= 5, { 7, 2 }, { 8, 2 } )) }
   // This instance variable contains an optional code block
   // that determines the color of data items as they are
   // displayed. This block is evaluated each time a new value
   // is retrieved using TBColumn:block
   // The retrieved data value is passed as an argument to
   // TBColumn:colorBlock, which must return an array
   // containing two numeric values
   // The first determines the unselected
   // color which determines the color used to headings,
   // footings, etc.
   // It is also used to display values when the cursor is not
   // on the data value being displayed.
   // The second value determines the selected color which
   // is used to display the current browse cell
   column:footing := "Last;Column"
   b:addColumn( column )

   b:freeze := 1

   WHILE .T.
      IF  ( b:colPos <= b:freeze )
         b:colPos := b:freeze + 1

      ENDIF

      WHILE ( !b:stabilize() )
      END

      IF ( b:stable )
         IF ( b:hitTop .OR. b:hitBottom )
            TONE(87.3,1)
            TONE(40,3.5)

         ENDIF
         WHILE( (nKey := INKEY(.5) ) == 0 )
            @  0, 70 SAY " " + TIME() + " "

         END

      ENDIF

      // Process key
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

// EOF - TBR4.PRG //
