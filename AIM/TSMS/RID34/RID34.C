#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <conio.h>
#include <memory.h>
#include "aim34.h"

#define  NORMAL 0

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
       return (-1);

   if ( ( tdlstat = tdlinit34()) != NORMAL )
     {
      //tdloff();
		return (tdlstat);
     }

   memset ( filename, 0, sizeof( filename ) );
	memcpy ( filename, afiles[ rep_type ], 2 );
   filename [2] = '3'; filename [3] = '4';
   memcpy ( filename+4, argv[1], 2 );
   filename[6] = mode; filename[7] = '\0';

   fp = fopen ( filename, "a" );

	switch ( rep_type )
     {
       case 0 :   if ( ( tdlstat = termrep ( isc_no, mode, fp )) != NORMAL)
                    {
                     tdloff34();
               	   fclose (fp);
                     return(tdlstat);
                    }
                  break;

       case 1 :  if ( ( tdlstat = deptrep ( isc_no, mode, fp )) != NORMAL)
                    {
                     tdloff34();
               	   fclose (fp);
                     return(tdlstat);
                    }
                  break;

       case 2 : if ( ( tdlstat = plurep ( isc_no, mode, fp )) != NORMAL)
                    {
                     tdloff34();
               	   fclose (fp);
                     return(tdlstat);
                    }
                  break;
       case 3 : if ( ( tdlstat = hourly( isc_no, mode, fp )) != NORMAL)
                    {
                     tdloff34();
               	    fclose (fp);
                     return(tdlstat);
                    }
                  break;
       case 4 : if ( ( tdlstat = cashrep( isc_no, mode, fp )) != NORMAL)
                    {
                     tdloff34();
               	   fclose (fp);
                     return(tdlstat);
                    }

  	  }

   tdloff34();
   fclose (fp);
   return ( NORMAL );
  }

