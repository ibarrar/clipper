#include "rpt.ch"
#include "janus.ch"
#include "fileio.ch"
#include "inkey.ch"
#include "setcurs.ch"

#define F_BLOCK  1024
#define DATA_PATH  chr(65+curdrv())+":\"+curdir()+"\BACKUP\"   

#define DEFAULT_PATH   "DATA"
#define CR     chr(13)
#define LF     chr(10)
#define CRLF   CR + LF

memvar getlist
memvar dEndDate,dStartDate

function PLU_IMP(sdate)

local term, pos := 0, date, time := 0
local cFileName, cfile, cpath, cStr
local nFHandle, lfirst := .f., plu_file
local strdate := dtoc(sdate), cSign := space(3),itemcnt := 0
local nread := 0, cbuff,nFtarget, nFSource, nmove, itemsold := 0

 plu_file := "PLUI" + substr(strdate,1,2) + substr(strdate,4,2) + "." + substr(strdate,7,2) + "0"

 if NetUse("UM",DB_SHARED,NUM_SECONDS)
    Set Index to UM
 endif

 if NetUse("PLU",DB_SHARED,NUM_SECONDS)
    Set Index to PLU,ITEMCNT,DATEPLU
 endif

if NetUse("NPLU",DB_SHARED,NUM_SECONDS)
    Set Index to NPLU,NITEMCNT
 endif

 Do While UM->(!Eof()) 

  if UM->(DeleteD())
   UM->(DbSkip())
   loop
  endif
   
 
   cFilename :=  alltrim(UM->UMAC_PATH)+PLU_FILE
   cPath := alltrim(UM->UMAC_PATH)

   Message(" Opening file :  "+ cFilename)

   nFHandle := fopen(cFilename,FO_READ)

   if nFHandle == -1
     Message(" Opening file :  "+ cFilename+ "      No Data Found !!!")
     tone(100,1.5)
     UM->(DbSkip())
     loop
   endif

   while !feof(nFhandle)

    cStr := space(116)
    freadln(nFHandle,@cStr,116)
   
    Do Case
      Case SIGN == "PLU" .or.  SIGN == "NOT" 
         pos := at("<",cStr)
         term := substr(cStr,pos+1,4)
         csign := SIGN
      Case substr(SIGN,3,1) == "/"   
         date := ctod(SUBSTR(cStr,1,8))
         time := val(SUBSTR(cStr,32,5))
         if lfirst
            PLU->(DbUnLock())
            lfirst := .f.
         endif
      otherwise   
        if cSIGN == "PLU"
         PLU->(FilLock())
         if !PLU->(DbSeek(ICODE+dtos(date)))
            PLU->(DbAppend())
            PLU->DATE   := date
            PLU->CODE   := ICODE
            PLU->OP_FLAG := 1
            PLU->ITEM_CODE   := ITCODE
            PLU->DESC    := IDESC
            pos := at("-",ICNT)
            IF pos <> 0
               itemcnt := VAL(SUBSTR(ICNT,pos+1,10)) * -.001
            ELSE   
               itemcnt := val(ICNT) * .001
            ENDIF   
            pos := at("-",IAMT)
            IF pos <> 0
               itemsold := VAL(SUBSTR(IAMT,pos+1,12)) * -.01
            ELSE   
               itemsold := val(IAMT) * .01
            ENDIF   
            PLU->ICOUNT  := itemcnt
            PLU->IAMOUNT := itemsold
            PLU->I_UCOST := IUCOST
         else 
            pos := at("-",ICNT)
            IF pos <> 0
               itemcnt := VAL(SUBSTR(ICNT,pos+1,10)) * -.001
            ELSE   
               itemcnt := val(ICNT) * .001
            ENDIF   
            pos := at("-",IAMT)
            IF pos <> 0
               itemsold := VAL(SUBSTR(IAMT,pos+1,12)) * -.01
            ELSE   
               itemsold := val(IAMT) * .01
            ENDIF   
            PLU->ICOUNT  += itemcnt
            PLU->IAMOUNT += itemsold
            PLU->I_UCOST += IUCOST
         endif
         lfirst := .t.
        endif 

        if cSIGN == "NOT"
         NPLU->(FilLock())
         if !NPLU->(DbSeek(ICODE+dtos(date)))
            NPLU->(DbAppend())
            NPLU->DATE   := date
            NPLU->CODE   := NF_ICODE
            NPLU->OP_FLAG := 1
            pos := at("-",NF_ICNT)
            IF pos <> 0
               itemcnt := VAL(SUBSTR(NF_ICNT,pos+1,10)) * -.001
            ELSE   
               itemcnt := val(NF_ICNT) * .001
            ENDIF   
            pos := at("-",NF_IAMT)
            IF pos <> 0
               itemsold := VAL(SUBSTR(NF_IAMT,pos+1,12)) * -.01
            ELSE   
               itemsold := val(NF_IAMT) * .01
            ENDIF   
            NPLU->ICOUNT  := itemcnt
            NPLU->IAMOUNT := itemsold
         else 
            pos := at("-",NF_ICNT)
            IF pos <> 0
               itemcnt := VAL(SUBSTR(NF_ICNT,pos+1,10)) * -.001
            ELSE   
               itemcnt := val(NF_ICNT) * .001
            ENDIF   
            pos := at("-",NF_IAMT)
            IF pos <> 0
               itemsold := VAL(SUBSTR(NF_IAMT,pos+1,12)) * -.01
            ELSE   
               itemsold := val(NF_IAMT) * .01
            ENDIF   
            NPLU->ICOUNT  += itemcnt
            NPLU->IAMOUNT += itemsold
         endif
         lfirst := .t.
        endif 
        
    EndCase 
   
   enddo
   fclose(nFhandle) 

   if file(cPath+PLU_FILE)
     cFile := alltrim(SUBSTR(CMONTH(sdate),1,3))+alltrim(SUBSTR(DTOC(sdate),4,2))+".PLU"
     frename((cPath)+PLU_FILE,(cPath)+cFile)
     
      nFsource :=  fopen((cpath)+cFile,FO_READ)
      nFTarget := fopen((DATA_PATH)+cFile,FO_READWRITE)
      if ferror() == 2
         fcreate((DATA_PATH)+cFile,FC_NORMAL)
         nFTarget := fopen((DATA_PATH)+cFile,FO_READWRITE)
      endif
      nMove := fseek(nFTarget,0,FS_END)
      cbuff := space(F_BLOCK)
      while ((nread := fread(nFsource,@cbuff,F_BLOCK)) > 0)
         fwrite(nFtarget,cBuff,nRead)
      enddo
      ferase((cPath)+cFile)

     fClose(nFtarget)
     fClose(nFSource)
     
   else
     alert("No ITEM transaction file", {"Return"})
     Return nil
   endif  
  
  UM->(DbSkip())
 enddo
 
 DbCloseAll()

return nil


// REPORT POSTING - moves data to backup directory

function Repost()

local nFhandle, cPath:=" ", wChange, nFhandle1
local getlist := {}, dbffile, oldpath 
local datpath := "C:\"+curdir() + "\BACKUP\"
local mpath

if file(".\"+"RP.TXT")
  nFHandle:=fopen(".\"+"RP.TXT")
  cPath := freadstr(nFHandle,35)
  fclose(nFHandle)
else
  cPath := datPath  
endif     

cPath := padr(alltrim(cPath),35) 
wChange := OpenWindow(5,10,9,75,"Data Path Editing")
setcursor(SC_NORMAL)
@  6,10 to 9,75 double
@  7,12 say "ENTER DESTINATION PATH : " get cPath pict "@! " +REPL("X",35)
read
CloseWindow(wChange)  
setcursor(SC_NONE) 
cPath := ALLTRIM(cPath)
if substr(cpath,len(cPath),1) != "\"
  cPath += "\"
endif  

   
 // save new path to file
 if lastkey() != K_ESC
   if file("RP.TXT")
     ferase("RP.TXT")
   endif  
   nFHandle := fcreate("RP.TXT",FC_NORMAL)
   fwrite(nFHandle,cPath)
   fclose(nFHandle)          
 else
   BUMMER()
   return nil
 endif


if (nFHandle1 := fcreate((cpath)+"TMP.DAT", FC_NORMAL)) == -1   // to test if network exist
     BUMMER()
     alert("Drive does not exist or Insufficient disk space",{"Quit"})  
     return nil
endif     


if Getdates()

   message("Copying Files ....")

/*================ CASHIER =======================*/
  mpath := "cash"+ substr(dtoc(dstartdate),1,2) + substr(dtoc(dstartdate),7,2) 
  if !file(cpath+mpath+".dbf")
   NetUse("CASH",DB_SHARED,NUM_SECONDS)   
   copy stru to (cpath) + (mpath) +".dbf"
   CASH->(DbCloseArea())
  endif 

   if NetUse(cpath + mpath, DB_EXCLUSIVE,NUM_SECONDS)   
      DbfFile := alias()
   endif   
  
   if NetUse("CASH",DB_SHARED,NUM_SECONDS)   
      Index on CASH->CODE to CAS
   endif
   
   
   Do while CASH->(!Eof())
      if CASH->DATE >= dstartdate .and. CASH->DATE <= dEndDate .AND. CASH->(!Deleted())
         (DbfFile)->(DbAppend())
         (DbfFile)->TERM    := CASH->TERM
         (DbfFile)->DATE    := CASH->DATE
         (DbfFile)->TIME    := CASH->TIME
         (DbfFile)->CODE    := CASH->CODE
         (DbfFile)->NAME    := CASH->NAME
         (DbfFile)->DAILY_C := CASH->DAILY_C
         (DbfFile)->DAILY_A := CASH->DAILY_A
         (DbfFile)->CASH_A  := CASH->CASH_A
         (DbfFile)->GROSS_A := CASH->GROSS_A
         (DbfFile)->DEPT_A  := CASH->DEPT_A
         (DbfFile)->FORCUR_C := CASH->FORCUR_C
         (DbfFile)->FORCUR_A := CASH->FORCUR_A
         (DbfFile)->MISC01_C := CASH->MISC01_C
         (DbfFile)->MISC01_A := CASH->MISC01_A
         (DbfFile)->MISC02_C := CASH->MISC02_C
         (DbfFile)->MISC02_A := CASH->MISC02_A
         (DbfFile)->MISC03_C := CASH->MISC03_C
         (DbfFile)->MISC03_A := CASH->MISC03_A
         (DbfFile)->MISC04_C := CASH->MISC04_C
         (DbfFile)->MISC04_A := CASH->MISC04_A
         (DbfFile)->MISC05_C := CASH->MISC05_C
         (DbfFile)->MISC05_A := CASH->MISC05_A
         (DbfFile)->MISC06_C := CASH->MISC06_C
         (DbfFile)->MISC06_A := CASH->MISC06_A
         (DbfFile)->MISC07_C := CASH->MISC07_C
         (DbfFile)->MISC07_A := CASH->MISC07_A
         (DbfFile)->MISC08_C := CASH->MISC08_C
         (DbfFile)->MISC08_A := CASH->MISC08_A
         (DbfFile)->MISC09_C := CASH->MISC09_C
         (DbfFile)->MISC09_A := CASH->MISC09_A
         (DbfFile)->MISC10_C := CASH->MISC10_C
         (DbfFile)->MISC10_A := CASH->MISC10_A
         (DbfFile)->MISC11_C := CASH->MISC11_C
         (DbfFile)->MISC11_A := CASH->MISC11_A
         (DbfFile)->MISC12_C := CASH->MISC12_C
         (DbfFile)->MISC12_A := CASH->MISC12_A
         (DbfFile)->MISC13_C := CASH->MISC13_C
         (DbfFile)->MISC13_A := CASH->MISC13_A
         (DbfFile)->MISC14_C := CASH->MISC14_C
         (DbfFile)->MISC14_A := CASH->MISC14_A
         (DbfFile)->MISC15_C := CASH->MISC15_C
         (DbfFile)->MISC15_A := CASH->MISC15_A
         (DbfFile)->MISC16_C := CASH->MISC16_C
         (DbfFile)->MISC16_A := CASH->MISC16_A
         (DbfFile)->MISC17_C := CASH->MISC17_C
         (DbfFile)->MISC17_A := CASH->MISC17_A
         (DbfFile)->MISC18_C := CASH->MISC18_C
         (DbfFile)->MISC18_A := CASH->MISC18_A
         (DbfFile)->MISC19_C := CASH->MISC19_C
         (DbfFile)->MISC19_A := CASH->MISC19_A
         (DbfFile)->MISC20_C := CASH->MISC20_C
         (DbfFile)->MISC20_A := CASH->MISC20_A
         (DbfFile)->MISC21_C := CASH->MISC21_C
         (DbfFile)->MISC21_A := CASH->MISC21_A
         (DbfFile)->MISC22_C := CASH->MISC22_C
         (DbfFile)->MISC22_A := CASH->MISC22_A
         (DbfFile)->MISC23_C := CASH->MISC23_C
         (DbfFile)->MISC23_A := CASH->MISC23_A
         (DbfFile)->MISC24_C := CASH->MISC24_C
         (DbfFile)->MISC24_A := CASH->MISC24_A
         (DbfFile)->MISC25_C := CASH->MISC25_C
         (DbfFile)->MISC25_A := CASH->MISC25_A
         (DbfFile)->MISC26_C := CASH->MISC26_C
         (DbfFile)->MISC26_A := CASH->MISC26_A
         (DbfFile)->MISC27_C := CASH->MISC27_C
         (DbfFile)->MISC27_A := CASH->MISC27_A
         (DbfFile)->MISC28_C := CASH->MISC28_C
         (DbfFile)->MISC28_A := CASH->MISC28_A
         (DbfFile)->MISC29_C := CASH->MISC29_C
         (DbfFile)->MISC29_A := CASH->MISC29_A
         (DbfFile)->MISC30_C := CASH->MISC30_C
         (DbfFile)->MISC30_A := CASH->MISC30_A
         (DbfFile)->MISC31_C := CASH->MISC31_C
         (DbfFile)->MISC31_A := CASH->MISC31_A
         (DbfFile)->MISC32_C := CASH->MISC32_C
         (DbfFile)->MISC32_A := CASH->MISC32_A
         (DbfFile)->MISC33_C := CASH->MISC33_C
         (DbfFile)->MISC33_A := CASH->MISC33_A
         (DbfFile)->MISC34_C := CASH->MISC34_C
         (DbfFile)->MISC34_A := CASH->MISC34_A
         (DbfFile)->MISC35_C := CASH->MISC35_C
         (DbfFile)->MISC35_A := CASH->MISC35_A
         (DbfFile)->MISC36_C := CASH->MISC36_C
         (DbfFile)->MISC36_A := CASH->MISC36_A
         (DbfFile)->MISC37_C := CASH->MISC37_C
         (DbfFile)->MISC37_A := CASH->MISC37_A
         (DbfFile)->MISC38_C := CASH->MISC38_C
         (DbfFile)->MISC38_A := CASH->MISC38_A
         (DbfFile)->MISC39_C := CASH->MISC39_C
         (DbfFile)->MISC39_A := CASH->MISC39_A
         (DbfFile)->MISC40_C := CASH->MISC40_C
         (DbfFile)->MISC40_A := CASH->MISC40_A
         (DbfFile)->MISC41_C := CASH->MISC41_C
         (DbfFile)->MISC41_A := CASH->MISC41_A
         (DbfFile)->MISC42_C := CASH->MISC42_C
         (DbfFile)->MISC42_A := CASH->MISC42_A
         (DbfFile)->MISC43_C := CASH->MISC43_C
         (DbfFile)->MISC43_A := CASH->MISC43_A
         (DbfFile)->MISC44_C := CASH->MISC44_C
         (DbfFile)->MISC44_A := CASH->MISC44_A
         (DbfFile)->MISC45_C := CASH->MISC45_C
         (DbfFile)->MISC45_A := CASH->MISC45_A
         (DbfFile)->MISC46_C := CASH->MISC46_C
         (DbfFile)->MISC46_A := CASH->MISC46_A
         (DbfFile)->MISC47_C := CASH->MISC47_C
         (DbfFile)->MISC47_A := CASH->MISC47_A
         (DbfFile)->MISC48_C := CASH->MISC48_C
         (DbfFile)->MISC48_A := CASH->MISC48_A
         (DbfFile)->MISC49_C := CASH->MISC49_C
         (DbfFile)->MISC49_A := CASH->MISC49_A
         (DbfFile)->MISC50_C := CASH->MISC50_C
         (DbfFile)->MISC50_A := CASH->MISC50_A
         (DbfFile)->IVOID_C :=  CASH->IVOID_C
         (DbfFile)->IVOID_A :=  CASH->IVOID_A
         (DbfFile)->MVOID_C :=  CASH->MVOID_C
         (DbfFile)->MVOID_A :=  CASH->MVOID_A
         (DbfFile)->IDISC_C :=  CASH->IDISC_C
         (DbfFile)->IDISC_A :=  CASH->IDISC_A
         (DbfFile)->SUBTD_C :=  CASH->SUBTD_C
         (DbfFile)->SUBTD_A :=  CASH->SUBTD_A
         (DbfFile)->ADDON_C :=  CASH->ADDON_C
         (DbfFile)->ADDON_A :=  CASH->ADDON_A
         (DbfFile)->SSBTD_C :=  CASH->SSBTD_C
         (DbfFile)->SSBTD_A :=  CASH->SSBTD_A
         (DbfFile)->SSBTA_C :=  CASH->SSBTA_C
         (DbfFile)->SSBTA_A :=  CASH->SSBTA_A
         (DbfFile)->RETRN_C :=  CASH->RETRN_C
         (DbfFile)->RETRN_A :=  CASH->RETRN_A
         (DbfFile)->REFND_C :=  CASH->REFND_C
         (DbfFile)->REFND_A :=  CASH->REFND_A
         (DbfFile)->OTINC_C :=  CASH->OTINC_C
         (DbfFile)->OTINC_A :=  CASH->OTINC_A
         (DbfFile)->CANCL_C :=  CASH->CANCL_C
         (DbfFile)->CANCL_A :=  CASH->CANCL_A
         (DbfFile)->TVOID_C :=  CASH->TVOID_C
         (DbfFile)->TVOID_A :=  CASH->TVOID_A
         (DbfFile)->SUSPD_C :=  CASH->SUSPD_C
         (DbfFile)->SUSPD_A :=  CASH->SUSPD_A
         (DbfFile)->LAYAW_C :=  CASH->LAYAW_C
         (DbfFile)->LAYAW_A :=  CASH->LAYAW_A
         (DbfFile)->PIKUP_C :=  CASH->PIKUP_C
         (DbfFile)->PIKUP_A :=  CASH->PIKUP_A
         (DbfFile)->PDOUT_C :=  CASH->PDOUT_C
         (DbfFile)->PDOUT_A :=  CASH->PDOUT_A
         (DbfFile)->LOAN_C :=   CASH->LOAN_C
         (DbfFile)->LOAN_A :=   CASH->LOAN_A
         (DbfFile)->RECACT_C := CASH->RECACT_C
         (DbfFile)->RECACT_A := CASH->RECACT_A
         (DbfFile)->BOTDEP_C := CASH->BOTDEP_C
         (DbfFile)->BOTDEP_A := CASH->BOTDEP_A
         (DbfFile)->CASHDEC :=  CASH->CASHDEC
         (DbfFile)->TRAIN_A :=  CASH->TRAIN_A
         (DbfFile)->OFFLN_A :=  CASH->OFFLN_A
         (DbfFile)->RENTER_A := CASH->RENTER_A
         (DbfFile)->OLDGRD_A := CASH->OLDGRD_A
         (DbfFile)->NEWGRD_A := CASH->NEWGRD_A
         (DbfFile)->XCOUNT_C := CASH->XCOUNT_C
         (DbfFile)->ZCOUNT_C := CASH->ZCOUNT_C

         CASH->(RecLock(0))
         CASH->(DbDelete())
         CASH->(DbUnLock())
      endif         
      CASH->(DbSkip())
   enddo 
   CASH->(DbCloseArea())
   (DbfFile)->(DbCloseArea())
   if NetUse("CASH",DB_EXCLUSIVE,NUM_SECONDS)   
      Set index to CAS
      CASH->(__DbPack())
      CASH->(DbCloseArea())
   ENDIF   
   BUMMER()
   HEYTHERE()

   
/*================ TERMINAL =======================*/
  mpath := "term"+ substr(dtoc(dstartdate),1,2) + substr(dtoc(dstartdate),7,2) 
  if !file(cpath+mpath+".dbf")
   NetUse("TERMINAL",DB_SHARED,NUM_SECONDS)   
   copy stru to (cpath) + (mpath)+".dbf"
   TERMINAL->(DbCloseArea())
  endif 

   if NetUse(cpath + mpath,DB_EXCLUSIVE,NUM_SECONDS)   
      DbfFile := alias()
   endif   
  
   if NetUse("TERMINAL",DB_SHARED,NUM_SECONDS)   
     Index on TERMINAL->TERM to TERMINAL
   endif
   
   
   Do while TERMINAL->(!Eof())
      if TERMINAL->DATE >= dstartdate .and. TERMINAL->DATE <= dEndDate;
         .and. TERMINAL->(!Deleted())
         (DbfFile)->(DbAppend())
         (DbfFile)->TERM    := TERMINAL->TERM
         (DbfFile)->DATE    := TERMINAL->DATE
         (DbfFile)->TIME    := TERMINAL->TIME
         (DbfFile)->DAILY_C := TERMINAL->DAILY_C
         (DbfFile)->DAILY_A := TERMINAL->DAILY_A
         (DbfFile)->CASH_A  := TERMINAL->CASH_A
         (DbfFile)->GROSS_A := TERMINAL->GROSS_A
         (DbfFile)->DEPT_A  := TERMINAL->DEPT_A
         (DbfFile)->FORCUR_C := TERMINAL->FORCUR_C
         (DbfFile)->FORCUR_A := TERMINAL->FORCUR_A
         (DbfFile)->MISC1_C := TERMINAL->MISC1_C
         (DbfFile)->MISC1_A := TERMINAL->MISC1_A
         (DbfFile)->MISC2_C := TERMINAL->MISC2_C
         (DbfFile)->MISC2_A := TERMINAL->MISC2_A
         (DbfFile)->MISC3_C := TERMINAL->MISC3_C
         (DbfFile)->MISC3_A := TERMINAL->MISC3_A
         (DbfFile)->MISC4_C := TERMINAL->MISC4_C
         (DbfFile)->MISC4_A := TERMINAL->MISC4_A
         (DbfFile)->MISC5_C := TERMINAL->MISC5_C
         (DbfFile)->MISC5_A := TERMINAL->MISC5_A
         (DbfFile)->MISC6_C := TERMINAL->MISC6_C
         (DbfFile)->MISC6_A := TERMINAL->MISC6_A
         (DbfFile)->MISC7_C := TERMINAL->MISC7_C
         (DbfFile)->MISC7_A := TERMINAL->MISC7_A
         (DbfFile)->MISC8_C := TERMINAL->MISC8_C
         (DbfFile)->MISC8_A := TERMINAL->MISC8_A
         (DbfFile)->MISC9_C := TERMINAL->MISC9_C
         (DbfFile)->MISC9_A := TERMINAL->MISC9_A
         (DbfFile)->MISC10_C := TERMINAL->MISC10_C
         (DbfFile)->MISC10_A := TERMINAL->MISC10_A
         (DbfFile)->MISC11_C := TERMINAL->MISC11_C
         (DbfFile)->MISC11_A := TERMINAL->MISC11_A
         (DbfFile)->MISC12_C := TERMINAL->MISC12_C
         (DbfFile)->MISC12_A := TERMINAL->MISC12_A
         (DbfFile)->MISC13_C := TERMINAL->MISC13_C
         (DbfFile)->MISC13_A := TERMINAL->MISC13_A
         (DbfFile)->MISC14_C := TERMINAL->MISC14_C
         (DbfFile)->MISC14_A := TERMINAL->MISC14_A
         (DbfFile)->MISC15_C := TERMINAL->MISC15_C
         (DbfFile)->MISC15_A := TERMINAL->MISC15_A
         (DbfFile)->MISC16_C := TERMINAL->MISC16_C
         (DbfFile)->MISC16_A := TERMINAL->MISC16_A
         (DbfFile)->MISC17_C := TERMINAL->MISC17_C
         (DbfFile)->MISC17_A := TERMINAL->MISC17_A
         (DbfFile)->MISC18_C := TERMINAL->MISC18_C
         (DbfFile)->MISC18_A := TERMINAL->MISC18_A
         (DbfFile)->MISC19_C := TERMINAL->MISC19_C
         (DbfFile)->MISC19_A := TERMINAL->MISC19_A
         (DbfFile)->MISC20_C := TERMINAL->MISC20_C
         (DbfFile)->MISC20_A := TERMINAL->MISC20_A
         (DbfFile)->MISC21_C := TERMINAL->MISC21_C
         (DbfFile)->MISC21_A := TERMINAL->MISC21_A
         (DbfFile)->MISC22_C := TERMINAL->MISC22_C
         (DbfFile)->MISC22_A := TERMINAL->MISC22_A
         (DbfFile)->MISC23_C := TERMINAL->MISC23_C
         (DbfFile)->MISC23_A := TERMINAL->MISC23_A
         (DbfFile)->MISC24_C := TERMINAL->MISC24_C
         (DbfFile)->MISC24_A := TERMINAL->MISC24_A
         (DbfFile)->MISC25_C := TERMINAL->MISC25_C
         (DbfFile)->MISC25_A := TERMINAL->MISC25_A
         (DbfFile)->MISC26_C := TERMINAL->MISC26_C
         (DbfFile)->MISC26_A := TERMINAL->MISC26_A
         (DbfFile)->MISC27_C := TERMINAL->MISC27_C
         (DbfFile)->MISC27_A := TERMINAL->MISC27_A
         (DbfFile)->MISC28_C := TERMINAL->MISC28_C
         (DbfFile)->MISC28_A := TERMINAL->MISC28_A
         (DbfFile)->MISC29_C := TERMINAL->MISC29_C
         (DbfFile)->MISC29_A := TERMINAL->MISC29_A
         (DbfFile)->MISC30_C := TERMINAL->MISC30_C
         (DbfFile)->MISC30_A := TERMINAL->MISC30_A
         (DbfFile)->MISC31_C := TERMINAL->MISC31_C
         (DbfFile)->MISC31_A := TERMINAL->MISC31_A
         (DbfFile)->MISC32_C := TERMINAL->MISC32_C
         (DbfFile)->MISC32_A := TERMINAL->MISC32_A
         (DbfFile)->MISC33_C := TERMINAL->MISC33_C
         (DbfFile)->MISC33_A := TERMINAL->MISC33_A
         (DbfFile)->MISC34_C := TERMINAL->MISC34_C
         (DbfFile)->MISC34_A := TERMINAL->MISC34_A
         (DbfFile)->MISC35_C := TERMINAL->MISC35_C
         (DbfFile)->MISC35_A := TERMINAL->MISC35_A
         (DbfFile)->MISC36_C := TERMINAL->MISC36_C
         (DbfFile)->MISC36_A := TERMINAL->MISC36_A
         (DbfFile)->MISC37_C := TERMINAL->MISC37_C
         (DbfFile)->MISC37_A := TERMINAL->MISC37_A
         (DbfFile)->MISC38_C := TERMINAL->MISC38_C
         (DbfFile)->MISC38_A := TERMINAL->MISC38_A
         (DbfFile)->MISC39_C := TERMINAL->MISC39_C
         (DbfFile)->MISC39_A := TERMINAL->MISC39_A
         (DbfFile)->MISC40_C := TERMINAL->MISC40_C
         (DbfFile)->MISC40_A := TERMINAL->MISC40_A
         (DbfFile)->MISC41_C := TERMINAL->MISC41_C
         (DbfFile)->MISC41_A := TERMINAL->MISC41_A
         (DbfFile)->MISC42_C := TERMINAL->MISC42_C
         (DbfFile)->MISC42_A := TERMINAL->MISC42_A
         (DbfFile)->MISC43_C := TERMINAL->MISC43_C
         (DbfFile)->MISC43_A := TERMINAL->MISC43_A
         (DbfFile)->MISC44_C := TERMINAL->MISC44_C
         (DbfFile)->MISC44_A := TERMINAL->MISC44_A
         (DbfFile)->MISC45_C := TERMINAL->MISC45_C
         (DbfFile)->MISC45_A := TERMINAL->MISC45_A
         (DbfFile)->MISC46_C := TERMINAL->MISC46_C
         (DbfFile)->MISC46_A := TERMINAL->MISC46_A
         (DbfFile)->MISC47_C := TERMINAL->MISC47_C
         (DbfFile)->MISC47_A := TERMINAL->MISC47_A
         (DbfFile)->MISC48_C := TERMINAL->MISC48_C
         (DbfFile)->MISC48_A := TERMINAL->MISC48_A
         (DbfFile)->MISC49_C := TERMINAL->MISC49_C
         (DbfFile)->MISC49_A := TERMINAL->MISC49_A
         (DbfFile)->MISC50_C := TERMINAL->MISC50_C
         (DbfFile)->MISC50_A := TERMINAL->MISC50_A
         (DbfFile)->IVOID_C :=  TERMINAL->IVOID_C
         (DbfFile)->IVOID_A :=  TERMINAL->IVOID_A
         (DbfFile)->MVOID_C :=  TERMINAL->MVOID_C
         (DbfFile)->MVOID_A :=  TERMINAL->MVOID_A
         (DbfFile)->IDISC_C :=  TERMINAL->IDISC_C
         (DbfFile)->IDISC_A :=  TERMINAL->IDISC_A
         (DbfFile)->SUBTD_C :=  TERMINAL->SUBTD_C
         (DbfFile)->SUBTD_A :=  TERMINAL->SUBTD_A
         (DbfFile)->ADDON_C :=  TERMINAL->ADDON_C
         (DbfFile)->ADDON_A :=  TERMINAL->ADDON_A
         (DbfFile)->SSBTD_C :=  TERMINAL->SSBTD_C
         (DbfFile)->SSBTD_A :=  TERMINAL->SSBTD_A
         (DbfFile)->SSBTA_C :=  TERMINAL->SSBTA_C
         (DbfFile)->SSBTA_A :=  TERMINAL->SSBTA_A
         (DbfFile)->RETRN_C :=  TERMINAL->RETRN_C
         (DbfFile)->RETRN_A :=  TERMINAL->RETRN_A
         (DbfFile)->REFND_C :=  TERMINAL->REFND_C
         (DbfFile)->REFND_A :=  TERMINAL->REFND_A
         (DbfFile)->OTINC_C :=  TERMINAL->OTINC_C
         (DbfFile)->OTINC_A :=  TERMINAL->OTINC_A
         (DbfFile)->CANCL_C :=  TERMINAL->CANCL_C
         (DbfFile)->CANCL_A :=  TERMINAL->CANCL_A
         (DbfFile)->TVOID_C :=  TERMINAL->TVOID_C
         (DbfFile)->TVOID_A :=  TERMINAL->TVOID_A
         (DbfFile)->SUSPD_C :=  TERMINAL->SUSPD_C
         (DbfFile)->SUSPD_A :=  TERMINAL->SUSPD_A
         (DbfFile)->LAYAW_C :=  TERMINAL->LAYAW_C
         (DbfFile)->LAYAW_A :=  TERMINAL->LAYAW_A
         (DbfFile)->PIKUP_C :=  TERMINAL->PIKUP_C
         (DbfFile)->PIKUP_A :=  TERMINAL->PIKUP_A
         (DbfFile)->PDOUT_C :=  TERMINAL->PDOUT_C
         (DbfFile)->PDOUT_A :=  TERMINAL->PDOUT_A
         (DbfFile)->LOAN_C :=   TERMINAL->LOAN_C
         (DbfFile)->LOAN_A :=   TERMINAL->LOAN_A
         (DbfFile)->RECACT_C := TERMINAL->RECACT_C
         (DbfFile)->RECACT_A := TERMINAL->RECACT_A
         (DbfFile)->BOTDEP_C := TERMINAL->BOTDEP_C
         (DbfFile)->BOTDEP_A := TERMINAL->BOTDEP_A
         (DbfFile)->TRAIN_A :=  TERMINAL->TRAIN_A
         (DbfFile)->OFFLN_A :=  TERMINAL->OFFLN_A
         (DbfFile)->RENTER_A := TERMINAL->RENTER_A
         (DbfFile)->OLDGRD_A := TERMINAL->OLDGRD_A
         (DbfFile)->NEWGRD_A := TERMINAL->NEWGRD_A
         (DbfFile)->XCOUNT_C := TERMINAL->XCOUNT_C
         (DbfFile)->ZCOUNT_C := TERMINAL->ZCOUNT_C

         TERMINAL->(RecLock(0))
         TERMINAL->(DbDelete())
         TERMINAL->(DbUnLock())
      endif   
      TERMINAL->(DbSkip())
   enddo 
   TERMINAL->(DbCloseArea())
   (DbfFile)->(DbCloseArea())
   if NetUse("TERMINAL",DB_EXCLUSIVE,NUM_SECONDS)   
      Set index to TERMINAL
      TERMINAL->(__DbPack())
      TERMINAL->(DbCloseArea())
   ENDIF   
   BUMMER()
   HEYTHERE()


/*================ RETURN =======================*/
  mpath := "retn"+ substr(dtoc(dstartdate),1,2) + substr(dtoc(dstartdate),7,2) 
  if !file(cpath+mpath+".dbf")
   NetUse("RET",DB_SHARED,NUM_SECONDS)   
   copy stru to (cpath) + (mpath)+".dbf"
   RET->(DbCloseArea())
  endif 

   if NetUse(cpath + mpath,DB_EXCLUSIVE,NUM_SECONDS)   
      DbfFile := alias()
   endif   
  
   if NetUse("RET",DB_SHARED,NUM_SECONDS)   
     Index on RET->PLUCODE+DTOS(RET->DATE) to RET
   endif
   
   
   Do while RET->(!Eof())
      if RET->DATE >= dstartdate .and. RET->DATE <= dEndDate .and. RET->(!Deleted())
         (DbfFile)->(DbAppend())
         (DbfFile)->DATE    := RET->DATE
         (DbfFile)->PLUCODE := RET->PLUCODE
         (DbfFile)->RDESC   := RET->RDESC
         (DbfFile)->RDEPT   := RET->RDEPT
         (DbfFile)->RCOUNT  := RET->RCOUNT
         (DbfFile)->RAMOUNT := RET->RAMOUNT

         RET->(RecLock(0))
         RET->(DbDelete())
         RET->(DbUnLock())

      endif   
      RET->(DbSkip())
   enddo 
   RET->(DbCloseArea())
   (DbfFile)->(DbCloseArea())
   if NetUse("RET",DB_EXCLUSIVE,NUM_SECONDS)   
      Set index to RET
      RET->(__DbPack())
      RET->(DbCloseArea())
   ENDIF      
   BUMMER()
   HEYTHERE()


/*================ DEPARTMENT =======================*/
  mpath := "dept"+ substr(dtoc(dstartdate),1,2) + substr(dtoc(dstartdate),7,2) 
  if !file(cpath+mpath+".dbf")
   NetUse("DEPT",DB_SHARED,NUM_SECONDS)   
   copy stru to (cpath) + (mpath)+".dbf"
   DEPT->(DbCloseArea())
  endif 

   if NetUse(cpath + mpath,DB_EXCLUSIVE,NUM_SECONDS)   
      DbfFile := alias()
   endif   
  
   if NetUse("DEPT",DB_SHARED,NUM_SECONDS)   
     Index on DEPT->DCODE+DTOS(DEPT->DATE) to DEPT
   endif
   
   
   Do while DEPT->(!Eof())
      if DEPT->DATE >= dstartdate .and. DEPT->DATE <= dEndDate .and. DEPT->(!Deleted())
         (DbfFile)->(DbAppend())
         (DbfFile)->DATE    := DEPT->DATE
         (DbfFile)->DCODE := DEPT->DCODE
         (DbfFile)->DDESC   := DEPT->DDESC
         (DbfFile)->DCOUNT  := DEPT->DCOUNT
         (DbfFile)->DAMOUNT := DEPT->DAMOUNT

         DEPT->(RecLock(0))
         DEPT->(DbDelete())
         DEPT->(DbUnLock())

      endif   
      DEPT->(DbSkip())
   enddo 
   DEPT->(DbCloseArea())
   (DbfFile)->(DbCloseArea())
   if NetUse("DEPT",DB_EXCLUSIVE,NUM_SECONDS)   
      Set index to DEPT
      DEPT->(__DbPack())
      DEPT->(DbCloseArea())
   ENDIF      
   BUMMER()
   HEYTHERE()


/*================ PLUITEMS =======================*/

 mpath := "item"+ substr(dtoc(dstartdate),1,2) + substr(dtoc(dstartdate),7,2) 
 if !file((cpath)+mpath+".dbf")
   if NetUse("PLU",DB_SHARED,NUM_SECONDS)   
     copy stru to (cpath) +(mpath)+ ".dbf"
     PLU->(DbCloseArea())
   endif  
  endif 


   if NetUse((cpath)+(mpath),DB_SHARED,NUM_SECONDS)   
     DbfFile := alias()
   endif  
   
   if NetUse("PLU",DB_SHARED,NUM_SECONDS)   
      Index on PLU->CODE to PLU
   endif  

   
   PLU->(DbGoTop())
   Do while PLU->(!Eof())

     if PLU->DATE >= dstartdate .and. PLU->DATE <= dEndDate .AND. PLU->(!Deleted())

         (DbfFile)->(RecLock(0))
         (DbfFile)->(DbAppend())
         (DbfFile)->DATE    := PLU->DATE
         (DbfFile)->CODE    := PLU->CODE
         (DbfFile)->DESC    := PLU->DESC
         (DbfFile)->ICOUNT  := PLU->ICOUNT
         (DbfFile)->IAMOUNT := PLU->IAMOUNT
         (DbfFile)->I_UCOST := PLU->I_UCOST
         (DbfFile)->(DbUnLock())

         PLU->(RecLock(0))
         PLU->(DbDelete())
         PLU->(DbUnLock())
      endif   
      
      PLU->(DbSkip())
   enddo 
   
   PLU->(DbCloseArea())
   (DbfFile)->(DbCloseArea())
   if NetUse("PLU",DB_EXCLUSIVE,NUM_SECONDS)   
      Set index to PLU
      PLU->(__DbPack())
      
      PLU->(DbCloseArea())
   ENDIF         
   BUMMER()
   HEYTHERE()

/*================ NOT FOUND PLUITEMS =======================*/

 mpath := "nplu"+ substr(dtoc(dstartdate),1,2) + substr(dtoc(dstartdate),7,2) 
 if !file((cpath)+mpath+".dbf")
   if NetUse("NPLU",DB_SHARED,NUM_SECONDS)   
     copy stru to (cpath) +(mpath)+ ".dbf"
     NPLU->(DbCloseArea())
   endif  
  endif 


   if NetUse((cpath)+(mpath),DB_SHARED,NUM_SECONDS)   
     DbfFile := alias()
   endif  
   
   if NetUse("NPLU",DB_SHARED,NUM_SECONDS)   
      Index on NPLU->CODE to NPLU
   endif  

   
   NPLU->(DbGoTop())
   Do while NPLU->(!Eof())

     if NPLU->DATE >= dstartdate .and. NPLU->DATE <= dEndDate .AND. NPLU->(!Deleted())

         (DbfFile)->(RecLock(0))
         (DbfFile)->(DbAppend())
         (DbfFile)->DATE    := NPLU->DATE
         (DbfFile)->CODE    := NPLU->CODE
         (DbfFile)->ICOUNT  := NPLU->ICOUNT
         (DbfFile)->IAMOUNT := NPLU->IAMOUNT
         (DbfFile)->I_UCOST := NPLU->I_UCOST
         (DbfFile)->(DbUnLock())

         NPLU->(RecLock(0))
         NPLU->(DbDelete())
         NPLU->(DbUnLock())
      endif   
      
      NPLU->(DbSkip())
   enddo 
   
   NPLU->(DbCloseArea())
   (DbfFile)->(DbCloseArea())
   if NetUse("NPLU",DB_EXCLUSIVE,NUM_SECONDS)   
      Set index to NPLU
      NPLU->(__DbPack())
      
      NPLU->(DbCloseArea())
   ENDIF         
   BUMMER()
   HEYTHERE()


/*================ HOURLY =======================*/
  mpath := "hour"+ substr(dtoc(dstartdate),1,2) + substr(dtoc(dstartdate),7,2) 
  if !file(cpath+mpath+".dbf")
   NetUse("HOUR",DB_SHARED,NUM_SECONDS)   
   copy stru to (cpath) +(mpath)+ ".dbf"
   HOUR->(DbCloseArea())
  endif 

   if NetUse(cpath +mpath,DB_EXCLUSIVE,NUM_SECONDS)   
      DbfFile := alias()
   endif   
  
   if NetUse("HOUR",DB_SHARED,NUM_SECONDS)   
     index on HOUR->HOUR to HOUR
   endif
   
   Do while HOUR->(!Eof())
      if HOUR->DATE >= dstartdate .and. HOUR->DATE <= dEndDate .and. HOUR->(!Deleted())
         (DbfFile)->(DbAppend())
         (DbfFile)->TERM    := HOUR->TERM
         (DbfFile)->DATE    := HOUR->DATE
         (DbfFile)->TIME    := HOUR->TIME
         (DbfFile)->HOUR    := HOUR->HOUR
         (DbfFile)->HCOUNT  := HOUR->HCOUNT
         (DbfFile)->HAMOUNT := HOUR->HAMOUNT

         HOUR->(RecLock(0))
         HOUR->(DbDelete())
         HOUR->(DbUnLock())

      endif   
      HOUR->(DbSkip())
   enddo 
   HOUR->(DbCloseArea())
   (DbfFile)->(DbCloseArea())
   if NetUse("HOUR",DB_EXCLUSIVE,NUM_SECONDS)   
      Set index to HOUR
      HOUR->(__DbPack())
      HOUR->(DbCloseArea())
   ENDIF            
   BUMMER()
   HEYTHERE()


/*================ CCD =======================*/
  mpath := "ccd"+ substr(dtoc(dstartdate),1,2) + substr(dtoc(dstartdate),7,2) 
  if !file(cpath+mpath+".DBF")
   NetUse("CCD",DB_SHARED,NUM_SECONDS)   
   copy stru to (cpath) +(mpath)+ ".DBF"
   CCD->(DbCloseArea())
  endif 

   if NetUse(cpath + mpath,DB_EXCLUSIVE,NUM_SECONDS)   
      DbfFile := alias()
   endif   
  
   if NetUse("CCD",DB_SHARED,NUM_SECONDS)   
      index on DTOS(CCD->DATE)+CCD->CASH_CODE+CCD->BANK_CODE+str(CCD->DENOM) to CCD
   endif
   
   while CCD->(!Eof())
      if CCD->DATE >= dstartdate .and. CCD->DATE <= dEndDate .and. CCD->(!Deleted())
         (DbfFile)->(DbAppend())         
         (DbfFile)->DATE       := CCD->DATE
         (DbfFile)->CASH_CODE  := CCD->CASH_CODE
         (DbfFile)->BANK_CODE  := CCD->BANK_CODE
         (DbfFile)->CCD_COUNT  := CCD->CCD_COUNT
         (DbfFile)->DENOM      := CCD->DENOM
         (DbfFile)->CCD_AMOUNT := CCD->CCD_AMOUNT

         CCD->(RecLock(0))
         CCD->(DbDelete())
         CCD->(DbUnLock())

      endif   
      CCD->(DbSkip())
   enddo 
   CCD->(DbCloseArea())
   (DbfFile)->(DbCloseArea())
   if NetUse("CCD",DB_EXCLUSIVE,NUM_SECONDS)   
      Set index to CCD
      CCD->(__DbPack())
      CCD->(DbCloseArea())
   ENDIF            
   BUMMER()
   HEYTHERE()

/*================ CHARGE =======================*/
  mpath := "chrg"+ substr(dtoc(dstartdate),1,2) + substr(dtoc(dstartdate),7,2) 
  if !file(cpath+mpath+".DBF")
   NetUse("CHARGE",DB_SHARED,NUM_SECONDS)   
   copy stru to (cpath) + (mpath)+ ".DBF"
   CHARGE->(DbCloseArea())
  endif 

   if NetUse(cpath + mpath,DB_EXCLUSIVE,NUM_SECONDS)   
      DbfFile := alias()
   endif   
  
   if NetUse("CHARGE",DB_SHARED,NUM_SECONDS)   
      index on DTOS(CHARGE->DATE)+CHARGE->POS_NO + CHARGE->PAY_TYPE to CHARGE
   endif

   while CHARGE->(!Eof())
      if CHARGE->DATE >= dStartDate .and. CHARGE->DATE <= dEndDate .and. CHARGE->(!Deleted())
         (DbfFile)->(DbAppend())         
         (DbfFile)->POS_NO    := CHARGE->POS_NO
         (DbfFile)->DATE      := CHARGE->DATE
         (DbfFile)->TIME      := CHARGE->TIME
         (DbfFile)->CASH_CODE := CHARGE->CASH_CODE
         (DbfFile)->SLS_AMOUNT:= CHARGE->SLS_AMOUNT
         (DbfFile)->PAY_TYPE  := CHARGE->PAY_TYPE
         (DbfFile)->ACCT_NO   := CHARGE->ACCT_NO

         CHARGE->(RecLock(0))
         CHARGE->(DbDelete())
         CHARGE->(DbUnLock())

      endif      

      CHARGE->(DbSkip())
   enddo 
   CHARGE->(DbCloseArea())
   (DbfFile)->(DbCloseArea())
   if NetUse("CHARGE",DB_EXCLUSIVE,NUM_SECONDS)   
      Set index to CHARGE
      CHARGE->(__DbPack())
      CHARGE->(DbCloseArea())
   ENDIF            
   BUMMER()
   HEYTHERE()


/*=============================================================*/      


   Reindex() 
   

  endif  // getdates()
  
return nil




function Retrv()

local nFhandle, wChange, nFhandle1
local getlist := {}, dbffile, oldpath 
local cpath := "C:\"+curdir() + "\BACKUP\"
local mpath

if file(".\"+"RP.TXT")
  nFHandle:=fopen(".\"+"RP.TXT")
  cPath := freadstr(nFHandle,35)
  fclose(nFHandle)
endif     

cPath := padr(alltrim(cPath),35) 
wChange := OpenWindow(5,10,9,75,"Data Path Editing")
setcursor(SC_NORMAL)
@  6,10 to 9,75 double
@  7,12 say "ENTER SOURCE PATH : " get cPath pict "@! " +REPL("X",35)
read
CloseWindow(wChange)  
setcursor(SC_NONE) 
cPath := ALLTRIM(cPath)
if substr(cpath,len(cPath),1) != "\"
  cPath += "\"
endif  

   
 // save new path to file
 if lastkey() != K_ESC
   if file("RP.TXT")
     ferase("RP.TXT")
   endif  
   nFHandle := fcreate("RP.TXT",FC_NORMAL)
   fwrite(nFHandle,cPath)
   fclose(nFHandle)          
 else
   BUMMER()
   return nil
 endif


if (nFHandle1 := fcreate((cpath)+"TMP.DAT", FC_NORMAL)) == -1   // to test if network exist
     BUMMER()
     alert("Drive does not exist or Insufficient disk space",{"Quit"})  
     return nil
endif     


if Getdates()

   message("Copying Files ....")

/*================ CASHIER =======================*/

   mpath := "cash"+ substr(dtoc(dstartdate),1,2) + substr(dtoc(dstartdate),7,2) 
   if NetUse(cpath + mpath,DB_EXCLUSIVE,NUM_SECONDS)   
      DbfFile := alias()
   endif   
  
   if NetUse("CASH",DB_SHARED,NUM_SECONDS)   
      Index on CASH->CODE to CAS
   endif
   
   
   Do while (DbfFile)->(!Eof())
      if (DbfFile)->DATE >= dStartDate .and. (DbfFile)->DATE <= dEndDate .AND. (DbfFile)->(!Deleted())
         CASH->(DbAppend())
         CASH->TERM    := (DbfFile)->TERM
         CASH->DATE    := (DbfFile)->DATE
         CASH->TIME    := (DbfFile)->TIME
         CASH->CODE    := (DbfFile)->CODE
         CASH->NAME    := (DbfFile)->NAME
         CASH->DAILY_C := (DbfFile)->DAILY_C
         CASH->DAILY_A := (DbfFile)->DAILY_A
         CASH->CASH_A  := (DbfFile)->CASH_A
         CASH->GROSS_A := (DbfFile)->GROSS_A
         CASH->DEPT_A  := (DbfFile)->DEPT_A
         CASH->FORCUR_C := (DbfFile)->FORCUR_C
         CASH->FORCUR_A := (DbfFile)->FORCUR_A
         CASH->MISC01_C := (DbfFile)->MISC01_C
         CASH->MISC01_A := (DbfFile)->MISC01_A
         CASH->MISC02_C := (DbfFile)->MISC02_C
         CASH->MISC02_A := (DbfFile)->MISC02_A
         CASH->MISC03_C := (DbfFile)->MISC03_C
         CASH->MISC03_A := (DbfFile)->MISC03_A
         CASH->MISC04_C := (DbfFile)->MISC04_C
         CASH->MISC04_A := (DbfFile)->MISC04_A
         CASH->MISC05_C := (DbfFile)->MISC05_C
         CASH->MISC05_A := (DbfFile)->MISC05_A
         CASH->MISC06_C := (DbfFile)->MISC06_C
         CASH->MISC06_A := (DbfFile)->MISC06_A
         CASH->MISC07_C := (DbfFile)->MISC07_C
         CASH->MISC07_A := (DbfFile)->MISC07_A
         CASH->MISC08_C := (DbfFile)->MISC08_C
         CASH->MISC08_A := (DbfFile)->MISC08_A
         CASH->MISC09_C := (DbfFile)->MISC09_C
         CASH->MISC09_A := (DbfFile)->MISC09_A
         CASH->MISC10_C := (DbfFile)->MISC10_C
         CASH->MISC10_A := (DbfFile)->MISC10_A
         CASH->MISC11_C := (DbfFile)->MISC11_C
         CASH->MISC11_A := (DbfFile)->MISC11_A
         CASH->MISC12_C := (DbfFile)->MISC12_C
         CASH->MISC12_A := (DbfFile)->MISC12_A
         CASH->MISC13_C := (DbfFile)->MISC13_C
         CASH->MISC13_A := (DbfFile)->MISC13_A
         CASH->MISC14_C := (DbfFile)->MISC14_C
         CASH->MISC14_A := (DbfFile)->MISC14_A
         CASH->MISC15_C := (DbfFile)->MISC15_C
         CASH->MISC15_A := (DbfFile)->MISC15_A
         CASH->MISC16_C := (DbfFile)->MISC16_C
         CASH->MISC16_A := (DbfFile)->MISC16_A
         CASH->MISC17_C := (DbfFile)->MISC17_C
         CASH->MISC17_A := (DbfFile)->MISC17_A
         CASH->MISC18_C := (DbfFile)->MISC18_C
         CASH->MISC18_A := (DbfFile)->MISC18_A
         CASH->MISC19_C := (DbfFile)->MISC19_C
         CASH->MISC19_A := (DbfFile)->MISC19_A
         CASH->MISC20_C := (DbfFile)->MISC20_C
         CASH->MISC20_A := (DbfFile)->MISC20_A
         CASH->MISC21_C := (DbfFile)->MISC21_C
         CASH->MISC21_A := (DbfFile)->MISC21_A
         CASH->MISC22_C := (DbfFile)->MISC22_C
         CASH->MISC22_A := (DbfFile)->MISC22_A
         CASH->MISC23_C := (DbfFile)->MISC23_C
         CASH->MISC23_A := (DbfFile)->MISC23_A
         CASH->MISC24_C := (DbfFile)->MISC24_C
         CASH->MISC24_A := (DbfFile)->MISC24_A
         CASH->MISC25_C := (DbfFile)->MISC25_C
         CASH->MISC25_A := (DbfFile)->MISC25_A
         CASH->MISC26_C := (DbfFile)->MISC26_C
         CASH->MISC26_A := (DbfFile)->MISC26_A
         CASH->MISC27_C := (DbfFile)->MISC27_C
         CASH->MISC27_A := (DbfFile)->MISC27_A
         CASH->MISC28_C := (DbfFile)->MISC28_C
         CASH->MISC28_A := (DbfFile)->MISC28_A
         CASH->MISC29_C := (DbfFile)->MISC29_C
         CASH->MISC29_A := (DbfFile)->MISC29_A
         CASH->MISC30_C := (DbfFile)->MISC30_C
         CASH->MISC30_A := (DbfFile)->MISC30_A
         CASH->MISC31_C := (DbfFile)->MISC31_C
         CASH->MISC31_A := (DbfFile)->MISC31_A
         CASH->MISC32_C := (DbfFile)->MISC32_C
         CASH->MISC32_A := (DbfFile)->MISC32_A
         CASH->MISC33_C := (DbfFile)->MISC33_C
         CASH->MISC33_A := (DbfFile)->MISC33_A
         CASH->MISC34_C := (DbfFile)->MISC34_C
         CASH->MISC34_A := (DbfFile)->MISC34_A
         CASH->MISC35_C := (DbfFile)->MISC35_C
         CASH->MISC35_A := (DbfFile)->MISC35_A
         CASH->MISC36_C := (DbfFile)->MISC36_C
         CASH->MISC36_A := (DbfFile)->MISC36_A
         CASH->MISC37_C := (DbfFile)->MISC37_C
         CASH->MISC37_A := (DbfFile)->MISC37_A
         CASH->MISC38_C := (DbfFile)->MISC38_C
         CASH->MISC38_A := (DbfFile)->MISC38_A
         CASH->MISC39_C := (DbfFile)->MISC39_C
         CASH->MISC39_A := (DbfFile)->MISC39_A
         CASH->MISC40_C := (DbfFile)->MISC40_C
         CASH->MISC40_A := (DbfFile)->MISC40_A
         CASH->MISC41_C := (DbfFile)->MISC41_C
         CASH->MISC41_A := (DbfFile)->MISC41_A
         CASH->MISC42_C := (DbfFile)->MISC42_C
         CASH->MISC42_A := (DbfFile)->MISC42_A
         CASH->MISC43_C := (DbfFile)->MISC43_C
         CASH->MISC43_A := (DbfFile)->MISC43_A
         CASH->MISC44_C := (DbfFile)->MISC44_C
         CASH->MISC44_A := (DbfFile)->MISC44_A
         CASH->MISC45_C := (DbfFile)->MISC45_C
         CASH->MISC45_A := (DbfFile)->MISC45_A
         CASH->MISC46_C := (DbfFile)->MISC46_C
         CASH->MISC46_A := (DbfFile)->MISC46_A
         CASH->MISC47_C := (DbfFile)->MISC47_C
         CASH->MISC47_A := (DbfFile)->MISC47_A
         CASH->MISC48_C := (DbfFile)->MISC48_C
         CASH->MISC48_A := (DbfFile)->MISC48_A
         CASH->MISC49_C := (DbfFile)->MISC49_C
         CASH->MISC49_A := (DbfFile)->MISC49_A
         CASH->MISC50_C := (DbfFile)->MISC50_C
         CASH->MISC50_A := (DbfFile)->MISC50_A
         CASH->IVOID_C :=  (DbfFile)->IVOID_C
         CASH->IVOID_A :=  (DbfFile)->IVOID_A
         CASH->MVOID_C :=  (DbfFile)->MVOID_C
         CASH->MVOID_A :=  (DbfFile)->MVOID_A
         CASH->IDISC_C :=  (DbfFile)->IDISC_C
         CASH->IDISC_A :=  (DbfFile)->IDISC_A
         CASH->SUBTD_C :=  (DbfFile)->SUBTD_C
         CASH->SUBTD_A :=  (DbfFile)->SUBTD_A
         CASH->ADDON_C :=  (DbfFile)->ADDON_C
         CASH->ADDON_A :=  (DbfFile)->ADDON_A
         CASH->SSBTD_C :=  (DbfFile)->SSBTD_C
         CASH->SSBTD_A :=  (DbfFile)->SSBTD_A
         CASH->SSBTA_C :=  (DbfFile)->SSBTA_C
         CASH->SSBTA_A :=  (DbfFile)->SSBTA_A
         CASH->RETRN_C :=  (DbfFile)->RETRN_C
         CASH->RETRN_A :=  (DbfFile)->RETRN_A
         CASH->REFND_C :=  (DbfFile)->REFND_C
         CASH->REFND_A :=  (DbfFile)->REFND_A
         CASH->OTINC_C :=  (DbfFile)->OTINC_C
         CASH->OTINC_A :=  (DbfFile)->OTINC_A
         CASH->CANCL_C :=  (DbfFile)->CANCL_C
         CASH->CANCL_A :=  (DbfFile)->CANCL_A
         CASH->TVOID_C :=  (DbfFile)->TVOID_C
         CASH->TVOID_A :=  (DbfFile)->TVOID_A
         CASH->SUSPD_C :=  (DbfFile)->SUSPD_C
         CASH->SUSPD_A :=  (DbfFile)->SUSPD_A
         CASH->LAYAW_C :=  (DbfFile)->LAYAW_C
         CASH->LAYAW_A :=  (DbfFile)->LAYAW_A
         CASH->PIKUP_C :=  (DbfFile)->PIKUP_C
         CASH->PIKUP_A :=  (DbfFile)->PIKUP_A
         CASH->PDOUT_C :=  (DbfFile)->PDOUT_C
         CASH->PDOUT_A :=  (DbfFile)->PDOUT_A
         CASH->LOAN_C :=   (DbfFile)->LOAN_C
         CASH->LOAN_A :=   (DbfFile)->LOAN_A
         CASH->RECACT_C := (DbfFile)->RECACT_C
         CASH->RECACT_A := (DbfFile)->RECACT_A
         CASH->BOTDEP_C := (DbfFile)->BOTDEP_C
         CASH->BOTDEP_A := (DbfFile)->BOTDEP_A
         CASH->CASHDEC :=  (DbfFile)->CASHDEC
         CASH->TRAIN_A :=  (DbfFile)->TRAIN_A
         CASH->OFFLN_A :=  (DbfFile)->OFFLN_A
         CASH->RENTER_A := (DbfFile)->RENTER_A
         CASH->OLDGRD_A := (DbfFile)->OLDGRD_A
         CASH->NEWGRD_A := (DbfFile)->NEWGRD_A
         CASH->XCOUNT_C := (DbfFile)->XCOUNT_C
         CASH->ZCOUNT_C := (DbfFile)->ZCOUNT_C

         (DbfFile)->(RecLock(0))
         (DbfFile)->(DbDelete())
         (DbfFile)->(DbUnLock())
      endif         
      (DbfFile)->(DbSkip())
   enddo 
   (DbfFile)->(DbCloseArea())
   CASH->(DbCloseArea())
   if NetUse(cpath + mpath,DB_EXCLUSIVE,NUM_SECONDS)   
      dbfFile := alias()
      index on (DbfFile)->CODE to CAS
      (DbfFile)->(__DbPack())
      (DbfFile)->(DbCloseArea())
   ENDIF   
   BUMMER()
   HEYTHERE()

   
/*================ TERMINAL =======================*/

   mpath := "term"+ substr(dtoc(dstartdate),1,2) + substr(dtoc(dstartdate),7,2) 
   if NetUse(cpath + mpath,DB_EXCLUSIVE,NUM_SECONDS)   
      DbfFile := alias()
   endif   
  
   if NetUse("TERMINAL",DB_SHARED,NUM_SECONDS)   
     Index on TERMINAL->TERM to TERMINAL
   endif
   
   
   Do while (DbfFile)->(!Eof())
      if (DbfFile)->DATE >= dStartDate .and. (DbfFile)->DATE <= dEndDate;
         .and. (DbfFile)->(!Deleted())
         TERMINAL->(DbAppend())
         TERMINAL->TERM    := (DbfFile)->TERM
         TERMINAL->DATE    := (DbfFile)->DATE
         TERMINAL->TIME    := (DbfFile)->TIME
         TERMINAL->DAILY_C := (DbfFile)->DAILY_C
         TERMINAL->DAILY_A := (DbfFile)->DAILY_A
         TERMINAL->CASH_A  := (DbfFile)->CASH_A
         TERMINAL->GROSS_A := (DbfFile)->GROSS_A
         TERMINAL->DEPT_A  := (DbfFile)->DEPT_A
         TERMINAL->FORCUR_C := (DbfFile)->FORCUR_C
         TERMINAL->FORCUR_A := (DbfFile)->FORCUR_A
         TERMINAL->MISC1_C := (DbfFile)->MISC1_C
         TERMINAL->MISC1_A := (DbfFile)->MISC1_A
         TERMINAL->MISC2_C := (DbfFile)->MISC2_C
         TERMINAL->MISC2_A := (DbfFile)->MISC2_A
         TERMINAL->MISC3_C := (DbfFile)->MISC3_C
         TERMINAL->MISC3_A := (DbfFile)->MISC3_A
         TERMINAL->MISC4_C := (DbfFile)->MISC4_C
         TERMINAL->MISC4_A := (DbfFile)->MISC4_A
         TERMINAL->MISC5_C := (DbfFile)->MISC5_C
         TERMINAL->MISC5_A := (DbfFile)->MISC5_A
         TERMINAL->MISC6_C := (DbfFile)->MISC6_C
         TERMINAL->MISC6_A := (DbfFile)->MISC6_A
         TERMINAL->MISC7_C := (DbfFile)->MISC7_C
         TERMINAL->MISC7_A := (DbfFile)->MISC7_A
         TERMINAL->MISC8_C := (DbfFile)->MISC8_C
         TERMINAL->MISC8_A := (DbfFile)->MISC8_A
         TERMINAL->MISC9_C := (DbfFile)->MISC9_C
         TERMINAL->MISC9_A := (DbfFile)->MISC9_A
         TERMINAL->MISC10_C := (DbfFile)->MISC10_C
         TERMINAL->MISC10_A := (DbfFile)->MISC10_A
         TERMINAL->MISC11_C := (DbfFile)->MISC11_C
         TERMINAL->MISC11_A := (DbfFile)->MISC11_A
         TERMINAL->MISC12_C := (DbfFile)->MISC12_C
         TERMINAL->MISC12_A := (DbfFile)->MISC12_A
         TERMINAL->MISC13_C := (DbfFile)->MISC13_C
         TERMINAL->MISC13_A := (DbfFile)->MISC13_A
         TERMINAL->MISC14_C := (DbfFile)->MISC14_C
         TERMINAL->MISC14_A := (DbfFile)->MISC14_A
         TERMINAL->MISC15_C := (DbfFile)->MISC15_C
         TERMINAL->MISC15_A := (DbfFile)->MISC15_A
         TERMINAL->MISC16_C := (DbfFile)->MISC16_C
         TERMINAL->MISC16_A := (DbfFile)->MISC16_A
         TERMINAL->MISC17_C := (DbfFile)->MISC17_C
         TERMINAL->MISC17_A := (DbfFile)->MISC17_A
         TERMINAL->MISC18_C := (DbfFile)->MISC18_C
         TERMINAL->MISC18_A := (DbfFile)->MISC18_A
         TERMINAL->MISC19_C := (DbfFile)->MISC19_C
         TERMINAL->MISC19_A := (DbfFile)->MISC19_A
         TERMINAL->MISC20_C := (DbfFile)->MISC20_C
         TERMINAL->MISC20_A := (DbfFile)->MISC20_A
         TERMINAL->MISC21_C := (DbfFile)->MISC21_C
         TERMINAL->MISC21_A := (DbfFile)->MISC21_A
         TERMINAL->MISC22_C := (DbfFile)->MISC22_C
         TERMINAL->MISC22_A := (DbfFile)->MISC22_A
         TERMINAL->MISC23_C := (DbfFile)->MISC23_C
         TERMINAL->MISC23_A := (DbfFile)->MISC23_A
         TERMINAL->MISC24_C := (DbfFile)->MISC24_C
         TERMINAL->MISC24_A := (DbfFile)->MISC24_A
         TERMINAL->MISC25_C := (DbfFile)->MISC25_C
         TERMINAL->MISC25_A := (DbfFile)->MISC25_A
         TERMINAL->MISC26_C := (DbfFile)->MISC26_C
         TERMINAL->MISC26_A := (DbfFile)->MISC26_A
         TERMINAL->MISC27_C := (DbfFile)->MISC27_C
         TERMINAL->MISC27_A := (DbfFile)->MISC27_A
         TERMINAL->MISC28_C := (DbfFile)->MISC28_C
         TERMINAL->MISC28_A := (DbfFile)->MISC28_A
         TERMINAL->MISC29_C := (DbfFile)->MISC29_C
         TERMINAL->MISC29_A := (DbfFile)->MISC29_A
         TERMINAL->MISC30_C := (DbfFile)->MISC30_C
         TERMINAL->MISC30_A := (DbfFile)->MISC30_A
         TERMINAL->MISC31_C := (DbfFile)->MISC31_C
         TERMINAL->MISC31_A := (DbfFile)->MISC31_A
         TERMINAL->MISC32_C := (DbfFile)->MISC32_C
         TERMINAL->MISC32_A := (DbfFile)->MISC32_A
         TERMINAL->MISC33_C := (DbfFile)->MISC33_C
         TERMINAL->MISC33_A := (DbfFile)->MISC33_A
         TERMINAL->MISC34_C := (DbfFile)->MISC34_C
         TERMINAL->MISC34_A := (DbfFile)->MISC34_A
         TERMINAL->MISC35_C := (DbfFile)->MISC35_C
         TERMINAL->MISC35_A := (DbfFile)->MISC35_A
         TERMINAL->MISC36_C := (DbfFile)->MISC36_C
         TERMINAL->MISC36_A := (DbfFile)->MISC36_A
         TERMINAL->MISC37_C := (DbfFile)->MISC37_C
         TERMINAL->MISC37_A := (DbfFile)->MISC37_A
         TERMINAL->MISC38_C := (DbfFile)->MISC38_C
         TERMINAL->MISC38_A := (DbfFile)->MISC38_A
         TERMINAL->MISC39_C := (DbfFile)->MISC39_C
         TERMINAL->MISC39_A := (DbfFile)->MISC39_A
         TERMINAL->MISC40_C := (DbfFile)->MISC40_C
         TERMINAL->MISC40_A := (DbfFile)->MISC40_A
         TERMINAL->MISC41_C := (DbfFile)->MISC41_C
         TERMINAL->MISC41_A := (DbfFile)->MISC41_A
         TERMINAL->MISC42_C := (DbfFile)->MISC42_C
         TERMINAL->MISC42_A := (DbfFile)->MISC42_A
         TERMINAL->MISC43_C := (DbfFile)->MISC43_C
         TERMINAL->MISC43_A := (DbfFile)->MISC43_A
         TERMINAL->MISC44_C := (DbfFile)->MISC44_C
         TERMINAL->MISC44_A := (DbfFile)->MISC44_A
         TERMINAL->MISC45_C := (DbfFile)->MISC45_C
         TERMINAL->MISC45_A := (DbfFile)->MISC45_A
         TERMINAL->MISC46_C := (DbfFile)->MISC46_C
         TERMINAL->MISC46_A := (DbfFile)->MISC46_A
         TERMINAL->MISC47_C := (DbfFile)->MISC47_C
         TERMINAL->MISC47_A := (DbfFile)->MISC47_A
         TERMINAL->MISC48_C := (DbfFile)->MISC48_C
         TERMINAL->MISC48_A := (DbfFile)->MISC48_A
         TERMINAL->MISC49_C := (DbfFile)->MISC49_C
         TERMINAL->MISC49_A := (DbfFile)->MISC49_A
         TERMINAL->MISC50_C := (DbfFile)->MISC50_C
         TERMINAL->MISC50_A := (DbfFile)->MISC50_A
         TERMINAL->IVOID_C :=  (DbfFile)->IVOID_C
         TERMINAL->IVOID_A :=  (DbfFile)->IVOID_A
         TERMINAL->MVOID_C :=  (DbfFile)->MVOID_C
         TERMINAL->MVOID_A :=  (DbfFile)->MVOID_A
         TERMINAL->IDISC_C :=  (DbfFile)->IDISC_C
         TERMINAL->IDISC_A :=  (DbfFile)->IDISC_A
         TERMINAL->SUBTD_C :=  (DbfFile)->SUBTD_C
         TERMINAL->SUBTD_A :=  (DbfFile)->SUBTD_A
         TERMINAL->ADDON_C :=  (DbfFile)->ADDON_C
         TERMINAL->ADDON_A :=  (DbfFile)->ADDON_A
         TERMINAL->SSBTD_C :=  (DbfFile)->SSBTD_C
         TERMINAL->SSBTD_A :=  (DbfFile)->SSBTD_A
         TERMINAL->SSBTA_C :=  (DbfFile)->SSBTA_C
         TERMINAL->SSBTA_A :=  (DbfFile)->SSBTA_A
         TERMINAL->RETRN_C :=  (DbfFile)->RETRN_C
         TERMINAL->RETRN_A :=  (DbfFile)->RETRN_A
         TERMINAL->REFND_C :=  (DbfFile)->REFND_C
         TERMINAL->REFND_A :=  (DbfFile)->REFND_A
         TERMINAL->OTINC_C :=  (DbfFile)->OTINC_C
         TERMINAL->OTINC_A :=  (DbfFile)->OTINC_A
         TERMINAL->CANCL_C :=  (DbfFile)->CANCL_C
         TERMINAL->CANCL_A :=  (DbfFile)->CANCL_A
         TERMINAL->TVOID_C :=  (DbfFile)->TVOID_C
         TERMINAL->TVOID_A :=  (DbfFile)->TVOID_A
         TERMINAL->SUSPD_C :=  (DbfFile)->SUSPD_C
         TERMINAL->SUSPD_A :=  (DbfFile)->SUSPD_A
         TERMINAL->LAYAW_C :=  (DbfFile)->LAYAW_C
         TERMINAL->LAYAW_A :=  (DbfFile)->LAYAW_A
         TERMINAL->PIKUP_C :=  (DbfFile)->PIKUP_C
         TERMINAL->PIKUP_A :=  (DbfFile)->PIKUP_A
         TERMINAL->PDOUT_C :=  (DbfFile)->PDOUT_C
         TERMINAL->PDOUT_A :=  (DbfFile)->PDOUT_A
         TERMINAL->LOAN_C :=   (DbfFile)->LOAN_C
         TERMINAL->LOAN_A :=   (DbfFile)->LOAN_A
         TERMINAL->RECACT_C := (DbfFile)->RECACT_C
         TERMINAL->RECACT_A := (DbfFile)->RECACT_A
         TERMINAL->BOTDEP_C := (DbfFile)->BOTDEP_C
         TERMINAL->BOTDEP_A := (DbfFile)->BOTDEP_A
         TERMINAL->TRAIN_A :=  (DbfFile)->TRAIN_A
         TERMINAL->OFFLN_A :=  (DbfFile)->OFFLN_A
         TERMINAL->RENTER_A := (DbfFile)->RENTER_A
         TERMINAL->OLDGRD_A := (DbfFile)->OLDGRD_A
         TERMINAL->NEWGRD_A := (DbfFile)->NEWGRD_A
         TERMINAL->XCOUNT_C := (DbfFile)->XCOUNT_C
         TERMINAL->ZCOUNT_C := (DbfFile)->ZCOUNT_C

         (DbfFile)->(RecLock(0))
         (DbfFile)->(DbDelete())
         (DbfFile)->(DbUnLock())
      endif   
      (DbfFile)->(DbSkip())
   enddo 
   (DbfFile)->(DbCloseArea())
   TERMINAL->(DbCloseArea())
   if NetUse(cpath + mpath,DB_EXCLUSIVE,NUM_SECONDS)   
      dbffile := alias()
      index on (DbfFile)->TERM to TERMINAL
      (DbfFile)->(__DbPack())
      (DbfFile)->(DbCloseArea())
   ENDIF   
   BUMMER()
   HEYTHERE()


/*================ RETURN =======================*/
   mpath := "retn"+ substr(dtoc(dstartdate),1,2) + substr(dtoc(dstartdate),7,2) 
   if NetUse(cpath + mpath,DB_EXCLUSIVE,NUM_SECONDS)   
      DbfFile := alias()
   endif   
  
   if NetUse("RET",DB_SHARED,NUM_SECONDS)   
     Index on RET->PLUCODE+DTOS(RET->DATE) to RET
   endif
   
   
   Do while (DbfFile)->(!Eof())
      if (DbfFile)->DATE >= dStartDate .and. (DbfFile)->DATE <= dEndDate .and. (DbfFile)->(!Deleted())
         RET->(DbAppend())
         RET->DATE    := (DbfFile)->DATE
         RET->PLUCODE := (DbfFile)->PLUCODE
         RET->RDESC   := (DbfFile)->RDESC
         RET->RDEPT   := (DbfFile)->RDEPT
         RET->RCOUNT  := (DbfFile)->RCOUNT
         RET->RAMOUNT := (DbfFile)->RAMOUNT

         (DbfFile)->(RecLock(0))
         (DbfFile)->(DbDelete())
         (DbfFile)->(DbUnLock())

      endif   
      (DbfFile)->(DbSkip())
   enddo 
   (DbfFile)->(DbCloseArea())
   RET->(DbCloseArea())
   if NetUse(cpath + mpath,DB_EXCLUSIVE,NUM_SECONDS)   
      dbffile := alias()
      Index on (DbfFile)->PLUCODE+DTOS((DbfFile)->DATE) to RET
      (DbfFile)->(__DbPack())
      (DbfFile)->(DbCloseArea())
   ENDIF      
   BUMMER()
   HEYTHERE()


/*================ DEPARTMENT =======================*/

   mpath := "dept"+ substr(dtoc(dstartdate),1,2) + substr(dtoc(dstartdate),7,2) 
   if NetUse(cpath + mpath,DB_EXCLUSIVE,NUM_SECONDS)   
      DbfFile := alias()
   endif   
  
   if NetUse("DEPT",DB_SHARED,NUM_SECONDS)   
     Index on DEPT->DCODE+DTOS(DEPT->DATE) to DEPT
   endif
   
   
   Do while (DbfFile)->(!Eof())
      if (DbfFile)->DATE >= dStartDate .and. (DbfFile)->DATE <= dEndDate .and. (DbfFile)->(!Deleted())
         DEPT->(DbAppend())
         DEPT->DATE    := (DbfFile)->DATE
         DEPT->DCODE   := (DbfFile)->DCODE
         DEPT->DDESC   := (DbfFile)->DDESC
         DEPT->DCOUNT  := (DbfFile)->DCOUNT
         DEPT->DAMOUNT := (DbfFile)->DAMOUNT

         (DbfFile)->(RecLock(0))
         (DbfFile)->(DbDelete())
         (DbfFile)->(DbUnLock())

      endif   
      (DbfFile)->(DbSkip())
   enddo 
   (DbfFile)->(DbCloseArea())
   DEPT->(DbCloseArea())
   if NetUse(cpath + mpath,DB_EXCLUSIVE,NUM_SECONDS)   
      dbffile := alias()
      Index on (DbfFile)->DCODE+DTOS((DbfFile)->DATE) to DEPT
      (DbfFile)->(__DbPack())
      (DbfFile)->(DbCloseArea())
   ENDIF      
   BUMMER()
   HEYTHERE()


/*================ PLUITEMS =======================*/


   mpath := "item"+ substr(dtoc(dstartdate),1,2) + substr(dtoc(dstartdate),7,2) 
   if NetUse((cpath)+ (mpath),DB_SHARED,NUM_SECONDS)   
     DbfFile := alias()
   endif  
   
   if NetUse("PLU",DB_SHARED,NUM_SECONDS)   
      Index on PLU->CODE to PLU
   endif  

   
   (DbfFile)->(DbGoTop())
   Do while (DbfFile)->(!Eof())

     if (DbfFile)->DATE >= dStartDate .and. (DbfFile)->DATE <= dEndDate .AND. (DbfFile)->(!Deleted())

         PLU->(RecLock(0))
         PLU->(DbAppend())
         PLU->DATE    := (DbfFile)->DATE
         PLU->CODE    := (DbfFile)->CODE
         PLU->DESC    := (DbfFile)->DESC
         PLU->ICOUNT  := (DbfFile)->ICOUNT
         PLU->IAMOUNT := (DbfFile)->IAMOUNT
         PLU->I_UCOST := (DbfFile)->I_UCOST
         PLU->(DbUnLock())

         (DbfFile)->(RecLock(0))
         (DbfFile)->(DbDelete())
         (DbfFile)->(DbUnLock())
      endif   
      
      (DbfFile)->(DbSkip())
   enddo 
   
   (DbfFile)->(DbCloseArea())
   PLU->(DbCloseArea())
   if NetUse(cpath + mpath,DB_EXCLUSIVE,NUM_SECONDS)   
      dbffile := alias()
      Index on (DbfFile)->CODE to PLU
      (DbfFile)->(__DbPack())
      (DbfFile)->(DbCloseArea())
   ENDIF         
   BUMMER()
   HEYTHERE()

/*================ NOT FOUND PLUITEMS =======================*/


   mpath := "nplu"+ substr(dtoc(dstartdate),1,2) + substr(dtoc(dstartdate),7,2) 
   if NetUse((cpath)+ (mpath),DB_SHARED,NUM_SECONDS)   
     DbfFile := alias()
   endif  
   
   if NetUse("NPLU",DB_SHARED,NUM_SECONDS)   
      Index on NPLU->CODE to NPLU
   endif  

   
   (DbfFile)->(DbGoTop())
   Do while (DbfFile)->(!Eof())

     if (DbfFile)->DATE >= dStartDate .and. (DbfFile)->DATE <= dEndDate .AND. (DbfFile)->(!Deleted())

         NPLU->(RecLock(0))
         NPLU->(DbAppend())
         NPLU->DATE    := (DbfFile)->DATE
         NPLU->CODE    := (DbfFile)->CODE
         NPLU->ICOUNT  := (DbfFile)->ICOUNT
         NPLU->IAMOUNT := (DbfFile)->IAMOUNT
         NPLU->I_UCOST := (DbfFile)->I_UCOST
         NPLU->(DbUnLock())

         (DbfFile)->(RecLock(0))
         (DbfFile)->(DbDelete())
         (DbfFile)->(DbUnLock())
      endif   
      
      (DbfFile)->(DbSkip())
   enddo 
   
   (DbfFile)->(DbCloseArea())
   NPLU->(DbCloseArea())
   if NetUse(cpath + mpath,DB_EXCLUSIVE,NUM_SECONDS)   
      dbffile := alias()
      Index on (DbfFile)->CODE to NPLU
      (DbfFile)->(__DbPack())
      (DbfFile)->(DbCloseArea())
   ENDIF         
   BUMMER()
   HEYTHERE()


/*================ HOURLY =======================*/
   
   mpath := "hour"+ substr(dtoc(dstartdate),1,2) + substr(dtoc(dstartdate),7,2) 
   if NetUse(cpath + mpath,DB_EXCLUSIVE,NUM_SECONDS)   
      DbfFile := alias()
   endif   
  
   if NetUse("HOUR",DB_SHARED,NUM_SECONDS)   
     index on HOUR->HOUR to HOUR
   endif
   
   Do while (DbfFile)->(!Eof())
      if (DbfFile)->DATE >= dStartDate .and. (DbfFile)->DATE <= dEndDate .and. (DbfFile)->(!Deleted())
         HOUR->(DbAppend())
         HOUR->TERM    := (DbfFile)->TERM
         HOUR->DATE    := (DbfFile)->DATE
         HOUR->TIME    := (DbfFile)->TIME
         HOUR->HOUR    := (DbfFile)->HOUR
         HOUR->HCOUNT  := (DbfFile)->HCOUNT
         HOUR->HAMOUNT := (DbfFile)->HAMOUNT

         (DbfFile)->(RecLock(0))
         (DbfFile)->(DbDelete())
         (DbfFile)->(DbUnLock())

      endif   
      (DbfFile)->(DbSkip())
   enddo 
   (DbfFile)->(DbCloseArea())
   HOUR->(DbCloseArea())
   if NetUse(cpath + mpath,DB_EXCLUSIVE,NUM_SECONDS)   
      dbffile := alias()
      index on (DbfFile)->HOUR to HOUR
      (DbfFile)->(__DbPack())
      (DbfFile)->(DbCloseArea())
   ENDIF            
   BUMMER()
   HEYTHERE()


/*================ CCD =======================*/

   mpath := "ccd"+ substr(dtoc(dstartdate),1,2) + substr(dtoc(dstartdate),7,2) 
   if NetUse(cpath + mpath,DB_EXCLUSIVE,NUM_SECONDS)   
      DbfFile := alias()
   endif   
  
   if NetUse("CCD",DB_SHARED,NUM_SECONDS)   
      index on DTOS(CCD->DATE)+CCD->CASH_CODE+CCD->BANK_CODE+str(CCD->DENOM) to CCD
   endif
   
   while (DbfFile)->(!Eof())
      if (DbfFile)->DATE >= dStartDate .and. (DbfFile)->DATE <= dEndDate .and. (DbfFile)->(!Deleted())
         CCD->(DbAppend())         
         CCD->DATE       := (DbfFile)->DATE
         CCD->CASH_CODE  := (DbfFile)->CASH_CODE
         CCD->BANK_CODE  := (DbfFile)->BANK_CODE
         CCD->CCD_COUNT  := (DbfFile)->CCD_COUNT
         CCD->DENOM      := (DbfFile)->DENOM
         CCD->CCD_AMOUNT := (DbfFile)->CCD_AMOUNT

         (DbfFile)->(RecLock(0))
         (DbfFile)->(DbDelete())
         (DbfFile)->(DbUnLock())

      endif   
      (DbfFile)->(DbSkip())
   enddo 
   (DbfFile)->(DbCloseArea())
   CCD->(DbCloseArea())
   if NetUse(cpath+mpath,DB_EXCLUSIVE,NUM_SECONDS)   
      (DbfFile)->(__DbPack())
      (DbfFile)->(DbCloseArea())
   ENDIF            
   BUMMER()
   HEYTHERE()


/*================ CHARGE =======================*/
   mpath := "chrg"+ substr(dtoc(dstartdate),1,2) + substr(dtoc(dstartdate),7,2) 
   if NetUse(cpath + mpath,DB_EXCLUSIVE,NUM_SECONDS)   
      DbfFile := alias()
   endif   
  
   if NetUse("CHARGE",DB_SHARED,NUM_SECONDS)   
      index on DTOS(CHARGE->DATE)+CHARGE->POS_NO + CHARGE->PAY_TYPE to CHARGE
   endif
   
   while (DbfFile)->(!Eof())
      if (DbfFile)->DATE >= dStartDate .and. (DbfFile)->DATE <= dEndDate .and. (DbfFile)->(!Deleted())
         CHARGE->(DbAppend())         
         CHARGE->POS_NO    := (DbfFile)->POS_NO
         CHARGE->DATE      := (DbfFile)->DATE
         CHARGE->TIME      := (DbfFile)->TIME
         CHARGE->CASH_CODE := (DbfFile)->CASH_CODE
         CHARGE->SLS_AMOUNT:= (DbfFile)->SLS_AMOUNT
         CHARGE->PAY_TYPE  := (DbfFile)->PAY_TYPE
         CHARGE->ACCT_NO   := (DbfFile)->ACCT_NO

         (DbfFile)->(RecLock(0))
         (DbfFile)->(DbDelete())
         (DbfFile)->(DbUnLock())

      endif   
      (DbfFile)->(DbSkip())
   enddo 
   (DbfFile)->(DbCloseArea())
   CHARGE->(DbCloseArea())
   if NetUse(cpath+mpath,DB_EXCLUSIVE,NUM_SECONDS)   
      (DbfFile)->(__DbPack())
      (DbfFile)->(DbCloseArea())
   ENDIF            
   BUMMER()
   HEYTHERE()

/*=============================================================*/   

   Reindex() 
      

  endif  // getdates()
  
return nil


STATIC FUNCTION freadln(handle, buffer, max_line)

	LOCAL line, eol, num_read, save_pos

	line := space(max_line)
	buffer := ""

	* save current file position for later seek
	save_pos := fseek(handle, 0, FS_RELATIVE)

	num_read := fread(handle, @line, max_line)

	IF (eol := at(CRLF, substr(line, 1, num_read))) == 0
		buffer := line
	ELSE
		* copy up to eol
		buffer := substr(line, 1, eol-1)
		* now position file to next line (skip lf) ...
		fseek(handle, save_pos + eol + 1, FS_SET )
	ENDIF

RETURN num_read != 0



function Export(sdate)

local nFhandle, wChange, nFhandle1
local cPAth := "C:\" +curdir() + "\BE\"
local getlist := {}, strdAte

if file(".\"+"FM.ID")
  nFHandle:=fopen(".\"+"FM.ID")
  cPath := freadstr(nFHandle,35)
  fclose(nFHandle)
endif     

cPath := padr(alltrim(cPath),35) 
wChange := OpenWindow(5,10,9,75,"Data Path Editing")
setcursor(SC_NORMAL)
@  6,10 to 9,75 double
@  7,12 say "ENTER DESTINATION PATH : " get cPath pict "@! " +REPL("X",35)
read
CloseWindow(wChange)  
setcursor(SC_NONE) 
cPath := ALLTRIM(cPath)
if substr(cpath,len(cPath),1) != "\"
  cPath += "\"
endif  

   
 // save new path to file
 if lastkey() != K_ESC
   if file("FM.ID")
     ferase("FM.ID")
   endif  
   nFHandle := fcreate("FM.ID",FC_NORMAL)
   fwrite(nFHandle,cPath)
   fclose(nFHandle)          
 else
   BUMMER()
   return nil
 endif


if (nFHandle1 := fcreate((cpath)+"TMP.DAT", FC_NORMAL)) == -1   // to test if network exist
     BUMMER()
     alert("Drive does not exist or Insufficient disk space",{"Quit"})  
     return nil
endif     

message("Copying Files ....")

strdate := dtoc(sdate)
if NetUSE("RET",DB_SHARED,NUM_SECONDS)
 copy to (cpath) + "RET" + substr(strdate,1,2) + substr(strdate,4,2) + "." + substr(strdate,7,2) + "0" for sdate == RET->DATE
 DbCloseAll()
endif 

if NetUSE("PLU",DB_SHARED,NUM_SECONDS)
 copy to (cpath) + "PLU" + substr(strdate,1,2) + substr(strdate,4,2) + "." + substr(strdate,7,2) + "0" for sdate == PLU->DATE
 DbCloseAll()
endif 

message("")

return nil















  
