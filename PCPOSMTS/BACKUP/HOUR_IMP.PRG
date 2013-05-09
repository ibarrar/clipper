#include "rpt.ch"
#include "janus.ch"
#include "fileio.ch"

#define F_BLOCK  1024
#define DATA_PATH  chr(65+curdrv())+":\"+curdir()+"\BACKUP\"   


function HOUR_IMP(sdate)

local term, pos := 0, date, time := 0
local cFileName, cfile, cpath, cStr
local nFHandle, lfirst := .f., hour_file
local strdate := dtoc(sdate)
local nread := 0, cbuff,nFtarget, nFSource, nmove

hour_file := "HOUR" + substr(strdate,1,2) + substr(strdate,4,2) + "." + substr(strdate,7,2) + "0"



 if NetUse("UM",DB_SHARED,NUM_SECONDS)
    Set Index to UM
 endif

 if NetUse("HOUR",DB_SHARED,NUM_SECONDS)
    Set Index to HOUR
 endif

 Do While UM->(!Eof()) 

  if UM->(Deleted())
   UM->(DbSkip())
   loop
  endif   
 
   cFilename :=  alltrim(UM->UMAC_PATH)+HOUR_FILE
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
      Case SIGN == "HOU" 
         pos := at("<",cStr)
         term := substr(cStr,pos+1,4)
      Case substr(SIGN,3,1) == "/"   
         date := ctod(SUBSTR(cStr,1,8))
         time := val(SUBSTR(cStr,20,5))
         if lfirst
            HOUR->(DbUnLock())
            lfirst := .f.
         endif
      otherwise   
         HOUR->(FilLock())
         HOUR->(DbAppend())
         HOUR->TERM     := term
         HOUR->DATE     := date
         HOUR->TIME     := time
         HOUR->HOUR     := H_HOUR
         HOUR->HCOUNT   := H_COUNT
         HOUR->HAMOUNT  := H_AMOUNT
         HOUR->OP_FLAG  := 1
         lfirst := .t.
    EndCase 
   
   enddo
   fclose(nFhandle) 
   
   if file(cPath+HOUR_FILE)
     cFile := alltrim(SUBSTR(CMONTH(sdate),1,3))+alltrim(SUBSTR(DTOC(sdate),4,2))+".HR"
     frename((cPath)+HOUR_FILE,(cPath)+cFile)
     
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

























  