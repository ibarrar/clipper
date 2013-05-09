#include "message.ch"
#include "spec_key.ch"
#include "keymap.ch"
#include "config.ch"
#include "file_acc.ch"

#define SOS_LEN  6

static lNonAdd_Entry := .F.

function isNonAdd(lVar)
  if valtype(lVar) == "L"
     lNonAdd_Entry := lVar
  endif
return lNonAdd_Entry

function get_SOS( cVal )
local out_text,cKey := ENTER
static cSOSBuff := ""

  if empty(cVal) .or. "."$cVal
  
     disp_clr()
          
     if !empty(cSOSBuff)
       DISPTEXTXY( 1, 1, 0, 0, 1, 1, "SOS # : " + cSOSBuff )
       MsgAreaDisp(MSG_D034)       
       cKey:=input()
     endif       
     
     if empty(cSOSBuff) .or. ( cKey != ENTER )       
       MsgAreaDisp(MSG_D020)               
       // For Display prompts
       DISPTEXTXY( 1, 1, 0, 0, 1, 1, "SOS # :             " )
       cSOSBuff:= ReadData( 1, 9, 0, 0, 1, 9, { |x| (!empty(is_number(x)) .and. (x != KEY_PERIOD) )  }, SOS_LEN,MSG_D020, cKey )

       if empty(cSOSBuff)
          return nil
       endif
     endif  
  else  
    cSOSBuff := cVal
  endif   
  
  cSOSBuff := padl(alltrim(cSOSBuff),SOS_LEN,"0")
    
  DISPTEXTXY( 1, 1, 0, 0, 1, 1, pad("SOS # : "+cSOSBuff,20) )  

  tran_cCrgo(cSOSBuff)

  out_text := "SOS# "+tran_cCrgo()
  A_RJS_PRNT(1, 1, 0, out_text , 0)
  lNonAdd_Entry := .T.

return nil

