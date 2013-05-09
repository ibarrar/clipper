/*****
 *
 * TBR17.PRG
 *
 *
 * Clipper tbr17 /N /W
 * RTLINK FILE tbr17
 *
 */

#include "inkey.ch"
#include "setcurs.ch"

// Shift Cursor Keys
#define     K_SH_UP       56
#define     K_SH_DOWN     50
#define     K_SH_LEFT     52
#define     K_SH_RIGHT    54

#define     COLSEP        CHR(32)  + CHR(179) + CHR(32)
#define     HEADSEP       CHR(205) + CHR(209) + CHR(205)
#define     FOOTSEP       CHR(205) + CHR(207) + CHR(205)
#define     MYCOLORS      "W+/B*,W+/R*,,,BG/N"

FUNCTION Main()
   LOCAL b, column, nKey, cScreen
   LOCAL cClr

   cScreen := savescreen()
   SET SCOREBOARD OFF
   SET CONFIRM    ON

   // If you do not have a VGA does not
   // matter it will just be ignored
   SETMODE(50,80)

   USE test INDEX test3 NEW
   SETCURSOR(SC_NONE)
   SETBLINK(.F.)
   SETCOLOR("N/W")
   SCROLL()
   @ 2, 6 TO 13,55 DOUBLE COLOR "W+/B*"

   b:= TBrowseDB( 3, 7, 12, 54 )
   b:colSep    := COLSEP
   b:headSep   := HEADSEP
   b:colorSpec := MYCOLORS

   // TBColumn objects
   column := TBColumnNew( "Field 1", {|| test->fld1} )
   b:addColumn( column )
   column := TBColumnNew( "Field 3", {|| test->fld3} )
   b:addColumn( column )
   column := TBColumnNew( "Field 4", {|| test->fld4} )
   b:addColumn( column )
   column := TBColumnNew( "Field 5", {|| test->fld5} )
   b:addColumn( column )

   b:freeze := 1

   WHILE .T.
      IF  ( b:colPos <= b:freeze )
         b:colPos := b:freeze + 1

      ENDIF

      ForceStable( b )
      IF ( b:hitTop .OR. b:hitBottom )
         TONE(87.3,1)
         TONE(40,3.5)

      ENDIF
      nKey := INKEY(0)

      IF !TBMoveCursor( nKey, b )
         IF ( nKey == K_ESC )
            SCROLL()
            SETMODE(25,80)
            EXIT

         ELSEIF ( nKey == K_ALT_S )
            SizeIt( b )
            cClr := SETCOLOR("N/W")
            SCROLL()
            SETCOLOR(cClr)
            @ b:nTop - 1,b:nLeft - 1 TO;
              b:nBottom + 1,b:nRight + 1 DOUBLE;
              COLOR "W+/B*"

         ELSEIF ( nKey == K_ALT_M )
            MoveIt( b )
            cClr := SETCOLOR("N/W")
            SCROLL()
            SETCOLOR(cClr)
            @ b:nTop - 1,b:nLeft - 1 TO;
              b:nBottom + 1,b:nRight + 1 DOUBLE;
              COLOR "W+/B*"

         ENDIF

      ENDIF

   END
   restscreen(,,,,cScreen)
   RETURN (NIL)

/*****
 *
 * "Moves" the window
 *
 */

FUNCTION MoveIt( obj )
   // Remember: Objects are passed by REFERENCE
   //
   LOCAL cScreen, cColours
   LOCAL nKey, t, l, b, r

   t := obj:nTop    - 1
   l := obj:nLeft   - 1
   b := obj:nBottom + 1
   r := obj:nRight  + 1

   // Screen
   cColours := SETCOLOR("W+/N")
   cScreen  := SAVESCREEN( 0, 0, MAXROW(), MAXCOL() )
   @ t, l, b, r BOX CHR(219)

   WHILE .T.
      nKey := INKEY(0)
      RESTSCREEN( 0, 0, MAXROW(), MAXCOL(), cScreen )

      IF ( nKey == K_UP )
         IF ( t != 0 )
            --t
            --b

         ENDIF

      ELSEIF ( nKey == K_DOWN )
         IF ( b != MAXROW() )
            ++b
            ++t

         ENDIF

      ELSEIF ( nKey == K_LEFT )
         IF ( l != 0 )
            --l
            --r

         ENDIF

      ELSEIF ( nKey == K_RIGHT )
         IF ( r != MAXCOL() )
            ++r
            ++l

         ENDIF

      ELSEIF ( nKey == K_ENTER )
         EXIT

      ENDIF
      @ t, l, b, r BOX CHR(219)

   END
   SETCOLOR(cColours)

   // Objects are passed by REFERENCE
   // When you modify the instance variables
   // nTop, nLeft, nBottom, nRight
   // you are modifying at the b object above
   // because obj has a reference to b
   //
   obj:nTop    := ++t
   obj:nLeft   := ++l
   obj:nBottom := --b
   obj:nRight  := --r
   RETURN (NIL)

/*****
 *
 * "Sizes" the window
 *
 */

FUNCTION SizeIt( obj )
   LOCAL cScreen, cColours
   LOCAL nKey, t, l, b, r

   t := obj:nTop    - 1
   l := obj:nLeft   - 1
   b := obj:nBottom + 1
   r := obj:nRight  + 1

   cColours := SETCOLOR("W+/N")
   cScreen  := SAVESCREEN( 0, 0, MAXROW(), MAXCOL() )
   @ t, l, b, r BOX CHR(219)

   WHILE .T.
      nKey := INKEY(0)
      RESTSCREEN( 0, 0, MAXROW(), MAXCOL(), cScreen )

      IF ( nKey == K_UP )
         t := IF( t != 0, --t, t )

      ELSEIF ( nKey == K_DOWN )
         b := IF( b != MAXROW(), ++b, b )

      ELSEIF ( nKey == K_LEFT )
         l := IF( l != 0, --l, l )

      ELSEIF ( nKey == K_RIGHT )
         r := IF( r != MAXCOL(), ++r, r )

      ELSEIF ( nKey == K_SH_UP )
         b := IF( b != (t + 2), --b, b )

      ELSEIF ( nKey == K_SH_DOWN )
         t := IF( t != (b - 2), ++t, t )

      ELSEIF ( nKey == K_SH_LEFT )
         r := IF( r != (l + 35), --r, r )

      ELSEIF ( nKey == K_SH_RIGHT )
         l := IF( l != (r - 35), ++l, l )

      ELSEIF ( nKey == K_ENTER )
         EXIT

      ENDIF
      @ t, l, b, r BOX CHR(219)

   END
   SETCOLOR(cColours)

   obj:nTop    := ++t
   obj:nLeft   := ++l
   obj:nBottom := --b
   obj:nRight  := --r
   //
   // In this case you do not need to issue a
   // configure() because this is automatic when you
   // change the instance variables nTop, nLeft,
   // nBottom, nRight
   RETURN (NIL)

/*****
 *
 * Cursor Movement Methods
 *
 */

STATIC FUNCTION TBMoveCursor( nKey, oObj )
   LOCAL nFound
   LOCAL aKeys := ;
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

   nFound := ASCAN( aKeys, nKey )
   IF (nFound != 0)
      EVAL( aKeys[++nFound], oObj )

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

// EOF - TBR17.PRG //
