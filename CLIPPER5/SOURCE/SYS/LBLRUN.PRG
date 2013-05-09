/***
*
*  Lblrun.prg
*
*  Clipper LABEL FORM runtime system
*
*  Copyright (c) 1990-1993, Computer Associates International, Inc.
*  All rights reserved.
*
*  Compile: /m /n /w
*
*/

#include "lbldef.ch"                 // Label array definitions
#include "error.ch"

/***
*  Nation Message Constants
*  These constants are used with the NationMsg(<msg>) function.
*  The <msg> parameter can range from 1-12 and returns the national
*  version of the system message.
*/
#define _LF_SAMPLES      2      // "Do you want more samples?"
#define _LF_YN           12     // "Y/N"


// File-wide static declarations
// Label definition array
STATIC aLabelData := {}
STATIC aBandToPrint := {}
STATIC cBlank := ""
STATIC lOneMoreBand := .T.
STATIC nCurrentCol  := 1            // The current column in the band

/***
*
*  __LabelForm( <cLBLName>, [<lPrinter>], <cAltFile>, [<lNoConsole>],
*        <bFor>, <bWhile>, <nNext>, <nRecord>, <lRest>, [<lSample>] )
*
*  Print the specified (.lbl) definition for specified records
*  meeting specified scope and condition
*
*/
PROCEDURE __LabelForm( cLBLName, lPrinter, cAltFile, lNoConsole, bFor, ;
                       bWhile, nNext, nRecord, lRest, lSample )
   LOCAL lPrintOn := .F.               // PRINTER status
   LOCAL lConsoleOn                    // CONSOLE status
   LOCAL cExtraFile, lExtraState       // EXTRA file status
   LOCAL xBreakVal, lBroke := .F.
   LOCAL err
   Local OldMargin


   // Resolve parameters
   IF cLBLName == NIL
      err := ErrorNew()
      err:severity := ES_ERROR
      err:genCode := EG_ARG
      err:subSystem := "FRMLBL"
      Eval(ErrorBlock(), err)

   ELSE
      IF AT( ".", cLBLName ) == 0
         cLBLName := TRIM( cLBLName ) + ".LBL"
      ENDIF

   ENDIF
 
   IF lPrinter == NIL
      lPrinter := .F.
   ENDIF
 
   IF lSample == NIL
      lSample := .F.
   ENDIF
 
   // Set output devices
   IF lPrinter             // To the printer
      lPrintOn  := SET( _SET_PRINTER, lPrinter )
   ENDIF

   lConsoleOn := SET( _SET_CONSOLE )
   SET( _SET_CONSOLE, ! ( lNoConsole .OR. !lConsoleOn ) )
 
   IF (!Empty(cAltFile))         // To file
      lExtraState := SET( _SET_EXTRA, .T. )
      cExtraFile  := SET( _SET_EXTRAFILE, cAltFile )
   ENDIF
 
   OldMargin := SET( _SET_MARGIN, 0)
   
   BEGIN SEQUENCE
 
      aLabelData := __LblLoad( cLBLName )  // Load the (.lbl) into an array
 
      // Add to the left margin if a SET MARGIN has been defined
      aLabelData[ LB_LMARGIN ] += OldMargin
 
      // Size the aBandToPrint array to the number of fields
      ASIZE( aBandToPrint, LEN( aLabelData[ LB_FIELDS ] ) )
      AFILL( aBandToPrint, SPACE( aLabelData[ LB_LMARGIN ] ) )
 
      // Create enough space for a blank record
      cBlank := SPACE( aLabelData[ LB_WIDTH ] + aLabelData[ LB_SPACES ] )
 
      // Handle sample labels
      IF lSample
         SampleLabels()
      ENDIF
 
      // Execute the actual label run based on matching records
      DBEval( { || ExecuteLabel() }, bFor, bWhile, nNext, nRecord, lRest )
 
      // Print the last band if there is one
      IF lOneMoreBand
         // Print the band
         AEVAL( aBandToPrint, { | BandLine | PrintIt( BandLine ) } )

      ENDIF
 
 
   RECOVER USING xBreakVal
 
      lBroke := .T.
 
   END SEQUENCE

   // Clean up and leave
   aLabelData   := {}                // Recover the space
   aBandToPrint := {}
   nCurrentCol  := 1
   cBlank       := ""
   lOneMoreBand :=.T.
 
   // clean up
   SET( _SET_PRINTER, lPrintOn ) // Set the printer back to prior state
   SET( _SET_CONSOLE, lConsoleOn )  // Set the console back to prior state
 
   IF (!Empty(cAltFile))            // Set extrafile back
      SET( _SET_EXTRAFILE, cExtraFile )
      SET( _SET_EXTRA, lExtraState )
   ENDIF
 
   IF lBroke
      BREAK xBreakVal               // continue breaking
   ENDIF
 
   SET( _SET_MARGIN, OldMargin)
   
   RETURN

/***
*
*  ExecuteLabel()
*  Process the label array using the current record
*
*/
STATIC PROCEDURE ExecuteLabel
   LOCAL nField, nMoreLines, aBuffer := {}, cBuffer
   LOCAL v
 
   // Load the current record into aBuffer
   FOR nField := 1 TO LEN( aLabelData[ LB_FIELDS ] )

      if ( aLabelData[ LB_FIELDS, nField ] <> NIL )

         v := Eval( aLabelData[ LB_FIELDS, nField, LF_EXP ] )

         cBuffer := PadR( v, aLabelData[ LB_WIDTH ] )
         cBuffer += Space( aLabelData[ LB_SPACES ] )

         if ( aLabelData[ LB_FIELDS, nField, LF_BLANK ] )
            if ( !Empty( cBuffer ) )
               AADD( aBuffer, cBuffer )
            end
         else
            AADD( aBuffer, cBuffer )
         endif

      else

         AADD( aBuffer, NIL )

      end

   NEXT

   ASIZE( aBuffer, LEN( aLabelData[ LB_FIELDS ] ) )
 
   // Add aBuffer to aBandToPrint
   FOR nField := 1 TO LEN( aLabelData[ LB_FIELDS ] )
      IF aBuffer[ nField ] == NIL
         aBandToPrint[ nField ] += cBlank
      ELSE
         aBandToPrint[ nField ] += aBuffer[ nField ]
      ENDIF
   NEXT
 
   IF nCurrentCol == aLabelData[ LB_ACROSS ]

     // trim
     FOR nField := 1 TO LEN( aBandToPrint )
       aBandToPrint[ nField ] := Trim( aBandToPrint[ nField ] )
     NEXT


      lOneMoreBand := .F.
      nCurrentCol  := 1
 
      // Print the band
      AEVAL( aBandToPrint, { | BandLine | PrintIt( BandLine ) } )

      nMoreLines := aLabelData[ LB_HEIGHT ] - LEN( aBandToPrint )
      IF nMoreLines > 0
         FOR nField := 1 TO nMoreLines
            PrintIt()
         NEXT
      ENDIF
      IF aLabelData[ LB_LINES ] > 0
 
         // Add the spaces between the label lines
         FOR nField := 1 TO aLabelData[ LB_LINES ]
            PrintIt()
         NEXT
 
      ENDIF
 
      // Clear out the band
      AFILL( aBandToPrint, SPACE( aLabelData[ LB_LMARGIN ] ) )
   ELSE
      lOneMoreBand := .T.
      nCurrentCol++
   ENDIF
 
   RETURN

/***
*
*  SampleLabels()
*  Print sample labels
*
*/
STATIC PROCEDURE SampleLabels
   LOCAL nGetKey, lMoreSamples := .T., nField
   LOCAL aBand := {}
 
   // Create the sample label row
   ASIZE( aBand, aLabelData[ LB_HEIGHT ] )
   AFILL( aBand, SPACE( aLabelData[ LB_LMARGIN ] ) +;
              REPLICATE( REPLICATE( "*", ;
              aLabelData[ LB_WIDTH ] ) + ;
              SPACE( aLabelData[ LB_SPACES ] ), ;
              aLabelData[ LB_ACROSS ] ) )
 
   // Prints sample labels
   DO WHILE lMoreSamples
 
      // Print the samples
      AEVAL( aBand, { | BandLine | PrintIt( BandLine ) } )

      IF aLabelData[ LB_LINES ] > 0
         // Add the spaces between the label lines
         FOR nField := 1 TO aLabelData[ LB_LINES ]
            PrintIt()
         NEXT nField
      ENDIF
 
      // Prompt for more
      @ ROW(), 0 SAY NationMsg(_LF_SAMPLES)+" ("+Nationmsg(_LF_YN)+")"
      nGetKey := INKEY(0)
      @ ROW(), COL() SAY CHR(nGetKey)
      IF ROW() == MAXROW()
         SCROLL( 0, 0, MAXROW(), MAXCOL(), 1 )
         @ MAXROW(), 0 SAY ""
      ELSE
         @ ROW()+1, 0 SAY ""
      ENDIF
      IF IsNegative(CHR(nGetKey))   // Don't give sample labels
         lMoreSamples := .F.
      ENDIF
   ENDDO
   RETURN

/***
*
*  PrintIt( <cString> )
*  Print a string, then send a CRLF
*
*/
STATIC PROCEDURE PrintIt( cString )

   IF cString == NIL
      cString := ""
   ENDIF
   QQOUT( cString )
   QOUT()

   RETURN
