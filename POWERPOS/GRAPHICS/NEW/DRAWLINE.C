#include <dos.h>
#include <stdlib.h>
#include "gdraws.h"

void drawLine(int x1, int y1, int x2, int y2, int color)
{
	int dx,dy,dxabs,dyabs,i,j,px,py,sdx,sdy,x,y;
	unsigned long int mask=0x80000000;

	convert(x1,y1);
	convert(x2,y2);
	dx = x2 -x1;
	dy = y2 -y1;
	sdx = sign(dx);
	sdy = sign(dy);
	dxabs = abs(dx);
	dyabs = abs(dy);
	x = 0;
	y = 0;
	px = x1;
	py = y1;
	if (dxabs >= dyabs)
	{
		for (i=0; i<dxabs; i++)
		{
		  mask = mask ? mask : 0x80000000;
		  y +=dyabs;
		  if (y>=dxabs)
		  {
		  		y -= dxabs;
				py += sdy;
		  }
		  px += sdx;
		  if (PATTERN & mask)
		  {
		  	for (j=-LINEWIDTH/2; j<=LINEWIDTH/2; j++)
				plot(px,py+j,color);
		  }
		  mask >>= 1;
		}
	}
	else
	{
		for (i=0; i<dyabs; i++)
		{
			mask = mask ? mask : 0x80000000;
			x += dxabs;
			if (x>=dyabs)
			{
				x -= dyabs;
				px += sdx;
			}
			py += sdy;
			if (PATTERN & mask)
			{
				for (j=-LINEWIDTH/2; j<=LINEWIDTH/2; j++)
					plot(px+j, py, color);
			}
			mask >>= 1;
		}
	}
}

	