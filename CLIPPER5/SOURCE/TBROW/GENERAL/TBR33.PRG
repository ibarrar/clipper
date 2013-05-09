/*****
 *
 * TBR33.PRG
 * A "multi-line" TBrowse in which the memo field
 * is shown in up to four lines
 * Editing is allowed
 *
 *
 * Clipper tbr33 /N /W
 * RTLINK FILE tbr33
 *
 */

#include "inkey.ch"
#include "setcurs.ch"
#include "set.ch"

#define     HEADSEP       CHR(205) + CHR(209) + CHR(205)
#define     COLSEP        CHR(32)  + CHR(179) + CHR(32)
#define     FOOTSEP       CHR(205) + CHR(207) + CHR(205)
#define     MYCOLORS      "W+/BG,W+/B*"
#define     WIDTH         40
#define     LAST_LINE     4
#define     MEMOCOLUMN    2

FUNCTION Main()
   LOCAL b, column, nKey, cScreen
   LOCAL nMaxRow, nMaxCol
   // This variable holds the line number
   // Lets start as line number 1
   //
   LOCAL nLine := 1

   // Open file
   USE memotest INDEX memotest

   // Screen (not handled by TBrowse)
   cScreen := savescreen()
   SET(_SET_SCOREBOARD, .F.)
   SETBLINK(.F.)
   SETCURSOR(SC_NONE)
   SETCOLOR("N/W")
   SCROLL()
   nMaxRow := MAXROW()
   nMaxCol := MAXCOL()
   @  2, 4 TO nMaxRow - 3,nMaxCol - 5 DOUBLE COLOR MYCOLORS

   // Create Browse Object
   b := TBrowseDB( 3, 5, nMaxRow - 4, nMaxCol - 6 )
   b:colSep    := COLSEP
   b:headSep   := HEADSEP
   b:footSep   := FOOTSEP
   b:colorSpec := MYCOLORS
   // Custom Skippers
   //
   // nLine is passed by reference
   // since we need to know which
   // data should be retrieved.
   //
   // It means field contents or "" or even spaces
   // for the first and the third columns depending
   // if nLine is 1 or != 1.
   //
   b:skipBlock     := {|nSkip| SkipDB(nSkip, @nLine)}
   b:goTopBlock    := {|| GoTopDB(@nLine)}
   b:goBottomBlock := {|| GoBottomDB(@nLine)}

   // Column objects
   //
   column := TBColumnNew( "City", {|| IF(nLine == 1,;
                          memotest->charfld, "")})
   // Get-set block should be attached to cargo
   column:cargo := {|x| IF(x == NIL, memotest->charfld,;
                                     memotest->charfld := x)}
   column:footing := "Computer Associates Int'l"
   b:addColumn( column )

   // As you can see, the "trick" is the line counter
   // which will point out for the line you want to
   // show on the screen.
   column := TBColumnNew( "Memo", {|| RetrieveWhat(nLine)} )
   column:width   := WIDTH
   // Get-set block should be attached to cargo
   column:cargo := {|x| IF(x == NIL, memotest->memofld,;
                                     memotest->memofld := x)}
   column:footing := "TBrowse/TBColumn;Objects"
   b:addColumn( column )

   // Browse it!
   WHILE .T.
      ForceStable( b )
      IF (b:hitTop .OR. b:hitBottom)
         // Make some noise!
         TONE(1000, 2)

      ENDIF
      nKey := INKEY(0)

      // Process key
      IF !TBMoveCursor( nKey, b )
         IF ( nKey == K_ESC )
            EXIT

         ELSEIF ( nKey == K_ENTER )
            // Editing
            // Is it a memo?
            IF ( b:colPos == MEMOCOLUMN )
               IF EditMemo(b, nLine)
                  b:refreshAll()

               ELSE
                  b:invalidate()

               ENDIF

            ELSE
               DoGet(b, nLine)

            ENDIF

         ENDIF

      ENDIF

   END

   DBCLOSEALL()
   SCROLL()
   restscreen(,,,,cScreen)
   RETURN (.T.)

/*****
 *
 * Bottom of file
 *
 */

STATIC FUNCTION GoBottomDB( nLine )
   // You are receiving a reference
   DBGOBOTTOM()
   nLine := LAST_LINE
   RETURN (NIL)

/*****
 *
 * Top of File
 *
 */

STATIC FUNCTION GoTopDB( nLine )
   // You are receiving a reference
   DBGOTOP()
   // Since you are pointing to the first record
   // your current line should be 1
   nLine := 1
   RETURN (NIL)

/*****
 *
 * Skip records
 *
 */

STATIC FUNCTION SkipDB( nRequest, nLine )
   // nLine is a reference
   LOCAL nActually := 0

   IF nRequest == 0
      DBSKIP(0)

   ELSEIF nRequest > 0 .AND. !EOF()
      WHILE nActually < nRequest
         IF nLine < LAST_LINE
            // This will print up to LAST_LINE of text
            // Some of them (or even all) might be empty
            ++nLine

         ELSE
            // Go to the next record
            DBSKIP(+1)
            nLine := 1

         ENDIF
         IF EOF()
            DBSKIP(-1)
            nLine := LAST_LINE
            EXIT

         ENDIF
         nActually++

      END

   ELSEIF nRequest < 0
      WHILE nActually > nRequest
         // Go to previous line
         IF nLine > 1
            --nLine

         ELSE
            DBSKIP(-1)
            IF !BOF()
               nLine := LAST_LINE

            ELSE
               // You need this. Believe me!
               nLine := 1
               GOTO RECNO()
               EXIT

            ENDIF

         ENDIF
         nActually--

      END

   ENDIF
   RETURN (nActually)

/*****
 *
 * Which line should be retrieved?
 *
 */

STATIC FUNCTION RetrieveWhat(nLine)
   LOCAL cReturn := ""
   LOCAL cStr

   // Strip all hard returns, soft returns and line feeds
   cStr := STRTRAN(memotest->memofld, CHR(141), "")
   cStr := STRTRAN(cStr, CHR(10), "")
   cStr := STRTRAN(cStr, CHR(13), "")

   IF nLine == 1
      cReturn := SUBSTR(cStr, 1, WIDTH)

   ELSEIF nLine == 2
      cReturn := SUBSTR(cStr, WIDTH + 1, WIDTH)

   ELSEIF nLine == 3
      cReturn := SUBSTR(cStr, WIDTH * 2 + 1, WIDTH)

   ELSEIF nLine == 4
      cReturn := SUBSTR(cStr, WIDTH * 3 + 1, WIDTH)

   ENDIF
   RETURN (cReturn)

/*****
 *
 * Edits the memo field
 *
 */

STATIC FUNCTION EditMemo(b, nLine)
   LOCAL nBot, nRig, nTop, nLef, column
   LOCAL cStr1, cStr0, bBlock
   LOCAL cClr, nCur, lRet := .F.

   IF nLine == 1
      column := b:getColumn(b:colPos)
      nTop   := ROW()
      nLef   := COL()

      IF (b:rowCount == b:rowPos)
         nBot := nTop

      ELSEIF ( (b:rowPos + LAST_LINE - 1 ) > b:rowCount)
         nBot := nTop + (b:rowCount - b:rowPos)

      ELSE
         nBot := nTop + LAST_LINE - 1

      ENDIF

      nRig   := nLef + WIDTH

      cClr  := SETCOLOR("I")
      nCur  := SETCURSOR(SC_NORMAL)
      cStr0 := EVAL(column:cargo)

      // Edit it
      cStr1 := MEMOEDIT(cStr0, nTop, nLef, nBot, nRig, .T.)

      // Reset
      SETCOLOR(cClr)
      SETCURSOR(SC_NONE)

      IF !(cStr0 == cStr1)
         // Replace field
         EVAL(column:cargo, cStr1)
         lRet := .T.

      ENDIF

   ENDIF

   RETURN (lRet)

/*****
 *
 * @...GET
 *
 */

STATIC FUNCTION DoGet(obj, nLine)
   LOCAL nCursSave, xOldKey, xNewKey
   LOCAL column, get, nKey

   IF nLine != 1
      RETURN (NIL)

   ENDIF

   // Cursors are for GETs, so:
   nCursSave := SETCURSOR(SC_NORMAL)

   // make sure browse is stable
   WHILE ( !obj:stabilize() )
   END

   column := obj:getColumn( obj:colPos )

   // create a corresponding GET and READ it
   // Pay attention to column:cargo!!!!!!!!!
   get := GetNew(ROW(), COL(), column:cargo,;
               column:heading,, "W+/BG,W+/B")

   // Get old key value or NIL
   xOldKey := IF( EMPTY(INDEXKEY()), NIL, &(INDEXKEY()) )
   READMODAL( {get} )
   SETCURSOR(SC_NONE)
   xNewKey := IF( EMPTY(INDEXKEY()), NIL, &(INDEXKEY()) )

   // If key was changed...
   IF xOldKey != xNewKey
      // Refresh
      obj:refreshAll()
      ForceStable( obj )

      // Make sure we are still in the right record
      // after stabilizing
      WHILE &(INDEXKEY()) > xNewKey .AND. !obj:hitTop()
         obj:up()
         ForceStable( obj )

      END

   ELSE
      obj:refreshCurrent()
      ForceStable( obj )

   ENDIF

   // check exit key
   nKey := LASTKEY()
   IF ( nKey == K_UP .OR. nKey == K_DOWN .OR. ;
      nKey == K_PGUP .OR. nKey == K_PGDN )
      KEYBOARD CHR( nKey )

   ENDIF
   RETURN (NIL)

/*****
 *
 * Cursor Movement Methods
 *
 */

STATIC FUNCTION TBMoveCursor( nKey, oObj )
   LOCAL nFound
   STATIC aKeys := ;
       { K_DOWN      , {|b| b:down()},;
         K_UP        , {|b| b:up()},;
         K_PGDN      , {|b| b:pageDown()},;
         K_PGUP      , {|b| b:pageUp()},;
         K_CTRL_PGUP , {|b| b:goTop()},;
         K_CTRL_PGDN , {|b| b:goBottom()},;
         K_RIGHT     , {|b| b:right()},;
         K_LEFT      , {|b| b:left()},;
         K_HOME      , {|b| b:home()},;
         K_END       , {|b| b:end()},;
         K_CTRL_LEFT , {|b| b:panLeft()},;
         K_CTRL_RIGHT, {|b| b:panRight()},;
         K_CTRL_HOME , {|b| b:panHome()},;
         K_CTRL_END  , {|b| b:panEnd()} }

   // Search into array
   nFound := ASCAN( aKeys, nKey )
   IF nFound != 0
      EVAL( aKeys[++nFound], oObj )

   ENDIF
   RETURN (nFound != 0)

/*****
 *
 * Forces Stabilization
 *
 */

STATIC FUNCTION ForceStable( obj )
   DISPBEGIN()
   WHILE !obj:stabilize()
   END
   DISPEND()
   RETURN (.T.)

// EOF - TBR33.PRG //
