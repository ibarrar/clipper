/***
*
*  Print.prg
*
*  Sample user-defined functions for controlling the printer
*
*  Copyright (c) 1993, Computer Associates International Inc.
*  All rights reserved.
*
*  NOTE: Compile with /a /m /n /w
*
*/


/***
*
*  PrintCodes( <cCtrlCode> )
*
*  Send control codes to the printer without affecting printhead position
*
*  Usage:
*         PrintCodes( CHR (27 ) + "E" )
*         ?? "Some Text"
*         PrintCodes( CHR( 27 ) + "F" )
*         ?? "More Text"
*
*/
PROCEDURE PrintCodes( cCtrlCode )
   
   LOCAL nRow     := PROW()                     // Save the current row
   LOCAL nCol     := PCOL()                     // Save the current column
   LOCAL lPrinter := SET( _SET_PRINTER, .T. )   // SET PRINTER ON
   LOCAL lConsole := SET( _SET_CONSOLE, .F. )   // SET CONSOLE OFF

   ?? cCtrlCode                  // Send the code(s) to the printer

   SETPRC( nRow, nCol )          // Restore the previous row/column settings
   SET( _SET_PRINTER, lPrinter ) // Restore printer setting
   SET( _SET_CONSOLE, lPrinter ) // Restore console setting

   RETURN 
