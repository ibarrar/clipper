/***
*
*  Asrtdemo.prg
*
*  Sample program to demostrate assertions for error checking
*
*  Copyright (c) 1993, Computer Associates International Inc.
*  All rights reserved.
*
*  Assertions are used to verify conditions that must be true
*  for a function to work (or to verify that a function has
*  worked). This simple test program takes two integers as
*  command line parameters. It compares them numerically and
*  displays a symbol representing the relationship between
*  them. The function uses assertions to verify that the
*  command line parameters are present and that they are
*  valid integer values.
*
*  Note: compile with /n
*
*/

#include "Assert.ch"


/***
*
*  AssertTest( cNum1, cNum2 )
*
*  Convert parameters to numeric values and show the relationship
*  between them
*
*  Parameters:
*     cNum1 - Character string form (e.g. "10") of a number
*     cNum2 - Second string of a number to be converted to a numeric type
*
*/
PROCEDURE AssertTest( p1, p2 )

   LOCAL n

   // Fail if 2 params were not supplied
   ASSERT ( PCOUNT() == 2, "requires two params" )

   // Fail if params don't begin with numeric characters
   ASSERT ( ISDIGIT( p1 ) .AND. ISDIGIT( p2 ) )

   // Everything looks good, compare the values
   n = VAL( p1 ) - VAL( p2 )

   IF (n == 0)
      ?? "="
   ELSEIF (n > 0)
      ?? ">"
   ELSEIF (n < 0)
      ?? "<"
   ELSE
      // Something must have gone haywire, force a failure
      ASSERT ( .F., "This can't happen but it did!" )
   END

   RETURN
