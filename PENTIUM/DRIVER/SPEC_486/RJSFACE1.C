/****************************************************************************
  RJSFACE1.C

  Syntax:

    A_RJS_PRNT( <receipt>, <journal>, <slip>, <text_message>, <line_flag> )

  Parameters:

    <receipt>
    <journal>
    <slip>     -  flags indicating the desired printer station in 
                  which <text_message> is printed. A non-zero value
                  enables the desired printer station for printing, 
                  otherwise a value of zero (0), disables it. These
                  flags are of numeric data type. 

    <text_message> -  a null-terminated character string. Length
                      ranging from 1 to 80 bytes.

    <line_flag>  -  a flag that indicates if a line feed is automatically
                    appended in printing <text_message>. A non-zero
                    value enables it, otherwise a value of zero (0), 
                    disables it.

  Description:

    A_RJS_PRNT() executes asynchronously the print jobs for the receipt, 
    journal and slip printer station. 

    The number of characters that can be printed per line depends on the 
    printer station selected and the printer type. If a print job exceeds 
    the maximum line length, the remainder is output to the next line.

    Only one printer station can be selected at any one time, with the excep-
    tion of Receipt and Journal which can be regarded as single printer station.
    
    If no printer station is selected, A_RJS_PRNT() defaults to Receipt printer.
        
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
enum arguments {RCPT=1, JRNAL, SLIP, TXT, LINE_FLAG}; 

/* EXTERNAL DEFINITIONS */
extern RJS_DATA1 prnt_data1[PRINT_JOBS];  /* print job buffer */
extern int buff_in1;  /* buffer input index */
extern int buff_out1; /* buffer output index */
extern int buffer_empty;  /* flag that indicates if the print buffer is empty */
extern int async_printing;  /* flag that indicates the asynchronous printing mode */

CLIPPER a_rjs_prnt(void)
{
  static unsigned char printer_type;  /* bit assignments for print station */
  static unsigned int text_len;  /* data length */
  static char *data;  /* data pointer */
  static int line_feed;  /* line feed flag */  
  static int next_buff_in;  /* next buffer input index */

  /* validate parameters */
  if (PCOUNT == 5 && ISNUM(RCPT) && ISNUM(JRNAL) && 
                     ISNUM(SLIP) && ISCHAR(TXT) && ISNUM(LINE_FLAG))
  {                     
    if (!async_printing)  /* not in asynchronous printing mode */
    {
      _retni(INVP);  
      return;
    }
      
    data = _parc(TXT);  /* get data to be printed */

    /* check data length */
    text_len = _parclen(TXT);
    
    if (NOT_IN_RANGE(text_len, 1, 80))
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

    /* get line feed flag */
    line_feed = _parni(LINE_FLAG);
    
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

    prnt_data1[buff_in1].func_type = 0;  /* A_RJS_PRNT() */
    prnt_data1[buff_in1].printer_type = printer_type;
    prnt_data1[buff_in1].line_flag = line_feed;
    prnt_data1[buff_in1].text_len = text_len;
    _bcopy(prnt_data1[buff_in1].txt_msg, data,text_len);

    buff_in1 = next_buff_in;  /* update buffer input index */
    buffer_empty = 0;  /* buffer is not empty */

    _retni(NORMAL);
  }
  else
    _retni(INVP);
}
                     