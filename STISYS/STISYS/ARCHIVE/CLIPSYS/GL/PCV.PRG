// Filename:      PCV.PRG
// Author:        Arnold P. Caoile
// Module:        Petty Cash Vouchers
// Date-Started:  April 02, 1992
// Updated By:    Rollie C. Ibarra Jr.
// Last-Update:   June 26, 1992/June 9,1993

#include "Inkey.ch"
#include "Setcurs.ch"
#include "Mode.ch"
#include "Help.ch"

#define PCV_BAR "F2-Add  F3-Edit  F4-Delete  F5-Search  "+;
   "F6-Totals  F9-Update  Esc-Abort"

static mVoucherNo,mDate,mParticular,mDetails1,mDetails2,mDetails3,mDetails4
static aPicture

function PCV()
local wPCV,nKey
   Message("Opening Databases....")
   if NetUse("CHART",DB_SHARED,NUM_SECONDS)
      set index to CHT_CODE,CHART,CHT_ACCT
   endif
   if NetUse("PCVTRANS",DB_SHARED,NUM_SECONDS)
      set index to PCVTRANS
   endif
   if NetUse("PCV",DB_SHARED,NUM_SECONDS)
      set index to PCV_VNO,PCV_DATE,PCV_NAME
   endif
   aPicture:=Array(4,2)
   aPicture[1][1]:="PCVTRANS->REC_NO"
   aPicture[1][2]:="@!"
   aPicture[2][1]:="PCVTRANS->ACCT_CODE"
   aPicture[2][2]:=Replicate("X",6)
   aPicture[3][1]:="PCVTRANS->DEBIT"
   aPicture[3][2]:="9,999,999.99"
   aPicture[4][1]:="PCVTRANS->CREDIT"
   aPicture[4][2]:="9,999,999.99"
   wPCV:=OpenWindow(03,08,12,66,"Petty Cash Voucher")
   if PCV->(RecCount())==0 ; PCVScreen(APPEND_MODE) ; endif
   if LastKey()!=K_ESC
      do while (nKey!=K_ESC)
         PCVScreen(VIEW_MODE)
         nKey:=Inkey(0)
         do case
            case nKey==K_DOWN
               PCV->(DbSkip())
               if PCV->(Eof())
                  PCV->(DbGoBottom())
                  Tone(100,3)
                  Tone(100,3)
                  Message("End of file reached....")
                  Inkey(1)
               endif
            case nKey==K_UP
               PCV->(DbSkip(-1))
               if PCV->(Bof())
                  PCV->(DbGoTop())
                  Tone(100,3)
                  Message("Beginning of file reached....")
                  Inkey(1)
               endif
            case nKey==K_END
               PCV->(DbGoBottom())
                  Message("Moving to end of file....")
                  Inkey(1)
            case nKey==K_CTRL_PGDN
               PCV->(DbSkip(NUM_TO_SKIP))
               if PCV->(Eof())
                  PCV->(DbGoBottom())
                  Tone(100,3)
                  Message("End of file reached....")
                  Inkey(1)
               endif
            case nKey==K_CTRL_PGUP
               PCV->(DbSkip(-NUM_TO_SKIP))
               if PCV->(Bof())
                  PCV->(DbGoTop())
                  Tone(100,3)
                  Message("Beginning of file reached....")
                  Inkey(1)
               endif
            case nKey==K_HOME
               PCV->(DbGoTop())
                  Message("Moving to beginning of file....")
                  Inkey(1)
            case nKey==K_PGDN
               PCVTRANS->(ABrowse(PCV->(RecNo()),VIEW_MODE,aPicture,H_PCV))
            case nKey==K_F1
               GetHelp(H_PCV)
            case nKey==K_F2
               Message("Press ENTER to add new record.")
               inkey(0)
               if LastKey()==K_ENTER
                  PCVScreen(APPEND_MODE)
               endif
            case nKey==K_F3
               PCVScreen(EDIT_MODE)
            case nKey==K_F4
               Message("Press ENTER to delete record, ESC to abort.")
               nDel:=0
               do while (nDel!=K_ENTER) .and. (nDel!=K_ESC)
                  nDel:=Inkey(0)
               enddo
               if nDel==K_ENTER
                  Message("Deleting current record....")
                  PCV->(FilLock(0))
                  PCV->(DbDelete())
                  PCV->(DbUnlock())
                  PCVTRANS->(DbSeek(PCV->(RecNo())))
                  do while PCVTRANS->REC_NO==PCV->(RecNo())
                     PCVTRANS->(FilLock(0))
                     PCVTRANS->(DbDelete())
                     PCVTRANS->(DbUnlock())
                     PCVTRANS->(DbSkip())
                  enddo
               endif
            case nKey==K_F5
               SearchPax()
            case nKey==K_F6
               GetSummary()
            case nKey==K_F9
               Message("Press ENTER to update subsidiary ...")
               inkey(0)
               if LastKey()==K_ENTER
                  Update()
               endif
            case nKey==K_F10
               Message("Press ENTER to Reindex databeses ...")
               inkey(0)
               if Lastkey()==K_ENTER
                  Message("Reindexing, this may take FOREVER...")
                 PCV->(DbReindex())
                 endif
         endcase
      enddo
   endif
   Message("Closing Databases....")
   PCV->(DbCloseArea())
   PCVTRANS->(DbCloseArea())
   CHART->(DbCloseArea())
   CloseWindow(wPCV)
return nil

static function PCVScreen(nMode)
local cColor,nArea,lNewRec, nAdd:=nUpd:=0
   Tone(300,1)
   InitVariables(nMode)
   Message(PCV_BAR)
   cColor:=SetColor("N/BG")
   if PCV->(Deleted()) ; @ 03,35 say "<deleted>"
   else ; @ 03,35 say "         " ; endif
   @ 03,54 say "Rec. #" + ;
   Transform(If(nMode==APPEND_MODE,PCV->(RecCount()+1),PCV->(RecNo())),"99999")
   SetColor(cColor)
   @ 05,10 say "  Voucher No." get mVoucherNo picture "@!"
   @ 06,10 say "         Date" get mDate picture "@D"
   @ 07,10 say "  Particulars" get mParticular picture "@!"
   @ 08,10 say "Other Details" get mDetails1
   @ 09,10 say "             " get mDetails2
   @ 10,10 say "             " get mDetails3
   @ 11,10 say "             " get mDetails4
   if (nMode==APPEND_MODE) .or. (nMode==EDIT_MODE)
      Message("Esc-Abort")
      SetCursor(SC_NORMAL)
      read
      if LastKey()!=K_ESC
         if nMode==APPEND_MODE
            PCV->(AddRec(0))
         endif
         if Updated()
            /* Replace current record with new entry. */
            PCV->(FilLock(0))
            PCV->VOUCHER_NO:=mVoucherNo
            PCV->DATE:=DToC(mDate)
            PCV->PARTICULAR:=mParticular
            PCV->DETAILS_1:=mDetails1
            PCV->DETAILS_2:=mDetails2
            PCV->DETAILS_3:=mDetails3
            PCV->DETAILS_4:=mDetails4
            PCV->(DbCommit())
            PCV->(DbUnlock())
         endif
         PCVTRANS->(ABrowse(PCV->(RecNo()),nMode,aPicture,H_PCV))
         SetCursor(SC_NONE)
      endif
   else
      clear gets
   endif
   SetCursor(SC_NONE)
return nil

static function InitVariables(nMode)
   if (nMode==APPEND_MODE)
      mVoucherNo=Space(10)
      mDate:=CToD("  /  /  ")
      mParticular:=Space(40)
      mDetails1:=Space(40)
      mDetails2:=Space(40)
      mDetails3:=Space(40)
      mDetails4:=Space(40)
   else
      mVoucherNo:=PCV->VOUCHER_NO
      mDate:=CToD(PCV->DATE)
      mParticular:=PCV->PARTICULAR
      mDetails1:=PCV->DETAILS_1
      mDetails2:=PCV->DETAILS_2
      mDetails3:=PCV->DETAILS_3
      mDetails4:=PCV->DETAILS_4
   endif
   mAirline:=space(35)
return nil

static function SearchPax()
local nRecNo,wSearch,nKey,cName:=Space(40)
   nRecNo:=PCV->(RecNo())
   wSearch:=OpenWindow(06,18,10,61,"Search Mode")
   @ 08,20 say "Enter name to search"
   @ 09,20 get cName picture "@!"
   SetCursor(SC_NORMAL)
   read
   cName:=Alltrim(cName)
   CloseWindow(wSearch)
   SetCursor(SC_NONE)
   if LastKey()!=K_ESC
      PCV->(DbSetOrder(3))
      PCV->(DbSeek(cName))
      if PCV->(Found())
         do while (cName==substr(upper(PCV->PARTICULAR),1,len(cName))) .and. (nKey!=K_ESC)
            PCVScreen(VIEW_MODE)
            Message("Press ENTER to continue search, ESC to abort....")
            nKey:=0
            do while (nkey!=K_ENTER) .and. (nKey!=K_ESC)
               nKey:=Inkey(0)
            enddo
            if nKey==K_ENTER ; PCV->(DbSkip()) ; endif
        enddo
      else
        Message("Name not found ... Press ENTER to search Firstnames")
        nKey:= inkey(0)
        PCV->(DbGoBottom())
        do while (PCV->(!BOF())) .and. (nKey!=K_ESC) .and. nextKey()!=K_ESC
          Message("Searching for "+cName+", this may take TIME..."+space(abs(29-len(cName)))+"ESC to abort")
          do while !(cName $ (PCV->PARTICULAR)) .and. PCV->(!BOF()) .and. nextkey()!=K_ESC
            PCV->(DbSkip(-1))
          enddo
          if  (cName $ (PCV->PARTICULAR))
            PCVScreen(VIEW_MODE)
            Message("Press ENTER to continue search, ESC to abort ...")
            nkey:=0
            do while (nKey!=K_ENTER) .and. (nkey!=K_ESC)
              nKey:=Inkey(0)
            enddo
            if nkey==K_ENTER; PCV->(DbSkip(-1)); endif
          endif
        enddo
         if PCV->(BOF()) .or. (PCV->(!Found()) .and. nKey==K_ENTER)
          Tone(150,2)
          Message("Name not found....")
          PCV->(DbGoTo(nRecNo))
          Inkey(1.5)
         endif
      endif
      PCV->(DbSetOrder(1))
   endif
return nil

static function GetSummary()
local n1,n2,aChart:={},aAccounts:={},nSaveRecNo:=PCV->(RecNo())
local nDebit:=nCredit:=0.00,accountFound:=.F.
local wReport,mReport
   /* Get transaction dates . */
   if GetDates()
      Message("Thinking....")
      /* Index CHART by ACCT_TITLE. */
      CHART->(DbSetOrder(2))
      CHART->(DbGoTop())
      /* Load account codes in Account array lookup. */
      do while CHART->(!Eof())
         aAdd(aChart,CHART->ACCT_CODE)
         aAdd(aAccounts,{0.00,0.00})
         CHART->(DbSKip())
      enddo
      /* Index CHART by ACCT_CODE. */
      CHART->(DbSetOrder(3))
      /* Index PCV by DATE. */
      PCV->(DbSetOrder(2))
      PCV->(DbSeek(SubStr(DToC(dStartDate),7,2)+"-"+ ;
                   SubStr(DToC(dStartDate),1,2) ))
      if PCV->(Found())
         /* Find for requested start date */
         do while (PCV->(!Eof())) .and. (CToD(PCV->DATE)<dStartDate)
              PCV->(DbSkip());  enddo
         /* Read PCV file, check if record is within transaction dates. */
         do while (PCV->(!Eof())) .and. (CToD(PCV->DATE)<=dEndDate)
            /* Read all transactions of current PCV record. */
            PCVTRANS->(DbSeek(PCV->(RecNo())))
            Message("Searching Petty Cash Vouchers (rec #"+ ;
                Transform(PCV->(RecNo()),"999999")+")....")
            do while PCVTRANS->REC_NO==PCV->(RecNo())
               /* Accounts array lookup. */
               n1:=aScan(aChart,PCVTRANS->ACCT_CODE)
               /* Increment totals. */
               if n1>0
                  aAccounts[n1][A_DEBIT]:=aAccounts[n1][A_DEBIT] + ;
                     PCVTRANS->DEBIT
                  nDebit:=nDebit+PCVTRANS->DEBIT
                  aAccounts[n1][A_CREDIT]:=aAccounts[n1][A_CREDIT] + ;
                     PCVTRANS->CREDIT
                  nCredit:=nCredit+PCVTRANS->CREDIT
               endif
               PCVTRANS->(DbSkip())
            enddo
            PCV->(DbSkip())
         enddo
      endif
      PCV->(DbSetOrder(1))
      PCV->(DbGoTo(nSaveRecNo))
      /* Prepare PCV Summary report. */
      Message("Preparing PCV Summary Report....")
      Set(_SET_CONSOLE,.F.)
      Set(_SET_ALTFILE,"PCVSUM.RPT")
      Set(_SET_ALTERNATE,.T.)
      ? "þPetty Cash Vouchers - Summary Totals"
      ? "Period: "+CMonth(dEndDate)+" "+;
         Transform(Year(dEndDate),"9999")
      ?
      ? Space(5),"Account Title"+Space(51)+"Debit         Credit"
      ?
      for n:=1 to Len(aAccounts)
         if (aAccounts[n][A_DEBIT]!=0.00) .or. (aAccounts[n][A_CREDIT]!=0.00)
            CHART->(DbSeek(aChart[n]))
            ? CHART->ACCT_TITLE,Space(2)
            ?? Transform(aAccounts[n][A_DEBIT], "9,999,999.99"),Space(2)
            ?? Transform(aAccounts[n][A_CREDIT],"9,999,999.99")
         endif
      next
      ? Replicate("-",90)
      ? "Totals  ---->",Space(49)
      ?? Transform(nDebit, "9,999,999.99"),Space(2)
      ?? Transform(nCredit,"9,999,999.99")
      Set(_SET_CONSOLE,.T.)
      Set(_SET_ALTFILE,"")
      Set(_SET_ALTERNATE,.F.)
      close alternate
      /* Display report on screen (scrolling window). */
      cReport:=MemoRead("PCVSUM.RPT")
      Message("Use cursor keys to navigate, press F10 to print, Esc to abort.")
      SetCursor(SC_NORMAL)
      wReport:=OpenWindow(3,1,21,77,"Petty Cash Vouchers - Summary Totals")
      nLFactor:=2
      MemoEdit(cReport,4,2,20,76,.F.,"EditorFunc",90)
      nLFactor:=1
      CloseWindow(wReport)
      SetCursor(SC_NONE)
   endif
return nil

static function PcvReport()
local wReport,nSaveRecNo
   wReport:=OpenWindow(03,01,21,77,"Petty Cash Vouchers")
   @ 05,03 say "  Date     PCV No.                  Particulars                  Amount   "
   @ 06,03 say ""
   nSaveRecNo:=PCV->(RecNo())
   PCV->(DbGoTop())
   do while PCV->(!Eof())
      if (DToC(PCV->DATE)>=DToC(dStartDate)) .and. ;
         (DToC(PCV->DATE)<=DToC(dEndDate))
         @ Row()+1,03 say DToC(PCV->DATE)+" "+PCV->VOUCHER_NO+" "+;
            PCV->PARTICULAR
      endif
      PCV->(DbSkip())
   enddo
   Inkey(0)
   CloseWindow(wReport)
   PCV->(DbGoTo(nSaveRecNo))
return nil

static function Update()
local nSaveRec := PCV->(RecNo()), cKey, x
local lNewRec, nDadd:= nTadd:=0
   if GetDateCode() .and. (aScan(aLedgerCode,mAcctCode)!=0)
      x:=AScan(aLedgerCode,mAcctCode)
      if (mAcctCode=="01-121") .or. ;
         (mAcctCode=="04-181") .or. ;
         (mAcctCode=="04-171")
         Message("Type [A] for Agency Ledger, other key for Individual Ledger")
         inkey(0)
         Message("")
         if LastKey()==asc("A")
            cDbfName:=aLedgerName[x]+"A"     // Agency Ledger
         else
            cDbfName:=aLedgerName[x]+"I"     // Individual Ledger
         endif
      else
         cDbfName:=aLedgerName[x]
      endif
      cTransName:=cDbfName+"TRAN"
      if (cDbfName=="ARA") .or. (cDbfName=="ARTA") .or. ;
         (cDbfName=="PRA")
         if NetUse(cDbfName,DB_SHARED,NUM_SECONDS)
            set index to &cDbfName,&(cDbfName+"_AIR")
            set order to 2
         endif
         if(cDbfName=="ARA",xFmode:=1,xFmode:=2) 
      else
         if NetUse(cDbfName,DB_SHARED,NUM_SECONDS)
            set index to &cDbfName
         endif
         xFmode:=3
      endif
      nDbfArea:=Select()
      if NetUse(cTransName,DB_SHARED,NUM_SECONDS)
         set index to &cTransName
      endif
      nTransArea:=Select()
      PCV->(DbSetOrder(2))
      if PCV->(DbSeek(SubStr(DToC(dStartDate),7,2)+"-"+ ;
                     SubStr(DToC(dStartDate),1,2) ))
         do while (PCV->(!Eof())) .and. (CTOD(PCV->DATE)<dStartDate)
              PCV->(DbSkip())
         enddo
         do while (PCV->(!Eof())) .and. (CTOD(PCV->DATE)<=dEndDate)
            Message("Updating Subsidiary from Petty Cash Voucher rec #"+;
                    transform(PCV->(Recno()),"9999") )
            PCVTRANS->(DbSeek(PCV->(RecNo())))
            do while PCVTRANS->REC_NO==PCV->(RecNo())  
                if (mAcctCode==PCVTRANS->ACCT_CODE)
                   lNewRec:=.F.
                   do case 
                      case xFmode==1
                         AIRLINE->(DbSeek(PCV->AIR_CODE))
                         cKey:=substr(AIRLINE->AIRLINE,1,10)+upper(PCV->PARTICULAR)
                      case xFmode==2
                         cKey:=space(20)+upper(PCV->PARTICULAR)
                      case xFmode==3
                         cKey:=upper(PCV->PARTICULAR)
                   endcase
                   if (nDbfArea)->(!DbSeek(cKey))
                      (nDbfArea)->(AddRec(0))   ; nDadd++
                      (nDbfArea)->(FilLock(0))
                      (nDbfArea)->PARTICULAR:=upper(PCV->PARTICULAR)
                      (nDbfArea)->DATE:=PCV->DATE
                      (nDbfArea)->(DbUnlock())
                   endif
                   if ctod((nDbfArea)->DATE) > ctod(PCV->DATE)
                      (nDbfArea)->(FilLock())
                      (nDbfArea)->DATE := PCV->DATE
                      (nDbfArea)->(DbUnlock())
                   endif
                   if (nTransArea)->(!DbSeek((nDbfArea)->(RecNo())))
                      lNewRec:=.T.
                   else
                      do while ((nTransArea)->FOLIO!=PCV->VOUCHER_NO) .and. ;
                               ((nTransArea)->REC_NO==(nDbfArea)->(RecNo())) .and. ;
                               (nTransArea)->(!Eof())
                         (nTransArea)->(DbSkip())
                      enddo
                      if ((nTransArea)->FOLIO!=PCV->VOUCHER_NO) .or. ;
                         ((nTransArea)->REC_NO!=(nDbfArea)->(RecNo()))
                         lNewRec:=.T.
                      endif
                   endif
                   if lNewRec
                      (nTransArea)->(AddRec(0))  ; nTadd ++
                      (nTransArea)->(FilLock(0))
                      (nTransArea)->REC_NO := (nDbfArea)->(RecNo())
                      (nTransArea)->FOLIO := PCV->VOUCHER_NO
                      (nTransArea)->(DbUnlock())
                   endif
                   if ( (nTransArea)->REC_NO==(nDbfArea)->(RecNo()) )  .and.  ;
                      ( (nTransArea)->FOLIO==PCV->VOUCHER_NO)
                      (nTransArea)->(FilLock(0))
                      (nTransArea)->DATE:=PCV->DATE
                      (nTransArea)->DEBIT:=PCVTRANS->DEBIT
                      (nTransArea)->CREDIT:=PCVTRANS->CREDIT
                      (nTransArea)->DETAILS_1:=PCV->DETAILS_1
                      (nTransArea)->DETAILS_2:=PCV->DETAILS_2
                      (nTransArea)->(DbUnlock())
                   endif
                endif
                PCVTRANS->(DbSkip())
            enddo
           PCV->(DbSkip())
        enddo
      endif
      (nTransArea)->(DbCloseArea())
      (nDbfArea)->(DbCloseArea())
      PCV->(DbGoto(nSaveRec))    
      PCV->(DbSetOrder(1))
      Message("Status Report :  Added "+transform(nDadd,"99")+;
            " Entry,  "+transform(nTadd,"99")+" Transactions.")
      inkey(2)
   endif
return nil
// end-of-file