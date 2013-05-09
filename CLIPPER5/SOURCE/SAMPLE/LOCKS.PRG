/***
*
*  Locks.prg
*
*  Sample networking functions to supplant the use of USE, 
*  FLOCK(), RLOCK() and APPEND BLANK by adding additional
*  functionality
*
*  Copyright (c) 1993, Computer Associates International Inc.
*  All rights reserved.
*
*  NOTE: Compile with /a /m /n /w options
*
*/

#include "Common.ch"

#define NET_WAIT     0.5   // Seconds to wait between between retries
#define NET_SECS     2     // Number of seconds to continue retry


/***
*
*  AddRec( [<nWaitSeconds>] ) --> lSuccess
*
*  Attempt to APPEND BLANK with optional retry
*
*  Parameter:
*     nWaitSeconds - Optional time in seconds to retry operation, defaults
*                    to NET_SECS
*
*  Returns:
*     True (.T.) if successful, false (.F.) if not
*
*/
FUNCTION AddRec( nWaitSeconds )
   
   LOCAL lForever       // Retry forever?

   DEFAULT nWaitSeconds TO NET_SECS

   APPEND BLANK
   IF !NETERR()
      RETURN ( .T. )             // NOTE
   ENDIF

   lForever := ( nWaitSeconds == 0 )

   // Keep trying as long as our time's not up
   DO WHILE ( lForever .OR. ( nWaitSeconds > 0 ) )
      
      APPEND BLANK

      IF !NETERR()
         RETURN ( .T. )          // NOTE
      ENDIF

      INKEY( NET_WAIT )          // Wait NET_WAIT seconds (defined above)
      nWaitSeconds  -= NET_WAIT

   ENDDO

   RETURN ( .F. )       // Not locked



/***
*
*  FilLock( [<nWaitSeconds>] ) --> lSuccess
*
*  Attempt to FLOCK() with optional retry
*
*  Parameter:
*     nWaitSeconds - Optional time in seconds to retry operation, defaults
*                    to NET_SECS
*
*  Returns:
*     True if successful, false if not
*
*/
FUNCTION FilLock( nSeconds )
   
   LOCAL lForever    // Retry forever?

   DEFAULT nSeconds TO NET_SECS

   IF FLOCK()
      RETURN ( .T. )       // NOTE
   ENDIF

   lForever := ( nSeconds == 0 )

   // Keep trying until our time's up
   DO WHILE ( lForever .OR. ( nSeconds > 0 ) )
      
      INKEY( NET_WAIT )    // Wait NET_WAIT seconds
      nSeconds -= NET_WAIT

      IF FLOCK()
         RETURN ( .T. )    // NOTE
      ENDIF

   ENDDO

   RETURN ( .F. )          // Not locked



/***
*
*  NetUse( <cDatabase>, <lOpenMode>, [<nWaitSeconds>] ) --> lSuccess
*
*  Attempt to USE a database file with optional retry
*
*  Parameters:
*     cDatabase    - Database file to open
*     lOpenMode    - Sharing mode: True indicates EXCLUSIVE, false
*                    indicates SHARED
*     nWaitSeconds - Optional time in seconds to retry operation, defaults
*                    to NET_SECS
*
*  Returns:
*     True if successfull, false if not
*
*/
FUNCTION NetUse( cDatabase, lOpenMode, nSeconds )
   
   LOCAL lForever    // Retry forever?

   DEFAULT nSeconds TO NET_SECS
   lForever := ( nSeconds == 0 )

   // Keep trying as long as our time's not up
   DO WHILE ( lForever .OR. ( nSeconds > 0 ) )
     
     // lOpenMode determines the mode files are opened in
     IF lOpenMode       
         USE ( cDatabase ) EXCLUSIVE  
     ELSE
         USE ( cDatabase ) SHARED
     ENDIF

     IF !NETERR()
        RETURN ( .T. )     // NOTE
     ENDIF

     INKEY( NET_WAIT )     // Wait
     nSeconds -= NET_WAIT

   ENDDO

   RETURN ( .F. )          // USE fails



/***
*
*  RecLock( [<nWaitSeconds>] ) --> lSuccess
*
*  Attempt to RLOCK() with optional retry
*
*  Parameter:
*     nWaitSeconds - Optional time in seconds to retry operation, defaults
*                    to NET_SECS
*
*  Returns:
*     True if successful, false if not
*
*/
FUNCTION RecLock( nSeconds )
   
   LOCAL lForever          // Retry forever?

   DEFAULT nSeconds TO NET_SECS

   IF RLOCK()
      RETURN ( .T. )       // NOTE
   ENDIF

   lForever := ( nSeconds == 0 )

   DO WHILE ( lForever .OR. ( nSeconds > 0 ) )
      
      IF RLOCK()
         RETURN ( .T. )    // NOTE
      ENDIF

      INKEY( NET_WAIT )    // Wait 1/2 second
      nSeconds -= NET_WAIT

   ENDDO

   RETURN ( .F. )          // Not locked
