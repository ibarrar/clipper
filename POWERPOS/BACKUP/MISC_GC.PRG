#include "message.ch"
#include "spec_key.ch"
#include "terminal.ch"
#include "config.ch"
#include "grfx_all.ch"

#define TYPE_GC           "4"

function Misc_GiftCheque(nMisc,cKeyBuff)
local nPaymAmt := val(cKeyBuff)
local nDueAmt  := nvr_nSUBtotal()
local nQty     := nvr_nQtyItems() 
local lRetVal := .F.
local cTypeDesc := "Acct#"
local cKey   := 0, status := 0
local cCode1 := ""
local cCOde3 := ""
local cCode2 := ""
local out_Text := ""
local disp_tot := 0
local title, card, mess
local desc1,cTemp
local add_on_amt := 0
local prev_total := 0
local total_amt  := 0
local addn_desc  := ""
local addn_rate  := 0
local addn_amt   := 0
local i := 0
local desc2
local arrMisc_   := {}
local arrDesc_   := {}
local othinc     := 0
local cWindow
     
    // check if subtotal value is zero
    if empty(nDueAmt)
         ErrorDisp(MSG_D009) // Balance Due is zero...
         return lRetVal
    endif
    disp_clr()
    
    if !( valtype(nMisc) == "N" .and. nMisc > 0 .and. nMisc <=20 )
  
       MsgAreaDisp(MSG_D023)
       for i := 1 to 50
          if (GetMType(i) == TYPE_GC) .and. !empty(GetMDesc(i))       
             aAdd( arrMisc_ , {GetMDesc(i), GetMCode(i), i} )
             aAdd( arrDesc_, GetMDesc(i) )
          endif   
       next i

       while .T. 

          nMisc := aLookUp(30, 35, arrDesc_, " MISC. CHEQUES ")

          if nMisc == 0
             return lRetVal
          elseif nMisc > 0 .and. (GetMtype(arrMisc_[nMisc][3]) == TYPE_GC)
             DISPTEXTXY(3, 1, 0, 0, 0, 0, "CODE FOUND !!!      ")        
             MsgAreaDisp(arrMisc_[nMisc][1])
             BEEP_1()
             tone(15,15)                  
             exit
          else
             DISPTEXTXY(3, 1, 0, 0, 0, 0, "                    ")           
             ErrorDisp("BANK CODE NOT FOUND!")        
          endif       
       enddo
   endif

   if nPaymAmt == 0
        nPaymAmt := nDueAmt
   endif     
  
   if nMisc == 1 
       title := "MISC. CHEQUES"
       card  := "Gift Cheque"
       mess  := "Enter Acct. No."
       desc2 := "Account No."
       
       // add 5% surcharge on total purchase for gift cheque
       addn_rate := 5
       addn_amt := round(nPaymAmt * round(addn_rate * 0.01, 2),2)
       prev_total := nvr_nSUBtotal()
       total_amt  := prev_total + addn_amt
//       nvr_nSUBtotal(total_amt)          // jlp.02.05.98
       
//       nDueAmt := nvr_nSUBtotal()
       nDueAmt  := total_amt
//       Disp_BoldChar(nvr_nSUBtotal(), "Amount Due")              
       Disp_BoldChar(nDueAmt, "Amount Due")       
       addn_desc := trans(addn_rate, "9%") + " Add-On"       
    else   
       title := "MISC CHEQUES"
       card  := "Non-Employee"
       mess  := "Enter Acct. No."
       desc2 := "Account No."
       prev_total := nvr_nSUBtotal()
       nDueAmt := nvr_nSubtotal()
       addn_rate := 0
       addn_amt  := 0
    endif   
    
    if nPaymAmt <= nDueAmt .and. nPaymAmt > 0
      disp_tot := nPaymAmt
    else
      disp_tot := nDueAmt     // nvr_nSUBtotal() . equal lang sila...
    endif      
    
    // Ito ang madugo menstrual
    ?  " Misc type :"
    ?? GetMType(nMisc)

    do case
       case nMisc == 1
         #ifdef DEF_GRAPHICS
            // display screen to getinput for local card payment
            // save screen
            cWindow := OpenWindow(24, 34, 83, 68, title)

            gDrawText(17, 20, "Subtotal", SMALL_FONT, 6, 0, MFIX, LEFT_TEXT)
            gDrawText(18, 20, addn_desc, SMALL_FONT, 6, 0, MFIX, LEFT_TEXT)
            gDrawText(19, 20, padr(subs(arrMisc_[nMisc][1],12),12), SMALL_FONT, 6, 0, MFIX, LEFT_TEXT)
            gDrawText(20, 20, desc2, SMALL_FONT, 6, 0, MFIX, LEFT_TEXT)

            gDrawText(17, 32, ":" , SMALL_FONT, 6, 0, MFIX, LEFT_TEXT)
            gDrawText(18, 32, ":" , SMALL_FONT, 6, 0, MFIX, LEFT_TEXT)      
            gDrawText(19, 32, ":" , SMALL_FONT, 6, 0, MFIX, LEFT_TEXT)   
            gDrawText(20, 32, ":" , SMALL_FONT, 6, 0, MFIX, LEFT_TEXT)

            gDrawText(17, 33, ltrim(transform(prev_total, "999,999.99")) , ;
             SMALL_FONT, 6, 0, MFIX, LEFT_TEXT)
            gDrawText(18, 33, ltrim(transform(addn_amt, "999,999.99")) , ;
             SMALL_FONT, 6, 0, MFIX, LEFT_TEXT)             
            gDrawText(19, 33, ltrim(transform(disp_tot, "999,999.99")) , ;
             SMALL_FONT, 6, 0, MFIX, LEFT_TEXT)

            MsgAreaDisp(mess)
            gDrawText(20, 33, CHR(95), SMALL_FONT, 6, 0, MFIX, LEFT_TEXT)

         #endif

         // disp 4x20  Display the charged amount 
         DISPTEXTXY(1, 1, 0, 0, 0, 0, "G.C. SLIP  :"+trans(nPaymAmt,"999,999.99"))
         DISPTEXTXY(2, 1, 0, 0, 1, 1, "G.C. #  :            ")
    
         MsgAreaDisp("ENTER ACCT. NO.")
         #ifdef DEF_GRAPHICS
           cCode1 := Grfx_Data(2, 11, 0, 0, 2, 1, { |x| ((!empty(is_number(x)) .and. x != KEY_PERIOD ) .or. (!empty(is_alpha(x)) .and. x != KEY_PERIOD )) } , 20, "ENTER CHEQUE NO.", 3 )
         #else
           cCode1 := ReadData(2, 11, 0, 0, 1, 11, { |x| ((!empty(is_number(x)) .and. x != KEY_PERIOD ) .or. (!empty(is_alpha(x)) .and. x != KEY_PERIOD )) } , 20, "ENTER GIFTCHEQUE NO." )
         #endif                 
         if empty(cCode1)
           #ifdef DEF_GRAPHICS
            // restore previous screen
            CloseWindow(cWindow)
           #endif   
            nvr_nSUBtotal(prev_total)
            Disp_BoldChar(nvr_nSUBtotal(), "Total Amount")
            return lRetVal
         endif   
             
         cCode1 := padl(alltrim(cCode1),20,"0")      
         DISPTEXTXY(2, 11, 0, 0, 1, 11, cCode1 + "   " )

         #ifdef DEF_GRAPHICS
           gClearTo(46, 57, 75, 60, 7)
           gDrawText(20, 33, cCode1, SMALL_FONT, 6, 0, MFIX, LEFT_TEXT)
*           gDrawText(21, 33, chr(95), SMALL_FONT, 6, 0, MFIX, LEFT_TEXT)    
         #endif

         DISPTEXTXY(1, 1, 0, 0, 1, 0, "BAL DUE : "+trans(nDueAmt,"999,999.99")  )
         DISPTEXTXY(2, 1, 0, 0, 2, 1, "CHARGE  : "+trans(nPaymAmt,"999,999.99") )
         DISPTEXTXY(3, 1, 0, 0, 0, 1, "CHANGE  : "+trans(nPaymAmt-nDueAmt,"999,999.99"))
         
#ifdef SLIP_PRNT
         // add_invoice({ nMisc , nPaymAmt } )

         slip_prompt("INSERT G.C. SLIP....")

         out_text := "BEGINNING BALANCE   "+space(12)+trans(begin_bal, "***,**9.99") + chr(10)
         slip_check(out_text)
         out_text := "AMOUNT PURCHASED("+padr(arrMisc_[nMisc][1]+")",15)+trans(nPaymAmt, "***,**9.99") + chr(10)
         slip_check(out_text)         
         out_text := "NEW BALANCE         "+space(12)+trans(begin_bal-nPaymAmt, "***,**9.99") + chr(10) 
         slip_check(out_text)

         slip_check(" " + chr(10), 0)         
         out_text := space(13) + "NO. OF ITEMS " + transform(nvr_nQTYitems(), "999") + chr(10)
         slip_check(out_text)
                           
         out_text := dtoc(date()) + '  ' + substr(time(), 1, 5) + '  ' + ;
                  subs(nvr_cCashCode(),1,3) + '***  ' + padl(nvr_nTrans(), 6, "0") + "#  " +;
                  config(POS_TERM_NUM) +  chr(10)
         slip_check(out_text)                                 
#endif
       case nMisc == 2

         #ifdef DEF_GRAPHICS
            // display screen to getinput for local card payment
            // save screen
            cWindow := OpenWindow(24, 34, 83, 64, title)

            gDrawText(17, 20, arrMisc_[nMisc][1], SMALL_FONT, 6, 0, MFIX, LEFT_TEXT)
            gDrawText(18, 20, desc2, SMALL_FONT, 6, 0, MFIX, LEFT_TEXT)
*            gDrawText(19, 20, desc1, SMALL_FONT, 6, 0, MFIX, LEFT_TEXT)

            gDrawText(17, 32, ":" , SMALL_FONT, 6, 0, MFIX, LEFT_TEXT)
            gDrawText(18, 32, ":" , SMALL_FONT, 6, 0, MFIX, LEFT_TEXT)      
*            gDrawText(19, 32, ":" , SMALL_FONT, 6, 0, MFIX, LEFT_TEXT)   

            gDrawText(17, 33, ltrim(transform(disp_tot, "999,999.99")) , ;
             SMALL_FONT, 6, 0, MFIX, LEFT_TEXT)

            MsgAreaDisp(mess)
            gDrawText(18, 33, CHR(95), SMALL_FONT, 6, 0, MFIX, LEFT_TEXT)

         #endif       

         // disp 4x20  Display the charged amount 
         DISPTEXTXY(1, 1, 0, 0, 0, 0, "OTHERS   :"+trans(nPaymAmt,"999,999.99"))
         DISPTEXTXY(2, 1, 0, 0, 0, 0, "ACCT.No.:          " )
         #ifdef DEF_GRAPHICS
           cCode1 := Grfx_Data(2, 11, 0, 0, 2, 1, { |x| ((!empty(is_number(x)) .and. x != KEY_PERIOD ) .or. !empty(is_alpha(x))) } , 20, "ENTER CHEQUE NUMBER", 1 )
         #else    
           cCode1 := ReadData(2, 11, 0, 0, 1, 11, { |x| ((!empty(is_number(x)) .and. x != KEY_PERIOD ) .or. !empty(is_alpha(x))) } , 20, "ENTER ACCOUNT NUMBER" )
         #endif  
         if empty(cCode1)
            #ifdef DEF_GRAPHICS
              // restore previous screen
              CloseWindow(cWindow)
            #endif
            nvr_nSUBtotal(prev_total)
            Disp_BoldChar(nvr_nSUBtotal(), "Total Amount")
            return lRetVal
         endif   

         cCode1 := padl(alltrim(cCode1),20,"0")      
         
         // display the account no. entered then ask the expiry date
         #ifdef DEF_GRAPHICS
           gClearTo(46, 51, 75, 54, 7)
           gDrawText(18, 33, cCode1, SMALL_FONT, 6, 0, MFIX, LEFT_TEXT)
*           gDrawText(19, 33, chr(95), SMALL_FONT, 6, 0, MFIX, LEFT_TEXT)    
         #endif
/*         
         while .T.           
           MsgAreaDisp("ENTER BEGINNING BAL.")
           DISPTEXTXY(3, 1, 0, 0, 2, 1, "BEG.BAL.:           ")
           #ifdef DEF_GRAPHICS
             cCode3 := Grfx_Data(3, 1, 0, 0, 2, 1, { |x| ((!empty(is_number(x)) .and. x != KEY_PERIOD ) .or. !empty(is_alpha(x))) } , 10, "ENTER BEGINNING BAL.", 2)
           #else
             cCode3 := ReadData(3, 11, 0, 0, 2, 11, { |x| !empty(is_number(x)) } , 10 , "ENTER BEGINNING BAL.")
           #endif 
           if !empty(cCode3) 
               if !("."$cCode3)
                  if len(cCode3) < 3
                     cCode3 := padl(cCode3,3,"0")
                  endif 
                  cCode3 := stuff(cCode3,len(cCode3)-1,0,".") 
               endif   
            #ifdef DEF_GRAPHICS
             gClearTo(46, 54, 75, 57, 7)
             gDrawText(19, 33, cCode3, SMALL_FONT, 6, 0, MFIX, LEFT_TEXT)
            #endif
           else
             exit    
           endif     
           if val(cCode3) < nPaymAmt
              ErrorDisp("INSUFFICIENT BALANCE")
              #ifdef DEF_GRAPHICS
               gClearTo(46, 54, 75, 57, 7)
               gDrawText(19, 33, chr(95), SMALL_FONT, 6, 0, MFIX, LEFT_TEXT)
              #endif
           elseif val(cCode3) > TOTAMT_HALO
              ErrorDisp(MSG_E009)                 
              #ifdef DEF_GRAPHICS
               gClearTo(46, 54, 75, 57, 7)
               gDrawText(19, 33, chr(95), SMALL_FONT, 6, 0, MFIX, LEFT_TEXT)
              #endif
           else 
              begin_bal := val(cCode3)
              exit   
           endif   
         enddo  
         
         if empty(cCode3)
            #ifdef DEF_GRAPHICS
              // restore previous screen
              CloseWindow(cWindow)
            #endif
           return lRetVal
         endif  
*/         
    endcase

    #ifdef DEF_GRAPHICS
      MsgAreaDisp("Press Any Key to Continue...")
      input()
      // restore previous screen
      CloseWindow(cWindow)
      MsgAreaDisp(MSG_D018)
    #endif

    if nPaymAmt > nDueAmt

      MsgAreaDisp("<OTH_INC> TO CONFIRM")
      BEEP_4() 

      while .t.
      
        if input() == OTH_INC
      
            othinc := nPaymAmt - nDueAmt
            // POS receipt and journal printer...
            // skip one line...
            A_RJS_FEED(1, 1, 0, 1)                      

            out_text := "*OTHINC(" + arrMisc_[nMisc][1] + ")" + trans(othinc,"99,999.99") + chr(10) 
            rpt_prnt(1, 0, 0, out_text, 0)                       

            // on journal...
            out_text := "*OTHINC(" + arrMisc_[nMisc][1] + ")" + trans(othinc,"99,999.99") + chr(10) 
            rpt_prnt(0, 1, 0, out_text, 0)                                                      

            // then make a new record for the add-on record
            tran_cPLU(  "" ) 
            tran_cItem( "" )
            tran_cDept( "" )
            tran_cFlag( OP_OINC_FLAG ) // Flag Set As Other Income by ret-exch.
            tran_cPFlg( "0" )
            tran_cRegM( "0" ) // Temporarily set as keyboard method of entry
            tran_cPrcM( "0" ) // Temporarily set as normal pricing method
            tran_cConc( "" ) // Concessionaire
            tran_cColo( "" )  
            tran_cSize( "" ) 
            tran_nSale( othinc  ) 
            tran_nCntr( 1 ) 
            tran_nPric( othinc )
            tran_nQty ( 1 )
            tran_cDesc("Other income")
            Update_Trans()
                                     
            Term_nData(TR_OINC_TOT, othinc)
            Term_nData(TR_OINC_KNT, 1 )                     

            // add oth. inc. to daily sales  
            Term_nData(TR_DSLS_TOT, othinc)
            exit
        endif
      enddo
           
    endif
         
    if config(POS_ISLIP_PRN) == "YES"
       rpt_prnt(0, 1, 0, space(10), 0)

       do while .T.
         MsgAreaDisp("Insert Slip & Press <VALID> key to Validate or <CLR> to exit")
         cKey := input()
            if cKey == VALIDATE
              // validate first, before printing 
              if config(POS_ISLIP_PRN) == "YES"
                 out_text := "TOTAL" + ' ' + transform(disp_tot, "***,**9.99") + ' ' + ;
                             "ACCT#" + ' ' + cCode1 + ' ' + dtoc(date()) + ;
                             ' ' + padl(nvr_nTrans(), 6, "0") + '# ' + subs(nvr_cCashCode(),1,3) + ;
                             ' ' + config(POS_TERM_NUM) + chr(10)   
                 status := valid_prnt(out_text, 1)
                 A_RJS_FEED(0, 1, 0, 1)
                 MsgAreaDisp("Remove Sales Slip & Press <Enter> key to Continue") 
                 do while .T.
                   cKey := input()
                   if cKey == ENTER
                     exit
                   endif  
                 enddo
              endif
            elseif cKey == CLR   
              exit
            endif  
       enddo
    endif    

    if nDueAmt > nPaymAmt .and. nPaymAmt > 0

          // here is where the actual payment is processed....
          MsgAreaDisp(MSG_D015) // Aknowledge partial payment
          tone(15,18) // delay exactly one second...         
          
          #ifdef DEF_GRAPHICS
            Disp_PayAmt(arrMisc_[nMisc][1] + " #" + cCode1, nDueAmt, nPaymAmt, nDueAmt - nPaymAmt)
          #endif          

#ifdef OPEN_DRAWER
          open_drawr()
          MsgAreaDisp(MSG_D014) // Close Drawer msg
#endif          
          // customer display 2
          // cashier display (4X20)
          out_text := "BAL DUE : " + trans(nDueAmt, "999,999.99")
          DISPTEXTXY(1, 1, 0, 0, 1, 1, out_text )
          out_text := " CHARGE : " + trans(nPaymAmt,"999,999.99")
          DISPTEXTXY(2, 1, 0, 0, 2, 1, out_text )
          out_text := " CHANGE : " + trans(nPaymAmt-nDueAmt,"999,999.99")
          DISPTEXTXY(3, 1, 0, 0, 0, 0, out_text )                  

          // POS printer...
          // skip one line...
          A_RJS_FEED(1, 1, 0, 1)   

          if nMisc == 1
             out_text := trans(addn_rate,"9% ") + " Handling Fee" + space(6) + trans(addn_amt, "999,999.99")
             rpt_prnt(1, 1, 0, out_text, 1)
          endif    
          
          out_text := padl("SUBTOTAL ",22) + trans(nDueAmt, "999,999.99") + chr(10) 
          rpt_prnt(1, 0, 0, out_text, 0)                    

          A_RJS_FEED(1, 1, 0, 1)   

          out_text := "Acct#" + cCode1
          rpt_prnt(1, 0, 0, out_text, 0)          
         
          out_text := pad(arrMisc_[nMisc][1], 21) + trans(nPaymAmt,"999,999.99")
          rpt_prnt(1, 1, 0, out_text, 0 )                     

          out_text := padl("BAL. DUE ",22) + trans(nDueAmt - nPaymAmt, "999,999.99") + chr(10) 
          rpt_prnt(1, 0, 0, out_text, 0)          

          // then on journal...
          out_text := arrMisc_[nMisc][1] + chr(10)
          rpt_prnt(0, 1, 0, out_text, 0)

          out_text := "Acct.# " +  cCode1 + chr(10)
          rpt_prnt(0, 1, 0, out_text, 0)

          out_text := space(14) + trans(nPaymAmt, "999,999.99") + chr(10)      
          rpt_prnt(0, 1, 0, out_text, 0)

          tran_cFlag( OP_ADON_FLAG ) // Found the plu set as normal
          tran_cRegM( RegMode() ) 
          tran_cPflg(  "1" )
          tran_cPrcM(  "0" ) // Temporarily set as normal pricing method
          tran_nSale( addn_amt ) 
          tran_nCntr( addn_rate ) 
          tran_cClrk( "" )
          tran_cCrgo( "" )
          tran_cDesc( "" )
          tran_nPric( addn_amt )
          tran_nQty ( addn_rate )
     
          Update_Trans()
          
          payment(nPaymAmt,(nDueAmt - nPaymAmt), arrMisc_[nMisc][3], cCode1,cCode2,cCode3)  

          nDueAmt -= nPaymAmt
          nvr_nSUBtotal(nDueAmt)
          // Add to the terminal file
          Term_nData(TR_DSLS_TOT,nPaymAmt)            // First the Totals  
                
          Term_nData(7+((arrMisc_[nMisc][3]-1)*2),nPaymAmt)        
          Term_nData(8+((arrMisc_[nMisc][3]-1)*2),1)     // Then the Quantities
        
          // add add-amt to add-on fields (total & count)
          Term_nData(TR_ADON_TOT, addn_amt)
          Term_nData(TR_ADON_KNT, if(addn_amt!=0,1,0)) 

          DispSubTotal()
          #ifdef DEF_GRAPHICS
            Disp_BoldChar(nvr_nSUBtotal(), "Amount Due")
          #endif                        
      else      

         // display charge payment
         disp_clr()

         #ifdef DEF_GRAPHICS
           Disp_PayAmt(arrMisc_[nMisc][1] + " #" + cCode1, nDueAmt, nPaymAmt, nDueAmt - nPaymAmt)
         #endif   

         // cust display 1
         out_text := "C" + trans(nDueAmt,"999999.99")
         DISPTEXTXY(0, 0, 1, 1, 0, 0, out_text)

         // customer display 2
         // cashier display (4X20)
         out_text := "BAL DUE : " + trans(nDueAmt, "999,999.99")
         DISPTEXTXY(1, 1, 0, 0, 1, 1, out_text )
         out_text := " CHARGE : " + trans(nPaymAmt,"999,999.99")
         DISPTEXTXY(2, 1, 0, 0, 2, 1, out_text )
         out_text := " CHANGE : " + trans(nPaymAmt-nDueAmt,"999,999.99")
         DISPTEXTXY(3, 1, 0, 0, 0, 0, out_text )                  


#ifdef OPEN_DRAWER
         open_drawr()
         MsgAreaDisp(MSG_D014) // Close Drawer msg
#endif         
  
         // POS receipt printer...
         // skip one line...
         A_RJS_FEED(1, 0, 0, 1)

         if nMisc == 1
            out_text := trans(addn_rate, "9% ") + "Handling Fee" + space(6) + trans(addn_amt, "9999,999.99")
            rpt_prnt(1, 1, 0, out_text, 1)
         endif   

         out_text := "Acct# " + cCode1 + chr(10)
         rpt_prnt(1, 0, 0, out_text, 0)                    
         
         out_text := pad(arrMisc_[nMisc][1], 21) + transform(nPaymAmt, "999,999.99") + chr(10) 
         rpt_prnt(1, 0, 0, out_text, 0)

         // then on journal
         out_text := "Acct# " + cCode1 + chr(10)
         rpt_prnt(0, 1, 0, out_text, 0)

         out_text := pad(arrMisc_[nMisc][1],21) + transform(nPaymAmt, "999,999.99") + chr(10) 
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

        tran_cFlag( OP_ADON_FLAG ) // Found the plu set as normal
	tran_cRegM( RegMode() ) 
	tran_cPflg(  "1" )
	tran_cPrcM(  "0" ) // Temporarily set as normal pricing method
	tran_nSale( addn_amt ) 
	tran_nCntr( addn_rate ) 
	tran_cClrk( "" )
	tran_cCrgo( "" )
	tran_cDesc( "" )
	tran_nPric( addn_amt )
	tran_nQty ( addn_rate )
     
	Update_Trans()
                
        payment(nPaymAmt,(nDueAmt - nPaymAmt), arrMisc_[nMisc][3], cCode1, cCode2, cCode3)  
        
        nvr_nSubtotal(nDueAmt)   //jlp.02.05.98

        // update first the terminal file
        Term_nData(TR_DSLS_TOT,nvr_nSUBtotal())
        Term_nData(TR_DSLS_KNT,1)               
        
        // Term_nData(7+((arrMisc_[nMisc][3]-1)*2),nvr_nSUBtotal())        
        Term_nData(7+((arrMisc_[nMisc][3]-1)*2),nPaymAmt)        
        Term_nData(8+((arrMisc_[nMisc][3]-1)*2),1)

        // add add-amt to add-on fields (total & count)
        Term_nData(TR_ADON_TOT, addn_amt)
        Term_nData(TR_ADON_KNT, if(addn_amt!=0,1,0)) 

        // Update nvram in this case resetting to 0
        nvr_nSUBtotal(0)         
        nvr_nQtyitems(0)               

        #ifdef DEF_GRAPHICS
          Disp_BoldChar(nvr_nSUBtotal(), "Total Amount")
        #endif     
            
        prnt_end( nQty  )      
        lRetVal := .T.                        
    endif   

return lRetVal
    