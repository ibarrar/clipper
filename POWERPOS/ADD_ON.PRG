#include "terminal.ch"
#include "message.ch"
#include "config.ch"

function addon(cDataBuff,lRate)
local lRetVal := .F.
local nAmount
local nRate
local out_text
local descriptor

   if !lRate
     // Put a decimal if there is none          
     if !empty(cDataBuff) 
        if !("."$cDataBuff)
           if len(cDataBuff) < 3
              cDataBuff := padl(cDataBuff,3,"0")
           endif 
           cDataBuff := stuff(cDataBuff,len(cDataBuff)-1,0,".") 
        endif   
     endif            
     nAmount := val(cDataBuff)   
     nRate := nAmount/(nvr_nSUBtotal() * 0.01 )
     nRate := round(nRate,2)
   else
     nRate := val(cDataBuff)
     nAmount := nRate * 0.01 * nvr_nSUBtotal()
     nAmount := round(nAmount,2)
   endif   

   if nAmount <= 0
      ErrorDisp("CAN'T ADD ZERO AMT.!")
/*   elseif nAmount > val(config(POS_ADDON_AMT)) .or. nRate > 100
      ErrorDisp("ADDON LIMIT EXCEEDED") */
   else        
      tran_cFlag( OP_ADON_FLAG ) // Found the plu set as normal
      tran_cRegM( RegMode() ) 
      tran_cPflg(  "0" )
      tran_cPrcM(  "0" ) // Temporarily set as normal pricing method
      tran_nSale( nAmount ) 
      tran_nCntr( nRate ) 
      tran_cClrk( "" )
      tran_cCrgo( "" )
      tran_cDesc( "" )
      tran_nPric( nAmount )
      tran_nQty ( nRate )
     
      Update_Trans()

      #ifdef DEF_GRAPHICS
        if !lRate
           descriptor := "AMOUNT ADD-ON "
        else
           descriptor := transform(nRate, "@Z 99% ") + "ADD-ON"
        endif
        Disp_PayAmt(descriptor, nvr_nSUBtotal(), nAmount, nvr_nSUBtotal() + nAmount)
        Disp_BoldChar(nvr_nSUBtotal() + nAmount)
      #endif

      out_text := pad("SUBTOTAL",21) + tran(nvr_nSUBTotal() ,"9999,999.99")
      A_RJS_PRNT(1, 1, 0, out_text, 0)                  
     
      // normalize the transaction subtotal and no of items  
      nvr_nSUBtotal(nvr_nSUBtotal() + nAmount)           
 
      disp_Addon(nRate,nAmount)         
      Term_nData( TR_ADON_TOT , nAmount)
      Term_nData( TR_ADON_KNT , 1 )
      
      
      if lRate
        out_text := pad(tran(nRate,"@Z 999.99% ADD-ON"),21) + trans(nAmount, "9999,999.99")
      else
        out_text := pad("* ADD-ON AMOUNT",21) + trans(nAmount, "9999,999.99") 
      endif
      A_RJS_PRNT(1, 1, 0, out_text, 0)            
         
      // try to print to optional slip printer...
      out_text := space(6) + pad(trans(nRate,"@Z 999.99% ADD-ON"),24) + ;
                  transform(nAmount, "9999,999.99") + chr(10)
      slip_print(out_text, 0)         
      lRetVal := .T.   
   endif  

return lRetVal


function disp_Addon(nRate,nAmount)         
local out_text
  disp_clr()  
  DISPTEXTXY(1, 1, 1, 1, 1, 1, MSG_CLEAR )
  out_text := trans( nRate , "999%") + " ADDON" + trans(nAmount,"999,999.99")
  DISPTEXTXY(2, 1, 0, 0, 2, 1, out_text)
  DISPTEXTXY(3, 1, 0, 0, 0, 0, "* SUBTOTAL ADD-ON *")
return nil

function reprint_Addon(nRate,nAmount)
local out_text

   out_text := pad(tran(nRate,"@Z 999.99% ADD-ON"),21) + trans(nAmount, "9999,999.99")
   A_RJS_PRNT(1, 0, 0, out_text, 0)            
      
return nil      