/***
*
*  Dbu.prg
*
*  DBU Main Module
*
*  Copyright (c) 1990-1993, Computer Associates International, Inc.
*  All rights reserved.
*
*/

PROCEDURE Dbu( param1, param2, param3 )

   PUBLIC n_files,keystroke,lkey,frame,sframe,cur_dir,more_up,more_down,;
   kf1,kf2,kf3,kf4,kf5,kf6,need_field,need_ntx,need_relat,need_filtr,;
   help_code,view_err,cur_area,cur_dbf,cur_ntx,cur_fields,error_on,;
   exit_str,page,sysfunc,func_sel,cur_func,local_func,local_sel,box_open,;
   color1,color2,color3,color4,color5,color6,color7,color8,color9,;
   color10,color11,color12,com_line,curs_on,helpfile


   ******
   *  The parameters are optional and have the following meaning:
   *
   *  - filename (.VEW or .DBF) to Browse
   *
   *  - color directive where:
   *     /C = use color even if monochrome
   *     /M = monochrome (don't use color)
   *
   *  - file opening mode (for network support)
   *     /E = exclusive use of files
   *
   *  Parameters may be specified in any order
   ******

   * avoid a type mismatch & convert to uppercase
   IF VALTYPE( param1 ) != "C"
      param1 = ""
   ENDIF

   IF VALTYPE( param2 ) != "C"
      param2 = ""
   ENDIF

   IF VALTYPE( param3 ) != "C"
      param3 := ""
   ENDIF

   // Combine all the command line params together
   param1 := UPPER( param1 + "~" + param2 + "~" + param3 + "~" )

   // Process the command line parameters where com_line will contain the
   // view/file name to open and param2 will contain the color directive
   param3 := ParseCommLine( param1 )
   com_line := param3[1]
   param2   := param3[2]

   SET CURSOR OFF                                && cursors are for gets
   SAVE SCREEN                                   && the screen you save...
   SET SCOREBOARD OFF                            && who's keeping score, anyhow
   SET KEY 28 TO                                 && some folks need help

   IF (ISCOLOR() .OR. "/C" $ UPPER(param2)) .AND. .NOT. "/M" $ UPPER(param2)
      * make it pretty
      color1 = "W+/B,N/W,B"                      && normal
      color2 = "B/W"                             && item hilite
      color3 = "W+/R"                            && error or high intensity
      color4 = "W+/B,B/W,,,W+/B"                 && achoice/list array..unselected is norm
      color5 = "B/BG,B/W,,,W/BG"                 && achoice/sysmenu..true unselected
      color6 = "W+/BG"                           && menu frame
      color7 = "B/BG,B/W"                        && browse, modify structure, set relation
      color8 = "B/W,B/BG,,,B/W"                  && memos, dialogue
      color9 = "W+/B,N/BG"                       && memo titles
      color10 = "B/BG"                           && dialogue box hilite
      color11 = "W+/BG"                          && menu title hilite
      color12 = "W+/B"                           && set relation hilite

   ELSE
      * monochrome
      color1 = "W/N,N/W"
      color2 = "N/W"
      color3 = "W+/N"
      color4 = "W/N,N/W,,,W/N"
      color5 = "W+/N,N/W,,,W/N"
      color6 = "W/N"
      color7 = "W/N,N/W"
      color8 = "W/N,N/W,,,W/N"
      color9 = "N/W,N/W"
      color10 = "N/W"
      color11 = "N/W"
      color12 = "W+/N"

   ENDIF

   * let's get this baby off the ground
   SetColor(color1)
   CLEAR

   * system constants
   more_up = CHR(24)                             && visual up arrow
   more_down = CHR(25)                           && visual down arrow
   frame = "ÕÍ¸³¾ÍÔ³"                            && box characters
   lframe = "ÑÍ¸³¾ÍÏ³"
   mframe = "ÂÄÂ³ÙÄÀ³"
   sframe = "ÚÄ¿³ÙÄÀ³"

   * global variables
   STORE .F. TO need_field,need_ntx,need_relat,need_filtr,box_open
   STORE "" TO kf1,kf2,kf3,kf4,kf5,kf6
   help_code = 0                                 && let them eat cake
   curs_on = .F.                                 && what cursor?
   cur_dir = ""                                  && current directory
   cur_dbf = ""                                  && current data file
   cur_ntx = ""                                  && current controlling index file
   cur_fields = ""                               && fields array for current area
   cur_area = 0                                  && current work area
   page = 1                                      && active view screen
   n_files = 0                                   && 14 user files max
   view_file = ""                                && file to save view
   view_err = ""                                 && displayed by "set_view"

   view_err = "DBU - Copyright (c) 1990-1993 Computer Associates Int'l, " +;
   "All Rights Reserved."

   * search for help file
   IF FILE( "dbu.hlp" )
      helpfile := "dbu.hlp"

   ELSE
      helpfile := GetHelpFile()

   ENDIF

   **
   *  Arrays declared in main module are considered public and
   *  may be accessed or altered by any module in the system. The
   *  matrix defines 6 work areas with 7 indexes and 64 fields
   *  for each. 15 relations are also provided. All elements are
   *  initialized to avoid a type mismatch.
   **

   * names of data files
   DECLARE dbf[6]

   * names of index files
   DECLARE ntx1[7]
   DECLARE ntx2[7]
   DECLARE ntx3[7]
   DECLARE ntx4[7]
   DECLARE ntx5[7]
   DECLARE ntx6[7]

   * index expression keys
   DECLARE expKey[7]

   * 15 relations
   DECLARE s_relate[15]                          && source of relation
   DECLARE k_relate[15]                          && key to relation
   DECLARE t_relate[15]                          && target of relation

   * individual field names for active list
   DECLARE field_n1[64]
   DECLARE field_n2[64]
   DECLARE field_n3[64]
   DECLARE field_n4[64]
   DECLARE field_n5[64]
   DECLARE field_n6[64]

   * master field list..128 fields overall max
   DECLARE field_list[128]

   * first and last row of each screen section
   DECLARE row_a[3]                              && first row of each screen section
   DECLARE row_x[3]                              && last row of each screen sectionn

   * constant values
   row_a[1] = 6
   row_x[1] = 6
   row_a[2] = 10
   row_x[2] = 12
   row_a[3] = 16
   row_x[3] = 22

   * col() of data file columns
   DECLARE column[6]

   * current row for each data column and each screen section
   DECLARE _cr1[3]
   DECLARE _cr2[3]
   DECLARE _cr3[3]
   DECLARE _cr4[3]
   DECLARE _cr5[3]
   DECLARE _cr6[3]

   * current element for each data column and each screen section
   DECLARE _el1[3]
   DECLARE _el2[3]
   DECLARE _el3[3]
   DECLARE _el4[3]
   DECLARE _el5[3]
   DECLARE _el6[3]

   * titles for function keys and help screens
   DECLARE func_title[8]
   DECLARE menu_deflt[8]
   DECLARE help_title[22]

   **
   * initialize arrays
   **

   * active data files
   afill(dbf, "")

   * index files for each data file
   afill(ntx1, "")
   afill(ntx2, "")
   afill(ntx3, "")
   afill(ntx4, "")
   afill(ntx5, "")
   afill(ntx6, "")

   * fields for each data file
   afill(field_n1, "")
   afill(field_n2, "")
   afill(field_n3, "")
   afill(field_n4, "")
   afill(field_n5, "")
   afill(field_n6, "")

   * source, key, and target for relations
   afill(s_relate, "")
   afill(k_relate, "")
   afill(t_relate, "")

   * master field list
   afill(field_list, "")

   * titles for function keys
   func_title[1] = "Help"
   func_title[2] = "Open"
   func_title[3] = "Create"
   func_title[4] = "Save"
   func_title[5] = "Browse"
   func_title[6] = "Utility"
   func_title[7] = "Move"
   func_title[8] = "Set"

   afill(menu_deflt, 1)

   * draw top of screen rows 0 thru 3
   @ 0,0 SAY " F1        F2        F3        F4        F5        F6        " +;
   "F7        F8       "
   show_keys()
   @ 2,0 SAY REPLICATE("Ä", 80)
   error_msg(view_err)

   * when to bubble up
   exit_str = "356"

   * pop-up menus with parallel boolean arrays for achoice()
   DECLARE help_m[1]
   DECLARE help_b[1]
   help_m[1] = "Help"
   help_b[1] = .T.

   DECLARE open_m[3]
   DECLARE open_b[3]
   open_m[1] = "Database"
   open_m[2] = "Index"
   open_m[3] = "View"
   open_b[1] = "sysfunc = 0 .AND. .NOT. box_open"
   open_b[2] = "sysfunc = 0 .AND. .NOT. box_open .AND. .NOT. EMPTY(cur_dbf)"
   open_b[3] = "sysfunc = 0 .AND. .NOT. box_open"

   DECLARE create_m[2]
   DECLARE create_b[2]
   create_m[1] = "Database"
   create_m[2] = "Index"
   create_b[1] = "sysfunc = 0"
   create_b[2] = "sysfunc = 0 .AND. .NOT. EMPTY(cur_dbf)"

   DECLARE save_m[2]
   DECLARE save_b[2]
   save_m[1] = "View"
   save_m[2] = "Struct"
   save_b[1] = "sysfunc = 0 .AND. .NOT. box_open"
   save_b[2] = "sysfunc = 3 .AND. func_sel = 1 .AND. .NOT. box_open"

   DECLARE browse_m[2]
   DECLARE browse_b[2]
   browse_m[1] = "Database"
   browse_m[2] = "View"
   browse_b[1] = "sysfunc = 0 .AND. .NOT. EMPTY(cur_dbf)"
   browse_b[2] = "sysfunc = 0 .AND. .NOT. EMPTY(dbf[1])"

   DECLARE utility_m[6]
   DECLARE utility_b[6]
   utility_m[1] = "Copy"
   utility_m[2] = "Append"
   utility_m[3] = "Replace"
   utility_m[4] = "Pack"
   utility_m[5] = "Zap"
   utility_m[6] = "Run"
   afill(utility_b, "sysfunc = 0 .AND. .NOT. EMPTY(cur_dbf)", 1, 5)
   utility_b[6] = "sysfunc = 0"

   DECLARE move_m[4]
   DECLARE move_b[4]
   move_m[1] = "Seek"
   move_m[2] = "Goto"
   move_m[3] = "Locate"
   move_m[4] = "Skip"
   afill(move_b, "sysfunc = 5 .AND. .NOT. box_open")
   move_b[1] = move_b[1] + " .AND. .NOT. EMPTY(cur_ntx)"

   DECLARE set_m[3]
   DECLARE set_b[3]
   set_m[1] = "Relation"
   set_m[2] = "Filter"
   set_m[3] = "Fields"
   set_b[1] = "sysfunc = 0 .AND. .NOT. box_open .AND. .NOT. EMPTY(dbf[2])"
   set_b[2] = "sysfunc = 0 .AND. .NOT. box_open .AND. .NOT. EMPTY(cur_dbf)"
   set_b[3] = "sysfunc = 0 .AND. .NOT. box_open .AND. .NOT. EMPTY(cur_dbf)"

   * titles for help screens
   help_title[1] = "GENERAL INFORMATION"
   help_title[2] = "FIELDS LISTS"
   help_title[3] = "BROWSE"
   help_title[4] = "CREATE / MODIFY STRUCTURE"
   help_title[5] = "CREATE INDEX"
   help_title[6] = "OPEN DATABASE"
   help_title[7] = "FILTERS"
   help_title[8] = "OPEN INDEX"
   help_title[9] = "SET RELATIONSHIP"
   help_title[10] = "LOCATE EXPRESSION"
   help_title[11] = "SDF / DELIMITED"
   help_title[12] = "COPY"
   help_title[13] = "SEEK EXPRESSION"
   help_title[14] = "GO TO RECORD NUMBER"
   help_title[15] = "APPEND"
   help_title[16] = "FOR / WHILE"
   help_title[17] = "SCOPE"
   help_title[18] = "DOS WINDOW"
   help_title[19] = "MEMO EDITOR"
   help_title[20] = "SKIP <n> RECORDS"
   help_title[21] = "SAVE / RESTORE VIEW"
   help_title[22] = "REPLACE"

   * arrays for file names in default directory
   DECLARE dbf_list[adir("*.DBF") + 20]          && directory of data files
   DECLARE ntx_list[adir("*" + INDEXEXT()) + 20] && directory of index files
   DECLARE vew_list[adir("*.VEW") + 20]          && directory of view files

   * fill the arrays with filenames
   array_dir("*.DBF",dbf_list)
   array_dir("*" + INDEXEXT(),ntx_list)
   array_dir("*.VEW",vew_list)

   * default to set view
   local_func = 0                                && local menu
   local_sel = 1                                 && local menu item
   keystroke = 0                                 && current keystroke
   lkey = 0                                      && previous keystroke
   sysfunc = 0                                   && system menu
   func_sel = 1                                  && system menu item

   * clean up and process command line if entered
   com_line = LTRIM(TRIM(com_line))

   IF .NOT. EMPTY(com_line)

      DO CASE

      CASE RAT(".", com_line) > RAT("\", com_line)
         * file extension entered
         IF .NOT. FILE(com_line)
            * file must exist
            com_line = ""

         ENDIF

      CASE FILE(com_line + ".VEW")
         * look for file name with .VEW extension
         com_line = com_line + ".VEW"

      CASE FILE(com_line + ".DBF")
         * look for file name with .DBF extension
         com_line = com_line + ".DBF"

      OTHERWISE
         * file not found..ignore command line
         com_line = ""

      ENDCASE

      IF .NOT. EMPTY(com_line)
         * command line file exists

         IF RAT(".VEW", com_line) = LEN(com_line) - 3
            * assume a valid .VEW file
            view_file = com_line
            set_from(.F.)                        && restore view
            KEYBOARD CHR(-4) + CHR(24) + CHR(13) && browse view

         ELSE
            * assume a valid .DBF file
            dbf[1] = com_line                    && primary database

            IF NetUse( com_line )
               all_fields(1, M->field_n1)        && all fields active
               KEYBOARD CHR(-4) + CHR(13)        && browse database
            ELSE
               dbf[1] := ""
            ENDIF

         ENDIF

         IF .NOT. EMPTY(dbf[1])
            * view established..cancel display of message
            view_err = ""
         ENDIF
      ENDIF
   ENDIF

   DO WHILE .T.
      * forever
      cur_func = M->sysfunc                      && to recognize a change

      DO CASE

      CASE M->sysfunc = 5
         * browse

         IF .NOT. EMPTY(dbf[1])
            * there is a view..do the set up
            setup()

            IF EMPTY(M->view_err)
               * set up successful so far
               cur_fields = "field_n" + SUBSTR("123456", M->cur_area, 1)

               DO CASE

               CASE M->func_sel = 1 .AND. EMPTY(M->cur_dbf)
                  * browse one file
                  view_err = "No data file in current select area"

               CASE M->func_sel = 1 .AND. EMPTY(&cur_fields[1])
                  * browse one file
                  view_err = "No active field list in current select area"

               CASE EMPTY(field_list[1])
                  * browse entire view
                  view_err = "No active field list"

               OTHERWISE
                  * ok to browse

                  IF M->func_sel = 1
                     * browse one file..hi-lite the name
                     hi_cur()

                  ENDIF

                  help_code = 3
                  DO browse
                  dehi_cur()

               ENDCASE
            ENDIF

         ELSE
            view_err = "No database in use"

         ENDIF

         sysfunc = 0                             && back to the main view screen

      CASE M->sysfunc = 3

         IF M->func_sel = 1
            * modify structure
            hi_cur()
            help_code = 4
            DO modi_stru
            dehi_cur()

            IF EMPTY(M->cur_dbf)
               * new structure not created..kill dummy View channel
               cur_area = 0

            ENDIF

         ELSE
            * create or re-create index

            IF EMPTY(M->cur_dbf)
               view_err = "No data file in current select area"

            ELSE
               help_code = 5
               DO make_ntx

            ENDIF
         ENDIF

         sysfunc = 0                             && back to the main view screen

      CASE M->sysfunc = 6 .AND. M->func_sel <> 6
         * copy/append/replace/pack/zap

         IF EMPTY(M->cur_dbf)
            view_err = "No data file in current select area"
            sysfunc = 0                          && back to the main view screen
            LOOP

         ENDIF

         IF .NOT. EMPTY(dbf[1])
            * do view set up
            setup()

         ENDIF

         IF .NOT. EMPTY(M->view_err)
            * error in set up
            sysfunc = 0                          && back to the main view screen
            LOOP

         ENDIF

         hi_cur()

         DO CASE

         CASE M->func_sel < 4
            * copy, append, or replace
            DO capprep

         CASE M->func_sel = 4
            * pack command

            IF rsvp("Pack " + M->cur_dbf + "? (Y/N)") = "Y"
               * pack confirmed
               stat_msg("Packing " + M->cur_dbf)
               SELECT (M->cur_area)

               * we will have to rebuild the index files after PACK
               ntx := "ntx" + SUBSTR("123456", M->cur_area, 1)
               M->i := 1
               DO WHILE M->i <= 7
                 IF EMPTY (&ntx[i])  // no more
                   EXIT
                 ENDIF

                 expKey[i] := IndexKey (i)
                 M->i ++
               ENDDO

               IF NetPack()

                 M->i := 1
                 DO WHILE M->i <= 7
                   IF EMPTY (&ntx[i])  // no more
                     EXIT
                   ENDIF

									 INDEX ON &(expKey[i]) TO (&ntx[i])
                   M->i ++
                 ENDDO
                 dbClearIndex()

                 stat_msg(M->cur_dbf + " Packed")

                 * update indexes and filter
                 need_ntx := .T.
                 need_filtr := .T.

               ELSE
                  /*
                  IF !NetUse( M->cur_dbf )
                     /// If we can't re-open, we're in trouble...
                     ALERT( "Assertion failed:;Unable to re-open file" )
                     QUIT
                  ENDIF
                  */
                  clear_dbf(M->cur_area, 2)
                  cur_dbf = dbf[M->cur_area]
                  stat_msg("")
               ENDIF

            ENDIF

         CASE M->func_sel = 5
            * zap command

            IF rsvp("Zap " + M->cur_dbf + "? (Y/N)") = "Y"
               * zap confirmed
               stat_msg("Zapping " + M->cur_dbf)
               SELECT (M->cur_area)

               * we will have to rebuild the index files after ZAP
               ntx := "ntx" + SUBSTR("123456", M->cur_area, 1)
               M->i := 1
               DO WHILE M->i <= 7
                  IF EMPTY (&ntx[i])  // no more
                     EXIT
                  ENDIF

                  expKey[i] := IndexKey (i)
                  M->i ++
               ENDDO

               IF NetZap()
                  M->i := 1
                  DO WHILE M->i <= 7
                     IF EMPTY (&ntx[i])  // no more
                        EXIT
                     ENDIF

									   INDEX ON &(expKey[i]) TO (&ntx[i])
                     M->i ++
                  ENDDO
                  dbClearIndex()

                  stat_msg(M->cur_dbf + " Zapped")
                  * update indexes and filter
                  need_ntx := .T.
                  need_filtr := .T.

               ELSE
                  /*
                  IF !NetUse( M->cur_dbf )       //Attempt to re-open shared
                     /// If we can't re-open, we're in trouble...
                     ALERT( "Assertion failed:;Unable to re-open file" )
                     QUIT
                  ENDIF
                  */
                  clear_dbf(M->cur_area, 2)
                  cur_dbf = dbf[M->cur_area]
                  stat_msg("")
               ENDIF

            ENDIF

         ENDCASE

         dehi_cur()
         sysfunc = 0                             && back to the main view screen

      CASE M->sysfunc = 6 .AND. M->func_sel = 6
         * run a DOS command or program
         @ 4,0 CLEAR

         IF .NOT. EMPTY(dbf[1])
            * set view before a possible chdir
            setup()

         ENDIF

         IF .NOT. EMPTY(M->view_err)
            * display message and continue for possible
            * correction of "File not found", etc.
            error_msg(M->view_err, 24, 7)
            view_err = ""

         ENDIF

         run_com = ""
         com_line = ""
         help_code = 18

         DO WHILE .NOT. q_check()
            * re-draw top 3 rows after each command
            @ 0,0 SAY " F1        F2        F3        F4        " +;
            "F5        F6        F7        F8       "
            show_keys()
            @ 2,0 SAY REPLICATE("Ä", 80)
            @ 24,0 SAY "Run Í" + CHR(16) + " "

            * accept command entry
            run_com = enter_rc(M->com_line,24,7,127,"@KS73",M->color1)

            IF .NOT. EMPTY(M->run_com) .AND. M->keystroke = 13
               * only the enter key will run the command
               com_line = M->run_com             && preserve previous command
               @ 24,0                            && clear the command entry

               SET CURSOR ON
               RUN &run_com
               SET CURSOR OFF

            ELSE
               * check for menu request
               sysmenu()

               IF M->local_func = 1
                  DO syshelp

               ENDIF
            ENDIF
         ENDDO

         * re-establish the environment
         @ 3,0 CLEAR

         * rebuild directory arrays..must keep current
         DECLARE dbf_list[adir("*.DBF") + 20]
         DECLARE ntx_list[adir("*" + INDEXEXT()) + 20]
         DECLARE vew_list[adir("*.VEW") + 20]

         * fill the arrays with filenames..data files
         array_dir("*.DBF",dbf_list)

         * index files
         array_dir("*" + INDEXEXT(),ntx_list)

         * view files
         array_dir("*.VEW",vew_list)
         cur_area = 0                            && re-draw view screen
         sysfunc = 0                             && back to the main view screen

      OTHERWISE
         * main view screen..sysfunc = 0
         help_code = 1
         DO set_view

         IF M->keystroke = 27
            * exit confirmed in set_view
            SET TYPEAHEAD TO 0                   && remaining keystrokes to DOS
            CLOSE DATABASES                      && kill the view
            RESTORE SCREEN                       && ...may be your own
            SET CURSOR ON                        && always leave them laughing
            SET COLOR TO                         && back to normal
            QUIT                                 && -=[Bye]=-

         ENDIF
      ENDCASE
   ENDDO

   RETURN



/***
*
*  ParseCommLine( cCommandLine ) --> { cFile, cColorDescriptor }
*
*/
FUNCTION ParseCommLine( cStr )
   LOCAL aRet := { "", "" }                   // Return value containing file and colors
   LOCAL nPos := 1                            // Position of next token in string
   LOCAL cToken                               // Extracted command line parameter

   WHILE ( nPos != 0 )

      IF (( nPos := AT( "~", cStr ) ) != 0 )

         cToken := SUBSTR( cStr, 1, nPos - 1 )
         cStr   := SUBSTR( cStr, ++nPos )

         DO CASE
         CASE ( cToken == "/E" )
            NetMode( .F. )

         CASE ( cToken $ "/C/M" )
            aRet[2] := cToken

         CASE !( cToken == "" )
            aRet[1] := cToken

         ENDCASE

      ENDIF

   ENDDO

   RETURN ( aRet )



/***
*
*  GetHelpFile() --> cHelpFile
*
*/
FUNCTION GetHelpFile()
   LOCAL cPath := GETENV( "PATH" )
   LOCAL nPos  := 1
   LOCAL cFile
   LOCAL lFound

   WHILE ( nPos != 0 )

      nPos  := AT( ";", cPath )

      // Account for backslash in path
      IF ( SUBSTR( cPath, nPos - 1, 1 ) == "\" )
         cFile := SUBSTR( cPath, 1, IF( nPos == 0, LEN( cPath ), nPos - 1 )) + "dbu.hlp"
      ELSE
         cFile := SUBSTR( cPath, 1, IF( nPos == 0, LEN( cPath ), nPos - 1 )) + "\dbu.hlp"
      ENDIF

      IF FILE( cFile )
         EXIT     // We found it, time to bail...
      ENDIF

      IF ( nPos == 0 )
         cFile := ""
      ELSE
         cPath := SUBSTR( cPath, nPos + 1 )
      ENDIF

   END

   RETURN ( cFile )



* EOF DBU.PRG
