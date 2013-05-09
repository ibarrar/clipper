/*****
 *
 * TBR25.PRG
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

#define   MAXLEN    15

FUNCTION Main()
   LOCAL b, nKey, column
   LOCAL nSubscript, cScreen, k
   LOCAL aArray := {"Commander",;
                    "Dragon",;
                    "Excalibur",;
                    "Edinburgh",;
                    "Abbey",;
                    "Glasgow",;
                    "Inverness",;
                    "Argyll",;
                    "Dover",;
                    "London",;
                    "Coventry",;
                    "Tornado",;
                    "Harrier",;
                    "Fighter",;
                    "Typhoon" }
   LOCAL aUSA := {"Los Angeles",;
                  "San Francisco",;
                  "Seattle",;
                  "Portland",;
                  "New York",;
                  "Chicago",;
                  "Palm Springs",;
                  "Phoenix",;
                  "Santa Fe",;
                  "Apache",;
                  "Hellfire",;
                  "Sidewinder",;
                  "Eagle",;
                  "Alameda",;
                  "Indianapolis" }

   // Init
   k := 0
   nSubscript := 1

   cScreen := savescreen()
   SETCURSOR(SC_NONE)
   SETCOLOR("N/W")
   SCROLL()

   // TBrowse object for values
   b := TBrowseNew( 1, 5, 10, 40 )
   //
   // nSubscript is passed by reference
   b:skipBlock := {|x| JumpIt(x, @nSubscript)}
   b:goTopBlock    := {|| nSubscript := 1}
   b:goBottomBlock := {|| nSubscript := MAXLEN}
   b:colorSpec := MYCOLORS
   b:headSep := HSEP
   b:colSep  := CSEP

   // TBColumn Object
   column := TBColumnNew("First",{|| aUSA[nSubscript]})
   b:addColumn( column )
   column := TBColumnNew("Second",{|| aArray[nSubscript]})
   b:addColumn( column )

   WHILE .T.
      STABILIZE b INKEY TO nKey

      IF (b:stable)
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
 * Main Skipper
 *
 */

STATIC FUNCTION JumpIt(nRequest, nSubscript)
   LOCAL k := 0

   // Show current
   IF nRequest == 0
      k := 0         // When browsing databases was a matter
                    // of SKIP 0.  Return 0 and your array
                    // element will be painted on screen

   ELSEIF nRequest > 0
      // Skip forward
      // When browsing databases was a matter of SKIP. Now
      // you should return the proper array subscript
      //
      // (MAXLEN - nSubscript) is the amount of elements until
      //                       the end of the array
      //
      IF nRequest < (MAXLEN - nSubscript)
         k := nRequest

      ELSE
         k := MAXLEN - nSubscript

      ENDIF

   ELSEIF nRequest < 0
      // Skip backwards
      IF nRequest < (1 - nSubscript)
         // Skip several elements
         k := 1 - nSubscript

      ELSE
         k := nRequest

      ENDIF

   ENDIF

   // Position in the proper element
   nSubscript += k
   RETURN (k)

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
