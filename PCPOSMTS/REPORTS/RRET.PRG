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
#define REPORTFILE  "RETURN.PRN"
#define MAX_SIZE    65535
#define MAX_LINE    50    
#define EJECT_FROM_FILE
#define DEBUG
#define THIS_WIDTH (85 + PLU_CODE_LEN + PLU_DESC_LEN +PLU_CODE_LEN ) + LEFT_MARGIN
 
memvar n,dStartDate,dEndDate, creport
static nLimit
memvar GetList



/*=========================================*/
function RRET()
/*=========================================*/
local cRef,wWindBuff
local nMaxrow := maxrow()+1, nMaxCol := maxcol()+1
local aFsize := {}
// Gauge variables
local nRecCtr := 0, hGauge, nPercent, nGaugeCtr:=1, wUpdate, dDate
local cName, dFile, code
local lNewPage := 0, nLineCtr := 0, nLinelen  := 93, nPageCtr := 1
local nPageslstot := 0, nPageslsqty := 0, cWindow
local nReccount := 0, nCtr := 1, ccolor, coldpath
local nRunslstot := 0, nRunslsqty := 0, prevsup := space(3)
local sup := space(3), cPname := space(20), nqtydisp := 0
local nRunUCost := 0, nPageUCost := 0

if !Getvalid()
  BUMMER() ; return nil 
endif 


if netuse("RET", DB_SHARED, NUM_SECONDS)
    set index to RET
else
   alert("File 'RET.DBF' cannot be accessed",{"Quit"})
   return nil    
endif	 



cOldPath := SET(_SET_PATH)

Message("Preparing Returns Report ...")


SET ALTERNATE TO ".\"+REPORTFILE
SET ALTERNATE ON
SET CONSOLE OFF
SET PRINTER OFF


window( 19, 1, 22, 60, CONFIRM_COLOR )


 lNewPage := .t.

prevsup := space(3)  
RET->(DbGoTop())
Do While RET->(!Eof())  

  @ 1, 1 wsay " Creating " + "Returns Report" + "  Please wait ..."
  @ 2, 1 wsay " Item Code: " + RET->PLUCODE + "    "

if DatesOk(RET->DATE) .and. RET->(!Deleted())

  // Create header if new page  
  if lNewPage  
   // Create header if new page  
   ? MARGIN + "RETURNS REPORT"
   ?
   ? MARGIN +chr(254)+ SYS_NAME
   ? MARGIN +"Returns Report"
   ? MARGIN +"From "+dtoc(dStartDate)+" to "+dtoc(dEndDate)
   ? MARGIN +"As of "+dtoc(date())+", "+time()
   ?
   ?
  	? MARGIN + "ITEM CODE             DESCRIPTION       DEPT   UNIT COST        QUANTITY     AMOUNT SOLD"
   ? MARGIN + "--------------   --------------------   ----   --------------   ----------   --------------"
   //          12345678901234   12345678901234567890   1234   12345678901234   1234567890   12345678901234
   ?

   lNewpage := .f.
   nLineCtr := 13
 endif
 

   ?  MARGIN + RET->PLUCODE
   ?? space(3) + RET->RDESC
   ?? space(3) + RET->RDEPT
   ?? space(3) + tran(RET->RUCOST,"999,999,999.99")
   ?? space(3) + tran(RET->RCOUNT,"999,999.99")
   ?? space(2) + tran(RET->RAMOUNT,"999,999,999.99")
   nLineCtr += 1
 
    nPageslsqty += RET->RCOUNT
    nPageslstot += RET->RAMOUNT
    nPageUCost += RET->RUCOST
	 nRunslsqty += RET->RCOUNT
    nRunslstot += RET->RAMOUNT
    nRunUCost += RET->RUCOST
   
   
  
  // check if footer is needed, eject
  // reset counters
    if nLineCtr >= MAX_LINE 
    ?
	 ? MARGIN+repl("-",nLineLen)
    ? MARGIN+"Page Total    : " + space(31) + trans(nPageUCost,"999,999,999.99") +;
            space(1) +  trans(nPageslsqty,"9,999,999.99") +;
            space(2) +  trans(nPageslstot,"999,999,999.99")
    ?  MARGIN+"Running Total : " + space(31) + trans(nRunUCost,"999,999,999.99") +;
            space(1) +  trans(nRunslsqty,"9,999,999.99") +;
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
 RET->(DbSkip())
enddo  

  if lNewPage  
   ? MARGIN + "RETURNS REPORT"
   ?
   ? MARGIN +chr(254)+ SYS_NAME
   ? MARGIN +"Returns Report"
   ? MARGIN +"From "+dtoc(dStartDate)+" to "+dtoc(dEndDate)
   ? MARGIN +"As of "+dtoc(date())+", "+time()
   ?
   ?
   ?
   ? MARGIN + "ITEM CODE             DESCRIPTION       DEPT   UNIT COST        QUANTITY     AMOUNT SOLD"
   ? MARGIN + "--------------   --------------------   ----   --------------   ----------   --------------"
   //          12345678901234   12345678901234567890   1234   12345678901234   1234567890   12345678901234
   ?
 endif


 ?
 ? MARGIN+repl("-",nLineLen)
 ? MARGIN+"Page Total    : " + space(31) + trans(nPageUCost,"999,999,999.99") +;
          space(1) +  trans(nPageslsqty,"9,999,999.99") +;
          space(2) +  trans(nPageslstot,"999,999,999.99")
 ?  MARGIN+"Running Total : " +  space(31) + trans(nRunUCost,"999,999,999.99") +;
          space(1) +  trans(nRunslsqty,"9,999,999.99") +;
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
   wWindBuff:=OpenWindow(1,2,maxrow()-1,maxcol()-2,"Returns Report")
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