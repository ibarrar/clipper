/*============================================================================

	(c) 1993  TECHNO SOFTWARE CORPORATION

	This module contains information proprietary to TECHNO SOFTWARE
	CORPORATION, and should be treated confidential.

	it390002.prg - 	Conditional Page Eject
			Merchandize Tracking System (ITS)

	Parameters:

	length  - page length
	top     - top margin
	bottwom - bottom margin

	acr / 04.09.93
        eso / 09.15.95   tinangal yung eject. ba! sige raw...

============================================================================*/

FUNCTION it390002 (rpt_id, length, top, bottom, left, right, page, width, nRow)

	LOCAL need_eject := (nRow + bottom) > length .or. (nRow == 0)

	if need_eject
	  if nRow > 0
	    it390006 ( rpt_id, width, left, right, page )
	    //eject dito bah. - rci 09/15/95
       //eject 
       // setprc(0,0) 
     endif
     eject 
     setprc(0,0) 
        
	*@  nRow + top, 0 SAY ""
	endif

RETURN need_eject

