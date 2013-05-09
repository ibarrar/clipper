/***
*
*  Iterator.prg
*
*  Sample array iteration functions
*
*  Copyright (c) 1993, Computer Associates International Inc.
*  All rights reserved.
*
*  NOTE: compile with /a /m /n /w
*
*/


/***
*
*  IEval( <nCount>, <bBlock> ) --> xValueLast
*
*  Evaluate bBlock nCount times, passing it the current iteration
*  (starting at 1)
*
*  Return the value the last iteration returns
*
*/
FUNCTION IEval( nCount, bBlock )
   
   LOCAL i              // Counter variable
   LOCAL xValResult     // Return value

   FOR i := 1 TO nCount
      xValResult := EVAL( bBlock, i )
   NEXT

   RETURN( xValResult )



/***
*
*  Collect( <aArray>, <bBlock> ) --> aResults
*
*  Evaluate bBlock on each element of aArray and store the results in 
*  aResults
*
*/
FUNCTION Collect( aArray, bBlock )
   
   LOCAL aResults[ LEN( aArray ) ]
   LOCAL nCount := 1

   AEVAL( aArray, { |element| aResults[nCount++] := EVAL( bBlock, element) } )

   RETURN( aResults )



/***
*
*  Extract( <aArray>, <bMatch> ) --> aMatches
*
*  Returns the elements in aArray that match specified criteria.  bMatch 
*  is passed on element at a time and should return .T. if element matches
*  criteria, false otherwise. 
*
*/
FUNCTION Extract( aArray, bMatch )
   
   LOCAL aResults := {}

   AEVAL( aArray, { |element| IIF( EVAL( bMatch, element),   ;
                                   AADD( aResults, element), ;
                                   NIL ) }                   ;
        )

   RETURN ( aResults )
