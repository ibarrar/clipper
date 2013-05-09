/****************************************************************************
  SLIPESC.C

  Syntax:

    SLIP_ESC( <esc_sequences> )

  Parameters:

    <esc_sequences> -  a null-terminated character string containing
                       the escape sequences. The escape sequences
                       must be passed as Hexadecimal digits (0-9, a-f or A-F),
                       in other words in Hexadecimal equivalent. For example, 
                       sending a command for initializing the printer: 
                       ESC@ is sent as "1B40", "1B" for the ESC code and "40" 
                       for the ASCII character "@". The string passed must be
                       in even no. of bytes, that is 2 hexadecimal digits for 
                       1 ASCII character. String length is 1 to 1000 bytes.
                      
  Description:

    SLIP_ESC() provides specific printer control commands for the optional slip 
    printer by way of Escape sequences.

    It is the responsibility of the user that the command sent is valid or 
    applicable. Escape sequences that require a response must not be used. 
        
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
#include <ctype.h>
 
#include "extend.h"
#include "pcr_ext.h"
#include "pflsrial.h"
#include "pfl_clip.ch"

#define BUFF_SIZE   500     /* maximum buffer size for escape sequences */

/* parameter constants */
#define ESC_SEQ      1

/* External definitions */
extern POS_TABLE pos_setup[];

/* Other variables */
static unsigned char slip_esc_cmd[BUFF_SIZE];  /* holds the escape sequences */

/* Local functions */
static int ishex_digit(unsigned char *hexchar, unsigned char *hex_value);
static int ascii_to_hex(unsigned char *hexchar, unsigned int len);

CLIPPER slip_esc(void)
{
  int gen_status;  /* generic error codes returned to the application */
  unsigned int len;  /* hex string length */
  char *data;  /* hex string pointer */
  int paper_sts;  /* slip printer paper status */  
  char esc_cmd[2];  
  int i;


  /* validate parameters */
  if (PCOUNT == 1 && ISCHAR(ESC_SEQ))
  {
    data = _parc(ESC_SEQ);  /* get hex string */
    len = _parclen(ESC_SEQ);

    /* check data length */
    if (len  < 1 || len > 1000 || (len % 2) != 0)
    {
      _retni(INVP);
      return;
    }

    /* verify initial status */
    if (chk_init_flag(OPT_SLIP_PRNTR) == 0)
    {
      _retni(DEV_NOT_EXIST);   /* device not yet initialized */
      return;
    }

    /* convert ASCII hex string to its numeric hex equivalent */
    if ((gen_status = ascii_to_hex(data, len)) == NORMAL)
    {
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
        pfl_com_nsend(slip_esc_cmd, len / 2);
        _retni(SLIP_PAPER_OUT);
        return;
      }

      /* send escape sequence command */
      if (pfl_com_nsend(slip_esc_cmd, len / 2))
        gen_status = DEV_NOT_READY;      
    }

    _retni(gen_status);
  }
  else
    _retni(INVP);
}

static int ascii_to_hex(unsigned char *hexchar, unsigned int len)
{
  unsigned char hex_value;
  unsigned int i, j;
  int status;

  for (i = j = 0; i < len; i += 2, ++j)
  {
    if ((status = ishex_digit(hexchar+i, &hex_value)) != NORMAL)
      break;

    slip_esc_cmd[j] = (unsigned char) (hex_value << 4);

    if ((status = ishex_digit(hexchar+i+1, &hex_value)) != NORMAL)
      break;

    slip_esc_cmd[j] += (hex_value & 0x0f);
  }

  return status;
}
  
static int ishex_digit(unsigned char *hexchar, unsigned char *hex_value)
{
  unsigned char hex_digit;

  hex_digit = (unsigned char) *hexchar; 

  if ( hex_digit >= 'a' && hex_digit <= 'f')
      hex_digit -= 0x20;      

  if (hex_digit >= 'A' && hex_digit <= 'F')
    *hex_value = (unsigned char) (hex_digit - '7');
  else if (hex_digit >= '0' && hex_digit <= '9')
    *hex_value = (unsigned char) (hex_digit - '0');
  else
    return INVP;

  return NORMAL;
}
                       
