/*****
 *
 * ERR17.PRG
 *
 * Clipper err17 /N /W
 * RTLINK FILE err17
 *
 */

#include "error.ch"

#define  MAX_NOF_ATTEMPTS    30
#define  WAIT_TO_RETRY       1
#define  DOS_SHARING_ERROR   32

FUNCTION Main()
   LOCAL bOldError

   SCROLL(); SETPOS( 0, 0 )

   bOldError := ERRORBLOCK( {|e| OpenDBF( e, bOldError )} )

   // Open file shared
   DBUSEAREA( .T., , "cust", , .T. )

   ERRORBLOCK(bOldError)
   RETURN (NIL)

/*****
 *
 * Error while opening database
 *
 * Used in lieu of NetErr()
 *
 */

FUNCTION OpenDbf( e, bHandler )
   IF (e:genCode == EG_OPEN .AND.;
      e:osCode == DOS_SHARING_ERROR .AND.;
      e:canRetry .AND. e:tries < MAX_NOF_ATTEMPTS)
      //
      // You can even insert a message here
      //
      INKEY(WAIT_TO_RETRY)
      RETURN (.T.)

   ENDIF

   // NOTE!!!
   e:canDefault := .F.
   e:canRetry   := .F.

   RETURN EVAL(bHandler, e )

// EOF - ERR17.PRG //
