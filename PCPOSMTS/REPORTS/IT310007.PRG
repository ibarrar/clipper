
/*============================================================================

   (c) 1993  TECHNO SOFTWARE CORPORATION

   This module contains information proprietary to TECHNO SOFTWARE
   CORPORATION, and should be treated confidential.

   it310007.prg - Stock Adjustmnet Register module
             for Inventory Tracking System (ITS)

   acr / 05.17.93
   eso / 09.24.95 replaced prow() with nCtr

============================================================================*/
#include "Janus.ch"
#include "its.ch"
#include "set.ch"
#include "setcurs.ch"

#define RPT_ID     "SA-REG-D"
#define RPT_ID_M   "SA-REP-M"
#define RPT_NAME   "STOCK ADJUSTMENT REGISTER"
#define RPT_NAME_M "STOCK ADJUSTMENT REPORT"
#define THIS_WIDTH (128 +PLU_CODE_LEN+PLU_DESC_LEN + LEFT_MARGIN)

STATIC pttl[2], gttl[2]
STATIC nPage := 0, nTCost := 0, footer_now := 0
static nCtr := 0

FUNCTION it310007()
   LOCAL cRptName, cRptID
   LOCAL cOldClr := setcolor ( BN_COLOR ), nOldCursor := 0
   LOCAL cSARef := space(8), dTDate := ctod ("")
   local nGoPrint := 2, getlist := {}, dBrowse, edate := Date()
   local lMark := .f. , sdate := Date(), lStartLine := .f.

   SET CURSOR ON 
   dBrowse := OpenWindow(15,20,17,55)
   @ 15,27 say "Date Adjusted Range"
   @ 16,21 say "From: "Get sdate
   @ 16,40 say "To: "Get edate
   read
   SET CURSOR OFF
   CloseWindow(dBrowse)  
   
   nPage := 1
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
   
   if NetUse("SA",DB_SHARED,NUM_SECONDS)
     // Set Index to SA_001
     index on SA->SA_005 to savcode
   endif      

/*   if nReportSwitch = 2
      dbSetFilter( {|| SA->SA_003 = 2}, "SA->SA_003 = 2" ) 
   else
      dbSetFilter( {|| SA->SA_003 < 2}, "SA->SA_003 < 2" ) 
   endif */

   if NetUse("SA_ITEMS",DB_SHARED,NUM_SECONDS)
      Set Index to SAI_LINK
   endif      

   SA->(dbGoTop())

#ifdef TO_FILE
   Set( 24, ".\"+cRptID, .F. )
#endif

   set device to printer
   set printer on
   set console off

   // Standard page header routine.
   it390003 ( SYS_NAME, cRptName, THIS_WIDTH, LEFT_MARGIN, RIGHT_MARGIN )
   nctr := 1

   // Print the headers for this report.
   it31000701(sdate,edate)

  while V->(!Eof())
     
    // Indicate record being processed.
    @ 2, 1 wsay " Stock Adj.: " + SA->SA_005
   IF SA->(DbSeek(V->V_001))  
       ? MARGIN   + SA->SA_005 
      ?? space(3) + SA->SA_006 
      nCtr += 1
   ENDIF  

    lStartLine := .f.


*   SA->(DbSeek(V->V_001))
   while SA->(!Eof()) .and. V->V_001 == SA->SA_005

    if SA->SA_002 >= sdate .and. SA->SA_002 <= edate     
      if SA->(!Deleted())
         SA_ITEMS->(DbSeek(SA->SA_001))
        // flag := .f.
         while  SA_ITEMS->SAI_LINK == SA->SA_001 .and. SA_ITEMS->(!Eof())
         if SA_ITEMS->(!Deleted()) .and. SA_ITEMS->SAI_POST == 1 
         
          if lStartline 
             ? MARGIN   + space(26)
             nCtr += 1
          endif 
             
         // Find item cross reference.        
          ?? space(2)  + SA->SA_001
          ?? space(2) + dtoc(SA->SA_002) + space(2)  
          ITEM->(DbSeek(SA_ITEMS->SAI_ITEM))         
          
          ?? space(2) + SA_ITEMS->SAI_ITEM
          ?? space(2) + ITEM->I_002
          ?? space(2) + SA_ITEMS->SAI_UNIT
          ?? space(5) + tran(SA_ITEMS->SAI_QADJ,"99,999,999")
          ?? space(2) + ITEM->I_005  // Measure                    
          ?? space(2) + tran(ITEM->I_007,"999,999.99")
          ?? space(2) + tran(ITEM->I_003,"999,999.99")

          nTCost = ITEM->I_007 * abs(SA_ITEMS->SAI_QADJ)
           
          ?? space(2) + tran(nTCost,"999,999,999.99")
          
          
          // Accumulate the page and grand total and count.
          pttl[1] += SA_ITEMS->SAI_QADJ
          pttl[2] += nTCost

          gttl[1] += SA_ITEMS->SAI_QADJ
          gttl[2] += nTCost
          
          lStartline := .t.               
           if SA_ITEMS->(!eof()) .and. nCtr == 55
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
       SA_ITEMS->(DbSkip())  
      enddo 
     endif 
    endif   
    SA->(DbSkip())
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
   RepGen( ".\"+cRptID, cRptName, 0, 200 )

RETURN NIL


FUNCTION it310007p()

   LOCAL cRptName, cRptID
   LOCAL cOldClr := setcolor ( BN_COLOR ), nOldCursor := 0
   LOCAL cSARef := space(8), dTDate := ctod ("")
   local nGoPrint := 2, getlist := {}, dBrowse, edate := Date()
   local lMark := .f. , sdate := Date(), lStartLine := .f.
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
   @ 15,27 say "Date Adjusted Range"
   @ 16,21 say "From: "Get sdate
   @ 16,40 say "To: "Get edate
   read
   SET CURSOR OFF
   CloseWindow(dBrowse)  
   
   nPage := 1
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
   
   if NetUse("SA",DB_SHARED,NUM_SECONDS)
     // Set Index to SA_001
     index on SA->SA_005 to savcode
   endif      

/*   if nReportSwitch = 2
      dbSetFilter( {|| SA->SA_003 = 2}, "SA->SA_003 = 2" ) 
   else
      dbSetFilter( {|| SA->SA_003 < 2}, "SA->SA_003 < 2" ) 
   endif */

   if NetUse("SA_ITEMS",DB_SHARED,NUM_SECONDS)
      Set Index to SAI_LINK
   endif      

   SA->(dbGoTop())

#ifdef TO_FILE
   Set( 24, ".\"+cRptID, .F. )
#endif

   set device to printer
   set printer on
   set console off

   // Standard page header routine.
   it390003 ( SYS_NAME, cRptName, THIS_WIDTH, LEFT_MARGIN, RIGHT_MARGIN )
   nctr := 1

   // Print the headers for this report.
   it31000701(sdate,edate)

     
  IF SA->(DbSeek(Vrecord))  
    @ 2, 1 wsay " Stock Adj.: " + SA->SA_005
     ? MARGIN   + SA->SA_005 
    ?? space(3) + SA->SA_006 
    nCtr += 1

   // lStartLine := .f.


   while SA->(!Eof()) .and. vRecord == SA->SA_005

    if SA->SA_002 >= sdate .and. SA->SA_002 <= edate     
      if SA->(!Deleted())
         SA_ITEMS->(DbSeek(SA->SA_001))
        // flag := .f.
         while  SA_ITEMS->SAI_LINK == SA->SA_001 .and. SA_ITEMS->(!Eof())
         if SA_ITEMS->(!Deleted()) .and. SA_ITEMS->SAI_POST == 1 
         
          if lStartline 
             ? MARGIN   + space(26)
             nCtr += 1
          endif 
             
         // Find item cross reference.        
          ?? space(2)  + SA->SA_001
          ?? space(2) + dtoc(SA->SA_002) + space(2)  
          ITEM->(DbSeek(SA_ITEMS->SAI_ITEM))         
          
          ?? space(2) + SA_ITEMS->SAI_ITEM
          ?? space(2) + ITEM->I_002
          ?? space(2) + SA_ITEMS->SAI_UNIT
          ?? space(5) + tran(SA_ITEMS->SAI_QADJ,"99,999,999")
          ?? space(2) + ITEM->I_005  // Measure                    
          ?? space(2) + tran(ITEM->I_007,"999,999.99")
          ?? space(2) + tran(ITEM->I_003,"999,999.99")

          nTCost = ITEM->I_007 * abs(SA_ITEMS->SAI_QADJ)
           
          ?? space(2) + tran(nTCost,"999,999,999.99")
          
          
          // Accumulate the page and grand total and count.
          pttl[1] += SA_ITEMS->SAI_QADJ
          pttl[2] += nTCost

          gttl[1] += SA_ITEMS->SAI_QADJ
          gttl[2] += nTCost
          
          lStartline := .t.               
           if SA_ITEMS->(!eof()) .and. nCtr == 55
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
       SA_ITEMS->(DbSkip())  
      enddo 
     endif 
    endif   
    SA->(DbSkip())
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
   RepGen( ".\"+cRptID, cRptName, 0, 200 )

RETURN NIL

/*============================================================================
   Page Header
============================================================================*/
STATIC FUNCTION it31000701(startd,endate)

       ? MARGIN   + "STOCK ADJUSMENT"
       ?  MARGIN   + "From: " + dtoc(startd) + "  To: " + dtoc(endate) 
       ? MARGIN + "Supplier--------------------Item----------" + repl ("-",PLU_DESC_LEN + PLU_CODE_LEN + 85)

       ? MARGIN + padr("Code",4)
      ?? space(2)  + padr ("   Name",20)      
      ?? space(2)  + padr ( "Number", 8 )
      ?? space (2) + padr ( "Trans Date",  10 )
      ?? space (2) + padr ( "Code",        PLU_CODE_LEN )
      ?? space (2) + padr ( "Description", PLU_DESC_LEN )
      ?? space (2) + padr ( "Unit",        04 ) 
      ?? space (3) + padl ( "Qty Adj",     11 )
      ?? space (3) + padr ( "Unit",     10 )
      ?? space (2) + padl ( "Unit Cost",   10 )
      ?? space (2) + padl ( "Sell Prce",   10 )
      ?? space (2) + padl ( "Total Cost",  14 )

       ? MARGIN + replicate ( "-", THIS_WIDTH - LEFT_MARGIN)
      nCtr += 5 
RETURN NIL

/*============================================================================
============================================================================*/
STATIC FUNCTION it31000702

    ? MARGIN + replicate ( "-", THIS_WIDTH - LEFT_MARGIN)
    ? MARGIN + "   PAGE TOTAL" 
   ?? space(49+PLU_DESC_LEN+PLU_CODE_LEN) + tran(pttl[1], "99,999,999" )
   ?? space(38) + tran(pttl[2], "999,999,999.99" )

    ? MARGIN + "RUNNING TOTAL" 
   ?? space(49+PLU_DESC_LEN+PLU_CODE_LEN) + tran(gttl[1], "99,999,999" )
   ?? space(38) + tran(gttl[2], "999,999,999.99" )
    ? MARGIN + replicate ( "-", THIS_WIDTH - LEFT_MARGIN)
    
   nCtr += 4 
   afill ( pttl, 0 )

RETURN NIL


