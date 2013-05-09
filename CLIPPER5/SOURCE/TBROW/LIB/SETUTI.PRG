/*****
 *
 * SETUTI.PRG
 * Push/Pop SETs
 *
 */

#include "set.ch"

#define     MAX_ARR_SIZE        4096

// Status Array
STATIC aStatus := {}

/*****
 *
 * Push SETs
 * PopSets() --> lSuccess
 *
 */

FUNCTION PushSets()
   LOCAL aSub[_SET_COUNT]
   LOCAL lRet := .F.

   // Check for maximum array size
   IF LEN(aStatus) < MAX_ARR_SIZE
      // Load Array with SETs
      AEVAL( aSub, {|x,i| aSub[i] := SET(i)} )

      lRet := (AADD( aStatus, aSub ) == aSub)

   ENDIF

   RETURN (lRet)

/*****
 *
 * Pop SETs
 * PopSets() --> lSuccess
 *
 */

FUNCTION PopSets()
   LOCAL aSub := ATAIL( aStatus )
   LOCAL lRet := .F.

   // Check array size
   IF LEN(aStatus) > 0
      // Restore status from array
      AEVAL( aSub, {|x,i| SET(i, x)} )

      // Resize array
      ASIZE( aStatus, LEN(aStatus) - 1 )
      lRet := .T.

   ENDIF

   RETURN (lRet)

// EOF - SETUTI.PRG //

