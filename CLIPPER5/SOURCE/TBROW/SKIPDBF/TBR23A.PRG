/*****
 *
 * TBR23.PRG
 *
 * Multi-line Browse - Example 2
 *
 * Clipper tbr23 /N /W
 * RTLINK FILE tbr23
 *
 */

#include "inkey.ch"
#include "setcurs.ch"
#include "set.ch"

#define  HEADSEP    CHR(205) + CHR(209) + CHR(205)
#define  COLSEP     CHR(32)  + CHR(179) + CHR(32)
#define  FOOTSEP    CHR(205) + CHR(207) + CHR(205)
#define  MYCOLORS   "W+/BG,W+/B*"

FUNCTION Main()
   FIELD country, city1, city2, city3, city4, continent ;
         IN places
   LOCAL b, column, nKey, cScreen
   LOCAL nMaxRow, nMaxCol
   // This variable holds the line number
   // Lets start as line number 1
   //
   LOCAL nLine := 1

   // Open file
   USE places INDEX places

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
   // For the second column, nLine will be used
   // to decide which field (city2, city3, city4)
   // will be retrieved!
   //
   b:skipBlock     := {|nSkip| SkipDB(nSkip, @nLine)}
   b:goTopBlock    := {|| GoTopDB(@nLine)}
   b:goBottomBlock := {|| GoBottomDB(@nLine)}

   // Column object
   //
   column := TBColumnNew( "Country", {|| IF(nLine == 1,;
                          Country, "")})
   column:footing := "Computer Associates Int'l"
   b:addColumn( column )
   // As you can see, the "trick" is the line counter
   // which will point out for the line you want to
   // show on the screen.
   column := TBColumnNew( "Cities", {|| RetrieveWhat(nLine)} )
   column:footing := "CA-Clipper 5.2"
   b:addColumn( column )
   column := TBColumnNew( "Continent",;
                          {|| IF(nLine == 1, Continent, "")} )
   column:footing := "TBrowse/TBColumn;Objects"
   b:addColumn( column )
   b:freeze := 2

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

         ENDIF

      ENDIF

   END

   DBCLOSEALL()
   SCROLL()
   restscreen(,,,,cScreen)
   RETURN (NIL)

/*****
 *
 * Bottom of file
 *
 */

STATIC FUNCTION GoBottomDB( nLine )
   // You are receiving a reference
   FIELD country, city1, city2, city3, city4, continent;
         IN places
   DBGOBOTTOM()
   // Since you are pointing to the last record
   // your last line should be 1, 2, 3 or 4 depending
   // wheather or not you have data to fill those lines
   //
   nLine := LastLine()
   RETURN (NIL)

/*****
 *
 * Top of File
 *
 */

STATIC FUNCTION GoTopDB( nLine )
   // You are receiving a reference
   FIELD country, city1, city2, city3, city4, continent;
         IN places
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
   FIELD country, city1, city2, city3, city4, continent;
         IN places
   LOCAL nActually := 0

   IF nRequest == 0
      DBSKIP(0)

   ELSEIF nRequest > 0 .AND. !EOF()
      WHILE nActually < nRequest
         // Which one is the next line?
         // Be aware that if you have an empty
         // city field followed by another non-empty
         // city field, example:
         // city1 := "Something"
         // city2 := "         "
         // city3 := "Another  "
         //
         // it will appear on screen that way
         //
         IF (nLine == 1 .AND. !EMPTY(city2)) .OR.;
            (nLine == 2 .AND. !EMPTY(city3)) .OR.;
            (nLine == 3 .AND. !EMPTY(city4))
            ++nLine

         ELSE
            // We are able to go to the next record since
            // all 3 fields (city2, city3, city4) are empty
            DBSKIP(+1)
            nLine := 1

         ENDIF
         IF EOF()
            DBSKIP(-1)
            nLine := LastLine()
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
               nLine := LastLine()

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
 * Which city should be retrieved?
 *
 */

STATIC FUNCTION RetrieveWhat(nLine)
   RETURN EVAL(FIELDBLOCK(FIELD(nLine + 1)))

/*****
 *
 * Returns the last non-empty city
 *
 */

STATIC FUNCTION LastLine()
   FIELD country, city1, city2, city3, city4, continent;
      IN places
   LOCAL nCity := 4

   WHILE .T.
      IF !EMPTY(EVAL(FIELDBLOCK(FIELD(nCity + 1))))
         EXIT

      ENDIF
      nCity--

   END
   RETURN (nCity )

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
   RETURN (NIL)

// EOF - TBR23.PRG //
