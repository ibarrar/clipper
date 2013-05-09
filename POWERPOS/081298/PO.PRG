#include "get_grfx.ch"
#include "message.ch"
#include "spec_key.ch"


static lPO_entered := .F.
static cPO_Code := "          "
static nPO_Limit := 0

function lPO_entered(lVar)
	if Valtype(lVar) == "L"
	   lPO_entered := lVar
	   if !lPO_entered
	     nPO_limit := 0
        endif
	endif   
return lPO_entered

function nPO_Limit(nValue)
 if valtype(nValue) == "N"
    nPO_Limit := nValue
 endif
return (nPO_limit)

function po(cKeyBuff)
local cWindow,i
local nPO_temp

  if !empty(cKeyBuff)
  	cPO_Code := alltrim(cKeyBuff)
	for i:= 1 to len(cPO_Code)
		if !isdigit(subs(cPO_Code,i,1))
			cPO_Code := subs(cPO_Code,1,i)
			exit
		endif
	next i
	cPO_Code := padl(cPO_Code,10,"0")
  endif

  nPO_temp := nPO_Limit-nvr_nSUBtotal()
 
  cWindow := OpenWindow(22, 32, 81, 65, "Purchase Order")

  @ 45, 34 say "PO #"
  @ 49, 34 say "PO Limit"

  @ 45, 46 say ":"         
  @ 49, 46 say ":"        

  @ 45, 50 get cPO_Code when !lPO_Entered valid !empty(cPO_Code)
  @ 49, 50 get nPO_temp pict "9999999.99" when !lPO_Entered valid !empty(nPO_temp)

  readmodal()
  if lPO_entered
  	MsgAreaDisp(MSG_D030)
  	input()
  elseif  lastinput() != CLR
     lPO_entered := .T.
     nPO_limit := nPO_temp	
     A_RJS_FEED(1, 1, 0, 1)
	A_RJS_PRNT(1, 1, 0, "PO Number: "+pad(cPO_Code,10,"0"),0)
	A_RJS_PRNT(1, 1, 0, "PO Limit: "+trans(nPO_Limit,"$***,**9.99"), 0)
	A_RJS_FEED(1, 1, 0, 1)
  endif	
        
  // restore previous screen
  CloseWindow(cWindow)

return nil

#ifdef NOTHING
function validate_po(nPaymAmt,cCode1)
local out_text

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
return nil
#endif

