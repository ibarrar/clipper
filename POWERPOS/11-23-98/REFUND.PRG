#include "powerpos.ch"
#include "terminal.ch"
#include "config.ch"
#include "message.ch"
#include "nvr_file.ch"

function itm_refund()
local nVatAmt := 0
local k,cFlag
local cRetBuff
local nAmount
local nCounter
local nPayAmt
local nPayType
local outtext
local cPLUCode,cDept,cPflg
local nPrice := 0
local cDesc := space(20)
local nDisc := 0
local pAmt  := 0
local pQty  := 0
local rIamt := 0
local rIqty := 0

  MsgAreaDisp("*** Item Refund Transaction ***")
  A_RJS_FEED(1, 1, 0, 1)

#ifdef POS_VAT  
  if config(POS_VAT_APLICABLE) == "YES"
     A_RJS_PRNT(1, 1, 0, padl("TOTAL ",21)+trans(nvr_nSUBtotal(),"9999,999.99"), 0)
     nVatAmt := nvr_nSUBtotal() * VAT_RATE
     A_RJS_PRNT(1, 1, 0, pad("10% VALUE ADDED TAX",21)+trans(nVatAmt,"9999,999.99"), 0)     
  endif     
#endif

*  A_RJS_PRNT(1, 1, 0, pad("SUBTOTAL ",21)+trans(nvr_nSUBtotal()+nVatAmt,"9999,999.99"), 0)
  A_RJS_PRNT(1, 1, 0, pad("SUBTOTAL ",21)+trans(nvr_nSUBtotal(),"9999,999.99"), 0)
  A_RJS_FEED(1, 1, 0, 1)
  A_RJS_PRNT(1, 1, 0, "****   TRANSACTION REFUND  ****", 0)
  A_RJS_FEED( 1, 1, 0, 1 )
  
  disp_itmrefund()

  for k := 1 to nvr_nITMitem()
     
     tran_init(k)
     cFlag := tran_cFlag()
     cPflg := tran_cPflg()
     nAmount  := tran_nSale() * 2
     nCounter := tran_nCntr() * 2
     cPLUCode := tran_cPLU()
     cDept    := tran_cDept()
     pAmt     := tran_nSale()
     pQty     := tran_nCntr()
     rIamt    := tran_nSale()
     rIqty    := tran_nCntr()
     nPrice   := tran_nPric()  // jlp
     do case 
        case cFlag $ POSITIVE_OPER_FLAG 
             // Deduct the department total with the ff amounts              
             
             if cFlag == OP_OINC_FLAG
                 Term_nData(TR_OINC_TOT, - nAmount )
                 Term_nData(TR_OINC_KNT, - 1 )
                 Term_nData(TR_DSLS_TOT, - nAmount )                 
             elseif cFlag == OP_ADON_FLAG
                 Term_nData(TR_ADON_TOT, - nAmount )
                 Term_nData(TR_ADON_KNT, - 1 )
             else
                 Term_nData(TR_DEPT_TOT, - rIamt)
                 dept_counter(cDept, -pQty, -pAmt, 0)                 
                 if cFlag == OP_NPLU_FLAG
                   plu_counter(cPLUCode, - nCounter, - nAmount, 0)
                 elseif cFlag == OP_NOTF_FLAG
                  // lNFND_Add(cPLUCode,tran_cDesc(),cDept,-nCounter,nAmount,0 )
                   lNFND_Add(cPLUCode,tran_cDesc(),cDept,-nCounter,nPrice,0 )
                 endif                 
             endif
        case cFlag $ NEGATIVE_OPER_FLAG

             // Deduct the department total with the ff amounts 
*            Term_nData(TR_DEPT_TOT, nAmount)

             if cFlag == OP_IDSC_FLAG
// RCI 10/11/98		   
			  Term_nData(TR_IDSC_TOT, - pAmt) //   <------ changed
			  Term_nData(TR_IDSC_KNT, - 1 ) //   <------ changed
             elseif cFlag == OP_SDSC_FLAG
                 Term_nData(TR_SDSC_TOT, - nAmount)
                 Term_nData(TR_SDSC_KNT, - 1 )
             elseif cFlag == OP_REXC_FLAG
                 Term_nData(TR_REXC_TOT, - nAmount )
                 Term_nData(TR_REXC_KNT, - 1 )
                 Term_nData(TR_DEPT_TOT, nAmount)
                 dept_counter(cDept,pQty,pAmt,0)                  
                 if cPflg == OP_NOTF_FLAG
                   lNFND_Add(cPLUCode,tran_cDesc(),cDept,nCounter,nAmount,0 )
                 elseif cPFlg == OP_NPLU_FLAG
                   plu_counter(cPLUCode, nCounter, nAmount, 0)    
                 endif
             endif    
                                                                         
        case cFlag $ DONOTHING_OPER_FLAG
             if cFlag $ "123456789" // partial payments...
                // undo the payment done...

                nPayType := val(tran_cPrcM())                
                nPayAmt := -tran_nSale()
                Term_nData(TR_DSLS_TOT,nPayAmt)      // First the Totals
                Term_nData(TR_TRCL_TOT,-nPayAmt)                

                if nPayType == 0
                  Term_nData(TR_CASH_TOT,nPayAmt)
                  outtext := pad("CASH PAYMENT",21)
                else
                  Term_nData(7+((nPayType-1)*2),nPayAmt)        
                  Term_nData(8+((nPayType-1)*2),-1)     // Then the Quantities                
                  outtext := pad(GetMDesc(nPayType)+" PAYMENT",21)
                endif    
                        
                outtext += trans(nPayAmt, "9999,999.99")
                A_RJS_PRNT( 1, 1, 0, outtext , 1 )
                                                               
             endif
             // Just do nothing...              
        otherwise 
           // warn me that there are unknown flags roaming around...
           error_log ("Unrecognized flag at trans refund : "+cFlag)   
     endcase    

     // then edit the transaction for cancel flag
        
     if cFlag $ "123456789" 
        tran_cFlag(OP_TRCL_FLAG)
     elseif cFlag == "V"
        tran_cFlag(OP_VOID_FLAG)
     elseif cFlag == "G"
        tran_cFlag(OP_MGRV_FLAG)   
     else
        tran_cFlag(OP_RFND_FLAG)
        tran_cPflg(cFlag)
     endif  
     edit_trans(k)               
  next k  

/*
#ifdef POS_VAT
  if config(POS_VAT_APLICABLE) == "YES"
     tran_cFlag( OP_VATX_FLAG ) // Found the plu set as normal
     tran_cRegM( RegMode() ) 
     tran_cPflg(  "0" )
     tran_cPrcM(  "0" ) // Temporarily set as normal pricing method
     tran_nSale( nVatAmt ) 
     tran_nCntr( VAT_RATE ) 
     tran_cClrk( "" )
     tran_cCrgo( "" )
     tran_cDesc( "" )
     tran_nPric( nVatAmt )
     tran_nQty ( VAT_RATE )
     
     Update_Trans()  
  endif  
#endif */

  tran_cFlag(OP_RFND_FLAG)                        // flag
  tran_cPFlg( "0" )
  tran_cPrcM(padl("0",TRAN_PRCM_LEN,"0"))
  tran_nSale(nvr_nSUBtotal()+nVatAmt)                       // Sale    
  tran_nCntr(0)                       // Balance
    
  tran_cCrg1(repl("0",TRAN_CRG1_LEN))                    // ist cargo
  tran_cCrg2(repl("0",TRAN_CRG1_LEN))                    // 2nd cargo
  tran_cCrg3(repl("0",TRAN_CRG1_LEN))                    // 3rd cargo    
  tran_cCrg4(padl(nvr_nQTYitems()+nVatAmt,TRAN_CRG4_LEN),"0")   // 4th cargo  
  
  Update_trans()
  
#ifdef SLIP_PRNT
  // delete all transactions in invoice validation proc..
  del_invoice()
#endif  

  // increment the Terminal cancel counter 
  Term_nData(TR_DSLS_TOT, -(nvr_nSUBtotal()))            // First the Totals  
  Term_nData(TR_CASH_TOT, -(nvr_nSUBtotal()))        
  Term_nData(TR_RFND_TOT, nvr_nSUBTotal())
  Term_nData(TR_RFND_KNT, 1 )  
  // no need as per che&doris
  
  A_RJS_FEED( 1, 1, 0, 1 )
  A_RJS_PRNT(1, 1, 0, pad("SUBTOTAL ",21)+trans(nvr_nSUBtotal(0),"9999,999.99"), 0)

  prnt_end(nvr_nQTYItems())  

    // reset the subtotal and counter 
  nvr_nSUBtotal(0)
  nvr_nQTYitems(0)  

  DispSubTotal()         
  
return nil

function disp_itmrefund()   
   DISPTEXTXY(1,1,1,1,1,1,MSG_CLEAR)   
   DISPTEXTXY(2,1,0,0,1,1,"*TRANSACTION REFUND*")   
   DISPTEXTXY(3,1,0,0,0,0,MSG_CLEAR)   
   DISPTEXTXY(4,1,0,0,0,0,MSG_CLEAR)   
return nil

function disp_refund(cPflag,cCode,cDesc,cDept,cClerk,nQty, nPrice, nAmount)

  do case 
     case cPflag == "0"
          d_gen_refund(nAmount)
     case cPflag == OP_NPLU_FLAG
          d_ref_plu( cCode,cDesc,cDept,cClerk,nQty,nPrice,nAmount)
     case cPflag == OP_NOTF_FLAG
          d_ref_plu( cCode,cDesc,cDept,cClerk,nQty,nPrice,nAmount)          
     case cPflag == OP_OPEN_FLAG
          d_ref_dept(cDept,cDesc,cClerk,nQty,nPrice,nAmount) 
     case cPflag == OP_IDSC_FLAG
          d_ref_disc(nQty,nAmount, cCode)             
     case cPflag == OP_ADON_FLAG
          d_ref_addon( nQty, nAmount )    
     case cPflag == OP_SDSC_FLAG
          d_ref_Sdisc( nQty, nAmount )     
  endcase
    
return nil      

function d_gen_refund(nAmount)
local out_text

  disp_clr()  
  out_text := "REFUND   " + trans(-nAmount,"9999,999.99")
  DISPTEXTXY(1, 1, 0, 0, 1, 1, out_text)
  DISPTEXTXY(2, 1, 0, 0, 2, 1, "** GENERAL REFUND **")

return nil  

function d_ref_dept(cCode,cDesc,cClerk,nQty,nPrice,nAmount)
local out_text

   out_text := pad(("DEPARTMENT "+cCode),20)  
   DISPTEXTXY(1, 1, 0, 0, 0, 0, out_text)
   cDesc := subs(cDesc,1,13) + "*REFUND"
   DISPTEXTXY(2, 1, 0, 0, 0, 0, cDesc )
                
   if nQty != 1
     out_text := trans(nQty,"9999@ ")+ trans(nPrice,"999,999,999.99")
     DISPTEXTXY(3, 1, 0, 0, 0, 0, out_text )
     DISPTEXTXY(0, 0, 0, 0, 1, 1, out_text )
     out_text := subs(cDesc,1,10) + trans(-nAmount,"999,999.99")
     DISPTEXTXY(0, 0, 0, 0, 2, 1, out_text )
   else
     out_text := "      "+ trans(-nAmount,"999,999,999.99")           
     DISPTEXTXY(3, 1, 0, 0, 2, 1, out_text )             
     DISPTEXTXY(0, 0, 0, 0, 1, 1, cDesc )                       
   endif  
   
   if val(cClerk) > 0
      out_text := "CK:"+subs(cClerk,1,6)+ trans(-nAmount ,"9999,999.99")
   else
      out_text := "         " + trans(-nAmount ,"9999,999.99")            
   endif
   
   DISPTEXTXY(4, 1, 0, 0, 0, 0, out_text )
           
#ifdef DEF_DISP1X09
   out_text :=  trans(-nAmount ,"9999999.99")
   DISPTEXTXY(0, 0, 1, 1, 0, 0, out_text ) 
#endif           

return nil

function d_ref_plu(cCode,cDesc,cDept,cClerk,nQty, nPrice, nAmount)
local cBuffer

#ifdef DEF_DISP1X09
    cBuffer := tran(nAmount,"9999999.99")
    DISPTEXTXY( 0, 0, 1, 1, 0, 0, cBuffer )
#endif          
   if nQty != 1      
       cBuffer := tran(nQty,"999") + "@ " + tran(nPrice,"999,999.99")       
       DISPTEXTXY(0, 0, 0, 0, 2, 1, subs(cDesc,1,10)+ tran(-nAmount,"999,999.99" ))   
   else
       cBuffer := tran(nAmount,"999,999.99")
       DISPTEXTXY(0, 0, 0, 0, 2, 1, cDesc )   
   endif
   DISPTEXTXY(0, 0, 0, 0, 1, 1, padl(cBuffer,20) )

#ifdef DEF_DISP4X20
   DISPTEXTXY(1, 1, 0, 0, 0, 0, pad((cCode+" D"+cDept),20)   )
   cDesc :=  subs(cDesc,1,13) + "*REFUND"
   DISPTEXTXY(2, 1, 0, 0, 0, 0, pad(cDesc,20)   )    
   DISPTEXTXY(3, 1, 0, 0, 1, 1, padl(cBuffer,20))    
   if val(cClerk) > 0
     cBuffer :=  "CK:"+subs(cClerk,1,6)+tran(-nAmount,"9999,999.99")
   else
     cBuffer :=  "         "+tran(-nAmount,"9999,999.99")
   endif     
     
   DISPTEXTXY(4, 1, 0, 0, 0, 0, cBuffer )        
#endif   
                                 
return nil  

function d_ref_disc(nRate, nAmount, cCode)
local out_text

  disp_clr()
  DISPTEXTXY(1, 1, 0, 0, 1, 1, cCode )
  out_text := trans( nRate , "999%") + " DISC." + trans(nAmount,"999,999.99")
  DISPTEXTXY(2, 1, 0, 0, 2, 1, out_text)
  DISPTEXTXY(3, 1, 0, 0, 0, 0, "ITEM DISCOUNT")

return nil  

function d_ref_Addon(nRate,nAmount)         
local out_text
  disp_clr()  
  DISPTEXTXY(3, 1, 1, 1, 1, 1, MSG_CLEAR )
  out_text := trans( nRate , "999%") + " ADDON" + trans(-nAmount,"999,999.99")
  DISPTEXTXY(1, 1, 0, 0, 2, 1, out_text)
  DISPTEXTXY(2, 1, 0, 0, 0, 0, "*REFUND STTL ADD-ON*")
return nil

function d_ref_Sdisc(nRate, nAmount)
local out_text

  disp_clr()
*  DISPTEXTXY(1, 1, 0, 0, 1, 1, MSG_CLEAR )
  out_text := trans( nRate , "999%") + " DISC." + trans(nAmount,"999,999.99")
  DISPTEXTXY(2, 1, 0, 0, 2, 1, out_text)
  DISPTEXTXY(3, 1, 0, 0, 0, 0, "REFUND STTL.DISCOUNT")

return nil  


/* eof */