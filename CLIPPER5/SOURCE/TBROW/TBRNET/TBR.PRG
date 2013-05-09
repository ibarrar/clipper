/*****
 *
 * TBR.PRG
 * TBrowse Functions
 *
 *
 */

#include "inkey.ch"
#include "setcurs.ch"
#include "getexit.ch"

#define     TIMEOUT          5

/*****
 *
 * ForceStable(<oBrowse>) --> .T.
 *
 */

FUNCTION ForceStable( obj )
   DISPBEGIN()
   WHILE !obj:stabilize()
   END
   DISPEND()
   RETURN (.T.)

/*****
 *
 * Cursor Movement Methods
 *
 * TBMoveCursor(<oBrowse>, <nKey>) --> lSucess
 *
 */

FUNCTION TBMoveCursor( oBrowse, nKey )
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
      EVAL( aKeys[++nFound], oBrowse )

   ENDIF
   RETURN (nFound != 0)

/*****
 *
 * @...GET
 *
 * DoGet( <oBrowse> [,<cGetColor>] [,<bCustomReader>] ) --> lUpdated
 *
 */

FUNCTION DoGet( oBr, cClr, bReader )
   LOCAL nCursSave, xOldKey, xNewKey
   LOCAL column, get, nKey

   nCursSave := SETCURSOR(SC_NORMAL)

   ForceStable( oBr )
   column := oBr:getColumn( oBr:colPos )
   get := GetNew( ROW(), COL(), column:block,;
                  column:heading ,, cClr )

   xOldKey := IF( EMPTY(INDEXKEY()), NIL, &(INDEXKEY()) )

   // Changing to a custom reader to allow time out
   //
   get:reader := bReader

   READMODAL( {get} )
   SETCURSOR(SC_NONE)

   xNewKey := IF( EMPTY(INDEXKEY()), NIL, &(INDEXKEY()) )
   IF ( xOldKey != xNewKey )
      oBr:refreshAll()
      ForceStable( oBr )
      WHILE &(INDEXKEY()) > xNewKey .AND. !oBr:hitTop()
         oBr:up()
         ForceStable( oBr )

      END

   ELSE
      oBr:refreshCurrent()
      ForceStable( oBr )

   ENDIF

   nKey := LASTKEY()
   IF ( nKey == K_UP .OR. nKey == K_DOWN .OR. ;
      nKey == K_PGUP .OR. nKey == K_PGDN )
      KEYBOARD CHR( nKey )

   ENDIF
   RETURN (UPDATED())

/*****
 *
 * get:reader with time-out
 *
 * EditIt(<oGet> [,<nTime>])
 */

FUNCTION EditIt( oGet, nTime )
   LOCAL nKey

   nTime := IF(nTime == NIL, TIMEOUT, nTime)

   IF GetPreValidate(oGet)
      // Activate the GET for reading
		oGet:setFocus()

      WHILE ( oGet:exitState == GE_NOEXIT )
         // Check for initial no editable positions
         IF oGet:typeOut
            oGet:exitState := GE_ENTER

         ENDIF

         // Apply keystrokes until exit or time out
         WHILE oGet:exitState == GE_NOEXIT
            IF ((nKey := INKEY(nTime)) != 0)
               GetApplyKey( oGet, nKey )

            ELSE
               oGet:undo()
               oGet:exitState := GE_ESCAPE

            ENDIF

         END

         // Disallow exit if the VALID condition
         // is not satisfied
         IF !GetPostValidate(oGet)
            oGet:exitState := GE_NOEXIT

         ENDIF

      END

      // De-activate the GET
      oGet:killFocus()

   ENDIF

   RETURN (NIL)

// EOF - TBR.PRG //
