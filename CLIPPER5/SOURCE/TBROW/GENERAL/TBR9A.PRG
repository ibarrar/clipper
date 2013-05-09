/*****
 *
 * TBR9A.PRG
 *
 *
 * It fixes the "bug" on tbr9.prg
 *
 * Clipper tbr9a /N /W
 * RTLINK FILE tbr9a
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
   LOCAL b, column, nKey, aColors, cScreen

   cScreen := savescreen()
   SET SCOREBOARD OFF
   SET CONFIRM    ON
   READEXIT(.T.)

   USE test INDEX test3 NEW
   SETCURSOR(SC_NONE)
   SETCOLOR("N/W")
   SCROLL()
   @  2, 6 TO 22,72 COLOR "W+/BG"
   @ MAXROW(), 0 SAY ;
     PADC("ENTER - Edit      ESC - Quit",;
     MAXCOL() + 1) COLOR "W+/RB"

   b := TBrowseDB( 3, 7, 21, 71 )
   b:colorSpec := MYCOLORS
   b:colSep    := COLSEP
   b:headSep   := HEADSEP
   b:footSep   := FOOTSEP

   // TBColumn objects
   // Due to the fact that ahead in this example
   // we will edit the field, we need to assign a get-set
   // block to the object
   //
   // Use FIELDBLOCK("field")
   // FIELDBLOCK() assumes you are using a field in the current
   // work area
   // If you need to use a field in another area
   // use FIELDWBLOCK()
   //
   column := TBColumnNew( "Field 1", FIELDBLOCK("fld1") )
   column:footing := "First"
   b:addColumn( column )
   column := TBColumnNew( "Field 2", FIELDBLOCK("fld2") )
   b:addColumn( column )
   column := TBColumnNew( "Field 3", FIELDBLOCK("fld3") )
   b:addColumn( column )
   column := TBColumnNew( "Field 4", FIELDBLOCK("fld4") )
   b:addColumn( column )
   column := TBColumnNew( "Field 5", FIELDBLOCK("fld5") )
   column:footing := "Last"
   b:addColumn( column )

   b:freeze := 1

   WHILE .T.
      IF ( b:colPos <= b:freeze )
         b:colPos := b:freeze + 1

      ENDIF

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

         ELSEIF ( nKey == K_ENTER )
            DoGet( b )

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

/*****
 *
 * @...GET
 *
 */

STATIC FUNCTION DoGet( obj )
   LOCAL nCursSave
   LOCAL column, get, nKey

   // Cursors are for GETs, so:
   nCursSave := SETCURSOR(SC_NORMAL)

   // make sure browse is stable
   WHILE ( !obj:stabilize() )
   END

   column := obj:getColumn( obj:colPos )

   // create a corresponding GET and READ it
   get := GetNew(ROW(), COL(), column:block,;
               column:heading,, "W+/BG,W+/B")
   READMODAL( {get} )

   // force redisplay of current row
   obj:refreshCurrent()

   // check exit key
   nKey := LASTKEY()
   IF ( nKey == K_UP .OR. nKey == K_DOWN .OR. ;
      nKey == K_PGUP .OR. nKey == K_PGDN )
      KEYBOARD CHR( nKey )

   ENDIF
   SETCURSOR(SC_NONE)
   RETURN (NIL)

// EOF - TBR9A.PRG //
