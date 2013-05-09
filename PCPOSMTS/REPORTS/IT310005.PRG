/*============================================================================

   (c) 1993  TECHNO SOFTWARE CORPORATION

   This module contains information proprietary to TECHNO SOFTWARE
   CORPORATION, and should be treated confidential.

   it310005.prg - Stock Out module
         for Inventory Tracking System (ITS)

   acr / 05.17.93
   eso / 09.24.95 replaced prow() with nCtr

============================================================================*/
#include "Janus.ch"
#include "its.ch"
#include "set.ch"
#include "setcurs.ch"

#define RPT_ID   "SO-REP-D"
#define RPT_NAME "STOCK OUT REPORT"
#define THIS_WIDTH (70 + PLU_DESC_LEN + LEFT_MARGIN + PLU_CODE_LEN)

memvar nUnit

static nPage := 0, nTCost := 0, footer_now := 0, so_days := 0
static nCtr := 0


/*==========================================================*/
function it310005()
/*==========================================================*/

local cOldClr := setcolor ( BN_COLOR ), nOldCursor := 0
local nGoPrint, lStartLine := .f.
   nPage := 0

   nOldCursor = setcursor ( SC_NONE )

   // Create display window.
   window ( 19, 1, 22, 60, CONFIRM_COLOR )
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
     * Set index to I_001
     index on ITEM->I_020 to icode
   endif   

   if NetUse("V",DB_SHARED,NUM_SECONDS)
      Set index to V_001
   endif   
   
  // set filter to ITEM->I_019 != 2  // Revised ATC 07-21-93.
     
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
   it31000501()

   while V->(!Eof())

      // Indicate record being processed.
      @ 2, 1 wsay " Item: " + V->V_001

      // Print on next row.
       ? MARGIN + V->V_001 
       ?? space(2) + subs(V->V_002,1,20)   //jzo04-21-98
       nCtr += 1
      lStartLine := .f. 
      ITEM->(DbSeek(V->V_001))
      while ITEM->(!Eof()) .and. V->V_001 == ITEM->I_020
         if ITEM->(!Deleted())   .and. UITEMS->(DbSeek(ITEM->I_001))
            // Check if quantity on hand > 0.
           if UITEMS->UI_STK_BAL > 0 .OR. UITEMS->UI_STK_OUT == CTOD("  /  /  ")
             ITEM->(Dbskip())
             loop
           endif
           if lStartLine
               ?  MARGIN + space(25) 
               nCtr += 1
           endif
           ?? space(2) + ITEM->I_001    
           ?? space(2) + ITEM->I_002 
           ?? space(2) + dtoc(UITEMS->UI_STK_OUT)
           so_days = date() - UITEMS->UI_STK_OUT
           ?? space(18) + tran(so_days, "9,999" )
           lStartLine := .t.
            if ITEM->(!eof()) .and. nCtr == 55
               ?
               ? MARGIN     + repl( "-", THIS_WIDTH - LEFT_MARGIN)
               nCtr := 0
               it390006 ( RPT_ID, THIS_WIDTH, LEFT_MARGIN, RIGHT_MARGIN, nPage )
               npage += 1                              
               eject
               it390003 ( SYS_NAME, RPT_NAME, THIS_WIDTH, LEFT_MARGIN, RIGHT_MARGIN )
               nCtr := 1   
               it31000501()
            endif   
         endif
         ITEM->(DbSkip())
      enddo   
      V->(Dbskip())
   enddo
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

   // Screen or Printed Reports
   RepGen(".\"+RPT_ID, RPT_NAME, 0, 214 )
   ferase("icode.ntx")

return nil


/*==========================================================*/
function it310005p()
/*==========================================================*/

local cOldClr := setcolor ( BN_COLOR ), nOldCursor := 0
local nGoPrint, lStartLine := .f., getlist:={}, vRecord :=Space(3)
local vBrowse
   nPage := 0

   nOldCursor = setcursor ( SC_NONE )

      vBrowse := OpenWindow(15,30,17,50)
      @ 16,31 say "Supplier Code: "Get vRecord Pict "999"
      setCursor("ON")
      read
      setCursor("OFF")
      CloseWindow(vBrowse)

      vRecord := padl(alltrim(vRecord),3,"0")
   

   // Create display window.
   window ( 19, 1, 22, 60, CONFIRM_COLOR )
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
     * Set index to I_001
     index on ITEM->I_020 to icode
   endif   

   if NetUse("V",DB_SHARED,NUM_SECONDS)
      Set index to V_001
   endif   
   
//   set filter to ITEM->I_019 != 2  // Revised ATC 07-21-93.
     
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
   it31000501()

   lStartLine := .f.
   if ITEM->(DbSeek(vRecord))
   
      // Indicate record being processed.
      @ 2, 1 wsay " Item: " + vRecord
      // Print on next row.
      if V->(DbSeek(ITEM->I_020))
       ? MARGIN + V->V_001 
       ?? space(2) + subs(V->V_002,1,20)       //jzo04-21-98
       nCtr += 1
      endif 

      while ITEM->(!Eof()) .and. vRecord == ITEM->I_020
        if ITEM->(!Deleted())   .and. UITEMS->(DbSeek(ITEM->I_001))
            // Check if quantity on hand > 0.
           if UITEMS->UI_STK_BAL > 0 .OR. UITEMS->UI_STK_OUT == CTOD("  /  /  ")
             ITEM->(Dbskip())
             loop
           endif
           if lStartLine
               ?  MARGIN + space(25) 
               nCtr += 1
           endif
           ?? space(2) + ITEM->I_001    
           ?? space(2) + ITEM->I_002 
           ?? space(2) + dtoc(UITEMS->UI_STK_OUT)
           so_days = date() - UITEMS->UI_STK_OUT
           ?? space(18) + tran(so_days, "9,999" )
           lStartLine := .t.
           if ITEM->(!eof()) .and. nCtr == 55
               ?
               ? MARGIN     + repl( "-", THIS_WIDTH - LEFT_MARGIN)
               nCtr := 0
               it390006 ( RPT_ID, THIS_WIDTH, LEFT_MARGIN, RIGHT_MARGIN, nPage )
               npage += 1                              
               eject
               it390003 ( SYS_NAME, RPT_NAME, THIS_WIDTH, LEFT_MARGIN, RIGHT_MARGIN )
               nCtr := 1   
               it31000501()
           endif    
         endif  
         ITEM->(DbSkip())
      enddo   
   else   
      Message("Supplier Code :"+vRecord+" not found ...")
      BUMMER()
   endif
   
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

   // Screen or Printed Reports
   RepGen(".\"+RPT_ID, RPT_NAME, 0, 214 )
   ferase("icode.ntx")

return nil


/*============================================================================
   Page Header
============================================================================*/
STATIC FUNCTION it31000501

       ? MARGIN + "Report Date: As of  " + dtoc(Date())
*      ?? space(60) + "UNIT " +  padl(alltrim(str(nUnit)),3,"0")
       ? MARGIN   +"SUPPLIER-------------------" 
      ?? space(0) +"ITEM----------------------------" + replicate( "-", PLU_DESC_LEN +25) 

       ? MARGIN   + padr ( "Name",  20) 
      ?? space(7) + padr ( "Code", PLU_CODE_LEN )
      ?? space(2) + padr ( "Description",       PLU_DESC_LEN )
      ?? space(2) + padr ( "Stock Out Date",    20 )
      ?? space(2) + padr ( "Days Out of Stock", 20 )

       ? MARGIN + replicate ( "-", THIS_WIDTH - LEFT_MARGIN)
     nCtr += 4  
RETURN NIL

