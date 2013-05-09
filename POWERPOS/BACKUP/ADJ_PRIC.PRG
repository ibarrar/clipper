#include "keymap.ch"
#include "file_acc.ch"
#include "message.ch"
#include "plu_file.ch"
#include "spec_key.ch"
#include "config.ch"
#include "pfl_clip.ch"
#include "nvr_file.ch"
#include "inkey.ch"
#include "powerpos.ch"
#include "terminal.ch"

#ifdef DEF_GRAPHICS
 #include "grfx_all.ch"
#endif

#define LMARGIN         12

function adjusted_price()
local lRetVal := .F.
local cData
local nQuantity := 1
local nPrice,Tprice,cQtyBuff
local nQty,cDesc
local Amount := 0
local discount, cPLUcode
local cWindow

// display screen to getinput not found plu code
   // save screen
   cWindow := OpenWindow(25, 34, 78, 63, "PRICE ADJUSTMENT")

   gDrawText(16, 20, "Original Price", SMALL_FONT, 6, 0, MFIX, LEFT_TEXT)
   gDrawText(17, 20, "PLU Code", SMALL_FONT, 6, 0, MFIX, LEFT_TEXT)
   gDrawText(18, 20, "New Price", SMALL_FONT, 6, 0, MFIX, LEFT_TEXT)

   gDrawText(16, 37, ":" , SMALL_FONT, 6, 0, MFIX, LEFT_TEXT)
   gDrawText(17, 37, ":" , SMALL_FONT, 6, 0, MFIX, LEFT_TEXT)
   gDrawText(18, 37, ":" , SMALL_FONT, 6, 0, MFIX, LEFT_TEXT)   
     
   gDrawText(16, 38, transform(tran_nPric(), "@B999,999.99") , SMALL_FONT, 6, ;
	     0, MFIX, LEFT_TEXT)
   gDrawText(17, 38, tran_cPLU(), SMALL_FONT, 6, 0, MFIX, LEFT_TEXT)        
   gDrawText(18, 38, chr(95), SMALL_FONT, 6, 0)
   Beep_3()
   MsgAreaDisp("Enter New Price ...")
   DISPTEXTXY(0, 0, 0, 0, 1, 1, "PRICE :             ")
   cData := Input_Data(2, 9, 1, 1, 1, 9, { |x| !empty(is_number(x)) } , 9, "ENTER NEW PRICE...  ", 1, .F.)   

   if empty(cData)
        // restore previous screen
        CloseWindow(cWindow)
        MsgAreaDisp("Enter Clerk/Qty or Item")
        return .F.
   endif          

   // put a decimal if there is none
   cData := put_decimal(cData)

   nPrice := val(cData) 
   nQty   := tran_nQty()
   //Tprice := tran_nPric()
   cPLUcode := tran_cPLU()
   cDesc := tran_cDesc()
   Amount := nPrice * nQty
   DISPTEXTXY(2, 1, 0, 0, 1, 1, "PRICE : "+trans(nPrice,"9,999,999.99"))            
   
   #ifdef DEF_GRAPHICS
     // display the adjusted price
     gClearTo(53, 51, 68, 54, 7)
     gDrawText(18, 38, transform(nPrice, "@B999,999.99"), SMALL_FONT, 6, 0)

   #endif

   // update the original item price with the adjusted item price
   tran_nPric( nPrice )
   tran_nSale( Amount )

   nvr_nSUBtotal( nvr_nSUBtotal() + Amount )
   nvr_nQTYItems( nvr_nQTYItems() + nQty )
   
   Term_nData(TR_DEPT_TOT,Amount) // add the dept sale to the dept totals

   // update the nvram file and trans. record
   Update_Trans()

   if tran_cFlag() == OP_NPLU_FLAG
      plu_counter(tran_cPLU(), tran_nCntr(), tran_nSale(), 0)
      dept_counter(tran_cDept(), tran_nCntr(), tran_nSale(), 0)
   elseif tran_cFlag() == OP_NOTF_FLAG      
      lNFND_Add(tran_cPLU(),tran_cDesc(),tran_cDept(), tran_nCntr(), tran_nSale(), 0)
      dept_counter(tran_cDept(), tran_nCntr(), tran_nSale(), 0)
   endif
            
   // wait for a keypress before exiting the function
   input() 

   // restore previous screen
   CloseWindow(cWindow)

   Disp_Adjust(OP_NPLU_FLAG, cPLUcode, cDesc, nQty, nPrice, Amount)
   
   #ifdef DEF_GRAPHICS
    if tran_cFlag() == "N" 
      Rcpt_Scroll(1, tran_cDesc(), nQty, nPrice, "A", 0, 0, 0, 0, tran_cClrk()) 
    elseif tran_cFlag() == "P"
      Rcpt_Scroll(1, tran_cPLU(), nQty, nPrice, "A", 0, 0, 0, 0, tran_cClrk()) 
    endif  
    Disp_BoldChar(nvr_nSUBtotal(), "Total Amount")  
   #endif            
   MsgAreaDisp("Enter Clerk/Qty or Item")

   print_adjust(cPLUCode,nQty,nPrice, Amount,cDesc)

return nil

#ifdef DEF_GRAPHICS
function Input_Data(n1Row,n1Col,n2Row,n2Col,n3Row,n3Col, bBlock, nLen, cMsg, ;
                    pass_code, adj_flag)
 local cKey,cData
 local cKeyBuff := ""
 local cDispBuff := ""

 while .T. 

   #ifdef T_KEYBOARD
     cKey := input(T_KEYBOARD)
   #else
     cKey := input()
   #endif  

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
            #ifdef T_KEYBOARD
              input(T_KEYBOARD)
            #else
              input()
            #endif  
          enddo
          SetAlarm()
          Disp_Mode()          
          
          MsgAreaDisp(cMsg) // clear display area
#ifdef KEY_SOUND          
          Sound_On()
#endif          
       case Eval(bBlock,cKey)
          do case
             case !empty(cData := is_number( cKey ))
             case len(cData := is_alpha( cKey )) > 0
             case !empty(cData := cDeptCode( cKey ))
          endcase             
          if len(cKeyBuff) < nLen
             cKeyBuff += cData
          endif      
          if pass_code == 1
             gClearTo(53, 51, 68, 54, 7)
             gDrawText(18, 38, cKeyBuff + chr(95), SMALL_FONT, 6, 0)
          elseif pass_code == 2
             gClearTo(53, 54, 68, 57, 7)
             gDrawText(19, 38, cKeyBuff + chr(95), SMALL_FONT, 6, 0)
          elseif pass_code == 3
             gClearTo(53, 57, 83, 60, 7)
             gDrawText(20, 38, cKeyBuff + chr(95), SMALL_FONT, 6, 0)
          endif     
#ifdef ALPHA_NUMERIC
       case !empty(cData := is_alpha() )
          if len(cKeyBuff) < MAXIMUM_INPUT_LEN
             cKeyBuff += cData
          endif     
          if pass_code == 1
             gClearTo(53, 51, 68, 54, 7)
             gDrawText(18, 38, cKeyBuff + chr(95), SMALL_FONT, 6, 0)
          elseif pass_code == 2
             gClearTo(53, 54, 68, 57, 7)
             gDrawText(19, 38, cKeyBuff + chr(95), SMALL_FONT, 6, 0)
          elseif pass_code == 3
             gClearTo(53, 57, 83, 60, 7)
             gDrawText(20, 38, cKeyBuff + chr(95), SMALL_FONT, 6, 0)
          endif               
#endif           
       case cKey == CLR
          if empty(cKeyBuff)
             exit
          endif
          if pass_code == 1
             gClearTo(53, 51, 68, 54, 7)
             gDrawText(18, 38, chr(95), SMALL_FONT, 6, 0)
          elseif pass_code == 2
             gClearTo(53, 54, 68, 57, 7)
             gDrawText(19, 38, chr(95), SMALL_FONT, 6, 0)
          elseif pass_code == 3   
             gClearTo(53, 57, 83, 61, 7)
             gDrawText(20, 38, CHR(95), SMALL_FONT, 6, 0)         
          endif     
          cKeyBuff   := ""
       case cKey == BACK_SPACE
          cKeyBuff := subs(cKeyBuff,1,len(cKeyBuff)-1)
          if pass_code == 1
             gClearTo(53, 51, 68, 54, 7)
             gDrawText(18, 38, cKeyBuff + chr(95), SMALL_FONT, 6, 0)
          elseif pass_code == 2
             gClearTo(53, 54, 68, 57, 7)
             gDrawText(19, 38, cKeyBuff + chr(95), SMALL_FONT, 6, 0)
          elseif pass_code == 3
             gClearTo(53, 57, 83, 61, 7)
             gDrawText(20, 38, cKeyBuff + chr(95), SMALL_FONT, 6, 0)                      
          endif     
       case cKey == ENTER
          if pass_code == 1 
/*             if !adj_flag
                if val(put_decimal(cKeyBuff)) > tran_nPric()
                   gClearTo(53, 51, 68, 54, 7)
                   gDrawText(18, 38, chr(95), SMALL_FONT, 6, 0)             
                   ErrorDisp(MSG_D013)
                   cKeyBuff := ""
                   cDispBuff := cKeyBuff + if (len(cKeyBuff) < nLen,"_","")
                   MsgAreaDisp("Enter New Price")
                   loop
                else
                   MsgAreaDisp("Press Any Key to Continue")
                   exit                  
                endif
             else
                if val(put_decimal(cKeyBuff)) < tran_nPric()
                   gClearTo(53, 51, 68, 54, 7)
                   gDrawText(18, 38, chr(95), SMALL_FONT, 6, 0)             
                   ErrorDisp(MSG_D013)
                   cKeyBuff := ""
                   cDispBuff := cKeyBuff + if (len(cKeyBuff) < nLen,"_","")
                   MsgAreaDisp("Enter New Price")
                   loop
                else
                   MsgAreaDisp("Press Any Key to Continue")
                   exit                  
                endif
             endif   */
             MsgAreaDisp("Press Any Key to Continue")
             exit                  
          elseif pass_code == 2
             exit
          elseif pass_code == 3
             exit  
          endif   
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

function Disp_Adjust(cFlag,cCode,cDesc, nQty, nPrice, nAmount)
local cBuffer

#ifdef DEF_DISP1X09
    cBuffer := tran(nAmount,"9999999.99")
    DISPTEXTXY( 0, 0, 1, 1, 0, 0, cBuffer )
#endif          

   cBuffer := tran(nQty,"999") + "@ " + tran(nPrice,"99,999.99")  
   
   DISPTEXTXY(0, 0, 0, 0, 1, 1, padl(cBuffer,20))      
   DISPTEXTXY(0, 0, 0, 0, 2, 1, subs(cDesc,1,10)+ tran(nAmount,"99,999.99" )) 
   
#ifdef DEF_DISP4X20
   DISPTEXTXY(1, 1, 0, 0, 0, 0, padl(cCode,20))
   DISPTEXTXY(2, 1, 0, 0, 0, 0, pad(cDesc,20))     
   DISPTEXTXY(3, 1, 0, 0, 0, 0, cBuffer)    
   DISPTEXTXY(4, 1, 0, 0, 0, 0, padl(tran(nAmount," 999,999.99"),20))   
#endif   
                                 
return nil  

function print_adjust(cPLUCode,nQty,nPrice,nAmount,cDesc)
local out_text

  // prepare to print values 
  A_RJS_PRNT(0, 1, 0, cPLUCode, 0)            
      
  if nQty > 1
	  out_text :=space(LMARGIN)+trans(nQty,"999 @  ")
	  out_text += trans(nPrice,"999,999.99")
	  // now print the values
	  A_RJS_PRNT(1, 1, 0, out_text, 0)            
  endif
                     
  out_text := cDesc
  out_text += "  " +  trans(nAmount,"999,999.99")
         
  // now print the values
  A_RJS_PRNT(1, 1, 0, out_text, 0)
      
return nil

