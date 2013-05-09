// Filename:      BRS_BANK.PRG
// System-Name:   BRS (Bank Reconciliation Statement);
// Module:        Report Module for Bank Totals
// Author:        Rollie Ibarra
// Date-Started:  June 18, 1993
// Last-Update:   June 24, 1993

#include "Mode.ch"
#include "Setcurs.ch"
#include "Inkey.ch"

// list of functions
//  ** function Total_Savings()
//  ** function Total_Transit()
//  ** function Total_Outstanding()

function Total_Savings()
local nSav:=0
      message("Opening Databases")
      netuse("SAVINGS",DB_SHARED,NUM_SECONDS)
      message("Totalling Savings Acccount")
      sum SAVINGS->DEPOSIT - SAVINGS->WITHDRAWAL to nSav ;
          for ctod(SAVINGS->DATE)<=ctod(dEndDate)
      message("Closing Databases")
      SAVINGS->(DBCloseArea())
return nSav

function Total_Current()
local nCur:=0
      message("Opening Databases")
      netuse("CURRENT",DB_SHARED,NUM_SECONDS)
      message("Totalling Current Acccount")
      sum CURRENT->DEBIT - CURRENT->CREDIT to nCur ;
          for ctod(CURRENT->DATE)<=ctod(dEndDate)
      message("Closing Databases")
      CURRENT->(DBCloseArea())
return nCur

function Total_Transit()
local nTra:=0
      message("Opening Databases")
      netuse("TRANSIT",DB_SHARED,NUM_SECONDS)
      message("Totalling Deposit in Transit")
      sum TRANSIT->AMOUNT to nTra for (ctod(TRANSIT->DATE) <= ctod(dEndDate));
         .and. (ctod(TRANSIT->DATE) >= ctod(dStartDate))
      message("Closing Databases")
      TRANSIT->(DBCloseArea())
return nTra

function Total_Outstanding()
local nOut:=0
      message("Opening Databases")
      netuse("OUT_TEMP",DB_SHARED,NUM_SECONDS)
      message("Totalling Outstanding Checks")
      sum OUT_TEMP->AMOUNT to nOut
      message("Closing Databases")
      OUT_TEMP->(DBCloseArea())
return nOut

//end-of-file