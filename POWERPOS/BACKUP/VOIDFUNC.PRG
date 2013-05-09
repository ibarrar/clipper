#include "nvr_file.ch"
#include "message.ch"
#include "terminal.ch"

//#include "powerpos.ch"
#include "plu_file.ch"
#include "deptfile.ch"
#include "spec_key.ch"
#include "file_acc.ch"
#include "get_grfx.ch"

#ifdef DEF_GRAPHICS
  #include "grfx_all.ch"
#endif

#define LMARGIN 12

function void_item()
local nSubtotal := nvr_nSUBtotal()
local nVoidQty,nDiscQty := 0
local nVoidAmt,nDiscAmt := 0
local nPrice,cFlag,cDesc
local lWDisc := .F.
local out_text,cCode
local curr_item := nvr_nITMitem()
local descriptor

  if nvr_nSUBtotal() > 0 .and. curr_item > 0

     // move backward until operation can be voided
     while tran_cFlag() == "D" .and. curr_item > 1
         curr_item-- //decrement counter by one
         tran_init(curr_item)
         // mark it as discounted
         lWDisc := .T.         
     enddo
     
     // check if current operation can be voided     
     if tran_cFlag() == OP_NPLU_FLAG .or. tran_cFlag() == OP_OPEN_FLAG .or.;
        tran_cFlag() == OP_NOTF_FLAG        

        cDesc := tran_cDesc()
        descriptor := tran_cDesc()
        do case
           case tran_cFlag() == OP_NPLU_FLAG .or. tran_cFlag() == OP_NOTF_FLAG 
               cCode := tran_cPLU()
           otherwise     
               cCode := pad("DEPT: "+tran_cDept(),TRAN_PLU_LEN) 
               tran_cDesc(cCode)
        endcase               

        out_text := "*ITEM VOID " +  trans(tran_nQty(), "@ 9999.99") ;
                    + " @ "  + trans(tran_nPric(), "99,999.99") + chr(10) 
        rpt_prnt(1, 1, 0, out_text, 0)            
        
        // instead of item code, print the description
        out_text := pad(cDesc,21) + transform(-tran_nSale(), "9999,999.99") + chr(10) 
        rpt_prnt(1, 1, 0, out_text, 0)
        
        Term_nData( TR_DEPT_TOT , -tran_nSale() )        
        Term_nData( TR_VOID_TOT , tran_nSale() )                
        Term_nData( TR_VOID_KNT , 1 )                
        // normalize the transaction subtotal and no of items  
        ? " Subtotal is : "
        ? nSubtotal
        nSUBtotal := nvr_nSUBtotal( nSUBtotal - tran_nSale() )
        ? " Subtotal now : "
        ? nSubtotal
        nvr_nQTYitems(nvr_nQTYitems() - tran_nCntr() )

        tran_cPFlg(tran_cFlag())
        tran_cFlag(OP_VOID_FLAG)
        edit_trans(curr_item)

        nVoidAmt := tran_nSale() 
        nVoidQty := tran_nCntr()
        nPrice   := tran_nPric()        

        if tran_cPFlg() == OP_NPLU_FLAG
	  plu_counter(tran_cPLU(), -nVoidQty, -nVoidAmt, 0)
	  dept_counter(tran_cDept(), -nVoidQty, -nVoidAmt, 0)
        elseif tran_cPFlg() == OP_NOTF_FLAG      
	  lNFND_Add(tran_cPLU(),tran_cDesc(),tran_cDept(), -nVoidQty, nPrice, 0)
	  dept_counter(tran_cDept(), -nVoidQty, -nVoidAmt, 0)
        elseif tran_cPFlg() == OP_OPEN_FLAG  
          dept_counter(tran_cDept(), -nVoidQty, -nVoidAmt, 0)        
        endif

        if lWDisc         
           tran_init(++curr_item)
           if tran_cFlag() == "D" 
               nDiscAmt := tran_nSale()
               nDiscQty := tran_nCntr()
               Term_nData( TR_IDSC_TOT, - nDiscAmt )                   
               Term_nData( TR_IDSC_KNT, - 1 )                       
               tran_cPFlg(tran_cFlag())
               tran_cFlag(OP_VOID_FLAG)           
               edit_trans(curr_item)            
               curr_item++ // increment to the next record...
               tran_init(curr_item)            
               ? "this is item discount item branch"
           endif

           ? " With Discount Subtotal was : "
           ?? nSubtotal
           nSubtotal := nvr_nSUBtotal( nSUBtotal + nDiscAmt)
           ? " Subtotal now :"
           ?? nSubtotal
           
// Since Item discount is not deducted to DEPT TOTALS 
// Thefore there is no reason for me to add it to DEPT TOT 
//    in case it is voided           
//              Term_nData( TR_DEPT_TOT, + nDiscAmt )                      
// 06-29-96

           out_text := "*ITEM DISC VOIDED" 
           rpt_prnt(1, 1, 0, out_text, 0)
           out_text := pad(trans(nDiscQty, "999% DISCOUNT"),21) + ;
                       trans(nDiscAmt, "9999,999.99") 
           rpt_prnt(1, 1, 0, out_text, 0)                    
        endif
      
        disp_Void( nVoidAmt - nDiscAmt, cCode, nVoidQty, nPrice)    

        #ifdef DEF_GRAPHICS
            cFlag := tran_cFlag()
            Rcpt_Scroll(1, descriptor, nVoidQty, nPrice, cFlag, nDiscQty,nDiscQty,nDiscAmt, 0, tran_cClrk())
            Disp_LastPage(nvr_nITMitem())
            Disp_BoldChar(nvr_nSUBtotal())
        #endif

   #ifdef VALIDATE_VOID
           // prompt for a slip printer        
           slip_prompt()
        
           // try to print to optional slip printer...
           out_text := space(6) + "*ITEM VOID    " + ;
                        transform(nVoidQty, "@Z 9999.99") + " @ "  + ;
                        transform(nPrice, "9999,999.99") + chr(10)
           slip_print(out_text, 0)
           out_text := space(6) + pad(cCode,15) + transform(-nVoidAmt, "9999,999.99") + chr(10)
           slip_print(out_text, 0)        

           if lWDisc
             out_text := "*ITEM DISC VOIDED" + chr(10)
             slip_print(space(6) + out_text, 0)        
             out_text := trans(nDiscQty, "999% DISCOUNT") + space(9) + ;
                         trans(nDiscAmt, "999,999.99") + chr(10) 
             slip_print(space(6) + out_text, 0)        
           endif
   #endif             
           // Put all the lastest data on the mem variable
           tran_init()
     else           
        ErrorDisp("CAN'T VOID LAST ITEM")                 
     endif
  else
     ErrorDisp(MSG_D009)
  endif    

return nil

function disp_Void(nVoidAmt, cCode, nQty, nPrice)
local out_text

  // clear displays....
  disp_clr()
  // customer display 1 (1x9)
  out_text := " " + transform(-nVoidAmt, "9999999.99")
  DISPTEXTXY(0, 0, 1, 1, 0, 0, out_text)

  // customer display 2 (2x20)
  DISPTEXTXY(0, 0, 0, 0, 1, 1, cCode)
  out_text := "VOID     "  + transform(-nVoidAmt, "9999,999.99")
  DISPTEXTXY(0, 0, 0, 0, 2, 1, out_text)

  // cashier display (4x20)
  do case
     case nQty > 1
        DISPTEXTXY(1, 1, 0, 0, 0, 0, cCode)
        out_text := space(3) + transform(nQty, "9999") + " @" + ;
                    transform(nPrice, "9999,999.99")                     
        DISPTEXTXY(2, 1, 0, 0, 0, 0, out_text)
        out_text := "VOID     " + transform(-nVoidAmt, "9999,999.99")
        DISPTEXTXY(3, 1, 0, 0, 0, 0, out_text)
     otherwise
        DISPTEXTXY(2, 1, 0, 0, 0, 0, cCode)
        out_text := "VOID     " + transform(-nVoidAmt, "9999,999.99")
        DISPTEXTXY(3, 1, 0, 0, 0, 0, out_text)
  endcase

return nil  

function mgr_void()
local nVoidQty
local nVoidAmt  
local nPrice,cCode
local lWDisc := .F.
local nDiscAmt := 0
local nDiscQty := 0
local nSubtotal := nvr_nSUBtotal()
local curr_item := nvr_nITMitems()
local disc_text,out_text
local next_item,cKey,cDesc 
local descriptor
local cDept
local cQty,cAmt
local wWindow

  if nSUBtotal > 0 .and. curr_item > 0
  
       disp_tran(curr_item)     
       MsgAreaDisp("[ENTER] TO VOID ITEM")       
       curr_item := Item_Select(curr_item)

       if curr_item == 0
          return nil
       endif   
       
       tran_init(curr_item)
       
       if tran_cFlag() == "D" .or. tran_cFlag() == OP_VOID_FLAG .or.;
             tran_cFlag() == OP_MGRV_FLAG 
          ErrorDisp("CAN'T VOID LAST ITEM")                    
          return nil
       endif   

/*
       // move backward until operation can be voided
       while tran_cFlag() == "D" .or. tran_cFlag() == OP_VOID_FLAG .or.;
             tran_cFlag() == OP_MGRV_FLAG .and. curr_item > 1 
          curr_item-- //decrement counter by one
          tran_init(curr_item)
          // mark it as discounted
       enddo
*/
      MsgAreaDisp("Voiding Item "+trans( curr_item, "99"))

      wWindow := OpenWindow(20, 34, 78 ,64, "MGR's VOID FUNCTION")

      @ 44, 27 say "Item Desc  " 
      @ 48, 27 say "Department "
      @ 52, 27 say "Quantity   "
      @ 56, 27 say "Amount     "

      @ 44, 42 say ":"
      @ 48, 42 say ":"
      @ 52, 42 say ":"
      @ 56, 42 say ":"

      cDesc := tran_cDesc()
      cDept := tran_cDept()
      cQty  := tran(tran_nQty(),"@B 999,999")
      cAmt  := tran(tran_nSale(),"@B 999,999,999.99")

      DISPTEXTXY(0,0,0,0,1,1,cDesc)
      DISPTEXTXY(0,0,0,0,2,1,trans(tran_nSale(),"VOID  999,999,999.99"))

      @ 44, 44 get cDesc WHEN .F.
      @ 48, 44 get cDept WHEN .F.
      @ 52, 44 get cQty WHEN .F.
      @ 56, 44 get cAmt WHEN .F.
      
      readmodal()
      
      MsgAreaDisp("Press ENTER to void this item...")
      ckey := 0
      while cKey != ENTER .and. cKey!= CLR
         cKey := input()
      enddo

      CloseWindow(wWindow)

      if cKey != ENTER 
         MsgAreaDisp("Manager's Void function Aborted...")
         BUMMER()
         return nil
      endif   
         

     // check if the last operation can be voided     
     if tran_cFlag() == "N" .or. tran_cFlag() == "M" .or.;
        tran_cFlag() == "P"       

        cDesc := tran_cDesc()
        descriptor := tran_cDesc()
        do case
           case tran_cFlag() == "N" .or. tran_cFlag() == "P" 
               cCode := tran_cPLU()
           otherwise     
               cCode := pad("DEPT: "+tran_cDept(),TRAN_PLU_LEN) 
               tran_cDesc(cCode)               
        endcase       

        out_text := "*MGR'S VOID" +  trans(tran_nQty(), "@ 9999") ;
                    + " @ "  + trans(tran_nPric(), "9999,999.99") + chr(10) 
        rpt_prnt(1, 1, 0, out_text, 0)            
        
        out_text := pad(cDesc,21) + transform(-tran_nSale(), "9999,999.99") + chr(10) 
        rpt_prnt(1, 1, 0, out_text, 0)        
        
        Term_nData( TR_DEPT_TOT , -tran_nSale() )        
        Term_nData( TR_MGRV_TOT , tran_nSale() )                
        Term_nData( TR_MGRV_KNT , 1 )                
        // normalize the transaction subtotal and no of items  
        nSubtotal := nvr_nSUBtotal(nSubtotal - tran_nSale() )
        nvr_nQTYitems(nvr_nQTYitems() - tran_nCntr() )
        tran_cPFlg(tran_cFlag())
        tran_cFlag(OP_MGRV_FLAG)
        edit_trans(curr_item)                

        if tran_cPFlg() == OP_NPLU_FLAG
	  plu_counter(tran_cPLU(), -tran_nCntr(), -tran_nSale(), 0)
 	  dept_counter(tran_cDept(), -tran_nCntr(), -tran_nSale(), 0)
        elseif tran_cPFlg() == OP_NOTF_FLAG      

//	  lNFND_Add(tran_cPLU(),tran_cDesc(),tran_cDept(), -tran_nCntr(), tran_nSale(), 0)
	  lNFND_Add(tran_cPLU(),tran_cDesc(),tran_cDept(), -tran_nCntr(), tran_nPric(), 0)
	  dept_counter(tran_cDept(), -tran_nCntr(), -tran_nSale(), 0)

        elseif tran_cPFlg() == OP_OPEN_FLAG
          dept_counter(tran_cDept(), -tran_nCntr(), -tran_nSale(), 0)
        endif

        nVoidAmt := tran_nSale() 
        nVoidQty := tran_nCntr()
        nPrice   := tran_nPric()

        if curr_item < nvr_nITMitem()
           curr_item++
           tran_init(curr_item)
        endif   

        if tran_cFlag() == OP_IDSC_FLAG
           lWDisc := .T.
           nDiscAmt := tran_nSale()
           nDiscQty := tran_nCntr()
           Term_nData( TR_IDSC_TOT, - tran_nSale() )
           Term_nData( TR_IDSC_KNT, - 1 )        
           tran_cPFlg(tran_cFlag())
           tran_cFlag(OP_MGRV_FLAG)            
           edit_trans(curr_item)            
           curr_item++ // increment to the next record...
           tran_init(curr_item)            
*           ? "this is mgr discount item loop"

           nvr_nSUBtotal( nSubtotal + nDiscAmt )

// Since ITEM DISCOUNT was not less on DEPT TOT 
//         Term_nData( TR_DEPT_TOT, + tran_nSale() )           
// it should'nt be added when voided.
           
           out_text := "*ITEM DISC VOIDED" + chr(10)
           rpt_prnt(1, 1, 0, out_text, 0)
           out_text := pad(trans(nDiscQty, "999% DISCOUNT"),21) + ;
                       trans(nDiscAmt, "9999,999.99")  
           rpt_prnt(1, 1, 0, out_text, 0)                    
        endif
      
        disp_Void( nVoidAmt - nDiscAmt , cCode, nVoidQty, nPrice )

        #ifdef DEF_GRAPHICS
          Disp_BoldChar(nvr_nSUBtotal(), "Total Amount")
          Rcpt_Scrollc(1, descriptor, nVoidQty, nPrice, OP_MGRV_FLAG, nDiscQty, nDiscQty, nDiscAmt, 0, tran_cClrk())
          Disp_LastPage(nvr_nITMitem())
        #endif
   #ifdef VALIDATE_VOID
           // prompt for a slip printer        
           slip_prompt()
        
           // try to print to optional slip printer...
           out_text := space(6) + "*ITEM VOID    " + ;
                        transform(nVoidQty, "@Z 9999") + " @ "  + ;
                        transform(nPrice, "9999,999.99") + chr(10)
           slip_print(out_text, 0)
           out_text := space(6) + pad(cCode,15) + transform(-nVoidAmt, "9999,999.99") + chr(10)
           slip_print(out_text, 0)        

           if lWDisc
             out_text := "*ITEM DISC VOIDED" + chr(10)
             slip_print(space(6) + out_text, 0)        
             out_text := pad(trans(nDiscQty, "999% DISCOUNT"),21) + ;
                         trans(nDiscAmt, "9999,999.99") + chr(10) 
             slip_print(space(6) + out_text, 0)        
           endif
   #endif             
           // Put all the lastest data on the mem variable
           tran_init()
           Rcpt_Footer()
     else           
        ErrorDisp("CAN'T VOID LAST ITEM")                 
     endif
     
  else
     ErrorDisp(MSG_D009)
  endif   

  tran_init()
   
return nil  

function print_void(cFlag,nAmount,cDesc,nQty,nPrice,lMgr)
local out_text
   do case
      case cFlag == OP_IDSC_FLAG
           out_text := "*ITEM DISC VOIDED" + chr(10)
           rpt_prnt(1, 0, 0, out_text, 0)
           out_text := pad(trans(nQty, "999% DISCOUNT"),21) + ;
                       trans(nAmount, "9999,999.99")  
           rpt_prnt(1, 1, 0, out_text, 0)                    
      case cFlag == OP_NPLU_FLAG .or. cFlag == OP_NOTF_FLAG
           out_text := if (lMgr,"*MGR'S VOID","*ITEM VOID ")
           out_text += trans(nQty, "@ 9999") + " @ "  + ;
                       trans(nPrice, "9999,999.99") 
           rpt_prnt(1, 0, 0, out_text, 0)            
        
           out_text := pad(cDesc,21) + transform(-nAmount, "9999,999.99") + chr(10) 
           rpt_prnt(1, 0, 0, out_text, 0)        
   endcase        

return nil

function reprint_void(cFlag,nAmount,cDesc,nQty,nPrice,lMgr)
local out_text
   do case
      case cFlag == OP_IDSC_FLAG
           out_text := "*ITEM DISC VOIDED" + chr(10)
           rpt_prnt(1, 0, 0, out_text, 0)
           out_text := pad(trans(nQty, "999% DISCOUNT"),21) + ;
                       trans(nAmount, "9999,999.99")  
           rpt_prnt(1, 0, 0, out_text, 0)                    
      case cFlag == OP_NPLU_FLAG .or. cFlag == OP_NOTF_FLAG
           out_text := if (lMgr,"*MGR'S VOID","*ITEM VOID ")
           out_text += trans(nQty, "@ 9999") + " @ "  + ;
                       trans(nPrice, "9999,999.99") 
           rpt_prnt(1, 0, 0, out_text, 0)            
        
           out_text := pad(cDesc,21) + transform(-nAmount, "9999,999.99") + chr(10) 
           rpt_prnt(1, 0, 0, out_text, 0)        
   endcase        

return nil


*-----eof()-------------------->
