/*============================================================================

   (c) 1993  TECHNO SOFTWARE CORPORATION

   This module contains information proprietary to TECHNO SOFTWARE
   CORPORATION, and should be treated confidential.

   it310009.prg - Inventory Variance Report module
             for Inventory Tracking System (ITS)

   acr / 05.17.93
   eso / 09.24.95 replaced prow() with nCtr

============================================================================*/
#include "Janus.ch"
#include "its.ch"
#include "set.ch"
#include "setcurs.ch"
#include "inkey.ch"

#define RPT_ID   "IV-REP-D"
#define RPT_NAME "INVENTORY VARIANCE REPORT"
#define THIS_WIDTH 135 + PLU_DESC_LEN +LEFT_MARGIN +PLU_CODE_LEN

memvar nUnit, getlist 

STATIC pttl[2], gttl[2]
STATIC nPage := 0, footer_now := 0
STATIC qty_var := 0, qty_ratio := 0, amt_var := 0, amt_ratio := 0
static nCtr := 0, sdate

/*=================================*/
FUNCTION it310009 
/*=================================*/
   LOCAL cOldClr := setcolor ( BN_COLOR ), nOldCursor := 0
   local nGoPrint := 2, invr, lStartLine := .f.
   LOCAL vBrowse

   sdate := date() 
   SET CURSOR ON
   vBrowse := OpenWindow(10,30,12,50)
   @ 10,35 say "REPORT DATE"
   @ 11,33 say "Date: "Get sdate
   read
   if lastkey() == K_ESC
      SET CURSOR OFF
      CloseWindow(vBrowse)
      return nil
   endif   
   SET CURSOR OFF
   CloseWindow(vBrowse)


   afill (pttl, 0)
   afill (gttl, 0)

   // Create display window.
   window( 19, 1, 22, 60, CONFIRM_COLOR )
   @ 1, 1 wsay " Creating " + RPT_NAME + ".  Please wait ..."

   if NetUse("UNIT",DB_SHARED,NUM_SECONDS)
      set Index to UNIT
   endif  
   if UNIT->(DbSeek(padl(alltrim(str(nUnit)),3,"0"))) 
      Set(_SET_PATH,UNIT->UNIT_PATH)
   endif   
   if NetUse("UITEMS",DB_SHARED,NUM_SECONDS)
      Set Index to UITEMS
   endif      

   if NetUse("ITEM.DBF",DB_SHARED,NUM_SECONDS)
     //  Set Index to I_001
     index on ITEM->I_020 to invr
   endif   

   if NetUse("V",DB_SHARED,NUM_SECONDS)
      Set Index to V_001
   endif   

   set filter to ITEM->I_019 != 2     // Revised ATC 07-21-93.
   ITEM->(dbGoTop())

#ifdef TO_FILE
   set printer to ".\"+RPT_ID
#endif

   set device to printer
   set printer on
   set console off

   // Standard page header routine.
   it390003 ( SYS_NAME, RPT_NAME, THIS_WIDTH, LEFT_MARGIN, RIGHT_MARGIN )
   nCtr := 1
   nPage := 1

   // Print the headers for this report.
   it31000901()   

   do while V->(!Eof())


      // Indicate record being processed.
      @ 2, 1 wsay " Item: " + V->V_001

      // Print on next row.
         ? MARGIN + V->V_001
        ?? space(2) + V->V_002
        nCtr += 1

      lStartLine := .f.        
      ITEM->(DbSeek(V->V_001))
      while ITEM->(!Eof()) .and. V->V_001 == ITEM->I_020
         if ITEM->(!Deleted())  .and. UITEMS->(DbSeek(ITEM->I_001))               
          IF UITEMS->UI_STK_BAL <> 0
           if lStartLine
             ? MARGIN + space(35)
             nCtr += 1
           endif  
            ?? space(2) + ITEM->I_001 
            ?? space(2) + ITEM->I_002 
            ?? space(2) + tran(UITEMS->UI_P_COUNT, "999,999,999" )
            ?? space(2) + tran(UITEMS->UI_STK_BAL, "999,999,999" )
            ?? space(2) + ITEM->I_005 
            ?? space(2) + tran( ITEM->i_007, "99,999.99" )
            ?? space(2) + tran( ITEM->i_003, "99,999.99" )

            qty_var   = UITEMS->UI_P_COUNT - (UITEMS->UI_STK_BAL)
            qty_ratio = (qty_var / UITEMS->UI_P_COUNT) * 100
            amt_var   = (UITEMS->UI_P_COUNT * ITEM->i_007) - ((UITEMS->UI_STK_BAL) * ITEM->i_007)
            amt_ratio = (amt_var / (UITEMS->UI_P_COUNT * ITEM->i_007)) * 100

            ?? space(2) + tran(qty_var,   "999,999,999" )
            ?? space(2) + tran(qty_ratio, "999.99" )

            ?? space(2) + tran(amt_var,   "999,999,999.99" )
            ?? space(2) + tran(amt_ratio, "999.99" )

            // Accumulate the page and grand total and count.
            it31000903()
            lStartLine := .t.
            if ITEM->(!eof()) .and. nCtr == 55
               it31000902()
               nCtr := 0
               it390006 ( RPT_ID, THIS_WIDTH, LEFT_MARGIN, RIGHT_MARGIN, nPage )
               npage += 1                              
               eject
               it390003 ( SYS_NAME, RPT_NAME, THIS_WIDTH, LEFT_MARGIN, RIGHT_MARGIN )
               nCtr := 1   
               it31000901()
            endif   
          ENDIF  
         endif
         ITEM->(Dbskip())
     enddo
     V->(DbSkip())
  enddo
  
   // Print the page totals.
   it31000902()

    ? MARGIN + "END OF REPORT" + replicate ( "=", THIS_WIDTH - LEFT_MARGIN - 13) 
   it390006 ( RPT_ID, THIS_WIDTH, LEFT_MARGIN, RIGHT_MARGIN, nPage )
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

   // Screen or Printed Reports.
   RepGen( ".\"+RPT_ID, RPT_NAME, 2, 214 )
   ferase("invr.ntx")

RETURN NIL

/*=================================*/
FUNCTION it310009p 
/*=================================*/
LOCAL cOldClr := setcolor ( BN_COLOR ), nOldCursor := 0
local nGoPrint := 2, invr, lStartLine := .f.
local vRecord := space(3), vBrowse, getlist := {}

   sdate := date()
   SET CURSOR ON
   vBrowse := OpenWindow(10,30,12,50)
   @ 10,35 say "REPORT DATE"
   @ 11,33 say "Date: "Get sdate
   read
   if lastkey() == K_ESC
      SET CURSOR OFF
      CloseWindow(vBrowse)
      return nil
   endif   
   SET CURSOR OFF
   CloseWindow(vBrowse)

   vBrowse := OpenWindow(15,30,17,50)
   @ 16,31 say "Supplier Code: "Get vRecord Pict "999"
   setCursor("ON")
   read
   setCursor("OFF")
   CloseWindow(vBrowse)

   vRecord := padl(alltrim(vRecord),3,"0")

   afill (pttl, 0)
   afill (gttl, 0)

   // Create display window.
   window( 19, 1, 22, 60, CONFIRM_COLOR )
   @ 1, 1 wsay " Creating " + RPT_NAME + ".  Please wait ..."

   if NetUse("UNIT",DB_SHARED,NUM_SECONDS)
      set Index to UNIT
   endif  
   if UNIT->(DbSeek(padl(alltrim(str(nUnit)),3,"0"))) 
      Set(_SET_PATH,UNIT->UNIT_PATH)
   endif   
   if NetUse("UITEMS",DB_SHARED,NUM_SECONDS)
      Set Index to UITEMS
   endif      

   if NetUse("ITEM.DBF",DB_SHARED,NUM_SECONDS)
     //  Set Index to I_001
     index on ITEM->I_020 to invr
   endif   

   if NetUse("V",DB_SHARED,NUM_SECONDS)
      Set Index to V_001
   endif   

   set filter to ITEM->I_019 != 2     // Revised ATC 07-21-93.
   ITEM->(dbGoTop())

#ifdef TO_FILE
   set printer to ".\"+RPT_ID
#endif

   set device to printer
   set printer on
   set console off

   // Standard page header routine.
   it390003 ( SYS_NAME, RPT_NAME, THIS_WIDTH, LEFT_MARGIN, RIGHT_MARGIN )
   nCtr := 1
   nPage := 1

   // Print the headers for this report.
   it31000901()   
   lStartLine := .f.
   if ITEM->(DbSeek(vRecord))

      // Indicate record being processed.
      @ 2, 1 wsay " Item: " + vRecord

      // Print on next row.
      if V->(DbSeek(ITEM->I_020))
         ? MARGIN + V->V_001
        ?? space(2) + V->V_002
        nCtr += 1
      endif  

      while ITEM->(!Eof()) .and. vRecord == ITEM->I_020
       if ITEM->(!Deleted())  .and. UITEMS->(DbSeek(ITEM->I_001))               
         IF UITEMS->UI_STK_BAL <> 0
          if lStartLine
            ? MARGIN + space(35)
            nCtr += 1
          endif  
            ?? space(2) + ITEM->I_001 
            ?? space(2) + ITEM->I_002 
            ?? space(2) + tran(UITEMS->UI_P_COUNT, "999,999,999" )
            ?? space(2) + tran(UITEMS->UI_STK_BAL, "999,999,999" )
            ?? space(2) + ITEM->I_005 
            ?? space(2) + tran( ITEM->i_007, "99,999.99" )
            ?? space(2) + tran( ITEM->i_003, "99,999.99" )

            qty_var   = UITEMS->UI_P_COUNT - (UITEMS->UI_STK_BAL)
            qty_ratio = (qty_var / UITEMS->UI_P_COUNT) * 100
            amt_var   = (UITEMS->UI_P_COUNT * ITEM->i_007) - ((UITEMS->UI_STK_BAL) * ITEM->i_007)
            amt_ratio = (amt_var / (UITEMS->UI_P_COUNT * ITEM->i_007)) * 100

            ?? space(2) + tran(qty_var,   "999,999,999" )
            ?? space(2) + tran(qty_ratio, "999.99" )

            ?? space(2) + tran(amt_var,   "999,999,999.99" )
            ?? space(2) + tran(amt_ratio, "999.99" )

            // Accumulate the page and grand total and count.
            it31000903()
            lStartLine := .t.
            if ITEM->(!eof()) .and. nCtr == 55
               it31000902()
               nCtr := 0
               it390006 ( RPT_ID, THIS_WIDTH, LEFT_MARGIN, RIGHT_MARGIN, nPage )
               npage += 1                              
               eject
               it390003 ( SYS_NAME, RPT_NAME, THIS_WIDTH, LEFT_MARGIN, RIGHT_MARGIN )
               nCtr := 1   
               it31000901()
            endif   
          ENDIF  
         endif
         ITEM->(Dbskip())
     enddo
   else
      Message("Supplier Code :"+vRecord+" not found ...")
      BUMMER()
   endif  
   
   // Print the page totals.
   it31000902()

    ? MARGIN + "END OF REPORT" + replicate ( "=", THIS_WIDTH - LEFT_MARGIN - 13) 
   it390006 ( RPT_ID, THIS_WIDTH, LEFT_MARGIN, RIGHT_MARGIN, nPage )
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

   // Screen or Printed Reports.
   RepGen( ".\"+RPT_ID, RPT_NAME, 2, 214 )
   ferase("invr.ntx")

RETURN NIL


/*============================================================================
   Page Header
============================================================================*/
STATIC FUNCTION it31000901()

    ? MARGIN + "Report Date: As of  " + dtoc(sDate)
   ?? space(105) + "UNIT " +  padl(alltrim(str(nUnit)),3,"0")
    ? MARGIN + "SUPPLIER------------------------------"
   ?? space(0) + "ITEM--------------------------------------------------"
   ?? repl("-",PLU_DESC_LEN+PLU_CODE_LEN+11) 
   ?? space(2) + "Quantity--------------  Amount----------"
   
    ? MARGIN + padr ( "Code", 4 )
   ?? space(2) + padr ("Name", 30) 
   ?? space(2) + padr ( "Code", PLU_CODE_LEN )
   ?? space(2) + padr ( "Description",PLU_DESC_LEN )
   ?? space(2) + padl ( "Phys Count",     11 )
   ?? space(2) + padl ( "Qty on Hand",    11 )
   ?? space(2) + padr ( "Unit",        10 )
   ?? space(2) + padl ( "Unit Cost",       9 )
   ?? space(2) + padl ( "Sell Prce",       9 )
   ?? space(2) + padl ( "Variance",       11 )
   ?? space(2) + padl ( "Ratio",           6 )
   ?? space(2) + padl ( "Variance",       14 )
   ?? space(2) + padl ( "Ratio",           6 )

    ? MARGIN + replicate ( "-", THIS_WIDTH - LEFT_MARGIN)
   nCtr += 4 
RETURN NIL

/*============================================================================
============================================================================*/
STATIC FUNCTION it31000902()

    ? MARGIN + replicate ( "-", THIS_WIDTH - LEFT_MARGIN)
    ? MARGIN + "   PAGE TOTAL" 
   ?? space(88+PLU_CODE_LEN+PLU_DESC_LEN) + tran( pttl[1], "999,999,999" )
   ?? space(10) + tran( pttl[2], "999,999,999.99" )

    ? MARGIN + "RUNNING TOTAL" 
   ?? space(88+PLU_CODE_LEN+PLU_DESC_LEN) + tran( gttl[1], "999,999,999" )
   ?? space(10) + tran( gttl[2], "999,999,999.99" )
    ? MARGIN + replicate ( "-", THIS_WIDTH - LEFT_MARGIN)   

   nctr += 4
   afill (pttl, 0)

RETURN NIL

/*============================================================================
============================================================================*/
STATIC FUNCTION it31000903

   // Accumulate quantity / amount pairs.
   pttl[1] += qty_var
   pttl[2] += amt_var

   gttl[1] += qty_var
   gttl[2] += amt_var

RETURN NIL

