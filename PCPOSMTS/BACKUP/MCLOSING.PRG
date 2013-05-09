*** MCLOSING.PRG ***

#include "box.ch"
#include "its.ch"
#include "Janus.ch"
#include "inkey.ch"

#define DEFAULT_PATH "MTSDATA"
#define DATA_PATH    ".\MTSDATA\"

memvar dToday

function MClosing()
local cThisDefault, aNtx
local cOldClr := setcolor ( BN_COLOR )
local cCurrDir
local vBrowse, getlist := {}, sdate := date()

   SET CURSOR ON
   vBrowse := OpenWindow(10,30,12,50)
   @ 10,33 say "MONTHLY CLOSING "
   @ 11,33 say "Date: "Get sdate
   read
   if lastkey() == K_ESC
      SET CURSOR OFF
      CloseWindow(vBrowse)
      return nil
   endif   
   SET CURSOR OFF
   CloseWindow(vBrowse)


   if (SetCursor() == 1, SetCursor(0), SetCursor(1))

   @ 1, 1 wsay "Rebuilding Indices.        "
   Reindex()       

   // Create display window.
   window ( 5, 30, 7, 70, CONFIRM_COLOR )
   @ 1, 1 wsay "Scanning for Daily Posting."
   tone ( 3000, 1 )

     
   /* Proceed with updating for monthly transactions.
      Replace posting status with 2 for records with posting status == 1.
      Update posting date.
      Rebuild indices. */

   // Units.  This file is found in CENTRAL ONLY.
   @ 1, 1 wsay "Updating Units.            "

   

   // Purchase Orders.
   @ 1, 1 wsay "Updating Purchase Orders.  "
   
   if NetUse("PO",DB_SHARED,NUM_SECONDS)
     Set Index to PO_001
     PO->(FilLock(0)) 
     PO->(DbSetFilter( {|| PO->PO_007 = 1 .and. month (PO->PO_003) == month (sdate) .and. year (PO->PO_003) == year (sdate)}, "PO->PO_012 = 1 .and. month (PO->PO_003) == month (sdate) .and. year (PO->PO_003) == year (sdate)" ))
     PO->(DbGoTop())
     PO->(DBEval( {|| PO->PO_007 := 2, PO->PO_008 := sdate},,,,, .F. ))
     PO->(dbClearFil())
     PO->(DbUnlock())
     PO->(DbCloseArea())
   endif     

   // Stock Receipts.
   @ 1, 1 wsay "Updating Stock Receipts.   "
   if NetUse("RR",DB_SHARED,NUM_SECONDS)
      Set Index to RR_001
      RR->(FilLock(0))
      RR->(DbSetFilter( {|| RR->RR_010 = 1 .and. month (RR->RR_005) == month (sdate) .and. year (RR->RR_005) == year (sdate)}, "RR->RR_010 = 1 .and. month (RR->RR_005) == month (sdate) .and. year (RR->RR_005) == year (sdate)" ))
      RR->(DbGoTop())
      RR->(DBEval( {|| RR->RR_010 := 2, RR->RR_011 := sdate},,,,, .F. ))
      RR->(DbClearFil())
      RR->(DbUnlock())
      RR->(dbCloseArea())      
   endif
  
   // Stock Returns.
   @ 1, 1 wsay "Updating Stock Returns.    "
   if NetUse("RJ",DB_SHARED,NUM_SECONDS )
      DbClearIndex()
      Set Index to RJ_001
      RJ->(FilLock(0))
      RJ->(DbSetFilter( {|| RJ->RJ_010 = 1 .and. month (RJ->RJ_005) == month (sdate) .and. year (RJ->RJ_005) == year (sdate)}, "RJ->RJ_010 = 1 .and. month (RJ->RJ_005) == month (sdate) .and. year (RJ->RJ_005) == year (sdate)" ))
      RJ->(DbGoTop())
      RJ->(DbEval( {|| _FIELD->rj->rj_010 := 2, _FIELD->rj->rj_011 := sdate},,,,, .F. ))
      RJ->(DbClearFil())
      RJ->(DbUnlock())
      RJ->(DbCloseArea())
   endif   

   // Stock Adjustments.
   @ 1, 1 wsay "Updating Stock Adjustments."
   if NetUse( "SA",DB_SHARED,NUM_SECONDS)
      Set Index to SA_001
      SA->(FilLock(0))
      SA->(DbSetFilter( {|| SA->SA_003 = 1 .and. month (SA->SA_004) == month (sdate) .and. year (SA->SA_004) == year (sdate)}, "SA->SA_003 = 1 .and. month (SA->SA_004) == month (sdate) .and. year (SA->SA_004) == year (sdate)" ))
      SA->(dbGoTop())
      SA->(DBEval( {|| _FIELD->sa->sa_003 := 2, _FIELD->sa->sa_004 := sdate},,,,, .F. ))
      SA->(DbClearFil())
      SA->(DbUnlock())
      SA->(dbCloseArea())
   endif  

   // Stock Transfer.
   @ 1, 1 wsay "Updating Stock Transfer."
   if NetUse( "ST",DB_SHARED,NUM_SECONDS)
      Set Index to ST_001
      ST->(FilLock(0))
      ST->(DbSetFilter( {|| ST->ST_005 = 1 .and. month (ST->ST_004) == month (sdate) .and. year (ST->ST_004) == year (sdate)}, "ST->ST_005 = 1 .and. month (ST->ST_004) == month (sdate) .and. year (ST->ST_004) == year (sdate)" ))
      ST->(dbGoTop())
      ST->(DBEval( {|| _FIELD->ST->ST_005 := 2, _FIELD->ST->ST_004 := sdate},,,,, .F. ))
      ST->(DbClearFil())
      ST->(DbUnlock())
      ST->(dbCloseArea())
   endif  

   // Items.
   if NetUse("ITEM.DBF",DB_EXCLUSIVE,NUM_SECONDS )
      Set Index to I_001,I_002
      ITEM->(__DbPack())
      ITEM->(DBCloseArea())
   endif     

    if NetUse("ITEM.DBF",DB_SHARED,NUM_SECONDS )
      Set Index to I_001
      // Add Stock Balance to Beginning Balance.
      @ 1, 1 wsay "Updating Item Stock Balance."
      ITEM->(FilLock(0))
      ITEM->(DbEval( {|| ITEM->I_009 := ITEM->I_008, ITEM->I_027:= 0 ,ITEM->I_028:= 0,ITEM->I_029:= 0 ,ITEM->I_030:= 0 },,,,, .f. ))
      ITEM->(DbUnlock())
      ITEM->(DbCloseArea())
   endif

   // IV
   if NetUse("IV",DB_EXCLUSIVE,NUM_SECONDS)
      Set Index to IV_LINK
      IV->(__DbPack())
      IV->(DbCloseArea())
   endif    
   
   // Hourly Sales.
/*   @ 1, 1 wsay "Clearing Hourly Sales."
   if NetUse("HR",DB_EXCLUSIVE,NUM_SECONDS)
      HR->(__DBZap())
      HR->(DbCloseArea())
   endif   */

   // Vendors.
   // Class.  This file is found in CENTRAL ONLY.
#ifdef CLASS_LINK   
   @ 1, 1 wsay "Resetting Open to Buy Budget."
   tone ( 3000, 1 )

   if NetUse("CL",DB_SHARED,NUM_SECONDS)
      set index to cl_001

      CL->(FilLock(0))
      REPLACE CL->CL_005 WITH CL->CL_004 ALL
      CL->(DbUnlock())
      CL->(DbCloseArea())   
   endif
#endif   

/*   if NetUse("PLUTRANS",DB_EXCLUSIVE,NUM_SECONDS )
      PLUTRANS->(__DbZap())
      PLUTRANS->(DBCloseArea())
   endif     */

   // Zero out items (UITEMS.DBF)
     MonthlyItem(sdate)
   
   killwindow ()
   tone ( 3500, 1 )

   if (SetCursor() == 0, SetCursor(1), SetCursor(0))

   setcolor ( cOldClr )

RETURN NIL


/*function MReindex()
local cCurrDefa
local aDbf,cOldPath 
      

         cOldPath := set(_SET_DEFAULT,"")
         
         l_chdir ( DEFAULT_PATH )  // Change to central subdirectory.

         message("Please wait while I reindex all files . . .")

         // PO, RR, RJ, ST, SA, V, I, HR dbf and ntx.
         aDbf := makedbf1() // Create the array entries.
         createntx ( aDbf, 0 ) // Create the NTXes.

         // DP, CL, U, CLR, SZ dbf and ntx.
         aDbf := makedbf2()   // Create the array entries.
         createntx ( aDbf, 0 ) // Create the NTXes.

              // Go back to the work directory.
         l_chdir (".." )   

         set (_SET_DEFAULT, cOldPaTh )
   
   
return nil */
