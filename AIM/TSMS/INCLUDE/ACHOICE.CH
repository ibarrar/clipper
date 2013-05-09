/***
*	achoice.ch
*	Standard definitions for ACHOICE() user function.
*	Copyright (c) 1990 Nantucket Corp.  All Rights Reserved.
*/


// User function entry modes

#define AC_IDLE			0		// Idle
#define AC_HITTOP		1		// Attempt to cursor past top of list
#define AC_HITBOTTOM	2		// Attempt to cursor past bottom of list
#define AC_EXCEPT		3		// Keystroke exception
#define AC_NOITEM		4		// No selectable items


// User function return codes

#define AC_ABORT		0		// Abort ACHOICE(), return zero
#define AC_SELECT		1		// Select current item, return item index
#define AC_CONT			2		// Continue ACHOICE()
#define AC_GOTO			3		// Go to the next item whose first character
								// matches the last key pressed

