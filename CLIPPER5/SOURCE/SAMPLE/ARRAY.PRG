/***
*
*  Array.prg
*
*  Sample array handling functions
*
*  Copyright (c) 1990-1993, Computer Associates International Inc.
*  All rights reserved.
*
*  NOTE: Compile with /a /m /n /w
*
*/

#include "Common.ch"
#include "Inkey.ch"


// Maintains the current row of ABrowse()
STATIC nRow


/***
*
*  ABrowse( <aArray> [,<nTop>][,<nLeft>][,<nBottom>][,<nRight>] ) --> xValue
*
*  Browse a 2-dimensional array using a TBrowse object
*
*  Parameters:
*     aArray  - The 2D array to browse
*     nTop    - Optional line on which to display the top margin of the browse
*     nLeft   - Optional column of the left margin of the browse
*     nRight  - Optional column of the right margin of the browse
*     nBottom - Optional line of the bottom margin of the browse
*
*  Returns: The value of the highlighted array element
*
*/
FUNCTION ABrowse( aArray, nT, nL, nB, nR )
   
   LOCAL nOldCursor     // Saves current cursor shape
   LOCAL nOldNRow       // Saves current row
   LOCAL xRet           // Return value (user's selection or NIL)
   LOCAL nKey := 0      // Keystroke holder
   LOCAL n              // FOR..NEXT counter variable
   LOCAL o              // TBrowse object

   // Preserve cursor setting, turn off cursor
   nOldCursor := SETCURSOR( 0 )

   // Preserve static var (just in case), set it to 1
   nOldNRow := nRow
   nRow     := 1


   // Assign defaults for omitted parameters
   DEFAULT nT TO 0
   DEFAULT nL TO 0
   DEFAULT nB TO MAXROW()
   DEFAULT nR TO MAXCOL()

   // Create the TBrowse object
   o := TBrowseNew( nT, nL, nB, nR )

   // This skip block just adds to (or subtracts from) nRow
   // (see aSkipTest for explanation of that function)
   o:skipBlock := { |nSkip| nSkip := ASkipTest( aArray, nRow, nSkip ), ;
                            nRow += nSkip,                             ;
                            nSkip                                      ;
                  }

   // The go top block sets nRow to 1
   o:goTopBlock := { || nRow := 1 }

   // The go bottom block sets nRow to the length of the array
   o:goBottomBlock := { || nRow := LEN( aArray ) }

   // Create column blocks and add TBColumn objects to the TBrowse
   // (see ABrowseBlock() below)
   FOR n := 1 TO LEN( aArray[1] )
     o:addColumn( TBColumnNew( "", ABrowseBlock( aArray, n )))
   NEXT

   // Main key handler loop
   DO WHILE ( nKey <> K_ESC ) .AND. ( nKey <> K_RETURN )

      // Stabilize the browse and wait for a keystroke
      o:forceStable()
      nKey := INKEY( 0 )

      // Process the directional keys
      IF o:stable

         DO CASE
         CASE ( nKey == K_DOWN )
            o:down()

         CASE ( nKey == K_UP )
            o:up()

         CASE ( nKey == K_RIGHT )
            o:right()

         CASE ( nKey == K_LEFT )
            o:left()

         CASE ( nKey == K_PGDN )
            o:right()
            o:down()

         CASE ( nKey == K_PGUP )
            o:right()
            o:up()

         CASE ( nKey == K_HOME )
            o:left()
            o:up()

         CASE ( nKey == K_END )
            o:left()
            o:down()

         ENDCASE

      ENDIF

   ENDDO


   // Set the return value
   xRet := IF( nKey == K_RETURN, aArray[nRow, o:colPos], NIL )

   // Restore the original cursor setting
   SETCURSOR( nOldCursor )

   // Restore the static var
   nRow := nOldNRow


   RETURN (xRet)



/***
*
*  ABrowseBlock( <aArray>, <nIndex> ) --> bColumnBlock
*
*  Create and return a get/set block for <aArray>[nRow, <nIndex>]
*
*  Parameters:
*     aArray - The array for which the code block is to be created
*     nIndex - The index into aArray for the code block creation
*
*  This function works by returning a block that refers
*  to local variables <a> and <x> (the parameters). In
*  version 5.01 these local variables are preserved for
*  use by the block even after the function has returned.
*  The result is that each call to ABrowseBlock() returns
*  a block which has the passed values of <a> and <x> "bound"
*  to it for later use. The block defined here also refers to
*  the static variable nRow, used by ABrowse() to track the
*  array's "current row" while browsing.
*
*/
STATIC FUNCTION ABrowseBlock( a, x )

   RETURN ( {|p| IF( PCOUNT() == 0, a[nRow, x], a[nRow, x] := p ) } )



/***
*
*  ASkipTest( <aArray>, <nCurrent>, <nSkip> ) --> nSkipsPossible
*
*  Given array <aArray> whose "current" row is <nCurrent>, determine
*  whether it is possible to "skip" forward or backward by
*  <nSkip> rows
*
*  Parameters:
*     aArray   - The array on which to perform the "skip test"
*     nCurrent - The currently selected array element
*     nSkip    - The requested number of rows to skip, negative numbers
*                meaning to "skip" backwards
*
*  Returns the number of skips actually possible
*
*/
STATIC FUNCTION ASkipTest( a, nCurrent, nSkip )

   IF ( nCurrent + nSkip < 1 )
      
      // Would skip past the top...
      RETURN ( -nCurrent + 1 )

   ELSEIF ( nCurrent + nSkip > LEN( a ) )
      
      // Would skip past the bottom...
      RETURN ( LEN(a) - nCurrent )

   END

   // No problem
   RETURN ( nSkip )



/***
*
*  ABlock( <cName>, <nSubx> ) --> bABlock
*
*  Create a get/set block for the specified array element
*
*  Parameters:
*     cName - The name of the array variable for which the code block is
*             to be created
*     nSubx - The index into the array which determines the array element
*             to use
*
*  NOTE:
*     cName must be the name of a variable that is visible
*     in macros (i.e. not a LOCAL or STATIC variable). Also, the
*     variable must be visible anywhere where the block is to be
*     used.
*
*     ABlock() may be used to make blocks for a nested array
*     by including a subscript expression as part of cName:
*
*       // to make a set/get block for a[i]
*       b := ABlock( "a", i )
*
*       // to make a set/get block for a[i][j]
*       b :=- ABlock( "a[i]", j )
*
*     This function is provided for compatibility with the
*     version 5.00 Array.prg. See the ABrowseBlock() function
*     (above) for a method of "binding" an array to a block
*     without using a macro.
*
*/
FUNCTION ABlock( cName, nSubx )

LOCAL cAXpr

   cAXpr := cName + "[" + LTRIM( STR( nSubx )) + "]"

   RETURN &( "{ |p| IF(PCOUNT()==0, " + cAXpr + "," + cAXpr + ":=p) }" )




/***
*           Array utility functions
*/


/***
*
*  AMax( <aArray> ) --> nPos
*
*  Search aArray for the position of its highest numerical value
*
*  Parameter:
*     aArray - The array to be "searched" for the highest value
*
*  Returns: The subscript of the array element with the highest value or
*           zero if an error occurred
*
*/
FUNCTION AMax( aArray )

   LOCAL nLen        // The length of aArray
   LOCAL nPos        // The position of the highest element
   LOCAL nLastExpr   // The value of the last element
   LOCAL nElement    // Loop counter variable

   DO CASE

   // The argument is not an array
   CASE VALTYPE( aArray ) <> "A"
      nPos := 0

   // The array has no elements
   CASE EMPTY( aArray )
      nPos := 0

   // If we made it this far, assume the variable's ok
   OTHERWISE
      
      nLen      := LEN( aArray )
      nPos      := 1
      nLastExpr := aArray[nPos]
      FOR nElement := 2 TO nLen
         IF ( aArray[nElement] > nLastExpr )
            
            // Make this element the current maximum and assign it to
            // nLastExpr for future comparisons
            nPos := nElement
            nLastExpr := aArray[nElement]

         ENDIF
      NEXT

   ENDCASE

   RETURN ( nPos )


/***
*
*  AMin( <aArray> ) --> nPos
*
*  Search aArray for the position of its lowest numerical value
*
*  Parameter:
*     aArray - The array to be "searched" for the minimum value
*
*  Returns: The subscript of the array element with the minimum value or
*           zero if an error occurred
*
*/
FUNCTION AMin( aArray )

   LOCAL nLen        // The length of aArray
   LOCAL nPos        // The position of the highest element
   LOCAL nLastExpr   // The value of the last element
   LOCAL nElement    // Loop counter variable

   DO CASE

   // Argument is not an array
   CASE VALTYPE( aArray ) <> "A"
      nPos := 0

   // Array is empty
   CASE EMPTY( aArray )
      nPos := 0

   // Assume we're ok
   OTHERWISE
      
      nLen      := LEN( aArray )
      nPos      := 1
      nLastExpr := aArray[nPos]
      FOR nElement := 2 TO nLen
         
         // If this element is less than previous elements, assign it as
         // the current minimum
         IF aArray[nElement] < nLastExpr
            nPos := nElement
            nLastExpr := aArray[nElement]
         ENDIF

      NEXT

   ENDCASE

   RETURN ( nPos )


/***
*
*  AComp( <aArray>, <bComp> [, <nStart>] [, <nStop>] ) --> xElementValue
*
*  Compare all elements of aArray using the bComp block from nStart to
*  nStop (if specified, otherwise entire array) and return the result.
*
*  Parameters:
*     aArray - Array to be compared
*     bComp  - Code block containing the comparison expression
*     nStart - Optional starting element to compare
*     nStop  - Optional ending element to compare
*
*  NOTE: Several sample blocks are provided in Array.ch.
*
*/
FUNCTION AComp( aArray, bComp, nStart, nStop )
   
   LOCAL xVal := aArray[1]    // Value of the element matching the condition

   AEVAL(                                                               ;
          aArray,                                                       ;
          {|x| xVal := IF( EVAL( bComp, x, xVal ), x, xVal ) },         ;
          nStart,                                                       ;
          nStop                                                         ;
        )

   RETURN( xVal )


/***
*
*  Dimensions( <aArray> ) --> aDims
*
*  Calculate the dimensions of a multi-dimensional array
*
*  Parameter:
*     aArray - Array to be calculated
*
*  Returns: An array of numeric values describing the dimensions of aArray
*
*  NOTE: Assumes aArray has uniform dimensions (i.e. is not a ragged array)
*
*/
FUNCTION Dimensions( aArray )
   
   LOCAL aDims := {}    // Array to contain the dimensions

   // We keep "traversing" the array until the first element is NOT an array
   DO WHILE ( VALTYPE( aArray ) == "A" )
      
      // Add the size of this dimension to aDims and use this array's first
      // element as the array for the next iteration of the loop
      AADD( aDims, LEN(aArray) )
      aArray := aArray[1]

   ENDDO

   RETURN ( aDims )