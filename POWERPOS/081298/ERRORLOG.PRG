*
* System......... POWERPOS for Siemens Nixdorf
* Program I.D.... ERRORLOG.prg
* Description.... Writes the error occurrences into an error text file.
*

#include "fileio.ch"
#define  CRLF chr(13) + chr(10)

function error_log(error_desc, end_pos)
***************************************
local i
local f_handle := 0
local filename := "err_" + substr(dtoc(date()), 1, 2) + ;
                  substr(dtoc(date()), 4, 2) + ".txt"
local err_buffer := ""

  f_handle :=  fopen(filename, FO_READWRITE)

  if ferror() == 2
    f_handle := fcreate(filename,FC_NORMAL)
  endif

  // pass dos error code, pls. refer to p. 1018 of Clipper 5
  // developer's guide for the definition of such error code...
  if ferror() != 0
     pfl_msg(ferror(), 1, "DOS", f_handle)
  endif

  // move to end of file...
  fseek(f_handle, 0, FS_END)

  // write error info to file...
  err_buffer := "*** System Error Occurred ***" + CRLF
  // date and time when the error occurred...
  err_buffer += "DATE : " + dtoc(date()) + CRLF
  err_buffer += "TIME : " + time() + CRLF
  // error description...
  err_buffer += "DESCRIPTION : " + error_desc + CRLF
  i := len(err_buffer)  
  c_fwrite(f_handle, err_buffer, @i)
  if i !=  len(err_buffer)
     pfl_msg(ferror(), 1, "DOS", f_handle)
  endif

  // if unrecoverrable error, quit to DOS...
  if !empty(end_pos)
     fwriteln(f_handle," Trace : ->")
     i := 1
     while !empty(procname(i)) 
       fwriteln(f_handle,"   "+procname(i) + " (" + ltrim(str(procline(i))) + ")")
       i++
     enddo  
     pfl_msg(ferror(), 1, "DOS", f_handle, "UNRECOVERRABLE ERROR")
  endif

  // then close the file...
  fclose(f_handle)

return nil

* eop 09/06/94
