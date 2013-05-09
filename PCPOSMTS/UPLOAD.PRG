#include "Inkey.ch"
#include "Setcurs.ch"
#include "Directry.ch"
#include "Error.ch"
#include "ITS.ch"
#include "Janus.ch"

#define UP_PATH  chr(65+curdrv())+":\"+curdir()+"\UPLOAD\"   

function Upload()

local wReindex,hGauge,cAlias,n,i:=0,nFileCount:=0,nPercent
local adir := {}, aUnits := {}, y := 0, ui_down, dbffile
local dbffile1, r:=0


if alert("Continue ?", {"YES","NO"}) == 2
   return nil   
endif

if lastkey() == K_ESC
   return nil
endif


/*============================= SUPPLIER =====================================*/

if !file((UP_PATH)+"V_DOWN.DBF")
   return nil
endif

if NetUse("V",DB_SHARED,NUM_SECONDS)
      set index to V_001
endif   

if NetUse((UP_PATH)+"V_DOWN",DB_SHARED,NUM_SECONDS)
   DBFFILE := ALIAS()
endif   

Message("Uploading Supplier File....please wait!")
wReindex:=OpenWindow(08,03,15,76,"UPLOAD")
hGauge:=GaugeNew(10,05,12,74,"N/W","N/W",chr(177))
GaugeDisplay(hGauge)
i := 0

(DBFFILE)->(DbGoTop())
Do while (DBFFILE)->(!Eof())
   nPercent:=i++/100
   GaugeUpdate(hGauge,nPercent)            
   Do Case
      Case (DBFFILE)->V_013 == 1
         if !V->(Dbseek((DBFFILE)->V_001))
         V->(FilLock(0))
         V->(DbAppend())
         V->V_001 := (DBFFILE)->V_001
         V->V_002 := (DBFFILE)->V_002
         V->V_003 := (DBFFILE)->V_003
         V->V_004 := (DBFFILE)->V_004
         V->V_005 := (DBFFILE)->V_005
         V->V_006 := (DBFFILE)->V_006
         V->V_007 := (DBFFILE)->V_007
         V->V_008 := (DBFFILE)->V_008
         V->V_009 := (DBFFILE)->V_009
         V->V_010 := (DBFFILE)->V_010
         V->V_011 := (DBFFILE)->V_011
         V->V_012 := (DBFFILE)->V_012
         V->(DbUnLock())
         (DBFFILE)->(Reclock(0))
         (DBFFILE)->V_013 := 0
         (DBFFILE)->(DbUnLock())
	 endif
      Case (DBFFILE)->V_013 == 2 .OR. (DBFFILE)->V_013 == 5
         if V->(Dbseek((DBFFILE)->V_001))
            V->(RecLock(0))
            V->V_001 := (DBFFILE)->V_001
            V->V_002 := (DBFFILE)->V_002
            V->V_003 := (DBFFILE)->V_003
            V->V_004 := (DBFFILE)->V_004
            V->V_005 := (DBFFILE)->V_005
            V->V_006 := (DBFFILE)->V_006
            V->V_007 := (DBFFILE)->V_007
            V->V_008 := (DBFFILE)->V_008
            V->V_009 := (DBFFILE)->V_009
            V->V_010 := (DBFFILE)->V_010
            V->V_011 := (DBFFILE)->V_011
            V->V_012 := (DBFFILE)->V_012
            V->(DbUnLock())
            (DBFFILE)->(Reclock(0))
            (DBFFILE)->V_013 := 0
            (DBFFILE)->(DbUnLock())   
         else
            V->(FilLock(0))
            V->(DbAppend())
            V->V_001 := (DBFFILE)->V_001
            V->V_002 := (DBFFILE)->V_002
            V->V_003 := (DBFFILE)->V_003
            V->V_004 := (DBFFILE)->V_004
            V->V_005 := (DBFFILE)->V_005
            V->V_006 := (DBFFILE)->V_006
            V->V_007 := (DBFFILE)->V_007
            V->V_008 := (DBFFILE)->V_008
            V->V_009 := (DBFFILE)->V_009
            V->V_010 := (DBFFILE)->V_010
            V->V_011 := (DBFFILE)->V_011
            V->V_012 := (DBFFILE)->V_012
            V->(DbUnLock())
            (DBFFILE)->(Reclock(0))
            (DBFFILE)->V_013 := 0
            (DBFFILE)->(DbUnLock())   
         endif   
      Case (DBFFILE)->V_013 == 3
         if V->(Dbseek((DBFFILE)->V_001))
            V->(RecLock(0))
            V->(DbDelete())
            V->(DbUnLock())
            (DBFFILE)->(Reclock(0))
            (DBFFILE)->V_013 := 0
            (DBFFILE)->(DbUnLock())   
         endif          
      Case (DBFFILE)->V_013 == 4
         if V->(Dbseek((DBFFILE)->V_001))
            V->(RecLock(0))
            V->(DbRecall())
            V->(DbUnLock())
            (DBFFILE)->(Reclock(0))
            (DBFFILE)->V_013 := 0
            (DBFFILE)->(DbUnLock())   
         else   
            V->(FilLock(0))
            V->(DbAppend())
            V->V_001 := (DBFFILE)->V_001
            V->V_002 := (DBFFILE)->V_002
            V->V_003 := (DBFFILE)->V_003
            V->V_004 := (DBFFILE)->V_004
            V->V_005 := (DBFFILE)->V_005
            V->V_006 := (DBFFILE)->V_006
            V->V_007 := (DBFFILE)->V_007
            V->V_008 := (DBFFILE)->V_008
            V->V_009 := (DBFFILE)->V_009
            V->V_010 := (DBFFILE)->V_010
            V->V_011 := (DBFFILE)->V_011
            V->V_012 := (DBFFILE)->V_012
            V->(DbUnLock())
            (DBFFILE)->(Reclock(0))
            (DBFFILE)->V_013 := 0
            (DBFFILE)->(DbUnLock())   
         endif            
   Endcase
   (DBFFILE)->(DbSkip())
enddo
GaugeUpdate(hGauge,1)               
@ 13,05 clear to 14,74
@ 13,05 say " Uploading of Supplier file FINISHED."
HEYTHERE()
OKDONE()
CloseWindow(wReindex)
DbCloseAll()


/*============================= DEPARTMENT =====================================*/

if !file((UP_PATH)+"DP_DOWN.DBF")
   return nil
endif

if NetUse("DP",DB_SHARED,NUM_SECONDS)
      set index to DP_001
endif   
if NetUse((UP_PATH)+"DP_DOWN",DB_SHARED,NUM_SECONDS)
   DBFFILE := ALIAS()
endif   

Message("Uploading Department File....please wait!")
wReindex:=OpenWindow(08,03,15,76,"UPLOAD")
hGauge:=GaugeNew(10,05,12,74,"N/W","N/W",chr(177))
GaugeDisplay(hGauge)
i := 0

(DBFFILE)->(DbGoTop())
Do while (DBFFILE)->(!Eof())
  nPercent:=i++/100
  GaugeUpdate(hGauge,nPercent)            
  DO CASE
   CASE (DBFFILE)->DP_012 == 1
      IF !DP->(DbSeek((DBFFILE)->DP_001))
      DP->(FilLock(0))
      DP->(DbAppend())
      DP->DP_001 := (DBFFILE)->DP_001
      DP->DP_002 := (DBFFILE)->DP_002
      DP->DP_003 := (DBFFILE)->DP_003
      DP->DP_004 := (DBFFILE)->DP_004
      DP->DP_005 := (DBFFILE)->DP_005
      DP->DP_006 := (DBFFILE)->DP_006
      DP->DP_007 := (DBFFILE)->DP_007
      DP->DP_008 := (DBFFILE)->DP_008
      DP->DP_009 := (DBFFILE)->DP_009
      DP->DP_010 := (DBFFILE)->DP_010
      DP->DP_011 := (DBFFILE)->DP_011
      DP->(DbUnLock())
      (DBFFILE)->(Reclock(0))
      (DBFFILE)->DP_012 := 0
      (DBFFILE)->(DbUnLock())
      endif
    CASE (DBFFILE)->DP_012 == 2 .OR. (DBFFILE)->DP_012 == 5
      IF DP->(DbSeek((DBFFILE)->DP_001))
         DP->(RecLock(0))
         DP->DP_001 := (DBFFILE)->DP_001
         DP->DP_002 := (DBFFILE)->DP_002
         DP->DP_003 := (DBFFILE)->DP_003
         DP->DP_004 := (DBFFILE)->DP_004
         DP->DP_005 := (DBFFILE)->DP_005
         DP->DP_006 := (DBFFILE)->DP_006
         DP->DP_007 := (DBFFILE)->DP_007
         DP->DP_008 := (DBFFILE)->DP_008
         DP->DP_009 := (DBFFILE)->DP_009
         DP->DP_010 := (DBFFILE)->DP_010
         DP->DP_011 := (DBFFILE)->DP_011
         DP->(DbUnLock())
         (DBFFILE)->(Reclock(0))
         (DBFFILE)->DP_012 := 0
         (DBFFILE)->(DbUnLock())
      ELSE
         DP->(FilLock(0))
         DP->(DbAppend())
         DP->DP_001 := (DBFFILE)->DP_001
         DP->DP_002 := (DBFFILE)->DP_002
         DP->DP_003 := (DBFFILE)->DP_003
         DP->DP_004 := (DBFFILE)->DP_004
         DP->DP_005 := (DBFFILE)->DP_005
         DP->DP_006 := (DBFFILE)->DP_006
         DP->DP_007 := (DBFFILE)->DP_007
         DP->DP_008 := (DBFFILE)->DP_008
         DP->DP_009 := (DBFFILE)->DP_009
         DP->DP_010 := (DBFFILE)->DP_010
         DP->DP_011 := (DBFFILE)->DP_011
         DP->(DbUnLock())
         (DBFFILE)->(Reclock(0))
         (DBFFILE)->DP_012 := 0
         (DBFFILE)->(DbUnLock())
      ENDIF  
    CASE (DBFFILE)->DP_012 == 3
         if DP->(Dbseek((DBFFILE)->DP_001))
            DP->(RecLock(0))
            DP->(DbDelete())
            DP->(DbUnLock())
            (DBFFILE)->(Reclock(0))
            (DBFFILE)->DP_012 := 0
            (DBFFILE)->(DbUnLock())   
         endif          
     CASE (DBFFILE)->DP_012 == 4
         if DP->(Dbseek((DBFFILE)->DP_001))
            DP->(RecLock(0))
            DP->(DbRecall())
            DP->(DbUnLock())
            (DBFFILE)->(Reclock(0))
            (DBFFILE)->DP_012 := 0
            (DBFFILE)->(DbUnLock())   
         else     
            DP->(FilLock(0))
            DP->(DbAppend())
            DP->DP_001 := (DBFFILE)->DP_001
            DP->DP_002 := (DBFFILE)->DP_002
            DP->DP_003 := (DBFFILE)->DP_003
            DP->DP_004 := (DBFFILE)->DP_004
            DP->DP_005 := (DBFFILE)->DP_005
            DP->DP_006 := (DBFFILE)->DP_006
            DP->DP_007 := (DBFFILE)->DP_007
            DP->DP_008 := (DBFFILE)->DP_008
            DP->DP_009 := (DBFFILE)->DP_009
            DP->DP_010 := (DBFFILE)->DP_010
            DP->DP_011 := (DBFFILE)->DP_011
            DP->(DbUnLock())
            (DBFFILE)->(Reclock(0))
            (DBFFILE)->DP_012 := 0
            (DBFFILE)->(DbUnLock())
         endif
   ENDCASE
   (DBFFILE)->(DbSkip())
enddo
GaugeUpdate(hGauge,1)               
@ 13,05 clear to 14,74
@ 13,05 say " Uploading of Department file FINISHED."
HEYTHERE()
OKDONE()
CloseWindow(wReindex)
DbCloseAll()



/*============================= CLASS =====================================*/

if !file((UP_PATH)+"CL_DOWN.DBF")
   return nil
endif

if NetUse("CL",DB_SHARED,NUM_SECONDS)
      set index to CL_001
endif   
if NetUse((UP_PATH)+"CL_DOWN",DB_SHARED,NUM_SECONDS)
   DBFFILE := ALIAS()
endif   

Message("Uploading Class File....please wait!")
wReindex:=OpenWindow(08,03,15,76,"UPLOAD")
hGauge:=GaugeNew(10,05,12,74,"N/W","N/W",chr(177))
GaugeDisplay(hGauge)
i := 0

(DBFFILE)->(DbGoTop())
Do while (DBFFILE)->(!Eof())
   nPercent:=i++/100
   GaugeUpdate(hGauge,nPercent)            
   DO CASE
      CASE (DBFFILE)->CL_006 == 1
         IF !CL->(DBSEEK((DBFFILE)->CL_001))
         CL->(FilLock(0))
         CL->(DbAppend())
         CL->CL_001 := (DBFFILE)->CL_001
         CL->CL_002 := (DBFFILE)->CL_002
         CL->CL_003 := (DBFFILE)->CL_003
         CL->CL_004 := (DBFFILE)->CL_004
         CL->CL_005 := (DBFFILE)->CL_005
         CL->(DbUnLock())
         (DBFFILE)->(Reclock(0))
         (DBFFILE)->CL_006 := 0
         (DBFFILE)->(DbUnLock())
	 endif
      CASE (DBFFILE)->CL_006 == 2 .OR. (DBFFILE)->CL_006 == 5
         IF CL->(DBSEEK((DBFFILE)->CL_001))
            CL->(RECLOCK(0))
            CL->CL_001 := (DBFFILE)->CL_001
            CL->CL_002 := (DBFFILE)->CL_002
            CL->CL_003 := (DBFFILE)->CL_003
            CL->CL_004 := (DBFFILE)->CL_004
            CL->CL_005 := (DBFFILE)->CL_005
            CL->(DbUnLock())
            (DBFFILE)->(Reclock(0))
            (DBFFILE)->CL_006 := 0
            (DBFFILE)->(DbUnLock())   
         ELSE
            CL->(FilLock(0))
            CL->(DbAppend())
            CL->CL_001 := (DBFFILE)->CL_001
            CL->CL_002 := (DBFFILE)->CL_002
            CL->CL_003 := (DBFFILE)->CL_003
            CL->CL_004 := (DBFFILE)->CL_004
            CL->CL_005 := (DBFFILE)->CL_005
            CL->(DbUnLock())
            (DBFFILE)->(Reclock(0))
            (DBFFILE)->CL_006 := 0
            (DBFFILE)->(DbUnLock())   
         ENDIF
      CASE (DBFFILE)->CL_006 == 3
         if CL->(Dbseek((DBFFILE)->CL_001))
            CL->(RecLock(0))
            CL->(DbDelete())
            CL->(DbUnLock())
            (DBFFILE)->(Reclock(0))
            (DBFFILE)->CL_006 := 0
            (DBFFILE)->(DbUnLock())   
         endif          
     CASE (DBFFILE)->CL_006 == 4
         if CL->(Dbseek((DBFFILE)->CL_001))
            CL->(RecLock(0))
            CL->(DbRecall())
            CL->(DbUnLock())
            (DBFFILE)->(Reclock(0))
            (DBFFILE)->CL_006 := 0
            (DBFFILE)->(DbUnLock())   
         else     
            CL->(FilLock(0))
            CL->(DbAppend())
            CL->CL_001 := (DBFFILE)->CL_001
            CL->CL_002 := (DBFFILE)->CL_002
            CL->CL_003 := (DBFFILE)->CL_003
            CL->CL_004 := (DBFFILE)->CL_004
            CL->CL_005 := (DBFFILE)->CL_005
            CL->(DbUnLock())
            (DBFFILE)->(Reclock(0))
            (DBFFILE)->CL_006 := 0
            (DBFFILE)->(DbUnLock())
         endif   
   ENDCASE
   (DBFFILE)->(DbSkip())
enddo
GaugeUpdate(hGauge,1)               
@ 13,05 clear to 14,74
@ 13,05 say " Uploading of Class file FINISHED."
HEYTHERE()
OKDONE()
CloseWindow(wReindex)
DbCloseAll()


/*============================= CARD =====================================*/

if !file((UP_PATH)+"CC_DOWN.DBF")
   return nil
endif

if NetUse("CC",DB_SHARED,NUM_SECONDS)
      set index to CC_001
endif   
if NetUse((UP_PATH)+"CC_DOWN",DB_SHARED,NUM_SECONDS)
   DBFFILE := ALIAS()
endif   

Message("Uploading CARD File....please wait!")
wReindex:=OpenWindow(08,03,15,76,"UPLOAD")
hGauge:=GaugeNew(10,05,12,74,"N/W","N/W",chr(177))
GaugeDisplay(hGauge)
i := 0

(DBFFILE)->(DbGoTop())
Do while (DBFFILE)->(!Eof())
   nPercent:=i++/100
   GaugeUpdate(hGauge,nPercent)            
   DO CASE
      CASE (DBFFILE)->CC_005 == 1
         IF !CC->(DBSEEK((DBFFILE)->CC_001))
         CC->(FilLock(0))
         CC->(DbAppend())
         CC->CC_001 := (DBFFILE)->CC_001
         CC->CC_002 := (DBFFILE)->CC_002
         CC->CC_003 := (DBFFILE)->CC_003
         CC->CC_004 := (DBFFILE)->CC_004
         CC->(DbUnLock())
         (DBFFILE)->(Reclock(0))
         (DBFFILE)->CC_005 := 0
         (DBFFILE)->(DbUnLock())
	 endif
      CASE (DBFFILE)->CC_005 == 2 .OR. (DBFFILE)->CC_005 == 5
         IF CC->(DBSEEK((DBFFILE)->CC_001))
            CC->(RECLOCK(0))
            CC->CC_001 := (DBFFILE)->CC_001
            CC->CC_002 := (DBFFILE)->CC_002
            CC->CC_003 := (DBFFILE)->CC_003
            CC->CC_004 := (DBFFILE)->CC_004
            CC->(DbUnLock())
            (DBFFILE)->(Reclock(0))
            (DBFFILE)->CC_005 := 0
            (DBFFILE)->(DbUnLock())   
         ELSE
            CC->(FilLock(0))
            CC->(DbAppend())
            CC->CC_001 := (DBFFILE)->CC_001
            CC->CC_002 := (DBFFILE)->CC_002
            CC->CC_003 := (DBFFILE)->CC_003
            CC->CC_004 := (DBFFILE)->CC_004
            CC->(DbUnLock())
            (DBFFILE)->(Reclock(0))
            (DBFFILE)->CC_005 := 0
            (DBFFILE)->(DbUnLock())   
         ENDIF
      CASE (DBFFILE)->CC_005 == 3
         if CC->(Dbseek((DBFFILE)->CC_001))
            CC->(RecLock(0))
            CC->(DbDelete())
            CC->(DbUnLock())
            (DBFFILE)->(Reclock(0))
            (DBFFILE)->CC_005 := 0
            (DBFFILE)->(DbUnLock())   
         endif          
     CASE (DBFFILE)->CC_005 == 4
         if CC->(Dbseek((DBFFILE)->CC_001))
            CC->(RecLock(0))
            CC->(DbRecall())
            CC->(DbUnLock())
            (DBFFILE)->(Reclock(0))
            (DBFFILE)->CC_005 := 0
            (DBFFILE)->(DbUnLock())   
         else     
            CC->(FilLock(0))
            CC->(DbAppend())
            CC->CC_001 := (DBFFILE)->CC_001
            CC->CC_002 := (DBFFILE)->CC_002
            CC->CC_003 := (DBFFILE)->CC_003
            CC->CC_004 := (DBFFILE)->CC_004
            CC->(DbUnLock())
            (DBFFILE)->(Reclock(0))
            (DBFFILE)->CC_005 := 0
            (DBFFILE)->(DbUnLock())
         endif   
   ENDCASE
   (DBFFILE)->(DbSkip())
enddo
GaugeUpdate(hGauge,1)               
@ 13,05 clear to 14,74
@ 13,05 say " Uploading of CARD file FINISHED."
HEYTHERE()
OKDONE()
CloseWindow(wReindex)
DbCloseAll()



/*============================= ITEMS =====================================*/

if !file((UP_PATH)+"I_DOWN.DBF")
   RETURN NIL
endif 

if NetUse("IV",DB_SHARED,NUM_SECONDS)
   set index to IV_LINK
endif   
if NetUse("ITEM.DBF",DB_SHARED,NUM_SECONDS)
      set index to I_001,I_002,I_020,I_033
endif   
if NetUse((UP_PATH)+"I_DOWN",DB_SHARED,NUM_SECONDS)
   DBFFILE := ALIAS()
endif   
if NetUse((UP_PATH)+"IV_DOWN",DB_SHARED,NUM_SECONDS)
   DBFFILE1 := ALIAS()
   INDEX ON (DBFFILE1)->IV_LINK TO IVDOWN
endif   

Message("Uploading Item File....please wait!")
wReindex:=OpenWindow(08,03,15,76,"UPLOAD")
hGauge:=GaugeNew(10,05,12,74,"N/W","N/W",chr(177))
GaugeDisplay(hGauge)
i := 0

(DBFFILE)->(DbGoTop())
Do while (DBFFILE)->(!Eof())
   nPercent:=i++/100
   GaugeUpdate(hGauge,nPercent)            

   DO CASE
      CASE (DBFFILE)->I_039 == 1
       IF !ITEM->(DBSEEK((DBFFILE)->I_001))            
	  ITEM->(FilLock(0))
	  ITEM->(DbAppend())
	  ITEM->I_001 := (DBFFILE)->I_001
	  ITEM->I_002 := (DBFFILE)->I_002
	  ITEM->I_003 := (DBFFILE)->I_003
	  ITEM->I_004 := (DBFFILE)->I_004
	  ITEM->I_005 := (DBFFILE)->I_005
	  ITEM->I_006 := (DBFFILE)->I_006
	  ITEM->I_007 := (DBFFILE)->I_007
	  ITEM->I_008 := (DBFFILE)->I_008
	  ITEM->I_009 := (DBFFILE)->I_009
	  ITEM->I_010 := (DBFFILE)->I_010
	  ITEM->I_011 := (DBFFILE)->I_011
	  ITEM->I_012 := (DBFFILE)->I_012
	  ITEM->I_013 := (DBFFILE)->I_013
	  ITEM->I_014 := (DBFFILE)->I_014
	  ITEM->I_015 := (DBFFILE)->I_015
	  ITEM->I_016 := (DBFFILE)->I_016
	  ITEM->I_017 := (DBFFILE)->I_017
	  ITEM->I_018 := (DBFFILE)->I_018
	  ITEM->I_019 := (DBFFILE)->I_019
	  ITEM->I_020 := (DBFFILE)->I_020
	  ITEM->I_021 := (DBFFILE)->I_021 
	  ITEM->I_022 := (DBFFILE)->I_022
	  ITEM->I_023 := (DBFFILE)->I_023
	  ITEM->I_024 := (DBFFILE)->I_024
	  ITEM->I_025 := (DBFFILE)->I_025
	  ITEM->I_026 := (DBFFILE)->I_026
	  ITEM->I_027 := (DBFFILE)->I_027
	  ITEM->I_028 := (DBFFILE)->I_028
	  ITEM->I_029 := (DBFFILE)->I_029
	  ITEM->I_030 := (DBFFILE)->I_030
	  ITEM->I_031 := (DBFFILE)->I_031
	  ITEM->I_032 := (DBFFILE)->I_032
	  ITEM->I_033 := (DBFFILE)->I_033
	  ITEM->I_034 := (DBFFILE)->I_034
	  ITEM->I_035 := (DBFFILE)->I_035
	  ITEM->I_036 := (DBFFILE)->I_036
	  ITEM->I_037 := (DBFFILE)->I_037
	  ITEM->I_038 := (DBFFILE)->I_038
	  ITEM->(DbUnLock())
	  (DBFFILE)->(Reclock(0))
	  (DBFFILE)->I_039 := 0
	  (DBFFILE)->(DbUnlock())
       endif
	  if (DBFFILE1)->(Dbseek((DBFFILE)->I_001))
  	     Do While (DBFFILE1)->(!Eof()) .and. (DBFFILE1)->IV_LINK == (DBFFILE)->I_001
	     IV->(FilLock(0))
	     IV->(DbAppend())
	     IV->IV_LINK := (DBFFILE1)->IV_LINK
	     IV->IV_CODE := (DBFFILE1)->IV_CODE
	     IV->IV_NAME := (DBFFILE1)->IV_NAME
	     IV->IV_COST := (DBFFILE1)->IV_COST
	     IV->IV_OQTY := (DBFFILE1)->IV_OQTY
	     IV->IV_STCK := (DBFFILE1)->IV_STCK
	     IV->IV_DATE := (DBFFILE1)->IV_DATE
	     IV->(DbUnLock())
	     (DBFFILE1)->(DbSkip())
	     enddo
	  endif   
      CASE (DBFFILE)->I_039 == 2 .OR. (DBFFILE)->I_039 == 5
           IF ITEM->(DBSEEK((DBFFILE)->I_001))          
              ITEM->(RECLOCK(0))
      		  ITEM->I_001 := (DBFFILE)->I_001
      		  ITEM->I_002 := (DBFFILE)->I_002
      		  ITEM->I_003 := (DBFFILE)->I_003
      		  ITEM->I_004 := (DBFFILE)->I_004
      		  ITEM->I_005 := (DBFFILE)->I_005
      		  ITEM->I_006 := (DBFFILE)->I_006
      		  ITEM->I_007 := (DBFFILE)->I_007
      		  ITEM->I_008 := (DBFFILE)->I_008
      		  ITEM->I_009 := (DBFFILE)->I_009
      		  ITEM->I_010 := (DBFFILE)->I_010
      		  ITEM->I_011 := (DBFFILE)->I_011
      		  ITEM->I_012 := (DBFFILE)->I_012
      		  ITEM->I_013 := (DBFFILE)->I_013
      		  ITEM->I_014 := (DBFFILE)->I_014
      		  ITEM->I_015 := (DBFFILE)->I_015
      		  ITEM->I_016 := (DBFFILE)->I_016
      		  ITEM->I_017 := (DBFFILE)->I_017
      		  ITEM->I_018 := (DBFFILE)->I_018
                  ITEM->I_019 := (DBFFILE)->I_019
      		  ITEM->I_020 := (DBFFILE)->I_020
      		  ITEM->I_021 := (DBFFILE)->I_021 
      		  ITEM->I_022 := (DBFFILE)->I_022
      		  ITEM->I_023 := (DBFFILE)->I_023
      		  ITEM->I_024 := (DBFFILE)->I_024
      		  ITEM->I_025 := (DBFFILE)->I_025
      		  ITEM->I_026 := (DBFFILE)->I_026
                  ITEM->I_027 := (DBFFILE)->I_027
      		  ITEM->I_028 := (DBFFILE)->I_028
      		  ITEM->I_029 := (DBFFILE)->I_029
      		  ITEM->I_030 := (DBFFILE)->I_030
      		  ITEM->I_031 := (DBFFILE)->I_031
      		  ITEM->I_032 := (DBFFILE)->I_032
      		  ITEM->I_033 := (DBFFILE)->I_033
      		  ITEM->I_034 := (DBFFILE)->I_034
      		  ITEM->I_035 := (DBFFILE)->I_035
        	  ITEM->I_036 := (DBFFILE)->I_036
      		  ITEM->I_037 := (DBFFILE)->I_037
      		  ITEM->I_038 := (DBFFILE)->I_038
      		  ITEM->(DbUnLock())
      		  (DBFFILE)->(Reclock(0))
      		  (DBFFILE)->I_039 := 0
      		  (DBFFILE)->(DbUnlock())
      		  if (DBFFILE1)->(Dbseek((DBFFILE)->I_001))
      			  Do While (DBFFILE1)->(!Eof()) .and. (DBFFILE1)->IV_LINK == (DBFFILE)->I_001
      				  IV->(RECLOCK(0))
      				  IV->IV_LINK := (DBFFILE1)->IV_LINK
      				  IV->IV_CODE := (DBFFILE1)->IV_CODE
      				  IV->IV_NAME := (DBFFILE1)->IV_NAME
      				  IV->IV_COST := (DBFFILE1)->IV_COST
      				  IV->IV_OQTY := (DBFFILE1)->IV_OQTY
      				  IV->IV_STCK := (DBFFILE1)->IV_STCK
      				  IV->IV_DATE := (DBFFILE1)->IV_DATE
      				  IV->(DbUnLock())
      				  (DBFFILE1)->(DbSkip())
      			  enddo
      		  endif      
           ELSE
		        ITEM->(FilLock(0))
      		  ITEM->(DbAppend())
      		  ITEM->I_001 := (DBFFILE)->I_001
      		  ITEM->I_002 := (DBFFILE)->I_002
      		  ITEM->I_003 := (DBFFILE)->I_003
      		  ITEM->I_004 := (DBFFILE)->I_004
      		  ITEM->I_005 := (DBFFILE)->I_005
      		  ITEM->I_006 := (DBFFILE)->I_006
      		  ITEM->I_007 := (DBFFILE)->I_007
      		  ITEM->I_008 := (DBFFILE)->I_008
      		  ITEM->I_009 := (DBFFILE)->I_009
      		  ITEM->I_010 := (DBFFILE)->I_010
      		  ITEM->I_011 := (DBFFILE)->I_011
      		  ITEM->I_012 := (DBFFILE)->I_012
      		  ITEM->I_013 := (DBFFILE)->I_013
      		  ITEM->I_014 := (DBFFILE)->I_014
      		  ITEM->I_015 := (DBFFILE)->I_015
      		  ITEM->I_016 := (DBFFILE)->I_016
      		  ITEM->I_017 := (DBFFILE)->I_017
      		  ITEM->I_018 := (DBFFILE)->I_018
              ITEM->I_019 := (DBFFILE)->I_019
      		  ITEM->I_020 := (DBFFILE)->I_020
      		  ITEM->I_021 := (DBFFILE)->I_021 
      		  ITEM->I_022 := (DBFFILE)->I_022
      		  ITEM->I_023 := (DBFFILE)->I_023
      		  ITEM->I_024 := (DBFFILE)->I_024
      		  ITEM->I_025 := (DBFFILE)->I_025
      		  ITEM->I_026 := (DBFFILE)->I_026
		        ITEM->I_027 := (DBFFILE)->I_027
      		  ITEM->I_028 := (DBFFILE)->I_028
      		  ITEM->I_029 := (DBFFILE)->I_029
      		  ITEM->I_030 := (DBFFILE)->I_030
      		  ITEM->I_031 := (DBFFILE)->I_031
      		  ITEM->I_032 := (DBFFILE)->I_032
      		  ITEM->I_033 := (DBFFILE)->I_033
      		  ITEM->I_034 := (DBFFILE)->I_034
      		  ITEM->I_035 := (DBFFILE)->I_035
        		  ITEM->I_036 := (DBFFILE)->I_036
      		  ITEM->I_037 := (DBFFILE)->I_037
      		  ITEM->I_038 := (DBFFILE)->I_038
      		  ITEM->(DbUnLock())
      		  (DBFFILE)->(Reclock(0))
      		  (DBFFILE)->I_039 := 0
      		  (DBFFILE)->(DbUnlock())
      		  if (DBFFILE1)->(Dbseek((DBFFILE)->I_001))
      			  Do While (DBFFILE1)->(!Eof()) .and. (DBFFILE1)->IV_LINK == (DBFFILE)->I_001
      				  IV->(FilLock(0))
      				  IV->(DbAppend())
      				  IV->IV_LINK := (DBFFILE1)->IV_LINK
      				  IV->IV_CODE := (DBFFILE1)->IV_CODE
      				  IV->IV_NAME := (DBFFILE1)->IV_NAME
      				  IV->IV_COST := (DBFFILE1)->IV_COST
      				  IV->IV_OQTY := (DBFFILE1)->IV_OQTY
      				  IV->IV_STCK := (DBFFILE1)->IV_STCK
      				  IV->IV_DATE := (DBFFILE1)->IV_DATE
      				  IV->(DbUnLock())
      				  (DBFFILE1)->(DbSkip())
      			  enddo
      		  endif      
           ENDIF  
      CASE (DBFFILE)->I_039 == 3
         if ITEM->(Dbseek((DBFFILE)->I_001))
            ITEM->(RecLock(0))
            ITEM->(DbDelete())
            ITEM->(DbUnLock())
            (DBFFILE)->(Reclock(0))
            (DBFFILE)->I_039 := 0
            (DBFFILE)->(DbUnLock())   
         endif           
      CASE (DBFFILE)->I_039 == 4
         if ITEM->(Dbseek((DBFFILE)->I_001))
           ITEM->(RecLock(0))
           ITEM->(DbRecall())
           ITEM->(DbUnLock())
           (DBFFILE)->(Reclock(0))
           (DBFFILE)->I_039 := 0
           (DBFFILE)->(DbUnLock())   
         ELSE
           ITEM->(FilLock(0))
     		  ITEM->(DbAppend())
   		  ITEM->I_001 := (DBFFILE)->I_001
   		  ITEM->I_002 := (DBFFILE)->I_002
   		  ITEM->I_003 := (DBFFILE)->I_003
   		  ITEM->I_004 := (DBFFILE)->I_004
   		  ITEM->I_005 := (DBFFILE)->I_005
   		  ITEM->I_006 := (DBFFILE)->I_006
   		  ITEM->I_007 := (DBFFILE)->I_007
   		  ITEM->I_008 := (DBFFILE)->I_008
   		  ITEM->I_009 := (DBFFILE)->I_009
   		  ITEM->I_010 := (DBFFILE)->I_010
   		  ITEM->I_011 := (DBFFILE)->I_011
   		  ITEM->I_012 := (DBFFILE)->I_012
   		  ITEM->I_013 := (DBFFILE)->I_013
   		  ITEM->I_014 := (DBFFILE)->I_014
   		  ITEM->I_015 := (DBFFILE)->I_015
   		  ITEM->I_016 := (DBFFILE)->I_016
   		  ITEM->I_017 := (DBFFILE)->I_017
   		  ITEM->I_018 := (DBFFILE)->I_018
   		  ITEM->I_019 := (DBFFILE)->I_019
   		  ITEM->I_020 := (DBFFILE)->I_020
   		  ITEM->I_021 := (DBFFILE)->I_021 
   		  ITEM->I_022 := (DBFFILE)->I_022
   		  ITEM->I_023 := (DBFFILE)->I_023
   		  ITEM->I_024 := (DBFFILE)->I_024
   		  ITEM->I_025 := (DBFFILE)->I_025
   		  ITEM->I_026 := (DBFFILE)->I_026
   		  ITEM->I_027 := (DBFFILE)->I_027
   		  ITEM->I_028 := (DBFFILE)->I_028
   		  ITEM->I_029 := (DBFFILE)->I_029
   		  ITEM->I_030 := (DBFFILE)->I_030
   		  ITEM->I_031 := (DBFFILE)->I_031
   		  ITEM->I_032 := (DBFFILE)->I_032
   		  ITEM->I_033 := (DBFFILE)->I_033
   		  ITEM->I_034 := (DBFFILE)->I_034
   		  ITEM->I_035 := (DBFFILE)->I_035
   		  ITEM->I_036 := (DBFFILE)->I_036
   		  ITEM->I_037 := (DBFFILE)->I_037
   		  ITEM->I_038 := (DBFFILE)->I_038
   		  ITEM->(DbUnLock())
   		  (DBFFILE)->(Reclock(0))
   		  (DBFFILE)->I_039 := 0
   		  (DBFFILE)->(DbUnlock())
   		  if (DBFFILE1)->(Dbseek((DBFFILE)->I_001))
   			  Do While (DBFFILE1)->(!Eof()) .and. (DBFFILE1)->IV_LINK == (DBFFILE)->I_001
   				  IV->(FilLock(0))
   				  IV->(DbAppend())
   				  IV->IV_LINK := (DBFFILE1)->IV_LINK
   				  IV->IV_CODE := (DBFFILE1)->IV_CODE
   				  IV->IV_NAME := (DBFFILE1)->IV_NAME
   				  IV->IV_COST := (DBFFILE1)->IV_COST
   				  IV->IV_OQTY := (DBFFILE1)->IV_OQTY
   				  IV->IV_STCK := (DBFFILE1)->IV_STCK
   				  IV->IV_DATE := (DBFFILE1)->IV_DATE
   				  IV->(DbUnLock())
   				  (DBFFILE1)->(DbSkip())
   			  enddo
	   	  endif   
         endif              
                
    ENDCASE
 
   (DBFFILE)->(DbSkip())
enddo
GaugeUpdate(hGauge,1)               
@ 13,05 clear to 14,74
@ 13,05 say " Uploading of ITEM file FINISHED."
HEYTHERE()
OKDONE()
CloseWindow(wReindex)
DbCloseAll()



/*============================= FM =====================================*/

if !file((UP_PATH)+"FM_DOWN.DBF")
   return nil      
endif 

if NetUse("FM",DB_SHARED,NUM_SECONDS)
      set index to FM
endif
   
if NetUse((UP_PATH)+"FM_DOWN",DB_SHARED,NUM_SECONDS)
   DBFFILE := ALIAS()
endif   

Message("Uploading FM File....please wait!")
wReindex:=OpenWindow(08,03,15,76,"UPLOAD")
hGauge:=GaugeNew(10,05,12,74,"N/W","N/W",chr(177))
GaugeDisplay(hGauge)
i := 0

(DBFFILE)->(DbGoTop())
Do while (DBFFILE)->(!Eof())
   nPercent:=i++/100
   GaugeUpdate(hGauge,nPercent)            


   FM->(FilLock(0))
   FM->(DbAppend())      
   
 /*  if FM->(DbSeek((DBFFILE)->TRANSNO))
      r := FM->(LastRec())
      FM->TRANSNO := r //(DBFFILE)->TRANSNO
   else */
      FM->TRANSNO := (DBFFILE)->TRANSNO   
   // endif 

   FM->OP_CODE := (DBFFILE)->OP_CODE
   FM->FILE_ID := (DBFFILE)->FILE_ID
   FM->RECDATA := (DBFFILE)->RECDATA
   FM->POSTDATE:= (DBFFILE)->POSTDATE
   FM->POSTSTAT:= (DBFFILE)->POSTSTAT
   
   FM->(DbUnLock())
   
   (DBFFILE)->(Reclock(0))
   (DBFFILE)->OP_FLAG := 0
   (DBFFILE)->(DbUnLock())

   (DBFFILE)->(DbSkip())
enddo

GaugeUpdate(hGauge,1)               
@ 13,05 clear to 14,74
@ 13,05 say " Uploading of FM file FINISHED."
HEYTHERE()
OKDONE()
CloseWindow(wReindex)
DbCloseAll()

//added by jzo04-01-98

/*============================= P.O. =====================================*/

if !file((UP_PATH)+"PO_DOWN.DBF")
   return nil
endif

if NetUse("PO",DB_SHARED,NUM_SECONDS)
      set index to PO_001
endif   

if NetUse((UP_PATH)+"PO_DOWN",DB_SHARED,NUM_SECONDS)
      DBFFILE := ALIAS()
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
   Do Case 
      Case (DBFFILE)->PO_018 == 1
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
         endif
      Case (DBFFILE)->PO_018 == 2 .OR. (DBFFILE)->PO_018 == 5
         if PO->(Dbseek((DBFFILE)->PO_001))
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
         else
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
            (DBFFILE)->(DbUnLock())   
         endif   
      Case (DBFFILE)->PO_018 == 3
         if PO->(Dbseek((DBFFILE)->PO_001))
            PO->(RecLock(0))
            PO->(DbDelete())
            PO->(DbUnLock())
            (DBFFILE)->(Reclock(0))
            (DBFFILE)->PO_018 := 0
            (DBFFILE)->(DbUnLock())   
         endif
      Case (DBFFILE)->PO_018 == 4
         if PO->(Dbseek((DBFFILE)->PO_001))
            PO->(RecLock(0))
            PO->(DbRecall())
            PO->(DbUnLock())
            (DBFFILE)->(Reclock(0))
            (DBFFILE)->PO_018 := 0
            (DBFFILE)->(DbUnLock())
         else   
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
            (DBFFILE)->(DbUnLock())   
         endif
   Endcase
   (DBFFILE)->(DbSkip())
enddo
GaugeUpdate(hGauge,1)               
@ 13,05 clear to 14,74
@ 13,05 say " Uploading of I.P. files FINISHED."
HEYTHERE()
OKDONE()
CloseWindow(wReindex)
DbCloseAll()


/*============================= UITEMS =====================================*/

   aUnits := getUnits()

   for y:= 1 to len(aUnits)
      if file((UP_PATH)+"UITEMS"+substr(aUnits[y][1],2,2)+".DBF")
        // RETURN NIL
     //  endif 


      if NetUse("UITEMS",DB_SHARED,NUM_SECONDS)
         set index to UITEMS
      endif   
      if NetUse((UP_PATH)+"UITEMS"+substr(aUnits[y][1],2,2),DB_SHARED,NUM_SECONDS)
         UI_DOWN := ALIAS()
         
      endif   

      Message("Uploading UITEMS File....please wait!")
      wReindex:=OpenWindow(08,03,15,76,"UPLOAD")
      hGauge:=GaugeNew(10,05,12,74,"N/W","N/W",chr(177))
      GaugeDisplay(hGauge)
      i := 0

      (UI_DOWN)->(DbGoTop())
      Do while (UI_DOWN)->(!Eof())
         nPercent:=i++/100
         GaugeUpdate(hGauge,nPercent)            
         DO CASE
            CASE (UI_DOWN)->UI_OP_FLAG == 1
            IF !UITEMS->(DBSEEK((UI_DOWN)->UI_PLUCODE)) 
	       UITEMS->(FilLock(0))
               UITEMS->(DbAppend())
               UITEMS->UI_PLUCODE := (UI_DOWN)->UI_PLUCODE
               UITEMS->UI_STKCODE := (UI_DOWN)->UI_STKCODE
               UITEMS->UI_STK_BAL := (UI_DOWN)->UI_STK_BAL
               UITEMS->UI_BEG_BAL := (UI_DOWN)->UI_BEG_BAL
               UITEMS->UI_MAX_BAL := (UI_DOWN)->UI_MAX_BAL
               UITEMS->UI_MIN_BAL := (UI_DOWN)->UI_MIN_BAL
               UITEMS->UI_REORDER := (UI_DOWN)->UI_REORDER
               UITEMS->UI_P_COUNT := (UI_DOWN)->UI_P_COUNT
               UITEMS->UI_DATEREC := (UI_DOWN)->UI_DATEREC
               UITEMS->UI_STK_OUT := (UI_DOWN)->UI_STK_OUT
               UITEMS->UI_REODATE := (UI_DOWN)->UI_REODATE
               UITEMS->UI_ECRDSLS := (UI_DOWN)->UI_ECRDSLS
               UITEMS->UI_ECRDCNT := (UI_DOWN)->UI_ECRDCNT
               UITEMS->UI_ACCDSLS := (UI_DOWN)->UI_ACCDSLS
               UITEMS->UI_ACCDCNT := (UI_DOWN)->UI_ACCDCNT
               UITEMS->UI_ECRMSLS := (UI_DOWN)->UI_ECRMSLS
               UITEMS->UI_ECRMCNT := (UI_DOWN)->UI_ECRMCNT
               UITEMS->UI_ECRASLS := (UI_DOWN)->UI_ECRASLS
               UITEMS->UI_ECRACNT := (UI_DOWN)->UI_ECRACNT
               UITEMS->UI_DSLRATE := (UI_DOWN)->UI_DSLRATE
               UITEMS->UI_MSLRATE := (UI_DOWN)->UI_MSLRATE
               UITEMS->UI_POSTDTE := (UI_DOWN)->UI_POSTDTE
               UITEMS->(DbUnLock())
               (UI_DOWN)->(Reclock(0))
               (UI_DOWN)->UI_OP_FLAG := 0
               (UI_DOWN)->(DbUnLock())
	    endif   
            CASE (UI_DOWN)->UI_OP_FLAG == 2 .OR. (UI_DOWN)->UI_OP_FLAG == 5
               IF UITEMS->(DBSEEK((UI_DOWN)->UI_PLUCODE))
                  UITEMS->(RecLock(0))
                  UITEMS->UI_PLUCODE := (UI_DOWN)->UI_PLUCODE
                  UITEMS->UI_STKCODE := (UI_DOWN)->UI_STKCODE
                  UITEMS->UI_STK_BAL := (UI_DOWN)->UI_STK_BAL
                  UITEMS->UI_BEG_BAL := (UI_DOWN)->UI_BEG_BAL
                  UITEMS->UI_MAX_BAL := (UI_DOWN)->UI_MAX_BAL
                  UITEMS->UI_MIN_BAL := (UI_DOWN)->UI_MIN_BAL
                  UITEMS->UI_REORDER := (UI_DOWN)->UI_REORDER
                  UITEMS->UI_P_COUNT := (UI_DOWN)->UI_P_COUNT
                  UITEMS->UI_DATEREC := (UI_DOWN)->UI_DATEREC
                  UITEMS->UI_STK_OUT := (UI_DOWN)->UI_STK_OUT
                  UITEMS->UI_REODATE := (UI_DOWN)->UI_REODATE
                  UITEMS->UI_ECRDSLS := (UI_DOWN)->UI_ECRDSLS
                  UITEMS->UI_ECRDCNT := (UI_DOWN)->UI_ECRDCNT
                  UITEMS->UI_ACCDSLS := (UI_DOWN)->UI_ACCDSLS
                  UITEMS->UI_ACCDCNT := (UI_DOWN)->UI_ACCDCNT
                  UITEMS->UI_ECRMSLS := (UI_DOWN)->UI_ECRMSLS
                  UITEMS->UI_ECRMCNT := (UI_DOWN)->UI_ECRMCNT
                  UITEMS->UI_ECRASLS := (UI_DOWN)->UI_ECRASLS
                  UITEMS->UI_ECRACNT := (UI_DOWN)->UI_ECRACNT
                  UITEMS->UI_DSLRATE := (UI_DOWN)->UI_DSLRATE
                  UITEMS->UI_MSLRATE := (UI_DOWN)->UI_MSLRATE
                  UITEMS->UI_POSTDTE := (UI_DOWN)->UI_POSTDTE
                  UITEMS->(DbUnLock())
                  (UI_DOWN)->(Reclock(0))
                  (UI_DOWN)->UI_OP_FLAG := 0
                  (UI_DOWN)->(DbUnLock())   
               ELSE
                  UITEMS->(FilLock(0))
                  UITEMS->(DbAppend())
                  UITEMS->UI_PLUCODE := (UI_DOWN)->UI_PLUCODE
                  UITEMS->UI_STKCODE := (UI_DOWN)->UI_STKCODE
                  UITEMS->UI_STK_BAL := (UI_DOWN)->UI_STK_BAL
                  UITEMS->UI_BEG_BAL := (UI_DOWN)->UI_BEG_BAL
                  UITEMS->UI_MAX_BAL := (UI_DOWN)->UI_MAX_BAL
                  UITEMS->UI_MIN_BAL := (UI_DOWN)->UI_MIN_BAL
                  UITEMS->UI_REORDER := (UI_DOWN)->UI_REORDER
                  UITEMS->UI_P_COUNT := (UI_DOWN)->UI_P_COUNT
                  UITEMS->UI_DATEREC := (UI_DOWN)->UI_DATEREC
                  UITEMS->UI_STK_OUT := (UI_DOWN)->UI_STK_OUT
                  UITEMS->UI_REODATE := (UI_DOWN)->UI_REODATE
                  UITEMS->UI_ECRDSLS := (UI_DOWN)->UI_ECRDSLS
                  UITEMS->UI_ECRDCNT := (UI_DOWN)->UI_ECRDCNT
                  UITEMS->UI_ACCDSLS := (UI_DOWN)->UI_ACCDSLS
                  UITEMS->UI_ACCDCNT := (UI_DOWN)->UI_ACCDCNT
                  UITEMS->UI_ECRMSLS := (UI_DOWN)->UI_ECRMSLS
                  UITEMS->UI_ECRMCNT := (UI_DOWN)->UI_ECRMCNT
                  UITEMS->UI_ECRASLS := (UI_DOWN)->UI_ECRASLS
                  UITEMS->UI_ECRACNT := (UI_DOWN)->UI_ECRACNT
                  UITEMS->UI_DSLRATE := (UI_DOWN)->UI_DSLRATE
                  UITEMS->UI_MSLRATE := (UI_DOWN)->UI_MSLRATE
                  UITEMS->UI_POSTDTE := (UI_DOWN)->UI_POSTDTE
                  UITEMS->(DbUnLock())
                  (UI_DOWN)->(Reclock(0))
                  (UI_DOWN)->UI_OP_FLAG := 0
                  (UI_DOWN)->(DbUnLock())   
               ENDIF   
            CASE (UI_DOWN)->UI_OP_FLAG == 3
               IF UITEMS->(DBSEEK((UI_DOWN)->UI_PLUCODE))
                  UITEMS->(RecLock(0))
                  UITEMS->(DbDelete())
                  UITEMS->(DbUnLock())
                  (UI_DOWN)->(Reclock(0))
                  (UI_DOWN)->UI_OP_FLAG := 0
                  (UI_DOWN)->(DbUnLock())   
               ENDIF   
            CASE (UI_DOWN)->UI_OP_FLAG == 4 
               IF UITEMS->(DBSEEK((UI_DOWN)->UI_PLUCODE))
                  UITEMS->(RecLock(0))
                  UITEMS->(DbRecall())
                  UITEMS->(DbUnLock())
                  (UI_DOWN)->(Reclock(0))
                  (UI_DOWN)->UI_OP_FLAG := 0
                  (UI_DOWN)->(DbUnLock())    
               ELSE
                  UITEMS->(FilLock(0))
                  UITEMS->(DbAppend())
                  UITEMS->UI_PLUCODE := (UI_DOWN)->UI_PLUCODE
                  UITEMS->UI_STKCODE := (UI_DOWN)->UI_STKCODE
                  UITEMS->UI_STK_BAL := (UI_DOWN)->UI_STK_BAL
                  UITEMS->UI_BEG_BAL := (UI_DOWN)->UI_BEG_BAL
                  UITEMS->UI_MAX_BAL := (UI_DOWN)->UI_MAX_BAL
                  UITEMS->UI_MIN_BAL := (UI_DOWN)->UI_MIN_BAL
                  UITEMS->UI_REORDER := (UI_DOWN)->UI_REORDER
                  UITEMS->UI_P_COUNT := (UI_DOWN)->UI_P_COUNT
                  UITEMS->UI_DATEREC := (UI_DOWN)->UI_DATEREC
                  UITEMS->UI_STK_OUT := (UI_DOWN)->UI_STK_OUT
                  UITEMS->UI_REODATE := (UI_DOWN)->UI_REODATE
                  UITEMS->UI_ECRDSLS := (UI_DOWN)->UI_ECRDSLS
                  UITEMS->UI_ECRDCNT := (UI_DOWN)->UI_ECRDCNT
                  UITEMS->UI_ACCDSLS := (UI_DOWN)->UI_ACCDSLS
                  UITEMS->UI_ACCDCNT := (UI_DOWN)->UI_ACCDCNT
                  UITEMS->UI_ECRMSLS := (UI_DOWN)->UI_ECRMSLS
                  UITEMS->UI_ECRMCNT := (UI_DOWN)->UI_ECRMCNT
                  UITEMS->UI_ECRASLS := (UI_DOWN)->UI_ECRASLS
                  UITEMS->UI_ECRACNT := (UI_DOWN)->UI_ECRACNT
                  UITEMS->UI_DSLRATE := (UI_DOWN)->UI_DSLRATE
                  UITEMS->UI_MSLRATE := (UI_DOWN)->UI_MSLRATE
                  UITEMS->UI_POSTDTE := (UI_DOWN)->UI_POSTDTE
                  UITEMS->(DbUnLock())
                  (UI_DOWN)->(Reclock(0))
                  (UI_DOWN)->UI_OP_FLAG := 0
                  (UI_DOWN)->(DbUnLock())   
               ENDIF      
         ENDCASE
         (UI_DOWN)->(DbSkip())
      enddo
      GaugeUpdate(hGauge,1)               
      @ 13,05 clear to 14,74
      @ 13,05 say " Uploading of UITEMS file FINISHED."
      HEYTHERE()
      OKDONE()
      CloseWindow(wReindex)
      DbCloseAll()
    endif
   next

   up_stocks()


if alert("Empty Directory ?", {"YES","NO"}) == 1
   adir := directory((UP_PATH)+"*.DBF")
   Message("Emptying Directory....please wait!")
   aEval(adir, {|x,z| ferase((UP_PATH)+ adir[z][F_NAME]) })
endif


return nil