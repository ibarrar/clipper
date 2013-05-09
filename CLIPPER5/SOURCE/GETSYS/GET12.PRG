/*****
 *
 * GET12.PRG
 *
 * Getting a password and echoing asterisks
 *
 * Clipper get12 /n /w
 * Clipper getpsw /n /w
 * RTLINK FILE get12,getpsw
 *
 */

#include "inkey.ch"

FUNCTION Test()
   LOCAL GetList := {}
   LOCAL cPassword
   LOCAL cScreen

   cScreen := savescreen()
   WHILE .T.
      SCROLL()
      cPassword := SPACE(10)
      @ 10,10 GET cPassword SEND reader := {|o| o:varPut(MyPsw(o))}
      READ
      @ 20,10 SAY cPassword
      IF INKEY(5) == K_ESC
         EXIT

      ENDIF

   END
   restscreen(,,,,cScreen)
   RETURN (NIL)

// EOF - GET12.PRG //
