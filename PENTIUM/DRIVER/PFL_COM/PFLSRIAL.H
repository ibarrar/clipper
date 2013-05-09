/*****************************************************************************
  PFLSRIAL.H 

  Header file containing declarations and definitions necessary for the
  PFL Serial port interface routines.
  
  rnr  4-24-95
*****************************************************************************/ 

/* COM ports */
#define PFL_COM1  0
#define PFL_COM2  1
#define PFL_COM3  2
#define PFL_COM4  3

/* serial port base address */
#define PFL_COM1_ADDRS  0x3f8
#define PFL_COM2_ADDRS  0x2f8
#define PFL_COM3_ADDRS  0x3e8
#define PFL_COM4_ADDRS  0x2e8

/* Stop bits */
#define SB_1  0     /* 1 bit */
#define SB_2  4     /* 2 bits */

/* Data bits */
#define DB_7  2     /* 7 bits */
#define DB_8  3     /* 8 bits */

/* Bit Rate constants */
enum bit_rate { BR_110   = 0x00, 
                BR_150   = 0x20, 
                BR_300   = 0x40, 
                BR_600   = 0x60,
                BR_1200  = 0x80, 
                BR_2400  = 0xa0, 
                BR_4800  = 0xd0, 
                BR_9600  = 0xe0, 
                BR_19200 = 0x1e0, 
                BR_38400 = 0x2e0 };

/* Parity bit */
enum parity_bit { P_NONE = 0, P_ODD = 0x08, P_EVEN = 0x18 };

/* Handshaking protocol */
#define H_NONE     0         /* none */
#define H_DTR_RTS  1         /* DTR/RTS */
#define H_DTR      2         /* DTR only */
#define H_RTS      3         /* RTS only */

/* Function prototypes */
int pfl_com_init(int port_no, int setup, unsigned char protocol);
int pfl_com_port(int port_no);
int pfl_com_send(unsigned char byte_data);
int pfl_com_sendp(int port, unsigned char byte_data);
int pfl_com_sendb(int base_addrs, unsigned char byte_data);
int pfl_com_nsend(unsigned char *byte_data, int len);
int pfl_com_nsendp(int port, unsigned char *byte_data, int len);
int pfl_com_nsendb(int base_addrs, unsigned char *byte_data, int len);
int pfl_com_brecv(int port_no);
int pfl_com_drecv(void);
int pfl_com_drecvp(int port_no);
int pfl_com_drecvb(int base_addrs);
int pfl_com_sts(int port_no);
int pfl_com_dsts(int base_addrs);
int pfl_com_ndsts(int base_addrs);
int pfl_com_rmcr(int base_addrs);
int pfl_com_wmcr_or(int base_addrs, int or_bits);
int pfl_com_wmcr_and(int base_addrs, int and_bits);
