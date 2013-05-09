/*****
 *
 * BROWSEEK.PRG
 * SeekIt(<xKey>, <lSoftSeek>, <oBrowse>) --> lFound
 *
 */

FUNCTION SeekIt( xKey, lSoftSeek, oObj )
   LOCAL lFound, nRecNo

   nRecNo    := RECNO()
   lSoftSeek := IF(VALTYPE(lSoftSeek) == "L", lSoftSeek, .F.)

   IF !(lFound := DBSEEK( xKey, lSoftSeek ))
      IF EOF()
         // Not found.
         // Keep pointer in the same place
         DBGOTO(nRecNo)
         oObj:invalidate()

      ELSE
         // Not Found but, SoftSeek is on!
         // But there is that behaviour on TBrowse...
         //
         SetHilite(oObj)

      ENDIF

   ELSE
      // Found!
      // But there is that behaviour on TBrowse...
      //
      SetHilite(oObj)

   ENDIF

   RETURN (lFound)

/*****
 *
 * SetHilite(<oBrowse>, <nRecNo>) --> .T.
 *
 * Puts the hilite in the correct place
 *
 */

FUNCTION SetHilite(oObj, nRecNo)
   nRecNo := RECNO()
   DISPBEGIN()
   oObj:refreshAll()
   ForceStable( oObj )
   WHILE (nRecNo != RECNO()) .AND. !(oObj:hitTop())
      oObj:up()
      ForceStable( oObj )

   END
   DISPEND()

   RETURN (.T.)

// EOF - BROWSEEK.PRG //
