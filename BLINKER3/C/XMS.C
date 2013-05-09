/******************
* XMS.C
* (C) 1993, ASM Inc
*
* Demonstration of DosRealIntr()    - call real mode interrutpt
*                  DosRealFarCall() - call real mode function
*
*
*/
#include <memory.h>
#include <stdio.h>
#include <blx286.h>

void main(void)
{
  REGS16 regs;
  REALPTR xmsdriver ;

  printf("This program attempts to get the XMS driver version number\n");
  printf("using DosRealIntr() and DosRealFarCall().\n\n");
  memset(&regs, 0, sizeof(REGS16)) ;        /* important: clear to zero */
  regs.ax = 0x4300 ;
  if (DosRealIntr(0x2f, &regs, 0L, 0) == 0) /* xms installation check */
     if ((regs.ax & 0xff)==0x80)
        {
         printf("XMS driver installed\n");
         memset(&regs, 0, sizeof(REGS16)) ;/* important: clear to zero */
         regs.ax = 0x4310 ;                /* get driver entry point */
         if (DosRealIntr(0x2f, &regs, 0L, 0) == 0)
            {
             xmsdriver = (REALPTR)MK_FP(regs.es, regs.bx);  /* real mode entry point */
             printf("XMS driver real mode entry point is : %Fp\n",xmsdriver);
             memset(&regs, 0, sizeof(REGS16));     /* clear to zero */
             regs.ax = 0;                          /* Get version function */
             if (DosRealFarCall(xmsdriver, &regs, 0L, 0) == 0)
                {
                 if(regs.ax != 0)
                   printf("XMS driver version : %04X\n",regs.ax);
                 else
                   printf("XMS get version call failed\n");
                }
             else
                {
                 printf("DosRealFarCall() failed.\n") ;
                }
            }
         else
            {
             printf("DosRealIntr() call failed.\n");
            }
        }
     else
        {
        printf("XMS driver not installed.\n");
        }
  else
     {
     printf("DosRealIntr() call failed.\n");
     }
}

