/*****
 *
 * TBKEYACT.PRG
 *
 * Clipper tbkeyact /N /W
 *
 */

#include "inkey.ch"

#define     KEY_CODE      1
#define     ACTION        2

STATIC aKeyAction := ;
   { {K_DOWN      , {|obj| obj:down()}}     ,;
     {K_UP        , {|obj| obj:up()}}       ,;
     {K_PGDN      , {|obj| obj:pageDown()}} ,;
     {K_PGUP      , {|obj| obj:pageUp()}}   ,;
     {K_CTRL_PGUP , {|obj| obj:goTop()}}    ,;
     {K_CTRL_PGDN , {|obj| obj:goBottom()}} ,;
     {K_RIGHT     , {|obj| obj:right()}}    ,;
     {K_LEFT      , {|obj| obj:left()}}     ,;
     {K_HOME      , {|obj| obj:home()}}     ,;
     {K_END       , {|obj| obj:end()}}      ,;
     {K_CTRL_LEFT , {|obj| obj:panLeft()}}  ,;
     {K_CTRL_RIGHT, {|obj| obj:panRight()}} ,;
     {K_CTRL_HOME , {|obj| obj:panHome()}}  ,;
     {K_CTRL_END  , {|obj| obj:panEnd()}}    }

/*****
 *
 * Looks up for a key code into array
 * Executes associated code block
 * Returns .T. if key was found in array
 *
 */

FUNCTION OnKey( nKey, oTBr )
   LOCAL nFound

   nFound := ASCAN( aKeyAction, {|aSub| aSub[KEY_CODE] == nKey} )
   IF (nFound != 0)
      EVAL( aKeyAction[nFound, ACTION], oTBr )

   ENDIF
   RETURN (nFound != 0)

/*****
 *
 * Adds a key and a codeblock to array
 *
 */

FUNCTION AddKeyAction( nKey, bBlock )
   // Warning: maximum number of array elements is 4096
   AADD( aKeyAction, {nKey, bBlock} )
   RETURN (.T.)

/*****
 *
 * Deletes a key and action from array
 *
 */

FUNCTION DelKeyAction( nKey )
   LOCAL nFound

   // Warning: does not check for empty array!
   nFound := ASCAN( aKeyAction, {|aSub| aSub[KEY_CODE] == nKey} )
   IF (nFound != 0)
      ADEL( aKeyAction, nFound )
      ASIZE( aKeyAction, LEN(aKeyAction) - 1 )

   ENDIF
   RETURN (nFound != 0)

/*****
 *
 * Replaces the codeblock for a given key with a new one
 *
 */

FUNCTION ChangeAction( nKey, bBlock )
   LOCAL nFound

   // Warning: does not check for empty array!
   nFound := ASCAN( aKeyAction, {|aSub| aSub[KEY_CODE] == nKey} )
   IF (nFound != 0)
      aKeyAction[nFound, ACTION] := bBlock

   ENDIF
   RETURN (nFound != 0)

// EOF - TBKEYACT.PRG //
