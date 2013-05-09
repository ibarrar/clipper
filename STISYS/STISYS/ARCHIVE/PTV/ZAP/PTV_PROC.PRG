Procedure DRAWBOX
parameter t,l,b,r,dobol
@ t,l clear to b,r

if dobol
   @ t,l to b,r double
else
   @ t,l to b,r 
endif
return

******************************

Procedure getpass
private pword

pword = spac(08)

do drawbox with 9,21,11,60,.f.

@ 10,23 say "WHAT IS YOUR PASSWORD? => " 
@ 10,49 say ""
set colo to ,N,
@ 10,49 get PWORD PICT "@!"

read         
set colo to
if PWORD = "PTV4MAIN"
   clea                                             
   do drawbox with 8,19,17,56,.t.

   @ 09,20 say "                                    "
   @ 10,20 SAY "          Hello Operator!           "
   @ 11,20 SAY "                                    "
   @ 12,20 SAY "                                    "
   @ 13,20 SAY "           LOGGING ON TO            " 
   @ 14,20 SAY "              PTV-4                 "
   @ 15,20 SAY "          PAYROLL SYSTEM            "
   @ 16,20 SAY "                                    "
   inkey(5)
else
   @ 13,00 SAY "                               Incorrect password."
   @ 15,00 SAY "                                  GOODBYE ! " + CHR(1)
   set colo to
   set cursor on
   @ 24,00 say ''
   restore screen from before
   quit
endif

*****************************

Procedure getfile

bell = chr(07) + chr(07) + chr(07)

mastfile = "MR" + regmm + regdd + regyy + ".DBF"              && Master File
if .not. file("&mastfile")
   ??bell
   WAIT "ERROR!!! Masterfile File not found. Aborting."
   inkey(0)
   quit
endif
mastfile = subs(mastfile,1,8)   
use &mastfile                   
index on empn to &mastfile      

taxfile = "ptvtxtab.dbf"                                      && Tax Table  
if .not. file("&taxfile")
   ??bell
   wait "PTVTXTAB.dbf not found. Aborting."
   inkey(0)
   quit
endif

// Transaction Files

private fil, i
fil = "  "
i = 1
do whil i <= 20
   do case
      case i = 1      
           fil = "AR" 
      case i = 2      
           fil = "BR" 
      case i = 3      
           fil = "CR" 
      case i = 4      
           fil = "DR" 
      case i = 5      
           fil = "ER" 
      case i = 6      
           fil = "FR" 
      case i = 7      
           fil = "GR" 
      case i = 8      
           fil = "HR" 
      case i = 9      
           fil = "IR" 
      case i = 10     
           fil = "JR" 
      case i = 11      
           fil = "AC" 
      case i = 12      
           fil = "BC" 
      case i = 13      
           fil = "CC" 
      case i = 14      
           fil = "DC" 
      case i = 15      
           fil = "EC" 
      case i = 16      
           fil = "FC" 
      case i = 17      
           fil = "GC" 
      case i = 18      
           fil = "HC" 
      case i = 19      
           fil = "IC" 
      case i = 20     
           fil = "JC" 
   endcase            
   tranfile = fil + regmm + regdd + regyy + ".DBF"
   if .not. file("&tranfile")      
      tranmas = "ptvmast.dbf"
      if .not. file("&tranmas")
         ??bell
         wait "ERROR!!! PTVMAST.DBF not found. Aborting..."
         inkey(0)                      
         quit
      endif
      use ptvmast                 
      copy stru to &tranfile       
   endif                           
   sele 1
   tranfile = subs(tranfile,1,8)   
   use &tranfile                   
   inde on empn to &tranfile       
   sele 2 
   use &mastfile inde &mastfile
   dcode = '  '
   do whil .t.
      dcode = divcde
      if fil = dcode
         sele 1
         seek b->empn
         if eof()
            appe blan
         endif
         repl empn with b->empn
         repl lnam with b->lnam
         repl fnam with b->fnam
         repl mnam with b->mnam
      else
         skip
         if eof()
            sele 2
            go top
            exit
         endif
      endif
      sele 2
      skip
   enddo
   i = i + 1
enddo
clos database
return

**********************************

Procedure paydate_val
set cursor on
public regmm, regdd, regyy
clea
do whil .t.

   store "0" to invsw
   store "  " to regmm, regdd, regyy

   @ 08,00 say "                              ENTER PAYROLL DATE"
   @ 10,00 say "                                MONTH -> "
   @ 10,43 get regmm pict "99"
   @ 12,00 say "                                DAY   -> "
   @ 12,43 get regdd pict "99"
   @ 14,00 say "                                YEAR  -> "
   @ 14,43 get regyy pict "99"
   @ 16,00 say "                                <ESC> - TO QUIT"
   
   read                                                                                    

   if lastkey() = 27
      clear
      quit
   endif

   tempdate = regmm + "/" + regdd + "/" + regyy
   tempdate = ctod(tempdate)
   mdate = cmon(tempdate)
   cmm = cmonth(tempdate)
   cyy = year(tempdate)
   if regdd = "15"
      fdd = "01"
   else
      fdd = "16"
   endif
   if regmm > "12" .or. regmm < "00" .or. regmm = "  "
      invsw = "1"
   endif
   if regmm = "01" .or. regmm = "03" .or. regmm = "05" .or. regmm = "07" .or. regmm = "08" .or. regmm = "10" .or. regmm = "12"
      if regdd = "15" .or. regdd = "31"
         *
      else
         invsw = "1"
      endif
   else
      if regmm = "04" .or. regmm = "06" .or. regmm = "09" .or. regmm = "11"
         if regdd = "15" .or. regdd = "30"
            *
         else
            invsw = "1"
         endif
      else
         if regdd = "15"
            *
         else
            if regdd = "29"
               if mdate = "March"
                  invsw = "1"
               endif
            else
               if regdd = "28"
                  idate = ctod(regmm + "/" + regdd + "/" + regyy) + 1
                  idate = cmon(idate)
                  if idate = "March"
                     *
                  else
                     invsw = "1"
                  endif 
               else
                  invsw = "1"
               endif
            endif
         endif
      endif
   endif
   if invsw = "1"
      @ 24,00 clea
      @ 23,00 say ""
      wait "PAYROLL DATE IS OUT OF RANGE. Press any key to continue..."
      clear
      loop
   endif
   set cursor off
   exit
enddo
return 

****************************

Procedure ERRLINE
parameter mERROR
save screen to errscr
do case
   case mERROR = 1
        mFILE = &mastfile
        @ 24,00 clea
        @ 24,00 say &mFILE + ".DBF" + " not found. Aborting."
        inkey(5)
        quit
   case mERROR = 2
        mFILE = &mastfile
        @ 24,00 clea
        @ 24,00 say &mFILE + ".DBF" + " not found. Aborting."
        inkey(5)
        quit
   case mERROR = 3
        @ 24,00 clea
        @ 24,00 say "PTVTXTAB.DBF not found. Aborting."
        inkey(5)
        quit
   case mERROR = 4
        @ 24,00 clea
        @ 23,00 say ''
        wait "Employee No. does not exist."
        inkey(5)
        restore screen from errscr
        return
   case mERROR = 5
        @ 24,00 clea
        @ 23,00 say ''
        @ 24,00 say "Top of File encountered."
        inkey(5)
        restore screen from errscr
        return
   case mERROR = 6
        @ 24,00 clea
        @ 23,00 say ''
        @ 24,00 say "End of File encountered."
        inkey(5)
        restore screen from errscr
        return 
   case mERROR = 7
        @ 24,00 clea
        @ 23,00 say ''
        @ 24,00 say "Tax Status not found. Check file entry"
        inkey(5)
        restore screen from errscr
        return
endcase
       
*****************************

Procedure STARTUP

set talk off
set echo off
set confirm on
set status off
set wrap on
set func 2 to ''
set func 3 to ''
set func 4 to ''
set func 5 to ''
set func 6 to ''
set func 7 to ''
set func 8 to ''
set func 9 to ''
return

**************************

Procedure HEADING
@ 03,01 clear to 03,78
set colo to n/w
@ 03,40-len(msubsys)/2 say msubsys
set colo to
return

***************************

Procedure POPEYE

tone(294,1)
tone(274,1)
tone(294,1)
tone(0,1)
tone(150,1)
tone(0,1)
tone(220,1)
tone(193,1)
tone(187,1)
tone(220,1)
tone(294,1)
tone(0,1)
tone(294,1)
tone(0,1)

****************************

Procedure DIE

tone(150,2)
tone(150,2)
tone(150,1)
tone(150,2)
tone(180,2)
tone(168,1)
tone(168,2)
tone(150,1)
tone(150,2)
tone(143,1)
tone(150,2)

****************************

Procedure ET

tone(330,5)
tone(367,5)
tone(294,5)
tone(150,5)
tone(220,5)

*****************************

Procedure ESTATUS
parameter estat
do drawbox with 18,1,21,13,.f.

@ 19,2 prompt 'Regular    '
@ 20,2 prompt 'Contractual'
menu to x
if lastkey() = 27
   return
endif
do case 
   case x = 1
        estat = 'R'
   case x = 2
        estat = 'C'
endcase
return