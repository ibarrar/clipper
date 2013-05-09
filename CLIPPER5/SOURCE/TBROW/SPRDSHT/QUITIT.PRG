/*****
 *
 * QUITIT.PRG
 * General purpose EXIT warning box
 *
 *
 */

#include "inkey.ch"

#define        CONTINUE             2
#define        QUIT                 1

FUNCTION ExitBox( nTop, nLeft, bBlock, cTitle,;
                  nWait, bSaver )
   LOCAL cScr, cClr, cLine, nKey, nOpt, cButScr
   LOCAL aQuit, aCont
   LOCAL lBlink := SETBLINK(.F.)

   // If you are going to use this function in
   // your programs, take special care about colors
   // since I am always using SETBLINK(FALSE)

   nTop   := IF(nTop == NIL, 10, nTop)
   nLeft  := IF(nLeft == NIL, 18, nLeft)
   bBlock := IF(bBlock == NIL, {|| .F.}, bBlock)
   cTitle := IF(cTitle == NIL, "", cTitle)
   nWait  := IF(nWait == NIL, 0, nWait)
   bSaver := IF(bSaver == NIL, {|| .F.}, bSaver)

   aQuit := CreateButtom( nTop + 5, nLeft + 7, "E^xit" )
   aCont := CreateButtom( nTop + 5, nLeft + 18, "^Continue" )

   DISPBEGIN()
   cScr := SAVESCREEN( nTop, nLeft, nTop + 8, nLeft + 36)
   cClr := SETCOLOR("N/W")

   Shadow( nTop + 1, nLeft + 2, nTop + 8, nLeft + 36)
   SCROLL( nTop, nLeft, nTop + 7, nLeft + 34)
   @ nTop,nLeft SAY " - " COLOR "W+/N*"
   @ nTop,nLeft + 3 SAY " Exit " + ;
                  SUBSTR(cTitle + SPACE(26), 1, 26) ;
                  COLOR "N/GR*"
   @ nTop + 2,nLeft + 4  SAY "Do you really want to Exit?"

   // Paint buttons
   SelectButtom(aQuit)
   UnSelectButtom(aCont)

   // Save last line
   cLine := SAVESCREEN( MAXROW(), 0, MAXROW(), MAXCOL() )
   @ MAXROW(), 0 SAY SPACE(MAXCOL() + 1) COLOR "W+/BG"
   @ MAXROW(), 0 SAY "Press Enter to exit the " + cTitle +;
                    " program or ESC to resume"
   DISPEND()

   nOpt := QUIT
   WHILE .T.
      IF nOpt == QUIT
         DISPBEGIN()
         SelectButtom(aQuit )
         UnSelectButtom(aCont)
         @ MAXROW(), 0 SAY SPACE(MAXCOL() + 1) COLOR "W+/BG"
         @ MAXROW(), 0 SAY "Press Enter to exit the " +;
                          cTitle +;
                          " program or ESC to resume" ;
                          COLOR "W+/BG"
         DISPEND()

      ELSE
         DISPBEGIN()
         UnselectButtom(aQuit)
         SelectButtom(aCont)
         @ MAXROW(), 0 SAY SPACE(MAXCOL() + 1) COLOR "W+/BG"
         @ MAXROW(), 0 SAY "Press Enter to resume the " +;
                          cTitle +;
                          " program" COLOR "W+/BG"
         DISPEND()

      ENDIF
      WHILE ((nKey := WhatKey( nWait, bBlock)) == 0)
         EVAL( bSaver )

      END
      IF nKey == K_TAB
         nOpt := IF(nOpt == QUIT, CONTINUE, QUIT)

      ELSEIF UPPER(CHR(nKey)) == "X"
         UnSelectButtom(aQuit)
         UnSelectButtom(aCont)
         SelectButtom(aQuit)
         PressButtom(aQuit)
         nOpt := QUIT
         EXIT

      ELSEIF UPPER(CHR(nKey)) == "C"
         UnSelectButtom(aQuit)
         UnSelectButtom(aCont)
         SelectButtom(aCont)
         PressButtom(aCont)
         nOpt := CONTINUE
         EXIT

      ELSEIF nKey == K_ENTER
         IF nOpt == QUIT
            PressButtom(aQuit)

         ELSE
            PressButtom(aCont)

         ENDIF
         EXIT

      ELSEIF nKey == K_ESC
         UnSelectButtom(aQuit)
         UnSelectButtom(aCont)
         SelectButtom(aCont)
         PressButtom(aCont)
         nOpt := CONTINUE
         EXIT

      ENDIF

   END
   RESTSCREEN( nTop, nLeft, nTop + 8, nLeft + 36, cScr )
   RESTSCREEN( MAXROW(), 0, MAXROW(), MAXCOL() + 1, cLine )
   SETCOLOR( cClr )
   SETBLINK(lBlink)
   RETURN (nOpt == QUIT)

// EOF - QUITIT.PRG //
