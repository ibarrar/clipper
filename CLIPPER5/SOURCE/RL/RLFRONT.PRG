/***
*  
*  Rlfront.prg
*
*  Front end for REPORT and LABEL FORM design program
*  
*  Copyright (c) 1987-1993, Computer Associates International, Inc.
*  All rights reserved.
*  
*  Note: Compile with /m /n
*
*/

// File-wide definitions
#include "inkey.ch"
#include "setcurs.ch"

// Event types
#define E_CANCEL        1       // Cancel, continue
#define E_NO            2       // Exit, no save
#define E_OK            3       // Exit, save


/***
*
*  Setup()
*
*  Save/Restore info when entering/exiting RL
*
*/
PROCEDURE Setup()

   LOCAL  cStartScr
   PUBLIC file_error, exit_status, my_update, no_save_flag, form_state

   file_error = 0                // File ok

   SET SCOREBOARD OFF            // Row 0 is being used
   SET WRAP ON
   SAVE SCREEN TO cStartScr      // Save beginning screen

   RlMain()                      // Edit reports and label definitions

   RESTORE SCREEN FROM cStartScr
   RETURN



/***
*
*  SayMsg( cMessage ) --> NIL
*
*  Display a message to the message line
*
*/
FUNCTION SayMsg( cMsg )
	LOCAL cLastColor := SETCOLOR("n/gr")
	@ 2,0 SAY cMsg 
	SETCOLOR( cLastColor )  
	RETURN NIL



/***
*
*    SignOn() --> NIL
*
*    Display the sign-on message and wait for a key
*
*/
FUNCTION SignOn( aMenu )
	LOCAL cLastColor, lLastCursor

	cLastColor = SETCOLOR("N/BG")
	@ 0, 0 SAY aMenu[ 1 ] 
	SETCOLOR( cLastColor )
	lLastCursor := SETCURSOR( SC_NONE )

	@ 0, 10 SAY aMenu[ 2 ]
	@ 0, 19 SAY aMenu[ 3 ]
   @ 1, 0  TO 1, MAXCOL()
   SayMsg( "RL - Copyright (c) 1986-1993, Computer Associates International, Inc." )

	CLEAR TYPEAHEAD
	nKey = INKEY(0)
	@ 2, 0
	KEYBOARD CHR( nKey )

	SETPOS( 0, 0 )
	SETCURSOR( lLastCursor )

	RETURN NIL



/***
*
*  RlMain()
*
*  main procedure
*
*     event types are:
*       1 = cancel, (continue)
*       2 = No,     (exit-no save)
*       3 = Ok,     (exit-w/ save)
*/
PROCEDURE RlMain
	LOCAL aMainMenu

	PRIVATE rl_opt1, rl_opt2, rl_quit
	PRIVATE rl_choice, execute, filename, open_name, file_box, event_type

	// item functions must be listed in ascending order...that
	// is, higher numbered items must be located at a higher
	// row number, a higher column number, or both.
	DECLARE file_box[5]

	// item functions used in this program
	file_box[1] = "enter_title(sysparam)"
	file_box[2] = "rl_getfil(sysparam)"
	file_box[3] = "ok_button(sysparam)"
	file_box[4] = "cancel_button(sysparam)"
	file_box[5] = "filelist(sysparam)"

	okee_dokee = "do_it()"
	execute = .T.
	aMainMenu := { " Report ", " Label ", " Quit " }

	SET COLOR TO BG+/B,N/BG,,,N/W
   CLEAR
   SignOn( aMainMenu )

	DO WHILE execute
		CLEAR

		event_type   = E_CANCEL         // loop
		filename     = SPACE(64)

		// Set flags
		my_update    = .F.
		no_save_flag = .F.

		// Display main menu
		@ 0, 0  PROMPT aMainMenu[ 1 ]
		@ 0, 10 PROMPT aMainMenu[ 2 ]
		@ 0, 19 PROMPT aMainMenu[ 3 ]
	  @ 1, 0  TO 1, MAXCOL()

		MENU TO rl_choice
		SET CURSOR OFF

		DO CASE
		CASE rl_choice == 3 .OR. rl_choice == 0

			// Exit
			execute = .F.

		CASE rl_choice == 1

			// Select REPORT FORM
			DECLARE files[adir("*.FRM") + 1]
			afill(files,"")
			adir("*.FRM", files)

			IF multibox(7, 17, 7, 5, file_box) = 0      // <esc> or cancel?
				LOOP
			ENDIF

		 // add an extension if none was found (.frm)
			open_name = EXT_ADD(filename, "R")  

		CASE rl_choice == 2

			// Select LABEL FORM
			DECLARE files[adir("*.LBL") + 1]
			afill(files,"")
			adir("*.LBL", files)

			IF multibox(7, 17, 7, 5, file_box) = 0      // <esc> or cancel?
				LOOP
			ENDIF

		 // Add an extension if none was found (.lbl)
			open_name = EXT_ADD(filename, "L")  

		ENDCASE

	IF EMPTY( filename )
		execute = .F.
	ENDIF

	IF execute

	  * report choice was selected from menu bar
		IF rl_choice == 1

			SET COLOR TO BG*+/B
			@ 2,0 SAY "Loading..."
			SET COLOR TO BG+/B,N/BG,,,N/W

			IF !FRM_LOAD(open_name, "FRM_FILE.DBF", "FRM_FILE.MEM")
				FRM_ERROR(open_name, file_error)
				EXIT
			ENDIF

			* proceed to editing the report
			DO WHILE (event_type == 1)

			* initital state of report screen (fields screen)
			form_state = 3

			* the edit routine
			IF FRM_EDIT(open_name, "FRM_FILE.DBF", "FRM_FILE.MEM")

				* get the event_type from selection box upon exit
				event_type = SYSTEM_EXIT()

					IF event_type == 2      // 'No' button was selected
						event_type = 0
					ENDIF

					IF event_type == 3      // 'Ok' button was selected
				  IF !FRM_SAVE(open_name, "FRM_FILE.DBF", "FRM_FILE.MEM")
					 FRM_ERROR(open_name, file_error)

					 * exit while loop, some error was found
					 event_type = 0
						ENDIF
					ENDIF

				ELSE

			   * no update (my_update) when editing, go home
					event_type = 0    

				ENDIF

			ENDDO

			* delete work files, always
			DELETE FILE frm_file.dbf
			DELETE FILE frm_file.mem

		ENDIF    // rl_choice = 1

	  * label choice was selected from menu bar
		IF rl_choice == 2    

			SET COLOR TO BG*+/B
			@ 2,10 SAY "Loading..."
			SET COLOR TO BG+/B
			IF !LBL_LOAD(open_name, "LBL_FILE.DBF", "LBL_FILE.MEM")
				LBL_ERROR(open_name, file_error)
				EXIT
			ENDIF

			*  edit the label file
			DO WHILE (event_type == 1)

				IF LBL_EDIT(open_name, "LBL_FILE.DBF", "LBL_FILE.MEM")

					event_type = SYSTEM_EXIT()

					IF event_type == 2      // 'No' button
						event_type = 0
					ENDIF

					IF event_type == 3
						IF !LBL_SAVE(open_name, "LBL_FILE.DBF", "LBL_FILE.MEM")
							LBL_ERROR(open_name, file_error)
							event_type = 0
						ENDIF
					ENDIF

				ELSE

			   * no update (my_update) when editing, go home
					event_type = 0

				ENDIF

			ENDDO

			* delete work files
			DELETE FILE lbl_file.dbf
			DELETE FILE lbl_file.mem

		ENDIF

	ENDIF

ENDDO

SET CURSOR ON
// end of RlMain (procedure)



***
* lbl_clear (function)
*
* clear gets for label system
***
PROCEDURE lbl_clear
PARAMETERS dummy1, dummy2, dummy3
CLEAR GETS
RETURN



***
* lbl_edit (function)
*
* edit a label file
***
FUNCTION LBL_EDIT
PARAMETERS label_file, label_dbf, label_mem

PRIVATE field_list, paint_only

exit_status = .F.

// get default .MEM file info
RESTORE FROM &label_mem ADDITIVE

// .DBF file info
SELECT 0
USE &label_dbf ALIAS label_dbf

DECLARE field_list[FCOUNT()]

FOR n = 1 TO FCOUNT()
	field_list[n] = FIELDNAME(n)
NEXT

// draw the screen once
LBL_SCR(label_file)

// cursor back on (multibox sets it off)
SET CURSOR ON

paint_only = .T.
DO WHILE !exit_status

	* set 'break-out' key, toggle switch
	SET KEY -1 TO lbl_clear    // (F2)

	* set label format key
	SET KEY -2 TO lab_setup

	* set F10 key to the exit procedure
	SET KEY -9 TO set_exit_flag

	@ 05,16 GET lbl_width  PICTURE "999"
	@ 06,16 GET lbl_height PICTURE "999" VALID LINE_CHK(lbl_height)
	@ 07,16 GET lbl_across PICTURE "999"

	@ 05,52 GET lbl_margin PICTURE "999"
	@ 06,52 GET lbl_lines  PICTURE "999"
	@ 07,52 GET lbl_spaces PICTURE "999"

	@ 09,16 GET lbl_remark

	IF !paint_only
		READ
	ENDIF

	my_update = my_update .OR. UPDATED()

	IF exit_status
		EXIT
   ENDIF

	* send the escape key to exit from dbedit the first time    
	IF paint_only
		CLEAR GETS
		KEYBOARD CHR(27)
		paint_only = .F.
	ENDIF

	* view/edit field expressions
	SET KEY -9 TO
   SET KEY 1  TO Home_key
   SET KEY 6  TO End_key
   SET KEY -1 TO

   SET CURSOR OFF
   @ 12,0 SAY "Line " + LTRIM(STR(RECNO())) + " อ"
   DBEDIT(11, 7, 23, 79, field_list, "LBL_ED")
   SET CURSOR ON

   SET KEY -9 TO set_exit_flag
   SET KEY 1  TO 
   SET KEY 6  TO 

ENDDO

CLOSE DATABASES

IF my_update .AND. !no_save_flag
	* save off to .mem file, if it was updated and 'No' was not selected
   SAVE ALL LIKE lbl_* TO &label_mem
ENDIF

// disable SET KEY's
SET KEY -1 TO
SET KEY -2 TO
SET KEY -9 TO

RETURN (my_update)
// end of lbl_edit (function)



PROCEDURE Home_key
KEYBOARD CHR(31)
RETURN



PROCEDURE End_key
KEYBOARD CHR(30)
RETURN   



***
*   lab_setup (procedure)
*
*   handle the various formats that dBASE supports
***
PROCEDURE lab_setup
PARAMETERS procName, dummy2, dummy3

PRIVATE double, more, type, type1, type2, type3, type4, type5

double = "ษอปบผอศบ"

SAVE SCREEN

@ 08,18,20,57 BOX ""    // space around window

// make window
@ 10,20,18,55 BOX double

// disable options
SET KEY -1 TO
SET KEY -2 TO
SET KEY 1  TO 
SET KEY 6  TO 

// no F10 here, ESC returns
SET KEY -9 TO

// various label types
type1 = "     3 1/2 x 15/16 by 1       "
type2 = "     3 1/2 x 15/16 by 2       "
type3 = "     3 1/2 x 15/16 by 3       "
type4 = "       4 x 17/16 by 1         "
type5 = "3 2/10 x 11/12 by 3 (Cheshire)"

more = .T.
DO WHILE more

	* selections
	@ 12,23 PROMPT type1
	@ 13,23 PROMPT type2
	@ 14,23 PROMPT type3
	@ 15,23 PROMPT type4
	@ 16,23 PROMPT type5

	MENU TO lab_choice

	* set up the strings, based on choice
	DO CASE
		CASE lab_choice = 0
			more = .F.
		CASE lab_choice = 1
			type = LTRIM(TRIM(type1)) + SPACE(60-18)
			more = stuff_label(35,5,0,1,0,1,type)
			UpdateHeight(5)
		CASE lab_choice = 2
			type = LTRIM(TRIM(type2)) + SPACE(60-18)
			more = stuff_label(35,5,0,1,2,2,type)
			UpdateHeight(5)
		CASE lab_choice = 3
			type = LTRIM(TRIM(type3)) + SPACE(60-18)
			more = stuff_label(35,5,0,1,2,3,type)
			UpdateHeight(5)
		CASE lab_choice = 4
			type = LTRIM(TRIM(type4)) + SPACE(60-14)
			more = stuff_label(40,8,0,1,0,1,type)
			UpdateHeight(8)
		CASE lab_choice = 5
			type = type5 + SPACE(60-30)
			more = stuff_label(32,5,0,1,2,3,type)
			UpdateHeight(5)
	ENDCASE

ENDDO

SET KEY 1  TO Home_key
SET KEY 6  TO End_key

CLEAR GETS

// break out of dbedit()
KEYBOARD CHR(27)

RESTORE SCREEN
RETURN
// end of lab_setup (procedure)



***
*   stuff_label (function)
*
*   stuff label variables with values from lbl_setup, return .F.
***
FUNCTION stuff_label
PARAMETERS one,two,three,four,five,six,seven

lbl_width  = one
lbl_height = two
lbl_margin = three
lbl_lines  = four
lbl_spaces = five
lbl_across = six
lbl_remark = seven

// generates an update
my_update = .T.

RETURN (.F.)
// end of stuff_label (function)



***
*   lbl_ed (function)
*
*   user defined function to be called from DBEDIT, used in LBL_EDIT
***
FUNCTION LBL_ED
PARAMETERS mode, i

PRIVATE cur_field

// get the name of the current field into a regular variable
cur_field = field_list[i]

DO CASE
CASE mode = 0
	* idle mode...
	@ 12,0 SAY "Line " + LTRIM(STR(RECNO())) + " อ"
	RETURN(1)

CASE mode = 1
	KEYBOARD CHR(30)
	RETURN 1

CASE mode = 2
  KEYBOARD CHR(31)
  RETURN 1

CASE mode < 4
  * case action can be implemented for each mode
  RETURN (1)

CASE LASTKEY() = -1                                   // F2
	SET CURSOR ON
	RETURN (0)

CASE LASTKEY() = 7
  * Del..delete current line.
  rec_num = RECNO()
  DELETE
  PACK
  APPEND BLANK

  GO REC_NUM
  my_update = .t.

  RETURN 2

CASE LASTKEY() = 27
	RETURN (0)

CASE LASTKEY() = 13 .OR. LASTKEY() > 32 .AND. LASTKEY() < 128
	* force key into GET field
	IF LASTKEY() != 13
		KEYBOARD CHR(LASTKEY())
  ENDIF

	* enter key..edit the current field
	* ..current row and col are correct
	@ ROW(), COL() GET &cur_field

	* set curson on and edit the expressions
	SET CURSOR ON
	SET KEY -9 TO set_exit_flag
	SET KEY 1 TO
	SET KEY 6 TO

	READEXIT(.T.)
	READ
	READEXIT(.F.)

	SET KEY -9 TO
	SET KEY 1 TO home_key
	SET KEY 6 TO end_key

	SET CURSOR OFF

	* set the update flag
	my_update = my_update .OR. UPDATED()
	IF LASTKEY() = 13
		KEYBOARD CHR(24)
	ENDIF

	* don't quit
	 RETURN(1)

CASE LASTKEY() = -9
	exit_status = .T.
	RETURN 0

OTHERWISE
	* don't quit
	RETURN 1

ENDCASE
// end of lbl_ed (function)



***
* lbl_scr (function)
*
* paint the label screen using SAY's
***
FUNCTION LBL_SCR
PARAMETERS label_file

CLEAR

@ 0,00 SAY "F1"
@ 0,09 SAY "F2"
@ 0,20 SAY "F3"
@ 0,70 SAY "F10"

@ 1,00 SAY "Help"
@ 1,09 SAY "Toggle"
@ 1,20 SAY "Formats"
@ 1,70 SAY "Exit"

@ 2,0 SAY REPLICATE(CHR(196),80)

// display the filename all the way to the right
@ 03,80-LEN("File " + label_file) SAY "File " + label_file

// display headers
@ 04,01 SAY "Dimensions"
@ 04,30 SAY "Formatting"

@ 05,06 SAY "Width   "
@ 06,06 SAY "Height  "
@ 07,06 SAY "Across  "
@ 05,36 SAY "Margin  "
@ 06,36 SAY "Lines   "
@ 07,36 SAY "Spaces  "
@ 09,06 SAY "Remarks "

RETURN ("")
// end of lbl_scr (function)



***
* 
* line_chk (function)
*
* Check the line_height variable.  Report error if not in range. Modify 
* database to accomodate new values, if any. Return Boolean valid_flag.
***
FUNCTION LINE_CHK
PARAMETERS height, file

PRIVATE lines, range_error, valid_flag, i

range_error = "(Valid range is between 1 and 16.)"
valid_flag  = .T.

SET CURSOR OFF

IF height > 16 .OR. height <= 0
		@ 24, CENTER(range_error,80) SAY range_error
		valid_flag = .F.

ELSEIF height != LASTREC()

		UpdateHeight(height)
	@ 24,0  // ok to clear line
END

SET CURSOR ON

RETURN (valid_flag)
// end of line_chk (function)



***
*
*    UpdateHeight(height, lines)
*       Delete added lines or expand to fill if lines are less than height.
*       Uses inherited privates vars.
*
*       8/13/89 CEW
*
PROCEDURE UpdateHeight

		PARAMETERS height

	* delete lineitems
	DELETE ALL FOR RECNO() > height
	PACK

		* add lineitems
		lines = RECCOUNT()
	IF height > lines
		DO WHILE lines < height
			APPEND BLANK
			SKIP
			lines = lines + 1
		ENDDO
		GO TOP  // reset
	ENDIF

RETURN



***
*  set_exit_flag (procedure)
*
*  sets the global exit_status flag to .T. upon exit (F10).
***
PROCEDURE set_exit_flag
CLEAR GETS
exit_status = .T.
RETURN
// end of set_exit_flag (procedure)



***
* system_exit (function)
*
* save changes to file ...?   Ok     - Save and exit
*                                 No     - Exit
*                                    Cancel - loop (continue)
****
FUNCTION system_exit
PARAMETERS dummy1, dummy2, dummy3

PRIVATE exit_box, continue

continue = 3    // save and exit

DECLARE exit_box[4]

exit_box[1] = "save_title(sysparam)"
exit_box[2] = "ok_button(sysparam)"
exit_box[3] = "no_button(sysparam)"
exit_box[4] = "can_button(sysparam)"

SET CURSOR OFF
IF multibox(7, 17, 7, 2, exit_box) = 0      // save changes? (Y,N,C)

	continue = 1         // cancel

	IF no_save_flag     // set inside multibox routine
		continue = 2
	ENDIF

ENDIF
SET CURSOR ON

RETURN (continue)
// end of system_exit (function)



****
* frm_edit (function)
*
* this routine calls 6 procedures, using SET KEY <n> TO ...
*
* F-key:                      (procedure name):
* F2 = pageheading screen     (form_layout)
* F3 = group/subgroup screen  (form_groups)
* F4 = default fields screen  (form_fields)
* F5 = delete                 (form_delete)
* F6 = insert                 (form_insert)
* F7 = goto field             (form_goto)
*
****
FUNCTION FRM_EDIT
PARAMETERS form_file, form_dbf, form_mem
PRIVATE lNonBlank
PRIVATE phdr_lines, chdr_lines, i, lkey, insert_flag

// get default .MEM file info
RESTORE FROM &form_mem ADDITIVE

// .DBF file info
SELECT 0
USE &form_dbf ALIAS form_dbf

// set up work arrays
DECLARE phdr_lines[4]
DECLARE chdr_lines[24*4]    // 24 fields, 4 lines each

// inititalize pagetitle array
afill(phdr_lines,SPACE(60))

// translate semicolons into lines and stuff array
fstart_pos = 1
phdr_lines[1] = XLATE(frm_pagehdr, ";", 60)
phdr_lines[2] = XLATE(frm_pagehdr, ";", 60)
phdr_lines[3] = XLATE(frm_pagehdr, ";", 60)
phdr_lines[4] = XLATE(frm_pagehdr, ";", 60)

// initalize contents header array
afill(chdr_lines, SPACE(65), 1, 24*4)

// set the array index
ar_index = 1

// get the strings from datafile
GO TOP
FOR i = 1 TO RECCOUNT()

   * set field start position   
	fstart_pos = 1

	* set up fields contents headers
	chdr_lines[ar_index]   = XLATE(form_dbf->header, ";", 65)
	chdr_lines[ar_index+1] = XLATE(form_dbf->header, ";", 65)
	chdr_lines[ar_index+2] = XLATE(form_dbf->header, ";", 65)
	chdr_lines[ar_index+3] = XLATE(form_dbf->header, ";", 65)

   * next one
	SKIP

	* increment array subscript (in groups of four)
	ar_index = ar_index + 4

NEXT
	
// pad the group/subgroup area, if necessary
frm_grpexpr  = frm_grpexpr + SPACE(200 - LEN(frm_grpexpr))
frm_grphdr   = frm_grphdr  + SPACE( 50 - LEN(frm_grphdr ))
frm_subexpr  = frm_subexpr + SPACE(200 - LEN(frm_subexpr))
frm_subhdr   = frm_subhdr  + SPACE( 50 - LEN(frm_subhdr ))

// modifying old file
GO TOP
IF frm_colcount != 0    

	m_contents = form_dbf->contents
	m_width    = form_dbf->width
	m_decimals = form_dbf->decimals
	m_totals   = form_dbf->totals

***** 03/29/88
* originally:
*   total_fields   = frm_colcount
* fix:
	TOTAL_FIELDS = int(FRM_COLCOUNT)


ELSE    // modifying new file, frm_colcount == 0

	m_contents = SPACE(254)
	m_width    = 10
	m_decimals = 0
	m_totals   = "N"
	total_fields   = 1

ENDIF
	
// get the data again if 'Cancel' on filebox
IF my_update

	m_contents = form_dbf->contents
	m_width    = form_dbf->width
	m_decimals = form_dbf->decimals
	m_totals   = form_dbf->totals

ENDIF

insert_flag = .F.   // no inserted fields yet
exit_status = .F.   // exit not set yet

// exit on F10
SET KEY -9 TO set_exit_flag

key = form_state        // the fields screen

// index is always 1 on entry
ar_index = 1

// control loop for frm_edit
DO WHILE !exit_status

   * set page function keys 
	SET KEY -1 TO clear_gets   // F2
	SET KEY -2 TO clear_gets   // F3        
	SET KEY -3 TO clear_gets   // F4

	DO CASE
		CASE M->form_state == 1
			UpdateColumn(.T.)
			DO form_layout
		CASE M->form_state == 2
			UpdateColumn(.T.)
			DO form_groups
		CASE M->form_state == 3
			UpdateColumn(.T.)
			DO form_fields
		CASE M->form_state == 4
			UpdateColumn(.T.)
			DO form_delete
			form_state = 3
			* DON'T get new key 
			LOOP
		CASE M->form_state == 5
			UpdateColumn(.T.)
			DO form_insert
			form_state = 3
			* DON'T get new key 
			LOOP
		CASE M->form_state == 6
			UpdateColumn(.T.)
			DO form_goto
			form_state = 3
			* DON'T get new key 
			LOOP
	ENDCASE

	* get the key
	key = LASTKEY()

	DO CASE

	  * if key was F10
		CASE M->key == -9
			DO set_exit_flag

		CASE M->key == 27 .OR. M->key == 18 .OR. M->key == 3
			* define your own special 'read-exit' keys here, if needed
		
		***** 03/29/88
		* fix:
		case m->KEY > 27 .and. m->KEY < 255

		OTHERWISE   // the function keys
			form_state = VAL(SUBSTR(LTRIM(STR(M->key)),2))  // get the new state

	ENDCASE

ENDDO

//   Note: dBASE III+ uses a semi-colon to delimit report title fields
//         and saves them in the .FRM file in the following manner
//         (where digit <n> represents the field line number):
//          
//         titles               .FRM file
//         ------               ---------
//         1                    1
//         1 2                  1;2
//         1 2 3 4              1;2;3;4
//         1   3                1;;3
//         (none)               [blank]
//               4              ;;;4
//           2   4              ;2;;4
//
lNonBlank := .F.

frm_pagehdr := ""      

FOR i = 4 TO 2 STEP -1

   // test for first nonblank
   lNonBlank := IIF( lNonBlank, lNonBlank, ! EMPTY( phdr_lines[ i ] ) )

   // once a nonblank is encountered, prefix all but the first
   // entry with a semi-colon
   frm_pagehdr := IIF( lNonBlank, ";", "" ) + TRIM( phdr_lines[ i ] ) + ;
	  frm_pagehdr

NEXT i

frm_pagehdr = TRIM( phdr_lines[ i ] ) + frm_pagehdr

// strip of spaces in the group/subgroup areas
frm_grpexpr  = TRIM(frm_grpexpr)
frm_grphdr   = TRIM(frm_grphdr)
frm_subexpr  = TRIM(frm_subexpr)
frm_subhdr   = TRIM(frm_subhdr)

// save if updated and 'No' was not selected
IF my_update .AND. !no_save_flag

	*  set number of fields
	frm_colcount = MAX(total_fields, frm_colcount)

   SAVE ALL LIKE frm_* TO &form_mem
	
	* put the semicolon's back on, the simple way
	i = 1
	GO TOP
	DO WHILE .NOT. EOF()
		REPLACE form_dbf->header WITH ;
		TRIM(chdr_lines[i]) + ";" + TRIM(chdr_lines[i+1]) + ";" + ;
		TRIM(chdr_lines[i+2]) + ";" + TRIM(chdr_lines[i+3])
		SKIP
		i = i + 4
	ENDDO

ENDIF

CLOSE DATABASES

// disable SET KEYs ...
FOR i = 1 TO 6
	SET KEY -i TO
NEXT
SET KEY -9 TO 

RETURN (my_update)
// end of frm_edit (function)



****
* form_fields (procedure)
*
* called from frm_edit, processes editing requests
****
PROCEDURE form_fields

PRIVATE stay_msg, no_more_fields, rec_saved

SET CURSOR ON

// set up function keys
SET KEY -4 TO clear_gets    // delete (F5)
SET KEY -5 TO clear_gets    // insert (F6)
SET KEY -6 TO clear_gets    // goto # (F7)

SET KEY -3 TO   // disable this option (F4)

// draw screen
FRM_SCR(3)

// possible error messages
stay_msg       = "(Must type in inserted field, or delete, before moving)."
no_more_fields = "(You have reached end of file)."

break_out = .F.     // flag to break out of WHILE loop

DO WHILE !exit_status

   * just in case
   @ 4,71 SAY IF (!BOF(), "Field " + LTRIM(STR(RECNO())) + " ", "<bof>  ")
   @ 4,71 SAY IF (!EOF(), "Field " + LTRIM(STR(RECNO())) + " ", "<eof>  ")

   @ 5,71 SAY "Total " + LTRIM(STR(total_fields)) + " "

   @ 07,09 GET m_contents PICTURE "@S65"

   @ 11,09 GET chdr_lines[ar_index]
   @ 12,09 GET chdr_lines[ar_index+1]
   @ 13,09 GET chdr_lines[ar_index+2]
   @ 14,09 GET chdr_lines[ar_index+3]

   @ 19,10 GET m_width    PICTURE "99"
   @ 20,10 GET m_decimals PICTURE "99"
   @ 21,10 GET m_totals   PICTURE "!"

   READ

   lkey = LASTKEY()

   IF break_out     // set in clear_gets procedure
	  EXIT
   ENDIF

   * was it updated?
   my_update = my_update .OR. UPDATED()

   * F10?
   IF exit_status
	  IF RECNO() < 24
		 UpdateColumn(.T.)
	  ELSEIF total_fields > 0
		 total_fields = total_fields - 1
	  ENDIF

   ENDIF

   DO CASE
	  CASE lkey == 13 .OR. lkey == 3    // CR or PgDn
	
			* put the information in the file when going forward
			UpdateColumn(.F.)

			IF insert_flag .AND. !my_update
				@ 24,CENTER(stay_msg,80) SAY stay_msg
				INKEY(5)
				@ 24,0
				LOOP
			ELSE
				* reset insert flag 
				insert_flag = .F.
			ENDIF

			* add a new one
			IF (UPDATED() .AND. RECNO() == LASTREC()) .OR. (RECNO() == LASTREC() .AND. !EMPTY(m_contents))

				* save for restore, if illegal APPEND
				rec_saved = RECNO()

				APPEND BLANK

				* no more than 24 fields allowed
				IF RECNO() > 24

					@ 24,CENTER(no_more_fields,80) SAY no_more_fields
					INKEY(2)
					DELETE
					PACK

					@ 24,0
					* restore
					GO rec_saved

					LOOP
				ENDIF

				* increment array subscript
				IF ar_index <= 92
					ar_index = ar_index + 4
				ENDIF

				* add the total field count
				total_fields = total_fields + 1

				* init new field
				m_contents = SPACE(254)
				m_width    = 10
				m_decimals =  0
				m_totals   = "N"

			ELSE

			SKIP
			IF ar_index <= 92
				ar_index = ar_index + 4
			ENDIF

				IF EOF()

				* no more ...
					@ 24,CENTER(no_more_fields,80) SAY no_more_fields
					INKEY(3)
					@ 24,0

				SKIP -1

				IF RECNO() < 24
				IF ar_index > 1
						ar_index = ar_index - 4
					ENDIF
				ENDIF

			ENDIF
	
				m_contents = form_dbf->contents
				m_width    = form_dbf->width
				m_decimals = form_dbf->decimals
				m_totals   = form_dbf->totals
	
			ENDIF
								
	  CASE lkey == 18   // PgUp

		* put the information in the file when going backward
		UpdateColumn(.F.)

		IF insert_flag .AND. !my_update
			@ 24,CENTER(stay_msg,80) SAY stay_msg
			INKEY(3)
			@ 24,0
			LOOP
		ELSE
			* reset insert flag 
			insert_flag = .F.
		ENDIF

		IF !BOF()

			SKIP -1

			IF ar_index > 1
				ar_index = ar_index - 4
			ENDIF

		   m_contents = form_dbf->contents
		   m_width    = form_dbf->width
		   m_decimals = form_dbf->decimals
		   m_totals   = form_dbf->totals

		ENDIF

   ENDCASE

ENDDO

my_update = my_update .OR. UPDATED()

RETURN
// end of form_fields (procedure)



***
* form_insert (procedure)
*
* insert a column (field) in the report file
*
* insert a field only when:
*   a) field is not the first one, first time
*   b) field is not the last one
*   c) total field count is not larger than maximum, 24
*
* Purpose:
*  shifts fields up by one, inserts a new one
* 
* Note: Field that is left blank creates an error in expression area.
*       Delete 'unused' field to avoid this.
*
***
PROCEDURE form_insert
PARAMETERS dummy1, dummy2, dummy3

PRIVATE saved_record, insert_error, temp

insert_error = "(Cannot insert field. Insert (F6) invalid here, or maximum is reached)."

IF RECNO() != 1 .AND. RECNO() != LASTREC() .AND. RECCOUNT() < 24 .AND. !EMPTY(form_dbf->contents)

	* save position before insert call
	saved_record = RECNO()

	* new field, return Boolean to insert_flag for processing in form_fields
	insert_flag = insert_blank(RECNO())
	
	* restore record#
	GO saved_record

	* add an item in array, starting at ar_index pos
	FOR temp = ar_index TO ar_index + 3
		ains(chdr_lines, ar_index)
		chdr_lines[ar_index] = SPACE(65)        // no (U) here!
	NEXT

	* increment field count variables
	total_fields = total_fields + 1
	frm_colcount = frm_colcount + 1

	* initialize new field
	m_contents = SPACE(254)
	REPLACE form_dbf->contents WITH SPACE(254)
	REPLACE form_dbf->header   WITH SPACE(260)
	REPLACE form_dbf->width    WITH 10
	REPLACE form_dbf->totals   WITH "N"
	REPLACE form_dbf->decimals WITH 0

	* no update flag for insert
	my_update = .F.

ELSE

	@ 24,CENTER(insert_error,80) SAY insert_error
	INKEY(4)
ENDIF

RETURN
// end of form_insert (procedure)



***
*  insert_blank (function)
*
*  insert a blank record in dbf at position 'pos'
*
***
FUNCTION insert_blank
PARAMETERS pos

PRIVATE inserted

// yes, we are inserting, set flag
inserted = .T.

// set position for insert
@ 3,0 SAY "Insert at field " + LTRIM(STR(pos)) + " ..."

// position
GO pos

// make temp file, copy the rest of file
COPY NEXT LASTREC() TO temp

// mark them, delete
DELETE ALL FOR RECNO() >= pos

// add a new one
APPEND BLANK

// get the tail list
APPEND FROM temp

// remove deleted items
PACK

// delete temporary work file, insertion done!
DELETE FILE temp.DBF

RETURN (inserted)
// end of insert_blank (function)



***
* form_delete (procedure)
*
* purpose:
*    delete a column (field) in the report file
*
* delete a field when the field is already blank
* so user has the option to abort process.
*
* note: a deletion sets the my_update flag so the file may
*       be saved to disk.
* 
***
PROCEDURE form_delete
PARAMETERS dummy1, dummy2, dummy3

PRIVATE temp, saved_record, content_error

content_error = "(Field must be blank to do that.  Use Ctrl-Y to delete)."

// field contents is empty, OK to delete
IF EMPTY(m_contents)

	* remove items in array, starting at ar_index pos
	FOR temp = ar_index TO ar_index + 3
		adel(chdr_lines, ar_index)
		chdr_lines[LEN(chdr_lines)] = SPACE(65)     // no (U) here!
	NEXT

	* save this record before delete
	saved_record = RECNO()

	DELETE
	PACK

	* reset insert flag, in case of 'insert-notyping-delete' process
	insert_flag = .F.

	IF !EOF()

		IF saved_record = total_fields
			GO saved_record - 1
			IF ar_index > 1
				ar_index = ar_index - 4
			ENDIF
		ELSE
			GO saved_record
		ENDIF

	ELSE

		APPEND BLANK

		REPLACE form_dbf->contents WITH SPACE(254)
		REPLACE form_dbf->header   WITH SPACE(260)
		REPLACE form_dbf->width    WITH 10
		REPLACE form_dbf->totals   WITH "N"
		REPLACE form_dbf->decimals WITH  0

	ENDIF

	IF total_fields > 1
		total_fields = total_fields - 1
		frm_colcount = frm_colcount - 1
	ENDIF

	* get the new data
	m_contents = form_dbf->contents
	m_width    = form_dbf->width
	m_decimals = form_dbf->decimals
	m_totals   = form_dbf->totals

	my_update = .T.     // generates an update...

ELSE    // field content is not empty, error

	* honk 
	?? CHR(7)

	* display the error msg
	@ 24,CENTER(content_error,80) SAY content_error
	INKEY(4)
ENDIF

RETURN
// end of form_delete (procedure)



***
*   form_goto (procedure)
*
*   goto specified field (F7)
***
PROCEDURE form_goto

PRIVATE goto_str, goto_field, goto_error, goto_ok, recno_saved

* for this procedure only
SET CONFIRM ON

goto_str   = "Go to field number "
goto_error = "(Field not in valid range.  Range is 1 to 24)."
goto_field = RECNO()

goto_ok = .F.
DO WHILE !goto_ok

	@ 24,0
	@ 24,20 SAY goto_str
	@ 24,39 GET goto_field PICTURE "99"
	READ

   * abort if <esc> key was hit
   IF LASTKEY() == 27
	  RETURN   
   ENDIF

   * save, to restore if error (eof)
   recno_saved = RECNO()

   * first check
   GO goto_field

   * entry ok?
   IF goto_field <= 0 .OR. goto_field >= 25 .OR. EOF()
		@ 24,CENTER(goto_error,80) SAY goto_error
		INKEY(4)
	  IF EOF()
		 GO recno_saved
	  ENDIF
	ELSE
		goto_ok = .T.
	ENDIF

ENDDO

// new field position
GO goto_field

// set ar_index to new position
ar_index = (goto_field * 4) - 3

// the data of the new position
m_contents = form_dbf->contents
m_width    = form_dbf->width
m_decimals = form_dbf->decimals
m_totals   = form_dbf->totals

// set back to default
SET CONFIRM OFF

RETURN
// end of form_goto (procedure)



***
*   clear_gets (procedure)
*
*   exit read
***
PROCEDURE clear_gets
PARAMETERS dummy1,dummy2,dummy3

IF form_state = 3   // break out of loop when in fields procedure only
	break_out = .T.
ENDIF
CLEAR GETS
RETURN
// end of clear_gets (procedure)



***
* form_layout (procedure)
*
* display the pageheading and items related to report layout
***
PROCEDURE form_layout

LOCAL bValidHeader := { | cString | ! ( ";" $ cString ) }
// this represents the minimum constraint --  calculation should account for
// column widths
LOCAL bValidRMargin := { | nExp | nExp < frm_pagewidth .AND. nExp >= 0 }

LOCAL nHeaderIndex

FRM_SCR(1)

SET CURSOR ON

SET KEY -4 TO   // no delete option
SET KEY -5 TO  // no insert option
SET KEY -6 TO   // no goto option here
SET KEY -1 TO   // disable this option

// get page headers from user
FOR nHeaderIndex := 1 TO LEN( phdr_lines )

   @ 05 + nHeaderIndex, 12 GET phdr_lines[ nHeaderIndex ] VALID ;
	  VCondition( bValidHeader, ;
	  "Semicolon (;) not permitted in page heading" )

NEXT nHeaderIndex
	
@ 12,42 GET frm_pagewidth PICTURE "999"
@ 13,42 GET frm_leftmarg  PICTURE "999"


@ 14,42 GET frm_rightmarg PICTURE "999" VALID VCondition( bValidRMargin, ;
   "Invalid right margin -- must be between 0 and " + ;
   ltrim( str( frm_pagewidth - 1 ) ) )


@ 15,42 GET frm_linespage PICTURE "999"
@ 16,42 GET frm_dblspaced PICTURE "!"
			
@ 20,49 GET frm_pebp      PICTURE "!"
@ 21,49 GET frm_peap      PICTURE "!"
@ 22,49 GET frm_plainpage PICTURE "!"
			
READ

IF UPDATED()
	my_update = .T.
ENDIF

RETURN
// end of form_layout (procedure)



/***
*
*  VCondition( <bCondition>, [<cErrMsg>], [<lEcho>] ) --> lValid
*
*  Test current GET for specified condition; optionally display
*  error message.
*
*/
STATIC FUNCTION VCondition( bCondition, cErrMsg, lEcho )
   LOCAL lValid := .F.

   cErrMsg := IIF( cErrMsg == NIL, "Invalid", cErrMsg )

   xExp := GetActive():varGet()

   lEcho := IIF( lEcho == NIL, .T., lEcho )

   lValid := EVAL( bCondition, xExp )

   IF lEcho
	  SET CURSOR OFF

	  @ 24,0 SAY PADC( IIF( !lValid, cErrMsg, ""), 80 )

	  SET CURSOR ON

   ENDIF

   RETURN ( lValid )



***
* form_groups (procedure)
*
* display the group and subgroup headers, plus summary and eject options
***
PROCEDURE form_groups

FRM_SCR(2)

SET CURSOR ON

SET KEY -4 TO   // no delete option here
SET KEY -5 TO  // no insert option here
SET KEY -6 TO   // no goto option here

SET KEY -2 TO   // disable this option

@ 06,25 GET frm_grpexpr PICTURE "@S50"
@ 07,25 GET frm_grphdr

@ 11,23 GET frm_summary PICTURE "!"
@ 12,23 GET frm_pe PICTURE "!"

@ 18,25 GET frm_subexpr PICTURE "@S50"
@ 19,25 GET frm_subhdr

READ    
	
IF UPDATED()
	my_update = .T.
ENDIF

RETURN
// end of form_groups (procedure)



***
* frm_scr (function)
*
* draw the report screens, indicated by parameter 'screen'
***
FUNCTION FRM_SCR
PARAMETERS screen

PRIVATE pagehead, field_def, group, sub_group, m_exit, m_nogo
PRIVATE m_f1, m_f2, m_f3, m_f4, m_f5, m_f6, m_f10, m_layout, m_groups, m_fields
PRIVATE m_insert, m_delete, m_help

pagehead  = "อออ Page Header อออ"
field_def = "อออ Column Definitions อออ"
group     = "อออ Group Specifications อออ"
sub_group = "อออ Sub-Group Specifications อออ"

m_f1  = "F1"
m_f2  = "F2"
m_f3  = "F3"
m_f4  = "F4"
m_f5  = "F5"
m_f6  = "F6"
m_f7  = "F7"
m_f10 = "F10"

m_help   = "Help  "
m_layout = "Report"         // "Layout"
m_groups = "Groups"
m_fields = "Columns"        //  "Fields"
m_delete = "Delete"
m_insert = "Insert"
m_goto   = "Go To "
m_exit   = "Exit  "
m_nogo   = "...    "

CLEAR

// Display menu line.
@ 00,01 SAY m_f1
@ 00,11 SAY m_f2
@ 00,21 SAY m_f3
@ 00,31 SAY m_f4
@ 00,41 SAY m_f5
@ 00,51 SAY m_f6
@ 00,61 SAY m_f7
@ 00,70 SAY m_f10

@ 01,01 SAY m_help
@ 01,11 SAY m_layout
@ 01,21 SAY m_groups
@ 01,31 SAY m_fields
@ 01,41 SAY m_delete
@ 01,51 SAY m_insert
@ 01,61 SAY m_goto
@ 01,70 SAY m_exit

@ 02,00 SAY REPLICATE(CHR(196),80)

DO CASE

	CASE screen == 1
		* Page definition screen.

		@ 01,11 SAY m_nogo   // this option 'disabled'
		@ 01,41 SAY m_nogo   // delete 'disabled'
		@ 01,51 SAY m_nogo   // insert 'disabled'
		@ 01,61 SAY m_nogo   // go to  'disabled'

		@ 03,80-LEN("File " + form_file) SAY "File " + form_file

		@ 04,30 SAY pagehead

		@ 11,27 SAY "Formatting "
	
		@ 12,27 SAY "Page Width"
		@ 13,27 SAY "Left Margin"
		@ 14,27 SAY "Right Margin"
		@ 15,27 SAY "Lines Per Page"
		@ 16,27 SAY "Double Spaced?"
	
		@ 19,24 SAY "Printer Directives"

		@ 20,24 SAY "Page Eject Before Print"
		@ 21,24 SAY "Page Eject After Print"
		@ 22,24 SAY "Plain Page"

	CASE screen == 2
		* Group definition screen.

		@ 01,21 SAY m_nogo   // this option 'disabled'
		@ 01,41 SAY m_nogo  // delete 'disabled'
		@ 01,51 SAY m_nogo   // insert 'disabled'
		@ 01,61 SAY m_nogo  // go to  'disabled'

		@ 03,80-LEN("File " + form_file) SAY "File " + form_file

		@ 04,CENTER(group,80) SAY group

		@ 06,0 SAY "Group On Expression"
		@ 07,0 SAY "Group Heading" 

		@ 11,0 SAY "Summary Report Only"
		@ 12,0 SAY "Page Eject After Group"

		@ 16,CENTER(sub_group, 80) SAY sub_group

		@ 18,0 SAY "Sub-Group On Expression"
		@ 19,0 SAY "Sub-Group Heading"

	CASE screen == 3

		* Column definition screen.
		@ 03,80-LEN("File " + form_file) SAY "File " + form_file
		@ 01,31 SAY m_nogo

		@ 05,CENTER(field_def, 80) SAY field_def

		@ 07,00 SAY "Contents"
		@ 10,00 SAY "Heading"

		@ 11,06 SAY "1"
		@ 12,06 SAY "2"
		@ 13,06 SAY "3"
	 @ 14,06 SAY "4"
		@ 18,00 SAY "Formatting"

		@ 19,00 SAY "Width"
		@ 20,00 SAY "Decimals"
		@ 21,00 SAY "Totals"

ENDCASE

RETURN ("")
// end of frm_scr (function)



***
* frm_error (function)
*
* display the report file errors
****
FUNCTION FRM_ERROR
PARAMETERS fname, dos_error

PRIVATE err_str, dos_code

dos_code = LTRIM(STR(dos_error))

DO CASE

	CASE dos_error == -3        // eof while reading
		err_str = "Code " + dos_code + " " + "eof while reading report " + fname

	CASE dos_error == -2        // disk full
		err_str = "Code " + dos_code + " " + "disk full saving report " + fname

	CASE dos_error == -1        // not a report file
		err_str = "Code " + dos_code + " " + "not a report file " + fname

	CASE dos_error == 2     // Open error, file not found
		err_str = "Code " + dos_code + " " + "error opening report " + fname

	CASE dos_error == 6     // Close error, invalid handle
		err_str = "Code " + dos_code + " " + "error closing report " + fname

   CASE dos_error == 25   // Seek error, FSEEK
		err_str = "Code " + dos_code + " " + "error seeking report " + fname

	CASE dos_error == 29        // Write error, write fault
		err_str = "Code " + dos_code + " " + "error writing report " + fname

	CASE dos_error == 30        // Read error, read fault
		err_str = "Code " + dos_code + " " + "error reading report " + fname

  OTHERWISE
		err_str = "Code " + dos_code + " " + "see DOS extended error codes"

ENDCASE

@ 24,CENTER(err_str,80) SAY err_str
INKEY(4)
@ 24,0

RETURN ("")
// end of frm_error (function)



***
* lbl_error (function)
*
* display the label file errors
***
FUNCTION LBL_ERROR
PARAMETERS fname, dos_error

PRIVATE err_str, dos_code

dos_code = LTRIM(STR(dos_error))

DO CASE

	CASE dos_error == -3        // eof while reading
		err_str = "Code " + dos_code + " " + "eof while reading label " + fname

	CASE dos_error == -2        // disk full
		err_str = "Code " + dos_code + " " + "disk full saving label " + fname

	CASE dos_error == -1        // not a label file
		err_str = "Code " + dos_code + " " + "not a label file " + fname

	CASE dos_error == 2     // Open error, file not found
		err_str = "Code " + dos_code + " " + "error opening label " + fname

	CASE dos_error == 6     // Close error, invalid handle
		err_str = "Code " + dos_code + " " + "error closing label " + fname

   CASE dos_error == 25   // Seek error, FSEEK
		err_str = "Code " + dos_code + " " + "error seeking label " + fname

	CASE dos_error == 29        // Write error, write fault
		err_str = "Code " + dos_code + " " + "error writing label " + fname

	CASE dos_error == 30        // Read error, read fault
		err_str = "Code " + dos_code + " " + "error reading label " + fname

  OTHERWISE
		err_str = "Code " + dos_code + " " + "see DOS extended error codes"

ENDCASE

@ 24,CENTER(err_str,80) SAY err_str
INKEY(4)
@ 24,0

RETURN ("")
// end of lbl_error (function)



***
* center (function)
*
* center a string
***
FUNCTION CENTER
PARAMETER string,length
RETURN INT((length-LEN(string))/2)

//**
// ext_add (function)
//
// append an .FRM/.LBL extension if one was not found
//**
FUNCTION EXT_ADD
PARAMETERS fname, type

PRIVATE open

IF AT(".", fname) == 0
	IF type == "L"
		open = TRIM(fname) + ".LBL"
	ENDIF
	IF type == "R"
		open = TRIM(fname) + ".FRM"
	ENDIF
ELSE
	open = TRIM(fname)
ENDIF

RETURN (open)
// end of ext_add (function)



***
* Xlate()
*   Translate the semicolons
* 
***
FUNCTION XLATE
PARAMETERS source, char, len

PRIVATE xlated_str

fend_pos = AT(char, SUBSTR(source, fstart_pos, len))

IF fend_pos = 0
	xlated_str = SUBSTR(source, fstart_pos, len)
	fstart_pos = fstart_pos + LEN(xlated_str)
ELSE
	xlated_str = SUBSTR(source, fstart_pos, fend_pos - 1)
	fstart_pos = fstart_pos + LEN(xlated_str) + 1
ENDIF

// pad string with spaces when needed
IF LEN(xlated_str) != len
	xlated_str = xlated_str + SPACE(len - LEN(xlated_str))
ENDIF

RETURN (xlated_str)

***
*
* UpdateColumn()
*   update the contents and parameters of column for report
*   when change the screen
***
FUNCTION UpdateColumn( isCheckUpd )
   IF isCheckUpd
	  IF !my_update
		 RETURN (NIL)
	  ENDIF
   ENDIF

   form_dbf->contents = m_contents
   form_dbf->width = m_width
   form_dbf->decimals = m_decimals
   form_dbf->totals = m_totals

   RETURN (NIL)
