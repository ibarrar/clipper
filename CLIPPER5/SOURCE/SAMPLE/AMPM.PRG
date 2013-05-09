/***
*
*  Ampm.prg
*
*  Summer '87 AMPM() Compatibility Routine
*
*  Copyright (c) 1993, Computer Associates International Inc.
*  All rights reserved.
*
*/


/***
*
*  AMPM( <cTime> ) --> cTime
*
*  Convert a time string to 12-hour format
*
*/
FUNCTION AMPM( cTime )

   IF VAL( cTime ) == 0
      cTime := "12" + SUBSTR( cTime, 3 ) + " am"

   ELSEIF VAL( cTime ) < 12
      cTime += " am"

   ELSEIF VAL( cTime ) == 12
      cTime += " pm"

   ELSEIF VAL( cTime ) == 24
      cTime := "12" + SUBSTR( cTime, 3 ) + " am"

   ELSE
      cTime := STR( VAL( cTime ) - 12, 2 ) + SUBSTR( cTime, 3 ) + " pm"

   ENDIF

   RETURN cTime


