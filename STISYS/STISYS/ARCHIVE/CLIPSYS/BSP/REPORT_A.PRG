// Filename:      REPORT_A.PRG
// System-Name:   Bank Settlement Plan System
// Module:        Report Generation Module
// Author:        Rollie C. Ibarra
// Date-Started:  August 28, 1993
// Last-Update:   August 28, 1993

#include "Mode.Ch"
#include "SetCurs.Ch"
#include "Inkey.Ch"
#include "BSP.Ch"

static cPax_Name, aGrandAir, aAir
static nG_CONJ, nG_TEC, nG_OEC, nG_PTA, nG_RTT
static nCONJ, nTEC, nOEC, nPTA, nRTT

function Indi_Repo()
   if GetDates_Pax()
      if isPrinter()
         Message("Press any key when ready...")
         inkey(0)
         Set(_SET_CONSOLE,.f.)
         Set(_SET_PRINTER,.t.)
         Message("Printing...")
         STI_Header(2)
         ?? chr(18)                     //10 cpi
         ?? chr(27)+chr(119)+chr(1)     // Double Heigth
         ?? chr(27)+chr(107)+chr(0)     //Roman Type
         ?? chr(27)+chr(120)+chr(1)     //NLQ on
         ? "þBSP Individual Summary Report "
         ?
         ? "Period :"+substr(expand(dStartDate),1,2)+" ";
                       +substr(expand(dStartDate),3,3)+" ";
                       +substr(expand(dStartDate),6,2)+" to ";
                       +substr(expand(dEndDate),1,2)+" ";
                       +substr(expand(dEndDate),3,3)+" ";
                       +substr(expand(dEndDate),6,2)
         ?
         ? "Passenger's Name : ",cPax_Name
         ?
         ?? chr(27) + chr(119)+ chr(0)  // Double Heigth off
         ?? chr(15)                     //Condense on
         ?  space(46)
         ?? " ÚÄÄÄÄÄ AirFare ÄÄÄÄÄ¿   "+"ÚÄÄÄ Transmittal ÄÄÄ¿   "
         ?? "ÚÄÄÄ Commission ÄÄÄÄ¿   "+"ÚÄÄÄ Remittance ÄÄÄÄ¿   "
         ?? "ÚÄÄÄÄÄÄ Tax ÄÄÄÄÄÄÄÄ¿   "+"ÚÄ Fare Diff. Due ÄÄ¿"
         ?? chr(27)+chr(120)+chr(0)      //NLQ off
         aGrandAir:={}
         nG_CONJ:= nG_PTA:= nG_RTT:= nG_OEC:= nG_TEC:=0
         for x:=1 to 4
             Print_Indi(x)
         next
         Prn_Indi_Grand()
         Set(_SET_CONSOLE,.t.)
         Set(_SET_PRINTER,.f.)
      endif
   endif
return

static function Print_Indi(x)
   aAir:={}
   nCONJ := nPTA := nTEC := nOEC := nRTT := 0
   cDbf:=OpenBSP(x)
   (cDbf)->(DbSetOrder(PAX_NDX))
   if (cDbf)->(DbSeek(cPax_Name))
      do while (date < dStartDate) .and. ;
               (cPax_Name == substr(upper(PASSENGER),1,len(cPax_Name)) )
           DbSkip()
      enddo
      do while (cPax_Name == substr(upper(PASSENGER),1,len(cPax_Name)) ) .and.;
               (DATE <= dEndDate) .and. (cDbf)->(!Eof())
            ? space(12)+expand(DATE)+space(2)+TICKET_NO+space(7)
            ?? blank_ifzero(AIRFARE_P,"999,999.99")+" "+;
               blank_ifzero(AIRFARE_D,"999,999.99")+"   "
            ?? blank_ifzero(TRANSMIT_P,"999,999.99") + " " +;
               blank_ifzero(TRANSMIT_D,"999,999.99") + "   "
            ?? blank_ifzero(if(CRATE_P>0,TRANSMIT_P-REMIT_P,0.00),"999,999.99")+" "+;
               blank_ifzero(if(CRATE_D>0,TRANSMIT_D-REMIT_D,0.00),"999,999.99")+"   "
            ?? blank_ifzero(REMIT_P,"999,999.99") + " " +;
               blank_ifzero(REMIT_D,"999,999.99") + "   "
            ?? blank_ifzero(TAX_P,"999,999.99") + " " +;
               blank_ifzero(TAX_D,"999,999.99") + "   "
            ?? blank_ifzero(ACM_P,"999,999.99") + " " +;
               blank_ifzero(ACM_D,"999,999.99")
            // Compute for airline totals  //
            x:=aScan(aAir,{ |x| x[AIRTKT_COD] == substr(TICKET_NO,1,3) })
            if (x==0)
               aAdd(aAir,{substr(TICKET_NO,1,3), 0, 0,0, 0,0, 0,0, 0,0, 0,0, 0,0})
               x:=len(aAir)
            endif
            aAir[x][AIRTKT_CNT]  += 1
            aAir[x][AIRP_AFLD]  +=AIRFARE_P
            aAir[x][AIRD_AFLD]  +=AIRFARE_D
            aAir[x][TRAP_AFLD]  +=TRANSMIT_P
            aAir[x][TRAD_AFLD]  +=TRANSMIT_D
            aAir[x][COMP_AFLD]  +=if(CRATE_P>0,TRANSMIT_P-REMIT_P,0.00)
            aAir[x][COMD_AFLD]  +=if(CRATE_D>0,TRANSMIT_D-REMIT_D,0.00)
            aAir[x][REMP_AFLD]  +=REMIT_P
            aAir[x][REMD_AFLD]  +=REMIT_D
            aAir[x][TAXP_AFLD]  +=TAX_P
            aAir[x][TAXD_AFLD]  +=TAX_D
            aAir[x][ACMP_AFLD]  +=ACM_P
            aAir[x][ACMD_AFLD]  +=ACM_D
            // Check - out remark fields //
            if at("CONJ",upper(REMIT_RMRK))!=0;  nCONJ++  ;  endif
            if at("OEC",upper(TAX_RMRK))!=0 ;    nOEC++   ;  endif
            if at("RTT",upper(TAX_RMRK))!=0 ;    nRTT++   ;  endif
            if at("TEC",upper(TAX_RMRK))!=0 ;    nTEC++   ;  endif
            if at("PTA",upper(TAX_RMRK))!=0 ;    nPTA++   ;  endif
            DbSkip()
      enddo
      //    Print airline totals   //
      ? "Airline Totals :"
      for x:=1 to len(aAir)
            AIRLINE->(DbSeek(aAir[x][AIRTKT_COD]))
            ? AIRLINE->AIR_CODE,"-",AIRLINE->AIRLINE+;
              "("+transform(aAir[x][AIRTKT_CNT],"999")+")"
            ?? blank_ifzero(aAir[x][AIRP_AFLD],"999,999.99")+" "+;
               blank_ifzero(aAir[x][AIRD_AFLD],"999,999.99")+"   "
            ?? blank_ifzero(aAir[x][TRAP_AFLD],"999,999.99")+ " " +;
               blank_ifzero(aAir[x][TRAD_AFLD],"999,999.99")+ "   "
            ?? blank_ifzero(aAir[x][COMP_AFLD],"999,999.99")+ " " +;
               blank_ifzero(aAir[x][COMD_AFLD],"999,999.99")+ "   "
            ?? blank_ifzero(aAir[x][REMP_AFLD],"999,999.99")+ " " +;
               blank_ifzero(aAir[x][REMD_AFLD],"999,999.99")+ "   "
            ?? blank_ifzero(aAir[x][TAXP_AFLD],"999,999.99")+ " " +;
               blank_ifzero(aAir[x][TAXD_AFLD],"999,999.99")+ "   "
            ?? blank_ifzero(aAir[x][ACMP_AFLD],"999,999.99")+ " " +;
               blank_ifzero(aAir[x][ACMD_AFLD],"999,999.99")
      next
      ? "      TOTALS  :                          "
      ?? "("+blank_ifzero(aTotal(aAir,AIRTKT_CNT),"999")+")"
      ?? blank_ifzero(aTotal(aAir,AIRP_AFLD),"999,999.99")+" "+;
         blank_ifzero(aTotal(aAir,AIRD_AFLD),"999,999.99")+"   "
      ?? blank_ifzero(aTotal(aAir,TRAP_AFLD),"999,999.99")+" "+;
         blank_ifzero(aTotal(aAir,TRAD_AFLD),"999,999.99")+"   "
      ?? blank_ifzero(aTotal(aAir,COMP_AFLD),"999,999.99")+" "+;
         blank_ifzero(aTotal(aAir,COMD_AFLD),"999,999.99")+"   "
      ?? blank_ifzero(aTotal(aAir,REMP_AFLD),"999,999.99")+" "+;
         blank_ifzero(aTotal(aAir,REMD_AFLD),"999,999.99")+"   "
      ?? blank_ifzero(aTotal(aAir,TAXP_AFLD),"999,999.99")+" "+;
         blank_ifzero(aTotal(aAir,TAXD_AFLD),"999,999.99")+"   "
      ?? blank_ifzero(aTotal(aAir,ACMP_AFLD),"999,999.99")+" "+;
         blank_ifzero(aTotal(aAir,ACMD_AFLD),"999,999.99")
      // Save Grand Totals
      for z:=1 to len(aAir)
            x:=aScan(aGrandAir,{ |x| x[AIRTKT_COD] == aAir[z][AIRTKT_COD] })
            if (x==0)
               aAdd(aGrandAir,{aAir[z][AIRTKT_COD], 0, 0,0, 0,0, 0,0, 0,0, 0,0, 0,0})
               x:=len(aGrandAir)
            endif
            aGrandAir[x][AIRTKT_CNT]  +=aAir[z][AIRTKT_CNT]
            aGrandAir[x][AIRP_AFLD]  +=aAir[z][AIRP_AFLD]
            aGrandAir[x][AIRD_AFLD]  +=aAir[z][AIRD_AFLD]
            aGrandAir[x][TRAP_AFLD]  +=aAir[z][TRAP_AFLD]
            aGrandAir[x][TRAD_AFLD]  +=aAir[z][TRAD_AFLD]
            aGrandAir[x][COMP_AFLD]  +=aAir[z][COMP_AFLD]
            aGrandAir[x][COMD_AFLD]  +=aAir[z][COMD_AFLD]
            aGrandAir[x][REMP_AFLD]  +=aAir[z][REMP_AFLD]
            aGrandAir[x][REMD_AFLD]  +=aAir[z][REMD_AFLD]
            aGrandAir[x][TAXP_AFLD]  +=aAir[z][TAXP_AFLD]
            aGrandAir[x][TAXD_AFLD]  +=aAir[z][TAXD_AFLD]
            aGrandAir[x][ACMP_AFLD]  +=aAir[z][ACMP_AFLD]
            aGrandAir[x][ACMD_AFLD]  +=aAir[z][ACMD_AFLD]
      next
      nG_CONJ += nCONJ         ;     nG_OEC  += nOEC
      nG_RTT  += nRTT          ;     nG_TEC  += nTEC
      nG_PTA  += nPTA
   else  ;   ?? "*** No Record(s) found ***"   ;   endif
   ? repl('-',188)
   (cDbf)->(DbCloseArea())
return nil

static function Prn_Indi_Grand()
      //    Print Airline Grand totals   //
      if len(aGrandAir) > 0
        ? "Airline Grand Totals :"
        for x:=1 to len(aGrandAir)
            AIRLINE->(DbSeek(aGrandAir[x][AIRTKT_COD]))
            ? AIRLINE->AIR_CODE,"-",AIRLINE->AIRLINE+;
            "("+transform(aGrandAir[x][AIRTKT_CNT],"999")+")"
            ?? blank_ifzero(aGrandAir[x][AIRP_AFLD],"999,999.99")+" "+;
               blank_ifzero(aGrandAir[x][AIRD_AFLD],"999,999.99")+"   "
            ?? blank_ifzero(aGrandAir[x][TRAP_AFLD],"999,999.99")+ " " +;
               blank_ifzero(aGrandAir[x][TRAD_AFLD],"999,999.99")+ "   "
            ?? blank_ifzero(aGrandAir[x][COMP_AFLD],"999,999.99")+ " " +;
               blank_ifzero(aGrandAir[x][COMD_AFLD],"999,999.99")+ "   "
            ?? blank_ifzero(aGrandAir[x][REMP_AFLD],"999,999.99")+ " " +;
               blank_ifzero(aGrandAir[x][REMD_AFLD],"999,999.99")+ "   "
            ?? blank_ifzero(aGrandAir[x][TAXP_AFLD],"999,999.99")+ " " +;
               blank_ifzero(aGrandAir[x][TAXD_AFLD],"999,999.99")+ "   "
            ?? blank_ifzero(aGrandAir[x][ACMP_AFLD],"999,999.99")+ " " +;
               blank_ifzero(aGrandAir[x][ACMD_AFLD],"999,999.99")
        next
        ? "      GRAND TOTALS :                     "
        ?? "("+transform(aTotal(aGrandAir,AIRTKT_CNT),"999")+")"
        ?? blank_ifzero(aTotal(aGrandAir,AIRP_AFLD),"999,999.99")+" "+;
           blank_ifzero(aTotal(aGrandAir,AIRD_AFLD),"999,999.99")+"   "
        ?? blank_ifzero(aTotal(aGrandAir,TRAP_AFLD),"999,999.99")+" "+;
           blank_ifzero(aTotal(aGrandAir,TRAD_AFLD),"999,999.99")+"   "
        ?? blank_ifzero(aTotal(aGrandAir,COMP_AFLD),"999,999.99")+" "+;
           blank_ifzero(aTotal(aGrandAir,COMD_AFLD),"999,999.99")+"   "
        ?? blank_ifzero(aTotal(aGrandAir,REMP_AFLD),"999,999.99")+" "+;
           blank_ifzero(aTotal(aGrandAir,REMD_AFLD),"999,999.99")+"   "
        ?? blank_ifzero(aTotal(aGrandAir,TAXP_AFLD),"999,999.99")+" "+;
           blank_ifzero(aTotal(aGrandAir,TAXD_AFLD),"999,999.99")+"   "
        ?? blank_ifzero(aTotal(aGrandAir,ACMP_AFLD),"999,999.99")+" "+;
           blank_ifzero(aTotal(aGrandAir,ACMD_AFLD),"999,999.99")
        ? "********************"
        ? "    Conj -> "+transform(nG_CONJ,"999")
        ? "    OEC  -> "+transform(nG_OEC,"999")
        ? "    RTT  -> "+transform(nG_RTT,"999")
        ? "    TEC  -> "+transform(nG_TEC,"999")
        ? "    PTA  -> "+transform(nG_PTA,"999")
        ? "********************"
      endif
return nil

static function GetDates_Pax()
local wDate
   dStartDate:=dEndDate:=CToD("  -  -  ")  ; cPax_Name := space(30)
   Message("Enter transaction dates, press Esc to abort.")
   wDate:=OpenWindow(07,13,12,63,"Date & Passenger Information Box")
   @ 09,15 say " Enter starting date (MM/DD/YY format)" get dStartDate
   @ 10,15 say "         Ending date (MM/DD/YY format)" get dEndDate
   @ 11,15 say "Passenger's Name" get cPax_Name pict "@!"
   SetCursor(SC_NORMAL)
   read
   SetCursor(SC_NONE)
   CloseWindow(wDate)
   cPax_Name:=alltrim(cPax_Name)
return If(LastKey()==K_ESC,.F.,.T.)

// <EOF> - REPORT_A.PRG //