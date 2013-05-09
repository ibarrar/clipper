/***
*
*  Elaptime.prg
*
*  Summer '87 ELAPTIME() Compatibility Routine
*
*  Copyright (c) 1993, Computer Associates International Inc.
*  All rights reserved.
*
*/


/***
*
*  ElapTime( <nStartTime>, <nEndTime> )
*
*	Return a time string showing the difference between start and end times
*
*	Note: If start time is greater than end time, this algorithm assumes
*         that the day changed at midnight.  Only for timings under 24 hours.
*         86400 is the number of seconds in 24 hours.
*/
FUNCTION ELAPTIME(cl_start, cl_end)
	RETURN TSTRING( IF( cl_end < cl_start, 86400, 0) + ;
                   SECS(cl_end) - SECS(cl_start) )


