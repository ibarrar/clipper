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

#define MARGIN      Space(1) 
#define REPORTFILE  "VOIDPREV.PRN"
#define MAX_SIZE    65535
#define MAX_LINE    50    
#define EJECT_FROM_FILE
#define DEBUG
#define THIS_WIDTH (85 + PLU_CODE_LEN + PLU_DESC_LEN +PLU_CODE_LEN ) + LEFT_MARGIN
 
memvar n,dStartDate,dEndDate,nLimit, GetList, cReport


/*=========================================*/
function VoidPrev()
/*=========================================*/
local cRef,wWindBuff
local nMaxrow := maxrow()+1, nMaxCol := maxcol()+1
local aFsize := {}
// Gauge variables
local nRecCtr := 0, hGauge, nPercent, nGaugeCtr:=1, wUpdate, dDate
local cName := space(20), dFile, code
local lNewPage := 0, nLineCtr := 0, nLinelen  := 8+59, nPageCtr := 1
local nPageslstot := 0, nPageslsqty := 0, cWindow
local nReccount := 0, nCtr := 1, ccolor, coldpath
local nRunslstot := 0, nRunslsqty := 0, count := 0, amount := 0
local cPname := space(20),  prevdept := space(4), prevdesc := space(20)
local lFirst := .f., ldate := .t., ncount := 0, namount := 0.00

local nPageTot:=0, nRunTot:=0

local prevccode:=space(12),prevposno:=space(12),prevtrans:=space(15)
local prevtime:=space(5),nVoidtot:=0,prevvoid:=0

if !Getvalid()
  BUMMER() ; return nil 
endif 


if netuse("DEPT", DB_SHARED, NUM_SECONDS)
    set index to DEPT
else
   alert("File 'DEPT.DBF' cannot be accessed",{"Quit"})
   return nil    
endif	 

if netuse("PLU", DB_SHARED, NUM_SECONDS)
    set index to PLU
else
   alert("File 'PLU.DBF' cannot be accessed",{"Quit"})
   return nil    
endif	 

if netuse("ITM_MOVE", DB_SHARED, NUM_SECONDS)
    set index to ITM_MOVE
else
   alert("File 'ITM_MOVE.DBF' cannot be accessed",{"Quit"})
   return nil    
endif	 

cOldPath := SET(_SET_PATH)

Message("Preparing Void Previous Report ...")


SET ALTERNATE TO ".\"+REPORTFILE
SET ALTERNATE ON
SET CONSOLE OFF
SET PRINTER OFF

window( 19, 1, 22, 60, CONFIRM_COLOR )

lNewPage := .t.
lFirst := .t.

Do While ITM_MOVE->(!Eof())  

  @ 1, 1 wsay " Creating " + "Void Previous Report" + "  Please wait ..."
  @ 2, 1 wsay " Dept Code: " + ITM_MOVE->DEPT_CODE + "    "

 if DatesOk(ITM_MOVE->DATE) .and. ITM_MOVE->FLAG=="T"

  // Create header if new page  
  if lNewPage  
   // Create header if new page  
   ? MARGIN + "VOID PREVIOUS REPORT"
   ?
   ? MARGIN +chr(254)+ SYS_NAME
   ? MARGIN +"Void Previous Report"
   ? MARGIN +"From "+dtoc(dStartDate)+" to "+dtoc(dEndDate)
   ? MARGIN +"As of "+dtoc(date())+", "+time()
   ?
   ?
//   ? MARGIN + SPACE(14+2+20+2) + "SALES     SRP       SALES         RETURN    RETURN        VOID      VOID          DISCOUNT     NET SALES                  ITEM      PROFIT     "    
//   ? MARGIN + SPACE(14+2+20+2) + "QTY                 AMT           QTY       AMT           QTY       AMT           AMT          AMT           QTY          COST                 " 

?  MARGIN   + PADR("CASHIER NO. ",12) 
?? SPACE(2) + PADR("TERMINAL NO.",12) 
?? SPACE(2) + PADR("TRANSACTION NO.",15)
?? SPACE(2) + PADR("TIME",5)
?? SPACE(2) + PADL("VOIDED AMOUNT",15)
   ?
   ? MARGIN + REPL("-",8+59) 
   ?
   ?
   lNewpage := .f.
   nLineCtr := 13
  endif   

if (prevtrans!=ITM_MOVE->TRANS_NO) .and. !empty(prevtrans)
? MARGIN  + PADR(prevccode,12)
??SPACE(2)+ PADL(prevposno,12)
??SPACE(2)+ PADR(prevtrans,15)
??SPACE(2)+ PADR( SUBS(prevtime,1,5),5)
??SPACE(2)+ TRANS(nVoidtot," 999,999,999.99")

nPageTot+=nVoidtot
nRunTot +=nVoidtot
nLineCtr+=1

nVoidtot:=0
prevccode:=ITM_MOVE->CASHCODE
prevposno:=ITM_MOVE->POS_NO
prevtrans:=ITM_MOVE->TRANS_NO
prevtime:=SUBS(ITM_MOVE->TIME,1,5)

endif

if empty(prevtrans)
prevccode:=ITM_MOVE->CASHCODE
prevposno:=ITM_MOVE->POS_NO
prevtrans:=ITM_MOVE->TRANS_NO
prevtime:=SUBS(ITM_MOVE->TIME,1,5)
prevvoid:=ITM_MOVE->VOID_AMT
endif

if prevtrans==ITM_MOVE->TRANS_NO
nVoidtot+=ITM_MOVE->VOID_AMT
prevccode:=ITM_MOVE->CASHCODE
prevposno:=ITM_MOVE->POS_NO
prevtrans:=ITM_MOVE->TRANS_NO
prevtime:=SUBS(ITM_MOVE->TIME,1,5)
endif

  // check if footer is needed, eject
  // reset counters
  if nLineCtr >= MAX_LINE 
     ? MARGIN+repl("-",nLineLen)
? MARGIN + "Page Total:     " + space(36) + trans(nPageTot," 999,999,999.99")
? MARGIN + "Run Total:      " + space(36) + trans(nRunTot ," 999,999,999.99")
? MARGIN+repl("-",nLineLen)
    ?
   // Reset page counter
     nPageTot:=0
            
     lNewPage := .t.
    // eject
    ? chr(12)
  endif

 endif 

 ITM_MOVE->(DbSkip())
enddo  

  if lNewPage  
   // Create header if new page  
   ? MARGIN + "VOID PREVIOUS REPORT"
   ?
   ? MARGIN +chr(254)+ SYS_NAME
   ? MARGIN +"Void Previous Report"
   ? MARGIN +"From "+dtoc(dStartDate)+" to "+dtoc(dEndDate)
   ? MARGIN +"As of "+dtoc(date())+", "+time()
   ?
   ?
//   ? MARGIN + SPACE(14+2+20+2) + "SALES     SRP       SALES         RETURN    RETURN        VOID      VOID          DISCOUNT     NET SALES                  ITEM      PROFIT     "    
//   ? MARGIN + SPACE(14+2+20+2) + "QTY                 AMT           QTY       AMT           QTY       AMT           AMT          AMT           QTY          COST                 " 

?  MARGIN   + PADR("CASHIER NO. ",12) 
?? SPACE(2) + PADR("TERMINAL NO.",12) 
?? SPACE(2) + PADR("TRANSACTION NO.",15)
?? SPACE(2) + PADR("TIME",5)
?? SPACE(2) + PADL("VOIDED AMOUNT",15)
?
   ? MARGIN + REPL("-",nLineLen) 
   ?
   ?
 endif   

? MARGIN  + PADR(prevccode,12)
??SPACE(2)+ PADL(prevposno,12)
??SPACE(2)+ PADR(prevtrans,15)
??SPACE(2)+ PADR( SUBS(prevtime,1,5),5)
??SPACE(2)+ TRANS(nVoidtot," 999,999,999.99")

nPageTot+=nVoidtot
nRunTot +=nVoidtot

 ? MARGIN+repl("-",nLineLen)
 ? MARGIN + "Page Total:     " + space(36) + trans(nPageTot," 999,999,999.99")
 ? MARGIN + "Run Total:      " + space(36) + trans(nRunTot ," 999,999,999.99")
 ? MARGIN + padl("Page # "+alltrim(trans(nPageCtr++,"9,999"))+ " - Last Page",nLineLen)
 ? MARGIN+repl("-",nLineLen)
 ?  
 ?  MARGIN+"Total Void Amount     : " + trans( nRunTot ,"999,999,999.99")
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
   wWindBuff:=OpenWindow(1,2,maxrow()-1,maxcol()-2,"Void Previous Report")
   MemoEdit(cReport,2,3,maxrow()-2,maxcol()-3,.f.,'Editor3Func',75 )
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
return nil




