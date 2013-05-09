set echo off
set talk off
use paymast
sele 2
use paytrans
do while .not. eof()
   ? "Searching Rec#",recno(),",  Slot #",paytrans->tr_slot,"..."
   sele 1
   locate for paymast->emp_slot = paytrans->tr_slot
   if found()
      ?? "found..."
      replace paytrans->rec_no with recno()
   else
      ?? "skipped..."
   endif
   sele 2
   skip
enddo
close all
set talk on
set echo on

