/****************************************************************************
  POS_INIT.C

  Source file containing the preliminary setup or initialization functions.

  1. SET_DEV()
  2. SETALL_DEV()
  3. CLOSE_DEV()

  The following functions act as an interface between the Clipper application
  and the PCR device drivers. These functions are callable from Clipper using
  the Extend System.

  Note: For more information about the PCR device drivers see the POS 3000
        Technical Reference manual.

  rnr  4-11-95
  rci  3-15-97
*****************************************************************************/
#include "pfl_clip.ch"
#include "pcr_Ext.h"
#include "pflsrial.h"
#include "pfl_key2.h"
#include "pfl_lpt.h"
#include "klck_fix.h"
#include "extend.h"

#define  DEV_NUM            1   /* parameter constant for device number */
#define  NONE              ""
#define  TRUE               1
#define  FALSE              0

#define  OPEN_FLAGS         FO_WRITE
#define  PFL_LPT2           1



/* GLOBAL VARIABLES */

volatile POS_TABLE pos_setup[] =
{
  { 1, "LPT2" , TRUE , FALSE, -1, -1, -1, -1, -1, PFL_LPT2 },  /* POS printer */ 
  { 3, NONE   , TRUE , FALSE, -1, -1, -1, -1, -1, -1 },  /* cash drawer */
  { 2, "KEY$$", FALSE, FALSE, -1, -1, -1, -1, -1, -1 },  /* magnetic card reader */
  { 2, "KEY$$", TRUE , FALSE, -1, -1, -1, -1, -1, -1 },  /* POS keyboard */ 
  { 2, "KEY$$", TRUE , FALSE, -1, -1, -1, -1, -1, -1 },  /* POS Central Keylock */
  { 3, NONE,    TRUE , FALSE, -1, -1, -1, -1, -1, -1 },  /* customer display (additional) */
  { 3, NONE,    TRUE , FALSE, -1, -1, -1, -1, -1, -1 },  /* scanner or optical reader */ 
  { 3, NONE,    TRUE , FALSE, -1, -1, -1, -1, -1, -1 },  /* Optional Slip printer */
#if 1
  { 1, "VFD$$", TRUE , FALSE, -1, -1, -1, -1, -1, -1 },  /* customer display (integrated) */
  { 1, "LCD$$", TRUE , FALSE, -1, -1, -1, -1, -1, -1 }   /* cashier or operator display */
#endif  
} ;
  


#define NO_OF_DEVICES  sizeof(pos_setup)/sizeof(POS_TABLE)

/* variables used in asynchronous printing */
volatile RJS_DATA1 prnt_data1[PRINT_JOBS];   /* print job buffer */
volatile int print_status;                   /* holds the generic printer status */
volatile int print_active = 0;               /* a flag that indicates that a print job is in progress */
volatile int print_stop = 0;                 /* a value of 1 disables RJ printing; otherwise, a value
                                                of zero enables it */
int buff_in1;                                /* buffer input index */
int buff_out1;                               /* buffer output index */
volatile int async_printing = 0;             /* flag that indicates the asynchronous printing mode */
volatile int buffer_empty = 1;               /* flag that indicates if the print buffer is empty */

/* variables used in asynchronous scanning */
volatile int async_scan = 0;                 /* flag that indicates the asynchronous scanning mode */
int s_buff_size = 1;                         /* maximum no of labels to be buffered */
int s_end_char = 0x0d;                       /* terminating character */
int s_dflt_irq = 1;                          /* default IRQ flag */

/* sound flag */
volatile int sound_active = 0;
volatile int in_sound = 0;                   /* keyboard sound flag */

/* variables used in keyboard tone */
unsigned int frqwency = 2000;                /* frequency in Hertz */
unsigned int delay_cnt = 13107;              /* delay count in microseconds
                                                this is approximately 50 ms */
unsigned int msec_cnt = 50;                  /* delay count in ms */


/* Local functions */

/* device initialization functions */
static int init_method1(int dev_no);
static int init_method2(int dev_no);
static int init_method3(int dev_no);
static int pos_device_chk(int dev_no);

/* device termination functions */
static int close_method1(int dev_no);
static int close_method2(int dev_no);
static int close_method3(int dev_no);

/*****************************************************************************
  Syntax:

    SET_DEV( <device_name> )

  Parameters:

    <device_name> - a numeric value that corresponds to the desired POS device.
                    See symbolic constants defined in PFL_CLIP.CH.
                
  Description:

    SET_DEV() initializes the designated POS device. It returns INVP if the
    designated POS device is not supported.

  Return values:
    
    Returns a numeric value describing the result of the process. 

    NORMAL        - Normal operation
    DEV_EXIST     - Device already initialized
    MEM_OUT       - Not enough space in memory
    DEV_NOT_READY - Device not ready
    HARD_ERR      - General hardware error
    INVP          - Invalid parameter or invalid command    
    NO_DRIVER     - Driver not installed

    See header file - PFL_CLIP.CH for details.
     
  rnr  4-18-95  
*****************************************************************************/

CLIPPER set_dev(void)
{
  int gen_status = NORMAL;       /* generic error codes returned to the application */
  int dev_no;                    /* device no */

  /* validate parameters */
  if (PCOUNT == 1 && ISNUM(DEV_NUM))
  {
    dev_no = _parni(DEV_NUM);    /* get device name */

    /* verify if the requested device is supported */
    if ( dev_no < 0 || dev_no > NO_OF_DEVICES )
    {
      _retni(INVP);              /* device not yet supported */
      return;
    }

    /* verify initial status */
    if ( pos_setup[dev_no].init_flag )
    {
      _retni(DEV_EXIST);   /* device already initialized */
      return;
    }

    /* initialize device */
    switch (pos_setup[dev_no].open_method)  /* determine initialization method */
    {
      case 1: gen_status = init_method1(dev_no);  /* file method */
              break;
      case 2: gen_status = init_method2(dev_no);  /* file method but check existing device(s) */
              break;
      case 3: gen_status = init_method3(dev_no);  /* direct or other method */
              break;
    }

    /* perform additional hardware checking or initialization */
    if (pos_setup[dev_no].device_check && gen_status == NORMAL)
      gen_status = pos_device_chk(dev_no);

    _retni(gen_status);
  }
  else
    _retni(INVP);
}

/*****************************************************************************
  Syntax:

    CLOSE_DEV( <device_name> )

  Parameters:

    <device_name> - a numeric value that corresponds to the desired POS device.
                    See symbolic constants defined in PFL_CLIP.CH.
                
  Description:
    CLOSE_DEV() terminates or closes the communication channel of the
    designated device.

  Return values:
    
    Returns a numeric value describing the result of the process. 

    NORMAL        - Normal operation
    DEV_NOT_EXIST - Device not initialized
    INVP          - Invalid parameter or invalid command    

    See header file - PFL_CLIP.CH for details.
     
  rnr  4-19-94  
*****************************************************************************/
CLIPPER close_dev(void)
{
  int gen_status = NORMAL;       /* generic error codes returned to the application */
  int dev_no;                    /* device no */

  /* validate parameters */
  if (PCOUNT == 1 && ISNUM(DEV_NUM))
  {
    dev_no = _parni(DEV_NUM);    /* get device name */

    /* verify if the requested device is supported */
    if ( dev_no < FALSE ||  dev_no > NO_OF_DEVICES )
    {
      _retni(INVP);              /* device not yet supported */
      return;
    }    

    /* determine termination method */
    switch (pos_setup[dev_no].open_method)  
    {
      case 1: gen_status = close_method1(dev_no);  /* file method */
              break;
      case 2: gen_status = close_method2(dev_no);  /* file method but check existing device(s) */
              break;
      case 3: gen_status = close_method3(dev_no);  /* direct or other method */
              break;
    }    

    _retni(gen_status);
  }
  else
    _retni(INVP);
}

/* device initialization functions */

/*  init_method1(): file method  */
static int init_method1(int dev_no)
{
  FHANDLE dev_handle;           /* device handle */
  int gen_status;               /* generic error codes returned to the application */  

  dev_handle = _fsOpen(pos_setup[dev_no].dev_type, OPEN_FLAGS );

  gen_status = error_map(_fsError());  /* get the generic error status */

  if (gen_status == NORMAL)
    update_table(1, dev_no, dev_handle, -1, -1, -1, -1);  /* update the POS Device table */    

  return gen_status;    
}

/*  init_method2(): file method but check existing devices(s)  */
static int init_method2(int dev_no)
{
  FHANDLE dev_handle;           /* device handle */
  int gen_status;  /* generic error codes returned to the application */  
  int other_dev;   

  gen_status = NORMAL;          /* assume normal status */
  other_dev = dev_no;  
  
  if (pos_setup[dev_no].init_flag)
      gen_status = DEV_EXIST;

  if (gen_status == DEV_EXIST)  /* already initialized */
  {
    /* update the POS Device table */ 
    update_table(1, dev_no, pos_setup[other_dev].file_num, -1, -1, -1, -1);  
    gen_status = NORMAL;    
  }
  else  /* not yet initialized */
  {
    dev_handle = _fsOpen(pos_setup[dev_no].dev_type, OPEN_FLAGS );

    gen_status = error_map(_fsError());  /* get the generic error status */

    if (gen_status == NORMAL)
      update_table(1, dev_no, dev_handle, -1, -1, -1, -1);  /* update the POS Device table */        
  }

  return gen_status;  
}


/*  init_method3(): direct or other method  */
static int init_method3(int dev_no)
{
  int gen_status = NORMAL;  /* generic error codes returned to the application */  

  switch (dev_no)
  {
          case POS_SCAN:    /* added aea */
                         gen_status = open_serial_dev(dev_no);
                         gen_status = NORMAL;
                         break;
    case POS_CUST_DISP2:
    case OPT_SLIP_PRNTR: 
    case POS_CASH_DRAW:  gen_status = open_serial_dev(dev_no);
                         break;
                         
  } 
  
  return gen_status;
}

/*  pos_device_chk: performs additional hardware checking or initialization  */
static int pos_device_chk(int dev_no)
{
  int gen_status;  /* generic error codes returned to the application */  
  unsigned char esc_cmd[12]; /* holds the escape sequence command */
  int port_status;

  gen_status = NORMAL;  /* assume normal */
  switch (dev_no)
  {
#if 1
    case POS_CASH_DISP:  /* cashier or operator display */
      /* clear the screen */
      esc_cmd[0] = ESC_CODE;
      esc_cmd[1] = 'C';
      
      /* cursor off and no blink */
      esc_cmd[2] = ESC_CODE;
      esc_cmd[3] = 'A';
      esc_cmd[4] = 0x01;

      /* set cursor to the leftmost column */
      esc_cmd[5] = ESC_CODE;
      esc_cmd[6] = 'D';
      esc_cmd[7] = 0x00;
      
      /* select overwrite mode 
      esc_cmd[8] = ESC_CODE;
      esc_cmd[9] = 'S';
      esc_cmd[10] = 0x02;      */

      _fsWrite(pos_setup[dev_no].file_num, esc_cmd, 8);
      
      gen_status = error_map(_fsError());

      if (gen_status == NORMAL)
      {
        /* select overwrite mode */
        esc_cmd[0] = ESC_CODE;
        esc_cmd[1] = 'S';
        esc_cmd[2] = 0x02;      

        _fsWrite(pos_setup[dev_no].file_num, esc_cmd, 3);
        gen_status = error_map(_fsError());      
      } 
      
      break;
      
    case POS_CUST_DISP1: /* 1 X 9 integrated customer display */
      /* initialize display */
      esc_cmd[0] = 0x00;
      
      /* clear the screen and set the cursor to the leftmost column */
      esc_cmd[1] = '\n';

      _fsWrite(pos_setup[dev_no].file_num, esc_cmd, 2);
      gen_status = error_map(_fsError());
      break;
#endif
    case POS_CUST_DISP2: /* 2 X 20 customer display (additional) */
      port_status = pfl_com_init(pos_setup[dev_no].port, pos_setup[dev_no].setup,
                                (unsigned char) pos_setup[dev_no].protocol);
             
      if ((port_status & 0x0030) != 0x0030)  /* data set ready & clear to send */
        gen_status = DEV_NOT_READY;

      if (gen_status == NORMAL)
      {
        /* initialize display */ 
        esc_cmd[0] = ESC_CODE;
        esc_cmd[1] = '@';
        
        /* set character set to U.S.A. */
        esc_cmd[2] = ESC_CODE;
        esc_cmd[3] = 'f';
        esc_cmd[4] = 'A';

        /* select font: comply with ASCII code */
        esc_cmd[5] = ESC_CODE;
        esc_cmd[6] = 'c';
        esc_cmd[7] = 'A';

        if (pfl_com_nsend(esc_cmd, 8))
          gen_status = DEV_NOT_READY;

        delay(50);  /* put some delay */
        
        /* specify overwrite mode */
        esc_cmd[0] = ESC_CODE;
        esc_cmd[1] = 0x11;

        /* move the cursor to the leftmost position on the upper line 
        esc_cmd[2] = ESC_CODE;
        esc_cmd[3] = '[';
        esc_cmd[4] = 'H'; */

        if (pfl_com_nsend(esc_cmd, 2))
          gen_status = DEV_NOT_READY;

        delay(500);  /* put some delay */

        /* clear display screen */
        esc_cmd[0] = 0x0c;        

        if (pfl_com_send(esc_cmd[0]))
          gen_status = DEV_NOT_READY;          

        delay(500);
      }
      break;

    case OPT_SLIP_PRNTR: /* optional slip printer */
      port_status = pfl_com_init(pos_setup[dev_no].port, pos_setup[dev_no].setup,
                                (unsigned char) pos_setup[dev_no].protocol);
      /* check printer status: see corresponding printer manual for verifying the printer status */
      esc_cmd[0] = ESC_CODE;
      esc_cmd[1] = 0x76;
      pfl_com_nsend(esc_cmd, 2);
      
      if (pfl_com_drecv() == -1)  /* cannot retrieve the status */
        gen_status = DEV_NOT_READY;
      
      break;

    case POS_SCAN:  /* scanner or optical reader */
      port_status = pfl_com_init(pos_setup[dev_no].port, pos_setup[dev_no].setup,
                                (unsigned char) pos_setup[dev_no].protocol);
      /*if (!(port_status & 0x0020))   */  /* data set ready ? */
      /*   gen_status = DEV_NOT_READY; */   /* scanner not ready */
       gen_status = NORMAL;
      break;

    case POS_CASH_DRAW: /* cash drawer */            
      port_status = pfl_com_init(pos_setup[dev_no].port, pos_setup[dev_no].setup,
                                (unsigned char) pos_setup[dev_no].protocol);
        
      if (!(port_status & 0x0010))  /* not clear to send */
          gen_status = DEV_NOT_READY;
          
      break;  
    case POS_PRINTER: /* POS RJS printer */
      /* set paper end signal to journal printer */

      esc_cmd[0] = ESC_CODE;
      esc_cmd[1] = 'c';
      esc_cmd[2] = '3';
      esc_cmd[3] = 1;        

      pfl_lpt_nsend(pos_setup[dev_no].lpt_port, esc_cmd, 4);          
      
      delay(50);  /* put some delay */
      
      port_status = pfl_lpt_sts(pos_setup[dev_no].lpt_port);
      
      /* timeout, I/O error, out of paper, busy, and not selected status */
      if ((port_status & 0x29) || !(port_status & 0x80) || !(port_status & 0x10))
        gen_status = DEV_NOT_READY;

      break;

    case POS_KEYBOARD:
      pfl_key_clear(); /* clear POS keyboard buffer */

      break;

    case POS_CKEYLOCK:
      if (!check_pfl_klck())  /* PFL_KLCK.COM not installed */
        gen_status = NO_DRIVER;
      
      break;
  }

  if (gen_status != NORMAL)  /* update the POS Device table */
  {
    if (pos_setup[dev_no].open_method == 1)  /* device opened as a file */
      _fsClose(pos_setup[dev_no].file_num);            
    else if (pos_setup[dev_no].open_method == 2)  /* file method but linked to
                                                     other devices */
      close_link_dev(dev_no);                                                     
      
    update_table(0, dev_no, -1, -1, -1, -1, -1);  /* update the POS Device table */          
  }
    
  return gen_status;
}

/* device termination functions */

/*  int close_method1(): file method  */
static int close_method1(int dev_no)
{
  int gen_status;  /* generic error codes returned to the application */

  _fsClose(pos_setup[dev_no].file_num);

  gen_status = error_map(_fsError());  /* get the generic error status */

  if (gen_status == NORMAL)
    update_table(0, dev_no, -1, -1, -1, -1, -1);  /* update the POS Device table */

  return gen_status;
}

/*  close_method2(): file method but check existing devices(s)  */
static int close_method2(int dev_no)
{
  int gen_status;  /* generic error codes returned to the application */
  int other_dev;

  other_dev = 0;
  gen_status = NORMAL;  /* assume normal status */

   
  switch (dev_no)
  {
     case POS_KEYBOARD: 
     case POS_CARD_READ:
     case POS_CKEYLOCK: /* check existing devices */
                        if (chk_init_flag(POS_CARD_READ))  /* card reader */
                          ++other_dev;  

                        if (chk_init_flag(POS_CKEYLOCK))  /* keylock */
                          ++other_dev;

                        if (chk_init_flag(POS_KEYBOARD))  /* POS keyboard */
                          ++other_dev;

                        break;
                    
  }  

  if (other_dev > 1)  /* link to other devices */
    update_table(0, dev_no, -1, -1, -1, -1, -1);  /* update the POS Device table */ 
  else  
  {
    _fsClose(pos_setup[dev_no].file_num);

    gen_status = error_map(_fsError());  /* get the generic error status */

    if (gen_status == NORMAL)
      update_table(0, dev_no, -1, -1, -1, -1, -1);  /* update the POS Device table */
  }

  return gen_status;
}

/*  close_method3(): direct or other method  */
static int close_method3(int dev_no)
{

  update_table(0, dev_no, -1, -1, -1, -1, -1);

  return NORMAL;  /* for the meantime */
		  /* up to this time rci 3-15-97 */
}

int chk_init_flag(int device_no)
{
 return  ( pos_setup[device_no].init_flag ) ;
}
