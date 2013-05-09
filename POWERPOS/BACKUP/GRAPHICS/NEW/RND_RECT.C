#include "gdraws.h"

void drawRoundRect(int x1, int y1, int x2, int y2, int b, int color)
{
	int a, xr, yr, col, i, j, row, xend, yend;
	long a_square, b_square, two_a_square, two_b_square, 
	     four_a_square, four_b_square, d;

	yr = b;
	xr = b;
	xend = x2-xr;
	yend = y2+yr;
	for (j=-LINEWIDTH/2; j<=LINEWIDTH/2; j++)
	{
		for (i=x1+xr; i<=xend; i++)
		{
			plots(i,y1+j,color);
			plots(i,y2+j,color);
		}
	}
	for (j=-LINEWIDTH/2; j<=LINEWIDTH/2; j++)
	{
		for(i=y1-yr; i>=yend; i--)
		{
			plots(x1+j,i,color);
			plots(x2+j,i,color);
		}
	}
	b -= LINEWIDTH/2;
	a=b;
	for (i=0; i<LINEWIDTH; i++)
	{
		b_square = b*b;
		a_square = a*a;
		row = b;
		col = 0;
		two_a_square = a_square << 1;
		four_a_square = a_square << 2;
		four_b_square = b_square << 2;
		two_b_square = b_square << 1;
		d = two_a_square * ((row -1) * (row)) + a_square +
			 two_b_square * (1-a_square);
		while (a_square*(row) > b_square * (col))
		{
			plots(col+xend,yend-row,color);
			plots(col+xend,y1-yr+row,color);
			plots(x1+xr-col,yend-row,color);
			plots(x1+xr-col,y1-yr+row,color);
			if (d>=0)
			{
			 	row--;
				d -= four_a_square *(row);
			}
			d += two_b_square*(3 +(col <<1));
			col++;
		}
		d = two_b_square * (col +1)*col +two_a_square*(row *(row-2)+1) +
		    (1-two_a_square)*b_square;
		while (row)
		{
			plots(col+xend, yend-row,color);
			plots(col+xend,y1-yr+row,color);
			plots(x1+xr-col,yend-row,color);
			plots(x1+xr-col,y1-yr+row,color);
			if (d<=0)
			{
				col++;
				d += four_b_square*col;
			}
			row--;
			d+= two_a_square * (3 -(row<<1));
		}
		b++;
		a++;
	}
}

				
		