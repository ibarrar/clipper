/*****
 *
 * ERR01.PRG
 *
 * Clipper err01 /N /W
 * RTLINK FILE err01
 *
 */

FUNCTION Main()
   LOCAL nValue1 := 10
   LOCAL nValue2 := 0
   LOCAL nResult

   SCROLL(); SETPOS( 0, 0 )

   // Calculating...
   nResult := nValue1 / nValue2

   // Print result
   QOUT( "Result is: " )
   QQOUT( nResult )            // Result: 0  (How?)

   RETURN (NIL)

// EOF - ERR01.PRG //

