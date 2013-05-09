/*****
 *
 * TBR12.PRG
 *
 *
 * Clipper tbr12 /N /W
 * RTLINK FILE tbr12
 *
 */

#include "inkey.ch"
#include "setcurs.ch"

#define     COLSEP     CHR(32)  + CHR(179) + CHR(32)
#define     HEADSEP    CHR(205) + CHR(209) + CHR(205)
#define     FOOTSEP    CHR(205) + CHR(207) + CHR(205)
#define     MYCOLORS   "W+/BG,N/W,W/N,N," +;
                       "GR+/W,N/BG,B+/BG,GR+/BG,W+/B"

#xtranslate     GETSETBLOCK      =>     (column:cargo)\[1\]
#xtranslate     BLOCKPICTURE     =>     (column:cargo)\[2\]

FUNCTION Main()
   LOCAL b, column, nKey, cScreen

   cScreen := savescreen()
   SET SCOREBOARD OFF
   SET CONFIRM    ON
   READEXIT(.T.)

   USE test INDEX test3 NEW
   SETCURSOR(SC_NONE)
   SETCOLOR("N/W")
   SCROLL()
   @  2, 6 TO 22,72 COLOR "W+/BG"
   b := TBrowseDB( 3, 7, 21, 71 )
   b:colorSpec := MYCOLORS
   b:headSep   := HEADSEP
   b:colSep    := COLSEP

   column := TBColumnNew( "Record#", {|| RECNO()} )
   b:addColumn( column )
   column := TBColumnNew( "Field 2", FIELDBLOCK("fld2") )
   column:cargo := { FIELDBLOCK("fld2"), "" }
   column:width := 10
   b:addColumn( column )
   column := TBColumnNew( "Field 3", FIELDBLOCK("fld3") )
   column:cargo := { FIELDBLOCK("fld3"), "" }
   column:width := 30
   b:addColumn( column )
   column := TBColumnNew( "Field 4", FIELDBLOCK("fld4") )
   column:cargo := { FIELDBLOCK("fld4"), "" }
   column:width := 5
   b:addColumn( column )
   column := TBColumnNew( "Field 5", ;
                          {|| TRANSFORM(test->fld5, "99,999.99")})
   column:cargo   := { FIELDBLOCK("fld5"), "99,999.99" }
   column:width   := 10
   b:addColumn( column )

   b:freeze := 1

   WHILE .T.
      IF  ( b:colPos <= b:freeze )
         b:colPos := b:freeze + 1

      ENDIF

      // Regular color
      b:colorRect({b:rowPos, b:freeze + 1, b:rowPos,;
                   b:colCount},;
                   {1, 1})
      ForceStable( b )

      // Bar color
      b:colorRect({b:rowPos, b:freeze + 1, b:rowPos,;
                  b:colCount}, {9, 2})
      // Since you are painting a group of cells in a
      // different colour, you should hilite the
      // current cell (specially if you are going to edit)
      b:hilite()
      IF ( b:hitTop .OR. b:hitBottom )
         TONE(87.3,1)
         TONE(40,3.5)

      ENDIF
      nKey := INKEY(0)

      IF !TBMoveCursor( b, nKey )
         IF ( nKey == K_ESC )
            SCROLL()
            SETCURSOR(SC_NORMAL)
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
   LOCAL nCursSave, xOldKey, xNewKey
   LOCAL column, get, nKey

   nCursSave := SETCURSOR(SC_NORMAL)
   WHILE ( !obj:stabilize() )
   END
   column := obj:getColumn( obj:colPos )
   get := GetNew(ROW(), COL(), column:block,;
               column:heading,, "W+/BG,W+/B")
   xOldKey := IF( EMPTY(INDEXKEY()), NIL, &(INDEXKEY()) )
   READMODAL( {get} )
   SETCURSOR(SC_NONE)

   xNewKey := IF( EMPTY(INDEXKEY()), NIL, &(INDEXKEY()) )
   IF xOldKey != xNewKey
      obj:refreshAll()
      ForceStable( obj )
      WHILE &(INDEXKEY()) > xNewKey .AND. !obj:hitTop()
         obj:up()
         ForceStable( obj )

      END

   ELSE
      obj:refreshCurrent()
      ForceStable( obj )

   ENDIF

   nKey := LASTKEY()
   IF ( nKey == K_UP .OR. nKey == K_DOWN .OR. ;
      nKey == K_PGUP .OR. nKey == K_PGDN )
      KEYBOARD CHR( nKey )

   ENDIF
   RETURN (NIL)

// EOF - TBR12.PRG //

