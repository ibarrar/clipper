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
#define REPORTFILE  "D_SLSRPT.PRN"
#define MAX_SIZE    65535
#define MAX_LINE    50    
#define EJECT_FROM_FILE
#define DEBUG
#define THIS_WIDTH (85 + PLU_CODE_LEN + PLU_DESC_LEN +PLU_CODE_LEN ) + LEFT_MARGIN
 
memvar n,dStartDate,dEndDate,nLimit, GetList, cReport
//static cStartDept,cEndDept

/*=========================================*/
function Dlyslsrpt()
/*=========================================*/
local cRef,wWindBuff
local nMaxrow := maxrow()+1, nMaxCol := maxcol()+1
local aFsize := {}
// Gauge variables
local nRecCtr := 0, hGauge, nPercent, nGaugeCtr:=1, wUpdate, dDate
local cName := space(20), dFile, code
local lNewPage := 0, nLineCtr := 0, nLinelen  := 57+123+24-5+15, nPageCtr := 1
local nPageslstot := 0, nPageslsqty := 0, cWindow
local nReccount := 0, nCtr := 1, ccolor, coldpath
local nRunslstot := 0, nRunslsqty := 0, count := 0, amount := 0
local cPname := space(20),  prevdept := space(4), prevdesc := space(20)
local lFirst := .f., ldate := .t., ncount := 0, namount := 0.00

local nPageretqty := 0, nPagerettot := 0, nPagenetqty := 0
local nPagevoidqty := 0, nPagevoidtot := 0, nPagedisctot := 0, nPagenettot  := 0
local nRunretqty := 0, nRunrettot := 0, nRunnetqty := 0,netqty:=0,prevplucost:=0
local nRunvoidqty := 0, nRunvoidtot := 0, nRundisctot := 0, nRunnettot  := 0
local nDPretqty := 0, nDPrettot := 0, nDPnetqty := 0,itvoidqty:=0,itvoidtot:=0
local nDPvoidqty := 0, nDPvoidtot := 0, nDPdisctot := 0, nDPnettot  := 0
local nDPslsqty:=0, nDPslstot:=0, nRunprofit:=0,nDPprofit:=0
local nPLUretqty := 0, nPLUrettot := 0, nPLUnetqty:=0, nPLUvoidamt:=0
local nPLUvoidqty := 0, nPLUvoidtot := 0, nPLUdisctot := 0, nPLUnettot  := 0
local nPLUslsqty:=0, nPLUslstot:=0, nPLUprofit:=0, nPLUitmcost:=0, nPageprofit:=0


local prevplu:=space(14), prevpludesc:=space(40),prevplusrp:=0,cScr

if !Getvalid()
  BUMMER() ; return nil 
endif 

/*
if !GetDept()
  BUMMER() ; return nil 
endif 
*/
if netuse("DEPT", DB_SHARED, NUM_SECONDS)
    set index to DEPT
else
   alert("File 'DEPT.DBF' cannot be accessed",{"Quit"})
   return nil    
endif	 

if netuse("ITEM.DBF", DB_SHARED, NUM_SECONDS)
    set index to I_001
else
   alert("File 'ITEM.DBF' cannot be accessed",{"Quit"})
   return nil    
endif	 

if netuse("ITM_MOVE", DB_SHARED, NUM_SECONDS)
    set index to ITM_MOVE
else
   alert("File 'ITM_MOVE.DBF' cannot be accessed",{"Quit"})
   return nil    
endif	 

cOldPath := SET(_SET_PATH)

Message("Preparing Daily Sales Report ...")

cScr:=savescreen(19,1,22,60)
SET ALTERNATE TO ".\"+REPORTFILE
SET ALTERNATE ON
SET CONSOLE OFF
SET PRINTER OFF

window( 19, 1, 22, 60, CONFIRM_COLOR )

lNewPage := .t.
lFirst := .t.


Do While ITM_MOVE->(!Eof())
 
  @ 1, 1 wsay " Creating " + "Daily Sales Report" + "  Please wait ..."
  @ 2, 1 wsay " Dept Code: " + ITM_MOVE->DEPT_CODE + "    "

//if ( val(itm_move->dept_code) >= val(cStartDept) .and. val(itm_move->dept_code) <= val(cEndDept) )

 if DatesOk(ITM_MOVE->DATE) 

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

   ?MARGIN + SPACE(14+1+40+1) + PADL("SALES",13)
   ?? SPACE(1) + PADL("SRP",9) 
   ?? SPACE(1) + PADL("SALES",13)
   ?? SPACE(1) + PADL("RETURN",13) 
   ?? SPACE(1) + PADL("RETURN",13) 
   ?? SPACE(1) + PADL("VOID",13) 
   ?? SPACE(1) + PADL("VOID",13) 
   ?? SPACE(1) + PADL("DISCOUNT",10) 
   ?? SPACE(1) + PADR("NET SALES",13) 
   ?? SPACE(1) + PADL("NET SALES",13)
   ?? SPACE(1) + PADL("ITEM",9) 
   ?? SPACE(1) + PADL("PROFIT",13)
   ?  MARGIN   + SPACE(56) + PADL("QTY",13) 
   ?? SPACE(1+9+1)+ PADL("AMT",13) 
   ?? SPACE(1) + PADL("QTY",13) 
   ?? SPACE(1) + PADL("AMT",13) 
   ?? SPACE(1) + PADL("QTY",13) 
   ?? SPACE(1) + PADL("AMT",13) 
   ?? SPACE(1) + PADL("AMT",10) 
   ?? SPACE(1) + PADR("AMT",13) 
   ?? SPACE(1) + PADL("QTY",13) 
   ?? SPACE(1) + PADL("COST",9)

   ? MARGIN + REPL("-",nLineLen) 
   ?
   ?
   lNewpage := .f.
   nLineCtr := 13
  endif   

   if !empty(prevdept) .and. prevdept!=ITM_MOVE->DEPT_CODE

      if nPLUslsqty+nPLUretqty+nPLUvoidqty > 0    // zero skip...
      
      ? MARGIN + prevplu
      ITEM->(DBSEEK(ITM_MOVE->PLU_CODE))
      ?? space(1) + prevpludesc

      ?? space(1) + trans(nPLUslsqty,"99,999,999.99")
      ?? space(1) + trans(prevplusrp,"99,999.99")
      ?? space(1) + trans(nPLUslstot,"99,999,999.99")
      ?? space(1) + trans(nPLUretqty,"99,999,999.99")
      ?? space(1) + trans(nPLUrettot,"99,999,999.99")
      ?? space(1) + trans(nPLUvoidqty,"99,999,999.99")
      ?? space(1) + trans(nPLUvoidtot,"99,999,999.99")

//      ?? space(2) + trans(nPLUdisctot,"9,999,999.99")
      ?? space(1) + trans(nPLUdisctot,"999,999.99")

      ?? space(1) + trans(nPLUnettot,"99,999,999.99")
      ?? space(1) + trans(nPLUnetqty,"99,999,999.99")
      ?? space(1) + trans(nPLUitmcost,"99,999.99")

      ?? space(1) + trans(nPLUprofit,"99,999,999.99")

      endif
      
      nPageslsqty += nPLUslsqty
      nPageslstot += nPLUslstot
      nRunslsqty += nPLUslsqty
      nRunslstot += nPLUslstot
      
      nPageretqty += nPLUretqty
      nPagerettot += nPLUrettot
      nRunretqty += nPLUretqty
      nRunrettot += nPLUrettot      

      nPagevoidqty += nPLUvoidqty
      nPagevoidtot += nPLUvoidtot
      nRunvoidqty += nPLUvoidqty
      nRunvoidtot += nPLUvoidtot
            
      nPagedisctot += val(trans(nPLUdisctot,"99999999.99"))
      nRundisctot +=  val(trans(nPLUdisctot,"99999999.99"))
      
      nPagenettot  += nPLUnettot
      nPagenetqty += nPLUnetqty
      nRunnettot  += nPLUnettot
      nRunnetqty += nPLUnetqty      

      nPageprofit  += nPLUprofit
      nRunprofit  += nPLUprofit
            

      nDPnettot += nPLUnettot
      nDPnetqty += nPLUnetqty
      nDPprofit += nPLUprofit


      nPLUslsqty := 0
      nPLUslstot := 0
      nPLUretqty := 0
      nPLUrettot := 0
      nPLUvoidqty := 0
      nPLUvoidtot := 0 
      nPLUdisctot := 0 
      nPLUnettot  := 0
      nPLUnetqty := 0
      nPLUitmcost:=0
      nPLUprofit:=0
      
      prevplu:=ITM_MOVE->PLU_CODE
//if ITM_MOVE->UPRICE !=0
      prevplusrp:=ITM_MOVE->UPRICE
//endif      
      ITEM->(DBSEEK(ITM_MOVE->PLU_CODE))      
      prevpludesc:=SUBS(ITEM->I_037,1,40)
       nLineCtr += 1

   
     ? MARGIN+repl("-",nLineLen)
     ?  MARGIN+PADR("Dept Total    : ",56) + trans(nDPslsqty,"99,999,999.99") +;
     space(1)+space(9) +space(1) + trans(nDPslstot,"99,999,999.99") + space(1) +;
     trans(nDPretqty,"99,999,999.99") + space(1) + trans(nDPrettot,"99,999,999.99") +;
     space(1) + trans(nDPvoidqty,"99,999,999.99") + space(1) + ;
     trans(nDPvoidtot,"99,999,999.99") + space(1) + trans(nDPdisctot,"999,999.99") +;
     space(1) + trans(nDPnettot,"99,999,999.99") +space(1) + trans(nDPnetqty,"99,999,999.99") +;
     space(1+9)+space(1) + trans(nDPprofit,"99,999,999.99")

    ? MARGIN+repl("-",nLineLen)
    ?
      nDPslsqty := 0
      nDPslstot := 0
      nDPretqty := 0
      nDPrettot := 0
      nDPvoidqty := 0
      nDPvoidtot := 0 
      nDPdisctot := 0 
      nDPnettot  := 0
      nDPnetqty := 0                
      nDPprofit := 0
   nLineCtr += 4
   endif

   
   if prevdept!=ITM_MOVE->DEPT_CODE
      DEPT->(DBSEEK(ITM_MOVE->DEPT_CODE))
      prevdept:=ITM_MOVE->DEPT_CODE
      prevdesc:=DEPT->DDESC
      ? MARGIN + "DEPT. " + prevdept      
      prevplu:=space(14)      
      ?? space(2) + prevdesc
      nLineCtr += 1
   endif      


   if prevplu!=ITM_MOVE->PLU_CODE .and. !empty(prevplu)

      if nPLUslsqty+nPLUretqty+nPLUvoidqty > 0    // zero skip...

      ? MARGIN + prevplu
      ITEM->(DBSEEK(ITM_MOVE->PLU_CODE))
      ?? space(1) + prevpludesc

      ?? space(1) + trans(nPLUslsqty,"99,999,999.99")
      ?? space(1) + trans(prevplusrp,"99,999.99")
      ?? space(1) + trans(nPLUslstot,"99,999,999.99")
      ?? space(1) + trans(nPLUretqty,"99,999,999.99")
      ?? space(1) + trans(nPLUrettot,"99,999,999.99")
      ?? space(1) + trans(nPLUvoidqty,"99,999,999.99")
      ?? space(1) + trans(nPLUvoidtot,"99,999,999.99")

//      ?? space(2) + trans(nPLUdisctot,"9,999,999.99")
      ?? space(1) + trans(nPLUdisctot,"999,999.99")

      ?? space(1) + trans(nPLUnettot,"99,999,999.99")
      ?? space(1) + trans(nPLUnetqty,"99,999,999.99")
      ?? space(1) + trans(nPLUitmcost,"99,999.99")
      ?? space(1) + trans(nPLUprofit,"99,999,999.99")
      
      endif

      nPageslsqty += nPLUslsqty
      nPageslstot += nPLUslstot
      nRunslsqty += nPLUslsqty
      nRunslstot += nPLUslstot
      
      nPageretqty += nPLUretqty
      nPagerettot += nPLUrettot
      nRunretqty += nPLUretqty
      nRunrettot += nPLUrettot      

      nPagevoidqty += nPLUvoidqty
      nPagevoidtot += nPLUvoidtot
      nRunvoidqty += nPLUvoidqty
      nRunvoidtot += nPLUvoidtot
            
      nPagedisctot += val(trans(nPLUdisctot,"99999999.99"))
      nRundisctot  += val(trans(nPLUdisctot,"99999999.99"))
      
      nPagenettot  += nPLUnettot
      nPagenetqty += nPLUnetqty
      nRunnettot  += nPLUnettot
      nRunnetqty += nPLUnetqty      

      nPageprofit  += nPLUprofit
      nRunprofit  += nPLUprofit
            
      nDPnettot += nPLUnettot
      nDPnetqty += nPLUnetqty
      nDPprofit += nPLUprofit


      nPLUslsqty := 0
      nPLUslstot := 0
      nPLUretqty := 0
      nPLUrettot := 0
      nPLUvoidqty := 0
      nPLUvoidtot := 0 
      nPLUdisctot := 0 
      nPLUnettot  := 0
      nPLUnetqty := 0
      nPLUitmcost:=0
      nPLUprofit:=0
      netqty:=0      
      prevplu:=ITM_MOVE->PLU_CODE
      prevplusrp:=ITM_MOVE->UPRICE
      prevplucost:=ITM_MOVE->ITM_COST
      ITEM->(DBSEEK(ITM_MOVE->PLU_CODE))      
      prevpludesc:=SUBS(ITEM->I_037,1,40)
       nLineCtr += 1

   endif


   if empty(prevplu)
      prevplu:=ITM_MOVE->PLU_CODE
      prevplusrp:=ITM_MOVE->UPRICE
      prevplucost:=ITM_MOVE->ITM_COST
      ITEM->(DBSEEK(ITM_MOVE->PLU_CODE))      
      prevpludesc:=SUBS(ITEM->I_037,1,40)
   endif



   if prevplu == ITM_MOVE->PLU_CODE

      nPLUslsqty += ITM_MOVE->QTY
      nPLUslstot += ITM_MOVE->AMOUNT
      nPLUretqty += ITM_MOVE->RTN_QTY
      nPLUrettot += ITM_MOVE->RTN_AMOUNT

   if ITM_MOVE->FLAG == "T"
      nPLUvoidqty += ITM_MOVE->VOID_QTY
      nPLUvoidtot += ITM_MOVE->VOID_AMT 
      itvoidqty := ITM_MOVE->VOID_QTY
      itvoidtot := ITM_MOVE->VOID_AMT
   else 
      itvoidqty := 0
      itvoidtot := 0
   endif

   nPLUdisctot += val(trans(ITM_MOVE->DISC_AMT,"99999999.99"))
   nPLUnettot+=ITM_MOVE->AMOUNT - ITM_MOVE->RTN_AMOUNT - itvoidtot -(val(trans(ITM_MOVE->DISC_AMT,"99999999.99")))

   nPLUnetqty+=ITM_MOVE->QTY -ITM_MOVE->RTN_QTY -itvoidqty
   netqty:=ITM_MOVE->QTY -ITM_MOVE->RTN_QTY -itvoidqty
   nPLUprofit+=(prevplusrp-prevplucost)*netqty

   if ITM_MOVE->UPRICE != 0
         prevplusrp := ITM_MOVE->UPRICE
   endif
   
   if ITM_MOVE->ITM_COST != 0
      prevplucost := ITM_MOVE->ITM_COST
   endif

   ITEM->(DBSEEK(prevplu))      
   prevpludesc:=SUBS(ITEM->I_037,1,40)

   if ITM_MOVE->ITM_COST != 0
      nPLUitmcost:=ITM_MOVE->ITM_COST
   endif      


endif



   if prevdept==ITM_MOVE->DEPT_CODE

      nDPslsqty += ITM_MOVE->QTY
      nDPslstot += ITM_MOVE->AMOUNT
      nDPretqty += ITM_MOVE->RTN_QTY
      nDPrettot += ITM_MOVE->RTN_AMOUNT
 
      if ITM_MOVE->FLAG=="T"
         nDPvoidqty += ITM_MOVE->VOID_QTY
         nDPvoidtot += ITM_MOVE->VOID_AMT
         itvoidqty := ITM_MOVE->VOID_QTY
         itvoidtot := ITM_MOVE->VOID_AMT      
      else
      itvoidqty := 0
      itvoidtot := 0
   endif
      nDPdisctot += val(trans(ITM_MOVE->DISC_AMT,"99999999.99"))

endif                  


     
  // check if footer is needed, eject
  // reset counters
  if nLineCtr >= MAX_LINE 
     ? MARGIN+repl("-",nLineLen)
     ? MARGIN+PADR("Page Total    : ",56) + trans(nPageslsqty,"99,999,999.99") +;
space(1)+space(9) +space(1) + trans(nPageslstot,"99,999,999.99") + space(1) +;
trans(nPageretqty,"99,999,999.99") + space(1) + trans(nPagerettot,"99,999,999.99") +;
space(1) + trans(nPagevoidqty,"99,999,999.99") + space(1) + ;
trans(nPagevoidtot,"99,999,999.99") + space(1) + trans(nPagedisctot,"999,999.99") +;
space(1) + trans(nPagenettot,"99,999,999.99") +space(1) + trans(nPagenetqty,"99,999,999.99")+;
space(1+9+1)+trans(nPageprofit,"99,999,999.99")
 
     ? MARGIN+padr("Running Total : ",56) + trans(nRunslsqty,"99,999,999.99") +;
space(1)+space(9)+ space(1) + trans(nRunslstot,"99,999,999.99") + space(1) +;
trans(nRunretqty,"99,999,999.99") + space(1) + trans(nRunrettot,"99,999,999.99") +;
space(1) + trans(nRunvoidqty,"99,999,999.99") + space(1) + ;
trans(nRunvoidtot,"99,999,999.99") + space(1) + trans(nRundisctot,"999,999.99") +;
space(1) + trans(nRunnettot,"99,999,999.99") +space(1) + trans(nRunnetqty,"99,999,999.99") +;
space(1+9+1)+trans(nRunprofit,"99,999,999.99")

     ? MARGIN+repl("-",nLineLen)
     ?
     // Reset page counter

     nPageslsqty := 0
     nPageslstot := 0
     nPageretqty := 0
     nPagerettot := 0    
     nPagevoidqty := 0
     nPagevoidtot := 0
     nPagedisctot := 0          
     nPagenettot  := 0
     nPagenetqty := 0
       
     lNewPage := .t.
     // eject
     ? chr(12)
  endif

 endif 
//endif
 ITM_MOVE->(DbSkip())
enddo  

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

   ?MARGIN + SPACE(56) + PADL("SALES",13) 
   ?? space(1) + PADL("SRP",9) 
   ?? space(1) + PADL("SALES",13)
   ?? space(1) + PADL("RETURN",13) 
   ?? space(1) + PADL("RETURN",13) 
   ?? space(1) + PADL("VOID",13) 
   ?? space(1) + PADL("VOID",13) 
   ?? space(1) + PADL("DISCOUNT",10) 
   ?? space(1) + PADR("NET SALES",13) 
   ?? space(1) + PADL("NET SALES",13)
   ?? space(1) + PADL("ITEM",9) 
   ?? space(1) + PADL("PROFIT",13)
   ?  MARGIN   + SPACE(56) + PADL("QTY",13) 
   ?? SPACE(1+9+1)+ PADL("AMT",13) 
   ?? space(1) + PADL("QTY",13) 
   ?? space(1) + PADL("AMT",13) 
   ?? space(1) + PADL("QTY",13) 
   ?? space(1) + PADL("AMT",13) 
   ?? space(1) + PADL("AMT",10) 
   ?? space(1) + PADR("AMT",13) 
   ?? space(1) + PADL("QTY",13) 
   ?? space(1) + PADL("COST",9)

   ? MARGIN + REPL("-",nLineLen) 
   ?
   ?
 endif   

    
      ? MARGIN + prevplu
//      PLU->(DBSEEK(ITM_MOVE->PLU_CODE))
      ?? space(1) + prevpludesc

      ?? space(1) + trans(nPLUslsqty,"99,999,999.99")
      ?? space(1) + trans(prevplusrp,"99,999.99")
      ?? space(1) + trans(nPLUslstot,"99,999,999.99")
      ?? space(1) + trans(nPLUretqty,"99,999,999.99")
      ?? space(1) + trans(nPLUrettot,"99,999,999.99")
      ?? space(1) + trans(nPLUvoidqty,"99,999,999.99")
      ?? space(1) + trans(nPLUvoidtot,"99,999,999.99")

//      ?? space(2) + trans(nPLUdisctot,"9,999,999.99")
      ?? space(1) + trans(nPLUdisctot,"999,999.99")

      ?? space(1) + trans(nPLUnettot,"99,999,999.99")
      ?? space(1) + trans(nPLUnetqty,"99,999,999.99")
      ?? space(1) + trans(nPLUitmcost,"99,999.99")
      ?? space(1) + trans(nPLUprofit,"99,999,999.99")
      
      nPageslsqty += nPLUslsqty
      nPageslstot += nPLUslstot
      nRunslsqty += nPLUslsqty
      nRunslstot += nPLUslstot
      
      nPageretqty += nPLUretqty
      nPagerettot += nPLUrettot
      nRunretqty += nPLUretqty
      nRunrettot += nPLUrettot      

      nPagevoidqty += nPLUvoidqty
      nPagevoidtot += nPLUvoidtot
      nRunvoidqty += nPLUvoidqty
      nRunvoidtot += nPLUvoidtot
            
      nPagedisctot += val(trans(nPLUdisctot,"99999999.99"))
      nRundisctot  += val(trans(nPLUdisctot,"99999999.99"))
      
      nPagenettot  += nPLUnettot
      nPagenetqty += nPLUnetqty
      nRunnettot  += nPLUnettot
      nRunnetqty += nPLUnetqty      

      nPageprofit  += nPLUprofit
      nRunprofit  += nPLUprofit

      nDPnettot += nPLUnettot
      nDPnetqty += nPLUnetqty
      nDPprofit += nPLUprofit


 ? MARGIN+repl("-",nLineLen)
 ?  MARGIN+PADR("Dept Total    : ",56) + trans(nDPslsqty,"99,999,999.99") +;
space(1)+space(9) +space(1) + trans(nDPslstot,"99,999,999.99") + space(1) +;
trans(nDPretqty,"99,999,999.99") + space(1) + trans(nDPrettot,"99,999,999.99") +;
space(1) + trans(nDPvoidqty,"99,999,999.99") + space(1) + ;
trans(nDPvoidtot,"99,999,999.99") + space(1) + trans(nDPdisctot,"999,999.99") +;
space(1) + trans(nDPnettot,"99,999,999.99") +space(1) + trans(nDPnetqty,"99,999,999.99")+;
space(1+9)+space(1) + trans(nDPprofit,"99,999,999.99")

 ? MARGIN+repl("-",nLineLen)
 ?
 ?  MARGIN+PADR("Page Total    : ",56) + trans(nPageslsqty,"99,999,999.99") +;
space(1)+space(9)+space(1) + trans(nPageslstot,"99,999,999.99") + space(1) +;
trans(nPageretqty,"99,999,999.99") + space(1) + trans(nPagerettot,"99,999,999.99") +;
space(1) + trans(nPagevoidqty,"99,999,999.99") + space(1) + ;
trans(nPagevoidtot,"99,999,999.99") + space(1) + trans(nPagedisctot,"999,999.99") +;
space(1) + trans(nPagenettot,"99,999,999.99") +space(1) + trans(nPagenetqty,"99,999,999.99")+;
space(1+9+1)+trans(nPageprofit,"99,999,999.99")

 ?  MARGIN+padr("Running Total : ",56) + trans(nRunslsqty,"99,999,999.99") +;
space(1)+space(9)+space(1) + trans(nRunslstot,"99,999,999.99") + space(1) +;
trans(nRunretqty,"99,999,999.99") + space(1) + trans(nRunrettot,"99,999,999.99") +;
space(1) + trans(nRunvoidqty,"99,999,999.99") + space(1) + ;
trans(nRunvoidtot,"99,999,999.99") + space(1) + trans(nRundisctot,"999,999.99") +;
space(1) + trans(nRunnettot,"99,999,999.99") +space(1) + trans(nRunnetqty,"99,999,999.99") +;
space(1+9+1)+trans(nRunprofit,"99,999,999.99")
			  
 ? MARGIN + padl("Page # "+alltrim(trans(nPageCtr++,"9,999"))+ " - Last Page",nLineLen)
 ? MARGIN+repl("-",nLineLen)

 ?  MARGIN+padr("Grand Total : ",56) + trans(nRunslsqty,"99,999,999.99") +;
space(1)+space(9)+space(1) + trans(nRunslstot,"99,999,999.99") + space(1) +;
trans(nRunretqty,"99,999,999.99") + space(1) + trans(nRunrettot,"99,999,999.99") +;
space(1) + trans(nRunvoidqty,"99,999,999.99") + space(1) + ;
trans(nRunvoidtot,"99,999,999.99") + space(1) + trans(nRundisctot,"999,999.99") +;
space(1) + trans(nRunnettot,"99,999,999.99") +space(1) + trans(nRunnetqty,"99,999,999.99") +;
space(1+9+1)+trans(nRunprofit,"99,999,999.99")

 ?  
 ?  MARGIN+"Net Sales Amount     : " + trans( (nRunslstot-nRunrettot-nRunvoidtot-nRunDisctot) ,"999,999,999.99")
 ?  MARGIN+"Net Sales Qty        : " + trans( (nRunslsqty-nRunretqty-nRunvoidqty) ,"999,999,999.99")
 ?  MARGIN+"Profit               : " + trans(nRunprofit,"999,999,999.99")
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

restscreen(19,1,22,60,cScr)
cReport := "" //Free memory      
  
DbCloseAll()
return nil


/*
static function GetDept()
local wValid
cStartDept:=cEndDept:=space(4)
    Message("Enter Department Codes to cover reports")
    wValid := OpenWindow(09,12,15,66,"Printing Validation Box")
    @ 10,12 to 15,66 double    
      @ 12,17 say "From Dept. Code" get cStartDept pict "99"
      @ 13,17 say "  To Dept. Code" get cEndDept pict "99"
      SetCursor(SC_NORMAL)
      HeyThere()
      read
      SetCursor(SC_NONE)
    CloseWindow(wValid)
    cStartDept:=padl(cStartDept,4,"0")
    cEndDept:=padl(cEndDept,4,"0")
return if(LastKey()==K_ESC,.F.,.T.)
*/