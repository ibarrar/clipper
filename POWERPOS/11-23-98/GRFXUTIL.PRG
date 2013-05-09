/*
* System......... Graphics Utility/Common Functions
* Program I.D.... GrfxUtil.prg
* Description.... Common Functions called by Graphics Routines
*
* Author......... jay ocampo
* Date Started... July 1994
* Dialect........ Clipper plus Graphics lib from Turbo C++
* Remarks........
*
*/

#include "POWERPOS.ch"
#include "GRFX_ALL.CH"


/*--------------------------------------------------------------------------*/
/* USAGE  : Clear a rectangular region of the screen
   PARMS  :

                  nTop, nLeft         -> Upper left coordinates
                  nRight, nBottom     -> Upper left coordinates
                  [nBackColor]        -> Fill Color of the specified rectangular region

   Returns: NIL

*/

function gClearTo( nLeft, nTop, nRight, nBottom, nBackColor)
local nForeSave
local nBackSave

  // Save ForeGround and BackGround Colors
*  nForeSave   := gGrfxConfg(FCOLOR_CFG)
*  nBackSave   := gGrfxConfg(BCOLOR_CFG)
*  nBackColor  := if( nBackColor != NIL, nBackColor, nBackSave)

#ifdef DEF_GRAPHICS
  // Clear the area by drawing a box in background color
  gDrawBox(nLeft, nTop, nRight, nBottom, SOLID_LINE, NORM_WIDTH, ;
           nBackColor, SOLID_FILL, nBackColor)
#endif

  // Restore ForeGround and BackGround Colors
*  gGrfxSetNw(FCOLOR_SET, nForeSave)
*  gGrfxSetNw(BCOLOR_SET, nBackSave)

RETURN NIL


