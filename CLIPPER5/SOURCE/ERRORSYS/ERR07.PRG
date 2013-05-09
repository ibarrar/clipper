/*****
 *
 * ERR07.PRG
 *
 * Clipper err07 /N /W
 * RTLINK FILE err07
 *
 */

#include "Error.ch"

#define  ERR_PROG_ABEND      "Program Aborted... "
#define  ERR_WHERE           "Database "
#define  ERR_WHY             " does not exist in" +;
                             " the current directory."

FUNCTION Main()
   // Error handling
   LOCAL bOldError := ERRORBLOCK( {|oErr| ErrFiles(oErr)} )

   SCROLL(); SETPOS( 0, 0 )
   bOldError := ERRORBLOCK( {|oErr| ErrFiles(oErr)} )

   // Open database file
   DBUSEAREA( ,, "cust" )

   ERRORBLOCK( bOldError )
   RETURN (NIL)

/*****
 *
 * ErrFiles( ErrorObject ) -> NIL
 *
 */

STATIC FUNCTION ErrFiles( oErr )
   IF (oErr:genCode == EG_OPEN)
      QOUT( "" )
      QOUT( ERR_PROG_ABEND )
      QOUT( ERR_WHERE )
      QQOUT( oErr:filename )
      QQOUT( ERR_WHY )
      QOUT( "" )

      QUIT   // NOTE!

   ENDIF

   RETURN (NIL)

// EOF - ERR07.PRG //
