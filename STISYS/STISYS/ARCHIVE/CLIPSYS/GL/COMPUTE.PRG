// Filename:      COMPUTE.PRG
// Module:        Debit/Credit Accounts Computation
// Author:        Arnold P. Caoile
// Date-Started:  May 18, 1992
// Last-Update:   June 29, 1992

#include "Inkey.ch"
#include "Mode.ch"
#include "Setcurs.ch"

function UpdateAccts()
local wUpd, n
   if !GetDates()
      return nil
   endif
   aSize(aCodes,0)
   aSize(aCurrAccts,0)
   Message("Opening databases....")
   NetUse("CHART",DB_SHARED,NUM_SECONDS)
   CHART->(DbSetIndex("CHT_CODE","CHART"))
   Message("Thinking....")
   /* Index CHART by ACCT_TITLE. */
   CHART->(DbSetOrder(2))
   CHART->(DbGoTop())
   /* Load account codes in Account array lookup. */
   do while CHART->(!Eof())
      aAdd(aCodes,{CHART->ACCT_CODE,CHART->ACCT_TITLE})
      aAdd(aCurrAccts,{0.00,0.00})
      CHART->(DbSKip())
   enddo
   /* Index CHART by ACCT_CODE. */
   CHART->(DbSetOrder(1))
   aCurrAccts:=doCompute(aCurrAccts,"")
   CHART->(DbCloseArea())
   NetUse("FSDEBIT",DB_SHARED,NUM_SECONDS)
   FSDEBIT->(DbSetIndex("FSDEBIT"))
   NetUse("FSCREDIT",DB_SHARED,NUM_SECONDS)
   FSCREDIT->(DbSetIndex("FSCREDIT"))
   Set(_SET_CONSOLE,.F.)
   Set(_SET_ALTERNATE,.T.)
   Set(_SET_ALTFILE,"ACCOUNTS.RPT")
   ? "þ Summary of Accounts"
   ? "as of ",dStartDate,"/",dEndDate
   ?
   ? "Code  ",Padr("Title",45," "),space(5),"Debit Total",space(5),"Credit Total"
   ?
   if FSDEBIT->(!DbSeek(dStartDate)) ; FSDEBIT->(AddRec(0)) ; endif
   if FSCREDIT->(!DbSeek(dStartDate)); FSCREDIT->(AddRec(0)); endif
   FSDEBIT->(FilLock(0))
   FSCREDIT->(FilLock(0))
   FSDEBIT->MONTH := dtoc(dStartDate)
   FSCREDIT->MONTH := dtoc(dStartDate)
   for x:=1 to len(aCodes)
      ? aCodes[x][1],substr(aCodes[x][2],1,45),;
        space(5),transform(aCurrAccts[x][A_DEBIT],NUM_PIC),;
        space(5),transform(aCurrAccts[x][A_CREDIT],NUM_PIC)
      FSDEBIT->&(Code2Field(aCodes[x][1])):=aCurrAccts[x][A_DEBIT]
      FSCREDIT->&(Code2Field(aCodes[x][1])):=aCurrAccts[x][A_CREDIT]
   next
   FSDEBIT->(DbUnlock())
   FSCREDIT->(DbUnlock())
   Set(_SET_CONSOLE,.T.)
   Set(_SET_ALTFILE,"")
   Set(_SET_ALTERNATE,.F.)
   cReport:=MemoRead("ACCOUNTS.RPT")
   wUpd:=OpenWindow(3,1,21,77,"Summary of Accounts")
   MemoEdit(cReport,4,2,20,76,.F.,"EditorFunc",90)
   CloseWindow(wUpd)
   SetCursor(SC_NONE)
   FSDEBIT->(DbCloseArea())
   FSCREDIT->(DbCloseArea())
return nil

static function doCompute(aAccount,cRemark)
   NetUse("CDB",DB_SHARED,NUM_SECONDS)
   CDB->(DbSetIndex("CDB_DATE"))
   NetUse("CDBTRANS",DB_SHARED,NUM_SECONDS)
   CDBTRANS->(DbSetIndex("CDBTRANS"))
   NetUse("CRB",DB_SHARED,NUM_SECONDS)
   CRB->(DbSetIndex("CRB_DATE"))
   NetUse("CRBTRANS",DB_SHARED,NUM_SECONDS)
   CRBTRANS->(DbSetIndex("CRBTRANS"))
   NetUse("SB",DB_SHARED,NUM_SECONDS)
   SB->(DbSetIndex("SB_DATE"))
   NetUse("SBTRANS",DB_SHARED,NUM_SECONDS)
   SBTRANS->(DbSetIndex("SBTRANS"))
   NetUse("JV",DB_SHARED,NUM_SECONDS)
   JV->(DbSetIndex("JV_DATE"))
   NetUse("JVTRANS",DB_SHARED,NUM_SECONDS)
   JVTRANS->(DbSetIndex("JVTRANS"))
   /* Read CDB file. */
   if DToC(dStartDate)=="  -  -  "
      CDB->(DbGoTop())
   else
      CDB->(DbSeek(SubStr(DToC(dStartDate),7,2)+"-"+ ;
         SubStr(DToC(dStartDate),1,2)))
   endif
   do while (CToD(CDB->DATE)<=dEndDate) .and. (CDB->(!Eof()))
      Message(cRemark+"Searching Cash Disbursement Book (rec #"+ ;
         Transform(CDB->(RecNo()),"999999")+")....")
         /* Read all transactions of current CDB record. */
         CDBTRANS->(DbSeek(CDB->(RecNo())))
         do while CDBTRANS->REC_NO==CDB->(RecNo())
            aCurrActs:=CDBTRANS->(AddAccount(aAccount))
            CDBTRANS->(DbSkip())
         enddo
      CDB->(DbSkip())
   enddo
   /* Read CRB file.  */
   if DToC(dStartDate)=="  -  -  "
      CRB->(DbGoTop())
   else
      CRB->(DbSeek(SubStr(DToC(dStartDate),7,2)+"-"+ ;
         SubStr(DToC(dStartDate),1,2)))
   endif
   do while (CToD(CRB->DATE)<=dEndDate) .and. (CRB->(!Eof()))
      Message(cRemark+"Searching Cash Receipts Book (rec #"+ ;
         Transform(CRB->(RecNo()),"999999")+")....")
         /* Read all transactions of current CRB record. */
         CRBTRANS->(DbSeek(CRB->(RecNo())))
         do while CRBTRANS->REC_NO==CRB->(RecNo())
            aCurrActs:=CRBTRANS->(AddAccount(aAccount))
            CRBTRANS->(DbSkip())
         enddo
      CRB->(DbSkip())
   enddo
   /* Read SB file until end-of-file. */
   if DToC(dStartDate)=="  -  -  "
      SB->(DbGoTop())
   else
      SB->(DbSeek(SubStr(DToC(dStartDate),7,2)+"-"+ ;
         SubStr(DToC(dStartDate),1,2)))
   endif
   do while (CtoD(SB->DATE)<=dEndDate) .and. (SB->(!Eof()))
      Message(cRemark+"Searching Sales Book (rec #"+ ;
         Transform(SB->(RecNo()),"999999")+")....")
         /* Read all transactions of current SB record. */
         SBTRANS->(DbSeek(SB->(RecNo())))
         do while SBTRANS->REC_NO==SB->(RecNo())
            aCurrActs:=SBTRANS->(AddAccount(aAccount))
            SBTRANS->(DbSkip())
         enddo
      SB->(DbSkip())
   enddo
   /* Read JV file until end-of-file. */
   if DToC(dStartDate)=="  -  -  "
      JV->(DbGoTop())
   else
      JV->(DbSeek(SubStr(DToC(dStartDate),7,2)+"-"+ ;
         SubStr(DToC(dStartDate),1,2)))
   endif
   do while (CToD(JV->DATE)<=dEndDate) .and. (JV->(!Eof()))
      Message(cRemark+"Searching Journal Vouchers (rec #"+ ;
         Transform(JV->(RecNo()),"999999")+")....")
         /* Read all transactions of current JV record. */
         JVTRANS->(DbSeek(JV->(RecNo())))
         do while JVTRANS->REC_NO==JV->(RecNo())
            aCurrActs:=JVTRANS->(AddAccount(aAccount))
            JVTRANS->(DbSkip())
         enddo
      JV->(DbSkip())
   enddo
   JV->(DbCloseArea())
   JVTRANS->(DbCloseArea())
   SB->(DbCloseArea())
   SBTRANS->(DbCloseArea())
   CRB->(DbCloseArea())
   CRBTRANS->(DbCloseArea())
   CDB->(DbCloseArea())
   CDBTRANS->(DbCloseArea())
return  aAccount

static function AddAccount(aAccount)
local x:=0
   x:=aScan(aCodes,{|z| z[1] == ACCT_CODE})
   if x>0
      aAccount[x][A_DEBIT]:=aAccount[x][A_DEBIT]+DEBIT
      aAccount[x][A_CREDIT]:=aAccount[x][A_CREDIT]+CREDIT
   endif
return aAccount

function GetBal(nMode,cCode)
local nBalance:=0
    if dStartDate == ctod("  -  -  ")
       FSDEBIT->(DbGotop())
       FSCREDIT->(DbGoTop())
    else
       FSDEBIT->(DbSeek(dStartDate))
       FSCREDIT->(DbSeek(dStartDate))
    endif
    do while (ctod(FSDEBIT->MONTH) < dEndDate) .and. (FSDEBIT->(!Eof()) )
       if nMode==DEBIT_BAL
          nBalance+= FSDEBIT->&(Code2Field(cCode)) - FSCREDIT->&(Code2Field(cCode))
       else
          nBalance+= FSCREDIT->&(Code2Field(cCode)) - FSDEBIT->&(Code2Field(cCode))
       endif
       FSDEBIT->(DbSkip())
       FSCREDIT->(DbSkip())
    enddo
return nBalance

static function Code2Field(cCode,lDebit)
return "F"+substr(cCode,1,2)+"_"+substr(cCode,4,3)
// end-of-file
