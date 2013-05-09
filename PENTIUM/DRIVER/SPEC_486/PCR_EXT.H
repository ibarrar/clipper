/*****************************************************************************
  PCR_EXT.H

  Header file containing declarations and definitions necessary for the 
  Clipper Extend System of the PCR device driver functions.
  
  rnr  4-11-95
*****************************************************************************/
#include <filesys.api>

#define IS_CELL_NUMBER(n, ndex)   (_parinfa((n), (ndex)) & NUMERIC)
#define ESC_CODE          0x1b
#define NOT_IN_RANGE(x, min, max)  ((x) < (min) || (x) > (max))
#define PRINT_JOBS        400  /* no. of print jobs */
#define KEY_SCANS          12  /* no. of keyboard scan codes */
#define MAX_TDEV           31  /* maximum target device */
#define KEY_SOUND_ENABLED   1

/* Structure declaration */
typedef struct
{
  unsigned char open_method;    /* device initialization method:
               1 - open as a file (file method)
               2 - file method but check existing device(s)
               3 - direct or other method */
  char *dev_type;               /* device type: device name for file method */
  unsigned char device_check;   /* performs additional hardware checking or
               initialization
               0 - not required
               Non-Zero value - required */

  unsigned char init_flag;      /* initialization status
               0 - not yet initialized
               1 - already initialized */

  FHANDLE file_num;                 /* file number or file handle */
  int port;                     /* serial port no */
  int setup;                    /* serial port communication parameters */
  int protocol;                 /* handshaking protocol */
  int base_addrs;               /* serial port base address */
  int lpt_port;                 /* parallel port no */

} POS_TABLE;


typedef struct
{
  int func_type;               /* function type: print job from
                                  0 - A_RJS_PRNT()
                                  1 - A_RJS_FEED()
                                  2 - A_PRT_ESC()   */
  unsigned char printer_type;  /* bit assignments for print station */      
  int line_flag;               /* line feed flag */
  unsigned int text_len;       /* length of print data */
  int no_lfeed;                /* number of line feeds */
  char txt_msg[81];            /* print data */
} RJS_DATA1;                   /* print job record */

/* Support routines */
int chk_init_flag(int device_no);
int error_map(int pcr_status);
void update_table(char open, int device_no, FHANDLE file_no, int port, int setup, int protocol, int base_addrs);
int get_paper_sts(unsigned char printer_type, unsigned char paper_sts);
int send_print_cmd(char *esc_cmd, int len);
int set_disp_cursor(int device_no, int row, int col);
int clr_disp(int device_no);
int del_line(int device_no, int row);
int open_serial_dev(int dev_no);
void asyn_prnt_on(void);
void asyn_prnt_off(void);
void hook_keytone(void);
void unhook_keytone(void);
void close_link_dev(int dev_no);

/* objects taken from Turbo C++ */
void sound(unsigned int frequency);
void nosound(void);
void delay(unsigned int ms);
