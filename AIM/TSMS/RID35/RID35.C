#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <conio.h>
#include <memory.h>
#include <dos.h>
#include "tdl35.h"

#define MK_FP(s,o) ((void far *) ((( unsigned long)(s) << 16) | (unsigned) (o) ) )
#define peek(a,b) (*((unsigned far *)MK_FP((a),(b))))

void terminate( int return_code );
void delay(unsigned tsecs);

static char *afiles[] = { "RS", "DP", "PL", "HR", "CS" };

int main ( int argc, char *argv[] )
 {
   int tdlstat;
   FILE *fp;
   char filename[8];
   int rep_type = atoi( argv[2] );
   int isc_no = atoi ( argv[3] );
   char mode = toupper(*argv[4]);

	if ( argc != 5 )
     terminate(1);

   if ( ( tdlstat = tdlinit()) != NORMAL )
     {
      //tdloff();
      return (tdlstat);
     }

   memset ( filename, 0, sizeof( filename ) );
	memcpy ( filename, afiles[ rep_type ], 2 );
   filename [2] = '3'; filename [3] = '5';
   memcpy ( filename+4, argv[1], 2 );
   filename[6] = mode; filename[7] = '\0';

   fp = fopen ( filename, "a" );

	switch ( rep_type )
     {
       case 0 :   if ( ( tdlstat = termrep ( isc_no, mode, fp )) != NORMAL)
                    {
                     tdloff();
               	   fclose (fp);
                     return(tdlstat);
                    }
                  break;

       case 1 :  if ( ( tdlstat = ddaily ( isc_no, mode, fp )) != NORMAL)
                    {
                     tdloff();
               	   fclose (fp);
                     return(tdlstat);
                    }
                  break;

       case 2 : if ( ( tdlstat = plall_i  ( isc_no, mode, fp )) != NORMAL)
                    {
                     tdloff();
               	   fclose (fp);
                     return(tdlstat);
                    }
                   break;
       case 3 : if ( ( tdlstat = hourly  ( isc_no, mode, fp )) != NORMAL)
                    {
                     tdloff();
               	   fclose (fp);
                     return(tdlstat);
                    }
                   break;
       case 4 : if ( ( tdlstat = floatc  ( isc_no, mode, 1, fp )) != NORMAL)
                    {
                     tdloff();
               	   fclose (fp);
                     return(tdlstat);
                    }
                   break;
  	  }

   tdloff();
   fclose (fp);
   return ( NORMAL );
  }


void terminate( int return_code )
 {
   union REGS inregs, outregs;

   inregs.h.ah = 0x4C;
   inregs.h.al = ( unsigned char ) return_code;
   intdos( &inregs, &outregs );
 }

static void delay(unsigned tsecs)
{
  unsigned tickref;
  for (; tsecs > 0; -- tsecs)
  {
    tickref = peek( 0x40, 0x6C );
    while (tickref == peek( 0x40, 0x6C ))
      ;
  }

}
