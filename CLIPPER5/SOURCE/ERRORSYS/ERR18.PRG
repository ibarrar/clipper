/*****
 *
 * ERR18.PRG
 *
 * Clipper err18 /N /W
 * RTLINK FILE err18
 *
 */

#include "error.ch"

#define  MAX           30
#define  ABORT         2
#define  STR_TO_PRT    "This is a printer test"
#define  ERR_MSG       "Your printer has a problem..."
#define  ERR_CONTINUE  "Continue"
#define  ERR_ABORT     "Abort"

FUNCTION Main()
   LOCAL bOldError, i

   SCROLL(); SETPOS( 0, 0 )
   bOldError := ERRORBLOCK( {|e| PrintError( e, bOldError )} )

   SET( _SET_DEVICE, "PRINTER" )
   SET( _SET_PRINTER, .T. )

   BEGIN SEQUENCE
   FOR i := 1 TO MAX
      QOUT( STR_TO_PRT )

   NEXT
   END SEQUENCE

   SET( _SET_DEVICE, "SCREEN" )
   SET( _SET_PRINTER, .T. )
   ERRORBLOCK( bOldError )
   RETURN (NIL)

/*****
 *
 * Printer error
 *
 */

FUNCTION PrintError( e, bHandler )
   LOCAL nChoice

   IF (e:genCode == EG_PRINT)
      nChoice := ALERT( ERR_MSG,;
                         { ERR_CONTINUE, ERR_ABORT } )
      IF (nChoice == ABORT)
         BREAK

      ENDIF

   ENDIF
   RETURN (.T.)  // Retry

// EOF - ERR18.PRG //
