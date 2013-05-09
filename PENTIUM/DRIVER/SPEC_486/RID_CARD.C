/****************************************************************************
  RID_CARD.C

  Syntax:

    READ_CARD( <track_no>, <bytes_read>, <str_buffer>, <cancel_pos> )

  Parameters:

    <track_no>   - a numeric argument that will contain the track number (from where
                   data was read) on return from this function. This argument must
                   always be passed by reference (@) and must be initialized by 
                   a numeric data type.

    <bytes_read> - a numeric argument that will contain the length (in bytes)
                   of the actual data read. This argument must always be 
                   passed by reference (@> and must be initialized by a numeric
                   data type.

    <str_buffer> - buffer that contains the track data. Data read is stored as 
                   character string. This argument must always be passed by reference
                   (@) and must be initialized by a character data type (for example,
                   a null string - "").

    <cancel_pos> - a numeric argument that specify the Cancel key position on
                   the POS keyboard. Values must be between 1-105.
           
  Description:

    READ_CARD() switches the swipecard reader to ready-to-read state and
    enables the reading of data. On a NORMAL return from this function - 
    <track_no> will contain the track number, while <str_buffer> contains
    the track data.
    
    Track data length is obtained from <bytes_read>.

    Read operation can be cancelled by pressing the Cancel key on the POS
    keyboard.

  Return values:

    NORMAL         - Normal operation
    DEV_NOT_READY  - Device not ready
    DEV_NOT_EXIST  - Device not initialized
    HARD_ERR       - General hardware error
    INVP           - Invalid parameter or invalid command
    TIMEOUT_ERR    - Timeout status occurred
    READ_ERR       - Read operation error
    CANCEL_OP      - Read/Write operation cancelled
    
    See header file - PFL_CLIP.CH for details.
    
  Note:
  This function acts as an interface between the Clipper application and the
  PCR device drivers. This function is callable from Clipper using the
  Extend System.
  
  For more information about the PCR device drivers see the POS 3000
  Technical Reference manual.
  
  rnr  5-23-95
*****************************************************************************/
#include <stdlib.h>
#include <string.h>
#include <conio.h>
#include "extend.h"
#include "pcr_ext.h"
#include "pfl_key2.h"
#include "pfl_scan.h"
#include "pfl_clip.ch"

#pragma intrinsic (memcmp)

#define BUFF_SIZE   300  /* maximum buffer size for reading */

/* parameter constants */
enum arguments { TRACK_NO=1, BYTES_READ, STR_BUFF, CANCEL_POS };

/* External definitions */
extern POS_TABLE pos_setup[];
extern int in_sound;  /* keyboard sound flag */
extern unsigned int frqwency;  /* frequency in Hertz */
extern unsigned int msec_cnt;  /* delay count in ms */
extern int async_scan;  /* flag that indicates the asynchronous scanning mode */
extern int s_buff_size;  /* maximum no of labels to be buffered */
extern int s_end_char;  /* terminating character */
extern int s_dflt_irq;  /* default IRQ flag */

CLIPPER read_card(void)
{
  int gen_status;  /* generic error codes returned to the application */
  char esc_cmd[4]; /* holds the escape sequence command */
  char str_len[4], *str_stop;
  int abort_flag, i, cancel_loc, track_num, trackno;
  long int len;
  /* Other variables */
  char read_buff[BUFF_SIZE+1];   /* +1 for the NULL character */
  char key_position[] = /* POS keyboard position */
    { 0xff, 0x30, 0x31, 0x32, 0x33, 0x35, 0x34, 0x36, 0x37, 0x38,
      0x3b, 0x3a, 0x39, 0x3c, 0x3d, 0x3e, 0x40, 0x41, 0x42, 0x43,
      0x45, 0x44, 0x46, 0x47, 0x48, 0x4b, 0x4a, 0x49, 0x4c, 0x4d,
      0x4e, 0x50, 0x51, 0x52, 0x53, 0x55, 0x54, 0x56, 0x57, 0x58, 
      0x5b, 0x5a, 0x59, 0x5c, 0x5d, 0x5e, 0x60, 0x61, 0x62, 0x63, 
      0x65, 0x64, 0x66, 0x67, 0x68, 0x6b, 0x6a, 0x69, 0x6c, 0x6d, 
      0x6e, 0x20, 0x21, 0x22, 0x23, 0x25, 0x24, 0x26, 0x27, 0x28, 
      0x2b, 0x2a, 0x29, 0x2c, 0x2d, 0x2e, 0x10, 0x11, 0x12, 0x13, 
      0x15, 0x14, 0x16, 0x17, 0x18, 0x1b, 0x1a, 0x19, 0x1c, 0x1d, 
      0x1e, 0x00, 0x01, 0x02, 0x03, 0x05, 0x04, 0x06, 0x07, 0x08, 
      0x0b, 0x0a, 0x09, 0x0c, 0x0d, 0x0e };

  /* validate parameters */
  if (PCOUNT == 4 && ISNUM(TRACK_NO) && ISBYREF(TRACK_NO) &&
                     ISNUM(BYTES_READ) && ISBYREF(BYTES_READ) &&
                     ISCHAR(STR_BUFF) && ISBYREF(STR_BUFF) && 
                     ISNUM(CANCEL_POS))
  {
    /* read and verify cancel key position */
    cancel_loc = _parni(CANCEL_POS);
       trackno = _parni(TRACK_NO);

    if (NOT_IN_RANGE(cancel_loc, 1, 105))
    {
      _retni(INVP);
      return;
    }

    /* verify initial status */
    if (chk_init_flag(POS_CARD_READ) == 0)
    {
      _retni(DEV_NOT_EXIST);   /* device not yet initialized */
      return;
    }

#ifdef KEY_SOUND_ENABLED
    if (in_sound) /* keyboard sound is enabled */
      unhook_keytone(); /* disable it temporarily */
#endif      

    if (async_scan) /* asynchronous scanning is enabled */
      asyn_scan_off(); /* disable it temporarily */

    pfl_key_clear();  /* clear keyboard input buffer */              
      
    if (cancel_loc != 16)  /* not the default CANCEL key position */      
    {
      /* set cancel key */
      esc_cmd[0] = '@';
      esc_cmd[1] = key_position[cancel_loc];

      _fsWrite(pos_setup[POS_CARD_READ].file_num, esc_cmd, 2);
      
      gen_status = error_map(_fsError());    

      if (gen_status != NORMAL)  /* unable to set the cancel key */
      {
      
#ifdef KEY_SOUND_ENABLED      
        if (in_sound) /* keyboard sound is enabled */
          hook_keytone(); /* enable it again */    
#endif          

        if (async_scan) /* asynchronous scanning is enabled */          
          asyn_scan_on(s_buff_size, (unsigned char) s_end_char, s_dflt_irq, 
                 pos_setup[POS_SCAN].port+1, pos_setup[POS_SCAN].base_addrs,
                 pos_setup[POS_SCAN].setup, (unsigned char) pos_setup[POS_SCAN].protocol);        
        
        _retni(gen_status);
        return;
      }
    }
    
    /* set swipecard reader to ready-to-read state */    
    esc_cmd[0] = '$';

    _fsWrite(pos_setup[POS_CARD_READ].file_num, esc_cmd, 1);
    gen_status = error_map(_fsError());        
    
    if (gen_status != NORMAL)  /* unable to initialize the MSR */
    {
#ifdef KEY_SOUND_ENABLED          
      if (in_sound) /* keyboard sound is enabled */
        hook_keytone(); /* enable it again */    
#endif                  

      if (async_scan) /* asynchronous scanning is enabled */          
        asyn_scan_on(s_buff_size, (unsigned char) s_end_char, s_dflt_irq, 
               pos_setup[POS_SCAN].port+1, pos_setup[POS_SCAN].base_addrs,
               pos_setup[POS_SCAN].setup, (unsigned char) pos_setup[POS_SCAN].protocol);                
            
      _retni(gen_status);
      return;
    }

    /* read track data */
    gen_status = NORMAL;  /* assume normal operation */
    _bset((char *) read_buff, 0x0, sizeof(read_buff));
    abort_flag = i = 0;

    do    
    {
      read_buff[i] = (char) getch();    

      if (read_buff[i] == '\xa8')  /* inverted question mark */
      {
        ++i;
        read_buff[i] = (char) getch();         

        switch (read_buff[i])
        {
          case 'c':  /* cancel key is pressed */
            /* simulate keyboard tone */
            sound(frqwency);
            delay(msec_cnt);
            nosound();
          
            abort_flag = 1;
            gen_status = CANCEL_OP;
            break;

          case 't':  /* timeout error */
            abort_flag = 1;
            gen_status = TIMEOUT_ERR;      
            break;
            
          case 'e':  /* read error */
            abort_flag = 1;            
            gen_status = READ_ERR;
            break;

          case 'm':  /* good read */
            abort_flag = 1;
            break;
        }
      }

      ++i;
      
    } while (!abort_flag);

    /* disable MSR reading */
    esc_cmd[0] = '!';
    _fsWrite(pos_setup[POS_CARD_READ].file_num, esc_cmd, 1);
    
    if (gen_status != NORMAL) /* not a normal read operation */
    {

#ifdef KEY_SOUND_ENABLED          
      if (in_sound) /* keyboard sound is enabled */
        hook_keytone(); /* enable it again */          
#endif        
        
      if (async_scan) /* asynchronous scanning is enabled */          
        asyn_scan_on(s_buff_size, (unsigned char) s_end_char, s_dflt_irq, 
               pos_setup[POS_SCAN].port+1, pos_setup[POS_SCAN].base_addrs,
               pos_setup[POS_SCAN].setup, (unsigned char) pos_setup[POS_SCAN].protocol); 
            
      _retni(gen_status);
      return;
    }
    
    gen_status = error_map(_fsError());        
    
    if (gen_status != NORMAL)  /* unable to disable MSR reading */
    {
#ifdef KEY_SOUND_ENABLED              
      if (in_sound) /* keyboard sound is enabled */
        hook_keytone(); /* enable it again */    
#endif        

      if (async_scan) /* asynchronous scanning is enabled */          
        asyn_scan_on(s_buff_size, (unsigned char) s_end_char, s_dflt_irq, 
               pos_setup[POS_SCAN].port+1, pos_setup[POS_SCAN].base_addrs,
               pos_setup[POS_SCAN].setup, (unsigned char) pos_setup[POS_SCAN].protocol);         
            
      _retni(gen_status);
      return;
    }    

    /* scan the buffer for TRACK 2 data */
    gen_status = READ_ERR;  /* assume read error */
    
    switch(trackno) {
        case 1:
           for (i = 0; i < BUFF_SIZE+1; ++i)
           {
              if (memcmp(read_buff+i, "\xa8\x31", 2) == 0) /* TRACK 2 signature */
              {
                 gen_status = NORMAL;
                 break;
              }
           }
           break;
        case 3:
           for (i = 0; i < BUFF_SIZE+1; ++i)
           {
              if (memcmp(read_buff+i, "\xa8\x33", 2) == 0) /* TRACK 2 signature */
              {
                 gen_status = NORMAL;
                 break;
              }
          }
           break;
        case 2:
        default:
           for (i = 0; i < BUFF_SIZE+1; ++i)
              {
              if (memcmp(read_buff+i, "\xa8\x32", 2) == 0) /* TRACK 2 signature */
                 {
                 gen_status = NORMAL;
                 break;
                 }
              }
           break;
        }

    if (gen_status != NORMAL)  /* unable to read TRACK 1 or 2 or 3 */
    {
#ifdef KEY_SOUND_ENABLED              
      if (in_sound) /* keyboard sound is enabled */
        hook_keytone(); /* enable it again */    
#endif        

      if (async_scan) /* asynchronous scanning is enabled */          
        asyn_scan_on(s_buff_size, (unsigned char) s_end_char, s_dflt_irq, 
               pos_setup[POS_SCAN].port+1, pos_setup[POS_SCAN].base_addrs,
               pos_setup[POS_SCAN].setup, (unsigned char) pos_setup[POS_SCAN].protocol);         
            
      _retni(gen_status);
      return;
    }        
    
    /* get track number */
    track_num = (int) (read_buff[i+1] & 0x0f);
    _storni(track_num, TRACK_NO);

    /* get no of bytes read */
    str_len[0] = read_buff[i+2];
    str_len[1] = read_buff[i+3];
    str_len[2] = '\0';
    i += 4;
    
    /* convert hex string to integer format */
    len = strtol(str_len, &str_stop, 16);
    _storni((int) len, BYTES_READ);

    /* save track data */
    *(read_buff+i+len) = '\0';  /* insert a NULL character */
    _storclen(read_buff+i, (int) (len+1), STR_BUFF);


#ifdef KEY_SOUND_ENABLED              
    if (in_sound) /* keyboard sound is enabled */
      hook_keytone(); /* enable it again */        
#endif      

    if (async_scan) /* asynchronous scanning is enabled */          
      asyn_scan_on(s_buff_size, (unsigned char) s_end_char, s_dflt_irq, 
             pos_setup[POS_SCAN].port+1, pos_setup[POS_SCAN].base_addrs,
             pos_setup[POS_SCAN].setup, (unsigned char) pos_setup[POS_SCAN].protocol);       
             
    pfl_key_clear();  /* clear keyboard input buffer */                           

    _retni(gen_status);      
  }
  else
    _retni(INVP);
}
