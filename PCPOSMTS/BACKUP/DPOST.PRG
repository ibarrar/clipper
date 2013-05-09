/*============================================================================

   (c) 1993  TECHNO SOFTWARE CORPORATION

   This module contains information proprietary to TECHNO SOFTWARE
   CORPORATION, and should be treated confidential.

   it2100.prg - Daily Posting
           for Merchandize Tracking System (MTS)

   acr / 05.31.93

============================================================================*/

#include "box.ch"
#include "its.ch"
#include "inkey.ch"

FUNCTION SDailyPost()

   LOCAL cOldClr := setcolor ( BN_COLOR )

   tone ( 2000, 1 )

  //  GetData() // Read Pos

   // 6 Update Item File
         SDailyItem()

   tone ( 2500, 1 )

   setcolor ( cOldClr )

RETURN NIL






FUNCTION IDailyPost()

   LOCAL cOldClr := setcolor ( BN_COLOR )
   local vBrowse, getlist := {}, sdate := date()

   SET CURSOR ON
   vBrowse := OpenWindow(10,30,12,50)
   @ 10,33 say "INVENTORY POSTING"
   @ 11,33 say "Date: "Get sdate
   read
   if lastkey() == K_ESC
      SET CURSOR OFF
      CloseWindow(vBrowse)
      return nil
   endif   
   
   SET CURSOR OFF
   CloseWindow(vBrowse)

   tone ( 2000, 1 )

   
   // 1 Process Stock Transfer
        DailyST(sdate)
        
   // 2 Process Stock Adjustments
        DailySA(sdate)

   // 3 Process Stock Returns
        DailStkRet(sdate)

   // 4 Process Stock Receipts
        DailStkRec(sdate)

   // 5 Process Purchase Orders
        DailyPO(sdate)

   // 6 Update Item File
   //     IDailyItem()

   tone ( 2500, 1 )

   setcolor ( cOldClr )

RETURN NIL


 