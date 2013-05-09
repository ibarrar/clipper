#include "powerpos.ch"
#include "plu_file.ch"
#include "deptfile.ch"
#include "message.ch"
#include "spec_key.ch"
#include "file_acc.ch"
#include "nvr_file.ch"
#include "terminal.ch"
#include "config.ch"
#include "get_grfx.ch"
#include "return.ch"

#ifdef DEF_GRAPHICS
  #include "grfx_all.ch"
#endif

#define LMARGIN 12

function ret_exch()
local lRetVal := .F.
local cKey := 0
local cData,ckeyBuff := ""
local i,cDispBuff
local nQuantity := 1
local cQtyBuff := ""
local nDept,out_text
local nPLU := 0

 DISPTEXTXY(1, 1, 0, 0, 1, 1, "                   0" ) 
 DISPTEXTXY(0, 0, 1, 1, 0, 0, "        0" ) 
 DISPTEXTXY(2, 1, 0, 0, 2, 1, "                    " ) 
 DISPTEXTXY(3, 1, 0, 0, 0, 0, "                    " )             
 MsgAreaDisp(MSG_D026)

  while cKey != SUBTOTAL

     ckey := input()
     do case
        case !empty(cData := is_number(cKey))
             ckeyBuff += cData
             #ifdef DEF_GRAPHICS
               Disp_Data(cKeyBuff)
             #endif          
#ifdef ALPHA_NUMERIC
       case !empty(cData := is_alpha( @cKey ) )
             cKeyBuff += cData
             #ifdef DEF_GRAPHICS
                Disp_Data(cKeyBuff)
             #endif
#endif          
        case cKey == PLU  .or. ckey == SUBTOTAL
             if empty(cKeyBuff)
                MsgAreaDisp(MSG_D005)
             else 
                exit
             endif 
        case (is_dept(cKey) != 0)
             // Put a decimal if there is none
             cKeyBuff := put_Decimal(cKeyBuff)

             if val(cKeyBuff)*nQuantity > TOTAMT_HALO .or. (val(cKeyBuff)*nQuantity <= AMT_LALO)
                  ErrorDisp(MSG_D008) // amount may have exceeded or less than expected
             else 
                exit       
             endif 
        case ckey == QTY
             nQuantity := val(ckeyBuff)     
             ckeyBuff := ""
        case cKey == CLR
             if cKeyBuff == ""
                exit
             endif    
             cKeyBuff := ""
             nQuantity := 1
        case cKey == SCANNER 
             cKeyBuff := scandata()     
             if empty(cKeyBuff)
                MsgAreaDisp(MSG_D005)
             else 
                exit
             endif              
/*        case  (nPLU := isPLU()) > 0 
             if nPLU > 0              
               cKeyBuff := is_oneshot(@nPLU) // this is a oneshot plu...            
             endif  
             if empty(cKeyBuff)
               MsgAreaDisp(MSG_D005)
               nQuantity := 1
             else
               exit  
             endif  
        otherwise */
     endcase   

      if empty(cKeyBuff) 
         DISPTEXTXY(1, 1, 0, 0, 1, 1, "                   0" ) 
         DISPTEXTXY(0, 0, 1, 1, 0, 0, "        0" ) 
         if nQuantity  == 1 
            DISPTEXTXY(2, 1, 0, 0, 2, 1, "                    " ) 
            DISPTEXTXY(3, 1, 0, 0, 0, 0, "                    " )             
            MsgAreaDisp(MSG_D026)           
         else // second line
            cQTYBuff  := trans(nQuantity,"999")+"@ "                     
            DISPTEXTXY(2, 1, 0, 0, 2, 1, padl(cQtyBuff,20) )
            DISPTEXTXY(3, 1, 0, 0, 0, 0, MSG_CLEAR)      
            MsgAreaDisp(MSG_D026)               
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
            MsgAreaDisp(MSG_D026)           
         else // second line
            cQTYBuff  := trans(nQuantity,"999")+"@ "                        
            DISPTEXTXY(2, 1, 0, 0, 2, 1, padl(cQtyBuff,20) )
            DISPTEXTXY(3, 1, 0, 0, 0, 0, "                    " )
            MsgAreaDisp(MSG_D026)               
         endif   
         
     endif
                       
         
  enddo

  if cKey == PLU .or. (is_dept(cKey) != 0) .or. cKey == SCANNER .or. nPLU > 0

     if cKey == PLU .or. cKey == SCANNER .or. nPLU > 0
        lRetVal := exchange_plu(padl(alltrim(cKeyBuff),PLU_CODE_LEN,"0"),nQuantity)                       
     elseif (( nDept := is_dept(cKey)) != 0)  
        lRetVal := exchanged_dept(nDept,nQuantity,cKeyBuff)
     endif      

     if lRetVal  
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


static function exchange_plu(cPLUCode,nQty)
local lRetVal := .F.
local nPrice,cDesc,cCode,cDept
local nAmount  := 0
local nQTYtotal,nAMTamount
local cData,out_text
local status
local nCounter,nTotals
local nPTDqty,nPTDamt
local nPriceLev := 0
local TotPrice := 0
local cItmCode
local cWindow 

   // seek plu master file thru file access...
   // prepare the space allocation

   if PLU_Get(cPLUCode)

      nPrice := nPLU_Pric()
      cDesc  := cPLU_Desc()
      cDept  := cPLU_Dept()
      nPriceLev := nPLU_Cost()
      cItmCode := cPLU_Item()

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
      TotPrice := nQty * nPriceLev

      tran_cPLU(  cPLUCode )  // 
      tran_cItem( cPLU_Item() )
      tran_cDept( cPLU_Dept() )
      tran_cFlag( OP_REXC_FLAG ) // Found the plu set as normal
      tran_cPFlg( OP_NPLU_FLAG )
      tran_cRegM( RegMode() ) // Temporarily set as keyboard method of entry
      tran_cPrcM(  "0" ) // Temporarily set as normal pricing method
      tran_cConc( cPLU_Conc() )
      tran_cColo( cPLU_Colo() )
      tran_cSize( cPLU_Size() )
      // this is other income situation make neccessary adjustments...
      tran_nSale( nAmount )
      tran_nCntr(  nQty ) 
      // cargo 
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
      tran_cFlag( OP_REXC_FLAG )
      tran_cPFlg( OP_NOTF_FLAG )
      tran_cRegM( RegMode() )
      tran_cPrcM( "0" ) // Temporarily set as normal pricing method
      tran_cConc( repl("?",TRAN_CONC_LEN)  ) // Concessionaire
      tran_cColo( repl("?",TRAN_COLO_LEN)  ) 
      tran_cSize( repl("?",TRAN_SIZE_LEN)  )
      // this is other income situation make neccessary adjustments...
      tran_nSale( nAmount ) 
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

   endif                    

   nQTYtotal  := nvr_nQTYitems() - nQty
   nAMTamount := nvr_nSUBtotal() - nAmount
   
   if nAmount > AMT_LALO .and. nAmount < AMT_HALO .and. ;
      nQtytotal < TOTQTY_HALO .and. nAMTamount < TOTAMT_HALO

      if nAmount > nvr_nSUBtotal()      
         
         // Other income condition
         BEEP_4() 
         out_text := "EXCHG. AMT:"+ trans(nvr_nSUBtotal(),"99,999.99")
         DISPTEXTXY(1, 1, 0, 0, 1, 1, out_text )
         out_text := "RETURN AMT:"+ trans(-nAmount,"99,999.99")
         DISPTEXTXY(2, 1, 0, 0, 2, 1, out_text )        
         out_text := "EXCESS AMT:"+ trans(nAMTamount,"99,999.99")
         DISPTEXTXY(3, 1, 0, 0, 0, 0, out_text )
         
         MsgAreaDisp("<OTH_INC> TO CONFIRM")

         if input() == OTH_INC
 
            disp_ret(OP_REXC_FLAG,cPLUCode,cDesc,nQty,nPrice,nAmount)         

            // less the dept returns to the dept totals        
            //Term_nData(TR_DEPT_TOT, -nAmount)                  
            // Term_nData(TR_REXC_TOT, nAmount + nAMTamount )   
            
            Term_nData(TR_REXC_TOT, nAmount )   
            Term_nData(TR_REXC_KNT, 1)            

            // put the returned record on nvcntrl trans file...
            Update_trans()
            
            // increment the return total & counter
            retexch_counter(tran_cPLU(),tran_cItem(),tran_cDesc(),tran_cDept(), tran_nQty(), tran_nPric(), tran_nSale())

	    if tran_cPFlg() == OP_NPLU_FLAG
	       plu_counter(cPLUCode, -nQty, -nAmount, 0)
	       dept_counter(cDept, -nQty, -nAmount, 0)                  
	    elseif tran_cPFlg() == OP_NOTF_FLAG
	       dept_counter(cDept, -nQty, -nAmount, 0)                  
	      // lNFND_Add(cPLUCode,cDesc,cDept,-nQty,nAmount, 0) -> jlp
	       lNFND_Add(cPLUCode,cDesc,cDept,-nQty,nPrice, 0)
	    endif            
            
            // prepare to print values 
            rpt_prnt(0, 1, 0, cPLUCode, 0)            
        
            out_text :=pad("*RETURN",LMARGIN)+trans(nQty,"999 @  ")
            out_text += trans(nPrice,"999,999.99")
            // now print the values
            rpt_prnt(1, 1, 0, out_text, 0)            
                     
            out_text := cDesc
            out_text += "  " +  trans(-nAmount,"999,999.99")
         
            // now print the values
            rpt_prnt(1, 1, 0, out_text, 0)

#ifdef SLIP_PRNT            
            slip_prompt("Insert Sales Slip & Press <VALID> key") 
            
            // set font to 15.6 cpi normal...
            //
            // A_PRT_ESC(NORMAL_15)
            out_text := "*** RET/EXCH " + transform(nAMTAmount, "***,**9.99") + " " + ;
                         dtoc(date()) + " " + substr(time(), 1, 5) + " ***" + chr(10)

            // print to optional slip printer...            
            slip_check(out_text)
#endif

            // then make a new record for the add-on record
            tran_cPLU(  repl("?",TRAN_PLU_LEN   ) )  // 
            tran_cItem( repl("?",TRAN_ITEM_LEN  ) )
            tran_cDept( repl("?",TRAN_DEPT_LEN ) )
            tran_cFlag( OP_OINC_FLAG ) // Flag Set As Other Income by ret-exch.
            tran_cPFlg( OP_REXC_FLAG )
            tran_cRegM( "0" ) // Temporarily set as keyboard method of entry
            tran_cPrcM( "0" ) // Temporarily set as normal pricing method
            tran_cConc( repl("?",TRAN_CONC_LEN) ) // Concessionaire
            tran_cColo( repl("?",TRAN_COLO_LEN) )  
            tran_cSize( repl("?",TRAN_SIZE_LEN) ) 
            tran_nSale( -nAmtAmount  ) 
            tran_nCntr( 1 ) 
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
            tran_cDesc(  )
            tran_nPric( -nAmtAmount )
            tran_nQty ( 1 )               

#ifdef DEF_GRAPHICS
      Rcpt_Scroll(1, cDesc, nQty, nPrice, OP_REXC_FLAG, 0, 0, 0, 0, tran_cClrk())
#endif 
            Update_trans()        

            // POS receipt and journal printer...
            // skip one line...
            A_RJS_FEED(1, 1, 0, 1)                      

            out_text := pad("*OTHINC(RET/EXCH)",22) + trans(-nAmtAmount, "999,999.99") + chr(10) 
            rpt_prnt(1, 0, 0, out_text, 0)                       

            // on journal...
            out_text := pad("*OTHINC(RET/EXCH)",22) + trans(-nAmtAmount, "999,999.99") + chr(10) 
            rpt_prnt(0, 1, 0, out_text, 0)                                                      
            
#ifdef SLIP_PRNT            
            out_text := "*** OTHINC   " + transform(-nAmtAmount, "***,**9.99") + " " + ;
                         dtoc(date()) + " " + substr(time(), 1, 5) + " ***" + chr(10)

            // print to optional slip printer...            
            slip_check(out_text,0)            
#endif            

            Term_nData(TR_OINC_TOT, -nAMTAmount )
            Term_nData(TR_OINC_KNT, 1 )                     
            
            // add the dept sale to the dept totals
            // Term_nData(TR_DEPT_TOT, -nAMTAmount )      
            // Term_nData(TR_DSLS_TOT, -nAMTAmount )
            // Term_nData(TR_CASH_TOT, -nAMTAmount )   
            // Term_nData(TR_DSLS_TOT, -nAmount )                           

            nvr_nQtyitems(nQTYtotal)            
            nvr_nSUBtotal(0)             
            
            lRetVal := .t.                                         
            

         else
            tran_init()
            BUMMER()
            MsgAreaDisp("EXCHANGED CANCELLED!")
         endif               
                                                                
      else 
      
        disp_ret(OP_REXC_FLAG,cPLUCode,cDesc,nQty,nPrice,nAmount)

#ifdef DEF_GRAPHICS
      Rcpt_Scroll(1, cDesc, nQty, nPrice, OP_REXC_FLAG, 0, 0, 0, 0, tran_cClrk())
#endif
        // this normal return exchange ... 
        tran_nSale( nAmount )        

        // Add this record to the nvcntrl trans file...
        Update_Trans()

        retexch_counter(tran_cPLU(),tran_cItem(),tran_cDesc(),tran_cDept(), tran_nQty(), tran_nPric(), tran_nSale())                    

        if tran_cPFlg() == OP_NPLU_FLAG
           plu_counter(cPLUCode, -nQty, -nAmount, 0)
           dept_counter(cDept, -nQty, -nAmount, 0)                  
        elseif tran_cPFlg() == OP_NOTF_FLAG
           dept_counter(cDept, -nQty, -nAmount, 0)                  
           lNFND_Add(cPLUCode,cDesc,cDept,-nQty,nAmount, 0)
        endif            
      
        // prepare to print values 
        rpt_prnt(0, 1, 0, cPLUCode, 0)            
      
        out_text :=pad("*RETURN",LMARGIN)+trans(nQty,"999 @  ")
        out_text += trans(nPrice,"999,999.99")
        // now print the values
        rpt_prnt(1, 1, 0, out_text, 0)            
                     
        out_text := cDesc
        out_text += "  " +  trans(-nAmount,"999,999.99")
         
        // now print the values
        rpt_prnt(1, 1, 0, out_text, 0)

#ifdef SLIP_PRNT
        if nAMTAmount >= 0

          slip_prompt(MSG_D028) 
          
          // set font to 15.6 cpi normal...
          //
          // A_PRT_ESC(NORMAL_15)
          out_text := "*** RET/EXCH " + transform(nAMTAmount, "***,**9.99") + " " + ;
                       dtoc(date()) + " " + substr(time(), 1, 5) + " ***" + chr(10)

          // print to optional slip printer...            
          slip_check(out_text,0)
        endif  
#endif      
                          
        nvr_nQtyitems(nQTYtotal)
        nvr_nSUBtotal(nAMTamount) 

        // less the dept returns to the dept totals        
        // Term_nData(TR_DEPT_TOT, nAmount)      
        Term_nData(TR_REXC_KNT, 1)
        Term_nData(TR_REXC_TOT, nAmount)
        
        lRetVal := .t.
                                
      endif
         
   else
      ErrorDisp(MSG_D013)  
      tran_init()
      BUMMER()
   endif  
 
return lRetVal             
   

static function exchanged_dept(nDeptno,nQty,cDataBuff)
local cDeptCode
local nPrice,cDesc
local nAmount,nTot_Amount,nQty_total
local out_text,lRetVal := .F.
local status,cDept
local nTotals,nCounter

  if nDeptNo > 0 .and. nDeptNo <= MAXIMUM_DEPT
     cDeptCode := getdept(nDeptNo) 
  endif

  if Dept_Get(cDeptCode)
     ? "Department " + cDeptCode +" Found !!!"
     nPrice := val(cDataBuff)
     if config(POS_LALO) == "YES" .and. nPrice < nDept_Lalo()
         ErrorDisp(MSG_D016)    // LALO violation
     elseif config(POS_HALO) == "YES" .and. nPrice > nDept_Halo() 
         ErrorDisp(MSG_D017)    // HALO violation
     else            
         cDesc := cDept_Desc() 
         nAmount := nQty * nPrice
         cDept := tran_cDept()

         tran_cPLU  ( repl("0",PLU_CODE_LEN) )
         tran_cITEM ( repl("0",PLU_ITEM_LEN) )
         tran_cDept ( cDeptCode )
         tran_cFlag ( OP_REXC_FLAG )
         tran_cPFlg ( OP_OPEN_FLAG )
         tran_cRegM ( "0" ) // Open department is not scanned default "0"
         tran_cPrcM ( "0" ) // No special pricing done...
         tran_cConc ( cDept_Conc() )
         tran_cColo ( "CL" ) // Department no info about colors
         tran_cSize ( "SZ" ) // your guess is as good as mine
         // Sale to be resolved later...
         tran_nCntr ( nQty )
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
        tran_cDesc ( cDept_Desc() ) // use dept desc.
        tran_nPric ( nPrice )
        tran_nQty  ( nQty )       
             
        nTOT_Amount := nvr_nSUBtotal() - nAmount
        nQty_total  := nvr_nQTYitems() - nQty

        if nAmount > AMT_LALO .and. nAmount < AMT_HALO .and.;
           nQty_total < TOTQTY_HALO .and. nTOT_Amount < TOTAMT_HALO      

           if nAmount > nvr_nSUBtotal()      

              BEEP_4() 
              out_text := "EXCHG. AMT:"+ trans(nvr_nSUBtotal(),"99,999.99")
              DISPTEXTXY(1, 1, 0, 0, 1, 1, out_text )
              out_text := "RETURN AMT:"+ trans(-nAmount,"99,999.99")
              DISPTEXTXY(2, 1, 0, 0, 2, 1, out_text )        
              out_text := "EXCESS AMT:"+ trans(nTOT_Amount,"99,999.99")
              DISPTEXTXY(3, 1, 0, 0, 0, 0, out_text )
         
              MsgAreaDisp("<OTH_INC> TO CONFIRM")

              if input() == OTH_INC
              
                // display the parameters              
                disp_ret(OP_REXC_FLAG,cDeptCode,cDesc,nQty,nPrice,nAmount)

                // less the dept returns to the dept totals        
                // Term_nData(TR_DEPT_TOT, -nAmount)                               
                // Term_nData(TR_REXC_TOT, nAmount + nTOT_Amount )   
                Term_nData(TR_REXC_KNT, 1)
                Term_nData(TR_REXC_TOT, nAmount )   
                
                // this is other income situation make neccessary adjustments...
                tran_nSale(nvr_nSUBtotal() ) 
                
                // Add this record to the nvcntrl trans file...            
                Update_Trans()             
                          
                // For the Journal            
                rpt_prnt(0, 1, 0, cDesc, 0)    
                out_text := pad("*RETURN",16)+tran(nQty,"9999@") + trans(nPrice ," 999,999.99")
                rpt_prnt(0, 1, 0, out_text , 0)
                rpt_prnt(0, 1, 0, space(20)+trans(-nAmount, "9,999,999.99") , 0)
             
                out_text := pad("*RETURN",11)+trans(nQty,"9999 @   ")+ trans(nPrice,"99,999.99")             
                rpt_prnt(1, 0, 0, out_text , 0)                                        
           
                out_text := cDesc + trans(-nAmount, "9,999,999.99")
                rpt_prnt(1, 1, 0, out_text , 0)

#ifdef SLIP_PRNT
                slip_prompt(MSG_D028) 
             
                // set font to 15.6 cpi normal...
                //
                // A_PRT_ESC(NORMAL_15)
                out_text := "*** RET/EXCH " + transform(nTOT_Amount, "***,**9.99") + " " + ;
                             dtoc(date()) + " " + substr(time(), 1, 5) + " ***" + chr(10)

                // print to optional slip printer...            
                slip_check(out_text,0)                
#endif            
                // then make a new record for the add-on record
                tran_cPLU(  repl("?",TRAN_PLU_LEN   ) )  // 
                tran_cItem( repl("?",TRAN_ITEM_LEN  ) )
                tran_cDept( repl("?",TRAN_DEPT_LEN  ) )
                tran_cFlag( OP_OINC_FLAG ) // Flag Set As Add-on by ret-exch.
                tran_cPFlg( OP_REXC_FLAG )
                tran_cRegM( "0" ) // Temporarily set as keyboard method of entry
                tran_cPrcM( "0" ) // Temporarily set as normal pricing method
                tran_cConc( repl("?",TRAN_CONC_LEN) ) // Concessionaire
                tran_cColo( repl("?",TRAN_COLO_LEN) )  
                tran_cSize( repl("?",TRAN_SIZE_LEN) ) 
                tran_nSale( -nTOT_Amount  ) 
                tran_nCntr( 1 ) 
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
                tran_cDesc(  )
                tran_nPric( -nTOT_Amount )
                tran_nQty ( 1 )

#ifdef DEF_GRAPHICS
      Rcpt_Scroll(1, cDesc, nQty, nPrice, OP_REXC_FLAG, 0, 0, 0, 0, tran_cClrk())
#endif
                Update_trans()

                dept_counter(cDept, -nQty, -nAmount)

                // POS receipt and journal printer...
                // skip one line...
                A_RJS_FEED(1, 1, 0, 1)                      

                out_text := pad("*OTHINC(RET/EXCH)",22) + trans(-nTOT_Amount, "999,999.99") + chr(10) 
                rpt_prnt(1, 0, 0, out_text, 0)                       

                // on journal...
                out_text := pad("*OTHINC(RET/EXCH)",22) + trans(-nTOT_Amount, "999,999.99") + chr(10) 
                rpt_prnt(0, 1, 0, out_text, 0)                                                      
            
#ifdef SLIP_PRNT
                out_text := "*** OTHINC   " + transform(-nTOT_Amount, "***,**9.99") + " " + ;
                             dtoc(date()) + " " + substr(time(), 1, 5) + " ***" + chr(10)

                // print to optional slip printer...            
                slip_check(out_text,0)            
#endif

                Term_nData(TR_OINC_TOT, -nTOT_Amount )
                Term_nData(TR_OINC_KNT, 1 )

                // add the dept sale to the dept totals
                //Term_nData(TR_DEPT_TOT, -nTOT_Amount ) 
                //Term_nData(TR_DSLS_TOT, -nAmount ) 

                nvr_nQtyitems(nQTY_total)
                nvr_nSUBtotal(0)             

                lRetVal := .t.                          
              else    
                MsgAreaDisp("EXCHANGED CANCELLED!")
                tran_init()                
                BUMMER()
              endif           
              
          else                              
              // display the parameters              
              disp_ret(OP_REXC_FLAG,cDeptCode,cDesc,nQty,nPrice,nAmount)

            #ifdef DEF_GRAPHICS
               Rcpt_Scroll(1, cDesc, nQty, nPrice, OP_REXC_FLAG, 0, 0, 0, 0, tran_cClrk())
            #endif
              // this normal return exchange ... 
              tran_nSale( nAmount )        
              // Add this record to the nvcntrl trans file...            
              Update_Trans()             
                          
              // For the Journal            
              rpt_prnt(0, 1, 0, cDesc, 0)    
              out_text := pad("*RETURN",16)+tran(nQty,"9999@") + trans(nPrice ," 999,999.99")
              rpt_prnt(0, 1, 0, out_text , 0)
              rpt_prnt(0, 1, 0, space(20)+trans(-nAmount, "9,999,999.99") , 0)
           
              out_text := pad("*RETURN",11)+trans(nQty,"9999 @   ")+ trans(nPrice,"99,999.99")             
              rpt_prnt(1, 0, 0, out_text , 0)                                        
           
              out_text := cDesc + trans(-nAmount, "9,999,999.99")
              rpt_prnt(1, 1, 0, out_text , 0)

#ifdef SLIP_PRNT
              if nTOT_Amount >= 0

                 slip_prompt(MSG_D028) 
            
                 out_text := "*** RET/EXCH " + transform(nTOT_Amount, "***,**9.99") + " " + ;
                              dtoc(date()) + " " + substr(time(), 1, 5) + " ***" + chr(10)

                 // print to optional slip printer...            
                 slip_check(out_text,0)
              endif   
#endif              
             
              // add the dept sale to the dept totals              
              // Term_nData(TR_DEPT_TOT, nAmount)      
              Term_nData(TR_REXC_KNT, 1)
              Term_nData(TR_REXC_TOT, nAmount)                 
            
              nvr_nSUBtotal(nTOT_Amount) 
              nvr_nQTYitems(nQty_total)             

              dept_counter(cDept, -nQty, -nAmount)

              lRetVal := .T.
             
           endif     
           
       else
           ErrorDisp(MSG_D013)  
           tran_init()
           BUMMER()
       endif      
    endif    
  else
     ? "Department " + cDeptCode +" Not Found !!!"
     lRetVal := .F.
  endif
  
return lRetVal 

function Disp_ret(cFlag,cCode,cDesc, nQty, nPrice, nAmount)
local cBuffer

#ifdef DEF_DISP1X09
    cBuffer := tran(nAmount,"9999999.99")
    DISPTEXTXY( 0, 0, 1, 1, 0, 0, cBuffer )
#endif          

   cBuffer := "RETURN" + tran(nQty,"999") + "@ " + tran(nPrice,"99,999.99")  
   
   DISPTEXTXY(0, 0, 0, 0, 1, 1, padl(cBuffer,20))      
   DISPTEXTXY(0, 0, 0, 0, 2, 1, subs(cDesc,1,10)+ tran(nAmount,"99,999.99" )) 
   
#ifdef DEF_DISP4X20
   DISPTEXTXY(1, 1, 0, 0, 0, 0, padl(cCode,20))
   DISPTEXTXY(2, 1, 0, 0, 0, 0, pad(cDesc,20))     
   DISPTEXTXY(3, 1, 0, 0, 1, 1, cBuffer)    
   DISPTEXTXY(4, 1, 0, 0, 0, 0, padl(tran(nAmount," 999,999.99"),20))   
#endif   
                                 
return nil  

function Disp_OINK( nAmount )
local out_text
  DISPTEXTXY(1, 1, 0, 0, 2, 1, MSG_CLEAR)
  out_text := "*OTHER INC." + trans(nAmount,"99,999.99")
  DISPTEXTXY(2, 1, 0, 0, 1, 1, out_text)
  DISPTEXTXY(3, 1, 0, 0, 0, 0, MSG_CLEAR)
  DISPTEXTXY(4, 1, 0, 0, 0, 0, MSG_CLEAR)
return nil  

function reprint_ret(cFlag,cPLUCode,cDesc,nQty,nPrice,nAmount)
local out_text

     out_text := pad("*RETURN",11)+trans(nQty,"9999 @   ")+ trans(nPrice,"99,999.99")             
     rpt_prnt(1, 0, 0, out_text , 0)                                        
           
     out_text := cDesc + trans(-nAmount, "9,999,999.99")
     rpt_prnt(1, 0, 0, out_text , 0)
     
return nil

function reprint_OINK( nAmount )
local out_text

    // POS receipt and journal printer...
    // skip one line...
    A_RJS_FEED(1, 0, 0, 1)                      

    out_text := pad("*OTHINC(RET/EXCH)",22) + trans(-nAmount, "999,999.99") + chr(10) 
    rpt_prnt(1, 0, 0, out_text, 0)                       

return nil


function retexch_counter(plu_code, item_code, desc, dept_code, nQty, nAmount, nTotPrice)
local cHeader
local cOutData,cInData 
local status := NORMAL
local rQty := 0
local rAmount := 0
local rUnitCost := 0

if !nvr_lTRNG_Mode() 

   cOutData := plu_code
   cHeader := formHeader(FC_SRCHGET,FP_ZERO,FA_FN_RTN)           
   cIndata := space(RET_REC_SIZE)

   status := f_access(@cHeader,cOutData,@cIndata,GetLocal_Path())
   
   if status == 0 .or. status == 23 .and. subs(cIndata,RET_PLUCODE_OFF,RET_PLUCODE_LEN) == plu_code      
     rQty      := realiee(subs(cIndata,RET_ITOTQTY_OFF,RET_ITOTQTY_LEN))
     rAmount   := realiee(subs(cIndata,RET_ITOTAMT_OFF,RET_ITOTAMT_LEN))
     rUnitCost := realiee(subs(cIndata,RET_IUCOSTS_OFF,RET_IUCOSTS_LEN))
     nQty      += rQty 
     nAmount   := rAmount + nTotPrice
     nTotPrice += rUnitCost
   elseif status != 4
      MsgAreaDisp(" Unable to retrieve Return.IDX counter : "+str(status))
      error_log("Unable to retrieve Return.IDX counter : "+str(status))       
   endif   

   cOutData := padl(plu_code,RET_PLUCODE_LEN,"0")
   cOutData += padl(item_code,RET_ITMCODE_LEN,"0")
   cOutData += padr(desc, RET_PLUDESC_LEN)
   cOutData += padl(dept_code, RET_DEPCODE_LEN, "0")
   cOutData += ieereal(nQty)
   cOutData += ieereal(nAmount)
   cOutData += ieereal(nTotPrice)   
   
   cIndata := ""
   cHeader := formHeader(FC_SRCHPUT,FP_ZERO,FA_FN_RTN)     

   status := f_access(@cHeader,cOutData,@cIndata,GetLocal_Path())
   
   if status != NORMAL .and. status != 23
        MsgAreaDisp(" Unable to update Return.IDX counter : "+str(status))
        error_log("Unable to update Return.IDX counter : "+str(status))
   endif            
   
endif

return status
   

