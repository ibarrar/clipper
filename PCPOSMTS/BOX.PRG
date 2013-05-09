#include "its.ch"

/***
*
*  BoxMenu.prg
*  Sample user-defined functions defining menus
*
*  Copyright, Nantucket Corporation, 1990
*  Jake Jacob
*
*  NOTE: compile with /n/w/a/m
*  
*/


/***
*  BoxMenu( <aMenuItems>, [<nTop>], [<nLeft>], [<nBottom>], [<nRight>], ;
*     [<cMenuTitle>], [<nChoice>], [<cBoxChars>], [<cColorString>] ) --> nChoice
*  Paint quick and simple menu inside a box with a drop shadow.
*
*  Returns a numeric value which denotes the subscript of the array
*  passed to the BoxMenu() function which holds the menu prompts.
*  One menu choice per element.
*/

/***
*  BoxShadow( <nTop>, <nLeft>, <nBottom>, <nRight> ) --> NIL
*  Draw a box shadow with see through
*
*/


/***
*  BoxMenu( <aMenuItems>, [<nTop>], [<nLeft>], [<nBottom>], [<nRight>], ;
*     [<cMenuTitle>], [<nChoice>], [<cBoxChars>], [<cColorString>] ) --> nChoice
*  Paint quick and simple menu inside a box with a drop shadow.
*
*/
FUNCTION BoxMenu( aMenuItems, nTop, nLeft, nBottom, nRight, cMenuTitle, ;
                  nChoice, cBoxChars, cMenuColor )

   LOCAL nLength := 0, cOldColor, i
   LOCAL nMenuRow, nMenuCol, lArrNotChar := .F.

   // If no array passed or will not fit on screen, return NIL
   IF aMenuItems == NIL .OR. LEN( aMenuItems ) > ( MAXROW() - 3 )
      RETURN NIL
   ENDIF

   // Check if starting choice (nChoice) was passed
   nChoice := IF( nChoice == NIL, 1, nChoice )

   // Find the longest array element (menu prompt) and check if any element
   // is not of character type.
   ASCAN( aMenuItems, { |str| nLength := MAX( nLength, LEN( str ) ), ;
                          lArrNotChar := ( VALTYPE( str ) <> "C" ) } )

   // If any element is not of character type then return NIL
   IF lArrNotChar
      RETURN NIL
   ENDIF

   // Initialize the four coordinates
   nTop    := IF( nTop == NIL, 0, nTop )
   nLeft   := IF( nLeft == NIL, 0, nLeft )
   nBottom := MIN( MAX( nTop + LEN( aMenuItems ) + 3,;
                IF( nBottom == NIL, MAXROW(), nBottom ) ), MAXROW() )
   nRight  := MIN( MAX( nLeft + nLength + 3, ;
                IF( nRight == NIL, MAXCOL(), nRight ) ), MAXCOL() )
  
   // Check if box characters and color specification was passed
   cBoxChars  := IF( cBoxChars  == NIL, "…Õª∫ºÕ»∫", cBoxChars  )
   cMenuColor := IF( cMenuColor == NIL, SETCOLOR(), cMenuColor )

   // Save the old color and set a new color
   cOldColor := SETCOLOR( cMenuColor )

   // Paint the box
   @ nTop, nLeft CLEAR TO nBottom, nRight
   @ nTop, nLeft, nBottom, nRight BOX cBoxChars

   IF cMenuTitle != NIL
        @ nTop, nLeft + 2 SAY cMenuTitle COLOR cMenuColor
   ENDIF

   // Paint the drop shadow
   BoxShadow( nTop, nLeft, nBottom, nRight )

   // Determine the starting row and column of the first menu prompt
   // so as to center the menu
   nMenuRow := nTop + INT( ( ( nBottom - nTop ) - LEN( aMenuItems ) ) / 2 ) + 1
   nMenuCol := nLeft + INT( ( ( nRight - nLeft ) - nLength ) / 2 ) + 1

   // Invoke the menu
   FOR i := 1 TO LEN( aMenuItems )
      @ nMenuRow++, nMenuCol PROMPT LEFT( aMenuItems[i] + SPACE(nLength), nLength )
   NEXT

   MENU TO nChoice

   // Reset the old color
   SETCOLOR( cOldColor )

   RETURN nChoice


/***
*  BoxShadow( <nTop>, <nLeft>, <nBottom>, <nRight> ) --> NIL
*  Draw a box shadow with see through
*
*/
FUNCTION BoxShadow( nTop, nLeft, nBottom, nRight )
   LOCAL nShadTop, nShadLeft, nShadBottom, nShadRight
   
   nShadTop   := nShadBottom := MIN(nBottom + 1, MAXROW())
   nShadLeft  := nLeft + 1
   nShadRight := MIN(nRight + 1, MAXCOL())

   RESTSCREEN( nShadTop, nShadLeft, nShadBottom, nShadRight,;
       TRANSFORM( SAVESCREEN(nShadTop, nShadLeft, nShadBottom, nShadRight),;
       REPLICATE("X", nShadRight - nShadLeft + 1 ) ) )

   nShadTop    := nTop + 1
   nShadLeft   := nShadRight := MIN(nRight + 1, MAXCOL())
   nShadBottom := nBottom

   RESTSCREEN( nShadTop, nShadLeft, nShadBottom, nShadRight,;
       TRANSFORM( SAVESCREEN(nShadTop,  nShadLeft , nShadBottom,  nShadRight),;
       REPLICATE("X", nShadBottom - nShadTop + 1 ) ) )

   RETURN NIL
