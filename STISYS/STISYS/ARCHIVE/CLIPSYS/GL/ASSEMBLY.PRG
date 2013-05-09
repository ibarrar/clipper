// Filename:      ASSEMBLY.PRG
// Module:        Assembly Sheet
// Author:        Arnold P. Caoile
// Date-Started:  April 06, 1992
// Last-Update:   June 29, 1992

#include "Inkey.ch"
#include "Setcurs.ch"
#include "Mode.ch"

function PrintAS()
local mAS,wAS,nCash:=nART:=nPreExp:=nAccumDep:=nDep:=Tax:=0.00
   if GetDates()
      dStartDate:=ctod("  -  -  ")
      NetUse("FSCREDIT",DB_SHARED,NUM_SECONDS)
      FSCREDIT->(DbSetIndex("FSCREDIT"))
      NetUse("FSDEBIT",DB_SHARED,NUM_SECONDS)
      FSDEBIT->(DbSetIndex("FSDEBIT"))
      /* Prepare Assembly Sheet report. */
      Message("Preparing Assembly Sheet....")
      Set(_SET_CONSOLE,.F.)
      Set(_SET_ALTFILE,"AS.RPT")
      Set(_SET_ALTERNATE,.T.)
      ? "Super Travel, Inc."
      ? "þ Assembly Sheet"
      ? "Period: "+CMonth(dEndDate)+" "
      ?? Transform(Year(dEndDate),"9999")
      ?
      ?
      ? "          Cash on Hand and in Banks          "
      ?
      ? "             Cash in Bank - CBC             P"
      ?? Transform(GetBal(DEBIT_BAL,"01-112"),SIGN_PIC)
      ? "             Cash in Bank - PCIB             "
      ?? Transform(GetBal(DEBIT_BAL,"01-111"),SIGN_PIC)
      ? "             Petty Cash Fund                 "
      ?? Transform(GetBal(DEBIT_BAL,"01-113"),SIGN_PIC)
      nCash:=GetBal(DEBIT_BAL,"01-112")+GetBal(DEBIT_BAL,"01-111")+ ;
         GetBal(DEBIT_BAL,"01-113")
      ? "                                             ",repl('-',13)
      ? "             Total ---->                    P"
      ?? Transform(nCash,SIGN_PIC)
      ? "                                             ",repl('=',13)
      ?

      ? "          Accounts Receivable - Trade        "
      ?
      ? "             Accounts Receivable - Travel   P"
      ?? Transform(GetBal(DEBIT_BAL,"01-121"),SIGN_PIC)
      ? "             Accounts Receivable - Airlines  "
      ?? Transform(GetBal(DEBIT_BAL,"01-122"),SIGN_PIC)
      ? "             Unbilled Airfare Tickets        "
      ?? Transform(GetBal(DEBIT_BAL,"01-123"),SIGN_PIC)
      nART:=GetBal(DEBIT_BAL,"01-121")+GetBal(DEBIT_BAL,"01-122")+ ;
         GetBal(DEBIT_BAL,"01-123")
      ? "                                             ",repl('-',13)
      ? "             Total ---->                    P"
      ?? Transform(nART,SIGN_PIC)
      ? "                                             ",repl('=',13)
      ?

      ? "          Prepaid Expenses                   "
      ?
      ? "             Prepaid Insurance              P"
      ?? Transform(GetBal(DEBIT_BAL,"01-152"),SIGN_PIC)
      ? "             Prepaid Expenses                "
      ?? Transform(GetBal(DEBIT_BAL,"01-151"),SIGN_PIC)
      nPreExp:=GetBal(DEBIT_BAL,"01-152")+GetBal(DEBIT_BAL,"01-151")
      ? "                                             ",repl('-',13)
      ? "             Total ---->                    P"
      ?? Transform(nPreExp,SIGN_PIC)
      ? "                                             ",repl('=',13)

      ?
      ? "          Deposit and Claims Receivable      "
      ?
      ? "             Deposit to PLDT                P"
      ?? Transform(GetBal(DEBIT_BAL,"03-111"),SIGN_PIC)
      ? "             Deposit to MERALCO              "
      ?? Transform(GetBal(DEBIT_BAL,"03-112"),SIGN_PIC)
      nDep:=GetBal(DEBIT_BAL,"03-111")+GetBal(DEBIT_BAL,"03-112")
      ? "                                             ",repl('-',13)
      ? "             Total ---->                    P"
      ?? Transform(nDep,SIGN_PIC)
      ? "                                             ",repl('=',13)
      ?

      ? "          Accumulated Depreciation           "
      ?
      ? "             Office Equipment               P"
      ?? Transform(GetBal(DEBIT_BAL,"02-212"),SIGN_PIC)
      ? "             Furnitures and Fixtures         "
      ?? Transform(GetBal(DEBIT_BAL,"02-211"),SIGN_PIC)
      ? "             Transportation Equipment        "
      ?? Transform(GetBal(DEBIT_BAL,"02-213"),SIGN_PIC)
      ? "             Leasehold Improvement           "
      ?? Transform(GetBal(DEBIT_BAL,"02-214"),SIGN_PIC)
      nAccumDep:=GetBal(DEBIT_BAL,"02-212")+GetBal(DEBIT_BAL,"02-211")+ ;
         GetBal(DEBIT_BAL,"02-213")+GetBal(DEBIT_BAL,"02-214")
      ? "                                             ",repl('-',13)
      ? "             Total ---->                    P"
      ?? Transform(nAccumDep,SIGN_PIC)
      ? "                                             ",repl('=',13)
      ?

      ? "          Accounts Payable - Trade           "
      ?
      ? "             Airfare Tickets Payable        P"
      ?? Transform(GetBal(CREDIT_BAL,"04-111"),SIGN_PIC)
      nATP:=GetBal(CREDIT_BAL,"04-111")
      ? "                                             ",repl('=',13)
      ?
      ?
      ?
      ?
      ?
      ? "          Taxes/SSS/MEDICARE/Salary Loan     "
      ?
      ? "             Withholding Tax Payable        P"
      ?? Transform(GetBal(CREDIT_BAL,"04-122"),SIGN_PIC)
      ? "             Expanded Withholding Tax Payable"
      ?? Transform(GetBal(CREDIT_BAL,"04-121"),SIGN_PIC)
      ? "             SSS/Medicare Payable            "
      ?? Transform(GetBal(CREDIT_BAL,"04-123"),SIGN_PIC)
      ? "             SSS Loan Payable                "
      ?? Transform(GetBal(CREDIT_BAL,"04-124"),SIGN_PIC)
      nTax:=GetBal(CREDIT_BAL,"04-122")+GetBal(CREDIT_BAL,"04-121")+ ;
         GetBal(CREDIT_BAL,"04-123")+GetBal(CREDIT_BAL,"04-124")
      ? "                                             ",repl('-',13)
      ? "             Total ---->                    P"
      ?? Transform(nTax,SIGN_PIC)
      ? "                                             ",repl('=',13)
      Set(_SET_CONSOLE,.T.)
      Set(_SET_ALTFILE,"")
      Set(_SET_ALTERNATE,.F.)
      close alternate
      cReport:=MemoRead("AS.RPT")
      Message("Use cursor keys to navigate, press F10 to print, Esc to abort.")
      SetCursor(SC_NORMAL)
      wAS:=OpenWindow(3,1,21,77,"Assembly Sheet")
      MemoEdit(cReport,4,2,20,76,.F.,"EditorFunc",120)
      CloseWindow(wAS)
      SetCursor(SC_NONE)
      FSDEBIT->(DbCloseArea())
      FSCREDIT->(DbCloseArea())
   endif
return nil

// end-of-file