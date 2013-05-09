// Filename:      PRINTER.PRG
// Module:        Printer Control Functions Library
// Date-Written:  February 21, 1992
// Last-Update:   February 21, 1992

#include "Printer.ch"

/********************************************************/
/* nil function SetPrinter(nCommand,nMode)              */
/* --> Controlls the overall operations of the printer. */
/********************************************************/

function SetPrinter(nCommand,nMode)
   do case
      case nCommand==_SET_FORMFEED
         ?? chr(12)
      case nCommand==_SET_QUALITY
         ?? chr(27)+chr(120)+chr(nMode)
      case nCommand==_SET_TYPESTYLE
         ?? chr(27)+chr(107)+chr(nMode)
      case nCommand==_SET_PITCH
         if nMode==P_10_PITCH     ; ?? chr(27)+chr(80)
         elseif nMode==P_12_PITCH ; ?? chr(27)+chr(77) ; endif
      case nCommand==_SET_SIZE
         if nMode==P_NORMAL        ; ?? chr(18)
         elseif nMode==P_CONDENSED ; ?? chr(15) ; endif
      case nCommand==_SET_WIDTH
         if nMode==P_NORMAL       ; ?? chr(27)+chr(87)+chr(0)
         elseif nMode==P_DOUBLE   ; ?? chr(27)+chr(87)+chr(1) ; endif
      case nCommand==_SET_HEIGHT
         if nMode==P_NORMAL       ; ?? chr(27)+chr(119)+chr(0)
         elseif nMode==P_DOUBLE   ; ?? chr(27)+chr(119)+chr(1) ; endif
      case nCommand==_SET_EMPHASIZED
         if nMode==.T.            ; ?? chr(27)+chr(69)
         elseif nMode==.F.        ; ?? chr(27)+chr(70) ; endif
      case nCommand==_SET_DBSTRIKE
         if nMode==.T.            ; ?? chr(27)+chr(71)
         elseif nMode==.F.        ; ?? chr(27)+chr(72) ; endif
      case nCommand==_SET_ITALIC
         if nMode==.T.            ; ?? chr(27)+chr(52)
         elseif nMode==.F.        ; ?? chr(27)+chr(53) ; endif
      case nCommand==_SET_UNDERLINE
         if nMode==.T.            ; ?? chr(27)+chr(45)+chr(1)
         elseif nMode==.F.        ; ?? chr(27)+chr(45)+chr(0) ; endif
   endcase
return nil

// end-of-file

