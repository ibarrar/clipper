*** DSTKRET.PRG ***

#include "box.ch"
#include "its.ch"
#include "set.ch"
#include "Janus.ch"

function DailStkRet(idate)
local aUnits :={}
local cOldPath 

 // Create display window.
 window( 8, 30, 12, 70, BN_COLOR )
 @ 1, 1 wsay  "Processing Stock Returns"

 // Get just warehouse path :
 aUnits := getUnits(1)

 // Use This path for data returns
 cOldPath := set(_SET_PATH, aUnits[1][3] )
 
 // then Open The warehouse unit items
 if NetUse("UITEMS",DB_SHARED,NUM_SECONDS)
    Set Index to UITEMS
 endif   
  
 // Open I file.
 if NetUse("ITEM.DBF",DB_SHARED,NUM_SECONDS)
    set index to I_001
 endif

 // Open PO file.
/* if NetUse("PO",DB_SHARED,NUM_SECONDS)
    set index to PO_001
 endif   
 if NetUse("PO_ITEMS",DB_SHARED,NUM_SECONDS)
    set index to POI_LINK
 endif   */
 if NetUse("RR",DB_SHARED,NUM_SECONDS)
    set index to RR_001
 endif       
 // Open RJ file.
 if NetUse("RJ",DB_SHARED,NUM_SECONDS)
   set index to RJ_001
 endif
 if NetUse("RJ_ITEMS",DB_SHARED,NUM_SECONDS)
    set index to RJI_LINK
 endif   
 
 RJ->(DbGotop())

 while !RJ->(EOF())

   // If posting status = 0, process this record.
   if (RJ->RJ_010 == 0 .or. RJ->RJ_010 == 7) .and. RJ->RJ_005 == idate

      // Find PO record.  If not found skip to next record.
   /*   if !( RR->(DbSeek(RJ->RJ_002)) .and. (PO->(DbSeek(RR->RR_002))) )
         RJ->(DbSkip())
         loop
      endif */

      // Add Stock Returns Quantity to PO->(Qty. Returned)
      // and update PO status.
      
      @ 2,  1 wsay " RJ: " + RJ->RJ_001

      RJ_ITEMS->(DbSeek(RJ->RJ_001))
      while RJ_ITEMS->RJI_LINK == RJ->RJ_001 .and. RJ_ITEMS->(!Eof())
      //  PO_ITEMS->(DbSeek(PO->PO_001))       
      //  while  PO_ITEMS->(!Eof()) .and. PO_ITEMS->POI_LINK == PO->PO_001
          if ITEM->(DbSeek(RJ_ITEMS->RJI_ITEM)) .and. (RJ_ITEMS->RJI_POST == 0)
            @ 2, 20 wsay "  I: " + RJ_ITEMS->RJI_ITEM
            @ 3,  1 wsay " Qty Returned: " + tran (RJ_ITEMS->RJI_QRET,"999,999,999.999")          
         //   PO_ITEMS->(RecLock(0))
         //   PO_ITEMS->POI_QRET += RJ_ITEMS->RJI_QRET      
         //   PO_ITEMS->(DbUnlock())
            RJ_ITEMS->(RecLock(0))
            RJ_ITEMS->RJI_POST := 1
            RJ_ITEMS->(DbUnLock(0))
            // The Central Database
            if (ITEM->(DbSeek(RJ_ITEMS->RJI_ITEM)))
               ITEM->(RecLock(0))
               ITEM->I_008 -= RJ_ITEMS->RJI_QRET
               ITEM->(DbUnlock())
            endif   
            // Now the Warehouse
            if (UITEMS->(DbSeek(RJ_ITEMS->RJI_ITEM)))
               UITEMS->(RecLock(0))
               UITEMS->UI_STK_BAL -= RJ_ITEMS->RJI_QRET
               UITEMS->(DbUnlock())
            endif               
            
          endif
        //  PO_ITEMS->(DbSkip())
       // enddo 
        RJ_ITEMS->(DbSkip())  
      enddo  

   //   PO->(RecLock(0))
   //   PO->PO_006 :=  2 // Update PO Status
   //   PO->(DbUnLock())

      // Mark as posted for daily updates.
      RJ->(RecLock(0))
      RJ->RJ_010 := 1
      RJ->RJ_011 := idate
      RJ->(DbUnlock(0))
    endif
      // Go next record.
      RJ->(DbSkip())
   enddo

   // Close all files.
   RJ_ITEMS->(DbCloseArea())
   RJ->(DbCloseArea())
   RR->(DbCloseArea())
  // PO_ITEMS->(DbCloseArea())
 //  PO->(DbCloseArea())
   ITEM->(DBCloseArea())
   UITEMS->(DbCloseArea())

   //Have to pack RJ_ITEMS
   if NetUse("RJ_ITEMS",DB_EXCLUSIVE,NUM_SECONDS)
      Set Index to RJI_LINK
      RJ_ITEMS->(__DbPack())
      RJ_ITEMS->(DbCloseArea())
   endif   

   // Restore Old Unit path
   set(_SET_PATH,cOldPath)
   // Remove window.
   KillWindow()

RETURN NIL


