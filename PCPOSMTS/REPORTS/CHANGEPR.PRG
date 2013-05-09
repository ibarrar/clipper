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
#define REPORTFILE  "CHANGEPR.PRN"
#define MAX_SIZE    65535
#define MAX_LINE    50    
#define EJECT_FROM_FILE
#define DEBUG
#define THIS_WIDTH (85 + PLU_CODE_LEN + PLU_DESC_LEN +PLU_CODE_LEN ) + LEFT_MARGIN 
 
memvar n,dStartDate,dEndDate,nLimit, GetList, cReport
static cItemCode

/*=========================================*/
function changepr()
/*=========================================*/
local cRef,wWindBuff
local nMaxrow := maxrow()+1, nMaxCol := maxcol()+1
local aFsize := {}
// Gauge variables
local nRecCtr := 0, hGauge, nPercent, nGaugeCtr:=1, wUpdate, dDate
local cName, dFile, code
local lNewPage := 0, nLineCtr := 0, nLinelen  := 65+5+5+27, nPageCtr := 1
local nPagetot := 0, nPageqty := 0, cWindow
local nReccount := 0, nCtr := 1, ccolor, coldpath,prevqty:=0
local nRuntot := 0, nRunqty := 0, prevsup := space(3),prevdrate:=0
local sup := space(3), cPname := space(20), nqtydisp := 0,nDamtacc:=0
local nRunUCost := 0, nPageUCost := 0,prevexch:=0,prevsrp:=0
local prevplu:=space(14), prevdesc:=space(20),prevdate:=space(8)
local nPLUqty:=0, nPLUtot:=0,nPLUindx:=1,aPLU:={},nPLUqtyacc:=0,nPLUtotacc:=0
local prevtransno:=space(8),prevdisctot:=0,prevvoidqty:=0,prevvoidtot:=0
local prevretqty:=0,prevrettot:=0,prevtot:=0,nFlg:=0
local PLUqty:=0,SRP:=0,Drate:=0,NSRP:=0,PLUtot:=0,Pdate:=space(8)
if !Getvalid()
  BUMMER() ; return nil 
endif 

/*
if !GetItem()
  BUMMER() ; return nil 
endif 
*/

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


Message("Preparing Change Price Report ...")

SET ALTERNATE TO ".\"+REPORTFILE
SET ALTERNATE ON
SET CONSOLE OFF
SET PRINTER OFF

window( 19, 1, 22, 60, CONFIRM_COLOR )



lNewPage := .t.
ITM_MOVE->(DBGOTOP())
DO WHILE ITM_MOVE->(!EOF())

if DatesOk(ITM_MOVE->DATE)

  // Create header if new page  
  if lNewPage  
   // Create header if new page  
   ? MARGIN + "CHANGE PRICE REPORT"
   ?
   ? MARGIN +chr(254)+ SYS_NAME
   ? MARGIN +"Change Price Report"
   ? MARGIN +"From "+dtoc(dStartDate)+" to "+dtoc(dEndDate)
   ? MARGIN +"As of "+dtoc(date())+", "+time()
   ?
   ?
   ?
  	? MARGIN + "CODE             DESCRIPTION            QTY.         SSRP         DISC. %    NSRP         TOTAL            DATE    "
   ? MARGIN + "--------------   --------------------   ----------   ----------   --------   ----------   --------------   --------"
   //          12345678901234   12345678901234567890   1234567890   1234567890   12345678   1234567890   12345678901234   12345678
   ?
   ?
   lNewpage := .f.
   nLineCtr := 13
  endif


     if prevdate!=dtoc(ITM_MOVE->DATE) .and. !empty(prevdate)
if nFlg==1
? MARGIN  + prevplu
??space(3)+ prevdesc
??space(3)+ trans(nPLUqty,"999,999.99")
??space(3)+ trans(prevsrp,"999,999.99")
??space(3)+ trans(prevdrate*100,"  999.99")
??space(3)+ trans( prevsrp-(prevsrp*prevdrate),"999,999.99")
??space(3)+ trans( nPLUtot,"999,999,999.99")
??space(3)+prevdate
nDamtacc+=nPLUtot
? MARGIN + SPACE(14+3+20+3+10+3+10+3+10+1+3+10) +REPL("-",14)
? MARGIN + SPACE(14+3+20+3+10+3+10+3+10+1+3+10) + trans(nDamtacc,"999,999,999.99")
?
nLineCtr+=4
endif
        prevplu:=ITM_MOVE->PLU_CODE
        ITEM->(DBSEEK(prevplu))
        prevdesc:=subs(ITEM->I_037,1,20)
        nPLUqty:=0
        nPLUtot:=0
        nDamtacc:=0
        prevexch:=ITM_MOVE->EXCH_RATE
        prevsrp:=ITM_MOVE->UPRICE
        prevdate:=dtoc(ITM_MOVE->DATE)
        prevdrate:=ITM_MOVE->DISC_RATE/100
        nFlg:=0
     endif  


     if empty(prevplu)
        prevplu:=ITM_MOVE->PLU_CODE
        prevdate:=dtoc(ITM_MOVE->DATE)
        prevsrp:= ITM_MOVE->UPRICE
        ITEM->(DBSEEK(ITM_MOVE->PLU_CODE))
        prevdesc:=SUBS(ITEM->I_037,1,20)
        prevdrate:=ITM_MOVE->DISC_RATE/100
        prevdisctot:=itm_move->disc_amt
        prevvoidqty:=itm_move->void_qty
        prevvoidtot:=itm_move->void_amt
        prevretqty:=itm_move->rtn_qty
        prevrettot:=itm_move->rtn_amount        
        nPLUqty:=0
        nPLUtot:=0
        prevtot:=0
        nFlg:=0
     endif

if prevplu!=itm_move->plu_code .and. !empty(prevplu)
if nFlg==1
? MARGIN  + prevplu
??space(3)+ prevdesc
??space(3)+ trans(nPLUqty,"999,999.99")
??space(3)+ trans(prevsrp,"999,999.99")
??space(3)+ trans(prevdrate*100,"  999.99")
??space(3)+ trans( prevsrp-(prevsrp*prevdrate),"999,999.99")
??space(3)+ trans( nPLUtot ,"999,999,999.99")
??space(3)+ prevdate
//nDamtacc+= (nPLUqty-prevqty) * prevsrp
nDamtacc+=nPLUtot
nLineCtr+=1        
endif
        prevplu:=ITM_MOVE->PLU_CODE
        prevdate:=dtoc(ITM_MOVE->DATE)
        prevsrp:= ITM_MOVE->UPRICE
        ITEM->(DBSEEK(ITM_MOVE->PLU_CODE))
        prevdesc:=SUBS(ITEM->I_037,1,20)
        prevdrate:=ITM_MOVE->DISC_RATE/100
        prevdisctot:=itm_move->disc_amt
        prevvoidqty:=itm_move->void_qty
        prevvoidtot:=itm_move->void_amt
        prevretqty:=itm_move->rtn_qty
        prevrettot:=itm_move->rtn_amount        
        nPLUqty:=0
        nPLUtot:=0
        nFlg:=0
endif        


     if prevplu == ITM_MOVE->PLU_CODE .and. prevsrp == ITM_MOVE->UPRICE
        nPLUqty+=ITM_MOVE->QTY- itm_move->rtn_qty - Itm_move->void_qty
        nPLUtot+=ITM_MOVE->AMOUNT - itm_move->rtn_amount - itm_move->void_amt - itm_move->disc_amt
        prevplu := ITM_MOVE->PLU_CODE
        ITEM->(DBSEEK(ITM_MOVE->PLU_CODE))
        prevdesc:=SUBS(ITEM->I_037,1,20)
        prevdate:= dtoc(ITM_MOVE->DATE)
        prevsrp := ITM_MOVE->UPRICE
        prevdrate:=ITM_MOVE->DISC_RATE /100  
        prevqty:=itm_move->qty
        prevexch:= ITM_MOVE->EXCH_RATE          
        prevtot:=ITM_MOVE->AMOUNT
        prevdisctot:=itm_move->disc_amt 
        prevvoidqty+=itm_move->void_qty
        prevvoidtot+=itm_move->void_amt
        prevretqty+=itm_move->rtn_qty
        prevrettot+=itm_move->rtn_amount
     endif

     if prevplu == ITM_MOVE->plu_code .and. (prevsrp != ITM_MOVE->UPRICE .or. prevexch!= ITM_MOVE->EXCH_RATE)

? MARGIN  + prevplu
??space(3)+ prevdesc
??space(3)+ trans(nPLUqty,"999,999.99")
??space(3)+ trans(prevsrp,"999,999.99")
??space(3)+ trans(prevdrate*100,"  999.99")
??space(3)+ trans(prevsrp-(prevsrp*prevdrate) ,"999,999.99")
??space(3)+ trans( nPLUtot ,"999,999,999.99")
??space(3)+ prevdate
//nDamtacc+= (nPLUqty-prevqty) * prevsrp
nDamtacc+=nPLUtot
/*
? MARGIN  + prevplu
??space(3)+ prevdesc
??space(3)+ trans(nPLUqty,"999,999.99")
??space(3)+ trans(prevsrp,"999,999.99")
??space(3)+ trans(prevdrate*100,"  999.99")
??space(3)+ trans( prevsrp-(prevsrp*prevdrate),"999,999.99")
??space(3)+ trans( nPLUtot ,"999,999,999.99")
??space(3)+ prevdate
//nDamtacc+= (nPLUqty-prevqty) * prevsrp
nDamtacc+=nPLUtot
*/
nLineCtr+=1
        prevplu:=ITM_MOVE->PLU_CODE
        prevdate:=dtoc(ITM_MOVE->DATE)
        prevsrp:= ITM_MOVE->UPRICE
        ITEM->(DBSEEK(ITM_MOVE->PLU_CODE))
        prevdesc:=SUBS(ITEM->I_037,1,20)
        prevdrate:=ITM_MOVE->DISC_RATE/100
        prevdisctot:=itm_move->disc_amt
        prevvoidqty:=itm_move->void_qty
        prevvoidtot:=itm_move->void_amt
        prevretqty:=itm_move->rtn_qty
        prevrettot:=itm_move->rtn_amount        
   nPLUqty:=itm_move->qty - itm_move->rtn_qty - Itm_move->void_qty
   nPLUtot:=itm_move->amount - itm_move->rtn_amount - itm_move->void_amt - itm_move->disc_amt
   prevexch:=itm_move->exch_rate
nFlg:=1


PLUqty:=nPLUqty
SRP:=prevsrp
Drate:=prevdrate*100
NSRP:=prevsrp-(prevsrp*prevdrate)
PLUtot:=nPLUtot
Pdate:=prevdate
/*
? MARGIN  + prevplu
??space(3)+ prevdesc
??space(3)+ trans(nPLUqty,"999,999.99")
??space(3)+ trans(prevsrp,"999,999.99")
??space(3)+ trans(prevdrate*100,"  999.99")
??space(3)+ trans( prevsrp-(prevsrp*prevdrate),"999,999.99")
??space(3)+ trans( nPLUtot ,"999,999,999.99")
??space(3)+ prevdate
//nDamtacc+= (nPLUqty-prevqty) * prevsrp
nDamtacc+=nPLUtot
nLineCtr+=1
*/
        prevplu:=ITM_MOVE->PLU_CODE
        prevdate:=dtoc(ITM_MOVE->DATE)
        prevsrp:= ITM_MOVE->UPRICE
        ITEM->(DBSEEK(ITM_MOVE->PLU_CODE))
        prevdesc:=SUBS(ITEM->I_037,1,20)
        prevdrate:=ITM_MOVE->DISC_RATE/100
        prevdisctot:=itm_move->disc_amt
        prevvoidqty:=itm_move->void_qty
        prevvoidtot:=itm_move->void_amt
        prevretqty:=itm_move->rtn_qty
        prevrettot:=itm_move->rtn_amount        
   nPLUqty:=itm_move->qty - itm_move->rtn_qty - Itm_move->void_qty
   nPLUtot:=itm_move->amount - itm_move->rtn_amount - itm_move->void_amt - itm_move->disc_amt
   prevexch:=itm_move->exch_rate
nFlg:=1
     endif

    if nLineCtr >= MAX_LINE 
/*
    ?
    ? MARGIN+repl("-",nLineLen+13)
    ? MARGIN+"Page Totl: " + trans(nPageqty,"999,999.99") +;
            space(3) +  trans(nPagetot,"999,999,999.99")
    ?  MARGIN+"Run. Totl: " +  trans(nRunqty,"999,999.99") +;
            space(3) +  trans(nRuntot,"999,999,999.99")

    ? MARGIN + padl("Page # "+alltrim(trans(nPageCtr++,"9,999")),nLineLen+13)
    ? MARGIN+repl("-",nLineLen+13)
    ?
*/

? MARGIN + SPACE(14+3+20+3+10+3+10+3+10+1+3+10) +REPL("-",14)
? MARGIN + SPACE(14+3+20+3+10+3+10+3+10+1+3+10) + trans(nDamtacc,"999,999,999.99")    
   nDamtacc:=0   
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
   ? MARGIN + "CHANGE PRICE REPORT"
   ?
   ? MARGIN +chr(254)+ SYS_NAME
   ? MARGIN +"Change Price Report"
   ? MARGIN +"From "+dtoc(dStartDate)+" to "+dtoc(dEndDate)
   ? MARGIN +"As of "+dtoc(date())+", "+time()
   ?
   ?
   ?
  	? MARGIN + "CODE             DESCRIPTION            QTY.         SSRP         DISC. %    NSRP         TOTAL            DATE    "
   ? MARGIN + "--------------   --------------------   ----------   ----------   --------   ----------   --------------   --------"
   //          12345678901234   12345678901234567890   1234567890   1234567890   12345678   1234567890   12345678901234   12345678
   ?
   ?
 endif

IF !EMPTY(prevplu)
if nFlg==1
? MARGIN  + prevplu
??space(3)+ prevdesc
??space(3)+ trans(nPLUqty,"999,999.99")
??space(3)+ trans(prevsrp,"999,999.99")
??space(3)+ trans(prevdrate*100,"  999.99")
??space(3)+ trans( prevsrp-(prevsrp*prevdrate),"999,999.99")
??space(3)+ trans( nPLUtot,"999,999,999.99")
??space(3)+prevdate
nDamtacc+=nPLUtot
endif
ENDIF
? MARGIN + SPACE(14+3+20+3+10+3+10+3+10+1+3+10) +REPL("-",14)
? MARGIN + SPACE(14+3+20+3+10+3+10+3+10+1+3+10) + trans(nDamtacc,"999,999,999.99")


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
   wWindBuff:=OpenWindow(1,2,maxrow()-1,maxcol()-2,"Change Price Report")
   MemoEdit(cReport,2,3,maxrow()-2,maxcol()-3,.f.,'EditorFunc',122 )
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

