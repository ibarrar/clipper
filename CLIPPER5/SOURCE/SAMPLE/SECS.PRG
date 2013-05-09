/***
*
*  Secs.prg
*
*  Summer '87 SECS() Compatibility Routine
*
*  Copyright (c) 1993, Computer Associates International Inc.
*  All rights reserved.
*
*/


/***
*
*	SECS( <time string> )
*
*	Return numeric seconds as a quantity of the time string
*
*	Note: Seconds in time period
*         -------    -----------
*              60    1 minute
*            3600    1 hour
*           86400    1 day
*/
FUNCTION SECS(cl_time)
	RETURN VAL( 	  cl_time	) * 3600 +;
		   VAL(SUBSTR(cl_time,4)) *   60 +;
		   VAL(SUBSTR(cl_time,7))


