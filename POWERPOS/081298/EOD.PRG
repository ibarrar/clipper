*
* System......... POWERPOS for Spectrum
* Program I.D.... eod.prg
* Description....

#include "file_acc.ch"
#include "message.ch"
#include "powerpos.ch"
#include "directry.ch"

#ifdef DEF_GRAPHICS
  #include "grfx_all.ch"
#endif

#define DEF_SCR_SWAP2 "AAAAAAAA.IMJ"


function end_of_day()
local status,lStatus := .T.
local cIndata := ""
local cOutdata := ""
local nAsk := 0
local cWindow
local afiles:={}

#ifdef ERASE_FMTRANS
  // check first if all the fm_transaction is done...
  if getFMF() == free_inquiry()  //.and. day(date()) == 13 no more pending

     // issue a fm_Trans reset function 
     status := file_access(FA_CMD_SRCHDEL, FA_PRM_ZERO, FA_FN_FMF,FA_FRAME_LEN, cOutData, @cIndata, GetServer_Path() )

     if status == NORMAL          
        updateFMF( 0 )
     endif   

  endif // else do not reset anything capitch !!!
#endif

  // display prompt for resetting of data....
  // or check first if resetting was already accomplish....

  if !ltr_reset() 

     DISPTEXTXY(1,1,0,0,1,1,MSG_D040)         
     DISPTEXTXY(2,1,0,0,2,1,"  YES/NO :    ")         
     
     cWindow := OpenWindow(20, 34, 78, 66,MSG_D040)
  
     gDrawText(49, 42, "PROCESS EOD ", DEFAULT_FONT, 2, CFG_DHLITE, MSCALE, CENTER_TEXT)
     gDrawText(55, 44, "REPORTS ?   ", DEFAULT_FONT, 2, CFG_DHLITE, MSCALE, CENTER_TEXT)
     
     MsgAreaDisp("Use Arrow keys then ENTER... ")  
     
     nAsk := aLookUp(50,62,{"YES","NO"})
      
     CloseWindow(cWindow)
     MsgAreaDisp(MSG_CLEAR)       
                
     if nAsk == 1
           DISPTEXTXY(2,1,0,0,2,1,"  YES/NO :YES ")                    
           if Sales_to_Server() // just redundantly send anyway...                       
              MsgAreaDisp("TERMINAL REPORT Please Wait ...")       
              Term_Report( .T. )
              MsgAreadisp("CASHIER REPORT WAIT.")
              String_Cash( .T. )
              fopen(Getreport_path()+"NUL.ID")
              if ferror() != 3
                 afiles:=directory("*.RPT")
                 aEval( afiles, { |e| ferase(e[F_NAME]) } )
              endif   
              MsgAreaDisp("End-Of-Day Reports Done....")
              HeyThere()
           endif              
     elseif nAsk == 2
        MsgAreaDisp("TERMINATE W/O RESET!")
        Tone(300,16)
     else   
        lStatus := .F.
     endif         

  endif
    
return lStatus

* eop 11/09/96 

