#include "inkey.ch"

function main()
local cBuffer,status
local cDataBuff := space(25)
local cReceive 
local cpath := ".\test\"
local cSendBuff
local k := 1
local last_mem := Blimemmax()


 while inkey() != K_ESC

   cReceive  := space(256)
   // first fetch the fm_trans and convert data to send 
       
   cSendBuff := padl(k,8,"0")
   ? "trying :"
   ?? cSendBuff

   cBuffer := "8888888888888888"  //  LOCAL IPX NO
   cBuffer += "0004"              //  LOCAL MAC NO
   cBuffer += "9999999999999999"  //  CALLER IPX NO
   cBuffer += "9999"          // CALLER MAC NO 
   cBuffer += "0512"          // LENGTH     
   cBuffer += "01"            // SEQUENCE
   cBuffer += "02"            // COMMAND
   cBuffer += "00"            // PARAMETER
 
   cl_atobcd(cBuffer,50,@cDataBuff)

   cDataBuff += "FM"
   status := f_access(@cDataBuff,cSendBuff,@cReceive,cPath)
   
   if status != 0
     ? " status of FM_TRANST not normal .... :"
     tone(300,6)
     ?? status 
   endif  

   if subs(cReceive,11,2) == "PL" 
   
      cSendBuff := subs(cReceive,13,14)

      cReceive  := space(206)

      cBuffer := "8888888888888888"  //  LOCAL IPX NO
      cBuffer += "0004"              //  LOCAL MAC NO
      cBuffer += "9999999999999999"  //  CALLER IPX NO
      cBuffer += "9999"          // CALLER MAC NO 
      cBuffer += "0512"          // LENGTH     
      cBuffer += "01"            // SEQUENCE
      cBuffer += "02"            // COMMAND
      cBuffer += "00"            // PARAMETER
 
      cl_atobcd(cBuffer,50,@cDataBuff)

      cDataBuff += "PL"
      status := f_access(@cDataBuff,cSendBuff,@cReceive,cPath)
   
      if status != 0
        ? " status not normal .... "
        tone(300,6)
      else 
        ? " Data Retrieved : "
        ?? cReceive        
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

   endif

   if k == 800
     k := 1
     tone(600,3)
   else
     k ++
   endif 

*   tone(15,1)
   
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