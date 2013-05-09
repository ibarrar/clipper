set escape on
set wrap on
set cursor on
set message to 24 center
msubsys = "Employee Master File"
do heading
mastfile = 'mr' + regmm + regdd + regyy
mastfile = subs(mastfile,1,8)
sele 1
use &mastfile 
inde on empn to &mastfile

sele 2
use ptvtxtab
inde on status to ptvtxtab

sele 3
use gsisloan
inde on empn to gsisloan

set deleted on

MEMPN = spac(3)
LNAM = spac(15)
FNAM = spac(15)
MNAM = spac(15)
MADD1 = Spac(25)
MADD2 = SPAC(25)
MAGE = 0
MSEX = spac(1)
MHDATE = CTOD("  /  /  ")
MCLASS = spac(01)
MTITLE = spac(20)
MDIVCDE = spac(02)
MESTATUS = SPAC(1)
MMRATE = 0.00
MDRATE = 0.00
MHRATE = 0.00
MTXSTAT = spac(04)
MGSIS = spac(10)
MG_ARR = 0.00 
MG_CONT = 0.00  
MM_CARE = 0.00  
MM_ARR = 0.00 
MPERA = 0.00
MLIFE = 0.00
MPHIL = 0.00
MPTEA = 0.00
MOTHERS = 0.00
MLOANAMT = 0.00
MLOANMON = 0.00
MLOANPD = 0.00
@ 07,00 clear

do whil .t. 
   sele 1
   MEMPN = empn   
   MLNAM = lnam
   MFNAM = fnam    
   MMNAM = mnam    
   MADD1 = add1    
   MADD2 = add2    
   MAGE = age
   MSEX = sex    
   MHDATE = hdate           
   MCLASS = class   
   MTITLE = title   
   MDIVCDE = divcde
   MESTATUS = estatus 
   MMRATE = mrate
   MDRATE = drate
   MHRATE = hrate
   MTXSTAT = txstat
   MGSIS = gsisno
   MG_ARR = g_arr
   MG_CONT = g_cont
   MM_CARE = m_care
   MM_ARR = m_arr
   MPERA = pera
   MLIFE = lifecare
   MPHIL = philam
   MPTEA = ptea
   sele 3
   seek MEMPN
   MLOANAMT = loanamt
   MLOANSEM = loansem
   MLOANPD = loanpd
   sele 1
   MOTHERS = others
   WHAT = " "
   @ 08,04 say "A.  Employee No. : "
   @ 09,04 say "B.  Last Name    : "
   @ 10,04 say "C.  First Name   : "
   @ 11,04 say "D.  Middle Name  : "
   @ 12,04 say "E.  Address      : "            
   @ 14,04 say "F.  Sex          : " 
   @ 15,04 say "G.  Date Hired   : " 
   @ 16,04 say "H.  Status       : " 
   @ 17,04 say "I.  Designation  : "
   @ 18,04 say "J.  Division     : "
   @ 19,04 say "K.  Monthly Rate : "                   
   @ 20,04 say "    Daily Rate   : "                   
   @ 21,04 say "    Hourly Rate  : "

   @ 08,50 say "L.  Tax Status   : "                     
   @ 09,50 say "M.  GSIS No.     : "
   @ 10,50 say "N.  GSIS Cont'n  : "
   @ 11,50 say "O.  GSIS Arrears : "
   @ 12,50 say "P.  Medicare     : "
   @ 13,50 say "Q.  Med. Arrears : "
   @ 14,50 say "R.  Allowance    : "
   @ 15,50 say "S.  Philam       : "
   @ 16,50 say "T.  LifeCare     : "
   @ 17,50 say "U.  PTEA         : "
   @ 18,50 say "V.  Salary Loan  : "
   @ 19,50 say "W.  Semi-mo. Amt.: "
   @ 20,50 say "X.  Loan Paid    : "
   @ 21,50 say "Y.  Others       : "
   @ 08,24 say MEMPN 
   @ 09,24 say MLNAM
   @ 10,24 say MFNAM
   @ 11,24 say MMNAM
   @ 12,24 say MADD1
   @ 13,24 say MADD2                
   do case
      case MSEX = "M"
           @ 14,24 say "MALE  "
      case MSEX = "F"
           @ 14,24 say "FEMALE"
      otherwise
           @ 14,24 say "      "
   endcase                 
   @ 15,24 say MHDATE               
   do case
      case MESTATUS = "R"
           @ 16,24 say "REGULAR    "
      case MESTATUS = "C"
           @ 16,24 say "CONTRACTUAL"
      otherwise
           @ 16,24 say "           "       
   endcase
   @ 17,24 say MTITLE               
   @ 18,24 say MDIVCDE 
   @ 19,24 say MRATE pict "99,999.99" 
   @ 20,26 say MDRATE pict "999.99" 
   @ 21,27 say MHRATE pict "99.99"  
   @ 08,69 say MTXSTAT
   @ 09,69 say MGSIS              
   @ 10,69 say MG_CONT pict "99,999.99"
   @ 11,69 say MG_ARR pict "99,999.99" 
   @ 12,69 say MM_CARE pict "99,999.99"  
   @ 13,69 say MM_ARR pict "99,999.99"
   @ 14,69 say MPERA pict "99,999.99"
   @ 15,69 say MPHIL pict "99,999.99"
   @ 16,69 say MLIFE pict "99,999.99"
   @ 17,69 say MPTEA pict "99,999.99"
   @ 18,69 say MLOANAMT pict "99,999.99"
   @ 19,69 say MLOANSEM pict "99,999.99"
   @ 20,69 say MLOANPD pict "99,999.99"
   @ 21,69 say MOTHERS pict "99,999.99"

   @ 22,00 say REPL(CHR(205),80)
   @ 23,00 prompt "   Add    ";
           message "         Add New Employee         "
   @ 23,10 prompt "   Edit   ";
           message "         Edit Employee Record     "
   @ 23,20 prompt "  Delete  ";
           message "         Delete or Undelete Record"
   @ 23,30 prompt "  Search  ";
           message "         Search Employee Record   "
   @ 23,43 say "<F6 save>   <Esc  exit>"
   @ 24,00 say chr(24) + "PgUp" + " "  + chr(25) + "PgDn" + " to browse"
   menu to CHOICE1
   if lastkey() = 27
      @ 08,00 clea
      set cursor off
      clos data
      return
   endif      
   if lastkey() = 3 .or. lastkey() = 24           && Page Down
      skip
      if eof()
         do et
         do errline with 6
         skip-1
      endif
      MEMPN = empn   
      MLNAM = lnam
      MFNAM = fnam    
      MMNAM = mnam      
      MADD1 = add1      
      MADD2 = add2      
      MAGE = age        
      MSEX = sex        
      MHDATE = hdate           
      MCLASS = class    
      MTITLE = title    
      MDIVCDE = divcde
      MESTATUS = estatus 
      MMRATE = mrate    
      MDRATE = drate    
      MHRATE = hrate    
      MTXSTAT = txstat
      MGSIS = gsisno
      MG_ARR = g_arr
      MG_CONT = g_cont
      MM_CARE = m_care
      MM_ARR = m_arr
      MPERA = pera
      MLIFE = lifecare
      MPHIL = philam
      MPTEA = ptea
      MLOANAMT = loanamt
      MLOANSEM = loansem
      MLOANPD = loanpd
      MOTHERS = others
      loop
   endif
   if lastkey() = 18 .or. lastkey() = 5	      && Page Up
      skip -1
      if bof()
         do et
         do errline with 5
      else
         @ 24,66 say "            "
      endif
      MEMPN = empn   
      MLNAM = lnam
      MFNAM = fnam    
      MMNAM = mnam      
      MADD1 = add1      
      MADD2 = add2      
      MAGE = age        
      MSEX = sex        
      MHDATE = hdate           
      MCLASS = class    
      MTITLE = title    
      MDIVCDE = divcde
      MESTATUS = estatus 
      MMRATE = mrate    
      MDRATE = drate    
      MHRATE = hrate    
      MTXSTAT = txstat
      MGSIS = gsisno
      MG_ARR = g_arr
      MG_CONT = g_cont
      MM_CARE = m_care
      MM_ARR = m_arr
      MPERA = pera
      MLIFE = lifecare
      MPHIL = philam
      MPTEA = ptea
      MLOANAMT = loanamt
      MLOANSEM = loansem
      MLOANPD = loanpd
      MOTHERS = others
      loop
   endif
   if CHOICE1 = 1
      set func 6 to chr(23)
      MEMPN = spac(3)
      MLNAM = spac(15)
      MFNAM = spac(15)
      MMNAM = spac(15)
      MADD1 = Spac(25)
      MADD2 = SPAC(25)
      MAGE = 0
      MSEX = spac(1)
      MHDATE = CTOD("  /  /  ")
      MCLASS = spac(01)
      MTITLE = spac(20)
      MESTATUS = SPAC(01)
      MDIVCDE = spac(02)
      MMRATE = 0.00
      MDRATE = 0.00
      MHRATE = 0.00
      MTXSTAT = spac(04)
      MGSIS = spac(10)
      MG_ARR = 0.00   
      MG_CONT = 0.00  
      MM_CARE = 0.00  
      MM_ARR = 0.00   
      MPERA = 0.00
      MLIFE = 0.00
      MPHIL = 0.00
      MPTEA = 0.00
      MLOANAMT = 0.00
      MLOANSEM = 0.00
      MLOANPD = 0.00
      MOTHERS = 0.00
      do whil .t.
         @ 08,24 get MEMPN valid no_dupes()
         read
         if lastkey() = 27
            exit
         endif
         @ 09,24 get MLNAM pict "@K !!!!!!!!!!!!!!!"
         @ 10,24 get MFNAM pict "@K !!!!!!!!!!!!!!!"                        
         @ 11,24 get MMNAM pict "@K !!!!!!!!!!!!!!!"                        
         @ 12,24 get MADD1 pict "@K !!!!!!!!!!!!!!!!!!!!!!!!!"                        
         @ 13,24 get MADD2 pict "@K !!!!!!!!!!!!!!!!!!!!!!!!!"                        
         @ 14,24 get MSEX pict "@K !"                         
         @ 15,24 get MHDATE                                 
         @ 16,24 get MESTATUS pict "@K !"                     
         @ 17,24 get MTITLE pict "@K !!!!!!!!!!!!!!!!!!!!"                       
         @ 18,24 get MDIVCDE pict "@K !!" valid (mdivcde $'ARACBRBCCRCCDRDCERECFRFCGRGCHRHCIRICJRJC')
         @ 19,24 get MMRATE pict "99,999.99" valid MMRATE > 0.00                

         @ 08,69 get MTXSTAT pict "@K !!!!" valid seek_tax()                      
         @ 09,69 get MGSIS pict "@K !!!!!!!!!!"                        
         @ 10,69 get MG_CONT pict "99,999.99"                
         @ 11,69 get MG_ARR pict "99,999.99"                   
         @ 12,69 get MM_CARE pict "99,999.99"                   
         @ 13,69 get MM_ARR pict "99,999.99"                    
         @ 14,69 get MPERA pict "99,999.99"                  
         @ 15,69 get MPHIL pict "99,999.99"                  
         @ 16,69 get MLIFE pict "99,999.99"                  
         @ 17,69 get MPTEA pict "99,999.99"                    
         @ 18,69 get MLOANAMT pict "99,999.99"
         @ 19,69 get MLOANSEM pict "99,999.99"
         @ 20,69 get MLOANPD pict "99,999.99"
         @ 21,69 get MOTHERS pict "99,999.99"
         read                                               
         if lastkey() = 27                                  
            exit                                            
         endif                                              
         MDRATE = MMRATE / 22                               
         @ 20,26 say MDRATE pict "999.99"                   
         MHRATE = MDRATE / 8                                
         @ 21,27 say MHRATE pict "99.99"                    
         if lastkey() = 23 .or. lastkey() = 13              
            sele 1                                      
            appe blan                                   
            repl empn with MEMPN                        
            repl LNAM with MLNAM                        
            repl fnam with MFNAM                        
            repl mnam with MMNAM                        
            repl add1 with MADD1                        
            repl add2 with MADD2                        
            repl age with MAGE                          
            repl sex with MSEX                          
            repl hdate with MHDATE                      
            repl class with MCLASS                      
            repl title with MTITLE                      
            repl divcde with MDIVCDE                    
            repl estatus with MESTATUS                  
            repl mrate with MMRATE                      
            repl drate with MDRATE                      
            repl hrate with MHRATE                      
            repl txstat with MTXSTAT                    
            repl gsisno with MGSIS                      
            repl g_cont with MG_CONT                    
            repl g_arr with MG_ARR                      
            repl m_care with MM_CARE                    
            repl m_arr with MM_ARR                      
            repl pera with MPERA                        
            repl lifecare with MLIFE                    
            repl philam with MPHIL                      
            repl ptea with PTEA                         
            repl loanamt with MLOANAMT                  
            repl loansem with MLOANSEM                  
            repl loanpd with MLOANPD                    
            repl others with MOTHERS                    
            set func 6 to ""
            tranfile = mdivcde + regmm + regdd + regyy
            sele 2
            use &tranfile inde &tranfile
            appe blan
            repl empn with mempn
            repl lnam with mlnam
            repl fnam with mfnam
            repl mnam with mmnam
            sele 1
            exit                                        
         endif                                          
      enddo
   endif
   if CHOICE1 = 2
      @ 24,00 clea
      @ 24,00 say "Make your choice => "
      ENTRY = " "
      @ 24,20 get ENTRY pict "!" valid (ENTRY $"ABCDEFGHIJKLMNOPQRSTUY")
      read
      do case
         case ENTRY = "A"
              @ 08,24 get MEMPN valid no_dupes()
              read
              repl empn with MEMPN
         case ENTRY = "B"
              @ 09,24 get MLNAM pict "@K !!!!!!!!!!!!!!!"
              read
              repl lnam with MLNAM
         case ENTRY = "C"
              @ 10,24 get MFNAM pict "@K !!!!!!!!!!!!!!!"
              read
              repl fnam with MFNAM
         case ENTRY = "D"
              @ 11,24 get MMNAM pict "@K !!!!!!!!!!!!!!!"
              read
              repl mnam with MMNAM
         case ENTRY = "E"
              @ 12,24 get MADD1 pict "@K !!!!!!!!!!!!!!!!!!!!!!!!!"
              @ 13,24 get MADD2 pict "@K !!!!!!!!!!!!!!!!!!!!!!!!!"
              read
              repl add1 with MADD1
              repl add2 with MADD2
         case ENTRY = "F"
              @ 14,24 get MSEX pict "@K !"       
              read
              repl sex with MSEX
         case ENTRY = "G"
              @ 15,24 get MHDATE               
              read
              repl hdate with MHDATE
         case ENTRY = "H"
              @ 16,24 get MESTATUS pict "@K !"   
              read
              repl estatus with MESTATUS
         case ENTRY = "I"
              @ 17,24 get MTITLE pict "@K !!!!!!!!!!!!!!!!!!!!!!!!!"     
              read
              repl title with MTITLE
         case ENTRY = "J"
              @ 18,24 get MDIVCDE pict "@K !!" valid (mdivcde $'ARACBRBCCRCCDRDCERECFRFCGRGCHRHCIRICJRJC')
              read
              repl divcde with MDIVCDE
         case ENTRY = "K"
              @ 19,24 get MMRATE pict "99,999.99" valid MMRATE > 0.00
              read
              MDRATE = MMRATE / 22
              MHRATE = MDRATE / 8
              @ 20,26 say MDRATE pict "999.99" 
              @ 21,27 say MHRATE pict "99.99"  
              repl mrate with MMRATE
              repl drate with MDRATE
              repl hrate with MHRATE
         case ENTRY = "L"
              @ 08,69 get MTXSTAT pict "@K !!!!" valid seek_tax()
              read
              repl txstat with MTXSTAT
         case ENTRY = "M"
              @ 09,69 get MGSIS pict "@K !!!!!!!!!!"
              read
              repl gsisno with MGSIS
         case ENTRY = "N"
              @ 10,69 get MG_CONT pict "99,999.99"
              read
              repl g_cont with MG_CONT
         case ENTRY = "O"
              @ 11,69 get MG_ARR pict "99,999.99"
              read
              repl g_arr with MG_ARR
         case ENTRY = "P"
              @ 12,69 get MM_CARE pict "99,999.99"
              read
              repl m_care with MM_CARE
         case ENTRY = "Q"
              @ 13,69 get MM_ARR pict "99,999.99"
              read
              repl m_arr with MM_ARR
         case ENTRY = "R"
              @ 14,69 get MPERA pict "99,999.99"
              read
              repl pera with MPERA
         case ENTRY = "S"
              @ 15,69 get MPHIL pict "99,999.99"
              read
              repl philam with MPHIL
         case ENTRY = "T"
              @ 16,69 get MLIFE pict "99,999.99"
              read
              repl lifecare with Mlife
         case ENTRY = "U"
              @ 17,69 get MPTEA pict "99,999.99"
              read
              repl ptea with MPTEA
         case ENTRY = "Y"
              @ 21,69 get MOTHERS pict "99,999.99"
              read
              repl others with MOTHERS
      endcase
   endif
   if CHOICE1 = 3
      store "N" to DEL
      @ 24,00 clea
      @ 24,00 say "Record ready for deletion. Proceed? Y/N "
      @ 24,42 get DEL pict "!"
      read
      if DEL = "Y"
         tranfile = mdivcde + regmm + regdd + regyy
         select 4
         use &tranfile inde &tranfile
         seek mempn
         delete
         pack
         sele 1
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
      rempn = spac(3)
      @ 14,29 say "  Search Employee No.       "       
      @ 14,52 get rempn valid val_emp(rempn)
      read
      restore screen
   endif
enddo



func val_emp
parameter rempn
if rempn = spac(3)
   return .f.
endif
seek rempn
if eof()
   tone(0250,01)
   tone(0275,01)
   tone(0300,01)
   tone(0275,01)
   tone(0250,01)
   do errline with 4
   skip-1
   return .f.
endif
return .t.





func no_dupes

if MEMPN = spac(3)
   return .f.
else
   seek MEMPN
   if .not. eof()
      tone(0250,01)
      tone(0275,01)
      tone(0300,01)
      tone(0275,01)
      tone(0250,01)
      @ 24,00 clea
      @ 23,00 say ''
      wait "EMPLOYEE NO. already exists. Press any key..."
      inkey(5)
      @ 24,00 clea
      @ 24,00 say chr(24) + "PgDn" + " "  + chr(25) + "PgUp" + " to browse"
      return .f.
   else   
      return .t.
   endif
endif





func seek_tax

if MTXSTAT = spac(4)
   return .f.
else
   sele 2                                             
   seek MTXSTAT                                       
   if eof()                                           
      tone(0250,01)
      tone(0275,01)
      tone(0300,01)
      tone(0275,01)
      tone(0250,01)
      do errline with 7
      @ 24,00 clea                                    
      @ 24,00 say chr(24) + "PgDn" + " "  + chr(25) + "PgUp" + " to browse"
      sele 1                                          
      return .f.
   else
      sele 1
      return .t.
   endif
endif                                              
