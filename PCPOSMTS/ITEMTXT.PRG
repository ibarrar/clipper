#include "cashterm.ch"
#include "directry.ch"
#include "janus.ch"
#include "fileio.ch"
#include "inkey.ch"
#include "setcurs.ch"

#define DATA_PATH  chr(65+curdrv())+":\"+curdir()+"\MTSDATA\"   
#define ROOT_PATH  chr(65+curdrv())+":\"+curdir()+"\"   

memvar getlist
function Item_imp()
local cpath := space(35), i := 0, cFileName, aTxtDir := {}, nFHandle, cStr, nFH, nfh2
local aflag := {"Z", "0", "1", "2", "3", "4", "5", "6", "7", "8", "9" }, wChange
local ChargeFlags := { "N", "R", "T", "D", "V" }

// get path
if file((ROOT_PATH)+"item.id")
  nFh:=fopen((ROOT_PATH)+"item.id")
  cpath := freadstr(nFh,35)
  fclose(nFh)
endif     

cpath := padr(alltrim(cpath),35) 
wChange := OpenWindow(5,15,9,72,"Server Path Editing")
setcursor(SC_NORMAL)
@  6,15 to 9,72 double
@  7,17 say "ENTER DATA PATH : " get cpath pict "@! " +REPL("X",35)
read
CloseWindow(wChange)  
setcursor(SC_NONE) 
cpath := ALLTRIM(cpath)
if substr(cpath,len(cpath),1) != "\"
  cpath += "\"
endif  
   
// save new path to file
 if lastkey() != K_ESC
   if file("item.id")
     ferase("item.id")
   endif  
   nFh := fcreate("item.id",FC_NORMAL)
   fwrite(nFh,cpath)
   fclose(nFh)          
 else
   BUMMER()
   return nil
 endif


aTxtDir := directory(cPath+"ITEM*.TXT")

if len(aTxtDir) == 0
  alert("No ITEM transaction file", {"Return"})
  return nil 
endif


for  i:= 1 to len(aTxtDir)
   if file(cPath+ aTxtDir[i][F_NAME])
     RENAME (cPath)+aTxtDir[i][F_NAME] to (cPath)+substr(aTxtDir[i][F_NAME],1,8)
     COPY file (cPath)+substr(aTxtDir[i][F_NAME],1,8)  to (DATA_PATH)+ (aTxtDir[i][F_NAME]) 
     FERASE((cPath)+substr(aTxtDir[i][F_NAME],1,8))
   else
     alert("No ITEM transaction file", {"Return"})
     Return nil
   endif  
next i   



if netuse("CHARGE", DB_SHARED, NUM_SECONDS)
    set index to CHARGE
else
   alert("File 'CHARGE.DBF' cannot be accessed",{"Quit"})
   return nil
endif


for i := 1 to len(aTxtDir)

  cFileName := aTxtDir[i][F_NAME]
  nFHandle := fopen((DATA_PATH)+ cFileName,FO_READ)

  if nFHandle == -1
    Alert("Error opening file : '"+cFileName+"'", {"Return"})
    return -1 
  endif
  Message('Updating files "CHARGE.DBF " please wait...')
  
  while !feof(nFhandle)
    cStr := freadstr(nFHandle,128)
    
 if aScan(aFlag, TRANSFLAG) != 0
  IF VAL(PAYMTYPE) <> 0

    CHARGE->(dbAppend())
    CHARGE->(RecLock())
    
    CHARGE->POS_NO     := POSNO        
    CHARGE->DATE       := CTOD(DATES)
    CHARGE->TIME       := TIMES        
    CHARGE->CASH_CODE  := CASH_CDE 
    CHARGE->SLS_AMOUNT := SLSAMT
    CHARGE->PAY_TYPE   := PAYMTYPE  
    CHARGE->ACCT_NO    := C1
    CHARGE->OP_FLAG    := 1
    CHARGE->(dbUnLock())    
    
  ENDIF  
 endif

  enddo
    
  Fclose(nFHandle)
  HEYTHERE() 
  INKEY(1)    
next i

CHARGE->(dbCommit())    
CHARGE->(DbCloseArea())
HEYTHERE() ; OKDONE()
INKEY(1)      
return nil  


