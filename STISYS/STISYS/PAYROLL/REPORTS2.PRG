/*
   Procedure file: Reports2.PRG
           System: Payroll.Prg (Super Travel - Payroll System)
           Author: Ronan Japzon Paredes
                   Copyright (c) 1992, Super Travel, Inc.
      Description: Payroll Reports / Printouts - Part 2
    Last modified: 02/08/93     11:26a

    Functions                  Who
    -----------------------    ---
    Pay13mRep()                Ron Paredes
    Pay5DayRep()                - same -
    WTaxReport()                - same -

    Modifications:
    Date              Who      Remarks
    --------------    ---      -----------------------------------------

*/

#include "Epson.ch"
#include "Janus.Ch"
#include "SetCurs.Ch"
#include "Inkey.ch"

function Pay13Report()
/*
    Purpose : Prints 13th month compensation for the year
*/
local lSw := .T.
   if getdates()
      if isprinter()
         Message("Thinking...")
         cYear := substr(dtoc(dEndDate),7,2)
         netuse("SLIP",DB_SHARED,NUM_SECONDS)
         if netuse("PAYMAST",DB_SHARED,NUM_SECONDS)
            set index to PAYMAST
         endif
         if netuse("WAGE",DB_SHARED,NUM_SECONDS)
            set index to WAGE
         endif
         if netuse("HISTORY",DB_SHARED,NUM_SECONDS)
            set index to HISTORY
         endif
         set console off
         set alternate to "13month.Sal"
         set alternate on
         ?? dtoc(dStartDate) + dtoc(dEndDate)
         ?
         set alternate off
         set printer on
         Sti_Header(2)
         ?? _PRN_10CPI + _PRN_CONDOFF
         ?? _PRN_LQON + _PRN_ROMAN
         ?? _PRN_HDBLE
         ?
         ?
         ?  "þ13th Month Salary Report"
         ?
         ?
         ?  "For the Year : 19" +cYear
         ?  _PRN_HNORM
         ?? _PRN_CONDON
         ?
         ? space(10)
         ?? "Employee Name                 ",space(1)
         ?? "  January ",space(1)   ; ?? " February ",space(1)
         ?? "   March  ",space(1)   ; ?? "   April  ",space(1)
         ?? "   May    ",space(1)   ; ?? "   June   ",space(1)
         ?? "   July   ",space(1)   ; ?? "  August  ",space(1)
         ?? " September",space(1)   ; ?? "  October ",space(1)
         ?? " November ",space(1)   ; ?? " December ",space(1)
         ?? "13 Mon.Pay",space(1)   ; ?? "W/Holding" ,space(1)
         ?? "  Net Pay "
         ?
         store 0 to nTot13pay, nTotWTax, nTotNet
         aTMonthGross := aFill(array(12),0)
         PAYMAST->(DbGotop())
         do while PAYMAST->(!eof())
            Message("Printing Rec#"+transform(PAYMAST->(RecNo()),"999"))
            if ((empty(PAYMAST->Emp_Out) .and. (lSw==.T.)) .or. ;
                (!empty(PAYMAST->Emp_Out) .and. (lSw==.F.)) )
                store 0 to n13pay, nWtax, nNet
                aMonthGross := aFill(array(12),0)
                HISTORY->(DbSeek( PAYMAST->(RecNo()) ))
                do while HISTORY->(!Eof()) .and. ;
                         HISTORY->Rec_No==PAYMAST->(RecNo())
                    if substr(dtoc(HISTORY->Date),7,2) == cYear .and. ;
                       HISTORY->Date <= dEndDate
                       nMonth := val(substr(dtoc(HISTORY->Date),1,2))
                       aMonthGross[nMonth] += HISTORY->Net
                    endif
                    HISTORY->(DbSkip())
                enddo
                if FindWage(PAYMAST->(RecNo()),dEndDate)
                   aEval(aMonthGross, { |x| n13pay += x})
                   n13pay /= 11.5
                   nWTax := MonthlyWT(WAGE->Wg_Taxc,n13pay)
                   nNet := n13pay - nWTax
                   ? space(10)
                   ?? PAYMAST->Emp_Name
                   for x:=1 to 12
                      ?? ' ',transform(aMonthGross[x],"999,999.99")
                      aTMonthGross[x] += aMonthGross[x]
                   next
                   ?? ' ',transform(n13pay,"999,999.99")
                   ?? ' ',transform(nWTax,"99,999.99")
                   ?? ' ',transform(nNet,"999,999.99")
                   nTot13pay += n13pay
                   nTotWtax  += nWTax
                   nTotNet   += nNet
                   if !HISTORY->( FindDate(PAYMAST->(RecNo()), ;
                             ctod("12-31-"+cYear) ))
                       HISTORY->(AddRec(0))
                   endif
                   HISTORY->(RecLock(0))
                   replace HISTORY->WTax  with nWTax
                   replace HISTORY->Gross with n13pay
                   replace HISTORY->Net   with nNEt
                   HISTORY->(DbUnlock(0))
                   /* ------------------------------------------------ */
                   /* Keep details in Salary File for Payslip printing */
                   /* ------------------------------------------------ */
                   set printer off
                   set alternate on
                   ?? PAYMAST->Emp_Name
                   ?? transform(WAGE->Wg_BPay /2, "9999999.99")
                   ?? transform(n13pay,           "9999999.99")
                   ?? transform(nWTax,            "9999999.99")
                   ?? transform(nNet,             "9999999.99")
                   ?
                   set alternate off
                   set printer on
                endif
            endif
            PAYMAST->(DbSkip())
         enddo
         ? repl('=',223)
         ? "    Totals :",space(27)
         for x:=1 to 12
             ?? space(1),transform(aTMonthGross[x],"999,999.99")
         next
         ?? space(1),transform(nTot13pay,"999,999.99")
         ?? space(1),transform(nTotWTax,"99,999.99")
         ?? space(1),transform(nTotNet,"999,999.99")
         ? _PRN_CONDOFF
         ? "Note :"
         ?
         ? "       Total 13th Month Salary for the year = "
         ?? transform(nTotNet,"99,999.99")
         ? _PRN_FFEED
         WAGE->(DbCloseArea())
         HISTORY->(DbCloseArea())
         PAYMAST->(DbCloseArea())
         set printer off
         set console on
         close alternate
         Message("Press any key to print payslip, ESC to abort...")
         HeyThere()
         if inkey(0) # K_ESC
            PaySlip2()
         endif
         Message("Printing Done...")
         OkDone()
         inkey(2)
      else
         Message("Printer Not Ready...")
         Bummer()
         inkey(2)
      endif
    endif
    return nil



function Pay5DayReport()
/*
    Purpose : Prints 5 day compensation for the year
*/
   if getdates()
      if isprinter()
         Message("Thinking...")
         if netuse("PAYMAST",DB_SHARED,NUM_SECONDS)
            set index to PAYMAST
         endif
         if netuse("WAGE",DB_SHARED,NUM_SECONDS)
            set index to WAGE
         endif
         set console off
         set alternate to "5DayInc.Sal"
         set alternate on
         ?? dtoc(dStartDate) + dtoc(dEndDate)
         ?
         set alternate off
         set printer on
         Sti_Header(2)
         ?? _PRN_10CPI + _PRN_CONDOFF
         ?? _PRN_LQON + _PRN_ROMAN
         ?? _PRN_HDBLE
         ?
         ?
         ?  "þ5-Day Incentive Report"
         ?
         ?
         ?  "For the Year : 19" +substr(dtoc(dEndDate),7,2)
         ?  _PRN_HNORM
         ?
         ?
         ?? space(24),"Employee Name"
         ?? space(17),"Date Employed"
         ?? space(5), "Basic Pay"
         ?? space(5), "Incentive Pay"
         ?
         store 0 to nTotIncentive
         PAYMAST->(DbGotop())
         do while PAYMAST->(!eof())
            Message("Printing Rec#"+transform(PAYMAST->(RecNo()),"999"))
            if FindWage(PAYMAST->(RecNo()),dEndDate)
               if empty(PAYMAST->Emp_Out) .and. (WAGE->Wg_Stat $ "RD")
                  ?
                  ?? space(24),PAYMAST->Emp_Name
                  ?? space(2),PAYMAST->Emp_In
                  ?? space(8),transform(WAGE->Wg_BPay,"99,999.99")
                  ?? space(8),transform((WAGE->Wg_BPay/26)*5,"99,999.99")
                  nTotIncentive += (WAGE->Wg_BPay/26)*5
                  /* ----------------------------------------- */
                  /* Keep details in SLIP for Payslip printing */
                  /* ----------------------------------------- */
                  set printer off
                  set alternate on
                  ?? PAYMAST->Emp_Name
                  ?? transform(WAGE->Wg_BPay/2     ,"9999999.99")
                  ?? transform(WAGE->Wg_BPay/26    ,"9999999.99")
                  ?? transform((WAGE->Wg_BPay/26)*5,"9999999.99")
                  ?
                  set alternate off
                  set printer on
               endif
            endif
            PAYMAST->(DbSkip())
         enddo
         ? space(7),repl('=',103)
         ? space(10),"Totals :"
         ?? space(73),transform(nTotIncentive,"99,999.99")
         ?
         ? "Note :"
         ?
         ? "       Total Five Day Incentive for the year = "
         ?? transform(nTotIncentive,"99,999.99")
         ? _PRN_FFEED
         WAGE->(DbCloseArea())
         PAYMAST->(DbCloseArea())
         SLIP->(DbCloseArea())
         set printer off
         set console on
         close alternate
         Message("Press any key to print payslip, ESC to abort...")
         HeyThere()
         if inkey(0) # K_ESC
            PaySlip3()
         endif
         Message("Printing Done...")
         OkDone()
         inkey(2)
      else
         Message("Printer Not Ready...")
         Bummer()
         inkey(2)
      endif
    endif
    return nil

function WtaxReport()
/*
    Purpose : Prints WithHolding Tax Report for the Year
*/
local lSw := .T.
   if getdates()
      if isprinter()
         Message("Thinking...")
         cYear := substr(dtoc(dEndDate),7,2)
         if netuse("PAYMAST",DB_SHARED,NUM_SECONDS)
            set index to PAYMAST
         endif
         if netuse("WAGE",DB_SHARED,NUM_SECONDS)
            set index to WAGE
         endif
         if netuse("HISTORY",DB_SHARED,NUM_SECONDS)
            set index to HISTORY
         endif
         set console off
*         set printer to "Temp.TXT"
         set printer on
         Sti_Header(2)
         ?? _PRN_10CPI + _PRN_CONDOFF
         ?? _PRN_LQON + _PRN_ROMAN
         ?? _PRN_HDBLE
         ?
         ?
         ?  "þWithHolding Tax Report"
         ?
         ?
         ?  "For the Year : 19" +cYear
         ?  _PRN_HNORM
         ?
         ?
         ?? _PRN_CONDON
         ? space(10)
         ?? "Employee Name                 ",space(1)
         ?? "  January ",space(1)   ; ?? " February ",space(1)
         ?? "   March  ",space(1)   ; ?? "   April  ",space(1)
         ?? "   May    ",space(1)   ; ?? "   June   ",space(1)
         ?? "   July   ",space(1)   ; ?? "  August  ",space(1)
         ?? " September",space(1)   ; ?? "  October ",space(1)
         ?? " November ",space(1)   ; ?? " December ",space(1)
         ?? "13 Mo. Wtx",space(1)   ; ?? "  Totals" ,space(1)
         ?
         store 0 to nTotWTax
         aTMonthWTax := aFill(array(13),0)
         PAYMAST->(DbGotop())
         do while PAYMAST->(!eof())
            Message("Printing Rec#"+transform(PAYMAST->(RecNo()),"999"))
            if ((empty(PAYMAST->Emp_Out) .and. (lSw==.T.)) .or. ;
                (!empty(PAYMAST->Emp_Out) .and. (lSw==.F.)) )
                store 0 to nWtax
                aMonthWTax := aFill(array(13),0)
                HISTORY->(DbSeek( PAYMAST->(RecNo()) ))
                do while HISTORY->(!Eof()) .and. ;
                         HISTORY->Rec_No==PAYMAST->(RecNo())
                    if substr(dtoc(HISTORY->Date),7,2) == cYear .and. ;
                       HISTORY->Date <= dEndDate
                       if substr(dtoc(HISTORY->Date),1,5) # "12-31"
                          nMonth := val(substr(dtoc(HISTORY->Date),1,2))
                          aMonthWTax[nMonth] += HISTORY->WTax
                       else
                          aMonthWTax[13] += HISTORY->WTax
                       endif
                    endif
                    HISTORY->(DbSkip())
                enddo
                ? space(10)
                ?? PAYMAST->Emp_Name
                for x:=1 to 13
                   ?? ' ',transform(aMonthWTax[x],"999,999.99")
                   aTMonthWTax[x] += aMonthWTax[x]
                   nWTax += aMonthWTax[x]
                next
                ?? ' ',transform(nWTax,"999,999.99")
                nTotWtax  += nWTax
            endif
            PAYMAST->(DbSkip())
         enddo
         ? repl('=',223)
         ? "    Totals :",space(27)
         for x:=1 to 13
             ?? space(1),transform(aTMonthWTax[x],"999,999.99")
         next
         ?? space(1),transform(nTotWTax,"99,999.99")
         ? _PRN_CONDOFF
         ? "Note :"
         ?
         ? "       Total WithHolding Tax for the year = "
         ?? transform(nTotWTax,"99,999.99")
         ? _PRN_FFEED
         WAGE->(DbCloseArea())
         HISTORY->(DbCloseArea())
         PAYMAST->(DbCloseArea())
*         set printer to
         set printer off
         set console on
         Message("Printing Done...")
         OkDone()
         inkey(2)
      else
         Message("Printer Not Ready...")
         Bummer()
         inkey(2)
      endif
    endif
    return nil



/*
  Eof<Reports2.PRG>
*/


