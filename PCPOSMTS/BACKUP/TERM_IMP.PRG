#include "rpt.ch"
#include "janus.ch"
#include "fileio.ch"

#define F_BLOCK  1024
#define DATA_PATH  chr(65+curdrv())+":\"+curdir()+"\BACKUP\"   


function TERM_IMP(sdate)

local term, pos := 0, date, time := 0
local cFileName, cfile, cpath, cStr
local nFHandle, lfirst := .f., terminal_file
local strdate  := dtoc(sdate)
local nread := 0, cbuff,nFtarget, nFSource, nmove

terminal_file := "TERM" + substr(strdate,1,2) + substr(strdate,4,2) + "." + substr(strdate,7,2) + "0"


 if NetUse("UM",DB_SHARED,NUM_SECONDS)
    Set Index to UM
 endif

 if NetUse("TERMINAL",DB_SHARED,NUM_SECONDS)
   Set Index to TERMINAL
 endif

 Do While UM->(!Eof()) 
   
  if UM->(Deleted())
   UM->(DbSkip())
   loop
  endif
 
   cFilename :=  alltrim(UM->UMAC_PATH)+TERMINAL_FILE
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

    cStr := freadln(nFHandle)    

   
    Do Case
      Case SIGN == "TER"
         pos := at("<",cStr)
         term := substr(cStr,pos+1,4)
      Case substr(SIGN,3,1) == "/"   
         date := ctod(SUBSTR(cStr,1,8))
         time := val(SUBSTR(cStr,17,5))
         if lfirst
            TERMINAL->(DbUnLock())
            lfirst := .f.
         endif
      Case SIGN == "001"
         TERMINAL->(FilLock())
         TERMINAL->(DbAppend())
         TERMINAL->TERM := term
         TERMINAL->DATE := date
         TERMINAL->TIME := time
         TERMINAL->DAILY_C := COUNT
         TERMINAL->DAILY_A := AMOUNT
         TERMINAL->OP_FLAG := 1
         lfirst := .t.
      Case SIGN == "002"
         TERMINAL->CASH_A := AMOUNT2
      Case SIGN == "003"
         TERMINAL->GROSS_A := AMOUNT2
      Case SIGN == "004"
         TERMINAL->DEPT_A := AMOUNT2
      Case SIGN == "005"
         TERMINAL->FORCUR_C := COUNT
         TERMINAL->FORCUR_A := AMOUNT            
      Case SIGN == "006"
         TERMINAL->MISC1_C := COUNT
         TERMINAL->MISC1_A := AMOUNT
      Case SIGN == "007"
         TERMINAL->MISC2_C := COUNT
         TERMINAL->MISC2_A := AMOUNT
      Case SIGN == "008"
         TERMINAL->MISC3_C := COUNT
         TERMINAL->MISC3_A := AMOUNT
      Case SIGN == "009"
         TERMINAL->MISC4_C := COUNT
         TERMINAL->MISC4_A := AMOUNT
      Case SIGN == "010"
         TERMINAL->MISC5_C := COUNT
         TERMINAL->MISC5_A := AMOUNT
      Case SIGN == "011"
         TERMINAL->MISC6_C := COUNT
         TERMINAL->MISC6_A := AMOUNT            
      Case SIGN == "012"
         TERMINAL->MISC7_C := COUNT
         TERMINAL->MISC7_A := AMOUNT      
      Case SIGN == "013"
         TERMINAL->MISC8_C := COUNT
         TERMINAL->MISC8_A := AMOUNT   
      Case SIGN == "014"
         TERMINAL->MISC9_C := COUNT
         TERMINAL->MISC9_A := AMOUNT   
      Case SIGN == "015"
         TERMINAL->MISC10_C := COUNT
         TERMINAL->MISC10_A := AMOUNT   
      Case SIGN == "016"
         TERMINAL->MISC11_C := COUNT
         TERMINAL->MISC11_A := AMOUNT      
      Case SIGN == "017"
         TERMINAL->MISC12_C := COUNT
         TERMINAL->MISC12_A := AMOUNT   
      Case SIGN == "018"
         TERMINAL->MISC13_C := COUNT
         TERMINAL->MISC13_A := AMOUNT
      Case SIGN == "019"
         TERMINAL->MISC14_C := COUNT
         TERMINAL->MISC14_A := AMOUNT
      Case SIGN == "020"
         TERMINAL->MISC15_C := COUNT
         TERMINAL->MISC15_A := AMOUNT
      Case SIGN == "021"
         TERMINAL->MISC16_C := COUNT
         TERMINAL->MISC16_A := AMOUNT           
      Case SIGN == "022"
         TERMINAL->MISC17_C := COUNT
         TERMINAL->MISC17_A := AMOUNT
      Case SIGN == "023"
         TERMINAL->MISC18_C := COUNT
         TERMINAL->MISC18_A := AMOUNT
      Case SIGN == "024"
         TERMINAL->MISC19_C := COUNT
         TERMINAL->MISC19_A := AMOUNT
      Case SIGN == "025"
         TERMINAL->MISC20_C := COUNT
         TERMINAL->MISC20_A := AMOUNT
      Case SIGN == "026"
         TERMINAL->MISC21_C := COUNT
         TERMINAL->MISC21_A := AMOUNT
      Case SIGN == "027"
         TERMINAL->MISC22_C := COUNT
         TERMINAL->MISC22_A := AMOUNT
      Case SIGN == "028"
         TERMINAL->MISC23_C := COUNT
         TERMINAL->MISC23_A := AMOUNT
      Case SIGN == "029"
         TERMINAL->MISC24_C := COUNT
         TERMINAL->MISC24_A := AMOUNT
      Case SIGN == "030"
         TERMINAL->MISC25_C := COUNT
         TERMINAL->MISC25_A := AMOUNT
      Case SIGN == "031"
         TERMINAL->MISC26_C := COUNT
         TERMINAL->MISC26_A := AMOUNT            
      Case SIGN == "032"
         TERMINAL->MISC27_C := COUNT
         TERMINAL->MISC27_A := AMOUNT      
      Case SIGN == "033"
         TERMINAL->MISC28_C := COUNT
         TERMINAL->MISC28_A := AMOUNT   
      Case SIGN == "034"
         TERMINAL->MISC29_C := COUNT
         TERMINAL->MISC29_A := AMOUNT   
      Case SIGN == "035"
         TERMINAL->MISC30_C := COUNT
         TERMINAL->MISC30_A := AMOUNT   
      Case SIGN == "036"
         TERMINAL->MISC31_C := COUNT
         TERMINAL->MISC31_A := AMOUNT      
      Case SIGN == "037"
         TERMINAL->MISC32_C := COUNT
         TERMINAL->MISC32_A := AMOUNT   
      Case SIGN == "038"
         TERMINAL->MISC33_C := COUNT
         TERMINAL->MISC33_A := AMOUNT
      Case SIGN == "039"
         TERMINAL->MISC34_C := COUNT
         TERMINAL->MISC34_A := AMOUNT
      Case SIGN == "040"
         TERMINAL->MISC35_C := COUNT
         TERMINAL->MISC35_A := AMOUNT
      Case SIGN == "041"
         TERMINAL->MISC36_C := COUNT
         TERMINAL->MISC36_A := AMOUNT           
      Case SIGN == "042"
         TERMINAL->MISC37_C := COUNT
         TERMINAL->MISC37_A := AMOUNT
      Case SIGN == "043"
         TERMINAL->MISC38_C := COUNT
         TERMINAL->MISC38_A := AMOUNT
      Case SIGN == "044"
         TERMINAL->MISC39_C := COUNT
         TERMINAL->MISC39_A := AMOUNT
      Case SIGN == "045"
         TERMINAL->MISC40_C := COUNT
         TERMINAL->MISC40_A := AMOUNT
      Case SIGN == "046"
         TERMINAL->MISC41_C := COUNT
         TERMINAL->MISC41_A := AMOUNT
      Case SIGN == "047"
         TERMINAL->MISC42_C := COUNT
         TERMINAL->MISC42_A := AMOUNT
      Case SIGN == "048"
         TERMINAL->MISC43_C := COUNT
         TERMINAL->MISC43_A := AMOUNT
      Case SIGN == "049"
         TERMINAL->MISC44_C := COUNT
         TERMINAL->MISC44_A := AMOUNT
      Case SIGN == "050"
         TERMINAL->MISC45_C := COUNT
         TERMINAL->MISC45_A := AMOUNT
      Case SIGN == "051"
         TERMINAL->MISC46_C := COUNT
         TERMINAL->MISC46_A := AMOUNT            
      Case SIGN == "052"
         TERMINAL->MISC47_C := COUNT
         TERMINAL->MISC47_A := AMOUNT      
      Case SIGN == "053"
         TERMINAL->MISC48_C := COUNT
         TERMINAL->MISC48_A := AMOUNT   
      Case SIGN == "054"
         TERMINAL->MISC49_C := COUNT
         TERMINAL->MISC49_A := AMOUNT   
      Case SIGN == "055"
         TERMINAL->MISC50_C := COUNT
         TERMINAL->MISC50_A := AMOUNT    
      Case SIGN == "056"
         TERMINAL->IVOID_C := COUNT
         TERMINAL->IVOID_A := AMOUNT
      Case SIGN == "057"
         TERMINAL->MVOID_C := COUNT
         TERMINAL->MVOID_A := AMOUNT
      Case SIGN == "058"
         TERMINAL->IDISC_C := COUNT
         TERMINAL->IDISC_A := AMOUNT
      Case SIGN == "059"
         TERMINAL->SUBTD_C := COUNT
         TERMINAL->SUBTD_A := AMOUNT
      Case SIGN == "060"
         TERMINAL->ADDON_C := COUNT
         TERMINAL->ADDON_A := AMOUNT
      Case SIGN == "061"
         TERMINAL->SSBTD_C := COUNT
         TERMINAL->SSBTD_A := AMOUNT
      Case SIGN == "062"
         TERMINAL->SSBTA_C := COUNT
         TERMINAL->SSBTA_A := AMOUNT
      Case SIGN == "063"
         TERMINAL->RETRN_C := COUNT
         TERMINAL->RETRN_A := AMOUNT
      Case SIGN == "064"
         TERMINAL->REFND_C := COUNT
         TERMINAL->REFND_A := AMOUNT
      Case SIGN == "065"
         TERMINAL->OTINC_C := COUNT
         TERMINAL->OTINC_A := AMOUNT
      Case SIGN == "066"
         TERMINAL->CANCL_C := COUNT
         TERMINAL->CANCL_A := AMOUNT
      Case SIGN == "067"
         TERMINAL->TVOID_C := COUNT
         TERMINAL->TVOID_A := AMOUNT
      Case SIGN == "068"
         TERMINAL->SUSPD_C := COUNT
         TERMINAL->SUSPD_A := AMOUNT
      Case SIGN == "069"
         TERMINAL->LAYAW_C := COUNT
         TERMINAL->LAYAW_A := AMOUNT
      Case SIGN == "070"
         TERMINAL->PIKUP_C := COUNT
         TERMINAL->PIKUP_A := AMOUNT
      Case SIGN == "071"
         TERMINAL->PDOUT_C := COUNT
         TERMINAL->PDOUT_A := AMOUNT
      Case SIGN == "072"
         TERMINAL->LOAN_C := COUNT
         TERMINAL->LOAN_A := AMOUNT
      Case SIGN == "073"
         TERMINAL->RECACT_C := COUNT
         TERMINAL->RECACT_A := AMOUNT
      Case SIGN == "074"
         TERMINAL->BOTDEP_C := COUNT
         TERMINAL->BOTDEP_A := AMOUNT
      Case SIGN == "075"
         TERMINAL->TRAIN_A := AMOUNT2
      Case SIGN == "076"
         TERMINAL->OFFLN_A := AMOUNT2
      Case SIGN == "077"
         TERMINAL->RENTER_A := AMOUNT2
      Case SIGN == "078"
         TERMINAL->OLDGRD_A := AMOUNT2
      Case SIGN == "079"
         TERMINAL->NEWGRD_A := AMOUNT2
      Case SIGN == "080"
         TERMINAL->XCOUNT_C := COUNT3
      Case SIGN == "081"
         TERMINAL->ZCOUNT_C := COUNT3
                                                                                       
    EndCase 
   
   enddo
   fclose(nFhandle) 

   if file(cPath+TERMINAL_FILE)
     cFile := alltrim(SUBSTR(CMONTH(sdate),1,3))+alltrim(SUBSTR(DTOC(sdate),4,2))+".TRM"
     frename((cPath)+TERMINAL_FILE,(cPath)+cFile)
     
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

























  