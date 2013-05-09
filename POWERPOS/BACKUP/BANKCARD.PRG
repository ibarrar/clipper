#include "pfl_clip.ch"
#include "message.ch"
#include "keymap.ch"
#include "config.ch"
#include "terminal.ch"
#include "spec_key.ch"

#ifdef DEF_GRAPHICS
 #include "grfx_all.ch"
 #include "inkey.ch"
#endif

#define TYPE_BANKCARD       "0"

function Bank_Payment(nMisc,cKeyBuff)
local cKey
local cDispBuff := ""
local cData
local lRetVal := .F.
local disp_tot := 0
local nPaymAmt := val(cKeyBuff)
local nDueAmt  := nvr_nSUBtotal()
local nQty     := nvr_nQtyItems() 
local out_text
local cCode1:="",cCode2 := ""
local cExpDate := "",cCode3 := "" 
local cap_code := ""
local cWindow 
// local nMisc
// for mcr
local status     := 0
local track_no   := 2
local bytes_Read := 0
local cancel_Pos := 1
local str_buffer := space(20)
local k,i
local cTemp
local add_desc   := ""
local addn_rate  := 0
local addn_amt   := 0
local prev_total := 0, pres_total := 0
local date_today := (UPPER(subs(CMONTH(date()),1,3))+subs(dtoc(date()),7,2))
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
local aBankCards_ := {}                  
local aBankDescs_ := {}                  
                  
  cancel_Pos := if(empty(config(POS_MANUAL_KEY)),1,val(config(POS_MANUAL_KEY)))

  if nPaymAmt > nDueAmt
     ErrorDisp("EXCESS CHARGE AMOUNT")
     return lRetVal
  endif        

  //Prompt for the bank Code ...
  disp_clr()

  if !( valtype(nMisc) == "N" .and. nMisc > 0 .and. nMisc <=50 )
  
    MsgAreaDisp(MSG_D023)
    for i := 1 to 50
       if GetMType(i) == TYPE_BANKCARD .and. !empty(GetMDesc(i) )       
          aAdd( aBankCards_ , {GetMDesc(i), GetMCode(i), i } )
          aAdd( aBankDescs_, GetMDesc(i) )
       endif   
    next i

    while .T. 
     if len(aBankCards_) > 18
        nMisc := aLookUp(17, 35, aBankDescs_ )
     else
        nMisc := aLookUp(25, 35, aBankDescs_ )
     endif   
       if nMisc == 0
          return lRetVal
       elseif nMisc > 0 .and. GetMtype(aBankCards_[nMisc][3]) == TYPE_BANKCARD  
          DISPTEXTXY(3, 1, 0, 0, 0, 0, "CODE FOUND !!!      ")
          MsgAreaDisp(aBankCards_[nMisc][1])
          BEEP_1()
          tone(15,15)                  
          exit
        else
          DISPTEXTXY(3, 1, 0, 0, 0, 0, "                    ")           
          ErrorDisp("BANK CODE NOT FOUND!")        
        endif       
    enddo
    
    endif

    // normalize the amount paid    
   
    add_desc   := trans(2, "9% ") + "Add-On"
    addn_rate  := 2
    prev_total := nvr_nSUBtotal()
    if nPaymAmt < nvr_nSUBtotal() .and. nPaymAmt > 0
       addn_amt := round((nPaymAmt * (addn_rate * 0.01)), 2)
       disp_tot := nPaymAmt            
    else
       addn_amt := round((nvr_nSUBtotal() * (addn_rate * 0.01)), 2)
       disp_tot := addn_amt + nvr_nSUBtotal()
    endif          
    pres_total := addn_amt + nvr_nSUBtotal()
//    nvr_nSUBtotal(pres_total)      jlp.02.05.98
//    nDueAmt    := nvr_nSUBtotal()
    nDueAmt    := nvr_nSUBtotal() + addn_amt
//    Disp_BoldChar(nvr_nSUBtotal(), "Amount Due")
    Disp_BoldChar(nDueAmt, "Amount Due")

    if nPaymAmt == 0
       nPaymAmt := nDueAmt
    endif
  
#ifdef DEF_GRAPHICS
     // display screen to getinput for local card payment
     // save screen
     cWindow := OpenWindow(22, 34, 83, 70, "CREDIT CARD")

     gDrawText(17, 18, "Subtotal", SMALL_FONT, 6, 0, MFIX, LEFT_TEXT)
     gDrawText(18, 18, add_desc, SMALL_FONT, 6, 0, MFIX, LEFT_TEXT)
     gDrawText(19, 18, padr(aBankCards_[nMisc][1],12), SMALL_FONT, 6, 0, MFIX, LEFT_TEXT)
     gDrawText(20, 18, "Account No.", SMALL_FONT, 6, 0, MFIX, LEFT_TEXT)
     gDrawText(21, 18, "Expiry Date", SMALL_FONT, 6, 0, MFIX, LEFT_TEXT)

     gDrawText(17, 32, ":" , SMALL_FONT, 6, 0, MFIX, LEFT_TEXT)
     gDrawText(18, 32, ":" , SMALL_FONT, 6, 0, MFIX, LEFT_TEXT)
     gDrawText(19, 32, ":" , SMALL_FONT, 6, 0, MFIX, LEFT_TEXT)   
     gDrawText(20, 32, ":" , SMALL_FONT, 6, 0, MFIX, LEFT_TEXT)
     gDrawText(21, 32, ":" , SMALL_FONT, 6, 0, MFIX, LEFT_TEXT)

     gDrawText(17, 33, ltrim(transform(prev_total, "999,999.99")) , ;
              SMALL_FONT, 6, 0, MFIX, LEFT_TEXT)
     gDrawText(18, 33, ltrim(transform(addn_amt, "999,999.99")) , ;
             SMALL_FONT, 6, 0, MFIX, LEFT_TEXT)             
     gDrawText(19, 33, ltrim(transform(disp_tot, "999,999.99")) , ;
             SMALL_FONT, 6, 0, MFIX, LEFT_TEXT)
             
     MsgAreaDisp(" Swipe Card to <ENTER> Account Number ")
     gDrawText(20, 33, CHR(95), SMALL_FONT, 6, 0, MFIX, LEFT_TEXT)
#endif

     
    // disp 4x20  Display the charged amount 
    DISPTEXTXY(1, 1, 0, 0, 0, 0, pad(aBankCards_[nMisc][1],11)+trans(nPaymAmt,"99,999.99"))
    DISPTEXTXY(2, 1, 0, 0, 1, 1, "ACCT. # :           ")

    while .T.
    
       DISPTEXTXY(2, 1, 0, 0, 1, 1, "ACCT. # :           ")    
       MsgAreaDisp("SWIPE CARD FOR ACCT#")         
       DISPTEXTXY(3, 1, 0, 0, 2, 1, MSG_CLEAR )
       track_no   := 2
       bytes_read := 0
       str_buffer := space(40)
       ? " Cancel Pos : "
       ?? cancel_pos
       status := READ_CARD( @track_no, @bytes_read, @str_buffer, cancel_pos )
       ? "Status :"
       ?? status
       ? "Data : "
       ?? subs(str_buffer,1,bytes_Read)
       do case
          case status == NORMAL
               cCode1 := ""
               for k:=1 to bytes_read               
                if isdigit(subs(str_buffer,k,1))
                  cCode1 += subs(str_buffer,k,1)
                else
                  exit
                endif
               next k
               cTemp := subs(str_buffer,at("=",str_buffer)+1,4)
               cTemp := subs(cTemp,3,2)+"-01-"+subs(cTemp,1,2)
               cExpDate := ctod(cTemp)
               if !empty(cExpDate) .and. year(cExpDate) > 1980
                 cExpDate := UPPER(subs(cmonth(cExpDate),1,3)+subs(cTemp,7,2))
                 ? "cExpDate :"
                 ?? cExpDate
               else 
                 cExpDate := ""
               endif  
               if !empty(cCode1)
                 exit                
               endif                       
          case status == CANCEL_OP
               MsgAreaDisp(MSG_D024)
               #ifdef DEF_GRAPHICS
                  cCode1 := Grfx_Data(3, 1, 0, 0, 2, 1, { |x| ((!empty(is_number(x)) .and. x != KEY_PERIOD ) .or. (!empty(is_alpha(x)) .and. x != KEY_PERIOD )) } , 20, MSG_D024, 3 )
               #else
                 cCode1 := ReadData(3, 1, 0, 0, 2, 1, { |x| ((!empty(is_number(x)) .and. x != KEY_PERIOD ) .or. (!empty(is_alpha(x)) .and. x != KEY_PERIOD )) } , 20, MSG_D024 )
               #endif                 
               exit
          otherwise
               MsgAreaDisp("ERROR, READ AGAIN...")
               beep_3()
               tone(300, 3)               
       endcase   
    enddo            
                 
    if empty(cCode1)
       #ifdef DEF_GRAPHICS
         // restore previous screen
         CloseWindow(cWindow)
       #endif   
       nvr_nSUBtotal(prev_total)
       Disp_BoldChar(nvr_nSUBtotal(), "Total Amount")
       return lRetVal
    endif   

    // capture the acct. code w/o padded 0
    cap_code := cCode1         
    cCode1 := padl(alltrim(cCode1),20,"0")      
    DISPTEXTXY(2, 1, 0, 0, 2, 1, "#"+subs(cCode1,2) )

    #ifdef DEF_GRAPHICS
        gClearTo(46, 57, 75, 60, 7)
        gDrawText(20, 33, cCode1, SMALL_FONT, 6, 0, MFIX, LEFT_TEXT)
        if !empty(cExpDate)
          gDrawText(21, 33, cExpDate, SMALL_FONT, 6, 0, MFIX, LEFT_TEXT)    
        else
          gDrawText(21, 33, chr(95), SMALL_FONT, 6, 0, MFIX, LEFT_TEXT)    
        endif   
    #endif

    while .T. 
    
      if empty(cExpDate)
         MsgAreaDisp("ENTER EXPIRY DATE...")
         DISPTEXTXY(3, 1, 0, 0, 1, 1, "EXP.DATE(MMYY):_    ")

         #ifdef DEF_GRAPHICS
            cExpDate := Grfx_Data(3, 1, 0, 0, 2, 1, { |x| (((!empty(is_number(x)) .and. x != KEY_PERIOD )) .or. (!empty(is_alpha(x)) .and. x != KEY_PERIOD)) } , 20, "ENTER EXPIRY DATE...", 4)
         #else  
           cExpDate := ReadData(3, 16, 0, 0, 1, 16,{ |x| (!empty(is_number(x)) .and. x != KEY_PERIOD ) } , 4, "ENTER EXPIRY DATE..." )
         #endif  
         if empty(cExpDate)
            #ifdef DEF_GRAPHICS
              // restore previous screen
              CloseWindow(cWindow)
            #endif
            nvr_nSUBtotal(prev_total)
            Disp_BoldChar(nvr_nSUBtotal(), "Total Amount")
            return lRetVal
         else
            cTemp := cExpDate
   			cTemp := subs(cTemp,1,2)+"-01-"+subs(cTemp,3,2)
	   		cExpDate := ctod(cTemp)
		    	if !empty(cExpDate) .and. year(cExpDate) > 1980
			      cExpDate := UPPER(subs(cmonth(cExpDate),1,3)+subs(cTemp,7,2))
               ? "cExpDate :"
               ?? cExpDate
            else 
               cExpDate := ""
            endif
         endif
         
       endif  
         
       DISPTEXTXY(3, 1, 0, 0, 1, 1, "EXPIRY DATE : "+cExpDate)
       #ifdef DEF_GRAPHICS
          gClearTo(46, 60, 75, 63, 7)
          gDrawText(21, 33, cExpDate, SMALL_FONT, 6, 0, MFIX, LEFT_TEXT)
       #endif

       ? "DATA compared to :"
       ?? date_today
       ? "Value of entry : " 
       ??  (val(subs(cExpDate,4,2))+(ascan(aMonth,subs(cExpDate,1,3))/12))
       ? "Value of today : " 
       ??  (val(subs(date_today,4,2))+(ascan(aMonth,subs(date_today,1,3))/12)) 
       if len(cExpDate) != 5 .or. ;
          (val(subs(cExpDate,4,2))+(ascan(aMonth,subs(cExpDate,1,3))/12)) < ;
          (val(subs(date_today,4,2))+(ascan(aMonth,subs(date_today,1,3))/12))
           Beep_2()                
           ErrorDisp("INVALID DATE !!!    ")
           cExpDate := ""
           #ifdef DEF_GRAPHICS
              gClearTo(46, 60, 75, 63, 7)
              gDrawText(21, 33, chr(95), SMALL_FONT, 6, 0, MFIX, LEFT_TEXT)
           #endif  
       else
           cCode2 := padl(addn_rate, 20, "0")
           cCode3 := padl(addn_amt, 20, "0")
           #ifdef DEF_GRAPHICS
             MsgAreaDisp("Press Any Key to Continue...")
             input()
             // restore previous screen
             CloseWindow(cWindow)
             MsgAreaDisp(MSG_D018)
           #endif
           exit    
       endif                        
      
    enddo

#ifdef SLIP_PRNT      
    // For the Sales Draft ....
    MsgAreaDisp(MSG_D025)         

    // disp 4x20  
    DISPTEXTXY(4, 1, 0, 0, 2, 1, "DRAFT # : _         ")    

    cCode2 := ReadData(4, 11, 0, 0, 2, 11, { |x| ((!empty(is_number(x)) .and. x != KEY_PERIOD ) .or. !empty(is_alpha(x))) } , 10, "DRAFT # : _         " )
    if empty(cCode2)
       return lRetVal
    endif   
             
    cCode2 := padl(alltrim(cCode2),10,"0")      
    DISPTEXTXY(4, 1, 0, 0, 2, 1, "DRAFT # : "+cCode2 )         

    // try to print to optional slip printer...
    if slip_prompt(MSG_D029)
         
       slip_check(" "+chr(10), 0)
       out_text := space(6) + "ACCT.#"+cCode1+" " +cExpDate + chr(10)
       slip_check(out_text, 0)
       out_text := space(6) + "SALES DRAFT #"+cCode2+ chr(10)
       slip_check(out_text, 0)         
       out_text := space(6) + "SUBTOTAL"+space(14) + trans(nPaymAmt, "999,999.99") + chr(10)
      
       slip_check(out_text, 0)
       slip_check(" " + chr(10), 0)

*       out_text := space(14) + "NO. OF ITEMS " + transform(nvr_nQTYitems(), "999") + chr(10)
*       slip_check(out_text, 0)
      
       out_text := space(6) + dtoc(date()) + ' ' + substr(time(), 1, 5) + ' ' + ;
                   padl(nvr_nTrans(), 6, "0") + '#  ' + subs(nvr_cCashCode(),1,3) +;
                   ' '+ config(POS_TERM_NUM) + chr(10)
       slip_check(out_text, 0)
    endif   

    add_invoice( { nMisc , nPaymAmt } )  
#endif

    if config(POS_ISLIP_PRN) == "YES"
       rpt_prnt(0, 1, 0, space(10), 0)

       do while .T.
         MsgAreaDisp("Insert Slip & Press <VALID> key to Validate or <CLR> to exit")
         cKey := input()
            if cKey == VALIDATE
              // validate first, before printing 
              if config(POS_ISLIP_PRN) == "YES"
                 out_text := "TOTAL" + ' ' + transform(nPaymAmt, "***,**9.99") + ' ' + ;
                             "ACCT#" + cCode1 + ' ' + dtoc(date()) + ;
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
          Disp_PayAmt(aBankCards_[nMisc][1] + " #" + cCode1, nDueAmt, nPaymAmt, nDueAmt - nPaymAmt)
       #endif          
       
       // POS printer...
       // skip one line...
       A_RJS_FEED(1, 1, 0, 1)   

       out_text := trans(addn_rate, "9%") + " Handling Fee" + space(7) + trans(addn_amt, "999,999.99") + chr(10) 
       rpt_prnt(1, 1, 0, out_text, 0)          
              
       out_text := "SUBTOTAL  " + space(12) + trans(nDueAmt, "999,999.99") + chr(10) 
       rpt_prnt(1, 1, 0, out_text, 0)          

       A_RJS_FEED(1, 0, 0, 1)                 

       out_text := "Acct# " + cCode1 + " " + cExpDate + chr(10) 
       rpt_prnt(1, 0, 0, out_text, 0)

       out_text := pad(aBankCards_[nMisc][1]+" CARD",22) + trans(nPaymAmt,"999,999.99")
       rpt_prnt(1, 1, 0, out_text, 0 )                     

       out_text := "BAL. DUE  " + space(12) + trans(nDueAmt - nPaymAmt, "999,999.99") + chr(10) 
       rpt_prnt(1, 0, 0, out_text, 0)          

       // then on journal...
       out_text := aBankCards_[nMisc][1] + " CARD" + chr(10)
       rpt_prnt(0, 1, 0, out_text, 0)

       out_text := "Acct# " + cCode1 + chr(10)
       rpt_prnt(0, 1, 0, out_text, 0)

       out_text := space(14) + trans(nPaymAmt, "999,999.99") + chr(10)      
       rpt_prnt(0, 1, 0, out_text, 0)

       tran_cFlag( OP_ADON_FLAG ) // Found the plu set as normal
       tran_cRegM( RegMode() ) 
       tran_cPflg( "1" )
       tran_cPrcM( "0" ) // Temporarily set as normal pricing method
       tran_nSale( addn_amt ) 
       tran_nCntr( addn_rate ) 
       tran_cClrk( "" )
       tran_cCrgo( "" )
       tran_cDesc( "" )
       tran_nPric( addn_amt )
       tran_nQty ( addn_rate )
     
       Update_Trans()
       
       payment(nPaymAmt,(nDueAmt - nPaymAmt), aBankCards_[nMisc][3], cCode1,cCode2,cCode3)  

       nDueAmt -= nPaymAmt
       nvr_nSUBtotal(nDueAmt)
       // Add to the terminal file
       Term_nData(TR_DSLS_TOT,nPaymAmt)            // First the Totals                         
       Term_nData(7+((aBankCards_[nMisc][3]-1)*2),nPaymAmt)        
       Term_nData(8+((aBankCards_[nMisc][3]-1)*2),1)

       //add add-amt to add-on fields (total & count)
       Term_nData(TR_ADON_TOT, addn_amt)
       Term_nData(TR_ADON_KNT, 1) 
       
       DispSubTotal()

       #ifdef DEF_GRAPHICS
        Disp_BoldChar(nvr_nSUBtotal(), "Amount Due")
       #endif             

    else      
       
       // display charge payment
       disp_clr()

       #ifdef DEF_GRAPHICS
          Disp_PayAmt(aBankCards_[nMisc][1] + " #" + cCode1, nDueAmt, nPaymAmt, nDueAmt - nPaymAmt)
       #endif   

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
       
       // POS receipt printer...
       // skip one line...
       A_RJS_FEED(1, 0, 0, 1)

       out_text := trans(addn_rate, "9%") + " Handling Fee" + space(7) + trans(addn_amt, "999,999.99") + chr(10) 
       rpt_prnt(1, 0, 0, out_text, 0)          
       
       out_text := "Acct# " + cCode1 + " " + cExpDate+ chr(10) 
       rpt_prnt(1, 0, 0, out_text, 0)

       out_text := pad(aBankCards_[nMisc][1] + " CARD",22) + transform(nDueAmt, "999,999.99") + chr(10) 
       rpt_prnt(1, 0, 0, out_text, 0)
       A_RJS_FEED(1, 0, 0, 1)

       // then on journal...
       // A_PRT_ESC(NORMAL_12)

       out_text := trans(addn_rate, "9%") + " Handling Fee " + trans(addn_amt, "999,999.99") + chr(10) 
       rpt_prnt(0, 1, 0, out_text, 0)          
       
       out_text := aBankCards_[nMisc][1] + " CARD" + chr(10)
       rpt_prnt(0, 1, 0, out_text, 0)

       out_text := "Acct# " + cCode1 + chr(10) 
       rpt_prnt(0, 1, 0, out_text, 0)

       out_text := space(14) + transform(nDueAmt, "999,999.99") + chr(10) 
       rpt_prnt(0, 1, 0, out_text, 0)

       out_text := space(16) + "SUBTL " + transform(nDueAmt, "999,999.99") + chr(10) 
       rpt_prnt(1, 0, 0, out_text, 0)

       out_text := space(16) + "TOTAL " + transform(nDueAmt, "999,999.99") + chr(10) 
       rpt_prnt(1, 0, 0, out_text, 0)

       // then on journal...
       out_text := "SUBTOTAL      " + transform(nDueAmt, "999,999.99") + chr(10)
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
       
       payment(nPaymAmt,(nDueAmt - nPaymAmt), aBankCards_[nMisc][3], cCode1, cCode2, cCode3)  

       nvr_nSubtotal(nDueAmt) // dito na incase patayin ng NE.jlp.02.05.98

       // update first the terminal file
       Term_nData(TR_DSLS_TOT,nvr_nSUBtotal())
       Term_nData(TR_DSLS_KNT,1)               

       Term_nData(7+((aBankCards_[nMisc][3]-1)*2),nvr_nSUBtotal())        
       Term_nData(8+((aBAnkCards_[nMisc][3]-1)*2),1)
       
       // add add-amt to add-on fields (total & count)
       Term_nData(TR_ADON_TOT, addn_amt)
       Term_nData(TR_ADON_KNT, 1) 
       
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


