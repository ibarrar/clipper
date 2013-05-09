/*****
 *
 * GET3.PRG
 *
 * Compile: Clipper get3 /N /W
 * Link:    RTLINK FI Get3
 *
 */

// This will make our life a bit easier
#include "inkey.ch"
#include "setcurs.ch"
#include "set.ch"

FUNCTION Main()
   LOCAL o
   LOCAL cVar := "This is a Get Object" + SPACE(20)
   LOCAL lExitRequested := .F.
   LOCAL nKey, cKey
   LOCAL lInsertMode := SET(_SET_INSERT)
   LOCAL cScreen

   cScreen := savescreen()
   SETCOLOR("BG/B,W/GB,,,BG/B")
   SCROLL()

   // Create the Get object
   o := GetNew( 10, 10, {|x| IF(x == NIL, cVar, cVar := x)},,,;
                  "BG/B,GR+/R,,,BG/B" )
   o:setFocus()

   WHILE !lExitRequested
      nKey := INKEY(0)
      IF (nKey == K_ESC)
         o:undo()
         lExitRequested := .T.

      ELSEIF (nKey == K_ENTER)
         lExitRequested := .T.

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
            IF lInsertMode
               // Insert Character
               // get:insert(character)
               // Inserts character into the editing buffer
               // at the current cursor position, shifting
               // the existent contents of the buffer to the
               // right. The cursor is place one position
               // to the right of the inserted character
               o:insert(cKey)

            ELSE
               // Overstrike Character
               // get:overstrike(character)
               // Puts character into the editing buffer at the
               // current cursor position, overwriting the
               // existent contents. The cursor is placed one
               // position to the right of the overwriten
               // character
               o:overstrike(cKey)

            ENDIF

         ENDIF

      ENDIF

   END

   // get:changed
   // This instance variable contains a logical value
   // indicating wheater the get:buffer has changed
   // since the Get received input focus
   IF (o:changed)
      // get:assign()
      // Assigns the value in the editing buffer to
      // the Get variable
      o:assign()

   ENDIF

   // Reset
   // Resets the Get object's internal state information.
   // This includes reseting the editing buffer to reflect
   // the current value
   o:reset()

   // Take out input focus
   o:killFocus()

   // Show contents
   @ 20,10 SAY cVar
   INKEY(5)
   // Bye!
   restscreen(,,,,cScreen)
   RETURN (NIL)

// EOF - GET3.PRG //
