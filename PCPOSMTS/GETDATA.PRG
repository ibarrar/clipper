#include "its.ch"
#include "janus.ch"
#include "inkey.ch"



memvar dEndDate,dStartDate,GETLIST

function Getdata(nVar)
local n,DbfFile,nPos
local aUnits := {}
local cOldPath := set(_SET_PATH)
local cString
local aWare := {}
local cPOS_NO,dDate,sdate := date(),vBrowse
local aVectors := {}, lrecfnd := .f.
local nOSales := 0 ,others, other := 0, odate


SET CURSOR ON
   vBrowse := OpenWindow(10,30,12,50)
   @ 10,33 say "END OF DAY SALES"
   @ 11,33 say "Date: "Get sdate
   read
   if lastkey() == K_ESC
      SET CURSOR OFF
      CloseWindow(vBrowse)
      return nil
   endif   
   SET CURSOR OFF
   CloseWindow(vBrowse)



// if GetDates()      

 // First open the Unit Branch Master 

 Message("Opening Databases...")
 // Warehouse Only
 aWare  := {"000", "*** UNIT WAREHOUSE ***", chr(65+curdrv())+":\"+curdir()+"\MTSDATA.000","" }

 Set(_SET_PATH,aWare[3])
 Use ("UITEMS") ALIAS F0 SHARED NEW
 Set Index to UITEMS          
 aWare[4] := Alias() 

 if NetUse("UNIT",DB_SHARED,NUM_SECONDS)
    Set Index to UNIT 
 endif

 UNIT->(DbGotop())
 // all other Units
  
 while UNIT->(!Eof())
     if UNIT->(!Deleted())
        aAdd(aUnits,{ UNIT->UNIT_CODE,UNIT->UNIT_NAME,UNIT->UNIT_PATH, "" } )     
     endif
     UNIT->(DbSkip())
 enddo

 UNIT->(DbCloseArea())

 // Open All unit Databases ....
 
 for n:= 1 to len(aUnits)
    Message(" Opening Database of "+aUnits[n][2])
    Set(_SET_PATH,aUnits[n][3])
    Use ("UITEMS") ALIAS &("F"+(alltrim(str(n)))) SHARED NEW
    Set Index to UITEMS        
    aUnits[n][4] := Alias()
 next

 set(_SET_PATH,cOldPath)   
 
 // But Dont Forget to Close Them Afterwards
         
 Message("Opening Sales Databases...") 
 
 // Assuming the Databases are NOT OPEN
 if NetUse("ITEM.DBF",DB_SHARED,NUM_SECONDS)
    Set Index to I_001,I_002,I_033
 endif
    

 // Get all except WAREHOUSE . Why...?
 // Because there is no selling done in the warehouse just -
 // Stock Inventory and Transfers
 for n:= 1 to len(aUnits)

       
      if NetUse("PLU",DB_SHARED,NUM_SECONDS)
        // Here is where all the data is Up-loaded
        // into their specific De`stinations

        DbfFile := Alias() 
        while (DbfFile)->(!Eof())

          if (DbfFile)->(!Deleted())

           if (DbfFile)->Date == sdate
           
            Message("Posting Item: "+(DbfFile)->CODE+" ...")                                          

                
                // This is for the UNIT BRANCHES Accumulation or Posting of Sales... 
                if (aUnits[n][4])->(DbSeek((DbfFile)->CODE)) 
                   (aUnits[n][4])->(RecLock(0))          
                   (aUnits[n][4])->UI_POSTDTE := (DBFFILE)->DATE                     

                    (aUnits[n][4])->UI_ECRDSLS += (DbfFile)->IAMOUNT
                    (aUnits[n][4])->UI_ECRDCNT += (DbfFile)->ICOUNT
                    (aUnits[n][4])->UI_OP_FLAG := 5
                    
                    (aUnits[n][4])->(DbUnLock())

                else // Append to Database all not Found
                    
                    if !ITEM->(DbSeek((DbfFile)->CODE))
                     if (DbfFile)->CODE <> "00000000000000" 
                       Message("Item Code:"+(DbfFile)->CODE+" Not Found!!! Creating...")
                       ITEM->(FilLock())
                       ITEM->(Addrec(0))
                       ITEM->I_001 := (DbfFile)->CODE
                       ITEM->I_002 := repl("?",PLU_DESC_LEN)
                       ITEM->(DbUnLock())
                      endif 
                    endif
                                                             
                    (aUnits[n][4])->(FilLock(0))
                    (aUnits[n][4])->(DbAppend(0))
                    (aUnits[n][4])->UI_PLUCODE := (DbfFile)->CODE
                    (aUnits[n][4])->UI_POSTDTE := (DBFFILE)->DATE

                    (aUnits[n][4])->UI_ECRDSLS += (DbfFile)->IAMOUNT
                    (aUnits[n][4])->UI_ECRDCNT += (DbfFile)->ICOUNT
                    
                    (aUnits[n][4])->(DbUnLock())                                      
                    
                endif // This is the checking of the existance of the PLUCODE

                (aUnits[n][4])->(DbCommit())


                // Now The WareHouse
                if (aWare[4])->(DbSeek((DbfFile)->CODE))
                    (aWare[4])->(RecLock(0))         
                    (aWare[4])->UI_POSTDTE := (DBFFILE)->DATE   

                    (aWare[4])->UI_ECRDSLS += (DbfFile)->IAMOUNT
                    (aWare[4])->UI_ECRDCNT += (DbfFile)->ICOUNT
                    (aWare[4])->UI_OP_FLAG := 5

                    (aWare[4])->(DbUnLock())                        
                    
                else   // Append Not Found PLU
                  
                    (aWare[4])->(FilLock(0))
                    (aWare[4])->(DbAppend(0))
                    (aWare[4])->UI_PLUCODE := (DbfFile)->CODE
                    (aWare[4])->UI_POSTDTE := (DBFFILE)->DATE

                    (aWare[4])->UI_ECRDSLS += (DbfFile)->IAMOUNT
                    (aWare[4])->UI_ECRDCNT += (DbfFile)->ICOUNT

                    (aWare[4])->(DbUnLock())                        
                    
                endif    
                
                (aWare[4])->(DbCommit())
                
                
                // mark for deletion 
            (DbfFile)->(RecLock()) 
            (DbfFile)->(DbDelete())                
            (DbfFile)->(DbUnlock())                                       
            lrecfnd := .t. 
          endif // date 
          
         endif // IF the Trans FIle Is Not Deleted
        (DbfFile)->(DbSkip()) 
        enddo  // Go Through All the RECORDS one by one                  
        (DbfFile)->(DbCloseArea())         

      else 
         Message("Error Locating PLU.DBF")               
      endif

next n
if !lrecfnd
   Message("No Records Found !!! Be sure data were already imported. ")                       
   tone(100,1.5)
   inkey(2)
endif



 DbCloseAll()  
 
// endif  // getdates()  

return nil

// ********************** Eof *******************


