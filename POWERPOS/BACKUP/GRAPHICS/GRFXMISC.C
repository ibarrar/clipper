/*
* System......... Graphics Library Routine for CLIPPER
* Program I.D.... GrfxMisc.C
* Description.... Graphics Miscellaneous Function
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
#include <string.h>
#include <graphics.h>
#include "grfx_api.h"
#include "grfxmisc.h"



CLIPPER gClrDevice(void)
{
  /*
   USAGE : Erases the entire graphics  screen and moves the current position
           to the origin (0,0) - (x, y) coordinates.
  */
  
   /* clears the graphics screen */
    cleardevice();
    _retni(grNORMAL);
}

/*--------------------------------------------------------------------------*/

CLIPPER gGrfxConfg(void)
{
  /*
     USAGE : Interface function that returns one of the graphics settings
             listed below

     The first parameter can be one of the ff. defined constants

     MAXX_CFG           1  -> Get Maximum Column X in pixels
     MAXY_CFG           2  -> Get Maximum Row Y in pixels
     XCURR_CFG          3  -> Get Current Column position in pixels
     YCURR_CFG          4  -> Get Current Row position in pixels
     CHAR_WIDTH_CFG     5  -> Get Average Width of String passed in pixels
     CHAR_HEIGHT_CFG    6  -> Get Average Width of String passed in pixels
     GMODE_CFG          7  -> Get Current Graphics Mode
     FCOLOR_CFG         8  -> Get Current Foreground Color
     BCOLOR_CFG         9  -> Get Current Background Color
     CFONT_CFG         10  -> Get Current Font Setting
     CFSIZE_CFG        11  -> Get Current Character Size
     ISEGAVGA_CFG      13  -> Check if Graphics Driver is a EGA or VGA

  */

  int iObjPtr, iParmCnt, iretvalue;

  iParmCnt = PCOUNT;

  if(iParmCnt <= 1)
    _retni(grINVP);

  iObjPtr = _parni(1);

  iretvalue = grNORMAL;

  switch(iObjPtr)
    {
      case MAXX_CFG:
         iretvalue = getmaxx();
         break;
      case MAXY_CFG:
         iretvalue = getmaxy();
         break;
      case XCURR_CFG:
         iretvalue = getx();
         break;
      case YCURR_CFG:
         iretvalue = gety();
         break;
      case CHAR_WIDTH_CFG:
         if(iParmCnt == 2)
            if (ISCHAR(2))
                iretvalue = cStrWidth(_parc(2));
            else
               iretvalue = grINVP;
         else
            iretvalue = max(textwidth("W"), textwidth("M"));
         break;
      case CHAR_HEIGHT_CFG:
         if(iParmCnt == 2)
            if (ISCHAR(2))
                iretvalue = textheight(_parc(2));
            else
               iretvalue = grINVP;
         else
            iretvalue = textheight("H");
         break;
      case GMODE_CFG:
         iretvalue = getgraphmode();
         break;
      case FCOLOR_CFG:
         iretvalue = getcolor();
         break;
      case BCOLOR_CFG:
         iretvalue = getbkcolor();
         break;
      case CFONT_CFG:
      case CFSIZE_CFG:
         iretvalue = cTextInfo(iObjPtr);
         break;
      case ISEGAVGA_CFG:
         iretvalue = IsEGAVGAdrvr();
         break;
      default:
         iretvalue = grNORMAL;
         break;
    }

    _retni(iretvalue);
}


/*--------------------------------------------------------------------------*/


CLIPPER gGrfxSetNw(void)
{
  /*
     USAGE : Interface function that changes one of the graphic settings
             listed below

     The first parameter can be one of the ff. defined constants

     XMOVE_SET          1  -> Move Column position to X in pixels
     YMOVE_SET          2  -> Move Row position to Y in pixels
     FCOLOR_SET         3  -> Change Foreground Color
     BCOLOR_SET         4  -> Change Background Color
     GMODE_SET          5  -> Change Graphics Mode
     SCR_ACTIVE_SET     6  -> Change Active Screen Page ( 0 or 1 only for EGA/VGA mode 2)
     SCR_VISUAL_SET     7  -> Change Visual Screen Page ( 0 or 1 only for EGA/VGA mode 2)

  */

  int iObjPtr, iParmCnt, iNextParm, iretvalue;

  iParmCnt = PCOUNT;

  if(iParmCnt < 2)
    _retni(grINVP);

  iObjPtr = _parni(1);
  if (ISNUM(2))
     iNextParm = _parni(2);
  else
    _retni(grINVP);

  iretvalue = grNORMAL;

  switch(iObjPtr)
    {
      case XMOVE_SET:
           moveto(iNextParm, gety());
           break;
      case YMOVE_SET:
           moveto(getx(), iNextParm);
           break;
      case FCOLOR_SET:
           setcolor(iNextParm);
           break;
      case BCOLOR_SET:
           setbkcolor(iNextParm);
           break;
      case GMODE_SET:
           setgraphmode(iNextParm);
           break;
      case SCR_ACTIVE_SET:
           setactivepage(iNextParm);
           break;
      case SCR_VISUAL_SET:
           setvisualpage(iNextParm);
           break;

      default:
         iretvalue = grNORMAL;
         break;
    }

    _retni(iretvalue);
}


/*--------------------------------------------------------------------------*/


int cTextInfo(int iObjPtr)
{
  /*
     USAGE : C++ Function called by Clipper Interface functions namely:
             gGrfxConfg() and gGrfxText().  This either returns the
             current FONT or CHARACTER SIZE.
  */

  int iretvalue;
  int iCurrWid, iDefltWid;
  long nNumerator, nDenomtor;
  struct textsettingstype textinfo;

  iretvalue = grNORMAL;

  gettextsettings(&textinfo);

  switch(iObjPtr)
    {
      case CFONT_CFG:
         iretvalue = textinfo.font;
         break;
      case CFSIZE_CFG:
         iretvalue = textinfo.charsize;
         if(iretvalue == 0)
           {
             iCurrWid = textwidth("H");      /* Get Current text Width */
             setusercharsize(1, 1, 1, 1);
             iDefltWid = textwidth("H");     /* Get Default text Width */

             /* OffSet Rounding since float and double data types can NOT be used */

             nNumerator = (long)iCurrWid * X_MAGDIV;
             nDenomtor = (long)iDefltWid * getmaxx();

             iretvalue = (int) (nNumerator * 10 / nDenomtor) + 5;
             iretvalue = (int) (iretvalue / 10);

             if (iretvalue < 1)
                 iretvalue = 0;              /* Trap Invalid Char Size */

             /* Restore original user-define character size */
             setusercharsize(iretvalue * (getmaxx() + 1), X_MAGDIV, iretvalue * (getmaxy() + 1), Y_MAGDIV);
            }
         break;
      default:
         iretvalue = grNORMAL;
         break;
    }
  return(iretvalue);
}


/*--------------------------------------------------------------------------*/


int cStrWidth(char *textstring)
{
  /*
     USAGE : C++ Function called by Clipper Interface function gGrfxConfg
             This solves the offset error in determining the width of any
             character string in any Font and size configuration.
  */
  
  char cLetter[1];      /* String variable where each letter in the string is stored */
  int iLenCtr;          /* Accumulator for the total length of the string */
  int iCtr;

  iLenCtr = 0;
  cLetter[1] = '\0';    /* Explicit null terminator */

  for(iCtr = 0; iCtr < strlen(textstring); iCtr++)
     {
       cLetter[0] = textstring[iCtr];
       iLenCtr += textwidth(cLetter);
     }
  return(iLenCtr);
}


/*--------------------------------------------------------------------------*/


int IsEGAVGAdrvr(void)
{
  int iEGAVGAflag = FALSE;
  
  // compare name of the device driver in use  with "EGAVGA"

  iEGAVGAflag = strcmp(getdrivername(), "EGAVGA");
  
  if (iEGAVGAflag == 0)
     iEGAVGAflag = TRUE;
  else
     iEGAVGAflag = FALSE;

  return(iEGAVGAflag); 
} 