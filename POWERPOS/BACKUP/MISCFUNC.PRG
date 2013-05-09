#include "oneshot.ch"
#include "pfl_clip.ch"
#include "spec_key.ch"
#include "message.ch"
#include "config.ch"

#define MAXIMUM_MISC        50  
#define TYPE_BANKCARD       "0"

static aInvoice_ := {}
static aMisc_ := {}

function charge_init()
local aDummy_ := array(MAXIMUM_MISC)
local i,k,aTemp
local cCode,cType,cDesc
local aCode := {}
local cBuffer 

   aSize( aMisc_, MAXIMUM_MISC )   
   
   afill(aDummy_,"")  
   
   parse(CONFIG_ITM_FILE,CONFIG_MISC_LINES,aDummy_)

   for i := 1 to MAXIMUM_MISC

     aTemp := getparse(aDummy_[i])         
     cCode := if(len(aTemp)>0, aTemp[1], "") 
     cType := if(len(aTemp)>1, aTemp[2], "") 
     cDesc := if(len(aTemp)>2, aTemp[3], "")     

     if right(cCode,1) != ","
        cCode += ","
     endif
        
     cBuffer := ""    
     aCode := {}
     for k:= 1 to len(cCode)
       if subs(cCode,k,1) == "," 
          aAdd(aCode,padl(alltrim(cBuffer),4,"0"))
          cBuffer := ""
       else
          cBuffer += subs(cCode,k,1)
       endif   
     next
     
     if empty(aCode)
       aCode := {""}
     endif    
         
     aMisc_[i] := { subs(cCode,1,4), cType, cDesc }
     
   next   

return nil   

function isMisc(cCode)
local k,nRetVal := 0

  for k := 1 to len(aMisc_)
     if aScan(aMisc_[k][1] , { |x| x == cCode }) > 0
        nRetVal := k        
        exit
     endif 
  next

return nRetVal

function GetMType(nVal)
return aMisc_[nVal][2]

function GetMDesc(nVal)    
return aMisc_[nVal][3]

function GetMCode(nVal)
return aMisc_[nVal][1]

function getparse(cData)
local cBuffer, j
local aRetVal := {}

    if right(cData,1) != ";"
       cData += ";"
    endif
       
    cBuffer := ""
    for j := 1 to len(cData) 
       if subs(cData,j,1) == ";"  
          aAdd(aRetVal,cBuffer)
          cBuffer := ""
       else 
          cBuffer += subs(cData,j,1)
       endif 
    next
    
return aRetVal

#ifdef SLIP_PRNT
function slip_prompt(cMessage)
local status
local cKey := 0
local lRetVal := .F.

    if empty(cMessage)
       cMessage := MSG_D028
    endif   
    
    // check first if the slip printer is configured at system.cfg
    if config(POS_XSLIP_PRN) == "YES"

       MsgAreaDisp(cMessage)    

       while ((cKey := input()) != VALIDATE ) ; enddo       

       while .T. 


         // check if power is ok...
         // initialize optional slip printer...
         status := slip_esc("1B40")

         // set print mode...
         status := slip_esc("1B2101")

         // set font to 7x7 (ESC + M)...
         status := slip_esc("1B4D")
         

         // issue an error beep...
         beep_2()
         do case 
            case status == SLIP_PAPER_OUT 
                 ErrorDisp("PAPER OUT ERROR!   ")                 
            case status == DEV_NOT_EXIST .or. status == DEV_NOT_READY
                 ErrorDisp("SLIP PRINTER IS OFF")
            otherwise
                 exit                 
         endcase         
         MsgAreaDisp(cMessage)    
       enddo        
       
       lRetVal := .T.               
    
    endif

return lRetVal

function slip_check(cText, nVar )
local status
local cKey := 0
local lRetVal := .F.

    // check first if the slip printer is configured at system.cfg
    if config(POS_XSLIP_PRN) == "YES"

       status := slip_esc("1B40")
       status := slip_esc("1B2101")
       status := slip_esc("1B4D")

       while status != NORMAL

         // issue an error beep...
         beep_2()
         do case 
            case status == SLIP_PAPER_OUT 
                 ErrorDisp("PAPER OUT ERROR!   ")                 
            case status == DEV_NOT_EXIST .or. status == DEV_NOT_READY
                 ErrorDisp("SLIP PRINTER IS OFF")
         endcase         
         
         status := slip_esc("1B40")
         status := slip_esc("1B2101")
         status := slip_esc("1B4D")
         
       enddo        

       slip_print( cText , if(nVar==NIL,0,nVar) )       
    
    endif

return status


function add_invoice( aInv_ )
local n

   if ( ( n:= aScan( aInvoice_ , { |x| x[1] == aInv_[1] } ) ) > 0)
       aInvoice_[n][2] += aInv_[2]
   else
      aAdd( aInvoice_ , aInv_ )
   endif       
  
return nil

function del_invoice()
  aInvoice_ := {}
return nil

function print_invoice()
local i
local out_text,cData
local total := 0
local lYes := .F.

  // check if the there is possible SLIP# validation...
  for i := 1 to len(aInvoice_)
    if GetMType(aInvoice_[i][1]) != TYPE_BANKCARD
       lYes := .T.
       exit
    endif
  next

  if !empty(aInvoice_) .and. lYes
  
   MsgAreaDisp(MSG_D036)
    cData := ""
    while empty(cData)
      DISPTEXTXY(4,1,0,0,0,0,"SLS.SLIP#:          ")
      cData := readdata(4,11,1,1,0,0,{ |x| ( ((!empty(is_number(x)) .and. (x != KEY_PERIOD)) .or. is_dept(x) != 0) )},10,"SLS.SLIP#:          ")
      out_text := "CHARGE INV.# "+cData
      rpt_prnt(1,1,0,out_text,0)  
      tran_cCrg3(cData)        
    enddo
    
    if config(POS_XSLIP_PRN) == "YES"
      slip_prompt("Insert Charge Invoice Form & Press <VALID> key ")    
      slip_check( out_text )                
      slip_check(chr(10))    
    
      for i := 1 to len (aInvoice_)
          out_text := pad("PAYMENT ("+GetMDesc(aInvoice_[i][1])+")",32)+trans(aInvoice_[i][2],"999,999.99")+ chr(10)
          slip_check( out_text )
          total += aInvoice_[i][2]
      next    
      out_text := pad("CHARGED TOTAL",32) + +trans(total,"999,999.99")+ chr(10)
      slip_check(out_text)
      out_text := dtoc(date()) + '  ' + substr(time(), 1, 5) + '  ' + ;
                  subs(nvr_cCashCode(),1,3) + '***  ' + padl(nvr_nTrans(), 6, "0") + "#  " + ;
                  config(POS_TERM_NUM) +  chr(10)  
      slip_check( out_text )     
    endif                                
    
  endif              
  
  // clear the array 
  aInvoice_ := {} 
  MsgAreaDisp(MSG_CLEAR)
return nil
#endif