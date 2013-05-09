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
#define REPORTFILE  "CCHARGE.PRN"
#define REPORTFILE1  "ICHARGE.PRN"
#define REPORTFILE2  "ACHARGE.PRN"
#define MAX_SIZE    65535
#define MAX_LINE    50    
#define EJECT_FROM_FILE
#define DEBUG
#define MAX_MISC    50    
 
memvar n,dStartDate,dEndDate,nLimit, GetList, cReport



/*=========================================*/
function do_R_Credit()
/*=========================================*/
local cRef,wWindBuff
local nMaxrow := maxrow()+1, nMaxCol := maxcol()+1
local aFsize := {}
// Gauge variables
local nRecCtr := 0, hGauge, nPercent, nGaugeCtr:=1, wUpdate, dDate
local cName := space(20), dFile, code
local lNewPage := 0, nLineCtr := 0, nLinelen  := 60, nPageCtr := 1
local nPageslstot := 0, nPageslsqty := 0, cWindow
local nReccount := 0, nCtr := 1, ccolor, coldpath
local nRunslstot := 0, nRunslsqty := 0, count := 0, amount := 0
local lFirst := .f., aCredit := {}, i := 0, nQuantity := 0
local ntotalamt := 0, nRuntotamt := 0

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

Message("Preparing Consolidated Charge Sales Report ...")


SET ALTERNATE TO ".\"+REPORTFILE
SET ALTERNATE ON
SET CONSOLE OFF
SET PRINTER OFF

window( 19, 1, 22, 60, CONFIRM_COLOR )

lNewPage := .t.
lFirst := .t.

* aSize(aCredit,MAX_MISC)
* aFill(aCredit,{"0000"," ",0,0})

 for i := 1 to MAX_MISC

  aadd(aCredit,{"0000"," ",0,0})
 
 next i
  
 DO WHILE CC->(!EOF())

   aCredit[val(CC->CC_001)][1] := CC->CC_001
   aCredit[val(CC->CC_001)][2] := CC->CC_002
   
   CC->(DBSKIP())
 ENDDO   



Do While TERMINAL->(!Eof())  

  @ 1, 1 wsay " Creating " + "Consolidated Charge Sales Report" + "  Please wait ..."
  @ 2, 1 wsay " Terminal No: " + TERMINAL->TERM + "    "

 if DatesOk(TERMINAL->DATE) 
 
    aCredit[1][3] += TERMINAL->MISC1_C 
    aCredit[1][4] += TERMINAL->MISC1_A
    nQuantity     += TERMINAL->MISC1_C 
    
    aCredit[2][3] += TERMINAL->MISC2_C 
    aCredit[2][4] += TERMINAL->MISC2_A 
    nQuantity     += TERMINAL->MISC2_C 
    
    aCredit[3][3] += TERMINAL->MISC3_C 
    aCredit[3][4] += TERMINAL->MISC3_A 
    nQuantity     += TERMINAL->MISC3_C 

    aCredit[4][3] += TERMINAL->MISC4_C 
    aCredit[4][4] += TERMINAL->MISC4_A
    nQuantity     += TERMINAL->MISC4_C 
    
    aCredit[5][3] += TERMINAL->MISC5_C 
    aCredit[5][4] += TERMINAL->MISC5_A
    nQuantity     += TERMINAL->MISC5_C 
    
    aCredit[6][3] += TERMINAL->MISC6_C 
    aCredit[6][4] += TERMINAL->MISC6_A
    nQuantity     += TERMINAL->MISC6_C 
    
    aCredit[7][3] += TERMINAL->MISC7_C 
    aCredit[7][4] += TERMINAL->MISC7_A
    nQuantity     += TERMINAL->MISC7_C 
    
    aCredit[8][3] += TERMINAL->MISC8_C 
    aCredit[8][4] += TERMINAL->MISC8_A
    nQuantity     += TERMINAL->MISC8_C 
    
    aCredit[9][3] += TERMINAL->MISC9_C 
    aCredit[9][4] += TERMINAL->MISC9_A
    nQuantity     += TERMINAL->MISC9_C 
    
    aCredit[10][3] += TERMINAL->MISC10_C 
    aCredit[10][4] += TERMINAL->MISC10_A
    nQuantity     += TERMINAL->MISC10_C 
    
    aCredit[11][3] += TERMINAL->MISC11_C 
    aCredit[11][4] += TERMINAL->MISC11_A
    nQuantity     += TERMINAL->MISC11_C 
    
    aCredit[12][3] += TERMINAL->MISC12_C 
    aCredit[12][4] += TERMINAL->MISC12_A
    nQuantity     += TERMINAL->MISC12_C 
    
    aCredit[13][3] += TERMINAL->MISC13_C 
    aCredit[13][4] += TERMINAL->MISC13_A
    nQuantity     += TERMINAL->MISC13_C 
    
    aCredit[14][3] += TERMINAL->MISC14_C 
    aCredit[14][4] += TERMINAL->MISC14_A
    nQuantity     += TERMINAL->MISC14_C 
    
    aCredit[15][3] += TERMINAL->MISC15_C 
    aCredit[15][4] += TERMINAL->MISC15_A
    nQuantity     += TERMINAL->MISC15_C 
    
    aCredit[16][3] += TERMINAL->MISC16_C 
    aCredit[16][4] += TERMINAL->MISC16_A
    nQuantity     += TERMINAL->MISC16_C 
    
    aCredit[17][3] += TERMINAL->MISC17_C 
    aCredit[17][4] += TERMINAL->MISC17_A
    nQuantity     += TERMINAL->MISC17_C 
    
    aCredit[18][3] += TERMINAL->MISC18_C 
    aCredit[18][4] += TERMINAL->MISC18_A
    nQuantity     += TERMINAL->MISC18_C 
    
    aCredit[19][3] += TERMINAL->MISC19_C 
    aCredit[19][4] += TERMINAL->MISC19_A
    nQuantity     += TERMINAL->MISC19_C 
    
    aCredit[20][3] += TERMINAL->MISC20_C 
    aCredit[20][4] += TERMINAL->MISC20_A
    nQuantity     += TERMINAL->MISC20_C 
    
    aCredit[21][3] += TERMINAL->MISC21_C 
    aCredit[21][4] += TERMINAL->MISC21_A
    nQuantity     += TERMINAL->MISC21_C 
    
    aCredit[22][3] += TERMINAL->MISC22_C 
    aCredit[22][4] += TERMINAL->MISC22_A
    nQuantity     += TERMINAL->MISC22_C 
    
    aCredit[23][3] += TERMINAL->MISC23_C 
    aCredit[23][4] += TERMINAL->MISC23_A
    nQuantity     += TERMINAL->MISC23_C 
    
    aCredit[24][3] += TERMINAL->MISC24_C 
    aCredit[24][4] += TERMINAL->MISC24_A
    nQuantity     += TERMINAL->MISC24_C 
    
    aCredit[25][3] += TERMINAL->MISC25_C 
    aCredit[25][4] += TERMINAL->MISC25_A
    nQuantity     += TERMINAL->MISC25_C 
    
    aCredit[26][3] += TERMINAL->MISC26_C 
    aCredit[26][4] += TERMINAL->MISC26_A
    nQuantity     += TERMINAL->MISC26_C 
    
    aCredit[27][3] += TERMINAL->MISC27_C 
    aCredit[27][4] += TERMINAL->MISC27_A
    nQuantity     += TERMINAL->MISC27_C 
    
    aCredit[28][3] += TERMINAL->MISC28_C 
    aCredit[28][4] += TERMINAL->MISC28_A
    nQuantity     += TERMINAL->MISC28_C 
    
    aCredit[29][3] += TERMINAL->MISC29_C 
    aCredit[29][4] += TERMINAL->MISC29_A
    nQuantity     += TERMINAL->MISC29_C 
    
    aCredit[30][3] += TERMINAL->MISC30_C 
    aCredit[30][4] += TERMINAL->MISC30_A
    nQuantity     += TERMINAL->MISC30_C 
    
    aCredit[31][3] += TERMINAL->MISC31_C 
    aCredit[31][4] += TERMINAL->MISC31_A
    nQuantity     += TERMINAL->MISC31_C 
    
    aCredit[32][3] += TERMINAL->MISC32_C 
    aCredit[32][4] += TERMINAL->MISC32_A
    nQuantity     += TERMINAL->MISC32_C 
    
    aCredit[33][3] += TERMINAL->MISC33_C 
    aCredit[33][4] += TERMINAL->MISC33_A
    nQuantity     += TERMINAL->MISC33_C 
    
    aCredit[34][3] += TERMINAL->MISC34_C 
    aCredit[34][4] += TERMINAL->MISC34_A
    nQuantity     += TERMINAL->MISC34_C 
    
    aCredit[35][3] += TERMINAL->MISC35_C 
    aCredit[35][4] += TERMINAL->MISC35_A
    nQuantity     += TERMINAL->MISC35_C 
    
    aCredit[36][3] += TERMINAL->MISC36_C 
    aCredit[36][4] += TERMINAL->MISC36_A
    nQuantity     += TERMINAL->MISC36_C 
    
    aCredit[37][3] += TERMINAL->MISC37_C 
    aCredit[37][4] += TERMINAL->MISC37_A
    nQuantity     += TERMINAL->MISC37_C 
    
    aCredit[38][3] += TERMINAL->MISC38_C 
    aCredit[38][4] += TERMINAL->MISC38_A
    nQuantity     += TERMINAL->MISC38_C 
    
    aCredit[39][3] += TERMINAL->MISC39_C 
    aCredit[39][4] += TERMINAL->MISC39_A
    nQuantity     += TERMINAL->MISC39_C 
    
    aCredit[40][3] += TERMINAL->MISC40_C 
    aCredit[40][4] += TERMINAL->MISC40_A
    nQuantity     += TERMINAL->MISC40_C 
    
    aCredit[41][3] += TERMINAL->MISC41_C 
    aCredit[41][4] += TERMINAL->MISC41_A
    nQuantity     += TERMINAL->MISC41_C 
    
    aCredit[42][3] += TERMINAL->MISC42_C 
    aCredit[42][4] += TERMINAL->MISC42_A
    nQuantity     += TERMINAL->MISC42_C 
    
    aCredit[43][3] += TERMINAL->MISC43_C 
    aCredit[43][4] += TERMINAL->MISC43_A
    nQuantity     += TERMINAL->MISC43_C 
    
    aCredit[44][3] += TERMINAL->MISC44_C 
    aCredit[44][4] += TERMINAL->MISC44_A
    nQuantity     += TERMINAL->MISC44_C 
    
    aCredit[45][3] += TERMINAL->MISC45_C 
    aCredit[45][4] += TERMINAL->MISC45_A
    nQuantity     += TERMINAL->MISC45_C 
    
    aCredit[46][3] += TERMINAL->MISC46_C 
    aCredit[46][4] += TERMINAL->MISC46_A
    nQuantity     += TERMINAL->MISC46_C 
    
    aCredit[47][3] += TERMINAL->MISC47_C 
    aCredit[47][4] += TERMINAL->MISC47_A
    nQuantity     += TERMINAL->MISC47_C 
    
    aCredit[48][3] += TERMINAL->MISC48_C 
    aCredit[48][4] += TERMINAL->MISC48_A
    nQuantity     += TERMINAL->MISC48_C 
    
    aCredit[49][3] += TERMINAL->MISC49_C 
    aCredit[49][4] += TERMINAL->MISC49_A
    nQuantity     += TERMINAL->MISC49_C 
    
    aCredit[50][3] += TERMINAL->MISC50_C 
    aCredit[50][4] += TERMINAL->MISC50_A
    nQuantity     += TERMINAL->MISC50_C 
         

 endif 
 TERMINAL->(DbSkip())
enddo        


  // Create header if new page  
  if lNewPage  
   // Create header if new page  
   ? MARGIN + "CONSOLIDATED CHARGE SALES REPORT"
   ?
   ? MARGIN +chr(254)+ SYS_NAME
   ? MARGIN +"Consolidated Charge Sales Report"
   ? MARGIN +"From "+dtoc(dStartDate)+" to "+dtoc(dEndDate)
   ? MARGIN +"As of "+dtoc(date())+", "+time()
   ?
   ?
   ?
   ? MARGIN + "                                                           "                    
   ? MARGIN + "CODE       DESCRIPTION        QUANTITY     AMOUNT SOLD     "
   ? MARGIN + "----   --------------------   ----------   --------------  "
   //          1234   12345678901234567890   1234567890   12345678901234     
   ?
   ?

   lNewpage := .f.
   nLineCtr := 13
 endif   

 for i := 1 to MAX_MISC     
  if aCredit[i][3] <> 0 .or. aCredit[i][4] <> 0 
    if aCredit[i][2] == " "
     ? MARGIN + aCredit[i][1]
     ?? space(3) +padr("Miscellaneous "+alltrim(str(i)),20)
    else
     ? MARGIN + aCredit[i][1]
     ?? space(3) + aCredit[i][2]
    endif 
     ?? space(3) + trans(aCredit[i][3],"9,999,999")
     ?? space(3) + trans(aCredit[i][4],"99,999,999.99")
     ntotalamt := (aCredit[i][3] / (aCredit[i][3] + nQuantity)) * 100
//     ?? space(8) + trans(ntotalamt, "999.99") + " %"
     
     nPageslsqty += aCredit[i][3]
     nPageslstot += aCredit[i][4]
     nRunslsqty  += aCredit[i][3]
     nRunslstot  += aCredit[i][4]
     nRuntotamt  += ntotalamt 
  endif   
 next i  


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
   wWindBuff:=OpenWindow(1,2,maxrow()-1,maxcol()-2,"Consolidated Charge Sales Report")
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
return nil



/*=========================================*/
function do_I_Credit()
/*=========================================*/
local cRef,wWindBuff
local nMaxrow := maxrow()+1, nMaxCol := maxcol()+1
local aFsize := {}
// Gauge variables
local nRecCtr := 0, hGauge, nPercent, nGaugeCtr:=1, wUpdate, dDate
local cName := space(20), dFile, code
local lNewPage := 0, nLineCtr := 0, nLinelen  := 80, nPageCtr := 1
local nPageslstot := 0, nPageslsqty := 0, cWindow
local nReccount := 0, nCtr := 1, ccolor, coldpath
local nRunslstot := 0, nRunslsqty := 0, count := 0, amount := 0
local lFirst := .f., vBrowse, i := 0, nQuantity := 0
local ntotalamt := 0, nRuntotamt := 0,bank_c := space(4)

   SET CURSOR ON
   vBrowse := OpenWindow(15,30,17,50,"")
   @ 16,31 say "Bank Code   : "Get bank_c Pict "9999"
   read
   SET CURSOR OFF
   CloseWindow(vBrowse)

   bank_c := padl(alltrim(bank_c),4,"0") 


if !Getvalid()
  BUMMER() ; return nil 
endif 


if netuse("CC", DB_SHARED, NUM_SECONDS)
    set index to CC_001
endif    


if netuse("CHARGE", DB_SHARED, NUM_SECONDS)
    set index to PAYTYPE
else
   alert("File 'CHARGE.DBF' cannot be accessed",{"Quit"})
   DbCloseAll()
   return nil    
endif	 



cOldPath := SET(_SET_PATH)

Message("Preparing Individual Charge Sales Report ...")


SET ALTERNATE TO ".\"+REPORTFILE1
SET ALTERNATE ON
SET CONSOLE OFF
SET PRINTER OFF

window( 19, 1, 22, 60, CONFIRM_COLOR )

lNewPage := .t.
lFirst := .t.


Do While CHARGE->(!Eof())  

  @ 1, 1 wsay " Creating " + "Individual Charge Sales Report" + "  Please wait ..."
  @ 2, 1 wsay " Bank Code: " + CHARGE->PAY_TYPE + "    "

 if DatesOk(CHARGE->DATE) .and. CHARGE->PAY_TYPE == bank_c
   dDate := CHARGE->DATE 
   

      // Create header if new page  
     if lNewPage  
      // Create header if new page  
      ? MARGIN + "INDIVIDUAL CHARGE SALES REPORT"
      ?
      ? MARGIN +chr(254)+ SYS_NAME
      ? MARGIN +"Individual Charge Sales Report"
      ? MARGIN +"From "+dtoc(dStartDate)+" to "+dtoc(dEndDate)
      ? MARGIN +"As of "+dtoc(date())+", "+time()
      ?
      ?
      ?
      ? MARGIN + "CODE       DESCRIPTION        DATE            ACCOUNT NO        AMOUNT SOLD     "
      ? MARGIN + "----   --------------------   --------   --------------------   --------------  "
      //          1234   12345678901234567890   12345678   12345678901234567890   12345678901234     
      ?
      ?
   
      lNewpage := .f.
      nLineCtr := 13
    endif   

    ? MARGIN + CHARGE->PAY_TYPE
    IF CC->(DbSeek(CHARGE->PAY_TYPE))
      ?? SPACE(3) + CC->CC_002
    ELSE
      ?? SPACE(3) + PADR("CODE NOT FOUND",20)
    ENDIF  
    ?? SPACE(3) + DTOC(CHARGE->DATE)
    ?? SPACE(3) + CHARGE->ACCT_NO
    ?? SPACE(3) + TRANS(CHARGE->SLS_AMOUNT,"99,999,999.99")
    nLineCtr += 1
    nQuantity     += 1
    nPageslstot += CHARGE->SLS_AMOUNT
    nRunslstot  += CHARGE->SLS_AMOUNT
     
    IF nLineCtr > MAX_LINE
      lNewPage := .t.
      nLineCtr := 0
      nPageSlstot := 0

      ?
      ? MARGIN+repl("-",nLineLen)
      ? MARGIN+"Page Total    : " + space(47) + trans(nPageslstot,"999,999,999.99") 
      ? MARGIN+"Running Total : " + space(47) + trans(nRunslstot,"999,999,999.99") 				  
      ? MARGIN + padl("Page # "+alltrim(trans(nPageCtr++,"9,999"))+ " - Last Page",nLineLen)
      ? MARGIN+repl("-",nLineLen)
      ?
      ? chr(12)    
     
    ENDIF
 
    
//   endif
 endif 
 CHARGE->(DbSkip())
enddo        

      
 ?
 ? MARGIN+repl("-",nLineLen)
 ? MARGIN+"Page Total    : " + space(47) + trans(nPageslstot,"999,999,999.99") 
 ? MARGIN+"Running Total : " + space(47) + trans(nRunslstot,"999,999,999.99") 				  
 ? MARGIN + padl("Page # "+alltrim(trans(nPageCtr++,"9,999"))+ " - Last Page",nLineLen)
 ? MARGIN+repl("-",nLineLen)
 ?
 ?  
 ?  MARGIN+"Total Amount Sold    : " + alltrim(trans(nRunslstot,"999,999,999.99"))
 ? 
 ?
 ? MARGIN+padc("********** End of Report **********",nLineLen )  
 ?
 ? chr(12)  

CLOSE ALTERNATE
SET ALTERNATE OFF
SET CONSOLE ON

aFsize := directory(REPORTFILE1)

// check if repot file is < 64K
// direct to printer if greater   

if aFsize[1][2] < MAX_SIZE

  cReport:=memoread(REPORTFILE1)
  if !empty(cReport)
   if !setmode(50,80) .and. !setmode(43,80)
      setmode(nMaxrow,nMaxcol)
   else
      _logo()   
   endif       
   Message("Use cursor keys to navigate, press F10 to print, "+ ;
              "Esc to abort.")
   wWindBuff:=OpenWindow(1,2,maxrow()-1,maxcol()-2,"Individual Charge Sales Report")
   MemoEdit(cReport,2,3,maxrow()-2,maxcol()-3,.f.,'EditorFunc',122 )
   CloseWindow(wWindBuff)
   setcursor(SC_NONE)
   setmode(nMaxrow,nMaxcol)
  endif
 
else

 if alert("Report too large to edit, will be directed to printer", {"Print","Quit"}) == 1 
    Direct2Prn(REPORTFILE1) 
 endif  
 
endif  


cReport := "" //Free memory      
  
DbCloseAll()
return nil



/*=========================================*/
function do_A_Credit()
/*=========================================*/
local cRef,wWindBuff
local nMaxrow := maxrow()+1, nMaxCol := maxcol()+1
local aFsize := {}
// Gauge variables
local nRecCtr := 0, hGauge, nPercent, nGaugeCtr:=1, wUpdate, dDate
local cName := space(20), dFile, code
local lNewPage := 0, nLineCtr := 0, nLinelen  := 80, nPageCtr := 1
local nPageslstot := 0, nPageslsqty := 0, cWindow
local nReccount := 0, nCtr := 1, ccolor, coldpath
local nRunslstot := 0, nRunslsqty := 0, count := 0, amount := 0
local lFirst := .f., i := 0, nQuantity := 0
local ntotalamt := 0, nRuntotamt := 0,bank_c := space(4)


if !Getvalid()
  BUMMER() ; return nil 
endif 


if netuse("CC", DB_SHARED, NUM_SECONDS)
    set index to CC_001
endif    


if netuse("CHARGE", DB_SHARED, NUM_SECONDS)
    set index to PAYTYPE
else
   alert("File 'CHARGE.DBF' cannot be accessed",{"Quit"})
   DbCloseAll()
   return nil    
endif	 



cOldPath := SET(_SET_PATH)

Message("Preparing All Charge Sales Report ...")


SET ALTERNATE TO ".\"+REPORTFILE2
SET ALTERNATE ON
SET CONSOLE OFF
SET PRINTER OFF

window( 19, 1, 22, 60, CONFIRM_COLOR )

lNewPage := .t.
bank_c := space(4)
ddate := ctod("")

Do While CHARGE->(!Eof())  

  @ 1, 1 wsay " Creating " + "All Charge Sales Report" + "  Please wait ..."
  @ 2, 1 wsay " Bank Code: " + CHARGE->PAY_TYPE + "    "

 if DatesOk(CHARGE->DATE) 

   if bank_c != CHARGE->PAY_TYPE .OR. dDate != CHARGE->DATE

     IF nPageSlstot <> 0 .or. nRunSlstot <> 0
      ?
      ? MARGIN+repl("-",nLineLen)
      ? MARGIN+"Page Total    : " + space(47) + trans(nPageslstot,"999,999,999.99") 
      ? MARGIN+"Running Total : " + space(47) + trans(nRunslstot,"999,999,999.99") 				  
      ? MARGIN + padl("Page # "+alltrim(trans(nPageCtr++,"9,999"))+ " - Last Page",nLineLen)
      ? MARGIN+repl("-",nLineLen)
      ?
      ?  
      ?  MARGIN+"Total Amount Sold    : " + alltrim(trans(nRunslstot,"999,999,999.99"))
      ? 
      ? 
      ? MARGIN+padc("********** End of Report **********",nLineLen )  
      ?
      ? chr(12)  
     ENDIF
        
     nLineCtr := 0
     nPageSlstot := 0
     nRunSlstot := 0
     nPageCtr := 1
    
      // Create header if new page  
      ? MARGIN + "ALL CHARGE SALES REPORT"
      ?
      ? MARGIN +chr(254)+ SYS_NAME
      ? MARGIN +"All Charge Sales Report"
      ? MARGIN +"From "+dtoc(dStartDate)+" to "+dtoc(dEndDate)
      ? MARGIN +"As of "+dtoc(date())+", "+time()
      ?
      ?
      ?
      ? MARGIN + "CODE       DESCRIPTION        DATE            ACCOUNT NO        AMOUNT SOLD     "
      ? MARGIN + "----   --------------------   --------   --------------------   --------------  "
      //          1234   12345678901234567890   12345678   12345678901234567890   12345678901234     
      ?
      ?
   
      lNewpage := .f.
      nLineCtr := 13

    ? MARGIN + CHARGE->PAY_TYPE
    IF CC->(DbSeek(CHARGE->PAY_TYPE))
      ?? SPACE(3) + CC->CC_002
    ELSE
      ?? SPACE(3) + PADR("CODE NOT FOUND",20)
    ENDIF  
    ?? SPACE(3) + DTOC(CHARGE->DATE)
    ?? SPACE(3) + CHARGE->ACCT_NO
    ?? SPACE(3) + TRANS(CHARGE->SLS_AMOUNT,"99,999,999.99")
    nLineCtr += 1
    nQuantity     += 1
    nPageslstot += CHARGE->SLS_AMOUNT
    nRunslstot  += CHARGE->SLS_AMOUNT
    bank_c := CHARGE->PAY_TYPE
    dDate := CHARGE->DATE
     
  ELSE
    ? MARGIN + CHARGE->PAY_TYPE
    IF CC->(DbSeek(CHARGE->PAY_TYPE))
      ?? SPACE(3) + CC->CC_002
    ELSE
      ?? SPACE(3) + PADR("CODE NOT FOUND",20)
    ENDIF  
    ?? SPACE(3) + DTOC(CHARGE->DATE)
    ?? SPACE(3) + CHARGE->ACCT_NO
    ?? SPACE(3) + TRANS(CHARGE->SLS_AMOUNT,"99,999,999.99")
    nLineCtr += 1
    nQuantity     += 1
    nPageslstot += CHARGE->SLS_AMOUNT
    nRunslstot  += CHARGE->SLS_AMOUNT
    
   
  ENDIF  
  if lNewPage 
      // Create header if new page  
      ? MARGIN + "ALL CHARGE SALES REPORT"
      ?
      ? MARGIN +chr(254)+ SYS_NAME
      ? MARGIN +"All Charge Sales Report"
      ? MARGIN +"From "+dtoc(dStartDate)+" to "+dtoc(dEndDate)
      ? MARGIN +"As of "+dtoc(date())+", "+time()
      ?
      ?
      ?
      ? MARGIN + "CODE       DESCRIPTION        DATE            ACCOUNT NO        AMOUNT SOLD     "
      ? MARGIN + "----   --------------------   --------   --------------------   --------------  "
      //          1234   12345678901234567890   12345678   12345678901234567890   12345678901234           
      ?
      ?
   
      lNewpage := .f.
      nLineCtr := 13
    endif   
  IF nLineCtr > MAX_LINE
      lNewPage := .t.
      nLineCtr := 0
      nPageSlstot := 0

      ?
      ? MARGIN+repl("-",nLineLen)
      ? MARGIN+"Page Total    : " + space(47) + trans(nPageslstot,"999,999,999.99") 
      ? MARGIN+"Running Total : " + space(47) + trans(nRunslstot,"999,999,999.99") 				  
      ? MARGIN + padl("Page # "+alltrim(trans(nPageCtr++,"9,999"))+ " - Last Page",nLineLen)
      ? MARGIN+repl("-",nLineLen)
      ?
      ? chr(12)    
     
  ENDIF
   
 endif 

    
 CHARGE->(DbSkip())
enddo        

      
 ?
 ? MARGIN+repl("-",nLineLen)
 ? MARGIN+"Page Total    : " + space(47) + trans(nPageslstot,"999,999,999.99") 
 ? MARGIN+"Running Total : " + space(47) + trans(nRunslstot,"999,999,999.99") 				  
 ? MARGIN + padl("Page # "+alltrim(trans(nPageCtr++,"9,999"))+ " - Last Page",nLineLen)
 ? MARGIN+repl("-",nLineLen)
 ?
 ?  
 ?  MARGIN+"Total Amount Sold    : " + alltrim(trans(nRunslstot,"999,999,999.99"))
 ? 
 ?
 ? MARGIN+padc("********** End of Report **********",nLineLen )  
 ?
 ? chr(12)  

CLOSE ALTERNATE
SET ALTERNATE OFF
SET CONSOLE ON

aFsize := directory(REPORTFILE2)

// check if repot file is < 64K
// direct to printer if greater   

if aFsize[1][2] < MAX_SIZE

  cReport:=memoread(REPORTFILE2)
  if !empty(cReport)
   if !setmode(50,80) .and. !setmode(43,80)
      setmode(nMaxrow,nMaxcol)
   else
      _logo()   
   endif       
   Message("Use cursor keys to navigate, press F10 to print, "+ ;
              "Esc to abort.")
   wWindBuff:=OpenWindow(1,2,maxrow()-1,maxcol()-2,"All Charge Sales Report")
   MemoEdit(cReport,2,3,maxrow()-2,maxcol()-3,.f.,'EditorFunc',122 )
   CloseWindow(wWindBuff)
   setcursor(SC_NONE)
   setmode(nMaxrow,nMaxcol)
  endif
 
else

 if alert("Report too large to edit, will be directed to printer", {"Print","Quit"}) == 1 
    Direct2Prn(REPORTFILE2) 
 endif  
 
endif  


cReport := "" //Free memory      
  
DbCloseAll()
return nil




