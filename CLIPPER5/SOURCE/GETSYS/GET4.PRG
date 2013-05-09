/*****
 *
 * GET4.PRG
 *
 *
 * Compile: Clipper get4 /N /W
 * Link:    RTLINK FI get4
 *
 */

// This will make our life a bit easier
#include "inkey.ch"
#include "setcurs.ch"
#include "set.ch"

FUNCTION Main()
   LOCAL o
   LOCAL nVar := 10.00
   LOCAL lExitRequested := .F.
   LOCAL nKey, cKey
   LOCAL lInsertMode := SET(_SET_INSERT)
   LOCAL cScreen

   cScreen := savescreen()
   SETCOLOR("BG/B,W/GB,,,BG/B")
   SCROLL()

   // Create the Get object
   o := GetNew( 10, 10, {|x| IF(x == NIL, nVar, nVar := x)},,,;
                  "BG/B,GR+/R,,,BG/B" )
   // VALID
   o:postBlock := {|| nVar != 36.23 }
   o:picture   := "9,999,999,999.99"
   o:setFocus()

   WHILE !lExitRequested
      nKey := INKEY(0)
      IF (nKey == K_ESC)
         o:undo()
         lExitRequested := .T.

      ELSEIF (nKey == K_ENTER)
         IF (o:changed)
            o:assign()

         ENDIF
         // VALID?
         IF EVAL( o:postBlock )
            // Ok! Just exit
            lExitRequested := .T.

         ELSE
            o:pos := 1

         ENDIF

      ELSEIF (nKey == K_ALT_U)
         o:undo()

      ELSEIF (nKey == K_ALT_I)
         SETCURSOR( IF( (lInsertMode := !lInsertMode),;
                  SC_SPECIAL1, SC_NORMAL ) )

      ELSEIF (nKey == K_RIGHT)
         o:right()

      ELSEIF (nKey == K_LEFT)
         o:left()

      ELSEIF (nKey == K_DEL)
         o:delete()

      ELSEIF (nKey == K_BS)
         o:backSpace()

      ELSEIF (nKey == K_ALT_K)
         o:delEnd()

      ELSE
         // NOTE!
         IF (nKey >= 32) .AND. (nKey <= 127)
            cKey := CHR(nKey)
            IF cKey == "." .OR. cKey == ","
               o:toDecPos()

            ELSE
               IF lInsertMode
                  o:insert(cKey)

               ELSE
                  o:overstrike(cKey)

               ENDIF

            ENDIF

         ENDIF

      ENDIF

   END

   o:reset()
   o:killFocus()

   // Show contents
   @ 20,10 SAY nVar
   INKEY(5)
   // Bye!
   restscreen(,,,,cScreen)
   RETURN (NIL)

// EOF - GET4.PRG //
