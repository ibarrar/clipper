#include "rpt.ch"
#include "janus.ch"
#include "fileio.ch"
#include "inkey.ch"
#include "setcurs.ch"

#define F_BLOCK  1024
#define DATA_PATH  chr(65+curdrv())+":\"+curdir()+"\BACKUP\"   

#define DEFAULT_PATH   "DATA"

memvar dEndDate,dStartDate

function CCD_IMP(sdate)

local term, pos := 0, date:= sdate, time := 0
local cFileName, cfile, cpath, cStr
local nFHandle, lfirst := .f., ccd_file, cashcode := space(6)
local strdate := dtoc(sdate)
local nread := 0, cbuff,nFtarget, nFSource, nmove

ccd_file := "CCDR" + substr(strdate,1,2) + substr(strdate,4,2) + "." + substr(strdate,7,2) + "0"



 if NetUse("UM",DB_SHARED,NUM_SECONDS)
    Set Index to UM
 endif

 if NetUse("CCD",DB_SHARED,NUM_SECONDS)
    Set Index to CCD
 endif

 Do While UM->(!Eof()) 

 if UM->(Deleted())
   UM->(DbSkip())
   loop
  endif
   
 
   cFilename :=  alltrim(UM->UMAC_PATH)+ccd_file
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
      Case SIGN == "CAS"
         pos := at("<",cStr)
         term := substr(cStr,pos+1,4)
      Case substr(SIGN,3,1) == "/"   
         date := ctod(SUBSTR(cStr,1,8))
         time := val(SUBSTR(cStr,41,5))
      Case substr(SIGN,1,1) == "["     
         cashcode := substr(cStr,2,6)
         if lfirst
            CCD->(DbUnLock())
            lfirst := .f.
         endif
      otherwise   
         CCD->(FilLock())
         if !CCD->(DbSeek(dtos(date)+cashcode+BNK_CODE+ str(BNK_DENOM)))
            CCD->(DbAppend())
            CCD->DATE        := date
            CCD->TERM        := term
            CCD->CASH_CODE   := cashcode
            CCD->BANK_CODE   := BNK_CODE
            CCD->DENOM       := BNK_DENOM
            CCD->CCD_COUNT   := BNK_COUNT
            CCD->CCD_AMOUNT  := BNK_AMOUNT
            CCD->OP_FLAG     := 1
         else 
            CCD->CCD_COUNT   += BNK_COUNT
            CCD->CCD_AMOUNT  += BNK_AMOUNT
         endif
         lfirst := .t.
    EndCase 
   
   enddo
   fclose(nFhandle) 

  if file(cPath+CCD_FILE)
     cFile := alltrim(SUBSTR(CMONTH(sdate),1,3))+alltrim(SUBSTR(DTOC(sdate),4,2))+".CCD"
     frename((cPath)+CCD_FILE,(cPath)+cFile)
     
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














  