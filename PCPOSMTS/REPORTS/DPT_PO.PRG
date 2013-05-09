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

#define RPT_ID    "PO-REG-D"
#define RPT_ID_M  "PO-REP-M"


#define RPT_NAME  "DEPARTMENTAL PENDING ORDER REGISTER"
#define RPT_NAME_M   "DEPARTMENTAL PENDING ORDER REPORT"

#define THIS_WIDTH ( 142 + PLU_DESC_LEN + PLU_CODE_LEN ) + LEFT_MARGIN +2 -118

memvar dToday

static pttl[4+1], gttl[4+1]
static nPage := 0, nTCost := 0, footer_now := 0, nTRetl:=0
static nCtr := 0

function dpt_po ( nReportSwitch )
local cOldClr := setcolor ( BN_COLOR ), nOldCursor := 0
local cRptName, cRptID, lStartLine
local nGoPrint := 2, getlist := {}
local sdate:=Date(), edate:=Date(), vBrowse

local nDpPOIdx:=0, aDpPO:={} 
local cDpPOCode:=SPACE(2), cDpPOName:=space(20)


 SET CURSOR ON
   vBrowse := OpenWindow(15,20,17,55)
   @ 15,27 say "Date Received Range"
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

/*   if nReportSwitch == 2
      set filter to PO->PO_007 == 2 .and. month (PO->PO_004) == month (dToday) .AND. year (po->po_003) == year (dToday)
   else
      dbSetFilter( {|| PO->PO_007 < 2}, "PO->PO_007 < 2" ) 
   endif */

//jzo05-08-98   PO->(DbGoTop())

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

do while DP->(!EOF())
   aadd(aDpPO,{DP->DP_001,DP->DP_002})
   DP->(DBSKIP())
enddo   

for nDpPOIdx := 1 to len (aDpPO)
 cDpPOCode := aDpPO[nDpPOIdx][1]
 cDpPOName := aDpPO[nDpPOIdx][2]


?MARGIN + padr(cDpPOCode,4)
?? space(2) + subs(cDpPOName,1,20)

PO->(dbgotop())
   while PO->(!Eof())
      
    if PO->PO_003 >= sdate .and. PO->PO_003 <= edate   
       
if !RR->(DBSEEK(PO->PO_001))

      // Indicate record being processed.
      @ 2, 1 wsay " PO: " + PO->PO_001
       
/*jzo05-08-98
      // Find vendor cross reference.
      V->(DbSeek(PO->PO_002))
*/

      nCtr += 1

      lStartLine := .f.
      // Find item cross reference.
      PO_ITEMS->(DbSeek(PO->PO_001))
      while PO_ITEMS->(!Eof()) .and. PO_ITEMS->POI_LINK == PO->PO_001     

       if ITEM->(DbSeek(PO_ITEMS->POI_ITEM)) 

if subs(PO_ITEMS->POI_ITEM,4,2) == cDpPOCode

         if lStartLine
           ? MARGIN + space(70)
           nCtr += 1
         endif       

         nTCost := nTCost + (PO_ITEMS->POI_QORD * PO_ITEMS->POI_COST)
         nTRetl := nTRetl + (PO_ITEMS->POI_QORD * PO_ITEMS->POI_URET)


         // Accumulate the page and grand total and count.
//         it31000103()
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
endif
       endif
       
     
       PO_ITEMS->(DbSkip())  
       
      enddo
endif
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
next nDpPOIdx

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

