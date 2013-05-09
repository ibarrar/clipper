/*************************************************/
/* Filename:      WINDOWS.PRG                    */
/* Module:        Text Window Functions Library. */
/* Date-Written:  November 27, 1991              */
/* Last-Update:   December 07, 1991              */
/*************************************************/

/*************************************************************************/
/* CHAR function OpenWindow(t,l,b,r,cTitle)                              */
/* --> pops-up a text window with a shadow in the specified coordinates. */
/* INT  t,l,b,r - refers to the coordinates of the window.               */
/* CHAR cTitle  - string title displayed on the top row of the window.   */
/*                                                                       */
/* CHAR function CloseWindow(cWindow)                                    */
/* --> closes a previously opened window.                                */
/* CHAR cWindow - character buffer of a previously saved window.         */
/*************************************************************************/

#include "Box.ch"
#include "Inkey.ch"
#include "Setcurs.ch"

// Constant definitions for Window.
#define GET_T(cWindow)   Asc(SubStr(cWindow,1,1))
#define GET_L(cWindow)   Asc(SubStr(cWindow,2,1))
#define GET_B(cWindow)   Asc(SubStr(cWindow,3,1))
#define GET_R(cWindow)   Asc(SubStr(cWindow,4,1))
#define GET_WIN(cWindow) SubStr(cWindow,5)

// Constant definitions for Shadow.
#define ATTR_CONV(FORE,BACK) (BACK)/16+(FORE)
#define BLACK   0
#define WHITE   7
#define DK_GRAY 9
#define COL_SHADOW_ATTRIBUTE ATTR_CONV(DK_GRAY,BLACK)
#define BW_SHADOW_ATTRIBUTE  ATTR_CONV(WHITE,BLACK)

function OpenWindow(t,l,b,r,cTitle)
local cWindow,i,k,c
local clr := SetColor("N/W")           // Change color to Black on White.
   // Save coordinates and screen to buffer.
   cWindow:=chr(t)+chr(l)+chr(b+1)+chr(r+1)+SaveScreen(t,l,b+1,r+1)
   k:=((r-l)/2)
   for i:=((b-t)/2) to b
   for c:=1 to 3
   @ max(t,b-i),max(l,(r-k)) clear to min(b,t+i),min(r,(l+k))
   next
   k++
   next                                // palabok
   @ t,l clear to b,r                  // Clear window.
*   @ t,l to b,r                       // Draw box.
   Shadow(t,l,b,r)                      // Draw shadow of window.
   if !empty(cTitle)                    // Is there a title?
      SetColor(if(IsColor(),"W+/RB+","W+/N")) // Change color to White on Cyan.
      @ t,l clear to t,r               // Clear title area.
      @ t,l+2 say cTitle               // Display title.
      SetColor("N/W")                  // Change color to Black on White.
   endif
return cWindow                         // Value returned: CHAR cWindow

function CloseWindow(cWindow)
   // Restore previously saved screen.
   RestScreen(GET_T(cWindow),GET_L(cWindow),GET_B(cWindow),;
   GET_R(cWindow),GET_WIN(cWindow))
return nil                             // Value returned: NIL

function Shadow(t,l,b,r)
local shadow_attribute
   // Only if there is room.
   if r<MaxCol() .and. b<MaxRow()
      shadow_attribute:=iif(IsColor(),COL_SHADOW_ATTRIBUTE,BW_SHADOW_ATTRIBUTE)
      ShadowAttr(b+1,l+1,b+1,r+1,shadow_attribute)
      ShadowAttr(t+1,r+1,b+1,r+1,shadow_attribute)
   endif
return nil

static function ShadowAttr(t,l,b,r,new_attr)
local old_scr_area,new_scr_area,i
   // Save screen area in a variable.
   old_scr_area:=SaveScreen(t,l,b,r)
   // Initialize new screen area.
   new_scr_area:=""
   // Copy each character in saved area to new string & change attribute.
   for i:=1 to Len(old_scr_area) step 2
      new_scr_area:=new_scr_area+SubStr(old_scr_area,i,1)+chr(new_attr)
   next
   // Restore new area in same position.
   RestScreen(t,l,b,r,new_scr_area)
return nil

// end-of-file