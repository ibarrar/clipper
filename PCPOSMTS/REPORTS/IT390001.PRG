/*============================================================================

	(c) 1993  TECHNO SOFTWARE CORPORATION

	This module contains information proprietary to TECHNO SOFTWARE
	CORPORATION, and should be treated confidential.

	it390001.prg - 	Send Printer Control Codes
			Merchandize Tracking System (ITS)

	acr / 04.09.93

============================================================================*/

FUNCTION it390001 (string)

	LOCAL r := prow(), c := pcol()

	@  r, c say string
	setprc (r,c)

RETURN ""
