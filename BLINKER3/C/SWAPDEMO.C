/*
 *  Blinker 2.1 Swap function demo
 *
 *          C version
 *
 *  Copyright (c) A.S.M. Inc, 1992, 1993
 *
 *  cl -AL -c swapdemo.c ;
 *
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "blinker.h"

#define TRUE    1
#define FALSE   0

void yesno(int) ;

void main(void)
{
 int status ;
 char keystr [100];

   if (! SWPGETPID("swapdemo.c"))

      /* If not already running */
      {
      printf("C Swap function Example\n");
      printf("=======================\n");
      printf("\n");

      printf("Default settings:\n\n");
      printf("Use EMS                        : "); yesno(SWPUSEEMS(FALSE));
      printf("Use XMS                        : "); yesno(SWPUSEXMS(FALSE));
      printf("Use UMB                        : "); yesno(SWPUSEUMB(FALSE));
      printf("Save/restore video mode        : "); yesno(SWPVIDMDE(FALSE));
      printf("Save/restore directory         : "); yesno(SWPCURDIR(FALSE));
      printf("Display message                : "); yesno(SWPDISMSG(FALSE));
      printf("Wait for keypress              : "); yesno(SWPGETKEY(FALSE));
      printf("Suppress <Ctrl><Alt><Del>      : "); yesno(SWPNOBOOT(FALSE));
      printf("\n");

      printf("Program already running        : "); yesno(SWPGETPID("swapdemo.c"));
      printf("Set program ID to swapdemo.c   : "); yesno(SWPSETPID("swapdemo.c"));
      printf("\n");

      /* enable use of EMS / XMS / UMBs */

      SWPUSEEMS(TRUE);
      SWPUSEXMS(TRUE);
      SWPUSEUMB(TRUE);

      /* save / restore current directory and video mode */

      SWPCURDIR(TRUE);
      SWPVIDMDE(TRUE);

      printf("Shelling to DOS...(Type EXIT to return)\n\n");
      printf("Run swapdemo again to see SWPGETPID()\n");
      printf("--------------------------------------------------------------------\n");

      /* Set a new prompt */

      SWPSETENV("PROMPT=C SwapDemo - $p$g");

      strcpy (keystr, "'dir /w'{enter}'swapdemo'");
      status = SWPKEYBRD(keystr);

      /* status = SWPRUNCMD(ChildProg, Memory, Shell Directory, Temporary directory) */

      status = SWPRUNCMD("",0,"","");

      printf("--------------------------------------------------------------------\n");
      printf("Back from shell - status is    : %d\n",status);
      printf("Major error code               : %d\n",SWPERRMAJ());
      printf("Minor error code               : %d\n",SWPERRMIN());
      printf("Child process return code      : %d\n",SWPERRLEV());
      printf("Child process return string    : %s\n\n",SWPGETSTR());
      }
   else
      {
      printf("This is the second invocation of SWAPDEMO\n");
      printf("Please enter a message to return to the parent\n");
      gets (keystr);

      status = SWPSETSTR ("swapdemo.c",keystr);

      printf("Type EXIT to return to previous swapdemo.c\n");
      exit(255);
      }
}

void yesno(flag)
int flag;
{
  if (flag)
  {
    printf("Yes\n");
  }
  else
  {
    printf("No \n");
  }
}

