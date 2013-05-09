#include "pfl_clip.ch"
#include "printctl.ch"
#include "keymap.ch"
#include "spec_key.ch"
#include "powerpos.ch"
#include "message.ch"
#include "cashier.ch"
#include "config.ch"
#include "file_Acc.ch"

#ifdef DEF_GRAPHICS
  #include "grfx_all.ch"
#endif

function SignOn()
local lRetVal := .F.
local cBuffer := ""
local cKeyBuff := "",cDispBuff := ""
local cKey := 0, cData := ""
local cCashpath 
local cCashCode 
local cCashName
local cIndata
local cOutData
local status
local cPosUser
local cTime := strtran(time(),":","")

  offline()
  
  // is the cashier floating or not
  if config(POS_FLOATING) != "FLOATING" .or. !isServer_Mode()
      cCashPath := GetLocal_Path()
  else
      cCashPath := GetCentral_Path()
  endif        
  
  scrollOff() 
  disp_clr()
  
#ifdef DEF_GRAPHICS  
  Disp_Data("_")
#endif  

  DISPTEXTXY (2, 11, 0, 0, 2, 9, "_           ")

  // get data input from keyboard...
  disp_ready()
  while lRetVal == .F. .and. keylock() == KEY_LOCK_POS1

    cKey := input()

    do case
       case cKey==CLR .and. empty(cKeyBuff) .or. IS_KEYCHANGE(cKey)
          Disp_Data()
          exit
       case !empty(cData := is_number(@cKey ))
          if cData != "." .and. len(cKeyBuff) < 6
             cKeyBuff += cData
          endif      
       case cKey == BACK_SPACE
          cKeyBuff := subs(cKeyBuff,1,len(cKeyBuff)-1)
       case cKey == CLR
          cKeyBuff := ""   
       case cKey == ENTER
          if len(cKeyBuff) == 6  // check if data entry is valid and acceptable...
            
            // seek cashier file thru file access...
            // Allocate the would be needed space
            cInData  := space(FA_SZ_CSH)
            cOutData := subs(cKeyBuff,1,3)
            
            status := file_access(FA_CMD_SRCHGET,FA_PRM_ZERO,FA_FN_CSH,FA_SZ_CSH,cOutdata,@cIndata,cCashPath)
            
            ? "Status file access :" + str(status)           
            ? "Path : " + cCashPath

            if status == NORMAL 
               if subs(cIndata,CASH_CODE_OFF+3,3) == subs(cKeyBuff,4,3)
                  // now check if the floating cashier is on and 
                  // the cashier is used other than this machine
                  cPosUser := subs(cIndata,CASH_POSNO_OFF,CASH_POSNO_LEN)
                  if cPosUser == "0000" .or. cPosUser == config(POS_TERM_NUM) // means available...
                       // Must set the POS number of cashier to this machine
                       cOutData := subs(cIndata,CASH_CODE_OFF,26)
                       cOutData += cTime // replace the sign on register
                       cOutData += subs(cIndata,CASH_TIME2_OFF,CASH_TIME2_LEN)
                       cOutData += padl(config(POS_TERM_NUM),4,"0")
                       cOutData += subs(cIndata,CASH_RSRVD_OFF,CASH_RSRVD_LEN)
                       cOutData += chr(13)+chr(10)
                       ? "Data to write :"+cOutData
                       file_access(FA_CMD_SRCHPUT,FA_PRM_ZERO,FA_FN_CSH,FA_SZ_CSH,cOutdata,@cIndata,cCashPath) 
                       lRetVal := .T.                       
                       cCashCode := subs(cIndata,CASH_CODE_OFF,CASH_CODE_LEN)
                       cCashName := UPPER(subs(cIndata,CASH_NAME_OFF,CASH_NAME_LEN))
                       exit                       
                  else
                       BEEP_3() 
                       Display_Msg("FCASHIER CODE : "+subs(cKeyBuff,1,3)+" ",;
                                   "ALREADY USED AT "+cPosUser,;
                                   "SIGN_ON DISALLOWED !")
                         ErrorDisp(MSG_D031)    
                       
                       
                       cKeyBuff := ""
                       disp_clr()                       
                       disp_ready()
                  endif 
               else
                  ErrorDisp(MSG_D003)
                  disp_ready()
                  cKeyBuff :=  subs(cKeyBuff,1,3)                  
               endif                                                            
            elseif status == 4 .or. status == 1 // Use local if no floating or network error...   
               // try to locate the cashier code in the local 
               // cashier file
               cIndata :=  seek_cash(cKeyBuff)
               if !empty(cIndata)
                  lRetVal := .T.
                  cCashCode := subs(cIndata,CS_CODE_OFF,CS_SECR_LEN+CS_CODE_LEN)
                  cCashName := subs(cIndata,CS_NAME_OFF,CS_NAME_LEN)
                  exit
               else
                 cKeyBuff := ""
                 ErrorDisp(MSG_D004)
                 disp_ready()
               endif                 
            else    
               cKeyBuff := ""
               ErrorDisp("Error Seeking Cashier:"+str(status))                  
               disp_ready()            
            endif                  
          else  
            ErrorDisp(MSG_D005)
            disp_ready()
            ckeyBuff := ""
          endif                             
       otherwise
          ErrorDisp(MSG_D006) // Sequence error 
          disp_ready()
    endcase         
       
    cDispBuff := subs(cKeyBuff,1,3)+repl("*",min(len(cKeyBuff)-3,3)) + if(len(cKeyBuff) < 6,"_","")
    DISPTEXTXY (2, 11, 0, 0, 2, 9, "      " )   // I use more constants to 
    DISPTEXTXY (2, 11, 0, 0, 2, 9, cDispBuff)   // make it fast
    Disp_Data(cDispBuff)
  enddo

  if lRetVal 
      // this displays the name of cashier in the disp area
      // Disp_Data(UPPER(subs(cIndata,CASH_NAME_OFF,CASH_NAME_LEN)),DISP_CENTER)

      nvr_cCashCode(cCashCode)
      nvr_cCashName(cCashName)
/*      
#ifndef DEBUG      
      A_RJS_PRNT(1, 0, 0, padc("CASHIER SIGN ON",32), 0)      
      prnt_end()
#endif      
*/
      BEEP_1()
      // print on journal that cashier has sign on...
      // date, time, trans. no., cashier code, branch, etc...
      A_PRT_ESC(NORMAL_12)

      // check if training mode...
      if nvr_lTRNG_Mode()
         A_RJS_PRNT(0, 1, 0, "**** TRAINING  MODE ****" + chr(10), 0)
      endif

      cBuffer := padl(nvr_nTrans(),6,"0") + " " + cDispBuff +  " " + ;
                 substr(dtoc(date()), 1, 2) + substr(dtoc(date()), 4, 2) + ;
                 " " + substr(time(), 1, 5) + " " + config(POS_TERM_NUM) + chr(10)
                  
      A_RJS_PRNT(0, 1, 0, cBuffer, 0)
      
      cBuffer := "CS: "+alltrim(nvr_cCashName()) + " SIGN-ON" + chr(10)
      A_RJS_PRNT(0, 1, 0, cBuffer, 0)
      A_RJS_FEED(0, 1, 0, 2)    

#ifndef STAND_ALONE_MODE      
      send_sign_onoff(.T.)
#endif      
      cashier_init(cCashCode)      

  endif
  
  Disp_Data() 
  ScrollOn()
return lRetVal




/* Eof */
