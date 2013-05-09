/***
*   FILEOPEN()
*
*   CA-Clipper-callable function that attempts to open a file
*   for reading and writing using FileOpener() and returns the
*   file handle.  The first parameter is the name of the file to
*   open and the second is a logical value indicating if the
*   file should be opened shared (default is false).  If the
*   filename is passed by reference it will be changed to the
*   fully qualified name of the file if the open is successful,
*   or the name that was attempted if unsuccessful.
*
*   Note: the subsystem code is set in this function since the
*   lower-level function FileOpener() is designed to be called
*   from many different routines.
*/

#include "extend.api"
#include "error.api"
#include "error.ch"
#include "filesys.api"


FHANDLE FileOpener( BYTEP fpFileName, USHORT uiFlags, ERRORP pError );


CLIPPER FILEOPEN()
{
   BYTEP fpFileName;
   FHANDLE hFile = FS_ERROR;
   USHORT uiFlags = FO_READWRITE;
   ERRORP pError;

   if ( ISCHAR( 1 ) )
   {
      fpFileName = _parc( 1 );

      uiFlags |= ( ISLOG( 2 ) && _parl( 2 ) ) ? FO_SHARED : FO_EXCLUSIVE;

      pError = _errNew();
      _errPutSubCode( pError, 1111 );     // subCode determined by caller

      hFile = FileOpener( fpFileName, uiFlags, pError );

      if ( ISBYREF( 1 ) )
         _storc( fpFileName, 1 );
   }

   _retni( hFile );

}


/***
*   FileOpener()
*
*   Attempts to open a file whose name is passed as an argument
*   along with the open mode flags and a pointer to an allocated
*   Error object.  A default extension of ".TXT" will be assumed
*   if the filename does not include an extension.
*
*   The function will generate an error if the open fails and
*   will continue to retry for as long as the Error Handler
*   returns E_RETRY.
*
*   The return value will be a valid file handle if successful,
*   otherwise FS_ERROR is returned.
*/

FHANDLE FileOpener( BYTEP fpFileName, USHORT uiFlags, ERRORP pError )
{
   FHANDLE hHandle;
   BOOL    retry;

   _errPutSeverity( pError, ES_ERROR );   // we determine the severity
   _errPutFlags( pError, EF_CANRETRY );   // and the allowable action
   _errPutGenCode( pError, EG_OPEN );     // open error
   _errPutFileName( pError, fpFileName )  // will be modified by _fsExtOpen()
                                          //   to the opened filename
   do
   {
      hHandle = _fsExtOpen( fpFileName, ".TXT", uiFlags, NULL, pError );

      retry = FALSE;

      if (hHandle == FS_ERROR)
      {
         retry = ( _errLaunch( pError) == E_RETRY );
      }

   } while (retry);

   fpFileName = _errGetFileName( pError );

   return (handle);
}
