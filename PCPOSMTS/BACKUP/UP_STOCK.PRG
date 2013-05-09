#include "Inkey.ch"
#include "Setcurs.ch"
#include "Directry.ch"
#include "Error.ch"
#include "ITS.ch"
#include "Janus.ch"

#define UP_PATH  chr(65+curdrv())+":\"+curdir()+"\UPLOAD\"   

function up_stocks()

local wReindex,hGauge,cAlias,n,i:=0,nFileCount:=0,nPercent
local adir := {}, aUnits := {}, y := 0, ui_down, dbffile
local dbffile1

/*============================= P.O. =====================================*/

if !file((UP_PATH)+"PO_DOWN.DBF")
   return nil      
endif 


if NetUse("PO_ITEMS",DB_SHARED,NUM_SECONDS)
   set index to POI_LINK
endif   
if NetUse("PO",DB_SHARED,NUM_SECONDS)
      set index to PO_001
endif   
if NetUse((UP_PATH)+"PO_DOWN",DB_SHARED,NUM_SECONDS)
   dbffile := alias()
endif   
if NetUse((UP_PATH)+"POITEMS_DOWN",DB_SHARED,NUM_SECONDS)
   dbffile1 := alias()
   INDEX ON (DBFFILE1)->POI_LINK TO POIDOWN
endif   

Message("Uploading I.P. Files....please wait!")
wReindex:=OpenWindow(08,03,15,76,"UPLOAD")
hGauge:=GaugeNew(10,05,12,74,"N/W","N/W",chr(177))
GaugeDisplay(hGauge)
i := 0

(DBFFILE)->(DbGoTop())
Do while (DBFFILE)->(!Eof())
   nPercent:=i++/100
   GaugeUpdate(hGauge,nPercent)            
   DO CASE
      CASE (DBFFILE)->PO_018 == 1

//jzo04-07-98
       if !PO->(Dbseek((DBFFILE)->PO_001))

         PO->(FilLock(0))
         PO->(DbAppend())
         PO->PO_001 := (DBFFILE)->PO_001
         PO->PO_002 := (DBFFILE)->PO_002
         PO->PO_003 := (DBFFILE)->PO_003
         PO->PO_004 := (DBFFILE)->PO_004
         PO->PO_005 := (DBFFILE)->PO_005
         PO->PO_006 := (DBFFILE)->PO_006
         PO->PO_007 := (DBFFILE)->PO_007
         PO->PO_008 := (DBFFILE)->PO_008
         PO->PO_009 := (DBFFILE)->PO_009
         PO->PO_010 := (DBFFILE)->PO_010
         PO->PO_011 := (DBFFILE)->PO_011
         PO->PO_012 := (DBFFILE)->PO_012
         PO->PO_013 := (DBFFILE)->PO_013
         PO->PO_014 := (DBFFILE)->PO_014
         PO->PO_015 := (DBFFILE)->PO_015
         PO->PO_016 := (DBFFILE)->PO_016
         PO->PO_017 := (DBFFILE)->PO_017
         PO->(DbUnLock())
         (DBFFILE)->(Reclock(0))
         (DBFFILE)->PO_018 := 0
         (DBFFILE)->(DbUnlock())
         if (DBFFILE1)->(Dbseek((DBFFILE)->PO_001))
            Do While (DBFFILE1)->(!Eof()) .and. (DBFFILE1)->POI_LINK == (DBFFILE)->PO_001
               PO_ITEMS->(FilLock(0))
               PO_ITEMS->(DbAppend())
               PO_ITEMS->POI_LINK := (DBFFILE1)->POI_LINK
               PO_ITEMS->POI_ITEM := (DBFFILE1)->POI_ITEM
               PO_ITEMS->POI_DESC := (DBFFILE1)->POI_DESC
               PO_ITEMS->POI_COST := (DBFFILE1)->POI_COST
               PO_ITEMS->POI_QORD := (DBFFILE1)->POI_QORD
               PO_ITEMS->POI_UM := (DBFFILE1)->POI_UM
               PO_ITEMS->POI_URET := (DBFFILE1)->POI_URET
               PO_ITEMS->POI_QREC := (DBFFILE1)->POI_QREC
               PO_ITEMS->POI_QRET := (DBFFILE1)->POI_QRET
               PO_ITEMS->POI_POST := (DBFFILE1)->POI_POST
               PO_ITEMS->(DbUnLock())
               (DBFFILE1)->(DbSkip())
            enddo
         endif   
       endif  
      CASE (DBFFILE)->PO_018 == 2 .OR. (DBFFILE)->PO_018 == 5
         IF DBSEEK(((DBFFILE)->PO_001))
            PO->(RecLock(0))
            PO->PO_001 := (DBFFILE)->PO_001
            PO->PO_002 := (DBFFILE)->PO_002
            PO->PO_003 := (DBFFILE)->PO_003
            PO->PO_004 := (DBFFILE)->PO_004
            PO->PO_005 := (DBFFILE)->PO_005
            PO->PO_006 := (DBFFILE)->PO_006
            PO->PO_007 := (DBFFILE)->PO_007
            PO->PO_008 := (DBFFILE)->PO_008
            PO->PO_009 := (DBFFILE)->PO_009
            PO->PO_010 := (DBFFILE)->PO_010
            PO->PO_011 := (DBFFILE)->PO_011
            PO->PO_012 := (DBFFILE)->PO_012
            PO->PO_013 := (DBFFILE)->PO_013
            PO->PO_014 := (DBFFILE)->PO_014
            PO->PO_015 := (DBFFILE)->PO_015
            PO->PO_016 := (DBFFILE)->PO_016
            PO->PO_017 := (DBFFILE)->PO_017
            PO->(DbUnLock())
            (DBFFILE)->(Reclock(0))
            (DBFFILE)->PO_018 := 0
            (DBFFILE)->(DbUnlock())
            if (DBFFILE1)->(Dbseek((DBFFILE)->PO_001))
               Do While (DBFFILE1)->(!Eof()) .and. (DBFFILE1)->POI_LINK == (DBFFILE)->PO_001
                  PO_ITEMS->(RecLock(0))
                  PO_ITEMS->POI_LINK := (DBFFILE1)->POI_LINK
                  PO_ITEMS->POI_ITEM := (DBFFILE1)->POI_ITEM
                  PO_ITEMS->POI_DESC := (DBFFILE1)->POI_DESC
                  PO_ITEMS->POI_COST := (DBFFILE1)->POI_COST
                  PO_ITEMS->POI_QORD := (DBFFILE1)->POI_QORD
                  PO_ITEMS->POI_UM := (DBFFILE1)->POI_UM
                  PO_ITEMS->POI_URET := (DBFFILE1)->POI_URET
                  PO_ITEMS->POI_QREC := (DBFFILE1)->POI_QREC
                  PO_ITEMS->POI_QRET := (DBFFILE1)->POI_QRET
                  PO_ITEMS->POI_POST := (DBFFILE1)->POI_POST
                  PO_ITEMS->(DbUnLock())
                  (DBFFILE1)->(DbSkip())
               enddo
            endif      
          ELSE
            PO->(FilLock(0))
            PO->(DbAppend())
            PO->PO_001 := (DBFFILE)->PO_001
            PO->PO_002 := (DBFFILE)->PO_002
            PO->PO_003 := (DBFFILE)->PO_003
            PO->PO_004 := (DBFFILE)->PO_004
            PO->PO_005 := (DBFFILE)->PO_005
            PO->PO_006 := (DBFFILE)->PO_006
            PO->PO_007 := (DBFFILE)->PO_007
            PO->PO_008 := (DBFFILE)->PO_008
            PO->PO_009 := (DBFFILE)->PO_009
            PO->PO_010 := (DBFFILE)->PO_010
            PO->PO_011 := (DBFFILE)->PO_011
            PO->PO_012 := (DBFFILE)->PO_012
            PO->PO_013 := (DBFFILE)->PO_013
            PO->PO_014 := (DBFFILE)->PO_014
            PO->PO_015 := (DBFFILE)->PO_015
            PO->PO_016 := (DBFFILE)->PO_016
            PO->PO_017 := (DBFFILE)->PO_017
            PO->(DbUnLock())
            (DBFFILE)->(Reclock(0))
            (DBFFILE)->PO_018 := 0
            (DBFFILE)->(DbUnlock())
            if (DBFFILE1)->(Dbseek((DBFFILE)->PO_001))
               Do While (DBFFILE1)->(!Eof()) .and. (DBFFILE1)->POI_LINK == (DBFFILE)->PO_001
                  PO_ITEMS->(FilLock(0))
                  PO_ITEMS->(DbAppend())
                  PO_ITEMS->POI_LINK := (DBFFILE1)->POI_LINK
                  PO_ITEMS->POI_ITEM := (DBFFILE1)->POI_ITEM
                  PO_ITEMS->POI_DESC := (DBFFILE1)->POI_DESC
                  PO_ITEMS->POI_COST := (DBFFILE1)->POI_COST
                  PO_ITEMS->POI_QORD := (DBFFILE1)->POI_QORD
                  PO_ITEMS->POI_UM := (DBFFILE1)->POI_UM
                  PO_ITEMS->POI_URET := (DBFFILE1)->POI_URET
                  PO_ITEMS->POI_QREC := (DBFFILE1)->POI_QREC
                  PO_ITEMS->POI_QRET := (DBFFILE1)->POI_QRET
                  PO_ITEMS->POI_POST := (DBFFILE1)->POI_POST
                  PO_ITEMS->(DbUnLock())
                  (DBFFILE1)->(DbSkip())
               enddo
            endif      
          ENDIF   
       CASE (DBFFILE)->PO_018 == 3
         IF DBSEEK(((DBFFILE)->PO_001))
            PO->(RecLock(0))
            PO->(DbDelete())
            PO->(DbUnLock())
            (DBFFILE)->(Reclock(0))
            (DBFFILE)->PO_018 := 0
            (DBFFILE)->(DbUnlock())
            if (DBFFILE1)->(Dbseek((DBFFILE)->PO_001))
               Do While (DBFFILE1)->(!Eof()) .and. (DBFFILE1)->POI_LINK == (DBFFILE)->PO_001
                  PO_ITEMS->(RecLock(0))
                  PO_ITEMS->(DbDelete())
                  PO_ITEMS->(DbUnLock())
                  (DBFFILE1)->(DbSkip())
               enddo
            endif      
          ENDIF
        CASE (DBFFILE)->PO_018 == 4
         IF DBSEEK(((DBFFILE)->PO_001))
            PO->(RecLock(0))
            PO->(DbRecall())
            PO->(DbUnLock())
            (DBFFILE)->(Reclock(0))
            (DBFFILE)->PO_018 := 0
            (DBFFILE)->(DbUnlock())
            if (DBFFILE1)->(Dbseek((DBFFILE)->PO_001))
               Do While (DBFFILE1)->(!Eof()) .and. (DBFFILE1)->POI_LINK == (DBFFILE)->PO_001
                  PO_ITEMS->(RecLock(0))
                  PO_ITEMS->(DbRecall())
                  PO_ITEMS->(DbUnLock())
                  (DBFFILE1)->(DbSkip())
               enddo
            endif      
          ELSE
            PO->(FilLock(0))
            PO->(DbAppend())
            PO->PO_001 := (DBFFILE)->PO_001
            PO->PO_002 := (DBFFILE)->PO_002
            PO->PO_003 := (DBFFILE)->PO_003
            PO->PO_004 := (DBFFILE)->PO_004
            PO->PO_005 := (DBFFILE)->PO_005
            PO->PO_006 := (DBFFILE)->PO_006
            PO->PO_007 := (DBFFILE)->PO_007
            PO->PO_008 := (DBFFILE)->PO_008
            PO->PO_009 := (DBFFILE)->PO_009
            PO->PO_010 := (DBFFILE)->PO_010
            PO->PO_011 := (DBFFILE)->PO_011
            PO->PO_012 := (DBFFILE)->PO_012
            PO->PO_013 := (DBFFILE)->PO_013
            PO->PO_014 := (DBFFILE)->PO_014
            PO->PO_015 := (DBFFILE)->PO_015
            PO->PO_016 := (DBFFILE)->PO_016
            PO->PO_017 := (DBFFILE)->PO_017
            PO->(DbUnLock())
            (DBFFILE)->(Reclock(0))
            (DBFFILE)->PO_018 := 0
            (DBFFILE)->(DbUnlock())
            if (DBFFILE1)->(Dbseek((DBFFILE)->PO_001))
               Do While (DBFFILE1)->(!Eof()) .and. (DBFFILE1)->POI_LINK == (DBFFILE)->PO_001
                  PO_ITEMS->(FilLock(0))
                  PO_ITEMS->(DbAppend())
                  PO_ITEMS->POI_LINK := (DBFFILE1)->POI_LINK
                  PO_ITEMS->POI_ITEM := (DBFFILE1)->POI_ITEM
                  PO_ITEMS->POI_DESC := (DBFFILE1)->POI_DESC
                  PO_ITEMS->POI_COST := (DBFFILE1)->POI_COST
                  PO_ITEMS->POI_QORD := (DBFFILE1)->POI_QORD
                  PO_ITEMS->POI_UM := (DBFFILE1)->POI_UM
                  PO_ITEMS->POI_URET := (DBFFILE1)->POI_URET
                  PO_ITEMS->POI_QREC := (DBFFILE1)->POI_QREC
                  PO_ITEMS->POI_QRET := (DBFFILE1)->POI_QRET
                  PO_ITEMS->POI_POST := (DBFFILE1)->POI_POST
                  PO_ITEMS->(DbUnLock())
                  (DBFFILE1)->(DbSkip())
               enddo
            endif      
         ENDIF     
    ENDCASE
      
   (DBFFILE)->(DbSkip())
enddo
GaugeUpdate(hGauge,1)               
@ 13,05 clear to 14,74
@ 13,05 say " Uploading of I.P. files FINISHED."
HEYTHERE()
OKDONE()
CloseWindow(wReindex)
DbCloseAll()



/*============================= DELIVERY =====================================*/

if !file((UP_PATH)+"RR_DOWN.DBF")
   return nil
endif 


if NetUse("RR_ITEMS",DB_SHARED,NUM_SECONDS)
   set index to RRI_LINK
endif   
if NetUse("RR",DB_SHARED,NUM_SECONDS)
      set index to RR_001
endif   
if NetUse((UP_PATH)+"RR_DOWN",DB_SHARED,NUM_SECONDS)
   DBFFILE := ALIAS()
endif   
if NetUse((UP_PATH)+"RRITEMS_DOWN",DB_SHARED,NUM_SECONDS)
   DBFFILE1 := ALIAS()
   INDEX ON (DBFFILE1)->RRI_LINK TO RRIDOWN
endif   

Message("Uploading delivery File....please wait!")
wReindex:=OpenWindow(08,03,15,76,"UPLOAD")
hGauge:=GaugeNew(10,05,12,74,"N/W","N/W",chr(177))
GaugeDisplay(hGauge)
i := 0

(DBFFILE)->(DbGoTop())
Do while (DBFFILE)->(!Eof())
   nPercent:=i++/100
   GaugeUpdate(hGauge,nPercent)             
   DO CASE
      CASE (DBFFILE)->RR_013 == 1
         RR->(FilLock(0))
         RR->(DbAppend())
         RR->RR_001 := (DBFFILE)->RR_001
         RR->RR_002 := (DBFFILE)->RR_002
         RR->RR_003 := (DBFFILE)->RR_003
         RR->RR_004 := (DBFFILE)->RR_004
         RR->RR_005 := (DBFFILE)->RR_005
         RR->RR_006 := (DBFFILE)->RR_006
         RR->RR_007 := (DBFFILE)->RR_007
         RR->RR_008 := (DBFFILE)->RR_008
         RR->RR_009 := (DBFFILE)->RR_009
         RR->RR_010 := (DBFFILE)->RR_010
         RR->RR_011 := (DBFFILE)->RR_011
         RR->RR_012 := (DBFFILE)->RR_012
         RR->(DbUnLock())
         (DBFFILE)->(Reclock(0))
         (DBFFILE)->RR_013 := 0
         (DBFFILE)->(DbUnlock())
         if (DBFFILE1)->(Dbseek((DBFFILE)->RR_001))
            Do While (DBFFILE1)->(!Eof()) .and. (DBFFILE1)->RRI_LINK == (DBFFILE)->RR_001
               RR_ITEMS->(FilLock(0))
               RR_ITEMS->(DbAppend())
               RR_ITEMS->RRI_LINK := (DBFFILE1)->RRI_LINK
               RR_ITEMS->RRI_ITEM := (DBFFILE1)->RRI_ITEM
               RR_ITEMS->RRI_COST := (DBFFILE1)->RRI_COST
               RR_ITEMS->RRI_URET := (DBFFILE1)->RRI_URET
               RR_ITEMS->RRI_QREC := (DBFFILE1)->RRI_QREC
               RR_ITEMS->RRI_POST := (DBFFILE1)->RRI_POST
               RR_ITEMS->RRI_AGEC := (DBFFILE1)->RRI_AGEC
               RR_ITEMS->RRI_SOLD := (DBFFILE1)->RRI_SOLD
               RR_ITEMS->(DbUnLock())
               (DBFFILE1)->(DbSkip())
            enddo
         endif   
      CASE (DBFFILE)->RR_013 == 2 .OR. (DBFFILE)->RR_013 == 5
         IF RR->(DBSEEK((DBFFILE)->RR_001))
            RR->(RecLock(0))
            RR->RR_001 := (DBFFILE)->RR_001
            RR->RR_002 := (DBFFILE)->RR_002
            RR->RR_003 := (DBFFILE)->RR_003
            RR->RR_004 := (DBFFILE)->RR_004
            RR->RR_005 := (DBFFILE)->RR_005
            RR->RR_006 := (DBFFILE)->RR_006
            RR->RR_007 := (DBFFILE)->RR_007
            RR->RR_008 := (DBFFILE)->RR_008
            RR->RR_009 := (DBFFILE)->RR_009
            RR->RR_010 := (DBFFILE)->RR_010
            RR->RR_011 := (DBFFILE)->RR_011
            RR->RR_012 := (DBFFILE)->RR_012
            RR->(DbUnLock())
            (DBFFILE)->(Reclock(0))
            (DBFFILE)->RR_013 := 0
            (DBFFILE)->(DbUnlock())
            if (DBFFILE1)->(Dbseek((DBFFILE)->RR_001))
               Do While (DBFFILE1)->(!Eof()) .and. (DBFFILE1)->RRI_LINK == (DBFFILE)->RR_001
                  RR_ITEMS->(RecLock(0))
                  RR_ITEMS->RRI_LINK := (DBFFILE1)->RRI_LINK
                  RR_ITEMS->RRI_ITEM := (DBFFILE1)->RRI_ITEM
                  RR_ITEMS->RRI_COST := (DBFFILE1)->RRI_COST
                  RR_ITEMS->RRI_URET := (DBFFILE1)->RRI_URET
                  RR_ITEMS->RRI_QREC := (DBFFILE1)->RRI_QREC
                  RR_ITEMS->RRI_POST := (DBFFILE1)->RRI_POST
                  RR_ITEMS->RRI_AGEC := (DBFFILE1)->RRI_AGEC
                  RR_ITEMS->RRI_SOLD := (DBFFILE1)->RRI_SOLD
                  RR_ITEMS->(DbUnLock())
                  (DBFFILE1)->(DbSkip())
               enddo
            endif            
         ELSE
            RR->(FilLock(0))
            RR->(DbAppend())
            RR->RR_001 := (DBFFILE)->RR_001
            RR->RR_002 := (DBFFILE)->RR_002
            RR->RR_003 := (DBFFILE)->RR_003
            RR->RR_004 := (DBFFILE)->RR_004
            RR->RR_005 := (DBFFILE)->RR_005
            RR->RR_006 := (DBFFILE)->RR_006
            RR->RR_007 := (DBFFILE)->RR_007
            RR->RR_008 := (DBFFILE)->RR_008
            RR->RR_009 := (DBFFILE)->RR_009
            RR->RR_010 := (DBFFILE)->RR_010
            RR->RR_011 := (DBFFILE)->RR_011
            RR->RR_012 := (DBFFILE)->RR_012
            RR->(DbUnLock())
            (DBFFILE)->(Reclock(0))
            (DBFFILE)->RR_013 := 0
            (DBFFILE)->(DbUnlock())
            if (DBFFILE1)->(Dbseek((DBFFILE)->RR_001))
               Do While (DBFFILE1)->(!Eof()) .and. (DBFFILE1)->RRI_LINK == (DBFFILE)->RR_001
                  RR_ITEMS->(FilLock(0))
                  RR_ITEMS->(DbAppend())
                  RR_ITEMS->RRI_LINK := (DBFFILE1)->RRI_LINK
                  RR_ITEMS->RRI_ITEM := (DBFFILE1)->RRI_ITEM
                  RR_ITEMS->RRI_COST := (DBFFILE1)->RRI_COST
                  RR_ITEMS->RRI_URET := (DBFFILE1)->RRI_URET
                  RR_ITEMS->RRI_QREC := (DBFFILE1)->RRI_QREC
                  RR_ITEMS->RRI_POST := (DBFFILE1)->RRI_POST
                  RR_ITEMS->RRI_AGEC := (DBFFILE1)->RRI_AGEC
                  RR_ITEMS->RRI_SOLD := (DBFFILE1)->RRI_SOLD
                  RR_ITEMS->(DbUnLock())
                  (DBFFILE1)->(DbSkip())
               enddo
            endif            
         ENDIF   
      CASE (DBFFILE)->RR_013 == 3
         IF RR->(DBSEEK((DBFFILE)->RR_001))
            RR->(RecLock(0))
            RR->(DbDelete())
            RR->(DbUnLock())
            (DBFFILE)->(Reclock(0))
            (DBFFILE)->RR_013 := 0
            (DBFFILE)->(DbUnlock())
            if (DBFFILE1)->(Dbseek((DBFFILE)->RR_001))
               Do While (DBFFILE1)->(!Eof()) .and. (DBFFILE1)->RRI_LINK == (DBFFILE)->RR_001
                  RR_ITEMS->(RecLock(0))
                  RR_ITEMS->(DbDelete())
                  RR_ITEMS->(DbUnLock())
                  (DBFFILE1)->(DbSkip())
               enddo
            endif   
         ENDIF      
       CASE (DBFFILE)->RR_013 == 4
         IF RR->(DBSEEK((DBFFILE)->RR_001))
            RR->(RecLock(0))
            RR->(DbRecall())
            RR->(DbUnLock())
            (DBFFILE)->(Reclock(0))
            (DBFFILE)->RR_013 := 0
            (DBFFILE)->(DbUnlock())
            if (DBFFILE1)->(Dbseek((DBFFILE)->RR_001))
               Do While (DBFFILE1)->(!Eof()) .and. (DBFFILE1)->RRI_LINK == (DBFFILE)->RR_001
                  RR_ITEMS->(RecLock(0))
                  RR_ITEMS->(DbRecall())
                  RR_ITEMS->(DbUnLock())
                  (DBFFILE1)->(DbSkip())
               enddo
            endif            
         ELSE
            RR->(FilLock(0))
            RR->(DbAppend())
            RR->RR_001 := (DBFFILE)->RR_001
            RR->RR_002 := (DBFFILE)->RR_002
            RR->RR_003 := (DBFFILE)->RR_003
            RR->RR_004 := (DBFFILE)->RR_004
            RR->RR_005 := (DBFFILE)->RR_005
            RR->RR_006 := (DBFFILE)->RR_006
            RR->RR_007 := (DBFFILE)->RR_007
            RR->RR_008 := (DBFFILE)->RR_008
            RR->RR_009 := (DBFFILE)->RR_009
            RR->RR_010 := (DBFFILE)->RR_010
            RR->RR_011 := (DBFFILE)->RR_011
            RR->RR_012 := (DBFFILE)->RR_012
            RR->(DbUnLock())
            (DBFFILE)->(Reclock(0))
            (DBFFILE)->RR_013 := 0
            (DBFFILE)->(DbUnlock())
            if (DBFFILE1)->(Dbseek((DBFFILE)->RR_001))
               Do While (DBFFILE1)->(!Eof()) .and. (DBFFILE1)->RRI_LINK == (DBFFILE)->RR_001
                  RR_ITEMS->(FilLock(0))
                  RR_ITEMS->(DbAppend())
                  RR_ITEMS->RRI_LINK := (DBFFILE1)->RRI_LINK
                  RR_ITEMS->RRI_ITEM := (DBFFILE1)->RRI_ITEM
                  RR_ITEMS->RRI_COST := (DBFFILE1)->RRI_COST
                  RR_ITEMS->RRI_URET := (DBFFILE1)->RRI_URET
                  RR_ITEMS->RRI_QREC := (DBFFILE1)->RRI_QREC
                  RR_ITEMS->RRI_POST := (DBFFILE1)->RRI_POST
                  RR_ITEMS->RRI_AGEC := (DBFFILE1)->RRI_AGEC
                  RR_ITEMS->RRI_SOLD := (DBFFILE1)->RRI_SOLD
                  RR_ITEMS->(DbUnLock())
                  (DBFFILE1)->(DbSkip())
               enddo
            endif            
         ENDIF            
   ENDCASE  
   (DBFFILE)->(DbSkip())
enddo
GaugeUpdate(hGauge,1)               
@ 13,05 clear to 14,74
@ 13,05 say " Uploading of Delivery file FINISHED."
HEYTHERE()
OKDONE()
CloseWindow(wReindex)
DbCloseAll()


/*============================= RETURNS =====================================*/

if !file((UP_PATH)+"RJ_DOWN.DBF")
   return nil
endif 


if NetUse("RJ_ITEMS",DB_SHARED,NUM_SECONDS)
   set index to RJI_LINK
endif   
if NetUse("RJ",DB_SHARED,NUM_SECONDS)
      set index to RJ_001
endif   
if NetUse((UP_PATH)+"RJ_DOWN",DB_SHARED,NUM_SECONDS)
   dbffile := alias()
endif   
if NetUse((UP_PATH)+"RJITEMS_DOWN",DB_SHARED,NUM_SECONDS)
   dbffile1 := alias()
   INDEX ON (DBFFILE1)->RJI_LINK TO RJIDOWN
endif   

Message("Uploading RETURN File....please wait!")
wReindex:=OpenWindow(08,03,15,76,"UPLOAD")
hGauge:=GaugeNew(10,05,12,74,"N/W","N/W",chr(177))
GaugeDisplay(hGauge)
i := 0

(DBFFILE)->(DbGoTop())
Do while (DBFFILE)->(!Eof())
   nPercent:=i++/100
   GaugeUpdate(hGauge,nPercent)            
   DO CASE
      CASE (DBFFILE)->RJ_012 == 1
         RJ->(FilLock(0))
         RJ->(DbAppend())
         RJ->RJ_001 := (DBFFILE)->RJ_001
         RJ->RJ_002 := (DBFFILE)->RJ_002
         RJ->RJ_003 := (DBFFILE)->RJ_003
         RJ->RJ_004 := (DBFFILE)->RJ_004
         RJ->RJ_005 := (DBFFILE)->RJ_005
         RJ->RJ_006 := (DBFFILE)->RJ_006
         RJ->RJ_007 := (DBFFILE)->RJ_007
         RJ->RJ_008 := (DBFFILE)->RJ_008
         RJ->RJ_009 := (DBFFILE)->RJ_009
         RJ->RJ_010 := (DBFFILE)->RJ_010
         RJ->RJ_011 := (DBFFILE)->RJ_011
         RJ->(DbUnLock())
         (DBFFILE)->(Reclock(0))
         (DBFFILE)->RJ_012 := 0
         (DBFFILE)->(DbUnlock())
         if (DBFFILE1)->(Dbseek((DBFFILE)->RJ_001))
            Do While (DBFFILE1)->(!Eof()) .and. (DBFFILE1)->RJI_LINK == (DBFFILE)->RJ_001
               RJ_ITEMS->(FilLock(0))
               RJ_ITEMS->(DbAppend())
               RJ_ITEMS->RJI_LINK := (DBFFILE1)->RJI_LINK
               RJ_ITEMS->RJI_ITEM := (DBFFILE1)->RJI_ITEM
               RJ_ITEMS->RJI_COST := (DBFFILE1)->RJI_COST
               RJ_ITEMS->RJI_URET := (DBFFILE1)->RJI_URET
               RJ_ITEMS->RJI_QRET := (DBFFILE1)->RJI_QRET
               RJ_ITEMS->RJI_POST := (DBFFILE1)->RJI_POST
               RJ_ITEMS->RJI_AGEC := (DBFFILE1)->RJI_AGEC
               RJ_ITEMS->(DbUnLock())
               (DBFFILE1)->(DbSkip())
            enddo
         endif   
      CASE (DBFFILE)->RJ_012 == 2 .OR. (DBFFILE)->RJ_012 == 5
         IF RJ->(DBSEEK((DBFFILE)->RJ_001))
            RJ->(Reclock(0))
            RJ->RJ_001 := (DBFFILE)->RJ_001
            RJ->RJ_002 := (DBFFILE)->RJ_002
            RJ->RJ_003 := (DBFFILE)->RJ_003
            RJ->RJ_004 := (DBFFILE)->RJ_004
            RJ->RJ_005 := (DBFFILE)->RJ_005
            RJ->RJ_006 := (DBFFILE)->RJ_006
            RJ->RJ_007 := (DBFFILE)->RJ_007
            RJ->RJ_008 := (DBFFILE)->RJ_008
            RJ->RJ_009 := (DBFFILE)->RJ_009
            RJ->RJ_010 := (DBFFILE)->RJ_010
            RJ->RJ_011 := (DBFFILE)->RJ_011
            RJ->(DbUnLock())
            (DBFFILE)->(Reclock(0))
            (DBFFILE)->RJ_012 := 0
            (DBFFILE)->(DbUnlock())
            if (DBFFILE1)->(Dbseek((DBFFILE)->RJ_001))
               Do While (DBFFILE1)->(!Eof()) .and. (DBFFILE1)->RJI_LINK == (DBFFILE)->RJ_001
                  RJ_ITEMS->(RecLock(0))
                  RJ_ITEMS->RJI_LINK := (DBFFILE1)->RJI_LINK
                  RJ_ITEMS->RJI_ITEM := (DBFFILE1)->RJI_ITEM
                  RJ_ITEMS->RJI_COST := (DBFFILE1)->RJI_COST
                  RJ_ITEMS->RJI_URET := (DBFFILE1)->RJI_URET
                  RJ_ITEMS->RJI_QRET := (DBFFILE1)->RJI_QRET
                  RJ_ITEMS->RJI_POST := (DBFFILE1)->RJI_POST
                  RJ_ITEMS->RJI_AGEC := (DBFFILE1)->RJI_AGEC
                  RJ_ITEMS->(DbUnLock())
                  (DBFFILE1)->(DbSkip())
               enddo
            endif            
         ELSE
            RJ->(FilLock(0))
            RJ->(DbAppend())
            RJ->RJ_001 := (DBFFILE)->RJ_001
            RJ->RJ_002 := (DBFFILE)->RJ_002
            RJ->RJ_003 := (DBFFILE)->RJ_003
            RJ->RJ_004 := (DBFFILE)->RJ_004
            RJ->RJ_005 := (DBFFILE)->RJ_005
            RJ->RJ_006 := (DBFFILE)->RJ_006
            RJ->RJ_007 := (DBFFILE)->RJ_007
            RJ->RJ_008 := (DBFFILE)->RJ_008
            RJ->RJ_009 := (DBFFILE)->RJ_009
            RJ->RJ_010 := (DBFFILE)->RJ_010
            RJ->RJ_011 := (DBFFILE)->RJ_011
            RJ->(DbUnLock())
            (DBFFILE)->(Reclock(0))
            (DBFFILE)->RJ_012 := 0
            (DBFFILE)->(DbUnlock())
            if (DBFFILE1)->(Dbseek((DBFFILE)->RJ_001))
               Do While (DBFFILE1)->(!Eof()) .and. (DBFFILE1)->RJI_LINK == (DBFFILE)->RJ_001
                  RJ_ITEMS->(FilLock(0))
                  RJ_ITEMS->(DbAppend())
                  RJ_ITEMS->RJI_LINK := (DBFFILE1)->RJI_LINK
                  RJ_ITEMS->RJI_ITEM := (DBFFILE1)->RJI_ITEM
                  RJ_ITEMS->RJI_COST := (DBFFILE1)->RJI_COST
                  RJ_ITEMS->RJI_URET := (DBFFILE1)->RJI_URET
                  RJ_ITEMS->RJI_QRET := (DBFFILE1)->RJI_QRET
                  RJ_ITEMS->RJI_POST := (DBFFILE1)->RJI_POST
                  RJ_ITEMS->RJI_AGEC := (DBFFILE1)->RJI_AGEC
                  RJ_ITEMS->(DbUnLock())
                  (DBFFILE1)->(DbSkip())
               enddo
            endif            
         ENDIF   
      CASE (DBFFILE)->RJ_012 == 3
         IF RJ->(DBSEEK((DBFFILE)->RJ_001))
            RJ->(Reclock(0))
            RJ->(DbDelete())
            RJ->(DbUnLock())
            (DBFFILE)->(Reclock(0))
            (DBFFILE)->RJ_012 := 0
            (DBFFILE)->(DbUnlock())
            if (DBFFILE1)->(Dbseek((DBFFILE)->RJ_001))
               Do While (DBFFILE1)->(!Eof()) .and. (DBFFILE1)->RJI_LINK == (DBFFILE)->RJ_001
                  RJ_ITEMS->(RecLock(0))
                  RJ_ITEMS->(DbDelete())
                  RJ_ITEMS->(DbUnLock())
                  (DBFFILE1)->(DbSkip())
               enddo
            endif            
         ENDIF   
      CASE (DBFFILE)->RJ_012 == 4
         IF RJ->(DBSEEK((DBFFILE)->RJ_001))
            RJ->(Reclock(0))
            RJ->(DbRecall())
            RJ->(DbUnLock())
            (DBFFILE)->(Reclock(0))
            (DBFFILE)->RJ_012 := 0
            (DBFFILE)->(DbUnlock())
            if (DBFFILE1)->(Dbseek((DBFFILE)->RJ_001))
               Do While (DBFFILE1)->(!Eof()) .and. (DBFFILE1)->RJI_LINK == (DBFFILE)->RJ_001
                  RJ_ITEMS->(RecLock(0))
                  RJ_ITEMS->(DbRecall())
                  RJ_ITEMS->(DbUnLock())
                  (DBFFILE1)->(DbSkip())
               enddo
            endif               
         ELSE
            RJ->(FilLock(0))
            RJ->(DbAppend())
            RJ->RJ_001 := (DBFFILE)->RJ_001
            RJ->RJ_002 := (DBFFILE)->RJ_002
            RJ->RJ_003 := (DBFFILE)->RJ_003
            RJ->RJ_004 := (DBFFILE)->RJ_004
            RJ->RJ_005 := (DBFFILE)->RJ_005
            RJ->RJ_006 := (DBFFILE)->RJ_006
            RJ->RJ_007 := (DBFFILE)->RJ_007
            RJ->RJ_008 := (DBFFILE)->RJ_008
            RJ->RJ_009 := (DBFFILE)->RJ_009
            RJ->RJ_010 := (DBFFILE)->RJ_010
            RJ->RJ_011 := (DBFFILE)->RJ_011
            RJ->(DbUnLock())
            (DBFFILE)->(Reclock(0))
            (DBFFILE)->RJ_012 := 0
            (DBFFILE)->(DbUnlock())
            if (DBFFILE1)->(Dbseek((DBFFILE)->RJ_001))
               Do While (DBFFILE1)->(!Eof()) .and. (DBFFILE1)->RJI_LINK == (DBFFILE)->RJ_001
                  RJ_ITEMS->(FilLock(0))
                  RJ_ITEMS->(DbAppend())
                  RJ_ITEMS->RJI_LINK := (DBFFILE1)->RJI_LINK
                  RJ_ITEMS->RJI_ITEM := (DBFFILE1)->RJI_ITEM
                  RJ_ITEMS->RJI_COST := (DBFFILE1)->RJI_COST
                  RJ_ITEMS->RJI_URET := (DBFFILE1)->RJI_URET
                  RJ_ITEMS->RJI_QRET := (DBFFILE1)->RJI_QRET
                  RJ_ITEMS->RJI_POST := (DBFFILE1)->RJI_POST
                  RJ_ITEMS->RJI_AGEC := (DBFFILE1)->RJI_AGEC
                  RJ_ITEMS->(DbUnLock())
                  (DBFFILE1)->(DbSkip())
               enddo
            endif            
         ENDIF      
   ENDCASE
   
   (DBFFILE)->(DbSkip())
enddo
GaugeUpdate(hGauge,1)               
@ 13,05 clear to 14,74
@ 13,05 say " Uploading of RETURN file FINISHED."
HEYTHERE()
OKDONE()
CloseWindow(wReindex)
DbCloseAll()


/*============================= TRANSFER =====================================*/

if !file((UP_PATH)+"ST_DOWN.DBF")
   return nil      
endif 

if NetUse("ST_ITEMS",DB_SHARED,NUM_SECONDS)
   set index to STI_LINK
endif   
if NetUse("ST",DB_SHARED,NUM_SECONDS)
      set index to ST_001
endif   
if NetUse((UP_PATH)+"ST_DOWN",DB_SHARED,NUM_SECONDS)
   dbffile := alias()
endif   
if NetUse((UP_PATH)+"STITEMS_DOWN",DB_SHARED,NUM_SECONDS)
   dbffile1 := alias()
   INDEX ON (DBFFILE1)->STI_LINK TO STIDOWN
endif   

Message("Uploading TRANSFER File....please wait!")
wReindex:=OpenWindow(08,03,15,76,"UPLOAD")
hGauge:=GaugeNew(10,05,12,74,"N/W","N/W",chr(177))
GaugeDisplay(hGauge)
i := 0

(DBFFILE)->(DbGoTop())
Do while (DBFFILE)->(!Eof())
   nPercent:=i++/100
   GaugeUpdate(hGauge,nPercent)            
   DO CASE
      CASE (DBFFILE)->ST_009 == 1
         ST->(FilLock(0))
         ST->(DbAppend())
         ST->ST_001 := (DBFFILE)->ST_001
         ST->ST_002 := (DBFFILE)->ST_002
         ST->ST_003 := (DBFFILE)->ST_003
         ST->ST_004 := (DBFFILE)->ST_004
         ST->ST_005 := (DBFFILE)->ST_005
         ST->ST_006 := (DBFFILE)->ST_006
         ST->ST_007 := (DBFFILE)->ST_007
         ST->ST_008 := (DBFFILE)->ST_008
         ST->(DbUnLock())
         (DBFFILE)->(Reclock(0))
         (DBFFILE)->ST_009 := 0
         (DBFFILE)->(DbUnlock())
         if (DBFFILE1)->(Dbseek((DBFFILE)->ST_001))
            Do While (DBFFILE1)->(!Eof()) .and. (DBFFILE1)->STI_LINK == (DBFFILE)->ST_001
               ST_ITEMS->(FilLock(0))
               ST_ITEMS->(DbAppend())
               ST_ITEMS->STI_LINK := (DBFFILE1)->STI_LINK
               ST_ITEMS->STI_ITEM := (DBFFILE1)->STI_ITEM
               ST_ITEMS->STI_QADJ := (DBFFILE1)->STI_QADJ
               ST_ITEMS->STI_UPRC := (DBFFILE1)->STI_UPRC
               ST_ITEMS->STI_POST := (DBFFILE1)->STI_POST
               ST_ITEMS->(DbUnLock())
               (DBFFILE1)->(DbSkip())
            enddo
         endif   
      CASE (DBFFILE)->ST_009 == 2 .OR. (DBFFILE)->ST_009 == 5
         IF ST->(DBSEEK((DBFFILE)->ST_001))
            ST->(RecLock(0))
            ST->ST_001 := (DBFFILE)->ST_001
            ST->ST_002 := (DBFFILE)->ST_002
            ST->ST_003 := (DBFFILE)->ST_003
            ST->ST_004 := (DBFFILE)->ST_004
            ST->ST_005 := (DBFFILE)->ST_005
            ST->ST_006 := (DBFFILE)->ST_006
            ST->ST_007 := (DBFFILE)->ST_007
            ST->ST_008 := (DBFFILE)->ST_008
            ST->(DbUnLock())
            (DBFFILE)->(Reclock(0))
            (DBFFILE)->ST_009 := 0
            (DBFFILE)->(DbUnlock())
            if (DBFFILE1)->(Dbseek((DBFFILE)->ST_001))
               Do While (DBFFILE1)->(!Eof()) .and. (DBFFILE1)->STI_LINK == (DBFFILE)->ST_001
                  ST_ITEMS->(RecLock(0))
                  ST_ITEMS->STI_LINK := (DBFFILE1)->STI_LINK
                  ST_ITEMS->STI_ITEM := (DBFFILE1)->STI_ITEM
                  ST_ITEMS->STI_QADJ := (DBFFILE1)->STI_QADJ
                  ST_ITEMS->STI_UPRC := (DBFFILE1)->STI_UPRC
                  ST_ITEMS->STI_POST := (DBFFILE1)->STI_POST
                  ST_ITEMS->(DbUnLock())
                  (DBFFILE1)->(DbSkip())
               enddo
            endif      
         ELSE
            ST->(FilLock(0))
            ST->(DbAppend())
            ST->ST_001 := (DBFFILE)->ST_001
            ST->ST_002 := (DBFFILE)->ST_002
            ST->ST_003 := (DBFFILE)->ST_003
            ST->ST_004 := (DBFFILE)->ST_004
            ST->ST_005 := (DBFFILE)->ST_005
            ST->ST_006 := (DBFFILE)->ST_006
            ST->ST_007 := (DBFFILE)->ST_007
            ST->ST_008 := (DBFFILE)->ST_008
            ST->(DbUnLock())
            (DBFFILE)->(Reclock(0))
            (DBFFILE)->ST_009 := 0
            (DBFFILE)->(DbUnlock())
            if (DBFFILE1)->(Dbseek((DBFFILE)->ST_001))
               Do While (DBFFILE1)->(!Eof()) .and. (DBFFILE1)->STI_LINK == (DBFFILE)->ST_001
                  ST_ITEMS->(FilLock(0))
                  ST_ITEMS->(DbAppend())
                  ST_ITEMS->STI_LINK := (DBFFILE1)->STI_LINK
                  ST_ITEMS->STI_ITEM := (DBFFILE1)->STI_ITEM
                  ST_ITEMS->STI_QADJ := (DBFFILE1)->STI_QADJ
                  ST_ITEMS->STI_UPRC := (DBFFILE1)->STI_UPRC
                  ST_ITEMS->STI_POST := (DBFFILE1)->STI_POST
                  ST_ITEMS->(DbUnLock())
                  (DBFFILE1)->(DbSkip())
               enddo
            endif      
         ENDIF   
      CASE (DBFFILE)->ST_009 == 3
         IF ST->(DBSEEK((DBFFILE)->ST_001))
            ST->(RecLock(0))
            ST->(DbDelete())
            ST->(DbUnLock())
            (DBFFILE)->(Reclock(0))
            (DBFFILE)->ST_009 := 0
            (DBFFILE)->(DbUnlock())
            if (DBFFILE1)->(Dbseek((DBFFILE)->ST_001))
               Do While (DBFFILE1)->(!Eof()) .and. (DBFFILE1)->STI_LINK == (DBFFILE)->ST_001
                  ST_ITEMS->(RecLock(0))
                  ST_ITEMS->(DbDelete())
                  ST_ITEMS->(DbUnLock())
                  (DBFFILE1)->(DbSkip())
               enddo
            endif   
         ENDIF      
      CASE (DBFFILE)->ST_009 == 4
         IF ST->(DBSEEK((DBFFILE)->ST_001))
            ST->(RecLock(0))
            ST->(DbRecall())
            ST->(DbUnLock())
            (DBFFILE)->(Reclock(0))
            (DBFFILE)->ST_009 := 0
            (DBFFILE)->(DbUnlock())
            if (DBFFILE1)->(Dbseek((DBFFILE)->ST_001))
               Do While (DBFFILE1)->(!Eof()) .and. (DBFFILE1)->STI_LINK == (DBFFILE)->ST_001
                  ST_ITEMS->(RecLock(0))
                  ST_ITEMS->(DbRecall())
                  ST_ITEMS->(DbUnLock())
                  (DBFFILE1)->(DbSkip())
               enddo
            endif            
         ELSE
            ST->(FilLock(0))
            ST->(DbAppend())
            ST->ST_001 := (DBFFILE)->ST_001
            ST->ST_002 := (DBFFILE)->ST_002
            ST->ST_003 := (DBFFILE)->ST_003
            ST->ST_004 := (DBFFILE)->ST_004
            ST->ST_005 := (DBFFILE)->ST_005
            ST->ST_006 := (DBFFILE)->ST_006
            ST->ST_007 := (DBFFILE)->ST_007
            ST->ST_008 := (DBFFILE)->ST_008
            ST->(DbUnLock())
            (DBFFILE)->(Reclock(0))
            (DBFFILE)->ST_009 := 0
            (DBFFILE)->(DbUnlock())
            if (DBFFILE1)->(Dbseek((DBFFILE)->ST_001))
               Do While (DBFFILE1)->(!Eof()) .and. (DBFFILE1)->STI_LINK == (DBFFILE)->ST_001
                  ST_ITEMS->(FilLock(0))
                  ST_ITEMS->(DbAppend())
                  ST_ITEMS->STI_LINK := (DBFFILE1)->STI_LINK
                  ST_ITEMS->STI_ITEM := (DBFFILE1)->STI_ITEM
                  ST_ITEMS->STI_QADJ := (DBFFILE1)->STI_QADJ
                  ST_ITEMS->STI_UPRC := (DBFFILE1)->STI_UPRC
                  ST_ITEMS->STI_POST := (DBFFILE1)->STI_POST
                  ST_ITEMS->(DbUnLock())
                  (DBFFILE1)->(DbSkip())
               enddo
            endif      
         ENDIF            
   ENDCASE
      
   (DBFFILE)->(DbSkip())
enddo
GaugeUpdate(hGauge,1)               
@ 13,05 clear to 14,74
@ 13,05 say " Uploading of TRANSFER file FINISHED."
HEYTHERE()
OKDONE()
CloseWindow(wReindex)
DbCloseAll()


/*============================= ADJUSTMENT =====================================*/

if !file((UP_PATH)+"SA_DOWN.DBF")
   return nil      
endif 


if NetUse("SA_ITEMS",DB_SHARED,NUM_SECONDS)
   set index to SAI_LINK
endif   
if NetUse("SA",DB_SHARED,NUM_SECONDS)
      set index to SA_001
endif   
if NetUse((UP_PATH)+"SA_DOWN",DB_SHARED,NUM_SECONDS)
   dbffile := alias()
endif   
if NetUse((UP_PATH)+"SAITEMS_DOWN",DB_SHARED,NUM_SECONDS)
   dbffile1 := alias()
   INDEX ON (DBFFILE1)->SAI_LINK TO SAIDOWN
endif   

Message("Uploading ADJUSTMENT File....please wait!")
wReindex:=OpenWindow(08,03,15,76,"UPLOAD")
hGauge:=GaugeNew(10,05,12,74,"N/W","N/W",chr(177))
GaugeDisplay(hGauge)
i := 0

(DBFFILE)->(DbGoTop())
Do while (DBFFILE)->(!Eof())
   nPercent:=i++/100
   GaugeUpdate(hGauge,nPercent)            
   DO CASE
      CASE (DBFFILE)->SA_007 == 1
         SA->(FilLock(0))
         SA->(DbAppend())
         SA->SA_001 := (DBFFILE)->SA_001
         SA->SA_002 := (DBFFILE)->SA_002
         SA->SA_003 := (DBFFILE)->SA_003
         SA->SA_004 := (DBFFILE)->SA_004
         SA->SA_005 := (DBFFILE)->SA_005
         SA->SA_006 := (DBFFILE)->SA_006
         SA->(DbUnLock())
         (DBFFILE)->(Reclock(0))
         (DBFFILE)->SA_007 := 0
         (DBFFILE)->(DbUnlock())
         if (DBFFILE1)->(Dbseek((DBFFILE)->SA_001))
            Do While (DBFFILE1)->(!Eof()) .and. (DBFFILE1)->SAI_LINK == (DBFFILE)->SA_001
               SA_ITEMS->(FilLock(0))
               SA_ITEMS->(DbAppend())
               SA_ITEMS->SAI_LINK := (DBFFILE1)->SAI_LINK
               SA_ITEMS->SAI_ITEM := (DBFFILE1)->SAI_ITEM
               SA_ITEMS->SAI_QADJ := (DBFFILE1)->SAI_QADJ
               SA_ITEMS->SAI_UPRC := (DBFFILE1)->SAI_UPRC
               SA_ITEMS->SAI_POST := (DBFFILE1)->SAI_POST
               SA_ITEMS->(DbUnLock())
               (DBFFILE1)->(DbSkip())
            enddo
         endif   
      CASE (DBFFILE)->SA_007 == 2 .OR. (DBFFILE)->SA_007 == 5
         IF SA->(DBSEEK((DBFFILE)->SA_001))
            SA->(RecLock(0))
            SA->SA_001 := (DBFFILE)->SA_001
            SA->SA_002 := (DBFFILE)->SA_002
            SA->SA_003 := (DBFFILE)->SA_003
            SA->SA_004 := (DBFFILE)->SA_004
            SA->SA_005 := (DBFFILE)->SA_005
            SA->SA_006 := (DBFFILE)->SA_006
            SA->(DbUnLock())
            (DBFFILE)->(Reclock(0))
            (DBFFILE)->SA_007 := 0
            (DBFFILE)->(DbUnlock())
            if (DBFFILE1)->(Dbseek((DBFFILE)->SA_001))
               Do While (DBFFILE1)->(!Eof()) .and. (DBFFILE1)->SAI_LINK == (DBFFILE)->SA_001
                  SA_ITEMS->(RecLock(0))
                  SA_ITEMS->SAI_LINK := (DBFFILE1)->SAI_LINK
                  SA_ITEMS->SAI_ITEM := (DBFFILE1)->SAI_ITEM
                  SA_ITEMS->SAI_QADJ := (DBFFILE1)->SAI_QADJ
                  SA_ITEMS->SAI_UPRC := (DBFFILE1)->SAI_UPRC
                  SA_ITEMS->SAI_POST := (DBFFILE1)->SAI_POST
                  SA_ITEMS->(DbUnLock())
                  (DBFFILE1)->(DbSkip())
               enddo
            endif      
         ELSE
            SA->(FilLock(0))
            SA->(DbAppend())
            SA->SA_001 := (DBFFILE)->SA_001
            SA->SA_002 := (DBFFILE)->SA_002
            SA->SA_003 := (DBFFILE)->SA_003
            SA->SA_004 := (DBFFILE)->SA_004
            SA->SA_005 := (DBFFILE)->SA_005
            SA->SA_006 := (DBFFILE)->SA_006
            SA->(DbUnLock())
            (DBFFILE)->(Reclock(0))
            (DBFFILE)->SA_007 := 0
            (DBFFILE)->(DbUnlock())
            if (DBFFILE1)->(Dbseek((DBFFILE)->SA_001))
               Do While (DBFFILE1)->(!Eof()) .and. (DBFFILE1)->SAI_LINK == (DBFFILE)->SA_001
                  SA_ITEMS->(FilLock(0))
                  SA_ITEMS->(DbAppend())
                  SA_ITEMS->SAI_LINK := (DBFFILE1)->SAI_LINK
                  SA_ITEMS->SAI_ITEM := (DBFFILE1)->SAI_ITEM
                  SA_ITEMS->SAI_QADJ := (DBFFILE1)->SAI_QADJ
                  SA_ITEMS->SAI_UPRC := (DBFFILE1)->SAI_UPRC
                  SA_ITEMS->SAI_POST := (DBFFILE1)->SAI_POST
                  SA_ITEMS->(DbUnLock())
                  (DBFFILE1)->(DbSkip())
               enddo
            endif      
         ENDIF   
      CASE (DBFFILE)->SA_007 == 3
         IF SA->(DBSEEK((DBFFILE)->SA_001))
            SA->(RecLock(0))
            SA->(dbDelete())
            SA->(DbUnLock())
            (DBFFILE)->(Reclock(0))
            (DBFFILE)->SA_007 := 0
            (DBFFILE)->(DbUnlock())
            if (DBFFILE1)->(Dbseek((DBFFILE)->SA_001))
               Do While (DBFFILE1)->(!Eof()) .and. (DBFFILE1)->SAI_LINK == (DBFFILE)->SA_001
                  SA_ITEMS->(RecLock(0))
                  SA_ITEMS->(DbDelete())
                  SA_ITEMS->(DbUnLock())
                  (DBFFILE1)->(DbSkip())
               enddo
            endif      
         ENDIF
      CASE (DBFFILE)->SA_007 == 4
         IF SA->(DBSEEK((DBFFILE)->SA_001))
            SA->(RecLock(0))
            SA->(dbRecall())
            SA->(DbUnLock())
            (DBFFILE)->(Reclock(0))
            (DBFFILE)->SA_007 := 0
            (DBFFILE)->(DbUnlock())
            if (DBFFILE1)->(Dbseek((DBFFILE)->SA_001))
               Do While (DBFFILE1)->(!Eof()) .and. (DBFFILE1)->SAI_LINK == (DBFFILE)->SA_001
                  SA_ITEMS->(RecLock(0))
                  SA_ITEMS->(DbRecall())
                  SA_ITEMS->(DbUnLock())
                  (DBFFILE1)->(DbSkip())
               enddo
            endif                  
         ELSE
            SA->(FilLock(0))
            SA->(DbAppend())
            SA->SA_001 := (DBFFILE)->SA_001
            SA->SA_002 := (DBFFILE)->SA_002
            SA->SA_003 := (DBFFILE)->SA_003
            SA->SA_004 := (DBFFILE)->SA_004
            SA->SA_005 := (DBFFILE)->SA_005
            SA->SA_006 := (DBFFILE)->SA_006
            SA->(DbUnLock())
            (DBFFILE)->(Reclock(0))
            (DBFFILE)->SA_007 := 0
            (DBFFILE)->(DbUnlock())
            if (DBFFILE1)->(Dbseek((DBFFILE)->SA_001))
               Do While (DBFFILE1)->(!Eof()) .and. (DBFFILE1)->SAI_LINK == (DBFFILE)->SA_001
                  SA_ITEMS->(FilLock(0))
                  SA_ITEMS->(DbAppend())
                  SA_ITEMS->SAI_LINK := (DBFFILE1)->SAI_LINK
                  SA_ITEMS->SAI_ITEM := (DBFFILE1)->SAI_ITEM
                  SA_ITEMS->SAI_QADJ := (DBFFILE1)->SAI_QADJ
                  SA_ITEMS->SAI_UPRC := (DBFFILE1)->SAI_UPRC
                  SA_ITEMS->SAI_POST := (DBFFILE1)->SAI_POST
                  SA_ITEMS->(DbUnLock())
                  (DBFFILE1)->(DbSkip())
               enddo
            endif      
         ENDIF            
   ENDCASE
   
   (DBFFILE)->(DbSkip())
enddo
GaugeUpdate(hGauge,1)               
@ 13,05 clear to 14,74
@ 13,05 say " Uploading of ADJUSTMENT file FINISHED."
HEYTHERE()
OKDONE()
CloseWindow(wReindex)
DbCloseAll()

return nil