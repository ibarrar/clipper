/*****
 *
 * ERR02.PRG
 *
 * Using ERRORBLOCK() to post another codeblock
 *
 * Clipper err02 /N /W
 * RTLINK FILE err02
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
   QQOUT( nResult )            // Result: NIL  (see below)

   // Retur previous block
   ERRORBLOCK( bOldError )

   RETURN (NIL)

/*****
 *
 * HandleTheMess() -> NIL
 *
 */

STATIC FUNCTION HandleTheMess()
   RETURN (NIL)

// EOF - ERR02.PRG //
