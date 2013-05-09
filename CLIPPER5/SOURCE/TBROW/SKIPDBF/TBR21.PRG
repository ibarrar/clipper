/*****
 *
 * TBR21.PRG
 *
 * Clipper tbr21 /N /W
 * RTLINK FILE tbr21
 *
 */

#include "inkey.ch"
#include "setcurs.ch"

#define  HEADSEP    CHR(205) + CHR(209) + CHR(205)
#define  COLSEP     CHR(32)  + CHR(179) + CHR(32)
#define  FOOTSEP    CHR(205) + CHR(207) + CHR(205)

// Assuming blink off
#define  COLORS_FIRST     "W+/BG,W+/B*"
#define  COLORS_SECOND    "W+/B*,W+/R*"

FUNCTION Main()
   LOCAL b, column, nKey, cScreen, c, w
   LOCAL nWhichRecno
   FIELD purdate, invno IN file1
   FIELD invnumber, item, itemdesc IN file2

   cScreen := savescreen()
   SET SCOREBOARD OFF
   SET CONFIRM    ON

   SETCURSOR(SC_NONE)
   SETCOLOR("N/W")
   SCROLL()
   @ MAXROW(), 0 SAY;
      PADR("TAB - Shift Browses       "+;
           "ESC - Quit", MAXCOL() + 1) ;
      COLOR "W+/RB*"

   SETBLINK(.F.)  // This is going to give us
                  // high intensity background

   // Open first file
   USE file1 INDEX file1 NEW

   // Open second file
   USE file2 INDEX file2 NEW

   // First file
   SELECT file1

   // First Browse
   @  2, 6 TO 10,35 DOUBLE COLOR COLORS_FIRST
   b := TBrowseDB( 3, 7, 9, 34 )
   b:colSep    := COLSEP
   b:headSep   := HEADSEP
   b:footSep   := FOOTSEP
   b:colorSpec := COLORS_FIRST

   // Second Browse
   @ 12, 6 TO 22,72 DOUBLE COLOR COLORS_SECOND
   c := TBrowseDB( 13, 7, 21, 71 )
   c:skipBlock     := {|nSkip| SkipDB(nSkip,;
                    {|| file1->invno == file2->invnumber})}
   c:goTopBlock    := {|| GoTopDB(;
                    {|| file1->invno == file2->invnumber})}
   c:goBottomBlock := {|| GoBottomDB(;
                    {|| file1->invno == file2->invnumber})}
   c:colSep    := COLSEP
   c:headSep   := HEADSEP
   c:footSep   := FOOTSEP
   c:colorSpec := COLORS_SECOND

   // TBColumn objects
   // First file
   column := TBColumnNew( "Purchase Date", {|| purdate} )
   column:footing := "Parent"
   b:addColumn( column )
   column := TBColumnNew( "Invoice#", {|| invno} )
   b:addColumn( column )

   // TBColumn Objects
   // Second File
   column := TBColumnNew( "Invoice#", {|| invnumber} )
   column:footing := "Child"
   c:addColumn( column )
   column := TBColumnNew( "Item", {|| item} )
   c:addColumn( column )
   column := TBColumnNew( "Description", {|| itemdesc} )
   c:addColumn( column )

   // Remember: The variable contains a REFERENCE
   // to the object
   // Dehilite cell in the unselected object
   ForceStable( c )
   c:deHilite()

   // Current object
   w := b

   nWhichRecno := 0
   WHILE .T.
      // This is a different appoach
      // to make sure keyboarb buffer is empty
      // and allow stabilization to be
      // interrupted
      DISPBEGIN()
      WHILE !(w:stabilize()) .AND. (NEXTKEY() == 0)
      END
      DISPEND()

      IF (NEXTKEY() == 0) .AND. ;
         (nWhichRecno != file1->(RECNO()))
         nWhichRecno  := file1->(RECNO())
         SELECT file2
         DBSEEK( file1->invno )
         c:refreshAll()
         ForceStable( c )
         c:deHilite()
         SELECT file1

      ENDIF

      IF ( w:stable )
         nKey := INKEY(0)

      ENDIF

      // Process key
      IF !TBMoveCursor( nKey, w )
         IF ( nKey == K_ESC )
            EXIT

         ELSEIF ( nKey == K_TAB )
            w:deHilite()
            IF w == c
               w := b
               SELECT file1

            ELSE
               w := c
               SELECT file2

            ENDIF
            w:hilite()

         ENDIF

      ENDIF

   END

   SCROLL()
   SETCURSOR(SC_NORMAL)
   restscreen(,,,,cScreen)
   RETURN (NIL)

/*****
 *
 * Custom Skippers
 *
 */

STATIC FUNCTION GoTopDB( bWhileCond )
   WHILE EVAL( bWhileCond ) .AND. !BOF()
      SKIP -1
      IF !EVAL( bWhileCond )
         SKIP
         EXIT

      ENDIF

   END
   RETURN (NIL)

STATIC FUNCTION GoBottomDB( bWhileCond )
   WHILE EVAL( bWhileCond ) .AND. !EOF()
      SKIP

   END
   SKIP -1
   RETURN (NIL)

STATIC FUNCTION SkipDB( nSkipRequest, bWhileCOnd )
   LOCAL nActSkip := 0

   IF nSkipRequest == 0
      SKIP 0

   ELSEIF nSkipRequest > 0 .AND. !EOF()
      WHILE nActSkip < nSkipRequest
         SKIP

         IF !EVAL( bWhileCond ) .OR. EOF()
         SKIP -1
         EXIT

         END
         nActSkip++

      END

   ELSEIF nSkipRequest < 0
      WHILE nActSkip > nSkipRequest
         SKIP -1
         IF BOF()
            EXIT

         ENDIF

         IF !EVAL( bWhileCond )
            SKIP
            EXIT

         ENDIF
         nActSkip--

      END

   ENDIF
   RETURN (nActSkip)

/*****
 *
 * Cursor Movement Methods
 *
 */

FUNCTION TBMoveCursor( nKey, oObj )
   LOCAL nFound
   STATIC aCursorMethods := ;
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
   nFound := ASCAN( aCursorMethods, nKey )
   IF nFound != 0
      EVAL( aCursorMethods[++nFound], oObj )

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

// EOF - TBR21.PRG //

