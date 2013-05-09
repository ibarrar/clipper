/*
*
* Quarter( dDate ) -> nQuarter
* 
* Given a date, determines what quarter it lies in
* Copyright (C) 1993, Computer Associates, Inc. All Rights Reserved
*
*/
#include "clipdefs.h"
#include "extend.api"
#include "item.api"

CLIPPER Quarter( void )
{
   ITEM itemDate, itemQuarter;
   BYTE sDate[8];          // Date buffer: YYYYMMDD\0

   if ( PCOUNT == 0 )
   {
      _ret();              // Withhold service!
      return;   
   }

   
   itemQuarter = _itemPutNL( NULL, 0 );
   itemDate = _itemParam( 1 );
   
   if ( _itemType( itemDate ) == DATE )
   {
      _itemGetDS( itemDate, sDate );

      sDate[6] = NULL;
   
      if (sDate[4] == '1')
      {
         itemQuarter = _itemPutNL( itemQuarter, 4 );
      }
      else
      {
         switch ( sDate[5] )
         {
            case '1':
            case '2':
            case '3':
               itemQuarter = _itemPutNL( itemQuarter, 1 );
               break;

            case '4':
            case '5':
            case '6':
               itemQuarter = _itemPutNL( itemQuarter, 2 );
               break;

            default:
               itemQuarter = _itemPutNL( itemQuarter, 3 );

         }
      }
   }

   _itemReturn( itemQuarter );
   _itemRelease( itemDate );
   _itemRelease( itemQuarter );

   return;
}
