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
#define REPORTFILE  "DEPT.PRN"
#define MAX_SIZE    65535
#define MAX_LINE    50    
#define EJECT_FROM_FILE
#define DEBUG
#define THIS_WIDTH (85 + PLU_CODE_LEN + PLU_DESC_LEN +PLU_CODE_LEN ) + LEFT_MARGIN
 
memvar n,dStartDate,dEndDate,nLimit, GetList, cReport


/*=========================================*/
function DptClass()
/*=========================================*/
local cRef,wWindBuff
local nMaxrow := maxrow()+1, nMaxCol := maxcol()+1
local aFsize := {}
// Gauge variables
local nRecCtr := 0, hGauge, nPercent, nGaugeCtr:=1, wUpdate, dDate
local cName := space(20), dFile, code
local lNewPage := 0, nLineCtr := 0, nLinelen  := 57, nPageCtr := 1
local nPageslstot := 0, nPageslsqty := 0, cWindow
local nReccount := 0, nCtr := 1, ccolor, coldpath
local nRunslstot := 0, nRunslsqty := 0, count := 0, amount := 0
local cPname := space(20),  prevdept := space(4), prevdesc := space(20)
local lFirst := .f., ldate := .t., ncount := 0, namount := 0.00

//jzo04-29-98 
local cDpCode:=space(4), cprevdept:= space(4),nPLUDptTot:=0
local nDptSlsTot := 0, nDptTot := 0, nAllDptSlsTot := 0, nDpTotAcc:=0
local nDPCLTot:=0, clindx:=0, cPLUdesc:=space(20),nPLUtotal:=0
local desc:=space(20),aDPCL:={},nDPCLindx,cDPCLcode:=space(4),cPLUcode:=space(14)
local cDPname:=space(20),cCLcode:=space(4),cprevDP:=space(2),cprevCL:=space(2)

if !Getvalid()
  BUMMER() ; return nil 
endif 

if netuse("DEPT", DB_SHARED, NUM_SECONDS)
    set index to DEPT
else
   alert("File 'DEPT.DBF' cannot be accessed",{"Quit"})
   return nil    
endif	 


if netuse("CL", DB_SHARED, NUM_SECONDS)
    set index to CL_001
else
   alert("File 'CL.DBF' cannot be accessed",{"Quit"})
   return nil    
endif	 


if netuse("PLU", DB_SHARED, NUM_SECONDS)
    set index to PLU
else
   alert("File 'PLU.DBF' cannot be accessed",{"Quit"})
   return nil    
endif	 

cOldPath := SET(_SET_PATH)

Message("Preparing Department/Class Sales Report ...")


SET ALTERNATE TO ".\"+REPORTFILE
SET ALTERNATE ON
SET CONSOLE OFF
SET PRINTER OFF

window( 19, 1, 22, 60, CONFIRM_COLOR )

lNewPage := .t.
lFirst := .t.
/*
do while DEPT->(!EOF())
 if DatesOk(DEPT->DATE)
 DCode:= SUBS(DEPT->DCODE,3,2)
 CL->(DBGOTOP())
 DO WHILE CL->(!EOF())
    if subs(CL->CL_001,1,2)==DCode
       aadd(aDPCL,DCode+subs(CL->CL_001,3,2))
    endif
    CL->(DBSKIP())
 ENDDO
 endif
 DEPT->(DBSKIP())
enddo 
*/
PLU->(dbgotop())
Do while PLU->(!eof())
 if DatesOk(PLU->DATE) 
    
      nAllDptSlsTot += PLU->IAMOUNT
      nDpTotAcc += PLU->IAMOUNT
  
 endif
 PLU->(DbSkip())
enddo

while CL->(!EOF())
cCLcode:=CL->CL_001

if cprevCL!=subs(cCLcode,3,2) .and. !empty(cprevCL)
   ? MARGIN + SPACE(4) + SPACE(3) + subs(cPLUcode,6,2) + " " +;
     subs(cPLUdesc,1,17) + space(3) + trans(nPLUtotal," 999,999,999.99")
   cprevCL:=subs(cCLcode,3,2)
   nPLUtotal:=0
   nCtr += 1
nLineCtr++   
endif   


if cprevDP!=subs(CL->CL_001,1,2) .and. !empty(cprevDP)
DEPT->(DBGOTOP())
do while DEPT->(!eof())
   IF subs(DEPT->DCODE,3,2)==subs(cprevDP,1,2)
      ?  MARGIN + PADR(SUBS(DEPT->DCODE,3,2),4,"0")
      ?? space(3) + SUBS(DEPT->DDESC,1,20)
      ?? space(3) + trans(nPLUDptTot," 999,999,999.99")
      ?? space(3) + trans( (nPLUDptTot/nAllDptSlsTot)*100 ,"    999.99" )
      ?
nLineCtr++
nPageslstot += nPLUDptTot
nRunslstot  += nPLUDptTot        
      nPLUDptTot:=0
      cprevDP:=space(2)
      nCtr += 1   
      exit
   ENDIF
DEPT->(DBSKIP())
enddo   
endif

if empty(cprevDP)
  cprevDP:=subs(cCLcode,1,2)
endif
if empty(cprevCL)
  cprevCL:=subs(cCLcode,3,2)
endif
  
PLU->(dbgotop())
Do While PLU->(!Eof())  

  @ 1, 1 wsay " Creating " + "Dept/Class Sales Report" + "  Please wait ..."
  @ 2, 1 wsay " Item Code: " + PLU->CODE + "    "

 if DatesOk(PLU->DATE) // .AND. (SUBS(PLU->CODE,4,4)==cCLcode)
 

  // Create header if new page  
  if lNewPage  
   // Create header if new page  
   ? MARGIN + "DEPARTMENT/CLASS SALES REPORT"
   ?
   ? MARGIN +chr(254)+ SYS_NAME
   ? MARGIN +"Department/Class Sales Report"
   ? MARGIN +"From "+dtoc(dStartDate)+" to "+dtoc(dEndDate)
   ? MARGIN +"As of "+dtoc(date())+", "+time()
   ?
   ?
   ?

   ? MARGIN + "DEPT                                                  "
   ? MARGIN + "CODE        DESCRIPTION       SALES             % CONT.    "
   ? MARGIN + "----   --------------------   ---------------   -----------"
   //          1234   12345678901234567890   123456789012345   1234567890
   
   ?

   lNewpage := .f.
   nLineCtr := 13
  endif   

cPLUcode:=PLU->CODE
cPLUdesc:=PLU->DESC
nPLUtotal+=PLU->IAMOUNT
nPLUDptTot+=PLU->IAMOUNT
nLineCtr++
//nPageslstot += nPLUDptTot
//nRunslstot  += nPLUDptTot  
    
  // check if footer is needed, eject
  // reset counters
  if nLineCtr >= MAX_LINE 
    ?
    ? MARGIN+repl("-",nLineLen+46+15-59)
    ? MARGIN+"Page Total    : " + space(30-3-12) +;
            trans(nPageslstot,"999,999,999.99")
    ?  MARGIN+"Running Total : " + space(30-3-12) +;
            trans(nRunslstot,"999,999,999.99") 				  
    ? MARGIN + padl("Page # "+alltrim(trans(nPageCtr++,"9,999")),nLineLen+46+15-59)		  
    ? MARGIN+repl("-",nLineLen+46+15-59)
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
CL->(DBSKIP())
enddo


  if lNewPage  
   // Create header if new page  
   ? MARGIN + "DEPARTMENT/CLASS SALES REPORT"
   ?
   ? MARGIN +chr(254)+ SYS_NAME
   ? MARGIN +"Department/Class Sales Summary Report"
   ? MARGIN +"From "+dtoc(dStartDate)+" to "+dtoc(dEndDate)
   ? MARGIN +"As of "+dtoc(date())+", "+time()
   ?
   ?
   ?

   ? MARGIN + "DEPT                                                  "
   ? MARGIN + "CODE        DESCRIPTION       SALES             % CONT.    "
   ? MARGIN + "----   --------------------   ---------------   -----------"
   //          1234   12345678901234567890   123456789012345   1234567890

   ?
 endif   


 ?
 ? MARGIN+repl("-",nLineLen+46+15-59)
 ?  MARGIN+"Page Total    : " + space(30-3-12) +;
              trans(nPageslstot,"999,999,999.99") 
 ?  MARGIN+"Running Total : " + space(30-3-12) +;
               trans(nRunslstot,"999,999,999.99") 				  
 ? MARGIN + padl("Page # "+alltrim(trans(nPageCtr++,"9,999"))+ " - Last Page",nLineLen+46+15-59)
 ? MARGIN+repl("-",nLineLen+46+15-59)
 ?
 ?  
 ?  MARGIN+"Total Sales    : " + alltrim(trans(nRunslstot,"999,999,999.99"))
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
   wWindBuff:=OpenWindow(1,2,maxrow()-1,maxcol()-2,"Department/Class Sales Report")
   MemoEdit(cReport,2,3,maxrow()-2,maxcol()-3,.f.,'Editor2Func',70 )
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




