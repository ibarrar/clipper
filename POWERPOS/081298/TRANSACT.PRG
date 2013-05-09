/* *************************************************************************

   Filename..... TRANSACT.PRG
   Module....... Module for transaction procedures
   Author....... Rollie C. Ibarra Jr.
   Date Started.
   Revisitions.. 
       Date      Name
       
*************************************************************************** */

#include "config.ch"
#include "spec_key.ch"
#include "message.ch"
#include "terminal.ch"
#include "nvr_file.ch"
#include "plu_file.ch"

#ifdef DEF_GRAPHICS
  #include "grfx_all.ch"
#endif  

#define  DRAWER_OPEN        18
#define  DRAWER_CLOSED      19

#define DISC_RATE_HALO      100
#define DISC_AMT_HALO       AMT_HALO

#define TYPE_BANKCARD       "0"
#define TYPE_BANKCHEQUE     "3"
#define TYPE_INHOUSE        "1"
#define TYPE_PO             "2"
#define TYPE_GC             "4"

static lSubtotal   := .F.
static lRetExch    := .F.
static lRefund     := .F.
static lDiscount   := .F.

function transaction(lSignedOn)
local lRetVal := .T.
local nQuantity:= 1
local cKeyBuff := ""
local cKey := CLR
local cData
local i,k,nDept,nPayt,lStatus
local nPLU := 0
local pymt_stat 

  ScrollOff()

  lRetExch := .F.
  lSubtotal := .F.    
  isTransact(.F.) 

  if !lSignedOn
    // clear display
    disp_clr()
      
    DISPTEXTXY(1, 1, 0, 0, 1, 1, "                    ")
#ifdef DEF_DISP1X09
    DISPTEXTXY(0, 0, 1, 1, 0, 0, "        0" )
#endif    
    MsgAreaDisp(MSG_D018)

#ifdef DEF_GRAPHICS  
    gDrawText(22, 2, "_" , SMALL_FONT, 8, BLACK)
    Rcpt_Footer()      
#endif      
  endif    

  DISPTEXTXY(1, 1, 0, 0, 1, 1, "  YOUR CASHIER IS   ")
  DISPTEXTXY(2, 1, 0, 0, 2, 1, nvr_cCashName())  
  
#ifdef DEF_GRAPHICS
 Disp_BoldChar(nvr_nSUBtotal(), "Total Amount")
 Rcpt_Footer()
#endif

  // get data input from keyboard...
  while lRetVal == .T. 

#ifdef DEF_DISP4X20
    if ltran_void()
       DISPTEXTXY(4, 1, 0, 0, 0, 0, "TXV*")
    elseif nvr_lTRNG_Mode()
       DISPTEXTXY(4, 1, 0, 0, 0, 0, "TRNG*")  
    endif
#endif    

    cKey := input()
    
    do case
       case IS_KEYCHANGE(@cKey)          
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
          MsgAreaDisp(MSG_CLEAR) // clear display area
#ifdef KEY_SOUND          
          Sound_On()
#endif          
       case ( len(cData := is_number(@cKey)) > 0 ) .or. ( len(cData := is_alpha(@cKey)) > 0 )
          if len(cKeyBuff) < MAXIMUM_INPUT_LEN
             cKeyBuff += cData
          endif      
          DISPTEXTXY(1, 1, 0, 0, 1, 1, padl(cKeyBuff,20))
          nPLU := 0
#ifdef DEF_GRAPHICS          
          Disp_Data(cKeyBuff + chr(95))
#endif          
          loop
       case cKey == BACK_SPACE
          cKeyBuff := subs(cKeyBuff,1,len(cKeyBuff)-1)
          DISPTEXTXY(1, 1, 0, 0, 1, 1, padl(cKeyBuff,20) )
#ifdef DEF_GRAPHICS
          Disp_Data(cKeyBuff + chr(95))
#endif   
          loop
       case cKey == CLR
          lSubTotal  := .F.
#ifdef DEF_GRAPHICS
             Disp_Data(chr(95))
#endif             
          DISPTEXTXY(1, 1, 0, 0, 1, 1, MSG_CLEAR ) 
          DISPTEXTXY(2, 1, 0, 0, 2, 1, PAD(config(POS_2X20_DISP1),20) )
          clearkeys()
       case ckey == QTY
             // must include the decimal if it exist...
            if val(cKeyBuff) > QTY_LALO .and. val(cKeyBuff) < QTY_HALO  .and. lHasNoAlpha(@cKeyBuff)
              nQuantity := val(cKeyBuff)
              DISPTEXTXY(1, 1, 0, 0, 1, 1, MSG_CLEAR )
              DISPTEXTXY(2, 1, 0, 0, 2, 1, trans(nQuantity,"      999 Items     ") )
#ifdef DEF_DISP4X20
              DISPTEXTXY(3, 1, 0, 0, 0, 0, MSG_CLEAR )               
#endif              
              // MsgAreaDisp("ENTER ITEM or AMOUNT")              
              MsgAreaDisp(trans(nQuantity,"999 Items"))
            else
              ErrorDisp(MSG_D007) // invalid quantity
              nQuantity := 1
            endif  
            cKeyBuff := ""
#ifdef DEF_GRAPHICS
              Disp_Data(cKeyBuff + chr(95))
#endif             
            loop          
       case ckey == CASHIER
          if "0" == cKeyBuff               
            if nvr_nSUBtotal() != 0 
              ErrorDisp(MSG_D011)            
            elseif lRetExch               
              ErrorDisp("RET_EXCH ! COMPLETE.") 
            else
              // Cashier is signing off 
              // will have to unmark the marked cashier as free
              // thru file access
#ifdef DEF_GRAPHICS              
              Disp_Data()
#endif              
              BEEP_1()              
#ifndef STAND_ALONE_MODE              
              send_sign_onoff(.F.)
#endif              
              Print_SignOff()
              Cashier_off()
              nvr_cCashCode("OFFOFF")                            

              lRetVal  := .F. 
            endif 
          elseif temp_sign_off(cKeyBuff)
            DISPTEXTXY(1, 1, 0, 0, 1, 1, MSG_CLEAR ) 
#ifdef DEF_DISP1X09
            DISPTEXTXY(0, 0, 1, 1, 0, 0, "        0" )              
#endif
            MsgAreaDisp(MSG_D018)               
          else   
            ErrorDisp(MSG_D006) // probable key sequence error   
          endif
	  case cKey == PO
	       po(cKeyBuff)    
       case  ((nDept := is_dept(@cKey)) != 0)
          // Put a decimal if there is none
          if !lHasNoAlpha(@cKeyBuff)                    
             ErrorDisp(MSG_D013)  
          else
            cKeyBuff := put_decimal(cKeyBuff)   
            // check for excessive amounts
            if val(cKeyBuff) * nQuantity > TOTAMT_HALO .or. (val(cKeyBuff) * nQuantity <= AMT_LALO)
                 ErrorDisp(MSG_D008) // amount may have exceeded or less than expected
            else
#ifdef DEF_GRAPHICS
                if pymt_stat == .T.
                   // clear screen in case sub_total is pressed..
                   gClearTo(4, 57, 96, 74, 7)
                endif   
#endif                
                cData := getDept(nDept)
                
                if dept_request(cData,nQuantity,cKeyBuff)
                   lSubtotal := .f.                            
                   tran_cCrgo()  // Reset the cargos
#ifdef DEF_GRAPHICS                  
                   screen_refresh()
                   Disp_Data()
#endif                   
                   isTransact(.T.)
                   cKeyBuff  := ""
                   nQuantity := 1
                   pymt_stat := .F.
                   loop
                endif                  
            endif                   
          endif           
#ifdef ONESHOT_PLU		
       case ckey == PLU .or. cKey == SCANNER .or. ( (nPLU := isPLU(@cKey)) > 0 )
#else
       case ckey == PLU .or. cKey == SCANNER 
#endif	  	  
          if cKey == SCANNER
             cKeyBuff := scandata()
#ifdef ONESHOT_PLU
          elseif nPLU > 0              
            cKeyBuff := is_oneshot(@nPLU) // this is a oneshot plu...            
#endif
          endif  
          if empty(cKeyBuff)
            nQuantity := 1
            loop            
          endif  
          if "." $ cKeyBuff
            ErrorDisp(MSG_D005)           // Invalid Code...
          else 
             // to make it simplier just call the function
             // and pass the parameters
#ifdef DEF_GRAPHICS
             if pymt_stat == .T.
                // clear screen in case sub_total is pressed..
                gClearTo(4, 57, 96, 74, 7)
             endif   
#endif
             if (plu_request(cKeyBuff,nQuantity))
                tran_cCrgo()  // Reset the cargo
                lSubtotal := .f.                            
#ifdef DEF_GRAPHICS                  
                screen_refresh()
                Disp_Data(chr(95))
#endif
                isTransact(.T.) 
                cKeyBuff  := ""             
                nQuantity := 1                            
                pymt_stat := .F.
                Rcpt_Footer()
                loop
             endif
          endif  
/*          
#ifdef DEF_GRAPHICS          
       case ckey == UP
          screen_up()
       case ckey == DOWN
          screen_dn()          
#endif          
*/
       case ckey == SUBTOTAL
          // possible return exchanged PLU or amount          
          DispSubtotal()          
          lSubTotal := .T.
          cKeyBuff   := ""          
          nQuantity  := 1
	  MsgAreaDisp(MSG_D043)
          loop
       case (( nPayT := is_payment(@cKey) ) != -1 )       
          // Put a decimal if there is none for the amount tendered...
          cKeyBuff := put_decimal(cKeyBuff)
          // check if subtotal value is zero
          if empty(nvr_nSUBtotal()) .and. !lRetExch
             ErrorDisp(MSG_D009) // Balance Due is zero...
          elseif nvr_nSUBtotal() < 0 .and. !lRefund 
             ErrorDisp("NEGATIVE BALANCE DUE")            
             // check if  mandatoty subtotal keypress is SET                
          elseif (val(cKeyBuff) != 0) .and. (val(cKeyBuff) > TOTQTY_HALO .or. val(cKeyBuff) <= AMT_LALO )
             ErrorDisp(MSG_D008) // amount may have exceeded or less than expected
          elseif config(POS_M_STTL_KEY) == "YES" .and. !lSubTotal 
             ErrorDisp(MSG_D010) // Press subtotal first  
          else            
            if !lSubTotal
               DispSubTotal()
            endif
            if nPayT == 0  // This means type of payment is CASH
		  	if cCurrency() == DOLLAR_SIGN
	               lStatus := Cash_Payment(cKeyBuff)     
			else
				lStatus := Foreign_Payment(cKeyBuff)
			endif	
            elseif nPayT == 100 .or. GetMtype(nPayT) == TYPE_BANKCARD
               lStatus := Bank_Payment(nPayT,cKeyBuff)			
            else              
               lStatus := MISC_Payment(nPayT,cKeyBuff) 
            endif            
            pymt_stat := .T.            
                
            if lStatus               
                            
               // Reset all values...
               nvr_nTrans (.T.)

               reset_nvr()

               lRetExch  := .F.
               lDiscount := .F.
               lSubtotal := .F.
               isTransact(.F.) 
               lTran_void(.F.)



               lPO_Entered(.F.)
                              
               if config(POS_CASH_DRAWER) != "NO" 
                  while chk_drawr() != DRAWER_CLOSED
                       MsgAreaDisp(MSG_D014) // Close Drawer msg
                       tone(15,9)                       
                  enddo               
               endif               
#ifdef DEF_GRAPHICS
                 Rcpt_Footer()
                 getRcptRow(0)
                 getRcptCol(0)
                 Rcpt_Scroll(0)
                 Disp_Data(chr(95))
                 pymt_stat := .F.
#endif  
               lRefund := .F.
            endif              
          endif    
#ifdef NON_ADD_ENABLED		
       case cKey == SALES_CLERK // The CLERK Key
          get_Clerk(cKeyBuff)
       case cKey == NON_ADD // in Manuela's case SOS
          get_SOS(cKeyBuff)
#endif		
       case cKey == PESO .or. cKey == USD
          cCurrency(if(cKey==PESO,"P","$"))
		DispSubtotal()
		loop          
       case cKey == ADD_ON_AMT .or. cKey == ADD_ON_RATE          
          if config(POS_ADDON) != "YES" 
             ErrorDisp("ADD-ON FUNC DISABLED")
          elseif nvr_nSUBtotal() == 0
             ErrorDisp(MSG_D009) // Balance Due is zero...
          elseif !lSubTotal
             ErrorDisp(MSG_D010) // Press subtotal first
          elseif keylock() != KEY_LOCK_POS2
             ErrorDisp("MANAGER'S MODE REQ'D")             
          else          
            // initiate add-on            
            addon(cKeyBuff,cKey==ADD_ON_RATE) //2nd param if rate passed .t. else .f.
          endif   
       case cKey == VOID .or. cKey == ERRCORR
          if config(POS_CSHR_IV_ALWD) == "YES"
		  if  keylock() == KEY_LOCK_POS2
              void_item()
              Rcpt_Footer()
            else
              ErrorDisp("MANAGER'S MODE REQ'D")   
            endif 
		else
		    ErrorDisp("Cashier Void Not Allowed!")
		endif  
       case cKey == MGR_VOID    
          if config(POS_CSHR_SIV_ALWD) == "YES" 
		   if  keylock() == KEY_LOCK_POS2
               mgr_void()
               Rcpt_Footer()
             else
               ErrorDisp("MANAGER'S MODE REQ'D")  
             endif 
		else
		   ErrorDisp("Manager Void Not Allowed!")
		endif   
       case cKey == RET_EXC
          if keylock() == KEY_LOCK_POS2
             // Must first input the exchange item then subtotal
             if nvr_nSUBtotal() > 0 
                lRetExch := ret_exch() 
             else
                ErrorDisp("EXCH. ITEM/AMT.FIRST")                
             endif 
          else 
            ErrorDisp("MANAGER'S MODE REQ'D")
          endif  
       case cKey == IPCT_DISC .or. cKey == DISCOUNT
          if lSubtotal
            ErrorDisp("CLR BEFORE ITEM DISC")
          elseif keylock() != KEY_LOCK_POS2
            ErrorDisp("MANAGER'S MODE REQ'D")
          else  
            if cKey == DISCOUNT
              if empty(cKeyBuff)
                 cKeyBuff := config(POS_PRCNT_DISC)
              endif   
            endif   
            if val(cKeyBuff) > 0 .and. val(cKeyBuff) < DISC_RATE_HALO          
                 discount(cKeyBuff) 
                 lDiscount := .T.
            else
               ErrorDisp("INVALID DISC. RATE!!")    
            endif  
          endif  
       case cKey == SPCT_DISC
          if empty(cKeyBuff)
             cKeyBuff := config(POS_PRCNT_DISC)          
		endif    
          if !lSubTotal
            ErrorDisp(MSG_D010) // Press subtotal first            
          elseif nvr_nSUBtotal() <= 0
            ErrorDisp(MSG_D009) // Balance Due is zero...
          elseif val(cKeyBuff) <= 0 .or. val(cKeyBuff) >= DISC_RATE_HALO 
            ErrorDisp("INVALID DISC. RATE!!")    
          elseif lDiscount == .T.  
            ErrorDisp("ERROR : DISCOUNT GIVEN ALREADY  !!")    
          elseif keylock() != KEY_LOCK_POS2
            ErrorDisp("MANAGER'S MODE REQ'D")  
          else
            SubttlDisc(cKeyBuff)
          endif   
       case cKey == IAMT_DISC
          if lSubtotal 
             ErrorDisp("CLR BEFORE ITEM DISC")
          elseif keylock() != KEY_LOCK_POS2
            ErrorDisp("MANAGER'S MODE REQ'D")  
          else  
            // Put a decimal if there is none          
            cKeyBuff := put_decimal(cKeyBuff)
            if val(cKeyBuff) > 0 .and. val(cKeyBuff) < DISC_AMT_HALO          
                 iamtdisc(cKeyBuff) 
            else
               ErrorDisp("INVALID DISC. AMOUNT")    
            endif  
          endif  
       case cKey == SAMT_DISC       
          // Put a decimal if there is none          
          cKeyBuff := put_decimal(cKeyBuff)
          if !lSubTotal
            ErrorDisp(MSG_D010) // Press subtotal first
          elseif nvr_nSUBtotal() <= 0
            ErrorDisp(MSG_D009) // Balance Due is zero...          
          elseif val(cKeyBuff) <= 0 .or. val(cKeyBuff) >= DISC_AMT_HALO 
            ErrorDisp("INVALID DISC. AMOUNT")    
          elseif keylock() != KEY_LOCK_POS2
            ErrorDisp("MANAGER'S MODE REQ'D")  
          else            
            SamtDisc(cKeyBuff)
          endif   
       case cKey == NO_SALE          
          if nvr_nSUBtotal() != 0
             ErrorDisp(MSG_D011)  // bal due is not zero
          elseif keylock() != KEY_LOCK_POS2 
             ErrorDisp("MANAGER'S MODE REQ'D")  
          else   
             if !lSubtotal
                DispSubtotal()
             endif   
             open_drawr()
             MsgAreaDisp(MSG_D014) // Close Drawer msg
             rpt_prnt(1,1,0,"OPEN DRAWER",0)
             prnt_end(nvr_nQtyItems())
             nvr_nQtyItems(0)
             nvr_nITMitems(0)           
             lSubtotal := .F.
             lRetExch := .F.
             isTransact(.F.)
             lPO_Entered(.F.)
             if config(POS_CASH_DRAWER) != "NO" 
                 while chk_drawr() != DRAWER_CLOSED
                    MsgAreaDisp(MSG_D014) // Close Drawer msg
                 enddo         
             endif
#ifdef DEF_GRAPHICS
               getRcptRow(0)
               getRcptCol(0)
               Rcpt_Scroll(0)
               Disp_BoldChar(0, "Total Amount")
               Disp_Data(chr(95))
#endif  
          endif   
       case cKey == TRANSCAN
          if nvr_nITMitem() <= 0 .or. nvr_nSubtotal() <= 0
            ErrorDisp(MSG_D009) // Balance Due is zero...          
          elseif keylock() != KEY_LOCK_POS2
            ErrorDisp("MANAGER'S MODE REQ'D")          
          elseif !lSubTotal
            ErrorDisp(MSG_D010) // Press subtotal first  
          else
            TransCancel()
            // Reset all values...
            nvr_nTrans (.T.)
            reset_nvr()
            lRetExch := .F.
            isTransact(.F.)
          endif         
       case cKey == SUSPEND
          if nvr_nSUBtotal() <= 0
             ErrorDisp(MSG_D009) // Balance Due is zero...
          elseif nvr_nSUSlevel() == 9 
             ErrorDisp(MSG_D035) // maximum transaction suspend reached.  
          elseif keylock() != KEY_LOCK_POS2
            ErrorDisp("MANAGER'S MODE REQ'D")          
          else   
             DispSubTotal()
             DISPTEXTXY(1,1,0,0,1,1,"SUSPEND TRANSACTION!")
             DISPTEXTXY(4,1,0,0,2,1,MSG_D034)
             MsgAreaDisp("Suspend Transaction, Press <ENTER> key to Confirm")
             if input() == ENTER
              // do the actual suspension of transaction.
              if suspend_tran(nvr_nSUSlevel()) != NORMAL
                 ErrorDisp("CANNOT SUSPEND TRANS.")
              else
                 isTransact(.F.)                 
                 Rcpt_Footer()
                 #ifdef DEF_GRAPHICS
                   getRcptRow(0)
                   getRcptCol(0)
                   Rcpt_Scroll(0)
                   Disp_BoldCh(nvr_nSUBtotal(), "Total Amount")
                 #endif
              endif
             endif
          endif   
       case cKey == RESUME      
          if nvr_nSUBtotal() != 0
             ErrorDisp(MSG_D011)  // bal due is not zero
          elseif nvr_nSUSlevel() == 0
             ErrorDisp("NO SUSPEND TO RESUME")   
          elseif keylock() != KEY_LOCK_POS2
            ErrorDisp("MANAGER'S MODE REQ'D")          
          else
             resume_tran()
             isTransact(.T.)                              
             Rcpt_Footer()
          endif            
       case cKey == REFUND            
          if keylock() != KEY_LOCK_POS2
            ErrorDisp("MANAGER'S MODE REQ'D")          
          elseif !lSubTotal
            ErrorDisp(MSG_D010) // Press subtotal first            
          elseif nvr_nSUBtotal() <= 0
            ErrorDisp(MSG_D009) // Balance Due is zero...
          else
            open_drawr()
            itm_refund()
            if config(POS_CASH_DRAWER) != "NO" 
              while chk_drawr() != DRAWER_CLOSED
                  MsgAreaDisp(MSG_D014) // Close Drawer msg
                  tone(15,9)                       
              enddo               
            endif               
            // Reset all values...
               nvr_nTrans (.T.)
               reset_nvr()
               lRetExch := .F.
               isTransact(.F.) 
               lTran_void(.F.)
               #ifdef DEF_GRAPHICS
                 getRcptRow(0)
                 getRcptCol(0)
                 Rcpt_Scroll(0)
                 Disp_Data(chr(95))
                 pymt_stat := .F.
               #endif  
          endif            
          lSubtotal := .F.        
       case cKey == TRAN_VOID   
          if nvr_nSUBtotal() != 0
             ErrorDisp(MSG_D011)  // bal due is not zero
        elseif keylock() != KEY_LOCK_POS2
            ErrorDisp("MANAGER'S MODE REQ'D") 

          else
             ltran_void(.T.)   
             if tran_void()
                         
               // Reset all values...
               nvr_nTrans (.T.)

               reset_nvr()

               lRetExch := .F.
               isTransact(.F.) 
               lTran_void(.F.)
               prnt_end(nvr_nQTYItems())  
       
#ifdef DEF_GRAPHICS   
                 Rcpt_Footer()                      
                 getRcptRow(0)
                 getRcptCol(0)
                 Rcpt_Scroll(0)
                 Disp_Data(chr(95))                 
#endif  
               
               lRefund := .F.
            endif  
          endif
#ifdef PICKUP_PAIDOUT_ENABLED		
       case cKey == PICK_UP
          if nvr_nSUBtotal() == 0
             pick_up(cKeyBuff)
          else
             ErrorDisp(MSG_D011)  // bal due is not zero                
          endif       
       case cKey == PAID_OUT
          if nvr_nSUBtotal() == 0 
             paid_out(cKeyBuff)
          else 
             ErrorDisp(MSG_D011)  // bal due is not zero                
          endif   
#endif		
#ifdef LOAN_ENABLED
       case cKey == LOAN
          if nvr_nSUBtotal() == 0
             loan(cKeyBuff)
          else
             ErrorDisp(MSG_D011)  // bal due is not zero                
          endif    
#endif		   
       case cKey == REPRINT   
          if keylock() != KEY_LOCK_POS2
             ErrorDisp("MANAGER'S MODE REQ'D")          
          else   
             reprint_bill(cKeyBuff)
          endif   
       case cKey == ENTER
          online_plu(cKeyBuff)   
#ifdef CASH_DECLARE_ENABLED		        
       case cKey == CASH_IN_DRAWER
          if nvr_nSUBtotal() != 0
             MsgAreaDisp(MSG_D011)
             loop
          else   
             cash_declare()      
          endif
#endif
#ifdef VALIDATE_CONCESS		
       case cKey == VALIDATE
          // validate last item     
          validate(lSubtotal)
#endif
#ifdef PRICE_LEVELING		
       case cKey == PLEVEL
            if config(POS_PRICE_DEFAULT) == "00"
               config(POS_PRICE_DEFAULT, "01")
               MsgAreaDisp("WHOLESALE MODE")
               Rcpt_Footer()
               cPLU_PLev(PRICE_LEVEL_1)
            elseif config(POS_PRICE_DEFAULT) == "01"
               config(POS_PRICE_DEFAULT, "00")
               MsgAreaDisp("RETAIL MODE")
               Rcpt_Footer()
               cPLU_PLev(PRICE_LEVEL_0)
            endif
#endif		  
       otherwise
          ErrorDisp(MSG_D006) // probable key sequence error
    endcase

    Disp_Data(chr(95))

    cKeyBuff   := ""          
    nQuantity  := 1

    if nvr_nITMitem() > 0
       Disp_tran()       
    else
       DISPTEXTXY(1, 1, 0, 0, 1, 1, MSG_CLEAR ) 
    endif
    if lSubtotal
    	 MsgAreaDisp(MSG_D043)
    else
      MsgAreaDisp(MSG_D018)
    endif	 
  enddo

  ScrollOn()
return lRetVal

#ifdef DEF_GRAPHICS  

function Rcpt_Footer()
local cOutText            // Display buffer
local var_test := nvr_cCashName()
  
  if empty(var_test)
     var_test := subs(nvr_cCashCode(),1,3)
  endif

  // Clear Receipt Footer Region
  gClearTo( 10, 74, 90, 80, CFG_DFILL)
    
  // Display Receipt Footer  
  gDrawText(74, 50, "No. Of Items " + trans(nvr_nQTYitems(),"@BZ 9999999.99") , ;
            SMALL_FONT, 6, CFG_DNORM, MSCALE, CENTER_TEXT)

  // Prepare the Print Receipt Footer buffer
  cOutText := dtoc(date())     + " " + ; // system date hope its correct
              subs(time(),1,5) + " " + ; // Time 
       padl(nvr_nTrans(),6,"0")+ " " + ; // running transaction number
            alltrim(subs(nvr_cCashName(), 1, 12))   + " " + config(POS_TERM_NUM) + " " + ;
            if(nvr_lTRNG_Mode(), "[TRNG]", " ")               
		  
//           if(config(POS_PRICE_DEFAULT) == "00", "[RETAIL]", "[WHOLESALE]") + " ";
            
              
  gDrawText(77, 50, cOutText , SMALL_FONT, 6, CFG_DNORM, MSCALE, CENTER_TEXT)

  // Clear Amount region
  gClearTo( 46, 10, 97, 20, CFG_DFILL)
  // Display amount
  #ifdef USD_CURRENCY
  	gDrawText(10,47,"$",TRIPLEX_FONT, 5, CFG_DNORM, MSCALE, LEFT_TEXT)
  #endif 
  gDrawText(10, 96, TRANS(nvr_nSUBtotal(), "9,999,999.99"), ;
             TRIPLEX_FONT, 5, CFG_DNORM, MSCALE, RIGHT_TEXT) 
  
return nil

#endif              

function DispSubtotal()
local nSubAmount := nvr_nSUBtotal()
local out_text

  if config(POS_PRINT_SUBTOTAL) == "YES"
      // set font to 15.6 cpi normal...
      // A_PRT_ESC(NORMAL_15)
      
      out_text :=  space(10)+"SUBTOTAL "+ trans(nSubAmount, "99,999,999.99")      
      A_RJS_FEED(1, 0, 0, 1)
      rpt_prnt(1, 0, 0, out_text , 0)     

      out_text :=  "SUBTOTAL"+ space(11) + trans(nSubAmount, "99,999,999.99")
      // on journal...
      // A_PRT_ESC(NORMAL_12)
      A_RJS_FEED(0, 1, 0, 1)
      rpt_prnt(0, 1, 0, out_text , 0)
   endif      

#ifdef DEF_DISP1X09
    TOTAL_ON
    // customer display 1 (1x9)
    // no. plus comma or period occupies only 1 space
    out_text := trans(nSubAmount, "9999999.99")
    DISPTEXTXY(0, 0, 1, 1, 0, 0, out_text )
#endif          
          
    // customer display 2 (2X20)
    disp_clr()
    if cCurrency() == DOLLAR_SIGN
        DISPTEXTXY(0, 0, 0, 0, 1, 1, "   US Dollar (USD)  ")
	   out_text := trans(nSubAmount, "999,999.99")
    else
        DISPTEXTXY(0, 0, 0, 0, 1, 1, "Philippine Peso(PHP)")
	out_text := trans(nSubAmount*nvr_nPHP_Rate(), "999,999.99")
    endif      
    DISPTEXTXY(2, 1, 0, 0, 2, 1, "BAL DUE :           ")
    DISPTEXTXY(3, 11, 0, 0, 2, 11, out_text)

#ifdef DEF_GRAPHICS
    Disp_BoldChar(nSubAmount, "Amount Due")
#endif
   
return nil

function Cash_Payment(cKeyBuff)
local lRetVal := .F.
local nCashAmt := val(cKeyBuff)
local nDueAmt := nvr_nSUBtotal()
local nQty    := nvr_nQtyItems() 
local out_text 

    if nDueAmt > nCashAmt .and. nCashAmt > 0
        // here is where the actual payment is processed....
        MsgAreaDisp(MSG_D015) // Aknowledge partial payment
        tone(15,18) // delay exactly one second...         
        
        // POS printer...
        // skip one line...
        A_RJS_FEED(1, 1, 0, 1)        

        out_text := "SUBTOTAL  " + space(12) + trans(nDueAmt, "999,999.99") + chr(10) 
        rpt_prnt(1, 1, 0, out_text, 0)        

        A_RJS_FEED(1, 1, 0, 1)                

        out_text := "CASH" + space(18) + trans(nCashAmt, "999,999.99") + chr(10)
        rpt_prnt(1, 1, 0, out_text, 0)

        out_text := "BAL. DUE  " + space(12) + ;
                     trans(nDueAmt - nCashAmt, "999,999.99") + chr(10) 
        rpt_prnt(1, 1, 0, out_text, 0)
        A_RJS_FEED(1, 1, 0, 1)

#ifdef SLIP_PRNT   
        // try to print to optional slip printer...
        //
        slip_print("  " + chr(10), 0)
        out_text := space(6) + "CASH      " + space(12) + ;
                    trans(nCashAmt, "999,999.99") + chr(10)
        slip_print(out_text, 0)
        out_text := space(6) + "SUBTOTAL  " + space(12) + ;
                    trans(nDueAmt, "999,999.99") + chr(10)
        slip_print(out_text, 0)
        out_text := space(6) + "BAL. DUE  " + space(12) + ;
                    trans(nDueAmt - nCashAmt, "999,999.99") + chr(10)
        slip_print(out_text, 0)
        slip_print("  " + chr(10), 0)
#endif

        #ifdef DEF_GRAPHICS
          Disp_PayAmt("CASH", nDueAmt, nCashAmt, nDueAmt - nCashAmt)
          Disp_BoldChar(nDueAmt -nCashAmt)
        #endif
        payment(nCashAmt,(nDueAmt - nCashAmt), 0, "", "")
        nDueAmt -= nCashAmt
        nvr_nSUBtotal(nDueAmt)

        // Add to the terminal file
        Term_nData(TR_DSLS_TOT,nCashAmt)            // First the Totals  
        Term_nData(TR_CASH_TOT,nCashAmt)        

        DispSubTotal()
    else     
        // now ok to pay 
        // now check if there is change 
        if nCashAmt == 0
           nCashAmt := nDueAmt           
        endif                            
        
        // you know what to do....
        disp_clr()

        #ifdef DEF_GRAPHICS
           Disp_PayAmt("CASH", nDueAmt, nCashAmt, nDueAmt - nCashAmt)
        #endif
#ifdef DEF_DISP1X09                     
        out_text := "C " + trans(nCashAmt - nDueAmt, "99999.99")
        DISPTEXTXY(0, 0, 1, 1, 0, 0, out_text)
#endif        

        // customer display 2 (2x20)
        out_text := "   CASH : "  + transform(nCashAmt, "999,999.99")
        DISPTEXTXY(0, 0, 0, 0, 1, 1, out_text)
        out_text := " CHANGE : " + transform(nCashAmt - nDueAmt, "999,999.99")
        DISPTEXTXY(0, 0, 0, 0, 2, 1, out_text)
#ifdef DEF_DISP4X20
        // cashier display (4x20)
        out_text := "BAL DUE : " + transform(nDueAmt, "999,999.99")
        DISPTEXTXY(1, 1, 0, 0, 0, 0, out_text)
        out_text := "   CASH : " + transform(nCashAmt, "999,999.99")
        DISPTEXTXY(2, 1, 0, 0, 0, 0, out_text)
        out_text := " CHANGE : " + transform(nCashAmt - nDueAmt, "999,999.99")
        DISPTEXTXY(3, 1, 0, 0, 0, 0, out_text)
#endif
        open_drawr()
        MsgAreaDisp(MSG_D014) // Close Drawer msg

        // POS receipt and journal printer...
        // skip one line...
        A_RJS_FEED(1, 1, 0, 1)

        out_text := space(16) + "TOTAL " + transform(nDueAmt, "999,999.99") + chr(10) 
        rpt_prnt(1, 0, 0, out_text, 0)
                
        out_text := space(16) + "CASH  " + transform(nCashAmt, "999,999.99") + chr(10)         
        rpt_prnt(1, 0, 0, out_text, 0)

        out_text := space(16) + "CHANGE" + transform(nCashAmt - nDueAmt, "999,999.99") + chr(10) 
        rpt_prnt(1, 0, 0, out_text, 0)                                  

        // on journal...
        out_text := pad("SUBTOTAL      ",22) + transform(nDueAmt, "999,999.99") + chr(10)
        rpt_prnt(0, 1, 0, out_text, 0)
        out_text := pad("CASH          ",22) + transform(nCashAmt, "999,999.99") + chr(10) 
        rpt_prnt(0, 1, 0, out_text, 0)
        out_text := pad("CHANGE        ",22) + transform(nCashAmt - nDueAmt, "999,999.99") + chr(10) 
        rpt_prnt(0, 1, 0, out_text, 0)        
        
        A_RJS_FEED(0, 1, 0, 1)

#ifdef SLIP_PRNT
      // try to print on optional slip printer...
        //
        slip_print("  " + chr(10), 0)
        out_text := space(6) + "TOTAL     " + space(12) + ;
                               trans(nDueAmt, "999,999.99") + chr(10)
        slip_print(out_text, 0)
        out_text := space(6) + "CASH      " + space(12) + ;
                               trans(nCashAmt, "999,999.99") + chr(10)
        slip_print(out_text, 0)

        out_text := space(6) + "CHANGE    " + space(12) + ;
                      transform(nCashAmt - nDueAmt, "999,999.99") + chr(10)
        slip_print(out_text, 0)
        
        // print all the charge invoice one time only...
        print_invoice()        
#endif        
        payment(nDueAmt,(nDueAmt - nCashAmt), 0, "", "")          
        
        // update first the terminal file
        Term_nData(TR_DSLS_TOT,nvr_nSUBtotal())
        Term_nData(TR_CASH_TOT,nvr_nSUBtotal())
        Term_nData(TR_DSLS_KNT,1)
	
        // Update nvram in this case resetting to 0
        nvr_nSUBtotal(0) 
        // now the quantity
        nvr_nQtyitems(0)               
            
        prnt_end( nQty  )      
        
#ifdef DEF_GRAPHICS   
        Rcpt_Footer()                      
#endif
        lRetVal := .T.                                
        
    endif   

return lRetVal

function TransCancel()
local k,cFlag
local cRetBuff
local nAmount
local nCounter
local nPayAmt
local nPayType
local outtext,cPLUCode
local nQty,nPrice := 0
local cDept,cDesc := space(20)
  
  A_RJS_FEED(1, 1, 0, 1)
  rpt_prnt(1, 1, 0, pad("SUBTOTAL ",21)+trans(nvr_nSUBtotal(),"9999,999.99"), 0)
  A_RJS_FEED(1, 1, 0, 1)
  rpt_prnt(1, 1, 0, "**** TRANSACTION CANCELLED ****", 0)
  A_RJS_FEED( 1, 1, 0, 1 )
  
  disp_cancel()

  #ifdef DEF_GRAPHICS
    getRcptRow(0)
    getRcptCol(0)
    Rcpt_Scroll(0)
    Disp_BoldChar(0, "Total Amount")
  #endif  

  for k := 1 to nvr_nITMitem()
     
     tran_init(k)
     cFlag := tran_cFlag()
     nAmount  := tran_nSale()
     nPrice   := tran_nPric() // jlp
     nCounter := tran_nCntr()
     cPLUCode := tran_cPLU()
     cDept    := tran_cDept()
     do case 
        case cFlag $ POSITIVE_OPER_FLAG 
             // Deduct the department total with the ff amounts              
             
             if cFlag == OP_OINC_FLAG
                 Term_nData(TR_OINC_TOT, - nAmount )
                 Term_nData(TR_OINC_KNT, - 1 )
                 Term_nData(TR_DSLS_TOT, - nAmount )                 
             elseif cFlag == OP_ADON_FLAG
                 Term_nData(TR_ADON_TOT, - nAmount )
                 Term_nData(TR_ADON_KNT, - 1 )
             else
                 Term_nData(TR_DEPT_TOT, - nAmount)
                 dept_count(tran_cDept(),-nCounter, -nAmount, 0 )                                   
             endif

             if cFlag == OP_NPLU_FLAG
                  plu_counter(tran_cPlu(), -nCounter, -nAmount, 0)
             elseif cFlag == OP_NOTF_FLAG   
                  lNFND_ADD(tran_cPLU(),tran_cDesc(),tran_cDept(),-nCounter, nPrice,0)
             endif                
                
        case cFlag $ NEGATIVE_OPER_FLAG
             // Deduct the department total with the ff amounts 
*            Term_nData(TR_DEPT_TOT, nAmount)

             if cFlag == OP_VOID_FLAG
                 if Tran_cPflg() != "D"
                   Term_nData(TR_VOID_TOT, - nAmount )
                   Term_nData(TR_VOID_KNT, - 1 )
                 endif 
             elseif cFlag == OP_MGRV_FLAG    
                 if Tran_cPflg() != "D"
                   Term_nData(TR_MGRV_TOT, - nAmount )
                   Term_nData(TR_MGRV_KNT, - 1 )
                 endif  
             elseif cFlag == OP_IDSC_FLAG
                 Term_nData(TR_IDSC_TOT, - nAmount )
                 Term_nData(TR_IDSC_KNT, - 1 )
             elseif cFlag == OP_SDSC_FLAG
                 Term_nData(TR_SDSC_TOT, - nAmount )
                 Term_nData(TR_SDSC_KNT, - 1 )
             elseif cFlag == OP_REXC_FLAG
                 Term_nData(TR_REXC_TOT, -nAmount )
                 Term_nData(TR_REXC_KNT, - 1 )
                 // Term_nData(TR_DEPT_TOT, nAmount) 
             endif    

        case cFlag $ DONOTHING_OPER_FLAG
             if cFlag $ "123456789" // partial payments...
                // undo the payment done...

                nPayType := val(tran_cPrcM())                
                nPayAmt := -tran_nSale()
                Term_nData(TR_DSLS_TOT,nPayAmt)      // First the Totals                
                Term_nData(TR_TRCL_TOT,-nPayAmt)                

                if nPayType == 0
                  Term_nData(TR_CASH_TOT,nPayAmt)
                  outtext := pad("CASH PAYMENT",21)
                else
                  Term_nData(7+((nPayType-1)*2),nPayAmt)        
                  Term_nData(8+((nPayType-1)*2),-1)     // Then the Quantities                
                  outtext := pad(GetMDesc(nPayType)+" PAYMENT",21)
                endif    
                        
                outtext += trans(nPayAmt, "9999,999.99")
                rpt_prnt( 1, 1, 0, outtext , 1 )
                                                               
             endif
             // Just do nothing...              
        otherwise 
           // warn me that there are unknown flags roaming around...
           error_log ("Unrecognized flag at trans cancel : "+cFlag)   
     endcase    


     // then edit the transaction for cancel flag
     tran_cPflg(tran_cFlag())
     if cFlag $ "123456789" 
       tran_cFlag(OP_TRCL_FLAG)
     else
       tran_cFlag(OP_ITCL_FLAG)
     endif  
     edit_trans(k)               
  next k  

  tran_cFlag(OP_TRCL_FLAG)                        // flag
  tran_cPFlg( "0" )
  tran_cPrcM(padl("0",TRAN_PRCM_LEN,"0"))
  tran_nSale(nvr_nSUBtotal())                       // Sale    
  tran_nCntr(0)                       // Balance
    
  tran_cCrg1(repl("0",TRAN_CRG1_LEN))                    // ist cargo
  tran_cCrg2(repl("0",TRAN_CRG1_LEN))                    // 2nd cargo
  tran_cCrg3(repl("0",TRAN_CRG1_LEN))                    // 3rd cargo    
  tran_cCrg4(padl(nvr_nQTYitems(),TRAN_CRG4_LEN),"0")   // 4th cargo  
  
  Update_trans()

#ifdef SLIP_PRNT
  // delete all transactions in invoice validation proc..
  del_invoice()
#endif  

  // increment the Terminal cancel counter 
  Term_nData(TR_TRCL_TOT, nvr_nSUBTotal() )
  Term_nData(TR_TRCL_KNT, 1 )  
  // no need as per che&doris
    
  // reset the subtotal and counter 
  nvr_nSUBtotal(0)
  nvr_nQTYitems(0)  

  DispSubTotal()         
  A_RJS_FEED( 1, 1, 0, 1 )
  rpt_prnt(1, 1, 0, pad("SUBTOTAL ",21)+trans(nvr_nSUBtotal(),"9999,999.99"), 0)

  prnt_end(nvr_nQTYItems())  
  
return nil

function disp_cancel()   
   DISPTEXTXY(1,1,1,1,1,1,MSG_CLEAR)   
   DISPTEXTXY(2,1,0,0,1,1,"*TRANSACTION CANCEL*")   
#ifdef DEF_DISP4X20   
   DISPTEXTXY(3,1,0,0,0,0,MSG_CLEAR)   
   DISPTEXTXY(4,1,0,0,0,0,MSG_CLEAR)   
#endif   
return nil

function lHasNoAlpha(cBuffer)
local lRetVal := .T.
local i

   for i := 1 to len(cBuffer)
     if isalpha(subs(cBuffer,i,1))
        lRetVal := .F.
        exit
     endif   
   next

return lRetVal

#ifdef DEF_GRAPHICS
static function screen_refresh()

   // Clear Receipt Footer Region
   gClearTo( 10, 74, 90, 77, CFG_DFILL)            
   // Display Receipt Footer      
   gDrawText(74, 50, "No. Of Items " + trans(nvr_nQTYitems(),"@B 9999999.99") , ;
           SMALL_FONT, 6, CFG_DNORM, MSCALE, CENTER_TEXT)                              
return nil           
#endif                            

function put_decimal(cParm)
local nVar

   if len(cParm) > 0
      if !("."$cParm)
           if len(cParm) < 3
               cParm := padl(cParm,3,"0")
           endif 
           cParm := stuff(cParm,len(cParm)-1,0,".") 
      endif   
   endif     
   
#ifdef DEBUG
   ? " Data Variable : >"
   ?? cParm
#endif   
   nVar := val(cParm)
   nVar := round(nVar,2)
   
return   alltrim(trans(val(cParm),"99999999.99"))


