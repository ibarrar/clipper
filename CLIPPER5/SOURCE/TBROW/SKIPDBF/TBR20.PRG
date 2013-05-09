/*****
 *
 * TBR20.PRG
 *
 * Clipper tbr20 /N /W
 * RTLINK FILE tbr20
 *
 */

#include "inkey.ch"
#include "setcurs.ch"

#define     COLSEP     CHR(32)  + CHR(179) + CHR(32)
#define     HEADSEP    CHR(205) + CHR(209) + CHR(205)
#define     FOOTSEP    CHR(205) + CHR(207) + CHR(205)

FUNCTION Main()
   LOCAL cScreen
   // Serves just for test purposes
   cScreen := savescreen()
   SETCURSOR(SC_NONE)
   SCROLL()

   // Open File
   USE test NEW
   // Go to start condition
   GOTO 100

   BroWhile( ,,,,,, "RECNO() >= 100" )
   SCROLL()
   restscreen(,,,,cScreen)
   RETURN (NIL)

/*****
 *
 * BroWhile()
 *
 * nTop, nLeft, nBottom, nRight - window coordinates
 *                                defaults to min and max
 *                                of the screen
 * aColFld - array of columns for table
 *           (defaults to all fields)
 * cUdf - UDF label - passed as string
 * cWhileCond - while condition - passed as string
 * cColTit - array of titles for each column
 *
 * This generic function is based on the TBrowse Class.
 * Made to act like DBEDIT() and include its significant
 * parameters only. Most importantly, it incorporates a
 * WHILE condition.
 *
 * BroWhile( , , , , , , cFiltCond )        // do it!
 * BroWhile( , , , , , "Udf" , cFiltCond )  // do it
 *                                             with Udf!
 *
 *
 */

FUNCTION BroWhile( nTop, nLeft, nRight, nBottom,;
                   aColFld, cUdf, cWhileCond, aColTit )

   LOCAL bWhileCond, bUdf
   LOCAL cColr := SETCOLOR()
   LOCAL lColFld, lColTit, lUdf
   LOCAL nCOunt, nRow, nCol, nKey := 0
   LOCAL nRetUdf := 1
   LOCAL nNumOfFlds, nCursor := SETCURSOR(SC_NONE)
   LOCAL nMode := 4
   LOCAL o, column

   // Default coordinates
   nTop    := IF(VALTYPE( nTop )  != "N", 0       , nTop)
   nLeft   := IF(VALTYPE( nLeft)  != "N", 0       , nLeft)
   nBottom := IF(VALTYPE(nBottom) != "N", MAXROW(), nBottom)
   nRight  := IF(VALTYPE(nRight)  != "N", MAXCOL(), nRight)

   // Was array of fields passed?
   lColFld := VALTYPE(aColFld) == "A"

   // Macro-compile any udf passed
   lUdf := (VALTYPE(cUdf) == "C" .AND. LEN(cUdf) > 0)
   bUdf := IF(lUdf, &("|nMode, nElement| " + cUdf +;
                    "(nMode, nElement)}" ), ;
                    {|| .T.})

   // Macro-compile any while conditions passed, else
   // default to every record
   bWhileCond := IF(VALTYPE(cWhileCond) == "C" .AND.;
               LEN(cWhileCond) > 0,;
               &("{|| " + cWhileCond + " }") , ;
               {|| .T.})

   // Was array of titles passed?
   lColTit := VALTYPE(aColTit) == "A"

   // Create Browse object
   o := TBROWSEDB( nTop, nLeft, nBottom, nRight )

   // Color table
   o:colorSpec := "B+/W, W+/G, GR+/R"

   // Add custom "Skippers"
   // To handle While condition
   o:skipBlock     := {|nSkip| SkipDB(nSkip, bWhileCond)}
   o:goTopBlock    := {|| GoTopDB( bWhileCond )}
   o:goBottomBlock := {|| GoBottomDB( bWhileCond )}

   // Determine number of columns
   nNumOfFlds := IF(lColFld, LEN(aColFld), FCOUNT())

   // Add Columns
   FOR nCount := 1 TO nNumOfFlds
      // Make object
      column := TBColumnNew( IF(lColTit, aColTit[ nCount ],;
               IF(lColFld, aColFld[ nCount ], ;
               FIELDNAME( nCount ) ) ), ;
               FIELDWBLOCK(IF(lColFld, ;
               aColFld[ nCount ], ;
               FIELDNAME( nCount ) ), SELECT() ) )
      column:headSep := HEADSEP
      column:colSep  := COLSEP
      column:footSep := FOOTSEP

      // Memo?
      // Then do not show data
      // Show memo designator
      column:block := IF(VALTYPE(;
                       &(FIELDNAME(nCount ))) == "M", ;
                       {|| "Memo"}, column:block)

      // Add column to Browse object
      o:addColumn(column)

   NEXT

   // Main loop
   nMode := 0

   WHILE .T.
      // Determine wheather to continue, and if so, in
      // what manner should the screen be repainted
      IF nRetUdf == 0
         EXIT

      ELSEIF nRetUdf == 1
         o:refreshCurrent()

      ELSEIF nRetUdf == 2
         o:refreshAll()

      ENDIF
      nRetUdf := 1

      // Stabilize
      WHILE !o:stabilize()
      END

      IF o:stable
         // Retain coordinates
         nRow := ROW()
         nCol := COL()

         IF o:hitTop .OR. o:hitBottom
            TONE(500, 1)

            IF o:hitTop .AND. o:hitBottom
               // Empty
               nMode := 3

            ELSEIF o:hitTop
               nMode := 1

            ELSEIF o:hitBottom
               nMode := 2

            ENDIF

         ENDIF

         // If there is an Udf to process, do so
         IF lUdf
            nRetUdf := EVAL( bUdf, nMode, o:colPos )

         ELSEIF nMode == 4 .AND. !lUdf
            // If non-movement key is pressed and no Udf
            // to process, then, get out of here
            EXIT

         ENDIF

         // Reset mode, if WAS greater than zero
         IF nMode > 0
            nMode := 0

         ENDIF

         // Get Keys
         nKey := INKEY(0)

         // Process Keys
         IF nKey == K_UP
            o:up()

         ELSEIF nKey == K_DOWN
            o:down()

         ELSEIF nKey == K_LEFT
            o:left()

         ELSEIF nKey == K_RIGHT
            o:right()

         ELSEIF nKey == K_PGUP
            o:pageUp()

         ELSEIF nKey == K_PGDN
            o:pageDown()

         ELSEIF nKey == K_CTRL_PGUP
            o:goTop()

         ELSEIF nKey == K_CTRL_PGDN
            o:goBottom()

         ELSE
            nMode := 4

         ENDIF

      ENDIF

   END

   SETCURSOR(nCursor)
   SETCOLOR(cColr)
   RETURN (NIL)

STATIC FUNCTION GoTopDB( bWhileCond )
   // Skip all the way to top of condition
   WHILE EVAL( bWhileCond ) .AND. !BOF()
      DBSKIP(-1)
      IF !EVAL( bWhileCond )
         DBSKIP(1)
         EXIT

      ENDIF

   END
   RETURN (NIL)

STATIC FUNCTION GoBottomDB( bWhileCond )
   // Skip to bottom of condition block
   WHILE EVAL( bWhileCond ) .AND. !EOF()
      DBSKIP(1)

   END
   // GO back to the last occurrence
   DBSKIP(-1)
   RETURN (NIL)

STATIC FUNCTION SkipDB( nSkipRequest, bWhileCOnd )
   LOCAL nActSkip := 0

   IF nSkipRequest == 0
      DBSKIP(0)

   ELSEIF nSkipRequest > 0 .AND. !EOF()
      // keep skipping until number of skips requested
      // is satisfied
      WHILE nActSkip < nSkipRequest
         DBSKIP(1)

         // Evaluate condition to each record
         IF !EVAL( bWhileCond ) .OR. EOF()
         DBSKIP(-1)
         EXIT

         END

         // Mantain counter
         nActSkip++

      END

   ELSEIF nSkipRequest < 0
      WHILE nActSkip > nSkipRequest
         DBSKIP(-1)
         // This check is important! BOF bangs do not
         // sit on phanton record. Rather the top record
         // is evaluated, and may meet the condition
         IF BOF()
            EXIT

         ENDIF

         // Evaluate condition to each record
         IF !EVAL( bWhileCond )
            DBSKIP(1)
            EXIT

         ENDIF

         // Mantain counter
         nActSkip--

      END

   ENDIF
   // Return the number of ACTUAL skips processed
   RETURN (nActSkip)

// EOF - TBR20.PRG //
