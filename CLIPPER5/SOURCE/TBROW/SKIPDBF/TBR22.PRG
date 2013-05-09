/*****
 *
 * TBR22.PRG
 *
 * Multi-line Browse - Example 1

 * Clipper tbr22 /N /W
 * RTLINK FILE tbr22
 *
 */

#include "inkey.ch"
#include "setcurs.ch"
#include "set.ch"

#define   ShowAnotherLine()    (!EMPTY(City)  .OR.;
                                !EMPTY(State) .OR.;
                                !EMPTY(Zip))

#define  HEADSEP    CHR(205) + CHR(209) + CHR(205)
#define  COLSEP     CHR(32)  + CHR(179) + CHR(32)
#define  FOOTSEP    CHR(205) + CHR(207) + CHR(205)
#define  MYCOLORS   "W+/BG,W+/B*"

FUNCTION Main()
   FIELD name, address, city, state, zip, country
   LOCAL nKey, b, column, cScreen
   LOCAL nMaxRow, nMaxCol
   // This variable will keep track
   // if we need to display line 2
   //
   LOCAL lLine := .F.

   // Open file
   USE test2 index test2

   // Screen (not handled by TBrowse)
   cScreen := savescreen()
   SET(_SET_SCOREBOARD, .F.)
   SETBLINK(.F.)
   SETCURSOR(SC_NONE)
   SETCOLOR("N/W")
   SCROLL()
   nMaxRow := MAXROW()
   nMaxCol := MAXCOL()
   @  2, 3 TO nMaxRow - 3,nMaxCol - 3 ;
      DOUBLE COLOR MYCOLORS

   b := TBrowseDB( 3, 4, nMaxRow - 4,nMaxCol - 4 )
   b:colSep    := COLSEP
   b:headSep   := HEADSEP
   b:footSep   := FOOTSEP
   b:colorSpec := MYCOLORS
   // nLine is passed by reference
   //
   b:skipBlock     := {|nSkip| SkipDB(nSkip, @lLine)}
   b:goTopBlock    := {|| GoTopDB(@lLine)}
   b:goBottomBlock := {|| GoBottomDB(@lLine)}

   // Pay attention to the data retrieval block!
   column := TBColumnNew( "Name", {|| IF(!lLine, Name, "")} )
   column:footing := "CA-Clipper 5.2"
   b:addColumn( column )
   // Pay attention to the data retrieval block!
   column := TBColumnNew( "Address", {|| IF(!lLine, Address,;
            PADR(City, 24) + PADR(STATE, 4) + Zip)} )
   column:width := 38
   b:addColumn( column )
   // Pay attention to the data retrieval block!
   column := TBColumnNew( "Country", {|| IF(!lLine,;
                          Country, "")} )
   b:addColumn( column )

   WHILE .T.
      ForceStable( b )
      nKey := INKEY(0)

      // Process key
      IF !TBMoveCursor( nKey, b )
         IF ( nKey == K_ESC )
            EXIT

         ENDIF

      ENDIF

   END
   restscreen(,,,,cScreen)
   RETURN (NIL)

/*****
 *
 * Bottom of file
 *
 */

FUNCTION GoBottomDB( lLine ) // You are receiving a reference
   FIELD name, address, city, state, zip, country
   DBGOBOTTOM()
   // do we have data for the second line?
   //
   lLine := ShowAnotherLine()
   RETURN (NIL)

/*****
 *
 * Top of File
 *
 */

FUNCTION GoTopDB( lLine ) // You are receiving a reference
   FIELD name, address, city, state, zip, country
   DBGOTOP()
   // Since you are pointing to the first record
   // your current line should be 1
   lLine := .F.
   RETURN (NIL)

/*****
 *
 * Skip records
 *
 */

FUNCTION SkipDB( nRequest, lLine )
   FIELD name, address, city, state, zip, country
   // lLine is a reference
   LOCAL nActually := 0

   IF nRequest == 0
      SKIP 0

   ELSEIF nRequest > 0 .AND. !EOF()
      WHILE nActually < nRequest
         // Check next line
         IF (!lLine) .AND. (!EMPTY(city)  .OR.;
                          !EMPTY(state) .OR.;
                          !EMPTY(zip))
            // We are able to show to the next line
            // for this record
            // (city + state + zip)
            lLine := .T.

         ELSE
            // We are able to go to the next record since
            // all 3 fields (city + state + zip) are empty
            lLine := .F.
            SKIP +1

         ENDIF
         IF EOF()
            SKIP -1
            lLine := ShowAnotherLine()
            EXIT

         ENDIF
         nActually++

      END

   ELSEIF nRequest < 0
      // Go to previous line
      WHILE nActually > nRequest
         IF lLine
            lLine := .F.

         ELSE
            SKIP - 1
            IF !BOF()
               lLine := ShowAnotherLine()

            ELSE
               // Reset pointer if BOF
               // no "phantom" record as in EOF
               lLine := .F.
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
 * Cursor Movement Methods
 *
 */

FUNCTION TBMoveCursor( nKey, oObj )
   LOCAL nFound
   STATIC aKeys := ;
       { K_DOWN      ,{|b| b:down()},;
         K_UP        ,{|b| b:up()},;
         K_PGDN      ,{|b| b:pageDown()},;
         K_PGUP      ,{|b| b:pageUp()},;
         K_CTRL_PGUP ,{|b| b:goTop()},;
         K_CTRL_PGDN ,{|b| b:goBottom()},;
         K_RIGHT     ,{|b| b:right()},;
         K_LEFT      ,{|b| b:left()},;
         K_HOME      ,{|b| b:home()},;
         K_END       ,{|b| b:end()},;
         K_CTRL_LEFT ,{|b| b:panLeft()},;
         K_CTRL_RIGHT,{|b| b:panRight()},;
         K_CTRL_HOME ,{|b| b:panHome()},;
         K_CTRL_END  ,{|b| b:panEnd()} }

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

// EOF - TBR22.PRG //
