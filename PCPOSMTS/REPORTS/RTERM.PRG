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
#define REPORTFILE  "TERMINAL.PRN"
#define MAX_SIZE    65535
#define MAX_LINE    50    
#define EJECT_FROM_FILE
#define DEBUG
#define MAX_MISC    81    
 
memvar n,dStartDate,dEndDate,nLimit, GetList, cReport



/*=========================================*/
function RCterm()
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


if netuse("TERMINAL", DB_SHARED, NUM_SECONDS)
    set index to TERMINAL
else
   alert("File 'TERMINAL.DBF' cannot be accessed",{"Quit"})
   DbCloseAll()
   return nil    
endif	 

cOldPath := SET(_SET_PATH)

Message("Preparing Consolidated Terminal Sales Report ...")


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



Do While TERMINAL->(!Eof())  

  @ 1, 1 wsay " Creating " + "Consolidated Terminal Sales Report" + "  Please wait ..."
  @ 2, 1 wsay " Terminal No: " + TERMINAL->TERM + "    "

 if DatesOk(TERMINAL->DATE) 

    aCredit[1][2] += TERMINAL->DAILY_C 
    aCredit[1][3] += TERMINAL->DAILY_A

    aCredit[2][3] += TERMINAL->CASH_A

    aCredit[3][3] += TERMINAL->GROSS_A

    aCredit[4][3] += TERMINAL->DEPT_A

    aCredit[5][2] += TERMINAL->FORCUR_C 
    aCredit[5][3] += TERMINAL->FORCUR_A
 
    aCredit[6][2] += TERMINAL->MISC1_C 
    aCredit[6][3] += TERMINAL->MISC1_A
    
    aCredit[7][2] += TERMINAL->MISC2_C 
    aCredit[7][3] += TERMINAL->MISC2_A 
    
    aCredit[8][2] += TERMINAL->MISC3_C 
    aCredit[8][3] += TERMINAL->MISC3_A 

    aCredit[9][2] += TERMINAL->MISC4_C 
    aCredit[9][3] += TERMINAL->MISC4_A
    
    aCredit[10][2] += TERMINAL->MISC5_C 
    aCredit[10][3] += TERMINAL->MISC5_A
    
    aCredit[11][2] += TERMINAL->MISC6_C 
    aCredit[11][3] += TERMINAL->MISC6_A
    
    aCredit[12][2] += TERMINAL->MISC7_C 
    aCredit[12][3] += TERMINAL->MISC7_A
    
    aCredit[13][2] += TERMINAL->MISC8_C 
    aCredit[13][3] += TERMINAL->MISC8_A
    
    aCredit[14][2] += TERMINAL->MISC9_C 
    aCredit[14][3] += TERMINAL->MISC9_A
    
    aCredit[15][2] += TERMINAL->MISC10_C 
    aCredit[15][3] += TERMINAL->MISC10_A
    
    aCredit[16][2] += TERMINAL->MISC11_C 
    aCredit[16][3] += TERMINAL->MISC11_A
    
    aCredit[17][2] += TERMINAL->MISC12_C 
    aCredit[17][3] += TERMINAL->MISC12_A
    
    aCredit[18][2] += TERMINAL->MISC13_C 
    aCredit[18][3] += TERMINAL->MISC13_A
    
    aCredit[19][2] += TERMINAL->MISC14_C 
    aCredit[19][3] += TERMINAL->MISC14_A
    
    aCredit[20][2] += TERMINAL->MISC15_C 
    aCredit[20][3] += TERMINAL->MISC15_A
    
    aCredit[21][2] += TERMINAL->MISC16_C 
    aCredit[21][3] += TERMINAL->MISC16_A
    
    aCredit[22][2] += TERMINAL->MISC17_C 
    aCredit[22][3] += TERMINAL->MISC17_A
    
    aCredit[23][2] += TERMINAL->MISC18_C 
    aCredit[23][3] += TERMINAL->MISC18_A
    
    aCredit[24][2] += TERMINAL->MISC19_C 
    aCredit[24][3] += TERMINAL->MISC19_A
    
    aCredit[25][2] += TERMINAL->MISC20_C 
    aCredit[25][3] += TERMINAL->MISC20_A
    
    aCredit[26][2] += TERMINAL->MISC21_C 
    aCredit[26][3] += TERMINAL->MISC21_A
    
    aCredit[27][2] += TERMINAL->MISC22_C 
    aCredit[27][3] += TERMINAL->MISC22_A
    
    aCredit[28][2] += TERMINAL->MISC23_C 
    aCredit[28][3] += TERMINAL->MISC23_A
    
    aCredit[29][2] += TERMINAL->MISC24_C 
    aCredit[29][3] += TERMINAL->MISC24_A
    
    aCredit[30][2] += TERMINAL->MISC25_C 
    aCredit[30][3] += TERMINAL->MISC25_A
    
    aCredit[31][2] += TERMINAL->MISC26_C 
    aCredit[31][3] += TERMINAL->MISC26_A
    
    aCredit[32][2] += TERMINAL->MISC27_C 
    aCredit[32][3] += TERMINAL->MISC27_A
    
    aCredit[33][2] += TERMINAL->MISC28_C 
    aCredit[33][3] += TERMINAL->MISC28_A
    
    aCredit[34][2] += TERMINAL->MISC29_C 
    aCredit[34][3] += TERMINAL->MISC29_A
    
    aCredit[35][2] += TERMINAL->MISC30_C 
    aCredit[35][3] += TERMINAL->MISC30_A
    
    aCredit[36][2] += TERMINAL->MISC31_C 
    aCredit[36][3] += TERMINAL->MISC31_A
    
    aCredit[37][2] += TERMINAL->MISC32_C 
    aCredit[37][3] += TERMINAL->MISC32_A
    
    aCredit[38][2] += TERMINAL->MISC33_C 
    aCredit[38][3] += TERMINAL->MISC33_A
    
    aCredit[39][2] += TERMINAL->MISC34_C 
    aCredit[39][3] += TERMINAL->MISC34_A
    
    aCredit[40][2] += TERMINAL->MISC35_C 
    aCredit[40][3] += TERMINAL->MISC35_A
    
    aCredit[41][2] += TERMINAL->MISC36_C 
    aCredit[41][3] += TERMINAL->MISC36_A
    
    aCredit[42][2] += TERMINAL->MISC37_C 
    aCredit[42][3] += TERMINAL->MISC37_A
    
    aCredit[43][2] += TERMINAL->MISC38_C 
    aCredit[43][3] += TERMINAL->MISC38_A
    
    aCredit[44][2] += TERMINAL->MISC39_C 
    aCredit[44][3] += TERMINAL->MISC39_A
    
    aCredit[45][2] += TERMINAL->MISC40_C 
    aCredit[45][3] += TERMINAL->MISC40_A
    
    aCredit[46][2] += TERMINAL->MISC41_C 
    aCredit[46][3] += TERMINAL->MISC41_A
    
    aCredit[47][2] += TERMINAL->MISC42_C 
    aCredit[47][3] += TERMINAL->MISC42_A
    
    aCredit[48][2] += TERMINAL->MISC43_C 
    aCredit[48][3] += TERMINAL->MISC43_A
    
    aCredit[49][2] += TERMINAL->MISC44_C 
    aCredit[49][3] += TERMINAL->MISC44_A
    
    aCredit[50][2] += TERMINAL->MISC45_C 
    aCredit[50][3] += TERMINAL->MISC45_A
    
    aCredit[51][2] += TERMINAL->MISC46_C 
    aCredit[51][3] += TERMINAL->MISC46_A
    
    aCredit[52][2] += TERMINAL->MISC47_C 
    aCredit[52][3] += TERMINAL->MISC47_A
   
    aCredit[53][2] += TERMINAL->MISC48_C 
    aCredit[53][3] += TERMINAL->MISC48_A
    
    aCredit[54][2] += TERMINAL->MISC49_C 
    aCredit[54][3] += TERMINAL->MISC49_A
    
    aCredit[55][2] += TERMINAL->MISC50_C 
    aCredit[55][3] += TERMINAL->MISC50_A

    aCredit[56][2] += TERMINAL->IVOID_C 
    aCredit[56][3] += TERMINAL->IVOID_A
    
    aCredit[57][2] += TERMINAL->MVOID_C 
    aCredit[57][3] += TERMINAL->MVOID_A
    
    aCredit[58][2] += TERMINAL->IDISC_C 
    aCredit[58][3] += TERMINAL->IDISC_A
    
    aCredit[59][2] += TERMINAL->SUBTD_C 
    aCredit[59][3] += TERMINAL->SUBTD_A
    
    aCredit[60][2] += TERMINAL->ADDON_C 
    aCredit[60][3] += TERMINAL->ADDON_A
    
    aCredit[61][2] += TERMINAL->SSBTD_C 
    aCredit[61][3] += TERMINAL->SSBTD_A
    
    aCredit[62][2] += TERMINAL->SSBTA_C 
    aCredit[62][3] += TERMINAL->SSBTA_A
    
    aCredit[63][2] += TERMINAL->RETRN_C 
    aCredit[63][3] += TERMINAL->RETRN_A
    
    aCredit[64][2] += TERMINAL->REFND_C 
    aCredit[64][3] += TERMINAL->REFND_A
    
    aCredit[65][2] += TERMINAL->OTINC_C 
    aCredit[65][3] += TERMINAL->OTINC_A
    
    aCredit[66][2] += TERMINAL->CANCL_C 
    aCredit[66][3] += TERMINAL->CANCL_A
    
    aCredit[67][2] += TERMINAL->TVOID_C 
    aCredit[67][3] += TERMINAL->TVOID_A
    
    aCredit[68][2] += TERMINAL->SUSPD_C 
    aCredit[68][3] += TERMINAL->SUSPD_A
    
    aCredit[69][2] += TERMINAL->LAYAW_C 
    aCredit[69][3] += TERMINAL->LAYAW_A
    
    aCredit[70][2] += TERMINAL->PIKUP_C 
    aCredit[70][3] += TERMINAL->PIKUP_A
    
    aCredit[71][2] += TERMINAL->PDOUT_C 
    aCredit[71][3] += TERMINAL->PDOUT_A
    
    aCredit[72][2] += TERMINAL->LOAN_C 
    aCredit[72][3] += TERMINAL->LOAN_A
    
    aCredit[73][2] += TERMINAL->RECACT_C 
    aCredit[73][3] += TERMINAL->RECACT_A
    
    aCredit[74][2] += TERMINAL->BOTDEP_C 
    aCredit[74][3] += TERMINAL->BOTDEP_A
    
    aCredit[75][3] += TERMINAL->TRAIN_A
    
    aCredit[76][3] += TERMINAL->OFFLN_A
    
    aCredit[77][3] += TERMINAL->RENTER_A
    
    aCredit[78][3] += TERMINAL->OLDGRD_A
    
    aCredit[79][3] += TERMINAL->NEWGRD_A
    
    aCredit[80][2] += TERMINAL->XCOUNT_C 
    
    aCredit[81][2] += TERMINAL->ZCOUNT_C 
         

 endif 
 TERMINAL->(DbSkip())
enddo        




 for i := 1 to MAX_MISC     

    // Create header if new page  
   if lNewPage  
     // Create header if new page  
     ? MARGIN + "CONSOLIDATED TERMINAL SALES REPORT"
     ?
     ? MARGIN +chr(254)+ SYS_NAME
     ? MARGIN +"Consolidated Terminal Sales Report"
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
         aCredit[i][1] := padr("CASH COUNT DECLARATION",35)
       Case i == 74
         aCredit[i][1] := padr("BOTTLE DEPOSIT TOTAL",35)
       Case i == 75
         aCredit[i][1] := padr("TRAINING MODE TOTAL",35)
       Case i == 76
         aCredit[i][1] := padr("NEGATIVE CASH",35)
       Case i == 77
         aCredit[i][1] := padr("RE-ENTER TOTAL",35)
       Case i == 78
         aCredit[i][1] := padr("OLD GRAND TOTAL",35)
       Case i == 79
         aCredit[i][1] := padr("NEW GRAND TOTAL",35)
       Case i == 80
         aCredit[i][1] := padr("X - COUNTER",35)
       Case i == 81
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
   wWindBuff:=OpenWindow(1,2,maxrow()-1,maxcol()-2,"Consolidated Terminal Sales Report")
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
function RIterm()
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
local ntotalamt := 0, nRuntotamt := 0, n := 0, cterm := space(4)
local vBrowse


   SET CURSOR ON
   vBrowse := OpenWindow(15,30,17,50)
   @ 16,31 say "Terminal No.: "Get cTerm Pict "9999"
   read
   SET CURSOR OFF
   CloseWindow(vBrowse)

   cTerm := padl(alltrim(cTerm),4,"0") 


if !Getvalid()
  BUMMER() ; return nil 
endif 


if netuse("CC", DB_SHARED, NUM_SECONDS)
    set index to CC_001
endif    


if netuse("TERMINAL", DB_SHARED, NUM_SECONDS)
    set index to TERMINAL
else
   alert("File 'TERMINAL.DBF' cannot be accessed",{"Quit"})
   DbCloseAll()
   return nil    
endif	 



cOldPath := SET(_SET_PATH)

Message("Preparing Individual Terminal Sales Report ...")


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



Do While TERMINAL->(!Eof())  

  @ 1, 1 wsay " Creating " + "Individual Terminal Sales Report" + "  Please wait ..."
  @ 2, 1 wsay " Terminal No: " + TERMINAL->TERM + "    "

 if DatesOk(TERMINAL->DATE)
  IF  TERMINAL->TERM == cterm

    aCredit[1][2] += TERMINAL->DAILY_C 
    aCredit[1][3] += TERMINAL->DAILY_A

    aCredit[2][3] += TERMINAL->CASH_A

    aCredit[3][3] += TERMINAL->GROSS_A

    aCredit[4][3] += TERMINAL->DEPT_A

    aCredit[5][2] += TERMINAL->FORCUR_C 
    aCredit[5][3] += TERMINAL->FORCUR_A
 
    aCredit[6][2] += TERMINAL->MISC1_C 
    aCredit[6][3] += TERMINAL->MISC1_A
    
    aCredit[7][2] += TERMINAL->MISC2_C 
    aCredit[7][3] += TERMINAL->MISC2_A 
    
    aCredit[8][2] += TERMINAL->MISC3_C 
    aCredit[8][3] += TERMINAL->MISC3_A 

    aCredit[9][2] += TERMINAL->MISC4_C 
    aCredit[9][3] += TERMINAL->MISC4_A
    
    aCredit[10][2] += TERMINAL->MISC5_C 
    aCredit[10][3] += TERMINAL->MISC5_A
    
    aCredit[11][2] += TERMINAL->MISC6_C 
    aCredit[11][3] += TERMINAL->MISC6_A
    
    aCredit[12][2] += TERMINAL->MISC7_C 
    aCredit[12][3] += TERMINAL->MISC7_A
    
    aCredit[13][2] += TERMINAL->MISC8_C 
    aCredit[13][3] += TERMINAL->MISC8_A
    
    aCredit[14][2] += TERMINAL->MISC9_C 
    aCredit[14][3] += TERMINAL->MISC9_A
    
    aCredit[15][2] += TERMINAL->MISC10_C 
    aCredit[15][3] += TERMINAL->MISC10_A
    
    aCredit[16][2] += TERMINAL->MISC11_C 
    aCredit[16][3] += TERMINAL->MISC11_A
    
    aCredit[17][2] += TERMINAL->MISC12_C 
    aCredit[17][3] += TERMINAL->MISC12_A
    
    aCredit[18][2] += TERMINAL->MISC13_C 
    aCredit[18][3] += TERMINAL->MISC13_A
    
    aCredit[19][2] += TERMINAL->MISC14_C 
    aCredit[19][3] += TERMINAL->MISC14_A
    
    aCredit[20][2] += TERMINAL->MISC15_C 
    aCredit[20][3] += TERMINAL->MISC15_A
    
    aCredit[21][2] += TERMINAL->MISC16_C 
    aCredit[21][3] += TERMINAL->MISC16_A
    
    aCredit[22][2] += TERMINAL->MISC17_C 
    aCredit[22][3] += TERMINAL->MISC17_A
    
    aCredit[23][2] += TERMINAL->MISC18_C 
    aCredit[23][3] += TERMINAL->MISC18_A
    
    aCredit[24][2] += TERMINAL->MISC19_C 
    aCredit[24][3] += TERMINAL->MISC19_A
    
    aCredit[25][2] += TERMINAL->MISC20_C 
    aCredit[25][3] += TERMINAL->MISC20_A
    
    aCredit[26][2] += TERMINAL->MISC21_C 
    aCredit[26][3] += TERMINAL->MISC21_A
    
    aCredit[27][2] += TERMINAL->MISC22_C 
    aCredit[27][3] += TERMINAL->MISC22_A
    
    aCredit[28][2] += TERMINAL->MISC23_C 
    aCredit[28][3] += TERMINAL->MISC23_A
    
    aCredit[29][2] += TERMINAL->MISC24_C 
    aCredit[29][3] += TERMINAL->MISC24_A
    
    aCredit[30][2] += TERMINAL->MISC25_C 
    aCredit[30][3] += TERMINAL->MISC25_A
    
    aCredit[31][2] += TERMINAL->MISC26_C 
    aCredit[31][3] += TERMINAL->MISC26_A
    
    aCredit[32][2] += TERMINAL->MISC27_C 
    aCredit[32][3] += TERMINAL->MISC27_A
    
    aCredit[33][2] += TERMINAL->MISC28_C 
    aCredit[33][3] += TERMINAL->MISC28_A
    
    aCredit[34][2] += TERMINAL->MISC29_C 
    aCredit[34][3] += TERMINAL->MISC29_A
    
    aCredit[35][2] += TERMINAL->MISC30_C 
    aCredit[35][3] += TERMINAL->MISC30_A
    
    aCredit[36][2] += TERMINAL->MISC31_C 
    aCredit[36][3] += TERMINAL->MISC31_A
    
    aCredit[37][2] += TERMINAL->MISC32_C 
    aCredit[37][3] += TERMINAL->MISC32_A
    
    aCredit[38][2] += TERMINAL->MISC33_C 
    aCredit[38][3] += TERMINAL->MISC33_A
    
    aCredit[39][2] += TERMINAL->MISC34_C 
    aCredit[39][3] += TERMINAL->MISC34_A
    
    aCredit[40][2] += TERMINAL->MISC35_C 
    aCredit[40][3] += TERMINAL->MISC35_A
    
    aCredit[41][2] += TERMINAL->MISC36_C 
    aCredit[41][3] += TERMINAL->MISC36_A
    
    aCredit[42][2] += TERMINAL->MISC37_C 
    aCredit[42][3] += TERMINAL->MISC37_A
    
    aCredit[43][2] += TERMINAL->MISC38_C 
    aCredit[43][3] += TERMINAL->MISC38_A
    
    aCredit[44][2] += TERMINAL->MISC39_C 
    aCredit[44][3] += TERMINAL->MISC39_A
    
    aCredit[45][2] += TERMINAL->MISC40_C 
    aCredit[45][3] += TERMINAL->MISC40_A
    
    aCredit[46][2] += TERMINAL->MISC41_C 
    aCredit[46][3] += TERMINAL->MISC41_A
    
    aCredit[47][2] += TERMINAL->MISC42_C 
    aCredit[47][3] += TERMINAL->MISC42_A
    
    aCredit[48][2] += TERMINAL->MISC43_C 
    aCredit[48][3] += TERMINAL->MISC43_A
    
    aCredit[49][2] += TERMINAL->MISC44_C 
    aCredit[49][3] += TERMINAL->MISC44_A
    
    aCredit[50][2] += TERMINAL->MISC45_C 
    aCredit[50][3] += TERMINAL->MISC45_A
    
    aCredit[51][2] += TERMINAL->MISC46_C 
    aCredit[51][3] += TERMINAL->MISC46_A
    
    aCredit[52][2] += TERMINAL->MISC47_C 
    aCredit[52][3] += TERMINAL->MISC47_A
   
    aCredit[53][2] += TERMINAL->MISC48_C 
    aCredit[53][3] += TERMINAL->MISC48_A
    
    aCredit[54][2] += TERMINAL->MISC49_C 
    aCredit[54][3] += TERMINAL->MISC49_A
    
    aCredit[55][2] += TERMINAL->MISC50_C 
    aCredit[55][3] += TERMINAL->MISC50_A

    aCredit[56][2] += TERMINAL->IVOID_C 
    aCredit[56][3] += TERMINAL->IVOID_A
    
    aCredit[57][2] += TERMINAL->MVOID_C 
    aCredit[57][3] += TERMINAL->MVOID_A
    
    aCredit[58][2] += TERMINAL->IDISC_C 
    aCredit[58][3] += TERMINAL->IDISC_A
    
    aCredit[59][2] += TERMINAL->SUBTD_C 
    aCredit[59][3] += TERMINAL->SUBTD_A
    
    aCredit[60][2] += TERMINAL->ADDON_C 
    aCredit[60][3] += TERMINAL->ADDON_A
    
    aCredit[61][2] += TERMINAL->SSBTD_C 
    aCredit[61][3] += TERMINAL->SSBTD_A
    
    aCredit[62][2] += TERMINAL->SSBTA_C 
    aCredit[62][3] += TERMINAL->SSBTA_A
    
    aCredit[63][2] += TERMINAL->RETRN_C 
    aCredit[63][3] += TERMINAL->RETRN_A
    
    aCredit[64][2] += TERMINAL->REFND_C 
    aCredit[64][3] += TERMINAL->REFND_A
    
    aCredit[65][2] += TERMINAL->OTINC_C 
    aCredit[65][3] += TERMINAL->OTINC_A
    
    aCredit[66][2] += TERMINAL->CANCL_C 
    aCredit[66][3] += TERMINAL->CANCL_A
    
    aCredit[67][2] += TERMINAL->TVOID_C 
    aCredit[67][3] += TERMINAL->TVOID_A
    
    aCredit[68][2] += TERMINAL->SUSPD_C 
    aCredit[68][3] += TERMINAL->SUSPD_A
    
    aCredit[69][2] += TERMINAL->LAYAW_C 
    aCredit[69][3] += TERMINAL->LAYAW_A
    
    aCredit[70][2] += TERMINAL->PIKUP_C 
    aCredit[70][3] += TERMINAL->PIKUP_A
    
    aCredit[71][2] += TERMINAL->PDOUT_C 
    aCredit[71][3] += TERMINAL->PDOUT_A
    
    aCredit[72][2] += TERMINAL->LOAN_C 
    aCredit[72][3] += TERMINAL->LOAN_A
    
    aCredit[73][2] += TERMINAL->RECACT_C 
    aCredit[73][3] += TERMINAL->RECACT_A
    
    aCredit[74][2] += TERMINAL->BOTDEP_C 
    aCredit[74][3] += TERMINAL->BOTDEP_A
    
    aCredit[75][3] += TERMINAL->TRAIN_A
    
    aCredit[76][3] += TERMINAL->OFFLN_A
    
    aCredit[77][3] += TERMINAL->RENTER_A
    
    aCredit[78][3] += TERMINAL->OLDGRD_A
    
    aCredit[79][3] += TERMINAL->NEWGRD_A
    
    aCredit[80][2] += TERMINAL->XCOUNT_C 
    
    aCredit[81][2] += TERMINAL->ZCOUNT_C 
         
  ENDIF
 endif 
 TERMINAL->(DbSkip())
enddo        




 for i := 1 to MAX_MISC     

    // Create header if new page  
   if lNewPage  
     // Create header if new page  
     ? MARGIN + "INDIVIDUAL TERMINAL SALES REPORT"
     ?
     ? MARGIN +chr(254)+ SYS_NAME
     ? MARGIN +"Individual Terminal Sales Report"
     ? MARGIN +"From "+dtoc(dStartDate)+" to "+dtoc(dEndDate)
     ? MARGIN +"As of "+dtoc(date())+", "+time()
     ?
     ? MARGIN +"TERMINAL NO. : " + cterm
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
         aCredit[i][1] := padr("CASH COUNT DECLARATION",35)
       Case i == 74
         aCredit[i][1] := padr("BOTTLE DEPOSIT TOTAL",35)
       Case i == 75
         aCredit[i][1] := padr("TRAINING MODE TOTAL",35)
       Case i == 76
         aCredit[i][1] := padr("NEGATIVE CASH",35)
       Case i == 77
         aCredit[i][1] := padr("RE-ENTER TOTAL",35)
       Case i == 78
         aCredit[i][1] := padr("OLD GRAND TOTAL",35)
       Case i == 79
         aCredit[i][1] := padr("NEW GRAND TOTAL",35)
       Case i == 80
         aCredit[i][1] := padr("X - COUNTER",35)
       Case i == 81
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
   wWindBuff:=OpenWindow(1,2,maxrow()-1,maxcol()-2,"Individual Terminal Sales Report")
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