/***
*
*  Lblback.prg
*
*  Clipper LABEL FORM runtime system
*
*  Copyright (c) 1990-1993, Computer Associates International, Inc.
*  All rights reserved.
*
*  Compile: /m /n /w
*
*/

#include "lbldef.ch"
#include "error.ch"

#define BUFFSIZE        1034          // Size of label file
#define FILEOFFSET      74            // Start of label content descriptions
#define FIELDSIZE       60
#define REMARKOFFSET    2
#define REMARKSIZE      60
#define HEIGHTOFFSET    62
#define HEIGHTSIZE      2
#define WIDTHOFFSET     64
#define WIDTHSIZE       2
#define LMARGINOFFSET   66
#define LMARGINSIZE     2
#define LINESOFFSET     68
#define LINESSIZE       2
#define SPACESOFFSET    70
#define SPACESSIZE      2
#define ACROSSOFFSET    72
#define ACROSSSIZE      2

// File error definitions
#define  F_OK              0          // No error
#define  F_EMPTY          -3          // File is empty
#define  F_ERROR          -1          // Some kind of error
#define  F_NOEXIST         2          // File does not exist


/***
*  __LblLoad( cLblFile ) --> aLabel
*  Load a (.lbl) file into a label array as specified in lbldef.ch
*
*/
FUNCTION __LblLoad( cLblFile )
   LOCAL i, j       := 0                  // Counters
   LOCAL cBuff      := SPACE(BUFFSIZE)    // File buffer
   LOCAL nHandle    := 0                  // File handle
   LOCAL nReadCount := 0                  // Bytes read from file
   LOCAL lStatus    := .F.                // Status
   LOCAL nOffset    := FILEOFFSET         // Offset into file
   LOCAL nFileError := F_OK               // File error
   LOCAL cFieldText := ""                 // Text expression container
   LOCAL err                              // error object

   LOCAL cDefPath          // contents of SET DEFAULT string
   LOCAL aPaths            // array of paths
   LOCAL nPathIndex := 0   // iteration counter

   // Create and initialize default label array
   LOCAL aLabel[ LB_COUNT ]
   aLabel[ LB_REMARK ]  := SPACE(60)      // Label remark
   aLabel[ LB_HEIGHT ]  := 5              // Label height
   aLabel[ LB_WIDTH ]   := 35             // Label width
   aLabel[ LB_LMARGIN ] := 0              // Left margin
   aLabel[ LB_LINES ]   := 1              // Lines between labels
   aLabel[ LB_SPACES ]  := 0              // Spaces between labels
   aLabel[ LB_ACROSS ]  := 1              // Number of labels across
   aLabel[ LB_FIELDS ]  := {}             // Array of label fields

   // Open the label file
   nHandle := FOPEN( cLblFile )

   IF ( ! EMPTY( nFileError := FERROR() ) ) .AND. !( "\" $ cLblFile .OR. ":" $ cLblFile )

      // Search through default path; attempt to open label file
      cDefPath := SET( _SET_DEFAULT )
      cDefPath := STRTRAN( cDefPath, ",", ";" )
      aPaths := ListAsArray( cDefPath, ";" )

      FOR nPathIndex := 1 TO LEN( aPaths )
         nHandle := FOPEN( aPaths[ nPathIndex ] + "\" + cLblFile )
         // if no error is reported, we have our label file
         IF EMPTY( nFileError := FERROR() )
            EXIT

         ENDIF

      NEXT nPathIndex

   ENDIF

   // File error
   IF nFileError != F_OK
      err := ErrorNew()
      err:severity := ES_ERROR
      err:genCode := EG_OPEN
      err:subSystem := "FRMLBL"
      err:osCode := nFileError
      err:filename := cLblFile
      Eval(ErrorBlock(), err)
   ENDIF

   // If we got this far, assume the label file is open and ready to go
   // and so go ahead and read it
   nReadCount := FREAD( nHandle, @cBuff, BUFFSIZE )

   // READ ok?
   IF nReadCount == 0
      nFileError := F_EMPTY             // File is empty
   ELSE
      nFileError := FERROR()            // Check for DOS errors
   ENDIF

   IF nFileError == 0

      // Load label dimension into aLabel
      aLabel[ LB_REMARK ] := SUBSTR(cBuff, REMARKOFFSET, REMARKSIZE)
      aLabel[ LB_HEIGHT ] := BIN2W(SUBSTR(cBuff, HEIGHTOFFSET, HEIGHTSIZE))
      aLabel[ LB_WIDTH  ] := BIN2W(SUBSTR(cBuff, WIDTHOFFSET, WIDTHSIZE))
      aLabel[ LB_LMARGIN] := BIN2W(SUBSTR(cBuff, LMARGINOFFSET, LMARGINSIZE))
      aLabel[ LB_LINES  ] := BIN2W(SUBSTR(cBuff, LINESOFFSET, LINESSIZE))
      aLabel[ LB_SPACES ] := BIN2W(SUBSTR(cBuff, SPACESOFFSET, SPACESSIZE))
      aLabel[ LB_ACROSS ] := BIN2W(SUBSTR(cBuff, ACROSSOFFSET, ACROSSSIZE))

      FOR i := 1 TO aLabel[ LB_HEIGHT ]

         // Get the text of the expression
         cFieldText := TRIM( SUBSTR( cBuff, nOffset, FIELDSIZE ) )
         nOffset += 60

         IF !EMPTY( cFieldText )

            AADD( aLabel[ LB_FIELDS ], {} )

            // Field expression
            AADD( aLabel[ LB_FIELDS, i ], &( "{ || " + cFieldText + "}" ) )

            // Text of field
            AADD( aLabel[ LB_FIELDS, i ], cFieldText )

            // Compression option
            AADD( aLabel[ LB_FIELDS, i ], .T. )

       ELSE

         AADD( aLabel[ LB_FIELDS ], NIL )

         ENDIF

      NEXT

      // Close file
      FCLOSE( nHandle )
      nFileError = FERROR()

   ENDIF
   RETURN( aLabel )

/***
*
*  ListAsArray( <cList>, <cDelimiter> ) --> aList
*  Convert a delimited string to an array
*
*/
STATIC FUNCTION ListAsArray( cList, cDelimiter )

   LOCAL nPos
   LOCAL aList := {}                  // Define an empty array
   LOCAL lDelimLast := .F.
  
   IF cDelimiter == NIL
      cDelimiter := ","
   ENDIF

   DO WHILE ( LEN(cList) <> 0 )

      nPos := AT(cDelimiter, cList)

      IF ( nPos == 0 )
         nPos := LEN(cList)
      ENDIF

      IF ( SUBSTR( cList, nPos, 1 ) == cDelimiter )
         lDelimLast := .T.
         AADD(aList, SUBSTR(cList, 1, nPos - 1)) // Add a new element
      ELSE
         lDelimLast := .F.
         AADD(aList, SUBSTR(cList, 1, nPos)) // Add a new element
      ENDIF

      cList := SUBSTR(cList, nPos + 1)

   ENDDO

   IF ( lDelimLast )
      AADD(aList, "")
   ENDIF

   RETURN aList                       // Return the array

