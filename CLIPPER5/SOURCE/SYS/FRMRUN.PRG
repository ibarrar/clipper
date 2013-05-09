/***
*
*  Frmrun.prg
*
*  Clipper REPORT FORM runtime system
*
*  Copyright (c) 1990-1993, Computer Associates International, Inc.
*  All rights reserved.
*
*  Compile: /m /n /w
*
*/

#include "frmdef.ch"
#include "error.ch"

/***
*  Nation Message Constants
*  These constants are used with the NationMsg(<msg>) function.
*  The <msg> parameter can range from 1-12 and returns the national
*  version of the system message.
*/
#define _RF_PAGENO       3     // "Page No."
#define _RF_SUBTOTAL     4     // "** Subtotal **"
#define _RF_SUBSUBTOTAL  5     // "* Subsubtotal *"
#define _RF_TOTAL        6     // "*** Total ***"

#define S87_COMPAT					// preserve Summer '87 compatability

STATIC aReportData, nPageNumber, nLinesLeft, aReportTotals
STATIC aGroupTotals, lFirstPass, lFormFeeds, nMaxLinesAvail

/***
*
*  __ReportForm( <cFRMName>, [<lPrinter>], <cAltFile>,
*         [<lNoConsole>], <bFor>, <bWhile>, <nNext>, <nRecord>,
*         <lRest>, <lPlain>, [<cHeading>], [<lBEject>],
*         [<lSummary>] )
*
*/
PROCEDURE __ReportForm( cFRMName, lPrinter, cAltFile, lNoConsole, bFor, ;
                       bWhile, nNext, nRecord, lRest, lPlain, cHeading, ;
                       lBEject, lSummary )

   LOCAL lPrintOn, lConsoleOn // Status of PRINTER and CONSOLE
   LOCAL cExtraFile, lExtraState // Status of EXTRA
   LOCAL nCol, nGroup
   LOCAL xBreakVal, lBroke := .F.
   LOCAL err

   LOCAL lAnyTotals
   LOCAL lAnySubTotals

   // Resolve parameters
   IF cFRMName == NIL
      err := ErrorNew()
      err:severity := ES_ERROR
      err:genCode := EG_ARG
      err:subSystem := "FRMLBL"
      Eval(ErrorBlock(), err)
   ELSE
      IF AT( ".", cFRMName ) == 0
         cFRMName := TRIM( cFRMName ) + ".FRM"
      ENDIF
   ENDIF

#ifdef OLDCODE
   IF lPrinter == NIL
     lPrinter   := .F.
   ENDIF
#endif

   IF cHeading == NIL
     cHeading := ""
   ENDIF

   // Set output devices
#ifdef OLDCODE
   lPrintOn   := SET( _SET_PRINTER, lPrinter )

   lConsoleOn := SET( _SET_CONSOLE, .F. )
   SET( _SET_CONSOLE, ! ( lNoConsole .OR. !lConsoleOn ) )
#endif

   lPrintOn   := IF( lPrinter,   SET( _SET_PRINTER, lPrinter ), ;
	                               SET( _SET_PRINTER ) )

	 lConsoleOn := IF( lNoConsole, SET( _SET_CONSOLE, .F.),       ;
                                 SET( _SET_CONSOLE) )

   IF lPrinter                   // To the printer
     lFormFeeds := .T.
   ELSE
     lFormFeeds := .F.
   ENDIF

   IF (!Empty(cAltFile))            // To file
     lExtraState := SET( _SET_EXTRA, .T. )
     cExtraFile := SET( _SET_EXTRAFILE, cAltFile )
   ENDIF


   BEGIN SEQUENCE

     	aReportData := __FrmLoad( cFRMName )  // Load the frm into an array
     	nMaxLinesAvail := aReportData[RP_LINES]

     	// Modify aReportData based on the report parameters
#ifdef OLDCODE
     	IF lSummary != NIL             // Set the summary only flag
#else
      IF lSummary == .T.             // Set the summary only flag
#endif
          aReportData[ RP_SUMMARY ] := lSummary
     	ENDIF
     	IF lBEject != NIL .AND. lBEject
         	aReportData[ RP_BEJECT ]  := .F.
     	ENDIF
     	IF lPlain                      // Set plain report flag
       	aReportData[ RP_PLAIN ]   := .T.
       	cHeading               := ""
       	lFormFeeds             := .F.
     	ENDIF
     	aReportData[ RP_HEADING ]    := cHeading

     	// Add to the left margin if a SET MARGIN has been defined
     	// NOTE: uncommenting this line will cause REPORT FORM to respect
     	// SET MARGIN to screen/to file, but double the margin TO PRINT
     	// aReportData[ RP_LMARGIN ] += SET( _SET_MARGIN )

     	nPageNumber := 1                  // Set the initial page number
     	lFirstPass  := .T.             // Set the first pass flag

     	nLinesLeft  := aReportData[ RP_LINES ]

#ifdef S87_COMPAT
		QOUT()		// output additional line on first page
		nLinesLeft--
#endif

     	// Check to see if a "before report" eject, or TO FILE has been specified
     	IF aReportData[ RP_BEJECT ]
	      EjectPage()

     	ENDIF

     	// Generate the initial report header manually (in case there are no
     	// records that match the report scope)
     	ReportHeader()

     	// Initialize aReportTotals to track both group and report totals, then
     	// set the column total elements to 0 if they are to be totaled, otherwise
     	// leave them NIL
     	aReportTotals := ARRAY( LEN(aReportData[RP_GROUPS]) + 1, ;
                       	LEN(aReportData[RP_COLUMNS]) )

     	// Column total elements
     	FOR nCol := 1 TO LEN(aReportData[RP_COLUMNS])
       	IF aReportData[RP_COLUMNS,nCol,RC_TOTAL]
         	FOR nGroup := 1 TO LEN(aReportTotals)
            	aReportTotals[nGroup,nCol] := 0
         	NEXT
       	ENDIF
     	NEXT

     	// Initialize aGroupTotals as an array
     	aGroupTotals := ARRAY( LEN(aReportData[RP_GROUPS]) )

     	// Execute the actual report based on matching records
     	DBEval( { || ExecuteReport() }, bFor, bWhile, nNext, nRecord, lRest )

     	// Generate any totals that may have been identified
     	// Make a pass through all the groups
     	FOR nGroup := LEN(aReportData[RP_GROUPS]) TO 1 STEP -1


       	// make sure group has subtotals
       	lAnySubTotals := .F.
       	FOR nCol := 1 TO LEN(aReportData[RP_COLUMNS])
         	IF aReportData[RP_COLUMNS,nCol,RC_TOTAL]
            	lAnySubTotals := .T.
            	EXIT              // NOTE
         	ENDIF
       	NEXT

       	IF !lAnySubTotals
         	LOOP                 // NOTE
       	ENDIF


       	// Check to see if we need to eject the page
       	IF nLinesLeft < 2
         	EjectPage()
         	IF aReportData[ RP_PLAIN ]
            	nLinesLeft := 1000
         	ELSE
            	ReportHeader()
         	ENDIF
       	ENDIF

       	// Print the first line
       	PrintIt( SPACE(aReportData[RP_LMARGIN]) + ;
            	IF(nGroup==1,NationMsg(_RF_SUBTOTAL),;
                            NationMsg(_RF_SUBSUBTOTAL) ) )

       	// Print the second line
       	QQOUT( SPACE(aReportData[RP_LMARGIN]) )
       	FOR nCol := 1 TO LEN(aReportData[RP_COLUMNS])
         	IF nCol > 1
            	QQOUT( " " )
         	ENDIF
         	IF aReportData[RP_COLUMNS,nCol,RC_TOTAL]
            	QQOUT( TRANSFORM(aReportTotals[nGroup+1,nCol], ;
              	aReportData[RP_COLUMNS,nCol,RC_PICT]) )
         	ELSE
            	QQOUT( SPACE(aReportData[RP_COLUMNS,nCol,RC_WIDTH]) )
         	ENDIF
       	NEXT

       	// Send a cr/lf for the last line
       	QOUT()

     	NEXT

#ifdef OLDCODE
     	// Generate the "Grand totals"
     	// Check to see if we need to eject the page
     	IF nLinesLeft < 2
       	EjectPage()
       	IF aReportData[ RP_PLAIN ]
         	nLinesLeft := 1000
       	ELSE
         	ReportHeader()
       	ENDIF
     	ENDIF
#endif

     	// Any report totals?
     	lAnyTotals := .F.
     	FOR nCol := 1 TO LEN(aReportData[RP_COLUMNS])
       	IF aReportData[RP_COLUMNS,nCol,RC_TOTAL]
         	lAnyTotals := .T.
         	EXIT
       	ENDIF
     	NEXT nCol


     	IF lAnyTotals

#ifndef OLDCODE
        // Check to see if we need to eject the page
        IF nLinesLeft < 2
          EjectPage()
          IF aReportData[ RP_PLAIN ]
            nLinesLeft := 1000
          ELSE
            ReportHeader()
          ENDIF
        ENDIF
#endif

        	// Print the first line
        	PrintIt( SPACE(aReportData[RP_LMARGIN]) + NationMsg(_RF_TOTAL ) )

        	// Print the second line
        	QQOUT( SPACE(aReportData[RP_LMARGIN]) )
        	FOR nCol := 1 TO LEN(aReportData[RP_COLUMNS])
          	IF nCol > 1
            	QQOUT( " " )
          	ENDIF
          	IF aReportData[RP_COLUMNS,nCol,RC_TOTAL]
            	QQOUT( TRANSFORM(aReportTotals[1,nCol], ;
               	aReportData[RP_COLUMNS,nCol,RC_PICT]) )
          	ELSE
            	QQOUT( SPACE(aReportData[RP_COLUMNS,nCol,RC_WIDTH]) )
          	ENDIF
        	NEXT nCol

        	// Send a cr/lf for the last line
        	QOUT()

     	ENDIF

     	// Check to see if an "after report" eject, or TO FILE has been specified
     	IF aReportData[ RP_AEJECT ]
      	EjectPage()
     	ENDIF


   RECOVER USING xBreakVal

		lBroke := .T.

   END SEQUENCE


   // Clean up and leave
   aReportData   := NIL          // Recover the space
   aReportTotals  := NIL
   aGroupTotals   := NIL
   nPageNumber   := NIL
   lFirstPass    := NIL
   nLinesLeft    := NIL
   lFormFeeds    := NIL
   nMaxLinesAvail := NIL

   // clean up
   SET( _SET_PRINTER, lPrintOn )    // Set the printer back to prior state
   SET( _SET_CONSOLE, lConsoleOn )     // Set the console back to prior state

   IF (!Empty(cAltFile))            // Set extrafile back
     SET( _SET_EXTRAFILE, cExtraFile )
     SET( _SET_EXTRA, lExtraState )
   ENDIF

   IF lBroke
     // keep the break value going
     BREAK xBreakVal
   END

   RETURN

/***
*  ExecuteReport()
*  Executed by DBEVAL() for each record that matches record scope
*/
STATIC PROCEDURE ExecuteReport
   LOCAL aRecordHeader  := {}          // Header for the current record
   LOCAL aRecordToPrint := {}          // Current record to print
   LOCAL nCol                          // Counter for the column work
   LOCAL nGroup                        // Counter for the group work
   LOCAL lGroupChanged  := .F.         // Has any group changed?
   LOCAL lEjectGrp := .F.              // Group eject indicator
   LOCAL nMaxLines                     // Number of lines needed by record
   LOCAL nLine                         // Counter for each record line
   LOCAL cLine                         // Current line of text for parsing
   LOCAL nLastElement                  // Last element pointer if record is

   LOCAL lAnySubTotals

   // Add to the main column totals
   FOR nCol := 1 TO LEN(aReportData[RP_COLUMNS])
      IF aReportData[RP_COLUMNS,nCol,RC_TOTAL]
         // If this column should be totaled, do it
         aReportTotals[ 1 ,nCol] += ;
                  EVAL( aReportData[RP_COLUMNS,nCol,RC_EXP] )
      ENDIF
   NEXT

   // Determine if any of the groups have changed.  If so, add the appropriate
   // line to aRecordHeader for totaling out the previous records
   IF !lFirstPass                       // Don't bother first time through

      // Make a pass through all the groups
      FOR nGroup := LEN(aReportData[RP_GROUPS]) TO 1 STEP -1


       // make sure group has subtotals
       lAnySubTotals := .F.
       FOR nCol := 1 TO LEN(aReportData[RP_COLUMNS])
         IF aReportData[RP_COLUMNS,nCol,RC_TOTAL]
            lAnySubTotals := .T.
            EXIT              // NOTE
         ENDIF
       NEXT

#ifndef OLDCODE
       // retrieve group eject state from report form
       IF ( nGroup == 1 )
         lEjectGrp := aReportData[ RP_GROUPS, nGroup, RG_AEJECT ]
       ENDIF
#endif

       IF !lAnySubTotals
         LOOP                 // NOTE
       ENDIF

         //  For subgroup processing: check if group has been changed
			   IF MakeAStr(EVAL(aReportData[RP_GROUPS, 1, RG_EXP]),;
                 aReportData[RP_GROUPS, 1, RG_TYPE]) != aGroupTotals[1]
					  lGroupChanged  := .T.
			   ENDIF

         //  If this (sub)group has changed since the last record
         IF lGroupChanged .OR. MakeAStr(EVAL(aReportData[RP_GROUPS,nGroup,RG_EXP]),;
             aReportData[RP_GROUPS,nGroup,RG_TYPE]) != aGroupTotals[nGroup]

            AADD( aRecordHeader, IF(nGroup==1,NationMsg(_RF_SUBTOTAL),;
                                              NationMsg(_RF_SUBSUBTOTAL)) )
            AADD( aRecordHeader, "" )

#ifdef OLDCODE
				// retrieve group eject state from report form
				IF ( nGroup == 1 )
					lEjectGrp := aReportData[ RP_GROUPS, nGroup, RG_AEJECT ]
				ENDIF
#endif

            // Cycle through the columns, adding either the group
            // amount from aReportTotals or spaces wide enough for
            // the non-totaled columns
            FOR nCol := 1 TO LEN(aReportData[RP_COLUMNS])
               IF aReportData[RP_COLUMNS,nCol,RC_TOTAL]
                  aRecordHeader[ LEN(aRecordHeader) ] += ;
                     TRANSFORM(aReportTotals[nGroup+1,nCol], ;
                     aReportData[RP_COLUMNS,nCol,RC_PICT])
                  // Zero out the group totals column from aReportTotals
                  aReportTotals[nGroup+1,nCol] := 0
               ELSE
                  aRecordHeader[ LEN(aRecordHeader) ] += ;
                        SPACE(aReportData[RP_COLUMNS,nCol,RC_WIDTH])
               ENDIF
               aRecordHeader[ LEN(aRecordHeader) ] += " "
            NEXT
            // Get rid of the extra space from the last column
            aRecordHeader[LEN(aRecordHeader)] := ;
                  LEFT( aRecordHeader[LEN(aRecordHeader)], ;
                  LEN(aRecordHeader[LEN(aRecordHeader)]) - 1 )
         ENDIF
      NEXT

   ENDIF

#ifdef OLDCODE
   lFirstPass = .F.
#endif

	IF ( LEN( aRecordHeader ) > 0 ) .AND. lEjectGrp .AND. lGroupChanged
		IF LEN( aRecordHeader ) > nLinesLeft
			EjectPage()

			IF ( aReportData[ RP_PLAIN ] )
				nLinesLeft := 1000
			ELSE
				ReportHeader()
			ENDIF

		ENDIF

		AEVAL( aRecordHeader, { | HeaderLine | ;
			PrintIt( SPACE( aReportData[ RP_LMARGIN ] ) + HeaderLine ) } )

		aRecordHeader := {}

		EjectPage()

		IF ( aReportData[ RP_PLAIN ] )
			nLinesLeft := 1000

		ELSE
			ReportHeader()

		ENDIF

	ENDIF

   // Add to aRecordHeader in the event that the group has changed and
   // new group headers need to be generated

   // Cycle through the groups
   FOR nGroup := 1 TO LEN(aReportData[RP_GROUPS])
      // If the group has changed
      IF MakeAStr(EVAL(aReportData[RP_GROUPS,nGroup,RG_EXP]),;
            aReportData[RP_GROUPS,nGroup,RG_TYPE]) == aGroupTotals[nGroup]
      ELSE
         AADD( aRecordHeader, "" )   // The blank line

// page eject after group
#ifndef OLDCODE
         //  put CRFF after group
         IF nGroup == 1 .AND. !lFirstPass .AND. !lAnySubTotals
            IF lEjectGrp := aReportData[ RP_GROUPS, nGroup, RG_AEJECT ]
               nLinesLeft  := 0
            ENDIF
         ENDIF
#endif

         AADD( aRecordHeader, IF(nGroup==1,"** ","* ") +;
               aReportData[RP_GROUPS,nGroup,RG_HEADER] + " " +;
               MakeAStr(EVAL(aReportData[RP_GROUPS,nGroup,RG_EXP]), ;
               aReportData[RP_GROUPS,nGroup,RG_TYPE]) )
      ENDIF
   NEXT

#ifndef OLDCODE
   lFirstPass := .F.
#endif

   // Is there anything in the record header?
   IF LEN( aRecordHeader ) > 0
      // Determine if aRecordHeader will fit on the current page.  If not,
      // start a new header
      IF LEN( aRecordHeader ) > nLinesLeft
         EjectPage()
         IF aReportData[ RP_PLAIN ]
            nLinesLeft := 1000
         ELSE
            ReportHeader()
         ENDIF
      ENDIF

      // Send aRecordHeader to the output device, resetting nLinesLeft
      AEVAL( aRecordHeader, { | HeaderLine | ;
              PrintIt( SPACE(aReportData[RP_LMARGIN])+ HeaderLine ) } )

      nLinesLeft -= LEN( aRecordHeader )

      // Make sure it didn't hit the bottom margin
      IF nLinesLeft == 0
         EjectPage()
         IF aReportData[ RP_PLAIN ]
            nLinesLeft := 1000
         ELSE
            ReportHeader()
         ENDIF
      ENDIF
   ENDIF

   // Add to the group totals
   FOR nCol := 1 TO LEN(aReportData[RP_COLUMNS])
      // If this column should be totaled, do it
      IF aReportData[RP_COLUMNS,nCol,RC_TOTAL]
         // Cycle through the groups
         FOR nGroup := 1 TO LEN( aReportTotals ) - 1
            aReportTotals[nGroup+1,nCol] += ;
               EVAL( aReportData[RP_COLUMNS,nCol,RC_EXP] )
         NEXT
      ENDIF
   NEXT

   // Reset the group expressions in aGroupTotals
   FOR nGroup := 1 TO LEN(aReportData[RP_GROUPS])
      aGroupTotals[nGroup] := MakeAStr(EVAL(aReportData[RP_GROUPS,nGroup,RG_EXP]),;
                                    aReportData[RP_GROUPS,nGroup,RG_TYPE])
   NEXT

   // Only run through the record detail if this is NOT a summary report
   IF !aReportData[ RP_SUMMARY ]
      // Determine the max number of lines needed by each expression
     nMaxLines := 1
      FOR nCol := 1 TO LEN(aReportData[RP_COLUMNS])
				
         IF aReportData[RP_COLUMNS,nCol,RC_TYPE] $ "M"
            nMaxLines := MAX(XMLCOUNT(EVAL(aReportData[RP_COLUMNS,nCol,RC_EXP]),;
                         aReportData[RP_COLUMNS,nCol,RC_WIDTH]), nMaxLines)
         ELSEIF aReportData[RP_COLUMNS,nCol,RC_TYPE] $ "C"
            nMaxLines := MAX( XMLCOUNT( STRTRAN( EVAL( aReportData[RP_COLUMNS,nCol,RC_EXP]),;
                         ";", CHR(13)+CHR(10)),;
                         aReportData[RP_COLUMNS,nCol,RC_WIDTH]), nMaxLines)
         ENDIF
      NEXT

      // Size aRecordToPrint to the maximum number of lines it will need, then
      // fill it with nulls
      ASIZE( aRecordToPrint, nMaxLines )
      AFILL( aRecordToPrint, "" )

      // Load the current record into aRecordToPrint
      FOR nCol := 1 TO LEN(aReportData[RP_COLUMNS])
         FOR nLine := 1 TO nMaxLines
            // Check to see if it's a memo or character
            IF aReportData[RP_COLUMNS,nCol,RC_TYPE] $ "CM"
               //  Load the current line of the current column into cLine
               //  with multi-lines per record ";"- method
               IF aReportData[RP_COLUMNS,nCol,RC_TYPE] $ "C"
                  cLine := XMEMOLINE( TRIM( STRTRAN( EVAL(aReportData[RP_COLUMNS,nCol,RC_EXP]),;
                             ";", CHR(13)+CHR(10)) ),;
                             aReportData[RP_COLUMNS,nCol,RC_WIDTH], nLine )
               ELSE
                  cLine := XMEMOLINE(TRIM(EVAL(aReportData[RP_COLUMNS,nCol,RC_EXP])),;
                             aReportData[RP_COLUMNS,nCol,RC_WIDTH], nLine )
							 ENDIF
               cLine := PADR( cLine, aReportData[RP_COLUMNS,nCol,RC_WIDTH] )
            ELSE
               IF nLine == 1
                  cLine := TRANSFORM(EVAL(aReportData[RP_COLUMNS,nCol,RC_EXP]),;
                           aReportData[RP_COLUMNS,nCol,RC_PICT])
                  cLine := PADR( cLine, aReportData[RP_COLUMNS,nCol,RC_WIDTH] )
               ELSE
                  cLine := SPACE( aReportData[RP_COLUMNS,nCol,RC_WIDTH])
               ENDIF
            ENDIF
            // Add it to the existing report line
            IF nCol > 1
               aRecordToPrint[ nLine ] += " "
            ENDIF
            aRecordToPrint[ nLine ] += cLine
         NEXT
      NEXT

      // Determine if aRecordToPrint will fit on the current page
      IF LEN( aRecordToPrint ) > nLinesLeft
         // The record will not fit on the current page - will it fit on
         // a full page?  If not, break it up and print it.
         IF LEN( aRecordToPrint ) > nMaxLinesAvail
            // This record is HUGE!  Break it up...
            nLine := 1
            DO WHILE nLine < LEN( aRecordToPrint )
               PrintIt( SPACE(aReportData[RP_LMARGIN]) + aRecordToPrint[nLine] )
               nLine++
               nLinesLeft--
               IF nLinesLeft == 0
                  EjectPage()
                  IF aReportData[ RP_PLAIN ]
                     nLinesLeft := 1000
                  ELSE
                     ReportHeader()
                  ENDIF
               ENDIF
            ENDDO
         ELSE
            EjectPage()
            IF aReportData[ RP_PLAIN ]
               nLinesLeft := 1000
            ELSE
               ReportHeader()
            ENDIF
            AEVAL( aRecordToPrint, ;
               { | RecordLine | ;
                 PrintIt( SPACE(aReportData[RP_LMARGIN])+ RecordLine ) ;
               } ;
            )
            nLinesLeft -= LEN( aRecordToPrint )
         ENDIF
      ELSE
         // Send aRecordToPrint to the output device, resetting nLinesLeft
         AEVAL( aRecordToPrint, ;
            { | RecordLine | ;
              PrintIt( SPACE(aReportData[RP_LMARGIN])+ RecordLine ) ;
            } ;
         )
         nLinesLeft -= LEN( aRecordToPrint )
      ENDIF

#ifdef OLDCODE
      // Make sure it didn't hit the bottom margin
      IF nLinesLeft == 0
         EjectPage()
         IF aReportData[ RP_PLAIN ]
            nLinesLeft := 1000
         ELSE
            ReportHeader()
         ENDIF
      ENDIF
#endif

      // Tack on the spacing for double/triple/etc.
      IF aReportData[ RP_SPACING ] > 1

/*  Double space problem in REPORT FORM at the bottom of the page  */
#ifdef OLDCODE
         IF nLinesLeft > aReportData[ RP_SPACING ] - 1
#else
         IF nLinesLeft >= aReportData[ RP_SPACING ] - 1
#endif

            FOR nLine := 2 TO aReportData[ RP_SPACING ]
               PrintIt()
               nLinesLeft--
            NEXT
         ENDIF
      ENDIF

   ENDIF    // Was this a summary report?

   RETURN


/***
*
*  ReportHeader()
*
*/
STATIC PROCEDURE ReportHeader
   LOCAL nLinesInHeader := 0
   LOCAL aPageHeader    := {}
   LOCAL nHeadingLength := aReportData[RP_WIDTH] - aReportData[RP_LMARGIN] - 30
   LOCAL nCol, nLine, nMaxColLength, nGroup, cHeader
   LOCAL nHeadLine            // lines in a single heading
   LOCAL nRPageSize           // width of report after subtracting right margin
   LOCAL aTempPgHeader        // temporary page header array
   LOCAL nHeadSize


   nRPageSize := aReportData[RP_WIDTH] - aReportData[RP_RMARGIN]

   //  Header width should be less then 255 characters.
   nHeadSize := MIN (nRPageSize, 254)

   // Create the header and drop it into aPageHeader

   // Start with the heading
   IF !aReportData[ RP_PLAIN ]           // If not a plain paper report, build
      IF aReportData[RP_HEADING] == ""   // the heading
         AADD( aPageHeader, NationMsg(_RF_PAGENO) + STR(nPageNumber,6) )

      ELSE
         aTempPgHeader := ParseHeader( aReportData[ RP_HEADING ], ;
            Occurs( ";", aReportData[ RP_HEADING ] ) + 1 )

         FOR nLine := 1 TO LEN( aTempPgHeader )
            // determine number of lines in header given current report dimensions
            nLinesInHeader := MAX( XMLCOUNT( LTRIM( aTempPgHeader[ nLine ] ), ;
               nHeadingLength ), 1 )

            // extract lines and add to array
            FOR nHeadLine := 1 TO nLinesInHeader

               AADD( aPageHeader, SPACE( 15 ) + ;
                  PADC( TRIM( XMEMOLINE( LTRIM( aTempPgHeader[ nLine ] ),;
                  nHeadingLength, nHeadLine ) ), nHeadingLength ) )

            NEXT nHeadLine

         NEXT nLine
         aPageHeader[ 1 ] := STUFF( aPageHeader[ 1 ], 1, 14, ;
                                    NationMsg(_RF_PAGENO) + STR(nPageNumber,6) )

      ENDIF
      AADD( aPageHeader, DTOC(DATE()) )

   ENDIF

   // Tack on the actual header from the FRM
   FOR nLine := 1 TO LEN( aReportData[RP_HEADER] )
      // determine number of lines in header given current report dimensions

      nLinesInHeader := MAX( XMLCOUNT( LTRIM( aReportData[RP_HEADER, ;
         nLine ] ), nHeadSize ), 1 )

      // extract lines and add to array
      FOR nHeadLine := 1 TO nLinesInHeader

         cHeader := TRIM( XMEMOLINE( LTRIM( aReportData[ RP_HEADER, nLine ] ),;
            nHeadSize, nHeadLine) )

         AADD( aPageHeader, SPACE( ( nRPageSize - aReportData[ RP_LMARGIN ] - ;
            LEN( cHeader ) ) / 2 ) + cHeader )
      NEXT nHeadLine

   NEXT nLine

#ifdef S87_COMPAT
   // S87 compat.
   AADD( aPageHeader, "" )
#endif

   // Now add the column headings
   nLinesInHeader := LEN( aPageHeader )

   // Determine the longest column header
   nMaxColLength := 0
   FOR nCol := 1 TO LEN( aReportData[ RP_COLUMNS ] )
       nMaxColLength := MAX( LEN(aReportData[RP_COLUMNS,nCol,RC_HEADER]), ;
                             nMaxColLength )
   NEXT
   FOR nCol := 1 TO LEN( aReportData[ RP_COLUMNS ] )
      ASIZE( aReportData[RP_COLUMNS,nCol,RC_HEADER], nMaxColLength )
   NEXT

   FOR nLine := 1 TO nMaxColLength
      AADD( aPageHeader, "" )
   NEXT

   FOR nCol := 1 TO LEN(aReportData[RP_COLUMNS])    // Cycle through the columns
      FOR nLine := 1 TO nMaxColLength
         IF nCol > 1
            aPageHeader[ nLinesInHeader + nLine ] += " "
         ENDIF
         IF aReportData[RP_COLUMNS,nCol,RC_HEADER,nLine] == NIL
            aPageHeader[ nLinesInHeader + nLine ] += ;
                           SPACE( aReportData[RP_COLUMNS,nCol,RC_WIDTH] )
         ELSE
            IF aReportData[RP_COLUMNS,nCol,RC_TYPE] == "N"
               aPageHeader[ nLinesInHeader + nLine ] += ;
                           PADL(aReportData[RP_COLUMNS,nCol,RC_HEADER,nLine],;
                           aReportData[RP_COLUMNS,nCol,RC_WIDTH])
            ELSE
               aPageHeader[ nLinesInHeader + nLine ] += ;
                           PADR(aReportData[RP_COLUMNS,nCol,RC_HEADER,nLine],;
                           aReportData[RP_COLUMNS,nCol,RC_WIDTH])
            ENDIF
         ENDIF
      NEXT
   NEXT

   // Insert the two blank lines between the heading and the actual data
   AADD( aPageHeader, "" )
   AADD( aPageHeader, "" )
   AEVAL( aPageHeader, { | HeaderLine | ;
         PrintIt( SPACE(aReportData[RP_LMARGIN])+ HeaderLine ) } )

   // Set the page number and number of available lines
   nPageNumber++

	// adjust the line count to account for Summer '87 behavior
   nLinesLeft := aReportData[RP_LINES] - LEN( aPageHeader )
   nMaxLinesAvail := aReportData[RP_LINES] - LEN( aPageHeader )

   RETURN

/***
*  Occurs( <cSearch>, <cTarget> ) --> nCount
*  Determine the number of times <cSearch> is found in <cTarget>
*
*/
STATIC FUNCTION Occurs( cSearch, cTarget )
   LOCAL nPos, nCount := 0
   DO WHILE !EMPTY( cTarget )
      IF (nPos := AT( cSearch, cTarget )) != 0
         nCount++
         cTarget := SUBSTR( cTarget, nPos + 1 )
      ELSE
         // End of string
         cTarget := ""
      ENDIF
   ENDDO
   RETURN nCount

/***
*     MakeStr( <exp>, <cType> ) --> value
*     Convert a value of any data type into string to add to the group header
*/
STATIC FUNCTION MakeAStr( uVar, cType )
   LOCAL cString
   DO CASE
   CASE UPPER(cType) == "D"
      cString := DTOC( uVar )

   CASE UPPER(cType) == "L"
      cString := IF( uVar, "T", "F" )

   CASE UPPER(cType) == "N"
      cString := STR( uVar )

   CASE UPPER(cType) == "C"
      cString := uVar

   OTHERWISE
      cString := "INVALID EXPRESSION"
   ENDCASE
   RETURN( cString )

/***
*  PrintIt( <cString> )
*  Print a string, THEN send a CRLF
*/
STATIC PROCEDURE PrintIt( cString )

   IF cString == NIL
      cString := ""
   ELSE
#ifdef S87_COMPAT
     // prevents output of trailing space, also prevents wrapping of some
     // lines when sent to screen or 80-column printer. Comment out this
     // line for complete Summer 87 compatibility.
     //cString := Trim( cString )
#endif
   ENDIF

   QQOUT( cString )
   QOUT()

   RETURN

/***
*
*  EjectPage()
*  Eject a page if the form feed option is set
*
*/
STATIC PROCEDURE EjectPage
   IF lFormFeeds
      EJECT
   ENDIF
   RETURN

/***
*
*  XMLCOUNT( <cString>, [<nLineLength>], [<nTabSize>],
*     [<lWrap>] ) --> nLineCount
*
*/
STATIC FUNCTION XMLCOUNT( cString, nLineLength, nTabSize, lWrap )
   // Set defaults if none specified
   nLineLength := IF( nLineLength == NIL, 79, nLineLength )
   nTabSize := IF( nTabSize == NIL, 4, nTabSize )
   lWrap := IF( lWrap == NIL, .T., .F. )

   IF nTabSize >= nLineLength
      nTabSize := nLineLength - 1
   ENDIF
   RETURN( MLCOUNT( TRIM(cString), nLineLength, nTabSize, lWrap ) )


/***
*
*  XMEMOLINE( <cString>, [<nLineLength>], [<nLineNumber>],
*         [<nTabSize>], [<lWrap>] ) --> cLine
*
*/
STATIC FUNCTION XMEMOLINE( cString, nLineLength, nLineNumber, nTabSize, lWrap )

   // Set defaults if none specified
   nLineLength := IF( nLineLength == NIL, 79, nLineLength )
   nLineNumber := IF( nLineNumber == NIL, 1, nLineNumber )
   nTabSize := IF( nTabSize == NIL, 4, nTabSize )
   lWrap := IF( lWrap == NIL, .T., lWrap )

   IF nTabSize >= nLineLength
      nTabSize := nLineLength - 1
   ENDIF

   RETURN( MEMOLINE( cString, nLineLength, nLineNumber, nTabSize, lWrap ) )