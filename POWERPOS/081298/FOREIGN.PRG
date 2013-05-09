#include "get_grfx.ch"
#include "fm_file.ch"
#include "powerpos.ch"
#include "message.ch"
#include "terminal.ch"
#include "spec_key.ch"

static cCurrency := DOLLAR_SIGN

function foreign_Payment(cKeyBuff)
local cWindow
local nPaymAmt := val(put_decimal(cKeyBuff))
local nTotal  := nvr_nSUBtotal()
local nDueAmt := (nvr_nSUBtotal()*nvr_nPHP_Rate())
local nChange := 0
local nQty := nvr_nQtyitems()
local lRetVal := .F.
local out_text

     // Normalize value remove extra decimal places
	out_text := trans(nDueAmt,"999999.99")
	nDueAmt := val(out_text)
                                
     if nPaymAmt == 0
		nPaymAmt := nDueAmt
	endif

     cWindow := OpenWindow(20, 34, 78, 73, "Foreign Currency")

	@ 45, 28 say "FCUR Abbr."
	@ 49, 28 say "FCUR Desc."
	@ 53, 28 say "FCUR Rate"
	@ 57, 28 say "Amount Due"
	@ 61, 28 say "Converted"
	@ 65, 28 say "Tender Amt"

	@ 45, 46 say ":"
	@ 49, 46 say ":"
	@ 53, 46 say ":"
	@ 57, 46 say ":"
	@ 61, 46 say ":"
	@ 65, 46 say ":"

	@ 45, 49 say "PHP" 
	@ 49, 49 say "Philippine Peso"
	@ 53, 49 say trans(nvr_nPHP_Rate(),"99.9999")
	@ 57, 49 say trans(nTotal,"999,999.99")
	@ 61, 49 say trans(nDueAmt,"999,999.99")
	@ 65, 49 get nPaymAmt pict "999999.99" MESSAGE "ENTER PESO AMOUNT"
	
	readmodal()

	if lastinput() != CLR
          MsgAreaDisp("Press Any Key to Continue...")
		input()
		CloseWindow(cWindow)
		if lastinput() == CLR
		  return .F.
		endif
	else
		CloseWindow(cWindow)
		return .F.
	endif	


	if nDueAmt > nPaymAmt .and. nPaymAmt > 0
	   MsgAreaDisp(MSG_D015) // Aknowledge partial payment
	   tone(15,18) // delay exactly one second..

	   // POS printer
	   // skip one line
	   A_RJS_FEED(1, 1, 0, 1)

        out_text := "SUBTOTAL  " + space(12) + trans(nTotal, "999,999.99") + chr(10) 
        rpt_prnt(1, 1, 0, out_text, 0)        
	   out_text := trans(nDueAmt, "999,999.99") + " PHILIPPINE PESO"
	   rpt_prnt(1, 1, 0, out_text, 0)        
	   
        out_text := "CASH      " + space(12) + trans(nPaymAmt/nvr_nPHP_Rate(),"999,999.99")
	   rpt_prnt(1, 1, 0, out_text, 0)        
        out_text := trans(nPaymAmt, "999,999.99") + " PHILIPPINE PESO"
        rpt_prnt(1, 1, 0, out_text, 0)        

	   out_text := "BAL. DUE  " + space(12) + trans(nTotal-(nPaymAmt/nvr_nPHP_Rate()),"999,999.99")
        out_text := trans(nDueAmt-nPaymAmt, "999,999.99") + " PHILIPPINE PESO"
        rpt_prnt(1, 1, 0, out_text, 0)

        A_RJS_FEED(1, 1, 0, 1)
	   
        Disp_PayAmt("Philippine Peso", nDueAmt, nPaymAmt, nDueAmt - nPaymAmt)
        Disp_BoldChar(nDueAmt -nPaymAmt)
        // payment(nPaymAmt,(nDueAmt - nPaymAmt), 0, "", "")
        // nDueAmt -= nPaymAmt
        // nvr_nSUBtotal(nDueAmt)
	   payment((nPaymAmt/nvr_nPHP_Rate()),(nTotal - (nPaymAmt/nvr_nPHP_Rate())), 0, "", "" )
	   nTotal -= (nPaymAmt/nvr_nPHP_Rate())
	   nvr_nSUBtotal(nTotal)

        // Add to the terminal file
        Term_nData(TR_DSLS_TOT,(nPaymAmt/nvr_nPHP_Rate()))            // First the Totals  
        Term_nData(TR_CASH_TOT,(nPaymAmt/nvr_nPHP_Rare()))

	   // To foreign currency totals
	   Term_nData(TR_FCUR_TOT,nPaymAmt)   
	   Term_nData(TR_FCUR_KNT,1)   
		
        DispSubTotal()
    else    
        // now ok to pay 
        // now check if there is change 
        if nPaymAmt == 0
           nPaymAmt := nDueAmt           
        endif                            
        
        // you know what to do....
        disp_clr()

        #ifdef DEF_GRAPHICS
           Disp_PayAmt("Philippine Peso", nDueAmt, nPaymAmt, nDueAmt - nPaymAmt)
        #endif

        // customer display 2 (2x20)
        out_text := "PH PESO : " + trans(nPaymAmt, "999,999.99")
        DISPTEXTXY(0, 0, 0, 0, 1, 1, out_text)
        out_text := " CHANGE : " + trans(nPaymAmt - nDueAmt, "999,999.99")
        DISPTEXTXY(0, 0, 0, 0, 2, 1, out_text)

        open_drawr()
        MsgAreaDisp(MSG_D014) // Close Drawer msg

        // POS receipt and journal printer...
        // skip one line...
        A_RJS_FEED(1, 1, 0, 1)
        out_text := "SUBTOTAL  " + space(12) + trans(nTotal, "999,999.99") + chr(10) 
        rpt_prnt(1, 1, 0, out_text, 0)        
        out_text := transform(nDueAmt, "999,999.99") + " PHILIPPINE PESO"
        rpt_prnt(1, 0, 0, out_text, 0)
                
        out_text := "CASH      " + space(12) + trans((nPaymAmt/nvr_nPHP_Rate()), "999,999.99") + chr(10)         
        rpt_prnt(1, 1, 0, out_text, 0)
	   out_text := trans(nPaymAmt,"999,999.99") + " PHILIPPINE PESO"
	   rpt_prnt(1, 1, 0, out_text, 0)
	   	   
	   out_text := "CHANGE    " + space(12) + trans((nPaymAmt/nvr_nPHP_Rate())-nTotal,"999,999.99")
	   rpt_prnt(1, 1, 0, out_text, 0)
        out_text := trans(nPaymAmt - nDueAmt, "999,999.99") + " PHILIPPINE PESO"
        rpt_prnt(1, 1, 0, out_text, 0)

        A_RJS_FEED(1, 1, 0, 1)

        // payment(nDueAmt,(nDueAmt - nPaymAmt), 0, "", "")          
        payment(nTotal,(nTotal - (nPaymAmt/nvr_nPHP_Rate())), 0, "", "")          
        
        // update first the terminal file
        Term_nData(TR_DSLS_TOT,nvr_nSUBtotal())
        Term_nData(TR_CASH_TOT,nvr_nSUBtotal())
        Term_nData(TR_DSLS_KNT,1)

	   // update foreign currency totals
	   Term_nData(TR_FCUR_TOT,nPaymAmt)
	   Term_nData(TR_FCUR_KNT,1)
	
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
	
function cCurrency(cChar)

  if valtype(cChar) == "C"
    cCurrency := cChar
  endif

return cCurrency

function fcur_set(cIndata)
local cStr_curr
local cAbbr_str
local nNum_curr

	cAbbr_str := subs(cIndata,15,3)
	cStr_curr := subs(cIndata,38,10)
	nNum_curr := val(cStr_curr)
	nNum_curr := (nNum_curr / 1000000)

	if cAbbr_str == "PHP"
      	nvr_nPHP_Rate(nNum_curr)
	elseif cAbbr_str == "USD"
	     nvr_nUSD_Rate(nNum_curr)
	endif		

return nil