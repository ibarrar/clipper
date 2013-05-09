/***
*
*  String.prg
*
*  Sample user-defined functions for processing character strings
*
*  Copyright (c) 1993, Computer Associate International Inc.
*  All rights reserved.
*
*  NOTE: Compile with /a /m /n /w
*
*/

#include "Common.ch"


/***
*
*  CityState( <cCity>, <cState>, <cZip> ) --> cString
*
*  Format city, state and zip variables into a single string
*
*/
FUNCTION CityState( cCity, cState, cZip )
   RETURN ( RTRIM( cCity ) + ", " + RTRIM( cState ) + "  " + cZip )



/***
*
*  ListAsArray( <cList>, <cDelimiter> ) --> aList
*
*  Convert a delimited string to an array
*
*/
FUNCTION ListAsArray( cList, cDelimiter )
   
   LOCAL nPos              // Position of cDelimiter in cList
   LOCAL aList := {}       // Define an empty array

   DEFAULT cDelimiter TO ","

   // Loop while there are more items to extract
   DO WHILE ( nPos := AT( cDelimiter, cList )) != 0
      
      // Add the item to aList and remove it from cList
      AADD( aList, SUBSTR( cList, 1, nPos - 1 ))
      cList := SUBSTR( cList, nPos + 1 )

   ENDDO
   AADD( aList, cList )                         // Add final element

   RETURN ( aList )                             // Return the array



/***
*
*  Occurs( <cSearch>, <cTarget> ) --> nCount
*
*  Determine the number of times <cSearch> is found in <cTarget>
*
*/
FUNCTION Occurs( cSearch, cTarget )
   
   LOCAL nPos
   LOCAL nCount := 0

   DO WHILE !EMPTY( cTarget )
      
      IF ( nPos := AT( cSearch, cTarget )) != 0
         nCount++
         cTarget := SUBSTR( cTarget, nPos + 1 )
      ELSE     
         // End of string
         cTarget := ""
      ENDIF

   ENDDO

   RETURN ( nCount )



/***
*
*  Proper( <cString> ) --> cProper
*
*  Capitalize each word in a string
*
*/
FUNCTION Proper( cString )
   
   LOCAL nPos
   LOCAL cWord
   LOCAL cProper := ""

   DO WHILE !EMPTY( cString )
      
      IF ( nPos := AT( " ", cString )) != 0
         cWord   := SUBSTR( cString, 1, nPos )
         cString := SUBSTR( cString, nPos + 1 )
      ELSE     
         // End of string
         cWord   := cString
         cString := ""
      ENDIF

      cProper := cProper + UPPER( SUBSTR( cWord, 1, 1 )) + SUBSTR( cWord, 2 )

   ENDDO

   RETURN ( cProper )

