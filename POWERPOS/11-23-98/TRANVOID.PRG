#include "grfx_all.ch"
#include "config.ch"
#include "spec_key.ch"
#include "keymap.ch"
#include "powerpos.ch"
#include "terminal.ch"
#include "itemtran.ch"
#include "file_acc.ch"
#include "plu_file.ch"
#include "deptfile.ch"
#include "message.ch"

#define  LMARGIN             11

static ltran_void := .F.

function ltran_void(lVal)
  if valtype(lVal) == "L"
     ltran_void := lVal
  endif
return ltran_void

function tran_void(tran_no)
local lRetVal := .F.
local cTransNo,cPassword
local nTransNo
local cFlag,cBuffer
local nQty,nAmt
local nPayType
local outtext
local nQTYtotal,nAMTtotal 
local nPrice := 0
local cDesc := space(20)
local cClerk
local cPluCode,cDept
local cData,cDispBuff := ""
local cPflg
local cWindow

    cWindow := OpenWindow(24, 34, 77, 63, "Transaction Void")
     // first Prompt for password for transaction voids
     if !empty( config( POS_PASSWORD ) )
       MsgAreaDisp("Enter password for transaction void...")
       gDrawText(18, 22, "Password : _",    SMALL_FONT, 6, 0, MFIX, LEFT_TEXT)            
       cPassword := GetPass( 18,33,8, "Enter transaction no to void.." )
       if cPassword != config( POS_PASSWORD )
	  ErrorDisp("Invalid Password !!!")
	  BUMMER()
	  CloseWindow(cWindow)
	  return .F.
       endif        
     endif  
     // then prompt for transaction no.
     MsgAreaDisp("Enter transaction number to void..")
     gDrawText(19, 21, "Trans. No. : _",    SMALL_FONT, 6, 0, MFIX, LEFT_TEXT)    
     cTransNo := Grfx_Data(3, 9, 0, 0, 2, 9, { |x| ( ((!empty(is_number(x)) .and. (x != KEY_PERIOD)) .or. is_dept(x) != 0) ) } , 6, "Enter transaction no to void..", 2)
     nTransNo := val(cTransNo)
     if empty(nTransNo)
	  ErrorDisp("Invalid Transaction no. ...")
	  CloseWindow(cWindow)
	  return .F.
     else
       cTransNo := padl(nTransNo,6,"0")
     endif
     CloseWindow(cWindow)

     // now proceed with all possible items to void...
                
    // clear display
    disp_clr()

    if parsetran(nTransNo)
       cBuffer := getnext(nTransNo)

       while len(cBuffer) == ITEM_SIZE_TOT
          cFlag := subs( cBuffer,ITEM_FLAG_OFF ,ITEM_FLAG_LEN )
          cPflg := subs( cBuffer,ITEM_PFLG_OFF ,ITEM_PFLG_LEN )
          if cFlag != "?" .and. cFlag != "!"          
             if cFlag $ "Z1234567890"
                nQty := val(subs(cBuffer,CUST_CNTR_OFF,CUST_CNTR_LEN)) //* 0.01
                nAmt := val(subs(cBuffer,CUST_SALE_OFF,CUST_SALE_LEN)) * 0.01
                nPayType := val(subs(cBuffer,CUST_PAYM_OFF,CUST_PAYM_LEN))

                Term_nData(TR_DSLS_TOT,-nAmt)                
                if cFlag == "Z"
                  Term_nData(TR_DSLS_KNT,-1)                
                endif  
// RCI 11-22-98
//			 Term_nData(TR_DEPT_TOT, -nAmt)

                Term_nData(TR_TRVD_TOT, nAmt)
                Term_nData(TR_TRVD_KNT, 1)

                if nPayType == 0
                   Term_nData(TR_CASH_TOT,-nAmt)
                   outtext := pad("*VOIDED CASH PAYMENT",21)
#ifdef DEF_GRAPHICS
                   Disp_PayAmt("CASH", nvr_nSUBtotal(), nAmt, nvr_nSUBtotal() + nAmt)
#endif 
                else
                   Term_nData(7+((nPayType-1)*2),-nAmt)        
                   Term_nData(8+((nPayType-1)*2),-1)   // Then the Quantities                
                   outtext := pad("*VOIDED "+GetMDesc(nPayType)+" PAYMENT",21)
#ifdef DEF_GRAPHICS
                   Disp_PayAmt(GetMDesc(nPayType), nvr_nSUBtotal(), nAmt, nvr_nSUBtotal() + nAmt)
#endif                    
                endif                    
                Disp_BoldChar(nvr_nSUBtotal()+nAmt)                

                A_RJS_FEED( 1, 1, 0, 1 )
                outtext += trans(nAmt, "9999,999.99")
                rpt_prnt( 1, 1, 0, outtext , 1 )
                
                nvr_nSUBtotal( nvr_nSUBtotal() + nAmt )
                                                
*                tran_cPflg( subs(cBuffer,CUST_PFLG_OFF,CUST_PFLG_LEN) )
                tran_cPFlg( cFlag )                                
                tran_cFlag( OP_TVOD_FLAG )
                tran_nSale( val(subs(cBuffer,CUST_SALE_OFF,CUST_SALE_LEN)) * 0.01 )
                tran_nCntr( val(subs(cBuffer,CUST_CNTR_OFF,CUST_CNTR_LEN)) )
                tran_cPrcM( subs(cBuffer,CUST_PAYM_OFF,CUST_PAYM_LEN) )
                tran_cCrg1( subs(cBuffer,CUST_CRG1_OFF,CUST_CRG1_LEN) )
                tran_cCrg2( subs(cBuffer,CUST_CRG2_OFF,CUST_CRG2_LEN) )
                tran_cCrg3( subs(cBuffer,CUST_CRG3_OFF,CUST_CRG3_LEN) )    
             else
                cClerk := subs( cBuffer,ITEM_CLRK_OFF,ITEM_CLRK_LEN )
                nQty := val(subs(cBuffer,ITEM_CNTR_OFF,ITEM_CNTR_LEN)) //* 0.01
                nAmt := val(subs(cBuffer,ITEM_SALE_OFF,ITEM_SALE_LEN)) * 0.01
                nQTYtotal := nvr_nQtyitems()
                nAMTtotal := nvr_nSUBtotal()
                cPLUCode := subs(cBUffer,ITEM_PLUC_OFF,ITEM_PLUC_LEN)
                cDept := subs(cBuffer,ITEM_DEPT_OFF,ITEM_DEPT_LEN)
#ifdef NON_ADD_ENABLED
                if config(POS_VLD_CLRK) == "YES" .and. cClerk != "000000"
                   get_Clerk(cClerk)
                   outtext := if(empty(cClerk_Desc()),"CLERK# "+cClerk,cClerk_Desc())
                   rpt_prnt(1, 1, 0, outtext , 0)  
                endif                                  
#endif                
                do case
                   case cFlag == OP_NPLU_FLAG  
                        nvr_nQtyitems(nQTYtotal-nQty)
                        nvr_nSUBtotal(nAMTtotal-nAmt)
                        // Term_nData(TR_DEPT_TOT, nAmt)
                        get_plu(cPLUCode,@nPrice,@cDesc,cDept,nAmt,nQty )
                        nPrice := (nAmt/max(nQty,1))
                        print_plu(cPLUCode,nQty,nPrice,-nAmt,cDesc)
                        Disp_BoldChar(nvr_nSUBtotal(), "Total Amount")
                        Rcpt_Scroll(1, cDesc, nQty, -nPrice, cFlag, 0, 0, 0, 0, cClerk)
                        plu_counter(cPLUcode, - nQty, - nAmt, 0)  
                        dept_counter(cDept, - nQty, - nAmt, 0)
                   case cFlag == OP_OINC_FLAG
                        A_RJS_FEED(1, 1, 0, 1)                                         
                        if cPFlg != "1"  // Negative Cash Sub Flag
                          nvr_nQtyitems(nQTYtotal-nQty )            
                          nvr_nSUBtotal(nAMTtotal-nAmt)                                       
                          if cPFlg == OP_REXC_FLAG
                            outtext := pad("*OTHINC(RET/EXCH)",22) + trans(-nAmt, "999,999.99") + chr(10) 
                            Term_nData(TR_OINC_TOT, -nAmt )
                            Term_nData(TR_OINC_KNT, -1 ) 
                            Term_nData(TR_TRVD_TOT, -nAmt )                
                          else  
                            outtext := pad("*OTHER INCOME    ",22) + trans(-nAmt, "999,999.99") + chr(10)
                          endif  
                        elseif (nAmt != 0)
                          Term_nData(TR_OFFL_TOT, -nAmt)
                          Term_nData(TR_OFFL_KNT, -nQty )           
                          outtext := pad("*NEGATIVE CASH",22) + trans(-nAmt, "999,999.99") + chr(10)                                                     
                        endif
                        rpt_prnt(1, 1, 0, outtext, 0)
                   case cFlag == OP_VOID_FLAG 
                        if cPFlg $ "NMP"
                          Term_nData( TR_VOID_TOT , -nAmt )                
                          Term_nData( TR_VOID_KNT , -1 )                
                          outtext := "*ITEM VOID " +  trans(nQty, "@ 9999.99") ;
                                     + " @ "  + trans(nAmt, "99,999.99") + chr(10) 
                          rpt_prnt(1, 1, 0, outtext, 0)            
                          outtext := pad(cPLUCode,21) + transform(nAmt, "9999,999.99") + chr(10) 
                          rpt_prnt(1, 1, 0, outtext, 0)
                        endif  
                   case cFlag == OP_MGRV_FLAG
                        if cPFlg $ "NMP"
                          Term_nData( TR_MGRV_TOT , -nAmt )                
                          Term_nData( TR_MGRV_KNT , -1 ) 
                          outtext := "*MGR'S VOID" +  trans(nQty, "@ 9999.99") ;
                                     + " @ "  + trans(nAmt, "99,999.99") + chr(10) 
                          rpt_prnt(1, 1, 0, outtext, 0)            
                          outtext := pad(cPLUCode,21) + transform(nAmt, "9999,999.99") + chr(10) 
                          rpt_prnt(1, 1, 0, outtext, 0)                                                                                    
                        endif                          
                   case cFlag == OP_IDSC_FLAG 
                        if cPflg == "0"
                          nvr_nSUBtotal(nAMTtotal + nAmt)             
//RCI 11-22-98					 
//			  Term_nData(TR_DEPT_TOT, -nAmt)
                          Term_nData(TR_IDSC_TOT, - nAmt )
                          Term_nData(TR_IDSC_KNT, - 1 )
                          outtext := trans(nQty,"999%")+pad("ITEM DISC",17) + trans(nAmt, "9999,999.99")
                          rpt_prnt(1, 1, 0, outtext, 0)            
                         #ifdef DEF_GRAPHICS 
                          Rcpt_Scroll(1, cDesc, 0, nPrice, cFlag, 0, nQty, nAmt, 0, cClerk)
                         #endif 
                        endif  
                   case cFlag == OP_SDSC_FLAG
                        nvr_nSUBtotal(nAMTtotal + nAmt)            
                        nvr_nQtyitems(nQTYtotal - nQty )
                        Term_nData(TR_SDSC_TOT, - nAmt )
                        Term_nData(TR_SDSC_KNT, - 1 )
                        outtext := "SUBTOTAL:          "+ trans(nvr_nSUBtotal(), "99,999,999.99")      
                        A_RJS_FEED(1, 1, 0, 1)
                        rpt_prnt(1, 1, 0, outtext , 0)   
                        outtext := trans(nQty,"999 %")+"STTL. DISCOUNT " + trans(nAmt, "9999,999.99") 
                        rpt_prnt(1, 1, 0, outtext, 0)  
#ifdef DEF_GRAPHICS
                        outtext := transform(nQty, "@Z 99% ") + "DISCOUNT"
                        Disp_PayAmt(outtext, nAmtTotal, nAmt, nvr_nSUBTotal())
                        Disp_BoldChar(nvr_nSUBtotal())
#endif                                                
                   case cFlag == OP_TRCL_FLAG
                        /* do nothing */
                   case cFlag == OP_ITCL_FLAG
                        /* do nothing */
                   case cFlag == OP_OPEN_FLAG
                        nvr_nSUBtotal(nAMTtotal - nAmt)
                        nvr_nQtyitems(nQTYtotal  - nQty )
                        // Term_nData(TR_DEPT_TOT,- nAmt)                          
                        get_dept(cDept,nAmt,nQty,@cDesc)
                        nPrice := (nAmt/max(nQty,1))
                        print_dept(cDesc,nQty,nPrice,-nAmt)
#ifdef DEF_GRAPHICS
                        Disp_BoldChar(nvr_nSUBtotal(), "Total Amount")
                        Rcpt_Scroll(1, cDesc, nQty, -nPrice, cFlag, 0, 0, 0, 0, cClerk )
#endif                        
                        dept_counter(cDept, -nQty, -nAmt, 0)
                   case cFlag == OP_REXC_FLAG
                        nvr_nSUBtotal(nAMTtotal + nAmt)
                        nvr_nQtyitems(nQTYtotal  + nQty )
                        Term_nData(TR_REXC_TOT, - nAmt )
                        Term_nData(TR_REXC_KNT, - 1 )
                        // Term_nData(TR_DEPT_TOT, nAmt)
                        get_plu(cPLUCode,@nPrice,@cDesc,cDept,nAmt,nQty)
                        nPrice := (nAmt/max(nQty,1))
                        A_RJS_FEED(1, 1, 0, 1)                      
#ifdef DEF_GRAPHIC
                        Rcpt_Scroll(1, cDesc, nQty, nPrice, cFlag, 0, 0, 0, 0, cClerk) 
#endif                  
                        if cPflg == OP_NPLU_FLAG
                           plu_counter(cPLUCode, nQty, nAmt, 0)
                        elseif cPflg == OP_NOTF_FLAG   
                           lNFND_Add(cPLUCode,cDesc,cDept,nQty,nAmt,0 )
                        endif   
                        dept_counter(cDept, nQty, nAmt, 0)           
                        retexch_counter(cPLUCode, space(12), cDesc, cDept, -nQty, nPrice, -nAmt)
                        outtext :=pad("*RETURN",LMARGIN)+trans(nQty,"999 @  ")
                        outtext += trans(nPrice,"999,999.99")
                        rpt_prnt(1, 1, 0, outtext, 0)            
                        outtext := cDesc
                        outtext += "  " +  trans(nAmt,"999,999.99")
                        rpt_prnt(1, 1, 0, outtext, 0)
                        Term_nData( TR_TRVD_TOT , nAmt )                
                   case cFlag == OP_NOTF_FLAG
                        nvr_nQtyitems(nQTYtotal-nQty)
                        nvr_nSUBtotal(nAMTtotal-nAmt)                        
                        // Term_nData(TR_DEPT_TOT,-nAmt)
                        nPrice := (nAmt/max(nQty,1))
#ifdef DEF_GRAPHICS                        
                        if cPflg == "0"
                          Rcpt_Scroll(1, cPLUCode, nQty, -nPrice, cFlag, 0, 0, 0, 0, cClerk) 
                        else  
                          Rcpt_Scroll(1, cPLUCode, nQty, -nPrice, "A", 0, 0, 0, 0, cClerk)
                        endif  
#endif                          
                        cDesc := pad("P"+cPLUCode+"D"+cDept,20)
                        // lNFND_Add(cPLUCode,cDesc,cDept,-nQty,-nAmt,0 )  - jlp 
			lNFND_Add(cPLUCode,cDesc,cDept,-nQty,nPrice,0 )    
                        dept_counter(cDept, -nQty, -nAmt, 0)
                        print_plu(cPLUCode,nQty,nPrice,-nAmt,cDesc)
                   case cFlag == OP_ADON_FLAG
                        nvr_nSUBtotal(nAMTtotal - nAmt)                  
                        if cPflg != "1"  
                          Term_nData(TR_ADON_TOT, - nAmt )
                          Term_nData(TR_ADON_KNT, if (nAmt != 0,-1,0) )
                        endif  
                        outtext := pad(tran(nQty,"@Z 999.99% ADD-ON"),21) + trans(-nAmt, "9999,999.99")
                        rpt_prnt(1, 1, 0, outtext, 0)                  
                        outtext := pad("SUBTOTAL",21) + tran(nvr_nSUBTotal() ,"9999,999.99")                        
                        rpt_prnt(1, 1, 0, outtext, 0)                                                            
#ifdef POS_VAT
                   case cFlag == OP_VATX_FLAG
                        nvr_nSUBtotal(nAMTtotal - nAmt)                   
                        outtext := pad("SUBTOTAL",21) + tran(nvr_nSUBTotal() ,"9999,999.99")
                        rpt_prnt(1, 1, 0, outtext, 0)                  
                        outtext := padl("10%VAT",21) + trans(-nAmt, "9999,999.99") + chr(10) 
                        rpt_prnt(1, 1, 0, outtext, 0)                                    
#endif                                                                      
                   case cFlag == OP_RFND_FLAG            
                        /* do nothing muna */ 
                endcase  
                    
                tran_cPFlg( cFlag )                                
                tran_cFlag( OP_VOID_FLAG )
                tran_cPLU ( subs(cBuffer,ITEM_PLUC_OFF,ITEM_PLUC_LEN) )
                tran_cItem( subs(cBuffer,ITEM_ITEM_OFF,ITEM_ITEM_LEN) )
                tran_cDept( subs(cBuffer,ITEM_DEPT_OFF,ITEM_DEPT_LEN) )
                tran_cRegM( subs(cBuffer,ITEM_REGM_OFF,ITEM_REGM_LEN) )
                tran_cConc( subs(cBuffer,ITEM_CONC_OFF,ITEM_CONC_LEN) )
                tran_cColo( subs(cBuffer,ITEM_COLO_OFF,ITEM_COLO_LEN) )
                tran_cSize( subs(cBuffer,ITEM_SIZE_OFF,ITEM_SIZE_LEN) )
                tran_cClrk( subs(cBuffer,ITEM_CLRK_OFF,ITEM_CLRK_LEN) )                
                tran_nSale( nAmt ) // placed the amount
                tran_nCntr( nQty ) // placed the quantity
                tran_cCrgo( subs(cBuffer,ITEM_CRGO_OFF,ITEM_CRGO_LEN) )
                tran_cPrcM( subs(cBuffer,ITEM_PRCM_OFF,ITEM_PRCM_LEN) )

*               tran_cDesc( )
*               tran_nPric( )
*               tran_nQty( )                
                
/*                o"o     ---- 
                   !    (      )
                 ;(o)`-{  Hi !  )
                ;(o)`   (      )
               ;(o)`      ----         <o>   <o>
              '(o)`                          
               ;(o);,,,,,,
                ;(o)))))))^-
                 ''''''''' 
*/                                
             endif   
             MsgAreaDisp("Updating Trans file")
             Update_Trans()
          endif                                

          Rcpt_Footer()

          cBuffer := getnext(nTransNo)
          
       enddo

       DispSubTotal()         
       A_RJS_FEED( 1, 1, 0, 1 )
       rpt_prnt(1, 1, 0, pad("SUBTOTAL ",21)+trans(nvr_nSUBtotal(),"9999,999.99"), 0)
       A_RJS_FEED(1, 1, 0, 1)
       rpt_prnt(1, 1, 0,  padc("Transaction #:"+ltrim(str(nTransNo)),32), 0)
       rpt_prnt(1, 1, 0, "****** TRANSACTION VOIDED ******", 0)
       A_RJS_FEED( 1, 1, 0, 1 ) 

       lRetVal := .T.
       // reset the subtotal and counter 
       nvr_nSUBtotal(0)
       nvr_nQTYitems(0)  
    endif
      
return lRetVal

static function GetPass( nRow, nCol, nLen, cMsg )
local cKey := 0
local cData
*local x1,x2,y1,y2
local cKeyBuff := ""

   while cKey != ENTER
        cKey := input ()
        
        do case
           case IS_KEYCHANGE(cKey)          
#ifdef KEY_SOUND       
             Sound_off()
#endif          
             Disp_Mode()                    
             if nvr_nSUBtotal() != 0
                SetAlarm(MSG_D011)
             else
                // don't allow position one three and four 
                SetAlarm(MSG_D012)
             endif  
             while keylock() == 0 .or. keylock() == 3 .or. keylock() == 4
                 input()
             enddo
             SetAlarm()
             Disp_Mode()          
          
             MsgAreaDisp(cMsg) // clear display area
#ifdef KEY_SOUND          
             Sound_On()
#endif       
           case cKey == CLR
             if empty(cKeyBuff)
                exit
             endif
             cKeyBuff := ""
             gClearTo(44, 51, 75, 54, 7)
             gDrawText(18, 33, chr(95), SMALL_FONT, 6, 0)
           case !empty(cData := is_number( cKey ) ) 
             if len(cKeyBuff) < nLen
               cKeyBuff += cData
             endif                  
             gClearTo(44, 51, 75, 54, 7)
             gDrawText(18, 33, repl("*",len(cKeyBuff)) + chr(95), SMALL_FONT, 6, 0)
           case !empty(cData := is_alpha( cKey ) )
             if len(cKeyBuff) < nLen
               cKeyBuff += cData
             endif      
             gClearTo(44, 51, 75, 54, 7)
             gDrawText(18, 33, repl("*",len(cKeyBuff)) + chr(95), SMALL_FONT, 6, 0)
           case cKey == BACK_SPACE  
             cKeyBuff := subs(cKeyBuff,1,len(cKeyBuff)-1)
             gClearTo(44, 51, 75, 54, 7)
             gDrawText(18, 33, repl("*",len(cKeyBuff)) + chr(95), SMALL_FONT, 6, 0)
           case cKey == ENTER
             gClearTo(44, 51, 75, 54, 7)
             gDrawText(18, 33, repl("*",len(cKeyBuff)), SMALL_FONT, 6, 0)
           otherwise
              if !empty(cMsg)
                  ErrorDisp(MSG_D006) // probable key sequence error   
                  MsgAreaDisp(cMsg)  // restore previous message
              endif              
        endcase      
        
//        x2 := x1 + round((len(cKeyBuff)+3)*3,0)      
//        gClearTo(x1, y1, x2, y2, 7)
        
   enddo
   
return cKeyBuff
/* eof */
