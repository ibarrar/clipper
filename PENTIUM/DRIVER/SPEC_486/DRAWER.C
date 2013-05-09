#include <extend.h>
#include <conio.H>

#include "pcr_ext.h"
#include "pflsrial.h"
#include "pfl_clip.ch"

/* External definitions */
extern POS_TABLE pos_setup[];


CLIPPER OPEN_DRAWR()
{
  outp(0x260,0x14);
  outp(0x261,0x04);

  outp(0x260,0x15);
  outp(0x261,0x01);

  _ret();
}

CLIPPER CHK_DRAWR()
{
  int gen_status; /* generic error codes returned to the application */
  int rts_sts;    /* RTS status */
  int cts_sts;    /* CTS status */  

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
