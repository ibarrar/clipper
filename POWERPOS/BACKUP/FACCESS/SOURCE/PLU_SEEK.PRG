#include "inkey.ch"

static array_ := { " ", ;
                 }


function main()
local cBuffer,status
local cDataBuff := space(25)
local cReceive 
local cpath := ".\test\"
local cSendBuff
local k := 1
local last_mem := Blimemmax()


 while inkey() != K_ESC

		cSendBuff := array_[k]

		cReceive  := space(256)
		// first fetch the fm_trans and convert data to send        

		cBuffer := "8888888888888888"  //  LOCAL IPX NO
		cBuffer += "0004"              //  LOCAL MAC NO
		cBuffer += "9999999999999999"  //  CALLER IPX NO
		cBuffer += "9999"          // CALLER MAC NO 
		cBuffer += "0512"          // LENGTH     
		cBuffer += "01"            // SEQUENCE
		cBuffer += "03"            // COMMAND
		cBuffer += "00"            // PARAMETER
 
		cl_atobcd(cBuffer,50,@cDataBuff)

		cDataBuff += "PL"
		status := f_access(@cDataBuff,cSendBuff,@cReceive,cPath)
   
		if status != 0
		  ? " status not normal .... "
		  tone(300,6)
		endif  
   
		? "status PL_S&GET :"
		?? status
		? " Data : "
		??  cReceive        
		? "                       Memory :"
		?? Blimemavl()
		? "Maximum Memory Block :"   
		?? Blimemmax()
      
		if Blimemmax()  != last_mem
			? " memory availability was changed..."
			inkey(0)
		endif   
		?

   if k == 486
     k := 1
   else
     k ++
   endif 

   tone(15,3)
   
 enddo

 cSendBuff := ""
 cReceive := "" 
 ? "Final Memory :"
 ?? Blimemavl()
 ? "Maximum Memory Block :"
 ?? Blimemmax() 
 inkey(0)
 ?
  
return nil