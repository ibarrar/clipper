/*****
 *
 * TBR3.PRG
 *
 *
 * Clipper tbr3 /N /W
 * RTLINK FILE tbr3
 *
 */

// Include Header Files
#include "inkey.ch"
#include "setcurs.ch"

#define     COLSEP     CHR(32)  + CHR(179) + CHR(32)
#define     HEADSEP    CHR(205) + CHR(209) + CHR(205)
#define     FOOTSEP    CHR(205) + CHR(207) + CHR(205)

FUNCTION Main()
   LOCAL b, column, nKey, cScreen

   cScreen := savescreen()
   SET SCOREBOARD OFF
   SET CONFIRM    ON

   USE test INDEX test3 NEW

   // Cursors are for GETs, so turn it off
   // The SC_XXXX contants are defined in setcurs.ch
   SETCURSOR(SC_NONE)

   SETCOLOR("N/W")
   SCROLL()
   SETCOLOR("W+/BG,N/W")
   SCROLL( 2, 6, 22, 72 )
   @ 2, 6 TO 22,72 DOUBLE

   b := TBrowseDB( 3, 7, 21, 71 )
   b:colSep  := COLSEP
   b:headSep := HEADSEP
   b:footSep := FOOTSEP

   // TBColumn objects
   column := TBColumnNew( "Field 1", {|| test->fld1} )
   // Footer for this column
   column:footing := "First"
   b:addColumn( column )
   column := TBColumnNew( "Field 2", {|| test->fld2} )
   b:addColumn( column )
   column := TBColumnNew( "Field 3", {|| test->fld3} )
   b:addColumn( column )
   column := TBColumnNew( "Field 4", {|| test->fld4} )
   b:addColumn( column )
   column := TBColumnNew( "Field 5", {|| test->fld5} )
   // Footer for this column
   column:footing := "Last"
   b:addColumn( column )

   // One useful thing: freeze one or more columns on the
   // screen. You could accomplish this using the instance
   // variable freeze. It defines the number of data columns
   // frozen on the left side of the display
   b:freeze := 1

   // If later you need to "defrost" the column, just
   // use b:freeze := 0

   WHILE .T.
      // Do not allow cursor to move into frozen columns
      // (This is Optional!)
      // You will use the instance variable colPos to get
      // current cursor column position and assign it
      IF  ( b:colPos <= b:freeze )
         b:colPos := b:freeze + 1

      ENDIF

      // Stabilization
      WHILE ( !b:stabilize() )
         nKey := INKEY()
         IF ( nKey != 0 )
            EXIT // abort if a key is waiting

         ENDIF

      END

      IF ( b:stable )
         // Is always a good idea tell the user about
         // end or beginning of file
         // b:hitTop contais a .T. if an attempt was made
         // to navigate beyond the beginning of data source
         // b:hitBottom contais a .T. if an attempt was made
         // to navigate beyond the end of data source

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
   // Declaring this array as static will speed things up,
   // since Clipper will not create/destroy it every time
   // you call this function
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

// EOF - TBR3.PRG //
