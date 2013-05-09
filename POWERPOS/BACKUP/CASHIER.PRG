#include "pfl_clip.ch"
#include "fileio.ch"
#include "cashier.ch"
#include "config.ch"
#include "keymap.ch"
#include "file_acc.ch"
#include "terminal.ch"
#include "Message.ch"
#include "spec_key.ch"

#define TEMP_BMPFILE  "Powerpos.bmp"

#define SET_REC  1

#define CASHIER_FILE     (subs(config(POS_NVRAM_DRV),1,1)+":\CASHIER.POS")
#define LOCAL_CASH_FILE  GetLocal_path()+"CASHIER.LOC"

#define  CS_FIELD_KNT   CS_ATRN_TIM // last field in the local cashier file 

static  cs_handle := -1
static  aCash_ := {}
static  mTime_in,mCashCode,mCashName
static  lCashReset := .F.

function cashier_init(cCashCode)
local fhandle := -1
local cBuffer := space(LOCAL_CASH_SIZE)
local i := 0
local lFound := .F.
local nLine_Size

  mTime_in := pad(strtran(time(),":",""),CS_TMIN_LEN)
  mCashCode:= cCashCode
  mCashName:= nvr_cCashName()

  // first look for the  Cashier code if it already exist in the local file
  
  fhandle := FOPEN ( LOCAL_CASH_FILE , FO_READWRITE )
  
  if (ferror() == 2) // file does not yet exist
     ? 
     ? " Im re-Writing the "
     ?? LOCAL_CASH_FILE
     tone(300,18)
          
     if diskspace()  <  LOCAL_CASH_SIZE
        ErrorDisp("Err Open "+LOCAL_CASH_FILE+" insufficient diskspace ")
        error_log("Err Open "+LOCAL_CASH_FILE+" insufficient diskspace ")
     else // Proceed w/ the creation of the LOCAL CASHIER FILE ...
        fhandle := FCREATE( LOCAL_CASH_FILE, FC_NORMAL )
     endif     
  endif   

  if (ferror() == NORMAL)  
     // Seek for the Cashier code to place in nvram
     i := 0
     FSEEK( fhandle, 0 , FS_SET )
     cBuffer := space(LOCAL_CASH_SIZE)
     while FREAD( fhandle, @cBuffer, LOCAL_CASH_SIZE ) == LOCAL_CASH_SIZE
         if subs(cBuffer,CS_CODE_OFF,CS_CODE_LEN+CS_SECR_LEN) == cCashCode
            lFound := .T.
            exit
         endif   
         i += LOCAL_CASH_SIZE
         FSEEK( fhandle, i, FS_SET)
     enddo                        

     if !lFound
        ? 
        ? " Im initializing the record of cashier :"
        ?? cCashCode 
        tone(300,18)
        cBuffer := mCashCode
        cBuffer += mCashName
        cBuffer += padl(config(POS_TERM_NUM),CS_TERM_LEN,"0")
        cBuffer += mTime_in
        cBuffer += repl("0",CS_TOUT_LEN)
        for i:= 1 to CS_FIELD_KNT
            cBuffer += ieereal(0)
        next   
        FSEEK( fhandle, 0 , FS_END)
        nLine_Size := LOCAL_CASH_SIZE
        c_fwrite (fhandle, cBuffer ,@nLine_size)
        if nLine_size != LOCAL_CASH_SIZE
           // post to error file
           error_log("Error local Cashier initialize, " +ltrim(str(ferror())))
           ErrorDisp("Error local Cashier initialize, " +ltrim(str(ferror())))
        endif
     else 
        // Refresh the cashier name just to make sure
        mCashName := subs(cBuffer,CS_NAME_OFF,CS_NAME_LEN)
     endif                  
  else
      error_log("Unable to access cashier file previously validated")
      cBuffer := mCashCode
      cBuffer += mCashName
      cBuffer += padl(config(POS_TERM_NUM),CS_TERM_LEN,"0")
      cBuffer += mTime_in
      cBuffer += repl("0",CS_TOUT_LEN)
      for i:= 1 to CS_FIELD_KNT
          cBuffer += ieereal(0)
      next   
  endif

  fclose(fhandle)
  
  aSize(aCash_,CS_FIELD_KNT)
  afill(aCash_,0)  

  cs_handle := FOPEN( CASHIER_FILE, FO_READWRITE )
  
  if ferror() ==  2 // file does not exist
     cs_handle := FCREATE( CASHIER_FILE, FC_HIDDEN+FC_NORMAL )
  endif

  if ferror() != NORMAL
    ErrorDisp("Err Open "+CASHIER_FILE+" Dos Error "+str(ferror()))
    error_log("Err Open "+CASHIER_FILE+" Dos Error "+str(ferror()))    
    power_end()
  endif
                       
  // Cashier Report File successfully opened... now initialize
  FSEEK(cs_handle, 0, FS_SET)
  nLine_Size := CS_DATA_LEN

  c_fwrite( cs_handle, subs(cBuffer,CS_DATA_OFF,CS_DATA_LEN), @nLine_Size )

  if nLine_size != CS_DATA_LEN
     // post to error file
     error_log ("Error Cashier Report file init.." +ltrim(str(ferror())),1)
  endif                 

  // now initialize all the variables.
  FSEEK (cs_handle, 0, FS_SET)
  cBuffer := space(CS_DATA_LEN)
  if FREAD (cs_handle, @cBuffer, CS_DATA_LEN) != CS_DATA_LEN
     // post to error file...
     error_log("CASHIER file reading failed at initialization, " +;
                ltrim(str(ferror())))
  endif
      
  // now put all the files data to the array aCash_
  for i := 1 to CS_FIELD_KNT                  
        aCash_[i] := realiee(subs(cBuffer,(i-1)*8+1,8))
  next       

return nil

function Cash_Recover(cCashCode)
local lRetVal := .F.
local cBuffer
local i

  aSize(aCash_,CS_FIELD_KNT)
  afill(aCash_,0)  

  // Check if the cashier code in NVRAM is ok...   

  cBuffer := Seek_Cash(cCashCode)

  if empty(cBuffer)
    // this is a problem the data on the nvram may be garbage so 
    // we must make the powerpos reject the cashier data
    // and pretent that no cashier has signed on
*    ? "Cashier Code from nvr not found rejecting : "    
*    ?? nvr_cCashCode()
    nvr_cCashCode("OFFOFF")
  else  
    mCashCode:= cCashCode
    mTime_in := subs(cBuffer,CS_TMIN_OFF,CS_TMIN_LEN)    
    mCashName:= subs(cBuffer,CS_NAME_OFF,CS_NAME_LEN)
    nvr_cCashName( mCashName )      

    cs_handle := FOPEN ( CASHIER_FILE, FO_READWRITE )

    if ferror() == NORMAL

       // Cashier Report File successfully opened...
       // now initialize all the variables.
       FSEEK (cs_handle, 0, FS_SET)
       cBuffer := space(CS_DATA_LEN)
       if FREAD (cs_handle, @cBuffer, CS_DATA_LEN) != CS_DATA_LEN
          // post to error file...
          error_log("CASHIER file reading failed at initialization, " +;
                     ltrim(str(ferror())) + '.')
       endif
      
       // now put all the files data to the array aCash_
       for i := 1 to CS_FIELD_KNT                  
             aCash_[i] := realiee(subs(cBuffer,(i-1)*8+1,8))
       next       
       
       lRetVal := .T.              
    endif
 endif   
  
return lRetVal
 
static function Update_Cash()
local nLine_Size := CS_DATA_LEN
local cBuffer := ""
local i

   for i := CS_DSLS_TOT to CS_FIELD_KNT
       cBuffer += ieereal(aCash_[i])
   next
   
#ifdef DEBUG
   ? "Length of cashier file :"
   ?? len(cBuffer)   

   if len(cBuffer) != CS_DATA_LEN
      ? "Error buffer length mismatch.."
   endif   
#endif     

   FSEEK( cs_handle, 0, FS_SET) // Reset File Pointer
   c_fwrite (cs_handle, cBuffer ,@nLine_size)

   if nLine_size != CS_DATA_LEN
      // post to error file
       error_log ("Error Cashier update, " +ltrim(str(ferror())) +".",1)
   endif

return nil       

function Cash_nData(nVar,nAmount)

  if nAmount != NIL 
     aCash_[nVar] += nAmount   
     Update_Cash()     
  endif  
    
return aCash_[nVar]

function Print_SignOff()

                // print on journal that cashier has signed off...
local out_text := padl(nvr_nTrans(),6,"0") + " " + subs(nvr_cCashCode(),1,3) + "*** " + ;
                  subs(dtoc(date()), 1, 2) + subs(dtoc(date()), 4, 2) + ;
                  " " + substr(time(), 1, 5) + " " + config(POS_TERM_NUM) + chr(10)
                  
  A_RJS_PRNT(0, 1, 0, out_text, 0)
      
  out_text := "CS: "+alltrim(nvr_cCashName()) + " SIGN-OFF" + chr(10)
  A_RJS_PRNT(0, 1, 0, out_text, 0)
  A_RJS_FEED(0, 1, 0, 2)

/*
#ifndef DEBUG
              A_RJS_PRNT(1, 0, 0, padc("CASHIER SIGN OFF",32), 0)
              prnt_end()
#endif    
*/

return nil      


function Cashier_off()
local fhandle
local nLine_Size
local cBuffer := space(LOCAL_CASH_SIZE)
local i,status := NORMAL
local lFound := .F.
local nOffset := 0
local cCashPath
local cOutdata
local cIndata

#ifdef DEF_GRAPHICS
   // clear receipt footer region
   gClearTo( 4, 70, 96, 80, 7)
   getRcptRow(0)
   getRcptCol(0)
   Rcpt_Scroll(0)   
#endif  

  if (( fhandle := FOPEN ( LOCAL_CASH_FILE , FO_READWRITE ) ) < 1 )  
     if diskspace()  <  LOCAL_CASH_SIZE
        error_log("Err Open "+LOCAL_CASH_FILE+" diskspace "+;
                       ltrim(str(ferror())) + '.')                 
     else // Proceed w/ the creation of the LOCAL CASHIER FILE ...
        if (( fhandle := FCREATE( LOCAL_CASH_FILE, FC_NORMAL ) ) < 1)
             error_log("Error Create "+LOCAL_CASH_FILE+" bad sector "+;
                       ltrim(str(ferror())) + '.')          
        endif             
     endif
  endif

  // Linear search...
  nOffset := 0
  FSEEK( fhandle, 0 , FS_SET )
  cBuffer := space(LOCAL_CASH_SIZE)
  while FREAD( fhandle, @cBuffer, LOCAL_CASH_SIZE ) == LOCAL_CASH_SIZE
      if subs(cBuffer,CS_CODE_OFF,CS_CODE_LEN+CS_SECR_LEN) == mCashCode
         lFound := .T.
         exit
      endif   
      nOffset += LOCAL_CASH_SIZE
      FSEEK( fhandle, nOffSet, FS_SET)
  enddo                        


  cBuffer := mCashCode
  cBuffer += mCashName
  cBuffer += padl(config(POS_TERM_NUM),CS_TERM_LEN,"0")
  cBuffer += mTIME_in
  cBuffer += pad(strtran(time(),":",""),CS_TOUT_LEN)
  for i:= 1 to CS_FIELD_KNT
      cBuffer += ieereal(aCash_[i])
  next                  

  if lFound
     FSEEK( fhandle, nOffset, FS_SET)     
  else
     FSEEK( fhandle, 0, FS_END)  
     ? 
     ? " Im initializing the record of cashier :"
     ?? mCashCode 
     tone(300,18)
  endif   
  
  nLine_Size := LOCAL_CASH_SIZE
  c_fwrite (fhandle, cBuffer ,@nLine_size)
  if nLine_size != LOCAL_CASH_SIZE
     // post to error file
     error_log ("Error local Cashier initialize, " +ltrim(str(ferror())) +".",1)
  endif

  fclose(fhandle)    
  fclose(cs_handle)
  
  nvr_cCashName("*** SIGN OFF ***")

  // put the timeout data and reset pos no of central cashier file..
  // be it on server or local
  // get path of cashier
  if config(POS_FLOATING) != "FLOATING"
     cCashPath := GetLocal_Path()
  else
     cCashPath := GetCentral_Path()
  endif
  
  cOutdata := subs(mCashCode,CS_CODE_OFF,CS_CODE_LEN)
  cIndata := space(FA_SZ_CSH)

  status := file_access(FA_CMD_SRCHGET,FA_PRM_ZERO,FA_FN_CSH,FA_SZ_CSH,cOutData,@cIndata,cCashPath)
  if status == NORMAL

     // check if code is correct and machine no match...
     if subs(cIndata,CASH_CODE_OFF,CASH_CODE_LEN) == mCashCode .and. subs(cIndata,CASH_POSNO_OFF,CASH_POSNO_LEN) == padl(config(POS_TERM_NUM),4,"0")
        // write it back to the file
        cOutData := subs(cIndata,CASH_CODE_OFF,CASH_CODE_LEN)
        cOutData += subs(cIndata,CASH_NAME_OFF,CASH_NAME_LEN)
        cOutData += subs(cIndata,CASH_TIME1_OFF,CASH_TIME1_LEN) 
        cOutData += strtran(time(),":","")
        cOutData += "0000"
        cOutData += subs(cIndata,CASH_RSRVD_OFF,CASH_RSRVD_LEN)
        cOutData += chr(13)+chr(10)
        status := file_access(FA_CMD_SRCHPUT,FA_PRM_ZERO,FA_FN_CSH,len(cIndata),cOutData,@cIndata,cCashPath)
        if status != NORMAL
           error_log("Error Cashier update on sign-off :"+str(status))   
        endif
     endif  
  else 
    error_log("Error Cashier access on sign-off :"+str(status))   
  endif
  
  // if network not accessible or cashier not found let go situation...  
  // then erase all suspended transaction that this cashier has initiated...
  
/*
  for i := 1 to nvr_nSUSlevel()
      if file(".\SUSP"+padl(i,4,"0")+".TXT")
        ferase(".\SUSP"+padl(i,4,"0")+".TXT")
      endif         
  next  
  nvr_nSUSlevel(0)   
  i := Term_nData(TR_TRSU_TOT)
  Term_nData(TR_TRSU_TOT, -i)
  i := Term_nData(TR_TRSU_KNT)
  Term_nData(TR_TRSU_KNT, -i) 
*/  
    
return nil

function String_Cash(lType)
local fhandle
local cBuffer 
local aCash_ := {}
local k,i

   // Search for the key code entered
   if (( fhandle := FOPEN ( LOCAL_CASH_FILE , FO_READWRITE ) ) < 1 )  
        error_log("Err Open "+LOCAL_CASH_FILE+" diskspace "+;
                       ltrim(str(ferror())) + '.')                 
   else  
      // Seek for the Cashier code to place in nvram
      i := 0
      FSEEK( fhandle, 0 , FS_SET )
      cBuffer := space(LOCAL_CASH_SIZE)
      while FREAD( fhandle, @cBuffer, LOCAL_CASH_SIZE ) == LOCAL_CASH_SIZE
         aadd( aCash_, subs(cBuffer,CS_CODE_OFF,CS_CODE_LEN) )
         i += LOCAL_CASH_SIZE
         FSEEK( fhandle, i, FS_SET)
         cBuffer := space(LOCAL_CASH_SIZE)
      enddo         
   endif

   fclose(fhandle)

   for k := 1 to len(aCash_)
#ifdef DEF_GRAPHICS   
     DISPTEXTXY(3,1,0,0,0,0,"TESTING CASHIER :"+padl(aCash_[k],3,"0"))
#else
     MsgAreaDisp("TESTING CASHIER :"+padl(aCash_[k],3,"0"))
#endif     
     Cash_Report(lType,aCash_[k])   
   next k
     
return nil

function Cash_Report(lType,cCashCode ) // .F. -X; .T. -Z 
local fhandle
local i,lSales 
local lFound := .F.
local cBuffer
local outdata 
local lRetVal:= .F.
local status := 0
local total_charges := 0
local gross_sales := 0
local excess := 0
local cash_sales := 0
local nDaily_sls := 0
   
   // Search for the key code entered
   if (( fhandle := FOPEN ( LOCAL_CASH_FILE , FO_READWRITE ) ) < 1 )  
        error_log("Err Open "+LOCAL_CASH_FILE+" diskspace "+;
                       ltrim(str(ferror())) + '.')                 
   else  
      // Seek for the Cashier code to place in nvram
      i := 0
      FSEEK( fhandle, 0 , FS_SET )
      cBuffer := space(LOCAL_CASH_SIZE)
      while FREAD( fhandle, @cBuffer, LOCAL_CASH_SIZE ) == LOCAL_CASH_SIZE
         if subs(cBuffer,CS_CODE_OFF,CS_CODE_LEN) == cCashCode
            lFound := .T.
            exit
         endif   
         i += LOCAL_CASH_SIZE
         FSEEK( fhandle, i, FS_SET)
      enddo         
   endif

   fclose(fhandle)

   if !lFound
      return .F.
   endif   

   Cashier_init(subs(cBuffer,CS_CODE_OFF,CS_CODE_LEN+CS_SECR_LEN))  

   while chk_jrnal() == PAPER_ERR
        MsgAreaDisp("Receipt/Journal Paper Error")
        tone(600,6) // Error sound
        MsgAreaDisp()        
   enddo                   

   lSales := .F.
   for i := 1 to CS_REEN_TOT
    if aCash_[i] != 0
       lSales := .T.
       exit
    endif   
   next  i
   
   if lSales .and.  (rpt_prnt(SET_REC, 1, 0, "CASHIER REPORT", 0) == 0) 
   
    total_charges := aCash_[TR_MC01_TOT] + aCash_[TR_MC02_TOT] + aCash_[TR_MC03_TOT] + ;
                     aCash_[TR_MC04_TOT] + aCash_[TR_MC05_TOT] + aCash_[TR_MC06_TOT] + ;
                     aCash_[TR_MC07_TOT] + aCash_[TR_MC08_TOT] + aCash_[TR_MC09_TOT] + ; 
                     aCash_[TR_MC10_TOT] + aCash_[TR_MC11_TOT] + aCash_[TR_MC12_TOT] + ;
                     aCash_[TR_MC13_TOT] + aCash_[TR_MC14_TOT] + aCash_[TR_MC15_TOT] + ;
                     aCash_[TR_MC16_TOT] + aCash_[TR_MC17_TOT] + aCash_[TR_MC18_TOT] + ;
                     aCash_[TR_MC19_TOT] + aCash_[TR_MC20_TOT] + aCash_[TR_MC21_TOT] + ;
                     aCash_[TR_MC22_TOT] + aCash_[TR_MC23_TOT] + aCash_[TR_MC24_TOT] + ;
                     aCash_[TR_MC25_TOT] + aCash_[TR_MC26_TOT] + aCash_[TR_MC27_TOT] + ;
                     aCash_[TR_MC28_TOT] + aCash_[TR_MC29_TOT] + aCash_[TR_MC30_TOT] + ; 
                     aCash_[TR_MC31_TOT] + aCash_[TR_MC32_TOT] + aCash_[TR_MC33_TOT] + ;
                     aCash_[TR_MC34_TOT] + aCash_[TR_MC35_TOT] + aCash_[TR_MC36_TOT] + ;
                     aCash_[TR_MC37_TOT] + aCash_[TR_MC38_TOT] + aCash_[TR_MC39_TOT] + ;
                     aCash_[TR_MC40_TOT] + aCash_[TR_MC41_TOT] + aCash_[TR_MC42_TOT] + ;
                     aCash_[TR_MC43_TOT] + aCash_[TR_MC44_TOT] + aCash_[TR_MC45_TOT] + ;                   
                     aCash_[TR_MC46_TOT] + aCash_[TR_MC47_TOT] + aCash_[TR_MC48_TOT] + ;                   
                     aCash_[TR_MC49_TOT] + aCash_[TR_MC50_TOT]

     gross_sales := (aCash_[CS_DEPT_TOT] + aCash_[CS_OINC_TOT] + aCash_[CS_ADON_TOT])
      nDaily_sls := Gross_sales - aCash_[129] - aCash_[121] - ;
                    aCash_[123] - ( aCash_[111] + aCash_[113] )

     // Update the New Grand Total
     // aCash_[CS_NEWG_TOT] := aCash_[CS_OLDG_TOT] + aCash_[CS_DSLS_TOT]
     aCash_[CS_NEWG_TOT] := aCash_[CS_OLDG_TOT] + nDaily_sls
     
     ?
     if lType
       outdata := "(Z - "+ alltrim(trans(aCash_[CS_ZCTR_TOT],"@B 99999"))+ ")"
     else       
       outdata := "(X - "+ alltrim(trans(aCash_[CS_XCTR_TOT],"@B 99999"))+ ")"
     endif       
     status += rpt_prnt(SET_REC,1,0, outdata, 0)
     ? outdata
     outdata := "Cashier Code "+cCashCode+"***"
     status += rpt_prnt(SET_REC,1,0, outdata, 0)
     ? outdata     
     outdata := "Cashier Name "+subs(mCashName,1,19)
     status += rpt_prnt(SET_REC,1,0, outdata, 0)
     ? outdata     
     outdata := "Daily Sales       " + trans(aCash_[01]," 99,999,999.99")
     status += rpt_prnt(SET_REC,1,0, outdata, 0)
     ? outdata     
     outdata := padl(tran(aCash_[02],"999,999,999"),32)
     status += rpt_prnt(SET_REC,1,0, outdata, 0)
     ? outdata     
     outdata := "Dept. Sales       " + trans(aCash_[04]," 99,999,999.99")
     status += rpt_prnt(SET_REC,1,0, outdata, 0)
     ? outdata     
     //gross_sales := (aCash_[CS_DEPT_TOT] + aCash_[CS_OINC_TOT] + aCash_[CS_ADON_TOT])
     outdata := "Gross Sales       " + trans(gross_sales," 99,999,999.99")
     status += rpt_prnt(SET_REC,1,0, outdata, 0)
     ? outdata
     cash_sales := (aCash_[CS_CASH_TOT] + aCash_[CS_OINC_TOT] + aCash_[CS_PKUP_TOT] - aCash_[CS_LOAN_TOT])
     outdata := "Cash Totals       " + trans(cash_sales," 99,999,999.99")
     status += rpt_prnt(SET_REC,1,0, outdata, 0)
     ? outdata
     outdata := "Charge Sales      " + trans(total_charges," 99,999,999.99")
     status += rpt_prnt(SET_REC,1,0, outdata, 0)
     ? outdata     
     if 0 != (aCash_[141] + aCash_[142])
        outdata := "Cash Declaration  " + trans(aCash_[141]," 99,999,999.99")
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata                                
        outdata := padl(trans(aCash_[142],"999,999,999"),32)
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata                                
     endif    
     excess := aCash_[141] - ((aCash_[01] + aCash_[139]) - aCash_[135])
     outdata := "Over/Short        " + trans(excess," 99,999,999.99")
     status += rpt_prnt(SET_REC,1,0, outdata, 0)

     if 0 != (aCash_[05] + aCash_[06])     
        outdata := "Foreign Currency  " + trans(aCash_[05]," 99,999,999.99")         
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata        
        outdata := padl(tran(aCash_[06],"999,999,999"),32)
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata                
     endif    
     if 0 != (aCash_[07] + aCash_[08])
        outdata :=  pad(if(empty(GetMDesc(1)),"MISC. 1",GetMDesc(1)),18) + ;        
                                  trans(aCash_[07]," 99,999,999.99")
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata                                          
        outdata := padl(tran(aCash_[08],"999,999,999"),32)
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata                
     endif    
     if 0 != (aCash_[09] + aCash_[10])      
        outdata := pad(if(empty(GetMDesc(2)),"MISC. 2",GetMDesc(2)),18) +;
                                  trans(aCash_[09]," 99,999,999.99")
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata                                          
        outdata := padl(tran(aCash_[10],"999,999,999"),32)
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata        
     endif    
     if 0 != (aCash_[11] + aCash_[12])
        outdata := pad(if(empty(GetMDesc(3)),"MISC. 3",GetMDesc(3)),18) +;     
                                  trans(aCash_[11]," 99,999,999.99")
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata                                          
        outdata := padl(tran(aCash_[12],"999,999,999"),32)
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata                
     endif    
     if 0 != (aCash_[13] + aCash_[14])
        outdata := pad(if(empty(GetMDesc(4)),"MISC. 4",GetMDesc(4)),18) +;     
                                  trans(aCash_[13]," 99,999,999.99")
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata                                          
        outdata := padl(tran(aCash_[14],"999,999,999"),32)
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata        
     endif    
     if 0 != (aCash_[15] + aCash_[16])
        outdata := pad(if(empty(GetMDesc(5)),"MISC. 5",GetMDesc(5)),18) +;             
                                  trans(aCash_[15]," 99,999,999.99")
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata                                          
        outdata := padl(tran(aCash_[16],"999,999,999"),32)
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata                
     endif    
     if 0 != (aCash_[17] + aCash_[18])
        outdata := pad(if(empty(GetMDesc(6)),"MISC. 6",GetMDesc(6)),18) +;     
                                  trans(aCash_[17]," 99,999,999.99")
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata                                          
        outdata := padl(tran(aCash_[18],"999,999,999"),32)
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata                
     endif    
     if 0 != (aCash_[19] + aCash_[20])
        outdata := pad(if(empty(GetMDesc(7)),"MISC. 7",GetMDesc(7)),18) +;     
                                  trans(aCash_[19]," 99,999,999.99")
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata                                          
        outdata := padl(tran(aCash_[20],"999,999,999"),32)
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata                
     endif    
     if 0 != (aCash_[21] + aCash_[22])
        outdata := pad(if(empty(GetMDesc(8)),"MISC. 8",GetMDesc(8)),18) +;     
                                  trans(aCash_[21]," 99,999,999.99")
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata                                          
        outdata := padl(tran(aCash_[22],"999,999,999"),32)
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata                
     endif    
     if 0 != (aCash_[23] + aCash_[24])
        outdata := pad(if(empty(GetMDesc(9)),"MISC. 9",GetMDesc(9)),18) +;     
                                  trans(aCash_[23]," 99,999,999.99")
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata                                          
        outdata := padl(tran(aCash_[24],"999,999,999"),32)
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata                
     endif    
     if 0 != (aCash_[25] + aCash_[26])
        outdata := pad(if(empty(GetMDesc(10)),"MISC. 10",GetMDesc(10)),18) +;     
                                  trans(aCash_[25]," 99,999,999.99")
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata                                          
        outdata := padl(tran(aCash_[26],"999,999,999"),32)
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata                
     endif    
     if 0 != (aCash_[27] + aCash_[28])
        outdata := pad(if(empty(GetMDesc(11)),"MISC. 11",GetMDesc(11)),18) +;     
                                  trans(aCash_[27]," 99,999,999.99")
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata                                          
        outdata := padl(tran(aCash_[28],"999,999,999"),32)
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata                
     endif    
     if 0 != (aCash_[29] + aCash_[30])
        outdata := pad(if(empty(GetMDesc(12)),"MISC. 12",GetMDesc(12)),18) +;     
                                  trans(aCash_[29]," 99,999,999.99")
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata                                          
        outdata := padl(tran(aCash_[30],"999,999,999"),32)
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata                
     endif    
     if 0 != (aCash_[31] + aCash_[32])
        outdata := pad(if(empty(GetMDesc(13)),"MISC. 13",GetMDesc(13)),18) +;     
                                  trans(aCash_[31]," 99,999,999.99")
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata                                          
        outdata := padl(tran(aCash_[32],"999,999,999"),32)
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata                
     endif    
     if 0 != (aCash_[33] + aCash_[34])
        outdata := pad(if(empty(GetMDesc(14)),"MISC. 14",GetMDesc(14)),18) +;     
                                  trans(aCash_[33]," 99,999,999.99")
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata                                          
        outdata := padl(tran(aCash_[34],"999,999,999"),32)
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata                
     endif    
     if 0 != (aCash_[35] + aCash_[36])
        outdata := pad(if(empty(GetMDesc(15)),"MISC. 15",GetMDesc(15)),18) +;             
                                  trans(aCash_[35]," 99,999,999.99")
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata                                          
        outdata := padl(tran(aCash_[36],"999,999,999"),32)
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata                
     endif    
     if 0 != (aCash_[37] + aCash_[38])
        outdata := pad(if(empty(GetMDesc(16)),"MISC. 16",GetMDesc(16)),18) +;     
                                  trans(aCash_[37]," 99,999,999.99")
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata                                          
        outdata := padl(tran(aCash_[38],"999,999,999"),32)
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata                
     endif    
     if 0 != (aCash_[39] + aCash_[40])
        outdata := pad(if(empty(GetMDesc(17)),"MISC. 17",GetMDesc(17)),18) +;     
                                  trans(aCash_[39]," 99,999,999.99")
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata                                          
        outdata := padl(tran(aCash_[40],"999,999,999"),32)
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata                
     endif    
     if 0 != (aCash_[41] + aCash_[42])
        outdata := pad(if(empty(GetMDesc(18)),"MISC. 18",GetMDesc(18)),18) +;     
                                  trans(aCash_[41]," 99,999,999.99")
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata                                          
        outdata := padl(tran(aCash_[42],"999,999,999"),32)
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata                
     endif    
     if 0 != (aCash_[43] + aCash_[44])
        outdata := pad(if(empty(GetMDesc(19)),"MISC. 19",GetMDesc(19)),18) +;     
                                  trans(aCash_[43]," 99,999,999.99")
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata                                          
        outdata := padl(tran(aCash_[44],"999,999,999"),32)
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata                
     endif    
     if 0 != (aCash_[45] + aCash_[46])
        outdata := pad(if(empty(GetMDesc(20)),"MISC.20",GetMDesc(20)),18) +;     
                                  trans(aCash_[45]," 99,999,999.99")   
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata                                          
        outdata := padl(tran(aCash_[46],"999,999,999"),32)
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata                
     endif    
     if 0 != (aCash_[47] + aCash_[48])
        outdata := pad(if(empty(GetMDesc(21)),"MISC. 21",GetMDesc(21)),18) + ;
                         trans(aCash_[47]," 99,999,999.99")
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata                              
        outdata := padl(trans(aCash_[48],"999,999,999"),32)
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata                                      
     endif    
     if 0 != (aCash_[49] + aCash_[50])      
        outdata := pad(if(empty(GetMDesc(22)),"MISC. 22",GetMDesc(22)),18) +;
                                  trans(aCash_[49]," 99,999,999.99")
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata                                                                
        outdata := padl(trans(aCash_[50],"999,999,999"),32)
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata                                      
     endif    
     if 0 != (aCash_[51] + aCash_[52])
        outdata := pad(if(empty(GetMDesc(23)),"MISC. 23",GetMDesc(23)),18) +;     
                                  trans(aCash_[51]," 99,999,999.99")
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata                                                                
        outdata := padl(trans(aCash_[52],"999,999,999"),32)
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata                                      
     endif    
     if 0 != (aCash_[53] + aCash_[54])
        outdata := pad(if(empty(GetMDesc(24)),"MISC. 24",GetMDesc(24)),18) +;     
                                  trans(aCash_[53]," 99,999,999.99")
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata                                                                
        outdata := padl(trans(aCash_[54],"999,999,999"),32)
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata                                      
     endif    
     if 0 != (aCash_[55] + aCash_[56])
        outdata :=  pad(if(empty(GetMDesc(25)),"MISC. 25",GetMDesc(25)),18) +;     
                                  trans(aCash_[55]," 99,999,999.99")
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata                                                                
        outdata := padl(trans(aCash_[56],"999,999,999"),32)
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata                                      
     endif    
     if 0 != (aCash_[57] + aCash_[58])
        outdata :=  pad(if(empty(GetMDesc(26)),"MISC. 26",GetMDesc(26)),18) +;     
                                  trans(aCash_[57]," 99,999,999.99")
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata
        outdata :=  padl(trans(aCash_[58],"999,999,999"),32)
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata
     endif    
     if 0 != (aCash_[59] + aCash_[60])
        outdata :=  pad(if(empty(GetMDesc(27)),"MISC. 27",GetMDesc(27)),18) +;     
                                  trans(aCash_[59]," 99,999,999.99")
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata                                  
        outdata :=  padl(trans(aCash_[60],"999,999,999"),32)
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata        
     endif    
     if 0 != (aCash_[61] + aCash_[62])
        outdata :=  pad(if(empty(GetMDesc(28)),"MISC. 28",GetMDesc(28)),18) +;     
                                  trans(aCash_[61]," 99,999,999.99")
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata                                  
        outdata :=  padl(trans(aCash_[62],"999,999,999"),32)
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata        
     endif    
     if 0 != (aCash_[63] + aCash_[64])
        outdata :=  pad(if(empty(GetMDesc(29)),"MISC. 29",GetMDesc(29)),18) +;     
                                  trans(aCash_[63]," 99,999,999.99")
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata                                  
        outdata :=  padl(trans(aCash_[64],"999,999,999"),32)
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata        
     endif    
     if 0 != (aCash_[65] + aCash_[66])
        outdata :=  pad(if(empty(GetMDesc(30)),"MISC. 30",GetMDesc(10)),18) +;     
                                  trans(aCash_[65]," 99,999,999.99")
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata                                  
        outdata := padl(trans(aCash_[66],"999,999,999"),32)
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata        
     endif    
     if 0 != (aCash_[67] + aCash_[68])
        outdata :=  pad(if(empty(GetMDesc(31)),"MISC. 31",GetMDesc(31)),18) +;     
                                  trans(aCash_[67]," 99,999,999.99")
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata                                  
        outdata := padl(trans(aCash_[68],"999,999,999"),32)
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata        
     endif    
     if 0 != (aCash_[69] + aCash_[70])
        outdata :=  pad(if(empty(GetMDesc(32)),"MISC. 32",GetMDesc(32)),18) +;     
                                  trans(aCash_[69]," 99,999,999.99")
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata                                  
        outdata :=  padl(trans(aCash_[70],"999,999,999"),32)
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata        
     endif    
     if 0 != (aCash_[71] + aCash_[72])
        outdata :=  pad(if(empty(GetMDesc(33)),"MISC. 33",GetMDesc(73)),18) +;     
                                  trans(aCash_[71]," 99,999,999.99")
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata                                  
        outdata := padl(trans(aCash_[72],"999,999,999"),32)
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata        
     endif    
     if 0 != (aCash_[73] + aCash_[74])
        outdata := pad(if(empty(GetMDesc(34)),"MISC. 34",GetMDesc(34)),18) +;     
                                  trans(aCash_[73]," 99,999,999.99")
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata                                  
        outdata := padl(trans(aCash_[74],"999,999,999"),32)
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata        
     endif    
     if 0 != (aCash_[75] + aCash_[76])
        outdata := pad(if(empty(GetMDesc(35)),"MISC. 35",GetMDesc(35)),18) +;     
                                  trans(aCash_[75]," 99,999,999.99")
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata                                  
        outdata := padl(trans(aCash_[76],"999,999,999"),32)
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata        
     endif    
     if 0 != (aCash_[77] + aCash_[78])
        outdata := pad(if(empty(GetMDesc(36)),"MISC. 36",GetMDesc(36)),18) +;     
                                          trans(aCash_[77]," 99,999,999.99")
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata                                          
        outdata := padl(trans(aCash_[78],"999,999,999"),32)
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata        
     endif    
     if 0 != (aCash_[79] + aCash_[80])
        outdata :=  pad(if(empty(GetMDesc(37)),"MISC. 37",GetMDesc(37)),18) +;     
                                  trans(aCash_[79]," 99,999,999.99")
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata                                  
        outdata :=  padl(trans(aCash_[80],"999,999,999"),32)
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata        
     endif    
     if 0 != (aCash_[81] + aCash_[82])
        outdata := pad(if(empty(GetMDesc(38)),"MISC. 38",GetMDesc(38)),18) +;     
                                  trans(aCash_[81]," 99,999,999.99")
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata                                  
        outdata := padl(trans(aCash_[82],"999,999,999"),32)
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata        
     endif    
     if 0 != (aCash_[83] + aCash_[84])
        outdata :=  pad(if(empty(GetMDesc(39)),"MISC. 39",GetMDesc(39)),18) +;     
                                  trans(aCash_[83]," 99,999,999.99")
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata                                  
        outdata :=  padl(trans(aCash_[84],"999,999,999"),32)
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata        
     endif    
     if 0 != (aCash_[85] + aCash_[86])
        outdata := pad(if(empty(GetMDesc(40)),"MISC. 40",GetMDesc(40)),18) +;     
                                  trans(aCash_[85]," 99,999,999.99")   
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata                                  
        outdata := padl(trans(aCash_[86],"999,999,999"),32)
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata        
     endif    
     if 0 != (aCash_[87] + aCash_[88])
        outdata := pad(if(empty(GetMDesc(41)),"MISC. 41",GetMDesc(41)),18) + ;
                         trans(aCash_[87]," 99,999,999.99")
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata                              
        outdata := padl(trans(aCash_[88],"999,999,999"),32)
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata                                      
     endif    
     if 0 != (aCash_[89] + aCash_[90])      
        outdata := pad(if(empty(GetMDesc(42)),"MISC. 42",GetMDesc(42)),18) +;
                                  trans(aCash_[89]," 99,999,999.99")
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata                                                                
        outdata := padl(trans(aCash_[70],"999,999,999"),32)
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata                                      
     endif    
     if 0 != (aCash_[91] + aCash_[92])
        outdata := pad(if(empty(GetMDesc(43)),"MISC. 43",GetMDesc(43)),18) +;     
                                  trans(aCash_[91]," 99,999,999.99")
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata                                                                
        outdata := padl(trans(aCash_[92],"999,999,999"),32)
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata                                      
     endif    
     if 0 != (aCash_[93] + aCash_[94])
        outdata := pad(if(empty(GetMDesc(44)),"MISC. 44",GetMDesc(44)),18) +;     
                                  trans(aCash_[93]," 99,999,999.99")
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata                                                                
        outdata := padl(trans(aCash_[94],"999,999,999"),32)
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata                                      
     endif    
     if 0 != (aCash_[95] + aCash_[96])
        outdata :=  pad(if(empty(GetMDesc(45)),"MISC. 45",GetMDesc(45)),18) +;     
                                  trans(aCash_[95]," 99,999,999.99")
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata                                                                
        outdata := padl(trans(aCash_[96],"999,999,999"),32)
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata                                      
     endif    
     if 0 != (aCash_[97] + aCash_[98])
        outdata :=  pad(if(empty(GetMDesc(46)),"MISC. 46",GetMDesc(46)),18) +;     
                                  trans(aCash_[97]," 99,999,999.99")
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata
        outdata :=  padl(trans(aCash_[98],"999,999,999"),32)
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata
     endif    
     if 0 != (aCash_[99] + aCash_[100])
        outdata :=  pad(if(empty(GetMDesc(47)),"MISC. 47",GetMDesc(47)),18) +;     
                                  trans(aCash_[99]," 99,999,999.99")
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata                                  
        outdata :=  padl(trans(aCash_[100],"999,999,999"),32)
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata        
     endif    
     if 0 != (aCash_[101] + aCash_[102])
        outdata :=  pad(if(empty(GetMDesc(48)),"MISC. 48",GetMDesc(48)),18) +;     
                                  trans(aCash_[101]," 99,999,999.99")
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata                                  
        outdata :=  padl(trans(aCash_[102],"999,999,999"),32)
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata        
     endif    
     if 0 != (aCash_[103] + aCash_[104])
        outdata :=  pad(if(empty(GetMDesc(49)),"MISC. 49",GetMDesc(49)),18) +;     
                                  trans(aCash_[103]," 99,999,999.99")
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata                                  
        outdata :=  padl(trans(aCash_[104],"999,999,999"),32)
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata        
     endif    
     if 0 != (aCash_[105] + aCash_[106])
        outdata :=  pad(if(empty(GetMDesc(50)),"MISC. 50",GetMDesc(50)),18) +;     
                                  trans(aCash_[105]," 99,999,999.99")
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata                                  
        outdata := padl(trans(aCash_[26],"999,999,999"),32)
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata        
     endif    
     if 0 != (aCash_[107] + aCash_[108])
        outdata := "Item Void         " + trans(aCash_[107]," 99,999,999.99")
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata        
        outdata :=  padl(trans(aCash_[108],"999,999,999"),32)
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata        
     endif    
     if 0 != (aCash_[109] + aCash_[110])
        outdata := "Manager Void      " + trans(aCash_[109]," 99,999,999.99")
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata                        
        outdata := padl(trans(aCash_[110],"999,999,999"),32)
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata                
     endif    
     if 0 != (aCash_[111] + aCash_[112])
        outdata := "Item Discount     " + trans(aCash_[111]," 99,999,999.99")
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata                
        outdata := padl(trans(aCash_[112],"999,999,999"),32)
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata                
     endif    
     if 0 != (aCash_[113] + aCash_[114])
        outdata :=  "Subtotal Discount " + trans(aCash_[113]," 99,999,999.99") 
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata                
        outdata := padl(trans(aCash_[114],"999,999,999"),32)
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata                
     endif    
     if 0 != (aCash_[115] + aCash_[116])
        outdata := "Add-On Total      " + trans(aCash_[115]," 99,999,999.99")
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata                
        outdata := padl(trans(aCash_[116],"999,999,999"),32)
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata                        
     endif     
     if 0 != (aCash_[117] + aCash_[118])
        outdata :=  "Selective STT Disc" + trans(aCash_[117]," 99,999,999.99")
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata                                
        outdata :=  padl(trans(aCash_[118],"999,999,999"),32)
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata                                
     endif    
     if 0 != (aCash_[119] + aCash_[120])
        outdata := "Subtotal Discount " + trans(aCash_[119]," 99,999,999.99")
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata                                
        outdata := padl(trans(aCash_[120],"999,999,999"),32)
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata                                
     endif    
     if 0 != (aCash_[121] + aCash_[122])
        outdata := "Return Exchange   " + trans(aCash_[121]," 99,999,999.99")
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata                                
        outdata := padl(trans(aCash_[122],"999,999,999"),32)
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata                                
     endif    
     if 0 != (aCash_[123] + aCash_[124])
        outdata := "Refunds           " + trans(aCash_[123]," 99,999,999.99")
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata                                
        outdata := padl(trans(aCash_[124],"999,999,999"),32)
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata                                
     endif    
     if 0 != (aCash_[125] + aCash_[126])
        outdata := "Other Income      " + trans(aCash_[125]," 99,999,999.99")
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata                                
        outdata := padl(trans(aCash_[126],"999,999,999"),32)
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata                                
     endif    
     if 0 != (aCash_[127] + aCash_[128])
        outdata := "Transaction Cancel" + trans(aCash_[127]," 99,999,999.99")
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata                                
        outdata := padl(trans(aCash_[128],"999,999,999"),32)
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata                                
     endif    
     if 0 != (aCash_[129] + aCash_[130])
        outdata := "Transaction Void  " + trans(aCash_[129]," 99,999,999.99")
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata                                
        outdata := padl(trans(aCash_[130],"999,999,999"),32)
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata                                
     endif    
     if 0 != (aCash_[131] + aCash_[132])
        outdata := "Trans. Suspend    " + trans(aCash_[131]," 99,999,999.99")
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata                                
        outdata := padl(trans(aCash_[132],"999,999,999"),32)
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata                                
     endif    
     if 0 != (aCash_[133] + aCash_[134])
        outdata := "Lay-Away Amt      " + trans(aCash_[133]," 99,999,999.99")
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata                                
        outdata := padl(trans(aCash_[134],"999,999,999"),32)
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata                                
     endif    
     if 0 != (aCash_[135] + aCash_[136])
        outdata := "Pick-Up           " + trans(aCash_[135]," 99,999,999.99")
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata                                
        outdata := padl(trans(aCash_[136],"999,999,999"),32)
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata                                
     endif    
     if 0 != (aCash_[137] + aCash_[138])
        outdata := "Paid-Out          " + trans(aCash_[137]," 99,999,999.99")
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata                                
        outdata := padl(trans(aCash_[138],"999,999,999"),32)
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata                                
     endif    
     if 0 != (aCash_[139] + aCash_[140])
        outdata := "Loan              " + trans(aCash_[139]," 99,999,999.99")
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata                                
        outdata := padl(trans(aCash_[140],"999,999,999"),32)
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata                                
     endif    

     if 0 != (aCash_[143] + aCash_[144])
        outdata := "Bottle Deposit    " + trans(aCash_[143]," 99,999,999.99")
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata                                
        outdata := padl(trans(aCash_[144],"999,999,999"),32)
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata                                
     endif    
/*     
     ?  "Offline Total     " + trans(aCash_[145]," 99,999,999.99")
     ?                   padl(aCash_[146],32)           
*/

* #ifndef STAND_ALONE_MODE        
        outdata := "Negative Cash     " + trans(aCash_[145]," 99,999,999.99")
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata                                
        outdata := padl(trans(aCash_[146],"999,999,999"),32)  
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata                                        
* #endif           

     if 0 != (aCash_[147])
        outdata := "Training Mode     " + trans(aCash_[147]," 99,999,999.99")
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata                                
     endif
     if 0 != (aCash_[148])     
        outdata := "Reenter Total     " + trans(aCash_[148]," 99,999,999.99")
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata                                
     endif 
     ?
     outdata := "Old Grand Total " + trans(aCash_[CS_OLDG_TOT],"9,999,999,999.99")
     status += rpt_prnt(SET_REC,1,0, outdata, 0)
     ? outdata                             
     outdata := "New Grand Total " + trans(aCash_[CS_NEWG_TOT],"9,999,999,999.99")
     status += rpt_prnt(SET_REC,1,0, outdata, 0)
     ? outdata                        
     
/*        ? outdata        
        outdata := padl(tran(aCash_[82],"999,999,999"),32)
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata        
*/
     
     if lType 
       if status == 0 // all printing is normal
                
           
           // Make the new grand total as Old grand total
           aCash_[CS_OLDG_TOT] := aCash_[CS_NEWG_TOT]             
           
           for i := CS_DSLS_TOT to CS_REEN_TOT
             aCash_[i] := 0 //  reset totals 
/*
             rpt_prnt(1, 0, 0, trans(i, "999 : ")+trans(aCash_[i], "999"), 0)
*/             
           next i

           for i := CS_SCAN_TOT to CS_ATRN_TIM
             aCash_[i] := 0
           next i 

           // increment the Z counter
           aCash_[CS_ZCTR_TOT] += 1 

           lcs_reset( .T. )
       else
           DISPTEXTXY(3,1,0,0,0,0,"PRINT NOT COMPLETED!")
           ErrorDisp("* RETRY Z-READING! *")
       endif   
     else
        // increment the X counter
        aCash_[CS_XCTR_TOT] += 1        
     endif
     // now write all updates to the report file      
     lRetVal := .T.
     Update_cash()     
     prnt_end()
     // delay for a moment
     tone(15,54)     
  endif   

  cashier_off()
    
return lRetVal

function seek_cash(cVar)
local fhandle
local lFound := .F.
local cBuffer 
local i

  // try to open file
  // Search for the key code entered

  fhandle := FOPEN ( LOCAL_CASH_FILE , FO_READWRITE )
  
  if ferror() == NORMAL
     // Seek for the Cashier code to place in nvram
     i := 0
     FSEEK( fhandle, 0 , FS_SET )
     cBuffer := space(LOCAL_CASH_SIZE)
     while FREAD( fhandle, @cBuffer, LOCAL_CASH_SIZE ) == LOCAL_CASH_SIZE
        if subs(cBuffer,CS_CODE_OFF,CS_CODE_LEN+CS_SECR_LEN) == cVar
           lFound := .T.
           exit
        endif   
        i += LOCAL_CASH_SIZE
        FSEEK( fhandle, i, FS_SET)
     enddo         
  endif

  fclose(fhandle)
  
return if(lFound,cBuffer,"")

function temp_sign_off(cVar)
local lretval := .F.
local out_text
local cCode:= "",cKey := 0
local cData
local wWindow,nStatus

    if cVar == subs(mCashCode,1,3)       

       wWindow := OpenWindow(0,0,100,91)       
       MsgAreaDisp("TEMPORARY SIGN-OFF..")
       // Center Bitmap Display Horizontally
       if ((nStatus := gLoad_BMP(TEMP_BMPFILE,0,0,100,100 )) != 0)
          DispStatus("Bitmap loading err: "+padl(nStatus,3))
       endif     

       ScrollOn()
       while !lRetVal
       DISPTEXTXY(0, 0, 0, 0, 1, 1, padc(VERSION_ID,20))                 
          do case
             case keylock() == KEY_LOCK_POS0
*                disp_clr()
                DISPTEXTXY(1,1,0,0,1,1,MSG_0004)
                out_text := pad("CASHIER : "+subs(mCashName,1,min(10,at(" ",mCashName))),20)
                DISPTEXTXY(2,1,0,0,0,0,out_text)
                MsgAreaDisp("TEMPORARY SIGN-OFF..")
                cCode := ""                        
                // disable sound...
                set_key_sound(OFF)       
                while keylock() == 0
                    cKey := input()                             
                enddo    
                // enable sound
                set_key_sound(ON)                                                      
             case keylock() == 1   
                ScrollOff()                  
                disp_ready()                
                DISPTEXTXY(3, 1, 0, 0, 0, 0, "MESSAGE : TEMPORARY ")
                DISPTEXTXY(2,11,0,0,2,10, "_      " )
                while .T. 

                  DISPTEXTXY(2,11,0,0,2,10, pad(subs(cCode,1,3)+repl("*",len(cCode)-3)+"_",6) )
*                  Disp_Data(pad(subs(cCode,1,3)+repl("*",len(cCode)-3)+"_",6) )
                  cKey := input()                  

                  do case 
                     case IS_KEYCHANGE(cKey) 
                        if keylock() != KEY_LOCK_POS1           
                           exit
                        endif   
                     case !empty(cData := is_number( cKey ))
                        if cData != "." .and. len(cCode) < 6
                            cCode += cData
                        endif      
                     case cKey == BACK_SPACE
                        cCode := subs(cCode,1,len(cCode)-1)
                     case cKey == CLR
                        cCode := ""   
                        DISPTEXTXY(2,11,0,0,2,10, "_      " )
                     case cKey == ENTER
                        if cCode == mCashCode            
                           lRetVal:= .T.
                           exit
                        else
                           cCode := ""
                           ErrorDisp("INVALID CASHIER CODE")
                           MsgAreaDisp(MSG_D002)
                           DISPTEXTXY(2,11,0,0,2,10, "_      " )
                        endif   
                     otherwise
                  endcase                            
                   
                enddo                   
        
                ScrollOn()                                  
          otherwise      
                SetAlarm("INVALID KEY LOCK POS")
                while keylock() != KEY_LOCK_POS0 .and. keylock() != KEY_LOCK_POS1
                  cKey := input()
                enddo  
                SetAlarm()
          endcase      
       enddo
       ScrollOff()                  
       CloseWindow(wWindow)
    endif
    
return lRetVal

function lcs_reset(lVar)
  if valtype( lVar ) == "L"
     lCashReset :=  lVar
  endif
return lCashReset

/*------------eof------------*/