/*
* USERDO()
* --------
* userDO( <valueToDO>, [ <uParam1> [, <uParamN> [, ... ]]] ) --> result
*
* Copyright (C) 1993 Computer Associates, Inc. All Rights Reserved
*/
#include "clipdefs.h"
#include "extend.api"
#include "item.api"

CLIPPER userDO( void )
{
   EVALINFO info;
   USHORT   uiParam;
   ITEM     retP;

   /* Get evaluation expression */

   if ( PCOUNT < 1 )
   {
      _ret();
      return;
   }
   else
   {
      _evalNew( &info, _itemParam( 1 ) );
   }

   /* Get parameters */

   for ( uiParam = 2; uiParam <= PCOUNT; uiParam++ )
   {
      _evalPutParam( &info, _itemParam( uiParam ) );
   }

   /* Launch evaluation information */

   retP = _evalLaunch( &info );

   /* Release ITEMs associated with the evaluation info */
   
   _evalRelease( &info );

   _itemReturn ( retP );
   _itemRelease( retP );

   return;
}

