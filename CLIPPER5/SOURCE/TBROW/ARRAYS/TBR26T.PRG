/*****
 *
 * TBR26T.PRG
 * Test for TBR26
 *
 * Copyright (c) 1991 Computer Associates Int'l Corporation.
 *                    All Rights Reserved.
 *
 * Clipper tbr26t /N /W
 * RTLINK FILE tbr26t, tbr26
 *
 */

FUNCTION Main()
   LOCAL i, cScreen
   LOCAL aArray[200], aLogic[200], aMsg[200]

   cScreen := savescreen()
   FOR i := 1 TO 200
      aArray[ i ] := "Test " + STR(i,3,0)
      aLogic[ i ] := "0" $ STR( i )
      aMsg[ i ]   := "This is element# " + STR(i,3,0)

   NEXT


   ACHMENU( 4, 10, 14, 30, aArray, aLogic, aMsg,,;
            {|| DEVPOS(0, 60), DEVOUT(TIME(),"W+/BG")} )

   restscreen(,,,,cScreen)
   RETURN (NIL)

// EOF - TBR26T.PRG //
