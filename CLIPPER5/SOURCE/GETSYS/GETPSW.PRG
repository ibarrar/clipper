/*****
 *
 * GETPSW.PRG
 *
 * Getting a password and echoing asterisks
 *
 * Clipper getpsw
 *
 */

#include "inkey.ch"
#include "getexit.ch"

#define     ECHO_CHAR     "*"
#define     LOW           32
#define     HIGH          127

/*****
 *
 * Custom reader
 *
 */

FUNCTION MyPsw(oGet)
   LOCAL nRet := GE_NOEXIT
   LOCAL cKey, nKey
   LOCAL cAuxVar, cOriginal
   LOCAL cScreen

   cScreen := savescreen()

   // I am NOT checking for SET KEYs.
   // This is supposed to allow
   // access to whatever ONLY after a
   // valid Password is entered

   // Assuming this is ONLY for password
   // typing, neither WHEN evaluation
   // nor VALID evaluation are performed

   oGet:setFocus()
   oGet:exitState := GE_NOEXIT
   cAuxVar := cOriginal := oGet:original

   // Check for initial typeout
   // (no editable positions)
   IF (oGet:typeOut)
      oGet:exitState := GE_ENTER

   ENDIF
   // Apply keystrokes until exit
   WHILE (oGet:exitState == GE_NOEXIT)
      // Process key
      //
      // WARNING: In order to make it simpler not
      //          all movement keys are handled
      //
      nKey := INKEY(0)
      IF (nKey == K_ENTER)
         oGet:exitState := GE_ENTER

      ELSEIF (nKey == K_ESC)
         cAuxVar := cOriginal
         oGet:undo()
         oGet:exitState := GE_ESCAPE

      ELSEIF (nKey == K_BS)
         cAuxVar := STUFF(cAuxVar, oGet:pos - 1, 1, " ")
         oGet:backSpace()

      ELSE
         // Data Key
         IF (nKey >= LOW) .AND. (nKey <= HIGH)
            cKey := CHR(nKey)
            // Insert character in the auxiliary variable
            // and ECHO_CHAR in the buffer
            cAuxVar := STUFF(cAuxVar, oGet:pos, 1, cKey)
            oGet:insert(ECHO_CHAR)

            // Type-out?
            IF (oGet:typeOut)
               oGet:exitState := GE_ENTER

            ENDIF

         ENDIF

      ENDIF

   END

   // De-activate GET
   oGet:killFocus()

   restscreen(,,,,cScreen)
   RETURN (cAuxVar)

// EOF - GET12.PRG //
