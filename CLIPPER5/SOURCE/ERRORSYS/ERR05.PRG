/*****
 *
 * ERR05.PRG
 *
 * Working with the instance variable:
 * canSubstitute
 *
 * Clipper err05 /N /W
 * RTLINK FILE err05
 *
 */

FUNCTION Main()
   LOCAL nValue1 := 10
   LOCAL nValue2 := 0
   LOCAL nResult

   LOCAL bOldError
   bOldError := ERRORBLOCK( {|oErr| ErrHandle(oErr)} )

   SCROLL(); SETPOS( 0, 0 )

   nResult := nValue1 / nValue2

   QOUT( "Result is " )
   QQOUT( nResult )

   ERRORBLOCK( bOldError )
   RETURN (NIL)

/*****
 *
 * ErrHandle() -> -90
 *
 */

STATIC FUNCTION ErrHandle( oErr )
   oErr:canSubstitute := .F.         // NOTE!
   RETURN (-90)

// EOF - ERR05.PRG //
