/***
*
*  Num.prg
*
*  Sample user-defined functions for manipulating numbers
*
*  Copyright (c) 1993, Computer Associates International Inc.
*  All rights reserved.
*
*  NOTE: compile with /a /m /n /w
*
*/

#define PI  ( 3.1415926535897932384626433 )


/***
*
*  BaseToBase( <cInString>, <nInBase>, <nOutBase> ) --> cNewBaseValue
*
*  Transform a string of a number from one base to another 
*  within the base range of 2 to 36
*
*  Parameters:
*     cInString - The number to convert in character string format
*     nInBase   - The base of <cInString>
*     nOutBase  - The base to covert <cInString> into
*
*  Returns:
*     <cInString> in base <nOutBase> as a character string
*
*  NOTE: Compile with /dNOARGCHECK to suppress argument checking
*
*/
FUNCTION BaseToBase( cInString, nInBase, nOutBase )
   
   LOCAL cDigits       := "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ"
   LOCAL cNewBaseValue := ""
   LOCAL i
   LOCAL DecPos
   LOCAL IntValue      := 0
   LOCAL FracValue     := 0.000000000000000000
   LOCAL FracProduct
   LOCAL FracCounter
   LOCAL IntProdStr
   LOCAL FracOutStr
   LOCAL IntOutString
   LOCAL IntStr
   LOCAL FracString
   LOCAL FracLimit
   LOCAL Block
   LOCAL LChr
   LOCAL Remainder
   LOCAL Quotient
   LOCAL NegSign

   cInString := UPPER( ALLTRIM( cInString ) )

#ifndef NOARGCHECK
   
   // Check parameters
   IF EMPTY( cInString ) .OR. VALTYPE( cInString ) <> "C" .OR. LEN( cInString ) > 19
      cNewBaseValue := NIL
   ELSE
      nInBase := IF( EMPTY( nInBase  ), 10, nInBase  )
      nOutBase := IF( EMPTY( nOutBase ), 10, nOutBase )

      IF VALTYPE( nInBase ) <> "N" .OR. VALTYPE( nOutBase ) <> "N"
         cNewBaseValue := NIL
      ELSE
         
         // Check out-of-range bases
         IF ( nInBase > 36 .OR. nOutBase > 36 .OR. nInBase < 2 .OR. nOutBase < 2 )
            cNewBaseValue := NIL
         ELSE
            i := 1

            DO WHILE i++ < LEN( cInString ) .AND. cNewBaseValue <> NIL
               IF .NOT. SUBSTR( cInString, i, 1 ) $ ( SUBSTR( cDigits, 1, nInBase ) + "." )
                  cNewBaseValue := NIL
               ENDIF
            ENDDO

         ENDIF

      ENDIF
   ENDIF

#endif

   IF cNewBaseValue <> NIL

      // Check if cInString is negative
      NegSign := IF( SUBSTR( cInString, 1, 1 ) == "-", "-", "" )
      IF .NOT. EMPTY( NegSign )
         cInString := SUBSTR( ALLTRIM( SUBSTR( cInString, 2 ) ), 2 )
      ENDIF

      // Locate the decimal
      DecPos := AT( ".", cInString )
      IntStr := IF( DecPos > 1, SUBSTR( cInString, 1, DecPos - 1 ), IF( DecPos == 1, "0", cInString ) )
      FracString := IF( DecPos > 0, SUBSTR( cInString, DecPos + 1 ), "0" )

      // Convert integer portion to base 10
      FOR i = LEN( IntStr ) TO 1 STEP -1
         IntValue += ( AT( SUBSTR( IntStr, i, 1 ), cDigits) - 1) * ( nInBase ** ( LEN( IntStr ) - i ) )
      NEXT

      // Convert fraction portion to base 10
      FOR i := 1 TO LEN( FracString )
         FracValue += ( AT( SUBSTR( FracString, i, 1 ), cDigits ) - 1 ) * ( nInBase ** ( - i ) )
      NEXT

      // Calculate output string for integer portion
      Quotient     := IntValue
      IntOutString := ""

      DO WHILE Quotient <> 0
         Remainder    := Quotient % nOutBase
         Quotient     := INT( Quotient / nOutBase )
         IntOutString := SUBSTR( cDigits, Remainder + 1, 1 ) + IntOutString
      ENDDO

      IntOutString := IF( EMPTY( IntOutstring ), "0", IntOutString )

      // Calculate output string for fraction portion
      FracLimit   := 19 - DecPos
      FracProduct := FracValue
      FracCounter := 1
      FracOutStr  := ""

      // If the following WHILE condition is replaced with
      // FracCounter++ < FracLimit .AND. FracProduct < 0.00000000000001
      // then there is no need for execute the block to get rid of
      // trailing zeros.

      DO WHILE FracCounter++ < FracLimit .AND. FracProduct <> 0
         IntProdStr  := FracProduct * nOutBase
         FracOutStr  := FracOutStr + SUBSTR( cDigits, INT( IntProdStr ) + 1, 1 )
         FracProduct := IntProdStr - INT( IntProdStr )
      ENDDO

      // Get rid of trailing zeros from the fraction portion
      Block:={ || LChr := RIGHT(FracOutStr, 1), ;
         IF(LChr == "0", FracOutStr := SUBSTR(FracOutStr, 1, LEN(FracOutStr) - 1), 0), ;
         IF(LChr == "0", EVAL(Block), FracOutStr) }
      FracOutStr := EVAL( Block )

      /* The following block takes more memory but is shorter
         Block := { |Str| IF(RIGHT(Str, 1) == "0", ;
            EVAL(Block, SUBSTR(FracOutStr, 1, LEN(FracOutStr) - 1)), Str)}
      */

   ENDIF

   // Output
   IF cNewBaseValue <> NIL
      cNewBaseValue := IF( DecPos > 0, NegSign + IntOutString + "." + FracOutStr, IntOutString )
   ENDIF

   RETURN ( cNewBaseValue )



/***
*
*  Ceiling( <nNumber> ) --> nInteger
*
*  Return the smallest integer that is greater than or equal to <nNumber>
*
*/
FUNCTION Ceiling( nNumber )
   
   LOCAL nInteger

   IF ( INT( nNumber ) == nNumber ) .OR. ( nNumber < 0 )
      
      // Integers and negative non-integers
      nInteger := INT( nNumber )

   ELSEIF ( nNumber > 0 )
      
      // Positive non-integers
      nInteger := INT( nNumber + 1 )

   ENDIF

   RETURN ( nInteger )



/***
*
*  DtoR( <nDegrees> ) --> nRadians
*
*  Convert an angle size specified in radians to degrees
*
*/
FUNCTION DtoR( nDegrees )
   RETURN (( nDegrees/180 ) * PI )



/***
*
*  Floor( <nNumber> ) --> nInteger
*
*  Return the largest integer that is less than or equal to <nNumber>
*
*/
FUNCTION Floor( nNumber )
   
   LOCAL nInteger

   IF ( INT( nNumber ) == nNumber ) .OR. ( nNumber > 0 )
      
      // Integers and positive non-integers
      nInteger := INT( nNumber )

   ELSEIF ( nNumber < 0 )
      
      // Negative non-integers
      nInteger := INT( nNumber - 1 )

   ENDIF

   RETURN ( nInteger )



/***
*
*  NumAsCurrency( <nNumber>, <cSymbol>, <nSide> ) --> cCurrency
*
*  Convert number to currency format, floating dollar symbol
*
*/
FUNCTION NumAsCurrency( nNumber, cSymbol, nSide )
   
   LOCAL cCurrency

   // If nSide is negative, currency symbol goes on the left
   IF ( nSide < 0 )
      
      cCurrency := cSymbol + LTRIM( STR( nNumber ))

   ELSE  // Otherwise, currency symbol goes on the right
      
      cCurrency := RTRIM( STR( nNumber )) + cSymbol

   ENDIF

   RETURN ( cCurrency )



/***
*
*  NumAsLog10( <nNumber> ) --> nLog10 
*
*  Convert a positive number to log base 10
*
*/
FUNCTION NumAsLog10( nNumber )        
   
   IF ( nNumber > 0 )
      
      RETURN LOG( nNumber )/LOG( 10 )     //NOTE

   ENDIF

   RETURN ( NIL )



/***
*
*  NumGetDecimals( <nNumber> ) --> nDecimals
*
*  Determine the number of decimal digits
*
*/
FUNCTION NumGetDecimals( nNumber )
   
   LOCAL cNum
   LOCAL nPos

   cNum := STR( nNumber )
   nPos := AT( ".", cNum )

   IF nPos > 0
      RETURN( LEN( ALLTRIM( SUBSTR( cNum, nPos + 1 ))))
   ENDIF

   RETURN ( 0 )



/***
*
*  NumGetLen( <nNumber> ) --> nDigits
*
*  Determine the number of whole number digits
*
*/
FUNCTION NumGetLen( nNumber )
   
   LOCAL cNum

   cNum := STR( INT( ABS( nNumber )))

   RETURN ( LEN( ALLTRIM( cNum )))



/***
*
*  RtoD( <nRadians> ) --> nDegrees
*
*  Convert an angle size specified in radians to degrees
*
*/
FUNCTION RtoD( nRadians )
   RETURN ( 180 * ( nRadians/PI ))



/***
*
*  Sign( <nNumber> ) --> nSign
*
*  Return the sign of a number as follows:
*     0 - <nNumber> is zero
*     1 - <nNumber> is positive
*    -1 - <nNumber> is negative
*
*/
FUNCTION Sign( nNumber )
   
   LOCAL nSign

   DO CASE
   CASE nNumber == 0
      nSign := 0

   CASE nNumber > 0
      nSign := 1

   CASE nNumber < 0
      nSign := -1

   ENDCASE

   RETURN ( nSign )
