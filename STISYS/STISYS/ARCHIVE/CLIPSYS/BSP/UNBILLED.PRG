// Filename:      UNBILLED.PRG
// System-Name:   Bank Settlement Plan System
// Module:        Printing of Unbilled Tickets
// Author:        Rollie C. Ibarra Jr.
// Date-Started:  Sept 16, 1992
// Last-Update:   Sept 16, 1992

#include "Mode.Ch"
#include "Inkey.Ch"
#include "BSP.Ch"
#include "SetCurs.Ch"
#include "Fileio.ch"

static  nLCount,lPrnt

function Print_Unbilled()
static wUnb,lReady,nKey
local   vPeso := vDollar := 0, lBill := .F.,  cTitle, cTicket := space(18)
    if GetDates_UnB()
        Set(_SET_CONSOLE,.f.)
         lReady:=IsPrinter()
         if cOutput == "Y"
          lPrnt:=.t.
          Set(_SET_PRINTER,.t.)
          Message("Printing Unbilled Reports....")
         do while !lReady .and. (nKey!=K_ESC .or. nKey!=K_ENTER)
         Message("Printer not Ready!!!, Press ENTER to retry ")
         nkey:=inkey(0)
         lReady:=IsPrinter()
         enddo
/************************** TO PRINTER ************************************/
      if (((isPrinter() .and. lPrnt) .or. (!lPrnt)).and. Lastkey()==K_ENTER)
         ?? chr(27) + chr(119)+ chr(1)  // Double Heigth
         ?? "Super Travel, Inc."
         ?
         ? "þBSP Unbilled Report"
         ?
         ? "Period :"+ expand(dStartDate) + " to " + expand(dEndDate)
         ?? chr(27) +chr(119)+ chr(0)    // Double Heigth off
         ?? chr(15)
         nLCount := 4
         for x:=1 to 5
            aDetails:={}
            cDbf:=OpenBSP(x)
            do case
               case x==1 ; cTitle:="MCO's"
               case x==2 ; cTitle:="SERIES 2 Tickets"
               case x==3 ; cTitle:="Series 4 Tickets"
               case x==4 ; cTitle:="APOLLO Tickets"
               case x==5 ; cTitle:="ABACUS Tickets"
            endcase
            Message("Searching "+cTitle+"...")
            (cDbf)->(DbSetOrder(DATE_NDX))
            (cDbf)->(DbSeek(dStartDate))
            do while ((cDbf)->DATE <= dEndDate) ;
                  .and. (cDbf)->(!Eof())
                  if empty( (cDbf)->BILL_1NO + (cDbf)->BILL_2NO + ;
                             (cDbf)->OR_1NO   + (cDbf)->OR_2NO ) .and. ;
                     !("VOID" $ upper((cDbf)->PASSENGER))
                     Message("Printing "+Alias()+" - Rec# "+;
                            transform((cDbf)->(RecNo()),"9999")+"...")
                     if cTicket $ (cDbf)->TICKET_NO
                        aAdd(aDetails,{expand((cDbf)->DATE),;
                            space(18),(cDbf)->PASSENGER,;
                            transform((cDbf)->REMIT_P+;
                            (cDbf)->TAX_P,"999,999.99"),;
                            transform((cDbf)->REMIT_D+;
                            (cDbf)->TAX_D,"999,999.99")})
                     else
                        aAdd(aDetails,{expand((cDbf)->DATE),;
                            substr((cDbf)->TICKET_NO,1,18),(cDbf)->PASSENGER,;
                            transform((cDbf)->REMIT_P+;
                            (cDbf)->TAX_P,"999,999.99"),;
                            transform((cDbf)->REMIT_D+;
                            (cDbf)->TAX_D,"999,999.99")})
                     endif
                     vDollar += (cDbf)->REMIT_D+(cDbf)->TAX_D
                     vPeso += (cDbf)->REMIT_P+(cDbf)->TAX_P
                     cTicket := substr((cDbf)->TICKET_NO,1,18)
                  endif
                  (cDbf)->(DBSkip())
            enddo
            (cDbf)->(DbCloseArea())
            Detail1_Header(ctitle)
            for v:=1 to len(aDetails)
               ? space(15)
               ?? aDetails[v][1]
               ?? space(2)
               ?? aDetails[v][2] + space(2)
               ?? aDetails[v][3] + space(2)
               ?? aDetails[v][4] + space(6)
               ?? aDetails[v][5]
               nLCount ++
               if nLCount > 59
                  eject
                  ?
                  ?
                  nLCount := 2
               endif
           next
           if nLCount + 4 > 59
              eject
              ?
              ?
              nLCount := 2
           endif
         next
         ? space(15)+repl('=',94)
         ? space(79)+transform(vPeso,"9,999,999.99")
         ?? space(4)+transform(vDollar,"9,999,999.99")
      endif
          if Alert("Include Domestic Tickets ? ",{" Yes ","  No  "}) = 1
           Do_UnBDom()
          endif
          Set(_SET_PRINTER,.f.)
          Message("Unbilled Reports Printed....")
          eject
          Tone(300,1)
         else
/************************** TO CONSOLE *************************************/
          lPrnt:=.f.
          Set(_SET_ALTERNATE,.t.)
          Set(_SET_ALTFILE,"Unbld.rpt")
          Set(_SET_PRINTER,.f.)
          Message("Preparing Unbilled Reports....")
         ?? "Super Travel, Inc."
         ? "þBSP Unbilled Report"
         ? "Period :"+ expand(dStartDate) + " to " + expand(dEndDate)
         nLCount := 4
         for x:=1 to 5
            aDetails:={}
            cDbf:=OpenBSP(x)
            do case
               case x==1 ; cTitle:="MCO's"
               case x==2 ; cTitle:="SERIES 2 Tickets"
               case x==3 ; cTitle:="Series 4 Tickets"
               case x==4 ; cTitle:="APOLLO Tickets"
               case x==5 ; cTitle:="ABACUS Tickets"
            endcase
            Message("Searching "+cTitle+"...")
            (cDbf)->(DbSetOrder(DATE_NDX))
            (cDbf)->(DbSeek(dStartDate))
            do while ((cDbf)->DATE <= dEndDate) ;
                  .and. (cDbf)->(!Eof())
                  if empty( (cDbf)->BILL_1NO + (cDbf)->BILL_2NO + ;
                             (cDbf)->OR_1NO   + (cDbf)->OR_2NO ) .and. ;
                     !("VOID" $ upper((cDbf)->PASSENGER))
                     Message("Printing "+Alias()+" - Rec# "+;
                            transform((cDbf)->(RecNo()),"9999")+"...")
                     if cTicket $ (cDbf)->TICKET_NO
                        aAdd(aDetails,{expand((cDbf)->DATE),;
                            (cDbf)->PASSENGER,;
                            transform((cDbf)->REMIT_P+;
                            (cDbf)->TAX_P,"999,999.99"),;
                            transform((cDbf)->REMIT_D+;
                            (cDbf)->TAX_D,"999,999.99")})
                     else
                        aAdd(aDetails,{expand((cDbf)->DATE),;
                            (cDbf)->PASSENGER,;
                            transform((cDbf)->REMIT_P+;
                            (cDbf)->TAX_P,"999,999.99"),;
                            transform((cDbf)->REMIT_D+;
                            (cDbf)->TAX_D,"999,999.99")})
                     endif
                     vDollar += (cDbf)->REMIT_D+(cDbf)->TAX_D
                     vPeso += (cDbf)->REMIT_P+(cDbf)->TAX_P
                     cTicket := substr((cDbf)->TICKET_NO,1,18)
                  endif
                  (cDbf)->(DBSkip())
            enddo
            (cDbf)->(DbCloseArea())
            xDetail1_Header(ctitle)
            for v:=1 to len(aDetails)
               ? space(2)
               ?? aDetails[v][1]
               ?? space(2)
               ?? aDetails[v][2] + space(2)
               ?? aDetails[v][3] + space(3)
               ?? aDetails[v][4]
            next
         next
         ? space(01)+repl('=',72)
         ? space(46)+transform(vPeso,"9,999,999.99")
         ?? space(1)+transform(vDollar,"9,999,999.99")
         ?
          if Alert("Include Domestic Tickets ? ",{" Yes ","  No  "}) = 1
           Do_UnBDom()
          endif
          Set(_SET_ALTFILE,"")
          Set(_SET_ALTERNATE,.f.)
          Close alternate
          cReport:=MEMOREAD("UnBld.Rpt")
          Message("Use CursorKeys to navigate.")
          SetCursor(SC_NORMAL)
          wUnb:=OpenWindow(3,1,22,77,"BSP Unbilled Reports")
          if Mem_chk(cReport)
          MemoEdit(cReport,4,1,21,76,.F.,"EditorFunc",120)
          else
          Message("Sorry not enough Memory to Display Unbilled...")
          Alert("Exit and Use other Dos Editing Programs...")
          endif
          CloseWindow(wUnb)
          SetCursor(SC_NONE)
      endif
          Set(_SET_CONSOLE,.t.)
   endif
return nil

static function Mem_Chk(Param)
param := if(valtype(param)=="C",len(param),param)
return (param < Memory(1)*1024)



static function thud()
tone(100,0.50)
return .f.


*!*********************************************************************
*!  Function  : GetDates()
*!      Notes : Input Window for Date Info.
*!*********************************************************************
function GetDates_UnB()
   local wDate
   dStartDate:=dEndDate:=CToD("  -  -  ")
   cOutput:= "N"
   Message("Enter transaction dates, press Esc to abort.")
   wDate:=OpenWindow(08,15,13,63,"Date Information Box")
   @ 10,17 say "Enter starting date (MM/DD/YY format)" get dStartDate
   @ 11,17 say "        Ending date (MM/DD/YY format)" get dEndDate
   @ 12,17 say " Output report to line printer (Y,N)?" get cOutput picture "Y"
   SetCursor(SC_NORMAL)
   read
   SetCursor(SC_NONE)
   CloseWindow(wDate)
return If(LastKey()==K_ESC,.F.,.T.)

static function Detail1_Header(cTitle)
   ?
   ?? chr(27)+chr(107)+chr(1)     //Roman Type//
   ?? chr(27)+chr(120)+chr(1)     //NLQ on//
   ? space(5)+ctitle
   ? space(15)+" Date  "+space(6)+"Ticket/MCO#"+space(7)
   ?? space(2)+"Passenger(s)"+space(21)+space(2)
   ?? "Peso Amt "+space(5)+"Dollar Amt"
   ?? chr(27)+chr(120)+chr(0)     //NLQ off//
   ?? chr(27)+chr(107)+chr(0)     //Roman Type off//
   nLCount += 4
return nil

static function xDetail1_Header(cTitle)
   ?
   ? space(1)+ctitle
   ? space(03)+" Date  "+space(2)
   ?? space(0)+"Passenger(s)"+space(14)+space(13)
   ?? "Peso Amt "+space(3)+"Dollar Amt"
   nLCount += 4
return nil

function Print_Unpaid()
local vTPesoBal := vTDollBal := vTBillPeso := vTBillDoll := ;
      vTPaidPeso := vTPaidDoll := 0
local cTitle
   if GetDates()
      if isPrinter()
         Set(_SET_CONSOLE,.f.)
         Set(_SET_PRINTER,.t.)
         Message("Printing...")
         Sti_Header(1)
         ? chr(27) + chr(119)+ chr(1)  // Double Heigth
         ?? "þBSP Unpaid Tickets Report"
         ?
         ? "Period :"+substr(expand(dStartDate),1,2)+" ";
                       +substr(expand(dStartDate),3,3)+" ";
                       +substr(expand(dStartDate),6,2)+" to ";
                       +substr(expand(dEndDate),1,2)+" ";
                       +substr(expand(dEndDate),3,3)+" ";
                       +substr(expand(dEndDate),6,2)
         ? chr(27) +chr(119)+ chr(0)    // Double Heigth off
         ? chr(15)
         for x:=1 to 4
            aDetails:={}
            cDbf:=OpenBSP(x)
            do case
               case x==1 ; cTitle:="MCO's"
               case x==2 ; cTitle:="SERIES 2 Tickets"
               case x==3 ; cTitle:="Series 4 Tickets"
               case x==4 ; cTitle:="Automated Tickets"
            endcase
            Message("Searching "+cTitle+"...")
            (cDbf)->(DbSetOrder(DATE_NDX))
            (cDbf)->(DbSeek(dStartDate))
            do while ((cDbf)->DATE <= dEndDate) ;
                  .and. (cDbf)->(!Eof())
                  if ((cDbfname)->BILL_1AMTP + (cDbfname)->BILL_2AMTP > ;
                      (cDbfname)->OR_1AMTP + (cDbfname)->OR_1AMTP      ) .or.;
                     ((cDbfname)->BILL_1AMTD + (cDbfname)->BILL_2AMTD > ;
                      (cDbfname)->OR_1AMTD + (cDbfname)->OR_1AMTD      ) .and.;
                      (at("VOID",PASSENGER)==0)
                     vPesoBal :=( (cDbfname)->BILL_1AMTP+(cDbfname)->BILL_2AMTP;
                                 -(cDbfname)->OR_1AMTP+(cDbfname)->OR_2AMTP)
                     vDollBal :=( (cDbfname)->BILL_1AMTD+(cDbfname)->BILL_2AMTD;
                                 -(cDbfname)->OR_1AMTD+(cDbfname)->OR_2AMTD)
                     aAdd(aDetails,{(cDbf)->DATE,(cDbf)->TICKET_NO,;
                         (cDbf)->PASSENGER,;
                         (cDbf)->BILL_1AMTP+(cDbf)->BILL_2AMTP,;
                         (cDbf)->BILL_1AMTD+(cDbf)->BILL_2AMTD,;
                         (cDbf)->OR_1AMTP+(cDbf)->OR_2AMTP,;
                         (cDbf)->OR_1AMTD+(cDbf)->OR_2AMTD,;
                         vPesoBal,vDollBal})
                     vTBillPeso+=(cDbf)->BILL_1AMTP+(cDbf)->BILL_2AMTP
                     vTBillDoll+=(cDbf)->BILL_1AMTD+(cDbf)->BILL_2AMTD
                     vTPaidPeso+=(cDbf)->OR_1AMTP+(cDbf)->OR_2AMTP
                     vTPaidDoll+=(cDbf)->OR_1AMTD+(cDbf)->OR_2AMTD
                     vTPesoBal += vPesoBal
                     vTDollBal += vDollBal
                  endif
                  (cDbfname)->(DbSkip())
            enddo
            (cDbf)->(DbCloseArea())
*            if (x!=1)
*                aSort(aDetails,,,{|x, y| substr(x[2],5) < substr(y[2],5) })
*            endif
            Detail2_Header(ctitle)
            for v:=1 to len(aDetails)
               ? space(15)
               ?? expand(aDetails[v][1]) + space(2)
               ?? aDetails[v][2] + space(2)
               ?? aDetails[v][3] + space(2)
               ?? blank_ifzero(aDetails[v][4],"9,999,999.99") + space(2)
               ?? blank_ifzero(aDetails[v][5],"9,999,999.99") + space(5)
               ?? blank_ifzero(aDetails[v][6],"9,999,999.99") + space(2)
               ?? blank_ifzero(aDetails[v][7],"9,999,999.99") + space(5)
               ?? blank_ifzero(aDetails[v][8],"9,999,999.99") + space(2)
               ?? blank_ifzero(aDetails[v][9],"9,999,999.99") + space(2)
           next
         next
         ? space(15)+repl('=',163)
         ? space(80) + blank_ifzero(vTBillPeso,"99,999,999.99")
         ?? space(1) + blank_ifzero(vTBillDoll,"99,999,999.99")
         ?? space(4) + blank_ifzero(vTPaidDoll,"99,999,999.99")
         ?? space(1) + blank_ifzero(vTPaidDoll,"99,999,999.99")
         ?? space(4) + blank_ifzero(vTPesoBal,"99,999,999.99")
         ?? space(1) + blank_ifzero(vTDollBal,"99,999,999.99")
         eject
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

static function Detail2_Header(cTitle)
   ?
   ?
   ?? chr(27)+chr(107)+chr(1)     //Roman Type//
   ?? chr(27)+chr(120)+chr(1)     //NLQ on//
   ? space(5)+ctitle
   ? space(81) + "ÚÄÄÄÄ Billed Amount ÄÄÄÄÄ¿" + space(5)
   ?? "ÚÄÄÄÄÄ Paid Amount ÄÄÄÄÄÄ¿" + space(5)
   ?? "ÚÄÄÄÄÄÄÄ Balance ÄÄÄÄÄÄÄÄ¿"
   ? space(15) + "Date   " + space(2) + "Ticket/MCO#" + space(7)
   ?? space(2) + "Passenger(s)" +space(25)
   ?? repl("        Peso        Dollar" + space(5),3)
   ?? chr(27)+chr(120)+chr(0)     //NLQ off//
   ?? chr(27)+chr(107)+chr(0)     //Roman Type off//
return nil

function UpdateBills()
local wUpdate, aCheck := aFill(array(7),.F.)
local aCodes := {"STD_M#", "STD_2#", "STD_4#", "STD_P#", "STD_B#"}
local aDbfs := {"MCO", "SERIES2", "SERIES4", "APOLLO", "ABACUS"}
local aBooks := {"CRB", "SB"}
    if GetDates()
        wUpdate:=OpenWindow(07,25,18,55,"Update Bills")
        @ 08, 27 say "MCO/Tickets"
        @ 09, 27 say "   Misc. Charge Order" get aCheck[1] pict 'Y'
        @ 10, 27 say "             Series 2" get aCheck[2] pict 'Y'
        @ 11, 27 say "             Series 4" get aCheck[3] pict 'Y'
        @ 12, 27 say "         Optat Apollo" get aCheck[4] pict 'Y'
        @ 13, 27 say "         Optat Abacus" get aCheck[5] pict 'Y'
        @ 15, 27 say "Books"
        @ 16, 27 say "   Cash Receipts Book" get aCheck[6] pict 'Y'
        @ 17, 27 say "           Sales Book" get aCheck[7] pict 'Y'
        SetCursor(SC_NORMAL)
        read
        SetCursor(SC_NONE)
        CloseWindow(wUpdate)
        for x:=1 to 5
            cDbf:=OpenBSP(x)
            (cDbf)->(DbSetOrder(TKT_NDX))
        next
        for x:= 6 to 7
        if aCheck[x]
            if netuse(aBooks[x-5],DB_SHARED,NUM_SECONDS)
                 set index to (aBooks[x-5]+"_DATE")
            endif
            CRB->(DbSeek( substr(dtoc(dStartDate),7,2) + '-' + ;
                          substr(dtoc(dStartDate),1,2) + '-' + ;
                          substr(dtoc(dStartDate),4,2)  ))
            do while CRB->(!Eof()) .and. (ctod(CRB->DATE) <= dEndDate)
                for n:=1 to 5
                    if (aCodes[n] $ upper(CRB->DETAILS_1+CRB->DETAILS_2)) ;
                        .and. aCheck[n]
                       z:=at(aCodes[n],upper(CRB->DETAILS_1+CRB->DETAILS_2)) + 6
                       cTicket := substr(CRB->DETAILS_1+CRB->DETAILS_2,z,14)
                       if (aDbfs[n])->(DbSeek(cTicket))
                          (aDbfs[n])->(RecLock(0))
                          if empty((aDbfs[n])->OR_1DATE)
                              replace (aDbfs[n])->OR_1DATE with CTOD(CRB->DATE)
                              replace (aDbfs[n])->OR_1NO with CRB->VOUCHER_NO
                          elseif empty((aDbfs[n])->OR_2DATE)
                              replace (aDbfs[n])->OR_2DATE with CTOD(CRB->DATE)
                              replace (aDbfs[n])->OR_2NO with CRB->VOUCHER_NO
                          endif
                         (aDbfs[n])->(DbUnlock())
                      endif
                    endif               //
                next
                CRB->(DbSkip())
            enddo
        endif                       // aCheck[x]
        next
    endif
return nil

static function EditorFunc(nMode,nLine,nCol)
memvar initRow,initCol,initRelRow,initRelCol
local nRetVal,lKey,nKey,isReady,nLines,nCurrLine,n,nLineCtr:=0
   initRow:=nLine ; initCol:=nCol ; initRelRow:=Row()-1 ; initRelCol:=Col()-1
   if nMode==ME_IDLE
      SetCursor(SC_NONE)
      cColor:=SetColor("N/BG")
      @ 03,55 say "Line"+Transform(nLine,"9999")+"  Col"+;
        Transform(nCol+1,"9999")
      SetColor(cColor)
      SetCursor(SC_NORMAL)
   else
      lKey:=LastKey()
      do case
         case lKey==K_F10
            Message("Press ENTER to print report, ESC to abort....")
            nKey:=0
            do while (nKey!=K_ENTER) .and. (nKey!=K_ESC)
               nKey:=Inkey(0)
            enddo
            if nKey=K_ENTER
               isReady:=.F.
               do while (nKey!=K_ESC) .and. (!isReady)
                  isReady:=IsPrinter()
                  if isReady
                     Message("Insert 80 column form then press "+;
                        "ENTER to print.")
                     nKey:=0
                     do while nKey!=K_ENTER ; nKey:=Inkey(0) ; enddo
                     nLineCtr:=0
                     Message("Printing....please wait!")
                     Set(_SET_CONSOLE,.F.)
                     Set(_SET_PRINTER,.T.)
                     nLines:=MLCount(cReport,110)
                     ?? chr(27) + chr(120) + chr(1)   // select NLQ
                     ?? chr(27) + chr(107) + chr(0)   // select Roman
                     ?? chr(27) + chr(119) + chr(1)   // turn on Double heigth
                     for nCurrLine:=2 to 4
                        cLine:=MemoLine(cReport,110,nCurrLine)
                        ? cLine
                        ?
                     next
                     ?? chr(27) + chr(119) + chr(0)   // turn off Double heigth
                     for nCurrLine:=5 to nLines
                        cLine:=MemoLine(cReport,110,nCurrLine)
                        if nLineCtr>50
                           eject
                           nLineCtr:=0
                        endif
                        ? cLine
                        nLineCtr++
                     next
                     eject
                     Set(_SET_CONSOLE,.T.)
                     Set(_SET_PRINTER,.F.)
                     Set(_SET_ALTFILE,"")
                     Set(_SET_ALTERNATE,.F.)
                     close alternate
                  else
                     Message("Printer not ready....")
                     Tone(100,3)
                     Inkey(2)
                     Message("Press any key to retry, Esc to abort....")
                     nKey:=Inkey(0)
                     Message("")
                  endif
               enddo
            endif
            Message("Use cursor keys to navigate, press F10 to print, "+ ;
               "Esc to abort.")
         otherwise
            nRetVal:=ME_DEFAULT
      endcase
   endif
return nRetVal

function  Print()
vPeso:=0
cTicket:= space(18)
   aDetails:= {}
   Message("Searching Unbilled Domestic Tickets...")
   UNBDOM->(DbSeek(dStartDate))
   do while (UNBDOM->DATE <= dEndDate) .and. UNBDOM->(!Eof())
      Message("Printing "+Alias()+" - Rec# "+;
      transform(UNBDOM->(RecNo()),"9999")+"...")
      if cTicket $ UNBDOM->TICKET_NO
         aAdd(aDetails,{expand(UNBDOM->DATE),;
              space(18),UNBDOM->PASSENGER,;
              transform(UNBDOM->REMIT_P,"999,999.99")})
      else
              aAdd(aDetails,{expand(UNBDOM->DATE),;
              substr(UNBDOM->TICKET_NO,1,18),UNBDOM->PASSENGER,;
              transform(UNBDOM->REMIT_P,"999,999.99")})
      endif
      vPeso += UNBDOM->REMIT_P
      cTicket := substr(UNBDOM->TICKET_NO,1,18)
      UNBDOM->(DBSkip())
   enddo
   if lPrnt
      Detail1_Header("PR Domestic Tickets")
   else
      xDetail1_Header("PR Domestic Tickets")
   endif
   for v:=1 to len(aDetails)
      ? space(2)
      if lPrnt; ?? space(13) ;endif
      ?? aDetails[v][1] + space(2)
      if lPrnt; ?? aDetails[v][2] + space(2) ; endif
      ?? aDetails[v][3] + space(2)
      ?? aDetails[v][4] + space(3)
      if lPrnt; ?? space(3) ; endif
      ?? transform(0,"999,999.00")
      nLCount ++
      if (nLCount > 59 ) .and. lPrnt
         eject
         ?
         ?
         nLCount := 2
      endif
   next
   if (nLCount + 4 > 59) .and. lPrnt
      eject
      ?
      ?
      nLCount := 2
   endif
   ? space(1)
   if lPrnt
      ?? space(14)+repl('=',94)
      ? space(79)
   else
      ?? repl("=",72)
      ? space(46)
   endif
   ?? transform(vPeso,"9,999,999.99") +space(1)
   if lPrnt ; ?? space(3) ; endif
   ?? transform(0,"9,999,999.99")
   Message("Unbilled Domestic Reports Printed....")
   if lPrnt; eject; endif
   Tone(300,1)
return nLCount

// <EOF> - UNBILLED