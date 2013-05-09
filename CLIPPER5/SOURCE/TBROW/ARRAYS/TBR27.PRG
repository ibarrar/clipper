/*****
 *
 * TBR27.PRG
 * Modifying TBR25 to browse a multidimensional array
 *
 * Copyright (c) 1991 Computer Associates Int'l Corporation.
 *                    All Rights Reserved.
 *
 * Clipper tbr25 /N /W
 * RTLINK FILE tbr25
 *
 */

#include "inkey.ch"
#include "setcurs.ch"

#define        HSEP       CHR(205) + CHR(209) + CHR(205)
#define        CSEP       CHR(032) + CHR(179) + CHR(032)
#define        FSEP       CHR(205) + CHR(207) + CHR(205)
#define        MYCOLORS   "W+/BG,W+/B"

#xcommand      STABILIZE <obj> INKEY [TO] <x>  =>;
               DISPBEGIN();;
               WHILE (!<obj>:stabilize()) .AND.;
                    ((<x> := INKEY()) == 0);;
               END;;
               DISPEND()

#define   MAXLEN    8

FUNCTION Main()
   LOCAL b, nKey, column
   LOCAL nSubscript, cScreen, k
   LOCAL aArray := { { 12, 34 },;
                     { 28, 67 },;
                     { 72, 63 },;
                     { 33, 39 },;
                     { 51, 44 },;
                     { 27, 21 },;
                     { 89,  2 },;
                     { 0,  -1 } }

   cScreen := savescreen()
   SETCURSOR(SC_NONE)
   SETCOLOR("N/W")
   SCROLL()

   // Init
   k := 0
   nSubscript := 1

   // TBrowse object for values
   b := TBrowseNew( 1, 5, 10, 40 )
   b:skipBlock := {|x| ;
                 k := IF(ABS(x) >= IF(x >= 0,;
                 MAXLEN - nSubscript, nSubscript - 1),;
                 IF(x >= 0, MAXLEN - nSubscript,;
                 1 - nSubscript),;
                 x), nSubscript += k,;
                 k }

   b:goTopBlock    := {|| nSubscript := 1}
   b:goBottomBlock := {|| nSubscript := MAXLEN}
   b:colorSpec := MYCOLORS
   b:headSep   := HSEP
   b:colSep    := CSEP

   // One subarray per column
   column := TBColumnNew("Column #1",;
                          {|| aArray[nSubscript, 1]})
   b:addColumn( column )
   column := TBColumnNew("Column #2",;
                          {|| aArray[nSubscript, 2]})
   b:addColumn( column )

   WHILE .T.
      STABILIZE b INKEY TO nKey

      IF (b:stable)
         IF (b:hitTop .OR. b:hitBottom)
            TONE(1000,4)

         ENDIF
         nKey := INKEY(0)

      ENDIF

      IF !TbMoveCursor( nKey, b )
         IF nKey == K_ESC
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

// EOF - TBR25.PRG //
