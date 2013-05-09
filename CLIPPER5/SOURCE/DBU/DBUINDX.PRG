/***
*
*  Dbuindx.prg
*
*  DBU Index Read/Write Module
*
*  Copyright (c) 1990-1993, Computer Associates International, Inc.
*  All rights reserved.
*
*/


******
*	make_ntx
*
*	create index file
*
*	note: see multibox in DBUUTIL.PRG
******
PROCEDURE make_ntx
local saveColor
PRIVATE filename, files, fi_disp, okee_dokee, cur_el, rel_row, def_ext,;
		bcur, fi_done, el, cr, ntx, k_exp

* set local variables to macro reference specific arrays
cr = "_cr" + SUBSTR("123456", M->cur_area, 1)
el = "_el" + SUBSTR("123456", M->cur_area, 1)
ntx = "ntx" + SUBSTR("123456", M->cur_area, 1)

* get name of current index file
filename = &ntx[&el[2]]

* hi-lite the current index file..even if empty
saveColor := SetColor(M->color2)
@ &cr[2], column[M->cur_area] + 2 SAY pad(name(M->filename), 8)

* temporarily disable any relations and filters that may be active
SELECT (M->cur_area)
SET FILTER TO
CLOSE INDEX
need_filtr = .T.
need_ntx = .T.
not_target(SELECT(), .F.)
SELECT (M->cur_area)

* initialize variables for multibox sub-system
cur_el = 1
rel_row = 0
files = "ntx_list"
def_ext = INDEXEXT()

IF .NOT. EMPTY(M->filename)
	* set up for quick re-index
	k_exp = ntx_key(M->filename)
	bcur = 4

ELSE
	* assume new file to be created
	k_exp = ""
	bcur = 2

ENDIF

* establish array of functions for multi-box
DECLARE boxarray[6]

boxarray[1] = "ntx_title(sysparam)"
boxarray[2] = "ntx_getfil(sysparam)"
boxarray[3] = "ntx_exp(sysparam)"
boxarray[4] = "ok_button(sysparam)"
boxarray[5] = "can_button(sysparam)"
boxarray[6] = "filelist(sysparam)"

* define certain sub-processes
fi_disp = "ntx_exist()"
fi_done = "ntx_done()"
okee_dokee = "do_index()"

IF multibox(13, 17, 9, M->bcur, M->boxarray) <> 0 .AND.;
   aseek(&ntx, M->filename) = 0
	* index file generated and not open

	IF M->n_files < 14 .OR. .NOT. EMPTY(&ntx[&el[2]])
		* room for one more..bring index file into View

		IF EMPTY(&ntx[&el[2]])
			* keep track of number of open files
			n_files = M->n_files + 1

		ENDIF

		* place in global array
		&ntx[&el[2]] = M->filename

	ENDIF
ENDIF

* re-write index filename as normal
saveColor := SetColor(M->color1)
@ &cr[2], column[M->cur_area] + 2 SAY pad(name(&ntx[&el[2]]), 8)

SetColor(saveColor)
RETURN


*******************************
* support functions for INDEX *
*******************************

******
*	ntx_title()
*
*	display title for "index"
******
FUNCTION ntx_title

PARAMETERS sysparam

RETURN box_title(M->sysparam, "Index " +;
							  SUBSTR(M->cur_dbf, RAT("\", M->cur_dbf) + 1) +;
							  " to...")


******
*	ntx_getfil()
*
*	get target filename for "index"
******
FUNCTION ntx_getfil

PARAMETERS sysparam

RETURN getfile(M->sysparam, 4)


******
*	ntx_done()
*
*	preliminary test of filename typed into entry field
******
FUNCTION ntx_done

PRIVATE done_ok

done_ok = .NOT. EMPTY(M->filename)

IF M->done_ok
	* filename entered

	IF FILE(M->filename) .AND. EMPTY(M->k_exp)
		* read and display the key expression from the index file
		k_exp = ntx_key(M->filename)
		ntx_exp(3)

	ENDIF

	IF EMPTY(M->k_exp)
		* move cursor to expression field
		KEYBOARD CHR(24)

	ELSE
		* expression entered..move cursor to the "Ok" button
		to_ok()

	ENDIF
ENDIF

RETURN M->done_ok


******
*	ntx_exp()
*
*	get key expression for "index"
******
FUNCTION ntx_exp

PARAMETERS sysparam

RETURN get_exp(M->sysparam, "KEY    ", 6, "k_exp")


******
*	ntx_exist()
*
*	display filename selected from list and get key from file
******
FUNCTION ntx_exist

IF EMPTY(M->k_exp)
	* expression not entered..read it from the selected index file
	k_exp = ntx_key(M->filename)

ENDIF

* display the filename and key
ntx_getfil(3)
ntx_exp(3)

RETURN 0


******
*	do_index()
*
*	do the index command
*
*	note: this function is called when <enter> is pressed
*		  while the cursor is on the "Ok" button
******
FUNCTION do_index

PRIVATE done, n_dup, new_el, add_name

* get number of select area using this index if any
n_dup = dup_ntx(M->filename)

DO CASE

	CASE EMPTY(M->filename)
		error_msg("Index file not selected")
		done = .F.

	CASE M->n_dup > 0 .AND. M->n_dup <> SELECT()
		error_msg("Index in use by another data file")
		done = .F.

	CASE EMPTY(M->k_exp)
		error_msg("Index key not entered")
		done = .F.

	CASE .NOT. TYPE(M->k_exp) $ "CND"
		error_msg("Key expression not valid")
		done = .F.

	OTHERWISE
		* ok to generate index
		stat_msg("Generating index file")
		add_name = .NOT. FILE(name(M->filename) + INDEXEXT())
		INDEX ON &k_exp TO &filename
		CLOSE INDEX

		IF AT(INDEXEXT(), M->filename) = LEN(M->filename) - 3 .AND.;
		   FILE(name(M->filename) + INDEXEXT()) .AND. M->add_name
			* add only .ntx files in the current directory

			new_el = afull(M->ntx_list) + 1

			IF M->new_el <= LEN(M->ntx_list)
				* add file to array
				ntx_list[M->new_el] = M->filename
				array_sort(M->ntx_list)

			ENDIF
		ENDIF

		stat_msg("File indexed")
		done = .T.

ENDCASE

RETURN M->done


* EOF DBUINDX.PRG
