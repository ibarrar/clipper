*** DITEM.PRG ***

#include "box.ch"
#include "its.ch"
#include "set.ch"
#include "Janus.ch"
#include "inkey.ch"


function SDailyItem()

local aUnits := {}
local n,cOldPath := set(_SET_PATH)
local nTotalAmt,nGttlAmt:=0, getlist := {},nDiff := 0
local nTotalCnt,nGttlCnt:=0, stk := 0, vBrowse, sdate := date()

   SET CURSOR ON
   vBrowse := OpenWindow(10,30,12,50)
   @ 10,35 say "SALES POSTING"
   @ 11,33 say "Date: "Get sdate
   read
   if lastkey() == K_ESC
      SET CURSOR OFF
      CloseWindow(vBrowse)
      return nil
   endif   
   SET CURSOR OFF
   CloseWindow(vBrowse)

#ifdef FM_ITEMS   
   if NetUse("FM",DB_SHARED,NUM_SECONDS)
      set index to FM
   endif   
#endif

   // Open I file.
   If NetUse("ITEM.DBF",DB_SHARED,NUM_SECONDS)
      set index to I_001
   endif   
#ifdef CLASS_LINK
   If NetUse("CL",DB_SHARED,NUM_SECONDS)
      set index to CL_001
   endif   
#endif

   if NetUse("RR_ITEMS",DB_SHARED,NUM_SECONDS)
      set index to RRI_COST
   endif                     

   while ITEM->(!EOF())
    IF ITEM->I_018 <> 0 .OR. ITEM->I_017 <> 0 .OR. ITEM->I_027 <> 0 .OR. ITEM->I_028 <> 0
      ITEM->(RecLock(0))
      ITEM->I_018 := 0
      ITEM->I_017 := 0 
      ITEM->I_027 := 0
      ITEM->I_028 := 0 
      ITEM->(DbUnlock())               
    ENDIF  
      ITEM->(DbSkip())
   enddo   

   // Create display window.
   window ( 8, 30, 13, 75, BN_COLOR )
   @ 1, 1 wsay "Processing ITEMS "

   // Get Units except the warehouse
   aUnits := getUnits(0)

   for n:= 1 to len(aUnits)

     set(_SET_PATH,aUnits[n][3])

     if NetUse("UITEMS",DB_SHARED,NUM_SECONDS)
        Set Index to UITEMS
     endif

     nTotalAmt := 0  // Reset  
     nTotalCnt := 0  // Accumulators
     // Get total Sales And Amount for the day
     while UITEMS->(!EOF())
      IF UITEMS->UI_ACCDSLS <> 0 .OR. UITEMS->UI_ACCDCNT <> 0
        // nTotalAmt += UITEMS->UI_ECRDSLS  
        // nTotalCnt += UITEMS->UI_ECRDCNT
         UITEMS->(RecLock(0))
         UITEMS->UI_ACCDSLS := 0
         UITEMS->UI_ACCDCNT := 0
         UITEMS->(DbUnLock())
       endif
       UITEMS->(DbSkip())
     enddo  

     UITEMS->(DbGotop())     

     While UITEMS->(!Eof()) 
      IF UITEMS->UI_POSTDTE == sdate

        if UITEMS->(!Deleted()) .and. ITEM->(DbSeek(UITEMS->UI_PLUCODE))

           @ 2, 1 wsay " UNIT: " +aUnits[n][1]+" "+aUnits[n][2]
           @ 3, 1 wsay " ITEM: " + UITEMS->UI_PLUCODE + " STK#: "+UITEMS->UI_STKCODE
           @ 4, 1 wsay " STATUS: " 

           RR_ITEMS->(DbSeek(UITEMS->UI_PLUCODE))
           Do While RR_ITEMS->(!Eof()) .and. RR_ITEMS->RRI_ITEM == UITEMS->UI_PLUCODE
            IF RR_ITEMS->RRI_QREC != RR_ITEMS->RRI_SOLD 
               RR_ITEMS->(RecLock(0))
               RR_ITEMS->RRI_SOLD += UITEMS->UI_ECRDCNT 
               RR_ITEMS->(DbUnLock())
               nDiff := RR_ITEMS->RRI_QREC - RR_ITEMS->RRI_SOLD
               IF nDiff < 0 .OR. nDiff == 0
                  RR_ITEMS->(RecLock(0))
                  RR_ITEMS->RRI_SOLD := RR_ITEMS->RRI_QREC
                  RR_ITEMS->(DbUnLock())
                  RR_ITEMS->(DbSkip())
                  RR_ITEMS->(RecLock(0))
                  RR_ITEMS->RRI_SOLD := nDiff
                  RR_ITEMS->(DbUnLock())
                  ITEM->(RecLock(0))
                  ITEM->I_038 := RR_ITEMS->RRI_AGEC
                  ITEM->I_007 := RR_ITEMS->RRI_COST
                  ITEM->(DbUnLock())
                  #ifdef FM_ITEMS                    
                     FM->(FilLock())
                     FM->(DbAppend())
                     FM->TRANSNO := FMNext()
                     FM->OP_CODE := "02" // EDIT
                     FM->FILE_ID := "PL" // File ID Item
                     FM->RECDATA := GetData()
                     FM->POSTDATE:= Date()
                     FM->POSTSTAT:= 0
                     FM->(DbUnLock())
                  #endif                
                  EXIT
               ENDIF
               EXIT   
            ENDIF
            RR_ITEMS->(DbSkip())
           enddo             
           
            
           ITEM->(RecLock(0))
            ITEM->I_018 += UITEMS->UI_ECRDSLS
            ITEM->I_017 += UITEMS->UI_ECRDCNT 
            ITEM->I_027 += UITEMS->UI_ECRDSLS
            ITEM->I_028 += UITEMS->UI_ECRDCNT 
            ITEM->I_029 += UITEMS->UI_ECRDSLS
            ITEM->I_030 += UITEMS->UI_ECRDCNT 
            ITEM->I_031 += UITEMS->UI_ECRDSLS
            ITEM->I_032 += UITEMS->UI_ECRDCNT 
            ITEM->I_026 := UITEMS->UI_POSTDTE
            ITEM->(DbUnlock())               
           
           UITEMS->(RecLock(0))
           // Daily Stock Posting 
           UITEMS->UI_STK_BAL -= UITEMS->UI_ECRDCNT
           UITEMS->UI_ACCDSLS += UITEMS->UI_ECRDSLS
           UITEMS->UI_ACCDCNT += UITEMS->UI_ECRDCNT
           UITEMS->UI_ECRMSLS += UITEMS->UI_ECRDSLS
           UITEMS->UI_ECRMCNT += UITEMS->UI_ECRDCNT
           UITEMS->UI_ECRASLS += UITEMS->UI_ECRDSLS
           UITEMS->UI_ECRACNT += UITEMS->UI_ECRDCNT

            
           UITEMS->UI_ECRDSLS := 0  
           UITEMS->UI_ECRDCNT := 0 
           
         //  UITEMS->UI_DSLRATE := (UITEMS->UI_ACCDSLS/nTotalAmt)*100     
           UITEMS->(DBUnLock())
           
        endif
      ENDIF  
        // Goto Next record.
        UITEMS->(DBSkip())
        
     enddo

     UITEMS->(DBCloseArea())

     nGttlAmt += nTotalAmt
     
   next n     


   // Now the warehouse all the sales are here 

   aUnits := GetUnits(1) // warehouse only

   set(_SET_PATH,aUnits[1][3])

     if NetUse("UITEMS",DB_SHARED,NUM_SECONDS)
        Set Index to UITEMS
     endif   
     UITEMS->(DbGotop())

     While UITEMS->(!Eof())
      IF UITEMS->UI_POSTDTE == sdate

        if UITEMS->(!Deleted()) .and. ITEM->(DbSeek(UITEMS->UI_PLUCODE))

           @ 2, 1 wsay " UNIT: " +aUnits[1][1]+" "+aUnits[1][2]+"  "
           @ 3, 1 wsay " ITEM: " +UITEMS->UI_PLUCODE+" STK#: "+UITEMS->UI_STKCODE
           @ 4, 1 wsay " STATUS: "

           UITEMS->(RecLock(0))

           // Daily Stock Posting 
           // Because there is no actual sales in warehouse
           // UITEMS->UI_ECRDSLS is always ZERO
           // and UITEMS->UI_STK_BAL is only affected by:
           * Stock Receipts or deliveries
           * Stock Adjustment
           * Stock Returns 
           * and by Stock Transfers to and from different units
           * UITEMS->UI_STK_BAL -= UITEMS->UI_ECRDSLS // not allowed

            UITEMS->UI_ECRDSLS := ITEM->I_018 
            UITEMS->UI_ECRDCNT := ITEM->I_017 
            UITEMS->UI_ACCDSLS := ITEM->I_027 
            UITEMS->UI_ACCDCNT := ITEM->I_028 
            UITEMS->UI_ECRMSLS := ITEM->I_029 
            UITEMS->UI_ECRMCNT := ITEM->I_030 
            UITEMS->UI_ECRASLS := ITEM->I_031
            UITEMS->UI_ECRACNT := ITEM->I_032
            // UITEMS->UI_POSTDTE := ITEM->I_026 

      
         //  UITEMS->UI_DSLRATE := (UITEMS->UI_ACCDSLS/nGttlAmt)*100
           UITEMS->(DBUnLock())           

        endif
      ENDIF  
        // Goto Next record.
        UITEMS->(DBSkip())
        
     enddo

     UITEMS->(DBCloseArea())     

     ITEM->(DbCloseArea())
  
     DbcloseAll()

   // Restore OldPath
   set(_SET_PATH,cOldPath)  
   // Remove window.
   killwindow()

return nil 




function MonthlyItem(sdate)

local aUnits := {}
local n,cOldPath := set(_SET_PATH)
local nTotalAmt,nGttlAmt:=0,i18:=0
local nTotalCnt,nGttlCnt:=0, stk := 0

   // Open I file.
   If NetUse("ITEM.DBF",DB_SHARED,NUM_SECONDS)
      set index to I_001
   endif   

   // Create display window.
   window ( 8, 30, 13, 75, BN_COLOR )
   @ 1, 1 wsay "Processing ITEMS "

   // Get Units except the warehouse
   aUnits := getUnits(0)

   for n:= 1 to len(aUnits)

     set(_SET_PATH,aUnits[n][3])

     if NetUse("UITEMS",DB_SHARED,NUM_SECONDS)
        Set Index to UITEMS
     endif


     UITEMS->(DbGotop())     

     While UITEMS->(!Eof())


        if UITEMS->(!Deleted()) .and. ITEM->(DbSeek(UITEMS->UI_PLUCODE)) //  month(UITEMS->UI_POSTDTE) == month(date())
           UITEMS->(RecLock(0))
          // UITEMS->UI_POSTDTE := date()   
           UITEMS->(DbUnLock())
           if  month(UITEMS->UI_POSTDTE) == month(sdate)

           @ 2, 1 wsay " UNIT: " +aUnits[n][1]+" "+aUnits[n][2]
           @ 3, 1 wsay " ITEM: " + UITEMS->UI_PLUCODE + " STK#: "+UITEMS->UI_STKCODE
           @ 4, 1 wsay " STATUS: " 
           UITEMS->(RecLock(0))
           UITEMS->UI_BEG_BAL := UITEMS->UI_STK_BAL 

         UITEMS->UI_ECRDSLS := 0
         UITEMS->UI_ECRDCNT := 0
         UITEMS->UI_ACCDSLS := 0
         UITEMS->UI_ACCDCNT := 0
         UITEMS->UI_ECRMSLS := 0
         UITEMS->UI_ECRMCNT := 0
//         UITEMS->UI_STK_BAL := 0

            ITEM->(RecLock(0))
            ITEM->I_018 := UITEMS->UI_ECRDSLS
            ITEM->I_017 := UITEMS->UI_ECRDCNT 
            ITEM->I_027 := UITEMS->UI_ACCDSLS
            ITEM->I_028 := UITEMS->UI_ACCDCNT 
            ITEM->I_029 := UITEMS->UI_ECRMSLS
            ITEM->I_030 := UITEMS->UI_ECRMCNT 
            ITEM->I_026 := UITEMS->UI_POSTDTE
            ITEM->(DbUnlock())               
           
           UITEMS->UI_DSLRATE := 0     
           UITEMS->(DBUnLock())
        endif           
        endif
        // Goto Next record.
        UITEMS->(DBSkip())
        
     enddo

     UITEMS->(DBCloseArea())

     
   next n     


   // Now the warehouse all the sales are here 

   aUnits := GetUnits(1) // warehouse only

   set(_SET_PATH,aUnits[1][3])

     if NetUse("UITEMS",DB_SHARED,NUM_SECONDS)
        Set Index to UITEMS
     endif   
     
   
     UITEMS->(DbGotop())

     While UITEMS->(!Eof())
       
          if UITEMS->(!Deleted()) .and. ITEM->(DbSeek(UITEMS->UI_PLUCODE)) //  month(UITEMS->UI_POSTDTE) == month(date())
           UITEMS->(RecLock(0))
         //  UITEMS->UI_POSTDTE := date()   
           UITEMS->(DbUnLock())
           if  month(UITEMS->UI_POSTDTE) == month(sdate)

           @ 2, 1 wsay " UNIT: " +aUnits[1][1]+" "+aUnits[1][2]
           @ 3, 1 wsay " ITEM: " + UITEMS->UI_PLUCODE + " STK#: "+UITEMS->UI_STKCODE
           @ 4, 1 wsay " STATUS: " 
           UITEMS->(RecLock(0))
           UITEMS->UI_BEG_BAL :=  UITEMS->UI_STK_BAL 

         UITEMS->UI_ECRDSLS := 0
         UITEMS->UI_ECRDCNT := 0
         UITEMS->UI_ACCDSLS := 0
         UITEMS->UI_ACCDCNT := 0
         UITEMS->UI_ECRMSLS := 0
         UITEMS->UI_ECRMCNT := 0
//         UITEMS->UI_STK_BAL := 0

           UITEMS->UI_DSLRATE := 0     
           UITEMS->(DBUnLock())
        endif           
        endif
        // Goto Next record.
        UITEMS->(DBSkip())
        
     enddo

     UITEMS->(DBCloseArea())
        

     ITEM->(DbCloseArea())
  
   *  IV->(DbCloseArea())

   // Restore OldPath
   set(_SET_PATH,cOldPath)  
   // Remove window.
   killwindow()

return nil 


function AnnualItem(sdate)

local aUnits := {}
local n,cOldPath := set(_SET_PATH)
local nTotalAmt,nGttlAmt:=0,i18:=0
local nTotalCnt,nGttlCnt:=0, stk := 0

   // Open I file.
   If NetUse("ITEM.DBF",DB_SHARED,NUM_SECONDS)
      set index to I_001
   endif   

   // Create display window.
   window ( 8, 30, 13, 75, BN_COLOR )
   @ 1, 1 wsay "Processing ITEMS "

   // Get Units except the warehouse
   aUnits := getUnits(0)

   for n:= 1 to len(aUnits)

     set(_SET_PATH,aUnits[n][3])

     if NetUse("UITEMS",DB_SHARED,NUM_SECONDS)
        Set Index to UITEMS
     endif


     UITEMS->(DbGotop())     

     While UITEMS->(!Eof())


        if UITEMS->(!Deleted()) .and. ITEM->(DbSeek(UITEMS->UI_PLUCODE)) //  month(UITEMS->UI_POSTDTE) == month(date())
           UITEMS->(RecLock(0))
          // UITEMS->UI_POSTDTE := date()   
           UITEMS->(DbUnLock())
           if  year(UITEMS->UI_POSTDTE) == year(sdate)

           @ 2, 1 wsay " UNIT: " +aUnits[n][1]+" "+aUnits[n][2]
           @ 3, 1 wsay " ITEM: " + UITEMS->UI_PLUCODE + " STK#: "+UITEMS->UI_STKCODE
           @ 4, 1 wsay " STATUS: " 
           UITEMS->(RecLock(0))
           UITEMS->UI_BEG_BAL := UITEMS->UI_STK_BAL 

         UITEMS->UI_ECRDSLS := 0
         UITEMS->UI_ECRDCNT := 0
         UITEMS->UI_ACCDSLS := 0
         UITEMS->UI_ACCDCNT := 0
         UITEMS->UI_ECRMSLS := 0
         UITEMS->UI_ECRMCNT := 0
         UITEMS->UI_ECRASLS := 0
         UITEMS->UI_ECRACNT := 0
//         UITEMS->UI_STK_BAL := 0

            ITEM->(RecLock(0))
            ITEM->I_018 := UITEMS->UI_ECRDSLS
            ITEM->I_017 := UITEMS->UI_ECRDCNT 
            ITEM->I_027 := UITEMS->UI_ACCDSLS
            ITEM->I_028 := UITEMS->UI_ACCDCNT 
            ITEM->I_029 := UITEMS->UI_ECRMSLS
            ITEM->I_030 := UITEMS->UI_ECRMCNT 
            ITEM->I_031 := UITEMS->UI_ECRASLS
            ITEM->I_032 := UITEMS->UI_ECRACNT 
            ITEM->I_026 := UITEMS->UI_POSTDTE
            ITEM->(DbUnlock())               
           
           UITEMS->UI_DSLRATE := 0     
           UITEMS->(DBUnLock())
        endif           
        endif
        // Goto Next record.
        UITEMS->(DBSkip())
        
     enddo

     UITEMS->(DBCloseArea())

     
   next n     


   // Now the warehouse all the sales are here 

   aUnits := GetUnits(1) // warehouse only

   set(_SET_PATH,aUnits[1][3])

     if NetUse("UITEMS",DB_SHARED,NUM_SECONDS)
        Set Index to UITEMS
     endif   
     
   
     UITEMS->(DbGotop())

     While UITEMS->(!Eof())
       
          if UITEMS->(!Deleted()) .and. ITEM->(DbSeek(UITEMS->UI_PLUCODE)) //  month(UITEMS->UI_POSTDTE) == month(date())
           UITEMS->(RecLock(0))
         //  UITEMS->UI_POSTDTE := date()   
           UITEMS->(DbUnLock())
           if  year(UITEMS->UI_POSTDTE) == year(sdate)

           @ 2, 1 wsay " UNIT: " +aUnits[1][1]+" "+aUnits[1][2]
           @ 3, 1 wsay " ITEM: " + UITEMS->UI_PLUCODE + " STK#: "+UITEMS->UI_STKCODE
           @ 4, 1 wsay " STATUS: " 
           UITEMS->(RecLock(0))
           UITEMS->UI_BEG_BAL :=  UITEMS->UI_STK_BAL 

         UITEMS->UI_ECRDSLS := 0
         UITEMS->UI_ECRDCNT := 0
         UITEMS->UI_ACCDSLS := 0
         UITEMS->UI_ACCDCNT := 0
         UITEMS->UI_ECRMSLS := 0
         UITEMS->UI_ECRMCNT := 0
         UITEMS->UI_ECRASLS := 0
         UITEMS->UI_ECRACNT := 0
//         UITEMS->UI_STK_BAL := 0

           UITEMS->UI_DSLRATE := 0     
           UITEMS->(DBUnLock())
        endif           
        endif
        // Goto Next record.
        UITEMS->(DBSkip())
        
     enddo

     UITEMS->(DBCloseArea())
        

     ITEM->(DbCloseArea())
  
   *  IV->(DbCloseArea())

   // Restore OldPath
   set(_SET_PATH,cOldPath)  
   // Remove window.
   killwindow()

return nil 


static function GetData()
local cData


      cData := ITEM->I_001      // PLU item Code 
      cData += SUBSTR(ITEM->I_033,3,12)    // Stock Code,
      cData += ITEM->I_002      // PLU Descriptor
      cData += "00"                  // Size
      cData += "00"                  // Color
      #ifdef CLASS_LINK 
         cData += right(ITEM->I_006,4)       // Class Code      
      #else
         cData += right(ITEM->I_006,4)       // Department Code
      #endif    
      #ifdef CLASS_LINK
         if CL->(DbSeek(ITEM->I_006)) 
             cData += "00"+right(CL->CL_003,2)   // Associated Department
         else
             cData += "0000"
         endif      
      #else
         cData += "00"+right(ITEM->I_006,2)
      #endif             
      cData += "0"+right(ITEM->I_020,3)          // Vendor Code
      cData += padl(alltrim(strtran(str(ITEM->I_003),".","")),10,"0") // selling price
      cData += repl("0",10) // price level 1
      cData += repl("0",10) // price level 2
      cData += repl("0",10) // price level 3
      cData += repl("0",10) // price level 4
      cData += repl("0",10) // price level 5
      cData += padl(alltrim(strtran(str(ITEM->I_007),".","")),10,"0") // unit cost
      cData += repl("0",4)  // time start
      cData += repl("0",4)  // time end
      cData += repl("0",4)  // base qty
      cData += repl("0",8)  // day of week
      cData += repl("0",4)  // discount rate
      cData += repl("0",10) // discount amount
      cData += repl("0",4)  // ssd rate
      cData += repl("0",10) // ssd amount
      cData += repl("0",10) // ad tax1
      cData += repl("0",10) // ad tax2
      cData += repl("0",16) // status bytes
      cData += repl("0",30) // reserved
      
return padr(cData,244,"0")


