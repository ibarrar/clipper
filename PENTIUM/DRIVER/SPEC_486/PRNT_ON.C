/*****************************************************************************
  PRNT_ON.C

  Syntax:
  
    A_PRNT_ON() 

  Parameters:

    No parameters.

  Description:

    A_PRNT_ON() enables asynchronous printing. This function is called prior
    to the use of the asynchronous print functions - A_RJS_PRNT(), A_RJS_FEED()
    and A_PRT_ESC().

  Return values:

    NORMAL         - Normal operation
    DEV_NOT_EXIST  - Device not initialized
    INVP           - Invalid parameter or invalid command

    See header file - PFL_CLIP.CH for details.    

  Note:
  This function acts as an interface between the Clipper application and the
  PCR device drivers. This function is callable from Clipper using the
  Extend System.
  
  For more information about the PCR device drivers see the POS 3000
  Technical Reference manual.
    
  rnr  6-27-94
  rnr  5-15-95
*****************************************************************************/
#include "extend.h"
#include "pcr_ext.h"
#include "pfl_clip.ch"

/* EXTERNAL DEFINITIONS */
extern int print_status;  /* holds the generic printer status */
extern int print_active;  /* a flag that indicates that a print job is in progress */
extern int print_stop;  /* a value of 1 disables RJ printing; otherwise, a value
                           of zero enables it */
extern RJS_DATA1 prnt_data1[PRINT_JOBS];  /* print job buffer */
extern int buff_in1;  /* buffer input index */
extern int buff_out1; /* buffer output index */
extern int async_printing;  /* flag that indicates the asynchronous printing mode */
extern int buffer_empty;  /* flag that indicates if the print buffer is empty */

CLIPPER a_prnt_on(void)
{
  /* validate parameters */
  if (PCOUNT == 0)  /* no argument is passed */  
  {
    if (async_printing)  /* already in asynchronous printing mode */
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

    /* initialization */
    print_status = print_active = print_stop = 0;
    async_printing = buffer_empty = 1;

    buff_in1 = buff_out1 = 0;  /* set buffer indices to start of buffer (empty) */
    
    /* call the asynchronous printing initialization function */
    asyn_prnt_on();

    _retni(NORMAL);
  }
  else
    _retni(INVP);
}
