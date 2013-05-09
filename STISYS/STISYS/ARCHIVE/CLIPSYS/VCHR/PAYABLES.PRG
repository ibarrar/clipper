// Filename:      PAYABLES.PRG
// Author:        Rollie C. Ibarra Jr.
// Date-Started:  December 28, 1993
// Last-Update:   December 28, 1993

#include "Inkey.ch"
#include "Setcurs.ch"
#include "Achoice.ch"
#include "Mode.Ch"
#include "Printer.Ch"

static mAgency, nTotalAmt

function TourPay()
   if GetInfo()
      if IsPrinter()
          if netuse("LAND",DB_SHARED,NUM_SECONDS)
             set index to LAND
          endif
          if NetUse("PAX",DB_SHARED,NUM_SECONDS)
             set index to PAX
          endif
          if NetUse("VOUCHER",DB_SHARED,NUM_SECONDS)
             set index to VOUCHER
          endif
          Set(_SET_ALTFILE,"PAYABLES.RPT")
          Set(_SET_CONSOLE,.F.)
          Set(_SET_ALTERNATE,.T.)
          ?? "Super Travel, Inc."
          ? "þ Tour Voucher Payables" + if(!empty(mAgency),"  ("+mAgency+")","")
          ? "Period :", dtoe(dStartDate),"to",dtoe(dEndDate)
          ?
          ?  "     Voucher#  Htl    Date      Dur                "
          ?? "Passenger(s)                      Adult     Child      Total"
          ?
          nTotalAmt:=0
          do while VOUCHER->(!Eof())
            if ((VOUCHER->AGENCY==mAgency) .or. empty(mAgency)) .and. ;
               (VOUCHER->HOTEL_FROM >= dStartDate) .and. ;
               (VOUCHER->HOTEL_FROM <= dEndDate) .and. ;
               !VOUCHER->CANCELLED .and. VOUCHER->BILLED
                Message("Reading Voucher Rec #"+;
                     transform(VOUCHER->(RecNo()),"9999") )
               lFound:=.F.
               LAND->(DbGotop())
               do while LAND->(!Eof()) .and. !lFound
                  if (LAND->EFF_TO >= VOUCHER->HOTEL_FROM) .and. ;
                        (LAND->EFF_FROM <= VOUCHER->HOTEL_FROM) .and. ;
                        (LAND->EFF_TILL >= VOUCHER->DAY_ISSUED) .and. ;
                        (LAND->AGENCY == VOUCHER->AGENCY) .and. ;
                        (LAND->HOTEL == VOUCHER->HOTEL)
                        lFound:=.T.
                        ProcessVoucher()
                  endif
                  LAND->(DbSkip())
               enddo
            endif
            VOUCHER->(DbSkip())
         enddo
         ? repl('-',114)
         ? "Totals ------->",space(87),transform(nTotalAmt,"999999.99")
         Set(_SET_ALTERNATE,.F.)
         Set(_SET_CONSOLE,.T.)
         Set(_SET_ALTFILE,"")
         PAX->(DbCloseArea())
         VOUCHER->(DbCloseArea())
         LAND->(DbCloseArea())
         Message("Insert 80 column paper and presss any key...")
         inkey(0)
         Message("Printing...")
         cReport:=MemoRead("PAYABLES.RPT")
         nLines:=MLCount(cReport,225)
         Set(_SET_CONSOLE,.F.)
         Set(_SET_PRINTER,.T.)
         ?? chr(27) + chr(80) + chr(18)
         SetPrinter(_SET_HEIGHT,P_DOUBLE)
         SetPrinter(_SET_EMPHASIZED,.T.)
         SetPrinter(_SET_QUALITY,P_NLQ)
         ?? MemoLine(cReport,70,1)
         ?
         ?  MemoLine(cReport,70,2)
         ?
         ?  MemoLine(cReport,70,3)
         SetPrinter(_SET_HEIGHT,P_NORMAL)
         SetPrinter(_SET_SIZE,P_CONDENSED)
         Set(_SET_MARGIN,10)
         ?
         ? "Page : 1"
         Head1 := MemoLine(cReport,120,5)
         Head2 := MemoLine(cReport,120,6)
         ?  Head1  ;  ? Head2
         SetPrinter(_SET_QUALITY,P_DRAFT)
         SetPrinter(_SET_EMPHASIZED,.F.)
         nLCount:=7  ; nPage := 1
         for x:=7 to nLines
             ? MemoLine(cReport,120,x)
             nLCount ++
             if nLCount > 57
                eject
                nPage ++
                SetPrinter(_SET_EMPHASIZED,.T.)
                SetPrinter(_SET_QUALITY,P_NLQ)
                ? "Page :"+transform(nPage,"99")
                ?  Head1  ;  ? Head2
                SetPrinter(_SET_QUALITY,P_DRAFT)
                SetPrinter(_SET_EMPHASIZED,.F.)
                nLcount := 3
             endif
         next
         eject
         Set(_SET_MARGIN,0)
         Set(_SET_PRINTER,.F.)
         Set(_SET_CONSOLE,.T.)
         Message("Printing Done...")
         Tone(300,1)
         Inkey(2)
      else
         Message("Printer Not Ready...")
         Tone(100,3)
         Inkey(2)
      endif
   endif
return nil

static function ProcessVoucher()
local  nAmtADT := nAmtCHD := 0
   if VOUCHER->TWN_BED1 > 0 ; nAmtADT += GetAdtCost(1) * VOUCHER->TWN_BED1 ; endif
   if VOUCHER->SGL_BED1 > 0 ; nAmtADT += GetAdtCost(2) * VOUCHER->SGL_BED1 ; endif
   if VOUCHER->XTR_BED1 > 0 ; nAmtADT += GetAdtCost(3) * VOUCHER->XTR_BED1 ; endif
   if VOUCHER->TWN_BED2 > 0 ; nAmtCHD += GetAdtCost(1) * VOUCHER->TWN_BED2 ; endif
   if VOUCHER->SGL_BED2 > 0 ; nAmtCHD += GetAdtCost(2) * VOUCHER->SGL_BED2 ; endif
   if VOUCHER->XTR_BED2 > 0 ; nAmtCHD += GetAdtCost(3) * VOUCHER->XTR_BED2 ; endif
   nTotalAmt += nAmtADT + nAmtCHD
   PAX->(DbSeek( VOUCHER->VOUCHER_NO ))
   ? space(4),VOUCHER->VOUCHER_NO," ",VOUCHER->HOTEL,"  "
   ?? dtoe(VOUCHER->HOTEL_FROM),"  ",VOUCHER->DURATION," ",PAX->NAME,"  "
   ?? transform(nAmtADT,"9999.99")," ",transform(nAmtCHD,"9999.99"),"  "
   ?? transform(nAmtADT+nAmtCHD,"99999.99")
   PAX->(DbSkip())
   do while PAX->(!Eof()) .and. (VOUCHER->VOUCHER_NO == PAX->VOUCHER_NO)
      ? space(41),PAX->NAME
      PAX->(DbSkip())
   enddo
return nil

static function GetADTCost(nMode)
local nAmt := 0
   if "4D3N" $ VOUCHER->DURATION
       do case
           case nMode==1 ; nAmt :=LAND->HTWN_4D3NA
           case nMode==2 ; nAmt :=LAND->SGLB_4D3NA
           case nMode==3 ; nAmt :=LAND->XTRB_4D3NA
       endcase
       if !VOUCHER->ABF        ; nAmt -= LAND->HOTEL_ABF * 3 ; endif
       if !VOUCHER->TOUR       ; nAmt -= LAND->TOUR          ; endif
       if !VOUCHER->RTTRANSFER ; nAmt -= LAND->OW_TRSF * 2   ; endif
       IF !VOUCHER->OWTRANSFER ; nAmt -= LAND->OW_TRSF       ; endif
   elseif "3D2N" $ VOUCHER->DURATION
       do case
           case nMode==1 ; nAmt :=LAND->HTWN_3D2N
           case nMode==2 ; nAmt :=LAND->SGLB_3D2N
           case nMode==3 ; nAmt :=LAND->XTRB_3D2N
       endcase
       if !VOUCHER->ABF        ; nAmt -= LAND->HOTEL_ABF * 2 ; endif
       if !VOUCHER->TOUR       ; nAmt -= LAND->TOUR          ; endif
       if !VOUCHER->RTTRANSFER ; nAmt -= LAND->OW_TRSF * 2   ; endif
       IF !VOUCHER->OWTRANSFER ; nAmt -= LAND->OW_TRSF       ; endif
   else
       nNights := val( substr(VOUCHER->DURATION,3,1) )
       do case
           case nMode==1 ; nAmt :=LAND->HTWN_4D3NA + (LAND->XN_HTWN * (nNights-3))
           case nMode==2 ; nAmt :=LAND->SGLB_4D3NA + (LAND->XN_SGLB * (nNights-3))
           case nMode==3 ; nAmt :=LAND->XTRB_4D3NA + (LAND->XN_XTRB * (nNights-3))
       endcase
       if !VOUCHER->ABF        ; nAmt -= LAND->HOTEL_ABF * nNights ; endif
       if !VOUCHER->TOUR       ; nAmt -= LAND->TOUR                ; endif
       if !VOUCHER->RTTRANSFER ; nAmt -= LAND->OW_TRSF * 2         ; endif
       IF !VOUCHER->OWTRANSFER ; nAmt -= LAND->OW_TRSF             ; endif
   endif
return nAmt

static function GetCHDCost(nMode)
local nAmt := 0
   if "4D3N" $ VOUCHER->DURATION
       do case
           case nMode==1 ; nAmt :=LAND->HTWN_4D3NC
           case nMode==2 ; nAmt :=LAND->XTRB_4D3NC
           case nMode==3 ; nAmt :=LAND->NOB_4D3NC
       endcase
       if !VOUCHER->ABF        ; nAmt -= LAND->HOTEL_ABF * 3 ; endif
       if !VOUCHER->TOUR       ; nAmt -= LAND->TOUR          ; endif
       if !VOUCHER->RTTRANSFER ; nAmt -= LAND->OW_TRSF * 2   ; endif
       IF !VOUCHER->OWTRANSFER ; nAmt -= LAND->OW_TRSF       ; endif
   elseif "3D2N" $ VOUCHER->DURATION
       do case
           case nMode==1 ; nAmt :=LAND->HTWN_4D3NC - LAND->XN_HTWN
           case nMode==2 ; nAmt :=LAND->XTRB_4D3NC - LAND->XN_XTRB
           case nMode==3 ; nAmt :=LAND->NOB_4D3NC
       endcase
       if !VOUCHER->ABF        ; nAmt -= LAND->HOTEL_ABF * 2 ; endif
       if !VOUCHER->TOUR       ; nAmt -= LAND->TOUR          ; endif
       if !VOUCHER->RTTRANSFER ; nAmt -= LAND->OW_TRSF * 2   ; endif
       IF !VOUCHER->OWTRANSFER ; nAmt -= LAND->OW_TRSF       ; endif
   else
       nNights := val( substr(VOUCHER->DURATION,3,1) )
       do case
           case nMode==1 ; nAmt :=LAND->HTWN_4D3NC + (LAND->XN_HTWN * (nNights-3))
           case nMode==2 ; nAmt :=LAND->XTRB_4D3NC + (LAND->XN_XTRB * (nNights-3))
           case nMode==3 ; nAmt :=LAND->NOB_4D3NA
       endcase
       if !VOUCHER->ABF        ; nAmt -= LAND->HOTEL_ABF * nNights ; endif
       if !VOUCHER->TOUR       ; nAmt -= LAND->TOUR                ; endif
       if !VOUCHER->RTTRANSFER ; nAmt -= LAND->OW_TRSF * 2         ; endif
       IF !VOUCHER->OWTRANSFER ; nAmt -= LAND->OW_TRSF             ; endif
   endif
return Amt

static function GetInfo()
local wDates
   dStartDate1:=dEndDate:=ctod("") ; mAgency:=Space(3)
   SetCursor(SC_NORMAL)
   Message("Enter transaction dates press Esc to abort.")
   wDates:=OpenWindow(08,14,13,64,"Print Accounts Payable")
   @ 10,19 say "Enter starting date (mm-dd-yy)" get dStartDate picture "@!"
   @ 11,19 say "        ending date (mm-dd-yy)" get dEndDate picture "@!"
   @ 12,19 say "      Travel Agency code (xxx)" get mAgency picture "@!"
   set key K_ALT_A to GetAgent()
   read
   set Key K_ALT_A to
   CloseWindow(wDates)
   SetCursor(SC_NONE)
   Message("")
return if(LastKey()==K_ESC,.F.,.T.)

// end-of-file