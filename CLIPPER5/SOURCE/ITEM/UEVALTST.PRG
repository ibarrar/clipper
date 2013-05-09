/*
*
* User EVAL Test program (Contains new testbed & uses ArrayClone)
*
* Copyright (C) 1993, Computer Associates, Inc.  All Rights Reserved
*
*/

PROCEDURE Main()

   TestIt( {|| TheTest()} )

   RETURN

PROCEDURE TheTest()
   LOCAL aTest := {"This","Is","An","Array",{1,2,3,4,5,{6,7,8,9,10}},"of",NIL,;
                   {"Lawnmower Man","SegHead","Glyph","Woof Woof"} }
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

// New testbed function ... NOTE: Uses USERDO() not EVAL()
//
PROCEDURE TestIt( bBlock )
   
   SET COLOR TO "W+/B"
   CLS

   WHILE INKEY() != 27
      SET COLOR TO "W+/R"
      @ MAXROW(), 00 SAY          "Swap: " + LTRIM(STR(MEMORY(0))) +;
                           ", Lg object: " + LTRIM(STR(MEMORY(1))) +;
                                 ", Run: " + LTRIM(STR(MEMORY(2))) +;
                                 ", EMM: " + LTRIM(STR(MEMORY(4))) +;
                                  ", FM: " + LTRIM(STR(MEMORY(101))) +; 
                         ", Idle Conven: " + LTRIM(STR(MEMORY(104)))
      DevPos( 0, 0 )
      SET COLOR TO "W+/B"

      // Extend routine block call
      //
      UserDo( bBlock )                         // WAKEUP!
      
   ENDDO

   RETURN      
