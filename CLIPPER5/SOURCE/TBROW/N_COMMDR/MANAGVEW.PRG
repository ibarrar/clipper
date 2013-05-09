/*****
 *
 * MANAGVEW.PRG
 * Text file edit
 *
 *
 * RMAKE manager
 *
 */

#include "inkey.ch"
#include "memoedit.ch"
#include "setcurs.ch"
#include "manager.ch"

FUNCTION ShowIt(cFileName, lEditMode)
   LOCAL cContents
   LOCAL cScr, cClr, nCurs

   // DO NOT allow view of .OBJ, .LIB and .EXE files
   IF (".obj" $ cFileName) .OR. (".exe" $ cFileName) .OR.;
      (".lib" $ cFileName)
      RETURN (NIL)

   ENDIF
   // WARNING: MEMOREAD() will read ONLY 64 Kb
   cContents := MEMOREAD(cFileName)

   // Screen (section not handled by MEMOEDIT())
   cScr  := SAVESCREEN( 0, 0, MAXROW(), 79)
   cClr  := SETCOLOR("BG+/B")
   IF lEditMode
      nCurs := SETCURSOR(SC_NORMAL)

   ENDIF
   @  0, 0 SAY SPACE(80) COLOUR "N/BG"
   @  0, 0 SAY IF(lEditMode, "Edit: ", "View: ") +;
               cFileName COLOUR "N/BG"
   @  0,60 SAY "Line:" COLOUR "N/BG"
   @  0,72 SAY "Col:"  COLOUR "N/BG"
   BottLine()
   @ MAXROW(),74 SAY "Exit" COLOUR "N/BG"
   // Screen (handled by MEMOEDIT())
   //
   MEMOEDIT( cContents, 1, 0, MAXROW() - 1, 79,;
            lEditMode, "memovew", 250 )
   RESTSCREEN( 0, 0, MAXROW(), 79, cScr)
   SETCOLOR(cClr)
   IF lEditMode
      SETCURSOR(nCurs)

   ENDIF
   RETURN (NIL)

/*****
 *
 * You cannot declare this function as
 * STATIC, since MEMOEDIT() will call it
 * via macro.
 *
 */

FUNCTION MemoVew( nMode, nLin, nCol )
   LOCAL nKey, nRet

   nRet := ME_DEFAULT
   nKey := LASTKEY()

   IF nMode == ME_IDLE
      @  0,66 SAY nLin PICTURE "9999" COLOUR "N/BG"
      @  0,77 SAY nCol PICTURE "999"  COLOUR "N/BG"

   ELSEIF nMode == ME_UNKEY .OR. nMode == ME_UNKEYX
      IF nKey == K_F10
         nRet := 27    // ESCape

      ENDIF

   ENDIF

   RETURN (nRet)

// EOF - MANAGVEW.PRG //
