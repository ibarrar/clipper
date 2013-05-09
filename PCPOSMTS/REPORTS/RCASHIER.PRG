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
#define REPORTFILE  "CASHIER.PRN"
#define MAX_SIZE    65535
#define MAX_LINE    50    
#define EJECT_FROM_FILE
#define DEBUG
#define MAX_MISC    82    
 
memvar n,dStartDate,dEndDate,nLimit,GetList, cReport



/*=========================================*/
function RCCashier()
/*=========================================*/
local cRef,wWindBuff
local nMaxrow := maxrow()+1, nMaxCol := maxcol()+1
local aFsize := {}
// Gauge variables
local nRecCtr := 0, hGauge, nPercent, nGaugeCtr:=1, wUpdate, dDate
local cName := space(20), dFile, code
local lNewPage := 0, nLineCtr := 0, nLinelen  := 75, nPageCtr := 1
local nPageslstot := 0, nPageslsqty := 0, cWindow
local nReccount := 0, nCtr := 1, ccolor, coldpath
local nRunslstot := 0, nRunslsqty := 0, count := 0, amount := 0
local lFirst := .f., aCredit := {}, i := 0, nQuantity := 0
local ntotalamt := 0, nRuntotamt := 0, n := 0

if !Getvalid()
  BUMMER() ; return nil 
endif 


if netuse("CC", DB_SHARED, NUM_SECONDS)
    set index to CC_001
endif    


if netuse("CASH", DB_SHARED, NUM_SECONDS)
    set index to CAS
else
   alert("File 'CASH.DBF' cannot be accessed",{"Quit"})
   DbCloseAll()
   return nil    
endif	 



cOldPath := SET(_SET_PATH)

Message("Preparing Consolidated Cashier Sales Report ...")


SET ALTERNATE TO ".\"+REPORTFILE
SET ALTERNATE ON
SET CONSOLE OFF
SET PRINTER OFF

window( 19, 1, 22, 70, CONFIRM_COLOR )

lNewPage := .t.
lFirst := .t.

* aSize(aCredit,MAX_MISC)
* aFill(aCredit,{"0000"," ",0,0})

 for i := 1 to MAX_MISC

  aadd(aCredit,{" ",0,0})
 
 next i
  
 DO WHILE CC->(!EOF())

   aCredit[6+n][1] := CC->CC_002
   n := n+1
   CC->(DBSKIP())
 ENDDO   



Do While CASH->(!Eof())  

  @ 1, 1 wsay " Creating " + "Consolidated Cashier Sales Report" + "  Please wait ..."
  @ 2, 1 wsay " Cashier Code: " + CASH->CODE + "   " + "Cashier Name: " + CASH->NAME

 if DatesOk(CASH->DATE) 

    aCredit[1][2] += CASH->DAILY_C 
    aCredit[1][3] += CASH->DAILY_A

    aCredit[2][3] += CASH->CASH_A

    aCredit[3][3] += CASH->GROSS_A

    aCredit[4][3] += CASH->DEPT_A

    aCredit[5][2] += CASH->FORCUR_C 
    aCredit[5][3] += CASH->FORCUR_A
 
    aCredit[6][2] += CASH->MISC01_C 
    aCredit[6][3] += CASH->MISC01_A
    
    aCredit[7][2] += CASH->MISC02_C 
    aCredit[7][3] += CASH->MISC02_A 
    
    aCredit[8][2] += CASH->MISC03_C 
    aCredit[8][3] += CASH->MISC03_A 

    aCredit[9][2] += CASH->MISC04_C 
    aCredit[9][3] += CASH->MISC04_A
    
    aCredit[10][2] += CASH->MISC05_C 
    aCredit[10][3] += CASH->MISC05_A
    
    aCredit[11][2] += CASH->MISC06_C 
    aCredit[11][3] += CASH->MISC06_A
    
    aCredit[12][2] += CASH->MISC07_C 
    aCredit[12][3] += CASH->MISC07_A
    
    aCredit[13][2] += CASH->MISC08_C 
    aCredit[13][3] += CASH->MISC08_A
    
    aCredit[14][2] += CASH->MISC09_C 
    aCredit[14][3] += CASH->MISC09_A
    
    aCredit[15][2] += CASH->MISC10_C 
    aCredit[15][3] += CASH->MISC10_A
    
    aCredit[16][2] += CASH->MISC11_C 
    aCredit[16][3] += CASH->MISC11_A
    
    aCredit[17][2] += CASH->MISC12_C 
    aCredit[17][3] += CASH->MISC12_A
    
    aCredit[18][2] += CASH->MISC13_C 
    aCredit[18][3] += CASH->MISC13_A
    
    aCredit[19][2] += CASH->MISC14_C 
    aCredit[19][3] += CASH->MISC14_A
    
    aCredit[20][2] += CASH->MISC15_C 
    aCredit[20][3] += CASH->MISC15_A
    
    aCredit[21][2] += CASH->MISC16_C 
    aCredit[21][3] += CASH->MISC16_A
    
    aCredit[22][2] += CASH->MISC17_C 
    aCredit[22][3] += CASH->MISC17_A
    
    aCredit[23][2] += CASH->MISC18_C 
    aCredit[23][3] += CASH->MISC18_A
    
    aCredit[24][2] += CASH->MISC19_C 
    aCredit[24][3] += CASH->MISC19_A
    
    aCredit[25][2] += CASH->MISC20_C 
    aCredit[25][3] += CASH->MISC20_A
    
    aCredit[26][2] += CASH->MISC21_C 
    aCredit[26][3] += CASH->MISC21_A
    
    aCredit[27][2] += CASH->MISC22_C 
    aCredit[27][3] += CASH->MISC22_A
    
    aCredit[28][2] += CASH->MISC23_C 
    aCredit[28][3] += CASH->MISC23_A
    
    aCredit[29][2] += CASH->MISC24_C 
    aCredit[29][3] += CASH->MISC24_A
    
    aCredit[30][2] += CASH->MISC25_C 
    aCredit[30][3] += CASH->MISC25_A
    
    aCredit[31][2] += CASH->MISC26_C 
    aCredit[31][3] += CASH->MISC26_A
    
    aCredit[32][2] += CASH->MISC27_C 
    aCredit[32][3] += CASH->MISC27_A
    
    aCredit[33][2] += CASH->MISC28_C 
    aCredit[33][3] += CASH->MISC28_A
    
    aCredit[34][2] += CASH->MISC29_C 
    aCredit[34][3] += CASH->MISC29_A
    
    aCredit[35][2] += CASH->MISC30_C 
    aCredit[35][3] += CASH->MISC30_A
    
    aCredit[36][2] += CASH->MISC31_C 
    aCredit[36][3] += CASH->MISC31_A
    
    aCredit[37][2] += CASH->MISC32_C 
    aCredit[37][3] += CASH->MISC32_A
    
    aCredit[38][2] += CASH->MISC33_C 
    aCredit[38][3] += CASH->MISC33_A
    
    aCredit[39][2] += CASH->MISC34_C 
    aCredit[39][3] += CASH->MISC34_A
    
    aCredit[40][2] += CASH->MISC35_C 
    aCredit[40][3] += CASH->MISC35_A
    
    aCredit[41][2] += CASH->MISC36_C 
    aCredit[41][3] += CASH->MISC36_A
    
    aCredit[42][2] += CASH->MISC37_C 
    aCredit[42][3] += CASH->MISC37_A
    
    aCredit[43][2] += CASH->MISC38_C 
    aCredit[43][3] += CASH->MISC38_A
    
    aCredit[44][2] += CASH->MISC39_C 
    aCredit[44][3] += CASH->MISC39_A
    
    aCredit[45][2] += CASH->MISC40_C 
    aCredit[45][3] += CASH->MISC40_A
    
    aCredit[46][2] += CASH->MISC41_C 
    aCredit[46][3] += CASH->MISC41_A
    
    aCredit[47][2] += CASH->MISC42_C 
    aCredit[47][3] += CASH->MISC42_A
    
    aCredit[48][2] += CASH->MISC43_C 
    aCredit[48][3] += CASH->MISC43_A
    
    aCredit[49][2] += CASH->MISC44_C 
    aCredit[49][3] += CASH->MISC44_A
    
    aCredit[50][2] += CASH->MISC45_C 
    aCredit[50][3] += CASH->MISC45_A
    
    aCredit[51][2] += CASH->MISC46_C 
    aCredit[51][3] += CASH->MISC46_A
    
    aCredit[52][2] += CASH->MISC47_C 
    aCredit[52][3] += CASH->MISC47_A
   
    aCredit[53][2] += CASH->MISC48_C 
    aCredit[53][3] += CASH->MISC48_A
    
    aCredit[54][2] += CASH->MISC49_C 
    aCredit[54][3] += CASH->MISC49_A
    
    aCredit[55][2] += CASH->MISC50_C 
    aCredit[55][3] += CASH->MISC50_A

    aCredit[56][2] += CASH->IVOID_C 
    aCredit[56][3] += CASH->IVOID_A
    
    aCredit[57][2] += CASH->MVOID_C 
    aCredit[57][3] += CASH->MVOID_A
    
    aCredit[58][2] += CASH->IDISC_C 
    aCredit[58][3] += CASH->IDISC_A
    
    aCredit[59][2] += CASH->SUBTD_C 
    aCredit[59][3] += CASH->SUBTD_A
    
    aCredit[60][2] += CASH->ADDON_C 
    aCredit[60][3] += CASH->ADDON_A
    
    aCredit[61][2] += CASH->SSBTD_C 
    aCredit[61][3] += CASH->SSBTD_A
    
    aCredit[62][2] += CASH->SSBTA_C 
    aCredit[62][3] += CASH->SSBTA_A
    
    aCredit[63][2] += CASH->RETRN_C 
    aCredit[63][3] += CASH->RETRN_A
    
    aCredit[64][2] += CASH->REFND_C 
    aCredit[64][3] += CASH->REFND_A
    
    aCredit[65][2] += CASH->OTINC_C 
    aCredit[65][3] += CASH->OTINC_A
    
    aCredit[66][2] += CASH->CANCL_C 
    aCredit[66][3] += CASH->CANCL_A
    
    aCredit[67][2] += CASH->TVOID_C 
    aCredit[67][3] += CASH->TVOID_A
    
    aCredit[68][2] += CASH->SUSPD_C 
    aCredit[68][3] += CASH->SUSPD_A
    
    aCredit[69][2] += CASH->LAYAW_C 
    aCredit[69][3] += CASH->LAYAW_A
    
    aCredit[70][2] += CASH->PIKUP_C 
    aCredit[70][3] += CASH->PIKUP_A
    
    aCredit[71][2] += CASH->PDOUT_C 
    aCredit[71][3] += CASH->PDOUT_A
    
    aCredit[72][2] += CASH->LOAN_C 
    aCredit[72][3] += CASH->LOAN_A
    
    aCredit[73][2] += 0 
    aCredit[73][3] += 0
    
    aCredit[74][2] += CASH->BOTDEP_C 
    aCredit[74][3] += CASH->BOTDEP_A

    aCredit[75][3] += CASH->RECACT_A
    
    aCredit[76][3] += CASH->TRAIN_A
    
    aCredit[77][3] += CASH->OFFLN_A
    
    aCredit[78][3] += CASH->RENTER_A
    
    aCredit[79][3] += CASH->OLDGRD_A
    
    aCredit[80][3] += CASH->NEWGRD_A
    
    aCredit[81][2] += CASH->XCOUNT_C 
    
    aCredit[82][2] += CASH->ZCOUNT_C 
         

 endif 
 CASH->(DbSkip())
enddo        




 for i := 1 to MAX_MISC     

    // Create header if new page  
   if lNewPage  
     // Create header if new page  
     ? MARGIN + "CONSOLIDATED CASHIER SALES REPORT"
     ?
     ? MARGIN +chr(254)+ SYS_NAME
     ? MARGIN +"Consolidated Cashier Sales Report"
     ? MARGIN +"From "+dtoc(dStartDate)+" to "+dtoc(dEndDate)
     ? MARGIN +"As of "+dtoc(date())+", "+time()
     ?
     ?
     ?
     ? MARGIN + "    DESCRIPTION                             COUNT         AMOUNT      "
     ? MARGIN + "-----------------------------------       ----------   -------------- " 
     //          12345678901234567890123456789012345       1234567890   12345678901234  
     ?
     ?

   lNewpage := .f.
   nLineCtr := 13
  endif   

   

   if i >= 6 .and. i <= 55
     if aCredit[i][2] <> 0 .or. aCredit[i][3] <> 0 
     
      if aCredit[i][1] == " "
        ? MARGIN +padr("MISCELLANEOUS "+alltrim(str(i)),35)
      else
        ? MARGIN + padr(aCredit[i][1],35)
      endif 
      ?? space(7) + trans(aCredit[i][2],"9,999,999")
      ?? space(3) + trans(aCredit[i][3],"99,999,999.99")
      nLinectr += 1    
     endif 
    
   else
   
     Do Case
       Case i == 1 
         aCredit[i][1] := padr("DAILY SALES",35)
       Case i == 2 
         aCredit[i][1] := padr("CASH TOTALS",35)  
       Case i == 3 
         aCredit[i][1] := padr("GROSS SALES",35)
       Case i == 4 
         aCredit[i][1] := padr("DEPARTMENT TOTALS",35)
       Case i == 5 
         aCredit[i][1] := padr("FOREIGN CURRENCY TOTALS",35)
       Case i == 56 
         aCredit[i][1] := padr("ITEM VOID TOTAL",35)
       Case i == 57
         aCredit[i][1] := padr("MANAGER VOID TOTAL",35)
       Case i == 58
         aCredit[i][1] := padr("ITEM DISCOUNT TOTAL",35)
       Case i == 59
         aCredit[i][1] := padr("SUBTOTAL DISCOUNT TOTAL",35)
       Case i == 60
         aCredit[i][1] := padr("ADD-ON TOTAL",35)
       Case i == 61
         aCredit[i][1] := padr("SELECTIVE SUBTOTAL DISCOUNT TOTAL",35)
       Case i == 62
         aCredit[i][1] := padr("SELECTIVE SUBTOTAL ADD-ON TOTAL",35)
       Case i == 63
         aCredit[i][1] := padr("RETURN / EXCHANGE TOTAL",35)
       Case i == 64
         aCredit[i][1] := padr("REFUND TOTAL",35)
       Case i == 65
         aCredit[i][1] := padr("OTHER INCOME TOTAL",35)
       Case i == 66
         aCredit[i][1] := padr("TRANSACTION CANCEL TOTAL",35)
       Case i == 67
         aCredit[i][1] := padr("TRANSACTION VOID TOTAL",35)
       Case i == 68
         aCredit[i][1] := padr("TRANSACTION SUSPEND TOTAL",35)
       Case i == 69
         aCredit[i][1] := padr("LAY-AWAY TOTAL",35)
       Case i == 70
         aCredit[i][1] := padr("PICK-UP TOTAL",35)
       Case i == 71
         aCredit[i][1] := padr("PAID-OUT TOTAL",35)
       Case i == 72
         aCredit[i][1] := padr("LOAN TOTAL",35)
       Case i == 73
         aCredit[i][1] := padr("RECEIVED ON ACCOUNT TOTAL",35)
       Case i == 74
         aCredit[i][1] := padr("BOTTLE DEPOSIT TOTAL",35)
       Case i == 75
         aCredit[i][1] := padr("CASH DECLARATION TOTAL",35)  
       Case i == 76
         aCredit[i][1] := padr("TRAINING MODE TOTAL",35)
       Case i == 77
         aCredit[i][1] := padr("NEGATIVE CASH",35)
       Case i == 78
         aCredit[i][1] := padr("RE-ENTER TOTAL",35)
       Case i == 79
         aCredit[i][1] := padr("OLD GRAND TOTAL",35)
       Case i == 80
         aCredit[i][1] := padr("NEW GRAND TOTAL",35)
       Case i == 81
         aCredit[i][1] := padr("X - COUNTER",35)
       Case i == 82
         aCredit[i][1] := padr("Z - COUNTER",35)
                                                                   
     Endcase
     ? MARGIN + aCredit[i][1] 
     ?? space(7) + trans(aCredit[i][2],"9,999,999")
     ?? space(3) + trans(aCredit[i][3],"99,999,999.99")
     nLinectr += 1    
    
   endif 
   

     IF nLinectr == MAX_LINE
       ? chr(12)
       lNewpage := .t.
     ENDIF
     
    
 next i  
      
 ?
 ?
 ?     
 ? MARGIN+padc("********** End of Report **********",nLineLen )  
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
   wWindBuff:=OpenWindow(1,2,maxrow()-1,maxcol()-2,"Consolidated Cashier Sales Report")
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
function RICashier()
/*=========================================*/
local cRef,wWindBuff
local nMaxrow := maxrow()+1, nMaxCol := maxcol()+1
local aFsize := {}
// Gauge variables
local nRecCtr := 0, hGauge, nPercent, nGaugeCtr:=1, wUpdate, dDate
local cName := space(20), dFile, code
local lNewPage := 0, nLineCtr := 0, nLinelen  := 75, nPageCtr := 1
local nPageslstot := 0, nPageslsqty := 0, cWindow
local nReccount := 0, nCtr := 1, ccolor, coldpath
local nRunslstot := 0, nRunslsqty := 0, count := 0, amount := 0
local lFirst := .f., aCredit := {}, i := 0, nQuantity := 0
local ntotalamt := 0, nRuntotamt := 0, n := 0, cterm := space(3)
local vBrowse


   SET CURSOR ON
   vBrowse := OpenWindow(15,30,17,50)
   @ 16,31 say "Cashier Code: "Get cTerm Pict "999"
   read
   SET CURSOR OFF
   CloseWindow(vBrowse)

   cTerm := padl(alltrim(cTerm),3,"0") 
   

if !Getvalid()
  BUMMER() ; return nil 
endif 


if netuse("CC", DB_SHARED, NUM_SECONDS)
    set index to CC_001
endif    


if netuse("CASH", DB_SHARED, NUM_SECONDS)
    set index to CAS
else
   alert("File 'CASH.DBF' cannot be accessed",{"Quit"})
   DbCloseAll()
   return nil    
endif	 



cOldPath := SET(_SET_PATH)

Message("Preparing Individual Cashier Sales Report ...")


SET ALTERNATE TO ".\"+REPORTFILE
SET ALTERNATE ON
SET CONSOLE OFF
SET PRINTER OFF

window( 19, 1, 22, 70, CONFIRM_COLOR )

lNewPage := .t.
lFirst := .t.

* aSize(aCredit,MAX_MISC)
* aFill(aCredit,{"0000"," ",0,0})

 for i := 1 to MAX_MISC

  aadd(aCredit,{" ",0,0})
 
 next i
  
 DO WHILE CC->(!EOF())

   aCredit[6+n][1] := CC->CC_002
   n := n+1
   CC->(DBSKIP())
 ENDDO   



Do While CASH->(!Eof())  

  @ 1, 1 wsay " Creating " + "Individual Cashier Sales Report" + "  Please wait ..."
  @ 2, 1 wsay " Cashier Code: " + CASH->CODE + "   " + "Cashier Name: " + CASH->NAME


 if DatesOk(CASH->DATE)
  IF  CASH->CODE == cterm
      cName := CASH->NAME

    aCredit[1][2] += CASH->DAILY_C 
    aCredit[1][3] += CASH->DAILY_A

    aCredit[2][3] += CASH->CASH_A

    aCredit[3][3] += CASH->GROSS_A

    aCredit[4][3] += CASH->DEPT_A

    aCredit[5][2] += CASH->FORCUR_C 
    aCredit[5][3] += CASH->FORCUR_A
 
    aCredit[6][2] += CASH->MISC01_C 
    aCredit[6][3] += CASH->MISC01_A
    
    aCredit[7][2] += CASH->MISC02_C 
    aCredit[7][3] += CASH->MISC02_A 
    
    aCredit[8][2] += CASH->MISC03_C 
    aCredit[8][3] += CASH->MISC03_A 

    aCredit[9][2] += CASH->MISC04_C 
    aCredit[9][3] += CASH->MISC04_A
    
    aCredit[10][2] += CASH->MISC05_C 
    aCredit[10][3] += CASH->MISC05_A
    
    aCredit[11][2] += CASH->MISC06_C 
    aCredit[11][3] += CASH->MISC06_A
    
    aCredit[12][2] += CASH->MISC07_C 
    aCredit[12][3] += CASH->MISC07_A
    
    aCredit[13][2] += CASH->MISC08_C 
    aCredit[13][3] += CASH->MISC08_A
    
    aCredit[14][2] += CASH->MISC09_C 
    aCredit[14][3] += CASH->MISC09_A
    
    aCredit[15][2] += CASH->MISC10_C 
    aCredit[15][3] += CASH->MISC10_A
    
    aCredit[16][2] += CASH->MISC11_C 
    aCredit[16][3] += CASH->MISC11_A
    
    aCredit[17][2] += CASH->MISC12_C 
    aCredit[17][3] += CASH->MISC12_A
    
    aCredit[18][2] += CASH->MISC13_C 
    aCredit[18][3] += CASH->MISC13_A
    
    aCredit[19][2] += CASH->MISC14_C 
    aCredit[19][3] += CASH->MISC14_A
    
    aCredit[20][2] += CASH->MISC15_C 
    aCredit[20][3] += CASH->MISC15_A
    
    aCredit[21][2] += CASH->MISC16_C 
    aCredit[21][3] += CASH->MISC16_A
    
    aCredit[22][2] += CASH->MISC17_C 
    aCredit[22][3] += CASH->MISC17_A
    
    aCredit[23][2] += CASH->MISC18_C 
    aCredit[23][3] += CASH->MISC18_A
    
    aCredit[24][2] += CASH->MISC19_C 
    aCredit[24][3] += CASH->MISC19_A
    
    aCredit[25][2] += CASH->MISC20_C 
    aCredit[25][3] += CASH->MISC20_A
    
    aCredit[26][2] += CASH->MISC21_C 
    aCredit[26][3] += CASH->MISC21_A
    
    aCredit[27][2] += CASH->MISC22_C 
    aCredit[27][3] += CASH->MISC22_A
    
    aCredit[28][2] += CASH->MISC23_C 
    aCredit[28][3] += CASH->MISC23_A
    
    aCredit[29][2] += CASH->MISC24_C 
    aCredit[29][3] += CASH->MISC24_A
    
    aCredit[30][2] += CASH->MISC25_C 
    aCredit[30][3] += CASH->MISC25_A
    
    aCredit[31][2] += CASH->MISC26_C 
    aCredit[31][3] += CASH->MISC26_A
    
    aCredit[32][2] += CASH->MISC27_C 
    aCredit[32][3] += CASH->MISC27_A
    
    aCredit[33][2] += CASH->MISC28_C 
    aCredit[33][3] += CASH->MISC28_A
    
    aCredit[34][2] += CASH->MISC29_C 
    aCredit[34][3] += CASH->MISC29_A
    
    aCredit[35][2] += CASH->MISC30_C 
    aCredit[35][3] += CASH->MISC30_A
    
    aCredit[36][2] += CASH->MISC31_C 
    aCredit[36][3] += CASH->MISC31_A
    
    aCredit[37][2] += CASH->MISC32_C 
    aCredit[37][3] += CASH->MISC32_A
    
    aCredit[38][2] += CASH->MISC33_C 
    aCredit[38][3] += CASH->MISC33_A
    
    aCredit[39][2] += CASH->MISC34_C 
    aCredit[39][3] += CASH->MISC34_A
    
    aCredit[40][2] += CASH->MISC35_C 
    aCredit[40][3] += CASH->MISC35_A
    
    aCredit[41][2] += CASH->MISC36_C 
    aCredit[41][3] += CASH->MISC36_A
    
    aCredit[42][2] += CASH->MISC37_C 
    aCredit[42][3] += CASH->MISC37_A
    
    aCredit[43][2] += CASH->MISC38_C 
    aCredit[43][3] += CASH->MISC38_A
    
    aCredit[44][2] += CASH->MISC39_C 
    aCredit[44][3] += CASH->MISC39_A
    
    aCredit[45][2] += CASH->MISC40_C 
    aCredit[45][3] += CASH->MISC40_A
    
    aCredit[46][2] += CASH->MISC41_C 
    aCredit[46][3] += CASH->MISC41_A
    
    aCredit[47][2] += CASH->MISC42_C 
    aCredit[47][3] += CASH->MISC42_A
    
    aCredit[48][2] += CASH->MISC43_C 
    aCredit[48][3] += CASH->MISC43_A
    
    aCredit[49][2] += CASH->MISC44_C 
    aCredit[49][3] += CASH->MISC44_A
    
    aCredit[50][2] += CASH->MISC45_C 
    aCredit[50][3] += CASH->MISC45_A
    
    aCredit[51][2] += CASH->MISC46_C 
    aCredit[51][3] += CASH->MISC46_A
    
    aCredit[52][2] += CASH->MISC47_C 
    aCredit[52][3] += CASH->MISC47_A
   
    aCredit[53][2] += CASH->MISC48_C 
    aCredit[53][3] += CASH->MISC48_A
    
    aCredit[54][2] += CASH->MISC49_C 
    aCredit[54][3] += CASH->MISC49_A
    
    aCredit[55][2] += CASH->MISC50_C 
    aCredit[55][3] += CASH->MISC50_A

    aCredit[56][2] += CASH->IVOID_C 
    aCredit[56][3] += CASH->IVOID_A
    
    aCredit[57][2] += CASH->MVOID_C 
    aCredit[57][3] += CASH->MVOID_A
    
    aCredit[58][2] += CASH->IDISC_C 
    aCredit[58][3] += CASH->IDISC_A
    
    aCredit[59][2] += CASH->SUBTD_C 
    aCredit[59][3] += CASH->SUBTD_A
    
    aCredit[60][2] += CASH->ADDON_C 
    aCredit[60][3] += CASH->ADDON_A
    
    aCredit[61][2] += CASH->SSBTD_C 
    aCredit[61][3] += CASH->SSBTD_A
    
    aCredit[62][2] += CASH->SSBTA_C 
    aCredit[62][3] += CASH->SSBTA_A
    
    aCredit[63][2] += CASH->RETRN_C 
    aCredit[63][3] += CASH->RETRN_A
    
    aCredit[64][2] += CASH->REFND_C 
    aCredit[64][3] += CASH->REFND_A
    
    aCredit[65][2] += CASH->OTINC_C 
    aCredit[65][3] += CASH->OTINC_A
    
    aCredit[66][2] += CASH->CANCL_C 
    aCredit[66][3] += CASH->CANCL_A
    
    aCredit[67][2] += CASH->TVOID_C 
    aCredit[67][3] += CASH->TVOID_A
    
    aCredit[68][2] += CASH->SUSPD_C 
    aCredit[68][3] += CASH->SUSPD_A
    
    aCredit[69][2] += CASH->LAYAW_C 
    aCredit[69][3] += CASH->LAYAW_A
    
    aCredit[70][2] += CASH->PIKUP_C 
    aCredit[70][3] += CASH->PIKUP_A
    
    aCredit[71][2] += CASH->PDOUT_C 
    aCredit[71][3] += CASH->PDOUT_A
    
    aCredit[72][2] += CASH->LOAN_C 
    aCredit[72][3] += CASH->LOAN_A
    
    aCredit[73][2] += 0
    aCredit[73][3] += 0
    
    aCredit[74][2] += CASH->BOTDEP_C 
    aCredit[74][3] += CASH->BOTDEP_A
    
    aCredit[75][3] += CASH->RECACT_A

    aCredit[76][3] += CASH->TRAIN_A
    
    aCredit[77][3] += CASH->OFFLN_A
    
    aCredit[78][3] += CASH->RENTER_A
    
    aCredit[79][3] += CASH->OLDGRD_A
    
    aCredit[80][3] += CASH->NEWGRD_A
    
    aCredit[81][2] += CASH->XCOUNT_C 
    
    aCredit[82][2] += CASH->ZCOUNT_C 
         
  ENDIF
 endif 
 CASH->(DbSkip())
enddo        




 for i := 1 to MAX_MISC     

    // Create header if new page  
   if lNewPage  
     // Create header if new page  
     ? MARGIN + "INDIVIDUAL CASHIER SALES REPORT"
     ?
     ? MARGIN +chr(254)+ SYS_NAME
     ? MARGIN +"Individual Cashier Sales Report"
     ? MARGIN +"From "+dtoc(dStartDate)+" to "+dtoc(dEndDate)
     ? MARGIN +"As of "+dtoc(date())+", "+time()
     ?
     ? MARGIN +"CASHIER CODE : " + cterm +", " + cName 
     ?
     ? MARGIN + "    DESCRIPTION                             COUNT         AMOUNT      "
     ? MARGIN + "-----------------------------------       ----------   -------------- " 
     //          12345678901234567890123456789012345       1234567890   12345678901234  
     ?
     ?

   lNewpage := .f.
   nLineCtr := 13
  endif   

   

   if i >= 6 .and. i <= 55
     if aCredit[i][2] <> 0 .or. aCredit[i][3] <> 0 
     
      if aCredit[i][1] == " "
        ? MARGIN +padr("MISCELLANEOUS "+alltrim(str(i)),35)
      else
        ? MARGIN + padr(aCredit[i][1],35)
      endif 
      ?? space(7) + trans(aCredit[i][2],"9,999,999")
      ?? space(3) + trans(aCredit[i][3],"99,999,999.99")
      nLinectr += 1    
     endif 
    
   else
   
     Do Case
       Case i == 1 
         aCredit[i][1] := padr("DAILY SALES",35)
       Case i == 2 
         aCredit[i][1] := padr("CASH TOTALS",35)  
       Case i == 3 
         aCredit[i][1] := padr("GROSS SALES",35)
       Case i == 4 
         aCredit[i][1] := padr("DEPARTMENT TOTALS",35)
       Case i == 5 
         aCredit[i][1] := padr("FOREIGN CURRENCY TOTALS",35)
       Case i == 56 
         aCredit[i][1] := padr("ITEM VOID TOTAL",35)
       Case i == 57
         aCredit[i][1] := padr("MANAGER VOID TOTAL",35)
       Case i == 58
         aCredit[i][1] := padr("ITEM DISCOUNT TOTAL",35)
       Case i == 59
         aCredit[i][1] := padr("SUBTOTAL DISCOUNT TOTAL",35)
       Case i == 60
         aCredit[i][1] := padr("ADD-ON TOTAL",35)
       Case i == 61
         aCredit[i][1] := padr("SELECTIVE SUBTOTAL DISCOUNT TOTAL",35)
       Case i == 62
         aCredit[i][1] := padr("SELECTIVE SUBTOTAL ADD-ON TOTAL",35)
       Case i == 63
         aCredit[i][1] := padr("RETURN / EXCHANGE TOTAL",35)
       Case i == 64
         aCredit[i][1] := padr("REFUND TOTAL",35)
       Case i == 65
         aCredit[i][1] := padr("OTHER INCOME TOTAL",35)
       Case i == 66
         aCredit[i][1] := padr("TRANSACTION CANCEL TOTAL",35)
       Case i == 67
         aCredit[i][1] := padr("TRANSACTION VOID TOTAL",35)
       Case i == 68
         aCredit[i][1] := padr("TRANSACTION SUSPEND TOTAL",35)
       Case i == 69
         aCredit[i][1] := padr("LAY-AWAY TOTAL",35)
       Case i == 70
         aCredit[i][1] := padr("PICK-UP TOTAL",35)
       Case i == 71
         aCredit[i][1] := padr("PAID-OUT TOTAL",35)
       Case i == 72
         aCredit[i][1] := padr("LOAN TOTAL",35)
       Case i == 73
         aCredit[i][1] := padr("RECEIVED ON ACCOUNT TOTAL",35)
       Case i == 74
         aCredit[i][1] := padr("BOTTLE DEPOSIT TOTAL",35)
       Case i == 75
         aCredit[i][1] := padr("CASH DECLARATION TOTAL",35)    
       Case i == 76
         aCredit[i][1] := padr("TRAINING MODE TOTAL",35)
       Case i == 77
         aCredit[i][1] := padr("NEGATIVE CASH",35)
       Case i == 78
         aCredit[i][1] := padr("RE-ENTER TOTAL",35)
       Case i == 79
         aCredit[i][1] := padr("OLD GRAND TOTAL",35)
       Case i == 80
         aCredit[i][1] := padr("NEW GRAND TOTAL",35)
       Case i == 81
         aCredit[i][1] := padr("X - COUNTER",35)
       Case i == 82
         aCredit[i][1] := padr("Z - COUNTER",35)
                                                                   
     Endcase
     ? MARGIN + aCredit[i][1] 
     ?? space(7) + trans(aCredit[i][2],"9,999,999")
     ?? space(3) + trans(aCredit[i][3],"99,999,999.99")
     nLinectr += 1    
    
   endif 
   

     IF nLinectr == MAX_LINE
       ? chr(12)
       lNewpage := .t.
     ENDIF
     
    
 next i  
      
 ?
 ?
 ?     
 ? MARGIN+padc("********** End of Report **********",nLineLen )  
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
   wWindBuff:=OpenWindow(1,2,maxrow()-1,maxcol()-2,"Individual Cashier Sales Report")
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