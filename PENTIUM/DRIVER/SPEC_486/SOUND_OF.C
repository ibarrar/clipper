/*****************************************************************************
  SOUND_OF.C

  Syntax:
  
    SOUND_OFF() 

  Parameters:

    No parameters.

  Description:

    SOUND_OFF() turns off the keyboard sound.

  Return values:

    NORMAL         - Normal operation
    INVP           - Invalid parameter or invalid command

    See header file - PFL_CLIP.CH for details.    

  rnr  5-17-95
/*****************************************************************************/
#include "extend.h"
#include "pcr_ext.h"
#include "pfl_clip.ch"

/* EXTERNAL DEFINITIONS */
extern int in_sound; /* keyboard sound flag */

CLIPPER sound_off(void)
{
  /* validate parameters */
  if (PCOUNT == 0)  /* no argument is passed */  
  {
    if (!in_sound)  
    {
      _retni(INVP);
      return;
    }
    
    unhook_keytone();

    in_sound = 0; 
    
    _retni(NORMAL);
  }
  else
    _retni(INVP);
}
