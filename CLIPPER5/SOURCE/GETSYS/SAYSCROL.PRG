/*****
 *
 *
 * You should include this user-defined command in your programs
 *
 * YOU SHOLD GIVE IT AN @Sn PICTURE IN ORDER TO ACHIEVE THE
 * DESIRED BEHAVIOUR OF SCROLLING!!!
 *
 * WARNING: #xcommand DOES NOT ALLOW 4 LETTER ABBREVIATIONS
 *
 * #xcommand @ <r>,<c> SAYSCROLL <var>                                      ;
 *                                 PICTURE <pict>                           ;
 *                                 [COLOR <clr>]                            ;
 *                                 [SEND <msg>]                             ;
 *                                                                          ;
 *                                                 =>                       ;
 *                                                                          ;
 *    AADD(GetList, GETNEW(<r>,<c>,{|| <var>},<"var">,<pict>,<clr>))       ;;
 *    ATAIL(GetList):display()                                             ;;
 *    ATAIL(GetList):reader := {|g| MyCuteReader(g)}                       ;;
 *    [ATAIL(GetList):<msg>]
 *
 */

#include "inkey.ch"
#include "getexit.ch"

/*****
 *
 * Custom Reader to be used with SayScroll()
 *
 */

FUNCTION MyCuteReader(g)
   // Read the GET if the WHEN condition is satisfied
   IF (GetPreValidate(g))
	   // Activate the GET for reading
	   g:SetFocus()

	   WHILE (g:exitState == GE_NOEXIT)
	      // Check for initial typeout (no editable positions)
	      IF (g:typeOut)
		      g:exitState := GE_ENTER

	      ENDIF

	      // Apply keystrokes until exit
	      WHILE (g:exitState == GE_NOEXIT)
		      SayScroll(g, INKEY(0))

	      END

	      // No valid condition is needed

	   END

	   // De-activate the GET
	   g:KillFocus()

   ENDIF

   RETURN (NIL)

/*****
 *
 * SayScroll()
 *
 * This will behave like a GET but without editing
 * So, if you specify the picture (@S), it will
 * allow you to have something like a SAY with scroll
 * You can also specify a color for this get in order
 * to make it appear as a SAY
 *
 */

FUNCTION SayScroll(g, nKey)
   LOCAL cKey, bKeyBlock

	// Check for SET KEY first
   IF ((bKeyBlock := SETKEY(nKey)) != NIL)
		GetDoSetKey(bKeyBlock, g)
		RETURN (NIL)                 // NOTE

   ENDIF

   IF (nKey == K_UP)
      g:exitState := GE_UP

	ELSEIF (nKey == K_SH_TAB)
      g:exitState := GE_UP

   ELSEIF (nKey == K_DOWN)
      g:exitState := GE_DOWN

   ELSEIF (nKey == K_TAB)
      g:exitState := GE_DOWN

   ELSEIF (nKey == K_ENTER)
      g:exitState := GE_ENTER

   ELSEIF (nKey == K_ESC)
      IF (SET(_SET_ESCAPE))
         g:exitState := GE_ESCAPE

      ENDIF

   ELSEIF ( nKey == K_PGUP )
      g:exitState := GE_WRITE

   ELSEIF ( nKey == K_PGDN )
      g:exitState := GE_WRITE

   ELSEIF ( nKey == K_CTRL_HOME )
      g:exitState := GE_TOP

	// Both ^W and ^End go to the last GET
   ELSEIF (nKey == K_CTRL_END)
		g:exitState := GE_BOTTOM

   ELSEIF (nKey == K_HOME)
      g:Home()

   ELSEIF (nKey == K_END)
      g:End()

   ELSEIF (nKey == K_RIGHT)
      g:Right()

   ELSEIF (nKey == K_LEFT)
      g:Left()

   ELSEIF (nKey == K_CTRL_RIGHT)
      g:WordRight()

   ELSEIF (nKey == K_CTRL_LEFT)
      g:WordLeft()

   ENDIF

   RETURN (NIL)

// EOF - SAYSCROLL.PRG //
