#include <dos.h>
#include "gdraws.h"

int setMode(int mode)
{
   union REGS reg;
	int retval;

	/* get current video mode */
	reg.h.ah = 0x0F;
	int86(0x10,&reg,&reg);
	retval = reg.h.al;
	
	if ( mode == 0) 
	{
	  /* just return mode */
	  return(mode);
	}		  	  
   reg.h.ah = 0x00;
   reg.h.al = mode;	
	int86(0x10,&reg,&reg);
	
	return retval;
}
   