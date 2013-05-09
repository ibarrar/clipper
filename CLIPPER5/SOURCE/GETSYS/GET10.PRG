/*****
 *
 * GET10.PRG
 *
 *
 * Clipper get10 /N /W
 * RTLINK FILE get10
 *
 */

/*

  Here is an example on how one can make a custom READER
  for one's GET's. With the use of the @..GET..SEND clause
  one can implement special behavior on a particular GET
  without modifying the default Getsys.Prg.

  In this case this is a simple implementation on GET-ting
  whole numbers from right-to-left, as opposed to the default
  left-to-right, and at the same time toggling the number to
  be positive/negative.

  [ Feel free to improve/improvise for a more spectacular
    behavior. ]

*/

#include "inkey.ch"
#include "getexit.Ch"

FUNCTION Main()
   LOCAL n1, n2, n3
   LOCAL cScreen
   // It is a good idea declare GetList
   LOCAL GetList := {}

   // Setup initial values
   n1 := 0
   n2 := 0
   n3 := 0.00

   cScreen := savescreen()
   CLS
   // 1st & 3rd GET's use default READER
   // 2nd only works well with whole numbers
   @ 10, 10 GET n1
   @ 11, 10 GET n2 SEND READER := { |oGet| MyRead( oGet ) }
   @ 12, 10 GET n3
   READ

   ? n1, VALTYPE( n1 )
   ? n2, VALTYPE( n2 )
   ? n3, VALTYPE( n3 )

   restscreen(,,,,cScreen)
   RETURN (NIL)

/********
 *
 * MyRead( oGet ) "READER"
 *
 * A personalized numeric get GetObj:READER.
 * Passed by the @..GET..SEND clause to READMODAL().
 *
 * NOTE: Currently works only on whole numbers without the
 *       use of WHEN, VALID, RANGE, COLOR, or PICTURE clause.
 *
 * Can toggle numbers as negatives/positives.
 *
 */

FUNCTION MyRead( oGet )
   LOCAL cTemp, nKey := 0

   // Set Input Focus
   oGet:setFocus()

   // Set cursor position to rightmost column
   SETPOS( oGet:row, oGet:col + LEN( oGet:buffer ) - 1 )

   // Store initial value of GET variable to oGet:BUFFER
   oGet:buffer := STR( oGet:varget() )

   // Store Get object buffer to a temporary variable
   cTemp := IF( oGet:varget() == 0, "", ALLTRIM( oGet:buffer ) )

   // Key processing loop
   WHILE ( nKey := INKEY(0) ) != K_ENTER         ;
      .AND. nKey != K_UP                         ;
      .AND. nKey != K_DOWN                       ;
      .AND. nKey != K_ESC                        ;
      .AND.  LEN( cTemp ) < LEN( oGet:BUFFER )   ;
      .AND. ( CHR(nKey) $ "0123456789-" .OR. nKey == K_DEL )

      IF CHR( nKey ) == "-"
         cTemp := IF(VAL(cTemp) != 0,;
                  ALLTRIM(STR(VAL( cTemp ) * -1 )), "")

      ELSEIF nKey == K_DEL
         cTemp := ""

      ELSE
         cTemp := cTemp + CHR( nKey )

      ENDIF

      IF LEN( cTemp ) > 0
         oGet:buffer := PADL(cTemp,LEN(oGet:buffer))

      ELSE
         oGet:buffer := PADL("0", LEN(oGet:buffer))

      ENDIF
      oGet:display()

      // Reset cursor position to rightmost column
      SETPOS(oGet:row, oGet:col + LEN(oGet:buffer) - 1)

   END

   // Store new value to GET variable
   IF nKey != K_ESC
      oGet:varput(VAL(oGet:buffer))

   ENDIF

   // Update oGet:sxitState
   IF nKey == K_UP
      oGet:exitState := GE_UP

   ELSEIF nKey == K_DOWN
      oGet:exitState := GE_DOWN

   ELSEIF nKey == K_ESC
      oGet:exitState := GE_ESCAPE

   ELSE
      oGet:exitState := GE_ENTER

   ENDIF

   // Kill Input focus
   oGet:killFocus()

   RETURN (NIL)

// EOF - GET10.PRG //
