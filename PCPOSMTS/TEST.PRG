function test()
local count := 0, amount := 0

use plu
Do while  !eof()
   if plu->date == ctod("12/01/97")
      count += plu->icount
      amount += plu->iamount
   endif
   skip
enddo
? count
? amount
close all
return nil