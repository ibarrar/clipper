#include "message.ch"
#include "grfx_all.ch"

function display_msg(cMsg1,cMsg2,cMsg3,cMsg4)
local cWindow

  cMsg1 := if(empty(cMsg1),"",cMsg1)
  cMsg2 := if(empty(cMsg2),"",cMsg2)
  cMsg3 := if(empty(cMsg3),"",cMsg3)
  cMsg4 := if(empty(cMsg4),"",cMsg4)  

  cWindow := OpenWindow(20, 34, 78, 66,"IMPORTANT MESSAGE")
  
  gDrawText(14, 0, cMsg1, DEFAULT_FONT, 2, 15, MFIX, CENTER_TEXT)
  gDrawText(15, 0, cMsg2, DEFAULT_FONT, 2, 15, MFIX, CENTER_TEXT)
  gDrawText(16, 0, cMsg3, DEFAULT_FONT, 2, 15, MFIX, CENTER_TEXT)
  gDrawText(17, 0, cMsg4, DEFAULT_FONT, 2, 15, MFIX, CENTER_TEXT)

  ErrorDisp(MSG_D031)  
      
  CloseWindow(cWindow)

return nil

function DispStatus(cText)

#ifdef DEF_GRAPHICS
  gClrDevice()       // Clear entire screen

  // Draw Box
  gDrawBox(15, 40, 85, 60, BUTTON_UP_LINE,,, SOLID_FILL, CFG_DFILL, MSCALE, 10)

  // Display Text
  gDrawText(7, 0, cText, TRIPLEX_FONT, 4, CFG_DHLITE, MFIX, CENTER_TEXT)

#else
  alert("*** "+cText+" ***")
#endif

return nil 
