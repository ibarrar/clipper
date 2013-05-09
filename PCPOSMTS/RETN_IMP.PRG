#include "rpt.ch"
#include "janus.ch"
#include "fileio.ch"

#define F_BLOCK  1024
#define DATA_PATH  chr(65+curdrv())+":\"+curdir()+"\BACKUP\"   

#define CR     chr(13)
#define LF     chr(10)
#define CRLF   CR + LF


function RET_IMP(sdate)

local term, pos := 0, date, time := 0
local cFileName, cfile, cpath, cStr
local nFHandle, lfirst := .f., ret_file
local strdate := dtoc(sdate)
local nread := 0, cbuff,nFtarget, nFSource, nmove


ret_file := "RETU" + substr(strdate,1,2) + substr(strdate,4,2) + "." + substr(strdate,7,2) + "0"



 if NetUse("UM",DB_SHARED,NUM_SECONDS)
    Set Index to UM
 endif

 if NetUse("RET",DB_SHARED,NUM_SECONDS)
    Set Index to RET,RETD
 endif

 Do While UM->(!Eof()) 
   
  if UM->(Deleted())
   UM->(DbSkip())
   loop
  endif
 
   cFilename :=  alltrim(UM->UMAC_PATH)+RET_FILE
   cPath := alltrim(UM->UMAC_PATH)

   Message(" Opening file :  "+ cFilename)

   nFHandle := fopen(cFilename,FO_READ)


   if nFHandle == -1
     Message(" Opening file :  "+ cFilename+ "      No Data Found !!!")
     tone(100,1.5)
     UM->(DbSkip())
     loop
   endif

   set order to 1
   while !feof(nFhandle)

    cStr := space(86)
    freadln(nFHandle,@cStr,86)
   
   
    Do Case
      Case SIGN == "RET" .or.  SIGN == "NOT" 
         pos := at("<",cStr)
         term := substr(cStr,pos+1,4)
      Case substr(SIGN,3,1) == "/"   
         date := ctod(SUBSTR(cStr,1,8))
         time := val(SUBSTR(cStr,56,5))
         if lfirst
            RET->(DbUnLock())
            lfirst := .f.
         endif
      otherwise   
         RET->(FilLock())
         if !RET->(DbSeek(R_PLU+dtos(date)))
            RET->(DbAppend())
            RET->DATE     := date
            RET->PLUCODE  := R_PLU
            RET->ITEMCODE  := R_ICODE
            RET->RDESC    := R_DESC
            RET->RDEPT    := R_DEPT
            RET->RCOUNT   := R_COUNT
            RET->RAMOUNT  := R_AMOUNT
            RET->RUCOST   := R_UCOST
            RET->OP_FLAG  := 1
         ELSE
           if R_PLU == "00000000000000" 
            set order to 2
            IF !RET->(DbSeek(R_PLU+R_DEPT))
              RET->(DbAppend())
              RET->DATE     := date
              RET->PLUCODE  := R_PLU
              RET->RDESC    := R_DESC
              RET->RDEPT    := R_DEPT
              RET->RCOUNT   := R_COUNT
              RET->RAMOUNT  := R_AMOUNT
              RET->RUCOST   := R_UCOST
            ENDIF
           endif 
           
           set order to 1
            RET->RCOUNT   += R_COUNT
            RET->RAMOUNT  += R_AMOUNT
            RET->RUCOST   := R_UCOST
         ENDIF   
         lfirst := .t.
    EndCase 
   
   enddo
   fclose(nFhandle) 

   if file(cPath+RET_FILE)
     cFile := alltrim(SUBSTR(CMONTH(sdate),1,3))+alltrim(SUBSTR(DTOC(sdate),4,2))+".RET"
     frename((cPath)+RET_FILE,(cPath)+cFile)
     
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






















  