// Filename:      BRS_BANK.PRG
// System-Name:   BRS (Bank Reconciliation Statement);
// Module:        Report Module for Book Totals
// Author:        Rollie Ibarra
// Date-Started:  June 13, 1993
// Last-Update:   June 22, 1993

#include "Mode.ch"
#include "Setcurs.ch"
#include "Inkey.ch"

// list of functions
//  ** function Total_Cash_Receipts()
//  ** function Total_Cash_Disbursed()
//  ** function Total_Interest()
//  ** function Total_Managers_Checks(nIssued, nRedeposit)

function Total_CReceipts()
local nCR:=0
      message("Opening Databases")
      if netuse("CRBTRANS",DB_SHARED,NUM_SECONDS)
         set index to CRBTRANS
      endif
      if netuse("CRB",DB_SHARED,NUM_SECONDS)
         set index to CRB_DATE
      endif
      if CRB->(DBSeek(YrMo(dStartDate)) )
         message("Computing for Cash Receipts")
         do while (CRB->(!Eof())) .and. ;
                  (YrMo(dStartDate)==YrMo(CRB->DATE))
             if (CRB->DATE <= dEndDate) .and. (CRB->DATE >= dStartDate)
                if CRBTRANS->(DBSeek( CRB->(RecNo()) ))
                   do while (CRBTRANS->REC_NO == CRB->(Recno()))
                     if CRBTRANS->ACCT_CODE == cBCode
                        nCR+= CRBTRANS->DEBIT
                     endif
                     CRBTRANS->(DBSkip())
                   enddo
                endif
             endif
             CRB->(DBSkip())
         enddo
      endif
      CRB->(DBCloseArea())
      CRBTRANS->(DBCloseArea())
return nCR

function Total_CDisbursed()
local nCD:=0
      message("Opening Databases")
      if netuse("CDBTRANS",DB_SHARED,NUM_SECONDS)
         set index to CDBTRANS
      endif
      if netuse("CDB",DB_SHARED,NUM_SECONDS)
         set index to CDB_DATE
      endif
      if CDB->(DBSeek(YrMo(dStartDate)) )
         message("Computing for Cash Disbursements")
         do while (CDB->(!Eof())) .and. ;
                  (YrMo(dStartDate)==YrMo(CDB->DATE))
             if (CDB->DATE <= dEndDate) .and. (CDB->DATE >= dStartDate)
                if CDBTRANS->(DBSeek( CDB->(RecNo()) ))
                   do while (CDBTRANS->REC_NO == CDB->(Recno()))
                     if CDBTRANS->ACCT_CODE == cBCode
                        nCD+= CDBTRANS->CREDIT
                     endif
                     CDBTRANS->(DBSkip())
                   enddo
                endif
             endif
             CDB->(DBSkip())
         enddo
      endif
      message("Closing Databases")
      CDB->(DBCloseArea())
      CDBTRANS->(DBCloseArea())
return nCD

function JV_Totals()
local cIncCod:="09-201", cMiscCod:="10-532", cPCIB := "01-111"
      message("Opening Databases")
      if netuse("JVTRANS",DB_SHARED,NUM_SECONDS)
         set index to JVTRANS
      endif
      if netuse("JV",DB_SHARED,NUM_SECONDS)
         set index to JV_DATE
      endif
      message("Computing for Interest Income")
      if JV->(DBSeek(YrMo(dStartDate)) )
         do while (JV->(!Eof())) .and. ;
                  (YrMo(dStartDate)==YrMo(JV->DATE))
             if (JV->DATE <= dEndDate) .and. (JV->DATE >= dStartDate)
                if JVTRANS->(DBSeek( JV->(RecNo()) ))
                   do while (JVTRANS->REC_NO == JV->(Recno()))
                     if JVTRANS->ACCT_CODE == cIncCod
                        nJVInc+= JVTRANS->CREDIT
                     endif
                     if JVTRANS->ACCT_CODE == cMiscCod .and. ;
                        at("(BRS)",JV->DETAILS_1+JV->DETAILS_2+JV->DETAILS_3)!=0
                        nJVMsc+= JVTRANS->DEBIT
                     endif
                     if (JVTRANS->ACCT_CODE == cPCIB)
                        if at("(CRB-)",JV->DETAILS_1+JV->DETAILS_2;
                                      +JV->DETAILS_3)!=0
                            nJVCre += JVTRANS->CREDIT
                        elseif at("(CRB)",JV->DETAILS_1+JV->DETAILS_2;
                                     +JV->DETAILS_3)!=0
                               nJVDeb += JVTRANS->DEBIT
                        elseif at("(MC)",JV->DETAILS_1+JV->DETAILS_2;
                                     +JV->DETAILS_3)!=0
                           nJVIss+= JVTRANS->CREDIT
                           nJVRdp += JVTRANS->DEBIT
                        elseif at("(BRS)",JV->DETAILS_1+JV->DETAILS_2;
                                     +JV->DETAILS_3)=0
                           nJVcan += JVTRANS->DEBIT
                        endif
                     endif
                     JVTRANS->(DBSkip())
                   enddo
                endif
             endif
             JV->(DBSkip())
         enddo
      endif
      message("Closing Databases")
      JV->(DBCloseArea())
      JVTRANS->(DBCloseArea())
return nil

// end-of-file