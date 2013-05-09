/*******************************************************************************
*  HMODEM.CH - MODEM.LIB header file                                           *
*******************************************************************************/

/* file transfer constants */
#define XMODEM 1
#define XMODEM1K 2
#define YMODEM 3
#define YMODEMG 4

/* data format constants */
#define P8N1 1    /* 8 data bits, no parity, 1 stop bit */
#define P7E1 0    /* 7 data bits, even parity, 1 stop bit */

/* ERRORs */
#define PORT_FAILED     1
#define DIAL_FAILED     2
#define UPLOAD_FAILED   3
#define LOW_MEM         4
#define FILE_NOT_FOUND  6
#define INIT_FAILED     7
