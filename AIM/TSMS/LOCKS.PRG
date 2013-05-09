/***
*
*  Locks.prg
*  Sample network functions to supplant USE, FLOCK(), RLOCK() and
*  APPEND BLANK.
*
*  Copyright, Nantucket Corporation, 1989, 1990
*
*  Compile as follows:
*     
*	  C>CLIPPER Locks /N /W /A /M
*/


/***
*  AddRec( <nWaitSeconds> ) --> lSuccess
*  Attempt to APPEND BLANK with optional retry
*/
FUNCTION AddRec( nWaitSeconds )
   LOCAL lForever
   APPEND BLANK
   IF .NOT. NETERR()
      RETURN (.T.)
   ENDIF
   lForever = (nWaitSeconds = 0)
   DO WHILE (lForever .OR. nWaitSeconds > 0)
      APPEND BLANK
      IF .NOT. NETERR()
         RETURN .T.
      ENDIF
      INKEY(.5)         // Wait 1/2 second
      nWaitSeconds  = nWaitSeconds  - .5
   ENDDO
   RETURN (.F.)         // Not locked



/***
*  FilLock( <nWaitSeconds> ) --> lSuccess
*  Attempt to FLOCK() with optional retry
*/
FUNCTION FilLock( nSeconds )
   LOCAL lForever
   IF FLOCK()
      RETURN (.T.)      // Locked
   ENDIF
   lForever = (nSeconds = 0)
   DO WHILE (lForever .OR. nSeconds > 0)
      INKEY(.5)         // Wait 1/2 second
      nSeconds = nSeconds - .5
      IF FLOCK()
         RETURN (.T.)   // Locked
      ENDIF
   ENDDO
   RETURN (.F.)         // Not locked



/***
*  NetUse( <cDatabase>, <lOpenMode>, <nWaitSeconds> ) --> lSuccess
*  Attempt to USE a database file with optional retry
*/
FUNCTION NetUse( cDatabase, lOpenMode, nSeconds )
   LOCAL lForever
   lForever = (nSeconds = 0)
   DO WHILE (lForever .OR. nSeconds > 0)
     IF lOpenMode
         USE (cDatabase) EXCLUSIVE NEW
     ELSE
         USE (cDatabase) SHARED NEW// Shared
     ENDIF
     IF .NOT. NETERR()          // USE succeeds
        RETURN (.T.)
      ENDIF
      INKEY(1)                 // Wait 1 second
      nSeconds = nSeconds - 1
   ENDDO
   RETURN (.F.)                // USE fails



/***
*  RecLock( <nWaitSeconds> ) --> lSuccess
*  Attempt to RLOCK() with optional retry
*/
FUNCTION RecLock( nSeconds )
   LOCAL lForever
   IF RLOCK()
      RETURN (.T.)        // Locked
   ENDIF
   lForever = (nSeconds = 0)
   DO WHILE (lForever .OR. nSeconds > 0)
      IF RLOCK()
         RETURN (.T.)     // Locked
      ENDIF
      INKEY(.5)           // Wait 1/2 second
      nSeconds = nSeconds - .5
   ENDDO
   RETURN (.F.)           // Not locked

