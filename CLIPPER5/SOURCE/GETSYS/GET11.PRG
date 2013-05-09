/*****
 *
 * GET11.PRG
 *
 *
 * Clipper get11 /N /W
 * Clipper memoget /N /W
 * RTLINK FILE get11,memoget
 *
 */

#xcommand   @ <row>,<col> GETMEMO <var>                     ;
                          [COLOR <clr>] =>                  ;
                                                            ;
        SETPOS(<row>,<col>); DEVOUT("<Memo>", <clr>);       ;
        AADD( GetList, GetNew(<row>, <col>,                 ;
        {|x| IF(x == NIL, <var>, <var> := x)}, <"var">) );  ;
        ATAIL(GetList):reader := {|get| SETPOS(<row>,<col>),;
        EditMemo(get, <clr>)}

FUNCTION Test()
   LOCAL GetList := {}
   LOCAL nNum1 := 1234.56
   LOCAL dDat2 := DATE()
   LOCAL cStr3 := "This is a test of the GETMEMO command"
   LOCAL cStr4 := "Computer Associates Int'l"
   LOCAL cScreen

   cScreen := savescreen()

   SCROLL()
   SET( _SET_CONFIRM, .T. )
   SET( _SET_SCOREBOARD, .F. )
   @  8,10 GET nNum1 PICTURE "@K 9,999,999.99"
   @ 10,10 GET dDat2
   @ 12,10 GETMEMO cStr3 COLOR "W+/BG"
   @ 14,10 GET cStr4
   READ

   restscreen(,,,,cScreen)
   RETURN (NIL)

// EOF- GET11.PRG //
