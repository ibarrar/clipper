/*============================================================================

	(c) 1993  TECHNO SOFTWARE CORPORATION

	This module contains information proprietary to TECHNO SOFTWARE
	CORPORATION, and should be treated confidential.

	it390006.prg - 	Standard Page Footer
			Merchandize Tracking System (ITS)

	Parameters:

	sys_name - system name
	rpt_name - report name
	rpt_id	 - report identification string
	width	 - page width
	left	 - left margin
	right	 - rigth margin
	page	 - page length

	acr / 04.09.93
        eso / 09.24.95 - placed eject on this function

============================================================================*/

MEMVAR cUnitNumber

FUNCTION it390006 ( rpt_id, width, left, right, page )


	LOCAL line_A := rpt_id + "    " 
	LOCAL line_B := dtoc (date()) + " " + time() + " Page " + ltrim(str(page))
	LOCAL nSpcCnt := 0

	nSpcCnt = width - len(line_A) - len(line_B) - left

	? space(left) + line_A + space(nSpcCnt) + line_B

RETURN NIL



