/*============================================================================

   (c) 1993  TECHNO SOFTWARE CORPORATION

   This module contains information proprietary to TECHNO SOFTWARE
   CORPORATION, and should be treated confidential.

   R_STKTRN.prg - Stock Transfer Register module
                  wfor Inventory Tracking System (ITS)

============================================================================*/
#include "Janus.ch"
#include "its.ch"
#include "set.ch"
#include "setcurs.ch"

#define RPT_ID     "ST-REG-D"
#define RPT_ID_M   "ST-REP-M"
#define RPT_NAME   "STOCK TRANSFER REGISTER"
#define RPT_NAME_M "STOCK TRANSFER REPORT"
#define THIS_WIDTH (117 +PLU_CODE_LEN+PLU_DESC_LEN + LEFT_MARGIN)

STATIC pttl[2], gttl[2]
STATIC nPage := 0, nTCost := 0, footer_now := 0
static nCtr := 0

function do_R_StkTransfer ( )
local cRptName, cRptID
local cOldClr := setcolor ( BN_COLOR ), nOldCursor := 0
local cSARef := space(8), dTDate := ctod ("")
local nGoPrint := 2, lStartLine := .f.
local lMark := .f. , getlist := {}, dBrowse, edate := date(), sdate := date()

   SET CURSOR ON 
   dBrowse := OpenWindow(15,20,17,55)
   @ 15,27 say "Date Transferred Range"
   @ 16,21 say "From: "Get sdate
   @ 16,40 say "To: "Get edate
   read
   SET CURSOR OFF
   CloseWindow(dBrowse)  
   
   nTCost := 0
   footer_now := 0

   afill ( pttl, 0 )
   afill ( gttl, 0 )

   cRptName := RPT_NAME
   cRptID   := RPT_ID

   nOldCursor = setcursor ( SC_NONE )

   // Create display window.
   window( 19, 1, 22, 60, CONFIRM_COLOR )
   @ 1, 1 wsay " Creating " + cRptName + ".  Please wait ..."

   if NetUse("ITEM.DBF",DB_SHARED,NUM_SECONDS)
      Set Index to I_001
   endif   

   if NetUse("V",DB_SHARED,NUM_SECONDS)
      Set Index to V_001
   endif   
   
   if NetUse("ST",DB_SHARED,NUM_SECONDS)
     // Set Index to ST_001
     index on ST->ST_007 to stvcode
   endif      

   if NetUse("ST_ITEMS",DB_SHARED,NUM_SECONDS)
      Set Index to STI_LINK
   endif      

   ST->(dbGoTop())

#ifdef TO_FILE
   Set( 24, ".\"+cRptID, .F. )
#endif

   set device to printer
   set printer on
   set console off

   // Standard page header routine.
   it390003 ( SYS_NAME, cRptName, THIS_WIDTH, LEFT_MARGIN, RIGHT_MARGIN )
   nPage := 1
   nCtr := 1

   // Print the headers for this report.
   it31000701(sdate,edate)

   while V->(!Eof())
     
    // Indicate record being processed.
    @ 2, 1 wsay " Stock Trn.: " + ST->ST_007

    lStartLine := .f.

    ST->(DbSeek(V->V_001))  
    While ST->(!Eof()) .and. V->V_001 == ST->ST_007
      if ST->ST_004 >= sdate .and. ST->ST_004 <= edate     
          
      ? MARGIN   + ST->ST_001
      ?? space(3) + ST->ST_002
      ?? space(2) + ST->ST_003
      ?? space(2) + DTOC(ST->ST_004)
      ?? space(2) + ST->ST_007 
      ?? space(3) + ST->ST_008 
      nCtr += 1

      ST_ITEMS->(DbSeek(ST->ST_001))
      while  ST_ITEMS->STI_LINK == ST->ST_001 .and. ST_ITEMS->(!Eof())
         if ST_ITEMS->(!Deleted()) 
          if lMark 
            ? MARGIN   + space(28)
            ?? MARGIN   + space(8)
            ?? space(2) + space(4)
            ?? space(2) + space(3)
            ?? space(2) + space(8)
            nCtr += 1
          endif 
             
          // Find item cross reference.          
          ITEM->(DbSeek(ST_ITEMS->STI_ITEM))         
          
          ?? space(2) + ST_ITEMS->STI_ITEM
          ?? space(2) + ITEM->I_002
          ?? space(5) + tran(ST_ITEMS->STI_QADJ,"99,999,999")
          ?? space(2) + ITEM->I_005  // Measure         
          ?? space(2) + tran(ITEM->I_003,"999,999.99")

          nTCost = ITEM->I_003 * ST_ITEMS->STI_QADJ
           
          ?? space(2) + tran(nTCost,"999,999,999.99")
          
          
          // Accumulate the page and grand total and count.
          pttl[1] += ST_ITEMS->STI_QADJ
          pttl[2] += nTCost

          gttl[1] += ST_ITEMS->STI_QADJ
          gttl[2] += nTCost
          
          lMark := .t.               
          lStartline := .t.               
          if ST_ITEMS->(!eof()) .and. nCtr == 55
               it31000702()
               nCtr := 0
               it390006 ( cRptID, THIS_WIDTH, LEFT_MARGIN, RIGHT_MARGIN, nPage )
               npage += 1                              
               eject
               it390003 ( SYS_NAME, cRptName, THIS_WIDTH, LEFT_MARGIN, RIGHT_MARGIN )
               nCtr := 1   
               it31000701(sdate,edate)
          endif   
        endif
        ST_ITEMS->(DbSkip())  
      
      enddo 
      lMark := .f.
      endif
      ST->(DbSkip())

   enddo
   V->(DbSkip())
 enddo  

   // Print the page totals.
   it31000702()

    ? MARGIN + "END OF REPORT" + replicate ( "=", THIS_WIDTH - LEFT_MARGIN - 13) 
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

   // Screen or Printed Reports.
   RepGen( ".\"+cRptID, cRptName, 1, 180 )

RETURN NIL



function do_PR_StkTransfer ( )
local cRptName, cRptID
local cOldClr := setcolor ( BN_COLOR ), nOldCursor := 0
local cSARef := space(8), dTDate := ctod ("")
local nGoPrint := 2, lStartLine := .f.
local lMark := .f. , getlist := {}, dBrowse, edate := date(), sdate := date()
local vBrowse, vRecord := space(3)


   SET CURSOR ON
   vBrowse := OpenWindow(15,30,17,50)
   @ 16,31 say "Supplier Code: "Get vRecord Pict "999"
   read
   SET CURSOR OFF
   CloseWindow(vBrowse)

   vRecord := padl(alltrim(vRecord),3,"0")

   SET CURSOR ON 
   dBrowse := OpenWindow(15,20,17,55)
   @ 15,27 say "Date Transferred Range"
   @ 16,21 say "From: "Get sdate
   @ 16,40 say "To: "Get edate
   read
   SET CURSOR OFF
   CloseWindow(dBrowse)  
   
   nTCost := 0
   footer_now := 0

   afill ( pttl, 0 )
   afill ( gttl, 0 )

   cRptName := RPT_NAME
   cRptID   := RPT_ID

   nOldCursor = setcursor ( SC_NONE )

   // Create display window.
   window( 19, 1, 22, 60, CONFIRM_COLOR )
   @ 1, 1 wsay " Creating " + cRptName + ".  Please wait ..."

   if NetUse("ITEM.DBF",DB_SHARED,NUM_SECONDS)
      Set Index to I_001
   endif   

   if NetUse("V",DB_SHARED,NUM_SECONDS)
      Set Index to V_001
   endif   
   
   if NetUse("ST",DB_SHARED,NUM_SECONDS)
     // Set Index to ST_001
     index on ST->ST_007 to stvcode
   endif      

   if NetUse("ST_ITEMS",DB_SHARED,NUM_SECONDS)
      Set Index to STI_LINK
   endif      

   ST->(dbGoTop())

#ifdef TO_FILE
   Set( 24, ".\"+cRptID, .F. )
#endif

   set device to printer
   set printer on
   set console off

   // Standard page header routine.
   it390003 ( SYS_NAME, cRptName, THIS_WIDTH, LEFT_MARGIN, RIGHT_MARGIN )
   nPage := 1
   nCtr := 1

   // Print the headers for this report.
   it31000701(sdate,edate)

  IF ST->(DbSeek(Vrecord))       
    // Indicate record being processed.
    @ 2, 1 wsay " Stock Trn.: " + ST->ST_007

    While ST->(!Eof()) .and. Vrecord == ST->ST_007
     if ST->ST_004 >= sdate .and. ST->ST_004 <= edate     
          
      ? MARGIN   + ST->ST_001
      ?? space(3) + ST->ST_002
      ?? space(2) + ST->ST_003
      ?? space(2) + DTOC(ST->ST_004)
      ?? space(2) + ST->ST_007 
      ?? space(3) + ST->ST_008 
      nCtr += 1

      ST_ITEMS->(DbSeek(ST->ST_001))
      while  ST_ITEMS->STI_LINK == ST->ST_001 .and. ST_ITEMS->(!Eof())
         if ST_ITEMS->(!Deleted()) 
          if lMark 
            ? MARGIN   + space(28)
            ?? MARGIN   + space(8)
            ?? space(2) + space(4)
            ?? space(2) + space(3)
            ?? space(2) + space(8)
            nCtr += 1
          endif 
             
          // Find item cross reference.          
          ITEM->(DbSeek(ST_ITEMS->STI_ITEM))         
          
          ?? space(2) + ST_ITEMS->STI_ITEM
          ?? space(2) + ITEM->I_002
          ?? space(5) + tran(ST_ITEMS->STI_QADJ,"99,999,999")
          ?? space(2) + ITEM->I_005  // Measure                    
          ?? space(2) + tran(ITEM->I_003,"999,999.99")

          nTCost = ITEM->I_003 * ST_ITEMS->STI_QADJ
           
          ?? space(2) + tran(nTCost,"999,999,999.99")
          
          
          // Accumulate the page and grand total and count.
          pttl[1] += ST_ITEMS->STI_QADJ
          pttl[2] += nTCost

          gttl[1] += ST_ITEMS->STI_QADJ
          gttl[2] += nTCost
          
          lMark := .t.               
          lStartline := .t.               
          if ST_ITEMS->(!eof()) .and. nCtr == 55
               it31000702()
               nCtr := 0
               it390006 ( cRptID, THIS_WIDTH, LEFT_MARGIN, RIGHT_MARGIN, nPage )
               npage += 1                              
               eject
               it390003 ( SYS_NAME, cRptName, THIS_WIDTH, LEFT_MARGIN, RIGHT_MARGIN )
               nCtr := 1   
               it31000701(sdate,edate)
          endif   
        endif
        ST_ITEMS->(DbSkip())  
      
      enddo 
      lMark := .f.
      
      endif
      ST->(DbSkip())

   enddo
  else
     Message("Supplier Code :"+vRecord+" not found ...")
     BUMMER()
  endif    

   // Print the page totals.
   it31000702()

    ? MARGIN + "END OF REPORT" + replicate ( "=", THIS_WIDTH - LEFT_MARGIN - 13) 
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

   // Screen or Printed Reports.
   RepGen( ".\"+cRptID, cRptName, 1, 180 )

RETURN NIL


/*============================================================================
   Page Header
============================================================================*/
STATIC FUNCTION it31000701(startd,endate)

       ? MARGIN   + "From: " + dtoc(startd) + "  To: " + dtoc(endate) 
       ? MARGIN   + "STOCK TRANSFER-----------------" +;
           "Supplier--------------------Item----------" + repl ("-",PLU_DESC_LEN + PLU_CODE_LEN + 44)

      
      ?  MARGIN    + padr ( "Number", 8 )
      ?? space (2) + padr ( "From",4 )
      ?? space (2) + padr ( "To:",3 )
      ?? space (2) + padr ( "Date",8 )
      ?? space(2)  + padr ( "Code",4)
      ?? space(2)  + padr ( "   Name",20)      
      ?? space (2) + padr ( "Code",        PLU_CODE_LEN )
      ?? space (2) + padr ( "Description", PLU_DESC_LEN )
      ?? space (4) + padl ( "Qty Trn",     11 )
      ?? space (2) + padr ( "Measure",     10 )
      ?? space (2) + padl ( "Sell Prce",   10 )
      ?? space (2) + padl ( "Total Cost",  14 )

       ? MARGIN + replicate ( "-", THIS_WIDTH - LEFT_MARGIN)
      nCtr += 4 
RETURN NIL

/*============================================================================
============================================================================*/
STATIC FUNCTION it31000702

    ? MARGIN + replicate ( "-", THIS_WIDTH - LEFT_MARGIN)
    ? MARGIN + "   PAGE TOTAL" 
   ?? space(53+PLU_DESC_LEN+PLU_CODE_LEN) + tran(pttl[1], "99,999,999" )
   ?? space(26) + tran(pttl[2], "999,999,999.99" )

    ? MARGIN + "RUNNING TOTAL" 
   ?? space(53+PLU_DESC_LEN+PLU_CODE_LEN) + tran(gttl[1], "99,999,999" )
   ?? space(26) + tran(gttl[2], "999,999,999.99" )
    ? MARGIN + replicate ( "-", THIS_WIDTH - LEFT_MARGIN)
    
   nCtr += 4 
   afill ( pttl, 0 )

RETURN NIL


