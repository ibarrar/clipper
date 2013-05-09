#include "Inkey.ch"

*  AMax( <aArray> ) --> nPos
*  Return the subscript of the array element with the highest value.
FUNCTION AMax( aArray )
   LOCAL nLen, nPos, expLast, nElement
   DO CASE
   // Invalid argument
   CASE VALTYPE( aArray ) <> "A"
      RETURN NIL
   // Empty argument
   CASE EMPTY( aArray )
      RETURN 0
   OTHERWISE
      nLen := LEN( aArray )
      nPos := 1
      expLast := aArray[1]
      FOR nElement := 2 TO nLen
         IF aArray[nElement] > expLast
            nPos := nElement
            expLast := aArray[nElement]
         ENDIF
      NEXT
   ENDCASE
   RETURN nPos

*  AMin( <aArray> ) --> nPos
*  Return the subscript of the array element with the lowest value.
FUNCTION AMin( aArray )
   LOCAL nLen, nPos, expLast, nElement
   DO CASE
   // Invalid argument
   CASE VALTYPE( aArray ) <> "A"
      RETURN NIL
   // Empty argument
   CASE EMPTY( aArray )
      RETURN 0
   OTHERWISE
      nLen := LEN( aArray )
      nPos := 1
      expLast := aArray[1]
      FOR nElement := 2 TO nLen
         IF aArray[nElement] < expLast
            nPos := nElement
            expLast := aArray[nElement]
         ENDIF
      NEXT
   ENDCASE
   RETURN nPos

*  AComp( <aArray>, <bComp>, [<nStart>], [<nStop>] ) --> valueElement
*  Compares all elements of aArray using the bComp block from nStart to
*  nStop (if specified, otherwise entire array) and returns the result.
*  Several sample blocks are provided in Array.ch.
FUNCTION AComp( aArray, bComp, nStart, nStop )
   LOCAL value := aArray[1]
   AEVAL(                                                               ;
          aArray,                                                       ;
          {|x| value := IF( EVAL(bComp, x, value), x, value )},         ;
          nStart,                                                       ;
          nStop                                                         ;
        )
   RETURN( value )

*  Dimensions( <aArray> ) --> aDims
*  Return an array of numeric values describing the dimensions of a
*  nested or multi-dimensional array, assuming the array has uniform
*  dimensions.
FUNCTION Dimensions( aArray )
   LOCAL aDims := {}
   DO WHILE ( VALTYPE(aArray) == "A" )
      AADD( aDims, LEN(aArray) )
      aArray := aArray[1]
   ENDDO
   RETURN (aDims)
