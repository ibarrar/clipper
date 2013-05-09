/***
*
*   Sdx.c
*
*   SDX driver implementation
*
*   Copyright (c) 1993, Computer Associates International, Inc.
*   All rights reserved.
*
*/

/*
*  Note: the following two (2) defines must be declares here as they 
*  are used to convert the definitions in some of the headers!
*  Failure to do define these here will cause these values to point
*  to the wrong structures and tables. 
*/

// AREAP must be re-defined to point to our expanded workarea structure
#define AREAP  struct _SDXAREA_ far * 

// SUPERTABLE must be re-defined to point to our SUPER class structure
#define SUPERTABLE ( &sdxSuper )


// Clipper API header files
#include "extend.api"
#include "fm.api"
#include "rdd.api"
#include "filesys.api"
#include "error.api"

// Clipper include header files
#include "error.ch"

// Microsoft C header files
#include "string.h"
#include "stdlib.h"
#include "ctype.h"
#include "dos.h"

#include "sdx.h"


/***
*  
*  Variables and function prototypes
*  
*/

DBFUNCTABLE  near sdxSuper = { NULL };
   
HIDE ERRCODE GenError( SDXAREAP area, ERRORP err );
HIDE void    MakeDefAlias( BYTEP source, BYTEP target );
HIDE BYTEP   MakeCopy( BYTEP source, BYTEP source2 );
HIDE ERRCODE FileOpen( SDXAREAP area, BYTEP filename, BYTEP defExt,
                       USHORT flags, FHANDLEP handle );
HIDE ERRCODE FileClose( SDXAREAP area, FHANDLE handle );
HIDE ERRCODE WriteSDXFile( SDXAREAP area );
HIDE ERRCODE GetDbInfo( SDXAREAP area );
HIDE BOOL    ProcessToken( SDXAREAP area, BYTEP token, USHORT start );
HIDE BOOL    ProcessInfo( SDXAREAP area, USHORT start );
HIDE BOOL    ProcessFields( SDXAREAP area, USHORT start );
HIDE USHORT  FindBOD( FHANDLE handle, BYTEPP token );
HIDE USHORT  GetFilePos( FHANDLE handle );
HIDE void    PutChar( FHANDLE handle );
HIDE BYTE    GetChar( FHANDLE handle );
HIDE BOOL    GetToken( FHANDLE handle, BYTEPP token );
HIDE BOOL    ReadToNextWord( FHANDLE handle );
HIDE BOOL    ReadToNextToken( FHANDLE handle );
HIDE BOOL    ReadToNextLine( FHANDLE handle );
HIDE BOOL    GetWord( FHANDLE handle, BYTEPP word );
HIDE BOOL    GetNumber( FHANDLE handle, BYTEPP word );
HIDE BOOL    GetFileName( FHANDLE handle, BYTEPP word );
HIDE void    SkipWhiteSpace( FHANDLE handle );
HIDE BOOL    FileReadBuff( SDXAREAP area );
HIDE void    DoubleToStr( XDOUBLE dval, USHORT len, USHORT dec, BYTEP dest );



/*
*  
*  sdxSysName
*
*/

ERRCODE sdxSysName( SDXAREAP ThisDb, BYTEP buff )

{
   ThisDb;     /* Avoid compiler warnings */
   strcpy( buff, "SDX" );
   return ( E_SUCCESS );
}



/*
*  
*  sdxStructSize()
*  Tells the system how much memory to allocate for our workarea
*  structure.
*
*  Warning: failure to implement this prior to using the driver will
*  result in the system overwriting your extensions to the workarea
*  structure.
*
*/

ERRCODE sdxStructSize( SDXAREAP ThisDb, USHORTP StructSize )

{
   ThisDb;     /* Avoid compiler warning */
   *StructSize = sizeof( SDXAREA );
   return ( E_SUCCESS );
}


   
/*
*  
*  sdxNew()
*
*  Just calls the super class method.
*
*/

ERRCODE sdxNew( SDXAREAP ThisDb )

{
   return ( SUPERNEW( ThisDb ) );
}
   


/*
*  
*  sdxRelease()
*  
*/

ERRCODE sdxRelease( SDXAREAP ThisDb )

{
   // Deallocate our pointers
   if ( ThisDb->infoName )
      _xfree( ThisDb->infoName );

   if ( ThisDb->dbName )
      _xfree( ThisDb->dbName );

   if ( ThisDb->buff )
      _xfree( ThisDb->buff );

   if ( ThisDb->fieldOffsets )
      _xfree( ThisDb->fieldOffsets );

   return ( SUPERRELEASE( ThisDb ) );

}



/*
*  
*  sdxDeleted()
*  
*  NOTE: Since the SDX driver can't "toggle" deleted records on 
*  and off, it always returns FALSE!
*  
*/

ERRCODE sdxDeleted( SDXAREAP ThisDb, BOOLP isDeleted )

{
   ThisDb;                 /* Avoid compiler warnings */
   *isDeleted = FALSE;

   return ( E_SUCCESS );
}



/*
*  
*  sdxBof()
*  
*/

ERRCODE sdxBof( SDXAREAP ThisDb, BOOLP bof )

{
   *bof = ThisDb->bof;
   return ( E_SUCCESS );
}



/*
*  
*  sdxEof()
*  
*/

ERRCODE sdxEof( SDXAREAP ThisDb, BOOLP eof )

{
   *eof = ThisDb->eof;
   return ( E_SUCCESS );
}   



/*
*  
*  sdxRecCount()
*  
*/

ERRCODE sdxRecCount( SDXAREAP ThisDb, ULONGP recCount )

{
   *recCount = ThisDb->recCount;
   return ( E_SUCCESS );
}   



/*
*  
*  sdxRecNo()
*  
*/

ERRCODE sdxRecNo( SDXAREAP ThisDb, ITEM row )

{
   if ( _itemType( row ) == NUMERIC )
   {
      _itemPutNL( row, ThisDb->recNo );
      return ( E_SUCCESS );
   }
   else
   {
      return ( E_BREAK );
   }   
}   



/*
*
*  sdxClose()
*
*  Update the header, clean up, and go home.
*
*/

ERRCODE sdxClose( SDXAREAP ThisDb )

{
   ERRCODE errCode;
   USHORT  flags = FXO_TRUNCATE | FXO_DEFAULTS | FO_READWRITE | FO_EXCLUSIVE;

   SELFGOCOLD( ThisDb );

   // Close the files
   if ( errCode = FileClose( ThisDb, ThisDb->dbHandle ) )
   {
      return ( errCode );              /* NOTE */
   }

   if ( errCode = FileClose( ThisDb, ThisDb->infoHandle ) )
   {
      return ( errCode );              /* NOTE */
   }

   // Rewrite the .SDX file (update its information)
   if ( errCode = FileOpen( ThisDb, ThisDb->infoName, ".SDX", flags,
                            &ThisDb->infoHandle ) )
   {
      return ( errCode );              /* NOTE */
   }
   else
   {
      /* WARNING: No error checking */
      WriteSDXFile( ThisDb );
      FileClose( ThisDb, ThisDb->infoHandle );
   }      

   return ( SUPERCLOSE( ThisDb ) );
}



/*
*
*  sdxOpen()
*
*  Physically open the file and call SUPEROPEN method and allow
*  it to do the rest.  Also remember to position the record pointer
*  to the top.  (That is the expected behavior.)
*
*/

ERRCODE sdxOpen( SDXAREAP ThisDb, DBOPENINFOP OpenInfo )

{
   BYTE    defAlias[ MAXLEN_IDENTIFIER + 1 ];
   USHORT  flags = FXO_DEFAULTS | FO_PRIVATE | FO_EXCLUSIVE | FO_READWRITE;
   ERRCODE err;

   // Create default alias if necessary
   if ( OpenInfo->alias == NULL )
   {
      MakeDefAlias( OpenInfo->name, defAlias );
      OpenInfo->alias = defAlias;
   }

   ThisDb->shared   = OpenInfo->shared;
   ThisDb->readonly = OpenInfo->readonly;

   // Open the database info (.SDX) file (header info)
   ThisDb->infoName = MakeCopy( OpenInfo->name, NULL );

   err = FileOpen( ThisDb, ThisDb->infoName, ".SDX", flags, 
                   &ThisDb->infoHandle );

   // Read the database's info (header info)
   if ( err == E_SUCCESS )
   {
      err = GetDbInfo( ThisDb );
   }

   // Open the database (.SDF) file
   if ( err == E_SUCCESS )
   {
      err = FileOpen( ThisDb, ThisDb->dbName, ".SDF", flags, 
                      &ThisDb->dbHandle );
   }

   // If successful perform the SUPEROPEN
   if ( err == E_SUCCESS )
   {
      err = SUPEROPEN( ThisDb, OpenInfo );
   }

   // If an error occurs close the file and return the error code
   if ( err != E_SUCCESS )
   {
      SELFCLOSE( ThisDb );
      return ( err );         /* NOTE */
   }

   ThisDb->buff        = (BYTEP) _xgrab( (USHORT) ThisDb->recSize );
   ThisDb->buffIsValid = FALSE;
   ThisDb->buffIsHot   = FALSE;

   return ( SELFGOTOP( ThisDb ) );
}



/*
*  
*  sdxCreate()
*  
*/

ERRCODE sdxCreate( SDXAREAP ThisDb, DBOPENINFOP OpenInfo )

{
   USHORT  counter;
   USHORT  counterSum = 0;
   BYTE    defAlias[ MAXLEN_IDENTIFIER + 1 ];
   USHORT  flags = FXO_TRUNCATE | FXO_DEFAULTS | FO_PRIVATE | FO_READWRITE |
                   FO_EXCLUSIVE;
   ERRCODE errCode;

   if (( errCode = SUPERCREATE( ThisDb, OpenInfo )) != E_SUCCESS )
   {
      return ( errCode );        /* NOTE */
   }

   // Create default alias if necessary
   if ( OpenInfo->alias == NULL )
   {
      MakeDefAlias( OpenInfo->name, defAlias );
      OpenInfo->alias = defAlias;
   }

   ThisDb->infoName = MakeCopy( OpenInfo->name, ".SDX" );

   // Create the database header (.SDX) file using the normal attribute
   if ( errCode = FileOpen( ThisDb, ThisDb->infoName, ".SDX", flags,
                            &ThisDb->infoHandle ) )
   {
      return ( errCode );           /* NOTE */
   }

   ThisDb->dbName = MakeCopy( OpenInfo->name, ".SDF" );

   // Now try the database (.SDF) file
   // NOTE: All .SDF files use same name as the .SDX file
   if ( errCode = FileOpen( ThisDb, ThisDb->dbName, ".SDF", flags, 
                            &ThisDb->dbHandle ) )
   {
      return ( errCode );           /* NOTE */
   }

   // Write the header info in the .SDX file
   if ( errCode = WriteSDXFile( ThisDb ) )
   {
      SELFCLOSE( ThisDb );
      return ( errCode );         /* NOTE! */
   }

   ThisDb->buff        = (BYTEP) _xgrab( (USHORT) ThisDb->recSize );
   ThisDb->buffIsValid = FALSE;
   ThisDb->buffIsHot   = FALSE;


   // Setup field info (offsets of each field in the record buffer)
   ThisDb->fieldOffsets = 
                 (USHORTP) _xgrab( ThisDb->fieldCount * sizeof( USHORT ) );

   // First field is always starts at zero (0) offset
   ThisDb->fieldOffsets[0] = 0;

   for ( counter = 1; counter < ThisDb->fieldCount; counter++ )
   {
      counterSum += ThisDb->fields[ counter - 1 ].len;
      ThisDb->fieldOffsets[ counter ] = counterSum;
   }



   return ( SELFGOTOP( ThisDb ) );
}



/*
*  
*  sdxGotoId()
*
*  Note: we must check the type of the record ITEM since non-numeric
*  record identifiers can be passed in Clipper 5.2!  If we are passed
*  a record identifier that is not a number, we generate a "data type"
*  error. 
*/

ERRCODE sdxGotoId( SDXAREAP ThisDb, ITEM record )

{
   ERRORP  err;
   ERRCODE errCode = E_BREAK;

   if ( _itemType( record ) == NUMERIC )
   {
      return ( SELFGOTO( ThisDb, _itemGetNL( record )));    /* NOTE */
   }
   else
   {
      SELFGOCOLD( ThisDb );
      if ( err = _errNew() )
      {
         _errPutGenCode( err, EG_DATATYPE );
         _errPutSubCode( err, ESDX_DATATYPE );
         errCode = GenError( ThisDb, err );
         _errRelease( err );
      }

      return ( errCode );      /* NOTE */
   }   
}



/*
*  
*  sdxGo()
*  
*/

ERRCODE sdxGo( SDXAREAP ThisDb, ULONG recno )

{
   SELFGOCOLD( ThisDb );
   ThisDb->buffIsValid = FALSE;

   if ( recno >= 1L && recno <= ThisDb->recCount )
   {
      // Valid record
      ThisDb->recNo = recno;
      ThisDb->bof   = FALSE;
      ThisDb->eof   = FALSE;
   }
   else if ( recno == 0L )
   {
      // Move to BOF
      ThisDb->recNo = 1L;
      ThisDb->bof   = TRUE;
      ThisDb->eof   = FALSE;
   }
   else if ( recno > ThisDb->recCount )
   {
      // Move to EOF
      ThisDb->recNo = ThisDb->recCount + 1;
      ThisDb->bof   = FALSE;
      ThisDb->eof   = TRUE;

      // Phantom record is always blank
      memset( ThisDb->buff, SPACE, (USHORT) ThisDb->recSize );
      ThisDb->buffIsValid = TRUE;
   }

   return ( E_SUCCESS );
}



/*
*  
*  sdxGoTop()
*  
*/

ERRCODE sdxGoTop( SDXAREAP ThisDb )

{
   SELFGOTO( ThisDb, 1L );
   return ( E_SUCCESS );
}   



/*
*  
*  sdxGoBottom()
*  
*/

ERRCODE sdxGoBottom( SDXAREAP ThisDb )

{
   SELFGOTO( ThisDb, ThisDb->recCount );
   return ( E_SUCCESS );
}   



/*
*  
*  sdxGoCold()
*  
*/

ERRCODE sdxGoCold( SDXAREAP ThisDb )

{
   ULONG   filePos;
   ERRORP  err;
   ERRCODE errCode = E_BREAK;

   if ( ThisDb->buffIsHot )
   {
      // Position the file pointer
      filePos = ( ThisDb->recNo - 1L ) * ( ThisDb->recSize + 2L );
      _fsSeek( ThisDb->dbHandle, filePos, FS_SET );
      
      // Write the record to disk
      if ( _fsWrite( ThisDb->dbHandle, ThisDb->buff, 
                    (USHORT) ThisDb->recSize ) != (USHORT) ThisDb->recSize )
      {
         if ( err = _errNew() )
         {
            _errPutOsCode( err, _fsError() );
            _errPutGenCode( err, EG_WRITE );
            _errPutSubCode( err, ESDX_WRITE );
            errCode = GenError( ThisDb, err );
            _errRelease( err );
         }

         return ( errCode );              /* NOTE */
      }

      ThisDb->buffIsHot   = FALSE;
      ThisDb->buffIsValid = TRUE;
   }

   return ( E_SUCCESS );

}



/*
*  
*  sdxGoHot()
*  
*/

ERRCODE sdxGoHot( SDXAREAP ThisDb )

{
   ThisDb->buffIsHot   = TRUE;
   ThisDb->buffIsValid = TRUE;
   return ( E_SUCCESS );
}



/*
*  
*  sdxGetValue()
*  
*/

ERRCODE sdxGetValue( SDXAREAP ThisDb, USHORT fieldNum, ITEM value )

{
   FIELD field;
   BYTEP buffPtr;

   if ( !FileReadBuff( ThisDb ) )
   {
      return ( E_BREAK );        /* NOTE */
   }

   field = ThisDb->fields[ fieldNum ];

   buffPtr = (BYTEP) _xgrab( field.len + 1 );
   buffPtr[ field.len ] = NIL;
   strncpy( buffPtr, 
            &ThisDb->buff[ ThisDb->fieldOffsets[ fieldNum ] ], field.len );

   switch ( _rddExtendType( field.type ) )
   {
      case CHARACTER:
         _itemPutCL( value, buffPtr, field.len );
         break;

      case DOUBLE:
         _itemPutND( value, atof( buffPtr ) );
         break;

      case NUMERIC:
         _itemPutNL( value, atol( buffPtr ) );
         break;

      case LOGICAL:
         _itemPutL( value, ( *buffPtr == 'T' ? TRUE : FALSE ) );
         break;

      case DATE:
         _itemPutDS( value, buffPtr );
   }

   _xfree( buffPtr );
   return ( E_SUCCESS );
}



/*
*  
*  sdxPutValue()
*  
*/

ERRCODE sdxPutValue( SDXAREAP ThisDb, USHORT fieldNum, ITEM value )

{
   FIELD   field;
   USHORT  type;
   BYTEP   buffPtr;
   USHORT  buffLen;
   USHORT  errCode = 0;
   ERRORP  err;

   // Check if on phantom record
   if ( ThisDb->recNo == ThisDb->recCount + 1 )
   {
      return ( E_DEFAULT );      /* NOTE: No error */
   }
   
   // Prepare to write buffer
   if ( !ThisDb->buffIsHot )
   {
      SELFGOHOT( ThisDb );
   }

   // Get the current field
   field = ThisDb->fields[ fieldNum ];

   // Replace the buffer's value with the passed one
   switch ( _rddExtendType( field.type ) )
   {
      case CHARACTER:
         if ( _itemType( value ) == CHARACTER )
         {
            buffPtr = _itemGetC( value );
            buffLen = strlen( buffPtr );

            if ( buffLen > field.len )
            {
               errCode = ESDX_DATAWIDTH;
            }
            else
            {   
               memset( &ThisDb->buff[ ThisDb->fieldOffsets[ fieldNum ] ], 
                       SPACE, field.len );

               strncpy( &ThisDb->buff[ ThisDb->fieldOffsets[ fieldNum ] ], 
                        buffPtr, 
                        ( field.len > buffLen ? buffLen : field.len ));
            }

            _itemFreeC( buffPtr );
         }
         else
         {
            errCode = ESDX_DATATYPE;
         }   
         break;

      case DOUBLE:
         if ( _itemType( value ) | NUMERIC )
         {
            buffPtr = (BYTEP) _xgrab( field.len + 1 );
            DoubleToStr( _itemGetND( value ), field.len, field.dec, 
                         buffPtr );

            if ( *buffPtr == '*' )
            {
               errCode = ESDX_DATAWIDTH;
            }
            else
            {
               memset( &ThisDb->buff[ ThisDb->fieldOffsets[ fieldNum ] ],
                       SPACE, field.len );

               strncpy( &ThisDb->buff[ ThisDb->fieldOffsets[ fieldNum ] ],
                        buffPtr, field.len );
            }

            _xfree( buffPtr );
         }
         else
         {
            errCode = ESDX_DATATYPE;
         }   
         break;

      case NUMERIC:
         type = _itemType( value );
         if ( type | NUMERIC )
         {
            buffPtr = (BYTEP) _xgrab( MAX_WIDTH_LONG + 1 );

            if ( type | DOUBLE )
            {
               // Type is DOUBLE, convert it to LONG
               ltoa( (LONG) _itemGetND( value ), buffPtr, 10 );
            }
            else
            {
               // Type is LONG
               ltoa( _itemGetNL( value ), buffPtr, 10 );
            }
               
            buffLen = strlen( buffPtr );

            if ( buffLen > field.len )
            {
               errCode = ESDX_DATAWIDTH;
            }
            else
            {   
               memset( &ThisDb->buff[ ThisDb->fieldOffsets[ fieldNum ] ], 
                       SPACE, field.len );

               strncpy( &ThisDb->buff[ ThisDb->fieldOffsets[ fieldNum ] +
                        ( field.len - buffLen ) ], buffPtr, buffLen );
            }

            _xfree( buffPtr );
         }
         else
         {
            errCode = ESDX_DATATYPE;
         }   
         break;

      case LOGICAL:
         if ( _itemType( value ) == LOGICAL )
         {
            ThisDb->buff[ ThisDb->fieldOffsets[ fieldNum ] ] = 
                          (BYTE) ( _itemGetL( value ) ? 'T' : 'F' );
         }
         else
         {
            errCode = ESDX_DATATYPE;
         }   
         break;

      case DATE:
         if ( _itemType( value ) == DATE )
         {
            buffPtr = _xgrab( 8 );
            strncpy( &ThisDb->buff[ ThisDb->fieldOffsets[ fieldNum ] ],
                     _itemGetDS( value, buffPtr ), 8 );

            _xfree( buffPtr );
         }
         else
         {
            errCode = ESDX_DATATYPE;
         }   
   }

   if ( errCode )
   {
      if ( err = _errNew() )
      {
         _errPutSubCode( err, errCode );
         _errPutGenCode( err, ( errCode = ESDX_DATATYPE ? EG_DATATYPE : 
                                                          EG_DATAWIDTH ) );
         errCode = GenError( ThisDb, err );
         _errRelease( err );
      }

      return ( errCode );        /* NOTE */
   }   

   return ( E_SUCCESS );
}



/*
*
*  sdxAppend()
*
*/

ERRCODE sdxAppend( SDXAREAP ThisDb, BOOL releaseLocks )

{
   ERRCODE errCode = 0;
   ERRORP  err;

   releaseLocks;        /* Avoid compiler warnings */

   if ( errCode = SELFGOCOLD( ThisDb ) )
   {
      return ( errCode );                 /* NOTE */
   }

   if ( !ThisDb->readonly )
   {
      memset( ThisDb->buff, SPACE, (USHORT) ThisDb->recSize );
      _fsSeek( ThisDb->dbHandle, 0L, FS_END );

      if ( _fsWrite( ThisDb->dbHandle, ThisDb->buff, 
                     (USHORT) ThisDb->recSize ) != (USHORT) ThisDb->recSize )
      {
         errCode = E_BREAK;      // $JPF Ugh! In case _errNew fails...
         if ( err = _errNew() )
         {
            _errPutGenCode( err, EG_WRITE );
            _errPutSubCode( err, ESDX_WRITE );
            errCode = GenError( ThisDb, err );
            _errRelease( err );
         }

         return ( errCode );     /* NOTE */
      }

      if ( _fsWrite( ThisDb->dbHandle, SDX_REC_DELIM, 2 ) != 2 )
      {
         errCode = E_BREAK;
         if ( err = _errNew() )
         {
            _errPutGenCode( err, EG_WRITE );
            _errPutSubCode( err, ESDX_WRITE );
            errCode = GenError( ThisDb, err );
            _errRelease( err );
         }

         return ( errCode );     /* NOTE */
      }

      ThisDb->recCount++;
      ThisDb->recNo       = ThisDb->recCount;
      ThisDb->buffIsHot   = FALSE;
      ThisDb->buffIsValid = TRUE;
      ThisDb->bof         = FALSE;
      ThisDb->eof         = FALSE;
   }
   else
   {
      errCode = E_BREAK;
      if ( err = _errNew() )
      {
         _errPutGenCode( err, EG_READONLY );
         _errPutSubCode( err, ESDX_READONLY );
         errCode = GenError( ThisDb, err );
         _errRelease( err );
      }

      return ( errCode );        /* NOTE */
   }

   return ( errCode );
}



/*
*  
*  sdxSkipRaw()
*  
*/

ERRCODE sdxSkipRaw( SDXAREAP ThisDb, LONG toSkip )

{
   return ( SELFGOTO( ThisDb, ThisDb->recNo + toSkip ) );
}



/***
*  
*           Local service routines
*  
*/

/*
*  
*  GenError()
*  
*  Generic error generator for SDX subsystem
*  
*/

HIDE ERRCODE GenError( SDXAREAP ThisDb, ERRORP error )

{
   ERRCODE errCode;

   _errPutSeverity( error, ES_ERROR );
   errCode = SELFERROR( ThisDb, error );

   return ( errCode );
}



/*
*  
*  MakeDefAlias()
*  
*/

HIDE void MakeDefAlias( BYTEP source, BYTEP target )

{
   BYTEP  sourceMarker;
   BYTEP  targetMarker;

   // Start copying from after the last backslash if any
   if (( sourceMarker = strrchr( source, '\\' )) == NULL )     /* MSC RT */
   {
      sourceMarker = source;
   }
   else
   {
      sourceMarker++;
   }   
   targetMarker = target;

   // Copy the string as long we don't hit an extension
   while (( *sourceMarker != '.' ) && ( *sourceMarker != NIL ))
   {
      *targetMarker++ = *sourceMarker++;
   }
   *targetMarker = NIL;

}



/*
*
*  MakeCopy()
*  
*  Allocates 'copy' and copies 'source1' and 'source2' (if present)
*  into itself
*  
*  NOTE: Assumes 'source1' is NULL terminated string and 'source2' is
*        either a NULL terminated string or a NULL pointer
*
*/

HIDE BYTEP MakeCopy( BYTEP source1, BYTEP source2 )

{
   BYTEP  copy;
   BYTEP  marker;
   USHORT len;

   if ( source2 )
   {
      len    = strlen( source1 );
      copy   = (BYTEP) _xgrab( len + strlen( source2 ) + 1 );
      marker = copy + len;
      strcpy( copy, source1 );
      strcpy( marker, source2 );
   }
   else
   {
      copy = (BYTEP) _xgrab( strlen( source1 ) + 1 );
      strcpy( copy, source1 );
   }
      
   return ( copy );

}



/*
*  
*  FileOpen()
*  
*  File opener that handles open mode and error handling
*  
*/

HIDE ERRCODE FileOpen( SDXAREAP ThisDb, BYTEP filename, BYTEP extension, 
                       USHORT flags, FHANDLEP handlePtr )

{
   BYTE    fileName[MAXLEN_DOSFILE];
   BOOL    retry;
   ERRCODE errCode;
   ERRORP  err;

   // Only exclusive, read/write mode is currently supported
   if ( ThisDb->shared || ThisDb->readonly )
   {
      errCode = E_BREAK;
      if ( err = _errNew() )
      {
         _errPutGenCode( err, EG_OPEN );
         _errPutSubCode( err, ThisDb->shared ? ESDX_SHARED : ESDX_READONLY );
         errCode = GenError( ThisDb, err );
         _errRelease( err );
      }

      return ( errCode );                 /* NOTE */
   }

   // Create an error object for use by _fsExtOpen
   err = _errNew();
   _errPutFileName( err, fileName );

   do
   {
      // Attempt to open the file (with retry capability )
      *handlePtr = _fsExtOpen( filename, extension, flags, NULL, err );

      if ( errCode = _fsError() )
      {
         _errPutOsCode( err, errCode );
         _errPutFlags( err, EF_CANRETRY );
         _errPutSubCode( err, ESDX_OPEN );
         errCode = GenError( ThisDb, err );
         retry = ( errCode == E_RETRY );
      }
      else
      {
         retry = FALSE;
      }

   } while ( retry );

   // Release the error object
   _errRelease( err );

   return ( errCode );

}



/*
*  
*  FileClose()
*  
*/

HIDE ERRCODE FileClose( SDXAREAP ThisDb, FHANDLE handle )

{
   ERRCODE errCode = 0;
   ERRORP  err;

   if ( handle && handle != FS_ERROR )
   {
      _fsClose( handle );

      if (( errCode = _fsError() ) != 0 )
      {
         errCode = E_BREAK;
         if ( err = _errNew() )
         {
            _errPutOsCode( err, errCode );
            _errPutGenCode( err, EG_CLOSE );
            _errPutSubCode( err, ESDX_CLOSE );
            errCode = GenError( ThisDb, err );
            _errRelease( err );
         }
      }
   }

   return ( errCode );
}



/*
*
*  WriteSDXFile()
*
*/

HIDE ERRCODE WriteSDXFile( SDXAREAP ThisDb )

{
   BYTE    name[ MAXLEN_IDENTIFIER + 1 ];
   BYTE    byte;
   BYTE    str[ 18 ];
   LONG    size = 0;
   USHORT  i;
   ERRCODE errCode;
   ERRORP  err;

   // Calculate record size if creating a new .SDF file
   if ( !ThisDb->recSize )
   {
      for ( i = 0; i < ThisDb->fieldCount; i++ )
      {
         size += ThisDb->fields[i].len;
      }
      ThisDb->recSize = size;
   }

   /*
   *
   *  Write database file info
   *
   */
   _fsWrite( ThisDb->infoHandle, "[info]\r\nfile=", 13 );
   _fsWrite( ThisDb->infoHandle, ThisDb->dbName, strlen( ThisDb->dbName ) );

   _fsWrite( ThisDb->infoHandle, "\r\nfieldcount=", 13 );
   ultoa( (LONG) ThisDb->fieldCount, str, 10 );                /* MSC RT */
   _fsWrite( ThisDb->infoHandle, str, strlen( str ) );

   _fsWrite( ThisDb->infoHandle, "\r\nrecsize=", 10 );
   ultoa( ThisDb->recSize, str, 10 );
   _fsWrite( ThisDb->infoHandle, str, strlen( str ) );

   _fsWrite( ThisDb->infoHandle, "\r\nreccount=", 11 );
   ultoa( ThisDb->recCount, str, 10 );
   _fsWrite( ThisDb->infoHandle, str, strlen( str ) );

   /*
   *  
   *  Write field structure info
   *  
   */
   _fsWrite( ThisDb->infoHandle, "\r\n\r\n[fields]", 12 );
   for ( i = 0; i < ThisDb->fieldCount; i++ )
   {
      SELFFIELDNAME( ThisDb, i + 1, name );

      _fsWrite( ThisDb->infoHandle, "\r\n", 2 );
      _fsWrite( ThisDb->infoHandle, name, strlen( name ) );
      _fsWrite( ThisDb->infoHandle, "=", 1 );

      switch ( _rddExtendType( ThisDb->fields[i].type ) )
      {
         case CHARACTER:
            byte = 'C';
            break;

         case NUMERIC:
         case DOUBLE:
            byte = 'N';
            break;

         case LOGICAL:
            byte = 'L';
            break;

         case DATE:
            byte = 'D';
            break;

         default:
            byte = UNDEF;
            break;
      }

      if ( byte == UNDEF )
      {
         errCode = E_BREAK;
         if ( err = _errNew() )
         {
            _errPutGenCode( err, EG_DATATYPE );
            _errPutSubCode( err, ESDX_DATATYPE );
            errCode = GenError( ThisDb, err );
            _errRelease( err );
         }

         return ( errCode );              /* NOTE */
      }

      _fsWrite( ThisDb->infoHandle, &byte, 1 );

      // Write out the field length
      byte = ',';
      _fsWrite( ThisDb->infoHandle, &byte, 1 );
      ultoa( (LONG) ThisDb->fields[i].len, str, 10 );         /* MSC RT */
      _fsWrite( ThisDb->infoHandle, str, strlen( str ) );

      // Write out the decimals value if decimals exists
      if (( ThisDb->fields[i].type == _rddFieldType( DOUBLE )) &&
                                      ThisDb->fields[i].dec )
      {
         _fsWrite( ThisDb->infoHandle, &byte, 1 );
         ultoa( (LONG) ThisDb->fields[i].dec, str, 10 );      /* MSC RT */
         _fsWrite( ThisDb->infoHandle, str, strlen( str ) );
      }   

   }

   if ( errCode = _fsError() )
   {
      if ( err = _errNew() )
      {
         _errPutOsCode( err, errCode );
         _errPutGenCode( err, EG_WRITE );
         _errPutSubCode( err, ESDX_WRITE );
         errCode = GenError( ThisDb, err );
         _errRelease( err );
      }
   }   

   return ( errCode );

}



/*
*  
*  GetDbInfo()
*  
*/

HIDE ERRCODE GetDbInfo( SDXAREAP ThisDb )

{
   USHORT  counter;           /* Counter for establishing offsets   */
   USHORT  counterSum;        /* Sum of counters                    */
   USHORT  bod;               /* Beginning Of Data file offset      */
   USHORT  tokensToProcess;   /* Number of .SDX sections to process */
   BYTEP   token;             /* Current .SDX section               */
   ERRCODE errCode;           /* Return value of error              */
   ERRORP  err;               /* Error object                       */

   tokensToProcess = MAX_SDX_TOKENS;

   while ( tokensToProcess )
   {
      if ( bod = FindBOD( ThisDb->infoHandle, &token ))
      {
         if ( !ProcessToken( ThisDb, strupr( token ), bod ) )
         {
            _xfree( token );
            break;   /* NOTE */
         }
         _xfree( token );
         tokensToProcess--;
      }
      else
      {
         break;      /* NOTE */         
      }
   }

   // Check to see if all tokens were processed
   if ( tokensToProcess )
   {
      errCode = E_BREAK;
      if ( err = _errNew() )
      {
         _errPutGenCode( err, EG_CORRUPTION );
         _errPutSubCode( err, ESDX_CORRUPT  );
         errCode = GenError( ThisDb, err );
         _errRelease( err );
      }

      return ( errCode );     /* NOTE */
   }

   // Calculate the field offsets in buff
   ThisDb->fieldOffsets = 
                 (USHORTP) _xgrab( ThisDb->fieldCount * sizeof( USHORT ) );

   // First field is always at the front!
   ThisDb->fieldOffsets[0] = 0;     
   counterSum = 0;
   for ( counter = 1; counter < ThisDb->fieldCount; counter++ )
   {
      counterSum += ThisDb->fields[ counter - 1 ].len;
      ThisDb->fieldOffsets[ counter ] = counterSum;
   }

   return ( E_SUCCESS );
}



/*
*  
*  ProcessToken()
*  
*/

HIDE BOOL ProcessToken( SDXAREAP ThisDb, BYTEP token, USHORT start )

{
   BOOL ok = FALSE;

   if ( strcmp( token, "INFO" ) == 0 )
      ok = ProcessInfo( ThisDb, start );

   else if ( strcmp( token, "FIELDS" ) == 0 )
      ok = ProcessFields( ThisDb, start );

   return ( ok );
}



/*
*  
*  ProcessInfo()
*  
*/

HIDE BOOL ProcessInfo( SDXAREAP ThisDb, USHORT start )

{
   USHORT  items = 4;            /* Number of options in [info] section */
   USHORT  numFields;
   BYTEP   word;
   FHANDLE file;

   // Check for duplicate definitions in file
   if ( ThisDb->recSize || ThisDb->fieldExtent || ThisDb->dbName )
   {
      return ( FALSE );    /* NOTE */
   }   

   file = ThisDb->infoHandle;

   // Position to beginning of [info]'s data
   _fsSeek( file, (LONG) start, FS_SET );
   ReadToNextWord( file );

   while ( items )
   {
      if ( GetWord( file, &word ) )
      {
         if ( strcmp( "FILE", strupr( word ) ) == 0 )
         {
            _xfree( word );
            SkipWhiteSpace( file );
            if ( GetChar( file ) != '=' )
            {
               return ( FALSE );         /* NOTE */
            }
            SkipWhiteSpace( file );
            if ( !GetFileName( file, &ThisDb->dbName ) )
            {
               return ( FALSE );         /* NOTE */
            }
         }   
         else if ( strcmp( "RECSIZE", strupr( word ) ) == 0 )
         {
            _xfree( word );
            SkipWhiteSpace( file );
            if ( GetChar( file ) != '=' )
            {
               return ( FALSE );         /* NOTE */
            }
            SkipWhiteSpace( file );
            if ( GetNumber( file, &word ) )
            {
               ThisDb->recSize = (ULONG) atol( word );
            }
         }
         else if ( strcmp( "FIELDCOUNT", strupr( word ) ) == 0 )
         {
            _xfree( word );
            SkipWhiteSpace( file );
            if ( GetChar( file ) != '=' )
            {
               return ( FALSE );         /* NOTE */
            }
            SkipWhiteSpace( file );
            if ( GetNumber( file, &word ) )
            {
               numFields = (USHORT) atoi( word );
            }
         }
         else if ( strcmp( "RECCOUNT", strupr( word ) ) == 0 )
         {
            _xfree( word );
            SkipWhiteSpace( file );
            if ( GetChar( file ) != '=' )
            {
               return ( FALSE );         /* NOTE */
            }
            SkipWhiteSpace( file );
            if ( GetNumber( file, &word ) )
            {
               ThisDb->recCount = (ULONG) atol( word );
            }
         }   
         else  /* if none match */
         {
            _xfree( word );
            return ( FALSE );            /* NOTE */
         }

         ReadToNextLine( file );
         items--;

      }
   }

   SELFSETFIELDEXTENT( ThisDb, numFields );
   return ( items == 0 );
}



/*
*  
*  ProcessFields()
*  
*/

HIDE BOOL ProcessFields( SDXAREAP ThisDb, USHORT start )

{
   DBFIELDINFO field;
   USHORT      numFields;
   BYTEP       word;
   FHANDLE     file;
   USHORT      i;

   // Check for duplicate definitions in file
   if ( ThisDb->fieldCount )
   {
      return ( FALSE );    /* NOTE */
   }

   file = ThisDb->infoHandle;
   numFields = ThisDb->fieldExtent;

   // Position to beginning of [fields]'s data
   _fsSeek( file, (LONG) start, FS_SET );
   ReadToNextWord( file );

   for ( i = 0; i < numFields; i++ )  /* CAUTION: no error checking */
   {
      /* Clear out the field */
      memset( &field, NIL, sizeof( field ) );

      /* Get the field name */
      GetWord( file, &word );
      field.name = strupr( word );
      SkipWhiteSpace( file );
      if ( GetChar( file ) != '=' )
      {
         _xfree( word );
         return ( FALSE );       /* NOTE */
      }
      SkipWhiteSpace( file );

      /* Get the field type */
      GetWord( file, &word );
      switch ( *word )
      {
         case 'c':
         case 'C':
            field.type = _rddFieldType( CHARACTER );
            break;

         case 'n':
         case 'N':
            field.type = _rddFieldType( NUMERIC );
            break;

         case 'l':
         case 'L':
            field.type = _rddFieldType( LOGICAL );
            break;

         case 'd':
         case 'D':
            field.type = _rddFieldType( DATE );
            break;

         default:
            field.type = _rddFieldType( UNDEF );
            break;
      }
      _xfree( word );

      if ( field.type == _rddFieldType( UNDEF ) )
      {
         return ( FALSE );       /* NOTE */
      }

      SkipWhiteSpace( file );
      if ( GetChar( file ) != ',' )
      {
         return ( FALSE );       /* NOTE */
      }
      SkipWhiteSpace( file );

      /* Get the field length */
      GetNumber( file, &word );
      field.len = (USHORT) atoi( word );
      _xfree( word );

      /* Get the field decimals and change to DOUBLE if appropriate */
      if ( field.type == _rddFieldType( NUMERIC ) )
      {
         SkipWhiteSpace( file );
         if ( GetChar( file ) != ',' )
         {
            PutChar( file );
         }
         else
         {
            SkipWhiteSpace( file );
            GetNumber( file, &word );
            field.type = _rddFieldType( DOUBLE );
            field.dec  = (USHORT) atoi( word );
            _xfree( word );
         }
      }

      ReadToNextLine( file );

      /* Add the field */
      SELFADDFIELD( ThisDb, &field );
      _xfree( field.name );

   }

   return ( TRUE );

}



/***
*  
*         .SDX file parsing routines
*  
*/


/*
*  
*  FindBOD()
*  
*  Finds a token, stores it to 'token' (allocating the mem for it) and
*  returns the offset into the file where the data stream starts
*  
*/

HIDE USHORT FindBOD( FHANDLE handle, BYTEPP token )

{
   USHORT bod = 0;

   if ( GetToken( handle, token ) )
   {
      ReadToNextLine( handle );
      bod = GetFilePos( handle );
   }

   return ( bod );
}



/*
*  
*  GetFilePos()
*  
*/

HIDE USHORT GetFilePos( FHANDLE handle )

{
   return ( (USHORT) _fsSeek( handle, 0L, FS_RELATIVE ) );
}


   
/*
*  
*  PutChar()
*  
*/

HIDE void PutChar( FHANDLE handle )

{
   _fsSeek( handle, -1L, FS_RELATIVE );
}



/*
*  
*  GetChar()
*  
*/

HIDE BYTE GetChar( FHANDLE handle )

{
   BYTE character;

   if ( _fsRead( handle, &character, 1 ) != 1 )
   {
      if ( _fsError() )
      {
         character = NIL;
      }
      else
      {
         character = EOF;
      }      
   }   
   
   return ( character );
}   



/*
*
*  GetToken()
*  
*/

HIDE BOOL GetToken( FHANDLE handle, BYTEPP token )

{
   BOOL found = FALSE;

   if ( ReadToNextToken( handle ) )
   {
      if ( GetWord( handle, token ) )
      {
         found = TRUE;
      }
   }
   
   return ( found );
}



/*
*  
*  ReadToNextWord()
*  
*/

HIDE BOOL ReadToNextWord( FHANDLE handle )

{
   BYTE data = 0;
   BOOL err  = FALSE;

   while ( !( err || isalpha( data )) )
   {
      if ( _fsRead( handle, &data, 1 ) != 1 )
      {
         err = TRUE;
      }
      else if ( data == ';' )
      {
         ReadToNextLine( handle );
      }
   }

   PutChar( handle );

   return ( !err );
}



/*
*  
*  ReadToNextToken()
*  
*/

HIDE BOOL ReadToNextToken( FHANDLE handle )

{
   BYTE data = 0;
   BOOL err  = FALSE;

   while ( !( err || ISTOKEN( data )) )
   {
      if ( _fsRead( handle, &data, 1 ) != 1 )
      {
         err = TRUE;
      }
      else if ( data == ';' )
      {
         ReadToNextLine( handle );
      }
   }

   return ( !err );
}



/*
*  
*  ReadToNextLine()
*  
*/

HIDE BOOL ReadToNextLine( FHANDLE handle )

{
   BYTE data    = 0;
   BOOL err     = FALSE;
   BOOL newline = FALSE;

   while ( !( err || newline ) )
   {
      if ( _fsRead( handle, &data, 1 ) != 1 )
      {
         err = TRUE;
      }
      else if ( data == '\r' )
      {
         if ( GetChar( handle ) == '\n' )
            newline = TRUE;
         else
            PutChar( handle );
      }
   }
            
   return ( !err );
}



/*
*  
*  GetWord()
*  
*/

HIDE BOOL GetWord( FHANDLE handle, BYTEPP word )

{
   USHORT size;
   USHORT start;
   USHORT end;
   BYTE   data;

   // Figure out the length of the word
   start = GetFilePos( handle );
   if ( isalpha( data = GetChar( handle )))               /* MSC RT */
   {
      do
      {
         data = GetChar( handle );
      }
      while ( isalnum( data ) || (data == '_') );

   }
   end = GetFilePos( handle ) - (( data == EOF ) ? 0 : 1 );
   size = end - start;

   // Roll backwards to the beginning of this 'word'
   _fsSeek( handle, (LONG) start, FS_SET );

   // Allocate the mem for 'word'
   *word = (BYTEP) _xgrab( size + 1 );
   (*word)[ size ] = NIL;

   return ( _fsRead( handle, *word, size ) == size );
}



/*
*  
*  GetNumber()
*  
*/

HIDE BOOL GetNumber( FHANDLE handle, BYTEPP word )

{
   USHORT size;
   USHORT start;
   USHORT end;
   BYTE   data;

   // Figure out the length of the word
   start = GetFilePos( handle );
   while ( isdigit( data = GetChar( handle )));           /* MSC RT */
   end = GetFilePos( handle ) - (( data == EOF ) ? 0 : 1 );
   size = end - start;

   // Roll backwards to the beginning of this 'word'
   _fsSeek( handle, (LONG) start, FS_SET );

   // Allocate the mem for 'word'
   *word = (BYTEP) _xgrab( size + 1 );
   (*word)[ size ] = NIL;

   return ( _fsRead( handle, *word, size ) == size );
}



/*
*  
*  GetFileName()
*  
*/

HIDE BOOL GetFileName( FHANDLE handle, BYTEPP word )

{
   BOOL   ok;
   BYTE   data;
   USHORT size;
   USHORT start;
   USHORT end;

   // Figure out the length of the word
   start = GetFilePos( handle );

   data = GetChar( handle );
   while ( isalpha( data ) || data == ':' || data == '\\' || data == '.' )
   {
      data = GetChar( handle );
   }

   end = GetFilePos( handle ) - (( data == EOF ) ? 0 : 1 );
   size = end - start;

   // Roll backwards to the beginning in the file
   _fsSeek( handle, (LONG) start, FS_SET );

   // Allocate the mem for 'word'
   *word = (BYTEP) _xgrab( size + 1 );
   (*word)[ size ] = NIL;

   ok = _fsRead( handle, *word, size ) == size;
   strupr( *word );

   return ( ok );
}



/*
*  
*  SkipWhiteSpace()
*  
*/

HIDE void SkipWhiteSpace( FHANDLE handle )

{
   BOOL done = FALSE;
   BYTE data;

   while ( !done )
   {
      data = GetChar( handle );
      if ( !ISWHITESPACE( data ) )
      {
         done = TRUE;
         PutChar( handle );
      }
   }
}



/***
*  
*           Buffer manipulation stuff
*  
*/



/*
*  
*  FileReadBuff()
*  
*/

HIDE BOOL FileReadBuff( SDXAREAP ThisDb )

{
   ULONG  filePos;
   ERRORP err;

   if ( !ThisDb->buffIsValid )
   {
      // Position the file pointer
      filePos = ( ThisDb->recNo - 1L ) * ( ThisDb->recSize + 2L );
      _fsSeek( ThisDb->dbHandle, filePos, FS_SET );

      if ( _fsRead( ThisDb->dbHandle, ThisDb->buff, 
                    (USHORT) ThisDb->recSize ) != (USHORT) ThisDb->recSize )
      {
         if ( err = _errNew() )
         {
            _errPutOsCode( err, _fsError() );
            _errPutGenCode( err, EG_READ );
            _errPutSubCode( err, ESDX_READ );
            GenError( ThisDb, err );            /* NOTE */
            _errRelease( err );
         }

         return ( FALSE );                      /* NOTE */
      }

      ThisDb->buffIsValid = TRUE;
   }

   return ( TRUE );
}



/***
*  
*           Floating point conversion wrappers
*  
*/


/*
*
*  DoubleToStr( dval, len, dec, dest )
*
*   Convert double to printable ASCII.
*
*   dval:  value to convert.
*   len:   desired total length.
*   dec:   desired number of decimal places.
*   dest:  destination buffer.
*
*   Decimal digits are rounded to desired number of places.  If whole
*  digits cannot be fully represented, destination is filled with
*  asterisks.
*
*  CAUTION: dest must be at least len + 1 bytes long.
*/

HIDE void DoubleToStr( XDOUBLE dval, USHORT len, USHORT dec, BYTEP dest )

{
   BYTEP  buff;
   int    expt;
   int    sign;
   USHORT total;
   USHORT b;
   USHORT d;


   buff = fcvt(dval, dec, &expt, &sign);

   /* check for overflow */
   total = 0;
   while (buff[total])
   {
      total++;
   }

   if (sign)
   {
      /* room for sign */
      total++;
   }

   if (dec)
   {
      /* room for decimal point */
      total++;

      if (expt < 1)
      {
         /* room for single whole zero */
         total++;

         /* room for leading fractional zeros */
         total += -expt;
      }
   }


   b = 0;
   d = 0;

   if (total > len)
   {
      /* overflow */
      while (d < len)
      {
         dest[d++] = '*';
      }
   }
   else
   {
      while (total < len)
      {
         /* leading blanks */
         dest[d++] = ' ';
         total++;
      }

      if (sign)
      {
         /* put in sign */
         dest[d++] = '-';
      }

      if (expt < 1)
      {
         /* whole zero and point */
         dest[d++] = '0';
         dest[d++] = '.';

         while (expt)
         {
            /* frac leading zeros */
            dest[d++] = '0';
            expt++;
         }
      }
      else
      {
         while (expt)
         {
            /* copy whole digits */
            dest[d++] = buff[b++];
            expt--;
         }

         if (dec)
         {
            /* point */
            dest[d++] = '.';
         }
      }

      while (buff[b])
      {
         /* other digits */
         dest[d++] = buff[b++];
      }
   }

   /* terminator */
   dest[d] = '\0';
}


