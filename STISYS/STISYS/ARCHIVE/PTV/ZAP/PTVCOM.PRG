msubsys = "Payroll Computation"
public estat
do heading
do estatus with estat

if lastkey() = 27
   return
endif

REC_CNT = 0
emp = 0


TEMPN = SPAC(3)
TSTATE = " "
TLNAM = SPAC(15)
TFNAM = SPAC(15)
TMNAM = SPAC(15)
TADD1 = SPAC(25)
TADD2 = SPAC(25)
TAGE = 0
TSEX = SPAC(01)
THDATE = CTOD("  /  /  ")
TCLASS = SPAC(01)
TDIVCDE = SPAC(02)
TESTATUS = SPAC(01)
TMRATE = 0.00
TDRATE = 0.00
THRATE = 0.00
TTXSTAT = SPAC(04)
TTITLE = SPAC(20)
RSTATUS = SPAC(4)
TRATE = 0.00
TABSENCES = 0.00
TOVER = 0.00
TEARN = 0.00
TGROSS = 0.00
TTAX = 0.00
TPERA = 0.00
TGSIS = 0.00
TGARIR = 0.00
TMCARE = 0.00
TMARIR = 0.00
TPHIL = 0.00
TPTEA = 0.00
TLIFE = 0.00
TLOANAMT = 0.00
TLOANSEM = 0.00
TLOANPD = 0.00
TOTHERS = 0.00
TNETPAY = 0.00
TAXSW = "0"
CONTSW = "0"
PER_CNT = 0
**********************MAKE NEW FILE FOR NEXT PAYROLL DATE******************

D = VAL(REGDD)
M = VAL(REGMM)
Y = VAL(REGYY)

*IF REGMM = "01"
*   MCHAR = "12"
*ELSE
*   M = (M - 1) + 100
*   MCHAR = SUBS(STR(M),9,2)
*ENDIF

IF REGDD $("28293031")
   NEWDD = "15"
   IF REGMM = "12"
      NEWMM = "01"
      SAVNY = Y + 1
      NEWYY = SUBS(STR(SAVNY + 100),9,2)
   ELSE
      M = (M + 1) + 100
      NEWMM = SUBS(STR(M),9,2)
      NEWYY = REGYY
   ENDIF
ELSE
   NEWMM = REGMM
   NEWYY = REGYY
   DO CASE
      CASE REGMM = "01" .OR. REGMM = "03" .OR. REGMM = "05" .OR. REGMM = "07" .OR. REGMM = "08" .OR. REGMM = "10" .OR. REGMM = "12"
         NEWDD = "31"
      CASE REGMM = "04" .OR. REGMM = "06" .OR. REGMM = "09" .OR. REGMM = "11"
         NEWDD = "30"
      OTHERWISE
         TESTDATE = CTOD("02/29/" + REGYY)
         IF DAY(TESTDATE) = 29
            NEWDD = "29"
         ELSE
            NEWDD = "28"
         ENDIF
   ENDCASE
ENDIF


nextmas = "MR" + newmm + newdd + newyy + ".dbf"
if file("&nextmas")
   save scree
   @ 10,20 say "                                                "
   @ 11,20 say "                                                "
   @ 12,20 say "  WARNING!!!                                    "
   @ 13,20 say "  This is a rerun.                              "
   @ 14,20 say "  Previously created files will be overwritten. "
   @ 15,20 say "  Do you wish to continue? (Y/N) "
   abox = chr(201) + chr(205) + chr(187) + chr(186) + chr(188) + chr(205);
          + chr(200) + chr(186) 
   @ 10,19,17,68 box abox
   WISH = " "
   do whil .t.
      @ 15,53 get WISH pict "!"
      read
      if WISH $("YN")
         *
      else
         loop
      endif
      if WISH = "N"
         @ 08,00 clea
         clos data
         return
      endif
      @ 10,00 clea
      restore scree
      exit
   enddo
else
   use ptvmastr
   copy stru to &nextmas
   clos data
endif

rec_cnt = cnt_rec(rec_cnt)

mastfile = "MR" + regmm + regdd + regyy
sele 1 
use &mastfile 
index on empn to &mastfile
sele 2
nextmas = subs(nextmas,1,8)
use &nextmas 
index on empn to &nextmas
sele 3
use ptvtxtab
index on status to ptvtxtab
sele 4
use gsisloan index gsisloan

i = 0
do whil .t.
   i = i + 1
   do case
      case i = 1
         fil = "A"
      case i = 2
         fil = "B"
      case i = 3
         fil = "C"
      case i = 4
         fil = "D"
      case i = 5
         fil = "E"
      case i = 6
         fil = "F"
      case i = 7
         fil = "G"
      case i = 8
         fil = "H"
      case i = 9
         fil = "I"
      case i = 10
         fil = "J"
      otherwise
         clos data
         return
   endcase
   tranfile = fil + estat + regmm + regdd + regyy
   sele 5
   use &tranfile inde &tranfile
   cnt = reccount()
   if cnt = 0 
      i = i + 1
      loop
   endif
   notax_sw = 0
   abox = chr(218) + chr(196) + chr(191) + chr(179) + chr(217) + chr(196);
          + chr(192) + chr(179)
   @ 16,29,18,51 box abox
   do whil .t.
      emp = emp + 1
      per_cnt = ((emp / rec_cnt) * 100)  
      @ 17,33 say "Computing " + subs(str(round(per_cnt,1)),8,3) + "%"
      tempn = empn
      sele 1
      seek tempn
      tlnam = lnam
      tfnam = fnam
      tmnam = mnam
      tadd1 = add1
      tadd2 = add2
      tage = age
      tsex = sex
      thdate = hdate
      tclass = class
      ttitle = title
      tdivcde = divcde
      testatus = estatus
      tmrate = mrate
      tdrate = drate
      thrate = hrate
      ttxstat = txstat
      tgsisno = gsisno
      tpera = pera
      tgsis = g_cont
      tgarir = g_arr   
      tmcare = m_care
      tmarir = m_arr    
      tphilam = philam
      tptea = ptea
      tlife = lifecare
*      TLOANAMT = loanamt
*      TLOANSEM = loansem
*      TLOANPD = loanpd
*      TOTHERS = others

      loan = 0
      sele 5
      trate = tmrate / 2
      tabsences = absences
      tover = overtime
      rstatus = spac(04)
      tearn = trate - tabsences
      tgross = (trate + tover) - tabsences
      if tearn <= 833.33
         if ttxstat = "S   "
            rstatus = "S** "
            taxsw = "1"
         endif
         if ttxstat = "HF  "
            rstatus = "HF* "
            taxsw = "1"
         endif
      endif
      sele 3
      if taxsw = "1"
         seek rstatus
         if eof()
            @ 24,00 clea
            @ 23,00 say ""
            wait "                   TAX STATUS of " + trim(TLNAM) + ", " + trim(TFNAM) + " not found." + CHR(07)
            @ 24,00 clear
            notax_sw = 1
         endif
         taxsw = "0"
      else
         seek ttxstat
         if eof()
            @ 24,00 clea
            @ 23,00 say ""
            wait "                   TAX STATUS of " + trim(TLNAM) + ", " + trim(TFNAM) + " not found." + CHR(07)
            @ 24,00 clea
            notax_sw = 1
         endif
         taxsw = "0"
      endif
      if notax_sw = 0
         sal1 = salary
         fix1 = fixrate
         pct1 = percent
      endif
      do whil .t.
         if notax_sw = 1
            notax_sw = 0
            ttax = 0.00
            exit
         endif
         skip
         if rstatus = "S** "
            if tearn < 646.00
               ttax = 0.00
               exit
            endif
            if tearn >= 646.00 .and. tearn < 750.00
               sal1 = 646.00
               fix1 = 0.00
               pct1 = 1
               varrate = ((tgross - sal1) * pct1) / 100
               ttax = fix1 + varrate
               exit
            endif
            if tearn >= 750.00
               sal1 = 750.00
               fix1 = 1.04
               pct1 = 3
               varrate = ((tgross - sal1) * pct1) / 100
               ttax = fix1 + varrate
               exit
            endif
         endif
         if rstatus = "HF* "
            if tearn < 771.00
               ttax = 0.00
               exit
            else
               sal1 = 771
               fix1 = 0.00
               pct1 = 1
               varrate = ((tgross - sal1) * pct1) / 100
               ttax = fix1 + varrate
               exit
            endif
         endif
         if tearn >= sal1 .and. tearn < salary
            varrate = ((tgross - sal1) * pct1) / 100
            ttax = fix1 + varrate
            exit
         endif
         sal1 = salary
         fix1 = fixrate
         pct1 = percent
      enddo

      sele 4
      seek tempn
      if !eof()
         tloansem = loansem
      endif
      
      deduct - ttax + tgsis + tgarir + tmcare + tmarir + tphilam + tptea + tlife + tloansem + tothers

      if (tgross + tpera) < deduct
         loan = 1
         tnetpay = tgross
         tgsis = 0.00
         tgarir = 0.00
         tmcare = 0.00
         tmarir = 0.00
         tphilam = 0.00
         tptea = 0.00
         tlife = 0.00
      else
         loan = 0
         tnetpay = (tgross + tpera) - deduct
      endif

      sele 5
      repl rate with trate
      repl earnedpay with tgross
      repl tax with ttax
      repl pera with tpera
      repl gsis with tgsis
      repl gsisarir with tgarir
      repl mcare with tmcare
      repl mcarearir with tmarir
      repl philam with tphil
      repl lifecare with tlife
      repl ptea with tptea
      repl loan with tloansem

      if loan = 0
         sele 4
         seek tempn
         tloanpd = loanpd + tloansem
         repl loanpd with tloanpd
      else
         sele 4
         seek tempn
         tarrears = arrears + tloansem
         repl arrears with tarrears
      endif

      sele 5
      repl others with tothers
      repl netpay with tnetpay

      sele 2
      seek tempn
      if eof()
         appe blan 
      endif
      repl empn with tempn
      repl lnam with tlnam
      repl fnam with tfnam
      repl mnam with tmnam
      repl add1 with tadd1 
      repl add2 with tadd2 
      repl age with tage 
      repl sex with tsex
      repl hdate with thdate 
      repl class with tclass 
      repl title with ttitle 
      repl divcde with tdivcde 
      repl estatus with testatus 
      repl mrate with tmrate 
      repl drate with tdrate 
      repl hrate with thrate
      repl txstat with ttxstat 
      repl gsisno with tgsisno 
      repl pera with tpera 
      repl g_cont with tgsis 
      repl g_arr with tgarir 
      repl m_care with tmcare 
      repl m_arr with tmarir 
      repl philam with tphilam 
      repl ptea with tptea 
      repl lifecare with tlife 
      repl loanamt with tloanamt
      repl loansem with tloansem
      repl loanpd with tloanpd
      repl others with tothers
      sele 5
      skip 
      if eof()
         exit
      endif
   enddo
enddo


FUNCTION cnt_rec
parameter rec_ctr
private i, fil

i = 1
do whil .t.
   do case
      case i = 1
           fil = "A"
      case i = 2
           fil = "B"
      case i = 3
           fil = "C"
      case i = 4
           fil = "D"
      case i = 5
           fil = "E"
      case i = 6
           fil = "F"
      case i = 7
           fil = "G"
      case i = 8
           fil = "H"
      case i = 9
           fil = "I"
      case i = 10
           fil = "J"
      otherwise
           exit
   endcase
   tranfile = fil + estat + REGMM + REGDD + REGYY
   use &tranfile
   REC_CTR = REC_CTR + reccount()
   i = i + 1
enddo       
clos data                                            
return rec_ctr                                                    