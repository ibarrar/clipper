// Filename:      LEDGER.PRG
// Module:        Subsidiary Ledger
// Author:        Arnold P. Caoile
// Date-Started:  May 13, 1992
// Last-Update:   June 26, 1992

#include "Inkey.ch"
#include "Setcurs.ch"
#include "Mode.ch"
#include "Help.ch"

#define LDGR_BAR "F2-Add  F3-Edit  F4-Delete  F5-Search  "+;
   "F6-Totals  F7-Print  Esc-Abort"

static nDbfArea,nTransArea,mAirAgency,mDate,mParticular,mAirline,aPicture
static aInclude:={}

function Ledger(cDbfName,cTransName,cTitle)
local wLedger,wInclude,nKey, nSaveRec
local lCdb:=lCrb:=lSb:=lPcv:=lJv:=.T.
   if NetUse("AIRLINE",DB_SHARED,NUM_SECONDS)
      set index to AIR_CODE,AIRLINE
   endif
   if NetUse("CHART",DB_SHARED,NUM_SECONDS)
      set index to CHT_CODE,CHART
   endif
   if NetUse(cTransName,DB_SHARED,NUM_SECONDS)
      set index to &cTransName
   endif
   nTransArea:=Select()
   if NetUse(cDbfName,DB_SHARED,NUM_SECONDS)
      set index to &cDbfName
   endif
   nDbfArea:=Select()
   aPicture:=Array(7,2)
   aPicture[1][1]:=cTransName+"->REC_NO"
   aPicture[1][2]:="@!"
   aPicture[2][1]:=cTransName+"->DATE"
   aPicture[2][2]:=Replicate("X",8)
   aPicture[3][1]:=cTransName+"->Folio"
   aPicture[3][2]:=Replicate("X",10)
   aPicture[4][1]:=cTransName+"->DEBIT"
   aPicture[4][2]:="9,999,999.99"
   aPicture[5][1]:=cTransName+"->CREDIT"
   aPicture[5][2]:="9,999,999.99"
   aPicture[6][1]:=cTransName+"->DETAILS_1"
   aPicture[6][2]:=Replicate("X",40)
   aPicture[7][1]:=cTransName+"->DETAILS_2"
   aPicture[7][2]:=Replicate("X",40)
   wLedger:=OpenWindow(03,08,11,66,"Subsidiary Ledger")
   if (nDbfArea)->(RecCount())==0 ; LedgerScreen(APPEND_MODE,cTitle) ; endif
   if LastKey()!=K_ESC
      do while (nKey!=K_ESC)
         LedgerScreen(VIEW_MODE,cTitle)
         nKey:=Inkey(0)
         do case
            case nKey==K_DOWN
               (nDbfArea)->(DbSkip())
               if (nDbfArea)->(Eof())
                  (nDbfArea)->(DbGoBottom())
                  Tone(100,3)
                  Message("End of file reached....")
                  Inkey(1)
               endif
            case nKey==K_UP
               (nDbfArea)->(DbSkip(-1))
               if (nDbfArea)->(Bof())
                  (nDbfArea)->(DbGoTop())
                  Tone(100,3)
                  Message("Beginning of file reached....")
                  Inkey(1)
               endif
            case nKey==K_CTRL_PGDN
               (nDbfArea)->(DbSkip(NUM_TO_SKIP))
               if (nDbfArea)->(Eof())
                  (nDbfArea)->(DbGoBottom())
                  Tone(100,3)
                  Message("End of file reached....")
                  Inkey(1)
               endif
            case nKey==K_CTRL_PGUP
               (nDbfArea)->(DbSkip(-NUM_TO_SKIP))
               if (nDbfArea)->(Bof())
                  (nDbfArea)->(DbGoTop())
                  Tone(100,3)
                  Message("Beginning of file reached....")
                  Inkey(1)
               endif
            case nKey==K_END
               (nDbfArea)->(DbGoBottom())
               Message("Moving to end of file....")
               Inkey(1)
            case nKey==K_HOME
               (nDbfArea)->(DbGoTop())
               Message("Moving to beginning of file....")
               Inkey(1)
            case nKey==K_PGDN
               (nTransArea)->(ABrowse2((nDbfArea)->(RecNo()),VIEW_MODE,;
                  aPicture,H_LDGR))
            case nKey==K_F1
               GetHelp(H_LDGR)
            case nKey==K_F2
               LedgerScreen(APPEND_MODE,cTitle)
            case nKey==K_F3
               LedgerScreen(EDIT_MODE,cTitle)
            case nKey==K_F4
               Message("Press ENTER to delete record, ESC to abort.")
               nDel:=0
               do while (nDel!=K_ENTER) .and. (nDel!=K_ESC)
                  nDel:=Inkey(0)
               enddo
               if nDel==K_ENTER
                  Message("Deleting current record....")
                  (nDbfArea)->(FilLock(0))
                  (nDbfArea)->(DbDelete())
                  (nDbfArea)->(DbUnlock())
                  (nTransArea)->(DbSeek((nDbfArea)->(RecNo())))
                  (nTransArea)->(FilLock(0))
                  Message("Updating Transaction file...")
                  do while (nTransArea)->REC_NO==(nDbfArea)->(RecNo())
                      (nTransArea)->(DbDelete())
                      (nTransArea)->(DbSkip())
                  enddo
                  (nTransArea)->(DBUnLock())
               endif
            case nKey==K_F5
               SearchPax(cTitle)
            case nKey==K_F10
               Tone(300,1)
               Message("Press ENTER to Reindex Databases...")
               inkey(0)
              if lastkey() == K_ENTER
               Message("Reindexing, this may take FOREVER...")
               (nDbfArea)->(DbReindex())
               (nTransArea)->(DbReindex())
              endif
            case nKey==K_F6
               if GetDates()
                  lCdb:=lCrb:=lSb:=lPcv:=lJv:=.T.
                  aInclude:={{"Y","CV"},{"Y","OR"},{"Y","B#"},{"Y","PC"}, ;
                     {"Y","JV"}}
                  wInclude:=OpenWindow(07,26,16,54,"Schedule of Accounts")
                  SetCursor(SC_NORMAL)
                  Message("Type Y to include in computation, N if not.")
                  @ 09,28 say "Include the following:"
                  @ 11,28 say "        Check Vouchers" get lCdb picture "Y"
                  @ 12,28 say "         Cash Receipts" get lCrb picture "Y"
                  @ 13,28 say "                 Bills" get lSb  picture "Y"
                  @ 14,28 say "   Petty Cash Vouchers" get lPcv picture "Y"
                  @ 15,28 say "      Journal Vouchers" get lJv  picture "Y"
                  read
                  aInclude[1][1]:=lCdb
                  aInclude[2][1]:=lCrb
                  aInclude[3][1]:=lSb
                  aInclude[4][1]:=lPcv
                  aInclude[5][1]:=lJv
                  SetCursor(SC_NONE)
                  CloseWindow(wInclude)
                  if LastKey() != K_ESC
                    if cOutput=="Y"
                       PrintSked(cTitle)
                    else
                       ComputeTotal(cTitle)
                    endif
                  endif
               endif
            case nKey==K_F7
               if IsPrinter()
                  Message("Printing....please wait!")
                  Set(_SET_CONSOLE,.F.)
                  Set(_SET_PRINTER,.T.)
                  ?
                  ? MARGIN,"Subsidiary Ledger"
                  ? MARGIN,cTitle
                  ?
                  if !Empty(mAirline)
                     ? MARGIN,"Airline/Agency"
                     ? MARGIN,mAirline
                     ?
                  endif
                  ? MARGIN,"Date      Particulars"
                  ? MARGIN,(nDbfArea)->DATE+Space(2)+(nDbfArea)->PARTICULAR
                  ? chr(15)            // Select Condensed Mode.
                  ?? chr(27)+chr(77)   // Select 12 pitch
                  ? MARGIN,"  Date      Folio         Debit        Credit      "
                  ?? "            Details 1                     "
                  ?? "            Details 2                  "
                  ?
                  aTrans:=(nTransArea)->(InitArray2((nDbfArea)->(RecNo())))
                  nDebit := nCredit := 0
                  for n:=1 to Len(aTrans)
                     ? MARGIN,aTrans[n][3]+Space(2)+aTrans[n][4]+Space(2)
                     ?? aTrans[n][5]+Space(2)+aTrans[n][6]+Space(2)
                     ?? aTrans[n][7]+Space(2)+aTrans[n][8]
                     nDebit += val(delchar(aTrans[n][5],','))
                     nCredit += val(delchar(aTrans[n][6],','))
                  next
                  ? MARGIN, space(9), "Balance --> "
                  ?? transform(nDebit - nCredit,"@( 9,999,999.99")
                  ?? chr(18)            // Cancel Condensed Mode
                  ?? chr(27)+chr(80)    // Select 10 pitch
                  eject
                  Set(_SET_CONSOLE,.T.)
                  Set(_SET_PRINTER,.F.)
               else
                  Message("Printer not ready....")
                  Tone(100,3)
                  Inkey(2)
               endif
         endcase
      enddo
   endif
   (nDbfArea)->(DbCloseArea())
   (nTransArea)->(DbCloseArea())
   CHART->(DbCloseArea())
   AIRLINE->(DbCloseArea())
   CloseWindow(wLedger)
return nil

static function LedgerScreen(nMode,cTitle)
local nArea,cColor
   Tone(300,1)
   InitVariables(nMode)
   Message(LDGR_BAR)
   cColor:=SetColor("W+/BG")
   if (nDbfArea)->(Deleted()) ; @ 03,35 say "<deleted>"
   else ; @ 03,35 say "         " ; endif
   @ 03,54 say "Rec. #" + ;
   Transform(If(nMode==APPEND_MODE,(nDbfArea)->(RecCount()+1),(nDbfArea)->(RecNo())),"99999")
   SetColor(cColor)
   @ 05,10 say cTitle
   @ 07,10 say "Airline/Agency"
   if nMode==VIEW_MODE
      mAirline:=mAirAgency
      if Len(AllTrim(mAirAgency))!=0
         AIRLINE->(DbSeek(AllTrim(mAirAgency)))
         if AIRLINE->(Found())
            mAirline:=AIRLINE->AIRLINE
         endif
      endif
      @ 08,10 get mAirline
   else
      @ 08,10 get mAirAgency picture "@!"
   endif
   @ 09,10 say "Date"
   @ 10,10 get mDate
   @ 09,25 say "Particulars"
   @ 10,25 get mParticular picture "@!"
   if (nMode==APPEND_MODE) .or. (nMode==EDIT_MODE)
      Message("Esc-Abort")
      SetCursor(SC_NORMAL)
      read
      if LastKey()!=K_ESC
        if nMode==APPEND_MODE
           (nDbfArea)->(AddRec(0))
        endif
        /* Replace current record with new entry. */
        (nDbfArea)->(FilLock(0))
        (nDbfArea)->AIR_AGENCY:=mAirAgency
        (nDbfArea)->DATE:=DToC(mDate)
        (nDbfArea)->PARTICULAR:=mParticular
        (nDbfArea)->(DbUnlock())
        (nTransArea)->(ABrowse2((nDbfArea)->(RecNo()),nMode,aPicture,H_LDGR))
      endif
   else
      clear gets
   endif
   SetCursor(SC_NONE)
return nil

static function InitVariables(nMode)
   if (nMode==APPEND_MODE)
      mAirAgency:=Space(40)
      mDate:=CToD("  /  /  ")
      mParticular:=Space(40)
   else
      mAirAgency=(nDbfArea)->AIR_AGENCY
      mDate=CToD((nDbfArea)->DATE)
      mParticular:=(nDbfArea)->PARTICULAR
   endif
return nil

static function SearchPax(cTitle)
local nRecNo,wSearch,nKey,cName:=Space(40)
   nRecNo:=(nDbfArea)->(RecNo())
   wSearch:=OpenWindow(08,18,12,61,"Search Mode")
   @ 10,20 say "Enter name to search"
   @ 11,20 get cName picture "@!"
   SetCursor(SC_NORMAL)
   read
   cName:=Alltrim(cName)
   CloseWindow(wSearch)
   SetCursor(SC_NONE)
   if LastKey()!=K_ESC
      (nDbfArea)->(DbSeek(AllTrim(cName)))
      if (nDbfArea)->(Found())
         do while (cName==substr(upper((nDbfArea)->PARTICULAR),1,len(cName))) .and. (nKey!=K_ESC)
            LedgerScreen(VIEW_MODE,cTitle)
            Message("Press ENTER to continue search, ESC to abort....")
            nKey:=0
            do while (nkey!=K_ENTER) .and. (nKey!=K_ESC)
               nKey:=Inkey(0)
            enddo
            if nKey==K_ENTER ; (nDbfArea)->(DbSkip()) ; endif
        enddo
      else
        Message("Name not found ... Press ENTER to search Firstnames")
        nKey:= inkey(0)
        (nDbfArea)->(DbGoBottom())
        do while ((nDbfArea)->(!BOF())) .and. (nKey!=K_ESC) .and. nextKey()!=K_ESC
          Message("Searching for "+cName+", this may take TIME..."+space(abs(29-len(cName)))+"ESC to abort")
          do while !(cName $ ((nDbfArea)->PARTICULAR)) .and. (nDbfArea)->(!BOF()) .and. nextkey()!=K_ESC
            (nDbfArea)->(DbSkip(-1))
          enddo
          if  (cName $ ((nDbfArea)->PARTICULAR))
            LedgerScreen(VIEW_MODE,cTitle)
            Message("Press ENTER to continue search, ESC to abort ...")
            nkey:=0
            do while (nKey!=K_ENTER) .and. (nkey!=K_ESC)
              nKey:=Inkey(0)
            enddo
            if nkey==K_ENTER; (nDbfArea)->(DbSkip(-1)); endif
          endif
        enddo
         if (nDbfArea)->(BOF()) .or. ((nDbfArea)->(!Found()) .and. nKey==K_ENTER)
          Tone(150,2)
          Message("Name not found....")
          (nDbfArea)->(DbGoTo(nRecNo))
          Inkey(1.5)
         endif
      endif
   endif
return nil

static function PrintSked(cTitle)
local nSaveRecNo:=(nDbfArea)->(RecNo()),nAmount,nTotal:=0
local cDate,cFolio,nLines,nPage,nKey,lReady:=.F.,nLCnt := 55
local cInclude:="",x
   for x:=1 to len(aInclude)
      if aInclude[x][1]
         cInclude += substr(aInclude[x][2],1,2)
      endif
   next
   Message("Press ENTER to print Schedules, ESC to abort....")
   do while (nKey!=K_ENTER) .and. (nKey!=K_ESC)
      nKey:=Inkey(0)
   enddo
   if nKey==K_ENTER
      lReady:=IsPrinter()
      nKey:=0
      do while !lReady .and. (nKey!=K_ESC)
         Tone(100,3)
         Message("Printer not ready....")
         Inkey(2)
         Message("Press ENTER to retry, ESC to abort....")
         nKey:=Inkey(0)
         lReady:=IsPrinter()
      enddo
      if nKey!=K_ESC
         Message("Printing Schedule of "+cTitle+"....")
         Set(_SET_CONSOLE,.F.)
         Set(_SET_PRINTER,.T.)
         ?  chr(27)+chr(120)+chr(1)        // Turn NLQ on
         ?? chr(27)+chr(119)+chr(1)        // Turn Double-Height Mode ON.
         ? MARGIN,"Super Travel, Inc."
         ?
         ? MARGIN,cTitle
         ?
         ? MARGIN,"Period:  As of ",DToC(dEndDate)
         ? chr(27)+chr(119)+chr(0)        // Turn Double-Height Mode OFF.
         ? chr(27)+chr(120)+chr(0)       // Turn NLQ off
         ?
         ? chr(15)                        // Select Condensed Mode.
         ? MARGIN,Space(10),"  Date  ",Space(5)
         ?? "         P a r t i c u l a r s          ",Space(5),"   Folio    "
         ?? Space(10),"   Amount   "
         ?
         nLines:=11
         nPage:=1
         (nDbfArea)->(DbGoTop())
         do while (nDbfArea)->(!Eof())
            if CToD((nDbfArea)->DATE)<=dEndDate
               if (nTransArea)->(DbSeek((nDbfArea)->(RecNo())))
                  nAmount:=0  ; cDate:=""
                  do while ((nTransArea)->REC_NO == (nDbfArea)->(RecNo()))  .and. ;
                     ((nTransArea)->(!Eof()))
                     if (CTOD((nTransArea)->DATE)<=dEndDate) .and. ;
                        (CTOD((nTransArea)->DATE)>=dStartDate) .and. ;
                     (at( upper(substr((nTransArea)->FOLIO,1,2)),cInclude)!=0)
                        if ctod(cDate) < ctod((nTransArea)->DATE)
                           cDate:=(nTransArea)->DATE
                           cFolio:=(nTransArea)->FOLIO
                        endif
                        nAmount+=(nTransArea)->DEBIT - (nTransArea)->CREDIT
                     endif
                     (nTransArea)->(DbSkip())
                  enddo
                  if (transform(nAmount,"99.99") != " 0.00")
                     if ((Alias(nDbfArea) == "APO") .or. (Alias(nDbfArea) == "AEX") .or.;
                        (Alias(nDbfArea) == "PRI"))
                        nAmount:=-nAmount
                     endif
                     if nLines>LINES_PER_PAGE
                        nLCnt:=60
                        ?? chr(12)        // Form Feed.
                        nPage+=1
                        // Turn Double-Height Mode ON.
                        ? chr(27)+chr(119)+chr(1)
                        ?? MARGIN,"Page no. ",Transform(nPage,"99")
                        ?
                        // Turn Double-Height Mode OFF.
                        ? chr(27)+chr(119)+chr(0)
                        ??
                        ?? chr(15)         // Select Condensed Mode.
                        ? MARGIN,Space(10),"  Date  ",Space(5)
                        ?? "         P a r t i c u l a r s          "
                        ?? Space(5),"   Folio    ",Space(10),"   Amount   "
                        ?
                        nLines:=5
                     endif
                     ? MARGIN,Space(10),cDate,Space(5)
                     ?? (nDbfArea)->PARTICULAR,Space(5),cFolio,Space(10)
                     ?? Transform(nAmount,NUM_PIC)
                     nLines+=1
                     nTotal+=nAmount
                  endif
               endif
            endif
            (nDbfArea)->(DbSkip())
         enddo
         ? MARGIN,Space(10),Replicate("=",96)
         ? MARGIN,Space(71),"Totals",Space(13),Transform(nTotal,NUM_PIC)
         ?? chr(18)                          // Cancel Condensed Mode.
         eject
         (nDbfArea)->(DbGoTo(nSaveRecNo))
         Set(_SET_CONSOLE,.T.)
         Set(_SET_PRINTER,.F.)
      endif
   endif
return nil

static function ComputeTotal(cTitle)
local nSaveRecNo:=(nDbfArea)->(RecNo()),nDebit:=nCredit:=0
local wTotals, cInclude:="", x
    for x:=1 to len(aInclude)
       if aInclude[x][1]
          cInclude := cInclude + substr(aInclude[x][2],1,2)
       endif
    next
    Message("Computing "+cTitle+" totals....")
    (nDbfArea)->(DbGotop())
    do while (nDbfArea)->(!Eof())
       Message("Reading Master (rec# "+transform((nDbfArea)->(RecNo()),"9999")+").")
       if CToD((nDbfArea)->DATE)<=dEndDate
          if (nTransArea)->(DbSeek((nDbfArea)->(RecNo())))
             do while ((nTransArea)->REC_NO == (nDbfArea)->(RecNo())) .and. ;
                      ((nTransArea)->(!Eof()))
                Message("Reading Transaction (rec# "+transform((nTransArea)->(RecNo()),"99999")+").")
                if (CTOD((nTransArea)->DATE)<=dEndDate) .and. ;
                   (CTOD((nTransArea)->DATE)>=dStartDate) .and. ;
                   (at( upper(substr((nTransArea)->FOLIO,1,2)),cInclude)!=0)
                      nDebit+=(nTransArea)->DEBIT
                      nCredit+=(nTransArea)->CREDIT
                endif
                (nTransArea)->(DbSkip())
             enddo
          endif
       endif
       (nDbfArea)->(DbSkip())
    enddo
    wTotals:=OpenWindow(08,20,14,60,cTitle)
    @ 10,29 say " Debit:  "+Transform(nDebit,"99,999,999.99")
    @ 11,29 say "Credit:  "+Transform(nCredit,"99,999,999.99")
    @ 12,29 say "         "+Replicate("-",12)
    @ 13,29 say "Balance: "+Transform(nDebit-nCredit,"99,999,999.99")
    Message("Press any key to continue....")
    Inkey(0)
    CloseWindow(wTotals)
    (nDbfArea)->(DbGoTo(nSaveRecNo))
return nil

// end-of-file