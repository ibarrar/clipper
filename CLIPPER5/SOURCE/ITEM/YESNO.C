/*
*  YesNo( lExpr ) -> cValue
*
*  Given a logical expression, returns the
*  string "Yes" if true, and "No " if false.
*
*  Copyright (C) 1993, Computer Associates, Inc. All Rights Reserved
*/
#include "clipdefs.h"
#include "extend.api"
#include "item.api"

CLIPPER YesNo( void )
{
   ITEM itemLughi, itemCRet;

   // Warning: "Yes" and "No " strings use DGROUP!
   // In general, this is a bad practice, but ... 6 bytes?
   // I doubt if the universe will explode (unless this is a 
   // Doug Adams program)

   itemCRet = _itemPutC( NULL, "No " );

   if (PCOUNT > 0)
   {
      itemLughi = _itemParam( 1 );
      if (_itemGetL( itemLughi ))
         itemCRet = _itemPutC( itemCRet, "Yes");
   
      _itemRelease( itemLughi );      
   }

   _itemRelease( _itemReturn( itemCRet ) );
   return;
}
