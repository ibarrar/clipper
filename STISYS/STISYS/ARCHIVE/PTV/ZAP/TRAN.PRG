set escape on

public TRANS, estat
@ 06,00 say chr(198)
@ 06,25 say chr(216)

do drawbox with 9,26,20,46,.f.

@ 10,27 prompt " a. GM's Office    "
@ 11,27 prompt " b. PPS            "
@ 12,27 prompt " c. News           "
@ 13,27 prompt " d. Public Affairs "
@ 14,27 prompt " e. EEC            "
@ 15,27 prompt " f. Engineering    "
@ 16,27 prompt " g. Provincial     "
@ 17,27 prompt " h. Sales          "
@ 18,27 prompt " i. Administrative "
@ 19,27 prompt " j. Finance        "
menu to tran
do case
   case tran = 1
        trans = "A"
   case tran = 2
        trans = "B"
   case tran = 3
        trans = "C"
   case tran = 4
        trans = "D"
   case tran = 5
        trans = "E"
   case tran = 6
        trans = "F"
   case tran = 7
        trans = "G"
   case tran = 8
        trans = "H"
   case tran = 9
        trans = "I"
   case tran = 10
        trans = "J"
endcase
if lastkey() = 27
   return
endif

do estatus with estat

if lastkey () = 27
   return
endif

mastfile = "MR" + REGMM + REGDD + REGYY
sele 1
use &mastfile 
inde on empn to &mastfile

tranfile = TRANS + ESTAT + REGMM + REGDD + REGYY
sele 2
use &tranfile 
inde on empn to &tranfile
sele 1
DECODE = TRANS + ESTAT
DCODE = "  "
do whil .t.
   DCODE = divcde
   if DECODE = DCODE
      sele 2
      seek a->empn
      if eof()
         appe blan
      endif
      repl empn with a->empn
      repl lnam with a->lnam
      repl fnam with a->fnam
      repl mnam with a->mnam
   else
      skip
      if eof()
         clos data
         exit
      endif
      loop
   endif
   sele 1
   skip
enddo
clos databases
return


