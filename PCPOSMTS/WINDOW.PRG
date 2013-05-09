#include "its.ch"
#include "box.ch"

static wstack := {}
static woldclr
memvar getlist

#define WTOP	   wstack[len(wstack), 1]
#define WLEFT     wstack[len(wstack), 2]
#define WBOTTOM   wstack[len(wstack), 3]
#define WRIGHT    wstack[len(wstack), 4]
#define WCONTENTS wstack[len(wstack), 5]

/*============================================================================
	Window Create
============================================================================*/
function window(t, l, b, r, w_color, w_borders )

	w_color := if (w_color = NIL, setcolor(), w_color )

	aadd (wstack, { t, l, b, r, savescreen (t, l, b, r ) } )
	woldclr := setcolor()	// Save old color first!

	if w_borders == NIL
      @ t, l, b, r BOX B_SINGLE + ' ' COLOR  w_color
	else
		@ t, l, b, r BOX w_borders + ' ' COLOR w_color
	endif


return nil

/*============================================================================
	Window Kill
============================================================================*/
function KillWindow()

	if ! empty (wstack)
		restscreen ( WTOP, WLEFT, WBOTTOM, WRIGHT, WCONTENTS )
		asize (wstack, len(wstack) - 1)
	endif
	setcolor( woldclr )	// Restore old color.

return nil

/*============================================================================
	Return Row Position
============================================================================*/
FUNCTION it999052 ( _offrow )
	
RETURN 	if (empty(wstack), 0, WTOP + _offrow )

 
/*============================================================================
	Return Column Position
============================================================================*/
FUNCTION it999053 ( _offcol )
	
RETURN 	if (empty(wstack), 0, WLEFT + _offcol )

/*============================================================================
	Window Clear
============================================================================*/
FUNCTION it999054

	if ! empty (wstack)
		scroll (WTOP + 1, WLEFT + 1, WBOTTOM - 1, WRIGHT - 1, 0 )
	endif

RETURN NIL

/*============================================================================
	Window SAY
============================================================================*/
FUNCTION it999055 ( wrow, wcol, wtext, wcolor )
	// Determine current output device
local cOldDevice := set(20)

	// Force output to screen.
	set (20, "SCREEN" )

	if ! empty (wstack)
		if wcolor == NIL
			@ it999052 (wrow), it999053 (wcol) say wtext color "W+*/B"
		else
			@ it999052 (wrow), it999053 (wcol) say wtext color wcolor
		endif

	endif

	// Restore output device.
	set (20, cOldDevice)

RETURN NIL

/*============================================================================
	Window PROMPT
============================================================================*/
FUNCTION it999056 ( wrow, wcol, wtext )

	// Determine current output device
	LOCAL cOldDevice := set (20)

	// Force output to screen.
	set (20, "SCREEN" )

	if ! empty (wstack)
		@ it999052 (wrow), it999053 (wcol) prompt wtext
	endif

	// Restore output device.
	set (20, cOldDevice)

RETURN NIL

function Heading(cTitle1,cTitle2)
local cSaveColor
   cSaveColor:=SetColor(if(iscolor(),"W+/B","W+/N+"))        // Change color to White on Blue.
   // Display title on center-top row.
   scroll(00, 00, 00, maxcol())
   if empty(cTitle2)
     @ 00,00 say padc(cTitle1,maxcol()+1)
   else
     @ 00,00 say cTitle1 
     @ 00,maxcol()-len(cTitle2) say cTitle2
   endif  
     
   SetColor(cSaveColor)                // Return original color.
return nil                             // Value returned: NIL

function Message(cMessage,nUnit)
local cSaveColor,cUnit,k,cCol 

   cSaveColor:=SetColor(if(iscolor(),"GR+/B","N+/W")) // Change color to White on Cyan.

   if !empty(cMessage)
     if Len(cMessage)>maxcol()                    // Is string > 69 characters?
        cMessage:=SubStr(cMessage,1,maxcol()-10)  // Yes -- truncate to 69 chars only.
                                                // For This module we need 10 msg 
                                                // space for unit or warehouse msg.
     endif 

     @ maxrow(),00 clear to maxrow(),maxcol()-10 // Clear bottom row.
     @ maxrow(),00 say " "+cMessage                  // Display message on bottom row.
   endif

   if nUnit != Nil
     if nUnit == 0
        cUnit := "WAREHOUSE"
     else
        cUnit := "UNIT# "+padl(alltrim(str(nUnit)),3,"0")
     endif
     @ maxrow(),70 say chr(179)+cUnit 
   endif

   SetColor(cSaveColor)                      // Return original color.
return nil                                   // Value returned: NIL

#ifdef COLOR_STAT
function Msgbar(cMessage)
 cMessage := subs(cMessage,1,138)
 cMessage += repl(chr(32)+chr(30),138-len(cMessage))
 RestScreen(maxrow(),1,maxrow(),maxcol()-10,cMessage)
return nil     
#else
function Msgbar(cMessage)
return message(cMessage)
#endif

