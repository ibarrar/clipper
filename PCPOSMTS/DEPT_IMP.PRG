#include "rpt.ch"
#include "janus.ch"
#include "fileio.ch"

#define F_BLOCK  1024
#define DATA_PATH  chr(65+curdrv())+":\"+curdir()+"\BACKUP\"   


function DEPT_IMP(sdate)

local term, pos := 0, date, time := 0
local cFileName, cfile, cpath, cStr
local nFHandle, lfirst := .f., dept_file
local strdate := dtoc(sdate)
local nread := 0, cbuff,nFtarget, nFSource, nmove

dept_file := "DEPT" + substr(strdate,1,2) + substr(strdate,4,2) + "." + substr(strdate,7,2) + "0"


 if NetUse("UM",DB_SHARED,NUM_SECONDS)
    Set Index to UM
 endif

 if NetUse("DEPT",DB_SHARED,NUM_SECONDS)
    Set Index to DEPT
 endif

 Do While UM->(!Eof()) 

  if UM->(Deleted())
   UM->(DbSkip())
   loop
  endif
   
 
   cFilename :=  alltrim(UM->UMAC_PATH)+DEPT_FILE
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
      Case SIGN == "DEP" 
         pos := at("<",cStr)
         term := substr(cStr,pos+1,4)
      Case substr(SIGN,3,1) == "/"   
         date := ctod(SUBSTR(cStr,1,8))
         time := val(SUBSTR(cStr,42,5))
         if lfirst
            DEPT->(DbUnLock())
            lfirst := .f.
         endif
      otherwise   
         DEPT->(FilLock())
      if !DEPT->(DbSeek(D_CODE+dtos(date))) 
         DEPT->(DbAppend())
         DEPT->DATE     := date
         DEPT->DCODE    := D_CODE
         DEPT->DDESC    := D_DESC
         DEPT->DCOUNT   := val(substr(cStr,25,10)) * .001 // D_COUNT
         DEPT->DAMOUNT  := D_AMOUNT
         DEPT->OP_FLAG  := 1
      else
         DEPT->DCOUNT   += val(substr(cStr,25,10)) * .001 // D_COUNT
         DEPT->DAMOUNT  += D_AMOUNT
      endif   
         lfirst := .t.
    EndCase 
   
   enddo
   fclose(nFhandle) 

   if file(cPath+DEPT_FILE)
     cFile := alltrim(SUBSTR(CMONTH(sdate),1,3))+alltrim(SUBSTR(DTOC(sdate),4,2))+".DPT"
     frename((cPath)+DEPT_FILE,(cPath)+cFile)
     
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

























  