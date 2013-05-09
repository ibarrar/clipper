/*****
 *
 * GET2.PRG
 *
 *
 * Compile: Clipper get2 /N /W
 * Link:    RTLINK FI Get2
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
   LOCAL nKey
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
         // Abort!
         // First, put the things as before
         // o:undo()
         // sets the variable back to the value it had when
         // the Get acquired input focus.
         // The effect of get:undo() is equivalent to assigning
         // the Get variable from get:original and then sending
         // the message get:reset()
         o:undo()
         lExitRequested := .T.

      ELSEIF (nKey == K_ENTER)
         // Normal termination
         lExitRequested := .T.

      ELSEIF (nKey == K_ALT_U)
         // Undo the editing
         o:undo()

      ELSEIF (nKey == K_ALT_I)
         // Toggle between insert/overstrike
         SETCURSOR( IF( (lInsertMode := !lInsertMode),;
                  SC_SPECIAL1, SC_NORMAL ) )

      ELSEIF (nKey == K_RIGHT)
         // Move cursor one position to the right
         // within the editing buffer
         o:right()

      ELSEIF (nKey == K_LEFT)
         // Move cursor one position to the left
         o:left()

      ELSEIF (nKey == K_DEL)
         // Delete character under cursor
         o:delete()

      ELSEIF (nKey == K_BS)
         // Delete character to the left of the cursor
         // moving the cursor one position to the left
         o:backSpace()

      ELSEIF (nKey == K_ALT_K)
         // Delete from cursor until end of line
         o:delEnd()

      ENDIF

   END

   // Take out input focus
   o:killFocus()

   @ 20,10 SAY cVar
   INKEY(5)
   restscreen(,,,,cScreen)
   RETURN NIL

// EOF - GET2.PRG //
