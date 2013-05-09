// Filename:      MAINT.PRG
// Author:        Rollie C. Ibarra Jr & Arnold P. Caoile
// Module:        Database Maintenance
// Date-Started:  April 23, 1992
// Last-Update:   June 23, 1992
//            :   August 09, 1995         

#include "Inkey.ch"
#include "Setcurs.ch"
#include "Directry.ch"
#include "Error.ch"
#include "ITS.ch"
#include "Janus.ch"

#define   DEFAULT_PATH   "MTSDATA"
#define   MEMFILE        ".\BACKUP.ID"

memvar getlist, dEndDate,dStartDate

function Reindex()
local wReindex,hGauge,cAlias,n,nFileCount:=0,nPercent
local k,cExp,aDbf,i:=1,cOldPath // := set(_SET_DEFAULT,"")
local cScr
cScr:=savescreen(08,03,15,79)
restscreen(08,03,15,79,cScr)
   Message("Reindexing databases....please wait!")
   wReindex:=OpenWindow(08,03,15,76,"Reindex Databases")
   hGauge:=GaugeNew(10,05,12,74,"N/W","N/W",chr(177))
   GaugeDisplay(hGauge)
   
   if netuse("ITEM.DBF",DB_EXCLUSIVE,NUM_SECONDS)
      Set index to I_001
      ITEM->(__DbPack())
      ITEM->(DbCloseArea())
   endif
   cOldPath := set(_SET_DEFAULT,"")
   
   aDbf :=  makedbf1()

   l_mkdir ( DEFAULT_PATH )   
   l_chdir ( DEFAULT_PATH )

   for k:= 1 to len(aDbf)
     for n :=  1 to len(aDbf[k, SYS_NTX]) 
        nFileCount++
     next n   
   next k     
      
   for k:=1 to len(aDbf)
      for n:= 1 to len(aDbf[k, SYS_NTX])
         @ 13,05 clear to 14,74
         @ 13,05 say "Reindexing "+alltrim(aDbf[k, SYS_DBFNAME])+" to "+alltrim(aDbf[k, SYS_NTX][n, NTX_NAME])
         @ 14,05 say "using "+alltrim(aDbf[k, SYS_NTX][n,NTX_KEY])+"..."
            cAlias:=alltrim(aDbf[k, SYS_DBFNAME])
            cExp:=alltrim(aDbf[k, SYS_NTX][n,NTX_KEY])
            if NetUse(aDbf[k, SYS_DBFNAME],DB_SHARED,NUM_SECONDS)
                index on &(cExp) to (aDbf[k, SYS_NTX][n,NTX_NAME])
                &(cAlias)->(DbCloseArea())
	    else
	    	alert("Unable to reindex  "+cAlias+".DBF ...")
            endif
         nPercent:=i++/nFileCount
         GaugeUpdate(hGauge,nPercent)            
      next n   
   next k
   GaugeUpdate(hGauge,1)               
   @ 13,05 clear to 14,74
   @ 13,05 say Transform(nFileCount,"99")+" index file(s) reindexed."
   HEYTHERE()
   OKDONE()
   DbCloseAll()
   CloseWindow(wReindex)
   restscreen(08,03,15,79,cScr)   
   l_chdir(".." )
   set(_SET_DEFAULT,cOldPath)
return nil

function CopyFile(nMode)
local wCopy,hGauge,aDirectory,cName,n,nFileCount:=0,nTotalSize:=0,nPercent:=0
local bSaveHandler,error,wError,nKey,wDirMask,nAccumulate := 0
local cSource,cTarget,cString
local aTemp := {}
PUBLIC cDirBackup,cDirSource
   Message("Enter source & target drives, press ESC to abort.")
   if (File(MEMFILE))
      RESTORE FROM MEMFILE ADDITIVE 
      if nMode == 1
         cSource :=  cDirSource
         cTarget :=  cDirBackup
         wDirMask:=OpenWindow(09,14,13,66,"Backup Databases")         
      elseif nMode == 2  
         cTarget :=  cDirSource
         cSource :=  cDirBackup      
         wDirMask:=OpenWindow(09,14,13,66,"Restore Databases")         
      endif    
   else         
      if nMode==1
         cSource:=PADR(chr(65+curdrv())+":\"+curdir()+if(empty(curdir()),"","\")+"MTSDATA\",50)
         cTarget:=PADR("F:\MTSDATA\",50)
         wDirMask:=OpenWindow(09,14,13,66,"Backup Databases")
      elseif nMode==2
         cSource:=PADR("F:\MTSDATA\",50)
         cTarget:=PADR(chr(65+curdrv())+":\"+curdir()+if(empty(curdir()),"","\")+"MTSDATA\",50)
         wDirMask:=OpenWindow(09,14,13,66,"Restore Databases")
      endif
   endif   
   SetCursor(SC_NORMAL)
   @ 11,16 say "Source Drive/Path" get cSource picture "@!S30"
   @ 12,16 say "Target Drive/Path" get cTarget picture "@!S30"
   read
   SetCursor(SC_NONE)
   CloseWindow(wDirMask)
   if LastKey()!=K_ESC .and. !empty(cSource) .and. !empty(cTarget)  
     cSource := rtrim(cSource)
     cTarget := rTrim(cTarget)
     if(subs(cSource,len(cSource),1) != "\")
        cSource+= "\"
     endif   
     if(subs(cTarget,len(cTarget),1) != "\")
        cTarget+= "\"
     endif        
     if nMode == 1
       cDirSource := pad(cSource,50)
       cDirBackup := pad(cTarget,50)
     elseif nMode == 2  
       cDirSource := pad(cTarget,50)
       cDirBackup := pad(cSource,50)
     endif       
     SAVE TO MEMFILE ALL LIKE cDir* 
     cSource:=AllTrim(cSource) ; cTarget:=AllTrim(cTarget)
     bSaveHandler:=ErrorBlock({|x| Break(x)})
     
     aDirectory:=Directory(cSource+"*.DBF")
     aTemp := Directory(cSource+"*.NTX")

     for n := 1 to len(aTemp)
      aadd ( aDirectory,aTemp[n] )
     next
     
     aTemp := Directory(cSource+"*.DBT")

     for n := 1 to len(aTemp)
      aadd ( aDirectory,aTemp[n] )
     next     
     
     Message("Copying databases....please wait!")
     if nMode==1
        wCopy:=OpenWindow(06,03,16,76,"Backup Databases")
     elseif nMode==2
        wCopy:=OpenWindow(06,03,16,76,"Restore Databases")
     endif
     hGauge:=GaugeNew(10,05,12,74,"N/W","N/W",chr(177))
     GaugeDisplay(hGauge)
     for n:=1 to Len(aDirectory)
        nFileCount++
        cName:=aDirectory[n,F_NAME]
        @ 13,05 clear to 13,74

        if len(cTarget+cName+cName+cSource) > 66
          cString := subs(cSource,1,3) + "...\"+cName+"  " +padc("Copy to",52-(len(cName+cName)),">") +;
                     "  "+subs(cTarget,1,3)+"...\"+cName
        else
        cString := cSource+cName+"  "+padc("Copy to",66-(len(cTarget+cName+cName+cSource)),">") +"  "+;
                    cTarget+cName                    
        endif            
                    
        @ 09,05 say cString           
        @ 13,05 say "Filename: "+cName
        @ 13,29 say "Filesize: "+Transform(aDirectory[n,F_SIZE],"9,999,999")+" bytes"
        @ 13,57 say Cmonth(aDirectory[n,F_DATE])+" "+;
          Transform(Day(aDirectory[n,F_DATE]),"99")+", "+;
          Transform(Year(aDirectory[n,F_DATE]),"9999")
        nTotalSize +=  aDirectory[n,F_SIZE]  
        @ 15,05 say PADR("Total: "+Transform(nTotalSize,"99,999,999")+" bytes copied",50)                     
        do while .T.
           BEGIN SEQUENCE
              copy file &(cSource+cName) to &(cTarget+cName)
           RECOVER USING error
              if error:genCode==EG_CREATE
                 Message("Press "+chr(17)+chr(196)+chr(217)+ ;
                    " to retry, Esc to abort....")
                 Tone(100,3)
                 BUMMER()
                 wError:=OpenWindow(08,12,14,67,"Runtime Error")
                 @ 10,14 say "                      WARNING!                      "
                 @ 11,14 say "   File creation error, unable to write to disk.    "
                 @ 12,14 say "Please check drive or disk.  Drive may not be ready,"
                 @ 13,14 say "        disk maybe full or write-protected.         "
                 nKey:=0
                 do while (nKey!=K_ENTER) .and. (nKey!=K_ESC)
                    nKey:=Inkey(0)
                 enddo
                 CloseWindow(wError)
                 if nKey==K_ENTER
                    Message("Copying databases....please wait!")
                    loop
                 elseif nKey==K_ESC
                    CloseWindow(wCopy)
                    return nil
                 endif
              endif
           END
           exit
        enddo
        ErrorBlock(bSaveHandler)
        nPercent := nFileCount/len(aDirectory)
        GaugeUpdate(hGauge,nPercent)
     next
     @ 13,05 clear to 13,74
     @ 13,05 say Transform(nFileCount,"99")+" file(s) copied."
     Message("Press any key to return to Main Menu....")
     HEYTHERE()
     OKDONE()
     CloseWindow(wCopy)
   endif
return nil 


Function alis()

local nans := 0, cWindow, nChoice, cWindow1
local aSelect := {"PO", "Delivery", "Returns",;
                  "Adjusment", "Transfers"}

cwindow1:= OpenWindow( 5, 26, 12, 43,"DELETE FILES")

nChoice := Achoice(7,28,11,40,aSelect)
if LASTKEY() == K_ESC
   CloseWindow(cWindow1)
   Return nil
endif   
CloseWindow(cWindow1)

 if Getdates()
    cwindow:= OpenWindow( 19, 1, 22, 60,"FILE STATUS")

   Do Case
   
    Case nchoice == 1
      if NetUse("PO",DB_SHARED,NUM_SECONDS)
         set index to PO_001
      endif   
      if NetUse("PO_ITEMS",DB_SHARED,NUM_SECONDS)
         set index to POI_LINK
      endif   
      Do While PO->(!Eof()) .and. PO->PO_003 >= dStartDate .and. PO->PO_003 <= dEndDate  
        @ 20, 1 say " Deleting Purchase Order File.  Please wait ..."  
        @ 21, 1 say " Purchase Order No. : " + PO->PO_001
         if PO_ITEMS->(DbSeek(PO->PO_001))
            PO_ITEMS->(Reclock(0))
            PO_ITEMS->(DbDelete())
            PO_ITEMS->(DbUnlock())
         endif   
         
         PO->(Reclock(0))
         PO->(DbDelete())
         PO->(DbUnlock())
         PO->(DbSkip())
      Enddo   
      PO->(DbCloseArea())
      PO_ITEMS->(DbCloseArea())
      
      if NetUse("PO",DB_EXCLUSIVE,NUM_SECONDS)
         set index to PO_001
         PO->(__DbPack())
         PO->(DbCloseArea())
      endif   
      if NetUse("PO_ITEMS",DB_EXCLUSIVE,NUM_SECONDS)
         set index to POI_LINK
         PO_ITEMS->(__DbPack())
         PO_ITEMS->(DbCloseArea())
      endif   
      HEYTHERE() ; OKDONE()
      
   Case nchoice == 2
      if NetUse("RR",DB_SHARED,NUM_SECONDS)
         set index to RR_001
      endif   
      if NetUse("RR_ITEMS",DB_SHARED,NUM_SECONDS)
         set index to RRI_LINK
      endif   
      Do While RR->(!Eof()) .and. RR->RR_006 >= dStartDate .and. RR->RR_006 <= dEndDate  
        @ 20, 1 say " Deleting Stock Delivery File.  Please wait ..."  
        @ 21, 1 say " Stock Delivery No. : " + RR->RR_001
         if RR_ITEMS->(DbSeek(RR->RR_001))
            RR_ITEMS->(Reclock(0))
            RR_ITEMS->(DbDelete())
            RR_ITEMS->(DbUnlock())
         endif   
         RR->(Reclock(0))
         RR->(DbDelete())
         RR->(DbUnlock())
         RR->(DbSkip())
      Enddo   
      RR->(DbCloseArea())
      RR_ITEMS->(DbCloseArea())
      
      if NetUse("RR",DB_EXCLUSIVE,NUM_SECONDS)
         set index to RR_001
         RR->(__DbPack())
         RR->(DbCloseArea())
      endif   
      if NetUse("RR_ITEMS",DB_EXCLUSIVE,NUM_SECONDS)
         set index to RRI_LINK
         RR_ITEMS->(__DbPack())
         RR_ITEMS->(DbCloseArea())
      endif         

   Case nchoice == 3
      if NetUse("RJ",DB_SHARED,NUM_SECONDS)
         set index to RJ_001
      endif   
      if NetUse("RJ_ITEMS",DB_SHARED,NUM_SECONDS)
         set index to RJI_LINK
      endif   
      Do While RJ->(!Eof()) .and. RJ->RJ_006 >= dStartDate .and. RJ->RJ_006 <= dEndDate  
        @ 20, 1 say " Deleting Stock Return File.  Please wait ..."  
        @ 21, 1 say " Stock Return No. : " + RJ->RJ_001
         if RJ_ITEMS->(DbSeek(RJ->RJ_001))
            RJ_ITEMS->(Reclock(0))
            RJ_ITEMS->(DbDelete())
            RJ_ITEMS->(DbUnlock())

         endif   

         RJ->(Reclock(0))
         RJ->(DbDelete())
         RJ->(DbUnlock())         
         RJ->(DbSkip())
      Enddo   
      RJ->(DbCloseArea())
      RJ_ITEMS->(DbCloseArea())
      
      if NetUse("RJ",DB_EXCLUSIVE,NUM_SECONDS)
         set index to RJ_001
         RJ->(__DbPack())
         RJ->(DbCloseArea())
      endif   
      if NetUse("RJ_ITEMS",DB_EXCLUSIVE,NUM_SECONDS)
         set index to RJI_LINK
         RJ_ITEMS->(__DbPack())
         RJ_ITEMS->(DbCloseArea())
      endif

   Case nchoice == 4
      if NetUse("SA",DB_SHARED,NUM_SECONDS)
         set index to SA_001
      endif   
      if NetUse("SA_ITEMS",DB_SHARED,NUM_SECONDS)
         set index to SAI_LINK
      endif   
      Do While SA->(!Eof()) .and. SA->SA_002 >= dStartDate .and. SA->SA_002 <= dEndDate  
        @ 20, 1 say " Deleting Stock Adjustment File.  Please wait ..."  
        @ 21, 1 say " Stock Adjustment No : " + SA->SA_001
         if SA_ITEMS->(DbSeek(SA->SA_001))
            SA_ITEMS->(Reclock(0))
            SA_ITEMS->(DbDelete())
            SA_ITEMS->(DbUnlock())

         endif   

         SA->(Reclock(0))
         SA->(DbDelete())
         SA->(DbUnlock())         
         SA->(DbSkip())
      Enddo   
      SA->(DbCloseArea())
      SA_ITEMS->(DbCloseArea())
      
      if NetUse("SA",DB_EXCLUSIVE,NUM_SECONDS)
         set index to SA_001
         SA->(__DbPack())
         SA->(DbCloseArea())
      endif   
      if NetUse("SA_ITEMS",DB_EXCLUSIVE,NUM_SECONDS)
         set index to SAI_LINK
         SA_ITEMS->(__DbPack())
         SA_ITEMS->(DbCloseArea())
      endif     

   Case nchoice == 5
      if NetUse("ST",DB_SHARED,NUM_SECONDS)
         set index to ST_001
      endif   
      if NetUse("ST_ITEMS",DB_SHARED,NUM_SECONDS)
         set index to STI_LINK
      endif   
      Do While ST->(!Eof()) .and. ST->ST_004 >= dStartDate .and. ST->ST_004 <= dEndDate  
        @ 20, 1 say " Deleting Stock Transfer File.  Please wait ..."  
        @ 21, 1 say " Stock Transfer No. : " + ST->ST_001
         if ST_ITEMS->(DbSeek(ST->ST_001))
            ST_ITEMS->(Reclock(0))
            ST_ITEMS->(DbDelete())
            ST_ITEMS->(DbUnlock())

         endif   

         ST->(Reclock(0))
         ST->(DbDelete())
         ST->(DbUnlock())         
         ST->(DbSkip())
      Enddo   
      ST->(DbCloseArea())
      ST_ITEMS->(DbCloseArea())
      
      if NetUse("ST",DB_EXCLUSIVE,NUM_SECONDS)
         set index to ST_001
         ST->(__DbPack())
         ST->(DbCloseArea())
      endif   
      if NetUse("ST_ITEMS",DB_EXCLUSIVE,NUM_SECONDS)
         set index to STI_LINK
         ST_ITEMS->(__DbPack())
         ST_ITEMS->(DbCloseArea())
      endif                               
      
   Endcase    
   
  CloseWindow(cWindow)
 Endif  

Return nil 


function Reset()
local wlinks,hGauge, nRecCount := 0, nPercent, nCtr := 1

if alert(" Transaction Reset will erase;"+; 
    " all records on TRANITEM.DBF !..;"+;
    " Proceed ?", {" Proceed "," Cancel "}) == 1   

  if netuse("TRANITEM", DB_EXCLUSIVE, NUM_SECONDS)
    set index to TRANITEM
  endif
  if netuse("BAKUPITM", DB_EXCLUSIVE, NUM_SECONDS)
   //  set index to BAKUPITM
  endif

    nRecCount := TRANITEM->(LastRec())

   Message("Backing up Transaction file ....please wait!")
   wLinks:=OpenWindow(08,03,15,76,"Back-Up File(Tranitem.Dbf)") 
   hGauge:=GaugeNew(10,05,12,74,"N/W","N/W",chr(177))
   GaugeDisplay(hGauge)
   @ 13, 05 say "Item Count  : "
   @ 14, 05 say "Output File : 'BAKUPITM.DBF'" 
  
  DO WHILE TRANITEM->(!EOF())
   BAKUPITM->(DbAppend())
   BAKUPITM->(RecLock(0))
      BAKUPITM->POS_NO     := TRANITEM->POS_NO
      BAKUPITM->DATE       := TRANITEM->DATE
      BAKUPITM->TIME       := TRANITEM->TIME
      BAKUPITM->TRANS_NO    := TRANITEM->TRANS_NO
      BAKUPITM->RESERVD1   := TRANITEM->RESERVD1
      BAKUPITM->TRANS_FLAG := TRANITEM->TRANS_FLAG
      BAKUPITM->CASH_CODE  := TRANITEM->CASH_CODE
      BAKUPITM->CLERK_CODE := TRANITEM->CLERK_CODE
      BAKUPITM->REG_METHOD := TRANITEM->REG_METHOD
      BAKUPITM->PR_METHOD  := TRANITEM->PR_METHOD
      BAKUPITM->RESERVD2   := TRANITEM->RESERVD2
      BAKUPITM->PLU_CODE   := TRANITEM->PLU_CODE
      BAKUPITM->ITEM_CODE  := TRANITEM->ITEM_CODE
      BAKUPITM->DEPT_CODE  := TRANITEM->DEPT_CODE
      BAKUPITM->CONC_CODE  := TRANITEM->CONC_CODE
      BAKUPITM->COLOR      := TRANITEM->COLOR
      BAKUPITM->SIZE       := TRANITEM->SIZE
      BAKUPITM->SLS_AMOUNT := TRANITEM->SLS_AMOUNT
      BAKUPITM->QUANTITY   := TRANITEM->QUANTITY
      BAKUPITM->PAY_TYPE   := TRANITEM->PAY_TYPE
      BAKUPITM->ORDER_NO   := TRANITEM->ORDER_NO
      BAKUPITM->RESERVD3   := TRANITEM->RESERVD3
      BAKUPITM->CARGO1     := TRANITEM->CARGO1
      BAKUPITM->CARGO2     := TRANITEM->CARGO2
      BAKUPITM->CARGO3     := TRANITEM->CARGO3
   BAKUPITM->(DbUnLock())   

   @ 13,19 say alltrim(str(nCtr)) + space(5)    
     nPercent:=nCtr++/nRecCount
     GaugeUpdate(hGauge,nPercent)
   
   TRANITEM->(DbSkip())
   
  enddo        
  BAKUPITM->(DbCloseArea())
  TRANITEM->(DbCloseArea())
  CloseWindow(wLinks)
  
  if netuse("TRANITEM", DB_EXCLUSIVE, NUM_SECONDS)
    set index to TRANITEM
    message("Resetting file 'TRANITEM.DBF' ...")
    TRANITEM->(__dbZap())
    TRANITEM->(dbCloseArea())
    HEYTHERE()
    inkey(1)
  else
    BUMMER()
    alert("File 'TRANITEM.DBF' cannot be opened Exclusively !", {"Return"})
  endif
  

  message("DONE !")
  inkey(1)
endif  

return nil

// end-of-file