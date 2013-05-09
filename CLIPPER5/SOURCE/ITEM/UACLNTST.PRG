/*
*
* Test for ArrayClone()
*
* Copyright (C) 1993, Computer Associates, Inc.  All Rights Reserved
*
*/

PROCEDURE Main()

   TestIt( {|| TheTest()} )

   RETURN


PROCEDURE TheTest()

   LOCAL aTest := {"This","Is","An","Array",{1,2,3,4,5,{6,7,8,9,10}},"of",NIL,;
                   {"Quixote","Genet","Burroughs","Blah Blah"} }
   LOCAL aNew

   ShowVar(aTest)
   
   ?
   ? "Cloning..."
   aNew := ArrayClone( aTest )
   ? "----------"
   ?
   
   aTest[3] := "A SCREWED UP"
   ShowVar(aNew)

   RETURN


PROCEDURE ShowVar( xItem )
   LOCAL nCount

   DO CASE
      CASE VALTYPE( xItem ) $ "CM"
         ?? CHR(34) + xItem + CHR(34)
      CASE VALTYPE( xItem ) == "N"
         ?? LTRIM(STR(xItem))
      CASE VALTYPE( xItem ) == "B"
         ?? "{||...}"
      CASE VALTYPE( xItem ) == "L"
         ?? IIF(xItem,".T.",".F.")
      CASE VALTYPE( xItem ) == "D"
         ?? DTOC(xItem)
      CASE VALTYPE( xItem ) == "U"
         ?? "NIL"
      CASE VALTYPE( xItem ) == "A"
         ?? "{"
         FOR nCount := 1 TO LEN(xItem)
            ShowVar(xItem[nCount])
            IF nCount != LEN(xItem)
               ?? ", "
            ENDIF
         NEXT nCount
         ?? "}"
   ENDCASE         

   RETURN
