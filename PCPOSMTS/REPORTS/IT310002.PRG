/*============================================================================

   (c) 1993  TECHNO SOFTWARE CORPORATION

   This module contains information proprietary to TECHNO SOFTWARE
   CORPORATION, and should be treated confidential.

   it310002.prg - Receiving module
         for Inventory Tracking System (ITS)

   acr / 05.17.93
   eso / 09.21.95 changed prow() with nCtr 

============================================================================*/
#include "Janus.ch"
#include "its.ch"
#include "set.ch"
#include "setcurs.ch"

#define RPT_ID     "RR-REG-D"
#define RPT_ID_M   "RR-REP-M"
#define RPT_NAME   "RECEIVING REGISTER"
#define RPT_NAME_M "RECEIVING REPORT"
#define THIS_WIDTH (186 + PLU_DESC_LEN + PLU_CODE_LEN + LEFT_MARGIN)
 
static pttl[4], gttl[4]
static nPage := 0, nTCost := 0, footer_now := 0
static nCtr := 0

/*=======================================*/
function it310002 ( nReportSwitch )
/*=======================================*/

local cOldClr := setcolor ( BN_COLOR ), nOldCursor := 0
local cRptName, cRptID, lStartLine, lPOfound := .f.
local cRRRef := space(8), dTDate := NIL, dRdate := NIl
local nGoPrint := 2, flag := .f., getlist := {}, aFields := {}
local sdate:=Date(), edate:=Date(), vBrowse


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

   SET CURSOR ON
   vBrowse := OpenWindow(15,20,17,55)
   @ 15,27 say "Date Received Range"
   @ 16,21 say "From: "Get sdate
   @ 16,40 say "To: "Get edate
   read
   SET CURSOR OFF
   CloseWindow(vBrowse)
   
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
   

   if Netuse("RR_ITEMS",DB_SHARED,NUM_SECONDS)
      Set Index to RRI_LINK 
   endif   

   if NetUse("RR",DB_SHARED,NUM_SECONDS)
    //  Set Index to RR_001
    index on RR->RR_002 to rrvcode
   endif   


   RR->(DbGoTop())

#ifdef TO_FILE
   Set( 24, ".\"+cRptID, .F. )
#endif  

   set device to printer
   set printer on
   set console off

   // Standard page header routine.
   it390003 ( SYS_NAME, cRptName, THIS_WIDTH, LEFT_MARGIN, RIGHT_MARGIN )
   // added nCtr 
   nCtr := 1   
   nPage := 1

   // Print the headers for this report.
   it31000201(sdate,edate)
   
      
   while V->(!Eof())
    
      
      // Indicate record being processed.
      @ 2, 1 wsay " RR: " + RR->RR_002
      RR->(DbSeek(V->V_001)) 
      if RR->RR_006 >= sdate .and. RR->RR_006 <= edate
       if RR->RR_002 == V->V_001
        ? MARGIN   + RR->RR_002 
        ?? space(2) + RR->RR_003 
        nCtr += 1
       ENDIF 

      lStartLine := .f.

      RR->(DbSeek(V->V_001))
      while RR->(!Eof()) .and. V->V_001 == RR->RR_002
       
         if RR->(!Deleted())          
            RR_ITEMS->(DbSeek(RR->RR_001)) 
            flag := .f.
           while RR_ITEMS->(!EOF()) .AND. RR->RR_001 == RR_ITEMS->RRI_LINK
           if RR_ITEMS->(!Deleted())
            if lStartLine
              ? MARGIN + space(35) 
              nCtr += 1
            endif
            if !flag 
            ?? space(5) + RR->RR_001
            ?? space(4) + dtoc(RR->RR_005) 
            ?? space(3) + dtoc(RR->RR_006) 
            ?? space(4) + trans(RR->RR_007,"9")
            ?? space(2) + RR->RR_008 
            ?? space(2) + dtoc(RR->RR_009)  
            ?? space(2) + RR->RR_004
            else
               ?? MARGIN + space(80)
            endif    
            ?? space(2) + RR_ITEMS->RRI_ITEM    
            if ITEM->(DbSeek(RR_ITEMS->RRI_ITEM))
              ?? space(2) + ITEM->I_002 
              ?? space(5) + tran( RR_ITEMS->RRI_QREC, "99,999,999" )
              ?? space(2) +  ITEM->I_005 
              ?? space(2) + trans( ITEM->i_007, "99,999.99" ) 
              ?? space(2) + trans( ITEM->i_003, "99,999.99" ) 
               nTCost = RR_ITEMS->RRI_QREC * ITEM->i_007
              ?? space(2) + trans( nTCost,"999,999,999.99" )
            else
              ?? " NO RECORDS FOUND "
            endif      
            
              // Accumulate the page and grand total and count.
              it31000203()
              lStartLine := .t.
              flag := .t.
            if RR_ITEMS->(!eof()) .and. nCtr == 55
               it31000202()
               nCtr := 0
               it390006 ( cRptID, THIS_WIDTH, LEFT_MARGIN, RIGHT_MARGIN, nPage )
               npage += 1                              
               eject
               it390003 ( SYS_NAME, cRptName, THIS_WIDTH, LEFT_MARGIN, RIGHT_MARGIN )
               nCtr := 1   
               it31000201(sdate,edate)
            endif   
            endif
            RR_ITEMS->(DbSkip()) 
           enddo
         endif   
         RR->(DbSkip())
      enddo   
      endif
      V->(DbSkip())
   enddo 
 
   // Print the page totals.
     it31000202()

    ? MARGIN + "END OF REPORT" + replicate ( "=", THIS_WIDTH - LEFT_MARGIN - 13)
   it390006 ( cRptID, THIS_WIDTH, LEFT_MARGIN, RIGHT_MARGIN, nPage )
   // added nCtr += 2, for ? margin & it390006 
   //nCtr += 2
   eject

   dbCloseAll()

   // COND_OFF
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

   // Screen or Printed Reports.
   RepGen( ".\"+cRptID, cRptName, 1, 214 )
ferase("rrvcode.ntx")

RETURN NIL

/*==================================*/
function it31000 ( nReportSwitch )
/*==================================*/

local cOldClr := setcolor ( BN_COLOR ), nOldCursor := 0
local cRptName, cRptID, lStartLine, lPOfound := .f.
local cRRRef := space(8), dTDate := NIL, dRdate := NIl
local nGoPrint := 2, vRecord := space(3), vBrowse
local getlist := {}, flag := .f., edate := Date()
local sdate := Date(), dBrowse

   SET CURSOR ON
   vBrowse := OpenWindow(15,30,17,50)
   @ 16,31 say "Supplier Code: "Get vRecord Pict "999"
   read
   SET CURSOR OFF
   CloseWindow(vBrowse)

   vRecord := padl(alltrim(vRecord),3,"0")

   SET CURSOR ON 
   dBrowse := OpenWindow(15,20,17,55)
   @ 15,27 say "Date Received Range"
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

   afill (pttl, 0)
   afill (gttl, 0)
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
   

   if Netuse("RR_ITEMS",DB_SHARED,NUM_SECONDS)
      Set Index to RRI_LINK 
   endif   

   if NetUse("RR",DB_SHARED,NUM_SECONDS)
    //  Set Index to RR_001
    index on RR->RR_002 to rrvcode
   endif   


/*   if nReportSwitch = 2
      dbSetFilter( {|| RR->RR_010 = 2}, "RR->RR_010 = 2" ) 
   else
      dbSetFilter( {|| RR->RR_010 < 2}, "RR->RR_010 < 2" ) 
   endif */

   RR->(DbGoTop())

#ifdef TO_FILE
   Set( 24, ".\"+cRptID, .F. )
#endif  

   set device to printer
   set printer on
   set console off


   // Standard page header routine.
   it390003 ( SYS_NAME, cRptName, THIS_WIDTH, LEFT_MARGIN, RIGHT_MARGIN )
   // added nCtr 
   nCtr += 1   
   nPage := 1


   // Print the headers for this report.
   it31000201(sdate,edate)
      

      lStartLine := .f.

   if RR->(DbSeek(vRecord))
        @ 2, 1 wsay " RR: " + RR->RR_002
        ? MARGIN   + RR->RR_002 
       ?? space(2) + RR->RR_003 
       nCtr += 1
      
      while RR->(!Eof()) .and. vRecord == RR->RR_002
        if RR->RR_006 >= sdate .and. RR->RR_006 <= edate     
         if RR->(!Deleted()) 
            RR_ITEMS->(DbSeek(RR->RR_001)) 
            flag := .f.
           while RR_ITEMS->(!EOF()) .AND. RR->RR_001 == RR_ITEMS->RRI_LINK
           if RR_ITEMS->(!Deleted())
            if lStartLine
              ? MARGIN + space(35) 
              nCtr += 1
            endif
            if !flag
            ?? space(5) + RR->RR_001
            ?? space(4) + dtoc(RR->RR_005) 
            ?? space(3) + dtoc(RR->RR_006) 
            ?? space(4) + trans(RR->RR_007,"9")
            ?? space(2) + RR->RR_008 
            ?? space(2) + dtoc(RR->RR_009)  
            ?? space(2) + RR->RR_004
            else
               ?? MARGIN + space(80)
            endif   
            ?? space(2) + RR_ITEMS->RRI_ITEM 
            if ITEM->(DbSeek(RR_ITEMS->RRI_ITEM))
              ?? space(2) + ITEM->I_002 
              ?? space(5) + tran( RR_ITEMS->RRI_QREC, "99,999,999" )
              ?? space(2) +  ITEM->I_005 
              ?? space(2) + trans( ITEM->i_007, "99,999.99" ) 
              ?? space(2) + trans( ITEM->i_003, "99,999.99" ) 
               nTCost = RR_ITEMS->RRI_QREC * ITEM->i_007
              ?? space(2) + trans( nTCost,"999,999,999.99" )
            else
              ?? " Record not found in master database "
            endif      

            // Accumulate the page and grand total and count.
            it31000203()
            lStartLine := .t.
            flag := .t.
            if RR_ITEMS->(!eof()) .and. nCtr == 55
               it31000202()
               nCtr := 0
               it390006 ( cRptID, THIS_WIDTH, LEFT_MARGIN, RIGHT_MARGIN, nPage )
               npage += 1                              
               eject
               it390003 ( SYS_NAME, cRptName, THIS_WIDTH, LEFT_MARGIN, RIGHT_MARGIN )
               nCtr := 1   
               it31000201(sdate,edate)
            endif   
           endif
           RR_ITEMS->(DbSkip()) 
           enddo
         endif   
        endif 
         RR->(DbSkip())
      enddo   
   else
     Message("Supplier Code :"+vRecord+" not found ...")
     BUMMER()
   endif  
      

   // Print the page totals.
     it31000202()

    ? MARGIN + "END OF REPORT" + replicate ( "=", THIS_WIDTH - LEFT_MARGIN - 13)
   it390006 ( cRptID, THIS_WIDTH, LEFT_MARGIN, RIGHT_MARGIN, nPage )
   // added nCtr += 2, for ? margin & it390006 
  // nCtr += 2
  eject

   dbCloseAll()

   // COND_OFF
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

   // Screen or Printed Reports.
   RepGen( ".\"+cRptID, cRptName, 1, 214 )
   ferase("rrvcode.ntx")

RETURN NIL



/*============================================================================
   Page Header
============================================================================*/
STATIC FUNCTION it31000201(startd,endate)

      ?  MARGIN   + "RECEIVING REPORT"
      ?  MARGIN   + "From: " + dtoc(startd) + "  To: " + dtoc(endate) 
      ?  MARGIN + "Supplier-------------------------------------------------------------------------------------------------------------"
      ?? space(0) + "Item------------------------------------------------------"+REPL("-",PLU_CODE_LEN)+repl("-",PLU_DESC_LEN+11)

       ? MARGIN   + padr ( "Code", 4 )
      ?? space(2) + padr ( "Name", 30 )
      ?? space(2) + padr ( "Rcv. Number", 11)
      ?? space(2) + padr ( "Trans Date", 10)
      ?? space(2) + padr ( "Date Recvd",  10 )
      ?? space(2) + padr ( " ",            1 )
      ?? space(2) + padr ( "Reference",   10 )
      ?? space(2) + padr ( "Ref Date",    8 )
      ?? space(2) + padr ( "Recv. By", 15)
      ?? space(2) + padr ( "Code",        PLU_CODE_LEN )
      ?? space(2) + padr ( "Description", PLU_DESC_LEN )
      ?? space(4) + padr ( "Qty Receive",    11 )
      ?? space(2) + padr ( "Unit",     10 )
      ?? space(2) + padl ( "Unit Cost",    9 )
      ?? space(2) + padl ( "Sell Prce",    9 )
      ?? space(2) + padl ( "Total Cost",  14 )

       ? MARGIN + repl ( "-", THIS_WIDTH - LEFT_MARGIN)
      nCtr += 5 // added this line - eso / 09.21.95
       
RETURN NIL

/*============================================================================
============================================================================*/
STATIC FUNCTION it31000202

    ? MARGIN     + repl( "-", THIS_WIDTH - LEFT_MARGIN)
    ? MARGIN     + "   PAGE TOTAL" 
   ?? space(111+PLU_CODE_LEN+PLU_DESC_LEN) + tran(pttl[1], "99,999,999" )
   ?? space(36)  + tran(pttl[2], "999,999,999.99" )

    ? MARGIN + "RUNNING TOTAL" 
   ?? space(111+PLU_CODE_LEN+PLU_DESC_LEN) + tran(gttl[1], "99,999,999" )
   ?? space(36)  + tran(gttl[2], "999,999,999.99" )

    ? MARGIN     + repl( "-", THIS_WIDTH - LEFT_MARGIN)
    nCtr += 4  // added this line - eso / 09.21.95

   afill ( pttl, 0 )

RETURN NIL


/*============================================================================
============================================================================*/
STATIC FUNCTION it31000203

   // Accumulate quantity received.
   pttl[1] += RR_ITEMS->RRI_QREC
   gttl[1] += RR_ITEMS->RRI_QREC

   // Accumulate total cost.
   pttl[2] += nTCost
   gttl[2] += nTCost

RETURN NIL

