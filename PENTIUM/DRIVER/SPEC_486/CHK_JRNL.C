/****************************************************************************
  CHK_JRNL.C

  Syntax:

    CHK_JRNAL()

  Parameters:

    No parameters.

  Description:

    CHK_JRNAL() detects paper-out condition on the journal printer.
        
  Return values:
    
    Returns a numeric value describing the result of the process.

    NORMAL        - Normal operation
    DEV_NOT_EXIST - Device not initialized
    PAPER_ERR     - Paper error
    INVP          - Invalid parameter or invalid command    
    
    See header file - PFL_CLIP.CH for details.

  rnr  8-12-95
*****************************************************************************/
#include <stdio.h>
#include "extend.h"
#include "pcr_ext.h"
#include "pfl_lpt.h"
#include "pfl_clip.ch"

/* External definitions */
extern POS_TABLE pos_setup[];
extern int print_stop;  /* a value of 1 disables RJ printing; otherwise, a value
                           of zero enables it */
extern int buffer_empty;  /* flag that indicates if the print buffer is empty */

CLIPPER chk_jrnal(void)
{
  int gen_status; /* generic error codes returned to the application */
  unsigned char esc_cmd[5];  
  int paper_sts;

  /* validate parameters */
  if (PCOUNT == 0)  /* no argument is passed */
  {
    /* verify initial status */
    if (chk_init_flag(POS_PRINTER) == 0)
    {
      _retni(DEV_NOT_EXIST);   /* device not yet initialized */
      return;
    }

    /* allow current print jobs to finish */
    while (!print_stop && !buffer_empty)
      delay(10); 

/*    delay(100);   put some delay to allow any current print jobs to finish */              
    
    gen_status = NORMAL;  /* assume normal */
    
    /* query cash journal paper status */

    esc_cmd[0] = ESC_CODE;
    esc_cmd[1] = 'c';
    esc_cmd[2] = '3';
    esc_cmd[3] = 1;    

    pfl_lpt_nsend(pos_setup[POS_PRINTER].lpt_port, esc_cmd, 4);    

    delay(50);  /* put some delay */

    paper_sts = pfl_lpt_sts(pos_setup[POS_PRINTER].lpt_port);    

    if (paper_sts & 0x0020)  /* out of paper? */
      gen_status = PAPER_ERR;
    
    _retni(gen_status); 
  }
  else
    _retni(INVP);
}
                       