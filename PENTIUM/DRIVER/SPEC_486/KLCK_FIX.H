/*****************************************************************************
  KLCK_FIX.H

  Header file containing declarations and definitions necessary for accessing
  PFL_KLCK's Multiplex (INT 2FH) functions.
  
  rnr  6-26-95
*****************************************************************************/ 

/* Function prototypes */
int check_pfl_klck(void);
void klck_fix_on(void);
void klck_fix_off(void);
void klck_stuff(void);
