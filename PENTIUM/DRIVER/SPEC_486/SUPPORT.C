/****************************************************************************
  SUPPORT.C

  Support routines for the Clipper Extend System of the PCR device driver
  functions.

  rnr  4-17-95
*****************************************************************************/
#include "pcr_ext.h"
#include "pflsrial.h"
#include "mpex_2f.h"
#include "pfl_clip.ch"


/* External definitions */
extern POS_TABLE pos_setup[];

/*  error_map: maps the DOS error code to the generic error status 
               that is returned to the application  */
int error_map(int pcr_status)
{
  int gen_status = NORMAL;
  
  switch (pcr_status)  /* DOS error code */
  {   
      case 0: break;
      case 1: gen_status = INVP;   /* invalid function */
              break;
      case 2: gen_status = NO_DRIVER;  /* file not found or file does not exist */
              break;
      case 4: /* too many open files */
      case 8: /* not enough memory */
              gen_status = MEM_OUT;
              break;
      case 5: gen_status = DEV_NOT_READY;  /* access denied */
              break;
      case 6: gen_status = DEV_NOT_EXIST;  /* invalid handle */
              break;
     default: gen_status = DEV_NOT_READY;  /* for the meantime */
              break;
  }

  return gen_status;
}

/*  update_table: updates the POS Device table  */
void update_table(char open, int device_no, FHANDLE file_no, int port, int setup, int protocol, int base_addrs)
{
  if (open)  /* open mode */
    pos_setup[device_no].init_flag = 1;         /* set init flag */
    
  pos_setup[device_no].file_num = file_no;      /* save file no */
  pos_setup[device_no].port = port;             /* set serial port */
  pos_setup[device_no].setup = setup;           /* set communication settings */
  pos_setup[device_no].protocol = protocol;     /* set protocol */    
  pos_setup[device_no].base_addrs = base_addrs; /* set serial port base address */
}  

/*  set_disp_cursor: sets the cursor position for the corresponding display  */

int set_disp_cursor(int device_no, int row, int col)
{
  unsigned char esc_cmd[11]; /* holds the escape sequence command */
  int len = 0, status;
  static unsigned char lcd_pos[4][20] = /* cashier or operator display cell position */
    {{0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09,  /* Line 1 */
      0x0a, 0x0b, 0x0c, 0x0d, 0x0e, 0x0f, 0x10, 0x11, 0x12, 0x13},
     {0x40, 0x41, 0x42, 0x43, 0x44, 0x45, 0x46, 0x47, 0x48, 0x49,  /* Line 2 */
      0x4a, 0x4b, 0x4c, 0x4d, 0x4e, 0x4f, 0x50, 0x51, 0x52, 0x53},
     {0x14, 0x15, 0x16, 0x17, 0x18, 0x19, 0x1a, 0x1b, 0x1c, 0x1d,  /* Line 3 */
      0x1e, 0x1f, 0x20, 0x21, 0x22, 0x23, 0x24, 0x25, 0x26, 0x27}, 
     {0x54, 0x55, 0x56, 0x57, 0x58, 0x59, 0x5a, 0x5b, 0x5c, 0x5d,  /* Line 4 */
      0x5e, 0x5f, 0x60, 0x61, 0x62, 0x63, 0x64, 0x65, 0x66, 0x67}};

  /* set escape sequence command */
  switch (device_no)
  {
     case POS_CASH_DISP: esc_cmd[0] = ESC_CODE;
                         esc_cmd[1] = 'D';
                         esc_cmd[2] = lcd_pos[row-1][col-1];
                         len = 3;
                         break;
                         
    case POS_CUST_DISP1: esc_cmd[0] = 0x10;
                         esc_cmd[0] |= (unsigned char) (col-1);
                         len = 1;
                         break;
                         
    case POS_CUST_DISP2: esc_cmd[0] = ESC_CODE;
                         esc_cmd[1] = 'l';
                         esc_cmd[2] = (unsigned char) col;
                         esc_cmd[3] = (unsigned char) row;
                         len = 4;
                         break;
  }

  status = NORMAL;
  
  /* output the corresponding command */
  switch (device_no)
  {
    case POS_CASH_DISP:    
    case POS_CUST_DISP1: 
           _fsWrite(pos_setup[device_no].file_num, esc_cmd, len);
           status = error_map(_fsError());
           break;
                        
    case POS_CUST_DISP2: if (pfl_com_nsendb(pos_setup[device_no].base_addrs, esc_cmd, len))
                           status = DEV_NOT_READY;
                         break;
  }  

  return status;
}

/*  clr_disp: clears the entire screen of the corresponding display  */  
int clr_disp(int device_no)
{
  unsigned char esc_cmd[5]; /* holds the escape sequence command */
  int status, len;

  /* set escape sequence command */
  switch (device_no)
  {
     case POS_CASH_DISP: esc_cmd[0] = ESC_CODE;
                         esc_cmd[1] = 'C';
                         len = 2;
                         break;
                        
    case POS_CUST_DISP1: esc_cmd[0] = '\n';
                         len = 1;
                         break;
                        
    case POS_CUST_DISP2: esc_cmd[0] = 0x0c;
                         break;
  }

  status = NORMAL;  
  /* output the corresponding command */
  switch (device_no)
  {
     case POS_CASH_DISP:
     case POS_CUST_DISP1:
             _fsWrite(pos_setup[device_no].file_num, esc_cmd, len);
             status = error_map(_fsError());
             break;
                     
     case POS_CUST_DISP2: if (pfl_com_sendb(pos_setup[device_no].base_addrs, esc_cmd[0]))
                           status = DEV_NOT_READY;
                         break;
  }
  
  return status;
}  

/*  del_line: deletes a line from the corresponding display  */
int del_line(int device_no, int row)
{
  unsigned char esc_cmd[5]; /* holds the escape sequence command */
  int status, len=0;
  char *space_char = "                    ";

  /* set cursor position to the leftmost column of the selected line # */
  if ((status = set_disp_cursor(device_no, row, 1)) == NORMAL)
  {
    /* set escape sequence command */
    switch (device_no)
    {
       case POS_CASH_DISP:
      case POS_CUST_DISP2: len = 20;
                           break;
                           
      case POS_CUST_DISP1: esc_cmd[0] = '\n';
                           len = 1;
                           break;
    }

    /* output the corresponding command */
    switch (device_no)
    {
       case POS_CASH_DISP: 
               _fsWrite(pos_setup[device_no].file_num, space_char, len);
               status = error_map(_fsError());
               if (status == NORMAL)
                       status = set_disp_cursor(device_no, row, 1);    
               break;
      
      case POS_CUST_DISP1: 
               _fsWrite(pos_setup[device_no].file_num, esc_cmd, len); 
               status = error_map(_fsError());
               break;
                         
      case POS_CUST_DISP2: if (pfl_com_nsendb(pos_setup[device_no].base_addrs, space_char, len))
                             status = DEV_NOT_READY;
                           if (status == NORMAL)
                             status = set_disp_cursor(device_no, row, 1);
                           break;
    }    
  }

  return status;
}

/*  open_serial_dev: retrieves serial port communication parameters  */
int open_serial_dev(int dev_no)
{
  int gen_status;  /* generic error codes returned to the application */  
  int port, dev_id, setup, protocol, base_addrs;

  gen_status = NORMAL;  /* assume normal */
 
  if (check_pfl_com() == 0)  /* PLF_COM not installed */
    gen_status = NO_DRIVER;
  else
  {                         
    gen_status = DEV_NOT_READY;
    for (port = 0; port < 4; ++port)
    {
      /* read serial port communication parameters */
      read_com_parm(port, &dev_id, &setup, &protocol);
      if (dev_id == dev_no)  /* device is assigned to a serial port */
      {
        gen_status = NORMAL;
        break;
      }
    }
  }  

  if (gen_status == NORMAL)
  {
    switch (port)  /* determine serial port base address */
    {
      case PFL_COM1: base_addrs = PFL_COM1_ADDRS;
                     break;

      case PFL_COM2: base_addrs = PFL_COM2_ADDRS;
                     break;

      case PFL_COM3: base_addrs = PFL_COM3_ADDRS;
                     break;

      case PFL_COM4: base_addrs = PFL_COM4_ADDRS;
                     break;
    }

    /* update POS device table */    
    update_table(1, dev_no, -1, port, setup, protocol, base_addrs);
  }    
    
  return gen_status;
}

/*  close_link_dev(): closes the device using file method but checks first if
                      it is linked to another device  */
void close_link_dev(int dev_no)
{
  int other_dev;

  other_dev = 0;
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

  if (other_dev == 1)  /* not linked to other devices */
    _fsClose(pos_setup[dev_no].file_num);
}
