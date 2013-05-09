/***
*
*  Lennum.prg
*
*  Summer '87 LENNUM() Compatibility Routine
*
*  Copyright (c) 1993, Computer Associates International Inc.
*  All rights reserved.
*
*/


/***
*
*	LENNUM( <nNum> )
*
*	Return the string length of <nNum>
*
*/
FUNCTION LENNUM(cl_number)
	RETURN LEN(LTRIM(STR(cl_number)))

