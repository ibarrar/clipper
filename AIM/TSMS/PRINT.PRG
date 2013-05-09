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

FUNCTION it390004 ( how_many, left_margin, what, photo )

	if what == NIL
		what := ""
	endif

	if photo == NIL
		@ prow() + how_many, left_margin say  what 
	else
		@ prow() + how_many, left_margin say  what picture photo
	endif

RETURN NIL

FUNCTION it390005 ( move_over, what, photo )

	if what == NIL
		what := ""
	endif

	if photo == NIL
		@ prow(), pcol() + move_over say  what 
	else
		@ prow(), pcol() + move_over say  what picture photo
	endif

RETURN NIL
