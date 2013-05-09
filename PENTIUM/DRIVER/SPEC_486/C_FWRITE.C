/*
 *
 * System......... POWERPOS for Spectrun
 * Program I.D.... c_fwrite.c
 * Description.... Clipper callable file write function for the NV RAM  
 * Authors........ Bong n R (5-29-95)
*/

/*
#include <stdio.h>
#include <io.h>
#include <dos.h>
*/

#include <filesys.api>
#include "extend.h"

/* parameter constants */
#define  FILE_HANDLE  1
#define  WRITE_LINE   2
#define  LINE_SIZE    3

/* Local functions */
int asm_commit(int file_handle);

CLIPPER c_fwrite (void)
{
   int  file_handle;
   char *line;
   USHORT  line_size;
   
   if (PCOUNT == 3 && ISNUM(FILE_HANDLE) && ISCHAR(WRITE_LINE)
                   && ISNUM(LINE_SIZE) && ISBYREF(LINE_SIZE))
   {
      /* convert clipper parameters into C types... */
      file_handle = _parni(FILE_HANDLE);
      line_size = _parni(LINE_SIZE);
      line = _parc(WRITE_LINE);
      
      /* call C write function... */
      if ( _fsWrite(file_handle, line, line_size) < line_size ) 
      {
        _storni (0, LINE_SIZE);
        _ret();
        return;
      }
      
      /* flush the data to file without closing it... */
      if (asm_commit(file_handle))  
        _storni (0, LINE_SIZE);
   }
   else
      /* update line_size to zero... */
      _storni (0, LINE_SIZE);                   

   _ret();  /* returns NIL */
}
