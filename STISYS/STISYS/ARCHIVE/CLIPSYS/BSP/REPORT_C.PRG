// Filename:      REPORT_C.PRG
// System-Name:   Bank Settlement Plan System
// Module:        Printing of Sales Reports
// Author:        Rollie C. Ibarra Jr.
// Date-Started:  Oct 30, 1993
// Last-Update:   Oct 30, 1993

#include "Mode.Ch"
#include "BSP.Ch"
#include "SetCurs.ch"
#include "Inkey.ch"

static cQtr

function Sales_Report(nMode)
local aItems := {}
local vGRemit_PHP:= vGRemit_USD:= vGTax_PHP:= vGTax_USD:= vGADM_PHP:= 0
local vGADM_USD:= vGACM_PHP:= vGACM_USD:= vGTotal_PHP:= vGTotal_USD:= 0
local vGOther_PHP := vGOther_USD :=  vTotal_PHP := vTotal_USD := 0
   do case
       case nMode == 1 ;  lDateOk := GetMonth()
       case nMode == 2 ;  lDateOk := GetQuarter()
       case nMode == 3 ;  lDateOk := GetYear()
       case nMode == 4 ;  lDateOk := GetDates()
   endcase
   if lDateOk
      if isPrinter()
         Set(_SET_CONSOLE,.f.)
         Set(_SET_PRINTER,.t.)
         Sti_Header(2)
         ?
         ?
         ? chr(27) + chr(119)+ chr(1)  // Double Heigth
         do case
            case nMode == 1
              ?? "þMonthly Sales Report - B.S.P."
              ?
              ? "For the Month of "+cmonth(dStartDate)+", ";
                +transform(year(dStartDate),"9999")
            case nMode == 2
              ?? "þQuarterly Sales Report - B.S.P."
              ?
              ? "For the " +if(cQtr=="1","1st ",;
                               if(cQtr=="2","2nd ",;
                                 if(cQtr=="3","3rd ","4th ");
                                ) )+;
                 +"Quarter of "+transform(year(dStartDate),"9999")
            case nMode == 3
              ?? "þAnnual Sales Report - B.S.P."
              ?
              ? "For the Year of "+transform(year(dStartDate),"9999")
            case nMode == 4
              ?? "þBSP Sales Report"
              ?
              ? "Period :" ,dStartDate, "to" ,dEndDate
            endcase
         ? chr(27) +chr(119)+ chr(0)    // Double Heigth off
         ?? chr(15)
         ?? chr(27) + chr(80)
         ?? chr(27)+chr(107)+chr(1)     //Roman Type//
         ?? chr(27)+chr(120)+chr(1)     //NLQ on//
         ? space(38) + "ÃÄÄÄÄÄÄÄÄÄ Airfare ÄÄÄÄÄÄÄÄ´"
         ?? space(2) + "ÃÄÄÄÄÄÄÄ Travel Tax ÄÄÄÄÄÄÄ´"
         ?? space(2) + "ÃÄÄÄÄÄÄÄÄÄ Others ÄÄÄÄÄÄÄÄÄ´"
         ?? space(2) + "ÃÄÄÄ Airline Debit Memos ÄÄ´"
         ?? space(2) + "ÃÄÄ Airline Credit Memos ÄÄ´"
         ?? space(2) + "ÃÄÄÄÄÄÄÄÄÄ Totals ÄÄÄÄÄÄÄÄÄ´"
         ? space(6) + "Airlines"
         ?? space(24) + replicate("    Peso          Dollar      ",6)
         ?? chr(27)+chr(107)+chr(0)     //Roman Type//
         ?? chr(27)+chr(120)+chr(0)     //NLQ off//
         ?
         aItems := Get_Sales()
         Message("Printing....")
         for x:=1 to len(aItems)
            if (aItems[x][2]+aItems[x][3]+aItems[x][4]+aItems[x][5]+;
                aItems[x][6]+aItems[x][7]+aItems[x][8]+aItems[x][9]+;
                aItems[x][10]+aItems[x][11]+aItems[x][12]+aItems[x][13]!= 0.00) .or. (nMode==3)
                ? "(" + aItems[x][1] + ")" + space(2)
                AIRLINE->(DbSeek(aItems[x][1]))
                ?? substr(AIRLINE->AIRLINE,1,25) + space(6)
                ?? blank_ifzero(aItems[x][2],"99,999,999.99") + space(2)
                ?? blank_ifzero(aItems[x][3],"99,999,999.99") + space(2)
                ?? blank_ifzero(aItems[x][4],"99,999,999.99") + space(2)
                ?? blank_ifzero(aItems[x][5],"99,999,999.99") + space(2)
                ?? blank_ifzero(aItems[x][6],"99,999,999.99") + space(2)
                ?? blank_ifzero(aItems[x][7],"99,999,999.99") + space(2)
                ?? blank_ifzero(aItems[x][8],"99,999,999.99") + space(2)
                ?? blank_ifzero(aItems[x][9],"99,999,999.99") + space(2)
                ?? blank_ifzero(aItems[x][10],"99,999,999.99") + space(2)
                ?? blank_ifzero(aItems[x][11],"99,999,999.99") + space(2)
                vTotal_PHP := aItems[x][2] + aItems[x][4] + aItems[x][6] +;
                              aItems[x][8] - aItems[x][10] - aItems[x][12]
                vTotal_USD := aItems[x][3] + aItems[x][5] + aItems[x][7] +;
                              aItems[x][9] - aItems[x][11] - aItems[x][13]
                ?? blank_ifzero(vTotal_PHP,"99,999,999.99") + space(2)
                ?? blank_ifzero(vToTal_USD,"99,999,999.99")
                vGRemit_PHP += aItems[x][2]
                vGRemit_USD += aItems[x][3]
                vGTax_PHP += aItems[x][4]
                vGTax_USD += aItems[x][5]
                vGOther_PHP += aItems[x][6]
                vGOther_USD += aItems[x][7]
                vGADM_PHP += aItems[x][8]
                vGADM_USD += aItems[x][9]
                vGACM_PHP += aItems[x][10]
                vGACM_USD += aItems[x][11]
                vGTotal_PHP += vTotal_PHP
                vGTotal_USD += vTotal_USD
            endif
         next
         ? replicate("=",232)
         ? space(38)
         ?? blank_ifzero(vGRemit_PHP,"99,999,999.99") + space(2)
         ?? blank_ifzero(vGRemit_USD,"99,999,999.99") + space(2)
         ?? blank_ifzero(vGTax_PHP,"99,999,999.99") + space(2)
         ?? blank_ifzero(vGTax_USD,"99,999,999.99") + space(2)
         ?? blank_ifzero(vGOther_PHP,"99,999,999.99") + space(2)
         ?? blank_ifzero(vGOther_USD,"99,999,999.99") + space(2)
         ?? blank_ifzero(vGADM_PHP,"99,999,999.99") + space(2)
         ?? blank_ifzero(vGADM_USD,"99,999,999.99") + space(2)
         ?? blank_ifzero(vGACM_PHP,"99,999,999.99") + space(2)
         ?? blank_ifzero(vGACM_USD,"99,999,999.99") + space(2)
         ?? blank_ifzero(vGTotal_PHP,"99,999,999.99") + space(2)
         ?? blank_ifzero(vGTotal_USD,"99,999,999.99")
         Set(_SET_CONSOLE,.t.)
         Set(_SET_PRINTER,.f.)
         Tone(300,1)
      else
          Message("Printer not Ready...")
          Tone(100,3)
          inkey(2)
      endif
   endif
return nil

static function Get_Sales()
local aItems := {}
    Message("Thinking...")
    AIRLINE->(DbGotop())
    do while AIRLINE->(!Eof())
        if val(AIRLINE->AIR_CODE) >= 0
            aAdd(aItems,{AIRLINE->AIR_CODE, 0,0, 0,0,;
            0,0, 0,0, 0,0, 0,0})
        endif
        AIRLINE->(DbSkip())
    enddo
    for i := 1 to 5
        cDbf:=OpenBSP(i)
        do case
           case i==1 ; cTitle:="MCO's"
           case i==2 ; cTitle:="Series 2 Tickets"
           case i==3 ; cTitle:="Series 4 Tickets"
           case i==4 ; cTitle:="Apollo Tickets"
           case i==5 ; cTitle:="Abacus Tickets"
        endcase
        Message("Searching "+cTitle+"...")
        (cDbf)->(DbSetOrder(DATE_NDX))
        (cDbf)->(DbSeek(dStartDate))
        do while ((cDbf)->DATE <= dEndDate) .and. (cDbf)->(!Eof())
            Message(cDbf+" Record #"+transform((cDbf)->(Recno()),"9999")+"...")
            store 0 to Tax_Php, Other_Php, Rem_Php ,CommDue_Php
            store 0 to Tax_Usd, Other_Usd, Rem_Usd ,CommDue_Usd
            if (cDbf == "MCO")
                * ---Compute for AirFare in PHP ---
                Rem_PHP := AIRFARE_P
                Rem_USD := AIRFARE_D
                * ---Compute for Tax in PHP ---
                if empty((cDbf)->TAX_P)
                   if empty((cDbf)->AIRFARE_P)
                      if("TAX" $ (cDbf)->ROUTE_1+(cDbf)->ROUTE_2)
                          Tax_PHP := (cDbf)->REMIT_P
                      else
                          Other_PHP := (cDbf)->REMIT_P
                      endif
                   else
                      Tax_PHP := (cDbf)->REMIT_P - (cDbf)->AIRFARE_P
                   endif
                else
                   Tax_PHP := (CDbf)->TAX_P + ((cDbf)->REMIT_P - (cDbf)->AIRFARE_P)
                endif
                * ---Compute for Tax in PHP ---
                if empty((cDbf)->TAX_D)
                   if empty((cDbf)->AIRFARE_D)
                      if("TAX" $ (cDbf)->ROUTE_1+(cDbf)->ROUTE_2)
                          Tax_USD := (cDbf)->REMIT_D
                      else
                          if ("TX(" $ (cDbf)->ROUTE_1+(cDbf)->ROUTE_2)
                              x:=at("(",(cDbf)->ROUTE_1+(cDbf)->ROUTE_2)
                              cLess:=substr((cDbf)->ROUTE_1+(cDbf)->ROUTE_2,x,;
                                     at(")",(cDbf)->ROUTE_1+(cDbf)->ROUTE_2)-x-1)
                              Other_USD:=(cDbf)->REMIT_P - val(cLess)
                              Tax_USD := val(cLess)
                          else
                               Other_USD := (cDbf)->REMIT_D
                          endif
                      endif
                   else
                      Tax_USD := (cDbf)->REMIT_D - (cDbf)->AIRFARE_D
                   endif
                else
                   Tax_USD := (CDbf)->TAX_D + ((cDbf)->REMIT_D - (cDbf)->AIRFARE_D)
                endif
            else
                Rem_PHP := (cDbf)->REMIT_P
                Rem_USD := (cDbf)->REMIT_D
                Tax_PHP := (cDbf)->TAX_P
                Tax_USD := (cDbf)->TAX_D
                 * ---Take Comm/Diff.Due if any---
                 CommDue_Php:= (cDbf)->ACM_P
                 CommDue_Usd:= (cDbf)->ACM_D
            endif
            cAirCode := substr((cDbf)->TICKET_NO,1,3)
            x := aScan(aItems,{ |x| x[1] == cAirCode})
            if x != 0
                aItems[x][2] += Rem_PHP
                aItems[x][3] += Rem_USD
                aItems[x][4] += Tax_PHP
                aItems[x][5] += Tax_USD
                aItems[x][6] += Other_PHP
                aItems[x][7] += Other_USD
                aItems[x][12] += CommDue_Php
                aItems[x][13] += CommDue_Usd
            endif
            (cDbf)->(DbSkip())
        enddo
        (cDbf)->(DbCloseArea())
    next
    if NetUse("MEMO",DB_SHARED,NUM_SECONDS)
        set index to MEMO
    endif
    Message("Searching Airline Memos...")
    MEMO->(DbSeek(dStartDate))
    do while (MEMO->DATE <= dEndDate) .and. MEMO->(!Eof())
        Message("Memo Record #"+transform(MEMO->(Recno()),"9999")+"...")
        if (substr(MEMO->FOLIO,1,3) == "ADM")
            x := aScan(aItems,{ |x| x[1] == MEMO->AIR_CODE})
            if x != 0
                aItems[x][8] += MEMO->AMOUNT_P
                aItems[x][9] += MEMO->AMOUNT_D
            endif
        endif
        if (substr(MEMO->FOLIO,1,3) == "ACM")
            x := aScan(aItems,{ |x| x[1] == MEMO->AIR_CODE})
            if x != 0
                aItems[x][10]  += MEMO->AMOUNT_P
                aItems[x][11] += MEMO->AMOUNT_D
            endif
        endif
        if (substr(MEMO->FOLIO,1,2) == "RN")
            x := aScan(aItems,{ |x| x[1] == MEMO->AIR_CODE})
            if x != 0
                aItems[x][10]  += MEMO->AMOUNT_P
                aItems[x][11] += MEMO->AMOUNT_D
            endif
        endif
        MEMO->(DbSkip())
    enddo
    MEMO->(DbCloseArea())
return aItems

static function GetMonth()
local wDate, cMo := "  " , cYr := "  "
   dStartDate:=dEndDate:=CToD("  -  -  ")
   Message("Enter transaction dates, press Esc to abort.")
   wDate:=OpenWindow(08,25,12,55,"Date Information Box")
   @ 10,28 say " Enter month (1..12)" get cMo
   @ 11,28 say "     Enter year (99)" get cYr
   SetCursor(SC_NORMAL)
   read
   SetCursor(SC_NONE)
   CloseWindow(wDate)
   If LastKey()==K_ESC
      return .F.
   else
      dStartDate:=ctod(cMo+"-01-"+cYr)
      dEndDate:=dStartDate
      do while substr(dtoc(dEndDate+1),1,2) == cMo
          dEndDate ++
      enddo
   endif
return .T.

static function GetQuarter()
local wDate, cYr := "  "
   cQtr := " "
   dStartDate:=dEndDate:=CToD("  -  -  ")
   Message("Enter transaction dates, press Esc to abort.")
   wDate:=OpenWindow(08,25,12,55,"Date Information Box")
   @ 10,28 say " Enter Quarter (1..4)" get cQtr pict "9"
   @ 11,28 say "      Enter year (99)" get cYr  pict "99"
   SetCursor(SC_NORMAL)
   read
   SetCursor(SC_NONE)
   CloseWindow(wDate)
   If LastKey()==K_ESC
      return .F.
   else
      do case
         case cQtr == "1"
             dStartDate := ctod("01-01-"+cYr)
             dEndDate := ctod("03-31-"+cYr)
         case cQtr == "2"
             dStartDate := ctod("04-01-"+cYr)
             dEndDate := ctod("06-30-"+cYr)
         case cQtr == "3"
             dStartDate := ctod("07-01-"+cYr)
             dEndDate := ctod("09-30-"+cYr)
         case cQtr == "4"
             dStartDate := ctod("10-01-"+cYr)
             dEndDate := ctod("12-31-"+cYr)
      endcase
   endif
return .T.

static function GetYear()
local wDate, cYr := "  "
   dStartDate:=dEndDate:=CToD("  -  -  ")
   Message("Enter transaction dates, press Esc to abort.")
   wDate:=OpenWindow(08,25,11,55,"Date Information Box")
   @ 10,28 say "      Enter year (99)" get cYr pict "99"
   SetCursor(SC_NORMAL)
   read
   SetCursor(SC_NONE)
   CloseWindow(wDate)
   If LastKey()==K_ESC
      return .F.
   else
      dStartDate:=ctod("01-01-"+cYr)
      dEndDate:=ctod("12-31-"+cYr)
   endif
return .T.

function YearSum()
local nGrandPhp := 0, nGrandUsd := 0, cYear
   if GetYear()
      if isPrinter()
         use airline index air_code new
         Message("Thinking...")
         aCodes := {}    ;  aJanTotals := {}
         Airline->(DbGoTop())
         do while Airline->(!Eof())
            if (val(Airline->Air_Code) >= 0)
               aAdd(aCodes,{Airline->Air_Code,.F.})
               aAdd(aJanTotals,{0,0})
               aAdd(aComm_Due,0)
            endif
            Airline->(DbSkip())
         enddo
         aFebTotals := aClone(aJanTotals)
         aMarTotals := aClone(aJanTotals) ; aAprTotals := aClone(aJanTotals)
         aMayTotals := aClone(aJanTotals) ; aJunTotals := aClone(aJanTotals)
         aJulTotals := aClone(aJanTotals) ; aAugTotals := aClone(aJanTotals)
         aSepTotals := aClone(aJanTotals) ; aOctTotals := aClone(aJanTotals)
         aNovTotals := aClone(aJanTotals) ; aDecTotals := aClone(aJanTotals)
         cYear := substr(dtoc(dStartDate),7,2)
         for x:= 1 to 5
            cDbf := OpenBsp(x)
            (cDbf)->(DbSetOrder(DATE_NDX))
            (cDbf)->(DbSeek(dStartDate))
            do while (cDbf)->(!Eof()) .and. ((cDbf)->Date <= dEndDate)
               Message("Reading " + cDbf + " Record #"+ ;
                  transform((cDbf)->(RecNo()),"9999") )
               cCode := substr((cDbf)->Ticket_No,1,3)
               if (n := aScan(aCodes,{|a| a[1] == cCode})) != 0
                  if (x==1)
                     nRem_Php := (cDbf)->Airfare_P
                     nRem_Usd := (cDbf)->Airfare_D
                  else
                     nRem_Php := (cDbf)->Remit_P
                     nRem_Usd := (cDbf)->Remit_D
                     aComm_Due[n] += (cDbf)->ACM_D
                  endif
                  if (cDbf)->Date < ctod("02-01-"+cYear)
                     aJanTotals[n][1] += nRem_Php
                     aJanTotals[n][2] += nRem_Usd
                  elseif (cDbf)->Date < ctod("03-01-"+cYear)
                     aFebTotals[n][1] += nRem_Php
                     aFebTotals[n][2] += nRem_Usd
                  elseif (cDbf)->Date < ctod("04-01-"+cYear)
                     aMarTotals[n][1] += nRem_Php
                     aMarTotals[n][2] += nRem_Usd
                  elseif (cDbf)->Date < ctod("05-01-"+cYear)
                     aAprTotals[n][1] += nRem_Php
                     aAprTotals[n][2] += nRem_Usd
                  elseif (cDbf)->Date < ctod("06-01-"+cYear)
                     aMayTotals[n][1] += nRem_Php
                     aMayTotals[n][2] += nRem_Usd
                  elseif (cDbf)->Date < ctod("07-01-"+cYear)
                     aJunTotals[n][1] += nRem_Php
                     aJunTotals[n][2] += nRem_Usd
                  elseif (cDbf)->Date < ctod("08-01-"+cYear)
                     aJulTotals[n][1] += nRem_Php
                     aJulTotals[n][2] += nRem_Usd
                  elseif (cDbf)->Date < ctod("09-01-"+cYear)
                     aAugTotals[n][1] += nRem_Php
                     aAugTotals[n][2] += nRem_Usd
                  elseif (cDbf)->Date < ctod("10-01-"+cYear)
                     aSepTotals[n][1] += nRem_Php
                     aSepTotals[n][2] += nRem_Usd
                  elseif (cDbf)->Date < ctod("11-01-"+cYear)
                     aOctTotals[n][1] += nRem_Php
                     aOctTotals[n][2] += nRem_Usd
                  elseif (cDbf)->Date < ctod("12-01-"+cYear)
                     aNovTotals[n][1] += nRem_Php
                     aNovTotals[n][2] += nRem_Usd
                  else
                     aDecTotals[n][1] += nRem_Php
                     aDecTotals[n][2] += nRem_Usd
                  endif
               endif
               (cDbf)->(DbSkip())
            enddo
            (cDbf)->(DbCloseArea())
         next
         Message("Insert 132 column paper and press any key...")
         inkey(0)
         Message("Printing...")
         for x:=1 to len(aCodes)
            aCodes[x][2] := if(aJanTotals[x][1]+aJanTotals[x][2]+;
                               aFebTotals[x][1]+aFebTotals[x][2]+;
                               aMarTotals[x][1]+aMarTotals[x][2]+;
                               aAprTotals[x][1]+aAprTotals[x][2]+;
                               aMayTotals[x][1]+aMayTotals[x][2]+;
                               aJunTotals[x][1]+aJunTotals[x][2]+;
                               aJulTotals[x][1]+aJulTotals[x][2]+;
                               aAugTotals[x][1]+aAugTotals[x][2]+;
                               aSepTotals[x][1]+aSepTotals[x][2]+;
                               aOctTotals[x][1]+aOctTotals[x][2]+;
                               aNovTotals[x][1]+aNovTotals[x][2]+;
                               aDecTotals[x][1]+aDecTotals[x][2] != 0,;
                               .T.,.F.)
         next
         Set(_SET_CONSOLE,.F.)
         Set(_SET_PRINTER,.T.)
         STI_Header(2)
         ? chr(27) + chr(119)+ chr(1)  // Double Heigth
         ?? "þSummary of Airfare Remittance from BSP MCO & Tickets"
         ?
         ? "January to June "+substr(dtoc(dStartDate),7,2)
         ? chr(27) + chr(119)+ chr(0)  // Double Heigth off
         ?? chr(15)                     //Condense on//
         ?? chr(27)+chr(107)+chr(0)     //Roman Type//
         ?? chr(27)+chr(120)+chr(1)     //NLQ on//
         ? space(41)
         ?? ' ' + "ÃÄÄÄÄÄÄÄ January ÄÄÄÄÄÄÄ´"
         ?? ' ' + "ÃÄÄÄÄÄÄÄ February ÄÄÄÄÄÄ´"
         ?? ' ' + "ÃÄÄÄÄÄÄÄÄ March ÄÄÄÄÄÄÄÄ´"
         ?? ' ' + "ÃÄÄÄÄÄÄÄÄ April ÄÄÄÄÄÄÄÄ´"
         ?? ' ' + "ÃÄÄÄÄÄÄÄÄÄ May ÄÄÄÄÄÄÄÄÄ´"
         ?? ' ' + "ÃÄÄÄÄÄÄÄÄ June ÄÄÄÄÄÄÄÄÄ´"
         ?? ' ' + "ÃÄÄÄÄÄÄÄ Totals ÄÄÄÄÄÄÄÄ´"
         ? padc('Airlines',42) + repl("    Peso        Dollar    ",7)
         ?? chr(27)+chr(120)+chr(0)     //NLQ on//
         for x:=1 to len(aCodes)
            if aCodes[x][2]
               Airline->(DbSeek(aCodes[x][1]))
               ?  '('+ aCodes[x][1] +')  ' + Airline->Airline
               ?? blank_ifzero(aJanTotals[x][1],"9,999,999.99")
               ?? ' ' + blank_ifzero(aJanTotals[x][2],"9,999,999.99")
               ?? ' ' + blank_ifzero(aFebTotals[x][1],"9,999,999.99")
               ?? ' ' + blank_ifzero(aFebTotals[x][2],"9,999,999.99")
               ?? ' ' + blank_ifzero(aMarTotals[x][1],"9,999,999.99")
               ?? ' ' + blank_ifzero(aMarTotals[x][2],"9,999,999.99")
               ?? ' ' + blank_ifzero(aAprTotals[x][1],"9,999,999.99")
               ?? ' ' + blank_ifzero(aAprTotals[x][2],"9,999,999.99")
               ?? ' ' + blank_ifzero(aMayTotals[x][1],"9,999,999.99")
               ?? ' ' + blank_ifzero(aMayTotals[x][2],"9,999,999.99")
               ?? ' ' + blank_ifzero(aJunTotals[x][1],"9,999,999.99")
               ?? ' ' + blank_ifzero(aJunTotals[x][2],"9,999,999.99")
               ?? ' ' + blank_ifzero(aJanTotals[x][1]+aFebTotals[x][1]+;
               aMarTotals[x][1]+aAprTotals[x][1]+;
               aMayTotals[x][1]+aJunTotals[x][1],"9,999,999.99")
               ?? ' ' + blank_ifzero(aJanTotals[x][2]+aFebTotals[x][2]+;
               aMarTotals[x][2]+aAprTotals[x][2]+;
               aMayTotals[x][2]+aJunTotals[x][2]-aCommDue[x],"9,999,999.99")
            endif
         next
         ? repl('=',225)
         store 0 to nTotalPhp, nTotalUsd
         ?  space(41)
         nTotal := 0;  aEval(aJanTotals,{|x| nTotal += x[1]})
         ?? ' ' + blank_ifzero(nTotal,"9,999,999.99")
         nTotalPhp += nTotal
         nTotal := 0;  aEval(aJanTotals,{|x| nTotal += x[2]})
         ?? ' ' + blank_ifzero(nTotal,"9,999,999.99")
         nTotalUsd += nTotal
         nTotal := 0;  aEval(aFebTotals,{|x| nTotal += x[1]})
         ?? ' ' + blank_ifzero(nTotal,"9,999,999.99")
         nTotalPhp += nTotal
         nTotal := 0;  aEval(aFebTotals,{|x| nTotal += x[2]})
         ?? ' ' + blank_ifzero(nTotal,"9,999,999.99")
         nTotalUsd += nTotal
         nTotal := 0;  aEval(aMarTotals,{|x| nTotal += x[1]})
         ?? ' ' + blank_ifzero(nTotal,"9,999,999.99")
         nTotalPhp += nTotal
         nTotal := 0;  aEval(aMarTotals,{|x| nTotal += x[2]})
         ?? ' ' + blank_ifzero(nTotal,"9,999,999.99")
         nTotalUsd += nTotal
         nTotal := 0;  aEval(aAprTotals,{|x| nTotal += x[1]})
         ?? ' ' + blank_ifzero(nTotal,"9,999,999.99")
         nTotalPhp += nTotal
         nTotal := 0;  aEval(aAprTotals,{|x| nTotal += x[2]})
         ?? ' ' + blank_ifzero(nTotal,"9,999,999.99")
         nTotalUsd += nTotal
         nTotal := 0;  aEval(aMayTotals,{|x| nTotal += x[1]})
         ?? ' ' + blank_ifzero(nTotal,"9,999,999.99")
         nTotalPhp += nTotal
         nTotal := 0;  aEval(aMayTotals,{|x| nTotal += x[2]})
         ?? ' ' + blank_ifzero(nTotal,"9,999,999.99")
         nTotalUsd += nTotal
         nTotal := 0;  aEval(aJunTotals,{|x| nTotal += x[1]})
         ?? ' ' + blank_ifzero(nTotal,"9,999,999.99")
         nTotalPhp += nTotal
         nTotal := 0;  aEval(aJunTotals,{|x| nTotal += x[2]})
         ?? ' ' + blank_ifzero(nTotal,"9,999,999.99")
         nTotalUsd += nTotal
         ?? ' ' + blank_ifzero(nTotalPhp,"9,999,999.99")
         ?? ' ' + blank_ifzero(nTotalUsd,"9,999,999.99")
         eject
         nGrandPhp += nTotalPhp
         nGrandUsd += nTotalUsd

         STI_Header(2)
         ? chr(27) + chr(119)+ chr(1)  // Double Heigth
         ?? "þSummary of Airfare Remittance from BSP MCO & Tickets"
          ?
         ? "July to December "+substr(dtoc(dStartDate),7,2)
         ? chr(27) + chr(119)+ chr(0)  // Double Heigth off
         ?? chr(15)                     //Condense on//
         ?? chr(27)+chr(107)+chr(0)     //Roman Type//
         ?? chr(27)+chr(120)+chr(1)     //NLQ on//
         ? space(41)
         ?? ' ' + "ÃÄÄÄÄÄÄÄÄ July ÄÄÄÄÄÄÄÄÄ´"
         ?? ' ' + "ÃÄÄÄÄÄÄÄ August ÄÄÄÄÄÄÄÄ´"
         ?? ' ' + "ÃÄÄÄÄÄÄ September ÄÄÄÄÄÄ´"
         ?? ' ' + "ÃÄÄÄÄÄÄÄ October ÄÄÄÄÄÄÄ´"
         ?? ' ' + "ÃÄÄÄÄÄÄÄ November ÄÄÄÄÄÄ´"
         ?? ' ' + "ÃÄÄÄÄÄÄÄ December ÄÄÄÄÄÄ´"
         ?? ' ' + "ÃÄÄÄÄÄÄÄ Totals ÄÄÄÄÄÄÄÄ´"
         ? padc('Airlines',42) + repl("    Peso        Dollar    ",7)
         ?? chr(27)+chr(120)+chr(0)     //NLQ on//
         for x:=1 to len(aCodes)
            if aCodes[x][2]
               Airline->(DbSeek(aCodes[x][1]))
               ?  '('+ aCodes[x][1] +')  ' + Airline->Airline
               ?? blank_ifzero(aJulTotals[x][1],"9,999,999.99")
               ?? ' ' + blank_ifzero(aJulTotals[x][2],"9,999,999.99")
               ?? ' ' + blank_ifzero(aAugTotals[x][1],"9,999,999.99")
               ?? ' ' + blank_ifzero(aAugTotals[x][2],"9,999,999.99")
               ?? ' ' + blank_ifzero(aSepTotals[x][1],"9,999,999.99")
               ?? ' ' + blank_ifzero(aSepTotals[x][2],"9,999,999.99")
               ?? ' ' + blank_ifzero(aOctTotals[x][1],"9,999,999.99")
               ?? ' ' + blank_ifzero(aOctTotals[x][2],"9,999,999.99")
               ?? ' ' + blank_ifzero(aNovTotals[x][1],"9,999,999.99")
               ?? ' ' + blank_ifzero(aNovTotals[x][2],"9,999,999.99")
               ?? ' ' + blank_ifzero(aDecTotals[x][1],"9,999,999.99")
               ?? ' ' + blank_ifzero(aDecTotals[x][2],"9,999,999.99")
               ?? ' ' + blank_ifzero(aJulTotals[x][1]+aAugTotals[x][1]+;
               aSepTotals[x][1]+aOctTotals[x][1]+;
               aNovTotals[x][1]+aDecTotals[x][1],"9,999,999.99")
               ?? ' ' + blank_ifzero(aJulTotals[x][2]+aAugTotals[x][2]+;
               aSepTotals[x][2]+aOctTotals[x][2]+;
               aNovTotals[x][2]+aDecTotals[x][2],"9,999,999.99")
            endif
         next
         ? repl('=',225)
         store 0 to nTotalPhp, nTotalUsd
         ?  space(41)
         nTotal := 0;  aEval(aJulTotals,{|x| nTotal += x[1]})
         ?? ' ' + blank_ifzero(nTotal,"9,999,999.99")
         nTotalPhp += nTotal
         nTotal := 0;  aEval(aJulTotals,{|x| nTotal += x[2]})
         ?? ' ' + blank_ifzero(nTotal,"9,999,999.99")
         nTotalUsd += nTotal
         nTotal := 0;  aEval(aAugTotals,{|x| nTotal += x[1]})
         ?? ' ' + blank_ifzero(nTotal,"9,999,999.99")
         nTotalPhp += nTotal
         nTotal := 0;  aEval(aAugTotals,{|x| nTotal += x[2]})
         ?? ' ' + blank_ifzero(nTotal,"9,999,999.99")
         nTotalUsd += nTotal
         nTotal := 0;  aEval(aSepTotals,{|x| nTotal += x[1]})
         ?? ' ' + blank_ifzero(nTotal,"9,999,999.99")
         nTotalPhp += nTotal
         nTotal := 0;  aEval(aSepTotals,{|x| nTotal += x[2]})
         ?? ' ' + blank_ifzero(nTotal,"9,999,999.99")
         nTotalUsd += nTotal
         nTotal := 0;  aEval(aOctTotals,{|x| nTotal += x[1]})
         ?? ' ' + blank_ifzero(nTotal,"9,999,999.99")
         nTotalPhp += nTotal
         nTotal := 0;  aEval(aOctTotals,{|x| nTotal += x[2]})
         ?? ' ' + blank_ifzero(nTotal,"9,999,999.99")
         nTotalUsd += nTotal
         nTotal := 0;  aEval(aNovTotals,{|x| nTotal += x[1]})
         ?? ' ' + blank_ifzero(nTotal,"9,999,999.99")
         nTotalPhp += nTotal
         nTotal := 0;  aEval(aNovTotals,{|x| nTotal += x[2]})
         ?? ' ' + blank_ifzero(nTotal,"9,999,999.99")
         nTotalUsd += nTotal
         nTotal := 0;  aEval(aDecTotals,{|x| nTotal += x[1]})
         ?? ' ' + blank_ifzero(nTotal,"9,999,999.99")
         nTotalPhp += nTotal
         nTotal := 0;  aEval(aDecTotals,{|x| nTotal += x[2]})
         ?? ' ' + blank_ifzero(nTotal,"9,999,999.99")
         nTotalUsd += nTotal
         ?? ' ' + blank_ifzero(nTotalPhp,"9,999,999.99")
         ?? ' ' + blank_ifzero(nTotalUsd,"9,999,999.99")
         nGrandPhp += nTotalPhp
         nGrandUsd += nTotalUsd
         if NetUse("ACR",DB_SHARED,NUM_SECONDS)
            set index to ACR
         endif
         ? chr(18)
         ?? chr(27)+chr(120)+chr(1)     // NLQ on
         ?? "Airline Conversion Rates"
         ACR->(DbSeek(dStartDate))
         do while ACR->(!Eof()) .and. (ACR->DateFrom <= dEndDate)
            ? space(10),expand(ACR->DateFrom),space(5),expand(ACR->DateTo)
            ?? space(6),transform(ACR->Amount,"99.99")
            ACR->(DbSkip())
         enddo
         ? repl('=',35)
         ?? chr(27)+chr(120)+chr(0)     // NLQ off
         eject
         ACR->(DbCloseArea())

         STI_Header(2)
         ? chr(27) + chr(119)+ chr(1)  // Double Heigth
         ?? "þBSP Yearly Totals and Percentage Summary"
         ?
         ? "January to December "+substr(dtoc(dStartDate),7,2)
         ? chr(27) + chr(119)+ chr(0)  // Double Heigth off
         ?? chr(27)+chr(107)+chr(0)     //Roman Type//
         ?? chr(27)+chr(120)+chr(1)     //NLQ on//
         ?  padc('Airlines',42)
         ?? "Peso Totals"
         ?? space(5) + "Dollar Totals"
         ?? space(5) + "Peso Percentage"
         ?? space(5) + "Dollar Percentage"
         ?
         for x:=1 to len(aCodes)
            if aCodes[x][2]
               nTotalPhp := ;
                  aJanTotals[x][1] + aFebTotals[x][1]+;
                  aMarTotals[x][1] + aAprTotals[x][1]+;
                  aMayTotals[x][1] + aJunTotals[x][1]+;
                  aJulTotals[x][1] + aAugTotals[x][1]+;
                  aSepTotals[x][1] + aOctTotals[x][1]+;
                  aNovTotals[x][1] + aDecTotals[x][1]
               nTotalUsd := ;
                  aJanTotals[x][2] + aFebTotals[x][2]+;
                  aMarTotals[x][2] + aAprTotals[x][2]+;
                  aMayTotals[x][2] + aJunTotals[x][2]+;
                  aJulTotals[x][2] + aAugTotals[x][2]+;
                  aSepTotals[x][2] + aOctTotals[x][2]+;
                  aNovTotals[x][2] + aDecTotals[x][2]
               Airline->(DbSeek(aCodes[x][1]))
               ?  '('+ aCodes[x][1] +')  ' + Airline->Airline
               ?? transform(nTotalPhp,"9,999,999.99")
               ?? space(5) + transform(nTotalUsd,"9,999,999.99")
               ?? space(8) + transform((nTotalPhp/nGrandPhp)*100,"99.99") + '%'
               ?? space(16) + transform((nTotalUsd/nGrandUsd)*100,"99.99") + '%'
            endif
         next
         ?
         ? repl('=',110)
         ? padr('Totals',42) + transform(nGrandPhp,"9,999,999.99")
         ?? space(5) + transform(nGrandUsd,"9,999,999.99")
         ?? chr(27)+chr(120)+chr(0)     //NLQ off//
         eject

         Set(_SET_PRINTER,.F.)
         Set(_SET_CONSOLE,.T.)
         Message("Printing done...")
         Tone(300,1)
         inkey(1)
      else
         Message("Printer not ready...")
         Tone(100,3)
         inkey(2)
      endif
   endif
return nil

function CompSum()
local cYear, dFirstDate := dLastDate := ctod("")
   if GetDates()
      if isPrinter()
         Message("Thinking...")
         aCodes := {}  ;  aCurrTotals := {}  ;   aPrevTotals := {}
         Airline->(DbGoTop())
         do while Airline->(!Eof())
            if (val(Airline->Air_Code) >= 0)
               aAdd(aCodes,{Airline->Air_Code,.F.})
               aAdd(aCurrTotals,{0,0})
            endif
            Airline->(DbSkip())
         enddo
         aPrevTotals := aClone(aCurrTotals)
         dFirstdate := dStartDate   ;  dLastDate := dEndDate
         cYear := substr(dtoc(dStartDate),7,2)
         for z:= 1 to 2
            if z == 1
               aTotals := aCurrTotals
            else
               dStartDate := ctod(substr(dtoc(dStartDate),1,6)+;
                             transform(val(cYear)-1,"99"))
               dEndDate := ctod(substr(dtoc(dEndDate),1,6)+;
                             transform(val(cYear)-1,"99"))
               aTotals := aPrevTotals
            endif
            for x:= 1 to 5
              cDbf := OpenBsp(x)
              (cDbf)->(DbSetOrder(DATE_NDX))
              (cDbf)->(DbSeek(dStartDate))
              do while (cDbf)->(!Eof()) .and. ((cDbf)->Date <= dEndDate)
                 Message("Reading " + cDbf + " Record #"+ ;
                    transform((cDbf)->(RecNo()),"9999") )
                 cCode := substr((cDbf)->Ticket_No,1,3)
                 if (n := aScan(aCodes,{|a| a[1] == cCode})) != 0
                    if (x==1)
                         nRem_Php := (cDbf)->Airfare_P
                         nRem_Usd := (cDbf)->Airfare_D
                    else
                         nRem_Php := (cDbf)->Remit_P
                         nRem_Usd := (cDbf)->Remit_D
                    endif
                    aTotals[n][1] += nRem_Php
                    aTotals[n][2] += nRem_Usd
                 endif
                 (cDbf)->(DbSkip())
              enddo
              (cDbf)->(DbCloseArea())
            next
         next
         dStartDate := dFirstDate   ;  dEndDate := dLastDate
         for x:= 1 to len(aCodes)
             aCodes[x][2] := (aCurrTotals[x][1] + aCurrTotals[x][2] +;
                              aPrevTotals[x][1] + aPrevTotals[x][2]) > 0
         next
         Message("Insert 80 column paper and press any key...")
         inkey(0)
         Message("Printing...")
         Set(_SET_CONSOLE,.F.)
         Set(_SET_PRINTER,.T.)
         STI_Header(1)
         ? chr(27) + chr(119)+ chr(1)  // Double Heigth
         ?? "þBSP Comparative Summary"
         ?
         ? "For the Period of : ",;
             cMonth(dStartDate),substr(dtoc(dStartDate),4,2),"to",;
             cMonth(dEndDate),substr(dtoc(dEndDate),4,2),+",",;
             transform(val(cYear)-1,"99") +"/"+ cYear
         ? chr(27) + chr(119)+ chr(0)   // Double Heigth off
         ?? chr(15)+chr(27)+chr(58)     // Condense on
         ?? chr(27)+chr(107)+chr(0)     // Roman Type
         ?? chr(27)+chr(120)+chr(1)     // NLQ on
         Set(_SET_MARGIN,15)
         ?
         ? space(48)
         ?? "ÚÄÄÄÄÄÄÄÄÄ 19"+ transform(val(cYear)-1,"99") +" ÄÄÄÄÄÄÄÄÄ¿"
         ?? space(5), "ÚÄÄÄÄÄÄÄÄÄ 19"+ cYear +" ÄÄÄÄÄÄÄÄÄ¿"
         ? space(47),"   Peso          Dollar   "
         ?? space(5),"   Peso          Dollar   "
         ?? chr(27)+chr(120)+chr(0)     // NLQ on
         store 0 to nCurrPhp, nCurrUSD, nPrevPHP, nPrevUSD
         for x:=1 to len(aCodes)
            if aCodes[x][2]
               Airline->(DbSeek(aCodes[x][1]))
               ?  '('+ aCodes[x][1] +')  ' + Airline->Airline,  space(5)
               ?? blank_ifzero(aPrevTotals[x][1],"999,999.99"), space(5)
               ?? blank_ifzero(aPrevTotals[x][2],"999,999.99"), space(5)
               ?? blank_ifzero(aCurrTotals[x][1],"999,999.99"), space(5)
               ?? blank_ifzero(aCurrTotals[x][2],"999,999.99")
               nCurrPHP += aCurrTotals[x][1]
               nCurrUSD += aCurrTotals[x][2]
               nPrevPHP += aPrevTotals[x][1]
               nPrevUSD += aPrevTotals[x][2]
            endif
         next
         ? repl('=',107)
         ?  space(48)
         ?? blank_ifzero(nPrevPHP,"999,999.99"), space(5)
         ?? blank_ifzero(nPrevUSD,"999,999.99"), space(5)
         ?? blank_ifzero(nCurrPHP,"999,999.99"), space(5)
         ?? blank_ifzero(nCurrUSD,"999,999.99")
         eject

         Set(_SET_MARGIN,0)
         Set(_SET_PRINTER,.F.)
         Set(_SET_CONSOLE,.T.)
         Message("Printing done...")
         Tone(300,1)
         inkey(1)
      else
         Message("Printer not ready...")
         Tone(100,3)
         inkey(2)
      endif
   endif
return nil

/*
static function FirstDOM(cMonth,cYear)
return ctod(cMonth + "-01-" + cYear)

static function LastDOM(cMonth,cYear)
return if(cMonth != "12",;
       FirstDOM(transform(val(cMonth)+1,"99"),cYear) -1,;
       FirstDOM("01",transform(val(cYear)+1,"99"))   )

static function GetInfo()
local winfo
   cMonth := cYear := "  "
   Message("Enter Month and Year, press Esc to abort.")
   winfo:=OpenWindow(09,15,13,63,"Information Box")
   @ 11,27 say " Month (1-January, so on..)" get cMonth pict "99"
   @ 12,27 say "                  Year (99)" get cYear  pict "99"
   SetCursor(SC_NORMAL)
   read
   SetCursor(SC_NONE)
   CloseWindow(winfo)
return If(LastKey()==K_ESC,.F.,.T.)
*/
// <EOF> - REPORT_C.PRG //

