
#include "Janus.Ch"
#include "Epson.Ch"

static cDetl1, cDetl2, cDetl3, cName, cDate1, cDate2

function PaySlip()
local cMemo := MemoRead("Period.Sal"), x
if isprinter()
   if len(cMemo) # 0
      cDate1 := substr( MemoLine(cMemo,16,1), 1, 8)
      cDate2 := substr( MemoLine(cMemo,16,1), 9, 8)
      Message("Printing payslips..")
      store .F. to lFF
      set console off
      set printer on
      ?? _PRN_10CPI
      ?? _PRN_CONDOFF
      ?? _PRN_LQON
      ?? _PRN_ROMAN
      for x := 2 to MlCount(cMemo,120)
         cLine := MemoLine(cMemo,120,x)
         cName := substr( cLine, 1, 30)
         nRPay := val( substr( cLine, 31, 10))
         nOTPay:= val( substr( cLine, 41, 10))
         nUTPay:= val( substr( cLine, 51, 10))
         nSSS  := val( substr( cLine, 61, 10))
         nMed  := val( substr( cLine, 71, 10))
         nWTax := val( substr( cLine, 81, 10))
         nOthers:= val( substr( cLine, 91, 10))
         nGPay := val( substr( cLine,101, 10))
         nNet  := val( substr( cLine,111, 10))
         PrintHead()
         FixDetails(nNet,"salary")
         ?  space(4)
         ?? padr(cDetl1,72)
         ?? padr(cDetl1,72)
         ?  space(4)
         ?? padr(cDetl2,72)
         ?? padr(cDetl2,72)
         ?  space(4)
         ?? padr(cDetl3,72)
         ?? padr(cDetl3,72)

         ?
         ?

         ?  space(4)
         ?? padr("Regular Pay .............. "+transform(nRPay,"P99,999.99"),72)
         ?? padr("Regular Pay .............. "+transform(nRPay,"P99,999.99"),72)

         ?

         ?  space(4)
         ?? padr("Add/Deduct:",72)
         ?? padr("Add/Deduct:",72)

         ?  space(4)
         ?? padr("  Overtime       :  " +transform(nOTPay,"9,999.99"),36)
         ?? padr("  SSS Premium    :  "+transform(nSSS,"9,999.99"),36)
         ?? padr("  Overtime       :  " +transform(nOTPay,"9,999.99"),36)
         ?? padr("  SSS Premium    :  "+transform(nSSS,"9,999.99"),36)

         ?  space(4)
         ?? padr("  UnderTime      :  "+transform(nUTPay,"9,999.99"),36)
         ?? padr("  Medicare       :  "+transform(nMED,"9,999.99"),36)
         ?? padr("  UnderTime      :  "+transform(nUTPay,"9,999.99"),36)
         ?? padr("  Medicare       :  "+transform(nMED,"9,999.99"),36)

         ?  space(4)
         ?? padr("  Others         :  "+transform(nOthers,"9,999.99"),36)
         ?? padr("  WithHolding Tax:  "+transform(nWTax,"9,999.99"),36)
         ?? padr("  Others         :  "+transform(nOthers,"9,999.99"),36)
         ?? padr("  WithHolding Tax:  "+transform(nWTax,"9,999.99"),36)

         ?
         ?
         ?  space(4)
         ?? padr("Gross Pay   .............. "+transform(nGPay,"P99,999.99"),72)
         ?? padr("Gross Pay   .............. "+transform(nGPay,"P99,999.99"),72)

         ?
         ?  space(4)
         ?? padr("Net Pay     .............. "+transform(nNet,"P99,999.99"),72)
         ?? padr("Net Pay     .............. "+transform(nNet,"P99,999.99"),72)
         PrintName()
      next
      set printer off
      set console on
   endif
endif
return nil


function PaySlip2()
local cMemo := MemoRead("13Month.Sal"), x
if isprinter()
   if len(cMemo) # 0
      cDate1 := substr( MemoLine(cMemo,16,1), 1, 8)
      cDate2 := substr( MemoLine(cMemo,16,1), 9, 8)
      Message("Printing payslips..")
      store .F. to lFF
      set console off
      set printer on
      for x := 2 to MlCount(cMemo,70)
         cLine := MemoLine(cMemo,70,x)
         cName := substr( cLine, 1, 30)
         nRPay := val( substr( cLine, 31, 10))
         nGPay := val( substr( cLine, 41, 10))
         nWTax := val( substr( cLine, 51, 10))
         nNet  := val( substr( cLine, 61, 10))
         PrintHead()
         FixDetails(nNet,"13th Month salary")
         ?  space(4)
         ?? padr(cDetl1,72)
         ?? padr(cDetl1,72)
         ?  space(4)
         ?? padr(cDetl2,72)
         ?? padr(cDetl2,72)
         ?  space(4)
         ?? padr(cDetl3,72)
         ?? padr(cDetl3,72)

         ?
         ?

         ?  space(4)
         ?? padr("Regular Pay .............. "+transform(nRPay,"P99,999.99"),72)
         ?? padr("Regular Pay .............. "+transform(nRPay,"P99,999.99"),72)

         ?

         ?  space(4)
         ?? padr("Deduct:",72)
         ?? padr("Deduct:",72)

         ?  space(4)
         ?? padr("         WithHolding Tax:  "+transform(nWTax,"P99,999.99"),72)
         ?? padr("         WithHolding Tax:  "+transform(nWTax,"P99,999.99"),72)

         ?

         ?  space(4)
         ?? padr("Gross Pay   .............. "+transform(nGPay,"P99,999.99"),72)
         ?? padr("Gross Pay   .............. "+transform(nGPay,"P99,999.99"),72)

         ?
         ?  space(4)
         ?? padr("Net Pay     .............. "+transform(nNet,"P99,999.99"),72)
         ?? padr("Net Pay     .............. "+transform(nNet,"P99,999.99"),72)

         PrintName()
      next
   endif
   set printer off
   set console on
endif
return nil

function PaySlip3()
local cMemo := MemoRead("5DayInc.Sal"), x
if isprinter()
   if len(cMemo) # 0
      cDate1 := substr( MemoLine(cMemo,16,1), 1, 8)
      cDate2 := substr( MemoLine(cMemo,16,1), 9, 8)
      Message("Printing payslips..")
      store .F. to lFF
      set console off
      set printer on
      for x := 2 to MlCount(cMemo,60)
         cLine := MemoLine(cMemo,60,x)
         cName := substr( cLine, 1, 30)
         nRPay := val( substr( cLine, 31, 10))
         nGPay := val( substr( cLine, 41, 10))
         nNet  := val( substr( cLine, 51, 10))
         PrintHead()
         FixDetails(nNet,"5 Day incentive")
         ?  space(4)
         ?? padr(cDetl1,72)
         ?? padr(cDetl1,72)
         ?  space(4)
         ?? padr(cDetl2,72)
         ?? padr(cDetl2,72)
         ?  space(4)
         ?? padr(cDetl3,72)
         ?? padr(cDetl3,72)

         ?
         ?

         ?  space(4)
         ?? padr("Regular Pay .............. "+transform(nRPay,"P99,999.99"),72)
         ?? padr("Regular Pay .............. "+transform(nRPay,"P99,999.99"),72)

         ?

         ?  space(4)

         ?  space(4)
         ?? padr("Daily Rate  .............. "+transform(nGPay,"P99,999.99"),72)
         ?? padr("Daily Rate  .............. "+transform(nGPay,"P99,999.99"),72)

         ?

         ?  space(4)

         ?
         ?  space(4)
         ?? padr("Net Pay     .............. "+transform(nNet,"P99,999.99"),72)
         ?? padr("Net Pay     .............. "+transform(nNet,"P99,999.99"),72)

         PrintName()
      next
   endif
   set printer off
   set console on
endif
return nil

static function FixDetails(nAmount,cText)
local cString, thou, hund, ones, cent
   thou := substr(transform(namount,"99999.99"),1,2)
   hund := substr(transform(namount,"99999.99"),3,1)
   ones := substr(transform(namount,"99999.99"),4,2)
   cent := substr(transform(namount,"99999.99"),7,2)

   cDetl1 := "Received from Super Travel, Inc. the sum of "+;
             if( !empty(thou), c2digit(thou)+"Thousand", "")
   cDetl2 := if( !empty(hund), c1digit(hund)+"Hundred", "") +;
             " " + if( !empty(ones), c2digit(ones)+"&", "") +;
             " " + cent + "/100               (P" + ;
             transform(namount,"99,999.99") + ")"
   cDetl3 := "representing my " + ctext + " for " + ;
             cDate1 + " to " + cDate2 + "."
   return nil

static function c2digit(cNumStr)
local cTemp
   cTemp := ''
   if (substr(cNumStr,1,1) # " ") .and. (substr(cNumStr,1,1) # "0")
      do case
      case substr(cNumStr,len(cNumStr)-1,1) == "9" ; cTemp := "Ninety "
      case substr(cNumStr,len(cNumStr)-1,1) == "8" ; cTemp := "Eighty "
      case substr(cNumStr,len(cNumStr)-1,1) == "7" ; cTemp := "Seventy "
      case substr(cNumStr,len(cNumStr)-1,1) == "6" ; cTemp := "Sixty "
      case substr(cNumStr,len(cNumStr)-1,1) == "5" ; cTemp := "Fifty "
      case substr(cNumStr,len(cNumStr)-1,1) == "4" ; cTemp := "Forty "
      case substr(cNumStr,len(cNumStr)-1,1) == "3" ; cTemp := "Thirty "
      case substr(cNumStr,len(cNumStr)-1,1) == "2" ; cTemp := "Twenty "
      otherwise
         do case
         case substr(cNumStr,len(cNumStr),1) == "9" ; cTemp := "Nineteen "
         case substr(cNumStr,len(cNumStr),1) == "8" ; cTemp := "Eighteen "
         case substr(cNumStr,len(cNumStr),1) == "7" ; cTemp := "Seventeen "
         case substr(cNumStr,len(cNumStr),1) == "6" ; cTemp := "Sixteen "
         case substr(cNumStr,len(cNumStr),1) == "5" ; cTemp := "Fifteen "
         case substr(cNumStr,len(cNumStr),1) == "4" ; cTemp := "Fourteen "
         case substr(cNumStr,len(cNumStr),1) == "3" ; cTemp := "Thirteen "
         case substr(cNumStr,len(cNumStr),1) == "2" ; cTemp := "Twelve "
         case substr(cNumStr,len(cNumStr),1) == "1" ; cTemp := "Eleven "
         case substr(cNumStr,len(cNumStr),1) == "0" ; cTemp := "Ten "
         endcase
      endcase
   endif
   if (substr(cNumStr,len(cNumStr),1) # ' ') .and. ;
      (substr(cNumStr,len(cNumStr)-1,1) # '1')
      cTemp += c1digit( substr(cNumStr,len(cNumStr),1) )
   endif
   return cTemp

static function c1digit(cNumStr)
local cTemp
   cTemp := ''
   do case
   case substr(cNumStr,len(cNumStr),1) == "9" ; cTemp := "Nine "
   case substr(cNumStr,len(cNumStr),1) == "8" ; cTemp := "Eight"
   case substr(cNumStr,len(cNumStr),1) == "7" ; cTemp := "Seven "
   case substr(cNumStr,len(cNumStr),1) == "6" ; cTemp := "Six "
   case substr(cNumStr,len(cNumStr),1) == "5" ; cTemp := "Five "
   case substr(cNumStr,len(cNumStr),1) == "4" ; cTemp := "Four "
   case substr(cNumStr,len(cNumStr),1) == "3" ; cTemp := "Three "
   case substr(cNumStr,len(cNumStr),1) == "2" ; cTemp := "Two "
   case substr(cNumStr,len(cNumStr),1) == "1" ; cTemp := "One "
   endcase
   return cTemp

static function PrintHead()
      ?? _PRN_CONDOFF
      ?? padc("SUPER TRAVEL, INC.",42)
      ?? padc("SUPER TRAVEL, INC.",42)
      ?
      ?? padc("PAY SLIP",42)
      ?? padc("PAY SLIP",42)
      ?
      ?? _PRN_CONDON
return nil

static function PrintName()
      ?
      ?
      ?  space(4)
      ?? space(30) + padc(alltrim(cName),35) + space(7)
      ?? space(30) + padc(alltrim(cName),35) + space(7)
      ?  space(4)
      ?? space(30) + repl('-',35)  + space(7)
      ?? space(30) + repl('-',35)  + space(7)
      ?  space(4)
      ?? space(30) + padc("Name of Employee",35) + space(7)
      ?? space(30) + padc("Name of Employee",35) + space(7)

      ?
      ?
      ?  space(4)
      ?? space(30) + repl('-',35)  + space(7)
      ?? space(30) + repl('-',35)  + space(7)
      ?  space(4)
      ?? space(30) + padc("Signature & Date",35) + space(7)
      ?? space(30) + padc("Signature & Date",35) + space(7)
      if lFF
         lFF = .F.
         ? _PRN_FFEED
      else
         ?  ;  ?  ;  ?  ;  ?  ; ?  ; ?
         lFF = .T.
      endif
return nil