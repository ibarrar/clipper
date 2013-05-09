/*============================================================================

   (c) 1993  TECHNO SOFTWARE CORPORATION

   This module contains information proprietary to TECHNO SOFTWARE
   CORPORATION, and should be treated confidential.

   it3200.prg - Directories and Listings

   acr / 05.18.93

 Revisions :
  1. Incorporated printing error checking by modifying the errorblock.
                                              
                                                    atc / 07.30.93

============================================================================*/

#include "box.ch"
#include "its.ch"

FUNCTION it3200 ( mchoice )

   LOCAL cOldScr
        
        // Save the previous error handler.
   LOCAL PrevHandler := ErrorBlock()

   // Direct all error to printer error handler.
        ErrorBlock ( { |e| it390007( 12, 30, e, PrevHandler ) } ) 

   cOldScr = savescreen ( 0, 0, maxrow(), maxcol() )

BEGIN SEQUENCE  // Start of checking for error block.
   
   DO CASE

      CASE mchoice =  1 // Vendor Directory
         it320001()

      CASE mchoice =  2 // Item Directory Per Supplier
         it320002p()

      CASE mchoice =  7 // Item Directory All Supplier
         it320002()   
 
      CASE mchoice =  4 // Class Directory
         it320004()

      CASE mchoice =  5 // Department Directory
         it320005()


      CASE mchoice =  6 // All Directories
         it320001()
         it320002()
         it320004()
         it320005()
   ENDCASE

END SEQUENCE // Checking ends.

        ErrorBlock ( PrevHandler )  // Restore previous handler.

   restscreen (0, 0, maxrow(), maxcol(), cOldScr)

        dbCloseAll() // Close any opened file.

   RETURN NIL

