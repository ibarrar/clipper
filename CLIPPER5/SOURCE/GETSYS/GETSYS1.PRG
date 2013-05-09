/***
*	Getsys.prg
*  Standard Clipper 5.2 GET/READ subsystem
*
*	NOTE: compile with /n/w
*
*  ************************************
*  WARNING: MODIFIED VERSION!!!!!!!!!!!
*  ************************************
*
*/

#include "Set.ch"
#include "Inkey.ch"
#include "Getexit.ch"

#define K_UNDO          K_CTRL_U


// state variables for active READ
static Format
static Updated := .f.
static KillRead
static BumpTop
static BumpBot
static LastExit
static LastPos
static ActiveGet
static ReadProcName
static ReadProcLine


// format of array used to preserve state variables
#define GSV_KILLREAD		1
#define GSV_BUMPTOP			2
#define GSV_BUMPBOT			3
#define GSV_LASTEXIT		4
#define GSV_LASTPOS			5
#define GSV_ACTIVEGET		6
#define GSV_READVAR 		7
#define GSV_READPROCNAME	8
#define GSV_READPROCLINE	9

#define GSV_COUNT			9

// Modifications
#ifndef NOCHANGES

// Time-out variable
STATIC lTimedOut := .F.
STATIC nTimeOut

// GOTOGET and START AT get variable
STATIC nToGet

// Exit at Get variable
STATIC nAtGet

#endif

/***
*	ReadModal()
*	Standard modal READ on an array of GETs.
*/

#ifndef NOCHANGES
FUNCTION ReadModal( GetList, nTime, nStartAt )
#else
func ReadModal( GetList )
#endif

local get
local pos
local savedGetSysVars

#ifndef NOCHANGES
   nTimeOut  := IF(nTime == NIL, 0, nTime)
   lTimedOut := .F.

#endif

	if ( ValType(Format) == "B" )
		Eval(Format)
	end

	if ( Empty(getList) )
		// S87 compat.
        SetPos( MaxRow()-1, 0 )
		return (.f.)			// NOTE
	end


	// preserve state vars
	savedGetSysVars := ClearGetSysVars()

	// set these for use in SET KEYs
	ReadProcName := ProcName(1)
	ReadProcLine := ProcLine(1)


#ifndef NOCHANGES
   IF nStartAt != NIL
      pos := nStartAt

   ELSE
#endif

	// set initial GET to be read
	pos := Settle( Getlist, 0 )

#ifndef NOCHANGES
   ENDIF
#endif

	while ( pos <> 0 )

		// get next GET from list and post it as the active GET
		get := GetList[pos]
		PostActiveGet( get )


		// read the GET
		if ( ValType( get:reader ) == "B" )
			Eval( get:reader, get ) 		// use custom reader block
		else
			GetReader( get )				// use standard reader
		end


#ifndef NOCHANGES
      nAtGet := pos

#endif

      // move to next GET based on exit condition
		pos := Settle( GetList, pos )

   end


	// restore state vars
	RestoreGetSysVars(savedGetSysVars)

	// S87 compat.
    SetPos( MaxRow()-1, 0 )

return (Updated)



/***
*	GetReader()
*	Standard modal read of a single GET.
*/
proc GetReader( get )


	// read the GET if the WHEN condition is satisfied
	if ( GetPreValidate(get) )

		// activate the GET for reading
		get:SetFocus()

		while ( get:exitState == GE_NOEXIT )

			// check for initial typeout (no editable positions)
			if ( get:typeOut )
				get:exitState := GE_ENTER
			end

			// apply keystrokes until exit
			while ( get:exitState == GE_NOEXIT )
#ifndef NOCHANGES
            GetApplyKey( get, MyInkey() )

#else
				GetApplyKey( get, Inkey(0) )
#endif

			end

			// disallow exit if the VALID condition is not satisfied
			if ( !GetPostValidate(get) )
				get:exitState := GE_NOEXIT
			end

		end

		// de-activate the GET
		get:KillFocus()

	end

return



/***
*	GetApplyKey()
*	Apply a single Inkey() keystroke to a GET.
*
*	NOTE: GET must have focus.
*/
proc GetApplyKey(get, key)

local cKey
local bKeyBlock


	// check for SET KEY first
	if ( (bKeyBlock := SetKey(key)) <> NIL )

		GetDoSetKey(bKeyBlock, get)
		return									// NOTE

	end


	do case
#ifndef NOCHANGES
      //
      // Time-out
      //
      CASE ( lTimedOut )
         get:undo()
         get:exitState := GE_ESCAPE
#endif

	case ( key == K_UP )
		get:exitState := GE_UP

	case ( key == K_SH_TAB )
		get:exitState := GE_UP

	case ( key == K_DOWN )
		get:exitState := GE_DOWN

	case ( key == K_TAB )
		get:exitState := GE_DOWN

	case ( key == K_ENTER )
		get:exitState := GE_ENTER

	case ( key == K_ESC )
		if ( Set(_SET_ESCAPE) )
			get:undo()
			get:exitState := GE_ESCAPE
		end

	case ( key == K_PGUP )
		get:exitState := GE_WRITE

	case ( key == K_PGDN )
		get:exitState := GE_WRITE

	case ( key == K_CTRL_HOME )
		get:exitState := GE_TOP


#ifdef CTRL_END_SPECIAL

	// both ^W and ^End go to the last GET
	case (key == K_CTRL_END)
		get:exitState := GE_BOTTOM

#else

	// both ^W and ^End terminate the READ (the default)
	case (key == K_CTRL_W)
		get:exitState := GE_WRITE

#endif


	case (key == K_INS)
		Set( _SET_INSERT, !Set(_SET_INSERT) )
		ShowScoreboard()

	case (key == K_UNDO)
		get:Undo()

	case (key == K_HOME)
		get:Home()

	case (key == K_END)
		get:End()

	case (key == K_RIGHT)
		get:Right()

	case (key == K_LEFT)
		get:Left()

	case (key == K_CTRL_RIGHT)
		get:WordRight()

	case (key == K_CTRL_LEFT)
		get:WordLeft()

	case (key == K_BS)
		get:BackSpace()

	case (key == K_DEL)
		get:Delete()

	case (key == K_CTRL_T)
		get:DelWordRight()

	case (key == K_CTRL_Y)
		get:DelEnd()

	case (key == K_CTRL_BS)
		get:DelWordLeft()

	otherwise

		if (key >= 32 .and. key <= 255)

			cKey := Chr(key)

			if (get:type == "N" .and. (cKey == "." .or. cKey == ","))
				get:ToDecPos()

			else
				if ( Set(_SET_INSERT) )
					get:Insert(cKey)
				else
					get:Overstrike(cKey)
				end

				if (get:typeOut .and. !Set(_SET_CONFIRM) )
					if ( Set(_SET_BELL) )
						?? Chr(7)
					end

					get:exitState := GE_ENTER
				end

			end

		end

	endcase

return



/***
*	GetPreValidate()
*	Test entry condition (WHEN clause) for a GET.
*/
func GetPreValidate(get)

local saveUpdated
local when := .t.


	if ( get:preBlock <> NIL )

		saveUpdated := Updated

		when := Eval(get:preBlock, get)

		get:Display()

		ShowScoreBoard()
		Updated := saveUpdated

	end


	if ( KillRead )
		when := .f.
		get:exitState := GE_ESCAPE		// provokes ReadModal() exit

	elseif ( !when )
		get:exitState := GE_WHEN		// indicates failure

	else
		get:exitState := GE_NOEXIT		// prepares for editing

	end

return (when)



/***
*	GetPostValidate()
*	Test exit condition (VALID clause) for a GET.
*
*	NOTE: bad dates are rejected in such a way as to preserve edit buffer.
*/
func GetPostValidate(get)

local saveUpdated
local changed, valid := .t.


	if ( get:exitState == GE_ESCAPE )
		return (.t.)					// NOTE
	end

	if ( get:BadDate() )
		get:Home()
		DateMsg()
		ShowScoreboard()
		return (.f.)					// NOTE
	end


	// if editing occurred, assign the new value to the variable
	if ( get:changed )
		get:Assign()
		Updated := .t.
	end


	// reform edit buffer, set cursor to home position, redisplay
	get:Reset()


	// check VALID condition if specified
	if ( get:postBlock <> NIL )

		saveUpdated := Updated

		// S87 compat.
        SetPos( get:row, get:col + Len(get:buffer) )

		valid := Eval(get:postBlock, get)

		// reset compat. pos
		SetPos( get:row, get:col )

		ShowScoreBoard()
		get:UpdateBuffer()

		Updated := saveUpdated

		if ( KillRead )
			get:exitState := GE_ESCAPE	// provokes ReadModal() exit
			valid := .t.
		end

	end

return (valid)




/***
*	GetDoSetKey()
*	Process SET KEY during editing.
*/
proc GetDoSetKey(keyBlock, get)

local saveUpdated


	// if editing has occurred, assign variable
	if ( get:changed )
		get:Assign()
		Updated := .t.
	end


	saveUpdated := Updated

	Eval(keyBlock, ReadProcName, ReadProcLine, ReadVar())

	ShowScoreboard()
	get:UpdateBuffer()

	Updated := saveUpdated


	if ( KillRead )
		get:exitState := GE_ESCAPE		// provokes ReadModal() exit
	end

return



/**************************
*
*	READ services
*
*/



/***
*	Settle()
*
*	Returns new position in array of Get objects, based on
*
*		- current position
*		- exitState of Get object at current position
*
*	NOTE return value of 0 indicates termination of READ
*	NOTE exitState of old Get is transferred to new Get
*/
static func Settle(GetList, pos)

local exitState


	if ( pos == 0 )
		exitState := GE_DOWN
	else
		exitState := GetList[pos]:exitState
	end


	if ( exitState == GE_ESCAPE .or. exitState == GE_WRITE )
		return ( 0 )					// NOTE
	end


	if ( exitState <> GE_WHEN )
		// reset state info
		LastPos := pos
		BumpTop := .f.
		BumpBot := .f.

	else
		// re-use last exitState, do not disturb state info
		exitState := LastExit

	end


	/***
	*	move
	*/
	do case
	case ( exitState == GE_UP )
		pos --

	case ( exitState == GE_DOWN )
		pos ++

	case ( exitState == GE_TOP )
		pos := 1
		BumpTop := .T.
		exitState := GE_DOWN

	case ( exitState == GE_BOTTOM )
		pos := Len(GetList)
		BumpBot := .T.
		exitState := GE_UP

	case ( exitState == GE_ENTER )
		pos ++

#ifndef NOCHANGES
   CASE ( exitState < 0 .AND. -exitState <= LEN(GetList))
      pos := -exitState
      exitState := GE_NOEXIT

#endif

	endcase


	/***
	*	bounce
	*/
	if ( pos == 0 ) 						// bumped top

		if ( !ReadExit() .and. !BumpBot )
			BumpTop := .T.
			pos := LastPos
			exitState := GE_DOWN
		end

	elseif ( pos == Len(GetList) + 1 )		// bumped bottom

		if ( !ReadExit() .and. exitState <> GE_ENTER .and. !BumpTop )
			BumpBot := .T.
			pos := LastPos
			exitState := GE_UP
		else
			pos := 0
		end
	end


	// record exit state
	LastExit := exitState

	if ( pos <> 0 )
		GetList[pos]:exitState := exitState
	end

return (pos)



/***
*	PostActiveGet()
*	Post active GET for ReadVar(), GetActive().
*/
static proc PostActiveGet(get)

	GetActive( get )
	ReadVar( GetReadVar(get) )

	ShowScoreBoard()

return



/***
*	ClearGetSysVars()
*	Save and clear READ state variables. Return array of saved values.
*
*	NOTE: 'Updated' status is cleared but not saved (S87 compat.).
*/
static func ClearGetSysVars()

local saved[ GSV_COUNT ]


	saved[ GSV_KILLREAD ] := KillRead
	KillRead := .f.

	saved[ GSV_BUMPTOP ] := BumpTop
	BumpTop := .f.

	saved[ GSV_BUMPBOT ] := BumpBot
	BumpBot := .f.

	saved[ GSV_LASTEXIT ] := LastExit
	LastExit := 0

	saved[ GSV_LASTPOS ] := LastPos
	LastPos := 0

	saved[ GSV_ACTIVEGET ] := GetActive( NIL )

	saved[ GSV_READVAR ] := ReadVar( "" )

	saved[ GSV_READPROCNAME ] := ReadProcName
	ReadProcName := ""

	saved[ GSV_READPROCLINE ] := ReadProcLine
	ReadProcLine := 0

	Updated := .f.

return (saved)



/***
*   RestoreGetSysVars()
*	Restore READ state variables from array of saved values.
*
*	NOTE: 'Updated' status is not restored (S87 compat.).
*/
static proc RestoreGetSysVars(saved)

	KillRead := saved[ GSV_KILLREAD ]

	BumpTop := saved[ GSV_BUMPTOP ]

	BumpBot := saved[ GSV_BUMPBOT ]

	LastExit := saved[ GSV_LASTEXIT ]

	LastPos := saved[ GSV_LASTPOS ]

	GetActive( saved[ GSV_ACTIVEGET ] )

	ReadVar( saved[ GSV_READVAR ] )

	ReadProcName := saved[ GSV_READPROCNAME ]

	ReadProcLine := saved[ GSV_READPROCLINE ]

return



/***
*	GetReadVar()
*	Set READVAR() value from a GET.
*/
static func GetReadVar(get)

local name := Upper(get:name)


//#ifdef SUBSCRIPT_IN_READVAR
local i

	/***
	*	The following code includes subscripts in the name returned by
	*	this function, if the get variable is an array element.
	*
	*	Subscripts are retrieved from the get:subscript instance variable.
	*
	*	NOTE: incompatible with Summer 87
	*/

	if ( get:subscript <> NIL )
		for i := 1 to len(get:subscript)
			name += "[" + ltrim(str(get:subscript[i])) + "]"
		next
	end

//#endif

return (name)



/**********************
*
*	system services
*
*/



/***
*   __SetFormat()
*	SET FORMAT service
*/
func __SetFormat(b)
	Format := if ( ValType(b) == "B", b, NIL )
return (NIL)


/***
*	__KillRead()
*   CLEAR GETS service
*/
proc __KillRead()
	KillRead := .t.
return


/***
*	GetActive()
*/
func GetActive(g)
local oldActive := ActiveGet
	if ( PCount() > 0 )
		ActiveGet := g
	end
return ( oldActive )


/***
*	Updated()
*/
func Updated()
return (Updated)


/***
*	ReadExit()
*/
func ReadExit(lNew)
return ( Set(_SET_EXIT, lNew) )


/***
*	ReadInsert()
*/
func ReadInsert(lNew)
return ( Set(_SET_INSERT, lNew) )



/**********************************
*
*	wacky compatibility services
*
*/


// display coordinates for SCOREBOARD
#define SCORE_ROW		0
#define SCORE_COL		60


/***
*   ShowScoreboard()
*/
static proc ShowScoreboard()

local nRow, nCol


    if ( Set(_SET_SCOREBOARD) )
        nRow := Row()
        nCol := Col()

		SetPos(SCORE_ROW, SCORE_COL)
		DispOut( if(Set(_SET_INSERT), "Ins", "   ") )
        SetPos(nRow, nCol)
	end

return



/***
*	DateMsg()
*/
static proc DateMsg()

local nRow, nCol


    if ( Set(_SET_SCOREBOARD) )
		nRow := Row()
		nCol := Col()

		SetPos(SCORE_ROW, SCORE_COL)
		DispOut("Invalid Date")
        SetPos(nRow, nCol)

		while ( Nextkey() == 0 )
		end

		SetPos(SCORE_ROW, SCORE_COL)
		DispOut("            ")
        SetPos(nRow, nCol)

	end

return



/***
*   RangeCheck()
*
*	NOTE: unused second param for 5.00 compatibility.
*/

func RangeCheck(get, junk, lo, hi)

local cMsg, nRow, nCol
local xValue


	if ( !get:changed )
		return (.t.)
	end

	xValue := get:VarGet()

	if ( xValue >= lo .and. xValue <= hi )
		return (.t.)									// NOTE
	end

    if ( Set(_SET_SCOREBOARD) )
		cMsg := "Range: " + Ltrim(Transform(lo, "")) + ;
				" - " + Ltrim(Transform(hi, ""))

		if ( Len(cMsg) > MaxCol() )
			cMsg := Substr( cMsg, 1, MaxCol() )
		end

		nRow := Row()
		nCol := Col()

		SetPos( SCORE_ROW, Min(60, MaxCol() - Len(cMsg)) )
		DispOut(cMsg)
        SetPos(nRow, nCol)

		while ( NextKey() == 0 )
		end

		SetPos( SCORE_ROW, Min(60, MaxCol() - Len(cMsg)) )
		DispOut( Space(Len(cMsg)) )
        SetPos(nRow, nCol)

	end

return (.f.)

#ifndef NOCHANGES
/*****
 *
 * Time-Out?
 *
 */

FUNCTION TimedOut()
   RETURN (lTimedOut)

/*****
 *
 * Time-Out feature
 *
 */

STATIC FUNCTION MyInKey()
   LOCAL nKey

   IF (nKey := INKEY(nTimeOut)) == 0
   //
   // If after the wait time
   // keystroke is still 0
   // We are supposed to
   // get out of here.
   // So, lets do it
   //
      lTimedOut := .T.
      __KillRead()

   ENDIF

   RETURN (nKey)

/*****
 *
 * Go to a particular get
 *
 */

FUNCTION GoToGet(nGet)
   GetActive():exitState := -nGet
   RETURN (.T.)   // !!!!NOTE!!!!

/*****
 *
 * What was the Get?
 *
 */

FUNCTION ExitAtGet()
   RETURN (nAtGet)

#endif
