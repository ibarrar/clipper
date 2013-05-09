#include <gdraws.h>

void drawRect(int x1, int y1, int x2, int y2, int color)
{
	drawLine(x1-LINEWIDTH/2, y1, x2+LINEWIDTH/2, y1, color);
	drawLine(x1-LINEWIDTH/2, y2, x2+LINEWIDTH/2, y2, color);
	drawLine(x1,y1+LINEWIDTH/2,x1,y2-LINEWIDTH/2,color);
	drawLine(x2,y1+LINEWIDTH/2,x2,y2-LINEWIDTH/2,color);
}