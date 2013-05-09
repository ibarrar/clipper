/*
*
* IsDouble() & YesNo() test program
*
* WARNING: ISDBL.C & YESNO.C are needed for this test to work.
* Copyright (C) 1993, Computer Associates, Inc. All Rights Reserved
*
*/


PROCEDURE Main()

   TestIt( {|| TheTest()} )

   RETURN


PROCEDURE TheTest()

   ? "YesNo( IsDouble( nNum ) )"
   ?
   ? "27           Dbl?: " + YesNo(IsDouble(27))
   ? "42.334       Dbl?: " + YesNo(IsDouble(42.334       ))
   ? ".39283       Dbl?: " + YesNo(IsDouble(.39283       ))
   ? "92342143144  Dbl?: " + YesNo(IsDouble(92342143144  ))
   ? "923892932.2  Dbl?: " + YesNo(IsDouble(923892932.2  ))
   ? "0            Dbl?: " + YesNo(IsDouble(0            ))
   ? "-27          Dbl?: " + YesNo(IsDouble(-27           ))
   ? "-42.334      Dbl?: " + YesNo(IsDouble(-42.334       ))
   ? "-.39283      Dbl?: " + YesNo(IsDouble(-.39283       ))
   ? "-92342143144 Dbl?: " + YesNo(IsDouble(-92342143144  ))
   ? "-923892932.2 Dbl?: " + YesNo(IsDouble(-923892932.2  ))
   ? "-0           Dbl?: " + YesNo(IsDouble(-0            ))
   ? "'Testing!'   Size: " + YesNo(IsDouble("Testing!"))
   ? "{2,1,'',0,0} Size: " + YesNo(IsDouble({2,1,"",0,0}))
   ? "NIL          Size: " + YesNo(IsDouble(NIL))

   RETURN
