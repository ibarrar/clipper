/*
* Quarter Test program
*
* Copyright (C) 1993, Computer Associates, Inc. All Rights Reserved
*/

PROCEDURE Main()

   TestIt( {|| TheTest()} )

   RETURN

PROCEDURE TheTest()

   ? "Quarter( <date> ) -> nQuarter"

   ? "Date 01/24/82 -> " + LTRIM(STR(Quarter(CTOD("01/24/82"))))
   ? "Date 09/15/91 -> " + LTRIM(STR(Quarter(CTOD("09/15/91"))))  // <G>
   ? "Date 07/12/63 -> " + LTRIM(STR(Quarter(CTOD("07/12/63"))))
   ? "Date 10/01/99 -> " + LTRIM(STR(Quarter(CTOD("10/01/99"))))
   ? "Date >Today<  -> " + LTRIM(STR(Quarter(DATE()          )))

   RETURN
