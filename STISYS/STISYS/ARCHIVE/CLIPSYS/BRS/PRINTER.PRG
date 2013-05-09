// Filename : PRINTER.PRG
// Module Description : Printer Control Functions Library
// Author : Rolando C. Ibarra Jr.
// Date Written : February 21, 1992
// Last Update  : February 21, 1992

#include "Printer.Ch"

// nil function SetPrinter(nCommand, nMode)
//    --> controls the print attribute

function SetPrinter(nCommand,nMode)
   lstat := Set(_SET_PRINTER,.T.)
   do case
      case nCommand == _SET_FORMFEED    ; ?? chr(12)
      case nCommand == _SET_QUALITY     ; ?? chr(27)+chr(120)+chr(nMode)
      case nCommand == _SET_TYPESTYLE   ; ?? chr(27)+chr(107)+chr(nMode)
      case nCommand == _SET_PITCH       ; ?? chr(27)+if(nMode==P_12_PITCH,chr(77),chr(80))
      case nCommand == _SET_SIZE        ; ?? if(nMode==P_NORMAL,chr(18),chr(15))
      case nCommand == _SET_WIDTH       ; ?? chr(27)+chr(87)+if(nMode==P_NORMAL,chr(0),chr(1))
      case nCommand == _SET_HEIGHT      ; ?? chr(27)+chr(119)+if(nMode==P_NORMAL,chr(0),chr(1))
      case nCommand == _SET_EMPHASIZED  ; ?? chr(27)+if(nMode==.T.,chr(69),chr(70))
      case nCommand == _SET_DBSTRIKE    ; ?? chr(27)+if(nMode==.T.,chr(71),chr(72))
      case nCommand == _SET_SUPERSCRIPT ; ?? chr(27)+if(nMode==.T.,chr(83)+chr(0),chr(84))
      case nCommand == _SET_SUBSCRIPT   ; ?? chr(27)+if(nMode==.T.,chr(83)+chr(1),chr(84))
      case nCommand == _SET_ITALIC      ; ?? chr(27)+if(nMode==.T.,chr(52),chr(53))
      case nCommand == _SET_UNDERLINE   ; ?? chr(27)+chr(45)+if(nMode==.T.,chr(1),chr(0))
   endcase
   Set(_SET_PRINTER,lstat)
return nil

// < EOF - Printer.Prg >