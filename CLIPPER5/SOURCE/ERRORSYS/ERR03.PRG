/*****
 *
 * ERR03.PRG
 *
 * Clipper err03 /N /W
 * RTLINK FILE err03
 *
 */

FUNCTION Main()
   LOCAL nValue1 := 10
   LOCAL nValue2 := 0
   LOCAL nResult

   // Error handling
   LOCAL bOldError
   bOldError := ERRORBLOCK( {|| HandleTheMess()} )

   SCROLL(); SETPOS( 0, 0 )

   // Calculating...
   nResult := nValue1 / nValue2

   // Print result
   QOUT( "Result is: " )
   QQOUT( nResult )          // Result: -876.15 (see below)

   // Return previous block
   ERRORBLOCK( bOldError )
   RETURN (NIL)

/*****
 *
 * HandleTheMess() -> -876.15
 *
 */

STATIC FUNCTION HandleTheMess()
   RETURN (-876.15)

// EOF - ERR03.PRG //
