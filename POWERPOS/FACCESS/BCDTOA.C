/*
 * System.......... PowerPos for Spectrum
 * Program I.D..... bcdtoa.c
 * Description..... Functions to convert ascii to bcd format and vice versa
 * Copied by....... Bongý Santiago (used by Alvin Alimbuyuguen)
 * Dialect......... MicroSoft C
*/

#include "extend.h"

#pragma check_stack-

void BCDTOA(char *ascii, unsigned char *bcd, int bcd_len)
{
   int count, i;

   count = -1;
   for (i = 0; i < bcd_len; ++i)
   {
      count++;
      if ((bcd[i] & 0xF0) == 0xD0)
        ascii[count] = (char) '-';
      else
        ascii[count] = (char) ((bcd[i] >> 4) + 0x30);

      count++;
      if ((bcd[i] & 0x0F) == 0x0D)
        ascii[count] = (char) '-';
      else
        ascii[count] = (char) ((bcd[i] & 0x0F) + 0x30);

   }
}

void ATOBCD(char *ascii, unsigned char *bcd, int ascii_len)
{
   int count, i, j;
	char *asc_buf;

	asc_buf = (char *) _xalloc((ascii_len+1)*sizeof(char));
	_bset(asc_buf, 0x0, ascii_len +1);

	for (i = j = 0; i < ascii_len; ++i)
	{
		if (ascii[i] != '.')
			asc_buf[j++] = ascii[i];
	}

	count = 0;
	_bset (bcd, 0, (int) ascii_len/2);

	for (i = 0; i < ascii_len; ++i)
	{
      bcd[count] =  (unsigned char) (((unsigned char) asc_buf[i]) - 0x30);
      bcd[count] =  (unsigned char) (((unsigned char) bcd[count]) << 4);
		bcd[count] += ((unsigned char) asc_buf[++i] & 0x0F);
		count++;
	}

	_xfree(asc_buf);
}

/* EOF */