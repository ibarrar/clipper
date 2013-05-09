/*****
 *
 * TBR11.PRG
 *
 *
 * Clipper tbr11
 * RTLINK FILE tbr11
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
   LOCAL nRecno, nCnt, nTemp
   LOCAL nCursor, cSearch
   LOCAL GetList := {}

   cScreen := savescreen()
   SET SCOREBOARD OFF
   SET CONFIRM    ON

   USE test NEW
   INDEX ON STR(test->fld4, 5) TO test4
   SET INDEX TO test3,test7,test4
   SETCURSOR(SC_NONE)
   SETCOLOR("N/W")
   SCROLL()
   @  2, 6 TO 22,72 COLOR "W+/BG"
   @ MAXROW(), 0 SAY ;
     PADC("ESC - Quit          RIGHT,LEFT - "+;
     "Change active index" +;
     "           " +;
     "ALT_S - Seek",;
     MAXCOL() + 1) COLOR "W+/RB"

   b := TBrowseDB( 3, 7, 21, 71 )
   b:colorSpec := MYCOLORS
   b:colSep    := COLSEP
   b:headSep   := HEADSEP

   // Columns
   column := TBColumnNew( "Field 3", {|| test->fld3} )
   b:addColumn( column )
   column := TBColumnNew( "Field 7", {|| test->fld7} )
   b:addColumn( column )
   column := TBColumnNew( "Field 4", {|| test->fld4} )
   b:addColumn( column )
   column := TBColumnNew( "RecNo", {|| RECNO()} )
   b:addColumn( column )

   nTemp := 0
   WHILE .T.
      IF (nTemp != b:colPos) .AND.;
         (b:colPos >= 1 .AND. b:colPos <= b:colCount)
         nTemp := b:colPos
         // Switch Indexes
         nRecno := RECNO()
         // Reset all column colors
         FOR nCnt := 1 TO b:colCount
            column := b:getColumn( nCnt )
            column:defColor := {1, 2}

         NEXT

         DISPBEGIN()
         // Switch indexes (or no indexes)
         DBSETORDER( IF(INDEXKEY(b:colPos) == "",;
                       0, b:colPos) )
         // Different color for the current column
         // This means the current key (or no key
         // if the file is not indexed)
         column := b:getColumn( b:colPos )
         column:defColor := {8, 2}

         b:configure()
         b:refreshAll()
         ForceStable( b )
         //
         // As you already know,
         // TBrowse has that behaviour ...
         //
         DBSKIP(0)
         WHILE (nRecno != RECNO()) .AND. !(b:hitTop())
            b:up()
            ForceStable( b )

         END
         DISPEND()

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

         ELSEIF ( nKey == K_ALT_S )
            cSearch := SPACE(LEN(&(INDEXKEY(INDEXORD()))))
            SCROLL( 9, 8, 11, 40 )
            @  9, 8 TO 11,40
            nCursor := SETCURSOR(SC_NORMAL)
            @ 10,10 SAY "Search: " COLOR "W+/BG";
                    GET cSearch ;
                    PICTURE "@S20" COLOR "W+/W"
            READ
            SETCURSOR(SC_NONE)
            cSearch := TRIM(cSearch)
            SeekIt( cSearch ,, b )

         ENDIF

      ENDIF

   END
   FERASE("test4.ntx")
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
 * Seek a key
 *
 */

STATIC FUNCTION SeekIt( xKey, lSoftSeek, obj )
   LOCAL lFound, nRecno

   nRecno := RECNO()
   lSoftSeek := IF(VALTYPE(lSoftSeek) == "L",;
                  lSoftSeek, .F.)

   IF !(lFound := DBSEEK( xKey, lSoftSeek ))
      IF EOF()
         // Not found.
         // Keep pointer in the same place
         DBGOTO(nRecno)
         obj:invalidate()

      ENDIF

   ELSE
      // Found!
      // But there is that behaviour on TBrowse...
      //
      nRecno := RECNO()
      DISPBEGIN()
      obj:refreshAll()
      ForceStable( obj )
      WHILE (nRecno != RECNO()) .AND. !(obj:hitTop())
         obj:up()
         ForceStable( obj )

      END
      DISPEND()

   ENDIF

   RETURN (lFound)

// EOF - TBR11.PRG //

