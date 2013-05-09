/*****
 *
 * ERR08.PRG
 *
 * When a database is not found, you can create it
 * from your error handler
 *
 * Clipper err08 /N /W
 * RTLINK FILE err08
 *
 */

#include "Error.ch"

#define  MSG_FILE         "Database file "
#define  MSG_SUCCESS      " was succesfully opened!"

FUNCTION Main()
   LOCAL bOldError := ERRORBLOCK( {|oErr| DBFHandler( oErr )} )

   SCROLL(); SETPOS( 0, 0 )

   DBUSEAREA( ,, "cust" )

   QOUT( "" )
   QOUT( MSG_FILE )
   QQOUT( ALIAS() )
   QQOUT( MSG_SUCCESS )
   QOUT( "" )

   ERRORBLOCK( bOldError )
   RETURN (NIL)

/*****
 *
 * DBFHandler( ErrorObject ) -> .T.
 *
 */

STATIC FUNCTION DBFHandler( oErr )
   LOCAL aCustStruct

   IF oErr:genCode == EG_OPEN .AND. ;
      oErr:filename == "cust.DBF"
      aCustStruct := {  { "LastName",  "C", 20, 0 },;
                        { "FirstName", "C", 20, 0 },;
                        { "Address",   "C", 30, 0 },;
                        { "City",      "C", 20, 0 },;
                        { "State",     "C",  2, 0 },;
                        { "Zip",       "C",  5, 0 }   }
      DBCREATE( "cust", aCustStruct )

   ENDIF
   RETURN (.T.)     // NOTE!

// EOF - ERR08.PRG //
