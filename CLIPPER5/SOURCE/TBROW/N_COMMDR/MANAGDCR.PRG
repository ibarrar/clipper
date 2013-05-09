/*****
 *
 * MANAGDCR.PRG
 * Delete, Rename and Copy Functions
 *
 * RMAKE Manager
 *
 */

#include "manager.ch"
#include "inkey.ch"
#include "setcurs.ch"

/*****
 *
 * May I delete?
 *
 */

FUNCTION DeleteOk(cFileName)
   LOCAL nOpt, lStatus := .F.

   // Dialog Box
   nOpt := OkBox( 5, 24, { " Delete ",;
                          "Do you wish to delete",;
                          cFileName,;
                          " Delete ",;
                          " Cancel " } )
   IF nOpt == GO_AHEAD
      lStatus := (FERASE(cFileName) == ERASE_OK)

   ENDIF

   RETURN (lStatus)

/*****
 *
 * May I rename?
 *
 */

FUNCTION RenameOK(cFileName)
   LOCAL cNew, lStatus := .F.
   // Dialog Box
   cNew := PickBox( 5, 2, { " Rename ",;
                          "Rename or Move ",;
                          cFileName,;
                          " Rename ",;
                          " Cancel " } )
   IF !EMPTY(cNew)
      lStatus := (FRENAME(cFileName, cNew) == RENAME_OK)

   ENDIF
   RETURN (lStatus)

/*****
 *
 * May I copy?
 *
 */

FUNCTION CopyOK(cFileName)
   LOCAL cName, lRet := .T.

   // Dialog Box
   cName := PickBox( 5, 2, { " Copy ",;
                             "Copy ",;
                             cFileName,;
                             " Copy ",;
                             " Cancel " } )
   IF !EMPTY(cName)
      COPY FILE (cFileName) TO (cName)
      RETURN (lRet)

   ENDIF
   RETURN (!lRet)

/*****
 *
 * New file name
 *
 */

FUNCTION PickBox( nTop, nLeft, aOpt, cClr )
   LOCAL nBottom, nRight, nOpt, cScr
   LOCAL nPos1, nPos2
   LOCAL cPath, nCurs
   LOCAL GetList[1]

   // I am not using MAXCOL() just because
   // this program is supposed to work ONLY
   // with 80 columns.
   // You can change the number of lines.
   cScr := SAVESCREEN( 0, 0, MAXROW(), 79)

   nOpt    := 1   // Default
   nBottom := nTop + 7
   nRight  := 75
   nPos1   := nLeft + ((nRight - nLeft) / 2) - ;
            LEN(aOpt.boxFirstOpt)
   nPos2   := nPos1 + LEN(aOpt.boxFirstOpt) + 1

   Shadow( nTop + 1, nLeft + 2, nBottom + 1, nRight + 2 )
   cClr := SETCOLOR(IF(cClr == NIL, "N/W,N/BG", cClr))
   SCROLL( nTop, nLeft, nBottom, nRight )
   @ nTop + 1,nLeft + 3 TO nBottom - 1,nRight - 3 DOUBLE
   CentreIt(aOpt.boxTitle,    nTop + 1, nLeft, nRight )
   @ nTop + 2, 7 SAY aOpt.boxMessage + aOpt.boxFileName + " to"
   @ nTop + 4, 6 TO nTop + 4,nRight - 4
   @ nTop + 5,nPos1 SAY aOpt.boxFirstOpt
   @ nTop + 5,nPos2 SAY aOpt.boxSecondOpt
   // Get name and path
   cPath := SPACE(64)
   GetList[1] := GetNew( nTop + 3, 7, {|x| IF(x == NIL, cPath,;
                       cPath := x)}, "cPath" )
   nCurs := SETCURSOR(SC_NORMAL)
   ReadModal( GetList )
   SETCURSOR(nCurs)
   IF LASTKEY() == K_ESC .OR. !UPDATED()
      nOpt := 2

   ENDIF
   // Menu options
   @ nTop + 5,nPos1 PROMPT aOpt.boxFirstOpt
   @ nTop + 5,nPos2 PROMPT aOpt.boxSecondOpt
   MENU TO nOpt

   SETCOLOR(cClr)
   RESTSCREEN( 0, 0, MAXROW(), 79, cScr)
   RETURN (IF(nOpt == GO_AHEAD, cPath, NIL))

/*****
 *
 * This is a "junior" version of
 * ReadModal()
 *
 */

STATIC FUNCTION ModalJr( get )
   LOCAL lExitRequested := .F.
   LOCAL nKey, cKey, lUpdated := .F.

   SETCURSOR(IF(!SET(_SET_INSERT), SC_NORMAL, SC_SPECIAL1))
   // In order to edit the Get you
   // should give it input focus
   get:setFocus()

   // Check for editable positions
   lExitRequested := get:typeOut

   // Keystroke processing loop
   WHILE !lExitRequested
      // Wait for a key and keep the clock
      //
      nKey := WhatKey( , {|r, c, l| r := ROW(),;
                                c := COL(),;
                                l := SETCURSOR(SC_NONE),;
                                SETPOS(  0, 71 ),;
                                DEVOUT( TIME(), "N/BG" ),;
                                DEVPOS(r, c),;
                                SETCURSOR(l)} )
      // Process It
      IF (nKey == K_ESC)
         // Abort!
         get:undo()
         get:reset()
         RETURN (lUpdated)

      ELSEIF (nKey == K_ENTER)
         // Normal termination
         lExitRequested := .T.

      ELSEIF (nKey == K_CTRL_U)
         get:undo()

      ELSEIF (nKey == K_RIGHT)
         // Move cursor one position to the right
         get:right()

      ELSEIF (nKey == K_HOME)
         // Move cursor to the left-most position
         get:home()

      ELSEIF (nKey == K_END)
         // Move cursor to the right-most position
         get:end()

      ELSEIF (nKey == K_CTRL_RIGHT)
         // Move cursor right one word
         get:wordRight()

      ELSEIF (nKey == K_CTRL_LEFT)
         // Move cursor left one word
         get:wordLeft()

      ELSEIF (nKey == K_LEFT)
         // Move cursor one position to the left
         get:left()

      ELSEIF (nKey == K_DEL)
         // Delete character under cursor
         get:delete()

      ELSEIF (nKey == K_BS)
         // Delete character to the left of the cursor
         get:backSpace()

      ELSEIF (nKey == K_ALT_K)
         // Delete from cursor until end of line
         get:delEnd()

      ELSEIF (nKey == K_INS)
         // Insert Key will toggle between insert/overstrike
         SET(_SET_INSERT,!SET(_SET_INSERT))
         SETCURSOR(IF(SET(_SET_INSERT), SC_SPECIAL1,;
                   SC_NORMAL))

      ELSE
         // Data Keys
         IF (nKey >= 32) .AND. (nKey <= 127)
            cKey := CHR(nKey)
            // Check for Numbers
            IF (get:type == "N") .AND. ;
               (cKey == "," .OR. cKey == ".")
               get:toDecPos()
               // Moves the cursor to the immediate position
               // of the decimal point in the editing buffer

            ELSE
               // Send it to Get
               IF SET(_SET_INSERT)
                  // Inserts character into the editing buffer
                  // at the current cursor position, shifting
                  // the existent contents of the buffer to the
                  // right
                  get:insert(cKey)

               ELSE
                  // Puts character into the editing buffer at
                  // the current cursor position, overwriting
                  // the existent contents.
                  get:overstrike(cKey)

               ENDIF

            ENDIF

         ENDIF

      ENDIF

   END

   IF (lUpdated := get:changed)
      // Indicates wheater the get:buffer has changed
      get:assign() // Assigns the value in the editing buffer
                   // to the Get variable

   ENDIF
   // resets the editing buffer to reflect the current value
   get:reset()
   // Take out input focus
   get:killFocus()
   SETCURSOR(SC_NONE)
   RETURN (lUpdated)

// EOF - MANAGDCR.PRG //
