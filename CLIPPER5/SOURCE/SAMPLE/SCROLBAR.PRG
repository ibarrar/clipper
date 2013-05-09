/***
*
*  Scrolbar.prg
*
*  Implements a scroll bar that can be updated as the cursor moves down
*  in a TBrowse object, ACHOICE(), DBEDIT(), or MEMOEDIT()
*
*  Copyright (c) 1993, Computer Associates International Inc.
*  All rights reserved.
*
*  NOTE: Compile with /n /w
*
*/

#include "Fileman.ch"


/***
*
*  ScrollBarNew( <nTopRow>, <nTopColumn>, <nBottomRow>, 
*                <cColorString>, <nInitPosition> ) --> aScrollBar
*  
*  Create a new scroll bar array with the specified coordinates
*
*/
FUNCTION ScrollBarNew( nTopRow, nTopColumn, nBottomRow, ;
                        cColorString, nInitPosition )

   LOCAL aScrollBar := ARRAY( TB_ELEMENTS )

   aScrollBar[ TB_ROWTOP ]    := nTopRow
   aScrollBar[ TB_COLTOP ]    := nTopColumn
   aScrollBar[ TB_ROWBOTTOM ] := nBottomRow
   aScrollBar[ TB_COLBOTTOM ] := nTopColumn

   // Set the default color to White on Black if none specified
   IF cColorString == NIL
      cColorString := "W/N"
   ENDIF
   aScrollBar[ TB_COLOR ] := cColorString

   // Set the starting position
   IF nInitPosition == NIL
      nInitPosition := 1
   ENDIF
   aScrollBar[ TB_POSITION ] := nInitPosition

   RETURN ( aScrollBar )



/***
*
*  ScrollBarDisplay( <aScrollBar> ) --> aScrollBar
*
*  Display a scoll bar array to the screen
*
*/
FUNCTION ScrollBarDisplay( aScrollBar )
   
   LOCAL cOldColor
   LOCAL nRow

   cOldColor := SETCOLOR( aScrollBar[ TB_COLOR ] )

   // Draw the arrows
   @ aScrollBar[ TB_ROWTOP ], aScrollBar[ TB_COLTOP ] SAY TB_UPARROW
   @ aScrollBar[ TB_ROWBOTTOM ], aScrollBar[ TB_COLBOTTOM ] SAY TB_DNARROW

   // Draw the background
   FOR nRow := (aScrollBar[ TB_ROWTOP ] + 1) TO (aScrollBar[ TB_ROWBOTTOM ] - 1)
      @ nRow, aScrollBar[ TB_COLTOP ] SAY TB_BACKGROUND
   NEXT

   SETCOLOR( cOldColor )

   RETURN ( aScrollBar )



/***
*
*  ScrollBarUpdate( <aScrollBar>, <nCurrent>, <nTotal>,
*     <lForceUpdate> ) --> aScrollBar
*
*  Update scroll bar array with new tab position and redisplay tab
*
*/
FUNCTION ScrollBarUpdate( aScrollBar, nCurrent, nTotal, lForceUpdate )

   LOCAL cOldColor
   LOCAL nNewPosition
   LOCAL nScrollHeight := ( aScrollBar[TB_ROWBOTTOM] - 1 ) - ;
                          ( aScrollBar[TB_ROWTOP] )

   IF nTotal < 1
      nTotal := 1
   ENDIF

   IF nCurrent < 1
      nCurrent := 1
   ENDIF

   IF nCurrent > nTotal
      nCurrent := nTotal
   ENDIF

   IF lForceUpdate == NIL
      lForceUpdate := .F.
   ENDIF

   cOldColor := SETCOLOR( aScrollBar[ TB_COLOR ] )

   // Determine the new position
   nNewPosition := ROUND( (nCurrent / nTotal) * nScrollHeight, 0 )

   // Resolve algorythm oversights
   nNewPosition := IF( nNewPosition < 1, 1, nNewPosition )
   nNewPosition := IF( nCurrent == 1, 1, nNewPosition )
   nNewPosition := IF( nCurrent >= nTotal, nScrollHeight, nNewPosition )

   // Overwrite the old position (if different), then draw in the new one
   IF nNewPosition <> aScrollBar[ TB_POSITION ] .OR. lForceUpdate
      @ (aScrollBar[ TB_POSITION ] + aScrollBar[ TB_ROWTOP ]), ;
         aScrollBar[ TB_COLTOP ] SAY TB_BACKGROUND
      @ (nNewPosition + aScrollBar[ TB_ROWTOP ]), aScrollBar[ TB_COLTOP ] SAY ;
        TB_HIGHLIGHT
      aScrollBar[ TB_POSITION ] := nNewPosition
   ENDIF

   SETCOLOR( cOldColor )

   RETURN ( aScrollBar )
