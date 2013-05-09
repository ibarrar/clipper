/*****************************************************************************
  PFL_KEY2.H

  Header file containing declarations and definitions necessary for the
  POS Keyboard interface routines.
  
  rnr  5-17-95
*****************************************************************************/

/* Function prototypes */
void pfl_key_clear(void);
int pfl_key_geta(int *word_data, int len);
int pfl_key_wgeta(int *word_data, int len);
int pfl_key_gets(int *word_data, int len);
int pfl_key_wgets(int *word_data, int len);
int pfl_key_getsa(int *word_data, int len);
int pfl_key_wgetsa(int *word_data, int len);
int pfl_rid_klock(void);
