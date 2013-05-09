/*****
 *
 * TBR32.PRG
 * Letter Incremental/decremental seek
 *
 *
 * Clipper tbr32
 * Clipper tbkeyact
 * Clipper brfunc
 * RTLINK FILE tbr32, tbkeyact, brfunc
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
   LOCAL b, column, nKey
   LOCAL nRecno, nCnt, xKey, cKey, cScreen
   LOCAL nCursor, nLen
   LOCAL lContinue := .T.
   LOCAL GetList := {}

   cScreen := savescreen()
   SET(_SET_SCOREBOARD, .F.)
   SET(_SET_CONFIRM, .T.)

   DBUSEAREA( .T., "DbfNtx", "testn" )
   DBSETINDEX( "testn" )

   SETCURSOR(SC_NONE)
   SETCOLOR("N/W")
   SCROLL()
   @  2, 6 TO 22,72 COLOR "W+/BG"
   @ MAXROW(), 0 SAY ;
     PADC("ESC - Quit"    +;
     "          "    +;
     "ALT_X - Quits Seek" +;
     "          "    +;
     "Letters & backspace - Seek",;
     MAXCOL() + 1) COLOR "W+/RB"

   b := TBrowseDB( 3, 7, 21, 71 )
   b:colorSpec := MYCOLORS
   b:colSep    := COLSEP
   b:headSep   := HEADSEP

   // Columns
   column := TBColumnNew( "Last;Name", {|| testn->lname} )
   b:addColumn( column )
   column := TBColumnNew( "First;Name", {|| testn->fname} )
   b:addColumn( column )
   column := TBColumnNew( "Extension", {|| testn->ext} )
   b:addColumn( column )

   // Add to the keystroke handler
   // ESCape
   AddKeyAction(K_ESC,    {|| lContinue := .F.})
   // ALT-X
   AddKeyAction(K_ALT_X,  {|| xKey := ""})
   // Backspace
   //
   //
   // Please note that enclosing two expressions
   // between parentheses and separating them with
   // commas will enable Clipper to evaluate both
   // inside the IF()
   //
   AddKeyAction(K_CTRL_H, {|| IF((nLen := LEN(xKey)) > 0,;
                       ((xKey := SUBSTR(xKey, 1, --nLen)), SeekIt(xKey, .T., b)),;
                       NIL) })
   xKey := ""
   WHILE lContinue
      @ 0, 0 SAY PADR("Find Key = " + xKey, MAXCOL() + 1) COLOR "W+/BG"

      ForceStable( b )

      IF ( b:hitTop .OR. b:hitBottom )
         TONE(87.3,1)
         TONE(40,3.5)

      ENDIF

      cKey := CHR((nKey := INKEY(0)))

      IF !OnKey( nKey, b )
         IF ( nKey >= 65 .AND. nKey <= 90 ) .OR. ;
                ( nKey >= 97 .AND. nKey <= 122 )
            xKey += cKey
            SeekIt( xKey, .T., b)

         ENDIF

      ENDIF

   END
   restscreen(,,,,cScreen)
   RETURN (NIL)

// EOF - TBR32.PRG //
