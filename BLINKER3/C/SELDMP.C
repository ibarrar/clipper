/*

    93.10.08    Blinker extender selector dump program

*/

#include <process.h>
#include <stdio.h>

#include <blx286.h>

static void DumpFlags(SEL sel)
{
    /* Dumps an interpreted version of the segment attribute */

    USHORT flags;
    if (DosVerifyAccess(sel, &flags) == 0)
       if (flags & SEL_VALID)         /* is a valid selector */
          {
            if (flags & SEL_READABLE)
                printf("READABLE ");
            if (flags & SEL_WRITABLE)
                printf("WRITABLE ");
            if (flags & SEL_CODE)
                printf("EXECUTABLE");
            printf("\n");
          }
          else
          {
            printf("NOT A SELECTOR\n");
          }

}

void pascal seldmp (void)
{
   BYTE     ProcMode;
   USHORT   hshift;
   DESC     desc_buf;
   int      selinc;
   SEL      tmpsel;

   if (DosGetMachineMode(&ProcMode) == 0)
   {
      printf("\nThe processor is in ");
      switch (ProcMode)
      {
      case MODE_REAL :
         printf ("real mode/V86 mode\n");
         break;
      case MODE_PROTECTED :
         printf ("286 Protected mode\n");
         break;
      default:
         printf ("another mode - interesting\n");
         exit(255);
      }
   }

   if (ProcMode == MODE_PROTECTED)
      {
      DosGetHugeShift(&hshift);                    /* Get the shift */
      selinc = 1 << hshift ;
      printf ("Selector shift for huge segments %04X\n",hshift);
      printf ("     Increment for huge segments %04X\n\n",selinc);

      printf("Sel  Base     Length   Attr   Flags\n");
      printf("-----------------------------------\n");

      for (tmpsel = SELECTOROF (seldmp); tmpsel < 0x8000; tmpsel += selinc)
         {
         if (DosGetSegDesc(tmpsel,&desc_buf) == 0)
            {
            printf("%04X %08lX %08lX %04X   ",
                  tmpsel,desc_buf.segbase ,desc_buf.seglen, desc_buf.segattrib);
            DumpFlags (tmpsel);
            }
         }
      }
}

void main (void)
{
   printf ("\nSELDMP 0.1 Blinker extender selector dump program");
   printf ("\n-------------------------------------------------\n");

   seldmp ();
   exit (0);
}
