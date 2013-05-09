/***
*
*  Dbuview.prg
*
*  DBU View Maintenance Module
*
*  Copyright (c) 1990-1993, Computer Associates International, Inc.
*  All rights reserved.
*
*/


******
*	set_view
*
*	select files, set fields, relations, filters
*
*	note: only data files are opened and closed when
*		  requested..all other aspects of the View are
*		  set when needed by calling the setup() function
*		  in the utilities module
******
PROCEDURE set_view
local saveColor
PRIVATE bar_line,empty_line,ntx,field_n,el,cur_row,t_row,ch_draw,;
		strn,is_redraw,is_insert,horiz_keys,prev_area,i

saveColor := SetColor(M->color1)

* establish local array for index file names (no path or extension)
DECLARE d_array[LEN(M->ntx1)]

* initialize local variables
horiz_keys = CHR(4) + CHR(19) + CHR(1) + CHR(6)	&& quick return from bar_menu
bar_line = ""		&& built by bline()
empty_line = ""		&& ditto
prev_area = 0		&& detect horizontal movement (zero to initialize)
ch_draw = .F.		&& switch for channel function

* global help code
help_code = 1

* global key value..zero is convenient for branch to "otherwise" case below
keystroke = 0

* special attention for open and create menu defaults
set_deflt()

IF .NOT. EMPTY(M->view_err)
	* with soap it's loaded
	error_msg(M->view_err)
	view_err = ""

ENDIF

DO WHILE .NOT. q_check()
	* one big switch..exit condition determined elsewhere

	DO CASE

		CASE M->cur_area = 0
			* draw View screen..see if complete reset needed
			cur_area = aseek(M->dbf, M->cur_dbf)

			IF M->cur_area = 0
				* complete reset needed

				FOR i = 1 TO 3
					* current rows and current elements
               STORE row_a[M->i] TO _cr1[M->i],_cr2[M->i],_cr3[M->i],;
                               _cr4[M->i],_cr5[M->i],_cr6[M->i]
               STORE 1 TO _el1[M->i],_el2[M->i],_el3[M->i],_el4[M->i],;
                        _el5[M->i],_el6[M->i]

				NEXT

				* global variables
				cur_dbf = dbf[1]
				STORE 1 TO cur_area, page

				* set default for open and create menus
				set_deflt()

			ENDIF

			* draw the main View screen
			draw_view(0)

		CASE M->cur_area <> M->prev_area
			* horizontal movement detected (or initial entry)
			cur_dbf = dbf[M->cur_area]	&& current data file

			* save on function calls
			strn = SUBSTR("123456", M->cur_area, 1)

			* set variables to matrix into current data channel
			ntx = "ntx" + strn
			field_n = "field_n" + strn
         el = "_el" + strn

			* use temporary variable for adjustment
         t_row = "_cr" + strn

			IF M->page > 1 .AND. M->prev_area <> 0
				* adjust element by (old row - new row)
				&el[M->page] = &el[M->page] +;
							   &cur_row[M->page] - &t_row[M->page]

				* new row = old row
				&t_row[M->page] = &cur_row[M->page]

			ENDIF

			* set to current data channel
			cur_row = M->t_row

			* clear for next loop
			prev_area = M->cur_area

		CASE M->keystroke = 19
			* left arrow..move one channel to the left

			IF M->cur_area > 1
				* ok to move left
				cur_area = M->cur_area - 1

			ENDIF

			keystroke = 0

		CASE M->keystroke = 1
			* home key..extreme left
			cur_area = 1
			keystroke = 0

		CASE M->keystroke = 4
			* right arrow..move one channel to the right

			IF M->cur_area < 6 .AND. .NOT. EMPTY(M->cur_dbf)
				* ok to move right..next channel
				cur_area = M->cur_area + 1

				IF EMPTY(dbf[M->cur_area])
					* inactive channel..cannot enter indexes or fields
					page = 1
					set_deflt()

				ENDIF
			ENDIF

			keystroke = 0

		CASE M->keystroke = 6
			* end key..move to extreme right

			IF M->cur_area < 6 .AND. .NOT. EMPTY(M->cur_dbf)
				* ok to move right..determine last active channel
				i = afull(M->dbf)

				IF M->i < 6 .AND. (M->page = 1 .OR. M->cur_area = M->i)
					* move to inactive channel
					cur_area = M->i + 1

					* cannot enter indexes or fields
					page = 1
					set_deflt()

				ELSE
					* move to last active channel
					cur_area = M->i

				ENDIF

			ENDIF

			keystroke = 0

		CASE M->keystroke = 18 .OR. M->keystroke = 5
			* PgUp or up arrow

			IF M->page > 1
				* ok to move up
				page = M->page - 1
				set_deflt()

			ENDIF

			keystroke = 0

		CASE M->keystroke = 3 .OR. M->keystroke = 24
			* PgDn or down arrow

			IF M->page < 3 .AND. .NOT. EMPTY(M->cur_dbf)
				* ok to move down
				page = M->page + 1
				set_deflt()

				* adjust row and element for smooth cursor movement
				&el[M->page] = &el[M->page] -;
							   (&cur_row[M->page] - row_a[M->page])
				&cur_row[M->page] = row_a[M->page]

			ENDIF

			keystroke = 0

		CASE M->keystroke = 22 .OR. M->keystroke = 13 .OR.;
			 isdata(M->keystroke) .OR. (M->local_func = 2 .AND.;
			 (M->local_sel = 1 .OR. M->local_sel = 2)) .OR.;
			 (M->local_func = 8 .AND. M->local_sel = 3)
			* insert or enter or local menu item

			IF M->local_func <> 0
				* local menu item..set page to menu selection
				page = M->local_sel
				set_deflt()

				* menu select behaves like insert
				keystroke = 22

			ENDIF

			IF M->page = 1 .AND. M->n_files < 14
				* open a data file
				is_redraw = M->cur_area < 6 .AND. (M->keystroke = 22 .OR.;
												  EMPTY(M->cur_dbf))

				is_insert = (M->keystroke = 22 .AND.;
							.NOT. EMPTY(M->cur_dbf) .AND. M->cur_area < 6)

				IF M->is_redraw
					* open up dummy channel on screen
					draw_view(M->cur_area)

					* a dummy for a dummy
					SetColor(M->color2)
					@ row_a[1], column[M->cur_area] + 2 SAY SPACE(8)
					SetColor(M->color1)

				ELSE
					* hilite the affected View item
					hi_cur()

				ENDIF

				* call the open function and save the return status
				ch_draw = open_dbf(M->is_insert, .F.)

				IF M->ch_draw
					* update screen with "channel" function
					channel(&ntx, &field_n, &el, &cur_row,;
							M->cur_area, M->cur_area)

					* new current data file
					cur_dbf = dbf[M->cur_area]

				ELSE
					* put the screen back the way it was

					IF M->is_redraw
						* kill the dummy
						draw_view(0)

					ELSE
						* un-hilite
						dehi_cur()

					ENDIF
				ENDIF

			ELSE

				IF M->page > 1
					* pages 2 and 3 handled by channel function
					channel(&ntx, &field_n, &el, &cur_row,;
							M->cur_area, M->cur_area)

				ELSE
					error_msg("Too many files open")

				ENDIF
			ENDIF

			keystroke = 0

		CASE M->keystroke = 7
			* delete

			IF M->page = 1 .AND. .NOT. EMPTY(M->cur_dbf)
				* close this work area and shift subsequent ones down
				stat_msg("Closing File")
				clear_dbf(M->cur_area, 2)

				IF M->cur_area = 6
					* no need to re-write screen..clear windows
					ch_draw = .T.
					channel(&ntx, &field_n, &el, &cur_row,;
							M->cur_area, M->cur_area)

				ELSE
					* re-write screen
					draw_view(0)

				ENDIF

				* new current data file
				cur_dbf = dbf[M->cur_area]

				* clear status message
				stat_msg("")

			ELSE

				IF M->page > 1
					* pages 2 and 3 handled by channel function
					channel(&ntx, &field_n, &el, &cur_row,;
							M->cur_area, M->cur_area)

				ENDIF
			ENDIF

			keystroke = 0

		CASE M->local_func = 8 .AND. M->local_sel = 1
			* "set_relation" selected from pull-down menu
			set_relation()
			keystroke = 0

		CASE M->local_func = 8 .AND. M->local_sel = 2
			* "set filter" selected from pull-down menu
			get_filter()
			keystroke = 0

		CASE M->local_func = 2 .AND. M->local_sel = 3
			* "restore View from .VEW file" selected from pull-down menu
			set_from(.T.)

			IF .NOT. EMPTY(M->view_file) .AND. M->keystroke = 13
				* View set..re-write screen
				cur_area = 0
				cur_dbf = ""

			ENDIF

			keystroke = 0

		CASE M->local_func = 4
			* "save View" selected from pull-down menu
			save_view()
			keystroke = 0

		CASE M->local_func = 1
			* "help" selected from pull-down menu
			DO syshelp
			keystroke = 0

		OTHERWISE
			* all pending cases have been processed

			DO CASE

				CASE M->page = 1
					* get keystroke if pending

					IF .NOT. key_ready()
						* no key pending..hilite the current item
						hi_cur()

						* wait for keystroke
						read_key()

						* re-write the current item as normal
						dehi_cur()

					ENDIF

				CASE M->page = 2
					* copy index file names to "name only" array
					d_copy(&ntx)

					* do the menu selection on the main View screen
					bar_menu(column[M->cur_area] + 2,;
							 column[M->cur_area] + 9, M->d_array)

				CASE M->page = 3
					* do the menu selection on the main View screen
					bar_menu(column[M->cur_area] + 1,;
							 column[M->cur_area] + 10, &field_n)

			ENDCASE

			IF M->keystroke = 27

				IF rsvp("Exit to DOS? (Y/N)") <> "Y"
					keystroke = 0

				ENDIF
			ENDIF
	ENDCASE
ENDDO

IF M->sysfunc = 3 .AND. M->func_sel = 1 .AND. EMPTY(M->cur_dbf)
	* indicate create structure by opening a dummy channel
	draw_view(M->cur_area)

ENDIF

RETURN


******
*	channel()
*
*	process one channel for "set view"
*
*	note: the array identifiers associated with the current
*		  channel are passed to this function in order to
*		  avoid the repeated macro expansion inherent in
*		  constructs like &ntx[&el[]]
******
FUNCTION channel

PARAMETERS ch_ntx, ch_field_n, ch_el, ch_cur_row, n, dbf_num
local saveColor
PRIVATE f_n, is_ins, temp_buff, d_item

saveColor := SetColor(M->color1)

DO CASE

	CASE M->ch_draw
		* update the screen for channel "n"..clear windows
		scroll(row_a[2], column[M->n], row_x[2], column[M->n] + 11, 0)
		scroll(row_a[3], column[M->n], row_x[3], column[M->n] + 11, 0)

		* display the specified file name "dbf_num"
		@ row_a[1],column[M->n] + 2 SAY pad(name(dbf[M->dbf_num]), 8)

		IF .NOT. EMPTY(ch_ntx[1])
			* list the index files if any
			d_copy(M->ch_ntx)
			list_array(row_a[2],column[M->n] + 2,row_x[2],column[M->n] + 9,;
					   M->d_array,ch_el[2] - (ch_cur_row[2] - row_a[2]))

		ENDIF

		* display field list
		list_array(row_a[3], column[M->n] + 1, row_x[3], column[M->n] + 10,;
				   M->ch_field_n, ch_el[3] - (ch_cur_row[3] - row_a[3]))

		ch_draw = .F.				&& reset the screen update flag

	CASE M->keystroke = 22 .OR. M->keystroke = 13 .OR. isdata(M->keystroke)
		* insert or enter or character key

		IF isdata(M->keystroke)
			* forward character to GET system
			KEYBOARD CHR(M->keystroke)

		ENDIF

		* remember if insert
		is_ins = (M->keystroke = 22)

		DO CASE

			CASE M->page = 2 .AND. (M->n_files < 14 .OR. (M->keystroke <> 22;
				 .AND. .NOT. EMPTY(ch_ntx[ch_el[2]])))
				* add or change an index file in the current list..save window
				temp_buff = SAVESCREEN(row_a[2], column[M->n] + 1,;
									   row_x[2], column[M->n] + 11)

				IF M->is_ins
					* insert

					IF ch_el[2] + row_x[2] - ch_cur_row[2] = afull(M->ch_ntx)
						* last filename will scroll off the window
						@ row_x[2], column[M->n] + 11 SAY M->more_down

					ENDIF

					IF ch_cur_row[2] < row_x[2]
						* open a blank row..scroll down
						scroll(ch_cur_row[2], column[M->n] + 1,;
									row_x[2], column[M->n] + 10, -1)

					ENDIF

					* show entry blank
					d_item = SPACE(8)

				ELSE
					* show the affected View item
					d_item = pad(name(ch_ntx[ch_el[2]]), 8)

				ENDIF

				* hilite the affected View item
				SetColor(M->color2)
				@ ch_cur_row[2],column[M->n] + 2 SAY M->d_item
				SetColor(M->color1)

				* get selection
				f_n = get_ntx(ch_cur_row[2], column[M->n] + 2,;
							  ch_ntx[ch_el[2]], M->is_ins)

				IF .NOT. M->f_n == ch_ntx[ch_el[2]] .AND. .NOT. EMPTY(M->f_n)
					* index file added to list
					need_ntx = .T.

					IF M->is_ins
						* make room for new index file name
						array_ins(M->ch_ntx,ch_el[2])

					ENDIF

					* assign filename to array element
					ch_ntx[ch_el[2]] = M->f_n

					IF ch_el[2] = 1
						* controlling index..remove relations where target
						not_target(M->n, .T.)

					ENDIF

					* display the name of the newly selected index file
					@ ch_cur_row[2],column[M->n] + 2;
					SAY pad(name(ch_ntx[ch_el[2]]), 8)

				ELSE
					* aborted entry..restore the window as it was
					RESTSCREEN(row_a[2], column[M->n] + 1,;
							   row_x[2], column[M->n] + 11, M->temp_buff)

				ENDIF

			CASE M->page = 3
				* add or change a fieldname in the current list..save window
				temp_buff = SAVESCREEN(row_a[3], column[M->n] + 1,;
									   row_x[3], column[M->n] + 11)

				IF M->is_ins
					* insert

					IF ch_el[3] + row_x[3] - ch_cur_row[3] = afull(M->ch_field_n)
						* last fieldname will scroll off the window
						@ row_x[3], column[M->n] + 11 SAY M->more_down

					ENDIF

					IF ch_cur_row[3] < row_x[3]
						* open a blank row..scroll down
						scroll(ch_cur_row[3], column[M->n] + 1,;
									row_x[3], column[M->n] + 10, -1)

					ENDIF

					* show entry blank
					d_item = SPACE(10)

				ELSE
					* show the affected View item
					d_item = pad(ch_field_n[ch_el[3]], 10)

				ENDIF

				* hilite the affected View item
				SetColor(M->color2)
				@ ch_cur_row[3],column[M->n] + 1 SAY M->d_item
				SetColor(M->color1)

				* get selection
				f_n = get_field(ch_cur_row[3], column[M->n] + 1, M->n,;
								ch_field_n[ch_el[3]])

				IF (M->is_ins .OR. .NOT. M->f_n == ch_field_n[ch_el[3]]);
				   .AND. .NOT. EMPTY(M->f_n)
					* fieldname added to list
					need_field = .T.

					IF M->is_ins
						* make room for new field name
						array_ins(M->ch_field_n,ch_el[3])

					ENDIF

					* assign fieldname to array element
					ch_field_n[ch_el[3]] = M->f_n

					* display the name of the newly selected field
					@ ch_cur_row[3],column[M->n] + 1;
					SAY pad(ch_field_n[ch_el[3]], 10)

				ELSE
					* aborted entry..restore the window as it was
					RESTSCREEN(row_a[3], column[M->n] + 1,;
							   row_x[3], column[M->n] + 11, M->temp_buff)

				ENDIF
		ENDCASE

	CASE M->keystroke = 7
		* delete

		DO CASE

			CASE M->page = 2 .AND. .NOT. EMPTY(ch_ntx[ch_el[2]])
				* remove index file from list
				need_ntx = .T.	&& must reset

				IF ch_el[2] = 1
					* primary index..remove relations where target
					not_target(M->n, .T.)

				ENDIF

				* select work area n
				SELECT (M->n)

				* ensure that n_files does not exceed actual open files
				CLOSE INDEX

				* remove the filename from the list
				array_del(M->ch_ntx,ch_el[2])

				* decrement global file counter
				n_files = M->n_files - 1

				IF ch_cur_row[2] < row_x[2]
					* scroll up to remove filename from screen
					scroll(ch_cur_row[2],column[M->n] + 1,;
								row_x[2],column[M->n] + 9,1)

				ENDIF

				* fill in blank row at bottom of window
				@ row_x[2],column[M->n] + 2;
				SAY pad(name(ch_ntx[ch_el[2] + row_x[2] - ch_cur_row[2]]), 8)

				IF afull(M->ch_ntx) - ch_el[2] = row_x[2] - ch_cur_row[2]
					* remove the "more_down" indicator from the screen
					@ row_x[2],column[M->n] + 11 SAY " "

				ENDIF

			CASE M->page = 3 .AND. .NOT. EMPTY(ch_field_n[ch_el[3]])
				* delete a fieldname from the current list
				need_field = .T.	&& must reset

				* remove the fieldname from the list
				array_del(M->ch_field_n,ch_el[3])

				IF ch_cur_row[3] < row_x[3]
					* scroll up to remove fieldname from screen
					scroll(ch_cur_row[3],column[M->n] + 1,;
								row_x[3],column[M->n] + 10,1)

				ENDIF

				* fill in blank row at bottom of window
				@ row_x[3],column[M->n] + 1;
				SAY pad(ch_field_n[ch_el[3] + row_x[3] - ch_cur_row[3]], 10)

				IF afull(M->ch_field_n) - ch_el[3] = row_x[3] - ch_cur_row[3]
					* remove the "more_down" indicator from the screen
					@ row_x[3],column[M->n] + 11 SAY " "

				ENDIF
		ENDCASE
ENDCASE

SetColor(saveColor)
RETURN 0


******
*	bar_menu()
*
*	verticle light bar selection menu for the main View screen
*
*	note: this routine is expected to return a value in "keystroke"
*		  to be processed by "set_view"
******
FUNCTION bar_menu

PARAMETERS l, r, array
local saveColor
PRIVATE num_d, num_full, cur_el, rel_row, x, t, b

* look ahead at next keystroke
keystroke = NEXTKEY()

IF CHR(M->keystroke) $ M->horiz_keys
	* improve performance of horizontal cursor movement with quick return
	INKEY()		&& remove character from typeahead buffer
	RETURN 0

ENDIF

* avoid costly array access by getting top and bottom of window to "t" and "b"
t = row_a[M->page]
b = row_x[M->page]

* get the number of active elements
num_full = afull(M->array)

* and the number of displayable elements
num_d = M->num_full

IF M->num_d < LEN(M->array)
	* first empty element is included
	num_d = M->num_d + 1

	* achoice() won't display a null string
	array[M->num_d] = " "

ENDIF

* determine column offset to put "more_up" and "more_down" indicators
x = IF(M->r - M->l > 7, 1, 2)

* it's all relative to achoice()
rel_row = &cur_row[M->page] - M->t

* discard returned value
saveColor := SetColor(M->color4)
achoice(M->t, M->l, M->b, M->r, M->array, .T.,;
		"bar_func", &el[M->page], M->rel_row)
SetColor(saveColor)

* change back to absolute
&cur_row[M->page] = M->rel_row + M->t

IF array[M->num_d] == " "
	* kill the dummy
	array[M->num_d] = ""

ENDIF

* check for menu request
sysmenu()

RETURN 0


******
*	bar_func()
*
*	function to be called from achoice() specifically for bar_menu()
******
FUNCTION bar_func

PARAMETERS mode, bar_el, row
PRIVATE ret_code

* get keystroke
keystroke = LASTKEY()

* assume continue
ret_code = 2

* maintain variables from above
&el[M->page] = M->bar_el
rel_row = M->row

IF M->error_on
	* erase error message
	error_off()

ENDIF

DO CASE

	CASE M->mode = 0
		* idle..maintain correct "more_up" and "more_down" indicators
		@ M->t, M->r + M->x SAY IF(M->bar_el > M->row + 1, M->more_up, " ")
		@ M->b, M->r + M->x SAY IF(M->num_full >;
								   (M->bar_el + M->b - M->t - M->row),;
								M->more_down, " ")

	CASE M->mode = 1 .OR. M->mode = 2
		* attempt to cursor past top or end of list
		ret_code = 0

	CASE M->mode = 3
		* keystroke exception

		DO CASE

			CASE CHR(M->keystroke) $ M->horiz_keys
				* horizontal cursor key
				ret_code = 0

			CASE M->keystroke = 27
				* abort selection
				ret_code = 0

			CASE M->keystroke = 13
				* replace a View item
				ret_code = 1

			CASE isdata(M->keystroke)
				* character key...entry in place
				ret_code = 1

			CASE M->keystroke = 22 .OR. M->keystroke = 7
				* ins, del
				ret_code = 1

			CASE menu_key() <> 0
				* menu request
				ret_code = 0

		ENDCASE

	CASE M->mode = 4
		* nothing selectable
		ret_code = 0

ENDCASE

RETURN M->ret_code


******
*	list_array()
*
*	list array elements vertically in window
******
FUNCTION list_array

PARAMETERS t, l, b, r, array, top_el
local saveColor
PRIVATE bottom_el, num_full, x

saveColor := SetColor(M->color4)
IF .NOT. EMPTY(array[M->top_el])
	* something to list..calculate number of last element in window
	bottom_el = M->top_el + M->b - M->t

	* get number of non-empty elements
	num_full = afull(M->array)

	* determine column offset of "more_up" and "more_down" indicators
	x = IF(M->r - M->l > 7, 1, 2)

	IF M->top_el > 1 .AND. M->bottom_el = M->num_full + 1
		* prevent achoice() from making adjustments
		array[M->bottom_el] = " "

	ENDIF

	* display only and return without waiting for a keystroke
	achoice(M->t, M->l, M->b, M->r, M->array, .F., "", M->top_el)
	SetColor(M->color1)

	* update status of "more_up" and "more_down" indicators
	@ M->t, M->r + M->x SAY IF(M->top_el > 1, M->more_up, " ")
	@ M->b, M->r + M->x SAY IF(M->bottom_el < M->num_full, M->more_down, " ")

	IF array[M->bottom_el] == " "
		* restore to null string
		array[M->bottom_el] = ""

	ENDIF
ENDIF

SetColor(saveColor)
RETURN 0


******
*	set_deflt()
*
*	set defaults for open and create pull-down menus
******
FUNCTION set_deflt

IF M->page = 2
	* cursor in index file list..default to open index and create index
	STORE 2 TO menu_deflt[2], menu_deflt[3]

ELSE
	* default to open database and create database
	STORE 1 TO menu_deflt[2], menu_deflt[3]

ENDIF

RETURN 0


******
*	bline()
*
*	build a new bar line for the main View screen
******
FUNCTION bline

PARAMETERS num_slots
PRIVATE i, k

IF num_slots < 6
	* add one empty slot
	num_slots = num_slots + 1

ENDIF

* the first slot is diferent than the rest
bar_line = "ออออออออออออ"
empty_line = ""

k = 1

DO WHILE M->k < M->num_slots
	* each new slot separated from previous by a vertical line
	bar_line = M->bar_line + "ัออออออออออออ"
	empty_line = M->empty_line + SPACE(12) + "ณ"

	* next
	k = M->k + 1

ENDDO

* calculate value to center the entire View screen
i = INT((80 - LEN(M->bar_line)) / 2)

FOR k = 1 TO M->num_slots
	* establish screen columns for all active slots
	column[M->k] = M->i + (13 * (M->k - 1))

NEXT

RETURN 0


******
*	draw_view()
*
*	fill the main View screen
*
*	note: the parameter indicates which channel is to be the
*		  dummy for operations in progress, zero for no dummy
******
FUNCTION draw_view

PARAMETERS blank_area
PRIVATE i, j, ntx, field_n, el, cur_row, strnum

* get number of active work areas
i = afull(M->dbf)

IF M->i < 6 .AND. blank_area <> 0
	* add one for the dummy
	i = M->i + 1

ENDIF

* build the bar_line and empty_line strings
bline(M->i)

* clear the deck and draw a blank template
@ 4,0 CLEAR

* page 1..names of data files
@ row_a[1] - 2,37 SAY "Files"
@ row_a[1] - 1,column[1] SAY M->bar_line
@ row_a[1],column[1] SAY M->empty_line

* page 2..names of index files
@ row_a[2] - 2,36 SAY "Indexes"
@ row_a[2] - 1,column[1] SAY M->bar_line
@ row_a[2],column[1] SAY M->empty_line
@ row_a[2] + 1,column[1] SAY M->empty_line
@ row_a[2] + 2,column[1] SAY M->empty_line

* page 3..active fields lists
@ row_a[3] - 2,37 SAY "Fields"
@ row_a[3] - 1,column[1] SAY M->bar_line

FOR i = row_a[3] TO row_x[3]
	* complete the blank template
	@ M->i,column[1] SAY M->empty_line

NEXT

i = 1
j = 1

DO WHILE M->j <= 6

	IF EMPTY(dbf[M->i])
		* no more active work areas
		EXIT

	ENDIF

	IF M->j <> M->blank_area
		* channel needs filling
		strnum = SUBSTR("123456", M->i, 1)

		* set to channel "i"
		ntx = "ntx" + strnum
		field_n = "field_n" + strnum
      el = "_el" + strnum
      cur_row = "_cr" + strnum

		* fill the channel
		ch_draw = .T.
		channel(&ntx, &field_n, &el, &cur_row, M->j, M->i)

		* next real channel
		i = M->i + 1

	ENDIF

	* next display channel
	j = M->j + 1

ENDDO

RETURN 0


******
*	d_copy()
*
*	create a filename only array (no paths or extensions)
******
FUNCTION d_copy

PARAMETERS array
PRIVATE i

* clear the dedicated array
afill(M->d_array, "")

i = 1

DO WHILE M->i <= LEN(M->array)

	IF EMPTY(array[M->i])
		* end of active list
		EXIT

	ENDIF

	* assign the extracted name
	d_array[M->i] = name(array[M->i])

	* next
	i = M->i + 1

ENDDO

RETURN 0


******
*	open_dbf()
*
*	open data file in the specified work area
******
FUNCTION open_dbf

PARAMETERS is_insert, not_view
PRIVATE shift, filename, a_temp, f_row, d_col, ret_val, old_help

IF M->n_files >= 14
	error_msg("Too many files open")
	RETURN .F.

ENDIF

* save old and set new help codes
old_help = M->help_code
help_code = 6

* initialize private variables
filename = ""

* coordinate of filename on View screen
f_row = _cr1[1]
d_col = column[M->cur_area] + 2

* shift = 1 for major insertion
shift = IF(M->is_insert, 1, 0)

* select the current work area
SELECT (M->cur_area)

IF M->not_view
	* not called from "set_view"
	filename = M->cur_dbf
	ret_val = do_opendbf()

ELSE
	* assume file not opened
	ret_val = .F.

	IF isdata(M->keystroke)
		* forward the data character to the GET system
		KEYBOARD CHR(M->keystroke)

		* entry in place
		filename = enter_rc(dbf[M->cur_area],M->f_row,M->d_col,64,"@K!S8",;
							M->color1)

		IF .NOT. EMPTY(M->filename)
			* something entered

			IF .NOT. (RAT(".", M->filename) > RAT("\", M->filename))
				* no extension entered..provide default
				filename = M->filename + ".DBF"

			ENDIF

			* try to open the file
			ret_val = do_opendbf()

			IF .NOT. M->ret_val
				* failed..restore the screen
				@ M->f_row, M->d_col SAY pad(name(M->cur_dbf), 8)

			ENDIF

		ELSE
			* aborted entry..restore the screen
			@ M->f_row, M->d_col SAY pad(name(M->cur_dbf), 8)

		ENDIF

		IF menu_key() <> 0
			* forward menu key to "set_view"
			KEYBOARD CHR(M->keystroke)

		ELSE
			* avoid confusion
			keystroke = 0

		ENDIF

	ELSE
		* insert or enter or menu selection..use filebox
		ret_val = filebox(".DBF", "dbf_list", "dopen_titl",;
						  "do_opendbf", .F., 8) <> 0

	ENDIF
ENDIF

IF M->ret_val
	* default field arrays to all fields
	a_temp = "field_n" + SUBSTR("123456", M->cur_area, 1)
   all_fields(M->cur_area, &a_temp)

	* re-set current row for indexes and fields
   a_temp = "_cr" + SUBSTR("123456", M->cur_area, 1)
   &a_temp[2] = row_a[2]
   &a_temp[3] = row_a[3]

	* re-set current elements
   a_temp = "_el" + SUBSTR("123456", M->cur_area, 1)
   afill(&a_temp, 1)

ENDIF

* restore help code
help_code = M->old_help

RETURN M->ret_val


******
*	dopen_titl()
*
*	display title for data file to open
******
FUNCTION dopen_titl

PARAMETERS sysparam

RETURN box_title(M->sysparam, "Open data file...")


******
*	do_opendbf()
*
*	set up and open a data file
******
FUNCTION do_opendbf

PRIVATE done

DO CASE

	CASE EMPTY(M->filename)
		error_msg("Data file not selected")
		done = .F.

	CASE .NOT. FILE(M->filename)
		error_msg("Can't open " + M->filename)
		done = .F.

	CASE aseek(M->dbf, M->filename) > 0 .AND.;
		 .NOT. (dbf[M->cur_area] == M->filename .AND. M->shift = 0)
		error_msg("Data file would be open in two areas")
		done = .F.

	OTHERWISE
		stat_msg("Opening File")

		IF .NOT. EMPTY(dbf[M->cur_area])
			* clear the current work area
			clear_dbf(M->cur_area, M->shift)

		ENDIF

		* open the file in the current area
		SELECT (M->cur_area)

      IF NetUse( filename )

         * adjust global variable
         n_files = M->n_files + 1

         * assign the filename to global array
         dbf[M->cur_area] = M->filename

         done = .T.

      ELSE

         done := .F.

      ENDIF

      * clear the message
      stat_msg("")

ENDCASE

RETURN M->done


******
*	get_ntx()
*
*	select index files for the current work area
******
FUNCTION get_ntx

PARAMETERS d_row, d_col, org_file, is_ins
PRIVATE filename, old_help

IF M->n_files >= 14
	error_msg("Too many files open")
	RETURN ""

ENDIF

* save old and set new help codes
old_help = M->help_code
help_code = 8

* initialize private variable
filename = ""

IF isdata(M->keystroke)
	* forward data keystroke to GET system
	KEYBOARD CHR(M->keystroke)

	* entry in place
	filename = enter_rc(M->org_file,M->d_row,M->d_col,64,"@K!S8",M->color1)

	IF .NOT. EMPTY(M->filename)
		* something entered

		IF .NOT. (RAT(".", M->filename) > RAT("\", M->filename))
			* extension not entered..provide default
			filename = filename + INDEXEXT()

		ENDIF

		IF .NOT. do_openntx()
			* failed..return null string
			filename = ""

		ENDIF
	ENDIF

	IF menu_key() <> 0
		* forward menu request to "set_view"
		KEYBOARD CHR(M->keystroke)

	ELSE
		* avoid confusion
		keystroke = 0

	ENDIF

ELSE

	IF filebox(INDEXEXT(),"ntx_list","xopen_titl","do_openntx",.F.,13) = 0
		* no selection..return null string
		filename = ""

	ENDIF
ENDIF

* restore help code
help_code = M->old_help

RETURN M->filename


******
*	xopen_titl()
*
*	display title for index file to open
******
FUNCTION xopen_titl

PARAMETERS sysparam

RETURN box_title(M->sysparam, "Open index file...")


******
*	do_openntx()
*
*	verify the selectability of an index file
******
FUNCTION do_openntx

PRIVATE done

DO CASE

	CASE EMPTY(M->filename)
		error_msg("Index file not selected")
		done = .F.

	CASE .NOT. FILE(M->filename)
		error_msg("Can't open " + M->filename)
		done = .F.

	CASE dup_ntx(M->filename) <> 0 .AND.;
		 (M->is_ins .OR. .NOT. M->filename == M->org_file)
		error_msg("Index file already open")
		done = .F.

	OTHERWISE
		* filename may be selected

		IF EMPTY(M->org_file) .OR. M->is_ins
			* adjust global variable
			n_files = M->n_files + 1

		ENDIF

		done = .T.

ENDCASE

RETURN M->done


******
*	get_field()
*
*	add a field to an individual field list
******
FUNCTION get_field

PARAMETERS f_row, d_col, work_area, org_field
PRIVATE field_mvar, rel_row, cur_el, okee_dokee, fi_disp, old_help

* save old and set new help codes
old_help = M->help_code
help_code = 2

* initialize variable to contain fieldname
field_mvar = ""

* select the specified work area
SELECT (M->work_area)

* get master field list into local array for selection
DECLARE field_m[FCOUNT()]
all_fields(M->work_area, M->field_m)

IF isdata(M->keystroke)
	* forward the data keystroke to the GET system
	KEYBOARD CHR(M->keystroke)

	* entry in place
	field_mvar = enter_rc(M->org_field,M->f_row,M->d_col,10,"@K!",M->color1)

	IF .NOT. EMPTY(M->field_mvar)
		* something entered

		IF .NOT. do_fsel()
			* failed..return null string
			field_mvar = ""

		ENDIF

	ENDIF

	IF menu_key() <> 0
		* forward the menu request to "set_view"
		KEYBOARD CHR(M->keystroke)

	ELSE
		* avoid confusion
		keystroke = 0

	ENDIF

ELSE
	* establish arrays for multibox
	DECLARE boxarray[5]

	boxarray[1] = "fsel_title(sysparam)"
	boxarray[2] = "getfield(sysparam)"
	boxarray[3] = "ok_button(sysparam)"
	boxarray[4] = "can_button(sysparam)"
	boxarray[5] = "fieldlist(sysparam)"

	* initialize private variables
	cur_el = 1
	rel_row = 0

	* where the action is
	okee_dokee = "do_fsel()"
	fi_disp = "getfield(3)"

	IF multibox(7, 17, 5, 5, M->boxarray) = 0
		* failed or aborted..return null string
		field_mvar = ""

	ENDIF
ENDIF

* restore help code
help_code = M->old_help

RETURN M->field_mvar


******
*	getfield()
*
*	process fieldname entry blank (called from multibox)
******
FUNCTION getfield

PARAMETERS sysparam

RETURN genfield(M->sysparam, .F.)


******
*	fsel_title()
*
*	display title for field selection
******
FUNCTION fsel_title

PARAMETERS sysparam

RETURN box_title(M->sysparam, "Select field...")


******
*	do_fsel()
*
*	validate field selection
******
FUNCTION do_fsel

PRIVATE done

DO CASE

	CASE EMPTY(M->field_mvar)
		error_msg("Field name not selected")
		done = .F.

	CASE aseek(M->field_m, M->field_mvar) = 0
		* needed for entry in place
		error_msg(M->field_mvar + " does not exist")
		done = .F.

	OTHERWISE
		* field exists..no problem
		done = .T.

ENDCASE

RETURN M->done


******
*	set_relation()
*
*	interface for editing the list of relations
*
*	note: the relations window can display a maximum
*		  of six (6) relationships at one time
******
FUNCTION set_relation
local saveColor
PRIVATE c_row, c_el, rel_buff, pos_r, width, old_help, k, n_area, ls, lk, lt,;
		cNorm, cHilite

cNorm := color7
cHilite:= color2
saveColor := SetColor(M->cNorm)

* save old and set new help codes
old_help = M->help_code
help_code = 9

* prevent certain menu selections with multibox mechanism
box_open = .T.

IF EMPTY(M->bar_line)
	* need bar line for vertical reference
	bline(afull(M->dbf))

ENDIF

* window has variable width
width = LEN(M->bar_line) - 1

* establish easy reference to right most column
pos_r = column[1] + M->width

* save the window
rel_buff = SAVESCREEN(8, column[1] - 1, 23, M->pos_r + 1)

* clear and frame the window
scroll(8, column[1] - 1, 23, M->pos_r + 1, 0)
@ 8, column[1] - 1, 23, M->pos_r + 1 BOX M->frame

* display the heading and bar line
@ 9,35 SAY "Relations"
@ 10,column[1] SAY M->bar_line

* initialize current row and element
c_row = 11
c_el = 1

* initial window fill
draw_relat(1)

* global key value..zero is convenient for branch to "otherwise" case below
keystroke = 0

DO WHILE .NOT. q_check()
	* one big switch..exit condition determined elsewhere

	DO CASE

		CASE M->keystroke = 18
			* PgUp

			IF M->c_el > ((M->c_row - 11) / 2) + 1
				* elements off screen..move up one page
				c_el = M->c_el - 5

				IF M->c_el < ((M->c_row - 11) / 2) + 1
					* minimum element for this row
					c_el = ((M->c_row - 11) / 2) + 1

				ENDIF

				* re-write relations window
				draw_relat(M->c_el - ((M->c_row - 11) / 2))

			ELSE
				* first element is on screen

				IF M->c_el > 1
					* move to top of list
					c_el = 1
					c_row = 11

				ENDIF
			ENDIF

			keystroke = 0

		CASE M->keystroke = 3
			* PgDn..determine maximum allowable cursor element
			k = afull(M->k_relate)

			IF M->k < LEN(M->k_relate)
				* first empty element is allowed
				k = M->k + 1

			ENDIF

			IF M->c_el < M->k - ((21 - M->c_row) / 2)
				* elements off screen..down one page
				c_el = M->c_el + 5

				IF M->c_el > M->k - ((21 - M->c_row) / 2)
					* maximum element for this row
					c_el = M->k - ((21 - M->c_row) / 2)

				ENDIF

				* re-write relations window
				draw_relat(M->c_el - ((M->c_row - 11) / 2))

			ELSE
				* last allowable element is on screen

				IF M->c_el < M->k
					* move to bottom of list
					c_row = M->c_row + ((M->k - M->c_el) * 2)
					c_el = M->k

				ENDIF
			ENDIF

			keystroke = 0

		CASE M->keystroke = 22 .OR. isdata(M->keystroke)
			* insert or character key..insert a relation

			* k = number of first relation off screen
			k = M->c_el + ((21 - M->c_row) / 2 ) + 1

			* save the last relationship
			ls = s_relate[LEN(M->s_relate)]
			lk = k_relate[LEN(M->k_relate)]
			lt = t_relate[LEN(M->t_relate)]

			* do the insert..assume relation will be entered
			array_ins(M->s_relate, M->c_el)
			array_ins(M->k_relate, M->c_el)
			array_ins(M->t_relate, M->c_el)

			IF M->c_row < 21
				* make room on screen..scroll down 2 lines
				scroll(M->c_row, column[1], 22, M->pos_r - 1, -2)

			ELSE
				* clear the last row
				@ M->c_row + 1,column[1] SAY SPACE(M->width)

			ENDIF

			IF M->k <= LEN(M->k_relate)
				* k is within subscript range

				IF .NOT. EMPTY(k_relate[M->k])
					* off-screen element is active
					@ 22, M->pos_r SAY M->more_down

				ENDIF
			ENDIF

			* accept input of new relation
			get_relation(M->c_row, M->c_el)

			IF .NOT. EMPTY(k_relate[M->c_el])
				* relation has been entered..show it
				disp_relation(M->c_row, M->c_el, color7)

			ELSE
				* relation not entered..cannot delete a null string
				STORE "x" TO s_relate[M->c_el],;
							 k_relate[M->c_el], t_relate[M->c_el]

				* restore arrays
				array_del(M->s_relate, M->c_el)
				array_del(M->k_relate, M->c_el)
				array_del(M->t_relate, M->c_el)

				* restore last relationship
				s_relate[LEN(M->s_relate)] = M->ls
				k_relate[LEN(M->k_relate)] = M->lk
				t_relate[LEN(M->t_relate)] = M->lt

				IF M->c_row < 21
					* close the gap on the screen..scroll up 2 lines
					scroll(M->c_row, column[1], 22, M->pos_r - 1, 2)

				ELSE
					* erase the deleted relation from screen
					@ 21,column[1] SAY SPACE(M->width)
					@ 22,column[1] SAY SPACE(M->width)

				ENDIF

				* fill in the last relation on screen
				disp_relation(21,M->c_el+((21-M->c_row)/2),color7)

			ENDIF

			IF M->k <= LEN(M->k_relate)
				* k is within subscript range

				IF EMPTY(k_relate[M->k])
					* off-screen element not active
					@ 22, M->pos_r SAY " "

				ENDIF
			ENDIF

			keystroke = 0

		CASE M->keystroke = 13
			* enter key..change a relationship
			get_relation(M->c_row, M->c_el)

			* display the change
			disp_relation(M->c_row, M->c_el, color7)

			keystroke = 0

		CASE M->keystroke = 7 .AND. .NOT. EMPTY(k_relate[M->c_el])
			* remove a relation from the list
			need_relat = .T.	&& will need to reset

			* select the source work area
			n_area = ASC(s_relate[M->c_el]) - ASC("A") + 1
			SELECT (M->n_area)

			* turn off relations from this work area
			SET RELATION TO

			* remove the relation from list
			array_del(M->s_relate, M->c_el)
			array_del(M->k_relate, M->c_el)
			array_del(M->t_relate, M->c_el)

			IF M->c_row < 21
				* close the gap on the screen
				scroll(M->c_row, column[1], 22, M->pos_r - 1, 2)

			ELSE
				* last row erase the deleted relation from screen
				@ 21,column[1] SAY SPACE(M->width)
				@ 22,column[1] SAY SPACE(M->width)

			ENDIF

			* fill in the last relation on screen
			disp_relation(21, M->c_el + ((21 - M->c_row) / 2), color7)

			IF M->c_el < LEN(M->k_relate) - ((21 - M->c_row) / 2)
				* off-screen element is within subscript range

				IF EMPTY(k_relate[M->c_el + ((21 - M->c_row) / 2) + 1])
					* remove "more_down" indicator from screen
					@ 22, M->pos_r SAY " "

				ENDIF
			ENDIF

			keystroke = 0

		CASE M->keystroke = 5 .AND. M->c_el > 1
			* up arrow..move up one element
			c_el = M->c_el - 1

			IF M->c_row > 11
				* room to move up on screen
				c_row = M->c_row - 2

			ELSE
				* scroll entire window down 2 lines
				scroll(11, column[1], 22, M->pos_r - 1, -2)

				* fill in the top row
				disp_relation(11, M->c_el, color7)

				IF M->c_el <= LEN(M->k_relate) - 6
					* off-screen element within subscript range

					IF .NOT. EMPTY(k_relate[M->c_el + 6])
						* off-screen element is active
						@ 22, M->pos_r SAY M->more_down

					ENDIF
				ENDIF

				IF M->c_el = 1
					* first element brought onto screen..no "more_up"
					@ 11,M->pos_r SAY " "

				ENDIF
			ENDIF

			keystroke = 0

		CASE M->keystroke = 24 .AND. .NOT.;
			 (EMPTY(k_relate[M->c_el]) .OR. M->c_el = LEN(M->k_relate))
			* down arrow..move down one element
			c_el = M->c_el + 1

			IF c_row < 22 - 2
				* room to move down on screen
				c_row = M->c_row + 2

			ELSE
				* scroll entire window up 2 lines
				scroll(11, column[1], 22, M->pos_r - 1, 2)

				* definitely more up
				@ 11,M->pos_r SAY M->more_up

				IF .NOT. EMPTY(k_relate[M->c_el])
					* fill in the bottom row
					disp_relation(21, M->c_el, color7)

				ENDIF

				IF M->c_el < LEN(M->k_relate)
					* off-screen element within subscript range

					IF EMPTY(k_relate[M->c_el + 1])
						* erase "more_down" indicator from screen
						@ 22,M->pos_r SAY " "

					ENDIF

				ELSE
					* no off-screen element..erase "more_down" indicator
					@ 22,M->pos_r SAY " "

				ENDIF
			ENDIF

			keystroke = 0

		CASE M->local_func = 1
			* "help" selected from pull-down menu
			DO syshelp
			keystroke = 0

		OTHERWISE
			* get new keystroke

			IF .NOT. key_ready()
				* no key pending..hilite the current item
				disp_relation(M->c_row, M->c_el, cHilite)

				* display a blob of light if element empty
				SetColor(M->cHilite)
				@ M->c_row,column[1] + 2;
				SAY IF(EMPTY(k_relate[M->c_el]), " ", "")
				SetColor(M->cNorm)

				* wait for keystroke
				read_key()

				* re-write the current item as normal
				disp_relation(M->c_row, M->c_el, cNorm)

				@ M->c_row, column[1] + 2 SAY ""

			ENDIF
	ENDCASE
ENDDO

* restore the window
RESTSCREEN(8, column[1] - 1, 23, M->pos_r + 1, M->rel_buff)

* restore the help code
help_code = M->old_help

* restore access to menu options
box_open = .F.

* avoid confusion
keystroke = 0
SetColor(saveColor)
RETURN 0


******
*	draw_relat()
*
*	fill the relations window
******
FUNCTION draw_relat

PARAMETERS start_el
PRIVATE i

* clear the window
scroll(11, column[1], 22, M->pos_r, 0)

i = 0

DO WHILE M->i < 6 .AND. M->start_el + M->i <= LEN(M->k_relate)

	IF EMPTY(k_relate[M->start_el + M->i])
		* end of active list
		EXIT

	ENDIF

	* display one relation
	disp_relation(11 + (2 * M->i), M->start_el + M->i, color7)

	* next
	i = M->i + 1

ENDDO

IF M->start_el > 1
	* indicate active elements above window
	@ 11, M->pos_r SAY M->more_up

ENDIF

IF M->start_el + M->i <= LEN(M->k_relate)
	* off-screen element within subscript range

	IF .NOT. EMPTY(k_relate[M->start_el + M->i])
		* indicate active elements below window
		@ 22, M->pos_r SAY M->more_down

	ENDIF
ENDIF

RETURN 0


******
*	get_relation()
*
*	accept entry of one relationship
*
*	note: a character key may be used to select a file whose
*		  name begins with that letter
******
FUNCTION get_relation

PARAMETERS row_n, element

PRIVATE stroke, k_input, k_trim, s_alias, t_alias, i, j, q, pos_c,;
		ntx_expr, k_type, ok

IF isdata(M->keystroke)
	* character key..look for matching filename
	i = c_search(UPPER(CHR(M->keystroke)), M->dbf, 0, afull(M->dbf))

	IF SUBSTR(dbf[M->i],1,1) = UPPER(CHR(M->keystroke))
		* found..make the selection as the source file
		KEYBOARD CHR(13)

	ENDIF

ELSE

	IF EMPTY(k_relate[M->element])
		* brand new..start at the beginning
		i = 1

	ELSE
		* relation exists..begin with source file
		i = ASC(s_relate[M->element]) - ASC("A") + 1

	ENDIF
ENDIF

j = 0
stroke = 0

DO WHILE .NOT. (M->j > 0 .AND. M->stroke = 13)
	* till both source and target files are selected

	DO CASE

		CASE M->stroke = 13
			* enter key..select source

			IF M->i < 6
				* can only select if another file is open to the right

				IF .NOT. EMPTY(dbf[M->i + 1])

					IF .NOT. EMPTY(k_relate[M->element])
						* assume same target for existing relation
						j = ASC(t_relate[M->element]) - ASC("A") + 1

					ENDIF

					IF M->j <= M->i
						* target must be to the right of the source
						j = M->i + 1

					ENDIF
				ENDIF
			ENDIF

			stroke = 0

		CASE M->stroke = 4
			* right arrow

			IF M->j = 0 .AND. M->i < 6
				* source not selected..change source

				IF .NOT. EMPTY(dbf[M->i + 1])
					* only open files are selectable
					i = M->i + 1

				ENDIF

			ELSE

				IF M->j > 0 .AND. M->j < 6
					* source selected..change target

					IF .NOT. EMPTY(dbf[M->j + 1])
						* only open files are selectable
						j = M->j + 1

					ENDIF
				ENDIF
			ENDIF

			stroke = 0

		CASE M->stroke = 19
			* left arrow

			IF M->j = 0 .AND. M->i > 1
				* source not selected..change source
				i = M->i - 1

			ELSE

				IF M->j > 0
					* source selected..change target
					j = M->j - 1

					IF M->j = M->i
						* target must be to the right
						j = 0	&& revert to unselected source

					ENDIF
				ENDIF
			ENDIF

			stroke = 0

		CASE isdata(M->stroke)
			* character key..perform character search
			q = c_search(UPPER(CHR(M->stroke)),M->dbf,M->i,afull(M->dbf))

			IF SUBSTR(dbf[M->q],1,1) = UPPER(CHR(M->stroke))
				* found

				IF M->j = 0
					* source not selected..make selection
					i = M->q
					KEYBOARD CHR(13)

				ELSE

					IF M->q > M->i
						* found file is acceptable as target..make selection
						j = M->q
						KEYBOARD CHR(13)

					ELSE
						* found file cannot be target
						j = 0		&& revert to unselected source
						i = M->q	&& found file is current s_alias

					ENDIF
				ENDIF
			ENDIF

			stroke = 0

		CASE M->stroke = 27
			* escape..abort
			@ M->row_n,column[1] SAY SPACE(M->width)
			RETURN 0

		CASE M->stroke = 28
			* "help" selected from pull-down menu
			DO syshelp
			stroke = 0

		OTHERWISE
			* update screen and get new stroke

			IF M->j = 0
				* source file not selected..clear the row
				@ M->row_n,column[1] SAY SPACE(M->width)

				* extract the current source alias
				s_alias = name(dbf[M->i])

				* display it as intense
				SetColor(M->color12)
				@ M->row_n,column[M->i] + 2 SAY M->s_alias
				SetColor(M->cNorm)

			ELSE
				* source selected (do not disturb)..extract target alias
				t_alias = name(dbf[M->j])

				* calculate column after s_alias
				pos_c = column[M->i] + 2 + LEN(M->s_alias)

				* clear to right edge of window
				@ M->row_n,M->pos_c SAY SPACE(M->pos_r - M->pos_c)

				* draw line and arrow pointing to target alias
				@ M->row_n,M->pos_c;
				SAY REPLICATE("ฤ", column[M->j] - M->pos_c + 1) + CHR(16)

				* display target alias as intense
				SetColor(M->color12)
				?? t_alias
				SetColor(M->cNorm)

			ENDIF

			* get new stroke
			stroke = raw_key()

	ENDCASE
ENDDO

* hilite source and target in reverse video to indicate both selected
SetColor(M->cHilite)
@ M->row_n,column[M->i] + 2 SAY M->s_alias
@ M->row_n,column[M->j] + 2 SAY M->t_alias
SetColor(M->cNorm)

* determine correct type for relation expression
SELECT (M->j)
ntx_expr = ctrl_key()		&& get the controlling index key

IF EMPTY(M->ntx_expr)
	* target not indexed..must be numeric or recno()
	k_type = "N"

ELSE
	* same type as target index key
	k_type = TYPE(M->ntx_expr)

ENDIF

* select source work area to test key expression
SELECT (M->i)

* start with previous expression
k_trim = k_relate[M->element]
ok = .F.

DO WHILE .NOT. M->ok
	* accept input of key expression
	k_trim = enter_rc(M->k_trim, M->row_n + 1, column[M->i] + 2,;
					  127, "@KS" + LTRIM(STR(M->pos_r - column[M->i] - 2)),;
					  M->color1)

	* empty expression will abort, else must be correct type
	ok = EMPTY(M->k_trim) .OR. TYPE(M->k_trim) = M->k_type

	IF .NOT. M->ok
		error_msg("Invalid Expression")

	ENDIF
ENDDO

* clear the expression row
@ M->row_n + 1,column[1] SAY SPACE(M->width)

IF EMPTY(M->k_trim)
	* abort
	RETURN 0

ENDIF

* will need to set relations
need_relat = .T.

* store defined relation in global arrays
k_relate[M->element] = M->k_trim
s_relate[M->element] = CHR(M->i + ASC("A") - 1) + M->s_alias
t_relate[M->element] = CHR(M->j + ASC("A") - 1) + M->t_alias

RETURN 0


******
*	disp_relation()
*
*	display the specified relation on the specified row in the specified color
******
FUNCTION disp_relation

PARAMETERS disp_row, element, cSpecial
PRIVATE j, k

IF EMPTY(k_relate[M->element])
	* clear lines only
	@ M->disp_row,column[1] SAY SPACE(M->width)
	@ M->disp_row + 1,column[1] SAY SPACE(M->width)
	RETURN 0

ENDIF

* calculate the work areas of the related files
j = ASC(s_relate[M->element]) - ASC("A") + 1	&& source
k = ASC(t_relate[M->element]) - ASC("A") + 1	&& target

* display the source alias in the specified color
SetColor(M->cSpecial)
@ M->disp_row, column[M->j] + 2 SAY SUBSTR(s_relate[M->element], 2)
SetColor(M->cNorm)

* display an arrow (always normal color)
?? REPLICATE("ฤ", column[M->k] - COL() + 1) + CHR(16)

* display the target alias in the specified color
SetColor(M->cSpecial)
?? SUBSTR(t_relate[M->element], 2)
SetColor(M->cNorm)

* display the key on the next line (always normal color)
@ M->disp_row + 1, column[M->j] + 2;
SAY pad(k_relate[M->element], M->pos_r - column[M->j] - 2)

RETURN 0


******
*	c_search()
*
*	find the next array element with a matching first character
******
FUNCTION c_search

PARAMETERS c, array, cur_el, num_d
PRIVATE chr_el

* begin with next element
chr_el = M->cur_el + 1

DO WHILE M->chr_el <= M->num_d
	* forward search..exit if found

	IF UPPER(SUBSTR(array[M->chr_el], 1, 1)) = UPPER(M->c)
		EXIT

	ENDIF

	* next
	chr_el = M->chr_el + 1

ENDDO

IF M->chr_el > M->num_d
	* not found..search from beginning
	chr_el = 1

	DO WHILE M->chr_el < M->cur_el .AND.;
			 UPPER(SUBSTR(array[M->chr_el], 1, 1)) <> UPPER(M->c)

		* next
		chr_el = M->chr_el + 1

	ENDDO
ENDIF

RETURN M->chr_el


******
*	ctrl_key()
*
*	return controlling index key for the current work area
******
FUNCTION ctrl_key

PRIVATE key, ntx

IF M->need_ntx
	* index may be specified but not set
	ntx = "ntx" + LTRIM(STR(SELECT()))

	* read key directly from file
	key = ntx_key(&ntx[1])

ELSE
	* get key from system if index already set
	key = INDEXKEY(0)

ENDIF

RETURN M->key


******
*	get_filter()
*
*	accept entry of filter expression for the current work area
******
FUNCTION get_filter

PRIVATE k_filter,k_trim,old_help

* save old and set new help codes
old_help = M->help_code
help_code = 7

* get the current contents of the filter expression
k_filter = "kf" + SUBSTR("123456", M->cur_area, 1)
k_trim = &k_filter

* select the current work area for testing of filter expression
SELECT (M->cur_area)

* hilite the affected data file
hi_cur()

* establish array for mulitbox
DECLARE boxarray[4]

boxarray[1] = "fltr_title(sysparam)"
boxarray[2] = "getfilter(sysparam)"
boxarray[3] = "ok_button(sysparam)"
boxarray[4] = "can_button(sysparam)"

* indicate the function that will complete the process
okee_dokee = "do_filter()"

* open the box
multibox(7, 17, 5, 2, M->boxarray)

* restore help code
help_code = M->old_help

* un-hilite the name of the current data file
dehi_cur()

RETURN 0


******
*	fltr_title()
*
*	display title for filter entry
******
FUNCTION fltr_title

PARAMETERS sysparam

* title includes filename.ext but no path
RETURN box_title(M->sysparam, "Set filter for " +;
							  SUBSTR(M->cur_dbf, RAT("\", M->cur_dbf) + 1) +;
							  " to...")


******
*	getfilter()
*
*	accept input of filter expression to the temporary variable "k_trim"
******
FUNCTION getfilter

PARAMETERS sysparam

RETURN get_k_trim(M->sysparam, "Condition")


******
*	do_filter()
*
*	complete the filter entry
******
FUNCTION do_filter

PRIVATE done, k_sample

IF EMPTY(M->k_trim)
	* a confirmed empty expression means eliminate the current filter
	done = .T.

	IF .NOT. EMPTY(&k_filter)
		* cancel any filter that may be active
		SET FILTER TO

		* set global filter expression to nul
		&k_filter = ""

	ENDIF

ELSE

	IF TYPE(M->k_trim) = "L"
		* expression evaluates ok
		done = .T.

		IF .NOT. (&k_filter == M->k_trim)
			* change in filter expression..set global variables
			need_filtr = .T.
			&k_filter = M->k_trim

		ENDIF

	ELSE
		done = .F.
		error_msg("Filter must be a Logical expression")

	ENDIF
ENDIF

RETURN M->done


******
*	clear_dbf()
*
*	clear specified work area..shift higher work areas if requested
*
*	shift values:
*		0  =  no shift
*		1  =  shift right (insert)
*		2  =  shift left (delete)
******
FUNCTION clear_dbf

PARAMETERS work_area, shift
PRIVATE s_alias,c_area,temp,xtemp,i,file_name,alias_6,n_active

* determine number of active work areas
n_active = afull(M->dbf)

* extract alias of specified work area
s_alias = name(dbf[M->work_area])

* area 6 could be affected if shifting due to insert
alias_6 = ""

* access the list of index files for the current area
temp = "ntx" + SUBSTR("123456", M->work_area, 1)

DO CASE

	CASE M->shift = 0
		* no shift..no problem
		dbf[M->work_area] = ""

		* reduce number of open files by no. of index files + 1
		n_files = M->n_files - afull(&temp) - 1

	CASE M->shift = 1
		* shift right..current data file (if any) will remain open

		IF .NOT. EMPTY(dbf[6])
			* remember the alias
			alias_6 = name(dbf[6])

			* reduce number of open files by no. of index files + 1
			n_files = M->n_files - afull(M->ntx6) - 1

		ENDIF

		* shift may not be needed after all
		shift = IF(EMPTY(dbf[M->work_area]) .OR. M->work_area = 6, 0, 1)

		* open an empty element in global array of data files
		array_ins(M->dbf, M->work_area)

	CASE M->shift = 2
		* shift left..current data file will be closed
		array_del(M->dbf, M->work_area)

		* shift may not be needed after all
		shift = IF(EMPTY(dbf[M->work_area]), 0, 2)

		* reduce number of open files by no. of index files + 1
		n_files = M->n_files - afull(&temp) - 1

ENDCASE

i = 1

DO WHILE M->i <= M->n_active
	* select area i
	c_area = CHR(M->i + ASC("A") - 1)
	SELECT (M->i)

	* search filters in all active areas for disappearing aliases
	temp = "kf" + SUBSTR("123456", M->i, 1)

	IF (((M->s_alias + "->" $ UPPER(&temp)) .OR.;
	   (M->i = M->work_area .AND. .NOT. EMPTY(&temp)));
	   .AND. M->shift <> 1) .OR. (.NOT. EMPTY(M->alias_6) .AND.;
	   M->alias_6 + "->" $ UPPER(&temp) .AND. M->shift = 1)
		* data file was part of filter expression or none can exist

		* turn of the filter
		SET FILTER TO

		* will need to reset
		need_filtr = .T.

		* set global filter expression to nul
		&temp = ""

	ENDIF

	IF M->i = M->work_area .OR. (M->i > M->work_area .AND. M->shift <> 0)
		* close all work areas to be shifted or closed
		USE
   ENDIF

	* next
	i = M->i + 1

ENDDO

DO CASE

	CASE M->shift = 0
		* clear array of index files
		temp = "ntx" + SUBSTR("123456", M->work_area, 1)
		afill(&temp, "")

		* clear field list
		temp = "field_n" + SUBSTR("123456", M->work_area, 1)
		afill(&temp, "")

		* clear filter
		temp = "kf" + SUBSTR("123456", M->work_area, 1)
		&temp = ""

	CASE M->shift = 1
		* shift right
		need_filtr = .T.	&& will need to reset
		need_ntx = .T.		&& ditto

		* count backwards..dbf array may not be contiguous
		i = 6

		DO WHILE EMPTY(dbf[M->i])
			* find highest active area
			i = M->i - 1

		ENDDO

		DO WHILE M->i > M->work_area
			* shift all higher work areas..list of index files
			temp = "ntx" + SUBSTR("123456", M->i, 1)
			xtemp = "ntx" + SUBSTR("123456", M->i - 1, 1)
			acopy(&xtemp,&temp)

			* active fields list
			temp = "field_n" + SUBSTR("123456", M->i, 1)
			xtemp = "field_n" + SUBSTR("123456", M->i - 1, 1)
			acopy(&xtemp,&temp)

			* current rows
         temp = "_cr" + SUBSTR("123456", M->i, 1)
         xtemp = "_cr" + SUBSTR("123456", M->i - 1, 1)
			acopy(&xtemp,&temp)

			* current elements
         temp = "_el" + SUBSTR("123456", M->i, 1)
         xtemp = "_el" + SUBSTR("123456", M->i - 1, 1)
			acopy(&xtemp,&temp)

			* filter expressions
			temp = "kf" + SUBSTR("123456", M->i, 1)
			xtemp = "kf" + SUBSTR("123456", M->i - 1, 1)
			&temp = &xtemp

			* next
			i = M->i - 1

		ENDDO

		* clear the specified work area (i = work_area)
		xtemp = SUBSTR("123456", M->i, 1)	&& str(i) for convenience

		* clear index files list
		temp = "ntx" + xtemp
		afill(&temp, "")

		* clear active fields list
		temp = "field_n" + xtemp
		afill(&temp, "")

		* clear filter expression
		temp = "kf" + xtemp
		&temp = ""

		* reset current rows
      temp = "_cr" + xtemp
		&temp[2] = row_a[2]
		&temp[3] = row_a[3]

		* reset current elements
      temp = "_el" + xtemp
		afill(&temp, 1)

	CASE M->shift = 2
		* shift left
		need_filtr = .T.	&& will need to reset
		need_ntx = .T.		&& ditto

		i = M->work_area

		DO WHILE M->i < 6 .AND. .NOT. EMPTY(dbf[M->i])
			* shift all higher work areas..list of index files
			temp = "ntx" + SUBSTR("123456", M->i, 1)
			xtemp = "ntx" + SUBSTR("123456", M->i + 1, 1)
			acopy(&xtemp,&temp)

			* active fields list
			temp = "field_n" + SUBSTR("123456", M->i, 1)
			xtemp = "field_n" + SUBSTR("123456", M->i + 1, 1)
			acopy(&xtemp,&temp)

			* current rows
         temp = "_cr" + SUBSTR("123456", M->i, 1)
         xtemp = "_cr" + SUBSTR("123456", M->i + 1, 1)
			acopy(&xtemp,&temp)

			* current elements
         temp = "_el" + SUBSTR("123456", M->i, 1)
         xtemp = "_el" + SUBSTR("123456", M->i + 1, 1)
			acopy(&xtemp,&temp)

			* filter expressions
			temp = "kf" + SUBSTR("123456", M->i, 1)
			xtemp = "kf" + SUBSTR("123456", M->i + 1, 1)
			&temp = &xtemp

			* next
			i = M->i + 1

		ENDDO

		* clear the last (previously active) work area
		xtemp = SUBSTR("123456", M->i, 1)	&& str(i) for convenience

		* clear index files list
		temp = "ntx" + M->xtemp
		afill(&temp, "")

		* clear active fields list
		temp = "field_n" + M->xtemp
		afill(&temp, "")

		* clear filter expression
		temp = "kf" + M->xtemp
		&temp = ""

		* reset current rows
      temp = "_cr" + M->xtemp
		&temp[2] = row_a[2]
		&temp[3] = row_a[3]

		* reset current elements
      temp = "_el" + M->xtemp
		afill(&temp, 1)

ENDCASE

* will need to reset
need_field = .T.

**
*	note: the source and target of relations are identified
*		  by the letter of the work area + the alias
**

* get letter of cleared work area
c_area = CHR(M->work_area + ASC("A") - 1)

i = 1

DO WHILE M->i <= LEN(M->k_relate)
	* search all active relations

	IF EMPTY(k_relate[M->i])
		* no more active relations
		EXIT

	ENDIF

	IF ((SUBSTR(s_relate[M->i], 1, 1) = M->c_area .OR.;
	   SUBSTR(t_relate[M->i], 1, 1) = M->c_area) .AND. M->shift <> 1) .OR.;
	   (M->shift = 1 .AND. SUBSTR(t_relate[M->i], 1, 1) = "F")
		* relation must be removed from list

		array_del(M->s_relate, M->i)
		array_del(M->k_relate, M->i)
		array_del(M->t_relate, M->i)
		need_relat = .T.

	ELSE

		IF (M->shift = 2 .AND. SUBSTR(s_relate[M->i], 1, 1) > M->c_area) .OR.;
		   (M->shift = 1 .AND. SUBSTR(s_relate[M->i], 1, 1) >= M->c_area)
			* source work area was shifted..adjust source area

			s_relate[M->i] = CHR(ASC(SUBSTR(s_relate[M->i], 1, 1)) +;
							 IF(M->shift = 1, 1, -1)) +;
							 SUBSTR(s_relate[M->i], 2)
			need_relat = .T.

		ENDIF

		IF (M->shift = 2 .AND. SUBSTR(t_relate[M->i], 1, 1) > M->c_area) .OR.;
		   (M->shift = 1 .AND. SUBSTR(t_relate[M->i], 1, 1) >= M->c_area)
			* target work area was shifted..adjust target area

			t_relate[M->i] = CHR(ASC(SUBSTR(t_relate[M->i], 1, 1)) +;
							 IF(M->shift = 1, 1, -1)) +;
							 SUBSTR(t_relate[M->i], 2)
			need_relat = .T.

		ENDIF

		* next
		i = M->i + 1

	ENDIF
ENDDO

IF M->shift <> 0
	* re-open active data files in new work areas
	i = 6

	DO WHILE M->i >= M->work_area
		* search all shifted work areas

		IF .NOT. EMPTY(dbf[M->i])
			* open data file
			c_area = CHR(M->i + ASC("A") - 1)
			SELECT (M->i)
			file_name = dbf[M->i]
         NetUse( file_name )

		ENDIF

		* next
		i = M->i - 1

	ENDDO
ENDIF

RETURN 0


******
*	save_view()
*
*	save the current view in a ".VEW" file
*
*	note: - the view file is a data base file with a default extension
*			of ".VEW" and 2 fields: "item_name" and "contents".
*		  -	the first 2 items are reserved for the global variables
*			"cur_dir", and "n_files"..then a variable number of
*			filter expressions..the remaining items are arrays.
*		  -	if the contents of an item will not fit in the contents
*			field, it will be continued in the next record where
*			the item_name will be left blank.
*		  -	for arrays, only the identifier is saved..the number of
*			items is the number of elements to fill
******
FUNCTION save_view

PRIVATE filename, old_help

* save old and set new help codes
old_help = M->help_code
help_code = 21

* get user entered file name..will default to primary + ".VEW"
IF EMPTY(M->view_file) .AND. .NOT. EMPTY(dbf[1])
	* default to name of primary data file
	filename = name(dbf[1]) + ".VEW"

ELSE
	* whatever the last view was
	filename = M->view_file

ENDIF

* it's better in a box
filebox(".VEW", "vew_list", "vcrea_titl", "do_creavew", .T., 8)

* restore help code
help_code = M->old_help

RETURN 0


******
*	vcrea_titl()
*
*	display title for save view
******
FUNCTION vcrea_titl

PARAMETERS sysparam

RETURN box_title(M->sysparam, "Save view as...")


******
*	do_creavew()
*
*	save the current view in a .VEW file
******
FUNCTION do_creavew

LOCAL cAlias
PRIVATE i, j, k, m_name, l_name, add_name

IF EMPTY(M->filename)
	error_msg("View file not selected")
	RETURN .F.

ENDIF

* select system reserved work area
SELECT 10

stat_msg("Generating View File")

* add new .VEW files to vew_list if created in current directory only
add_name = .NOT. FILE(name(filename) + ".VEW")

* create structure extended template
CREATE ddbbuuuu.ext

* define 2 fields
APPEND BLANK
REPLACE field_name WITH "ITEM_NAME",field_type WITH "C",field_len WITH 10

APPEND BLANK
REPLACE field_name WITH "CONTENTS",field_type WITH "C",field_len WITH 10

* create the view file
USE
cAlias := MakeAlias( filename )
CREATE &filename FROM ddbbuuuu.ext ALIAS cAlias

* set global variable
view_file = M->filename

* open view file..avoid alias conflict
NetUse( view_file, NIL, NIL, "ddbbuuuu" )

* erase template
ERASE ddbbuuuu.ext

* 2 global variables always saved
APPEND BLANK
REPLACE item_name WITH "cur_dir"
put_line(cur_dir)

APPEND BLANK
REPLACE item_name WITH "n_files"
put_line(LTRIM(STR(n_files)))

i = 1

DO WHILE i <= 6
	* filters

	IF EMPTY(dbf[i])
		* no more data files
		EXIT

	ENDIF

	* get variable name for macro expansion
	m_name = "kf" + SUBSTR("123456", i, 1)

	IF .NOT. EMPTY(&m_name)
		* only save active filters
		APPEND BLANK
		REPLACE item_name WITH m_name
		put_line(&m_name)

	ENDIF

	* next
	i = i + 1

ENDDO

* save arrays..avoid saving empty elements
i = 1

DO WHILE i <= 6
	* data file filespecs

	IF EMPTY(dbf[i])
		* no more data files
		EXIT

	ENDIF

	* save one filespec
	APPEND BLANK
	REPLACE item_name WITH "dbf"
	put_line(dbf[i])

	* next
	i = i + 1

ENDDO

* save index lists and fields lists
l_name = "ntx"

FOR k = 1 TO 2
	* first the indexed, then the fields
	i = 1

	DO WHILE i <= 6
		* index or field list for each data file

		IF EMPTY(dbf[i])
			* no more data files
			EXIT

		ENDIF

		* get array identifier for macro expansion
		m_name = l_name + SUBSTR("123456", i, 1)

		j = 1

		DO WHILE j <= LEN(&m_name)
			* index or field list for one data file

			IF EMPTY(&m_name[j])
				* an early exit saves time and disk space
				EXIT

			ENDIF

			* save one index filespec or one field name
			APPEND BLANK
			REPLACE item_name WITH m_name
			put_line(&m_name[j])

			* next element
			j = j + 1

		ENDDO

		* next work area
		i = i + 1

	ENDDO

	* switch to field lists
	l_name = "field_n"

NEXT

i = 1

DO WHILE i <= 3
	* relations in 3 arrays..s_relate, k_relate, and t_relate
	m_name = SUBSTR("skt", i, 1) + "_relate"
	j = 1

	DO WHILE j <= LEN(&m_name)
		* one array

		IF EMPTY(&m_name[j])
			* an early exit saves time and disk space
			EXIT

		ENDIF

		* one item
		APPEND BLANK
		REPLACE item_name WITH m_name
		put_line(&m_name[j])

		* next element
		j = j + 1

	ENDDO

	* next array
	i = i + 1

ENDDO

* close view file
USE

* add file name to array of view files
IF AT(".VEW", filename) = LEN(filename) - 3 .AND.;
   FILE(name(filename) + ".VEW") .AND. add_name
	* add only new .VEW files in the current directory

	* determine number of first empty element
	i = afull(vew_list) + 1

	IF i <= LEN(vew_list)
		* room for one more
		vew_list[i] = filename

		* must be alphabetical
		array_sort(vew_list)

	ENDIF
ENDIF

stat_msg("")

RETURN .T.


******
*	put_line()
*
*	store string in contents field(s) of open view file
******
FUNCTION put_line

PARAMETERS line
PRIVATE pos

* assign contents to the current record
REPLACE contents WITH line

* position to begin fragmentation
pos = LEN(contents) + 1

DO WHILE pos <= LEN(line)
	* continue contents in next record
	APPEND BLANK
	REPLACE contents WITH SUBSTR(line, pos)

	* next chunk
	pos = pos + LEN(contents)

ENDDO

RETURN 0


******
*	set_from()
*
*	restore View from .VEW file
******
FUNCTION set_from

PARAMETERS from_view
PRIVATE filename, old_help

* save old and set new help codes
old_help = M->help_code
help_code = 21

* default to previous View file if any
filename = M->view_file

IF M->from_view
	* called from set_view

	IF filebox(".VEW", "vew_list", "vopen_titl", "do_openvew", .F., 8) <> 0
		* indicate new View has been set
		keystroke = 13

	ENDIF

ELSE
	* just do it
	do_openvew()

ENDIF

* restore help code
help_code = M->old_help

RETURN 0


******
*	vopen_titl()
*
*	display title for restore view
******
FUNCTION vopen_titl

PARAMETERS sysparam

RETURN box_title(M->sysparam, "Restore view from...")


******
*	do_openvew()
*
*	restore view from .VEW file
*
*	note: this function is called when the enter key is
*		  pressed while the cursor is on the Ok button
******
FUNCTION do_openvew

PRIVATE m_name, i, done

DO CASE

	CASE EMPTY(M->filename)
		error_msg("View file not selected")
		done = .F.

	CASE .NOT. FILE(M->filename)
		error_msg("Can't open " + M->filename)
		done = .F.

	OTHERWISE
		* select system reserved work area
		SELECT 10

		* open .VEW file..avoid alias conflict
      NetUse( filename, NIL, NIL, "ddbbuuuu" )

		IF .NOT. (TYPE("item_name") = "C" .AND. TYPE("contents") = "C")
			USE
			error_msg("Invalid view file")
			RETURN .F.

		ENDIF

		* ok to restore View..set global variable
		view_file = M->filename

		* entire View will need setup
		STORE .T. TO need_field,need_ntx,need_relat,need_filtr
		stat_msg("Restoring view")

		* clear the current view if any
		i = 6

		DO WHILE M->i > 0

			IF .NOT. EMPTY(dbf[M->i])
				* clear one work area
				clear_dbf(M->i, 0)

			ENDIF

			* next
			i = M->i - 1

		ENDDO

		* select system reserved work area
		SELECT 10

		* "cur_dir" and "n_files" always saved first
		cur_dir = get_line()
		n_files = VAL(get_line())

		IF TRIM(item_name) == "k_filter"
			* continued support for old format
			REPLACE item_name WITH "kf1"
			kf1 = get_line()

		ELSE

			DO WHILE SUBSTR(item_name, 1, 2) == "kf"
				* get one filter expression
				m_name = TRIM(item_name)

				* assign the expression
				&m_name = get_line()

			ENDDO
		ENDIF

		* all remaining information to be stored in global arrays
		DO WHILE .NOT. EOF()
			* get next array identifier and initialize subscript
			m_name = TRIM(item_name)
			i = 1

			* fill one array
			DO WHILE TRIM(item_name) == m_name
				* fill one element of array
				&m_name[i] = get_line()

				* next element
				i = i + 1

			ENDDO
		ENDDO

		* close the view file
		USE

		* open all data files in their select areas
		i = 1

		DO WHILE M->i <= 6

			IF EMPTY(dbf[M->i])
				* no more data files to open
				EXIT

			ENDIF

			* select the corresponding work area
			SELECT (M->i)

			* open the data file
			filename = dbf[M->i]
         NetUse( filename )

			* next work area
			i = M->i + 1

		ENDDO

		stat_msg("")
		done = .T.

ENDCASE

RETURN M->done


******
*	get_line()
*
*	assemble contents of variable from .VEW file
******
FUNCTION get_line

PRIVATE line

* assign contents from first record
line = TRIM(contents)
SKIP

DO WHILE LEN(TRIM(item_name)) = 0 .AND. .NOT. EOF()
	* blank name field means contents are continued in next record
	line = line + TRIM(contents)
	SKIP

ENDDO

RETURN line


* EOF DBUVIEW.PRG
