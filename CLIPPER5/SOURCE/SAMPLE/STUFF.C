/***
*
*  Stuff.c
*
*  Clipper STUFF() function
*
*  Copyright (c) 1990-1993, Computer Associates International, Inc.
*  All rights reserved.
*
*/

#include "Extend.api"
#include "Vm.api"
#include "error.api"
#include "error.ch"

#define E_SWAPMEM			5300

/***
*
*	bcopy()
*
*	shift 'count' bytes of memory
*
*/

HIDE void bcopy(BYTEP to, BYTEP from, USHORT count)

{
	while ( count-- )
		*to++ = *from++;
}




/***
*
*  StuffC()
*
*  Remove characters from a string and insert characters
*	from a second string (C callable).
*
*	StuffC( str, len, pos, del, iStr, iLen )
*
*	Remove 'del' characters from 'str' starting at 'pos',
*	insert all characters from 'iStr' in their place.  'len'
*	is the logical length of 'str' and 'iLen' is the logical
*	length of 'iStr'.  The lengths need not be the same and
*	either can be zero.
*
*  If a VM segment can not be allocated, it will generate an error.
*
*/

HIDE void StuffC( BYTEP str, USHORT len, USHORT pos, USHORT del,
					   BYTEP iStr, USHORT iLen )

{
	long oLen;
	BYTEP sResult;
   HANDLE hResult;
   ERRORP  pError;

   pError = _errNew();

	/* convert origin */
	if ( pos > 0 )
		pos--;

	/* limit params */
	if ( pos > len )
		pos = len;

	if ( del > len - pos )
		del = len - pos;

	/* use long to verify size without overflow */
	oLen = (long)len + (long)iLen - (long)del;
	if ( oLen > 0L && oLen < 65500L )
	{
		/* allocate workspace from virtual memory */
      if ( ( ( hResult = _xvalloc( (USHORT)oLen + 1, 0 ) ) != NULL ) &&
         ( ( sResult = _xvlock( hResult ) ) != NULL ) )
         {
   		  /* build the sResult string */
		     bcopy( sResult, str, pos );
		     bcopy( &sResult[pos], iStr, iLen );
		     bcopy( &sResult[pos + iLen], &str[pos + del], len - (pos + del) );
		     sResult[oLen] = NIL;

		     /* return string to Clipper */
		    _retclen(sResult, (USHORT)oLen);
          _xvunlock( hResult );
          _xvfree( hResult );
	      }
	   else
         {
           _errPutGenCode( pError, EG_MEM );
           _errPutSubCode( pError, E_SWAPMEM );
           _errPutSubSystem( pError, "BASE" );
           _errPutFlags( pError, EF_CANDEFAULT );
           _errPutSeverity( pError, ES_ERROR );

           _errLaunch( pError );

         }
	}
	else
		_retc("");

   _errRelease( pError );  

}




/***
*
*	STUFF()
*
*	Replace 'del' number of characters in 'str' starting at 'pos'
*		with the entire 'iStr' string.
*
*	result = STUFF(str, pos, del, iStr)
*
*		result      -   character string.       
*		str         -   character string.
*		pos         -   numeric.
*		del         -   numeric.
*		iStr        -   character string.
*
*/

CLIPPER STUFF(void)

{
	if (PCOUNT == 4 && ISCHAR(1) &&
		ISNUM(2) && ISNUM(3) && ISCHAR(4) )
	{
		StuffC(_parc(1), _parclen(1), _parni(2),
			   _parni(3), _parc(4), _parclen(4));
	}
	else
		_retc("");
}


