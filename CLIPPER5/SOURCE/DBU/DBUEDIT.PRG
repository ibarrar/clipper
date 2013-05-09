/***
*
*  Dbuedit.prg
*
*  DBU Data File Editing Module
*
*  Copyright (c) 1990-1993, Computer Associates International, Inc.
*  All rights reserved.
*
*/

#include "inkey.ch"
#include "memoedit.ch"

#define TB_REFRESH_RATE    5     // Wait 5 seconds between tbrowse refreshes


/***
*	browse
*
*	browse one file or the entire View
*/
proc browse

local i,j,nHelpSave,cNtx,cFieldArray,cFieldName,nWa,cMemo,oB,nRec,;
	cBrowseBuf,nPrimeArea,nHsepRow,cEditField,bAlias,cAlias,nCType,;
	cHead,lMore,lCanAppend,cMemoBuff,aMoveExp,cPrimeDbf,;
   nColorSave,lAppend,lGotKey,lKillAppend,bColBlock

/*
 nRefreshTimer forces refresh of browse every TB_REFRESH_RATE seconds
 This serves the purpose of keeping the browse up to date in case we're
 running on a network.
*/
local nRefreshTimer  := SECONDS()
local anCursPos[2]

memvar keystroke,help_code,func_sel,cur_area,cur_dbf,field_list,frame,;
	curs_on,cur_ntx,ntx1,dbf,local_func,box_open,;
	color1,color7,color8,color9

	/* turn off cursor */
	nCType := SetCursor(0)
	curs_on := .f.

	/* save prev help code */
	nHelpSave := help_code

	/* save, clear, and frame the window */
	cBrowseBuf := SaveScreen(8, 0, 23, 79)

	/* array to save move_ptr expressions */
	aMoveExp := Array(4)
	AFill(aMoveExp, "")

	/* heading separator row if only one database */
	nHsepRow := 11

	/* determine what to browse */
	if ( func_sel == 1 )
		/* browse one file */
		nPrimeArea := cur_area
		cFieldArray := "field_n" + Substr("123456", cur_area, 1)
		cNtx := "ntx" + Substr("123456", cur_area, 1)
		cur_ntx := &cNtx[1]
		cPrimeDbf := Substr(cur_dbf, Rat("\", cur_dbf) + 1)
		lCanAppend := .T.
	else
		/* browse the entire view */
		nPrimeArea := 1
		cFieldArray := "field_list"
		cur_ntx := ntx1[1]
		cPrimeDbf := Substr(dbf[1], Rat("\", dbf[1]) + 1)
		lCanAppend := .F.

		if ( "->" $ field_list[afull(field_list)] )
			nHsepRow := 12
		end
	end

	/* block to extract alias from alias->field */
	bAlias := &("{|i| if('->' $" + cFieldArray + "[i], Substr(" +;
				cFieldArray + "[i], 1, At('->'," + cFieldArray +;
				"[i]) - 1), '')}")

	Select(nPrimeArea)
	if ( Eof() )
		/* end of file not allowed */
		go top
	end

	/* misc */
	lAppend := .F.
	nRec := 0

	/* create TBrowse object */
	nColorSave := SetColor(color7)
	oB := TBrowseDB(10, 1, 23, 78)

	oB:headSep := "мям"
	oB:colSep  := " Ё "
	oB:footSep := "мом"
	oB:skipBlock := {|x| Skipped(x, lAppend)}

	/* put columns into browse */
	j := Len(&cFieldArray)
	for i := 1 TO j
		if ( Empty(&cFieldArray[i]) )
			EXIT
		end

		/* determine workarea/alias stuff */
		cEditField := &cFieldArray[i]
		if ( "->" $ cEditField )
			cAlias := Substr(cEditField, 1, At("->", cEditField) + 1)
			cFieldName := Substr(cEditField, At("->", cEditField) + 2)
			cHead := cAlias + ";" + cFieldName
			nWa := Select(cAlias)
		else
			cAlias := ""
			cFieldName := cHead := cEditField
			nWa := Select()
		end

		/* memos are handled differently */
		if ( ValType(&cEditField) == "M" )
			bColBlock := &("{|| '  <Memo>  '}")
		else
			bColBlock := FieldWBlock(cFieldName, nWa)
		end

		/* add one column */
		oB:addColumn(TBColumnNew(cHead, bColBlock))
	next

	/* initialize parts of screen not handled by TBrowse */
	stat_msg("")
	scroll(8, 0, 23, 79, 0)
	@ 8, 0, 23, 79 BOX frame
	@ nHsepRow, 0 SAY "ф"
	@ nHsepRow, 79 SAY "╣"

	/* init rest of locals */
	cAlias := ""
	lKillAppend := .f.
	if ( (LastRec() == 0) .and. lCanAppend )
		/* empty file..force append mode */
		keystroke := K_DOWN
		lGotKey := .t.
	else
		lGotKey := .f.
	end

	lMore := .t.
	while (lMore)

		if ( !lGotKey )
			/* keystroke will interrupt stabilize */
			while ( !oB:stabilize() )
				if ( (keystroke := Inkey()) != 0 )
					lGotKey := .t.
					exit
				end
			end
		end

		if ( !lGotKey )
			if ( oB:hitBottom .and. lCanAppend )
				/* turn on or continue append mode */
				if ( !lAppend .or. Recno() != LastRec() + 1 )
					if ( lAppend )
						/* continue append mode */
                  oB:refreshCurrent():forceStable()
						go bottom
					else
						/* first append */
						lAppend := .t.
						SetCursor(1)
						curs_on := .t.
					end

					/* move down and stabilize to set rowPos */
               oB:down():forceStable()
				end
			end

			/* display status */
			cAlias := Eval(bAlias, oB:colPos)
			statline(oB, lAppend, cAlias)

			/* stabilize again for correct cursor pos */
         WHILE !oB:stabilize() ; END

         // If TB_REFRESH_RATE seconds has elapsed, refresh the browse
         // This is neccessary on a network environment to insure updated
         // browses for each user
         WHILE (( keystroke := INKEY()) == 0 )
            IF (( nRefreshTimer + TB_REFRESH_RATE ) < SECONDS() )
               DISPBEGIN()
               anCursPos := { ROW(), COL() }
               FreshOrder( oB )
               StatLine( oB, lAppend, cAlias )
               SETPOS( anCursPos[1], anCursPos[2] )
               DISPEND()
               nRefreshTimer := SECONDS()
            ENDIF
         END

		else
			/* reset for next loop */
			lGotKey := .f.
		end

		do case
		case keystroke == K_DOWN
			if ( lAppend )
				oB:hitBottom := .t.
			else
				oB:down()
			end

		case keystroke == K_UP
			if ( lAppend )
				lKillAppend := .t.
			else
				oB:up()
			end

		case keystroke == K_PGDN
			if ( lAppend )
				oB:hitBottom := .t.
			else
				oB:pageDown()
			end

		case keystroke == K_PGUP
			if ( lAppend )
				lKillAppend := .t.
			else
				oB:pageUp()
			end

		case keystroke == K_CTRL_PGUP
			if ( lAppend )
				lKillAppend := .t.
			else
				oB:goTop()
			end

		case keystroke == K_CTRL_PGDN
			if ( lAppend )
				lKillAppend := .t.
			else
				oB:goBottom()
			end

		case keystroke == K_RIGHT
			oB:right()

		case keystroke == K_LEFT
			oB:left()

		case keystroke == K_HOME
			oB:home()

		case keystroke == K_END
			oB:end()

		case keystroke == K_CTRL_LEFT
			oB:panLeft()

		case keystroke == K_CTRL_RIGHT
			oB:panRight()

		case keystroke == K_CTRL_HOME
			oB:panHome()

		case keystroke == K_CTRL_END
			oB:panEnd()

		case keystroke == K_DEL
			/* toggle deleted() flag */
         oB:forceStable()
			cAlias := Eval(bAlias, oB:colPos)
			if ( !Empty(cAlias) )
				Select(cAlias)
			end

			if ( Recno() != Lastrec() + 1 )
            IF NetRLock()

               // We've got a lock...
               // If the record is deleted, recall it, and vice-versa
               IF DELETED()
                  RECALL
               ELSE
                  DELETE
               END

               COMMIT
               UNLOCK

            ENDIF
			end

			Select(nPrimeArea)

		case keystroke == K_INS
			/*toggle insert mode */
			tog_insert()

		case keystroke == K_RETURN
			/* edit the current field */

         if EmptyFile() .and. !lAppend
            keyboard chr( K_DOWN ) + chr( nextkey() )
            loop
         endif

         oB:forceStable()

			cAlias := Eval(bAlias, oB:colPos)

			if ( !Empty(cAlias) )
				Select(cAlias)
			end

	 		if ( !lAppend .and. (Recno() == LastRec() + 1) )
				Select(nPrimeArea)
				loop	/* NOTE */
			end

			Select(nPrimeArea)

			/* make sure the display is correct */
			oB:hitTop := .f.
			Statline(oB, lAppend, cAlias)
         WHILE !oB:stabilize() ; END

			cEditField := &cFieldArray[oB:colPos]

			/* turn the cursor on */
			SetCursor(1)
			curs_on := .t.

			if ( Type(cEditField) == "M" )
				/* edit memo field */
				help_code := 19
				box_open := .t.

				/* save, clear, and frame window for memoedit */
				cMemoBuff := SaveScreen(10, 10, 22, 69)

				SetColor(color8)
				Scroll(10, 10, 22, 69, 0)
				@ 10, 10, 22, 69 BOX frame

				/* use fieldspec for title */
				SetColor(color9)
				@ 10,((76 - Len(cEditField)) / 2) SAY "  " + cEditField + "  "

				/* edit the memo field */
				SetColor(color8)
				cMemo := MemoEdit(&cEditField, 11, 11, 21, 68,.T.,"xmemo")

				if Lastkey() == K_CTRL_END
					/* ^W..new memo confirmed */

               BEGIN SEQUENCE
                  IF ( lAppend .and. Eof() )
                     /* First data in new record */
                     IF !NetAppBlank()
                        BREAK    // Abort since we couldn't append
                     ENDIF
                  ELSE
                     /* Just editing... */
                     IF !NetRLock()
                        BREAK    // Abort since we couldn't lock it
                     ENDIF
                  END

                  REPLACE &cEditField WITH cMemo
                  COMMIT
                  UNLOCK

               END SEQUENCE

					/* move to next field */
					keystroke := K_RIGHT
					lGotKey := .t.
				else
					keystroke := 0
				end

				/* restore the window */
				RestScreen(10, 10, 22, 69, cMemoBuff)
				box_open := .F.
			else
				/* regular data entry */
				SetColor(color1)
				keystroke := DoGet(oB, lAppend, cAlias)
				lGotKey := ( keystroke != 0 )
			end

         lKillAppend := .T.

			/* turn off the cursor unless append mode */
			if ( !lAppend )
				SetCursor(0)
				curs_on := .f.
			end

			help_code := nHelpSave
			SetColor(color7)

		otherwise
			if ( isdata(keystroke) )
				/* forward data keystroke to GET system */
				if !EmptyFile() .or. lCanAppend
					keyboard Chr(K_RETURN) + Chr(keystroke)
				endif
			else
				/* check for menu request */
				sysmenu()

				do case
				case q_check()
					/* exit */
					lMore := .f.

				case local_func == 1
					/* help requested */
					DO syshelp

				case local_func == 7
					/* move option selected..only the primary can be moved */
					nRec := Recno()
					move_ptr(aMoveExp, cPrimeDbf)

					if ( nRec != Recno() )
						if ( lAppend )
							/* no more append mode */
							lKillAppend := .t.
						else
							FreshOrder(oB)
						end
					end
				end
			end
		end

		if ( lKillAppend )
			/* turn off append mode */
			lKillAppend := .f.
			lAppend := .f.

			/* refresh respecting any change in index order */
			FreshOrder(oB)
			SetCursor(0)
			curs_on := .f.
      end

	end

	/* restore the screen */
	RestScreen(8, 0, 23, 79, cBrowseBuf)
	SetColor(nColorSave)
	SetCursor(nCType)
	curs_on := (nCType != 0)
	stat_msg("")

return


/***
*	xmemo()
*
*	memoedit user function
*/
func xmemo(mmode, line, col)
local nRet
memvar keystroke,local_func

	nRet := 0

	if mmode <> ME_IDLE
		/* check for menu request */
		keystroke := Lastkey()
		sysmenu()

		do case
		case local_func == 1
			/* help requested */
			do syshelp

		case keystroke == K_INS
			/* insert key pressed */
			tog_insert()
			nRet := ME_IGNORE

		case keystroke == K_ESC
			/* escape key pressed */
			if mmode == ME_UNKEYX
				/* memo has been altered */
				if rsvp("Ok To Lose Changes? (Y/N)") <> "Y"
					/* no exit if not confirmed (32 == ignore) */
					nRet := ME_IGNORE
				end
			end
		end
	end

return (nRet)


/***
*	tog_insert()
*
*	ditto
*/
static func tog_insert
local nCType

	Readinsert(!Readinsert())
	nCType := SetCursor(0)
	show_insert()
	SetCursor(nCType)

return (0)


/***
*	show_insert()
*
*	display current insert mode
*/
static func show_insert
local nColorSave

	nColorSave := SetColor(color7)
	@ 9,4 say if(ReadInsert(), "<Insert>", "        ")
	SetColor(nColorSave)

return (0)


/***
*	statline()
*
*	update the status line in the browse window
*/
static func statline(oB, lAppend, cAlias)
local cColorSave, cCurrAlias, lNoFilter, nWaSave, nCType

	/* preserve current state */
	nCType := SetCursor(0)

	nWaSave := Select()
	if ( !Empty(cAlias) )
		Select(cAlias)
	end

	cColorSave := SetColor(color7)

	/* show current mode */
	show_insert()

	/* show filter status */
	lNoFilter := Empty(&("kf" + Substr("123456", Select(), 1)))
	@ 9,16 say if(lNoFilter, "        ", "<Filter>")

	/* display record pointer information */
	@ 9,41 say if(Empty(cAlias), space(10), Lpad(cAlias + "->", 10));
			   + "Record "

	if ( EmptyFile() .and. .not. lAppend )
		/* file is empty */
		@ 9,58 say "<none>               "
	elseif ( Eof() )
		/* no record number if eof */
		@ 9,28 say "         "
		@ 9,58 say "                " + if(lAppend, "<new>", "<eof>")
	else
		/* normal record..display recno()/lastrec() and deleted() */
		@ 9,28 say if(Deleted(), "<Deleted>", "         ")
		@ 9,58 say Pad(Ltrim(Str(Recno())) + "/" + Ltrim(Str(Lastrec())),15)+;
				   If(oB:hitTop, " <bof>", if(oB:hitBottom, " <eof>", "      "))
	end

	/* restore state */
	SetColor(cColorSave)
	Select(nWaSave)
	SetCursor(nCType)

return (0)


/***
*	move_ptr()
*
*	seek, goto, locate, skip
*
*	the following array is defined and initialized in browse:
*		aMoveExp[1] == the last SEEK expression
*		aMoveExp[2] == the last GOTO value
*		aMoveExp[3] == the last LOCATE expressions
*		aMoveExp[4] == the last SKIP value
*/
static func move_ptr(aMoveExp, cPrimeDbf)

local nHelpSave,aBox
memvar okee_dokee, k_trim, movp_sel, titl_str, exp_label
memvar help_code,local_sel,ntx_expr
private okee_dokee, k_trim, movp_sel, titl_str, exp_label, ntx_expr

	nHelpSave := help_code

	/* save function select number */
	movp_sel := local_sel

	/* initialize expression to previous value, if any */
	k_trim := aMoveExp[movp_sel]

	/* set up for multibox */
	aBox := Array(4)

	aBox[1] := "movp_title(sysparam)"
	aBox[2] := "movp_exp(sysparam)"
	aBox[3] := "ok_button(sysparam)"
	aBox[4] := "can_button(sysparam)"

	do case
	case movp_sel == 1
		/* seek */
		okee_dokee := "do_seek()"
		titl_str := "Seek in file " + cPrimeDbf + "..."
		exp_label := "Expression"
		ntx_expr := Indexkey(0)
		help_code := 13

	case movp_sel == 2
		/* goto */
		okee_dokee := "do_goto()"
		titl_str := "Move pointer in file " + cPrimeDbf + " to..."
		exp_label := "Record#"
		help_code := 14

	case movp_sel == 3
		/* locate */
		okee_dokee := "do_locate()"
		titl_str := "Locate in file " + cPrimeDbf + "..."
		exp_label := "Expression"
		help_code := 10

	case movp_sel == 4
		/* skip */
		okee_dokee := "do_skip()"
		titl_str := "Skip records in file " + cPrimeDbf + "..."
		exp_label := "Number"
		help_code := 20
	end

	/* do it */
	set key K_INS to tog_insert
	multibox(14, 17, 5, 2, aBox)
	set key K_INS to

	/* save expression for next time */
	aMoveExp[movp_sel] := k_trim

	help_code := nHelpSave

return (0)


/***
*	movp_title()
*
*	display title for move pointer functions
*/
func movp_title(sysparam)
memvar titl_str
return (box_title(sysparam, titl_str))


/***
*	movp_exp()
*
*	get parameter for move pointer
*/
func movp_exp(sysparam)
memvar exp_label
return (get_k_trim(sysparam, exp_label))


/***
*	do_seek()
*
*	seek to expression
*/
func do_seek

local lDone, nRec, cSeekType
memvar k_trim,ntx_expr

	lDone := .F.

	if Empty(k_trim)
		error_msg("Expression not entered")
	else
		stat_msg("Searching...")

		/* save record number in case no find */
		nRec := Recno()

		/* determine type for seek */
		cSeekType := Type(ntx_expr)

		/* try it */
		do case
		case cSeekType == "C"
			/* character search */
			seek k_trim

		case cSeekType == "N"
			/* numeric search */
			seek Val(k_trim)

		case cSeekType == "D"
			/* date search */
			seek Ctod(k_trim)
		end

		if Found()
			/* operation complete */
			stat_msg("Found")
			lDone := .T.
		else
			/* consider this an error..start over */
			error_msg("Not found")
			goto nRec
		end
	end

return (lDone)


/***
*	do_goto()
*
*	go to record number
*/
func do_goto

local lDone, nWhich
memvar k_trim

	lDone := .F.
	nWhich := Val(k_trim)		&& convert to number

	do case
	case Empty(k_trim)
		error_msg("Record number not entered")

	case .not. Substr(Ltrim(k_trim), 1, 1) $ "-+1234567890"
		error_msg("Record number not numeric")

	case nWhich <= 0 .or. nWhich > Lastrec()
		error_msg("Record out of range")

	otherwise
		/* operation complete */
		goto nWhich
		lDone := .T.

	end

return (lDone)


/***
*	do_locate()
*
*	locate expression
*/
func do_locate

local lDone, nRec
memvar k_trim

	lDone := .F.

	do case
	case Empty(k_trim)
		error_msg("Expression not entered")

	case Type(k_trim) <> "L"
		error_msg("Expression Type must be Logical")

	otherwise
		/* save record number in case no find */
		nRec := Recno()
		stat_msg("Searching...")

		if &k_trim
			/* current record meets the condition */
			skip
		end

		/* search forward to end of file */
		locate for &k_trim while .T.

		if Found()
			/* operation complete */
			stat_msg("Found")
			lDone := .T.

		else
			/* consider this an error..start over */
			error_msg("Not found")
			goto nRec
		end
	end

return (lDone)


/***
*	do_skip()
*
*	skip number of records
*/
func do_skip

local lDone, nSkip
memvar k_trim

	lDone := .F.
	nSkip := Val(k_trim)		&& convert to number

	do case
	case Empty(k_trim)
		error_msg("Skip value not entered")

	case .not. Substr(Ltrim(k_trim), 1, 1) $ "-+1234567890"
		error_msg("Skip value not numeric")

	case nSkip == 0
		error_msg("Skip value zero")

	otherwise
		/* no out of range or over-skip error */
		lDone := .T.

		skip nSkip

		if Eof()
			/* over-skip..clear eof flag */
			go bottom
		end

		if Bof()
			/* over-skip..clear bof flag */
			go top
		end
	end

return (lDone)


/***
*	EmptyFile()
*/

static func EmptyFile()

	if (LastRec() == 0 )
		return (.t.)
	end

	if ( (Eof() .or. Recno() == LastRec() + 1) .and. Bof() )
		return (.t.)
	end

return (.f.)


/***
*	DoGet()
*
*	Edit the current field
*/

static func DoGet(oB, lAppend, cAlias)

local lExitSave, oCol, oGet, nKey, cExpr, xEval
local lFresh, mGetVar, nWaSave

	/* save state */
	lExitSave := Set(_SET_EXIT, .t.)
	nWaSave := Select()
	if ( !Empty(cAlias) )
		Select(cAlias)
	end

	/* set insert key to toggle insert mode and cursor */
	set key K_INS to tog_insert
	xkey_clear()

	/* get the controlling index key */
	cExpr := IndexKey(0)
	if ( !Empty(cExpr) )
		/* expand key expression for later comparison */
		xEval := &cExpr
	end

	/* get column object from browse */
	oCol := oB:getColumn(oB:colPos)

	/* use temp for safety */
	mGetVar := Eval(oCol:block)

	/* create a corresponding GET with ambiguous set/get block */
	oGet := GetNew(Row(), Col(),									;
				   {|x| if(PCount() == 0, mGetVar, mGetVar := x)},	;
				   "mGetVar")

   /* setup a scrolling GET if it's too long to fit on the screen */
   if oGet:type == "C" .AND. LEN( oGet:varGet() ) > 78
      oGet:picture := "@S78"
   endif

	/* refresh flag */
	lFresh := .f.

	/* read it */
   BEGIN SEQUENCE
      if ( ReadModal( {oGet} ) )
         /* new data has been entered */
         if ( lAppend .and. Recno() == LastRec() + 1 )
            /* new record confirmed */
            IF !NetAppBlank()
               BREAK    // Let's bail out, we couldn't APPEND BLANK
            ENDIF
         end

         IF NetRLock()
            Eval(oCol:block, mGetVar)  // Replace with new data
         ELSE
            BREAK                      // Abort change, we couldn't RLOCK()
         ENDIF

         // We appended and/or locked successfully, so now we commit and unlock
         COMMIT
         UNLOCK

         /* test for change in index order */
         if ( !Empty(cExpr) .and. !lAppend )
            if ( xEval != &cExpr )
               /* change in index key eval */
               lFresh := .t.
            end
         end
      end
   END SEQUENCE

	Select(nWaSave)
	if ( lFresh )
		/* record in new indexed order */
		FreshOrder(oB)

		/* no other action */
		nKey := 0
	else
		/* refresh the current row only */
		oB:refreshCurrent()

		/* certain keys move cursor after edit if no refresh */
		nKey := ExitKey(lAppend)
	end

	/* restore state */
	Set(_SET_EXIT, lExitSave)
	set key K_INS to
	xkey_norm()

return (nKey)


/***
*	ExitKey()
*
*	Determine the follow-up action after editing a field
*/

static func ExitKey(lAppend)

memvar keystroke

	keystroke := LastKey()
	if ( keystroke == K_PGDN )
		/* move down if not append mode */
		if ( lAppend )
			keystroke := 0
		else
			keystroke := K_DOWN
		end

	elseif ( keystroke == K_PGUP )
		/* move up if not append mode */
		if ( lAppend )
			keystroke := 0
		else
			keystroke := K_UP
		end

	elseif ( keystroke == K_RETURN .or. isdata(keystroke) )
		/* return key or type out..move right */
		keystroke := K_RIGHT

	elseif (keystroke != K_UP .and. keystroke != K_DOWN .and. menu_key() == 0)
		/* no other action */
		keystroke := 0
	end

return (keystroke)


/***
*	FreshOrder()
*
*	Refresh respecting any change in index order
*/

static func FreshOrder(oB)

local nRec

	nRec := Recno()
	oB:refreshAll()

	/* stabilize to see if TBrowse moves the record pointer */
   oB:forceStable()

	if ( nRec != LastRec() + 1 )
		/* record pointer may move if bof is on screen */
		while ( Recno() != nRec .and. !ob:hitTop )
			/* falls through unless record is closer to bof than before */
         oB:up():forceStable()
		end
	end

return (NIL)


/***
*	Skipped(n)
*
*	Skip thru database and return the
*	actual number of records skipped
*/

static func Skipped(nRequest, lAppend)

local nCount

	nCount := 0
	if ( LastRec() != 0 )
		if ( nRequest == 0 )
			skip 0

		elseif ( nRequest > 0 .and. Recno() != LastRec() + 1 )
			/* forward */
			while ( nCount < nRequest )
				skip 1
				if ( Eof() )
					if ( lAppend )
						/* eof record allowed if append mode */
						nCount++
					else
						/* back to last actual record */
						skip -1
					end

					exit
				end

				nCount++
			end

		elseif ( nRequest < 0 )
			/* backward */
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


/* eof dbuedit.prg */