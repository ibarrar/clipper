/*****
 *
 * MISCSPRD.PRG
 * Miscellaneous Functions
 *
 *
 */

#include "inkey.ch"
#include "setcurs.ch"
#include "error.ch"
#include "sprdsht.ch"

/*****
 *
 * Cursor Movement Methods
 *
 */

FUNCTION MoveIt( nKey, oObj )
   LOCAL  nFound
   STATIC aCursorMethods := ;
         { K_DOWN      , {|b| b:down()},;
            K_UP        , {|b| b:up()},;
            K_PGDN      , {|b| b:pageDown()},;
            K_PGUP      , {|b| b:pageUp()},;
            K_CTRL_PGUP , {|b| b:goTop()},;
            K_CTRL_PGDN , {|b| b:goBottom()},;
            K_RIGHT     , {|b| b:right()},;
            K_LEFT      , {|b| b:left()},;
            K_HOME      , {|b| b:home()},;
            K_END       , {|b| b:end()},;
            K_CTRL_LEFT , {|b| b:panLeft()},;
            K_CTRL_RIGHT, {|b| b:panRight()},;
            K_CTRL_HOME , {|b| b:panHome()},;
            K_CTRL_END  , {|b| b:panEnd()} }

   // Search into array
   nFound := ASCAN( aCursorMethods, nKey )
   IF nFound != 0
      EVAL( aCursorMethods[++nFound], oObj )

   ENDIF
   RETURN (nFound != 0)

/*****
 *
 * Wait for a key and optionally
 * executes a code block during the
 * wait time.
 *
 */

FUNCTION WhatKey( nTime, bBlock )
   LOCAL nKey
   LOCAL i

   nTime  := IF(nTime == NIL, 0, nTime)
   bBlock := IF(bBlock == NIL, {|| .F.}, bBlock)

   IF nTime == 0  // Wait for a key,
                  // aka INKEY(0)
                  //
      WHILE ((nKey := INKEY(.1)) == 0)
         EVAL(bBlock)

      END
      // Key pressed
      RETURN (nKey)

   ELSE
      // Time-out option
      i := 0
      WHILE i <= nTime
         IF ((nKey := INKEY(.1)) != 0)
            RETURN (nKey)

         ELSE
            EVAL(bBlock)

         ENDIF
         i += .1

      END
      RETURN (nKey)

   ENDIF
   // Dummy!
   RETURN (NIL)

/*****
 *
 * Creates a screen shadow
 *
 */

FUNCTION Shadow( nTop, nLeft, nBottom, nRight )
   LOCAL nShadowLen, cShadow
   cShadow := SAVESCREEN( nTop, nLeft, nBottom, nRight )
   nShadowLen := LEN(cShadow)
   RESTSCREEN( nTop, nLeft, nBottom, nRight,;
               TRANSFORM(cShadow, REPLICATE("X", nShadowLen)))
   RETURN (NIL)

/*****
 *
 * Opens the "Curtain"
 *
 */

FUNCTION RestoreCurtain( aScrSave )
   LOCAL i
   FOR i := 0 TO MAXCOL()
      RESTSCREEN( 0, i, MAXROW(), i, aScrSave[i + 1] )
      @  0, i + 1, MAXROW(), i + 1 BOX CHR(176) COLOR "W+/W"
      INKEY(.01)

   NEXT
   RETURN (NIL)

/*****
 *
 * Stores the "Curtain"
 *
 */

FUNCTION SaveCurtain()
   LOCAL i, aMainScr[MAXCOL() + 1]
   FOR i := 0 TO MAXCOL()
      aMainScr[i + 1] := SAVESCREEN( 0, i, MAXROW(), i )

   NEXT
   RETURN (aMainScr)

/*****
 *
 * Text centering function
 *
 */

Function TCenter( cStr )
Return( ( int( maxcol()/2 ) ) - ( int( len( cStr )/2 ) ) )

/*****
 *
 * Screen Backgrownd
 *
 */

FUNCTION PaintScreen()
   LOCAL nMaxCol := MAXCOLUMN
   LOCAL nMaxRow := MAXROW()
   LOCAL i
   // Begin
   DISPBEGIN()
   SETCOLOR(BACKGROUND)
   SCROLL()
   @  0, 0 SAY SPACE(MAXCOLUMN + 1) COLOR FIRSTLINE
   @  0, TCenter(PAGEHEADER) SAY PAGEHEADER COLOR FIRSTLINE
   SETCOLOR(BACKGROUND)
   SCROLL( 3, 3, 19, 77)
   // Background and its "shadows"
   SETCOLOR(ALLBLACK)
   SCROLL( 3, MAXCOLUMN - 1, nMaxRow - 4, MAXCOLUMN - 1)
   SETCOLOR(BACKGROUND)
   @  2,MAXCOLUMN - 1 SAY CHR(220)
   @ nMaxRow - 3, 2 SAY REPLICATE(CHR(223), MAXCOLUMN - 2)
   // Bar
   SETCOLOR(BARCOLOR)
   @  2, 1 SAY SPACE(MAXCOLUMN - 2)
   SCROLL( 2, 1, nMaxRow - 4, 6)
   FOR i := 1 TO MAXLEN
      @  2 + i, 1 SAY STR( i, 4, 0) + " "

   NEXT
   @  2,14 SAY "A" COLOR BARCOLOR
   @  2,25 SAY "B" COLOR BARCOLOR
   @  2,36 SAY "C" COLOR BARCOLOR
   @  2,47 SAY "D" COLOR BARCOLOR
   @  2,58 SAY "E" COLOR BARCOLOR
   @  2,69 SAY "F" COLOR BARCOLOR
   SCROLL( 3, 6, nMaxRow - 4, MAXCOLUMN - 2)
   SETCOLOR(BACKGROUND)
   DISPEND()
   RETURN (NIL)

/*****
 *
 * Do you need HELP?
 *
 */

FUNCTION NeedHelp( nTime, bBlock )
   LOCAL cScr, cClr
   LOCAL aCont := CreateButtom( 15, 46, "^Continue")

   DISPBEGIN()
   cScr := SAVESCREEN( 4, 10, 19, 64)
   Shadow( 5, 12, 18, 64)
   cClr := SETCOLOR("N/W")
   @  4,10 SAY " - " COLOR "W+/N*"
   @  4,13 SAY PADR(" Spreadsheet Info", 50);
               COLOR("N/GR*")
   SCROLL( 5, 10, 17, 62)
   @  6,13 SAY "Supported operators: ( ) + - * /"
   @  8,13 SAY "You should type formulas using LOTUS style:"
   @  9,13 SAY "    D1*A1     D21            B1+E1*C5"
   @ 10,13 SAY "    2+5       (A21+B5)/6     5.3 * 21"
   @ 12,13 SAY "A formula can be up to 30 characters long."
   @ 13,13 SAY "For numeric overflow or invalid formula, ZERO"
   @ 14,13 SAY "will be returned as result."
   SelectButtom(aCont)
   DISPEND()
   // Keep the letters running
   WHILE (WhatKey( nTime , bBlock) == 0)
      // Save your screen!
      ScreenBlanker()

   END
   PressButtom(aCont)
   SETCOLOR(cClr)
   RESTSCREEN( 4, 10, 19, 64, cScr)
   RETURN (NIL)

/*****
 *
 * "Blanks" the screen
 *
 */

FUNCTION ScreenBlanker()
   LOCAL cScr := SAVESCREEN( 0, 0, MAXROW(), MAXCOL() )
   LOCAL cClr := SETCOLOR("N/N")
   LOCAL i := 0
   LOCAL nKey

   SCROLL()
   WHILE ((nKey := INKEY(1)) == 0)
      @  i, 0 SAY SPACE(MAXCOL() + 1) COLOR "N/N"
      IF (i == MAXROW())
         i := 0

      ENDIF
      @  ++i, 0 SAY PADC( SAVEHEADER, MAXCOL() + 1) ;
               COLOR HEADCLR

   END

   SETCOLOR(cClr)
   RESTSCREEN( 0, 0, MAXROW(), MAXCOL(), cScr )
   RETURN (nKey)

// EOF - MISCSPRD.PRG //
