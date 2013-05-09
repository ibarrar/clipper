*:*********************************************************************
*:
*: Procedure file: REPORTS.PRG
*:
*:         System: BSP.PRG (Bank Settlement of the Philippines)
*:         Author: Rolando Castro Ibarra  Jr.
*:      Copyright (c) 1992, Super Travel, Inc.
*:  Last modified: 12/05/93     11:26a
*:
*:  Procs & Fncts:
*:               : Reports()
*:               : Handle()
*:               : GetDates()
*:               : GetDates_Air()
*:               : Register1()
*:               : Register2()
*:               : FareDiff()
*:
*:*********************************************************************

#include "BSP.Ch"
#include "Inkey.Ch"
#include "Achoice.Ch"
#include "SetCurs.Ch"
#include "c501_mod.ch"
#include "Mode.Ch"

*!*********************************************************************
*!  Function  : Reports()
*!      Notes : Reports Menu
*!*********************************************************************
function Reports()
    local  wRMenu, aMenu[3]
    aMenu[1] := "   BSP Registry 1  "
    aMenu[2] := "   BSP Registry 2  "
    aMenu[3] := "   Fare Difference "
    Message(SELECT_BAR)
    wMenu:=OpenWindow(06,45,11,77,"Report Options")
    aChoice(08,47,10,75,aMenu,,"Handle")
    CloseWindow(wMenu)
    return nil

*!*********************************************************************
*!  Function  : Handle()
*!      Notes : Achoice Handler
*!*********************************************************************
function Handle(nMode,nCurElem,nRelPos)
    local nRetVal,nKey
    do case
       case nMode==AC_EXCEPT            // Is key stroke used by AChoice?
          nKey:=LastKey()               // No -- get last key pressed.
          do case
             case nKey==K_ESC           // Esc key pressed?
                nRetVal:=AC_ABORT       // Yes -- abort menu selection.
             case nKey==K_ENTER         // Enter key pressed?
                do case
                   case nCurElem == 1   ;   (cDbf)->(Register1())
                   case nCurElem == 2   ;   (cDbf)->(Register2())
                   case nCurElem == 3   ;   (cDbf)->(FareDiff())
                endcase
                nRetVal:=AC_CONT
             otherwise                  // Other keys pressed.
                nRetVal:=AC_CONT        // Continue selection.
          endcase
       otherwise                        // Keystoke used by Achoice.
          nRetVal:=AC_CONT              // ....continue selection.
    endcase
    Message(SELECT_BAR)
    return nRetVal

*!*********************************************************************
*!  Function  : GetDates()
*!      Notes : Input Window for Date Info.
*!*********************************************************************
function GetDates()
   local wDate
   dStartDate:=dEndDate:=CToD("  -  -  ")
   Message("Enter transaction dates, press Esc to abort.")
   wDate:=OpenWindow(08,15,12,63,"Date Information Box")
   @ 10,17 say "Enter starting date (MM/DD/YY format)" get dStartDate
   @ 11,17 say "        Ending date (MM/DD/YY format)" get dEndDate
   SetCursor(SC_NORMAL)
   read
   SetCursor(SC_NONE)
   CloseWindow(wDate)
   return If(LastKey()==K_ESC,.F.,.T.)

*!*********************************************************************
*!  Function  : GetDates_Air()
*!      Notes : Input Window for Date & Aircode Info.
*!*********************************************************************
function GetDates_Air()
    local wDate
    dStartDate:=dEndDate:=CToD("  -  -  ")  ;  cAircode:="   "
    Message("Enter transaction dates, press Esc to abort, F1 to list Air codes")
    wDate:=OpenWindow(09,15,14,63,"Date & Airline Code Information Box")
    @ 11,17 say "Enter starting date (MM/DD/YY format)" get dStartDate
    @ 12,17 say "        Ending date (MM/DD/YY format)" get dEndDate
    @ 13,17 say "                         Airline Code" get cAircode pict "@!"
    SetCursor(SC_NORMAL)
    set key K_F1 to Air_Look()
    read
    set key K_F1 to
    SetCursor(SC_NONE)
    CloseWindow(wDate)
    return If(LastKey()==K_ESC,.F.,.T.)

*!*********************************************************************
*!  Function  : Register1()
*!      Notes : MCO/Ticket Registry 1 Printing Routine
*!*********************************************************************
function Register1()
    local nRecNo := RecNo()
    private lFirstPage := lFirstPass := .T. , nPgLines := 0, nA:= nS:= 0
    private nCONJ_cnt := nRTT_cnt := nPTA_cnt := nOEC_cnt := nTEC_cnt := 0
    private aAirline:={},aSeries:={}, aDetails:={}
    if GetDates()
        if isPrinter()
           DbSetOrder(DATE_NDX)
           DbSeek(dtos(dStartDate))
           DbSetOrder(TKT_NDX)
           Message("Insert 132 column paper and press any key when ready...")
           inkey(0)
           Set(_SET_CONSOLE,.f.)
           Set(_SET_PRINTER,.t.)
           do while (!Eof())
              if (Date >= dStartDate) .and. (Date <= dEndDate)
                 Message("Printing Record#"+transform(RecNo(),"9999")+"...")
                 if lFirstPass
                    if lFirstPage
                       R1Header()
                    endif
                    R1DetlHead()
                 endif
                 R1Detail()
                 if nPgLines > 60
                    eject
                    nPgLines := 0
                    lFirstPass := .T.
                 endif
              endif
              DbSkip()
           enddo
           R1Total()
           Set(_SET_PRINTER,.f.)
           Set(_SET_CONSOLE,.t.)
        else
           Message("Printer not Ready...")
           inkey(2)
        endif
    endif
    DbGoto(nRecNo)
    return nil

static function R1Header()
local nDollarRate := 0
    if NetUse("ACR",DB_SHARED,NUM_SECONDS)
       set index to ACR
       ACR->(DbSeek(dStartDate))
       nDollarRate := ACR->AMOUNT
       ACR->(DbCloseArea())
    endif
    Select (cDbf)
    STI_Header(2)
    ?
    ? chr(27) + chr(119)+ chr(1)                     // Double Heigth
    ?? "þBSP Registry Report 1"
    ?? space(90)+"Rate :",transform(nDollarRate,"99.99")
    ?
    ? "Period :",expand(dStartDate),"to",expand(dEndDate)
    ?? space(85) + cTitle
    ? chr(27) + chr(119)+ chr(0)                     // Double Heigth off
    lFirstPage := .F.
    nPgLines := 10
    return nil

static function R1DetlHead()
    ?? chr(15)                                // Condense on
    ?  chr(27)+chr(107)+chr(0)                // Roman Type
    ?? chr(27)+chr(120)+chr(1)                // NLQ on
    ?? if(cDbf=="MCO",space(94)+"ÚÄÄÄÄÄ AirFare ÄÄÄÄÄ¿  ",space(117))
    ?? "ÚÄÄÄ Transmittal ÄÄÄ¿  "
    ?? "ÚÄÄÄ Commission ÄÄÄÄ¿  "
    ?? "ÚÄÄÄ Remittance ÄÄÄÄ¿  "
    ?? "ÚÄÄÄÄÄÄ Tax ÄÄÄÄÄÄÄÄ¿  "
    ?? "ÚÄ Comm/Diff. Due ÄÄ¿"
    ? "Date" + space(9)
    ?? if(cDbf=="MCO"," MCO No.  ","Ticket No.") + space(17)
    ?? "Passenger(s)" + space(24)
    ?? "Route" + if(cDbf=="MCO",space(13),space(36))
    ?? repl("      Peso     Dollar  ",5)
    ?? if(cDbf=="MCO","      Peso     Dollar","")
    ?? chr(27)+chr(120)+chr(0)                // NLQ off
    ?
    lFirstPass := .F.
    nPgLines += 2
    return nil

static function R1Detail()
    /* ----- print first line ----- */
    ?? expand(Date) + space(2)
    if len(alltrim(Ticket_No))==18
       ?? substr(Ticket_No,1,18)
    else
       ?? space(18)
    endif
    ?? space(2) + Passenger + space(2)
    if (cDbf!="MCO")
       cTemp  := alltrim(Route_1) + alltrim(Route_2)
       cTemp1 := padr(substr(ctemp,46),45)
       cTemp  := padr(substr(ctemp,1),45)
    else
       cTemp  := Route_1
       ctemp1 := Route_2
    endif
    ?? cTemp + space(2)
    if (cDbf=="MCO")
       ?? blank_ifzero(Airfare_P,"999,999.99") + space(1)
       ?? blank_ifzero(Airfare_D,"999,999.99") + space(2)
    else
       ?? space(4)
    endif
    ?? blank_ifzero(Transmit_P,"999,999.99") + space(1)
    ?? blank_ifzero(Transmit_D,"999,999.99") + space(2)
    ?? blank_ifzero(if(CRate_P>0,Transmit_P-Remit_P,0),"999,999.99") + space(1)
    ?? blank_ifzero(if(CRate_D>0,Transmit_D-Remit_D,0),"999,999.99") + space(2)
    ?? blank_ifzero(Remit_P,"999,999.99") + space(1)
    ?? blank_ifzero(Remit_D,"999,999.99") + space(2)
    ?? blank_ifzero(Tax_P,"999,999.99") + space(1)
    ?? blank_ifzero(Tax_D,"999,999.99") + space(2)
    ?? blank_ifzero(Acm_P,"999,999.99") + space(1)
    ?? blank_ifzero(Acm_D,"999,999.99")
    ?
    /* ----- print second line ----- */
    ?? space(66) + cTemp1 + space(2)
    if (cDbf=="MCO")
       ?? padl(alltrim(Air_Rmrk),21," ") + space(2)
    else
       ?? space(4)
    endif
    ?? substr(Trans_Rmrk,1,21) + space(25)
    ?? substr(Remit_Rmrk,1,21) + space(2)
    ?? substr(Tax_Rmrk,1,21) + space(2)
    ?? blank_ifzero(Diff_P,"999,999.99") + space(1)
    ?? blank_ifzero(Diff_D,"999,999.99")
    ?
    nPgLines += 2
    /* ----- compute airline totals ----- */
    if !empty(substr(Ticket_No,1,3))
       x:=aScan(aAirline,{ |x| x[1] == substr(Ticket_No,1,3) })
       if (x==0)
          aAdd(aAirline,{substr(Ticket_No,1,3), 0, 0,0, ;
             0,0, 0,0, 0,0, 0,0, 0,0, 0,0})
          nA:=len(aAirline)
       else
          nA:=x
       endif
    endif
    if len(alltrim(Ticket_No,5))!=19
       aAirline[nA][2]  += 1
    endif
    aAirline[nA][3]   += Airfare_P    ;   aAirline[nA][4]  += Airfare_D
    aAirline[nA][5]   += Transmit_P   ;   aAirline[nA][6]  += Transmit_D
    aAirline[nA][7]   += if(CRate_P>0,Transmit_P-Remit_P,0.00)
    aAirline[nA][8]   += if(CRate_D>0,Transmit_D-Remit_D,0.00)
    aAirline[nA][9]   += Remit_P      ;   aAirline[nA][10]  += Remit_D
    aAirline[nA][11]  += Tax_P        ;   aAirline[nA][12]  += Tax_D
    aAirline[nA][13]  += Acm_P        ;   aAirline[nA][14]  += Acm_D
    aAirline[nA][15]  += Diff_P       ;   aAirline[nA][16]  += Diff_D
    /* ----- compute series totals -------*/
    if len(alltrim(Ticket_No,5))!=19
       x:=aScan(aSeries,{ |x| x[1] == substr(Ticket_No,5,8) })
       if (x==0)
          aAdd(aSeries,{substr(Ticket_No,5,8),substr(Ticket_No,5,14);
             ,substr(Ticket_No,5,14),0, 0,0, 0,0, 0,0, 0,0, 0,0, 0,0, 0,0})
          nS:=len(aSeries)
       else
          nS:=x
       endif
    endif
    if len(alltrim(Ticket_No,5))!=19
       if substr(Ticket_No,5,14) < aSeries[nS][2]
          aSeries[nS][2] := substr(Ticket_No,5,14)
       endif
       if substr(Ticket_No,5,14) > aSeries[nS][3]
          aSeries[nS][3] := substr(Ticket_No,5,14)
       endif
       aSeries[nS][4] ++
    endif
    aSeries[nS][5]  += Airfare_P     ;    aSeries[nS][6] +=Airfare_D
    aSeries[nS][7]  += Transmit_P    ;    aSeries[nS][8]  += Transmit_D
    aSeries[nS][9]  += if(CRate_P>0,Transmit_P-Remit_P,0.00)
    aSeries[nS][10] += if(CRate_D>0,Transmit_D-Remit_D,0.00)
    aSeries[nS][11] += Remit_P       ;    aSeries[nS][12] += Remit_D
    aSeries[nS][13] += Tax_P         ;    aSeries[nS][14] += Tax_D
    aSeries[nS][15] += Acm_P         ;    aSeries[nS][16] += Acm_D
    aSeries[nS][17] += Diff_P        ;    aSeries[nS][18] += Diff_D
    /* ----- compute docs totals ------ */
    if at("CONJ",upper(REMIT_RMRK))!=0
       nCONJ_cnt += val(substr(REMIT_RMRK,1,1))
    endif
    if at("OEC",upper(TAX_RMRK))!=0 ; nOEC_cnt++ ; endif
    if at("RTT",upper(TAX_RMRK))!=0 ; nRTT_cnt++ ; endif
    if at("TEC",upper(TAX_RMRK))!=0 ; nTEC_cnt++ ; endif
    if at("PTA",upper(TAX_RMRK))!=0 ; nPTA_cnt++ ; endif
    return nil

static function R1Total()
    ?? repl("-",230)
    /* ----- print airline totals ----- */
    aSort(aAirline,,,{|x,y| x[1] < y[1]})
    ? "Airline Totals :"
    for x:=1 to len(aAirline)
        AIRLINE->(DbSeek(aAirline[x][1]))
        ? space(8)+"("+ AIRLINE->AIR_CODE + ") - " + AIRLINE->AIRLINE
        ?? space(5),transform(aAirline[x][2],"999")
        ?? space(34)
        if (cDbf=="MCO")
           ?? blank_ifzero(aAirline[x][3],"999,999.99") + space(1)
           ?? blank_ifzero(aAirline[x][4],"999,999.99") + space(2)
        else
           ?? space(23)
        endif
        ?? blank_ifzero(aAirline[x][5],"999,999.99") + space(1)
        ?? blank_ifzero(aAirline[x][6],"999,999.99") + space(2)
        ?? blank_ifzero(aAirline[x][7],"999,999.99") + space(1)
        ?? blank_ifzero(aAirline[x][8],"999,999.99") + space(2)
        ?? blank_ifzero(aAirline[x][ 9],"999,999.99") + space(1)
        ?? blank_ifzero(aAirline[x][10],"999,999.99") + space(2)
        ?? blank_ifzero(aAirline[x][11],"999,999.99") + space(1)
        ?? blank_ifzero(aAirline[x][12],"999,999.99") + space(2)
        ?? blank_ifzero(aAirline[x][13],"999,999.99") + space(1)
        ?? blank_ifzero(aAirline[x][14],"999,999.99") + space(2)
        ? space(209) + blank_ifzero(aAirline[x][15],"999,999.99")
        ?? space(1)  + blank_ifzero(aAirline[x][16],"999,999.99")
    next
    ?
    /* ----- print grand totals ----- */
    ? space(8) + "TOTALS  :"
    ?? space(39),transform(aTotal(aAirline,2),"999")
    ?? space(34)
    if (cDbf=="MCO")
       ?? blank_ifzero(aTotal(aAirline,3),"999,999.99") + space(1)
       ?? blank_ifzero(aTotal(aAirline,4),"999,999.99") + space(1)
    else
       ?? space(22)
    endif
    ?? blank_ifzero(aTotal(aAirline,5),"9999,999.99") + space(1)
    ?? blank_ifzero(aTotal(aAirline,6),"999,999.99") + space(2)
    ?? blank_ifzero(aTotal(aAirline,7),"999,999.99") + space(1)
    ?? blank_ifzero(aTotal(aAirline,8),"999,999.99") + space(1)
    ?? blank_ifzero(aTotal(aAirline, 9),"9999,999.99") + space(1)
    ?? blank_ifzero(aTotal(aAirline,10),"999,999.99") + space(2)
    ?? blank_ifzero(aTotal(aAirline,11),"999,999.99") + space(1)
    ?? blank_ifzero(aTotal(aAirline,12),"999,999.99") + space(2)
    ?? blank_ifzero(aTotal(aAirline,13),"999,999.99") + space(1)
    ?? blank_ifzero(aTotal(aAirline,14),"999,999.99") + space(2)
    ? space(209) + blank_ifzero(aTotal(aAirline,15),"999,999.99")
    ?? space(1)  + blank_ifzero(aTotal(aAirline,16),"999,999.99")
    ? repl("-",230)

    /* ----- print grand totals ----- */
    ? "Series Totals : "
    for x:=1 to len(aSeries)
        ? space(8)
        ?? aSeries[x][2] + "  to  " + aSeries[x][3]
        ?? space(15) + transform(aSeries[x][4],"999") + space(34)
        if (cDbf=="MCO")
           ?? blank_ifzero(aSeries[x][5],"999,999.99") + space(1)
           ?? blank_ifzero(aSeries[x][6],"999,999.99") + space(1)
        else
           ?? space(22)
        endif
        ?? blank_ifzero(aSeries[x][7],"9999,999.99") + space(1)
        ?? blank_ifzero(aSeries[x][8],"999,999.99") + space(2)
        ?? blank_ifzero(aSeries[x][ 9],"999,999.99") + space(1)
        ?? blank_ifzero(aSeries[x][10],"999,999.99") + space(1)
        ?? blank_ifzero(aSeries[x][11],"9999,999.99") + space(1)
        ?? blank_ifzero(aSeries[x][12],"999,999.99") + space(2)
        ?? blank_ifzero(aSeries[x][13],"999,999.99") + space(1)
        ?? blank_ifzero(aSeries[x][14],"999,999.99") + space(2)
        ?? blank_ifzero(aSeries[x][15],"999,999.99") + space(1)
        ?? blank_ifzero(aSeries[x][16],"999,999.99") + space(2)
        ? space(209) + blank_ifzero(aSeries[x][17],"999,999.99")
        ?? space(1)  + blank_ifzero(aSeries[x][18],"999,999.99")
    /* ----- print docs totals ----- */
    next
    ? "********************"
    ? "    Conj -> "+transform(nCONJ_cnt,"999")
    ? "    OEC  -> "+transform(nOEC_cnt,"999")
    ? "    RTT  -> "+transform(nRTT_cnt,"999")
    ? "    TEC  -> "+transform(nTEC_cnt,"999")
    ? "    PTA  -> "+transform(nPTA_cnt,"999")
    ? "********************"
    eject
    return nil

*!*********************************************************************
*!  Function  : Register2()
*!      Notes : MCO/Ticket Registry 2 Printing Routine
*!*********************************************************************
function Register2()
    local nRecNo := RecNo()
    private aTotals := aFill(array(6),0)
    private nPgLines := 0, lFirstPage := lFirstPass := .T.
    if GetDates()
        if isPrinter()
           DbSetOrder(DATE_NDX)
           DbSeek(dtos(dStartDate))
           Message("Insert 132 column paper and press any key when ready...")
           inkey(0)
           Set(_SET_CONSOLE,.f.)
           Set(_SET_PRINTER,.t.)
           do while (DATE <= dEndDate) .and. (!Eof())
              Message("Printing Record#"+transform(RecNo(),"9999")+"...")
              if lFirstPass
                 if lFirstPage
                    R2Header()
                 endif
                 R2DetlHead()
              endif
              R2Detail()
              if nPgLines > 60
                 eject
                 nPgLines := 0
                 lFirstPass := .T.
              endif
              DbSkip()
           enddo
           R2Total()
           Set(_SET_PRINTER,.f.)
           Set(_SET_CONSOLE,.t.)
           DbSetOrder(TKT_NDX)
        else
           Message("Printer not Ready...")
           inkey(2)
        endif
    endif
    DbGoto(nRecNo)
    return nil

static function R2Header()
    STI_Header(2)
    ?? chr(27) + chr(119)+ chr(1)           // Double Heigth on
    ?? "þBSP Registry Report 2"
    ?? space(90) + cTitle
    ?
    ? "Period :",expand(dStartDate)," to ",expand(dEndDate)
    ?? chr(27) + chr(119)+ chr(0)           // Double Heigth off
    ?
    lFirstPage := .F.
    nPgLines := 10
    return nil

static function R2DetlHead()
    ?? chr(15)                             // Condense on
    ?? chr(27)+chr(107)+chr(0)             // Roman Type on
    ?? chr(27)+chr(120)+chr(1)             // NLQ on
    ?? space(66)
    ?? "ÚÄÄÄÄÄÄÄÄÄÄÄÄÄ Billings ÄÄÄÄÄÄÄÄÄÄÄÄÄ¿  "
    ?? "ÚÄÄÄÄÄÄÄÄ Official Receipts ÄÄÄÄÄÄÄÄÄ¿  "
    ?? "ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ Refunds ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿"
    ? "Date" + space(9)
    ?? if(Alias()=="MCO"," MCO No.  ","Ticket No.") + space(17)
    ?? "Passenger(s)" + space(14)
    ?? repl("Date     Bill #       Peso      Dollar  ",2)
    ?? "Date     RA#       RN#       ACM#            Peso      Dollar"
    ?? chr(27)+chr(120)+chr(0)              //NLQ off//
    ?
    lFirstPass := .F.
    nPgLines += 2
    return nil

static function R2Detail()
    ??  expand(Date) + space(2)
    ?? if(len(alltrim(Ticket_no))==19,space(18),substr(Ticket_No,1,18))
    ?? space(2) + Passenger + space(2)
    ?? expand(Bill_1Date) + space(2)
    ?? substr(Bill_1No,1,5) + space(2)
    ?? blank_ifzero(Bill_1AmtP,"999,999.99") + space(2)
    ?? blank_ifzero(Bill_1AmtD,"999,999.99") + space(2)
    ?? expand(OR_1Date) + space(2)
    ?? substr(OR_1No,1,5) + space(2)
    ?? blank_ifzero(OR_1AmtP,"999,999.99") + space(2)
    ?? blank_ifzero(OR_1AmtD,"999,999.99") + space(2)
    ?? expand(Date_1Last) + space(2)
    ?? RA_1No + space(2)
    ?? RN_1No + space(2)
    ?? ACM_1No + space(2)
    ?? blank_ifzero(Amt_1P,"999,999.99") + space(2)
    ?? blank_ifzero(Amt_1D,"999,999.99")
    ?
    if !empty(Bill_2Date) .or. !empty(OR_2Date);
       .or. !empty(Date_2Last)
       ??  space(71)
       ?? expand(Bill_2Date) + space(2)
       ?? substr(Bill_2No,1,5) + space(2)
       ?? blank_ifzero(Bill_2AmtP,"999,999.99") + space(2)
       ?? blank_ifzero(Bill_2AmtD,"999,999.99") + space(2)
       ?? expand(OR_2Date) + space(2)
       ?? substr(OR_2No,1,5) + space(2)
       ?? blank_ifzero(OR_2AmtP,"999,999.99") + space(2)
       ?? blank_ifzero(OR_2AmtD,"999,999.99") + space(2)
       ?? expand(Date_2Last) + space(2)
       ?? RA_2No + space(2)
       ?? RN_2No + space(2)
       ?? ACM_2No + space(2)
       ?? blank_ifzero(Amt_2P,"999,999.99") + space(2)
       ?? blank_ifzero(Amt_2D,"999,999.99")
       ?
       nPgLines ++
    endif
    nPgLines ++
    aTotals[1] += BILL_1AMTP  + BILL_2AMTP
    aTotals[2] += BILL_1AMTD  + BILL_2AMTD
    aTotals[3] += OR_1AMTP    + OR_2AMTP
    aTotals[4] += OR_1AMTD    + OR_2AMTD
    aTotals[5] += AMT_1P     + AMT_2P
    aTotals[6] += AMT_2D     + AMT_2D
    return nil

static function R2Total()
    ? repl("=",209)
    ? "Totals" + space(76)
    ?? blank_ifzero(aTotals[1],"999,999.99") + space(2)
    ?? blank_ifzero(aTotals[2],"999,999.99") + space(18)
    ?? blank_ifzero(aTotals[3],"999,999.99") + space(2)
    ?? blank_ifzero(aTotals[4],"999,999.99") + space(41)
    ?? blank_ifzero(aTotals[5],"999,999.99") + space(2)
    ?? blank_ifzero(aTotals[6],"999,999.99")
    eject
    return nil

*!*********************************************************************
*!  Function  : FareDiff()
*!      Notes : MCO/Ticket Fare Difference Printing Routine
*!*********************************************************************
function FareDiff()
    local nRecNo := RecNo()
    private nAcmPeso := nAcmUsd := 0
    private nPgLines := 0, lFirstPage := lFirstPass := .T.
    if GetDates_Air()
        if isPrinter()
           DbSetOrder(DATE_NDX)
           DbSeek(dtos(dStartDate))
           Message("Insert 80 column paper and press any key when ready...")
           inkey(0)
           Set(_SET_CONSOLE,.f.)
           Set(_SET_PRINTER,.t.)
           do while (DATE <= dEndDate) .and. (!Eof())
              Message("Printing Record#"+transform(RecNo(),"9999")+"...")
              if lFirstPass
                 if lFirstPage
                    FDHeader()
                 endif
                 FDDetlHead()
              endif
              FDDetail()
              if nPgLines > 60
                 eject
                 nPgLines := 0
                 lFirstPass := .T.
              endif
              DbSkip()
           enddo
           FDTotal()
           Set(_SET_PRINTER,.f.)
           Set(_SET_CONSOLE,.t.)
           DbSetOrder(TKT_NDX)
        else
           Message("Printer not Ready...")
           inkey(2)
        endif
    endif
    DbGoto(nRecNo)
    return nil

static function FDHeader()
    STI_Header(2)
    ?? chr(27) + chr(119)+ chr(1)           // Double Heigth on
    ?? "þBSP Fare Difference Report"
    ?? space(85) + cTitle
    ?
    ? "Period :",expand(dStartDate)," to ",expand(dEndDate)
    if Airline->(DbSeek(cAirCode))
        ?? space(85) + Airline->Airline
    endif
    ?? chr(27) + chr(119)+ chr(0)           // Double Heigth off
    ?
    lFirstPage := .F.
    nPgLines := 10
    return nil

static function FDDetlHead()
    ?? chr(15)                             // Condense on
    ?? chr(27)+chr(107)+chr(0)             // Roman Type on
    ?? chr(27)+chr(120)+chr(1)             // NLQ on
    ?? PadR("Date",12," ") + PadR("Ticket No",23," ")
    ?? PadR("Passenger(s)",40," ") + PadR("Route",31," ") + space(5)
    ?? PadL("Peso",10," ") + space(5) + PadL("Dollar",10," ")
    ?? chr(27)+chr(120)+chr(0)              //NLQ off//
    ?
    lFirstPass := .F.
    nPgLines += 2
    return nil

static function FDDetail()
    if (cAircode==substr(TICKET_NO,1,3)) .or. empty(cAirCode)
       ?? expand(Date) + space(5)
       ?? Passenger + space(5)
       ?? Route_1 + space(5)
       ?? transform(Acm_D,"999,999.99") + space(5)
       ?? transform(Acm_P,"999,999.99")
       ?
       if !empty(Route_2)
          ?? space(52) + Route_2
          ?
          nPgLines ++
       endif
       nPgLines++
       nAcmPeso += Acm_P
       nAcmUsd  += Acm_D
    endif
    return nil

static function FDTotal()
    ?? repl("-",110)
    ?
    ?? space(83)+transform(nAcmPeso,"999,999.99")
    ?? space(5)+transform(nAcmUsd,"999,999.99")
    eject
    return nil

*:****************** Eof <Reports.Prg> ******************************
