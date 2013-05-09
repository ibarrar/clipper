/*****
 *
 * SPRDSHT.PRG
 * A TBrowse Spreadsheet
 *
 * WARNING: This program is based in a 80 column
 *          screen. What, of course, can be easily
 *          changed!
 *
 */

#include "inkey.ch"
#include "setcurs.ch"
#include "error.ch"
#include "sprdsht.ch"

/*****
 *
 * Main Function
 *
 */

FUNCTION Sheet(nWait)
   LOCAL b, k, nKey, c, w, g
   LOCAL column, nMaxRow, nMaxCol
   LOCAL aBlocks[MAXLEN, 6]
   LOCAL i, aInfo, aCalc, aTgON, aEdFo, aTgOF, aEdNu
   LOCAL aCurtain
   LOCAL lAutoCalc     := .T.
   LOCAL lNeedToReCalc := .F.
   // You cannot declare both arrays
   // as LOCAL because we are using a macro
   // to create the data retrieval block.
   // If you want to avoid the macro, see comment below.
   // The same applies to nSubscript.
   MEMVAR aArray, aFormulas, nSubscript

   // Init
   nWait   := IF(nWait != NIL, VAL(nWait), NIL)
   nMaxRow := MAXROW()
   nMaxCol := MAXCOLUMN
   aArray     := ARRAY(MAXLEN, 6)
   aFormulas  := ARRAY(MAXLEN, 6)
   k          := 0
   nSubscript := 1
   nKey       := 0

   // Load Arrays
   ReadSpreadSheet(aArray, VALUES)
   ReadSpreadSheet(aFormulas, FORMULAS)

   // Calculate all formulas
   Calculus(aArray, aFormulas, aBlocks)

   // Screen (section not handled by TBrowse)
   // Save the "curtain"
   aCurtain := SaveCurtain()

   SETCURSOR(SC_NONE)
   SET SCOREBOARD OFF
   SETBLINK(.F.)
   PaintScreen()

   // Create buttons
   aInfo := CreateButtom( nMaxRow - 2,  5, "^Info" )
   aTgON := CreateButtom( nMaxRow - 2, 18, "^Autocalc ON " )
   aTgOF := CreateButtom( nMaxRow - 2, 18, "^Autocalc OFF" )
   aEdFo := CreateButtom( nMaxRow - 2, 39, "^Edit Formulas" )
   aEdNu := CreateButtom( nMaxRow - 2, 39, "^Edit Numbers " )
   aCalc := CreateButtom( nMaxRow - 2, 61, "^Calculate" )
   // Paint buttoms
   SelectButtom(aInfo)
   SelectButtom(aEdFo)
   SelectButtom(aTgON)
   SelectButtom(aCalc)

   // TBrowse object for values
   b := TBrowseNew( 3, 6, nMaxRow - 4, MAXCOLUMN - 2)
   b:skipBlock := {|x| ;
                  k := IF(ABS(x) >= IF(x >= 0,;
                  MAXLEN - nSubscript, nSubscript - 1),;
                  IF(x >= 0, MAXLEN - nSubscript,1 - nSubscript),;
                  x), nSubscript += k,;
                  k }
   b:goTopBlock    := {|| nSubscript := 1}
   b:goBottomBlock := {|| nSubscript := MAXLEN}
   // Colour table for the browse object
   b:colorSpec := COLORTABLE

   // Create each column
   FOR i := 1 TO 6
      column := TBColumnNew(,;
               &("{|p| IF(p == NIL, VAL(STR(aArray[nSubscript," +;
               LTRIM(STR(i)) + "],10,2)), aArray[nSubscript," +;
               LTRIM(STR(i)) + "] := p)}"))
      column:width := 11
      column:colorBlock := {|x| IF(x < 0, {5,2},;
                                IF(x > 0, {8,2}, {4,2}))}
      column:colSep := NOTHING
      b:addColumn(column)

   NEXT
   // You can create each column without macros
   // repeating this code six times (1 to 6)
   // column := TBColumnNew(,{|p| IF(p == NIL,;
   //                       aArray[nSubscript,1],;
   //                       aArray[nSubscript,1] := p)})
   // column:width := 11
   // b:addColumn(column)
   //
   // Doing so, you can declare aArray as LOCAL
   // since it will not be macroed. Same applies to
   // the nSubscript variable.

   // TBrowse object for formulas
   c := TBrowseNew( 3, 6, nMaxRow - 4, MAXCOLUMN - 2)
   // Skip Block
   c:skipBlock := {|x| ;
                  k := IF(ABS(x) >= IF(x >= 0,;
                  MAXLEN - nSubscript, nSubscript - 1),;
                  IF(x >= 0, MAXLEN - nSubscript,1 -;
                  nSubscript), x), nSubscript += k,;
                  k }
   c:goTopBlock    := {|| nSubscript := 1}
   c:goBottomBlock := {|| nSubscript := MAXLEN}
   c:colorSpec := COLORTABLE

   // Create each column
   FOR i := 1 TO 6
      column := TBColumnNew(,;
               &("{|p| IF(p == NIL, aFormulas[nSubscript," +;
               LTRIM(STR(i)) + "], aFormulas[nSubscript," +;
               LTRIM(STR(i)) + "] := p)}"))
      column:width := 10
      column:colSep := NOTHING
      column:defColor := {5,7}
      c:addColumn(column)

   NEXT
   // You can create each column without macros
   // repeating this code six times (1 to 6)
   // column := TBColumnNew(,{|p| IF(p == NIL,;
   //                       aFormulas[nSubscript,1],;
   //                       aFormulas[nSubscript,1] := p)})
   // c:addColumn(column)
   //
   // Doing so, you can declare aFormulas as LOCAL
   // since it will not be macroed. Same applies to
   // nSubscript variable.

   // Current object will be data
   w := b

   // Main loop
   WHILE .T.
      // Stabilize it!
      // DispBegin() and DispEnd() are used to get rid
      // of that line by line display
      //
      DISPBEGIN()
      WHILE (!w:stabilize())
      END
      @ MAXROW(), 0;
      SAY PADR( EVAL ( (c:getColumn(w:colPos)):block ),;
                  MAXCOLUMN + 1 ) COLOR FIRSTLINE
      DISPEND()
      IF w:stable()
         // The "Running Letters"
         // and the "Screen Saver"
         IF ((nKey := WhatKey( nWait, {|| Touchy()})) == 0)
            ScreenBlanker()
            // Repaint browse screen
            w:invalidate()
            LOOP

         ENDIF

      ENDIF
      IF !MoveIt(nKey, w)
         // Keystroke was not handled by MoveIt()
         IF nKey == K_ENTER
            IF (w == b) .AND. ;
               !EMPTY(EVAL((c:getColumn(w:colPos)):block))
               // Formula exists for this cell!
               // Do not allow editing!
               LOOP
               // Edit current object
               lNeedToReCalc := DoGet( w )

            ENDIF
            // Edit current object
            lNeedToReCalc := DoGet( w )
            IF lAutoCalc .AND. lNeedToReCalc
               // Evaluate all code blocks
               CalcBlocks(aArray, aBlocks)
               w:refreshAll()
               lNeedToReCalc := .F.

            ENDIF

         ELSEIF nKey == K_ESC .OR. ;
               nKey == K_ALT_X .OR. ;
               nKey == K_ALT_F4
            IF ExitBox( 8, 24, {|| Touchy()}, "Sprdsht",;
                       nWait, {|| ScreenBlanker()} )
               // Bye for now!
               // Do not forget to save the work!
               SaveValues(aArray)
               SaveFormulas(aFormulas)
               RestoreCurtain(aCurtain)
               EXIT

            ENDIF

         ELSEIF nKey == ASC("E") .OR.;
               nKey == ASC("e")
            // Shift between Formulas/Values
            IF (w == b)
               // Entering EDIT FORMULAS mode
               // turn Recalculation OFF
               lAutoCalc := .F.
               PressButtom(aEdFo)
               SelectButtom(aEdNu)
               SelectButtom(aTgOF)
               w := c

            ELSE
               // Entering EDIT NUMBERS mode
               // turn Recalculation ON
               lAutoCalc := .T.
               // Rebuild all Codeblocks
               //
               Calculus(aArray, aFormulas, aBlocks)
               PressButtom(aEdNu)
               SelectButtom(aEdFo)
               SelectButtom(aTgON)
               w := b

            ENDIF
            EVAL(w:goTopBlock)
            w:refreshAll()

         ELSEIF nKey == ASC("C") .OR.;
               nKey == ASC("c")
            IF (w == b)
               // Calculus, calculus, calculus...
               PressButtom(aCalc)
               Calculus(aArray, aFormulas, aBlocks)
               w:refreshAll()

            ENDIF

         ELSEIF nKey == ASC("I") .OR.;
               nKey == ASC("i")
            PressButtom(aInfo)
            NeedHelp( nWait, {|| Touchy()} )

         ELSEIF nKey == ASC("A") .OR.;
               nKey == ASC("a")
            // Disabled while in Edit Formulas mode
            IF (w == b)
               // Toggle Automatic Recalculation
               // Be aware about one fact:
               // Even if you turned Recalculation OFF,
               // every time you enter in the editing vales mode
               // recalculation will be turned ON!
               //
               lAutoCalc := !lAutocalc
               IF lAutoCalc
                  PressButtom(aTgON)

               ELSE
                  PressButtom(aTgOF)

               ENDIF

            ENDIF

         ENDIF

      ENDIF

   END
   RETURN (NIL)

/*****
 *
 * Initialize array elements
 *
 */

STATIC FUNCTION ReadSpreadSheet(PointerToArray, ReadWhat)
   // Since arrays are references
   // Values stored into PointerToArray[x,y]
   // are stored into the array above since
   // arrays are always passed by reference
   LOCAL k := 1

   IF ReadWhat == VALUES
      IF FILE("SprdVal.dbf")
         DBUSEAREA( .F., "DbfNtx", "SprdVal" )
         // Load array from database
         AEVAL(PointerToArray,;
            {|x,i| IF(k != i,;
            EVAL({|m| DBSKIP(), k := m }, i), NIL),;
            AEVAL(x, {|y,j| ;
            PointerToArray[k,j] := FIELDGET(j)})})
         DBCLOSEAREA()

      ELSE
         // Database not found!
         // Initialize array elements
         AEVAL(PointerToArray,;
               {|x| AEVAL(x, { |y,j| ;
               PointerToArray[k,j] := 0.00}),;
               ++k})

      ENDIF

   ELSE
      IF FILE("SprdFor.dbf")
         DBUSEAREA( .F., "DbfNtx", "SprdFor" )
         // Load array from database
         AEVAL(PointerToArray,;
            {|x,i| IF(k != i,;
            EVAL({|m| DBSKIP(), k := m }, i), NIL),;
            AEVAL(x, {|y,j| ;
            PointerToArray[k,j] := FIELDGET(j) }) })
         DBCLOSEAREA()

      ELSE
         // Database not found!
         // Initialize array elements
         AEVAL(PointerToArray,;
               { |x| AEVAL(x, { |y,j| ;
               PointerToArray[k,j] := SPACE(30)}),;
               ++k})

      ENDIF

   ENDIF
   RETURN (NIL)

/*****
 *
 * Saves values to a database file
 *
 */

STATIC FUNCTION SaveValues(PointerToArray)
   LOCAL aStructure, k
   LOCAL lFile := .F.

   IF (lFile := !FILE("SprdVal.dbf"))
      aStructure := { { "COL1", "Numeric", 10, 2 },;
                    { "COL2", "Numeric", 10, 2 },;
                    { "COL3", "Numeric", 10, 2 },;
                    { "COL4", "Numeric", 10, 2 },;
                    { "COL5", "Numeric", 10, 2 },;
                    { "COL6", "Numeric", 10, 2 } }
      DBCREATE("SprdVal", aStructure)

   ENDIF

   DBUSEAREA( .F., "DbfNtx", "SprdVal" )
   ReplaceData(PointerToArray, lFile)
   DBCLOSEAREA()
   RETURN (NIL)

/*****
 *
 * Saves formulas to a database file
 *
 */

STATIC FUNCTION SaveFormulas(PointerToArray)
   LOCAL aStructure, k
   LOCAL lFile := .F.

   IF (lFile := !FILE("SprdFor.dbf"))
      aStructure := { { "COL1", "Character", 30, 0 },;
                    { "COL2", "Character", 30, 0 },;
                    { "COL3", "Character", 30, 0 },;
                    { "COL4", "Character", 30, 0 },;
                    { "COL5", "Character", 30, 0 },;
                    { "COL6", "Character", 30, 0 } }
      DBCREATE("SprdFor", aStructure)

   ENDIF
   DBUSEAREA( .F., "DbfNtx", "SprdFor" )
   ReplaceData(PointerToArray, lFile)
   DBCLOSEAREA()
   RETURN (NIL)

/*****
 *
 * Actually replaces data into database file
 *
 */

STATIC FUNCTION ReplaceData(PointerToArray, lLogic)
   LOCAL k
   IF lLogic
      k := 0
      // Empty database
      AEVAL(PointerToArray,;
         {|x,i| IF(k != i, EVAL({|m| DBAPPEND(), k := m }, i),;
         NIL),;
         AEVAL(x, {|y,j| FIELDPUT(j, PointerToArray[k,j]) }) })

   ELSE
      // Non-empty database
      k := 1
      AEVAL(PointerToArray,;
         {|x,i| IF(k != i, EVAL({|m| DBSKIP(), k := m }, i),;
         NIL),;
         AEVAL(x, {|y,j| FIELDPUT(j, PointerToArray[k,j]) }) })

   ENDIF
   RETURN (NIL)

/*****
 *
 * A nice display (I hope!)
 *
 */

STATIC FUNCTION Touchy()
  LOCAL cStr  := PAGEHEADER
  STATIC nCnt := 0
  LOCAL nLen  := LEN(PAGEHEADER) - 1

  // Regular Line
  @  0, TCenter(PAGEHEADER) SAY cStr COLOR FIRSTLINE
  @  0, TCenter(PAGEHEADER) + nCnt ;
        SAY SUBSTR( cStr, nCnt + 1, 1) COLOR HEADCLR
  IF (++nCnt > nLen)
     nCnt := 0

  ENDIF
  RETURN (NIL)

/*****
 *
 * Translates formula into a codeblock
 *
 */

STATIC FUNCTION ConvertIt(cToBeXlated)
   LOCAL cXlated := NOTHING
   LOCAL cTemp   := NOTHING
   LOCAL nLen
   LOCAL i := 1
   LOCAL aXlateArray

   // Empty cell
   IF EMPTY(cToBeXlated)
      RETURN ("{|aArray| .T.}")

   ENDIF

   // Take spaces out
   cToBeXlated := STRTRAN(cToBeXlated, " ", NOTHING)
   nLen        := LEN(cToBeXlated)
   aXlateArray := ARRAY(nLen)
   // Transfer each character of the original string
   // to an array element
   AEVAL(aXlateArray, {|x,i| ;
         aXlateArray[i] := SUBSTR(cToBeXlated,i,1)})
   // Handle it
   WHILE (i <= nLen)
      IF ELEMENT $ "0123456789"
         cTemp += ELEMENT

      ELSEIF ELEMENT $ "(/+-*)."
         cTemp += ELEMENT

      ELSEIF ELEMENT == "A"
         cTemp += "aArray["
         cTemp += WhatItIs(aXlateArray, @i)
         cTemp += ",1]"

      ELSEIF ELEMENT == "B"
         cTemp += "aArray["
         cTemp += WhatItIs(aXlateArray, @i)
         cTemp += ",2]"

      ELSEIF ELEMENT == "C"
         cTemp += "aArray["
         cTemp += WhatItIs(aXlateArray, @i)
         cTemp += ",3]"

      ELSEIF ELEMENT == "D"
         cTemp += "aArray["
         cTemp += WhatItIs(aXlateArray, @i)
         cTemp += ",4]"

      ELSEIF ELEMENT == "E"
         cTemp += "aArray["
         cTemp += WhatItIs(aXlateArray, @i)
         cTemp += ",5]"

      ELSEIF ELEMENT == "F"
         cTemp += "aArray["
         cTemp += WhatItIs(aXlateArray, @i)
         cTemp += ",6]"

      ELSE
         // Invalid Character
         // Assume no formula given
         cTemp := "{|aArray| .T.}"
         EXIT

      ENDIF
      ++i

   END
   IF !("T" $ cTemp)
      cTemp := "{|aArray| " + cTemp + "}"

   ENDIF
   RETURN (cTemp)

STATIC FUNCTION WhatItIs(aXlateArray, i)
   LOCAL cTemp := NOTHING
   LOCAL nLen  := LEN(aXlateArray)

   i++
   WHILE (ELEMENT $ "0123456789")
      cTemp += aXlateArray[i++]
      IF i > nLen
         EXIT

      ENDIF

   END
   --i
   RETURN (cTemp)

/*****
 *
 * Calculus, calculus, calculus...
 *
 * Calculation is columnwise
 * top to bottom
 *
 */

STATIC FUNCTION Calculus(aArray, aFor, aBlock)
   LOCAL i, j, k, oOldHandler
   // First build the codeblocks
   // based in the formulas
   // You can use FOR...NEXT
   // or AEVAL()
   // This one uses AEVAL()
   //
   // Avoid crashes!
   // Just in case someone typed a "strange" formula
   //
   // Post your handler
   oOldHandler := ERRORBLOCK({|e| Oops(e, oOldHandler)})
   AEVAL(aFor, {|x,i| k := i,;
         AEVAL(x, {|y,j| aBlock[k,j] := &(ConvertIt(y))})})
   // Original handler
   ERRORBLOCK(oOldHandler)
   // Blocks built!
   // This one uses FOR...NEXT
   // to evaluate each one
   //
   CalcBlocks(aArray, aBlock)
   RETURN (NIL)

/*****
 *
 * Evaluates array with codeblocks
 *
 */

STATIC FUNCTION CalcBlocks(aArray, aBlocks)
   LOCAL i, j, k
   //
   // You can use AEVAL() in lieu of FOR...NEXT
   //
   FOR i := 1 TO MAXLEN
      FOR j := 1 TO 6
         k := EVAL(aBlocks[i,j], aArray)
         IF VALTYPE(k) == "N"
            // Force it to the size of 10
            aArray[i,j] := VAL(STR(k,10,2))

         ENDIF

      NEXT

   NEXT
   RETURN (NIL)

/*****
 *
 * Recovery against mistyped formulas
 *
 */

STATIC FUNCTION Oops(e, oOldHandler)
   LOCAL oWhatsUpDoc
   IF (e:operation $ "&") .AND.;
      (e:genCode == EG_SYNTAX)
      // Someone typed a wrong formula.
      // Ignore the wrong one.
      // Replace it with:
      RETURN &("{|aArray| .T.}")

   ENDIF
   // I DO NOT know what is going on!
   // So, create an error object and
   // pass it to the old handler
   // This case should not happen!
   oWhatsUpDoc := ERRORNEW()
   oWhatsUpDoc:description := "YourError() failed"
   oWhatsUpDoc:severity    := ES_CATASTROPHIC     // Gosh!
   oWhatsUpDoc:genCode     := 99
   oWhatsUpDoc:subCode     := 9999
   oWhatsUpDoc:operation   := "Problem found when replacing; "+;
                             "a mistyped formula"
   // Raise the error
   RETURN EVAL(oOldHandler, oWhatsUpDoc)

/*****
 *
 * @...GET
 *
 */

STATIC FUNCTION DoGet( w )
   LOCAL nCursSave
   LOCAL column, get, nKey
   LOCAL lNeedToCalc := .F.

   // make sure browse is stable
   DISPBEGIN()
   WHILE (!w:stabilize())
   END
   DISPEND()

   // get column object from browses
   // based on its position
   column := w:getColumn( w:colPos )

   // create a corresponding GET
   get := GetNew(ROW(), COL(), column:block,;
         column:heading,;
         IF(VALTYPE(EVAL(column:block)) == "N",;
         "@KR 9,999,999.99", "@!KS10"), "W+/RB")

   // read it
   lNeedToCalc := ModalJr( get )

   // force redisplay of current row
   w:refreshCurrent()

   SETCURSOR(SC_NONE)
   RETURN (lNeedToCalc)

/*****
 *
 * This is a "junior" version of
 * ReadModal()
 *
 */

STATIC FUNCTION ModalJr( get )
   LOCAL lExitRequested       := .F.
   LOCAL nKey, cKey, lUpdated := .F.

   SETCURSOR(IF(!SET(_SET_INSERT), SC_NORMAL, SC_SPECIAL1))
   // In order to edit the Get you
   // should give it input focus
   get:setFocus()

   // Check for editable positions
   lExitRequested := get:typeOut

   // Keystroke processing loop
   WHILE !lExitRequested
      // Wait for a key and,
      // keep the letters running
      //
      // WARNING: Pay special attention to the
      // codeblock sent to WhatKey(), since you
      // are moving the cursor under Touchy().
      // When you need variables LOCAL to the
      // block, just declare some dummy parameters
      //
      nKey := WhatKey( , {|r, c, l| r := ROW(),;
                                c := COL(),;
                                l := SETCURSOR(SC_NONE),;
                                Touchy(),;
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
         SETCURSOR(IF(SET(_SET_INSERT), SC_SPECIAL1, SC_NORMAL))

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
                  // Puts character into the editing buffer at the
                  // current cursor position, overwriting the
                  // existent contents.
                  get:overstrike(cKey)

               ENDIF

            ENDIF

         ENDIF

      ENDIF

   END

   IF (lUpdated := get:changed)
      // Indicates wheater the get:buffer has changed
      get:assign() // Assigns the value in the editing buffer to
                  // the Get variable

   ENDIF
   // resets the editing buffer to reflect the current value
   get:reset()
   // Take out input focus
   get:killFocus()
   SETCURSOR(SC_NONE)
   RETURN (lUpdated)

// EOF - SPRDSHT.PRG //
