/***
*
*  Fklabel.prg
*
*  Summer '87 FKLABEL() Compatibility Routine
*
*  Copyright (c) 1993, Computer Associates International Inc.
*  All rights reserved.
*
*/


/***
*	FKLABEL( <nFunKey> )
*
*	Return the name of the <expN>th programmable function key
*/
FUNCTION FKLABEL(cl_1)
	RETURN IF( cl_1 <= 40 .AND. cl_1 > 0, "F"+LTRIM(STR(cl_1)), "")

