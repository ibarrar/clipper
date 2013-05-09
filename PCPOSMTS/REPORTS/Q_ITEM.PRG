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
#define REPORTFILE  "ITEM.PRN"
#define MAX_SIZE    65535
#define MAX_LINE    50    
#define EJECT_FROM_FILE
#define DEBUG
#define THIS_WIDTH (85 + PLU_CODE_LEN + PLU_DESC_LEN +PLU_CODE_LEN ) + LEFT_MARGIN
 
memvar n,dStartDate,dEndDate, cReport
static nLimit
memvar GetList



/*=========================================*/
function RItem()
/*=========================================*/
local cRef,wWindBuff
local nMaxrow := maxrow()+1, nMaxCol := maxcol()+1
local aFsize := {}
// Gauge variables
local nRecCtr := 0, hGauge, nPercent, nGaugeCtr:=1, wUpdate, dDate
local cName, dFile, code
local lNewPage := 0, nLineCtr := 0, nLinelen  := 86, nPageCtr := 1
local nPageslstot := 0, nPageslsqty := 0, cWindow
local nReccount := 0, nCtr := 1, ccolor, coldpath
local nRunslstot := 0, nRunslsqty := 0, prevsup := space(3)
local sup := space(3), cPname := space(20), nqtydisp := 0
local nRunUCost := 0, nPageUCost := 0 // , aSup:={}

if !Getvalid()
  BUMMER() ; return nil 
endif 


if netuse("PLU", DB_SHARED, NUM_SECONDS)
    set index to ITEMCNT
else
   alert("File 'PLU.DBF' cannot be accessed",{"Quit"})
   return nil    
endif	 
if netuse("V", DB_SHARED, NUM_SECONDS)
    set index to V_001
else
   alert("File 'V.DBF' cannot be accessed",{"Quit"})
   return nil    
endif	 

cOldPath := SET(_SET_PATH)

Message("Preparing All Item Sales Report ...")


SET ALTERNATE TO ".\"+REPORTFILE
SET ALTERNATE ON
SET CONSOLE OFF
SET PRINTER OFF


window( 19, 1, 22, 60, CONFIRM_COLOR )

 lNewPage := .t.

/* do while V->(!eof())
 aadd(aSup,V->V_001)
V->(dbskip()) 
enddo */
prevsup := space(3)
  
PLU->(DbGoTop())
Do While PLU->(!Eof())

  @ 1, 1 wsay " Creating " + "All Item Sales Report" + "  Please wait ..."
  @ 2, 1 wsay " Item Code: " + PLU->CODE + "    "

if DatesOk(PLU->DATE) // .and. (aScan(aSup,subs(PLU->CODE,1,3)) !=0 )

  // Create header if new page  
  if lNewPage  
   // Create header if new page  
   ? MARGIN + "ALL ITEM SALES REPORT"
   ?
   ? MARGIN +chr(254)+ SYS_NAME
   ? MARGIN +"All Item Sales Report"
   ? MARGIN +"From "+dtoc(dStartDate)+" to "+dtoc(dEndDate)
   ? MARGIN +"As of "+dtoc(date())+", "+time()
   ?
   ?
  	? MARGIN + "BAR  CODE             DESCRIPTION       UNIT COST        QUANTITY     AMOUNT SOLD"
   ? MARGIN + "--------------   --------------------   --------------   ----------   --------------"
   //          12345678901234   12345678901234567890   12345678901234   1234567890   12345678901234
   ?

   lNewpage := .f.
   nLineCtr := 13
 endif
 

   ?  MARGIN + PLU->CODE
   if PLU->DESC != SPACE(20)
      ?? space(3) + PLU->DESC
   ELSE
      ?? space(3) + "PLU NOT FOUND !!!   " 
   ENDIF      
   ?? space(3) + tran(PLU->I_UCOST,"999,999,999.99")
   ?? space(3) + tran(PLU->ICOUNT,"99,999.99")
   ?? space(2) + tran(PLU->IAMOUNT,"999,999,999.99")
   nLineCtr += 1
 
    nPageslsqty += PLU->ICOUNT
    nPageslstot += PLU->IAMOUNT
    nPageUCost += PLU->I_UCOST
	 nRunslsqty += PLU->ICOUNT
    nRunslstot += PLU->IAMOUNT
    nRunUCost += PLU->I_UCOST
   
   
  
  // check if footer is needed, eject
  // reset counters
    if nLineCtr >= MAX_LINE 
    ?
    ? MARGIN+repl("-",nLineLen)
    ? MARGIN+"Page Total    : " + space(24) + trans(nPageUCost,"999,999,999.99") +;
            space(2) +  trans(nPageslsqty,"999,999.99") +;
            space(2) +  trans(nPageslstot,"999,999,999.99")
    ?  MARGIN+"Running Total : " +  space(24) + trans(nRunUCost,"999,999,999.99") +;
            space(2) +  trans(nRunslsqty,"999,999.99") +;
            space(2) +  trans(nRunslstot,"999,999,999.99")

    ? MARGIN + padl("Page # "+alltrim(trans(nPageCtr++,"9,999")),nLineLen)		  
    ? MARGIN+repl("-",nLineLen)
    ?
   // Reset page counter
     nPageslsqty := 0
     nPageslstot := 0
     nPageUCost := 0 

     lNewPage := .t.
    // eject
    ? chr(12)
  endif
 endif 
 PLU->(DbSkip())
enddo  

  if lNewPage  
   ? MARGIN + "ALL ITEMS SALES REPORT"
   ?
   ? MARGIN +chr(254)+ SYS_NAME
   ? MARGIN +"All Items Sales Report"
   ? MARGIN +"From "+dtoc(dStartDate)+" to "+dtoc(dEndDate)
   ? MARGIN +"As of "+dtoc(date())+", "+time()
   ?
   ?
   ?
   ? MARGIN + "BAR  CODE             DESCRIPTION       UNIT COST        QUANTITY     AMOUNT SOLD"
   ? MARGIN + "--------------   --------------------   --------------   ----------   --------------"
   //          12345678901234   12345678901234567890   12345678901234   1234567890   12345678901234
   ?
 endif


 ?
 ? MARGIN+repl("-",nLineLen)
 ? MARGIN+"Page Total    : " + space(24) + trans(nPageUCost,"999,999,999.99") +;
            space(2) +  trans(nPageslsqty,"999,999.99") +;
            space(2) +  trans(nPageslstot,"999,999,999.99")
 ?  MARGIN+"Running Total : " +  space(24) + trans(nRunUCost,"999,999,999.99") +;
            space(2) +  trans(nRunslsqty,"999,999.99") +;
            space(2) +  trans(nRunslstot,"999,999,999.99")
            
 ? MARGIN + padl("Page # "+alltrim(trans(nPageCtr++,"9,999"))+ " - Last Page",nLineLen)
 ? MARGIN+repl("-",nLineLen)
 ?
 ?  
 ?  MARGIN+"Total Quantity Sold  : " + alltrim(trans(nRunslsqty,"9,999,999.99"))
 ?  MARGIN+"Total Amount Sold    : " + alltrim(trans(nRunslstot,"999,999,999.99"))
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
   wWindBuff:=OpenWindow(1,2,maxrow()-1,maxcol()-2,"All Items Sales Report")
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


/*=========================================*/
function RPItem()
/*=========================================*/
local cRef,wWindBuff
local nMaxrow := maxrow()+1, nMaxCol := maxcol()+1
local aFsize := {}
// Gauge variables
local nRecCtr := 0, hGauge, nPercent, nGaugeCtr:=1, wUpdate, dDate
local cName, dFile, code
local lNewPage := 0, nLineCtr := 0, nLinelen  := 66, nPageCtr := 1
local nPageslstot := 0, nPageslsqty := 0, cWindow
local nReccount := 0, nCtr := 1, ccolor, coldpath
local nRunslstot := 0, nRunslsqty := 0
local cPname := space(20), sup := space(3)
local vRecord:= space(3), vBrowse


   SET CURSOR ON
   vBrowse := OpenWindow(15,30,17,50)
   @ 16,31 say "Supplier Code: "Get vRecord Pict "999"
   read
   SET CURSOR OFF
   CloseWindow(vBrowse)

   vRecord := padl(alltrim(vRecord),3,"0") 


if !Getvalid()
  BUMMER() ; return nil 
endif 


if netuse("V", DB_SHARED, NUM_SECONDS)
    set index to V_001
else
   alert("File 'V.DBF' cannot be accessed",{"Quit"})
   return nil    
endif	 

if netuse("PLU", DB_SHARED, NUM_SECONDS)
    set index to PLU
else
   alert("File 'PLU.DBF' cannot be accessed",{"Quit"})
   DbCloseAll()
   return nil    
endif	 

if netuse("ITEM.DBF", DB_SHARED, NUM_SECONDS)
  set index to I_001
else
   alert("File 'ITEM.DBF' cannot be accessed",{"Quit"})
   DbCloseAll()
   return nil
endif

cOldPath := SET(_SET_PATH)

Message("Preparing All Item Per Supplier Sales Report ...")


SET ALTERNATE TO ".\"+REPORTFILE
SET ALTERNATE ON
SET CONSOLE OFF
SET PRINTER OFF

window( 19, 1, 22, 70, CONFIRM_COLOR )

 lNewPage := .t.

Do While PLU->(!Eof())  

  @ 1, 1 wsay " Creating " + "All Item Per Supplier Sales Report" + "  Please wait ..."
  @ 2, 1 wsay " Item Code: " + PLU->CODE + "    "

 if DatesOk(PLU->DATE)

  // Create header if new page  
  if lNewPage  

   IF V->(DbSeek(vRecord))
      cName := V->V_002
   else
      cName := "** Code Not Found **"   
   endif   
   // Create header if new page  
   ? MARGIN + "ALL ITEM PER SUPPLIER SALES REPORT"
   ?
   ? MARGIN +chr(254)+ SYS_NAME
   ? MARGIN +"All Item Per Supplier Sales Report"
   ? MARGIN +"From "+dtoc(dStartDate)+" to "+dtoc(dEndDate)
   ? MARGIN +"As of "+dtoc(date())+", "+time()
   ? 
   ? MARGIN +"SUPPLIER NAME : " + cName
   ? 
	? MARGIN + "ITEM CODE             DESCRIPTION       QUANTITY     AMOUNT SOLD"
   ? MARGIN + "--------------   --------------------   ----------   --------------"
   //          12345678901234   12345678901234567890   1234567890   12345678901234
   ?
   ?

   lNewpage := .f.
   nLineCtr := 13
 endif
 

    IF ITEM->(DBSeek(PLU->CODE)) 
      cPname := ITEM->I_002
      sup := ITEM->I_020
    ELSE
      cPname := "** Code Not Found **"   
    ENDIF   

  if sup == vRecord  
  
   ? MARGIN + PLU->CODE
   ?? space(3) + cPName
   ?? space(3) + tran(PLU->ICOUNT,"999,999.99")
   ?? space(2) + tran(PLU->IAMOUNT,"999,999,999.99")
   nLineCtr += 1
 
    nPageslsqty += PLU->ICOUNT
    nPageslstot += PLU->IAMOUNT
    nRunslsqty += PLU->ICOUNT
    nRunslstot += PLU->IAMOUNT
  endif    
   
  
  // check if footer is needed, eject
  // reset counters
  if nLineCtr >= MAX_LINE 
    ?
	 ? MARGIN+repl("-",nLineLen)
    ? MARGIN+"Page Total    : " + space(22) + trans(nPageslsqty,"9,999,999.99") +;
            space(2) +  trans(nPageslstot,"999,999,999.99")
    ?  MARGIN+"Running Total : " + space(22) + trans(nRunslsqty,"9,999,999.99") +;
            space(2) + trans(nRunslstot,"999,999,999.99") 				  
    ? MARGIN + padl("Page # "+alltrim(trans(nPageCtr++,"9,999")),nLineLen)		  
    ? MARGIN+repl("-",nLineLen)
    ?
   // Reset page counter
     nPageslsqty := 0
     nPageslstot := 0
     lNewPage := .t.
    // eject
    ? chr(12)
  endif
 endif 
 PLU->(DbSkip())
enddo  

  if lNewPage  
//jzo04-03-98
   IF V->(DbSeek(vRecord))
      cName := V->V_002
   else
      cName := "** Code Not Found **"   
   endif   
  
   ? MARGIN + "ALL ITEM PER SUPPLIER SALES REPORT"
   ?
   ? MARGIN +chr(254)+ SYS_NAME
   ? MARGIN +"All Item Sales Report"
   ? MARGIN +"From "+dtoc(dStartDate)+" to "+dtoc(dEndDate)
   ? MARGIN +"As of "+dtoc(date())+", "+time()
   ? 
   ? MARGIN +"SUPPLIER NAME : " + cName
   ?
	? MARGIN + "ITEM CODE             DESCRIPTION       QUANTITY     AMOUNT SOLD"
   ? MARGIN + "--------------   --------------------   ----------   --------------"
   //          12345678901234   12345678901234567890   1234567890   12345678901234
   ?
   ?
 endif


 ?
 ? MARGIN+repl("-",nLineLen)
 ?  MARGIN+"Page Total    : " + space(22) + trans(nPageslsqty,"9,999,999.99") +;
              space(2) + trans(nPageslstot,"999,999,999.99") 
 ?  MARGIN+"Running Total : " + space(22) + trans(nRunslsqty,"9,999,999.99") +;
              space(2) + trans(nRunslstot,"999,999,999.99") 				  
 ? MARGIN + padl("Page # "+alltrim(trans(nPageCtr++,"9,999"))+ " - Last Page",nLineLen)
 ? MARGIN+repl("-",nLineLen)
 ?
 ?  
 ?  MARGIN+"Total Quantity Sold  : " + alltrim(trans(nRunslsqty,"9,999,999.99"))
 ?  MARGIN+"Total Amount Sold    : " + alltrim(trans(nRunslstot,"999,999,999.99"))
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
   wWindBuff:=OpenWindow(1,2,maxrow()-1,maxcol()-2,"All Item Per Supplier Sales Report")
   MemoEdit(cReport,2,3,maxrow()-2,maxcol()-3,.f.,'Editor2Func',122 )
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



/*=========================================*/
function NFItem()
/*=========================================*/
local cRef,wWindBuff
local nMaxrow := maxrow()+1, nMaxCol := maxcol()+1
local aFsize := {}
// Gauge variables
local nRecCtr := 0, hGauge, nPercent, nGaugeCtr:=1, wUpdate, dDate
local cName, dFile, code
local lNewPage := 0, nLineCtr := 0, nLinelen  := 48, nPageCtr := 1
local nPageslstot := 0, nPageslsqty := 0, cWindow
local nReccount := 0, nCtr := 1, ccolor, coldpath
local nRunslstot := 0, nRunslsqty := 0, prevsup := space(3)
local sup := space(3), cPname := space(20), nqtydisp := 0
local nRunUCost := 0, nPageUCost := 0

if !Getvalid()
  BUMMER() ; return nil 
endif 


if netuse("NPLU", DB_SHARED, NUM_SECONDS)
    set index to NITEMCNT
else
   alert("File 'NPLU.DBF' cannot be accessed",{"Quit"})
   return nil    
endif	 



cOldPath := SET(_SET_PATH)

Message("Preparing Not Found Plucode Report ...")


SET ALTERNATE TO ".\"+REPORTFILE
SET ALTERNATE ON
SET CONSOLE OFF
SET PRINTER OFF


window( 19, 1, 22, 60, CONFIRM_COLOR )


 lNewPage := .t.

prevsup := space(3)  
NPLU->(DbGoTop())
Do While NPLU->(!Eof())  

  @ 1, 1 wsay " Creating " + "Not Found PLU Report" + "  Please wait ..."
  @ 2, 1 wsay " Item Code: " + NPLU->CODE + "    "

if DatesOk(NPLU->DATE)

  // Create header if new page  
  if lNewPage  
   // Create header if new page  
   ? MARGIN + "NOT FOUND PLUCODE REPORT"
   ?
   ? MARGIN +chr(254)+ SYS_NAME
   ? MARGIN +"Not Found PluCode Report"
   ? MARGIN +"From "+dtoc(dStartDate)+" to "+dtoc(dEndDate)
   ? MARGIN +"As of "+dtoc(date())+", "+time()
   ?
   ?
   ? MARGIN + "BAR  CODE        QUANTITY     AMOUNT SOLD"
   ? MARGIN + "--------------   ----------   --------------"
   //          12345678901234   1234567890   12345678901234
   ?

   lNewpage := .f.
   nLineCtr := 13
 endif
 

   ?  MARGIN + NPLU->CODE
   ?? space(3) + tran(NPLU->ICOUNT,"99,999.99")
   ?? space(2) + tran(NPLU->IAMOUNT,"999,999,999.99")
   nLineCtr += 1
 
    nPageslsqty += NPLU->ICOUNT
    nPageslstot += NPLU->IAMOUNT
    nPageUCost += NPLU->I_UCOST
	 nRunslsqty += NPLU->ICOUNT
    nRunslstot += NPLU->IAMOUNT
    nRunUCost += NPLU->I_UCOST
   
   
  
  // check if footer is needed, eject
  // reset counters
    if nLineCtr >= MAX_LINE 
    ?
    ? MARGIN+repl("-",nLineLen)
    ? MARGIN+"Page Total    : " + space(2) +  trans(nPageslsqty,"999,999.99") +;
            space(2) +  trans(nPageslstot,"999,999,999.99")
    ?  MARGIN+"Running Total : "  + space(2) +  trans(nRunslsqty,"999,999.99") +;
            space(2) +  trans(nRunslstot,"999,999,999.99")

    ? MARGIN + padl("Page # "+alltrim(trans(nPageCtr++,"9,999")),nLineLen)		  
    ? MARGIN+repl("-",nLineLen)
    ?
   // Reset page counter
     nPageslsqty := 0
     nPageslstot := 0
     nPageUCost := 0 

     lNewPage := .t.
    // eject
    ? chr(12)
  endif
 endif 
 NPLU->(DbSkip())
enddo  

  if lNewPage  
   ? MARGIN + "NOT FOUND PLU REPORT"
   ?
   ? MARGIN +chr(254)+ SYS_NAME
   ? MARGIN +"Not Found PLU Report"
   ? MARGIN +"From "+dtoc(dStartDate)+" to "+dtoc(dEndDate)
   ? MARGIN +"As of "+dtoc(date())+", "+time()
   ?
   ?
   ?
   ? MARGIN + "BAR  CODE        QUANTITY     AMOUNT SOLD"
   ? MARGIN + "--------------   ----------   --------------"
   //          12345678901234   1234567890   12345678901234
   ?
 endif


 ?
 ? MARGIN+repl("-",nLineLen)
 ? MARGIN+"Page Total    : " + space(2) +  trans(nPageslsqty,"999,999.99") +;
            space(2) +  trans(nPageslstot,"999,999,999.99")
 ?  MARGIN+"Running Total : " + space(2) +  trans(nRunslsqty,"999,999.99") +;
            space(2) +  trans(nRunslstot,"999,999,999.99")
            
 ? MARGIN + padl("Page # "+alltrim(trans(nPageCtr++,"9,999"))+ " - Last Page",nLineLen)
 ? MARGIN+repl("-",nLineLen)
 ?
 ?  
 ?  MARGIN+"Total Quantity Sold  : " + alltrim(trans(nRunslsqty,"9,999,999.99"))
 ?  MARGIN+"Total Amount Sold    : " + alltrim(trans(nRunslstot,"999,999,999.99"))
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
   wWindBuff:=OpenWindow(1,2,maxrow()-1,maxcol()-2,"Not Found PluCode Report")
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


static function Qty2Disp()
local wValid
  nLimit:=10
    Message("Enter number of items to list")
    wValid := OpenWindow(09,12,14,66,"Printing Validation Box")
    @ 10,12 to 14,66 double    
      @ 12,17 say "Enter item count to display" get nLimit pict "999999"
      SetCursor(SC_NORMAL)
      HeyThere()
      read
      SetCursor(SC_NONE)
    CloseWindow(wValid)
return lastkey() <> K_ESC



/*=========================================*/
function RFItem()
/*=========================================*/
local cRef,wWindBuff
local nMaxrow := maxrow()+1, nMaxCol := maxcol()+1
local aFsize := {}
// Gauge variables
local nRecCtr := 0, hGauge, nPercent, nGaugeCtr:=1, wUpdate, dDate
local cName, dFile, code
local lNewPage := 0, nLineCtr := 0, nLinelen  := 86, nPageCtr := 1
local nPagetot := 0, nPageqty := 0, cWindow
local nReccount := 0, nCtr := 1, ccolor, coldpath
local nRuntot := 0, nRunqty := 0, prevsup := space(3)
local sup := space(3), cPname := space(20), nqtydisp := 0
local nRunUCost := 0, nPageUCost := 0
local prevplu:=space(14), prevpludesc:=space(20)
local nPLUqty:=0, nPLUtot:=0,nPLUindx:=1,aPLU:={}

if !Getvalid()
  BUMMER() ; return nil 
endif 

if !Qty2Disp()
   BUMMER() ; return nil 
endif

if netuse("PLU",DB_SHARED, NUM_SECONDS)
	set index to DATEPLU
endif	
	
cOldPath := SET(_SET_PATH)

PLU->(dbgobottom())
do while PLU->(!BOF())
  if DatesOk(PLU->DATE)

     if prevplu!=PLU->CODE .and. !empty(prevplu)
        aadd(aPLU,{prevplu,prevpludesc,nPLUqty,nPLUtot})
        prevplu:=PLU->CODE
        prevpludesc := PLU->DESC
        nPLUqty:=0
        nPLUtot:=0
     endif  

     if empty(prevplu)  
        prevplu:=PLU->CODE
        prevpludesc:=PLU->DESC
     endif

     if prevplu == PLU->CODE
        nPLUqty += PLU->ICOUNT - PLU->RTN_QTY - PLU->VOID_QTY
        nPLUtot += PLU->IAMOUNT - PLU->RTN_AMT - PLU->VOID_AMT - PLU->DISC_AMT
        prevpludesc := PLU->DESC
     endif
  
  endif
  PLU->(DbSkip(-1))  
enddo

     if !empty(prevplu)
        aadd(aPLU,{prevplu,prevpludesc,nPLUqty,nPLUtot})
        prevplu := PLU->CODE
        prevpludesc := PLU->DESC
     endif   
ASORT(aPLU,,,{|x,y| x[3]>y[3]})

Message("Preparing Fast Moving Item Sales Report ...")

SET ALTERNATE TO ".\"+REPORTFILE
SET ALTERNATE ON
SET CONSOLE OFF
SET PRINTER OFF

window( 19, 1, 22, 60, CONFIRM_COLOR )

lNewPage := .t.
for nPLUindx:=1 to len(aPLU)

  // Create header if new page  
  if lNewPage  
   // Create header if new page  
   ? MARGIN + "FAST MOVING ITEM SALES REPORT"
   ?
   ? MARGIN +chr(254)+ SYS_NAME
   ? MARGIN +"Fast Moving Item Sales Report"
   ? MARGIN +"From "+dtoc(dStartDate)+" to "+dtoc(dEndDate)
   ? MARGIN +"As of "+dtoc(date())+", "+time()
   ? MARGIN +"By Quantity"
   ?
  	? MARGIN + "BAR  CODE             DESCRIPTION       QUANTITY     NET AMOUNT "
   ? MARGIN + "--------------   --------------------   ----------   --------------"
   //          12345678901234   12345678901234567890   1234567890   12345678901234
   ?

   lNewpage := .f.
   nLineCtr := 13
 endif

?  MARGIN +  aPLU[nPLUindx][1]
??space(2)+ aPLU[nPLUindx][2]
??space(3)+ trans(aPLU[nPLUindx][3],"999,999.99")
??space(3)+ trans(aPLU[nPLUindx][4],"999,999,999.99")
    
   nPageqty += aPLU[nPLUindx][3]
   nPagetot += aPLU[nPLUindx][4]
   nRunqty  += aPLU[nPLUindx][3]
   nRuntot  += aPLU[nPLUindx][4]
nLineCtr+=1
nQtyDisp+=1

    if nLineCtr >= MAX_LINE 
    ?
    ? MARGIN+repl("-",nLineLen-17)
    ? MARGIN+"Page Total    : " + space(24-3) +;
            space(2) +  trans(nPageqty,"999,999.99") +;
            space(3) +  trans(nPagetot,"999,999,999.99")
    ?  MARGIN+"Running Total : " +  space(24-3) +;
            space(2) +  trans(nRunqty,"999,999.99") +;
            space(3) +  trans(nRuntot,"999,999,999.99")

    ? MARGIN + padl("Page # "+alltrim(trans(nPageCtr++,"9,999")),nLineLen-17)		  
    ? MARGIN+repl("-",nLineLen-17)
    ?
   // Reset page counter
     nPageqty := 0
     nPagetot := 0
//     nPageUCost := 0 

     lNewPage := .t.
    // eject
    ? chr(12)
  endif
  if nQtyDisp == nLimit
     exit
   endif             
 
next


  if lNewPage  
   ? MARGIN + "FAST MOVING ITEM SALES REPORT"
   ?
   ? MARGIN +chr(254)+ SYS_NAME
   ? MARGIN +"Fast Moving Item Sales Report"
   ? MARGIN +"From "+dtoc(dStartDate)+" to "+dtoc(dEndDate)
   ? MARGIN +"As of "+dtoc(date())+", "+time()
   ? MARGIN +"By Quantity"
   ?
   ?
   ? MARGIN + "BAR  CODE             DESCRIPTION       QUANTITY     NET AMOUNT "
   ? MARGIN + "--------------   --------------------   ----------   --------------"
   //          12345678901234   12345678901234567890   1234567890   12345678901234
   ?
 endif

 ? MARGIN+repl("-",nLineLen-17)
 ? MARGIN+"Page Total    : " + space(24-3) +;
            space(2) +  trans(nPageqty,"999,999.99") +;
            space(3) +  trans(nPagetot,"999,999,999.99")
 ?  MARGIN+"Running Total : " +  space(24-3) +;
            space(2) +  trans(nRunqty,"999,999.99") +;
            space(3) +  trans(nRuntot,"999,999,999.99")
            
 ? MARGIN + padl("Page # "+alltrim(trans(nPageCtr++,"9,999"))+ " - Last Page",nLineLen-17)
 ? MARGIN+repl("-",nLineLen-17)
 ?
 ?  
 ?  MARGIN+"Net Quantity   : " + trans(nRunqty,"999,999,999.99")
 ?  MARGIN+"Net Amount     : " + trans(nRuntot,"999,999,999.99")
 ? 
 ?
 ? MARGIN+padc("********** End of Report **********",nLineLen-17 )  
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
   wWindBuff:=OpenWindow(1,2,maxrow()-1,maxcol()-2,"Fast Moving Item Sales Report")
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




/*=========================================*/
function RFAmt()
/*=========================================*/
local cRef,wWindBuff
local nMaxrow := maxrow()+1, nMaxCol := maxcol()+1
local aFsize := {}
// Gauge variables
local nRecCtr := 0, hGauge, nPercent, nGaugeCtr:=1, wUpdate, dDate
local cName, dFile, code
local lNewPage := 0, nLineCtr := 0, nLinelen  := 86, nPageCtr := 1
local nPagetot := 0, nPageqty := 0, cWindow
local nReccount := 0, nCtr := 1, ccolor, coldpath
local nRuntot := 0, nRunqty := 0, prevsup := space(3)
local sup := space(3), cPname := space(20), nqtydisp := 0
local nRunUCost := 0, nPageUCost := 0
local prevplu:=space(14), prevpludesc:=space(20)
local nPLUqty:=0, nPLUtot:=0,nPLUindx:=1,aPLU:={}

if !Getvalid()
  BUMMER() ; return nil 
endif 

if !Qty2Disp()
   BUMMER() ; return nil 
endif

if netuse("PLU.DBF", DB_SHARED, NUM_SECONDS)
    set index to DATEPLU
else
   alert("File 'PLU.DBF' cannot be accessed",{"Quit"})
   return nil    
endif	 

cOldPath := SET(_SET_PATH)

PLU->(dbgobottom())
do while PLU->(!BOF())
  if DatesOk(PLU->DATE)

     if prevplu!=PLU->CODE .and. !empty(prevplu)
        aadd(aPLU,{prevplu,prevpludesc,nPLUqty,nPLUtot})
        prevplu := PLU->CODE
        prevpludesc := PLU->DESC
        nPLUqty:=0
        nPLUtot:=0
     endif  

     if empty(prevplu)  
        prevplu:= PLU->CODE
        prevpludesc := PLU->DESC
     endif

     if prevplu == PLU->PLU_CODE
        nPLUqty += PLU->ICOUNT - PLU->RTN_QTY - PLU->VOID_QTY
        nPLUtot += PLU->IAMOUNT - PLU->RTN_AMT - PLU->VOID_AMT - PLU->DISC_AMT
        prevpludesc := PLU->DESC
     endif
  
  endif
  PLU->(DBSKIP(-1))  
enddo

     if !empty(prevplu)
        aadd(aPLU,{prevplu,prevpludesc,nPLUqty,nPLUtot})
        prevplu:=PLU->CODE
        prevpludesc := PLU->DESC
     endif   
ASORT(aPLU,,,{|x,y| x[4]>y[4]})

Message("Preparing Fast Moving Item Sales Report ...")

SET ALTERNATE TO ".\"+REPORTFILE
SET ALTERNATE ON
SET CONSOLE OFF
SET PRINTER OFF

window( 19, 1, 22, 60, CONFIRM_COLOR )

lNewPage := .t.
for nPLUindx:=1 to len(aPLU)

  // Create header if new page  
  if lNewPage  
   // Create header if new page  
   ? MARGIN + "FAST MOVING ITEM SALES REPORT"
   ?
   ? MARGIN +chr(254)+ SYS_NAME
   ? MARGIN +"Fast Moving Item Sales Report"
   ? MARGIN +"From "+dtoc(dStartDate)+" to "+dtoc(dEndDate)
   ? MARGIN +"As of "+dtoc(date())+", "+time()
   ? MARGIN +"By Amount"
   ?
  	? MARGIN + "BAR  CODE             DESCRIPTION       QUANTITY     NET AMOUNT "
   ? MARGIN + "--------------   --------------------   ----------   --------------"
   //          12345678901234   12345678901234567890   1234567890   12345678901234
   ?

   lNewpage := .f.
   nLineCtr := 13
 endif

?  MARGIN +  aPLU[nPLUindx][1]
??space(2)+ aPLU[nPLUindx][2]
??space(3)+ trans(aPLU[nPLUindx][3],"999,999.99")
??space(3)+ trans(aPLU[nPLUindx][4],"999,999,999.99")
    
   nPageqty += aPLU[nPLUindx][3]
   nPagetot += aPLU[nPLUindx][4]
   nRunqty  += aPLU[nPLUindx][3]
   nRuntot  += aPLU[nPLUindx][4]
nLineCtr+=1
nQtyDisp+=1
    if nLineCtr >= MAX_LINE 
    ?
    ? MARGIN+repl("-",nLineLen-17)
    ? MARGIN+"Page Total    : " + space(24-3) +;
            space(2) +  trans(nPageqty,"999,999.99") +;
            space(3) +  trans(nPagetot,"999,999,999.99")
    ?  MARGIN+"Running Total : " +  space(24-3) +;
            space(2) +  trans(nRunqty,"999,999.99") +;
            space(3) +  trans(nRuntot,"999,999,999.99")

    ? MARGIN + padl("Page # "+alltrim(trans(nPageCtr++,"9,999")),nLineLen-17)		  
    ? MARGIN+repl("-",nLineLen-17)
    ?
   // Reset page counter
     nPageqty := 0
     nPagetot := 0
//     nPageUCost := 0 

     lNewPage := .t.
    // eject
    ? chr(12)
  endif
  if nQtyDisp == nLimit
     exit
   endif             
 
next


  if lNewPage  
   ? MARGIN + "FAST MOVING ITEM SALES REPORT"
   ?
   ? MARGIN +chr(254)+ SYS_NAME
   ? MARGIN +"Fast Moving Item Sales Report"
   ? MARGIN +"From "+dtoc(dStartDate)+" to "+dtoc(dEndDate)
   ? MARGIN +"As of "+dtoc(date())+", "+time()
   ? MARGIN +"By Amount"
   ?
   ?
   ? MARGIN + "BAR  CODE             DESCRIPTION       QUANTITY     NET AMOUNT "
   ? MARGIN + "--------------   --------------------   ----------   --------------"
   //          12345678901234   12345678901234567890   1234567890   12345678901234
   ?
 endif


 ? MARGIN+repl("-",nLineLen-17)
 ? MARGIN+"Page Total    : " + space(24-3) +;
            space(2) +  trans(nPageqty,"999,999.99") +;
            space(3) +  trans(nPagetot,"999,999,999.99")
 ?  MARGIN+"Running Total : " +  space(24-3) +;
            space(2) +  trans(nRunqty,"999,999.99") +;
            space(3) +  trans(nRuntot,"999,999,999.99")
            
 ? MARGIN + padl("Page # "+alltrim(trans(nPageCtr++,"9,999"))+ " - Last Page",nLineLen-17)
 ? MARGIN+repl("-",nLineLen-17)
 ?
 ?  
 ?  MARGIN+"Net Quantity   : " + trans(nRunqty,"999,999,999.99")
 ?  MARGIN+"Net Amount     : " + trans(nRuntot,"999,999,999.99")
 ? 
 ?
 ? MARGIN+padc("********** End of Report **********",nLineLen-17 )  
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
   wWindBuff:=OpenWindow(1,2,maxrow()-1,maxcol()-2,"Fast Moving Item Sales Report")
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


/*=========================================*/
function RSItem()
/*=========================================*/
local cRef,wWindBuff
local nMaxrow := maxrow()+1, nMaxCol := maxcol()+1
local aFsize := {}
// Gauge variables
local nRecCtr := 0, hGauge, nPercent, nGaugeCtr:=1, wUpdate, dDate
local cName, dFile, code
local lNewPage := 0, nLineCtr := 0, nLinelen  := 86, nPageCtr := 1
local nPagetot := 0, nPageqty := 0, cWindow
local nReccount := 0, nCtr := 1, ccolor, coldpath
local nRuntot := 0, nRunqty := 0, prevsup := space(3)
local sup := space(3), cPname := space(20), nqtydisp := 0
local nRunUCost := 0, nPageUCost := 0
local prevplu:=space(14), prevpludesc:=space(20)
local nPLUqty:=0, nPLUtot:=0,nPLUindx:=1,aPLU:={}

if !Getvalid()
  BUMMER() ; return nil 
endif 

if !Qty2Disp()
   BUMMER() ; return nil 
endif

if netuse("PLU.DBF", DB_SHARED, NUM_SECONDS)
    set index to DATEPLU
else
   alert("File 'PLU.DBF' cannot be accessed",{"Quit"})
   return nil    
endif	 

cOldPath := SET(_SET_PATH)

PLU->(dbgotop())
while PLU->(!EOF())
  if DatesOk(PLU->DATE)

     if prevplu!=PLU->CODE .and. !empty(prevplu)
        aadd(aPLU,{prevplu,prevpludesc,nPLUqty,nPLUtot})
        prevplu := PLU->CODE
        prevpludesc := PLU->DESC
        nPLUqty:=0
        nPLUtot:=0
     endif  

     if empty(prevplu)  
        prevplu := PLU->CODE
        prevpludesc := PLU->DESC
     endif

     if prevplu == PLU->CODE
        nPLUqty += PLU->ICOUNT - PLU->RTN_QTY - PLU->VOID_QTY
        nPLUtot += PLU->IAMOUNT - PLU->RTN_AMT - PLU->VOID_AMT - PLU->DISC_AMT
        prevpludesc := PLU->DESC
     endif
  
  endif
PLU->(DBSKIP())  
enddo

     if !empty(prevplu)
        aadd(aPLU,{prevplu,prevpludesc,nPLUqty,nPLUtot})
        prevplu := PLU->CODE
        prevpludesc := PLU->DESC
     endif   
ASORT(aPLU,,,{|x,y| x[3]<y[3]})

Message("Preparing Slow Moving Item Sales Report ...")

SET ALTERNATE TO ".\"+REPORTFILE
SET ALTERNATE ON
SET CONSOLE OFF
SET PRINTER OFF

window( 19, 1, 22, 60, CONFIRM_COLOR )

lNewPage := .t.
for nPLUindx:=1 to len(aPLU)

  // Create header if new page  
  if lNewPage  
   // Create header if new page  
   ? MARGIN + "SLOW MOVING ITEM SALES REPORT"
   ?
   ? MARGIN +chr(254)+ SYS_NAME
   ? MARGIN +"Slow Moving Item Sales Report"
   ? MARGIN +"From "+dtoc(dStartDate)+" to "+dtoc(dEndDate)
   ? MARGIN +"As of "+dtoc(date())+", "+time()
   ? MARGIN +"By Quantity"
   ?
  	? MARGIN + "BAR  CODE             DESCRIPTION       QUANTITY     NET AMOUNT "
   ? MARGIN + "--------------   --------------------   ----------   --------------"
   //          12345678901234   12345678901234567890   1234567890   12345678901234
   ?

   lNewpage := .f.
   nLineCtr := 13
 endif

?  MARGIN +  aPLU[nPLUindx][1]
??space(2)+ aPLU[nPLUindx][2]
??space(3)+ trans(aPLU[nPLUindx][3],"999,999.99")
??space(3)+ trans(aPLU[nPLUindx][4],"999,999,999.99")
    
   nPageqty += aPLU[nPLUindx][3]
   nPagetot += aPLU[nPLUindx][4]
   nRunqty  += aPLU[nPLUindx][3]
   nRuntot  += aPLU[nPLUindx][4]
nLineCtr+=1
nQtyDisp+=1
    if nLineCtr >= MAX_LINE 
    ?
    ? MARGIN+repl("-",nLineLen-17)
    ? MARGIN+"Page Total    : " + space(24-3) +;
            space(2) +  trans(nPageqty,"999,999.99") +;
            space(3) +  trans(nPagetot,"999,999,999.99")
    ?  MARGIN+"Running Total : " +  space(24-3) +;
            space(2) +  trans(nRunqty,"999,999.99") +;
            space(3) +  trans(nRuntot,"999,999,999.99")

    ? MARGIN + padl("Page # "+alltrim(trans(nPageCtr++,"9,999")),nLineLen-17)		  
    ? MARGIN+repl("-",nLineLen-17)
    ?
   // Reset page counter
     nPageqty := 0
     nPagetot := 0
     lNewPage := .t.
    // eject
    ? chr(12)
  endif
  if nQtyDisp == nLimit
     exit
   endif             
 
next


  if lNewPage  
   ? MARGIN + "SLOW MOVING ITEM SALES REPORT"
   ?
   ? MARGIN +chr(254)+ SYS_NAME
   ? MARGIN +"Slow Moving Item Sales Report"
   ? MARGIN +"From "+dtoc(dStartDate)+" to "+dtoc(dEndDate)
   ? MARGIN +"As of "+dtoc(date())+", "+time()
   ? MARGIN +"By Quantity"
   ?
   ?
   ? MARGIN + "BAR  CODE             DESCRIPTION       QUANTITY     NET AMOUNT "
   ? MARGIN + "--------------   --------------------   ----------   --------------"
   //          12345678901234   12345678901234567890   1234567890   12345678901234
   ?
 endif

 ? MARGIN+repl("-",nLineLen-17)
 ? MARGIN+"Page Total    : " + space(24-3) +;
            space(2) +  trans(nPageqty,"999,999.99") +;
            space(3) +  trans(nPagetot,"999,999,999.99")
 ?  MARGIN+"Running Total : " +  space(24-3) +;
            space(2) +  trans(nRunqty,"999,999.99") +;
            space(3) +  trans(nRuntot,"999,999,999.99")
            
 ? MARGIN + padl("Page # "+alltrim(trans(nPageCtr++,"9,999"))+ " - Last Page",nLineLen-17)
 ? MARGIN+repl("-",nLineLen-17)
 ?
 ?  
 ?  MARGIN+"Net Quantity   : " + trans(nRunqty,"999,999,999.99")
 ?  MARGIN+"Net Amount     : " + trans(nRuntot,"999,999,999.99")
 ? 
 ?
 ? MARGIN+padc("********** End of Report **********",nLineLen-17 )  
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
   wWindBuff:=OpenWindow(1,2,maxrow()-1,maxcol()-2,"Slow Moving Item Sales Report")
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



/*=========================================*/
function RSAmt()
/*=========================================*/
local cRef,wWindBuff
local nMaxrow := maxrow()+1, nMaxCol := maxcol()+1
local aFsize := {}
// Gauge variables
local nRecCtr := 0, hGauge, nPercent, nGaugeCtr:=1, wUpdate, dDate
local cName, dFile, code
local lNewPage := 0, nLineCtr := 0, nLinelen  := 86, nPageCtr := 1
local nPagetot := 0, nPageqty := 0, cWindow
local nReccount := 0, nCtr := 1, ccolor, coldpath
local nRuntot := 0, nRunqty := 0, prevsup := space(3)
local sup := space(3), cPname := space(20), nqtydisp := 0
local nRunUCost := 0, nPageUCost := 0
local prevplu:=space(14), prevpludesc:=space(20)
local nPLUqty:=0, nPLUtot:=0,nPLUindx:=1,aPLU:={}

if !Getvalid()
  BUMMER() ; return nil 
endif 

if !Qty2Disp()
   BUMMER() ; return nil 
endif

if netuse("PLU", DB_SHARED, NUM_SECONDS)
    set index to DATEPLU
else
   alert("File 'PLU.DBF' cannot be accessed",{"Quit"})
   return nil    
endif	 

cOldPath := SET(_SET_PATH)

PLU->(dbgotop())
do while PLU->(!EOF())
  if DatesOk(PLU->DATE)

     if prevplu != PLU->CODE .and. !empty(prevplu)
        aadd(aPLU,{prevplu,prevpludesc,nPLUqty,nPLUtot})
        prevplu := PLU->CODE
        prevpludesc := PLU->DESC
        nPLUqty:=0
        nPLUtot:=0
     endif  

     if empty(prevplu)  
        prevplu := PLU->PLU_CODE
        prevpludesc := PLU->DESC
     endif

     if prevplu == PLU->CODE
        nPLUqty += PLU->ICOUNT - PLU->RTN_QTY - PLU->VOID_QTY
        nPLUtot += PLU->IAMOUNT - PLU->RTN_AMT - PLU->VOID_AMT - PLU->DISC_AMT

        prevpludesc := PLU->DEPT
     endif
  
  endif
  PLU->(DbSkip())  
enddo

     if !empty(prevplu)
        aadd(aPLU,{prevplu,prevpludesc,nPLUqty,nPLUtot})
        prevplu := PLU->CODE
        prevpludesc := PLU->DESC
     endif   
ASORT(aPLU,,,{|x,y| x[4]<y[4]})

Message("Preparing Slow Moving Item Sales Report ...")

SET ALTERNATE TO ".\"+REPORTFILE
SET ALTERNATE ON
SET CONSOLE OFF
SET PRINTER OFF

window( 19, 1, 22, 60, CONFIRM_COLOR )

lNewPage := .t.
for nPLUindx:=1 to len(aPLU)

  // Create header if new page  
  if lNewPage  
   // Create header if new page  
   ? MARGIN + "SLOW MOVING ITEM SALES REPORT"
   ?
   ? MARGIN +chr(254)+ SYS_NAME
   ? MARGIN +"Slow Moving Item Sales Report"
   ? MARGIN +"From "+dtoc(dStartDate)+" to "+dtoc(dEndDate)
   ? MARGIN +"As of "+dtoc(date())+", "+time()
   ? MARGIN +"By Amount"
   ?
  	? MARGIN + "BAR  CODE             DESCRIPTION       QUANTITY     NET AMOUNT "
   ? MARGIN + "--------------   --------------------   ----------   --------------"
   //          12345678901234   12345678901234567890   1234567890   12345678901234
   ?

   lNewpage := .f.
   nLineCtr := 13
 endif

?  MARGIN +  aPLU[nPLUindx][1]
??space(2)+ aPLU[nPLUindx][2]
??space(3)+ trans(aPLU[nPLUindx][3],"999,999.99")
??space(3)+ trans(aPLU[nPLUindx][4],"999,999,999.99")
    
   nPageqty += aPLU[nPLUindx][3]
   nPagetot += aPLU[nPLUindx][4]
   nRunqty  += aPLU[nPLUindx][3]
   nRuntot  += aPLU[nPLUindx][4]
   nLineCtr+=1
   nQtyDisp+=1
    if nLineCtr >= MAX_LINE 
    ?
    ? MARGIN+repl("-",nLineLen-17)
    ? MARGIN+"Page Total    : " + space(24-3) +;
            space(2) +  trans(nPageqty,"999,999.99") +;
            space(3) +  trans(nPagetot,"999,999,999.99")
    ?  MARGIN+"Running Total : " +  space(24-3) +;
            space(2) +  trans(nRunqty,"999,999.99") +;
            space(3) +  trans(nRuntot,"999,999,999.99")

    ? MARGIN + padl("Page # "+alltrim(trans(nPageCtr++,"9,999")),nLineLen-17)		  
    ? MARGIN+repl("-",nLineLen-17)
    ?
   // Reset page counter
     nPageqty := 0
     nPagetot := 0

     lNewPage := .t.
    // eject
    ? chr(12)
  endif
  if nQtyDisp == nLimit
     exit
   endif             
 
next


  if lNewPage  
   ? MARGIN + "SLOW MOVING ITEM SALES REPORT"
   ?
   ? MARGIN +chr(254)+ SYS_NAME
   ? MARGIN +"Slow Moving Item Sales Report"
   ? MARGIN +"From "+dtoc(dStartDate)+" to "+dtoc(dEndDate)
   ? MARGIN +"As of "+dtoc(date())+", "+time()
   ? MARGIN +"By Amount"
   ?
   ?
   ? MARGIN + "BAR  CODE             DESCRIPTION       QUANTITY     NET AMOUNT "
   ? MARGIN + "--------------   --------------------   ----------   --------------"
   //          12345678901234   12345678901234567890   1234567890   12345678901234
   ?
 endif

 ? MARGIN+repl("-",nLineLen-17)
 ? MARGIN+"Page Total    : " + space(24-3) +;
            space(2) +  trans(nPageqty,"999,999.99") +;
            space(3) +  trans(nPagetot,"999,999,999.99")
 ?  MARGIN+"Running Total : " +  space(24-3) +;
            space(2) +  trans(nRunqty,"999,999.99") +;
            space(3) +  trans(nRuntot,"999,999,999.99")
            
 ? MARGIN + padl("Page # "+alltrim(trans(nPageCtr++,"9,999"))+ " - Last Page",nLineLen-17)
 ? MARGIN+repl("-",nLineLen-17)
 ?
 ?  
 ?  MARGIN+"Net Quantity   : " + trans(nRunqty,"999,999,999.99")
 ?  MARGIN+"Net Amount     : " + trans(nRuntot,"999,999,999.99")
 ? 
 ?
 ? MARGIN+padc("********** End of Report **********",nLineLen-17 )  
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
   wWindBuff:=OpenWindow(1,2,maxrow()-1,maxcol()-2,"Slow Moving Item Sales Report")
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

