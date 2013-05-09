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
#define REPORTFILE  "SUPP.PRN"
#define MAX_SIZE    65535
#define MAX_LINE    50    
#define EJECT_FROM_FILE
#define DEBUG
#define THIS_WIDTH (85 + PLU_CODE_LEN + PLU_DESC_LEN +PLU_CODE_LEN ) + LEFT_MARGIN
 
memvar n,dStartDate,dEndDate,nLimit,cReport
//static cReport
memvar GetList

/*=========================================*/
function RSupplier()
/*=========================================*/
local cRef,wWindBuff
local nMaxrow := maxrow()+1, nMaxCol := maxcol()+1
local aFsize := {}
// Gauge variables
local nRecCtr := 0, hGauge, nPercent, nGaugeCtr:=1, wUpdate, dDate
local cName := space(20), dFile, code
local lNewPage := 0, nLineCtr := 0, nLinelen  := 67, nPageCtr := 1
local nPageslstot := 0, nPageslsqty := 0, cWindow
local nReccount := 0, nCtr := 1, ccolor, coldpath
local nRunslstot := 0, nRunslsqty := 0, count := 0, amount := 0
local cPname := space(20), sup := space(3), prevsup := space(3)
local lFirst := .f.

if !Getvalid()
  BUMMER() ; return nil 
endif 

if netuse("V", DB_SHARED, NUM_SECONDS)
    set index to V_001
else
   alert("File 'V.DBF' cannot be accessed",{"Quit"})
   return nil    
endif	 

if netuse("ITEM.DBF", DB_SHARED, NUM_SECONDS)
  set index to I_001
else
   alert("File 'ITEM.DBF' cannot be accessed",{"Quit"})
   DbCloseAll()
   return nil
endif

if netuse("PLUTEMP", DB_EXCLUSIVE, NUM_SECONDS)
   PLUTEMP->(__dbzap())
endif	 

cOldPath := SET(_SET_PATH)

Message("Preparing Supplier Sales Summary Report ...")


SET ALTERNATE TO ".\"+REPORTFILE
SET ALTERNATE ON
SET CONSOLE OFF
SET PRINTER OFF

window( 19, 1, 22, 60, CONFIRM_COLOR )

 Plu_Con()  // conslidate to PLUTEMP
 PLUTEMP->(Dbgotop())
 
lNewPage := .t.
lFirst := .t.

Do While PLUTEMP->(!Eof())  

  // Create header if new page  
  if lNewPage  
   // Create header if new page  
   ? MARGIN + "SUPPLIER SALES SUMMARY REPORT"
   ?
   ? MARGIN +chr(254)+ SYS_NAME
   ? MARGIN +"Supplier Sales Report"
   ? MARGIN +"From "+dtoc(dStartDate)+" to "+dtoc(dEndDate)
   ? MARGIN +"As of "+dtoc(date())+", "+time()
   ?
   ?
   ?
   ? MARGIN + "CODE       DESCRIPTION                  QUANTITY     AMOUNT SOLD"
   ? MARGIN + "----   ------------------------------   ----------   --------------"
   //          123    123456789012345678901234567890   1234567890   12345678901234
   ?
   ?

   lNewpage := .f.
   nLineCtr := 13
  endif   
 
      sup := substr(PLUTEMP->code,1,3)
      if lfirst
       prevsup := sup
       lfirst := .f.
      endif

   if sup != prevsup
     if V->(DbSeek(prevsup))
       cName := V->V_002
     else
       cName := "** Supplier  Code Not Found **"   
     endif  
     if sup != space(3)
      ? MARGIN + prevsup
      ?? space(4) + cName
      ?? space(3) + tran(count,"999,999.99")
      ?? space(2) + tran(amount,"999,999,999.99")
      nLineCtr += 1
      prevsup := sup
      count := PLUTEMP->ICOUNT
      amount := PLUTEMP->IAMOUNT

      PLUTEMP->(Dbskip())
      if PLUTEMP->(Eof())
      ? MARGIN + prevsup
      ?? space(4) + cName
      ?? space(3) + tran(count,"999,999.99")
      ?? space(2) + tran(amount,"999,999,999.99")
      nLineCtr += 1
      else
      PLUTEMP->(Dbskip(-1))
      endif

     else 
      ? MARGIN + prevsup
      ?? space(4) + cName
      ?? space(3) + tran(PLUTEMP->ICOUNT,"999,999.99")
      ?? space(2) + tran(PLUTEMP->IAMOUNT,"999,999,999.99")
      nLineCtr += 1
      prevsup := sup
      count := 0
      amount := 0
     endif
   else   
      if prevsup == space(3)
       ? MARGIN + prevsup
       ?? space(4) + "** Code Not Found **"   
       ?? space(3) + tran(PLUTEMP->ICOUNT,"999,999.99")
       ?? space(2) + tran(PLUTEMP->IAMOUNT,"999,999,999.99")
       nLineCtr += 1
      endif

      count += PLUTEMP->ICOUNT
      amount += PLUTEMP->IAMOUNT
      
   endif

   nPageslsqty += PLUTEMP->ICOUNT
      nPageslstot += PLUTEMP->IAMOUNT
      nRunslsqty += PLUTEMP->ICOUNT
      nRunslstot += PLUTEMP->IAMOUNT
   
  // check if footer is needed, eject
  // reset counters
  if nLineCtr >= MAX_LINE 
    ?
	 ? MARGIN+repl("-",nLineLen)
    ? MARGIN+"Page Total    : " + space(12) + trans(nPageslsqty,"9,999,999.99") +;
            space(2) +  trans(nPageslstot,"999,999,999.99")
    ?  MARGIN+"Running Total : " + space(12) + trans(nRunslsqty,"9,999,999.99") +;
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

 PLUTEMP->(DbSkip())
enddo  

  if lNewPage  
   // Create header if new page  
   ? MARGIN + "SUPPLIER SALES SUMMARY REPORT"
   ?
   ? MARGIN +chr(254)+ SYS_NAME
   ? MARGIN +"Supplier Sales Report"
   ? MARGIN +"From "+dtoc(dStartDate)+" to "+dtoc(dEndDate)
   ? MARGIN +"As of "+dtoc(date())+", "+time()
   ?
   ?
   ?
   ? MARGIN + "CODE       DESCRIPTION        QUANTITY     AMOUNT SOLD"
   ? MARGIN + "----   --------------------   ----------   --------------"
   //          123    12345678901234567890   1234567890   12345678901234
   ?
   ?
 endif   


 ?
 ? MARGIN+repl("-",nLineLen)
 ?  MARGIN+"Page Total    : " + space(12) + trans(nPageslsqty,"9,999,999.99") +;
              space(2) + trans(nPageslstot,"999,999,999.99") 
 ?  MARGIN+"Running Total : " + space(12) + trans(nRunslsqty,"9,999,999.99") +;
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
   wWindBuff:=OpenWindow(1,2,maxrow()-1,maxcol()-2,"Supplier Sales Summary Report")
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

function Plu_Con()
local code

  if netuse("PLU", DB_SHARED, NUM_SECONDS)
     set index to PLU
  else
     alert("File 'PLU.DBF' cannot be accessed",{"Quit"})
     DbCloseAll()
     return nil    
  endif	 

  if netuse("NPLU", DB_SHARED, NUM_SECONDS)
     set index to NPLU
  else
     alert("File 'NPLU.DBF' cannot be accessed",{"Quit"})
     DbCloseAll()
     return nil    
  endif	 

  PLU->(Dbgotop())
  NPLU->(Dbgotop())

  while PLU->(!eof())

  @ 1, 1 wsay " Creating " + "Supplier Sales Summary Report" + "  Please wait ..."
  @ 2, 1 wsay " Item Code: " + PLU->CODE + "    "

    if datesok(PLU->DATE)
       PLUTEMP->(Dbappend())
       PLUTEMP->DATE := PLU->DATE
       PLUTEMP->CODE := PLU->CODE
       PLUTEMP->DESC := PLU->DESC
       PLUTEMP->ICOUNT := PLU->ICOUNT
       PLUTEMP->IAMOUNT := PLU->IAMOUNT
       PLUTEMP->I_UCOST := PLU->I_UCOST
       PLUTEMP->OP_FLAG := PLU->OP_FLAG
    endif
    PLU->(Dbskip())   

  enddo
  PLUTEMP->(Dbcommit())

  while NPLU->(!eof())

  @ 1, 1 wsay " Creating " + "Supplier Sales Summary Report" + "  Please wait ..."
  @ 2, 1 wsay " Item Code: " + NPLU->CODE + "    "

    if datesok(NPLU->DATE)
       PLUTEMP->(Dbappend())
       PLUTEMP->DATE := NPLU->DATE
       PLUTEMP->CODE := NPLU->CODE
       PLUTEMP->DESC := "Not Found!"
       PLUTEMP->ICOUNT := NPLU->ICOUNT
       PLUTEMP->IAMOUNT := NPLU->IAMOUNT
       PLUTEMP->I_UCOST := NPLU->I_UCOST
       PLUTEMP->OP_FLAG := NPLU->OP_FLAG
    endif
    NPLU->(Dbskip())   
  enddo
  PLUTEMP->(Dbcommit())

  PLU->(DbcloseArea())
  NPLU->(DbcloseArea())

return nil
//.jlp.03.07.98....