/*
*
* CharCount( cString, cChar )
*
* Count occurences of a single character
* in a CA-Clipper string.
*
* Copyright (C) 1993, Computer Associates, Inc
* All Rights Reserved
*/
#include "clipdefs.h"
#include "extend.api"
#include "item.api"

CLIPPER CharCount( void )
{
   USHORT uiChars = 0;
   USHORT uiLen;
   USHORT i;

   BYTEP  cStringP;
   BYTEP  cFindMeP;

   ITEM   itemString, itemFindMe, itemRet;
   

   if (PCOUNT != 2)
   {
      _ret();           // NOTE: Withhold service
      return;           // Early return!
   }

   itemRet    = _itemPutNL( NULL, 0 );
   itemString = _itemParam( 1 );
   itemFindMe = _itemParam( 2 );

   if ( (_itemType( itemString ) == CHARACTER) &&
        (_itemType( itemFindMe ) == CHARACTER) )
   {
      if (_itemSize( itemFindMe ) == 1)
      {
         cFindMeP = _itemGetC( itemFindMe );
         cStringP = _itemGetC( itemString );
   
         uiLen = _itemSize( itemString );

         for( i = 0; i < uiLen; i++ )
         {
            if ( cStringP[i] == *cFindMeP )
               uiChars++;
         }
      
         _itemFreeC( cFindMeP );
         _itemFreeC( cStringP );   


         itemRet = _itemPutNL( itemRet, (long)uiChars );
      }
   }

   _itemReturn( itemRet );

   _itemRelease( itemRet );
   _itemRelease( itemString );
   _itemRelease( itemFindMe );

   return;
}
