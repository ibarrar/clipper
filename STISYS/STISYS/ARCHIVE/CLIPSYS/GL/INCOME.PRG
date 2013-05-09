// Filename:      INCOME.PRG
// Module:        Income Statement
// Author:        Arnold P. Caoile
// Date-Started:  April 10, 1992
// Last-Update:   June 29, 1992

#include "Inkey.ch"
#include "SetCurs.ch"
#include "Mode.ch"

function PrintIS()
local wIS,;
      nNetInc :=nOpExp :=nOthInc :=0.00, ;
      nNetInc2:=nOpExp2:=nOthInc2:=0.00, ;
      nNetInc3:=nOpExp3:=nOthInc3:=0.00, ;
      nNetInc4:=nOpExp4:=nOthInc4:=0.00
local dSaveEnd:=dEDate1:=dEDate2:=dEDate3:=dEDate4:=;
      dSaveStart:=dSDate1:=dSDate2:=dSDate3:=dSDate4:=ctod("  -  -  ")
   if GetDates()

      dSaveEnd:=dEndDate   ; dSaveStart:=dStartDate
      dSDate1:=dStartDate
      dSDate2:=ctod(substr(dtoc(dSaveStart),1,6);
              +transform(year(dSaveStart)-1901,"99") )
      dEDate1:=dEndDate
      dEDate2:=ctod(substr(dtoc(dSaveEnd),1,6);
              +transform(year(dSaveEnd)-1901,"99") )
      dSDate3:=ctod("01-01-"+substr(dtoc(dSaveEnd),7,2))
      dEDate3:=dEndDate
      dSDate4:=ctod("01-01-"+transform(year(dSaveEnd)-1901,"99") )
      dEDate4:=ctod(substr(dtoc(dSaveEnd),1,6)+;
                 transform(year(dSaveEnd)-1901,"99") )
      NetUse("FSDEBIT",DB_SHARED,NUM_SECONDS)
      FSDEBIT->(DbSetIndex("FSDEBIT"))
      NetUse("FSCREDIT",DB_SHARED,NUM_SECONDS)
      FSCREDIT->(DbSetIndex("FSCREDIT"))
      Message("Preparing Income Statement....")
      Set(_SET_CONSOLE,.F.)
      Set(_SET_ALTFILE,"IS.RPT")
      Set(_SET_ALTERNATE,.T.)
      ? "Super Travel, Inc."
      ? "þComparative Income Statement"
      ? "For the Month of",CMonth(dEndDate)+" ",;
         Transform(Year(dEndDate),"9999"),"/ ",;
         Transform(Year(dEndDate)-1,"9999")
      ?
      ? "                              ",space(10),"This Month",space(18),"This Year"
      ? "                              ",space(10),"----------",space(18),"---------"
      ? "                              ",space(8),;
         Transform(Year(dEndDate),"9999"),space(8),Transform(Year(dEndDate)-1,"9999"),space(8),;
         Transform(Year(dEndDate),"9999"),space(8),Transform(Year(dEndDate)-1,"9999")
      ?
      ? "Gross Income:                 "
      ? "   Commission Income         P"
      dStartDate:=dSDate1     ;  dEndDate:=dEDate1
      ?? Transform(GetBal(CREDIT_BAL,"09-101"),SIGN_PIC),+" P"
      nNetInc+=GetBal(CREDIT_BAL,"09-101")
      dStartDate:=dSDate2     ;  dEndDate:=dEDate2
      ?? Transform(GetBal(CREDIT_BAL,"09-101"),SIGN_PIC),+" P"
      nNetInc2+=GetBal(CREDIT_BAL,"09-101")
      dStartDate:=dSDate3     ;  dEndDate:=dEDate3
      ?? Transform(GetBal(CREDIT_BAL,"09-101"),SIGN_PIC),+" P"
      nNetInc3+=GetBal(CREDIT_BAL,"09-101")
      dStartDate:=dSDate4     ;  dEndDate:=dEDate4
      ?? Transform(GetBal(CREDIT_BAL,"09-101"),SIGN_PIC)
      nNetInc4+=GetBal(CREDIT_BAL,"09-101")

      ? "   Commission Income (Non-VAT)"
      dStartDate:=dSDate1     ;  dEndDate:=dEDate1
      ?? Transform(GetBal(CREDIT_BAL,"09-102"),SIGN_PIC),+"  "
      nNetInc+=GetBal(CREDIT_BAL,"09-102")
      dStartDate:=dSDate2     ;  dEndDate:=dEDate2
      ?? Transform(GetBal(CREDIT_BAL,"09-102"),SIGN_PIC),+"  "
      nNetInc2+=GetBal(CREDIT_BAL,"09-102")
      dStartDate:=dSDate3     ;  dEndDate:=dEDate3
      ?? Transform(GetBal(CREDIT_BAL,"09-102"),SIGN_PIC),+"  "
      nNetInc3+=GetBal(CREDIT_BAL,"09-102")
      dStartDate:=dSDate4     ;  dEndDate:=dEDate4
      ?? Transform(GetBal(CREDIT_BAL,"09-102"),SIGN_PIC)
      nNetInc4+=GetBal(CREDIT_BAL,"09-102")

      ? "   Service Fee                "
      dStartDate:=dSDate1     ;  dEndDate:=dEDate1
      ?? Transform(GetBal(CREDIT_BAL,"09-103"),SIGN_PIC),+"  "
      nNetInc+=GetBal(CREDIT_BAL,"09-103")
      dStartDate:=dSDate2     ;  dEndDate:=dEDate2
      ?? Transform(GetBal(CREDIT_BAL,"09-103"),SIGN_PIC),+"  "
      nNetInc2+=GetBal(CREDIT_BAL,"09-103")
      dStartDate:=dSDate3     ;  dEndDate:=dEDate3
      ?? Transform(GetBal(CREDIT_BAL,"09-103"),SIGN_PIC),+"  "
      nNetInc3+=GetBal(CREDIT_BAL,"09-103")
      dStartDate:=dSDate4     ;  dEndDate:=dEDate4
      ?? Transform(GetBal(CREDIT_BAL,"09-103"),SIGN_PIC)
      nNetInc4+=GetBal(CREDIT_BAL,"09-103")

      ? "                              "
      ?? repl('-',14)+"  "+repl('-',14)+"  "+;
         repl('-',14)+"  "+repl('-',14)
      ? "Total ---->                  P"
      ?? Transform(nNetInc,SIGN_PIC),+" P"
      ?? Transform(nNetInc2,SIGN_PIC),+" P"
      ?? Transform(nNetInc3,SIGN_PIC),+" P"
      ?? Transform(nNetInc4,SIGN_PIC)
      ?

      ? "Pax Discount - Commission    P"
      dStartDate:=dSDate1     ;  dEndDate:=dEDate1
      ?? Transform(GetBal(DEBIT_BAL,"09-111"),SIGN_PIC),+" P"
      nNetInc+=GetBal(DEBIT_BAL,"09-111")
      dStartDate:=dSDate2     ;  dEndDate:=dEDate2
      ?? Transform(GetBal(DEBIT_BAL,"09-111"),SIGN_PIC),+" P"
      nNetInc2+=GetBal(DEBIT_BAL,"09-111")
      dStartDate:=dSDate3     ;  dEndDate:=dEDate3
      ?? Transform(GetBal(DEBIT_BAL,"09-111"),SIGN_PIC),+" P"
      nNetInc3+=GetBal(DEBIT_BAL,"09-111")
      dStartDate:=dSDate4     ;  dEndDate:=dEDate4
      ?? Transform(GetBal(DEBIT_BAL,"09-111"),SIGN_PIC)
      nNetInc4+=GetBal(DEBIT_BAL,"09-111")

      ? "Pax Discount - Service Fee    "
      dStartDate:=dSDate1     ;  dEndDate:=dEDate1
      ?? Transform(GetBal(DEBIT_BAL,"09-112"),SIGN_PIC),+"  "
      nNetInc+=GetBal(DEBIT_BAL,"09-112")
      dStartDate:=dSDate2     ;  dEndDate:=dEDate2
      ?? Transform(GetBal(DEBIT_BAL,"09-112"),SIGN_PIC),+"  "
      nNetInc2+=GetBal(DEBIT_BAL,"09-112")
      dStartDate:=dSDate3     ;  dEndDate:=dEDate3
      ?? Transform(GetBal(DEBIT_BAL,"09-112"),SIGN_PIC),+"  "
      nNetInc3+=GetBal(DEBIT_BAL,"09-112")
      dStartDate:=dSDate4     ;  dEndDate:=dEDate4
      ?? Transform(GetBal(DEBIT_BAL,"09-112"),SIGN_PIC)
      nNetInc4+=GetBal(DEBIT_BAL,"09-112")

      ? "                              "
      ?? repl('-',14)+"  "+repl('-',14)+"  "+;
         repl('-',14)+"  "+repl('-',14)
      ? "Net Income ---->             P"
      ?? Transform(nNetInc,SIGN_PIC),+" P"
      ?? Transform(nNetInc2,SIGN_PIC),+" P"
      ?? Transform(nNetInc3,SIGN_PIC),+" P"
      ?? Transform(nNetInc4,SIGN_PIC)
      ?

      ? "Operating Expenses:           "
      ? "   Salaries & Wages          P"
      dStartDate:=dSDate1     ;  dEndDate:=dEDate1
      ?? Transform(GetBal(DEBIT_BAL,"10-501"),SIGN_PIC),+" P"
      nOpExp+=GetBal(DEBIT_BAL,"10-501")
      dStartDate:=dSDate2     ;  dEndDate:=dEDate2
      ?? Transform(GetBal(DEBIT_BAL,"10-501"),SIGN_PIC),+" P"
      nOpExp2+=GetBal(DEBIT_BAL,"10-501")
      dStartDate:=dSDate3     ;  dEndDate:=dEDate3
      ?? Transform(GetBal(DEBIT_BAL,"10-501"),SIGN_PIC),+" P"
      nOpExp3+=GetBal(DEBIT_BAL,"10-501")
      dStartDate:=dSDate4     ;  dEndDate:=dEDate4
      ?? Transform(GetBal(DEBIT_BAL,"10-501"),SIGN_PIC)
      nOpExp4+=GetBal(DEBIT_BAL,"10-501")

      ? "   Employee Incentive         "
      dStartDate:=dSDate1     ;  dEndDate:=dEDate1
      ?? Transform(GetBal(DEBIT_BAL,"10-516"),SIGN_PIC),+"  "
      nOpExp+=GetBal(DEBIT_BAL,"10-516")
      dStartDate:=dSDate2     ;  dEndDate:=dEDate2
      ?? Transform(GetBal(DEBIT_BAL,"10-516"),SIGN_PIC),+"  "
      nOpExp2+=GetBal(DEBIT_BAL,"10-516")
      dStartDate:=dSDate3     ;  dEndDate:=dEDate3
      ?? Transform(GetBal(DEBIT_BAL,"10-516"),SIGN_PIC),+"  "
      nOpExp3+=GetBal(DEBIT_BAL,"10-516")
      dStartDate:=dSDate4     ;  dEndDate:=dEDate4
      ?? Transform(GetBal(DEBIT_BAL,"10-516"),SIGN_PIC)
      nOpExp4+=GetBal(DEBIT_BAL,"10-516")

      ? "   13th Month Pay             "
      dStartDate:=dSDate1     ;  dEndDate:=dEDate1
      ?? Transform(GetBal(DEBIT_BAL,"10-517"),SIGN_PIC),+"  "
      nOpExp+=GetBal(DEBIT_BAL,"10-517")
      dStartDate:=dSDate2     ;  dEndDate:=dEDate2
      ?? Transform(GetBal(DEBIT_BAL,"10-517"),SIGN_PIC),+"  "
      nOpExp2+=GetBal(DEBIT_BAL,"10-517")
      dStartDate:=dSDate3     ;  dEndDate:=dEDate3
      ?? Transform(GetBal(DEBIT_BAL,"10-517"),SIGN_PIC),+"  "
      nOpExp3+=GetBal(DEBIT_BAL,"10-517")
      dStartDate:=dSDate4     ;  dEndDate:=dEDate4
      ?? Transform(GetBal(DEBIT_BAL,"10-517"),SIGN_PIC)
      nOpExp4+=GetBal(DEBIT_BAL,"10-517")

      ? "   Rent Expenses              "
      dStartDate:=dSDate1     ;  dEndDate:=dEDate1
      ?? Transform(GetBal(DEBIT_BAL,"10-503"),SIGN_PIC),+"  "
      nOpExp+=GetBal(DEBIT_BAL,"10-503")
      dStartDate:=dSDate2     ;  dEndDate:=dEDate2
      ?? Transform(GetBal(DEBIT_BAL,"10-503"),SIGN_PIC),+"  "
      nOpExp2+=GetBal(DEBIT_BAL,"10-503")
      dStartDate:=dSDate3     ;  dEndDate:=dEDate3
      ?? Transform(GetBal(DEBIT_BAL,"10-503"),SIGN_PIC),+"  "
      nOpExp3+=GetBal(DEBIT_BAL,"10-503")
      dStartDate:=dSDate4     ;  dEndDate:=dEDate4
      ?? Transform(GetBal(DEBIT_BAL,"10-503"),SIGN_PIC)
      nOpExp4+=GetBal(DEBIT_BAL,"10-503")

      ? "   Light & Water              "
      dStartDate:=dSDate1     ;  dEndDate:=dEDate1
      ?? Transform(GetBal(DEBIT_BAL,"10-514"),SIGN_PIC),+"  "
      nOpExp+=GetBal(DEBIT_BAL,"10-514")
      dStartDate:=dSDate2     ;  dEndDate:=dEDate2
      ?? Transform(GetBal(DEBIT_BAL,"10-514"),SIGN_PIC),+"  "
      nOpExp2+=GetBal(DEBIT_BAL,"10-514")
      dStartDate:=dSDate3     ;  dEndDate:=dEDate3
      ?? Transform(GetBal(DEBIT_BAL,"10-514"),SIGN_PIC),+"  "
      nOpExp3+=GetBal(DEBIT_BAL,"10-514")
      dStartDate:=dSDate4     ;  dEndDate:=dEDate4
      ?? Transform(GetBal(DEBIT_BAL,"10-514"),SIGN_PIC)
      nOpExp4+=GetBal(DEBIT_BAL,"10-514")

      ? "   Emergency Living Allowance "
      dStartDate:=dSDate1     ;  dEndDate:=dEDate1
      ?? Transform(GetBal(DEBIT_BAL,"10-502"),SIGN_PIC),+"  "
      nOpExp+=GetBal(DEBIT_BAL,"10-502")
      dStartDate:=dSDate2     ;  dEndDate:=dEDate2
      ?? Transform(GetBal(DEBIT_BAL,"10-502"),SIGN_PIC),+"  "
      nOpExp2+=GetBal(DEBIT_BAL,"10-502")
      dStartDate:=dSDate3     ;  dEndDate:=dEDate3
      ?? Transform(GetBal(DEBIT_BAL,"10-502"),SIGN_PIC),+"  "
      nOpExp3+=GetBal(DEBIT_BAL,"10-502")
      dStartDate:=dSDate4     ;  dEndDate:=dEDate4
      ?? Transform(GetBal(DEBIT_BAL,"10-502"),SIGN_PIC)
      nOpExp4+=GetBal(DEBIT_BAL,"10-502")

      ? "   Telex,Telephone & Telegraph"
      dStartDate:=dSDate1     ;  dEndDate:=dEDate1
      ?? Transform(GetBal(DEBIT_BAL,"10-505"),SIGN_PIC),+"  "
      nOpExp+=GetBal(DEBIT_BAL,"10-505")
      dStartDate:=dSDate2     ;  dEndDate:=dEDate2
      ?? Transform(GetBal(DEBIT_BAL,"10-505"),SIGN_PIC),+"  "
      nOpExp2+=GetBal(DEBIT_BAL,"10-505")
      dStartDate:=dSDate3     ;  dEndDate:=dEDate3
      ?? Transform(GetBal(DEBIT_BAL,"10-505"),SIGN_PIC),+"  "
      nOpExp3+=GetBal(DEBIT_BAL,"10-505")
      dStartDate:=dSDate4     ;  dEndDate:=dEDate4
      ?? Transform(GetBal(DEBIT_BAL,"10-505"),SIGN_PIC)
      nOpExp4+=GetBal(DEBIT_BAL,"10-505")

      ? "   Advertising Expenses       "
      dStartDate:=dSDate1     ;  dEndDate:=dEDate1
      ?? Transform(GetBal(DEBIT_BAL,"10-504"),SIGN_PIC),+"  "
      nOpExp+=GetBal(DEBIT_BAL,"10-504")
      dStartDate:=dSDate2     ;  dEndDate:=dEDate2
      ?? Transform(GetBal(DEBIT_BAL,"10-504"),SIGN_PIC),+"  "
      nOpExp2+=GetBal(DEBIT_BAL,"10-504")
      dStartDate:=dSDate3     ;  dEndDate:=dEDate3
      ?? Transform(GetBal(DEBIT_BAL,"10-504"),SIGN_PIC),+"  "
      nOpExp3+=GetBal(DEBIT_BAL,"10-504")
      dStartDate:=dSDate4     ;  dEndDate:=dEDate4
      ?? Transform(GetBal(DEBIT_BAL,"10-504"),SIGN_PIC)
      nOpExp4+=GetBal(DEBIT_BAL,"10-504")

      ? "   Personnel Training         "
      dStartDate:=dSDate1     ;  dEndDate:=dEDate1
      ?? Transform(GetBal(DEBIT_BAL,"10-511"),SIGN_PIC),+"  "
      nOpExp+=GetBal(DEBIT_BAL,"10-511")
      dStartDate:=dSDate2     ;  dEndDate:=dEDate2
      ?? Transform(GetBal(DEBIT_BAL,"10-511"),SIGN_PIC),+"  "
      nOpExp2+=GetBal(DEBIT_BAL,"10-511")
      dStartDate:=dSDate3     ;  dEndDate:=dEDate3
      ?? Transform(GetBal(DEBIT_BAL,"10-511"),SIGN_PIC),+"  "
      nOpExp3+=GetBal(DEBIT_BAL,"10-511")
      dStartDate:=dSDate4     ;  dEndDate:=dEDate4
      ?? Transform(GetBal(DEBIT_BAL,"10-511"),SIGN_PIC)
      nOpExp4+=GetBal(DEBIT_BAL,"10-511")

      ? "   Representation Expense     "
      dStartDate:=dSDate1     ;  dEndDate:=dEDate1
      ?? Transform(GetBal(DEBIT_BAL,"10-512"),SIGN_PIC),+"  "
      nOpExp+=GetBal(DEBIT_BAL,"10-512")
      dStartDate:=dSDate2     ;  dEndDate:=dEDate2
      ?? Transform(GetBal(DEBIT_BAL,"10-512"),SIGN_PIC),+"  "
      nOpExp2+=GetBal(DEBIT_BAL,"10-512")
      dStartDate:=dSDate3     ;  dEndDate:=dEDate3
      ?? Transform(GetBal(DEBIT_BAL,"10-512"),SIGN_PIC),+"  "
      nOpExp3+=GetBal(DEBIT_BAL,"10-512")
      dStartDate:=dSDate4     ;  dEndDate:=dEDate4
      ?? Transform(GetBal(DEBIT_BAL,"10-512"),SIGN_PIC)
      nOpExp4+=GetBal(DEBIT_BAL,"10-512")

      ? "   Transportation & Travel    "
      dStartDate:=dSDate1     ;  dEndDate:=dEDate1
      ?? Transform(GetBal(DEBIT_BAL,"10-513"),SIGN_PIC),+"  "
      nOpExp+=GetBal(DEBIT_BAL,"10-513")
      dStartDate:=dSDate2     ;  dEndDate:=dEDate2
      ?? Transform(GetBal(DEBIT_BAL,"10-513"),SIGN_PIC),+"  "
      nOpExp2+=GetBal(DEBIT_BAL,"10-513")
      dStartDate:=dSDate3     ;  dEndDate:=dEDate3
      ?? Transform(GetBal(DEBIT_BAL,"10-513"),SIGN_PIC),+"  "
      nOpExp3+=GetBal(DEBIT_BAL,"10-513")
      dStartDate:=dSDate4     ;  dEndDate:=dEDate4
      ?? Transform(GetBal(DEBIT_BAL,"10-513"),SIGN_PIC)
      nOpExp4+=GetBal(DEBIT_BAL,"10-513")

      ? "   Taxes & Licenses           "
      dStartDate:=dSDate1     ;  dEndDate:=dEDate1
      ?? Transform(GetBal(DEBIT_BAL,"10-509"),SIGN_PIC),+"  "
      nOpExp+=GetBal(DEBIT_BAL,"10-509")
      dStartDate:=dSDate2     ;  dEndDate:=dEDate2
      ?? Transform(GetBal(DEBIT_BAL,"10-509"),SIGN_PIC),+"  "
      nOpExp2+=GetBal(DEBIT_BAL,"10-509")
      dStartDate:=dSDate3     ;  dEndDate:=dEDate3
      ?? Transform(GetBal(DEBIT_BAL,"10-509"),SIGN_PIC),+"  "
      nOpExp3+=GetBal(DEBIT_BAL,"10-509")
      dStartDate:=dSDate4     ;  dEndDate:=dEDate4
      ?? Transform(GetBal(DEBIT_BAL,"10-509"),SIGN_PIC)
      nOpExp4+=GetBal(DEBIT_BAL,"10-509")

      ? "   Prof. & Retainer's Fee     "
      dStartDate:=dSDate1     ;  dEndDate:=dEDate1
      ?? Transform(GetBal(DEBIT_BAL,"10-510"),SIGN_PIC),+"  "
      nOpExp+=GetBal(DEBIT_BAL,"10-510")
      dStartDate:=dSDate2     ;  dEndDate:=dEDate2
      ?? Transform(GetBal(DEBIT_BAL,"10-510"),SIGN_PIC),+"  "
      nOpExp2+=GetBal(DEBIT_BAL,"10-510")
      dStartDate:=dSDate3     ;  dEndDate:=dEDate3
      ?? Transform(GetBal(DEBIT_BAL,"10-510"),SIGN_PIC),+"  "
      nOpExp3+=GetBal(DEBIT_BAL,"10-510")
      dStartDate:=dSDate4     ;  dEndDate:=dEDate4
      ?? Transform(GetBal(DEBIT_BAL,"10-510"),SIGN_PIC)
      nOpExp4+=GetBal(DEBIT_BAL,"10-510")

      ? "   Office Supplies            "
      dStartDate:=dSDate1     ;  dEndDate:=dEDate1
      ?? Transform(GetBal(DEBIT_BAL,"10-525"),SIGN_PIC),+"  "
      nOpExp+=GetBal(DEBIT_BAL,"10-525")
      dStartDate:=dSDate2     ;  dEndDate:=dEDate2
      ?? Transform(GetBal(DEBIT_BAL,"10-525"),SIGN_PIC),+"  "
      nOpExp2+=GetBal(DEBIT_BAL,"10-525")
      dStartDate:=dSDate3     ;  dEndDate:=dEDate3
      ?? Transform(GetBal(DEBIT_BAL,"10-525"),SIGN_PIC),+"  "
      nOpExp3+=GetBal(DEBIT_BAL,"10-525")
      dStartDate:=dSDate4     ;  dEndDate:=dEDate4
      ?? Transform(GetBal(DEBIT_BAL,"10-525"),SIGN_PIC)
      nOpExp4+=GetBal(DEBIT_BAL,"10-525")

      ? "   Postage & Docu. Stamps     "
      dStartDate:=dSDate1     ;  dEndDate:=dEDate1
      ?? Transform(GetBal(DEBIT_BAL,"10-526"),SIGN_PIC),+"  "
      nOpExp+=GetBal(DEBIT_BAL,"10-526")
      dStartDate:=dSDate2     ;  dEndDate:=dEDate2
      ?? Transform(GetBal(DEBIT_BAL,"10-526"),SIGN_PIC),+"  "
      nOpExp2+=GetBal(DEBIT_BAL,"10-526")
      dStartDate:=dSDate3     ;  dEndDate:=dEDate3
      ?? Transform(GetBal(DEBIT_BAL,"10-526"),SIGN_PIC),+"  "
      nOpExp3+=GetBal(DEBIT_BAL,"10-526")
      dStartDate:=dSDate4     ;  dEndDate:=dEDate4
      ?? Transform(GetBal(DEBIT_BAL,"10-526"),SIGN_PIC)
      nOpExp4+=GetBal(DEBIT_BAL,"10-526")

      ? "   Gasoline & Oil             "
      dStartDate:=dSDate1     ;  dEndDate:=dEDate1
      ?? Transform(GetBal(DEBIT_BAL,"10-515"),SIGN_PIC),+"  "
      nOpExp+=GetBal(DEBIT_BAL,"10-515")
      dStartDate:=dSDate2     ;  dEndDate:=dEDate2
      ?? Transform(GetBal(DEBIT_BAL,"10-515"),SIGN_PIC),+"  "
      nOpExp2+=GetBal(DEBIT_BAL,"10-515")
      dStartDate:=dSDate3     ;  dEndDate:=dEDate3
      ?? Transform(GetBal(DEBIT_BAL,"10-515"),SIGN_PIC),+"  "
      nOpExp3+=GetBal(DEBIT_BAL,"10-515")
      dStartDate:=dSDate4     ;  dEndDate:=dEDate4
      ?? Transform(GetBal(DEBIT_BAL,"10-515"),SIGN_PIC)
      nOpExp4+=GetBal(DEBIT_BAL,"10-515")

      ? "   SSS Contribution           "
      dStartDate:=dSDate1     ;  dEndDate:=dEDate1
      ?? Transform(GetBal(DEBIT_BAL,"10-523"),SIGN_PIC),+"  "
      nOpExp+=GetBal(DEBIT_BAL,"10-523")
      dStartDate:=dSDate2     ;  dEndDate:=dEDate2
      ?? Transform(GetBal(DEBIT_BAL,"10-523"),SIGN_PIC),+"  "
      nOpExp2+=GetBal(DEBIT_BAL,"10-523")
      dStartDate:=dSDate3     ;  dEndDate:=dEDate3
      ?? Transform(GetBal(DEBIT_BAL,"10-523"),SIGN_PIC),+"  "
      nOpExp3+=GetBal(DEBIT_BAL,"10-523")
      dStartDate:=dSDate4     ;  dEndDate:=dEDate4
      ?? Transform(GetBal(DEBIT_BAL,"10-523"),SIGN_PIC)
      nOpExp4+=GetBal(DEBIT_BAL,"10-523")

      ? "   Membership & Subs. Fee     "
      dStartDate:=dSDate1     ;  dEndDate:=dEDate1
      ?? Transform(GetBal(DEBIT_BAL,"10-524"),SIGN_PIC),+"  "
      nOpExp+=GetBal(DEBIT_BAL,"10-524")
      dStartDate:=dSDate2     ;  dEndDate:=dEDate2
      ?? Transform(GetBal(DEBIT_BAL,"10-524"),SIGN_PIC),+"  "
      nOpExp2+=GetBal(DEBIT_BAL,"10-524")
      dStartDate:=dSDate3     ;  dEndDate:=dEDate3
      ?? Transform(GetBal(DEBIT_BAL,"10-524"),SIGN_PIC),+"  "
      nOpExp3+=GetBal(DEBIT_BAL,"10-524")
      dStartDate:=dSDate4     ;  dEndDate:=dEDate4
      ?? Transform(GetBal(DEBIT_BAL,"10-524"),SIGN_PIC)
      nOpExp4+=GetBal(DEBIT_BAL,"10-524")

      ? "   Notarial Fee               "
      dStartDate:=dSDate1     ;  dEndDate:=dEDate1
      ?? Transform(GetBal(DEBIT_BAL,"10-529"),SIGN_PIC),+"  "
      nOpExp+=GetBal(DEBIT_BAL,"10-529")
      dStartDate:=dSDate2     ;  dEndDate:=dEDate2
      ?? Transform(GetBal(DEBIT_BAL,"10-529"),SIGN_PIC),+"  "
      nOpExp2+=GetBal(DEBIT_BAL,"10-529")
      dStartDate:=dSDate3     ;  dEndDate:=dEDate3
      ?? Transform(GetBal(DEBIT_BAL,"10-529"),SIGN_PIC),+"  "
      nOpExp3+=GetBal(DEBIT_BAL,"10-529")
      dStartDate:=dSDate4     ;  dEndDate:=dEDate4
      ?? Transform(GetBal(DEBIT_BAL,"10-529"),SIGN_PIC)
      nOpExp4+=GetBal(DEBIT_BAL,"10-529")

      ? "   Repairs & Maintenance      "
      dStartDate:=dSDate1     ;  dEndDate:=dEDate1
      ?? Transform(GetBal(DEBIT_BAL,"10-527"),SIGN_PIC),+"  "
      nOpExp+=GetBal(DEBIT_BAL,"10-527")
      dStartDate:=dSDate2     ;  dEndDate:=dEDate2
      ?? Transform(GetBal(DEBIT_BAL,"10-527"),SIGN_PIC),+"  "
      nOpExp2+=GetBal(DEBIT_BAL,"10-527")
      dStartDate:=dSDate3     ;  dEndDate:=dEDate3
      ?? Transform(GetBal(DEBIT_BAL,"10-527"),SIGN_PIC),+"  "
      nOpExp3+=GetBal(DEBIT_BAL,"10-527")
      dStartDate:=dSDate4     ;  dEndDate:=dEDate4
      ?? Transform(GetBal(DEBIT_BAL,"10-527"),SIGN_PIC)
      nOpExp4+=GetBal(DEBIT_BAL,"10-527")

      ? "   Miscellaneous Expenses     "
      dStartDate:=dSDate1     ;  dEndDate:=dEDate1
      ?? Transform(GetBal(DEBIT_BAL,"10-532"),SIGN_PIC),+"  "
      nOpExp+=GetBal(DEBIT_BAL,"10-532")
      dStartDate:=dSDate2     ;  dEndDate:=dEDate2
      ?? Transform(GetBal(DEBIT_BAL,"10-532"),SIGN_PIC),+"  "
      nOpExp2+=GetBal(DEBIT_BAL,"10-532")
      dStartDate:=dSDate3     ;  dEndDate:=dEDate3
      ?? Transform(GetBal(DEBIT_BAL,"10-532"),SIGN_PIC),+"  "
      nOpExp3+=GetBal(DEBIT_BAL,"10-532")
      dStartDate:=dSDate4     ;  dEndDate:=dEDate4
      ?? Transform(GetBal(DEBIT_BAL,"10-532"),SIGN_PIC)
      nOpExp4+=GetBal(DEBIT_BAL,"10-532")

      dStartDate:=dSDate1     ;  dEndDate:=dEDate1
      nDepre:=GetBal(DEBIT_BAL,"10-518")+GetBal(DEBIT_BAL,"10-519")+ ;
         GetBal(DEBIT_BAL,"10-520")+GetBal(DEBIT_BAL,"10-521")
      dStartDate:=dSDate2     ;  dEndDate:=dEDate2
      nDepre2:=GetBal(DEBIT_BAL,"10-518")+GetBal(DEBIT_BAL,"10-519")+ ;
         GetBal(DEBIT_BAL,"10-520")+GetBal(DEBIT_BAL,"10-521")
      dStartDate:=dSDate3     ;  dEndDate:=dEDate3
      nDepre3:=GetBal(DEBIT_BAL,"10-518")+GetBal(DEBIT_BAL,"10-519")+ ;
         GetBal(DEBIT_BAL,"10-520")+GetBal(DEBIT_BAL,"10-521")
      dStartDate:=dSDate4     ;  dEndDate:=dEDate4
      nDepre4:=GetBal(DEBIT_BAL,"10-518")+GetBal(DEBIT_BAL,"10-519")+ ;
         GetBal(DEBIT_BAL,"10-520")+GetBal(DEBIT_BAL,"10-521")
      ? "   Depreciation Expense       "
      ?? Transform(nDepre,SIGN_PIC),+"  "
      ?? Transform(nDepre2,SIGN_PIC),+"  "
      ?? Transform(nDepre3,SIGN_PIC),+"  "
      ?? Transform(nDepre4,SIGN_PIC)

      nOpExp+=nDepre       ;      nOpExp2+=nDepre2
      nOpExp3+=nDepre3     ;      nOpExp4+=nDepre4
      ? "   Amortization Expenses      "
      dStartDate:=dSDate1     ;  dEndDate:=dEDate1
      ?? Transform(GetBal(DEBIT_BAL,"10-534"),SIGN_PIC),+"  "
      nOpExp+=GetBal(DEBIT_BAL,"10-534")
      dStartDate:=dSDate2     ;  dEndDate:=dEDate2
      ?? Transform(GetBal(DEBIT_BAL,"10-534"),SIGN_PIC),+"  "
      nOpExp2+=GetBal(DEBIT_BAL,"10-534")
      dStartDate:=dSDate3     ;  dEndDate:=dEDate3
      ?? Transform(GetBal(DEBIT_BAL,"10-534"),SIGN_PIC),+"  "
      nOpExp3+=GetBal(DEBIT_BAL,"10-534")
      dStartDate:=dSDate4     ;  dEndDate:=dEDate4
      ?? Transform(GetBal(DEBIT_BAL,"10-534"),SIGN_PIC)
      nOpExp4+=GetBal(DEBIT_BAL,"10-534")

      ? "   Insurance Premium          "
      dStartDate:=dSDate1     ;  dEndDate:=dEDate1
      ?? Transform(GetBal(DEBIT_BAL,"10-522"),SIGN_PIC),+"  "
      nOpExp+=GetBal(DEBIT_BAL,"10-522")
      dStartDate:=dSDate2     ;  dEndDate:=dEDate2
      ?? Transform(GetBal(DEBIT_BAL,"10-522"),SIGN_PIC),+"  "
      nOpExp2+=GetBal(DEBIT_BAL,"10-522")
      dStartDate:=dSDate3     ;  dEndDate:=dEDate3
      ?? Transform(GetBal(DEBIT_BAL,"10-522"),SIGN_PIC),+"  "
      nOpExp3+=GetBal(DEBIT_BAL,"10-522")
      dStartDate:=dSDate4     ;  dEndDate:=dEDate4
      ?? Transform(GetBal(DEBIT_BAL,"10-522"),SIGN_PIC)
      nOpExp4+=GetBal(DEBIT_BAL,"10-522")

      ? "   BSP Charges                "
      dStartDate:=dSDate1     ;  dEndDate:=dEDate1
      ?? Transform(GetBal(DEBIT_BAL,"10-506"),SIGN_PIC),+"  "
      nOpExp+=GetBal(DEBIT_BAL,"10-506")
      dStartDate:=dSDate2     ;  dEndDate:=dEDate2
      ?? Transform(GetBal(DEBIT_BAL,"10-506"),SIGN_PIC),+"  "
      nOpExp2+=GetBal(DEBIT_BAL,"10-506")
      dStartDate:=dSDate3     ;  dEndDate:=dEDate3
      ?? Transform(GetBal(DEBIT_BAL,"10-506"),SIGN_PIC),+"  "
      nOpExp3+=GetBal(DEBIT_BAL,"10-506")
      dStartDate:=dSDate4     ;  dEndDate:=dEDate4
      ?? Transform(GetBal(DEBIT_BAL,"10-506"),SIGN_PIC)
      nOpExp4+=GetBal(DEBIT_BAL,"10-506")

      ? "   Janitorial Services        "
      dStartDate:=dSDate1     ;  dEndDate:=dEDate1
      ?? Transform(GetBal(DEBIT_BAL,"10-530"),SIGN_PIC),+"  "
      nOpExp+=GetBal(DEBIT_BAL,"10-530")
      dStartDate:=dSDate2     ;  dEndDate:=dEDate2
      ?? Transform(GetBal(DEBIT_BAL,"10-530"),SIGN_PIC),+"  "
      nOpExp2+=GetBal(DEBIT_BAL,"10-530")
      dStartDate:=dSDate3     ;  dEndDate:=dEDate3
      ?? Transform(GetBal(DEBIT_BAL,"10-530"),SIGN_PIC),+"  "
      nOpExp3+=GetBal(DEBIT_BAL,"10-530")
      dStartDate:=dSDate4     ;  dEndDate:=dEDate4
      ?? Transform(GetBal(DEBIT_BAL,"10-530"),SIGN_PIC)
      nOpExp4+=GetBal(DEBIT_BAL,"10-530")

      ? "   Airline Charges            "
      dStartDate:=dSDate1     ;  dEndDate:=dEDate1
      ?? Transform(GetBal(DEBIT_BAL,"10-507"),SIGN_PIC),+"  "
      nOpExp+=GetBal(DEBIT_BAL,"10-507")
      dStartDate:=dSDate2     ;  dEndDate:=dEDate2
      ?? Transform(GetBal(DEBIT_BAL,"10-507"),SIGN_PIC),+"  "
      nOpExp2+=GetBal(DEBIT_BAL,"10-507")
      dStartDate:=dSDate3     ;  dEndDate:=dEDate3
      ?? Transform(GetBal(DEBIT_BAL,"10-507"),SIGN_PIC),+"  "
      nOpExp3+=GetBal(DEBIT_BAL,"10-507")
      dStartDate:=dSDate4     ;  dEndDate:=dEDate4
      ?? Transform(GetBal(DEBIT_BAL,"10-507"),SIGN_PIC)
      nOpExp4+=GetBal(DEBIT_BAL,"10-507")

      ? "   Value Added Tax (VAT)      "
      dStartDate:=dSDate1     ;  dEndDate:=dEDate1     
      ?? Transform(GetBal(DEBIT_BAL,"10-508"),SIGN_PIC),+"  "
      nOpExp+=GetBal(DEBIT_BAL,"10-508")
      dStartDate:=dSDate2     ;  dEndDate:=dEDate2
      ?? Transform(GetBal(DEBIT_BAL,"10-508"),SIGN_PIC),+"  "
      nOpExp2+=GetBal(DEBIT_BAL,"10-508")
      dStartDate:=dSDate3     ;  dEndDate:=dEDate3
      ?? Transform(GetBal(DEBIT_BAL,"10-508"),SIGN_PIC),+"  "
      nOpExp3+=GetBal(DEBIT_BAL,"10-508")
      dStartDate:=dSDate4     ;  dEndDate:=dEDate4
      ?? Transform(GetBal(DEBIT_BAL,"10-508"),SIGN_PIC)
      nOpExp4+=GetBal(DEBIT_BAL,"10-508")

      ? "   Commission Expense         "
      dStartDate:=dSDate1     ;  dEndDate:=dEDate1
      ?? Transform(GetBal(DEBIT_BAL,"10-533"),SIGN_PIC),+"  "
      nOpExp+=GetBal(DEBIT_BAL,"10-533")
      dStartDate:=dSDate2     ;  dEndDate:=dEDate2
      ?? Transform(GetBal(DEBIT_BAL,"10-533"),SIGN_PIC),+"  "
      nOpExp2+=GetBal(DEBIT_BAL,"10-533")
      dStartDate:=dSDate3     ;  dEndDate:=dEDate3
      ?? Transform(GetBal(DEBIT_BAL,"10-533"),SIGN_PIC),+"  "
      nOpExp3+=GetBal(DEBIT_BAL,"10-533")
      dStartDate:=dSDate4     ;  dEndDate:=dEDate4
      ?? Transform(GetBal(DEBIT_BAL,"10-533"),SIGN_PIC)
      nOpExp4+=GetBal(DEBIT_BAL,"10-533")

      ? "                              "
      ?? repl('-',14)+"  "+repl('-',14)+"  "+;
         repl('-',14)+"  "+repl('-',14)
      ? "                              "
      ? "Total Operating Expenses --> P"
      ?? Transform(nOpExp,SIGN_PIC),+" P"
      ?? Transform(nOpExp2,SIGN_PIC),+" P"
      ?? Transform(nOpExp3,SIGN_PIC),+" P"
      ?? Transform(nOpExp4,SIGN_PIC)

      nNetInc-=nOpExp      ;      nNetInc2-=nOpExp2
      nNetInc3-=nOpExp3    ;      nNetInc4-=nOpExp4
      ? "Net Operating Income (Loss)->P"
      ?? Transform(nNetInc,SIGN_PIC),+" P"
      ?? Transform(nNetInc2,SIGN_PIC),+" P"
      ?? Transform(nNetInc3,SIGN_PIC),+" P"
      ?? Transform(nNetInc4,SIGN_PIC)
      ?
      ?
      ?
      ?
      ?

      ? "Add: Other Income (Expenses)  "
      ? "   Other Income              P"
      dStartDate:=dSDate1     ;  dEndDate:=dEDate1
      ?? Transform(GetBal(CREDIT_BAL,"09-202"),SIGN_PIC),+" P"
      nOthInc+=GetBal(CREDIT_BAL,"09-202")
      dStartDate:=dSDate2     ;  dEndDate:=dEDate2
      ?? Transform(GetBal(CREDIT_BAL,"09-202"),SIGN_PIC),+" P"
      nOthInc2+=GetBal(CREDIT_BAL,"09-202")
      dStartDate:=dSDate3     ;  dEndDate:=dEDate3
      ?? Transform(GetBal(CREDIT_BAL,"09-202"),SIGN_PIC),+" P"
      nOthInc3+=GetBal(CREDIT_BAL,"09-202")
      dStartDate:=dSDate4     ;  dEndDate:=dEDate4
      ?? Transform(GetBal(CREDIT_BAL,"09-202"),SIGN_PIC)
      nOthInc4+=GetBal(CREDIT_BAL,"09-202")

      ? "   Interest Income            "
      dStartDate:=dSDate1     ;  dEndDate:=dEDate1
      ?? Transform(GetBal(CREDIT_BAL,"09-201"),SIGN_PIC),+"  "
      nOthInc+=GetBal(CREDIT_BAL,"09-201")
      dStartDate:=dSDate2     ;  dEndDate:=dEDate2
      ?? Transform(GetBal(CREDIT_BAL,"09-201"),SIGN_PIC),+"  "
      nOthInc2+=GetBal(CREDIT_BAL,"09-201")
      dStartDate:=dSDate3     ;  dEndDate:=dEDate3
      ?? Transform(GetBal(CREDIT_BAL,"09-201"),SIGN_PIC),+"  "
      nOthInc3+=GetBal(CREDIT_BAL,"09-201")
      dStartDate:=dSDate4     ;  dEndDate:=dEDate4
      ?? Transform(GetBal(CREDIT_BAL,"09-201"),SIGN_PIC)
      nOthInc4+=GetBal(CREDIT_BAL,"09-201")

      ? "   Dividend Income            "
      dStartDate:=dSDate1     ;  dEndDate:=dEDate1
      ?? Transform(GetBal(CREDIT_BAL,"09-113"),SIGN_PIC),+"  "
      nOthInc+=GetBal(CREDIT_BAL,"09-113")
      dStartDate:=dSDate2     ;  dEndDate:=dEDate2
      ?? Transform(GetBal(CREDIT_BAL,"09-113"),SIGN_PIC),+"  "
      nOthInc2+=GetBal(CREDIT_BAL,"09-113")
      dStartDate:=dSDate3     ;  dEndDate:=dEDate3
      ?? Transform(GetBal(CREDIT_BAL,"09-113"),SIGN_PIC),+"  "
      nOthInc3+=GetBal(CREDIT_BAL,"09-113")
      dStartDate:=dSDate4     ;  dEndDate:=dEDate4
      ?? Transform(GetBal(CREDIT_BAL,"09-113"),SIGN_PIC)
      nOthInc4+=GetBal(CREDIT_BAL,"09-113")

      ? "   Cancellation Charges       "
      dStartDate:=dSDate1     ;  dEndDate:=dEDate1
      ?? Transform(GetBal(CREDIT_BAL,"09-203"),SIGN_PIC),+"  "
      nOthInc+=GetBal(CREDIT_BAL,"09-203")
      dStartDate:=dSDate2     ;  dEndDate:=dEDate2
      ?? Transform(GetBal(CREDIT_BAL,"09-203"),SIGN_PIC),+"  "
      nOthInc2+=GetBal(CREDIT_BAL,"09-203")
      dStartDate:=dSDate3     ;  dEndDate:=dEDate3
      ?? Transform(GetBal(CREDIT_BAL,"09-203"),SIGN_PIC),+"  "
      nOthInc3+=GetBal(CREDIT_BAL,"09-203")
      dStartDate:=dSDate4     ;  dEndDate:=dEDate4
      ?? Transform(GetBal(CREDIT_BAL,"09-203"),SIGN_PIC)
      nOthInc4+=GetBal(CREDIT_BAL,"09-203")

      ? "                              "
      ?? repl('-',14)+"  "+repl('-',14)+"  "+;
         repl('-',14)+"  "+repl('-',14)
      ? "   Total ---->               P"
      ?? Transform(nOthInc,SIGN_PIC) ,+" P"
      ?? Transform(nOthInc2,SIGN_PIC),+" P"
      ?? Transform(nOthInc3,SIGN_PIC),+" P"
      ?? Transform(nOthInc4,SIGN_PIC)
      ?

      nNetInc+=nOthInc      ;      nNetInc2+=nOthInc2
      nNetInc3+=nOthInc3    ;      nNetInc4+=nOthInc4
      ? "Less: Other Income (Expenses) "
      ? "   Interest & Bank Charges   P"
      dStartDate:=dSDate1     ;  dEndDate:=dEDate1
      ?? Transform(GetBal(DEBIT_BAL,"10-531"),SIGN_PIC),+" P"
      nNetInc-=GetBal(DEBIT_BAL,"10-531")
      dStartDate:=dSDate2     ;  dEndDate:=dEDate2
      ?? Transform(GetBal(DEBIT_BAL,"10-531"),SIGN_PIC),+" P"
      nNetInc2-=GetBal(DEBIT_BAL,"10-531")
      dStartDate:=dSDate3     ;  dEndDate:=dEDate3
      ?? Transform(GetBal(DEBIT_BAL,"10-531"),SIGN_PIC),+" P"
      nNetInc3-=GetBal(DEBIT_BAL,"10-531")
      dStartDate:=dSDate4     ;  dEndDate:=dEDate4
      ?? Transform(GetBal(DEBIT_BAL,"10-531"),SIGN_PIC)
      nNetInc4-=GetBal(DEBIT_BAL,"10-531")

      ? "   Provision for Income Tax   "
      dStartDate:=dSDate1     ;  dEndDate:=dEDate1
      ?? Transform(GetBal(DEBIT_BAL,"04-191"),SIGN_PIC),+"  "
      nNetInc-=GetBal(DEBIT_BAL,"04-191")
      dStartDate:=dSDate2     ;  dEndDate:=dEDate2
      ?? Transform(GetBal(DEBIT_BAL,"04-191"),SIGN_PIC),+"  "
      nNetInc2-=GetBal(DEBIT_BAL,"04-191")
      dStartDate:=dSDate3     ;  dEndDate:=dEDate3
      ?? Transform(GetBal(DEBIT_BAL,"04-191"),SIGN_PIC),+"  "
      nNetInc3-=GetBal(DEBIT_BAL,"04-191")
      dStartDate:=dSDate4     ;  dEndDate:=dEDate4
      ?? Transform(GetBal(DEBIT_BAL,"04-191"),SIGN_PIC)
      nNetInc4-=GetBal(DEBIT_BAL,"04-191")

      ? "                              "
      ?? repl('-',14)+"  "+repl('-',14)+"  "+;
         repl('-',14)+"  "+repl('-',14)
      ? "NET INCOME (LOSS) ---->      P"
      ?? Transform(nNetInc,SIGN_PIC),+" P"
      ?? Transform(nNetInc2,SIGN_PIC),+" P"
      ?? Transform(nNetInc3,SIGN_PIC),+" P"
      ?? Transform(nNetInc4,SIGN_PIC)
      ? "                              "
      ?? repl('=',14)+"  "+repl('=',14)+"  "+;
         repl('=',14)+"  "+repl('=',14)
      Set(_SET_CONSOLE,.T.)
      Set(_SET_ALTFILE,"")
      Set(_SET_ALTERNATE,.F.)
      close alternate
      FSDEBIT->(DbCloseArea())
      FSCREDIT->(DbCloseArea())
      cReport:=MemoRead("IS.RPT")
      Message("Use cursor keys to navigate, press F10 to print, Esc to abort.")
      SetCursor(SC_NORMAL)
      wIS:=OpenWindow(3,1,21,77,"Comparative Income Statement")
      MemoEdit(cReport,4,2,20,76,.F.,"EditorFunc",105)
      CloseWindow(wIS)
      SetCursor(SC_NONE)
   endif
return nil

// end-of-file

