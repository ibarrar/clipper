#include "Inkey.ch"
#include "Setcurs.ch"
#include "Directry.ch"
#include "Error.ch"
#include "ITS.ch"
#include "Janus.ch"

#define DOWN_PATH  chr(65+curdrv())+":\"+curdir()+"\DOWNLOAD\"   

function Download()
local j
local wReindex,hGauge,cAlias,n,i:=0,nFileCount:=0,nPercent
local adir := {}, aUnits := {}, y := 0, ui_down

if alert("Empty Directory ?", {"YES","NO"}) == 1
   if lastkey() == K_ESC
      return nil
   endif
   adir := directory((DOWN_PATH)+"*.DBF")
   Message("Emptying Directory....please wait!")
   aEval(adir, {|z| ferase((DOWN_PATH)+z[F_NAME]) })
else
   return nil   
endif


/*============================= TERMINAL =====================================*/

if !file((DOWN_PATH)+"TRM_DOWN.DBF")

   if NetUse("TERMINAL",DB_SHARED,NUM_SECONDS)
      set index to TERMINAL
   endif   
   
   copy stru to (DOWN_PATH)+ "TRM_DOWN.DBF"
   TERMINAL->(DbCloseArea())
      
endif 


if NetUse("TERMINAL",DB_SHARED,NUM_SECONDS)
      set index to TERMINAL
endif   
if NetUse((DOWN_PATH)+"TRM_DOWN",DB_SHARED,NUM_SECONDS)
endif   

Message("Downloading TERMINAL File....please wait!")
wReindex:=OpenWindow(08,03,15,76,"DOWNLOAD")
hGauge:=GaugeNew(10,05,12,74,"N/W","N/W",chr(177))
GaugeDisplay(hGauge)
i := 0

TERMINAL->(DbGoTop())
Do while TERMINAL->(!Eof())

   IF TERMINAL->OP_FLAG <> 0
      nPercent:=i++/100
      GaugeUpdate(hGauge,nPercent)            
      TRM_DOWN->(FilLock(0))
      TRM_DOWN->(DbAppend())
      TRM_DOWN->TERM     := TERMINAL->TERM
      TRM_DOWN->DATE     := TERMINAL->DATE
      TRM_DOWN->TIME     := TERMINAL->TIME
      TRM_DOWN->DAILY_C  := TERMINAL->DAILY_C
      TRM_DOWN->DAILY_A  := TERMINAL->DAILY_A
      TRM_DOWN->CASH_A   := TERMINAL->CASH_A
      TRM_DOWN->GROSS_A  := TERMINAL->GROSS_A
      TRM_DOWN->DEPT_A   := TERMINAL->DEPT_A
      TRM_DOWN->FORCUR_C := TERMINAL->FORCUR_C
      TRM_DOWN->FORCUR_A := TERMINAL->FORCUR_A
      TRM_DOWN->MISC1_C  := TERMINAL->MISC1_C
      TRM_DOWN->MISC1_A  := TERMINAL->MISC1_A
      TRM_DOWN->MISC2_C  := TERMINAL->MISC2_C
      TRM_DOWN->MISC2_A  := TERMINAL->MISC2_A
      TRM_DOWN->MISC3_C  := TERMINAL->MISC3_C
      TRM_DOWN->MISC3_A  := TERMINAL->MISC3_A
      TRM_DOWN->MISC4_C  := TERMINAL->MISC4_C
      TRM_DOWN->MISC4_A  := TERMINAL->MISC4_A
      TRM_DOWN->MISC5_C  := TERMINAL->MISC5_C
      TRM_DOWN->MISC5_A  := TERMINAL->MISC5_A                        
      TRM_DOWN->MISC6_C  := TERMINAL->MISC6_C
      TRM_DOWN->MISC6_A  := TERMINAL->MISC6_A
      TRM_DOWN->MISC7_C  := TERMINAL->MISC7_C
      TRM_DOWN->MISC7_A  := TERMINAL->MISC7_A
      TRM_DOWN->MISC8_C  := TERMINAL->MISC8_C
      TRM_DOWN->MISC8_A  := TERMINAL->MISC8_A
      TRM_DOWN->MISC9_C  := TERMINAL->MISC9_C
      TRM_DOWN->MISC9_A  := TERMINAL->MISC9_A
      TRM_DOWN->MISC10_C := TERMINAL->MISC10_C
      TRM_DOWN->MISC10_A  := TERMINAL->MISC10_A                        
      TRM_DOWN->MISC11_C  := TERMINAL->MISC11_C
      TRM_DOWN->MISC11_A  := TERMINAL->MISC11_A
      TRM_DOWN->MISC12_C  := TERMINAL->MISC12_C
      TRM_DOWN->MISC12_A  := TERMINAL->MISC12_A
      TRM_DOWN->MISC13_C  := TERMINAL->MISC13_C
      TRM_DOWN->MISC13_A  := TERMINAL->MISC13_A
      TRM_DOWN->MISC14_C  := TERMINAL->MISC14_C
      TRM_DOWN->MISC14_A  := TERMINAL->MISC14_A
      TRM_DOWN->MISC15_C  := TERMINAL->MISC15_C
      TRM_DOWN->MISC15_A  := TERMINAL->MISC15_A                        
      TRM_DOWN->MISC16_C  := TERMINAL->MISC16_C
      TRM_DOWN->MISC16_A  := TERMINAL->MISC16_A
      TRM_DOWN->MISC17_C  := TERMINAL->MISC17_C
      TRM_DOWN->MISC17_A  := TERMINAL->MISC17_A
      TRM_DOWN->MISC18_C  := TERMINAL->MISC18_C
      TRM_DOWN->MISC18_A  := TERMINAL->MISC18_A
      TRM_DOWN->MISC19_C  := TERMINAL->MISC19_C
      TRM_DOWN->MISC19_A  := TERMINAL->MISC19_A
      TRM_DOWN->MISC20_C  := TERMINAL->MISC20_C
      TRM_DOWN->MISC20_A  := TERMINAL->MISC20_A
      TRM_DOWN->MISC21_C  := TERMINAL->MISC21_C
      TRM_DOWN->MISC21_A  := TERMINAL->MISC21_A
      TRM_DOWN->MISC22_C  := TERMINAL->MISC22_C
      TRM_DOWN->MISC22_A  := TERMINAL->MISC22_A
      TRM_DOWN->MISC23_C  := TERMINAL->MISC23_C
      TRM_DOWN->MISC23_A  := TERMINAL->MISC23_A
      TRM_DOWN->MISC24_C  := TERMINAL->MISC24_C
      TRM_DOWN->MISC24_A  := TERMINAL->MISC24_A
      TRM_DOWN->MISC25_C  := TERMINAL->MISC25_C
      TRM_DOWN->MISC25_A  := TERMINAL->MISC25_A                        
      TRM_DOWN->MISC26_C  := TERMINAL->MISC26_C
      TRM_DOWN->MISC26_A  := TERMINAL->MISC26_A
      TRM_DOWN->MISC27_C  := TERMINAL->MISC27_C
      TRM_DOWN->MISC27_A  := TERMINAL->MISC27_A
      TRM_DOWN->MISC28_C  := TERMINAL->MISC28_C
      TRM_DOWN->MISC28_A  := TERMINAL->MISC28_A
      TRM_DOWN->MISC29_C  := TERMINAL->MISC29_C
      TRM_DOWN->MISC29_A  := TERMINAL->MISC29_A
      TRM_DOWN->MISC30_C  := TERMINAL->MISC30_C
      TRM_DOWN->MISC30_A  := TERMINAL->MISC30_A                        
      TRM_DOWN->MISC31_C  := TERMINAL->MISC31_C
      TRM_DOWN->MISC31_A  := TERMINAL->MISC31_A
      TRM_DOWN->MISC32_C  := TERMINAL->MISC32_C
      TRM_DOWN->MISC32_A  := TERMINAL->MISC32_A
      TRM_DOWN->MISC33_C  := TERMINAL->MISC33_C
      TRM_DOWN->MISC33_A  := TERMINAL->MISC33_A
      TRM_DOWN->MISC34_C  := TERMINAL->MISC34_C
      TRM_DOWN->MISC34_A  := TERMINAL->MISC34_A
      TRM_DOWN->MISC35_C  := TERMINAL->MISC35_C
      TRM_DOWN->MISC35_A  := TERMINAL->MISC35_A  
      TRM_DOWN->MISC36_C  := TERMINAL->MISC36_C
      TRM_DOWN->MISC36_A  := TERMINAL->MISC36_A                        
      TRM_DOWN->MISC37_C  := TERMINAL->MISC37_C
      TRM_DOWN->MISC37_A  := TERMINAL->MISC37_A
      TRM_DOWN->MISC38_C  := TERMINAL->MISC38_C
      TRM_DOWN->MISC38_A  := TERMINAL->MISC38_A
      TRM_DOWN->MISC39_C  := TERMINAL->MISC39_C
      TRM_DOWN->MISC39_A  := TERMINAL->MISC39_A
      TRM_DOWN->MISC40_C  := TERMINAL->MISC40_C
      TRM_DOWN->MISC40_A  := TERMINAL->MISC40_A
      TRM_DOWN->MISC41_C  := TERMINAL->MISC41_C
      TRM_DOWN->MISC41_A  := TERMINAL->MISC41_A                        
      TRM_DOWN->MISC42_C  := TERMINAL->MISC42_C
      TRM_DOWN->MISC42_A  := TERMINAL->MISC42_A
      TRM_DOWN->MISC43_C  := TERMINAL->MISC43_C
      TRM_DOWN->MISC43_A  := TERMINAL->MISC43_A
      TRM_DOWN->MISC44_C  := TERMINAL->MISC44_C
      TRM_DOWN->MISC44_A  := TERMINAL->MISC44_A
      TRM_DOWN->MISC45_C  := TERMINAL->MISC45_C
      TRM_DOWN->MISC45_A  := TERMINAL->MISC45_A
      TRM_DOWN->MISC46_C  := TERMINAL->MISC46_C
      TRM_DOWN->MISC46_A  := TERMINAL->MISC46_A                                                
      TRM_DOWN->MISC47_C  := TERMINAL->MISC47_C
      TRM_DOWN->MISC47_A  := TERMINAL->MISC47_A                        
      TRM_DOWN->MISC48_C  := TERMINAL->MISC48_C
      TRM_DOWN->MISC48_A  := TERMINAL->MISC48_A
      TRM_DOWN->MISC49_C  := TERMINAL->MISC49_C
      TRM_DOWN->MISC49_A  := TERMINAL->MISC49_A
      TRM_DOWN->MISC50_C  := TERMINAL->MISC50_C
      TRM_DOWN->MISC50_A  := TERMINAL->MISC50_A
      TRM_DOWN->IVOID_C   := TERMINAL->IVOID_C
      TRM_DOWN->IVOID_A   := TERMINAL->IVOID_A
      TRM_DOWN->MVOID_C   := TERMINAL->MVOID_C
      TRM_DOWN->MVOID_A   := TERMINAL->MVOID_A                                                
      TRM_DOWN->IDISC_C   := TERMINAL->IDISC_C
      TRM_DOWN->IDISC_A   := TERMINAL->IDISC_A
      TRM_DOWN->SUBTD_C   := TERMINAL->SUBTD_C
      TRM_DOWN->SUBTD_A   := TERMINAL->SUBTD_A                                                
      TRM_DOWN->ADDON_C   := TERMINAL->ADDON_C
      TRM_DOWN->ADDON_A   := TERMINAL->ADDON_A
      TRM_DOWN->SSBTD_C   := TERMINAL->SSBTD_C
      TRM_DOWN->SSBTD_A   := TERMINAL->SSBTD_A                                                
      TRM_DOWN->SSBTA_C   := TERMINAL->SSBTA_C
      TRM_DOWN->SSBTA_A   := TERMINAL->SSBTA_A
      TRM_DOWN->RETRN_C   := TERMINAL->RETRN_C
      TRM_DOWN->RETRN_A   := TERMINAL->RETRN_A                                                
      TRM_DOWN->REFND_C   := TERMINAL->REFND_C
      TRM_DOWN->REFND_A   := TERMINAL->REFND_A
      TRM_DOWN->OTINC_C   := TERMINAL->OTINC_C
      TRM_DOWN->OTINC_A   := TERMINAL->OTINC_A                                                
      TRM_DOWN->CANCL_C   := TERMINAL->CANCL_C
      TRM_DOWN->CANCL_A   := TERMINAL->CANCL_A
      TRM_DOWN->TVOID_C   := TERMINAL->TVOID_C
      TRM_DOWN->TVOID_A   := TERMINAL->TVOID_A                                                
      TRM_DOWN->SUSPD_C   := TERMINAL->SUSPD_C
      TRM_DOWN->SUSPD_A   := TERMINAL->SUSPD_A
      TRM_DOWN->LAYAW_C   := TERMINAL->LAYAW_C
      TRM_DOWN->LAYAW_A   := TERMINAL->LAYAW_A                                                
      TRM_DOWN->PIKUP_C   := TERMINAL->PIKUP_C
      TRM_DOWN->PIKUP_A   := TERMINAL->PIKUP_A
      TRM_DOWN->PDOUT_C   := TERMINAL->PDOUT_C
      TRM_DOWN->PDOUT_A   := TERMINAL->PDOUT_A                                                
      TRM_DOWN->LOAN_C    := TERMINAL->LOAN_C
      TRM_DOWN->LOAN_A    := TERMINAL->LOAN_A
      TRM_DOWN->RECACT_C  := TERMINAL->RECACT_C
      TRM_DOWN->RECACT_A  := TERMINAL->RECACT_A                                                
      TRM_DOWN->BOTDEP_C  := TERMINAL->BOTDEP_C
      TRM_DOWN->BOTDEP_A  := TERMINAL->BOTDEP_A
      TRM_DOWN->TRAIN_A   := TERMINAL->TRAIN_A
      TRM_DOWN->OFFLN_A   := TERMINAL->OFFLN_A                                                
      TRM_DOWN->RENTER_A  := TERMINAL->RENTER_A
      TRM_DOWN->OLDGRD_A  := TERMINAL->OLDGRD_A
      TRM_DOWN->NEWGRD_A  := TERMINAL->NEWGRD_A
      TRM_DOWN->XCOUNT_C  := TERMINAL->XCOUNT_C                                                
      TRM_DOWN->ZCOUNT_C  := TERMINAL->ZCOUNT_C                                                
      TRM_DOWN->OP_FLAG   := TERMINAL->OP_FLAG                                                
      TRM_DOWN->(DbUnLock())
      TERMINAL->(Reclock(0))
      TERMINAL->OP_FLAG := 0
      TERMINAL->(DbUnlock())
   ENDIF
   
   TERMINAL->(DbSkip())
enddo
GaugeUpdate(hGauge,1)               
@ 13,05 clear to 14,74
@ 13,05 say " Downloading of TERMINAL file FINISHED."
HEYTHERE()
OKDONE()
CloseWindow(wReindex)
DbCloseAll()


/*============================= CASHIER =====================================*/

if !file((DOWN_PATH)+"CAS_DOWN.DBF")

   if NetUse("CASH",DB_SHARED,NUM_SECONDS)
      set index to CAS
   endif   
   
   copy stru to (DOWN_PATH)+ "CAS_DOWN.DBF"
   CASH->(DbCloseArea())
      
endif 


if NetUse("CASH",DB_SHARED,NUM_SECONDS)
      set index to CAS
endif   
if NetUse((DOWN_PATH)+"CAS_DOWN",DB_SHARED,NUM_SECONDS)
endif   

Message("Downloading CASH File....please wait!")
wReindex:=OpenWindow(08,03,15,76,"DOWNLOAD")
hGauge:=GaugeNew(10,05,12,74,"N/W","N/W",chr(177))
GaugeDisplay(hGauge)
i := 0

CASH->(DbGoTop())
Do while CASH->(!Eof())

   IF CASH->OP_FLAG <> 0
      nPercent:=i++/100
      GaugeUpdate(hGauge,nPercent)            
      CAS_DOWN->(FilLock(0))
      CAS_DOWN->(DbAppend())
      CAS_DOWN->TERM     := CASH->TERM
      CAS_DOWN->DATE     := CASH->DATE
      CAS_DOWN->TIME     := CASH->TIME
      CAS_DOWN->CODE     := CASH->CODE
      CAS_DOWN->NAME     := CASH->NAME
      CAS_DOWN->DAILY_C  := CASH->DAILY_C
      CAS_DOWN->DAILY_A  := CASH->DAILY_A
      CAS_DOWN->CASH_A   := CASH->CASH_A
      CAS_DOWN->GROSS_A  := CASH->GROSS_A
      CAS_DOWN->DEPT_A   := CASH->DEPT_A
      CAS_DOWN->FORCUR_C := CASH->FORCUR_C
      CAS_DOWN->FORCUR_A := CASH->FORCUR_A
      CAS_DOWN->MISC01_C  := CASH->MISC01_C
      CAS_DOWN->MISC01_A  := CASH->MISC01_A
      CAS_DOWN->MISC02_C  := CASH->MISC02_C
      CAS_DOWN->MISC02_A  := CASH->MISC02_A
      CAS_DOWN->MISC03_C  := CASH->MISC03_C
      CAS_DOWN->MISC03_A  := CASH->MISC03_A
      CAS_DOWN->MISC04_C  := CASH->MISC04_C
      CAS_DOWN->MISC04_A  := CASH->MISC04_A
      CAS_DOWN->MISC05_C  := CASH->MISC05_C
      CAS_DOWN->MISC05_A  := CASH->MISC05_A                        
      CAS_DOWN->MISC06_C  := CASH->MISC06_C
      CAS_DOWN->MISC06_A  := CASH->MISC06_A
      CAS_DOWN->MISC07_C  := CASH->MISC07_C
      CAS_DOWN->MISC07_A  := CASH->MISC07_A
      CAS_DOWN->MISC08_C  := CASH->MISC08_C
      CAS_DOWN->MISC08_A  := CASH->MISC08_A
      CAS_DOWN->MISC09_C  := CASH->MISC09_C
      CAS_DOWN->MISC09_A  := CASH->MISC09_A
      CAS_DOWN->MISC10_C := CASH->MISC10_C
      CAS_DOWN->MISC10_A  := CASH->MISC10_A                        
      CAS_DOWN->MISC11_C  := CASH->MISC11_C
      CAS_DOWN->MISC11_A  := CASH->MISC11_A
      CAS_DOWN->MISC12_C  := CASH->MISC12_C
      CAS_DOWN->MISC12_A  := CASH->MISC12_A
      CAS_DOWN->MISC13_C  := CASH->MISC13_C
      CAS_DOWN->MISC13_A  := CASH->MISC13_A
      CAS_DOWN->MISC14_C  := CASH->MISC14_C
      CAS_DOWN->MISC14_A  := CASH->MISC14_A
      CAS_DOWN->MISC15_C  := CASH->MISC15_C
      CAS_DOWN->MISC15_A  := CASH->MISC15_A                        
      CAS_DOWN->MISC16_C  := CASH->MISC16_C
      CAS_DOWN->MISC16_A  := CASH->MISC16_A
      CAS_DOWN->MISC17_C  := CASH->MISC17_C
      CAS_DOWN->MISC17_A  := CASH->MISC17_A
      CAS_DOWN->MISC18_C  := CASH->MISC18_C
      CAS_DOWN->MISC18_A  := CASH->MISC18_A
      CAS_DOWN->MISC19_C  := CASH->MISC19_C
      CAS_DOWN->MISC19_A  := CASH->MISC19_A
      CAS_DOWN->MISC20_C  := CASH->MISC20_C
      CAS_DOWN->MISC20_A  := CASH->MISC20_A
      CAS_DOWN->MISC21_C  := CASH->MISC21_C
      CAS_DOWN->MISC21_A  := CASH->MISC21_A
      CAS_DOWN->MISC22_C  := CASH->MISC22_C
      CAS_DOWN->MISC22_A  := CASH->MISC22_A
      CAS_DOWN->MISC23_C  := CASH->MISC23_C
      CAS_DOWN->MISC23_A  := CASH->MISC23_A
      CAS_DOWN->MISC24_C  := CASH->MISC24_C
      CAS_DOWN->MISC24_A  := CASH->MISC24_A
      CAS_DOWN->MISC25_C  := CASH->MISC25_C
      CAS_DOWN->MISC25_A  := CASH->MISC25_A                        
      CAS_DOWN->MISC26_C  := CASH->MISC26_C
      CAS_DOWN->MISC26_A  := CASH->MISC26_A
      CAS_DOWN->MISC27_C  := CASH->MISC27_C
      CAS_DOWN->MISC27_A  := CASH->MISC27_A
      CAS_DOWN->MISC28_C  := CASH->MISC28_C
      CAS_DOWN->MISC28_A  := CASH->MISC28_A
      CAS_DOWN->MISC29_C  := CASH->MISC29_C
      CAS_DOWN->MISC29_A  := CASH->MISC29_A
      CAS_DOWN->MISC30_C  := CASH->MISC30_C
      CAS_DOWN->MISC30_A  := CASH->MISC30_A                        
      CAS_DOWN->MISC31_C  := CASH->MISC31_C
      CAS_DOWN->MISC31_A  := CASH->MISC31_A
      CAS_DOWN->MISC32_C  := CASH->MISC32_C
      CAS_DOWN->MISC32_A  := CASH->MISC32_A
      CAS_DOWN->MISC33_C  := CASH->MISC33_C
      CAS_DOWN->MISC33_A  := CASH->MISC33_A
      CAS_DOWN->MISC34_C  := CASH->MISC34_C
      CAS_DOWN->MISC34_A  := CASH->MISC34_A
      CAS_DOWN->MISC35_C  := CASH->MISC35_C
      CAS_DOWN->MISC35_A  := CASH->MISC35_A  
      CAS_DOWN->MISC36_C  := CASH->MISC36_C
      CAS_DOWN->MISC36_A  := CASH->MISC36_A                        
      CAS_DOWN->MISC37_C  := CASH->MISC37_C
      CAS_DOWN->MISC37_A  := CASH->MISC37_A
      CAS_DOWN->MISC38_C  := CASH->MISC38_C
      CAS_DOWN->MISC38_A  := CASH->MISC38_A
      CAS_DOWN->MISC39_C  := CASH->MISC39_C
      CAS_DOWN->MISC39_A  := CASH->MISC39_A
      CAS_DOWN->MISC40_C  := CASH->MISC40_C
      CAS_DOWN->MISC40_A  := CASH->MISC40_A
      CAS_DOWN->MISC41_C  := CASH->MISC41_C
      CAS_DOWN->MISC41_A  := CASH->MISC41_A                        
      CAS_DOWN->MISC42_C  := CASH->MISC42_C
      CAS_DOWN->MISC42_A  := CASH->MISC42_A
      CAS_DOWN->MISC43_C  := CASH->MISC43_C
      CAS_DOWN->MISC43_A  := CASH->MISC43_A
      CAS_DOWN->MISC44_C  := CASH->MISC44_C
      CAS_DOWN->MISC44_A  := CASH->MISC44_A
      CAS_DOWN->MISC45_C  := CASH->MISC45_C
      CAS_DOWN->MISC45_A  := CASH->MISC45_A
      CAS_DOWN->MISC46_C  := CASH->MISC46_C
      CAS_DOWN->MISC46_A  := CASH->MISC46_A                                                
      CAS_DOWN->MISC47_C  := CASH->MISC47_C
      CAS_DOWN->MISC47_A  := CASH->MISC47_A                        
      CAS_DOWN->MISC48_C  := CASH->MISC48_C
      CAS_DOWN->MISC48_A  := CASH->MISC48_A
      CAS_DOWN->MISC49_C  := CASH->MISC49_C
      CAS_DOWN->MISC49_A  := CASH->MISC49_A
      CAS_DOWN->MISC50_C  := CASH->MISC50_C
      CAS_DOWN->MISC50_A  := CASH->MISC50_A
      CAS_DOWN->IVOID_C   := CASH->IVOID_C
      CAS_DOWN->IVOID_A   := CASH->IVOID_A
      CAS_DOWN->MVOID_C   := CASH->MVOID_C
      CAS_DOWN->MVOID_A   := CASH->MVOID_A                                                
      CAS_DOWN->IDISC_C   := CASH->IDISC_C
      CAS_DOWN->IDISC_A   := CASH->IDISC_A
      CAS_DOWN->SUBTD_C   := CASH->SUBTD_C
      CAS_DOWN->SUBTD_A   := CASH->SUBTD_A                                                
      CAS_DOWN->ADDON_C   := CASH->ADDON_C
      CAS_DOWN->ADDON_A   := CASH->ADDON_A
      CAS_DOWN->SSBTD_C   := CASH->SSBTD_C
      CAS_DOWN->SSBTD_A   := CASH->SSBTD_A                                                
      CAS_DOWN->SSBTA_C   := CASH->SSBTA_C
      CAS_DOWN->SSBTA_A   := CASH->SSBTA_A
      CAS_DOWN->RETRN_C   := CASH->RETRN_C
      CAS_DOWN->RETRN_A   := CASH->RETRN_A                                                
      CAS_DOWN->REFND_C   := CASH->REFND_C
      CAS_DOWN->REFND_A   := CASH->REFND_A
      CAS_DOWN->OTINC_C   := CASH->OTINC_C
      CAS_DOWN->OTINC_A   := CASH->OTINC_A                                                
      CAS_DOWN->CANCL_C   := CASH->CANCL_C
      CAS_DOWN->CANCL_A   := CASH->CANCL_A
      CAS_DOWN->TVOID_C   := CASH->TVOID_C
      CAS_DOWN->TVOID_A   := CASH->TVOID_A                                                
      CAS_DOWN->SUSPD_C   := CASH->SUSPD_C
      CAS_DOWN->SUSPD_A   := CASH->SUSPD_A
      CAS_DOWN->LAYAW_C   := CASH->LAYAW_C
      CAS_DOWN->LAYAW_A   := CASH->LAYAW_A                                                
      CAS_DOWN->PIKUP_C   := CASH->PIKUP_C
      CAS_DOWN->PIKUP_A   := CASH->PIKUP_A
      CAS_DOWN->PDOUT_C   := CASH->PDOUT_C
      CAS_DOWN->PDOUT_A   := CASH->PDOUT_A                                                
      CAS_DOWN->LOAN_C    := CASH->LOAN_C
      CAS_DOWN->LOAN_A    := CASH->LOAN_A
      CAS_DOWN->RECACT_C  := CASH->RECACT_C
      CAS_DOWN->RECACT_A  := CASH->RECACT_A                                                
      CAS_DOWN->BOTDEP_C  := CASH->BOTDEP_C
      CAS_DOWN->BOTDEP_A  := CASH->BOTDEP_A
      CAS_DOWN->CASHDEC   := CASH->CASHDEC
      CAS_DOWN->TRAIN_A   := CASH->TRAIN_A
      CAS_DOWN->OFFLN_A   := CASH->OFFLN_A                                                
      CAS_DOWN->RENTER_A  := CASH->RENTER_A
      CAS_DOWN->OLDGRD_A  := CASH->OLDGRD_A
      CAS_DOWN->NEWGRD_A  := CASH->NEWGRD_A
      CAS_DOWN->XCOUNT_C  := CASH->XCOUNT_C                                                
      CAS_DOWN->ZCOUNT_C  := CASH->ZCOUNT_C                                                
      CAS_DOWN->OP_FLAG   := CASH->OP_FLAG                                                
      CAS_DOWN->(DbUnLock())
      CASH->(Reclock(0))
      CASH->OP_FLAG := 0
      CASH->(DbUnlock())
   ENDIF
   
   CASH->(DbSkip())
enddo
GaugeUpdate(hGauge,1)               
@ 13,05 clear to 14,74
@ 13,05 say " Downloading of CASH file FINISHED."
HEYTHERE()
OKDONE()
CloseWindow(wReindex)
DbCloseAll()


/*============================= PLU =====================================*/

if !file((DOWN_PATH)+"PLU_DOWN.DBF")

   if NetUse("PLU",DB_SHARED,NUM_SECONDS)
      set index to PLU
   endif   
   
   copy stru to (DOWN_PATH)+ "PLU_DOWN.DBF"
   PLU->(DbCloseArea())
      
endif 


if NetUse("PLU",DB_SHARED,NUM_SECONDS)
      set index to PLU
endif   
if NetUse((DOWN_PATH)+"PLU_DOWN",DB_SHARED,NUM_SECONDS)
endif   

Message("Downloading PLU File....please wait!")
wReindex:=OpenWindow(08,03,15,76,"DOWNLOAD")
hGauge:=GaugeNew(10,05,12,74,"N/W","N/W",chr(177))
GaugeDisplay(hGauge)
i := 0

PLU->(DbGoTop())
Do while PLU->(!Eof())
   IF PLU->OP_FLAG <> 0
      nPercent:=i++/100
      GaugeUpdate(hGauge,nPercent)            
      PLU_DOWN->(FilLock(0))
      PLU_DOWN->(DbAppend())
      PLU_DOWN->DATE      := PLU->DATE
      PLU_DOWN->CODE      := PLU->CODE
      PLU_DOWN->ITEM_CODE := PLU->ITEM_CODE
      PLU_DOWN->DESC      := PLU->DESC
      PLU_DOWN->ICOUNT    := PLU->ICOUNT
      PLU_DOWN->IAMOUNT   := PLU->IAMOUNT
      PLU_DOWN->I_UCOST   := PLU->I_UCOST
//      PLU_DOWN->WCOUNT    := PLU->WCOUNT
//      PLU_DOWN->WAMOUNT   := PLU->WAMOUNT
//      PLU_DOWN->W_UCOST   := PLU->W_UCOST
      PLU_DOWN->OP_FLAG   := PLU->OP_FLAG
      PLU_DOWN->(DbUnLock())
      PLU->(Reclock(0))
      PLU->OP_FLAG := 0
      PLU->(DbUnLock())
   ENDIF
   PLU->(DbSkip())
enddo
GaugeUpdate(hGauge,1)               
@ 13,05 clear to 14,74
@ 13,05 say " Downloading of PLU file FINISHED."
HEYTHERE()
OKDONE()
CloseWindow(wReindex)
DbCloseAll()

/*============================= NPLU =====================================*/

if !file((DOWN_PATH)+"NPLU_DWN.DBF")

   if NetUse("NPLU",DB_SHARED,NUM_SECONDS)
      set index to NPLU
   endif   
   
   copy stru to (DOWN_PATH)+ "NPLU_DWN.DBF"
   NPLU->(DbCloseArea())
      
endif 


if NetUse("NPLU",DB_SHARED,NUM_SECONDS)
      set index to NPLU
endif   
if NetUse((DOWN_PATH)+"NPLU_DWN",DB_SHARED,NUM_SECONDS)
endif   

Message("Downloading NPLU File....please wait!")
wReindex:=OpenWindow(08,03,15,76,"DOWNLOAD")
hGauge:=GaugeNew(10,05,12,74,"N/W","N/W",chr(177))
GaugeDisplay(hGauge)
i := 0

NPLU->(DbGoTop())
Do while NPLU->(!Eof())
   IF NPLU->OP_FLAG <> 0
      nPercent:=i++/100
      GaugeUpdate(hGauge,nPercent)            
      NPLU_DWN->(FilLock(0))
      NPLU_DWN->(DbAppend())
      NPLU_DWN->DATE      := NPLU->DATE
      NPLU_DWN->CODE      := NPLU->CODE
      NPLU_DWN->ICOUNT    := NPLU->ICOUNT
      NPLU_DWN->IAMOUNT   := NPLU->IAMOUNT
      NPLU_DWN->I_UCOST   := NPLU->I_UCOST
//      NPLU_DWN->WCOUNT    := NPLU->WCOUNT
//      NPLU_DWN->WAMOUNT   := NPLU->WAMOUNT
//      NPLU_DWN->W_UCOST   := NPLU->W_UCOST
      NPLU_DWN->OP_FLAG   := NPLU->OP_FLAG
      NPLU_DWN->(DbUnLock())
      NPLU->(Reclock(0))
      NPLU->OP_FLAG := 0
      NPLU->(DbUnLock())
   ENDIF
   NPLU->(DbSkip())
enddo
GaugeUpdate(hGauge,1)               
@ 13,05 clear to 14,74
@ 13,05 say " Downloading of NPLU file FINISHED."
HEYTHERE()
OKDONE()
CloseWindow(wReindex)
DbCloseAll()



/*============================= RETURN =====================================*/

if !file((DOWN_PATH)+"RET_DOWN.DBF")

   if NetUse("RET",DB_SHARED,NUM_SECONDS)
      set index to RET
   endif   
   
   copy stru to (DOWN_PATH)+ "RET_DOWN.DBF"
   RET->(DbCloseArea())
      
endif 


if NetUse("RET",DB_SHARED,NUM_SECONDS)
      set index to RET
endif   
if NetUse((DOWN_PATH)+"RET_DOWN",DB_SHARED,NUM_SECONDS)
endif   

Message("Downloading RETURN File....please wait!")
wReindex:=OpenWindow(08,03,15,76,"DOWNLOAD")
hGauge:=GaugeNew(10,05,12,74,"N/W","N/W",chr(177))
GaugeDisplay(hGauge)
i := 0

RET->(DbGoTop())
Do while RET->(!Eof())
   IF RET->OP_FLAG <> 0
      nPercent:=i++/100
      GaugeUpdate(hGauge,nPercent)            
      RET_DOWN->(FilLock(0))
      RET_DOWN->(DbAppend())
      RET_DOWN->DATE     := RET->DATE
      RET_DOWN->PLUCODE  := RET->PLUCODE
      RET_DOWN->ITEMCODE := RET->ITEMCODE
      RET_DOWN->RDESC    := RET->RDESC
      RET_DOWN->RCOUNT   := RET->RCOUNT
      RET_DOWN->RAMOUNT  := RET->RAMOUNT
      RET_DOWN->RUCOST   := RET->RUCOST
      RET_DOWN->OP_FLAG  := RET->OP_FLAG
      RET_DOWN->(DbUnLock())
      RET->(Reclock(0))
      RET->OP_FLAG := 0
      RET->(DbUnLock())
   ENDIF
   RET->(DbSkip())
enddo
GaugeUpdate(hGauge,1)               
@ 13,05 clear to 14,74
@ 13,05 say " Downloading of RETURN file FINISHED."
HEYTHERE()
OKDONE()
CloseWindow(wReindex)
DbCloseAll()


/*============================= DEPT =====================================*/

if !file((DOWN_PATH)+"DEPT_DOWN.DBF")

   if NetUse("DEPT",DB_SHARED,NUM_SECONDS)
      set index to DEPT
   endif   
   
   copy stru to (DOWN_PATH)+ "DEPT_DOWN.DBF"
   DEPT->(DbCloseArea())
      
endif 


if NetUse("DEPT",DB_SHARED,NUM_SECONDS)
      set index to DEPT
endif   
if NetUse((DOWN_PATH)+"DEPT_DOWN",DB_SHARED,NUM_SECONDS)
endif   

Message("Downloading DEPARTMENT File....please wait!")
wReindex:=OpenWindow(08,03,15,76,"DOWNLOAD")
hGauge:=GaugeNew(10,05,12,74,"N/W","N/W",chr(177))
GaugeDisplay(hGauge)
i := 0

DEPT->(DbGoTop())
Do while DEPT->(!Eof())
   IF DEPT->OP_FLAG <> 0
      nPercent:=i++/100
      GaugeUpdate(hGauge,nPercent)            
      DEPT_DOWN->(FilLock(0))
      DEPT_DOWN->(DbAppend())
      DEPT_DOWN->DATE     := DEPT->DATE
      DEPT_DOWN->DCODE    := DEPT->DCODE
      DEPT_DOWN->DDESC    := DEPT->DDESC
      DEPT_DOWN->DCOUNT   := DEPT->DCOUNT
      DEPT_DOWN->DAMOUNT  := DEPT->DAMOUNT
      DEPT_DOWN->OP_FLAG  := DEPT->OP_FLAG
      DEPT_DOWN->(DbUnLock())
      DEPT->(Reclock(0))
      DEPT->OP_FLAG := 0
      DEPT->(DbUnLock())
   ENDIF
   DEPT->(DbSkip())
enddo
GaugeUpdate(hGauge,1)               
@ 13,05 clear to 14,74
@ 13,05 say " Downloading of DEPARTMENT file FINISHED."
HEYTHERE()
OKDONE()
CloseWindow(wReindex)
DbCloseAll()


/*============================= HOUR =====================================*/

if !file((DOWN_PATH)+"HOUR_DOWN.DBF")

   if NetUse("HOUR",DB_SHARED,NUM_SECONDS)
      set index to HOUR
   endif   
   
   copy stru to (DOWN_PATH)+ "HOUR_DOWN.DBF"
   HOUR->(DbCloseArea())
      
endif 


if NetUse("HOUR",DB_SHARED,NUM_SECONDS)
      set index to HOUR
endif   
if NetUse((DOWN_PATH)+"HOUR_DOWN",DB_SHARED,NUM_SECONDS)
endif   

Message("Downloading HOUR File....please wait!")
wReindex:=OpenWindow(08,03,15,76,"DOWNLOAD")
hGauge:=GaugeNew(10,05,12,74,"N/W","N/W",chr(177))
GaugeDisplay(hGauge)
i := 0

HOUR->(DbGoTop())
Do while HOUR->(!Eof())
   IF HOUR->OP_FLAG <> 0
      nPercent:=i++/100
      GaugeUpdate(hGauge,nPercent)            
      HOUR_DOWN->(FilLock(0))
      HOUR_DOWN->(DbAppend())
      HOUR_DOWN->TERM     := HOUR->TERM
      HOUR_DOWN->DATE     := HOUR->DATE
      HOUR_DOWN->TIME     := HOUR->TIME
      HOUR_DOWN->HOUR     := HOUR->HOUR
      HOUR_DOWN->HCOUNT   := HOUR->HCOUNT
      HOUR_DOWN->HAMOUNT  := HOUR->HAMOUNT
      HOUR_DOWN->OP_FLAG  := HOUR->OP_FLAG
      HOUR_DOWN->(DbUnLock())
      HOUR->(Reclock(0))
      HOUR->OP_FLAG := 0
      HOUR->(DbUnLock())
   ENDIF
   HOUR->(DbSkip())
enddo
GaugeUpdate(hGauge,1)               
@ 13,05 clear to 14,74
@ 13,05 say " Downloading of HOUR file FINISHED."
HEYTHERE()
OKDONE()
CloseWindow(wReindex)
DbCloseAll()


/*============================= CCD =====================================*/

if !file((DOWN_PATH)+"CCD_DOWN.DBF")

   if NetUse("CCD",DB_SHARED,NUM_SECONDS)
      set index to CCD
   endif   
   
   copy stru to (DOWN_PATH)+ "CCD_DOWN.DBF"
   CCD->(DbCloseArea())
      
endif 


if NetUse("CCD",DB_SHARED,NUM_SECONDS)
      set index to CCD
endif   
if NetUse((DOWN_PATH)+"CCD_DOWN",DB_SHARED,NUM_SECONDS)
endif   

Message("Downloading CCD File....please wait!")
wReindex:=OpenWindow(08,03,15,76,"DOWNLOAD")
hGauge:=GaugeNew(10,05,12,74,"N/W","N/W",chr(177))
GaugeDisplay(hGauge)
i := 0

CCD->(DbGoTop())
Do while CCD->(!Eof())
   IF CCD->OP_FLAG <> 0
      nPercent:=i++/100
      GaugeUpdate(hGauge,nPercent)            
      CCD_DOWN->(FilLock(0))
      CCD_DOWN->(DbAppend())
      CCD_DOWN->DATE     := CCD->DATE
      CCD_DOWN->TERM     := CCD->TERM
      CCD_DOWN->CASH_CODE:= CCD->CASH_CODE
      CCD_DOWN->BANK_CODE:= CCD->BANK_CODE
      CCD_DOWN->CCD_COUNT:= CCD->CCD_COUNT
      CCD_DOWN->DENOM    := CCD->DENOM
      CCD_DOWN->CCD_AMOUNT:= CCD->CCD_AMOUNT
      CCD_DOWN->OP_FLAG  := CCD->OP_FLAG
      CCD_DOWN->(DbUnLock())
      CCD->(Reclock(0))
      CCD->OP_FLAG := 0
      CCD->(DbUnLock())
   ENDIF
   CCD->(DbSkip())
enddo
GaugeUpdate(hGauge,1)               
@ 13,05 clear to 14,74
@ 13,05 say " Downloading of DEPARTMENT file FINISHED."
HEYTHERE()
OKDONE()
CloseWindow(wReindex)
DbCloseAll()


/*============================= CHARGE =====================================*/

if !file((DOWN_PATH)+"CHRG_DOWN.DBF")

   if NetUse("CHARGE",DB_SHARED,NUM_SECONDS)
      set index to PAYTYPE
   endif   
   
   copy stru to (DOWN_PATH)+ "CHRG_DOWN.DBF"
   CHARGE->(DbCloseArea())
      
endif 


if NetUse("CHARGE",DB_SHARED,NUM_SECONDS)
      set index to PAYTYPE
endif   
if NetUse((DOWN_PATH)+"CHRG_DOWN",DB_SHARED,NUM_SECONDS)
endif   

Message("Downloading CHARGE File....please wait!")
wReindex:=OpenWindow(08,03,15,76,"DOWNLOAD")
hGauge:=GaugeNew(10,05,12,74,"N/W","N/W",chr(177))
GaugeDisplay(hGauge)
i := 0

CHARGE->(DbGoTop())
Do while CHARGE->(!Eof())
   IF CHARGE->OP_FLAG <> 0
      nPercent:=i++/100
      GaugeUpdate(hGauge,nPercent)            
      CHRG_DOWN->(FilLock(0))
      CHRG_DOWN->(DbAppend())
      CHRG_DOWN->POS_NO   := CHARGE->POS_NO
      CHRG_DOWN->DATE     := CHARGE->DATE
      CHRG_DOWN->TIME     := CHARGE->TIME
      CHRG_DOWN->CASH_CODE:= CHARGE->CASH_CODE
      CHRG_DOWN->SLS_AMOUNT:= CHARGE->SLS_AMOUNT
      CHRG_DOWN->PAY_TYPE := CHARGE->PAY_TYPE
      CHRG_DOWN->ACCT_NO  := CHARGE->ACCT_NO
      CHRG_DOWN->OP_FLAG  := CHARGE->OP_FLAG
      CHRG_DOWN->(DbUnLock())
      CHARGE->(Reclock(0))
      CHARGE->OP_FLAG := 0
      CHARGE->(DbUnLock())
   ENDIF
   CHARGE->(DbSkip())
enddo
GaugeUpdate(hGauge,1)               
@ 13,05 clear to 14,74
@ 13,05 say " Downloading of CHARGE file FINISHED."
HEYTHERE()
OKDONE()
CloseWindow(wReindex)
DbCloseAll()


/*============================= CONTROL =====================================*/

if !file((DOWN_PATH)+"CNTRL_DOWN.DBF")

   if NetUse("CNTRL",DB_SHARED,NUM_SECONDS)
      set index to CNTRL
   endif   
   
   copy stru to (DOWN_PATH)+ "CNTRL_DOWN.DBF"
   CNTRL->(DbCloseArea())
      
endif 


if NetUse("CNTRL",DB_SHARED,NUM_SECONDS)
      set index to CNTRL
endif   
if NetUse((DOWN_PATH)+"CNTRL_DOWN",DB_SHARED,NUM_SECONDS)
endif   

Message("Downloading CONTROL File....please wait!")
wReindex:=OpenWindow(08,03,15,76,"DOWNLOAD")
hGauge:=GaugeNew(10,05,12,74,"N/W","N/W",chr(177))
GaugeDisplay(hGauge)
i := 0

CNTRL->(DbGoTop())
Do while CNTRL->(!Eof())
   IF CNTRL->OP_FLAG <> 0
      nPercent:=i++/100
      GaugeUpdate(hGauge,nPercent)            
      CNTRL_DOWN->(FilLock(0))
      CNTRL_DOWN->(DbAppend())
      CNTRL_DOWN->CONTRL_NO   := CNTRL->CONTRL_NO
      CNTRL_DOWN->DATE     := CNTRL->DATE
      CNTRL_DOWN->OP_FLAG  := CNTRL->OP_FLAG
      CNTRL_DOWN->(DbUnLock())
      CNTRL->(Reclock(0))
      CNTRL->OP_FLAG := 0
      CNTRL->(DbUnLock())
   ENDIF
   CNTRL->(DbSkip())
enddo
GaugeUpdate(hGauge,1)               
@ 13,05 clear to 14,74
@ 13,05 say " Downloading of CONTROL file FINISHED."
HEYTHERE()
OKDONE()
CloseWindow(wReindex)
DbCloseAll()




/*============================= DELIVERY =====================================*/

if !file((DOWN_PATH)+"RR_DOWN.DBF")

   if NetUse("RR",DB_SHARED,NUM_SECONDS)
      set index to RR_001
   endif   
   
   copy stru to (DOWN_PATH)+ "RR_DOWN.DBF"
   RR->(DbCloseArea())
      
endif 

if !file((DOWN_PATH)+"RRITEMS_DOWN.DBF")

   if NetUse("RR_ITEMS",DB_SHARED,NUM_SECONDS)
      set index to RRI_LINK
   endif   
   
   copy stru to (DOWN_PATH)+ "RRITEMS_DOWN.DBF"
   RR_ITEMS->(DbCloseArea())
      
endif 

if NetUse("RR_ITEMS",DB_SHARED,NUM_SECONDS)
   set index to RRI_LINK
endif   
if NetUse("RR",DB_SHARED,NUM_SECONDS)
      set index to RR_001
endif   
if NetUse((DOWN_PATH)+"RR_DOWN",DB_SHARED,NUM_SECONDS)
endif   
if NetUse((DOWN_PATH)+"RRITEMS_DOWN",DB_SHARED,NUM_SECONDS)
endif   

Message("Downloading delivery File....please wait!")
wReindex:=OpenWindow(08,03,15,76,"DOWNLOAD")
hGauge:=GaugeNew(10,05,12,74,"N/W","N/W",chr(177))
GaugeDisplay(hGauge)
i := 0

RR->(DbGoTop())
Do while RR->(!Eof())

   IF RR->RR_013 <> 0
      nPercent:=i++/100
      GaugeUpdate(hGauge,nPercent)            
      RR_DOWN->(FilLock(0))
      RR_DOWN->(DbAppend())
      RR_DOWN->RR_001 := RR->RR_001
      RR_DOWN->RR_002 := RR->RR_002
      RR_DOWN->RR_003 := RR->RR_003
      RR_DOWN->RR_004 := RR->RR_004
      RR_DOWN->RR_005 := RR->RR_005
      RR_DOWN->RR_006 := RR->RR_006
      RR_DOWN->RR_007 := RR->RR_007
      RR_DOWN->RR_008 := RR->RR_008
      RR_DOWN->RR_009 := RR->RR_009
      RR_DOWN->RR_010 := RR->RR_010
      RR_DOWN->RR_011 := RR->RR_011
      RR_DOWN->RR_012 := RR->RR_012
      RR_DOWN->RR_013 := RR->RR_013
      RR_DOWN->(DbUnLock())
      RR->(Reclock(0))
      RR->RR_013 := 0
      RR->(DbUnlock())
      if RR_ITEMS->(Dbseek(RR->RR_001))
         Do While RR_ITEMS->(!Eof()) .and. RR_ITEMS->RRI_LINK == RR->RR_001
            RRITEMS_DOWN->(FilLock(0))
            RRITEMS_DOWN->(DbAppend())
            RRITEMS_DOWN->RRI_LINK := RR_ITEMS->RRI_LINK
            RRITEMS_DOWN->RRI_ITEM := RR_ITEMS->RRI_ITEM
            RRITEMS_DOWN->RRI_COST := RR_ITEMS->RRI_COST
            RRITEMS_DOWN->RRI_URET := RR_ITEMS->RRI_URET
            RRITEMS_DOWN->RRI_QREC := RR_ITEMS->RRI_QREC
            RRITEMS_DOWN->RRI_POST := RR_ITEMS->RRI_POST
            RRITEMS_DOWN->RRI_AGEC := RR_ITEMS->RRI_AGEC
            RRITEMS_DOWN->RRI_SOLD := RR_ITEMS->RRI_SOLD
            RRITEMS_DOWN->(DbUnLock())
            RR_ITEMS->(DbSkip())
         enddo
      endif   
   ENDIF
   
   RR->(DbSkip())
enddo
GaugeUpdate(hGauge,1)               
@ 13,05 clear to 14,74
@ 13,05 say " Downloading of Delivery file FINISHED."
HEYTHERE()
OKDONE()
CloseWindow(wReindex)
DbCloseAll()


/*============================= RETURNS =====================================*/

if !file((DOWN_PATH)+"RJ_DOWN.DBF")

   if NetUse("RJ",DB_SHARED,NUM_SECONDS)
      set index to RJ_001
   endif   
   
   copy stru to (DOWN_PATH)+ "RJ_DOWN.DBF"
   RJ->(DbCloseArea())
      
endif 

if !file((DOWN_PATH)+"RJITEMS_DOWN.DBF")

   if NetUse("RJ_ITEMS",DB_SHARED,NUM_SECONDS)
      set index to RJI_LINK
   endif   
   
   copy stru to (DOWN_PATH)+ "RJITEMS_DOWN.DBF"
   RJ_ITEMS->(DbCloseArea())
      
endif 

if NetUse("RJ_ITEMS",DB_SHARED,NUM_SECONDS)
   set index to RJI_LINK
endif   
if NetUse("RJ",DB_SHARED,NUM_SECONDS)
      set index to RJ_001
endif   
if NetUse((DOWN_PATH)+"RJ_DOWN",DB_SHARED,NUM_SECONDS)
endif   
if NetUse((DOWN_PATH)+"RJITEMS_DOWN",DB_SHARED,NUM_SECONDS)
endif   

Message("Downloading RETURN File....please wait!")
wReindex:=OpenWindow(08,03,15,76,"DOWNLOAD")
hGauge:=GaugeNew(10,05,12,74,"N/W","N/W",chr(177))
GaugeDisplay(hGauge)
i := 0

RJ->(DbGoTop())
Do while RJ->(!Eof())

   IF RJ->RJ_012 <> 0
      nPercent:=i++/100
      GaugeUpdate(hGauge,nPercent)            
      RJ_DOWN->(FilLock(0))
      RJ_DOWN->(DbAppend())
      RJ_DOWN->RJ_001 := RJ->RJ_001
      RJ_DOWN->RJ_002 := RJ->RJ_002
      RJ_DOWN->RJ_003 := RJ->RJ_003
      RJ_DOWN->RJ_004 := RJ->RJ_004
      RJ_DOWN->RJ_005 := RJ->RJ_005
      RJ_DOWN->RJ_006 := RJ->RJ_006
      RJ_DOWN->RJ_007 := RJ->RJ_007
      RJ_DOWN->RJ_008 := RJ->RJ_008
      RJ_DOWN->RJ_009 := RJ->RJ_009
      RJ_DOWN->RJ_010 := RJ->RJ_010
      RJ_DOWN->RJ_011 := RJ->RJ_011
      RJ_DOWN->RJ_012 := RJ->RJ_012
      RJ_DOWN->(DbUnLock())
      RJ->(Reclock(0))
      RJ->RJ_012 := 0
      RJ->(DbUnlock())
      if RJ_ITEMS->(Dbseek(RJ->RJ_001))
         Do While RJ_ITEMS->(!Eof()) .and. RJ_ITEMS->RJI_LINK == RJ->RJ_001
            RJITEMS_DOWN->(FilLock(0))
            RJITEMS_DOWN->(DbAppend())
            RJITEMS_DOWN->RJI_LINK := RJ_ITEMS->RJI_LINK
            RJITEMS_DOWN->RJI_ITEM := RJ_ITEMS->RJI_ITEM
            RJITEMS_DOWN->RJI_COST := RJ_ITEMS->RJI_COST
            RJITEMS_DOWN->RJI_URET := RJ_ITEMS->RJI_URET
            RJITEMS_DOWN->RJI_QRET := RJ_ITEMS->RJI_QRET
            RJITEMS_DOWN->RJI_POST := RJ_ITEMS->RJI_POST
            RJITEMS_DOWN->RJI_AGEC := RJ_ITEMS->RJI_AGEC
            RJITEMS_DOWN->(DbUnLock())
            RJ_ITEMS->(DbSkip())
         enddo
      endif   
   ENDIF
   
   RJ->(DbSkip())
enddo
GaugeUpdate(hGauge,1)               
@ 13,05 clear to 14,74
@ 13,05 say " Downloading of RETURN file FINISHED."
HEYTHERE()
OKDONE()
CloseWindow(wReindex)
DbCloseAll()


/*============================= TRANSFER =====================================*/

if !file((DOWN_PATH)+"ST_DOWN.DBF")

   if NetUse("ST",DB_SHARED,NUM_SECONDS)
      set index to ST_001
   endif   
   
   copy stru to (DOWN_PATH)+ "ST_DOWN.DBF"
   ST->(DbCloseArea())
      
endif 

if !file((DOWN_PATH)+"STITEMS_DOWN.DBF")

   if NetUse("ST_ITEMS",DB_SHARED,NUM_SECONDS)
      set index to STI_LINK
   endif   
   
   copy stru to (DOWN_PATH)+ "STITEMS_DOWN.DBF"
   ST_ITEMS->(DbCloseArea())
      
endif 

if NetUse("ST_ITEMS",DB_SHARED,NUM_SECONDS)
   set index to STI_LINK
endif   
if NetUse("ST",DB_SHARED,NUM_SECONDS)
      set index to ST_001
endif   
if NetUse((DOWN_PATH)+"ST_DOWN",DB_SHARED,NUM_SECONDS)
endif   
if NetUse((DOWN_PATH)+"STITEMS_DOWN",DB_SHARED,NUM_SECONDS)
endif   

Message("Downloading TRANSFER File....please wait!")
wReindex:=OpenWindow(08,03,15,76,"DOWNLOAD")
hGauge:=GaugeNew(10,05,12,74,"N/W","N/W",chr(177))
GaugeDisplay(hGauge)
i := 0

ST->(DbGoTop())
Do while ST->(!Eof())

   IF ST->ST_009 <> 0
      nPercent:=i++/100
      GaugeUpdate(hGauge,nPercent)            
      ST_DOWN->(FilLock(0))
      ST_DOWN->(DbAppend())
      ST_DOWN->ST_001 := ST->ST_001
      ST_DOWN->ST_002 := ST->ST_002
      ST_DOWN->ST_003 := ST->ST_003
      ST_DOWN->ST_004 := ST->ST_004
      ST_DOWN->ST_005 := ST->ST_005
      ST_DOWN->ST_006 := ST->ST_006
      ST_DOWN->ST_007 := ST->ST_007
      ST_DOWN->ST_008 := ST->ST_008
      ST_DOWN->ST_009 := ST->ST_009
      ST_DOWN->(DbUnLock())
      ST->(Reclock(0))
      ST->ST_009 := 0
      ST->(DbUnlock())
      if ST_ITEMS->(Dbseek(ST->ST_001))
         Do While ST_ITEMS->(!Eof()) .and. ST_ITEMS->STI_LINK == ST->ST_001
            STITEMS_DOWN->(FilLock(0))
            STITEMS_DOWN->(DbAppend())
            STITEMS_DOWN->STI_LINK := ST_ITEMS->STI_LINK
            STITEMS_DOWN->STI_ITEM := ST_ITEMS->STI_ITEM
            STITEMS_DOWN->STI_QADJ := ST_ITEMS->STI_QADJ
            STITEMS_DOWN->STI_UPRC := ST_ITEMS->STI_UPRC
            STITEMS_DOWN->STI_POST := ST_ITEMS->STI_POST
            STITEMS_DOWN->(DbUnLock())
            ST_ITEMS->(DbSkip())
         enddo
      endif   
   ENDIF
   
   ST->(DbSkip())
enddo
GaugeUpdate(hGauge,1)               
@ 13,05 clear to 14,74
@ 13,05 say " Downloading of TRANSFER file FINISHED."
HEYTHERE()
OKDONE()
CloseWindow(wReindex)
DbCloseAll()


/*============================= ADJUSTMENT =====================================*/

if !file((DOWN_PATH)+"SA_DOWN.DBF")

   if NetUse("SA",DB_SHARED,NUM_SECONDS)
      set index to SA_001
   endif   
   
   copy STRU to (DOWN_PATH)+ "SA_DOWN.DBF"
   SA->(DbCloseArea())
      
endif 

if !file((DOWN_PATH)+"SAITEMS_DOWN.DBF")

   if NetUse("SA_ITEMS",DB_SHARED,NUM_SECONDS)
      set index to SAI_LINK
   endif   
   
   copy STRU to (DOWN_PATH)+ "SAITEMS_DOWN.DBF"
   SA_ITEMS->(DbCloseArea())
      
endif 

if NetUse("SA_ITEMS",DB_SHARED,NUM_SECONDS)
   set index to SAI_LINK
endif   
if NetUse("SA",DB_SHARED,NUM_SECONDS)
      set index to SA_001
endif   
if NetUse((DOWN_PATH)+"SA_DOWN",DB_SHARED,NUM_SECONDS)
endif   
if NetUse((DOWN_PATH)+"SAITEMS_DOWN",DB_SHARED,NUM_SECONDS)
endif   

Message("Downloading ADJUSTMENT File....please wait!")
wReindex:=OpenWindow(08,03,15,76,"DOWNLOAD")
hGauge:=GaugeNew(10,05,12,74,"N/W","N/W",chr(177))
GaugeDisplay(hGauge)
i := 0

SA->(DbGoTop())
Do while SA->(!Eof())

   IF SA->SA_007 <> 0
      nPercent:=i++/100
      GaugeUpdate(hGauge,nPercent)            
      SA_DOWN->(FilLock(0))
      SA_DOWN->(DbAppend())
      SA_DOWN->SA_001 := SA->SA_001
      SA_DOWN->SA_002 := SA->SA_002
      SA_DOWN->SA_003 := SA->SA_003
      SA_DOWN->SA_004 := SA->SA_004
      SA_DOWN->SA_005 := SA->SA_005
      SA_DOWN->SA_006 := SA->SA_006
      SA_DOWN->SA_007 := SA->SA_007
      SA_DOWN->(DbUnLock())
      SA->(Reclock(0))
      SA->SA_007 := 0
      SA->(DbUnlock())
      if SA_ITEMS->(Dbseek(SA->SA_001))
         Do While SA_ITEMS->(!Eof()) .and. SA_ITEMS->SAI_LINK == SA->SA_001
            SAITEMS_DOWN->(FilLock(0))
            SAITEMS_DOWN->(DbAppend())
            SAITEMS_DOWN->SAI_LINK := SA_ITEMS->SAI_LINK
            SAITEMS_DOWN->SAI_ITEM := SA_ITEMS->SAI_ITEM
            SAITEMS_DOWN->SAI_QADJ := SA_ITEMS->SAI_QADJ
            SAITEMS_DOWN->SAI_UPRC := SA_ITEMS->SAI_UPRC
            SAITEMS_DOWN->SAI_POST := SA_ITEMS->SAI_POST
            SAITEMS_DOWN->(DbUnLock())
            SA_ITEMS->(DbSkip())
         enddo
      endif   
   ENDIF
   
   SA->(DbSkip())
enddo
GaugeUpdate(hGauge,1)               
@ 13,05 clear to 14,74
@ 13,05 say " Downloading of ADJUSTMENT file FINISHED."
HEYTHERE()
OKDONE()
CloseWindow(wReindex)
DbCloseAll()
  
   Bakup()
   
return nil

function Bakup()
local j,adir:={}
local cpath:=substr(cmonth(date()),1,3)+alltrim(str(day(date())))

 if l_mkdir(".\BACKUP\"+cpath) == 0

  message("Data Download Back-up....")
  adir := directory((DOWN_PATH)+"*.DBF")
  for j:=1 to len(adir)
  copy file (DOWN_PATH+adir[j][F_NAME]) TO (".\BACKUP\"+cpath+"\"+adir[j][F_NAME])
  next j

 endif 

return nil