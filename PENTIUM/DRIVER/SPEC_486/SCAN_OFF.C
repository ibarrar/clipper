/*****************************************************************************
  SCAN_OFF.C

  Syntax:
  
    A_SCAN_OFF() 

  Parameters:

    No parameters.

  Description:

    A_SCAN_OFF() disables asynchronous scanning. 

    This function must be called before terminating the application.

  Return values:

    NORMAL         - Normal operation
    INVP           - Invalid parameter or invalid command

    See header file - PFL_CLIP.CH for details.    

  rnr  6-9-95
*****************************************************************************/
/* #include <stdio.h> */
#include "extend.h"
#include "pcr_ext.h"
#include "pfl_scan.h"
#include "pfl_clip.ch"

/* EXTERNAL DEFINITIONS */
extern int async_scan; /* flag that indicates the asynchronous scanning mode */

CLIPPER a_scan_off(void)
{
  /* validate parameters */
  if (PCOUNT == 0)  /* no argument is passed */  
  {
    if (!async_scan)  /* not in asynchronous scanning mode */
    {
      _retni(INVP);
      return;
    }

    /* disable asynchronous scanning */
    asyn_scan_off();

    async_scan = 0;  /* asynchronous scanning mode - off */

    _retni(NORMAL);
  }
  else
    _retni(INVP);
}
