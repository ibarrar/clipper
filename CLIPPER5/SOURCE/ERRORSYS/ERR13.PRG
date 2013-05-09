/*****
 *
 * ERR13.PRG
 *
 * Copying files from the
 * hard disk to a floppy disk
 * Same as err12.prg using BEGIN SEQUENCE...END
 *
 * Clipper err13 /N /W
 * RTLINK FILE err13
 *
 */

#include "Error.ch"

#define     ERR_RETRY     "Retry"
#define     ERR_ABORT     "Abort"
#define     ERR_ANOTHER   "Another drive"
#define     WHICH_DRIVE   "Enter drive letter and colon"

FUNCTION Main()
   LOCAL GetList := {}
   LOCAL cDrive := "A:"
   LOCAL nChoice
   LOCAL lCOntinue := .T.

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
         COPY FILE cust.dbf TO (cDrive + "cust.dbf")

      RECOVER USING oErr
         aErrOptions := { ERR_RETRY, ERR_ANOTHER, ERR_ABORT }
         nChoice := ALERT( oErr:filename + " - " +;
                           oErr:description, ;
                           aErrOptions )

         IF nChoice == LEN(aErrOptions)
            // Bye!
            QUIT

         ELSEIF nChoice == LEN( aErrOptions ) - 1
            // Change drive
            @ MAXROW(), 0 SAY WHICH_DRIVE ;
                          GET cDrive PICTURE "@!"
            READ
            @ MAXROW(), 0

         ENDIF
         LOOP

      END SEQUENCE

      lContinue := !lContinue

   END

   // Return previous block
   ERRORBLOCK( bOldError )
   RETURN (NIL)

/*****
 *
 * IOHandler( ErrorObject ) -> .T.
 *
 */

STATIC FUNCTION IOHandler( oErr )
   LOCAL aCustStruct, aErrOptions, nChoice

   IF oErr:genCode == EG_OPEN .AND.;
      oErr:filename == "cust.DBF"
      aCustStruct := { { "LastName",  "C", 20, 0 },;
                       { "FirstName", "C", 20, 0 },;
                       { "Address",   "C", 30, 0 },;
                       { "City",      "C", 20, 0 },;
                       { "State",     "C",  2, 0 },;
                       { "Zip",       "C",  5, 0 } }
      DBCREATE( "cust", aCustStruct )

   ELSEIF oErr:genCode == EG_CREATE
      // Break the sequence
      // The error object will be sent
      // to the RECOVER USING statement
      //
      BREAK(oErr)

   ENDIF

   // Retry failed operation
   RETURN (.T.)

// EOF - ERR13.PRG //
