/***
*
*  Dbuhelp.prg
*
*  DBU Help Module
*
*  Copyright (c) 1990-1993, Computer Associates International, Inc.
*  All rights reserved.
*
*/


******
*	syshelp
*
*	Display help screens contained in the file DBU.HLP.
*	The help file can be in one of these places:
*
*		<current directory>
*		\CLIPPER\
*
*	The global variable "helpfile" contains the
*	path\filename, or a null string if not found.
******
PROCEDURE syshelp
local saveColor
PRIVATE hrow, hcol, hwbuf, htext

saveColor := SetColor()

IF EMPTY(M->helpfile)
	error_msg("Can't find DBU.HLP")

ELSE
	* save current row and column
	hrow = ROW()
	hcol = COL()

	* save screen in memvar
	hwbuf = SAVESCREEN(8, 10, 22, 69)

	* clear window and draw box
	SetColor(M->color8)
	scroll(8, 10, 22, 69, 0)
	@ 8,10,22,69 BOX M->frame

	* display help title
	SetColor(M->color10)
	@ 8,(76 - LEN(help_title[M->help_code])) / 2;
	SAY "  " + help_title[M->help_code] + "  "

	* get the help text
	htext = helptext(M->helpfile, M->help_code)

	* scroll state makes eliminates the need for a cursor
	SET CURSOR OFF

	* use editor in browse only mode
	SetColor(M->color8)
	MEMOEDIT(M->htext, 9, 11, 21, 68, .F.)

	* restore window
	RESTSCREEN(8, 10, 22, 69, M->hwbuf)

	* restore cursor
	@ M->hrow,M->hcol SAY ""
	IF M->curs_on
		SET CURSOR ON

	ENDIF
ENDIF

* reset
SetColor(saveColor)
local_func = 0
RETURN


******
*	helptext()
*
*	extract help text from a helpfile in the following format:
*
*	o	At the beginning of the help file is a table which contains
*		the offset and length of each block of help text in the file.
*
*	o	A table entry is 4 bytes long and consists of two 16 bit unsigned
*		numbers in binary format.  The first number is the offset within
*		the file where the corresponding help text begins; the second
*		number is the length of the text in bytes.
*
*	o	Table entries and related help text are arranged in numeric order
*		according to the global variable "help_code" which is used to
*		access the correct block of text.
*
*	o	Binary numbers at the beginning of the file are assumed to be
*		in standard Intel format where the Least Significant Byte (LSB)
*		is stored first and the Most Significant Byte (MSB) is second.
******
FUNCTION helptext

PARAMETERS hfile, hnum
PRIVATE htbuf, hoff, hlen, hhandle

* open the file and get handle
hhandle = FOPEN(M->hfile)

IF FERROR() = 0
	* allocate 512 byte buffer
	htbuf = SPACE(512)

	* read the file header into memory
	FREAD(M->hhandle, @htbuf, 512)

	* isolate the correct 4 byte table entry
	htbuf = SUBSTR(M->htbuf, (4 * (M->hnum - 1)) + 1, 4)

	* convert binary numbers (LSB, MSB) to Clipper numerics
	hoff = ASC(M->htbuf) + (256 * ASC(SUBSTR(M->htbuf, 2)))
	hlen = ASC(SUBSTR(M->htbuf, 3)) + (256 * ASC(SUBSTR(M->htbuf, 4)))

	* allocate buffer
	htbuf = SPACE(M->hlen)

	* position file to the correct offset
	FSEEK(M->hhandle, M->hoff)

	* read text into buffer
	FREAD(M->hhandle, @htbuf, M->hlen)

ELSE
	* return null string if error
	htbuf = ""

ENDIF

* close the file and release the handle
FCLOSE(M->hhandle)
RETURN M->htbuf


* EOF DBUHELP.PRG
