/*============================================================================

   (c) 1993  TECHNO SOFTWARE CORPORATION

   This module contains information proprietary to TECHNO SOFTWARE
   CORPORATION, and should be treated confidential.

   it310006.prg - Re-order Report module
             for Inventory Tracking System (ITS)

   acr / 05.17.93
   eso / 09.24.95 replaced prow() with nCtr

============================================================================*/
#include "Janus.ch" 
#include "its.ch"
#include "set.ch"
#include "setcurs.ch"

#define RPT_ID   "RO-REP-D"
#define RPT_NAME "RE-ORDER REPORT"
#define THIS_WIDTH 109 + PLU_DESC_LEN + LEFT_MARGIN + PLU_CODE_LEN

memvar nUnit

static pttl[5], gttl[5]
static nPage := 0, nTCost := 0, footer_now := 0
static aCreditTerms := ARRAY_TERMS
static aVendorType := VENDOR_TYPES
static nCtr := 0

/*========================================================*/
function it310006()
/*========================================================*/

local cOldClr := setcolor ( BN_COLOR ), nOldCursor := 0
local lStartLine 
local nGoPrint := 2
   nPage := 0

   afill ( pttl, 0 )
   afill ( gttl, 0 )

   nOldCursor = setcursor ( SC_NONE )

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

   if NetUse("V",DB_SHARED,NUM_SECONDS)
      Set Index to V_001
   endif   

   if NetUse("RJ",DB_SHARED,NUM_SECONDS)
      Set Index to RJ_001
   endif   

/*   if NetUse("IV",DB_SHARED,NUM_SECONDS)
      Set Index to IV_LINK
   endif */
     
   if NetUse("ITEM.DBF",DB_SHARED,NUM_SECONDS)
     // Set index to I_001
     index on ITEM->I_020 to rovcode 
   endif
      
   set filter to ITEM->I_019 != 2 // rEVISED atc 07-21-93.
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
   it31000601()   

   while V->(!Eof())


      // Indicate record being processed.
      @ 2, 1 wsay " Item: " + V->V_001

      // Print on next row.
       ?  MARGIN +  V->V_001 
//jzo04-21-98       ?? space(2) + V->V_002
       ?? space(2) + substr(V->V_002,1,20)

      nctr += 1
      lStartLine := .f.  
      // Find vendor/s cross reference.
      ITEM->(DbSeek(V->V_001))
      while ITEM->(!Eof()) .and. V->V_001 == ITEM->I_020
        if ITEM->(!Deleted())  .and. UITEMS->(DbSeek(ITEM->I_001))    
          // Check if below reorder level   
          // changed to reorder level instead of minimum
          // - eso - 09/18/95
      
          if UITEMS->UI_STK_BAL >= ITEM->I_012
             ITEM->(Dbskip())
             loop
          endif 
          if lStartLine
              ? MARGIN + space(25) 
              nCtr += 1
          endif
          ?? space(2)  + ITEM->I_001
          ?? space (2) + ITEM->I_002 
          ?? space (2) + tran( UITEMS->UI_STK_BAL, "999,999,999" )     // stock balance
*          ?? space (2) + tran( ITEM->I_011, "999,999,999" )     // min level
          ?? space (2) + tran( ITEM->I_010, "999,999,999" )     // max level
*          ?? space (2) + tran( ITEM->I_012, "999,999,999" )     // reorder level
          ?? space (2) + tran( ITEM->I_010 - (UITEMS->UI_STK_BAL), "999,999,999" )   // max - stock  
          ?? space (2) + ITEM->I_005 
          ?? space(2) + if( (V->V_009 > 0 .and. V->V_009 <= len(aCreditTerms)),;
                             padr( aCreditTerms[V->V_009], 8 ) , repl("?",8) )
          ?? space(2) + if( (V->V_010 > 0 .and. V->V_010 <= len(aVendorType)),;
                         padr( aVendorType[V->V_010], 15 ) , repl("?",15) )
          lStartLine := .t.
          // Accumulate the page and grand total and count.
          it31000603()
            if ITEM->(!eof()) .and. nCtr == 55
               it31000602()
               nCtr := 0
               it390006 ( RPT_ID, THIS_WIDTH, LEFT_MARGIN, RIGHT_MARGIN, nPage )
               npage += 1                              
               eject
               it390003 ( SYS_NAME, RPT_NAME, THIS_WIDTH, LEFT_MARGIN, RIGHT_MARGIN )
               nCtr := 1   
               it31000601()
            endif   
        endif
        ITEM->(DbSkip())
      enddo      
      V->(DbSkip())
   enddo
   // Print the page totals.
   it31000602()

    ? MARGIN +  "END OF REPORT" + replicate ( "=", THIS_WIDTH - LEFT_MARGIN - 13) 
   it390006 ( RPT_ID, THIS_WIDTH, LEFT_MARGIN, RIGHT_MARGIN, nPage )
   eject

   dbCloseAll()
   killwindow()

   set device to screen
   set printer off
   set console on
   set cursor on
   set printer to

   // Restore color set.
   setcolor ( cOldClr )

   // Screen or Printed Reports.
   RepGen( ".\"+RPT_ID, RPT_NAME, 2, 214 )
   ferase("rovcode.ntx")

RETURN NIL


/*========================================================*/
function it310006P()
/*========================================================*/

local cOldClr := setcolor ( BN_COLOR ), nOldCursor := 0
local lStartLine 
local nGoPrint := 2, getlist := {}, vRecord := space(3), vBrowse
   nPage := 0

   vBrowse := OpenWindow(15,30,17,50)
   @ 16,31 say "Supplier Code: "Get vRecord Pict "999"
   setCursor("ON")
   read
   setCursor("OFF")
   CloseWindow(vBrowse)

   vRecord := padl(alltrim(vRecord),3,"0")   

   afill ( pttl, 0 )
   afill ( gttl, 0 )

   nOldCursor = setcursor ( SC_NONE )

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

   if NetUse("V",DB_SHARED,NUM_SECONDS)
      Set Index to V_001
   endif   

   if NetUse("RJ",DB_SHARED,NUM_SECONDS)
      Set Index to RJ_001
   endif   

     
   if NetUse("ITEM.DBF",DB_SHARED,NUM_SECONDS)
     // Set index to I_001
     index on ITEM->I_020 to rovcode 
   endif
      
   set filter to ITEM->I_019 != 2 // rEVISED atc 07-21-93.
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
   it31000601()   


    lStartLine := .f.
    if ITEM->(DbSeek(vRecord))
      // Indicate record being processed.
      @ 2, 1 wsay " Item: " + vRecord

      // Print on next row.
      if V->(DbSeek(ITEM->I_020))
        ?  MARGIN +  V->V_001 
//jzo04-21-98        ?? space(2) + V->V_002
        ?? space(2) + subs(V->V_002,1,20)

        nctr += 1
      endif

      while ITEM->(!Eof()) .and. vRecord == ITEM->I_020
        if ITEM->(!Deleted())   .and. UITEMS->(DbSeek(ITEM->I_001))    
          // Check if below reorder level   
          // changed to reorder level instead of minimum
          // - eso - 09/18/95
      
          if UITEMS->UI_STK_BAL >= ITEM->I_012 
             ITEM->(Dbskip())
             loop
          endif 
          if lStartLine
              ? MARGIN + space(25) 
              nCtr += 1
          endif
          ?? space(2)  + ITEM->I_001
          ?? space (2) + ITEM->I_002 
          ?? space (2) + tran( UITEMS->UI_STK_BAL, "999,999,999" )     // stock balance
*          ?? space (2) + tran( ITEM->I_011, "999,999,999" )     // min level
          ?? space (2) + tran( ITEM->I_010, "999,999,999" )     // max level
*         ?? space (2) + tran( ITEM->I_012, "999,999,999" )     // reorder level
          ?? space (2) + tran( ITEM->I_010 - (UITEMS->UI_STK_BAL), "999,999,999" )   // max - stock  
          ?? space (2) + ITEM->I_005 
          ?? space(2) + if( (V->V_009 > 0 .and. V->V_009 <= len(aCreditTerms)),;
                             padr( aCreditTerms[V->V_009], 8 ) , repl("?",8) )
          ?? space(2) + if( (V->V_010 > 0 .and. V->V_010 <= len(aVendorType)),;
                         padr( aVendorType[V->V_010], 15 ) , repl("?",15) )
          lStartLine := .t.
          // Accumulate the page and grand total and count.
          it31000603()
          if ITEM->(!eof()) .and. nCtr == 55
               it31000602()
               nCtr := 0
               it390006 ( RPT_ID, THIS_WIDTH, LEFT_MARGIN, RIGHT_MARGIN, nPage )
               npage += 1                              
               eject
               it390003 ( SYS_NAME, RPT_NAME, THIS_WIDTH, LEFT_MARGIN, RIGHT_MARGIN )
               nCtr := 1   
               it31000601()
           endif   
        endif
        ITEM->(DbSkip())
      enddo      

   else
     Message("Supplier Code :"+vRecord+" not found ...")
     BUMMER()
   endif  
   // Print the page totals.
   it31000602()

   // Print grand totals.

    ? MARGIN +  "END OF REPORT" + replicate ( "=", THIS_WIDTH - LEFT_MARGIN - 13) 
   it390006 ( RPT_ID, THIS_WIDTH, LEFT_MARGIN, RIGHT_MARGIN, nPage )
   eject

   dbCloseAll()
   killwindow()

   set device to screen
   set printer off
   set console on
   set cursor on
   set printer to

   // Restore color set.
   setcolor ( cOldClr )

   // Screen or Printed Reports.
   RepGen( ".\"+RPT_ID, RPT_NAME, 2, 214 )
   ferase("rovcode.ntx")

RETURN NIL



/*============================================================================
   Page Header
============================================================================*/
STATIC FUNCTION it31000601

       ? MARGIN + "Report Date:  As of  " + dtoc(date())
*      ?? space(126) + "UNIT " + padl(alltrim(str(nUnit)),3,"0") 
       ? MARGIN + "Supplier--------------------" 
      ?? space(0)  + "Item---------------------------------------------------------------------------------------"+repl("-",PLU_DESC_LEN + 4) 

       ? MARGIN    + padr ( "Code",4 )
      ?? space (2) + padr ( "Name",20) 
      ?? space (2) + padr ( "Code", PLU_CODE_LEN )
      ?? space (2) + padr ( "Description", PLU_DESC_LEN )
      ?? space (2) + padr ( "Qty on Hand",   11 )
    *  ?? space (2) + padr ( "Minimum Level", 11 )
      ?? space (2) + padr ( "Maximum Level", 11 )
    *  ?? space (2) + padr ( "Reorder Level",   11 )
      ?? space (2) + padr ( "Reorder Qty", 11)   
      ?? space (2) + padr ( "Unit",       10 )
      ?? space (2) + padr ( "Terms", 8 )
      ?? space (2) + padr ( "Type", 15 )

       ? MARGIN    + replicate ( "-", THIS_WIDTH - LEFT_MARGIN)

     nCtr += 4
RETURN NIL

/*============================================================================
============================================================================*/
STATIC FUNCTION it31000602

    ? MARGIN +  replicate ( "-", THIS_WIDTH - LEFT_MARGIN)
    ? MARGIN + "   PAGE TOTAL" 
   ?? space (27) 
   ?? space ((PLU_CODE_LEN-12)+3+PLU_DESC_LEN) + tran(pttl[1], "999,999,999") 
 *  ?? space ( 2) + tran(pttl[2], "999,999,999" )
   ?? space ( 2) + tran(pttl[3], "999,999,999" )
 *  ?? space ( 2) + tran(pttl[4], "999,999,999" )
   ?? space ( 2) + tran(pttl[5], "999,999,999" )

    ? MARGIN +  "RUNNING TOTAL" 
   ?? space (27) 
   ?? space ((PLU_CODE_LEN-12)+3+PLU_DESC_LEN) + tran( gttl[1], "999,999,999" )
 *  ?? space ( 2) + tran( gttl[2], "999,999,999" )
   ?? space ( 2) + tran( gttl[3], "999,999,999" )
 *  ?? space ( 2) + tran( gttl[4], "999,999,999" )
   ?? space ( 2) + tran( gttl[5], "999,999,999" )
    ? MARGIN +  replicate ( "-", THIS_WIDTH - LEFT_MARGIN)   
    
   pttl[1] = 0
   pttl[2] = 0
   pttl[3] = 0
   pttl[4] = 0
   pttl[5] = 0
   nCtr += 4

RETURN NIL

/*============================================================================
============================================================================*/
STATIC FUNCTION it31000603

   // Accumulate quantity / amount pairs.
   pttl[1] += UITEMS->UI_STK_BAL
 *  pttl[2] += ITEM->I_011
   pttl[3] += ITEM->I_010
 *  pttl[4] += ITEM->I_012
   pttl[5] += ( ITEM->I_012 - UITEMS->UI_STK_BAL)

   gttl[1] += UITEMS->UI_STK_BAL
 *  gttl[2] += ITEM->i_011
   gttl[3] += ITEM->I_010
 *  gttl[4] += ITEM->I_012
   gttl[5] += ( ITEM->I_012 - UITEMS->UI_STK_BAL )

RETURN NIL

