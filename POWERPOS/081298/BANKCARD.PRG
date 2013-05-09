#include "pfl_clip.ch"
#include "message.ch"
#include "keymap.ch"
#include "config.ch"
#include "terminal.ch"
#include "spec_key.ch"
#include "powerpos.ch"

#ifdef DEF_GRAPHICS
 #include "grfx_all.ch"
 #include "get_grfx.ch"
#endif

#define TYPE_BANKCARD       "0"

function Bank_Payment(nMisc,cKeyBuff)
local cWindow
local nPaymAmt := val(put_decimal(cKeyBuff))
local nTotal := nvr_nSUBtotal()
local nDueAmt := (nvr_nSUBtotal()*nvr_nPHP_Rate())
local nChange := 0
local nQty := nvr_nQtyitems()
local lRetVal := .F.
local out_text, cKey
// used for MCR reading
local status     := 0
local track_no   := 2
local bytes_Read := 0
local cancel_Pos := 1
local str_buffer := space(20)
// Extras
local cCode1:="",cCode2 := ""
local cExpDate := "",cCode3 := "" 
local i,k
local cTemp
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

  cancel_Pos := val(config(POS_MANUAL_KEY))
  if cancel_Pos < 1 .or. cancel_Pos > 105
    cancel_Pos := 1
  endif		  

  // Normalize value remove extra decimal places
  out_text := trans(nDueAmt,"999999.99")
  nDueAmt := val(out_text)

  if nPaymAmt > nDueAmt
     ErrorDisp("EXCESS CHARGE AMOUNT")
     return lRetVal
  endif        

  //Prompt for the bank Code ...
  disp_clr()

  if !( valtype(nMisc) == "N" .and. nMisc > 0 .and. nMisc <= MAXIMUM_MISC )
  
    MsgAreaDisp(MSG_D023)
    for i := 1 to MAXIMUM_MISC
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

  if nPaymAmt == 0
  	nPaymAmt := nDueAmt
  endif

  // display screen to getinput for local card payment
  // save screen
  cWindow := OpenWindow(22, 34, 83, 70, "CREDIT CARD")

  @ 45, 28 say "Subtotal"
  @ 49, 28 say padr(GetMDesc(nMisc),12) 
  @ 53, 28 say "Account No."
  @ 57, 28 say "Expiry Date"

  @ 45, 46 say ":"
  @ 49, 46 say ":"
  @ 53, 46 say ":"
  @ 57, 46 say ":"
	
  @ 45, 49 say trans(nDueAmt,"999,999.99")
  @ 49, 49 say trans(nPaymAmt,"999,999.99") 
  @ 53, 49 say "_"
		
  MsgAreaDisp(" Swipe Card to <ENTER> Account Number ")

  // disp 4x20  Display the charged amount 
  DISPTEXTXY(1, 1, 0, 0, 0, 0, pad(GetMDesc(nMisc),11)+trans(nPaymAmt,"99,999.99"))
  DISPTEXTXY(2, 1, 0, 0, 1, 1, "ACCT. # :           ")

  while .T.
    
       DISPTEXTXY(2, 1, 0, 0, 1, 1, "ACCT. # :           ")    
       MsgAreaDisp("SWIPE CARD FOR ACCT#")         
       DISPTEXTXY(3, 1, 0, 0, 2, 1, MSG_CLEAR )
       track_no   := 2
       bytes_read := 0
	  status := CANCEL_OP
       str_buffer := space(40)
//       ? " Cancel Pos : "
//       ?? cancel_pos
       status := READ_CARD( @track_no, @bytes_read, @str_buffer, cancel_pos )
//       ? "Status :"
//       ?? status
//       ? "Data : "
//       ?? subs(str_buffer,1,bytes_Read)
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
//                 ? "cExpDate :"
//                 ?? cExpDate
               else 
                 cExpDate := ""
               endif  
               if !empty(cCode1)
                 exit                
               endif                       
          case status == CANCEL_OP
               MsgAreaDisp(MSG_D024)
               //cCode1 := Grfx_Data(3, 1, 0, 0, 2, 1, { |x| ((!empty(is_number(x)) .and. x != KEY_PERIOD ) .or. (!empty(is_alpha(x)) .and. x != KEY_PERIOD )) } , 20, MSG_D024, 3 )
			cCode1 := space(20)
			@ 53, 49 get cCode1 pict "99999999999999999999" MESSAGE MSG_D024
			readmodal()
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
       return lRetVal
    endif   

    // capture the acct. code w/o padded 0
    cCode1 := padl(alltrim(cCode1),20,"0")      
    DISPTEXTXY(2, 1, 0, 0, 2, 1, "#"+subs(cCode1,2) )

    #ifdef DEF_GRAPHICS
        @ 53, 49 say cCode1
        if !empty(cExpDate)
		@ 57, 49 say cExpDate
        else
          @ 57, 49 say "_"
        endif   
    #endif

    while .T. 
    
      if empty(cExpDate)
         MsgAreaDisp("ENTER EXPIRY DATE...")
         DISPTEXTXY(3, 1, 0, 0, 1, 1, "EXP.DATE(MMYY):_    ")
	    	cExpDate := space(5)
		@ 57, 49 get cExpDate MESSAGE "Enter Expiry Date..."
		readmodal()
         if empty(cExpDate)
            #ifdef DEF_GRAPHICS
              // restore previous screen
              CloseWindow(cWindow)
            #endif
            Disp_BoldChar(nvr_nSUBtotal(), "Total Amount")
            return lRetVal
         else
            cTemp := cExpDate
   			cTemp := subs(cTemp,1,2)+"-01-"+subs(cTemp,3,2)
	   		cExpDate := ctod(cTemp)
		    	if !empty(cExpDate) .and. year(cExpDate) > 1980
			      cExpDate := UPPER(subs(cmonth(cExpDate),1,3)+subs(cTemp,7,2))
//               ? "cExpDate :"
//               ?? cExpDate
               else 
                 cExpDate := ""
               endif
         endif
         
      endif  
         
       DISPTEXTXY(3, 1, 0, 0, 1, 1, "EXPIRY DATE : "+cExpDate)
       #ifdef DEF_GRAPHICS
		@ 57, 49 say cExpDate
       #endif

//       ? "DATA compared to :"
//       ?? date_today
//       ? "Value of entry : " 
//       ??  (val(subs(cExpDate,4,2))+(ascan(aMonth,subs(cExpDate,1,3))/12))
//       ? "Value of today : " 
//       ??  (val(subs(date_today,4,2))+(ascan(aMonth,subs(date_today,1,3))/12)) 
       cTemp := padl(ascan(aMonth,subs(cExpDate,1,3)),2,"0") +;
	  		 "-28-" + subs(cExpDate,4,2)
       if len(cExpDate) != 5 .or. ctod(cTemp) < date()
           Beep_2()                
           ErrorDisp("INVALID DATE !!!    ")
           cExpDate := ""
           #ifdef DEF_GRAPHICS
		    @ 57, 49 say "_"
           #endif  
       else
           #ifdef DEF_GRAPHICS
             MsgAreaDisp("Press Any Key to Continue...")
             input()
             // restore previous screen
             CloseWindow(cWindow)
		   if lastinput() == CLR
		      return .F.
		   endif	 
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
          Disp_PayAmt(GetMDesc(nMisc) + " #" + cCode1, nDueAmt, nPaymAmt, nDueAmt - nPaymAmt)
       #endif          
       
       // POS printer...
       // skip one line...
       A_RJS_FEED(1, 1, 0, 1)   

       out_text := pad("SUBTOTAL",22) + trans(nTotal, "999,999.99") + chr(10) 
       rpt_prnt(1, 1, 0, out_text, 0)          
	  out_text := trans(nDueAmt,"999,999.99") + " PHILIPPINE PESO"
	  rpt_prnt(1, 1, 0, out_text, 0)
	  
       out_text := "Acct# " + cCode1 + " " + cExpDate + chr(10) 
       rpt_prnt(1, 1, 0, out_text, 0)

       out_text := pad(GetMDesc(nMisc)+" CARD",22) + trans((nPaymAmt/nvr_nPHP_Rate()),"999,999.99")
       rpt_prnt(1, 1, 0, out_text, 0 ) 
	  out_text := trans(nPaymAmt,"999,999.99") + " PHILIPPINE PESO"

       out_text := "BAL. DUE  " + space(12) + trans(nTotal-(nPaymAmt/nvr_nPHP_Rate()), "999,999.99")
       rpt_prnt(1, 1, 0, out_text, 0 )
	  out_text := trans(nDueAmt - nPaymAmt, "999,999.99") + " PHILIPPINE PESO"
	  
       payment((nPaymAmt/nvr_nPHP_Rate()),(nTotal - (nPaymAmt/nvr_nPHP_Rate())), nMisc, cCode1,cCode2,cCode3)  

       // nDueAmt -= nPaymAmt
       // nvr_nSUBtotal(nDueAmt)
	  nTotal -= (nPaymAmt/nvr_nPHP_Rate())
	  nvr_nSUBtotal(nTotal)	  
	  
       // Add to the terminal file
       Term_nData(TR_DSLS_TOT,(nPaymAmt/nvr_nPHP_Rate()))            // First the Totals                         
       Term_nData(7+((nMisc-1)*2),(nPaymAmt/nvr_nPHP_Rate()))        
       Term_nData(8+((nMisc-1)*2),1)

	   // To foreign currency totals
	   Term_nData(TR_FCUR_TOT,nPaymAmt)   
	   Term_nData(TR_FCUR_KNT,1)   

       DispSubTotal()

       #ifdef DEF_GRAPHICS
        Disp_BoldChar(nvr_nSUBtotal(), "Amount Due")
       #endif             

    else      
       
       // display charge payment
       disp_clr()

       #ifdef DEF_GRAPHICS
          Disp_PayAmt(GetMDesc(nMisc) + " #" + cCode1, nDueAmt, nPaymAmt, nDueAmt - nPaymAmt)
       #endif   

       // customer display 2
       out_text := "CHARGE PHP" + trans(nPaymAmt, "999,999.99")
       DISPTEXTXY(0, 0, 0, 0, 1, 1, out_text)

       out_text := "CHANGE PHP" + trans(nPaymAmt-nDueAmt,"999,999.99")
       DISPTEXTXY(0, 0, 0, 0, 2, 1, out_text)

       // POS receipt printer...
       // skip one line...
       A_RJS_FEED(1, 0, 0, 1)

       out_text := pad("SUBTOTAL",22) + trans(nTotal, "999,999.99") + chr(10) 
       rpt_prnt(1, 1, 0, out_text, 0)          
       out_text := trans(nDueAmt, "999,999.99") + " PHILIPPINE PESO"
       rpt_prnt(1, 1, 0, out_text, 0)          

       out_text := "Acct# " + cCode1 + " " + cExpDate+ chr(10) 
       rpt_prnt(1, 1, 0, out_text, 0)

       out_text := pad(GetMDesc(nMisc)+" CARD",22) + trans(nTotal, "999,999.99")
       rpt_prnt(1, 1, 0, out_text, 0)
       out_text := trans(nDueAmt, "999,999.99") + " PHILIPPINE PESO"
       rpt_prnt(1, 1, 0, out_text, 0)	  
	  
       A_RJS_FEED(1, 1, 0, 1)

#ifdef SLIP_PRNT
       // now print all the charge invoice 
       print_invoice()        
#endif       
       payment((nPaymAmt/nvr_nPHP_Rate()),(nDueAmt - (nPaymAmt/nvr_nPHP_Rate())), nMisc, cCode1, cCode2, cCode3)  

       // update first the terminal file
       Term_nData(TR_DSLS_TOT,nvr_nSUBtotal())
       Term_nData(TR_DSLS_KNT,1)               

       Term_nData(7+((nMisc-1)*2),nvr_nSUBtotal())        
       Term_nData(8+((nMisc-1)*2),1)

	   // update foreign currency totals
	   Term_nData(TR_FCUR_TOT,nPaymAmt)
	   Term_nData(TR_FCUR_KNT,1)
       
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


