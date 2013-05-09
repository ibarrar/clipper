/*****************************************************************************
  PFL_SCAN.H

  Header file containing declarations and definitions necessary for the
  PFL Scanner interface routines.
  
  rnr  6-9-95
*****************************************************************************/

/* Function prototypes */
void asyn_scan_on(int label_size, unsigned char end_char, int default_irq,
                  int port_no, int base_addrs, int setup, unsigned char protocol);
void asyn_scan_off(void);
void pfl_scan_clear(void);
int pfl_get_label(char *byte_data);
int pfl_get_tlabel(char *byte_data);
int pfl_asyn_read(int *word_data, int len);
int pfl_asyn_tread(int *word_data, int len);
int pfl_key_twgeta(int *word_data, int len);
void set_rddev_idle(unsigned int tm_out_ticks);
