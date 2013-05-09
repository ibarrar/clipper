/*============================================================================

   (c) 1993  TECHNO SOFTWARE CORPORATION

   This module contains information proprietary to TECHNO SOFTWARE
   CORPORATION, and should be treated confidential.

   it320001.prg - Vendor Directory module
         for Inventory Tracking System (ITS)

   acr / 12.27.90
   eso / 09.25.95 replaced prow() with nCtr

============================================================================*/
#include "Janus.ch"
#include "its.ch"
#include "set.ch"
#include "setcurs.ch"

#define RPT_ID   "V-DIR"
#define RPT_NAME "SUPPLIER DIRECTORY"
#define THIS_WIDTH  209 + LEFT_MARGIN

STATIC nPage := 0
STATIC cCreditTerms := ARRAY_TERMS
STATIC cVendorType := VENDOR_TYPES
static nLineCtr := 0


FUNCTION it320001()

   LOCAL cOldClr := setcolor ( BN_COLOR ), nOldCursor := 0
   local nGoPrint := 2, nPage := 0, lFirst := .t.

   nOldCursor = setcursor ( SC_NONE )

   // Create display window.
   window ( 19, 1, 22, 60, CONFIRM_COLOR )
   @ 1, 1 wsay " Creating " + RPT_NAME + ".  Please wait ..."

   if NetUse("V",DB_SHARED,NUM_SECONDS)
      Set Index to V_001
   endif   

   dbGoTop()

#ifdef TO_FILE
   set printer to ".\"+RPT_ID
#endif

   set device to printer
   set printer on
   set console off
   
   
   

   lFirst := .t.
   NLINECTR := 0   

   do while .T.
   

      // Nothing to print.
      if V->(Eof())
         exit
      endif

      // Indicate record being processed.
      @ 2, 1 wsay " Supplier: " + V->V_001 + " " + V->V_002
      if lFirst
       // Standard page header routine.
        it390003 ( SYS_NAME, RPT_NAME, THIS_WIDTH, LEFT_MARGIN, RIGHT_MARGIN )
        nPage++
       // Print the headers for this report.
       it32000101()   
       lFirst := .f.
      endif

      // Print on next row.
       ? MARGIN + V->V_001 
      ?? space(2) + V->V_002 
      ?? space(2) + V->V_011 
      ?? space(2) + V->V_006 
      ?? space(2) + V->V_003 
      ?? space(2) + V->V_004 
      ?? space(2) + V->V_005 
      ?? space(2) + trans(V->V_012,"99.99") 

      if V->V_009 > 0 .and. V->V_009 <= len(cCreditTerms)
         ?? space(4) + cCreditTerms[V->V_009]
      else
         ?? space(4) + repl ( "?", 8 )
      endif

      if V->V_010 > 0 .and. V->V_010 <= len(cVendorType)
         ?? space(2) +  cVendorType[V->V_010]
      else
         ?? space(2) + repl ( "?", 13 )
      endif
      ? MARGIN + SPACE(5) + V->V_014 
      ? MARGIN + SPACE(5) + V->V_015 
      ? MARGIN + SPACE(5) + V->V_016 
      ? MARGIN + SPACE(5) + V->V_017 


      nLineCtr += 5
      if nLineCtr > 55
         lFirst := .t.
         nLineCtr := 0
         ? chr(12)
      endif
      V->(DbSkip())

   enddo
    ?
    ? MARGIN + "END OF REPORT" + replicate ( "=", THIS_WIDTH - LEFT_MARGIN - 13 ) 
   it390006 ( RPT_ID, THIS_WIDTH, LEFT_MARGIN, RIGHT_MARGIN, nPage )
   

   dbCloseAll()

   set device to screen
   set printer off
   set console on
   set cursor on
   set printer to

   // Remove window.
   Killwindow()
   tone ( 2100, 3 )

   // Restore cursor shape.
   setcursor ( nOldCursor )

   // Restore color set.
   setcolor ( cOldClr )

   // Screen or Printed Reports.
   RepGen( ".\"+RPT_ID, RPT_NAME, 2, 214 )
   
RETURN NIL

/*============================================================================
   Page Header
============================================================================*/
STATIC FUNCTION it32000101

       ? MARGIN  + "Report Date: " + dtoc(date())
  //     ? MARGIN +  "SUPPLIER" 
       ? 
       ? MARGIN +  replicate ( "-", 209)

       ? MARGIN + padr ( "Code", 4 )
      ?? space(1) + padr ( "Names",       30 )
      ?? space(2) + padr ( "Item Supplied", 20 )
      ?? space(2) + padr ( "Contact Person", 20 )
      ?? space(2) + padr ( "Address",  50 )
      ?? space(2) + padr ( "Telephone",  30 )
      ?? space(2) + padr ( "FAX No.",   10 )
      ?? space(2) + padr ( "Percent",  7 )
      ?? space(2) + padr ( "Terms",       8 )
      ?? space(2) + padr ( "Type",       13 )
       ?
       ? MARGIN + repl( "-", THIS_WIDTH - LEFT_MARGIN)
      nLineCtr += 5 
RETURN NIL
