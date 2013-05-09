/*****************************************************************************
  PFL_LPT.H

  Header file containing declarations and definitions necessary for the
  PFL Parallel port interface routines.
  
  rnr  5-9-95
*****************************************************************************/

/* Parallel ports */
#define PFL_LPT1  0
#define PFL_LPT2  1
#define PFL_LPT3  2
#define PFL_LPT4  3

/* Status bit masks */
#define LPT_TIMEOUT      0x01
#define LPT_IOERROR      0x08
#define LPT_SELECTED     0x10
#define LPT_NOPAPER      0x20
#define LPT_ACKNOWLEDGE  0x40
#define LPT_NOTBUSY      0x80

/* Function prototypes */
int pfl_lpt_init(int port_no);
int pfl_lpt_send(int port_no, unsigned char byte_data);
int pfl_lpt_nsend(int port, unsigned char *byte_data, int len);
int pfl_lpt_sts(int port_no);
