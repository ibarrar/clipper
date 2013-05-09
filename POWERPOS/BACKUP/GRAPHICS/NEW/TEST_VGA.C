#include "gdraws.h"
#include <stdio.h>
#include <conio.h>

extern int LINEWIDTH=1, OPERATOR=0;
extern unsigned long int PATTERN=0xFFFFFFFF;

void main()
{
	int mode;
	printf("\n test if adapter is a VGA");
	
	if (is_VGA())
	{	
	  mode = setMode(0x12);
	   drawRect(-309,210,310,-200,11); 
		drawRoundRect(-300,210,300,-200,60,11);
   	drawLine(-309,210,310,-200,11);
	   drawLine(-309,-200,310,210,11);
		fillRect(-309,210,310,-200,11); 		
	  getch();
	  setMode(mode);
	  puts("\n YES");	  
	}
	else
	  puts("\n NO");
	  
}
	  