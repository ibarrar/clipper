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
#define CASH_ACC    "CSH_ACCT.PRN"
#define STR_ACC     "TRM_ACCT.PRN"
#define STR_CONS    "OUTLET.PRN"

#define MAX_SIZE    65535
#define MAX_LINE    50    
#define EJECT_FROM_FILE
#define DEBUG
 
memvar dStartDate,dEndDate, cReport
memvar GetList



/*=========================================*/
function Cash_Acct()
/*=========================================*/
local cRef,wWindBuff
local nMaxrow := maxrow()+1, nMaxCol := maxcol()+1
local aFsize := {}
// Gauge variables
local nRecCtr := 0, hGauge, nPercent, nGaugeCtr:=1, wUpdate
local nGrsSls := 0, nCsSls := 0, nVdAmt := 0, nVdMgr := 0
local nSlsDsc := 0, nAddOn := 0, nRetrns := 0, nPckUp := 0, nOffLine := 0
local nLoan := 0, nCashDec := 0, nOther := 0, nBnkChq := 0
local nCrdtCrd := 0, nEmpChq := 0, nGftChq := 0, nEmpCrd := 0
local nNEmpCrd := 0, nPO := 0, nTotlAdd := 0, nGrossPls := 0
local nTotlVd  := 0, nTotlNeg := 0, nNetSls := 0, nDiff := 0
local nTotlTnd := 0.00, nCtr := 0, cDiff, dDate := ctod("")
local cOldPath, nTVoid := 0, nCancel := 0, nRefnd := 0, nTotlSls := 0
local nVdQty := 0, nVdMQty := 0, nTVQty := 0, nCQty := 0, nRetQty := 0
local nRefQty := 0, nDscQty := 0, nAddQty := 0, aCcd := {}
local cName := space(20), linectr := 0, lfirst := .t., i := 0,n := 0
local nSubtdsc := 0, nsubtQty:= 0, nCaSls := 0, nChrgPay := 0
local totCash := 0, nTotCcd := 0, cntrl_no := " "
local nPesoTot := 0


//jzo04-15-98
local nPeso := 0, nDollar := 0, nXrate := 0, aCredit := {}, indx := 0, cTime
local nCrdtDollar:=0, nCrdtPeso:=0, aFrate := {}, j:=0, dLstDate := ctod("")
local nLstRate:=0

if !Getvalid()
  BUMMER() ; return nil 
endif 


if netuse("CASH", DB_SHARED, NUM_SECONDS)
    set index to CAS
else
   alert("File 'CASH.DBF' cannot be accessed",{"Quit"})
   return nil    
endif	 

if netuse("PLU", DB_SHARED, NUM_SECONDS)
    set index to PLU
endif	 

//jzo03-27-98
if netuse("NPLU", DB_SHARED, NUM_SECONDS)
    set index to NITEMCNT
endif	 

if netUse("CC",DB_SHARED,NUM_SECONDS)
    index  on CC->CC_001 to CC_001
endif

if netuse("CNTRL", DB_SHARED, NUM_SECONDS)
  SET INDEX TO CNTRL,CDATE
endif	 

//jzo04-17-98
if netUse("FC_HIST",DB_SHARED,NUM_SECONDS)
    set index to FC_HIST
endif

cOldPath := SET(_SET_PATH)

Message("Preparing Cashier Accountability Report ...")

SET ALTERNATE TO ".\"+CASH_ACC
SET ALTERNATE ON
SET CONSOLE OFF
SET PRINTER OFF

window( 19, 1, 22, 60, CONFIRM_COLOR )

//jzo04-17-98

 for indx := 1 to 40

  aadd(aCredit,{" ",0,0})
 
 next indx
  
 DO WHILE CC->(!EOF())

   aCredit[1+n][1] := CC->CC_002
   n := n+1
   CC->(DBSKIP())
 ENDDO   

n:=0

 CASH->(dbgotop())

Do While CASH->(!Eof())  

  @ 1, 1 wsay " Creating Cashier Acct' Report, Please wait ..."
  @ 2, 1 wsay " Cashier Code: " + CASH->CODE

    
  // add counters if date is inclusive

  if DatesOk(CASH->DATE) 
    dDate := CASH->DATE
    cTime := CASH->TIME       //jzo04-20-98
    nNetSls	  += CASH->daily_a	
    nGrossPls     += CASH->gross_a
    nCaSls        += CASH->cash_a     
    nVdAmt        += CASH->ivoid_a
    nVdMgr        += CASH->mvoid_a
    nVdQty        += CASH->ivoid_c
    nVdMQty       += CASH->mvoid_c
    nTVoid        += CASH->tvoid_a
    nTVQty        += CASH->tvoid_c
    nCancel       += CASH->cancl_a
    nCQty         += CASH->cancl_c
    nSlsDsc       += CASH->idisc_a
    nDscQty       += CASH->idisc_c
    nSubtDsc      += CASH->subtd_a
    nsubtQty      += CASH->subtd_c
    nAddOn        += CASH->addon_a
    nAddQty       += CASH->addon_c
    nRetrns       += CASH->retrn_a
    nRetQty       += CASH->retrn_c 
    nRefnd        += CASH->refnd_a
    nRefQty       += CASH->refnd_c 
    nPckUp        += CASH->pikup_a
    nOffLine      += CASH->offln_a  
    nLoan         += CASH->loan_a
    nCashDec      += CASH->recact_a
    nOther        += CASH->otinc_a

//jzo04-17-98
    nPeso       += CASH->forcur_a
 
    aCredit[1][2] += CASH->MISC01_C 
    aCredit[1][3] += CASH->MISC01_A
    
    aCredit[2][2] += CASH->MISC02_C 
    aCredit[2][3] += CASH->MISC02_A 
    
    aCredit[3][2] += CASH->MISC03_C 
    aCredit[3][3] += CASH->MISC03_A 

    aCredit[4][2] += CASH->MISC04_C 
    aCredit[4][3] += CASH->MISC04_A
    
    aCredit[5][2] += CASH->MISC05_C 
    aCredit[5][3] += CASH->MISC05_A
    
    aCredit[6][2] += CASH->MISC06_C 
    aCredit[6][3] += CASH->MISC06_A
    
    aCredit[7][2] += CASH->MISC07_C 
    aCredit[7][3] += CASH->MISC07_A
    
    aCredit[8][2] += CASH->MISC08_C 
    aCredit[8][3] += CASH->MISC08_A
    
    aCredit[9][2] += CASH->MISC09_C 
    aCredit[9][3] += CASH->MISC09_A
    
    aCredit[10][2] += CASH->MISC10_C 
    aCredit[10][3] += CASH->MISC10_A
    
    aCredit[11][2] += CASH->MISC11_C 
    aCredit[11][3] += CASH->MISC11_A
    
    aCredit[12][2] += CASH->MISC12_C 
    aCredit[12][3] += CASH->MISC12_A
    
    aCredit[13][2] += CASH->MISC13_C 
    aCredit[13][3] += CASH->MISC13_A
    
    aCredit[14][2] += CASH->MISC14_C 
    aCredit[14][3] += CASH->MISC14_A
    
    aCredit[15][2] += CASH->MISC15_C 
    aCredit[15][3] += CASH->MISC15_A
    
    aCredit[16][2] += CASH->MISC16_C 
    aCredit[16][3] += CASH->MISC16_A
    
    aCredit[17][2] += CASH->MISC17_C 
    aCredit[17][3] += CASH->MISC17_A
    
    aCredit[18][2] += CASH->MISC18_C 
    aCredit[18][3] += CASH->MISC18_A
    
    aCredit[19][2] += CASH->MISC19_C 
    aCredit[19][3] += CASH->MISC19_A
    
    aCredit[20][2] += CASH->MISC20_C 
    aCredit[20][3] += CASH->MISC20_A
    

    aCredit[21][2] += CASH->MISC21_C 
    aCredit[21][3] += CASH->MISC21_A
    
    aCredit[22][2] += CASH->MISC22_C 
    aCredit[22][3] += CASH->MISC22_A 
    
    aCredit[23][2] += CASH->MISC23_C 
    aCredit[23][3] += CASH->MISC23_A 

    aCredit[24][2] += CASH->MISC24_C 
    aCredit[24][3] += CASH->MISC24_A
    
    aCredit[25][2] += CASH->MISC25_C 
    aCredit[25][3] += CASH->MISC25_A
    
    aCredit[26][2] += CASH->MISC26_C 
    aCredit[26][3] += CASH->MISC26_A
    
    aCredit[27][2] += CASH->MISC27_C 
    aCredit[27][3] += CASH->MISC27_A
    
    aCredit[28][2] += CASH->MISC28_C 
    aCredit[28][3] += CASH->MISC28_A
    
    aCredit[29][2] += CASH->MISC29_C 
    aCredit[29][3] += CASH->MISC29_A
    
    aCredit[30][2] += CASH->MISC30_C 
    aCredit[30][3] += CASH->MISC30_A
    
    aCredit[31][2] += CASH->MISC31_C 
    aCredit[31][3] += CASH->MISC31_A
    
    aCredit[32][2] += CASH->MISC32_C 
    aCredit[32][3] += CASH->MISC32_A
    
    aCredit[33][2] += CASH->MISC33_C 
    aCredit[33][3] += CASH->MISC33_A
    
    aCredit[34][2] += CASH->MISC34_C 
    aCredit[34][3] += CASH->MISC34_A
    
    aCredit[35][2] += CASH->MISC35_C 
    aCredit[35][3] += CASH->MISC35_A
    
    aCredit[36][2] += CASH->MISC36_C 
    aCredit[36][3] += CASH->MISC36_A
    
    aCredit[37][2] += CASH->MISC37_C 
    aCredit[37][3] += CASH->MISC37_A
    
    aCredit[38][2] += CASH->MISC38_C 
    aCredit[38][3] += CASH->MISC38_A
    
    aCredit[39][2] += CASH->MISC39_C 
    aCredit[39][3] += CASH->MISC39_A
    
    aCredit[40][2] += CASH->MISC40_C 
    aCredit[40][3] += CASH->MISC40_A


    // wala pa ngayon
/*
    nBnkChq       += CASH->misc18_a + CASH->misc19_a +CASH->misc20_a +;
                    CASH->misc21_a + CASH->misc22_a +CASH->misc23_a +;
                    CASH->misc24_a + CASH->misc25_a +CASH->misc26_a +;
                    CASH->misc27_a + CASH->misc28_a
*/

    nCrdtPeso      += CASH->misc01_a + CASH->misc02_a +CASH->misc03_a +;
                    CASH->misc04_a + CASH->misc05_a +CASH->misc06_a +;
                    CASH->misc07_a + CASH->misc08_a +CASH->misc09_a +;
                    CASH->misc10_a + CASH->misc11_a +CASH->misc12_a +;
                    CASH->misc13_a +CASH->misc14_a +CASH->misc15_a +;
                    CASH->misc16_a +CASH->misc17_a +CASH->misc18_a +;
                    CASH->misc19_a +CASH->misc20_a 


    nCrdtDollar     += CASH->misc21_a + CASH->misc22_a +CASH->misc23_a +;
                    CASH->misc24_a + CASH->misc25_a +CASH->misc26_a +;
                    CASH->misc27_a + CASH->misc28_a +CASH->misc29_a +;
                    CASH->misc30_a + CASH->misc31_a +CASH->misc32_a +;
                    CASH->misc33_a +CASH->misc34_a +CASH->misc35_a +;
                    CASH->misc36_a +CASH->misc37_a +CASH->misc38_a +;
                    CASH->misc39_a +CASH->misc40_a 
//    nDollar := CASH->MISC50_A

    nDollar += CASH->MISC50_A

/*
    nEmpChq       += CASH->misc30_a
    nGftChq       += CASH->misc29_a
    nEmpCrd       += CASH->misc14_a
    nNEmpCrd      += CASH->misc15_a 
    nPO           += CASH->misc16_a + CASH->misc17_a
*/    
  endif   
    
  
  CASH->(DbSkip())
enddo

//jzo04-24-98
do while FC_HIST->(!eof())
  if FC_HIST->DATE == dDate 
     aadd(aFrate,round(FC_HIST->NEWRATE,2))
  endif
FC_HIST->(dbskip())
enddo     

  FC_HIST->(dbgotop())
  while FC_HIST->(!eof())
    nXrate := round(FC_HIST->NEWRATE,2)  //jlp.  
    if FC_HIST->DATE == dDate
       nXrate := round(FC_HIST->NEWRATE,2)  //jlp.
       exit
    endif
    FC_HIST->(dbskip())
  enddo
  
if len(aFrate) == 0
 FC_HIST->(DBGOBOTTOM())
 aadd(aFrate,round(FC_HIST->NEWRATE,2))
endif

  // total counters
  nTotlAdd           := nOther + nAddon
  nGrsSls            := nGrossPls - nTotlAdd
  nTotlVd            := nVdAmt + nVdMgr + nCancel
  nTotlNeg           := nSlsDsc + nSubtdsc + nRetrns + nRefnd + nTVoid
  nTotlSls           := nGrsSls - nTotlNeg
  totcash            := nCaSls - nLoan + nPckup + nOffline
/*jzo04-17-98
  nTotlTnd           := nCaSls + nBnkChq + nCrdtCrd - nOther ; //bing
                        + nEmpChq + nGftChq + nEmpCrd ;
                        + nNEmpCrd + nPO // - (nAddon + nRefnd)
*/

//jzo04-17-98
//  nDollar            := nPeso / nXrate

  nTotlTnd           := nCaSls + nDollar + nCrdtDollar


  // report format
  ? CHR(15)
  ? MARGIN + "Run Date : " + dtoc(Date())
  ? CHR(18)
  ? MARGIN + space(32) + SYS_NAME
  ? MARGIN + space(24) + "Cashier Accountability Report"
  ?
  ?
  CNTRL->(DbSetOrderto(2))
  CNTRL->(DbSeek(dtos(dStartDate)))
  cntrl_no := " "
  while DatesOk(CNTRL->DATE)
     cntrl_no += alltrim(str(CNTRL->CONTRL_NO)) + ","
     dDate := CNTRL->DATE
     CNTRL->(DBSKIP())
  ENDDO
  CNTRL->(DbSetOrderto(1))
  ? MARGIN + "CONTROL NO. : " + cntrl_no + " " + dtoc(dDate)
  ?

  ? MARGIN + "EXCH. RATE:   $1.00 - " + alltrim(str(nXrate))

  for j:=1 to len(aFrate)
      ?? ", "+alltrim(trans(aFrate[j],"99,999,999.99"))
  next j

  ? 
  ? MARGIN + "GROSS SALES[DEPT SALES]                 " + trans(nGrsSls,"99,999,999.99")

  ?
  ? MARGIN + "GROSS PLUS[GROSS SALES]                 " + trans(nGrossPls,"99,999,999.99")
  ? MARGIN + "Less   : VOID ENTRIES         "
  ? MARGIN + "          Void Line Items               " + trans(nVdAmt,"99,999,999.99") 
  ?? space(4) + "(" + trans(nVdQty,"9999") + ")"                   
  ? MARGIN + "         Manager Void                   " + trans(nVdMgr,"99,999,999.99") 
  ?? space(4) + "(" + trans(nVdMQty,"9999") + ")"                    
  ? MARGIN + "          Void Total [Tran. Cancel]     " + trans(nCancel,"99,999,999.99")
  ?? space(4) + "(" + trans(nCQty,"9999") + ")"                    
  ? MARGIN + "                               ----------------------"
  ? MARGIN + "      [Total Void Entries               " + trans(nTotlVd,"99,999,999.99")  +"]"
  ?
  ? MARGIN + " Less  : Negative Entries"
  ? MARGIN + "         Returns                        " + trans(nRetrns,"99,999,999.99")
  ?? space(4) + "(" + trans(nRetQty,"9999") + ")"                    
  ? MARGIN + "         Refund                         " + trans(nRefnd,"99,999,999.99") 
  ?? space(4) + "(" + trans(nRefQty,"9999") + ")"                    
  ? MARGIN + "         Sales Discount                 " + trans(nSlsDsc+nSubtDsc,"99,999,999.99")
  ?? space(4) + "(" + trans(nDscQty+nSubTQty,"9999") + ")"          
  ? MARGIN + "         Void Previous[Tran. Void]      " + trans(nTVoid,"99,999,999.99")
  ?? space(4) + "(" + trans(nTVQty,"9999") + ")"                              
  ? MARGIN + "                               ----------------------"
  ? MARGIN + "       Total Negative Entries           " + trans(nTotlNeg,"99,999,999.99")
  ?
  ? MARGIN + "NET SALES [DAILY SALES]                 " + trans(nNetSls,"99,999,999.99")
//jzo04-18-98   ? chr(12)


  ?
  ? 
  ? MARGIN + "TENDER(s)               " 
  ? MARGIN + "         Dollar                         " + trans(nCaSls,"99,999,999.99")
  ? MARGIN + "         Peso                           " + trans(nDollar,"99,999,999.99") + " - P " + trans(nPeso,"99,999,999.99")
  ? MARGIN + "  CARD:                                 " 
  nPesoTot := nPeso
for indx := 1 to len(aCredit)
     if aCredit[indx][2] <> 0 .or. aCredit[indx][3] <> 0 
     
      if aCredit[indx][1] == " "
        ? MARGIN +"         CREDIT CARD "+alltrim(str(indx)) +space(40-(9+len("CREDIT CARD "+alltrim(str(indx)))))
      else
        ? MARGIN + space(9) + aCredit[indx][1] +space(40-(9+len(aCredit[indx][1])))
      endif 
      ?? trans(aCredit[indx][3],"99,999,999.99") 
	 ?? " - P " + trans(aCredit[indx][3]*nXrate,"99,999,999.99")
   	 nTotlTnd += aCredit[indx][3]
	 nPesoTot += (aCredit[indx][3] * nXrate)
      linectr += 1    
     endif 
  if linectr == 50
     ? chr(12)
     lfirst := .t.
  endif

next indx


  ? MARGIN + "                               ----------------------   ---------------"
  ? MARGIN + "TOTAL TENDER                            " + trans(nTotlTnd,"99,999,999.99")
  ?? "     " + trans(nPesoTot,"99,999,999.99")        
  ?
  ?
  ?
//jzo04-18-98  ? MARGIN + "Prepared By : _____________________   Reviewed By : _____________________"
 
  ? chr(12)  

CLOSE ALTERNATE
SET ALTERNATE OFF
SET CONSOLE ON

aFsize := directory(CASH_ACC)

// check if report file is < 64K
// direct to printer if greater   

if aFsize[1][2] < MAX_SIZE

  cReport:=memoread(CASH_ACC)
  if !empty(cReport)
   if !setmode(50,80) .and. !setmode(43,80)
      setmode(nMaxrow,nMaxcol)
   else
      _logo()   
   endif       
   Message("Use cursor keys to navigate, press F10 to print, "+ ;
              "Esc to abort.")
   wWindBuff:=OpenWindow(1,2,maxrow()-1,maxcol()-2,"Cashier Accountability Report")
   MemoEdit(cReport,2,3,maxrow()-2,maxcol()-3,.f.,'Editor2Func',122 )
   CloseWindow(wWindBuff)
   setcursor(SC_NONE)
   setmode(nMaxrow,nMaxcol)
  endif
 
else

 if alert("Report too large to edit, will be directed to printer", {"Print","Quit"}) == 1 
    Direct2Prn(CASH_ACC) 
 endif  
 
endif  


cReport := "" //Free memory      
  
DbCloseAll()
return nil



/*=========================================*/
function Store_Acct()
/*=========================================*/
local cRef,wWindBuff
local nMaxrow := maxrow()+1, nMaxCol := maxcol()+1
local aFsize := {}
// Gauge variables
local nRecCtr := 0, hGauge, nPercent, nGaugeCtr:=1, wUpdate
local nGrsSls := 0, nCsSls := 0, nVdAmt := 0, nVdMgr := 0
local nSlsDsc := 0, nAddOn := 0, nRetrns := 0, nPckUp := 0, nOffLine := 0
local nLoan := 0, nCashDec := 0, nOther := 0, nBnkChq := 0
local nCrdtCrd := 0, nEmpChq := 0, nGftChq := 0, nEmpCrd := 0
local nNEmpCrd := 0, nPO := 0, nTotlAdd := 0, nGrossPls := 0
local nTotlVd  := 0, nTotlNeg := 0, nNetSls := 0, nDiff := 0
local nTotlTnd := 0.00, nCtr := 0, cDiff, dDate := ctod("")
local cOldPath, nTVoid := 0, nCancel := 0, nRefnd := 0, nTotlSls := 0
local nVdQty := 0, nVdMQty := 0, nTVQty := 0, nCQty := 0, nRetQty := 0
local nRefQty := 0, nDscQty := 0,nAddQty := 0, cName  := space(20)
local nSubtdsc := 0, nsubtQty:= 0, i:= 0, n := 0
local nCaSls := 0, nChrgPay := 0, cntrl_no := " "
local totCash := 0,  linectr := 0, lfirst := .t.
local nPesoTot := 0

//jzo04-15-98
local nPeso := 0, nDollar := 0, nXrate := 0, aCredit := {}, indx := 0, cTime
local nCrdtDollar:=0, nCrdtPeso:=0,aFrate := {}, j:=0

if !Getvalid()
  BUMMER() ; return nil 
endif 


if netuse("TERMINAL", DB_SHARED, NUM_SECONDS)
    set index to TERMINAL
else
   alert("File 'CASH.DBF' cannot be accessed",{"Quit"})
   return nil    
endif	 

if netuse("PLU", DB_SHARED, NUM_SECONDS)
    set index to PLU
endif	 

//jzo03-27-98
if netuse("NPLU", DB_SHARED, NUM_SECONDS)
    set index to NITEMCNT
endif	 


if netUse("CC",DB_SHARED,NUM_SECONDS)
    index  on CC->CC_001 to CC_001
endif

if netuse("CNTRL", DB_SHARED, NUM_SECONDS)
 SET INDEX TO CNTRL,CDATE
endif	 


//jzo04-15-98
if netUse("FC_HIST",DB_SHARED,NUM_SECONDS)
    set index to FC_HIST
endif

cOldPath := SET(_SET_PATH)

Message("Preparing Store Accountability Report ...")

SET ALTERNATE TO ".\"+STR_ACC
SET ALTERNATE ON
SET CONSOLE OFF
SET PRINTER OFF

window( 19, 1, 22, 60, CONFIRM_COLOR )


Do While PLU->(!Eof())
 
 if DatesOk(PLU->DATE) 
   nCtr += PLU->ICOUNT
 endif  

PLU->(DbSkip())
enddo
 

//jzo03-27-98
Do While NPLU->(!Eof())
 
 if DatesOk(NPLU->DATE) 
   nCtr += NPLU->ICOUNT
 endif  

NPLU->(DbSkip())
enddo


//jzo04-15-98

 for indx := 1 to 40

  aadd(aCredit,{" ",0,0})
 
 next indx
  
 DO WHILE CC->(!EOF())

   aCredit[1+n][1] := CC->CC_002
   n := n+1
   CC->(DBSKIP())
 ENDDO   

n:=0


Do While TERMINAL->(!Eof())  

  @ 1, 1 wsay " Creating Store Acct' Report, Please wait ..." //bing
  @ 2, 1 wsay " Terminal No.: " + TERMINAL->TERM


  // add counters if date is inclusive

  if DatesOk(TERMINAL->DATE) 
    dDate := TERMINAL->DATE
    cTime := TERMINAL->TIME           //jzo04-20-98
    nNetSls	  += TERMINAL->daily_a	
    nGrossPls     += TERMINAL->gross_a
    nCaSls        += TERMINAL->cash_a     
    nVdAmt        += TERMINAL->ivoid_a
    nVdMgr        += TERMINAL->mvoid_a
    nVdQty        += TERMINAL->ivoid_c
    nVdMQty       += TERMINAL->mvoid_c
    nTVoid        += TERMINAL->tvoid_a
    nTVQty        += TERMINAL->tvoid_c
    nCancel       += TERMINAL->cancl_a
    nCQty         += TERMINAL->cancl_c
    nSlsDsc       += TERMINAL->idisc_a
    nDscQty       += TERMINAL->idisc_c
    nSubtDsc       += TERMINAL->subtd_a
    nSubtQty       += TERMINAL->subtd_c
    nAddOn        += TERMINAL->addon_a
    nAddQty       += TERMINAL->addon_c
    nRetrns       += TERMINAL->retrn_a
    nRetQty       += TERMINAL->retrn_c
    nRefnd        += TERMINAL->refnd_a
    nRefQty        += TERMINAL->refnd_c
    nPckUp        += TERMINAL->pikup_a
    nOffLine      += TERMINAL->offln_a  
    nLoan         += TERMINAL->loan_a
    nOther        += TERMINAL->otinc_a
    nCashDec      += TERMINAL->recact_a


//jzo04-15-98
    nPeso       += TERMINAL->forcur_a
 
    aCredit[1][2] += TERMINAL->MISC1_C 
    aCredit[1][3] += TERMINAL->MISC1_A
    
    aCredit[2][2] += TERMINAL->MISC2_C 
    aCredit[2][3] += TERMINAL->MISC2_A 
    
    aCredit[3][2] += TERMINAL->MISC3_C 
    aCredit[3][3] += TERMINAL->MISC3_A 

    aCredit[4][2] += TERMINAL->MISC4_C 
    aCredit[4][3] += TERMINAL->MISC4_A
    
    aCredit[5][2] += TERMINAL->MISC5_C 
    aCredit[5][3] += TERMINAL->MISC5_A
    
    aCredit[6][2] += TERMINAL->MISC6_C 
    aCredit[6][3] += TERMINAL->MISC6_A
    
    aCredit[7][2] += TERMINAL->MISC7_C 
    aCredit[7][3] += TERMINAL->MISC7_A
    
    aCredit[8][2] += TERMINAL->MISC8_C 
    aCredit[8][3] += TERMINAL->MISC8_A
    
    aCredit[9][2] += TERMINAL->MISC9_C 
    aCredit[9][3] += TERMINAL->MISC9_A
    
    aCredit[10][2] += TERMINAL->MISC10_C 
    aCredit[10][3] += TERMINAL->MISC10_A
    
    aCredit[11][2] += TERMINAL->MISC11_C 
    aCredit[11][3] += TERMINAL->MISC11_A
    
    aCredit[12][2] += TERMINAL->MISC12_C 
    aCredit[12][3] += TERMINAL->MISC12_A
    
    aCredit[13][2] += TERMINAL->MISC13_C 
    aCredit[13][3] += TERMINAL->MISC13_A
    
    aCredit[14][2] += TERMINAL->MISC14_C 
    aCredit[14][3] += TERMINAL->MISC14_A
    
    aCredit[15][2] += TERMINAL->MISC15_C 
    aCredit[15][3] += TERMINAL->MISC15_A
    
    aCredit[16][2] += TERMINAL->MISC16_C 
    aCredit[16][3] += TERMINAL->MISC16_A
    
    aCredit[17][2] += TERMINAL->MISC17_C 
    aCredit[17][3] += TERMINAL->MISC17_A
    
    aCredit[18][2] += TERMINAL->MISC18_C 
    aCredit[18][3] += TERMINAL->MISC18_A
    
    aCredit[19][2] += TERMINAL->MISC19_C 
    aCredit[19][3] += TERMINAL->MISC19_A
    
    aCredit[20][2] += TERMINAL->MISC20_C 
    aCredit[20][3] += TERMINAL->MISC20_A
    

    aCredit[21][2] += TERMINAL->MISC21_C 
    aCredit[21][3] += TERMINAL->MISC21_A
    
    aCredit[22][2] += TERMINAL->MISC22_C 
    aCredit[22][3] += TERMINAL->MISC22_A 
    
    aCredit[23][2] += TERMINAL->MISC23_C 
    aCredit[23][3] += TERMINAL->MISC23_A 

    aCredit[24][2] += TERMINAL->MISC24_C 
    aCredit[24][3] += TERMINAL->MISC24_A
    
    aCredit[25][2] += TERMINAL->MISC25_C 
    aCredit[25][3] += TERMINAL->MISC25_A
    
    aCredit[26][2] += TERMINAL->MISC26_C 
    aCredit[26][3] += TERMINAL->MISC26_A
    
    aCredit[27][2] += TERMINAL->MISC27_C 
    aCredit[27][3] += TERMINAL->MISC27_A
    
    aCredit[28][2] += TERMINAL->MISC28_C 
    aCredit[28][3] += TERMINAL->MISC28_A
    
    aCredit[29][2] += TERMINAL->MISC29_C 
    aCredit[29][3] += TERMINAL->MISC29_A
    
    aCredit[30][2] += TERMINAL->MISC30_C 
    aCredit[30][3] += TERMINAL->MISC30_A
    
    aCredit[31][2] += TERMINAL->MISC31_C 
    aCredit[31][3] += TERMINAL->MISC31_A
    
    aCredit[32][2] += TERMINAL->MISC32_C 
    aCredit[32][3] += TERMINAL->MISC32_A
    
    aCredit[33][2] += TERMINAL->MISC33_C 
    aCredit[33][3] += TERMINAL->MISC33_A
    
    aCredit[34][2] += TERMINAL->MISC34_C 
    aCredit[34][3] += TERMINAL->MISC34_A
    
    aCredit[35][2] += TERMINAL->MISC35_C 
    aCredit[35][3] += TERMINAL->MISC35_A
    
    aCredit[36][2] += TERMINAL->MISC36_C 
    aCredit[36][3] += TERMINAL->MISC36_A
    
    aCredit[37][2] += TERMINAL->MISC37_C 
    aCredit[37][3] += TERMINAL->MISC37_A
    
    aCredit[38][2] += TERMINAL->MISC38_C 
    aCredit[38][3] += TERMINAL->MISC38_A
    
    aCredit[39][2] += TERMINAL->MISC39_C 
    aCredit[39][3] += TERMINAL->MISC39_A
    
    aCredit[40][2] += TERMINAL->MISC40_C 
    aCredit[40][3] += TERMINAL->MISC40_A

    nCrdtPeso      += TERMINAL->misc1_a + TERMINAL->misc2_a +TERMINAL->misc3_a +;
                    TERMINAL->misc4_a + TERMINAL->misc5_a +TERMINAL->misc6_a +;
                    TERMINAL->misc7_a + TERMINAL->misc8_a +TERMINAL->misc9_a +;
                    TERMINAL->misc10_a + TERMINAL->misc11_a +TERMINAL->misc12_a +;
                    TERMINAL->misc13_a +TERMINAL->misc14_a +TERMINAL->misc15_a +;
                    TERMINAL->misc16_a +TERMINAL->misc17_a +TERMINAL->misc18_a +;
                    TERMINAL->misc19_a +TERMINAL->misc20_a 


    nCrdtDollar     += TERMINAL->misc21_a + TERMINAL->misc22_a +TERMINAL->misc23_a +;
                    TERMINAL->misc24_a + TERMINAL->misc25_a +TERMINAL->misc26_a +;
                    TERMINAL->misc27_a + TERMINAL->misc28_a +TERMINAL->misc29_a +;
                    TERMINAL->misc30_a + TERMINAL->misc31_a +TERMINAL->misc32_a +;
                    TERMINAL->misc33_a +TERMINAL->misc34_a +TERMINAL->misc35_a +;
                    TERMINAL->misc36_a +TERMINAL->misc37_a +TERMINAL->misc38_a +;
                    TERMINAL->misc39_a +TERMINAL->misc40_a 

    nDollar += TERMINAL->MISC50_A
  endif   
    
  
  TERMINAL->(DbSkip())
enddo

do while FC_HIST->(!eof())
  if FC_HIST->DATE == dDate      
     aadd(aFrate,round(FC_HIST->NEWRATE,2))
  endif
  FC_HIST->(dbskip())
enddo     

  FC_HIST->(dbgotop())
  while FC_HIST->(!eof())
    nXrate := round(FC_HIST->NEWRATE,2)  //jlp.
    if FC_HIST->DATE == dDate
       nXrate := round(FC_HIST->NEWRATE,2)  //jlp.
       exit
    endif
    FC_HIST->(dbskip())
  enddo

  // total counters
  nTotlAdd           := nOther + nAddon
  nGrsSls            := nGrossPls - nTotlAdd
  nTotlVd            := nVdAmt + nVdMgr + nCancel
  nTotlNeg           := nSlsDsc + nSubtdsc + nRetrns + nRefnd + nTVoid
  nTotlSls           := nGrsSls - nTotlNeg
  totcash            := nCaSls - nLoan + nPckup + nOffline

  nTotlTnd           := nCaSls + nDollar + nCrdtDollar

  // report format
  ? CHR(15)
  ? MARGIN + "Run Date : " + dtoc(Date())
  ? CHR(18)
  ? MARGIN + space(31) + SYS_NAME
  ? MARGIN + space(24) + "Store Accountability Report"
  ?
  ?
  CNTRL->(DbSetOrderto(2))
  CNTRL->(DbSeek(dtos(dStartDate)))
  cntrl_no := " "
  while DatesOk(CNTRL->DATE)
     cntrl_no += alltrim(str(CNTRL->CONTRL_NO)) + ","
     dDate := CNTRL->DATE
     CNTRL->(DBSKIP())
  ENDDO
  CNTRL->(DbSetOrderto(1))
  ? MARGIN + "CONTROL NO. : " + cntrl_no + " " + dtoc(dDate)

  ?
  ? MARGIN + "EXCH. RATE:   $1.00 - " + alltrim(str(nXrate))

  for j:=1 to len(aFrate)
      ?? ", "+ alltrim(trans(aFrate[j],"99,999,999.99"))
  next j  
  
  ?
  ? MARGIN + "No. of Items Sold  :          " + trans(nCtr,"999999")
  ? 
  ? MARGIN + "GROSS SALES[DEPT SALES]                 " + trans(nGrsSls,"99,999,999.99")
  ?
  ? MARGIN + "GROSS PLUS[GROSS SALES]                 " + trans(nGrossPls,"99,999,999.99")
  ? MARGIN + "Less   : VOID ENTRIES         "
  ? MARGIN + "          Void Line Items               " + trans(nVdAmt,"99,999,999.99") 
  ?? space(4) + "(" + trans(nVdQty,"9999") + ")"                   
  ? MARGIN + "          Manager Void          )       " + trans(nVdMgr,"99,999,999.99") 
  ?? space(4) + "(" + trans(nVdMQty,"9999") + ")"                    
  ? MARGIN + "          Void Total [Tran. Cancel]     " + trans(nCancel,"99,999,999.99")
  ?? space(4) + "(" + trans(nCQty,"9999") + ")"                    
  ? MARGIN + "                               ----------------------"
  ? MARGIN + "      [Total Void Entries               " + trans(nTotlVd,"99,999,999.99")  +"]"
  ?
  ? MARGIN + " Less  : Negative Entries"
  ? MARGIN + "         Returns                        " + trans(nRetrns,"99,999,999.99")
  ?? space(4) + "(" + trans(nRetQty,"9999") + ")"                    
  ? MARGIN + "         Refund                         " + trans(nRefnd,"99,999,999.99") 
  ?? space(4) + "(" + trans(nRefQty,"9999") + ")"                    
  ? MARGIN + "         Sales Discount                 " + trans(nSlsDsc+nSubtDsc,"99,999,999.99")
  ?? space(4) + "(" + trans(nDscQty+nSubTQty,"9999") + ")"          
  ? MARGIN + "         Void Previous [Tran. Void]     " + trans(nTVoid,"99,999,999.99")
  ?? space(4) + "(" + trans(nTVQty,"9999") + ")"                              
  ? MARGIN + "                               ----------------------"
  ? MARGIN + "       Total Negative Entries           " + trans(nTotlNeg,"99,999,999.99")
  ?
  ? MARGIN + "NET SALES [DAILY SALES]                 " + trans(nNetSls,"99,999,999.99")

  ?
  ? 
  ? MARGIN + "TENDER(s)               " 
  ? MARGIN + "         Dollar                         " + trans(nCaSls,"99,999,999.99")
  ? MARGIN + "         Peso                           " + trans(nDollar,"99,999,999.99") + " - P " + trans(nPeso,"99,999,999.99")
  ? MARGIN + "  CARD:                                 " 
  nPesoTot := nPeso

for indx := 1 to len(aCredit)
     if aCredit[indx][2] <> 0 .or. aCredit[indx][3] <> 0 
     
      if aCredit[indx][1] == " "
        ? MARGIN +"         CREDIT CARD "+alltrim(str(indx)) +space(40-(9+len("CREDIT CARD "+alltrim(str(indx)))))
      else
        ? MARGIN + space(9) + aCredit[indx][1] +space(40-(9+len(aCredit[indx][1])))
      endif 
      ?? trans(aCredit[indx][3],"99,999,999.99") 
	 ?? " - P " + trans(aCredit[indx][3]*nXrate,"99,999,999.99")
	 nTotlTnd += aCredit[indx][3]
      nPesoTot += aCredit[indx][3] * nXrate
      linectr += 1    
     endif 
  if linectr == 50
     ? chr(12)
     lfirst := .t.
  endif

next indx

  ? MARGIN + "                               ----------------------   ---------------"
  ? MARGIN + "TOTAL TENDER                            " + trans(nTotlTnd,"99,999,999.99")
  ?? "     " + trans(nPesoTot,"99,999,999.99")
  ?
  ?
  ?
//jzo04-18-98  ? MARGIN + "Prepared By : _____________________   Reviewed By : _____________________"
 
  ? chr(12)  

CLOSE ALTERNATE
SET ALTERNATE OFF
SET CONSOLE ON

aFsize := directory(STR_ACC)

// check if repot file is < 64K
// direct to printer if greater   

if aFsize[1][2] < MAX_SIZE

  cReport:=memoread(STR_ACC)
  if !empty(cReport)
   if !setmode(50,80) .and. !setmode(43,80)
      setmode(nMaxrow,nMaxcol)
   else
      _logo()   
   endif       
   Message("Use cursor keys to navigate, press F10 to print, "+ ;
              "Esc to abort.")
   wWindBuff:=OpenWindow(1,2,maxrow()-1,maxcol()-2,"Store Accountability Report") //bing
   MemoEdit(cReport,2,3,maxrow()-2,maxcol()-3,.f.,'Editor2Func',122 )
   CloseWindow(wWindBuff)
   setcursor(SC_NONE)
   setmode(nMaxrow,nMaxcol)
  endif
 
else

 if alert("Report too large to edit, will be directed to printer", {"Print","Quit"}) == 1 
    Direct2Prn(STR_ACC) 
 endif  
 
endif  


cReport := "" //Free memory      
  
DbCloseAll()
return nil


/*=========================================*/
function Cash_IAcct()
/*=========================================*/
local cRef,wWindBuff,cStr
local nMaxrow := maxrow()+1, nMaxCol := maxcol()+1
local aFsize := {}
// Gauge variables
local nRecCtr := 0, hGauge, nPercent, nGaugeCtr:=1, wUpdate
local nGrsSls := 0, nCsSls := 0, nVdAmt := 0, nVdMgr := 0
local nSlsDsc := 0, nAddOn := 0, nRetrns := 0, nPckUp := 0, nOffLine := 0
local nLoan := 0, nCashDec := 0, nOther := 0, nBnkChq := 0
local nCrdtCrd := 0, nEmpChq := 0, nGftChq := 0, nEmpCrd := 0
local nNEmpCrd := 0, nPO := 0, nTotlAdd := 0, nGrossPls := 0
local nTotlVd  := 0, nTotlNeg := 0, nNetSls := 0, nDiff := 0
local nTotlTnd := 0.00, nCtr := 0, cDiff, dDate := ctod("")
local cOldPath, nTVoid := 0, nCancel := 0, nRefnd := 0, nTotlSls := 0
local nVdQty := 0, nVdMQty := 0, nTVQty := 0, nCQty := 0, nRetQty := 0, nAddQty := 0
local nRefQty := 0, nDscQty := 0,cterm := space(3), aCcd := {}, i := 0, n := 0
local vBrowse, cCode, cName := space(20), linectr := 0, lfirst := .t.
local bankname := space(20), nSubtdsc := 0, nsubtQty := 0, nCaSls := 0, nChrgPay := 0
local totCash := 0, aTerm:={}, nTotCcd := 0, cntrl_no := " "
local nPesoTot := 0

//jzo04-15-98
local nPeso := 0, nDollar := 0, nXrate := 0, aCredit := {}, indx := 0, cTime
local nCrdtDollar:=0, nCrdtPeso:=0, aFrate := {}, j:=0
   SET CURSOR ON
   vBrowse := OpenWindow(15,30,17,50,"")
   @ 16,31 say "Cashier Code: "Get cTerm Pict "999"
   read
   SET CURSOR OFF
   CloseWindow(vBrowse)

   cTerm := padl(alltrim(cTerm),3,"0") 


if !Getvalid()
  BUMMER() ; return nil 
endif 


if netuse("CASH", DB_SHARED, NUM_SECONDS)
    set index to CAS
else
   alert("File 'CASH.DBF' cannot be accessed",{"Quit"})
   return nil    
endif	 

if netuse("PLU", DB_SHARED, NUM_SECONDS)
    set index to PLU
endif	 

//jzo04-15-98
if netUse("FC_HIST",DB_SHARED,NUM_SECONDS)
    set index to FC_HIST
endif


if netuse("CNTRL", DB_SHARED, NUM_SECONDS)
   SET INDEX TO CNTRL,CDATE
endif	 

if netUse("CC",DB_SHARED,NUM_SECONDS)
    index on CC->CC_001 to CC_001
endif


cOldPath := SET(_SET_PATH)

Message("Preparing Cashier Accountability Report ...")

SET ALTERNATE TO ".\"+CASH_ACC
SET ALTERNATE ON
SET CONSOLE OFF
SET PRINTER OFF

window( 19, 1, 22, 60, CONFIRM_COLOR )

//jzo04-15-98

 for indx := 1 to 40

  aadd(aCredit,{" ",0,0})
 
 next indx
  
 DO WHILE CC->(!EOF())

   aCredit[1+n][1] := CC->CC_002
   n := n+1
   CC->(DBSKIP())
 ENDDO   

n:=0

Do While CASH->(!Eof())  

  @ 1, 1 wsay " Creating Cashier Acct' Report, Please wait ..."
  @ 2, 1 wsay " Cashier Code: " + CASH->CODE


  // add counters if date is inclusive

  if DatesOk(CASH->DATE) .and. CASH->CODE == cTerm .and. cash->daily_a != 0 //bing

    if ( ( n:= aScan(aTerm,{|x| x == val(CASH->TERM) } ) ) == 0)
    
      aAdd(aTerm,val(CASH->TERM))
      
    endif 
    dDate := CASH->DATE
    cTime := CASH->TIME //jzo04-20-98
    cNaME := cash->name
    nNetSls	  += CASH->daily_a	
    nGrossPls     += CASH->gross_a
    nCaSls        += CASH->cash_a     
    nVdAmt        += CASH->ivoid_a
    nVdMgr        += CASH->mvoid_a
    nVdQty        += CASH->ivoid_c
    nVdMQty       += CASH->mvoid_c
    nTVoid        += CASH->tvoid_a
    nTVQty        += CASH->tvoid_c
    nCancel       += CASH->cancl_a
    nCQty         += CASH->cancl_c
    nSlsDsc       += CASH->idisc_a
    nDscQty       += CASH->idisc_c
    nSubtDsc       += CASH->subtd_a
    nsubtQty       += CASH->subtd_c
    nAddOn        += CASH->addon_a
    nAddQty       += CASH->addon_c
    nRetrns       += CASH->retrn_a
    nRetQty       += CASH->retrn_c 
    nRefnd        += CASH->refnd_a
    nRefQty       += CASH->refnd_c 
    nPckUp        += CASH->pikup_a
    nOffLine      += CASH->offln_a  
    nLoan         += CASH->loan_a
    nCashDec      += CASH->recact_a
    nOther        += CASH->otinc_a

//jzo04-15-98
    nPeso       += CASH->forcur_a
 
    aCredit[1][2] += CASH->MISC01_C 
    aCredit[1][3] += CASH->MISC01_A
    
    aCredit[2][2] += CASH->MISC02_C 
    aCredit[2][3] += CASH->MISC02_A 
    
    aCredit[3][2] += CASH->MISC03_C 
    aCredit[3][3] += CASH->MISC03_A 

    aCredit[4][2] += CASH->MISC04_C 
    aCredit[4][3] += CASH->MISC04_A
    
    aCredit[5][2] += CASH->MISC05_C 
    aCredit[5][3] += CASH->MISC05_A
    
    aCredit[6][2] += CASH->MISC06_C 
    aCredit[6][3] += CASH->MISC06_A
    
    aCredit[7][2] += CASH->MISC07_C 
    aCredit[7][3] += CASH->MISC07_A
    
    aCredit[8][2] += CASH->MISC08_C 
    aCredit[8][3] += CASH->MISC08_A
    
    aCredit[9][2] += CASH->MISC09_C 
    aCredit[9][3] += CASH->MISC09_A
    
    aCredit[10][2] += CASH->MISC10_C 
    aCredit[10][3] += CASH->MISC10_A
    
    aCredit[11][2] += CASH->MISC11_C 
    aCredit[11][3] += CASH->MISC11_A
    
    aCredit[12][2] += CASH->MISC12_C 
    aCredit[12][3] += CASH->MISC12_A
    
    aCredit[13][2] += CASH->MISC13_C 
    aCredit[13][3] += CASH->MISC13_A
    
    aCredit[14][2] += CASH->MISC14_C 
    aCredit[14][3] += CASH->MISC14_A
    
    aCredit[15][2] += CASH->MISC15_C 
    aCredit[15][3] += CASH->MISC15_A
    
    aCredit[16][2] += CASH->MISC16_C 
    aCredit[16][3] += CASH->MISC16_A
    
    aCredit[17][2] += CASH->MISC17_C 
    aCredit[17][3] += CASH->MISC17_A
    
    aCredit[18][2] += CASH->MISC18_C 
    aCredit[18][3] += CASH->MISC18_A
    
    aCredit[19][2] += CASH->MISC19_C 
    aCredit[19][3] += CASH->MISC19_A
    
    aCredit[20][2] += CASH->MISC20_C 
    aCredit[20][3] += CASH->MISC20_A
    

    aCredit[21][2] += CASH->MISC21_C 
    aCredit[21][3] += CASH->MISC21_A
    
    aCredit[22][2] += CASH->MISC22_C 
    aCredit[22][3] += CASH->MISC22_A 
    
    aCredit[23][2] += CASH->MISC23_C 
    aCredit[23][3] += CASH->MISC23_A 

    aCredit[24][2] += CASH->MISC24_C 
    aCredit[24][3] += CASH->MISC24_A
    
    aCredit[25][2] += CASH->MISC25_C 
    aCredit[25][3] += CASH->MISC25_A
    
    aCredit[26][2] += CASH->MISC26_C 
    aCredit[26][3] += CASH->MISC26_A
    
    aCredit[27][2] += CASH->MISC27_C 
    aCredit[27][3] += CASH->MISC27_A
    
    aCredit[28][2] += CASH->MISC28_C 
    aCredit[28][3] += CASH->MISC28_A
    
    aCredit[29][2] += CASH->MISC29_C 
    aCredit[29][3] += CASH->MISC29_A
    
    aCredit[30][2] += CASH->MISC30_C 
    aCredit[30][3] += CASH->MISC30_A
    
    aCredit[31][2] += CASH->MISC31_C 
    aCredit[31][3] += CASH->MISC31_A
    
    aCredit[32][2] += CASH->MISC32_C 
    aCredit[32][3] += CASH->MISC32_A
    
    aCredit[33][2] += CASH->MISC33_C 
    aCredit[33][3] += CASH->MISC33_A
    
    aCredit[34][2] += CASH->MISC34_C 
    aCredit[34][3] += CASH->MISC34_A
    
    aCredit[35][2] += CASH->MISC35_C 
    aCredit[35][3] += CASH->MISC35_A
    
    aCredit[36][2] += CASH->MISC36_C 
    aCredit[36][3] += CASH->MISC36_A
    
    aCredit[37][2] += CASH->MISC37_C 
    aCredit[37][3] += CASH->MISC37_A
    
    aCredit[38][2] += CASH->MISC38_C 
    aCredit[38][3] += CASH->MISC38_A
    
    aCredit[39][2] += CASH->MISC39_C 
    aCredit[39][3] += CASH->MISC39_A
    
    aCredit[40][2] += CASH->MISC40_C 
    aCredit[40][3] += CASH->MISC40_A
    
    
    // wala pa ngayon
/*jzo04-20-98
    nBnkChq       += CASH->misc18_a + CASH->misc19_a +CASH->misc20_a +;
                    CASH->misc21_a + CASH->misc22_a +CASH->misc23_a +;
                    CASH->misc24_a + CASH->misc25_a +CASH->misc26_a +;
                    CASH->misc27_a + CASH->misc28_a
*/

    nCrdtPeso      += CASH->misc01_a + CASH->misc02_a +CASH->misc03_a +;
                    CASH->misc04_a + CASH->misc05_a +CASH->misc06_a +;
                    CASH->misc07_a + CASH->misc08_a +CASH->misc09_a +;
                    CASH->misc10_a + CASH->misc11_a +CASH->misc12_a +;
                    CASH->misc13_a +CASH->misc14_a +CASH->misc15_a +;
                    CASH->misc16_a +CASH->misc17_a +CASH->misc18_a +;
                    CASH->misc19_a +CASH->misc20_a 


    nCrdtDollar     += CASH->misc21_a + CASH->misc22_a +CASH->misc23_a +;
                    CASH->misc24_a + CASH->misc25_a +CASH->misc26_a +;
                    CASH->misc27_a + CASH->misc28_a +CASH->misc29_a +;
                    CASH->misc30_a + CASH->misc31_a +CASH->misc32_a +;
                    CASH->misc33_a +CASH->misc34_a +CASH->misc35_a +;
                    CASH->misc36_a +CASH->misc37_a +CASH->misc38_a +;
                    CASH->misc39_a +CASH->misc40_a 

    nDollar += CASH->MISC50_A

/*jzo04-20-98
    nEmpChq       += CASH->misc30_a
    nGftChq       += CASH->misc29_a
    nEmpCrd       += CASH->misc14_a
    nNEmpCrd      += CASH->misc15_a 
    nPO           += CASH->misc16_a + CASH->misc17_a
*/    
  endif   
    
  
  CASH->(DbSkip())
enddo

//jzo04-15-98
do while FC_HIST->(!eof())
  nXrate:=round(FC_HIST->NEWRATE,2)
  if FC_HIST->DATE == dDate  //.and. val(FC_HIST->TIME)==cTime
     aadd(aFrate,round(FC_HIST->NEWRATE,2))
     nXrate:=round(FC_HIST->NEWRATE,2)
  endif
  FC_HIST->(dbskip())
enddo     

if len(aFrate) == 0
 FC_HIST->(DBGOBOTTOM())
 aadd(aFrate,round(FC_HIST->NEWRATE,2))
endif


  // total counters
  nTotlAdd           := nOther + nAddon
  nGrsSls            := nGrossPls - nTotlAdd
  nTotlVd            := nVdAmt + nVdMgr + nCancel
  nTotlNeg           := nSlsDsc + nSubtdsc + nRetrns + nRefnd + nTVoid
  nTotlSls           := nGrsSls - nTotlNeg
  totcash            := nCaSls - nLoan + nPckup + nOffline
/*jzo04-15-98
  nTotlTnd           := nCaSls + nBnkChq + nCrdtCrd - nOther;  //bing
                        + nEmpChq + nGftChq + nEmpCrd ;
                        + nNEmpCrd + nPO // - (nAddon + nRefnd)
*/

//jzo04-15-98
//  nDollar            := nPeso / nXrate

  nTotlTnd           := nCaSls + nDollar + nCrdtDollar
  cCode := ""

  for i := 1 to len(aTerm)
      cCode += " " + padl(aterm[i],2,"0")
  next                      


  // report format
  ? chr(15)
  ? MARGIN + "Run Date : " + dtoc(Date())
  ? chr(18)
  ?
  ? MARGIN + space(30) + SYS_NAME
  ? MARGIN + space(22) + "Cashier Accountability Report"
  ?
  ?
 CNTRL->(DbSetOrderto(2))
  CNTRL->(DbSeek(dtos(dStartDate)))
  cntrl_no := " "
  while DatesOk(CNTRL->DATE)
     cntrl_no += alltrim(str(CNTRL->CONTRL_NO)) + ","
     dDate := CNTRL->DATE
     CNTRL->(DBSKIP())
  ENDDO
  CNTRL->(DbSetOrderto(1))
  ? MARGIN + "CONTROL NO. : " + cntrl_no + " " + dtoc(dDate)
  ?
  ? MARGIN + "CASHIER ID  : " + cTerm + "  " + cName 
  ?
  ? MARGIN + "EXCH. RATE:   $1.00 - " //+ alltrim(str(nXrate))

//jzo04-21-98
  if len(aFrate) == 1
    ??alltrim(trans(aFrate[1],"99,999,999.99"))
  else    
  for j:=1 to len(aFrate)
    ??alltrim(trans(aFrate[j],"99,999,999.99")) + ", "
  next j  
  endif
  
  ?
  ? MARGIN + "Terminal No. "+ cCode
  ?
  ? 
  ? MARGIN + "GROSS SALES[DEPT SALES]                 " + trans(nGrsSls,"99,999,999.99")

/*jzo04-15-98
  ? MARGIN + " Plus  : Other Income                   " + trans(nOther,"99,999,999.99")
  ? MARGIN + "         Add-On(s)                      " + trans(nAddOn,"99,999,999.99")
  ? MARGIN + "                               ----------------------"
  ? MARGIN + " Total Negative Entries                 " + trans(nTotlAdd,"99,999,999.99")
*/

  ?
  ? MARGIN + "GROSS PLUS[GROSS SALES]                 " + trans(nGrossPls,"99,999,999.99")
  ? MARGIN + "Less   : VOID ENTRIES         "
  ? MARGIN + "          Void Line Items               " + trans(nVdAmt,"99,999,999.99") 
  ?? space(4) + "(" + trans(nVdQty,"9999") + ")"                   
  ? MARGIN + "         Manager Void                   " + trans(nVdMgr,"99,999,999.99") 
  ?? space(4) + "(" + trans(nVdMQty,"9999") + ")"                    
  ? MARGIN + "          Void Total [Tran. Cancel]     " + trans(nCancel,"99,999,999.99")
  ?? space(4) + "(" + trans(nCQty,"9999") + ")"                    
  ? MARGIN + "                               ----------------------"
  ? MARGIN + "      [Total Void Entries               " + trans(nTotlVd,"99,999,999.99")  +"]"
  ?
  ? MARGIN + " Less  : Negative Entries"
  ? MARGIN + "         Returns                        " + trans(nRetrns,"99,999,999.99")
  ?? space(4) + "(" + trans(nRetQty,"9999") + ")"                    
  ? MARGIN + "         Refund                         " + trans(nRefnd,"99,999,999.99") 
  ?? space(4) + "(" + trans(nRefQty,"9999") + ")"                    
  ? MARGIN + "         Sales Discount                 " + trans(nSlsDsc+nSubtDsc,"99,999,999.99")
  ?? space(4) + "(" + trans(nDscQty+nSubTQty,"9999") + ")"          
  ? MARGIN + "         Void Previous [Tran. Void]     " + trans(nTVoid,"99,999,999.99")
  ?? space(4) + "(" + trans(nTVQty,"9999") + ")"                              
  ? MARGIN + "                               ----------------------"
  ? MARGIN + "       Total Negative Entries           " + trans(nTotlNeg,"99,999,999.99")
  ?

/*jzo04-14-98
  ? MARGIN + "TOTAL SALES[DAILY SALES]                " + trans(nNetSls,"99,999,999.99")
  ? MARGIN + " Add  : Loans                           " + trans(nLoan,"99,999,999.99") 
  ? MARGIN + " Less : Pick-Up                         " + trans(nPckUp,"99,999,999.99")
  ? MARGIN + "       [(Negative Cash)                 " + trans(nOffLine,"99,999,999.99") + "]"
  ? MARGIN + "                               ----------------------"
  ? MARGIN + "NET SALES                               " + trans(nNetsls+nLoan-nPckUp,"99,999,999.99")
  ? MARGIN + "CASH COUNT DECLARATION                  " + trans(nCashDec,"99,999,999.99")
  ? MARGIN + "                               ----------------------"
  ? MARGIN + "(SHORT)/OVER                            " + trans(nCashDec-(nNetsls+nLoan-nPckUp),"@( 99,999,999.99")
  ?
*/
  ? MARGIN + "NET SALES [DAILY SALES]                 " + trans(nNetSls,"99,999,999.99")
//jzo04-18-98   ? chr(12)


  ?
  ? 
  ? MARGIN + "TENDER(s)               " 
  ? MARGIN + "         Dollar                         " + trans(nCaSls,"99,999,999.99")
  ?
  ? MARGIN + "         Peso                           " + trans(nDollar,"99,999,999.99") + " - P " + trans(nPeso,"99,999,999.99")
  ? MARGIN + "  CARD:                                 " 
  nPesoTot := nPeso

//jzo04-15-98
for indx := 1 to 20
     if aCredit[indx][2] <> 0 .or. aCredit[indx][3] <> 0 
     
      if aCredit[indx][1] == " "
        ? MARGIN +"         CREDIT CARD "+alltrim(str(indx)) +space(40-(9+len("CREDIT CARD "+alltrim(str(indx)))))
      else
        ? MARGIN + space(9) + aCredit[indx][1] +space(40-(9+len(aCredit[indx][1])))
      endif 
//      ?? space(7) + trans(aCredit[indx][2],"9,999,999")
//      ?? trans(aCredit[indx+20][3],"99,999,999.99") + " - P " + trans(aCredit[indx][3],"99,999,999.99")
        ?? trans(aCredit[indx][3],"99,999,999.99")
        ?? " - P " + trans(aCredit[indx][3]*nXrate,"99,999,999.99")
	   nTotlTnd += aCredit[indx][3]
	   nPesoTot += aCredit[indx][3] * nXrate
      linectr += 1    
     endif 
  if linectr == 50
     ? chr(12)
     lfirst := .t.
  endif

next indx

  ? MARGIN + "                               ----------------------   ---------------"
  ? MARGIN + "TOTAL TENDER                            " + trans(nTotlTnd,"99,999,999.99")
  ?? "     " + trans(nPesoTot,"99,999,999.99")
  ?
  ?
  ?
//jzo04-18-98  ? MARGIN + "Prepared By : _____________________   Reviewed By : _____________________"
 
  ? chr(12)  

CLOSE ALTERNATE
SET ALTERNATE OFF
SET CONSOLE ON

aFsize := directory(CASH_ACC)

// check if repot file is < 64K
// direct to printer if greater   

if aFsize[1][2] < MAX_SIZE

  cReport:=memoread(CASH_ACC)
  if !empty(cReport)
   if !setmode(50,80) .and. !setmode(43,80)
      setmode(nMaxrow,nMaxcol)
   else
      _logo()   
   endif       
   Message("Use cursor keys to navigate, press F10 to print, "+ ;
              "Esc to abort.")
   wWindBuff:=OpenWindow(1,2,maxrow()-1,maxcol()-2,"Cashier Accountability Report")
   MemoEdit(cReport,2,3,maxrow()-2,maxcol()-3,.f.,'Editor2Func',122 )
   CloseWindow(wWindBuff)
   setcursor(SC_NONE)
   setmode(nMaxrow,nMaxcol)
  endif
 
else

 if alert("Report too large to edit, will be directed to printer", {"Print","Quit"}) == 1 
    Direct2Prn(CASH_ACC) 
 endif  
 
endif  


cReport := "" //Free memory      
  
DbCloseAll()
return nil


/*=========================================*/
function Cash_All()
/*=========================================*/
local cRef,wWindBuff
local nMaxrow := maxrow()+1, nMaxCol := maxcol()+1
local aFsize := {}
// Gauge variables
local nRecCtr := 0, hGauge, nPercent, nGaugeCtr:=1, wUpdate
local nGrsSls := 0, nCsSls := 0, nVdAmt := 0, nVdMgr := 0
local nSlsDsc := 0, nAddOn := 0, nRetrns := 0, nPckUp := 0, nOffLine := 0
local nLoan := 0, nCashDec := 0, nOther := 0, nBnkChq := 0
local nCrdtCrd := 0, nEmpChq := 0, nGftChq := 0, nEmpCrd := 0
local nNEmpCrd := 0, nPO := 0, nTotlAdd := 0, nGrossPls := 0
local nTotlVd  := 0, nTotlNeg := 0, nNetSls := 0, nDiff := 0
local nTotlTnd := 0.00, nCtr := 0, cDiff, dDate := ctod("")
local cOldPath, nTVoid := 0, nCancel := 0, nRefnd := 0, nTotlSls := 0
local nVdQty := 0, nVdMQty := 0, nTVQty := 0, nCQty := 0, nRetQty := 0
local nRefQty := 0, nDscQty := 0, nAddQty := 0, aCcd := {}
local cName := space(20), linectr := 0, lfirst := .t., i := 0,n := 0
local nSubtdsc := 0, nsubtQty:= 0, nCaSls := 0, nChrgPay := 0
local totCash := 0, nTotCcd := 0,cCode:=space(3) ,cterm,cCName:= space(20),aTerm := {}
local prevcash := space(3), cntrl_no := " "
local nPesoTot := 0

//jzo04-15-98
local nPeso := 0, nDollar := 0, nXrate := 0, aCredit := {}, indx := 0, cTime
local nCrdtDollar:=0, nCrdtPeso:=0,  aFrate := {}, j:=0

if !Getvalid()
  BUMMER() ; return nil 
endif 


if netuse("CASH", DB_SHARED, NUM_SECONDS)
    set index to CAS
else
   alert("File 'CASH.DBF' cannot be accessed",{"Quit"})
   return nil    
endif	 


/*if netuse("PLU", DB_SHARED, NUM_SECONDS)
    set index to PLU
endif	  */


if netUse("CC",DB_SHARED,NUM_SECONDS)
    index  on CC->CC_001 to CC_001
endif

if netuse("CNTRL", DB_SHARED, NUM_SECONDS)
   SET INDEX TO CNTRL,CDATE
endif	 

//jzo04-17-98
if netUse("FC_HIST",DB_SHARED,NUM_SECONDS)
    set index to FC_HIST
endif

cOldPath := SET(_SET_PATH)

Message("Preparing Cashier Accountability Report ...")

SET ALTERNATE TO ".\"+CASH_ACC
SET ALTERNATE ON
SET CONSOLE OFF
SET PRINTER OFF

window( 19, 1, 22, 60, CONFIRM_COLOR )

//jzo04-17-98

 for indx := 1 to 40

  aadd(aCredit,{" ",0,0})
 
 next indx
  
 DO WHILE CC->(!EOF())

   aCredit[1+n][1] := CC->CC_002
   n := n+1
   CC->(DBSKIP())
 ENDDO   

n:=0


/* Do While PLU->(!Eof())
 
 if DatesOk(PLU->DATE) 
   nCtr += PLU->ICOUNT
 endif  

PLU->(DbSkip())
enddo */
 
prevcash := CASH->CODE

Do While CASH->(!Eof())  

  @ 1, 1 wsay " Creating Cashier Acct' Report, Please wait ..."
  @ 2, 1 wsay " Cashier Code: " + CASH->CODE


  if  CASH->DAILY_A == 0
      CASH->(DbSkip())
      loop   
  endif
  // add counters if date is inclusive

  if DatesOk(CASH->DATE)  
   if prevcash != CASH->CODE .and. nGrsSls <> 0

   cTerm := ""

  for i := 1 to len(aTerm)
      cTerm += " " + padl(aterm[i],2,"0")
  next                      

        // report format
  ? CHR(15)
  ? MARGIN + "Run Date : " + dtoc(Date())
  ? CHR(18)
  ? MARGIN + space(32) + SYS_NAME
  ? MARGIN + space(24) + "Cashier Accountability Report"
  ?
  ?
 CNTRL->(DbSetOrderto(2))
  CNTRL->(DbSeek(dtos(dStartDate)))
  cntrl_no := " "
  while DatesOk(CNTRL->DATE)
     cntrl_no += alltrim(str(CNTRL->CONTRL_NO)) + ","
     dDate := CNTRL->DATE
     CNTRL->(DBSKIP())
  ENDDO
  CNTRL->(DbSetOrderto(1))
  ? MARGIN + "CONTROL NO. : " + cntrl_no + " " + dtoc(dDate)
  ?
  ? MARGIN + "CASHIER NO. : " + prevcash + "  " + cCName  
  ?
  ? MARGIN + "EXCH. RATE:   $1.00 - "  //+ alltrim(str(nXrate))

//jzo04-21-98
  if len(aFrate) == 1
    ??alltrim(trans(aFrate[1],"99,999,999.99"))
    nXrate := aFrate[1]
  else    
  for j:=1 to len(aFrate)
    ??alltrim(trans(aFrate[j],"99,999,999.99")) + ", "
    nXrate := aFrate[j]
  next j  
  endif
  
  ?  
  ? MARGIN + "TERMINAL NO. " + cterm
  ?
//  ? MARGIN + "No. of Items Sold  :          " + trans(nCtr,"999999")
  ? 
  ? MARGIN + "GROSS SALES[DEPT SALES]                 " + trans(nGrsSls,"99,999,999.99")
/*jzo04-17-98
  ? MARGIN + " Plus  : Other Income                   " + trans(nOther,"99,999,999.99")
  ? MARGIN + "         Add-On(s)                      " + trans(nAddOn,"99,999,999.99")
  ? MARGIN + "                               ----------------------"
  ? MARGIN + " Total Negative Entries                 " + trans(nTotlAdd,"99,999,999.99")
*/
  ?
  ? MARGIN + "GROSS PLUS[GROSS SALES]                 " + trans(nGrossPls,"99,999,999.99")
  ? MARGIN + "Less   : VOID ENTRIES         "
  ? MARGIN + "          Void Line Items               " + trans(nVdAmt,"99,999,999.99") 
  ?? space(4) + "(" + trans(nVdQty,"9999") + ")"                   
  ? MARGIN + "         Manager Void                   " + trans(nVdMgr,"99,999,999.99") 
  ?? space(4) + "(" + trans(nVdMQty,"9999") + ")"                    
  ? MARGIN + "          Void Total [Tran. Cancel]     " + trans(nCancel,"99,999,999.99")
  ?? space(4) + "(" + trans(nCQty,"9999") + ")"                    
  ? MARGIN + "                               ----------------------"
  ? MARGIN + "      [Total Void Entries               " + trans(nTotlVd,"99,999,999.99")  +"]"
  ?
  ? MARGIN + " Less  : Negative Entries"
  ? MARGIN + "         Returns                        " + trans(nRetrns,"99,999,999.99")
  ?? space(4) + "(" + trans(nRetQty,"9999") + ")"                    
  ? MARGIN + "         Refund                         " + trans(nRefnd,"99,999,999.99") 
  ?? space(4) + "(" + trans(nRefQty,"9999") + ")"                    
  ? MARGIN + "         Sales Discount                 " + trans(nSlsDsc+nSubtDsc,"99,999,999.99")
  ?? space(4) + "(" + trans(nDscQty+nSubTQty,"9999") + ")"          
  ? MARGIN + "         Void Previous[Tran. Void]      " + trans(nTVoid,"99,999,999.99")
  ?? space(4) + "(" + trans(nTVQty,"9999") + ")"                              
  ? MARGIN + "                               ----------------------"
  ? MARGIN + "       Total Negative Entries           " + trans(nTotlNeg,"99,999,999.99")
  ?
/*jzo04-17-98
  ? MARGIN + "TOTAL SALES[DAILY SALES]                " + trans(nNetSls,"99,999,999.99")
  ? MARGIN + " Add  : Loans                           " + trans(nLoan,"99,999,999.99") 
  ? MARGIN + " Less : Pick-Up                         " + trans(nPckUp,"99,999,999.99")
  ? MARGIN + "       [(Negative Cash)                 " + trans(nOffLine,"99,999,999.99") + "]"
  ? MARGIN + "                               ----------------------"
  ? MARGIN + "NET SALES                               " + trans(nNetsls+nLoan-nPckUp,"99,999,999.99")
  ? MARGIN + "CASH COUNT DECLARATION                  " + trans(nCashDec,"99,999,999.99")
  ? MARGIN + "                               ----------------------"
  ? MARGIN + "(SHORT)/OVER                            " + trans(nCashDec-(nNetsls+nLoan-nPckUp),"@( 99,999,999.99")
  ?
*/
  ? MARGIN + "NET SALES [DAILY SALES]                 " + trans(nNetSls,"99,999,999.99")
//jzo04-18-98  ? chr(12)

  ?
  ? 
  ? MARGIN + "TENDER(s)               " 
  ? MARGIN + "         Dollar                         " + trans(nCaSls,"99,999,999.99")
  ? MARGIN + "         Peso                           " + trans(nDollar,"99,999,999.99") + " - P " + trans(nPeso,"99,999,999.99")
  ? MARGIN + "  CARD:                                 " 
  nPesoTot := nPeso

//jzo04-15-98
for indx := 1 to 20
     if aCredit[indx][2] <> 0 .or. aCredit[indx][3] <> 0 
     
      if aCredit[indx][1] == " "
        ? MARGIN +"         CREDIT CARD "+alltrim(str(indx)) +space(40-(9+len("CREDIT CARD "+alltrim(str(indx)))))
      else
        ? MARGIN + space(9) + aCredit[indx][1] +space(40-(9+len(aCredit[indx][1])))
      endif 
//      ?? space(7) + trans(aCredit[indx][2],"9,999,999")
//      ?? trans(aCredit[indx+20][3],"99,999,999.99") + " - P " +  trans(aCredit[indx][3],"99,999,999.99")
        ?? trans(aCredit[indx][3],"99,999,999.99") 
	   ?? " - P " +  trans(aCredit[indx][3]*nXrate,"99,999,999.99") 
	   nTotlTnd += aCredit[indx][3]
	   nPesoTot += aCredit[indx][3]*nXrate
      linectr += 1    
     endif 
  if linectr == 50
     ? chr(12)
     lfirst := .t.
  endif

next indx

  ? MARGIN + "                               ----------------------   ---------------"
  ? MARGIN + "TOTAL TENDER                            " + trans(nTotlTnd,"99,999,999.99")
  ?? "     " + trans(nPesoTot,"99,999,999.99")
  ?
  ?
  ?
//jzo04-18-98  ? MARGIN + "Prepared By : _____________________   Reviewed By : _____________________"
 
  ? chr(12)  
   
      prevCash := CASH->CODE
      aTerm := {}

     nNetSls	  := 0	
    nGrossPls     := 0
    nCaSls        := 0
    nVdAmt        := 0
    nVdMgr        := 0
    nVdQty        := 0
    nVdMQty       := 0
    nTVoid        := 0
    nTVQty        := 0
    nCancel       := 0
    nCQty         := 0
    nSlsDsc       := 0
    nDscQty       := 0
    nSubtDsc       := 0
    nsubtQty       := 0
    nAddOn        := 0
    nAddQty       := 0
    nRetrns       := 0
    nRetQty       := 0
    nRefnd        := 0
    nRefQty       := 0
    nPckUp        := 0
    nOffLine      := 0
    nLoan         := 0
    nCashDec      := 0
    nOther        := 0
    ndollar       := 0

//jzo04-15-98
    nPeso       := 0
 
    aCredit[1][2] := 0 
    aCredit[1][3] := 0
    
    aCredit[2][2] := 0 
    aCredit[2][3] := 0 
    
    aCredit[3][2] := 0 
    aCredit[3][3] := 0 

    aCredit[4][2] := 0 
    aCredit[4][3] := 0
    
    aCredit[5][2] := 0 
    aCredit[5][3] := 0
    
    aCredit[6][2] := 0 
    aCredit[6][3] := 0
    
    aCredit[7][2] := 0 
    aCredit[7][3] := 0
    
    aCredit[8][2] := 0 
    aCredit[8][3] := 0
    
    aCredit[9][2] := 0 
    aCredit[9][3] := 0
    
    aCredit[10][2] := 0 
    aCredit[10][3] := 0
    
    aCredit[11][2] := 0 
    aCredit[11][3] := 0
    
    aCredit[12][2] := 0 
    aCredit[12][3] := 0
    
    aCredit[13][2] := 0 
    aCredit[13][3] := 0
    
    aCredit[14][2] := 0 
    aCredit[14][3] := 0
    
    aCredit[15][2] := 0 
    aCredit[15][3] := 0
    
    aCredit[16][2] := 0 
    aCredit[16][3] := 0
    
    aCredit[17][2] := 0 
    aCredit[17][3] := 0
    
    aCredit[18][2] := 0 
    aCredit[18][3] := 0
    
    aCredit[19][2] := 0 
    aCredit[19][3] := 0
    
    aCredit[20][2] := 0 
    aCredit[20][3] := 0
    

    aCredit[21][2] := 0 
    aCredit[21][3] := 0
    
    aCredit[22][2] := 0 
    aCredit[22][3] := 0 
    
    aCredit[23][2] := 0 
    aCredit[23][3] := 0 

    aCredit[24][2] := 0 
    aCredit[24][3] := 0
    
    aCredit[25][2] := 0 
    aCredit[25][3] := 0
    
    aCredit[26][2] := 0 
    aCredit[26][3] := 0
    
    aCredit[27][2] := 0 
    aCredit[27][3] := 0
    
    aCredit[28][2] := 0 
    aCredit[28][3] := 0
    
    aCredit[29][2] := 0 
    aCredit[29][3] := 0
    
    aCredit[30][2] := 0 
    aCredit[30][3] := 0
    
    aCredit[31][2] := 0 
    aCredit[31][3] := 0
    
    aCredit[32][2] := 0 
    aCredit[32][3] := 0
    
    aCredit[33][2] := 0 
    aCredit[33][3] := 0
    
    aCredit[34][2] := 0 
    aCredit[34][3] := 0
    
    aCredit[35][2] := 0 
    aCredit[35][3] := 0
    
    aCredit[36][2] := 0 
    aCredit[36][3] := 0
    
    aCredit[37][2] := 0 
    aCredit[37][3] := 0
    
    aCredit[38][2] := 0 
    aCredit[38][3] := 0
    
    aCredit[39][2] := 0 
    aCredit[39][3] := 0
    
    aCredit[40][2] := 0 
    aCredit[40][3] := 0

    // wala pa ngayon
    nBnkChq       := 0
    nCrdtCrd      := 0
    nEmpChq       := 0
    nGftChq       := 0
    nEmpCrd       := 0
    nNEmpCrd      := 0
    nPO           := 0
    nTotccd       := 0


    endif

    
   // else

    dDate := CASH->DATE
    cCode := CASH->CODE
    cCName := CASH->NAME
    cTime := CASH->TIME   //jzo04-20-98
    if ( ( n:= aScan(aTerm,{|x| x == val(CASH->TERM) } ) ) == 0)
    
      aAdd(aTerm,val(CASH->TERM))
      
    endif 

    nNetSls	  += CASH->daily_a	
    nGrossPls     += CASH->gross_a
    nCaSls        += CASH->cash_a     
    nVdAmt        += CASH->ivoid_a
    nVdMgr        += CASH->mvoid_a
    nVdQty        += CASH->ivoid_c
    nVdMQty       += CASH->mvoid_c
    nTVoid        += CASH->tvoid_a
    nTVQty        += CASH->tvoid_c
    nCancel       += CASH->cancl_a
    nCQty         += CASH->cancl_c
    nSlsDsc       += CASH->idisc_a
    nDscQty       += CASH->idisc_c
    nSubtDsc       += CASH->subtd_a
    nsubtQty       += CASH->subtd_c
    nAddOn        += CASH->addon_a
    nAddQty       += CASH->addon_c
    nRetrns       += CASH->retrn_a
    nRetQty       += CASH->retrn_c 
    nRefnd        += CASH->refnd_a
    nRefQty       += CASH->refnd_c 
    nPckUp        += CASH->pikup_a
    nOffLine      += CASH->offln_a  
    nLoan         += CASH->loan_a
    nCashDec      += CASH->recact_a
    nOther        += CASH->otinc_a


//jzo04-15-98
    nPeso       += CASH->forcur_a
 
    aCredit[1][2] += CASH->MISC01_C 
    aCredit[1][3] += CASH->MISC01_A
    
    aCredit[2][2] += CASH->MISC02_C 
    aCredit[2][3] += CASH->MISC02_A 
    
    aCredit[3][2] += CASH->MISC03_C 
    aCredit[3][3] += CASH->MISC03_A 

    aCredit[4][2] += CASH->MISC04_C 
    aCredit[4][3] += CASH->MISC04_A
    
    aCredit[5][2] += CASH->MISC05_C 
    aCredit[5][3] += CASH->MISC05_A
    
    aCredit[6][2] += CASH->MISC06_C 
    aCredit[6][3] += CASH->MISC06_A
    
    aCredit[7][2] += CASH->MISC07_C 
    aCredit[7][3] += CASH->MISC07_A
    
    aCredit[8][2] += CASH->MISC08_C 
    aCredit[8][3] += CASH->MISC08_A
    
    aCredit[9][2] += CASH->MISC09_C 
    aCredit[9][3] += CASH->MISC09_A
    
    aCredit[10][2] += CASH->MISC10_C 
    aCredit[10][3] += CASH->MISC10_A
    
    aCredit[11][2] += CASH->MISC11_C 
    aCredit[11][3] += CASH->MISC11_A
    
    aCredit[12][2] += CASH->MISC12_C 
    aCredit[12][3] += CASH->MISC12_A
    
    aCredit[13][2] += CASH->MISC13_C 
    aCredit[13][3] += CASH->MISC13_A

    aCredit[14][2] += CASH->MISC14_C 
    aCredit[14][3] += CASH->MISC14_A
    
    aCredit[15][2] += CASH->MISC15_C 
    aCredit[15][3] += CASH->MISC15_A
    
    aCredit[16][2] += CASH->MISC16_C 
    aCredit[16][3] += CASH->MISC16_A
    
    aCredit[17][2] += CASH->MISC17_C 
    aCredit[17][3] += CASH->MISC17_A
    
    aCredit[18][2] += CASH->MISC18_C 
    aCredit[18][3] += CASH->MISC18_A
    
    aCredit[19][2] += CASH->MISC19_C 
    aCredit[19][3] += CASH->MISC19_A
    
    aCredit[20][2] += CASH->MISC20_C 
    aCredit[20][3] += CASH->MISC20_A
    

    aCredit[21][2] += CASH->MISC21_C 
    aCredit[21][3] += CASH->MISC21_A
    
    aCredit[22][2] += CASH->MISC22_C 
    aCredit[22][3] += CASH->MISC22_A 
    
    aCredit[23][2] += CASH->MISC23_C 
    aCredit[23][3] += CASH->MISC23_A 

    aCredit[24][2] += CASH->MISC24_C 
    aCredit[24][3] += CASH->MISC24_A
    
    aCredit[25][2] += CASH->MISC25_C 
    aCredit[25][3] += CASH->MISC25_A
    
    aCredit[26][2] += CASH->MISC26_C 
    aCredit[26][3] += CASH->MISC26_A
    
    aCredit[27][2] += CASH->MISC27_C 
    aCredit[27][3] += CASH->MISC27_A
    
    aCredit[28][2] += CASH->MISC28_C 
    aCredit[28][3] += CASH->MISC28_A
    
    aCredit[29][2] += CASH->MISC29_C 
    aCredit[29][3] += CASH->MISC29_A
    
    aCredit[30][2] += CASH->MISC30_C 
    aCredit[30][3] += CASH->MISC30_A
    
    aCredit[31][2] += CASH->MISC31_C 
    aCredit[31][3] += CASH->MISC31_A
    
    aCredit[32][2] += CASH->MISC32_C 
    aCredit[32][3] += CASH->MISC32_A
    
    aCredit[33][2] += CASH->MISC33_C 
    aCredit[33][3] += CASH->MISC33_A
    
    aCredit[34][2] += CASH->MISC34_C 
    aCredit[34][3] += CASH->MISC34_A
    
    aCredit[35][2] += CASH->MISC35_C 
    aCredit[35][3] += CASH->MISC35_A
    
    aCredit[36][2] += CASH->MISC36_C 
    aCredit[36][3] += CASH->MISC36_A
    
    aCredit[37][2] += CASH->MISC37_C 
    aCredit[37][3] += CASH->MISC37_A
    
    aCredit[38][2] += CASH->MISC38_C 
    aCredit[38][3] += CASH->MISC38_A
    
    aCredit[39][2] += CASH->MISC39_C 
    aCredit[39][3] += CASH->MISC39_A
    
    aCredit[40][2] += CASH->MISC40_C 
    aCredit[40][3] += CASH->MISC40_A

    // wala pa ngayon
/*
    nBnkChq       += CASH->misc18_a + CASH->misc19_a +CASH->misc20_a +;
                    CASH->misc21_a + CASH->misc22_a +CASH->misc23_a +;
                    CASH->misc24_a + CASH->misc25_a +CASH->misc26_a +;
                    CASH->misc27_a + CASH->misc28_a

    nCrdtCrd      += CASH->misc01_a + CASH->misc02_a +CASH->misc03_a +;
                    CASH->misc04_a + CASH->misc05_a +CASH->misc06_a +;
                    CASH->misc07_a + CASH->misc08_a +CASH->misc09_a +;
                    CASH->misc10_a + CASH->misc11_a +CASH->misc12_a +;
                    CASH->misc13_a  
    nEmpChq       += CASH->misc30_a
    nGftChq       += CASH->misc29_a
    nEmpCrd       += CASH->misc14_a
    nNEmpCrd      += CASH->misc15_a 
    nPO           += CASH->misc16_a + CASH->misc17_a
*/

    nCrdtPeso      += CASH->misc01_a + CASH->misc02_a +CASH->misc03_a +;
                    CASH->misc04_a + CASH->misc05_a +CASH->misc06_a +;
                    CASH->misc07_a + CASH->misc08_a +CASH->misc09_a +;
                    CASH->misc10_a + CASH->misc11_a +CASH->misc12_a +;
                    CASH->misc13_a +CASH->misc14_a +CASH->misc15_a +;
                    CASH->misc16_a +CASH->misc17_a +CASH->misc18_a +;
                    CASH->misc19_a +CASH->misc20_a 


    nCrdtDollar     += CASH->misc21_a + CASH->misc22_a +CASH->misc23_a +;
                    CASH->misc24_a + CASH->misc25_a +CASH->misc26_a +;
                    CASH->misc27_a + CASH->misc28_a +CASH->misc29_a +;
                    CASH->misc30_a + CASH->misc31_a +CASH->misc32_a +;
                    CASH->misc33_a +CASH->misc34_a +CASH->misc35_a +;
                    CASH->misc36_a +CASH->misc37_a +CASH->misc38_a +;
                    CASH->misc39_a +CASH->misc40_a 

   // nDollar := CASH->MISC50_A
    nDollar += CASH->MISC50_A

//jzo04-15-98
do while FC_HIST->(!eof())
  if FC_HIST->DATE == dDate  //.and. val(FC_HIST->TIME)==cTime
     aadd(aFrate,round(FC_HIST->NEWRATE,2))
     nXrate:=round(FC_HIST->NEWRATE,2)
  endif
  FC_HIST->(dbskip())
enddo     

if len(aFrate) == 0
 FC_HIST->(DBGOBOTTOM())
 aadd(aFrate,round(FC_HIST->NEWRATE,2))
endif
   
    // total counters
  nTotlAdd           := nOther + nAddon
  nGrsSls            := nGrossPls - nTotlAdd
  nTotlVd            := nVdAmt + nVdMgr + nCancel
  nTotlNeg           := nSlsDsc + nSubtdsc + nRetrns + nRefnd + nTVoid
  nTotlSls           := nGrsSls - nTotlNeg
  totcash            := nCaSls - nLoan + nPckup + nOffline
/*jzo04-17-98
  nTotlTnd           := nCaSls + nBnkChq + nCrdtCrd - nOther ; //bing
                        + nEmpChq + nGftChq + nEmpCrd ;
                        + nNEmpCrd + nPO // - (nAddon + nRefnd)
*/

//jzo04-15-98
//  nDollar            := nPeso / nXrate

  nTotlTnd           := nCaSls + nDollar + nCrdtDollar
  cCode := ""
/*
  for i := 1 to len(aTerm)
      cCode += " " + padl(aterm[i],2,"0")
  next                      
*/
//  endif

  endif   

  CASH->(DbSkip())    
  
enddo

 if nNetSls <> 0

  cTerm := ""

  for i := 1 to len(aTerm)
      cTerm += " " + padl(aterm[i],2,"0")
  next                      

        // report format
  ? CHR(15)
  ? MARGIN + "Run Date : " + dtoc(Date())
  ? CHR(18)
  ? MARGIN + space(32) + SYS_NAME
  ? MARGIN + space(24) + "Cashier Accountability Report"
  ?
  ?
 CNTRL->(DbSetOrderto(2))
  CNTRL->(DbSeek(dtos(dStartDate)))
  cntrl_no := " "
  while DatesOk(CNTRL->DATE)
     cntrl_no += alltrim(str(CNTRL->CONTRL_NO)) + ","
     dDate := CNTRL->DATE
     CNTRL->(DBSKIP())
  ENDDO
  CNTRL->(DbSetOrderto(1))
  ? MARGIN + "CONTROL NO. : " + cntrl_no + " " + dtoc(dDate)
  ?
  ? MARGIN + "CASHIER NO. : " + prevcash + "  " + cCName  
  ?
  ? MARGIN + "EXCH. RATE:   $1.00 - " //+ alltrim(str(nXrate))

//jzo04-21-98
  if len(aFrate) == 1
    ??alltrim(trans(aFrate[1],"99,999,999.99"))
  else    
  for j:=1 to len(aFrate)
    ??alltrim(trans(aFrate[j],"99,999,999.99")) + ", "
  next j  
  endif
  
  ?
  ? MARGIN + "TERMINAL NO. " + cterm
  ? 
//  ? MARGIN + "No. of Items Sold  :          " + trans(nCtr,"999999")
  ? 
  ? MARGIN + "GROSS SALES[DEPT SALES]                 " + trans(nGrsSls,"99,999,999.99")

/*jzo04-17-98
  ? MARGIN + " Plus  : Other Income                   " + trans(nOther,"99,999,999.99")
  ? MARGIN + "         Add-On(s)                      " + trans(nAddOn,"99,999,999.99")
  ? MARGIN + "                               ----------------------"
  ? MARGIN + " Total Negative Entries                 " + trans(nTotlAdd,"99,999,999.99")
*/

  ?
  ? MARGIN + "GROSS PLUS[GROSS SALES]                 " + trans(nGrossPls,"99,999,999.99")
  ? MARGIN + "Less   : VOID ENTRIES         "
  ? MARGIN + "          Void Line Items               " + trans(nVdAmt,"99,999,999.99") 
  ?? space(4) + "(" + trans(nVdQty,"9999") + ")"                   
  ? MARGIN + "         Manager Void                   " + trans(nVdMgr,"99,999,999.99") 
  ?? space(4) + "(" + trans(nVdMQty,"9999") + ")"                    
  ? MARGIN + "          Void Total [Tran. Cancel]     " + trans(nCancel,"99,999,999.99")
  ?? space(4) + "(" + trans(nCQty,"9999") + ")"                    
  ? MARGIN + "                               ----------------------"
  ? MARGIN + "      [Total Void Entries               " + trans(nTotlVd,"99,999,999.99")  +"]"
  ?
  ? MARGIN + " Less  : Negative Entries"
  ? MARGIN + "         Returns                        " + trans(nRetrns,"99,999,999.99")
  ?? space(4) + "(" + trans(nRetQty,"9999") + ")"                    
  ? MARGIN + "         Refund                         " + trans(nRefnd,"99,999,999.99") 
  ?? space(4) + "(" + trans(nRefQty,"9999") + ")"                    
  ? MARGIN + "         Sales Discount                 " + trans(nSlsDsc+nSubtDsc,"99,999,999.99")
  ?? space(4) + "(" + trans(nDscQty+nSubTQty,"9999") + ")"          
  ? MARGIN + "         Void Previous[Tran. Void]      " + trans(nTVoid,"99,999,999.99")
  ?? space(4) + "(" + trans(nTVQty,"9999") + ")"                              
  ? MARGIN + "                               ----------------------"
  ? MARGIN + "       Total Negative Entries           " + trans(nTotlNeg,"99,999,999.99")
  ?
/*jzo04-17-98
  ? MARGIN + "TOTAL SALES[DAILY SALES]                " + trans(nNetSls,"99,999,999.99")
  ? MARGIN + " Add  : Loans                           " + trans(nLoan,"99,999,999.99") 
  ? MARGIN + " Less : Pick-Up                         " + trans(nPckUp,"99,999,999.99")
  ? MARGIN + "       [(Negative Cash)                 " + trans(nOffLine,"99,999,999.99") + "]"
  ? MARGIN + "                               ----------------------"
  ? MARGIN + "NET SALES                               " + trans(nNetsls+nLoan-nPckUp,"99,999,999.99")
  ? MARGIN + "CASH COUNT DECLARATION                  " + trans(nCashDec,"99,999,999.99")
  ? MARGIN + "                               ----------------------"
  ? MARGIN + "(SHORT)/OVER                            " + trans(nCashDec-(nNetsls+nLoan-nPckUp),"@( 99,999,999.99")
  ?
*/
  ? MARGIN + "NET SALES [DAILY SALES]                 " + trans(nNetSls,"99,999,999.99")
//jzo04-18-98   ? chr(12)

  ?
  ? 
  ? MARGIN + "TENDER(s)               " 
  ? MARGIN + "         Dollar                         " + trans(nCaSls,"99,999,999.99")
  ? MARGIN + "         Peso                           " + trans(nDollar,"99,999,999.99") + " - P " + trans(nPeso,"99,999,999.99")
  ? MARGIN + "  CARD:                                 " 
  nPesoTot := nPeso
//jzo04-15-98
for indx := 1 to 20
     if aCredit[indx][2] <> 0 .or. aCredit[indx][3] <> 0 
     
      if aCredit[indx][1] == " "
        ? MARGIN +"         CREDIT CARD "+alltrim(str(indx)) +space(40-(9+len("CREDIT CARD "+alltrim(str(indx)))))
      else
        ? MARGIN + space(9) + aCredit[indx][1] +space(40-(9+len(aCredit[indx][1])))
      endif 
//      ?? space(7) + trans(aCredit[indx][2],"9,999,999")
//      ?? trans(aCredit[indx+20][3],"99,999,999.99") + " - P " +  trans(aCredit[indx][3],"99,999,999.99")
      ?? trans(aCredit[indx][3],"99,999,999.99") 
	 ?? " - P " +  trans(aCredit[indx][3]*nXrate,"99,999,999.99")
	 nTotlTnd += aCredit[indx][3]
	 nPesoTot += aCredit[indx][3] * nXrate
      linectr += 1    
     endif 
  if linectr == 50
     ? chr(12)
     lfirst := .t.
  endif

next indx

  ? MARGIN + "                               ----------------------   ---------------"
  ? MARGIN + "TOTAL TENDER                            " + trans(nTotlTnd,"99,999,999.99")
  ?? "     " + trans(nPesoTot,"99,999,999.99")
  ?
  ?
  ?
//jzo04-18-98  ? MARGIN + "Prepared By : _____________________   Reviewed By : _____________________"
 
  ? chr(12)  
 
 endif




CLOSE ALTERNATE
SET ALTERNATE OFF
SET CONSOLE ON

aFsize := directory(CASH_ACC)

// check if report file is < 64K
// direct to printer if greater   

if aFsize[1][2] < MAX_SIZE

  cReport:=memoread(CASH_ACC)
  if !empty(cReport)
   if !setmode(50,80) .and. !setmode(43,80)
      setmode(nMaxrow,nMaxcol)
   else
      _logo()   
   endif       
   Message("Use cursor keys to navigate, press F10 to print, "+ ;
              "Esc to abort.")
   wWindBuff:=OpenWindow(1,2,maxrow()-1,maxcol()-2,"Cashier Accountability Report")
   MemoEdit(cReport,2,3,maxrow()-2,maxcol()-3,.f.,'Editor2Func',122 )
   CloseWindow(wWindBuff)
   setcursor(SC_NONE)
   setmode(nMaxrow,nMaxcol)
  endif
 
else

 if alert("Report too large to edit, will be directed to printer", {"Print","Quit"}) == 1 
    Direct2Prn(CASH_ACC) 
 endif  
 
endif  

  KillWindow()
cReport := "" //Free memory      
  
DbCloseAll()
return nil