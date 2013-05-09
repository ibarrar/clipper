/*****************************************************************************
  RJSASYN3.C

  Syntax:
  
    void RJS_ASYN3(void) 

  Parameters:

    None.
    
  Description:

    RJS_ASYN3() is the main print function of A_PRT_ESC() - Clipper interface.
    It is called by RJS_ASYN() from PRNTASYN.ASM.
    
  Return values:

    The actual print job status is returned in the global variable print_status.
  
  
  rnr  6-25-94
  rnr  5-15-95
  rnr  1-11-96  Removed checking of printer status.
  rnr  4-19-96  Checks paper status.
*****************************************************************************/
#include "pcr_ext.h"
#include "pfl_lpt.h"
#include "pfl_clip.ch"

/* EXTERNAL DEFINITIONS */
extern POS_TABLE pos_setup[];
extern RJS_DATA1 prnt_data1[PRINT_JOBS];  /* print job buffer */
extern int buff_in1;  /* buffer input index */
extern int buff_out1; /* buffer output index */
extern int buffer_empty;  /* flag that indicates if the print buffer is empty */
extern int print_status;  /* holds the generic printer status */
extern int print_stop;  /* a value of 1 disables RJ printing; otherwise, a value
                           of zero enables it */

void rjs_asyn3(void)
{
  static int next_buff_out;  /* next buffer output index */
  static int gen_status;     /* generic error codes returned to the application */

  gen_status = NORMAL;  /* assume normal operation */  
  
  next_buff_out = buff_out1;  /* get current buffer output index */

  if (next_buff_out == buff_in1)  /* buffer is empty ? */
    buffer_empty = 1;
  else
  {
    if (!print_stop)  /* RJ printing is enabled */
    {  
      pfl_lpt_nsend(pos_setup[POS_PRINTER].lpt_port, prnt_data1[buff_out1].txt_msg, prnt_data1[buff_out1].text_len);

      ++next_buff_out;

      if (next_buff_out == PRINT_JOBS)  /* past the end of buffer ? */
        next_buff_out = 0;  /* reset to start of buffer */      

      buff_out1 = next_buff_out;  /* update buffer output index */
    }
  }
  
  print_status = gen_status;
}
