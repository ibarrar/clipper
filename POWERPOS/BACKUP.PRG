#include "fileio.ch"
#include "terminal.ch"

#define BACK_UP_FILENAME         GetLocal_path()+"TRBACKUP.LOC"
#define SIZE_OF_TRBKUP_RECORD    TERMINAL_SIZE

static back_handle

function trbkup_init()

  back_handle := fopen( BACK_UP_FILENAME, FO_READWRITE + FO_EXCLUSIVE )

  if ferror() == 2
     ? " Initializing terminal backup file..."
     tone(300,18)
     back_handle := fcreate ( BACK_UP_FILENAME, FC_HIDDEN )
  endif   

return back_handle > 0 


function trbkup_last()
local offset
local cBuffer := space( SIZE_OF_TRBKUP_RECORD )
local nreadsize := SIZE_OF_TRBKUP_RECORD

   if trbkup_init()   
      offset := fseek( back_handle, 0, FS_END)
      offset -= SIZE_OF_TRBKUP_RECORD
      fseek( back_handle, offset, FS_SET )
      if (fread( back_handle, @cBuffer, nreadsize ) !=  nreadsize )
         ? " Error reading from Terminal back-up file..."         
         cBuffer := ""              
      endif
      fclose( back_handle )
   else
      ? "Error Opening <"+BACK_UP_FILENAME+">"
      tone(300,16)
   endif
   
return cBuffer


function trbkup_date(nVar)
local cBuffer

   if valtype(nVar) == "N"
   else
     cBuffer := trbkup_last()   
   endif

return ctod(subs(cBuffer,,8))

function trbkup_append(cBuffer)
local lRet := .F.
local offset
local nwritesize := SIZE_OF_TRBKUP_RECORD

 if (len( cBuffer ) == nwritesize )  
   if trbkup_init() 
      offset := fseek( back_handle, 0, FS_END)
      if fwrite( back_handle, @cBuffer, nwritesize ) !=  nwritesize 
         ? " Error writting to Terminal back-up file..."         
      endif
      lRet := .T.
      fclose( back_handle ) // close file
   else
      ? "Error Opening <"+BACK_UP_FILENAME+">"
      tone(300,16)
   endif
 else
   ? " Error in buffer to be saved to backup file... "
   tone(300,16)
 endif  

return lRet



   