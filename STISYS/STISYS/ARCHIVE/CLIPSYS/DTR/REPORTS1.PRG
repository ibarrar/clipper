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

static function Check_HOLIDAY()
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

static function Regular_Day()
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


function UnderOverRep(cEmpCode,lDoor)
/*
    Purpose : Prints Undertime and Overtime filed by employees
              for the payroll period.
*/
   if getdates()
      if isprinter()
         Message("Thinking...")
         if netuse("PAYMAST",DB_SHARED,NUM_SECONDS)
            set index to PAYMAST
         endif
         if netuse("PAYTRANS",DB_SHARED,NUM_SECONDS)
            set index to PayTrans
         endif
         if netuse("WAGE",DB_SHARED,NUM_SECONDS)
            set index to WAGE
         endif
         if netuse("Holiday",DB_SHARED,NUM_SECONDS)
            set index to HOLIDAY
         endif
         nDoorDed:=Comp_Door(lDoor)
         set console off
*         set printer to "Temp.TXT"
         set printer on
         Sti_Header(2)
         ?? _PRN_10CPI + _PRN_CONDOFF
         ?? _PRN_LQON + _PRN_ROMAN
         ?? _PRN_HDBLE
         ?
         ?
         ?  "þUnderTime & OverTime Report for "
         ?? if('R' $ cEmpCode,"Regular","Probationary/Trainee")
         ?
         ?
         ?  "Period :",dStartDate," to ",dEndDate
         ?  _PRN_HNORM
         ?? _PRN_CONDON
         ?
         ?
         ?
         ?? space(29),"Basic Pay"
         ?? space(8),"UnderTime"
         ?? space(6),"UnderTime"
         ?? space(5),"UnderTime"
         ?? space(19),"No. of Days"
         ?? space(20),"Regular OT"
         ?? space(4),"Regular OT"
         ?? space(20),"Holiday"
         ?
         ?? "Employee Name"
         ?? space(16),"Semi-Mon."
         ?? space(10),"Rate"
         ?? space(8),"Total Mins."
         ?? space(4),"(Status)"
         ?? space(7),"Amount"
         ?? space(8),"Worked"
         ?? space(10),"Amount"
         ?? space(6),"Total Mins"
         ?? space(5),"(Status)"
         ?? space(7),"Amount"
         ?? space(5),"(Total Hrs.)"
         ?? space(6),"Amount"
         ?? space(8),"Gross Pay"
         ?
         ?

         PAYMAST->(DbGotop())
         store 0 to nEmpCount, nTotUT, nTotAbs
         store 0 to nTotOT, nTotHol, nTotGross
         store 0 to nTotUTm, nTotAbsd, nTotOTm, nTotHolh
         do while PAYMAST->(!eof())
            Message("Printing Rec#"+transform(PAYMAST->(RecNo()),"999"))
            if FindWage( PAYMAST->(RecNo()), dEndDate )
            if (empty(PAYMAST->Emp_Out) .or. ;
                (PAYMAST->Emp_Out >= dStartDate)) .and. ;
                (WAGE->Wg_Stat $ cEmpCode)
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
                ?? transform(WAGE->Wg_BPay/2       ,"9,999.99"),space(8)
                ?? transform(nDailyRate/8/60       ,"999.9999"),space(8)
                ?? transform(nUnderMins               ,"99999"),space(8)
                ?? transform(nUnderTime               ,"99999"),space(8)
                ?? transform(nUTded                ,"9,999.99"),space(8)
                ?? transform(nDayCount               ,"999.99"),space(8)
                ?? transform(nRegPay               ,"9,999.99"),space(8)
                ?? transform(nOverMins                ,"99999"),space(8)
                ?? transform(nOverTime                ,"99999"),space(8)
                ?? transform(nOTpay                ,"9,999.99"),space(8)
                ?? transform((nLegal_Wrk+nSpcl_Wrk)/60,"99.99"),space(8)
                ?? transform(nLegalPay + nSpclPay  ,"9,999.99"),space(8)
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
            endif
            PAYMAST->(DbSkip())
         enddo
         ? repl('=',228)
         ? "Totals : ",transform(nEmpCount,"999"),space(65)
         ?? transform(nTotUTm   ,    "99999"),space(8)
         ?? transform(nTotUT    , "9,999.99"),space(8)
         ?? space(46)
         ?? transform(nTotOTm   ,    "99999"),space(8)
         ?? transform(nTotOT    , "9,999.99"),space(8)
         ?? transform(nTotHolh  ,    "99.99"),space(8)
         ?? transform(nTotHol   , "9,999.99"),space(8)
         ?? transform(nTotGross ,"99,999.99")
         ? _PRN_FFEED
         HOLIDAY->(DbCloseArea())
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



function DoorCloseRep()
/*
   Purpose : Prints Door closed report, filed by employees
             for the payroll period.
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
         if netuse("PAYTRANS",DB_SHARED,NUM_SECONDS)
            set index to PayTrans
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
            if FindWage( PAYMAST->(RecNo()), dEndDate )
            if empty(PAYMAST->Emp_Out) .or. ;
                (PAYMAST->Emp_Out >= dStartDate)
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
            endif
            PAYMAST->(DbSkip())
         enddo
         ? repl('=',120)
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

function GetDates()
/*
   Purpose : Accepts dates from the user, to cover the report(s)
             to be prepared.
*/
local wDate
   dStartDate:=dEndDate:=CToD("")
   Message("Enter dates to cover report")
   wDate:=OpenWindow(09,15,13,64,"Date Information Box")
   @ 11,17 say " Enter starting date (MM/DD/YY format)" get dStartDate
   @ 12,17 say "         Ending date (MM/DD/YY format)" get dEndDate
   SetCursor(SC_NORMAL)
   HeyThere()
   read
   SetCursor(SC_NONE)
   CloseWindow(wDate)
return If(LastKey()==K_ESC,.F.,.T.)

/*
  Eof<Reports1.PRG>
*/