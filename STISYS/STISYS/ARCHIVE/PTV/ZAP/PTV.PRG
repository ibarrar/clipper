*********************************************
*                                           * 
* Program: Main Menu                        *
* Author : Alex Castro                      *
* Date   : August 15, 1993                  *
* Remarks: This program is made for use of  *
*          People's Television Network, Inc.*
*          using Clipper Summer '87         *
*********************************************
save screen to before
clear
set wrap on
set conf on
do startup
do getpass
do paydate_val
do getfile
set escape off
set cursor off
do popeye
*set key -9 to mread

mowner =   '        PTV-4         '
msystem =  '    PAYROLL SYSTEM    '
clos databases
clear
disk = diskspace()
mem = memory(0)
set colo to ,w,

ABOX = chr(218) + chr(196) + chr(191) + chr(179) + chr(181) + chr(205);
       + chr(198) + chr(179)
@ 01,00,04,79 box ABOX
*@ 02,01 say repl(chr(176),78)
*@ 03,01 say repl(chr(176),78)
@ 02,24 say "People's Television Network, Inc."
@ 03,24 say "         Payroll System          " 
set colo to
if isprinter()                                           
   printer = "ON LINE"                                   
else                                                     
   printer = "OFF LINE"                                  
endif                                                    
tdate = date()                                           
@ 22,01 say repl(chr(205),79)                            
@ 23,48 say "Printer: "                                  
@ 23,57 say printer                                      
@ 23,01 say "Date today: "                               
@ 23,15 say cmonth(tdate) + " " + str(day(tdate),2,0);   
            + ", " + str(year(tdate),4,0)                
@ 24,01 say "Payroll date: "                             
@ 23,47 say 'Available Memory: '                         
@ 24,47 say "Bytes Available : "                         
@ 23,65 say mem                                          
@ 24,65 say disk pict "99999999"                         
@ 24,74 say "Bytes"                                      
do whil .t.
   set escape off
   do boxing

   @ 05,01 prompt "  1. File Maintenance   "
   @ 05,26 prompt "  2. Compute   "
   @ 05,42 prompt "  3. Utilities    "
   @ 05,61 prompt "  4. System       "
   menu to SELECT

*** declare arrays ****

   declare sub1[5]  

   sub1[1] = "    Master file         "
   sub1[2] = "    Transaction File    "
   sub1[3] = "    GSIS Salary Loan    "
   sub1[4] = "    Tax Table           "
   sub1[5] = "    Div. Table          "

   declare sub2[1]
   sub2[1] = "   Payroll    "

   declare sub3[3]
   sub3[1] = "     Print        "
   sub3[2] = "     Index        "
   sub3[3] = "     Backup       "

   declare sub4[2]
   sub4[1] = "   System Info   "
   sub4[2] = "   Exit to DOS   "
  
**** make choices visible ****

   do case
      @ 24,00 say ""
      case SELECT = 1
           ABOX = chr(198) + chr(205) + chr(216) + chr(179) + chr(217);
                  + chr(196) + chr(192) + chr(179)
           @ 06,00,14,25 box ABOX
           subchoice = achoice(8,1,13,24,sub1)
           do boxing
           do case
              case subCHOICE = 1
                   save screen to mainscr 
                   do ptvmas
                   restore screen from mainscr
              case subCHOICE = 2
                   save screen to mainscr
                   do tran 
                   if lastkey() <> 27
                      do ptvtran
                   endif
                   restore screen from mainscr
              case subCHOICE = 3
                   save screen to mainscr 
                   do ptvgsis
                   restore screen from mainscr
              case subCHOICE = 4
                   save screen to mainscr
                   do ptvtax
                   restore screen from mainscr
              case subCHOICE = 5
*                  do ptvdiv
           endcase
           @ 07,00 clea to 21,79
      case SELECT = 2
           ABOX = chr(216) + chr(205) + chr(216) + chr(179) + chr(217);
                  + chr(196) + chr(192) + chr(179)
           @ 06,25,10,41 box ABOX
           subchoice = achoice(8,26,10,40,sub2)
           do case
              case subCHOICE = 1
                   save screen to mainscr
                   do ptvcom
                   restore screen from mainscr
           endcase
           @ 07,00 clea to 21,79
      case SELECT = 3
           ABOX = chr(216) + chr(205) + chr(216) + chr(179) + chr(217);
                  + chr(196) + chr(192) + chr(179)
           @ 06,41,12,60 box ABOX
*          subchoice = achoice(9,42,12,59,sub3) 
           subchoice = achoice(8,42,12,59,sub3) 
           do case
              case subCHOICE = 1
                   save screen to mainscr
                   do ptvprn
                   restore screen from mainscr
              case subCHOICE = 2
*                  do index
              case subCHOICE = 3
*                  do backup
           endcase
           @ 07,00 clea to 21,79
      case SELECT = 4
           ABOX = chr(216) + chr(205) + chr(181) + chr(179) + chr(217);
                  + chr(196) + chr(192) + chr(179)
           @ 06,60,11,79 box ABOX
           subchoice = achoice(8,61,11,78,sub4)
           if subCHOICE = 1
              *
           endif
           if subCHOICE = 2
              do die
              clear
              set cursor on
              @ 24,00 say ''
              restore screen from before
              return
           endif
           @ 07,00 clea to 21,79
   endcase

**** I can see it now, what's next ****

   do case
      case lastkey() = 4 .and. select <> 4
           keyboard chr(4) + chr(13)
      case lastkey() = 19 .and. select <> 1
           keyboard chr(19) + chr(13)
      case lastkey() = 4 .and. select = 4
           keyboard chr(4) + chr(13)
      case lastkey() = 19 .and. select = 1
           keyboard chr(19) + chr(13)
   endcase
enddo
*** eof PTV ***

procedure mread
file = 'ptv_rep.txt'
memoedit(memoread(file),2,2,22,78,.f.,'',80)