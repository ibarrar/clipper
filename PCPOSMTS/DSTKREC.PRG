*** DSTKREC.PRG ***

#include "box.ch"
#include "its.ch"
#include "set.ch"
#include "Janus.ch"

function DailStkRec(idate)
local cOldPath,aUnits := {}    

   // Create display window.
   window ( 8, 30, 12, 70, BN_COLOR )
   @ 1, 1 wsay "Processing Stock Receipts"

   aUnits :=  GetUnits(1)

   cOldPath :=  set(_SET_PATH,aUnits[1][3])
   // Open Unit Brance Items in this case the warehouse
   if NetUse("UITEMS",DB_SHARED,NUM_SECONDS)
      Set Index to UITEMS
   endif   

   // Open PO file.
/*   if NetUse("PO",DB_SHARED,NUM_SECONDS)
    set index to PO_001
   endif   
   if NetUse("PO_ITEMS",DB_SHARED,NUM_SECONDS)
     set index to POI_LINK
   endif   */
 
   // Open I file.
   if NetUse("ITEM.DBF",DB_SHARED,NUM_SECONDS)
     set index to I_001
   endif

   // Open RR file.
   if NetUse("RR",DB_SHARED,NUM_SECONDS)
     set index to RR_001
   endif
   if NetUse("RR_ITEMS",DB_SHARED,NUM_SECONDS)
     set index to RRI_LINK
   endif
          
   RR->(DbGotop())

   while !RR->(EOF())
   // If posting status = 0, process this record.
   if (RR->RR_010 == 0 .or. RR->RR_010 == 7) .and.  RR->RR_006 == idate
     // Find PO record.  If not found skip to next record.
  /*   if !(PO->(DbSeek(RR->RR_002)) )
             RR->(DbSkip())
             loop
     endif */

      @ 2,  1 wsay " RR: " + RR->RR_001

      RR_ITEMS->(DbSeek(RR->RR_001))
      while RR_ITEMS->RRI_LINK == RR->RR_001 .and. RR_ITEMS->(!Eof())            
    //    PO_ITEMS->(DbSeek(PO->PO_001))       
     //   while  PO_ITEMS->(!Eof()) .and. PO_ITEMS->POI_LINK == PO->PO_001
       //   if RR_ITEMS->RRI_ITEM == PO_ITEMS->POI_ITEM
            if ITEM->(DbSeek(RR_ITEMS->RRI_ITEM)) .and. (RR_ITEMS->RRI_POST == 0)
              @ 2, 20 wsay "  I: " + RR_ITEMS->RRI_ITEM
              @ 3,  1 wsay " Qty Received: " + tran (RR_ITEMS->RRI_QREC,"999,999,999.999")          
         //     PO_ITEMS->(RecLock(0))
                        // Add Stock Received Quantity to PO Qty. Received
         //     PO_ITEMS->POI_QREC += RR_ITEMS->RRI_QREC      
           //   PO_ITEMS->(DbUnlock())
              RR_ITEMS->(RecLock(0))
              RR_ITEMS->RRI_POST := 1
              RR_ITEMS->(DbUnLOck(0))
                        // Add Stock Received Quantity to Stock Balance
                        // and update date received.
              ITEM->(RecLock(0)) 
              ITEM->I_008 += RR_ITEMS->RRI_QREC
                //  ITEM->(Date Received) :=  RR->(Transaction Date)
                 ITEM->I_014 := RR->RR_005 // not used naman eh...
              ITEM->(DbUnlock())              
                  // Now the Warehouse
              if (UITEMS->(DbSeek(RR_ITEMS->RRI_ITEM)))
                 UITEMS->(RecLock(0))
                 UITEMS->UI_STK_BAL += RR_ITEMS->RRI_QREC
              // UITEMS->(Date Received) :=  RR->(Transaction Date)
                 UITEMS->UI_DATEREC := RR->RR_005
                 UITEMS->(DbUnlock())
              endif               
            endif  
         // endif
        //  PO_ITEMS->(DbSkip())
       // enddo 
        RR_ITEMS->(DbSkip())  
      enddo  

   /*   if PO->PO_006 < 2 
                // Update PO Status
        PO->(RecLock(0))
        PO->PO_006 :=  1 
        PO->(DbUnLock())
      endif */

                // Mark as posted for daily updates.
      RR->(RecLock(0))
      RR->RR_010 := 1
      RR->RR_011 := idate
      RR->(DbUnLock())

     endif
      // Go next record.
      RR->(DbSkip())

  enddo

   // Close all files.
   RR->(DbCloseArea())
   RR_ITEMS->(DbCloseArea())
   ITEM->(DbCloseArea())
 //  PO->(DbCloseArea())
 //  PO_ITEMS->(DbCloseArea())

   //Have to pack RR_ITEMS
   if NetUse("RR_ITEMS",DB_EXCLUSIVE,NUM_SECONDS)
      Set Index to RRI_LINK
      RR_ITEMS->(__DbPack())
      RR_ITEMS->(DbCloseArea())
   endif   

   // Restore Old Unit Path
   set(_SET_PATH,cOldPath) 
   // Remove window.
   killwindow()

return nil

