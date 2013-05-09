/***
*   Bootread.prg
*   Copyright (C) 1993 Computer Associates, Inc.  All Rights Reserved.
*
*   Reads a boot sector & prints it out
*/

PROCEDURE BootRead()

   LOCAL cBootSec
   LOCAL nEye
   LOCAL nLast := 0
   
   ? "Reading boot sector..."
   cBootSec := BootSector()         // Defaults to drive A
   ?

   FOR nEye := 1 TO LEN(cBootSec)
      ?? PADL(LTRIM(STR(ASC(SUBSTR(cBootSec,nEye,1)))),3,"0") + "  "
      IF COL() > 50
         @ ROW(),60 SAY SUBSTR(cBootSec,nLast+1,nEye-nLast)
         nLast := nEye
         ?
      ENDIF
   NEXT nEye

   QUIT
         

