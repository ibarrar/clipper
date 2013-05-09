
#include "Setcurs.ch"
#include "Inkey.ch"
#include "Janus.Ch"
#include "Epson.Ch"

function TwicePayroll(cEmpCode,lDoor)
local cPay,wPay
private dStart1,dStart2,dEnd1,dEnd2
/*
   Purpose : Uses Daily computation based on Wage file this is necessary
             for  between cutoff appraisals ;
             Print payroll using dStartDate, dEndDate. cEmpcode holds
             "RD" for regular and daily paid, "P" for probationary and
             trinee, lDoor holds if door closed is to be computed.
*/
   if getdates2()
      lCon := if(cOutput == "Y",.f.,.t.)
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
 ***********************************************************************
         nDoorDed:=TwiceDoor(lDoor)
         set console off
         set alternate to "Period.Sal"
         set alternate on
         ?? dtoc(dStartDate) + dtoc(dEndDate)
         ?
         set alternate off
         if !lCon
         set printer on
         Sti_Header(2)
         ?? _PRN_10CPI + _PRN_CONDOFF
         ?? _PRN_LQON + _PRN_ROMAN
         ?? _PRN_HDBLE
         ?
         ?
         else
         set alternate to "Pay.rpt"
         set alternate on
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
         ?
         ?
         PAYMAST->(DbGotop())
         store 0 to nEmpCount, nTotUT, nTotAbs
         store 0 to nTotOT, nTotHol, nTotGross, nTotWTax
         store 0 to nTotSSS, nTotMED, nTotRcv, nTotNet
         store 0 to nTotUTm, nTotAbsd, nTotOTm, nTotHolh
         do while PAYMAST->(!eof())
            Message("Printing Rec#"+transform(PAYMAST->(RecNo()),"999"))
            if FindWage(PAYMAST->(RecNo()), dEnd1) .and. ;
               (empty(PAYMAST->Emp_Out)) .and. (WAGE->Wg_Stat $ cEmpCode)
                store 0 to nDayCount, nLegal_Wrk, nSpcl_Wrk
                store 0 to nUnderTime, nOverTime, nAbsences
                store 0 to nDayTot, nUnderMins, nOverMins, nBasic
                store 0 to nUnderTot, nOverTot
   **********************************************************************

                PAYTRANS->(DbSeek( PAYMAST->(RecNo()) ))
                do while PAYTRANS->(!Eof()) .and. ;
                   (PAYTRANS->Rec_No == PAYMAST->(RecNo()) )
                   if (PAYTRANS->Tr_Date >= dStart1) .and. ;
                      (PAYTRANS->Tr_Date <= dEnd1)
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
                   else
                      nOverTime -= nUnderTime
                      nUnderTime := 0
                   endif
                endif
                nDayCount := if(WAGE->Wg_Stat == 'R',GetDays(dStart1,dEnd1),;
                             nDayCount)
                FindWage(PAYMAST->(Recno()), dEnd1)
                nDayTot   := nDayCount
                nUnderTot := nUnderTime
                nOverTot  := nOverTime
                nDailyRate:= WAGE->Wg_BPay / 26
                nBasic    := nDailyRate * GetDays(dStart1,dEnd1)
                nAbsDed   := nAbsences * nDailyRate
                nUTded    := nUnderTime * (( nDailyRate/8) /60)
                nOTPay    := (nOverTime * ((nDailyRate/8) /60)) * 1.25
                nLegalPay := nLegal_Wrk * (( nDailyRate/8) /60) * 2
                nSpclPay  := nSpcl_Wrk  * (((nDailyRate/8) /60) * 1.30)
                nRegPay   := nDailyRate * nDayCount

                store 0 to nDayCount, nLegal_Wrk, nSpcl_Wrk
                store 0 to nUnderTime, nOverTime, nAbsences

                PAYTRANS->(DbSeek( PAYMAST->(RecNo()) ))
                do while PAYTRANS->(!Eof()) .and. ;
                   (PAYTRANS->Rec_No == PAYMAST->(RecNo()) )
                   if (PAYTRANS->Tr_Date >= dStart2) .and. ;
                      (PAYTRANS->Tr_Date <= dEnd2)
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
                   else
                      nOverTime -= nUnderTime
                      nUnderTime := 0
                   endif
                endif

                nDayCount := if(WAGE->Wg_Stat == 'R',GetDays(dStart2,dEnd2),;
                             nDayCount)

                nDayTot   += nDayCount
                nUnderTot += nUnderTime
                nOverTot  += nOverTime

                FindWage(PAYMAST->(Recno()), dEnd2)
                nDailyRate:= WAGE->Wg_BPay / 26
                nAbsDed   += nAbsences * nDailyRate
                nBasic    += nDailyRate * GetDays(dStart2,dEnd2)
                nUTded    += nUnderTime * (( nDailyRate/8) /60)
                nOTPay    += (nOverTime  * ((nDailyRate/8) /60)) * 1.25

                if (nUnderTot > 0) .and. (nOverTot > 0)
                   if nUnderTot >= nOverTot
                      nUnderTot -= nOverTot
                      nOverTot := 0
                   else
                      nOverTot -= nUnderTot
                      nUnderTot := 0
                   endif
                endif

                if (nUTded > 0) .and. (nOTPay > 0)
                   if nUTded >= nOTPay
                      nUTded -= nOTPay
                      nOTPay := 0
                   else
                      nOTPay -= nUTded
                      nUTded := 0
                   endif
                endif

                nLegalPay += nLegal_Wrk * (( nDailyRate/8) /60) * 2
                nSpclPay  += nSpcl_Wrk  * (((nDailyRate/8) /60) * 1.30)
                nRegPay   += nDailyRate * nDayCount

                nGrossPay := (nRegPay + nLegalPay + nSpclPay + nOTpay) ;
                   - (nUTded + nAbsDed)

                if WAGE->Wg_Key .and. lDoor
                   nGrossPay -= nDoorDed
                endif

                ?? space(if(lCon,0,10))
                ?? padr(PAYMAST->Emp_Name,31)
                ?? transform(nBasic              ,"99,999.99") + ' '
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
                if !lCon
                set printer off
                else
                set alternate to "Period.Sal" additive
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
                if !lCon
                set alternate off
                set printer on
                else
                set alternate to "Pay.Rpt"  additive
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
         if !lCon
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
         else
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


function GetDates2()
/*
   Purpose : Accepts dates from the user, to cover the report(s)
             to be prepared.
*/
local wDate
   dStart1:=dEnd1:=dStart2:=dEnd2:=CToD("")
   cOutput:="N"
   Message("Enter dates to cover report")
   wDate:=OpenWindow(09,15,16,64,"Date Information Box")
   @ 11,17 say " Enter starting date (MM/DD/YY format)" get dStart1
   @ 12,17 say "         Ending date (MM/DD/YY format)" get dEnd1
   @ 13,17 say " Enter starting date (MM/DD/YY format)" get dStart2
   @ 14,17 say "         Ending date (MM/DD/YY format)" get dEnd2
   @ 15,17 say "       Direct output to printer [Y/N]?" get cOutput pict "@Y"
   SetCursor(SC_NORMAL)
   HeyThere()
   read
   SetCursor(SC_NONE)
   dStartDate:=dStart1
   dEndDate:=dEnd2
   CloseWindow(wDate)
return If(LastKey()==K_ESC,.F.,.T.)



function TwiceUndOvr(cEmpCode,lDoor)
/*
    Purpose : Prints Undertime and Overtime filed by employees
              for the payroll period.
*/
local cUnder,wUnder
private dStart1,dStart2,dEnd1,dEnd2
   if getdates2()
      lCon := if(cOutPut=="Y",.f.,.t.)
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
         nDoorDed:=TwiceDoor(lDoor)
         set console off
         if !lCon
         set printer on
         Sti_Header(2)
         ?? _PRN_10CPI + _PRN_CONDOFF
         ?? _PRN_LQON + _PRN_ROMAN
         ?? _PRN_HDBLE
         ?
         ?
         else
         set alternate to "Under.Rpt"
         set alternate on
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
            if FindWage(PAYMAST->(RecNo()), dEnd1) .and. ;
               (empty(PAYMAST->Emp_Out)) .and. (WAGE->Wg_Stat $ cEmpCode)
                store 0 to nDayCount, nLegal_Wrk, nSpcl_Wrk
                store 0 to nUnderTime, nOverTime, nAbsences
                store 0 to nDayTot, nUnderMins, nOverMins, nBasic
                store 0 to nUnderTot, nOverTot
*********************************************************************

                PAYTRANS->(DbSeek( PAYMAST->(RecNo()) ))
                do while PAYTRANS->(!Eof()) .and. ;
                   (PAYTRANS->Rec_No == PAYMAST->(RecNo()) )
                   if (PAYTRANS->Tr_Date >= dStart1) .and. ;
                      (PAYTRANS->Tr_Date <= dEnd1)
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
                nDayCount := if(WAGE->Wg_Stat == 'R',GetDays(dStart1,dEnd1),;
                             nDayCount) - nAbsences
                FindWage(PAYMAST->(Recno()), dEnd1)
                nDailyRate:= WAGE->Wg_BPay / 26
                nBasic    := nDailyRate * GetDays(dStart1,dEnd1)
                nDayTot   := nDayCount
                nUnderTot := nUnderTime
                nOverTot  := nOverTime
                nUTded    := nUnderTime * (( nDailyRate/8) /60)
                nOTPay    := (nOverTime * ((nDailyRate/8) /60)) * 1.25
                nLegalPay := nLegal_Wrk * (( nDailyRate/8) /60) * 2
                nSpclPay  := nSpcl_Wrk  * (((nDailyRate/8) /60) * 1.30)
                nRegPay   := nDailyRate * nDayCount

                store 0 to nDayCount, nLegal_Wrk, nSpcl_Wrk
                store 0 to nUnderTime, nOverTime, nAbsences

                PAYTRANS->(DbSeek( PAYMAST->(RecNo()) ))
                do while PAYTRANS->(!Eof()) .and. ;
                   (PAYTRANS->Rec_No == PAYMAST->(RecNo()) )
                   if (PAYTRANS->Tr_Date >= dStart2) .and. ;
                      (PAYTRANS->Tr_Date <= dEnd2)
                      if !Check_HOLIDAY()
                         Regular_Day()
                      endif
                   endif
                   PAYTRANS->(DbSkip())
                enddo

                nUnderMins += nUnderTime
                nOverMins  += nOverTime

                if (nUnderTime > 0) .and. (nOverTime > 0)
                   if nUnderTime >= nOverTime
                      nUndertime -= nOverTime
                      nOverTime := 0
                   else
                      nOverTime -= nUnderTime
                      nUnderTime := 0
                   endif
                endif


                nDayCount := if(WAGE->Wg_Stat == 'R',GetDays(dStart2,dEnd2),;
                             nDayCount) - nAbsences
                nDayTot   += nDayCount


                FindWage(PAYMAST->(Recno()), dEnd2)

                nDailyRate:= WAGE->Wg_BPay / 26
                nBasic    += (nDailyRate) * GetDays(dStart2,dEnd2)

                nUTded += nUnderTime * (( nDailyRate/8) /60)

                nOTPay += (nOverTime  * ((nDailyRate/8) /60)) * 1.25

                nUnderTot  += nUnderTime
                nOverTot   += nOverTime

                if (nUnderTot > 0) .and. (nOverTot > 0)
                   if nUnderTot >= nOverTot
                      nUnderTot -= nOverTot
                      nOverTot := 0
                   else
                      nOverTot -= nUnderTot
                      nUnderTot := 0
                   endif
                endif

                if (nUTded > 0) .and. (nOTPay > 0)
                   if nUTded >= nOTPay
                      nUTded -= nOTPay
                      nOTPay := 0
                   else
                      nOTPay -= nUTded
                      nUTded := 0
                   endif
                endif


                nLegalPay += nLegal_Wrk * (( nDailyRate/8) /60) * 2
                nSpclPay  += nSpcl_Wrk  * (((nDailyRate/8) /60) * 1.30)
                nRegPay   += nDailyRate * nDayCount

                nGrossPay := (nRegPay + nLegalPay + nSpclPay + nOTpay) ;
                   - (nUTded)

                if WAGE->Wg_Key .and. lDoor
                   nGrossPay -= nDoorDed
                endif
                ?? PAYMAST->Emp_Name,""
                ?? transform(nBasic                ,"9,999.99"),space(if(lCon,3,8))
                ?? transform(nDailyRate/8/60       ,"999.9999"),space(if(lCon,3,8))
                ?? transform(nUnderMins               ,"99999"),space(if(lCon,3,8))
                ?? transform(nUnderTot                ,"99999"),space(if(lCon,3,8))
                ?? transform(nUTded                ,"9,999.99"),space(if(lCon,3,8))
                ?? transform(nDayTot                 ,"999.99"),space(if(lCon,3,8))
                ?? transform(nRegPay               ,"9,999.99"),space(if(lCon,3,8))
                ?? transform(nOverMins                ,"99999"),space(if(lCon,3,8))
                ?? transform(nOverTot                 ,"99999"),space(if(lCon,3,8))
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
         else
         set printer off
         set console on
         endif
         Message(" Done...")
         inkey(1)
      else
         Message("Printer Not Ready...")
         Bummer()
         inkey(2)
      endif
    endif
    return nil

static function TwiceDoor(lDoor)
local nDoorDed:= 0
 if lDoor
    do while PAYMAST->(!eof())
    nDoor := 0
    if empty(PAYMAST->Emp_Out) .or. (PAYMAST->Emp_Out >= dStart1)
       if FindWage( PAYMAST->(RecNo()),dEnd1)
          PAYTRANS->(dbseek( PAYMAST->(Recno()) ))
          do while PAYTRANS->(!Eof()) .and. ;
                             (PAYTRANS->Rec_no == PAYMAST->(Recno()))
                             if (PAYTRANS->Tr_Date >= dStart1) .and. ;
                                (PAYTRANS->Tr_Date <= dEnd1) .and. ;
                                (PAYTRANS->Tr_AMinus == '1' )
                                nDoor += MinDiff("08:30",PAYTRANS->Tr_AMin)
                             endif
                             PAYTRANS->(DbSkip())
          enddo
          nDoorDed += (((WAGE->Wg_BPay/26)/8)/60) * nDoor
        endif
      endif
      PAYMAST->(DbSkip())
      enddo
    PAYMAST->(DbGotop())
    do while PAYMAST->(!eof())
    nDoor := 0
    if empty(PAYMAST->Emp_Out) .or. (PAYMAST->Emp_Out >= dStart2)
       if FindWage( PAYMAST->(RecNo()),dEnd2)
          PAYTRANS->(dbseek( PAYMAST->(Recno()) ))
          do while PAYTRANS->(!Eof()) .and. ;
                             (PAYTRANS->Rec_no == PAYMAST->(Recno()))
                             if (PAYTRANS->Tr_Date >= dStart2) .and. ;
                                (PAYTRANS->Tr_DAte <= dEnd2) .and. ;
                                (PAYTRANS->Tr_AMinus == '1' )
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

static function GetDays(dstart,dend)
local days := {31,if(isleap(dstart),29,28),31,30,31,30,31,31,30,31,30,31 }
local dd,mm,yy,ndays:= 0
k:=(dend-dstart)+1
 dd:=day(dstart)
 mm:=month(dstart)
 yy:=year(dstart)
for i:= 1 to k
 if dow(ctod(str(mm)+"-"+str(dd)+"-"+substr(str(yy),4,2))) > 1
   nDays++
 endif
 if dd < days[mm]
   dd++
 else
   dd:=1
   if mm < 12
     mm++
   else
     mm:= 01
     yy++
   endif
 endif
next
return nDays

static Function Isleap(param)
local nyy := if(valtype(param) == "D", year(param),param)
local dtest := ctod("02/28/"+str(nyy,4))
return (month(dtest+1) == 2)