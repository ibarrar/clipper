// Filename:      MAINT.PRG
// Author:        Arnold P. Caoile
// Module:        Database Maintenance
// Date-Started:  April 23, 1992
// Last-Update:   June 23, 1992

#include "Inkey.ch"
#include "Setcurs.ch"
#include "Directry.ch"
#include "Error.ch"
#include "Janus.Ch"
#define   DATA_PATH   "D:\PSDATA\"

function CopyFile(nMode)
local wCopy,hGauge,aDirectory,cName,n,nFileCount:=nTotalSize:=nPercent:=0
local bSaveHandler,error,wError,nKey,wDirMask
   Message("Enter source & target drives, press ESC to abort.")
   if nMode==1
      cSource:=padr("E:\PSDATA\",40)
      cTarget:=padr("D:\PSDATA\",40)
      wDirMask:=OpenWindow(09,14,13,66,"Backup Databases")
   elseif nMode==2
      cSource:=padr("D:\PSDATA\",40)
      cTarget:=padr("E:\PSDATA\",40)
      wDirMask:=OpenWindow(09,14,13,66,"Restore Databases")
   endif
   SetCursor(SC_NORMAL)
   @ 11,16 say "Source Drive/Path" get cSource picture "@!"
   @ 12,16 say "Target Drive/Path" get cTarget picture "@!"
   read
   SetCursor(SC_NONE)
   CloseWindow(wDirMask)
   if LastKey()!=K_ESC
   cSource:=AllTrim(cSource) ; cTarget:=AllTrim(cTarget)
   bSaveHandler:=ErrorBlock({|x| Break(x)})
   aDirectory:=Directory(cSource+"*.*")
   for n:=1 to Len(aDirectory) ; nTotalSize+=aDirectory[n,F_SIZE] ; next
   Message("Copying databases....please wait!")
   if nMode==1
      wCopy:=OpenWindow(06,03,16,76,"Backup Databases")
   elseif nMode==2
      wCopy:=OpenWindow(06,03,16,76,"Restore Databases")
   endif
   hGauge:=GaugeNew(10,05,12,74,"N/W","N/W",chr(177))
   GaugeDisplay(hGauge)
   @ 09,05 say cSource
   for n:=1 to Len(aDirectory)
      nFileCount++
      cName:=aDirectory[n,F_NAME]
      @ 13,05 clear to 13,74
      @ 13,05 say cName
      @ 13,20 say Transform(aDirectory[n,F_SIZE],"9,999,999")+" bytes"
      @ 13,43 say Cmonth(aDirectory[n,F_DATE])+" "+;
        Transform(Day(aDirectory[n,F_DATE]),"99")+", "+;
        Transform(Year(aDirectory[n,F_DATE]),"9999")
      do while .T.
         BEGIN SEQUENCE
            copy file &(cSource+cName) to &(cTarget+cName)
         RECOVER USING error
            if error:genCode==EG_CREATE
               Message("Press "+chr(17)+chr(196)+chr(217)+ ;
                  " to retry, Esc to abort....")
               Tone(100,3)
               wError:=OpenWindow(08,12,14,67,"Runtime Error")
               @ 10,14 say "                      WARNING!                      "
               @ 11,14 say "   File creation error, unable to write to disk.    "
               @ 12,14 say "Please check drive or disk.  Drive may not be ready,"
               @ 13,14 say "        disk maybe full or write-protected.         "
               nKey:=0
               do while (nKey!=K_ENTER) .and. (nKey!=K_ESC)
                  nKey:=Inkey(0)
               enddo
               CloseWindow(wError)
               if nKey==K_ENTER
                  Message("Copying databases....please wait!")
                  loop
               elseif nKey==K_ESC
                  CloseWindow(wCopy)
                  return nil
               endif
            endif
         END
         exit
      enddo
      ErrorBlock(bSaveHandler)
      nPercent+=aDirectory[n,F_SIZE]/nTotalSize
      GaugeUpdate(hGauge,nPercent)
   next
   @ 13,05 clear to 13,74
   @ 13,05 say Transform(nFileCount,"99")+" file(s) copied."
   Message("Press any key to return to Main Menu....")
   Inkey(0)
   CloseWindow(wCopy)
   endif
return nil

function ReIndexIt()
local wScreen, aChoices := afill(array(7),.F.)
     wScreen := OpenWindow(08,15,17,65,"Reindex")
     @ 10,     28 say "Employee Master File" get aChoices[1] pict "Y"
     @ row()+1,28 say "   Daily Time Record" get aChoices[2] pict "Y"
     @ row()+1,28 say "        Wage History" get aChoices[3] pict "Y"
     @ row()+1,28 say "           Wage File" get aChoices[4] pict "Y"
     @ row()+1,28 say " Accounts Receivable" get aChoices[5] pict "Y"
     @ row()+1,28 say "     SSS Loan Grants" get aChoices[6] pict "Y"
     @ row()+1,28 say "        Holiday File" get aChoices[7] pict "Y"
     Message("Choose file(s) to reindex...")
     setcursor(SC_NORMAL)
     read
     setcursor(SC_NONE)
     if lastkey() # K_ESC
        if aChoices[1]
           Message("Reindexing Master File...")
           DbMakeIndex("PAYMAST",DATA_PATH + "PAYMAST", "upper(emp_name)")
           DbMakeIndex("PAYMAST",DATA_PATH + "PAYSLOT", "emp_slot")
        endif
        if aChoices[2]
           Message("Reindexing Time Records...")
           DbMakeIndex("PAYTRANS",DATA_PATH + "PAYTRANS", "rec_no")
           DbMakeIndex("PAYTRANS",DATA_PATH + "PAYDATE", "tr_date")
        endif
        if aChoices[3]
           Message("Reindexing Wage History...")
           DbMakeIndex("HISTORY",DATA_PATH + "HISTORY", "rec_no")
        endif
        if aChoices[4]
           Message("Reindexing Wage File...")
           DbMakeIndex("WAGE",DATA_PATH + "WAGE", "rec_no")
        endif
        if aChoices[5]
           Message("Reindexing Accounts Receivables..")
           DbMakeIndex("ACCRCV",DATA_PATH + "ACCRCV", "rec_no")
        endif
        if aChoices[6]
           Message("Reindexing SSS Loan Grants...")
           DbMakeIndex("LOAN",DATA_PATH + "LOAN", "rec_no")
        endif
        if aChoices[7]
           Message("Reindexing Holiday File...")
           DbMakeIndex("HOLIDAY",DATA_PATH + "HOLIDAY", "hd_date")
        endif
     endif
     CloseWindow(wScreen)
return nil

static function DbMakeIndex(cDbfFile,cIndexFile,cIndexExp)
    use (cDbfFile) exclusive new
    if !neterr()
       index on &cIndexExp to &cIndexFile
       return .t.
       (cDbfFile)->(DbCloseArea())
    endif
return .f.

// end-of-file