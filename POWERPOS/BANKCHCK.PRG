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

#define TYPE_BANKCHEQUE       "3"

function Bank_Cheque(nMisc,cKeyBuff)
local cKey
local cDispBuff := ""
local cData
local lRetVal := .F.
local disp_tot := 0
local nPaymAmt := val(cKeyBuff)
local nDueAmt  := nvr_nSUBtotal()
local nActual  := 0
local nQty     := nvr_nQtyItems() 
local out_text
local cCode1:="",cCode2 := ""
local cExpDate := "",cCode3 := "" 
local cap_code := ""
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
local aBankCheck_ := {}
local aBankDesc_  := {}
local cWindow
                  
/*

  if nPaymAmt > nDueAmt
     ErrorDisp("EXCESS CHARGE AMOUNT")
     return lRetVal
  endif         
  
*/

  //Prompt for the bank Code ...
  disp_clr()

  if !( valtype(nMisc) == "N" .and. nMisc > 0 .and. nMisc <= 20 )
  
    MsgAreaDisp(MSG_D023)
    for i := 1 to 50 
       if GetMType(i) == TYPE_BANKCHEQUE .and. !empty(GetMDesc(i))       
          aAdd( aBankCheck_ , {GetMDesc(i), GetMCode(i), i} )
          aAdd( aBankDesc_, GetMDesc(i))
       endif   
    next i

    while .T. 
       nMisc := aLookUp(25, 35, aBankDesc_)
       if nMisc == 0
          return lRetVal
       elseif nMisc > 0 .and. GetMtype(aBankCheck_[nMisc][3]) == TYPE_BANKCHEQUE
          DISPTEXTXY(3, 1, 0, 0, 0, 0, "CODE FOUND !!!      ")        
          MsgAreaDisp(aBankCheck_[nMisc][1])
          BEEP_1()
          tone(15,15)                  
          exit
        else
          DISPTEXTXY(3, 1, 0, 0, 0, 0, "                    ")           
          ErrorDisp("BANK CODE NOT FOUND!")        
        endif       
    enddo
  else 
    return lRetVal    
  endif


  if nPaymAmt < nvr_nSUBTotal() .and. nPaymAmt > 0
     nActual := nPaymAmt
  else
     if nPaymAmt == 0
       // normalize the amount paid    
       nPaymAmt := nvr_nSUBTotal()
     endif  
     nActual := nvr_nSUBtotal()    
  endif
  
  disp_tot := nActual
  
#ifdef DEF_GRAPHICS

     // display screen to getinput for local card payment
     // save screen
     cWindow := OpenWindow(22, 34, 83, 64, "BANK CHEQUE")

     gDrawText(17, 18, "Subtotal", SMALL_FONT, 6, 0, MFIX, LEFT_TEXT)
     gDrawText(18, 18, substr(aBankCheck_[nMisc][1],1,12), SMALL_FONT, 6, 0, MFIX, LEFT_TEXT)
     gDrawText(19, 18, "Account No.", SMALL_FONT, 6, 0, MFIX, LEFT_TEXT)
     gDrawText(20, 18, "Expiry Date", SMALL_FONT, 6, 0, MFIX, LEFT_TEXT)

     gDrawText(17, 32, ":" , SMALL_FONT, 6, 0, MFIX, LEFT_TEXT)
     gDrawText(18, 32, ":" , SMALL_FONT, 6, 0, MFIX, LEFT_TEXT)
     gDrawText(19, 32, ":" , SMALL_FONT, 6, 0, MFIX, LEFT_TEXT)   
     gDrawText(20, 32, ":" , SMALL_FONT, 6, 0, MFIX, LEFT_TEXT)   
     
     gDrawText(17, 33, ltrim(transform(disp_tot, "999,999.99")) , ;
             SMALL_FONT, 6, 0, MFIX, LEFT_TEXT)

     gDrawText(18, 33, ltrim(transform(nPaymAmt, "999,999.99")) , ;
             SMALL_FONT, 6, 0, MFIX, LEFT_TEXT)             
             
     gDrawText(19, 33, CHR(95), SMALL_FONT, 6, 0, MFIX, LEFT_TEXT)

#endif
     
    // disp 4x20  Display the charged amount 
    DISPTEXTXY(1, 1, 0, 0, 0, 0, pad(aBankCheck_[nMisc][1],11)+trans(nPaymAmt,"99,999.99"))
    DISPTEXTXY(2, 1, 0, 0, 1, 1, "ACCT. # :           ")

    MsgAreaDisp(MSG_D024)
    #ifdef DEF_GRAPHICS
       cCode1 := Grfx_Data(3, 1, 0, 0, 2, 1, { |x| (((!empty(is_number(x)) .and. x != KEY_PERIOD )) .or. ((!empty(is_alpha(x)) .and. x != KEY_PERIOD ))) } , 20, MSG_D024, 2 )
    #else
       cCode1 := ReadData(3, 1, 0, 0, 2, 1, { |x| ((!empty(is_number(x)) .and. x != KEY_PERIOD ) .or. (!empty(is_alpha(x)) .and. x != KEY_PERIOD )) } , 20, MSG_D024 )
    #endif                                  

    if empty(cCode1)
       #ifdef DEF_GRAPHICS
         // restore previous screen
         CloseWindow(cWindow)
       #endif   
       return lRetVal
    endif   

    // capture the acct. code w/o padded 0
    cap_code := cCode1         
    cCode1 := padl(alltrim(cCode1),20,"0")      
    DISPTEXTXY(2, 1, 0, 0, 2, 1, "#"+subs(cCode1,2) )

    #ifdef DEF_GRAPHICS
        gClearTo(46, 54, 75, 57, 7)
        gDrawText(19, 33, cCode1, SMALL_FONT, 6, 0, MFIX, LEFT_TEXT)
        if !empty(cExpDate)
          gDrawText(20, 33, cExpDate, SMALL_FONT, 6, 0, MFIX, LEFT_TEXT)    
        else
          gDrawText(20, 33, chr(95), SMALL_FONT, 6, 0, MFIX, LEFT_TEXT)    
        endif   
    #endif

    while .T. 
    
      if empty(cExpDate)
         MsgAreaDisp("ENTER EXPIRY DATE...")
         DISPTEXTXY(3, 1, 0, 0, 1, 1, "EXP.DATE(MMYY):_    ")

         #ifdef DEF_GRAPHICS
            cExpDate := Grfx_Data(3, 1, 0, 0, 2, 1, { |x| ((!empty(is_number(x)) .and. x != KEY_PERIOD ) .or. !empty(is_alpha(x))) } , 20, "ENTER EXPIRY DATE...", 3)
         #else  
           cExpDate := ReadData(3, 16, 0, 0, 1, 16,{ |x| (!empty(is_number(x)) .and. x != KEY_PERIOD ) } , 4, "ENTER EXPIRY DATE..." )
         #endif  
         if empty(cExpDate)
            #ifdef DEF_GRAPHICS
              // restore previous screen
              CloseWindow(cWindow)
            #endif
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
          gClearTo(46, 57, 75, 60, 7)
          gDrawText(20, 33, cExpDate, SMALL_FONT, 6, 0, MFIX, LEFT_TEXT)
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
              gClearTo(46, 57, 75, 60, 7)
              gDrawText(20, 33, chr(95), SMALL_FONT, 6, 0, MFIX, LEFT_TEXT)
           #endif  
       else
           cCode2 := padl(addn_rate, 20, "0")
           cCode3 := padl(addn_amt , 20, "0")
           #ifdef DEF_GRAPHICS
             MsgAreaDisp("Press Any Key to Continue...")
             inkey(0)
             // restore previous screen
             CloseWindow(cWindow)
             MsgAreaDisp(MSG_D018)
           #endif
           exit    
       endif                        
      
    enddo

    if config(POS_ISLIP_PRN) == "YES"
       rpt_prnt(0, 1, 0, space(10), 0)

       do while .T.
         MsgAreaDisp("Insert Slip & Press <VALID> key to Validate or <CLR> to exit")
         cKey := input()
            if cKey == VALIDATE
              // validate first, before printing 
              if config(POS_ISLIP_PRN) == "YES"
                 out_text := "TOTAL" + ' ' + transform(nActual, "***,**9.99") + ' ' + ;
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
          Disp_PayAmt(aBankCheck_[nMisc][1] + " #" + cCode1, nDueAmt, nPaymAmt, nDueAmt - nPaymAmt)
       #endif          
       
       // POS printer...
       // skip one line...
       A_RJS_FEED(1, 1, 0, 1)   
              
       out_text := "SUBTOTAL  " + space(12) + trans(nDueAmt, "999,999.99") + chr(10) 
       rpt_prnt(1, 1, 0, out_text, 0)          

       A_RJS_FEED(1, 0, 0, 1)                 

       out_text := "Acct# " + cCode1 + " " + cExpDate + chr(10) 
       rpt_prnt(1, 0, 0, out_text, 0)

       out_text := padr(aBankCheck_[nMisc][1],22) + trans(nPaymAmt,"999,999.99")
       rpt_prnt(1, 1, 0, out_text, 0 )                     

       out_text := "BAL. DUE  " + space(12) + trans(nDueAmt - nPaymAmt, "999,999.99") + chr(10) 
       rpt_prnt(1, 0, 0, out_text, 0)          

       // then on journal...
       out_text := aBankCheck_[nMisc][1] + chr(10)
       rpt_prnt(0, 1, 0, out_text, 0)

       out_text := "Acct# " + cCode1 + chr(10)
       rpt_prnt(0, 1, 0, out_text, 0)

       out_text := space(14) + trans(nPaymAmt, "999,999.99") + chr(10)      
       rpt_prnt(0, 1, 0, out_text, 0)
       
       payment(nPaymAmt,(nDueAmt - nPaymAmt), aBankCheck_[nMisc][3], cCode1,cCode2,cCode3)  

       nDueAmt -= nPaymAmt
       nvr_nSUBtotal(nDueAmt)
       // Add to the terminal file
       Term_nData(TR_DSLS_TOT,nPaymAmt)            // First the Totals                         
       Term_nData(7+((aBankCheck_[nMisc][3]-1)*2),nPaymAmt)        
       Term_nData(8+((aBankCheck_[nMisc][3]-1)*2),1)

       DispSubTotal()

       #ifdef DEF_GRAPHICS
        Disp_BoldChar(nvr_nSUBtotal(), "Amount Due")
       #endif             

    else      
       
       // display charge payment
       disp_clr()

       #ifdef DEF_GRAPHICS
          Disp_PayAmt(aBankCheck_[nMisc][1] + " #" + cCode1, nDueAmt, nPaymAmt, nDueAmt - nPaymAmt)
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

       if nPaymAmt > nDueAmt
         open_drawr()
       endif  
       
       if config(POS_CASH_DRAWER) != "NO" 
         while .t.
           if chk_drawr() != DRAWER_CLOSED
             MsgAreaDisp(MSG_D014) // Close Drawer msg
             tone(15,9)                       
           else 
             exit   
           endif                       
         enddo               
       endif               

       // POS receipt printer...
       // skip one line...
       A_RJS_FEED(1, 0, 0, 1)

       out_text := "Acct# " + cCode1 + " " + cExpDate+ chr(10) 
       rpt_prnt(1, 0, 0, out_text, 0)

       out_text := padr(aBankCheck_[nMisc][1],22) + transform(nDueAmt, "999,999.99") + chr(10) 
       rpt_prnt(1, 0, 0, out_text, 0)
       A_RJS_FEED(1, 0, 0, 1)

       // then on journal...
       // A_PRT_ESC(NORMAL_12)

       out_text := aBankCheck_[nMisc][1] + chr(10)
       rpt_prnt(0, 1, 0, out_text, 0)

       out_text := "Acct# " + cCode1 + chr(10) 
       rpt_prnt(0, 1, 0, out_text, 0)

       out_text := space(14) + transform(nDueAmt, "999,999.99") + chr(10) 
       rpt_prnt(0, 1, 0, out_text, 0)

       out_text := space(16) + "SUBTL " + transform(nDueAmt, "999,999.99") + chr(10) 
       rpt_prnt(1, 0, 0, out_text, 0)

       out_text := space(16) + "CHANGE" + transform(nPaymAmt - nDueAmt, "999,999.99") + chr(10) 
       rpt_prnt(1, 0, 0, out_text, 0)

       // then on journal...
       out_text := "SUBTOTAL      " + transform(nDueAmt, "999,999.99") + chr(10)
       rpt_prnt(0, 1, 0, out_text, 0)

#ifdef SLIP_PRNT
       // now print all the charge invoice 
       print_invoice()        
#endif       

       // then make a new record for the add-on record
       tran_cPLU(  "" ) 
       tran_cItem( "" )
       tran_cDept( "" )
       tran_cFlag( OP_OINC_FLAG ) // Flag Set As Other Income by ret-exch.
       tran_cPFlg( "1" )
       tran_cRegM( "0" ) // Temporarily set as keyboard method of entry
       tran_cPrcM( "0" ) // Temporarily set as normal pricing method
       tran_cConc( "" ) // Concessionaire
       tran_cColo( "" )  
       tran_cSize( "" ) 
       tran_nSale( nPaymAmt - nDueAmt ) 
       tran_nCntr( if((nPaymAmt - nDueAmt)!=0,1,0) ) 
       tran_nPric( nPaymAmt - nDueAmt )
       tran_nQty ( if((nPaymAmt - nDueAmt)!=0,1,0) )
       tran_cDesc( "Negative Cash")
       Update_Trans()
       
*       payment(nPaymAmt,(nDueAmt - nPaymAmt), aBankCheck_[nMisc][3], cCode1, cCode2, cCode3)  
       payment(nDueAmt,(nDueAmt - nPaymAmt), aBankCheck_[nMisc][3], cCode1, cCode2, cCode3)  

       // update first the terminal file
       Term_nData(TR_DSLS_TOT,nvr_nSUBtotal())
       Term_nData(TR_DSLS_KNT,1)               

       //Term_nData(7+((aBankCheck_[nMisc][3]-1)*2),nvr_nSUBtotal())        
       Term_nData(7+((aBankCheck_[nMisc][3]-1)*2),nvr_nSUBtotal())        
       Term_nData(8+((aBankCheck_[nMisc][3]-1)*2),1)

       // add the change to offline total (Negative Cash)
       Term_nData(TR_OFFL_TOT, nPaymAmt - nDueAmt)
       Term_nData(TR_OFFL_KNT, if((nPaymAmt - nDueAmt)!=0,1,0))

       // less change to cash totals
       // Term_nData(TR_CASH_TOT, nDueAmt - nPaymAmt) 
       // per rowena ng ne bodega 
               
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


