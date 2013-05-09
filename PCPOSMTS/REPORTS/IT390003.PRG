/*============================================================================

	(c) 1993  TECHNO SOFTWARE CORPORATION

	This module contains information proprietary to TECHNO SOFTWARE
	CORPORATION, and should be treated confidential.

	it390003.prg - 	Standard Page Header
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

============================================================================*/

FUNCTION it390003 ( sys_name, rpt_name, width, left, right )

	 ? space(left) + sys_name

	?? space((width - (len(rpt_name+sys_name) + right)) - left) + rpt_name

RETURN NIL


