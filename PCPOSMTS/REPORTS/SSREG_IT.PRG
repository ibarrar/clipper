/*============================================================================

   (c) 1993  TECHNO SOFTWARE CORPORATION

   This module contains information proprietary to TECHNO SOFTWARE
   CORPORATION, and should be treated confidential.

   it310004.prg - Stock Status Register module
         for Inventory Tracking System (ITS)

   acr / 05.17.93
   rci
   eso / 09.24.95 replaced prow() with nCtr
   eso / 10.02.95 replaced aVectors (array ) with a temporary dbf

============================================================================*/
#include "Janus.ch"
#include "its.ch"
#include "set.ch"
#include "setcurs.ch"
#include "inkey.ch"

#define RPT_ID     "SS-REG-D"
#define RPT_ID_M   "SS-REG-M"
#define RPT_NAME   "STOCK STATUS REGISTER"
#define RPT_NAME_M "STOCK STATUS REPORT"  
#define THIS_WIDTH 208 + PLU_DESC_LEN + PLU_CODE_LEN + LEFT_MARGIN -36

memvar dToday, nUnit

static pttl[12], gttl[12], nqty[6], namt[6]
static nPage := 0, nTCost := 0, footer_now := 0
static nCtr := 0

/*========================================*/
function ssreg_it ( nReportSwitch )
/*========================================*/

local cOldClr := setcolor ( BN_COLOR ), nOldCursor := 0
local cRptName, cRptID ,nPos
// local aVectors_ := {}  removed 10.02.95 / eso
local nGoPrint := 2, flag := .f., stunit := space(3)
local vBrowse, getlist := {}, sdate := date()
local cCLcode:=space(4),cprevDP:=SPACE(2)

   SET CURSOR ON
   vBrowse := OpenWindow(10,30,12,50)
   @ 10,33 say "STOCK STATUS  "
   @ 11,33 say "Date: "Get sdate
   read
   if lastkey() == K_ESC
      SET CURSOR OFF
      CloseWindow(vBrowse)
      return nil
   endif   
   SET CURSOR OFF
   CloseWindow(vBrowse)



   if nReportSwitch = 2 // Monthly
      cRptName := RPT_NAME_M
      cRptID   := RPT_ID_M
   else
      cRptName := RPT_NAME
      cRptID   := RPT_ID
   endif

   afill ( pttl, 0 )
   afill ( gttl, 0 )
   afill ( nqty, 0 )
   afill ( namt, 0 )

   nOldCursor = setcursor ( SC_NONE )

   // Create display window.
   window ( 19, 1, 22, 60, CONFIRM_COLOR )
   @ 1, 1 wsay " Creating " + cRptName + ".  Please wait ..."

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

   // create a temporary dbf instead of arrays
   // eso / 10.02.95
   dbCreate("temp.dbf", { { "plu",  "C",  PLU_CODE_LEN,   0 },;
                          { "qrec", "N",  15,   3 },;
                          { "qret", "N",  15,   3 },;
                          { "qtrn", "N",  15,   3 },;
                          { "qadj", "N",  15,   3 } } )

   if netuse("TEMP", DB_SHARED, NUM_SECONDS)                        
      index on TEMP->plu to TEMP
   endif   

   if NetUse("RR",DB_SHARED,NUM_SECONDS)
      Set Index to RR_001
   endif

   if NetUse("RJ",DB_SHARED,NUM_SECONDS)
      Set Index to RJ_001
   endif

   if NetUse("SA",DB_SHARED,NUM_SECONDS)
      Set Index to SA_001
   endif

   if NetUse("ST",DB_SHARED,NUM_SECONDS)
      Set Index to ST_001
   endif

   if NetUse("RR_ITEMS",DB_SHARED,NUM_SECONDS)
      Set Index to RRI_LINK
   endif
   if NetUse("SA_ITEMS",DB_SHARED,NUM_SECONDS)
      Set Index to SAI_LINK
   endif
   if NetUse("ST_ITEMS",DB_SHARED,NUM_SECONDS)
      Set Index to STI_LINK
   endif
   if NetUse("RJ_ITEMS",DB_SHARED,NUM_SECONDS)
      Set Index to RJI_LINK
   endif
   
   if NetUse("ITEM.DBF",DB_SHARED,NUM_SECONDS)
      Set Index to I_001
   endif


   if NetUse("CL",DB_SHARED,NUM_SECONDS)
      Set Index to CL_001
   endif
   if NetUse("DEPT",DB_SHARED,NUM_SECONDS)
      Set Index to DEPT
   endif
      

   UITEMS->(dbGotop())
   while UITEMS->(!Eof())
     if UITEMS->(!Deleted())
       @ 2, 1 wsay "Item: " + UITEMS->UI_PLUCODE 
       TEMP->(RecLock())
       TEMP->(addRec(0))
       TEMP->plu  := UITEMS->UI_PLUCODE
       TEMP->(dbUnlock())          
     endif            
     UITEMS->(DbSkip())
   enddo  
   UITEMS->(DbCloseArea()) 


   RR->(DbGotop())
   while RR->(!Eof())
     if RR->(!Deleted()) .and. month(RR->RR_006) == month(sdate) .and. RR->RR_010 == 1
        RR_ITEMS->(DbSeek(RR->RR_001))
        while RR_ITEMS->(!Eof()) .and. RR_ITEMS->RRI_LINK == RR->RR_001
          @ 2, 1 wsay " From RR: " + RR->RR_001 +"   Item: "+RR_ITEMS->RRI_ITEM 
                 TEMP->(DbSeek(RR_ITEMS->RRI_ITEM))
                 if TEMP->plu == RR_ITEMS->RRI_ITEM         
                 TEMP->(RecLock())
                 TEMP->qrec += RR_ITEMS->RRI_QREC
                 TEMP->(dbUnlock())          
              endif   
          RR_ITEMS->(DbSkip())    
       enddo      
     endif  
     RR->(DbSkip())
   enddo  
   RR->(DbCloseArea())
   RR_ITEMS->(DbCloseArea())


   RJ->(dbGotop())
   while RJ->(!Eof())
     if RJ->(!Deleted()) .and. month(RJ->RJ_006) == month(sdate) .and. RJ->RJ_010 == 1
        RJ_ITEMS->(DbSeek(RJ->RJ_001))
        while RJ_ITEMS->(!Eof()) .and. RJ_ITEMS->RJI_LINK == RJ->RJ_001
          @ 2, 1 wsay " From RJ: " + RJ->RJ_001 +"   Item: "+RJ_ITEMS->RJI_ITEM 
                TEMP->(DbSeek(RJ_ITEMS->RJI_ITEM))
                if TEMP->plu == RJ_ITEMS->RJI_ITEM                          
                 TEMP->(RecLock())
                 TEMP->qret += RJ_ITEMS->RJI_QRET
                 TEMP->(dbUnlock())          
                endif 
          RJ_ITEMS->(DbSkip())    
       enddo      
     endif  
     RJ->(DbSkip())
   enddo  
   RJ->(DbCloseArea())
   RJ_ITEMS->(DbCloseArea())


   
   SA->(dbGotop())
   while SA->(!Eof())
     if SA->(!Deleted()) .and. month(SA->SA_002) == month(sdate) .and. SA->SA_003 == 1
        SA_ITEMS->(DbSeek(SA->SA_001)) 
        while SA_ITEMS->(!Eof()) .and. SA_ITEMS->SAI_LINK == SA->SA_001
          @ 2, 1 wsay " From SA: " + SA->SA_001 +"   Item: "+SA_ITEMS->SAI_ITEM 
               TEMP->(DbSeek(SA_ITEMS->SAI_ITEM))
               if TEMP->plu == SA_ITEMS->SAI_ITEM  .and.;
                  SA_ITEMS->SAI_UNIT == padl(alltrim(str(nUnit)),3,"0")       
                 TEMP->(RecLock())
                 TEMP->qadj += SA_ITEMS->SAI_QADJ
                 TEMP->(dbUnlock())          
               endif  
          SA_ITEMS->(DbSkip())    
       enddo      
     endif  
     SA->(DbSkip())
   enddo  
   SA->(DbCloseArea())
   SA_ITEMS->(DbCloseArea())

   ST->(DbGotop())
   while ST->(!Eof())
     if ST->(!Deleted()) .and. month(ST->ST_004) == month(sdate) .and. ST->ST_005 == 1
        ST_ITEMS->(DbSeek(ST->ST_001))
        while ST_ITEMS->(!Eof()) .and. ST_ITEMS->STI_LINK == ST->ST_001
          @ 2, 1 wsay " From ST: " + ST->ST_001 +"   Item: "+ST_ITEMS->STI_ITEM 
                 TEMP->(DbSeek(ST_ITEMS->STI_ITEM))
                 /*if nUnit != 0
                     stunit := ST->ST_003
                 else
                     stUnit  := ST->ST_002
                 endif        
                 if TEMP->plu == ST_ITEMS->STI_ITEM  .AND.;
                     stunit ==  padl(alltrim(str(nUnit)),3,"0")                               
                 TEMP->(RecLock())
                 TEMP->qTRN += ST_ITEMS->STI_QADJ
                 TEMP->(dbUnlock())          
               endif */   
               if ST->ST_003 != "000"
                 if TEMP->plu == ST_ITEMS->STI_ITEM 
                   TEMP->(RecLock())
                   TEMP->qTRN += ST_ITEMS->STI_QADJ
                   TEMP->(dbUnlock())          
                 endif  
               else
                 if TEMP->plu == ST_ITEMS->STI_ITEM 
                   TEMP->(RecLock())
                   TEMP->qret += ST_ITEMS->STI_QADJ
                   TEMP->(dbUnlock())          
                 endif  
               endif

               
          ST_ITEMS->(DbSkip())    
       enddo      
     endif  
     ST->(DbSkip())
   enddo  
   ST->(DbCloseArea())
   ST_ITEMS->(DbCloseArea())

   
   if NetUse("UITEMS",DB_SHARED,NUM_SECONDS)
      Set Index to UITEMS
   endif      

   if NetUse("ITEM.DBF",DB_SHARED,NUM_SECONDS)
     * Set Index to I_001
     index on ITEM->I_020 to sscode
   endif
      
 //  set filter to ITEM->I_019 != 2  // Revised ATC 07-21-93.

cRptId := SUBSTR(CMONTH(sdate),1,3)+SUBSTR(DTOC(sdate),7,2)+alltrim(str(nunit))


#ifdef TO_FILE
   set printer to ".\"+cRptID
#endif

   set device to printer
   set printer on
   set console off
   
   // Standard page header routine.
   it390003 ( SYS_NAME, cRptName, THIS_WIDTH, LEFT_MARGIN, RIGHT_MARGIN )
   nCtr := 1
   nPage := 1

   // Print the headers for this report.
   it31000401(sdate)   

      //
      // replaced this loop with the next loop
      // eso / 10.02.95
      //

     flag := .f. 

     ITEM->(DBGOTOP())
     while ITEM->(!Eof()) 
      // Indicate record being processed.
      @ 2, 1 wsay " Item: " + ITEM->I_001 

      if ITEM->(!Deleted())  .and. UITEMS->(DbSeek(ITEM->I_001))
        
       TEMP->(DbSeek(ITEM->I_001))
       if TEMP->plu == ITEM->I_001 
         IF nUnit != 0
            nqty[2] := TEMP->qtrn
         else
            nqty[2] := TEMP->qrec
         endif   
         nqty[3] := TEMP->qret
         nqty[4] := TEMP->qadj 
        if TEMP->qrec == 0 .and. TEMP->qret == 0 .and. TEMP->qadj == 0;
                    .AND. UITEMS->UI_BEG_BAL == 0 .AND. ITEM->I_030 == 0;
                    .and. TEMP->qtrn == 0
            ITEM->(DbSkip())
            loop
        endif    
       else 
        nqty[2] := 0 // TEMP->qrec
        nqty[3] := 0 // TEMP->qret
        nqty[4] := 0 // TEMP->qadj
       endif 

//       if flag
//         ? MARGIN + space(34)
         nCtr += 1
//       endif   
      ? MARGIN + ITEM->I_001  //code
      ?? space(1) + ITEM->I_002 //Desc
      ?? space(1) + ITEM->I_005 //Measure
      ?? space(1) + tran(ITEM->i_003, "99,999.99" ) //Selling price

      nqty[1] := UITEMS->UI_BEG_BAL
      namt[1] := UITEMS->UI_BEG_BAL * ITEM->i_003
      ?? space(2) + tran( nqty[1], " 999,999" )  
      ?? space(1) + tran( namt[1], "999,999,999.99" )

      namt[2] = nqty[2] * ITEM->i_003
      ?? space(2) + tran( nqty[2], " 999,999" )
      ?? space(1) + tran( namt[2], "999,999,999.99" )

      namt[3] = nqty[3] * ITEM->i_003
      ?? space(2) + tran( nqty[3], " 999,999" )
      ?? space(1) + tran( namt[3], "999,999,999.99" )

      namt[4] = abs(nqty[4]) * ITEM->i_003
      ?? space(2) + tran( nqty[4], " 999,999" )
      ?? space(1) + tran( namt[4], "999,999,999.99" )
      
      if nUnit != 0
        // Add Items' sales
        nqty[5] := ITEM->I_030
        namt[5] := ITEM->I_029
      else  
        nqty[5] := TEMP->qtrn
        namt[5] := nqty[5] * ITEM->I_003
      endif  
      ?? space(2) + tran( nqty[5], " 999,999" )
      ?? space(1) + tran( namt[5], "999,999,999.99" )      

      // Add everything up.
      nqty[6] := nqty[1] + nqty[2] + nqty[4] -(nqty[3] + nqty[5])
      if nqty[4] < 0
         namt[6] := namt[1] + namt[2] - (namt[4] + namt[3] + namt[5])
      else
         namt[6] := namt[1] + namt[2] + namt[4] -(namt[3] + namt[5])
      endif   
      ?? space(2) + tran( nqty[6], " 999,999" )
      ?? space(1) + tran( namt[6], "999,999,999.99" )
      
      // Accumulate the page and grand total and count.
      it31000403()
      flag := .t.
      if ITEM->(!eof()) .and. nCtr == 55
         it31000402()
         nCtr := 0
         it390006 ( cRptID, THIS_WIDTH, LEFT_MARGIN, RIGHT_MARGIN, nPage )
         npage += 1                              
         eject
         it390003 ( SYS_NAME, cRptName, THIS_WIDTH, LEFT_MARGIN, RIGHT_MARGIN )
         nCtr := 1   
         it31000401(sdate)
      endif   
      
      endif
      ITEM->(DbSkip())
     enddo     

   // Print the page totals.
   it31000402()

   ? MARGIN +  "END OF REPORT" + replicate ( "=", THIS_WIDTH - LEFT_MARGIN - 13) 
   it390006 ( cRptID, THIS_WIDTH, LEFT_MARGIN, RIGHT_MARGIN, nPage )
   eject

   dbCloseAll()

   // erase temporary files
   if file("TEMP.DBF")
    ferase("TEMP.DBF")
   endif

   if file("TEMP.NTX")
    ferase("TEMP.NTX")
   endif   

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
   RepGen( ".\"+cRptID, cRptName, 1, 250 )
   ferase("sscode.ntx")

RETURN NIL


/*============================================================================
   Page Header
============================================================================*/
STATIC FUNCTION it31000401(sdate)
LOCAL nI := 0

       ? MARGIN + "As of the Month of  "+ Cmonth(sdate) + ", " + str(year(sdate))
      ?? space(190) + "UNIT " +  padl(alltrim(str(nUnit)),3,"0")       
       ? MARGIN + "Item--------------------" + repl("-",PLU_DESC_LEN+PLU_CODE_LEN) 
      ??  "Beginning Inventory------"
      ??  "Received-----------------"
      ??  "Returns------------------"
      ??  "Adjustments--------------"
      if nUnit == 0
         ??  "Transfered---------------"
      else
         ??  "Sales--------------------"
      endif   
      ??  + "Ending Inventory-------" 

       ? MARGIN   + padr ( "Code", PLU_CODE_LEN )
      ?? space(1) + padr ( "Description", PLU_DESC_LEN )
      ?? space(1) + padr ( "Unit",     10 )
      ?? space(1) + padl ( "Sell Pric",    9 )

      for nI := 1 to 6
         ?? space(2) + padl ( "Quantity",    8 )
         ?? space(1) + padl ( "Amount",      14 )
      next

      ? MARGIN + repl ( "-", THIS_WIDTH - LEFT_MARGIN)
      nCtr += 4
RETURN NIL



/*============================================================================
   Page Footer
============================================================================*/
STATIC FUNCTION it31000402

    ? MARGIN + repl( "-", THIS_WIDTH - LEFT_MARGIN)
    ? MARGIN + "   PAGE TOTAL" 
   ?? space(45+PLU_CODE_LEN+PLU_DESC_LEN+1-36) + tran( pttl[ 1], "9,999,999" )
   ?? space( 1) + tran( pttl[ 2], "999,999,999.99" )
   ?? space( 1) + tran( pttl[ 3], "9,999,999" )
   ?? space( 1) + tran( pttl[ 4], "999,999,999.99" )
   ?? space( 1) + tran( pttl[ 5], "9,999,999" )
   ?? space( 1) + tran( pttl[ 6], "999,999,999.99" )
   ?? space( 1) + tran( pttl[ 7], "9,999,999" )
   ?? space( 1) + tran( pttl[ 8], "999,999,999.99" )
   ?? space( 1) + tran( pttl[ 9], "9,999,999" )
   ?? space( 1) + tran( pttl[10], "999,999,999.99" )
   ?? space( 1) + tran( pttl[11], "9,999,999" )
   ?? space( 1) + tran( pttl[12], "999,999,999.99" )   

    ? MARGIN + "RUNNING TOTAL" 
   ?? space(45+PLU_CODE_LEN+PLU_DESC_LEN+1-36) + tran( gttl[ 1], "9,999,999" )
   ?? space( 1) + tran( gttl[ 2], "999,999,999.99" )
   ?? space( 1) + tran( gttl[ 3], "9,999,999" )
   ?? space( 1) + tran( gttl[ 4], "999,999,999.99" )
   ?? space( 1) + tran( gttl[ 5], "9,999,999" )
   ?? space( 1) + tran( gttl[ 6], "999,999,999.99" )
   ?? space( 1) + tran( gttl[ 7], "9,999,999" )
   ?? space( 1) + tran( gttl[ 8], "999,999,999.99" )
   ?? space( 1) + tran( gttl[ 9], "9,999,999" )
   ?? space( 1) + tran( gttl[10], "999,999,999.99" )
   ?? space( 1) + tran( gttl[11], "9,999,999" )
   ?? space( 1) + tran( gttl[12], "999,999,999.99" )   

    ? MARGIN + repl ( "-", THIS_WIDTH - LEFT_MARGIN)

   nCtr += 4 
   afill ( pttl, 0 )

RETURN NIL

/*============================================================================
============================================================================*/
STATIC FUNCTION it31000403

   // Accumulate quantity / amount pairs.
   pttl[1] += nqty[1]
   gttl[1] += nqty[1]
   pttl[2] += namt[1]
   gttl[2] += namt[1]

   pttl[3] += nqty[2]
   gttl[3] += nqty[2]
   pttl[4] += namt[2]
   gttl[4] += namt[2]

   pttl[5] += nqty[3]
   gttl[5] += nqty[3]
   pttl[6] += namt[3]
   gttl[6] += namt[3]

   pttl[7] += nqty[4]
   gttl[7] += nqty[4]
   pttl[8] += namt[4]
   gttl[8] += namt[4]

   pttl[9]  += nqty[5]
   gttl[9]  += nqty[5]
   pttl[10] += namt[5]
   gttl[10] += namt[5]
      
   pttl[11] += nqty[6]
   gttl[11] += nqty[6]
   pttl[12] += namt[6]
   gttl[12] += namt[6]


RETURN NIL
