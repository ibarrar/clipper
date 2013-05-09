/*****
 *
 * GETMEMO.PRG
 * A memo field between Gets
 *
 *
 * Clipper getmemo /N /W
 *
 */

#include "getexit.ch"
#include "inkey.ch"

/*****
 *
 * You should include this user-defined command in
 * your .prg or header file
 *

#xcommand   @ <row>,<col> GETMEMO <var>                         ;
                          [COLOR <clr>]   =>                    ;
                                                                ;
            SETPOS(<row>,<col>); DEVOUT("<Memo>", <clr>);       ;
            AADD( GetList, GetNew(<row>, <col>,                 ;
            {|x| IF(x == NIL, <var>, <var> := x)}, <"var">) );  ;
            ATAIL(GetList):reader := {|get| SETPOS(<row>,<col>),;
            EditMemo(get, <clr>)}

 *
 *
 *****/

#define     TOP        10
#define     LEFT       10

/*****
 *
 * You can improve the MemoEdit()
 * user interface with borders,
 * screen coordinates as parameters, etc.
 *
 * There is no parameter checking
 *
 */

FUNCTION EditMemo( oObj, cClr )
   LOCAL nTop, nLeft, nRight, nBottom
   LOCAL cColor, cScr, cTemp
   LOCAL nKey
   LOCAL nRet := GE_NOEXIT
   LOCAL cScreen

   cScreen := savescreen()

   nTop    := TOP
   nLeft   := LEFT
   nBottom := MAXROW() - 1
   nRight  := MAXCOL() - 1

   nKey := INKEY(0)
   IF ( nKey == K_ENTER )
      cScr := SAVESCREEN( nTop, nLeft, nBottom, nRight )
      cColor := SETCOLOR(cClr)
      SCROLL( nTop, nLeft, nBottom, nRight )
      oObj:varPut( MEMOEDIT( oObj:varGet(), nTop, ;
                             nLeft, nBottom, nRight) )
      RESTSCREEN( nTop, nLeft, nBottom, nRight, cScr )
      oObj:exitState := GE_NOEXIT  // NOTE

   ELSEIF ( nKey == K_UP )
		oObj:exitState := GE_UP

	ELSEIF ( nKey == K_SH_TAB )
		oObj:exitState := GE_UP

	ELSEIF ( nKey == K_DOWN )
		oObj:exitState := GE_DOWN

	ELSEIF ( nKey == K_TAB )
		oObj:exitState := GE_DOWN

	ELSEIF ( nKey == K_ESC )
		IF ( Set(_SET_ESCAPE) )
			oObj:exitState := GE_ESCAPE

		ENDIF

	ELSEIF ( nKey == K_PGUP )
		oObj:exitState := GE_WRITE

	ELSEIF ( nKey == K_PGDN )
		oObj:exitState := GE_WRITE

	ELSEIF ( nKey == K_CTRL_HOME )
		oObj:exitState := GE_TOP

   ENDIF
   restscreen(,,,,cScreen)
   RETURN (NIL)

// EOF - GETMEMO.PRG //
