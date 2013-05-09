/****************************************************************************
  GETKCODE.C - includes the function GET_KCODE() & SET_KSOUND().

  Syntax:

    GET_KCODE()

  Parameters:

    No parameters.

  Description:

    GET_KCODE() returns the scan code of the keystroke. This function is
    used synchronously.

    A prior call to SETALL_DEV() or SET_DEV() is needed to initialize 
    the POS Keyboard. 

  Return values:

    If an error occurs in reading a keystroke, GET_KCODE() returns negative 
    one (-1). Otherwise, the return value is the scan code.

  rnr  5-17-95
*****************************************************************************/
#include "extend.h"
#include "pcr_ext.h"
#include "pfl_clip.ch"

/* External definitions */
extern unsigned int frqwency;  /* frequency in Hertz */
extern unsigned int delay_cnt;  /* delay count in milliseconds */
extern unsigned int msec_cnt;  /* delay count in ms */

/****************************************************************************
  Syntax:

    SET_KSOUND( <frequency>, <delay> )

  Parameters:

    <frequency> - a numeric value that specifies the frequency of sound
                  in Hertz, produced by pressing a key. A zero (0) value
                  turns off the keyboard tone.

                  Values passed should be in the range, 0-65535.
                  
    <delay>     - a numeric value that specifies the duration of the keyboard
                  tone in milliseconds.

                  Values passed should be in the range, 0-65535.
                  
  Description:

    SET_KSOUND() produces the keyboard tone specified by <frequency> in Hertz,
    with a duration (<delay>) in milliseconds.

    A prior call to SOUND_ON() is required, to activate the keyboard sound.

  Return values:
    
    NORMAL         - Normal operation
    INVP           - Invalid parameter or invalid command

    See header file - PFL_CLIP.CH for details.
    
  rnr  2-15-94
*****************************************************************************/

#define ONE_MSEC  263  /* 263 microseconds == 1 ms */

/* parameter constants */
enum arguments {D_FRQNCY=1, D_DELAY};

CLIPPER set_ksound(void)
{
  long int frequency, delay;
  
  /* validate parameters */
  if (PCOUNT == 2 && ISNUM(D_FRQNCY) && ISNUM(D_DELAY))
  {
    frequency = _parnl(D_FRQNCY);  /* get the frequency */
    delay = _parnl(D_DELAY);  /* get the duration */

    /* assign to the static global variables */
    if (frequency < 0L || frequency > 65535L)
      frequency = 0L;

    if (delay < 0L || delay > 65535L)
      delay = 0L;

    frqwency = (unsigned int) frequency;
    delay_cnt = (unsigned int) (delay * ONE_MSEC);  /* in microseconds */
    msec_cnt = (unsigned int) delay;  /* in ms */

    _retni(NORMAL);
  }
  else
    _retni(INVP);
}
