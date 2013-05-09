// Filename:      REPORT_B.PRG
// System-Name:   Bank Settlement Summary Reports
// Module:        File Handling Module
// Author:        Rollie C. Ibarra
// Date-Started:  September 7, 1993
// Last-Update:   September 7, 1993

#include "Mode.Ch"
#include "Inkey.Ch"
#include "SetCurs.Ch"
#include "Bsp.Ch"

static vDollar_Rate, vEVF_Rate, nTkt_Cnt, nAuto_Tkt
static vXmit_Peso, vXmit_Doll, vRemit_Peso, vRemit_Doll, ;
       vComm_Peso, vComm_Doll, vTax_Peso, vTax_Doll, vACM_Peso, vACM_Doll
static nConj_Cnt, nTEC_Cnt, nOEC_Cnt, nPTA_Cnt, nRTT_Cnt, nVoid_Cnt
static nACM_Cnt, nADM_Cnt, nRN_Cnt, vACM_Total, vADM_Total, vRN_Total
static aCredit_Balance, aVoid_Sti, aVoid_Pax

function Sum_Repo()
   if GetDates_Evf() .and. Get_Balances()
      if isPrinter()
         if NetUse("ACR",DB_SHARED,NUM_SECONDS)
             set index to ACR
         endif
         ACR->(DbSeek(dStartDate))
         vDollar_Rate := ACR->AMOUNT
         ACR->(DbCloseArea())
         Message("Press any key when ready...")
         inkey(0)
         Set(_SET_CONSOLE,.f.)
         Set(_SET_PRINTER,.t.)
         Message("Printing...")
         ?  chr(18)                     //10 cpi
         ?? chr(27) + chr(119)+ chr(1)   // Double Heigth
         ?? chr(27)+chr(107)+chr(0)     //Roman Type
         ?? chr(27)+chr(120)+chr(1)     //NLQ on
         ?
         ? "þAGENCY SALES TRANSMITTAL"
         ?
         ?
         ? "Period :"+substr(expand(dStartDate),1,2)+" ";
                       +substr(expand(dStartDate),3,3)+" ";
                       +substr(expand(dStartDate),6,2)+" to ";
                       +substr(expand(dEndDate),1,2)+" ";
                       +substr(expand(dEndDate),3,3)+" ";
                       +substr(expand(dEndDate),6,2)
         ?? chr(27) + chr(119)+ chr(0)  // Double Heigth off
         ?
         ?
         ? space(47),"Peso (PHP)",space(5),"Dollar (USD)"
         ?
         // Initialize Grand Variables //
         nTkt_Cnt:= nAuto_Tkt:= nConj_Cnt:= nTEC_Cnt:= nOEC_Cnt:= ;
         nPTA_Cnt:= nRTT_Cnt:= nVoid_Cnt :=0
         vXmit_Peso:= vComm_Peso:= vRemit_Peso:= vTax_Peso:= vACM_Peso:= 0
         vXmit_Doll:= vComm_Doll:= vRemit_Doll:= vTax_Doll:= vACM_Doll:= 0
         aVoid_Sti := {}  ;  aVoid_Pax := {}
         for x:=1 to 5    ;     Print_Sum(x)    ;    next
         Count_Memo()
         ?
         ? "Total Ticket Count :",nTkt_Cnt
         ?
         ? "ADM ...................."+transform(nADM_Cnt,"999")
         ? "ACM ...................."+transform(nACM_Cnt,"999")
         ? "Refund Notice .........."+transform(nRN_Cnt,"999")
         ? "RTT ...................."+transform(nRTT_Cnt,"999")
         ? "Conj. Xerox ............"+transform(nConj_Cnt,"999")
         ? "PTA 356 ................"+transform(nPTA_Cnt,"999")
         ? "TEC....................."+transform(nTEC_Cnt,"999")
         ? "OEC ...................."+transform(nOEC_Cnt,"999")
         ?

         cTkt := ""   ;  nVcnt := 0
         for x:=1 to len(aVoid_Pax)
             if aVoid_Pax[x][1] == cTkt
                aVoid_Pax[x][1] := space(18)
             else
                cTkt:=aVoid_Pax[x][1]
                nVcnt ++
             endif
         next
         aAdd(aVoid_Sti,{"PX",nVcnt})

         ? "VOIDED/CANCELLED STD's"
         for x:=1 to len(aVoid_Sti)
             ? space(5)+aVoid_Sti[x][1]+" ",aVoid_Sti[x][2]
         next

         ?
         ? "VOIDED/CANCELLED STD's TO BE CHARGED TO PAX/AGENTS"
         for x:=1 to len(aVoid_pax)
             ? space(5),substr(aVoid_Pax[x][1],5,14),space(2),aVoid_Pax[x][2]
         next
         ?
         eject

         vACM_Total := vADM_Total:= vRN_Total :=0
         ? chr(27) + chr(119)+ chr(1)   // Double Heigth
         ?
         ?
         ? "þSUMMARY OF BSP REPORT - PHP"
         ?
         ?
         ? "Period :"+substr(expand(dStartDate),1,2)+" ";
                       +substr(expand(dStartDate),3,3)+" ";
                       +substr(expand(dStartDate),6,2)+" to ";
                       +substr(expand(dEndDate),1,2)+" ";
                       +substr(expand(dEndDate),3,3)+" ";
                       +substr(expand(dEndDate),6,2)
         ?? chr(27) + chr(119)+ chr(0)  // Double Heigth off
         ?
         ?
         ?
         ?
         ? space(53)+"        Gross"+"  "+"   Commission"+"  "+"   Remittance"
         vComm_Peso += vACM_Peso    // Add commission from Airlines
         vRemit_Peso := vXmit_Peso - vComm_Peso   // less total Agency Commission
         ?  space(53)+transform(vXmit_Peso,"99,999,999.99")
         ?? space(2 )+transform(vComm_Peso,"99,999,999.99")
         ?? space(2 )+transform(vRemit_Peso,"99,999,999.99")
         ? "Add : Travel Tax        "
         ?? space(14)+transform(vTax_Peso,"99,999,999.99")
         Compute_Memo(1)
         ? "    Voided & Cancelled  "
         ? "    Documents           "+transform(nVoid_Cnt,"999")+" Docs "
         vAllowed := int(round(nTkt_Cnt*(4/100),0))
         ? "    Allowed Voided and  "
         ? "    Cancelled           "+transform(vAllowed ,"999")+" Docs "
         if (nVoid_Cnt>vAllowed)
            nResult:=nVoid_Cnt-vAllowed
         else  ; nResult:= 0  ;  endif
         if  ((nAuto_Tkt/nTkt_Cnt)*100 > 60) .and. (nResult > 0)
         ? "    Subject to Exemption"
         ? "    of 60% and over     "
         ?? transform(nResult,"999")+" Docs "
         nResult:= 0
         endif
         ? "    Subject to EVF       ---------"
         ? "    of "+transform(vEVF_Rate,"99.99")+" (Pesos)    "
         ?? transform(nResult,"999")+" Docs "
         ?? space(5) + transform(nResult * vEVF_Rate,"99,999,999.99")
         vAdditional := vADM_Total + vTax_Peso + (nResult * vEVF_Rate)
         ?? space(32)+transform(vAdditional,"99,999,999.99")
         ? space(39)+repl('-',13)+space(32)+repl('-',13)
         vTotal_Addl := vAdditional + vRemit_Peso
         ? space(83)+transform(vTotal_Addl,"99,999,999.99")
         ? "Less :                         "
         Compute_Memo(2)
         ? "    Refund Notice :     "
         Compute_Memo(3)
         nTotal_Ded := vACM_Total + vRN_Total
         ? space(83)+transform(nTotal_Ded,"99,999,999.99")
         vTotal_Sum := vTotal_Addl - nTotal_Ded
         ? space(39)+repl('-',13)+space(32)+repl('-',13)
         ? "Total Due for the Period "
         ?? space(58)+transform(vTotal_Sum,"99,999,999.99")
         eject

         vACM_Total := vADM_Total:= vRN_Total :=0
         ? chr(27) + chr(119)+ chr(1)   // Double Heigth
         ? "þSUMMARY OF BSP REPORT - USD"
         ?
         ?
         ? "Period :"+substr(expand(dStartDate),1,2)+" ";
                       +substr(expand(dStartDate),3,3)+" ";
                       +substr(expand(dStartDate),6,2)+" to ";
                       +substr(expand(dEndDate),1,2)+" ";
                       +substr(expand(dEndDate),3,3)+" ";
                       +substr(expand(dEndDate),6,2)
         ?? chr(27) + chr(119)+ chr(0)  // Double Heigth off
         ?
         ?
         ?
         ?
         ? space(53)+"        Gross"+"  "+"   Commission"+"  "+"   Remittance"
         ?  space(53)+transform(vXmit_Doll,"99,999,999.99")
         ?? space(2 )+transform(vComm_Doll + vACM_Doll,"99,999,999.99")
         ?? space(2 )+transform(vXmit_Doll-(vComm_Doll+vACM_Doll),"99,999,999.99")
         ? "Add : Travel Tax        "
         ?? space(59)+transform(vTax_Doll,"99,999,999.99")
         Compute_Memo(4)
         vAdditional := vADM_Total + vTax_Doll
         ? space(83)+repl('-',13)
         vTotal_Addl := vAdditional + vXmit_Doll-(vComm_Doll+vACM_Doll)
         ? space(83)+transform(vTotal_Addl,"99,999,999.99")
         ? "Less :                         "
         for x:=1 to 3
            if !empty(aCredit_Balance[x][1])
               ? aCredit_Balance[x][1]
               ?? transform(aCredit_Balance[x][2],"99,999,999.99")
               vACM_Total += aCredit_Balance[x][2]
            endif
         next
         Compute_Memo(5)
         ? "    Refund Notice :            "
         Compute_Memo(6)
         ? space(83)+transform(vACM_Total,"99,999,999.99")
         ? space(39)+repl('-',13)+space(31)+repl('-',13)
         vTotal_Sum := vTotal_Addl - vACM_Total
         ? "Total Due for the Period "
         ?? space(58)+transform(vTotal_Sum,"99,999,999.99")
         eject
         Set(_SET_PRINTER,.f.)
         Set(_SET_CONSOLE,.t.)
      else
         Tone(100,3)
         Message("Printer Not Ready...")
         inkey(2)
      endif
   endif
return nil

static function Print_Sum(x)
local nEnd:=0, cStart, cEnd, nStransp:=nStransd:=0, aSeries:={}
local nCONJ := nPTA := nTEC := nOEC := nRTT := 0
   cDbf:=OpenBSP(x)
   nvlast:=len(aVoid_Pax)
   (cDbf)->(DbSetOrder(DATE_NDX))
   (cDbf)->(DbSeek(dtos(dStartDate)))
   do while (DATE <= dEndDate) .and. (cDbf)->(!Eof())
      Message("Computing "+Alias()+" - Rec# "+transform(RecNo(),"9999")+"...")
      // Compute for airline grand totals  //
      vXmit_Peso  +=  TRANSMIT_P   ;   vXmit_Doll  +=  TRANSMIT_D
      vComm_Peso  +=  if(CRATE_P>0,TRANSMIT_P-REMIT_P,0.00)
      vComm_Doll  +=  if(CRATE_D>0,TRANSMIT_D-REMIT_D,0.00)
*      vRemit_Peso  +=  REMIT_P
                                       vRemit_Doll +=  REMIT_D
      vTax_Peso +=  TAX_P          ;   vTax_Doll   +=  TAX_D
      vACM_Peso +=  ACM_P          ;   vACM_Doll   +=  ACM_D
      // Compute for series totals
      if len(alltrim(TICKET_NO,5))!=19
         x:=aScan(aSeries,{ |x| x[1] == substr(TICKET_NO,5,8) })
         if (x==0)
            aAdd(aSeries,{substr(TICKET_NO,5,8),substr(TICKET_NO,5,14);
            ,substr(TICKET_NO,5,14), 0,0 })
            x:=len(aSeries)
         endif
         if substr(TICKET_NO,5,14) < aSeries[x][2]
            aSeries[x][2]:=substr(TICKET_NO,5,14)
         endif
         if substr(TICKET_NO,5,14) > aSeries[x][3]
            aSeries[x][3]:=substr(TICKET_NO,5,14)
         endif
         aSeries[x][4] += TRANSMIT_P
         aSeries[x][5] += TRANSMIT_D
         nTkt_Cnt ++
         if substr(TICKET_NO,5,2) == "33"
            nAuto_Tkt ++
         endif
      endif
      // Check - out remark fields //
      if at("CONJ",upper(REMIT_RMRK))!=0
         nConj_Cnt += val(substr(REMIT_RMRK,1,1))
      endif
      if at("OEC",upper(TAX_RMRK))!=0 ;    nOEC_Cnt++   ;  endif
      if at("RTT",upper(TAX_RMRK))!=0 ;    nRTT_Cnt++   ;  endif
      if at("TEC",upper(TAX_RMRK))!=0 ;    nTEC_Cnt++   ;  endif
      if at("PTA",upper(TAX_RMRK))!=0 ;    nPTA_Cnt++   ;  endif
      // Check voided/cancelled tickets //
      if (substr(TICKET_NO,1,3) == "000")
         if (aScan(aVoid_Pax,{ |x| x[1] == substr(TICKET_NO,1,18)})==0)
             nVoid_Cnt++
         endif
         if (at('VOID',upper(PASSENGER))!=0) .or.;
            (at('CANCELLED',upper(PASSENGER))!=0)
            cname := substr(PASSENGER ,at('(',PASSENGER)+1,2)
            x:=aScan(aVoid_Sti,{|x| x[1] == cname})
            if x==0 ; aAdd(aVoid_Sti,{cname,0}) ; x:=len(aVoid_Sti) ; endif
            aVoid_Sti[x][1]:=cname
            aVoid_Sti[x][2] ++
         else
            aAdd(aVoid_Pax,{substr(TICKET_NO,1,18),PASSENGER})
         endif
      endif
      DbSkip()
   enddo
   for x:=1 to len(aSeries)
      ? aSeries[x][2]," to ",aSeries[x][3],space(10)
      ?? transform(aSeries[x][4],"99,999,999.99"),space(5)
      ?? transform(aSeries[x][5],"99,999,999.99")
   next
   if len(aVoid_Pax) > nvlast
      aSort(aVoid_Pax,nvlast+1,,{|x,y| x[1] < y[1]})
   endif
   (cDbf)->(DbCloseArea())
return nil

static function Count_Memo()
   nACM_Cnt := nADM_Cnt := nRN_Cnt := 0
   if Netuse("MEMO",DB_SHARED,NUM_SECONDS)
      set index to MEMO
   endif
   MEMO->(DbSeek(dStartDate))
   do while (MEMO->DATE<=dEndDate) .and. ( MEMO->(!Eof()) )
         Message("Searching MEMO file - Rec# "+transform(RecNo(),"9999")+"...")
         if substr(MEMO->FOLIO,1,3) == "ADM"  ;   nADM_Cnt ++  ;  endif
         if substr(MEMO->FOLIO,1,3) == "ACM"  ;   nACM_Cnt ++  ;  endif
         if (substr(MEMO->FOLIO,1,3) != "ADM" ) .and. ;
            (substr(MEMO->FOLIO,1,3) != "ACM" )
            nRN_Cnt ++
         endif
         MEMO->(DbSkip())
   enddo
   MEMO->(DbCloseArea())
return nil

static function Compute_Memo(xMode)
   if Netuse("MEMO",DB_SHARED,NUM_SECONDS)
      set index to MEMO
   endif
   MEMO->(DbSeek(dStartDate))
   do while (MEMO->DATE)<=dEndDate .and. ( MEMO->(!Eof()) )
         Message("Searching MEMO file - Rec# "+transform(RecNo(),"9999")+"...")
         do case
         case xMode == 1
             if !empty(MEMO->FOLIO)
                if (substr(MEMO->FOLIO,1,3) == "ADM") .and. !empty(MEMO->AMOUNT_P)
                   ? space(8)+MEMO->FOLIO
                   ?? space(10)+transform(MEMO->AMOUNT_P,"99,999,999.99")
                   vADM_Total += MEMO->AMOUNT_P
                endif
             endif
         case xMode == 2
             if !empty(MEMO->FOLIO)
                if (substr(MEMO->FOLIO,1,3) == "ACM") .and. !empty(MEMO->AMOUNT_P)
                   ? space(8)+MEMO->FOLIO
                   ?? space(10)+transform(MEMO->AMOUNT_P,"99,999,999.99")
                   vACM_Total += MEMO->AMOUNT_P
                endif
             endif
         case xMode == 3
             if !empty(MEMO->FOLIO)
                if (substr(MEMO->FOLIO,1,3) != "ADM") .and. ;
                   (substr(MEMO->FOLIO,1,3) != "ACM") .and. ;
                   !empty(MEMO->AMOUNT_P)
                   ? space(8)+MEMO->FOLIO
                   ?? space(10)+transform(MEMO->AMOUNT_P,"99,999,999.99")
                   vRN_Total += MEMO->AMOUNT_P
                endif
             endif
         case xMode == 4
             if !empty(MEMO->FOLIO)
                if (substr(MEMO->FOLIO,1,3) == "ADM") .and. !empty(MEMO->AMOUNT_D)
                   ? space(8)+MEMO->FOLIO
                   ?? space(10)+transform(MEMO->AMOUNT_D,"99,999,999.99")
                   vADM_Total += MEMO->AMOUNT_D
                endif
             endif
         case xMode == 5
             if !empty(MEMO->FOLIO)
                if (substr(MEMO->FOLIO,1,3) == "ACM") .and. !empty(MEMO->AMOUNT_D)
                   ? space(8)+MEMO->FOLIO
                   ?? space(10)+transform(MEMO->AMOUNT_D,"99,999,999.99")
                   vACM_Total += MEMO->AMOUNT_D
                endif
             endif
         case xMode == 6
             if !empty(MEMO->FOLIO)
                if (substr(MEMO->FOLIO,1,3) != "ADM") .and. ;
                   (substr(MEMO->FOLIO,1,3) != "ACM") .and. ;
                   !empty(MEMO->AMOUNT_D)
                   ? space(8)+MEMO->FOLIO
                   ?? space(10)+transform(MEMO->AMOUNT_D,"99,999,999.99")
                   vACM_Total += MEMO->AMOUNT_D
                endif
             endif
         endcase
         MEMO->(DbSkip())
   enddo
   MEMO->(DbCloseArea())
return nil

static function GetDates_Evf()
local winfo
   dStartDate:=dEndDate:=CToD("  -  -  ")  ;  vEVF_Rate:=0.00
   Message("Enter transaction dates, press Esc to abort.")
   winfo:=OpenWindow(09,15,14,63,"Date & EVF Information Box")
   @ 11,17 say "Enter starting date (MM/DD/YY format)" get dStartDate
   @ 12,17 say "        Ending date (MM/DD/YY format)" get dEndDate
   @ 13,17 say "                             EVF Rate" get vEVF_Rate pict "99.99"
   SetCursor(SC_NORMAL)
   read
   SetCursor(SC_NONE)
   CloseWindow(winfo)
return If(LastKey()==K_ESC,.F.,.T.)

static function Get_Balances()
local wBal
   aCredit_Balance := { {space(30),0.00}, {space(30),0.00}, {space(30),0.00} }
   wBal:=OpenWindow(09,15,14,63,"Credit Balances Box")
   @ 10, 17 say "Remarks                        Amount"
   @ 11, 17 get aCredit_Balance[1][1]
   @ row(), col()+2 get aCredit_Balance[1][2] pict "99,999,999.99"
   @ 12, 17 get aCredit_Balance[2][1]
   @ row(), col()+2 get aCredit_Balance[2][2] pict "99,999,999.99"
   @ 13, 17 get aCredit_Balance[3][1]
   @ row(), col()+2 get aCredit_Balance[3][2] pict "99,999,999.99"
   SetCursor(SC_NORMAL)
   read
   SetCursor(SC_NONE)
   CloseWindow(wBal)
return If(LastKey()==K_ESC,.F.,.T.)

function AirSummary()
local wAir
private cCode := "   ", nMonth, nYear
      if GetInfo()
         if empty(nMonth)
            n1 := 1        ;   n2 := 12
         else
            n1 := nMonth   ;  n2 := nMonth
         endif
         aDetails := {}
         for x := n1 to n2
            dStartDate := ctod(padl(transform(x,"99"),2,"0")+"-01-"+;
               transform(nYear,"99"))
            dEndDate := if(x<12,ctod(padl(transform(x+1,"99"),2,"0")+;
               "-01-"+transform(nYear,"99"))-1,ctod("12-31-"+;
               transform(nYear,"99")) )
            store 0 to nRem_PHP, nRem_USD
            for u:=1 to 5
               cDbf := OpenBsp(u)
               (cDbf)->(DbSetOrder(DATE_NDX))
               (cDbf)->(DbSeek(dtos(dStartDate)))
               do while (cDbf)->(!Eof()) .and. ((cDbf)->Date <= dEndDate)
                  Message("Reading " + cDbf + " Record #"+ ;
                     transform((cDbf)->(RecNo()),"9999") + ;
                     " ("+ cMonth(dStartdate) + " Totals)..." )
                  if (cCode == substr((cDbf)->Ticket_No,1,3))
                     if(u == 1)
                        nRem_Php += (cDbf)->Airfare_P
                        nRem_Usd += (cDbf)->Airfare_D
                     else
                        nRem_Php += (cDbf)->Remit_P
                        nRem_Usd += (cDbf)->Remit_D
                     endif
                  endif
                  (cDbf)->(DbSkip())
               enddo
               (cDbf)->(DbCloseArea())
            next
            aAdd(aDetails,{cMonth(dStartDate),nRem_Php,nRem_Usd})
         next
         wAir := OpenWindow(02,10,22,69,"Airline Summary")
         Airline->(DbSeek(cCode))
         cAirline := Airline->Airline
         @ 04, 12 say "Airline : "+ cAirline
         @ 06, 17 say "        Month          Pesos          Dollar"
         store 0 to nRem_Php, nRem_Usd
         for x:=1 to len(aDetails)
            @ row()+1, 20 say padr(aDetails[x][1],15) +;
               transform(aDetails[x][2],"9,999,999.99") + space(3) +;
               transform(aDetails[x][3],"9,999,999.99")
            nRem_Php += aDetails[x][2]
            nRem_Usd += aDetails[x][3]
         next
         @ row()+1, 20 say repl('=',43)
         @ row()+1, 20 say space(15) + ;
               transform(nRem_Php,"9,999,999.99") + space(3) +;
               transform(nRem_Usd,"9,999,999.99")
         Message("Esc-Abort   F7-Print")
         nKey := inkey(0)
         do while nkey!=K_ESC
            if nKey==K_F7
               if IsPrinter()
                  Set(_SET_CONSOLE,.F.)
                  Set(_SET_PRINTER,.T.)
                  Sti_Header(1)
                  ? chr(27) + chr(119)+ chr(1)     // Double Heigth
                  ?? chr(27) + chr(107) + chr(0)   // select Roman
                  ?? chr(27)+chr(120)+chr(1)       // NLQ on
                  ?? "þAirline Summary Report"
                  ?
                  ? "Airline :"+ cAirline
                  ?
                  ?  chr(27)+chr(119)+chr(0)       // Double Heigth off
                  ?
                  ? space(10),"        Month           Peso          Dollar"
                  ?
                  for x:=1 to len(aDetails)
                     ? space(13), padr(aDetails[x][1],15) + ;
                        transform(aDetails[x][2],"9,999,999.99") + space(3)+;
                        transform(aDetails[x][3],"9,999,999.99")
                  next
                  ?
                  ? space(13),repl('=',43)
                  ? space(13),space(15) + ;
                        transform(nRem_Php,"9,999,999.99") + space(3) +;
                        transform(nRem_Usd,"9,999,999.99")
                  Set(_SET_PRINTER,.F.)
                  Set(_SET_CONSOLE,.T.)
                  Message("Printed...")
                  Tone(300,1)
                  Inkey(2)
                  Message("Esc-Abort   F7-Print")
               else
                  Message("Printer not ready...")
                  Tone(100,3)
                  Inkey(2)
               endif
            endif
            nkey := inkey(0)
         enddo
         CloseWindow(wAir)
      endif
return nil

static function GetInfo()
local winfo,cMonth := cYear := "  "
   Message("Enter transaction dates, press Esc to abort.")
   winfo:=OpenWindow(09,15,14,63,"Information Box")
   @ 11,17 say "               Airline Code" get cCode
   @ 12,17 say " Month (1-January, so on..)" get cMonth pict "99"
   @ 13,17 say "                  Year (99)" get cYear  pict "99"
   SetCursor(SC_NORMAL)
   read
   SetCursor(SC_NONE)
   CloseWindow(winfo)
   nMonth := val(cMonth)   ;  nYear := val(cYear)
return If(LastKey()==K_ESC,.F.,.T.)


// <EOF> - REPORT_B.PRG //
