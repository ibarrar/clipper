/***
*
*  Sdxinit.prg
*
*  SDX driver initialization module
*
*  Copyright (c) 1993, Computer Associates International, Inc.
*  All rights reserved.
*
*/

#include "Rddsys.ch"

ANNOUNCE SDX

INIT PROCEDURE SdxSys()
   REQUEST _SDX

   rddRegister( "SDX", RDT_FULL )

   RETURN

