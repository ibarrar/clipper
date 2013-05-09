// Filename:      CRB.PRG
// Author:        Arnold P. Caoile
// Module:        Cash Receipts Book
// Date-Started:  April 08, 1992
// Updated by:    Rollie C. Ibarra Jr.
// Last-Update:   June 29, 1992

#include "Inkey.ch"
#include "Setcurs.ch"
#include "Mode.ch"
#include "Help.ch"

#define CRB_BAR "F2-Add  F3-Edit  F4-Delete  F5-Search  "+;
   "F6-Totals  F9-Update  Esc-Abort"

static mVoucherNo,mDate,mPassenger,mDetails1,mDetails2,aPicture

function CRB()
local wCRB,nKey
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
   if NetUse("CRBTRANS",DB_SHARED,NUM_SECONDS)
      set index to CRBTRANS
   endif
   if NetUse("CRB",DB_SHARED,NUM_SECONDS)
      set index to CRB_VNO,CRB_DATE,CRB_NAME
   endif
   aPicture:=Array(4,2)
   aPicture[1][1]:="CRBTRANS->REC_NO"
   aPicture[1][2]:="@!"
   aPicture[2][1]:="CRBTRANS->ACCT_CODE"
   aPicture[2][2]:=Replicate("X",6)
   aPicture[3][1]:="CRBTRANS->DEBIT"
   aPicture[3][2]:="9,999,999.99"
   aPicture[4][1]:="CRBTRANS->CREDIT"
   aPicture[4][2]:="9,999,999.99"
   wCRB:=OpenWindow(03,08,12,66,"Cash Receipts Book")
   if CRB->(RecCount())==0 ; CRBScreen(APPEND_MODE) ; endif
   if LastKey()!=K_ESC
      do while (nKey!=K_ESC)
         CRBScreen(VIEW_MODE)
         nKey:=Inkey(0)
         do case
            case nKey==K_DOWN
               CRB->(DbSkip())
               if CRB->(Eof())
                  CRB->(DbGoBottom())
                  Tone(100,3)
                  Message("End of file reached....")
                  Inkey(1)
               endif
            case nKey==K_UP
               CRB->(DbSkip(-1))
               if CRB->(Bof())
                  CRB->(DbGoTop())
                  Tone(100,3)
                  Message("Beginning of file reached....")
                  Inkey(1)
               endif
            case nKey==K_CTRL_PGDN
               CRB->(DbSkip(NUM_TO_SKIP))
               if CRB->(Eof())
                  CRB->(DbGoBottom())
                  Tone(100,3)
                  Message("End of file reached....")
                  Inkey(1)
               endif
            case nKey==K_CTRL_PGUP
               CRB->(DbSkip(-NUM_TO_SKIP))
               if CRB->(Bof())
                  CRB->(DbGoTop())
                  Tone(100,3)
                  Message("Beginning of file reached....")
                  Inkey(1)
               endif
            case nKey==K_END
               CRB->(DbGoBottom())
                  Message("Moving to end of file....")
                  Inkey(1)
            case nKey==K_HOME
               CRB->(DbGoTop())
                  Message("Moving to beginning of file....")
                  Inkey(1)
            case nKey==K_PGDN
               CRBTRANS->(ABrowse(CRB->(RecNo()),VIEW_MODE,aPicture,H_CRB))
            case nKey==K_F1
               GetHelp(H_CRB)
            case nKey==K_F2
               Message("Press ENTER to add new record.")
               inkey(0)
               if LastKey()==K_ENTER
                  CRBScreen(APPEND_MODE)
               endif
            case nKey==K_F3
               CRBScreen(EDIT_MODE)
            case nKey==K_F4
               Message("Press ENTER to delete record, ESC to abort.")
               nDel:=0
               do while (nDel!=K_ENTER) .and. (nDel!=K_ESC)
                  nDel:=Inkey(0)
               enddo
               if nDel==K_ENTER
                  Message("Deleting current record....")
                  CRB->(FilLock(0))
                  CRB->(DbDelete())
                  CRB->(DbUnlock())
                  CRBTRANS->(DbSeek(CRB->(RecNo())))
                  do while CRBTRANS->REC_NO==CRB->(RecNo())
                     CRBTRANS->(FilLock(0))
                     CRBTRANS->(DbDelete())
                     CRBTRANS->(DbUnlock())
                     CRBTRANS->(DbSkip())
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
               Message("Press ENTER to reindex databases ...")
               inkey(0)
               if LastKey()==K_ENTER
                  Message("Reindexing, this may take FOREVER...")
                  CRB->(DbReindex())
               endif
         endcase
      enddo
   endif
   Message("Closing Databases....")
   CRB->(DbCloseArea())
   CRBTRANS->(DbCloseArea())
   CHART->(DbCloseArea())
   AGENCY->(DbCloseArea())
   AIRLINE->(DbCloseArea())
   CloseWindow(wCRB)
return nil

static function CRBScreen(nMode)
local nArea,cColor,mAirline:=Space(35),lNewRec, nAdd:=nUpd:=0
   Tone(300,1)
   InitVariables(nMode)
   Message(CRB_BAR)
   cColor:=SetColor("N/BG")
   if CRB->(Deleted()) ; @ 03,35 say "<deleted>"
   else ; @ 03,35 say "         " ; endif
   @ 03,54 say "Rec. #" + ;
   Transform(If(nMode==APPEND_MODE,CRB->(RecCount()+1),CRB->(RecNo())),"99999")
   SetColor(cColor)
   @ 05,10 say "       OR No." get mVoucherNo picture "@!"
   @ 06,10 say "         Date" get mDate picture "@D"
   @ 07,10 say "    Passenger" get mPassenger picture "@!"
   @ 08,10 say "       Agency" get mAgent picture "@!"
   if nMode==VIEW_MODE
      AIRLINE->(DbSeek(mAirCode))
      if AIRLINE->(Found()) ; mAirline:=AIRLINE->AIRLINE; endif
      @ 09,10 say "      Airline" get mAirline
   elseif (nMode==APPEND_MODE) .or. (nMode==EDIT_MODE)
      @ 09,10 clear to 09,58
      @ 09,10 say "      Airline" get mAirCode picture "@!"
   endif
   @ 10,10 say "Other Details" get mDetails1
   @ 11,10 say "             " get mDetails2
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
           CRB->(AddRec(0))
        endif
        /*if Updated()*/
           /* Replace current record with new entry. */
           CRB->(FilLock(0))
           CRB->VOUCHER_NO:=mVoucherNo
           CRB->DATE:=DToC(mDate)
           CRB->PASSENGER:=mPassenger
           CRB->AGENT:=mAgent
           CRB->AIR_CODE:=mAirCode
           CRB->DETAILS_1:=mDetails1
           CRB->DETAILS_2:=mDetails2
           CRB->(DbCommit())
           CRB->(DbUnlock())
           AGENCY->(DbSeek(mAgent))
           if AGENCY->(!Found())
              AGENCY->(AddRec(0))
              AGENCY->(FilLock(0))
              AGENCY->AGENT_NAME:=mAgent
              AGENCY->(DbUnlock())
           endif
       /* endif*/
        CRBTRANS->(ABrowse(CRB->(RecNo()),nMode,aPicture,H_CRB))
        SetCursor(SC_NONE)
      endif
   else
      clear gets
   endif
   SetCursor(SC_NONE)
   mAirline:=space(37)
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
   else
      mVoucherNo=CRB->VOUCHER_NO
      mDate=CToD(CRB->DATE)
      mPassenger:=CRB->PASSENGER
      mAgent:=CRB->AGENT
      mAirCode:=CRB->AIR_CODE
      mDetails1:=CRB->DETAILS_1
      mDetails2:=CRB->DETAILS_2
   endif
   mAirline:=space(35)
return nil

static function SearchPax()
local nRecNo,wSearch,nKey,cName:=Space(40)
   nRecNo:=CRB->(RecNo())
   wSearch:=OpenWindow(06,18,10,61,"Search Mode")
   @ 08,20 say "Enter name to search"
   @ 09,20 get cName picture "@!"
   SetCursor(SC_NORMAL)
   read
   cName:=Alltrim(cName)
   CloseWindow(wSearch)
   SetCursor(SC_NONE)
   if LastKey()!=K_ESC
      CRB->(DbSetOrder(3))
      CRB->(DbSeek(cName))
      if CRB->(Found())
         do while (cName == substr(upper(CRB->PASSENGER),1,len(cname))) .and. (nKey!=K_ESC)
            CRBScreen(VIEW_MODE)
            Message("Press ENTER to continue search, ESC to abort....")
            nKey:=0
            do while (nkey!=K_ENTER) .and. (nKey!=K_ESC)
               nKey:=Inkey(0)
            enddo
            if nKey==K_ENTER ; CRB->(DbSkip()) ; endif
        enddo
      else
        Message("Name not found ... Press ENTER to search Firstnames")
        nKey:= inkey(0)
        CRB->(DbGoBottom())
        do while (CRB->(!BOF())) .and. (nKey!=K_ESC) .and. nextKey()!=K_ESC
          Message("Searching for "+cName+", this may take TIME..."+space(abs(29-len(cName)))+"ESC to abort")
          do while !(cName $ (CRB->PASSENGER)) .and. CRB->(!BOF()) .and. nextkey()!=K_ESC
            CRB->(DbSkip(-1))
          enddo
          if  (cName $ (CRB->PASSENGER))
            CRBScreen(VIEW_MODE)
            Message("Press ENTER to continue search, ESC to abort ...")
            nkey:=0
            do while (nKey!=K_ENTER) .and. (nkey!=K_ESC)
              nKey:=Inkey(0)
            enddo
            if nkey==K_ENTER; CRB->(DbSkip(-1)); endif
          endif
        enddo
         if CRB->(BOF()) .or. (CRB->(!Found()) .and. nKey==K_ENTER)
          Tone(150,2)
          Message("Name not found....")
          CRB->(DbGoTo(nRecNo))
          Inkey(1.5)
         endif
      endif
      CRB->(DbSetOrder(1))
   endif
return nil

static function GetSummary()
local n1,n2,aChart:={},aAccounts:={},nSaveRecNo:=CRB->(RecNo())
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
      /* Index CRB by DATE */
      CRB->(DbSetOrder(2))
      CRB->(DbSeek(SubStr(DToC(dStartDate),7,2)+"-"+ ;
                   SubStr(DToC(dStartDate),1,2) ))
      if CRB->(Found())
         /* Find for requested start date */
         do while (CRB->(!Eof())) .and. (CToD(CRB->DATE)<dStartDate)
              CRB->(DbSkip());  enddo
         /* Read CRB file, check if record is within transaction dates. */
         do while (CRB->(!Eof())) .and. (CToD(CRB->DATE)<=dEndDate)
            /* Read all transactions of current CRB record. */
            CRBTRANS->(DbSeek(CRB->(RecNo())))
            Message("Searching Cash Receipts (rec #"+ ;
                Transform(CRB->(RecNo()),"999999")+")....")
            do while CRBTRANS->REC_NO==CRB->(RecNo())
               /* Accounts array lookup. */
               n1:=aScan(aChart,CRBTRANS->ACCT_CODE)
               /* Increment totals. */
               if n1>0
                  aAccounts[n1][A_DEBIT]:=aAccounts[n1][A_DEBIT] + ;
                     CRBTRANS->DEBIT
                  nDebit:=nDebit+CRBTRANS->DEBIT
                  aAccounts[n1][A_CREDIT]:=aAccounts[n1][A_CREDIT] + ;
                     CRBTRANS->CREDIT
                  nCredit:=nCredit+CRBTRANS->CREDIT
               endif
               CRBTRANS->(DbSkip())
            enddo
            CRB->(DbSkip())
         enddo
      endif
      CRB->(DbSetOrder(1))
      CRB->(DbGoTo(nSaveRecNo))
      /* Prepare CRB Summary report. */
      Message("Preparing CRB Summary Report....")
      Set(_SET_CONSOLE,.F.)
      Set(_SET_ALTFILE,"CRBSUM.RPT")
      Set(_SET_ALTERNATE,.T.)
      ? "þCash Receipt Book - Summary Totals"
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
      cReport:=MemoRead("CRBSUM.RPT")
      Message("Use cursor keys to navigate, press F10 to print, Esc to abort.")
      SetCursor(SC_NORMAL)
      wReport:=OpenWindow(3,1,21,77,"Cash Receipt Book - Summary Totals")
      nLFactor:=2
      MemoEdit(cReport,4,2,20,76,.F.,"EditorFunc",90)
      nLFactor:=1
      CloseWindow(wReport)
      SetCursor(SC_NONE)
   endif
return nil

static function Update()
local nSaveRec := CRB->(RecNo()), cKey, x
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
      CRB->(DbSetOrder(2))
      if CRB->(DbSeek(SubStr(DToC(dStartDate),7,2)+"-"+ ;
                     SubStr(DToC(dStartDate),1,2) ))
         do while (CRB->(!Eof())) .and. (CTOD(CRB->DATE)<dStartDate)
              CRB->(DbSkip())
         enddo
         do while (CRB->(!Eof())) .and. (CTOD(CRB->DATE)<=dEndDate)
            Message("Updating Subsidiary from Cash Receipt rec #"+;
                    transform(CRB->(Recno()),"9999") )
            CRBTRANS->(DbSeek(CRB->(RecNo())))
            do while CRBTRANS->REC_NO==CRB->(RecNo())
                if (mAcctCode==CRBTRANS->ACCT_CODE)
                   lNewRec:=.F.
                   do case
                      case xFmode==1
                         if empty(CRB->AIR_CODE)
                             exit
                         endif
                         AIRLINE->(DbSeek(CRB->AIR_CODE))
                         cKey:=substr(AIRLINE->AIRLINE,1,10)+upper(CRB->PASSENGER)
                      case xFmode==2
                         if empty(CRB->AGENT)
                             exit
                         endif
                         cKey:=substr(CRB->AGENT,1,20)+upper(CRB->PASSENGER)
                      case xFmode==3
                         if !empty(CRB->AGENT) .and.;
                            ((cDbfName="ARTI") .or. (cDbfname="PRI"))
                             exit
                         endif
                         cKey:=upper(CRB->PASSENGER)
                   endcase
                   if (nDbfArea)->(!DbSeek(cKey))
                      (nDbfArea)->(AddRec(0))   ; nDadd++
                      (nDbfArea)->(FilLock(0))
                      if xFmode != 1
                         (nDbfArea)->AIR_AGENCY:=CRB->AGENT
                      else
                         if AIRLINE->(DbSeek(CRB->AIR_CODE))
                            (nDbfArea)->AIR_AGENCY:=AIRLINE->AIRLINE
                         endif
                      endif
                      (nDbfArea)->PARTICULAR:=upper(CRB->PASSENGER)
                      (nDbfArea)->DATE:=CRB->DATE
                      (nDbfArea)->(DbUnlock())
                   endif
                   if ctod((nDbfArea)->DATE) > ctod(CRB->DATE)
                      (nDbfArea)->(FilLock())
                      (nDbfArea)->DATE := CRB->DATE
                      (nDbfArea)->(DbUnlock())
                   endif
                   nTransArea:=Select()
                   if (nTransArea)->(!DbSeek((nDbfArea)->(RecNo())))
                      lNewRec:=.T.
                   else
                      do while ((nTransArea)->FOLIO!=CRB->VOUCHER_NO) .and. ;
                               ((nTransArea)->REC_NO==(nDbfArea)->(RecNo())) .and. ;
                               (nTransArea)->(!Eof())
                         (nTransArea)->(DbSkip())
                      enddo
                      if ((nTransArea)->FOLIO!=CRB->VOUCHER_NO) .or. ;
                         ((nTransArea)->REC_NO!=(nDbfArea)->(RecNo()))
                         lNewRec:=.T.
                      endif
                   endif
                   if lNewRec
                      (nTransArea)->(AddRec(0))  ; nTadd ++
                      (nTransArea)->(FilLock(0))
                      (nTransArea)->REC_NO := (nDbfArea)->(RecNo())
                      (nTransArea)->FOLIO := CRB->VOUCHER_NO
                      (nTransArea)->(DbUnlock())
                   endif
                   if ( (nTransArea)->REC_NO==(nDbfArea)->(RecNo()) )  .and.  ;
                      ( (nTransArea)->FOLIO==CRB->VOUCHER_NO)
                      (nTransArea)->(FilLock(0))
                      (nTransArea)->DATE:=CRB->DATE
                      (nTransArea)->DEBIT:=CRBTRANS->DEBIT
                      (nTransArea)->CREDIT:=CRBTRANS->CREDIT
                      (nTransArea)->DETAILS_1:=CRB->DETAILS_1
                      (nTransArea)->DETAILS_2:=CRB->DETAILS_2
                      (nTransArea)->(DbUnlock())
                   endif
                endif
                CRBTRANS->(DbSkip())
            enddo
           CRB->(DbSkip())
        enddo
      endif
      (nTransArea)->(DbCloseArea())
      (nDbfArea)->(DbCloseArea())
      CRB->(DbGoto(nSaveRec))    
      CRB->(DbSetOrder(1))
      Message("Status Report :  Added "+transform(nDadd,"99")+;
            " Entry,  "+transform(nTadd,"99")+" Transactions.")
      inkey(2)
   endif
return nil
// end-of-file