// Filename:      SB.PRG
// Author:        Arnold P. Caoile
// Module:        Sales Book
// Date-Started:  April 08, 1992
// Updated by:    Rollie C. Ibarra Jr.
// Last-Update:   June 26, 1992/June 9, 1993

#include "Inkey.ch"
#include "Setcurs.ch"
#include "Mode.ch"
#include "Help.ch"

#define SB_BAR "F2-Add  F3-Edit  F4-Delete  F5-Search  "+;
   "F6-Totals  F9-Update  Esc-Abort"

static mVoucherNo,mDate,mPassenger,mDetails1,mDetails2,aPicture

function SB()
local wSB,nKey
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
   if NetUse("SBTRANS",DB_SHARED,NUM_SECONDS)
      set index to SBTRANS
   endif
   if NetUse("SB",DB_SHARED,NUM_SECONDS)
      set index to SB_VNO,SB_DATE,SB_NAME
   endif
   aPicture:=Array(4,2)
   aPicture[1][1]:="SBTRANS->REC_NO"
   aPicture[1][2]:="@!"
   aPicture[2][1]:="SBTRANS->ACCT_CODE"
   aPicture[2][2]:=Replicate("X",6)
   aPicture[3][1]:="SBTRANS->DEBIT"
   aPicture[3][2]:="9,999,999.99"
   aPicture[4][1]:="SBTRANS->CREDIT"
   aPicture[4][2]:="9,999,999.99"
   wSB:=OpenWindow(03,08,12,66,"Sales Book")
   if SB->(RecCount())==0 ; SBScreen(APPEND_MODE) ; endif
   if LastKey()!=K_ESC
      do while (nKey!=K_ESC)
         SBScreen(VIEW_MODE)
         nKey:=Inkey(0)
         do case
            case nKey==K_DOWN
               SB->(DbSkip())
               if SB->(Eof())
                  SB->(DbGoBottom())
                  Tone(100,3)
                  Message("End of file reached....")
                  Inkey(1)
               endif
            case nKey==K_UP
               SB->(DbSkip(-1))
               if SB->(Bof())
                  SB->(DbGoTop())
                  Tone(100,3)
                  Message("Beginning of file reached....")
                  Inkey(1)
               endif
            case nKey==K_CTRL_PGDN
               SB->(DbSkip(NUM_TO_SKIP))
               if SB->(Eof())
                  SB->(DbGoBottom())
                  Tone(100,3)
                  Message("End of file reached....")
                  Inkey(1)
               endif
            case nKey==K_CTRL_PGUP
               SB->(DbSkip(-NUM_TO_SKIP))
               if SB->(Bof())
                  SB->(DbGoTop())
                  Tone(100,3)
                  Message("Beginning of file reached....")
                  Inkey(1)
               endif
            case nKey==K_END
               SB->(DbGoBottom())
                  Message("Moving to end of file....")
                  Inkey(1)
            case nKey==K_HOME
               SB->(DbGoTop())
                  Message("Moving to beginning of file....")
                  Inkey(1)
            case nKey==K_PGDN
               SBTRANS->(ABrowse(SB->(RecNo()),VIEW_MODE,aPicture,H_SB))
            case nKey==K_F1
               GetHelp(H_SB)
            case nKey==K_F2
               Message("Press ENTER to add new record.")
               inkey(0)
               if LastKey()==K_ENTER
                  SBScreen(APPEND_MODE)
               endif
            case nKey==K_F3
               SBScreen(EDIT_MODE)
            case nKey==K_F4
               Message("Press ENTER to delete record, ESC to abort.")
               nDel:=0
               do while (nDel!=K_ENTER) .and. (nDel!=K_ESC)
                  nDel:=Inkey(0)
               enddo
               if nDel==K_ENTER
                  Message("Deleting current record....")
                  SB->(FilLock(0))
                  SB->(DbDelete())
                  SB->(DbUnlock())
                  SBTRANS->(DbSeek(SB->(RecNo())))
                  do while SBTRANS->REC_NO==SB->(RecNo())
                     SBTRANS->(FilLock(0))
                     SBTRANS->(DbDelete())
                     SBTRANS->(DbUnlock())
                     SBTRANS->(DbSkip())
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
               if LastKey()==K_ENTER
                  Message("Reindexing, this may take FOREVER...")
                  SB->(DbReindex())
               endif
         endcase
      enddo
   endif
   Message("Closing Databases....")
   SB->(DbCloseArea())
   SBTRANS->(DbCloseArea())
   CHART->(DbCloseArea())
   AGENCY->(DbCloseArea())
   AIRLINE->(DbCloseArea())
   CloseWindow(wSB)
return nil

static function SBScreen(nMode)
local nArea,cColor,mAirline:=Space(35),lNewRec, nAdd:=nUpd:=0
   Tone(300,1)
   InitVariables(nMode)
   Message(SB_BAR)
   cColor:=SetColor("N/BG")
   if SB->(Deleted()) ; @ 03,35 say "<deleted>"
   else ; @ 03,35 say "         " ; endif
   @ 03,54 say "Rec. #" + ;
   Transform(If(nMode==APPEND_MODE,SB->(RecCount()+1),SB->(RecNo())),"99999")
   SetColor(cColor)
   @ 05,10 say "     Bill No." get mVoucherNo picture "@!"
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
   if (nMode==APPEND_MODE) .or. (nMode==EDIT_MODE)
      Message("F9-Agencies  F10-Airlines  Esc-Abort")
      SetCursor(SC_NORMAL)
      set key K_F10 to AirLookUp()
      set key K_F9 to AgtLookUp()
      read
      set key K_F10
      set key K_F9
      if LastKey()!=K_ESC
        if nMode==APPEND_MODE
           SB->(AddRec(0))
        endif
       /* if Updated() */
           /* Replace current record with new entry. */
           SB->(FilLock(0))
           SB->VOUCHER_NO:=mVoucherNo
           SB->DATE:=DToC(mDate)
           SB->PASSENGER:=mPassenger
           SB->AGENT:=mAgent
           SB->AIR_CODE:=mAirCode
           SB->DETAILS_1:=mDetails1
           SB->DETAILS_2:=mDetails2
           SB->(DbCommit())
           SB->(DbUnlock())
           AGENCY->(DbSeek(mAgent))
           if AGENCY->(!Found())
              AGENCY->(AddRec(0))
              AGENCY->(FilLock(0))
              AGENCY->AGENT_NAME:=mAgent
              AGENCY->(DbUnlock())
           endif
      /*  endif   */
        SBTRANS->(ABrowse(SB->(RecNo()),nMode,aPicture,H_SB))
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
   else
      mVoucherNo=SB->VOUCHER_NO
      mDate=CToD(SB->DATE)
      mPassenger:=SB->PASSENGER
      mAgent:=SB->AGENT
      mAirCode:=SB->AIR_CODE
      mDetails1:=SB->DETAILS_1
      mDetails2:=SB->DETAILS_2
   endif
   mAirline:=space(35)
return nil

static function SearchPax()
local nRecNo,wSearch,nKey,cName:=Space(40)
   nRecNo:=SB->(RecNo())
   wSearch:=OpenWindow(06,18,10,61,"Search Mode")
   @ 08,20 say "Enter name to search"
   @ 09,20 get cName picture "@!"
   SetCursor(SC_NORMAL)
   read
   cName:=Alltrim(cName)
   CloseWindow(wSearch)
   SetCursor(SC_NONE)
   if LastKey()!=K_ESC
      SB->(DbSetOrder(3))
      SB->(DbSeek(cName))
      if SB->(Found())
         do while (cName==substr(upper(SB->PASSENGER),1,len(cName))) .and. (nKey!=K_ESC)
            SBScreen(VIEW_MODE)
            Message("Press ENTER to continue search, ESC to abort....")
            nKey:=0
            do while (nkey!=K_ENTER) .and. (nKey!=K_ESC)
               nKey:=Inkey(0)
            enddo
            if nKey==K_ENTER ; SB->(DbSkip()) ; endif
        enddo
      else
        Message("Name not found ... Press ENTER to search Firstnames")
        nKey:= inkey(0)
        SB->(DbGoBottom())
        do while (SB->(!BOF())) .and. (nKey!=K_ESC) .and. nextKey()!=K_ESC
          Message("Searching for "+cName+", this may take TIME..."+space(abs(29-len(cName)))+"ESC to abort")
          do while !(cName $ (SB->PASSENGER)) .and. SB->(!BOF()) .and. nextkey()!=K_ESC
            SB->(DbSkip(-1))
          enddo
          if  (cName $ (SB->PASSENGER))
            SBScreen(VIEW_MODE)
            Message("Press ENTER to continue search, ESC to abort ...")
            nkey:=0
            do while (nKey!=K_ENTER) .and. (nkey!=K_ESC)
              nKey:=Inkey(0)
            enddo
            if nkey==K_ENTER; SB->(DbSkip(-1)); endif
          endif
        enddo
         if SB->(BOF()) .or. (SB->(!Found()) .and. nKey==K_ENTER)
          Tone(150,2)
          Message("Name not found....")
          SB->(DbGoTo(nRecNo))
          Inkey(1.5)
         endif
      endif
      SB->(DbSetOrder(1))
   endif
return nil

static function GetSummary()
local n1,n2,aChart:={},aAccounts:={},nSaveRecNo:=SB->(RecNo())
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
      /* Index SB by DATE. */
      SB->(DbSetOrder(2))
      SB->(DbSeek(SubStr(DToC(dStartDate),7,2)+"-"+ ;
                  SubStr(DToC(dStartDate),1,2) ))
      if SB->(Found())
         /* Find for requested start date */
         do while (SB->(!Eof())) .and. (CToD(SB->DATE)<dStartDate)
               SB->(DbSkip())   ; enddo
         /* Read SB file, check if record is within transaction dates. */
         do while (SB->(!Eof())) .and. (CToD(SB->DATE)<=dEndDate)
            /* Read all transactions of current SB record. */
            SBTRANS->(DbSeek(SB->(RecNo())))
            Message("Searching Sales Book (rec #"+ ;
                Transform(SB->(RecNo()),"999999")+")....")
            do while SBTRANS->REC_NO==SB->(RecNo())
               /* Accounts array lookup. */
               n1:=aScan(aChart,SBTRANS->ACCT_CODE)
               if n1>0
                  aAccounts[n1][A_DEBIT]:=aAccounts[n1][A_DEBIT] + ;
                     SBTRANS->DEBIT
                  nDebit:=nDebit+SBTRANS->DEBIT
                  aAccounts[n1][A_CREDIT]:=aAccounts[n1][A_CREDIT] + ;
                     SBTRANS->CREDIT
                  nCredit:=nCredit+SBTRANS->CREDIT
               endif
               SBTRANS->(DbSkip())
            enddo
            SB->(DbSkip())
         enddo
      endif
      SB->(DbSetOrder(1))
      SB->(DbGoTo(nSaveRecNo))
      /* Prepare SB Summary report. */
      Message("Preparing SB Summary Report....")
      Set(_SET_CONSOLE,.F.)
      Set(_SET_ALTFILE,"SBSUM.RPT")
      Set(_SET_ALTERNATE,.T.)
      ? "þSales Book - Summary Totals"
      ? "Period: "+CMonth(dEndDate)+" "+ ;
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
      cReport:=MemoRead("SBSUM.RPT")
      Message("Use cursor keys to navigate, press F10 to print, Esc to abort.")
      SetCursor(SC_NORMAL)
      wReport:=OpenWindow(3,1,21,77,"Sales Book - Summary Totals")
      nLFactor:=2
      MemoEdit(cReport,4,2,20,76,.F.,"EditorFunc",90)
      nLFactor:=1
      CloseWindow(wReport)
      SetCursor(SC_NONE)
   endif
return nil

static function Update()
local nSaveRec := SB->(RecNo()), cKey, x
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
      SB->(DbSetOrder(2))
      if SB->(DbSeek(SubStr(DToC(dStartDate),7,2)+"-"+ ;
                     SubStr(DToC(dStartDate),1,2) ))
         do while (SB->(!Eof())) .and. (CTOD(SB->DATE)<dStartDate)
              SB->(DbSkip())
         enddo
         do while (SB->(!Eof())) .and. (CTOD(SB->DATE)<=dEndDate)
            Message("Updating Subsidiary from Sales Book rec #"+;
                    transform(SB->(Recno()),"9999") )
            SBTRANS->(DbSeek(SB->(RecNo())))
            do while SBTRANS->REC_NO==SB->(RecNo())  
                if (mAcctCode==SBTRANS->ACCT_CODE) 
                   lNewRec:=.F.
                   do case
                      case xFmode==1
                         if empty(SB->AIR_CODE)
                             exit
                         endif
                         AIRLINE->(DbSeek(SB->AIR_CODE))
                         cKey:=substr(AIRLINE->AIRLINE,1,10)+upper(SB->PASSENGER)
                      case xFmode==2
                         if empty(SB->AGENT)
                             exit
                         endif
                         cKey:=substr(SB->AGENT,1,20)+upper(SB->PASSENGER)
                      case xFmode==3
                         if !empty(SB->AGENT) .and.;
                            ((cDbfName="ARTI") .or. (cDbfname="PRI"))
                             exit
                         endif
                         cKey:=upper(SB->PASSENGER)
                   endcase
                   if (nDbfArea)->(!DbSeek(cKey))
                      (nDbfArea)->(AddRec(0))   ; nDadd++
                      (nDbfArea)->(FilLock(0))
                      if xFmode != 1
                         (nDbfArea)->AIR_AGENCY:=SB->AGENT
                      else
                         if AIRLINE->(DbSeek(SB->AIR_CODE))
                            (nDbfArea)->AIR_AGENCY:=AIRLINE->AIRLINE
                         endif
                      endif
                      (nDbfArea)->PARTICULAR:=upper(SB->PASSENGER)
                      (nDbfArea)->DATE:=SB->DATE
                      (nDbfArea)->(DbUnlock())
                   endif
                   if ctod((nDbfArea)->DATE) > ctod(SB->DATE)
                      (nDbfArea)->(FilLock())
                      (nDbfArea)->DATE := SB->DATE
                      (nDbfArea)->(DbUnlock())
                   endif
                   if (nTransArea)->(!DbSeek((nDbfArea)->(RecNo())))
                      lNewRec:=.T.
                   else
                      do while ((nTransArea)->FOLIO!=SB->VOUCHER_NO) .and. ;
                               ((nTransArea)->REC_NO==(nDbfArea)->(RecNo())) .and. ;
                               (nTransArea)->(!Eof())
                         (nTransArea)->(DbSkip())
                      enddo
                      if ((nTransArea)->FOLIO!=SB->VOUCHER_NO) .or. ;
                         ((nTransArea)->REC_NO!=(nDbfArea)->(RecNo()))
                         lNewRec:=.T.
                      endif
                   endif
                   if lNewRec
                      (nTransArea)->(AddRec(0))  ; nTadd ++
                      (nTransArea)->(FilLock(0))
                      (nTransArea)->REC_NO := (nDbfArea)->(RecNo())
                      (nTransArea)->FOLIO := SB->VOUCHER_NO
                      (nTransArea)->(DbUnlock())   
                   endif
                   if ( (nTransArea)->REC_NO==(nDbfArea)->(RecNo()) )  .and.  ;
                      ( (nTransArea)->FOLIO==SB->VOUCHER_NO)
                      (nTransArea)->(FilLock(0))
                      (nTransArea)->DATE:=SB->DATE
                      (nTransArea)->DEBIT:=SBTRANS->DEBIT
                      (nTransArea)->CREDIT:=SBTRANS->CREDIT
                      (nTransArea)->DETAILS_1:=SB->DETAILS_1
                      (nTransArea)->DETAILS_2:=SB->DETAILS_2
                      (nTransArea)->(DbUnlock())
                   endif
                endif
                SBTRANS->(DbSkip())
            enddo
           SB->(DbSkip())
        enddo
      endif
      (nTransArea)->(DbCloseArea())
      (nDbfArea)->(DbCloseArea())
      SB->(DbGoto(nSaveRec))    
      SB->(DbSetOrder(1))
      Message("Status Report :  Added "+transform(nDadd,"99")+;
            " Entry,  "+transform(nTadd,"99")+" Transactions.")
      inkey(2)
   endif
return nil
// end-of-file