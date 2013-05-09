/***
*
*  Dbustru.prg
*
*  DBU Create/Modify Structure Module
*
*  Copyright (c) 1990-1993, Computer Associates International, Inc.
*  All rights reserved.
*
*/


******
*	modi_stru
*
*	create or modify the structure of a database file
******
PROCEDURE modi_stru
local saveColor
PRIVATE filename,fill_row,cur_row,rec1,m_item,i,n,f_name,f_type,f_len,f_dec,;
		prev_rec,field_id,stru_ok,is_insert,is_append,altered,type_n,;
		empty_row,not_empty,old_help,chg_name,len_temp,stru_name,;
		wstru_buff

* save help code
old_help = help_code
saveColor := SetColor(M->color7)

* allocate buffer and save window
wstru_buff = SAVESCREEN(8, 20, 23, 59)

* local arrays..constant values
DECLARE ffield[4]
DECLARE field_col[4]
DECLARE data_type[5]
DECLARE l_usr[5]

* field list for structure file
ffield[1] = "field_name"
ffield[2] = "field_type"
ffield[3] = "field_len"
ffield[4] = "field_dec"

* display columns for ffield[]
field_col[1] = 22
field_col[2] = 35
field_col[3] = 48
field_col[4] = 55

* data types as character strings
data_type[1] = "Character"
data_type[2] = "Numeric  "
data_type[3] = "Date     "
data_type[4] = "Logical  "
data_type[5] = "Memo     "

* last user definable ffield for each data type
l_usr[1] = 3			&& character - variable len
l_usr[2] = 4			&& numeric - variable len and dec
l_usr[3] = 2			&& date - fixed len - 8
l_usr[4] = 2			&& logical - fixed len - 1
l_usr[5] = 2			&& memo - fixed len - 10

* initialize local variables
type_n = 1				&& index into data types
altered = .F.			&& any changes?
chg_name = .T.			&& possible to change field names?
prev_rec = 0			&& detect record movement
n = 1					&& current cursor column (1 - 4)
i = 0					&& invalid field aspect
cur_row = 13			&& current cursor row
is_insert = .F.			&& .T. if insert new field
keystroke = 999			&& for initial screen fill
filename = ""			&& variable for "filebox" function

* sigle row templates
empty_row = "           ณ           ณ       ณ    "
not_empty = "           ณ Character ณ    10 ณ    "

IF .NOT. EMPTY(M->cur_dbf)
	* modify structure
	stat_msg("Reading file structure")
	stru_name = M->cur_dbf
	SELECT (M->cur_area)

   // Attempt to re-open file exclusively if it's opened shared
   IF NetMode()
      IF !NetUse( M->cur_dbf, .T.,,, .T. )
         ErrMsg( "Cannot modify the structure of " + M->cur_dbf + ;
                 ":;Unable to obtain exclusive use" )
         IF !NetUse( M->cur_dbf,,,, .T. )
            clear_dbf(M->cur_area, 2)
            cur_dbf = dbf[M->cur_area]
         ENDIF
         RETURN         /* NOTE */
      ENDIF
   ENDIF

	* create system structure extended file
	COPY TO ddbbuuuu.ext STRUCTURE EXTENDED

	* open structure extended file in system reserved select area
	SELECT 10
	USE ddbbuuuu.ext

	* structure is valid and no new fields added
	stru_ok = .T.
	is_append = .F.

	* update screen header
	stat_msg("")

ELSE
	* create structure
	SELECT 10
	CREATE ddbbuuuu.ext

	* add first new field as yet undefined
	APPEND BLANK
	REPLACE field_type WITH "C",field_len WITH 10,field_dec WITH 0

	* structure is not valid
	stru_ok = .F.
	is_append = .T.
	stru_name = ""

ENDIF

* clear and frame window
scroll(8, 20, 23, 59, 0)
@ 8, 20, 23, 59 BOX M->frame

* establish window heading
@ 9,field_col[1];
SAY "Structure of " + pad(IF(EMPTY(stru_name), "<new file>",;
							SUBSTR(stru_name, RAT("\", stru_name) + 1)), 13)

@ 11,22 SAY   "Field Name   Type        Width   Dec"
@ 12,20 SAY "ฦออออออออออออัอออออออออออัอออออออัอออออต"
@ 23,33 SAY              "ฯอออออออออออฯอออออออฯ"

DO WHILE .NOT. q_check()
	* the big switch

	DO CASE

		CASE keystroke = 999
			* draw window
			scroll(13, 21, 22, 58, 0)			&& clear window
			rec1 = RECNO()						&& first record in window
			fill_row = 13						&& first row to fill

			DO WHILE .NOT. EOF() .AND. fill_row <= 22
				* fill the window
				stru_row(fill_row)

				* next field/record number
				SKIP
				fill_row = fill_row + 1

			ENDDO

			DO WHILE fill_row <= 22
				* end of file..complete vertical bar lines
				@ fill_row,field_col[1] SAY empty_row
				fill_row = fill_row + 1

			ENDDO

			* adjust record pointer to current row
			GOTO rec1
			fill_row = 13

			DO WHILE fill_row < cur_row
				* move to same row if possible
				SKIP

				IF EOF()
					* can't go all the way
					cur_row = fill_row
					GO BOTTOM
					EXIT

				ENDIF

				fill_row = fill_row + 1

			ENDDO

			keystroke = 0			&& get new keystroke

		CASE keystroke = 13 .OR. isdata(keystroke)
			* enter/select something

			IF n = 2
				* field_type gets special treatment
				type_n = AT(field_type, "CNDLM")

			ELSE
				* turn on cursor for GET
				SET CURSOR ON

				IF keystroke <> 13
					* forward data character to GET system
					KEYBOARD CHR(keystroke)

				ENDIF
			ENDIF

			* get descriptor fieldname to normal variable for macro expansion
			field_id = ffield[n]

			* save item to test for change
			m_item = &field_id

			* set up and down arrows and menu keys to exit read
			SET KEY 5 TO clear_gets
			SET KEY 24 TO clear_gets
			xkey_clear()

			DO CASE

				CASE n = 1
					* get is for field_name..force all caps
					SetColor(M->color1)
					@ cur_row,field_col[1] GET field_name PICTURE "@!K"
					READ
					SetColor(M->color7)
					keystroke = LASTKEY()

				CASE n = 2
					* special treatment for field_type

					DO CASE

						CASE UPPER(CHR(keystroke)) $ "CNDLM"
							* set field type to one of C, N, D, L, or M
							type_n = AT(UPPER(CHR(keystroke)), "CNDLM")
							keystroke = 13

						CASE keystroke = 32
							* space bar..revolving field types
							type_n = IF(type_n = 5, 1, type_n + 1)

						CASE keystroke <> 13
							* return key behaves like right arrow
							keystroke = 0

					ENDCASE

					IF m_item <> SUBSTR("CNDLM", type_n, 1)
						* set new field_type from type_n
						REPLACE field_type WITH SUBSTR("CNDLM", type_n, 1)

						DO CASE
							* set field_len and field_dec according to type

							CASE field_type = "C"
								* character..any len will do, but not any dec
								REPLACE field_dec WITH 0

							CASE field_type = "N"
								* numeric

								IF m_item = "C" .AND. (field_dec <> 0 .OR.;
								   field_len > 19)
									* too long or Clipper extended len
									REPLACE field_len WITH 10,field_dec WITH 0

								ENDIF

							CASE field_type = "D"
								* date..always 8
								REPLACE field_len WITH 8,field_dec WITH 0

							CASE field_type = "L"
								* logical..always 1
								REPLACE field_len WITH 1,field_dec WITH 0

							CASE field_type = "M"
								* memo..always 10
								REPLACE field_len WITH 10,field_dec WITH 0

						ENDCASE

						* display new field_len
						@ cur_row,field_col[3] SAY STR(field_len,4)

						IF field_type = "N"
							* display new field_dec
							@ cur_row,field_col[4] SAY field_dec

						ELSE
							* ensure a blank field_dec column
							@ cur_row,field_col[4] SAY "   "

						ENDIF
					ENDIF new type

				CASE n = 3
					* get is for field_len

					IF field_type = "C"
						* get Clipper extended field length into memvar
						len_temp = (256 * field_dec) + field_len

					ELSE
						* normal field_len
						len_temp = field_len

					ENDIF

					* get the new length
					SetColor(M->color1)
					@ cur_row,field_col[n] GET len_temp PICTURE "9999"
					READ
					SetColor(M->color7)
					keystroke = LASTKEY()

					IF menu_key() = 0
						* no menu request

						IF field_type = "C"
							* put Clipper extended field length into len/dec
							REPLACE field_len WITH (len_temp % 256)
							REPLACE field_dec WITH INT(len_temp / 256)

						ELSE

							IF len_temp < 256
								* may not be a valid length
								REPLACE field_len WITH len_temp

							ELSE
								* entry not accepted
								keystroke = 0

							ENDIF
						ENDIF
					ENDIF

				CASE n = 4
					* get is for field_dec
					SetColor(M->color1)
					@ cur_row,field_col[n] GET field_dec
					READ
					SetColor(M->color7)
					keystroke = LASTKEY()

			ENDCASE

			* release keys and wipe that cursor off the screen
			SET KEY 5 TO
			SET KEY 24 TO
			xkey_norm()
			SET CURSOR OFF

			IF menu_key() <> 0
				* restore the item and forward the menu key
				REPLACE &field_id WITH m_item
				KEYBOARD CHR(keystroke)

			ENDIF

			IF m_item <> &field_id
				* something has been changed
				stru_ok = .F.		&& fieldspec may not be valid
				altered = .T.		&& structure is altered

				IF n > 1
					* can no longer change field names
					chg_name = .F.

				ENDIF
			ENDIF

			DO CASE

				CASE keystroke = 18 .OR. keystroke = 5
					* up arrow or PgUp...move up
					keystroke = 5

				CASE keystroke = 3 .OR. keystroke = 24
					* down arrow or PgDn...move down
					keystroke = 24

				CASE keystroke = 13 .OR.;
					 (isdata(keystroke) .AND. keystroke <> 32)
					* next field..space bar is used for revolving data types
					keystroke = 4

				OTHERWISE
					* same field
					keystroke = 0

			ENDCASE

			* de-hilite the current item 
			stru_item()

		CASE keystroke = 5 .AND. RECNO() > 1
			* up arrow

			IF is_append
				* test newly appended field

				IF .NOT. stru_ck(.F.)
					* delete newly appended field if exit up
					no_append()

				ENDIF
			ENDIF

			IF stru_ck(.T.)
				* move up one field
				SKIP -1

				IF cur_row = 13
					* scroll required
					scroll(13, 21, 22, 58, -1)

					* fill the blank row
					stru_row(13)

				ELSE
					cur_row = cur_row - 1

				ENDIF

				is_append = .F.
				is_insert = .F.

			ELSE
				* fieldspec no good
				n = i

			ENDIF

			keystroke = 0

		CASE keystroke = 24
			* down arrow

			IF stru_ck(RECNO() < LASTREC())
				* ok to move down one field
				SKIP

				IF EOF()
					* down arrow will append
					APPEND BLANK
					REPLACE field_type WITH "C",field_len WITH 10,;
							field_dec WITH 0
					is_append = .T.
					stru_ok = .F.
					n = 1

					IF cur_row < 22
						* show new field template
						@ cur_row + 1, field_col[1] SAY not_empty

					ENDIF

				ELSE
					is_insert = .F.

				ENDIF

				IF cur_row = 22
					* scroll required
					scroll(13, 21, 22, 58, 1)

					* fill the blank row
					stru_row(22)

				ELSE
					cur_row = cur_row + 1

				ENDIF

			ELSE
				* fieldspec no good
				n = i

			ENDIF

			keystroke = 0

		CASE keystroke = 4
			* right arrow

			IF n < l_usr[AT(field_type, "CNDLM")]
				n = n + 1

			ENDIF

			keystroke = 0

		CASE keystroke = 19
			* left arrow

			IF n > 1
				n = n - 1

			ENDIF

			keystroke = 0

		CASE keystroke = 18
			* PgUp
			keystroke = 0

			IF RECNO() = 1
				* avoid re-draw if top of file
				LOOP

			ENDIF

			IF is_append
				* test newly appended field

				IF .NOT. stru_ck(.F.)
					* delete newly appended field if exit up
					no_append()

				ENDIF
			ENDIF

			IF stru_ck(.T.)
				is_append = .F.
				is_insert = .F.

				IF RECNO() = cur_row - 12
					* record 1 is on screen..no re-draw
					GO TOP
					cur_row = 13

				ELSE
					* skip one page up and re-draw
					SKIP -(9 + cur_row - 13)
					keystroke = 999

				ENDIF

			ELSE
				* fieldspec no good..no page up
				n = i

			ENDIF

		CASE keystroke = 3
			* PgDn
			keystroke = 0

			IF is_append
				* avoid error messages
				LOOP

			ENDIF

			IF stru_ck(.T.)
				is_insert = .F.

				IF LASTREC() - RECNO() <= 22 - cur_row
					* last field is on screen
					cur_row = cur_row + LASTREC() - RECNO()
					GO BOTTOM

				ELSE
					* skip one page down
					keystroke = 999			&& cause re-draw of window
					SKIP 9 - (cur_row - 13)

					IF EOF()
						* skip incomplete
						GO BOTTOM

					ENDIF
				ENDIF

			ELSE
				* fieldspec no good
				n = i

			ENDIF

		CASE keystroke = 31
			* ^PgUp..go to top of structure file
			keystroke = 0

			IF RECNO() = 1
				* top of file
				LOOP

			ENDIF

			IF is_append
				* test newly appended field

				IF .NOT. stru_ck(.F.)
					* delete newly appended field if exit up
					no_append()

				ENDIF
			ENDIF

			IF stru_ck(.T.)
				is_append = .F.
				is_insert = .F.

				IF RECNO() > cur_row - 12
					* record 1 is not on screen
					keystroke = 999

				ENDIF

				GO TOP
				cur_row = 13

			ELSE
				* fieldspec no good
				n = i

			ENDIF

		CASE keystroke = 30
			* ^PgDn
			keystroke = 0

			IF is_append
				* avoid error messages
				LOOP

			ENDIF

			IF stru_ck(.T.)
				is_insert = .F.

				IF LASTREC() - RECNO() <= 22 - cur_row
					* last field is on screen
					cur_row = cur_row + LASTREC() - RECNO()
					GO BOTTOM

				ELSE
					* re-draw window with lastrec on last row
					keystroke = 999
					GO BOTTOM
					SKIP -9
					cur_row = 22

				ENDIF

			ELSE
				* fieldspec no good
				n = i

			ENDIF

		CASE keystroke = 6 .OR. keystroke = 23
			* end or ^end
			keystroke = 0
			n = l_usr[AT(field_type, "CNDLM")]

		CASE keystroke = 1 .OR. keystroke = 29
			* home or ^home
			keystroke = 0
			n = 1

		CASE keystroke = 22
			* insert a new field before cursor

			IF stru_ck(.T.)
				n = 1					&& cursor on field name
				stru_ok = .F.			&& fieldspec not valid
				is_append = .F.			&& not append
				is_insert = .T.			&& new field inserted
				rec1 = RECNO()			&& remember which field

				* insert blank not available..do it the hard way
				APPEND BLANK

				DO WHILE rec1 < RECNO()
					* shift up for insert
					SKIP -1

					* get previous fieldspec
					f_name = field_name
					f_type = field_type
					f_len = field_len
					f_dec = field_dec

					* put into current fieldspec
					SKIP
					REPLACE field_name WITH f_name,field_type WITH f_type,;
							field_len WITH f_len,field_dec WITH f_dec

					* next
					SKIP -1

				ENDDO

				* make current fieldspec look like new
				REPLACE field_name WITH SPACE(10),field_type WITH "C",;
						field_len WITH 10,field_dec WITH 0

				IF cur_row < 22
					* scroll down for insert
					scroll((cur_row), 21, 22, 58, -1)

				ENDIF

				* newly added field looks like this
				@ cur_row,field_col[1] SAY not_empty

			ELSE
				* fieldspec no good
				n = i

			ENDIF

			keystroke = 0

		CASE keystroke = 7 .AND. LASTREC() > 1
			* delete..only the current record can be invalid
			rec1 = RECNO()
			DELETE
			PACK

			IF rec1 > LASTREC()
				* last record has been deleted
				GO BOTTOM

				IF cur_row = 13
					* top of window
					stru_row(13)

				ELSE
					@ cur_row,field_col[1] SAY empty_row
					cur_row = cur_row - 1

				ENDIF

			ELSE

				IF cur_row < 22
					* scroll bottom part of window up
					scroll((cur_row), 21, 22, 58, 1)

				ENDIF

				* go to last field on screen
				GOTO rec1
				SKIP 22 - cur_row

				IF .NOT. EOF()
					* fill bottom row
					stru_row(22)

				ELSE
					* put blank template on last row
					@ 22,field_col[1] SAY empty_row

				ENDIF

				* move pointer to current record
				GOTO rec1

				* same recno, but not the same record
				prev_rec = 0

			ENDIF

			IF .NOT. is_append .AND. .NOT. is_insert
				* structure is altered..cannot change names
				altered = .T.
				chg_name = .F.

			ENDIF

			* re-set tracking variables
			is_append = .F.				&& append is off
			is_insert = .F.				&& insert is off
			stru_ok = .T.				&& only current record can be invalid
			keystroke = 0

		CASE prev_rec <> RECNO()
			* record pointer has been moved and all cascading
			*	 keystrokes have been processed
			prev_rec = RECNO()

			* update field/record number on screen
			@ 9,field_col[1] + 26 SAY "Field " + pad(LTRIM(STR(RECNO())), 5)

			IF n > l_usr[AT(field_type, "CNDLM")]
				* check for n out of range
				n = l_usr[AT(field_type, "CNDLM")]

			ENDIF

		CASE local_func = 4
			* "save structure" selected from pull down menu..keystroke = 0
			local_func = 0

			IF .NOT. stru_ck(.T.)
				* fieldspec no good
				n = i
				LOOP

			ENDIF

			is_append = .F.
			is_insert = .F.
			filename = stru_name

			IF filebox(".DBF", "dbf_list", "stru_title",;
					   "do_modstru", .T., 13) <> 0
				* structure created or altered
				stru_name = filename

				* re-write name at top of window
				@ 9,field_col[1] + 13;
				SAY pad(IF(EMPTY(stru_name), "<new file>",;
							SUBSTR(stru_name, RAT("\", stru_name) + 1)), 13)

				IF aseek(dbf, filename) = 0
					* bring new file into view
					cur_dbf = filename

					open_dbf(.F., .T.)

					* select system reserved work area
					SELECT 10

				ENDIF

				* exit to main View screen
				keystroke = 27	&& exit this routine
				cur_area = 0	&& re-draw View screen

			ENDIF

			* clear message from screen
			stat_msg("")

		CASE local_func = 1
			* "help" selected from pull down menu..keystroke = 0
			local_func = 0
			DO syshelp

		OTHERWISE
			* get new keystroke

			IF .NOT. key_ready()
				* hi-lite the current item as reverse
				SetColor(M->color2)
				stru_item()
				SetColor(M->color7)

				* wait for keystroke
				read_key()

				IF .NOT. (keystroke = 13 .OR. isdata(keystroke))
					* this is not a GET..re-write as normal
					stru_item()

				ENDIF
			ENDIF

			IF keystroke = 27 .AND. altered
				* warning

				IF rsvp("Ok To Lose Changes? (Y/N)") <> "Y"
					keystroke = 0

				ENDIF
			ENDIF
	ENDCASE
ENDDO create/modify structure

* close and erase structure file..all done
USE
ERASE ddbbuuuu.ext

* clear status line
stat_msg("")

* restore window
RESTSCREEN(8, 20, 23, 59, M->wstru_buff)

SetColor(saveColor)
RETURN


*******************
* local functions *
*******************

******
*	stru_row()
*
*	fill one row in structure window
******
FUNCTION stru_row

PARAMETERS fill_row

@ fill_row,field_col[1];
SAY field_name + " ณ " + data_type[AT(field_type, "CNDLM")] + " ณ "

IF field_type = "C"
	* display Clipper extended field length
	@ fill_row,field_col[3] SAY STR(((256 * field_dec) + field_len), 4) +;
								" ณ    "

ELSE
	* normal field length
	@ fill_row,field_col[3] SAY STR(field_len, 4) + " ณ    "

	IF field_type = "N"
		* display decimals for numeric field
		@ fill_row,field_col[4] SAY field_dec

	ENDIF
ENDIF

RETURN 0


******
*	stru_item()
*
*	display item in structure window
******
FUNCTION stru_item

DO CASE

	CASE n = 1
		* field_name
		@ cur_row,field_col[1] SAY field_name

	CASE n = 2
		* display field_type as character string
		@ cur_row,field_col[2] SAY data_type[AT(field_type, "CNDLM")]

	CASE n = 3

		IF field_type = "C"
			* display Clipper extended field length
			@ cur_row,field_col[n] SAY STR(((256 * field_dec) +;
										   field_len),4)

		ELSE
			* normal field_len
			@ cur_row,field_col[n] SAY STR(field_len,4)

		ENDIF

	CASE n = 4
		* field_dec
		@ cur_row,field_col[4] SAY field_dec

ENDCASE

RETURN 0


******
*	no_append()
*
*	eliminate newly appended field/record
******
FUNCTION no_append

DELETE
PACK
GO BOTTOM
SKIP

IF (RECNO() = cur_row - 12) .OR. keystroke = 5
	* blank the current row
	@ cur_row,field_col[1] SAY empty_row

ENDIF

stru_ok = .T.

RETURN 0


******
*	stru_ck()
*
*	test fieldspec if needed
******
FUNCTION stru_ck

PARAMETERS disp_err

IF .NOT. stru_ok
	* fieldspec needs testing
	i = field_check(disp_err)
	stru_ok = (i = 0)

ENDIF

RETURN stru_ok


******
*	field_check()
*
*	return number of invalid field aspect (field_name = 1, etc.), 0 if ok
******
FUNCTION field_check

PARAMETERS disp_err
PRIVATE pos,test_num,test_name,status,err_msg

* initialize local variables
status = 0
err_msg = ""

* test for valid field name
pos = LEN(TRIM(field_name))

IF pos = 0
	* blank
	status = 1
	err_msg = "Blank Field Name"

ENDIF

IF status = 0

	DO WHILE pos > 0 .AND. SUBSTR(field_name, pos, 1) $;
						   "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_"
		* validate all characters except trailing spaces
		pos = pos - 1

	ENDDO

	* the first character must be a letter
	IF pos > 0 .OR. SUBSTR(field_name, 1, 1) $ "0123456789_"
		* invalid character
		status = 1
		err_msg = "Illegal Field Name"

		IF keystroke = 24
			* force error display for illegal down arrow
			disp_err = .T.

		ENDIF
	ENDIF
ENDIF

IF status = 0
	* look for duplicate field name
	test_num = RECNO()
	test_name = field_name
	LOCATE FOR field_name = test_name .AND. RECNO() <> test_num

	IF FOUND()
		* duplicate field name
		status = 1
		err_msg = "Duplicate Field Name"

		IF keystroke = 24
			* force error display for illegal down arrow
			disp_err = .T.

		ENDIF
	ENDIF

	* re-set pointer to current record
	GOTO test_num

ENDIF

IF status = 0
	* test for valid field_len

	IF field_type = "C"
		test_num = (256 * field_dec) + field_len

		IF test_num <= 0 .OR. test_num > 1024
			* invalid field width
			status = 3
			err_msg = "Invalid Field Width"

			IF keystroke = 24
				* force error display for illegal down arrow
				disp_err = .T.

			ENDIF
		ENDIF

	ELSE

		IF field_len <= 0 .OR. field_len > 19
			* invalid field width
			status = 3
			err_msg = "Invalid Field Width"

			IF keystroke = 24
				* force error display for illegal down arrow
				disp_err = .T.

			ENDIF
		ENDIF
	ENDIF
ENDIF

IF field_type = "N" .AND. status = 0
	* test for valid field_dec

	IF field_dec > IF(field_len < 3, 0, IF(field_len > 17, 15, field_len - 2))
		* invalid decimal width
		status = 4
		err_msg = "Invalid Decimal Width"

		IF keystroke = 24
			* force error display for illegal down arrow
			disp_err = .T.

		ENDIF
	ENDIF
ENDIF

IF status > 0 .AND. disp_err
	* something not right that ought to be shown
	error_msg(err_msg)

ENDIF

RETURN status


*********************************
* functions called from filebox *
*********************************

******
*	stru_title()
*
*	display title for save structure filebox
******
FUNCTION stru_title

PARAMETERS sysparam

RETURN box_title(M->sysparam, "Save structure as...")


******
*	do_modstru()
*
*	create/modify structure
******
FUNCTION do_modstru

LOCAL cAlias
PRIVATE stru_done, i, is_open, new_name, name_temp, add_name,;
		dbt_spec, dbt_temp, rec1

DO CASE

	CASE EMPTY(filename)
		error_msg("File name not entered")
		stru_done = .F.

	OTHERWISE
		* determine if structure to be created is currently open
		i = aseek(dbf, filename)
		is_open = (i > 0)

		IF FILE(filename) .AND. .NOT. (filename == cur_dbf)
			* file exists and is not the current data file being modified

			IF rsvp(filename + IF(is_open, " Is Currently Open",;
										   " Already Exists") +;
					"...Overwrite? (Y/N)") <> "Y"
				* oops
				RETURN .F.

			ENDIF
		ENDIF

		IF is_open
			* can't really modify an open file, but we make it look that way
			name_temp = "ntx" + SUBSTR("123456", i, 1)
			need_ntx = need_ntx .OR. .NOT. EMPTY(&name_temp[1])

			* temporarily disable any relations targeted at the open file
			not_target(i, .F.)

			* close the file
			SELECT (M->i)
			USE

			name_temp = "kf" + SUBSTR("123456", i, 1)

			IF .NOT. EMPTY(&name_temp)
				* will need to re-set the filter for the open file
				need_filtr = .T.

			ENDIF

			* select system reserved work area
			SELECT 10

		ENDIF

		* remember the current field number and close structure file
		rec1 = RECNO()
		USE

		* remember if file existed in current directory before
		add_name = .NOT. FILE(name(filename) + ".DBF")

		IF FILE(filename)
			* file exists..modify structure and save old data
			new_name = " "

			IF chg_name .AND. altered
				* rsvp change of field names
				new_name = rsvp("Change Field Name(s)? (Y/N)")

				IF .NOT. new_name $ "YN"
					* Escape key will cancel the operation
					USE ddbbuuuu.ext
					GOTO rec1
					RETURN .F.

				ENDIF
			ENDIF

			* establish temp filespec and dbt specs in same directory
			name_temp = SUBSTR(filename, 1, RAT("\", filename)) +;
						"DDBBUUUU.TMP"
			dbt_spec = SUBSTR(filename, 1, RAT(".", filename)) +;
					   "DBT"
			dbt_temp = SUBSTR(name_temp, 1, RAT(".", name_temp)) +;
					   "DBT"

			IF FILE(dbt_spec)
				* data file contains memo fields

				IF new_name = "Y"
					* field_name change will lose memos during SDF copy
					new_name = rsvp("Warning: Memos Will Be Lost" +;
									"...Proceed? (Y/N)")

					IF new_name <> "Y"
						* abort operation
						USE ddbbuuuu.ext
						GOTO rec1
						RETURN .F.

					ENDIF
				ENDIF

				* every dbt has its dbf
				RENAME &dbt_spec TO &dbt_temp

			ENDIF

			stat_msg(IF(new_name <> "Y", "Altering file structure",;
						"Changing field name(s)"))

			* save the old and create the new
			RENAME &filename TO &name_temp
         cAlias := MakeAlias( filename )
         CREATE &filename FROM ddbbuuuu.ext ALIAS cAlias

			IF new_name = "Y"
				* change field names by copying SDF
				USE &name_temp
				COPY TO ddbbuuuu.txt SDF
				USE &filename
				APPEND FROM ddbbuuuu.txt SDF
				ERASE ddbbuuuu.txt

			ELSE
				* normal modify structure
				APPEND FROM &name_temp

			ENDIF

			IF FILE(name_temp)
				* delete temp file
				ERASE &name_temp

			ENDIF

			IF FILE(dbt_temp)
				* delete temp dbt file
				ERASE &dbt_temp

			ENDIF

			IF is_open
				* re-establish file in its original select area
				USE					&& close in system reserved area
				SELECT (M->i)		&& select the correct area
				USE &filename		&& re-open the file

				* establish new field list for new structure
				name_temp = "field_n" + SUBSTR("123456", M->i, 1)
				all_fields(M->i, &name_temp)

				* re-select system reserved area
				SELECT 10

			ENDIF

		ELSE
			* create new file
			stat_msg("Creating new data file")
         cAlias := MakeAlias( filename )
         CREATE &filename FROM ddbbuuuu.ext ALIAS cAlias
			USE

			IF AT(".DBF", filename) = LEN(filename) - 3 .AND.;
			   FILE(name(filename) + ".DBF") .AND. add_name
				* add only .dbf files in the current directory
				i = afull(dbf_list) + 1

				IF i <= LEN(dbf_list)
					* add new file name to list
					dbf_list[i] = filename
					array_sort(dbf_list)

				ENDIF
			ENDIF
		ENDIF

		* close newly created or modified file
		USE
		stru_done = .T.

ENDCASE

RETURN stru_done


* EOF DBUSTRU.PRG
