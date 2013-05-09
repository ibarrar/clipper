/*****
 *
 * SCRUTI.PRG
 * Screen Utilities
 *
 */

#define     THINGS_TO_SAVE         8

#define     SCR_ROW                1
#define     SCR_COL                2
#define     SCR_COLOR              3
#define     SCR_BLINK              4
#define     SCR_MAXROW             5
#define     SCR_MAXCOL             6
#define     SCR_SCREEN             7
#define     SCR_CURSOR             8

#define     MAX_ARR_SIZE           4096

// Status Array
STATIC aScrSta := {}

/*****
 *
 * Push screen status
 * PushScr() --> lSuccess
 *
 * It will add a sub-array to aScrSta
 * which will hold all screen information
 *
 * This function is going to save ROW(), COL(),
 * SETCOLOR(), SETBLINK(), SETCURSOR(),
 * MAXROW(), MAXCOL() and the screen itself.
 *
 */

FUNCTION PushScr()
   LOCAL aSub
   LOCAL lRet := .F.

   // Add another array element (sub-array)
   // Check for maximum size
   IF LEN(aScrSta) < MAX_ARR_SIZE
      aSub := ARRAY(THINGS_TO_SAVE)
      aSub[SCR_ROW]    := ROW()
      aSub[SCR_COL]    := COL()
      aSub[SCR_COLOR]  := SETCOLOR()
      aSub[SCR_BLINK]  := SETBLINK()
      aSub[SCR_MAXROW] := MAXROW()
      aSub[SCR_MAXCOL] := MAXCOL()
      aSub[SCR_SCREEN] := SAVESCREEN(0, 0, MAXROW(), MAXCOL())
      aSub[SCR_CURSOR] := SETCURSOR()

      lRet := (AADD(aScrSta, aSub) == aSub)

   ENDIF

   RETURN (lRet)

/*****
 *
 * This function will restore the screen status
 * PopScr() --> lSuccess
 *
 */

FUNCTION PopScr()
   LOCAL aSub
   LOCAL lRet := .F.

   // Non-empty array?
   IF LEN(aScrSta) > 0
      aSub := ATAIL( aScrSta )

      // Put things as before...
      // When you reset video mode your screen might
      // flash depending on your video card
      SETMODE( aSub[SCR_MAXROW] + 1, aSub[SCR_MAXCOL] + 1 )
      RESTSCREEN( 0, 0, MAXROW(), MAXCOL(), aSub[SCR_SCREEN] )
      SETPOS( aSub[SCR_ROW], aSub[SCR_COL] )
      SETCOLOR( aSub[SCR_COLOR] )
      SETBLINK( aSub[SCR_BLINK] )
      SETCURSOR( aSub[SCR_CURSOR] )

      // Resize array
      ASIZE( aScrSta, LEN(aScrSta) - 1 )
      lRet := .T.

   ENDIF

   RETURN (lRet)

// EOF - SCRUTI.PRG //
