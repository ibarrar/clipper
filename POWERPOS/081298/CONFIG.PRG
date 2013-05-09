#include "fileio.ch"
#include "config.ch"
#include "powerpos.ch"

function config(nVar,mValue)
static config_ := {}

  if nVar == START_MODE
  
     asize (config_, CONFIG_POS_LEN)
     afill (config_, "")  
     
     if !parse(CONFIG_POS_FILE,CONFIG_POS_LINES,config_)
        ?
        ? "Error Opening "
        ?? CONFIG_POS_FILE
        ?
        quit
     endif
     config_[POS_TERM_NUM] := padl(right(config_[POS_TERM_NUM],4),4,"0")
  else
     if mValue != NIL
        config_[nVar] := mValue
     endif 
  endif

return if(nVar > 0, config_[nVar], nil)
        
function parse(filename, aVectors_ , array_)
local f_handle
local buffer,cData
local i,nOffset,nLCtr:= 0
local lRetVal := .T.

  // first, open and read the POS configuration file...
  //
  f_handle := fopen(filename, FO_READ)

  // if handle OK, read through the file...
  //
  if f_handle > -1
  
     while .t.
     
        nLCtr++
        if ((buffer := freadln(f_handle,1,150)) == "") 
           exit
        endif
        
        // remove the delemeter CR+LF        
        buffer := subs(buffer,1,len(buffer)-2)
        
        nOffSet := 1

        // skip remarks and blank lines...
        while subs(buffer,nOffSet,1) == " " ; nOffSet++ ; enddo           
        if subs(buffer,nOffSet, 2) == "//" .or. nOffSet > len(buffer)
           loop
        endif

        if at("//",buffer) > 0
           buffer := subs(buffer,1,at("//",buffer)-1)
        endif   

        cData := UPPER(ALLTRIM(subs(buffer,nOffSet,at("=",buffer)-1)))
        
        if (( i := aScan(aVectors_, { |x| x == cData }) ) > 0)             
            // process read buffer to get the option...
            cData := ALLTRIM(subs(buffer, at("=", buffer)+1,len(buffer)))
            
            if array_[i] != ""
             ? aVectors_[i]+" redifinition: "+array_[i]+" to "+cData
            endif 

            if ("[" $ cData) .or. ("]" $ cData)
                cData := strtran(cData,"[")
                cData := strtran(cData,"]")
            else 
                cData := UPPER(cData)
            endif

            array_[i] := cData
            
#ifdef DEBUG
            ? array_[i]
#endif            
        else  
#ifdef DEBUG             
            ? "Parse error file: "+filename+" line:"+padl(nLCtr,4,)+' "'+rtrim(buffer)+'"'            
#endif                                    
            loop
        endif    
     enddo
  else 
    lRetVal := .F.   
  endif   
  fclose(f_handle)

return lRetVal

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

   nLines      := 1   
   cDelim      := ( CHR(13) + CHR(10) )

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



/*eof*/


