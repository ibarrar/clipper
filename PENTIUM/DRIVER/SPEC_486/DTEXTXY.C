/****************************************************************************
  DTEXTXY.C

  Syntax:

    DISPTEXTXY( <cashr_row>, <cashr_col>, <cust1_row>, <cust1_col>,
                <cust2_row>, <cust2_col>, <text_msg> )

  Parameters:

    <cashr_row> 
    <cashr_col> - numeric arguments that specifies the line number and the
                  column position, respectively on the cashier display. A
                  non-zero value on both arguments enables cashier display for 
                  this function, otherwise a value of zero (0) in any of these 
                  arguments disables it. Furthermore, <cashr_row> can contain 
                  the status of the cashier display, if passed by reference (@). 
                  In this case, see header file - PFL_CLIP.CH for the statuses.

                  Values passed must be in the following ranges:
                    row position 0-4
                    col position 0-20 

    <cust1_row> 
    <cust1_col> - numeric arguments that specifies the line number and the
                  column position, respectively on the integrated customer 
                  display. A non-zero value on both arguments enables customer 
                  display for this function, otherwise a value of zero (0) in 
                  any of these arguments disables it. Furthermore, <cust1_row> 
                  can contain the status of the integrated customer display, 
                  if passed by reference (@). In this case, see header 
                  file - PFL_CLIP.CH for the statuses.                  

                  Values passed must be in the following ranges:
                    row position 0-1
                    col position 0-9

    <cust2_row> 
    <cust2_col> - numeric arguments that specifies the line number and the
                  column position, respectively on the additional (or supple-
                  mentary) customer display. A non-zero value on both arguments 
                  enables customer display for this function, otherwise a 
                  value of zero (0) in any of these arguments disables it. 
                  Furthermore, <cust2_row> can contain the status of the 
                  additional customer display, if passed by reference (@). 
                  In this case, see header file - PFL_CLIP.CH for the statuses.

                  Values passed must be in the following ranges:
                    row position 0-2
                    col position 0-20

    <text_msg> -  a null-terminated character string. Length ranging 
                  from 1 to 125 bytes.

  Description:

    DISPTEXTXY() outputs data to the designated display, using the specified
    line number and column position. 

    The possible values for the line numbers and the column positions depend
    on the type of display used.

  Return values:
    
    Returns INVP, when an invalid argument is passed, otherwise it returns
    NORMAL.
    
  Note:
  This function acts as an interface between the Clipper application and the
  PCR device drivers. This function is callable from Clipper using the
  Extend System.
  
  For more information about the PCR device drivers see the POS 3000
  Technical Reference manual.

  
  rnr  5-6-95
*****************************************************************************/
#include "extend.h"
#include "pcr_ext.h"
#include "pflsrial.h"
#include "pfl_clip.ch"


/* parameter constants */
enum arguments {CASHR_ROW=1, CASHR_COL, CUST1_ROW, CUST1_COL,
                CUST2_ROW, CUST2_COL, TXT};

/* External definitions */
extern POS_TABLE pos_setup[];

/* Local functions */
static int req_cmd(int device_no, int row, int col, char *data, unsigned int len);

CLIPPER disptextxy(void) 
{
  int cashr_status;  /* holds the cashier display status */
  int cust1_status;  /* holds the integrated customer display status */
  int cust2_status;  /* holds the additional customer display status */
  int cashr_y, cashr_x;  /* cashier display screen coordinates */
  int cust1_y, cust1_x;  /* integrated customer display screen coordinates */
  int cust2_y, cust2_x;  /* additional customer display screen coordinates */
  unsigned char display_type;  /* bit assignments for display type */
  unsigned int text_len;  /* data length */
  char *data;  /* data pointer */

  cashr_status = cust1_status = cust2_status = NORMAL;  /* initial status */
    
  /* validate parameters */
  if (PCOUNT == 7 && ISNUM(CASHR_ROW) && ISNUM(CASHR_COL) && ISNUM(CUST1_ROW) && 
                     ISNUM(CUST1_COL) && ISNUM(CUST2_ROW) && ISNUM(CUST2_COL) && 
                     ISCHAR(TXT))
  {
    data = _parc(TXT);  /* get data to be displayed */    
    text_len = _parclen(TXT);

    /* check data length */
    if (text_len < 1 || text_len > 125)
    {
      _retni(INVP);
      return;
    }

    /* get cursor positions & validate them */
    cashr_y = _parni(CASHR_ROW);  /* cashier line # */
    cashr_x = _parni(CASHR_COL);  /* cashier col # */
    cust1_y = _parni(CUST1_ROW);  /* integrated customer line # */
    cust1_x = _parni(CUST1_COL);  /* integrated customer col # */
    cust2_y = _parni(CUST2_ROW);  /* additional customer line # */
    cust2_x = _parni(CUST2_COL);  /* additional customer col # */

    if (NOT_IN_RANGE(cashr_y, 0, 4) || NOT_IN_RANGE(cashr_x, 0, 20))
    {
      _retni(INVP);
      return;
    }

    if (NOT_IN_RANGE(cust1_y, 0, 1) || NOT_IN_RANGE(cust1_x, 0, 9))
    {
      _retni(INVP);
      return;
    }

    if (NOT_IN_RANGE(cust2_y, 0, 2) || NOT_IN_RANGE(cust2_x, 0, 20))
    {
      _retni(INVP);
      return;
    }
    
    /* determine display type */
    display_type = 0x00;
    if (cashr_y && cashr_x)  /* non-zero value */
      display_type |= 0x01;  /* cashier display */

    if (cust1_y && cust1_x)  /* non-zero value */
      display_type |= 0x02;  /* integrated customer display */

    if (cust2_y && cust2_x)  /* non-zero value */
      display_type |= 0x04;  /* additional customer display */

    if (display_type == 0)  /* no selected display */
    {
      _retni(NORMAL);
      return;
    }
#if 0    
    if (display_type & 0x01)  /* cashier display */
      cashr_status = req_cmd(POS_CASH_DISP, cashr_y, cashr_x, data, text_len);

    if (display_type & 0x02)  /* integrated customer display */
      cust1_status = req_cmd(POS_CUST_DISP1, cust1_y, cust1_x, data, text_len);
#endif
    if (display_type & 0x04)  /* additional customer display */
      cust2_status = req_cmd(POS_CUST_DISP2, cust2_y, cust2_x, data, text_len);

    if (ISBYREF(CASHR_ROW))  /* passed by reference */
      _storni(cashr_status, CASHR_ROW);  /* return status result */  

    if (ISBYREF(CUST1_ROW))  /* passed by reference */
      _storni(cust1_status, CUST1_ROW);  /* return status result */      

    if (ISBYREF(CUST2_ROW))  /* passed by reference */
      _storni(cust2_status, CUST2_ROW);  /* return status result */      
        
    _retni(NORMAL);      
  }
  else
    _retni(INVP);
}

static int req_cmd(int device_no, int row, int col, char *data, unsigned int len)
{
  int status;

  if (chk_init_flag(device_no) == 0)
    status = DEV_NOT_EXIST;  /* device not yet initialized */
  else
  {
    if ((status = set_disp_cursor(device_no, row, col)) == NORMAL)
    {
      /* output data to the corresponding display */
      switch (device_no)
      {
#if 0	 
         case POS_CASH_DISP:
         case POS_CUST_DISP1: 
                _fsWrite(pos_setup[device_no].file_num, data, len),
                status = error_map(_fsError());
                break;
#endif			                          
        case POS_CUST_DISP2: 
                if (pfl_com_nsendb(pos_setup[device_no].base_addrs, data, len))
                    status = DEV_NOT_READY;
                break;    
      }      
    }
  }

  return status;
}
