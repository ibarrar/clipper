// Filename:      SCHED.PRG
// Module:        Schedule of Accounts
// Author:        Arnold P. Caoile
// Date-Started:  May 08, 1992
// Last-Update:   June 05, 1992

#include "Inkey.ch"
#include "Achoice.ch"
#include "Mode.ch"
#include "Setcurs.ch"

function Sched()
local wSched,cSched,nBalance:=0
local aDbfs := {"CDB", "CRB", "SB", "JV", "PCV"}
local aTrans := {"CDBTRANS", "CRBTRANS", "SBTRANS", "JVTRANS", "PCVTRANS"}
   Message("Preparing Databases...")
   use SKED index SKED_DAT,SKED_NAM exclusive new
   zap
   close SKED
   use SKEDTRAN index SKEDTRAN exclusive new
   zap
   close SKEDTRAN
   if NetUse("CHART",DB_SHARED,NUM_SECONDS)
      set index to CHT_ACCT
   endif
   if NetUse("SKED",DB_SHARED,NUM_SECONDS)
      set index to SKED_DAT,SKED_NAM
      set order to 2
   endif
   if NetUse("SKEDTRAN",DB_SHARED,NUM_SECONDS)
      set index to SKEDTRAN
   endif
   if GetDateCode()
      if LastKey()!=K_ESC
         aCheck := {.F.,.F.,.F.,.F.,.F.}
         wSched := OpenWindow(08,25,15,55,"Schedule of Accounts")
         @ 10, 27 say "   Cash Disbursements" get aCheck[1] pict 'Y'
         @ 11, 27 say "        Cash Receipts" get aCheck[2] pict 'Y'
         @ 12, 27 say "          Sales Books" get aCheck[3] pict 'Y'
         @ 13, 27 say "     Journal Vouchers" get aCheck[4] pict 'Y'
         @ 14, 27 say "  Petty Cash Vouchers" get aCheck[5] pict 'Y'
         SetCursor(SC_NORMAL)
         read
         SetCursor(SC_NONE)
         CloseWindow(wSched)
         Set(_SET_SOFTSEEK,.T.)
         for x:=1 to 5
         if aCheck[x]
            Message("Searching "+aDbfs[x]+"...")
            if NetUse(aDbfs[x],DB_SHARED,NUM_SECONDS)
               set index to (aDbfs[x]+"_DATE")
            endif
            nDbfArea:=Select()
            if NetUse(aTrans[x],DB_SHARED,NUM_SECONDS)
               set index to (aTrans[x])
            endif
            nTransArea:=Select()
            (nDbfArea)->(DbSeek(SubStr(DToC(dStartDate),7,2)+"-"+ ;
               SubStr(DToC(dStartDate),1,2)+"-"+ ;
               SubStr(DToC(dStartDate),4,2)  ))
            do while (nDbfArea)->(!Eof()) .and. (CToD((nDbfArea)->DATE) <= dEndDate)
               Message("Searching "+aDbfs[x]+" Record #"+transform((nDbfArea)->(RecNo()),"99999"))
               (nTransArea)->(DbSeek((nDbfArea)->(RecNo()) ))
               do while (nTransArea)->REC_NO==(nDbfArea)->(RecNo())
                  if (nTransArea)->ACCT_CODE==mAcctCode
                     if ((nTransArea)->DEBIT!=0.00) .or. ((nTransArea)->CREDIT!=0.00)
                        SKED->(FilLock(0))
                        SKEDTRAN->(FilLock(0))
                        cName := (nDbfArea)->&( (nDbfArea)->(Field(3)) )
                        if !SKED->(DbSeek( upper(cName)  ))
                            SKED->(AddRec(0))
                            SKED->PARTICULAR:=cName
                            SKED->DATE:=(nDbfArea)->DATE
                        endif
                        if ctod(SKED->DATE) < ctod((nDbfArea)->DATE)
                            SKED->DATE:=(nDbfArea)->DATE
                        endif
                        SKEDTRAN->(AddRec(0))
                        SKEDTRAN->REC_NO:=SKED->(RecNo())
                        SKEDTRAN->DATE:=(nDbfArea)->DATE
                        SKEDTRAN->FOLIO:=(nDbfArea)->VOUCHER_NO
                        SKEDTRAN->DEBIT:=(nTransArea)->DEBIT
                        SKEDTRAN->CREDIT:=(nTransArea)->CREDIT
                        SKEDTRAN->DETAILS_1:=(nDbfArea)->DETAILS_1
                        SKEDTRAN->DETAILS_2:=(nDbfArea)->DETAILS_2
                        SKEDTRAN->(DbUnlock())
                        SKED->(DbUnlock())
                     endif
                  endif
                  (nTransArea)->(DbSkip())
               enddo
               (nDbfArea)->(DbSkip())
            enddo
            (nDbfArea)->(DbCloseArea())
            (nTransArea)->(DbCloseArea())
         endif
         next
         SKED->(DbSetOrder(1))
         SKED->(DbGoTop())
         Set(_SET_CONSOLE,.F.)
         Set(_SET_PRINTER,.T.)
         Set(_SET_ALTFILE,"SCHED.RPT")
         ? "þ"+CHART->ACCT_TITLE
         ? "Period: ",dStartDate,"-",dEndDate
         ?
         ? "  Date       Folio                     Particulars            "
         ??  Space(11), "Debit", Space(7), "Credit", Space(6),"Balance"
         nBalance:=0
         do while SKED->(!Eof())
            cName := SKED->PARTICULAR
            nDebit:=nCredit:=0
            cDate:=cFolio:=cDetail_1:=cDetail_2:=""
            SKEDTRAN->(DbSeek( SKED->(RecNo()) ))
            do while SKEDTRAN->(!Eof()) .and. (SKED->(RecNo())==SKEDTRAN->REC_NO)
                if ctod(cDate) < ctod(SKEDTRAN->DATE)
                   cDate:=SKEDTRAN->DATE
                   cFolio:=SKEDTRAN->FOLIO
                   cDetail_1:=SKEDTRAN->DETAILS_1
                   cDetail_2:=SKEDTRAN->DETAILS_2
               endif
               nDebit+=SKEDTRAN->DEBIT
               nCredit+=SKEDTRAN->CREDIT
               SKEDTRAN->(DbSkip())
            enddo
            ? cDate," ",cFolio," ",cName," "
            ?? Transform(nDebit,"@( 99,999,999.99")," "
            ?? Transform(nCredit,"@( 99,999,999.99")," "
            ?? Transform(nDebit-nCredit,"@( 99,999,999.99")
            if Len(AllTrim(cDetail_1))!=0
               ? Space(23),cDetail_1
            endif
            if Len(AllTrim(cDetail_2))!=0
               ? Space(23),cDetail_2
            endif
            nBalance +=nDebit-nCredit
            SKED->(DbSkip())
         enddo
         ?
         ? Replicate("-",110)
         ? "Totals ---->"+Space(84)+Transform(nBalance,"@( 99,999,999.99")
         Set(_SET_SOFTSEEK,.F.)
         Set(_SET_CONSOLE,.T.)
         Set(_SET_PRINTER,.F.)
         Set(_SET_ALTFILE,"")
         close PRINTER
         cSched:=MemoRead("SCHED.RPT")
         Message("Use cursor keys to navigate, press Esc to abort.")
         SetCursor(SC_NORMAL)
         wSched:=OpenWindow(3,1,21,77,"Schedule of Accounts")
         MemoEdit(cSched,4,2,20,76,.F.,"EditorFunc",120)
         CloseWindow(wSched)
         SetCursor(SC_NONE)
      endif
      CHART->(DbCloseArea())
      SKED->(DbCloseArea())
      SKEDTRAN->(DbCloseArea())
   endif
return nil

function CDB_Summary()
   store 0 to nTot_CiBPCI, nTot_CiBCBC, nTot_ARTdr, nTot_ARTcr
   store 0 to nTot_PRdr, nTot_PRcr, nTot_CCdr, nTot_CCcr
   store 0 to nTot_TTdr, nTot_TTcr, nTot_Scr, nTot_Sdr
   if GetDates()
      if Isprinter()
         Set(_SET_SOFTSEEK,.T.)
         Set(_SET_CONSOLE,.F.)
         Set(_SET_PRINTER,.T.)
         Message("Thinking...")
         if NetUse("CHART",DB_SHARED,NUM_SECONDS)
            set index to CHT_ACCT
         endif
         if NetUse("CDBTRANS",DB_SHARED,NUM_SECONDS)
            set index to CDBTRANS
         endif
         if NetUse("CDB",DB_SHARED,NUM_SECONDS)
            set index to CDB_VNO
            set filter to ( ctod(date) >= dStartDate ) .and. ;
                          ( ctod(date) <= dEndDate )
            go top
         endif
         ?? chr(18)                        // Normal Size
         ?? chr(27)+chr(120)+chr(1)        // Turn NLQ on
         ?? chr(27)+chr(119)+chr(1)        // Turn Double-Height Mode ON.

         ?? "þCash Disbursement Report"
         ?
         ?? "Period :",dStartDate,"to",dEndDate
         ?
         ?
         ?? chr(27)+chr(119)+chr(0)        // Turn Double-Height Mode OFF.
         ?? chr(15)                        // Select Condensed Mode.
         ?? space(76),"ÚÄÄ Cash in Bank ÄÄ¿"," "
         ?? "ÚÄÄÄ A/R Travel ÄÄÄ¿"," "
         ?? "ÚÄÄÄ Pax Refund ÄÄÄ¿"," "
         ?? "ÚÄÄ Cxln Charges ÄÄ¿"," "
         ?? "Ú Trans. & Travel Ä¿"," "
         ?? "ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ Sundry Accounts ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿"
         ?
         ?? "  Date               Particular(s)                 Voucher No.    "
         ?? "Check No.    Debit     Credit      Debit     Credit      "
         ?? "Debit     Credit      Debit     Credit      "
         ?? "Debit     Credit        Account Title                 "
         ?? "Debit     Credit"
         ?? chr(27)+chr(120)+chr(0)        // Turn NLQ off
         ?
         ?
         do while CDB->(!Eof())
            Message("Printing Rec#" + transform( CDB->(RecNo()),"99999" ) )
            store 0 to nCiBPCI, nCiBCBC, nARTdebit, nARTcredit
            store 0 to nPRdebit, nPRcredit, nCCdebit, nCCcredit
            store 0 to nTTdebit, nTTcredit
            aSundry := {}
            CDBTRANS->(DbSeek( CDB->(RecNo()) ))
            do while CDBTRANS->(!Eof()) .and. ;
               (CDBTRANS->REC_NO == CDB->(RecNo()))
               Message("Printing Record#"+blank(CDB->(Recno()),"99999"))
               if CDBTRANS->ACCT_CODE == "01-111"
                  nCiBPCI := CDBTRANS->DEBIT + CDBTRANS->CREDIT
               elseif CDBTRANS->ACCT_CODE == "01-112"
                  nCiBCBC := CDBTRANS->DEBIT + CDBTRANS->CREDIT
               elseif CDBTRANS->ACCT_CODE == "01-121"
                  nARTdebit  := CDBTRANS->DEBIT
                  nARTcredit := CDBTRANS->CREDIT
               elseif CDBTRANS->ACCT_CODE == "04-181"
                  nPRdebit  := CDBTRANS->DEBIT
                  nPRcredit := CDBTRANS->CREDIT
               elseif CDBTRANS->ACCT_CODE == "09-203"
                  nCCdebit  := CDBTRANS->DEBIT
                  nCCcredit := CDBTRANS->CREDIT
               elseif CDBTRANS->ACCT_CODE == "10-513"
                  nTTdebit  := CDBTRANS->DEBIT
                  nTTcredit := CDBTRANS->CREDIT
               else
                 aAdd(aSundry,{CDBTRANS->ACCT_CODE,CDBTRANS->DEBIT,;
                     CDBTRANS->CREDIT})
               endif
               CDBTRANS->(DbSkip())
            enddo
            ?? CDB->DATE + "  " + CDB->PAYEE + "  "
            ?? CDB->VOUCHER_NO + "  " + CDB->CHECK_NO + "  "
            ?? blank(nCiBPCI,"99,999.99"), " "
            ?? blank(nCiBCBC,"99,999.99"), " "
            ?? blank(nARTdebit ,"99,999.99"), " "
            ?? blank(nARTcredit,"99,999.99"), " "
            ?? blank(nPRdebit ,"99,999.99"), " "
            ?? blank(nPRcredit,"99,999.99"), " "
            ?? blank(nCCdebit ,"99,999.99"), " "
            ?? blank(nCCcredit,"99,999.99"), " "
            ?? blank(nTTdebit ,"99,999.99"), " "
            ?? blank(nTTcredit,"99,999.99"), " "
            nTot_CibPCI += nCiBPCI
            nTot_CibCBC += nCiBCBC
            nTot_ARTdr += nARTdebit
            nTot_ARTcr += nARTcredit
            nTot_PRdr += nPRdebit
            nTot_PRcr += nPRcredit
            nTot_CCdr += nCCdebit
            nTot_CCcr += nCCcredit
            nTot_TTdr += nTTdebit
            nTot_TTcr += nTTcredit
            if len(aSundry) >= 1
               CHART->(DbSeek(aSundry[1][1]))
               ?? substr(CHART->ACCT_TITLE,1,30)," "
               ?? blank(aSundry[1][2],"99,999.99")," "
               ?? blank(aSundry[1][3],"99,999.99")
               nTot_Sdr += aSundry[1][2]
               nTot_Scr += aSundry[1][3]
            endif
            ?
            if !empty(CDB->DETAILS_1) .or. (len(aSundry) >= 2)
               ?? space(10),CDB->DETAILS_1, space(80)
               if len(aSundry) >= 2
                  CHART->(DbSeek(aSundry[2][1]))
                  ?? space(54),substr(CHART->ACCT_TITLE,1,30)," "
                  ?? blank(aSundry[2][2],"99,999.99")," "
                  ?? blank(aSundry[2][3],"99,999.99")
                  nTot_Sdr += aSundry[2][2]
                  nTot_Scr += aSundry[2][3]
               endif
               ?
            endif
            if !empty(CDB->DETAILS_2) .or. (len(aSundry) >= 3)
               ?? space(10),CDB->DETAILS_2, space(80)
               if len(aSundry) >= 3
                  CHART->(DbSeek(aSundry[3][1]))
                  ?? space(54),substr(CHART->ACCT_TITLE,1,30)," "
                  ?? blank(aSundry[3][2],"99,999.99")," "
                  ?? blank(aSundry[3][3],"99,999.99")
                  nTot_Sdr += aSundry[3][2]
                  nTot_Scr += aSundry[3][3]
               endif
               ?
            endif
            if len(aSundry) > 3
               for x := 4 to len(aSundry)
                  CHART->(DbSeek(aSundry[x][1]))
                  ?? space(186),substr(CHART->ACCT_TITLE,1,30)," "
                  ?? blank(aSundry[x][2],"99,999.99")," "
                  ?? blank(aSundry[x][3],"99,999.99")
                  nTot_Sdr += aSundry[x][2]
                  nTot_Scr += aSundry[x][3]
                  ?
               next
            endif
            CDB->(DbSkip())
         enddo
         ?? repl('=',241)
         ?
         ?? "Totals ------>",space(62)
         ?? blank(nTot_CiBPCI,"99,999.99")," "
         ?? blank(nTot_CiBCBC,"99,999.99")," "
         ?? blank(nTot_ARTdr,"99,999.99")," "
         ?? blank(nTot_ARTcr,"99,999.99")," "
         ?? blank(nTot_PRdr,"99,999.99")," "
         ?? blank(nTot_PRcr,"99,999.99")," "
         ?? blank(nTot_CCdr,"99,999.99")," "
         ?? blank(nTot_CCcr,"99,999.99")," "
         ?? blank(nTot_TTdr,"99,999.99")," "
         ?? blank(nTot_TTcr,"99,999.99")," "
         ?? space(30)," "
         ?? blank(nTot_Sdr,"99,999.99")," "
         ?? blank(nTot_Scr,"99,999.99")," "
         eject
         Set(_SET_PRINTER,.F.)
         Set(_SET_CONSOLE,.T.)
         CDB->(DbCloseArea())
         CDBTRANS->(DbCloseArea())
         CHART->(DbCloseArea())
         Set(_SET_SOFTSEEK,.F.)
         Message("Printing Done...")
         Tone(300,1)
         inkey(2)
      else
         Message("Printer Not Ready...")
         Tone(100,3)
         inkey(2)
      endif
   endif
   return nil

function CRB_Summary()
   store 0 to nTot_CiBPCI, nTot_CiBCBC, nTot_ART
   store 0 to nTot_PR, nTot_ARA, nTot_Scr, nTot_Sdr
   if GetDates()
      if Isprinter()
         Set(_SET_SOFTSEEK,.T.)
         Set(_SET_CONSOLE,.F.)
         Set(_SET_ALTFILE,"TEMP.TXT")
         Set(_SET_PRINTER,.T.)
         Message("Thinking...")
         if NetUse("CHART",DB_SHARED,NUM_SECONDS)
            set index to CHT_ACCT
         endif
         if NetUse("CRBTRANS",DB_SHARED,NUM_SECONDS)
            set index to CRBTRANS
         endif
         if NetUse("CRB",DB_SHARED,NUM_SECONDS)
            set index to CRB_VNO
            set filter to ( ctod(date) >= dStartDate ) .and. ;
                          ( ctod(date) <= dEndDate )
            go top
         endif
         ?? chr(18)                        // Normal Size
         ?? chr(27)+chr(120)+chr(1)        // Turn NLQ on
         ?? chr(27)+chr(119)+chr(1)        // Turn Double-Height Mode ON.

         ?? "þCash Revenue Report"
         ?
         ?
         ?? "Period :",dStartDate,"to",dEndDate
         ?
         ?
         ?? chr(27)+chr(119)+chr(0)        // Turn Double-Height Mode OFF.
         ?? chr(15)                        // Select Condensed Mode.
         ?? space(63),"+--- Cash in Bank ---+"
         ?? space(37),"+--------------- Sundry Accounts --------------------+"
         ?
         ?? "  Date              Passenger(s)                    "
         ?? "O.R. No.        PCIB         CBC    A/R Travel  Pax Refund   "
         ?? "Airlines        Account Title                 Debit     Credit"
         ?? chr(27)+chr(120)+chr(0)        // Turn NLQ off
         ?
         ?
         do while CRB->(!Eof())
            Message("Printing Rec#" + transform( CRB->(RecNo()),"99999" ) )
            store 0 to nCiBPCI, nCiBCBC, nART
            store 0 to nPR, nARA
            aSundry := {}
            CRBTRANS->(DbSeek( CRB->(RecNo()) ))
            do while CRBTRANS->(!Eof()) .and. ;
               (CRBTRANS->REC_NO == CRB->(RecNo()))
               Message("Printing Record#"+transform(CRB->(Recno()),"99999"))
               if CRBTRANS->ACCT_CODE == "01-111"
                  nCiBPCI := CRBTRANS->DEBIT
               elseif CRBTRANS->ACCT_CODE == "01-112"
                  nCiBCBC := CRBTRANS->DEBIT
               elseif CRBTRANS->ACCT_CODE == "01-121"
                  nART  := CRBTRANS->CREDIT
               elseif CRBTRANS->ACCT_CODE == "04-181"
                  nPR   := CRBTRANS->CREDIT
               elseif CRBTRANS->ACCT_CODE == "01-122"
                  nARA  := CRBTRANS->CREDIT
               else
                 aAdd(aSundry,{CRBTRANS->ACCT_CODE,CRBTRANS->DEBIT,;
                     CRBTRANS->CREDIT})
               endif
               CRBTRANS->(DbSkip())
            enddo
            ?? CRB->DATE + "  " + CRB->PASSENGER + "  "
            ?? CRB->VOUCHER_NO + "  "
            ?? blank(nCiBPCI,"999,999.99"), " "
            ?? blank(nCiBCBC,"999,999.99"), " "
            ?? blank(nART ,"999,999.99"), " "
            ?? blank(nPR ,"999,999.99"), " "
            ?? blank(nARA ,"999,999.99"), " "
            nTot_CibPCI += nCiBPCI
            nTot_CibCBC += nCiBCBC
            nTot_ART += nART
            nTot_PR  += nPR
            nTot_ARA += nARA
            if len(aSundry) >= 1
               CHART->(DbSeek(aSundry[1][1]))
               ?? substr(CHART->ACCT_TITLE,1,30)," "
               ?? blank(aSundry[1][2],"999,999.99")," "
               ?? blank(aSundry[1][3],"999,999.99")
               nTot_Sdr += aSundry[1][2]
               nTot_Scr += aSundry[1][3]
            endif
            ?
            if !empty(CRB->DETAILS_1) .or. (len(aSundry) >= 2)
               ?? space(9),CRB->DETAILS_1, space(73)
               if len(aSundry) >= 2
                  CHART->(DbSeek(aSundry[2][1]))
                  ?? substr(CHART->ACCT_TITLE,1,30)," "
                  ?? blank(aSundry[2][2],"999,999.99")," "
                  ?? blank(aSundry[2][3],"999,999.99")
                  nTot_Sdr += aSundry[2][2]
                  nTot_Scr += aSundry[2][3]
               endif
            endif
            ?
            if !empty(CRB->DETAILS_2) .or. (len(aSundry) >= 3)
               ?? space(9),CRB->DETAILS_2, space(73)
               if len(aSundry) >= 3
                  CHART->(DbSeek(aSundry[3][1]))
                  ?? substr(CHART->ACCT_TITLE,1,30)," "
                  ?? blank(aSundry[3][2],"999,999.99")," "
                  ?? blank(aSundry[3][3],"999,999.99")
                  nTot_Sdr += aSundry[3][2]
                  nTot_Scr += aSundry[3][3]
               endif
               ?
            endif
            if len(aSundry) > 3
               for x := 4 to len(aSundry)
                  CHART->(DbSeek(aSundry[x][1]))
                  ?? space(123),substr(CHART->ACCT_TITLE,1,30)," "
                  ?? blank(aSundry[x][2],"999,999.99")," "
                  ?? blank(aSundry[x][3],"999,999.99")
                  nTot_Sdr += aSundry[x][2]
                  nTot_Scr += aSundry[x][3]
                  ?
               next
            endif
         CRB->(DbSkip())
         enddo
         ?? repl('=',241)
         ?
         ?? "Totals ------>",space(49)
         ?? blank(nTot_CiBPCI,"999,999.99")," "
         ?? blank(nTot_CiBCBC,"999,999.99")," "
         ?? blank(nTot_ART,"999,999.99")," "
         ?? blank(nTot_PR ,"999,999.99")," "
         ?? blank(nTot_ARA,"999,999.99")," "
         ?? space(30)," "
         ?? blank(nTot_Sdr,"999,999.99")," "
         ?? blank(nTot_Scr,"999,999.99")," "
         eject
         Set(_SET_PRINTER,.F.)
         Set(_SET_CONSOLE,.T.)
         CRB->(DbCloseArea())
         CRBTRANS->(DbCloseArea())
         CHART->(DbCloseArea())
         Set(_SET_SOFTSEEK,.F.)
         Message("Printing Done...")
         Tone(300,1)
         inkey(2)
      else
         Message("Printer Not Ready...")
         Tone(100,3)
         inkey(2)
      endif
   endif
   return nil

function SB_Summary()
   store 0 to nTot_ART, nTot_ARA, nTot_Adv, nTot_Comm, nTot_SFee
   store 0 to nTot_UAT, nTot_APO, nTot_VAT, nTot_Deff, nTot_Cxln
   store 0 to nTot_Scr, nTot_Sdr
   if GetDates()
      if Isprinter()
         Set(_SET_SOFTSEEK,.T.)
         Set(_SET_CONSOLE,.F.)
         Set(_SET_PRINTER,.T.)
         Message("Thinking...")
         if NetUse("CHART",DB_SHARED,NUM_SECONDS)
            set index to CHT_ACCT
         endif
         if NetUse("SBTRANS",DB_SHARED,NUM_SECONDS)
            set index to SBTRANS
         endif
         if NetUse("SB",DB_SHARED,NUM_SECONDS)
            set index to SB_VNO
            set filter to ( ctod(date) >= dStartDate ) .and. ;
                          ( ctod(date) <= dEndDate )
            go top
         endif
         ?? chr(18)                        // Normal Size
         ?? chr(27)+chr(120)+chr(1)        // Turn NLQ on
         ?? chr(27)+chr(119)+chr(1)        // Turn Double-Height Mode ON.

         ?? "þSales Book Report"
         ?
         ?
         ?? "Period :",dStartDate,"to",dEndDate
         ?
         ?
         ?? chr(27)+chr(119)+chr(0)        // Turn Double-Height Mode OFF.
         ?? chr(15)                        // Select Condensed Mode.
         ?? space(63),"+- Accts. Receivble.-+   Advances   Commission   Service"
         ?? space(19),"A/P         VAT     Deffered      Cxln"
         ?? space(5),"+--------------- Sundry Accounts --------------------+"
         ?
         ?? "  Date              Passenger(s)                    "
         ?? "Bill No.      Travel     Airlines    for Pax      Income       "
         ?? "Fee          UAT        Others     Payable    Charges     "
         ?? "Charges           Account Title                Debit     Credit"
         ?? chr(27)+chr(120)+chr(0)        // Turn NLQ off
         ?
         ?
         do while SB->(!Eof())
            Message("Printing Rec#" + transform( SB->(RecNo()),"99999" ) )
            store 0 to nART, nARA, nAdv, nComm, nSFee
            store 0 to nUAT, nAPO, nVAT, nDeff, nCxln
            aSundry := {}
            SBTRANS->(DbSeek( SB->(RecNo()) ))
            do while SBTRANS->(!Eof()) .and. ;
               (SBTRANS->REC_NO == SB->(RecNo()))
               Message("Printing Record#"+transform(SB->(Recno()),"99999"))
               if SBTRANS->ACCT_CODE == "01-121"
                  nART := SBTRANS->DEBIT
               elseif SBTRANS->ACCT_CODE == "01-122"
                  nARA := SBTRANS->DEBIT
               elseif SBTRANS->ACCT_CODE == "01-142"
                  nAdv  := SBTRANS->CREDIT
               elseif SBTRANS->ACCT_CODE == "09-101"
                  nComm := SBTRANS->CREDIT
               elseif SBTRANS->ACCT_CODE == "09-103"
                  nSFee := SBTRANS->CREDIT
               elseif SBTRANS->ACCT_CODE == "01-123"
                  nUAT := SBTRANS->CREDIT
               elseif SBTRANS->ACCT_CODE == "04-131"
                  nAPO := SBTRANS->CREDIT
               elseif SBTRANS->ACCT_CODE == "04-1B1"
                  nVAT := SBTRANS->CREDIT
               elseif SBTRANS->ACCT_CODE == "03-131"
                  nDeff:= SBTRANS->DEBIT
               elseif SBTRANS->ACCT_CODE == "09-203"
                  nCxln:= SBTRANS->CREDIT
               else
                 aAdd(aSundry,{SBTRANS->ACCT_CODE,SBTRANS->DEBIT,;
                     SBTRANS->CREDIT})
               endif
               SBTRANS->(DbSkip())
            enddo
            ?? SB->DATE + "  " + SB->PASSENGER + "  "
            ?? SB->VOUCHER_NO + "  "
            ?? blank(nART,"999,999.99"), " "
            ?? blank(nARA,"999,999.99"), " "
            ?? blank(nAdv ,"999,999.99"), " "
            ?? blank(nComm,"999,999.99"), " "
            ?? blank(nSFee,"999,999.99"), " "
            ?? blank(nUAT,"999,999.99"), " "
            ?? blank(nAPO,"999,999.99"), " "
            ?? blank(nVAT ,"999,999.99"), " "
            ?? blank(nDeff,"999,999.99"), " "
            ?? blank(nCxln,"999,999.99"), " "
            nTot_ART += nART
            nTot_ARA += nARA
            nTot_Adv += nAdv
            nTot_Comm+= nComm
            nTot_SFee+= nSFee
            nTot_UAT += nUAT
            nTot_APO += nAPO
            nTot_VAT += nVAT
            nTot_Deff+= nDeff
            nTot_Cxln+= nCxln
            if len(aSundry) >= 1
               CHART->(DbSeek(aSundry[1][1]))
               ?? substr(CHART->ACCT_TITLE,1,30)," "
               ?? blank(aSundry[1][2],"999,999.99")," "
               ?? blank(aSundry[1][3],"999,999.99")
               nTot_Sdr += aSundry[1][2]
               nTot_Scr += aSundry[1][3]
            endif
            ?
            if !empty(SB->DETAILS_1) .or. (len(aSundry) >= 2)
               ?? space(9),SB->DETAILS_1, space(73)
               if len(aSundry) >= 2
                  CHART->(DbSeek(aSundry[2][1]))
                  ?? substr(CHART->ACCT_TITLE,1,30)," "
                  ?? blank(aSundry[2][2],"999,999.99")," "
                  ?? blank(aSundry[2][3],"999,999.99")
                  nTot_Sdr += aSundry[2][2]
                  nTot_Scr += aSundry[2][3]
               endif
            endif
            ?
            if !empty(SB->DETAILS_2) .or. (len(aSundry) >= 3)
               ?? space(9),SB->DETAILS_2, space(73)
               if len(aSundry) >= 3
                  CHART->(DbSeek(aSundry[3][1]))
                  ?? substr(CHART->ACCT_TITLE,1,30)," "
                  ?? blank(aSundry[3][2],"999,999.99")," "
                  ?? blank(aSundry[3][3],"999,999.99")
                  nTot_Sdr += aSundry[3][2]
                  nTot_Scr += aSundry[3][3]
               endif
               ?
            endif
            if len(aSundry) > 3
               for x := 4 to len(aSundry)
                  CHART->(DbSeek(aSundry[x][1]))
                  ?? space(123),substr(CHART->ACCT_TITLE,1,30)," "
                  ?? blank(aSundry[x][2],"999,999.99")," "
                  ?? blank(aSundry[x][3],"999,999.99")
                  nTot_Sdr += aSundry[x][2]
                  nTot_Scr += aSundry[x][3]
                  ?
               next
            endif
            SB->(DbSkip())
         enddo
         ?? repl('=',241)
         ?
         ?? "Totals ------>",space(49)
         ?? blank(nTot_ART,"999,999.99"), " "
         ?? blank(nTot_ARA,"999,999.99"), " "
         ?? blank(nTot_Adv ,"999,999.99"), " "
         ?? blank(nTot_Comm,"999,999.99"), " "
         ?? blank(nTot_SFee,"999,999.99"), " "
         ?? blank(nTot_UAT,"999,999.99"), " "
         ?? blank(nTot_APO,"999,999.99"), " "
         ?? blank(nTot_VAT ,"999,999.99"), " "
         ?? blank(nTot_Deff,"999,999.99"), " "
         ?? blank(nTot_Cxln,"999,999.99"), " "
         ?? space(30)," "
         ?? blank(nTot_Sdr,"999,999.99")," "
         ?? blank(nTot_Scr,"999,999.99")," "
         eject
         Set(_SET_PRINTER,.F.)
         Set(_SET_CONSOLE,.T.)
         SB->(DbCloseArea())
         SBTRANS->(DbCloseArea())
         CHART->(DbCloseArea())
         Set(_SET_SOFTSEEK,.F.)
         Message("Printing Done...")
         Tone(300,1)
         inkey(2)
      else
         Message("Printer Not Ready...")
         Tone(100,3)
         inkey(2)
      endif
   endif
   return nil

function JV_Summary()
   store 0 to nCredit, nDebit
   if GetDates()
      if Isprinter()
         Set(_SET_SOFTSEEK,.T.)
         Set(_SET_CONSOLE,.F.)
         Set(_SET_PRINTER,.T.)
         Message("Thinking...")
         if NetUse("CHART",DB_SHARED,NUM_SECONDS)
            set index to CHT_ACCT
         endif
         if NetUse("JVTRANS",DB_SHARED,NUM_SECONDS)
            set index to JVTRANS
         endif
         if NetUse("JV",DB_SHARED,NUM_SECONDS)
            set index to JV_VNO
            set filter to ( ctod(date) >= dStartDate ) .and. ;
                          ( ctod(date) <= dEndDate )
            go top
         endif
         ? "þJournal Voucher Report"
         ? "Period :",dStartDate,"to",dEndDate
         ? "Date              Passenger(s)                       Voucher No."+;
           "              Account Title               Debit         Credit"
         ?
         do while JV->(!Eof())
            Message("Printing Rec#" + transform( JV->(RecNo()),"99999" ) )
            aItems:={}
            JVTRANS->(DbSeek( JV->(RecNo()) ))
            do while JVTRANS->(!Eof()) .and. ;
               (JVTRANS->REC_NO == JV->(RecNo()))
               aAdd(aItems,{JVTRANS->ACCT_CODE,JVTRANS->DEBIT,JVTRANS->CREDIT})
               nCredit += JVTRANS->CREDIT
               nDebit  += JVTRANS->DEBIT
               JVTRANS->(DbSkip())
            enddo
            ? JV->DATE," ",JV->PASSENGER," ",JV->VOUCHER_NO," "
            for x:=1 to if(len(aItems)>2,len(aItems),4)
                if x==1  ;  ?? space(2)
                elseif x==2  ;  ? space(10),JV->DETAILS_1,space(16)
                elseif x==3  ;  ? space(10),JV->DETAILS_2,space(16)
                elseif x==4  ;  ? space(10),JV->DETAILS_3,space(16)
                else  ;  ? space(68)  ; endif
                if x<=len(aItems)
                   CHART->(DbSeek(aItems[x][1]))
                   ?? substr(CHART->ACCT_TITLE,1,30)," "
                   ?? blank(aItems[x][2],"999,999.99"," ")
                   ?? blank(aItems[x][3],"999,999.99")
                endif
            next
            JV->(DbSkip())
         enddo
         ? repl('=',125)
         ? "Totals ------>", space(83)
         ?? blank(nDebit ,"999,999.99"," ")
         ?? blank(nCredit,"999,999.99")
         Set(_SET_PRINTER,.F.)
         Set(_SET_CONSOLE,.T.)
         JV->(DbCloseArea())
         JVTRANS->(DbCloseArea())
         CHART->(DbCloseArea())
         Set(_SET_SOFTSEEK,.F.)
         Message("Printing Done...")
         Tone(300,1)
         inkey(2)
      else
         Message("Printer Not Ready...")
         Tone(100,3)
         inkey(2)
      endif
   endif
return nil

function PCV_Summary()
   store 0 to nDebit
   if GetDates()
      if Isprinter()
         Set(_SET_SOFTSEEK,.T.)
         Set(_SET_CONSOLE,.F.)
         Set(_SET_PRINTER,.T.)
         Message("Thinking...")
         if NetUse("CHART",DB_SHARED,NUM_SECONDS)
            set index to CHT_ACCT
         endif
         if NetUse("PCVTRANS",DB_SHARED,NUM_SECONDS)
            set index to PCVTRANS
         endif
         if NetUse("PCV",DB_SHARED,NUM_SECONDS)
            set index to PCV_VNO
            set filter to ( ctod(date) >= dStartDate ) .and. ;
                          ( ctod(date) <= dEndDate )
            go top
         endif
         ? "þPetty Cash Voucher Report"
         ? "Period :",dStartDate,"to",dEndDate
         ? "Date              Passenger(s)                       Voucher No."+;
           "              Account Title               Debit         Credit"
         ?
         do while PCV->(!Eof())
            Message("Printing Rec#" + transform( PCV->(RecNo()),"99999" ) )
            aItems:={}
            PCVTRANS->(DbSeek( PCV->(RecNo()) ))
            do while PCVTRANS->(!Eof()) .and. ;
               (PCVTRANS->REC_NO == PCV->(RecNo()))
               aAdd(aItems,{PCVTRANS->ACCT_CODE,PCVTRANS->DEBIT})
               nDebit  += PCVTRANS->DEBIT
               PCVTRANS->(DbSkip())
            enddo
            ? PCV->DATE," ",PCV->PARTICULAR," ",PCV->VOUCHER_NO," "
            for x:=1 to if(len(aItems)>2,len(aItems),4)
                if x==1  ;  ?? space(2)
                elseif x==2  ;  ? space(10),PCV->DETAILS_1,space(16)
                elseif x==3  ;  ? space(10),PCV->DETAILS_2,space(16)
                elseif x==4  ;  ? space(10),PCV->DETAILS_3,space(16)
                else  ;  ? space(68)  ; endif
                if x<=len(aItems)
                   CHART->(DbSeek(aItems[x][1]))
                   ?? substr(CHART->ACCT_TITLE,1,30)," "
                   ?? blank(aItems[x][2],"999,999.99")
                endif
            next
            PCV->(DbSkip())
         enddo
         ? repl('=',125)
         ? "Totals ------>", space(83)
         ?? blank(nDebit,"999,999.99")
         Set(_SET_PRINTER,.F.)
         Set(_SET_CONSOLE,.T.)
         PCV->(DbCloseArea())
         PCVTRANS->(DbCloseArea())
         CHART->(DbCloseArea())
         Set(_SET_SOFTSEEK,.F.)
         Message("Printing Done...")
         Tone(300,1)
         inkey(2)
      else
         Message("Printer Not Ready...")
         Tone(100,3)
         inkey(2)
      endif
   endif
return nil

static function GetDateCode()
local wDate
   dStartDate:=dEndDate:=CToD("  /  /  ")
   mAcctCode:=Space(6)
   set key K_F1 to ChartLookUp()
   Message("Enter dates to cover report...")
   wDate:=OpenWindow(09,15,14,63,"Date Information Box")
   @ 11,17 say "Enter starting date (mm-dd-yy format)" get dStartDate
   @ 12,17 say "        Ending date (mm-dd-yy format)" get dEndDate
   @ 13,17 say "Account Code (Press F1 to list codes)" get mAcctCode
   SetCursor(SC_NORMAL)
   read
   SetCursor(SC_NONE)
   CloseWindow(wDate)
   set key K_F1 to
return If(LastKey()==K_ESC,.F.,.T.)

static function GetDates()
local wDate
   dStartDate:=dEndDate:=CToD("")
   Message("Enter dates to cover report...")
   wDate:=OpenWindow(09,15,13,63,"Date Information Box")
   @ 11,17 say "Enter starting date (mm-dd-yy format)" get dStartDate
   @ 12,17 say "        Ending date (mm-dd-yy format)" get dEndDate
   SetCursor(SC_NORMAL)
   read
   SetCursor(SC_NONE)
   CloseWindow(wDate)
return If(LastKey()==K_ESC,.F.,.T.)

static function blank(v,c)
return if(v=0,space(len(c)),transform(v,c))