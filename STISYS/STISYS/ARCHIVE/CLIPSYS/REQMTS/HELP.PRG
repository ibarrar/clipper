/*******************************************************/
/* Filename:     HELP.PRG																														*/
/* System-name:  Visa Requirements Information System. */
/* Module:       Help Window Function.																	*/
/* Author:       Rolando C. Ibarra Jr. 															 */
/* Date-Started:  February 04, 1992																				*/
/* Last-Update:   February 04, 1992																				*/
/*******************************************************/

#include "Inkey.ch"

#define DATA_COLORS "N/W,N/BG"
#define ENTER_CHAR  chr(17)+chr(196)+chr(217)

function HelpWindow()
local wHelp,nKey
   wHelp:=OpenWindow(05,02,20,75,"")
			SetColor("N/G")
   @ 05,02 clear to 20,75
   @ 06,05 say " Editing & Navigation Keys "
   @ 07,08 say "Up arrow/Ctrl-E           Move up one line."
   @ 08,08 say "Down arrow/Ctrl-X         Move down one line."
   @ 09,08 say "Left arrow/Ctrl-S         Move left one character."
   @ 10,08 say "Right arrow/Ctrl-D        Move right one character."
   @ 11,08 say "Ctrl-left arrow/Ctrl-A    Move left one word."
   @ 12,08 say "Ctrl-right arrow/Ctrl-F   Move right one word."
   @ 13,08 say "Home                      Move to beginning of current line."
   @ 14,08 say "End                       Move to end of current line."
   @ 15,08 say "Ctrl-Home                 Move to beginning of current window."
   @ 16,08 say "PgUp                      Move to previous edit window."
   @ 17,08 say "PgDn                      Move to next edit window."
   @ 18,08 say "Ctrl-PgUp                 Move to end of memo."
   @ 19,08 say "Ctrl-PgDn                 Move to beginning of memo."
   Message("Press "+ENTER_CHAR+" for more....")
			nKey:=0
			do while nKey!=K_ENTER
      nKey:=InKey(0)
			enddo
   @ 05,02 clear to 20,75
   @ 08,08 say "Return                    Move to beginning of next line."
   @ 09,08 say "Delete                    Delete character at cursor."
   @ 10,08 say "Backspace                 Delete character to left of cursor."
   @ 11,08 say "Tab                       Insert tab character or spaces."
   @ 12,08 say "Printable characters      Insert character."
   @ 13,08 say "Ctrl-Y                    Delete the current line."
   @ 14,08 say "Ctrl-T                    Delete word right."
   @ 15,08 say "Ctrl-V/Ins                Toggle insert mode."
   @ 16,08 say "Esc                       Abort edit and return original."
   Message("Press "+ENTER_CHAR+" to return....")
			nKey:=0
			do while nKey!=K_ENTER
      nKey:=InKey(0)
			enddo
			SetColor(DATA_COLORS)
			CloseWindow(wHelp)
return nil

// end-of-file
