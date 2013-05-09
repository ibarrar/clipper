set echo off
set talk off
use slot
sele 2
use paytrans
do while .not. eof()
   sele 1
   locate for slot->slot_no = paytrans->tr_slot
   if found()
      replace paytrans->rec_no with slot->rec_no
   endif
   sele 2
   skip
enddo
close all
set talk on
set echo on

