/*============================================================================

	(c) 1993  TECHNO SOFTWARE CORPORATION

	This module contains information proprietary to TECHNO SOFTWARE
	CORPORATION, and should be treated confidential.

	CREATENT.PRG / it600020.prg - Create any NTX.
		                      Inventory Tracking System (ITS)

	acr / 03.29.93

============================================================================*/

#include "its.ch"

FUNCTION createntx ( aSys )

	LOCAL n

	for n := 1 to len (aSys)
		it600021  (aSys[n, SYS_DBFNAME], aSys[n, SYS_NTX])
	next n

RETURN NIL

/*============================================================================
	Create NTX file
============================================================================*/
STATIC FUNCTION it600021 ( dbfname, aNtx )

	LOCAL i, key

	for i := 1 to len (aNtx)
		use (dbfname) new
		key := aNtx[i, NTX_KEY]
		index on &key to (aNtx[i, NTX_NAME])
		use
	next i

RETURN NIL


