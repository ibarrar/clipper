/* 
   plu_file.prg
   created : 04-29-97

   rci
*/

#include "plu_file.ch"
#include "plu_temp.ch"
#include "file_Acc.ch"
#include "config.ch"
#include "fileio.ch"
#include "terminal.ch"

#define DEF_WHOLESALE

#ifndef NORMAL
 #define NORMAL 0
#endif

#define  CRLF            ( CHR(13) + CHR(10) )            // Control Line Feed
static _cPrice_Level := PRICE_LEVEL_0

static _cPLUCode
static _cPLUItem
static _cPLUDesc
static _cPLUDept
static _cPLUPric
static _cPLUCost
static _cPLUConc
static _cPLUColo
static _cPLUSize
static _lPLUSDpt := .F.

static _cPrev_Code := ""

static _cPLUPric0
static _cPLUPric1
static _cPLUPric5

function PLU_Get( cData )
local cHeader
local cOutData
local cIndata
local status := -1

#ifdef DEBUG
   if len(cData) != PLU_CODE_LEN
      ErrorDisp("Programmer Error incorrect parameter len PLU")
      return .F.
   endif    
#endif      

   cHeader := formHeader(FC_SRCHGET,FP_ZERO,FA_FN_PLU)   
   cOutData := cData
   cInData := space(PLU_SIZE)

*   MsgAreaDisp("Please wait, Accessing Master file...")   

   status := f_access(@cHeader,cOutData,@cIndata,GetPLU_Path())
   
   if status == NORMAL

      _cPLUCode := subs(cIndata,PLU_CODE_OFF,PLU_CODE_LEN)
      _cPLUItem := subs(cIndata,PLU_ITEM_OFF,PLU_ITEM_LEN)
      _cPLUDesc := subs(cIndata,PLU_DESC_OFF,PLU_DESC_LEN)
      _cPLUDept := subs(cIndata,PLU_DEPT_OFF,PLU_DEPT_LEN)
      _cPLUCost := subs(cIndata,PLU_PRI6_OFF,PLU_PRI6_LEN)
      _cPLUConc := subs(cIndata,PLU_CONC_OFF,PLU_CONC_LEN)
      _cPLUColo := subs(cIndata,PLU_COLO_OFF,PLU_COLO_LEN)
      _cPLUSize := subs(cIndata,PLU_SIZE_OFF,PLU_SIZE_LEN)
      _cPLUPric := subs(cIndata,PLU_PRI1_OFF,PLU_PRI1_LEN)
      _lPLUSdpt := subs(cIndata,PLU_STAT_OFF+1,1) == "1"
      _cPLUPric0:= subs(cIndata,PLU_PRIC_OFF,PLU_PRIC_LEN) // default retail price     
      _cPLUPric1:= subs(cIndata,PLU_PRI1_OFF,PLU_PRI1_LEN)
      _cPLUPric5:= subs(cIndata,PLU_PRI5_OFF,PLU_PRI5_LEN)

      do case 
         case ( _cPrice_Level == PRICE_LEVEL_1 )
          _cPLUPric := _cPLUPric1
          _cPLUDesc := pad(chr(127)+_cPLUDesc,PLU_DESC_LEN)
         case ( _cPrice_Level == PRICE_LEVEL_2 )
          _cPLUPric := subs(cIndata,PLU_PRI2_OFF,PLU_PRI2_LEN)               
         case ( _cPrice_Level == PRICE_LEVEL_3 )
          _cPLUPric := subs(cIndata,PLU_PRI3_OFF,PLU_PRI3_LEN)               
         case ( _cPrice_Level == PRICE_LEVEL_4 )
          _cPLUPric := subs(cIndata,PLU_PRI4_OFF,PLU_PRI4_LEN)                                             
         otherwise   
          _cPLUPric := _cPLUPric0     // default retail price     
          _cPrice_Level := PRICE_LEVEL_0
      endcase    

      _cPrev_Code := _cPLUCode
      _cPrice_Level := PRICE_LEVEL_0
      config(POS_PRICE_DEFAULT,"00")
   endif   

*   MsgAreaDisp("")

return (status == NORMAL)


function cPLU_PLev( cVal )

 if valtype (cVal) == "C"
    _cPrice_Level := cVal
 endif

return _cPrice_Level

function cPLU_Code()
return _cPLUCode

function cPLU_Item()
return _cPLUItem

function cPLU_Desc()
return _cPLUDesc

function cPLU_Dept()
return _cPLUDept

function nPLU_Pric()
return realiee(_cPLUPric)

function nPLU_Cost()
return realiee(_cPLUCost)

function nPLU_Pric0()
return realiee(_cPLUPric0)

function nPLU_Pric1()
return realiee(_cPLUPric1)

function cPLU_Conc()
return _cPLUConc

function cPLU_Colo()
return _cPLUColo

function cPLU_Size()
return _cPLUSize

function cPLU_Prev()
return _cPrev_Code 

function lPLU_Sdpt()
return _lPLUSdpt

function lNFND_ADD(cCode,cDesc,cDept,nQty,nPrice,nDiscount)
local cIndata
local cOutdata
local status := -1

  // if in training mode don't add to totals
  if !nvr_lTRNG_Mode()
  
       cIndata := space(FA_SZ_PLT)
            
       cOutData := cCode
       cOutData += cDept          
       cOutData += pad(cDesc,TMP_DESC_LEN)
       cOutData += ieereal( nPrice ) 
       cOutData += ieereal( nQty )  
       cOutData += ieereal( nDiscount ) 
       cOutData += ieereal( val(_cPrice_Level) )          
 
       status := file_access(FA_CMD_SRCHPUT,FA_PRM_ZERO,FA_FN_PLT,FA_SZ_PLT,cOutdata,@cIndata,GetPLU_Path())

       if status !=  NORMAL
          MsgAreaDisp(" Error in PLU TEMP update :"+str(status))                
       endif  
   endif            

return status == NORMAL 

 
// used by askserv.prg
function formPLU(cData)
local cOut := subs(cData,FM_PLU_CODE_OFF,PLU_CODE_LEN)
   cOut += subs(cData,FM_PLU_ITEM_OFF,PLU_ITEM_LEN)
   cOut += subs(cData,FM_PLU_DESC_OFF,PLU_DESC_LEN)
   cOut += subs(cData,FM_PLU_SIZE_OFF,PLU_SIZE_LEN)
   cOut += subs(cData,FM_PLU_COLO_OFF,PLU_COLO_LEN)
   cOut += subs(cData,FM_PLU_CLAS_OFF,PLU_CLAS_LEN)
   cOut += subs(cData,FM_PLU_DEPT_OFF,PLU_DEPT_LEN)
   cOut += subs(cData,FM_PLU_CONC_OFF,PLU_CONC_LEN)
   cOut += ieereal(val(subs(cData,FM_PLU_PRIC_OFF,10))*0.01)
   cOut += ieereal(val(subs(cData,FM_PLU_PRI1_OFF,10))*0.01)
   cOut += ieereal(val(subs(cData,FM_PLU_PRI2_OFF,10))*0.01)
   cOut += ieereal(val(subs(cData,FM_PLU_PRI3_OFF,10))*0.01)
   cOut += ieereal(val(subs(cData,FM_PLU_PRI4_OFF,10))*0.01)
   cOut += ieereal(val(subs(cData,FM_PLU_PRI5_OFF,10))*0.01)
   cOut += ieereal(val(subs(cData,FM_PLU_PRI6_OFF,10))*0.01)
   cOut += subs(cData,FM_PLU_STRT_OFF,PLU_STRT_LEN)
   cOut += subs(cData,FM_PLU_ENDT_OFF,PLU_ENDT_LEN)
   cOut += subs(cData,FM_PLU_BQTY_OFF,PLU_BQTY_LEN)
   cOut += subs(cData,FM_PLU_DOWK_OFF,PLU_DOWK_LEN)
   cOut += ieereal(val(subs(cData,FM_PLU_DRAT_OFF,04)))
   cOut += ieereal(val(subs(cData,FM_PLU_DAMT_OFF,10))*0.01)
   cOut += ieereal(val(subs(cData,FM_PLU_SSDR_OFF,04)))
   cOut += ieereal(val(subs(cData,FM_PLU_SSDA_OFF,10))*0.01)
   cOut += ieereal(val(subs(cData,FM_PLU_TAX1_OFF,10))*0.01)
   cOut += subs(cData,FM_PLU_STAT_OFF,PLU_STAT_LEN)
   cOut += subs(cData,FM_PLU_DLTD_OFF,PLU_DLTD_LEN)         
   cOut += ieereal(val(subs(cData,FM_PLU_STCK_OFF,10))*0.001)
   // cOut += space(PLU_TTLS_LEN) // Dummy data for counters          
return cOut


function plu_report(lVar,lReset)
local cOutData := repl("-",PLU_CODE_LEN)
local cInData  := space(PLU_SIZE)
local status   := NORMAL
local outdata  := "PLU REPORT " 
local cHeader
local nTotals
local nCounter
local nGrandTot := 0
local nGrandCnt := 0
local nPLUTot := 0
local nPLUCnt := 0

 outdata += space(12)
 outdata += if(lReset,"Z","X")
 outdata += "-READING"
  
 A_RJS_PRNT(1, 1, 0,  outdata, 0)
 
 // skip line/s
 A_RJS_FEED(1, 1, 0, 1)     

 cHeader := formHeader(FC_GETCNTR,if(lVar,FP_ONE,FP_ZERO),FA_FN_PLU)
 cInData := space(PCO_CNTR_SIZE)
 
 while status == NORMAL 

   status := f_access(@cHeader,cOutData,@cIndata,GetLocal_Path())

   nCounter := realiee(subs(cIndata,PCO_PL0Q_OFF,PLU_PL0Q_LEN))
   nTotals :=  realiee(subs(cIndata,PCO_PL0A_OFF,PLU_PL0A_LEN))

   nCounter += realiee(subs(cIndata,PCO_PL1Q_OFF,PLU_PL1Q_LEN))
   nTotals +=  realiee(subs(cIndata,PCO_PL1A_OFF,PLU_PL1A_LEN))

   if !empty(cIndata) .and. (( nCounter + nTotals != 0 ) .or. !lVar )
   
        outdata := subs(cIndata,PCO_CODE_OFF,PLU_CODE_LEN)+space(4)
        outdata += trans(nTotals,"999,999,999.99")
        A_RJS_PRNT(1, 1, 0, outdata, 0)
        outdata := subs(cIndata,PCO_DESC_OFF,PLU_DESC_LEN)
        outdata += trans(nCounter," 999,999,999")
        A_RJS_PRNT(1, 1, 0, outdata, 0)
        nPLUTot += nTotals
        nPLUCnt += nCounter
        
        if lReset      
        
           cOutData := subs(cIndata,PCO_CODE_OFF,PLU_CODE_LEN)
           cOutData += ieereal(0) //QUANTITY
           cOutData += ieereal(0) //AMOUNT
           cOutData += ieereal(0) //DISCOUNT
           cOutData += ieereal(0) //LEVEL

           cHeader := formHeader(FC_PUTCNTR,FP_ONE,FA_FN_PLU)     
           
           // " Reset Status : "
           f_access(@cHeader,cOutData,@cIndata,GetLocal_Path())
           
           cHeader := formHeader(FC_GETCNTR,if(lVar,FP_ONE,FP_ZERO),FA_FN_PLU)     
           cInData := space(PCO_CNTR_SIZE)
        endif        

   endif
   
   cOutData := repl("+",PLU_CODE_LEN)  
   
 enddo  

 A_RJS_FEED(1,1,0,1)
 A_RJS_PRNT(1,1,0, repl("-",32),0)
 outdata := "TOTAL"+space(13)+trans(nPLUTot,"999,999,999.99")
 A_RJS_PRNT(1,1,0,outdata,0)
 outdata := padl(trans(nPLUCnt,"999,999,999"),32)
 A_RJS_PRNT(1, 1, 0, outdata, 0)
 nGrandTot := nPLUTot 
 nGrandCnt := nPLUCnt
 nPLUTot   := 0
 nPLUCnt   := 0
 
 A_RJS_FEED(1,1,0,1)
 outdata += "NOT FOUND PLU REPORT   "
 outdata += if(lReset,"Z","X")
 outdata += "-READING"
  
 A_RJS_PRNT(1, 1, 0,  outdata, 0)
 
 // skip line/s
 A_RJS_FEED(1, 1, 0, 1)     

 cHeader  := formHeader(FC_SRCHGET,FP_ZERO,FA_FN_PLT)
 cInData  := space(PLUTEMP_SIZE)
 cOutData := repl("0",TMP_CODE_LEN)

 status := NORMAL 
 while status == NORMAL 

   status := f_access(@cHeader,cOutData,@cIndata,GetLocal_Path())
   
   if status == NORMAL .or. status == 9

        nCounter := realiee(subs(cIndata,TMP_CNTR_OFF,TMP_CNTR_LEN))
        nTotals  :=  realiee(subs(cIndata,TMP_AMNT_OFF,TMP_AMNT_LEN))
        
        outdata  := subs(cIndata,TMP_CODE_OFF,TMP_CODE_LEN)+space(4)
        outdata  += trans(nTotals,"999,999,999.99")
        A_RJS_PRNT(1, 1, 0, outdata, 0)
        outdata  := subs(cIndata,TMP_DESC_OFF,TMP_DESC_LEN)
        outdata  += trans(nCounter," 999,999,999")
        A_RJS_PRNT(1, 1, 0, outdata, 0)
        nPLUTot  += nTotals
        nPLUCnt  += nCounter
        
        if lReset      
        
           cOutData := subs(cIndata,TMP_CODE_OFF,TMP_CODE_LEN)

           cHeader := formHeader(FC_SRCHDEL,FP_ONE,FA_FN_PLT)     
           
           // " Reset Status : "
           f_access(@cHeader,cOutData,@cIndata,GetLocal_Path())
           
           cHeader := formHeader(FC_SRCHGET,FP_ZERO,FA_FN_PLT)     
           cInData := space(PLUTEMP_SIZE)           
        endif        
        
   endif
   
   cOutData := repl("+",TMP_CODE_LEN)  
   
 enddo  

 A_RJS_FEED(1,1,0,1)
 A_RJS_PRNT(1,1,0, repl("-",32),0)
 outdata := "TOTAL"+space(13)+trans(nPLUTot,"999,999,999.99")
 A_RJS_PRNT(1,1,0,outdata,0)
 outdata := padl(trans(nPLUCnt,"999,999,999"),32)
 A_RJS_PRNT(1, 1, 0, outdata, 0)
 nGrandTot += nPLUTot 
 nGrandCnt += nPLUCnt

 A_RJS_FEED(1,1,0,1)
 A_RJS_PRNT(1,1,0, repl("-",32),0)
 outdata := "GRAND TOTAL"+space(07)+trans(nGrandTot,"999,999,999.99")
 A_RJS_PRNT(1,1,0,outdata,0)
 outdata := padl(trans(nGrandCnt,"999,999,999"),32)
 A_RJS_PRNT(1, 1, 0, outdata, 0)


 prnt_end()
 //" Eof "    
  
return nil 


function plu_counter(plu_code, nQty, nAmount, nDisc)
local cHeader
local cOutData,cInData 
local status := NORMAL

if !nvr_lTRNG_Mode() 
   
   cOutData := plu_code
   cOutData += ieereal( nQty )
   cOutData += ieereal( nAmount )
   cOutData += ieereal( nDisc )
   cOutData += ieereal( val(_cPrice_Level) )
   
   cIndata := ""
   cHeader := formHeader(FC_PUTCNTR,FP_ZERO,FA_FN_PLU)     

   status := f_access(@cHeader,cOutData,@cIndata,GetLocal_Path())
   
   if status != NORMAL
        MsgAreaDisp(" Unable to update PLU counter : "+str(status))
        error_log(" Unable to update PLU counter : "+str(status))
   endif            
   
endif

return status


function form_PLU(lReset)
local fhandle := -1
local cFilename := "PLUITEMS.RPT"
local cDate := strtran(dtoc(Term_nData(TR_DATE_NOW)),"-","/")
local nCounter,nTotals,nPluCost
local nCounter1,nTotals1,nPluCost1
local cData
local cIndata
local cOutData:= repl("-", PLU_CODE_LEN)
local nPTDqty,nPTDamt
local cHeader
local lVar := .T.
local status := NORMAL
local cTemp := ieereal(0)

/*
   // first copy the report file if it exist
   if File( GetReport_Path()+cFilename )
         __copyfile( GetReport_Path()+cFilename, ".\"+cFilename)
   endif 
*/   

   fhandle := fopen( ".\"+cFilename,FO_READWRITE )

   if ferror() == 2
      fhandle := fcreate( ".\"+cFilename, FC_NORMAL )
   endif

   if fhandle < 1
      MsgAreaDisp(" Error Opening output file ")
      tone(300,6)
      return .F.
   endif

   fseek( fhandle, 0, FS_END ) 
   fwrite( fhandle, "PLU ITEMS Z-REPORT"+space(12)+"<"+padl(right(alltrim(config(POS_TERM_NUM)),4),4,"0")+">"+CRLF ,38)   
   fwrite( fhandle, cDate + space(23) + subs(time(),1,5)+CRLF,38)

   cHeader := formHeader(FC_GETCNTR,if(lVar, FP_ONE, FP_ZERO), FA_FN_PLU)
   cInData := space(PCO_CNTR_SIZE)
   
   while status == NORMAL // eof
   
     status := f_access(@cHeader,cOutData,@cIndata,GetLocal_Path())

     nCounter := realiee(subs(cIndata,PCO_PL0Q_OFF,PLU_PL0Q_LEN))
     nTotals  := realiee(subs(cIndata,PCO_PL0A_OFF,PLU_PL0Q_LEN))
     nPluCost := realiee(subs(cIndata,PCO_PL0C_OFF,PLU_PL0Q_LEN))
     nCounter1 := realiee(subs(cIndata,PCO_PL1Q_OFF,PLU_PL0Q_LEN))
     nTotals1  := realiee(subs(cIndata,PCO_PL1A_OFF,PLU_PL0Q_LEN))
     nPluCost1 := realiee(subs(cIndata,PCO_PL1C_OFF,PLU_PL0Q_LEN))
     
     if !empty(cIndata) .and. ((nCounter + nTotals + nCounter1 + nTotals1) != 0 )

        cData := subs(cIndata,PLU_CODE_OFF,PLU_CODE_LEN+PLU_ITEM_LEN+PLU_DESC_LEN) 
        cData += padl(alltrim(strtran(trans(nCounter, "9999999.999"),".","")),10,"0")
        cData += padl(alltrim(strtran(trans(nTotals,  "9999999999.99"),".","")),12,"0")
        cData += padl(alltrim(strtran(trans(nPluCost, "9999999999.99"),".","")),12,"0")
#ifdef DEF_WHOLESALE        
        cData += padl(alltrim(strtran(trans(nCounter1,"9999999.999"),".","")),10,"0")
        cData += padl(alltrim(strtran(trans(nTotals1, "9999999999.99"),".","")),12,"0")
        cData += padl(alltrim(strtran(trans(nPluCost1,"9999999999.99"),".","")),12,"0")
#endif        
        cData += CRLF

        fwrite ( fhandle, cData , len(cData) )

        if lReset
           cOutData := subs(cIndata,PLU_CODE_OFF,PLU_CODE_LEN)
           cOutData += ieereal(0) //QUANTITY
           cOutData += ieereal(0) //AMOUNT
           cOutData += ieereal(0) //DISCOUNT
           cOutData += ieereal(0) //PRICE LEVEL

           cHeader := formHeader(FC_PUTCNTR,FP_ONE,FA_FN_PLU)

           // reset status
           f_access(@cHeader,cOutData,@cIndata,GetLocal_Path())

           cHeader := formHeader(FC_GETCNTR,FP_ONE,FA_FN_PLU)
           cIndata := space(PCO_CNTR_SIZE)
           
        endif
     endif

     // cInData  := space(46)
     cOutData := repl("+",PLU_CODE_LEN)

     if status != NORMAL .and. status != 9
        MsgAreaDisp(" Error PLU Reports status : "+str(status))
        error_log(" Error PLU Reports status : "+str(status))
     endif

   enddo  

   fwrite( fhandle, "NOT FOUND PLU REPORT"+space(10)+"<"+padl(right(alltrim(config(POS_TERM_NUM)),4),4,"0")+">"+CRLF,38)   
   fwrite( fhandle, cDate+ space(23) + subs(time(),1,5)+CRLF,38)   

   // cOutData  := repl("0",14)
   // cInData   := space(65+28)   
   cHeader  := formHeader(FC_SRCHGET,FP_ZERO,FA_FN_PLT)
   cIndata  := space(PLUTEMP_SIZE)
   cOutData := repl("0",TMP_CODE_LEN)

   status := NORMAL
   while status == NORMAL
   
     status := f_access(@cHeader,cOutData,@cIndata,GetLocal_Path())

     if status == NORMAL .or. status == 9
            
/*        nCounter := realiee(subs(cIndata,TMP_PL0Q_OFF,TMP_PL0Q_LEN))
        nTotals  :=  realiee(subs(cIndata,TMP_PL0A_OFF,TMP_PL0A_LEN))
        nCounter1:= realiee(subs(cIndata,TMP_PL1Q_OFF,TMP_PL0Q_LEN))
        nTotals1 :=  realiee(subs(cIndata,TMP_PL1A_OFF,TMP_PL1A_LEN))        
*/        
        nCounter := realiee(subs(cIndata,TMP_CNTR_OFF,TMP_CNTR_LEN))
        nTotals  :=  realiee(subs(cIndata,TMP_AMNT_OFF,TMP_AMNT_LEN))
        nCounter1:= realiee(subs(cIndata,TMP_PL1Q_OFF,TMP_PL0Q_LEN))
        nTotals1 :=  realiee(subs(cIndata,TMP_PL1A_OFF,TMP_PL1A_LEN))        
	
          cData := subs(cIndata,TMP_CODE_OFF,TMP_CODE_LEN)
          cData += padl(alltrim(strtran(trans(nCounter,"9999999.999"),".","")),10,"0")
          cData += padl(alltrim(strtran(trans(nTotals, "9999999999.99"),".","")),12,"0")          
          cData += padl(alltrim(strtran(trans(nCounter1,"9999999.999"),".","")),10,"0")
          cData += padl(alltrim(strtran(trans(nTotals1, "9999999999.99"),".","")),12,"0")          
          cData += CRLF

          fwrite( fhandle, cData, len(cData) )       

          if lReset      
        
             cOutData := subs(cIndata,TMP_CODE_OFF,TMP_CODE_LEN)
             cHeader := formHeader(FC_SRCHDEL,FP_ONE,FA_FN_PLT)     
           
             // " Reset Status : "
             f_access(@cHeader,cOutData,@cIndata,GetLocal_Path())
           
             cHeader := formHeader(FC_SRCHGET,FP_ZERO,FA_FN_PLT)     
             cInData := space(PLUTEMP_SIZE)           
          endif        

                
     endif   
     
     cOutData := repl("+",TMP_CODE_LEN)
   
   enddo  
   
   fclose( fhandle )

return .T.
