/*
 * System.......... PowerPos for Spectrum
 * Program I.D..... bcd_clip.c
 * Description..... Routine to convert ascii to binary coded decimal (bcd)
 *                  format and vice versa
 * Author.......... Bongý Santiago
 * Date Started.... September 1994
 * Dialect......... MicroSoft callable bt Clipper 5.01
 * Remarks......... Compile in MicroSoft C Ver. 5.1 or later with the ff.
 *                  CL /c /AL /FPc /Gs /Oalt /Zl bcd_clip.c
*/
 
#include "extend.h"

#define NORMAL             0
#define INVALID_PARAM      7


#define  ATOBCD   1     /* ascii to convert to bcd... */
#define  ASCLEN   2     /* length of ascii string... */
#define  BBYREF   3     /* buffer for the converted bcd passed by reference... */

#define  BTOASC   1     /* bcd to convert to ascii... */
#define  BCDLEN   2     /* length of bcd string... */
#define  ABYREF   3     /* buffer for the converted ascii passed by reference... */

CLIPPER cl_atobcd(void)
{
   unsigned char *param1;    /* storage for the ascii string... */
   unsigned char *param2;    /* storage for the bcd buffer... */
   int  len;                 /* storage for the ascii length... */
   unsigned char *asc_buf;   /* storage for ascii string WITHOUT the '.' */
   int  i, count;

   /* validate parameters... */
   if (PCOUNT == 3 && ISCHAR(ATOBCD) && ISNUM(ASCLEN) 
       && ISCHAR(BBYREF) && ISBYREF(BBYREF))
   {
      /* convert Clipper ascii length to C int len... */
      len = _parni(ASCLEN);
      
      /* allocate some space for the parameter storage... */
      param2  = (unsigned char *) _xalloc((int) len/2);
      asc_buf = (unsigned char *) _xalloc(len);
      
      /* initialize pointers with zeroes... */
      _bset (param2, 0, (int) len/2);
      _bset (asc_buf, 0, len);
      
      /* convert Clipper ascii and bcd buffer to C parameters...*/
      param1 = _parc(ATOBCD);
      
      /* remove first the '.' if any...*/
      for ( i = count = 0; i < len; ++i )
      {
         if (param1[i] != '.')
            asc_buf[count++] = param1[i];
      }
      
      /* convert param1 to bcd format and store to param2... */
      for ( i = count = 0; i < len; i++ )
      {
         param2[count]  = (unsigned char) ((unsigned char) asc_buf[i] -  0x30);
         param2[count]  = (unsigned char) ((unsigned char) param2[count] << 4);
         param2[count] += ((unsigned char) asc_buf[++i] & 0x0F);
         count++;
      }

      /* update Clipper parameter bcd buffer with param2... */
      _storclen(param2, (int) len/2, BBYREF);

      /* release allocated memory for param2 and asc_buf... */
      _xfree(param2);
      _xfree(asc_buf);
      
      _retni(NORMAL);
   }
   else
      _retni(INVALID_PARAM);
}

CLIPPER cl_bcdtoa(void)
{
   unsigned char *param1;  /* storage for the bcd string... */
   unsigned char *param2;  /* storage for the ascii buffer... */
   int  len;               /* storage for the bcd string length... */
   int  count, i;

   /* validate parameters... */
   if (PCOUNT == 3 && ISCHAR(BTOASC) && ISNUM(BCDLEN) 
       && ISCHAR(ABYREF) && ISBYREF(ABYREF))
   {
      /* convert Clipper ascii length to C int len... */
      len = _parni(BCDLEN);

      /* allocate some space for the parameter storage... */
      param2 = _xalloc((int) len *2);
      
      /* initialize pointers with zeroes... */
      _bset (param2, 0, (int) len *2);

      /* convert Clipper bcd string and ascii buffer to C parameters... */
      param1 = _parc(BTOASC);

      /* convert param1 to ascii format and store to param2... */
      count = -1;
      for ( i = 0; i < len; i++ )
      {
         count++;
         if ((param1[i] & 0xF0) == 0xD0)
           param2[count] = (char) '-';
         else
           param2[count] = (char) ((param1[i] >> 4) + 0x30);

         count++;
         if ((param2[i] & 0x0F) == 0x0D)
           param2[count] = (char) '-';
   	   else
           param2[count] = (char) ((param1[i] & 0x0F) + 0x30);

      }

      /* update Clipper parameter ascii buffer with param2... */
      _storclen(param2, (int) len *2, ABYREF);

      /* release allocated memory for param2... */
      _xfree(param2);
      
      _retni(NORMAL);
   }
   else
      _retni(INVALID_PARAM);
}


