/*============================================================================

        (c) 1993  TECHNO SOFTWARE CORPORATION

        This module contains information proprietary to TECHNO SOFTWARE
        CORPORATION, and should be treated confidential.

        MAKEDBF2.PRG - Create DP, CL,  dbf and ntx.
                                    Inventory Tracking System (ITS)

        acr / 03.28.93

============================================================================*/
#include "dbstruct.ch"
#include "its.ch"

FUNCTION makedbf2()
local aDbf := {}, aStru, aNtx

   // Initialize the arrays to empty.
   aStru := {}
   aNtx  := {}

   // Item File Set
   AADD ( aStru, { "UI_PLUCODE", "C", PLU_CODE_LEN, 0, "" } )   
   AADD ( aStru, { "UI_STKCODE", "C", PLU_CODE_LEN, 0, "" } )
   AADD ( aStru, { "UI_STK_BAL", "N", 15, 3, "" } )
   AADD ( aStru, { "UI_BEG_BAL", "N", 15, 3, "" } )
   AADD ( aStru, { "UI_MAX_BAL", "N", 15, 3, "" } )
   AADD ( aStru, { "UI_MIN_BAL", "N", 15, 3, "" } )
   AADD ( aStru, { "UI_REORDER", "N", 15, 3, "" } )
   AADD ( aStru, { "UI_P_COUNT", "N", 15, 3, "" } )
*  AADD ( aStru, { "UI_STK_ADJ", "N", 15, 3, "" } )
   AADD ( aStru, { "UI_DATEREC", "D", 08, 0, "" } )
   AADD ( aStru, { "UI_STK_OUT", "D", 08, 0, "" } )
   AADD ( aStru, { "UI_REODATE", "D", 08, 0, "" } )
   AADD ( aStru, { "UI_ECRDSLS", "N", 15, 2, "" } )
   AADD ( aStru, { "UI_ECRDCNT", "N", 15, 3, "" } )
   AADD ( aStru, { "UI_ACCDSLS", "N", 15, 2, "" } )
   AADD ( aStru, { "UI_ACCDCNT", "N", 10, 3, "" } )
   AADD ( aStru, { "UI_ECRMSLS", "N", 15, 2, "" } )
   AADD ( aStru, { "UI_ECRMCNT", "N", 10, 3, "" } )
   AADD ( aStru, { "UI_ECRASLS", "N", 15, 2, "" } )
   AADD ( aStru, { "UI_ECRACNT", "N", 10, 3, "" } )
   AADD ( aStru, { "UI_DSLRATE", "N", 10, 3, "" } )
   AADD ( aStru, { "UI_MSLRATE", "N", 10, 3, "" } )
   AADD ( aStru, { "UI_POSTDTE", "D", 08, 0, "" } )
   AADD ( aStru, { "UI_OP_FLAG", "N", 01, 0, "" } )
   

   AADD ( aNtx,  { "UITEMS", "UI_PLUCODE", "PLU Stock Code" } )
   AADD ( aDbf,  { "UITEMS", "Items PLU File", aStru, aNtx   } )
        
RETURN aDbf
