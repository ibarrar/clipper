#include "plu_file.ch"
#include "deptfile.ch"
#include "powerpos.ch"
#include "file_acc.ch"
#include "itemtran.ch"
#include "config.ch"

#define LMARGIN         11

function reprint_bill( cTransNo )
local i 
local out_text

    if ( nvr_nITMitem() > 0  )
       out_text :=  space(10)+"SUBTOTAL"+ space(1) + trans(nvr_nSUBTotal(), "99,999,999.99")

       A_RJS_FEED(1, 0, 0, 1)
       rpt_prnt(1, 0, 0, out_text , 0)         
       rpt_prnt(1, 0, 0, "   ***** VOID RECEIPT *****", 1)    

       prnt_end()    
    
       // Now get all transaction records and put them in display array
       for i := 1 to nvr_nITMitem()
            Disp_tran( i )                                                
            print_bill( i )
       next i      

       A_RJS_FEED(1, 0, 0, 1)
       out_text :=  space(10)+"SUBTOTAL"+ space(1) + trans(nvr_nSUBTotal(), "99,999,999.99")
       rpt_prnt(1, 0, 0, out_text , 0)                 
    else
       if !empty(cTransNo) .and. val(cTransNo) > 0 .and.val(cTransNo) < nvr_nTrans()
         reissue_bill(val(cTransNo))
       else
         reissue_bill(nvr_nTrans()-1)
       endif  
    endif
          

return nil

function reissue_bill(nTransNo)
local cFlag,cBuffer,cPflg,cClerk
local nQty,nAmt
local nPayType
local outtext
local nQTYtotal := 0
local nAMTtotal := 0
local cPLUCode,cDept,nPrice,cDesc := ""

    if parsetran(nTransNo)
       while !empty( cBuffer := getnext(nTransNo))
          cFlag := subs( cBuffer,ITEM_FLAG_OFF ,ITEM_FLAG_LEN )
          cPflg := subs( cBuffer,ITEM_PFLG_OFF ,ITEM_PFLG_LEN )
          if cFlag != "?" .and. cFlag != "!"          
             if cFlag $ "Z1234567890"
                nQty := val(subs(cBuffer,CUST_CNTR_OFF,CUST_CNTR_LEN)) //* 0.01
                nAmt := val(subs(cBuffer,CUST_SALE_OFF,CUST_SALE_LEN)) * 0.01
                nPayType := val(subs(cBuffer,CUST_PAYM_OFF,CUST_PAYM_LEN))

                if nPayType == 0
                   outtext := pad("CASH PAYMENT",21)
                else
                   outtext := pad(GetMDesc(nPayType)+" PAYMENT",21)
                endif                    

                A_RJS_FEED( 1, 0, 0, 1 )
                outtext += trans(nAmt, "9999,999.99")
                rpt_prnt( 1, 0, 0, outtext , 1 )
                
                nAMTtotal -= nAmt
             else
                cClerk := subs( cBuffer,ITEM_CLRK_OFF,ITEM_CLRK_LEN )
                nQty := val(subs(cBuffer,ITEM_CNTR_OFF,ITEM_CNTR_LEN)) 
                nAmt := val(subs(cBuffer,ITEM_SALE_OFF,ITEM_SALE_LEN)) * 0.01

                cPLUCode := subs(cBUffer,ITEM_PLUC_OFF,ITEM_PLUC_LEN)
                cDept := subs(cBuffer,ITEM_DEPT_OFF,ITEM_DEPT_LEN)
#ifdef NON_ADD_ENABLED
                if config(POS_VLD_CLRK) == "YES" .and. cClerk != "000000"
                   get_Clerk(cClerk)
                   outtext := if(empty(cClerk_Desc()),"CLERK# "+cClerk,cClerk_Desc())
                   rpt_prnt(1, 0, 0, outtext , 0)  
                endif                  
#endif                
                do case
                   case cFlag == OP_NPLU_FLAG  

                        get_plu(cPLUCode,@nPrice,@cDesc,cDept,nAmt,nQty )
                        nPrice := (nAmt/max(nQty,1))
                        if nQty > 1
                           outtext :=space(LMARGIN)+trans(nQty,"999 @  ")
                      	   outtext += trans(nPrice,"999,999.99")
                           // now print the values
                           rpt_prnt(1, 0, 0, outtext, 0)
                        endif
                        outtext := cDesc
                        outtext += "  " +  trans(nAmt,"999,999.99")        
                        // now print the values
                        rpt_prnt(1, 0, 0, outtext, 0)
                        nQTYtotal += nQty                                                   
                        nAMTtotal += nAmt                           
                   case cFlag == OP_OINC_FLAG
                        A_RJS_FEED(1, 0, 0, 1)                      
                        outtext := pad("*OTHINC(RET/EXCH)",22) + trans(nAmt, "999,999.99") + chr(10) 
                        rpt_prnt(1, 0, 0, outtext, 0)                  
                        nAMTtotal += nAmt                                                                                                         
                   case cFlag == OP_VOID_FLAG
                        /* do nothing this is a voided item */
                   case cFlag == OP_MGRV_FLAG
                        /* do nothing this is a voided item */
                   case cFlag == OP_IDSC_FLAG 
                        if cPflg == "0"
                          outtext := trans(nQty,"999%")+pad("ITEM DISC",17) + trans(-nAmt, "9999,999.99")
                          rpt_prnt(1, 0, 0, outtext, 0)            
                        endif  
                        nAMTtotal -= nAmt
                   case cFlag == OP_SDSC_FLAG
                        outtext := "SUBTOTAL:          "+ trans(nAMTtotal, "99,999,999.99")      
                        A_RJS_FEED(1, 0, 0, 1)
                        rpt_prnt(1, 0, 0, outtext , 0)   
                        outtext := trans(nQty,"999 %")+"STTL. DISCOUNT " + trans(-nAmt, "9999,999.99") 
                        rpt_prnt(1, 0, 0, outtext, 0)  
                        nAMTtotal -= nAmt                        
                   case cFlag == OP_TRCL_FLAG
                        /* do nothing */
                   case cFlag == OP_ITCL_FLAG
                        /* do nothing */
                   case cFlag == OP_OPEN_FLAG
                        get_dept(cDept,nAmt,nQty,@cDesc)
                        nPrice := (nAmt/max(nQty,1))
                        if nQty != 1
                           outtext := space(LMARGIN)+trans(nQty,"9999 @   ")+ trans(nPrice,"99,999.99")
                           rpt_prnt(1, 0, 0, outtext , 0)
                        endif                       
                        outtext := cDesc + trans(nAmt, "9,999,999.99")
                        rpt_prnt(1, 0, 0, outtext , 0)                
                        nQTYtotal += nQty                                                           
                        nAMTtotal += nAmt                        
                   case cFlag == OP_REXC_FLAG
                        get_plu(cPLUCode,@nPrice,@cDesc,cDept,nAmt,nQty)
                        nPrice := (nAmt/max(nQty,1))
                        A_RJS_FEED(1, 0, 0, 1)                      
                        outtext := pad("*OTHINC(RET/EXCH)",22) + trans(-nAmt, "999,999.99")
                        rpt_prnt(1, 0, 0, outtext, 0)          
                        nQTYtotal -= nQty                                                                                        
                        nAMTtotal -= nAmt                                                
                   case cFlag == OP_NOTF_FLAG
                        nPrice := (nAmt/max(nQty,1))
                        if nQty != 1
                           outtext := space(LMARGIN)+trans(nQty,"9999 @   ")+ trans(nPrice,"99,999.99")
                           rpt_prnt(1, 0, 0, outtext , 0)
                        endif           
                        cDesc := "P"+cPLUCode+"D"+cDept                                     
                        outtext := cDesc + trans(nAmt, "9,999,999.99")
                        rpt_prnt(1, 0, 0, outtext , 0)                        
                        nQTYtotal += nQty                                                   
                        nAMTtotal += nAmt                                                                        
                   case cFlag == OP_ADON_FLAG
                        outtext := pad("SUBTOTAL",21) + tran(nAMTtotal ,"9999,999.99")                        
                        rpt_prnt(1, 0, 0, outtext, 0)                  
                        outtext := pad(tran(nQty,"@Z 999.99% ADD-ON"),21) + trans(nAmt, "9999,999.99")
                        rpt_prnt(1, 0, 0, outtext, 0)                                                            
#ifdef POS_VAT                        
                   case cFlag == OP_VATX_FLAG
                        outtext := pad("10% VALUE ADDED TAX",21) + trans(nAmt, "9999,999.99") + chr(10) 
                        rpt_prnt(1, 0, 0, outtext, 0)                                                            
#endif                        
                   case cFlag == OP_RFND_FLAG            
                        /* do nothing muna */ 
                endcase  
                    
             endif   
          endif                                
       enddo
       
       A_RJS_FEED( 1, 1, 0, 1 )       
       rpt_prnt( 1, 1, 0, "******** REPRINT BILL ********", 0)
       A_RJS_FEED( 1, 1, 0, 1 )       

       prnt_end( nQTYtotal )         

    endif

return nil    

function get_plu(cCode,nPrice,cDesc,cDept,nAmount,nQty)

   if PLU_Get(cCode)
      nPrice := nPLU_Pric()
      cDesc  := cPLU_Desc()
      cDept  := cPLU_Dept()
   else
      get_dept(cDept,nAmount,nQty,@cDesc)
   endif   

return nil      
         
function get_dept(cDept,nAmount,nQty,cDesc)

   if Dept_Get(cDept)
     cDesc := cDept_Desc()
   endif
   
return nil

