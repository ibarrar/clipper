/*****************************************************************************
  SOUND_ON.C

  Syntax:
  
    SOUND_ON() 

  Parameters:

    No parameters.

  Description:

    SOUND_ON() turns on the keyboard sound. 

  Return values:

    NORMAL         - Normal operation
    INVP           - Invalid parameter or invalid command

    See header file - PFL_CLIP.CH for details.    

  rnr  5-17-95
*****************************************************************************/
#include "extend.h"
#include "pcr_ext.h"
#include "pfl_clip.ch"

/* EXTERNAL DEFINITIONS */
extern int in_sound; /* keyboard sound flag */

CLIPPER sound_on(void)
{
  /* validate parameters */
  if (PCOUNT == 0)  /* no argument is passed */  
  {
    if (in_sound)  /* sound is already hooked */
    {
      _retni(INVP);
      return;
    }

    hook_keytone();

    in_sound = 1; 
    
    _retni(NORMAL);
  }
  else
    _retni(INVP);
}
