#include "get_grfx.ch"
#include "message.ch"
#include "spec_key.ch"


static lPO_entered := .F.
static cPO_Code := "          "

function lPO_entered(lVar)
	if Valtype(lVar) == "L"
	   lPO_entered := lVar
	   if !lPO_entered
	     nvr_nPOL_total(0)
           endif
	endif   
return lPO_entered

/*
function nPO_Limit(nValue)
 if valtype(nValue) == "N"
    nPO_Limit := nValue
 endif
return (nPO_limit)
*/

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

  nPO_temp := nvr_nPOL_total()-nvr_nSUBtotal()
 
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
     nvr_nPOL_total(nPO_temp)	
     A_RJS_FEED(1, 1, 0, 1)
	A_RJS_PRNT(1, 1, 0, "PO Number: "+pad(cPO_Code,10,"0"),0)
	A_RJS_PRNT(1, 1, 0, "PO Limit: "+trans(nPO_temp,"$***,**9.99"), 0)
	A_RJS_FEED(1, 1, 0, 1)
  endif	
        
  // restore previous screen
  CloseWindow(cWindow)

return nil

