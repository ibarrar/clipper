/***
*
*  Tstring.prg
*
*  Summer '87 TSTRING() Compatibility Routine
*
*  Copyright (c) 1993, Computer Associates International Inc.
*  All rights reserved.
*
*/


/***
*
*	TSTRING( <seconds> )
*
*	Return a 24-hour time string from numeric seconds
*
*	Note: Time quantities over 24 hours are returned by the DAYS() function.
*
*/
FUNCTION TSTRING(cl_secs)
	RETURN STRZERO( INT(MOD(cl_secs/3600, 24)), 2, 0 ) +':'+;
          STRZERO( INT(MOD(cl_secs/  60, 60)), 2, 0 ) +':'+;
          STRZERO( INT(MOD(cl_secs   , 60)), 2, 0 )

