/***
*
*  Dbuutil.prg
*
*  DBU Utilities Module
*
*  Copyright (c) 1990-1993, Computer Associates International, Inc.
*  All rights reserved.
*
*/


******
*	setup()
*
*	put the current View into effect
*
*	note: - data files are open and closed at the time of
*			selection, but everything else is done here
*		  - the global variables need_field, need_ntx,
*			need_relat, and need_filtr prevent re-setting
*			those portions of the View already in effect
******
FUNCTION setup

PRIVATE k, t, n, i, j, field_n, s_alias, k_filter, ntx, file_name,;
		k_1, k_2, k_3, k_4, k_5, k_6, k_7

stat_msg("Setting View")

IF M->need_field
	* assemble master field list
	need_field = .F.

	* get number of fields in old list
	k = afull(M->field_list)

	n = 1
	i = 1

	DO WHILE M->n <= 6 .AND. M->i <= LEN(M->field_list)

		IF EMPTY(dbf[M->n])
			* no more active work areas
			EXIT

		ENDIF

		* access one field list
		field_n = "field_n" + SUBSTR("123456", M->n, 1)

		IF .NOT. EMPTY(&field_n[1])
			* include "alias->" if work area > 1
			s_alias = IF(M->n > 1, name(dbf[M->n]) + "->", "")
			afill(M->field_list, M->s_alias, M->i, afull(&field_n))

			j = 1

			DO WHILE M->j <= LEN(&field_n) .AND. M->i <= LEN(M->field_list)

				IF EMPTY(&field_n[M->j])
					* no more fields in list
					EXIT

				ENDIF

				* "alias->" + fieldname
				field_list[M->i] = field_list[M->i] + &field_n[M->j]

				* next
				i = M->i + 1
				j = M->j + 1

			ENDDO
		ENDIF

		* next work area
		n = M->n + 1

	ENDDO

	IF M->i <= M->k
		* clear fieldnames from longer previous list
		afill(M->field_list, "", M->i)

	ENDIF
ENDIF

IF M->need_ntx
	* set all indexes
	need_ntx = .F.

	n = 1

	DO WHILE M->n <= 6

		IF EMPTY(dbf[M->n])
			* no more active work areas
			EXIT

		ENDIF

		* access one index file list
		ntx = "ntx" + SUBSTR("123456", M->n, 1)

		IF .NOT. EMPTY(&ntx[1])
			* index(s) selected..set 7 variables to index file names
			STORE "" TO k_1,k_2,k_3,k_4,k_5,k_6,k_7

			* select the proper work area
			SELECT (M->n)

			i = 1

			DO WHILE M->i <= 7 .AND. EMPTY(M->view_err)
				* index files must exist

				IF EMPTY(&ntx[M->i])
					* no more files in list
					EXIT

				ENDIF

				* save costly macro-array access
				file_name = &ntx[M->i]

				IF FILE(M->file_name)
					* file exists..place filename in proper variable
					k = "k_" + SUBSTR("1234567", M->i, 1)
					&k = M->file_name
					i = M->i + 1

				ELSE
					view_err = "Can't open index file " + M->file_name

				ENDIF
			ENDDO

			IF EMPTY(M->view_err)
				* null strings are acceptable between the commas
				SET INDEX TO &k_1,&k_2,&k_3,&k_4,&k_5,&k_6,&k_7

			ELSE
				* return with error message
				need_ntx = .T.
				RETURN 0

			ENDIF
		ENDIF

		* next work area
		n = M->n + 1

	ENDDO
ENDIF

IF M->need_relat
	* set all relations
	need_relat = .F.

	* out with the old
	FOR j = 1 TO 5
		SELECT (M->j)
		SET RELATION TO

	NEXT

	j = 1

	DO WHILE M->j <= LEN(M->k_relate)
		* scan the entire active list

		IF EMPTY(k_relate[M->j])
			* no more relations in list
			EXIT

		ENDIF

		* select the source work area
		n = ASC(s_relate[M->j]) - ASC("A") + 1
		SELECT (M->n)

		* key and target to standard variables for macro expansion
		k = k_relate[M->j]
		t = SUBSTR(t_relate[M->j], 2)

		* this additive option is really nice
		SET RELATION ADDITIVE TO &k INTO &t

		* next
		j = M->j + 1

	ENDDO

	* align the entire chain of relations
	SELECT 1
	GO TOP

ENDIF

IF M->need_filtr
	* set all filters
	need_filtr = .F.

	n = 1

	DO WHILE M->n <= 6

		IF EMPTY(dbf[M->n])
			* no more active work areas
			EXIT

		ENDIF

		* access one global filter expression
		k_filter = "kf" + SUBSTR("123456", M->n, 1)

		IF .NOT. EMPTY(&k_filter)
			* set filter to global variable
			SELECT (M->n)

			* expressions must remain in global variables
			DO CASE

				CASE M->n = 1
					SET FILTER TO &kf1

				CASE M->n = 2
					SET FILTER TO &kf2

				CASE M->n = 3
					SET FILTER TO &kf3

				CASE M->n = 4
					SET FILTER TO &kf4

				CASE M->n = 5
					SET FILTER TO &kf5

				CASE M->n = 6
					SET FILTER TO &kf6

			ENDCASE

			* move pointer to first record that meets the condition
			GO TOP

		ENDIF

		* next work area
		n = M->n + 1

	ENDDO
ENDIF

* clear message
stat_msg("")
RETURN 0


**********************
* multibox subsystem *
**********************

******
*	multibox()
*
*	user entry/selection subsystem
*
*	sysparam values:
*		1	=	initialize, display, and report position
*		2	=	hilite (become the current item)
*		3	=	dehilite (become a non-current item)
*		4	=	become a selected item and return a new state
*
*	states:
*		0	=	abort the process
*		1	=	initialization
*		2	=	pointing (cursor)
*		3	=	entry/selection
*		4	=	complete the process
*
*	note: - boxarray[] is an array of character strings that contain
*			the names of functions with one predefined parameter like
*			this: "function(sysparam)"
*		  - each function owns a screen coordinate which it must
*			report during initialization
*		  - each higher element of boxarray[] must have its coordinate at
*			the same or higher column (relative to the previous element)
*			with no two elements having the same row/column combination
******
FUNCTION multibox

PARAMETERS wt, wl, wh, beg_c, boxarray
local saveColor
PRIVATE sysparam, state, cursor, funcn, winbuff, save_help, prime_help,;
		x, colorNorm, colorHilite

colorNorm := color8
colorHilite := color10

* global variable eliminates recursive calls
box_open = .T.

* help codes can be set freely within multibox subsystem
save_help = M->help_code
prime_help = M->help_code

* establish parallel arrays for row and column of each object
DECLARE box_row[LEN(M->boxarray)]
DECLARE box_col[LEN(M->boxarray)]

* save the window
winbuff = SAVESCREEN(M->wt, M->wl, M->wt + M->wh + 1, M->wl + 45)

* clear and frame the window (fixed width, variable height and location)
saveColor := SetColor(M->colorNorm)
scroll(M->wt, M->wl, M->wt + M->wh + 1, M->wl + 45, 0)
@ M->wt, M->wl, M->wt + M->wh + 1, M->wl + 45 BOX frame

* initialize, display, and report position
sysparam = 1

FOR cursor = 1 TO LEN(M->boxarray)
	* call all functions in list
	funcn = boxarray[M->cursor]	&& to normal variable for macro
	x = &funcn					&& call the function
	box_row[M->cursor] = ROW()	&& save row coordinate
	box_col[M->cursor] = COL()	&& save col coordinate

NEXT

cursor = M->beg_c				&& caller decides where to start
state = 2						&& begin with pointing state

DO WHILE M->state <> 0 .AND. M->state <> 4
	* loop until select or abort
	funcn = boxarray[M->cursor]	&& get current function from list

	DO CASE

		CASE M->state = 2
			* pointing state

			IF .NOT. key_ready()
				* hilite
				sysparam = 2
				x = &funcn

				* wait for key
				read_key()

			ENDIF

			DO CASE

				CASE M->keystroke = 13 .OR. isdata(M->keystroke)
					* change to selection state
					state = 3

				CASE M->local_func = 1
					* "help" selected from pull-down menu
					DO syshelp

				CASE q_check()
					* process aborted
					state = 0

				OTHERWISE
					* un-hilite
					sysparam = 3
					x = &funcn

					* move cursor to new object
					cursor = matrix(M->cursor, M->keystroke)

			ENDCASE

		CASE M->state = 3
			* selection state
			sysparam = 4

			* all functions return a state value of 0, 2, or 4
			state = &funcn

	ENDCASE
ENDDO

* restore the window
RESTSCREEN(M->wt, M->wl, M->wt + M->wh + 1, M->wl + 45, M->winbuff)
SetColor(saveColor)

* reset global variables
keystroke = 0				&& not to get confused
box_open = .F.				&& box is closed
help_code = M->save_help	&& original help code

* a returned state of 0 means process aborted
RETURN M->state


******
*	matrix()
*
*	relocate cursor for multibox relative to current position
*
*	note: - the cursor value is a subscript into an array of function
*			names passed to multibox (ex. boxarray[cursor])
*		  - each function owns a screen coordinate which is saved
*			in the arrays box_row[] and box_col[]
*		  - since there is often a function that handles a list, the
*			actual screen row is used to determine vertical position
*		  - since the actual cursor could be anywhere on that row, the
*			reported column in box_col[] is used to determine horizontal
*			position
*		  - the new cursor is a "best guess" move in one of four directions
******
FUNCTION matrix

PARAMETERS old_curs, k
PRIVATE old_row, old_col, test_curs, new_curs

* get current position
old_row = ROW()					&& actual screen row is better for lists
old_col = box_col[M->old_curs]	&& col array..actual cursor could be anywhere

* new value same as old if no movement possible
new_curs = M->old_curs

* beginning value for test probe
test_curs = M->old_curs

DO CASE

	CASE M->k = 19 .OR. M->k = 219
		* left arrow

		DO WHILE M->test_curs > 2
			* test all lower elements except 1 which is always the title
			test_curs = M->test_curs - 1

			IF box_col[M->test_curs] < M->old_col .AND.;
			   box_row[M->test_curs] >= M->old_row
				* never move up while moving left

				IF box_row[M->test_curs] < box_row[M->new_curs];
				   .OR. M->new_curs = M->old_curs
					* but no further down than we have to
					new_curs = M->test_curs

				ENDIF
			ENDIF
		ENDDO

	CASE M->k = 4
		* right arrow

		DO WHILE M->test_curs < LEN(M->box_col)
			* test all higher elements
			test_curs = M->test_curs + 1

			IF box_col[M->test_curs] > M->old_col .AND.;
			   box_row[M->test_curs] <= M->old_row
				* never move down while moving right

				IF box_row[M->test_curs] > box_row[M->new_curs];
				   .OR. M->new_curs = M->old_curs
					* but no further up than we have to
					new_curs = M->test_curs

				ENDIF
			ENDIF
		ENDDO

	CASE M->k = 5
		* up arrow

		DO WHILE M->test_curs > 2
			* test all lower elements except 1 which is always the title
			test_curs = M->test_curs - 1

			IF box_row[M->test_curs] < M->old_row .AND.;
			   box_col[M->test_curs] <= M->old_col
				* never move right while moving up

				IF box_col[M->test_curs] > box_col[M->new_curs];
				   .OR. M->new_curs = M->old_curs
					* but no further left than we have to
					new_curs = M->test_curs

				ENDIF
			ENDIF
		ENDDO

	CASE M->k = 24
		* down arrow

		DO WHILE M->test_curs < LEN(M->box_row)
			* test all higher elements
			test_curs = M->test_curs + 1

			IF box_row[M->test_curs] > M->old_row .AND.;
			   box_col[M->test_curs] >= M->old_col
				* never move left while moving down

				IF box_col[M->test_curs] < box_col[M->new_curs];
				   .OR. M->new_curs = M->old_curs
					* but no further right than we have to
					new_curs = M->test_curs

				ENDIF
			ENDIF
		ENDDO
ENDCASE

RETURN M->new_curs


******
*	to_ok()
*
*	go directly to ok button
*
*	note: this routine depends upon things known and unknown
******
FUNCTION to_ok

* set the cursor to the element before the ok button
cursor = ascan(M->boxarray, "ok_button(sysparam)") - 1

* put a down arrow into the keyboard buffer
KEYBOARD CHR(24)

RETURN 0


******
*	to_can()
*
*	go directly to cancel button
*
*	note: this routine depends  p n th ngs kn wn  nd  nkn wn
******
FUNCTION to_can

* set the cursor to the cancel button
cursor = ascan(M->boxarray, "can_button(sysparam)")

* put a down arrow into the keyboard buffer
KEYBOARD CHR(24)

RETURN 0


******
*	ok_button
*
*	that's a wrap
*
*	note: - the caller of multibox must define the variable
*			"okee_dokee" which contains a character string
*			with the name of a function that takes no
*			parameters (ex. "function()")
*		  - that function will either do whatever it is that
*			multibox was called to do and return logical true,
*			or return logical false meaning incomplete
******
FUNCTION ok_button

PARAMETERS sysparam
local saveColor
PRIVATE ok, reply

* some boxes have secondary help
help_code = M->prime_help

* initialize private variables
ok = " Ok "		&& some button eh?
reply = 2		&& assume incomplete
saveColor := SetColor(M->colorNorm)

DO CASE

	CASE M->sysparam = 1 .OR. M->sysparam = 3
		* initialize or un-hilite
		@ M->wt + M->wh, M->wl + 8 SAY M->ok

		IF M->sysparam = 1
			* report position
			@ M->wt + M->wh, M->wl + 9 SAY ""

		ENDIF

	CASE M->sysparam = 2
		* hilite
		SetColor(M->colorHilite)
		@ M->wt + M->wh, M->wl + 8 SAY M->ok

	CASE M->sysparam = 4 .AND. M->keystroke = 13
		* selected, but only if enter key

		IF &okee_dokee
			* process completed
			reply = 4

		ENDIF
ENDCASE

SetColor(saveColor)
RETURN M->reply


******
*	can_button()
*
*	note: pressing Escape has the same effect
*		  as selecting the cancel button
******
FUNCTION can_button

PARAMETERS sysparam
local saveColor
PRIVATE can, reply

* some boxes have secondary help
help_code = M->prime_help

* initialize private variables
can = " Cancel "	&& a button
reply = 2			&& assume incomplete
saveColor := SetColor(M->colorNorm)

DO CASE

	CASE M->sysparam = 1 .OR. M->sysparam = 3
		* initialize or un-hilite
		@ M->wt + M->wh, M->wl + 17 SAY M->can

		IF M->sysparam = 1
			* report position
			@ M->wt + M->wh, M->wl + 17 SAY ""

		ENDIF

	CASE M->sysparam = 2
		* hilite
		saveColor := SetColor(M->colorHilite)
		@ M->wt + M->wh, M->wl + 17 SAY M->can

	CASE M->sysparam = 4 .AND. M->keystroke = 13
		* selected with the enter key..abort the process
		reply = 0

ENDCASE

SetColor(saveColor)
RETURN M->reply


******
*	filelist()
*
*	select file from list
******
FUNCTION filelist

PARAMETERS sysparam

RETURN itemlist(M->sysparam, 32, "filename", M->files, "*" + M->def_ext, .T.)


******
*	fieldlist()
*
*	select field from list
******
FUNCTION fieldlist

PARAMETERS sysparam

RETURN itemlist(M->sysparam, 34, "field_mvar", "field_m", "Fields", .F.)


******
*	itemlist()
*
*	select item from list
*
*	note: - this list handler only responds to sysparam
*			values of 1 (initialize) and 2 (hilite)
*		  - since both multibox() and achoice() wait for keystrokes,
*			it is necessary to mediate for a smooth user interface
*		  - when sysparam = 2, achoice() is given control after
*			which the select/abort status is resolved before
*			returning control to multibox()
******
FUNCTION itemlist

PARAMETERS sysparam, l_rel, mvar, items, i_title, go_ok
local saveColor
PRIVATE n, x, i_full

* some boxes have secondary help
help_code = M->prime_help
saveColor := SetColor(colorNorm)

* get size of list
i_full = afull(&items)

DO CASE

	CASE M->sysparam = 1
		* clear and frame the list portion of the box
		scroll(M->wt + 1, M->wl + M->l_rel - 1, M->wt + M->wh, M->wl + 44, 0)
		@ M->wt, M->wl + M->l_rel - 2, M->wt + M->wh + 1, M->wl + 45;
		BOX M->lframe

		* format the list title
		i_title = REPLICATE("Ä", ((46 - M->l_rel - LEN(M->i_title)) / 2) - 1);
				  + " " + M->i_title + " "
		i_title = M->i_title + REPLICATE("Ä", (46 - M->l_rel - LEN(M->i_title)))

		* display the list title
		@ M->wt + 1, M->wl + M->l_rel - 1 SAY M->i_title

		IF .NOT. EMPTY(&items[1])
			* display only..do not wait for keystrokes
			achoice(M->wt + 2, M->wl + M->l_rel, M->wt + M->wh, M->wl + 43,;
					&items, .F., "i_func", M->cur_el, M->rel_row)

		ENDIF

		* report position
		@ M->wt + 2, M->wl + M->l_rel SAY ""

	CASE M->sysparam = 2
		* hilite

		IF EMPTY(&items[1])
			* no list..go left
			KEYBOARD(CHR(219))

		ELSE
			* standard list selection..get starting element and row
			cur_el = M->cur_el - M->rel_row + ROW() - M->wt - 2
			rel_row = ROW() - M->wt - 2

			* get selected element or zero if abort
			n = achoice(M->wt + 2, M->wl + M->l_rel, M->wt + M->wh,;
						M->wl + 43, &items, .T., "i_func", M->cur_el,;
						M->rel_row)

			* check for menu request
			sysmenu()

			DO CASE

				CASE M->keystroke = 13
					* item selected..place in variable
					&mvar = &items[M->n]

					* call the specified function to display the selection
					x = &fi_disp

					IF M->go_ok
						* go directly to the ok button for convenience
						to_ok()

					ELSE
						* just move over and down
						KEYBOARD CHR(219) + CHR(24)

					ENDIF

				CASE M->keystroke = 19
					* left arrow..move off list by forwarding to multibox
					* cannot directly keyboard chr(19) because it would be
					*    handled like ^S and halt the system
					KEYBOARD CHR(219)

				CASE M->keystroke = 0
					* menu system has returned either select or abort

					IF M->local_func = 1
						* "help" selected from pull-down menu
						DO syshelp

					ENDIF

					* forward a "do nothing" keystroke to re-enter achoice
					KEYBOARD CHR(11)

				OTHERWISE
					* let multibox() decide
					KEYBOARD CHR(M->keystroke)

			ENDCASE
		ENDIF
ENDCASE

SetColor(saveColor)
RETURN 2


******
*	i_func()
*
*	achoice user function for item list in multibox
******
FUNCTION i_func

PARAMETERS amod, sel, rel
PRIVATE r, srow, scol

* multibox looks at screen coordinates..must save
srow = ROW()
scol = COL()

IF M->error_on
	* erase error message
	error_off()

ENDIF

IF M->amod = 4
	* nothing selectable
	r = 0

ELSE
	* maintain row and element variables
	cur_el = M->sel
	rel_row = M->rel

	* assume continue
	r = 2

	* get latest keystroke
	keystroke = LASTKEY()

ENDIF

IF M->cur_el > M->rel_row + 1
	* first element not on screen
	@ M->wt + 2, M->wl + 44 SAY M->more_up

ELSE
	* first element is on screen
	@ M->wt + 2, M->wl + 44 SAY " "

ENDIF

IF M->i_full - M->cur_el > M->wh - 2 - M->rel_row
	* last element not on screen
	@ M->wt + M->wh, M->wl + 44 SAY M->more_down

ELSE
	* last element is on screen
	@ M->wt + M->wh, M->wl + 44 SAY " "

ENDIF

IF M->amod = 3
	* keystroke exception

	DO CASE

		CASE M->keystroke = 27
			* escape..abort
			r = 0

		CASE M->keystroke = 13 .OR. M->keystroke = 19 .OR. M->keystroke = 219
			* quit achoice no abort..only the enter key will cause selection
			r = 1

		CASE M->keystroke = 1
			* home key..top of list
			KEYBOARD CHR(31)	&& ^PgUp

		CASE M->keystroke = 6
			* end key..end of list
			KEYBOARD CHR(30)	&& ^PgDn

		CASE isdata(M->keystroke)
			* request character search
			r = 3

		CASE menu_key() <> 0
			* abort to menu system
			r = 0

	ENDCASE
ENDIF

* restore screen coordinate
@ M->srow, M->scol SAY ""

RETURN M->r


******
*	getfile()
*
*	accept direct entry of filename in entry field
*
*	note: - the caller of multibox must establish the variables
*			"filename", "def_ext", and "fi_done"
*		  - fi_done contains the name of a function that will
*			decide if a filename is ready to be confirmed
******
FUNCTION getfile

PARAMETERS sysparam, row_off
local saveColor
PRIVATE irow, name_temp

* some boxes have secondary help
help_code = M->prime_help

* calculate absolute row
irow = M->wt + M->row_off
saveColor := SetColor(M->colorNorm)

DO CASE

	CASE M->sysparam = 1 .OR. M->sysparam = 3
		* display
		@ M->irow, M->wl + 2 SAY "File   " + pad(M->filename, 20)

		IF M->sysparam = 1
			* report position
			@ M->irow, M->wl + 9 SAY ""

		ENDIF

	CASE M->sysparam = 2
		* hilite
		SetColor(M->colorHilite)
		@ M->irow, M->wl + 9 SAY pad(M->filename, 20)

	CASE M->sysparam = 4
		* selected..accept input

		IF M->keystroke <> 13
			* forward data keystroke to GET system
			KEYBOARD CHR(M->keystroke)

		ENDIF

		* down arrow will exit READ
		SET KEY 24 TO clear_gets

		* call entry in place function
		name_temp = enter_rc(M->filename,M->irow,M->wl+9,64,"@K!S20",M->color9)

		* release down arrow
		SET KEY 24 TO

		IF .NOT. EMPTY(M->name_temp)
			* something entered

			IF .NOT. (RAT(".", M->name_temp) > RAT("\", M->name_temp))
				* extnesion not entered..provide default
				name_temp = M->name_temp + M->def_ext

			ENDIF

			* place in variable
			filename = M->name_temp

		ELSE

			IF M->keystroke = 13 .OR. M->keystroke = 24
				* accept blank entry
				M->filename = ""

			ENDIF
		ENDIF

		IF M->keystroke = 13
			* entry is deliberate

			IF &fi_done
				* entry is acceptable
				@ M->irow, M->wl + 9 SAY pad(M->filename, 20)

			ENDIF

		ELSE

			IF M->keystroke <> 27 .AND. .NOT. isdata(M->keystroke)
				* something else..forward the keystroke to multibox
				KEYBOARD CHR(M->keystroke)

			ENDIF
		ENDIF
ENDCASE

SetColor(saveColor)
RETURN 2


******
*	g_getfile()
*
*	get filename for filebox function
******
FUNCTION g_getfile

PARAMETERS sysparam

RETURN getfile(M->sysparam, 4)


******
*	genfield()
*
*	process fieldname entry blank (called indirectly from multibox)
******
FUNCTION genfield

PARAMETERS sysparam, is_replace

DO CASE

	CASE M->sysparam = 1 .OR. M->sysparam = 3
		* display
		@ M->wt + 3, M->wl + 2 SAY "Field  " + pad(M->field_mvar, 20)

		IF M->sysparam = 1
			* report position
			@ M->wt + 3, M->wl + 9 SAY ""

		ENDIF

	CASE M->sysparam = 2 .OR. M->sysparam = 4
		* no user entry allowed..deflect the cursor

		IF M->lkey = 5
			* upward movement..bounce right to list
			KEYBOARD CHR(4)

		ELSE
			* moving left from list..bounce down

			IF M->is_replace
				* replace option..move down to expression
				KEYBOARD CHR(24)

			ELSE
				* getfield via set_view

				IF EMPTY(M->field_mvar)
					* nothing to select..go to Cancel
					to_can()

				ELSE
					* go to Ok for confirmation
					to_ok()

				ENDIF
			ENDIF
		ENDIF
ENDCASE

RETURN 2


******
*	get_exp()
*
*	accept input of a general dBASE expression
*
*	note: - the caller of multibox must establish the variable
*			whose name is in the "mvar" parameter
*		  - this function is used for copy, append, replace, and create index
******
FUNCTION get_exp

PARAMETERS sysparam, xlable, row_off, mvar
local saveColor
PRIVATE erow, k_input

* calculate absolute row
erow = M->wt + M->row_off
saveColor := SetColor(M->colorNorm)

DO CASE

	CASE M->sysparam = 1 .OR. M->sysparam = 3
		* display
		@ M->erow, M->wl + 2 SAY M->xlable + pad(&mvar, 20)

		IF M->sysparam = 1
			* report position
			@ M->erow, M->wl + 9 SAY ""

		ENDIF

	CASE M->sysparam = 2
		* hilite
		SetColor(M->colorHilite)
		@ M->erow, M->wl + 9 SAY pad(&mvar, 20)

	CASE M->sysparam = 4
		* selected..accept input

		IF M->keystroke <> 13
			* forward data keystroke to GET system
			KEYBOARD CHR(M->keystroke)

		ENDIF

		* up and down arrows will exit READ
		SET KEY 5 TO clear_gets
		SET KEY 24 TO clear_gets

		* call entry in place function
		k_input = enter_rc(&mvar, M->erow, M->wl + 9, 127, "@KS20", M->color9)

		* release up and down arrows
		SET KEY 5 TO
		SET KEY 24 TO

		IF .NOT. EMPTY(M->k_input)
			* something entered..place in variable
			&mvar = M->k_input

			IF M->keystroke <> 5 .AND. .NOT. isdata(M->keystroke)
				* move down to next entry field
				keystroke = 24

			ENDIF

		ELSE

			IF M->keystroke = 13 .OR. M->keystroke = 5 .OR. M->keystroke = 24
				* accept blank entry
				&mvar = ""

			ENDIF
		ENDIF

		IF M->keystroke <> 13 .AND. M->keystroke <> 27 .AND.;
		   .NOT. isdata(M->keystroke)
			* something else..forward the keystroke to multibox
			KEYBOARD CHR(M->keystroke)

		ENDIF
ENDCASE

SetColor(saveColor)
RETURN 2


******
*	not_empty()
*
*	general item entry preliminary test
******
FUNCTION not_empty

PARAMETERS mvar
PRIVATE done_ok

* accept anything but a blank entry
done_ok = .NOT. EMPTY(&mvar)

IF M->done_ok
	* ready for confirmation
	to_ok()

ENDIF

RETURN M->done_ok


******
*	filebox()
*
*	general file selection using multibox
******
FUNCTION filebox

PARAMETERS def_ext, files, titl_func, do_func, creat_flag, box_top
PRIVATE rel_row, cur_el, fi_disp, okee_dokee, fi_done, bcur

* establish array for multibox
DECLARE boxarray[5]

boxarray[1] = M->titl_func + "(sysparam)"
boxarray[2] = "g_getfile(sysparam)"
boxarray[3] = "ok_button(sysparam)"
boxarray[4] = "can_button(sysparam)"
boxarray[5] = "filelist(sysparam)"

* initialize private variables
cur_el = 1
rel_row = 0
fi_disp = "g_getfile(3)"
fi_done = "not_empty('filename')"
okee_dokee = M->do_func + "()"

IF M->creat_flag
	* assume new filename to be entered

	IF EMPTY(filename)
		* beginning cursor on entry field
		bcur = 2

	ELSE
		* begin on ok button for fast confirmation
		bcur = 3

	ENDIF

ELSE
	* assume list selection preferred
	bcur = 5

ENDIF

* return same value as multibox
RETURN multibox(M->box_top, 17, 7, M->bcur, M->boxarray)


******
*	box_title()
*
*	display the specified title for a selection box
******
FUNCTION box_title

PARAMETERS sysparam, boxtitle

IF M->sysparam = 1
	@ M->wt + 1, M->wl + 2 SAY M->boxtitle
	@ M->wt + 1, M->wl + 2 SAY ""

ENDIF

RETURN 2


******
*	get_k_trim()
*
*	accept character input to the pre-defined variable k_trim
*
*	note: this function is used for the "move" menu options
*		  as well as entry of filter expressions
******
FUNCTION get_k_trim

PARAMETERS sysparam, k_label
local saveColor
PRIVATE k_input

saveColor := SetColor(M->colorNorm)

DO CASE

	CASE M->sysparam = 1 .OR. M->sysparam = 3
		* display
		@ M->wt + 3, M->wl + 2 SAY pad(M->k_label, 12) + pad(M->k_trim, 30)

		IF M->sysparam = 1
			* report position
			@ M->wt + 3, M->wl + 9 SAY ""

		ENDIF

	CASE M->sysparam = 2
		* hilite
		SetColor(M->colorHilite)
		@ M->wt + 3, M->wl + 14 SAY pad(M->k_trim, 30)

	CASE M->sysparam = 4
		* selected..accept input

		IF M->keystroke <> 13
			* forward data keystroke to GET system
			KEYBOARD CHR(M->keystroke)

		ENDIF

		* down arrow will exit READ
		SET KEY 24 TO clear_gets

		* call entry in place function
		k_input = enter_rc(M->k_trim, M->wt + 3, M->wl + 14, 127, "@KS30",;
						   M->color9)

		* release down arrow
		SET KEY 24 TO

		IF .NOT. EMPTY(M->k_input)
			* something entered..place in variable
			k_trim = M->k_input

			* move to ok button
			keystroke = 24

		ELSE

			IF M->keystroke = 13 .OR. M->keystroke = 24
				* accept blank entry
				k_trim = ""

				* move to ok button
				keystroke = 24

			ENDIF
		ENDIF

		IF M->keystroke <> 13 .AND. M->keystroke <> 27 .AND.;
		   .NOT. isdata(M->keystroke)
			* something else..forward the keystroke to multibox
			KEYBOARD CHR(M->keystroke)

		ENDIF
ENDCASE

SetColor(saveColor)
RETURN 2


*************************
* pull-down menu system *
*************************

******
*	sysmenu()
*
*	administrate pull-down menu system
*
*	return: logical true if menu selection or keystroke available
*
*	note: - the menu titles are the same as the function key labels that
*			appear at the top of the screen
*		  - these titles are stored in a global array called func_title[]
*		  - for each title there is a corresponding pair of arrays whose
*			names are &a._m[] and &a._b[] where a = func_title[curr menu]
*		  - the _m arrays contain the menu options and the _b arrays
*			determine the selectability of those options according to
*			the rules of the achoice() function
******
FUNCTION sysmenu
local saveColor
PRIVATE menu_func,menu_sel,menu_buf,a,ml,mr,mb,prev_func,sav_row,sav_col,x

IF M->keystroke = 0
	* nothing happening
	RETURN .F.

ENDIF

* which menu?
menu_func = menu_key()

* always re-set this global selection variable
local_func = 0

IF M->menu_func = 0
	* no menu..regular keystroke
	RETURN .T.

ENDIF

************************
* entering menu system *
************************

* save screen coordinate
sav_row = ROW()
sav_col = COL()

IF M->error_on
	* erase error message
	error_off()

ENDIF

* initialize variables for selection process
menu_sel = 0
prev_func = 0
x = M->menu_func
saveColor := SetColor()

* abort or select
DO WHILE M->menu_func > 0 .AND. M->menu_sel = 0
	* avoid re-draw if menu already displayed
	IF M->menu_func <> M->prev_func
		* pull it on down
		lite_fkey(M->menu_func)				&& hilite title
		prev_func = M->menu_func			&& remember for next loop
		a = func_title[M->menu_func]		&& get name of current menu
		ml = (10 * (M->menu_func - 1)) + 1	&& calculate left coordinate
		mr = ((10 * M->menu_func) - 2)		&& calculate right coordinate
		mb = (2 + LEN(&a._m))				&& calculate bottom coordinate

		* save the window
		menu_buf = SAVESCREEN(2, M->ml - 1, M->mb + 1, M->mr + 1)

		* draw frame for current menu
		SetColor(M->color6)
		@ 2, M->ml - 1, M->mb + 1, M->mr + 1 BOX M->mframe

	ENDIF

	* call achoice() for selection
	SetColor(M->color5)
	menu_sel = achoice(3, M->ml, M->mb, M->mr, &a._m, &a._b, "mu_func",;
					   menu_deflt[M->menu_func], menu_deflt[M->menu_func] - 1)

	* see mu_func() below for setting of keystroke and x
	DO CASE

		CASE M->keystroke = 27
			* abort
			menu_func = 0

		CASE M->keystroke = 4
			* right arrow..next menu with wrap around
			menu_func = IF(M->menu_func < 8, M->menu_func + 1, 1)

		CASE M->keystroke = 19
			* left arrow..previous menu with wrap around
			menu_func = IF(M->menu_func > 1, M->menu_func - 1, 8)

		CASE M->x <> 0
			* directly to a different menu
			menu_func = M->x

	ENDCASE

	IF M->menu_func <> M->prev_func .OR. M->menu_sel <> 0
		* new menu or no menu..restore the screen
		dim_fkey(M->prev_func)
		RESTSCREEN(2, M->ml - 1, M->mb + 1, M->mr + 1, M->menu_buf)

	ENDIF
ENDDO

IF M->menu_func <> 0
	* most recently selected is the new default
	menu_deflt[M->menu_func] = M->menu_sel

ENDIF

IF LTRIM(STR(M->menu_func)) $ M->exit_str
	* selection requires a top level branch
	sysfunc = M->menu_func
	func_sel = M->menu_sel

ELSE
	* selection to be handled locally
	local_func = M->menu_func
	local_sel = M->menu_sel

ENDIF

* restore screen coordinate
@ M->sav_row,M->sav_col SAY ""

* not to be confused
keystroke = 0
SetColor(saveColor)

* return logical true if selection made
RETURN menu_func <> 0


******
*	menu_key()
*
*	translate keystroke into menu number, zero if none
******
FUNCTION menu_key

PRIVATE num

* assume no menu request
num = 0

DO CASE

	CASE M->keystroke = 28
		* F1
		num = 1

	CASE M->keystroke < 0 .AND. M->keystroke > -8
		* F2 - F8 (ex. 1 - (-1) = 2)
		num = 1 - M->keystroke

	CASE M->keystroke >= 249 .AND. M->keystroke < 256
		* F2 - F8..function keys get truncated by the chr() function
		*	(ex. chr(-1) = chr(255)..257 - 255 = 2)
		num = 257 - M->keystroke

ENDCASE

RETURN M->num


******
*	mu_func()
*
*	achoice user function for pull-down menu system
******
FUNCTION mu_func

PARAMETERS amod, sel, rel
PRIVATE r

IF M->amod = 4
	* none selectable..wait for keystroke
	keystroke = INKEY(0)

	* abort selection process
	r = 0

ELSE
	* get latest keystroke
	keystroke = LASTKEY()

	* assume continue selection process
	r = 2

ENDIF

* in case menu key pressed
x = menu_key()

IF M->amod = 3
	* keystroke exception

	DO CASE

		CASE M->keystroke = 13 .OR. M->x = M->menu_func
			* enter key or same function key..select
			r = 1

		CASE M->keystroke = 27 .OR. M->keystroke = 19 .OR.;
			 M->keystroke = 4 .OR. M->x <> 0
			* different menu or no menu..abort from current menu
			r = 0

		CASE M->keystroke = 1
			* home key..top of list (^PgUp)
			KEYBOARD CHR(31)

		CASE M->keystroke = 6
			* end key..end of list (^PgDn)
			KEYBOARD CHR(30)

		CASE isdata(M->keystroke)
			* request character search
			r = 3

	ENDCASE
ENDIF

RETURN M->r


******
*	show_keys()
*
*	display the available function menus
******
FUNCTION show_keys

PRIVATE n

* clear the row
@ 1, 0

FOR n = 1 TO 8
	* display the function key titles
	@ 1,1 + (10 * (M->n - 1)) SAY func_title[M->n]

NEXT

RETURN 0


******
*	xkey_clear()
*
*	cause all menu keys to clear gets and exit a read
******
FUNCTION xkey_clear

PRIVATE i

* F1
SET KEY 28 TO clear_gets

FOR i = 1 TO 7
	* F2 - F8
	SET KEY -(M->i) TO clear_gets

NEXT

RETURN 0


******
*	xkey_norm()
*
*	cause all menu keys to return to normal after xkey_clear
******
FUNCTION xkey_norm

PRIVATE i

* F1
SET KEY 28 TO

FOR i = 1 TO 7
	* F2 - F8
	SET KEY -(M->i) TO

NEXT

RETURN 0


/*****
*	lite_fkey()
*
*	hilite the specified function key label
*/
func lite_fkey(k_num)
local saveColor
memvar color6

	saveColor := SetColor(M->color11)
	@ 1, (10 * (k_num - 1)) say " " + func_title[k_num] + " "
	SetColor(saveColor)

return (0)


/*****
*	dim_fkey()
*
*	un-hilite the specified function key label
*/
func dim_fkey(k_num)
local saveColor
memvar color1

	saveColor := SetColor(M->color1)
	@ 1, (10 * (k_num - 1)) say " " + func_title[k_num] + " "
	SetColor(saveColor)

return (0)


******
*	key_ready()
*
*	return true if key ready or menu select
******
FUNCTION key_ready

* save the previous keystroke
lkey = M->keystroke

* get new keystroke if ready
keystroke = INKEY()

RETURN (sysmenu() .OR. M->keystroke <> 0)


******
*	read_key()
*
*	wait for keystroke or menu select
******
FUNCTION read_key

DO WHILE .NOT. key_ready()
	* wait for keystroke or menu select

ENDDO

IF M->error_on
	* erase error message
	error_off()

ENDIF

RETURN M->keystroke


******
*	raw_key()
*
*	wait for and return next key without checking for menu selection
******
FUNCTION raw_key

PRIVATE k

* wait for key
k = INKEY(0)

IF M->error_on
	* erase error message
	error_off()

ENDIF

RETURN k


******
*	q_check()
*
*	return true to cause exit from a routine
*
*	note: cur_func is set equal to sysfunc at the
*		  top of the main loop of the program
******
FUNCTION q_check

RETURN (M->cur_func <> M->sysfunc .OR. M->keystroke = 27)


******
*	clear_gets
*
*	set keystrokes to this procedure to exit a READ
******
PROCEDURE clear_gets
PARAMETERS dummy1,dummy2,dummy3

CLEAR GETS
RETURN


******
*	all_fields()
*
*	fill field array with all fields for individual work area
******
FUNCTION all_fields

PARAMETERS work_area,field_a

stat_msg("Reading file structure")

* will need to assemble master field list
need_field = .T.

* select the specified work area
SELECT (M->work_area)

* fill the array with field names..fill leftover elements with null strings
afill(M->field_a, "", afields(M->field_a) + 1)

* clear the status message and return
stat_msg("")
RETURN 0


******
*	not_target()
*
*	remove relations where specified work area is target
******
FUNCTION not_target

PARAMETERS n, do_del
PRIVATE i

i = 1

DO WHILE M->i <= LEN(M->k_relate)
	* search the entire list of relations

	IF EMPTY(k_relate[M->i])
		* end of list
		EXIT

	ENDIF

	IF t_relate[M->i] == CHR(M->n + ASC("A") - 1) + name(dbf[M->n])
		* alias is target of relation
		need_relat = .T.

		* select the source work area for this relation
		SELECT (M->n)

		* turn off the relation
		SET RELATION TO

		IF M->do_del
			* relation will not be re-set..remove from list
			array_del(M->s_relate,M->i)
			array_del(M->k_relate,M->i)
			array_del(M->t_relate,M->i)

		ELSE
			* next element
			i = M->i + 1

		ENDIF

	ELSE
		* alias is not target of relation..next element
		i = M->i + 1

	ENDIF
ENDDO

RETURN 0


******
*	dup_ntx()
*
*	return work area where index is in use, zero if not found
******
FUNCTION dup_ntx

PARAMETERS ntx_file
PRIVATE ntx, i

i = 1

DO WHILE M->i <= 6

	IF EMPTY(dbf[M->i])
		* no more active work areas
		EXIT

	ENDIF

	* access one index file list
	ntx = "ntx" + SUBSTR("123456", M->i, 1)

	IF aseek(&ntx, M->ntx_file) > 0
		* index file in use
		RETURN M->i

	ENDIF

	* next work area
	i = M->i + 1

ENDDO

RETURN 0


/*****
*	stat_msg()
*
*	display status message
*/
func stat_msg(string)
local saveColor

	/* overwrite the entire row */
	saveColor := SetColor(M->color1)
	@ 3,0 say Pad(string,80)
	SetColor(saveColor)

return (0)


/*****
*	error_msg()
*
*	display error message and set global variable
*	  to erase message with next keystroke
*/
func error_msg(string)
local saveColor

	/* high intensity for error message */
	saveColor := SetColor(M->color3)
	@ 3,0 say string

	/* clear rest of message row */
	SetColor(M->color1)
	@ Row(), Col()

	/* next key stroke will erase message */
	error_on = .T.
	SetColor(saveColor)

return (0)


/*****
*	error_off()
*
*	erase error message
*/
func error_off
local saveColor

	/* set global variable false */
	error_on = .F.

	/* clear the message row */
	saveColor := SetColor(M->color1)
	@ 3,0
	SetColor(saveColor)

return (0)


******
*	rsvp()
*
*	get and return a Yes or No response (or Esc)
******
FUNCTION rsvp

PARAMETERS string
PRIVATE c

* initialize local variable
c = " "

* Yes/No/Esc
DO WHILE .NOT. (M->c $ "YN" + CHR(27))
	* display message bright like error message
	error_msg(M->string + "  ")

	* place the cursor at the end of the message
	@ 3,LEN(M->string) + 1 SAY ""

	* make the cursor visible
	SET CURSOR ON

	* get the response and erase the message
	c = UPPER(CHR(raw_key()))

	IF .NOT. M->curs_on
		* get rid of the cursor
		SET CURSOR OFF

	ENDIF
ENDDO

RETURN M->c


******
*	name()
*
*	extract filename from d:\path\filename.ext
******
FUNCTION name

PARAMETERS spec
PRIVATE p

* isolate filename and extension from path
p = SUBSTR(M->spec, RAT("\", M->spec) + 1)

IF "." $ M->p
	* there is an extension..chop it off
	p = SUBSTR(M->p, 1, AT(".", M->p) - 1)

ENDIF

RETURN M->p


******
*	pad()
*
*	force a string to a specified length
*
*	note: - if the string is longer than the specified
*			length it will be truncated
*		  - if the string is shorter than the specified length
*			it will be padded with spaces on the right
******
FUNCTION pad

PARAMETERS s, n

RETURN SUBSTR(M->s + SPACE(M->n), 1, M->n)


******
*	aseek()
*
*	search for matching array element..return zero if not found
*
*	note: only non-empty elements are searched
******
FUNCTION aseek

PARAMETERS array, exp
PRIVATE pos, num_el

* get number of non-empty elements
num_el = afull(M->array)

IF M->num_el = 0
	* not found if all empty
	RETURN 0

ENDIF

* perform exact search
SET EXACT ON

* ascan will return 0 if not found
pos = ascan(M->array, M->exp, 1, M->num_el)

* back to normal
SET EXACT OFF

RETURN M->pos


******
*	array_ins()
*
*	shift elements up and set array[pos] = ""
*
*	note: the only difference between this function and the ains()
*		  function is that here we set the inserted element to type C
******
FUNCTION array_ins

PARAMETERS array, pos

* insert a new element
ains(M->array, M->pos)

* assign null string to new element
array[M->pos] = ""

RETURN 0


******
*	array_del()
*
*	shift elements down and set array[len(array)] = ""
*
*	note: the only difference between this function and the adel()
*		  function is that here we set the last element to type C
******
FUNCTION array_del

PARAMETERS array, pos

* delete the specified element
adel(M->array, M->pos)

* assign null string to last element
array[LEN(M->array)] = ""

RETURN 0


******
*	afull()
*
*	find the number of contiguous full elements before the first null string
******
FUNCTION afull

PARAMETERS array
PRIVATE i

* perform exact search
SET EXACT ON

* search for null string
i = ascan(M->array, "")

* back to normal
SET EXACT OFF

IF M->i = 0
	* no null strings means completely full
	i = LEN(M->array)

ELSE
	* element of first null string - 1
	i = M->i - 1

ENDIF

RETURN M->i


******
*	array_sort()
*
*	sort the contiguous full elements before the first null string
******
FUNCTION array_sort

PARAMETERS array

* sort only the full elements
asort(M->array, 1, afull(M->array))

RETURN 0


******
*	array_dir()
*
*	prepare a sorted array of filenames that match a skeleton
******
FUNCTION array_dir

PARAMETERS skeleton, array

* begin with an empty array
afill(M->array, "")

* fill the array with filenames
adir(M->skeleton, M->array)

* sort the array
array_sort(M->array)

RETURN 0


******
*	ntx_key(filename)
*
*	read the key from an index file
*
*	note: this function assumes a valid index file
******
FUNCTION ntx_key

PARAMETERS filename
PRIVATE k, buffer, handle, k_pos

* initialize variable to hold key expression
k = ""

IF FILE(M->filename)
	* only if the file exists

	IF INDEXEXT() = ".NTX"
		* Clipper index file format
		k_pos = 23

	ELSE
		* .NDX..dBASE index file format
		k_pos = 25

	ENDIF

	* open the file and get handle
	handle = FOPEN(M->filename)

	IF FERROR() = 0
		* allocate 512 byte buffer
		buffer = SPACE(512)

		* read the index file header into memory
		FREAD(M->handle, @buffer, 512)

		* discard all bytes before the key expression
		k = SUBSTR(M->buffer, M->k_pos)

		* the expression is terminated with a zero byte (chr(0))
		k = TRIM(SUBSTR(M->k, 1, AT(CHR(0), M->k) - 1))

	ENDIF

	* close the file and release the handle
	FCLOSE(M->handle)

ENDIF

RETURN M->k


******
*	isdata()
*
*	determine if a key is data suitable for entry in place
******
FUNCTION isdata

PARAMETERS k

RETURN (M->k >= 32 .AND. M->k < 249 .AND. M->k <> 219 .AND. CHR(M->k) <> ";")


******
*	lpad()
*
*	pad with spaces on the left
*
*	note: this routine will fail if the requested len() is
*		  less than len(string)
******
FUNCTION lpad

PARAMETERS string,n

RETURN (SPACE(M->n - LEN(M->string)) + M->string)


******
*	hi_cur()
*
*	hilite the current data file
******
FUNCTION hi_cur
local saveColor

IF M->cur_area > 0
	* write on the main View screen
	saveColor := SetColor(M->color2)
	@ row_a[1], column[M->cur_area] + 2 SAY pad(name(M->cur_dbf), 8)
	SetColor(saveColor)

ENDIF

RETURN 0


******
*	dehi_cur()
*
*	display the current data file to un-hilite
******
FUNCTION dehi_cur
local saveColor

IF M->cur_area > 0
	* write on the main View screen
	saveColor := SetColor(M->color1)
	@ row_a[1], column[M->cur_area] + 2 SAY pad(name(M->cur_dbf), 8)
	SetColor(saveColor)

ENDIF

RETURN 0


******
*	enter_rc()
*
*	entry in place
******
FUNCTION enter_rc

PARAMETERS org_str, r, c, max_len, pfunc, cString
local saveColor
PRIVATE wk_str

* set menu keys to exit READ
xkey_clear()

* set initial work string from original string
wk_str = pad(M->org_str, M->max_len)
SET CURSOR ON
saveColor := SetColor(M->cString)

IF .NOT. EMPTY(M->pfunc)
	* perform GET with picture clause
	@ r, c GET M->wk_str PICTURE M->pfunc

ELSE
	* no picture clause
	@ r, c GET M->wk_str

ENDIF

* accept data input
READ
SET CURSOR OFF

* set global variable to exit key
keystroke = LASTKEY()

* release menu keys
xkey_norm()

IF M->error_on
	* erase error message
	error_off()

ENDIF

IF M->keystroke = 27 .OR. menu_key() <> 0
	* aborted entry..return null string
	wk_str = ""

ENDIF

SetColor(saveColor)
RETURN TRIM(M->wk_str)


* EOF DBUUTIL.PRG
