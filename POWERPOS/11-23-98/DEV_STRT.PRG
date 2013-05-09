*
* System......... POWERPOS for Spectrum
* Program I.D.... DEV_STRT.prg
* Description.... Initializes the POS devices and NETWORK interface
*

#include "pfl_clip.ch"
#include "powerpos.ch"
#include "config.ch"
#incluDE "keymap.ch"
#include "spec_key.ch"
#define DEBUG

function power_start()
******************************
local status
local cMsg1 := "ENTER KEY TO DISABLE"

// NOTE: initialize devices ONLY if the configuration
//       file says YES...
//

if config(POS_4X20_DISP) == "YES"
   //
   // initialize cashier display (4x20)
   //
   if (status := SET_DEV(POS_CASH_DISP)) != NORMAL
#ifdef DEBUG   
      ? "Cashier display 4X20 device check failed..."
      ? "Press [ENTER] to disable CASHIER DISPLAY 4X20..."
#endif      
      DISPTEXTXY(1,1,0,0,1,1,"DISPLAY 4X40 ERROR!!")
      DISPTEXTXY(2,1,0,0,2,1,cMsg1)
      if inkey(0) == ENTER
        config(POS_4X20_DISP,"NO") 
      else
        error_log("CASHIER DISPLAY 4x20 device check failed...")
        pfl_msg(status, 1, "4x20 display")
      endif  
   endif 
endif

if config(POS_1X09_DISP) == "YES"
   //
   // initialize customer display 1 (1x9)
   //
   if (status := SET_DEV(POS_CUST_DISP1)) != NORMAL
#ifdef DEBUG   
      ? "Customer display 1X9 device check failed..."
      ? "Press [ENTER] to disable CUSTOMER DISPLAY 1X9..."
#endif      
      DISPTEXTXY(1,1,0,0,1,1,"DISPLAY 1X09 ERROR!!")
      DISPTEXTXY(2,1,0,0,2,1,cMsg1)
      if inkey(0) == ENTER
        config(POS_1X09_DISP,"NO") 
      else   
        error_log("CUSTOMER DISPLAY 1 1x09 device check failed...")   
        pfl_msg(status, 1, "1x9 display")
      endif  
   endif 
endif

if config(POS_2X20_DISP) == "YES"
   //
   // initialize customer display 2 (2x20)
   //
   if (status := SET_DEV(POS_CUST_DISP2)) != NORMAL
#ifdef DEBUG      
      ? "Customer display 2X20 device check failed..."
      ? "Press [ENTER] to disable CUSTOMER DISPLAY 2X20..."
#endif      
      DISPTEXTXY(1,1,0,0,1,1,"DISPLAY 2X20 ERROR!!")
      DISPTEXTXY(2,1,0,0,2,1,cMsg1)      
      if inkey(0) == ENTER
        config(POS_2X20_DISP,"NO") 
      else      
        error_log("CUSTOMER DISPLAY 2 2x20 device check failed...")      
        pfl_msg(status, 1, "2x20 display")
      endif  
   endif 
endif

//if config(POS_RETAILKEY) == "YES"
   //
   // initialize POS keyboard for Supermarket/Dept. Store...
   //
   if (status := SET_DEV(POS_KEYBOARD)) != NORMAL
#ifdef DEBUG      
      ? "POS keyboard device check failed..."
      ? "Press [ENTER] to disable pos keyboard..."
#endif      
      DISPTEXTXY(1,1,0,0,1,1,"POS KEYBOARD ERROR!!")
      DISPTEXTXY(2,1,0,0,2,1,cMsg1)      
        error_log("SPECTRUM POS KEYBOARD device check failed...")      
        pfl_msg(status, 1, "POS keyboard")
   endif 
//endif


if config(POS_SCANNER) == "YES"
   //
   // initialize SCANNER...
   //
   if (status := SET_DEV(POS_SCAN)) != NORMAL
#ifdef DEBUG      
      ? "SCANNER device check failed..."
      ? "Press [ENTER] to disable scanner..."
#endif      
      DISPTEXTXY(1,1,0,0,1,1,"POS SCANNER ERROR !!")
      DISPTEXTXY(2,1,0,0,2,1,cMsg1)      
      if inkey(0) == ENTER
        config(POS_SCAN,"NO") 
      else            
        error_log("SCANNER device check failed...")      
        pfl_msg(status, 1, "Scanner")
      endif  
// enable asynchronous scanning of labels...
// config(80) is the suffix character... POS_SCAN_SUFX
// config(81) is the scanner IRQ flag... POS_SCAN_IRQ
//      
   endif
   
   A_SCAN_ON (10, val(config(POS_SCAN_SUFX)), val(config(POS_SCAN_IRQ)))   
   
endif 

if config(POS_REC_PRINT) == "YES" .or. config(POS_JRN_PRINT) == "YES" .or. config(POS_VAL_PRINT) == "YES"
   //
   // initialize POS printer (Receipt, Journal, and Validation)...
   //
   if (status := SET_DEV(POS_PRINTER)) != NORMAL
#ifdef DEBUG   
      ? "POS PRINTERS device check failed..."
      ? "Press [ENTER] to disable POS PRINTERS..."
#endif      
      DISPTEXTXY(1,1,0,0,1,1,"POS PRINTERS ERROR!!")
      DISPTEXTXY(2,1,0,0,2,1,cMsg1)
      if inkey(0) == ENTER
        config(POS_REC_PRINT,"NO") 
        config(POS_JRN_PRINT,"NO") 
        config(POS_VAL_PRINT,"NO")         
      else                  
        error_log("POS PRINTER/S device check failed...")      
        pfl_msg(status, 1, "POS printer/s")
      endif 
   else
      // enable asynchronous printing...
      if A_PRNT_ON () != NORMAL
         // close the devices, then quit...
         error_log("ASYNCHRONOUS PRINTING test error...")   
         power_end()
          quit
      endif    
   endif 	
endif

if config(POS_XSLIP_PRN) == "YES"
   //
   // initialize external slip printer...
   //
   if (status := SET_DEV(OPT_SLIP_PRNTR)) != NORMAL
#ifdef DEBUG   
      ? "EXTERNAL SLIP PRINTER device check failed..."
      ? "Press [ENTER] to disable EXTERNAL SLIP PRINTER..."
#endif      
      DISPTEXTXY(1,1,0,0,1,1,"SLIP PRINTER ERROR!!")
      DISPTEXTXY(2,1,0,0,2,1,cMsg1)
      if inkey(0) == ENTER
        config(POS_XSLIP_PRN,"NO")         
      else        
        error_log("EXTERNAL SLIP PRINTER device check failed...")       
        pfl_msg(status, 1, "Slip printer")
      endif  
   else
      // setup slip printer settings...
      //
      status := slip_esc("1B40")
      // set print mode to 42 chars. per line...
      //
      status := slip_esc("1B2101")
      // set font to 7x7 (ESC + M)...
      //
      status := slip_esc("1B4D")
   endif 	
endif

if config(POS_KEY_LOCK) == "YES"
   // initialize POS central keylock...
   //
   if (status := SET_DEV(POS_CKEYLOCK)) != NORMAL
      error_log("POS CENTRAL KEYLOCK device check failed...")   
   #ifdef DEBUG   
         ? "POS central keylock device check failed..."
         ? "Press [ENTER] to disable POS central keylock..."
   #endif      
         DISPTEXTXY(1,1,0,0,1,1,"POS KEYLOCK ERROR !!")
         DISPTEXTXY(2,1,0,0,2,1,cMsg1)      
         if inkey(0) == ENTER
           config(POS_KEY_LOCK,"NO")         
         else        
           pfl_msg(status, 1, "Key lock")
         endif
   endif 	
endif
// initialize POS cash drawer...
//
if (status := SET_DEV(POS_CASH_DRAW)) != NORMAL
   error_log("CASH DRAWER device check failed...")   
   if config(POS_CASH_DRAWER) != "NO"
#ifdef DEBUG   
      ? "POS cash drawer device check failed..."
      ? "Press [ENTER] to disable POS cash drawer..."
#endif      
      DISPTEXTXY(1,1,0,0,1,1,"CASH DRAWER ERROR !!")
      DISPTEXTXY(2,1,0,0,2,1,cMsg1)      
      if inkey(0) == ENTER
        config(POS_CASH_DRAWER,"NO")         
      else           
        pfl_msg(status, 1, "Cash Drawer")
      endif  
   endif 
endif 	

// initialize MCR device...
//
if  config(POS_MCR) == "YES"
  if (status := SET_DEV(POS_CARD_READ)) != NORMAL
#ifdef DEBUG  
      ? "POS magnetic card reader device check failed..."
      ? "Press [ENTER] to disable Magnetic card reader..."
#endif      
      DISPTEXTXY(1,1,0,0,1,1,"CARD READER ERROR !!")
      DISPTEXTXY(2,1,0,0,2,1,cMsg1)      
      if inkey(0) == ENTER
          config(POS_MCR,"NO")         
      else           
         error_log("MCR device check failed...")   
         pfl_msg(status, 1, "Magnetic Card Reader")
      endif  
  endif    
endif 

return nil

function rpt_prnt(nRcpt,nJrnl,nSlip, outdata,nFeed)
local nRetVal := -1
local retries := 10

  while nRetVal != NORMAL .and. retries-- > 0

    while chk_jrnal() == PAPER_ERR
       MsgAreaDisp("Receipt/Journal Paper Error")
       Tone(600,6)       
       MsgAreaDisp("Fix Journals and Press any to continue...")
       inkey(0)
       clearkeys()
       MsgAreaDisp()       
    enddo
    nRetVal := A_RJS_PRNT(nRcpt, nJrnl, nSlip, outdata, nFeed)    
    if nRetVal != NORMAL
       MsgAreaDisp("Error in journal Print <"+alltrim(str(nRetVal))+">")
    endif   
  enddo  
  
return nRetVal


* eop 01/03/96?

