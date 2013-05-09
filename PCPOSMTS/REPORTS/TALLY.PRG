/*============================================================================

   (c) 1993  TECHNO SOFTWARE CORPORATION

   This module contains information proprietary to TECHNO SOFTWARE
   CORPORATION, and should be treated confidential.

   it310001.prg - Purchase Order Register module
         for Inventory Tracking System (ITS)

   acr / 12.27.90

 Revisions :
    1. Remove extra accumulation of page and grand total (it31000103()).
                                                          atc / 07.16.93
                                                          
    2. Added Screen Report Generation for files less than 64K                                                      
                                                          eso / 08.01.95 

    3. Replaced prow() with nCtr                          eso / 09.24.95
============================================================================*/
#include "Janus.ch"
#include "its.ch"
#include "set.ch"
#include "setcurs.ch"

#define RPT_ID    "TS-REG-D"
#define RPT_ID_M  "TS-REP-M"

/*jzo05-08-98

#define RPT_NAME  "ITEMIZED PENDING ORDER REGISTER"
#define RPT_NAME_M   "ITEMIZED PENDING ORDER REPORT"

*/

#define RPT_NAME  "WEEKLY TALLY SHEET REGISTER"
#define RPT_NAME_M   "WEEKLY TALLY SHEET REPORT"

#define THIS_WIDTH ( 142 + PLU_DESC_LEN + PLU_CODE_LEN ) + LEFT_MARGIN +2 -118

memvar dToday
static pttl[4+1], gttl[4+1]
static nPage := 0, nTCost := 0, footer_now := 0, nTRetl:=0
static nCtr := 0


function tally(nReportSwitch)
local cOldClr := setcolor ( BN_COLOR ), nOldCursor := 0
local cRptName, cRptID, lStartLine
local nGoPrint := 2, getlist := {}
local sdate:=Date(), edate:=Date(), vBrowse

local nDpCLIdx:=0, aDpCL:={} ,lCLNext
local cDpCLCode:=SPACE(4), cDpCLName:=space(20),cPrevDC:=space(4)


 SET CURSOR ON
   vBrowse := OpenWindow(15,20,17,55)
   @ 15,27 say "Date Range"
   @ 16,21 say "From: "Get sdate
   @ 16,40 say "To: "Get edate
   read
   SET CURSOR OFF
   CloseWindow(vBrowse)

   if nReportSwitch = 2 // Monthly
      cRptName := RPT_NAME_M
      cRptID   := RPT_ID_M
   else
      cRptName := RPT_NAME
      cRptID   := RPT_ID
   endif

   afill (pttl, 0)
   afill (gttl, 0)
   nPage := 0

   nOldCursor = setcursor ( SC_NONE )

   // Create display window.
   window( 19, 1, 22, 60, CONFIRM_COLOR )
   @ 1, 1 wsay " Creating  " + cRptName + ".  Please wait ..."

   
   if NetUse("CL",DB_SHARED,NUM_SECONDS)
      Set Index to CL_001
   endif


   if NetUse("V",DB_SHARED,NUM_SECONDS)
      Set Index to V_001
   endif   

   if NetUse("ITEM.DBF",DB_SHARED,NUM_SECONDS)
      Set Index to I_001
   endif

   if NetUse("PO_ITEMS",DB_SHARED,NUM_SECONDS)
      Set Index to POI_LINK
   endif   
   
   if NetUse("PO",DB_SHARED,NUM_SECONDS)
      Set Index to PO_001
   endif

   
   if NetUse("RR",DB_SHARED,NUM_SECONDS)
      Set Index to RR_001
   endif
      
   
   if NetUse("DP",DB_SHARED,NUM_SECONDS)
      Set Index to DP_001
   endif

   #ifdef TO_FILE
      Set( 24, ".\"+cRptID, .F. )
   #endif 

   set device to printer
   set printer on
   set console off


    // Standard page header routine.
     it390003 ( SYS_NAME, cRptName, THIS_WIDTH, LEFT_MARGIN, RIGHT_MARGIN )
     nCtr := 1
     nPage := 1

   // Print the headers for this report.
     it31000101(sdate,edate)

CL->(dbgotop())
do while CL->(!eof())
   aadd(aDpCL,{CL->CL_001,CL->CL_002})
   CL->(dbskip())   
enddo

for nDpCLIdx := 1 to len(aDpCL)
    cDpCLCode:=aDpCL[nDpCLIdx][1]
    cDpCLName:=aDpCL[nDpCLIdx][2]
if nDpCLIdx<len(aDpCL)
    lCLNext:=.t.
else
    lCLNext:=.f.
endif    
    
if cPrevDC==space(4)
   cPrevDC:=cDpCLCode
   nTCost:=0
   nTRetl:=0
endif      

?MARGIN + padr(cDpCLCode,4)
?? space(2) + subs(cDpCLName,1,20)

PO->(dbgotop())
do while PO->(!eof())
    if (PO->PO_003 >= sdate .and. PO->PO_003 <= edate) .AND. (cPrevDC==PO->PO_014)

      // Indicate record being processed.
      @ 2, 1 wsay " PO: " + PO->PO_001
      nCtr += 1
      lStartLine:=.f.
/*
if PO->PO_014 !=  cPrevDC
         ?? space(2) +tran( nTCost, "999,999,999.99" )
         ?? space(2) +tran( nTRetl, "999,999,999.99" )
         
   // Accumulate total cost.
   pttl[2] += nTCost
   gttl[2] += nTCost

   // Accumulate total cost.
   pttl[5] += nTRetl
   gttl[5] += nTRetl
nTCost:=0
nTRetl:=0
cPrevDC:=space(4)
//exit
endif
*/


      // Find item cross reference.      
      PO_ITEMS->(DbSeek(PO->PO_001))      
      PO_ITEMS->(DBGOTOP())
      while PO_ITEMS->(!Eof())        //.and. PO_ITEMS->POI_LINK == PO->PO_001     

IF (PO->PO_014 == subs(PO_ITEMS->POI_ITEM,4,4)) .and. (PO_ITEMS->POI_LINK == PO->PO_001)

         if lStartLine
           ? MARGIN + space(70)
           nCtr += 1
         endif       
         
        nTCost := nTCost+ PO_ITEMS->POI_COST
        nTRetl := nTRetl+ PO_ITEMS->POI_URET

        lStartLine := .t. 
         if PO_ITEMS->(!eof()) .and. nCtr == 55
               it31000102()
               nCtr := 0
               it390006 ( cRptID, THIS_WIDTH, LEFT_MARGIN, RIGHT_MARGIN, nPage )
               npage += 1                              
               eject
               it390003 ( SYS_NAME, cRptName, THIS_WIDTH, LEFT_MARGIN, RIGHT_MARGIN )
               nCtr := 1   
               it31000101(sdate,edate)
         endif   
ENDIF         
//endif
         PO_ITEMS->(dbskip())
      enddo          
      

endif
PO->(DbSkip())
enddo       

         ?? space(2) +tran( nTCost, "999,999,999.99" )
         ?? space(2) +tran( nTRetl, "999,999,999.99" )
         
   // Accumulate total cost.
   pttl[2] += nTCost
   gttl[2] += nTCost

   // Accumulate total cost.
   pttl[5] += nTRetl
   gttl[5] += nTRetl
nTCost:=0
nTRetl:=0
cPrevDC:=space(4)


cPrevDC:=space(4)
next nDpCLIdx

   // Print the page totals.
   it31000102()

   ? MARGIN +  "END OF REPORT" + repl( "=", THIS_WIDTH - LEFT_MARGIN - 13)
   it390006 ( cRptID, THIS_WIDTH, LEFT_MARGIN, RIGHT_MARGIN, nPage )

   eject

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


   // hindi pa tapos !!! - eso 08/07/95
   // katatapos lang - rci 09/15/95
   Repgen( ".\"+cRptID, cRptName, 1, 70 )
   
RETURN NIL

/*============================================================================
   Page Header
============================================================================*/
static FUNCTION it31000101(stdate,endate)

       ? MARGIN  + "From : " + dtoc(stdate) + " To: " + dtoc(endate)
       ? MARGIN   + "DEPARTMENT" + repl("-",50)

       ? MARGIN   + padr ( "Code", 4 )
      ?? space(2) + padr ( "Name",         20 )
      ?? space(2) + padl ( "Total Cost",   14 )
      ?? space(2) + padl ( "Total Retail", 14 )

       ? MARGIN   + repl( "-", THIS_WIDTH - LEFT_MARGIN)
      nCtr += 4 
return nil

/*============================================================================
============================================================================*/
STATIC FUNCTION it31000102

    ? MARGIN    + repl( "-", THIS_WIDTH - LEFT_MARGIN)
    ? MARGIN    + "   PAGE TOTAL" 
   ?? space(63+PLU_DESC_LEN+PLU_CODE_LEN+2+24-108) + tran( pttl[2], "999,999,999.99" )
   ?? space(2) + tran( pttl[5], "999,999,999.99" )
   
//   ?? space( 5) + tran( pttl[3], "999,999.999" )
//   ?? space( 2) + tran( pttl[4], "999,999.999" )

    ? MARGIN    + "RUNNING TOTAL" 
   ?? space(63+PLU_DESC_LEN+PLU_CODE_LEN+2+24-108) + tran( gttl[2], "999,999,999.99" )
   ?? space(2) + tran( gttl[5], "999,999,999.99" )
//   ?? space( 5) + tran( gttl[3], "999,999.999" )
//   ?? space( 2) + tran( gttl[4], "999,999.999" )
  ? MARGIN    + repl( "-", THIS_WIDTH - LEFT_MARGIN)

   nCtr += 4
   afill ( pttl, 0 )

RETURN NIL

/*============================================================================
============================================================================*/
STATIC FUNCTION it31000103

   // Accumulate quantity ordered.
   pttl[1] += PO_ITEMS->POI_QORD
   gttl[1] += PO_ITEMS->POI_QORD

   // Accumulate total cost.
   pttl[2] += nTCost
   gttl[2] += nTCost

   // Accumulate quantity received.
   pttl[3] += PO_ITEMS->POI_QREC
   gttl[3] += PO_ITEMS->POI_QREC

   // Accumulate quantity returned.
   pttl[4] += PO_ITEMS->POI_QRET
   gttl[4] += PO_ITEMS->POI_QRET

   // Accumulate total cost.
   pttl[5] += nTRetl
   gttl[5] += nTRetl

RETURN NIL
               
