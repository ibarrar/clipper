/****************************************************************************
  CHK_DRW.C

  Syntax:

    CHK_DRAWR()

  Parameters:

    No parameters.

  Description:

    CHK_DRAWR() verifies whether the cash drawer is open or closed.
    It returns DRAWER_OPEN to signal that the cash drawer is open, while
    DRAWER_CLOSED indicates that the cash drawer is already closed.
        
  Return values:
    
    Returns a numeric value describing the result of the process.

    DEV_NOT_READY - Device not ready
    DEV_NOT_EXIST - Device not initialized
    DRAWER_OPEN   - Cash drawer already open
    DRAWER_CLOSED - Cash drawer already closed
    INVP          - Invalid parameter or invalid command
    
    See header file - PFL_CLIP.CH for details.

  rnr  6-15-95
*****************************************************************************/
#include <stdio.h>
#include "extend.h"
#include "pcr_ext.h"
#include "pflsrial.h"
#include "pfl_clip.ch"

/* External definitions */
extern POS_TABLE pos_setup[];

CLIPPER chk_drawr(void)
{
  int gen_status; /* generic error codes returned to the application */
  int rts_sts;  /* RTS status */
  int cts_sts;  /* CTS status */  

  /* validate parameters */
  if (PCOUNT == 0)  /* no argument is passed */
  {
    /* verify initial status */
    if (chk_init_flag(POS_CASH_DRAW) == 0)
    {
      _retni(DEV_NOT_EXIST);   /* device not yet initialized */
      return;
    }

    /* query cash drawer status */
    rts_sts = pfl_com_rmcr(pos_setup[POS_CASH_DRAW].base_addrs);

    rts_sts &= 0x0002;  /* mask RTS bit */

    cts_sts = pfl_com_ndsts(pos_setup[POS_CASH_DRAW].base_addrs);

    cts_sts &= 0x0010;  /* mask CTS bit */    

    if (rts_sts && cts_sts)  /* cash drawer is already closed */
      gen_status = DRAWER_CLOSED;
    else
      gen_status = DRAWER_OPEN;  /* cash drawer is already open */

    _retni(gen_status); 
  }
  else
    _retni(INVP);
}
                       