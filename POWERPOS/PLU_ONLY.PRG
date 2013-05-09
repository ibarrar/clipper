#include "get_grfx.ch"
#include "grfx_all.ch"  
#include "spec_key.ch"

function online_plu(cPLUCode)
local cCode
local cItem
local cDesc
local cDept
local cPrice
local cPrice0
local cPrice1
local cWindow
local cData,ckey


  MsgAreaDisp("Please Enter code for inquiry...")
  while .t.

    ckey := input()

    do case
       case ckey == CLR
          if empty(cPLUCode)
             return nil
          endif
          cPLUCode := ""     
       case ckey == ENTER
          if !empty(cPLUCode)
            exit
          endif  
       case ckey == SCANNER
          cPLUCode := scandata()
          exit 
       case ( len(cData := is_number(@cKey)) > 0 ) .or. ( len(cData := is_alpha(@cKey)) > 0 )          
          if empty(cPLUCode)
             cPLUCode := ""
          endif   
          cPLUCode += cData
    endcase
    Disp_Data(cPLUCode)
  enddo     
    
  if !empty(cPLUCode)
    cPLUCode := padl(alltrim(cPLUCode),14,"0")
    if PLU_Get(cPLUCode) 

       cCode   := cPLU_Code()
       cItem   := cPLU_Item()
       cDesc   := cPLU_Desc()
       cDept   := cPLU_Dept()
       cPrice  := trans(nPLU_Pric(), "@B999,999.99")
       cPrice0 := trans(nPLU_Pric0(), "@B999,999.99")
       cPrice1 := trans(nPLU_Pric1(), "@B999,999.99")

       #ifdef DEF_GRAPHICS     
	  // display screen to getinput for local card payment
	  // save screen
	  cWindow := OpenWindow(22, 32, 81, 78, "Price Look-UP Information")

	  @ 45, 27 say "PLU Code" 
	  @ 49, 27 say "Item Code"
	  @ 53, 27 say "Item Desc."
	  @ 57, 27 say "Dept Desc."
	  @ 61, 27 say "Active Price"
	  @ 65, 27 say "Retail Price"
	  @ 69, 27 say "Wholesale Price"

	  @ 45, 48 say ":" 
	  @ 49, 48 say ":" 
	  @ 53, 48 say ":" 
	  @ 57, 48 say ":" 
	  @ 61, 48 say ":" 
	  @ 65, 48 say ":"         
	  @ 69, 48 say ":"        

	  @ 45, 50 get cCode when .F.
	  @ 49, 50 get cItem when .F.
	  @ 53, 50 get cDesc when .F.
	  @ 57, 50 get cDept when .F.
	  @ 61, 50 get cPrice when .F.        
	  @ 65, 50 get cPrice0 when .F.
	  @ 69, 50 get cPrice1 when .F.        

	  MsgAreaDisp("Press Any Key to Continue...")
	  readmodal()
	  input()
        
	  // restore previous screen
	  CloseWindow(cWindow)
        
    else
	ErrorDisp("PLU Code Not Found ...")          
    endif        

    cPLUCode := ""

  endif
  MsgAreaDisp()        
return nil

