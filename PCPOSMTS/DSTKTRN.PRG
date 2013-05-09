*** DSTKTRN.PRG ***
/* Module for Daily posting of Stock Transfers */

#include "box.ch"
#include "its.ch"
#include "set.ch"
#include "Janus.ch"

function DailyST(idate)
local aUnits := {}
local cOldPath := set(_SET_PATH)
local n

 // Create display window.
 window ( 8, 30, 14, 70, BN_COLOR )
 @ 1, 1 wsay "Processing Stock Transfers"

 // Get all Existing Units: code name & path

 aUnits :=  getUnits()

 // Open ST_ITEMS 
 if NetUse("ST_ITEMS",DB_SHARED,NUM_SECONDS)
    Set Index to STI_LINK
 endif   
 
 // Open ST file.
 if NetUse("ST",DB_SHARED,NUM_SECONDS)
    Set Index to ST_001
 endif    

 ST->(DbGotop())

 while !ST->(Eof())
 
   // if Posting status == 0, process this record.
   if ST->ST_005 == 0 .and. ST->(!Deleted()) .and. ST->ST_004 == idate

      @ 2,  1 wsay " ST: " + ST->ST_001
      
      // First we subtract all the transfered qty from the source
      n := aScan(aUnits,{|a| a[1] == ST->ST_002 })
      
      set(_SET_PATH,aUnits[n][3])
      if NetUse("UITEMS",DB_SHARED,NUM_SECONDS)
         Set Index to UITEMS
      endif   
      
      ST_ITEMS->(DbSeek(ST->ST_001))

      while ST_ITEMS->STI_LINK == ST->ST_001 .and. ST_ITEMS->(!Eof())
        if (ST_ITEMS->STI_POST == 0) .and. UITEMS->(DbSeek(ST_ITEMS->STI_ITEM))
           @ 2, 20 wsay " PLU: " + ST_ITEMS->STI_ITEM
           @ 3,  1 wsay " FROM : " + ST->ST_002 + " " + aUnits[n][2]
           @ 4,  1 wsay " Qty Transfered "+ trans(ST_ITEMS->STI_QADJ,"999,999.99") 
           UITEMS->(RecLock(0))
           UITEMS->UI_STK_BAL -= ST_ITEMS->STI_QADJ 
           IF UITEMS->UI_STK_BAL < 1
              UITEMS->UI_STK_OUT := idate
           ENDIF    
           UITEMS->(DbUnlock())
           ST_ITEMS->(RecLock(0))
           ST_ITEMS->STI_POST := 1
           ST_ITEMS->(DbUnlock())
           
        endif  
        ST_ITEMS->(DbSkip())
      enddo

      UITEMS->(DbCloseArea())  

      // Next we Add all the transfered qty to the destination
      n := aScan(aUnits,{|a| a[1] = ST->ST_003 })
      
      set(_SET_PATH,aUnits[n][3])
      if NetUse("UITEMS",DB_SHARED,NUM_SECONDS)
         Set Index to UITEMS
      endif   
      
      ST_ITEMS->(DbSeek(ST->ST_001))

      while ST_ITEMS->STI_LINK == ST->ST_001 .and. ST_ITEMS->(!Eof())
        if (ST_ITEMS->STI_POST == 1) .and. UITEMS->(DbSeek(ST_ITEMS->STI_ITEM))
           @ 2, 20 wsay " PLU: " + ST_ITEMS->STI_ITEM
           @ 4, 1 wsay " TO : " + ST->ST_003 + " " + aUnits[n][2]
           @ 5, 1 wsay " Qty Transfered "+ trans(ST_ITEMS->STI_QADJ,"999,999.99") 
           UITEMS->(RecLock(0))
           UITEMS->UI_STK_BAL += ST_ITEMS->STI_QADJ 
           UITEMS->(DbUnlock())
          // ST->(RecLock(0))
          // ST->ST_005 := 2
          // ST->(DbUnlock())
        endif  
        ST_ITEMS->(DbSkip())
      enddo

      UITEMS->(DbCloseArea())        

      // Post the stk transfer record
      ST->(RecLock(0))
      ST->ST_005 := 1
      ST->ST_006 := idate      
      ST->(DbUnlock())
      
   endif   
   // Go next record.
   ST->(DbSkip())
   
 enddo   

 // Close all files.
 ST_ITEMS->(DbCloseArea())
 ST->(DbCloseArea())

 //Have to pack ST_ITEMS
 if NetUse("ST_ITEMS",DB_EXCLUSIVE,NUM_SECONDS)
    Set Index to STI_LINK
    ST_ITEMS->(__DbPack())
    ST_ITEMS->(DbCloseArea())
 endif 
        
 // Restore Old Units 
 set(_SET_PATH, cOldPath)      
 // Remove window.
 KillWindow()    

RETURN NIL
