/*****
 *
 * GET6.PRG
 * Uses GetActive() to produce a dynamic PICTURE
 *
 * Clipper get6 /N /W
 * RTLINK FILE get6
 *
 */

FUNCTION TestPict()
   // Declare your Get array
   LOCAL GetList := {}
   //
   // Array with the PICTUREs
   LOCAL aPicts := { "@!",;
                    "@!AAAAA99999",;
                    "@R 999-9999-999",;
                    "999.999,99",;
                    "@R 99/AAA-99.9/A9",;
                    "@!A",;
                    "@R AA-9999-AA-99" }

   // Variables to GET
   LOCAL nVar1 := 0
   LOCAL cVar1 := SPACE(10)
   LOCAL dVar3 := CTOD("")
   LOCAL cScreen

   cScreen := savescreen()

   // Screen
   SETCOLOR("BG/B,W+/RB,,,GR+/R")
   SCROLL()

   @ 10,10 SAY "Picture Type cVar1: " GET nVar1 ;
         WHEN PickAPict(aPicts) PICTURE "9"
   @ 12,10 SAY "cVar1: " GET cVar1 WHEN ThePict(aPicts[nVar1])
   @ 14,10 SAY "dVar3: " GET dVar3 PICTURE "@E"
   READ

   restscreen(,,,,cScreen)
   RETURN (NIL)

FUNCTION PicKAPict(aPicts)
   LOCAL cScr, cClr, nChoice

   // Save
   cScr := SAVESCREEN( 0, 5, 8, 26 )
   cClr := SETCOLOR("B+/N,GR+/W")

   // Screen
   SCROLL( 0, 5, 8, 26 )
   @  0, 5 TO  8,26 DOUBLE

   // What is your favorite Picture
   nChoice := ACHOICE( 1, 6, 7, 25, aPicts )
   IF nChoice != 0
      KEYBOARD STR(nChoice,1)

   ENDIF

   // Back
   RESTSCREEN( 0, 5, 8, 26, cScr )
   SETCOLOR(cClr)

   RETURN (.T.)  // Or our WHEN will not be completed

FUNCTION ThePict( cPict )
   //
   // Use GetActive() which returns a REFERENCE
   // to the current Get object to send a message
   // to assign the picture instance variable
   //
   GetActive():picture := cPict
   RETURN (.T.)

// EOF - GET6.PRG //

