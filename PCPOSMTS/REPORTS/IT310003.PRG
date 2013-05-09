/*============================================================================

   (c) 1993  TECHNO SOFTWARE CORPORATION

   This module contains information proprietary to TECHNO SOFTWARE
   CORPORATION, and should be treated confidential.

   it310003.prg - Returns Register module
         for Inventory Tracking System (ITS)

   acr / 05.17.93
   eso / 09.24.95 replaced prow() with nCtr

============================================================================*/
#include "Janus.ch"
#include "its.ch"
#include "set.ch"
#include "setcurs.ch"

#define RPT_ID    "RJ-REG-D"
#define RPT_ID_M  "RJ-REP-M"
#define RPT_NAME  "RETURNS REGISTER"
#define RPT_NAME_M   "RETURNS REPORT"
#define THIS_WIDTH (167 +PLU_CODE_LEN + PLU_DESC_LEN + LEFT_MARGIN)

static pttl[4], gttl[4]
static nPage := 0, nTCost := 0, footer_now := 0
static nctr := 0

/*========================================================*/
function it310003 ( nReportSwitch )
/*========================================================*/

local cOldClr := setcolor ( BN_COLOR ), nOldCursor := 0
local cRptName, cRptID, lStartLine, lPOfound := .f.
local cRJRef := space(8), dTDate := NIL, dRdate := NIl
local nGoPrint := 2, getlist:={}, dBrowse, edate:= Date()
local sdate := Date()

   SET CURSOR ON 
   dBrowse := OpenWindow(15,20,17,55)
   @ 15,27 say "Date Return Range"
   @ 16,21 say "From: "Get sdate
   @ 16,40 say "To: "Get edate
   read
   SET CURSOR OFF
   CloseWindow(dBrowse)  


   if nReportSwitch = 2 // Monthly
      cRptName := RPT_NAME_M
      cRptID   := RPT_ID_M
   else
      cRptName := RPT_NAME
      cRptID   := RPT_ID
   endif

   afill ( pttl, 0 )
   afill ( gttl, 0 )
   nPage := 0

   nOldCursor = setcursor ( SC_NONE )

   // Create display window.
   window( 19, 1, 22, 60, CONFIRM_COLOR )
   @ 1, 1 wsay " Creating " + cRptName + ".  Please wait ..."

   if NetUse("V",DB_SHARED,NUM_SECONDS)
      Set Index to V_001
   endif   

   if NetUse("ITEM.DBF",DB_SHARED,NUM_SECONDS)
      Set Index to I_001
   endif


//   if nReportSwitch = 2
//      dbSetFilter( {|| PO->PO_007 = 2}, "PO->PO_007 = 2" ) 
//   else
//      dbSetFilter( {|| PO->PO_007 < 2}, "PO->PO_007 < 2" ) 
//   endif
   
   if NetUse("RR",DB_SHARED,NUM_SECONDS)
      //Set Index to RR_001
      index on RR->RR_002 to rtvcode
   endif   

   if NetUse("RJ_ITEMS",DB_SHARED,NUM_SECONDS)
      Set Index to RJI_LINK
   endif     
 
   if NetUse("RJ",DB_SHARED,NUM_SECONDS)
      Set Index to RJ_001
   endif
      
/*   if nReportSwitch = 2
      dbSetFilter( {|| RJ->RJ_010 = 2}, "RJ->RR_010 = 2" ) 
   else
      dbSetFilter( {|| RJ->RJ_010 < 2}, "RJ->RR_010 < 2" ) 
   endif */

   RJ->(DbGoTop())
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
  it31000301(sdate,edate)
   
   while V->(!EOF())

      // Indicate record being processed.
      @ 2, 1 wsay " V: " + V->V_001

      lStartLine := .f.
      RR->(DbSeek(V->V_001))
      while RR->(!Eof()) .and. V->V_001 == RR->RR_002
         if RR->(!Deleted())
            RJ->(DbSeek(RR->RR_001))
            if RJ->RJ_006 >= sdate .and. RJ->RJ_006 <= edate     
             ? MARGIN   + V->V_001 
             ?? space(2) + V->V_002
            RJ_ITEMS->(DbSeek(RJ->RJ_001))
            while RJ_ITEMS->(!Eof()) .and. RJ_ITEMS->RJI_LINK == RJ->RJ_001
               if RJ_ITEMS->(!Deleted()) .and. ITEM->(DbSeek(RJ_ITEMS->RJI_ITEM))
                
                  if lStartLine
                  ? MARGIN + space(25)
                  nCtr += 1
                  endif
                  ?? space(2) + RJ->RJ_001 
                  ?? space(4) + dtoc(RJ->RJ_005)
                  ?? space(4) + dtoc(RJ->RJ_006) 
                  ?? space(4) + RJ->RJ_002 
                  ?? space(2) + tran(RJ->RJ_007 , "9")
                  ?? space(2) + RJ->RJ_008 
                  ?? space(2) + dtoc(RJ->RJ_009)
                  ?? space(2) + RJ_ITEMS->RJI_ITEM 
                  ?? space(2) + ITEM->I_002 
                  ?? space(6) + tran( RJ_ITEMS->RJI_QRET, "99,999,999" )
                  ?? space(2) + ITEM->I_005 
                  if RJ_ITEMS->(!Deleted()) .and. ITEM->I_001 == RJ_ITEMS->RJI_ITEM
                      ?? space(2) + tran( ITEM->i_007, "99,999.99" )
                     ?? space(2) + tran( ITEM->i_003, "99,999.99" )
                     nTCost := RJ_ITEMS->RJI_QRET * ITEM->i_007
                     ?? space(2) + tran( nTCost,     "999,999,999.99" )
                  endif

                  // Accumulate the page and grand total and count.
                  it31000303()
                  lStartLine := .t.
                  nCtr += 1
                  if RJ_ITEMS->(!Eof()) .and. nCtr == 55
                     it31000302()
                     nCtr := 0
                     it390006 ( cRptID, THIS_WIDTH, LEFT_MARGIN, RIGHT_MARGIN, nPage )
                     nPage += 1
                     eject
                     it390003 ( SYS_NAME, cRptName, THIS_WIDTH, LEFT_MARGIN, RIGHT_MARGIN )
                     nctr := 1
                     it31000301(sdate,edate)
                  endif   
               endif
               RJ_ITEMS->(Dbskip())
            enddo   
          endif  
         endif
        RR->(DbSkip())
      enddo         
      V->(DbSkip())
   enddo

   // Print the page totals.
   it31000302()

    ? MARGIN + "END OF REPORT" + repl ( "=", THIS_WIDTH - LEFT_MARGIN - 13) 
   it390006 ( cRptID, THIS_WIDTH, LEFT_MARGIN, RIGHT_MARGIN, nPage )
   eject

   dbCloseAll()

   set device to screen
   set printer off
   set console on
   set cursor on
   set printer to


   // Remove window.
   killwindow()
   tone ( 2100, 3 )

   // Restore cursor shape.
   setcursor ( nOldCursor )

   // Restore color set.
   setcolor ( cOldClr )

   // Screen or Printed Reports
   RepGen(".\"+cRptID, cRptName, 2, 214 )
   ferase("rtvcode.ntx")

RETURN NIL



/*========================================================*/
function it310003p ( nReportSwitch )
/*========================================================*/

local cOldClr := setcolor ( BN_COLOR ), nOldCursor := 0
local cRptName, cRptID, lStartLine, lPOfound := .f.
local cRJRef := space(8), dTDate := NIL, dRdate := NIl
local nGoPrint := 2, getlist:={}, vBrowse, vRecord := space(3)
local dBrowse, edate := Date(), sdate := Date()

   SET CURSOR ON
   vBrowse := OpenWindow(15,30,17,50)
   @ 16,31 say "Supplier Code: "Get vRecord Pict "999"
   read
   SET CURSOR OFF
   CloseWindow(vBrowse)

   vRecord := padl(alltrim(vRecord),3,"0")

   SET CURSOR ON
   dBrowse := OpenWindow(15,20,17,55)
   @ 15,27 say "Date Return Range"
   @ 16,21 say "From: "Get sdate
   @ 16,40 say "To: "Get edate
   read
   SET CURSOR OFF
   CloseWindow(dBrowse)  

   if nReportSwitch = 2 // Monthly
      cRptName := RPT_NAME_M
      cRptID   := RPT_ID_M
   else
      cRptName := RPT_NAME
      cRptID   := RPT_ID
   endif

   afill ( pttl, 0 )
   afill ( gttl, 0 )
   nPage := 0

   nOldCursor = setcursor ( SC_NONE )

   // Create display window.
   window( 19, 1, 22, 60, CONFIRM_COLOR )
   @ 1, 1 wsay " Creating " + cRptName + ".  Please wait ..."

   if NetUse("V",DB_SHARED,NUM_SECONDS)
      Set Index to V_001
   endif   

   if NetUse("ITEM.DBF",DB_SHARED,NUM_SECONDS)
      Set Index to I_001
   endif


//   if nReportSwitch = 2
//      dbSetFilter( {|| PO->PO_007 = 2}, "PO->PO_007 = 2" ) 
//   else
//      dbSetFilter( {|| PO->PO_007 < 2}, "PO->PO_007 < 2" ) 
//   endif
   
   if NetUse("RR",DB_SHARED,NUM_SECONDS)
      //Set Index to RR_001
      index on RR->RR_002 to rtvcode
   endif   

   if NetUse("RJ_ITEMS",DB_SHARED,NUM_SECONDS)
      Set Index to RJI_LINK
   endif     
 
   if NetUse("RJ",DB_SHARED,NUM_SECONDS)
      Set Index to RJ_001
   endif
      
/*   if nReportSwitch = 2
      dbSetFilter( {|| RJ->RJ_010 = 2}, "RJ->RR_010 = 2" ) 
   else
      dbSetFilter( {|| RJ->RJ_010 < 2}, "RJ->RR_010 < 2" ) 
   endif */

   RJ->(DbGoTop())

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
  it31000301(sdate,edate)
  
   lStartLine := .f.   
      // Indicate record being processed.
      @ 2, 1 wsay " V: " + vRecord

      
      if RR->(DbSeek(vRecord))
       ? MARGIN   + RR->RR_002 
      ?? space(2) + RR->RR_003
      nCtr += 1

      while RR->(!Eof()) .and. vRecord == RR->RR_002
         if RR->(!Deleted())
            RJ->(DbSeek(RR->RR_001))
            RJ_ITEMS->(DbSeek(RJ->RJ_001))
            while RJ_ITEMS->(!Eof()) .and. RJ_ITEMS->RJI_LINK == RJ->RJ_001
               if RJ_ITEMS->(!Deleted()) .and. ITEM->(DbSeek(RJ_ITEMS->RJI_ITEM))
                if RJ->RJ_006 >= sdate .and. RJ->RJ_006 <= edate     
                  if lStartLine
                  ? MARGIN + space(25)
                  nCtr += 1
                  endif
                  ?? space(2) + RJ->RJ_001 
                  ?? space(4) + dtoc(RJ->RJ_005)
                  ?? space(4) + dtoc(RJ->RJ_006) 
                  ?? space(4) + RJ->RJ_002 
                  ?? space(2) + tran(RJ->RJ_007 , "9")
                  ?? space(2) + RJ->RJ_008 
                  ?? space(2) + dtoc(RJ->RJ_009)
                  ?? space(2) + RJ_ITEMS->RJI_ITEM 
                  ?? space(2) + ITEM->I_002 
                  ?? space(6) + tran( RJ_ITEMS->RJI_QRET, "99,999,999" )
                  ?? space(2) + ITEM->I_005 
                  if RJ_ITEMS->(!Deleted()) .and. ITEM->I_001 == RJ_ITEMS->RJI_ITEM
                     ?? space(2) + tran( ITEM->i_007, "99,999.99" )
                     ?? space(2) + tran( ITEM->i_003, "99,999.99" )
                     nTCost := RJ_ITEMS->RJI_QRET * ITEM->i_007
                     ?? space(2) + tran( nTCost,     "999,999,999.99" )
                  endif

                  // Accumulate the page and grand total and count.
                  it31000303()
                  lStartLine := .t.
                  if RJ_ITEMS->(!Eof()) .and. nCtr == 55
                     it31000302()
                     nCtr := 0
                     it390006 ( cRptID, THIS_WIDTH, LEFT_MARGIN, RIGHT_MARGIN, nPage )
                     nPage += 1
                     eject
                     it390003 ( SYS_NAME, cRptName, THIS_WIDTH, LEFT_MARGIN, RIGHT_MARGIN )
                     nctr := 1
                     it31000301(sdate,edate)
                  endif   
               endif
               endif
               RJ_ITEMS->(Dbskip())
            enddo   
         endif
        RR->(DbSkip())
      enddo         
   else
      Message("Supplier Code :"+vRecord+" not found ...")
      BUMMER()
   endif   

   // Print the page totals.
   it31000302()

    ? MARGIN + "END OF REPORT" + repl ( "=", THIS_WIDTH - LEFT_MARGIN - 13) 
   it390006 ( cRptID, THIS_WIDTH, LEFT_MARGIN, RIGHT_MARGIN, nPage )

   dbCloseAll()

   set device to screen
   set printer off
   set console on
   set cursor on
   set printer to


   // Remove window.
   killwindow()
   tone ( 2100, 3 )

   // Restore cursor shape.
   setcursor ( nOldCursor )

   // Restore color set.
   setcolor ( cOldClr )

   // Screen or Printed Reports
   RepGen(".\"+cRptID, cRptName, 2, 214 )
   ferase("rtvcode.ntx")

RETURN NIL



/*============================================================================
   Page Header
============================================================================*/
STATIC FUNCTION it31000301(startd,endate)

       ? MARGIN + "RETURNS REPORT"
       ?  MARGIN   + "From: " + dtoc(startd) + "  To: " + dtoc(endate) 
      ? "SUPPLIER-------------------------------------------------------------------------------------------"
      ?? space(0) + "ITEM----------------------------" + repl("-",PLU_DESC_LEN+PLU_CODE_LEN+36) 
      
      ?  MARGIN + padr ( "Code",         4 )
      ?? space(2) + padr ( "Name",        20 )
      ?? space(2) + padr ( "Number", 8 )
      ?? space(2) + padr ( "Trans Date",  10 )
      ?? space(2) + padr ( "Date Retrn",  10 )
      ?? space(2) + padr ( "RR Ref",       8 )
      ?? space(2) + padr ( " ",            1 )
      ?? space(2) + padr ( "Reference",   10 )
      ?? space(2) + padr ( "Ref Date",    10 )
      ?? space(2) + padr ( "Code",        PLU_CODE_LEN )
      ?? space(2) + padr ( "Description", PLU_DESC_LEN )
      ?? space(4) + padl ( "Qty Retn",    11 )
      ?? space(2) + padr ( "Unit",     10 )
      ?? space(2) + padl ( "Unit Cost",    9 )
      ?? space(2) + padl ( "Sell Prce",    9 )
      ?? space(2) + padl ( "Total Cost",  14 )

       ? MARGIN + repl ( "-", THIS_WIDTH - LEFT_MARGIN)
      nCtr += 5 
RETURN NIL

/*============================================================================

============================================================================*/
STATIC FUNCTION it31000302

    ? MARGIN + replicate ( "-", THIS_WIDTH - LEFT_MARGIN)
    ? MARGIN + "   PAGE TOTAL" 
   ?? space(93+PLU_CODE_LEN+PLU_DESC_LEN) + tran( pttl[1], "99,999,999" )
   ?? space(36)  + tran( pttl[2], "999,999,999.99" )

    ? MARGIN +  "RUNNING TOTAL" 
   ?? space(93+PLU_CODE_LEN+PLU_DESC_LEN) + tran( gttl[1], "99,999,999" )
   ?? space(36)  + tran( gttl[2], "999,999,999.99" )
    ? MARGIN + replicate ( "-", THIS_WIDTH - LEFT_MARGIN)   

   afill ( pttl, 0 )
   nCtr += 4

RETURN NIL

/*============================================================================
============================================================================*/
STATIC FUNCTION it31000303

   // Accumulate quantity received.
   pttl[1] += RJ_ITEMS->RJI_QRET
   gttl[1] += RJ_ITEMS->RJI_QRET

   // Accumulate total cost.
   pttl[2] += nTCost
   gttl[2] += nTCost

RETURN NIL

