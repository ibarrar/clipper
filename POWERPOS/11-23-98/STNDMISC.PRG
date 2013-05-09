#include "message.ch"
#include "spec_key.ch"
#include "terminal.ch"
#include "config.ch"

#define TYPE_GC             "3"
#define TYPE_OTHERS         "7"

function Misc_Payment(nMisc,cKeyBuff)
local nPaymAmt := val(cKeyBuff)
local nDueAmt  := nvr_nSUBtotal()
local nQty     := nvr_nQtyItems() 
local lRetVal := .F.
local cTypeDesc := "Acct#"
local cCode1 := ""
local cCOde3 := ""
local cCode2 := ""
local out_Text := ""


    // check if subtotal value is zero
    if empty(nDueAmt)
         ErrorDisp(MSG_D009) // Balance Due is zero...
         return lRetVal
    endif

    if nPaymAmt > nDueAmt
       ErrorDisp("EXCESS CHARGE AMOUNT")
       return lRetVal
    endif   

    disp_clr()
    if nPaymAmt == 0
       nPaymAmt := nDueAmt
    endif
#ifdef DEF_DISP1X09
    DISPTEXTXY(0, 0, 1, 1, 0, 0, trans(nPaymAmt,"9999999.99"))
#endif

    // Ito ang madugo menstrual
    ?  " Misc type :"
    ?? GetMType(nMisc)

    do case
       case GetMType(nMisc) == TYPE_GC
         cTypeDesc := "G.C.#"
         // disp 4x20  Display the charged amount 
         DISPTEXTXY(1, 1, 0, 0, 0, 0, "GC SLIP  :"+trans(nPaymAmt,"999,999.99"))
         DISPTEXTXY(2, 1, 0, 0, 1, 1, "G.C. #  :            ")
    
         MsgAreaDisp("ENTER GIFTCHEQUE NO.")
         cCode1 := ReadData(2, 11, 0, 0, 1, 11, { |x| ((!empty(is_number(x)) .and. x != KEY_PERIOD ) .or. !empty(is_alpha(x))) } , 8, "ENTER GIFTCHEQUE NO." )
         if empty(cCode1)
            return lRetVal
         endif   
             
         cCode1 := padl(alltrim(cCode1),8,"0")      
         DISPTEXTXY(2, 11, 0, 0, 1, 11, cCode1 + "   " )

         while .T.           
           MsgAreaDisp("ENTER BEGINNING BAL.")
           DISPTEXTXY(3, 1, 0, 0, 2, 1, "BEG.BAL.:           ")
           cCode3 := ReadData(3, 11, 0, 0, 2, 11, { |x| !empty(is_number(x)) } , 10 , "ENTER BEGINNING BAL.")
           if !empty(cCode3) 
               if !("."$cCode3)
                  if len(cCode3) < 3
                     cCode3 := padl(cCode3,3,"0")
                  endif 
                  cCode3 := stuff(cCode3,len(cCode3)-1,0,".") 
               endif   
           else
             exit    
           endif     
           if val(cCode3) < nPaymAmt
              ErrorDisp("INSUFFICIENT BALANCE")
           elseif val(cCode3) > TOTAMT_HALO
              ErrorDisp(MSG_E009)                 
           else 
              exit   
           endif   
         enddo  

         if empty(cCode3)
           return lRetVal
         endif  
             
         out_text := trans(val(cCode3),"999,999.99")      
         DISPTEXTXY(3, 11, 0, 0, 2, 11, out_text   )                  

         DISPTEXTXY(1, 1, 0, 0, 0, 0, "BAL DUE : "+trans(nDueAmt,"999,999.99")  )
         DISPTEXTXY(2, 1, 0, 0, 1, 1, "CHARGE  : "+trans(nPaymAmt,"999,999.99") )
         DISPTEXTXY(3, 1, 0, 0, 2, 1, "CHANGE  : "+trans(nPaymAmt-nDueAmt,"999,999.99"))

#ifdef SLIP_PRNT         
         add_invoice({ nMisc , nPaymAmt } )

         slip_prompt("INSERT G.C. SLIP....")

         out_text := "BEGINNING BALANCE   "+space(12)+trans(val(cCode3), "***,**9.99") + chr(10)
         slip_check(out_text)
         out_text := "AMOUNT PURCHASED("+padr(GetMDesc(nMisc)+")",15)+trans(nPaymAmt, "***,**9.99") + chr(10)
         slip_check(out_text)         
         out_text := "NEW BALANCE         "+space(12)+trans(val(cCode3)-nPaymAmt, "***,**9.99") + chr(10) 
         slip_check(out_text)

         slip_check(" " + chr(10), 0)         
         out_text := space(13) + "NO. OF ITEMS " + transform(nvr_nQTYitems(), "999") + chr(10)
         slip_check(out_text)
                           
         out_text := dtoc(date()) + '  ' + substr(time(), 1, 5) + '  ' + ;
                  subs(nvr_cCashCode(),1,3) + '***  ' + padl(nvr_nTrans(), 6, "0") + "#  " +;
                  config(POS_TERM_NUM) +  chr(10)
         slip_check(out_text)                                 
#endif         
       case GetMType(nMisc) == TYPE_OTHERS
       
         cTypeDesc := "ACCT.No.:"
         // disp 4x20  Display the charged amount 
         DISPTEXTXY(1, 1, 0, 0, 0, 0, "OTHERS   :"+trans(nPaymAmt,"999,999.99"))
         DISPTEXTXY(2, 1, 0, 0, 0, 0, "ACCT.No.:          " )    
         cCode1 := ReadData(2, 11, 0, 0, 1, 11, { |x| ((!empty(is_number(x)) .and. x != KEY_PERIOD ) .or. !empty(is_alpha(x))) } , 8, "ENTER ACCOUNT NUMBER" )
         if empty(cCode1)
            return lRetVal
         endif   
             
         cCode1 := padl(alltrim(cCode1),8,"0")      
         DISPTEXTXY(2, 11, 0, 0, 1, 11, cCode1 + " " )

         cCode3 := ""
#ifdef SLIP_PRNT
         add_invoice({ nMisc , nPaymAmt } )
#endif         

    endcase
        
    if nDueAmt > nPaymAmt .and. nPaymAmt > 0

          // here is where the actual payment is processed....
          MsgAreaDisp(MSG_D015) // Aknowledge partial payment
          tone(15,18) // delay exactly one second...         
          
#ifdef OPEN_DRAWER
          open_drawr()
          MsgAreaDisp(MSG_D014) // Close Drawer msg
#endif          

          // POS printer...
          // skip one line...
          A_RJS_FEED(1, 1, 0, 1)   

          out_text := padl("SUBTOTAL ",22) + trans(nDueAmt, "999,999.99") + chr(10) 
          rpt_prnt(1, 0, 0, out_text, 0)          
                    

          A_RJS_FEED(1, 1, 0, 1)   
          
          out_text := cTypeDesc + cCode1  
          rpt_prnt(1, 0, 0, out_text, 0)

          if !empty(cCode2) 
            out_text := "Acct#" + cCode2 
            rpt_prnt(1, 0, 0, out_text, 0)          
          endif  

          out_text := pad(GetMDesc(nMisc),22) + trans(nPaymAmt,"999,999.99")
          rpt_prnt(1, 1, 0, out_text, 0 )                     

          out_text := padl("BAL. DUE ",22) + trans(nDueAmt - nPaymAmt, "999,999.99") + chr(10) 
          rpt_prnt(1, 0, 0, out_text, 0)          

          // then on journal...
          out_text := GetMDesc(nMisc) + chr(10)
          rpt_prnt(0, 1, 0, out_text, 0)

          out_text := cTypeDesc + cCode1 + chr(10)
          rpt_prnt(0, 1, 0, out_text, 0)

          if !empty(cCode2)  
            out_text := "Acct#" + cCode2 
            rpt_prnt(0, 1, 0, out_text, 0)                    
          endif  

          out_text := space(14) + trans(nPaymAmt, "999,999.99") + chr(10)      
          rpt_prnt(0, 1, 0, out_text, 0)
          
          payment(nPaymAmt,(nDueAmt - nPaymAmt), nMisc, cCode2,cCode1)  

          nDueAmt -= nPaymAmt
          nvr_nSUBtotal(nDueAmt)
          // Add to the terminal file
          Term_nData(TR_DSLS_TOT,nPaymAmt)            // First the Totals  
                
          Term_nData(7+((nMisc-1)*2),nPaymAmt)        
          Term_nData(8+((nMisc-1)*2),1)     // Then the Quantities
        
          DispSubTotal()
                    
      else      

         // display charge payment
         disp_clr()

         // cust display 1
         out_text := "C" + trans(nDueAmt,"999999.99")
         DISPTEXTXY(0, 0, 1, 1, 0, 0, out_text)

         // customer display 2
         out_text := " CHARGE : " + trans(nPaymAmt, "999,999.99")
         DISPTEXTXY(0, 0, 0, 0, 1, 1, out_text)

         out_text := " CHANGE : " + trans(nPaymAmt-nDueAmt,"999,999.99")
         DISPTEXTXY(0, 0, 0, 0, 2, 1, out_text)

         // cashier display (4X20)
         out_text := "BAL DUE : " + trans(nDueAmt, "999,999.99")
         DISPTEXTXY(1, 1, 0, 0, 0, 0, out_text )
         out_text := " CHARGE : " + trans(nPaymAmt,"999,999.99")
         DISPTEXTXY(2, 1, 0, 0, 0, 0, out_text )
         out_text := " CHANGE : " + trans(nPaymAmt-nDueAmt,"999,999.99")
         DISPTEXTXY(3, 1, 0, 0, 0, 0, out_text )                  


#ifdef OPEN_DRAWER
         open_drawr()
         MsgAreaDisp(MSG_D014) // Close Drawer msg
#endif         
  
         // POS receipt printer...
         // skip one line...
         A_RJS_FEED(1, 0, 0, 1)

         out_text := cTypeDesc + cCode1 + " " + chr(10) 
         rpt_prnt(1, 0, 0, out_text, 0)
         
         if !empty(cCode2)  
           out_text := "Acct#" + cCode2 
           rpt_prnt(1, 0, 0, out_text, 0)                    
         endif  
         
         out_text := pad(GetMDesc(nMisc), 22) + transform(nDueAmt, "999,999.99") + chr(10) 
         rpt_prnt(1, 0, 0, out_text, 0)


         out_text := cTypeDesc + cCode1 + chr(10)
         rpt_prnt(0, 1, 0, out_text, 0)

         if !empty(cCode2)  
           out_text := "Acct#" + cCode2 
           rpt_prnt(0, 1, 0, out_text, 0)                    
         endif           
         
         out_text := pad(GetMDesc(nMisc),22) + transform(nDueAmt, "999,999.99") + chr(10) 
         rpt_prnt(0, 1, 0, out_text, 0)

         out_text := space(16) + "SUBTL " + transform(nDueAmt, "999,999.99") + chr(10) 
         rpt_prnt(1, 0, 0, out_text, 0)

        out_text := space(16) + "TOTAL " + transform(nDueAmt, "999,999.99") + chr(10) 
        rpt_prnt(1, 0, 0, out_text, 0)

        // then on journal...
        out_text := pad("SUBTOTAL",22) + transform(nDueAmt, "999,999.99") + chr(10)
        rpt_prnt(0, 1, 0, out_text, 0)
#ifdef SLIP_PRNT
        // now print all the charge invoice 
        print_invoice()        
#endif        
                
        payment(nPaymAmt,(nDueAmt - nPaymAmt), nMisc, cCode2, cCode1)  
        
        // update first the terminal file
        Term_nData(TR_DSLS_TOT,nvr_nSUBtotal())
        Term_nData(TR_DSLS_KNT,1)               
        
        Term_nData(7+((nMisc-1)*2),nvr_nSUBtotal())        
        Term_nData(8+((nMisc-1)*2),1)

        // Update nvram in this case resetting to 0
        nvr_nSUBtotal(0)         
        nvr_nQtyitems(0)               
            
        prnt_end( nQty  )      
        lRetVal := .T.                        
    endif   

return lRetVal

/* EOF */
