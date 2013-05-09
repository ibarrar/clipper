@ 06,00 say chr(212)
@ 06,25 say chr(207)
@ 07,00 clea
set cursor on
msubsys = "Absences/Overtime File"
do heading

mastfile = "MR" + REGMM + REGDD + REGYY
sele 1
use &mastfile inde &mastfile

tranfile = TRANS + ESTAT + REGMM + REGDD + REGYY
sele 2
use &tranfile inde &tranfile

set func 6 to chr(23)
set escape on
@ 08,05 say "NAME OF EMPLOYEE"
@ 08,33 say "ABSENCES/UNDERTIME"
@ 08,60 say "OVERTIME"
REC_CNT = reccount()
if REC_CNT = 0
   @ 24,00 say "No records to process. Returning to Main Menu."
   inkey(5)
   clos data
   set cursor off
   return
endif

I = 1
savsw = "0"
do whil .t.
   j = i
   j = j + 100
   J = subs(str(j),9,2)
   MEMPN = "EMPN" + j
   MLNAM = "LNAM" + J
   MFNAM = "FNAM" + J
   MMNAM = "MNAM" + J      
   MABSENT = "ABSENT" + j
   MOVER = "OVERTIME" + j
   &MEMPN = empn
   &MLNAM = lnam
   &MFNAM = fnam
   &MMNAM = mnam
   &MOVER = overtime
   &MABSENT = absences
   i = i + 1
   skip
   if eof()
      go top
      exit
   endif
enddo

@ 24,00 clea 
@ 24,00 say chr(25) + 'PgDn' + '  ' + chr(24) + 'PgUp to browse     F6 - Save   Esc - to exit'

do whil .t.
   PGCTR = 1
   i = 1
   do whil .t.
      LCTR = 10
      PGCNT = 0
*@ 09,00 clea to 23,79
      do whil .t.
         ENDSW = "0"
         if eof()
            ENDSW = "1"
            exit
         endif
         if savsw = "1"
            savsw = "0"
            i = 1
         endif
         j = i
         J = j + 100
         J = subs(str(j),9,2)
*        MNAME = "NAME" + j
         MEMPN = "EMPN" + j
         MLNAM = "LNAM" + J
         MFNAM = "FNAM" + J
         MMNAM = "MNAM" + J
         MABSENT = "ABSENT" + j
         MOVER = "OVERTIME" + j
         l = len(trim(&MLNAM))
         f = len(trim(&MFNAM))
         @ LCTR,05 say trim(&MLNAM) + ", " + trim(&MFNAM) + " " + subs(&MMNAM,1,1) + "."  + spac(33-(l+f+4))
         @ LCTR,38 get &MABSENT pict "9,999.99"
         @ LCTR,60 get &MOVER pict "9,999.99"
         LCTR = LCTR + 1
         PGCNT = PGCNT + 1
         i = i + 1
         skip
         if LCTR = 23 .or. eof()
            if eof()
               endsw = "1"
            endif
            exit
         endif
      enddo
      read
      do whil .t.
*         read
         if lastkey() = 23
            i = 1
            do whil .t.
               j = i
               j = j + 100
               j = subs(str(j),9,2)
               MEMPN = "EMPN" + j
               MLNAM = "LNAM" + J
               MFNAM = "FNAM" + J
               MMNAM = "MNAM" + J
               MABSENT = "ABSENT" + j
               MOVER = "OVERTIME" + j
               seek &MEMPN
            *   repl name with &MNAME
               repl absences with &MABSENT
               repl overtime with &MOVER
               i = i + 1                           
	       if i > rec_cnt
                  SAVSW = "1"
                  PGCNT = 0
                  PGCTR = 1 
                  go top
                  exit
               endif
            enddo
         endif
         if SAVSW = "1"
            exit
         endif
         if lastkey() = 27   
            exit
         endif
         if lastkey() = 18
            if PGCTR = 1
               ??chr(07)
               @ 24,69 say "FIRST PAGE"
               i = 1
               go top
               exit
            endif
            SKIPCTR = 13 + PGCNT
            i = i - SKIPCTR     
            PGCTR = PGCTR - 1
            skip - SKIPCTR
            exit
         endif
         if lastkey() = 3 .or. lastkey() = 13
            if ENDSW = "1" 
               ??chr(07)
               @ 24,69 say "LAST PAGE"
               i = 1
               PGCTR = 1
               go top
               exit
            endif
            PGCTR = PGCTR + 1
            exit
         endif
      enddo
      if lastkey() = 27     
         exit  
      endif
   enddo
   if lastkey() = 27
      @ 07,00 clea
      clos data
      set cursor off
      return
   endif
enddo
