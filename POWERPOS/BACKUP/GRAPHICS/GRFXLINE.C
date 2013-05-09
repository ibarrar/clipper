/*
* System......... Graphics Library Routine for CLIPPER
* Program I.D.... GrfxLine.C
* Description.... Routine to Draw Line
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


int cDrawLine(int iLeft, int iTop, int iRight, int iBottom, int OptParm[]);


CLIPPER gDrawLine(void)
{
  /** Define C-variables to hold Clipper parameters **/ 
  
  int iLeft, iTop;         /* start of line coordinate  */
  int iRight, iBottom;     /* end of line coordinate    */ 
  int OptParm[4];          /* Optional parameters */
  
  /** Define local variables **/ 

  int ParmCnt;
  int i, status;


  ParmCnt = PCOUNT;
  if (ParmCnt < 4)
     {
       _retni(grINVP);
       return;
     } 

   /** Set optional parameters to END_PARM flag **/
   for( i = 0; i < 4; i++)
       OptParm[i] = END_PARM;

   iLeft   = _parni(1);
   iTop    = _parni(2);
   iRight  = _parni(3);
   iBottom = _parni(4);

   for( i = 0; i < ParmCnt - 4; i++)
     {
       if(ISNUM(i + 5))
          OptParm[i] = _parni(i + 5);
     }

   status = cDrawLine(iLeft, iTop, iRight, iBottom, OptParm);

   _retni(status);
}

int cDrawLine( int iLeft, int iTop, int iRight, int iBottom, int OptParm[])
{
   /* 
      Parameter List
      iLeft, iTop      -> Start of line coordinate  
      iRight, iBottom  -> End of line coordinate 


	 Optional Parameter List
      OptParm[0] -> int LineStyle
      OptParm[1] -> int LineThickness
      OptParm[2] -> int LineColor
      OptParm[3] -> int MoveFlag
      Optional Parameter = END_PARM if not explicitly passed
   */

   struct linesettingstype lineinfo;
   int MoveFlag;       // Row and Column Movements
   int iShadowColor;   // Button Line Style shadow
   int iHiliteColor;   // Button Line Style highlight

   /** Assign Default **/
   MoveFlag = MSCALE;

   /** get information about current line settings **/
   getlinesettings(&lineinfo);

   if((OptParm[0]  % THIN_THICK_LINE) >= SOLID_LINE &&
      (OptParm[0]  % THIN_THICK_LINE) <= DASHED_LINE)
      lineinfo.linestyle = OptParm[0];

   if(OptParm[1] == NORM_WIDTH || OptParm[1] == THICK_WIDTH)
      lineinfo.thickness = OptParm[1];

   if(OptParm[2] <= getmaxcolor() && OptParm[2] >= 0 )
      setcolor(OptParm[2]);
   else
     // Default line color to LIGHTGRAY if BUTTON_LINE style
     if( lineinfo.linestyle >= BUTTON_UP_LINE )
         OptParm[2] = LIGHTGRAY;

   if(OptParm[3] != END_PARM )
      MoveFlag = OptParm[3];

   if(MoveFlag != MPIXEL)
     {
       iLeft   = iscale(iLeft  , SCALE_X , SCR_SCALE);
       iTop    = iscale(iTop   , SCALE_Y , SCR_SCALE);
       iRight  = iscale(iRight , SCALE_X , SCR_SCALE);
       iBottom = iscale(iBottom, SCALE_Y , SCR_SCALE);
     }


   switch (lineinfo.linestyle)
   {
     case THIN_THICK_LINE:

       setlinestyle(SOLID_LINE, 0, THICK_WIDTH);
       line(iLeft, iTop, iRight, iBottom);

       setlinestyle(SOLID_LINE, 0, NORM_WIDTH);

       iTop    += THIN_THICK_ADJ ;
       iBottom += THIN_THICK_ADJ;

       /*
       iLeft = iLeft + THIN_THICK_ADJ ;
       iRight = iRight - THIN_THICK_ADJ ;
       */
       break;

     case BUTTON_UP_LINE:
     case BUTTON_DWN_LINE:

        if ( lineinfo.linestyle == BUTTON_UP_LINE )
           SetButtonColor( &OptParm[2], &iShadowColor, &iHiliteColor);
        else
           SetButtonColor( &OptParm[2], &iHiliteColor, &iShadowColor);

        setcolor(iHiliteColor);
        setlinestyle(SOLID_LINE, 0, lineinfo.thickness);
        line(iLeft, iTop, iRight, iBottom);

        setcolor(iShadowColor);
        setlinestyle(SOLID_LINE, 0, lineinfo.thickness);
        iTop    += lineinfo.thickness + 1 ;
        iBottom += lineinfo.thickness + 1 ;

        break;

     default:

        // select the line style
        setlinestyle(lineinfo.linestyle, 0, lineinfo.thickness);
        break;
   }

   line(iLeft, iTop, iRight, iBottom);

   return(grNORMAL);
}



