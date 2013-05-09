*
* System......... POWERPOS for Spectrum
* Program I.D.... FILE_ACC.prg
* Description.... 
* Remarks........ (Client-Server) version.
*

#include "config.ch"
#include "file_Acc.ch"
#include "powerpos.ch"

#define F_ACC_SERVER_2 "SERVER 2"
#define F_ACC_SERVER_3 "SERVER 3"

static cEcr_Name,cServer_Name,nSeq_no
static cData_path
static cServer_Path,cLocal_Path,cCentral_Path
static cReport_Path

* static cLocal_IP,cServer_IP

static cBCD_Terminal := "00"

function faccess_init()
*local cTemp
  
  cEcr_Name  := padl(right(alltrim(config(POS_TERM_NUM)),4),4,"0")

  cBCD_Terminal := space(2)
  cl_atobcd( cEcr_Name ,4 , @cBCD_Terminal ) 
  
/*
  cTemp := strtran(config(POS_LOCAL_IP_ADDR),".","")
  cLocal_IP  := padl(cTemp,16,"0")
*/  
  nSeq_no    := 0

  // Create the Server path thru the config file
  cServer_Path := config(POS_SERVER_PATH)
  
  if empty(cServer_Path)
      cServer_Path := ".\" // make it the local current path
  else   
      cServer_Path += if(subs(cServer_path,len(cServer_path),1)!="\","\","") 
  endif             

  // Create the Central Path for centralized files..  
  cCentral_Path := config(POS_CENTRAL_PATH)
  if empty(cCentral_Path)
      if cServer_Path != ".\"
        cCentral_Path := cServer_Path
      else
        cCentral_Path := ".\" // make it the local current path
      endif  
  else   
      cCentral_Path += if(subs(cCentral_Path,len(cCentral_Path),1)!="\","\","") 
  endif               

  // Now the local just in case if off-line or the system does not use network
  cLocal_Path := config(POS_LOCAL_PATH)
  
  if empty(cLocal_Path)
      cLocal_Path := ".\" // make it the local current path
  else   
      cLocal_Path += if(subs(cLocal_path,len(cLocal_path),1)!="\","\","") 
  endif               
  
  if isServer_Mode() // function found in input.prg
  
     if config(POS_TERM_FILE) == F_ACC_SERVER_2
           cServer_Name := config(POS_SERVER2)
     elseif config(POS_TERM_FILE) == F_ACC_SERVER_3 
           cServer_Name := config(POS_SERVER3)
     else // default 
           cServer_Name := config(POS_SERVER1)   
     endif       

     cServer_Name := padl(alltrim(cServer_Name),4,"0") 
     
*     cTemp := strtran(config(POS_SERV_IP_ADDR),".","")
*     cServer_IP := padl(alltrim(cTemp),16,"0")

  else
  
     cServer_Name := cEcr_Name

     // Use the server path if in server mode
     // Assume that it is online with the server at startup
     cServer_Path := cLocal_Path

*     cServer_IP := cLocal_IP
     
  endif

  if config(POS_ITEM_FILE) != "SERVER"
     cData_Path := cLocal_Path
  else
     cData_Path := cCentral_Path   
  endif   

  // Now the Report just in case if off-line or the system does not use network
  cReport_Path := config(POS_REPORT_PATH)
  
  if empty(cReport_Path)
      cReport_Path := cServer_Path // make it point to server path
  else   
      cReport_Path += if(subs(cReport_path,len(cReport_path),1)!="\","\","") 
  endif               
  
  
return nil

/*
    HEADER FORMAT 
    +--------+----------+---------+-----------+---+----+---+---+--+ 
    |LOCAL IP|LOCAL MAC#|SERVER IP|SERVER MAC#|LEN|SEQ#|CMD|PRM|FN|
 BCD|   8    |     2    |    8    |     2     | 2 |  1 | 1 | 1 | 2| 27
 ASC|   16   |     4    |    16   |     4     | 4 |  2 | 2 | 2 | 2| 52
    +--------+----------+---------+-----------+---+----+---+---+--+
    00000000 00 00000000 00 00 0 0 0 XX
    
*/ 


function form_header( command, parm, fn, length )
local cHeader_Buff := space(25)
local cDest_Addr
local cAscData 

 if empty(length)
    length := 128
 endif

* cDest_Addr := if(isServer_Mode(),cServer_IP+cServer_Name,cLocal_IP+cECR_Name)
 
 cAscData := "0000000000000000"       // padl(cLocal_IP, 16, "0") // 16
 cAscData += padl(cECR_Name,  4, "0") // 20
 cAscData += "00000000000000000000"   // padl(cDest_Addr,20, "0") // 40
 cAscData += padl(length,     4, "0") // 44
 cAscData += padl(nSeq_no,    2, "0") // 46
 cAscData += padl(command,    2, "0") // 48
 cAscData += padl(parm,       2, "0") // 50
 
 cl_atobcd( cAscData ,50 , @cHeader_Buff ) 

 if nSeq_no == 99
    nSeq_no := 0
 else 
    nSeq_no++
 endif       
 
return (cHeader_Buff + fn)

        
function GetLocal_path()
return cLocal_path

function GetServer_Path()
return cServer_Path

function GetCentral_Path()
return cCentral_Path

function GetPLU_Path()
return cData_Path

function GetReport_Path()
return cReport_Path


function file_Access(cCommand, cParm, cFileName, nLen,cOutData, cIndata, cPathParm)
local cHeader := form_Header(cCommand, cParm, cFileName, nLen)
local status, i:= 1

   status := f_access(@cHeader, cOutData, @cInData, cPathParm )   
   
   while status != NORMAL .and. i++ < val(config(POS_NUM_RETS))
       cHeader := form_Header(cCommand, cParm, cFileName, nLen)
       if ((status := f_access(@cHeader, cOutData, @cInData, cPathParm )) == 0 ) // NORMAL
          exit
       endif
   enddo

return status


function faccess_close()
local cHeader
local cIndata := ""
local cOutData := ""

  cHeader := formHeader(chr(22),chr(0),FA_FN_PLU)
  f_access(@cHeader,cOutData,@cIndata,GetLocal_Path())
  
return nil


function formheader(cCmd,cPrm,cFile)
local cHeader := repl(chr(8),8)

   cHeader += cBCD_Terminal
   cHeader += repl(chr(9),8)
   cHeader += chr(0)+chr(0)
   cHeader += chr(5)+chr(12)
   cHeader += chr(1)
   cHeader += cCmd  // FA_CMD_SRCHGET "02"
   cHeader += cPrm  // FA_PRM_ZERO  
   cHeader += cFile // FA_FN_PLU
   
return cHeader   


// eof 