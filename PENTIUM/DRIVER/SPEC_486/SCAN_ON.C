/*****************************************************************************
  SCAN_ON.C

  Syntax:
  
    A_SCAN_ON( <label_size>, <end_char>, <default_IRQ> ) 

  Parameters:

    <label_size>  - a numeric argument that specifies the maximum no. of
                    labels to be buffered. Values passed must be from
                    1 to 10.

    <end_char>    - a numeric argument that specifies the ASCII code of
                    the bar code suffix character, used for terminating the
                    label.

    <default_IRQ> - a numeric flag that indicates if the default IRQ no
                    is to be used for the specified ports.
                    
                    If <default_IRQ> is 1, the following table
                    describes the IRQ no used by a port:
                                
                    Port      IRQ no 

                    COM1       4
                    COM2       3
                    COM3       4
                    COM4       3

                    If <default_IRQ> is 0, the following table
                    describes the IRQ no used by a port:
                               
                    Port      IRQ no 

                    COM1       4
                    COM2       3
                    COM3       10
                    COM4       11            
                    
  Description:

    A_SCAN_ON() enables asynchronous scanning of labels. This function is 
    called prior to the use of READDEVICE(), if scanner input is needed.

  Return values:

    NORMAL         - Normal operation
    DEV_NOT_EXIST  - Device not initialized
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
extern POS_TABLE pos_setup[];
extern int async_scan; /* flag that indicates the asynchronous scanning mode */
extern int s_buff_size;  /* maximum no of labels to be buffered */
extern int s_end_char;  /* terminating character */
extern int s_dflt_irq;  /* default IRQ flag */

/* parameter constants */
enum arguments {MAX_BUFF_LABEL=1, SUFX_CHAR, USE_DFLT_IRQ};

CLIPPER a_scan_on(void)
{
  int buff_size;  /* maximum no of labels to be buffered */
  int end_char;  /* terminating character */
  int dflt_irq;  /* default IRQ flag */
  
  /* validate parameters */
  if (PCOUNT == 3 && ISNUM(MAX_BUFF_LABEL) && ISNUM(SUFX_CHAR)
                  && ISNUM(USE_DFLT_IRQ)) 
  {
    if (async_scan)  /* already in asynchronous scanning mode */
    {
      _retni(INVP);
      return;
    }

    /* get label size and validate it */
    buff_size = _parni(MAX_BUFF_LABEL);

    if (NOT_IN_RANGE(buff_size, 1, 10))
    {
      _retni(INVP);
      return;
    }

    /* get end character */
    end_char = _parni(SUFX_CHAR);

    /* get default IRQ flag */
    dflt_irq = _parni(USE_DFLT_IRQ);    
    
    if (NOT_IN_RANGE(dflt_irq, 0, 1))
    {
      _retni(INVP);
      return;
    }
    
    /* verify initial status */
    /*if (chk_init_flag(POS_SCAN) == 0)
    {
      _retni(DEV_NOT_EXIST);   
      return;
    } aea*/    /* device not yet initialized */

    /* save a copy for the global variables */
    s_buff_size = buff_size;
    s_end_char = end_char;
    s_dflt_irq = dflt_irq;
    
    /* enable asynchronous scanning */
    asyn_scan_on(buff_size, (unsigned char) end_char, dflt_irq, 
                 pos_setup[POS_SCAN].port+1, pos_setup[POS_SCAN].base_addrs,
                 pos_setup[POS_SCAN].setup, (unsigned char) pos_setup[POS_SCAN].protocol);

    async_scan = 1;  

    _retni(NORMAL);
  }
  else
    _retni(INVP);
}
