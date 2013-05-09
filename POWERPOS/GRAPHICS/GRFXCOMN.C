/*
* System......... Graphics Library Routine for CLIPPER
* Program I.D.... GrfxComn.C
* Description.... Common Routines for Clipper API
*
* Author......... jay ocampo
* Date Started... November 1994
* Dialect........ Turbo C++
* Remarks........
*
*/

#ifdef __TINY__
#error GRAPHLIB will not run in the tiny model.
#endif

#include "extend.h"
#include <stdlib.h>
#include <graphics.h>
#include "grfx_api.h"



void SetButtonColor( int *iFillColor, int *iShadowColor, int *iHiliteColor)
{
  /*
   USAGE : Set the Shadow and HiliteColor for BUTTON_LINE line style
           Function called by gDrawBox() and gDrawLine()
  */

   switch (*iFillColor)
   {
      case LIGHTBLUE:
      case LIGHTGREEN:
      case LIGHTCYAN:
      case LIGHTRED:
      case LIGHTMAGENTA:
      case YELLOW:
             *iHiliteColor = WHITE;
             *iShadowColor = *iFillColor - 8;
             break;

      case BLUE:
      case GREEN:
      case CYAN:
      case RED:
      case MAGENTA:
      case BROWN:

             *iHiliteColor = *iFillColor + 8;
             *iShadowColor = DARKGRAY;
             break;

      case DARKGRAY:
             *iHiliteColor = WHITE;
             *iShadowColor = LIGHTGRAY;
             break;

      case WHITE:
             *iHiliteColor = LIGHTGRAY;
             *iShadowColor = DARKGRAY;
             break;

      default:
             *iHiliteColor = WHITE;
             *iShadowColor = DARKGRAY;
             break;
   }

}


/*--------------------------------------------------------------------------*/

