*
* System......... POWERPOS for Spectrum
* Program I.D.... DEV_END.prg
* Description.... Closes all POS devices and disables async mode
*

#include "printctl.ch"
#include "pfl_clip.ch"
#include "powerpos.ch"
#include "config.ch"
#include "message.ch"

function power_end()
// close cntrl file
NVR_off()

// close the terminal file
Term_off()

// close if open offline 
offl_close()

// close all btrieve files
faccess_close()

// close graphics...
//
#ifdef DEF_GRAPHICS
  gGraphClos()
#endif

DISPTEXTXY(2, 1, 0, 0, 1, 1, MSG_D032)
DISPTEXTXY(3, 1, 0, 0, 2, 1, MSG_D033)

// disable sound...
//
#ifdef KEY_SOUND
  sound_off()
#endif

// disable asynchronous scanning...
// check if use scanner is YES...
//
if config(POS_SCANNER) == "YES"
   A_SCAN_OFF()
endif

// disable asynchronous mode...
//
A_PRNT_OFF()

// close the POS devices whether initialized or not...
//
if config(POS_4X20_DISP) == "YES"
   CLOSE_DEV(POS_CASH_DISP)
endif
if config(POS_1X09_DISP) == "YES"
   CLOSE_DEV(POS_CUST_DISP1)
endif
if config(POS_2X20_DISP) == "YES"
   DISPTEXTXY (0, 0, 0, 0, 1, 1, MSG_0004)   
   DISPTEXTXY (0, 0, 0, 0, 2, 1, padc("CLOSED",20))
   CLOSE_DEV(POS_CUST_DISP2)
endif   
if config(POS_RETAILKEY) == "YES"
   CLOSE_DEV(POS_KEYBOARD)
endif
if config(POS_SCANNER) == "YES"
   CLOSE_DEV(POS_SCAN)
endif   
if config(POS_REC_PRINT) == "YES" .or. config(POS_JRN_PRINT) == "YES" .or. config(POS_VAL_PRINT) == "YES"
   CLOSE_DEV(POS_PRINTER)
endif
if config(POS_CASH_DRAWER) == "YES"
   CLOSE_DEV(POS_CASH_DRAW)
endif   

   CLOSE_DEV(POS_CKEYLOCK)
   CLOSE_DEV(POS_CARD_READ)
   
return nil
