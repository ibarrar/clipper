/***
*
*  Fkmax.prg
*
*  Summer '87 FKMAX() Compatibility Routine
*
*  Copyright (c) 1993, Computer Associates International Inc.
*  All rights reserved.
*
*/


/***
*	FKMAX()
*	Return the maximum number of programmable function keys on the computer
*
*	Note: specific to IBM PC/XT/AT and clones.
*/
FUNCTION FKMAX()
	RETURN (40) 	// IBM specific

