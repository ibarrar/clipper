/****************************************************************************
  CHKCKLCK.C

  Syntax:

    CHK_CKLOCK( <cklock_pos> )

  Parameters:

    <cklock_pos> - a numeric argument that returns the central keylock position 
                   on exit from this function. This argument must always be passed 
                   by reference (@).
    
  Description:

    CHK_CKLOCK() checks and returns the current central keylock position. This
    function is used synchronously. 

    Any previous keyboard and scanner input is discarded after using this 
    function.

  Return values:
    
    Returns a numeric value describing the result of the process.

    NORMAL        - Normal operation
    DEV_NOT_READY - Device not ready
    DEV_NOT_EXIST - Device not initialized
    READ_ERR      - Read operation error
    INVP          - Invalid parameter or invalid command
    
    See header file - PFL_CLIP.CH for details.

  Note:
  This function acts as an interface between the Clipper application and the
  PCR device drivers. This function is callable from Clipper using the
  Extend System.
  
  For more information about the PCR device drivers see the POS 3000
  Technical Reference manual.

  rnr  5-18-95
*****************************************************************************/
#include "extend.h"
#include "pcr_ext.h"
#include "pfl_key2.h"
#include "pfl_scan.h"
#include "klck_fix.h"
#include "pfl_clip.ch"

/* parameter constants */
#define CKLOCK_POS 1

/* External definitions */
extern POS_TABLE pos_setup[];
extern int async_scan; /* flag that indicates the asynchronous scanning mode */
extern int in_sound;  /* keyboard sound flag */
extern int s_buff_size;  /* maximum no of labels to be buffered */
extern int s_end_char;  /* terminating character */
extern int s_dflt_irq;  /* default IRQ flag */

CLIPPER chk_cklock(void)
{
  int switch_pos1;  /* holds the central keylock position status */

  /* validate parameters */
  if (PCOUNT == 1 && ISNUM(CKLOCK_POS) && ISBYREF(CKLOCK_POS)) 
  {
    /* verify initial status */
    if (chk_init_flag(POS_CKEYLOCK) == 0)
    {
      _retni(DEV_NOT_EXIST);   /* device not yet initialized */
      return;
    }

   /*   pfl_scan_clear();   clear scanner input buffer */

#ifdef KEY_SOUND_ENABLED    
    if (in_sound) /* keyboard sound is enabled */
      unhook_keytone(); /* disable it temporarily */
#endif      
      
    /* pfl_key_clear(); */ /* clear keyboard input buffer */
    
    /* read keylock position */
    switch_pos1 = pfl_rid_klock();
    
    /* verify the keylock position returned */
    if (switch_pos1 == -1 || NOT_IN_RANGE(switch_pos1, 2, 6))
    {
    
#ifdef KEY_SOUND_ENABLED    
      /* pfl_key_clear(); */ /* clear keyboard input buffer */
      if (in_sound)  /* keyboard sound is enabled */
        hook_keytone();  /* enable it again */                
#endif        

    /*      pfl_scan_clear();   clear scanner input buffer */      
      
      _retni(READ_ERR);
      return;
    }    

    switch_pos1 &= 0x000f;  /* get the ASCII code */
    
    switch_pos1 -= 2;  /* minus 2 */

    _storni(switch_pos1, CKLOCK_POS);     

#ifdef KEY_SOUND_ENABLED
    /* pfl_key_clear(); */ /* clear keyboard input buffer */
    if (in_sound)  /* keyboard sound is enabled */
      hook_keytone();  /* enable it again */                
#endif      

    /*   pfl_scan_clear();  clear scanner input buffer */      
      
    _retni(NORMAL); 
  }
  else
    _retni(INVP);
}
                       
