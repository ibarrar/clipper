/*****
 *
 * TBR10.PRG
 *
 * Clipper tbr10
 * RTLINK FILE tbr10
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
   LOCAL b, column, nKey, cScreen

   cScreen := savescreen()
   SET SCOREBOARD OFF
   SET CONFIRM    ON

   USE test INDEX test3 NEW
   SETCURSOR(SC_NONE)
   SETCOLOR("N/W")
   SCROLL()
   SETCOLOR("W+/BG")
   SCROLL( 2, 6, 22, 72 )
   @  2, 6 TO 22,72
   @ MAXROW(), 0 SAY ;
     PADC("ENTER - Edit      ESC - Quit",;
     MAXCOL() + 1) COLOR "W+/RB"

   b := TBrowseDB( 3, 7, 21, 71 )
   b:colorSpec := MYCOLORS
   b:colSep    := COLSEP
   b:headSep   := HEADSEP

   // Columns
   column := TBColumnNew( "Field 3", FIELDBLOCK("fld3") )
   b:addColumn( column )
   column := TBColumnNew( "Field 7", FIELDBLOCK("fld7") )
   b:addColumn( column )
   column := TBColumnNew( "Field 4", FIELDBLOCK("fld1") )
   b:addColumn( column )
   column := TBColumnNew( "Field 5", FIELDBLOCK("fld5") )
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

   // Cursors are for GETs, so:
   nCursSave := SETCURSOR(SC_NORMAL)

   // make sure browse is stable
   WHILE ( !obj:stabilize() )
   END

   column := obj:getColumn( obj:colPos )

   // create a corresponding GET and READ it
   get := GetNew(ROW(), COL(), column:block,;
               column:heading,, "W+/BG,W+/B")

   // Get old key value or NIL
   xOldKey := IF( EMPTY(INDEXKEY()), NIL, &(INDEXKEY()) )
   READMODAL( {get} )
   SETCURSOR(nCursSave)

   // When a TBrowse object stabilizes, it always
   // tries to leave the same "cell" highlighted
   // as was previously.
   // That is, it always tries to keep the highlight at
   // the same position within the browse window unless
   // it is explicitly moved via an up() or down()
   // message. The TBrowse positions the data source in a
   // corresponding fashion. If there are not enough rows
   // left in a data source (i.e. EOF encontered while
   // trying to adjust the database to match the window),
   // the TBrowse willrelent and move the cursor upward,
   // leaving it on the correct record but with part of
   // the window unfilled.
   // That works OK for logical EOF, but a problem can
   // occur when a GET on a key field causes the current
   // record to move so close to logical BOF that it is
   // impossible to highlight the current record while
   // leaving the highlight in the same position within
   // the window. In this case, TBrowse opts to leave the
   // highlight in the same position within the window,
   // even though that position no longer corresponds with
   // the same record as before. That is, it repositions
   // the database as far it will go, then leaves the
   // highlight where it was. The result is that you end up
   // with the highlight on a different record than the one
   // just edited. This will fix the behavior.

   // Get records key value or NIL
   xNewKey := IF( EMPTY(INDEXKEY()), NIL, &(INDEXKEY()) )

   // If key was changed
   IF xOldKey != xNewKey
      // Refresh
      obj:refreshAll()
      ForceStable( obj )

      // Make sure we are still in the right record
      // after stabilizing
      WHILE &(INDEXKEY()) > xNewKey .AND. !obj:hitTop()
         obj:up()
         ForceStable( obj )

      END

   ELSE
      obj:refreshCurrent()
      ForceStable( obj )

   ENDIF

   // check exit key
   nKey := LASTKEY()
   IF ( nKey == K_UP .OR. nKey == K_DOWN .OR. ;
      nKey == K_PGUP .OR. nKey == K_PGDN )
      KEYBOARD CHR( nKey )

   ENDIF
   RETURN (.T.)

// EOF - TBR10.PRG //
