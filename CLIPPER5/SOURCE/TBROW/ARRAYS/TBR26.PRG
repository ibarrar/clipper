/*****
 *
 * TBR26.PRG
 *
 * Copyright (c) 1991 Computer Associates Int'l Corporation.
 *                    All Rights Reserved.
 *
 * Clipper tbr26 /N /W
 *
 */

// Header Files
#include "inkey.ch"
#include "setcurs.ch"

//                             1    2   3    4
#define     MYCOLORS         "W+/B,N/BG,W/B,W+/RB"
#define     SCROLL_BAR_BGND  "W/W"
#define     SCROLL_BUTTON    "N/W"

FUNCTION AchMenu( nTop, nLeft, nBottom, nRight, aItems,;
                  aLogic, aMsg, nMsgRow, bBlock, cClrStr )

   // AchMenu() receives the following parameters:

   // nTop, nLeft, nBottom, nRight  -  window coordinates
   // aItems  -  Array with Menu Items
   // aLogic  -  Array with .T. or .F. for each item in menu
   // aMsg    -  Array with messages for each item in menu
   // nMsgRow -  Line to display messages
   // bBlock  -  Codeblock to be executed while waiting for a key
   // cClrStr -  Color pattern (as a string)

   LOCAL b, nKey, column
   LOCAL x, k, n
   LOCAL nNewPos, nLen, nInitPos, nWindow
   LOCAL cSaveClr, lIsMsg, nWidth
   LOCAL nCursSave := SETCURSOR(SC_NONE)

   // Parameter checking
   nLen    := LEN( aItems )
   cClrStr := IF(cClrStr == NIL, MYCOLORS, cClrStr)

   lIsMsg := (VALTYPE(aMsg) == "A")
   nMsgRow := IF(nMsgRow == NIL, MAXROW(), nMsgRow)

   IF VALTYPE(aLogic) != "A"
      aLogic := ARRAY( nLen )
      AFILL( aLogic, .T. )

   ENDIF

   nInitPos := 0
   nWindow  := nBottom - nTop
   nWidth   := nRight - nLeft - 1

   bBlock := IF(bBlock == NIL, {|| .F.}, bBlock)

   // Draw the Box and Gauge
   cSaveClr := SETCOLOR(;
               SUBSTR(cClrStr, 1, AT(",",cClrStr) - 1))
   SCROLL( nTop - 1, nLeft - 1, nBottom + 1, nRight + 1 )
   @ nTop - 1, nLeft - 1 TO nBottom + 1, nRight + 1
   @ nTop,nRight + 1,nBottom,nRight + 1 BOX CHR(219) ;
                                        COLOR SCROLL_BAR_BGND
   @ nTop,nRight + 1 SAY CHR(219) COLOR SCROLL_BUTTON

   // Create a Browse Object
   b := TBrowseNew( nTop, nLeft, nBottom, nRight )
   b:colorSpec := MYCOLORS
   // n is the array subscript
   n := 1

   // Go Top and Go Bottom Blocks
   //
   // Position: First Element
   b:goTopBlock    := { || n := 1 }
   //
   // Position: Last Element
   b:goBottomBlock := { || n := nLen }
   //
   // This is our Skip Block
   //
   b:skipBlock := {|x| k := IF(ABS(x) >= IF(x >= 0,;
                          nLen - n, n - 1),;
                          IF(x >= 0, nLen - n, 1 - n),x),;
                          n += k, ;
                          k }

   // Create the column object
   column := TBColumnNew ( , {|| aItems[n] } )

   // Colors for Selectable and Unselectable Items
   column:colorBlock := {|| IF(aLogic[n], {1, 2}, {1, 3})}
   column:width      := nWidth
   //
   // About Column Width:
   //
   // When browsing array elements, you need to pay attention
   // to their size. This is very importante because TBcolumn
   // will work based in the size of the first element of
   // the array being being browsed.
   // We are assuming the width between left and right margins
   //
   b:addColumn( column )

   WHILE .T.
      ForceStable( b )

      IF ( b:hitTop .OR. b:hitBottom )
         TONE(87.3,1)
         TONE(40,3.5)

      ENDIF

      // Update Bar Gauge
      nNewPos := nWindow / (nLen / n)
      IF n == 1
         nNewPos := 0

      ELSEIF n == nLen
         nNewPos := nWindow

      ENDIF
      IF ( nInitPos != nNewPos )
         @ nTop + nInitPos,nRight + 1 SAY CHR(219) ;
                                      COLOR SCROLL_BAR_BGND
         @ nTop + nNewPos, nRight + 1 SAY CHR(219) ;
                                      COLOR SCROLL_BUTTON
         nInitPos := nNewPos

      ENDIF
      // Messages?
      IF lIsMsg
         @ nMsgRow, 0 SAY SPACE(MAXCOL() + 1) COLOR ;
           SUBSTR(cClrStr, RAT(",",cClrStr) + 1)
         @ nMsgRow, 0 SAY aMsg[n] COLOR ;
           SUBSTR(cClrStr, RAT(",",cClrStr) + 1)

      ENDIF
      WHILE ((nKey := INKEY(0.1)) == 0)
         // Evaluate a code block (if any)
         EVAL(bBlock)

      END

      IF !TBMoveCursor( nKey, b )
         // Key was not handle there
         // Lets try here
         IF ( nKey == K_ESC )
            SETCOLOR(cSaveClr)
            SETCURSOR(nCursSave)
            RETURN (0)

         ELSEIF ( nKey == K_ENTER )
            // Is the item selectable?
            IF aLogic[n]
               // If so, return array subscript for
               // the element
               SETCOLOR(cSaveClr)
               SETCURSOR(nCursSave)
               RETURN (n)

            ENDIF

         ENDIF

      ENDIF

   END
   RETURN (NIL)

/*****
 *
 * Cursor Movement Methods
 *
 */

STATIC FUNCTION TBMoveCursor( nKey, oObj )
   LOCAL nFound
   STATIC aKeys := ;
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

   nFound := ASCAN( aKeys, nKey )
   IF (nFound != 0)
      EVAL( aKeys[++nFound], oObj )

   ENDIF
   RETURN (nFound != 0)

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

// EOF - TBR26.PRG //
