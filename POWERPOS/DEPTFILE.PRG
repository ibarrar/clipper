#include "deptfile.ch"
#include "file_acc.ch"
#include "powerpos.ch"
#include "terminal.ch"
#include "message.ch"

static _DeptCode
static _DeptDesc
static _DeptConc
static _DeptHalo
static _DeptLalo
static _Discount

function Dept_Get(cData)
local cHeader  := formHeader(FC_SRCHGET,FP_ZERO,FA_FN_DPT)
local cOutData 
local cIndata  := space(DEPT_SIZE)
local status

   cData :=  padl(alltrim(cData),DEP_CODE_LEN,"0")

   cOutData := cData
   status   := f_access(@cHeader,cOutData,@cIndata,GetLocal_Path())

   if status == NORMAL
      _DeptCode := subs(cIndata,DEP_CODE_OFF,DEP_CODE_LEN)
      _DeptDesc := subs(cIndata,DEP_DESC_OFF,DEP_DESC_LEN)
      _DeptConc := subs(cIndata,DEP_CONC_OFF,DEP_CONC_LEN)
      _DeptHalo := subs(cIndata,DEP_HALO_OFF,DEP_HALO_LEN)
      _DeptLalo := subs(cIndata,DEP_LALO_OFF,DEP_LALO_LEN)
      _Discount := subs(cIndata,DEP_DISC_OFF,DEP_DISC_LEN)      
   endif         

return status == NORMAL

function cDept_Desc()
return _DeptDesc

function nDept_Halo()
return realiee(_DeptHalo)

function nDept_Lalo()
return realiee(_DeptLalo)

function cDept_Conc()
return _DeptConc

function nDept_Disc()
return val(_Discount)

function Vldt_Dept(cData)
local lRetVal

  if empty(cData)
     return .F.
  endif   
       
  cData := padl(alltrim(cData),DEP_CODE_LEN,"0")

  lRetVal := Dept_Get(cData)

  if !lRetVal
     MsgAreaDisp( MSG_D037 )
     BUMMER()
  endif

return lRetVal

function dept_count(cDept, nQty, nAmount, nDisc )
local cHeader
local cIndata
local cOutData
local status := NORMAL

    if empty(nDisc)
       nDisc :=  0
    endif
       
    cOutData := cDept
    cOutData += ieereal(nQty)
    cOutData += ieereal(nAmount)
    cOutData += ieereal(nDisc)
   
    cInData := ""
    cHeader := formHeader(FC_PUTCNTR,FP_ZERO,FA_FN_DPT)
    status := f_access(@cHeader,cOutData,@cIndata,GetLocal_Path())
   
    if status != NORMAL
       MsgAreaDisp("Error Accumulating Dept Counters:"+str(status))
       error_log("Error Accumulating Dept Counters:"+str(status))
    endif   
         
return nil


function dept_report(lReset)
local cHeader
local cIndata
local cOutData
local k
local status := NORMAL
local outdata := "DEPT REPORT"
local nPercent,nGrandTot
local nGrand_Tot := 0
local nGrand_Cnt := 0
local nTotals    := 0
local nCounter   := 0

  outdata += space(12)
  outdata += if(lReset,"Z","X")
  outdata += "-READING"

  A_RJS_PRNT(1, 1, 0,  outdata, 0)
 
  // skip line/s
  A_RJS_FEED(1, 0, 0, 1)      
      
  // check if zero skip then if zero then skip  
  cOutData := "0000"

  while status == NORMAL  

    cIndata  := space(DEPT_CNTR_SIZE)
    cHeader  := formHeader(FC_GETCNTR,FP_ZERO,FA_FN_DPT)
    status   := f_access(@cHeader,cOutData,@cIndata,GetLocal_Path())
  
    if  status == NORMAL .or. status == 9
     
        nTotals  := realiee(subs(cIndata, DEP_SALE_OFF, DEP_SALE_LEN) )
        nCounter := realiee(subs(cIndata, DEP_CNTR_OFF, DEP_CNTR_LEN) )
        
        nGrandTot := Term_nData(TR_DSLS_TOT)
        if nGrandTot != 0
           nPercent := nTotals/nGrandTot * 100
        endif  

        A_RJS_FEED( 1, 1, 0, 1 )                        
        outdata := subs(cIndata,DEP_CODE_OFF,DEP_CODE_LEN)
        if nGrandTot != 0
          outdata += trans(nPercent,"  999.99%")+space(5)
        else
          outdata += space(14)  
        endif  
        outdata += trans(nTotals,"999,999,999.99") 
        A_RJS_PRNT( 1, 1, 0, outdata, 0)
        
        outdata := subs(cIndata,DEP_CDSC_OFF,DEP_DESC_LEN) 
        outdata += trans(nCounter,"9999,999,999") 
        A_RJS_PRNT( 1, 1, 0, outdata, 0)
        nGrand_Tot += nTotals
        nGrand_Cnt += nCounter

        if lReset

           cOutData := subs(cIndata,DEP_CODE_OFF,DEP_CODE_LEN)
           cOutData += ieereal(0)
           cOutData += ieereal(0)
           cOutData += ieereal(0)
   
           cInData := ""
           cHeader := formHeader(FC_PUTCNTR,FP_ONE,FA_FN_DPT)
           f_access(@cHeader,cOutData,@cIndata,GetLocal_Path())
           
        endif
     endif

     cOutData := "++++"  
     
 enddo

 A_RJS_FEED(1,1,0,1)
 A_RJS_PRNT(1,1,0, repl("-",32),0)
 outdata := "TOTAL"+space(13)+trans(nGrand_Tot,"999,999,999.99")
 A_RJS_PRNT(1,1,0,outdata,0)
 outdata := padl(trans(nGrand_Cnt,"999,999,999"),32)
 A_RJS_PRNT(1, 1, 0, outdata, 0)
 
 prnt_end()
     
return nil
