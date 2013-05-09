/****************************************************************************
  VERIFONE.C

  Sample program to talk to a verifone terminal. (ver 1.0)

  rci
****************************************************************************/
#include "extend.h"
#include "pflsrial.h"
#include "pfl_clip.ch"

#define DATA_READY  0x0100

#define PORT_NUM   1
#define TXT        1
#define BYTES_READ 1
#define STR_TXT    2

static port_no = 0;

CLIPPER veri_init()
{

  int status;
  unsigned char baud_rate, parity, stop_bit, data_bit, protocol;

  if  (PCOUNT == 1 && ISNUM(PORT_NUM))
  {
    port_no = _parni(PORT_NUM);
    
    baud_rate = BR_9600;
    parity = P_EVEN;
    stop_bit = SB_1;
    data_bit = DB_7;    
    protocol = 0;

    status = pfl_com_init(port_no, (baud_rate | parity | stop_bit | data_bit), protocol);

    _retni(status);
  }
  else
    _retni(INVP);
}  

CLIPPER veri_send()
{
 char far * text;
 int status = INVP;
 int textlen;
 
  if (PCOUNT == 1 && ISCHAR(TXT))
  {      
      text = _parc(TXT);
      textlen = _parclen(TXT);
      status = pfl_com_nsend( text, textlen );
  }
  
  _retni(status);         
    
}

CLIPPER veri_recv()
{
  unsigned char buffer[100];
  int data=0,i;
  long far *timer_ticks = (long far *) 0x0040006CL;
  long timein = *timer_ticks+1080L;
  char far * str_txt;

  
  if ( PCOUNT == 2 && ISBYREF(BYTES_READ) && ISNUM(BYTES_READ)
                    && ISBYREF(STR_TXT)  && ISCHAR(STR_TXT) )
  {
     str_txt = _parc(STR_TXT);
     
     i = 0;
     while ( ((data & 0x00ff) != 0x03)  &&  ( timein > *timer_ticks ))
     {
       if (pfl_com_sts(port_no) & DATA_READY)
       {
	 data = pfl_com_drecv();
	 buffer[i++] = (unsigned char) (data & 0x00ff);            
       }    
     }  
     
     _storni(i,BYTES_READ);
     _storclen(buffer,i,STR_TXT);
     _retni(NORMAL);
  }
  else
     _retni(INVP);
      
}


