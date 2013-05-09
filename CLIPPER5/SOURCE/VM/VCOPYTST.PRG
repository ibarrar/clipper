/***
*   Vmtest.prg
*
*   Test of the VM API 
*
*   Copyright (C) 1993, Computer Associates, Inc.  All rights reserved
*/

PROCEDURE VMTest( cSourceFile, cTargetFile )

   IF PCOUNT() < 2 .OR.                                   ;
      VALTYPE( cSourceFile ) != "C" .OR.                  ;
      VALTYPE( cTargetFile ) != "C"

      ? "Usage: VMTest <Source File> <Target File>"
      ? "Wild card matches are not allowed"

   ELSE

      IF !FILE( cSourceFile )

         ? "Error: Source file (" + cSourceFile + ") not found!"

      ELSE
         ? "Copying " + cSourceFile + " to " + cTargetFile
         ?
         IF ! VMCopy( cSourceFile, cTargetFile ) 

            ? "You're hosed...better run chkdsk."

         ELSE 

            ? "File copied..."

         ENDIF

      ENDIF

   ENDIF

   QUIT

         

