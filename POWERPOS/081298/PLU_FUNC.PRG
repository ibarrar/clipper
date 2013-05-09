#include "nvr_file.ch"
#include "config.ch"
#include "message.ch"
#include "terminal.ch"
#include "deptfile.ch"
#include "plu_file.ch"
#include "get_grfx.ch"
#include "spec_key.ch"

#ifdef DEF_GRAPHICS
 #include "grfx_all.ch"
#endif  

#define LMARGIN         12

function plu_request(cPLUCode,nQty)
local lRetVal    := .F.
local cDesc      := ""
local cDept      := space(4)
local nAmount    := 0
local nPrice     := 0
local nQTYtotal  := 0
local nAMTamount := 0
local out_text
local cWindow

    if empty(cPLUCode)
       if nQty != 1
          ErrorDisp(MSG_D005) // Invalid Code...
          return .F.
       endif
       
       cPLUCode := cPLU_Prev()

       if empty(cPLUCode)
          ErrorDisp(MSG_D005) // Invalid Code...
          return .F.
       endif   
    else    
       cPLUCode := padl(alltrim(cPLUCode),PLU_CODE_LEN,"0")
    endif    

    if nQty < 1
      ErrorDisp(MSG_D007)
      return .F.
    endif

    if PLU_Get(cPLUCode)

      cDesc  := cPLU_Desc()
      cDept  := cPLU_Dept()
      nPrice := nPLU_Pric()

      if lPLU_Sdpt()
         cWindow := OpenWindow(20, 34, 78, 68, "Sub-Department PLU")

         @ 47, 30 say "PLU Code  : " get cPLUCode WHEN .F.
         @ 51, 30 say "Descriptor: " get cDesc    WHEN .F.
         @ 55, 30 say "PLU Price : " get nPrice MESS "ENTER PLU PRICE...  " PICT "9,999,999.99"     
         @ 59, 30 say "Dept Code : " get cDept  WHEN .F.
            
         readmodal()

         MsgAreaDisp()

         if lastinput() != ENTER
            // restore previous screen
            CloseWindow(cWindow)
            return .F.
         endif          

        CloseWindow(cWindow)
        
      endif                             

      nAmount := ( nPrice * nQty ) // we just multiply the unit price
                                  // to the no of items(qty) purchased          
      tran_cPLU ( cPLU_Code() )  
      tran_cItem( cPLU_Item() )
      tran_cDept( cDept ) 
      tran_cFlag( OP_NPLU_FLAG ) // Found the plu set as normal
      tran_cPFlg( "0" )          // Found the plu set as normal
      tran_cRegM( RegMode() ) 
      tran_cPrcM( cPLU_PLev() )  // Depends on what level is used
      tran_cConc( cPLU_Conc() )  // not enough lenght
      tran_cColo( cPLU_Colo() )  
      tran_cSize( cPLU_Size() )
      tran_nSale(  nAmount ) 
      tran_nCntr(  nQty ) 
#ifdef NON_ADD_ENABLED
      if !isClerk()
         tran_cClrk( "" )        // no clerk entry so clean variable...
      endif    
#endif	 
      tran_cCrgo( nPLU_Cost() )  // store the unit cost to the order no.
      tran_cDesc( cDesc  )
      tran_nPric( nPrice )
      tran_nQty ( nQty  )

            
   else
   
      // Plu record was not found ....   
      // Get Input from operator   

#ifdef DEF_DISP1X09                
      DISPTEXTXY(0, 0, 1, 1, 0, 0, "E")      // customer display 1 (1x9)
#endif                

#ifdef DEF_DISP4X20
      // cashier display (4x20)
      DISPTEXTXY(1, 1, 0, 0, 2, 1, "CODE: "+cPLUCode     )        
      DISPTEXTXY(3, 1, 0, 0, 0, 0, "                    ")
      DISPTEXTXY(4, 1, 0, 0, 0, 0, "NOT FOUND PLU...    ")
#endif  

      Beep_3() 
      
      // display screen to getinput not found plu code
      // save screen
      cWindow := OpenWindow(20, 34, 78, 64, "PLU NOT FOUND MENU")

      @ 47, 30 say "PLU Code  : " get cPLUCode WHEN .F.
      @ 51, 30 say "PLU Price : " get nPrice MESS "ENTER PLU PRICE...  " PICT "9,999,999.99"     
      @ 55, 30 say "Dept Code : " get cDept  MESS "ENTER DEPT. CODE... " PICT "9999" VALID Vldt_Dept(@cDept)
            
      readmodal()

      if lastinput() == CLR
         // restore previous screen
         CloseWindow(cWindow)
         return .F.
      endif          

      cDesc := padl(cPLUCODE, 20, "0")

      @ 55, 46 say cDEPT_Desc()            
      
      HEYTHERE()
      
      // restore previous screen
      CloseWindow(cWindow)

      MsgAreaDisp(MSG_CLEAR)
                 
      nAmount := nQty * nPrice

      tran_cPLU ( cPLUCode ) 
      tran_cItem( right(cPLUCode,TRAN_ITEM_LEN) ) 
      tran_cDept( cDept  )
      tran_cFlag( OP_NOTF_FLAG )                   // Flag Set As not found PLU
      tran_cPFlg( "0" )                            // set as normal
      tran_cRegM( RegMode() ) 
      tran_cPrcM( cPLU_PLev() )
      
*     tran_cConc( repl("?",TRAN_CONC_LEN) )        // Concessionaire

      tran_cConc( subs(cPLUCode,7,TRAN_CONC_LEN) ) // Concessionaire
      
      tran_cColo( repl("?",TRAN_COLO_LEN) )  
      tran_cSize( repl("?",TRAN_SIZE_LEN) ) 
      tran_nSale( nAmount ) 
      tran_nCntr( nQty ) 
#ifdef NON_ADD_ENABLED
      if !isClerk()
         // no clerk entry so clean variable...
         tran_cClrk( "" )
      endif    
      if !isNonAdd()
         tran_cCrgo( "" )
      endif      
#endif	 
      tran_cDesc(  cDesc )
      tran_nPric(  nPrice )
      tran_nQty (  nQty  )

   endif                    

   nQTYtotal  := nvr_nQTYitems() + nQty
   nAMTamount := nvr_nSUBtotal() + nAmount
   
   if nAmount > AMT_LALO .and. nAmount < AMT_HALO .and.;
      nQtytotal < TOTQTY_HALO .and. nAMTamount < TOTAMT_HALO 
          
      disp_plu( cPLUCode,cDesc,cDept,tran_cClrk(),nQty,nPrice,nAmount)

      // Add this record to the nvcntrl trans file...
      Update_Trans()

      nvr_nQtyitems(nQTYtotal)
      nvr_nSUBtotal(nAMTamount) 

      Term_nData(TR_DEPT_TOT,nAmount) // add the dept sale to the dept totals

      print_plu(cPLUCode,nQty,nPrice,nAmount,cDesc)
      
      if ( tran_cFlag() == OP_NOTF_FLAG )
         if !lNFND_Add(cPLUCode,cDesc,cDept,nQty,nPrice,0 )
               MsgAreaDisp(" PLU TEMP update not normal ...")                
         endif
#ifdef DEF_GRAPHICS
         Rcpt_Scroll(1, cPLUCode, nQty, nPrice, OP_NOTF_FLAG, 0, 0, 0, 0, tran_cClrk()) 
#endif                    
      else
#ifdef DEF_GRAPHICS
         Disp_BoldChar(nvr_nSUBtotal(), "Total Amount")
         Rcpt_Scroll(1, cDesc, nQty, nPrice, tran_cFlag(), 0, 0, 0, 0, tran_cClrk())
#endif               
         plu_counter(cPLUCode, nQty, nAmount, 0)
      endif   
      dept_counter(cDept, nQty, nAmount, 0)
                  
#ifdef DEF_GRAPHICS
      Disp_BoldChar(nvr_nSUBtotal())  // display the running total 
                                      // if plu is successful....
#endif   
      lRetVal := .t.
	 
 	 // this if for department wide discounts
	 if Dept_Get(cDept)
	    if nDept_Disc() > 0
		  discount(str(nDept_Disc()))	       
	    endif
	 endif

   else
      ErrorDisp(MSG_D013)  
      tran_init()
   endif  
                           
return lRetVal


function disp_plu(cCode,cDesc,cDept,cClerk,nQty, nPrice, nAmount)
local cBuffer

#ifdef DEF_DISP1X09
    cBuffer := tran(nAmount,"9999999.99")
    DISPTEXTXY( 0, 0, 1, 1, 0, 0, cBuffer )
#endif          
   if nQty != 1      
       cBuffer := tran(nQty,"999") + "@ " + tran(nPrice,"999,999.99")       
       DISPTEXTXY(0, 0, 0, 0, 2, 1, subs(cDesc,1,10)+ tran(nAmount,"999,999.99" ))   
   else
       cBuffer := tran(nAmount,"999,999.99")
       DISPTEXTXY(0, 0, 0, 0, 2, 1, cDesc )   
   endif
   DISPTEXTXY(0, 0, 0, 0, 1, 1, padl(cBuffer,20) )

#ifdef DEF_DISP4X20
   DISPTEXTXY(1, 1, 0, 0, 0, 0, pad((cCode+" D"+cDept),20)   )
   DISPTEXTXY(2, 1, 0, 0, 0, 0, pad(cDesc,20)   )    
   DISPTEXTXY(3, 1, 0, 0, 1, 1, padl(cBuffer,20))    
   if val(cClerk) > 0
     cBuffer :=  "CK:"+subs(cClerk,1,6)+tran(nAmount,"9999,999.99")
   else     
     cBuffer :=  "         "+tran(nAmount,"9999,999.99")     
   endif          
   DISPTEXTXY(4, 1, 0, 0, 0, 0, cBuffer )
#endif   
                                 
return nil  


function print_plu(cPLUCode,nQty,nPrice,nAmount,cDesc)
local out_text

  // prepare to print values 
  rpt_prnt(0, 1, 0, cPLUCode, 0)            
      
  if nQty > 1
	  out_text :=space(LMARGIN)+trans(nQty,"999 @  ")
	  out_text += trans(nPrice,"999,999.99")
	  // now print the values
	  rpt_prnt(1, 1, 0, out_text, 0)
  endif
                     
  out_text := cDesc
  out_text += "  " +  trans(nAmount,"999,999.99")
         
  // now print the values
  rpt_prnt(1, 1, 0, out_text, 0)
      
return nil

function reprint_plu(cPLUCode,nQty,nPrice,nAmount,cDesc)
local out_text

  if nQty > 1
	  out_text :=space(LMARGIN)+trans(nQty,"999 @  ")
	  out_text += trans(nPrice,"999,999.99")
	  // now print the values
	  rpt_prnt(1, 0, 0, out_text, 0)
  endif
                     
  out_text := cDesc
  out_text += "  " +  trans(nAmount,"999,999.99")
         
  // now print the values
  rpt_prnt(1, 0, 0, out_text, 0)
      
return nil


/* ------------ eof --------------*/