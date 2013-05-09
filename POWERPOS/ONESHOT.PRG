#include "oneshot.ch"
#include "powerpos.ch"
#include "spec_key.ch"

static oneshot_ := {}

function oneshot_init()
local i
local aDummy_ := {}
local aItems := {}

  asize ( aDummy_, CONFIG_PLU_LEN)
  afill ( aDummy_, "")

  if !parse(CONFIG_ITM_FILE,CONFIG_PLU_LINES,aDummy_)
     // put all default values of keymap here
     // this case reset keyboard definitions...
     afill ( aDummy_ , "" )
  endif 

  for i := 1 to CONFIG_PLU_LEN
     if !empty(aDummy_[i])
       aItems :=  getparse(aDummy_[i])
       
       aAdd( oneshot_ , {i,aClone(aItems)} )

     endif
  next

return nil

function is_oneshot(nVar)  
local cPLUCode := ""
local n,k
local aTemp := {}
local aData := {}
local cData := ""
local cTitle 

  if ( (n := aScan(oneshot_, { |x| x[1] == nVar } )) > 0)
      
     aTemp := oneshot_[n][2]

     if len(aTemp) == 1
        cPLUCode := padl(alltrim( aTemp[1] ),14,"0") 
     else   

       cTitle := aTemp[1]

       for k := 2 to len(aTemp)
      
         cData := padl(alltrim( aTemp[k] ),14,"0") 
       
         if PLU_Get(cData)
            aAdd(aData, cPLU_Desc() )
         else   
            aAdd(aData, cData )
         endif
       next  
     
       k := alookup( 30,35, aData, cTitle )     
     
       if ( k > 0 .and. lastinput() == ENTER )
         cPLUCode := padl(alltrim(oneshot_[n][2][k+1]),14,"0")
       endif 
       
     endif  
     
  else
    ErrorDisp(" One shot was not defined on itemmap.cfg ")     
  endif   
    
return cPLUCode

/* Eof */