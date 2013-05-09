/*****
 *
 * ERR15.PRG
 *
 * How to create an error object and how to
 * switch handlers
 *
 * Clipper err15 /N /W
 * RTLINK FILE err15
 *
 */

#include "Error.ch"

// The semi-colon will remind you a TBrowse heading...
//
#define  ALERT_REFUSE_TO_WORK   "I am sorry but I am unable;" +;
                                "to handle the error that;"   +;
                                "just happened. So, I am;"    +;
                                "going to send it back to;"   +;
                                "the default handler"

#define  ALERT_ACKNOWLEDGE      "Ok"
#define  DEFAULT_VALUE          0


FUNCTION Main()
   LOCAL bOldError, bErr, bBlock
   LOCAL nVar1, nVar2, nVar3

   nVar1 := 200
   nVar3 := 0

   // Post your handler, save the current one
   bOldError := ERRORBLOCK( ;
                {|oErr| MyHandler(oErr, bOldError)} )

   // This one is going to give us a headache!
   bBlock := {|x, y| x / y}

   SCROLL(); SETPOS( 0, 0 )

   QOUT( EVAL( bBlock, nVar1, nVar3 ) )   // Divide by zero!

   QOUT( EVAL( bBlock, nVar1, nVar2 ) )  // Divide by NIL!

   // Return to the default handler
   ERRORBLOCK( bOldError )
   RETURN (NIL)

/*****
 *
 * MyHandler( ErrorObject ) -> 0
 *
 * If your error is not handled by this function,
 * it will send it back to the default system handler
 *
 */

STATIC FUNCTION MyHandler(oErr, bOldErr)
   // Check to see if the error is the one
   // we expect
   IF oErr:genCode == EG_ZERODIV
      RETURN (DEFAULT_VALUE)

   ENDIF

   // Tell user what you are going to do...
   ALERT( ALERT_REFUSE_TO_WORK, {ALERT_ACKNOWLEDGE} )
   // Send it back...
   RETURN (EVAL( bOldErr, oErr ) )

// EOF - ERR15.PRG //
