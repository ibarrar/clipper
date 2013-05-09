/*****************************************************************************
  MPEX_2F.H

  Header file containing declarations and definitions necessary for accessing
  PFL_COM's Multiplex (INT 2FH) functions.
  
  rnr  5-2-95
*****************************************************************************/ 

/* Function prototypes */
int check_pfl_com(void);
void read_dev_id(int *com1_id, int *com2_id, int *com3_id, int *com4_id);
void read_com_parm(int port, int *dev_id, int *setup, int *protocol);
void store_com_parm(int port, int dev_id, int setup, int protocol);
