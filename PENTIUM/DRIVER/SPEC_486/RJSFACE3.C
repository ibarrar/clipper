/****************************************************************************
  RJSFACE3.C

  Syntax:

    A_PRT_ESC( <esc_sequences> )

  Parameters:

    <esc_sequences> -  a null-terminated character string containing
                       the escape sequences. The escape sequences
                       must be passed as Hexadecimal digits (0-9, a-f or A-F),
                       in other words in Hexadecimal equivalent. For example, 
                       sending a command for stamping the logo on the receipt: 
                       ESCo is sent as "1B6F", "1B" for the ESC code and "6F" 
                       for the ASCII character "o". The string passed must be
                       in even no. of bytes, that is 2 hexadecimal digits for 
                       1 ASCII character. String length is 1 to 80 bytes.
                      
  Description:

    A_PRT_ESC() provides specific printer control commands by way of Escape
    sequences. The command is sent to the printer asynchronously.

    It is the responsibility of the user that the command sent is
    valid or applicable to the designated printer station (receipt, journal or
    slip). Escape sequences that require a response must not be used. Invalid
    sequences could cause the printer to print out on the currently active
    station.
        
  Return values:

    The following error codes only indicates whether the requested print job 
    is buffered successfully.
    
    NORMAL         - Normal operation
    DEV_NOT_EXIST  - Device not initialized    
    INVP           - Invalid parameter or invalid command
    MEM_OUT        - Not enough space in memory
                  
    See header file - PFL_CLIP.CH for details.
    
  Note:
  This function acts as an interface between the Clipper application and the
  PCR device drivers. This function is callable from Clipper using the
  Extend System.
  
  For more information about the PCR device drivers see the POS 3000
  Technical Reference manual.
  
  rnr  6-25-94
  rnr  5-15-95
*****************************************************************************/

#include "extend.h"
#include "pcr_ext.h"
#include "pfl_clip.ch"


#define BUFF_SIZE   50     /* maximum buffer size for escape sequences */

/* parameter constants */
#define ESC_SEQ      1

/* EXTERNAL DEFINITIONS */
extern RJS_DATA1 prnt_data1[PRINT_JOBS];  /* print job buffer */
extern int buff_in1;  /* buffer input index */
extern int buff_out1; /* buffer output index */
extern int buffer_empty;  /* flag that indicates if the print buffer is empty */
extern int async_printing;  /* flag that indicates the asynchronous printing mode */
extern unsigned char toupper(unsigned char hexchar);

/* OTHER VARIABLES */
static unsigned char esc_cmd[BUFF_SIZE];  /* holds the escape sequences */

/* LOCAL FUNCTIONS */
static int ishex_digit(unsigned char *hexchar, unsigned char *hex_value);
static int ascii_to_hex(unsigned char *hexchar, unsigned int len);

CLIPPER a_prt_esc(void)
{
  static int next_buff_in;  /* next buffer input index */
  static unsigned int len;  /* hex string length */
  static char *data;  /* hex string pointer */

  /* validate parameters */
  if (PCOUNT == 1 && ISCHAR(ESC_SEQ))
  {
    if (!async_printing)  /* not in asynchronous printing mode */
    {
      _retni(INVP);  
      return;
    }
      
    data = _parc(ESC_SEQ);  /* get hex string */
    len  = _parclen(ESC_SEQ);

    /* check data length */
    if (len  < 1 || len > 80 || (len % 2) != 0)
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
    
    /* convert ASCII hex string to its numeric hex equivalent */
    if (ascii_to_hex(data, len) != NORMAL)
    {
      _retni(INVP);
      return;
    }

    prnt_data1[buff_in1].func_type = 2;  /* A_PRT_ESC() */
    prnt_data1[buff_in1].text_len = len / 2;
    _bcopy(prnt_data1[buff_in1].txt_msg, esc_cmd, len / 2);

    buff_in1 = next_buff_in;  /* update buffer input index */
    buffer_empty = 0;  /* buffer is not empty */    
    
    _retni(NORMAL);
  }
  else
    _retni(INVP);
}

static int ascii_to_hex(unsigned char *hexchar, unsigned int len)
{
  unsigned char hex_value;
  unsigned int i, j;
  int status = 0;

  for (i = j = 0; i < len; i += 2, ++j)
  {
    if ((status = ishex_digit(hexchar+i, &hex_value)) != NORMAL)
      break;

    esc_cmd[j] = (unsigned char) (hex_value << 4);

    if ((status = ishex_digit(hexchar+i+1, &hex_value)) != NORMAL)
      break;

    esc_cmd[j] += (hex_value & 0x0f);
  }

  return status;
}
  
static int ishex_digit(unsigned char *hexchar, unsigned char *hex_value)
{
  unsigned char hex_digit;

  hex_digit = (unsigned char) toupper(*hexchar);

  if (hex_digit >= 'A' && hex_digit <= 'F')
    *hex_value = (unsigned char) (hex_digit - '7');
  else if (hex_digit >= '0' && hex_digit <= '9')
    *hex_value = (unsigned char) (hex_digit - '0');
  else
    return INVP;

  return NORMAL;
}
                       
