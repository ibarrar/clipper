/***
*
*  Fileio.prg
*
*  Sample user-defined functions to process binary files
*
*  Copyright (c) 1993, Computer Associates International Inc.
*  All rights reserved.
*
*  NOTE: Compile with /a /m /n /w
*/

#include "Common.ch"
#include "Fileio.ch"


/***
*
*  FGets( <nHandle>, [<nLines>], [<nLineLength>], [<cDelim>] ) --> cBuffer
*
*  Read one or more lines from a text file
*
*/
FUNCTION FGets( nHandle, nLines, nLineLength, cDelim )
   RETURN ( FReadLn( nHandle, nLines, nLineLength, cDelim ) )



/***
*
*  FPuts( <nHandle>, <cString>, [<nLength>], [<cDelim>] ) --> nBytes
*
*  Write a line to a text file
*
*/
FUNCTION FPuts( nHandle, cString, nLength, cDelim )
   RETURN ( FWriteLn( nHandle, cString, nLength, cDelim ) )



/***
*
*  DirEval( <cMask>, <bAction> ) --> aArray
*
*  Apply a code block to each file matching a skeleton
*
*/
FUNCTION DirEval( cMask, bAction )
   RETURN ( AEVAL( DIRECTORY( cMask ), bAction ) )



/***
*
*  FileTop( <nHandle> ) --> nPos
*
*  Position the file pointer to the first byte in a binary file and return
*  the new file position (i.e., 0).
*
*/
FUNCTION FileTop( nHandle )
   RETURN ( FSEEK( nHandle, 0 ) )



/***
*
*  FileBottom( <nHandle> ) --> nPos
*
*  Position the file pointer to the last byte in a binary file and return
*  the new file position
*
*/
FUNCTION FileBottom( nHandle )
   RETURN ( FSEEK( nHandle, 0, FS_END ) )



/***
*
*  FilePos( <nHandle> ) --> nPos
*
*  Report the current position of the file pointer in a binary file
*
*/
FUNCTION FilePos( nHandle )
   RETURN ( FSEEK( nHandle, 0, FS_RELATIVE ) )



/***
*
*  FileSize( <nHandle> ) --> nBytes
*
*  Return the size of a binary file
*
*/
FUNCTION FileSize( nHandle )
   
   LOCAL nCurrent
   LOCAL nLength

   // Get file position
   nCurrent := FilePos( nHandle )

   // Get file length
   nLength := FSEEK( nHandle, 0, FS_END )

   // Reset file position
   FSEEK( nHandle, nCurrent )

   RETURN ( nLength )



/***
*
*  FReadLn( <nHandle>, [<nLines>], [<nLineLength>], [<cDelim>] ) --> cLines
*
*  Read one or more lines from a text file
*
*  NOTES:
*     Line length includes delimiter, so max line read is 
*     (nLineLength - LEN( cDelim ))
*
*     Return value includes delimiters, if delimiter was read
*
*     nLines defaults to 1, nLineLength to 80 and cDelim to CRLF
*
*     FERROR() must be checked to see if FReadLn() was successful
*
*     FReadLn() returns "" when EOF is reached
*
*/
FUNCTION FReadLn( nHandle, nLines, nLineLength, cDelim )
   
   LOCAL nCurPos        // Current position in file
   LOCAL nFileSize      // The size of the file
   LOCAL nChrsToRead    // Number of character to read
   LOCAL nChrsRead      // Number of characters actually read
   LOCAL cBuffer        // File read buffer
   LOCAL cLines         // Return value, the lines read
   LOCAL nCount         // Counts number of lines read
   LOCAL nEOLPos        // Position of EOL in cBuffer

   DEFAULT nLines      TO 1
   DEFAULT nLineLength TO 80
   DEFAULT cDelim      TO ( CHR(13) + CHR(10) )

   nCurPos   := FilePos( nHandle )
   nFileSize := FileSize( nHandle )

   // Make sure no attempt is made to read past EOF
   nChrsToRead := MIN( nLineLength, nFileSize - nCurPos )

   cLines  := ''
   nCount  := 1
   DO WHILE (( nCount <= nLines ) .AND. ( nChrsToRead != 0 ))
      
      cBuffer   := SPACE( nChrsToRead )
      nChrsRead := FREAD( nHandle, @cBuffer, nChrsToRead )

      // Check for error condition
      IF !(nChrsRead == nChrsToRead)
         // Error!
         // In order to stay conceptually compatible with the other
         // low-level file functions, force the user to check FERROR()
         // (which was set by the FREAD() above) to discover this fact
         //
         nChrsToRead := 0
      ENDIF

      nEOLPos := AT( cDelim, cBuffer )

      // Update buffer and current file position
      IF ( nEOLPos == 0 )
         cLines  += LEFT( cBuffer, nChrsRead )
         nCurPos += nChrsRead
      ELSE
         cLines  += LEFT( cBuffer, ( nEOLPos + LEN( cDelim ) ) - 1 )
         nCurPos += ( nEOLPos + LEN( cDelim ) ) - 1
         FSEEK( nHandle, nCurPos, FS_SET )
      ENDIF

      // Make sure we don't try to read past EOF
      IF (( nFileSize - nCurPos ) < nLineLength )
         nChrsToRead := ( nFileSize - nCurPos )
      ENDIF

      nCount++

   ENDDO

   RETURN ( cLines )



/***
*
*  FileEval( <nHandle>, [<nLineLength>], [<cDelim>], ;
*            <bBlock>, 
*            [<bForCondition>], 
*            [<bWhileCondition>],
*            [<nNextLines>],
*            [<nLine>],
*            [<lRest>] )   --> NIL
*
*  Apply a code block to lines in a binary file using DBEVAL() as a model.
*  If the intent is to modify the file, the output must be written to a
*  temporary file and copied over the original when done.
*
*  NOTES:
*     <bBlock>, <bForCondition> and <bWhileCondition> are passed a
*     line of the file
*
*     The defaults for nLineLength and cDelim are the same as those
*     for FReadLn()
*
*     The default for the rest of the parameters is that same as for
*     DBEVAL().
*
*     Any past EOF requests (nLine > last line in file, etc.) are ignored
*     and no error is generated.  The file pointer will be left at EOF.
*
*     Check FERROR() to see if it was successful
*
*/
PROCEDURE FileEval( nHandle, nLineLength, cDelim, bBlock, bFor, bWhile, ;
                    nNextLines, nLine, lRest )

   LOCAL cLine          // Contains current line being acted on
   LOCAL lEOF := .F.    // EOF status
   LOCAL nPrevPos       // Previous file position

   DEFAULT bWhile TO {|| .T. }
   DEFAULT bFor   TO {|| .T. }

   // lRest == .T. means stay where I am.  Anything else means start from
   // the top of the file
   IF ! ( ( VALTYPE(lRest) == 'L' ) .AND. ( lRest == .T. ) )
      FileTop( nHandle )
   ENDIF

   BEGIN SEQUENCE
      
      IF nLine != NIL
         
         // Process only that one record
         nNextLines := 1

         FileTop( nHandle )

         IF nLine > 1
            cLine := FReadLn( nHandle, 1, nLineLength, cDelim )
            IF FERROR() != 0
               BREAK    // An error occurred, jump out of the SEQUENCE
            ENDIF

            // If cLine is a null string, we're at end of file
            lEOF := ( cLine == "" )
            nLine--
         ENDIF

         // Move to that record (nLine will equal 1 when we are there)
         DO WHILE ( ! lEOF  ) .AND. (nLine > 1)
            cLine := FReadLn( nHandle, 1, nLineLength, cDelim )
            IF FERROR() != 0
               BREAK          // NOTE: will break out of SEQUENCE
            ENDIF

            lEOF := ( cLine == "" )
            nLine--
         ENDDO

      ENDIF

      // Save starting position
      nPrevPos := FilePos( nHandle)

      // If there is more to read from here, get the first line for
      // comparison and potential processing 
      IF ( ! lEOF ) .AND. (nNextLines == NIL .OR. nNextLines > 0)
         cLine := FReadLn( nHandle, 1, nLineLength, cDelim )
         IF FERROR() != 0
            BREAK             // NOTE
         ENDIF

         lEOF := ( cLine == "" )
      ENDIF

      DO WHILE ( ! lEOF ) .AND. EVAL( bWhile, cLine )      ;
               .AND. (nNextLines == NIL .OR. nNextLines > 0)

         IF EVAL( bFor, cLine )
            EVAL( bBlock, cLine )
         ENDIF

         // Save start of line
         nPrevPos := FilePos( nHandle )

         // Read next line
         cLine    := FReadLn( nHandle, 1, nLineLength, cDelim )
         IF FERROR() != 0
            BREAK
         ENDIF

         lEOF := ( cLine == "" )

         IF nNextLines != NIL
            nNextLines--
         ENDIF

      ENDDO

      // If the reason for ending was that I ran past the WHILE or the number
      // of lines specified, back up to the beginning of the line that failed
      // so that there is no gap in processing
      //
      IF ( ! EVAL( bWhile, cLine ) ) .OR. ;
         ( (nNextLines != NIL) .AND. (nNextLines == 0) )

         FSEEK( nHandle, nPrevPos, FS_SET )

      ENDIF

   END SEQUENCE

   RETURN



/***
*
*  FEof( <nHandle> ) --> lBoundary
*
*  Determine if the current file pointer position is the last
*  byte in the file
*
*/
FUNCTION FEof( nHandle )
   RETURN ( IF( FileSize( nHandle ) == FilePos( nHandle ), .T., .F. ))



/***
*
*  FWriteLn( <nHandle>, <cString>, [<nLength>], [<cDelim>] ) --> nBytes
*
*  Write a line to a text file at the current file pointer position. 
*  
*  NOTES:
*     Check FERROR() for the error
*
*     nLength defaults to length of entire string + delim, cDelim
*     defaults to CHR(13) + CHR(10)
*
*     Return value includes length of delimiter
*
*/
FUNCTION FWriteLn( nHandle, cString, nLength, cDelim )

   IF cDelim == NIL
      cString += CHR(13) + CHR(10)
   ELSE
      cString += cDelim
   ENDIF

   RETURN ( FWRITE( nHandle, cString, nLength ) )
