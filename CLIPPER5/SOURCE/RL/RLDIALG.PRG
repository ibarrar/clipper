/***
*
*  Rldialg.prg
*
*  Copyright (c) 1987-1993, Computer Associates International, Inc.
*  All rights reserved.
*
*  Note: Compile with /m /n
*
*/


/***
*
*	multibox()
*
*	sysparam values:
*		1	=	initialize and display
*		2	=	hilite (become the current item)
*		3	=	dehilite (become a non-current item)
*		4	=	become a selected item and return a new state
*
*		note that the above values are interpreted
*			 differently by each function
*
*	states:
*		0	=	abort the process
*		1	=	initialization
*		2	=	pointing (cursor)
*		3	=	entry/selection
*		4	=	complete the process
*
*/
FUNCTION multibox

PARAMETERS wt, wl, wh, beg_curs, boxarray
PRIVATE funcn, sysparam, state, cursor, x
PRIVATE asel, arel, frame, lframe

asel       = 1
arel       = 0
frame      = "ÕÍ¸³¾ÍÔ³"
lframe     = "ÑÍ¸³¾ÍÏ³"

DECLARE box_row[LEN(boxarray)]
DECLARE box_col[LEN(boxarray)]

SAVE SCREEN

@ wt, wl, wt + wh + 1, wl + 45 BOX frame + " "

* state 1 ... initialization
sysparam = 1

FOR cursor = 1 TO LEN(boxarray)
	funcn = boxarray[cursor]
	x = &funcn

	* each function leaves the cursor at its top left corner
	box_row[cursor] = ROW()
	box_col[cursor] = COL()

NEXT

cursor = beg_curs
state = 2

DO WHILE state <> 0 .AND. state <> 4
	* till completed or aborted
	funcn = boxarray[cursor]

	DO CASE

		CASE state = 2
			* pointing state
			sysparam = 2
			x = &funcn

			k = INKEY(0)

			DO CASE

				CASE k = 13 .OR. jisdata(k)
					* change to selection state
					state = 3

				CASE k = 27
					* abort
					state = 0

				OTHERWISE
					* current item becomes uncurrent
					sysparam = 3
					x = &funcn

					* get a new cursor
					cursor = matrix(cursor, k)

			ENDCASE

		CASE state = 3
			* be selected and return a new state
			sysparam = 4
			state = &funcn

	ENDCASE
ENDDO

RESTORE SCREEN

RETURN state



/***
*
*  title()
*
*/
FUNCTION enter_title
PARAMETERS sysparam

IF sysparam = 1
	@ wt + 1, wl + 2 SAY "Enter a filename "

	* set cursor for initialization
	@ wt + 1, wl + 2 SAY ""

ENDIF

RETURN 2



/***
*
*  save_title()
*
*/
FUNCTION save_title
PARAMETERS sysparam

IF sysparam = 1
	* watch out for the length of file, it may exceed the box width (path)
	@ wt + 3, wl + 4 SAY "Save Changes To File " + TRIM(filename) + "?"

	* set cursor for initialization
	@ wt + 3, wl + 4 SAY ""

ENDIF

RETURN 2



/***
*
*  rl_getfil()
*
*  get filename
*
*/
FUNCTION rl_getfil
PARAMETERS sysparam

DO CASE

	CASE sysparam = 1 .OR. sysparam = 3
		@ wt + 3, wl + 2 SAY "File " + SUBSTR(filename, 1, 20)

		IF sysparam = 1
			* set cursor for initialization
			@ wt + 3, wl + 9 SAY ""
		ENDIF

	CASE sysparam = 2
		* be current...hilite
		SET COLOR TO I
		@ wt + 3, wl + 7 SAY SUBSTR(filename, 1, 20)
		SET COLOR TO BG+/B

	CASE sysparam = 4
		* be selected...perform a GET on entry field
		
		Note: any other 'isdata' key will also execute selection
		IF k <> 13
			KEYBOARD CHR(k)
		ENDIF
		
		filename = jenter_rc(filename, wt + 3, wl + 7, 64, "@K!S20")

		SET CURSOR ON
		READ
		SET CURSOR OFF

		IF LASTKEY() = 13 .AND. .NOT. EMPTY(filename)
			* filename has been selected...go to the ok button
			filename = JPAD(filename,20)
			@ wt + 3, wl + 7 SAY filename
			to_ok()
		ENDIF
ENDCASE

RETURN 2



/***
*
*  filelist()
*
*/
FUNCTION filelist
PARAMETERS sysparam
PRIVATE c

DO CASE

	CASE sysparam = 1
		* clear the window
		scroll(wt + 1, wl + 31, wt + wh, wl + 44, 0)
		@ wt, wl + 30, wt + wh + 1, wl + 45 BOX lframe

		IF .NOT. EMPTY(files[1])
			* display the files list
			KEYBOARD CHR(27)
			achoice(wt+1,wl+32,wt+wh,wl+43,files,"ch_func",0,asel,arel)

		ENDIF

		* set cursor for initialization
		@ wt + 1, wl + 32 SAY ""

	CASE sysparam = 2

		IF EMPTY(files[1])
			* cannot cursor onto an empty list
			KEYBOARD CHR(219)

		ELSE
			* set initial relative row and array element
			asel = asel - arel + ROW() - wt - 1
			arel = ROW() - wt - 1

			* do the list selection
			c = achoice(wt+1,wl+32,wt+wh,wl+43,files,"ch_func",0,asel,arel)

			IF LASTKEY() = 13
				* filename selected from list...set memvar
				filename = SUBSTR(files[c] + SPACE(64), 1, 64)

				* display filename in entry blank
				rl_getfil(3)

				* go directly to ok button
				to_ok()

			ELSE

				IF LASTKEY() = 19
					* the system responds to CHR(19) as ^S
					KEYBOARD CHR(219)

				ELSE
					* send character to multibox
					KEYBOARD CHR(LASTKEY())

				ENDIF
			ENDIF
		ENDIF
ENDCASE

RETURN 2



/***
*
*  ok_button()
*
*/
FUNCTION ok_button

PARAMETERS sysparam
PRIVATE ok, reply

ok = " Ok "
reply = 2

DO CASE

	CASE sysparam = 1 .OR. sysparam = 3
		@ wt + wh, wl + 9 SAY ok

		IF sysparam = 1
			* set cursor for initialization
			@ wt + wh, wl + 9 SAY ""

		ENDIF

	CASE sysparam = 2
		* be current...hilite
		SET COLOR TO I
		@ wt + wh, wl + 9 SAY ok
		SET COLOR TO BG+/B

	CASE sysparam = 4

		IF &okee_dokee
			* a job well done...complete the process
			reply = 4
		ENDIF

ENDCASE

RETURN reply



/***
*
*  cancel_button()
*
*/
FUNCTION cancel_button

PARAMETERS sysparam
PRIVATE can, reply

can = " Cancel "
reply = 2

DO CASE

	CASE sysparam = 1 .OR. sysparam = 3
		@ wt + wh, wl + 17 SAY can

		IF sysparam = 1
			* set cursor for initialization
			@ wt + wh, wl + 17 SAY ""

		ENDIF

	CASE sysparam = 2
		* be current...hilite
		SET COLOR TO I
		@ wt + wh, wl + 17 SAY can
		SET COLOR TO BG+/B

	CASE sysparam = 4
		* cancel selected...abort the process
		reply = 0

ENDCASE

RETURN reply



/***
*
*  can_button()
*
*	cancel button for save file box
*
*/
FUNCTION can_button

PARAMETERS sysparam
PRIVATE can, reply

can = " Cancel "
reply = 2

DO CASE

	CASE sysparam = 1 .OR. sysparam = 3
		@ wt + wh, wl + 25 SAY can

		IF sysparam = 1
			* set cursor for initialization
			@ wt + wh, wl + 25 SAY ""

		ENDIF

	CASE sysparam = 2
		* be current...hilite
		SET COLOR TO I
		@ wt + wh, wl + 25 SAY can
		SET COLOR TO BG+/B

	CASE sysparam = 4
		* cancel selected...abort the process
		reply = 0

ENDCASE

RETURN reply



/***
*
*  no_button()
*
*/
FUNCTION no_button

PARAMETERS sysparam
PRIVATE no, reply

no = " No "
reply = 2

DO CASE

	CASE sysparam = 1 .OR. sysparam = 3
		@ wt + wh, wl + 13 SAY no

		IF sysparam = 1
			* set cursor for initialization
			@ wt + wh, wl + 13 SAY ""

		ENDIF

	CASE sysparam = 2
		* be current...hilite
		SET COLOR TO I
		@ wt + wh, wl + 13 SAY no
		SET COLOR TO BG+/B

	CASE sysparam = 4
		* 'No' selected...abort the process
		reply = 0
		no_save_flag = .T.
ENDCASE

RETURN reply



/***
*
*  ch_func()
*
*	achoice user function
*
*/
FUNCTION ch_func

PARAMETERS amod, sel, rel
PRIVATE k, r, srow, scol

srow = ROW()
scol = COL()

asel = sel
arel = rel
r = 2

IF asel > arel + 1
	* more files off screen up
	@ wt + 1, wl + 44 SAY CHR(24)

ELSE
	@ wt + 1, wl + 44 SAY " "

ENDIF

IF LEN(files) - asel > wh - 1 - arel
	* more files off screen down
	@ wt + wh, wl + 44 SAY CHR(25)

ELSE
	@ wt + wh, wl + 44 SAY " "

ENDIF

IF amod = 3
	k = LASTKEY()

	DO CASE

		CASE k = 27
			* escape key
			r = 0

		CASE k = 13 .OR. k = 19 .OR. k = 219
			* return or left arrow
			r = 1

		CASE k = 1
			* home key..top of list
			KEYBOARD CHR(31)

		CASE k = 6
			* end key..end of list
			KEYBOARD CHR(30)

	ENDCASE
ENDIF

@ M->srow, M->scol SAY ""
RETURN r



/***
*
*	do_it()
*
*	called from the "Ok" button as "&okee_dokee"
*	this function normally completes the process
*
*/
FUNCTION do_it

PRIVATE done, error_str

DO CASE

	* error if empty filename
	CASE EMPTY(filename)	&& error, empty filename
		KEYBOARD CHR(5)
		done = .F.

	OTHERWISE
		done = .T.

ENDCASE

RETURN done



/***
*
*  matrix()
*
*	relocate cursor
*
*/
FUNCTION matrix

PARAMETERS old_curs, k
PRIVATE old_row, old_col, test_curs, new_curs

old_row = ROW()
old_col = box_col[old_curs]
new_curs = old_curs
test_curs = old_curs

DO CASE

	CASE k = 19 .OR. k = 219
		* left arrow

		DO WHILE test_curs > 2
			test_curs = test_curs - 1

			IF box_col[test_curs] < old_col .AND. box_row[test_curs] >= old_row

				IF box_row[test_curs] < box_row[new_curs] .OR. new_curs = old_curs
					* best so far
					new_curs = test_curs

				ENDIF
			ENDIF
		ENDDO

	CASE k = 4
		* right arrow

		DO WHILE test_curs < LEN(box_col)
			test_curs = test_curs + 1

			IF box_col[test_curs] > old_col .AND. box_row[test_curs] <= old_row

				IF box_row[test_curs] > box_row[new_curs] .OR. new_curs = old_curs
					* best so far
					new_curs = test_curs

				ENDIF
			ENDIF
		ENDDO

	CASE k = 5
		* up arrow

		DO WHILE test_curs > 2
			test_curs = test_curs - 1

			IF box_row[test_curs] < old_row .AND. box_col[test_curs] <= old_col

				IF box_col[test_curs] > box_col[new_curs] .OR. new_curs = old_curs
					* best so far
					new_curs = test_curs

				ENDIF
			ENDIF
		ENDDO

	CASE k = 24
		* down arrow

		DO WHILE test_curs < LEN(box_row)
			test_curs = test_curs + 1

			IF box_row[test_curs] > old_row .AND. box_col[test_curs] >= old_col

				IF box_col[test_curs] < box_col[new_curs] .OR. new_curs = old_curs
					* best so far
					new_curs = test_curs

				ENDIF
			ENDIF
		ENDDO
ENDCASE

RETURN new_curs



/***
*
*  to_ok()
*
*	go directly to ok button
*
*/
FUNCTION to_ok

cursor = ascan(boxarray, "ok_button(sysparam)")
KEYBOARD CHR(219)
RETURN 0



/***
*
*	jisdata()
*
*	determine if a key is data suitable for entry in place
*
*/
FUNCTION jisdata

PARAMETERS k

RETURN (M->k >= 32 .AND. M->k < 249 .AND. M->k <> 219 .AND. CHR(M->k) <> ";")



/***
*
*	jenter_rc(r,c,max_len,pfunc)
*
*	entry in place
*
*/
FUNCTION jenter_rc

PARAMETERS org_str,r,c,max_len,pfunc
PRIVATE wk_str, keystroke

wk_str = JPAD(org_str, max_len)
SET CURSOR ON

IF .NOT. EMPTY(pfunc)
	@ r,c GET wk_str PICTURE pfunc
ELSE
	@ r,c GET wk_str
ENDIF

READ
SET CURSOR OFF

keystroke = LASTKEY()

IF keystroke = 27
	wk_str = ""
ENDIF

RETURN (TRIM(wk_str))



/***
*
*	jpad()
*
*	syntax: jpad( <expC>, <expN> )
*
*	return: <expC> padded with spaces so that len( <expC> ) = <expN>
*
*/
FUNCTION jpad

PARAMETERS s, n

RETURN(SUBSTR(s + SPACE(n), 1, n))

