// Filename:      BRS_OCH.PRG
// System-Name:   BRS (Bank Reconciliation Statement);
// Module:        Outstanding Check Report Generator
// Author:        Rollie Ibarra
// Date-Started:  June 13, 1993
// Last-Update:   June 10, 1993

#include "Mode.ch"
#include "Setcurs.ch"
#include "Inkey.ch"
#include "Printer.ch"

function Checks_Sched()
local nGTotal := nLastVal := nTotal := 0, cLastDate := space(8), wCS
local cChecks, nKey:= nLines:= nLineCre:=0, cLine, isReady, nPgNo:=1;

   Message("Enter the bank code for checks to be generated...")
   PopSound()
   wCS := openwindow(08,20,12,55,"Outstanding Checks")
   setcursor(SC_NORMAL)
   @ 10, 23 say "Enter Bank code [PCI/CBC] " get cBank pict "@!"
   read
   setcursor(SC_NONE)
   CloseWindow(wCS)
   unPopSound()
   Message("Preparing Outstanding checks report...")
   if cBank == "CBC"
      Do_CBCSched()
      return nil
   endif
   set(_SET_CONSOLE,.F.)
   set(_SET_ALTFILE,"CHECKS.RPT")
   set(_SET_ALTERNATE,.T.)
   if netuse("OUT_MAST",DB_SHARED,NUM_SECONDS)
        index on ctod(date) to OUT_DATE
   endif
   cLastDate := YrMo(OUT_MAST->DATE)
   do while OUT_MAST->(!EOF())
        if (YrMo(OUT_MAST->DATE) <> cLastDate) .and.;
        substr(OUT_MAST->CHECK_NO,1,3) = cBank
           ? space(96)+ "------------"
           ? space(96) + transform(nTotal,"@( 9,999,999.99")
           nGtotal += nTotal
           nTotal := 0
           ?
           ?
           cLastDate := YrMo(OUT_MAST->DATE)
        endif
        if substr(OUT_MAST->CHECK_NO,1,3) = cBank
           ? space(20) + OUT_MAST->DATE + space(5) + OUT_MAST->PAYEE +;
               space(2) + OUT_MAST->CHECK_NO + space(10) + ;
               transform(OUT_MAST->AMOUNT,"@ 9,999,999.99")
           nLastValue := OUT_MAST->AMOUNT
           nTotal += OUT_MAST->AMOUNT
        endif
        OUT_MAST->(DBSkip())
   enddo
   OUT_MAST->(DBCloseArea())
   ? space(96) + "------------"
   ? space(96) + transform(nTotal,"@( 9,999,999.99")
   ?
   ?
   nGtotal += nTotal
   ? space(96) + "============="
   ?
   ? space(70) + "Outstanding checks total  " + transform(nGtotal,"@( 9,999,999.99")
   set(_SET_ALTERNATE,.F.)
   set(_SET_ALTFILE,"")
   set(_SET_CONSOLE,.T.)
   cChecks := MemoRead("CHECKS.RPT")
*  isReady:=.F.
   isReady:=IsPrinter()
   nCurrLine:= 0
   do while (nKey!=K_ESC) .and. (!isReady)
       Message("Printer not ready....")
       ErrorSound()
       Inkey(2)
       Message("Press any key to retry, Esc to abort....")
       nKey:=Inkey(0)
       isReady:=IsPrinter()
   enddo
       if isReady
            Message("Insert 80 column form then press "+;
            "ENTER to print.")
            nKey:=0
         
            do while nKey!=K_ENTER ; nKey:=Inkey(0) ; enddo
            nLineCtr:=0
            Message("Printing....please wait!")
            Print_Header()
            Set(_SET_CONSOLE,.F.)
            Set(_SET_PRINTER,.T.)
            setprinter(_SET_QUALITY,P_NLQ)
            setprinter(_SET_HEIGHT,P_DOUBLE)
            ? "Schedule of Outstanding Checks (", cBank, ")"
            setprinter(_SET_HEIGHT,P_NORMAL)
            setprinter(_SET_SIZE,P_CONDENSED)
            ? "Page No.", transform(nPgno,"999")
            ? "------------"
            ? MARGIN, space(20) + "Date    " + space(5) + "     PAYEE" +;
               space(32) + "Check No." + space(12) + "Amount"
            setprinter(_SET_QUALITY,P_DRAFT)
            ?
            nLines:=MLCount(cChecks,130)
            for nCurrLine:=1 to nLines+2
                 cLine:=MemoLine(cChecks,130,nCurrLine)
                 if nLineCtr>44
                     eject
                     nLineCtr:=0
                     nPgno ++
                     setprinter(_SET_QUALITY,P_NLQ)
                     ? "Page No.", transform(nPgno,"999")
                     ? "------------"
                     ? MARGIN, space(20) + "Date    " + space(5) + "     PAYEE" +;
                       space(32) + "Check No." + space(12) + "Amount"
                     setprinter(_SET_QUALITY,P_DRAFT)
                     ?
                 endif
                 ? MARGIN,cLine
                 nLineCtr++
            next
            eject
            Set(_SET_CONSOLE,.T.)
            Set(_SET_PRINTER,.F.)
            Set(_SET_ALTFILE,"")
            Set(_SET_ALTERNATE,.F.)
            close alternate
            PopSound()
            Win_Ok({"Outstanding Check Report done..."})
            unPopSound()
       else
            Message("Printing Aborted...")
            inkey(2)
       endif
return nil

static function Do_CBCSched()
      Print_Header()
      Set(_SET_CONSOLE,.F.)
      Set(_SET_PRINTER,.T.)
      setprinter(_SET_QUALITY,P_NLQ)
      setprinter(_SET_HEIGHT,P_DOUBLE)
      ? "Schedule of Outstanding Checks ( CBC )"
      setprinter(_SET_HEIGHT,P_NORMAL)
      setprinter(_SET_SIZE,P_CONDENSED)
      ? "Page No.   1"
      ? "------------"
      ? space(27) + "Date    " + space(5) + "     PAYEE" +;
      space(32) + "Check No." + space(12) + "Amount"
      setprinter(_SET_QUALITY,P_DRAFT)
      ?
      ?
      ?
      ? space(27) + "        " + space(5) + "          " +;
      space(32) + "         " + space(6) + REPL('-',12)
      ? space(27) + "        " + space(5) + "          " +;
      space(21) + "Outstanding checks total  "+"        0.00"
      eject
      Set(_SET_CONSOLE,.T.)
      Set(_SET_PRINTER,.F.)
return nil

// end-of-file
