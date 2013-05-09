/*****
 *
 * TIMEOUT.PRG
 * Reader with time out
 *
 */

#include "inkey.ch"
#include "setcurs.ch"
#include "getexit.ch"

#define     TIMEOUT          60

/*****
 *
 * get:reader with time-out
 *
 * EditIt(<oGet> [,<nTime>]) --> NIL
 */

FUNCTION EditIt( oGet, nTime )
   LOCAL nKey

   nTime := IF(nTime == NIL, TIMEOUT, nTime)

   IF GetPreValidate(oGet)
      // Activate the GET for reading
		oGet:setFocus()

      WHILE ( oGet:exitState == GE_NOEXIT )
         // Check for initial no editable positions
         IF oGet:typeOut
            oGet:exitState := GE_ENTER

         ENDIF

         // Apply keystrokes until exit or time out
         WHILE oGet:exitState == GE_NOEXIT
            IF ((nKey := INKEY(nTime)) != 0)
               GetApplyKey( oGet, nKey )

            ELSE
               oGet:undo()
               oGet:exitState := GE_ESCAPE

            ENDIF
            
         END

         // Disallow exit if the VALID condition 
         // is not satisfied
         IF !GetPostValidate(oGet)
            oGet:exitState := GE_NOEXIT

         ENDIF

      END

      // De-activate the GET
      oGet:killFocus()

   ENDIF

   RETURN (NIL)

// EOF - TIMEOUT.PRG //
