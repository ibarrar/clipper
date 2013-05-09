/*****
 *
 * MANAGDBF.PRG
 * Browses a .dbf file
 *
 *
 * RMAKE manager
 *
 */

#include "inkey.ch"
#include "manager.ch"
#include "dbstruct.ch"

FUNCTION BrowseDBF(cFileName)
   // I think it is time to use another variable names
   // but I am a very conservative person
   // (aka without imagination for variable names)
   LOCAL b, column, nKey
   LOCAL cScr, nMaxRow, i
   LOCAL nFields

   DBUSEAREA( .F., "DbfNtx", cFileName )

   // Screen (section not handled by TBrowse)
   cScr    := SAVESCREEN( 0, 0, MAXROW(), MAXCOL())
   nMaxrow := MAXROW()
   SCROLL()
   @  0, 0 SAY SPACE(80) COLOR "N/BG"
   @  0, 0 SAY ".dbf View: " + cFileName COLOR "N/BG"
   BottLine()
   @ nMaxRow,57 SAY "Struc" COLOR "N/BG"
   @ nMaxRow,74 SAY "Exit"  COLOR "N/BG"
   @  1, 0 TO nMaxRow - 1,79 DOUBLE COLOR "BG+/B"

   // Create browse object
   b := TBrowseDB( 2, 1, nMaxRow - 2, 78)
   b:colorSpec := "BG+/B,GR+/W"
   b:headSep   := CHR(205) + CHR(209) + CHR(205)
   b:colSep    := CHR(032) + CHR(179) + CHR(032)

   // Create/add columns
   nFields := FCOUNT()
   FOR i := 1 TO nFields
      column := TBColumnNew( FIELDNAME(i),;
                             FIELDBLOCK(FIELDNAME(i)) )
      // Memo?
      IF VALTYPE(EVAL(column:block)) == "M"
         // Change data retrieval block to show "<Memo>"
         column:block := {|| "<Memo>"}

      ENDIF
      b:addColumn(column)

   NEXT

   WHILE .T.
      STABILIZE b

      IF (b:stable)
         IF (b:hitTop) .OR. (b:hitBottom)
            TONE(400, 3)

         ENDIF
         @  0,59 SAY "Record: " COLOR "N/BG"
         @  0,67 SAY RECNO()   PICTURE "999999/" COLOR "N/BG"
         @  0,74 SAY LASTREC() PICTURE "999999"  COLOR "N/BG"
         nKey := INKEY(0)

      ENDIF
      IF !TBMoveCursor( nKey, b )
         IF nKey == K_ESC .OR. nKey == K_F10
            EXIT

         ELSEIF nKey == K_F8
            DispStru()
            // Just repaint screen
            b:invalidate()

         ENDIF

      ENDIF

   END
   DBCLOSEAREA()
   RESTSCREEN( 0, 0, MAXROW(), 79, cScr )
   RETURN (NIL)

/*****
 *
 * Display .dbf structure
 *
 */

STATIC FUNCTION DispStru()
   LOCAL aStruct := {}
   LOCAL cSaveClr

   aStruct := DBSTRUCT()
   // Pad
   AEVAL( aStruct, {|x,i| aStruct[i] := DoIt(x)} )

   DISPBEGIN()
   SETCOLOR("N/BG*")
   SCROLL(  7, 18, 17, 62 )
   @  7,18 TO 17, 62 DOUBLE
   @  8,21 SAY "Field"
   @  8,34 SAY "Type"
   @  8,41 SAY "Size"
   @  8,52 SAY "Decimals"
   @ 16,21 SAY "ENTER - Exit" + SPACE(15) +;
               CHR(24) + CHR(25) +;
               " PgUp," + "PgDn"
   DISPEND()
   ShowStruc( 10, 21, 14, 59, aStruct )
   SETCOLOR(cSaveClr)
   RETURN (NIL)

STATIC FUNCTION DoIt( cElement )
   RETURN (PADR( cElement[DBS_NAME], 14 ) +;
           PADR( cElement[DBS_TYPE], 6 )  +;
           PADR( STR( cElement[DBS_LEN], 4 ), 13) +;
           STR( cElement[DBS_DEC], 3))

STATIC FUNCTION ShowStruc( nTop, nLeft, nBottom, nRight, aItems )
   LOCAL b, nKey, column
   LOCAL k, nWidth, nWindow, nInitPos
   LOCAL nNewPos, nLen, n

   nInitPos := 0
   nWindow  := nBottom - nTop
   nWidth   := nRight - nLeft - 1
   nLen     := LEN(aItems)

   // Draw the Box and Gauge
   DISPBEGIN()
   SETCOLOR("N/BG*")
   SCROLL( nTop - 1, nLeft - 1, nBottom + 1, nRight + 1)
   @ nTop - 1, nLeft - 1 TO nBottom + 1, nRight + 1
   @ nTop,nRight + 1,nBottom,nRight + 1  BOX CHR(219) ;
                                         COLOR "W+/W*"
   @ nTop,nRight + 1 SAY CHR(219) COLOR "N/W*"
   DISPEND()

   // Create a Browse Object
   b := TBrowseNew( nTop, nLeft, nBottom, nRight )

   // n is the array subscript
   n := 1

   // Go Top and Go Bottom Blocks
   b:goTopBlock    := {|| n := 1 }
   b:goBottomBlock := {|| n := nLen }

   // This is our Skip Block
   b:skipBlock := {|x| k := IF(ABS(x) >= IF(x >= 0,;
                          nLen - n, n - 1),;
                          IF(x >= 0, nLen - n, 1 - n),;
                          x), n += k, ;
                          k }

   // Create the column object
   column := TBColumnNew (, {|| aItems[n] } )
   column:width := nWidth
   //
   // About Column Width:
   //
   // When browsing array elements, you need to pay attention
   // to their size. This is very importante because TBcolumn
   // will work based in the size of the first element of
   // the array being browsed.
   // We are assuming the width between left and right margins
   //
   // Add the column to the browse
   b:addColumn( column )

   WHILE .T.
      STABILIZE b

      IF ( b:stable )
         IF ( b:hitTop .OR. b:hitBottom )
            TONE(87.3,1)
            TONE(40,3.5)

         ENDIF
         // Update Bar Gauge
         nNewPos := nWindow / (nLen / n)
         IF n == 1
            nNewPos := 0

         ELSEIF n == nLen
            nNewPos := nWindow

         ENDIF
         IF nInitPos != nNewPos
            @ nTop + nInitPos,;
            nRight + 1 SAY CHR(219) COLOR "W+/W*"
            @ nTop + nNewPos, nRight + 1;
            SAY CHR(219) COLOR "N/W*"
            nInitPos := nNewPos

         ENDIF
         nKey := INKEY(0)

      ENDIF

      // Process key
      IF !TBMoveCursor( nKey, b )
         IF ( nKey == K_ENTER )
            EXIT

         ENDIF

      ENDIF

   END
   RETURN (NIL)

// EOF - MANAGDBF.DBF //
