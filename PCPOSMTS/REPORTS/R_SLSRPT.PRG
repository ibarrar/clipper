#include "janus.ch"
#include "inkey.ch"
#include "setcurs.ch"
#include "memoedit.ch"
#include "fileio.ch"
#include "directry.ch"
#include "its.ch"

#define A_DEPT_CODE	1
#define A_DEPT_DESC 2
#define A_PLU_CODE	3
#define A_PLU_DESC	4
#define A_PLU_QTY	5
#define A_PLU_PRIC	6
#define A_PLU_AMT	7
#define A_RTN_QTY	8
#define A_RTN_AMT	9
#define A_VOID_QTY	10
#define A_VOID_AMT	11 
#define A_DISC_AMT	12
#define A_PLU_COST	13

#ifdef MARGIN
 #undef MARGIN
#endif

#define MARGIN      Space(1) 
#define REPORTFILE  "D_SLSRPT.PRN"
#define MAX_SIZE    65535
#define MAX_LINE    50    
#define EJECT_FROM_FILE
#define DEBUG
#define THIS_WIDTH (85 + PLU_CODE_LEN + PLU_DESC_LEN +PLU_CODE_LEN ) + LEFT_MARGIN


memvar n,dStartDate,dEndDate,nLimit,GetList,cReport
static cStartDept,cEndDept
/**************************************************/
* 
*  RCI 		   initial version
*  10/17/98
/**************************************************/
function r_slsrpt()
local wWindow,i,wWindBuff,n
local nMaxrow := maxrow()+1, nMaxCol := maxcol()+1
local cPLU_Dept,nPLU_Pric,cDEP_Desc
local lNewPage := .t.
local nLineCtr := 0
local nLinelen := 194, nPageCtr := 1
local nPLUnettot := 0, nPLUnetqty := 0 ,nPLUprofit := 0
local cPLU_Desc := ""
local prevdept
local aPLU_ := {}
local aPage_ := {}
local aRunt_ := {}
local aDept_ := {}
local aFsize := {}

 if !GetValid()
    BUMMER()
    return nil
 endif

 if !GetDept()
    BUMMER()
    return nil
 endif

 if netuse("DP", DB_SHARED, NUM_SECONDS)
    set index to DP_001
 endif

 if netuse("ITEM.DBF", DB_SHARED, NUM_SECONDS)
    set index to I_001,I_033
 endif
    
 if netuse("PLU", DB_SHARED, NUM_SECONDS)
    set index to DATEPLU
 endif
    
 Message("Preparing Daily Sales Report...")

 wWindow:= savescreen(19,1,22,60)
 window( 19, 1, 22, 60, CONFIRM_COLOR)

 while PLU->(!Eof())  
   @ 1,1 wsay " Creating " + "Daily Sales Report" + " Please wait..."
   
   if ITEM->(DbSeek(PLU->CODE))
	 nPLU_Pric := ITEM->I_003
	 cPLU_Dept := padl(ITEM->I_006,4,"0")
	 cPLU_Desc := ITEM->I_002
      if DP->(DbSeek(ITEM->I_006))
	    @ 2,1 wsay " Dept Code: " + DP->DP_002 + "   "
	    cDEP_Desc := DP->DP_002
	 else
	    cDEP_Desc := repl("?",25)
	 endif
   else

	// Check again by searching the stock code...

	ITEM->(DbSetOrder(2))
	if ITEM->(DbSeek("00"+substr(PLU->CODE,3,12)))
        nPLU_Pric := ITEM->I_003
        cPLU_Dept := padl(ITEM->I_006,4,"0")
        cPLU_Desc := ITEM->I_002
        if DP->(DbSeek(ITEM->I_006))
           @ 2,1 wsay " Dept Code: " + DP->DP_002 + "   "
           cDEP_Desc := DP->DP_002
        else
           cDEP_Desc := repl("?",25)
        endif		 
     else
       cPLU_Dept := "XXXX"
	  cPLU_Desc := padr(alltrim(PLU->DESC),20,"?")
	  nPLU_Pric := (PLU->IAMOUNT  / PLU->ICOUNT)
	  cDEP_Desc := repl("?",25)
	endif
	ITEM->(DbSetOrder(1))
   endif

   if cPLU_Dept == "XXXX" .or. ( val(cPLU_Dept) >= val(cStartDept) .and. ;
                                 val(cPLU_Dept) <= val(cEndDept) )
      if DatesOk(PLU->DATE)
      	 if ( ( n := aScan( aPLU_, { |x| x[A_PLU_CODE] == PLU->CODE }) ) == 0 )
	   aAdd(aPLU_, { cPLU_Dept,;
	                 cDEP_Desc,;
	                 PLU->CODE,;
	                 cPLU_Desc,;
				  PLU->ICOUNT,;
				  nPLU_Pric,;
				  PLU->IAMOUNT,;
				  PLU->RTN_QTY,;
				  PLU->RTN_AMT,;
				  PLU->VOID_QTY,;
				  PLU->VOID_AMT,;
				  PLU->DISC_AMT,;
				  PLU->I_UCOST } )
         else
	   aPLU_[n,A_PLU_QTY] += PLU->ICOUNT
	   aPLU_[n,A_PLU_AMT] += PLU->IAMOUNT
	   aPLU_[n,A_RTN_QTY] += PLU->RTN_QTY
	   aPLU_[n,A_RTN_AMT] += PLU->RTN_AMT
	   aPLU_[n,A_VOID_QTY] += PLU->VOID_QTY
	   aPLU_[n,A_VOID_AMT] += PLU->VOID_AMT
	   aPLU_[n,A_DISC_AMT] += PLU->DISC_AMT
	 endif				  
      endif	  	    
   endif

   PLU->(DBSkip())
 enddo   	 

 SET ALTERNATE TO ".\"+REPORTFILE
 SET ALTERNATE ON 
 SET CONSOLE OFF
 SET PRINTER OFF

 lNewPage := .t.
 prevdept := ""

 aSize(aPage_,13) ; aFill(aPage_,0)
 aSize(aRunt_,13) ; aFill(aRunt_,0)
 aSize(aDept_,13) ; aFill(aDept_,0)

 // Sort by department + code
 @ 2,1 wsay " Please wait... Sorting report !!!         "
 aSort(aPLU_,,,{|x,y| x[A_DEPT_CODE]+x[A_PLU_CODE] < y[A_DEPT_CODE]+y[A_PLU_CODE]})

 for i := 1 to len(aPLU_)

  // Create header if new page  
  if lNewPage  
   // Create header if new page  
   ? MARGIN + "DAILY SALES REPORT"
   ?
   ? MARGIN +chr(254)+ SYS_NAME
   ? MARGIN +"Daily Sales Report"
   ? MARGIN +"From "+dtoc(dStartDate)+" to "+dtoc(dEndDate)
   ? MARGIN +"As of "+dtoc(date())+", "+time()
   ?
   ?

   ? MARGIN + REPL("-",nLineLen) 
   ? MARGIN + SPACE(36) + PADL("SALES",13)
   ?? SPACE(1) + PADL("SRP",9) 
   ?? SPACE(1) + PADL("SALES",13)
   ?? SPACE(1) + PADL("RETURN",13) 
   ?? SPACE(1) + PADL("RETURN",13) 
   ?? SPACE(1) + PADL("VOID",13) 
   ?? SPACE(1) + PADL("VOID",13) 
   ?? SPACE(1) + PADL("DISCOUNT",10) 
   ?? SPACE(1) + PADL("NET SALES",13) 
   ?? SPACE(1) + PADL("NET SALES",13)
   ?? SPACE(1) + PADL("ITEM",9) 
   ?? SPACE(1) + PADL("PROFIT",13)
   ?  MARGIN   + SPACE(36) + PADL("QTY",13) 
   ?? SPACE(1+9+1)+ PADL("AMT",13) 
   ?? SPACE(1) + PADL("QTY",13) 
   ?? SPACE(1) + PADL("AMT",13) 
   ?? SPACE(1) + PADL("QTY",13) 
   ?? SPACE(1) + PADL("AMT",13) 
   ?? SPACE(1) + PADL("AMT",10) 
   ?? SPACE(1) + PADL("AMT",13) 
   ?? SPACE(1) + PADL("QTY",13) 
   ?? SPACE(1) + PADL("COST",9)

   ? MARGIN + REPL("-",nLineLen) 
   ?
   ?
   lNewpage := .f.
   nLineCtr := 13
  endif   

   if prevdept != aPLU_[i,A_DEPT_CODE]
       
       if !empty(prevdept)
         nPLUnettot := aDept_[A_PLU_QTY] - aDept_[A_RTN_QTY] - aDept_[A_VOID_QTY] 
         nPLUnettot := aDept_[A_PLU_AMT] - aDept_[A_RTN_AMT] - aDept_[A_VOID_AMT] - aDept_[A_DISC_AMT]
         nPLUprofit := (aDept_[A_PLU_PRIC] - aDept_[A_PLU_COST]) * ;
                       (aDept_[A_PLU_QTY] - aDept_[A_RTN_QTY] - aDept_[A_VOID_QTY])	  
         ? MARGIN+repl("-",nLineLen)
         ? MARGIN+padr("Dept Total    : ",36) + ;
                     trans(aDept_[A_PLU_QTY],"99,999,999.99") + ;
         space(11) + trans(aDept_[A_PLU_AMT],"99,999,999.99") +;
         space(1) + trans(aDept_[A_RTN_QTY],"99,999,999.99") + ;
         space(1) + trans(aDept_[A_RTN_AMT],"99,999,999.99") + ;
         space(1) + trans(aDept_[A_VOID_QTY],"99,999,999.99") +;
         space(1) + trans(aDept_[A_VOID_AMT],"99,999,999.99") +;
         space(1) + trans(aDept_[A_DISC_AMT],"999,999.99") +;
         space(1) + trans(nPLUnettot,"99,999,999.99") +;
         space(1) + trans(nPLUnetqty,"99,999,999.99") +;
         space(11)+ trans(nPLUprofit,"99,999,999.99")

         ? MARGIN+repl("-",nLineLen)
         ?
         aFill(aDept_,0)
         nLineCtr += 4
       endif 
       ? MARGIN + "DEPT. " + aPLU_[i,A_DEPT_CODE]
       ?? space(2) + aPLU_[i,A_DEPT_DESC]
	  prevdept := aPLU_[i,A_DEPT_CODE]
       nLineCtr += 1
   endif      

   ? MARGIN + aPLU_[i,A_PLU_CODE]
   ?? space(1) + aPLU_[i,A_PLU_DESC]

   ?? space(1) + trans(aPLU_[i,A_PLU_QTY] ,"99,999,999.99")
   ?? space(1) + trans(aPLU_[i,A_PLU_PRIC],"99,999.99")
   ?? space(1) + trans(aPLU_[i,A_PLU_AMT] ,"99,999,999.99")
   ?? space(1) + trans(aPLU_[i,A_RTN_QTY] ,"99,999,999.99")
   ?? space(1) + trans(aPLU_[i,A_RTN_AMT] ,"99,999,999.99")
   ?? space(1) + trans(aPLU_[i,A_VOID_QTY],"99,999,999.99")
   ?? space(1) + trans(aPLU_[i,A_VOID_AMT],"99,999,999.99")
   ?? space(1) + trans(aPLU_[i,A_DISC_AMT],"999,999.99")

   nPLUnetqty := aPLU_[i,A_PLU_QTY] - aPLU_[i,A_RTN_QTY] - aPLU_[i,A_VOID_QTY] 
   nPLUnettot := aPLU_[i,A_PLU_AMT] - aPLU_[i,A_RTN_AMT] - aPLU_[i,A_VOID_AMT] - aPLU_[i,A_DISC_AMT]
   nPLUprofit := (aPLU_[i,A_PLU_PRIC] - aPLU_[i,A_PLU_COST]) * ;
   			  (aPLU_[i,A_PLU_QTY] - aPLU_[i,A_RTN_QTY] - aPLU_[i,A_VOID_QTY])

   ?? space(1) + trans(nPLUnettot,"99,999,999.99")
   ?? space(1) + trans(nPLUnetqty,"99,999,999.99")
   ?? space(1) + trans(aPLU_[i,A_PLU_COST],"99,999.99")

   ?? space(1) + trans(nPLUprofit,"99,999,999.99")

	 aPage_[A_PLU_QTY] += aPLU_[i,A_PLU_QTY]
	 aPage_[A_PLU_AMT] += aPLU_[i,A_PLU_AMT]
	 aPage_[A_RTN_QTY] += aPLU_[i,A_RTN_QTY]
	 aPage_[A_RTN_AMT] += aPLU_[i,A_RTN_AMT]
	 aPage_[A_VOID_QTY] += aPLU_[i,A_VOID_QTY]
	 aPage_[A_VOID_AMT] += aPLU_[i,A_VOID_AMT]
	 aPage_[A_DISC_AMT] += aPLU_[i,A_DISC_AMT]
	 aPage_[A_PLU_COST] += aPLU_[i,A_PLU_COST]

	 aRunt_[A_PLU_QTY] += aPLU_[i,A_PLU_QTY]
	 aRunt_[A_PLU_AMT] += aPLU_[i,A_PLU_AMT]
	 aRunt_[A_RTN_QTY] += aPLU_[i,A_RTN_QTY]
	 aRunt_[A_RTN_AMT] += aPLU_[i,A_RTN_AMT]
	 aRunt_[A_VOID_QTY] += aPLU_[i,A_VOID_QTY]
	 aRunt_[A_VOID_AMT] += aPLU_[i,A_VOID_AMT]
	 aRunt_[A_DISC_AMT] += aPLU_[i,A_DISC_AMT]
	 aRunt_[A_PLU_COST] += aPLU_[i,A_PLU_COST]

	 aDept_[A_PLU_QTY] += aPLU_[i,A_PLU_QTY]
	 aDept_[A_PLU_AMT] += aPLU_[i,A_PLU_AMT]
	 aDept_[A_RTN_QTY] += aPLU_[i,A_RTN_QTY]
	 aDept_[A_RTN_AMT] += aPLU_[i,A_RTN_AMT]
	 aDept_[A_VOID_QTY] += aPLU_[i,A_VOID_QTY]
	 aDept_[A_VOID_AMT] += aPLU_[i,A_VOID_AMT]
	 aDept_[A_DISC_AMT] += aPLU_[i,A_DISC_AMT]
	 aDept_[A_PLU_COST] += aPLU_[i,A_PLU_COST]
	 	 
      nLineCtr += 1

      if !empty(prevdept) .and. len(aPLU_) == i
         nPLUnettot := aDept_[A_PLU_QTY] - aDept_[A_RTN_QTY] - aDept_[A_VOID_QTY] 
         nPLUnettot := aDept_[A_PLU_AMT] - aDept_[A_RTN_AMT] - aDept_[A_VOID_AMT] - aDept_[A_DISC_AMT]
         nPLUprofit := (aDept_[A_PLU_PRIC] - aDept_[A_PLU_COST]) * ;
                       (aDept_[A_PLU_QTY] - aDept_[A_RTN_QTY] - aDept_[A_VOID_QTY])	  
         ? MARGIN+repl("-",nLineLen)
         ? MARGIN+padr("Dept Total    : ",36) + ;
                     trans(aDept_[A_PLU_QTY],"99,999,999.99") + ;
         space(11) + trans(aDept_[A_PLU_AMT],"99,999,999.99") +;
         space(1) + trans(aDept_[A_RTN_QTY],"99,999,999.99") + ;
         space(1) + trans(aDept_[A_RTN_AMT],"99,999,999.99") + ;
         space(1) + trans(aDept_[A_VOID_QTY],"99,999,999.99") +;
         space(1) + trans(aDept_[A_VOID_AMT],"99,999,999.99") +;
         space(1) + trans(aDept_[A_DISC_AMT],"999,999.99") +;
         space(1) + trans(nPLUnettot,"99,999,999.99") +;
         space(1) + trans(nPLUnetqty,"99,999,999.99") +;
         space(11)+ trans(nPLUprofit,"99,999,999.99")

         ? MARGIN+repl("-",nLineLen)
         ?
         aFill(aDept_,0)
         nLineCtr += 4
       endif 

	 // check if footer is needed, eject
      // reset counters
      if nLineCtr >= MAX_LINE  .or. len(aPLU_) == i // if last 
	    nPLUnetqty := aPage_[A_PLU_QTY] - aPage_[A_RTN_QTY] - aPage_[A_VOID_QTY] 
	    nPLUnettot := aPage_[A_PLU_AMT] - aPage_[A_RTN_AMT] - aPage_[A_VOID_AMT] - aPage_[A_DISC_AMT]
	    nPLUprofit := (aPage_[A_PLU_PRIC] - aPage_[A_PLU_COST]) * ;
   			  (aPage_[A_PLU_QTY] - aPage_[A_RTN_QTY] - aPage_[A_VOID_QTY])
	 
         ? MARGIN+repl("-",nLineLen)
         ?  MARGIN+PADR("Page Total    : ",36) + ;
	                  trans(aPage_[A_PLU_QTY],"99,999,999.99") + ;
           space(11) + trans(aPage_[A_PLU_AMT],"99,999,999.99") + ;
		 space(1) + trans(aPage_[A_RTN_QTY],"99,999,999.99") + ;
		 space(1) + trans(aPage_[A_RTN_AMT],"99,999,999.99") + ;
           space(1) + trans(aPage_[A_VOID_QTY],"99,999,999.99") + ;
		 space(1) + trans(aPage_[A_VOID_AMT],"99,999,999.99") + ;
		 space(1) + trans(aPage_[A_DISC_AMT],"999,999.99") + ;
           space(1) + trans(nPLUnettot,"99,999,999.99") + ;
		 space(1) + trans(nPLUnetqty,"99,999,999.99") + ;
           space(11)+ trans(nPLUprofit,"99,999,999.99")

		 nPLUnetqty := aRunt_[A_PLU_QTY] - aRunt_[A_RTN_QTY] - aRunt_[A_VOID_QTY] 
		 nPLUnettot := aRunt_[A_PLU_AMT] - aRunt_[A_RTN_AMT] - aRunt_[A_VOID_AMT] - aRunt_[A_DISC_AMT]
		 nPLUprofit := (aRunt_[A_PLU_PRIC] - aRunt_[A_PLU_COST]) * ;
   			  (aRunt_[A_PLU_QTY] - aRunt_[A_RTN_QTY] - aRunt_[A_VOID_QTY])
		 
 
         ? MARGIN+padr("Running Total : ",36) + ;
	                  trans(aRunt_[A_PLU_QTY],"99,999,999.99") + ;
           space(11) + trans(aRunt_[A_PLU_AMT],"99,999,999.99") + ;
		 space(1) + trans(aRunt_[A_RTN_QTY],"99,999,999.99") + ;
		 space(1) + trans(aRunt_[A_RTN_AMT],"99,999,999.99") + ;
           space(1) + trans(aRunt_[A_VOID_QTY],"99,999,999.99") + ;
		 space(1) + trans(aRunt_[A_VOID_AMT],"99,999,999.99") + ;
		 space(1) + trans(aRunt_[A_DISC_AMT],"999,999.99") + ;
           space(1) + trans(nPLUnettot,"99,999,999.99") + ;		 
		 space(1) + trans(nPLUnetqty,"99,999,999.99") + ;
           space(11)+ trans(nPLUprofit,"99,999,999.99")

         ? MARGIN+repl("-",nLineLen)
         ?
         // Reset page counter
		aFill(aPage_,0)
       
        lNewPage := .t.
        // eject only if not last
	   if len(aPLU_) != i
           ? chr(12)
	   endif	 
      endif


 next

 
 ?  
 ?  MARGIN+"Net Sales Amount     : " + trans(nPLUnetqty,"999,999,999.99")
 ?  MARGIN+"Net Sales Qty        : " + trans(nPLUnettot,"999,999,999.99")
 ?  MARGIN+"Profit               : " + trans(nPLUprofit,"999,999,999.99")
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
    wWindBuff:=OpenWindow(1,2,maxrow()-1,maxcol()-2,"Daily Sales Report")
    MemoEdit(cReport,2,3,maxrow()-2,maxcol()-3,.f.,'Editor4Func',230 )
    CloseWindow(wWindBuff)
    setcursor(SC_NONE)
    setmode(nMaxrow,nMaxcol)
   endif
 
 else

  if alert("Report too large to edit, will be directed to printer", {"Print","Quit"}) == 1 
     Direct2Prn(REPORTFILE) 
  endif  
 
 endif  


 restscreen(19,1,22,60,wWindow)
 cReport := "" //Free Memory

 DbCloseAll()
return nil

 
static function GetDept()
local wValid
cStartDept:=cEndDept:=space(4)
    Message("Enter Department Codes to cover reports")
    wValid := OpenWindow(09,12,15,66,"Printing Validation Box")
    @ 10,12 to 15,66 double    
      @ 12,17 say "From Dept. Code" get cStartDept pict "99" valid !empty(cStartDept)
      @ 13,17 say "  To Dept. Code" get cEndDept pict "99" valid !empty(cEndDept)
      SetCursor(SC_NORMAL)
      HeyThere()
      read
      SetCursor(SC_NONE)
    CloseWindow(wValid)
  cStartDept:=padl(alltrim(cStartDept),4,"0")
  cEndDept:=padl(alltrim(cEndDept),4,"0")
return if(LastKey()==K_ESC,.F.,.T.)
