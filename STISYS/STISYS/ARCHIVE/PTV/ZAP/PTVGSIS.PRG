set escape on
set wrap on
set cursor on
set message to 24 center
msubsys = "GSIS Salary Loan File"
do heading
do startup

mastfile = "MR" + REGMM + REGDD + REGYY 
sele 1
use &mastfile 
inde on empn to &mastfile

sele 2
use gsisloan
inde on empn to gsisloan


MEMPN = spac(3)
LNAM = spac(15)
FNAM = spac(15)
MNAM = spac(15)
MGSIS = SPAC(10)
MLOANAMT = 0.00
MLOANMON = 0.00
MLOANPD = 0.00
marrears = 0.00
MFROMDATE = CTOD("  /  /  ")
MTODATE = CTOD("  /  /  ")

@ 07,00 clear
do whil .t. 
   sele 2
   mEMPN = empn   
   mLNAM = lnam
   mFNAM = fnam
   mMNAM = mnam
   mGSIS = gsisno
   mLOANAMT = loanamt
   mLOANSEM = loansem
   mLOANPD = loanpd
   mARREARS = arrears
   mFROMDATE = fromdate
   mTODATE = todate

   @ 10,08 say 'Employee No.  :'   
   @ 11,08 say 'First Name    :'
   @ 12,08 say 'Last Name     :'
   @ 13,08 say 'Middle Name   :'
   @ 14,08 say 'GSIS No.      :'
   @ 10,48 say 'Loan Amount   :'
   @ 11,48 say 'Semi-monthly  :'
   @ 12,48 say '  Deduction'        
   @ 13,48 say 'Paid Loan     :'
   @ 14,48 say 'Arrears       :'
   @ 17,27 say 'Date granted     :'
   @ 18,27 say 'Complete Payment :'

   @ 10,24  say mempn
   @ 11,24  say mlnam
   @ 12,24 say mfnam
   @ 13,24 say mmnam
   @ 14,24 say mgsis
   @ 10,64 say mloanamt pict '99,999.99'
   @ 11,64 say mloansem pict '99,999.99'
   @ 13,64 say mloanpd  pict '99,999.99'
   @ 14,64 say marrears pict '99,999.99'
   @ 17,46 say mfromdate
   @ 18,46 say mtodate

   @ 22,00 say REPL(CHR(205),80)
   @ 23,00 prompt "   Add    ";
           message "         Add New Employee         "
   @ 23,10 prompt "   Edit   ";
           message "         Edit Employee Record     "
   @ 23,20 prompt "  Delete  ";
           message "         Delete or Undelete Record"
   @ 23,30 prompt "  Search  ";
           message "         Search Employee Record   "
   @ 23,41 prompt "   Exit   ";
           message "         Return to Main Menu      "
   @ 24,00 say chr(24) + "PgUp" + " "  + chr(25) + "PgDn" + " to browse"
   menu to CHOICE1
   if lastkey() = 3 .or. lastkey() = 24           && Page Down
      skip
      if eof()
         do et
         do errline with 6
         skip-1
      endif
      loop
   endif
   if lastkey() = 18 .or. lastkey() = 5	      && Page Up
      skip -1
      if bof()
         do et
         do errline with 5
      endif
      loop
   endif
   if CHOICE1 = 1
      do whil lastkey() <> 27
         @ 08,32 get MEMPN
         read
         if lastkey() = 27
            exit
         endif
         seek MEMPN
         if ! eof()
            @ 24,00 clea
            @ 23,00 say ''
            @ 24,00 say 'Employee No. already exists.'
            inkey(3)
            loop
         endif
         sele 1
         seek mempn
         if eof()
            @ 24,00 clea
            @ 23,00 say ''
            @ 24,00 say 'Employee No. does not exist.'
            inkey(3)
            loop
         endif
         mlnam = lnam
         mfnam = fnam
         mmnam = mnam
         mgsis = gsisno
         sele 2

         @ 10,24 get mempn                   
         @ 11,24 get mlnam                   
         @ 12,24 get mfnam                    
         @ 13,24 get mmnam                    
         @ 14,24 get mgsis                    
         @ 10,64 get mloanamt pict '99,999.99'
         @ 11,64 get mloansem pict '99,999.99'
         @ 13,64 say mloanpd  pict '99,999.99'
         @ 14,64 say marrears pict '99,999.99'
         @ 17,46 get mfromdate                
         @ 18,46 get mtodate                  
         read                                               

         if lastkey() = 27                                  
            exit                                            
         endif
         appe blan         
         repl empn with mempn
         repl lnam with mlnam
         repl fnam with mfnam
         repl mnam with mmnam
         repl gsisno with mgsis
         repl loanamt with mloanamt
         repl loansem with mloansem
         repl fromdate with mfromdate
         repl todate with mtodate
         sele 1
         exit
      enddo
   endif
   if CHOICE1 = 2
      @ 10,64 get mloanamt pict '99,999.99'
      @ 11,64 get mloansem pict '99,999.99'
      @ 13,64 say mloanpd  pict '99,999.99'
      @ 14,64 say marrears pict '99,999.99'
      @ 17,46 get mfromdate                
      @ 18,46 get mtodate                  
      read
      if lastkey() = 27
         loop
      endif                                               
   endif

   if CHOICE1 = 3
      store "N" to DEL                                              
      @ 24,00 clea                                                  
      @ 24,00 say "Record ready for deletion. Proceed? Y/N "        
      @ 24,42 get DEL pict "!"                                      
      read                                                          
      if DEL = "Y"                                                  
         delete                                                     
         pack
      else                                                          
         if DEL = "N"                                               
          *                                                         
         endif                                                      
      endif                                                         
      @ 24,00 clea
   endif

   if CHOICE1 = 4
      save screen
      @ 13,28 to 15,57
      @ 14,29 say "  Search Employee No.       "       
      @ 14,51 get mempn valid validemp(mempn)
      read
      restore screen
   endif

   if CHOICE1 = 5
      @ 08,00 clea
      clos data
      set cursor off
      return
   endif      

enddo

func validemp
parameter mempn

if mempn = spac(3)
   retu .f.
endif

seek mempn
if eof()
   tone(0250,01)
   tone(0275,01)
   tone(0300,01)
   tone(0275,01)
   tone(0250,01)
   do errline with 4
   skip-1
   retu .f.
endif
retu .t.
 