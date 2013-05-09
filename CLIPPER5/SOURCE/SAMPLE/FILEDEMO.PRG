/***
*
*	Filedemo.prg
*
*  Demo of FileMan() function
*
*  Copyright (c) 1993, Computer Associates International Inc.
*  All rights reserved.
*
*/

PROCEDURE Main()

   LOCAL cFileName

   cFileName := FileMan( 5, 5, MAXROW() - 1, "W/B,N/W,,,W/N" )

   @ MAXROW(), 0
   ?? "Return value from FileMan() was:", '"' + cFileName + '"'

   RETURN
