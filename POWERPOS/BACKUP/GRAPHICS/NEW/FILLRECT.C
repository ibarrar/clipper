#include "gdraws.h"
#include "conio.h"

void fillRect(int x1, int y1, int x2, int y2, int color)
{
	int i,first,last,begin,end,start_mask,end_mask,dummy;
	long int y1L, y2L, j;
	unsigned long int offset;
	char far *mem_address;

	x1 += 319;
	x2 += 319;
	y1L = (240 - y1) * 80L;
	y2L = (240 - y2) * 80L;
	begin = x1/8;
	end = x2/8;
	first = x1 - begin * 8;
	last = x2 - end * 8 + 1;
	start_mask = 0xFF >> first;
	end_mask = 0xFF << (8-last);
	for (j=y1L; j<=y2L; j+=80)
	{
		offset = j + begin;
		mem_address = (char far *) 0xA0000000L + offset;
		graph_out(8,start_mask);
		seq_out(2,0x0F);
		dummy = *mem_address;
		*mem_address = 0;
		seq_out(2,color);
		*mem_address = start_mask;
		for (i=begin+1; i<end; i++)
		{
			offset = j + i;
			mem_address = (char far *) 0xA0000000L + offset;
			graph_out(8,0xFF);
			seq_out(2, 0x0F);
			dummy = *mem_address;
			*mem_address = 0;
			seq_out(2,color);
			*mem_address = 0xFF;
		}
		offset = j + end;
		mem_address = (char far *) 0xA0000000L + offset;
		graph_out(8, end_mask);
		seq_out(2, 0x0F);
		dummy = *mem_address;
		*mem_address = 0;
		seq_out(2,color);
		*mem_address = end_mask;
		seq_out(2,0x0F);
		graph_out(3,0);
		graph_out(8,0xFF);
	}

}