/*****
 *
 * BRFUNC.PRG
 * General purpose functions for TBrowse objects
 *
 *
 */

#include "inkey.ch"
#include "setcurs.ch"

/*****
 *
 * DoGet() -> .T.
 *
 * GET on a TBrowse object
 *
 */

STATIC FUNCTION DoGet( oObj, cGetClr )
   LOCAL nCursSave, xOldKey, xNewKey
   LOCAL column, oGet, nKey

   // Parameter checking
   cGetClr := IF(cGetClr == NIL, "I", cGetClr)

   // Cursors are for GETs, so:
   nCursSave := SETCURSOR(SC_NORMAL)

   // make sure browse is stable
   ForceStable(oObj)

   column := oObj:oGetColumn(oObj:colPos)

   // create a corresponding GET and READ it
   oGet := GetNew(ROW(), COL(), column:block,;
               column:heading,, cGetClr )

   // Get old key value or NIL
   // Sometimes there is no way to avoid macros...
   //
   xOldKey := IF(EMPTY(INDEXKEY()), NIL, &(INDEXKEY()))

   // READ it!
   READMODAL({oGet})

   // Turn cursor to its previous state
   SETCURSOR(nCursSave)

   // When a TBrowse object stabilizes, it always
   // tries to leave the same "cell" highlighted
   // as was previously.
   // That is, it always tries to keep the highlight at
   // the same position within the browse window unless
   // it is explicitly moved via an up() or down()
   // message. The TBrowse positions the data source in a
   // corresponding fashion. If there are not enough rows
   // left in a data source (i.e. EOF encontered while
   // trying to adjust the database to match the window),
   // the TBrowse willrelent and move the cursor upward,
   // leaving it on the correct record but with part of
   // the window unfilled.
   // That works OK for logical EOF, but a problem can
   // occur when a GET on a key field causes the current
   // record to move so close to logical BOF that it is
   // impossible to highlight the current record while
   // leaving the highlight in the same position within
   // the window. In this case, TBrowse opts to leave the
   // highlight in the same position within the window,
   // even though that position no longer corresponds with
   // the same record as before. That is, it repositions
   // the database as far it will go, then leaves the
   // highlight where it was. The result is that you end up
   // with the highlight on a different record than the one
   // just edited. This will fix the behavior.

   // Get records key value or NIL
   xNewKey := IF(EMPTY(INDEXKEY()), NIL, &(INDEXKEY()))

   // If key was changed
   IF xOldKey != xNewKey
      // Refresh
      oObj:refreshAll()
      ForceStable(oObj)

      // Make sure we are still in the right record
      // after stabilizing
      WHILE &(INDEXKEY()) > xNewKey .AND. !oObj:hitTop()
         oObj:up()
         ForceStable(oObj)

      END

   ELSE
      oObj:refreshCurrent()
      ForceStable(oObj)

   ENDIF

   // check exit key
   nKey := LASTKEY()
   IF ( nKey == K_UP .OR. nKey == K_DOWN .OR. ;
      nKey == K_PGUP .OR. nKey == K_PGDN )
      KEYBOARD CHR(nKey)

   ENDIF
   RETURN (.T.)

/*****
 *
 * ForceStable() -> .T.
 *
 * Forces stabilization of a Tbrowse object
 *
 */

FUNCTION ForceStable( oObj )
   WHILE !oObj:stabilize()
   END
   RETURN (.T.)

/*****
 *
 * IncrStable() -> nKeyCode
 *
 * Incremental stabilization
 *
 */

FUNCTION IncrStable( oObj )
   WHILE NEXTKEY() == 0 .AND. !oObj:stabilize()
   END

   RETURN (INKEY())

/*****
 *
 * SeekIt() -> lLogical
 *
 */

FUNCTION SeekIt( xKey, lSoftSeek, oObj )
   LOCAL lFound, nRecno

   nRecno    := RECNO()
   lSoftSeek := IF(VALTYPE(lSoftSeek) == "L", lSoftSeek, .F.)

   IF !(lFound := DBSEEK( xKey, lSoftSeek ))
      IF EOF()
         // Not found.
         // Keep pointer in the same place
         DBGOTO(nRecno)
         oObj:invalidate()

      ENDIF

   ELSE
      // Found!
      // But there is that behaviour on TBrowse...
      //
      nRecno := RECNO()
      DISPBEGIN()
      oObj:refreshAll()
      ForceStable( oObj )
      WHILE (nRecno != RECNO()) .AND. !(oObj:hitTop())
         oObj:up()
         ForceStable( oObj )

      END
      DISPEND()

   ENDIF

   RETURN (lFound)

// EOF - BRFUNC.PRG //
