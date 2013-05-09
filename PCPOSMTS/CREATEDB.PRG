/*============================================================================

	(c) 1993  TECHNO SOFTWARE CORPORATION

	This module contains information proprietary to TECHNO SOFTWARE
	CORPORATION, and should be treated confidential.

	CREATEDB.PRG /it600010.prg - Create any DBF.
		                     Inventory Tracking System (ITS)

	acr / 03.29.93

============================================================================*/

#include "its.ch"

FUNCTION createdbf ( aSys )

	LOCAL n

	for n := 1 to len (aSys)
		it600011 ( aSys, n )
	next n

RETURN NIL

/*============================================================================
	Create DBF file
============================================================================*/
STATIC FUNCTION it600011 ( aSys, n )

	LOCAL aDbStru := {}, f

	for f := 1 to len (aSys[n, SYS_STRU])	    
		aadd (aDbStru, { aSys[n, SYS_STRU, f, STRU_NAME],;
				 aSys[n, SYS_STRU, f, STRU_TYPE],;
				 aSys[n, SYS_STRU, f, STRU_LEN ],;
				 aSys[n, SYS_STRU, f, STRU_DEC ]})
	next f

	dbcreate ( aSys[n, SYS_DBFNAME], aDbStru )

RETURN NIL

