use ptvtxtab
index on status to ptvtxtab
set func 6 to chr(23)
set deleted off

@ 08,00 clear
do whil .t. 
   do init
   do whil .t.
      @ 08,06 say "Tax Status"
      @ 08,26 say "Salary"
      @ 08,42 say "Fix Rate"
      @ 08,60 say "Percent"
      i = 0
      lctr = 10
      do whil i < 10
         i = i + 1
         j = i + 100
         MSTATUS = "STAT" + subs(str(j),9,2)
         MSALARY = "SAL" + subs(str(j),9,2)
         MFIXRAT = "FIX" + subs(str(j),9,2)
         MPERCNT = "PER" + subs(str(j),9,2)
         &MSTATUS = status
         &MSALARY = salary
         &MFIXRAT = fixrate
         &MPERCNT = percent
         @ lctr,10 say &MSTATUS
         @ lctr,26 say &MSALARY
         @ lctr,41 say &MFIXRAT
         @ lctr,62 say &MPERCNT   
         skip
         if eof()
            exit
         endif
         lctr = lctr + 1
      enddo
      @ 22,00 say REPL(CHR(205),80)
      @ 23,00 say "<A>dd    <E>dit    <D>elete    <F6  save>    <Esc  exit>"
      @ 24,00 say "<PgDn  next>   <PgUp  previous>"
      STORE SPAC(01) TO WHAT
      @ 24,33 get WHAT pict "!"
      read
      if lastkey() = 27
         @ 08,00 clea
         clos data
         return
      endif
      if WHAT = "A"
         i = 0                                  
         lctr = 10
         do whil i < 10                         
            i = i + 1                           
            j = i + 100                         
            MSTATUS = "STAT" + subs(str(j),9,2) 
            MSALARY = "SAL" + subs(str(j),9,2)  
            MFIXRAT = "FIX" + subs(str(j),6,2)  
            MPERCNT = "PER" + subs(str(j),2,0)  
            &MSTATUS = spac(08)                 
            &MSALARY = spac(05)                 
            &MFIXRAT = 0.00                     
            &MPERCNT = 0                        
            @ lctr,10 get &MSTATUS              
            @ lctr,26 get &MSALARY              
            @ lctr,41 get &MFIXRAT pict "9,999.99"             
            @ lctr,62 get &MPERCNT pict "99"             
            lctr = lctr + 1
         enddo                                  
         read
         if lastkey() = 27 
            loop
         endif
      endif
   enddo
enddo

procedure init
i = 0
do whil i < 10
   i = i + 1
   j = i + 100
   MSTATUS = "STAT" + subs(str(j),9,2)
   MSALARY = "SAL" + subs(str(j),9,2)
   MFIXRAT = "FIX" + subs(str(j),9,2)
   MPERCNT = "PER" + subs(str(j),9,2)
   &MSTATUS = spac(08)
   &MSALARY = spac(05)
   &MFIXRAT = 0.00
   &MPERCNT = 0
enddo





















*8    6ax Status    20    26lary    36    42x Rate    54    60rcent             

*9       10xx             26999          41,999.99            62 % 
*10                       99999          99,999.99            99 % 
*11                       99999          99,999.99            99 % 
*12                       99999          99,999.99            99 % 
*13                       99999          99,999.99            99 % 
*14                       99999          99,999.99            99 % 
*15                       99999          99,999.99            99 % 
*16                       99999          99,999.99            99 % 
*17                       99999          99,999.99            99 % 
*18                       99999          99,999.99            99 % 
*19                       99999          99,999.99            99 % 
