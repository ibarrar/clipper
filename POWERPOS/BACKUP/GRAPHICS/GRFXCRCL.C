/*
* System......... Graphics Library Routine for CLIPPER
* Program I.D.... GrfxCrcl.C
* Description.... Routine to Draw Circle
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


int cDrawCircle(int iRowrel, int iColrel, int iRadius, int OptParm[]);


CLIPPER gDrawCircl(void)
{
  /** Define C-variables to hold Clipper parameters **/ 
  
  int iRowrel;             /* Row coordinate relative to Screen Scale */
  int iColrel;             /* Column coordinate relative to Screen Scale */
  int iRadius;        /* Radius relative to column coordinate */    
  int OptParm[6];	   /* Optional parameters */	
  
  /** Define local variables **/ 

  int ParmCnt;
  int i, status;


  ParmCnt = PCOUNT;
  if (ParmCnt < 3)
     {
       _retni(grINVP);
        return;
     }  

   /* Set optional parameters to END_PARM flag */
   for( i = 0; i < 6; i++)
       OptParm[i] = END_PARM;

   iRowrel = _parni(1);
   iColrel = _parni(2);
   iRadius = _parni(3);

   for( i = 0; i < ParmCnt - 3; i++)
      {
        if(ISNUM(i + 4))
           OptParm[i] = _parni(i + 4);
      }

   status = cDrawCircle( iRowrel, iColrel, iRadius, OptParm);

   _retni(status);
}


int cDrawCircle(int iRowrel, int iColrel, int iRadius, int OptParm[])
{
   /* 
      Parameter list
      iRowrel        -> Row coordinate relative to Screen Scale 
      iColrel        -> Column coordinate relative to Screen Scale
      iRadius   -> Radius relative to column coordinate     

      Optional parameters listed in order
      OptParm[0]  -> int LineStyle
      OptParm[1]  -> int LineThickness
      OptParm[2]  -> int LineColor
      OptParm[3]  -> int Fillpattern
      OptParm[4]  -> int FillColor
      OptParm[5]  -> int MoveFlag
      Optional Parameter = END_PARM if not explicitly passed
   */

   struct linesettingstype lineinfo;
   struct fillsettingstype fillinfo;
   int MoveFlag;

   /** Assign Default **/
   MoveFlag = MSCALE;


   /** get information about current line settings **/
   getlinesettings(&lineinfo);

   /** get information about current fill pattern and color **/
   getfillsettings(&fillinfo);

   if((OptParm[0]  % THIN_THICK_LINE) >= SOLID_LINE &&
      (OptParm[0]  % THIN_THICK_LINE) <= DASHED_LINE)
      lineinfo.linestyle = OptParm[0];

   if(OptParm[1] == NORM_WIDTH || OptParm[1] == THICK_WIDTH)
      lineinfo.thickness = OptParm[1];

   if(OptParm[2] <= getmaxcolor() && OptParm[2] >= 0 )
      setcolor(OptParm[2]);

   if(OptParm[3] >= EMPTY_FILL && OptParm[3] < USER_FILL )
      fillinfo.pattern = OptParm[3];

   if(OptParm[4] <= getmaxcolor() && OptParm[4] >= 0 )
      fillinfo.color = OptParm[4];

   if(MoveFlag != MPIXEL)
     {
	iColrel = iscale(iColrel, SCALE_X, SCR_SCALE);
	iRowrel = iscale(iRowrel, SCALE_Y, SCR_SCALE);
	iRadius = iscale(iRadius, SCALE_X, SCR_SCALE);
      }

   /** select the fill style **/
   setfillstyle(fillinfo.pattern, fillinfo.color);

   /** default line style to SOLID_LINE **/

   if(lineinfo.linestyle == THIN_THICK_LINE)
     {
       setlinestyle(SOLID_LINE, 0, THICK_WIDTH);
       circle(iColrel, iRowrel, iRadius);

       // fillellipse((int)iColrel, (int)iRowrel, (int)iRadius, (int)iRadius);
	  

       setlinestyle(SOLID_LINE, 0, NORM_WIDTH);
       iRadius = iRadius - THIN_THICK_ADJ;
      }
   else
      setlinestyle(SOLID_LINE, 0, lineinfo.thickness);

   fillellipse(iColrel, iRowrel, iRadius, iRadius);

   /** restore original line style **/
   setlinestyle(lineinfo.linestyle, 0, lineinfo.thickness);

   return(grNORMAL);
}


