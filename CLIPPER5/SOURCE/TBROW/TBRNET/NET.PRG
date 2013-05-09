/*****
 *
 * NET.PRG
 *
 * Clipper net /N /W
 *
 */

#include "inkey.ch"
#include "error.ch"
#include "setcurs.ch"
#include "fileio.ch"
#include "net.ch"

/*****
 *
 * Error while opening database
 *
 * Used in lieu of NetUse()
 *
 */

FUNCTION OpenDBF( e, bHandler )
   IF (e:genCode == EG_OPEN .AND.;
       e:osCode == OS_SHARING_ERROR .AND.;
       e:canRetry .AND. e:tries < MAX_NOF_ATTEMPTS)
       //
       // Perhaps you decide to include a message...
       //
       INKEY(WAIT_TO_RETRY)
       RETURN (.T.)

   ENDIF

   // NOTE!
   e:canDefault := .F.
   e:canRetry   := .F.

   RETURN EVAL( bHandler, e )

/*****
 *
 * Record Locking
 *
 */

FUNCTION RecLock( nRetry )
   LOCAL lForever
   LOCAL lRet := .T.

   nRetry   := IF(nRetry == NIL, MAX_NOF_ATTEMPTS, nRetry)
   lForever := (nRetry == 0)

   WHILE !RLOCK() .AND. ((nRetry > 0 .OR. lForever))
      IF Msg( MSG_TRY_LOCK_REC ) == K_ESC
         EXIT

      ENDIF
      nRetry--

   END

   IF !RLOCK()
      Msg( MSG_LOCK_NO_SUCCESS )
      lRet := !lRet

   ENDIF

   RETURN (lRet)

/*****
 *
 * Messages
 * Our standard is to place messages at MAXROW(), 0
 *
 * You may or may not want to keep this function
 * as STATIC
 *
 */

STATIC FUNCTION Msg( cText, nTime )
   LOCAL nKey

   nTime := IF(nTime == NIL, MSG_TIME, nTime)

   // Save
   PushScr()

   SETBLINK(.F.)

   // Perhaps message color can be another parameter...
   @ MAXROW(), 0 SAY PADR( cText, MAXCOL() + 1 ) ;
                    COLOR MSG_COLOR
   nKey := INKEY(nTime)

   // Restore
   PopScr()

   RETURN (nKey)

/*****
 *
 * Opens a Semaphore
 *
 */

FUNCTION OpenSemaphore( cFile, nRetry, nMode )
   LOCAL nHandle, lForever

   nRetry := IF(nRetry == NIL, MAX_NOF_ATTEMPTS, nRetry)
   lForever := (nRetry == 0)
   nMode := IF(nMode == NIL, FO_READWRITE + FO_EXCLUSIVE,;
                             nMode )

   WHILE (nRetry > 0 .OR. lForever)
      nHandle := FOPEN( cFile, nMode )
      IF nHandle >= 0
         EXIT

      ENDIF
      IF Msg( MSG_TRY_LOCK_SEMAPH + cFile ) == K_ESC
         EXIT

      ENDIF
      nRetry--

   END

   IF nHandle < 0
      Msg( MSG_NO_SEMAPH_LOCK + cFile )

   ENDIF

   RETURN (nHandle)

// EOF - NET.PRG //
