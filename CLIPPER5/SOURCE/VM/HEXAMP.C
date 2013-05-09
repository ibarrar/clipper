// WARNING: Skeletal example!  Don't compile.

// This example creates a segment heap with _xvheapnew() 
// and allocates a memory block in the segment heap.  
// The block is then locked and the string copied into it.  
// Later, the memory block is unlocked, the memory freed,
// and the heap destroyed:

// CA-Clipper include files

#include "extend.api"
#include "vm.api"

// Microsoft C include files
#include "string.h"

#define HEAP_SIZE	4096

BOOL VMHeapExample( BYTEP spSrc )
{
	HANDLE hSegment;
	USHORT uiStringOffset;
	USHORT uiBufflen;
	BYTEP  spString;
	BOOL   bResult = FALSE;

	if (hSegment = _xvheapnew(HEAP_SIZE))
		{
		uiBufflen = strlen(spSrc) + 1;
		uiStringOffset = _xvheapalloc(hSegment, uiBufflen);
		if (uiStringOffset)
			{
			spString = _xvheaplock(hSegment, uiStringOffset);
			if (spString != NULL)
				{
				strcpy(spString, spSrc);

				.
				. <statements>
				.

				bResult = TRUE;

				_xvheapunlock(hSegment, uiStringOffset);
				}
			_xvheapfree(hSegment, uiStringOffset);
			}
		_xvheapdestroy(hSegment);
		}

	return (bResult);
}

