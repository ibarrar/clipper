#include <dos.h>

int is_VGA(void)
{

	union REGS reg;

	reg.h.ah = 0x1A;
	reg.h.al = 0x00;
	int86(0x10, &reg, &reg);

   return(reg.h.al == 0x1A && reg.h.bl == 0x08);
	
}