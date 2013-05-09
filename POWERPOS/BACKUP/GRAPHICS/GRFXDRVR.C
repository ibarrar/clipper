/*
* System......... Graphics Library Routine for CLIPPER
* Program I.D.... GrfxDrvr.C
* Description.... Graphics Driver Functions
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

#include <graphics.h>
//#include <stdlib.h>
//#include <stdio.h>
//#include <conio.h>
//#include <alloc.h>

#include "extend.h"
#include "grfx_api.h"

/***
*   Note:
*   _xalloc() returns NULL if the request cannot be satisfied
*   _xgrab() generates a runtime error if the request cannot be satisfied
*/

/*   allocate memory */
extern void far * far _xalloc(unsigned int numberOfBytes);
extern void far       _xfree(void far *allocatedBlock);



void far * far _graphgetmem(unsigned size)
{
// char far * ptr;
  /* My own version of _graphgetmem to totally make the
     "TURBO C" graphics routines compatible with clipper. */

//  printf("\n_graphgetmem called to allocate %d bytes.\n",size);
//  printf("press any key:");
//  getch();
//  printf("\n");

  /* allocate memory from clipper's heap */

    return _xalloc(size);
//  ptr = (char far *) _xalloc(size);

//  if( ptr == NULL )
//     printf("\n allocation unsuccessfull");
//  else
//     printf("\n allocation successfull");


//  return ptr;
}


void far _graphfreemem(void far *ptr, unsigned size )
{
  /* also to make the deallocation symmetrically equal to _xalloc */

//  printf("\n_graphfreemem called to free %d bytes.\n",size);
//  printf("press any key:");
//  getch();
//  printf("\n");


  /* free ptr from clipper's heap */

  _xfree(ptr);
}

CLIPPER gGraphInit(void)
{
//  char far * one_ptr;
//  char far * two_ptr;

  /*
   USAGE : Initializes the graphics driver
   PARM  : GraphDriver  -> optional parameter for graphics driver;
                           defaults to auto-detect
           GraphMode    -> optional parameter for graphics mode;
                           defaults to zero; if auto-detect, the
                           highest graphics mode is selected
  */

  int GraphDriver  = DETECT;                /* The Graphics device driver  */
  int GraphMode    = 0;                     /* The Graphics mode value     */

  /** Define local variables **/
  int ErrorCode    = grOk;                  /* Reports any graphics errors */

  if(ISNUM(1))                            /* assign requested graphics driver */
     GraphDriver = _parni(1);

  if(ISNUM(2))                              /* assign requested graphics mode   */
     GraphMode   = _parni(2);


  /* Set the size of the internal graphics buffer smaller
     before making a call to initgraph.  The default size of
     this buffer is 4,096 bytes.
  */
  setgraphbufsize(GRFXBUFSIZE);


  /* Note : Load Graphics Drivers from Disks since this will only be
            done at the start of the program.  Linked-in graphics
            driver codes costs a lot of memory.*/

/*
  if( registerfarbgidriver(EGAVGA_driver_far  ) < 0)
     ErrorCode = grInvalidDriver;

  if( registerfarbgidriver(CGA_driver_far     ) < 0)
     ErrorCode = grInvalidDriver;
  if( registerfarbgidriver(Herc_driver_far    ) < 0)
     ErrorCode = grInvalidDriver;
  if( registerfarbgidriver(ATT_driver_far     ) < 0)
     ErrorCode = grInvalidDriver;
  if( registerfarbgidriver(IBM8514_driver_far ) < 0)
     ErrorCode = grInvalidDriver;
  if( registerfarbgidriver(PC3270_driver_far  ) < 0)
     ErrorCode = grInvalidDriver;
                                               */

  /***** Register fonts *****/

  /*
  Note : Do NOT register other graphics fonts as linked-in code
         to save on memory.  Register fonts only if necessary.
  */


/*
  if( registerfarbgifont(triplex_font_far ) < 0)
     ErrorCode = grInvalidFont;
  if( registerfarbgifont(small_font_far ) < 0)
     ErrorCode = grInvalidFont;

  if( registerfarbgifont(sansserif_font_far ) < 0)
     ErrorCode = grInvalidFont;
  if( registerfarbgifont(gothic_font_far ) < 0)
     ErrorCode = grInvalidFont;
  if( registerfarbgifont(script_font_far ) < 0)
     ErrorCode = grInvalidFont;


  if( registerfarbgifont(simplex_font_far) < 0)
     ErrorCode = grInvalidFont;
  if( registerfarbgifont(triplex_scr_font_far) < 0)
     ErrorCode = grInvalidFont;


  if( registerfarbgifont(complex_font_far) < 0)
     ErrorCode = grInvalidFont;


  if( registerfarbgifont(european_font_far) < 0)
     ErrorCode = grInvalidFont;

  if( registerfarbgifont(bold_font_far) < 0)
     ErrorCode = grInvalidFont;
                                */
  /*   Check error before loading graphics drivers */

  /*
   if (ErrorCode != grOk)
     {
       printf("Error1 = %d\n", ErrorCode);
       getch();
       _retni(ErrorCode);
       return;
     }
  */

  // test alloc & dealloc
//  if ( (one_ptr =  _graphgetmem(5554)) == NULL)
//      printf("\n fail to allocate 10b in ist test ");

//  if ( (two_ptr =  _graphgetmem(600)) == NULL)
//      printf("\n fail to allocate 10b in 2nd test ");

  // deallocate...
//  printf("\n deallocate ist ...");
//  _graphfreemem(one_ptr,5554);

//  printf("\n now the second...");
//  _graphfreemem(two_ptr,600);


//  printf("\n every thing is ha ok...");


  initgraph( &GraphDriver, &GraphMode, "BGI" );
  ErrorCode = graphresult();            /* Read result of initialization*/
  if( ErrorCode != grOk )               /* Error occured during init    */
    {
//      printf("Error2 = %d\n", ErrorCode);
      _retni(ErrorCode);
      return;
    }

//  printf("\n Setting fill style");

  setfillstyle(EMPTY_FILL, getcolor());

  _retni(grOk);
}


/*--------------------------------------------------------------------------*/


CLIPPER gGraphClos(void)
{
  /*
   USAGE : Shuts down the graphics system,  frees memory allocated for
           graphic drivers and fonts.
  */
  if (PCOUNT == 0)
  {
    closegraph();
    _retni(grNORMAL);
  }
  else
    _retni(grINVP);
}

/*--------------------------------------------------------------------------*/


CLIPPER gGrfxToTxt(void)
{
  /*
   USAGE : Restores the screen mode from Graphics to Text after call to
           gGraphInit().
  */
  if (PCOUNT != 0)
    _retni(grINVP);

    /* restore system to text mode */
    restorecrtmode();
    _retni(grNORMAL);
}

/*--------------------------------------------------------------------------*/

CLIPPER gTxtToGrfx(void)
{
  /*
   USAGE :  Switch back to Graphics mode after call to gGrfxToTxt().
  */
  if (PCOUNT != 0)
    _retni(grINVP);

    /* return to graphics mode */
    setgraphmode(getgraphmode());
    _retni(grNORMAL);
}

