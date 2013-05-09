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
#define REPORTFILE  "BR_MOVE.PRN"
#define MAX_SIZE    65535
#define MAX_LINE    50    
#define EJECT_FROM_FILE
#define DEBUG
#define THIS_WIDTH (85 + PLU_CODE_LEN + PLU_DESC_LEN +PLU_CODE_LEN ) + LEFT_MARGIN 
 
memvar n,dStartDate,dEndDate,nLimit, GetList, cReport
static cBrandName

/*=========================================*/
function Br_MoveN()
/*=========================================*/
local cRef,wWindBuff
local nMaxrow := maxrow()+1, nMaxCol := maxcol()+1
local aFsize := {}
// Gauge variables
local nRecCtr := 0, hGauge, nPercent, nGaugeCtr:=1, wUpdate, dDate
local cName, dFile, code
local lNewPage := 0, nLineCtr := 0, nLinelen  := 65+5, nPageCtr := 1
local nPagetot := 0, nPageqty := 0, cWindow
local nReccount := 0, nCtr := 1, ccolor, coldpath
local nRuntot := 0, nRunqty := 0, prevsup := space(3)
local sup := space(3), cPname := space(20), nqtydisp := 0
local nRunUCost := 0, nPageUCost := 0
local prevplu:=space(14), prevpludesc:=space(25),prevdate:=space(8)
local nPLUqty:=0, nPLUtot:=0,nPLUindx:=1,aPLU:={},nPLUqtyacc:=0,nPLUtotacc:=0

if !Getvalid()
  BUMMER() ; return nil 
endif 


if !GetBrand()
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


Message("Preparing Brand Movement Report ...")

SET ALTERNATE TO ".\"+REPORTFILE
SET ALTERNATE ON
SET CONSOLE OFF
SET PRINTER OFF

window( 19, 1, 22, 60, CONFIRM_COLOR )



lNewPage := .t.

DO WHILE ITM_MOVE->(!EOF())

ITEM->(DBSEEK(ITM_MOVE->PLU_CODE))

if DatesOk(ITM_MOVE->DATE) .AND. alltrim(cBrandName) $ ITEM->I_037  //.and. ITM_MOVE->AMOUNT != 0

  // Create header if new page  
  if lNewPage  
   // Create header if new page  
   ? MARGIN + "BRAND MOVEMENT REPORT"
   ?
   ? MARGIN +chr(254)+ SYS_NAME
   ? MARGIN +"Brand Movement Report"
   ? MARGIN +"From "+dtoc(dStartDate)+" to "+dtoc(dEndDate)
   ? MARGIN +"As of "+dtoc(date())+", "+time()
   ? MARGIN + cBrandName
   ?
   ?
  	? MARGIN + "CODE                  DESCRIPTION            QUANTITY     NET AMOUNT       DATE    "
   ? MARGIN + "--------------   -------------------------   ----------   --------------   --------"
   //          12345678901234   1234567890123456789012345   1234567890   12345678901234   12345678
   ?
   ?
   lNewpage := .f.
   nLineCtr := 13
  endif


     if prevplu!=ITM_MOVE->PLU_CODE .and. !empty(prevplu)
? MARGIN  + prevplu 
??space(3)+ subs(prevpludesc,1,25)
??space(3)+ trans(nPLUqty,"999,999.99")
??space(3)+ trans(nPLUtot,"999,999,999.99")
??space(3)+ prevdate
nPLUqtyacc+=nPLUqty
nPLUtotacc+=nPLUtot
        ? MARGIN + SPACE(14+3+25+3) + REPL("-",10) + SPACE(3) + REPL("-",14)
        ? MARGIN + SPACE(14+3+25+3) + TRANS(nPLUqtyacc,"999,999.99")
        ??space(3)+trans(nPLUtotacc,"999,999,999.99")
        ?
nPageqty+=nPLUqty
nRunqty+=nPLUqty
nPagetot+=nPLUtot
nRuntot+=nPLUtot
        prevplu:=ITM_MOVE->PLU_CODE
        ITEM->(DBSEEK(prevplu))
        prevpludesc := subs(ITEM->I_037,1,25)
        nPLUqty:=0
        nPLUtot:=0
        nPLUqtyacc:=0
        nPLUtotacc:=0        
        prevdate:=dtoc(ITM_MOVE->DATE)
        nLineCtr+=4
     endif  


     if empty(prevplu)  
        prevplu:=ITM_MOVE->PLU_CODE
        prevdate:=dtoc(ITM_MOVE->DATE)
        ITEM->(DBSEEK(prevplu))
        prevpludesc:=subs(ITEM->I_037,1,25)
     endif

     if prevplu == ITM_MOVE->PLU_CODE .and. prevdate == dtoc(ITM_MOVE->DATE)
        nPLUqty += ITM_MOVE->QTY - ITM_MOVE->RTN_QTY - ITM_MOVE->VOID_QTY
        nPLUtot += ITM_MOVE->AMOUNT - ITM_MOVE->RTN_AMOUNT - ITM_MOVE->VOID_AMT - ITM_MOVE->DISC_AMT

//        nPLUqtyacc+=ITM_MOVE->QTY   
//        nPLUtotacc+=ITM_MOVE->AMOUNT
        
        prevplu := ITM_MOVE->PLU_CODE
        ITEM->(DBSEEK(prevplu))
        prevpludesc := subs(ITEM->I_037,1,25)
        prevdate := dtoc(ITM_MOVE->DATE)

     endif

     if prevplu == ITM_MOVE->PLU_CODE .and. prevdate != dtoc(ITM_MOVE->DATE )
? MARGIN  + prevplu 
??space(3)+ subs(prevpludesc,1,25)
??space(3)+ trans(nPLUqty,"999,999.99")
??space(3)+ trans(nPLUtot,"999,999,999.99")
??space(3)+ prevdate
nPageqty+=nPLUqty
nRunqty+=nPLUqty
nPagetot+=nPLUtot
nRuntot+=nPLUtot
nPLUqtyacc +=nPLUqty
nPLUtotacc +=nPLUtot

        nPLUqty:=ITM_MOVE->QTY - ITM_MOVE->RTN_QTY - ITM_MOVE->VOID_QTY
        nPLUtot:=ITM_MOVE->AMOUNT - ITM_MOVE->RTN_AMOUNT - ITM_MOVE->VOID_AMT - ITM_MOVE->DISC_AMT

        prevplu:=ITM_MOVE->PLU_CODE
        prevdate:=dtoc(ITM_MOVE->DATE)
        ITEM->(DBSEEK(prevplu))
        prevpludesc := subs(ITEM->I_037,1,25)
nLineCtr+=1        
     endif


    if nLineCtr >= MAX_LINE 
    ?
    ? MARGIN+repl("-",nLineLen+13)
    ? MARGIN+"Page Total    : " + space(24+3) +;
            space(2) +  trans(nPageqty,"999,999.99") +;
            space(3) +  trans(nPagetot,"999,999,999.99")
    ?  MARGIN+"Running Total : " +  space(24+3) +;
            space(2) +  trans(nRunqty,"999,999.99") +;
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
   ? MARGIN + "BRAND MOVEMENT REPORT"
   ?
   ? MARGIN +chr(254)+ SYS_NAME
   ? MARGIN +"Brand Movement Report"
   ? MARGIN +"From "+dtoc(dStartDate)+" to "+dtoc(dEndDate)
   ? MARGIN +"As of "+dtoc(date())+", "+time()
   ? MARGIN + cBrandName
   ?
   ?
  	? MARGIN + "CODE                  DESCRIPTION            QUANTITY     NET AMOUNT       DATE    "
   ? MARGIN + "--------------   -------------------------   ----------   --------------   --------"
   //          12345678901234   1234567890123456789012345   1234567890   12345678901234   12345678
   ?
   ?
 endif

IF !EMPTY(prevplu)
? MARGIN  + prevplu 
??space(3)+ subs(prevpludesc,1,25)
??space(3)+ trans(nPLUqty,"999,999.99")
??space(3)+ trans(nPLUtot,"999,999,999.99")
??space(3)+ prevdate
nPLUqtyacc+=nPLUqty
nPLUtotacc+=nPLUtot
        ? MARGIN + SPACE(14+3+25+3) + REPL("-",10) + SPACE(3) + REPL("-",14)
        ? MARGIN + SPACE(14+3+25+3) + TRANS(nPLUqtyacc,"999,999.99")
        ??space(3)+trans(nPLUtotacc,"999,999,999.99")
        ?
nPageqty+=nPLUqty
nRunqty+=nPLUqty
nPagetot+=nPLUtot
nRuntot+=nPLUtot
ENDIF

 ? MARGIN+repl("-",nLineLen+13)
 ? MARGIN+"Page Total    : " + space(24+3) +;
            space(2) +  trans(nPageqty,"999,999.99") +;
            space(3) +  trans(nPagetot,"999,999,999.99")
 ?  MARGIN+"Running Total : " +  space(24+3) +;
            space(2) +  trans(nRunqty,"999,999.99") +;
            space(3) +  trans(nRuntot,"999,999,999.99")
            
 ? MARGIN + padl("Page # "+alltrim(trans(nPageCtr++,"9,999"))+ " - Last Page",nLineLen+13)
 ? MARGIN+repl("-",nLineLen+13)
 ?
 ?  
// ?  MARGIN+"Net Quantity   : " + trans(nRunqty,"999,999,999.99")
// ?  MARGIN+"Net Amount     : " + trans(nRuntot,"999,999,999.99")
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
   wWindBuff:=OpenWindow(1,2,maxrow()-1,maxcol()-2,"Brand Movement Report")
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


static function Getbrand()
local wValid
cBrandName:=space(25)
    Message("Enter Brand Name to cover reports")
    wValid := OpenWindow(09,12,15,66,"Printing Validation Box")
    @ 10,12 to 15,66 double    
      @ 12,17 say "Enter Brand Name" get cBrandName pict "@!"
      SetCursor(SC_NORMAL)
      HeyThere()
      read
      SetCursor(SC_NONE)
    CloseWindow(wValid)
return if(LastKey()==K_ESC,.F.,.T.)
