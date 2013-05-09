/***
*
*  Sdxinter.c
*
*  Workarea definitions and interface for SDX driver
*
*  Copyright (c) 1993, Computer Associates International, Inc.
*  All rights reserved.
*
*/

// AREAP must be re-defined to point to our expanded workarea structure
#define AREAP  struct _SDXAREA_ far *

#include "extend.api"
#include "rdd.api"
#include "filesys.api"
#include "error.api"
#include "sdx.h"

/*
*  This extern pulls in the dummy dynlink module for the RDD that your RDD
*  inherits from.  It should be the same as the hard link symbol from the 
*  parent's dynlink module.  In our case, it is WA for workarea.
*/
extern WA;


/***
*
*  SDX dbfunctable definitions
*
*  When our new virtual table is created (using the _rddInherit()
*  function), each element that is defined below will be copied over
*  any existing super class method in the same slot.  NULL entries 
*  will not be copied, and will retain the existing super class 
*  method.  This gives us the effect of inheritance.
*/

/* Movement and positioning methods */

extern ERRCODE sdxBof                  ( SDXAREAP workArea, BOOLP bof );
extern ERRCODE sdxEof                  ( SDXAREAP workArea, BOOLP eof );
#define        sdxFound                NULL
extern ERRCODE sdxGoBottom             ( SDXAREAP workArea );
extern ERRCODE sdxGo                   ( SDXAREAP workArea, ULONG recNo );
extern ERRCODE sdxGotoId               ( SDXAREAP workArea, ITEM record );    
extern ERRCODE sdxGoTop                ( SDXAREAP workArea );
#define        sdxSeek                 NULL
#define        sdxSkip                 NULL
#define        sdxSkipFilter           NULL
extern ERRCODE sdxSkipRaw              ( SDXAREAP workArea, LONG nToSkip );


/* Data management */

#define        sdxAddField             NULL
extern ERRCODE sdxAppend               ( SDXAREAP workArea, BOOL releaseLocks );
#define        sdxDelete               NULL
extern ERRCODE sdxDeleted              ( SDXAREAP workArea, BOOLP isDeleted );
#define        sdxFieldCount           NULL
#define        sdxFieldName            NULL
#define        sdxFlush                NULL
extern ERRCODE sdxGetValue             ( SDXAREAP workArea, USHORT index, ITEM value );
#define        sdxGetVarLen            NULL
extern ERRCODE sdxGoCold               ( SDXAREAP workArea );
extern ERRCODE sdxGoHot                ( SDXAREAP workArea );
#define        sdxPutRec               NULL
extern ERRCODE sdxPutValue             ( SDXAREAP workArea, USHORT index, ITEM value );    
#define        sdxRecall               NULL
extern ERRCODE sdxRecCount             ( SDXAREAP workArea, ULONGP recCount );
extern ERRCODE sdxRecNo                ( SDXAREAP workArea, ITEM row );
#define        sdxSetFieldExtent       NULL


/* Workarea/database management */

#define        sdxAlias                NULL
extern ERRCODE sdxClose                ( SDXAREAP workArea );
extern ERRCODE sdxCreate               ( SDXAREAP workArea, DBOPENINFOP info );    
#define        sdxInfo                 NULL
extern ERRCODE sdxNew                  ( SDXAREAP workArea );
extern ERRCODE sdxOpen                 ( SDXAREAP workArea, DBOPENINFOP info );    
extern ERRCODE sdxRelease              ( SDXAREAP workArea );    
extern ERRCODE sdxStructSize           ( SDXAREAP workArea, USHORTP size );    
extern ERRCODE sdxSysName              ( SDXAREAP workArea, BYTEP buff );
#define        sdxDbEval               NULL
#define        sdxPack                 NULL
#define        sdxSort                 NULL
#define        sdxTrans                NULL
#define        sdxTransRec             NULL
#define        sdxZap                  NULL


/* Relational methods */

#define        sdxChildEnd             NULL
#define        sdxChildStart           NULL
#define        sdxChildSync            NULL
#define        sdxSyncChildren         NULL
#define        sdxClearRel             NULL
#define        sdxForceRel             NULL
#define        sdxRelArea              NULL
#define        sdxRelEval              NULL
#define        sdxRelText              NULL
#define        sdxSetRel               NULL


/* Order management */

#define        sdxOrderListAdd         NULL
#define        sdxOrderListClear       NULL
#define        sdxOrderListDelete      NULL
#define        sdxOrderListFocus       NULL
#define        sdxOrderListRebuild     NULL
#define        sdxOrderCondition       NULL
#define        sdxOrderCreate          NULL
#define        sdxOrderDestroy         NULL
#define        sdxOrderInfo            NULL


/* Filters and scope settings */

#define        sdxClearFilter          NULL
#define        sdxClearLocate          NULL
#define        sdxClearScope           NULL
#define        sdxFilterText           NULL
#define        sdxSetFilter            NULL
#define        sdxSetLocate            NULL
#define        sdxSetScope             NULL


/* Miscellaneous */

#define        sdxCompile              NULL
#define        sdxError                NULL
#define        sdxEvalBlock            NULL


/* Network operations */

#define        sdxLock                 NULL
#define        sdxUnlock               NULL



/***
*
*  SDX dbfunctable
*
*/

HIDE DBFUNCTABLE near sdxFuncTable = 
{
   /* Movement and positioning methods */

   sdxBof,
   sdxEof,
   sdxFound,
   sdxGoBottom,
   sdxGo,
   sdxGotoId,
   sdxGoTop,
   sdxSeek,
   sdxSkip,
   sdxSkipFilter,
   sdxSkipRaw,


   /* Data management */

   sdxAddField,
   sdxAppend,
   sdxDelete,
   sdxDeleted,
   sdxFieldCount,
   sdxFieldName,
   sdxFlush,
   sdxGetValue,
   sdxGetVarLen,
   sdxGoCold,
   sdxGoHot,
   sdxPutRec,
   sdxPutValue,
   sdxRecall,
   sdxRecCount,
   sdxRecNo,
   sdxSetFieldExtent,


   /* Workarea/database management */

   sdxAlias,
   sdxClose,
   sdxCreate,
   sdxInfo,
   sdxNew,
   sdxOpen,
   sdxRelease,
   sdxStructSize,
   sdxSysName,
   sdxDbEval,
   sdxPack,
   sdxSort,
   sdxTrans,
   sdxTransRec,
   sdxZap,


   /* Relational methods */

   sdxChildEnd,
   sdxChildStart,
   sdxChildSync,
   sdxSyncChildren,
   sdxClearRel,
   sdxForceRel,
   sdxRelArea,
   sdxRelEval,
   sdxRelText,
   sdxSetRel,


   /* Order management */

   sdxOrderListAdd,
   sdxOrderListClear,
   sdxOrderListDelete,
   sdxOrderListFocus,
   sdxOrderListRebuild,
   sdxOrderCondition,
   sdxOrderCreate,
   sdxOrderDestroy,
   sdxOrderInfo,


   /* Filters and scope settings */

   sdxClearFilter,
   sdxClearLocate,
   sdxClearScope,
   sdxFilterText,
   sdxSetFilter,
   sdxSetLocate,
   sdxSetScope,


   /* Miscellaneous */

   sdxCompile,
   sdxError,
   sdxEvalBlock,


   /* Network operations */

   sdxLock,
   sdxUnlock

};



extern DBFUNCTABLE near sdxSuper;

/*
*
*  sdxGetFuncTable()
*
*  Calls _rddInherit() which copies the super class's table into
*  "table" and then copies the non-NULL entries from "sdxFunctable"
*  into it.  The modified copy of "table" will be used by the system
*  any time our driver is used.  Also, "sdxSuper" will now point to
*  the unmodified super class table. 
*
*/

ERRCODE pascal sdxGetFuncTable( USHORTP count, DBFUNCTABLEP table )

{
   *count = DBFUNCCOUNT;

   if ( table != NULL )
      _rddInherit( table, &sdxFuncTable, &sdxSuper, NULL );

   return ( E_SUCCESS );

}



/*
*
*  sdxInit()
*
*  Since DLLs are not yet supported, this only needs to be a stub.
*
*/

int pascal sdxInit( USHORT hInst, USHORT wDSeg, USHORT wHeap, BYTEP lpCmd )

{
   hInst;
   wDSeg;
   wHeap;
   lpCmd;

   return ( 1 );

}

