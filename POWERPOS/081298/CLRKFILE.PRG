#include "clrkfile.ch"
#include "powerpos.ch"
#include "config.ch"
#include "file_Acc.ch"
#include "spec_key.ch"
#include "get_grfx.ch"

#ifdef DEF_GRAPHICS
  #include "grfx_All.ch"
#endif  

static lClerk_Entry := .F.
static cClerkCode   := "000000"
static cClerkDesc   := ""

function isClerk(lVar)
  if valtype(lVar) == "L"
     lClerk_Entry := lVar
  endif
return lClerk_Entry

function cClerk_Desc()
return cClerkDesc


function get_Clerk(cVal)
local cHeader
local cOutData
local cIndata
local status := NORMAL
local k,n
local aName_ := {}
local aClrk_ := {}
local cTemp,out_text
local cWindow

   if empty(cVal) .or. "."$cVal  

      disp_clr()

      if config(POS_VLD_CLRK) == "YES"

        cOutData := repl("0",CRK_CODE_LEN)
        cInData  := space(CLERK_SIZE)

        // get first
        cHeader  := formHeader(FC_GETFRST,FP_ZERO,FA_FN_CLK)
        
        while status == NORMAL

          status := f_access(@cHeader,cOutData,@cIndata,GetCentral_Path())

          if status == NORMAL .or. status == 9
            aAdd( aClrk_, subs(cIndata,CRK_CODE_OFF,CRK_CODE_LEN) )
            aAdd( aName_, subs(cIndata,CRK_DESC_OFF,CRK_DESC_LEN) )
          endif  

          // get next
          cHeader  := formHeader(FC_GETNEXT,FP_ZERO,FA_FN_CLK)
          cInData  := space(CLERK_SIZE)
        enddo        

        k := alookup( 30,35, aName_,"Clerk Selection")     

        if ( k > 0 )
        
          cClerkCode := aClrk_[k]
          cClerkDesc := aName_[k]

        endif
        
      else

         cWindow := OpenWindow(20, 34, 66, 68, "Sub-Department PLU")

         @ 47, 30 say "Clerk Code : " get cTemp pict "999999"
            
         readmodal()

         if lastinput() != ENTER
            // restore previous screen
            CloseWindow(cWindow)
            return .F.
         endif          

         CloseWindow(cWindow)
         
         cClerkCode := padl(alltrim(cTemp),CRK_CODE_LEN,"0")
         cClerkDesc := ""
                
      endif  
   else

      if config(POS_VLD_CLRK) == "YES"
   
         cHeader  := formHeader(FC_SRCHGET,FP_ZERO,FA_FN_CLK)
         cOutData := padl(alltrim(cVal),CRK_CODE_LEN,"0")
         cInData  := space(CLERK_SIZE)      
         status := f_access(@cHeader,cOutData,@cIndata,GetCentral_Path())  

         if status == NORMAL
            cClerkCode := subs(cIndata,CRK_CODE_OFF,CRK_CODE_LEN) 
            cClerkDesc := subs(cIndata,CRK_DESC_OFF,CRK_DESC_LEN)
         else
            cClerkCode := padl(alltrim(cVal),CRK_CODE_LEN,"0")
            cClerkDesc := ""              
         endif 
         
      else
         cClerkCode := padl(alltrim(cVal),CRK_CODE_LEN,"0")
         cClerkDesc := ""
      endif    
      
   endif   

   tran_cClrk(cClerkCode)
  
   out_text := "CLERK# "+if(empty(cClerkDesc),cClerkCode,cClerkDesc)
   A_RJS_PRNT(1, 1, 0, out_text , 0)  
   
   lClerk_Entry := .T.

return nil


function clerk_report(lReset)
local cHeader
local cOutData
local cInData
local nTotals := 0
local nCounter := 0
local nGtotal := 0
local nGCount := 0
local outdata  := "CLERK REPORT " 
local status

 outdata += space(12)
 outdata += if(lReset,"Z","X")
 outdata += "-READING"

 A_RJS_PRNT(1, 1, 0,  outdata, 0)
 
 // skip line/s
 A_RJS_FEED(1, 1, 0, 1)     

 cOutData := repl("0",CRK_CODE_LEN)
 cInData  := space(CLERK_SIZE)

 // get first
 cHeader  := formHeader(FC_GETFRST,FP_ZERO,FA_FN_CLK)
      
 while status == NORMAL

     status := f_access(@cHeader,cOutData,@cIndata,GetCentral_Path())

     if status == NORMAL .or. status == 9        

        nTotals := realiee(subs(cIndata,CRK_SALE_OFF,CRK_SALE_LEN))
        nCounter := realiee(subs(cIndata,CRK_CNTR_OFF,CRK_CNTR_LEN))
      	outdata := subs(cIndata,CRK_CODE_OFF,CRK_CODE_LEN)+space(12)
	outdata += trans(nTotals,"999,999,999.99")
	A_RJS_PRNT(1, 1, 0, outdata, 0)
	outdata := subs(cIndata,CRK_DESC_OFF,CRK_DESC_LEN)
        outdata += trans(nCounter," 999,999,999")
	A_RJS_PRNT(1, 1, 0, outdata, 0)
	nGTotal += nTotals
	nGCount += nCounter
        
     endif  

     // get next
     cHeader  := formHeader(FC_GETNEXT,FP_ZERO,FA_FN_CLK)
     cInData  := space(CLERK_SIZE)
 enddo        


 A_RJS_FEED(1,1,0,1)
 A_RJS_PRNT(1,1,0, repl("-",32),0)
 outdata := "TOTAL"+space(13)+trans(nGTotal,"999,999,999.99")
 A_RJS_PRNT(1,1,0,outdata,0)
 outdata := padl(trans(nGCount,"999,999,999"),32)
 A_RJS_PRNT(1, 1, 0, outdata, 0)
 
return nil


