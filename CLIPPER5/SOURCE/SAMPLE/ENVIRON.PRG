/***
*
*  Environ.prg
*
*  Sample procedures and user-defined functions for aiding Clipper
*  programs with environmental issues and global settings
*
*  Copyright (c) 1993, Computer Associates International Inc.
*  All rights reserved.
*
*  NOTE: compile with /a /m /n /w
*
*/


/***
*
*  FilePath( <cFile> ) --> cFilePath
*
*  Extract the full path name (without the filename or extension) from
*  a complete file specification
*
*  Example:
*     FilePath( "c:\clipper5\bin\clipper.exe" ) --> "c:\clipper5\bin\"
*
*/
FUNCTION FilePath( cFile )
   
   LOCAL nPos        // Marks the posistion of the last "\" in cFile, if any
   LOCAL cFilePath   // The extracted path for cFile, exluding the filename

   IF ( nPos := RAT( "\", cFile )) != 0
      cFilePath := SUBSTR( cFile, 1, nPos )
   ELSE
      cFilePath := ""
   ENDIF

   RETURN ( cFilePath )



/***
*
*  FileBase( <cFile> ) --> cFileBase
*
*  Extract the eight letter base name from a filename
*
*/
FUNCTION FileBase( cFile )
   
   LOCAL nPos           // Marks the position of the last "\", if any
   LOCAL cFileBase      // Return value containing the filename

   DO CASE
   CASE ( nPos := RAT( "\", cFile )) != 0
      
      // Strip out full path name leaving only the filename (with
      // extension)
      cFileBase := SUBSTR( cFile, nPos + 1 )

   CASE ( nPos := AT( ":", cFile )) != 0
      
      // Strip drive letter if cFile contains only drive letter
      // no subdirectories
      cFileBase := SUBSTR( cFile, nPos + 1 )

   OTHERWISE
      
      // Assume it's already taken care of
      cFileBase := cFile

   ENDCASE

   // Strip out the file extension, if any
   IF ( nPos := AT( ".", cFileBase )) != 0
      cFileBase := SUBSTR( cFileBase, 1, nPos - 1 )
   ENDIF

   RETURN ( cFileBase )



/***
*
*  FileExt( <cFile> ) --> cFileExt
*
*  Extract the three letter extension from a filename
*
*/
FUNCTION FileExt( cFile )
   
   LOCAL nPos        // Marks the position of the extension, if any
   LOCAL cFileExt    // Return value, the extension of cFile

   // Does the file extension exist?
   IF ( nPos := RAT( ".", cFile )) != 0
      cFileExt := SUBSTR( cFile, nPos + 1 )  // Extract it
   ELSE
      cFileExt := ""                         // None exists, return ""
   ENDIF

   RETURN ( cFileExt )



/***
*
*  FileDrive( <cFile> ) --> cFileDrive
*
*  Extract the drive designator from a file specification
*
*/
FUNCTION FileDrive( cFile )
   
   LOCAL nPos                 // Marks the position of ":", if any
   LOCAL cFileDrive := ""     // Return value, the drive letter
   
   // If ":" exists in cFile, extract the previous letter (drive letter)
   IF ( nPos := AT( ":", cFile )) != 0
      cFileDrive := SUBSTR( cFile, 1, nPos - 1 )
   ENDIF

   RETURN ( cFileDrive )



/***
*
*  FullPath( <cFile>, <lClipPath> ) --> cFullPath
*
*  Returns the full path of cFile; similar to the FoxPro FULLPATH() function
*
*/
FUNCTION FullPath( cFile, lDosPath )
   
   LOCAL cDefault    // Contains the default path for searching for files
   LOCAL cPath       // Return value

   // Retrieve Clipper's default directory for files (SET DEFAULT)
   cDefault := SET( _SET_DEFAULT )

   // Add cFile to the default directory
   cDefault += IF( RIGHT( RTRIM( cDefault ), 1 ) != "\", "\", "" ) + cFile

   IF FILE( cDefault )
      cPath := cDefault
   ELSE
      IF (( lDosPath == NIL ) .OR. ( !lDosPath ))
         
         // Search for cFile in Clipper's current SET PATH setting;
         // cPath will be set to NIL if not found
         cPath := GetPath( cFile, SET( _SET_PATH ) )

      ELSE
         
         // Search for cFile in the current DOS PATH setting;
         // cPath will be set to NIL if not found
         cPath := GetPath( cFile, GETENV( "PATH" ) )

      ENDIF
   ENDIF

   // Return the SET DEFAULT path if the file was not found elsewhere
   RETURN IF( cPath == NIL, cDefault, cPath )



/***
*
*  GetPath( <cFile>, <cPathSpec> ) --> cPath
*
*  Returns the location of a file if found in cPathSpec,
*  otherwise returns NIL
*
*  NOTE: Calls ListAsArray(), which is defined in String.prg
*
*/
FUNCTION GetPath( cFile, cPathSpec )
   
   LOCAL aPathList   // Contains an array of all the paths in cPathSpec   
   LOCAL bFilePath   // Code block that checks for the existence of a file
   LOCAL nPos        // The position in aPathList where cFile exists
   LOCAL xRet        // Return value, the path where found, or NIL

   // This block returns true if cFile can be found in cPath
   bFilePath := { |cPath| FILE( cPath +                                      ;
                          IF( RIGHT( RTRIM( cPath ), 1 ) != "\", "\", "" ) + ;
                          cFile )                                            ;
                }

   // Convert the list of paths as separate array elements
   aPathList := ListAsArray( STRTRAN( cPathSpec, ",", ";" ), ";" )

   IF ( nPos := ASCAN( aPathList, bFilePath )) != 0
      xRet := aPathList[nPos]
   ELSE
      xRet := NIL
   ENDIF

   RETURN ( xRet )



/***
*
*  SetAll( [<aNewSets>] ) --> aCurrentSets
*
*  Using an array of settings, change all global SETs and return their
*  original settings in an array.  If no argument is passed, simply 
*  return current settings.
*
*/
FUNCTION SetAll( aNewSets )
   
   LOCAL aCurrentSets[_SET_COUNT]      // Holds the current global SETs
   LOCAL n                             // Loop counter

   IF ( aNewSets != NIL )
      
      // Set new and return current
      FOR n := 1 TO _SET_COUNT
         aCurrentSets[n] := SET( n, aNewSets[n] )
      NEXT

   ELSE
   
      // Just return current
      FOR n := 1 TO _SET_COUNT
         aCurrentSets[n] := SET( n )
      NEXT

   ENDIF

   RETURN ( aCurrentSets )