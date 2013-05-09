/*****
 *
 * TBR19.PRG
 *
 *
 * Clipper tbr19 /N /W
 * RTLINK FILE tbr19
 *
 */

#include "inkey.ch"
#include "setcurs.ch"

#define  MYCOLORS   "W+/BG,RB+/W,W/N,N," +;
                    "GR+/W,G+/B,R+/B,GR+/B"
#define  HEADSEP    CHR(205) + CHR(209) + CHR(205)
#define  COLSEP     CHR(32)  + CHR(179) + CHR(32)

FUNCTION Main()
   LOCAL b, column, nKey, cScreen

   cScreen := savescreen()
   SET SCOREBOARD OFF
   SET CONFIRM    ON

   USE test NEW
   // Important!
   // Go to start condition
   LOCATE FOR test->fld5 >= 5

   SETCURSOR(SC_NONE)
   SETCOLOR("N/W")
   SCROLL()
   @  2, 6 TO 22,72 DOUBLE COLOR "W+/BG"

   b := TBrowseDB( 3, 7, 21, 71 )
   b:colorSpec := MYCOLORS
   b:colSep    := COLSEP
   b:headSep   := HEADSEP

   // Custom Skippers
   b:skipBlock     := {|nRecs| Skipper( nRecs )}
   b:goTopBlock    := {|| GoTopDb()}
   b:goBottomBlock := {|| GoBottomDb()}

   // TBColumn objects
   column := TBColumnNew( "Record #", {|| RECNO()} )
   b:addColumn( column )
   column := TBColumnNew( "Field 3",  {|| test->fld3} )
   b:addColumn( column )
   column := TBColumnNew( "Field 5",  {|| test->fld5} )
   b:addColumn( column )

   WHILE .T.
      ForceStable( b )
      nKey := INKEY(0)

      // Process key
      IF !TBMoveCursor( nKey, b )
         IF ( nKey == K_ESC )
            SCROLL()
            EXIT

         ENDIF

      ENDIF

   END
   restscreen(,,,,cScreen)
   RETURN (NIL)

/*****
 *
 * Skip to top of condition
 *
 */

STATIC FUNCTION GoTopDb()
   WHILE (test->fld5 >= 5) .AND. (!BOF())
      DBSKIP(-1)
      IF !(test->fld5 >= 5)
         DBSKIP(1)
         EXIT

      ENDIF

   END
   RETURN (NIL)

/*****
 *
 * Skip to the bottom of
 * condition block
 *
 */

STATIC FUNCTION GoBottomDb()
   WHILE (test->fld5 >= 5) .AND. (!EOF())
      DBSKIP(1)

   END
   // Go back to the last occurrence
   DBSKIP(-1)
   RETURN NIL

/*****
 *
 * Main Skippper
 *
 */

STATIC FUNCTION Skipper( nRequest )
   // nRequest is the number of records to be skipped
   LOCAL nActually := 0

   IF (nRequest == 0)
      DBSKIP(0)

   ELSEIF (nRequest > 0) .AND. (!EOF())
      // Keep skipping until number of skips
      // requested is satisfied
      WHILE (nActually < nRequest)
         DBSKIP(1)
         // Evaluate condition for each record
         IF !(test->fld5 >= 5) .OR. EOF()
            DBSKIP(-1)
            EXIT

         ENDIF

         // Skip counter
         nActually++

      END

   ELSEIF (nRequest < 0)
      WHILE (nActually > nRequest)
         DBSKIP(-1)
         // This is check is important!
         // BOF bangs do not sit on phanton record
         // Rather, the top record is evaluated,
         // and may meet the condition
         IF BOF()
            EXIT

         ENDIF
         // Evaluate condition for each record
         IF !(test->fld5 >= 5)
            DBSKIP(1)
            EXIT

         ENDIF

         // Skip counter
         nActually--

      END

   ENDIF
   // Returns number of records actually skipped
   RETURN (nActually)

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
 * Forces stabilization
 *
 */

STATIC FUNCTION ForceStable( obj )
   DISPBEGIN()
   WHILE !obj:stabilize()
   END
   DISPEND()
   RETURN (NIL)

// EOF - TBR19.PRG //
