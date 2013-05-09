#include "fileio.ch"
#include "offline.ch"
#include "config.ch"
#include "pfl_clip.ch"
#include "powerpos.ch"
#include "nvr_file.ch"
#include "file_acc.ch"
#include "itemtran.ch"

#define TRANS_FLAG subs(cBuffer,30,1)
#undef  COMPLETE

static off_handle
static lOpen  := .F.
static mOff_Date, mOff_Time, mOff_Cntr := "    ", mOff_Sale := "    "

function reset_nvr()
local i := 0,n,k
local cData 
local cOutData
local cBuffer 
local cIndata := space(FA_SZ_ITM)
local status := 0
local cPath := GetLocal_Path()
local cHeader := formHeader(FC_SRCHPUT,FP_ONE,FA_FN_ITM)

#ifdef DEF_DISP4X20
   DISPTEXTXY(4,20,0,0,0,0,chr(126))
#endif  

  MsgAreaDisp("Please wait recording to electronic journal...")

  k := nvr_nITMitems()
  // then decide what to do with the transaction files
  for n:= 1 to k
  
    cData := get_Trans( n )
    
    cOutData := form_tran(cData)        
    status := f_access(@cHeader, cOutData, @cIndata, cPath)

    if status != NORMAL
       MsgAreaDisp("Not Able to save electronic journal "+padl(status,4))
       error_log("Not Able to save electronic journal "+padl(status,4))
    endif

  next n

  MsgAreaDisp()
  nvr_nITMitems( 0 )

return nil

function offline(cNew_Buff)
local i,n,k,nOffset
local nLine_Size
local cBuffer := ""
local status := NORMAL
local cIndata := space(FA_SZ_ITM)
local cHeader := formHeader(FC_SRCHPUT,FP_ZERO,FA_FN_ITM)
local nAmount
local nRetries
local fh

   // This is a semaphore to bare witness if the offline file is
   // already open or needs reopening
   if !lOpen
      off_handle := FOPEN ( OFFLINE_FILENAME , FO_READWRITE )
      if (ferror() == 2)
          off_handle := FCREATE( OFFLINE_FILENAME, FC_NORMAL )
          ? 
          ? " Im re-Writing the "
          ?? OFFLINE_FILENAME
          tone(300,18)              
          status := ferror()

          mOff_Date := dtoc(date())
          mOff_Time := time()
          mOff_Cntr := ieereal(0)
          mOff_Sale := ieereal(0)          
          
          // write the header of the file 
          nLine_Size := OFF_HEAD_LEN          
          cBuffer := mOff_Date
          cBuffer += mOff_Time 
          cBuffer += mOff_Cntr
          cBuffer += mOff_Sale           
          fseek(off_handle, 0 , FS_SET)
          c_fwrite(off_handle, cBuffer, @nLine_size )
          if nLine_Size != OFF_HEAD_LEN
             // post to error file
             error_log ("Error offline file initialize, " +ltrim(str(ferror())),1)
          endif          
      endif   

      if status == NORMAL
         cBuffer := space(OFF_HEAD_LEN)
         fseek( off_handle, 0 , FS_SET)
         if fread( off_handle, @cBuffer, OFF_HEAD_LEN ) != OFF_HEAD_LEN
             error_log("OFFLINE file reading failed at download, " +;
                      ltrim(str(ferror())) + '.')         
         endif

         mOff_Date := subs(cBuffer,OFF_DATE_OFF,OFF_DATE_LEN)
         mOff_Time := subs(cBuffer,OFF_TIME_OFF,OFF_TIME_LEN)
         mOff_Cntr := subs(cBuffer,OFF_CNTR_OFF,OFF_CNTR_LEN)
         mOff_Sale := subs(cBuffer,OFF_SALE_OFF,OFF_SALE_LEN)                     
         lOpen := .T.
      else  
         ErrorDisp("Error Opening/Creating Offline file."+str(ferror()))
         error_log("Error Opening/Creating Offline file."+str(ferror()))
         power_end()       
      endif   
  endif    
       
  if isServer_Mode()

      MsgAreaDisp(" Trying Network Connectivity. Please Wait... ")    
      fh := fopen(GetServer_Path()+"NUL")
//      MsgAreaDisp()            
      if ( ferror() == 3 )
         clearkeys()
         isServer_Mode(.F.)
         Disp_Comm(.F.)      
         offl_put(cNew_Buff)    
      else                    
        k:= Off_nCntr()

        for n:= 1 to k

           MsgAreaDisp("Network Re-Established! Downloading Offline data...")        
           nOffset := OFF_HEAD_LEN + ( (n-1)  * 128 )
           cBuffer := space(128)
      
           nAmount := Off_nSale() 
      
           if fseek( off_handle, nOffset , FS_SET) != nOffset
              error_log("OFFLINE file seek failed at download, " +;
              ltrim(str(ferror())) + '.')         
           else
              if fread( off_handle, @cBuffer , 128 ) != 128 
                error_log("OFFLINE file read failed at download, " +;
                ltrim(str(ferror())) + '.')                  
              else  
                if subs( cBuffer,1,1) != "*" 

                   // no more retries because we are already in offline mode 

                   cHeader := formHeader(FC_SRCHPUT,FP_ZERO,FA_FN_ITM)   
                   if ((status := f_access(@cHeader,cBuffer,@cIndata, GetServer_Path() )) != NORMAL)
                      Disp_Comm(.F.)   
                   endif 
              
                   if status == NORMAL

                      Off_nCntr(Off_nCntr()-1)

                      if subs(cBuffer,30,1) $ POSITIVE_OPER_FLAG // trans flag
                        Off_nSale( nAmount + val(subs(cBuffer,85,12)) * 0.01 )
                      elseif  subs(cBuffer,30,1) $ NEGATIVE_OPER_FLAG
                        Off_nSale( nAmount - val(subs(cBuffer,85,12)) * 0.01 )
                      elseif  subs(cBuffer,30,1) $ DONOTHING_OPER_FLAG  
                        // DO ABSOLUTELY NOTHING A....
                      else 
                        error_log ("Error Unrecognized trans. flag at offline put: "+TRANS_FLAG)
                      endif  
                               
                      cBuffer := repl("*",128)
                      nLine_Size := 128
                      fseek( off_handle, nOffset, FS_SET )
                      c_fwrite( off_handle, cBuffer , @nLine_Size ) 
                      if nLine_Size != 128
                          error_log("OFFLINE file write failed at download, " +;
                          ltrim(str(ferror())) + '.')
                      endif
                   else
                      ? "  Error: File Acc "+padl(status,4,"0")              
                      if status == 1  
                         // disable further network retries for is in vain
                         isServer_Mode(.F.)
                      endif 
                      exit   
                   endif     
              
                endif  
                // Just skip the record...       
              endif
           endif                  
        next

        MsgAreaDisp()
  #ifdef COMPLETE
        nOffset := OFF_HEAD_LEN + ( (++n-1)  * 128 )
        fseek( off_handle, nOffset , FS_SET)  
        while fread( off_handle, @cBuffer , 128 ) == 128
          if subs( cBuffer ,1,1) != "*" 

        // no more retries because we are already in offline mode 

             cHeader := formHeader(FC_SRCHPUT,FP_ZERO,FA_FN_ITM)   
             if ((status := f_access(@cHeader,cBuffer,@cIndata, GetServer_Path() )) != NORMAL)
                 Disp_COmm(.F.)
             endif 
              
             if status == NORMAL
              
                if TRANS_FLAG $ POSITIVE_OPER_FLAG
                  Off_nSale( nAmount + val(subs(cBuffer,85,12)) * 0.01 )
                elseif  TRANS_FLAG $ NEGATIVE_OPER_FLAG
                  Off_nSale( nAmount - val(subs(cBuffer,85,12)) * 0.01 )
                elseif  TRANS_FLAG $ DONOTHING_OPER_FLAG  
                  // DO ABSOLUTELY NOTHING A....
                else 
                  error_log ("Error Unrecognized trans. flag at offline put: "+TRANS_FLAG)
                endif  
                               
                cBuffer := repl("*",128)
                nLine_Size := 128
                fseek( off_handle, nOffset, FS_SET )
                c_fwrite( off_handle, cBuffer , @nLine_Size ) 
                if nLine_Size != 128
                    error_log("OFFLINE file write failed at download, " +;
                    ltrim(str(ferror())) + '.')
                endif
             else
                ? "  Error: File Acc "+padl(status,4,"0")              
                if status == 1  
                   // disable further network retries for is in vain
                   isServer_Mode(.F.)
                endif               
                exit   
             endif     
              
          endif     
          nOffset := OFF_HEAD_LEN + ( (++n-1)  * 128 )
          fseek( off_handle, nOffset , FS_SET) 
        enddo
  #endif

        if status == NORMAL

           Off_nCntr(0)
         
           if !empty(cNew_Buff)
         
             cHeader := formHeader(FC_SRCHPUT,FP_ZERO,FA_FN_ITM)   
             status := f_access(@cHeader,cNew_Buff,@cIndata, GetServer_Path() )
             nRetries := val(config(POS_NUM_RETS))
          
             while (status != NORMAL) .and. (--nRetries > 0)
                if ((status := f_access(@cHeader,cNew_Buff,@cIndata, GetServer_Path() )) == NORMAL)
                   exit
                endif 
                Disp_Comm(.F.) 
             enddo   

             if status != NORMAL
                Disp_Comm(.F.)         
                offl_put(cNew_Buff)    
                isServer_Mode(.F.) // not available... or network error         
             endif
           
          endif    
        else  
          Disp_Comm(.F.)         
          offl_put(cNew_Buff)    
          isServer_Mode(.F.) // not available... or network error                 
        endif
     endif 
   else  
      Disp_Comm(.F.)         
      offl_put(cNew_Buff)    
      isServer_Mode(.F.) // not available... or network error                       
   endif

   fclose(fh)

return status == NORMAL

function Off_dDate(dDate)
 if dDate != NIL
    mOff_Date := dtoc(dDate)
    Update_Off()
 endif
return ctod(mOff_Date)

function Off_cTime(cTime)
  if cTime != NIL
     mOff_Time := cTime
     Update_Off()
  endif
return mOff_Time

function Off_nCntr(nVar)
  if nVar != NIL
     mOff_Cntr := ieereal(nVar)
     Update_Off()     
  endif
return realiee(mOff_Cntr)

function Off_nSale(nVar)
  if nVar != NIL
     mOff_Sale := ieereal(nVar)
     Update_Off()
  endif
//  ? " mOff_Sale : "
//  ?? mOff_Sale
//  ? " RealIee(mOff_Sale) :"
//  ?? realiee(mOff_Sale)
return realiee(mOff_Sale)

function offl_close()
  if lOpen
     fclose(off_handle)
  endif   
return nil

function Offl_put(cBuffer)
local n := Off_nCntr() + 1
local nAmount := Off_nSale()
local nLine_Size := OFF_DATA_LEN

if !empty(cBuffer) 
 
   if !lopen
      error_log("Error "+OFFLINE_FILENAME+" should have been opened before Offl_put " , 1)
   endif   

   fseek(off_handle, OFF_HEAD_LEN + ( (n-1) * OFF_DATA_LEN ) , FS_SET)
   c_fwrite( off_handle, cBuffer, @nLine_Size )
   if nLine_Size != OFF_DATA_LEN
  *     ? "Error in offl_put len : "
  *     ?? nLine_Size
       error_log("OFFLINE file write"+str(nLine_Size)+" failed at offl_Put(), " +;
       ltrim(str(ferror())) + '.') 
   else
  *     ? " Offline Put now normalizing transaction with FLAG : "
  *     ?? TRANS_FLAG
       Off_nCntr(n)   
       if TRANS_FLAG $ POSITIVE_OPER_FLAG
	 Off_nSale( nAmount + val(subs(cBuffer,85,12)) * 0.01 )
  *       ? " Added the total sales... "
       elseif TRANS_FLAG $ NEGATIVE_OPER_FLAG
	 if !(TRANS_FLAG $ "VG")
	   Off_nSale( nAmount - val(subs(cBuffer,85,12)) * 0.01 )
  *         ? " Subtracted the total sales ... "
	 endif  
       elseif  TRANS_FLAG $ DONOTHING_OPER_FLAG  
	 // DO ABSOLUTELY NOTHING A....
  *         ? " Doing nothing..."
       else 
	 error_log ("Error Unrecognized trans. flag at offline put: "+TRANS_FLAG)
       endif  
   endif
   
endif 
   
return nil

function Update_off()
local cBuffer
local nLine_Size := OFF_HEAD_LEN

  if !lOpen
      error_log("Error "+OFFLINE_FILENAME+" should have been opened before Updates" , 1)    
  endif 
  
#ifdef DEBUG
  if len(mOff_Date) != OFF_DATE_LEN
    DispStatus("Mismatch mOff_Date length")  
  endif
  if len(mOff_Time) != OFF_TIME_LEN
    DispStatus("Mismatch mOff_Time length")  
  endif       
  if len(mOff_Cntr) != OFF_CNTR_LEN
    DispStatus("Mismatch mOff_Cntr length")  
  endif
  if len(mOff_Sale) != OFF_SALE_LEN
    DispStatus("Mismatch mOff_Sale length")  
  endif     
#endif    
  
  cBuffer :=  mOff_Date + ;
              mOff_Time + ;
              mOff_Cntr + ;
              mOff_Sale 

  if len(cBuffer) != OFF_HEAD_LEN
    DispStatus("Mismatch cBuffer of Offline length")  
  endif
              
  fseek(off_handle, 0 ,FS_SET)
  c_fwrite( off_handle, cBuffer , @nLine_Size)
  if nLine_Size != OFF_HEAD_LEN
     error_log("OFFLINE file write failed at Update_off(), " +;
     ltrim(str(ferror())) + '.') 
  endif 
    
return nil

function form_tran(cData)
local cBuffer
local cFlag
local nTemp

 cFlag := subs(cData,TRAN_FLAG_OFF,TRAN_FLAG_LEN)

  cBuffer := padl(right(alltrim(config(POS_TERM_NUM)),4),4,"0")
  cBuffer += dtoc(date())
  cBuffer += time()
  cBuffer += padl(nvr_nTrans()-1,NVR_TRN_LEN,"0")    
  cBuffer += padl(subs(cData,TRAN_PFLG_OFF,TRAN_PFLG_LEN),TRAN_PFLG_LEN,"0")
  cBuffer += cFlag
  cBuffer += nvr_cCashCode()         

  if cFlag == "Z" .or. cFlag == "1" .or. ;
     cFlag == "2" .or. cFlag == "3" .or. ;
     cFlag == "4" .or. cFlag == "5" .or. ;
     cFlag == "6" .or. cFlag == "7" .or. ;
     cFlag == "8" .or. cFlag == "9" .or. cFlag == "0";

     cBuffer += padl(subs(cData,TRAN_PRCM_OFF,TRAN_PRCM_LEN),CUST_PAYM_LEN,"0") // Paymt
     nTemp := realiee(subs(cData,TRAN_SALE_OFF,TRAN_SALE_LEN)) 
     cBuffer += padl(alltrim(strtran(str(nTemp),".","")),CUST_SALE_LEN,"0") // sale amount
     cBuffer += padl(realiee(subs(cData,TRAN_CNTR_OFF,TRAN_CNTR_LEN)),CUST_CNTR_LEN,"0") // quantity items
     cBuffer += padl(subs(cData,TRAN_CRG1_OFF,TRAN_CRG1_LEN),CUST_CRG1_LEN,"0")      // Ist Cargo field  
     cBuffer += padl(subs(cData,TRAN_CRG2_OFF,TRAN_CRG3_LEN),CUST_CRG2_LEN,"0")
     cBuffer += padl(subs(cData,TRAN_CRG3_OFF,TRAN_CRG3_LEN),CUST_CRG3_LEN,"0")
     cBuffer += repl("0",CUST_RESV_LEN)
     cBuffer += chr(13)+chr(10)                                
     tran_cCrg1("")                    // ist cargo
     tran_cCrg2("")                    // 2nd cargo
     tran_cCrg3("")                    // 3rd cargo     // Reset all cargo     
  else
     cBuffer += subs(cData,TRAN_CLRK_OFF,TRAN_CLRK_LEN) 
     cBuffer += subs(cData,TRAN_REGM_OFF,TRAN_REGM_LEN)
     cBuffer += subs(cData,TRAN_PRCM_OFF+1,TRAN_PRCM_LEN-1)
     cBuffer += subs(cData,TRAN_PRLV_OFF,TRAN_PRLV_LEN) 
     cBuffer += subs(cData,TRAN_PLU_OFF,TRAN_PLU_LEN)  
     cBuffer += subs(cData,TRAN_ITEM_OFF,TRAN_ITEM_LEN)
     cBuffer += subs(cData,TRAN_DEPT_OFF,TRAN_DEPT_LEN)
     cBuffer += subs(cData,TRAN_CONC_OFF,TRAN_CONC_LEN)
     cBuffer += subs(cData,TRAN_COLO_OFF,TRAN_COLO_LEN)
     cBuffer += subs(cData,TRAN_SIZE_OFF,TRAN_SIZE_LEN)
     nTemp  := realiee(subs(cData,TRAN_SALE_OFF,TRAN_SALE_LEN))
     cBuffer += padl(alltrim(strtran(str(nTemp),".","")),12,"0")
     cBuffer += padl(realiee(subs(cData,TRAN_CNTR_OFF,TRAN_CNTR_LEN)),10,"0")
     cBuffer += padl(subs(cData,TRAN_PRCM_OFF,TRAN_PRCM_LEN),4,"0")
     cBuffer += subs(cData,TRAN_CRGO_OFF,TRAN_CRGO_LEN)
     cBuffer += "0000"
     cBuffer += chr(13)+chr(10)        
  endif
  
return cBuffer


function send_sign_onoff(lSignon)
local cHeader
local i,status:= 0
local cIndata := space(FA_SZ_ITM)
local cOutData,fh

  if !lSignOn .and. !isServer_Mode()
     MsgAreaDisp(" Trying Network Connectivity. Please Wait... ")    
     fh := fopen(GetServer_Path()+"NUL")
     MsgAreaDisp()            
     if ( ferror() != 3 )
         isServer_Mode(.T.)
         Disp_Comm(.T.)      
     endif  
     fclose(fh)
  endif
  
  offline()

 cOutData := padl(right(alltrim(config(POS_TERM_NUM)),4),4,"0")
 cOutdata += dtoc(date())
 cOutdata += time()
 cOutdata += padl(nvr_nTrans()-1,NVR_TRN_LEN,"0")  
 cOutdata += repl("0",TRAN_PFLG_LEN)
 if lSignOn
   cOutData += "!" // sign_on
 else
   cOutData += "?" // sign off
 endif  
 cOutdata += nvr_cCashCode()         
 cOutdata += pad(nvr_cCashName() + if(lSignOn," SIGN ON "," SIGN OFF ") , ;
   CUST_PAYM_LEN + ;
   CUST_SALE_LEN + ;
   CUST_CNTR_LEN + ;
   CUST_CRG1_LEN + ;
   CUST_CRG2_LEN + ;
   CUST_CRG3_LEN + ;
   CUST_RESV_LEN ,"0")
                       
 cOutdata += chr(13)+chr(10)                                

 if isServer_Mode()  .and. Off_nCntr() == 0

    cHeader := formHeader(FC_SRCHPUT,FP_ZERO,FA_FN_ITM)    
    status := f_access(@cHeader, cOutData, @cIndata, GetServer_Path() )
 
    i := 1
    while status != NORMAL .and. i++ < val(config(POS_NUM_RETS))
       cHeader := formHeader(FC_SRCHPUT,FP_ZERO,FA_FN_ITM)    
       if ((status := f_access(@cHeader, cOutData, @cIndata, GetServer_Path() )) == NORMAL)
          exit
       endif
       Disp_Comm(.F.)
    enddo

#ifdef DEBUG
    ? " File access status : "
    ?? status 
   if status != NORMAL
      DISPTEXTXY(4,1,0,0,2,1,"Error: File Acc "+padl(status,4,"0"))
      ? "Error faccess : "
      ?? status 
   endif
#endif
    
    if status != NORMAL  
        if status == 1
           isServer_Mode(.F.) 
        endif
*        ? "Error in File access : "+padl(status,4) 
        offl_put(cOutdata)
    endif
 else
   Disp_Comm(.F.)
   offl_put(cOutdata)   
 endif         
 
return nil        


/*

function plu_dept_count()
local n,k
local nAmount,nQty
local cPLUCode,cDept
local cFlag,cBuffer,nDivisor

  k := nvr_nITMitems()
  // then decide what to do with the transaction files
  nvr_lStatus(.T.) 

  MsgAreaDisp("Please Wait....")  
  Disp_Data()

  nDivisor := 50/k
  
  for n:= k to 1 step -1  

    Disp_Data(repl("o",n*nDivisor))
    
    cBuffer := get_trans(n)

    cFlag   := subs(cBuffer,TRAN_FLAG_OFF,TRAN_FLAG_LEN) 
        
    do case
       case cFlag == OP_NPLU_FLAG  
            cPLUCode := subs(cBuffer,TRAN_PLU_OFF,TRAN_PLU_LEN)
            nAmount  := realiee(subs(cBuffer,TRAN_SALE_OFF,TRAN_SALE_LEN))
            nQty     := realiee(subs(cBuffer,TRAN_CNTR_OFF,TRAN_CNTR_LEN))
            cDept    := subs(cBuffer,TRAN_DEPT_OFF,TRAN_DEPT_LEN)
            plu_counter(cPLUCode, nQty, nAmount, 0)
            dept_counter(cDept, nQty, nAmount, 0)
       case cFlag == OP_OPEN_FLAG
            nAmount  := realiee(subs(cBuffer,TRAN_SALE_OFF,TRAN_SALE_LEN))
            nQty     := realiee(subs(cBuffer,TRAN_CNTR_OFF,TRAN_CNTR_LEN))
            cDept    := subs(cBuffer,TRAN_DEPT_OFF,TRAN_DEPT_LEN)
            dept_counter(cDept, nQty, nAmount, 0)
       case cFlag == OP_IDSC_FLAG 
            cDept    := subs(cBuffer,TRAN_DEPT_OFF,TRAN_DEPT_LEN)
            nAmount  := realiee(subs(cBuffer,TRAN_SALE_OFF,TRAN_SALE_LEN))
            dept_counter(cDept, 0, 0, nAmount)
            if subs(cBuffer,TRAN_PFLG_OFF,TRAN_PFLG_LEN) == OP_NPLU_FLAG
               cPLUCode := subs(cBuffer,TRAN_PLU_OFF,TRAN_PLU_LEN)
               plu_counter(cPLUCode, 0, 0, nAmount)
            endif  
 //    case cFlag == OP_OINC_FLAG
 //             do nothing
       case cFlag == OP_REXC_FLAG
            cPLUCode := subs(cBuffer,TRAN_PLU_OFF,TRAN_PLU_LEN)
            nAmount  := realiee(subs(cBuffer,TRAN_SALE_OFF,TRAN_SALE_LEN))
            nQty     := realiee(subs(cBuffer,TRAN_CNTR_OFF,TRAN_CNTR_LEN))
            cDept    := subs(cBuffer,TRAN_DEPT_OFF,TRAN_DEPT_LEN)       
            plu_counter(cPLUCode, -nQty, -nAmount, 0)
            dept_counter(cDept, -nQty, -nAmount, 0)          
       case cFlag == OP_NOTF_FLAG
            cDept    := subs(cBuffer,TRAN_DEPT_OFF,TRAN_DEPT_LEN)
            nQty     := realiee(subs(cBuffer,TRAN_CNTR_OFF,TRAN_CNTR_LEN))
            nAmount  := realiee(subs(cBuffer,TRAN_SALE_OFF,TRAN_SALE_LEN))       
            dept_counter(cDept, nQty, nAmount, 0)           
 //    case cFlag == OP_ADON_FLAG
 //    case cFlag == OP_RFND_FLAG            
 //         plu_counter(cPLUCode, -nQty, -nAmount, 0)
 //         dept_counter(cDept, -nQty, -nAmount, 0)           
       endcase      

       nvr_nITMitems(n)
 next n     

 nvr_nITMitems(0)
 nvr_lStatus(.F.) 

 MsgAreaDisp()

return nil
*/

/* ------------------ eof ---------------------*/
 