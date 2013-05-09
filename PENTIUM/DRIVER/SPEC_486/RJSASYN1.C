/*****************************************************************************
  RJSASYN1.C

  Syntax:
  
    void RJS_ASYN1(void) 

  Parameters:

    None.
    
  Description:

    RJS_ASYN1() is the main print function of A_RJS_PRNT() - Clipper interface.
    It is called by RJS_ASYN() from PRNTASYN.ASM.
    
  Return values:

    The actual print job status is returned in the global variable print_status.
  
  
  rnr  6-24-94
  rnr  5-15-95  Removed slip printing.
  rnr  1-11-96  Removed checking of printer status.
  rnr  4-19-96  Checks paper status.
*****************************************************************************/
#include "pcr_ext.h"
#include "pfl_lpt.h"
#include "pfl_clip.ch"

/* EXTERNAL DEFINITIONS */
extern POS_TABLE pos_setup[];
extern RJS_DATA1 prnt_data1[PRINT_JOBS];  /* print job buffer */
extern int buff_in1;  /* buffer input index */
extern int buff_out1; /* buffer output index */
extern int buffer_empty;  /* flag that indicates if the print buffer is empty */
extern int print_status;  /* holds the generic printer status */
extern int print_stop;  /* a value of 1 disables RJ printing; otherwise, a value
                           of zero enables it */

/* LOCAL FUNCTIONS */
static int req_cmd(unsigned char printer_type, char *data, unsigned int len, int line_feed);

void rjs_asyn1(void)
{
  static int next_buff_out;  /* next buffer output index */
  static int gen_status;     /* generic error codes returned to the application */

  gen_status = NORMAL;  /* assume normal operation */  
  
  next_buff_out = buff_out1;  /* get current buffer output index */

  if (next_buff_out == buff_in1)  /* buffer is empty ? */
    buffer_empty = 1;
  else
  {
    if (!print_stop)  /* RJ printing is enabled */
    {
      /* printing in both receipt and journal */
      if ((prnt_data1[buff_out1].printer_type & 0x01) &&
          (prnt_data1[buff_out1].printer_type & 0x02))
      {
        if (prnt_data1[buff_out1].printer_type & 0x01)  /* journal */
          gen_status = req_cmd(0x01, prnt_data1[buff_out1].txt_msg, prnt_data1[buff_out1].text_len, prnt_data1[buff_out1].line_flag); 

        if (gen_status == NORMAL)  /* journal print okay ? */
        {
          if (prnt_data1[buff_out1].printer_type & 0x02)  /* receipt */
          {
            gen_status = req_cmd(0x00, prnt_data1[buff_out1].txt_msg, prnt_data1[buff_out1].text_len, prnt_data1[buff_out1].line_flag);
        
            if (gen_status == PAPER_ERR)  /* update print buffer */
            {
               ++next_buff_out;

               if (next_buff_out == PRINT_JOBS)  /* past the end of buffer ? */
                 next_buff_out = 0;  /* reset to start of buffer */      

               buff_out1 = next_buff_out;  /* update buffer output index */
            }        
          }        
        }
      }
      else if (prnt_data1[buff_out1].printer_type & 0x02)  /* receipt */
        gen_status = req_cmd(0x00, prnt_data1[buff_out1].txt_msg, prnt_data1[buff_out1].text_len, prnt_data1[buff_out1].line_flag);      
      else if (prnt_data1[buff_out1].printer_type & 0x01)  /* journal */
        gen_status = req_cmd(0x01, prnt_data1[buff_out1].txt_msg, prnt_data1[buff_out1].text_len, prnt_data1[buff_out1].line_flag); 

      /* if (prnt_data1[buff_out1].printer_type & 0x04)  slip 
        gen_status = req_cmd(0x02, prnt_data1[buff_out1].txt_msg, prnt_data1[buff_out1].text_len, prnt_data1[buff_out1].line_flag); */

      if (gen_status == NORMAL)  /* printing is successful: update print buffer */
      {
        ++next_buff_out;

        if (next_buff_out == PRINT_JOBS)  /* past the end of buffer ? */
          next_buff_out = 0;  /* reset to start of buffer */      

        buff_out1 = next_buff_out;  /* update buffer output index */
      }
    }
  }
  
  print_status = gen_status;
}
                       
static int req_cmd(unsigned char printer_type, char *data, unsigned int len, int line_feed)
{
  static int gen_status;       /* generic error codes returned to the application */
  static unsigned char esc_cmd[6];  /* holds the printer escape sequence commands */
  /* static unsigned char paper_sts;  holds the paper status of all print stations */
  static int port_status;  /* holds the current parallel port status */
  static unsigned char paper_err;  /* flag that indicates paper error */


  paper_err = 0; 
  
  /* printing in both receipt and journal */
  if ((prnt_data1[buff_out1].printer_type & 0x01) &&
      (prnt_data1[buff_out1].printer_type & 0x02))  
  {
    port_status = pfl_lpt_sts(pos_setup[POS_PRINTER].lpt_port);

    if (port_status & 0x0020)  /* out of paper? */
    {
      print_stop = 1;  /* disable RJ printing */

      if (printer_type == 0)  /* if receipt printer: finish the current print job */
        paper_err = 1;  /* signal paper error status */
      else
        return PAPER_ERR;
    }
  }
  else if (prnt_data1[buff_out1].printer_type & 0x01)  /* journal print */
  {
    port_status = pfl_lpt_sts(pos_setup[POS_PRINTER].lpt_port);

    if (port_status & 0x0020)  /* out of paper? */
      return PAPER_ERR;  
  }

  /* for the meantime 
  timeout, I/O error, out of paper, and not selected status
  if ((port_status & 0x29) || !(port_status & 0x10))
    return DEV_NOT_READY; */

  gen_status = NORMAL;  /* assume normal operation */  
  
  /* send Select printer station comand */
  esc_cmd[0] = ESC_CODE;
  esc_cmd[1] = 'c';
  esc_cmd[2] = '0';
  esc_cmd[3] = printer_type;

  /* send escape sequence command to printer */
  pfl_lpt_nsend(pos_setup[POS_PRINTER].lpt_port, esc_cmd, 4);

  /* send data to printer */
  pfl_lpt_nsend(pos_setup[POS_PRINTER].lpt_port, data, len);  

  if (line_feed)  /* execute line feed? */
  {
    /* send Line feed command */
    esc_cmd[0] = '\r';

    pfl_lpt_send(pos_setup[POS_PRINTER].lpt_port, esc_cmd[0]);
  }

  if (paper_err)  /* paper error status ? */
    gen_status = PAPER_ERR;
    
  return gen_status;
}
