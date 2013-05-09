/****************************************************************************
  RJSFACE2.C

  Syntax:

    A_RJS_FEED( <receipt>, <journal>, <slip>, <no_of_lfeeds> )

  Parameters:

    <receipt>
    <journal>
    <slip>     -  flags indicating the desired printer station in 
                  which <no_of_lfeeds> is sent. A non-zero value
                  enables the desired printer station for printing, 
                  otherwise a value of zero (0), disables it. These
                  flags are of numeric data type. 

    <no_of_lfeeds> - a numeric variable containing the number of line
                     feeds to be executed. Values ranging from 1-32.
  Description:

    A_RJS_FEED() performs a line feed asynchronously and sets the next 
    print position to the leftmost column of the selected print station.

    Only one printer station can be selected at any one time, with the excep-
    tion of Receipt and Journal which can be regarded as single printer station.
    
    If no printer station is selected, A_RJS_FEED() defaults to Receipt printer.
    
  Return values:

    The following error codes only indicates whether the requested print job 
    is buffered successfully.
    
    NORMAL         - Normal operation
    DEV_NOT_EXIST  - Device not initialized    
    INVP           - Invalid parameter or invalid command
    MEM_OUT        - Not enough space in memory
                  
    See header file - PFL_CLIP.CH for details.

  Remarks:    

    Single-line validation print (slip) is not supported. For paper-out
    condition, only the journal side can be detected (using CHK_JRNAL()).    
           
  Note:
  This function acts as an interface between the Clipper application and the
  PCR device drivers. This function is callable from Clipper using the
  Extend System.
  
  For more information about the PCR device drivers see the POS 3000
  Technical Reference manual.
  
  rnr  6-24-94
  rnr  5-15-95
*****************************************************************************/
#include "extend.h"
#include "pcr_ext.h"
#include "pfl_clip.ch"

/* parameter constants */
enum arguments {RCPT=1, JRNAL, SLIP, NO_LFEED};

/* External definitions */
extern RJS_DATA1 prnt_data1[PRINT_JOBS];  /* print job buffer */
extern int buff_in1;  /* buffer input index */
extern int buff_out1; /* buffer output index */
extern int buffer_empty;  /* flag that indicates if the print buffer is empty */
extern int async_printing;  /* flag that indicates the asynchronous printing mode */

CLIPPER a_rjs_feed(void)
{
  static int next_buff_in;  /* next buffer input index */
  unsigned char printer_type;  /* bit assignments for print station */
  int no_feed;  /* no of line feeds */

  /* validate parameters */
  if (PCOUNT == 4 && ISNUM(RCPT) && ISNUM(JRNAL) && 
                     ISNUM(SLIP) && ISNUM(NO_LFEED))
  {
    if (!async_printing)  /* not in asynchronous printing mode */
    {
      _retni(INVP);  
      return;
    }
      
    if ((no_feed = _parni(NO_LFEED)) < 1 || no_feed > 32)
    {
      _retni(INVP);
      return;
    }

    /* determine printer station */
    printer_type = 0x00;  
    if (_parni(JRNAL))
      printer_type |= 0x01;  /* print on journal */

    if (_parni(RCPT))
      printer_type |= 0x02;  /* print on receipt */

    if (_parni(SLIP))
      printer_type |= 0x04;  /* print on slip/document */

    if (printer_type == 0x04)  /* slip validation not supported */
    {
      _retni(INVP);
      return;
    }      

    if (printer_type == 0)   /* no printer assignment */
      printer_type = 0x02;   /* default to receipt */

    /* only one printer station at a time */
    if (((printer_type & 0x02) && (printer_type & 0x04)) ||
        ((printer_type & 0x01) && (printer_type & 0x04)))
    {
      _retni(INVP);
      return;
    }
    
    /* verify initial status */
    if (chk_init_flag(POS_PRINTER) == 0)
    {
      _retni(DEV_NOT_EXIST);   /* device not yet initialized */
      return;
    }

    /* buffer the print job */
    next_buff_in = buff_in1;  /* get current buffer input index */
    ++next_buff_in;           

    if (next_buff_in == PRINT_JOBS)  /* past the end of buffer ? */
      next_buff_in = 0;  /* reset to start of buffer */

    if (next_buff_in == buff_out1)  /* is the buffer full ? */
    {
      _retni(MEM_OUT);
      return;
    }

    prnt_data1[buff_in1].func_type = 1;  /* A_RJS_FEED() */
    prnt_data1[buff_in1].printer_type = printer_type;
    prnt_data1[buff_in1].no_lfeed = no_feed;

    buff_in1 = next_buff_in;  /* update buffer input index */
    buffer_empty = 0;  /* buffer is not empty */    

    _retni(NORMAL);
    
  }
  else
    _retni(INVP);
}
                       