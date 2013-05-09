/***
*
*  Frmback.prg
*
*  Create a report array from a (.frm) file
*
*  Copyright (c) 1990-1993, Computer Associates International, Inc.
*  All rights reserved.
*
*  Compile: /m /n /w
*
*/

#include "frmdef.ch"
#include "error.ch"

// Definitions for buffer sizes
#define  SIZE_FILE_BUFF             1990       // Size of report file
#define  SIZE_LENGTHS_BUFF          110
#define  SIZE_OFFSETS_BUFF          110
#define  SIZE_EXPR_BUFF             1440
#define  SIZE_FIELDS_BUFF           300
#define  SIZE_PARAMS_BUFF           24

// Definitions for offsets into the FILE_BUFF string
#define  LENGTHS_OFFSET             5          // Start of expression length array
#define  OFFSETS_OFFSET             115        // Start of expression position array
#define  EXPR_OFFSET                225        // Start of expression data area
#define  FIELDS_OFFSET              1665       // Start of report columns (fields)
#define  PARAMS_OFFSET              1965       // Start of report parameters block

// These are offsets into the FIELDS_BUFF string to actual values
// Values are added to a block offset FLD_OFFSET that is moved in
// increments of 12
#define  FIELD_WIDTH_OFFSET         1
#define  FIELD_TOTALS_OFFSET        6
#define  FIELD_DECIMALS_OFFSET      7

// These are offsets into FIELDS_BUFF which are used to 'point' into
// the EXPR_BUFF string which contains the textual data
#define  FIELD_CONTENT_EXPR_OFFSET  9
#define  FIELD_HEADER_EXPR_OFFSET   11

// These are actual offsets into the PARAMS_BUFF string which
// are used to 'point' into the EXPR_BUFF string
#define  PAGE_HDR_OFFSET            1
#define  GRP_EXPR_OFFSET            3
#define  SUB_EXPR_OFFSET            5
#define  GRP_HDR_OFFSET             7
#define  SUB_HDR_OFFSET             9

// These are actual offsets into the PARAMS_BUFF string to actual values
#define  PAGE_WIDTH_OFFSET          11
#define  LNS_PER_PAGE_OFFSET        13
#define  LEFT_MRGN_OFFSET           15
#define  RIGHT_MGRN_OFFSET          17
#define  COL_COUNT_OFFSET           19
#define  DBL_SPACE_OFFSET           21
#define  SUMMARY_RPT_OFFSET         22
#define  PE_OFFSET                  23
#define  OPTION_OFFSET              24

// File error definitions
#define  F_OK                       0          // No error
#define  F_EMPTY                   -3          // File is empty
#define  F_ERROR                   -1          // Some kind of error
#define  F_NOEXIST                  2          // File does not exist

// Declare file-wide statics
STATIC cExprBuff
STATIC cOffsetsBuff
STATIC cLengthsBuff

/***
*
*  __FrmLoad( cFrmFile ) --> aReport
*  Reads a report (.frm) file and creates a report array
*
*  Notes:
*
*      1.   Report file name has extension.
*      2.   File error number placed in nFileError
*      3.   Offsets start at 1. Offsets are into a Clipper string, 1 to 1990
*      4.   The offsets mentioned in these notes are actual DOS FILE offsets,
*           not like the offsets declared in the body of FrmLoad()
*           which are Clipper STRING offsets.
*      5.   Report file length is 7C6h (1990d) bytes.
*      6.   Expression length array starts at 04h (4d) and can
*           contain upto 55 short (2 byte) numbers.
*      7.   Expression offset index array starts at 72h (114d) and
*           can contain upto 55 short (2 byte) numbers.
*      8.   Expression area starts at offset E0h (224d).
*      9.   Expression area length is 5A0h (1440d).
*     10.   Expressions in expression area are null terminated.
*     11.   Field expression area starts at offset 680h (1664d).
*     12.   Field expressions (column definition) are null terminated.
*     13.   Field expression area can contain upto 25 12-byte blocks.
*/

/***
*
*  __FrmLoad( <cFrmFile> ) --> aReport
*
*/
FUNCTION __FrmLoad( cFrmFile )
   LOCAL cFieldsBuff
   LOCAL cParamsBuff
   LOCAL nFieldOffset   := 0
   LOCAL cFileBuff      := SPACE(SIZE_FILE_BUFF)
   LOCAL cGroupExp      := SPACE(200)
   LOCAL cSubGroupExp   := SPACE(200)
   LOCAL nColCount      := 0        // Number of columns in report
   LOCAL nCount
   LOCAL nFrmHandle                 // (.frm) file handle
   LOCAL nBytesRead                 // Read/write and content record counter
   LOCAL nPointer       := 0        // Points to an offset into EXPR_BUFF string
   LOCAL nFileError                 // Contains current file error
   LOCAL cOptionByte                // Contains option byte

   LOCAL aReport[ RP_COUNT ]        // Create report array
   LOCAL err                        // error object

   LOCAL cDefPath          // contents of SET DEFAULT string
   LOCAL aPaths            // array of paths
   LOCAL nPathIndex := 0   // iteration counter

   LOCAL s, paths
   LOCAL i
	LOCAL aHeader				// temporary storage for report form headings
	LOCAL nHeaderIndex		// index into temporary header array

   // Initialize STATIC buffer values
   cLengthsBuff  := ""
   cOffsetsBuff  := ""
   cExprBuff     := ""

   // Default report values
   aReport[ RP_HEADER ]    := {}
   aReport[ RP_WIDTH ]     := 80
   aReport[ RP_LMARGIN ]   := 8
   aReport[ RP_RMARGIN ]   := 0
   aReport[ RP_LINES ]     := 58
   aReport[ RP_SPACING ]   := 1
   aReport[ RP_BEJECT ]    := .T.
   aReport[ RP_AEJECT ]    := .F.
   aReport[ RP_PLAIN ]     := .F.
   aReport[ RP_SUMMARY ]   := .F.
   aReport[ RP_COLUMNS ]   := {}
   aReport[ RP_GROUPS ]    := {}
   aReport[ RP_HEADING ]   := ""

   // Open the report file
   nFrmHandle := FOPEN( cFrmFile )

   IF ( !EMPTY( nFileError := FERROR() ) ) .AND. !( "\" $ cFrmFile .OR. ":" $ cFrmFile )

      // Search through default path; attempt to open report file
      cDefPath := SET( _SET_DEFAULT ) + ";" + SET( _SET_PATH )
      cDefPath := STRTRAN( cDefPath, ",", ";" )
      aPaths := ListAsArray( cDefPath, ";" )

      FOR nPathIndex := 1 TO LEN( aPaths )
         nFrmHandle := FOPEN( aPaths[ nPathIndex ] + "\" + cFrmFile )
         // if no error is reported, we have our report file
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
      err:filename := cFrmFile
      Eval(ErrorBlock(), err)
   ENDIF

   // OPEN ok?
   IF nFileError = F_OK

      // Go to START of report file
      FSEEK(nFrmHandle, 0)

      // SEEK ok?
      nFileError = FERROR()
      IF nFileError = F_OK

         // Read entire file into process buffer
         nBytesRead = FREAD(nFrmHandle, @cFileBuff, SIZE_FILE_BUFF)

         // READ ok?
         IF nBytesRead = 0
            nFileError = F_EMPTY        // file is empty
         ELSE
            nFileError = FERROR()       // check for DOS errors
         ENDIF

         IF nFileError = F_OK

            // Is this a .FRM type file (2 at start and end of file)
            IF BIN2W(SUBSTR(cFileBuff, 1, 2)) = 2 .AND.;
              BIN2W(SUBSTR(cFileBuff, SIZE_FILE_BUFF - 1, 2)) = 2

               nFileError = F_OK
            ELSE
               nFileError = F_ERROR
            ENDIF

         ENDIF

      ENDIF

      // Close file
      IF !FCLOSE(nFrmHandle)
         nFileError = FERROR()
      ENDIF

   ENDIF

// File existed, was opened and read ok and is a .FRM file
IF nFileError = F_OK

   // Fill processing buffers
   cLengthsBuff = SUBSTR(cFileBuff, LENGTHS_OFFSET, SIZE_LENGTHS_BUFF)
   cOffsetsBuff = SUBSTR(cFileBuff, OFFSETS_OFFSET, SIZE_OFFSETS_BUFF)
   cExprBuff    = SUBSTR(cFileBuff, EXPR_OFFSET, SIZE_EXPR_BUFF)
   cFieldsBuff  = SUBSTR(cFileBuff, FIELDS_OFFSET, SIZE_FIELDS_BUFF)
   cParamsBuff  = SUBSTR(cFileBuff, PARAMS_OFFSET, SIZE_PARAMS_BUFF)


   // Process report attributes
   // Report width
   aReport[ RP_WIDTH ]   := BIN2W(SUBSTR(cParamsBuff, PAGE_WIDTH_OFFSET, 2))

   // Lines per page
   aReport[ RP_LINES ]   := BIN2W(SUBSTR(cParamsBuff, LNS_PER_PAGE_OFFSET, 2))

   // Page offset (left margin)
   aReport[ RP_LMARGIN ] := BIN2W(SUBSTR(cParamsBuff, LEFT_MRGN_OFFSET, 2))

   // Page right margin (not used)
   aReport[ RP_RMARGIN ] := BIN2W(SUBSTR(cParamsBuff, RIGHT_MGRN_OFFSET, 2))

   nColCount  = BIN2W(SUBSTR(cParamsBuff, COL_COUNT_OFFSET, 2))

   // Line spacing
   // Spacing is 1, 2, or 3
   aReport[ RP_SPACING ] := IF( IsAffirm(SUBSTR(cParamsBuff, ;
	 DBL_SPACE_OFFSET, 1)) , 2, 1)

   // Summary report flag
   aReport[ RP_SUMMARY ] := IF( IsAffirm(SUBSTR(cParamsBuff, ;
    SUMMARY_RPT_OFFSET, 1)) , .T., .F.)

   // Process report eject and plain attributes option byte
   cOptionByte = ASC(SUBSTR(cParamsBuff, OPTION_OFFSET, 1))

   IF INT(cOptionByte / 4) = 1
      aReport[ RP_PLAIN ] := .T.          // Plain page
      cOptionByte -= 4
   ENDIF

   IF INT(cOptionByte / 2) = 1
      aReport[ RP_AEJECT ] := .T.         // Page eject after report
      cOptionByte -= 2
   ENDIF

   IF INT(cOptionByte / 1) = 1
      aReport[ RP_BEJECT ] := .F.         // Page eject before report
      cOptionByte -= 1
   ENDIF

   // Page heading, report title
   nPointer = BIN2W(SUBSTR(cParamsBuff, PAGE_HDR_OFFSET, 2))

	// Retrieve the header stored in the .FRM file
	nHeaderIndex := 4
   aHeader := ParseHeader( GetExpr( nPointer ), nHeaderIndex )

	// certain that we have retrieved all heading entries from the .FRM file, we
	// now retract the empty headings
	DO WHILE ( nHeaderIndex > 0 )
		IF ! EMPTY( aHeader[ nHeaderIndex ] )
			EXIT
		ENDIF
		nHeaderIndex--
	ENDDO

	aReport[ RP_HEADER ] := IIF( EMPTY( nHeaderIndex ) , {}, ;
		ASIZE( aHeader, nHeaderIndex ) )

   // Process Groups
   // Group
   nPointer = BIN2W(SUBSTR(cParamsBuff, GRP_EXPR_OFFSET, 2))

   IF !EMPTY(cGroupExp := GetExpr( nPointer ))

      // Add a new group array
      AADD( aReport[ RP_GROUPS ], ARRAY( RG_COUNT ))

      // Group expression
      aReport[ RP_GROUPS ][1][ RG_TEXT ] := cGroupExp
      aReport[ RP_GROUPS ][1][ RG_EXP ] := &( "{ || " + cGroupExp + "}" )
      IF USED()
         aReport[ RP_GROUPS ][1][ RG_TYPE ] := ;
                        VALTYPE( EVAL( aReport[ RP_GROUPS ][1][ RG_EXP ] ) )
      ENDIF

      // Group header
      nPointer = BIN2W(SUBSTR(cParamsBuff, GRP_HDR_OFFSET, 2))
      aReport[ RP_GROUPS ][1][ RG_HEADER ] := GetExpr( nPointer )

      // Page eject after group
      aReport[ RP_GROUPS ][1][ RG_AEJECT ] := IF(IsAffirm(SUBSTR(cParamsBuff, ;
      PE_OFFSET, 1)), .T., .F.)

   ENDIF

   // Subgroup
   nPointer = BIN2W(SUBSTR(cParamsBuff, SUB_EXPR_OFFSET, 2))

   IF !EMPTY(cSubGroupExp := GetExpr( nPointer ))

      // Add new group array
      AADD( aReport[ RP_GROUPS ], ARRAY( RG_COUNT ))

      // Subgroup expression
      aReport[ RP_GROUPS ][2][ RG_TEXT ] := cSubGroupExp
      aReport[ RP_GROUPS ][2][ RG_EXP ] := &( "{ || " + cSubGroupExp + "}" )
      IF USED()
         aReport[ RP_GROUPS ][2][ RG_TYPE ] := ;
                        VALTYPE( EVAL( aReport[ RP_GROUPS ][2][ RG_EXP ] ) )
      ENDIF

      // Subgroup header
      nPointer = BIN2W(SUBSTR(cParamsBuff, SUB_HDR_OFFSET, 2))
      aReport[ RP_GROUPS ][2][ RG_HEADER ] := GetExpr( nPointer )

      // Page eject after subgroup
      aReport[ RP_GROUPS ][2][ RG_AEJECT ] := .F.

   ENDIF

   // Process columns
   nFieldOffset := 12      // dBASE skips first 12 byte fields block.
   FOR nCount := 1 to nColCount

      AADD( aReport[ RP_COLUMNS ], GetColumn( cFieldsBuff, @nFieldOffset ) )

   NEXT nCount

ENDIF

RETURN aReport

/***
*
*  ParseHeader( <cHeaderString>, <nFields> ) --> aPageHeader
*
*	Parse report header (title) field from .FRM and populate page header
*	array. Processing is complicated somewhat by varying .FRM storage
*  formats of dBASE III+ and CA-Clipper. Although similar to ListAsArray(),
*	this function also accounts for fixed-length strings.
*
*/
FUNCTION ParseHeader( cHeaderString, nFields )
	LOCAL cItem
	LOCAL nItemCount := 0
	LOCAL aPageHeader := {}
   LOCAL nHeaderLen := 254
	LOCAL nPos

	DO WHILE ( ++nItemCount <= nFields )

		cItem := SUBSTR( cHeaderString, 1, nHeaderLen )

		// check for explicit delimiter
		nPos := AT( ";", cItem )

		IF ! EMPTY( nPos )
			// delimiter present
			AADD( aPageHeader, SUBSTR( cItem, 1, nPos - 1 ) )
		ELSE
			IF EMPTY( cItem )
				// empty string for S87 and 5.0 compatibility
				AADD( aPageHeader, "" )
			ELSE
				// exception
				AADD( aPageHeader, cItem )

			ENDIF
			// empty or not, we jump past the field
			nPos := nHeaderLen
		ENDIF

		cHeaderString := SUBSTR( cHeaderString, nPos + 1 )

	ENDDO

	RETURN( aPageHeader )

/***
*  GetExpr( nPointer ) --> cString
*
*  Reads an expression from EXPR_BUFF via the OFFSETS_BUFF and returns
*  a pointer to offset contained in OFFSETS_BUFF that in turn points
*  to an expression located in the EXPR_BUFF string.
*
*  Notes:
*
*     1. The expression is empty if:
*         a. Passed pointer is equal to 65535
*         b. Character following character pointed to by pointer is CHR(0)
*
*/
STATIC FUNCTION GetExpr( nPointer )
   LOCAL nExprOffset   := 0
   LOCAL nExprLength   := 0
   LOCAL nOffsetOffset := 0
   LOCAL cString := ""

   // Stuff for dBASE compatability.
   IF nPointer != 65535

      // Convert DOS FILE offset to CLIPPER string offset
      nPointer++

      // Calculate offset into OFFSETS_BUFF
      IF nPointer > 1
         nOffsetOffset = (nPointer * 2) - 1
      ENDIF

      nExprOffset = BIN2W(SUBSTR(cOffsetsBuff, nOffsetOffset, 2))
      nExprLength = BIN2W(SUBSTR(cLengthsBuff, nOffsetOffset, 2))

      // EXPR_OFFSET points to a NULL, so add one (+1) to get the string
      // and subtract one (-1) from EXPR_LENGTH for correct length

      nExprOffset++
      nExprLength--

      // Extract string
      cString = SUBSTR(cExprBuff, nExprOffset, nExprLength)

      // dBASE does this so we must do it too
      // Character following character pointed to by pointer is NULL
      IF CHR(0) == SUBSTR(cString, 1, 1) .AND. LEN(SUBSTR(cString,1,1)) = 1
         cString = ""
      ENDIF
   ENDIF

   RETURN (cString)


/***
*  GetColumn( <cFieldBuffer>, @<nOffset> ) --> aColumn
*
*  Get a COLUMN element from FIELDS_BUFF string using nOffset to point to
*  the current FIELDS_OFFSET block.
*
*  Notes:
*     1. The Header or Contents expressions are empty if:
*        a. Passed pointer is equal to 65535
*        b. Character following character pointed to by pointer is CHR(0)
*
*/
STATIC FUNCTION GetColumn( cFieldsBuffer, nOffset )
   LOCAL nPointer := 0, nNumber := 0, aColumn[ RC_COUNT ], cType

   // Column width
   aColumn[ RC_WIDTH ] := BIN2W(SUBSTR(cFieldsBuffer, nOffset + ;
		FIELD_WIDTH_OFFSET, 2))

   // Total column?
   aColumn[ RC_TOTAL ] := IF(IsAffirm(SUBSTR(cFieldsBuffer, nOffset + ;
    FIELD_TOTALS_OFFSET, 1)), .T., .F.)

   // Decimals width
   aColumn[ RC_DECIMALS ] := BIN2W(SUBSTR(cFieldsBuffer, nOffset + ;
		FIELD_DECIMALS_OFFSET, 2))

   // Offset (relative to FIELDS_OFFSET), 'point' to
   // expression area via array OFFSETS[]

   // Content expression
   nPointer = BIN2W(SUBSTR(cFieldsBuffer, nOffset +;
               FIELD_CONTENT_EXPR_OFFSET, 2))
   aColumn[ RC_TEXT ] := GetExpr( nPointer )
   aColumn[ RC_EXP ] := &( "{ || " + GetExpr( nPointer ) + "}" )

   // Header expression
   nPointer = BIN2W(SUBSTR(cFieldsBuffer, nOffset +;
               FIELD_HEADER_EXPR_OFFSET, 2))

   aColumn[ RC_HEADER ] := ListAsArray(GetExpr( nPointer ), ";")

   // Column picture
   // Setup picture only if a database file is open
   IF USED()
      cType := VALTYPE( EVAL(aColumn[ RC_EXP ]) )
      aColumn[ RC_TYPE ] := cType
      DO CASE
      CASE cType = "C" .OR. cType = "M"
         aColumn[ RC_PICT ] := REPLICATE("X", aColumn[ RC_WIDTH ])
      CASE cType = "D"
         aColumn[ RC_PICT ] := "@D"
      CASE cType = "N"
         IF aColumn[ RC_DECIMALS ] != 0
            aColumn[ RC_PICT ] := REPLICATE("9", aColumn[ RC_WIDTH ] - aColumn[ RC_DECIMALS ] -1) + "." + ;
                                  REPLICATE("9", aColumn[ RC_DECIMALS ])
         ELSE
            aColumn[ RC_PICT ] := REPLICATE("9", aColumn[ RC_WIDTH ])
         ENDIF
      CASE cType = "L"
         aColumn[ RC_PICT ] := "@L" + REPLICATE("X",aColumn[ RC_WIDTH ]-1)
      ENDCASE
   ENDIF

   // Update offset into ?_buffer
   nOffset += 12

   RETURN ( aColumn )

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