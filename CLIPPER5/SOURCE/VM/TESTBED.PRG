/*
*
* ITEM API Test bed
*
* Copyright (C) 1993, Computer Associates, Inc.
* All Rights Reverved
*/

PROCEDURE TestIt( bBlock )
   
   SET COLOR TO "W+/B"               
   CLS

   WHILE INKEY() != 27
      SET COLOR TO "W+/R"
      @ MAXROW(), 00 CLEAR
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
      EVAL( bBlock )
      
   ENDDO

   RETURN      
