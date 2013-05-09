/* plot() = plots a point on the screen at designated
* 				screen coordinates using selected color
*/

#include <dos.h>
#include "gdraws.h"

/*
void plot (int x, int y, int color)
{
	unsigned long offset;
	int dummy, mask;
	char far * mem_address;

	offset = (long)y * 80L + ((long)x /8L);
	mem_address = (char far*) 0xA0000000L +offset;
	mask = 0x80 >> (x % 8);
	graph_out(8,mask);
	seq_out(2, 0x0F);
	dummy = *mem_address;
	*mem_address =0;
	seq_out(2,color);
	*mem_address = 0xFF;
	seq_out(2, 0x0F);
	graph_out(3,0);
	graph_out(8,0xFF);
	
}	                                             
*/
void plot (int x, int y, int color)
{
	union REGS reg;

	reg.h.ah = 0x0C;
	reg.h.al = color;
	reg.h.bh = 0x00;
	reg.x.cx = x;
	reg.x.dx = y;
	int86(0x10, &reg, &reg);
}
		