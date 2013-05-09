/*****************************************************************************
  PRNT_OFF.C

  Syntax:
  
    A_PRNT_OFF() 

  Parameters:

    No parameters.

  Description:

    A_PRNT_OFF() disables asynchronous printing. This function is invoked after
    using the asynchronous print functions - A_RJS_PRNT(), A_RJS_FEED() and
    A_PRT_ESC(). 

    A_PRNT_OFF() flushes all print jobs in the print buffer, unless there's
    an error (PAPER_ERR) or STOP_PRINT() is invoked without the matching 
    STRT_PRINT() function.

    This function must be called before terminating the application.    

  Return values:

    NORMAL         - Normal operation
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
extern int async_printing;  /* flag that indicates the asynchronous printing mode */
extern int buffer_empty;  /* flag that indicates if the print buffer is empty */
extern int print_stop;  /* a value of 1 disables RJ printing; otherwise, a value
                           of zero enables it */

CLIPPER a_prnt_off(void)
{
  /* validate parameters */
  if (PCOUNT == 0)  /* no argument is passed */  
  {
    if (!async_printing)  /* not in asynchronous printing mode */
    {
      _retni(INVP);
      return;
    }

    /* loop while buffer is not empty; flush all print jobs */  
    while (!print_stop && !buffer_empty)  
      delay(10);

    /* disable asynchronous printing */
    asyn_prnt_off();

    async_printing = 0;  /* asynchronous printing mode off */

    _retni(NORMAL);
  }
  else
    _retni(INVP);
}
