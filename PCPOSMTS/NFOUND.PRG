#include "inkey.ch"
#include "setcurs.ch"


memvar getlist
static ccode

function nfound()
LOCAL CDATE := CTOD(""),QTY := 0, AMT := 0

ccode := space(14)


USE PLU
Set Index to PLU,ITEMCNT


Do while .t.
   cls

   @ 5,35 say "NOT FOUND PLU"
   @ 4,34 TO 6,49 DOUBLE

   @ 10, 20 SAY "DATE      : " GET cdate
   @ 11, 20 SAY "PLU CODE  : " GET ccode valid(item())
   @ 12, 20 SAY "QTY. SOLD : " GET qty PICT "@K 9,999.99"
   @ 13, 20 SAY "AMT. SOLD : " GET amt PICT "@K 999,999.99"
   READ
   if lastkey() == K_ESC
      DbCloseAll()
      return nil
   endif
   IF alert("Are all data correct ?", {"YES","NO"}) == 1
      if !PLU->(DbSeek(ccode+dtos(cdate)))
         PLU->(DbAppend())
         PLU->DATE := cdate
         PLU->CODE := ccode
         PLU->ICOUNT := qty
         PLU->IAMOUNT := amt
         PLU->OP_FLAG := 1
      else
         PLU->ICOUNT += QTY
         PLU->IAMOUNT += AMT 
      endif   
      // cdate := ctod("")
      ccode := space(14)
      QTY := 0
      AMT := 0
      IF alert("Add another record ?", {"YES","NO"}) == 1
         loop
      else
         exit
      endif
   ELSE
      loop
   ENDIF
enddo

DbCloseAll()
return nil


function item()
if empty(ccode)
 return .f.
endif
 
ccode := padl(alltrim(ccode),14,"0")

return .t.