/***
*
*  Days.prg
*
*  Summer '87 DAYS() Compatibility Routine
*
*  Copyright (c) 1993, Computer Associates International Inc.
*  All rights reserved.
*
*/


/***
*
*	DAYS( <nSeconds> )
*
*	Return integer number of days from numeric seconds
*
*	Note: The remainder under 24 hours is returned by the TSTRING() function.
*
*/
FUNCTION DAYS(cl_secs)
	RETURN INT( cl_secs / 86400 )


