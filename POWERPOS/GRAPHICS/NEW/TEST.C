#include "gdraws.h"

extern int LINEWIDTH=1, OPERATOR=0;
extern unsigned long int PATTERN=0xFFFFFFFF;

void main()
{
	setMode(12);
		
	drawRect(-309,210,310,-200,11);
	drawLine(-309,210,310,-200,11);
	drawLine(-309,-200,310,210,11);

}