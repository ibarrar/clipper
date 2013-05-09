*** DAILYSA.PRG ***
/**********************************************************************8
*
* This is a reminder to anyone who wish to read this code
* . all STOCK ADJUSTMENT either negative or positive is coursed thru the 
* . warehouse and is transfered to any unit by STOCK TRANSFER if need be.
* . 11/13/95 as per rci.
*/

#include "box.ch"
#include "its.ch"
#include "set.ch"
#include "Janus.ch"

memvar nunit

function DailySA(idate)
local n := 0, pOldPath 
local aUnits := {}

 // Create display window.
 window ( 8, 30, 13, 70, BN_COLOR )
 @ 1, 1 wsay "Processing Stock Adjustments"

    if NetUse("UNIT",DB_SHARED,NUM_SECONDS)
      set Index to UNIT
   endif  
   if UNIT->(DbSeek(padl(alltrim(str(nUnit)),3,"0"))) 
      Set(_SET_PATH,UNIT->UNIT_PATH)
   endif   
   if NetUse("UITEMS",DB_SHARED,NUM_SECONDS)
      Set Index to UITEMS
   endif   

 // Open I file.
 if NetUse("ITEM.DBF",DB_SHARED,NUM_SECONDS)
     set index to I_001
 endif   

 // Open SA file.
 if NetUse("SA",DB_SHARED,NUM_SECONDS)
        set index to SA_001
 endif   

 if NetUse("SA_ITEMS",DB_SHARED,NUM_SECONDS)
     set index to SAI_LINK
 endif    
 
 SA->(DbGotop())

 while ! SA->(EOF())
 
     // If posting status = 0, process this record.
     if SA->SA_003 == 0 .and. SA->(!Deleted()) .and. SA->SA_002 == idate
       
        SA_ITEMS->(DbSeek(SA->SA_001))
        while SA_ITEMS->SAI_LINK == SA->SA_001 .and. SA_ITEMS->(!EOF());
           .and. SA_ITEMS->SAI_UNIT ==  padl(alltrim(str(nUnit)),3,"0")                    
           // Find I record.  If not found skip to next record.
           if (SA_ITEMS->SAI_POST == 0) .and. ITEM->(DbSeek(SA_ITEMS->SAI_ITEM))
               // Add Stock Adjustment Quantity to Stock Balance.
                ITEM->(RecLock(0))
                ITEM->I_008 += SA_ITEMS->SAI_QADJ
                ITEM->(DbUnLock())                               
                if UITEMS->(DbSeek(SA_ITEMS->SAI_ITEM))
                  UITEMS->(RecLock(0))
                  UITEMS->UI_STK_BAL += SA_ITEMS->SAI_QADJ
                  UITEMS->(DbUnlock())
                endif  
                @ 2, 1  wsay " SA: "  + SA->SA_001
                @ 2, 20 wsay " PLU: " + SA_ITEMS->SAI_ITEM
                @ 3, 1  wsay " Stock balance " + tran(ITEM->I_008, "999,999,999" )
                @ 4, 1  wsay " Qty adjusted  " + tran(SA_ITEMS->SAI_QADJ, "99,999,999" )                
                
                // Mark as posted for daily updates.
                SA_ITEMS->(RecLock(0))
                SA_ITEMS->SAI_POST := 1
                SA_ITEMS->(DbUnlock())
                SA->(FilLock(0))
                SA->SA_003 := 1
                SA->SA_004 := idate
                SA->(DbUnLock())
           endif     
           SA_ITEMS->(DbSkip())           
         enddo                       

      endif 
      // Go next record.
      SA->(DbSkip())
    enddo

    // Close all files.
    SA_ITEMS->(DbCloseArea())
    SA->(DbCloseArea())
    ITEM->(DbCloseArea())
    UITEMS->(DbCloseArea())

   //Have to pack SA_ITEMS
   if NetUse("SA_ITEMS",DB_EXCLUSIVE,NUM_SECONDS)
      Set Index to SAI_LINK
      SA_ITEMS->(__DbPack())
      SA_ITEMS->(DbCloseArea())
   endif

    // Restore Old Units 
    set(_SET_PATH, pOldPath)      
    // Remove window.
    KillWindow()    

RETURN NIL


