#include "config.ch"
#include "message.ch"

#ifdef DEF_GRAPHICS
  #include "grfx_all.ch"
#endif  

#define DISPLAY_COLOR RED

static cScrollBuff, nStartPos, lScrolling

function disp_init()
local nRetVal := 0

 cScrollBuff := config(POS_2X20_DISP2)+space(3)
 nStartPos   := 1
 lScrolling  := .T.

  // initialize the display graphics driver
#ifdef DEF_GRAPHICS
   
  if ( (nRetVal := gGraphInit(VGA, VGAHI)) == NORMAL )
  
    // initialize graphics function such as subtotal, receipt logo and pad
    //    
    DispStoreBMP("POWERPOS.BMP")

    Rcpt_Image("RCPTLOGO.BMP")
    
    Disp_BoldChar(0, "Total Amount")

  endif  
#endif

return nRetVal


function disp_clr()

 DISPTEXTXY(1,1,0,0,1,1,"                    ")
 DISPTEXTXY(2,1,0,0,2,1,"                    ")
#ifdef DEF_DISP4X20
 DISPTEXTXY(3,1,0,0,0,0,"                    ")
 DISPTEXTXY(4,1,0,0,0,0,"                    ")
#endif
   
 MsgAreaDisp()
 Disp_Data(chr(95))

return nil

function disp_welcome()
********************************************
local status

#ifdef DEF_DISP1X90
  // integrated customer display (1x9)
  status := DISPTEXTXY(0, 0, 1, 9, 0, 0, "0")
#endif  

#ifdef DEF_DISP2x20
  // additional customer display (2x20)
  status := DISPTEXTXY(0, 0, 0, 0, 1, 1, config(POS_2X20_DISP1))
#endif  
   
#ifdef DEF_DISP4X20
  // cashier display (4x20)
  status := DISPTEXTXY(1, 1, 0, 0, 0, 0, config(POS_4X20_DISP1))
  status := DISPTEXTXY(2, 1, 0, 0, 0, 0, config(POS_4X20_DISP2))
  status := DISPTEXTXY(3, 1, 0, 0, 0, 0, config(POS_4X20_DISP3))
  status := DISPTEXTXY(4, 1, 0, 0, 0, 0, config(POS_4X20_DISP4))   
#endif
   
return nil 

function Disp_Mode()
local cText := ""
    do case 
       case keylock() == 0 // OFF MODE
            DISPTEXTXY (0, 0, 0, 0, 1, 1, MSG_0004)   
            DISPTEXTXY (0, 0, 0, 0, 2, 1, padc("CLOSED",20))
            cText := "CLOSED"
       case keylock() == 1 // REG MODE
            DISPTEXTXY (0, 0, 0, 0, 1, 1,pad(config(POS_2X20_DISP1),20))
       case keylock() == 2 // Secret mode
            DISPTEXTXY (0, 0, 0, 0, 1, 1,"MGR                 ")                   
            DISPTEXTXY (0, 0, 0, 0, 2, 1,"                    ")              
            cText := "MGR-MODE"
       case keylock() == 3 // X-mode
            DISPTEXTXY (0, 0, 0, 0, 1, 1,"X                   ")       
            DISPTEXTXY (0, 0, 0, 0, 2, 1,"                    ")            
            cText := "X-MODE"
       case keylock() == 4 // Z-mode
            DISPTEXTXY (0, 0, 0, 0, 1, 1,"Z                   ")              
            DISPTEXTXY (0, 0, 0, 0, 2, 1,"                    ")            
            cText := "Z-MODE"

    endcase
#ifdef DEF_GRAPHICS    
    //Erase first
    gDrawText(56,5,repl(chr(219),12), SMALL_FONT,3,LIGHTGRAY) 
    //Then Draw   
    gDrawText(56,5, cText, SMALL_FONT,3,DISPLAY_COLOR) 
#endif    
return nil

function Disp_Comm(lVar)
#ifdef DEF_GRAPHICS
 gDrawText(56,130,if(lVar,repl(chr(219),12),"OFF-LINE"),;
           SMALL_FONT,3,if(lVar,LIGHTGRAY,DISPLAY_COLOR) ) 
#endif           
 if !lVar
   MsgAreaDisp("NETWORK OFFLINE.WAIT")                 
 endif  
return nil

function ScrollDisp()
local cDispBuff,nSecondPos
  
  if lScrolling .and. !empty(cScrollBuff) 
     cDispBuff := subs(cScrollBuff,nStartPos,20)

     if len(cDispBuff) < 20
        nSecondPos := 20-len(cDispBuff)
        cDispBuff += subs(cScrollBuf,1,nSecondPos)
     endif
       
     DISPTEXTXY(3, 1, 0, 0, 2, 1, cDispBuff)

     if (nStartPos < len(cScrollBuff))     
        nStartPos ++
     elseif nSecondPos >= 19
        nStartPos := 1      
     endif
        
  endif
return nil

function ScrollOff()
 lScrolling := .F.
return lScrolling

function ScrollON(cVar)
 if !empty(cVar)
      cScrollBuff := cVar+space(3)
 endif     
 nStartPos := 1
 lScrolling := .T.
return lScrolling 
