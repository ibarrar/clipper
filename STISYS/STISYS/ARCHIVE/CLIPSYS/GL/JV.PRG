// Filename:      JV.PRG
// Author:        Arnold P. Caoile
// Module:        Journal Vouchers
// Date-Started:  April 08, 1992
// Updated By:    Rollie C. Ibarra Jr.
// Last-Update:   June 26, 1992

#include "Inkey.ch"
#include "Setcurs.ch"
#include "Mode.ch"
#include "Help.ch"

#define JV_BAR "F2-Add  F3-Edit  F4-Delete  F5-Search  "+;
   "F6-Totals  F9-Update  Esc-Abort"

static mVoucherNo,mDate,mPassenger,mDetails1,mDetails2,mDetails3,aPicture

function JV()
local wJV,nKey
   Message("Opening Databases....")
   if NetUse("AIRLINE",DB_SHARED,NUM_SECONDS)
      set index to AIR_CODE,AIRLINE
   endif
   if NetUse("AGENCY",DB_SHARED,NUM_SECONDS)
      set index to AGENCY
   endif
   if NetUse("CHART",DB_SHARED,NUM_SECONDS)
      set index to CHT_CODE,CHART,CHT_ACCT
   endif
   if NetUse("JVTRANS",DB_SHARED,NUM_SECONDS)
      set index to JVTRANS
   endif
   if NetUse("JV",DB_SHARED,NUM_SECONDS)
      set index to JV_VNO,JV_DATE,JV_NAME
   endif
   aPicture:=Array(4,2)
   aPicture[1][1]:="JVTRANS->REC_NO"
   aPicture[1][2]:="@!"
   aPicture[2][1]:="JVTRANS->ACCT_CODE"
   aPicture[2][2]:=Replicate("X",6)
   aPicture[3][1]:="JVTRANS->DEBIT"
   aPicture[3][2]:="9,999,999.99"
   aPicture[4][1]:="JVTRANS->CREDIT"
   aPicture[4][2]:="9,999,999.99"
   wJV:=OpenWindow(03,08,13,66,"Journal Voucher")
   if JV->(RecCount())==0 ; JVScreen(APPEND_MODE) ; endif
   if LastKey()!=K_ESC
      do while (nKey!=K_ESC)
         JVScreen(VIEW_MODE)
         nKey:=Inkey(0)
         do case
            case nKey==K_DOWN
               JV->(DbSkip())
               if JV->(Eof())
                  JV->(DbGoBottom())
                  Tone(100,3)
                  Message("End of file reached....")
                  Inkey(1)
               endif
            case nKey==K_UP
               JV->(DbSkip(-1))
               if JV->(Bof())
                  JV->(DbGoTop())
                  Tone(100,3)
                  Message("Beginning of file reached....")
                  Inkey(1)
               endif
            case nKey==K_END
               JV->(DbGoBottom())
                  Message("Moving to end of file....")
                  Inkey(1)
            case nKey==K_CTRL_PGDN
               JV->(DbSkip(NUM_TO_SKIP))
               if JV->(Eof())
                  JV->(DbGoBottom())
                  Tone(100,3)
                  Message("End of file reached....")
                  Inkey(1)
               endif
            case nKey==K_CTRL_PGUP
               JV->(DbSkip(-NUM_TO_SKIP))
               if JV->(Bof())
                  JV->(DbGoTop())
                  Tone(100,3)
                  Message("Beginning of file reached....")
                  Inkey(1)
               endif
            case nKey==K_HOME
               JV->(DbGoTop())
                  Message("Moving to beginning of file....")
                  Inkey(1)
            case nKey==K_PGDN
               JVTRANS->(ABrowse(JV->(RecNo()),VIEW_MODE,aPicture,H_JV))
            case nKey==K_F1
               GetHelp(H_JV)
            case nKey==K_F2
               Message("Press ENTER to add new record.")
               inkey(0)
               if LastKey()==K_ENTER
                  JVScreen(APPEND_MODE)
               endif
            case nKey==K_F3
               JVScreen(EDIT_MODE)
            case nKey==K_F4
               Message("Press ENTER to delete record, ESC to abort.")
               nDel:=0
               do while (nDel!=K_ENTER) .and. (nDel!=K_ESC)
                  nDel:=Inkey(0)
               enddo
               if nDel==K_ENTER
                  Message("Deleting current record....")
                  JV->(FilLock(0))
                  JV->(DbDelete())
                  JV->(DbUnlock())
                  JVTRANS->(DbSeek(JV->(RecNo())))
                  do while JVTRANS->REC_NO==JV->(RecNo())
                     JVTRANS->(FilLock(0))
                     JVTRANS->(DbDelete())
                     JVTRANS->(DbUnlock())
                     JVTRANS->(DbSkip())
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
               Message("Press ENTER to Reindex databases ...")
               inkey(0)
               if Lastkey()==K_ENTER
                  Message("Reindexing, this may take FOREVER...")
                  JV->(DbReindex())
               endif
         endcase
      enddo
   endif
   Message("Close Databases....")
   JV->(DbCloseArea())
   JVTRANS->(DbCloseArea())
   CHART->(DbCloseArea())
   AGENCY->(DbCloseArea())
   AIRLINE->(DbCloseArea())
   CloseWindow(wJV)
return nil

static function JVScreen(nMode)
local nArea,cColor,mAirline:=Space(35),lNewRec, nAdd:=nUpd:=0
   Tone(300,1)
   InitVariables(nMode)
   Message(JV_BAR)
   cColor:=SetColor("N/BG")
   if JV->(Deleted()) ; @ 03,35 say "<deleted>"
   else ; @ 03,35 say "         " ; endif
   @ 03,54 say "Rec. #" + ;
   Transform(If(nMode==APPEND_MODE,JV->(RecCount()+1),JV->(RecNo())),"99999")
   SetColor(cColor)
   @ 05,10 say "  Voucher No." get mVoucherNo picture "@!"
   @ 06,10 say "         Date" get mDate picture "@D"
   @ 07,10 say "    Passenger" get mPassenger picture "@!"
   @ 08,10 say "       Agency" get mAgent picture "@!"
   if nMode==VIEW_MODE
      AIRLINE->(DbSeek(mAirCode))
      if AIRLINE->(Found()) ; mAirline:=AIRLINE->AIRLINE ; endif
      @ 09,10 say "      Airline" get mAirline
   elseif (nMode==APPEND_MODE) .or. (nMode==EDIT_MODE)
      @ 09,10 clear to 09,58
      @ 09,10 say "      Airline" get mAirCode picture "@!"
   endif
   @ 10,10 say "Other Details" get mDetails1
   @ 11,10 say "             " get mDetails2
   @ 12,10 say "             " get mDetails3
   if (nMode==APPEND_MODE) .or. (nMode==EDIT_MODE)
      Message("F9-Agencies  F10-Airlines  Esc-Abort")
      SetCursor(SC_NORMAL)
      set key K_F10 to AirLookUp()
      set key K_F9 to AgtLookUp()
      read
      set key K_F10 to
      set key K_F9 to
      if LastKey()!=K_ESC
        if nMode==APPEND_MODE
           JV->(AddRec(0))
        endif
        /*if Updated()*/
           /* Replace current record with new entry. */
           JV->(FilLock(0))
           JV->VOUCHER_NO:=mVoucherNo
           JV->DATE:=DToC(mDate)
           JV->PASSENGER:=mPassenger
           JV->AGENT:=mAgent
           JV->AIR_CODE:=mAirCode
           JV->DETAILS_1:=mDetails1
           JV->DETAILS_2:=mDetails2
           JV->DETAILS_3:=mDetails3
           JV->(DbCommit())
           JV->(DbUnlock())
           AGENCY->(DbSeek(mAgent))
           if AGENCY->(!Found())
              AGENCY->(AddRec(0))
              AGENCY->(FilLock(0))
              AGENCY->AGENT_NAME:=mAgent
              AGENCY->(DbUnlock())
           endif
        /*endif*/
        JVTRANS->(ABrowse(JV->(RecNo()),nMode,aPicture,H_JV))
        SetCursor(SC_NONE)
      endif
   else
      clear gets
   endif
   SetCursor(SC_NONE)
return nil

static function InitVariables(nMode)
   if (nMode==APPEND_MODE)
      mVoucherNo:=Space(10)
      mDate:=CToD("  /  /  ")
      mPassenger:=Space(40)
      mAgent:=Space(40)
      mAirCode:=Space(3)
      mDetails1:=Space(40)
      mDetails2:=Space(40)
      mDetails3:=Space(40)
   else
      mVoucherNo=JV->VOUCHER_NO
      mDate=CToD(JV->DATE)
      mPassenger:=JV->PASSENGER
      mAgent:=JV->AGENT
      mAirCode:=JV->AIR_CODE
      mDetails1:=JV->DETAILS_1
      mDetails2:=JV->DETAILS_2
      mDetails3:=JV->DETAILS_3
   endif
   mAirline:=space(35)
return nil

static function SearchPax()
local nRecNo,wSearch,nKey,cName:=Space(40)
   nRecNo:=JV->(RecNo())
   wSearch:=OpenWindow(06,18,10,61,"Search Mode")
   @ 08,20 say "Enter name to search"
   @ 09,20 get cName picture "@!"
   SetCursor(SC_NORMAL)
   read
   cName:=Alltrim(cName)
   CloseWindow(wSearch)
   SetCursor(SC_NONE)
   if LastKey()!=K_ESC
      JV->(DbSetOrder(3))
      JV->(DbSeek(cName))
      if JV->(Found())
         do while (cName==substr(upper(JV->PASSENGER),1,len(cName))) .and. (nKey!=K_ESC)
            JVScreen(VIEW_MODE)
            Message("Press ENTER to continue search, ESC to abort....")
            nKey:=0
            do while (nkey!=K_ENTER) .and. (nKey!=K_ESC)
               nKey:=Inkey(0)
            enddo
            if nKey==K_ENTER ; JV->(DbSkip()) ; endif
        enddo
      else
        Message("Name not found ... Press ENTER to search Firstnames")
        nKey:= inkey(0)
        JV->(DbGoBottom())
        do while (JV->(!BOF())) .and. (nKey!=K_ESC) .and. nextKey()!=K_ESC
          Message("Searching for "+cName+", this may take TIME..."+space(abs(29-len(cName)))+"ESC to abort")
          do while !(cName $ (JV->PASSENGER)) .and. JV->(!BOF()) .and. nextkey()!=K_ESC
            JV->(DbSkip(-1))
          enddo
          if  (cName $ (JV->PASSENGER))
            JVScreen(VIEW_MODE)
            Message("Press ENTER to continue search, ESC to abort ...")
            nkey:=0
            do while (nKey!=K_ENTER) .and. (nkey!=K_ESC)
              nKey:=Inkey(0)
            enddo
            if nkey==K_ENTER; JV->(DbSkip(-1)); endif
          endif
        enddo
         if JV->(BOF()) .or. (JV->(!Found()) .and. nKey==K_ENTER)
          Tone(150,2)
          Message("Name not found....")
          JV->(DbGoTo(nRecNo))
          Inkey(1.5)
         endif
      endif
      JV->(DbSetOrder(1))
   endif
return nil

static function GetSummary()
local n1,n2,aChart:={},aAccounts:={},nSaveRecNo:=JV->(RecNo())
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
      /* Index JV by DATE. */
      JV->(DbSetOrder(2))
      JV->(DbSeek(SubStr(DToC(dStartDate),7,2)+"-"+ ;
                  SubStr(DToC(dStartDate),1,2) ))
      if JV->(Found())
         /* Find for requested start date */
         do while (JV->(!Eof())) .and. (CToD(JV->DATE)<dStartDate)
              JV->(DbSkip());  enddo
         /* Read JV file, check if record is within transaction dates. */
         do while (JV->(!Eof())) .and. (CToD(JV->DATE)<=dEndDate)
            /* Read all transactions of current JV record. */
            JVTRANS->(DbSeek(JV->(RecNo())))
            Message("Searching Journal Vouchers (rec #"+ ;
                Transform(JV->(RecNo()),"999999")+")....")
            do while JVTRANS->REC_NO==JV->(RecNo())
               /* Accounts array lookup. */
               n1:=aScan(aChart,JVTRANS->ACCT_CODE)
               /* Increment totals. */
               if n1>0
                  aAccounts[n1][A_DEBIT]:=aAccounts[n1][A_DEBIT] + ;
                     JVTRANS->DEBIT
                  nDebit:=nDebit+JVTRANS->DEBIT
                  aAccounts[n1][A_CREDIT]:=aAccounts[n1][A_CREDIT] + ;
                     JVTRANS->CREDIT
                  nCredit:=nCredit+JVTRANS->CREDIT
               endif
               JVTRANS->(DbSkip())
            enddo
            JV->(DbSkip())
         enddo
      endif
      JV->(DbSetOrder(1))
      JV->(DbGoTo(nSaveRecNo))
      /* Prepare JV Summary report. */
      Message("Preparing JV Summary Report....")
      Set(_SET_CONSOLE,.F.)
      Set(_SET_ALTFILE,"JVSUM.RPT")
      Set(_SET_ALTERNATE,.T.)
      ? "þJournal Vouchers - Summary Totals"
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
      cReport:=MemoRead("JVSUM.RPT")
      Message("Use cursor keys to navigate, press F10 to print, Esc to abort.")
      SetCursor(SC_NORMAL)
      wReport:=OpenWindow(3,1,21,77,"Journal Vouchers - Summary Totals")
      nLFactor:=2
      MemoEdit(cReport,4,2,20,76,.F.,"EditorFunc",90)
      nLFactor:=1
      CloseWindow(wReport)
      SetCursor(SC_NONE)
   endif
return nil

static function Update()
local nSaveRec := JV->(RecNo()), cKey, x
local lNewRec, nDadd:= nTadd:=0
   if GetDateCode() .and. (aScan(aLedgerCode,mAcctCode)!=0)
      x:=AScan(aLedgerCode,mAcctCode)
      if (mAcctCode=="01-121") .or. ;
         (mAcctCode=="04-181") .or. ;
         (mAcctCode=="04-171")
         Message("Type A for Agency Ledger, other key for Individual Ledger")
         inkey(0) 
         Message("")
         if (LastKey()==asc("A")) .or. (LastKey()==asc("a"))
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
      JV->(DbSetOrder(2))
      if JV->(DbSeek(SubStr(DToC(dStartDate),7,2)+"-"+ ;
                     SubStr(DToC(dStartDate),1,2) ))
         do while (JV->(!Eof())) .and. (CTOD(JV->DATE)<dStartDate)
              JV->(DbSkip())
         enddo
         do while (JV->(!Eof())) .and. (CTOD(JV->DATE)<=dEndDate)
            Message("Updating Subsidiary from Journal Voucher rec #"+;
                    transform(JV->(Recno()),"9999") )
            JVTRANS->(DbSeek(JV->(RecNo())))
            do while (JVTRANS->REC_NO==JV->(RecNo()) ) .and. ;
                (at("PETTY CASH",upper(JV->PASSENGER))==0)
                if (mAcctCode==JVTRANS->ACCT_CODE)
                   lNewRec:=.F.
                   do case
                      case xFmode==1
                         if empty(JV->AIR_CODE)
                             exit
                         endif
                         AIRLINE->(DbSeek(JV->AIR_CODE))
                         cKey:=substr(AIRLINE->AIRLINE,1,10)+upper(JV->PASSENGER)
                      case xFmode==2
                         if empty(JV->AGENT)
                             exit
                         endif
                         cKey:=substr(JV->AGENT,1,20)+upper(JV->PASSENGER)
                      case xFmode==3
                         if !empty(JV->AGENT) .and.;
                            ((cDbfName="ARTI") .or. (cDbfname="PRI"))
                             exit
                         endif
                         cKey:=upper(JV->PASSENGER)
                   endcase
                   if (nDbfArea)->(!DbSeek(cKey))
                      (nDbfArea)->(AddRec(0))   ; nDadd++
                      (nDbfArea)->(FilLock(0))
                      if xFmode != 1
                         (nDbfArea)->AIR_AGENCY:=JV->AGENT
                      else
                         if AIRLINE->(DbSeek(JV->AIR_CODE))
                            (nDbfArea)->AIR_AGENCY:=AIRLINE->AIRLINE
                         endif
                      endif
                      (nDbfArea)->PARTICULAR:=upper(JV->PASSENGER)
                      (nDbfArea)->DATE:=JV->DATE
                      (nDbfArea)->(DbUnlock())
                   endif
                   if ctod((nDbfArea)->DATE) > ctod(JV->DATE)
                      (nDbfArea)->(FilLock())
                      (nDbfArea)->DATE := JV->DATE
                      (nDbfArea)->(DbUnlock())
                   endif
                   if (nTransArea)->(!DbSeek((nDbfArea)->(RecNo())))
                      lNewRec:=.T.
                   else
                      do while ((nTransArea)->FOLIO!=JV->VOUCHER_NO) .and. ;
                               ((nTransArea)->REC_NO==(nDbfArea)->(RecNo())) .and. ;
                               (nTransArea)->(!Eof())
                         (nTransArea)->(DbSkip())
                      enddo
                      if ((nTransArea)->FOLIO!=JV->VOUCHER_NO) .or. ;
                         ((nTransArea)->REC_NO!=(nDbfArea)->(RecNo()))
                         lNewRec:=.T.
                      endif
                   endif
                   if lNewRec
                      (nTransArea)->(AddRec(0))  ; nTadd ++
                      (nTransArea)->(FilLock(0))
                      (nTransArea)->REC_NO := (nDbfArea)->(RecNo())
                      (nTransArea)->FOLIO := JV->VOUCHER_NO
                      (nTransArea)->(DbUnlock())   
                   endif
                   if ( (nTransArea)->REC_NO==(nDbfArea)->(RecNo()) )  .and.  ;
                      ( (nTransArea)->FOLIO==JV->VOUCHER_NO)
                      (nTransArea)->(FilLock(0))
                      (nTransArea)->DATE:=JV->DATE
                      (nTransArea)->DEBIT:=JVTRANS->DEBIT
                      (nTransArea)->CREDIT:=JVTRANS->CREDIT
                      (nTransArea)->DETAILS_1:=JV->DETAILS_1
                      (nTransArea)->DETAILS_2:=JV->DETAILS_2
                      (nTransArea)->(DbUnlock())
                   endif
                endif
                JVTRANS->(DbSkip())
            enddo
           JV->(DbSkip())
        enddo
      endif
      (nTransArea)->(DbCloseArea())
      (nDbfArea)->(DbCloseArea())
      JV->(DbGoto(nSaveRec))    
      JV->(DbSetOrder(1))
      Message("Status Report :  Added "+transform(nDadd,"99")+;
            " Entry,  "+transform(nTadd,"99")+" Transactions.")
      inkey(2)
   endif
return nil
// end-of-file