/***
*
* Dot.prg
*
* Dot-prompt interpreter written in Clipper.
*
* Copyright (c) 1986-1993, Computer Associates International, Inc.
* All rights reserved.
* 
* 
* NOTE
* ----
* DOT is offered as an example of Clipper capabilities.  It does
* not constitute a working dBASE interpreter.
*
*
* PROGRAM OVERVIEW
* ----------------
* DOT is an interpreter for some of the commands in the Clipper command
* set.  DOT consists of a stack, a parser to fill it, procedure driven
* stack analyzers, list and expression building functions, command line
* execution procedures, etc.
*
* After a command has been entered the verb analyzer checks the stack
* for an equal sign after the first identifier.  If an assignment is
* found, the analyzer procedure macro is set to "ASSIGN".  If not, the
* analyzer searches the verb list for the existence of the first stack
* item.  If a match is found, it is checked for correct abbreviation.
* If it is correct, the analysis procedure macro is initialized to the
* procedure name found in the analyzer procedure list.  If the item
* was not found or failed the abbreviation test, the analyzer macro is
* set to "UNKNOWN".  The analyzer procedure is used to set the Class
* Execution procedure macro, execution flags and Command Line
* Substitution macros.  If an assignment or a variable is to be
* created or deleted, it is done next, in the top most level of DOT.
* One of six Class Execution procedures is called next, based on what
* was found on the stack.  The called procedure contains Clipper
* command strings with substitution macros used in the variable
* portion of the line.  The command is selected with the execution
* flag set in the analyzer.  After the command has been executed, it
* is placed into the History array.  The control variables and command
* line macros are reset, and the loop returns to the top, ready for
* another command.
* 
* What ever you want to do, DOT can be tailored to your needs by
* adding PROCEDUREs and FUNCTIONs to form new commands.  A command can
* be appended to DOT by adding the verb and the matching analysis
* procedure name to the verb and analyzer lists. Next, decide on the
* Class Execution procedure you want to execute your command in, and
* add another DO CASE switch variable to the PUBLIC switch list at the
* beginning of the DOT procedure.  The analysis procedure can be added
* after you have selected the PROCEDURE and switch names.  These
* procedures and/or functions that you define can be made up of any
* combination of Clipper, "C", or ASSEMBLY routines. They, in turn,
* are interfaced to DOT by using Clipper's EXTEND system and EXTERNAL
* references. The EXTERNALs can either by added directly to DOT, your
* .PRG file, or compiled as a seperate file and included in the link
* line as an object module.
*
*/

clear

** set CALLS class flags public **
public CALLS1, CALLS2, CALLS3, CALLS4, CALLS5, CALLS6, CALLS7

** set DBF_NTX class flags public **
public DBF_NTX1, DBF_NTX2, DBF_NTX3, DBF_NTX4, DBF_NTX5, DBF_NTX6
public DBF_NTX7, DBF_NTX8, DBF_NTX9, DBF_NTX10, DBF_NTX11, DBF_NTX12
public DBF_NTX13, DBF_NTX14, DBF_NTX15, DBF_NTX16, DBF_NTX17, DBF_NTX18
public DBF_NTX19, DBF_NTX20, DBF_NTX21, DBF_NTX22, DBF_NTX23, DBF_NTX24
public DBF_NTX25, DBF_NTX26, DBF_NTX27, DBF_NTX28, DBF_NTX29, DBF_NTX30
public DBF_NTX31, DBF_NTX32, DBF_NTX33, DBF_NTX34, DBF_NTX35, DBF_NTX36

** set ERRS class flags public **
public ERRS1, ERRS2, ERRS3, ERRS4, ERRS5, ERRS6, ERRS7, ERRS8, ERRS9
public ERRS10, ERRS11, ERRS12, ERRS13, ERRS14, ERRS15

** set SCRN class flags public **
public SCRN1, SCRN2, SCRN3, SCRN4, SCRN5, SCRN6, SCRN7, SCRN8, SCRN9
public SCRN10, SCRN11, SCRN12, SCRN13, SCRN14, SCRN15, SCRN16, SCRN17
public SCRN18, SCRN19, SCRN20, SCRN21, SCRN22, SCRN23, SCRN24, SCRN25
public SCRN26, SCRN27, SCRN28

** set SETS class flags public **
public SETS1, SETS2, SETS3, SETS4, SETS5, SETS6, SETS7, SETS8, SETS9
public SETS10, SETS11, SETS12, SETS13, SETS14, SETS15, SETS16, SETS17
public SETS18, SETS19, SETS20, SETS21, SETS22

** set VARS class flags public **
public VARS1, VARS2, VARS3, VARS4, VARS5, VARS6, VARS7, VARS8, VARS9
public VARS10, VARS11, VARS12

** set data and index file status flags public **
public DBF_OPEN, NTX_OPEN

** set command line execution macro variables public **
public box_exp, coord1, coord2, coord3, coord4, dbf_file, dest, exp1
public exp2, exp3, get_exp, get_pict, list0, list1, list2, list3, list4
public list5, list6, list7, list8, list9, ntx_file, rng_exp1, rng_exp2
public say_exp, say_pict, source, var1

** set non-releasable macro variables **
public alias, filter, range1, range2, relation, valid_exp

** initialize non-releasable macro variables **
store "" to alias, filter, range1, range2, relation, valid_exp

** set conditional and scoping system variables public **
public condition, rewind_dbf, scope

** set internal status flags public **
public color_stat, confr_stat, delim_stat, exact_stat, inten_stat

** initialize internal status flags **
color_stat = "7/0"
confr_stat = "OFF"
delim_stat = "OFF"
exact_stat = "OFF"
inten_stat = "ON"

** set internal control variables public **
public bottom_on, cmd_line, error_on, executor, hist_max, lex_proc
public lex_list, max_hist, save_col, save_row, set_list, set_proc
public stack_size, verb_list, dot_vers

** initialize internal search list variables **
do fill_lists

** initialize internal control variables **
bottom_on = .T.
cmd_line = replicate("ø", 80)
error_on = .T.
save_col = 0
save_row = 0
stack_size = 30

** initialize the history variables **
hist_max = 0
max_hist = 20
declare history[max_hist]
dot_vers = "10/27/86"


** 5.0 error handler (see end of source file) **
public SysErrorBlock := ErrorBlock( {|e| DotError(e)} )


quit_now = .F.

do while !quit_now

	** reset command line execution macro variables **
	store "" to box_exp, coord1, coord2, coord3, coord4
	store "" to dbf_file, dest, exp1, exp2, exp3
	store "" to get_exp, get_pict, ntx_file, rng_exp1, rng_exp2
	store "" to say_exp, say_pict, source, var1
	store "" to list0, list1, list2, list3, list4
	store "" to list5, list6, list7, list8, list9


	begin sequence

	    declare stack[stack_size]        && initialize STACK.
	    stack_ptr = 0                    && initialize stack element pointer.
	    max_ptr = 0                      && initialize stack element counter.

	    lex_proc = ""                    && initialize analyzer macro.
	    executor = ""                    && initialize "class" executor macro.

	    ** set PROMPT environment quantity **
	    set color to
	    set delimiters OFF
	    set confirm OFF
	    set exact OFF

	    if bottom_on
	        do input_ln with "B"         && prompt at bottom of screen.
	    endif

	    ** set HELP and HISTORY call keys **
	    set key 28 to help
	    set key 5 to history

	    accept ". " to command           && get input from keyboard.

	    do hist_put                      && place command into HISTORY array.

	    command = "&command"             && expand all macros in string

	    set key 5 to                     && turn OFF HISTORY mode.

	    if bottom_on
	        do input_ln with "A"         && cursor to last display position.
	    endif

	    do parse                         && call "stack" population routine.
	    max_ptr = stack_ptr              && assign maximum stack elements.

	    if max_ptr > 0                   && stack elements exist.
	        if !err()                    && NO errors occurred in parser.
	            do set_lex               && do analyzer macro set procedure.
	            do &lex_proc             && do the analyze procedure macro.

	            if CALLS7
	                quit_now = .t.
					break
	            endif

	            if executor = "VARS"
	                ** check for variable creation or release activity. **
	                do case
	                    case VARS9
	                        ** if a variable is to be created **
	                        &var1 = &exp2
	                        VARS9 = .F.

	                    case VARS10
	                        ** if an array is to be created **
	                        declare &var1[&exp1]
	                        VARS10 = .F.

	                    case VARS11
	                        ** if a variable is to be released **
	                        release &var1
	                        VARS11 = .F.

	                    case VARS12
	                        ** if an array is assigned a value **
	                        &var1[&exp1] = &exp2
	                        VARS12 = .F.
	                endcase
	            endif
	        endif

	        if err()
				executor = "ERRS"        && set error executor procedure.
	        endif


			** set EXECUTION environment **
			set color to &color_stat
			set delimiters &delim_stat
			set confirm &confr_stat
			set exact &exact_stat

	        do &executor                 && do execution procedure.


	    endif

	recover
		** this is just here to reset the parser **
		command := '? ""'
		do parse

	end

enddo

*
** eoproc dot.prg


*******************
* Dot procedures. *
*******************


***
* Procedure ACCEPT
* Evaluates stack for ACCEPT verb.
* Sets execution class macro, class execution flag(s) and command line
* substitution macros.
*

procedure accept

private stack_ptr, stack_item, item_ok, string, to, dest, active, error

stack_ptr = 2
store .F. to string, to, dest, item_ok
active = 1        && 0 = done, 1 = string, 2 = TO token, 3 = expression.
error = 0

do while stack_ptr <= max_ptr .and. error = 0

    stack_item = ""
    item_ok = get_stack("stack_item")

    do case 
        case active = 0 .or. !item_ok
            error = 2

        case active = 1
            if !(upper(stack_item) == "TO")
                exp1 = stack_item
                string = .T.
                active = 2
            else
                to = .T.    
                active = 3
            endif

        case active = 2
            if upper(stack_item) == "TO"
                to = .T.
                active = 3
            else
                error = 15
            endif

        case active = 3    
            var1 = stack_item
            dest = .T.
            active = 0
    endcase
enddo

do case
    case error = 2 .or. active <> 0
        ERRS2 = .T.

    case error = 15
        ERRS15 = .T.

    case to .and. dest .and. !string
        executor = "VARS"
        VARS1 = .T.
        VARS9 = .T.

    case to .and. dest .and. string
        executor = "VARS"
        VARS2 = .T.
        VARS9 = .T.
endcase

return

*
** eoproc accept


***
* Procedure APPEND
* Evaluates stack for APPEND verb.
* Sets execution class macro, class execution flag(s) and command line
* substitution macros.
*

procedure append

private stack_ptr, stack_item, item_ok, blank, file, from, active, error

stack_ptr = 2
store .F. to blank, file, from, item_ok
active = 0        && 0 = done, 1 = BLANK or FROM toke, 2 = source.
error = 0

if error_on .and. !dbf_open
    error = 5
else
    active = 1
endif

do while stack_ptr <= max_ptr .and. error = 0

    stack_item = ""
    item_ok = get_stack("stack_item")

    do case
        case active = 0
            error = 2

        case active = 1
            do case
                case cmd_abbr(upper(stack_item), "BLANK")
                    blank = .T.
                    active = 0

                case upper(stack_item) == "FROM"
                    from = .T.
                    active = 2

                otherwise
                    error = 2    
            endcase

        case active = 2
            exp1 = stack_item
            if error_on
                if if("."$exp1, file(exp1), file("&exp1..dbf"))
                    file = .T.
                else
                    error = 13
                endif
            else
                file = .T.
            endif
            active = 0
    endcase
enddo

do case
    case error = 2 .or. active <> 0
        ERRS2 = .T.

    case error = 5
        ERRS5 = .T.

    case error = 13
        ERRS13 = .T.

    case blank
        executor = "DBF_NTX"
        DBF_NTX18 = .T.

    case from .and. file
        executor = "DBF_NTX"
        DBF_NTX31 = .T.
endcase

return

*
** eoproc append


**
* Procedure ASSIGN
* Evaluates stack for assignment operator "=".
* Sets execution class macro, class execution flag(s) and command line
* substitution macros.
*

procedure assign

private stack_ptr, equal, exp, array

stack_ptr = 1
store .F. to equal, exp, array

do while stack_ptr <= max_ptr
    do case
        case stack_ptr = 1
            var1 = stack[stack_ptr]
            stack_ptr = stack_ptr + 1
            if stack_ptr <= max_ptr
                if "["$stack[stack_ptr]
                    var1 = var1 + stack[stack_ptr]
                    stack_ptr = stack_ptr + 1
                endif
            endif
            if "["$var1
                string = var1
                var1 = ""
                open_ptr = at("[",string)
                close_ptr = at("]",string)
                var1 = substr(string, 1, (open_ptr - 1))
                exp1 = substr(string,(open_ptr+1),(close_ptr-open_ptr-1))
                array = .T.
            endif

        case stack[stack_ptr] = "="
            equal = .T.
            exp = get_expr1("exp2")
    endcase
enddo

if equal
    if exp
        executor = "VARS"
        if array
            VARS12 = .T.
        else
            VARS9 = .T.
        endif
    else
       ERRS2 = .F.
    endif
else
    ERRS1 = .T.
endif

return

*
** eoproc assign


***
* Procedure AT
* Evaluates stack for @ token.
* Sets execution class macro, class execution flag(s) and command line
* substitution macros.
*

procedure at

set exact on

private at, clear, box, say, say_part, get, get_part, pic1, pic2, range,;
    valid, xy, tlbr, co_num, stack_ptr, stack_item, active, null

store .F. to at, clear, box, say, say_part, get, get_part, pic1, pic2,;
    range, valid, xy, tlbr

co_num = "1"
stack_ptr = 1
active = 1        && 0 = done, 1 = processing say, 2 = processing get.

do while stack_ptr <= max_ptr .and. !err()

    stack_item = upper(stack[stack_ptr])

    do case
        case stack_item = "@"
            null = get_expr1("coord&co_num")
            co_num = str(val(co_num)+1,1)

        case stack_item = ","
            null = get_expr1("coord&co_num")
            co_num = str(val(co_num)+1,1)

        case stack_item = "BOX"
            box = .T.
            null = get_expr1("box_exp")

        case stack_item = "SAY"
            active = 1
            say = .T.
            say_part = get_expr1("say_exp")

        case stack_item = "GET"
            active = 2
            get = .T.
            get_part = get_expr1("get_exp")

        case cmd_abbr(stack_item, "PICTURE")
            do case
                case say .and. !get
                    pic1 = .T.
                    null = get_expr1("say_pict")

                case get .and. !say
                    pic2 = .T.
                    null = get_expr1("get_pict")

                case say .and. get
                    if active = 1        && if processing a say.
                        pic1 = get_expr1("say_pict")
                    else                 && if processing a get.
                        pic2 = get_expr1("get_pict")
                    endif

                otherwise
                    ERRS2 = .T.
            endcase

        case cmd_abbr(stack_item, "CLEAR")
            clear = .T.
            stack_ptr = stack_ptr + 1

        case cmd_abbr(stack_item, "RANGE")
            range = .T.
            null = get_expr1("rng_exp1")
            null = get_expr1("rng_exp2")

        case cmd_abbr(stack_item, "VALID")
            valid = .T.
            null = get_expr1("valid_exp")

        otherwise
            ERRS2 = .T.
    endcase
enddo

set exact &exact_stat

if !err()

    if !empty(coord1) .and. !empty(coord2)
        if !empty(coord3) .and. !empty(coord4)
            tlbr = .T.
        else
            xy = .T.
        endif
    else
        ERRS2 = .T.
    endif

    do case
        case xy .and. !say .and. !get .and. !clear .and. !box
            executor = "SCRN"
            SCRN1 = .T.
    
        case xy .and. clear .and. !say .and. !get .and. !box
            executor = "SCRN"
            SCRN2 = .T.

        case xy .and. say .and. !get
            do case
                case !say_part
                    ERRS2 = .T.

                case !pic1 .and. !clear .and. !range .and. !valid
                    executor = "SCRN"
                    SCRN3 = .T.

                case pic1 .and. !clear .and. !range .and. !valid
                    executor = "SCRN"
                    SCRN4 = .T.

                otherwise
                    ERRS1 = .T.
            endcase

        case xy .and. get .and. !say
            do case
                case !get_part
                    ERRS2 = .T.

                case !pic2 .and. !range .and. !valid
                    executor = "SCRN"
                    SCRN5 = .T.

                case pic2 .and. !range .and. !valid
                    executor = "SCRN"
                    SCRN6 = .T.

                case !pic2 .and. range .and. !valid
                    executor = "SCRN"
                    SCRN7 = .T.

                case !pic2 .and. !range .and. valid
                    executor = "SCRN"
                    SCRN8 = .T.

                case pic2 .and. !range .and. valid
                    executor = "SCRN"
                    SCRN10 = .T.

                case pic2 .and. range .and. !valid
                    executor = "SCRN"
                    SCRN11 = .T.

                otherwise
                    ERRS2 = .T.
            endcase

        case xy .and. say .and. get
            do case
                case !say_part .or. !get_part
                    ERRS2 = .T.

                case !pic1 .and. !pic2 .and. !range .and. !valid
                    executor = "SCRN"
                    SCRN13 = .T.

                case pic1 .and. !pic2 .and. !range .and. !valid
                    executor = "SCRN"
                    SCRN14 = .T.

                case pic1 .and. pic2 .and. !range .and. !valid
                    executor = "SCRN"
                    SCRN15 = .T.

                case pic1 .and. pic2 .and. range .and. !valid
                    executor = "SCRN"
                    SCRN16 = .T.

                case pic1 .and. pic2 .and. !range .and. valid
                    executor = "SCRN"
                    SCRN17 = .T.

                case !pic1 .and. pic2 .and. !range .and. !valid
                    executor = "SCRN"
                    SCRN19 = .T.

                case !pic1 .and. pic2 .and. range .and. !valid
                    executor = "SCRN"
                    SCRN20 = .T.

                case !pic1 .and. pic2 .and. !range .and. valid
                    executor = "SCRN"
                    SCRN21 = .T.

                otherwise
                    ERRS2 = .T.
            endcase

        case tlbr .and. box
            executor = "SCRN"
            SCRN22 = .T.

        otherwise
            ERRS1 = .T.
    endcase
endif

return

*
** eoproc at


***
* Procedure CALL
* Evaluates stack for CALL verb.
* Sets execution class macro, class execution flag(s) and command line
* substitution macros.
*

procedure call

private stack_ptr, stack_item, xproc, with, params, active, error,;
  item_ok

stack_ptr = 2
store .F. to xproc, with, params, item_ok
active = 1       && 0 = done, 1 = procedure, 2 = WITH toke and params.
error = 0

do while stack_ptr <= max_ptr .and. error = 0

    stack_item = ""
    stack_item = stack[stack_ptr]

    do case
        case active = 0
            error = 2

        case active = 1
            exp1 = stack_item
            xproc = .T.
            stack_ptr = stack_ptr + 1
            if stack_ptr > max_ptr
                active = 0
            else
                active = 2
            endif

        case active = 2
            if upper(stack_item) = "WITH"
                with = .T.
                params = get_list("E")
                if params
                    active = 0
                else
                    error = 2
                endif
            else
                error = 2
            endif
    endcase
enddo

do case
    case error = 2 .or. active <> 0
        ERRS2 = .T.

    case xproc .and. !with .and. !params
        executor = "CALLS"
        CALLS4 = .T.

    case xproc .and. with .and. params
        executor = "CALLS"
        CALLS5 = .T.
endcase

return

*
** eoproc call


***    
* Procedure CLEAR
* Evaluates stack for CLEAR verb.
* Sets execution class macro, class execution flag(s) and command line
* substitution macros.
*

procedure clear

if stack_ptr = 1
    executor = "SCRN"
    SCRN23 = .T.
else
    ERRS2 = .T.
endif

return

*
** eoproc clear


***
* Procedure COLOR
* Evaluates stack for SET COLOR command, called from SET procedure.
* Sets execution class macro, class execution flag(s) and command line
* substitution macros.
*

procedure color

private stack_ptr, to

stack_ptr = 3
to = .F.

if stack_ptr <= max_ptr
    if upper(stack[stack_ptr]) = "TO"
        to = .T.
        stack_ptr = stack_ptr + 1
        do while stack_ptr <= max_ptr         && build up color string.
            exp1 = exp1 + stack[stack_ptr]
            stack_ptr = stack_ptr + 1
        enddo
    endif
endif

if to
    executor = "SETS"
    SETS1 = .T.
else
    ERRS2 = .T.
endif

return

*
** eoproc color


***
* Procedure COPY
* Evaluates stack for COPY verb.
* Simple non-conditional and non-scoped syntax.
* Sets execution class macro, class execution flag(s) and command line
* substitution macros.
*

procedure copy

private stack_ptr, stack_item, item_ok, struc, to, target, active, error

stack_ptr = 2
store .F. to struc, to, target, item_ok
active = 0            && 0 = done, 1 = STRU or TO toke, 2 = target.
error = 0

if error_on .and. !DBF_OPEN
    error = 5
else
    active = 1
endif

do while stack_ptr <= max_ptr .and. error = 0

    stack_item = ""
    item_ok = get_stack("stack_item")

    do case
        case active = 0
            error = 2

        case active = 1
            do case 
                case cmd_abbr(upper(stack_item), "STRUCTURE") .and. !struc
                    struc = .T.
                    active = 1

                case upper(stack_item) == "TO"
                    to = .T.
                    active = 2

                otherwise
                    error = 2
            endcase

        case active = 2
            exp1 = stack_item
            target = .T.
            active = 0
    endcase
enddo

do case
    case error = 2 .or. active <> 0
        ERRS2 = .T.

    case error = 5
        ERRS5 = .T.

    case !struc .and. to .and. target
        executor = "DBF_NTX"
        DBF_NTX28 = .T.

    case struc .and. to .and. target
        executor = "DBF_NTX"
        DBF_NTX29 = .T.

    otherwise
        ERRS2 = .T.
endcase

return

*
** eoproc copy


***
* Procedure CONFIRM
* Evaluates stack for SET CONFIRM command.  Called procedure SET.
* Sets execution class macro, class execution flag(s) and command line
* substitution macros.
*

procedure confirm

private stack_ptr, stack_item, item_ok, toggle

stack_ptr = 3
stack_item = ""
store .F. to item_ok, toggle

item_ok = get_stack("stack_item")

if item_ok .and. upper(stack_item)$"ON^OFF"
    toggle = .T.
else
    error = 2
endif

if toggle
    executor = "SETS"
    SETS2 = .T.
else
    ERRS2 = .T.
endif

return

*
** eoproc confirm


***
* Procedure calls
* Executor for CALLS class of commands.
*

procedure calls

private i, qqq

do case
    case CALLS1
        do &exp1
        CALLS1 = .F.

    case CALLS2
		for i = 0 to 9
			qqq = "list"+str(i,1)
			if (empty(&qqq))
				&qqq = "[]"
			end
		next

        do &exp1 with &list0, &list1, &list2, &list3, &list4, &list5, &list6,;
            &list7, &list8, &list9
        CALLS2 = .F.

    case CALLS3
        run &exp1
        ?
        CALLS3 = .F.

    case CALLS4
        call &exp1
        CALLS4 = .F.

    case CALLS5
		for i = 0 to 9
			qqq = "list"+str(i,1)
			if (empty(&qqq))
				&qqq = "[]"
			end
		next

        call &exp1 with &list0, &list1, &list2, &list3, &list4, &list5, &list6
        CALLS5 = .F.

    case CALLS6
        quit
        CALLS6 = .F.

    case CALLS7
        ** RETURN is not executed at this level **

endcase

return

*
** eoproc calls


***
* Procedure dbf_ntx
* Executor for DBF_NTX class of commands.
*

procedure dbf_ntx

private more, disp_row, i, qqq

do case
    case DBF_NTX1 
        use
        DBF_NTX1 = .F.
        DBF_OPEN = .F.
        NTX_OPEN = .F.

    case DBF_NTX2
        use &dbf_file
        DBF_NTX2 = .F.
        DBF_OPEN = .T.
        NTX_OPEN = .F.

    case DBF_NTX3
        use &dbf_file index &list0, &list1, &list2, &list3, &list4, &list5,;
            &list6, &list7, &list8, &list9
        DBF_NTX3 = .F.
        DBF_OPEN = .T.
        NTX_OPEN = .T.

    case DBF_NTX4
        use &dbf_file alias &exp2
        DBF_NTX4 = .F.
        DBF_OPEN = .T.
        NTX_OPEN = .F.

    case DBF_NTX5
        use &dbf_file index &list0, &list1, &list2, &list3, &list4, &list5,;
            &list6, &list7, &list8, &list9 alias &exp2
        DBF_NTX5 = .F.
        DBF_OPEN = .T.
        NTX_OPEN = .T.

    case DBF_NTX32
        use &dbf_file exclusive
        DBF_NTX32 = .F.
        DBF_OPEN = .T.
        NTX_OPEN = .F.

    case DBF_NTX33
        use &dbf_file index &list0, &list1, &list2, &list3, &list4, &list5,;
            &list6, &list7, &list8, &list9 exclusive
        DBF_NTX33 = .F.
        DBF_OPEN = .T.
        NTX_OPEN = .T.

    case DBF_NTX34
        use &dbf_file alias &exp2 exclusive
        DBF_NTX34 = .F.
        DBF_OPEN = .T.
        NTX_OPEN = .F.

    case DBF_NTX35
        use &dbf_file index &list0, &list1, &list2, &list3, &list4, &list5,;
            &list6, &list7, &list8, &list9 alias &exp2 exclusive
        DBF_NTX35 = .F.
        DBF_OPEN = .T.
        NTX_OPEN = .T.

    case DBF_NTX6
        ? "Indexing file on " + upper(exp1) + " to " + upper(ntx_file)
        index on &exp1 to &ntx_file
        ? "Index file creation complete"
        NTX_OPEN = .T.
        DBF_NTX6 = .F.

    case DBF_NTX7
        goto &exp1
        DBF_NTX7 = .F.

    case DBF_NTX8
        goto top
        DBF_NTX8 = .F.

    case DBF_NTX9
        goto bottom
        DBF_NTX9 = .F.

    case DBF_NTX10
        skip
        if EOF()
            ? "End of file encountered"
        endif
        if BOF()
            ? "Beginning of file encountered"
        endif
        DBF_NTX10 = .F.

    case DBF_NTX11
        skip &exp1
        if EOF()
            ? "End of file encountered"
        endif
        if BOF()
            ? "Beginning of file encountered"
        endif
        DBF_NTX11 = .F.

    case DBF_NTX12
        go top
        do list_do with .T., .F.
        DBF_NTX12 = .F.

    case DBF_NTX13
        go top
		for i = 0 to 9
			qqq = "list"+str(i,1)
			if (empty(&qqq))
				&qqq = "[]"
			end
		next

        list &list0, &list1, &list2, &list3, &list4, &list5, &list6, &list7,;
            &list8, &list9 while inkey() <> 27
        DBF_NTX13 = .F.

    case DBF_NTX14
        do list_do with .T., .T.
        DBF_NTX14 = .F.

    case DBF_NTX15
		for i = 0 to 9
			qqq = "list"+str(i,1)
			if (empty(&qqq))
				&qqq = "[]"
			end
		next

        display &list0, &list1, &list2, &list3, &list4, &list5, &list6,;
            &list7, &list8, &list9
        DBF_NTX15 = .F.

    case DBF_NTX16
        select &exp1
        DBF_NTX16 = .F.

    case DBF_NTX17
        seek &exp1
        if eof()
            ? "NOT Found"
        else
            ? "Found"
        endif
        DBF_NTX17 = .F.

    case DBF_NTX18
        append blank
        DBF_NTX18 = .F.

    case DBF_NTX19
        do do_cnd_scp with "delete_it"  && calls condition/scope logic.
        DBF_NTX19 = .F.

    case DBF_NTX22
        dir &exp1
        DBF_NTX22 = .F.

    case DBF_NTX20
        do do_cnd_scp with "recall_it"  && calls condition/scope logic.
        DBF_NTX20 = .F.

    case DBF_NTX21
        pack
        DBF_NTX21 = .F.

    case DBF_NTX23
        type &exp1
        DBF_NTX23 = .F.

    case DBF_NTX24
        unlock
        DBF_NTX24 = .F.

    case DBF_NTX25
        unlock all
        DBF_NTX25 = .F.

    case DBF_NTX26
        replace &var1 with &exp1
        DBF_NTX26 = .F.

    case DBF_NTX27
        replace all &var1 with &exp1
        DBF_NTX27 = .F.

    case DBF_NTX28
        copy to &exp1
        DBF_NTX28 = .F.

    case DBF_NTX29
        copy structure to &exp1
        DBF_NTX29 = .F.

    case DBF_NTX30
        erase &exp1
        DBF_NTX30 = .F.

    case DBF_NTX31
        append from &exp1
        DBF_NTX31 = .F.

  case DBF_NTX36
     ? "Are you sure? (Y/N)" 
     more = .T.
     disp_row = row()

     do while more
        more = !(ltrim(str(inkey(0),3))$"13^27^78^89^110^121")
        if lastkey() > 31 .and. lastkey() < 127
           @ disp_row, 21 say chr(lastkey()) 
        endif
     enddo

     if upper(chr(lastkey())) = "Y"
        zap
     endif

     DBF_NTX36 = .F.

endcase

return

*
** eoproc dbf_ntx


***
* Procedure DECIMAL
* Evaluates the stack for the SET DECIMALS command.  Called SET procedure.
* Sets execution class macro, class execution flag(s) and command line
* substitution macros.
*

procedure decimal

private stack_ptr, to, null

stack_ptr = 3
to = .F.

if stack_ptr <= max_ptr
    if upper(stack[stack_ptr]) = "TO"
        to = .T.
        null = get_expr1("exp1")
    endif
endif

if to
    executor = "SETS"
    SETS3 = .T.
else
    ERRS2 = .T.
endif

return

*
** eoproc decimal


***
* Procedure DECLARE
* Evaluates the stack for the DECLARE verb.
* Sets execution class macro, class execution flag(s) and command line
* substitution macros.
*

procedure declare

private stack_ptr, string

stack_ptr = 2
string = ""

if get_stack("string")
    open_ptr = at("[",string)
    close_ptr = at("]",string)
    var1 = substr(string, 1, (open_ptr - 1))
    exp1 = substr(string,(open_ptr+1),(close_ptr-open_ptr-1))
    executor = "VARS"
    VARS10 = .T.
else
    ERRS2 = .T.
endif

return

*
** eoproc declare


***
* Procedure DEFAULT
* Evaluates the stack for the SET DEFAULT command.  Called by SET procedure.
* Sets execution class macro, class execution flag(s) and command line
* substitution macros.
*

procedure default

private stack_ptr, to

stack_ptr = 3
store .F. to to, drive

if stack_ptr <= max_ptr
    if upper(stack[stack_ptr]) = "TO"
        to = .T.
        drive = get_expr1("exp1")
    endif
endif

if to .and. drive
    executor = "SETS"
    SETS4 = .T.
else
    ERRS2 = .T.
endif

return

*
** eoproc default


***
* Procedure DELETE
* Analyze the stack for the DELETE verb.
* Sets execution class macro, class execution flag(s) and command line
* substitution macros.
* UDF CND_SCP() used to set condition and scope control variables.
*

procedure delete

private stack_ptr, for, while, next, record, all, stack_item

stack_ptr = 2
store .F. to for, while, next, record, all, condition
scope = 0

if cnd_scp()       && no errors during condition and scope analysis.

    do case
        case for .or. while .or. all .or. next .or. record
            ** w/ w/o scope and/or condition. **
            if DBF_OPEN .or. !error_on
                executor = "DBF_NTX"
                DBF_NTX19 = .T.
            else    
                ERRS5 = .T.
            endif

        case !for .and. !while .and. !all .and. !next .and. !record;
            .and. max_ptr = 1
            ** w/o scope or conditional **
            if DBF_OPEN .or. !error_on
                executor = "DBF_NTX"
                DBF_NTX19 = .T.
                scope = 1     && use RECORD (scope = 1) for single delete.
                exp3 = str(recno())

                if &exp3 > lastrec()
                    ERRS6 = .T.
                    DBF_NTX19 = .F.
                else
                    exp3 = "recno() = &exp3"
                endif
            else
                ERRS5 = .T.
            endif

        otherwise        
            ERRS2 = .T.
    endcase        

endif

return

*
** eoproc delete


***
* Procedure delete_it
* Executes a record delete.  Called by procedure DO_CND_SCP.
*

procedure delete_it

delete

return

*
** eoproc delete_it


***
* Procedure DELIM
* Evaluates stack for SET DELIMITERS command.  Called by procedure
* SET.
* Sets execution class macro, class execution flag(s) and command line
* substitution macros.
*

procedure delim

private stack_ptr, stack_item, to, switch, string, error, active, null

stack_ptr = 3
store .F. to to, switch, string, null
active = 1   && 0 = done, 1 = TO token or toggle, 2 = string/DEFAULT token.
error = 0

do while stack_ptr <= max_ptr .and. error = 0

    stack_item = ""
    null = get_stack("stack_item")

    do case
        case active = 0
            error = 2

        case active = 1
            do case 
                case upper(stack_item) == "TO"
                    to = .T.
                    active = 2

                case upper(stack_item)$"ON^OFF"
                    exp1 = stack_item
                    switch = .T.
                    active = 0

                otherwise
                    error = 2
            endcase

        case active = 2
            exp1 = stack_item
            string = .T.
            active = 0
    endcase
enddo

do case
    case error = 2 .or. active <> 0
        ERRS2 = .T.

    case to .and. string
        executor = "SETS"
        SETS6 = .T.

    case switch
        executor = "SETS"
        SETS5 = .T.
endcase

return

*
** eoproc delim


***
* Procedure DIR
* Sets execution class macro, class execution flag(s) and command line
* substitution macros from the command line not the stack.
*

procedure dir

exp1 = substr(command, len(stack[1]) + 1)

executor = "DBF_NTX"
DBF_NTX22 = .T.

*
** eoproc dir


***
* Procedure DISPLAY
* Evaluates the stack for the DISPLAY verb.
* Sets execution class macro, class execution flag(s) and command line
* substitution macros.
*

procedure display

private stack_ptr

stack_ptr = 1

if DBF_OPEN .or. !error_on
    if max_ptr = 1
        executor = "DBF_NTX"
        DBF_NTX14 = .T.
    else
        if get_list("E")
            executor = "DBF_NTX"
            DBF_NTX15 = .T.
        else
            ERRS2 = .T.
        endif
    endif
else
    ERRS5 = .T.
endif

return

*
** eoproc display


***
* Procedure DO
* Evaluates the stack for the DO verb.
* Sets execution class macro, class execution flag(s) and command line
* substitution macros.
*

procedure do

private stack_ptr, stack_item, item_ok, xproc, with, params, active, error

stack_ptr = 2
store .F. to xproc, with, params, item_ok
active = 1            && 0 = done, 1 = procedure, 2 = WITH toke and params.
error = 0

do while stack_ptr <= max_ptr .and. error = 0

    stack_item = ""
    stack_item = stack[stack_ptr]

    do case
        case active = 0
            error = 2

        case active = 1
            exp1 = stack_item
            xproc = .T.
            stack_ptr = stack_ptr + 1
            if stack_ptr > max_ptr
                active = 0
            else
                active = 2
            endif

        case active = 2
            if upper(stack_item) = "WITH"
                with = .T.
                params = get_list("E")
                if params
                    active = 0
                else
                    error = 2
                endif
            else
                error = 2
            endif
    endcase
enddo

do case
    case error = 2 .or. active <> 0
        ERRS2 = .T.

    case xproc .and. !with .and. !params
        executor = "CALLS"
        CALLS1 = .T.

    case xproc .and. with .and. params
        executor = "CALLS"
        CALLS2 = .T.
endcase

return

*
** eoproc do


***
* Procedure do_cnd_scp
* Executes logic for conditional and scoped commands.  Called by executor
* procedures.  Calls to procedures containing single iterations of command
* being executed.
*

procedure do_cnd_scp

parameters action_proc

private more, count, do_it
more = .T.
count = 0

if rewind_dbf
    go top
endif

do while more .and. !EOF()
    do_it = .F.
     
    if scope > 0                    && handles scoping stuff.
        do case
            case scope = 1          && record.
                if &exp3
                    do_it = .T.
                    more = .F.
                endif

            case scope = 2          && all.
                do_it = .T.

            case scope = 3          && next.
                count = count + 1
                if count <= &exp3
                    do_it = .T.
                else
                    do_it = .F.
                    more = .F.
                endif

        endcase
    endif

    if condition                    && handles conditional stuff.

        if "" <> exp1
            if &exp1                && FOR condition.
                do_it = .T.
            else
                do_it = .F.
            endif
        endif

        if "" <> exp2
            if &exp2                && WHILE condition.
                do_it = .T.
            else
                do_it = .F.
                more = .F.
            endif
        endif
    endif

    if do_it
        do &action_proc             && call single iteration of command.
    endif

    if more
        skip
    endif

enddo

return

*
** eoproc do_cnd_scp


***
* Procedure ERASE
* Sets execution class macro, class execution flag(s) and command line
* substitution macros from the command line.
*

procedure erase

private error

error = 0

exp1 = substr(command, len(stack[1]) + 1)

if !empty(exp1)
    if file(stack_item) .or. !error_on
        exp1 = stack_item
    else
        error = 13
    endif
endif

if error = 13
    ERRS13 = .T.
else
    executor = "DBF_NTX"
    DBF_NTX30 = .T.
endif

return

*
** eoproc erase


***
* Procedure errs
* Executor for the ERRS class of commands, the DOT error message system.
*

procedure errs

do case
    case ERRS1
        ? "Unrecognized command, F1 for Help."
        ERRS1 = .F.

    case ERRS2
        ? "Syntax error, F1 for Help."
        ERRS2 = .F.

    case ERRS3
        ? "Undefined expression."
        ERRS3 = .F.

    case ERRS4
        ? "Undefined variable : "+"&exp1"
        ERRS4 = .F.

    case ERRS5
        ? "Database NOT in use."
        ERRS5 = .F.

    case ERRS6
        ? "Record out of range."
        ERRS6 = .F.

    case ERRS7
        ? "Data file NOT found."
        ERRS7 = .F.

    case ERRS8
        ? "Unbalanced delimiters."
        ERRS8 = .F.

    case ERRS9
        ? "Index file NOT in use"
        ERRS9 = .F.

    case ERRS10
        ? "Not implemented"
        ERRS10 = .F.

    case ERRS11
        ? "Index file NOT found"
        ERRS11 = .F.

    case ERRS12
        ? "Illegal goto value"
        ERRS12 = .F.

    case ERRS13
        ? "File NOT found"
        ERRS13 = .F.

    case ERRS14
        ? "Invalid function key number, 2 - 40"
        ERRS14 = .F.

    case ERRS15
        ? "Missing key word"
        ERRS15 = .F.
endcase

return

*
** eoproc errs


***
* Procedure ESCAPE
* Evaluates stack for the SET ESCAPE command. Called by SET procedure.
* Sets execution class macro, class execution flag(s) and command line
* substitution macros.
*

procedure escape

stack_ptr = 3

if stack_ptr <= max_ptr
    exp1 = upper(stack[stack_ptr])
    if "&exp1"$"ON^OFF"
        executor = "SETS"
        SETS7 = .T.
    else
        ERRS2 = .T.
    endif
else
    ERRS2 = .T.
endif

return

*
** eoproc escape


***
* Procedure EXACT
* Evaluates the stack for SET EXACT command.  Called by SET procedure.
* Sets execution class macro, class execution flag(s) and command line
* substitution macros.
*

procedure exact

stack_ptr = 3

if stack_ptr <= max_ptr
    exp1 = upper(stack[stack_ptr])
    if "&exp1"$"ON^OFF"
        executor = "SETS"
        SETS20 = .T.
    else 
        ERRS2 = .T.
    endif
else
    ERRS2 = .T.
endif

return

*
** eoproc exact


***
* Procedure EXCLUSIVE
* Evaluates the stack for the SET EXCLUSIVE command.  Called from
* procedure SET.
* Sets execution class macro, class execution flag(s) and command
* line substitution macros.
*

procedure exclusive

stack_ptr = 3

if stack_ptr <= max_ptr
    exp1 = upper(stack[stack_ptr])
    if "&exp1"$"ON^OFF"
        executor = "SETS"
        SETS19 = .T.
    else
        ERRS2 = .T.
    endif
else
    ERRS2 = .T.
endif

return

*
** eoproc exclusive


***
* Procedure fill_lists
* Called from procedure DOT.  Fills the verb_list, lex_list, set_list and
* set_proc search strings.
*

procedure fill_lists

verb_list =    "         .!        .?        .??       .@        .ACCEPT   "+;
    ".APPEND   .CLEAR    .CLS      .DECLARE  .DELETE   .DIRECTORY.DISPLAY  "+;
    ".DO       .EXIT     .GO       .GOTO     .INDEX    .INPUT    .LIST     "+;
    ".PACK     .QUIT     .READ     .RECALL   .RELEASE  .RETURN   .RUN      "+;
    ".SEEK     .SELECT   .SET      .SKIP     .TYPE     .USE      .WAIT     "+;
    ".CALL     .UNLOCK   .REPLACE  .COPY     .ERASE    .ZAP      "

lex_list =     "         RUN       QUES1     QUES2     AT        ACCEPT    "+;
    "APPEND    CLEAR     CLEAR     DECLARE   DELETE    DIR       DISPLAY   "+;
    "DO        QUIT      GOTO      GOTO      INDEX     INPUT     LIST      "+;
    "PACK      QUIT      RREAD     RECALL    RELEASE   QUIT      RUN       "+;
    "SEEK      SELECT    SSET      SKIP      TYPE      USE       WWAIT     "+;
    "CALL      UNLOCK    REPLACE   COPY      ERASE     ZAP       "

set_list =      "          .COLOR     .CONFIRM   .DECIMALS  .DEFAULT   "+;
    ".DELIMITERS.EXACT     .ESCAPE    .EXCLUSIVE .FILTER    .FIXED     "+;
    ".FUNCTION  .INDEX     .INTENSITY .KEY       .ORDER     .PATH      "+;
    ".RELATION  .UNIQUE    "

set_proc =      "          COLOR      CONFIRM    DECIMAL    DEFAULT    "+;
    "DELIM      EXACT      ESCAPE     EXCLUSIVE  FILTER     FIXED      "+;
    "FUNC_SET   INDEX_SET  INTENSITY  KEY        ORDER      PATH       "+;
    "RELATE     UNIQUE     "    

return

*
** eoproc fill_lists


***
* Procedure FILTER
* Evaluates the stack for the SET FILTER command.  Called by procedure SET.
* Sets execution class macro, class execution flag(s) and command line
* substitution macros.
*

procedure filter

private stack_ptr, stack_item, to, filter, error

stack_ptr = 3
stack_item = ""
error = 0
store .F. to to, filter

if DBF_OPEN .or. if(error_on, DBF_OPEN, .T.)
    if get_stack("stack_item")
        to = (upper(stack_item) = "TO")
        filter = get_stack("exp1")
    else
        error = 2
    endif
else
    error = 5
endif

do case
    case error = 5
        ERRS5 = .T.

    case error = 2 .or. !to .and. !filter
        ERRS2 = .T.

    case to .and. filter
        executor = "SETS"
        SETS17 = .T.

    case to .and. !filter
        executor = "SETS"
        SETS18 = .T.
endcase

return

*
** eoproc filter


***
* Procedure FIXED
* Evaluates the stack for the SET FIXED command, called by procedure SET.
* Sets execution class macro, class execution flag(s) and command line
* substitution macros.
*

procedure fixed

stack_ptr = 3

if stack_ptr <= max_ptr
    exp1 = upper(stack[stack_ptr])
    if "&exp1"$"ON^OFF"
        executor = "SETS"
        SETS8 = .T.
    else
        ERRS2 = .T.
    endif
else
    ERRS2 = .T.
endif

return

*
** eoproc fixed


***
* Procedure FUNC
* Evaluates the stack for the SET FUNCTION command, called by procedure SET.
* Sets execution class macro, class execution flag(s) and command line
* substitution macros.
*

procedure func_set

private stack_ptr, stack_item, string, to, key, error, active, null

stack_ptr = 3
store .F. to key, to, string, null
error = 0
active = 1  && 0 = error, 1 = function number, 2 = TO token, 3 = string.

do while stack_ptr <= max_ptr

    stack_item = ""
    null = get_stack("stack_item")

    if upper(stack_item) = "TO"
        if active = 2    && expected TO token.
            to = .T.
            active = 3
        else
            error = 2
        endif
    else
        do case
            case active = 0                && unexpected something.
                error = 2

            case active = 1                && expecting key number.
                exp1 = stack_item
                if val(exp1) > 1 .and. val(exp1) < 41
                    key = .T.
                else
                    error = 14
                endif
                active = 2

            case active = 3                && expecting string.
                exp2 = stack_item
                string = .T.
                active = 0
        endcase
    endif
enddo

do case
    case error = 2
        ERRS2 = .T.

    case error = 14
        ERRS14 = .T.

    case key .and. to .and. string
        executor = "SETS"
        SETS9 = .T.

    otherwise
        ERRS2 = .T.
endcase

return

*
** eoproc func


***
* Procedure GOTO
* Evaluates the stack for the GO or GOTO verb.
* Sets execution class macro, class execution flag(s) and command line
* substitution macros.
*

procedure goto

private stack_ptr, stack_item, bottom, top, error

stack_ptr = 2
stack_item = ""
store .F. to bottom, top
error = 0

if DBF_OPEN .or. if(error_on, DBF_OPEN, .T.)  && check for open data file.
    if get_stack("stack_item")                && stack item exists.

        top = (upper(stack_item) == "TOP")
        bottom = cmd_abbr(upper(stack_item), "BOTTOM")

        if !top .and. !bottom

            exp1 = stack_item

            if error_on                       && check legal goto value.
                do case
                    case &exp1 > lastrec()    && too big.
                        error = 6
                        
                    case &exp1 < 0            && too small.
                        error = 12
                endcase
            endif
        endif
    else
        error = 2
    endif
else
    error = 5
endif

do case
    case error = 2
        ERRS2 = .T.

    case error = 5
        ERRS5 = .T.

    case error = 6
        ERRS6 = .T.

    case error = 12
        ERRS12 = .T.

    case !top .and. !bottom
        executor = "DBF_NTX"
        DBF_NTX7 = .T.

    case top
        executor = "DBF_NTX"
        DBF_NTX8 = .T.

    case bottom
        executor = "DBF_NTX"
        DBF_NTX9 = .T.
endcase

return

*
** eoproc goto


***
* Procedure help
* Help for DOT.
*

procedure help

parameters call_proc, line_num, call_var

set key 5 to

if call_proc = "HELP"
    return
endif

row = row()
col = col()

save screen
clear

text
                          Commands supported by DOT

  <F1> - Help
  <>  - History mode.  Up to [max_hist] commands are saved.  After
         [max_hist] commands have been saved, each new command is added
         to the end of the history array and the top command is thrown
         away.
 
         <>     - move backward through commands.
         <>     - move forward through commands.
         <ESC>   - returns without selecting a command.
         <ÄÙ>   - executes the selection.

  @ <row>,<col> 
     [say <exp> [picture <clause>]]
     [get <exp> [picture <clause>] 
     [range <exp, exp>] [valid <exp>]]
     [clear]
  @ t, l, b, r BOX <string>
  ! or RUN <DOS command or file>
  ?  [<exp>]
  ?? [<exp>]
  <var> = <exp>              

endtext

wait "Strike any key for more help, <ESC> to return"

if lastkey() = 27
    set key 5 to history
    clear
    restore screen
    return
endif

clear

text
                          More commands supported by DOT

  accept [<string>] to <memvar>
  append blank
  call <procedure> [with <param1>[,<parameter list>]]
  clear
  cls
  copy [structure] to <filename>
  dir [<drive>][<path>][<skeleton>]
  display [<exp>[,<expression list>]]
  delete [<scope>][FOR/WHILE <expression>].
  do <procedure> [with <param1>[,<parameter list>]]
  erase <file name>.<extension>
  exit
  go[to] <exp>/TOP/BOTTOM
  index on <key expression> to <ntxfile>
  input [<string>] to <var> 
  list [<exp>[,<expression list>]]
  pack
  quit
  read
  recall [<scope>] [FOR/WHILE <expression>].
  release <var>

endtext

wait "Strike any key for more help, <ESC> to return"

if lastkey() = 27
    set key 5 to history
    clear
    restore screen
    return
endif

clear

text
                          More commands supported by DOT

  replace <fieldname> with <expression>
  return            ** Returns to previous level **
  seek <exp>
  select <exp>/<alias>  ** variables not usable **
  set color to <expression>
  set decimals to <expression>
  set default to <drive:>
  set delimiters <ON/OFF>
  set delimiters to [<string>]/[DEFAULT]
  set filter to [<filter expression>]
  set escape <ON/OFF>
  set exact <ON/OFF>
  set exclusive <ON/OFF>
  set fixed <ON/OFF>
  set function <function key number> to <string>
  set intensity <ON/OFF>
  set index to [<ntxfile>[,<ntxlist>]]]
  set key <ascii key number> to <string>
  set path to [<path expression>]
  set order to [<expN>]
  set relation to [<key expression> into <alias>]

endtext

wait "Strike any key for more help, <ESC> to return"

if lastkey() = 27
    set key 5 to history
    clear
    restore screen
    return
endif

clear

text
                          More commands supported by DOT

  skip [<exp>]
  type <file name>.<extension>
  unlock [ALL]
  use [<filename> [index <ntxfile>[,<ntxlist>]]][alias <alias name>]
      exclusive
  wait [[<string>][to <var>]]
  zap

                                   Comments

  1. Command MUST be entered as shown in HELP or error may be generated.
  2. Lists can contain up to 10 items. CALL or DO use up to 7 items.
  3. The SET FUNCTION command does not allow [F1] to be reset.
     Range [2] to [40]
  4. The SET KEY command does not allow [28] and [24] keys to be reset.
     Range [-39] to [387].
  5. The SET KEY command overrides the SET FUNCTION key.
  6. SET KEY should ONLY be used with VALID procedure names.
  7. If a GET is pending, DO NOT use History [] to execute a READ or
     the GET will be cleared.

endtext

wait "Strike any key for more help, <ESC> to return"

if lastkey() = 27
    set key 5 to history
    clear
    restore screen
    return
endif

clear

text
                                   Comments

  8. FOR and WHILE are NON-exclusive phrases.  WHILE takes precedence.
  9. When more than one scoping key word is present, control will be
     given to the last key word in the command line.
 10. Input and Display sections can use different I/O environments when
     SETs are issued.  See main DOT procedure.
 11. SAFETY is NOT on, BE FOREWARNED.
 12. Macros are expanded before being placed on stack so DOT may behave
     differently than a Clipper program with macros.


                              Flow Chart

  The next page contains a simple flow chart of the internal structure of
  the DOT test utility.  Upper case words represent the names of
  PROCEDURES called by the main DOT procedure.  Several macros are used
  to call procedures that will vary based on the contents of the stack.
  These cases are noted as such and do not use the upper case convention.

endtext

wait "Strike any key for more help, <ESC> to return"

if lastkey() = 27
    set key 5 to history
    clear
    restore screen
    return
endif

clear
text
DOTÄÄÄÄ>ÄÄÄÄÄÄ (initialize flags, execution and control variables)
                   
               FILL_LIST    ** initialize search string variables.
                   
  ÚÄÄÄÄÄ>ÄÄÄÄÄ (initialize stack array) 
  ³                
  ³             INPUT_LN    ** put cursor at bottom of screen.
  ³                
  ³             (input)     ** accept the command line from the console.
  ³                
  ³             INPUT_LN    ** return to display portion of screen.
  ³                
                PARSE      ** place components of command line on stack.
  ³                
  ³             SET_LEX     ** set analysis procedure macro "lex_proc".
  ³                
  ³            (analyze)    ** do analyze procedure macro "lex_proc".
  ³                
  ³             HIST_PUT    ** put command into history array.
  ³                
  ³            (execute)    ** do execution procedure macro "executor".
  ³                
  ÀÄÄÄÄÄ<ÄÄÄÄÄ (reset command line substitution macro variables)
endtext

wait "Strike any key for more help, <ESC> to return"

if lastkey() = 27
    set key 5 to history
    clear
    restore screen
    return
endif

clear
text
                             DOT assistance programs

  what_key   : Returns the numeric value of a key. <ALT-Q> aborts.
  hist_purge : Empties the history array.
  set_sets   : Reset all the SET commands listed to their DEFAULT
               setting.

                           Internal Control Variables

  bottom_on = .T.  -  Places the input window at the bottom of the screen.
  error_on  = .T.  -  Checks for DBF, NTX ON/OFF or existence.
  max_hist  = 20   -  Maximum number of history item stored before
                      overwrites of earlier 'saved' commands starts.

endtext

wait "Strike any key to continue."

clear

set key 5 to history
restore screen
return

*
** eoproc help


***
* Procedure hist_purge
* Purges the history array.
*

procedure hist_purge

do while hist_max > 0
    history[hist_max] = ""
    hist_max = hist_max - 1
enddo
hist_ptr = 0

return

*
** eoproc hist_purge


***
* Procedure hist_put
* Stores command into the history array
*

procedure hist_put

if hist_max < max_hist
    hist_max = hist_max + 1
else 
    for i = 2 to max_hist 
        history[i-1] = history[i]
    next
endif

history[hist_max] = command

return

*
** eoproc hist_put


***
* Procedure history
* Allows user to select from the list of history'd commands.
*

procedure history

parameters call_proc, call_line, call_var

private key, hist_ptr, curr_row, curr_col, cmd_line

if hist_max > 0 .and. call_proc <> "HISTORY"

    set intensity on
    clear gets

    key = 0
    hist_ptr = hist_max
    curr_row = row()
    curr_col = col()

    set key 5 to stuff_up
    set key 24 to stuff_dn

    do while .T.
        cmd_line = history[hist_ptr] + space(77 - len(history[hist_ptr]))
        @ curr_row, curr_col get cmd_line
        read

        key = lastkey()

        do case
            case key = 5
                ** up-arrow, backwards **
                hist_ptr = hist_ptr - 1
                if hist_ptr <= 0
                    hist_ptr = hist_max
                endif
    
            case key = 24
                ** down-arrow, forward **
                hist_ptr = hist_ptr + 1
                if hist_ptr > hist_max
                    hist_ptr = 1
                endif

            case key = 13 .or. key = 27
                if key = 13
                    keyboard trim(cmd_line) + chr(13)
                endif
                @ curr_row, curr_col
                set intensity &inten_stat
                set key 5 to history
                set key 24 to
                return
        endcase
    enddo
endif

*
** eoproc history


***
* Procedure INDEX
* Evaluates the stack for the INDEX verb.
* Sets execution class macro, class execution flag(s) and command line
* substitution macros.
*

procedure index

private stack_ptr, stack_item, item_ok, on, to, key, file, active, error

stack_ptr = 2
store .F. to on, to, key, file
active = 1    && 0 = error, 1 = key, 2 = file.
error = 0

if error_on .and. !DBF_OPEN  && if file checking is on and file is not open.
    error = 5
endif

do while stack_ptr <= max_ptr .and. error = 0
    stack_item = ""
    item_ok = get_stack("stack_item")

    do case
        case upper(stack_item) = "ON" .and. !on
            on = .T.
            active = 1

        case upper(stack_item) = "TO" .and. !to
            to = .T.
            active = 2

        otherwise
            do case
                case active = 1
                    key = .T.
                    exp1 = stack_item
                    if !file
                        active = 2
                    else
                        active = 0
                    endif

                case active = 2
                    file = .T.
                    ntx_file = stack_item
                    if !key
                        active = 1
                    else
                        active = 0
                    endif

                otherwise
                    error = 2
            endcase
    endcase
enddo

do case
    case error = 2
        ERRS2 = .T.

    case error = 5
        ERRS5 = .T.
    
    case on .and. to .and. key .and. file
        executor = "DBF_NTX"
        DBF_NTX6 = .T.

    otherwise
        ERRS2 = .T.
endcase

return

*
** eoproc index


***
* Procedure INDEX_set
* Evaluates stack for SET INDEX TO command.  Called by procedure SET.
* Sets execution class macro, class execution flag(s) and command line
* substitution macros.
*

procedure index_set

private stack_ptr, stack_item, item_ok, to, file, error

stack_ptr = 3
stack_item = ""
store .F. to item_ok, to, file
error = 0

if error_on .and. !DBF_OPEN        && check for open data file.
    error = 5
else
    stack_item = stack[stack_ptr]

    if (upper(stack_item) == "TO")
        to = .T.
        file = get_list("NF")

        if !file                   && error occurred in building list.
            if empty(list0)        && list is empty, turn indexes off.
                file = .T.
            else                   && index file not found.
                error = 11
            endif
        endif
    else
        error = 2
    endif
endif

do case
    case error = 2
        ERRS2 = .T.

    case error = 5
        ERRS5 = .T.

    case error = 11
        ERRS11 = .T.

    case to .and. file
        executor = "SETS"
        SETS10 = .T.
endcase

return

*
** eoproc index_set


***
* Procedure INPUT
* Evaluates stack for INPUT verb.
* Sets execution class macro, class execution flag(s) and command line
* substitution macros.
*

procedure input

private stack_ptr, string, to, dest, stack_item

stack_ptr = 1
store .F. to string, to, dest

do while stack_ptr <= max_ptr
    stack_item = upper(stack[stack_ptr])
    do case
        case stack_item = "INPU"
            string = get_expr1("exp1")
            if upper(exp1) = "TO"
                string = .F.
                exp1 = ""
                stack_ptr = stack_ptr - 1
            endif

        case stack_item = "TO"
            to = .T.
            dest = get_expr1("var1")
        otherwise
            stack_ptr = stack_ptr + 1
    endcase
enddo

if !err()
    do case
        case to .and. dest .and. !string
            executor = "VARS"
            VARS3 = .T.
            VARS9 = .T.

        case to .and. dest .and. string
            executor = "VARS"
            VARS4 = .T.
            VARS9 = .T.

        otherwise
            ERRS2 = .T.
    endcase
endif

return

*
** eoproc input


***
* Procedure input_ln
* Places the input line on the bottom of screen and manages the
* placement of the end of output diamond.
*

procedure input_ln

parameters when

if when = "B"
    save_row = row()
    save_col = col()

    ?? chr(4)                && display cursor position marker.

    @ MaxRow(), 0 say ""

    do while (save_row > MaxRow()-2)
        ?
        save_row = save_row - 1
    enddo

    @ MaxRow()-1, 0 clear
    @ MaxRow()-1, 0 say cmd_line
    @ MaxRow()-1, 0 say ""
else
    @ MaxRow()-1, 0 clear
    @ save_row, save_col say " "
    @ save_row, save_col say ""
endif

return

*
** eoproc input_ln


***
* Procedure INTENSITY
* Evaluates the stack for the SET INTENSITY command.  Called by the 
* SET procedure.
* Sets execution class macro, class execution flag(s) and command line
* substitution macros.
*

procedure intensity

stack_ptr = 2

if get_expr1("exp1")
    if exp1$"ON^OFF"
        executor = "SETS"
        SETS11 = .T.
    else
        ERRS2 = .T.
    endif
else
    ERRS2 = .T.
endif

return

*
** eoproc intensity


***
* Procedure KEY
* Evaluates the stack for the SET KEY command.  Called from procedure
* SET.
* Sets execution class macro, class execution flag(s) and command line
* substitution macros.
* Does not allow [F1] or [] to be reset.
*

procedure key

private stack_ptr, string, to, key, null, stack_item

stack_ptr = 2
store .F. to key, to, null

do while stack_ptr <= max_ptr
    stack_item = upper(stack[stack_ptr])
    do case
        case stack_item = "KEY"
            key = get_expr1("exp1")
            if key .and. val(exp1) > -40 .and. val(exp1) < 388;
                .and. val(exp1) <> 28 .and. val(exp1) <> 24
                key = .T.
            endif

        case stack_item = "TO"
            to = .T.
            null = get_expr1("exp2")

        otherwise
            stack_ptr = stack_ptr + 1
    endcase
enddo

if !err()
    if key .and. to
        executor = "SETS"
        SETS14 = .T.
    else
        ERRS2 = .T.
    endif
endif

return

*
** eoproc key


***
* Procedure LIST
* Evaluates stack for the LIST verb.
* Sets execution class macro, class execution flag(s) and command line
* substitution macros.
*

procedure list

private stack_ptr

stack_ptr = 1

if DBF_OPEN .or. !error_on
    if max_ptr = 1
        executor = "DBF_NTX"
        DBF_NTX12 = .T.
    else
        if get_list("E")
            executor = "DBF_NTX"
            DBF_NTX13 = .T.
        else
            ERRS2 = .T.
        endif
    endif
else
    ERRS5 = .T.
endif

return

*
** eoproc list


***
* Procedure list_do
* Emulates the LIST/DISPLAY command, called LIST executor.
*
* Usage : list_do <logical 1>, <logical 2>
* Where :    <logical 1> = record number display flag.
*         :    <logical 2> = LIST/DISPLAY flag. .T. = DISPLAY mode
*

procedure list_do

parameters recno_on, is_display

private disp_count, count, header, l_part1, l_part2, l_part3, use_part2,;
    use_part3

if recno_on
    header = "[Record#  "
    l_part1 = "str(recno(),7)+space(2)"
else
    header = "["
    l_part1 = "space(0)"
endif

l_part2 = "space(0)"
l_part3 = "space(0)"

use_part2 = .F.
use_part3 = .F.

count = 1

do while "" <> fieldname(count)
    header = header + spacer_h(fieldname(count))
    if len(l_part1) < 150
        l_part1 = l_part1 + "+" + fld_form(fieldname(count)) + "+space(" +;
            spacer_l(fieldname(count)) + ")"
    else
        if len(l_part2) < 150
            l_part2 = l_part2 + "+" + fld_form(fieldname(count)) + "+space(" +;
                spacer_l(fieldname(count)) + ")"
        else
            l_part3 = l_part3 + "+" + fld_form(fieldname(count)) + "+space(" +;
                spacer_l(fieldname(count)) + ")"
        endif
    endif
    count = count + 1
enddo

header = header + "]"

use_part2 = !empty(&l_part2)
use_part3 = !empty(&l_part3)

? &header

if !eof()
    for i = 1 to if(!is_display, lastrec(), 1)
        ? &l_part1

        if use_part2
            ?? &l_part2
            if use_part3
                ?? &l_part3
            endif
        endif

        if !is_display
            skip
        endif

        if inkey() = 27
            return        
        endif
    next
endif

return

*
** eoproc list_do


***
* Procedure ORDER
* Evaluates stack for the SET ORDER command. Called from SET procedure.
* Sets execution class macro, class execution flag(s) and command line
* substitution macros.
*

procedure order

private stack_ptr, stack_item, to, exp, null

stack_ptr = 3

store .F. to to, exp, null

do while stack_ptr <= max_ptr
    stack_item = ""
    null = get_stack("stack_item")

    if upper(stack_item) = "TO" .and. !to
        to = .T.
    else
        exp1 = stack_item
        exp = .T.
    endif
enddo

do case
    case !(DBF_OPEN) .and. error_on
        ERRS5 = .T.

    case !(NTX_OPEN) .and. error_on
        ERRS9 = .T.

    case to .and. exp
        executor = "SETS"
        SETS21 = .T.

    case to .and. !exp
        executor = "SETS"
        SETS22 = .T.
    
    otherwise
        ERRS2 = .T.

endcase

return

*
** eoproc order


***
* Procedure PACK
* Evaluates the stack for PACK verb.
* Sets execution class macro, class execution flag(s) and command line
* substitution macros.
*

procedure pack

if max_ptr = 1
    if DBF_OPEN .or. !error_on
        executor = "DBF_NTX"
        DBF_NTX21 = .T.
    else
        ERRS5 = .T.
    endif
else
    ERRS2 = .T.
endif

return

*
** eoproc pack


***
* Procedure parse
* breaks command line into tokens and populates stack.
*

procedure parse

parameters stack_max

private line_len, scan_ptr, parse_more, tokens, collect_it, scan_char,;
    next_char, inc_before, inc_after, start_char, stop_char, item_count,;
    more_char

command = trim(ltrim(command))

if !empty(command)
    line_len = len(command)
    scan_ptr = 1
    parse_more = .T.
    tokens = " +-*/%<>#,!@.$^?=[()]'" + ["]
    stack_ptr = 1
    stack[1] = ""
    collect_it = .F.
    inc_before = .F.
    inc_after = .F.
else
    parse_more = .F.
endif

do while parse_more

    scan_char = substr(command, scan_ptr, 1)

    do case
        case !scan_char$tokens .and. "" <> scan_char
            ** if the scan character is NOT one of the parsed characters **
            collect_it = .T.

        case "" = scan_char
            ** if scan character is NULL, stop the parser. **
            parse_more = .F.

        case scan_char = " "
            ** if the scan character is a blank, check if stack element is **
            ** empty. If not, set the pre-collection stack increment flag **
            ** to true.                                                     ** 

            if "" <> stack[stack_ptr]
                inc_before = .T.
            endif

        case scan_char$"+-*/%<>#,!@.$^?="
            ** If the scan character is one of the parsed elements set the **
            ** collector flag true, initialize the next character variable, **
            ** and check if either the pre or post collection flags need to **
            ** be set.                                                        **

            collect_it = .T.

            if stack[stack_ptr] <> scan_char
                if "" <> stack[stack_ptr]
                    inc_before = .T.
                endif
            endif

            next_char = if((scan_ptr+1) <= line_len,;
                substr(command, scan_ptr+1, 1), "")
            if !next_char$tokens .and. "" <> next_char
                inc_after = .T.
            endif

        case scan_char$"[('" .or. scan_char = ["]
            ** if the scan character is a string delimiter or a **
            ** grouping operator, check for any empty stack element **
            ** then check for balanced delimiters or groupers. **

            if "" <> stack[stack_ptr]
                stack_ptr = stack_ptr + 1
                stack[stack_ptr] = ""
            endif

            start_char = scan_char

            if scan_char = "("
                stop_char = ")"
            else
                if scan_char = "["
                    stop_char = "]"
                else
                    stop_char = scan_char
                endif
            endif

            item_count = 0
            more_char = .T.

            do while more_char            
                stack[stack_ptr] = stack[stack_ptr] + scan_char

                if start_char <> stop_char
                    if scan_char = start_char
                        item_count = item_count + 1
                    else
                        if scan_char = stop_char
                            item_count = item_count - 1
                        endif
                    endif
                else
                    if item_count > 0
                        if scan_char = stop_char
                            item_count = item_count - 1
                        endif
                    else
                        item_count = 1
                    endif
                endif

                if item_count = 0 .or. "" = scan_char
                    more_char = .F.
                else
                    scan_ptr = scan_ptr + 1
                    scan_char = substr(command, scan_ptr, 1)
                endif
            enddo
            
            if scan_ptr > line_len
                ERRS8 = .T.
            else
                next_char = substr(command, scan_ptr + 1,1)
                if !next_char$tokens .and. "" <> next_char
                    inc_after = .T.
                endif
            endif

    endcase
     
    if inc_before
        stack_ptr = stack_ptr + 1
        stack[stack_ptr] = ""
        inc_before = .F.
    endif

    if collect_it                    && add current char to stack.
        stack[stack_ptr] = stack[stack_ptr] + scan_char
        collect_it = .F.
    endif

    if inc_after                     && increment after adding char.
        stack_ptr = stack_ptr + 1
        stack[stack_ptr] = ""
        inc_after = .F.
    endif

    scan_ptr = scan_ptr + 1

enddo

return

*
** eoproc parse


***
* Procedure PATH
* Evaluates stack for SET PATH command.  Called from SET procedure.
* Sets execution class macro, class execution flag(s) and command line
* substitution macros.
*

procedure path

private stack_ptr, to, null

stack_ptr = 3
store .F. to to, null

if upper(stack[stack_ptr]) = "TO"
    to = .T.
    null = get_expr1("exp1")
endif

if to
    executor = "SETS"
    SETS12 = .T.
else
    ERRS2 = .T.
endif

return

*
** eoproc path


***
* Procedure ques1
* Evaluates stack for single question mark (?).
* Sets execution class macro, class execution flag(s) and command line
* substitution macros.
*

procedure ques1

private stack_ptr

stack_ptr = 2

if get_stack("exp1")
    executor = "SCRN"
    SCRN25 = .T.
else
    executor = "SCRN"
    SCRN24 = .T.
endif

return 

*
** eoproc ques1
    

***
* Procedure ques2
* Evaluates stack for double question marks (??).
* Sets execution class macro, class execution flag(s) and command line
* substitution macros.
*

procedure ques2

private stack_ptr

stack_ptr = 1

if get_expr1("exp1")
    executor = "SCRN"
    SCRN27 = .T.
else
    executor = "SCRN"
    SCRN26 = .T.
endif

return 

*
** eoproc ques2


***
* Procedure QUIT
* called from analyze, analyzes the stack for the QUIT, EXIT or
* RETURN verb.
*

procedure quit

if max_ptr = 1
    executor = "CALLS"
    if stack[1]$"QUIT EXIT"
        CALLS6 = .T.
    else
        CALLS7 = .T.
    endif
else
    ERRS2 = .T.
endif

return

*
** eoproc quit


***
* Procedure rREAD
* Evaluates stack for READ verb. 
* Sets execution class macro, class execution flag(s) and command line
* substitution macros.
*

procedure rread

executor = "SCRN"
SCRN28 = .T.

return

*
** eoproc rread


***
* Procedure RECALL
* Evaluates the stack for RECALL verb.  Calls the condition and
* scope analyzer CND_SCP to set condition and scope flags and
* expressions.
* Sets execution class macro, class execution flag(s) and command line
* substitution macros.
*

procedure recall

private stack_ptr, for, while, next, record, all, stack_item

stack_ptr = 2
store .F. to for, while, next, record, all, condition
scope = 0

if cnd_scp()    && no errors during generic condition and scope analysis.
    do case 
        case for .or. while .or. all .or. next .or. record
            ** w/ w/o scope and/or condition. **
            if DBF_OPEN .or. !error_on
                executor = "DBF_NTX"
                DBF_NTX20 = .T.
            else    
                ERRS5 = .T.
            endif

        case !for .and. !while .and. !all .and. !next .and. !record;
            .and. max_ptr = 1
            ** w/o scope or conditional **
            if DBF_OPEN .or. !error_on
                executor = "DBF_NTX"
                DBF_NTX20 = .T.
                scope = 1       && use RECORD (scope = 1) for single recall.
                exp3 = str(recno())

                if &exp3 > lastrec() .and. error_on
                    ERRS6 = .T.
                    DBF_NTX20 = .F.
                else
                    exp3 = "recno() = &exp3"
                endif
            else
                ERRS5 = .T.
            endif

        otherwise        
            ERRS2 = .T.
    endcase        
endif

return

*
** eoproc recall


***
* Procedure recall_it
* Called by do_cnd_scp called from DBF_NTX execution procedure.
*

procedure recall_it

recall

return

*
** eoproc recall_it


***
* Procedure RELATE
* Evaluates stack for SET RELATION command.  Called from SET procedure.
* Sets execution class macro, class execution flag(s) and command line
* substitution macros.
*

procedure relate

private stack_ptr, to, exp, alias, stack_item

stack_ptr = 3
store .F. to to, exp, alias

do while stack_ptr <= max_ptr
    stack_item = upper(stack[stack_ptr])
    do case
        case stack_item = "TO"
            to = .T.
            exp = get_expr1("exp1")

        case stack_item = "INTO"
            alias = get_expr1("exp2")

        otherwise
            stack_ptr = stack_ptr + 1
    endcase
enddo

if !err()
    do case
        case to .and. exp .and. alias .and. if(error_on, DBF_OPEN, .T.)
            executor = "SETS"
            SETS16 = .T.

        case to .and. !exp .and. !alias .and. if(error_on, DBF_OPEN, .T.)
            executor = "SETS"
            SETS15 = .T.

        case if(error_on, !DBF_OPEN, .F.)
            ERRS5 = .T.

        otherwise
            ERRS2 = .T.
    endcase
endif

return

*
** eoproc relate


***
* Procedure RELEASE
* Evaluates stack for the RELEASE verb.
* Sets execution class macro, class execution flag(s) and command line
* substitution macros.
*

procedure release

private stack_ptr

stack_ptr = 2

if max_ptr = 2
    var1 = stack[stack_ptr]
    if type("&var1") <> "U"
        executor = "VARS"
        VARS11 = .T.
    else
        ERRS3 = .T.
    endif
else
    ERRS2 = .T.
endif

return

*
** eoproc release


***
* Procedure REPLACE
* Evaluates stack for the REPLACE command.
* Sets execution class macro, class execution flag(s) and command line
* substitution macros.
*

procedure replace

private stack_ptr, stack_item, dest, with, source, all, null

stack_ptr = 2
store .F. to dest, with, source, all

do while stack_ptr <= max_ptr

    stack_item = ""
    null = get_stack("stack_item")

    do case
        case upper(stack_item) = "ALL"
            all = .T.

        case upper(stack_item) = "WITH"
            with = .T.

        otherwise
            if "" == var1
                var1 = stack_item
                dest = .T.
            else
                exp1 = stack_item
                source = .T.
            endif
    endcase
enddo

do case
    case !DBF_OPEN .and. error_on
        ERRS5 = .T.

    case dest .and. with .and. source .and. !all
        executor = "DBF_NTX"
        DBF_NTX26 = .T.

    case dest .and. with .and. source .and. all
        executor = "DBF_NTX"
        DBF_NTX27 = .T.

    otherwise
        ERRS2 = .T.
endcase

return

*
** eoproc replace


***
* Procedure RUN
* Evaluates stack for the RUN or ! verb.
* Sets execution class macro, class execution flag(s) and command line
* substitution macros.
*

procedure run

exp1 = substr(command, len(stack[1]) + 1)

if !empty(exp1)
    executor = "CALLS"
    CALLS3 = .T.
else
    ERRS2 = .T.
endif

return

*
** eoproc run


***
* Procedure SEEK
* Evaluates stack for the SEEK verb.
* Sets execution class macro, class execution flag(s) and command line
* substitution macros.
*

procedure seek

private stack_ptr

stack_ptr = 1

if DBF_OPEN .or. !error_on
    if NTX_OPEN .or. !error_on
        if get_expr1("exp1")
            executor = "DBF_NTX"
            DBF_NTX17 = .T.
        else
            ERRS2 = .T.
        endif
    else
        ERRS9 = .T.
    endif
else
    ERRS5 = .T.
endif

return

*
** eoproc seek


***
* Procedure SELECT
* Evaluates stack for the SELECT verb.
* Sets execution class macro, class execution flag(s) and command line
* substitution macros.
*

procedure select

private stack_ptr, select, expr_type

stack_ptr = 1
select = .F.
expr_type = ""

if get_expr1("exp1")
	if select(exp1) > 0
	    select = .T.
	else
		expr_type = type(exp1)

		if expr_type = "N"
			if val(exp1) <= 250 .and. val(exp1) >= 0
				select = .T.
			endif
        endif
	endif
endif

if select
    executor = "DBF_NTX"
    DBF_NTX16 = .T.
else
    ERRS2 = .T.
endif

return

*
** eoproc select


***
* Procedure SSET
* Evaluates the next key word in SET command.  Checks abbreviation of
* key word.  Key ok, [do_sets] procedure macro is set.  Key fail or not
* found, set unknown command error flag ERRS1.
*

procedure sset

private stack_ptr, seek_strng, position, do_sets, error

stack_ptr = 2
do_sets = ""
error = 0

seek_strng = upper(stack[stack_ptr])
position = at("." + seek_strng, set_list)

if position > 0
    if cmd_abbr(seek_strng, trim(substr(set_list, (position + 1), 10)))
        do_sets = substr(set_proc, position, 10)
    else
        error = 1
    endif
else
    error = 1
endif

if error = 1
    ERRS1 = .T.
else
    do &do_sets
endif

return

*
** eoproc set


***
* Procedure sets
* executes the SETS class of commands
*

procedure sets

do case
    case SETS1
        set color to &exp1
        color_stat = exp1
        SETS1 = .F.

    case SETS2
        set confirm &exp1
        confr_stat = exp1
        SETS2 = .F.

    case SETS3
        set decimal to &exp1
        SETS3 = .F.

    case SETS4
        set default to &exp1
        SETS4 = .F.

    case SETS5
        set delimiters &exp1
        delim_stat = exp1
        SETS5 = .F.

    case SETS6
        set delimiters to &exp1
        SETS6 = .F.

    case SETS7
        set escape &exp1
        SETS7 = .F.

    case SETS8
        set fixed &exp1
        SETS8 = .F.

    case SETS9
        set function &exp1 to &exp2
        SETS9 = .F.

    case SETS10
        set index to &list0, &list1, &list2, &list3, &list4, &list5,;
            &list6, &list7, &list8, &list9
        SETS10 = .F.

        if empty(list0)
            NTX_OPEN = .F.
        else
            NTX_OPEN = .T.
        endif

    case SETS11
        set intensity &exp1
        inten_stat = exp1
        SETS11 = .F.

    case SETS12
        set path to &exp1
        SETS12 = .F.

    case SETS13
        set unique &exp1
        SETS13 = .F.

    case SETS14
* CAUTION:  5.0 A31
*        set key &exp1 to &exp2
        SETS14 = .F.

    case SETS15
        set relation to
        SETS15 = .F.

    case SETS16
        relation = exp1
        alias = exp2
        set relation to &relation into &alias
        SETS16 = .F.

    case SETS17
        filter = exp1
        set filter to &filter
        SETS17 = .F.

    case SETS18
        filter = ""
        set filter to
        SETS18 = .F.

    case SETS19
        set exclusive &exp1
        SETS19 = .F.

    case SETS20
        set exact &exp1
        exact_stat = exp1
        SETS20 = .F.

    case SETS21
        set order to &exp1
        SETS21 = .F.

    case SETS22
        set order to
        SETS22 = .F.
endcase

return

*
** eoproc sets


***
* Procedure set_lex
* Locates the verb in verb_list string and initializes "lex_proc" macro with 
* the corresponding procedure name found in the lex_list string.
* Calls CMD_ABBR().
*

procedure set_lex

private seek_strng, verb_string, position

if assign_chk()
    lex_proc = "ASSIGN"
else
    seek_strng = upper(stack[1])
    position = at("." + seek_strng, verb_list)
    if position > 0
        verb_string = trim(substr(verb_list, position + 1, 9))
        if cmd_abbr(seek_strng, verb_string)
            lex_proc = substr(lex_list, position, 10)
        else
            lex_proc = "UNKNOWN"
        endif
    else
        lex_proc = "UNKNOWN"
    endif
endif

return

*
** eoproc set_lex


***
* Procedure set_sets
* Called from interactive prompt.  Resets the SET commands to their
* DEFAULT settings.
*

procedure set_sets

set alternate OFF
set alternate to
set bell OFF
set color to
set confirm OFF
set console ON
set decimal to 2
set default to
set deleted OFF
set delimiters OFF
set delimiters to
set device to SCREEN
set escape ON
set exact OFF
set exclusive ON
set filter to
set fixed OFF
set format to

for i = 2 to 40
    set function i to ""
next

set index to
set intensity ON

for i = -39 to 387
*    set key i to ""
* CAUTION:  5.0 A31  (this was illegal anyway)
    set key i to
next

set order to 1
set print OFF
set path to
set relation to
set scoreboard ON
set unique OFF

inten_stat = "ON"
color_stat = "7/0"
delim_stat = "OFF"
confr_stat = "OFF"
exact_stat = "OFF"

return

*
** eoproc set_sets


***
* Procedure SKIP
* Evaluates stack for SKIP verb.
* Sets execution class macro, class execution flag(s) and command line
* substitution macros.
*

procedure skip

private stack_ptr

stack_ptr = 1
        
if DBF_OPEN .or. !error_on
    if get_expr1("exp1")
        if is_n_expr(&exp1)
            if if(error_on, &exp1 <= lastrec(), .T.)
                executor = "DBF_NTX"
                DBF_NTX11 = .T.
            else
                ERRS6 = .T.
            endif
        else
            ERRS3 = .T.
        endif
    else
        executor = "DBF_NTX"
        DBF_NTX10 = .T.
    endif
else
    ERRS5 = .T.
endif

return

*
** eoproc skip


***
* Procedure stuff_up
* Clears the get list when an up-arrow is depressed.
* Called from HISTORY procedure. 
*

procedure stuff_up

parameters call_proc, call_line, call_var

if call_proc <> "STUFF_UP"
    clear gets
endif

return

*
** eoproc stuff_up


***
* Procedure stuff_dn
* Clears the get list when a down-arrow is depressed.
* Called from HISTORY procedure.

procedure stuff_dn

parameters call_proc, call_line, call_var

if call_proc <> "STUFF_DN"
    clear gets
endif

return

*
** eoproc stuff_dn


***
* Procedure scrn
* executes the SCRN class commands
*

procedure scrn

do case
    case SCRN1
        @ &coord1, &coord2    
        SCRN1 = .F.

    case SCRN2
        @ &coord1, &coord2 clear
        SCRN2 = .F.

    case SCRN3
        @ &coord1, &coord2 say &say_exp
        SCRN3 = .F.

    case SCRN4
        @ &coord1, &coord2 say &say_exp picture &say_pict
        SCRN4 = .F.

    case SCRN5
        @ &coord1, &coord2 get &get_exp
        SCRN5 = .F.

    case SCRN6
        @ &coord1, &coord2 get &get_exp picture &get_pict
        SCRN6 = .F.

    case SCRN7
        range1 = rng_exp1
        range2 = rng_exp2
        @ &coord1, &coord2 get &get_exp range &range1, &range2
        SCRN7 = .F.

    case SCRN8
        @ &coord1, &coord2 get &get_exp valid &valid_exp
        SCRN8 = .F.

    case SCRN10
        @ &coord1, &coord2 get &get_exp picture &get_pict valid &valid_exp
        SCRN10 = .F.

    case SCRN11
        range1 = rng_exp1
        range2 = rng_exp2
        @ &coord1, &coord2 get &get_exp picture &get_pict range &range1,;
            &range2
        SCRN11 = .F.

    case SCRN13
        @ &coord1, &coord2 say &say_exp get &get_exp
        SCRN13 = .F.

    case SCRN14
        @ &coord1, &coord2 say &say_exp picture &say_pict get &get_exp
        SCRN14 = .F.

    case SCRN15
        @ &coord1, &coord2 say &say_exp picture &say_pict get &get_exp;
            picture &get_pict
        SCRN15 = .F.

    case SCRN16
        range1 = rng_exp1
        range2 = rng_exp2
        @ &coord1, &coord2 say &say_exp picture &say_pict get &get_exp;
            picture &get_pict range &range1, &range2
        SCRN16 = .F.

    case SCRN17
        @ &coord1, &coord2 say &say_exp picture &say_pict get &get_exp;
            picture &get_pict valid &valid_exp
        SCRN17 = .F.

    case SCRN19
        @ &coord1, &coord2 say &say_exp get &get_exp picture &get_pict
        SCRN19 = .F.

    case SCRN20
        range1 = rng_exp1
        range2 = rng_exp2
        @ &coord1, &coord2 say &say_exp get &get_exp picture &get_pict;
            range &range1, &range2
        SCRN20 = .F.

    case SCRN21
        @ &coord1, &coord2 say &say_exp get &get_exp picture &get_pict;
            valid &valid_exp
        SCRN21 = .F.

    case SCRN22
        @ &coord1, &coord2, &coord3, &coord4 box &box_exp
        SCRN22 = .F.

    case SCRN23
        clear
        SCRN23 = .F.

    case SCRN24
        ?
        SCRN24 = .F.

    case SCRN25
        ? &exp1
        SCRN25 = .F.

    case SCRN26
        ??
        SCRN26 = .F.

    case SCRN27
        ?? &exp1
        SCRN27 = .F.

    case SCRN28
        cur_row = row()
        read
        @ cur_row+1, 1
        SCRN28 = .F.
endcase

return

*
** eoproc scrn


***
* Procedure TYPE
* Evaluates stack for TYPE verb.
* Sets execution class macro, class execution flag(s) and command line
* substitution macros.
*

procedure type

private stack_ptr

stack_ptr = 1

if get_expr1("exp1")
    executor = "DBF_NTX"
    DBF_NTX23 = .T.
else
    ERRS2 = .T.
endif

return

*
** eoproc type


***
* Procedure unknown
* If command cannot be found this routine is called to set unknown
* error flag.
*

procedure unknown

ERRS1 = .T.

return

*
** eoproc unknown


***
* Procedure UNLOCK
* Evaluates stack for UNLOCK verb.
* Sets execution class macro, class execution flag(s) and command line
* substitution macros.
*

procedure unlock

private stack_ptr

stack_ptr = 1

if max_ptr = 1
    executor = "DBF_NTX"
    DBF_NTX24 = .T.
else
    if max_ptr = 2 .and. upper(stack[2]) = "ALL"
        executor = "DBF_NTX"
        DBF_NTX25 = .T.
    else
        ERRS1 = .T.
    endif
endif

return

*
** eoproc unlock
                      

***
* Procedure USE
* Evaluates stack for USE verb.
* Sets execution class macro, class execution flag(s) and command line
* substitution macros.
*

procedure use 

private stack_ptr, file, dbf, index, ntx, alias, name, excl,;
  stack_item

stack_ptr = 1
store .F. to file, dbf, index, ntx, alias, name, excl

do while stack_ptr <= max_ptr .and. !err()

    stack_item = upper(stack[stack_ptr])

    do case 
        case "USE" = stack_item
            if get_expr1("dbf_file")
                file = .T.
                dbf = if(error_on, file("&dbf_file..DBF"), .T.)
            endif

        case cmd_abbr(stack_item, "INDEX")
            index = .T.
            ntx = get_list("NF")

        case cmd_abbr(stack_item, "ALIAS")
            alias = .T.
            name = get_expr1("exp2")

        case cmd_abbr(stack_item, "EXCLUSIVE")
            excl = .T.
            stack_ptr = stack_ptr + 1

        otherwise
            ERRS2 = .T.
    endcase
enddo

if !err()
    do case
        case !file .and. !dbf .and. !index .and. !ntx .and. !alias;
            .and. !excl
            *** Close the current selected data file. ***
            executor = "DBF_NTX"
            DBF_NTX1 = .T.

        case file .and. dbf .and. !index .and. !ntx .and. !alias;
            .and. !excl
            executor = "DBF_NTX"
            DBF_NTX2 = .T.

        case file .and. dbf .and. index .and. ntx .and. !alias;
            .and. !excl
            executor = "DBF_NTX"
            DBF_NTX3 = .T.

        case file .and. dbf .and. alias .and. name .and. !index;
            .and. !ntx .and. !excl
            executor = "DBF_NTX"
            DBF_NTX4 = .T.

        case file .and. dbf .and. index .and. ntx .and. alias;
            .and. name .and. !excl
            executor = "DBF_NTX"
            DBF_NTX5 = .T.

        case file .and. dbf .and. !index .and. !ntx .and. !alias;
            .and. excl
            executor = "DBF_NTX"
            DBF_NTX32 = .T.

        case file .and. dbf .and. index .and. ntx .and. !alias;
            .and. excl
            executor = "DBF_NTX"
            DBF_NTX33 = .T.

        case file .and. dbf .and. alias .and. name .and. !index;
            .and. !ntx .and. excl
            executor = "DBF_NTX"
            DBF_NTX34 = .T.

        case file .and. dbf .and. index .and. ntx .and. alias;
            .and. name .and. excl
            executor = "DBF_NTX"
            DBF_NTX35 = .T.

        case file .and. !dbf .and. !index .and. !ntx .and. error_on
            ERRS7 = .T.

        case file .and. dbf .and. index .and. !ntx .and. error_on
            ERRS11 = .T.

        otherwise
            ERRS2 = .T.
    endcase
endif
return

*
** eoproc use 


***
* Procedure vars
* executes the VARS class of commands
*

procedure vars

do case
    case VARS1
        accept to &var1
        VARS1 = .F.

    case VARS2
        accept &exp1 to &var1
        VARS2 = .F.

    case VARS3
        input to &var1
        VARS3 = .F.

    case VARS4
        input &exp1 to &var1
        VARS4 = .F.

    case VARS5
        wait
        VARS5 = .F.

    case VARS6
        wait to &var1
        VARS6 = .F.

    case VARS7
        wait &exp1 to &var1
        VARS7 = .F.

    case VARS8
        wait &exp1
        VARS8 = .F.
endcase

return

*
** eoproc var


***
* Procedure what_key
* displays ascii decimal value of a key
*

procedure what_key

private key, trash

save screen

clear
key = 0

do while key <> 272
    trash = inkey()
    key = lastkey()
    @ 10,10 say str(key,4) + " <ALT-Q> returns (272)."
    for col = 40 to 60 step 1
        @ 10, col say ""
    next
    for col = 40 to 60 step 2
        @ 10, col say ""
    next
enddo

restore screen

return

*
** eoproc what_key


***
* Procedure wWAIT
* Evaluates stack for WAIT verb.
* Sets execution class macro, class execution flag(s) and command line
* substitution macros.
*

procedure wwait

private stack_ptr, string, to, dest, stack_item

stack_ptr = 1
store .F. to string, to, dest

do while stack_ptr <= max_ptr
    stack_item = upper(stack[stack_ptr])
    do case
        case stack_item = "WAIT"
            string = get_expr1("exp1")
            if upper(exp1) = "TO"
                string = .F.
                exp1 = ""
                stack_ptr = stack_ptr - 1
            endif

        case stack_item = "TO"
            to = .T.
            dest = get_expr1("var1")

        otherwise
            stack_ptr = stack_ptr + 1
    endcase
enddo

if !err()
    do case
        case !to .and. !dest .and. !string
            executor = "VARS"
            VARS5 = .T.

        case to .and. dest .and. !string
            executor = "VARS"
            VARS6 = .T.
            VARS9 = .T.

        case to .and. dest .and. string
            executor = "VARS"
            VARS7 = .T.
            VARS9 = .T.

        case !to .and. !dest .and. string
            executor = "VARS"
            VARS8 = .T.

        otherwise
            ERRS2 = .T.
    endcase
endif

return

*
** eoproc wwait


***
* Procedure ZAP
* Evaluates stack for ZAP verb. 
* Sets execution class macro, class execution flag.
*

procedure zap

if error_on .and. !DBF_OPEN
  ERRS5 = .T.
else
  if stack_ptr = 1
     executor = "DBF_NTX"
     DBF_NTX36 = .T.
  else
     ERRS2 = .T.
  endif
endif

return

*
** eoproc ZAP


*********************************
* End of procedures for dot.prg *
*********************************

*********************
* Functions for Dot *
*********************


***
* Function assign_chk
* Check command for assignment operator.
*
*    Usage :    assign_chk()
*
*     Returns:
*        .T. - assignment operator found after first identifier.
*        .F. - no operator found.
*
* Called from SET_LEX procedure.
*

function assign_chk

private stack_item, status

stack_item = ""
status = .F.

if max_ptr >= 2
  stack_item = stack[2]
endif

if substr(stack[1],1,1)$"_ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"
  if stack_item == "="
        status = .T.
  else
     if substr(stack_item,1,1) == "["   && if no close brace error in parser.
        if max_ptr >= 3
           if stack[3] == "="
              status = .T.
           endif
        endif 
     endif
  endif
endif

return (status)

*
** eofunc assign_chk


***
* Function cmd_abbr
* Checks verb for correct abbreviation.
*
*    Usage   : cmd_abbr(<string1>, <string2>)
*
*        <string1> - upper of verb to check.
*        <string2> - upper full spelling of verb.
*
*     Returns :
*        .T. - s1 ok.
*        .F. - s1 NOT ok.
*
*    Notes      :
* 
*        1. DIR is an exception to the four char abbreviation definition.        
*

function cmd_abbr

parameters s1, s2

private status, s1_len, abbr_len

status = .F.
s1_len = len(s1)
abbr_len = len(s2)

if abbr_len > 4
    abbr_len = 4
endif

s1 = "." + s1
s2 = "." + s2

if s1$s2 .and. s1_len >= abbr_len .or. s1 == ".DIR"
    status = .T.
endif

return (status)

*
** eofunc cmd_abbr


***
* Function cnd_scp
* Evaluates the stack for condition and scope.  Called from procedures that
* need to analyze conditions and/or scope key words.
*
*    Usage :    cnd_scp()
*
*     Returns:
*        .T. - if no error occurred in analysis.
*        .F. - error occurred.
*
*    Control variables effected:
*        Strings   -   condition
*                      scope
*
*        Logicals  -   for
*                      while
*                      record
*                      all
*                      next
*                      rewind_dbf
*                      to
*                      source
*
*        Numerics  -   scope
*

function cnd_scp

rewind_dbf = .F.

do while stack_ptr <= max_ptr .and. !err()

    stack_item = upper(stack[stack_ptr])

    do case
        case stack_item = "FOR"
            condition = get_expr1("exp1")
            if condition
                for = .T.
                rewind_dbf = .T.
            else
                ERRS2 = .T.
            endif

        case cmd_abbr(stack_item, "WHILE")
            condition = get_expr1("exp2")
            if condition
                while = .T.
                rewind_dbf = .F.
            else
                ERRS2 = .T.
            endif

        case cmd_abbr(stack_item, "RECORD")
            if get_expr1("exp3") .and. is_num(&exp3)
                if &exp3 <= lastrec()
                    record = .T.
                    scope = 1
                    rewind_dbf = .F.
                    exp3 = "recno() = &exp3"
                else
                    ERRS6 = .T.
                endif
            else
                ERRS2 = .T.
            endif

        case stack_item = "ALL"
            all = .T.
            scope = 2
            rewind_dbf = .T.
            stack_ptr = stack_ptr + 1

        case stack_item = "NEXT"
            if get_expr1("exp3") .and. is_num(&exp3)
                next = .T.
                scope = 3
                rewind_dbf = .F.
            else    
                ERRS2 = .T.
            endif

        case stack_item = "TO"
            if get_expr1("dest")
                to = .T.
            else
                ERRS2 = .T.
            endif

        case stack_item = "FROM"
            if get_expr1("source")
                source = .T.
            else
                ERRS2 = .T.
            endif

        otherwise
            stack_ptr = stack_ptr + 1
    endcase
enddo

return (!err())

*
** eoproc cnd_scp


***
* Function err
* Check for error status flags set.
*
*    Usage : err()
*
*    Returns:
*        .T. - if any of the error flags are set.
*

function err

private status

status = .F.

if error_on
    if ERRS1 .or. ERRS2 .or. ERRS3 .or. ERRS4 .or. ERRS5 .or. ERRS6 .or. ERRS7;
        .or. ERRS8 .or. ERRS9 .or. ERRS10 .or. ERRS11 .or. ERRS12 .or. ERRS13;
        .or. ERRS14 .or. ERRS15
        status = .T.
    endif
endif

return (status)

*
** eofunc err


***
* Function fld_form
* Provides the correct column formatting for any given field type.
* Called by the list_do procedure.
*
*    Usage     : fld_form(<character expression>)
*
*        <character expression> - name of field to provide formatting
*                                 for.
*
*     Returns :
*        Output format string for fieldname.
*

function fld_form

parameters fld_name

private type, fld_form

type = type("&fld_name")

do case
    case type = "C"
        fld_form = fld_name

    case type = "D"
        fld_form = "dtoc(&fld_name)"

    case type = "L"
        fld_form = [if((&fld_name), ".T.", ".F.")]

    case type = "M"
        fld_form = ["Memo      "]

    case type = "N"
        fld_form = "str(&fld_name)"
endcase

return (fld_form)

*
** eofunc fld_form


***
* Function get_expr1()
* Fills the passed variable.
*
*    Usage   : get_expr1(<var_name>)
*
*        <var_name> -  contains name of target variable.
*
*    Returns :
*        .T. - variable is NOT empty.
*        .F. - variable is empty.
*
*    Notes   :
*
*            1. Increments stack pointer before getting stack item.
*            2. Leaves the stack pointer at the next item on stack.  
*            

function get_expr1

parameters var_name

private current, next, get_more

current = ""
next = ""
get_more = .F.
stack_ptr = stack_ptr + 1

if stack_ptr <= max_ptr
    &var_name = &var_name + stack[stack_ptr]
    stack_ptr = stack_ptr + 1

    if current <> ","
        if stack_ptr <= max_ptr
            next = stack[stack_ptr]

            if &var_name$"+-!.\" .or. substr(next,1,1)$"|+-/%*<>=#.!$^(["
                get_more = .T.
            endif

        endif
    endif
endif

do while get_more

    get_more = .F.
    current = stack[stack_ptr]
    &var_name = &var_name + current
    stack_ptr = stack_ptr + 1

    if stack_ptr <= max_ptr
        next = stack[stack_ptr]
        if current$"|+-/%*<>=#.!$^==" .and. next <> "," .or.;
            substr(next,1,1)$"|+-/%*<>=#.!$^([" .and. current <> ","
             get_more = .T.
        endif
    endif

enddo

return ("" <> &var_name)

*
** eofunc get_expr1


***
* Function get_list
* Gets a list of expression from the stack.  List variables start at 1.
*
*    Usage  :  get_list(<control string>)
*
*        <control string> - indicates that the list contains....
*
*                    "E"     - expressions.
*                    "NF" - index files.
*
*    Returns :
*        .T. - list filled successfully, or if "NF" and empty.
*        .F. - list is empty or error occurred.
*
*    Notes   :
*
*        1. If string = "NF" and error_on = .F. no index file
*           checking is done.
*        2. Increments stack pointer before getting something from the
*           stack.
*        3. Leaves stack pointer at next item on stack.
*

function get_list

parameters list_type

private get_more, count, list_ok, stack_item, null

if stack_ptr <= max_ptr
    list_ok = .T.
    get_more = .T.
    count = "0"
    stack_item = ""
else
    get_more = .F.
    if list_type = "NF"
        list_ok = .T.
    else
        list_ok = .F.
    endif
endif

do while get_more
    get_more = .F.
    stack_item = ""

    null = get_expr1("stack_item")

    if stack_item <> ","
        if list_type = "NF"
            list_ok = if(error_on, file("&stack_item..NTX"), .T.)
        endif
        if list_ok
            store stack_item to list&count
            count = str(val(count)+1,1)
        endif
    endif

    if stack_ptr <= max_ptr .and. val(count) < 10 .and. list_ok
        if stack[stack_ptr] = ","
            get_more = .T.
        endif
    endif
enddo

return (list_ok)

*
** eofunc get_list


***
* Function get_stack
* Fills the variable passed in var_name.
*
*     Usage    : get_stack(<var_name>)
*
*        <var_name> - literal name of variable to store expression to.
*
*    Returns:
*        .T. - if NOT null
*        .F. - if null.
*
*    Notes:
*
*        1. Does NOT increment the stack pointer before getting 
*           something from the stack.
*         2. Leaves the stack pointer at the next item on the stack.  
*

function get_stack

parameters var_name

private current, next, get_more

current = ""
next = ""
get_more = .F.

if stack_ptr <= max_ptr

    &var_name = stack[stack_ptr]
    current = &var_name
    stack_ptr = stack_ptr + 1

    if stack_ptr <= max_ptr
        next = upper(stack[stack_ptr])
    endif

    if current <> ","
        if current$"+-!\*.?" .or. substr(next,1,1)$"|+-/%*<>=#!$^([?*."
            get_more = .T.
        endif
    endif
endif

do while get_more

    get_more = .F.
    current = stack[stack_ptr]
    &var_name = &var_name + current
    stack_ptr = stack_ptr + 1

    if stack_ptr <= max_ptr
        next = stack[stack_ptr]
        if substr(current,1,1)$"|+-/%*<>=#.!$^=?" .and. next <> "," .or.;
            substr(next,1,1)$"|+-/%*<>=#.!$^([?" .and. current <> ","
             get_more = .T.
        endif
    endif

enddo

return (!(&var_name == ""))

*
** eofunc get_stack


***
* Function is_n_expr
* Checks the contents of eval_item for numeric type.
*
*     Usage     : is_n_expr(<eval_item>)
*
*         <eval_item> - macro expanded string.
*
*    Returns : 
*        .T. - item is numeric.
*        .F. - item is NOT numeric.
*

function is_n_expr

parameters eval_item

return (type("eval_item")$"N")

*
** eofunc is_n_expr


***
* Function is_num
* checks if a string contains only numbers.
*
*     Usage     : is_num(<eval_item>)
*
*         <eval_item> - macro expanded string.
*
*    Returns : 
*        .T. - item is string of numbers.
*        .F. - item is NOT a string of numbers.
*
*

function is_num

parameters string

private status, len, counter

if type("string")$"NC"
    if type("string") = "N"
        string = str(string)
    endif

    string = ltrim(string)
    status = .T.
    len = len(string)
    counter = 1

    do while counter <= len .and. status
        if !substr(string,counter,1)$"0123456789"
            status = .F.
        endif
        counter = counter + 1
    enddo
else
    status = .F.
endif

return (status)

*
** eofunc is_num


***
* Function spacer_h
* Build a string for a list/display header.
* Called by the list_do procedure.
*
*     Usage     : spacer_h(<field name>)
*
*        <field name> - name of the field to format.
*
*    Returns :
*        Character string containing field name plus the number of
*        blanks to pad the column out.
*
*    Notes   :
*
*        1. Called from procedure list_do.
*

function spacer_h

parameter fld_name

private type, string

type = type("&fld_name")
string = ""

do case
    case type = "C"
        string = fld_name + space(if(len(fld_name) >= len(&fld_name), 1,;
            (len(&fld_name) - len(fld_name)) + 1))

    case type = "D"
        string = fld_name + space(if((len(fld_name) >= 8), 1,;
            (8 - len(fld_name)) + 1))

    case type = "L"
        string = fld_name + space(if((len(fld_name) >= 3), 1,;
            (3 - len(fld_name)) + 1))

    case type = "M"
        string = fld_name + space(if((len(fld_name) = 10), 1,;
            (10 - len(fld_name)) + 1))

    case type = "N"
        string = space(if((len(fld_name) >= len(str(&fld_name))), 0,;
            (len(str(&fld_name)) - len(fld_name)))) + fld_name + space(1)
endcase

return (string)

*
** eofunc spacer_h


***
* Function spacer_l
* Calculate the number of characters to pad a list/display line.
* Called by the list_do procedure.
*
*     Usage     : spacer_h(<field name>)
*
*        <field name> - name of the field pad.
*
*    Returns :
*        Number of spaces needed to pad out a column in a screen
*        output line.
*
*    Notes   :
*
*        1. Called from procedure list_do.
*

function spacer_l

parameters fld_name

private type, blanks

type = type("&fld_name")
blanks = 0

do case
    case type = "C"
        blanks = if(len(&fld_name) >= len(fld_name), 1,;
            (len(fld_name) - len(&fld_name)) + 1)

    case type = "D"
        blanks = if(8 >= len(fld_name), 1, (len(fld_name) - 8) + 1)

    case type = "L"
        blanks = if(3 >= len(fld_name), 1, (len(fld_name) - 3) + 1)

    case type = "M"
        blanks = if(10 >= len(fld_name), 1, (len(fld_name) - 10) + 1)

    case type = "N"
        blanks = if((len(str(&fld_name)) >= len(fld_name)), 1,;
            (len(fld_name) - len(str(&fld_name)) + 1))
endcase

return (ltrim(str(blanks,2)))

*
** eofunc spacer_l



***
*	5.0 error handler for Dot...
*

#include "error.ch"

#define NTRIM(n)		( LTrim(Str(n)) )



***
*	DotError()
*
static func DotError(e)

	local i, cMessage, aOptions, nChoice
	local bSaveErrorBlock


	// switch to system error handler (in case of error in here)
	bSaveErrorBlock := ErrorBlock(SysErrorBlock)


	// for network open error, set NETERR() and alert user
	if ( e:genCode == EG_OPEN .and. e:osCode == 32 )
		NetErr(.t.)
	end

	// for lock error during APPEND BLANK, set NETERR() and alert user
	if ( e:genCode == EG_APPENDLOCK .and. e:canDefault )
		NetErr(.t.)
	end


	// build error message
	cMessage := ErrorMessage(e)


	// build options array
	aOptions := {"Break", "Quit"}

	if (e:canRetry)
		AAdd(aOptions, "Retry")
	end

	if (e:canDefault)
		AAdd(aOptions, "Default")
	end


	// put up alert box
	nChoice := 0
	while ( nChoice == 0 )

		if ( Empty(e:osCode) )
			nChoice := Alert( cMessage, aOptions )

		else
			nChoice := Alert( cMessage + ;
							";(DOS Error " + NTRIM(e:osCode) + ")", ;
							aOptions )
		end

	end


	// switch back to our error handler before leaving
	ErrorBlock(bSaveErrorBlock)


	// do as instructed
	if ( !Empty(nChoice) )

		if ( aOptions[nChoice] == "Break" )
			Break(e)

		elseif ( aOptions[nChoice] == "Retry" )
			return (.t.)

		elseif ( aOptions[nChoice] == "Default" )

			// default for division by zero is zero
			if ( e:genCode == EG_ZERODIV )
				return (0)

			end

			return (.f.)

		end

	end


	// display message and quit
	if ( !Empty(e:osCode) )
		cMessage += " (DOS Error " + NTRIM(e:osCode) + ") "
	end


	? cMessage
	ErrorLevel(1)
	QUIT

return (.f.)



/***
*	ErrorMessage()
*/
static func ErrorMessage(e)

	local cMessage


	// start error message
	cMessage := if( e:severity > ES_WARNING, "Error ", "Warning " )


	// add subsystem name if available
	if ( ValType(e:subsystem) == "C" )
		cMessage += e:subsystem()
	else
		cMessage += "???"
	end


	// add subsystem's error code if available
	if ( ValType(e:subCode) == "N" )
		cMessage += ("/" + NTRIM(e:subCode))
	else
		cMessage += "/???"
	end


	// add error description if available
	if ( ValType(e:description) == "C" )
		cMessage += ("  " + e:description)
	end


	// add either filename or operation
	if ( !Empty(e:filename) )
		cMessage += (": " + e:filename)

	elseif ( !Empty(e:operation) )
		cMessage += (": " + e:operation)

	end


	return (cMessage)

*
*
** eof dot.prg

