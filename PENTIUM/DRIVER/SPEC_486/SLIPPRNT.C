/****************************************************************************
  SLIPPRNT.C

  Syntax:

    SLIP_PRINT( <text_message>, <line_flag> )

  Parameters:

    <text_message> -  a null-terminated character string. Length
                      ranging from 1 to 65535 bytes.

    <line_flag>  -  a flag that indicates if a line feed is automatically
                    appended in printing <text_message>. A non-zero
                    value enables it, otherwise a value of zero (0), 
                    disables it.

  Description:

    SLIP_PRINT() executes the print jobs for the optional slip printer.
    This function automatically executes a line feed depending on the 
    <line_flag>. A line feed clears and prints the data in the print buffer
    and then sets the next print position to the leftmost column. 

  Return values:
    
    NORMAL         - Normal operation
    DEV_NOT_READY  - Device not ready
    DEV_NOT_EXIST  - Device not initialized
    INVP           - Invalid parameter or invalid command
    SLIP_PAPER_OUT - (optional) slip printer paper error

    See header file - PFL_CLIP.CH for details.
    
  Note:
  This function acts as an interface between the Clipper application and the
  PCR device drivers. This function is callable from Clipper using the
  Extend System.
  
  For more information about the PCR device drivers see the POS 3000
  Technical Reference manual.

  rnr  5-9-95
*****************************************************************************/
#include <stdio.h>
#include <string.h>
#include "extend.h"
#include "pcr_ext.h"
#include "pflsrial.h"
#include "pfl_clip.ch"

#pragma intrinsic (strlen)

/* parameter constants */
enum arguments {TXT=1, LINE_FLAG};

/* External definitions */
extern POS_TABLE pos_setup[];

CLIPPER slip_print(void)
{
  int gen_status;  /* generic error codes returned to the application */
  unsigned int text_len;  /* data length */
  char *data;  /* data pointer */
  int line_feed;  /* line feed flag */
  int paper_sts;  /* slip printer paper status */
  char esc_cmd[2];
  int i;  

  /* validate parameters */
  if (PCOUNT == 2 && ISCHAR(TXT) && ISNUM(LINE_FLAG))
  {
    data = _parc(TXT);  /* get data to be printed */

    /* check data length */
    if ((text_len = strlen(data)) == 0)
    {
      _retni(INVP);
      return;
    }

    /* get line feed flag */
    line_feed = _parni(LINE_FLAG);
    
    /* verify initial status */
    if (chk_init_flag(OPT_SLIP_PRNTR) == 0)
    {
      _retni(DEV_NOT_EXIST);   /* device not yet initialized */
      return;
    }

    /* verify if the device was turned off */
    if ((paper_sts = pfl_com_dsts(pos_setup[OPT_SLIP_PRNTR].base_addrs)) & 0x1f00)
    {
      if (paper_sts & 0x0100)  /* ignore incoming data */
        pfl_com_drecv();
        
      _retni(DEV_NOT_READY);
      return;
    }

    /* check paper status: see corresponding printer manual for verifying the paper status */
    esc_cmd[0] = ESC_CODE;
    esc_cmd[1] = 0x76;
    
    if (pfl_com_nsend(esc_cmd, 2))
    {
      _retni(DEV_NOT_READY);
      return;      
    }
    
    /* This loop waits for a response from the slip printer and returns
       DEV_NOT_READY after approximately 3.5 seconds has expired. 3.5s
       is computed by multiplying the loop count (14) by the wait state 
       of pfl_com_drecv() - which is approximately 250ms (see pflsrial.asm
       for details). */

    i = 0;
    while ((paper_sts = pfl_com_drecv()) == -1)
    {
      ++i;
      if (i == 14)
        break;
    }
      
    if (i == 14)  /* time has elapsed */
    {
      _retni(DEV_NOT_READY);
      return;
    }
    
    if (paper_sts & 0x0003)  /* status byte bit 0 or/and bit 1 is set */
    {
      _retni(SLIP_PAPER_OUT);
      return;
    }
    
    /* send data to printer */
    gen_status = NORMAL;  /* assume normal */

    if (pfl_com_nsend(data, text_len))
      gen_status = DEV_NOT_READY;

    if (line_feed)  /* execute line feed? */
    {
      if (pfl_com_send('\n'))
        gen_status = DEV_NOT_READY;
    }      

    _retni(gen_status);
    
  }
  else
    _retni(INVP);
}
