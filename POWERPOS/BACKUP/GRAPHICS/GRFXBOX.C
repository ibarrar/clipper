/*
* System......... Graphics Library Routine for CLIPPER
* Program I.D.... GrfxBox.C
* Description.... Routine to Draw Box
*
* Author......... jay ocampo
* Date Started... June 1994
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


int cDrawBox(int iLeft, int iTop, int iRight, int iBottom, int OptParm[]);
int cDrawButtn( int iLeft, int iTop, int iRight, int iBottom,
                int iButtonStyle, int iFillPattern, int iFillColor, int iboxADJ);


CLIPPER gDrawBox(void)
{
  /** Define C-variables to hold Clipper parameters **/

  int iLeft, iTop;         /* Upper left corner of box  */
  int iRight, iBottom;     /* Lower right corner of box */
  int OptParm[7];          /* Optional parameters       */

  /** Define local variables **/

  int iParmCnt;
  int i, status;


  iParmCnt = PCOUNT;
  if (iParmCnt < 4)
     {
       _retni(grINVP);
       return;
     }


   /** Set optional parameters to END_PARM flag **/
   for( i = 0; i < 7; i++)
       OptParm[i] = END_PARM;

   iLeft   = _parni(1);
   iTop    = _parni(2);
   iRight  = _parni(3);
   iBottom = _parni(4);

   for( i = 0; i < iParmCnt - 4; i++)
     {
       if(ISNUM(i + 5))
          OptParm[i] = _parni(i + 5);
      }

   status = cDrawBox(iLeft, iTop, iRight, iBottom, OptParm);

  _retni(status);

}


/*--------------------------------------------------------------------------*/


int cDrawBox(int iLeft, int iTop, int iRight, int iBottom, int OptParm[])
{
   /*
      Parameter List
      iLeft, iTop      -> Upper left corner of box
      iRight, iBottom  -> Lower right corner of box

      Optional Parameter List
      OptParm[0]  -> int LineStyle
      OptParm[1]  -> int LineThickness
      OptParm[2]  -> int LineColor
      OptParm[3]  -> int Fillpattern
      OptParm[4]  -> int FillColor
      OptParm[5]  -> int MoveFlag
      OptParm[6]  -> int iboxAdj
      Optional Parameter = END_PARM if not explicitly passed
   */

   struct linesettingstype lineinfo;
   struct fillsettingstype fillinfo;
   int MoveFlag;
   int iboxADJ;                           // Adjustment (in pixels) from outer box to inner box

   /** Assign Default **/
   MoveFlag = MSCALE;


   /** get information about current line settings **/
   getlinesettings(&lineinfo);

   /** get information about current fill pattern and color **/
   getfillsettings(&fillinfo);

   if(OptParm[0] >= SOLID_LINE && OptParm[0] <= BUTTON_DWN_LINE)
      lineinfo.linestyle = OptParm[0];

   if(OptParm[1] == NORM_WIDTH || OptParm[1] == THICK_WIDTH)
      lineinfo.thickness = OptParm[1];

   if(OptParm[2] <= getmaxcolor() && OptParm[2] >= 0 )
      setcolor(OptParm[2]);

   if(OptParm[3] >= EMPTY_FILL && OptParm[3] < USER_FILL )
      fillinfo.pattern = OptParm[3];
   else
       // Default fill pattern to SOLID_FILL if BUTTON_LINE style
      if( lineinfo.linestyle >= BUTTON_UP_LINE )
          fillinfo.pattern = SOLID_FILL;


   if(OptParm[4] <= getmaxcolor() && OptParm[4] >= 0 )
      fillinfo.color = OptParm[4];
   else
       // Default fill color to LIGHTGRAY if BUTTON_LINE style
      if( lineinfo.linestyle >= BUTTON_UP_LINE )
          fillinfo.color = LIGHTGRAY;

   if(OptParm[5] != END_PARM )
      MoveFlag = OptParm[5];

   if(OptParm[6] != END_PARM )
      iboxADJ  = OptParm[6];
   else
      iboxADJ  = 10;

   iboxADJ = iscale( SCALE_Y, iboxADJ, SCALE_X);


   if(MoveFlag != MPIXEL)
     {
       iLeft   = iscale(iLeft  , SCALE_X, SCR_SCALE);
       iTop    = iscale(iTop   , SCALE_Y, SCR_SCALE);
       iRight  = iscale(iRight , SCALE_X, SCR_SCALE);
       iBottom = iscale(iBottom, SCALE_Y, SCR_SCALE);
      }


   if( lineinfo.linestyle >= BUTTON_UP_LINE )

      cDrawButtn( iLeft, iTop, iRight, iBottom,
                 lineinfo.linestyle, fillinfo.pattern, fillinfo.color, iboxADJ);
   else
     {
       /** select the fill style **/
       setfillstyle(fillinfo.pattern, fillinfo.color);

       /** select the line style **/
       if (lineinfo.linestyle != THIN_THICK_LINE)
           setlinestyle(lineinfo.linestyle , 0, lineinfo.thickness);
       else
         {
           iboxADJ = THIN_THICK_ADJ;   // Default to box adjustment to THIN_THICK_ADJ ( 5 pixels )
           setlinestyle(SOLID_LINE, 0, THICK_WIDTH);
           //rectangle(iLeft, iTop, iRight, iBottom);

           bar3d(iLeft, iTop, iRight, iBottom, 0, 0);

           setlinestyle(SOLID_LINE, 0, NORM_WIDTH);
           iLeft   = iLeft   + iboxADJ;
           iTop    = iTop    + iboxADJ;
           iRight  = iRight  - iboxADJ;
           iBottom = iBottom - iboxADJ;
         }

       bar3d(iLeft, iTop, iRight, iBottom, 0, 0);
     }

   return(grNORMAL);
}


/*--------------------------------------------------------------------------*/

int cDrawButtn( int iLeft, int iTop, int iRight, int iBottom,
                int iButtonStyle, int iFillPattern, int iFillColor, int iboxADJ)
{
   /*
      Parameter List
      iLeft, iTop      -> Upper left corner of box
      iRight, iBottom  -> Lower right corner of box
      iButtonStyle     -> Line Style Constant
      iFillPattern
      iFillColor

      Optional Parameter = END_PARM if not explicitly passed
   */

   //int iboxADJ;        // Adjustment (in pixels) from outer box to inner box
   int a1, b1;         // Upper left corner of inner box
   int a2, b2;         // Lower right corner of inner box
   int nSaveColor;     // Save Current Color
   int iShadowColor;   // Button Line Style shadow
   int iHiliteColor;   // Button Line Style highlight

   nSaveColor = getcolor();

   if ( iButtonStyle == BUTTON_UP_LINE )
      SetButtonColor( &iFillColor, &iShadowColor, &iHiliteColor);
   else	   
      SetButtonColor( &iFillColor, &iHiliteColor, &iShadowColor);

   setcolor(BLACK);
   setlinestyle(SOLID_LINE, 0, NORM_WIDTH);

   //iboxADJ = iscale( SCALE_Y, 10, SCALE_X);

   a1 = iLeft   + iboxADJ;
   b1 = iTop    + iboxADJ;
   a2 = iRight  - iboxADJ;
   b2 = iBottom - iboxADJ;

   // Draw Outer Box
   //setfillstyle(iFillPattern, iShadowColor);
   setfillstyle(SOLID_FILL, iShadowColor);
   bar3d(iLeft, iTop, iRight, iBottom, 0, 0);

   // Draw Inner Box
   setfillstyle(iFillPattern, iFillColor);
   bar3d(a1, b1, a2, b2, 0, 0);

   // Draw Lower-Left diagonal line
   line( iLeft, iBottom, a1, b2);

   // Draw Upper-Right diagonal line
   line( iRight, iTop, a2, b1);

   // Fill Box Highlight
   setfillstyle(iFillPattern, iHiliteColor);
   floodfill(iLeft + 1, iTop + 1, BLACK);

   // Fill Box Shadow
   setfillstyle(iFillPattern, iShadowColor);
   floodfill(iRight - 1, iBottom - 1, BLACK);


   // Re-Draw diagonal lines using Box Face Color
   setcolor(iFillColor);
   line( iLeft, iBottom, a1, b2);
   line( iRight, iTop, a2, b1);
   line( iLeft, iTop, a1, b1);
   line( iRight, iBottom, a2, b2);
   rectangle(a1, b1, a2, b2);

   setcolor(iShadowColor);
   rectangle(iLeft, iTop, iRight, iBottom);

   // Draw INNERmost Box
   //iboxADJ = iscale( SCALE_Y, 7, SCALE_X);
   iboxADJ = iboxADJ / 2;
   a1 = a1 + iboxADJ;
   b1 = b1 + iboxADJ;
   a2 = a2 - iboxADJ;
   b2 = b2 - iboxADJ;

   setcolor(iShadowColor);
   line( a1, b1, a2, b1);
   line( a1, b1, a1, b2);

   setcolor(iHiliteColor);
   line( a2, b2, a2, b1);
   line( a2, b2, a1, b2);

   setcolor(nSaveColor);

   return(grNORMAL);
}



