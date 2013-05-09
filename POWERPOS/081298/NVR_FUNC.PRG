#include "config.ch"
#include "nvr_file.ch"
#include "cashier.ch"
#include "powerpos.ch"

#ifdef DEF_GRAPHICS
  #include "grfx_all.ch"
#endif

/* ***************** static memory variables for nvcntrl file ********** */
static mCRC_Code, mSTS_Code, mCSH_Code, mUSD_Rate
static mPHP_Rate, mTRN_trans, mITM_item, mQTY_Qty, mSTT_total,mPOL_total
static mSUS_level, mSWP_level, mITP_level, mTRP_level, mTRNG_mode
static mFMF_Code

/* ***************** static memory variables for trans file ************ */
static mTran_Req,mTran_Pflg,mTran_Flag,mTran_PrcM,mTran_Sale,mTran_Cntr
/* ********************************************************************* */
static mTran_PLU,mTran_Item,mTran_Dept,mTran_Regm,mTran_Conc,mTran_Colo
static mTran_Size,mTran_Clrk,mTran_Desc,mTran_Pric,mTran_Qty
static mTran_Crgo,mTran_Prlv,mTran_Resv
/* ********************************************************************* */
static mTran_Crg1,mTran_Crg2,mTran_Crg3,mTran_Crg4

/* ***************** for display only when in graphics mode ************ */ 

function Cntrl_init()
local cntrl_line  :=  get_cntrl()

   mCRC_Code   := subs(cntrl_line, NVR_CRC_OFF, NVR_CRC_LEN) 
   
   mSTS_Code   := subs(cntrl_line, NVR_STS_OFF, NVR_STS_LEN) 
   
   mCSH_Code   := subs(cntrl_line, NVR_CSH_OFF, NVR_CSH_LEN) 

   mUSD_Rate   := subs(cntrl_line, NVR_USD_OFF, NVR_USD_LEN)

   mPHP_Rate   := subs(cntrl_line, NVR_PHP_OFF, NVR_PHP_LEN)

   mTRN_trans  := subs(cntrl_line, NVR_TRN_OFF, NVR_TRN_LEN)    

   mITM_item   := subs(cntrl_line, NVR_ITM_OFF, NVR_ITM_LEN)

   mQTY_Qty    := subs(cntrl_line, NVR_QTY_OFF, NVR_QTY_LEN)   
   
   mSTT_total  := subs(cntrl_line, NVR_STT_OFF, NVR_STT_LEN)

   mSUS_level  := subs(cntrl_line, NVR_SUS_OFF, NVR_SUS_LEN)       

   mSWP_level  := subs(cntrl_line, NVR_SWP_OFF, NVR_SWP_LEN)    

   mITP_level  := subs(cntrl_line, NVR_ITP_OFF, NVR_ITP_LEN)
 
   mTRP_level  := subs(cntrl_line, NVR_TRP_OFF, NVR_TRP_LEN)

   mTRNG_Mode   := subs(cntrl_line, NVR_RES_OFF, NVR_RES_LEN)

   mFMF_Code   := subs(cntrl_line, NVR_FMF_OFF, NVR_FMF_LEN)
   
   /**** The NVR TRAN Buffer variables ****/
   tran_init()
   
return nil

function power_up()
local cntrl_line,cTransline 
local drcpt_date := DATE()
local crcpt_time := TIME()
local nThis_item, nStatus 
local cCashpath,frame,cBuffer:= ""
local i

// for display in case of power failure recovery...
local nSubAmount := nvr_nSUBTotal()
local out_text
 
#ifdef DEBUG
   scroll()
   ?
   ? "Contents of Control file  --------------------------------"
   ? "Control file CRC16 value " + mCRC_Code
   ? "Control file status      " + mSTS_Code
   ? "Cashier code             " + mCSH_Code
   ? "USD Conversion Rate      " + mUSD_Rate
   ? "PHP Conversion Rate      " + mPHP_Rate
   ? "Current Transaction no.  " + mTRN_Trans
   ? "Current item no.         " + mITM_Item
   ? "Current total quantity   " + mQTY_Qty
   ? "Current subtotal         " + mSTT_total
   ? "Suspended level          " + mSUS_level
   ? "Swapped level            " + mSWP_level   
   ? "Item purging level       " + mITP_level
   ? "Trans. purging level     " + mTRP_level
   ? "Reserved for future use  " + mTRNG_Mode 
   ? "FM_trans last update     " + mFMF_Code
   ?    
#endif
   
   // We just have to make sure that there is a cashier code on duty to 
   // make some one accountable for the data in NVCNTRL file...
   if mCSH_Code != "OFFOFF" .and. Cash_Recover(mCSH_Code)

         // now this is the hard part.. Going to the previous state
         // exactly the way it is before stack-up. 
         *----> note all transaction must be accounted for no more no less !!!

         out_text :=  space(10)+"SUBTOTAL"+ space(1) + trans(nSubAmount, "99,999,999.99")

         A_RJS_FEED(1, 0, 0, 1)
         A_RJS_PRNT(1, 0, 0, out_text , 0)     

         out_text :=  "SUBTOTAL"+ space(11) + trans(nSubAmount, "99,999,999.99")
         // on journal...
         A_RJS_FEED(0, 1, 0, 1)
         A_RJS_PRNT(0, 1, 0, out_text , 0)

#ifdef DEF_DISP1X09
         // customer display 1 (1x9)
         // no. plus comma or period occupies only 1 space
         out_text := trans(nSubAmount, "9999999.99")
         DISPTEXTXY(0, 0, 1, 1, 0, 0, out_text )
#endif                    

         if nSubAmount == 0
           return (mCSH_Code != "OFFOFF")
         endif   
	 
         // customer display 2 (2X20)
         disp_clr()
         DISPTEXTXY(2, 1, 0, 0, 2, 1, "BAL DUE :           ")
         out_text := trans(nSubAmount, "999,999.99")
         DISPTEXTXY(3, 11, 0, 0, 2, 11, out_text)

         // Now get all transaction records and put them in display array
         for i := 1 to val(mITM_item)
             Disp_tran( i )                                                
             #ifdef DEF_GRAPHICS
               Disp_LastPage(i)
             #endif
         next i                     
         keylock(1)
         
   endif   

return (mCSH_Code != "OFFOFF")

static function Update_Cntrl()
local cCntrl_line 

#ifdef DEBUG 
 if len(mCRC_Code) != NVR_CRC_LEN
    DispStatus("Mismatch CRC length")
 endif   
 if len(mSTS_Code) != NVR_STS_LEN
    DispStatus("Mismatch STS length")
 endif   
 if len(mCSH_Code) != NVR_CSH_LEN
    DispStatus("Mismatch CSH length")
 endif   
 if len(mUSD_Rate) != NVR_USD_LEN
    DispStatus("Mismatch DAT length")
 endif   
 if len(mPHP_RATE) != NVR_PHP_LEN
    DispStatus("Mismatch TIM length")
 endif   
 if len(mTRN_trans) != NVR_TRN_LEN
    DispStatus("Mismatch TRN length")
 endif   
 if len(mITM_item) != NVR_ITM_LEN
    DispStatus("Mismatch ITM length")
 endif   
 if len(mQTY_Qty) != NVR_QTY_LEN
    DispStatus("Mismatch QTY length")
 endif   
 if len(mSTT_total) != NVR_STT_LEN
    DispStatus("Mismatch STT length")
 endif   
 if len(mSUS_level) != NVR_SUS_LEN
    DispStatus("Mismatch SUS length")
 endif   
 if len(mSWP_level) != NVR_SWP_LEN
    DispStatus("Mismatch SWP length")
 endif   
 if len(mITP_level) != NVR_ITP_LEN
    DispStatus("Mismatch ITP length")
 endif               
 if len(mTRP_level) != NVR_TRP_LEN
    DispStatus("Mismatch TRP length")
 endif               
 if len(mTRNG_Mode) != NVR_RES_LEN
    DispStatus("Mismatch RES length")
 endif               
 if len(mFMF_Code) != NVR_FMF_LEN
    DispStatus("Mismatch FMF length")
 endif                  

#endif

    cCntrl_line := mCRC_Code +;
                   mSTS_Code +;
                   mCSH_Code +;
                   mUSD_Rate +;
                   mPHP_Rate +;
                   mTRN_trans+;
                   mITM_item +;
                   mQTY_Qty  +;
                   mSTT_total+;
                   mSUS_level+;
                   mSWP_level+;
                   mITP_level+;
                   mTRP_level+;
                   mTRNG_Mode +;
                   mFMF_Code

    if len(cCntrl_line) != NVR_CNTRL_SIZE    
      DispStatus("Error creating NVCNTRL file")
    endif    


    put_cntrl(cCntrl_line)               
    
        
return nil

// transaction number
function nvr_nTrans(lVar)
local nVal := val(mTRN_trans)
   if !empty(lVar)           // if 0 or NIL stay as is else increment 
      nVal := if(nVal < 999999,nVal+1,1)
      mTRN_trans := padl(ltrim(str(nVal)) ,NVR_TRN_LEN, "0")
      Update_Cntrl()
   endif    
return val(mTRN_trans)

function nvr_nTranReset()
  mTRN_trans := padl(1,NVR_TRN_LEN, "0")
  Update_Cntrl()  
return val(mTRN_trans)

// status of transaction if inside transaction.
function nvr_lStatus(lVar)

   if lVar != NIL
      mSTS_Code := if(lVar,"1","0")
      Update_Cntrl()
   endif         
      
return (mSTS_Code == "1")

// cashier code len is sex
function nvr_cCashCode(cVar)
   if cVar != NIL
      mCSH_Code := pad(cVar ,NVR_CSH_LEN)
      Update_Cntrl()      
   endif
return mCSH_Code      

// cashier name not in nvram but initialized at sign on...
function nvr_cCashName(cVar)
static name := ""
  if cVar != NIL
     name := pad(alltrim(cVar),CASH_NAME_LEN)
  endif
return name

// No of items in the transaction.
function nvr_nQTYItems(nVar) 
   if nVar != nil
      mQTY_Qty := ieereal(nVar)
      Update_Cntrl()
   endif
return realiee(mQTY_Qty)

// Total amt sales in the transaction
function nvr_nSUBtotal(nVar)  
  if nVar != nil
     mSTT_total := ieereal(nVar)
     Update_Cntrl()
  endif
return realiee(mSTT_total)

// Total No of records in the NVR tran file
function nvr_nITMitem(nVar)  
  if nVar != nil
     mITM_item := padl(nVar,NVR_ITM_LEN,"0")
     Update_Cntrl()
  endif
return val(mITM_item)

function nvr_nSUSlevel(nVar)
   if nVar != nil
      mSUS_level := pad(nVar,NVR_SUS_LEN)
      Update_Cntrl()      
   endif   
return val(mSUS_level)

function nvr_nSWPlevel(nVar)
   if nVar != nil
      mSWP_level := pad(nVar,NVR_SWP_LEN)
      Update_Cntrl()      
   endif   
return val(mSWP_level)

function nvr_lTRNG_Mode(lVar)
   if valtype(lVar) == "L"
      mTRNG_Mode := if(lVar,"1","0")
      Update_Cntrl()      
   endif   
return (mTRNG_Mode == "1")

function nvr_nUSD_Rate(nVar)
	if nVar != nil
		mUSD_Rate := ieereal(nVar)
   		Update_Cntrl()
	endif
return realiee(mUSD_Rate)

function nvr_nPHP_Rate(nVar)
	if nVar != nil
	    mPHP_Rate := ieereal(nVar)
	    Update_Cntrl()
	endif
return realiee(mPHP_Rate)
/************************** mTransaction functions **************************/

function tran_cPLU(cVar)
  if cVar != NIL
     mTran_PLU := padl(cVar,TRAN_PLU_LEN,"0") 
  endif
return mTran_PLU

function tran_cItem(cVar)
  if cVar != NIL
      mTran_Item := padl(cVar,TRAN_ITEM_LEN,"0")
  endif
return mTran_Item

function tran_cDept(cVar)
  if cVar != NIL
      mTran_Dept := padl(cVar,TRAN_DEPT_LEN, "0")
  endif
return mTran_Dept

function tran_cPFlg(cVar)
  if cVar != NIL
      mTran_Pflg := padl(cVar,TRAN_PFLG_LEN,"0")
  endif      
return mTran_Pflg

function tran_cFlag(cVar)
  if cVar != NIL
      mTran_Flag := padl(cVar,TRAN_FLAG_LEN,"0")
  endif      
return mTran_Flag

function tran_cRegM(cVar)
  if cVar != NIL
      mTran_RegM := padl(cVar,TRAN_REGM_LEN,"0")
  endif
return mTran_RegM

function tran_cPrcM(cVar)
  if cVar != NIL
      mTran_PrcM := padl(cVar,TRAN_PRCM_LEN,"0")
  endif
return mTran_PrcM

function tran_cConc(cVar)
  if cVar != NIL
      mTran_Conc := padl(cVar,TRAN_CONC_LEN)
  endif
return mTran_Conc

function tran_cColo(cVar)
  if cVar != NIL
      mTran_Colo := pad(cVar,TRAN_COLO_LEN)
  endif
return mTran_Colo

function tran_cSize(cVar)
  if cVar != NIL
      mTran_Size := pad(cVar,TRAN_SIZE_LEN)
  endif
return mTran_Size

function tran_nSale(nVar)
  if nVar != NIL
      mTran_Sale := ieereal(nVar)
  endif
return realiee(mTran_Sale)

function tran_nCntr(nVar)
  if nVar != NIL
      mTran_Cntr := ieereal(nVar)
  endif
return realiee(mTran_Cntr)

function tran_cClrk(cVar)
  if cVar != NIL
      mTran_Clrk := padl(cVar,TRAN_CLRK_LEN,"0")
  endif
return mTran_Clrk

function tran_cCrgo(cVar)
  if cVar != NIL
      mTran_Crgo := padl(cVar,TRAN_CRGO_LEN,"0")
  endif
return mTran_Crgo  

function tran_cDesc(cVar)
  if cVar != NIL
      mTran_Desc := pad(cVar,TRAN_DESC_LEN)
  endif
return mTran_Desc

function tran_nPric(nVar)
  if nVar != NIL
     mTran_Pric := ieereal(nVar)
  endif   
return realiee(mTran_Pric)

function tran_nQty(nVar)
  if nVar != NIL
     mTran_Qty := ieereal(nVar)
  endif
return realiee(mTran_Qty )

function tran_cCrg1(cVar)
  if cVar != NIL
      mTran_Crg1 := padl(cVar,TRAN_CRG1_LEN,"0")
  endif
return mTran_Crg1  

function tran_cCrg2(cVar)
  if cVar != NIL
      mTran_Crg2 := padl(cVar,TRAN_CRG2_LEN,"0")
  endif
return mTran_Crg2  

function tran_cCrg3(cVar)
  if cVar != NIL
      mTran_Crg3 := padl(cVar,TRAN_CRG3_LEN,"0")
  endif
return mTran_Crg3
  
function tran_cCrg4(cVar)
  if cVar != NIL
      mTran_Crg4 := padl(cVar,TRAN_CRG4_LEN,"0")
  endif
return mTran_Crg4  

// if this function is called, a record is added to the 
// nvr transaction file 

function Update_Trans()
local curr_tran := nvr_nITMitem()
local cTrans_line 

    cTrans_line := mTran_Req  + ;
                   mTran_PFlg + ;
                   mTran_Flag + ;
                   mTran_PrcM + ;
                   mTran_Sale + ; 
                   mTran_Cntr                    
    if !( mTran_Flag $ "123456789Z" )   
    
      cTrans_line += mTran_PLU  + ;
                     mTran_Item + ;
                     mTran_Dept + ;                   
                     mTran_Regm + ;                   
                     mTran_Conc + ;
                     mTran_Colo + ;
                     mTran_Size + ;
                     mTran_Clrk + ;
                     mTran_Desc + ;
                     mTran_Pric + ;
                     mTran_Qty  + ;                                       
                     mTran_Crgo + ;
                     mTran_Prlv + ;
                     mTran_Resv

    else
      cTrans_line += mTran_Crg1 + ;                   
                     mTran_Crg2 + ;
                     mTran_Crg3 + ;
                     mTran_Crg4 
    endif                 


  ?  "mTran_Flag:----->"
  ?? mTran_Flag  

#ifdef DEBUG  
  check_size()
  if len(cTrans_line) != NVR_TRANS_SIZE    
      DispStatus("Error TRANS record length mismatch")
  endif       
#endif  

  nvr_nITMitem(curr_tran+1)
  
  ? "Item to write : "
  ?? nvr_nITMitem()
    
  put_trans(nvr_nITMItem(),cTrans_line)   
  
  offline(form_tran(cTrans_line))

#ifdef NON_ADD_ENABLED  
  /**** The NVR TRAN Buffer variables ****/
  isClerk(.F.)
  isNonAdd(.F.)
#endif  
       
return nil

function edit_trans(nVar)
local cTrans_line 

 if nVar > 0 .and. nVar <= nvr_nITMitem()
 
    cTrans_line := mTran_Req  + ;
                   mTran_PFlg + ;
                   mTran_Flag + ;
                   mTran_PrcM + ;
                   mTran_Sale + ;
                   mTran_Cntr                    
    if !( mTran_Flag $ "0123456789Z" ) 
      cTrans_line += mTran_PLU  + ;
                     mTran_Item + ;
                     mTran_Dept + ;                   
                     mTran_Regm + ;                   
                     mTran_Conc + ;
                     mTran_Colo + ;
                     mTran_Size + ;
                     mTran_Clrk + ;
                     mTran_Desc + ;
                     mTran_Pric + ;
                     mTran_Qty  + ;                                       
                     mTran_Crgo + ;
                     mTran_Prlv + ;
                     mTran_Resv
    else
      cTrans_line += mTran_Crg1 + ;                   
                     mTran_Crg2 + ;
                     mTran_Crg3 + ;
                     mTran_Crg4 
    endif                 

     ?  "mTran_Flag:----->"
     ?? mTran_Flag  

#ifdef DEBUG  
     check_size()
  if len(cTrans_line) != NVR_TRANS_SIZE    
      DispStatus("Error TRANS record length mismatch")
  endif     
#endif     
  
     ? "Item to edit : "+str(nVar)
    
     put_trans(nVar,cTrans_line)   
     
     offline(form_tran(cTrans_line))     
#ifdef NON_ADD_ENABLED
     /**** The NVR TRAN Buffer variables ****/
     isClerk(.F.)     
     isNonAdd(.F.)
#endif	
  else
   ? "error editing the transaction record..."
  endif  

return nil


#ifdef DEBUG  
static function check_size()

if len(mTran_Req) != TRAN_REQ_LEN
   DispStatus("mTran_Req len Mis-Match")
endif

if len(mTran_PFlg) != TRAN_PFLG_LEN
   DispStatus("mTran_PFlg len Mis-Match")
endif   

if len(mTran_Flag) != TRAN_FLAG_LEN
   DispStatus("mTran_Flag len Mis-Match")
endif

if len(mTran_PrcM) != TRAN_PRCM_LEN
   DispStatus("mTran_PrcM len Mis-Match")
endif

if len(mTran_Sale) != TRAN_SALE_LEN
   DispStatus("mTran_Sale len Mis-Match")
endif

if len(mTran_Cntr) != TRAN_CNTR_LEN
   DispStatus("mTran_Cntr len Mis-Match")
endif 
   
if len(mTran_PLU) != TRAN_PLU_LEN
   DispStatus("mTran_PLU len Mis-Match")
endif 

if len(mTran_Item) != TRAN_ITEM_LEN
   DispStatus("mTran_Item len Mis-Match")
endif

if len(mTran_Dept) != TRAN_DEPT_LEN
   DispStatus("mTran_Dept len Mis-Match")
endif 

if len(mTran_RegM) != TRAN_REGM_LEN
   DispStatus("mTran_PLU len Mis-Match")
endif 

if len(mTran_Conc) != TRAN_CONC_LEN
   DispStatus("mTran_Conc len Mis-Match")
endif 

if len(mTran_Colo) != TRAN_COLO_LEN
   DispStatus("mTran_Colo len Mis-Match")
endif

if len(mTran_Size) != TRAN_SIZE_LEN
   DispStatus("mTran_Size len Mis-Match")
endif 

if len(mTran_Clrk) != TRAN_CLRK_LEN
   DispStatus("mTran_Clrk len Mis-Match")
endif

if len(mTran_DESC) != TRAN_DESC_LEN
   DispStatus("mTran_Desc len Mis-Match")
endif 
if len(mTran_Pric) != TRAN_PRIC_LEN
   DispStatus("mTran_Pric len Mis-Match")
endif

if len(mTran_Qty) != TRAN_QTY_LEN
   DispStatus("mTran_Qty len Mis-Match")
endif 

if len(mTran_Crgo) != TRAN_CRGO_LEN
   DispStatus("mTran_Crgo len Mis-Match")
endif

if len(mTran_Prlv) != TRAN_PRLV_LEN
   DispStatus("mTran_Prlv len Mis-Match")
endif

if len(mTran_Resv) != TRAN_RESV_LEN
   DispStatus("mTran_Rsrv len Mis-Match")
endif


return nil
  
#endif    
  
function tran_init(nVar)
local cBuffer 

  if empty(nVar) .or. nVar == NIL
      nVar := nvr_nITMItem()
  endif

  if nVar > 0 .and. nVar <= nvr_nITMItem()      
  
   cBuffer := get_trans(nVar)

   /**** The NVR TRAN Buffer variables ****/
   mTran_Req  := subs(cBuffer,TRAN_REQ_OFF,TRAN_REQ_LEN) 
   mTran_Pflg := subs(cBuffer,TRAN_PFLG_OFF,TRAN_PFLG_LEN)
   mTran_Flag := subs(cBuffer,TRAN_FLAG_OFF,TRAN_FLAG_LEN) 
   mTran_PrcM := subs(cBuffer,TRAN_PRCM_OFF,TRAN_PRCM_LEN) 
   mTran_Sale := subs(cBuffer,TRAN_SALE_OFF,TRAN_SALE_LEN) 
   mTran_Cntr := subs(cBuffer,TRAN_CNTR_OFF,TRAN_CNTR_LEN)             

   if !(mTran_Flag $ "123456789Z")
      mTran_PLU  := subs(cBuffer,TRAN_PLU_OFF,TRAN_PLU_LEN) 
      mTran_Item := subs(cBuffer,TRAN_ITEM_OFF,TRAN_ITEM_LEN) 
      mTran_Dept := subs(cBuffer,TRAN_DEPT_OFF,TRAN_DEPT_LEN)       
      mTran_RegM := subs(cBuffer,TRAN_REGM_OFF,TRAN_REGM_LEN) 
      mTran_Conc := subs(cBuffer,TRAN_CONC_OFF,TRAN_CONC_LEN) 
      mTran_Colo := subs(cBuffer,TRAN_COLO_OFF,TRAN_COLO_LEN) 
      mTran_Size := subs(cBuffer,TRAN_SIZE_OFF,TRAN_SIZE_LEN) 
      mTran_Clrk := subs(cBuffer,TRAN_CLRK_OFF,TRAN_CLRK_LEN) 
      mTran_Desc := subs(cBuffer,TRAN_DESC_OFF,TRAN_DESC_LEN)  
      mTran_Pric := subs(cBuffer,TRAN_PRIC_OFF,TRAN_PRIC_LEN)  
      mTran_Qty  := subs(cBuffer,TRAN_QTY_OFF,TRAN_QTY_LEN)        
      mTran_Crgo := subs(cBuffer,TRAN_CRGO_OFF,TRAN_CRGO_LEN) 
      mTran_Prlv := subs(cBuffer,TRAN_PRLV_OFF,TRAN_PRLV_LEN) 
      mTran_Resv := subs(cBuffer,TRAN_RESV_OFF,TRAN_RESV_LEN) 

/* ********************************************* */

      mTran_Crg1 := repl("0",TRAN_CRG1_LEN)       
      mTran_Crg2 := repl("0",TRAN_CRG2_LEN)       
      mTran_Crg3 := repl("0",TRAN_CRG3_LEN)       
      mTran_Crg4 := repl("0",TRAN_CRG4_LEN)               
      
   else
      mTran_Crg1 := subs(cBuffer,TRAN_CRG1_OFF,TRAN_CRG1_LEN) 
      mTran_Crg2 := subs(cBuffer,TRAN_CRG2_OFF,TRAN_CRG2_LEN) 
      mTran_Crg3 := subs(cBuffer,TRAN_CRG3_OFF,TRAN_CRG3_LEN) 
      mTran_Crg4 := subs(cBuffer,TRAN_CRG4_OFF,TRAN_CRG4_LEN) 

/* ********************************************* */

      mTran_PLU  := space(TRAN_PLU_LEN) 
      mTran_Item := space(TRAN_ITEM_LEN) 
      mTran_Dept := repl("0",TRAN_DEPT_LEN)    
      mTran_RegM := space(TRAN_REGM_LEN) 
      mTran_Conc := repl("0",TRAN_CONC_LEN) 
      mTran_Colo := space(TRAN_COLO_LEN) 
      mTran_Size := space(TRAN_SIZE_LEN) 
      mTran_Clrk := repl("0",TRAN_CLRK_LEN)   
      mTran_Desc := space(TRAN_DESC_LEN)  
      mTran_Pric := ieereal(0)
      mTran_Qty  := ieereal(0)         
      mTran_Crgo := repl("0",TRAN_CRGO_LEN) 
      mTran_Prlv := repl("0",TRAN_PRLV_LEN)
      mTran_Resv := repl("0",TRAN_RESV_LEN)
      
   endif               
 else
 
   mTran_Req  := space(TRAN_REQ_LEN)    
   mTran_Pflg := repl("0",TRAN_PFLG_LEN)
   mTran_Flag := space(TRAN_FLAG_LEN) 
   mTran_PrcM := space(TRAN_PRCM_LEN)   
   mTran_Sale := ieereal(0)
   mTran_Cntr := ieereal(0)   

   mTran_PLU  := space(TRAN_PLU_LEN) 
   mTran_Item := space(TRAN_ITEM_LEN) 
   mTran_Dept := repl("0",TRAN_DEPT_LEN)    
   mTran_RegM := space(TRAN_REGM_LEN) 
   mTran_Conc := repl("0",TRAN_CONC_LEN) 
   mTran_Colo := space(TRAN_COLO_LEN) 
   mTran_Size := space(TRAN_SIZE_LEN) 
   mTran_Clrk := repl("0",TRAN_CLRK_LEN)   
   mTran_Desc := space(TRAN_DESC_LEN)  
   mTran_Pric := ieereal(0)
   mTran_Qty  := ieereal(0)         
   mTran_Crgo := repl("0",TRAN_CRGO_LEN) 
   mTran_Prlv := repl("0",TRAN_PRLV_LEN)
   mTran_Resv := repl("0",TRAN_RESV_LEN)

/* ********************************************* */

   mTran_Crg1 := repl("0",TRAN_CRG1_LEN)       
   mTran_Crg2 := repl("0",TRAN_CRG2_LEN)       
   mTran_Crg3 := repl("0",TRAN_CRG3_LEN)       
   mTran_Crg4 := repl("0",TRAN_CRG4_LEN)               
    
 endif  
   
return nil

function disp_tran(nVar)

#ifdef DEBUG
  if nVar != NIL
    if nVar < 1
       ? " disp_tran() parameter underflow "
    elseif nVar > nvr_nITMitem()
       ? " disp_tran() parameter overflow "
    endif      
  endif
#endif

  if !empty(nVar) .and. nVar <= nvr_nITMitem()
       tran_init(nVar)
  endif          
           
  ? "Display Flag "
  ?? mTran_Flag
                      
  do case 
     case mTran_Flag == "N" .or. mTran_Flag == "P" // Normal PLU transaction
          disp_plu(mTran_PLU,mTran_Desc,mTran_Dept,mTran_Clrk,realiee(mTran_Qty),realiee(mTran_Pric),realiee(mTran_Sale))
     case mTran_Flag == "M"
          disp_dept(mTran_Dept,mTran_Desc,mTran_Clrk,realiee(mTran_Qty),realiee(mTran_Pric),realiee(mTran_Sale))
     case mTran_Flag == "V"  
          disp_void(realiee(mTran_Sale),mTran_Desc,realiee(mTran_Qty),realiee(mTran_Pric))
     case mTran_Flag == "G" // Mgr's Void
          disp_void(realiee(mTran_Sale),mTran_Desc,realiee(mTran_Qty),realiee(mTran_Pric))          
     case mTran_Flag == "R" // return items
          disp_ret(mTran_Flag,mTran_PLU,mTran_Desc,realiee(mTran_Qty),realiee(mTran_Pric),realiee(mTran_Sale) )     
     case mTran_Flag == "D" 
          disp_disc(realiee(mTran_Qty),realiee(mTran_Pric),mTran_Desc)
     case mTran_Flag == "S"          
          disp_Sdisc(realiee(mTran_Cntr),realiee(mTran_Sale))
     case mTran_Flag == OP_ADON_FLAG
          disp_Addon(realiee(mTran_Cntr),realiee(mTran_Sale))          
     case mTran_Flag == OP_OINC_FLAG
          disp_OINK(realiee(mTran_Pric))                          
     case mTran_Flag == OP_RFND_FLAG
          disp_refund(mTran_Pflg,mTran_PLU,mTran_Desc,mTran_Dept,mTran_Clrk,realiee(mTran_Qty),realiee(mTran_Pric),realiee(mTran_Sale))          
     case mTran_Flag == OP_TRCL_FLAG     
          disp_cancel()          
     case mTran_Flag $ "1234567890Z"
          disp_paym(realiee(mTran_Sale),realiee(mTran_Cntr),val(mTran_Prcm)) 
  endcase     
                 
return nil        

function payment( nPaymAmt, nBalance, nType, cAcct1_Code, cAcct2_Code,cAcct3_Code)
local cTran_Flag 
static n := 0

    nPO_Limit(nPO_Limit() - nPaymAmt + nBalance)

    if nBalance > 0
       n := if( n < 9, n + 1, 9)
       cTran_Flag := pad( n , 1 )
      if nType == 999
         cTran_Flag := "999"
      endif  
    else
       n := 0
       cTran_Flag := "Z" 
    endif      
    
    tran_cFlag(cTran_Flag)                     // flag
    tran_cPrcM(padl(nType,TRAN_PRCM_LEN,"0"))
    tran_nSale(nPaymAmt)                       // Sale    
    tran_nCntr(nBalance)                       // Balance

    if cAcct1_Code != NIL
      tran_cCrg1(cAcct1_Code)                  // ist cargo
    endif  
    if cAcct2_Code != NIL
      tran_cCrg2(cAcct2_Code)                  // 2nd cargo
    endif          
    if cAcct3_Code != NIL      
      tran_cCrg3(cAcct3_Code)                  // 3rd cargo    
    endif  
    tran_cCrg4(padl(nvr_nQTYitems(),TRAN_CRG4_LEN),"0")   // 4th cargo
    
    Update_trans()

return nil

static function disp_paym(  nPaymAmt, nBalance, nType )
local out_text

 if nType != 999

   if nType == 0 
      out_text := "CASH      " + trans (nPaymAmt, "999,999.99")
   elseif nType > 0 
      out_text := pad(GetMDesc(nType),10) + trans(nPaymAmt, "999,999.99")
   endif   
   DISPTEXTXY(1,1,0,0,1,1, out_text)
   DiSPTEXTXY(2,1,0,0,2,1, "BALANCE DUE :       ")
   out_text := trans(nBalance,"999,999.99")
   DISPTEXTXY(3,1,0,0,0,0, padl(out_text,20) )
   DISPTEXTXY(4,1,0,0,0,0, "                    ")

 endif  

return nil   


function print_bill(nvar)

#ifdef DEBUG
  if nVar != NIL
    if nVar < 1
       ? " disp_tran() parameter underflow "
    elseif nVar > nvr_nITMitem()
       ? " disp_tran() parameter ovefflow "
    endif      
  endif
#endif

  if !empty(nVar) .and. nVar <= nvr_nITMitem()
       tran_init(nVar)
  endif          
         
/*
  ? "Display Flag "
  ?? mTran_Flag
*/  
                      
  do case 
     case mTran_Flag == "N" .or. mTran_Flag == "P" // Normal PLU transaction
          reprint_plu(mTran_PLU,realiee(mTran_Qty),realiee(mTran_Pric),realiee(mTran_Sale),mTran_Desc)
     case mTran_Flag == "M"
          reprint_dept(mTran_Desc,realiee(mTran_Qty),realiee(mTran_Pric),realiee(mTran_Sale))
     case mTran_Flag == "V"  
          reprint_void(mTran_PFlg,realiee(mTran_Sale),mTran_Desc,realiee(mTran_Qty),realiee(mTran_Pric),.F.)
     case mTran_Flag == "G" // Mgr's Void
          reprint_void(mTran_PFlg,realiee(mTran_Sale),mTran_Desc,realiee(mTran_Qty),realiee(mTran_Pric),.T.)
     case mTran_Flag == "R" // return items
          reprint_ret(mTran_Flag,mTran_PLU,mTran_Desc,realiee(mTran_Qty),realiee(mTran_Pric),realiee(mTran_Sale) )     
     case mTran_Flag == "D"            
          reprint_Idisc(realiee(mTran_Qty),realiee(mTran_Pric))
     case mTran_Flag == "S"          
          reprint_SDisc(realiee(mTran_Cntr),realiee(mTran_Sale))
     case mTran_Flag == OP_ADON_FLAG
          reprint_Addon(realiee(mTran_Cntr),realiee(mTran_Sale))                    
     case mTran_Flag == OP_OINC_FLAG
          reprint_OINK(realiee(mTran_Pric))                          
     case mTran_Flag $ "1234567890Z"
          reprint_paym(realiee(mTran_Sale),realiee(mTran_Cntr),val(mTran_Prcm),mTran_Crg1,mTran_Crg2)
  endcase     

return nil

function reprint_paym(nPayAmt,nBalance,nType,cCode1,cCode2)
local out_text

  // POS printer...
  // skip one line...
  A_RJS_FEED(1, 0, 0, 1)        

  if nType == 0 
         out_text := "CASH" + space(18) + trans(nPayAmt, "999,999.99") + chr(10)
         A_RJS_PRNT(1, 0, 0, out_text, 0)
         out_text := "SUBTOTAL  " + space(12) + trans(nPayAmt+nBalance, "999,999.99") + chr(10) 
         A_RJS_PRNT(1, 0, 0, out_text, 0)
         out_text := "BAL. DUE  " + space(12) + ;
                                         trans(nBalance, "999,999.99") + chr(10) 
         A_RJS_PRNT(1, 0, 0, out_text, 0)
         A_RJS_FEED(1, 0, 0, 1)
  elseif GetMType(nType) == "0"
    out_text := "Acct# " + cCode1  
    A_RJS_PRNT(1, 0, 0, out_text, 0)

    out_text := pad(GetMDesc(nType),22) + trans(nPayAmt,"999,999.99")
    A_RJS_PRNT(1, 0, 0, out_text, 0 )                     

    out_text := "SUBTOTAL  " + space(12) + trans(nPayAmt+nBalance, "999,999.99") + chr(10) 
    A_RJS_PRNT(1, 0, 0, out_text, 0)          

    out_text := "BAL. DUE  " + space(12) + trans(nBalance, "999,999.99") + chr(10) 
    A_RJS_PRNT(1, 0, 0, out_text, 0)                
  else  
    out_text := GetMDesc(nType)+" No.:" + cCode1  
         A_RJS_PRNT(1, 0, 0, out_text, 0)

         if !empty(cCode2) 
                out_text := "Acct#" + cCode2 
                A_RJS_PRNT(1, 0, 0, out_text, 0)          
         endif  

         out_text := pad(GetMDesc(nType),22) + trans(nPayAmt,"999,999.99")
         A_RJS_PRNT(1, 0, 0, out_text, 0 )                     

         out_text := padl("SUBTOTAL ",22) + trans(nPayAmt-nBalance, "999,999.99") + chr(10) 
         A_RJS_PRNT(1, 0, 0, out_text, 0)          

         out_text := padl("BAL. DUE ",22) + trans(nBalance, "999,999.99") + chr(10) 
         A_RJS_PRNT(1, 0, 0, out_text, 0)              
  endif  
   
return nil

* ------- eof () -------->

