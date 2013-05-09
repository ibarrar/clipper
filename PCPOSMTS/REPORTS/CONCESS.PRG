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
#define REPORTFILE  "CONCESS.PRN"
#define MAX_SIZE    65535
#define MAX_LINE    50    

memvar n,dStartDate,dEndDate, cReport
memvar GetList

function r_concess()
local cRef,wWindBuff
local nMaxrow := maxrow()+1, nMaxCol := maxcol()+1
local aFsize := {}
// Gauge variables
local nRecCtr := 0, hGauge, nPercent, nGaugeCtr:=1, wUpdate, dDate
local cName, dFile, code
local lNewPage := 0, nLineCtr := 0, nLinelen  := 66, nPageCtr := 1
local nPageslstot := 0, nPageslsqty := 0, cWindow
local nReccount := 0, nCtr := 1, ccolor, coldpath
local nRunslstot := 0, nRunslsqty := 0
local cPname := space(20), sup := space(3)
local vRecord:= space(3), vBrowse

local cVCode:=space(3), aVendor:={}, nVindx:=0, cVenCode:=space(3)
local cVenName1:=space(20),cVenName2:=space(20),cVenName3:=space(20)
local cVenName4:=space(20),cVenName5:=space(20), nItmQtyAcc:=0, nItmSlsAcc:=0

/*
   SET CURSOR ON
   vBrowse := OpenWindow(15,30,17,50)
   @ 16,31 say "Supplier Code: "Get vRecord Pict "999"
   read
   SET CURSOR OFF
   CloseWindow(vBrowse)

   vRecord := padl(alltrim(vRecord),3,"0") 
*/

if !Getvalid()
  BUMMER() ; return nil 
endif 


if netuse("V", DB_SHARED, NUM_SECONDS)
    set index to V_001
else
   alert("File 'V.DBF' cannot be accessed",{"Quit"})
   return nil    
endif	 

if netuse("PLU", DB_SHARED, NUM_SECONDS)
    set index to PLU
else
   alert("File 'PLU.DBF' cannot be accessed",{"Quit"})
   DbCloseAll()
   return nil    
endif	 

if netuse("ITEM.DBF", DB_SHARED, NUM_SECONDS)
  set index to I_001
else
   alert("File 'ITEM.DBF' cannot be accessed",{"Quit"})
   DbCloseAll()
   return nil
endif

cOldPath := SET(_SET_PATH)

Message("Preparing Concessionaire Report ...")


SET ALTERNATE TO ".\"+REPORTFILE
SET ALTERNATE ON
SET CONSOLE OFF
SET PRINTER OFF

  
window( 19, 1, 22, 70, CONFIRM_COLOR )

 lNewPage := .t.

do while V->(!eof())
   aadd(aVendor,{V->V_001, V->V_002, V->V_014, V->V_015, V->V_016, V->V_017})
   V->(dbskip())
enddo

for nVindx := 1 to len(aVendor)
  cVenCode  := aVendor[nVindx][1]
  cVenName1 := aVendor[nVindx][2]
  cVenName2 := aVendor[nVindx][3]
  cVenName3 := aVendor[nVindx][4]  
  cVenName4 := aVendor[nVindx][5]
  cVenName5 := aVendor[nVindx][6]
  
PLU->(DBGOTOP())
Do While PLU->(!Eof())  

  @ 1, 1 wsay " Creating " + "All Concessionaire Report" + "  Please wait ..."
  @ 2, 1 wsay " Concessionaire Code: " + PLU->CODE + "    "


 if DatesOk(PLU->DATE)

  // Create header if new page  
  if lNewPage  

/*jzo05-07-98
   IF V->(DbSeek(vRecord))
      cName := subs(V->V_002,1,20)
      cVCode := V->V_001          //jzo04-23-98
   else
      cName := "** Code Not Found **"   
   endif   
*/
   
   // Create header if new page  
   ? MARGIN + "ALL CONCESSIONAIRE SALES REPORT"
   ?
   ? MARGIN +chr(254)+ SYS_NAME
   ? MARGIN +"All Concessionaire Report"
   ? MARGIN +"From "+dtoc(dStartDate)+" to "+dtoc(dEndDate)
   ? MARGIN +"As of "+dtoc(date())+", "+time()
   ? 
//jzo05-07-98   ? MARGIN +"SUPPLIER NAME : " + cName
   ? 
	? MARGIN + "SUPPLIER CODE        SUPPLIER NAME      QUANTITY     AMOUNT SOLD"
   ? MARGIN + "--------------   --------------------   ----------   --------------"
   //          12345678901234   12345678901234567890   1234567890   12345678901234
   ?
   ?

   lNewpage := .f.
   nLineCtr := 13
 endif
 
/*
    IF ITEM->(DBSeek(PLU->CODE)) 
      cPname := ITEM->I_002
      sup := ITEM->I_020
    ELSE
      cPname := "** Code Not Found **"   
    ENDIF   
*/



  if empty(sup)
     sup:=cVenCode
        ? MARGIN + padr(cVenCode,14,"")
        ?? space(3) + subs(cVenName1,1,20)  
  endif   
  
  if sup == subs(PLU->CODE,1,3)
  
//   ? MARGIN + padr(cVenCode,14,"")
//   ?? space(3) + subs(cName,1,20)
//   ?? space(3) + tran(PLU->ICOUNT,"999,999.99")
//   ?? space(2) + tran(PLU->IAMOUNT,"999,999,999.99")
//   nLineCtr += 1

    nItmQtyAcc += PLU->ICOUNT
    nItmSlsAcc += PLU->IAMOUNT
 
    nPageslsqty += PLU->ICOUNT
    nPageslstot += PLU->IAMOUNT
    nRunslsqty += PLU->ICOUNT
    nRunslstot += PLU->IAMOUNT
  endif    
   
  
  // check if footer is needed, eject
  // reset counters
  if nLineCtr >= MAX_LINE 
    ?
	 ? MARGIN+repl("-",nLineLen)
    ? MARGIN+"Page Total    : " + space(22) + trans(nPageslsqty,"9,999,999.99") +;
            space(2) +  trans(nPageslstot,"999,999,999.99")
    ?  MARGIN+"Running Total : " + space(22) + trans(nRunslsqty,"9,999,999.99") +;
            space(2) + trans(nRunslstot,"999,999,999.99") 				  
    ? MARGIN + padl("Page # "+alltrim(trans(nPageCtr++,"9,999")),nLineLen)		  
    ? MARGIN+repl("-",nLineLen)
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

   ?? space(3) + tran(nItmQtyAcc,"999,999.99")
   ?? space(2) + tran(nItmSlsAcc,"999,999,999.99")
   ? MARGIN + SPACE(14+3) + subs(cVenName2,1,20)
   ? MARGIN + SPACE(14+3) + subs(cVenName3,1,20)
   ? MARGIN + SPACE(14+3) + subs(cVenName4,1,20)
   ? MARGIN + SPACE(14+3) + subs(cVenName5,1,20)
   
   nLineCtr += 5   
   nItmQtyAcc:=0
   nItmSlsAcc:=0
   sup:=space(3)

next nVindx


  if lNewPage  

/*jzo05-07-98
//added by jzo04-03-98
   IF V->(DbSeek(vRecord))
      cName := subs(V->V_002,1,20)
      cVCode := V->V_001         //jzo04-23-98
            
   else
      cName := "** Code Not Found **"   
   endif   
//
*/     

   ? MARGIN + "ALL CONCESSIONAIRE SALES REPORT"
   ?
   ? MARGIN +chr(254)+ SYS_NAME
   ? MARGIN +"All Concessionaire Sales Report"
   ? MARGIN +"From "+dtoc(dStartDate)+" to "+dtoc(dEndDate)
   ? MARGIN +"As of "+dtoc(date())+", "+time()
   ? 
//jzo05-07-98   ? MARGIN +"SUPPLIER NAME : " + cName
   ?
	? MARGIN + "SUPPLIER CODE        SUPPLIER NAME      QUANTITY     AMOUNT SOLD"
   ? MARGIN + "--------------   --------------------   ----------   --------------"
   //          12345678901234   12345678901234567890   1234567890   12345678901234
   ?
   ?
 endif


 ?
 ? MARGIN+repl("-",nLineLen)
 ?  MARGIN+"Page Total    : " + space(22) + trans(nPageslsqty,"9,999,999.99") +;
              space(2) + trans(nPageslstot,"999,999,999.99") 
 ?  MARGIN+"Running Total : " + space(22) + trans(nRunslsqty,"9,999,999.99") +;
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
   wWindBuff:=OpenWindow(1,2,maxrow()-1,maxcol()-2,"All Concessionaire Sales Report")
   MemoEdit(cReport,2,3,maxrow()-2,maxcol()-3,.f.,'Editor2Func',122-45 )
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


/*jzo
function r_concess()
local wWindow
local cConCode := space(14)
local nMaxrow := maxrow()+1, nMaxCol := maxcol()+1
local aFsize := {}
local lNewPage, nLineCtr := 0,nLineLen := 69, nPageCtr := 1
local nPagestot:= 0, nPagesqty  := 0
local nRunstot:= 0, nRunsqty := 0
local nRunUCost := 0, nPageUCost := 0

  while .T.
  
     nPagestot:= 0
     nPagesqty  := 0
     nRunstot:= 0
     nRunsqty := 0
     nRunUCost := 0
     nPageUCost := 0
  
     dStartDate :=  dEndDate := date()
     Message("Enter dates of last updates to cover reports")
     wWindow := OpenWindow(09,12,16,66,"Concessionaire Report Entry")
     @ 10,12 to 16,66 double    
     @ 12,17 say "   Enter Concessionaires code :" get cConCode pict "@K XXXXXXXXXXXXXX"
     @ 13,17 say "Enter starting date (MM-DD-YY format)" get dStartDate pict "@D"
     @ 14,17 say "        Ending date (MM-DD-YY format)" get dEndDate pict "@D"
     SetCursor(SC_NORMAL)
     HeyThere()
     read
     SetCursor(SC_NONE)
     CloseWindow(wWindow)

     if lastkey() == K_ESC
        BUMMER()
        return nil
     endif

     cConCode := padl(alltrim(cConCode),14,"0")   
     
//     if netuse("PLU", DB_SHARED, NUM_SECONDS)
//       set index to DATEPLU
//     else
//       alert("File 'PLU,DBF' connot be accessed",{"QUIT"})
//       return nil
//     endif   

     if netuse("PLUTEMP", DB_EXCLUSIVE, NUM_SECONDS)
        PLUTEMP->(__dbzap())
     endif        

     Plu_Con() // Consolidate...
     
     SET ALTERNATE TO ".\"+REPORTFILE
     SET ALTERNATE ON
     SET CONSOLE OFF
     SET PRINTER OFF
  
     window( 19, 1, 22, 60, CONFIRM_COLOR )
     lNewPage := .t.

     PLUTEMP->(DbGoTop())

     While PLUTEMP->(!Eof())  

       if cConCode == PLUTEMP->CODE  // .and. DatesOK(PLU->DATE)
          @ 1, 1 wsay " Creating Concessionaires Report  Please wait ..."
          @ 2, 1 wsay " Concess. Code: " + cConCode + " - " + PLUTEMP->DESC

          if lNewPage
           ? MARGIN + "CONCESSIONAIRE's REPORT"
           ?
           ? MARGIN + chr(254) +SYS_NAME
           ? MARGIN +"From "+dtoc(dStartDate)+" to "+dtoc(dEndDate)
           ? MARGIN +"As of "+dtoc(date())+", "+time()
           ?
           ? MARGIN +"Concessionaires Code: " + cConCode + " - " + PLUTEMP->DESC 
           ?
           ? MARGIN+repl("-",nLineLen)        
           ? MARGIN +"          DATE      UNIT COST        QUANTITY     AMOUNT SOLD"
           ? MARGIN+repl("-",nLineLen)
           ?
           lNewpage := .f.
           nLineCtr := 13
          endif

          ? MARGIN + space(7) + dtoc(PLUTEMP->DATE) 
            ??  space(3) + tran(PLUTEMP->I_UCOST,"999,999,999.99")
            ?? space(3) + tran(PLUTEMP->ICOUNT,"99,999.99")
            ?? space(2) + tran(PLUTEMP->IAMOUNT,"999,999,999.99")
          nLineCtr += 1
 
          nPagesqty += PLUTEMP->ICOUNT
          nPagestot += PLUTEMP->IAMOUNT
          nPageUCost += PLUTEMP->I_UCOST
          nRunsqty += PLUTEMP->ICOUNT
          nRunstot += PLUTEMP->IAMOUNT
          nRunUCost += PLUTEMP->I_UCOST
       
          if nLineCtr >= MAX_LINE
            ? 
            ? MARGIN+repl("-",nLineLen)
            ? MARGIN+"Page Total    : " + ;
                space(2) + trans(nPageUCost,"999,999,999.99") +;
                space(2) + trans(nPagesqty,"999,999.99") +;
                space(2) + trans(nPagestot,"999,999,999.99")
            ? MARGIN+"Running Total : " +; 
                space(2) + trans(nRunUCost,"999,999,999.99") +;    
                space(2) + trans(nRunsqty,"999,999.99") +;
                space(2) + trans(nRunsTot,"999,999,999.99")
            ? MARGIN+padl("Page # "+alltrim(trans(nPageCtr++,"9,999")),nLineLen)		                  
            ? MARGIN+repl("-",nLineLen)
            ?
            // Reset page counter
            nPagesqty := 0
            nPagestot := 0
            nPageUCost := 0 
            lNewPage := .t.
            // eject
            ? chr(12)  
          endif  
       endif   
       PLUTEMP->(DbSkip())   
     enddo

     if !lNewPage
       ? 
       ? MARGIN+repl("-",nLineLen)
       ? MARGIN+"Page Total    : " + ;
           space(2) + trans(nPageUCost,"999,999,999.99") +;
           space(2) + trans(nPagesqty,"999,999.99") +;
           space(2) + trans(nPagestot,"999,999,999.99")
     endif  
          
     ? MARGIN+"Running Total : " +; 
         space(2) + trans(nRunUCost,"999,999,999.99") +;    
         space(2) + trans(nRunsqty,"999,999.99") +;
         space(2) + trans(nRunsTot,"999,999,999.99")
     ? MARGIN+padl("Page # "+alltrim(trans(nPageCtr++,"9,999")),nLineLen)		                  
     ? MARGIN+repl("-",nLineLen)
     ?
     // eject
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
      wWindow:=OpenWindow(1,2,maxrow()-1,maxcol()-2,"Concessionaire Sales Report")
      MemoEdit(cReport,2,3,maxrow()-2,maxcol()-3,.f.,'EditorFunc',122 )
      CloseWindow(wWindow)
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
   
 enddo

return nil
*/