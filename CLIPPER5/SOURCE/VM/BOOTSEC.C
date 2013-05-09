/***
*   BOOTSEC.C
*
*   Item / VM API client example.
*   Copyright (C) 1993 Computer Associates, Inc.  All Rights Reserved.
*/

#include "extend.api"
#include "item.api"
#include "vm.api"
#include "clipdefs.h"
#include "dos.h"
#include "gt.api"


/***
*  This sample also uses the GT subsystem to display debugging
*  messages.  When DEBUG is defined, _gtWriteCon() calls are 
*  intercepted and displayed.
*/
#define MSGOUT( cmsg ) _gtWriteCon( cmsg, strlen(cmsg) );

#ifdef DEBUG
   #define ERROUT( cmsg ) MSGOUT( cmsg )
#else
   #define ERROUT( cmsg )
#endif


/*
*
* BootSector( [nDrive] ) -> cBootSecBuff
*
* Read the boot sector from drive nDrive,
* if there is no drive specified, BootSector()
* reads drive A.
*
* (0=A, 1=B, 2=C, etc...)
*
* Warning: Does not check for errors.
*          Needs dos.h & LLIBCA
*/ 

CLIPPER BootSector( void )
{
   ITEM   itemDriveN, itemBuff;
   BYTEP  bufferP;
   HANDLE vmBuffer;
   USHORT uiDriveN = 0;       // Default: A
   USHORT uiLen = 1024;

   union  REGS  preCallRx, postCallRx;
   struct SREGS theSegs;

   if ( PCOUNT > 0 )
   {
      itemDriveN = _itemParam( 1 );

      if ( _itemType( itemDriveN ) | NUMERIC )
         uiDriveN = (USHORT) _itemGetNL( itemDriveN );
      
      _itemRelease( itemDriveN );
   }

   vmBuffer = _xvalloc( uiLen );
   bufferP  = _xvlock( vmBuffer );

   segread( &theSegs );

   theSegs.es     = FP_SEG( bufferP );
   preCallRx.x.bx = FP_OFF( bufferP );
   preCallRx.x.ax = 0x0201;       // BIOS 02 / 1 sector
   preCallRx.x.cx = 1;            // Track 0, Sector 1
   preCallRx.x.dx = uiDriveN;     // Side 0, Drive uiDriveN

   int86x( 0x13, &preCallRx, &postCallRx, &theSegs );

   if ( postCallRx.x.cflag )
      ERROUT( "\r\nERROR on read!" );
   
   itemBuff = _itemPutCL( NULL, bufferP, uiLen );

   _xvunlock( vmBuffer );   
   _xvfree( vmBuffer );

   _itemRelease( _itemReturn( itemBuff ) );
   
   return;
}
