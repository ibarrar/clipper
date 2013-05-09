/*****
 *
 * TBR13.PRG
 *
 * Clipper tbr13 /N /W
 * RTLINK FILE tbr13
 *
 */

#include "inkey.ch"
#include "setcurs.ch"

#xcommand   FORCE [STABLE] <x> =>;
                  DISPBEGIN();;
                  WHILE !(<x>:stabilize());;
                  END;;
                  DISPEND()

#xcommand   ADD COLUMN <x> TO <c> [HEADING <*y*>]   =>;
            <c>:addColumn( TBColumnNew( <"y"> , <{x}> ) )

#define     HEADSEP    CHR(205) + CHR(209) + CHR(205)
#define     COLSEP     CHR(32)  + CHR(179) + CHR(32)

#define     TOP        2
#define     LEFT       6
#define     BOTTOM     22
#define     RIGHT      73

#define     MYCOLORS     "W+/BG,W+/R*,W/N," +;
                         "N,GR+/W,N/B,R+/B,GR+/B,W+/B*"
FUNCTION Fx1()
   LOCAL b, column, nKey, aColors, cScreen
   LOCAL nWindow, nInitPos, nNewPos
   LOCAL nTop, nLeft, nBottom, nRight

   nTop    := TOP
   nLeft   := LEFT
   nBottom := BOTTOM
   nRight  := RIGHT

   USE test
   cScreen := savescreen()
   SETBLINK(.F.)
   SETCURSOR(SC_NONE)
   SETCOLOR("W/W*")
   SCROLL()
   SETCOLOR("W+/BG")
   SCROLL( nTop, nLeft, nBottom, nRight )
   @  nTop++,nLeft++ TO nBottom--,nRight

   b := TBrowseDB( nTop, nLeft, nBottom, nRight - 1)
   b:colorSpec := MYCOLORS
   b:headSep   := HEADSEP
   b:colSep    := COLSEP

   // TBColumn objects
   ADD COLUMN test->fld2 TO b HEADING Field 2
   ADD COLUMN test->fld3 TO b HEADING Field 3
   ADD COLUMN test->fld4 TO b HEADING Field 4
   ADD COLUMN TRANSFORM(test->fld5, "99,999.99" ) ;
              TO b HEADING Field 5
   ADD COLUMN test->fld7 TO b HEADING Field 7
   ADD COLUMN test->fld8 TO b HEADING Field 8

   WHILE .T.
      b:colorRect({b:rowPos, b:freeze + 1,;
                   b:rowPos, b:colCount},;
                   {1, 1})

      FORCE STABLE b

      IF ( b:stable )
         b:colorRect({b:rowPos, b:freeze + 1, b:rowPos,;
                    b:colCount}, {9, 2})
         b:hilite()

         // Scroll Bars
         DbfVertScrollBar( nTop, nBottom, nRight )
         BrowHorizScrollBar( b, nBottom + 1,;
                             nLeft, nRight - 1)

         nKey := INKEY(0)

      ENDIF

      IF !TBMoveCursor( nKey, b )
         IF ( nKey == K_ESC )
            EXIT

         ENDIF

      ENDIF

   END

   SCROLL()
   restscreen(,,,,cScreen)
   RETURN (NIL)

/*****
 *
 * Cursor Movement Methods
 *
 */

STATIC FUNCTION TBMoveCursor(nKey, oObj)
   LOCAL nFound
   STATIC aKeys :=;
          { K_DOWN      , {|b| b:down()}     ,;
            K_UP        , {|b| b:up()}       ,;
            K_PGDN      , {|b| b:pageDown()} ,;
            K_PGUP      , {|b| b:pageUp()}   ,;
            K_CTRL_PGUP , {|b| b:goTop()}    ,;
            K_CTRL_PGDN , {|b| b:goBottom()} ,;
            K_RIGHT     , {|b| b:right()}    ,;
            K_LEFT      , {|b| b:left()}     ,;
            K_HOME      , {|b| b:home()}     ,;
            K_END       , {|b| b:end()}      ,;
            K_CTRL_LEFT , {|b| b:panLeft()}  ,;
            K_CTRL_RIGHT, {|b| b:panRight()} ,;
            K_CTRL_HOME , {|b| b:panHome()}  ,;
            K_CTRL_END  , {|b| b:panEnd()}    }

   // Search into array
   nFound := ASCAN(aKeys, nKey)
   IF (nFound != 0)
      EVAL(aKeys[++nFound], oObj)

   ENDIF
   RETURN (nFound != 0)

/* Scroll Bars */
#define     BARCOLOR        "W/W"
#define     BUTTONCOLOR     "N/W"

/*****
 *
 * Vertical Scroll Bar
 *
 */

STATIC FUNCTION DbfVertScrollBar(nTop, nBottom, nRight)
   STATIC lIsStart := .T.
   STATIC nWindow, nInitPos, nNewPos

   DISPBEGIN()
   // First time
   IF lIsStart
      lIsStart := .F.
      nWindow  := nBottom - nTop
      nInitPos := 0
      @ nTop,nRight,nBottom,nRight BOX CHR(219) ;
                                   COLOR BARCOLOR
      @ nTop,nRight SAY CHR(219) COLOR BUTTONCOLOR

   ENDIF

   // Update Bar Gauge
   nNewPos := nWindow / (LASTREC() / RECNO())
   IF ( RECNO() == 1 )
      nNewPos := 0

   ELSEIF ( RECNO() == LASTREC() )
      nNewPos := nWindow

   ENDIF

   IF ( nInitPos != nNewPos )
      @ nTop + nInitPos,nRight SAY ;
                   CHR(219) COLOR BARCOLOR
      @ nTop + nNewPos, nRight SAY ;
                   CHR(219) COLOR BUTTONCOLOR
      nInitPos := nNewPos

   ENDIF
   DISPEND()

   RETURN (NIL)

/*****
 *
 * Horizontal Scroll Bar
 *
 */

STATIC FUNCTION BrowHorizScrollBar(obj, nBottom, nLeft, nRight)

   STATIC lIsStart := .T.
   STATIC nWindow, nInitPos, nNewPos

   DISPBEGIN()
   // First time
   IF lIsStart
      lIsStart := .F.
      nWindow  := nRight - nLeft
      nInitPos := 0
      @ nBottom,nLeft,nBottom,nRight BOX CHR(219) ;
                                     COLOR BARCOLOR
      @ nBottom,nLeft SAY CHR(219) COLOR BUTTONCOLOR

   ENDIF

   // Update Bar Gauge
   nNewPos := nWindow / (obj:colCount / obj:colPos)
   IF ( obj:colPos == 1 )
      nNewPos := 0

   ELSEIF ( obj:colCount == obj:colPos )
      nNewPos := nWindow

   ENDIF

   IF ( nInitPos != nNewPos )
      @ nBottom,nLeft + nInitPos SAY ;
                   CHR(219) COLOR BARCOLOR
      @ nBottom,nLeft + nNewPos  SAY ;
                   CHR(219) COLOR BUTTONCOLOR
      nInitPos := nNewPos

   ENDIF
   DISPEND()
   RETURN (NIL)

// EOF - TBR13.PRG //
