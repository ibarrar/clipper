/*
*
* CharCount( cString, cChar )
*
* Count occurences of a single character
* in a CA-Clipper string.
*
*/
#include "clipdefs.h"
#include "extend.api"
#include "item.api"
#include "vm.api"

CLIPPER CharCount( void )
{
   USHORT uiChars = 0;
   USHORT uiLen;
   USHORT i;
   HANDLE vmhString;

   BYTEP  cStringP;
   BYTE   cFindMe;

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
      _itemCopyC( itemFindMe, &cFindMe, 1 );
   
      vmhString = _xvalloc( _itemSize( itemString ), NULL );
      cStringP = _xvlock( vmhString );

      uiLen = _itemCopyC( itemString, cStringP, NULL );

      for( i = 0; i < uiLen; i++ )
      {
         if ( cStringP[i] == cFindMe )
            uiChars++;
      }
      
      _xvunlock( vmhString );   
      _xvfree( vmhString );


      itemRet = _itemPutNL( itemRet, (long)uiChars );
      
   }

   _itemReturn( itemRet );

   _itemRelease( itemRet );
   _itemRelease( itemString );
   _itemRelease( itemFindMe );

   return;
}
