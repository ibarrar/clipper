/***
*
*  Dbucopy.prg
*
*  DBU Copy and Append Module
*
*  Copyright (c) 1990-1993, Computer Associates International, Inc.
*  All rights reserved.
*
*/


******
*	capprep
*
*	copy/append/replace
*
*	note: see multibox in DBUUTIL.PRG
******
PROCEDURE capprep

PRIVATE filename, files, fi_disp, okee_dokee, cur_el, rel_row, def_ext, mode,;
		fi_done, for_cond, while_cond, how_many, bcur, for_row, height,;
		field_mvar, with_what

IF M->func_sel = 3
	* replace command
	help_code = 22

	* select current work area
	SELECT (M->cur_area)

	* initialize variables to contain fieldname and replace expression
	field_mvar = ""
	with_what = ""

	* get master field list into local array for selection
	DECLARE field_m[FCOUNT()]
	all_fields(M->cur_area, M->field_m)

	* set up for multi-box
	DECLARE boxarray[9]
	boxarray[1] = "repl_title(sysparam)"
	boxarray[2] = "repl_field(sysparam)"
	boxarray[3] = "with_exp(sysparam)"
	boxarray[4] = "for_exp(sysparam)"
	boxarray[5] = "while_exp(sysparam)"
	boxarray[6] = "scope_num(sysparam)"
	boxarray[7] = "ok_button(sysparam)"
	boxarray[8] = "can_button(sysparam)"
	boxarray[9] = "fieldlist(sysparam)"

	* size and configuration
	bcur = 9			&& beginning cursor on field list
	for_row = 6
	height = 10
	okee_dokee = "do_replace()"
	fi_disp = "repl_field(3)"

ELSE
	* initialize filename variable
	filename = ""

	* only copy and append use a list of text files
	DECLARE txt_list[adir("*.TXT") + 20]		&& directory of text files
	array_dir("*.TXT",txt_list)					&& fill array with filenames

	* set up for multi-box
	DECLARE boxarray[10]

	IF M->func_sel = 1
		* copy command
		help_code = 12
		bcur = 2			&& beginning cursor on filename entry field
		boxarray[1] = "copy_title(sysparam)"
		boxarray[2] = "trg_getfil(sysparam)"
		fi_disp = "trg_getfil(3)"
		okee_dokee = "do_copy()"

	ELSE
		* append command
		help_code = 15
		bcur = 10			&& beginning cursor on selection list
		boxarray[1] = "appe_title(sysparam)"
		boxarray[2] = "src_getfil(sysparam)"
		fi_disp = "src_getfil(3)"
		okee_dokee = "do_append()"

	ENDIF

	* remainder of setup common to copy and append
	boxarray[3] = "for_exp(sysparam)"
	boxarray[4] = "while_exp(sysparam)"
	boxarray[5] = "scope_num(sysparam)"
	boxarray[6] = "tog_sdf(sysparam)"
	boxarray[7] = "ok_button(sysparam)"
	boxarray[8] = "tog_delim(sysparam)"
	boxarray[9] = "can_button(sysparam)"
	boxarray[10] = "filelist(sysparam)"

	* size and configuration
	for_row = 5
	height = 11

	* DBF for normal mode
	files = "dbf_list"
	def_ext = ".DBF"

	* when is a filename acceptable?
	fi_done = "not_empty('filename')"

ENDIF

* initialize local variables
STORE "" TO for_cond, while_cond

* normal mode, scope = ALL, top of selection list
STORE 1 TO mode,cur_el
rel_row = 0
how_many = 0

* do it with the all-purpose switchbox
multibox(8, 17, M->height, M->bcur, M->boxarray)
RETURN


******************************
* functions specific to COPY *
******************************

******
*	copy_title()
*
*	display title for "copy"
******
FUNCTION copy_title

PARAMETERS sysparam

RETURN box_title(M->sysparam, "Copy " +;
							  SUBSTR(M->cur_dbf, RAT("\", M->cur_dbf) + 1) +;
							  " to...")


******
*	trg_getfil()
*
*	get target filename for "copy"
******
FUNCTION trg_getfil

PARAMETERS sysparam

help_code = M->prime_help
RETURN getfile(M->sysparam, 3)


******
*	do_copy()
*
*	do the copy command
*
*	note: this function is called when <enter> is pressed
*		  while the cursor is on the "Ok" button
******
FUNCTION do_copy

PRIVATE done, add_name, new_el

* assume incomplete
done = .F.

DO CASE

	CASE EMPTY(M->filename)
		error_msg("Target not selected")

	CASE M->filename == M->cur_dbf
		error_msg("File cannot be coppied onto itself")

	CASE .NOT. EMPTY(M->for_cond) .AND. TYPE(M->for_cond) <> "L"
		error_msg("FOR condition must be a Logical expression")

	CASE .NOT. EMPTY(M->while_cond) .AND. TYPE(M->while_cond) <> "L"
		error_msg("WHILE condition must be a Logical expression")

	OTHERWISE
		* ok to copy file

		IF FILE(M->filename)

			IF rsvp("Target File " + IF(aseek(M->dbf, M->filename) > 0,;
					"Is Open", "Exists") + "...Overwrite? (Y/N)") <> "Y"
				RETURN .F.

			ENDIF
		ENDIF

		stat_msg("Copying")

		IF aseek(M->dbf, M->filename) > 0
			* copying to an open file...good luck!
			SELECT (aseek(M->dbf, M->filename))
			USE
			STORE .T. TO need_field,need_ntx,need_relat,need_filtr

		ENDIF

		SELECT (M->cur_area)

		IF RAT(M->def_ext, M->filename) = LEN(M->filename) - 3
			* target has default extension..does it exists in current dir?
			add_name = .NOT. FILE(name(M->filename) + M->def_ext)

		ELSE
			add_name = .F.

		ENDIF

		IF EMPTY(M->for_cond)
			* literal true is the same as no FOR condition
			for_cond = ".T."

		ENDIF

		IF EMPTY(M->while_cond)
			* literal true is correct only from top of file
			while_cond = ".T."

			IF M->how_many = 0
				* unless a scope has been entered
				GO TOP

			ENDIF
		ENDIF

		DO CASE

			CASE M->mode = 1 .AND. M->how_many = 0
				COPY TO &filename WHILE &while_cond FOR &for_cond

			CASE M->mode = 1 .AND. M->how_many > 0
				COPY TO &filename NEXT M->how_many WHILE &while_cond;
						FOR &for_cond

			CASE M->mode = 2 .AND. M->how_many = 0
				COPY TO &filename WHILE &while_cond FOR &for_cond;
						SDF

			CASE M->mode = 2 .AND. M->how_many > 0
				COPY TO &filename NEXT M->how_many WHILE &while_cond;
						FOR &for_cond SDF

			CASE M->mode = 3 .AND. M->how_many = 0
				COPY TO &filename WHILE &while_cond FOR &for_cond;
						DELIMITED

			CASE M->mode = 3 .AND. M->how_many > 0
				COPY TO &filename NEXT M->how_many WHILE &while_cond;
						FOR &for_cond DELIMITED

		ENDCASE

		IF aseek(M->dbf, M->filename) > 0
			* copying to an open file...good luck again!
			SELECT (aseek(M->dbf, M->filename))
			USE &filename

		ENDIF

		IF FILE(name(M->filename) + M->def_ext) .AND. M->add_name
			* add only .dbf files in the current directory
			new_el = afull(&files) + 1

			IF M->new_el <= LEN(&files)
				&files[M->new_el] = M->filename
				array_sort(&files)

			ENDIF
		ENDIF

		stat_msg("File copied")
		done = .T.

ENDCASE

RETURN M->done


********************************
* functions specific to APPEND *
********************************

******
*	appe_title()
*
*	display title for "append"
******
FUNCTION appe_title

PARAMETERS sysparam

RETURN box_title(M->sysparam, "Append to " +;
							  SUBSTR(M->cur_dbf, RAT("\", M->cur_dbf) + 1) +;
							  " from")


******
*	src_getfil()
*
*	get source filename for "append"
******
FUNCTION src_getfil

PARAMETERS sysparam

help_code = M->prime_help
RETURN getfile(M->sysparam, 3)


******
*	do_append()
*
*	do the append command
*
*	note: this function is called when <enter> is pressed
*		  while the cursor is on the "Ok" button
******
FUNCTION do_append

PRIVATE done

* assume incomplete
done = .F.

DO CASE

	CASE EMPTY(M->filename)
		error_msg("Source not selected")

	CASE M->filename == M->cur_dbf
		error_msg("File cannot be appended from itself")

	CASE .NOT. FILE(M->filename)
		error_msg("Can't open " + M->filename)

	CASE .NOT. EMPTY(M->for_cond) .AND. TYPE(M->for_cond) <> "L"
		error_msg("FOR condition must be a Logical expression")

	CASE .NOT. EMPTY(M->while_cond) .AND. TYPE(M->while_cond) <> "L"
		error_msg("WHILE condition must be a Logical expression")

	OTHERWISE
		* ok to append

		IF aseek(M->dbf, M->filename) > 0
			* appending from an open file
			SELECT (aseek(M->dbf, M->filename))
			USE
			STORE .T. TO need_field,need_ntx,need_relat,need_filtr

		ENDIF

		stat_msg("Appending")
		SELECT (M->cur_area)

		IF EMPTY(M->for_cond)
			* literal true is the same as no FOR condition
			for_cond = ".T."

		ENDIF

		IF EMPTY(M->while_cond)
			* literal true is the same as no WHILE condition
			while_cond = ".T."

		ENDIF

		DO CASE

			CASE M->mode = 1 .AND. M->how_many = 0
				APPEND FROM &filename WHILE &while_cond FOR;
							&for_cond

			CASE M->mode = 1 .AND. M->how_many > 0
				APPEND FROM &filename NEXT M->how_many WHILE;
							&while_cond FOR &for_cond

			CASE M->mode = 2 .AND. M->how_many = 0
				APPEND FROM &filename WHILE &while_cond FOR;
							&for_cond SDF

			CASE M->mode = 2 .AND. M->how_many > 0
				APPEND FROM &filename NEXT M->how_many WHILE;
							&while_cond FOR &for_cond SDF

			CASE M->mode = 3 .AND. M->how_many = 0
				APPEND FROM &filename WHILE &while_cond FOR;
							&for_cond DELIMITED

			CASE M->mode = 3 .AND. M->how_many > 0
				APPEND FROM &filename NEXT M->how_many WHILE;
							&while_cond FOR &for_cond DELIMITED

		ENDCASE

		IF aseek(M->dbf, M->filename) > 0
			* appending from an open file
			SELECT (aseek(M->dbf, M->filename))
			USE &filename

		ENDIF

		stat_msg("Append completed")
		done = .T.

ENDCASE

RETURN M->done


*********************************
* functions specific to REPLACE *
*********************************

******
*	repl_title()
*
*	display title for "replace"
******
FUNCTION repl_title

PARAMETERS sysparam

RETURN box_title(M->sysparam, "Replace in " +;
							  SUBSTR(M->cur_dbf, RAT("\", M->cur_dbf) + 1) +;
							  "...")


******
*	repl_field()
*
*	get fieldname for replace (only one field can be replaced at a time)
******
FUNCTION repl_field

PARAMETERS sysparam

help_code = M->prime_help
RETURN genfield(M->sysparam, .T.)


******
*	with_exp()
*
*	get "with" expression for replace
******
FUNCTION with_exp

PARAMETERS sysparam
PRIVATE rval

help_code = M->prime_help
rval = get_exp(M->sysparam, "WITH   ", 4, "with_what")

IF M->sysparam = 4 .AND. LASTKEY() = 13 .AND. .NOT. EMPTY(M->with_what)
	* expression just entered..dehilite and jump to 'Ok'
	get_exp(3, "WITH   ", 4, "with_what")
	to_ok()

ENDIF

RETURN M->rval


******
*	do_replace()
*
*	do the replace command
*
*	note: this function is called when <enter> is pressed
*		  while the cursor is on the "Ok" button
******
FUNCTION do_replace

PRIVATE done

* assume incomplete
done = .F.

DO CASE

	CASE EMPTY(M->field_mvar)
		error_msg("Field not selected")

	CASE EMPTY(M->with_what)
		error_msg("Replace expression not entered")

	CASE TYPE(M->with_what) <> TYPE(M->field_mvar) .and. ;
		!(TYPE(M->field_mvar) == "M") .and. ;
		!(TYPE(M->with_what) == "UI")
		error_msg("Type mismatch between replace expression and field")

	CASE .NOT. EMPTY(M->for_cond) .AND. TYPE(M->for_cond) <> "L"
		error_msg("FOR condition must be a Logical expression")

	CASE .NOT. EMPTY(M->while_cond) .AND. TYPE(M->while_cond) <> "L"
		error_msg("WHILE condition must be a Logical expression")

	OTHERWISE
		* ok to replace
		stat_msg("Replacing data")

		IF EMPTY(M->for_cond)
			* literal true is the same as no FOR condition
			for_cond = ".T."

		ENDIF

		IF EMPTY(M->while_cond)
			* literal true is the same as no WHILE condition
			while_cond = ".T."

			IF M->how_many = 0
				* unless a scope has been entered
				GO TOP

			ENDIF
		ENDIF

    IF !FLOCK()
        stat_msg("                 ")
        error_msg("Record update failed")
        done := .F.
    ELSE

        IF M->how_many = 0
            REPLACE &field_mvar WITH &with_what;
                WHILE &while_cond FOR &for_cond
        ELSE
            REPLACE NEXT M->how_many &field_mvar WITH &with_what;
                WHILE &while_cond FOR &for_cond
        ENDIF
        stat_msg("Replace completed")
        done = .T.

    ENDIF
    UNLOCK

ENDCASE

RETURN M->done


*************************************************
* functions common to COPY, APPEND, and REPLACE *
*************************************************

******
*	for_exp()
*
*	get "for" expression
******
FUNCTION for_exp

PARAMETERS sysparam

help_code = 16
RETURN get_exp(M->sysparam, "FOR    ", M->for_row, "for_cond")


******
*	while_exp()
*
*	get "while" expression
******
FUNCTION while_exp

PARAMETERS sysparam

help_code = 16
RETURN get_exp(M->sysparam, "WHILE  ", M->for_row + 1, "while_cond")


******
*	scope_num()
*
*	get scope
******
FUNCTION scope_num

PARAMETERS sysparam
local saveColor
PRIVATE old_scope

help_code = 17
saveColor := SetColor(M->colorNorm)

DO CASE

	CASE M->sysparam = 1 .OR. M->sysparam = 3
		* normal display
		@ M->wt + M->for_row + 2, M->wl + 2;
		SAY "SCOPE  " + pad(IF(M->how_many = 0, "ALL",;
							"NEXT " + LTRIM(STR(M->how_many))), 20)

		IF M->sysparam = 1
			* report position
			@ M->wt + M->for_row + 2, M->wl + 9 SAY ""

		ENDIF

	CASE M->sysparam = 2
		* hi-lite
		SetColor(M->colorHilite)
		@ M->wt + M->for_row + 2, M->wl + 9;
		SAY pad(IF(M->how_many = 0,;
				   "ALL", "NEXT " + LTRIM(STR(M->how_many))), 20)

	CASE M->sysparam = 4
		* selected

		IF CHR(M->keystroke) $ "0123456789" + CHR(13)
			* numeric digit or <enter>

			IF M->keystroke <> 13
				* include initial digit in entry
				KEYBOARD CHR(M->keystroke)

			ENDIF

			old_scope = M->how_many		&& in case of abort

			* set certain keys to exit the READ
			SET KEY 5 TO clear_gets
			SET KEY 24 TO clear_gets
			xkey_clear()

			* image is important
			SetColor(M->colorHilite)
			@ M->wt + M->for_row + 2, M->wl + 9 SAY pad("NEXT",20)

			SetColor(M->colorNorm)
			@ M->wt + M->for_row + 2, M->wl + 14;
			GET M->how_many PICTURE "99999999"

			SET CURSOR ON
			READ
			SET CURSOR OFF

			* remember the exit key
			keystroke = LASTKEY()

			* restore keys to normal
			SET KEY 5 TO
			SET KEY 24 TO
			xkey_norm()

			IF M->keystroke = 13
				* jump to "Ok" button
				to_ok()
				@ M->wt + M->for_row + 2, M->wl + 9;
				SAY pad(IF(M->how_many = 0, "ALL", "NEXT " +;
						LTRIM(STR(M->how_many))), 20)

			ELSE

				IF menu_key() <> 0
					* menu request
					how_many = M->old_scope

				ENDIF

				IF M->keystroke <> 27 .AND. .NOT. isdata(M->keystroke)
					* forward the request
					KEYBOARD CHR(M->keystroke)

				ENDIF
			ENDIF

		ELSE
			* character key..scope = 0 = ALL
			how_many = 0

		ENDIF
ENDCASE

SetColor(saveColor)
RETURN 2


***************************************
* functions common to COPY and APPEND *
***************************************

******
*	tog_sdf()
*
*	toggle sdf mode
******
FUNCTION tog_sdf

PARAMETERS sysparam
local saveColor

help_code = 11
saveColor := SetColor(M->colorNorm)

DO CASE

	CASE M->sysparam = 1 .OR. M->sysparam = 3
		* normal display
		@ M->wt + 9, M->wl + 8 SAY " SDF "

		IF M->mode = 2
			* SDF is current mode
			@ M->wt + 8, M->wl + 7, M->wt + 10, M->wl + 13 BOX sframe

		ENDIF

		IF M->sysparam = 1
			* report position
			@ M->wt + 9, M->wl + 9 SAY ""

		ENDIF

	CASE M->sysparam = 2
		* hi-lite
		SetColor(M->colorHilite)
		@ M->wt + 9, M->wl + 8 SAY " SDF "

	CASE M->sysparam = 4 .AND. M->keystroke = 13
		* selected..no character keys accepted here

		IF M->mode = 2
			* SDF...toggle off
			@ M->wt + 8, M->wl + 7, M->wt + 10, M->wl + 13 BOX "        "
			mode = 1

			* change from .TXT to .DBF
			cur_el = 1
			rel_row = 0
			files = "dbf_list"
			def_ext = ".DBF"
			filelist(1)			&& display new list

		ELSE
			* toggle SDF on

			IF M->mode = 3
				* toggle DELIMITED off
				@ M->wt + 8, M->wl + 16, M->wt + 10, M->wl + 28 BOX "        "

			ELSE
				* normal mode..change from .DBF to .TXT
				cur_el = 1
				rel_row = 0
				files = "txt_list"
				def_ext = ".TXT"
				filelist(1)		&& display new list

			ENDIF

			* indicate SDF on
			@ M->wt + 8, M->wl + 7, M->wt + 10, M->wl + 13 BOX sframe
			mode = 2

		ENDIF
ENDCASE

SetColor(saveColor)
RETURN 2


******
*	tog_delim
*
*	toggle delimited mode
******
FUNCTION tog_delim

PARAMETERS sysparam
local saveColor

help_code = 11
saveColor := SetColor(M->colorNorm)
DO CASE

	CASE M->sysparam = 1 .OR. M->sysparam = 3
		* normal display
		@ M->wt + 9, M->wl + 17 SAY " DELIMITED "

		IF M->mode = 3
			* DELIMITED is current mode
			@ M->wt + 8, M->wl + 16, M->wt + 10, M->wl + 28 BOX sframe

		ENDIF

		IF M->sysparam = 1
			* report position
			@ M->wt + 9, M->wl + 17 SAY ""

		ENDIF

	CASE M->sysparam = 2
		* hi-lite
		SetColor(M->colorHilite)
		@ M->wt + 9, M->wl + 17 SAY " DELIMITED "

	CASE M->sysparam = 4 .AND. M->keystroke = 13
		* selected..no character keys accepted here

		IF M->mode = 3
			* DELIMITED...toggle off
			@ M->wt + 8, M->wl + 16, M->wt + 10, M->wl + 28 BOX "        "
			mode = 1

			* change from .TXT to .DBF
			cur_el = 1
			rel_row = 0
			files = "dbf_list"
			def_ext = ".DBF"
			filelist(1)			&& display new list

		ELSE
			* toggle DELIMITED on

			IF M->mode = 2
				* toggle SDF off
				@ M->wt + 8, M->wl + 7, M->wt + 10, M->wl + 13 BOX "        "

			ELSE
				* normal mode..change from .DBF to .TXT
				cur_el = 1
				rel_row = 0
				files = "txt_list"
				def_ext = ".TXT"
				filelist(1)		&& display new list

			ENDIF

			* indicate DELIMITED on
			@ M->wt + 8, M->wl + 16, M->wt + 10, M->wl + 28 BOX sframe
			mode = 3

		ENDIF
ENDCASE

SetColor(saveColor)
RETURN 2


* EOF DBUCOPY.PRG
