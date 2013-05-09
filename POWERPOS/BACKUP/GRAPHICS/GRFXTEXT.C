/*
* System......... Graphics Library Routine for CLIPPER
* Program I.D.... GrfxText.C
* Description.... Routine to display graphical text messages
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
#include <graphics.h>
#include <stdlib.h>
#include <string.h>
#include "grfx_api.h"
#include "grfxtext.h"
#include "grfxmisc.h"


int cDrawText(int iRowrel, int iColrel, const char *ctext_msg, int OptParm[]);


CLIPPER gDrawText(void)
{
  /** Define C-variables to hold Clipper parameters **/ 
  
  int    iRowrel;          /* Row coordinate relative to Screen Scale */
  int    iColrel;          /* Column coordinate relative to Screen Scale */
  char  *ctext_msg;        /* Character string to display */
  int    OptParm[7];       /* Optional parameters */

  /** Define local variables **/

  int    ParmCnt;
  int    i, status;


  ParmCnt = PCOUNT;
  if (ParmCnt < 3)
     {
       _retni(grINVP);
       return;
     }

   /* Set optional parameters to END_PARM flag */
   for( i = 0; i < 7; i++)
       OptParm[i] = END_PARM;

   /* Convert Clipper parameters to C */
   iRowrel   = _parni(1);
   iColrel   = _parni(2);
   ctext_msg = _parc(3);

   for( i = 0; i < ParmCnt - 3; i++)
     {
       if(ISNUM(i + 4))
       OptParm[i] = _parni(i + 4);
     }

   status = cDrawText(iRowrel, iColrel, ctext_msg, OptParm);

   _retni(status);

}



int cDrawText(int iRowrel, int iColrel, const char *ctext_msg, int OptParm[])
{
  /*
     Parameter List
     iRowrel     -> Row position relative to Screen Scale
     iColrel     -> Column position relative to Screen Scale
     ctext_msg   -> Character string to display

     Optional parameter List
     OptParm[0]  -> int font
     OptParm[1]  -> int charsize
     OptParm[2]  -> int iForeColr
     OptParm[3]  -> int MoveFlag
     OptParm[4]  -> int iJustify
     OptParm[5]  -> int WrapFlag
     OptParm[6]  -> int UlineFlag
     Optional Parameter = END_PARM if not explicitly passed
  */
  int MoveFlag, WrapFlag, ULineFlag;
  int iAveHeight, iAveWidth, tmpCtr;
  int iErrorCode, nRow, nCol, nThreshold;
  int iLineCol;
  char *ptrtostr;

  struct viewporttype vp;
  struct textsettingstype textinfo;
  struct linesettingstype lineinfo;

   /* get information about current text settings */
   gettextsettings(&textinfo);

   /* get information about current line settings */
   getlinesettings(&lineinfo);


   /* assign defaults */
   textinfo.vert = TOP_TEXT;
   textinfo.direction = HORIZ_DIR;
   MoveFlag = MFIX;
   WrapFlag = WRAPTEXT_OFF;
   ULineFlag = ULINE_OFF;

   if(OptParm[0] >= DEFAULT_FONT && OptParm[0] < NFONTS)
     textinfo.font = OptParm[0];

   if(OptParm[1] > 0 && OptParm[1] < 11)
     textinfo.charsize = OptParm[1];

   if(textinfo.charsize == 0)      /* 0 means a User defined size */
      textinfo.charsize = cTextInfo(CFSIZE_CFG);

   if(OptParm[2] >= 0 && OptParm[2] <= getmaxcolor())
     setcolor(OptParm[2]);

   if(OptParm[3] != END_PARM )
      MoveFlag = OptParm[3];

   if(OptParm[4] == CENTER_TEXT || OptParm[4] == RIGHT_TEXT)
      textinfo.horiz = OptParm[4] ;

   if(OptParm[5] != END_PARM )
      WrapFlag = OptParm[5];

   if(OptParm[6] != END_PARM )
       ULineFlag = OptParm[6];

    getviewsettings( &vp );

    tmpCtr = textheight("H");                /* store previous font's ave. character height */

    graphresult();                           /* clear error code             */
    settextstyle(textinfo.font, textinfo.direction, 4);

    // Store FONT height and width for size 4
    iAveHeight = textheight("H");
    iAveWidth = max(textwidth("M"), textwidth("W"));

    if(textinfo.font != DEFAULT_FONT)
      {

        // Normalize font sizes for any/all video adapter
        // by using screen coordinates as magnification factor
        setusercharsize(textinfo.charsize * (SCALE_X + 1), X_MAGDIV,
                        textinfo.charsize * (SCALE_Y + 1), Y_MAGDIV);

        // Since the magnification factor is rounded down to the
        // nearest integer, there will certainly be an offset error
        // for character size for varying video adapter.

        // To minimize the error :
        //    consider the fractional part of the magnification factor,
        //    by multiplying the average height and width with the
        //    SCR_SCALE (100 pixels), when calculating for relative
        //    row and column coordinates

        iAveHeight = iscale(iAveHeight * SCR_SCALE,
                            textinfo.charsize * (SCALE_Y + 1), Y_MAGDIV);
        iAveWidth  = iscale(iAveWidth  * SCR_SCALE,
                            textinfo.charsize * (SCALE_X + 1), X_MAGDIV);
      }
    else
     {
        settextstyle(textinfo.font, textinfo.direction, textinfo.charsize);
        iAveHeight = iscale(iAveHeight * SCR_SCALE, textinfo.charsize, 4);
        iAveWidth  = iscale(iAveWidth  * SCR_SCALE, textinfo.charsize, 4);
     }

    iErrorCode = graphresult();            // check result
    if( iErrorCode != grOk )               // if error occured
      {
        closegraph();
        return(iErrorCode);
      }

    // Set Underline to SOLID_LINE of NORM_WIDTH
    if(ULineFlag == ULINE_ON)
       setlinestyle(SOLID_LINE, 0, NORM_WIDTH);


    // Suppress Numeric overflow
    iRowrel = min(iRowrel, vp.bottom - vp.top);
    iColrel = min(iColrel, vp.right - vp.left);

    // Calculate Row and Column coordinates (in pixels)
    nRow = iscale(iAveHeight, iRowrel, SCR_SCALE);
    nCol = iscale(iAveWidth , iColrel, SCR_SCALE);

    // Average Font Height and Width (in pixels)
    iAveHeight = iAveHeight / SCR_SCALE;
    iAveWidth  = iAveWidth  / SCR_SCALE;

    switch (MoveFlag)
    {
      case MROWREL:
           // move <iRowrel>* rows relative to CP (current position)
           // move <iColrel>* columns from HP (home position)

      case MBOTHREL:
           // move <iRowrel>* rows relative to CP
           // move <iColrel>* columns relative to CP

          tmpCtr = tmpCtr - iAveHeight;         // Row Adjustment for varying font size
          nRow = nRow + gety() + tmpCtr;

          if (MoveFlag == MBOTHREL)
             nCol += getx();

          break;

      case MCOLREL:
           // move <iRowrel>* rows from HP
           // move <iColrel>* columns relative to CP

           nCol += getx();
           break;

      case MSCALE:
           // row and column coordinates are scale accdg. to SCR_SCALE

           nRow = iscale(iRowrel , SCALE_Y, SCR_SCALE);
           nCol = iscale(iColrel , SCALE_X, SCR_SCALE);
           break;

      case MPIXEL:
           // use row and column parameters as actual coordinates
           // For use of Get routine only : NOT RECOMMENDED!
           nRow = iRowrel;
           nCol = iColrel;
           break;

      default:
           // move <iRowrel>* rows from HP
           // move <iColrel>* columns from HP
           // MFIX
           // nRow = iscale(iAveHeight, iRowrel, SCR_SCALE);
           // nCol = iscale(iAveWidth , iColrel, SCR_SCALE);
           break;
    }


   // allocate memory for message string
   if ((ptrtostr = _xalloc(strlen(ctext_msg) + 1)) == NULL)
       return(grError);

    nThreshold = vp.right - nCol;

    switch(textinfo.horiz)
     {
      case CENTER_TEXT:
        if(MoveFlag == MFIX )
           nCol = ((vp.right - vp.left) / 2) + nCol;
        nThreshold = (vp.right - nCol) * 2;
        iLineCol = nCol - (textwidth(ctext_msg) / 2);
        break;

      case RIGHT_TEXT:
        if(MoveFlag == MFIX)
           nCol = vp.right - nCol;
        iLineCol = nCol - textwidth(ctext_msg);
        break;

      default:    // LEFT_TEXT
        iLineCol = nCol - 1;
        break;
     }
    settextjustify(textinfo.horiz, textinfo.vert );

    // Check for endless loop  & Wrap Text Flag
    if(nThreshold < iAveWidth || WrapFlag != WRAPTEXT_ON )
       nThreshold = textwidth(ctext_msg) + 1;


    strcpy(ptrtostr, ctext_msg);
    tmpCtr = 0;

    while(textwidth(ptrtostr) > nThreshold )
      {
      strcpy(ptrtostr, "");
     while(textwidth(ptrtostr) < nThreshold)
       {
         strncat(ptrtostr, &ctext_msg[tmpCtr], 1);
         tmpCtr++;
        }

     tmpCtr--;
     ptrtostr[strlen(ptrtostr) - 1] = '\0';

     moveto(nCol, nRow);
     outtext(ptrtostr);
     nRow += iAveHeight;
     strcpy(ptrtostr, &ctext_msg[tmpCtr]);

     if(ULineFlag == ULINE_ON)
       line(iLineCol, nRow + 2, iLineCol + textwidth(ctext_msg), nRow + 2);
      }


    moveto(nCol, nRow);
    outtext(ptrtostr);
    if(ULineFlag == ULINE_ON)
      {
     line(iLineCol, nRow + iAveHeight + 2, iLineCol + textwidth(ctext_msg), nRow +  iAveHeight + 2);
     setlinestyle(lineinfo.linestyle, 0, lineinfo.thickness);
      }

    settextjustify(LEFT_TEXT, textinfo.vert );        /* set justification to default */

    // free memory
    _xfree(ptrtostr);

    return(grNORMAL);

}

