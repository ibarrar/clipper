/***
*
*  Valedit.prg
*
*  Copyright (c) 1993, Computer Associates International Inc.
*  All rights reserved.
*
*  NOTE: Compile with /a /m /n /w
*
*/

#include "inkey.ch"


/***
*
*  ValEdit( <nRow>, <nCol>, <xValue>, <[cPicture]>, <[cColor]> ) --> xNewValue
*
*  Uses a get object to edit value <xValue> at the screen location given
*  by <nRow> and <nCol>. Uses picture <cPicture> and color <cColor> if
*  passed.
*
*  Parameters:
*     nRow     - Row at which to edit <xValue>
*     nCol     - Column at which to edit <xValue>
*     xValue   - The value to be edited
*     cPicture - Optional picture clause for edit
*     cColor   - Optional color specification for edit
*
*  Returns:
*     The new (edited) value
*
*	Example usage:
*
*		// edits contents of myVar
*		myVar := ValEdit( 10, 10, myVar )
*
*		// edits flashing Y/N (default N), assigns to myVar
*		myVar := ValEdit( 10, 10, .F., "Y", "*W/R" )
*
*     // edits contents of a[i]
*     a[i] := ValEdit( 10, 10, a[i] )
*
*/
FUNCTION ValEdit( nRow, nCol, xValue, cPicture, cColor )

   LOCAL ExitRequested     // User requested termination of exit
   LOCAL nKey              // Current keypress
   LOCAL cKey              // Character string representation of nKey
   LOCAL lInsert := SET( _SET_INSERT )    // Current insert mode
   LOCAL g       := GetNew( nRow, nCol,                                     ;
                            { |p| IF( p == NIL, xValue, xValue := p ) }, "",;
                            cPicture,                                       ;
                            IF( cColor<>NIL , cColor + "," + cColor, NIL)   )

   g:setFocus()

   IF ( g:typeOut )        // No editable positions
      ExitRequested := .T.
   ELSE
      ExitRequested := .F.
   END

	//
   // Keystroke processing loop
	//
   WHILE ( !ExitRequested )

      nKey := INKEY( 0 )

      // Key processing construct
		do case
		case (nKey == K_UP)
			ExitRequested := .t.

		case (nKey == K_DOWN)
			ExitRequested := .t.

		case (nKey == K_ESC)
			g:Undo()
			g:KillFocus()
			RETURN (g:VarGet()) // NOTE

		case (nKey == K_PGUP)
			ExitRequested := .t.

		case (nKey == K_PGDN)
			ExitRequested := .t.

		case (nKey == K_CTRL_HOME)
			ExitRequested := .t.

		case (nKey == K_CTRL_W)
			ExitRequested := .t.

		case (nKey == K_ENTER)
			ExitRequested := .t.

		case (nKEY == K_CTRL_U)
			g:Undo()

		case (nKey == K_INS)
			lInsert := !lInsert

		case (nKey == K_HOME)
			g:Home()

		case (nKey == K_END)
			g:End()

		case (nKey == K_RIGHT)
			g:Right()

		case (nKey == K_LEFT)
			g:Left()

		case (nKey == K_CTRL_RIGHT)
			g:WordRight()

		case (nKey == K_CTRL_LEFT)
			g:WordLeft()

		case (nKey == K_BS)
			g:BackSpace()

		case (nKey == K_DEL)
			g:Delete()

		case (nKey == K_CTRL_T)
			g:DelWordRight()

		case (nKey == K_CTRL_Y)
			g:DelEnd()

		otherwise
			if (nKey >= 32 .and. nKey <= 127)
				// data key
				cKey := Chr(nKey)

				if (g:Type == "N" .and. ;
					(cKey == "." .or. cKey == ","))
					// go to decimal point
					g:ToDecPos()
				else
					// send it to the get
					if ( Set(_SET_INSERT) )
						g:Insert(cKey)
					else
						g:Overstrike(cKey)
					end
				end


#ifdef NOTDEF
				if (g:TypeOut)
					// exit get without confirm
					ExitRequested := .t.
				end
#endif

			end

		endcase

	//
	//	end of keystroke processing loop
	//
	end

    if (g:Changed)
		g:Assign()
    end

	g:Reset()
	g:KillFocus()

	// return final value
	RETURN (g:VarGet())

