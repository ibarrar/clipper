/*============================================================================

	(c) 1993  TECHNO SOFTWARE CORPORATION

	This module contains information proprietary to TECHNO SOFTWARE
	CORPORATION, and should be treated confidential.

	it390007.prg - Handler for printer errors.
                       Merchandize Tracking System (MTS)

	atc / 07.30.93

============================================================================*/


FUNCTION it390007(Row, Column, Err, passAlong)
#include "ERROR.CH"
LOCAL PrinterOk,nKey := 1

IF Err:genCode == EG_PRINT
 SET DEVICE TO SCREEN
 SET PRINTER OFF
  DO WHILE !ISPRINTER() .AND. (nKey==1)
   nKey := alert( " Printer not ready. ",{" Retry "," Quit "})
  ENDDO
 IF nKey == 1 
  SET DEVICE TO SCREEN
  SET PRINT ON
  RETURN .T.
 ENDIF
 BREAK
ELSE
 return(eval(passAlong, Err))
ENDIF
return NIL
 
