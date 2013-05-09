// Filename:      CDB.PRG
// Author:        Arnold P. Caoile
// Module:        Cash Disbursement Book
// Date-Started:  April 08, 1992
// Updated by:    Rollie C. Ibarra Jr.
// Last-Update:   June 26, 1992 /June 9, 1993

#include "Inkey.ch"
#include "Setcurs.ch"
#include "Dbstruct.ch"
#include "Mode.ch"
#include "Help.ch"

#define CDB_BAR "F2-Add  F3-Edit  F4-Delete  F5-Search  "+;
   "F6-Totals  F9-Update  Esc-Abort"

static mVoucherNo,mDate,mPayee,mDetails1,mDetails2,mCheckNo,aPicture

function CDB()
local wCDB,nKey
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
   if NetUse("CDBTRANS",DB_SHARED,NUM_SECONDS)
      set index to CDBTRANS
   endif
   if NetUse("CDB",DB_SHARED,NUM_SECONDS)
      set index to CDB_VNO,CDB_DATE,CDB_NAME
   endif
   aPicture:=Array(4,2)
   aPicture[1][1]:="CDBTRANS->REC_NO"
   aPicture[1][2]:="@!"
   aPicture[2][1]:="CDBTRANS->ACCT_CODE"
   aPicture[2][2]:=Replicate("X",6)
   aPicture[3][1]:="CDBTRANS->DEBIT"
   aPicture[3][2]:="9,999,999.99"
   aPicture[4][1]:="CDBTRANS->CREDIT"
   aPicture[4][2]:="9,999,999.99"
   wCDB:=OpenWindow(03,08,13,66,"Cash Disbursement Book")
   if CDB->(RecCount())==0 ; CDBScreen(APPEND_MODE) ; endif
   if LastKey()!=K_ESC
      do while (nKey!=K_ESC)
         CDBScreen(VIEW_MODE)
         nKey:=Inkey(0)
         do case
            case nKey==K_DOWN
               CDB->(DbSkip())
               if CDB->(Eof())
                  CDB->(DbGoBottom())
                  Tone(100,3)
                  Message("End of file reached....")
                  Inkey(1)
               endif
            case nKey==K_UP
               CDB->(DbSkip(-1))
               if CDB->(Bof())
                  CDB->(DbGoTop())
                  Tone(100,3)
                  Message("Beginning of file reached....")
                  Inkey(1)
               endif
            case nKey==K_CTRL_PGDN
               CDB->(DbSkip(NUM_TO_SKIP))
               if CDB->(Eof())
                  CDB->(DbGoBottom())
                  Tone(100,3)
                  Message("End of file reached....")
                  Inkey(1)
               endif
            case nKey==K_CTRL_PGUP
               CDB->(DbSkip(-NUM_TO_SKIP))
               if CDB->(Bof())
                  CDB->(DbGoTop())
                  Tone(100,3)
                  Message("Beginning of file reached....")
                  Inkey(1)
               endif
            case nKey==K_END
               CDB->(DbGoBottom())
                  Message("Moving to end of file....")
                  Inkey(1)
            case nKey==K_HOME
               CDB->(DbGoTop())
                  Message("Moving to beginning of file....")
                  Inkey(1)
            case nKey==K_PGDN
               CDBTRANS->(ABrowse(CDB->(RecNo()),VIEW_MODE,aPicture,H_CDB))
            case nKey==K_F1
               GetHelp(H_CDB)
            case nKey==K_F2
               Message("Press ENTER to add new record.")
               inkey(0)
               if LastKey()==K_ENTER
                  CDBScreen(APPEND_MODE)
               endif
            case nKey==K_F3
               CDBScreen(EDIT_MODE)
            case nKey==K_F4
               Message("Press ENTER to delete record, ESC to abort.")
               nDel:=0
               do while (nDel!=K_ENTER) .and. (nDel!=K_ESC)
                  nDel:=Inkey(0)
               enddo
               if nDel==K_ENTER
                  Message("Deleting current record....")
                  CDB->(FilLock(0))
                  CDB->(DbDelete())
                  CDB->(DbUnlock())
                  CDBTRANS->(DbSeek(CDB->(RecNo())))
                  do while CDBTRANS->REC_NO==CDB->(RecNo())
                     CDBTRANS->(FilLock(0))
                     CDBTRANS->(DbDelete())
                     CDBTRANS->(DbUnlock())
                     CDBTRANS->(DbSkip())
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
               Message("Press ENTER to Reindex Databases ...")
               tone(300,1)
               inkey(0)
               if lastkey()==K_ENTER
               Message("Reindexing databases this may take FOREVER...")
/*              CDB->(DbReindex())*/
               CDB->(DbCreateIndex((DATA_PATH)+"CDB_VNO", VOUCHER_NO))
               endif
         endcase
      enddo
   endif
   Message("Closing Databases....")
   CDB->(DbCloseArea())
   CDBTRANS->(DbCloseArea())
   CHART->(DbCloseArea())
   AGENCY->(DbCloseArea())
   AIRLINE->(DbCloseArea())
   CloseWindow(wCDB)
return nil

static function CDBScreen(nMode)
local n, nArea, cColor
   Tone(300,1)
   InitVariables(nMode)
   Message(CDB_BAR)
   cColor:=SetColor("N/BG")
   if CDB->(Deleted()) ; @ 03,35 say "<deleted>"
   else ; @ 03,35 say "         " ; endif
   @ 03,54 say "Rec. #" + ;
   Transform(If(nMode==APPEND_MODE,CDB->(RecCount()+1),CDB->(RecNo())),"99999")
   SetColor(cColor)
   @ 05,10 say "  Voucher No." get mVoucherNo picture "@!"
   @ 06,10 say "         Date" get mDate picture "@D"
   @ 07,10 say "        Payee" get mPayee picture "@!"
   @ 08,10 say "       Agency" get mAgent picture "@!"
   if nMode==VIEW_MODE
      AIRLINE->(DbSeek(mAirCode))
      if AIRLINE->(Found()) ; mAirline:=AIRLINE->AIRLINE ; endif
      @ 09,10 say "      Airline" get mAirline
   elseif (nMode==APPEND_MODE) .or. (nMode==EDIT_MODE)
      @ 09,10 clear to 09,58
      @ 09,10 say "      Airline" get mAirCode picture "@!"
   endif
   @ 10,10 say "    Check No." get mCheckNo picture "@!"
   @ 11,10 say "Other Details" get mDetails1
   @ 12,10 say "             " get mDetails2
   if (nMode==APPEND_MODE) .or. (nMode==EDIT_MODE)
      Message("  F9-Agencies  F10-Airlines  Esc-Abort")
      SetCursor(SC_NORMAL)
      set key K_F10 to AirLookUp()
      set key K_F9 to AgtLookUp()
      read
      set key K_F10 to
      set key K_F9 to
      if LastKey()!=K_ESC
         if nMode==APPEND_MODE
            CDB->(AddRec(0))
         endif
         /*if*Updated()  check for what successful read??  */
            /* Replace current record with new entry. */
            CDB->(FilLock(0))
            CDB->VOUCHER_NO:=mVoucherNo
            CDB->DATE:=DToC(mDate)
            CDB->PAYEE:=mPayee
            CDB->AGENT:=mAgent
            CDB->AIR_CODE:=mAirCode
            CDB->DETAILS_1:=mDetails1
            CDB->DETAILS_2:=mDetails2
            CDB->CHECK_NO:=mCheckNo
            CDB->(DbCommit())
            CDB->(DbUnlock())
            AGENCY->(DbSeek(mAgent))
            if AGENCY->(!Found()) .and. !empty(mAgent)
               /* Add new agency to agency database. */
               AGENCY->(AddRec(0))
               AGENCY->(FilLock(0))
               AGENCY->AGENT_NAME:=mAgent
               AGENCY->(DbUnlock())
            endif
        /*endif*/
         //Will always update rec unless lastkey = Esc
         CDBTRANS->(ABrowse(CDB->(RecNo()),nMode,aPicture,H_CDB))
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
      mDate:=CToD("  -  -  ")
      mPayee:=Space(40)
      mAgent:=Space(40)
      mAirCode:=Space(3)
      mDetails1:=Space(40)
      mDetails2:=Space(40)
      mCheckNo:=Space(11)
   else
      mVoucherNo=CDB->VOUCHER_NO
      mDate=CToD(CDB->DATE)
      mPayee:=CDB->PAYEE
      mAgent:=CDB->AGENT
      mAirCode:=CDB->AIR_CODE
      mDetails1:=CDB->DETAILS_1
      mDetails2:=CDB->DETAILS_2
      mCheckNo:=CDB->CHECK_NO
   endif
   mAirline:=space(35)
return nil

static function SearchPax()
local nRecNo,wSearch,nKey,cName:=Space(40)
   nRecNo:=CDB->(RecNo())
   wSearch:=OpenWindow(06,18,10,61,"Search Mode")
   @ 08,20 say "Enter name to search"
   @ 09,20 get cName picture "@!"
   SetCursor(SC_NORMAL)
   read
   cName := Alltrim(cName)
   CloseWindow(wSearch)
   SetCursor(SC_NONE)
   if LastKey()!=K_ESC
      CDB->(DbSetOrder(3))
      CDB->(DbSeek(cName))
      if CDB->(Found())
         do while (cName == substr(upper(CDB->PAYEE),1,len(cName))) .and. (nKey!=K_ESC)
            CDBScreen(VIEW_MODE)
            Message("Press ENTER to continue search, ESC to abort....")
            nKey:=0
            do while (nkey!=K_ENTER) .and. (nKey!=K_ESC)
               nKey:=Inkey(0)
            enddo
            if nKey==K_ENTER ; CDB->(DbSkip()) ; endif
        enddo
      else
        Message("Name not found ... Press ENTER to search Firstnames")
        nKey:= inkey(0)
        CDB->(DbGoBottom())
        do while (CDB->(!BOF())) .and. (nKey!=K_ESC) .and. nextKey()!=K_ESC
          Message("Searching for "+cName+", this may take TIME..."+space(abs(29-len(cName)))+"ESC to abort")
          do while !(cName $ (CDB->PAYEE)) .and. CDB->(!BOF()) .and. nextkey()!=K_ESC
            CDB->(DbSkip(-1))
          enddo
          if  (cName $ (CDB->PAYEE))
            CDBScreen(VIEW_MODE)
            Message("Press ENTER to continue search, ESC to abort ...")
            nkey:=0
            do while (nKey!=K_ENTER) .and. (nkey!=K_ESC)
              nKey:=Inkey(0)
            enddo
            if nkey==K_ENTER; CDB->(DbSkip(-1)); endif
          endif
        enddo
         if CDB->(BOF()) .or. (CDB->(!Found()) .and. nKey==K_ENTER)
          Tone(150,2)
          Message("Name not found....")
          CDB->(DbGoTo(nRecNo))
          Inkey(1.5)
         endif
      endif
      CDB->(DbSetOrder(1))
   endif
return nil

static function GetSummary()
local n1,n2,aChart:={},aAccounts:={},nSaveRecNo:=CDB->(RecNo())
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
      /* Index CDB by DATE. */
      CDB->(DbSetOrder(2))
      CDB->(DbSeek(SubStr(DToC(dStartDate),7,2)+"-"+ ;
                   SubStr(DToC(dStartDate),1,2) ))
      if CDB->(Found())
         /* Find for requested start date */
         do while (CDB->(!Eof())) .and. (CTOD(CDB->DATE)<dStartDate)
              CDB->(DbSkip());  enddo
         /* Read CDB file, check if record is within transaction dates. */
         do while (CDB->(!Eof())) .and. (CTOD(CDB->DATE)<=dEndDate)
            /* Read all transactions of current CDB record. */
            CDBTRANS->(DbSeek(CDB->(RecNo())))
            Message("Searching Cash Disbursements (rec #"+ ;
                Transform(CDB->(RecNo()),"999999")+")....")
            do while CDBTRANS->REC_NO==CDB->(RecNo())
               /* Accounts array lookup. */
               n1:=aScan(aChart,CDBTRANS->ACCT_CODE)
               /* Increment totals. */
               if n1>0
                  aAccounts[n1][A_DEBIT]:=aAccounts[n1][A_DEBIT] + ;
                     CDBTRANS->DEBIT
                  nDebit:=nDebit+CDBTRANS->DEBIT
                  aAccounts[n1][A_CREDIT]:=aAccounts[n1][A_CREDIT] + ;
                     CDBTRANS->CREDIT
                  nCredit:=nCredit+CDBTRANS->CREDIT
               endif
               CDBTRANS->(DbSkip())
            enddo
            CDB->(DbSkip())
         enddo
      endif
      CDB->(DbSetOrder(1))
      CDB->(DbGoTo(nSaveRecNo))
      Message("Preparing CDB Summary Report....")
      /* Prepare CDB Summary report. */
      Set(_SET_CONSOLE,.F.)
      Set(_SET_ALTFILE,"CDBSUM.RPT")
      Set(_SET_ALTERNATE,.T.)
      ? "þCash Disbursement Book - Summary Totals"
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
      cReport:=MemoRead("CDBSUM.RPT")
      Message("Use cursor keys to navigate, press F10 to print, Esc to abort.")
      SetCursor(SC_NORMAL)
      wReport:=OpenWindow(3,1,21,77,"Cash Disbursement Book - Summary Totals")
      nLFactor:=2
      MemoEdit(cReport,4,2,20,76,.F.,"EditorFunc",90)
      nLFactor:=1
      CloseWindow(wReport)
      SetCursor(SC_NONE)
      CHART->(DbSetOrder(1))
   endif
return nil

static function Update()
local nSaveRec := CDB->(RecNo()), cKey, x
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
      CDB->(DbSetOrder(2))
      if CDB->(DbSeek(SubStr(DToC(dStartDate),7,2)+"-"+ ;
                     SubStr(DToC(dStartDate),1,2) ))
         do while (CDB->(!Eof())) .and. (CTOD(CDB->DATE)<dStartDate)
              CDB->(DbSkip())
         enddo
         do while (CDB->(!Eof())) .and. (CTOD(CDB->DATE)<=dEndDate)
            Message("Updating Subsidiary from Cash Disbursement rec #"+;
                    transform(CDB->(Recno()),"9999") )
            CDBTRANS->(DbSeek(CDB->(RecNo())))
            do while (CDBTRANS->REC_NO==CDB->(RecNo()) ) .and. ;
                (at("PETTY CASH",upper(CDB->PAYEE))==0)
                if (mAcctCode==CDBTRANS->ACCT_CODE)
                   lNewRec:=.F.
                   do case
                      case xFmode==1
                         if empty(CDB->AIR_CODE)
                             exit
                         endif
                         AIRLINE->(DbSeek(CDB->AIR_CODE))
                         cKey:=substr(AIRLINE->AIRLINE,1,10)+upper(CDB->PAYEE)
                      case xFmode==2
                         if empty(CDB->AGENT)
                             exit
                         endif
                         cKey:=substr(CDB->AGENT,1,20)+upper(CDB->PAYEE)
                      case xFmode==3
                         if !empty(CDB->AGENT) .and. ;
                            ((cDbfName="ARTI") .or. (cDbfname="PRI"))
                             exit
                         endif
                         cKey:=upper(CDB->PAYEE)
                   endcase
                   if (nDbfArea)->(!DbSeek(cKey))
                      (nDbfArea)->(AddRec(0))   ; nDadd++
                      (nDbfArea)->(FilLock(0))
                      if xFmode != 1
                         (nDbfArea)->AIR_AGENCY:=CDB->AGENT
                      else
                         if AIRLINE->(DbSeek(CDB->AIR_CODE))
                            (nDbfArea)->AIR_AGENCY:=AIRLINE->AIRLINE
                         endif
                      endif
                      (nDbfArea)->PARTICULAR:=upper(CDB->PAYEE)
                      (nDbfArea)->DATE:=CDB->DATE
                      (nDbfArea)->(DbUnlock())
                   endif
                   if ctod((nDbfArea)->DATE) > ctod(CDB->DATE)
                      (nDbfArea)->(FilLock())
                      (nDbfArea)->DATE := CDB->DATE
                      (nDbfArea)->(DbUnlock())
                   endif
                   if (nTransArea)->(!DbSeek((nDbfArea)->(RecNo())))
                      lNewRec:=.T.
                   else
                      do while ((nTransArea)->FOLIO!=CDB->VOUCHER_NO) .and. ;
                               ((nTransArea)->REC_NO==(nDbfArea)->(RecNo())) .and. ;
                               (nTransArea)->(!Eof())
                         (nTransArea)->(DbSkip())
                      enddo
                      if ((nTransArea)->FOLIO!=CDB->VOUCHER_NO) .or. ;
                         ((nTransArea)->REC_NO!=(nDbfArea)->(RecNo()))
                         lNewRec:=.T.
                      endif
                   endif
                   if lNewRec
                      (nTransArea)->(AddRec(0))  ; nTadd ++
                      (nTransArea)->(FilLock(0))
                      (nTransArea)->REC_NO := (nDbfArea)->(RecNo())
                      (nTransArea)->FOLIO := CDB->VOUCHER_NO
                      (nTransArea)->(DbUnlock())
                   endif
                   if ( (nTransArea)->REC_NO==(nDbfArea)->(RecNo()) )  .and.  ;
                      ( (nTransArea)->FOLIO==CDB->VOUCHER_NO)
                      (nTransArea)->(FilLock(0))
                      (nTransArea)->DATE:=CDB->DATE
                      (nTransArea)->DEBIT:=CDBTRANS->DEBIT
                      (nTransArea)->CREDIT:=CDBTRANS->CREDIT
                      (nTransArea)->DETAILS_1:=CDB->DETAILS_1
                      (nTransArea)->DETAILS_2:=CDB->DETAILS_2
                      (nTransArea)->(DbUnlock())
                   endif
                endif
                CDBTRANS->(DbSkip())
            enddo
           CDB->(DbSkip())
        enddo
      endif
      (nTransArea)->(DbCloseArea())
      (nDbfArea)->(DbCloseArea())
      CDB->(DbGoto(nSaveRec))
      CDB->(DbSetOrder(1))
      Message("Status Report :  Added "+transform(nDadd,"99")+;
            " Entry,  "+transform(nTadd,"99")+" Transactions.")
      inkey(2)
   endif
return nil
// end-of-file
