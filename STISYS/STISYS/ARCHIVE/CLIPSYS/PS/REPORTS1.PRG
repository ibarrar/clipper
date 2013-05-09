/*
   Procedure file: Reports1.PRG
           System: Payroll.Prg (Super Travel - Payroll System)
           Author: Rollie Castro Ibarra Junior
                   Copyright (c) 1992, Super Travel, Inc.
      Description: Payroll Reports / Printouts
    Last modified: 02/08/93     11:26a

    Functions                  Who
    -----------------------    ---
    PrintPayroll()             Rollie C. Ibarra Jr. (RCI)
    UnderOverRep()               - same -
    DoorCloseRep()               - same -
    GetDates()                   - same -

    Modifications:
    Date              Who      Remarks
    --------------    ---      -----------------------------------------
    Nov. 11, 1993     RCI      for semi or monthly deductions of loan
*/

#include "Setcurs.ch"
#include "Inkey.ch"
#include "Janus.Ch"
#include "Epson.Ch"

function PrintPayroll(cEmpCode,lDoor)
/*
   Purpose : Uses Daily computation based on Wage file this is necessary
             for  between cutoff appraisals ;
             Print payroll using dStartDate, dEndDate. cEmpcode holds
             "RD" for regular and daily paid, "P" for probationary and
             trinee, lDoor holds if door closed is to be computed.
*/
   if getdates(.t.)
      lCon := if(cOutput=="Y",.f.,.t.)
      if (isprinter() .and. !lCon) .or. lCon
         Message("Thinking...")
         if netuse("PAYMAST",DB_SHARED,NUM_SECONDS)
            set index to PAYMAST
         endif
         if netuse("WAGE",DB_SHARED,NUM_SECONDS)
            set index to WAGE
         endif
         if netuse("PAYTRANS",DB_SHARED,NUM_SECONDS)
            set index to PayTrans
         endif
         if netuse("HOLIDAY",DB_SHARED,NUM_SECONDS)
            set index to HOLIDAY
         endif
         if netuse("HISTORY",DB_SHARED,NUM_SECONDS)
            set index to HISTORY
         endif
         if netuse("LOAN",DB_SHARED,NUM_SECONDS)
            set index to LOAN
         endif
         if netuse("AccRcv",DB_SHARED,NUM_SECONDS)
            set index to AccRcv
         endif
         nDoorDed:=Comp_Door(lDoor)
         set console off
         set alternate to "Period.Sal"
         set alternate on
         ?? dtoc(dStartDate) + dtoc(dEndDate)
         ?
         set alternate off
         if lCon
         set alternate to "Pay.Rpt"
         set alternate on
         else
         set printer on
         Sti_Header(2)
         ?? _PRN_10CPI + _PRN_CONDOFF
         ?? _PRN_LQON + _PRN_ROMAN
         ?? _PRN_HDBLE
         ?
         ?
         endif
         ?  "þPayroll Report for "
         ?? if('R' $ cEmpCode,"Regular","Probationary/Trainee")
         ?
         ?
         ?  "Period :",dStartDate," to ",dEndDate
         if !lCon
         ?  _PRN_HNORM
         ?? _PRN_12CPI
         ?
         ?
         endif
         ?
         ?? space(if(lCon,31,41))
         ?? padc("Semi-Mo." ,9) + ' '
         ?? padc("UnderTime",9) + ' '
         ?? padc("Absences" ,9) + ' '
         ?? padc("Regular"  ,9) + ' '
         ?? padc("Holiday"  ,9) + ' '
         ?? padc("Gross"    ,10) + ' '
         if 'R' $ cEmpCode
            ?? padc("W/Hold'g" ,9) + ' '
            ?? padc("SSS"      ,9) + ' '
            ?? padc("Medicare" ,9) + ' '
         endif
         ?? padc("Accounts" ,9) + ' '

         ?  space(if(lCon,0,10))
         ?? padr("Employee Name",30) + ' '
         ?? padc("Basic Pay"    ,9) + ' '
         ?? padc("Deduct'n"     ,9) + ' '
         ?? padc("Deduct'n"     ,9) + ' '
         ?? padc("OverTime"     ,9) + ' '
         ?? padc("OverTime"     ,9) + ' '
         ?? padc("Pay"          ,10) + ' '
         if 'R' $ cEmpCode
            ?? padc("Tax"      ,9) + ' '
            ?? padc("Deduct'n" ,9) + ' '
            ?? padc("Deduct'n" ,9) + ' '
         endif
         ?? padc("Rec'ble"  ,9) + ' '
         ?? padc("Net Pay"  ,10) + ' '
         ?
         if !lCon ; ?; ?; endif

         PAYMAST->(DbGotop())
         store 0 to nEmpCount, nTotUT, nTotAbs
         store 0 to nTotOT, nTotHol, nTotGross, nTotWTax
         store 0 to nTotSSS, nTotMED, nTotRcv, nTotNet
         do while PAYMAST->(!eof())
            Message("Printing Rec#"+transform(PAYMAST->(RecNo()),"999"))
            if FindWage( PAYMAST->(Recno()), dEndDate ) .and.;
               empty(PAYMAST->Emp_Out) .and. (WAGE->Wg_Stat $ cEmpCode)
                store 0 to nDayCount, nLegal_Wrk, nSpcl_Wrk
                store 0 to nUnderTime, nOverTime, nAbsences
                PAYTRANS->(DbSeek( PAYMAST->(RecNo()) ))
                do while PAYTRANS->(!Eof()) .and. ;
                   (PAYTRANS->Rec_No == PAYMAST->(RecNo()) )
                   if (PAYTRANS->Tr_Date >= dStartDate) .and. ;
                      (PAYTRANS->Tr_Date <= dEndDate)
                      if !Check_HOLIDAY()
                         Regular_Day()
                      endif
                   endif
                   PAYTRANS->(DbSkip())
                enddo

                if (nUnderTime > 0) .and. (nOverTime > 0)
                   if nUnderTime >= nOverTime
                      nUndertime -= nOverTime
                      nOverTime := 0
                   elseif nUnderTime < nOverTime
                      nOverTime -= nUnderTime
                      nUnderTime := 0
                   endif
                endif

                nDayCount := if(WAGE->Wg_Stat == 'R',13,nDayCount)
                nDailyRate := WAGE->Wg_BPay / 26
                nUTded    := nUnderTime * (( nDailyRate/8) /60)
                nOTPay    := (nOverTime  * ((nDailyRate/8) /60)) * 1.25
                nAbsDed   := nAbsences  * nDailyRate
                nLegalPay := nLegal_Wrk * (( nDailyRate/8) /60) * 2
                nSpclPay  := nSpcl_Wrk  * (((nDailyRate/8) /60) * 1.30)
                nRegPay   := nDailyRate * nDayCount
                nGrossPay := (nRegPay + nLegalPay + nSpclPay + nOTpay) ;
                   - (nUTded + nAbsDed)
                if WAGE->Wg_Key .and. lDoor
                   nGrossPay -= nDoorDed
                endif
                ?? space(if(lCon,0,10))
                ?? padr(PAYMAST->Emp_Name,31)
                ?? transform(WAGE->Wg_BPay/2     ,"99,999.99") + ' '
                ?? transform(nUTded              ,"99,999.99") + ' '
                ?? transform(nAbsDed             ,"99,999.99") + ' '
                ?? transform(nOTpay              ,"99,999.99") + ' '
                ?? transform(nLegalPay + nSpclPay,"99,999.99") + ' '
                ?? transform(nGrossPay           ,"999,999.99") + ' '
                nRcv := ComputeRcv()
                nLoan := ComputeLOAN()
                /*-------------------------------------*/
                /* Compute other details for reg/daily */
                /*-------------------------------------*/
                nWTax := nSSSded := nMEDded := 0
                if WAGE->Wg_Stat $ "RD"
                   ComputeDeductions(WAGE->Wg_Taxc,nGrossPay,;
                             @nWTax,@nSSSded,@nMEDded)
                   ?? transform(nWTax      ,"99,999.99") + ' '
                   ?? transform(nSSSded    ,"99,999.99") + ' '
                   ?? transform(nMEDded    ,"99,999.99") + ' '
                   nTotWTax += nWTax
                   nTotSSS  += nSSSded + nLoan
                   nTotMED  += nMEDded
                   nNetPay  := nGrossPay - (nWTax + nSSSded + nMEDded + nRcv)
                else
                   nNetPay  := nGrossPay - nRcv
                endif
                if nLoan > 0
                   nNetPay -= nLoan
                endif
                ?? transform(nRcv   ,"99,999.99") + ' '
                ?? transform(nNetPay,"999,999.99")
                ?
                /* ----------------------- */
                /* Check for second line   */
                /* ----------------------- */
                if ((WAGE->Wg_Key) .and. lDoor .and. (nDoorDed>0)) ;
                   .or. (nLoan > 0)
                   ?? space(51)
                   if (WAGE->Wg_Key) .and. lDoor .and. (nDoorDed > 0)
                       ?? transform(nDoorDed,"99,999.99")
                       ?? " *Door Closed Deductions."
                   else
                       ?? space(34)
                   endif
                   if nLoan > 0
                       ?? space(28) + transform(nLoan,"9,999.99")
                       ?? " *SSS LOAN Deductions"
                   endif
                   ?
                endif

                nEmpCount ++
                nTotUT  += nUTded
                nTotAbs += nAbsDed
                nTotOT  += nOTPay
                nTotHol += nLegalPay + nSpclPay
                nTotGross += nGrossPay
                nTotRcv  += nRcv
                nTotNet += nNetPay
                /* -------------------------------------------- */
                /* Keep net amount in HISTORY for other puposes */
                /* -------------------------------------------- */
                if HISTORY->( FindDate( PAYMAST->(RecNo()), dEndDate ))
                   HISTORY->(RecLock(0))
                   replace HISTORY->Net with nNetPay
                   HISTORY->(DbUnlock())
                else
                   HISTORY->(AddRec(0))
                   replace HISTORY->Rec_No with PAYMAST->(Recno())
                   replace HISTORY->Date   with dEndDate
                   replace HISTORY->Gross  with nGrossPay
                   replace HISTORY->Net    with nNetPay
                   HISTORY->(DbUnlock())
                endif
                /* ------------------------------------------------ */
                /* Keep details in Salary file for Payslip printing */
                /* ------------------------------------------------ */
                if lCon
                set alternate to "Period.Sal" additive
                else
                set printer off
                set alternate on
                endif
                ?? PAYMAST->Emp_Name
                ?? transform( WAGE->Wg_Bpay/2,           "9999999.99")
                ?? transform( nOtPay+nSpclPay+nLegalPay, "9999999.99")
                ?? transform( nUtDed+nAbsDed,            "9999999.99")
                ?? transform( nSSSDed,                   "9999999.99")
                ?? transform( nMedDed,                   "9999999.99")
                ?? transform( nWTax,                     "9999999.99")
                ?? transform( nRcv+nLoan,                "9999999.99")
                ?? transform( nGrossPay,                 "9999999.99")
                ?? transform( nNetPay,                   "9999999.99")
                ?
                if lCon
                set alternate to "Pay.Rpt" additive
                else
                set alternate off
                set printer on
                endif
            endif
            PAYMAST->(DbSkip())
         enddo
         if lCon
         ? repl('=',if('R' $ cEmpCode,145,115))
         else
         ? repl('=',if('R' $ cEmpCode,155,125))
         endif
         ? space(if(lCon,0,10)) + padr("Totals : ",41)
         ?? transform(nTotUT    ,"99,999.99") + ' '
         ?? transform(nTotAbs   ,"99,999.99") + ' '
         ?? transform(nTotOT    ,"99,999.99") + ' '
         ?? transform(nTotHol   ,"99,999.99") + ' '
         ?? transform(nTotGross ,"999,999.99") + ' '
         if cEmpCode == "RD"
            ?? transform(nTotWTax,"99,999.99") + ' '
            ?? transform(nTotSSS ,"99,999.99") + ' '
            ?? transform(nTotMED ,"99,999.99") + ' '
         endif
         ?? transform(nTotRcv  ,"99,999.99") + ' '
         ?? transform(nTotNet  ,"999,999.99")
         ?
         if !lCon
         ? _PRN_CONDOFF
         endif
         ? "Note :"
         ?
         ? "      Total Net Pay (Voucher) for the Period  = "
         ?? transform(nTotNet,"99,999.99")
         if cEmpCode == "RD"
            ?
            ? "      Door Closed Deduction  = "
            ?? transform(nDoorDed,"999.99")
         endif
         if !lcon
         ? _PRN_FFEED
         endif
         ACCRCV->(DbCloseArea())
         LOAN->(DbCloseArea())
         HISTORY->(DbCloseArea())
         HOLIDAY->(DbCloseArea())
         PAYTRANS->(DbCloseArea())
         WAGE->(DbCloseArea())
         PAYMAST->(DbCloseArea())
         close alternate
         set printer off
         set console on
         Message("Press any key to print payslip, ESC to abort...")
         HeyThere()
         if inkey(0) # K_ESC
            PaySlip()
         endif
         OkDone()
         if lCon
         wPay:=OpenWindow(3,1,22,77,"Payroll Report")
         Message("Use Cursor to navigate")
         cPay:=MemoRead("Pay.Rpt")
         SetCursor(SC_NORMAL)
         MemoEdit(cPay,4,2,21,76,.f.,,156)
         CloseWindow(wPay)
         SetCursor(SC_NONE)
         endif
         Message("Printing Done...")
         inkey(1)
      else
         Message("Printer Not Ready...")
         Bummer()
         inkey(2)
      endif
    endif
    return nil

static function Comp_Door(lDoor)
/*
   Purpose : Compute door closed filed by employees to be deducted
              from keyholder
*/
local nDoorDed := 0
    if ldoor
       do while PAYMAST->(!eof())
       nDoor := 0
       if empty(PAYMAST->Emp_Out) .or. (PAYMAST->Emp_Out >= dStartDate)
          if FindWage( PAYMAST->(RecNo()),dEndDate )
             PAYTRANS->(dbseek( PAYMAST->(Recno()) ))
             do while PAYTRANS->(!Eof()) .and. ;
                (PAYTRANS->Rec_no == PAYMAST->(Recno()))
                if (PAYTRANS->Tr_Date >= dStartDate) .and. ;
                   (PAYTRANS->Tr_Date <= dEndDate) .and. ;
                   (PAYTRANS->Tr_AMinus == '1')
                   nDoor += MinDiff("08:30",PAYTRANS->Tr_AMin)
                endif
                PAYTRANS->(DbSkip())
             enddo
             nDoorDed += (((WAGE->Wg_BPay/26)/8)/60) * nDoor
          endif
       endif
       PAYMAST->(DbSkip())
       enddo
    endif
    return nDoorDed

function Check_HOLIDAY()
/*
   Purpose : Check if the day is HOLIDAY and compute necessary
             amount equiv. for hours worked.
*/
local lRet := .F., nMins := 0
    if HOLIDAY->(DbSeek(PAYTRANS->Tr_Date))
       nMins += MinDiff(PAYTRANS->Tr_AmIn,PAYTRANS->Tr_AmOut)
       nMins += MinDiff(PAYTRANS->Tr_PmIn,PAYTRANS->Tr_PmOut)
       if (HOLIDAY->Hd_Type == 'L')
          nLegal_Wrk += nMins
       else
          nSpcl_Wrk += nMins
       endif
       lRet := .T.
    endif
    return lRet

function Regular_Day()
/*
    Purpose : Compute the amount equiv. to the hours worked
*/
local nOT := nUT := 0
    if PAYTRANS->Tr_AMinus == '2'
       if PAYTRANS->Tr_AMin == "12:00"
          nAbsences += .5
       else
          nUT += MinDiff("08:30",PAYTRANS->Tr_AMin)
       endif
    endif
    nUT += if(PAYTRANS->Tr_AMoutus== '2',MinDiff(PAYTRANS->Tr_AMout,"12:00"),0)
    nUT += if(PAYTRANS->Tr_PMinus == '2',MinDiff("13:00",PAYTRANS->Tr_PMin),0)
    if PAYTRANS->Tr_PMoutus == '2'
       if PAYTRANS->Tr_PMout == "13:00"
          nAbsences += .5
       else
          nUT += MinDiff(PAYTRANS->Tr_PMout,"17:30")
       endif
    endif
    nOT += if(PAYTRANS->Tr_PMoutos == '1',MinDiff("17:30",PAYTRANS->Tr_PMout),0)
    nUnderTime += nUT
    nOverTime += nOT
    nDayCount ++
    return nil

function ComputeDeductions(cCateg,nGross,nWTax,nSSS,nMED)
/*
   Purpose : Compute taxes/deductions from the tables in Table.PRG
             and save it to HISTORY.DBF for future reference
*/
    if substr(dtoc(dEndDate),4,2) == '10'
       nWTax := SemiMonthlyWT(cCateg,nGross)
       nSSS  := GetSSS(nGross)
       nMed  := GetMED(nGross)
    else
       /*  Look for 1st payroll entries  */
       HISTORY->(DbSeek( PAYMAST->(RecNo()) ))
       do while HISTORY->(!Eof()) .and. (HISTORY->Rec_No == PAYMAST->(RecNo()))
          if HISTORY->Date == dStartDate-1
             exit
          endif
          HISTORY->(DbSkip())
       enddo
       /*  If found adjust WTax | SSS | Medicare deductions  */
       if HISTORY->Date == dStartDate-1  .and. ;
          HISTORY->Rec_No == PAYMAST->(RecNo())
          nWTax := MonthlyWT(cCateg,HISTORY->Gross+nGross)
          nWTax -= HISTORY->WTax
          nSSS  := GetSSS(HISTORY->Gross+nGross)
          nSSS  -= HISTORY->SSS
          nMed  := GetMED(HISTORY->Gross+nGross)
          nMed  -= HISTORY->MED
       else
          nWTax := SemiMonthlyWT(cCateg,nGross)
          nSSS  := GetSSS(nGross)
          nMed  := GetMED(nGross)
       endif
    endif
    HISTORY->( FindDate(PAYMAST->(RecNo()),dEndDate) )
    if HISTORY->Date != dEndDate
       HISTORY->(AddRec(0))
    endif
    HISTORY->(RecLock(0))
    HISTORY->Rec_No := PAYMAST->(RecNo())
    HISTORY->Date   := dEndDate
    HISTORY->WTax    := nWTax
    HISTORY->SSS    := nSSS
    HISTORY->MED    := nMED
    HISTORY->Gross  := nGross
    HISTORY->(DbUnlock())
    return nil

function ComputeRcv()
/*
   Purpose : Look for Accounts recivable of the employee
             being processed.
*/
local nRcv := 0
    ACCRCV->(DbSeek( PAYMAST->(RecNo()) ))
    do while ACCRCV->(!Eof()) .and. (ACCRCV->Rec_No == PAYMAST->(RecNo()))
       if ACCRCV->Ar_Date == dEndDate
          nRcv += Ar_Amount
       endif
       ACCRCV->(DbSkip())
    enddo
    return nRcv

function ComputeLoan()
/*
   Purpose : Look for SSS Loan/Grants to be deducted from the employee
             being processed.
*/
local nLoan := 0
   if (LOAN->(DbSeek(PAYMAST->(RecNo())))) .and. ((substr(dtoc(dEndDate),4,2) == "10") .or. (LOAN->SEM_MONTH))
       do while LOAN->(!Eof()) .and. (LOAN->Rec_No == PAYMAST->(RecNo()))
          if LOAN->Ln_Balance > 0
             if LOAN->SEM_MONTH
               nLoan += (LOAN->Ln_Amount / LOAN->Ln_Month)/2
             else
               nLoan += LOAN->Ln_Amount / LOAN->Ln_Month
             endif
             if LOAN->Ln_LastDed < dEndDate
                LOAN->(RecLock())
                LOAN->Ln_LastDed := dEndDate
                LOAN->Ln_Remit   := LOAN->Ln_Remit + nLoan
                LOAN->Ln_Balance := LOAN->Ln_Amount - LOAN->Ln_Remit
                LOAN->(DbUnlock())
             endif
          endif
          LOAN->(DbSkip())
       enddo
    endif
    return nLoan



function UnderOverRep(cEmpCode,lDoor)
/*
    Purpose : Prints Undertime and Overtime filed by employees
              for the payroll period.
*/
   if getdates(.t.)
      lCon := if(cOutput=="Y",.f.,.t.)
      if (isprinter() .and. !lCon) .or. lCon
         Message("Thinking...")
         if netuse("PAYMAST",DB_SHARED,NUM_SECONDS)
            set index to PAYMAST
         endif
         if netuse("WAGE",DB_SHARED,NUM_SECONDS)
            set index to WAGE
         endif
         if netuse("PAYTRANS",DB_SHARED,NUM_SECONDS)
            set index to PayTrans
         endif
         if netuse("Holiday",DB_SHARED,NUM_SECONDS)
            set index to HOLIDAY
         endif
         nDoorDed:=Comp_Door(lDoor)
         set console off
         if lCon
           set alternate to "Under.Rpt"
           set alternate on
         else
           set printer on
           Sti_Header(2)
           ?? _PRN_10CPI + _PRN_CONDOFF
           ?? _PRN_LQON + _PRN_ROMAN
           ?? _PRN_HDBLE
           ?
           ?
         endif
         ?  "þUnderTime & OverTime Report for "
         ?? if('R' $ cEmpCode,"Regular","Probationary/Trainee")
         ?
         ?
         ?  "Period :",dStartDate," to ",dEndDate
         if !lCon
           ?  _PRN_HNORM
           ?? _PRN_CONDON
           ?
           ?
         endif
         ?
         ?? space(29),"Basic Pay"
         ?? space(if(lCon,03,08)),"UnderTime"
         ?? space(if(lCon,01,06)),"UnderTime"
         ?? space(if(lCon,00,05)),"UnderTime"
         ?? space(if(lCon,09,19)),"No. of Days"
         ?? space(if(lCon,10,20)),"Regular OT"
         ?? space(if(lCon,00,04)),"Regular OT"
         ?? space(if(lCon,09,20)),"Holiday"
         ?
         ?? "Employee Name"
         ?? space(16),"Semi-Mon."
         ?? space(if(lCon,5,10)),"Rate"
         ?? space(if(lCon,3,08)),"Total Mins."
         ?? space(if(lCon,0,04)),"(Status)"
         ?? space(if(lCon,1,07)),"Amount"
         ?? space(if(lCon,3,08)),"Worked"
         ?? space(if(lCon,5,10)),"Amount"
         ?? space(if(lCon,1,06)),"Total Mins"
         ?? space(if(lCon,0,05)),"(Status)"
         ?? space(if(lCon,2,07)),"Amount"
         ?? space(if(lCon,0,05)),"(Total Hrs.)"
         ?? space(if(lCon,1,06)),"Amount"
         ?? space(if(lCon,3,08)),"Gross Pay"
         ?
         ?

         PAYMAST->(DbGotop())
         store 0 to nEmpCount, nTotUT, nTotAbs
         store 0 to nTotOT, nTotHol, nTotGross
         store 0 to nTotUTm, nTotAbsd, nTotOTm, nTotHolh
         do while PAYMAST->(!eof())
            Message("Printing Rec#"+transform(PAYMAST->(RecNo()),"999"))
            if FindWage( PAYMAST->(RecNo()), dEndDate ) .and.;
               (empty(PAYMAST->Emp_Out)) .and. (WAGE->Wg_Stat $ cEmpCode)
                store 0 to nDayCount, nLegal_Wrk, nSpcl_Wrk
                store 0 to nUnderTime, nOverTime, nAbsences
                PAYTRANS->(DbSeek( PAYMAST->(RecNo()) ))
                do while PAYTRANS->(!Eof()) .and. ;
                   (PAYTRANS->Rec_No == PAYMAST->(RecNo()) )
                   if (PAYTRANS->Tr_Date >= dStartDate) .and. ;
                      (PAYTRANS->Tr_Date <= dEndDate)
                      if !Check_HOLIDAY()
                         Regular_Day()
                      endif
                   endif
                   PAYTRANS->(DbSkip())
                enddo

                nUnderMins := nUnderTime
                nOverMins  := nOverTime
                if (nUnderTime > 0) .and. (nOverTime > 0)
                   if nUnderTime >= nOverTime
                      nUndertime -= nOverTime
                      nOverTime := 0
                   else
                      nOverTime -= nUnderTime
                      nUnderTime := 0
                   endif
                endif

                nDayCount := if(WAGE->Wg_Stat == 'R',13,nDayCount) - ;
                             nAbsences
                nDailyRate := WAGE->Wg_BPay / 26
                nUTded    := nUnderTime * (( nDailyRate/8) /60)
                nOTPay    := (nOverTime  * ((nDailyRate/8) /60)) * 1.25
                nLegalPay := nLegal_Wrk * (( nDailyRate/8) /60) * 2
                nSpclPay  := nSpcl_Wrk  * (((nDailyRate/8) /60) * 1.30)
                nRegPay   := nDailyRate * nDayCount
                nGrossPay := (nRegPay + nLegalPay + nSpclPay + nOTpay) ;
                   - (nUTded)
                if WAGE->Wg_Key .and. lDoor
                   nGrossPay -= nDoorDed
                endif
                ?? PAYMAST->Emp_Name,""
                ?? transform(WAGE->Wg_BPay/2       ,"9,999.99"),space(if(lCon,3,8))
                ?? transform(nDailyRate/8/60       ,"999.9999"),space(if(lCon,3,8))
                ?? transform(nUnderMins               ,"99999"),space(if(lCon,3,8))
                ?? transform(nUnderTime               ,"99999"),space(if(lCon,3,8))
                ?? transform(nUTded                ,"9,999.99"),space(if(lCon,3,8))
                ?? transform(nDayCount               ,"999.99"),space(if(lCon,3,8))
                ?? transform(nRegPay               ,"9,999.99"),space(if(lCon,3,8))
                ?? transform(nOverMins                ,"99999"),space(if(lCon,3,8))
                ?? transform(nOverTime                ,"99999"),space(if(lCon,3,8))
                ?? transform(nOTpay                ,"9,999.99"),space(if(lCon,3,8))
                ?? transform((nLegal_Wrk+nSpcl_Wrk)/60,"99.99"),space(if(lCon,3,8))
                ?? transform(nLegalPay + nSpclPay  ,"9,999.99"),space(if(lCon,3,8))
                ?? transform(nGrossPay            ,"99,999.99")
                ?
                nEmpCount ++
                nTotUTm += nUnderTime
                nTotUT  += nUTded
                nTotAbsd+= nAbsences
                nTotOTm += nOverTime
                nTotOT  += nOTPay
                nTotHolh+= (nLegal_Wrk+nSpcl_Wrk)/60
                nTotHol += nLegalPay + nSpclPay
                nTotGross += nGrossPay
            endif
            PAYMAST->(DbSkip())
         enddo
         ? repl('=',if(lCon,168,228))
         ? "Totals : ",transform(nEmpCount,"999"),space(if(lCon,50,65))
         ?? transform(nTotUTm   ,    "99999"),space(if(lCon,3,8))
         ?? transform(nTotUT    , "9,999.99"),space(if(lCon,3,8))
         ?? space(if(lCon,31,46))
         ?? transform(nTotOTm   ,    "99999"),space(if(lCon,3,8))
         ?? transform(nTotOT    , "9,999.99"),space(if(lCon,3,8))
         ?? transform(nTotHolh  ,    "99.99"),space(if(lCon,3,8))
         ?? transform(nTotHol   , "9,999.99"),space(if(lCon,3,8))
         ?? transform(nTotGross ,"99,999.99")
         if !lCon
           ? _PRN_FFEED
         endif
         HOLIDAY->(DbCloseArea())
         PAYTRANS->(DbCloseArea())
         WAGE->(DbCloseArea())
         PAYMAST->(DbCloseArea())
         OkDone()
         if lCon
           close alternate
           set console on
           wUnder:=OpenWindow(3,1,22,77,"Undertime/Overtime Report")
           Message("Use Cursor to navigate")
           cUnder:=MemoRead("Under.Rpt")
           SetCursor(SC_NORMAL)
           MemoEdit(cUnder,4,2,21,76,.f.,,170)
           CloseWindow(wUnder)
           SetCursor(SC_NONE)
           Message("Done...")
         else
           set printer off
           set console on
           Message("Printing Done...")
         endif
         inkey(1)
      else
         Message("Printer Not Ready...")
         Bummer()
         inkey(2)
      endif
    endif
    return nil



function DoorCloseRep()
/*
   Purpose : Prints Door closed report, filed by employees
             for the payroll period.
*/
local wUnder,cUnder
   if getdates()
      if isprinter()
         Message("Thinking...")
         if netuse("PAYMAST",DB_SHARED,NUM_SECONDS)
            set index to PAYMAST
         endif
         if netuse("WAGE",DB_SHARED,NUM_SECONDS)
            set index to WAGE
         endif
         if netuse("PAYTRANS",DB_SHARED,NUM_SECONDS)
            set index to PayTrans
         endif
         set console off
         set printer on
         Sti_Header(2)
         ?? _PRN_10CPI + _PRN_CONDOFF
         ?? _PRN_LQON + _PRN_ROMAN
         ?? _PRN_HDBLE
         ?
         ?
         ?  "þDoor Closed Report "
         ?
         ?
         ?  "Period :",dStartDate," to ",dEndDate
         ?  _PRN_HNORM
         ?
         ?
         ? space(15)
         ?? "Employee Name"
         ?? space(31),"Basic Pay"
         ?? space(10),"Mins. Closed"
         ?? space(9),"Rate per Min."
         ?? space(10),"Deduction"
         ?
         ?
         ?

         PAYMAST->(DbGotop())
         store 0 to nTotDoor, nTotAmount, nEmpCount
         aDatesApp := {}
         do while PAYMAST->(!eof())
            Message("Printing Rec#"+transform(PAYMAST->(RecNo()),"999"))
            if FindWage( PAYMAST->(RecNo()), dEndDate ) .and. ;
               empty(PAYMAST->Emp_Out)
                store 0 to nDoor, nAmount
                PAYTRANS->(DbSeek( PAYMAST->(RecNo()) ))
                do while PAYTRANS->(!Eof()) .and. ;
                  (PAYTRANS->Rec_no == PAYMAST->(Recno()))
                  if (PAYTRANS->Tr_Date >= dStartDate) .and. ;
                     (PAYTRANS->Tr_Date <= dEndDate) .and. ;
                     (PAYTRANS->Tr_AMinus == '1')
                     nDoor += MinDiff("08:30",PAYTRANS->Tr_AMin)
                     if aScan(aDatesApp,PAYTRANS->Tr_Date) == 0
                        aAdd(aDatesApp,PAYTRANS->Tr_Date)
                     endif
                  endif
                  PAYTRANS->(DbSkip())
                enddo
                if nDoor > 0
                   nAmount := (WAGE->Wg_Bpay/26/8/60) * nDoor
                   ?  space(15) + PAYMAST->Emp_Name,space(15)
                   ?? transform(WAGE->Wg_Bpay,"9,999.99")       ,space(15)
                   ?? transform(nDoor,"999")                    ,space(15)
                   ?? transform(WAGE->Wg_Bpay/26/8/60,"99.9999"),space(15)
                   ?? transform(nAmount,"999.99")
                   nTotDoor += nDoor
                   nTotAmount += nAmount
                   nEmpCount ++
                endif
            endif
            PAYMAST->(DbSkip())
         enddo
         ? repl('=',135)
         ? space(15) + "Totals : ",transform(nEmpCount,"999"),space(56)
         ?? transform(nTotDoor,     "999"),space(38)
         ?? transform(nTotAmount,"999.99")
         ?
         ? "Dates Applicable : "
         for x := 1 to len(aDatesApp)
             ?? dtoc(aDatesApp[x]) + if(x<len(aDatesApp),", ","")
         next
         ? _PRN_FFEED
         PAYTRANS->(DbCloseArea())
         WAGE->(DbCloseArea())
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

function FindDate( nRecno, dDate )
    DbSeek( nRecNo )
    do while !Eof() .and. Rec_No == nRecNo
       if Date == dDate  ;  exit  ;  endif
       DbSkip()
    enddo
    return Rec_No == nRecno .and. Date == dDate

function FindWage( nRecno, dDate )
local n, aWage := {}
    WAGE->(DbSeek( nRecno ))
    do while WAGE->(!Eof()) .and. WAGE->Rec_No==nRecno
       aAdd( aWage,{WAGE->(RecNo()),WAGE->Date} )
       WAGE->(DbSkip())
    enddo
    if len(aWage) > 0
       aSort(aWage,,,{|x,y| x[2] > y[2]})
       for n := 1 to len(aWage)
          if aWage[n][2] <= dDate
              WAGE->(DbGoto(aWage[n][1]))
              return .T.
          endif
       next
    endif
    return .F.

function GetDates(wCon)
/*
   Purpose : Accepts dates from the user, to cover the report(s)
             to be prepared.
*/
local wDate
   dStartDate:=dEndDate:=CToD("")
   cOutput:= "N"
   Message("Enter dates to cover report")
   wDate:=OpenWindow(09,15,if(!empty(wCon),14,13),64,"Date Information Box")
   @ 11,17 say " Enter starting date (MM/DD/YY format)" get dStartDate
   @ 12,17 say "         Ending date (MM/DD/YY format)" get dEndDate
   if !empty(wCon)
     @ 13,17 say "      Direct output to printer [Y/N] ?" get cOutPut pict "@Y"
   endif
   SetCursor(SC_NORMAL)
   HeyThere()
   read
   SetCursor(SC_NONE)
   CloseWindow(wDate)
return If(LastKey()==K_ESC,.F.,.T.)

/*
  Eof<Reports1.PRG>
*/


 l 7 ; ; Ï ¨l *?|Ê/ àÿ*AzY *B7 ;  * *C