/*****
 *
 * MANAGMIS.PRG
 * Miscellaneous functions
 *
 *
 * RMAKE manager
 *
 */

#include "inkey.ch"
#include "manager.ch"

/*****
 *
 * Cursor Movement Methods
 * for TBrowse Objects
 *
 */

FUNCTION TBMoveCursor( nKey, oObj )
   LOCAL nFound
   STATIC aKeys :=;
      {  K_DOWN     , {|b| b:down()}     ,;
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
   RETURN (nFound != 0)     // .T. or .F.

/*****
 *
 * Bottom line
 *
 */

FUNCTION BottLine()
   LOCAL nMaxRow := MAXROW()

   // I really love this COLOR clause
   DISPBEGIN()
   @ nMaxRow, 0 SAY SPACE(80) COLOR "N/BG"
   @ nMaxRow, 0 SAY "1"  COLOR "W/N"
   @ nMaxRow, 8 SAY "2"  COLOR "W/N"
   @ nMaxRow,16 SAY "3"  COLOR "W/N"
   @ nMaxRow,24 SAY "4"  COLOR "W/N"
   @ nMaxRow,32 SAY "5"  COLOR "W/N"
   @ nMaxRow,40 SAY "6"  COLOR "W/N"
   @ nMaxRow,48 SAY "7"  COLOR "W/N"
   @ nMaxRow,56 SAY "8"  COLOR "W/N"
   @ nMaxRow,64 SAY "9"  COLOR "W/N"
   @ nMaxRow,72 SAY "10" COLOR "W/N"
   DISPEND()
   RETURN (NIL)

/*****
 *
 * Ok Box
 *
 * If you need a nice Ok box, take a look on
 * my spreadsheet program. I am sure you are going
 * to find a routine better than this one!
 *
 */

FUNCTION OkBox( nTop, nLeft, aOpt, cClr )
   LOCAL nBottom, nRight, nOpt, cScr
   LOCAL nPos1, nPos2

   // I am not using MAXCOL() just because
   // this program is supposed to work ONLY
   // with 80 columns.
   // You can change the number of lines.
   cScr := SAVESCREEN( 0, 0, MAXROW(), 79)

   nOpt    := 1   // Default
   nBottom := nTop + 6
   nRight  := nLeft + LEN(aOpt.boxMessage) + 9
   nPos1   := nLeft + ((nRight - nLeft) / 2) - ;
            LEN(aOpt.boxFirstOpt)
   nPos2   := nPos1 + LEN(aOpt.boxFirstOpt) + 1

   Shadow( nTop + 1, nLeft + 2, nBottom + 1, nRight + 2 )
   cClr := SETCOLOR(IF(cClr == NIL, "N/W,N/BG", cClr))
   SCROLL( nTop, nLeft, nBottom, nRight )
   @ nTop + 1,nLeft + 3 TO nBottom - 1,nRight - 3 DOUBLE
   CentreIt(aOpt.boxTitle,    nTop + 1, nLeft, nRight )
   @ nTop + 2,nLeft + 5 SAY aOpt.boxMessage
   CentreIt(aOpt.boxFileName, nTop + 3, nLeft, nRight )

   // Menu options
   @ nTop + 4,nPos1 PROMPT aOpt.boxFirstOpt
   @ nTop + 4,nPos2 PROMPT aOpt.boxSecondOpt
   MENU TO nOpt

   SETCOLOR(cClr)
   RESTSCREEN( 0, 0, MAXROW(), 79, cScr)
   RETURN (nOpt)

/*****
 *
 * Displays a centred string
 *
 */

FUNCTION CentreIt(cString, nLine, nCol1, nCol2)
   LOCAL nCalc

   nCalc := nCol1 + INT(((nCol2 - nCol1) -;
            LEN(cString)) / 2) + 1
   @ nLine,nCalc SAY cString

   RETURN (NIL)

/*****
 *
 * Makes a screen "shadow"
 *
 */

FUNCTION Shadow( nTop, nLeft, nBottom, nRight )
   LOCAL nShadowLen, cShadow
   cShadow := SAVESCREEN( nTop, nLeft, nBottom, nRight )
   nShadowLen := LEN(cShadow)
   RESTSCREEN( nTop, nLeft, nBottom, nRight,;
               TRANSFORM(cShadow, REPLICATE(;
               "X", nShadowLen)))
   RETURN (NIL)

/*****
 *
 * Unpads file name
 *
 */

FUNCTION UnPad( bObj )
   LOCAL cVal, cExt
   cVal := EVAL((bObj:getColumn(1)):block)
   cExt := ALLTRIM(SUBSTR(cVal, 10, 3))
   cVal := ALLTRIM(SUBSTR(cVal, 1, 8)) +;
         IF(EMPTY(cExt), "", "." + cExt)
   RETURN (cVal)

/*****
 *
 * Executes a code block while waiting
 * for a key
 *
 * There is a better version of WhatKey()
 * in the Spreadsheet program
 *
 */

FUNCTION WhatKey( nWait, bBlock)
   LOCAL nKey
   // Parameter checking
   nWait  := IF(nWait == NIL, .1, nWait)
   bBlock := IF(bBlock == NIL, {|| .F.}, bBlock)

   WHILE ((nKey := INKEY(nWait)) == 0)
      EVAL(bBlock)

   END

   RETURN (nKey)

// EOF - MANAGMIS.PRG //
