// Filename:      BALANCE.PRG
// Module:        Balance Sheet
// Author:        Arnold P. Caoile
// Date-Started:  April 10, 1992
// Last-Update:   June 29, 1992

#include "Inkey.ch"
#include "SetCurs.ch"
#include "Mode.ch"

function PrintBS()
local wBS,aLevel:=aTotals:={}
local dSaveEnd:=dDate1:=dDate2:=CTOD("  -  -  ")
local nCurAss:=nFixAss:=nOthAss:=nCurLia:=nEquity:=;
      nCurAss2:=nFixAss2:=nOthAss2:=nCurLia2:=nEquity2:=;
      nQtr1:=nQtr2:=nQtr3:=nQtr4:=n2Qtr1:=n2Qtr2:=n2Qtr3:=n2Qtr4:=0.00

   if GetDates()
      if !GetBegBal() ; return nil ; endif
      dSaveEnd:=dEndDate
      dDate1:=dEndDate
      dDate2:=ctod(substr(dtoc(dSaveEnd),1,6);
              +transform(year(dSaveEnd)-1901,"99") )
      dStartDate:=ctod("  -  -  ")
      NetUse("FSDEBIT",DB_SHARED,NUM_SECONDS)
      FSDEBIT->(DbSetIndex("FSDEBIT"))
      NetUse("FSCREDIT",DB_SHARED,NUM_SECONDS)
      FSCREDIT->(DbSetIndex("FSCREDIT"))
      Message("Preparing Balance Sheet....")
      Set(_SET_CONSOLE,.F.)
      Set(_SET_ALTFILE,"BS.RPT")
      Set(_SET_ALTERNATE,.T.)
      ? "Super Travel, Inc."
      ? "þComparative Balance Sheet"
      ? "As of",CMonth(dEndDate)+" "
      ?? Transform(Year(dEndDate),"9999"),"/ "
      ?? Transform(Year(dEndDate)-1,"9999")
      ?  
      ? "                                     ","     "+Transform(Year(dEndDate),;
        "9999")+"     ","     "+Transform(Year(dEndDate)-1,"9999")
      ? "                                     ","     ----     ","     ----"
      ?
      ? "Assets"
      ?
      ? "Current Assets:"
      ?
      dEndDate:=dDate1
      nCash:=GetBal(DEBIT_BAL,"01-111")+GetBal(DEBIT_BAL,"01-112")+ ;
         GetBal(DEBIT_BAL,"01-113")
      nArt:=GetBal(DEBIT_BAL,"01-121")+GetBal(DEBIT_BAL,"01-122")+ ;
         GetBal(DEBIT_BAL,"01-123")
      nPreExp:=GetBal(DEBIT_BAL,"01-151")+GetBal(DEBIT_BAL,"01-152")
      dEndDate:=dDate2
      nCash2:=GetBal(DEBIT_BAL,"01-111")+GetBal(DEBIT_BAL,"01-112")+ ;
         GetBal(DEBIT_BAL,"01-113")
      nArt2:=GetBal(DEBIT_BAL,"01-121")+GetBal(DEBIT_BAL,"01-122")+ ;
         GetBal(DEBIT_BAL,"01-123")
      nPreExp2:=GetBal(DEBIT_BAL,"01-151")+GetBal(DEBIT_BAL,"01-152")

      ? "   Cash on Hand and in Bank         P"
      ?? Transform(nCash,SIGN_PIC),"  P"
      ?? Transform(nCash2,SIGN_PIC)
      nCurAss:=nCash      ;      nCurAss2:=nCash2
      ? "   Accounts Receivable - Trade       "
      ?? Transform(nArt,SIGN_PIC),"   "
      ?? Transform(nArt2,SIGN_PIC)
      nCurAss+=nArt       ;      nCurAss2+=nArt2
      ? "   Accounts Receivable - Others      "
      dEndDate:=dDate1
      ?? Transform(GetBal(DEBIT_BAL,"01-131"),SIGN_PIC),"   "
      nCurAss+=GetBal(DEBIT_BAL,"01-131")
      dEndDate:=dDate2
      ?? Transform(GetBal(DEBIT_BAL,"01-131"),SIGN_PIC)
      nCurAss2+=GetBal(DEBIT_BAL,"01-131")

      ? "   Advances to Officers -            "
      dEndDate:=dDate1
      ?? Transform(GetBal(DEBIT_BAL,"01-141"),SIGN_PIC),"   "
      nCurAss+=GetBal(DEBIT_BAL,"01-141")
      dEndDate:=dDate2
      ?? Transform(GetBal(DEBIT_BAL,"01-141"),SIGN_PIC)
      nCurAss2+=GetBal(DEBIT_BAL,"01-141")

      ? "   Advances to Affiliates            "
      dEndDate:=dDate1
      ?? Transform(GetBal(DEBIT_BAL,"01-143"),SIGN_PIC),"   "
      nCurAss+=GetBal(DEBIT_BAL,"01-143")
      dEndDate:=dDate2
      ?? Transform(GetBal(DEBIT_BAL,"01-143"),SIGN_PIC)
      nCurAss2+=GetBal(DEBIT_BAL,"01-143")

      ? "   Advances for Passengers           "
      dEndDate:=dDate1
      ?? Transform(GetBal(DEBIT_BAL,"01-142"),SIGN_PIC),"   "
      nCurAss+=GetBal(DEBIT_BAL,"01-142")
      dEndDate:=dDate2
      ?? Transform(GetBal(DEBIT_BAL,"01-142"),SIGN_PIC)
      nCurAss2+=GetBal(DEBIT_BAL,"01-142")

      ? "   Advances Receivable - SSS         "
      dEndDate:=dDate1
      ?? Transform(GetBal(DEBIT_BAL,"01-132"),SIGN_PIC),"   "
      nCurAss+=GetBal(DEBIT_BAL,"01-132")
      dEndDate:=dDate2
      ?? Transform(GetBal(DEBIT_BAL,"01-132"),SIGN_PIC)
      nCurAss2+=GetBal(DEBIT_BAL,"01-132")

      ? "   Prepaid Expenses                  "
      ?? Transform(nPreExp,SIGN_PIC),"   "
      ?? Transform(nPreExp2,SIGN_PIC)
      nCurAss+=nPreExp      ;      nCurAss2+=nPreExp2
      ? "   Unused Office Supplies            "
      dEndDate:=dDate1
      ?? Transform(GetBal(DEBIT_BAL,"01-153"),SIGN_PIC),"   "
      nCurAss+=GetBal(DEBIT_BAL,"01-153")
      dEndDate:=dDate2
      ?? Transform(GetBal(DEBIT_BAL,"01-153"),SIGN_PIC)
      nCurAss2+=GetBal(DEBIT_BAL,"01-153")

      ? "                                     "
      ?? repl('-',14)+"   "+repl('-',14)
      ? "   Total Current Assets ---->       P"
      ?? Transform(nCurAss,SIGN_PIC),"  P"
      ?? Transform(nCurAss2,SIGN_PIC)
      ? "                                     "
      ?? repl('-',14)+"   "+repl('-',14)
      ?

      dEndDate:=dDate1
      nAccumDep:=GetBal(DEBIT_BAL,"02-211")+GetBal(DEBIT_BAL,"02-212")+ ;
         GetBal(DEBIT_BAL,"02-213")+GetBal(DEBIT_BAL,"02-214")
      dEndDate:=dDate2
      nAccumDep2:=GetBal(DEBIT_BAL,"02-211")+GetBal(DEBIT_BAL,"02-212")+ ;
         GetBal(DEBIT_BAL,"02-213")+GetBal(DEBIT_BAL,"02-214")
      ? "Fixed Assets:"
      ?
      ? "   Office Equipment                 P"
      dEndDate:=dDate1
      ?? Transform(GetBal(DEBIT_BAL,"02-112"),SIGN_PIC),"  P"
      nFixAss+=GetBal(DEBIT_BAL,"02-112")
      dEndDate:=dDate2
      ?? Transform(GetBal(DEBIT_BAL,"02-112"),SIGN_PIC)
      nFixAss2+=GetBal(DEBIT_BAL,"02-112")

      ? "   Furniture and Fixtures            "
      dEndDate:=dDate1
      ?? Transform(GetBal(DEBIT_BAL,"02-111"),SIGN_PIC),"   "
      nFixAss+=GetBal(DEBIT_BAL,"02-111")
      dEndDate:=dDate2
      ?? Transform(GetBal(DEBIT_BAL,"02-111"),SIGN_PIC)
      nFixAss2+=GetBal(DEBIT_BAL,"02-111")

      ? "   Transportation Equipment          "
      dEndDate:=dDate1
      ?? Transform(GetBal(DEBIT_BAL,"02-113"),SIGN_PIC),"   "
      nFixAss+=GetBal(DEBIT_BAL,"02-113")
      dEndDate:=dDate2
      ?? Transform(GetBal(DEBIT_BAL,"02-113"),SIGN_PIC)
      nFixAss2+=GetBal(DEBIT_BAL,"02-113")

      ? "   Leasehold Improvement             "
      dEndDate:=dDate1
      ?? Transform(GetBal(DEBIT_BAL,"02-114"),SIGN_PIC),"   "
      nFixAss+=GetBal(DEBIT_BAL,"02-114")
      dEndDate:=dDate2
      ?? Transform(GetBal(DEBIT_BAL,"02-114"),SIGN_PIC)
      nFixAss2+=GetBal(DEBIT_BAL,"02-114")

      ? "                                     "
      ?? repl('-',14)+"   "+repl('-',14)
      ? "   Total Fixed Assets ---->         P"
      ?? Transform(nFixAss,SIGN_PIC),"  P"
      ?? Transform(nFixAss2,SIGN_PIC)
      ? "   Less: Accumulated Depreciation    "
      ?? Transform(nAccumDep,SIGN_PIC),"   "
      ?? Transform(nAccumDep2,SIGN_PIC)
      nFixAss+=nAccumDep     ;      nFixAss2+=nAccumDep2
      ? "                                     "
      ?? repl('-',14)+"   "+repl('-',14)
      ? "   Net Depreciable Assets ---->     P"
      ?? Transform(nFixAss,SIGN_PIC),"  P"
      ?? Transform(nFixAss2,SIGN_PIC)
      ? "                                     "
      ?? repl('-',14)+"   "+repl('-',14)
      ?
      ? "Other Assets"
      ?
      dEndDate:=dDate1
      nDeposit:=GetBal(DEBIT_BAL,"03-111")+GetBal(DEBIT_BAL,"03-112")
      dEndDate:=dDate2
      nDeposit2:=GetBal(DEBIT_BAL,"03-111")+GetBal(DEBIT_BAL,"03-112")
      ? "   Deposit and Claims Receivable    P"
      ?? Transform(nDeposit,SIGN_PIC),"  P"
      ?? Transform(nDeposit2,SIGN_PIC)
      nOthAss+=nDeposit      ;      nOthAss2+=nDeposit2

      ? "   Investment on Shares of Stocks    "
      dEndDate:=dDate1
      ?? Transform(GetBal(DEBIT_BAL,"03-141"),SIGN_PIC),"   "
      nOthAss+=GetBal(DEBIT_BAL,"03-141")
      dEndDate:=dDate2
      ?? Transform(GetBal(DEBIT_BAL,"03-141"),SIGN_PIC)
      nOthAss2+=GetBal(DEBIT_BAL,"03-141")

      ? "   Utility and Rental Deposit        "
      dEndDate:=dDate1
      ?? Transform(GetBal(DEBIT_BAL,"03-113"),SIGN_PIC),"   "
      nOthAss+=GetBal(DEBIT_BAL,"03-113")
      dEndDate:=dDate2
      ?? Transform(GetBal(DEBIT_BAL,"03-113"),SIGN_PIC)
      nOthAss2+=GetBal(DEBIT_BAL,"03-113")

      ? "   Deferred Charges                  "
      dEndDate:=dDate1
      ?? Transform(GetBal(DEBIT_BAL,"03-131"),SIGN_PIC),"   "
      nOthAss+=GetBal(DEBIT_BAL,"03-131")
      dEndDate:=dDate2
      ?? Transform(GetBal(DEBIT_BAL,"03-131"),SIGN_PIC)
      nOthAss2+=GetBal(DEBIT_BAL,"03-131")

      ? "   VAT Input                         "
      dEndDate:=dDate1
      ?? Transform(GetBal(DEBIT_BAL,"03-161"),SIGN_PIC),"   "
      nOthAss+=GetBal(DEBIT_BAL,"03-161")
      dEndDate:=dDate2
      ?? Transform(GetBal(DEBIT_BAL,"03-161"),SIGN_PIC)
      nOthAss2+=GetBal(DEBIT_BAL,"03-161")

      ? "   Small Tools and Accessories       "
      dEndDate:=dDate1
      ?? Transform(GetBal(DEBIT_BAL,"03-151"),SIGN_PIC),"   "
      nOthAss+=GetBal(DEBIT_BAL,"03-151")
      dEndDate:=dDate2
      ?? Transform(GetBal(DEBIT_BAL,"03-151"),SIGN_PIC)
      nOthAss2+=GetBal(DEBIT_BAL,"03-151")

      ? "   Books and Journals                "
      dEndDate:=dDate1
      ?? Transform(GetBal(DEBIT_BAL,"03-121"),SIGN_PIC),"   "
      nOthAss+=GetBal(DEBIT_BAL,"03-121")
      dEndDate:=dDate2
      ?? Transform(GetBal(DEBIT_BAL,"03-121"),SIGN_PIC)
      nOthAss2+=GetBal(DEBIT_BAL,"03-121")

      ? "                                     "
      ?? repl('-',14)+"   "+repl('-',14)
      ? "   Total Other Assets ---->         P"
      ?? Transform(nOthAss,SIGN_PIC),"  P"
      ?? Transform(nOthAss2,SIGN_PIC)
      ? "                                     "
      ?? repl('-',14)+"   "+repl('-',14)
      ? "Total Assets ---->                  P"
      ?? Transform(nCurAss+nFixAss+nOthAss,SIGN_PIC),"  P"
      ?? Transform(nCurAss2+nFixAss2+nOthAss2,SIGN_PIC)
      ? "                                     "
      ?? repl('=',14)+"   "+repl('=',14)
      ?
      ?
      ?
      ?
      ?
      ?
      ? "Liabilities and Stockholder's Equity "
      ?
      dEndDate:=dDate1
      nTaxes:=GetBal(DEBIT_BAL,"04-121")+GetBal(DEBIT_BAL,"04-122")+ ;
         GetBal(DEBIT_BAL,"04-123")+GetBal(DEBIT_BAL,"04-124")
      dEndDate:=dDate2
      nTaxes2:=GetBal(DEBIT_BAL,"04-121")+GetBal(DEBIT_BAL,"04-122")+ ;
         GetBal(DEBIT_BAL,"04-123")+GetBal(DEBIT_BAL,"04-124")

      ? "Current Liabilities:"
      ?
      ? "   Accounts Payable - Trade         P"
      dEndDate:=dDate1
      ?? Transform(GetBal(CREDIT_BAL,"04-111"),SIGN_PIC),"  P"
      nCurLia+=GetBal(CREDIT_BAL,"04-111")
      dEndDate:=dDate2
      ?? Transform(GetBal(CREDIT_BAL,"04-111"),SIGN_PIC)
      nCurLia2+=GetBal(CREDIT_BAL,"04-111")

      ? "   Advances from Officers            "
      dEndDate:=dDate1
      ?? Transform(GetBal(CREDIT_BAL,"04-151"),SIGN_PIC),"   "
      nCurLia+=GetBal(CREDIT_BAL,"04-151")
      dEndDate:=dDate2
      ?? Transform(GetBal(CREDIT_BAL,"04-151"),SIGN_PIC)
      nCurLia2+=GetBal(CREDIT_BAL,"04-151")

      ? "   Accounts Payable - Others         "
      dEndDate:=dDate1
      ?? Transform(GetBal(CREDIT_BAL,"04-131"),SIGN_PIC),"   "
      nCurLia+=GetBal(CREDIT_BAL,"04-131")
      dEndDate:=dDate2
      ?? Transform(GetBal(CREDIT_BAL,"04-131"),SIGN_PIC)
      nCurLia2+=GetBal(CREDIT_BAL,"04-131")

      ? "   Passenger's Deposits              "
      dEndDate:=dDate1
      ?? Transform(GetBal(CREDIT_BAL,"04-171"),SIGN_PIC),"   "
      nCurLia+=GetBal(CREDIT_BAL,"04-171")
      dEndDate:=dDate2
      ?? Transform(GetBal(CREDIT_BAL,"04-171"),SIGN_PIC)
      nCurLia2+=GetBal(CREDIT_BAL,"04-171")

      ? "   Passenger's Refunds               "
      dEndDate:=dDate1
      ?? Transform(GetBal(CREDIT_BAL,"04-181"),SIGN_PIC),"   "
      nCurLia+=GetBal(CREDIT_BAL,"04-181")
      dEndDate:=dDate2
      ?? Transform(GetBal(CREDIT_BAL,"04-181"),SIGN_PIC)
      nCurLia2+=GetBal(CREDIT_BAL,"04-181")

      ? "   Accrued Expenses                  "
      dEndDate:=dDate1
      ?? Transform(GetBal(CREDIT_BAL,"04-141"),SIGN_PIC),"   "
      nCurLia+=GetBal(CREDIT_BAL,"04-141")
      dEndDate:=dDate2
      ?? Transform(GetBal(CREDIT_BAL,"04-141"),SIGN_PIC)
      nCurLia2+=GetBal(CREDIT_BAL,"04-141")

      ? "   Salaries Payables                 "
      dEndDate:=dDate1
      ?? Transform(GetBal(CREDIT_BAL,"04-1A1"),SIGN_PIC),"   "
      nCurLia+=GetBal(CREDIT_BAL,"04-1A1")
      dEndDate:=dDate2
      ?? Transform(GetBal(CREDIT_BAL,"04-1A1"),SIGN_PIC)
      nCurLia2+=GetBal(CREDIT_BAL,"04-1A1")

      ? "   Taxes,SSS,Medicare & Salary Loan  "
      ?? Transform(-nTaxes,SIGN_PIC),"   "
      ?? Transform(-nTaxes2,SIGN_PIC)
      nCurLia-=nTaxes     ;      nCurLia2-=nTaxes2

      ? "   VAT Payable                       "
      dEndDate:=dDate1
      ?? Transform(GetBal(CREDIT_BAL,"04-1B1"),SIGN_PIC),"   "
      nCurLia+=GetBal(CREDIT_BAL,"04-1B1")
      dEndDate:=dDate2
      ?? Transform(GetBal(CREDIT_BAL,"04-1B1"),SIGN_PIC)
      nCurLia2+=GetBal(CREDIT_BAL,"04-1B1")

      ? "   Income Tax Payable                "
      dEndDate:=dDate1
      ?? Transform(GetBal(CREDIT_BAL,"04-161"),SIGN_PIC),"   "
      nCurLia+=GetBal(CREDIT_BAL,"04-161")
      dEndDate:=dDate2
      ?? Transform(GetBal(CREDIT_BAL,"04-161"),SIGN_PIC)
      nCurLia2+=GetBal(CREDIT_BAL,"04-161")
      ? "                                     "
      ?? repl('-',14)+"   "+repl('-',14)
      ? "   Total Current Liabilities ---->  P"
      ?? Transform(nCurLia,SIGN_PIC),"  P"
      ?? Transform(nCurLia2,SIGN_PIC)
      ? "                                     "
      ?? repl('-',14)+"   "+repl('-',14)
      ?
      ? "Stockholder's Equity"
      ?

      ? "   Paid-Up Capital - Common         P"
      dEndDate:=dDate1
      ?? Transform(GetBal(CREDIT_BAL,"06-112"),SIGN_PIC),"  P"
      nEquity+=GetBal(CREDIT_BAL,"06-112")
      dEndDate:=dDate2
      ?? Transform(GetBal(CREDIT_BAL,"06-112"),SIGN_PIC)
      nEquity2+=GetBal(CREDIT_BAL,"06-112")

      ? "                   - Preferred       "
      dEndDate:=dDate1
      ?? Transform(GetBal(CREDIT_BAL,"06-111"),SIGN_PIC),"   "
      nEquity+=GetBal(CREDIT_BAL,"06-111")
      dEndDate:=dDate2
      ?? Transform(GetBal(CREDIT_BAL,"06-111"),SIGN_PIC)
      nEquity2+=GetBal(CREDIT_BAL,"06-111")

      ? "                                     "
      ?? repl('-',14)+"   "+repl('-',14)
      ? "   Total Paid-Up Capital ---->      P"
      ?? Transform(nEquity,SIGN_PIC),"  P"
      ?? Transform(nEquity2,SIGN_PIC)
      ?
      ? "   Retained Earnings:"
      ? "      Beginning Balance             P"
      ?? Transform(-nCurrDebit,SIGN_PIC),"  P"
      ?? Transform(-nPrevDebit,SIGN_PIC)  /**/
      nRetEarn:=-nCurrDebit       ;      nRetEarn2=-nPrevDebit
      ? "      Adjustments                    "
      dStartDate:=ctod("01-01-"+substr(dtoc(dSaveEnd),7,2))
      dEndDate:=dSaveEnd
      ?? Transform(GetBal(CREDIT_BAL,"06-121"),SIGN_PIC),"   "
      nRetEarn+=GetBal(CREDIT_BAL,"06-121")
      dStartDate:=ctod("01-01-"+transform(year(dSaveEnd)-1901,"99") )
      dEndDate:=ctod(substr(dtoc(dSaveEnd),1,6)+;
                 transform(year(dSaveEnd)-1901,"99") )
      ?? Transform(GetBal(CREDIT_BAL,"06-121"),SIGN_PIC)
      nRetEarn2+=GetBal(CREDIT_BAL,"06-121")
      ? "                                     "
      ?? repl('-',14)+"   "+repl('-',14)
      ? "      Total ---->                   P"
      ?? Transform(nRetEarn,SIGN_PIC),"  P"
      ?? Transform(nRetEarn2,SIGN_PIC)
      nEquity+=nRetEarn   ;   nEquity2+=nRetEarn2
      ?
      dEndDate:=dDate1
      dStartDate:=ctod("01-01-"+transform(year(dSaveEnd)-1900,"99"))
      if dSaveEnd > ctod("03-31-"+transform(year(dSaveEnd)-1900,"99"))
          dEndDate:=ctod("03-31-"+transform(year(dSaveEnd)-1900,"99"))
      endif
      nQtr1 := ISCompute()
      dEndDate:=dDate2
      dStartDate:=ctod("01-01-"+transform(year(dSaveEnd)-1901,"99"))
      if dSaveEnd > ctod("03-31-"+transform(year(dSaveEnd)-1900,"99"))
          dEndDate:=ctod("03-31-"+transform(year(dSaveEnd)-1901,"99"))
      endif
      n2Qtr1 := ISCompute()

      if dSaveEnd > ctod("03-31-"+transform(year(dSaveEnd)-1900,"99"))
          dEndDate:=dDate1
          dStartDate:=ctod("04-01-"+transform(year(dSaveEnd)-1900,"99"))
          if dSaveEnd > ctod("06-30-"+transform(year(dSaveEnd)-1900,"99"))
              dEndDate:=ctod("06-30-"+transform(year(dSaveEnd)-1900,"99"))
          endif
          nQtr2 := ISCompute()
          dEndDate:=dDate2
          dStartDate:=ctod("04-01-"+transform(year(dSaveEnd)-1901,"99"))
          if dSaveEnd > ctod("06-30-"+transform(year(dSaveEnd)-1900,"99"))
              dEndDate:=ctod("06-30-"+transform(year(dSaveEnd)-1901,"99"))
          endif
          n2Qtr2 := ISCompute()
      endif

      if dSaveEnd > ctod("06-30-"+transform(year(dSaveEnd)-1900,"99"))
          dEndDate:=dDate1
          dStartDate:=ctod("07-01-"+transform(year(dSaveEnd)-1900,"99"))
          if dSaveEnd > ctod("09-30-"+transform(year(dSaveEnd)-1900,"99"))
              dEndDate:=ctod("09-30-"+transform(year(dSaveEnd)-1900,"99"))
          endif
          nQtr3 := ISCompute()
          dEndDate:=dDate2
          dStartDate:=ctod("07-01-"+transform(year(dSaveEnd)-1901,"99"))
          if dSaveEnd > ctod("09-30-"+transform(year(dSaveEnd)-1900,"99"))
              dEndDate:=ctod("09-30-"+transform(year(dSaveEnd)-1901,"99"))
          endif
          n2Qtr3 := ISCompute()
      endif

      if dSaveEnd > ctod("09-30-"+transform(year(dSaveEnd)-1900,"99"))
          dEndDate:=dDate1
          dStartDate:=ctod("10-01-"+transform(year(dSaveEnd)-1900,"99"))
          if dSaveEnd > ctod("12-31-"+transform(year(dSaveEnd)-1900,"99"))
              dEndDate:=ctod("12-31-"+transform(year(dSaveEnd)-1900,"99"))
          endif
          nQtr4 := ISCompute()
          dEndDate:=dDate2
          dStartDate:=ctod("10-01-"+transform(year(dSaveEnd)-1901,"99"))
          if dSaveEnd > ctod("12-31-"+transform(year(dSaveEnd)-1900,"99"))
              dEndDate:=ctod("12-31-"+transform(year(dSaveEnd)-1901,"99"))
          endif
          n2Qtr4 := ISCompute()
      endif

      ? "   Add/Deduct: Income(LOSS)          "
      ? "      First Quarter                 P"
      ?? transform(nQtr1,SIGN_PIC),"  P"
      ?? transform(n2Qtr1,SIGN_PIC)
      ? "      Second Quarter                 "
      ?? transform(nQtr2,SIGN_PIC),"   "
      ?? transform(n2Qtr2,SIGN_PIC)
      ? "      Third Quarter                  "
      ?? transform(nQtr3,SIGN_PIC),"   "
      ?? transform(n2Qtr3,SIGN_PIC)
      ? "      Fourth Quarter                 "
      ?? transform(nQtr4,SIGN_PIC),"   "
      ?? transform(n2Qtr4,SIGN_PIC)
      nEquity += nQtr1+  nQtr2+  nQtr3+  nQtr4
      nEquity2+= n2Qtr1+ n2Qtr2+ n2Qtr3+ n2Qtr4
      ? "                                     "
      ?? repl('-',14)+"   "+repl('-',14)
      ? "   Net Retained Earnings ---->      P"
      ?? Transform(nEquity,SIGN_PIC),"  P"
      ?? Transform(nEquity2,SIGN_PIC)
      ? "                                     "
      ?? repl('-',14)+"   "+repl('-',14)
      ? "Total Liabilities &                  "
      ? "Stockholder's Equity ---->          P"
      ?? Transform(nCurLia+nEquity,SIGN_PIC),"  P"
      ?? Transform(nCurLia2+nEquity2,SIGN_PIC)
      ? "                                     "
      ?? repl('=',14)+"   "+repl('=',14)
      Set(_SET_CONSOLE,.T.)
      Set(_SET_ALTFILE,"")
      Set(_SET_ALTERNATE,.F.)
      close alternate
      FSDEBIT->(DbCloseArea())
      FSCREDIT->(DbCloseArea())
      cReport:=MemoRead("BS.RPT")
      Message("Use cursor keys to navigate, press F10 to print, Esc to abort.")
      SetCursor(SC_NORMAL)
      wBS:=OpenWindow(3,1,21,77,"Comparative Balance Sheet")
      MemoEdit(cReport,4,2,20,76,.F.,"EditorFunc",90)
      CloseWindow(wBS)
      SetCursor(SC_NONE)
   endif
return nil

static function IScompute()
local nGross, nExpenses, nOthers, nNet
      nGross:=GetBal(CREDIT_BAL,"09-101")
      nGross+=GetBal(CREDIT_BAL,"09-102")
      nGross+=GetBal(CREDIT_BAL,"09-103")
      nGross+=GetBal(DEBIT_BAL,"09-111")
      nGross+=GetBal(DEBIT_BAL,"09-112")

      nExpenses:=GetBal(DEBIT_BAL,"10-501")
      nExpenses+=GetBal(DEBIT_BAL,"10-516")
      nExpenses+=GetBal(DEBIT_BAL,"10-517")
      nExpenses+=GetBal(DEBIT_BAL,"10-503")
      nExpenses+=GetBal(DEBIT_BAL,"10-514")
      nExpenses+=GetBal(DEBIT_BAL,"10-502")
      nExpenses+=GetBal(DEBIT_BAL,"10-505")
      nExpenses+=GetBal(DEBIT_BAL,"10-504")
      nExpenses+=GetBal(DEBIT_BAL,"10-511")
      nExpenses+=GetBal(DEBIT_BAL,"10-512")
      nExpenses+=GetBal(DEBIT_BAL,"10-513")
      nExpenses+=GetBal(DEBIT_BAL,"10-509")
      nExpenses+=GetBal(DEBIT_BAL,"10-510")
      nExpenses+=GetBal(DEBIT_BAL,"10-525")
      nExpenses+=GetBal(DEBIT_BAL,"10-526")
      nExpenses+=GetBal(DEBIT_BAL,"10-515")
      nExpenses+=GetBal(DEBIT_BAL,"10-523")
      nExpenses+=GetBal(DEBIT_BAL,"10-524")
      nExpenses+=GetBal(DEBIT_BAL,"10-529")
      nExpenses+=GetBal(DEBIT_BAL,"10-527")
      nExpenses+=GetBal(DEBIT_BAL,"10-532")
      nExpenses+=GetBal(DEBIT_BAL,"10-518")
      nExpenses+=GetBal(DEBIT_BAL,"10-519")
      nExpenses+=GetBal(DEBIT_BAL,"10-520")
      nExpenses+=GetBal(DEBIT_BAL,"10-521")
      nExpenses+=GetBal(DEBIT_BAL,"10-534")
      nExpenses+=GetBal(DEBIT_BAL,"10-522")
      nExpenses+=GetBal(DEBIT_BAL,"10-506")
      nExpenses+=GetBal(DEBIT_BAL,"10-530")
      nExpenses+=GetBal(DEBIT_BAL,"10-507")
      nExpenses+=GetBal(DEBIT_BAL,"10-508")
      nExpenses+=GetBal(DEBIT_BAL,"10-533")

      nOthers:=GetBal(CREDIT_BAL,"09-202")
      nOthers+=GetBal(CREDIT_BAL,"09-201")
      nOthers+=GetBal(CREDIT_BAL,"09-113")
      nOthers+=GetBal(CREDIT_BAL,"09-203")

      nNet := nGross - nExpenses + nOthers

      nNet-=GetBal(DEBIT_BAL,"10-531")
      nNet-=GetBal(DEBIT_BAL,"04-191")
return nNet
// end-of-file