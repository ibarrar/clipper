/*
*  IsDouble( nExp ) -> lIsIt?
*
*  Tells if an expression is being stored internally as a double.
*  Copyright (C) 1993, Computer Associates, Inc. All Rights Reserved
*
*/
#include "clipdefs.h"
#include "extend.api"
#include "item.api"

CLIPPER IsDouble( void )
{
   ITEM itemRet, itemNum;

   itemRet = _itemPutL( NULL, FALSE );

   if (PCOUNT > 0)
   {
      itemNum = _itemParam( 1 );

      if (_itemType( itemNum ) & DOUBLE)
         itemRet = _itemPutL( itemRet, TRUE );

      _itemRelease( itemNum );
   }
   
   _itemRelease( _itemReturn( itemRet ) );

   return;
}
