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
#define REPORTFILE  "HOURLY.PRN"
#define MAX_SIZE    65535
#define MAX_LINE    50    
#define EJECT_FROM_FILE
#define DEBUG
#define MAX_MISC    81    
 
memvar n,dStartDate,dEndDate,nLimit, GetList, creport



/*=========================================*/
function RCHour()
/*=========================================*/
local cRef,wWindBuff
local nMaxrow := maxrow()+1, nMaxCol := maxcol()+1
local aFsize := {}
// Gauge variables
local nRecCtr := 0, hGauge, nPercent, nGaugeCtr:=1, wUpdate, dDate
local cName := space(20), dFile, code, cOldpath
local lNewPage := 0, nLineCtr := 0, nLinelen  := 75, nPageCtr := 1
local totamt := 0, totcnt := 0
local hour1_c := 0, hour1_a := 0, hour13_c := 0, hour13_a := 0
local hour2_c := 0, hour2_a := 0, hour14_c := 0, hour14_a := 0
local hour3_c := 0, hour3_a := 0, hour15_c := 0, hour15_a := 0
local hour4_c := 0, hour4_a := 0, hour16_c := 0, hour16_a := 0
local hour5_c := 0, hour5_a := 0, hour17_c := 0, hour17_a := 0
local hour6_c := 0, hour6_a := 0, hour18_c := 0, hour18_a := 0
local hour7_c := 0, hour7_a := 0, hour19_c := 0, hour19_a := 0
local hour8_c := 0, hour8_a := 0, hour20_c := 0, hour20_a := 0
local hour9_c := 0, hour9_a := 0, hour21_c := 0, hour21_a := 0
local hour10_c := 0, hour10_a := 0, hour22_c := 0, hour22_a := 0
local hour11_c := 0, hour11_a := 0, hour23_c := 0, hour23_a := 0
local hour12_c := 0, hour12_a := 0, hour24_c := 0, hour24_a := 0


if !Getvalid()
  BUMMER() ; return nil 
endif 


if netuse("HOUR", DB_SHARED, NUM_SECONDS)
    set index to HOUR
else
   alert("File 'HOUR' cannot be accessed",{"Quit"})
   DbCloseAll()
   return nil    
endif	 



cOldPath := SET(_SET_PATH)

Message("Preparing Consolidated Hourly Sales Report ...")


SET ALTERNATE TO ".\"+REPORTFILE
SET ALTERNATE ON
SET CONSOLE OFF
SET PRINTER OFF

window( 19, 1, 22, 70, CONFIRM_COLOR )

lNewPage := .t.

Do While HOUR->(!Eof())  

  @ 1, 1 wsay " Creating " + "Consolidated Hourly Sales Report" + "  Please wait ..."
  @ 2, 1 wsay " Terminal No: " + HOUR->TERM + "  "  + "Hour : " + alltrim(str(HOUR->HOUR)) +":00"

 if DatesOk(HOUR->DATE) 

    Do Case
       Case HOUR->HOUR == 1
         hour1_c += HOUR->HCOUNT
         hour1_a += HOUR->HAMOUNT
       Case HOUR->HOUR == 2
         hour2_c += HOUR->HCOUNT
         hour2_a += HOUR->HAMOUNT
       Case HOUR->HOUR == 3
         hour3_c += HOUR->HCOUNT
         hour3_a += HOUR->HAMOUNT
       Case HOUR->HOUR == 4
         hour4_c += HOUR->HCOUNT
         hour4_a += HOUR->HAMOUNT
       Case HOUR->HOUR == 5
         hour5_c += HOUR->HCOUNT
         hour5_a += HOUR->HAMOUNT
       Case HOUR->HOUR == 6
         hour6_c += HOUR->HCOUNT
         hour6_a += HOUR->HAMOUNT
       Case HOUR->HOUR == 7
         hour7_c += HOUR->HCOUNT
         hour7_a += HOUR->HAMOUNT
       Case HOUR->HOUR == 8
         hour8_c += HOUR->HCOUNT
         hour8_a += HOUR->HAMOUNT
       Case HOUR->HOUR == 9
         hour9_c += HOUR->HCOUNT
         hour9_a += HOUR->HAMOUNT
       Case HOUR->HOUR == 10
         hour10_c += HOUR->HCOUNT
         hour10_a += HOUR->HAMOUNT
       Case HOUR->HOUR == 11
         hour11_c += HOUR->HCOUNT
         hour11_a += HOUR->HAMOUNT
       Case HOUR->HOUR == 12
         hour12_c += HOUR->HCOUNT
         hour12_a += HOUR->HAMOUNT
       Case HOUR->HOUR == 13
         hour13_c += HOUR->HCOUNT
         hour13_a += HOUR->HAMOUNT
       Case HOUR->HOUR == 14
         hour14_c += HOUR->HCOUNT
         hour14_a += HOUR->HAMOUNT
       Case HOUR->HOUR == 15
         hour15_c += HOUR->HCOUNT
         hour15_a += HOUR->HAMOUNT
       Case HOUR->HOUR == 16
         hour16_c += HOUR->HCOUNT
         hour16_a += HOUR->HAMOUNT
       Case HOUR->HOUR == 17
         hour17_c += HOUR->HCOUNT
         hour17_a += HOUR->HAMOUNT
       Case HOUR->HOUR == 18
         hour18_c += HOUR->HCOUNT
         hour18_a += HOUR->HAMOUNT
       Case HOUR->HOUR == 19
         hour19_c += HOUR->HCOUNT
         hour19_a += HOUR->HAMOUNT
       Case HOUR->HOUR == 20
         hour20_c += HOUR->HCOUNT
         hour20_a += HOUR->HAMOUNT
       Case HOUR->HOUR == 21
         hour21_c += HOUR->HCOUNT
         hour21_a += HOUR->HAMOUNT
       Case HOUR->HOUR == 22
         hour22_c += HOUR->HCOUNT
         hour22_a += HOUR->HAMOUNT
       Case HOUR->HOUR == 23
         hour23_c += HOUR->HCOUNT
         hour23_a += HOUR->HAMOUNT
       Case HOUR->HOUR == 24
         hour24_c += HOUR->HCOUNT
         hour24_a += HOUR->HAMOUNT
                                                   
    EndCase
        totcnt += HOUR->HCOUNT         
        totamt += HOUR->HAMOUNT         
       
 endif 
 HOUR->(DbSkip())
enddo        



    // Create header if new page  
     ? MARGIN + "CONSOLIDATED HOURLY SALES REPORT"
     ?
     ? MARGIN +chr(254)+ SYS_NAME
     ? MARGIN +"Consolidated Hourly Sales Report"
     ? MARGIN +"From "+dtoc(dStartDate)+" to "+dtoc(dEndDate)
     ? MARGIN +"As of "+dtoc(date())+", "+time()
     ?
     ?
     ?
     ? MARGIN + "   TIME FRAME             COUNT           AMOUNT      "
     ? MARGIN + "--------------------    ----------    -------------- " 
     //          12345678901234567890    1234567890    12345678901234  
     ?
     ?

     ?  MARGIN + PADR(" 1:00 -  2:00  A.M.",20) 
     ?? SPACE(4) + trans(hour1_c," 9,999,999")
     ?? SPACE(4) + trans(hour1_a," 9,999,999.99")
     ?  MARGIN + PADR(" 2:00 -  3:00  A.M.",20) 
     ?? SPACE(4) + trans(hour2_c," 9,999,999")
     ?? SPACE(4) + trans(hour2_a," 9,999,999.99")
     ?  MARGIN + PADR(" 3:00 -  4:00  A.M.",20) 
     ?? SPACE(4) + trans(hour3_c," 9,999,999")
     ?? SPACE(4) + trans(hour3_a," 9,999,999.99")
     ?  MARGIN + PADR(" 4:00 -  5:00  A.M.",20) 
     ?? SPACE(4) + trans(hour4_c," 9,999,999")
     ?? SPACE(4) + trans(hour4_a," 9,999,999.99")
     ?  MARGIN + PADR(" 5:00 -  6:00  A.M.",20) 
     ?? SPACE(4) + trans(hour5_c," 9,999,999")
     ?? SPACE(4) + trans(hour5_a," 9,999,999.99")
     ?  MARGIN + PADR(" 6:00 -  7:00  A.M.",20) 
     ?? SPACE(4) + trans(hour6_c," 9,999,999")
     ?? SPACE(4) + trans(hour6_a," 9,999,999.99")
     ?  MARGIN + PADR(" 7:00 -  8:00  A.M.",20) 
     ?? SPACE(4) + trans(hour7_c," 9,999,999")
     ?? SPACE(4) + trans(hour7_a," 9,999,999.99")
     ?  MARGIN + PADR(" 8:00 -  9:00  A.M.",20) 
     ?? SPACE(4) + trans(hour8_c," 9,999,999")
     ?? SPACE(4) + trans(hour8_a," 9,999,999.99")
     ?  MARGIN + PADR(" 9:00 - 10:00  A.M.",20) 
     ?? SPACE(4) + trans(hour9_c," 9,999,999")
     ?? SPACE(4) + trans(hour9_a," 9,999,999.99")
     ?  MARGIN + PADR("10:00 - 11:00  A.M.",20) 
     ?? SPACE(4) + trans(hour10_c," 9,999,999")
     ?? SPACE(4) + trans(hour10_a," 9,999,999.99")
     ?  MARGIN + PADR("11:00 - 12:00  P.M.",20) 
     ?? SPACE(4) + trans(hour11_c," 9,999,999")
     ?? SPACE(4) + trans(hour11_a," 9,999,999.99")
     ?  MARGIN + PADR("12:00 -  1:00  P.M.",20) 
     ?? SPACE(4) + trans(hour12_c," 9,999,999")
     ?? SPACE(4) + trans(hour12_a," 9,999,999.99")
     ?  MARGIN + PADR(" 1:00 -  2:00  P.M.",20) 
     ?? SPACE(4) + trans(hour13_c," 9,999,999")
     ?? SPACE(4) + trans(hour13_a," 9,999,999.99")
     ?  MARGIN + PADR(" 2:00 -  3:00  P.M.",20) 
     ?? SPACE(4) + trans(hour14_c," 9,999,999")
     ?? SPACE(4) + trans(hour14_a," 9,999,999.99")
     ?  MARGIN + PADR(" 3:00 -  4:00  P.M.",20) 
     ?? SPACE(4) + trans(hour15_c," 9,999,999")
     ?? SPACE(4) + trans(hour15_a," 9,999,999.99")
     ?  MARGIN + PADR(" 4:00 -  5:00  P.M.",20) 
     ?? SPACE(4) + trans(hour16_c," 9,999,999")
     ?? SPACE(4) + trans(hour16_a," 9,999,999.99")
     ?  MARGIN + PADR(" 5:00 -  6:00  P.M.",20) 
     ?? SPACE(4) + trans(hour17_c," 9,999,999")
     ?? SPACE(4) + trans(hour17_a," 9,999,999.99")
     ?  MARGIN + PADR(" 6:00 -  7:00  P.M.",20) 
     ?? SPACE(4) + trans(hour18_c," 9,999,999")
     ?? SPACE(4) + trans(hour18_a," 9,999,999.99")
     ?  MARGIN + PADR(" 7:00 -  8:00  P.M.",20) 
     ?? SPACE(4) + trans(hour19_c," 9,999,999")
     ?? SPACE(4) + trans(hour19_a," 9,999,999.99")
     ?  MARGIN + PADR(" 8:00 -  9:00  P.M.",20) 
     ?? SPACE(4) + trans(hour20_c," 9,999,999")
     ?? SPACE(4) + trans(hour20_a," 9,999,999.99")
     ?  MARGIN + PADR(" 9:00 - 10:00  P.M.",20) 
     ?? SPACE(4) + trans(hour21_c," 9,999,999")
     ?? SPACE(4) + trans(hour21_a," 9,999,999.99")
     ?  MARGIN + PADR("10:00 - 11:00  P.M.",20) 
     ?? SPACE(4) + trans(hour22_c," 9,999,999")
     ?? SPACE(4) + trans(hour22_a," 9,999,999.99")
     ?  MARGIN + PADR("11:00 - 12:00  M.N.",20) 
     ?? SPACE(4) + trans(hour23_c," 9,999,999")
     ?? SPACE(4) + trans(hour23_a," 9,999,999.99")
     ?  MARGIN + PADR("12:00 -  1:00  A.M.",20) 
     ?? SPACE(4) + trans(hour24_c," 9,999,999")
     ?? SPACE(4) + trans(hour24_a," 9,999,999.99")
    
    ?
    ?
    ?
    ? MARGIN + "Total Quantity Sold :  " + trans(totcnt,"99,999,999.99" )
    ? MARGIN + "Total Amount Sold   :  " + trans(totamt,"99,999,999.99" )
      
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
   wWindBuff:=OpenWindow(1,2,maxrow()-1,maxcol()-2,"Consolidated Hourly Sales Report")
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
function RIHour()
/*=========================================*/
local cRef,wWindBuff
local nMaxrow := maxrow()+1, nMaxCol := maxcol()+1
local aFsize := {}
// Gauge variables
local nRecCtr := 0, hGauge, nPercent, nGaugeCtr:=1, wUpdate, dDate
local cName := space(20), dFile, code, cOldPath
local lNewPage := 0, nLineCtr := 0, nLinelen  := 75, nPageCtr := 1
local totamt := 0, totcnt := 0
local hour1_c := 0, hour1_a := 0, hour13_c := 0, hour13_a := 0
local hour2_c := 0, hour2_a := 0, hour14_c := 0, hour14_a := 0
local hour3_c := 0, hour3_a := 0, hour15_c := 0, hour15_a := 0
local hour4_c := 0, hour4_a := 0, hour16_c := 0, hour16_a := 0
local hour5_c := 0, hour5_a := 0, hour17_c := 0, hour17_a := 0
local hour6_c := 0, hour6_a := 0, hour18_c := 0, hour18_a := 0
local hour7_c := 0, hour7_a := 0, hour19_c := 0, hour19_a := 0
local hour8_c := 0, hour8_a := 0, hour20_c := 0, hour20_a := 0
local hour9_c := 0, hour9_a := 0, hour21_c := 0, hour21_a := 0
local hour10_c := 0, hour10_a := 0, hour22_c := 0, hour22_a := 0
local hour11_c := 0, hour11_a := 0, hour23_c := 0, hour23_a := 0
local hour12_c := 0, hour12_a := 0, hour24_c := 0, hour24_a := 0
local vBrowse, cterm := space(4)


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


if netuse("HOUR", DB_SHARED, NUM_SECONDS)
    set index to HOUR
else
   alert("File 'HOUR' cannot be accessed",{"Quit"})
   DbCloseAll()
   return nil    
endif	 



cOldPath := SET(_SET_PATH)

Message("Preparing Individual Hourly Sales Report ...")


SET ALTERNATE TO ".\"+REPORTFILE
SET ALTERNATE ON
SET CONSOLE OFF
SET PRINTER OFF

window( 19, 1, 22, 70, CONFIRM_COLOR )

lNewPage := .t.

Do While HOUR->(!Eof())  

  @ 1, 1 wsay " Creating " + "Individual Hourly Sales Report" + "  Please wait ..."
  @ 2, 1 wsay " Terminal No: " + HOUR->TERM + "  "  + "Hour : " + alltrim(str(HOUR->HOUR)) +":00"

 if DatesOk(HOUR->DATE) 
  IF  HOUR->TERM == cterm

    Do Case
       Case HOUR->HOUR == 1
         hour1_c += HOUR->HCOUNT
         hour1_a += HOUR->HAMOUNT
       Case HOUR->HOUR == 2
         hour2_c += HOUR->HCOUNT
         hour2_a += HOUR->HAMOUNT
       Case HOUR->HOUR == 3
         hour3_c += HOUR->HCOUNT
         hour3_a += HOUR->HAMOUNT
       Case HOUR->HOUR == 4
         hour4_c += HOUR->HCOUNT
         hour4_a += HOUR->HAMOUNT
       Case HOUR->HOUR == 5
         hour5_c += HOUR->HCOUNT
         hour5_a += HOUR->HAMOUNT
       Case HOUR->HOUR == 6
         hour6_c += HOUR->HCOUNT
         hour6_a += HOUR->HAMOUNT
       Case HOUR->HOUR == 7
         hour7_c += HOUR->HCOUNT
         hour7_a += HOUR->HAMOUNT
       Case HOUR->HOUR == 8
         hour8_c += HOUR->HCOUNT
         hour8_a += HOUR->HAMOUNT
       Case HOUR->HOUR == 9
         hour9_c += HOUR->HCOUNT
         hour9_a += HOUR->HAMOUNT
       Case HOUR->HOUR == 10
         hour10_c += HOUR->HCOUNT
         hour10_a += HOUR->HAMOUNT
       Case HOUR->HOUR == 11
         hour11_c += HOUR->HCOUNT
         hour11_a += HOUR->HAMOUNT
       Case HOUR->HOUR == 12
         hour12_c += HOUR->HCOUNT
         hour12_a += HOUR->HAMOUNT
       Case HOUR->HOUR == 13
         hour13_c += HOUR->HCOUNT
         hour13_a += HOUR->HAMOUNT
       Case HOUR->HOUR == 14
         hour14_c += HOUR->HCOUNT
         hour14_a += HOUR->HAMOUNT
       Case HOUR->HOUR == 15
         hour15_c += HOUR->HCOUNT
         hour15_a += HOUR->HAMOUNT
       Case HOUR->HOUR == 16
         hour16_c += HOUR->HCOUNT
         hour16_a += HOUR->HAMOUNT
       Case HOUR->HOUR == 17
         hour17_c += HOUR->HCOUNT
         hour17_a += HOUR->HAMOUNT
       Case HOUR->HOUR == 18
         hour18_c += HOUR->HCOUNT
         hour18_a += HOUR->HAMOUNT
       Case HOUR->HOUR == 19
         hour19_c += HOUR->HCOUNT
         hour19_a += HOUR->HAMOUNT
       Case HOUR->HOUR == 20
         hour20_c += HOUR->HCOUNT
         hour20_a += HOUR->HAMOUNT
       Case HOUR->HOUR == 21
         hour21_c += HOUR->HCOUNT
         hour21_a += HOUR->HAMOUNT
       Case HOUR->HOUR == 22
         hour22_c += HOUR->HCOUNT
         hour22_a += HOUR->HAMOUNT
       Case HOUR->HOUR == 23
         hour23_c += HOUR->HCOUNT
         hour23_a += HOUR->HAMOUNT
       Case HOUR->HOUR == 24
         hour24_c += HOUR->HCOUNT
         hour24_a += HOUR->HAMOUNT
                                                   
    EndCase
        totcnt += HOUR->HCOUNT         
        totamt += HOUR->HAMOUNT         
  endif       
 endif 
 HOUR->(DbSkip())
enddo        



    // Create header if new page  
     ? MARGIN + "INDIVIDUAL HOURLY SALES REPORT"
     ?
     ? MARGIN +chr(254)+ SYS_NAME
     ? MARGIN +"Individual Hourly Sales Report"
     ? MARGIN +"From "+dtoc(dStartDate)+" to "+dtoc(dEndDate)
     ? MARGIN +"As of "+dtoc(date())+", "+time()
     ?
     ? MARGIN +"Terminal No. " + cterm
     ?
     ? MARGIN + "   TIME FRAME             COUNT           AMOUNT      "
     ? MARGIN + "--------------------    ----------    -------------- " 
     //          12345678901234567890    1234567890    12345678901234  
     ?
     ?

     ?  MARGIN + PADR(" 1:00 -  2:00  A.M.",20) 
     ?? SPACE(4) + trans(hour1_c," 9,999,999")
     ?? SPACE(4) + trans(hour1_a," 9,999,999.99")
     ?  MARGIN + PADR(" 2:00 -  3:00  A.M.",20) 
     ?? SPACE(4) + trans(hour2_c," 9,999,999")
     ?? SPACE(4) + trans(hour2_a," 9,999,999.99")
     ?  MARGIN + PADR(" 3:00 -  4:00  A.M.",20) 
     ?? SPACE(4) + trans(hour3_c," 9,999,999")
     ?? SPACE(4) + trans(hour3_a," 9,999,999.99")
     ?  MARGIN + PADR(" 4:00 -  5:00  A.M.",20) 
     ?? SPACE(4) + trans(hour4_c," 9,999,999")
     ?? SPACE(4) + trans(hour4_a," 9,999,999.99")
     ?  MARGIN + PADR(" 5:00 -  6:00  A.M.",20) 
     ?? SPACE(4) + trans(hour5_c," 9,999,999")
     ?? SPACE(4) + trans(hour5_a," 9,999,999.99")
     ?  MARGIN + PADR(" 6:00 -  7:00  A.M.",20) 
     ?? SPACE(4) + trans(hour6_c," 9,999,999")
     ?? SPACE(4) + trans(hour6_a," 9,999,999.99")
     ?  MARGIN + PADR(" 7:00 -  8:00  A.M.",20) 
     ?? SPACE(4) + trans(hour7_c," 9,999,999")
     ?? SPACE(4) + trans(hour7_a," 9,999,999.99")
     ?  MARGIN + PADR(" 8:00 -  9:00  A.M.",20) 
     ?? SPACE(4) + trans(hour8_c," 9,999,999")
     ?? SPACE(4) + trans(hour8_a," 9,999,999.99")
     ?  MARGIN + PADR(" 9:00 - 10:00  A.M.",20) 
     ?? SPACE(4) + trans(hour9_c," 9,999,999")
     ?? SPACE(4) + trans(hour9_a," 9,999,999.99")
     ?  MARGIN + PADR("10:00 - 11:00  A.M.",20) 
     ?? SPACE(4) + trans(hour10_c," 9,999,999")
     ?? SPACE(4) + trans(hour10_a," 9,999,999.99")
     ?  MARGIN + PADR("11:00 - 12:00  P.M.",20) 
     ?? SPACE(4) + trans(hour11_c," 9,999,999")
     ?? SPACE(4) + trans(hour11_a," 9,999,999.99")
     ?  MARGIN + PADR("12:00 -  1:00  P.M.",20) 
     ?? SPACE(4) + trans(hour12_c," 9,999,999")
     ?? SPACE(4) + trans(hour12_a," 9,999,999.99")
     ?  MARGIN + PADR(" 1:00 -  2:00  P.M.",20) 
     ?? SPACE(4) + trans(hour13_c," 9,999,999")
     ?? SPACE(4) + trans(hour13_a," 9,999,999.99")
     ?  MARGIN + PADR(" 2:00 -  3:00  P.M.",20) 
     ?? SPACE(4) + trans(hour14_c," 9,999,999")
     ?? SPACE(4) + trans(hour14_a," 9,999,999.99")
     ?  MARGIN + PADR(" 3:00 -  4:00  P.M.",20) 
     ?? SPACE(4) + trans(hour15_c," 9,999,999")
     ?? SPACE(4) + trans(hour15_a," 9,999,999.99")
     ?  MARGIN + PADR(" 4:00 -  5:00  P.M.",20) 
     ?? SPACE(4) + trans(hour16_c," 9,999,999")
     ?? SPACE(4) + trans(hour16_a," 9,999,999.99")
     ?  MARGIN + PADR(" 5:00 -  6:00  P.M.",20) 
     ?? SPACE(4) + trans(hour17_c," 9,999,999")
     ?? SPACE(4) + trans(hour17_a," 9,999,999.99")
     ?  MARGIN + PADR(" 6:00 -  7:00  P.M.",20) 
     ?? SPACE(4) + trans(hour18_c," 9,999,999")
     ?? SPACE(4) + trans(hour18_a," 9,999,999.99")
     ?  MARGIN + PADR(" 7:00 -  8:00  P.M.",20) 
     ?? SPACE(4) + trans(hour19_c," 9,999,999")
     ?? SPACE(4) + trans(hour19_a," 9,999,999.99")
     ?  MARGIN + PADR(" 8:00 -  9:00  P.M.",20) 
     ?? SPACE(4) + trans(hour20_c," 9,999,999")
     ?? SPACE(4) + trans(hour20_a," 9,999,999.99")
     ?  MARGIN + PADR(" 9:00 - 10:00  P.M.",20) 
     ?? SPACE(4) + trans(hour21_c," 9,999,999")
     ?? SPACE(4) + trans(hour21_a," 9,999,999.99")
     ?  MARGIN + PADR("10:00 - 11:00  P.M.",20) 
     ?? SPACE(4) + trans(hour22_c," 9,999,999")
     ?? SPACE(4) + trans(hour22_a," 9,999,999.99")
     ?  MARGIN + PADR("11:00 - 12:00  M.N.",20) 
     ?? SPACE(4) + trans(hour23_c," 9,999,999")
     ?? SPACE(4) + trans(hour23_a," 9,999,999.99")
     ?  MARGIN + PADR("12:00 -  1:00  A.M.",20) 
     ?? SPACE(4) + trans(hour24_c," 9,999,999")
     ?? SPACE(4) + trans(hour24_a," 9,999,999.99")  
    
    ?
    ?
    ?
    ? MARGIN + "Total Quantity Sold :  " + trans(totcnt,"99,999,999.99" )
    ? MARGIN + "Total Amount Sold   :  " + trans(totamt,"99,999,999.99" )
      
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
   wWindBuff:=OpenWindow(1,2,maxrow()-1,maxcol()-2,"Individual Hourly Sales Report")
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






