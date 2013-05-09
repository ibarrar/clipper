/****************************************************************************
  VALIDPRN.C

  Syntax:
  
    VALID_PRNT( <text_message>, <line_flag> [, <line/row number>])

  Parameters:

    <text_message> -  a null-terminated character string.

    <line_flag>    -  a flag that indicates if a line feed is automatically
                      appended in printing <text_message>. A non-zero
    		      value enables it, otherwise a value of zero (0),
		      disables it.

    <line/row number> - an optional parameter specifying the row
         	        number the printing starts. This is only
			supported by the 11-line validation printer.

  Description:

    VALID_PRNT() executes the print jobs for the single-line validation
    printer. This function automatically executes a line feed depending on the
    <line_flag>.

    The <line/row number> must be used for the 11-line validation printer. 
    Otherwise, this function assumes that a one-line validation printer is 
    used.

  Return values:

    NORMAL         - Normal operation
    DEV_NOT_READY  - Device not ready
    DEV_NOT_EXIST  - Device not initialized
    PAPER_ERR      - Paper error    
    INVP           - Invalid parameter or invalid command

    See header file - PFL_CLIP.CH for details.

  Note:
  This function acts as an interface between the Clipper application and the
  PCR device drivers. This function is callable from Clipper using the Extend
  System.

  For more information about the PCR device drivers see the POS 3000
  Technical Reference manual.
  
  rnr  9-19-95  One-line validation.    (revised aea)
  aea  4-18-96  11-line validation.  
*****************************************************************************/
/*
#include <stdio.h>
#include <string.h>
*/
#include "extend.h"
#include "pcr_ext.h"
#include "pfl_lpt.h"
#include "pfl_clip.ch"

/* #pragma intrinsic (strlen) */

/* parameter constants */
enum arguments {TXT=1, LINE_FLAG, ROW_NUM};

/* EXTERNAL DEFINITIONS */
extern POS_TABLE pos_setup[];

/* LOCAL FUNCTIONS */
static int single_prnt(char *data, unsigned int len, int line_feed);
static int eleven_prnt(unsigned char row, char *data, unsigned int len, int line_feed);

CLIPPER valid_prnt(void)
{
  int gen_status;  /* generic error codes returned to the application */
  unsigned int text_len;  /* data length */
  char *data;  /* data pointer */
  int line_feed;  /* line feed flag */
  unsigned char row_number; /* starting row number */

  /* validate parameters */
  if (PCOUNT == 2 && ISCHAR(TXT) && ISNUM(LINE_FLAG))  /* for one-line */
  {
    data = _parc(TXT);  /* get data to be printed */
    text_len = _parclen(TXT);

    /* check data length */
    if (text_len == 0)
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

    gen_status = single_prnt(data, text_len, line_feed);

    _retni(gen_status);
  }
  /* for 11-line */
  else if (PCOUNT == 3 && ISCHAR(TXT) && ISNUM(LINE_FLAG) && ISNUM(ROW_NUM))
  {
    data = _parc(TXT);  /* get data to be printed */
    text_len = _parclen(TXT);

    /* check data length */
    if (text_len == 0)
    {
      _retni(INVP);
      return;
    }

    /* get line feed flag */
    line_feed = _parni(LINE_FLAG);

    /* get starting row number */
    row_number = (unsigned char) _parni(ROW_NUM);

    /* verify initial status */
    if (chk_init_flag(POS_PRINTER) == 0)
    {
      _retni(DEV_NOT_EXIST);   /* device not yet initialized */
      return;
    }

    gen_status = eleven_prnt(row_number, data, text_len, line_feed);

    _retni(gen_status);
  }
  else
    _retni(INVP);
}

/*********
static int single_prnt(char *data, unsigned int len, int line_feed)
{
  static int gen_status;       * generic error codes returned to the application *
  static unsigned char esc_cmd[5];  * holds the printer escape sequence commands *
  * static int port_status;  holds the current parallel port status *

  * port_status = pfl_lpt_sts(pos_setup[POS_PRINTER].lpt_port);

  for the meantime
  timeout, I/O error, out of paper, and not selected status 
  if ((port_status & 0x29) || !(port_status & 0x10))
    return DEV_NOT_READY; *

  gen_status = NORMAL;  * assume normal operation *
  
  * send Select printer station comand *
  esc_cmd[0] = ESC_CODE;
  esc_cmd[1] = 'c';
  esc_cmd[2] = '0';
  esc_cmd[3] = 0x02;  * single-line validation printer *

  * send escape sequence command to printer *
  pfl_lpt_nsend(pos_setup[POS_PRINTER].lpt_port, esc_cmd, 4);

  * send data to printer *
  pfl_lpt_nsend(pos_setup[POS_PRINTER].lpt_port, data, len);  

  if (line_feed)  * execute line feed? *
  {
    * send Line feed command *
    esc_cmd[0] = '\r';

    pfl_lpt_send(pos_setup[POS_PRINTER].lpt_port, esc_cmd[0]);
  }
    
  return gen_status;
}                 */



static int eleven_prnt(unsigned char row, char *data, unsigned int len, int line_feed)
{
  static int gen_status;       /* generic error codes returned to the application */
  static unsigned char esc_cmd[5];  /* holds the printer escape sequence commands */
  /* static int port_status;  holds the current parallel port status */

  gen_status = NORMAL;  /* assume normal operation */

  /* send Select printer station command */
  esc_cmd[0] = ESC_CODE;
  esc_cmd[1] = 'c';
  esc_cmd[2] = '0';
  esc_cmd[3] = 0x02;  /* single-line validation printer */

  /* send escape sequence command to printer */
  pfl_lpt_nsend(pos_setup[POS_PRINTER].lpt_port, esc_cmd, 4);

  /* send Select printer paper end signal */
  esc_cmd[0] = ESC_CODE;
  esc_cmd[1] = 'c';
  esc_cmd[2] = '3';
  esc_cmd[3] = 0x02;  /* single-line validation printer */

  /* send escape sequence command to printer */
  pfl_lpt_nsend(pos_setup[POS_PRINTER].lpt_port, esc_cmd, 4);

  /* Load validation card to printing area */

  esc_cmd[0] = ESC_CODE;
  esc_cmd[1] = 'l';

  /* send escape sequence command to printer */
  pfl_lpt_nsend(pos_setup[POS_PRINTER].lpt_port, esc_cmd, 2);

  if ((row > 1) && (row < 12))
  {
    esc_cmd[0] = ESC_CODE;
    esc_cmd[1] = 'd';
    esc_cmd[2] = (unsigned char) (row-1);
    pfl_lpt_nsend(pos_setup[POS_PRINTER].lpt_port, esc_cmd, 3);
  }

  /* Delay */

  delay(100);

  if ((pfl_lpt_sts(pos_setup[POS_PRINTER].lpt_port) & 0xB0) == 0xB0)
  {
    /* Paper not ready or not propely inserted */

    /* Eject validation card */

    esc_cmd[0] = ESC_CODE;
    esc_cmd[1] = 'q';

    /* send escape sequence command to printer */
    pfl_lpt_nsend(pos_setup[POS_PRINTER].lpt_port, esc_cmd, 2);

    /* return paper-out sensor to journal */
    esc_cmd[0] = ESC_CODE;
    esc_cmd[1] = 'c';
    esc_cmd[2] = '3';
    esc_cmd[3] = 1;

    /* send escape sequence command to printer */
    pfl_lpt_nsend(pos_setup[POS_PRINTER].lpt_port, esc_cmd, 4);

    return PAPER_ERR;
  }

  /* send data to printer */
  pfl_lpt_nsend(pos_setup[POS_PRINTER].lpt_port, data, len);

  if (line_feed)  /* execute line feed? */
  {
    /* send Line feed command */
    esc_cmd[0] = '\r';

    pfl_lpt_send(pos_setup[POS_PRINTER].lpt_port, esc_cmd[0]);
  }

  /* return paper-out sensor to journal */
  esc_cmd[0] = ESC_CODE;
  esc_cmd[1] = 'c';
  esc_cmd[2] = '3';
  esc_cmd[3] = 1;

  /* send escape sequence command to printer */
  pfl_lpt_nsend(pos_setup[POS_PRINTER].lpt_port, esc_cmd, 4);

  /* Move print head to the right side */

  esc_cmd[0] = ESC_CODE;
  esc_cmd[1] = '>';

  /* send escape sequence command to printer */
  pfl_lpt_nsend(pos_setup[POS_PRINTER].lpt_port, esc_cmd, 2);


  /* Eject validation card */

  esc_cmd[0] = ESC_CODE;
  esc_cmd[1] = 'q';

  /* send escape sequence command to printer */
  pfl_lpt_nsend(pos_setup[POS_PRINTER].lpt_port, esc_cmd, 2);

  return gen_status;
}

/***** This is the revised one line validation of Richard before
       he left... */
static int single_prnt(char *data, unsigned int len, int line_feed)
{
  static int gen_status;
  static unsigned char esc_cmd[5];
  static int port_status;

  gen_status = NORMAL;

  /* query cash validation paper status */
  esc_cmd[0] = ESC_CODE;
  esc_cmd[1] = 'c';
  esc_cmd[2] = '3';
  esc_cmd[3] = 2;    

  pfl_lpt_nsend(pos_setup[POS_PRINTER].lpt_port, esc_cmd, 4);    

  delay(50);  /* put some delay */
  
  port_status = pfl_lpt_sts(pos_setup[POS_PRINTER].lpt_port);

   /* out of paper? aea removed !*/
  /* if (!(port_status & 0x0020))  Removing paper checking...
    gen_status = PAPER_ERR;  */

  if (gen_status == NORMAL)
  {  
    /* send Select printer station comand */
    esc_cmd[0] = ESC_CODE;
    esc_cmd[1] = 'c';
    esc_cmd[2] = '0';
    esc_cmd[3] = 0x02;  /* single-line validation printer */

    /* send escape sequence command to printer */
    pfl_lpt_nsend(pos_setup[POS_PRINTER].lpt_port, esc_cmd, 4);

    /* send data to printer */
    pfl_lpt_nsend(pos_setup[POS_PRINTER].lpt_port, data, len);  

    if (line_feed)  /* execute line feed? */
    {
      /* send Line feed command */
      esc_cmd[0] = '\r';

      pfl_lpt_send(pos_setup[POS_PRINTER].lpt_port, esc_cmd[0]);
    }
  }

  /* return paper-out sensor to journal */
  esc_cmd[0] = ESC_CODE;
  esc_cmd[1] = 'c';
  esc_cmd[2] = '3';
  esc_cmd[3] = 1;

  /* send escape sequence command to printer */
  pfl_lpt_nsend(pos_setup[POS_PRINTER].lpt_port, esc_cmd, 4);  

  delay(50);  /* put some delay */
    
  return gen_status;
}

