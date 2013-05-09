*:*************************************************************************
*: Procedure Filename: REPORT.PRG
*: System-Name: PR-Domestic ticketing system
*: Modules :
*:         : REFUNDS_REP()
*:         : REMITTANCE()
*:
*: Author:        Rollie Ibarra Jr.
*: Date-Started:  5:05:04  12/8/1993
*: Last-Update:   5:05:11  12/8/1993
*:

#include "Mode.ch"
#include "Setcurs.ch"
#include "Inkey.ch"
#include "Printer.ch"
#include "cl501_60.ch"

#define OFFS   space(5)
#define LM     "  º"
#define LINE   " ³ "
#define DLINE  " º "



function Refunds_Rep()
local nkey,nRecNo := RecNo()
local cRefunds, isReady
private sRepNo,mDate,nLineCtr
private aGndTotal := {0,0,0,0,0,0,0,0}
   nPgNo:=1
   nTotPg:=0
   mName1:="Azucena Grijaldo"
   mPos1:= "Accountant      "
   mName2:="Elizabeth Mojico"
   mPos2:= "Bookkeeper      "
   Message("Enter necessary information...")
   if GetDates(3)
      Message("Preparing PR Refunds report...")
      set(_SET_CONSOLE,.F.)
      set(_SET_ALTFILE,"REFUNDS.RPT")
      set(_SET_ALTERNATE,.T.)
      if NETUSE("REFUND.DBF",DB_SHARED,NUM_SECONDS)
         Set index to REFUND
      endif
     do while (!Eof())
        if (Date >= dStartDate) .and. (Date <= dEndDate) .and. (!Deleted())
         Message("Preparing Record#"+transform(RecNo(),"9999")+"...")
           ?  OFFS,substr(REF_TICK,1,16) + space(1)
           ?? Padc(alltrim(CPN_NO),7) + space(1)
           ?? blank_ifzero(REF_AMT,   "99,999.99") + space(1)
           ?? blank_ifzero(REF_ASF,      "999.99") + space(1)
           ?? blank_ifzero(REF_TFEE,     "999.99") + space(1)
           ?? blank_ifzero(REF_SCHG,   "9,999.99") + space(1)
           ?? blank_ifzero(REF_NSC,    "9,999.99") + space(1)
           ?? blank_ifzero(REF_COMM,   "9,999.99") + space(1)
           ?? blank_ifzero(REF_NET,   "99,999.99") + space(1)
           ?
         /* ----- compute totals -------*/
         aGndTotal[1] ++
         aGndTotal[2] += REF_AMT
         aGndTotal[3] += REF_ASF
         aGndTotal[4] += REF_TFEE
         aGndtotal[5] += REF_SCHG
         aGndtotal[6] += REF_NSC
         aGndtotal[7] += REF_COMM
         aGndtotal[8] += REF_NET
       endif
         REFUND->(DBSkip())
     enddo
     REFUND->(DBCloseArea())
   set(_SET_ALTERNATE,.F.)
   set(_SET_ALTFILE,"")
   set(_SET_CONSOLE,.T.)
   close alternate
   cRefunds := MemoRead("REFUNDS.RPT")
   isReady:=IsPrinter()
   nCurrLine:= 0
   do while (nKey!=K_ESC) .and. (!isReady)
        Message("Printer not ready....")
        ErrorSound()
        Inkey(2)
        Message("Press any key to retry, Esc to abort....")
        nKey:=Inkey(0)
        isReady:=IsPrinter()
   enddo
   if isReady
      Tone(440,1);Tone(440,1)
      Message("Insert 80 column form then press ENTER to print.")
      nKey:=0
      do while nKey!=K_ENTER ; nKey:=Inkey(0) ; enddo
      Tone(880,1);Tone(880,1)
      nLineCtr:=0
      Message("Printing....please wait!")
      nLines:=MLCount(cRefunds,140)
      if nTotPg = 0
         nTotPg:=(nLines+22)            //if 21 is not right try 19
         nTotPg+=((int(nTotPg/81) + if(nTotPg%81 > 0,1,0)) * 7)
         nTotPg:=(int(nTotPg/81) + if((nTotPg%81)>0,1,0) )
      endif
      Set(_SET_CONSOLE,.F.)
      Set(_SET_PRINTER,.T.)
      DomHeader(2)
      DetlHead()
      for nCurrLine:=1 to nLines
          cLine:=MemoLine(cRefunds,140,nCurrLine)
          if nLineCtr>81
             eject
             nLineCtr:=5
             nPgno ++
             ??  chr(18)+chr(27)+chr(77)
             ??  space(87) + "Page "
             ??  transform(nPgNo,"9") + " of " +;
                 transform(nTotPg,"@B 9")
             ?  chr(15)+chr(27)+chr(80)
             DetlHead()
             ?
          endif
          ? cLine
          Message("Printing Line " + transform(nLineCtr,"99") +;
                  " of Page " + transform(nPgNo,"99") )
          nLineCtr++
      next
      if (nLineCtr + 06 ) > 82
          eject
          nPgno ++
          ??  chr(18)+chr(27)+chr(77)
          ?? space(87) + "Page "
          ?? transform(nPgno,"9") + " of " + transform(nTotPg,"@B 9")
          ??  chr(15)+chr(27)+chr(80)
      endif
      RefTotal()
      ?? chr(27)+chr(77)
      if (nLineCtr + 08 ) > 82
          eject
          nPgno ++
          ?? space(87) + "Page "
          ?? transform(nPgno,"9") + " of " + transform(nTotPg,"@B 9")
      endif
      Names()
      eject
      Set(_SET_CONSOLE,.T.)
      Set(_SET_PRINTER,.F.)
      PopSound()
      Alert("Domestic Refunds Report done...")
      unPopSound()
    else
      Message("Printing Aborted...")
      inkey(2)
    endif
 endif
       DbGoto(nRecNo)
return nil

function DomHeader(indx)
    ?   chr(18) + chr(27) + chr(77)                    // select 10 pitch & normal size
    ??  chr(27) + chr(120) + chr(1)                    //NLQ on
    ??  chr(27) + chr(107) + chr(0)                    // Select Roman
    ??  space(87) + "Page "
    ??  transform(nPgNo,"9") + " of " + transform(nTotPg,"@B 9")
    ?   chr(27) + chr(119)+ chr(1)                     // Double Heigth
    ??  "þPhilippine Airlines"
    ??  chr(27) + chr(87) + chr(1)                     // Double Width on
    ??  chr(27) + chr(71)                              // Doub X
    do case
       case indx = 1
       ??  space(10) + "SALES REPORT"
       case indx = 2
       ??  space(09) + "REFUNDS REPORT"
       case indx = 3
       ??  space(07) + "REMITTANCE REPORT"
    endcase
    ??  chr(27) + chr(72)                              // Doub X off
    ??  chr(27) + chr(87) + chr(0)                     // Double Width off
    ??  chr(27) + chr(119)+ chr(0)                     // Double Heigth off
    ? if(indx=3,space(38),space(39))
    ??  "Period: " + expand(dStartDate) + " to " + expand(dEndDate)
    ?  chr(27) + chr(119)+ chr(1)                     // Double Height on
    ?? " AGENT/CODE: "
    ?? "SUPER TRAVEL, INC./ YEE"
    do case
       case indx = 1
       ?? space(38) + "SALES REPORT NO: "
       case indx = 2
       ?? space(36) + "REFUNDS REPORT NO: "
       case indx = 3
       ?? space(33) + "REMITTANCE REPORT NO: "
    endcase
    ?? SRepNo
    ?? chr(27) + chr(119)+ chr(0)                     // Double Height off
    do case
       case indx = 1
       ?  space(74)+"Date Prepared" + space(2) + ": "
       case indx = 2
       ?  space(72)+"Date Prepared" + space(4) + ": "
       case indx = 3
       ?  space(69)+"Date Prepared" + space(7) + ": "
    endcase
    ?? expand(mDate)
    ??  chr(27) + chr(120) + chr(0)                    //NLQ off
    ??  chr(27) + chr(80)                               // 10 cpi
    ?
    nLineCtr := 10  //
return nil

static function DetlHead()
    ?? chr(27) + chr(50)                   //Line spacing
    ?? chr(27) + chr(120) + chr(1)        //NLQ
    ?? chr(18) + chr(27) + chr(77)
    ?? space(1) + repl("-",97)
    ?
    ?  OFFS,space(25) + "Refndble." + space(1) + "ÚÄÄÄ Tax ÄÄÄÄ¿"
    ?? space(0) + "   Rfnd." + space(1) + " No Show" + space(10) + "Net Rfndble"
    ?  OFFS,"Ticket/MCO No.  " + space(1) + "Cpn.No."
    ?? space(01) + "   Amt.  " + space(01) + "   ASF"
    ?? space(01) + " T-Fee"  + space(01) + "   Schg." + space(01) + "   Schg."
    ?? space(01) + "   Comm." + space(02) + "  Amount "
    ? space(1) + repl("-",97)
    ?? chr(27) + chr(48)                  //Line spacing
    lFirstPass := .F.
    nLineCtr += 5
return nil

static function RefTotal()
    ?  chr(27) + chr(50)
    ?? space(1) + repl("=",97)
    /* ----- print grand totals ----- */
    ?
    ? OFFS,"Totals :" + space(16)
    ?? space(01) + transform(aGndTotal[2],"99,999.99")
    ?? space(01) + transform(aGndTotal[3],   "999.99")
    ?? space(01) + transform(aGndTotal[4],   "999.99")
    ?? space(01) + transform(aGndTotal[5], "9,999.99")
    ?? space(01) + transform(aGndTotal[6], "9,999.99")
    ?? space(01) + transform(aGndTotal[7], "9,999.99")
    ?? space(01) + transform(aGndTotal[8],"99,999.99")
    ?
    ? space(1)+repl("-",97)
    ? chr(18)+chr(27)+chr(77)   //! On Condense Mode
   ??  chr(27) + chr(120) + chr(1)                    //NLQ on
    nLineCtr+=7
return nil

function GetDates(indx)   // if 1 con if 2 print if 3no notes
   local wDate
   mDate:=Date()
   SRepNo:=space(8)
   dStartDate:=dEndDate:=CToD("  -  -  ")
   Message("Enter transaction dates, press Esc to abort.")
   wDate:=OpenWindow(08,15,if(indx=1,12,14),63,"Date Information Box")
   @ 10,17 say "Enter starting date (MM/DD/YY format)" get dStartDate
   @ 11,17 say "        Ending date (MM/DD/YY format)" get dEndDate
   if indx!=1
   @ 12,17 say "                           Report No." get SRepNo pict "@!"
   @ 13,17 say "                       Date Prepared:" get mDate
   endif
   SetCursor(1) //SC_NORMAL)
   read
   nretval:=lastkey()
   if lastkey() != K_ESC .and. (indx!=1)
    Others(indx)
   endif
   SetCursor(0) //SC_NONE)
   CloseWindow(wDate)
return If(nRetVal==K_ESC,.F.,.T.)

function Remittance()
local nkey,nRecNo := RecNo()
local cRefunds, isReady
private sRepNo,mDate,nLineCtr
private aTotal :={0,0, 0,0, 0,0,}
   nPgNo:=1
   nTotPg:=1
   nLineCtr:=0
   mName1:="Azucena Grijaldo"
   mPos1:= "Accountant      "
   mName2:="Elizabeth Mojico"
   mPos2:= "Bookkeeper      "
   Message("Enter necessary information...")
   if GetDates(3)
      Message("Preparing PR Refunds report...")
      isReady:=IsPrinter()
      nCurrLine:= 0
      do while (nKey!=K_ESC) .and. (!isReady)
        Message("Printer not ready....")
        ErrorSound()
        Inkey(2)
        Message("Press any key to retry, Esc to abort....")
        nKey:=Inkey(0)
        isReady:=IsPrinter()
      enddo
    if isReady
      Tone(440,1);Tone(440,1)
      Message("Insert 80 column form then press ENTER to print.")
      Set(_SET_CONSOLE,.f.)
      Set(_SET_PRINTER,.t.)
      if NetUse("MEMO",DB_SHARED,NUM_SECONDS)
         Set index to MEMO
      endif
      if NetUse("MISC",DB_SHARED,NUM_SECONDS)
         Set index to MISC
      endif
      nKey:=0
      do while nKey!=K_ENTER ; nKey:=Inkey(0) ; enddo
      Tone(880,1);Tone(880,1)
      Message("Printing please wait...!")
      DomHeader(3)
      RemitHeader()
      do while (!MISC->(Eof())) .or. (!MEMO->(Eof()))
        if nLineCtr > 55
           nLinectr:=2
           eject
           RemitHeader()
        endif
           ? LM,space(10) + LINE + space(09) + LINE
           ?? space(7)  + LINE
           ?? space(10) + LINE
           ?? space(09) + LINE
           ?? space(7)  + LINE
           ?? space(10) + LINE
           ?? space(09) + DLINE
        do while !(MISC->(eof()))
          if (MISC->Date >= dStartDate) .and. (MISC->Date <= dEndDate) .and. ;
                 (!MISC->(Deleted()))
             exit
          endif
          MISC->(DbSkip())
        enddo
        if !MISC->(eof())
           ?  LM,MISC->PARTICULAR + LINE
           ?? blank_ifzero(MISC->AMOUNT,"99,999.99") + LINE
           aTotal[1]++
           aTotal[2]+=MISC->AMOUNT
        else
           ? LM,space(10) + LINE + space(09) + LINE
        endif
        do while !(MEMO->(eof()))
           if (MEMO->Date >= dStartDate) .and. (MEMO->Date <= dEndDate) .and. ;
                 (!MEMO->(Deleted()))
             exit
           endif
           MEMO->(DbSkip())
        enddo
        if !MEMO->(eof())
           if ("CM" $ MEMO->FOLIO) .OR. ("RN" $ MEMO->FOLIO)
              ?? space(7)  + LINE
              ?? space(10) + LINE
              ?? space(09) + LINE
              ?? expand(MEMO->DATE)   + LINE
              ?? MEMO->FOLIO          + LINE
              ?? blank_ifzero(MEMO->AMOUNT,"99,999.99") + DLINE
              aTotal[5]++
              aTotal[6]+=MEMO->AMOUNT
           else
              ?? expand(MEMO->DATE)   + LINE
              ?? MEMO->FOLIO          + LINE
              ?? blank_ifzero(MEMO->AMOUNT,"99,999.99") + LINE
              ?? space(7)  + LINE
              ?? space(10) + LINE
              ?? space(09) + DLINE
              aTotal[3]++
              aTotal[4]+=MEMO->AMOUNT
           endif
        else
              ?? space(7)  + LINE
              ?? space(10) + LINE
              ?? space(09) + LINE
              ?? space(7)  + LINE
              ?? space(10) + LINE
              ?? space(09) + DLINE
        endif
        MEMO->(DbSkip())
        MISC->(DbSkip())
        nLineCtr++
      enddo
      MISC->(DBCloseArea())
      MEMO->(DBCloseArea())
     /* ----- print grand totals ----- */
     ? space(2) + "Ç" + repl("Ä",12) + "Å" + repl("Ä",11) + "Å"
     ?? repl("Ä",9) + "Å" + repl("Ä",12) + "Å" + repl("Ä",11)+"Å"
     ?? repl("Ä",9) + "Å" + repl("Ä",12) + "Å" + repl("Ä",11) + "¶"
     ? LM, "Total :   " + LINE
     ?? transform(aTotal[2],"99,999.99") + LINE
     ?? space(07) + LINE + "Total :   "  + LINE
     ?? transform(aTotal[4],"99,999.99") + LINE
     ?? space(07) + LINE + "Total :   "  + LINE
     ?? transform(aTotal[6],"99,999.99") + DLINE
     ? space(2) + "Ì" + repl("Í",12) + "Ï" + repl("Í",11) + "Ï"
     ?? repl("Í",9) + "Ï" + repl("Í",12) + "Ï" + repl("Í",04)+"Ñ"+repl("Í",06)+  "Ï"
     ?? repl("Í",9) + "Ï" + repl("Í",12) + "Ï" + repl("Í",11) + "¹"

     nLineCtr+=4
     if nLineCtr + 12 >60
        eject
        ?
        ?
     endif
     Summary()
     ?
     ?
     ? space(3)+"Prepared by:"+PrtUnderline(padc(mName2,18,"_"),18)+;
      " Certified by:" + PrtUnderline(padC(mName1,18,"_"),18) +;
      " Remittance Report No:" + PrtUnderline(padc(SRepNo,8,"_"),8)
     ??  chr(27)+chr(83)+chr(0)                         //SuperScript
     ?? chr(27)+chr(48)
     ?  chr(27)+chr(50)
     ?? space(18) + padc(mPos2,18) + space(14) +padc(mPos1,18)
     ?? chr(27)+chr(84)
     ?
     eject
     Set(_SET_PRINTER,.f.)
     Set(_SET_CONSOLE,.t.)
     PopSound()
     Alert("PR-Domestic Remittance Report done...")
     UnPopSound()
    else
     Message("Printing aborted...")
     BUMMER()
    endif
   endif
return nil

static function Summary()
 ? LM+space(51)+LINE+space(39)+DLINE
 ? LM,padc("SUMMARY",50) + LINE + padc("FOR CASHIER'S USE ONLY",39) +DLINE
 ? "  ÇÄ"+repl("Ä",51)+"Å"+ repl("Ä",41) + "¶"
 ? LM," Cash Due : Automated SR        " +space(18) + LINE
 ?? " O.R. No." + space(11) + "Date " + space(14) + DLINE
 nSrTotal:=compSr()
 ? LM,"            Manual SR                  "        +transform(nSrTotal, "999,999.99") + " " + LINE
 ?? " Amount  PHP" +space(27) + DLINE
 ? "  ÇÄ"+repl("Ä",33) + "Â" +repl("Ä",17)+"Å"+ repl("Ä",41) + "¶"
 ? LM," Total Cash Due                 "+ LINE +"PHP " +transform(nSrTotal, "999,999.99") + " " + LINE + space(39)+DLINE
 ? "  ÇÄ"+repl("Ä",33) + "Å" +repl("Ä",17)+"´"
 ?? "  Prepared by :"+PrtUnderline(space(23),23) + space(2) + DLINE
 ? LM," Add :Miscellaneous Collections "+ LINE +"    " +transform(aTotal[2],"999,999.99") + " " + LINE
 ?? chr(27)+chr(83)+chr(0)
 ?? "               Name & Position Title"
 ?? chr(27)+chr(84) + space(03) + DLINE
 ? LM,"      Debit Memos               "+ LINE +"    " +transform(aTotal[4],"999,999.99") + " " + LINE + space(39)+DLINE
 ? LM,"                                "+ LINE + space(14)                  + " " + LINE
 ?? " Approved by :"+PrtUnderline(space(23),23) + space(2) + DLINE
 nRefTotal:=compRef()
 ? LM," Less:Refunds                   "+ LINE +"    " +transform(nRefTotal,"999,999.99") + " " + LINE
 ?? chr(27)+chr(83)+chr(0)
 ?? "               Name & Position Title"
 ?? chr(27)+chr(84) + space(03) + DLINE
 ? LM,"      Credit Memos              "+ LINE +"    " +transform(aTotal[6],"999,999.99") + " " + LINE + space(39) + DLINE
 nDuePal:= nSrTotal + ((aTotal[2]+aTotal[4])-(nRefTotal+aTotal[6]))
 ? "  ÇÄ"+repl("Ä",33)+ "Å" + repl("Ä",17) + "´" +space(40) + DLINE
 ? LM," REMITTANCE DUE PAL             "+ LINE +"PHP " +transform(nDuePal,"999,999.99")   + " " + LINE + space(39) + DLINE
 ? "  ÇÄ"+repl("Ä",33)+ "Á" + repl("Ä",17) + "Á" +repl("Ä",41) + "¶"
 ? LM, "Distribution: Copy 1 - DPRAD  Copy 2 - CCD  Copy -Agent " + space(36) +DLINE
 ? "  È"+repl("Í",94) + "¼"
return nil

static function RemitHeader()
    ?? chr(27) + chr(50)                   //Line spacing
    ?? chr(27) + chr(120) + chr(1)        //NLQ
    ?? chr(18) + chr(27) + chr(77)
    ?? space(2)+chr(201)+repl("Í",24) +"Ñ"+ repl("Í",34) +"Ñ"+repl("Í",34) +chr(187)
    ?  LM,padc("Misc. Collections",22)  +LINE+padc("Debit Memos",32)+LINE+padc("Credit Memos",32)+DLINE
    ? space(2) +"Ç"+repl("Ä",12)+"Â"+repl("Ä",11) +"Å"
    ?? repl("Ä",9)+"Â"+repl("Ä",12)+"Â"+repl("Ä",11) +"Å"
    ?? repl("Ä",9)+"Â"+repl("Ä",12)+"Â"+repl("Ä",11) +"¶"
    ?  LM,"Particulars" + chr(179) +space(1) + "  Amount " + LINE
    ?? " Date  " + LINE + padc("DM No.",10) +LINE+ "  Amount " + LINE
    ?? " Date  " + LINE + padc("CM No.",10) +LINE+ "  Amount " + DLINE
    ? space(2) +"Ç"+repl("Ä",12)+chr(197)+repl("Ä",11) +chr(197)
    ?? repl("Ä",9)+chr(197)+repl("Ä",12)+chr(197)+repl("Ä",11) +chr(197)
    ?? repl("Ä",9)+chr(197)+repl("Ä",12)+chr(197)+repl("Ä",11) +"¶"
    lFirstPass := .F.
    nLineCtr += 5
return nil

static function compSr()
nVal:=0.00
for i:= 1 to 4
    (cDbf):=OpenTickets(i)
    (cDbf)->(DbSetOrder(1))
    (cDbf)->(DbSeek(dtos(dStartDate)))
    (cDbf)->(DbSetOrder(3))
   do while (!Eof())
      if (Date >= dStartDate) .and. (Date <= dEndDate) .and. (!Deleted())
          Message("Preparing Record#"+transform(RecNo(),"9999")+"...")
          nVal += DUE
      endif
      (cDbf)->(DBSkip())
   enddo
   (cDbf)->(DBCloseArea())
next
return nVal

static function compREf()
nVal:=0.00
 if NETUSE("REFUND.DBF",DB_SHARED,NUM_SECONDS)
    Set index to REFUND
 endif
 do while (!Eof())
    if (REFUND->Date >= dStartDate) .and. (REFUND->Date <= dEndDate) .and. (!Deleted())
        Message("Preparing Record#"+transform(RecNo(),"9999")+"...")
         nVal += REF_NET
     endif
     REFUND->(DBSkip())
 enddo
REFUND->(DBCloseArea())
return nval


// end-of-file
