/*****
 *
 * GET13.PRG
 * "SAY with SCROLLING"
 *
 *
 */

#xcommand @ <r>,<c> SAYSCROLL <var>                                      ;
                                PICTURE <pict>                           ;
                                [COLOR <clr>]                            ;
                                [SEND <msg>]                             ;
                                                                         ;
                                                =>                       ;
                                                                         ;
   AADD(GetList, GETNEW(<r>,<c>,{|| <var>},<"var">,<pict>,<clr>))       ;;
   ATAIL(GetList):display()                                             ;;
   ATAIL(GetList):reader := {|g| MyCuteReader(g)}                       ;;
   [ATAIL(GetList):<msg>]

/*****
 *
 * Please nothe the way the WHEN is implemented!
 *
 */

FUNCTION Test()
   LOCAL GetList := {}
   LOCAL cVar1 := "Computer Associates Int'l"
   LOCAL cVar2 := "1 Computer Associates Plaza"
   LOCAL cVar3 := "Islandia, New York 11788"
   LOCAL cScreen

   cScreen := savescreen()
   SCROLL()
   @ 10,10 SAY "Company:" GET cVar1
   @ 12,10 SAY "Address:"
   @ 12,19 SAYSCROLL cVar2 PICTURE "@S10" COLOR "W/N" SEND preBlock := {|g| TONE(100,10), .T.}
   @ 14,10 GET cVar3
   READ

   restscreen(,,,,cScreen)
   RETURN (NIL)

// EOF - GET13.PRG //
