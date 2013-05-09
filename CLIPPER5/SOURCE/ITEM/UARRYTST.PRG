/*
*
* User ARRAY() function test
*
*/

PROCEDURE Main()

   TestIt( {|| TheTest()} )

   RETURN

PROCEDURE TheTest()
   LOCAL aClips
   LOCAL aOurs

   aClips := ARRAY(2,3,4)   
   aOurs := MYARRAY(2,3,4)

   ? "ARRAY(2,3,4):"
   ?
   ShowVar( aClips )

   ? "-------"
   ? "MYARRAY(2,3,4):"
   ?
   ShowVar( aOurs )

   ? "-------"
   ? 'MYARRAY(2,3,"B"):'
   ?
   ShowVar( MYARRAY( 2, 3, "B") )
   
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
