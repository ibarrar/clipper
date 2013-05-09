/*****
 *
 * TBR24A.PRG
 * Browsing a 1-D array
 * Same as TBR24 but with generic skippers.
 *
 * Copyright (c) 1992 Computer Associates Int'l Corporation.
 *                    All Rights Reserved.
 *
 * Clipper tbr24a
 * RTLINK FILE tbr24a
 *
 */

#include "inkey.ch"
#include "setcurs.ch"

#define        HSEP       CHR(205) + CHR(209) + CHR(205)
#define        CSEP       CHR(032) + CHR(179) + CHR(032)
#define        FSEP       CHR(205) + CHR(207) + CHR(205)
#define        MYCOLORS   "W+/BG,W+/B"

FUNCTION Main()
   LOCAL b, column
   LOCAL nSubscript, cScreen
   LOCAL aArray :=;
                  { "Sidewinder",;
                    "Dragon",;
                    "Excalibur",;
                    "Hurricane",;
                    "Blowpipe",;
                    "Spitfire",;
                    "Hawk",;
                    "Vulcan",;
                    "Victor",;
                    "Valiant",;
                    "Hellcat",;
                    "Tornado",;
                    "Harrier",;
                    "Fighter",;
                    "Typhoon"    }

   // NOTE!
   nSubscript := 1

   cScreen := savescreen()
   SETCURSOR(SC_NONE)
   SETCOLOR("N/W")
   SCROLL()
   // TBrowse object for values
   b := TBrowseNew( 1, 5, 10, 20 )

   b:skipBlock     := {|x| SkipArray(x, @nSubscript, aArray)}   // NOTE!
   b:goTopBlock    := {||  GoTopArray(@nSubscript)}             // NOTE!
   b:goBottomBlock := {||  GoBottomArray(@nSubscript, aArray)}  // NOTE!

   b:colorSpec := MYCOLORS
   b:headSep := HSEP

   // TBColumn Object
   column := TBColumnNew("My Array",{|| aArray[nSubscript]})
   b:addColumn( column )

   BrowseArray(b)

   SCROLL()

   restscreen(,,,,cScreen)
   RETURN (NIL)

/*****
 *
 * Browse Array
 *
 */

FUNCTION BrowseArray( oObj )
   LOCAL nKey

   WHILE .T.
      nKey := IncrStable( oObj )

      IF !TbMoveCursor( nKey, oObj )
         IF nKey == K_ESC
            EXIT

         ENDIF

      ENDIF

   END

   RETURN (.T.)

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
 * IncrStable() -> nKeyCode
 *
 * Incremental stabilization
 *
 */

FUNCTION IncrStable( oObj )
   WHILE NEXTKEY() == 0 .AND. !oObj:stabilize()
   END

   RETURN (INKEY())

/*****
 *
 * Skippers
 *
 */

FUNCTION GoTopArray(nSubscript)
   // By reference
   nSubscript := 1
   RETURN (NIL)

FUNCTION GoBottomArray(nSubscript, aArray)
   // By reference
   nSubscript := LEN(aArray)
   RETURN (NIL)

FUNCTION SkipArray( nRequest, nSubscript, aArray)
   LOCAL nActually

   nActually := IF(ABS(nRequest) >= IF(nRequest >= 0,;
                  LEN(aArray) - nSubscript, nSubscript - 1),;
                    IF(nRequest >= 0, LEN(aArray) - nSubscript,;
                       1 - nSubscript),;
                          nRequest)

   nSubscript += nActually

   RETURN(nActually)

// EOF - TBR24A.PRG //
