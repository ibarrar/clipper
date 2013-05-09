/*****
 *
 * ERR04.PRG
 *
 * Looking deep inside...
 *
 * Clipper err04 /N /W
 * RTLINK FILE err04
 *
 */

FUNCTION Main()
   LOCAL nValue1 := 10
   LOCAL nValue2 := 0
   LOCAL nResult

   // Error handling
   LOCAL bOldError
   bOldError := ERRORBLOCK( {|oErr| ErrHandle(oErr)} )

   SCROLL(); SETPOS( 0, 0 )

   // Calculating...
   nResult := nValue1 / nValue2

   // Print the result
   QOUT( "Result is " )
   QQOUT( nResult )

   // Return previous block
   ERRORBLOCK( bOldError )
   RETURN (NIL)

/*****
 *
 * ErrHandle() -> 0
 *
 */

STATIC FUNCTION ErrHandle( oErr )

   QOUT( "" )

   QOUT( "Args          : " ); QQOUT( oErr:args )
   QOUT( "canDefault    : " ); QQOUT( oErr:canDefault )
   QOUT( "canRetry      : " ); QQOUT( oErr:canRetry )
   QOUT( "canSubstitute : " ); QQOUT( oErr:canSubstitute )
   QOUT( "cargo         : " ); QQOUT( oErr:cargo )
   QOUT( "description   : " ); QQOUT( oErr:description )
   QOUT( "filename      : " ); QQOUT( oErr:filename )
   QOUT( "genCode       : " ); QQOUT( oErr:genCode )
   QOUT( "operation     : " ); QQOUT( oErr:operation )
   QOUT( "osCode        : " ); QQOUT( oErr:osCode )
   QOUT( "severity      : " ); QQOUT( oErr:severity )
   QOUT( "subCode       : " ); QQOUT( oErr:subCode )
   QOUT( "subSystem     : " ); QQOUT( oErr:subSystem )
   QOUT( "tries         : " ); QQOUT( oErr:tries )

   QOUT( "" )

   RETURN (0)

// EOF - ERR04.PRG //
