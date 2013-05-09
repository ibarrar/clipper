/***
*
*  Soundex.c
*
*  Clipper SOUNDEX() function
*
*  Copyright (c) 1990-1993, Computer Associates International, Inc.
*  All rights reserved.
*
*/

#include "extend.api"


/* used below */
#define ISALPHA(c)  ( (c) >= 'a' && (c) <= 'z' || (c) >= 'A' && (c) <= 'Z' )
#define TOUPPER(c)  ( (c) >= 'a' && (c) <= 'z' ? (c) - 'a' + 'A' : (c) )

#define SOUNDEX_LENGTH	4


/***
*   step2()
*   Return soundex result for a single letter.
*/

static char step2(char c)

{
	switch (c)
	{
		case 'B':
		case 'F':
		case 'P':
		case 'V':
			return ('1');

		case 'C':
		case 'G':
		case 'J':
		case 'K':
		case 'Q':
		case 'S':
		case 'X':
		case 'Z':
			return ('2');

		case 'D':
		case 'T':
			return ('3');

		case 'L':
			return ('4');


		case 'M':
		case 'N':
			return ('5');

		case 'R':
			return ('6');

		case 'A':
		case 'E':
		case 'H':
		case 'I':
		case 'O':
		case 'U':
		case 'W':
		case 'Y':
			return (NIL);
	}

	/* bad param -- return something obviously wrong */
	return ('9');
}


/***
*   SoundexC()
*   Convert a string to a soundex code (C-callable).
*
*	"Soundex" algorithm is standard Odell/Russell (1918):
*
*	Produce a code of the form "letter, digit, digit, digit"
*	using these rules:
*
*	1)	Retain the first letter unchanged.
*
*	2)	For each succeeding letter, produce a result based
*		on the following table:
*
*		letter							result
*
*		B, F, P, V						digit 1
*		C, G, J, K, Q, S, X, Z			digit 2
*		D, T							digit 3
*		L								digit 4
*		M, N							digit 5
*		R								digit 6
*		A, E, H, I, O, U, W, Y			(nothing)
*
*
*	3)	If two or more adjacent letters produce the same
*		result in step 2, ignore all but the first of the
*		adjacent letters.
*
*	4)  Repeat steps 2 and 3 until three digits have been
*		produced or until the source is exhausted.
*
*	5)	If less than three digits were produced, right-fill
*		with zeros.
*
*
*	Notes:
*
*	Non-alpha characters are ignored entirely; letters which
*	are separated only by non-alpha characters are considered
*	adjacent.  If the source contains no alpha characters, a
*	value of "0000" is returned.
*
*	Case is not significant.
*
*	Letters which produce (nothing) in step 2 are still
*	significant with respect to step 3.  That is, two letters
*	which produce the same digit are not considered adjacent
*	if they are separated by a letter that produces (nothing).
*	This is in accordance with the original algorithm.
*
*	This C-callable function returns a pointer to a static
*	buffer.  The buffer is overwritten by successive calls.
*/

static char *SoundexC(char *source, short len)

{
	static char code[SOUNDEX_LENGTH+1] = "";

    short i;
    short j;
	char c;
	char result;
	char prev;


	/* make Soundex code */
	for ( i = 0, j = 0, prev = NIL;  i < len && j < SOUNDEX_LENGTH;  i++ )
    {
		c = TOUPPER(source[i]);

		if ( ISALPHA(c) )
		{
			result = step2(c);

			if (j == 0)
			{
				/* retain first letter */
				code[j++] = c;
			}
			else if ( result != NIL && result != prev )
			{
				/* store soundex code */
				code[j++] = result;
			}

			prev = result;
		}
    }


    /* right fill with zeros */
	while (j < SOUNDEX_LENGTH)
		code[j++] = '0';


	return (code);
}


/***
*   SOUNDEX()
*   Convert a string to a "Soundex" code (Clipper-callable).
*
*   cSoundexCode := SOUNDEX(cString)
*/

CLIPPER SOUNDEX(void)

{
    char *code;


    if ( PCOUNT >= 1 && ISCHAR(1) )
	{
		code = SoundexC( _parc(1), _parclen(1) );
	}
	else
	{
		code = "0000";
	}


	_retclen(code, SOUNDEX_LENGTH);
}





