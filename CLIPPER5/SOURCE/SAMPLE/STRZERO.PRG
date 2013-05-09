/***
*
*  Strzero.prg
*
*  Summer '87 STRZERO() Compatibility Routine
*
*  Copyright (c) 1993, Computer Associates International Inc.
*  All rights reserved.
*
*/


/***
*
*   StrZero( <nNumber>, <nLength>, <nDecimals> ) --> cNumber
*
*   Convert a numeric to a string padded with leading zeros
*
*/
FUNCTION StrZero( n, nLength, nDecimals )

   LOCAL cNumber

   IF PCOUNT() == 3
      cNumber := STR( n, nLength, nDecimals )

   ELSEIF PCOUNT() == 2
      cNumber := STR( n, nLength )

   ELSE
      cNumber := STR( n )

   ENDIF

   IF "-" $ cNumber
      
      // Negative number, move the minus sign in front of zeros
      RETURN ( "-" + REPLICATE( "0", LEN( cNumber ) -    ;
               LEN( LTRIM( cNumber ))) +                 ;
               SUBSTR( cNumber, AT( "-", cNumber ) + 1 ) )

   ENDIF

   // Positive number
   RETURN ( REPLICATE( "0", LEN( cNumber ) - LEN( LTRIM( cNumber ))) + ;
            LTRIM( cNumber ) )

