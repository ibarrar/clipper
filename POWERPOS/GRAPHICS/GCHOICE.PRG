/*
* System......... Graphics Achoice Demo Program
* Program I.D.... gCHOICE.prg
* Description.... Demo Program calling the User-Defined Graphics Menu routine
*
* Author......... jay ocampo
* Date Started... July 1994
* Dialect........ Clipper plus Graphics lib from Turbo C++
* Remarks........
*
*/

#include "INKEY.CH"
#include "SET.CH"
#include "GRFX_ALL.CH"

#define  DEF_SCR_DEMO   "GRFXDEMO.IMG"


#define MEM_CHAR   0
#define MEM_BLOCK  1
#define MEM_RUN    2



MEMVAR GETLIST
MEMVAR GetVar

PROCEDURE main
  LOCAL status, iCtr
  LOCAL aMenuItems
  LOCAL nTop
  LOCAL nLeft
  LOCAL nBottom
  LOCAL nRight
  LOCAL cMenuTitle
  LOCAL nChoice
  LOCAL nFont
  LOCAL nSize
  LOCAL nFontHilite
  LOCAL nSizeHilite
  LOCAL nNormColor
  LOCAL nHiliteColor
  LOCAL nFillColor
  LOCAL nBarColor
  LOCAL buffer

  SET SCOREBOARD OFF

  SETCOLOR("W+/B")
  CLEAR


  // Initialize Graphics Driver
  status := gGraphInit()

  IF status < 0
    ? "GRAPHICS ERROR: "
    ?? status
    RETURN
  ENDIF


  aMenuItems := { "<\<V> Void"              , ;
                  "<\<E> Error Correct"     , ;
                  "<\<R> Refund"            , ;
                  "<\<X> Return = Exchange" , ;
                  "<\<Z> Return > Exchange" , ;
                  "<\<B> Return < Exchange"   }


  nLeft   := 4
  nTop    := 20
  nRight  := NIL
  nBottom := NIL
  cMenuTitle := NIL
  nChoice := 3

  nFont         := TRIPLEX_FONT
  nSize         := 3
  nFontHilite   := TRIPLEX_FONT
  nSizeHilite   := 3
  nNormColor    := WHITE
  nHiliteColor  := LIGHTRED
  nFillColor    := LIGHTGRAY
  nBarColor     := DARKGRAY


  nChoice := GrfxAChoice( aMenuItems, nLeft, nTop, nRight, nBottom, cMenuTitle, nChoice, ;
                          nFont, nSize , nFontHilite, nSizeHilite, ;
                          nNormColor, nHiliteColor, nFillColor, nBarColor, "TEMP.IMG", ULINE_OFF )


  IF (nChoice != 0)
      gDrawText(1, 0, "Item Selected = " + aMenuItems[nChoice], nFont, nSize, nHiliteColor, ;
                MFIX, CENTER_TEXT, WRAPTEXT_OFF, ULINE_OFF)
  ELSE
      gDrawText(1, 0, "ESC is Pressed !" , nFont, nSize, nHiliteColor, ;
                MFIX, CENTER_TEXT, WRAPTEXT_OFF, ULINE_OFF)

  ENDIF


  INKEY(0)

   // Release Graphics Drivers
   gGraphClos()
   ? "Back to text mode..."



RETURN



