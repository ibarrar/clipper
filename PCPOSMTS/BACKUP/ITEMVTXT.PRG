#include "itm_move.ch"
#include "directry.ch"
#include "janus.ch"
#include "fileio.ch"
#include "inkey.ch"
#include "setcurs.ch"

#define DATA_PATH  chr(65+curdrv())+":\"+curdir()+"\MTSDATA\"   
#define ROOT_PATH  chr(65+curdrv())+":\"+curdir()+"\"   
#define BCKUP_PATH chr(65+curdrv())+":\"+curdir()+"\BACKUP\"   

memvar getlist
function ItemV_imp()
local cpath := space(35), i := 0, cFileName, aTxtDir := {}, nFHandle, cStr:=space(116), nFH, nfh2
local aflag:={ "N", "R", "T", "D", "V" },wChange
local cDate:=dtos(date())
// get path
if file((ROOT_PATH)+"itemv.id")
  nFh:=fopen((ROOT_PATH)+"itemv.id")
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
   if file("itemv.id")
     ferase("itemv.id")
   endif  
   nFh := fcreate("itemv.id",FC_NORMAL)
   fwrite(nFh,cpath)
   fclose(nFh)          
 else
   BUMMER()
   return nil
 endif

//aTxtDir := directory(cPath+"ITMV*.JP")
aTxtDir := directory(cPath+"ITEM*.TXT")

if len(aTxtDir) == 0
  alert("No ITEM MOVEMENT transaction file", {"Return"})
  return nil 
endif

for  i:= 1 to len(aTxtDir)
   if file(cPath+ aTxtDir[i][F_NAME])
//     COPY FILE (cPath)+(aTxtDir[i][F_NAME]) TO (BCKUP_PATH)+( subs(aTxtDir[i][F_NAME],1,4)+subs(cDate,5,4)+".J"+alltrim(str(i)) )
     COPY FILE (cPath)+(aTxtDir[i][F_NAME]) TO (BCKUP_PATH)+(subs(aTxtDir[i][F_NAME],1,4)+subs(cDate,5,4)+".J"+ alltrim(str(val(subs(aTxtDir[i][F_NAME],5,4)))) )
     RENAME (cPath)+aTxtDir[i][F_NAME] to (cPath)+substr(aTxtDir[i][F_NAME],1,8)
     COPY file (cPath)+substr(aTxtDir[i][F_NAME],1,8)  to (DATA_PATH)+ (aTxtDir[i][F_NAME]) 
     FERASE((cPath)+substr(aTxtDir[i][F_NAME],1,8))
   else
     alert("No ITEM MOVEMENT transaction file", {"Return"})
     Return nil
   endif  
next i


if netuse("ITM_MOVE", DB_SHARED, NUM_SECONDS)
    set index to ITM_MOVE
else
   alert("File 'ITM_MOVE.DBF' cannot be accessed",{"Quit"})
   return nil
endif


for i := 1 to len(aTxtDir)

  cFileName := aTxtDir[i][F_NAME]
  nFHandle := fopen((DATA_PATH)+ cFileName,FO_READ)

  if nFHandle == -1
    Alert("Error opening file : '"+cFileName+"'", {"Return"})
    return -1 
  endif
  Message('Updating files "ITM_MOVE.DBF " please wait...')

  while !feof(nFhandle)
    cStr := freadstr(nFHandle,119)    //119= 117 CHARS. PER LINE + 2 FOR  CRLF
if aScan(aFlag, TRANSFLAG) != 0 
    ITM_MOVE->(dbAppend())
    ITM_MOVE->(RecLock())

    ITM_MOVE->POS_NO     := POSNO
    ITM_MOVE->DATE       := CTOD(DATES)
    ITM_MOVE->TIME       := TIMES
    ITM_MOVE->TRANS_NO   := TRANSNO
    ITM_MOVE->CASHCODE   := CASH_CDE
    ITM_MOVE->PLU_CODE   := PLUCODE
    ITM_MOVE->DEPT_CODE  := DEPTCODE
    ITM_MOVE->EXCH_RATE  := EXCHRATE     

    ITM_MOVE->UPRICE     := cncon(UNIT_PRC)  * 0.01        //SRP
    
IF TRANSFLAG == "N"      //NORMAL
    ITM_MOVE->QTY        := cncon(QTTY)                    //Sales Qty.
    ITM_MOVE->AMOUNT     := cncon(SLSAMOUNT) * 0.01        //Total Amount Sold
    ITM_MOVE->ITM_COST   := cncon(ITEMCOST)  * 0.01        //Item Cost
ENDIF

if TRANSFLAG == "R"                   //RETURN
    ITM_MOVE->RTN_QTY    := TRQTY
    ITM_MOVE->RTN_AMOUNT := cncon(TRAMT)* 0.001
endif

if TRANSFLAG == "T"                    //TRAN. VOID
    ITM_MOVE->VOID_QTY   := TRQTY
    ITM_MOVE->VOID_AMT   := cncon(TRAMT)* 0.001
endif

if TRANSFLAG == "V"                    //VOID
    ITM_MOVE->QTY        := cncon(QTTY)            //Sales Qty.
    ITM_MOVE->AMOUNT     := cncon(SLSAMOUNT)* 0.01       //Total Amount Sold
endif

if TRANSFLAG == "D"                    //DISCOUNT
    ITM_MOVE->DISC_AMT   := cncon(TRAMT)* 0.001
    ITM_MOVE->DISC_RATE  := DISCRATE
endif

if TRANSFLAG == "S"                    //SUBTOTAL DISCOUNT
    ITM_MOVE->SDISC_AMT  := cncon(TRAMT)* 0.001
endif    

//    ITM_MOVE->NET_ITMAMT := NT_ITMAMT
//    ITM_MOVE->NET_ITMQTY := NT_ITMQTY

    ITM_MOVE->FLAG := TRANSFLAG
    ITM_MOVE->(dbUnLock())

endif    
  enddo
    
  Fclose(nFHandle)
  HEYTHERE() 
  INKEY(1)    
next i


ITM_MOVE->(dbCommit())    
ITM_MOVE->(DbCloseArea())

HEYTHERE() ; OKDONE()
INKEY(1)      
return nil  


function cNcon(n)
return val(if("-" $ n,"-"+substr(n,at("-",n)+1),n))
