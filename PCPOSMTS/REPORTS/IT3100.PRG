/*============================================================================

   (c) 1993  TECHNO SOFTWARE CORPORATION

   This module contains information proprietary to TECHNO SOFTWARE
   CORPORATION, and should be treated confidential.

   it3100.prg - Registers and reports

   acr / 05.18.93

 Revisions :
  1. Incorporated printing error checking by modifying the errorblock.
                                              
                                                    atc / 07.30.93

============================================================================*/

#include "box.ch"
#include "its.ch"

FUNCTION it3100 ( dchoice )

   LOCAL cOldScr, rBrowse, nChoice := 0, aChoices:={"Per Supplier", "All Supplier"}
        
        // Save the previous error handler.
   LOCAL PrevHandler := ErrorBlock()

   // Direct all error to printer error handler.
        ErrorBlock ( { |e| it390007( 12, 30, e, PrevHandler ) } ) 

   cOldScr = savescreen ( 0, 0, maxrow(), maxcol() )

BEGIN SEQUENCE  // Start of checking for error block.
   
   DO CASE

      CASE dChoice =  21 // Purchase Order Report
          it310001( 0 )

      CASE dChoice =  1 // Receiving Report Per Supplier
          it31000( 0 )
          
      CASE dchoice =  2 // Receiving Report All Supplier
         it310002( 0 )

      CASE dchoice =  3 // Returns Report Per Supplier
         it310003p( 0 )

      CASE dchoice = 4  // Returns Report All Supplier   
         it310003( 0 )
         
      CASE dchoice =  5 // Stock Status Register Per Supplier
         it310004p( 0 )

      CASE dchoice =  20 // Stock Status Register All Supplier
         it310004( 0 )   

      CASE dchoice =  6 // Stock Out Report Per Supplier
         it310005p()
         
      CASE dchoice = 17 // Stock Out Report All Supplier
         it310005()   

      CASE dchoice =  7 // Re-order Report Per Supplier
         it310006P()

      CASE dChoice =  8 // Re-order Report All Supplier
         it310006()

      CASE dchoice =  9 // Stock Adjustment Per Supplier
         it310007p( 0 )

      CASE dchoice =  22 // Stock Adjustment All Supplier
         it310007( 0 )  

      CASE dchoice = 10 // Inventory Register Per Supplier
         it310008P()

      CASE dchoice = 18 // Inventory Register All Supplier
         it310008()   

      CASE dchoice = 11 // Inventory Variance Report Per Supplier
         it310009p()

      CASE dchoice = 19 // Inventory Variance Report All Supplier
         it310009()   


   ENDCASE

END SEQUENCE // Checking ends.

        ErrorBlock ( PrevHandler )  // Restore previous handler.
   
   restscreen (0, 0, maxrow(), maxcol(), cOldScr)
  
        dbCloseAll() // Close any opened file.

   RETURN NIL


