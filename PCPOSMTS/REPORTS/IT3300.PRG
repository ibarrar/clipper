/*============================================================================

   (c) 1993  TECHNO SOFTWARE CORPORATION

   This module contains information proprietary to TECHNO SOFTWARE
   CORPORATION, and should be treated confidential.

   it3300.prg - Monthly Reports

   acr / 05.18.93

 Revisions :
  1. Incorporated printing error checking by modifying the errorblock.
                                              
                                                    atc / 07.30.93

============================================================================*/

#include "box.ch"
#include "its.ch"

FUNCTION it3300 ( dchoice )

   LOCAL cOldScr
        
        // Save the previous error handler.
   LOCAL PrevHandler := ErrorBlock()
 
   // Direct all error to printer error handler.
        ErrorBlock ( { |e| it390007( 12, 30, e, PrevHandler ) } ) 
   
   cOldScr = savescreen ( 0, 0, maxrow(), maxcol() )

BEGIN SEQUENCE  // Start of checking for error block.
   
   DO CASE

      CASE dchoice =  1 // Purchase Order Report
         it310001( 2 )

      CASE dchoice =  2 // Receiving Report
         it310002( 2 )

      CASE dchoice =  3 // Rejects Report
         it310003( 2 )

      CASE dchoice =  4 // Stock Adjustment Report
         it310007( 2 )

      CASE dchoice =  6 // Stock status Report
         it310004( 2 )

      CASE dchoice =  7 // All Reports
         it310001( 2 )
         it310002( 2 )
         it310003( 2 )
         it310007( 2 )
         it310004( 2 )

   ENDCASE

END SEQUENCE // Checking ends.

        ErrorBlock ( PrevHandler )  // Restore previous handler.

   restscreen (0, 0, maxrow(), maxcol(), cOldScr)

        dbCloseAll() // Close any opened file.

   RETURN NIL


