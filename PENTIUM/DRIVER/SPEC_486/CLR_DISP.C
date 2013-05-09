/****************************************************************************
  CLR_DISP.C

  Syntax:

    CLEAR_DISP( <cashr>, <cust1>, <cust2>, <cashr_row>, <cust1_row>, <cust2_row> )

  Parameters:

    <cashr>
    <cust1>
    <cust2> -  numeric flags indicating the desired display. A non-zero
               value enables the desired display for this function, 
               otherwise a value of zero (0) disables it. These flags
               can contain the status of the corresponding display, if
               passed by reference (@). In this case, see header file - 
               PFL_CLIP.CH for the statuses.
             
               <cust1> corresponds to the integrated customer display, while
               <cust2> corresponds to the additional (or supplementary) customer
               display.

    <cashr_row> - a numeric value that specifies the line number on the
                  cashier display to be cleared. A value of zero (0) clears
                  the entire screen display. Values must be between 0-4.

    <cust1_row> - a numeric value that specifies the line number on the inte-
                  grated customer display to be cleared. A value of zero (0) 
                  clears the entire screen display. Values must be between 0-1.

    <cust2_row> - a numeric value that specifies the line number on the addi-
                  tional customer display to be cleared. A value of zero (0) 
                  clears the entire screen display. Values must be between 0-2.

  Description:

    CLEAR_DISP() clears a line or clears the entire screen of the correspon-
    ding display.

    Clearing the entire screen will set the cursor to the first column of the
    first row of the display. While clearing a line, positions the cursor to 
    the leftmost column of that line.

    The possible values for line numbers depend on the type of display used.
    
  Return values:
    
    Returns INVP, when an invalid argument is passed, otherwise it returns
    NORMAL.
    
  Note:
  This function acts as an interface between the Clipper application and the
  PCR device drivers. This function is callable from Clipper using the
  Extend System.
  
  For more information about the PCR device drivers see the POS 3000
  Technical Reference manual.
          
  rnr  5-5-95
*****************************************************************************/
#include <stdio.h>
#include "extend.h"
#include "pcr_ext.h"
#include "pfl_clip.ch"

/* parameter constants */
enum arguments {CASHR=1, CUST1, CUST2, CASHR_ROW, CUST1_ROW, CUST2_ROW};

/* External definitions */
extern POS_TABLE pos_setup[];

/* Local functions */
static int req_cmd(int device_no, int row);

CLIPPER clear_disp(void)
{
  int cashr_status;  /* holds the cashier display status */
  int cust1_status;  /* holds the integrated customer display status */
  int cust2_status;  /* holds the additional customer display status */
  unsigned char display_type;  /* bit assignments for display type */
  int cashr_line;  /* cashier display line number */
  int cust1_line;  /* integrated customer display line number */
  int cust2_line;  /* additional customer display line number */

  cashr_status = cust1_status = cust2_status = NORMAL;  /* initial status */
  
  /* validate parameters */
  if (PCOUNT == 6 && ISNUM(CASHR) && ISNUM(CUST1) && ISNUM(CUST2) &&
                     ISNUM(CASHR_ROW) && ISNUM(CUST1_ROW) && ISNUM(CUST2_ROW))
  {
    /* determine display type */
    display_type = 0x00;
    if (_parni(CASHR))
      display_type |= 0x01;  /* cashier display */

    if (_parni(CUST1))
      display_type |= 0x02;  /* integrated customer display */

    if (_parni(CUST2))
      display_type |= 0x04;  /* additional customer display */

    if (display_type == 0)  /* no selected display */
    {
      _retni(NORMAL);
      return;
    }
    
    cashr_line = _parni(CASHR_ROW);  /* get cashier line # */
    cust1_line = _parni(CUST1_ROW);  /* get integrated customer line # */
    cust2_line = _parni(CUST2_ROW);  /* get additional customer line # */
    
    /* validate line numbers passed */
    if ((display_type & 0x01) && NOT_IN_RANGE(cashr_line, 0, 4))
    {
      _retni(INVP);
      return;
    }

    if ((display_type & 0x02) && NOT_IN_RANGE(cust1_line, 0, 1))
    {
      _retni(INVP);
      return;
    }

    if ((display_type & 0x04) && NOT_IN_RANGE(cust2_line, 0, 2))
    {
      _retni(INVP);
      return;
    }

    if (display_type & 0x01)  /* cashier display */
      cashr_status = req_cmd(POS_CASH_DISP, cashr_line);

    if (display_type & 0x02)  /* integrated customer display */
      cust1_status = req_cmd(POS_CUST_DISP1, cust1_line);

    if (display_type & 0x04)  /* additional customer display */
      cust2_status = req_cmd(POS_CUST_DISP2, cust2_line);

    if (ISBYREF(CASHR))  /* passed by reference */
      _storni(cashr_status, CASHR);  /* return status result */  

    if (ISBYREF(CUST1))  /* passed by reference */
      _storni(cust1_status, CUST1);  /* return status result */      

    if (ISBYREF(CUST2))  /* passed by reference */
      _storni(cust2_status, CUST2);  /* return status result */      

    _retni(NORMAL);      
  }
  else
    _retni(INVP);
}

static int req_cmd(int device_no, int row)
{
  int status;

  if (chk_init_flag(device_no) == 0)
    status = DEV_NOT_EXIST;  /* device not yet initialized */
  else
  {
    if (row == 0)  /* clear entire screen display */
      status = clr_disp(device_no);  /* clear display */
    else  /* otherwise delete a line */
      status = del_line(device_no, row);
  }

  return status;
}
