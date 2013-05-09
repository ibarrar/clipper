/***
*   VMCOPY.C
*
*   Clipper callable function to test the Clipper VM API.  This function
*   opens a source file, reads the entire file (which could be several
*   megabytes) into VM, and then writes all the data back from VM to a new
*   file.  Of course this is NOT the most efficent way to copy a file
*   (especially if it is a big file and you don't have LOTS of EMM) but it
*   does illustrate how to use VM.  It is also useful for testing, or
*   "excercising" VM.  (wow, Scott really commented this program well)
*
*   Call from Clipper:
*      VMCopy( cInFile, cOutFile ) --> lSuccess
*
*         
*   HANDLE ReadFile( char * pInFile )      Reads an entire file into VM
*   HANDLE WriteFile( char * pOutFile )    Writes to new file from from VM
*
*   Compile: CL /c /AL /FPa /Gs /Oalt /Zl Vmcopy.c
*
*   Copyright (C) 1993, Computer Associates, Inc.  All Rights Reserved
*/

#include <extend.h>
#include "vmapi.h"
#include "vmcopy.h"
#include "gt.api"
#include <io.h>
#include <stdio.h>
#include <fcntl.h>
#include <string.h>
#include <sys\types.h>
#include <sys\stat.h>

#define MSGOUT( cmsg ) _gtWriteCon( cmsg, strlen(cmsg) );

#ifdef DEBUG
   #define ERROUT( cmsg ) MSGOUT( cmsg )
#else
   #define ERROUT( cmsg )
#endif

/* Function prototypes */
static HANDLE  AllocFileInfo( char * pInFile );
static Boolean FreeFileInfo( HANDLE hFileInfo );
static Boolean ReadFile(  char * pInFile,  HANDLE hFileInfo );
static Boolean WriteFile( char * pOutFile, HANDLE hFileInfo );



CLIPPER VMCOPY()
{
   HANDLE hFileInfo = 0;     // handle of VM segment that holds the file info
   Boolean fSuccess = FALSE; // flag to determine if the function succeeded 

   if (ISCHAR(1) & ISCHAR(2))
   {
      hFileInfo = AllocFileInfo(  _parc(1) );

      if (hFileInfo != 0)
      {
         if (fSuccess = ReadFile(  _parc(1), hFileInfo ))
         {
            ERROUT("OK(1)");
            if (fSuccess = WriteFile( _parc(2), hFileInfo ))
               ERROUT("OK(2)");
         }

         if (fSuccess = fSuccess & FreeFileInfo( hFileInfo ))
            ERROUT("OK(3)");
      }
   }
   _retl( fSuccess );
}



/***
*   ReadFile()
*
*   Reads the input file and stores the data in the VM segments created by
*   AllocFileInfo().  The read continues until all the segments (the number 
*   of which is stored in the file info structure) are processed.  If the
*   input file does not exist the function terminates and returns a (FALSE).  
*/

static Boolean ReadFile( char * pInFile, HANDLE hFileInfo )
{

   int hFile;                      // source file handle
   unsigned int uBytesRead;        // number of bytes read on each read()
   unsigned int uIndex;            // index into handle array 
   HANDLE * pHandles;              // pointer to array of segment handles       
   HANDLE hBuffer = 0;             // temp value for current segment handle 
   char * pBuffer;                 // pointer to current buffer segment  
   FILE_INFO * pFileInfo;          // pointer to handle array segment
   Boolean fSuccess = FALSE;       // flag to determine success


   hFile = open( pInFile, O_RDONLY | O_BINARY );

   if (hFile != -1)
   {
      /* lock file info segment  */
      pFileInfo = _xvlock( hFileInfo );     

      if (pFileInfo != NULL)
      {

         pHandles = &(pFileInfo->hOffset);        // pointer to handle array            
         fSuccess = TRUE;                         // errors will change flag

         MSGOUT("\r\nReading file");
         for ( uIndex = 0; uIndex < pFileInfo->uHandleCount; uIndex++ ) 
         {
            /* get the handle to the next segment */
            hBuffer = pHandles[ uIndex * sizeof( HANDLE ) ];

            /* get a pointer to the buffer by locking the segment */  
            pBuffer = _xvlock( hBuffer );

            if (pBuffer == NULL)            
            {
               ERROUT("Ooops!(1)");
               fSuccess = FALSE;            // read error, gotta bail
               break;
            }

            /* read the file into the buffer */
            uBytesRead = read( hFile, pBuffer, SEGMENT_SIZE );
            MSGOUT(".");

            _xvunlock( hBuffer );           // unlock the buffer segment 

            if (uBytesRead <= 0 )           
            {
               ERROUT("Ooops!(2)");
               fSuccess = FALSE;            // read error, gotta bail
               break;
            }
         }
         /* unlock the file info segment */
         _xvunlock( hFileInfo );
      }   
      close( hFile );
      MSGOUT("done.");
   }
   return (fSuccess);
}



/***
*   WriteFile()
*
*   Writes the data stored in the VM segments to the output file.  The write
*   continues until all the segments have been written.  If the output file 
*   does not exist it creates it.  If it does exist it opens it, truncates 
*   it to zero bytes, and writes the data to it. 
*/

static Boolean WriteFile( char * pOutFile, HANDLE hFileInfo )
{
   int hFile;                       // source file handle
   unsigned int uBytesToWrite;      // number of bytes to be written
   unsigned int uBytesWritten;      // number of bytes on written
   unsigned long ulBytesLeft;       // total bytes left to read from file   
   unsigned int uIndex = 0;         // index into handle array 
   HANDLE hBuffer;                  // temp value for current segment handle 
   FILE_INFO * pFileInfo;           // pointer to handle array segment
   char * pBuffer;                  // pointer to current buffer segment  
   HANDLE * pHandles;               // pointer to array of segment handles       
   Boolean fSuccess = TRUE;         // flag to determine success


   hFile = open( pOutFile, O_RDWR | O_CREAT | O_BINARY, S_IREAD | S_IWRITE );

   if (hFile != -1)                             // valid file handle? 
   {

      pFileInfo = _xvlock( hFileInfo );        // lock the file info segment 
      ulBytesLeft  = pFileInfo->ulFileSize;    // get bytes left to write

      pHandles = &(pFileInfo->hOffset);               

      MSGOUT("\r\nWriting file");

      for ( uIndex = 0; uIndex < pFileInfo->uHandleCount; uIndex++ ) 
      {
          /* get the handle to the next buffer segment */
          hBuffer = pHandles[ uIndex * sizeof( HANDLE ) ];         

          /* get buffer pointer by locking the segment */
          pBuffer = _xvlock( hBuffer );

          if (pBuffer == NULL) 
          {
             ERROUT("Ooops!(3)");
             fSuccess = FALSE;                // xvlock() failed, gotta bail
             break;
          }

          /* if bytes left are less that the segment size, only write the
             number of bytes left on the counter.  Otherwise write the  
             full segment */

          if (ulBytesLeft < SEGMENT_SIZE)
              uBytesToWrite =  (unsigned int) ulBytesLeft;

          else          
             uBytesToWrite =  SEGMENT_SIZE;
          
          uBytesWritten = write( hFile, pBuffer, uBytesToWrite );
          
          _xvunlock( hBuffer );                // unlock the buffer segment 

          MSGOUT(".");

          if (uBytesWritten != uBytesToWrite)
          {
             fSuccess = FALSE;                 // write failed, gotta bail
             ERROUT("Ooops!(4)");
             break;
          }
          
          /* decrease bytes left counter by the number of bytes written */
          ulBytesLeft -= (unsigned long) uBytesWritten;
      }
      /* unlock the file info segment */
      _xvunlock( hFileInfo );

      close( hFile );
      MSGOUT("done.\n");
   }
   return (fSuccess);
}


/***
*   AllocFileInfo()
*
*   Allocates a VM segment that contains a file info structure and an array 
*   of buffer segment handles.  The number of buffer segments required is 
*   calculated from the file length and the buffer size.  The buffer segments
*   are then allocated and their handles stored in the buffer handle array.
*   If successful a valid handle to the file info segment is returned.  
*   Otherwise a null handle is returned. 
*/

static HANDLE AllocFileInfo( char * pInFile )
{
   int hFile;                      // source file handle
   unsigned long ulFileSize;       // temp variable for file size
   unsigned int uIndex;            // index into handle array 
   unsigned int uHandleCount;      // temp value for handle count
   HANDLE hBuffer = 0;             // temp value for current segment handle 
   HANDLE hFileInfo = 0;           // file info segment handle
   FILE_INFO * pFileInfo;          // pointer to handle array segment
   HANDLE * pHandles;              // pointer to array of segment handles       
   Boolean fSuccess = FALSE;       // flag to determine success

   hFile = open( pInFile, O_RDONLY | O_BINARY );

   if (hFile != -1)
   {
      ulFileSize = lseek( hFile, 0L, SEEK_END ); // find the size of the file
      lseek( hFile, 0L, SEEK_SET );              // rewind to bof

      /* determine how many full segments will be required */
      uHandleCount = (unsigned int) (ulFileSize / (long) SEGMENT_SIZE);

      /* add one segment for the remainder of the data, if any */
      uHandleCount += ((ulFileSize % (long) SEGMENT_SIZE) ? 1 : 0);

      /* allocate a segment large enough to hold the file info structure 
         as well as the array of segment handles */
      hFileInfo = _xvalloc( sizeof( FILE_INFO ) + 
                          (uHandleCount * sizeof( HANDLE )), 0 );

      if (hFileInfo != 0)
      {
         /* get a pointer to the file info segment by locking it */
         pFileInfo = _xvlock( hFileInfo );

         if (pFileInfo != NULL)
         {
            fSuccess = TRUE;                   // errors will change flag

            /* store values to the file info structure */      
            pFileInfo->uHandleCount = uHandleCount;
            pFileInfo->ulFileSize   = ulFileSize;
      
            pHandles = &(pFileInfo->hOffset);               
    
            for ( uIndex = 0; uIndex < pFileInfo->uHandleCount; uIndex++ ) 
            {
               /* allocate a new segment */
               hBuffer = _xvalloc( SEGMENT_SIZE, 0 ); 

               if (hBuffer == 0)              // _xvalloc() failed, gotta bail
               {
                  fSuccess = FALSE; 
                  break;
               }

               /* store the buffer handle into the file info */
               pHandles[ uIndex * sizeof( HANDLE ) ] = hBuffer;         
            }   
         }
         _xvunlock( hFileInfo );

         if (! fSuccess)
         {

             if ( hFileInfo )
                FreeFileInfo( hFileInfo );

             hFileInfo = 0;               // null the handle (failure flag)
         }
      }
      close( hFile );
   }
   return (hFileInfo);
}


/***
*   FreeFileInfo()
*  
*   Frees each buffer segment using the buffer handle array, and then frees
*   the file info segment.
*   Returns TRUE successful, FALSE is an error occured.  
*/

static Boolean FreeFileInfo( HANDLE hFileInfo )
{
   unsigned int uIndex;              // index into handle array 
   HANDLE hBuffer = 0;               // temp value for current segment handle 
   FILE_INFO * pFileInfo;            // pointer to handle array segment
   HANDLE * pHandles;                // pointer to array of segment handles       
   Boolean fSuccess = FALSE;         // flag to determine success


   /* get a pointer to the file info segment by locking it */
   pFileInfo = _xvlock( hFileInfo );

   if (pFileInfo != NULL)
   {
      fSuccess = TRUE;                          // errors will change flag 

      pHandles = &(pFileInfo->hOffset);         // pointer to handle array      
      
      for ( uIndex = 0; uIndex < pFileInfo->uHandleCount; uIndex++ ) 
      {
         /* get the handle to the next segment */
         hBuffer = pHandles[ uIndex * sizeof( HANDLE ) ];         

         _xvfree( hBuffer );               // free the current buffer handle 
      }   
      
      _xvunlock( hFileInfo );              // unlock the file info segment   

      _xvfree( hFileInfo );                // free the file info segment

   }
   return (fSuccess);
}
