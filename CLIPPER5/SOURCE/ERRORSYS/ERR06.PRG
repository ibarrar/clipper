/*****
 *
 * ERR06.PRG
 *
 * Try to open a database file that doesn't exist
 * in the current directory
 *
 * Clipper err06 /N /W
 * RTLINK FILE err06
 *
 */

FUNCTION Main()
   SCROLL(); SETPOS( 0, 0 )

   // Open database File
   DBUSEAREA( .T.,, "cust" )  // Crash!!!!

   RETURN (NIL)

// EOF - ERR06.PRG //
