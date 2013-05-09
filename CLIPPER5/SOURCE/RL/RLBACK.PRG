/***
*
*  Rlback.prg
*
*  Copyright (c) 1987-1993, Computer Associates International, Inc.
*  All rights reserved.
*
*  Note: Compile with /m /n
*
*/


***
*  Function   :  LBL_LOAD()
*  Purpose    :  Reads a label <.LBL> file into the label system
*             :  <.MEM> and <.DBF> files.
*
*  Convention :
*
*     status = LBL_LOAD(lbl_file, dbf_file, mem_file)
*
*  Parameters :
*
*     lbl_file -  string, label file to load.
*     dbf_file -  string, data file for contents description.
*     mem_file -  string, memory file for specs.
*
*  Return     :
*
*     status   -  logical, sucess of load operation.
*
*  Externals  :
*
*     FOPEN(), FCLOSE() FREAD(), FERROR(), CREATE_DBF(), WORD_2_NUM()
*
*  Notes      :   Label file passed with extension.
*             :   <.LBL> not found, init <.DBF> and <.MEM> with defaults.
*             :   File error number placed in file_error.
*
FUNCTION LBL_LOAD

PARAMETERS label_file, dbf_file, mem_file

PRIVATE i, buff_size, buff, handle, read_count, status, offset,;
   lbl_remark, lbl_height, lbl_width, lbl_margin, lbl_lines, lbl_spaces,;
   lbl_across

buff_size = 1034              && size of label file.
buff      = SPACE(buff_size)

i          = 0
handle     = 0
read_count = 0                    && read/write and content record counter.
status     = .F.
offset     = 74                   && start of label content descriptions.

DECLARE ffield[1]
DECLARE ftype[1]
DECLARE flength[1]
DECLARE fdecimal[1]

ffield[1]   = "CONTENTS"
ftype[1]    = "C"
flength[1]  = 60
fdecimal[1] = 0

** Create label line transfer <.DBF>. **
IF CREATE_DBF(dbf_file, 1, ffield, ftype, flength, fdecimal)

   ** Open the label file **
   handle = FOPEN(label_file)

   ** File does not exist **
   file_error = FERROR()
   IF file_error = 2

      ** Initialize default values **
      lbl_remark = SPACE(60)
	  lbl_height = 5
   	  lbl_width  = 35
   	  lbl_margin = 0
   	  lbl_lines  = 1
   	  lbl_spaces = 0
   	  lbl_across = 1

      SAVE ALL LIKE lbl_* TO &mem_file

      ** Append default number blank lines to file  **
      USE &dbf_file
      FOR count = 0 to (lbl_height - 1)
         APPEND BLANK
         REPLACE contents WITH SPACE(60)
      NEXT
      CLOSE DATABASES

      status = .T.

   ELSE

      ** OPEN ok? **
      IF file_error = 0

         ** Read label file **
         read_count = FREAD(handle, @buff, buff_size)

         ** READ ok? **
         IF read_count = 0
            file_error = -3         && file is empty.
         ELSE
            file_error = FERROR()   && check for DOS errors
         ENDIF

         IF file_error = 0

            ** Load label dimension to mem file **
            lbl_remark = SUBSTR(buff, 2, 60)
            lbl_height = WORD_2_NUM(SUBSTR(buff, 62, 2))
            lbl_width  = WORD_2_NUM(SUBSTR(buff, 64, 2))
            lbl_margin = WORD_2_NUM(SUBSTR(buff, 66, 2))
            lbl_lines  = WORD_2_NUM(SUBSTR(buff, 68, 2))
            lbl_spaces = WORD_2_NUM(SUBSTR(buff, 70, 2))
            lbl_across = WORD_2_NUM(SUBSTR(buff, 72, 2))

            SAVE ALL LIKE lbl_* TO &mem_file

            ** Load label line content expressions to file **
            USE &dbf_file
            FOR i = 0 to (lbl_height - 1)
               APPEND BLANK
               REPLACE contents WITH SUBSTR(buff, offset, 60)
               offset = offset + 60
            NEXT
            CLOSE DATABASES

            ** Close file **
            FCLOSE(handle)
            file_error = FERROR()
         ENDIF
      ENDIF

      ** Label file loaded ok? **
      status = (file_error = 0)

   ENDIF
ENDIF

RETURN (status)
// eofunc LBL_LOAD



***
*  Function   :  LBL_SAVE()
*  Purpose    :  Writes contents of the label system <.DBF> and
*             :  <.MEM> files to a <.LBL> file.
*
*  Convention :
*
*     status = LBL_SAVE(lbl_file, dbf_file, mem_file)
*
*  Parameters :
*
*     lbl_file -  string, label file to load.
*     dbf_file -  string, data file containing label line contents.
*     mem_file -  string, memory file label dimension.
*
*  Return     :
*
*     status   -  logical, success of save operation.
*
*  Externals  :
*
*     FCREATE(), FCLOSE(), FWRITE(), FERROR(), NUM_2_WORD()
*
*  Notes      :   Label file name passed with extension.
*             :   File error number placed in file_error.
*
FUNCTION LBL_SAVE

PARAMETERS label_file, dbf_file, mem_file

PRIVATE label_image, label_size, content_size, handle, write_count,;
   status, i, lbl_remark, lbl_height, lbl_width, lbl_margin, lbl_lines,;
   lbl_spaces, lbl_across

label_size   = 1034        && size of label file.
label_image  = ""          && holds modified label for write operation.
content_size = 960         && content area of file holds 16 60-byte records.

write_count = 0            && bytes written.
handle      = 0
i           = 0            && record counter.
status      = .F.

** Create the label file **
handle = FCREATE(label_file)

** Open ok? **
file_error = FERROR()
status = (file_error = 0)

IF status
   ** Restore label dimension values **
   RESTORE ADDITIVE FROM &mem_file

   ** Build new file image. **
   label_image = CHR(2) + lbl_remark + CHR(lbl_height) + CHR(0);
               + CHR(lbl_width) + CHR(0) + CHR(lbl_margin);
               + CHR(0) + CHR(lbl_lines) + CHR(0) + CHR(lbl_spaces);
               + CHR(0) + CHR(lbl_across) + CHR(0)

   ** Add contents fields to label file image **
   USE &dbf_file
   FOR i = 0 to (lbl_height - 1)
      label_image = label_image + contents
      SKIP
   NEXT
   CLOSE DATABASES

   ** Pad if needed **
   IF i < 16
      label_image = label_image + SPACE(content_size - (60 * i))
   ENDIF

   ** Label file signature, 1034th byte **
   label_image = label_image + CHR(2)

   ** Write new image to label file **
   write_count = FWRITE(handle, label_image, label_size)

   ** WRITE error? **
   IF write_count = 0
      file_error = -2
   ELSE
      file_error = FERROR()
   ENDIF

   ** Close file **
   IF !FCLOSE(handle)
      file_error = FERROR()         && write error detect may be covered up
   ENDIF                            &&    if done differently.

   status = (file_error = 0)

ENDIF

RETURN (status)
// eofunc LBL_SAVE



***
*  Function   :  FRM_LOAD()
*  Purpose    :  Reads a report <.FRM> file into the report system
*             :  <.MEM> and <.DBF> files.
*
*  Convention :
*
*     status = FRM_LOAD(report_file, dbf_file, mem_file)
*
*  Parameters :
*
*     report_file  -  string, report file to load.
*     dbf_file     -  string, data file for column expressions.
*     mem_file     -  string, memory file for report dimension.
*
*  Return     :
*
*     status   -  logical, success of load operation.
*
*  Externals  :
*
*     GET_EXPR(), GET_FIELD(), CREATE_DBF(), FOPEN(), FCLOSE(),
*     FSEEK(), FREAD(), FERROR(), WORD_2_NUM()
*
*  Notes      :   Report file name has extension.
*             :   File error number placed in file_error.
*             :   WARNING!!!!!!->   Offsets start at 1.
*             :      Offsets are into a CLIPPER STRING, 1 to 1990
*             :
*             :   WARNING!!!!!!->   The offsets mentioned in these notes
*             :      are actual DOS FILE offsets. NOT like the offsets
*             :      declared in the body of FRM_LOAD() which are CLIPPER
*             :      STRING offsets.
*             :
*             :   Report file length is 7C6h (1990d) bytes.
*             :   Expression length array starts at 04h (4d) and can
*             :      contain upto 55 short (2 byte) numbers.
*             :   Expression offset index array starts at 72h (114d) and
*             :      can contain upto 55 short (2 byte) numbers.
*             :   Expression area starts at offset E0h (224d).
*             :   Expression area length is 5A0h (1440d).
*             :   Expressions in expression area are null terminated.
*             :   Field expression area starts at offset 680h (1664d).
*             :   Field expressions (column definition) are null terminated.
*             :   Field expression area can contain upto 25 12-byte blocks.
*
FUNCTION FRM_LOAD

PARAMETERS report_file, dbf_file, mem_file

** Shared by FRM_LOAD() and its ancillary functions **
PRIVATE lengths_buff, offsets_buff, expr_buff, fields_buff,;
   field_width_offset, field_totals_offset, field_decimals_offset,;
   field_content_expr_offset, field_header_expr_offset

PRIVATE i,  handle, read_count, status, pointer, fcount, fld_offset,;
   file_buff, params_buff, size_file_buff, size_lengths_buff,;
   size_offsets_buff, size_expr_buff, size_fields_buff, size_params_buff,;
   expr_offset, offsets_offset, lengths_offset, fields_offset,;
   page_hdr_offset, grp_expr_offset, sub_expr_offset, grp_hdr_offset,;
   sub_hdr_offset, page_width_offset, lns_per_page_offset, left_mrgn_offset,;
   right_mgrn_offset, col_count_offset, dbl_space_offset,;
   summary_rpt_offset, pe_offset, plnpg_peap_pebp_offset, plus_byte,;
   frm_pagehdr, frm_grpexpr, frm_subexpr, frm_grphdr, frm_subhdr,;
   frm_pagewidth, frm_linespage, frm_leftmarg, frm_rightmarg,;
   frm_colcount, frm_dblspaced, frm_summary, frm_pe, frm_pebp, frm_peap,;
   frm_plainpage

i          = 0
handle     = 0
read_count = 0              && read/write and content record counter.
pointer    = 0             && points to an offset into EXPR_BUFF string.
status     = .F.

size_file_buff = 1990           && size of report file.
file_buff = SPACE(size_file_buff)

size_lengths_buff = 110
size_offsets_buff = 110
size_expr_buff    = 1440
size_fields_buff  = 300
size_params_buff  = 24

lengths_buff = ""
offsets_buff = ""
expr_buff    = ""
fields_buff  = ""
params_buff  = ""

** There are offsets into the FILE_BUFF string **
lengths_offset = 5      && start of expression length array.
offsets_offset = 115    && start of expression position array.
expr_offset    = 225    && start of expression data area.
fields_offset  = 1665   && start of report columns (fields).
params_offset  = 1965   && start of report parameters block.

** These are offsets into the FIELDS_BUFF string to actual values **
** Values are added to a block offset FLD_OFFSET that is moved in **
**    increments of 12 **
fld_offset            = 0
field_width_offset    = 1
field_totals_offset   = 6
field_decimals_offset = 7

** These are offsets into FIELDS_BUFF which are used to 'point' into **
**    the EXPR_BUFF string which contains the textual data **
field_content_expr_offset = 9
field_header_expr_offset  = 11

** These are actual offsets into the PARAMS_BUFF string which **
**    are used to 'point' into the EXPR_BUFF string **
page_hdr_offset = 1
grp_expr_offset = 3
sub_expr_offset = 5
grp_hdr_offset  = 7
sub_hdr_offset  = 9

** These are actual offsets into the PARAMS_BUFF string to actual values **
page_width_offset      = 11
lns_per_page_offset    = 13
left_mrgn_offset       = 15
right_mgrn_offset      = 17
col_count_offset       = 19
dbl_space_offset       = 21
summary_rpt_offset     = 22
pe_offset              = 23
plnpg_peap_pebp_offset = 24


** Default report values **
frm_pagehdr   = SPACE(240)
frm_grpexpr   = SPACE(200)
frm_subexpr   = SPACE(200)
frm_grphdr    = SPACE(50)
frm_subhdr    = SPACE(50)
frm_pagewidth = 80
frm_linespage = 58
frm_leftmarg  = 8
frm_rightmarg = 0
frm_colcount  = 0
frm_dblspaced = "N"
frm_summary   = "N"
frm_pe        = "N"
frm_pebp      = "Y"
frm_peap      = "N"
frm_plainpage = "N"


** Initialize transfer dbf creation arrays **
fcount = 5
DECLARE ffield[fcount]
DECLARE ftype[fcount]
DECLARE flength[fcount]
DECLARE fdecimal[fcount]

ffield[1]   = "WIDTH"
ftype[1]    = "N"
flength[1]  = 2
fdecimal[1] = 0

ffield[2]   = "TOTALS"
ftype[2]    = "C"
flength[2]  = 1
fdecimal[2] = 0

ffield[3]   = "DECIMALS"
ftype[3]    = "N"
flength[3]  = 2
fdecimal[3] = 0

ffield[4]   = "CONTENTS"
ftype[4]    = "C"
flength[4]  = 254
fdecimal[4] = 0

ffield[5]   = "HEADER"
ftype[5]    = "C"
flength[5]  = 260
fdecimal[5] = 0

** CREATE the Report FIELDS reocrd transfer file. **
IF CREATE_DBF(dbf_file, fcount, ffield, ftype, flength, fdecimal)

   ** Open the report file **
   handle = FOPEN(report_file)

   ** File does not exist **
   file_error = FERROR()
   IF file_error = 2

      ** Save default report variables as initialize above **
      SAVE ALL LIKE frm_* TO &mem_file

      ** Load at least one FIELDS (column) record **
      USE &dbf_file
      APPEND BLANK

      REPLACE width WITH 10
      REPLACE totals WITH "N"
      REPLACE decimals WITH 0
      REPLACE contents WITH SPACE(254)
      REPLACE header WITH SPACE(260)

      CLOSE DATABASES

      status = .T.

   ENDIF

   ** OPEN ok? **
   IF file_error = 0

      ** Go to START of report file **
      FSEEK(handle, 0)

      ** SEEK ok? **
      file_error = FERROR()
      IF file_error = 0

         ** Read entire file into process buffer **
         read_count = FREAD(handle, @file_buff, size_file_buff)

         ** READ ok? **
         IF read_count = 0
            file_error = -3         && file is empty.
         ELSE
            file_error = FERROR()   && check for DOS errors
         ENDIF

         IF file_error = 0

            ** Is this a .FRM type file (2 at start and end of file) **
            IF WORD_2_NUM(SUBSTR(file_buff, 1, 2)) = 2 .AND.;
               WORD_2_NUM(SUBSTR(file_buff, size_file_buff - 1, 2)) = 2

               file_error = 0
            ELSE
               file_error = -1
            ENDIF
         ENDIF
      ENDIF

      ** Close file **
      IF !FCLOSE(handle)
         file_error = FERROR()
      ENDIF
   ENDIF

   ** File existed, was opened and read ok and is a .FRM file **
   IF file_error = 0

      ** Fill processing buffers **
      lengths_buff = SUBSTR(file_buff, lengths_offset, size_lengths_buff)
      offsets_buff = SUBSTR(file_buff, offsets_offset, size_offsets_buff)
      expr_buff    = SUBSTR(file_buff, expr_offset, size_expr_buff)
      fields_buff  = SUBSTR(file_buff, fields_offset, size_fields_buff)
      params_buff  = SUBSTR(file_buff, params_offset, size_params_buff)

      ** Extract Numerics **
      frm_pagewidth = WORD_2_NUM(SUBSTR(params_buff,page_width_offset,2))
      frm_linespage = WORD_2_NUM(SUBSTR(params_buff,lns_per_page_offset,2))
      frm_leftmarg  = WORD_2_NUM(SUBSTR(params_buff,left_mrgn_offset,2))
      frm_rightmarg = WORD_2_NUM(SUBSTR(params_buff,right_mgrn_offset,2))
      frm_colcount  = WORD_2_NUM(SUBSTR(params_buff,col_count_offset,2))

      ** Extract characters **
      frm_dblspaced = SUBSTR(params_buff, dbl_space_offset, 1)
      frm_summary   = SUBSTR(params_buff, summary_rpt_offset, 1)
      frm_pe        = SUBSTR(params_buff, pe_offset, 1)

      ** Process packed 'plus byte' **
      plus_byte = ASC(SUBSTR(params_buff, plnpg_peap_pebp_offset, 1))
      IF INT( plus_byte / 4 ) = 1
         frm_plainpage = "Y"
         plus_byte = plus_byte - 4
      ENDIF
      IF INT( plus_byte / 2 ) = 1
         frm_peap = "Y"
         plus_byte = plus_byte - 2
      ENDIF
      IF INT( plus_byte / 1 ) = 1
         frm_pebp = "N"
         plus_byte = plus_byte - 1
      ENDIF

      ** Extract expression (strings) pointed to by pointers **

      ** Page Heading, Report Title **
      pointer = WORD_2_NUM(SUBSTR(params_buff, page_hdr_offset, 2))
      frm_pagehdr = GET_EXPR(pointer)

      ** Grouping expression **
      pointer = WORD_2_NUM(SUBSTR(params_buff, grp_expr_offset, 2))
      frm_grpexpr = GET_EXPR(pointer)

      ** Sub-grouping expression **
      pointer = WORD_2_NUM(SUBSTR(params_buff, sub_expr_offset, 2))
      frm_subexpr = GET_EXPR(pointer)

      ** Group header **
      pointer = WORD_2_NUM(SUBSTR(params_buff, grp_hdr_offset, 2))
      frm_grphdr = GET_EXPR(pointer)

      ** Sub-group header **
      pointer = WORD_2_NUM(SUBSTR(params_buff, sub_hdr_offset, 2))
      frm_subhdr = GET_EXPR(pointer)

      SAVE ALL LIKE frm_* TO &mem_file

      ** EXTRACT FIELDS (columns) **

      fld_offset = 12      && dBASE skips first 12 byte fields block.
      USE &dbf_file
      FOR i = 1 to frm_colcount

         ** APPEND and REPLACEs happen in GET_FIELD() **
         fld_offset = GET_FIELD(fld_offset)

      NEXT
      CLOSE DATABASES

      ** If we have gotten this far assume that the file is ok **
      status = (file_error = 0)

   ENDIF
ENDIF

RETURN (status)
// eofunc FRM_LOAD



***
*  Function   :  GET_EXPR()
*  Purpose    :  Reads an expression from EXPR_BUFF via the OFFSETS_BUFF.
*
*  Convention :
*
*     string = GET_EXPR(pointer)
*
*  Parameters :
*
*     pointer  -  numeric, 'pointer' to offset contained in OFFSETS_BUFF
*                    string that inturn 'points' to an expression located
*                    in the EXPR_BUFF string.
*
*  Return     :
*
*     string   -  string, retrieved expression, NULL ("") is empty.
*
*  Externals  :
*
*     WORD_2_NUM()
*
*  Notes      :   The expression is empty if......
*             :      1. Passed pointer is equal to 65535.
*             :      2. Character following character pointed to by
*             :         pointer is CHR(0) (NULL).
*             :   Called by the FRM_LOAD(), GET_FIELD()
*             :   File error number placed in file_error.
*
FUNCTION GET_EXPR

PARAMETERS pointer

PRIVATE expr_offset, expr_length, offset_offset, string

expr_offset   = 0
expr_length   = 0
offset_offset = 0

string = ""

** Stuff for dBASE compatability. **
IF pointer != 65535

   ** Convert DOS FILE offset to CLIPPER string offset **
   pointer = pointer + 1

   ** Calculate offset into OFFSETS_BUFF **
   IF pointer > 1
      offset_offset = (pointer * 2) - 1
   ENDIF

   expr_offset = WORD_2_NUM(substr(offsets_buff, offset_offset, 2))
   expr_length = WORD_2_NUM(substr(lengths_buff, offset_offset, 2))

   ** EXPR_OFFSET points to a NULL, so add one (+1) to get the string **
   ** and subtract one (-1) from EXPR_LENGTH for correct length **

   expr_offset = expr_offset + 1
   expr_length = expr_length - 1

   ** Extract string **
   string = substr(expr_buff, expr_offset, expr_length)

   ** dBASE does this so we must do it too **
   ** Character following character pointed to by pointer is NULL **
   IF CHR(0) = SUBSTR(string, 1, 1) .AND. LEN(SUBSTR(string,1,1)) = 1
      string = ""
   ENDIF
ENDIF

RETURN (string)
// eofunc GET_EXPR()



***
*  Function   :  GET_FIELD()
*  Purpose    :  Get a FIELDS element from FIELDS_BUFF string.
*
*  Convention :
*
*     offset = GET_FIELD(offset)
*
*  Parameters :
*
*     offset   -  numeric, current FIELDS_OFFSET block.
*
*  Return     :
*
*     offset   -  numeric, next FIELDS_OFFSET block.
*
*  Externals  :
*
*     GET_EXPR(), WORD_2_NUM()
*
*  Notes      :   The Header or Contents expressions are empty if......
*             :      1. Passed pointer is equal to 65535.
*             :      2. Character following character pointed to by
*             :         pointer is CHR(0) (NULL).
*             :   Called by the FRM_LOAD()
*             :   File error number placed in file_error.
*
FUNCTION GET_FIELD

PARAMETERS offset

PRIVATE pointer, number

pointer = 0
number  = 0

APPEND BLANK

** Column width **
number = WORD_2_NUM(SUBSTR(fields_buff, offset + field_width_offset, 2))
REPLACE width WITH number


** Total **
REPLACE totals WITH SUBSTR(fields_buff, offset + field_totals_offset, 1)


** Decimals width **
number = WORD_2_NUM(SUBSTR(fields_buff, offset +;
            field_decimals_offset, 2))
REPLACE decimals WITH number

** Offset (relative to FIELDS_OFFSET), 'point' to **
**    expression area via array OFFSETS[]. **


** Content expression **
pointer = WORD_2_NUM(SUBSTR(fields_buff, offset +;
               field_content_expr_offset, 2))
REPLACE contents WITH GET_EXPR(pointer)


** Header expression **
pointer = WORD_2_NUM(SUBSTR(fields_buff, offset +;
               field_header_expr_offset, 2))
REPLACE header WITH GET_EXPR(pointer)

RETURN (offset + 12)
// eofunc GET_FIELD()



***
*  Function   :  FRM_SAVE()
*  Purpose    :  Writes contents of the report system <.DBF> and
*             :  <.MEM> files to a <.FRM> file.
*
*  Convention :
*
*     status = FRM_SAVE(frm_file, dbf_file, mem_file)
*
*  Parameters :
*
*     frm_file -  string, destination report form.
*     dbf_file -  string, data file for column expressions.
*     mem_file -  string, memory file for report dimension.
*
*  Return     :
*
*     status   -  logical, sucess of save operation.
*
*  Externals  :
*
*     WRITE_EXPR(), WRITE_FIELD(), WRITE_PARAMS(), FCREATE(), FCLOSE(),
*     FERROR(), FWRITE()
*
*  Notes      :   Report file name has extension.
*             :   File error number placed in file_error.
*             :   WARNING!!!!!!->   Offsets start are from 0.
*             :      Offsets are into a DOS FILE, 0 to 1989
*             :
*             :   WARNING!!!!!!->   The offsets mentioned in these notes
*             :      are actual DOS FILE offsets.  These ARE NOT the same
*             :      as those declared in FRM_LOAD().
*             :
*             :   WARNING!!!!!!->   An exception to this is the fields
*             :      (columns) related offsets which are relative to the
*             :      FIELDS_OFFSET offset.
*             :
*             :   Report file length is 7C6h (1990d) bytes.
*             :   Expression length array starts at 04h (4d) and can
*             :      contain upto 55 short (2 byte) numbers.
*             :   Expression offset index array starts at 72h (114d) and
*             :      can contain upto 55 short (2 byte) numbers.
*             :   Expression area starts at offset E0h (224d).
*             :   Expression area length is 5A0h (1440d).
*             :   Expressions in expression area are null terminated.
*             :   Expression lengths include the null terminator.
*             :   Field expression area starts at offset 680h (1664d).
*             :   Field expressions (column definition) are null terminated.
*             :   Field expression area can contain upto 25 12 byte elements
*             :      describing a column layout.
*
FUNCTION FRM_SAVE

PARAMETERS report_file, dbf_file, mem_file

** Shared by FRM_SAVE() and its ancillary functions **
PRIVATE handle, expr_offset, offsets_offset, lengths_offset, fields_offset,;
   page_hdr_num, grp_expr_num, sub_expr_num, grp_hdr_num, sub_hdr_num,;
   next_free_offset, last_expr, expr_count

PRIVATE report_size, report_image, status, expr_count, i, j, write_count,;
   frm_pagehdr, frm_grpexpr, frm_subexpr, frm_grphdr, frm_subhdr,;
   frm_pagewidth, frm_linespage, frm_leftmarg, frm_rightmarg,;
   frm_colcount, frm_dblspaced, frm_summary, frm_pe, frm_pebp, frm_peap,;
   frm_plainpage

report_size  = 1990              && size of report file.
report_image = ""

i           = 0
j           = 0
handle      = 0
write_count = 0                       && read/write and content record counter.
status      = .F.

expr_num   = 0                   && expression record count.
last_expr  = 0                   && end of last expression in area + 1.
expr_count = -1                  && first expression at offset 0.

** Offsets into the report file **
next_free_offset = 2             && first un-USEd expr area offset.
lengths_offset   = 4             && start of expression length array.
offsets_offset   = 114           && start of expression position array.
expr_offset      = 224           && start of expression data area.
fields_offset    = 1664          && start of report columns (fields).
end_offset       = 1964          && start of last 24 bytes to write.

** Offsets array index numbers to these expressions **
page_hdr_num = 0
grp_expr_num = 0
sub_expr_num = 0
grp_hdr_num  = 0
sub_hdr_num  = 0

** Create the label file **
handle = FCREATE(report_file)

** Open ok? **
file_error = FERROR()
IF file_error = 0
   ** Restore report dimension values **
   RESTORE ADDITIVE FROM &mem_file

   ** Write a NULL filled report 'skeleton' **
   report_image = CHR(2) + CHR(0) + replicate(CHR(0), (1990 - 4)) +;
                     CHR(2) + CHR(0)
   write_count = FWRITE(handle, report_image, report_size)

   ** Skeleton WRITE ok? **
   IF write_count = 0
      file_error = -2
   ELSE
      file_error = FERROR()
   ENDIF

   IF file_error = 0

      ** Write Page Heading info **
      page_hdr_num = WRITE_EXPR(frm_pagehdr, .T.)

      ** WRITE ok? **
      IF page_hdr_num != -1

         ** Write Grouping expression info **
         grp_expr_num = WRITE_EXPR(frm_grpexpr, .T.)

         ** WRITE ok? **
         IF grp_expr_num != -1

            ** Write Sub-grouping expression info **
            sub_expr_num = WRITE_EXPR(frm_subexpr, .T.)

            ** WRITE ok? **
            IF sub_expr_num != -1

               ** Write Group Heading info **
               grp_hdr_num = WRITE_EXPR(frm_grphdr, .T.)

               ** WRITE ok? **
               IF grp_hdr_num != -1

                  ** Write Sub-group Heading info **
                  sub_hdr_num = WRITE_EXPR(frm_subhdr, .F.)

                  ** WRITE ok? **
                  status = (sub_hdr_num != -1)

               ENDIF
            ENDIF
         ENDIF
      ENDIF

      ** Headers, grouping and sub-group info writen ok? **
      IF status

         ** Write FIELDS (columns) info **
         USE &dbf_file
         j = lastrec()
         FOR i = 1 to j

            IF i == j .AND. LEN( TRIM( contents ) ) == 0
               status := .T.
               frm_colcount--
            ELSE
               status := WRITE_FIELD()
            ENDIF

            ** Ok? **
            IF status
               SKIP                    && pass, go next.
            ELSE
               i = j + 1               && error, break out.
            ENDIF
         NEXT
         CLOSE DATABASES
      ENDIF

      ** Column info written ok? **
      IF status
         ** Write last 24 bytes of report and update next_free_offset **
         status = WRITE_PARAMS()
      ENDIF
   ENDIF

   ** CLOSE ok? **
   IF !FCLOSE(handle)
      file_error = FERROR()
      status = .F.
   ENDIF
ENDIF

RETURN (status)
// eofunc FRM_SAVE



***
*  Function   :  WRITE_EXPR()
*  Purpose    :  Writes an expression to Report expression area.
*
*  Convention :
*
*     expr_num = WRITE_EXPR(string, blank)
*
*  Parameters :
*
*     string   -  string, thing to write to expression area.
*     blank    -  logical, test for dBASE like blank expression handling
*                    and return a 65535 if expression to write is blank.
*
*  Return     :
*
*     expr_num -  numeric, expression count (0 to 55 inclusive) or
*                    65535 (if blank = .T. and EMPTY(string) = .T.) or
*                    -1 (if WRITE/SEEK error).
*
*  Externals  :
*
*     FWRITE(), FSEEK(), FERROR(), NUM_2_WORD()
*
*  Notes      :   Called by the FRM_SAVE()
*             :   Updates lengths_offset, offsets_offset, last_expr,
*             :      expr_count
*             :   Special dBASE test - string is EMPTY() and = CHR(0).
*             :   File error number placed in file_error.
*             :   DISK FULL error, file_error = -2.
*
FUNCTION WRITE_EXPR

PARAMETERS string, blank

PRIVATE status, write_item, write_len, write_count, return_count

status       = .F.
write_item   = ""
write_len    = 0
write_count  = 0
return_count = 0        && expression count/65535 if empty/-1 error.

** For dBASE compatability **
IF blank .AND. LEN(string) = 0
   status = .T.
ELSE

   write_item = string + CHR(0)
   write_len = LEN(write_item)

   ** Move to the next free area **
   FSEEK(handle, expr_offset + last_expr)

   file_error = FERROR()
   IF file_error = 0

      ** Write the expression **
      write_count = FWRITE(handle, write_item, write_len)

      ** WRITE error? **
      IF write_count = 0
         file_error = -2
      ELSE
         file_error = FERROR()
      ENDIF

      IF file_error = 0
         FSEEK(handle, offsets_offset)

         file_error = FERROR()
         IF file_error = 0

            ** Add an offset to the offsets array. **
            write_count = FWRITE(handle, NUM_2_WORD(last_expr), 2)

            ** WRITE error? **
            IF write_count = 0
               file_error = -2
            ELSE
               file_error = FERROR()
            ENDIF

            IF file_error = 0
               FSEEK(handle, lengths_offset)

               file_error = FERROR()
               IF file_error = 0

                  ** Add the expression length to the lengths array **
                  write_count = FWRITE(handle, NUM_2_WORD(write_len), 2)

                  ** WRITE error? **
                  IF write_count = 0
                     file_error = -2
                  ELSE
                     file_error = FERROR()
                  ENDIF

                  ** Move offsets to next position **
                  IF file_error = 0
                     last_expr = last_expr + write_len
                     lengths_offset = lengths_offset + 2
                     offsets_offset = offsets_offset + 2

                     ** Write was performed ok **
                     status = .T.

                  ENDIF
               ENDIF
            ENDIF
         ENDIF
      ENDIF
   ENDIF
ENDIF

** If the write ok, bump the expression count. **
IF status
   IF blank .and. LEN(string) = 0
      return_count = 65535                && if the expression was empty.
   ELSE
      expr_count = expr_count + 1         && global increment.
      return_count = expr_count           && local return.
   ENDIF
ELSE
   return_count = -1                      && WRITE/SEEK ops error.
ENDIF

RETURN (return_count)
// eofunc WRITE_EXPR()



***
*  Function   :  WRITE_FIELD()
*  Purpose    :  Writes a FIELDS element to the FIELDS area.
*
*  Convention :
*
*     status = WRITE_FIELD()
*
*  Parameters :
*
*     (none)
*
*  Return     :
*
*     status   -  logical, success or fail of write operation.
*
*  Externals  :
*
*     FWRITE(), FSEEK(), FERROR(), WRITE_EXPR(), NUM_2_WORD()
*
*  Notes      :   Called by the FRM_SAVE()
*             :   Updates fields_offset, lengths_offset, offsets_offset,
*             :      last_expr
*             :   File error number placed in file_error.
*
FUNCTION WRITE_FIELD

PRIVATE status, write_item, write_len, write_count, cnts_offset, hdr_offset

status      = .F.
write_item  = ""
write_len   = 0
write_count = 0
cnts_offset = 65535
hdr_offset  = 65535

** Write Contents **
cnts_offset = WRITE_EXPR(trim(contents), .F.)

** WRITE ok? **
IF cnts_offset != -1

   ** Write Header **
   hdr_offset = WRITE_EXPR(trim(header), .T.)

   ** WRITE ok? **
   IF hdr_offset != -1

      ** Seek to the next free FIELDS area **
      fields_offset = fields_offset + 12
      FSEEK(handle, fields_offset)

      ** SEEK ok? **
      file_error = FERROR()
      IF file_error = 0

         write_item = NUM_2_WORD(width) +;
                         replicate(CHR(0), 3) +;
                         totals +;
                         NUM_2_WORD(decimals) +;
                         NUM_2_WORD(cnts_offset) +;
                         NUM_2_WORD(hdr_offset)
         write_len = LEN(write_item)

         ** Write the FIELDS info **
         write_count = FWRITE(handle, write_item, write_len)

         ** WRITE error? **
         IF write_count = 0
            file_error = -2
         ELSE
            file_error = FERROR()
         ENDIF

         ** WRITE ok? **
         status = (file_error = 0)

      ENDIF
   ENDIF
ENDIF

RETURN (status)
// eofunc WRITE_FIELD()



***
*  Function   :  WRITE_PARAMS()
*  Purpose    :  Writes the last 24 bytes of the report file plus
*             :      updates the first un-used offset. (last_offset)
*
*  Convention :
*
*     status = WRITE_PARAMS()
*
*  Parameters :
*
*     (none)
*
*  Return     :

*     status   -  logical, success or fail of write operation.
*
*  Externals  :
*
*     FSEEK(), FWRITE(), FERROR(), NUM_2_WORD()
*
*  Notes      :   Called by the FRM_SAVE()
*             :   File error number placed in file_error.
*
FUNCTION WRITE_PARAMS

PRIVATE status, write_item, write_len, write_count, plus_byte

status      = .F.
write_item  = ""
write_len   = 0
write_count = 0
plus_byte   = 0

** Calculate plus byte **
IF frm_plainpage = "Y"
   plus_byte = plus_byte + 4
ENDIF
IF frm_peap = "Y"
   plus_byte = plus_byte + 2
ENDIF
IF frm_pebp = "N"
   plus_byte = plus_byte + 1
ENDIF

** Prepare miscellaneous data area string for write ops **
write_item = NUM_2_WORD(page_hdr_num) +;
                NUM_2_WORD(grp_expr_num) +;
                NUM_2_WORD(sub_expr_num) +;
                NUM_2_WORD(grp_hdr_num) +;
                NUM_2_WORD(sub_hdr_num) +;
                NUM_2_WORD(frm_pagewidth) +;
                NUM_2_WORD(frm_linespage) +;
                NUM_2_WORD(frm_leftmarg) +;
                NUM_2_WORD(frm_rightmarg) +;
                NUM_2_WORD(frm_colcount) +;
                frm_dblspaced +;
                frm_summary +;
                frm_pe +;
                CHR(plus_byte)
write_len = LEN(write_item)

** Seek to first parameters area **
FSEEK(handle, end_offset)

** SEEK ok? **
file_error = FERROR()
IF file_error = 0
   write_count = FWRITE(handle, write_item, write_len)

   ** WRITE error? **
   IF write_count = 0
      file_error = -2
   ELSE
      file_error = FERROR()
   ENDIF

   IF file_error = 0
      FSEEK(handle, next_free_offset)

      ** SEEK ok? **
      file_error = FERROR()
      IF file_error = 0

         ** Update the next free expression offset **
         write_count = FWRITE(handle, NUM_2_WORD(last_expr), 2)

         ** WRITE error? **
         IF write_count = 0
            file_error = -2
         ELSE
            file_error = FERROR()
         ENDIF

         status = (file_error = 0)

      ENDIF
   ENDIF
ENDIF


RETURN (status)
// eofunc WRITE_PARAMS()



***
*  Function   :  CREATE_DBF()
*  Purpose    :  Creates a <.DBF> file.
*
*  Convention :
*
*    status = CREATE_DBF(file, size, field, ftype, flength, fdecimal)
*
*  Parameters :
*
*     file     -  string, dbf file name to create.
*     size     -  numeric, number of fields. (for speed)
*     field    -  array, field name(s).
*     ftype    -  array, field type(s).
*     flength  -  array, field length(s).
*     fdecimal -  array, field decimal length(s).
*
*  Return     :
*
*     status   -  logical, success of create operation.
*
*  Externals  :
*
*     FCREATE(), FCLOSE(), FWRITE(), FERROR(), NUM_2_WORD()
*
*  Notes      :   File error number placed in file_error.
*
FUNCTION CREATE_DBF

PARAMETERS file, size, fieldname, ftype, flength, fdecimal

PRIVATE header_image, field_image, tail_image, block_size, handle,;
   i, write_count, field_count, data_offset, record_size, status

** DBF file creation variables **
i           = 0                  && array subscript.
handle      = 0
block_size  = 32                 && header and field block size.
data_offset = block_size         && field records start are offset 32d.
record_size = 0
write_count = 0                  && bytes writen.
field_count = 0                  && fields to create.
status = .T.

** NO extension **
IF AT(".", file) = 0
   file = TRIM(file) + ".DBF"
ENDIF

** Calculate record_size, field_count and data_offset **
FOR i = 1 to size
   record_size = record_size + flength[i]
   data_offset = data_offset + block_size
NEXT

field_count = i - 1
record_size = record_size + 1       && + one byte of pad.
data_offset = data_offset + 2       && + 2 for CR and NULL.

header_image = CHR(3) +;                        && dbf id.      (byte)
                  replicate(CHR(0), 3) +;       && last update. (byte)
                  replicate(CHR(0), 4) +;       && last record. (long)
                  NUM_2_WORD(data_offset) +;    && data offset. (word)
                  NUM_2_WORD(record_size) +;    && record size. (word)
                  replicate(CHR(0), 20)         && 20 byte pad.

field_image = ""                                && filled in later.
tail_image = CHR(13) + CHR(0) + CHR(26)         && CR, pad, EOF

** Create label content dbf file **
handle = FCREATE(file)

** CREATEd ok? **
file_error = FERROR()
status = (file_error = 0)

IF status

   ** Write dbf header image **
   write_count = FWRITE(handle, header_image, block_size)

   ** Header WRITE ok? **
   IF write_count = 0
      file_error = -2
   ELSE
      file_error = FERROR()
   ENDIF
   status = (file_error = 0)

   IF status

      ** Make a FIELD header block **
      FOR i = 1 to field_count

         ** Build it **
         field_image = fieldname[i] +;                   && field name + pad
                         replicate(CHR(0), 11 - LEN(fieldname[i])) +;
                         ftype[i] +;                 && field type   (byte)
                         replicate(CHR(0), 4) +;     && 4 byte pad
                         CHR(flength[i] % 256) +;    && field length (byte)
                         IF(ftype[i] = "C",;         && for "C" type > 256
                            CHR(flength[i] / 256),;  && low + high bytes
                            CHR(fdecimal[i])) +;     && decimals     (byte)
                         replicate(CHR(0), 14)       && 14 byte pad

         ** Write it **
         write_count = FWRITE(handle, field_image, block_size)

         ** WRITE ok? **
         IF write_count = 0
            file_error = -2
         ELSE
            file_error = FERROR()
         ENDIF
         status = (file_error = 0)

         IF !status
            i = field_count + 1        && breakout of FOR loop.
         ENDIF
      NEXT

   ENDIF

   ** If file created ok so far... **
   IF status
      ** Write Tail CR + NULL + EOF (0Dh + 00h + 1Ah) **
      write_count = FWRITE(handle, tail_image, 3)

      ** WRITE error? **
      IF write_count = 0
         file_error = -2
      ELSE
         file_error = FERROR()
      ENDIF

      status = (file_error = 0)

   ENDIF

   ** Close file **
   status = FCLOSE(handle)
   IF !status
      file_error = FERROR()
   ENDIF
ENDIF

RETURN (status)
// eofunc CREATE_DBF



***
*  Function   :  WORD_2_NUM()
*  Purpose    :  Converts a 2 byte string to numeric.
*
*  Convention :
*
*     num = WORD_2_NUM(hex_string)
*
*  Parameters :
*
*     string   -  hex_string, 2 hex bytes in LSB, MSB order
*
*  Return     :
*
*     num      -  numeric, converted number.
*
*

FUNCTION WORD_2_NUM

PARAMETERS byte_string

PRIVATE numeric

numeric = ASC(SUBSTR(byte_string, 1, 1)) +;           && extract LSB
             ASC(SUBSTR(byte_string, 2, 1)) * 256     && extract MSB

RETURN (numeric)
// eofunc WORD_2_NUM()



***
*  Function   :  NUM_2_WORD()
*  Purpose    :  Converts a numeric to a 2 byte string.
*
*  Convention :
*
*     byte_string = NUM_2_WORD(numeric)
*
*  Parameters :
*
*     numeric       -  numeric, number to convert.
*
*  Return     :
*
*     byte_string   -  string, 2 bytes in LSB, MSB order
*
*
FUNCTION NUM_2_WORD

PARAMETERS numeric

PRIVATE byte_string

byte_string = CHR(numeric % 256) +;         && make LSB
                CHR(numeric / 256)          && make MSB

RETURN (byte_string)
// eofunc NUM_2_WORD()
