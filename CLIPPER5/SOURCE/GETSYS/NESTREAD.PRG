/*****
 *
 * NESTREAD.PRG
 *
 */

FUNCTION AnyName()
   LOCAL dDate := CTOD("")
   LOCAL nValue := 0
   LOCAL GetList := {}
   LOCAL cScreen

   cScreen := savescreen()

   SET KEY -2 TO AnotherOne

   SCROLL()
   @ 10,10 SAY "Date:"  GET dDate
   @ 14,10 SAY "Value:" GET nValue PICTURE "9,999,999.99";
                                   COLOR "W+/N, N/BG"

   READ // aka ReadModal(GetList)

   restscreen(,,,,cScreen)
   RETURN (NIL)

FUNCTION AnotherOne()
   LOCAL cString := "This is a nested READ      "
   LOCAL GetList := {}

   @ 20,10 SAY "String:" GET cString COLOR "W+/N,N/BG"
   READ // aka ReadModal(GetList)

   @ 20,10

   RETURN (NIL)

// EOF- NESTREAD.PRG //
