 /* Program....: Ieereal.c
 *
 * syntax:   ieereal( nIEEVar )
 * returns:  char string of length 8.  each char in string
 *           represents the appropriate byte of nIEEVar.
 *
 * syntax:   realiee( cIEEStr )
 * returns:  double.  converts cIEEStr to it's double
   equivalent
 *
 * compile:  msc 5.1 -- cl /W3 /Ox /AL /Gs /c /FPa /Zl
   ieereal.c
 *
 */

#include "extend.h"

CLIPPER ieereal(void);
CLIPPER realiee(void);


union {
        double n;
        char   s[8];
      } v;


CLIPPER ieereal()
{
    double n;

    n = _parnd(1);

    _retclen( (char far *) &n, 8);
}


CLIPPER realiee()
{
    char i;
    char far *t;

    t = _parc(1);

    for (i = 0; i < 8; i++)
        v.s[i] = *t++;

    _retnd( v.n );
}
