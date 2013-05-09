/***
*	time87.ch
*
*	Copyright, Nantucket Corporation, 1990
*/


/***
*  Days( <nSeconds> ) --> nDays
*  Convert numeric seconds to days.
*/
#translate Days(<nSeconds>) => SecondsAsDays(<nSeconds>)



/***
*  AmPm( <cTime> ) --> cTime
*  Convert a time string to 12-hour format.
*/
#translate AmPm(<cTime>) => TimeAsAMPM( <cTime> )



/***
*  Secs( <cTime> ) --> nSeconds
*  Convert a time string to number of seconds from midnight.
*/
#translate Secs(<cTime>) => TimeAsSeconds(<cTime>)



/***
*  Tstring( <nSeconds> ) --> cTime
*  Convert numeric seconds to a time string.
*/
#translate Tstring(<nSeconds>) => TimeAsString(<nSeconds>)



/***
*  ElapTime( <cStartTime>, <cEndTime> ) --> cDiffTime
*  Return the difference between two time strings in the form hh:mm:ss.
*/
#translate ElapTime(<cStartTime>, <cEndTime>) => ;
   TimeDiff(<cStartTime>, <cEndTime>)



/***
*  ValidTime( <cTime> ) --> lValid
*  Validate a time string.
*/
#translate ValidTime(<cTime>) => TimeIsValid( <cTime> )


