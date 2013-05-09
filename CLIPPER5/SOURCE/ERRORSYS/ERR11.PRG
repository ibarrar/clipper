/*****
 *
 * ERR11.PRG
 *
 * Same as err10.prg but using BEGIN SEQUENCE...END
 *
 * Clipper err11 /N /W
 * RTLINK FILE err11
 *
 */

#include "Error.ch"
#include "Setcurs.ch"

#define     MY_COLORS        "W+/BG,N/GR*,,,W+/B*"
#define     MY_ROW           5
#define     MY_COL           5
#define     MY_VALUE         1
#define     ABORT_IT         "Abort"
#define     MY_DEFAULT       "Return 1"
#define     CLIPPER_DEFAULT  "Return 0"

static cScreen

FUNCTION Main()
   LOCAL aArrayIn
   LOCAL aArrayOut
   LOCAL nI, nChoice
   LOCAL aErrOptions := { MY_DEFAULT, CLIPPER_DEFAULT, ABORT_IT }

   LOCAL bOldError, oErr
   bOldError := ERRORBLOCK( {|e| BREAK(e)} )

   cScreen := savescreen()
   SETCOLOR( MY_COLORS )
   SETBLINK(.F.); SETCURSOR(SC_NONE); SCROLL()

   aArrayIn := aArrayOut := ARRAY( 5 )
   FillArray( aArrayIn )

   // Calculating with error handling...
   FOR nI := 1 TO LEN( aArrayIn )

      BEGIN SEQUENCE

      aArrayOut[nI] :=  nI / aArrayIn[nI]

      RECOVER USING oErr

         nChoice := ALERT( oErr:description + ;
                           TRANSFORM( nI, " in element 99"), ;
                           aErrOptions )

         IF nChoice == LEN( aErrOptions )
            // Bye.
            restscreen(,,,,cScreen)
            QUIT

         ELSEIF nChoice == LEN( aErrOptions ) - 1
            aArrayOut[nI] := CLIPPER_DEFAULT

         ELSE
            aArrayOut[nI] := MY_DEFAULT

         ENDIF

      END SEQUENCE

   NEXT

   // Show'em
   SETPOS( ROW() + 5, 0 )
   AEVAL( aArrayOut, { |nElement| QOUT( nElement ) } )

   ERRORBLOCK( bOldError )
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

// EOF - ERR11.PRG //
