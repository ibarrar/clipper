/***
*
*  Dbf.prg
*
*  Summer '87 DBF() Compatibility Routine
*
*  Copyright (c) 1993, Computer Associates International Inc.
*  All rights reserved.
*
*/


/***
*
*	DBF()
*
*	Return the alias of the currently selected database.
*
*	Note: Supposed to return the name of the currently selected database file.
*/
FUNCTION DBF
	RETURN ALIAS()

