/*****
 *
 * TBR23.PRG
 * Using TBrowse with arrays (one-dimension)
 * First example
 *
 */

#include "inkey.ch"
#include "setcurs.ch"
#include "box.ch"

#include "samples.ch"
#include "tbrowse.ch"

#define           WHAT_IT_DOES              "ESC - Quit"

FUNCTION Tbr23()
   LOCAL oBrow, oCol, nKey
   LOCAL nSubscript, cScreen

   LOCAL aArray := { "Spitfire" ,;
                     "Tornado"  ,;
                     "Harrier"  ,;
                     "Hawk"     ,;
                     "Phantom"  ,;
                     "Eagle"    ,;
                     "Victor"   ,;
                     "Vulcan"   ,;
                     "Valiant"  ,;
                     "TomCat"   ,;
                     "Prowler"  ,;
                     "Typhoon"  ,;
                     "Mustang"  ,;
                     "Hurricane",;
                     "Valkyrie"  }

   // Array subscript starts with first element
   nSubscript := 1

   cScreen := savescreen()
   SETBLINK(.F.)
   SETCURSOR(SC_NONE)
   SETCOLOR(BGND_CLR)
   SCROLL()
   DISPBOX( 1, 14, MAXROW() - 13, 31, B_SINGLE, CLR_SPEC )
   @ MAXROW(), 0 SAY PADC(WHAT_IT_DOES, MAXCOL() + 1) ;
                          COLOR MSG_ROW_CLR

   // STEP 1
   oBrow := TBROWSENEW( 2, 15, MAXROW() - 14, 30 )
   oBrow:skipBlock     := {|nReq| JumpIt(nReq, @nSubscript, aArray)}
   oBrow:goTopBlock    := {|| nSubscript := 1}
   oBrow:goBottomBlock := {|| nSubscript := LEN(aArray)}
   oBrow:colorSpec     := CLR_SPEC
   oBrow:headSep       := HEADSEP

   // STEP 2
   oCol := TBCOLUMNNEW( HEAD_ARRAY, {|| aArray[nSubscript]})
   oBrow:addColumn(oCol)

   WHILE .T.
      // STEP 3
      Force Stable(oBrow)

      // STEP 4
      nKey := INKEY(0)

      IF !TBMoveCursor( nKey, oBrow )
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

STATIC FUNCTION JumpIt(nRequest, nSubscript, aArray)
   LOCAL nActually := 0

   // Show current
   IF nRequest == 0
      nActually := 0   // When browsing databases it was a matter
                       // of SKIP 0.  Return 0 and your array
                       // element will be painted on screen

   ELSEIF nRequest > 0
      // Skip forward
      // When browsing databases was a matter of SKIP. Now
      // you should return the proper array subscript
      //
      // (LEN(aArray) - nSubscript) is the amount of elements until
      //                            the end of the array
      //
      IF nRequest < (LEN(aArray) - nSubscript)
         nActually := nRequest

      ELSE
         nActually := LEN(aArray) - nSubscript

      ENDIF

   ELSEIF nRequest < 0
      // Skip backwards
      IF nRequest < (1 - nSubscript)
         // Skip several elements
         nActually := 1 - nSubscript

      ELSE
         nActually := nRequest

      ENDIF

   ENDIF

   // Position in the proper element
   nSubscript += nActually
   RETURN (nActually)

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

// EOF - TBR23.PRG //
