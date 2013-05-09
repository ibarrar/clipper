#include <conio.h>
#include <graphics.h>
#include <stdlib.h>

void box(int, int, int, int, int);

main(void)
 {
  int driver, mode;
  unsigned size;
  void *buf;

  driver = DETECT; /*autodetect */
  mode = 0;
  initgraph(&driver, &mode, "");
  box(20, 20, 200, 200, 15);
  setcolor(RED);
  line(20, 20, 200, 200);
  getch();

  /*move image */

  /* first, get the image's size */
  size = imagesize(20, 20, 200, 200);
  if(size != 0xfff)
   {
    /* alloc memory for the image */
    buf = malloc(size);
    if(buf);
      {
       getimage(20, 20, 200, 200, buf);
       putimage(20, 210, buf, COPY_PUT);
       putimage(300, 50, buf, COPY_PUT);
      }
   }
   outtext("press a key");
   getch();
   restorecrtmode();
   return 0;
 }


 /* draw box given the coordinates of its two corners. */
 void box(int startx, int starty, int endx, int endy, int color)
   {
    setcolor(color);
    line(startx, starty, startx, endy);
    line(startx, starty, endx, starty);
    line(endx, starty, endx, endy);
    line(endx, endy, startx, endy);
   }