/*****
 *
 * MODGET.PRG
 *
 * Clipper modget /N /W /A
 *
 */

#xcommand   READ [TIMEOUT <n>] [START AT <x>] =>;
            ReadModal( GetList, <n>, <x> ); GetList := {}

FUNCTION Test()
   LOCAL GetList := {}
   LOCAL cVar  := SPACE(30)
   LOCAL cVar1 := SPACE(20)
   LOCAL cVar2 := SPACE(10)
   LOCAL cVar4 := SPACE(25)
   LOCAL cScreen

   cScreen := savescreen()

   SCROLL()
   @  5,10 GET cVar
   @ 10,10 GET cVar1
   @ 15,10 GET cVar2
   @ 20,10 GET cVar4 VALID GoToGet(2)  // NOTE
   READ TIMEOUT 10 START AT 3
   IF TimedOut()
      QOUT( ExitAtGet() )

   ENDIF

   restscreen(,,,,cScreen)
   RETURN (NIL)

// EOF - MODGET.PRG //
