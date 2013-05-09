#include "oneshot.ch"
#include "file_acc.ch"
#include "message.ch"
#include "deptfile.ch"
#include "terminal.ch"
#include "config.ch"
#include "spec_key.ch"

#ifdef DEF_GRAPHICS
 #include "grfx_all.ch"
#endif

#define PLU_CODE_LEN    14
#define PLU_ITEM_LEN    12

#define LMARGIN         11
                               
static adept_ := {}

function dept_init()

     asize (adept_,MAXIMUM_DEPT)
     afill (adept_, "")    

     parse(CONFIG_ITM_FILE,CONFIG_DEPT_LINES,adept_)
     
return nil

function getdept(nvar)
local cRetVal := ""
local i
static aDept := {}
static aDesc := {}

  if nVar > 0 .and. nVar <= MAXIMUM_DEPT
     cRetVal := padl(adept_[nvar],4,"0")
  elseif nVar == 100
     if empty(aDept)
       for i := 1 to MAXIMUM_DEPT
           if Dept_Get(padl(adept_[i],4,"0"))         
	         aAdd(aDesc,cDept_Desc())
		    aAdd(aDept,padl(adept_[i],4,"0"))
	      endif
       next i
     endif       

     if len(aDesc) > 18
        i := aLookUp(17, 35, aDesc )
     else
        i := aLookUp(25, 35, aDesc )
     endif

     if i != 0
        cRetVal := aDept[i]
     endif
  endif
   
return cRetVal

function dept_request(cDeptCode,nQty,cDataBuff)
local nPrice  := 0
local cDesc   := ""
local nAmount := 0
local nTot_Amount := 0
local nQty_Total  := 0
local lRetVal := .T.
local out_text := ""

  if Dept_Get(cDeptCode) 
  
     nPrice := val(cDataBuff)
     if config(POS_LALO) == "YES" .and. nPrice < nDept_Lalo()
         ErrorDisp(MSG_D016)    // LALO violation
     elseif config(POS_HALO) == "YES" .and. nPrice > nDept_Halo() 
         ErrorDisp(MSG_D017)    // HALO violation
     else            
           cDesc := cDept_Desc() 
         nAmount := nQty * nPrice
        
         nTOT_Amount := nvr_nSUBtotal() + nAmount
         nQty_total  := nvr_nQTYitems() + nQty

         if nAmount > AMT_LALO .and. nAmount < AMT_HALO .and.;
            nQty_total < TOTQTY_HALO .and. nTOT_Amount < TOTAMT_HALO      

            print_dept(cDesc,nQty,nPrice,nAmount)
            
#ifdef SLIP_PRNT
            if isNonAdd()
               slip_prompt(MSG_D028)
               out_text := "SOS #: "+tran_cCrgo()
               slip_check(out_text, 1)              
               slip_check("OPEN DEPARTMENT") 
               out_text := space(LMARGIN)+trans(nQty,"9999 @   ")+ trans(nPrice,"99,999.99")
               slip_check(out_text,1)
               out_text := cDesc + trans(nAmount, "9,999,999.99")
               slip_check(out_text,1)               
               out_text := dtoc(date()) + ' ' + substr(time(), 1, 5) + ' ' + ;
                           padl(nvr_nTrans(), 6, "0") + '#  ' + subs(nvr_cCashCode(),1,3) +;
                          ' '+ config(POS_TERM_NUM) + chr(10)
               slip_check(out_text, 0)                       
            endif
#endif            
            
            nvr_nSUBtotal(nTOT_Amount) 
            nvr_nQTYitems(nQty_total)

            // add the dept sale to the dept totals
            Term_nData(TR_DEPT_TOT,nAmount)

            tran_cPLU  ( repl("0",PLU_CODE_LEN) )
            tran_cITEM ( repl("0",PLU_ITEM_LEN) )
            tran_cDept ( cDeptCode )
            tran_cPFlg ( "0" )
            tran_cFlag ( OP_OPEN_FLAG )
            tran_cRegM ( "0" ) // Open department is not scanned default "0"
            tran_cPrcM ( "0" ) // No special pricing done...
            tran_cConc ( cDept_Conc() )
            tran_cColo ( "CL" ) // Department no info about colors
            tran_cSize ( "SZ" ) // your guess is as good as mine
            tran_nSale ( nAmount )
            tran_nCntr ( nQty )
#ifdef NON_ADD_ENABLED		  
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

            // display the parameters              
            disp_dept(cDeptCode,cDesc,tran_cClrk(),nQty,nPrice,nAmount)

            // Add this record to the nvcntrl trans file...            
            Update_Trans()

#ifdef DEF_GRAPHICS
            Disp_BoldChar(nvr_nSUBtotal(), "Total Amount")
            Rcpt_Scroll(1, cDesc, nQty, nPrice, tran_cFlag(), 0, 0, 0, 0, tran_cClrk())
#endif
            dept_counter(cDeptCode, nQty, nAmount)
         else
            ErrorDisp(MSG_D013)  
         endif                     
      endif      
  else
     ErrorDisp(MSG_D037)
     lRetVal := .F.
  endif
  
return lRetVal

function disp_dept(cCode,cDesc,cClerk,nQty,nPrice,nAmount)
local out_text

   out_text := pad(("DEPARTMENT "+cCode),20)  
   DISPTEXTXY(1, 1, 0, 0, 0, 0, out_text)
   DISPTEXTXY(2, 1, 0, 0, 0, 0, cDesc )
                
   if nQty != 1
     out_text := trans(nQty,"9999@ ")+ trans(nPrice,"999,999,999.99")
     DISPTEXTXY(3, 1, 0, 0, 0, 0, out_text )
     DISPTEXTXY(0, 0, 0, 0, 1, 1, out_text )
     out_text := subs(cDesc,1,10) + trans(nAmount,"999,999.99")
     DISPTEXTXY(0, 0, 0, 0, 2, 1, out_text )
   else
     out_text := "      "+ trans(nAmount,"999,999,999.99")           
     DISPTEXTXY(3, 1, 0, 0, 2, 1, out_text )             
     DISPTEXTXY(0, 0, 0, 0, 1, 1, cDesc )                       
   endif  
   
   if val(cClerk) > 0
      out_text := "CK:"+subs(cClerk,1,6)+ trans(nAmount ,"9999,999.99")
   else   
      out_text := "         " + trans(nAmount ,"9999,999.99")
   endif      
   
   DISPTEXTXY(4, 1, 0, 0, 0, 0, out_text )
           
#ifdef DEF_DISP1X09
   out_text :=  trans(nAmount ,"9999999.99")
   DISPTEXTXY(0, 0, 1, 1, 0, 0, out_text ) 
#endif           

return nil

function print_dept(cDesc,nQty,nPrice,nAmount)
local out_Text
           
  if nQty != 1
	 // For the Journal            
	 rpt_prnt(0, 1, 0, cDesc, 0)    
	 out_text := space(13)+tran(nQty,"9999@ ") + trans(nPrice ,"999,999.99")
	 rpt_prnt(0, 1, 0, out_text , 0)
	 out_text := space(LMARGIN)+trans(nQty,"9999 @   ")+ trans(nPrice,"99,999.99")
	 rpt_prnt(1, 0, 0, out_text , 0)                                        
  endif            
           
  out_text := cDesc + trans(nAmount, "9,999,999.99")
  rpt_prnt(1, 1, 0, out_text , 0)

return nil

function reprint_dept(cDesc,nQty,nPrice,nAmount)
local out_Text
           
  if nQty != 1
	 out_text := space(LMARGIN)+trans(nQty,"9999 @   ")+ trans(nPrice,"99,999.99")
	 rpt_prnt(1, 0, 0, out_text , 0)                                        
  endif            
           
  out_text := cDesc + trans(nAmount, "9,999,999.99")
  rpt_prnt(1, 0, 0, out_text , 0)

return nil

function cDeptCode( nVar )
local n,cRetVal := ""

     n :=  is_dept(nVar)
 
     if n > 0 .and. n <= MAXIMUM_DEPT
        cRetVal := aDept_[n]
     endif
     
return cRetVal

function formDept(cData)
local cOut := subs(cData,FM_DEP_CODE_OFF,DEP_CODE_LEN)
   cOut += subs(cData,FM_DEP_DESC_OFF,DEP_DESC_LEN)
   cOut += subs(cData,FM_DEP_CONC_OFF,DEP_CONC_LEN)
   cOut += subs(cData,FM_DEP_STTM_OFF,DEP_STTM_LEN)
   cOut += subs(cData,FM_DEP_ENTM_OFF,DEP_ENTM_LEN)
   cOut += subs(cData,FM_DEP_STAT_OFF,DEP_STAT_LEN)
   cOut += ieereal(val(subs(cData,FM_DEP_HALO_OFF,10))* 0.01)
   cOut += ieereal(val(subs(cData,FM_DEP_LALO_OFF,10))* 0.01)
   cOut += ieereal(val(subs(cData,FM_DEP_ADD1_OFF,10))* 0.01)
   cOut += ieereal(val(subs(cData,FM_DEP_ADD2_OFF,10))* 0.01)
   cOut += subs(cData,FM_DEP_DISC_OFF,DEP_DISC_LEN)
   cOut += ieereal(val(subs(cData,FM_DEP_DAMT_OFF,10))* 0.01)
   cOut += subs(cData,FM_DEP_CUST_OFF,DEP_CUST_LEN)
   cOut += subs(cData,FM_DEP_DELT_OFF,DEP_DELT_LEN)
   cOut += space(DEP_TTLS_LEN)     // Dummy data for counters 
return cOut

#ifdef VALIDATE_CONCESS
function validate(lsttl)
local out_text 
local cKey

  tran_init()

    if config(POS_ISLIP_PRN) == "YES" .and. (tran_cFlag() == OP_OPEN_FLAG .or. lsttl .or. tran_cFlag() == OP_NPLU_FLAG .or. tran_cFlag() == OP_NOTF_FLAG )
       A_RJS_FEED(1, 1, 0, 1)              
       MsgAreaDisp("Insert Slip & Press <VALID> key to Validate or <CLR> to exit")
       cKey := input()
       if cKey == VALIDATE
          // validate first, before printing 
          if lsttl
             out_text := "SUBTOTAL CONCESSION"
             out_text += trans(nvr_nQTYItems(),"999 ITEMS") + trans(nvr_nSUBtotal(),"99,999.99 TTL.")
          else
             out_text := "CONCESSIONAIRE ITEM"
             out_text += trans(tran_nQty(),"999@ ") + trans(tran_nPrice(),"99,999.99 ")
             out_text += ' ' + trans(tran_nSale(),"*****9.99") 
          endif   
          out_text += ' ' + dtoc(date()) 
          out_text += ' ' + subs(nvr_cCashCode(),1,3) 
          out_text += ' ' + padl(nvr_nTrans(), 6, "0") + '#'
          out_text += ' ' + config(POS_TERM_NUM)

          valid_prnt(out_text, 1)
          A_RJS_FEED(1, 1, 0, 1)
          MsgAreaDisp("Remove Sales Slip & Press <Enter> key to Continue") 
          while input() != ENTER ;enddo
       endif  
    endif
       
return nil           
#endif
/*-----------eof-----------------*/