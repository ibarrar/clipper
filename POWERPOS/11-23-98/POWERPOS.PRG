/************************************************************************

   Filename..... POWERPOS.PRG
   Module....... Main Module for Powerpos Application
   Author....... Rollie C. Ibarra Jr.
   Date Started.
   Revisitions.. 
       Date      Name
       
*************************************************************************/

#include "printctl.ch"
#include "message.ch"
#include "spec_key.ch"
#include "config.ch"
#include "powerpos.ch"

#undef CASHIER_ON_RECEIPT

function main()
local nStatus,cBuffer
local cKey,lSign_on,lPower_on
local lexit := .F.

  set(_SET_SCOREBOARD,.F.)
  set(_SET_WRAP,    .T.)
  set(_SET_PATH,DATA_PATH)
  set(_SET_DATEFORMAT,"mm-dd-yy")
  set(_SET_DELETED, .T.)
  set(_SET_EXACT,   .T.)
  set(_SET_SOFTSEEK,.T.)
  set(_SET_CONFIRM, .T.)
  set(_SET_CANCEL,  .F.)
  set(_SET_EPOCH, 1960 )
  
  scroll()  

  // initialize that cashier not signed on.
  lSign_on := .F.
  
  //
  // read the POS configuration (system.cfg), key mapping (keymap.cfg), and
  // Dept. and PLU one shot code definition (oneshot.cfg) text files and dump
  // their contents to the static  config_, keymap_, and oneShot_ arrays
  // respectively...
  //
  config(START_MODE)
  keymap_init()
  power_start()    

  DISPTEXTXY(4,1,0,0,0,0," ** PLEASE WAIT **  ")
  DISPTEXTXY(1,1,0,0,1,1," START-UP SEQUENCE  ")
  DISPTEXTXY(2,1,0,0,2,1,"    INITIATED...    ")   
  
  /* Departments... */
  dept_init()
  /* Miscellaneous..*/
  charge_init()
  
#ifdef ONESHOT_PLU  
  /* OneShot PLUs   */
  oneshot_init()
#endif
  
  /* Now Terminal report file... */
  term_init() 
  input_init()

  if (( nStatus := NVR_init()) != NORMAL ) 
         error_log("NVCTRL Error: "+pad(nStatus,2)+" file setting failed.")
         power_end()
         quit
  endif

  // initialize all values of cntrl variables 
  cntrl_init()  

  // initialize all the communications parameters...
  // paths and filenames
  faccess_init()    
  
  // try to make a start of the day routine if server mode...
  //
  if config(POS_SERVER_MD) == "YES"
     ask_server ( START_MODE )
     cntrl_init()  // reinitialize control buffer variables
  endif

  if ((nStatus := disp_init()) != NORMAL)
     error_log("Graphics Error : " + ltrim(str(nStatus)) + ".")
     ? "Graphics Error : "
     ?? nStatus
     power_end() 
     Quit 
  endif    
  
  // enable sound...
  //
#ifdef KEY_SOUND  
  set_ksound(2000, 100)
#endif  

  // clear displays
  disp_clr() 

#ifdef DEF_GRAPHICS  
  screen_init()
#endif    

  // clear keyboard buffer
  while nextkey() != 0 ; inkey(0) ; enddo

  disp_Data()  
  disp_welcome()     
    
  // check for powerup to restore parameters and variables status
  lPower_on := power_up()

  Disp_Mode()  
  while !lexit

   BEGIN SEQUENCE  // Error Recovery modules traps errors and recover

#ifdef DEF_KEY_LOCK        
    // First Get the Central Key Lock position.....    
    do case 
       case keylock() == KEY_LOCK_POS0 // OFF MODE
            MsgAreaDisp("*** C L O S E D ***")
            // disable sound...
            set_key_sound(OFF)       

             cKey := Input() 
             lExit := (cKey == ESC_DOS)
             
            // enable sound
            set_key_sound(ON)                                      
       case keylock() == KEY_LOCK_POS1 // REG MODE
#endif       
            if !lPower_on .and. !lSign_on
              MsgAreaDisp(MSG_D001) // Cashier key prompt to sign_on
              if ( (ckey := input()) == CASHIER )
                if lprev_reset()    // check first if the previous day was reset...
                  lSign_on := SignOn()  
                endif  
#ifndef DEF_KEY_LOCK
              elseif cKey == ESC_DOS
                  lexit := .T. 
#endif                
              endif  
            else  
              lSign_on := Transaction(lPower_on)  // Transaction procedures proper
              lPower_on := .F.
            endif              
            
#ifdef DEF_KEY_LOCK                    
       case keylock() == KEY_LOCK_POS2 // MGR-mode
            MsgAreaDisp("You are in MGR Mode.")
            input()
       case keylock() == KEY_LOCK_POS3 // X-mode
            MsgAreaDisp("*You are in X-mode.." )            
            reports()
            MsgAreaDisp(MSG_CLEAR)
       case keylock() == KEY_LOCK_POS4 // Z-mode             
            MsgAreaDisp("*You are in Z-mode.." )                        
            lExit := reports()
    endcase
#endif        

    disp_welcome()     
     
    Disp_Mode()

    if lExit
      //  we will reset the fm_Trans and nvcntrl fmtrans counter...
      lExit := end_of_day()  
    endif  
    
    RECOVER
    
    BEEP_3() 
    Display_Msg("*APPLICATION ERROR!*",;
                "IMPORTANT: TERMINATE",;
                "ALL EXISTING TRANS..",)
      ErrorDisp("THEN EXIT A.S.A.P.!!")    
                
    disp_welcome()     
     
    Disp_Mode()
    Disp_Comm(.F.)    
    LOOP
    
    END SEQUENCE   
    
  enddo   

  MsgAreaDisp(MSG_D000)   // Safe to power off display       
  ScrollOff()
  
  disp_clr()
  power_end()      
  
  ? "Normal Powerpos SHUTDOWN..."  

return keylock()

function prnt_end(nQty)
local out_text
local cName

/*
               A_RJS_FEED(1, 1, 0, 1)
  	       A_RJS_PRNT(1, 1, 0, "Remaining PO Limit: "+;
                          trans(nPO_Limit(),"$***,**9.99"), 0)
*/	
  // skip one line
  A_RJS_FEED(1, 0, 0, 1)

  // check if in training Mode...
  if nvr_lTRNG_Mode()
     A_RJS_PRNT(1, 0, 0, "   ***** VOID RECEIPT *****", 1)
     A_RJS_PRNT(0, 1, 0, "    **** TRAINING MODE ****", 1)
  endif  

  if valtype(nQty) == "N"

     // no of items on receipt....
     out_text := space(8) + "NO. OF ITEMS " + trans( nQTY ,"9999")
     A_RJS_PRNT(1, 0, 0, out_text, 0)

     // on journal ...
     out_text := space(11) + trans( nQTY,"9999" ) + " ITEMS"
     A_RJS_PRNT(0, 1, 0, out_text, 1)

     out_text := padl(nvr_nTrans(),6,"0") + " " + subs(nvr_cCashCode(),1,3) + ;
              "*** "+ subs(dtoc(date()),1,2) +" "+ subs(dtoc(date()),4,2) + ;
              " " + subs(time(),1,5) + " " +config(POS_TERM_NUM) 
                
     A_RJS_PRNT(0, 1, 0, out_text, 1)
  else   
     // skip one line
     A_RJS_FEED(1, 0, 0, 2)        
  endif   
  
  // back to the receipt
  out_text := " "+ dtoc(date()) + " " + subs(time(),1, 5) + " " + ;
              padl(nvr_nTrans(),6,"0") + " " + subs(nvr_cCashCode(),1,3) + ;
              " " + config(POS_TERM_NUM)
  A_RJS_PRNT(1, 0, 0, out_text, 0)                

  // skip one line
  A_RJS_FEED(1, 0, 0, 1) 
  
  // the thank you message....
  if empty(config(POS_BOTTOM_LINE1))
    A_RJS_PRNT(1, 0, 0, MESSAGE_LINE_ONE, 1) // look for it in the
  else
    A_RJS_PRNT(1, 0, 0, config(POS_BOTTOM_LINE1), 1) // look for it in the    
  endif

  if empty(config(POS_BOTTOM_LINE2))
    A_RJS_PRNT(1, 0, 0, MESSAGE_LINE_TWO, 1) // file message.ch
  else    
    A_RJS_PRNT(1, 0, 0, config(POS_BOTTOM_LINE2), 1) // file system.cfg    
  endif  
  
#ifdef MESSAGE_LINE_THREE  
  if !empty(config(POS_BOTTOM_LINE3))
    A_RJS_PRNT(1, 0, 0, config(POS_BOTTOM_LINE3), 1) // file system.cfg    
  endif
#endif  

  // skip 3 lines
  A_RJS_FEED(1, 0, 0, 6)
     
  A_RJS_PRNT(1, 0, 0, config(POS_REC_HEAD1),1)
  A_RJS_PRNT(1, 0, 0, config(POS_REC_HEAD2),1)
  A_RJS_PRNT(1, 0, 0, config(POS_REC_HEAD3),1)
  
  if !empty(config(POS_REC_HEAD4))
    A_RJS_PRNT(1, 0, 0, config(POS_REC_HEAD4), 1)
  else
    A_RJS_FEED(1, 0, 0, 1)       
  endif  
  
  // check if in training mode ulit
  if nvr_lTRNG_Mode()
      // skip 1 line
     A_RJS_PRNT(1, 0, 0, "    **** TRAINING MODE ****", 1)
  else   
     A_RJS_FEED(1, 0, 0, 1)     
  endif
    
  // skip a line
*  A_RJS_FEED(1, 0, 0, 1)

#ifdef CASHIER_ON_RECEIPT

  // Prints the cashier initial on the receipt   
  cName := subs(nvr_cCashName(),1,at(" ",nvr_cCashName()))
  cName := if(empty(cName),nvr_cCashName(),pad(cName,20))
  
  out_text := "CASHIER: "+cName+ UPPER(subs(cdow(date()),1,3))
  A_RJS_PRNT(1, 0, 0, out_text, 0)
#endif

  // skip a line
*  A_RJS_FEED(1, 0, 0, 2)

  // Then Cut the receipt...
  A_PRT_ESC(CUT_RECEIPT)      

return nil

*  eof ----->
