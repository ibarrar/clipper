/*****
 *
 * ERR12.PRG
 *
 * Copying files from the
 * hard disk to a floppy disk
 *
 * Clipper err12 /N /W
 * RTLINK FILE err12
 *
 */

#include "Error.ch"

#define     ERR_RETRY     "Retry"
#define     ERR_ABORT     "Abort"

FUNCTION Main()
   LOCAL cDrive := "A:"

   // Our error recovery routine will handle
   // two conditions:
   //
   // a) database file doesn't exist
   // b) you can't copy it to another drive
   //
   LOCAL bOldError
   bOldError := ERRORBLOCK( {|oErr| IOHandler(oErr)} )

   SCROLL(); SETPOS( 0, 0 )

   // Open database file
   DBUSEAREA( ,, "cust" )

   // Copy file to default drive ( A:)
   COPY FILE cust.dbf TO (cDrive + "cust.dbf")

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
      aErrOptions := { ERR_RETRY, ERR_ABORT }
      nChoice := ALERT( oErr:filename + " - " +;
                          oErr:description, ;
                          aErrOptions )

      IF nChoice == LEN( aErrOptions )
         // Bye!
         QUIT

      ENDIF

   ENDIF

   // Retry failed operation
   RETURN (.T.)

// EOF - ERR12.PRG //
