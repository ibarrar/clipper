#include "inkey.ch"

static array_ := { "NORMAL",;
                   "FILE_OPEN_ERR",;
                   "FILE_READ_ERR",;
                   "FILE_WRITE_ERR",;
                   "CODE_NOT_FOUND",;
                   "MEM_ALLOC_ERR",;
                   "FILE_CREATE_ERR",;
                   "INVALID_PARAM",;
                   "BTRIEVE_OPEN_ERR",;
                   "BTRIEVE_UPDATE_ERR",;
                   "BTRIEVE_INSERT_ERR",;
                   "BTRIEVE_CREATE_ERR",;
                   "FILE_DELETE_ERR",;
                   "INV_SEND_PARAM",;
                   "INV_RECV_PARAM",;
                   "INV_CMMD_PARAM",;
                   "INV_FILE_ID_PARAM",;
                   "INVALID_REC_NO",;
                   "RECORD_NO_ZERO",;
                   "DEL_NON_ZERO_ERR" }
 

function main()
local cBuffer,status
local cDataBuff := space(25)
local cReceive 
local cpath := ".\test\"
local cSendBuff
local k := 1
local last_mem := Blimemmax()


 while inkey() != K_ESC

   cReceive  := space(45)
   
   cSendBuff := repl(chr(k+48),6)

	cBuffer := "8888888888888888"  //  LOCAL IPX NO
	cBuffer += "0004"              //  LOCAL MAC NO
	cBuffer += "9999999999999999"  //  CALLER IPX NO
	cBuffer += "9999"          // CALLER MAC NO 
	cBuffer += "0512"          // LENGTH     
	cBuffer += "01"            // SEQUENCE
	cBuffer += "02"            // COMMAND
	cBuffer += "00"            // PARAMETER
 
	cl_atobcd(cBuffer,50,@cDataBuff)

	cDataBuff += "CS"
	status := f_access(@cDataBuff,cSendBuff,@cReceive,cPath)

   if status != 0
     ? " status not normal .... "
     ?? status     
     tone(300,6)
   endif  
   
	? "status :" + array_[status+1]
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

   if k == 42
     k := 1
   else
     k ++
   endif 

   tone(15,1)
   
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