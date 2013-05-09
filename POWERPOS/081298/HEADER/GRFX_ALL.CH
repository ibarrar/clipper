/*
ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
บ  System          :  PowerPOS for Specialty Shop                         บ
บ  Program I.D.    :  GRFX_ALL.CH                                         บ
บ  Description     :  Collection of all Definition Files for              บ
บ                     Graphics Interface Library                          บ
บ  Author          :  jay ocampo                                          บ
บ  Date Started    :  June 1994                                           บ
บ  Last Revision   :                                                      บ
บ  Dialect         :  Clipper plus Extend Libraries from Turbo C++        บ
บ  Remarks         :                                                      บ
ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
*/

#include "GRFXDRVR.CH"
#include "GRFX_API.CH"
#include "GRFXCOLR.CH"
#include "GRFXFILL.CH"
#include "GRFXFONT.CH"
#include "GRFXLINE.CH"
#include "GRFXMISC.CH"
#include "GRFXTEXT.CH"
#include "GRFXMENU.CH"

#include "GRFXSCRN.CH"

#define CFG_DNORM   BLACK
#define CFG_DHLITE  WHITE
#define CFG_DBACK   BLACK
#define CFG_DFILL   LIGHTGRAY
#define CFG_DBORDR  WHITE
#define CFG_DBAR    DARKGRAY    
#define CFG_DMSG    WHITE

#define MAX_ITEM_DISP  10
#define MAX_PAYROW     6
#define MIN_ITEM_DISP  1

#define DEF_SWAPDRIVE   ""                                // Define Swap Drive, preferably a RAM Drive
#define DEF_SCR_SWAP    DEF_SWAPDRIVE + "SCR_SWAP.IMG"    // Screen Image Swap File
#define DEF_SCREENREST  DEF_SWAPDRIVE + "SCREEN.IMG"
