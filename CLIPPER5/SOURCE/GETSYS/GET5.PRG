/*****
 *
 * GET5.PRG
 * Access GetList directly
 *
 * Clipper get5 /W /N
 * RTLINK FILE get5
 *
 */

 // Unless you declare it in another way
// GetList will be created as PUBLIC
//
MEMVAR GetList

FUNCTION Main()
   // Your GET variables
   LOCAL cVar1, cVar2, cVar3
   LOCAL cScreen

   cScreen := savescreen()

   cVar1 := SPACE(30)
   cVar2 := SPACE(20)
   cVar3 := SPACE(30)

   // Get It!
   SCROLL()
   @ 10,10 SAY "cVar1: " GET cVar1
   @ 15,10 SAY "cVar2: " GET cVar2 WHEN SetPict()
   @ 20,10 SAY "cVar3: " GET cVar3
   READ

   restscreen(,,,,cScreen)
   RETURN (NIL)

FUNCTION SetPict()
   // Array with the PICTUREs
   LOCAL aPicts := { "@!",;
                    "@!AAAAA99999",;
                    "@R 999-9999-999",;
                    "999.999,99",;
                    "@R 99/AAA-99.9/A9",;
                    "@!A",;
                    "@R AA-9999-AA-99" }

   LOCAL cScr, cClr, nChoice

   // Save
   cScr := SAVESCREEN( 0, 5, 8, 26 )
   cClr := SETCOLOR("B+/N,GR+/W")

   // Screen
   @  0, 5 CLEAR TO  8,26
   @  0, 5 TO  8,26 DOUBLE

   // What is your favorite Picture
   nChoice := ACHOICE( 1, 6, 7, 25, aPicts )
   IF nChoice != 0
      GetList[2]:picture := aPicts[nChoice]

   ENDIF

   // Back
   RESTSCREEN( 0, 5, 8, 26, cScr )
   SETCOLOR(cClr)

   RETURN (.T.)

// EOF - GET5.PRG //
