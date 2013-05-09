// Filename:      SR.PRG
// System-Name:
// Module:
// Author:        Rollie Ibarra Jr.
// Date-Started:  Nov. 22, 1993
// Last-Update:   Nov. 22, 1993

#include "Mode.ch"
#include "Setcurs.ch"
#include "Inkey.ch"
#include "Printer.ch"
#include "cl501_60.ch"

#define OFFS   space(3)

function Sales_Report(lCon)
local nkey,nRecNo := RecNo()
local cSales, isReady
private sRepNo,mDate,nLineCtr
private aGndTotal := {0,0,0,0,0,0,0}
   nPgNo:=1
   nTotPg:=0
   Message("Enter necessary information...")
   mName1:="Azucena Grijaldo"
   mPos1:= "Accountant      "
   mName2:="Elizabeth Mojico"
   mPos2:= "Bookkeeper      "
   if GetDates(if(lCon,1,2))
      Message("Preparing PR Sales report...")
      set(_SET_CONSOLE,.F.)
      set(_SET_ALTFILE,"SALES.RPT")
      set(_SET_ALTERNATE,.T.)
      if lCon
         ? "þPR Domestic Tickets Sales Report"
         ? " Period: " + expand(dStartDate) + " to " + expand(dEndDate)
         ?
      endif
     for i:= 1 to 4
          (cDbf):=OpenTickets(i)
          (cDbf)->(DbSetOrder(1))
          (cDbf)->(DbSeek(dtos(dStartDate)))
          (cDbf)->(DbSetOrder(3))
     if lCon
      ? cDbf
      ?  space(1) + " Date  "
      ?? space(1) + " MCO/Tickets     "
      ?? space(1) + " Passenger               "
      ?? space(2) + "Cash Sales"
      ?? space(2) + "  Cash Due"
      ?? space(2) + "Misc.Coll."
      ?
     endif
     do while (!Eof())
        if (Date >= dStartDate) .and. (Date <= dEndDate) .and. (!Deleted())
         Message("Preparing Record#"+transform(RecNo(),"9999")+"...")
         if lCon
            ?? space(1) + expand(DATE) + space(1)
            ?? substr(TICKET_NO,1,17)  + space(1)
            ?? substr(PASSENGER,1,25) + space(2)
            ?? blank_ifzero(SALES,"999,999.99") + space(2)
            ?? blank_ifzero(DUE,  "999,999.99") + space(2)
            ?? blank_ifzero(MISC,     "999.99") + space(2)
            ?? Remarks1
            ?
         else
            ? OFFS,substr(TICKET_NO,1,16) + space(1)
            if (SALES+COMM+ASF+TERM_FEE+DUE) != 0
               ?? blank_ifzero(SALES,"999,999.99") + space(1)
               ?? blank_ifzero(COMM,   "9,999.99") + space(1)
               ?? blank_ifzero(ASF,      "999.99") + space(1)
               ?? blank_ifzero(TERM_FEE, "999.99") + space(1)
               ?? blank_ifzero(DUE,  "999,999.99") + space(1)
               ?? blank_ifzero(MISC,   "9,999.99") + space(2)
               ?? substr(EXC_TKT,1,16)             + space(2)
               ?? PASSENGER          + space(1)
               ?? PAX_TYPE
            endif
            /* ----- print second line ----- */
               if (SALES+COMM+ASF+TERM_FEE+DUE) = 0
                  if empty(MISC)
                     ?? space(2)
                     ?? Remarks1 + space(01)
                     ?? substr(Remarks2,1,21) + space(01)
                     ?? substr(EXC_TKT,1,16)   + space(2)
                     ?? PASSENGER + space(1)
                     ?? PAX_TYPE
                   elseif (len(Alltrim(Remarks1)) + len(Alltrim(Remarks2))) < 43
                     ?? space(2)
                     ?? Remarks1 + space(01)
                     ?? substr(Remarks2,1,13) + space(01)
                     ?? blank_ifzero(MISC,"999.99") + space(2)
                     ?? substr(EXC_TKT,1,16)   + space(2)
                     ?? PASSENGER + space(1)
                     ?? PAX_TYPE
                   endif
                   ?
               elseif !empty(Remarks1) .or. !empty(Remarks2)
                  ? OFFS,space(19)
                  ??  Alltrim(Remarks1) + space(01)
                  ??  Remarks2
               else
                  ?
               endif
         endif
         /* ----- compute totals -------*/
         aGndTotal[1] ++
         aGndTotal[2] += SALES
         aGndTotal[3] += COMM
         aGndTotal[4] += ASF
         aGndtotal[5] += TERM_FEE
         aGndtotal[6] += DUE
         aGndtotal[7] += MISC
        endif
         (cDbf)->(DBSkip())
   enddo
   (cDbf)->(DBCloseArea())
 next
    if lCon
     ?? repl('=',90)
     ?  space(1)  + "Totals : "
     ?? space(3)  + transform(aGndTotal[1],"999") + " Tickets"
     ?? space(28) + transform(aGndTotal[2],"9,999,999.99")
     ?? space(00) + transform(aGndTotal[6],"9,999,999.99")
     ?? space(00) + transform(aGndTotal[7],"9,999.99")
     ?
   endif
   set(_SET_ALTERNATE,.F.)
   set(_SET_ALTFILE,"")
   set(_SET_CONSOLE,.T.)
   close alternate
   cSales := MemoRead("SALES.RPT")
   if lCon
     wSales:=OpenWindow(3,1,22,78,"Domestic Sales Report")
     Message("Use Cursor keys to navigate, F10 to print  Esc to Abort.")
     SetCursor(SC_NORMAL)
     MemoEdit(cSales,4,2,21,77,.f.,"EditorFunc",140)
     CloseWindow(wSales)
     SetCursor(SC_NONE)
   else
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
           nLines:=MLCount(cSales,140)
           cMemo:=Memoread("Notes.Rpt")
           nNotelines:=MlCount(cMemo,91)
           if nTotPg = 0
           nTotPg:=(nLines+22+nNotelines)            //if 21 is not right try 19
           nTotPg+=((int(nTotPg/81) + if(nTotPg%81 > 0,1,0)) * 7)
           nTotPg:=(int(nTotPg/81) + if((nTotPg%81)>0,1,0) )
           endif
           Set(_SET_CONSOLE,.F.)
           Set(_SET_PRINTER,.T.)
           DomHeader(1)
           SRDetlHead()
           for nCurrLine:=1 to nLines
               cLine:=MemoLine(cSales,140,nCurrLine)
               if nLineCtr>81
                  eject
                  nLineCtr:=5
                  nPgno ++
                  ??  chr(18)+chr(27)+chr(77)
                  ??  space(87) + "Page "
                  ??  transform(nPgNo,"9") + " of " +;
                      transform(nTotPg,"@B 9")
                  ?  chr(15)+chr(27)+chr(80)
                  SRDetlHead()
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
            SRTotal()
            ?? chr(27)+chr(77)
            for r:=1 to nNoteLines
                if nLineCtr  > 82
                   eject
                   nPgno ++
                   nLineCtr:=5
                   ?? space(87) + "Page "
                   ?? transform(nPgno,"9") + " of " + transform(nTotPg,"@B 9")
                endif
                cNoteLine:=MemoLine(cMemo,91,r,7)
                ? OFFS,cNoteLine
                Message("Printing Line " + transform(nLineCtr,"99") +;
                        " of Page " + transform(nPgNo,"99") )
                nLineCtr++
            next
            nLineCtr+= round(nNoteLines/5,0) + 1
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
            Alert("Domestic Sales Report done...")
            unPopSound()
       else
            Message("Printing Aborted...")
            inkey(2)
       endif
   endif
       DbGoto(nRecNo)
 endif
return nil


static function SRDetlHead()
    ?? chr(27) + chr(50)               //Line spacing
    ?? chr(15)+chr(27) + chr(70)       // Emp off & Compress
    ?? space(2) + repl("-",139)
    ?  OFFS,space(37) + "ÚÄÄÄÄ Tax ÄÄÄ¿"
    ?  OFFS,space(42) + "    Term." + space(11) + "   Misc." + space(59) + "Pax."
    ?  OFFS,"Form & Number   "  + space(1) + "Cash Sales"
    ?? space(01) + "    Comm" + space(01) + "   ASF"
    ?? space(01) + "   Fee"  + space(01) + "  Cash Due"
    ?? space(01) + "   Coll."  + space(02) + "Exchange Document"
    ?? space(10) + "Passenger" + space(21) + "Type"
    ? space(2) + repl("-",139)
    ?? chr(27) + chr(48)              //Line spacing
    lFirstPass := .F.
    nLineCtr += 5
return nil

static function SRTotal()
    ?  chr(27) + chr(50)
    ?? space(2) + repl("=",139)
    /* ----- print grand totals ----- */
    ? OFFS, "Totals : "
    ? OFFS, space(05) + transform(aGndTotal[1],"999") + " Tickets"
    ?? space(01) + transform(aGndTotal[2],"999,999.99")
    ?? space(01) + transform(aGndTotal[3],  "9,999.99")
    ?? space(01) + transform(aGndTotal[4],    "999.99")
    ?? space(01) + transform(aGndTotal[5],    "999.99")
    ?? space(01) + transform(aGndTotal[6],"999,999.99")
    ?? space(01) + transform(aGndTotal[7],  "9,999.99")
    ?
    ? space(2)+repl("-",139)
    ? chr(18)+chr(27)+chr(77)   //! On Condense Mode
   ??  chr(27) + chr(120) + chr(1)                    //NLQ on
    nLineCtr+=7
return nil


Function  Names()
    ?
    ?
    ? OFFS,"Prepared by:"+PrtUnderline(padc(alltrim(mName2),18),18)+;
      " Certified by:" + PrtUnderline(padC(alltrim(mName1),18),18) +;
      " Remittance Report No:" + PrtUnderline(padc(alltrim(SRepNo),8),8)
    ??  chr(27)+chr(83)+chr(0)                         //SuperScript
    ?? chr(27)+chr(48)
    ?  chr(27)+chr(50)
    ?? OFFS,space(12) + padc(alltrim(mPos2),18) + space(14) +padc(alltrim(mPos1),18)
    ?? chr(27)+chr(84)
    ?
    ? OFFS,"Distribution: Copy 1 & 2 - DPRAD    Copy 3 - Agent"
    ?? chr(27)+chr(72)
return nil

function Others(indx)
local lWrtOk,mStartP:=mEndP:= 0
   wOthers:= OpenWindow(14,09,18,70,"Others")
   @ 16,10 say "Prepared By:" get mName1
   @ 17,10 say " Pos./Title:" get mPos1
   @ 16,41 say "Approved By:" get mName2
   @ 17,41 say " Pos./Title:" get mPos2
 *  @ 14,43 say "Starting Page:" get mStartP picture "99" range 0,9
 *   @ 15,43 say "Ending Page:  " get  mEndP  picture "99" range 1,99
 *  @ 16,43 say " * Press Esc to accept Default "
   SetCursor(1) //SC_NORMAL)
   read
   if lastkey() != K_ESC
      nPgNo:=if(mStartP=0,nPgNo,mStart)
      nTotPg:=if(mEndP=0,nTotPg,mEndP)
   endif
   CloseWindow(wOthers)
   SetCursor(0)
   if lastkey() !=K_ESC .and. (indx!=3)
      cMemo:=Memoread("Notes.Rpt")
      cMemo:=Notes(cMemo)
      lWrtOk:= .f.
      do while (lastkey() != K_ESC) .and.  !lWrtOk
         lWrtOk:= MemoWrit("Notes.Rpt",cMemo)
         if !lWrtOk
            if Alert("Error Saving Notes...... ", {"Retry","Abort"}) = 2
               lWrtOk:=.t.
            endif
         endif
      enddo
   endif
return nil

function Notes(cMemo)
local wNotes
   wNotes:= OpenWindow(08,01,22,78,"Enter Notes....")
   Message("<Ctrl+W>- Save   <ESC>- Abort and return original ")
   SetCursor(1)
   cMemo:=memoEdit(cMemo,09,02,21,77,.t.,"MEMOFUNC",91,7)
   SetCursor(0)
   CloseWindow(wNotes)
return cMemo

static function MEMOFUNC()
local keypress
if me_mode == ME_UNKEY .or.;
   me_mode == ME_UNKEYX
   keypress := lastkey()
   do case
      case keypress == K_INS
         if readinsert()
            setcursor(1) //SC_NORMAL
         else
            setcursor(3)  //SC_SPECIAL1
         endif
         return K_INS
      case keypress == K_F5
         keyboard dtoc(date())
         return ME_DEFAULT
      otherwise
         return ME_DEFAULT
   endcase
endif
return ME_DEFAULT

// end-of-file
