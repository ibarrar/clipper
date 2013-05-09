#include "pfl_clip.ch"
#include "powerpos.ch"
#include "keymap.ch"
#include "spec_key.ch"
#include "message.ch"
#include "config.ch"

#ifdef DEF_GRAPHICS
  #include "grfx_all.ch"
#endif

#define INKEY_WAIT_VAL 0.175

#define NO_OF_SECONDS  15 // default for idle time...

static last_pos 
static key_pos  
static cScanned 
static lTransact := .F.

// for alarm
static lAlarm,cAlarmDisp
static lKeySound,lScanned

#ifdef MIDDAY_ITEM_UPDATE
  static idle_time
#endif  

static lServer_Mode := .T.

function input_init()
local status

  key_pos := DEFAULT_KEY_POS
#ifdef DEF_KEY_LOCK  
  while (( status := CHK_CKLOCK(@key_pos)) != NORMAL )
    ? "Error in Key Lock "
    ?? status
    DISPTEXTXY(4,1,0,0,2,1,"ERROR KEYLOCK STATUS") 
    tone(600,3)    
  enddo      
#endif  
  last_pos := key_pos 

  lServer_Mode := (config(POS_SERVER_MD)=="YES")  
  
#ifdef MIDDAY_ITEM_UPDATE
  idle_time := val(config(POS_IDLE_TIME))

  if idle_time < NO_OF_SECONDS
     idle_time := NO_OF_SECONDS
  endif   
#endif  
  
  cScanned := ""

   // scanned status default to false
   lScanned :=  .F.
   
   // set alarm sound and display to init values
   cAlarmDisp := ""
   lAlarm := .F.
   lKeySound := .T.
#ifdef KEY_SOUND
   sound_on()
#endif     
               
return nil

function Input()
local status,nRetVal,i 

#ifdef MIDDAY_ITEM_UPDATE
local nSeconds := seconds()
#endif

#ifdef DEF_SCANNER
local nBRead,cSBuffer
#endif

/*
  if nLev != 0
     DISPTEXTXY(4,1,0,0,0,0,"PL#"+str(nLev,1))
  endif    
*/  

#ifdef DEF_KEY_LOCK        
    while (( status := CHK_CKLOCK(@key_pos)) != NORMAL ) 
        ? "KEYLOCK STATUS : " 
        ?? status  
    enddo  
#endif    

  while key_pos == last_pos  

    if ((i := InKey(INKEY_WAIT_VAL)) != 0  )
//       while inkey() != 0 ; inkey(0) ; enddo   
       nRetVal := getkeyval(i)
       if nRetVal == STEP_REC
         A_RJS_FEED(1, 0, 0, 5)
       elseif nRetVal == STEP_JOURNAL 
         A_RJS_FEED(0, 1, 0, 5)            
       else        
         if nRetVal  == PLU
           lScanned := .F.
         endif    
         exit    
       endif  
    endif

#ifdef DEF_SCANNER   
    nBread := 0 
    cSBuffer := "XXXXXXXXXXXXXXXXXXXX"
    status := READ_SCAN( @nBRead, @cSBuffer, .T. )

    if (status == NORMAL) 
      	cScanned := subs(cSBuffer,1,nBRead )
        nRetVal := SCANNER
        lScanned := .T.
        putkeyval(nRetVal)
/*
      	? "cScanned :"
      	?? cScanned
       	?? " Len :"
       	?? nBRead
*/                
         exit
    elseif status == SCAN_ERR
        MsgAreaDisp("Scanner Data check error, Pls. Try Again")
    endif     
#endif        

    if chk_jrnal() == PAPER_ERR
       while chk_jrnal() == PAPER_ERR
          MsgAreaDisp("Receipt/Journal Paper Error")
          tone(600,6) // Error sound
          MsgAreaDisp("Fix Journals and Press any to continue...")
          inkey(0)
          clearkeys()
          MsgAreaDisp()
       enddo
    endif

    ScrollDisp()
#ifdef MIDDAY_ITEM_UPDATE
    if lServer_Mode .and. ((seconds() - nSeconds) > idle_time ) .and. !lTransact 
       if lPending() 
*           ? "Going for one..."
           GoforOne()
       else
           nSeconds += 10         
       endif  
    endif
#endif       

#ifdef DEF_KEY_LOCK    
    while (( status := CHK_CKLOCK(@key_pos)) != NORMAL ) 
        ? "KEYLOCK STATUS : " 
       ?? status         
    enddo  
#endif    

    if lAlarm
       tone(600,10)
       MsgAreaDisp(cAlarmDisp)
    endif
    
  enddo  

  // The priority is KEY_LOCK test for this first
  if (key_pos != last_pos)
     last_pos := key_pos 
     nRetVal  := key_pos + CONFIG_KEY_LEN + 1
     putkeyval(nRetVal)
  endif
                               
return nRetval

/*
function clr_input()
  array_ := {}
return nil
*/

function SetAlarm(cVar)
if empty(cVar)
  lAlarm := .F.
else
  cAlarmDisp := cVar
  lAlarm := .T.
endif
return lAlarm

function KeyLock(nVar)

if !empty(nVar)
   key_pos := nVar 
   
/*
#ifdef DEF_KEY_LOCK
local status
  while (( status := CHK_CKLOCK(@key_pos)) != NORMAL )
    ? "Error in Key Lock "
    ?? status
  enddo          
#endif 
*/

#ifndef DEF_KEY_LOCK 
  do case 
     case is_alpha() == KEY_A
       key_pos := KEY_LOCK_POS0
     case is_alpha() == KEY_B
       key_pos := KEY_LOCK_POS1
     case is_alpha() == KEY_C
       key_pos := KEY_LOCK_POS3
     case is_alpha() == KEY_D
       key_pos := KEY_LOCK_POS4
  endcase    
#endif

endif

return key_pos

function set_key_sound(lVar)
 if lVar != NIL
    lKeySound := lVar
 endif

#ifdef KEY_SOUND 
 if !lKeySound
    sound_off()
 else
    sound_on()   
 endif   
#endif
 
return lKeySound

function ReadData(n1Row,n1Col,n2Row,n2Col,n3Row,n3Col, bBlock, nLen, cMsg, c1st)
local cKey,cData := ""
local cKeyBuff := ""
local cDispBuff := "_"

  if valtype(c1st) == "N"
     if !empty(cData := is_number( c1st ))
     elseif !empty(cData := is_alpha( c1st ))
     endif    
     cKeyBuff := cData
     cDispBuff := cKeyBuff + if (len(cKeyBuff) < nLen,"_","")
     
#ifdef DEF_GRAPHICS
     Disp_Data(cDispBuff)
#endif    
  
    // cashier display (4x20)
    // customer display (2x20)
    DISPTEXTXY(n1Row, n1Col, 0, 0, n3Row, n3Col, pad(cDispBuff,nLen))
    
    // customer display (1x09) 
    DISPTEXTXY(0, 0, n2Row, n2Col, 0, 0, space(9-len(cKeyBuff)+if("."$cKeyBuff,1,0))+cDispBuff)    
  endif
    
/*
#ifdef DEF_GRAPHICS
    Disp_Data("_")
#endif    
*/
 // cashier display (4x20)
 // customer display (2x20)
 DISPTEXTXY(n1Row, n1Col, 0, 0, n3Row, n3Col, pad(cDispBuff,nLen))
 
 // customer display (1x09) 
 DISPTEXTXY(0, 0, n2Row, n2Col, 0, 0, "         ")

 while cKey != ENTER 

    cKey := input()
    
    do case
       case IS_KEYCHANGE(cKey)          
#ifdef KEY_SOUND       
          Sound_off()
#endif          
#ifdef DEF_GRAPHICS
          Disp_Data()  // clear data display area          
#endif          
          Disp_Mode()                    
          if nvr_nSUBtotal() != 0
            SetAlarm(MSG_D011)
          else
            // don't allow position one three and four 
            SetAlarm(MSG_D012)
          endif  
          while keylock() == KEY_LOCK_POS0 .or. keylock() == KEY_LOCK_POS3 .or. keylock() == KEY_LOCK_POS4
             input()
          enddo
          SetAlarm()
          Disp_Mode()          
          
#ifdef DEF_GRAPHICS          
          Disp_Data(cKeyBuff)
#endif          
          MsgAreaDisp(cMsg) // clear display area
#ifdef KEY_SOUND          
          Sound_On()
#endif          
       case cKey == CLR
          if empty(cKeyBuff)
             ErrorDisp(MSG_D018)
             exit
          endif
          cKeyBuff   := ""
       case Eval(bBlock,cKey)
          do case
             case !empty(cData := is_number())
             case !empty(cData := is_alpha())
             case !empty(cData := cDeptCode())
          endcase             
          if len(cKeyBuff) < nLen
             cKeyBuff += cData
          endif      
       case cKey == BACK_SPACE
          cKeyBuff := subs(cKeyBuff,1,len(cKeyBuff)-1)
       case cKey == SCANNER
          cKeyBuff := subs(scandata(),1,nLen)
       case cKey == ENTER
       otherwise
          if !empty(cMsg)
             ErrorDisp(MSG_D006) // probable key sequence error   
             MsgAreaDisp(cMsg)  // restore previous message
          endif   
    endcase
    cDispBuff := cKeyBuff + if (len(cKeyBuff) < nLen,"_","")
#ifdef DEF_GRAPHICS
    Disp_Data(cDispBuff)
#endif    
  
    // cashier display (4x20)
    // customer display (2x20)
    DISPTEXTXY(n1Row, n1Col, 0, 0, n3Row, n3Col, pad(cDispBuff,nLen))
    
    // customer display (1x09) 
    DISPTEXTXY(0, 0, n2Row, n2Col, 0, 0, space(9-len(cKeyBuff)+if("."$cKeyBuff,1,0))+cDispBuff)    

  enddo
  
/*
#ifdef DEF_GRAPHICS  
  Disp_Data()
#endif  
*/ 

return cKeyBuff


/*function ReadDate(n1Row,n1Col,n2Row,n2Col)
local cKey,cData
local cKeyBuff := ""
local date_today := (UPPER(subs(CMONTH(date()),1,3))+subs(dtoc(date()),7,2))
local cDispBuff := date_today
local aMonth := { "JAN", ;
                  "FEB", ;
                  "MAR", ;
                  "APR", ;
                  "MAY", ;
                  "JUN", ;
                  "JUL", ;
                  "AUG", ;
                  "SEP", ;
                  "OCT", ;
                  "NOV", ;
                  "DEC" }
local lMonth := .F.                  

 // cashier display (4x20)
 // customer display (2x20)
 DISPTEXTXY(n1Row, n1Col, 0, 0, n2Row, n2Col, "_")
 
 while .T.

    cKey := input()
    
    do case
       case IS_KEYCHANGE(cKey)          
#ifdef KEY_SOUND       
          Sound_off()
#endif          
#ifdef DEF_GRAPHICS
          Disp_Data()  // clear data display area          
#endif          
          Disp_Mode()                    
          if nvr_nSUBtotal() != 0
            SetAlarm(MSG_D011)
          else
            // don't allow position one three and four 
            SetAlarm(MSG_D012)
          endif  
          while keylock() == KEY_LOCK_POS0 .or. keylock() == KEY_LOCK_POS3 .or. keylock() == KEY_LOCK_POS4
             input()
          enddo
          SetAlarm()
          Disp_Mode()          
          
#ifdef DEF_GRAPHICS          
          Disp_Data(cKeyBuff)
#endif          
          MsgAreaDisp("ENTER EXPIRY DATE...") // clear display area
#ifdef KEY_SOUND          
          Sound_On()
#endif                    
      case cKey == CLR
          if empty(cKeyBuff)
             exit
          endif
          cKeyBuff   := ""
          lMonth := .F.
       case !empty(is_number()) .and. cKey != KEY_PERIOD
          if lMonth
             cData := is_number()         
             if len(cKeyBuff) < 5
               cKeyBuff += cData
             endif      
          else   
             ErrorDisp("USE LETTER FOR MONTH") // probable key sequence error   
             MsgAreaDisp("ENTER EXPIRY DATE...")
          endif   
       case !empty((cData := is_alpha()))
          if !lMonth
             if len(cKeyBuff) < 3
                cKeyBuff += cData
             endif
             if len(cKeyBuff) == 3
                if aScan(aMonth,cKeyBuff) > 0
                   lMonth := .T.
                else
                   ErrorDisp(  "INVALID MONTH FORMAT")   
                   MsgAreaDisp("ENTER EXPIRY DATE...")
                   cKeyBuff := ""
                endif   
             endif 
          else   
             ErrorDisp("USE NUMERIC FOR YEAR") // probable key sequence error   
             MsgAreaDisp("ENTER EXPIRY DATE...")             
          endif                         
       case cKey == ENTER          
          ? "DATA compared to :"
          ?? date_today
          if len(cKeyBuff) == 5
             ? "Value of entry : " 
             ??  (val(subs(cKeyBuff,4,2))+(ascan(aMonth,subs(cKeyBuff,1,3))*0.1))
             ? "Value of today : " 
             ??  (val(subs(date_today,4,2))+(ascan(aMonth,subs(date_today,1,3))*0.1)) 
             
             if (val(subs(cKeyBuff,4,2))+(ascan(aMonth,subs(cKeyBuff,1,3))*0.1)) > ;
                (val(subs(date_today,4,2))+(ascan(aMonth,subs(date_today,1,3))*0.1))
                exit
             endif
          endif     
          
          MsgAreaDisp("INVALID DATE !!!    ")
          cKeyBuff := ""
          lMonth := .F.
          Beep_2()
          
       otherwise
          ErrorDisp(MSG_D006) // probable key sequence error   
          MsgAreaDisp("ENTER EXPIRY DATE...")
    endcase    
    cDispBuff := cKeyBuff + if (len(cKeyBuff) < 5,"_","")
#ifdef DEF_GRAPHICS
    Disp_Data(cDispBuff+"_")
#endif    
  
    // cashier display (4x20)
    // customer display (2x20)
    DISPTEXTXY(n1Row, n1Col, 0, 0, n2Row, n2Col, cDispBuff+space(5-len(cKeyBuff)))
    
  enddo
 
return cKeyBuff*/

function RegMode()
return if(lScanned,"1","0")

function Scandata()
local cRetVal := ""

   if !empty(cScanned) 
      cRetVal := cScanned
      cScanned := ""
   endif  
     
return cRetVal

function IS_KEYCHANGE( cKey )
return (cKey > CONFIG_KEY_LEN .and. cKey < CONFIG_KEY_LEN + 6 )

function isServer_mode(lVal)
  if valtype(lVal) == "L"
     lServer_Mode := lVal
  endif
return lServer_Mode

function isTransact(lVar)
local dDate 

 if valtype(lVar) == "L"
     lTransact := lVar
 endif  
 
return lTransact

#ifdef DEF_GRAPHICS
 function Grfx_Data(n1Row,n1Col,n2Row,n2Col,n3Row,n3Col, bBlock, nLen, cMsg, pass_code)
 local cKey,cData
 local cKeyBuff := ""
 local cDispBuff := ""

 while cKey != ENTER 

    cKey := input()
    
    do case
       case IS_KEYCHANGE(cKey)          
#ifdef KEY_SOUND       
          Sound_off()
#endif          
          Disp_Mode()                    
          if nvr_nSUBtotal() != 0
            SetAlarm(MSG_D011)
          else
            // don't allow position one three and four 
            SetAlarm(MSG_D012)
          endif  
          while keylock() == 0 .or. keylock() == 3 .or. keylock() == 4
             input()
          enddo
          SetAlarm()
          Disp_Mode()          
          
          MsgAreaDisp(cMsg) // clear display area
#ifdef KEY_SOUND          
          Sound_On()
#endif          
       case cKey == CLR
          if empty(cKeyBuff)
             exit
          endif
          if pass_code == 0
             gClearTo(46, 48, 75, 51, 7)
             gDrawText(17, 33, chr(95), SMALL_FONT, 6, 0)
          elseif pass_code == 1
             gClearTo(46, 51, 75, 54, 7)
             gDrawText(18, 33, chr(95), SMALL_FONT, 6, 0)
          elseif pass_code == 2
             gClearTo(46, 54, 75, 57, 7)
             gDrawText(19, 33, chr(95), SMALL_FONT, 6, 0)
          elseif pass_code == 3
             gClearTo(46, 57, 75, 60, 7)
             gDrawText(20, 33, chr(95), SMALL_FONT, 6, 0)
          elseif pass_code == 4   
             gClearTo(46, 60, 75, 63, 7)
             gDrawText(21, 33, chr(95), SMALL_FONT, 6, 0)
          elseif pass_code == 5   
             gClearTo(46, 63, 75, 66, 7)
             gDrawText(22, 33, chr(95), SMALL_FONT, 6, 0)
          endif     
          cKeyBuff   := ""
       case Eval(bBlock,cKey)
          do case
             case !empty(cData := is_number( cKey ))
             case !empty(cData := is_alpha( cKey ))
             case !empty(cData := cDeptCode( cKey ))
          endcase             
          if len(cKeyBuff) < nLen
             cKeyBuff += cData
          endif      
          if pass_code == 0
             gClearTo(46, 48, 75, 51, 7)
             gDrawText(17, 33, cKeyBuff + chr(95), SMALL_FONT, 6, 0)
          elseif pass_code == 1
             gClearTo(46, 51, 75, 54, 7)
             gDrawText(18, 33, cKeyBuff + chr(95), SMALL_FONT, 6, 0)
          elseif pass_code == 2
             gClearTo(46, 54, 75, 57, 7)
             gDrawText(19, 33, cKeyBuff + chr(95), SMALL_FONT, 6, 0)
          elseif pass_code == 3
             gClearTo(46, 57, 75, 60, 7)
             gDrawText(20, 33, cKeyBuff + chr(95), SMALL_FONT, 6, 0)
          elseif pass_code == 4   
             gClearTo(46, 60, 75, 63, 7)
             gDrawText(21, 33, cKeyBuff + chr(95), SMALL_FONT, 6, 0)
          elseif pass_code == 5
             gClearTo(46, 63, 75, 66, 7)
             gDrawText(22, 33, cKeyBuff + chr(95), SMALL_FONT, 6, 0)             
          endif     
       case cKey == BACK_SPACE
          cKeyBuff := subs(cKeyBuff,1,len(cKeyBuff)-1)
          if pass_code == 0
             gClearTo(46, 48, 75, 51, 7)
             gDrawText(17, 33, cKeyBuff + chr(95), SMALL_FONT, 6, 0)
          elseif pass_code == 1
             gClearTo(46, 51, 75, 54, 7)
             gDrawText(18, 33, cKeyBuff + chr(95), SMALL_FONT, 6, 0)
          elseif pass_code == 2
             gClearTo(46, 54, 75, 57, 7)
             gDrawText(19, 33, cKeyBuff + chr(95), SMALL_FONT, 6, 0)
          elseif pass_code == 3
             gClearTo(46, 57, 75, 60, 7)
             gDrawText(20, 33, cKeyBuff + chr(95), SMALL_FONT, 6, 0)
          elseif pass_code == 4   
             gClearTo(46, 60, 75, 63, 7)
             gDrawText(21, 33, cKeyBuff + chr(95), SMALL_FONT, 6, 0)
          elseif pass_code == 5   
             gClearTo(46, 63, 75, 66, 7)
             gDrawText(22, 33, cKeyBuff + chr(95), SMALL_FONT, 6, 0)
          endif     
       case cKey == ENTER
       otherwise
          if !empty(cMsg)
             ErrorDisp(MSG_D006) // probable key sequence error   
             MsgAreaDisp(cMsg)  // restore previous message
          endif   
    endcase
    cDispBuff := cKeyBuff + if (len(cKeyBuff) < nLen,"_","")

    // cashier display (4x20)
    // customer display (2x20)
    DISPTEXTXY(n1Row, n1Col, 0, 0, n3Row, n3Col, cDispBuff+space(nLen-len(cKeyBuff)-1))
    
    // customer display (1x09) 
    DISPTEXTXY(0, 0, n2Row, n2Col, 0, 0, space(9-len(cKeyBuff)+if("."$cKeyBuff,1,0))+cDispBuff)    

enddo
 
return cKeyBuff

function Grfx_Date(n1Row,n1Col,n2Row,n2Col, pass_code)
local cKey,cData
local cKeyBuff := ""
local date_today := (UPPER(subs(CMONTH(date()),1,3))+subs(dtoc(date()),7,2))
local cDispBuff := date_today
local aMonth := { "JAN", ;
                  "FEB", ;
                  "MAR", ;
                  "APR", ;
                  "MAY", ;
                  "JUN", ;
                  "JUL", ;
                  "AUG", ;
                  "SEP", ;
                  "OCT", ;
                  "NOV", ;
                  "DEC" }
local lMonth := .F.                  

 // cashier display (4x20)
 // customer display (2x20)
 DISPTEXTXY(n1Row, n1Col, 0, 0, n2Row, n2Col, "_")
 
 while .T.

    cKey := input()
    
    do case
       case IS_KEYCHANGE(cKey)          
#ifdef KEY_SOUND       
          Sound_off()
#endif          
#ifdef DEF_GRAPHICS
          Disp_Data()  // clear data display area          
#endif          
          Disp_Mode()                    
          if nvr_nSUBtotal() != 0
            SetAlarm(MSG_D011)
          else
            // don't allow position one three and four 
            SetAlarm(MSG_D012)
          endif  
          while keylock() == 0 .or. keylock() == 3 .or. keylock() == 4
             input()
          enddo
          SetAlarm()
          Disp_Mode()          
          
          MsgAreaDisp("ENTER EXPIRY DATE...") // clear display area
#ifdef KEY_SOUND          
          Sound_On()
#endif                    
      case cKey == CLR
          if empty(cKeyBuff)
             exit
          endif
          if pass_code == 1
             gClearTo(46, 51, 75, 54, 7)
             gDrawText(18, 33, chr(95), SMALL_FONT, 6, 0)
          elseif pass_code == 2
             gClearTo(46, 54, 75, 57, 7)
             gDrawText(19, 33, chr(95), SMALL_FONT, 6, 0)
          endif     
          cKeyBuff   := ""
          lMonth := .F.
       case !empty(is_number(cKey)) .and. cKey != KEY_PERIOD
          if lMonth
             cData := is_number( cKey )         
             if len(cKeyBuff) < 5
               cKeyBuff += cData
             endif      
          else   
             ErrorDisp("USE LETTER FOR MONTH") // probable key sequence error   
             MsgAreaDisp("ENTER EXPIRY DATE...")
          endif   
          if pass_code == 1
             gClearTo(46, 51, 75, 54, 7)
             gDrawText(18, 33, cKeyBuff + chr(95), SMALL_FONT, 6, 0)
          elseif pass_code == 2
             gClearTo(46, 54, 75, 57, 7)
             gDrawText(19, 33, cKeyBuff + chr(95), SMALL_FONT, 6, 0)
          endif     
       case !empty((cData := is_alpha(cKey)))
          if !lMonth
             if len(cKeyBuff) < 3
                cKeyBuff += cData
              if pass_code == 1
                 gClearTo(46, 51, 75, 54, 7)
                 gDrawText(18, 33, cKeyBuff + chr(95), SMALL_FONT, 6, 0)
              elseif pass_code == 2
                 gClearTo(46, 54, 75, 57, 7)
                 gDrawText(19, 33, cKeyBuff + chr(95), SMALL_FONT, 6, 0)
              endif                     
             endif
             if len(cKeyBuff) == 3
                if aScan(aMonth,cKeyBuff) > 0
                   lMonth := .T.
                else
                   ErrorDisp(  "INVALID MONTH FORMAT")   
                   MsgAreaDisp("ENTER EXPIRY DATE...")
                   cKeyBuff := ""
                 if pass_code == 1
                   gClearTo(46, 51, 75, 54, 7)
                   gDrawText(18, 33, chr(95), SMALL_FONT, 6, 0)
                 elseif pass_code == 2
                   gClearTo(46, 54, 75, 57, 7)
                   gDrawText(19, 33, chr(95), SMALL_FONT, 6, 0)
                 endif     
                endif   
             endif 
          else   
             ErrorDisp("USE NUMERIC FOR YEAR") // probable key sequence error   
             MsgAreaDisp("ENTER EXPIRY DATE...")             
          endif                         
       case cKey == ENTER          
          ? "DATA compared to :"
          ?? date_today
          if len(cKeyBuff) == 5
             ? "Value of entry : " 
             ??  (val(subs(cKeyBuff,4,2))+(ascan(aMonth,subs(cKeyBuff,1,3))*0.1))
             ? "Value of today : " 
             ??  (val(subs(date_today,4,2))+(ascan(aMonth,subs(date_today,1,3))*0.1)) 
             
             if (val(subs(cKeyBuff,4,2))+(ascan(aMonth,subs(cKeyBuff,1,3))*0.1)) > ;
                (val(subs(date_today,4,2))+(ascan(aMonth,subs(date_today,1,3))*0.1))
                exit
             endif
          endif     
          
          MsgAreaDisp("INVALID DATE !!!    ")
          cKeyBuff := ""
          lMonth := .F.
          Beep_2()
          
       otherwise
          ErrorDisp(MSG_D006) // probable key sequence error   
          MsgAreaDisp("ENTER EXPIRY DATE...")
    endcase    
    cDispBuff := cKeyBuff + if (len(cKeyBuff) < 5,"_","")
  
    // cashier display (4x20)
    // customer display (2x20)
    DISPTEXTXY(n1Row, n1Col, 0, 0, n2Row, n2Col, cDispBuff+space(5-len(cKeyBuff)))
    
  enddo
 
return cKeyBuff

#endif

*eof()->


