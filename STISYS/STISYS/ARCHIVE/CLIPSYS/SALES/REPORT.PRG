/*********************************************************/
/* Filename:      REPORT.PRG                             */
/* System-Name:   Purchase Order Filing Program          */
/* Module:        Report Generation                      */
/* Author:        Arnold P. Caoile                       */
/* Date-Started:  February 19, 1992                      */
/* Last-Update:   February 24, 1992/July 19, 1993/Rollie */
/*********************************************************/

#include "Inkey.ch"
#include "MemoEdit.Ch"
#include "Set.ch"
#include "Setcurs.ch"
#include "Printer.ch"
#include "Mode.ch"

static dStartDate,dEndDate,lPrint,nRate
static aAgency, aTotal_PHP, aTotal_USD
static aFare_PHP, aFare_USD, aTax_PHP, aTax_USD
static aOther_PHP, aOther_USD

function Summary()
local n
   if GetDates()
      aFare_PHP:={}; aFare_USD:={} ; aAgency := {}
      Message("Thinking...")
      if netuse("AGENCY",DB_SHARED,NUM_SECONDS)
         set index to AGENCY
      endif
      do while AGENCY->(!Eof())
         AAdd(aAgency,{AGENCY->AGENT_CODE,AGENCY->AGENCY})
         AAdd(aFare_PHP,0)
         AAdd(aFare_USD,0)
         AGENCY->(DbSkip())
      enddo
      aTax_PHP := aClone(aFare_PHP);     aTax_USD := aClone(aFare_USD)
      aOther_PHP := aClone(aFare_PHP);   aOther_USD := aClone(aFare_USD)
      aComm_PHP := aClone(aFare_PHP);    aComm_USD := aClone(aFare_USD)
      aRemit_PHP := aClone(aFare_PHP);   aRemit_USD := aClone(aFare_USD)
      aXmit_PHP := aClone(aFare_PHP);    aXmit_USD := aClone(aFare_USD)
      AGENCY->(DbCloseArea())
      if netuse("PO",DB_SHARED,NUM_SECONDS)
        set index to PO
      endif
      if netuse("PO_EXT",DB_SHARED,NUM_SECONDS)
        set index to PO_EXT
      endif
      PO->(DbEval(,,{|| PO->DATE < dStartDate} ))
      do while PO->(!Eof())
         Message("Reading PO Rec#"+transform(PO->(RecNo()),"99999"))
         if (PO->DATE >= dStartdate) .and. ;
            (PO->DATE <= dEndDate) .and. ;
            (PO->CANCELLED==.F.) .and. ;
            (at("BK#",PO->ROUTE)==0)
            n := AScan(aAgency,{ |x| x[1] == PO->AGENT} )
            if n!=0
                PO_EXT->(DbSeek(PO->PO_NO))
                do while (PO_EXT->PO_NO == PO->PO_NO) .and. PO_EXT->(!Eof())
                   aFare_PHP[n] += PO_EXT->FARE_PHP
                   aFare_USD[n] += PO_EXT->FARE_USD
                   aXmit_PHP[n] += PO_EXT->XMIT_PHP
                   aXmit_USD[n] += PO_EXT->XMIT_USD
                   aTax_PHP[n] += PO_EXT->TAX_PHP
                   aTax_USD[n] += PO_EXT->TAX_USD
                   aOther_PHP[n] += PO_EXT->OTHERS_PHP
                   aOther_USD[n] += PO_EXT->OTHERS_USD
                   aRemit_PHP[n] += PO_EXT->REMIT_PHP
                   aRemit_USD[n] += PO_EXT->REMIT_USD
                   aComm_PHP[n] += PO_EXT->COMM_PHP
                   aComm_USD[n] += PO_EXT->COMM_USD
                   PO_EXT->(DbSkip())
                enddo
            endif
         endif
         PO->(DbSkip())
      enddo
      PO->(DbCloseArea())
      PO_EXT->(DbCloseArea())
      nGrandPHP := nGrandUSD := 0
      Set(_SET_ALTFILE,"SALES.RPT")
      Set(_SET_CONSOLE,.F.)
      Set(_SET_ALTERNATE,.T.)
      ? "þSales Summary Report - P.O."
      ? "Period : " +DateConvert(dStartDate) +" to " +DateConvert(dEndDate)
      ?
      ? space(43) + "+------ Airfare -------+"
      ?? space(3) + "+---- Transmittal -----+"
      ?? space(3) + "+------ Comm -------+"
      ?? space(3) + "+----- Remittance -----+"
      ?? space(3) + "+-------- Tax ---------+"
      ?? space(3) + "+----- Others ------+"
      ?? space(3) + "+------ Totals --------+"
      ? space(11) + "Airline/Agency"
      ?? space(23) + "Peso       Dollar           Peso      Dollar"
      ?? space(09) + "Peso     Dollar           Peso      Dollar"
      ?? space(11) + "Peso      Dollar         Peso     Dollar"
      ?? space(11) + "Peso      Dollar"
      ?
      nRemit_PHP := nRemit_USD := nFare_PHP := nFare_USD := ;
      nTax_PHP   := nTax_USD  := nOther_PHP := nOther_USD := ;
      nXmit_PHP := nXmit_USD := nComm_PHP := nComm_USD := 0
      for n:=1 to Len(aAgency)
         if (aRemit_PHP[n]!=0.00) .or. (aRemit_USD[n]!=0.00) .or. ;
            (aTax_PHP[n]!=0.00) .or. (aTax_USD[n]!=0.00)
               ? aAgency[n][2]
               ?? space(3) + Transform(aFare_PHP[n], "9,999,999.99")
               ?? space(2) + Transform(aFare_USD[n],   "999,999.99")
               ?? space(3) + Transform(aXmit_PHP[n], "9,999,999.99")
               ?? space(2) + Transform(aXmit_USD[n],   "999,999.99")
               ?? space(3) + Transform(aComm_PHP[n],   "999,999.99")
               ?? space(2) + Transform(aComm_USD[n],    "99,999.99")
               ?? space(3) + Transform(aRemit_PHP[n],"9,999,999.99")
               ?? space(2) + Transform(aRemit_USD[n],  "999,999.99")
               ?? space(3) + Transform(aTax_PHP[n],  "9,999,999.99")
               ?? space(2) + Transform(aTax_USD[n],    "999,999.99")
               ?? space(3) + Transform(aOther_PHP[n],  "999,999.99")
               ?? space(2) + Transform(aOther_USD[n],   "99,999.99")

               ?? space(3) + Transform(aRemit_PHP[n] + aTax_PHP[n] +;
                                       aOther_PHP[n],"9,999,999.99")
               ?? space(2) + Transform(aRemit_USD[n] + aTax_USD[n] +;
                                       aOther_USD[n],  "999,999.99")
               nFare_PHP += aFare_PHP[n]
               nFare_USD += aFare_USD[n]
               nXmit_PHP += aXmit_PHP[n]
               nXmit_USD += aXmit_USD[n]
               nTax_PHP += aTax_PHP[n]
               nTax_USD += aTax_USD[n]
               nOther_PHP += aOther_PHP[n]
               nOther_USD += aOther_USD[n]
               nComm_PHP += aComm_PHP[n]
               nComm_USD += aComm_USD[n]
               nRemit_PHP += aRemit_PHP[n]
               nRemit_USD += aRemit_USD[n]
               nGrandPHP += aRemit_PHP[n] + aTax_PHP[n] + aOther_PHP[n]
               nGrandUSD += aRemit_USD[n] + aTax_USD[n] + aOther_USD[n]
          endif
      next
      ?
      ? replicate('-',224)
      ? space(43) + transform(nFare_PHP, "9,999,999.99")
      ?? space(2) + transform(nFare_USD,   "999,999.99")
      ?? space(3) + transform(nXmit_PHP, "9,999,999.99")
      ?? space(2) + transform(nXmit_USD,   "999,999.99")
      ?? space(3) + transform(nComm_PHP,   "999,999.99")
      ?? space(2) + transform(nComm_USD,    "99,999.99")
      ?? space(3) + transform(nRemit_PHP,"9,999,999.99")
      ?? space(2) + transform(nRemit_USD,  "999,999.99")
      ?? space(3) + transform(nTax_PHP,  "9,999,999.99")
      ?? space(2) + transform(nTax_USD,    "999,999.99")
      ?? space(3) + transform(nOther_PHP,  "999,999.99")
      ?? space(2) + transform(nOther_USD,   "99,999.99")
      ?? space(3) + transform(nGrandPHP, "9,999,999.99")
      ?? space(2) + transform(nGrandUSD,   "999,999.99")
      Set(_SET_ALTERNATE,.F.)
      Set(_SET_CONSOLE,.T.)
      Set(_SET_ALTFILE,"")
      If lPrint
         Print_Sum()
      else
         Screen_Sum()
      endif
   endif
return nil

static function Print_Sum()
   if IsPrinter()
       Message("Press any key, when ready.")
       Inkey(0)
       Message("Printing....")
       cReport:=Memoread("SALES.RPT")
       nLines := MlCount(cReport,200)
       Set(_SET_CONSOLE,.F.)
       Set(_SET_PRINTER,.T.)
       SetPrinter(_SET_PITCH,P_10_PITCH)
       SetPrinter(_SET_QUALITY,P_NLQ)
       SetPrinter(_SET_HEIGHT,P_DOUBLE)
       ? "Super Travel, Inc."
       ?
       ? MemoLine(cReport,35,2)
       ?
       ? MemoLine(cReport,35,3)
       ?
       SetPrinter(_SET_HEIGHT,P_NORMAL)
       SetPrinter(_SET_SIZE,P_CONDENSED)
       ?
       ? MemoLine(cReport,230,5)
       ? MemoLine(cReport,230,6)
       ?
       SetPrinter(_SET_QUALITY,P_DRAFT)
       for n := 8 to nLines
           ? MemoLine(cReport,230,n)
       next
       eject
       Set(_SET_PRINTER,.F.)
       Set(_SET_CONSOLE,.T.)
   else
       Message("Printer not ready....")
       Inkey(2)
   endif
return nil

static function Screen_Sum()
local wScreen, cReport
     Message("Reading summary file...")
     wScreen:=OpenWindow(03,05,22,74,"Screen Report")
     cReport:=MemoRead("SALES.RPT")
     Message("Use cursor keys to move, Esc to abort.")
     SetCursor(SC_NORMAL)
     MemoEdit(cReport,04,06,21,73,.F.,"EditorFunc",250)
     SetCursor(SC_NONE)
     CloseWindow(wScreen)
return nil

function Report()
   if NetUse("AGENCY",DB_SHARED,NUM_SECONDS)
      set index to AGENCY
   endif
   mAgent := ""
   GetAgent()
   if AGENCY->(DbSeek(mAgent))
      mAgency:=AGENCY->AGENCY
   endif
   if GetDates2()
   if isprinter()
      Message("Thinking...")
      if Netuse("PO",DB_SHARED,NUM_SECONDS)
         set index to PO
         go top
      endif
      if Netuse("PO_EXT",DB_SHARED,NUM_SECONDS)
         set index to PO_EXT
      endif
      nRemit_PHP := nRemit_USD := nFare_PHP := nFare_USD := ;
      nTax_PHP   := nTax_USD  := nXmit_PHP   := nXmit_USD  := ;
      nOther_PHP := nOther_USD := nComm_Php := nComm_USD := 0
      aAgents = {}
      Set(_SET_CONSOLE,.F.)
      Set(_SET_PRINTER,.T.)
      SetPrinter(_SET_PITCH,P_10_PITCH)
      SetPrinter(_SET_QUALITY,P_NLQ)
      SetPrinter(_SET_HEIGHT,P_DOUBLE)
      ? "Super Travel, Inc."
      ?
      ? "þAgency Remittance"
      ?? space(97) + "Rate: " + transform(nRate,"99.99")
      ?
      ? "Period : " +DateConvert(dStartDate) +" to " +DateConvert(dEndDate)
      ?? space(88) + "Purchase Order"
      ?
      SetPrinter(_SET_HEIGHT,P_NORMAL)
      SetPrinter(_SET_SIZE,P_CONDENSED)
      DetlHead()
      SetPrinter(_SET_QUALITY,P_DRAFT)
      nLcount := 12   ;  nPage := 1
      PO->(DbEval(,,{|| (PO->DATE < dStartDate) } ))
      do while PO->(!Eof())
         Message("Printing PO Rec#"+transform(PO->(RecNo()),"99999") )
         if ( (PO->AGENT==mAgent) .or. empty(mAgent)) .and. ;
            (PO->DATE >= dStartDATE) .and. (PO->DATE <= dEndDATE)
            if nLcount > 61
                eject
                nPage ++
                SetPrinter(_SET_QUALITY,P_NLQ)
                ? "Page #" + transform(nPage,"99")
                DetlHead()
                SetPrinter(_SET_QUALITY,P_DRAFT)
                nLcount := 4
            endif
            ? DateConvert(PO->DATE) + space(2) + PO->PO_NO + space(2)
            AGENCY->(DbSeek(PO->AGENT))
            if "BULK" $ upper(PO->ROUTE)
               ?? AGENCY->AGENT_ABBR
               ?? space(2) + "(BULK TICKETS)"
               PO->(DbSkip())
               nLCount ++
               loop
            endif
            if PO->AGENT == "000"
               ?? space(7) + "(VOID)"
               PO->(DbSkip())
               nLCount ++
               loop
            endif
            ?? AGENCY->AGENT_ABBR
            nDtl := 1
            PO_EXT->(DbSeek(PO->PO_NO))
            do while (PO->PO_NO == PO_EXT->PO_NO) .and. PO_EXT->(!Eof()) .and.;
            !empty(PO_EXT->PAX_NAME)
               if nDtl == 1
                  ?? space(2) + PO_EXT->PAX_NAME
                  ?? space(1) + upper(substr(PO->ROUTE,1,40))
               elseif nDtl == 2
                  ? space(23) + PO_EXT->PAX_NAME
                  if len(alltrim(PO->ROUTE)) > 40
                     ?? space(1) + upper(substr(PO->ROUTE,41,40))
                  else
                     ?? space(41)
                  endif
               else
                  ? space(23) + PO_EXT->PAX_NAME
                  ?? space(41)
               endif
               ?? space(2) + blank_zero(PO_EXT->FARE_PHP,"999,999.99")
               ?? space(1) + blank_zero(PO_EXT->FARE_USD,"99,999.99")
               ?? space(2) + blank_zero(PO_EXT->XMIT_PHP,"999,999.99")
               ?? space(1) + blank_zero(PO_EXT->XMIT_USD,"99,999.99")
               ?? space(2) + blank_zero(PO_EXT->COMM_PHP,"99,999.99")
               ?? space(1) + blank_zero(PO_EXT->COMM_USD,"9,999.99")
               ?? space(2) + blank_zero(PO_EXT->REMIT_PHP,"999,999.99")
               ?? space(1) + blank_zero(PO_EXT->REMIT_USD,"99,999.99")
               ?? space(2) + blank_zero(PO_EXT->TAX_PHP,"999,999.99")
               ?? space(1) + blank_zero(PO_EXT->TAX_USD,"99,999.99")
               ?? space(2) + blank_zero(PO_EXT->OTHERS_PHP,"99,999.99")
               ?? space(1) + blank_zero(PO_EXT->OTHERS_USD,"9,999.99")
               nDtl ++
               if (at("BK#",PO->ROUTE)==0)
                   nFare_PHP += PO_EXT->FARE_PHP
                   nFare_USD += PO_EXT->FARE_USD
                   nXmit_PHP += PO_EXT->XMIT_PHP
                   nXmit_USD += PO_EXT->XMIT_USD
                   nComm_PHP += PO_EXT->COMM_PHP
                   nComm_USD += PO_EXT->COMM_USD
                   nRemit_PHP += PO_EXT->REMIT_PHP
                   nRemit_USD += PO_EXT->REMIT_USD
                   nTax_PHP += PO_EXT->TAX_PHP
                   nTax_USD += PO_EXT->TAX_USD
                   nOther_PHP += PO_EXT->OTHERS_PHP
                   nOther_USD += PO_EXT->OTHERS_USD
                   x:=aScan(aAgents,{|z| z[1]==PO->AGENT})
                   if x==0
                       aAdd(aAgents,{PO->AGENT,0,0,0,0,0,0,0,0,0,0,0,0,0})
                       x := len(aAgents)
                   endif
                   aAgents[x][2]  += PO_EXT->FARE_PHP
                   aAgents[x][3]  += PO_EXT->FARE_USD
                   aAgents[x][4]  += PO_EXT->XMIT_PHP
                   aAgents[x][5]  += PO_EXT->XMIT_USD
                   aAgents[x][6]  += PO_EXT->COMM_PHP
                   aAgents[x][7]  += PO_EXT->COMM_USD
                   aAgents[x][8]  += PO_EXT->REMIT_PHP
                   aAgents[x][9]  += PO_EXT->REMIT_USD
                   aAgents[x][10] += PO_EXT->TAX_PHP
                   aAgents[x][11] += PO_EXT->TAX_USD
                   aAgents[x][12] += PO_EXT->OTHERS_PHP
                   aAgents[x][13] += PO_EXT->OTHERS_USD
                   aAgents[x][14] += 1
                 endif
               PO_EXT->(DbSkip())
               if (PO_EXT->PO_NO != PO->PO_NO) .and. (nDtl==2) .and. ;
                  (len(alltrim(PO->ROUTE)) > 40)
                  ? space(54) + upper(substr(PO->ROUTE,41,40))
                  nLcount ++
               endif
               nLcount ++
            enddo
         endif
         PO->(DbSkip())
      enddo
      ? replicate('-',230)
      ? space(96) + blank_zero(nFare_PHP,"999,999.99")
      ?? space(1) + blank_zero(nFare_USD, "99,999.99")
      ?? space(2) + blank_zero(nXmit_PHP,"999,999.99")
      ?? space(1) + blank_zero(nXmit_USD, "99,999.99")
      ?? space(2) + blank_zero(nComm_PHP, "99,999.99")
      ?? space(1) + blank_zero(nComm_USD,  "9,999.99")
      ?? space(2) + blank_zero(nRemit_PHP,"999,999.99")
      ?? space(1) + blank_zero(nRemit_USD, "99,999.99")
      ?? space(2) + blank_zero(nTax_PHP,"999,999.99")
      ?? space(1) + blank_zero(nTax_USD, "99,999.99")
      ?? space(2) + blank_zero(nOther_PHP,"99,999.99")
      ?? space(1) + blank_zero(nOther_USD, "9,999.99")
      ?
      aSort(aAgents,,,{|x,y| x[1] < y[1]})
      for x:=1 to len(aAgents)
          AGENCY->(DbSeek(aAgents[x][1]))
          ? space(18) + "(" + AGENCY->AGENT_ABBR + ")" + space(3)
          ?? substr(if(AGENCY->(DbSeek(aAgents[x][1])),AGENCY->AGENCY,space(40)),1,30)
          ?? space(03) + transform(aAgents[x][14],"999")
          ?? space(27)
          ?? space(5) + blank_zero(aAgents[x][2],"999,999.99")
          ?? space(1) + blank_zero(aAgents[x][3],"99,999.99")
          ?? space(2) + blank_zero(aAgents[x][4],"999,999.99")
          ?? space(1) + blank_zero(aAgents[x][5],"99,999.99")
          ?? space(2) + blank_zero(aAgents[x][6],"99,999.99")
          ?? space(1) + blank_zero(aAgents[x][7],"9,999.99")
          ?? space(2) + blank_zero(aAgents[x][8],"999,999.99")
          ?? space(1) + blank_zero(aAgents[x][9],"99,999.99")
          ?? space(2) + blank_zero(aAgents[x][10],"999,999.99")
          ?? space(1) + blank_zero(aAgents[x][11],"99,999.99")
          ?? space(2) + blank_zero(aAgents[x][12],"99,999.99")
          ?? space(1) + blank_zero(aAgents[x][13],"9,999.99")
      next
      eject
      Set(_SET_PRINTER,.F.)
      Set(_SET_CONSOLE,.T.)
      PO->(DbCloseArea())
      PO_EXT->(DbCloseArea())
   else
       Message("Printer not ready....")
       Inkey(2)
   endif
   endif
   AGENCY->(DbCloseArea())
return nil

static function DetlHead()
  ? space(94),"+----- Airfare -----+"
  ?? space(1),"+--- Transmittal --+"
  ?? space(1),"+----- Comm -----+"
  ?? space(1),"+--- Remittance ---+"
  ?? space(1),"+------ Tax -------+"
  ?? space(1),"+---- Others ----+"
  ? " Date"
  ?? space(3),"PO No. Agt"
  ?? space(9),"Passenger(s)"
  ?? space(26),"Route"
  ?? space(25),"Peso     Dollar"
  ?? space(7),"Peso    Dollar"
  ?? space(6),"Peso   Dollar"
  ?? space(7),"Peso    Dollar"
  ?? space(7),"Peso    Dollar"
  ?? space(6),"Peso   Dollar"
  ?
return nil

static function GetDates()
local wDates
   dStartDate := dEndDate := ctod("")  ; lPrint:= .F.
   SetCursor(SC_NORMAL)
   Message("Enter transaction dates, press Esc to abort.")
   wDates:=OpenWindow(09,16,14,61,"Date Information Box")
   @ 11,20 say "Enter starting-date (mm-dd-yy)" get dStartDate picture "@!"
   @ 12,20 say "        ending-date (mm-dd-yy)" get dEndDate picture "@!"
   @ 13,20 say "       Send output to printer?" get lPrint picture "Y"
   read
   CloseWindow(wDates)
   SetCursor(SC_NONE)
return If(LastKey()!=K_ESC,.T.,.F.)

static function GetDates2()
local wDates
   dStartDate := dEndDate := ctod("")  ; lPrint:= .F. ;  nRate:= 0
   SetCursor(SC_NORMAL)
   Message("Enter transaction dates, press Esc to abort.")
   wDates:=OpenWindow(09,16,14,61,"Date Information Box")
   @ 11,20 say "Enter starting-date (mm-dd-yy)" get dStartDate picture "@!"
   @ 12,20 say "        ending-date (mm-dd-yy)" get dEndDate picture "@!"
   @ 13,20 say "                          Rate" get nRate pict "99.99"
   read
   CloseWindow(wDates)
   SetCursor(SC_NONE)
return If(LastKey()!=K_ESC,.T.,.F.)

function EditorFunc(nMode,nLine,nCol)
   if nMode==ME_IDLE
      SetCursor(SC_NONE)
      cColor:=SetColor("N/BG")
      @ 03,55 say "Line"+Transform(nLine,"9999")+"  Col"+;
        Transform(nCol+1,"9999")
      SetColor(cColor)
      SetCursor(SC_NORMAL)
   endif
return ME_DEFAULT

static function blank_zero(v,c)
return if(v!=0.00,transform(v,c),space(len(c)))
// end-of-file
