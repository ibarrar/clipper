/*
ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
บ  System          :  PowerPOS for Specialty Shop                         บ
บ  Program I.D.    :  D_PAYAMT.PRG                                        บ
บ  Description     :  Display Subtotal and Balance Due at                 บ
บ                     Receipt Image                                       บ
บ  Author          :  jay ocampo                                          บ
บ  Date Started    :  November 1994                                       บ
บ  Last Revision   :                                                      บ
บ  Remarks         :                                                      บ
ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
*/

#include "GRFX_ALL.CH"
#include "nvr_file.ch"

static cash_prtl := 0
static misc_prtl := 0
static bank_prtl := 0
static total_due := 0

function getCashPrtl(nVal)
  if valtype(nVal) == "N"
   if nVal != 0
      cash_prtl += nVal
   else
      cash_prtl := nVal   
   endif   
  endif
return cash_prtl     

function getBankPrtl(nVal)
  if valtype(nVal) == "N"
    if nVal != 0
      bank_prtl += nVal
    else
      bank_prtl := nVal  
    endif 
  endif
return bank_prtl     

function getMiscPrtl(nVal)
  if valtype(nVal) == "N"
    if nVal != 0
       misc_prtl += nVal
    else
       misc_prtl := nVal
    endif      
  endif
return misc_prtl     

function getTotalBal(nVal)
  if valtype(nVal) == "N"
    if nVal != 0
       total_due += nVal
    else
       total_due := nVal   
    endif    
  endif   
return total_due  

/*---------------------------------------------------------------------------*/


FUNCTION Disp_PayAmt(cpay_desc, ntotal_amt, npay_amt, nbal_due, cmisc1, cmisc2, ;
                     cmisc3)

/*  Usage : Display Subtotal and Balance Due
    Descr : Receipt Image Subtotal Region and Running Total Region are
            updated
    Parm  :

            cpay_desc   ->  payment mode description
            ntotal_amt  ->  subtotal amount; this must be passed by reference
            npay_amt    ->  Payment amount
            nbal_due    ->  balance due/change
            cmisc1      ->  miscellaneous payment information 1
            cmisc2      ->  miscellaneous payment information 2
    Return: NIL
*/

  LOCAL cOutText := ""                      // print buffer
  LOCAL nRowCtr := 57                       // Display Row Counter
  LOCAL point   := ""
  LOCAL init_pymt := 0
  LOCAL row_disp := 7

  if cash_prtl != 0 .and. bank_prtl != 0
     nRowCtr := 54
     row_disp := 5 
  elseif bank_prtl != 0
     nRowCtr := 55
     row_disp := 7
  elseif cash_prtl != 0 
     nRowCtr := 56
     row_disp := 7
  endif         

  // Move up receipt rows if necessary
  Disp_PayRcpt(row_disp )

  // Clear Payment region
  gClearTo( 4, 53, 96, 74, 7)

  gDrawText(nRowCtr, 5, "TOTAL ", ;
           TRIPLEX_FONT, 3, 0, MSCALE, LEFT_TEXT)
      gDrawText(nRowCtr, 95, TRANSFORM( ntotal_amt, "99,999,999.99") ,;
               TRIPLEX_FONT, 3, 0, MSCALE, RIGHT_TEXT)
  nRowCtr += 4
  

  IF ( LEN(cpay_desc) < 9 )
     gDrawText(nRowCtr, 5, cpay_desc, ;
               TRIPLEX_FONT, 3, 0, MSCALE, LEFT_TEXT)
     gDrawText(nRowCtr, 95, TRANSFORM( npay_amt, "99,999,999.99") ,;
              TRIPLEX_FONT, 3, 0, MSCALE, RIGHT_TEXT)
  ELSE
     gDrawText(nRowCtr, 5, cpay_desc, ;
               TRIPLEX_FONT, 3, 0, MSCALE, LEFT_TEXT)
     gDrawText(nRowCtr, 95, TRANSFORM( npay_amt, "9,999,999.99") ,;
               TRIPLEX_FONT, 3, 0, MSCALE, RIGHT_TEXT)
  ENDIF

  nRowCtr += 4

  IF ( nbal_due > 0 )
     nRowCtr += 1
     gDrawText(nRowCtr, 5, "BAL. DUE ", ;
               TRIPLEX_FONT, 3, 0, MSCALE, LEFT_TEXT)
     gDrawText(nRowCtr, 95, TRANSFORM( nbal_due, "9,999,999.99") ,;
               TRIPLEX_FONT, 3, 0, MSCALE, RIGHT_TEXT)
  ELSE
     gDrawText(nRowCtr, 5, "CHANGE" , ;
               TRIPLEX_FONT, 3, 0, MSCALE, LEFT_TEXT)
     gDrawText(nRowCtr, 95, TRANSFORM( ABS(nbal_due), "99,999,999.99") ,;
               TRIPLEX_FONT, 3, 0, MSCALE, RIGHT_TEXT)
  ENDIF
  nRowCtr += 4

RETURN NIL

/*---------------------------------------------------------------------------*/

