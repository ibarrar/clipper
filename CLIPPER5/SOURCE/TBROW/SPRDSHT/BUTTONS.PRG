/*****
 *
 * BUTTONS.PRG
 * Button Routines
 *
 *
 * WARNING: These functions are not supposed to
 *          save/restore any part of the screen.
 *          The only thing they save/restore is
 *          the SETBLINK() status, since I am using
 *          bright background colours.
 *
 */

#include "buttons.ch"

/*****
 *
 * Creates a Button
 *
 */

FUNCTION CreateButtom( nRow, nCol, cStr )
   LOCAL aArray[SIZE]
   LOCAL nAt

   // Highlight on selected letter
   // (defaults to the first letter on string)
   IF (nAt := AT("^", cStr)) == 0
      cStr := "  ^" + cStr + "  "
      nAt  := 3

   ELSE
      cStr := "  " + cStr + "  "
      nAt  += 2

   ENDIF

   // Build String
   aArray.butStr := SUBSTR(cStr, 1, nAt - 1) +;
                  SUBSTR(cStr, nAt + 1)
   aArray.len    := LEN(aArray.butStr)
   aArray.letCol := nCol + nAt - 1
   aArray.butLet := SUBSTR(aArray.butStr, nAt, 1)

   // Where
   aArray.row       := nRow
   aArray.col       := nCol
   aArray.ShadRow   := nRow + 1
   aArray.ShadCol   := nCol + 1
   aArray.upShadCol := nCol + aArray.len

   RETURN (aArray)

/*****
 *
 * Paints a Button
 *
 */

STATIC FUNCTION PaintButtom( aArray, lSelected, lShadow )
   LOCAL cThisClr, nAt
   LOCAL lBlink := SETBLINK(FALSE)

   lSelected := IF(lSelected == NIL, TRUE, lSelected)
   lShadow   := IF(lShadow == NIL, TRUE, lShadow)

   DISPBEGIN()
   // String
   @ aArray.row,aArray.col SAY aArray.butStr ;
   COLOR IF(lSelected, BUTTOMBGHI, BUTTOMBGLO)
   // Letter
   @ aArray.row,aArray.letCol SAY aArray.butLet ;
   COLOR IF(lSelected, BUTTOMLETHI, BUTTOMLETLO)

   // Shadow?
   IF lShadow
      // Keep same background COLOR
      cThisClr := SETCOLOR()
      nAt := AT("/" , cThisClr)
      cThisClr := "N" + SUBSTR(cThisClr, nAt)
      @ aArray.shadRow,aArray.shadCol SAY ;
      REPLICATE(CHR(223), aArray.len);
      COLOR cThisClr
      @ aArray.row,aArray.upShadCol SAY CHR(220);
      COLOR cThisClr

   ENDIF

   DISPEND()
   SETBLINK(lBlink)
   RETURN (NIL)

/*****
 *
 * Selects a Button
 *
 */

FUNCTION SelectButtom( aArray, lShadow )
   lShadow := IF(lShadow == NIL, TRUE, lShadow)

   PaintButtom(aArray, TRUE, lShadow)

   RETURN (NIL)

/*****
 *
 * Unselects a Button
 *
 */

FUNCTION UnselectButtom( aArray, lShadow )
   lShadow := IF(lShadow == NIL, TRUE, lShadow)

   PaintButtom(aArray, FALSE, lShadow)

   RETURN (NIL)

/*****
 *
 * "Presses" a Button
 *
 */

FUNCTION PressButtom( aArray, lSelected, lShadow )
   LOCAL lBlink := SETBLINK(.F.)

   lShadow   := IF(lShadow == NIL, TRUE, lShadow)
   lSelected := IF(lSelected == NIL, TRUE, lSelected)

   //
   // Assuming current background COLOR
   //

   // Blank button
   DISPBEGIN()
   @ aArray.row,aArray.col SAY SPACE(aArray.len + 1)
   @ aArray.shadRow,aArray.shadCol SAY SPACE(aArray.len)
   // String
   @ aArray.shadRow,aArray.shadCol + 1 SAY ;
   aArray.butStr COLOR IF(lSelected, BUTTOMBGHI, BUTTOMBGLO)
   // Letter
   @ aArray.shadRow,aArray.letCol + 2 SAY ;
   aArray.butLet COLOR IF(lSelected, BUTTOMLETHI, BUTTOMLETLO)
   DISPEND()
   INKEY(.5)
   @ aArray.shadRow,aArray.shadCol + 1 SAY SPACE(aArray.len)
   PaintButtom(aArray, lSelected, lShadow)
   INKEY(.3)

   SETBLINK(lBlink)
   RETURN (NIL)

// EOF - BUTTONS.PRG //
