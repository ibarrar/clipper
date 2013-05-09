/*****
 *
 * BROWGET.PRG
 * "@...GET" on a TBrowse object
 *
 */

#include "inkey.ch"
#include "setcurs.ch"

/*****
 *
 * "@...GET" on a TBrowse
 *
 * DoGet(<oBrowse>[,<cGetColor>][,<cPicture>][,<bCustomReader>]) 
 *                                                      --> lUpdated
 *
 */

FUNCTION DoGet( oBrowse, cGetClr, cPicture, bReader )
   LOCAL nCursSave, xOldKey, xNewKey
   LOCAL oColumn, oGet, nKey

   // Cursors are for GETs, so:
   nCursSave := SETCURSOR(SC_NORMAL)

   // Make sure browse is stable
   ForceStable(oBrowse)

   oColumn := oBrowse:getColumn(oBrowse:colPos)

   // create a corresponding GET and READ it
   oGet := GETNEW(ROW(), COL(), oColumn:block,;
                  oColumn:heading, cPicture, cGetClr )

   // Custom reader (if any)
   oGet:reader := bReader

   // Get old key value or NIL
   // Sometimes there is no way to avoid macros...
   //
   xOldKey := IF(EMPTY(INDEXKEY()), NIL, &(INDEXKEY()))

   // READ it!
   READMODAL({oGet})

   // Turn cursor back to its previous state
   SETCURSOR(nCursSave)

   // When a TBrowse object stabilizes, it always tries to 
   // leave the same "cell" highlighted as it was previously.
   // That is, it always tries to keep the highlight at the 
   // same position within the browse window unless it is 
   // explicitly moved via an up() or down() message. The 
   // TBrowse positions the data source in a corresponding 
   // fashion. If there are not enough rows left in a data 
   // source (i.e. EOF encontered while trying to adjust the
   // database to match the window), the TBrowse will relent
   // and move the cursor upward, leaving it on the correct
   // record but with part of the window unfilled. That works
   // OK for logical EOF, but a problem can occur when a GET
   // on a key field causes the current record to move so 
   // close to logical BOF that it is impossible to highlight
   // the current record while leaving the highlight in the 
   // same position within the window. In this case, TBrowse
   // opts to leave the highlight in the same position within
   // the window, even though that position no longer 
   // corresponds with the same record as before. That is, 
   // it repositions the database as far it will go, then 
   // leaves the highlight where it was. The result is that 
   // you end up with the highlight on a different record 
   // than the one just edited. This will fix the behavior.

   // Get records key value or NIL
   xNewKey := IF(EMPTY(INDEXKEY()), NIL, &(INDEXKEY()))

   // If key was changed
   IF xOldKey != xNewKey
      // Refresh
      oBrowse:refreshAll()
      ForceStable(oBrowse)

      // Make sure we are still in the right record
      // after stabilizing
      WHILE &(INDEXKEY()) > xNewKey .AND. !oBrowse:hitTop()
         oBrowse:up()
         ForceStable(oBrowse)

      END

   ELSE
      oBrowse:refreshCurrent()
      ForceStable(oBrowse)

   ENDIF

   // check exit key
   nKey := LASTKEY()
   IF ( nKey == K_UP .OR. nKey == K_DOWN .OR. ;
      nKey == K_PGUP .OR. nKey == K_PGDN )
      KEYBOARD CHR(nKey)

   ENDIF
   RETURN (UPDATED())

// EOF - BROWGET.PRG //
