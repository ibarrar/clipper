// Filename:      BRS_REP.PRG
// System-Name:   BRS (Bank Reconciliation Statement);
// Module:        Report Module 1
// Author:        Rollie Ibarra
// Date-Started:  June 13, 1993
// Last-Update:   June 25, 1993

#include "Mode.ch"
#include "Setcurs.ch"
#include "Inkey.ch"
#include "Printer.Ch"
// list of functions
//  ** function BrsReport()
//  ** static function getDates()
//  ** static function cmpSav_Cur()
//  ** static function cmpCDB_Cur()


function BrsReport()
local nTCur:= nTSav:= nTOut:= nTr:= nCr:= nCd := nBookTA := nBookTL := 0
local wBRS, w1, w2, w3, w4, w5
public nJVIss := nJVRdp := nJVInc:= nJVMsc:= nJVDeb:= nJVCre:= nJVcan:=0

 if getDates()
    if cBank =="CBC"
       Do_CBCReport()
       return nil
    endif
    PopSound()
    w1:=Win_Say(05, 10, {"Checking Databases Accuracy...","Please wait..."})
    cmpMOut_Cur()
    if !cmpSav_Cur()
       cmpCDB_Cur()
       PopSound()
       w2:=Win_Say(07,30,{"Database Accuracy checked...","Preparing Databases...",;
                      "Please wait..."})

       PopSound()
       w3:=Win_Say(09,20,{"Databases prepared...","Preparing Bank Accounts...",;
                      "Please wait..."})
       nTSav:=Total_Savings()
       nTCur:=5000 //Revised 10-01-93 Adv. Feline Montemayor
*      nTCur:=2000
       nTOut:=Total_OutStanding()
       nTr:=Total_Transit()

       PopSound()
       w4:=Win_Say(11,35,{"Bank Accounts prepared...","Preparing Book Accounts...",;
                      "Please wait..."})
       nCr:=Total_CReceipts()
       nCd:=Total_CDisbursed()
       JV_Totals()

       PopSound()
       w5:=Win_Say(13,15,{"Book Accounts prepared...","Preparing Final reports..."})

       if netuse("BALANCE",DB_SHARED,NUM_SECONDS)
          set index to BAL_DATE
       endif
       if BALANCE->(DBSeek(YrMo(dtoc(ctod(dStartDate)-30))))
          if cBank = "PCI"
            nBookBal := BALANCE->PCIB
          else
            nBookBal := BALANCE->CBC
          endif
       endif
       BALANCE->(DBCloseArea())

       Set(_SET_CONSOLE,.F.)
       Set(_SET_ALTFILE,"BRS.RPT")
       Set(_SET_ALTERNATE,.T.)

       ? "Super Travel, Inc."
       ? "Bank Reconciliation Statement - ("+cBank+")"
       ? "For the Month of: "+CMonth(CtoD(dEndDate))+" "+;
          transform(Year(CtoD(dEndDate)),"9999")
       ?
       ? "Book Balance                     "+space(23)+transform(nBookBal,"@( 99,999,999.99")
       ? "Add : Cash Receipts              "+transform(nCr+nJVDeb-nJVCre,"@( 99,999,999.99")
       ? "      Interest Income            "+transform(nJVInc,"@( 99,999,999.99")
       ? "      Redeposit Manager's Checks "+transform(nJVRdp,"@( 99,999,999.99")
       ? "      Cancelled Checks           "+transform(nJVcan,"@( 99,999,999.99")
       nBookTA := nCr + nJVDeb - nJVCre + nJVInc + nJVRdp + nJVcan
       ?? space(10)+transform(nBookTA,"@( 99,999,999.99")
       ? "                                 "+replicate('-',13)+space(10)+replicate('-',13)
       ?
       nBookBal += nBookTA
       ? "Total                            "+space(23)+transform(nBookBal,"@( 99,999,999.99")
       ?
       ? "Less : Cash Disbursements        "+transform(nCd,"@( 99,999,999.99")
       ? "       Manager's Checks          "+transform(nJVIss,"@( 99,999,999.99")
       ? "       Miscellaneous Expenses    "+transform(nJVMsc,"@( 99,999,999.99")
       nBookTL := nCd + nJVIss + nJVMsc
       ?? space(10)+transform(nBookTL,"@( 99,999,999.99")
       ? "                                 "+repl('-',13)+space(10)+repl('-',13)
       ?
       nBookBal -= nBookTL
       ? "Adjusted Book Balance            "+space(23)+transform(nBookBal,"@( 99,999,999.99")
       ?
       ?
       ?
       ?
       ? "Bank Balance   - Savings         "+transform(nTSav,"@( 99,999,999.99")
       ? "                 Current         "+transform(nTCur,"@( 99,999,999.99")
       nBankBal := nTSav + nTCur
       ?? space(10)+transform(nBankBal,"@( 99,999,999.99")
       ? "                                 "+repl('-',13)
       ?
       ? "Add : Deposit in Transit         "+space(23)+transform(nTr,"@( 99,999,999.99")
       ? "                                 "+space(23)+replicate('-',13)
       ?
       nBankBal += nTr
       ? "Total                            "+space(23)+transform(nBankBal,"@( 99,999,999.99")
       ?
       ? "Less: Outstanding Checks         "+space(23)+transform(nTOut,"@( 99,999,999.99")
       ? "                                 "+space(23)+replicate('-',13)
       nBankBal -= nTOut
       ?
       ? "Adjusted Bank Balance            "+space(23)+transform(nBankBal,"@( 99,999,999.99")
       Set(_SET_CONSOLE,.T.)
       Set(_SET_ALTFILE,"")
       Set(_SET_ALTERNATE,.F.)
       close alternate
       cReport :=MemoRead("BRS.RPT")
       CloseWindow(w5)
       unPopSound()
       CloseWindow(w4)
       unPopSound()
       CloseWindow(w3)
       unPopSound()
       CloseWindow(w2)
       unPopSound()
       CloseWindow(w1)
       unPopSound()
       Message("Cursor keys - Navigate, F10 - Print, F2 - Update, ESC - Abort.")
       SetCursor(SC_NORMAL)
       PopSound()
       wBRS := Openwindow(3,1,21,77,"Bank Reconciliation Statement - ("+;
                                    cBank+")")
       MemoEdit(cReport,4,2,20,76,.F.,"EditorFunc",90)
       CloseWindow(wBrs)
       UnPopSound()
       SetCursor(SC_NONE)
    else
       unPopSound()
       CloseWindow(w1)
    endif
 endif
return nil

static function getDates()
local wDate,StartDate:=EndDate:=CToD("  -  -  ")
   cOutput:="N"
   cBank:="   "
   PopSound()
   Message("Enter transaction dates, press Esc to abort.")
   wDate:=OpenWindow(09,15,14,63,"Date Information Box")
   @ 11,17 say "Enter starting date (MM/DD/YY format)" get StartDate
   @ 12,17 say "        Ending date (MM/DD/YY format)" get EndDate
   @ 13,17 say "       Enter Bank Code [ PCI / CBC ] " get cBank pict "@!"
   SetCursor(SC_NORMAL)
   read
   cBank:=substr(cBank,1,3)
   do case
      case cBank = "PCI"
         cBCode = "01-111"
      case cBank = "CBC"
         cBCode = "01-112"
   endcase
   dStartDate:=DToC(StartDate)
   dEndDate:=DToC(EndDate)
   SetCursor(SC_NONE)
   CloseWindow(wDate)
   UnPopSound()
return If(LastKey()==K_ESC,.F.,.T.)

static function cmpMOut_Cur()
      message("Opening Databases")
      if netuse("OUT_TEMP",DB_EXCLUSIVE,NUM_SECONDS)
          Zap
      endif
      OUT_TEMP->(DBCloseArea())
      netuse("OUT_TEMP",DB_SHARED,NUM_SECONDS)
      netuse("OUT_MAST",DB_SHARED,NUM_SECONDS)
      if netuse("CURRENT",DB_SHARED,NUM_SECONDS)
         set index to CUR_CHK
      endif
      Message("Checking OUT_MAST.DBF against CURRENT.DBF.")
      do while OUT_MAST->(!eof()) .AND. CTOD(OUT_MAST->DATE) <= CTOD(dEndDate)
           CURRENT->(DBSeek(OUT_MAST->CHECK_NO))
           if CURRENT->(!Found())
              OUT_TEMP->(AddRec(0))
              replace OUT_TEMP->DATE with OUT_MAST->DATE
              replace OUT_TEMP->CHECK_NO with OUT_MAST->CHECK_NO
              replace OUT_TEMP->PAYEE with OUT_MAST->PAYEE
              replace OUT_TEMP->AMOUNT with OUT_MAST->AMOUNT
              OUT_TEMP->(DBUnlock())
           endif
           OUT_MAST->(DBSkip())
      enddo
      Message("Closing Databases")
      OUT_TEMP->(DBCloseArea())
      OUT_MAST->(DBCloseArea())
      CURRENT->(DBCloseArea())
return nil

static function cmpSav_Cur()
local lFnd, lErr:=.F.
      message("Opening Databases")
      if netuse("SAVINGS",DB_SHARED,NUM_SECONDS)
         set index to SAV_DATE
      endif
      if netuse("CURRENT",DB_SHARED,NUM_SECONDS)
         set index to CUR_DATE
      endif
      if netuse("ERROR",DB_EXCLUSIVE,NUM_SECONDS)
         Zap
      endif
      ERROR->(DBCloseArea())
      netuse("ERROR",DB_SHARED,NUM_SECONDS)
      Message("Checking CURRENT.DBF against SAVINGS.DBF.")
      CURRENT->(DBSeek(YrMo(dStartDate) ) )
      if CURRENT->(Found())
         do while (CURRENT->(!Eof())) .and. ;
                   YrMo(dStartDate) == YrMo(CURRENT->DATE)
             if (CURRENT->DATE <= dEndDate) .and. (CURRENT->DATE >= dStartDate);
                .and. (cBank == substr(CURRENT->CHECK_NO,1,3))
                SAVINGS->(DBSeek( YrMo(CURRENT->DATE) ))
                if SAVINGS->(Found())
                   lFnd:=.F.
                   do while (YrMo(SAVINGS->DATE) == ;
                             YrMo(CURRENT->DATE))  .and.  (!lFnd)
                     if SAVINGS->WITHDRAWAL == CURRENT->DEBIT
                        lFnd:=.T.
                     endif
                     SAVINGS->(DBSkip())
                   enddo  //
                   if (!lFnd)
                     Message("Error(s) found....")
                     ERROR->(AddRec(0))
                     replace ERROR->DATE with CURRENT->DATE
                     replace ERROR->CHECK_NO with CURRENT->CHECK_NO
                     replace ERROR->AMOUNT with CURRENT->DEBIT
                     ERROR->(DBUnlock())
                   endif
                else
                     Message("Error(s) found....")
                     ERROR->(AddRec(0))
                     replace ERROR->DATE with CURRENT->DATE
                     replace ERROR->CHECK_NO with CURRENT->CHECK_NO
                     replace ERROR->AMOUNT with CURRENT->DEBIT
                     ERROR->(DBUnlock())
                endif
             endif
             CURRENT->(DBSkip())
         enddo  //not eof
      endif
      message("Closing Databases")
      SAVINGS->(DBCloseArea())
      CURRENT->(DBCloseArea())
      if ERROR->(RecCount())>0
         ErrorSound()
         Win_Ok({"Error(s) found while checking ",;
                 "CURRENT.DBF with SAVINGS.DBF"})
         ERROR->(DBbrowse(04,05,20,74,"ERROR.DBF",.F.))
         lErr:=.T.
      endif
      ERROR->(DBCloseArea())
return lErr

static function cmpCDB_Cur()
local lFnd
      message("Opening Databases")
      if netuse("CDB",DB_SHARED,NUM_SECONDS)
         set index to CDB_DATE
      endif
      if netuse("CDBTRANS",DB_SHARED,NUM_SECONDS)
         set index to CDBTRANS
      endif
      if netuse("CURRENT",DB_SHARED,NUM_SECONDS)
         set index to CUR_CHK
      endif
      netuse("OUT_TEMP",DB_SHARED,NUM_SECONDS)
      Message("Checking CDB.DBF against CURRENT.DBF.")
      CDB->(DBSeek(YrMo(dStartDate) ) )
      if CDB->(Found())
             do while (CDB->(!Eof())) .and. ;
             YrMo(dStartDate) == YrMo(CDB->DATE)
                   if (cBank == substr(CDB->CHECK_NO,1,3)) .and. ;
                       !("(CXLD)" $ CDB->DETAILS_1+CDB->DETAILS_2)
                       CURRENT->(DBSeek( CDB->CHECK_NO ))
                       if CURRENT->(!Found())
                          OUT_TEMP->(AddRec(0))
                          replace OUT_TEMP->DATE with CDB->DATE
                          replace OUT_TEMP->CHECK_NO with CDB->CHECK_NO
                          replace OUT_TEMP->PAYEE with CDB->PAYEE
                          CDBTRANS->(DBseek(CDB->(Recno()) ))
                          if CDBTRANS->(Found())
                             do while CDBTRANS->ACCT_CODE != "01-111"  
                               CDBTRANS->(Dbskip())
                             enddo
                             if (CDBTRANS->REC_NO==CDB->(RecNo()) ) .and. ;
                                (CDBTRANS->ACCT_CODE=="01-111")
                                replace OUT_TEMP->AMOUNT with CDBTRANS->CREDIT 
                             endif
                          endif
                          OUT_TEMP->(DBUnlock())
                       endif
                   endif
                   CDB->(DBSkip())
             enddo
      endif
      message("Closing Databases")
      CURRENT->(DBCloseArea())
      CDB->(DBCloseArea())
      CDBTRANS->(DBCloseArea())
      PopSound()
      if Win_YesNO({"Would you like to browse on the","Outstanding checks?"})
          OUT_TEMP->(DBbrowse(04,05,20,74,"Outstanding Checks",.F.))
      endif
      unPopSound()
      OUT_TEMP->(DBCloseArea())
return nil

function YrMo(cDate)
return substr(cDate,7,2)+"-"+substr(cDate,1,2)

static function Do_CBCReport()
      Print_Header()
      Set(_SET_CONSOLE,.F.)
      Set(_SET_PRINTER,.T.)
      setprinter(_SET_QUALITY,P_NLQ)
      setprinter(_SET_HEIGHT,P_DOUBLE)
      ? "Bank Reconciliation Statement - (CBC )"
      ?
      ? "For the Month of: "+CMonth(CtoD(dEndDate))+" "+;
          transform(Year(CtoD(dEndDate)),"9999")
      ?
      setprinter(_SET_HEIGHT,P_NORMAL)
      ? "       Book Balance                                       3,515.61"
      ?
      ? "       Less : Cash Disbursements                              0.00"
      ? "                                                      ------------"
      ? "                                                          3,515.61"
      ?
      ?
      ?
      ? "       Bank Balance                                       3,515.61"
      ?
      ? "       Less : Outstanding Checks                              0.00"
      ? "                                                      ------------"
      ? "                                                          3,515.61"
      eject
      Set(_SET_CONSOLE,.T.)
      Set(_SET_PRINTER,.F.)
return nil

// end-of-file
