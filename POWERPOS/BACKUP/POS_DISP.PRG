/*
ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
บ  System          :  PowerPOS for Specialty Shop                         บ
บ  Program I.D.    :  POS_DISP.PRG                                        บ
บ  Description     :  Collection of POS Screen Display Functions          บ
บ                                                                         บ
บ  Author          :  jay ocampo                                          บ
บ  Date Started    :  November 1994                                       บ
บ  Last Revision   :                                                      บ
บ  Remarks         :                                                      บ
ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
*/

#include "powerpos.ch"
#include "pfl_clip.ch"
#include "keymap.ch"
#include "spec_key.ch"
#include "message.ch"

#ifdef DEF_GRAPHICS
 #include "grfx_all.ch"
#endif 

#define  DEF_MSG_COL     50   // Message Display column position ( MSCALE )
#define  DEF_POSNAME     "PowerPOS ver 2.0a" 

#define CLR_X1 8
#define CLR_Y1 442
#define CLR_X2 630
#define CLR_Y2 473


/*---------------------------------------------------------------------------*/


FUNCTION MainDisplay(cTxtMsg)

/*  Usage : Main Menu Display
    Parm  :
            cTxtMsg -> Optional Message Dispaly
    Return: NIL
*/

#ifdef DEF_GRAPHICS
  gClrDevice()       // Clear entire screen

  gDrawBox(0, 0, 100, 100, THIN_THICK_LINE, NORM_WIDTH, ;
           CFG_DBORDR, SOLID_FILL, CFG_DBACK)
#endif
  MsgAreaDisp(cTxtMsg)

return nil


FUNCTION MsgAreaDisp( cTxtMsg )

/*  Usage : Display Text Message at the  Message Area
    Parm  :
            cTxtMsg - optional Help Message
    Return: NIL
*/

  // Erase First Then          
  // Clear the area by drawing a box in background color
  gDrawBox(CLR_X1, CLR_Y1, CLR_X2, CLR_Y2, SOLID_LINE, NORM_WIDTH, BLACK, SOLID_FILL, BLACK, MPIXEL)      

  // Display Help Message
  if !empty(cTxtMsg)
      // Display Text Message
      gDrawText(91, DEF_MSG_COL, cTxtMsg, SIMPLEX_FONT, 3, CFG_DMSG, MSCALE, CENTER_TEXT)       
  endif

return nil


function ErrorDisp( cErrMsg )
local cKey := 0

  // Display Help Message
  IF (cErrMsg != NIL)
      // disable key board sound   
      set_key_sound(OFF)

      // Clear the area by drawing a box in background color
      gDrawBox(CLR_X1, CLR_Y1, CLR_X2, CLR_Y2, SOLID_LINE, NORM_WIDTH, BLACK, SOLID_FILL, BLACK, MPIXEL)
      
      // Display Error Message
      gDrawText(91, DEF_MSG_COL, cErrMsg, SIMPLEX_FONT, 3, CFG_DMSG, MSCALE, CENTER_TEXT)

      tone(600,6) // Error sound
      
      while .T.
      
        // Clear the area by drawing a box in background color
        gDrawBox(CLR_X1, CLR_Y1, CLR_X2, CLR_Y2, SOLID_LINE, NORM_WIDTH, BLACK, SOLID_FILL, BLACK, MPIXEL)
              
        gDrawText(91, DEF_MSG_COL, cErrMsg, SIMPLEX_FONT, 3, CFG_DMSG, MSCALE, CENTER_TEXT)        

        #ifdef T_KEYBOARD
          cKey := input(T_KEYBOARD)
        #else
          cKey := input()
        #endif  
        if cKey != CLR .and. !IS_KEYCHANGE(cKey)

          // Clear the area by drawing a box in background color
          gDrawBox(CLR_X1, CLR_Y1, CLR_X2, CLR_Y2, SOLID_LINE, NORM_WIDTH, BLACK, SOLID_FILL, BLACK, MPIXEL)        
          
          gDrawText(91, DEF_MSG_COL, MSG_D031, SIMPLEX_FONT, 3, CFG_DMSG, MSCALE, CENTER_TEXT)          
          tone(600,6)
        else 
          exit
        endif
      enddo      
      KEY_STROKE_SOUND() 
      // enable the sound back
      set_key_sound(ON)
      // clr_input()
#ifdef DEF_DISP1X09
      DISPTEXTXY(0, 0, 1, 1, 0, 0, "         " )          
#endif      
  ENDIF
  
#ifdef DEF_GRAPHICS
      
#endif      


return nil

              
function Disp_Data(cTextdata)

#define DATA_X1 18
#define DATA_Y1 398.4
#define DATA_X2 620.8
#define DATA_Y2 420
 
#ifdef DEF_GRAPHICS        

   if empty(cTextData)
     gDrawBox(2, 82, 98, 89, BUTTON_UP_LINE,,, SOLID_FILL, CFG_DFILL, MSCALE, 4)         
     gDrawBox(DATA_X1, DATA_Y1, DATA_X2, DATA_Y2, SOLID_LINE, NORM_WIDTH, 15, SOLID_FILL, 15, MPIXEL, 4)     
   else       
     gDrawBox(DATA_X1, DATA_Y1, DATA_X2, DATA_Y2, SOLID_LINE, NORM_WIDTH, 15, SOLID_FILL, 15, MPIXEL, 4)
     gDrawText(22, 2, cTextData, SMALL_FONT, 8, BLACK )
   endif
   
#endif            

return nil

/*

FUNCTION PopBox( nLeft, nTop, nRight, nBottom, cBoxTitle )

  Usage : Display Pop-up Dialog Box
    Parm  : 
            <nLeft, nTop>      - upper-left corner of box
            <nRight, nBottom>  - lower-right corner of box
            <cBoxTitle>        - Dialog Box Title
                       
    Return: NIL

  LOCAL iBoxADJ                   // Box adjustment factor variable for BUTTON linestyle
  LOCAL iCenter                   // Coordinate variable to center Box Title

  // Convert scaled coordinates in terms of pixels
  nLeft  := ROUND(nLeft   * SCALE_X / SCR_SCALE, 0)
  nTop   := ROUND(nTop    * SCALE_Y / SCR_SCALE, 0)
  nRight := ROUND(nRight  * SCALE_X / SCR_SCALE, 0)
  nBottom:= ROUND(nBottom * SCALE_Y / SCR_SCALE, 0)
  
  // Calculate for Box border adjustments
  iBoxADJ := ROUND( SCALE_Y * ( SCR_SCALE / 6) / SCALE_X, 0)
 
  // Draw Button-Style BOX
  gDrawBox(nLeft, nTop, nRight, nBottom, BUTTON_UP_LINE,,, ;
           SOLID_FILL, 7, MPIXEL, 10)
  
  nTop    := nTop  + iBoxADJ
  iCenter := nLeft + ((nRight - nLeft) / 2)

  // Draw Box Title using TRIPLEX_FONT 3
  gDrawText(nTop, iCenter, cBoxTitle, ;
            TRIPLEX_FONT, 3, 15, MPIXEL, CENTER_TEXT)

  nLeft  := nLeft  + iboxADJ
  nRight := nRight - iboxADJ
  nTop   := nTop   + iboxADJ + gGrfxConfg(CHAR_HEIGHT_CFG)

  // Draw Box Title Line
  gDrawLine(nLeft, nTop, nRight, nTop, ;
            BUTTON_UP_LINE, NORM_WIDTH, 7, MPIXEL)

  nLeft += gGrfxConfg(CHAR_WIDTH_CFG)
  nTop  += gGrfxConfg(CHAR_HEIGHT_CFG)
  
  // Position graphics coordinates to next line 
  gGrfxSetNw(XMOVE_SET, nLeft)
  gGrfxSetNw(YMOVE_SET, nTop)
            
return nil
*/

*eof------------>
