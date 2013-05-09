/*
* ARRAYCLONE( <aArray1> ) --> aNewArray
*
* This function shows the use of the
* ITEM API's array functions.
*
* Copyright (C) 1993, Computer Associates, Inc.  All Rights Reserved
*/

#include "clipdefs.h"
#include "extend.api"
#include "item.api"

HIDE ITEM near _xAClone( ITEM aSrc );


CLIPPER ARRAYCLONE( void )
{
   ITEM aSource;        // Source array
   ITEM aCloned;        // New array

   /* Do parameters check */

   if ( PCOUNT != 1 )
   {
      return;
   }

   /* Get source array as ITEM */

   aSource = _itemParam( 1 );

   /* Clone source array  */

   aCloned = _xAClone( aSource );

   /* Return clone, release clone and source */

   _itemReturn ( aCloned );

   _itemRelease( aSource );
   _itemRelease( aCloned );

   return;
}


HIDE ITEM near _xAClone( ITEM aSrc )
{
   ITEM   itemRAD;
   ITEM   aTemp;
   ITEM   aNew;

   USHORT i;
   USHORT nLen;

   if ( !( _itemType( aSrc ) == ARRAY ) )    // If not an array
      return ( _itemNew( NULL ) );           //    return a NULL item (NIL)

   nLen = _itemSize( aSrc );                 // Get array len
   aNew = _itemArrayNew( nLen );             // Create new array of that len

   for ( i = 1; i <= nLen; i++ )             // Iterate through elements
   {
      itemRAD = _itemArrayGet( aSrc, i );    // Get source element value

      if ( _itemType( itemRAD ) == ARRAY )   // If array
      {
         aTemp = _xAClone( itemRAD );        //    clone it to "aTemp"
         _itemArrayPut( aNew, i, aTemp );    //    put it in "aNew" element
         _itemRelease( aTemp );              //    release "aTemp"
      }
      else
      {
         _itemArrayPut( aNew, i, itemRAD );  //    Put value in "aNew"
      }
   
      _itemRelease( itemRAD );               // Release RAD's ITEM
   
   }
   
   return ( aNew );

}
