/*
* MYARRAY()
*
* Just like ARRAY()!
*
* Copyright (C) 1993, Computer Associates, Inc. All Rights Reserved
*/

#include "clipdefs.h"
#include "extend.api"
#include "item.api"
#include "fm.api"

HIDE ITEM near _xMakeSub( USHORTP apSize, USHORT dims );

CLIPPER MYARRAY(void)
{
   ITEM       arrayP, elementsP;
   SHORT      i;
   BOOL       check;
   USHORT     pcount = PCOUNT;
   USHORTP    apSize;

   /* Check parameters - must be at least one and all NUMERIC */

   if ( pcount )
   {
      // CAUTION: _xgrab() will cause VM IE if there ain't enuf memory
      //
      apSize = (USHORTP)_xgrab( pcount * sizeof( USHORT ) );

      // store the parameters into apSize[] in reverse order.
      //
      for (i = 0; i < pcount; i++)
      {
         elementsP = _itemParam( pcount-i );

         check = _itemType( elementsP ) == NUMERIC &&
                 ( apSize[i] = (USHORT)_itemGetNL( elementsP ) ) <= 4096;

         _itemRelease( elementsP );

         if (!check)
            break;
      }

      // If all of the parameters check out ...
      //
      if( check )
      {
         arrayP = _xMakeSub( apSize, pcount );
         _itemReturn ( arrayP );
         _itemRelease( arrayP );
      }
      else
      {
         _itemRelease( _itemReturn( _itemNew( NULL ) ) );
      }

      _xfree( apSize );
   }

   return;
}

HIDE ITEM near _xMakeSub( USHORTP apSize, USHORT dims )
{
   ITEM   arrayP;
   ITEM   tempP;
   USHORT i;

   // Zoom through the parms backwards for PT
   //
   arrayP = _itemArrayNew( apSize[ --dims ] );

   if ( dims )
   {
      for (i = 1; i <= apSize[ dims ]; i++)
      {
         tempP = _xMakeSub( apSize, dims );
         _itemArrayPut( arrayP, i, tempP );
         _itemRelease( tempP );
      }
   }

   return (arrayP);
}
