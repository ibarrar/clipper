/*****
 *
 * ERR14.PRG
 *
 * If you select another drive and, by chance,
 * that drive is the current one, you will
 * end up copying the file onto itself.
 * Avoiding this...
 *
 * Clipper err14 /N /W
 * RTLINK FILE err14
 *
 */

#include "Error.ch"

#define     ERR_RETRY        "Retry"
#define     ERR_ABORT        "Abort"
#define     ERR_ANOTHER      "Another drive"
#define     ERR_SKIP         "Skip"
#define     ERR_OVERWRITE    "Overwrite"
#define     ERR_FILE_EXISTS  "File already exists"
#define     WHICH_DRIVE      "Enter drive letter and colon"

FUNCTION Main()
   LOCAL GetList   := {}
   LOCAL cDrive    := "A:"
   LOCAL nChoice
   LOCAL lContinue := .T.

   // Error handling
   LOCAL oErr, aErrOptions
   LOCAL bOldError
   bOldError := ERRORBLOCK( {|oErr| IOHandler(oErr)} )

   SCROLL(); SETPOS( 0, 0 )

   // Open database
   DBUSEAREA( ,, "cust" )

   // Copy file (defaults to A:)
   WHILE lContinue

      BEGIN SEQUENCE

         IF FILE( cDrive + "cust.dbf" )
            aErrOptions := { ERR_OVERWRITE, ERR_SKIP }
            nChoice := ALERT( ERR_FILE_EXISTS, aErrOptions )
            IF nChoice == 1
               COPY FILE cust.dbf TO (cDrive + "cust.dbf")

            ENDIF

         ELSE
            COPY FILE cust.dbf TO (cDrive + "cust.dbf")

         ENDIF

      RECOVER USING oErr
         aErrOptions := { ERR_RETRY, ERR_ANOTHER, ERR_ABORT }
         nChoice := ALERT( oErr:filename + " - " +;
                           oErr:description, ;
                           aErrOptions )

         IF nChoice == LEN( aErrOptions )
            // Bye!
            QUIT

         ELSEIF nChoice == LEN( aErrOptions ) - 1
            // Changing drive
            @ MAXROW(), 0 SAY WHICH_DRIVE ;
                          GET cDrive PICTURE "@!"
            READ
            @ MAXROW(), 0

         ENDIF
         LOOP

      END SEQUENCE

      lContinue := !lContinue

   END

   // Returning previous condition
   ERRORBLOCK( bOldError )
   RETURN NIL

/*****
 *
 * IOHandler(ErrorObject) -> .T.
 *
 */

STATIC FUNCTION IOHandler(oErr)
   LOCAL aCustStruct, aErrOptions, nChoice

   IF oErr:genCode == EG_OPEN .AND. ;
      oErr:filename == "cust.DBF"
      aCustStruct := { { "LastName",  "C", 20, 0 },;
                       { "FirstName", "C", 20, 0 },;
                       { "Address",   "C", 30, 0 },;
                       { "City",      "C", 20, 0 },;
                       { "State",     "C",  2, 0 },;
                       { "Zip",       "C",  5, 0 } }
      DBCREATE( "cust", aCustStruct )

   ELSEIF oErr:genCode == EG_CREATE
      BREAK(oErr)

   ENDIF

   // Retry failed operation
   RETURN (.T.)

// EOF - ERR14.PRG //
