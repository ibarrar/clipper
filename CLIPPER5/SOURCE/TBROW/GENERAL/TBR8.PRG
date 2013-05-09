/*****
 *
 * TBR8.PRG
 *
 *
 * Clipper tbr8 /N /W
 * RTLINK FILE tbr8
 *
 */

#include "inkey.ch"
#include "setcurs.ch"

#define     COLSEP     CHR(32)  + CHR(179) + CHR(32)
#define     HEADSEP    CHR(205) + CHR(209) + CHR(205)
#define     FOOTSEP    CHR(205) + CHR(207) + CHR(205)
#define     MYCOLORS   "W+/BG,N/W,W/N,N," +;
                       "GR+/W,N/BG,B+/BG,GR+/BG"

FUNCTION Main()
   LOCAL b, column, nKey, oCol, nCnt, bColorBlock, cScreen

   cScreen := savescreen()
   SET SCOREBOARD OFF
   SET CONFIRM    ON

   USE test INDEX test3 NEW
   SETCURSOR(SC_NONE)
   SETCOLOR("N/W")
   SCROLL()
   SETCOLOR("W+/BG")
   SCROLL( 2, 6, 22, 72 )
   @  2, 6 TO 22,72 DOUBLE
   @ MAXROW(), 0 SAY ;
     PADC("F10 - Change colors      ESC - Quit",;
     MAXCOL() + 1) COLOR "W+/RB"

   b := TBrowseDB( 3, 7, 21, 71 )
   b:colorSpec := MYCOLORS
   b:colSep    := COLSEP
   b:headSep   := HEADSEP
   b:footSep   := FOOTSEP

   // TBColumn objects
   column := TBColumnNew( "Field 1", {|| test->fld1} )
   column:footing := "First"
   b:addColumn( column )
   column := TBColumnNew( "Field 2", {|| test->fld2} )
   b:addColumn( column )
   column := TBColumnNew( "Field 3", {|| test->fld3} )
   b:addColumn( column )
   column := TBColumnNew( "Field 4", {|| test->fld4} )
   b:addColumn( column )
   column := TBColumnNew( "Field 5", {|| test->fld5} )
   column:footing := "Last"
   b:addColumn( column )
   b:cargo := {|| ChgClr()}

   WHILE .T.
      ForceStable( b )

      IF ( b:hitTop .OR. b:hitBottom )
         TONE(87.3,1)
         TONE(40,3.5)

      ENDIF
      nKey := INKEY(0)

      // Process key
      IF !TBMoveCursor( b, nKey )
         IF ( nKey == K_ESC )
            SCROLL()
            EXIT

         ELSEIF ( nKey == K_F10 )
            // Are we at the right place?
            // Evaluate attached cargo
            bColorBlock := EVAL( b:cargo )

            // Transverse all columns
            // Starting at column 1 up to colCount
            // which contains the total number of data
            // columns in the browse object
            FOR nCnt := 1 TO b:colCount
               // getColumn is a method which
               // returns a reference to a TBColumn
               // object
               oCol := b:getColumn( nCnt )
               oCol:colorBlock := bColorBlock

            NEXT

            b:configure()
            b:refreshAll()

         ENDIF

      ENDIF

   END
   restscreen(,,,,cScreen)
   RETURN (NIL)

/*****
 *
 * Color condition to a range of data rows
 *
 */

STATIC FUNCTION ChgClr()
   LOCAL GetList := {}  // For the Get System
   // I am not saving the screen
   // just because I am going to send
   // a refreshAll() message above
   LOCAL cClr  := SETCOLOR( "W+/B,GR+/R" )
   LOCAL nCurs := SETCURSOR(SC_NORMAL)
   LOCAL cString := SPACE(10)
   LOCAL bBlock

   SCROLL( 6, 9, 8, 32 )
   @  6, 9 TO  8,32
   @  7,12 SAY "String:" GET cString PICTURE "@!"
   READ

   bBlock := IF(LEN(TRIM(cString)) != 0,;
             {|x| IF(TRIM(cString) $ test->fld3,;
             { 8, 2 }, { 1, 2 })},;
             NIL)

   SETCURSOR(nCurs)
   SETCOLOR(cClr)

   // And return the proper block
   RETURN (bBlock)

/*****
 *
 * Forces stabilization
 *
 */

STATIC FUNCTION ForceStable( obj )
   DISPBEGIN()
   WHILE !obj:stabilize()
   END
   DISPEND()
   RETURN (NIL)

/*****
 *
 * Cursor Movement Methods
 *
 */

STATIC FUNCTION TBMoveCursor( o, nKey )
   LOCAL nFound
   STATIC aKeys := ;
       { K_DOWN      , {|obj| obj:down()},;
         K_UP        , {|obj| obj:up()},;
         K_PGDN      , {|obj| obj:pageDown()},;
         K_PGUP      , {|obj| obj:pageUp()},;
         K_CTRL_PGUP , {|obj| obj:goTop()},;
         K_CTRL_PGDN , {|obj| obj:goBottom()},;
         K_RIGHT     , {|obj| obj:right()},;
         K_LEFT      , {|obj| obj:left()},;
         K_HOME      , {|obj| obj:home()},;
         K_END       , {|obj| obj:end()},;
         K_CTRL_LEFT , {|obj| obj:panLeft()},;
         K_CTRL_RIGHT, {|obj| obj:panRight()},;
         K_CTRL_HOME , {|obj| obj:panHome()},;
         K_CTRL_END  , {|obj| obj:panEnd()} }

   nFound := ASCAN( aKeys, nKey )
   IF (nFound != 0)
      EVAL( aKeys[++nFound], o )

   ENDIF
   RETURN (nFound != 0)

// EOF - TBR8.PRG //
