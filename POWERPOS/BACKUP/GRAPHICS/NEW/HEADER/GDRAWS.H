/* gdraws.h = Header file for gdraws library */

void drawRect(int x1, int y1, int x2, int y2, int color );
void drawLine(int x1, int y1, int x2, int y2, int color );
void plot(int x, int y, int color);
void plots(int x, int y, int color);
void fillRect(int x1, int y1, int x2, int y2, int color);

int setMode(int mode);
int is_VGA(void);
void drawRoundRect(int x1, int y1, int x2, int y2, int b, int color);

extern int OPERATOR, LINEWIDTH, ANGLE, XCENTER, YCENTER;
extern unsigned long PATTERN, style[8];

#define convert(x,y) {x=(x+319); y =(240-y);} 
#define sign(x) ((x) > 0 ? 1 : ((x) == 0 ? 0: (-1)))
#define seq_out(index,val) {outp(0x3C4,index); \
			    outp(0x3C5,val); }
#define graph_out(index,val) {outp(0x3CE, index); \
			      outp(0x3CF, val); }
			