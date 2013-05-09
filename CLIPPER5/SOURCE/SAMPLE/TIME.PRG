/***
*
*  Time.prg
*
*  Sample user-defined functions for manipulating time strings
*
*  Copyright (c) 1993, Computer Associates International Inc.
*  All rights reserved.
*
*  NOTE: Compile with /a /m /n /w
*
*/


/***
*
*  SecondsAsDays( <nSeconds> ) --> nDays
*
*  Convert numeric seconds to days
*
*  NOTE: Same as DAYS() in Examplep.prg
*/
FUNCTION SecondsAsDays( nSeconds )
   RETURN INT(nSeconds / 86400)



/***
*  TimeAsAMPM( <cTime> ) --> cTime
*  Convert a time string to 12-hour format
*
*  NOTE:  Same as AMPM() in Examplep.prg
*/
FUNCTION TimeAsAMPM( cTime )

   IF VAL(cTime) < 12
      cTime += " am"
   ELSEIF VAL(cTime) = 12
      cTime += " pm"
   ELSE
      cTime := STR(VAL(cTime) - 12, 2) + SUBSTR(cTime, 3) + " pm"
   ENDIF

   RETURN cTime



/***
*  TimeAsSeconds( <cTime> ) --> nSeconds
*  Convert a time string to number of seconds from midnight
*
*  NOTE: Same as SECS() in Examplep.prg
*/
FUNCTION TimeAsSeconds( cTime )
   RETURN VAL(cTime) * 3600 + VAL(SUBSTR(cTime, 4)) * 60 +;
          VAL(SUBSTR(cTime, 7))



/***
*  TimeAsString( <nSeconds> ) --> cTime
*  Convert numeric seconds to a time string
*
*  NOTE: Same as TSTRING() in Examplep.prg
*/
FUNCTION TimeAsString( nSeconds )
   RETURN StrZero(INT(Mod(nSeconds / 3600, 24)), 2, 0) + ":" +;
		  StrZero(INT(Mod(nSeconds / 60, 60)), 2, 0) + ":" +;
		  StrZero(INT(Mod(nSeconds, 60)), 2, 0)



/***
*  TimeDiff( <cStartTime>, <cEndTime> ) --> cDiffTime
*  Return the difference between two time strings in the form hh:mm:ss
*
*  NOTE: Same as ELAPTIME() in Examplep.prg
*/
FUNCTION TimeDiff( cStartTime, cEndTime )
   RETURN TimeAsString(IF(cEndTime < cStartTime, 86400 , 0) +;
          TimeAsSeconds(cEndTime) - TimeAsSeconds(cStartTime))



/***
*  TimeIsValid( <cTime> ) --> lValid
*  Validate a time string
*
*/
FUNCTION TimeIsValid( cTime )
   RETURN VAL(cTime) < 24 .AND. VAL(SUBSTR(cTime, 4)) < 60 .AND.;
          VAL(SUBSTR(cTime, 7)) < 60
