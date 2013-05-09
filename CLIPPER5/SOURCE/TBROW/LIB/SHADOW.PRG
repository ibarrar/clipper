/*****
 *
 * SHADOW.PRG
 * A shadow with "see-thru"
 *
 */

FUNCTION Shadow( nTop, nLeft, nBottom, nRight )
   LOCAL nShadowLen, cShadow

   cShadow := SAVESCREEN( nTop, nLeft, nBottom, nRight )
   nShadowLen := LEN(cShadow)
   
   RESTSCREEN( nTop, nLeft, nBottom, nRight,;
               TRANSFORM(cShadow, REPLICATE("X" + CHR(7), nShadowLen)))
   RETURN (.T.)

// EOF - SHADOW.PRG //
