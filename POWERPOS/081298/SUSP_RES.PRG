#include "config.ch"
#include "nvr_file.ch"
#include "keymap.ch"
#include "fileio.ch"
#include "terminal.ch"
#include "powerpos.ch"

#define TYPE_BANKCARD       "0"

 // note that the transaction counter will not be incremented
 // the suspended transaction will be save to file susp000?.txt
 // maximum of 9 suspend transaction...
    
function suspend_tran(nVar)
local filename := subs(config(POS_NVRAM_DRV),1,1)+":\" + NVCNTRL_NAME
local suspfile := ".\SUSP"+padl(++nVar,4,"0")+".TXT"
local nRetVal := NORMAL
local outtext,k
local cFlag
local nAmount,nCounter
local nPayAmt
local nPayType

  __Copyfile(filename,suspfile)
  if ( (nRetVal := ferror ()) == NORMAL )
    // reset all nvram accumulators...
    outtext :=  space(10)+"SUBTOTAL"+ space(1) + trans(nvr_nSUBtotal(), "99,999,999.99")      
    A_RJS_FEED(1, 0, 0, 1)
    rpt_prnt(1, 0, 0, outtext , 0)     

    outtext :=  "SUBTOTAL"+ space(11) + trans(nvr_nSUBtotal(), "99,999,999.99")
    // on journal...
    // A_PRT_ESC(NORMAL_12)
    A_RJS_FEED(0, 1, 0, 1)
    rpt_prnt(0, 1, 0, outtext , 0)    
    A_RJS_FEED(1, 1, 0, 1)
    rpt_prnt(1, 1, 0,padc("*** TRANSACTION SUSPENDED ***",32),0)
    outtext := "SUSPEND TRANS.NO.: "+pad(nVar,1)
    rpt_prnt(1, 1, 0,padc(outtext,32),0)
    A_RJS_FEED(1, 1, 0, 1)    


    for k := 1 to nvr_nITMitem()
     
       tran_init(k)
       cFlag := tran_cFlag()
       nAmount  := tran_nSale()
       nCounter := tran_nCntr()
       do case 
          case cFlag $ POSITIVE_OPER_FLAG 

                if cFlag != OP_ADON_FLAG
                  // Deduct the department total with the ff amounts 
                  Term_nData(TR_DEPT_TOT, - nAmount)
                  dept_count(tran_cDept(),-nCounter, -nAmount, 0 )                  
               endif   
             
               if cFlag == OP_OINC_FLAG
                  Term_nData(TR_OINC_TOT, - nAmount  )
                  Term_nData(TR_OINC_KNT, - 1 )
               elseif cFlag == OP_ADON_FLAG
                  Term_nData(TR_ADON_TOT, - nAmount )
                  Term_nData(TR_ADON_KNT, - 1 )                    
               endif

               if cFlag == OP_NPLU_FLAG
                  plu_counter(tran_cPlu(), -nCounter, -nAmount, 0)
               elseif cFlag == OP_NOTF_FLAG   
                  lNFND_ADD(tran_cPLU(),tran_cDesc(),tran_cDept(),-nCounter,-nAmount,0)
               endif                  
             
          case cFlag $ NEGATIVE_OPER_FLAG
               // Deduct the department total with the ff amounts 
*              Term_nData(TR_DEPT_TOT, nAmount)

               if cFlag == OP_VOID_FLAG
                   if Tran_cPflg() != "D"               
                     Term_nData(TR_VOID_TOT, - nAmount )
                     Term_nData(TR_VOID_KNT, - 1 )
                   endif  
               elseif cFlag == OP_MGRV_FLAG    
                   if Tran_cPflg() != "D"               
                     Term_nData(TR_MGRV_TOT, - nAmount )
                     Term_nData(TR_MGRV_KNT, - 1 )
                   endif  
               elseif cFlag == OP_IDSC_FLAG
                   Term_nData(TR_IDSC_TOT, - nAmount )
                   Term_nData(TR_IDSC_KNT, - 1 )
                   
                   if tran_cPflg() == OP_NPLU_FLAG
                      plu_counter(tran_cPlu(), 0, 0, -nAmount)
                   elseif tran_cPflg() == OP_OPEN_FLAG
                      dept_count(tran_cDept(), 0, 0, -nAmount)                      
                   elseif tran_cPflg() == OP_NOTF_FLAG                         
                      lNFND_ADD(tran_cPLU(),tran_cDesc(),tran_cDept(),0,0,-nAmount)
                   endif                                            
                   
               elseif cFlag == OP_SDSC_FLAG
                   Term_nData(TR_SDSC_TOT, - nAmount )
                   Term_nData(TR_SDSC_KNT, - 1 )
               elseif cFlag == OP_REXC_FLAG
                   Term_nData(TR_REXC_TOT, - nAmount )
                   Term_nData(TR_REXC_KNT, - 1 )
                   Term_nData(TR_DEPT_TOT, nAmount)
               endif    
                                                                         
          case cFlag $ DONOTHING_OPER_FLAG
             if cFlag $ "123456789" // partial payments...
                // undo the payment done...

                nPayType := val(tran_cPrcM())                
                nPayAmt := -tran_nSale()
                Term_nData(TR_DSLS_TOT,nPayAmt)      // First the Totals  
              
                if nPayType == 0
                  Term_nData(TR_CASH_TOT,nPayAmt)                
                  outtext := pad("CASH PAYMENT",21)
                else
                  Term_nData(7+((nPayType-1)*2),nPayAmt)        
                  Term_nData(8+((nPayType-1)*2),-1)     // Then the Quantities
                  outtext := pad(GetMDesc(nPayType)+" PAYMENT",21)
                endif    
                        
                outtext += trans(nPayAmt, "9999,999.99")
                rpt_prnt( 1, 1, 0, outtext , 1 )
             endif          
             // Just do nothing...
          otherwise 
             // warn me that there are unknown flags roaming around...
             error_log ("Unrecognized flag at trans cancel : "+cFlag)   
       endcase    

       // then edit the transaction for cancel flag
       // tran_cPflg(tran_cFlag())
       // tran_cFlag(OP_ITCL_FLAG)
       // edit_trans(k)
	  MsgAreaDisp("Item : "+tran_cDesc()+" Suspended")               
    next k      

#ifdef SLIP_PRNT    
    // delete all transaction invoice procedure validation
    del_invoice()    
#endif    
        
    Term_nData(TR_TRSU_TOT, nvr_nSUBtotal())
    Term_nData(TR_TRSU_KNT, 1)
    prnt_end(nvr_nQTYItems())
    nvr_nSUSlevel(nVar)
    nvr_nSUBtotal(0)  
    nvr_nQTYItems(0) // No of items in the transaction.
    nvr_nITMitem(0) // Total No of records in the NVR tran file    
    nvr_nSWPlevel(0)         
  endif
   
return nRetVal

function resume_tran()
local nRetVal := NORMAL
local filename := subs(config(POS_NVRAM_DRV),1,1)+":\" + NVCNTRL_NAME
local suspfile 
local nFHandle ,k, nOffset
local nSuspend := 1
local cData,cBuffer
local outtext,cDispData
local aData_ := {}
local cFlag
local nAmount,nCounter
local nPayAmt
local nPayType

  if nvr_nSUSlevel() > 1

     cDispData :=  ": "   
     for k := 1 to nvr_nSUSlevel()
       if file(".\SUSP"+padl(k,4,"0")+".TXT")
          aadd(aData_,k)
          cDispData += pad(k,1)+","
       endif
     next k

     while .T.
       DISPTEXTXY(1,1,0,0,1,1,"RESUME TRANSACTION: ")
       DISPTEXTXY(2,1,0,0,0,0,"POSSIBLE TRANSACTION")
       DISPTEXTXY(3,1,0,0,0,0,pad(cDispData,20))
       DISPTEXTXY(4,1,0,0,2,1,"ENTER TRAN.TO RESUME")     
       MsgAreaDisp("Enter Transaction No. to Resume")
       cData := readdata(1,20,0,0,1,20,{|x| ((!empty(is_number(x)) .and. (x != KEY_PERIOD)) .or. is_dept(x) != 0)  } ,1,"ENTER TRAN.TO RESUME")
     
       if empty(cData) 
          return .F.
       endif
       nSuspend := val(cData)
       // validate the entry...
       if nSuspend > 0 .and. ascan(aData_,{ |x| x == nSuspend }) > 0
          exit 
       else
          outtext := "TRAN#:"+pad(nSuspend,1)+" DO NOT EXIST!"
          ErrorDisp(outtext)  
       endif
     enddo

     aData_ := {} // release the memory eaten...  
     
  endif  

  // now do the actual transaction resume...
  suspfile := ".\SUSP"+padl(nSuspend,4,"0")+".TXT"
  if file(suspfile) // check if the file still exist
     nfhandle := fopen(suspfile)
     if ferror() == NORMAL
        rpt_prnt(1, 1, 0,padc("*** TRANSACTION RESUMED ***",32),0)
        outtext := "RESUMED TRANS.NO.: "+pad(nSuspend,1)
        rpt_prnt(1, 1, 0,padc(outtext,32),0)
        A_RJS_FEED(1, 1, 0, 1)            
        fseek(nfhandle, 0, FS_SET)           
        cBuffer := space(NVR_CNTRL_SIZE)
        fread(nfhandle, @cBuffer, NVR_CNTRL_SIZE)
        cData  := subs(cBuffer, NVR_STT_OFF, NVR_STT_LEN)
        nvr_nSUBtotal(realiee(cData))
        cData  := subs(cBuffer, NVR_QTY_OFF, NVR_QTY_LEN)              
        nvr_nQTYItems(realiee(cData)) // No of items in the transaction.
        cData  := subs(cBuffer, NVR_ITM_OFF, NVR_ITM_LEN)           
        nvr_nITMitem(val(cData)) // Total No of records in the NVR tran file                          
        cData  := subs(cBuffer, NVR_SWP_OFF, NVR_SWP_LEN)
        nvr_nSWPlevel(val(cData)) 
        for k := 1 to nvr_nITMitem()
         nOffset := NVR_CNTRL_SIZE + ((k-1)*(NVR_TRANS_SIZE))
         FSEEK(nfhandle, nOffset, FS_SET)
         cBuffer := space(NVR_TRANS_SIZE)
         FREAD(nfhandle, @cBuffer, NVR_TRANS_SIZE) 
         put_Trans(k,cBuffer)
        next            
        fclose(nfhandle)
        ferase(suspfile)

        Term_nData(TR_TRSU_TOT, -nvr_nSUBtotal())
        Term_nData(TR_TRSU_KNT, -1)
                
#ifdef DEF_DISP1X09
        // customer display 1 (1x9)
        // no. plus comma or period occupies only 1 space
        outtext := trans(nvr_nSUBtotal(), "9999999.99")
        DISPTEXTXY(0, 0, 1, 1, 0, 0, outtext )
#endif                    
        // customer display 2 (2X20)
        disp_clr()
        DISPTEXTXY(2, 1, 0, 0, 2, 1, "BAL DUE :           ")
        outtext := trans(nvr_nSUBtotal(), "999,999.99")
        DISPTEXTXY(3, 11, 0, 0, 2, 11, outtext)
     
        // Now get all transaction records and put them in display array
        for k := 1 to  nvr_nITMitem()
               tran_init(k)
               cFlag := tran_cFlag()
               nAmount  := tran_nSale()
               nCounter := tran_nCntr()
               do case 
                  case cFlag $ POSITIVE_OPER_FLAG 
                       if cFlag != OP_ADON_FLAG
                         // Add the department total with the ff amounts
                         Term_nData(TR_DEPT_TOT, nAmount)
                         dept_count(tran_cDept(),nCounter, nAmount, 0 )                                           
                       endif  
             
                       if cFlag == OP_OINC_FLAG
                          Term_nData(TR_OINC_TOT, nAmount  )
                          Term_nData(TR_OINC_KNT, 1 )
                       elseif cFlag == OP_ADON_FLAG
                          Term_nData(TR_ADON_TOT, nAmount )
                          Term_nData(TR_ADON_KNT, 1 )                                                    
                       endif

               if cFlag == OP_NPLU_FLAG
                  plu_counter(tran_cPlu(), nCounter, nAmount, 0)
               elseif cFlag == OP_NOTF_FLAG   
                  lNFND_ADD(tran_cPLU(),tran_cDesc(),tran_cDept(),nCounter,nAmount,0)
               endif   
                                    
                  case cFlag $ NEGATIVE_OPER_FLAG
                       // Deduct the department total with the ff amounts 
          *            Term_nData(TR_DEPT_TOT, nAmount)

                       if cFlag == OP_VOID_FLAG
                           if Tran_cPflg() != "D"                       
                              Term_nData(TR_VOID_TOT,  nAmount )
                              Term_nData(TR_VOID_KNT,  1 )
                           endif   
                       elseif cFlag == OP_MGRV_FLAG    
                           if Tran_cPflg() != "D"                       
                              Term_nData(TR_MGRV_TOT,  nAmount )
                              Term_nData(TR_MGRV_KNT,  1 )
                           endif    
                       elseif cFlag == OP_IDSC_FLAG
                           Term_nData(TR_IDSC_TOT,  nAmount )
                           Term_nData(TR_IDSC_KNT,  1 )
                       elseif cFlag == OP_SDSC_FLAG
                           Term_nData(TR_SDSC_TOT,  nAmount )
                           Term_nData(TR_SDSC_KNT,  1 )
                       elseif cFlag == OP_REXC_FLAG
                           Term_nData(TR_REXC_TOT,  nAmount )
                           Term_nData(TR_REXC_KNT,  1 )
                           Term_nData(TR_DEPT_TOT, -nAmount)
                       endif    
                                                                         
                  case cFlag $ DONOTHING_OPER_FLAG
                       if cFlag $ "123456789" // partial payments...
                          // undo the payment done...

                          nPayType := val(tran_cPrcM())                
                          nPayAmt := tran_nSale()
                          Term_nData(TR_DSLS_TOT,nPayAmt)      // First the Totals               

                          if nPayType == 0
                            Term_nData(TR_CASH_TOT,nPayAmt)                          
                            outtext := pad("CASH PAYMENT",21)
                          else
                            outtext := pad(GetMDesc(nPayType)+" PAYMENT",21)
                            Term_nData(7+((nPayType-1)*2),nPayAmt)        
                            Term_nData(8+((nPayType-1)*2),1)     // Then the Quantities                            
#ifdef SLIP_PRNT                            
                            if GetMType(nPayType) != TYPE_BANKCARD
                               add_invoice( { nPayType, nPayAmt } )
                            endif
#endif                            
                            
                          endif    
                        
                          outtext += trans(nPayAmt, "9999,999.99")
                          rpt_prnt( 1, 1, 0, outtext , 1 )
                                                    
                          outtext := padl("BAL. DUE ",22) + trans(tran_nCntr(), "999,999.99") + chr(10) 
                          rpt_prnt( 1, 1, 0, outtext , 1 )                                                    
                          
                       endif   
                       // Just do nothing...
                  otherwise 
                     // warn me that there are unknown flags roaming around...
                     error_log ("Unrecognized flag at trans cancel : "+cFlag)   
               endcase    
     
          Disp_tran( k )                                                
          print_bill( k )
          Disp_LastPage(k)
        next k

        #ifdef DEF_GRAPHICS
          Disp_BoldCh(nvr_nSUBtotal(), "Total Amount")          
        #endif

        A_RJS_FEED(1, 1, 0, 1)
        
        outtext :=  space(10)+"SUBTOTAL"+ space(1) + trans(nvr_nSUBtotal(), "99,999,999.99")        
        rpt_prnt(1, 0, 0, outtext , 0)     

        // on journal...
        outtext :=  "SUBTOTAL"+ space(11) + trans(nvr_nSUBtotal(), "99,999,999.99")
        rpt_prnt(0, 1, 0, outtext , 0)
                           
     else
       ErrorDisp("CANNOT RESUME TRANS.")
     endif  
  else
    ErrorDisp("TRANS.ALREADY RESUME")
  endif   

  // now resolved the suspend level on nvcntrl
  // and update the suspend level variable
  nSuspend := nvr_nSUSlevel()
  for k := nSuspend to 0 step -1
    if file(".\SUSP"+padl(k,4,"0")+".TXT")
       exit
    endif
  next
  nvr_nSUSlevel(k)             
  
return nRetVal

