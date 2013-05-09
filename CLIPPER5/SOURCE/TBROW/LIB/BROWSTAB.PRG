/*****
 *
 * BROWSTAB.PRG
 * TBrowse stabilization functions
 *
 */

/*****
 *
 * Forces stabilization of a TBrowse object
 *
 * ForceStable(<oBrowse>) --> .T.
 *
 */

FUNCTION ForceStable(oBrowse)
   DISPBEGIN()
   WHILE !(oBrowse:stabilize())
   END        
   DISPEND()
   RETURN (.T.)

/*****
 *
 * Incremental stabilization of a TBrowse object
 *
 * IncrStable(<oBrowse>) --> nKeyCode
 *
 */

FUNCTION IncrStable(oBrowse)
   WHILE (NEXTKEY() == 0) .AND. !(oBrowse:stabilize())
   END
   RETURN (INKEY())

// EOF - BROWSTAB.PRG //
