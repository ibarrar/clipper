#include "Janus.ch"
#include "inkey.ch"
#include "setcurs.ch"
#include "memoedit.ch"
#include "fileio.ch"
#include "directry.ch"
#include "its.ch"

#ifdef MARGIN
 #undef MARGIN
#endif

#define MARGIN      Space(5) 
#define REPORTFILE  "ITM_MOVT.PRN"
#define MAX_SIZE    65535
#define MAX_LINE    50    
#define EJECT_FROM_FILE
#define DEBUG
#define THIS_WIDTH (85 + PLU_CODE_LEN + PLU_DESC_LEN +PLU_CODE_LEN ) + LEFT_MARGIN 
 
memvar n,dStartDate,dEndDate,nLimit, GetList, cReport
static cItemCode

/*=========================================*/
function Br_MoveI()
/*=========================================*/
local cRef,wWindBuff
local nMaxrow := maxrow()+1, nMaxCol := maxcol()+1
local aFsize := {}
// Gauge variables
local nRecCtr := 0, hGauge, nPercent, nGaugeCtr:=1, wUpdate, dDate
local cName, dFile, code
local lNewPage := 0, nLineCtr := 0, nLinelen  := 65+5+5, nPageCtr := 1
local nPagetot := 0, nPageqty := 0, cWindow
local nReccount := 0, nCtr := 1, ccolor, coldpath,prevdrate:=0
local nRuntot := 0, nRunqty := 0, prevsup := space(3)
local sup := space(3), cPname := space(20), nqtydisp := 0
local nRunUCost := 0, nPageUCost := 0,prevexch:=0,prevsrp:=0,prevdisctot:=0
local prevplu:=space(14), prevpludesc:=space(25),prevdate:=space(8)
local nPLUqty:=0, nPLUtot:=0,nPLUindx:=1,aPLU:={},nPLUqtyacc:=0,nPLUtotacc:=0
local cItemDesc:=space(30),prevqty:=0,prevtot:=0,prevtransno:=space(8)
local prevretqty:=0,prevrettot:=0,prevvoidqty:=0,prevvoidtot:=0
if !Getvalid()
  BUMMER() ; return nil 
endif 


if !GetItem()
  BUMMER() ; return nil 
endif 

if netuse("ITM_MOVE", DB_SHARED, NUM_SECONDS)
    set index to ITMV_PLU
else
   alert("File 'ITM_MOVE.DBF' cannot be accessed",{"Quit"})
   return nil    
endif	 

if netuse("ITEM.DBF", DB_SHARED, NUM_SECONDS)
    set index to I_001
else
   alert("File 'ITEM.DBF' cannot be accessed",{"Quit"})
   return nil    
endif	 

cOldPath := SET(_SET_PATH)


Message("Preparing Item Movement Report ...")

SET ALTERNATE TO ".\"+REPORTFILE
SET ALTERNATE ON
SET CONSOLE OFF
SET PRINTER OFF

window( 19, 1, 22, 60, CONFIRM_COLOR )



lNewPage := .t.
ITEM->(DBSEEK(cItemCode))
cItemDesc:=subs(ITEM->I_037,1,30) 

ITM_MOVE->(DBSEEK(cItemCode))
DO WHILE ITM_MOVE->(!EOF()) .and. ITM_MOVE->PLU_CODE == cItemCode
if DatesOk(ITM_MOVE->DATE)

  // Create header if new page  
  if lNewPage  
   // Create header if new page  
   ? MARGIN + "ITEM MOVEMENT REPORT"
   ?
   ? MARGIN +chr(254)+ SYS_NAME
   ? MARGIN +"Item Movement Report"
   ? MARGIN +"From "+dtoc(dStartDate)+" to "+dtoc(dEndDate)
   ? MARGIN +"As of "+dtoc(date())+", "+time()
   ? MARGIN + cItemDesc
   ? MARGIN +"Item Code: " + cItemCode
   ?
  	? MARGIN + "DATE        QUANTITY      NET AMOUNT     EXCH. RATE   SSRP         DISC. %    NSRP      "
   ? MARGIN + "--------   ----------   --------------   ----------   ----------   --------   ----------"
   //          12345678   1234567890   12345678901234   1234567890   1234567890   12345678   1234567890
   ?
   ?
   lNewpage := .f.
   nLineCtr := 13
  endif


     if prevdate!=dtoc(ITM_MOVE->DATE) .and. !empty(prevdate)
   ? MARGIN  + prevdate
   ??space(3)+ trans(nPLUqty,"999,999.99")
   ??space(3)+ trans(nPLUtot,"999,999,999.99")
   ??space(3)+ trans(prevexch,"999,999.99")
   ??space(3)+ trans(prevsrp,"999,999.99")
   ??space(3)+ trans(prevdrate*100,"  999.99")
   ??space(3)+ trans(prevsrp-(prevsrp*prevdrate),"999,999.99")
nPageqty+=nPLUqty
nRunqty+=nPLUqty
nPagetot+=nPLUtot
nRuntot+=nPLUtot

        nPLUqty:=0 //ITM_MOVE->QTY
        nPLUtot:=0 //ITM_MOVE->AMOUNT

        prevplu := ITM_MOVE->PLU_CODE
        prevdate:= dtoc(ITM_MOVE->DATE)
        prevexch:= ITM_MOVE->EXCH_RATE
        prevsrp := itm_move->uprice              // -(prevsrp*ITM_MOVE->DISC_RATE/100)
        prevdrate:= itm_move->disc_rate/100      // ITM_MOVE->DISC_RATE /100
        prevqty:= ITM_MOVE->QTY
        prevtot:= ITM_MOVE->AMOUNT        
        prevvoidqty:=0
        prevvoidtot:=0
        prevretqty:=0
        prevrettot:=0
        nLineCtr+=1        
     endif  

     if empty(prevplu)  
        prevplu:=ITM_MOVE->PLU_CODE
        prevexch:= ITM_MOVE->EXCH_RATE          
        prevdate:=dtoc(ITM_MOVE->DATE)
        prevsrp:= ITM_MOVE->UPRICE
        prevdrate:=ITM_MOVE->DISC_RATE/100
        prevtransno:=ITM_MOVE->TRANS_NO
        prevdisctot:=itm_move->disc_amt
        prevvoidqty:=itm_move->void_qty
        prevvoidtot:=itm_move->void_amt
        prevretqty:=itm_move->rtn_qty
        prevrettot:=itm_move->rtn_amount
     endif

if prevsrp==ITM_MOVE->UPRICE .and. prevexch == ITM_MOVE->EXCH_RATE
   nPLUqty+=ITM_MOVE->QTY - itm_move->rtn_qty - Itm_move->void_qty
   nPLUtot+=ITM_MOVE->AMOUNT - itm_move->rtn_amount - itm_move->void_amt - itm_move->disc_amt
        prevsrp:= ITM_MOVE->UPRICE
        prevexch:= ITM_MOVE->EXCH_RATE  
        prevdrate:=ITM_MOVE->DISC_RATE/100
        prevtransno:=ITM_MOVE->TRANS_NO
        prevqty:=ITM_MOVE->QTY
        prevtot:=ITM_MOVE->AMOUNT
        prevdisctot:=itm_move->disc_amt 
        prevvoidqty+=itm_move->void_qty
        prevvoidtot+=itm_move->void_amt
        prevretqty+=itm_move->rtn_qty
        prevrettot+=itm_move->rtn_amount
endif

//if nPLUqty>0
if (prevsrp!=ITM_MOVE->UPRICE .or. prevexch!= ITM_MOVE->EXCH_RATE)
   ? MARGIN  + prevdate
   ??space(3)+ trans(nPLUqty,"999,999.99")
   ??space(3)+ trans(nPLUtot,"999,999,999.99")
   ??space(3)+ trans(prevexch,"999,999.99")
   ??space(3)+ trans(prevsrp,"999,999.99")
   ??space(3)+ trans(prevdrate*100,"  999.99")
   ??space(3)+ trans(prevsrp-(prevsrp*prevdrate),"999,999.99")
nPageqty+=nPLUqty
nRunqty+=nPLUqty
nPagetot+=nPLUtot
nRuntot+=nPLUtot
   nPLUqty:=itm_move->qty - itm_move->rtn_qty - Itm_move->void_qty
   nPLUtot:=itm_move->amount - itm_move->rtn_amount - itm_move->void_amt - itm_move->disc_amt
   prevplu:=itm_move->plu_code
   prevsrp:=itm_move->uprice
   prevexch:=itm_move->exch_rate
nLineCtr+=1
endif
/*
else
  nPLUqty+=0
  nPLUtot+=0
   prevplu:=itm_move->plu_code
   prevsrp:=itm_move->uprice
   prevexch:=itm_move->exch_rate
endif
*/

    if nLineCtr >= MAX_LINE 
    ?
    ? MARGIN+repl("-",nLineLen+13)
    ? MARGIN+"Page Totl: " + trans(nPageqty,"999,999.99") +;
            space(3) +  trans(nPagetot,"999,999,999.99")
    ? MARGIN+"Run. Totl: " + trans(nRunqty, "999,999.99") +;
            space(3) +  trans(nRuntot,"999,999,999.99")

    ? MARGIN + padl("Page # "+alltrim(trans(nPageCtr++,"9,999")),nLineLen+13)
    ? MARGIN+repl("-",nLineLen+13)
    ?
   // Reset page counter
     nPageqty := 0
     nPagetot := 0
     lNewPage := .t.
    // eject
    ? chr(12)
  endif

endif

ITM_MOVE->(DBSKIP())
enddo
 


  if lNewPage  
   // Create header if new page  
   ? MARGIN + "ITEM MOVEMENT REPORT"
   ?
   ? MARGIN +chr(254)+ SYS_NAME
   ? MARGIN +"Item Movement Report"
   ? MARGIN +"From "+dtoc(dStartDate)+" to "+dtoc(dEndDate)
   ? MARGIN +"As of "+dtoc(date())+", "+time()
   ? MARGIN +subs(cItemDesc,1,30)
   ? MARGIN +"Item Code: "+cItemCode
   ?
  	? MARGIN + "DATE        QUANTITY      NET AMOUNT     EXCH. RATE   SSRP         DISC. %    NSRP      "
   ? MARGIN + "--------   ----------   --------------   ----------   ----------   --------   ----------"
   //          12345678   1234567890   12345678901234   1234567890   1234567890   12345678   1234567890
   ?
   ?
 endif

IF !EMPTY(prevplu)

? MARGIN  + prevdate
??space(3)+ trans(nPLUqty,"999,999.99")
??space(3)+ trans(nPLUtot,"999,999,999.99")
??space(3)+ trans(prevexch,"999,999.99")
??space(3)+ trans(prevsrp,"999,999.99")
??space(3)+ trans(prevdrate*100,"  999.99")
??space(3)+ trans(prevsrp-(prevsrp*prevdrate),"999,999.99")

nPageqty+=nPLUqty
nRunqty+=nPLUqty
nPagetot+=nPLUtot
nRuntot+=nPLUtot

ENDIF

 ? MARGIN+repl("-",nLineLen+13)
 ? MARGIN+"Page Totl: " + trans(nPageqty,"999,999.99") +;
            space(3) +  trans(nPagetot,"999,999,999.99")
 ?  MARGIN+"Run. Totl: " +  trans(nRunqty,"999,999.99") +;
            space(3) +  trans(nRuntot,"999,999,999.99")
            
 ? MARGIN + padl("Page # "+alltrim(trans(nPageCtr++,"9,999"))+ " - Last Page",nLineLen+13)
 ? MARGIN+repl("-",nLineLen+13)
 ?
 ?  
 ?  MARGIN+"Total Quantity   : " + trans(nRunqty,"999,999,999.99")
 ?  MARGIN+"Total Amount     : " + trans(nRuntot,"999,999,999.99")
 ? 
 ?
 ? MARGIN+padc("********** End of Report **********",nLineLen )  
 ?
 ? chr(12)  

CLOSE ALTERNATE
SET ALTERNATE OFF
SET CONSOLE ON

aFsize := directory(REPORTFILE)

// check if repot file is < 64K
// direct to printer if greater   

if aFsize[1][2] < MAX_SIZE

  cReport:=memoread(REPORTFILE)
  if !empty(cReport)
   if !setmode(50,80) .and. !setmode(43,80)
      setmode(nMaxrow,nMaxcol)
   else
      _logo()   
   endif       
   Message("Use cursor keys to navigate, press F10 to print, "+ ;
              "Esc to abort.")
   wWindBuff:=OpenWindow(1,2,maxrow()-1,maxcol()-2,"Item Movement Report")
   MemoEdit(cReport,2,3,maxrow()-2,maxcol()-3,.f.,'EditorFunc',122-17 )
   CloseWindow(wWindBuff)
   setcursor(SC_NONE)
   setmode(nMaxrow,nMaxcol)
  endif
 
else

 if alert("Report too large to edit, will be directed to printer", {"Print","Quit"}) == 1 
    Direct2Prn(REPORTFILE) 
 endif  
 
endif  


cReport := "" //Free memory      
  
DbCloseAll()

killwindow()
tone ( 2100, 3 )

return nil


static function GetItem()
local wValid
cItemCode:=space(14)
    Message("Enter Item Code to cover reports")
    wValid := OpenWindow(09,12,15,66,"Printing Validation Box")
    @ 10,12 to 15,66 double    
      @ 12,17 say "Enter Item Code" get cItemCode pict "@K 99999999999999" valid VLDTPLU(cItemcode)
      SetCursor(SC_NORMAL)
      HeyThere()
      read
      SetCursor(SC_NONE)
    CloseWindow(wValid)
return if(LastKey()==K_ESC,.F.,.T.)


  
static function vldtplu(cPlu)
local lretval:=.f.
 if !empty(cPlu)
  cItemCode:=padl(alltrim(cPlu),14,"0")
  lretval:=.t.
 endif
return lretval  
