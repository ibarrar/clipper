/***
*
*  Dbunet.prg
*
*  DBU Network Support Routines
*
*  Copyright (c) 1990-1993, Computer Associates International Inc.
*  All rights reserved.
*
*/

#include "common.ch"
#define NET_WAIT  1


/***
*
*  ErrMsg( <cMsg>, [<acChoices>] ) --> nChoice
*
*  Dialog box mechanism that displays cMsg and presents the choices
*  acChoices to the user
*
*  Parameters:
*     cMsg      - The message to display to the user; multiple line messages
*                 can be used by delimiting them with a semicolon (;)
*
*     acChoices - Optional array of character strings that represent the
*                 user's choices; if acChoices is not specified, the single
*                 choice "Ok" is displayed
*
*  Returns:
*     The element number of acChoices that the user selects
*
*/
FUNCTION ErrMsg( cMsg, acChoices )
   RETURN ( ALERT( cMsg, acChoices ) )



/***
*
*  NetMode( [<lOpenMode>] ) --> lFilesOpenedShared
*
*  Determines the default file opening mode of DBU
*
*  Parameter:
*     lOpenMode - If passed, determines new opening mode:
*                 .T. - Open files shared (default)
*                 .F. - Open files exclusive
*
*  Returns: The current default file opening mode of DBU
*
*/
FUNCTION NetMode( lNewMode )
   
   STATIC lOpenMode := .T.
   RETURN ( IIF( lNewMode != NIL, lOpenMode := lNewMode, lOpenMode ))



/***
*
*  NetUse( <cDatabase>, [<lOpenMode>], [<nWaitSeconds>], 
*          [<cAlias>], [<lNoAlert>] ) --> lSuccess
*
*  Attempt to USE a database file with optional retry
*
*  Parameters:
*     cDatabase    - The name of the database to open
*
*     lOpenMode    - Mode to open file in: True opens file for exclusive
*                    use, False opens file for shared use (Defaults to
*                    shared if NetMode() is true, else exclusive)
*
*     nWaitSeconds - Number of seconds to retry a failed attempt (defaults
*                    to NET_WAIT)
*
*     cAlias       - Optional alias to use for this database (defaults
*                    to the filename)
*
*     lNoAlert     - If true, disables the notification of a failed attempt
*                    to the user
*
*  Returns:
*     True if the database was successfully opened, otherwise false
*
*/
FUNCTION NetUse( cDatabase, lOpenMode, nSeconds, cAlias, lNoAlert )
   
   LOCAL cErrMsg        // Error message to display
   LOCAL lForever       // Variable to determine infinite retry
   LOCAL lRet := .F.    // Return value, assume the worst

   DEFAULT lOpenMode TO !NetMode()  // Open in mode determined by NetMode()
   DEFAULT nSeconds  TO NET_WAIT    // Retry for two seconds by default
   DEFAULT cAlias    TO MakeAlias( cDatabase )  // Default alias to db name
   DEFAULT lNoAlert  TO .F.         // Enable alert by default

   cErrMsg := "Unable to open file in;" + ;
              IIF( lOpenMode, "exclusive", "shared" ) + " mode"

   lForever := ( nSeconds == 0 )    // Retry forever if nSeconds is zero

   WHILE ( lForever .OR. ( nSeconds > 0 ))
      
      IF lOpenMode
          USE ( cDatabase ) ALIAS ( cAlias ) EXCLUSIVE
      ELSE
          USE ( cDatabase ) ALIAS ( cAlias ) SHARED
      ENDIF

      IF !NETERR()                // If successful, let's get out of here
         lRet := .T.
         EXIT
      ENDIF

      INKEY(1)                    // Wait 1 second
      nSeconds--

      //
      // Give user the choice to abort or retry if error alerting is
      // enabled, we're not trying forever, and our wait period is up
      //
      IF ( !lNoAlert .AND. !lForever .AND. ( nSeconds <= 0 ))
         IF ( ErrMsg( cErrMsg, { "Abort", "Retry" } ) == 2 )
            nSeconds := NET_WAIT
         ENDIF
      ENDIF

   ENDDO

   RETURN ( lRet )



/***
*
*  NetPack() --> lSuccess
*
*  Networking routine for performing PACK with error handling
*
*  Returns true if the PACK was successful, otherwise false
*
*/
FUNCTION NetPack()
   
   LOCAL lRet := .F.    // Return value of NetPack()
   
   // If we have exclusive of the file already, we can just PACK here
   IF !NetMode()
      PACK
      lRet := .T.
   ELSE
      
      //
      // We need to reopen exclusive, pack, then reopen shared since
      // we're in network mode
      //
      IF !NetUse( cur_dbf, .T., NIL, NIL, .T. )
         ErrMsg( "PACK failed;Unable to obtain exclusive use of file" )
      ELSE
         PACK
         IF NetUse( cur_dbf, NIL, NIL, NIL, .T. )
            lRet := .T.    // Operation was successful
         ELSE
            // This should never happen!
            ErrMsg( "Unable to reopen file after PACK;The database is closed" )
         ENDIF
      ENDIF

   ENDIF

   RETURN ( lRet )



/***
*
*  NetZap() --> lSuccess
*
*  Networking routine for performing ZAP with error handling
*
*  Returns true if the ZAP was successful, otherwise false
*
*/
FUNCTION NetZap()
   
   LOCAL lRet := .F.    // Return value of NetZap()
   
   // If we have exclusive of the file already, we can just ZAP here
   IF !NetMode()
      ZAP
      lRet := .T.
   ELSE
      
      //
      // We need to reopen exclusive, zap, then reopen shared since
      // we're in network mode
      //
      IF !NetUse( cur_dbf, .T., NIL, NIL, .T. )
         ErrMsg( "ZAP failed;Unable to obtain exclusive use of file" )
      ELSE
         ZAP
         IF NetUse( cur_dbf, NIL, NIL, NIL, .T. )
            lRet := .T.    // Operation was successful
         ELSE
            // This should never happen!
            ErrMsg( "Unable to reopen file after ZAP;The database is closed" )
         ENDIF
      ENDIF

   ENDIF

   RETURN ( lRet )



/***
*
*  NetAppBlank( [<nWaitSeconds>] ) --> lSuccess
*
*  Networking routine for APPENDing a BLANK record with error handling
*
*  Parameter:
*     nWaitSeconds - Optional number of seconds to retry a failed attempt
*                    (defaults to NET_WAIT)
*
*  Returns:
*     True if a record is successfully appended and locked, otherwise false
*
*/
FUNCTION NetAppBlank( nWaitSeconds )
   
   LOCAL lForever          // Variable to determine infinite retry
   LOCAL lRet    := .F.    // Return value, .T. indicating successful
   LOCAL cErrMsg := "Unable to append new record"  // Error message text

   DEFAULT nWaitSeconds TO NET_WAIT
   lForever := ( nWaitSeconds == 0 )

   WHILE ( lForever .OR. ( nWaitSeconds > 0 ))
      
      APPEND BLANK
      IF !NETERR()
         lRet := .T.
         EXIT
      ENDIF

      INKEY(.5)         // Wait 1/2 second
      nWaitSeconds -= .5

      // Give user the choice to abort or retry
      IF ( !lRet .AND. !lForever .AND. ( nWaitSeconds <= 0 ))
         IF ( ErrMsg( cErrMsg, { "Abort", "Retry" } ) == 2 )
            nWaitSeconds := NET_WAIT
         ENDIF
      ENDIF

   ENDDO

   RETURN ( lRet )



/***
*
*  NetRLock( [<nWaitSeconds>] ) --> lSuccess
*
*  Networking function to obtain a record lock (includes error handler)
*
*  Parameters:
*     nWaitSeconds - Optional number of seconds to attempt a record lock
*                    (defaults to NET_WAIT)
*
*  Returns:
*     True if a record was optained, otherwise false
*
*/
FUNCTION NetRLock( nWait )
   
   LOCAL lForever          // Variable to determine infinite retry
   LOCAL lRet    := .T.    // Return value, .T. indicating successful
   LOCAL cErrMsg := "Unable to obtain a record lock"  // Error message text

   DEFAULT nWait TO NET_WAIT
   lForever := ( nWait == 0 )

   WHILE ( NetMode() .AND. ( lForever .OR. ( nWait > 0 )))
      
      IF RLOCK()
         EXIT
      ENDIF

      INKEY( .5 )          // Wait 1/2 second
      nWait -= .5

      // Give user the choice to abort or retry
      IF ( !lForever .AND. ( nWait <= 0 ))
         IF ( ErrMsg( cErrMsg, { "Abort", "Retry" } ) == 2 )
            nWait := NET_WAIT
         ELSE
            lRet := .F.
         ENDIF
      ENDIF

   ENDDO

   RETURN ( lRet )




/***
*        Service routines
*/


/***
*
*  MakeAlias( cString ) --> cAliasName
*
*  Takes cString and parses it, removing drive, path, and extension
*  information, returning only the filename
*
*  Parameters:
*     cString - The string to parse
*
*  Returns: The filename contained in cString
*
*/
FUNCTION MakeAlias( cString )

   LOCAL nPos     // Used to locate position of search characters in string

   // Strip out the drive and path information, if any
   IF (( nPos := MAX( MAX( 0, RAT( "\", cString )), RAT( ":", cString ))) != 0 )
      cString := SUBSTR( cString, ++nPos )
   ENDIF

   // Strip out the extension information, if any
   IF (( nPos := RAT( ".", cString )) != 0 )
      cString := SUBSTR( cString, 1, --nPos )
   ENDIF

   RETURN ( cString )
