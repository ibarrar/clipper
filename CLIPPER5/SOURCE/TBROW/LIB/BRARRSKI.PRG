/*****
 *
 * BRARRSKI.PRG
 * Skippers for arrays
 *
 */

/*****
 *
 * ArrayGoTop(<nSubscript>) --> NIL
 * nSubscript should be passed by reference
 *
 */

FUNCTION ArrayGoTop( nSubscript )
   nSubscript := 1
   RETURN (NIL)

/*****
 *
 * ArrayGoBottom(<aArray>, <nSubscript>) --> NIL
 * nSubscript should be passed by reference
 *
 */

FUNCTION ArrayGoBottom( aArray, nSubscript )
   nSubscript := LEN(aArray)
   RETURN (NIL)

/*****
 *
 * ArraySkip(<nRequest>, <aArray>, <nSubscript>) --> NIL
 * nSubscript should be passed by reference
 *
 */

FUNCTION ArraySkip( nRequest, aArray, nSubscript )
   LOCAL nActually := 0

   nActually := IF(ABS(nRequest) >= IF(nRequest >= 0,;
                  LEN(aArray) - nSubscript, nSubscript - 1),;
                    IF(nRequest >= 0, LEN(aArray) - nSubscript,;
                       1 - nSubscript), nRequest)
                 
   nSubscript += nActually
   RETURN (nActually)

// EOF - BRARRSKI.PRG //
