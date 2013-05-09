#include "pfl_clip.ch"
#include "message.ch"
#include "spec_key.ch"
#include "keymap.ch"
#include "file_acc.ch"
#include "plu_file.ch"
#include "config.ch"
#include "nvr_file.ch"
#include "deptfile.ch"
#include "get_grfx.ch"
#include "powerpos.ch"

#ifdef DEF_GRAPHICS
  #include "grfx_all.ch"
#endif

function price_adjust()  
local lRetVal := .F.
local cKey := 0
local cKeybuff := ""
local cData
local i,cDispBuff
local nQuantity := 1
local nQtyBuff := ""
local nDept, out_text
local nPrice,Tprice,cQtyBuff

local array := { "    PROMO            ", ;
                 "    IN-HOUSE CARD    ", ;
                 "    PRICE-ADDON      " }
local d

MsgAreaDisp(MSG_D042)

while cKey != SUBTOTAL

     ckey := input()
     do case
        case !empty(cData := is_number(cKey))
             cKeyBuff += cData
             #ifdef DEF_GRAPHICS
               Disp_Data(cKeyBuff + "_")
             #endif          
#ifdef ALPHA_NUMERIC
       case !empty(cData := is_alpha( @cKey ) )
             cKeyBuff += cData
             #ifdef DEF_GRAPHICS
                Disp_Data(cKeyBuff + "_")
             #endif
#endif          
       case cKey == BACK_SPACE
          cKeyBuff := subs(cKeyBuff,1,len(cKeyBuff)-1)
             #ifdef DEF_GRAPHICS
                Disp_Data(cKeyBuff + chr(95))
             #endif  
        case cKey == PLU  .or. ckey == SUBTOTAL
             if empty(cKeyBuff)
                MsgAreaDisp(MSG_D005)
             else 
                exit
             endif 
        case ckey == QTY
             nQuantity := val(cKeyBuff)     
             cKeyBuff := ""
        case cKey == CLR
             if cKeyBuff == ""
                #ifdef DEF_GRAPHICS
                  Disp_Data(cKeyBuff + chr(95))
                #endif  
                exit
             endif    
             cKeyBuff := ""
             nQuantity := 1
             #ifdef DEF_GRAPHICS
                Disp_Data(cKeyBuff + chr(95))
             #endif  
        case cKey == SCANNER
             cKeyBuff := scandata()     
             if empty(cKeyBuff)
                MsgAreaDisp(MSG_D005)
             else 
                exit
             endif              
        otherwise
     endcase   

      if empty(cKeyBuff) 
         DISPTEXTXY(1, 1, 0, 0, 1, 1, "                   0" ) 
         DISPTEXTXY(0, 0, 1, 1, 0, 0, "        0" ) 
         if nQuantity  == 1 
            DISPTEXTXY(2, 1, 0, 0, 2, 1, "                    " ) 
            DISPTEXTXY(3, 1, 0, 0, 0, 0, "                    " )             
            MsgAreaDisp(MSG_D042)           
         else // second line
            cQTYBuff  := trans(nQuantity,"999")+"@ "                     
            DISPTEXTXY(2, 1, 0, 0, 2, 1, padl(cQtyBuff,20) )
            DISPTEXTXY(3, 1, 0, 0, 0, 0, MSG_CLEAR)      
            MsgAreaDisp(MSG_D042)               
         endif   
      else 
         // The cashier and customer display
         DISPTEXTXY(1, 1, 0, 0, 1, 1, padl(cKeyBuff,20) )
#ifdef DEF_DISP1X09
         i := len(cKeyBuff) - if("."$cKeyBuff,1,0)
          
         if (i <= 9)
            cDispBuff := space(9-i)+cKeyBuff
         else
            cDispBuff := subs(cKeyBuff,i-8)
         endif  
         DISPTEXTXY(0, 0 , 1, 1, 0, 0,cDispBuff)
#endif        
         if nQuantity  == 1
            DISPTEXTXY(2, 1, 0, 0, 2, 1, "                    " ) 
            DISPTEXTXY(3, 1, 0, 0, 0, 0, "                    " )             
            MsgAreaDisp(MSG_D042)           
         else // second line
            cQTYBuff  := trans(nQuantity,"999")+"@ "                        
            DISPTEXTXY(2, 1, 0, 0, 2, 1, padl(cQtyBuff,20) )
            DISPTEXTXY(3, 1, 0, 0, 0, 0, "                    " )
            MsgAreaDisp(MSG_D042)               
         endif   
         
     endif

  enddo

  if cKey == PLU .or. cKey == SCANNER

     if cKey == PLU .or. cKey == SCANNER
        lRetVal := adjust_plu(padl(alltrim(cKeyBuff),PLU_CODE_LEN,"0"),nQuantity)                       
     endif      

     if lRetVal  
        adjusted_price()
        tran_cCrgo()  // Reset the cargos
     endif                  
                
     // display subtotal...
     //
     DispSubtotal()

     #ifdef DEF_GRAPHICS
       Disp_BoldChar(nvr_nSUBtotal())
     #endif

  endif  

return lRetVal

static function adjust_plu(cPLUCode,nQty)
local lRetVal := .F.,lFound := .F.
local cBuffer,frame
local nPrice,cDesc,cCode,cDept
local nAmount  := 0
local cOutData := space(PLU_CODE_LEN)
local nQTYtotal,nAMTamount
local cData,out_text
local cIndata,status
local cWindow

   // seek plu master file thru file access...
   // prepare the space allocation

   if PLU_Get(cPLUCode)

      nPrice  := nPLU_Pric()
      cDesc   := cPLU_Desc()
      cDept   := cPLU_Dept()

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
      
      nAmount := nQty * nPrice

      tran_cPLU(  cPLUCode )  // 
      tran_cItem( cPLU_Item() )
      tran_cDept( cPLU_Dept() )
      tran_cFlag( OP_NPLU_FLAG ) // Found the plu set as normal
      tran_cPFlg( "1" )
      tran_cRegM( RegMode() ) // Temporarily set as keyboard method of entry
      tran_cPrcM(  "0" ) // Temporarily set as normal pricing method
      tran_cConc( cPLU_Conc() )
      tran_cColo( cPLU_Colo() )
      tran_cSize( cPLU_Size() )
      // Sale to be resolved later
      tran_nCntr(  nQty ) 
#ifdef NON_ADD_ENABLED	 
      // cargo 
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
      lRetVal := .T.
      
   else
   
      // Plu record was not found ....   
      // Get Input from operator
      
#ifdef DEF_DISP1X09                
      // customer display 1 (1x9)
      DISPTEXTXY(0, 0, 1, 1, 0, 0, "E")
#endif                

#ifdef DEF_DISP4X20
      // cashier display (4x20)
      DISPTEXTXY(1, 1, 0, 0, 0, 0, "CODE: "+cPLUCode)        
      DISPTEXTXY(3, 1, 0, 0, 0, 0, "                    ")
      DISPTEXTXY(4, 1, 0, 0, 0, 0, "NOT FOUND PLU...    ")
#endif  

      Beep_3() 

      // initialize all variables
      nPrice := 0
      cDesc  := space(PLU_DESC_LEN)
      cDept  := space(PLU_DEPT_LEN)
      
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

      cDesc := cDEPT_Desc()            

      @ 55, 46 say cDesc
      
      HEYTHERE()
      
      // restore previous screen
      CloseWindow(cWindow)

      MsgAreaDisp(MSG_CLEAR)
                 
      cDesc := "P"+subs(cPLUCode,2)+" D"+cDept
      nAmount := nQty * nPrice

      tran_cPLU(  padl(alltrim(cPLUCode),TRAN_PLU_LEN,"0" ))  // 
      tran_cItem( repl("?",TRAN_ITEM_LEN )  )
      tran_cDept( padl(cDept,TRAN_DEPT_LEN, "0" )  )
      tran_cFlag( OP_NOTF_FLAG ) // Flag Set As not found PLU
      tran_cPFlg( "1" )
      tran_cRegM( RegMode() )
      tran_cPrcM( "0" ) // Temporarily set as normal pricing method
      tran_cConc( repl("?",TRAN_CONC_LEN)  ) // Concessionaire
      tran_cColo( repl("?",TRAN_COLO_LEN)  ) 
      tran_cSize( repl("?",TRAN_SIZE_LEN)  )
      // Sale to be resolved later
      tran_nCntr(  nQty ) 
#ifdef NON_ADD_ENABLED	 
      // cargo
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
      lRetVal := .T.
   endif                    

return lRetVal             

