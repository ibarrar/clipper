#include "rpt.ch"
#include "janus.ch"
#include "fileio.ch"

#define F_BLOCK  1024
#define CR     chr(13)
#define LF     chr(10)
#define CRLF   CR + LF
#define DATA_PATH  chr(65+curdrv())+":\"+curdir()+"\BACKUP\"   

function CASH_IMP(sdate)

local term, pos := 0, date, time := 0
local cFileName, cfile, cpath, cStr
local nFHandle, lfirst := .f.
local end := 0, start := 0, n := 0, aCash := {}
local count := 0, amount := 0, i := 0, cash_file
local strdate := dtoc(sdate)
local nread := 0, cbuff,nFtarget, nFSource, nmove

cash_file := "CASH" + substr(strdate,1,2) + substr(strdate,4,2) + "." + substr(strdate,7,2) + "0"



 if NetUse("UM",DB_SHARED,NUM_SECONDS)
    Set Index to UM
 endif

 if NetUse("CASH",DB_SHARED,NUM_SECONDS)
    Set Index to CAS
 endif

 Do While UM->(!Eof()) 
 
   if UM->(Deleted())
     UM->(DbSkip())
     loop
   endif
 
   cFilename :=  alltrim(UM->UMAC_PATH)+CASH_FILE
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
    cStr := space(1277)
    freadln(nFHandle,@cStr,1277)
    aCash := {}

   
    Do Case
      Case SIGN == "CAS" 
         pos := at("<",cStr)
         term := substr(cStr,pos+1,4)
      Case substr(SIGN,3,1) == "/"   
         date := ctod(SUBSTR(cStr,1,8))
         time := val(SUBSTR(cStr,19,5))
         if lfirst
            CASH->(DbUnLock())
            lfirst := .f.
         endif
      otherwise

         start := 76
         end   :=  4
         n := 70

         Do While n <> 0
            count := substr(cStr,start,end)
            amount := substr(cStr,start+end,12)
            aadd(aCash,{val(count) ,val(amount) * .01})
            start := start+end+12
            n := n - 1
         enddo 
         
         CASH->(FilLock())
         CASH->(DbAppend())
         CASH->TERM    := term
         CASH->DATE    := date
         CASH->TIME    := time
         CASH->CODE    := substr(cStr,1,3)
         CASH->NAME    := substr(cStr,4,20)
         CASH->DAILY_C := val(substr(cStr,24,4)) 
         CASH->DAILY_A := val(substr(cStr,28,12)) * .01
         CASH->CASH_A  := val(substr(cStr,40,12)) * .01
         CASH->GROSS_A := val(substr(cStr,52,12)) * .01
         CASH->DEPT_A  := val(substr(cStr,64,12)) * .01
         CASH->OP_FLAG := 1


         for i := 1 to 70
         
          do case
             case i == 1
              CASH->FORCUR_C := aCash[i][1] 
              CASH->FORCUR_A := aCash[i][2] 
             case i == 2
              CASH->MISC01_C := aCash[i][1] 
              CASH->MISC01_A := aCash[i][2]  
             case i == 3
              CASH->MISC02_C := aCash[i][1] 
              CASH->MISC02_A := aCash[i][2] 
             case i == 4
              CASH->MISC03_C := aCash[i][1] 
              CASH->MISC03_A := aCash[i][2] 
             case i == 5
              CASH->MISC04_C := aCash[i][1] 
              CASH->MISC04_A := aCash[i][2] 
             case i == 6
              CASH->MISC05_C := aCash[i][1] 
              CASH->MISC05_A := aCash[i][2]    
             case i == 7
              CASH->MISC06_C := aCash[i][1] 
              CASH->MISC06_A := aCash[i][2] 
             case i == 8
              CASH->MISC07_C := aCash[i][1] 
              CASH->MISC07_A := aCash[i][2]     
             case i == 9
              CASH->MISC08_C := aCash[i][1] 
              CASH->MISC08_A := aCash[i][2]  
             case i == 10
              CASH->MISC09_C := aCash[i][1] 
              CASH->MISC09_A := aCash[i][2] 
             case i == 11
              CASH->MISC10_C := aCash[i][1] 
              CASH->MISC10_A := aCash[i][2] 
             case i == 12
              CASH->MISC11_C := aCash[i][1] 
              CASH->MISC11_A := aCash[i][2] 
             case i == 13
              CASH->MISC12_C := aCash[i][1] 
              CASH->MISC12_A := aCash[i][2] 
             case i == 14
              CASH->MISC13_C := aCash[i][1] 
              CASH->MISC13_A := aCash[i][2]    
             case i == 15
              CASH->MISC14_C := aCash[i][1] 
              CASH->MISC14_A := aCash[i][2] 
             case i == 16
              CASH->MISC15_C := aCash[i][1] 
              CASH->MISC15_A := aCash[i][2]     
             case i == 17
              CASH->MISC16_C := aCash[i][1] 
              CASH->MISC16_A := aCash[i][2] 
             case i == 18
              CASH->MISC17_C := aCash[i][1] 
              CASH->MISC17_A := aCash[i][2] 
             case i == 19
              CASH->MISC18_C := aCash[i][1] 
              CASH->MISC18_A := aCash[i][2] 
             case i == 20
              CASH->MISC19_C := aCash[i][1] 
              CASH->MISC19_A := aCash[i][2] 
             case i == 21
              CASH->MISC20_C := aCash[i][1] 
              CASH->MISC20_A := aCash[i][2] 
             case i == 22
              CASH->MISC21_C := aCash[i][1] 
              CASH->MISC21_A := aCash[i][2]    
             case i == 23
              CASH->MISC22_C := aCash[i][1] 
              CASH->MISC22_A := aCash[i][2] 
             case i == 24
              CASH->MISC23_C := aCash[i][1] 
              CASH->MISC23_A := aCash[i][2]     
             case i == 25
              CASH->MISC24_C := aCash[i][1] 
              CASH->MISC24_A := aCash[i][2] 
             case i == 26
              CASH->MISC25_C := aCash[i][1] 
              CASH->MISC25_A := aCash[i][2] 
             case i == 27
              CASH->MISC26_C := aCash[i][1] 
              CASH->MISC26_A := aCash[i][2] 
             case i == 28
              CASH->MISC27_C := aCash[i][1] 
              CASH->MISC27_A := aCash[i][2] 
             case i == 29
              CASH->MISC28_C := aCash[i][1] 
              CASH->MISC28_A := aCash[i][2] 
             case i == 30
              CASH->MISC29_C := aCash[i][1] 
              CASH->MISC29_A := aCash[i][2]    
             case i == 31
              CASH->MISC30_C := aCash[i][1] 
              CASH->MISC30_A := aCash[i][2] 
             case i == 32
              CASH->MISC31_C := aCash[i][1] 
              CASH->MISC31_A := aCash[i][2]     
             case i == 33
              CASH->MISC32_C := aCash[i][1] 
              CASH->MISC32_A := aCash[i][2]    
             case i == 34
              CASH->MISC33_C := aCash[i][1] 
              CASH->MISC33_A := aCash[i][2] 
             case i == 35
              CASH->MISC34_C := aCash[i][1] 
              CASH->MISC34_A := aCash[i][2] 
             case i == 36
              CASH->MISC35_C := aCash[i][1] 
              CASH->MISC35_A := aCash[i][2] 
             case i == 37
              CASH->MISC36_C := aCash[i][1] 
              CASH->MISC36_A := aCash[i][2] 
             case i == 38
              CASH->MISC37_C := aCash[i][1] 
              CASH->MISC37_A := aCash[i][2]    
             case i == 39
              CASH->MISC38_C := aCash[i][1] 
              CASH->MISC38_A := aCash[i][2] 
             case i == 40
              CASH->MISC39_C := aCash[i][1] 
              CASH->MISC39_A := aCash[i][2]     
             case i == 41
              CASH->MISC40_C := aCash[i][1] 
              CASH->MISC40_A := aCash[i][2] 
             case i == 42
              CASH->MISC41_C := aCash[i][1] 
              CASH->MISC41_A := aCash[i][2] 
             case i == 43
              CASH->MISC42_C := aCash[i][1] 
              CASH->MISC42_A := aCash[i][2] 
             case i == 44
              CASH->MISC43_C := aCash[i][1] 
              CASH->MISC43_A := aCash[i][2] 
             case i == 45
              CASH->MISC44_C := aCash[i][1] 
              CASH->MISC44_A := aCash[i][2] 
             case i == 46
              CASH->MISC45_C := aCash[i][1] 
              CASH->MISC45_A := aCash[i][2]    
             case i == 47
              CASH->MISC46_C := aCash[i][1] 
              CASH->MISC46_A := aCash[i][2] 
             case i == 48
              CASH->MISC47_C := aCash[i][1] 
              CASH->MISC47_A := aCash[i][2]     
             case i == 49
              CASH->MISC48_C := aCash[i][1] 
              CASH->MISC48_A := aCash[i][2] 
             case i == 50
              CASH->MISC49_C := aCash[i][1] 
              CASH->MISC49_A := aCash[i][2] 
             case i == 51
              CASH->MISC50_C := aCash[i][1] 
              CASH->MISC50_A := aCash[i][2] 
             case i == 52
              CASH->IVOID_C := aCash[i][1] 
              CASH->IVOID_A := aCash[i][2] 
             case i == 53
              CASH->MVOID_C := aCash[i][1] 
              CASH->MVOID_A := aCash[i][2] 
             case i == 54
              CASH->IDISC_C := aCash[i][1] 
              CASH->IDISC_A := aCash[i][2]    
             case i == 55
              CASH->SUBTD_C := aCash[i][1] 
              CASH->SUBTD_A := aCash[i][2] 
             case i == 56
              CASH->ADDON_C := aCash[i][1] 
              CASH->ADDON_A := aCash[i][2]     
             case i == 57
              CASH->SSBTD_C := aCash[i][1] 
              CASH->SSBTD_A := aCash[i][2] 
             case i == 58
              CASH->SSBTA_C := aCash[i][1] 
              CASH->SSBTA_A := aCash[i][2]  
             case i == 59
              CASH->RETRN_C := aCash[i][1] 
              CASH->RETRN_A := aCash[i][2] 
             case i == 60
              CASH->REFND_C := aCash[i][1] 
              CASH->REFND_A := aCash[i][2] 
             case i == 61
              CASH->OTINC_C := aCash[i][1] 
              CASH->OTINC_A := aCash[i][2] 
             case i == 62
              CASH->CANCL_C := aCash[i][1] 
              CASH->CANCL_A := aCash[i][2] 
             case i == 63
              CASH->TVOID_C := aCash[i][1] 
              CASH->TVOID_A := aCash[i][2]    
             case i == 64
              CASH->SUSPD_C := aCash[i][1] 
              CASH->SUSPD_A := aCash[i][2] 
             case i == 65
              CASH->LAYAW_C := aCash[i][1] 
              CASH->LAYAW_A := aCash[i][2]     
             case i == 66
              CASH->PIKUP_C := aCash[i][1] 
              CASH->PIKUP_A := aCash[i][2] 
             case i == 67
              CASH->PDOUT_C := aCash[i][1] 
              CASH->PDOUT_A := aCash[i][2] 
             case i == 68
              CASH->LOAN_C := aCash[i][1] 
              CASH->LOAN_A := aCash[i][2] 
             case i == 69
              CASH->RECACT_C := aCash[i][1] 
              CASH->RECACT_A := aCash[i][2] 
             case i == 70
              CASH->BOTDEP_C := aCash[i][1] 
              CASH->BOTDEP_A := aCash[i][2] 
          endcase
         next i

         CASH->CASHDEC := val(substr(cStr,1196,12))* .01
         CASH->TRAIN_A := val(substr(cStr,1208,12)) * .01
         CASH->OFFLN_A := val(substr(cStr,1220,12)) * .01
         CASH->RENTER_A := val(substr(cStr,1232,12)) * .01
         CASH->OLDGRD_A := val(substr(cStr,1244,12)) * .01
         CASH->NEWGRD_A := val(substr(cStr,1256,12)) * .01
         CASH->XCOUNT_C := val(substr(cStr,1268,4)) 
         CASH->ZCOUNT_C := val(substr(cStr,1272,4)) 
         
         lfirst := .t.
      EndCase 
   
   enddo
   fclose(nFhandle) 


   if file(cPath+CASH_FILE)
     cFile := alltrim(SUBSTR(CMONTH(sdate),1,3))+alltrim(SUBSTR(DTOC(sdate),4,2))+".CAS"
     frename((cPath)+CASH_FILE,(cPath)+cFile)
     
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


STATIC FUNCTION freadln(handle, buffer, max_line)

	LOCAL line, eol, num_read, save_pos

	line := space(max_line)
	buffer := ""

	* save current file position for later seek
	save_pos := fseek(handle,0,FS_RELATIVE)

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
























  