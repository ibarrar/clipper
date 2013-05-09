/*
*
* CC Test Program 
* Copyright (C) 1993, Computer Associates, Inc. All rights reserved.
*
*/

PROCEDURE Main()

   TestIt( {|| TheTest()} )

   RETURN


PROCEDURE TheTest()
   LOCAL nEye
   LOCAL cString := "Many Very Early Men Just Sat Under Nasty Pickles"
   LOCAL cLook
   LOCAL cSeen := ""

   ? "CharCount(" + cString + ", <char> ) ->"
   FOR nEye := 1 TO LEN(cString)
      cLook := SUBSTR(cString,nEye,1) 
      
      IF !(cLook $ cSeen)
         cSeen += cLook      
         ? "Looking for " + cLook + " -> " 
         ?? CharCount( cString, cLook )
      ENDIF

   NEXT nEye      

   RETURN
