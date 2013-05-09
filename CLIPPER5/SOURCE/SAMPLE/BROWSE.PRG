/***
*
*  Browse.prg
*
*  Database browse function
*
*  Copyright (c) 1990-1993, Computer Associates International Inc.
*  All rights reserved.
*
*  Compile: /n
*
*/

#include "inkey.ch"
#include "setcurs.ch"


// This code block will toggle insert mode and cursor
static bInsToggle := {|| SetCursor( if( ReadInsert( !ReadInsert() ), ;
                                        SC_NORMAL, SC_INSERT ))      }


/***
*
*  Browse( [nTop], [nLeft], [nBottom], [nRight] )
*
*	View, add, change, delete
*
*/
function browse( nTop, nLeft, nBottom, nRight )

local oB, n, lMore, cScrSave, lAppend, lKillAppend,;
      nKey, nCursSave, lGotKey, bKeyBlock

	if ( !Used() )
		// no database in use
		return (.f.)
	end

	if ( Pcount() < 4 )
		nTop    := 1
		nLeft   := 0
		nBottom := maxrow()
		nRight  := maxcol()
	end

	cScrSave := saveScreen(nTop, nLeft, nBottom, nRight)

	// frame window
	@ nTop, nLeft, nBottom, nRight box "ÕÍ¸³¾ÍÔ³"
	@ nTop + 3, nLeft say "Æ"
	@ nTop + 3, nRight say "µ"

	// clear status row
	@ nTop + 1, nLeft + 1 say Space(nRight - nLeft - 1)

	// create a TBrowse object for a database
	oB := TBrowseDB(nTop + 2, nLeft + 1, nBottom - 1, nRight - 1)
	oB:headSep := " Í"
	oB:skipBlock := {|x| Skipped(x, lAppend)}

	// add one column for each field
	for n := 1 to Fcount()
		oB:addColumn( TBColumnNew(FieldName(n), FieldBlock(FieldName(n))))
	next

	if ( Eof() )
		go top
	end

	// init
	lAppend := lKillAppend := .F.
	nCursSave := SetCursor(0)
	while ( !oB:stabilize() ) ; end

	if ( LastRec() == 0 )
		// empty file..force append mode
		nKey := K_DOWN
		lGotKey := .t.
	else
		lGotKey := .f.
	end

	lMore := .t.
	while (lMore)
		if ( !lGotKey )
			// stabilization will be interrupted by any keystroke
			while ( !oB:stabilize() )
				if ( (nKey := Inkey()) != 0 )
					lGotKey := .t.
					exit
				end
			end
		end

		if ( !lGotKey )
			// the TBrowse object is stable
			if ( oB:hitBottom )
				if ( !lAppend .or. Recno() != LastRec() + 1 )
					if ( lAppend )
						// continue appending..restore color to current row
						oB:refreshCurrent()
						while ( !oB:stabilize() ) ; end

						// ensure bottom of file without refresh
						go bottom
					else
						// begin append mode
						lAppend := .t.

						// turn the cursor on
						SetCursor( if(ReadInsert(), SC_INSERT, SC_NORMAL) )
					end

					// move to next row and stabilize to set rowPos
					oB:down()
					while ( !oB:stabilize() ) ; end

					// color the row
					oB:colorRect({oB:rowPos,1,oB:rowPos,oB:colCount},{2,2})
				end
			end

			// display status and stabilize again for correct cursor pos
			Statline(oB, lAppend)
			while ( !oB:stabilize() ) ; end

			// idle
			nKey := Inkey(0)

			if ( (bKeyBlock := SetKey(nKey)) != NIL )
				// run SET KEY block
				Eval(bKeyBlock, ProcName(1), ProcLine(1), "")
				loop	// NOTE
			end
		else
			// reset for next loop
			lGotKey := .f.
		end

		do case
		case ( nKey == K_DOWN )
			if ( lAppend )
				oB:hitBottom := .t.
			else
				oB:down()
			end

		case ( nKey == K_UP )
			if ( lAppend )
				lKillAppend := .t.
			else
				oB:up()
			end

		case ( nKey == K_PGDN )
			if ( lAppend )
				oB:hitBottom := .t.
			else
				oB:pageDown()
			end

		case ( nKey == K_PGUP )
			if ( lAppend )
				lKillAppend := .t.
			else
				oB:pageUp()
			end

		case ( nKey == K_CTRL_PGUP )
			if ( lAppend )
				lKillAppend := .t.
			else
				oB:goTop()
			end

		case ( nKey == K_CTRL_PGDN )
			if ( lAppend )
				lKillAppend := .t.
			else
				oB:goBottom()
			end

		case ( nKey == K_RIGHT )
			oB:right()

		case ( nKey == K_LEFT )
			oB:left()

		case ( nKey == K_HOME )
			oB:home()

		case ( nKey == K_END )
			oB:end()

		case ( nKey == K_CTRL_LEFT )
			oB:panLeft()

		case ( nKey == K_CTRL_RIGHT )
			oB:panRight()

		case ( nKey == K_CTRL_HOME )
			oB:panHome()

		case ( nKey == K_CTRL_END )
			oB:panEnd()

		case ( nKey == K_INS )
			// toggle insert mode and cursor if append mode
			if ( lAppend )
				Eval(bInsToggle)
			end

		case ( nKey == K_DEL )
			// delete key..toggle deleted() flag
			if ( Recno() != LastRec() + 1 )
				if ( Deleted() )
					recall
				else
					delete
				end
			end

		case ( nKey == K_RETURN )
			// edit
			if ( lAppend .or. Recno() != LastRec() + 1 )
				nKey := DoGet(oB, lAppend)

				// use returned value as next key if not zero
				lGotKey := ( nKey != 0 )
			else
				// begin append mode
				nKey := K_DOWN
				lGotKey := .t.
			end

		case ( nKey == K_ESC )
			// exit browse
			lMore := .f.

		otherwise
			if ( nKey >= 32 .and. nKey <= 255 )
				// begin edit and supply the first character
				keyboard Chr(K_RETURN) + Chr(nKey)
			end
		end

		if ( lKillAppend )
			// turn off append mode
			lKillAppend := .f.
			lAppend := .f.

			// refresh respecting any change in index order
			FreshOrder(oB)
			SetCursor(0)
		end
	end

	// restore
	SetCursor(nCursSave)
	restScreen(nTop, nLeft, nBottom, nRight, cScrSave)

return (.t.)



/***
*
*	DoGet()
*
*	Edit the current field
*
*/
static func DoGet( oB, lAppend )

local bInsSave, lScoreSave, lExitSave
local oCol, oGet, nKey, cExpr, xEval
local lFresh, nCursSave, mGetVar
local cForCond

	// make sure the display is correct
	oB:hitTop := .f.
	Statline(oB, lAppend)
	while ( !oB:stabilize() ) ; end

	// save state
	lScoreSave := Set(_SET_SCOREBOARD, .f.)
	lExitSave := Set(_SET_EXIT, .t.)

	// set insert key to toggle insert mode and cursor
	bInsSave := SetKey(K_INS, bInsToggle)

	// turn the cursor on
	nCursSave := SetCursor( if(ReadInsert(), SC_INSERT, SC_NORMAL) )

	// get the controlling index key
	cExpr := IndexKey(0)
	if ( !Empty(cExpr) )
		// expand key expression for later comparison
		xEval := &cExpr
	end

	// get column object from browse
	oCol := oB:getColumn(oB:colPos)

	// use temp for safety
	mGetVar := Eval(oCol:block)

	// create a corresponding GET with ambiguous set/get block
	oGet := GetNew(Row(), Col(),									;
				   {|x| if(PCount() == 0, mGetVar, mGetVar := x)},	;
				   "mGetVar",, oB:colorSpec)

	// refresh flag
	lFresh := .f.

	// read it
	if ( ReadModal( {oGet} ) )
		// new data has been entered
		if ( lAppend .and. Recno() == LastRec() + 1 )
			// new record confirmed
			APPEND BLANK
		end

		// replace with new data
		Eval(oCol:block, mGetVar)

      // test for dropping out of a conditional index
      if ( !lAppend .AND. !empty( cForCond := ordFor( IndexOrd() )))
         if !( &( cForCond ))
            dbGoTop()
         endif
      endif

      // test for change in index order
      if ( !lAppend .and. !Empty(cExpr) )
         if ( xEval != &cExpr )
            // change in index key eval
            lFresh := .t.
         end
      end

	end

	if ( lFresh )
		// record in new indexed order
		FreshOrder(oB)

		// no other action
		nKey := 0
	else
		// refresh the current row only
		oB:refreshCurrent()

		// certain keys move cursor after edit if no refresh
		nKey := ExitKey(lAppend)
	end

	if ( lAppend )
		// maintain special row color
		oB:colorRect({oB:rowPos,1,oB:rowPos,oB:colCount}, {2,2})
	end

	// restore state
	SetCursor(nCursSave)
	Set(_SET_SCOREBOARD, lScoreSave)
	Set(_SET_EXIT, lExitSave)
	SetKey(K_INS, bInsSave)

return (nKey)



/***
*
*	ExitKey()
*
*	Determine the follow-up action after editing a field
*
*/
static func ExitKey(lAppend)

local nKey

	nKey := LastKey()
	if ( nKey == K_PGDN )
		// move down if not append mode
		if ( lAppend )
			nKey := 0
		else
			nKey := K_DOWN
		end

	elseif ( nKey == K_PGUP )
		// move up if not append mode
		if ( lAppend )
			nKey := 0
		else
			nKey := K_UP
		end

	elseif ( nKey == K_RETURN .or. (nKey >= 32 .and. nKey <= 255) )
		// return key or type out..move right
		nKey := K_RIGHT

	elseif ( nKey != K_UP .and. nKey != K_DOWN )
		// no other action
		nKey := 0
	end

return (nKey)



/***
*
*	FreshOrder()
*
*	Refresh respecting any change in index order
*
*/
static func FreshOrder(oB)

local nRec

	nRec := Recno()
	oB:refreshAll()

	// stabilize to see if TBrowse moves the record pointer
	while ( !oB:stabilize() ) ; end

	if ( nRec != LastRec() + 1 )
		// record pointer may move if bof is on screen
		while ( Recno() != nRec .AND. !BOF() )
			// falls through unless record is closer to bof than before
			oB:up()
			while ( !oB:stabilize() ) ; end
		end
	end

return (NIL)



/***
*
*	Statline()
*
*	display status at coordinates relative to TBrowse object
*
*/
static func Statline(oB, lAppend)

local nTop, nRight

	nTop := oB:nTop - 1
	nRight := oB:nRight

	@ nTop, nRight - 27 say "Record "
	if ( LastRec() == 0 .and. !lAppend )
		// file is empty
		@ nTop, nRight - 20 say "<none>               "
	elseif ( Recno() == LastRec() + 1 )
		// no record number if eof
		@ nTop, nRight - 40 say "         "
		@ nTop, nRight - 20 say "                <new>"
	else
		// normal record..display Recno()/LastRec() and Deleted()
		@ nTop, nRight - 40 say If(Deleted(), "<Deleted>", "         ")
		@ nTop, nRight - 20 say Pad(Ltrim(Str(Recno())) + "/" +;
									Ltrim(Str(LastRec())), 16) +;
								If(oB:hitTop, "<bof>", "     ")
	end

return (NIL)



/***
*
*  Skipped( n )
*
*	Skip thru database and return the
*	actual number of records skipped
*
*/
static func Skipped( nRequest, lAppend )

local nCount

	nCount := 0
	if ( LastRec() != 0 )
		if ( nRequest == 0 )
			skip 0

		elseif ( nRequest > 0 .and. Recno() != LastRec() + 1 )
			// forward
			while ( nCount < nRequest )
				skip 1
				if ( Eof() )
					if ( lAppend )
						// eof record allowed if append mode
						nCount++
					else
						// back to last actual record
						skip -1
					end

					exit
				end

				nCount++
			end

		elseif ( nRequest < 0 )
			// backward
			while ( nCount > nRequest )
				skip -1
				if ( Bof() )
					exit
				end

				nCount--
			end
		end
	end

return (nCount)


// eof browse.prg

