#include "Janus.ch"
#include "inkey.ch"
#include "setcurs.ch"#include "memoedit.ch"
#include "fileio.ch"
#include "directry.ch"
#include "its.ch"

#ifdef MARGIN
 #undef MARGIN
#endif

#undef  DISC_FIX

#define MARGIN      Space(1) 
#define REPORTFILE  "DEPT.PRN"
#define MAX_SIZE    65535
#define MAX_LINE    50    
#define EJECT_FROM_FILE
#define DEBUG
#define THIS_WIDTH (85 + PLU_CODE_LEN + PLU_DESC_LEN +PLU_CODE_LEN ) + LEFT_MARGIN 
 
memvar n,dStartDate,dEndDate,nLimit, GetList, cReport

/*=========================================*/
function RDept()
/*=========================================*/
local cRef,wWindBuff
local nMaxrow := maxrow()+1, nMaxCol := maxcol()+1
local aFsize := {}
// Gauge variables
local nRecCtr := 0, hGauge, nPercent, nGaugeCtr:=1, wUpdate, dDate
local cName := space(20), dFile, code
local lNewPage := 0, nLineCtr := 0, nLinelen  := 149, nPageCtr := 1
local nPageslstot := 0, nPageslsqty := 0, cWindow
local nReccount := 0, nCtr := 1, ccolor, coldpath
local nRunslstot := 0, nRunslsqty := 0, count := 0, amount := 0
local cPname := space(20),  prevdept := space(4), prevdesc := space(20)
local lFirst := .f., ldate := .t., ncount := 0, namount := 0.00
local mDept,mDesc,i,nPrevGroup,j:=1
local aPagetot := {}
local aGrantot := {}
local aDept := {}
local aGroupTot := {}
local nDiscRate := 0, nGroup
local lLastTotal := .F.
local cXrate := ""

if !Getvalid()
  BUMMER() ; return nil 
endif 

if netuse("DEPT", DB_SHARED, NUM_SECONDS)
    set index to DEPT
else
   alert("File 'DEPT.DBF' cannot be accessed",{"Quit"})
   return nil    
endif	 

if netuse("DP", DB_SHARED, NUM_SECONDS)
    set index to DP_001
else
   alert("File 'DP.DBF' cannot be accessed",{"Quit"})
   return nil    
endif	 

if netuse("ITEM",DB_SHARED, NUM_SECONDS)
	set index to I_001,I_033
endif

if netuse("PLU", DB_SHARED, NUM_SECONDS)
    set index to DATEPLU
else
   alert("File 'PLU.DBF' cannot be accessed",{"Quit"})
   return nil    
endif

if netUse("FC_HIST",DB_SHARED,NUM_SECONDS)
    set index to FC_HIST
endif
	 
do while FC_HIST->(!eof())
   if  DatesOK(FC_HIST->DATE)
      cXrate += alltrim(str(round(FC_HIST->NEWRATE,2))) +"; "
   endif
   FC_HIST->(dbskip())
enddo     


cOldPath := SET(_SET_PATH)

Message("Preparing Department Total Report ...")

SET ALTERNATE TO ".\"+REPORTFILE
SET ALTERNATE ON
SET CONSOLE OFF
SET PRINTER OFF

window( 19, 1, 22, 60, CONFIRM_COLOR )

lNewPage := .t.
lFirst := .t.
aSize(aGroupTot,9)
aFill(aGroupTot,0)
aSize(aPagetot,9)
aFill(aPagetot,0)
aSize(aGrantot,9)
aFill(aGrantot,0)

// first load all departments on array
while DEPT->(!Eof())
   if DatesOK(DEPT->DATE)
#ifdef DISC_FIX   
     if DP->(DbSeek(subs(DEPT->DCODE,3,2)))   
	   nDiscRate := (DP->DP_009 * 0.01)
	else
	   nDiscRate := 0   
	endif 
#endif	
	if ((n := aScan(aDept,{ |x| x[1] == DEPT->DCODE })) > 0)
       aDept[n,3] += DEPT->DCOUNT
       aDept[n,4] += DEPT->DAMOUNT
#ifdef DISC_FIX	  
       aDept[n,8] += DEPT->DAMOUNT * nDiscRate
#endif	  
     else
	  if DP->(DbSeek(subs(DEPT->DCODE,3,2)))
	     nGroup := DP->DP_003
	  else
	     nGroup := 0
	  endif   
       aAdd(aDept,{	DEPT->DCODE,;
                    (DEPT->DDESC+space(5)),;
                    DEPT->DCOUNT,;
                    DEPT->DAMOUNT,0,0,0,;
				DEPT->DAMOUNT * nDiscRate,;
				nGroup })
     endif  
   endif
   DEPT->(DbSkip())
enddo
DEPT->(DbCloseArea())

while PLU->(!Eof())
     @ 1, 1 wsay " Creating " + "Department Sales Summary Report" + "  Please wait ..."
	if DatesOK(PLU->DATE)
	
	     @ 2, 1 wsay " Item Code: " + PLU->CODE + "    " 
		if ITEM->(DbSeek(PLU->CODE))
			mDept := padl(alltrim(ITEM->I_006),4,"0")
			if DP->(DbSeek(subs(mDept,3,2)))
   			 mDesc := DP->DP_002
			 nGroup := DP->DP_003
			else
			 mDesc := "Department Not Found     " 
			 nGroup := 0
			endif 
		else
		  // Check again by searching the stock code...
		  ITEM->(DbSetOrder(2))
		  if ITEM->(DbSeek("00"+substr(PLU->CODE,3,12)))
		  	mDept := padl(alltrim(ITEM->I_006),4,"0")
			if DP->(DbSeek(subs(mDept,3,2)))
				mDesc := DP->DP_002
				nGroup := DP->DP_003
			else
			   	mDesc := "Department Not Found     " 
				nGroup := 0
			endif	
		  else
		  	mDept := "????"
		  	mDesc := padr(alltrim(PLU->DESC)+PLU->CODE,25,"?") 		
		  	nGroup := 0
		  endif	
		  ITEM->(DbSetOrder(1))
		endif
		
		if ((n := aScan(aDept,{ |x| x[1] == mDept })) > 0)
		  aDept[n,5] += PLU->I_UCOST
		  aDept[n,6] += PLU->RTN_QTY
		  aDept[n,7] += PLU->RTN_AMT
#ifndef DISC_FIX		  
 		  aDept[n,8] += PLU->DISC_AMT
#endif		  
		else
		  aAdd(aDept,{	mDept,;
		  		   	mDesc,;
					0,;
					0,;
					PLU->I_UCOST,;
					PLU->RTN_QTY,;
					PLU->RTN_AMT,;
					PLU->DISC_AMT,;
					nGroup })
		endif  
	endif	
	PLU->(DbSkip())
enddo


if !empty(aDept)
  asort(aDept,,,{|x,y| (pad(x[9],1)+x[1]) < (pad(y[9],1)+y[1]) } )
  for j := 1 to len(aDept)
	if (aDept[j,3] +aDept[j,4] +aDept[j,5] +aDept[j,6] +aDept[j,7] +aDept[j,8] != 0)
	  exit
     endif	
  next
  if j > len(aDept) //RCI 11-22-98
    j := 1
  endif
  nGroup :=  aDept[j,9]
  nPrevGroup := aDept[j,9]

endif

for i := j to len(aDept)
    
  // Create header if new page  
  if lNewPage  
   // Create header if new page  
   ? MARGIN + "DEPARTMENT TOTAL REPORT"
   ?
   ? MARGIN +chr(254)+ SYS_NAME
   ? MARGIN +"Department Total Report"
   ? MARGIN +"From "+dtoc(dStartDate)+" to "+dtoc(dEndDate)
   ? MARGIN +"As of "+dtoc(date())+", "+time()
   ?
   ? MARGIN + "EXCH. RATE:   $1.00 - " + cXrate 
   ?

   ? MARGIN + padr("DEPT",4)
   ?? space(1) + padc("Description",25)
   ?? space(1) + padl("Units",10)
   ?? space(1) + padl("Sales",14)
   ?? space(1) + padl("Cost",14)
   ?? space(1) + padl("Average",10)
   ?? space(1) + padl("Return",10)
   ?? space(1) + padl("Return",14)
   ?? space(1) + padl("Net",10)
   ?? space(1) + padl("Net",14)
   ?? space(1) + padl("Net",14)

   ? MARGIN + padr("CODE",4)
   ?? space(1) + space(25)
   ?? space(1) + padl("Sold",10)
   ?? space(1) + padl("Amount",14)
   ?? space(1) + padl("Amount",14)
   ?? space(1) + padl("Per Item",10)
   ?? space(1) + padl("Qty",10)
   ?? space(1) + padl("Amount",14)
   ?? space(1) + padl("Disc",10)
   ?? space(1) + padl("Units",14)
   ?? space(1) + padl("Sales",14)

   ? MARGIN + repl("-",nLinelen)

   ?
   ?

   lNewpage := .f.
   nLineCtr := 13
  endif   

  if (aDept[i,3] +aDept[i,4] +aDept[i,5] +aDept[i,6] +aDept[i,7] +aDept[i,8] != 0)
  
      // Create Group Totals
      if (len(aDept) == i) .or. ((len(aDept) > i) .and. (nPrevGroup != aDept[i,9]))
        ? MARGIN+repl("-",nLineLen)
        ? MARGIN+"     " + space(25) +;
              space(1) + trans(aGroupTot[1],"999,999.99") + ;
              space(1) + trans(aGroupTot[2],"999,999,999.99") + ;
              space(1) + trans(aGroupTot[3],"999,999,999.99") + ;
              space(1) + trans(aGroupTot[4],"999,999.99") + ;
              space(1) + trans(aGroupTot[5],"999,999.99") + ;
              space(1) + trans(aGroupTot[6],"999,999,999.99") + ;
              space(1) + trans(aGroupTot[7],"999,999,999.99") + ;
              space(1) + trans(aGroupTot[8],"999,999.99") + ;
              space(1) + trans(aGroupTot[9],"999,999,999.99")
        ?
        aFill(aGroupTot,0)
        nLineCtr += 3
	   nPrevGroup := aDept[i,9]
	   if (len(aDept) == i)
	     lLastTotal := .T.
	   endif
      endif

	 if nLineCtr >= MAX_LINE
        // lNewPage := .t.
        // eject
        ? chr(12)
        nLineCtr := 0
      endif
  
	   
      ?  MARGIN + padl(aDept[i,1],4,"0")
	 ?? space(1) + aDept[i,2]
      ?? space(1) + trans(aDept[i,3],"999,999.99")
      ?? space(1) + trans(aDept[i,4],"999,999,999.99")
	 ?? space(1) + trans(aDept[i,5],"999,999,999.99")
	 ?? space(1) + trans((aDept[i,4]/aDept[i,3]),"999,999.99")
      ?? space(1) + trans(aDept[i,6],"999,999.99")
      ?? space(1) + trans(aDept[i,7],"999,999,999.99")
	 ?? space(1) + trans(aDept[i,8],"999,999,999.99")
      ?? space(1) + trans(aDept[i,3]-aDept[i,6],"999,999.99")
      ?? space(1) + trans(aDept[i,4]-aDept[i,8]-aDept[i,7],"999,999,999.99")

      nLineCtr += 1	 
	 
	 aGroupTot[1] += aDept[i,3]
	 aGroupTot[2] += aDept[i,4]
	 aGroupTot[3] += aDept[i,5]
	 aGroupTot[4] += (aDept[i,4]/aDept[i,3])
	 aGroupTot[5] += aDept[i,6]
	 aGroupTot[6] += aDept[i,7]
	 aGroupTot[7] += aDept[i,8]
	 aGroupTot[8] += (aDept[i,3]-aDept[i,6])	
	 aGroupTot[9] += (aDept[i,4]-aDept[i,8]-aDept[i,7])

	 aGrantot[1] += aDept[i,3]
	 aGrantot[2] += aDept[i,4]
	 aGrantot[3] += aDept[i,5]
	 aGrantot[4] += (aDept[i,4]/aDept[i,3])
	 aGrantot[5] += aDept[i,6]
	 aGrantot[6] += aDept[i,7]
	 aGrantot[7] += aDept[i,8]
	 aGrantot[8] += (aDept[i,3]-aDept[i,6])	
	 aGrantot[9] += (aDept[i,4]-aDept[i,8]-aDept[i,7])


  endif

next  
     if !lLastTotal 
        ? MARGIN+repl("-",nLineLen)
        ? MARGIN+"     " + space(25) +;
              space(1) + trans(aGroupTot[1],"999,999.99") + ;
              space(1) + trans(aGroupTot[2],"999,999,999.99") + ;
              space(1) + trans(aGroupTot[3],"999,999,999.99") + ;
              space(1) + trans(aGroupTot[4],"999,999.99") + ;
              space(1) + trans(aGroupTot[5],"999,999.99") + ;
              space(1) + trans(aGroupTot[6],"999,999,999.99") + ;
              space(1) + trans(aGroupTot[7],"999,999,999.99") + ;
              space(1) + trans(aGroupTot[8],"999,999.99") + ;
              space(1) + trans(aGroupTot[9],"999,999,999.99")
        ?
        aFill(aGroupTot,0)
        nLineCtr += 3
      endif

    ?
    ? MARGIN + repl("-",nLinelen)
    ? MARGIN+ padr("Grand Total",30) + ;
    		space(1) + trans(aGrantot[1],"999,999.99") + ;
		space(1) + trans(aGrantot[2],"999,999,999.99") + ;
		space(1) + trans(aGrantot[3],"999,999,999.99") + ;
		space(1) + trans(aGrantot[4],"999,999.99") + ;
		space(1) + trans(aGrantot[5],"999,999.99") + ;
		space(1) + trans(aGrantot[6],"999,999,999.99") + ;
		space(1) + trans(aGrantot[7],"999,999,999.99") + ;
		space(1) + trans(aGrantot[8],"999,999.99") + ;
		space(1) + trans(aGrantot[9],"999,999,999.99")    
    ? MARGIN + repl("-",nLinelen)		
 
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
   wWindBuff:=OpenWindow(1,2,maxrow()-1,maxcol()-2,"Department Total Report")
   MemoEdit(cReport,2,3,maxrow()-2,maxcol()-3,.f.,'EditorFunc',155 )
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




