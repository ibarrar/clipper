/*****
 *
 * TBR1.PRG
 *
 * Clipper tbr1 /N /W
 * RTLINK FILE tbr1
 *
 */

FUNCTION Main()
   // Your variables
   LOCAL b, column, nKey, cScreen

   // Your Settings
   cScreen := savescreen()
   SET SCOREBOARD OFF
   SET CONFIRM    ON

   // First open your file with indexes
   // Use NEW in lieu of SELECT 0
   USE test INDEX test3 NEW

   // Colors
   SETCOLOR("N/W")
   SCROLL()
   SETCOLOR("W+/BG,GR+/B")
   SCROLL( 2, 6, 22, 72 )
   @ 2, 6 TO 22,72 DOUBLE

   // Now is time to create a TBrowse object
   // TBrowseDB( top, left, bottom, right ) ===> Object
   b := TBrowseDB( 3, 7, 21, 71 )

   // Note that TBrowseDB() creates an object with no column
   // objects. In order to make the object usable, a column
   // must be added for each field to display.
   // This example use three fields.
   //
   // TBColumnNew( cHeading, bBlock ) =====> Object
   // Returns a new column object with specified heading
   // and data retrieval block

   column := TBColumnNew( "Field 1", {|| test->fld1} )

   // addColumn( objColumn ) =====> self
   // Adds a new column object to the browse object and
   // TBrowse:colCount is increased by one.

   b:addColumn( column )

   // Repeat the same to the other fields
   column := TBColumnNew( "Field 2", {|| test->fld2} )
   b:addColumn( column )
   column := TBColumnNew( "Field 3", {|| test->fld3} )
   b:addColumn( column )

   // Time to put this thing to work
   WHILE .T.
      // Stabilize display
      // stabilize() =====> lStable
      // Performs incremental stabilization. Stabilization is
      // performed in increments so that it can be interrupted
      // by any asynchronous event.
      // A value of .T. is returned indicating the object
      // is stable

      WHILE ( !b:stabilize() )
      END

      // b:stable contains .T. if the browse object is stable
      // Is display stable?
      IF ( b:stable )
         // everything is done; just wait for a key
         nKey := INKEY(0)

      ENDIF

      // Key pressed, get out of here
      EXIT

   END
   restscreen(,,,,cScreen)
   RETURN (NIL)

// EOF - TBR1.PRG //
