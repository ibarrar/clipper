/***
*
*  Status.prg
*
*  Implements a moving status indicator that can be used during
*  a batch process to indicate that the process is indeed underway
*
*  Copyright (c) 1993, Computer Associates International Inc.
*  All rights reserved.
*
*  NOTE: Compile with /n /w options
*
*/

#define ST_LEN     4       // Length of status array
#define ST_ROW     1       // Status item display row
#define ST_COL     2       // Status item display column
#define ST_COLOR   3       // Status item color
#define ST_CURRENT 4       // Status item current position in aDisplay


STATIC aDisplay := { "|", "/", "-", "\" } // Status item display characters


/***
*
*  StatusNew( [<nRow>], [<nCol>], [<cColor>] ) --> aStat
*
*  Create a new Status array
*
*/
FUNCTION StatusNew( nRow, nCol, cColor )
   
   LOCAL aStat[ ST_LEN ]

   aStat[ ST_ROW     ] := 0
   aStat[ ST_COL     ] := 0
   aStat[ ST_COLOR   ] := "W+/N"
   aStat[ ST_CURRENT ] := 1

   IF nRow != NIL
      aStat[ ST_ROW ] := nRow
   ENDIF

   IF nCol != NIL
      aStat[ ST_COL ] := nCol
   ENDIF

   IF cColor != NIL
      aStat[ ST_COLOR ] := cColor
   ENDIF

   RETURN ( aStat )



/***
*
*  StatusUpdate( <aStat> ) --> NIL
*
*  Update screen with new Status position
*
*/
FUNCTION StatusUpdate( aStat )
   
   LOCAL cOldColor

   cOldColor := SETCOLOR( aStat[ ST_COLOR ] )

   aStat[ ST_CURRENT ]++
   IF aStat[ ST_CURRENT ] > 4
      aStat[ ST_CURRENT ] := 1
   ENDIF

   @ aStat[ ST_ROW ], aStat[ ST_COL ] SAY aDisplay[aStat[ ST_CURRENT ]]

   SETCOLOR( cOldColor )

   RETURN ( NIL )
