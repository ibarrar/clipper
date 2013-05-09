/*****
 *
 * GET1.PRG
 *
 *
 * Compile: Clipper get1 /N /W
 * Link:    RTLINK FI Get1
 *
 */

FUNCTION Main()
   LOCAL o
   LOCAL cVar := "This is a Get Object" + SPACE(20)
   LOCAL cScreen

   // Create the Get object
   // Using GetNew( nRow, nCol, bBlock, cName, cPict, cColour )
   // It will return a new Get object with the row, col, block,
   // name, picture and colorSpec instance variables set
   // from the suplied arguments

   // You can also create the Get object and assign instance
   // variables:
   // o := GetNew()
   // o:row := 10
   // o:col := 10
   // o:block := {|x| IF(x == NIL, cVar, cVar := x)}

   o := GetNew( 10, 10, {|x| IF(x == NIL, cVar, cVar := x)} )

   // Build the screen
   cScreen := savescreen()
   SETCOLOR("BG/B,W+/GB,,,BG/B")
   SCROLL()

   // In order to edit the Get you should give it input focus
   // For this purpose you have:
   // get:setFocus()
   // Upon receiving this message, the Get object creates and
   // initializes its internal state information, including the
   // exported instance variables: get:buffer, get:pos,
   // get:decPos, get:original. The contents of the editing
   // buffer are then displayed using the selected colour
   o:setFocus()

   // Wait for a key
   INKEY(0)
   // Bye!
   restscreen(,,,,cScreen)
   RETURN (NIL)

// EOF - GET1.PRG //
