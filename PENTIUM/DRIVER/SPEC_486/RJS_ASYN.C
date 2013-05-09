/*****************************************************************************
  RJS_ASYN.C

  Syntax:
  
    void RJS_ASYN(void) 

  Parameters:

    None.
    
  Description:

    RJS_ASYN() calls the requested print function.

    a. Rjs_Asyn1() - A_RJS_PRNT()
    b. Rjs_Asyn2() - A_RJS_FEED()
    c. Rjs_Asyn3() - A_PRT_ESC()

    RJS_ASYN() is called from PRNTASYN.ASM.             
        
  Return values:

    The actual print job status is returned in the global variable print_status.
  
  
  rnr  6-27-94
  rnr  5-15-95
*****************************************************************************/
#include "pcr_ext.h"

/* EXTERNAL DEFINITIONS */
extern RJS_DATA1 prnt_data1[PRINT_JOBS];  /* print job buffer */
extern int buff_out1; /* buffer output index */

/* FUNCTION PROTOTYPES */
void rjs_asyn1(void);
void rjs_asyn2(void);
void rjs_asyn3(void);

void rjs_asyn(void)
{
  /* determine the required print function and invoke it */
  switch (prnt_data1[buff_out1].func_type)
  {
    case 0: /* A_RJS_PRNT() */
            rjs_asyn1();
            break;
    case 1: /* A_RJS_FEED() */
            rjs_asyn2();
            break;
    case 2: /* A_PRT_ESC() */
            rjs_asyn3();
            break;
  }
}
