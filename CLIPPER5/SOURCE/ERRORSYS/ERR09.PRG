/*****
 *
 * ERR09.PRG
 *
 * Clipper err09 /N /W
 * RTLINK FILE err09
 *
 */

#include "Error.ch"
#include "Setcurs.ch"

#define     MY_COLORS        "W+/BG,N/GR*,,,W+/B*"
#define     MY_ROW           5
#define     MY_COL           5
#define     MY_VALUE         1
#define     RETURN_RESULT    "Return 1"
#define     ABORT_IT         "Abort"

static cScreen


FUNCTION Main()
   LOCAL aArrayIn[5]
   LOCAL aArrayOut := {}

   LOCAL bOldError
   bOldError := ERRORBLOCK( {|oErr| ErrHandler( oErr )} )

   cScreen := savescreen()
   SETCOLOR( MY_COLORS )
   SETBLINK(.F.); SETCURSOR(SC_NONE); SCROLL()

   FillArray( aArrayIn )

   // Potencial division by zero!
   //
   AEVAL( aArrayIn, {|nElement, nSubscript| ;
                       AADD( aArrayOut,;
                       nSubscript / nElement ) } )

   // Show'em
   SETPOS( ROW() + 5, 0 )
   AEVAL( aArrayOut, { |nElement| QOUT( nElement ) } )

   ERRORBLOCK( bOldError )
   scroll()
   restscreen(,,,,cScreen)
   RETURN (NIL)

/*****
 *
 *  FillArray( aArray ) --> NIL
 *
 */

STATIC FUNCTION FillArray( aArray )
   LOCAL GetList := {}
   LOCAL nI

   AFILL( aArray, 0 )

   FOR nI := 1 TO LEN( aArray )
      @ MY_ROW + nI, MY_COL SAY TRANSFORM( nI, "Element 99 : " )
      @ ROW(), COL() GET aArray[nI] PICTURE "999.99"

   NEXT

   SETCURSOR(SC_NORMAL)
   READ
   SETCURSOR(SC_NONE)

   RETURN (NIL)

/*****
 *
 * ErrHandler( ErrorObject ) -> nValue
 *
 */

STATIC FUNCTION ErrHandler( oErr )
   LOCAL aErrOptions := { RETURN_RESULT, ABORT_IT }
   LOCAL nChoice

   IF oErr:genCode == EG_ZERODIV
      nChoice := ALERT( oErr:description, aErrOptions )
      IF nChoice == LEN( aErrOptions )
         restscreen(,,,,cScreen)
         QUIT

      ENDIF

   ENDIF

   RETURN (MY_VALUE)

// EOF - ERR09.PRG //
