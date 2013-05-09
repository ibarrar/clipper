// Filename:      MAINT.PRG
// Author:        Arnold P. Caoile
// Module:        Database Maintenance
// Date-Started:  April 23, 1992
// Last-Update:   June 23, 1992

#include "Inkey.ch"
#include "Setcurs.ch"
#include "Directry.ch"
#include "Error.ch"
#include "Mode.ch"
#define   DATA_PATH   "D:\GLDATA\"

function Reindex()
local wReindex,hGauge,cAlias,n:=nFileCount:=nPercent:=0
   NetUse("DATABASE",DB_SHARED,NUM_SECONDS)
   set index to DB_DBF
   nFileCount:=DATABASE->(LastRec())
   Message("Reindexing databases....please wait!")
   wReindex:=OpenWindow(06,03,16,76,"Reindex Databases")
   hGauge:=GaugeNew(10,05,12,74,"N/W","N/W",chr(177))
   GaugeDisplay(hGauge)
   do while DATABASE->(!EOF())
         @ 13,05 clear to 14,74
         @ 13,05 say "Reindexing "+rtrim(DATABASE->DBF_NAME)+" to "+;
                     rtrim(DATABASE->NTX_NAME)
         @ 14,05 say "using "+rtrim(DATABASE->NTX_KEY)+"..."
         if (DATABASE->DBF_NAME <> SPACE(25)) .and. ;
            (DATABASE->NTX_NAME <> SPACE(25)) .and. ;
            (DATABASE->NTX_KEY <> SPACE(45))
            cAlias:=rtrim(DATABASE->DBF_NAME)
            cExp:=rtrim(DATABASE->NTX_KEY)
            do while at('\',cAlias) <> 0
                cAlias:=substr(cAlias,at('\',cAlias)+1)
            enddo
            cAlias:=SubStr(cAlias,1,at(".",cAlias)-1)
            if NetUse(DATA_PATH+DATABASE->DBF_NAME,DB_SHARED,NUM_SECONDS)
                index on &(cExp) to (DATA_PATH+DATABASE->NTX_NAME)
            endif
            &(cAlias)->(DbCloseArea())
         endif
         DATABASE->(DbSkip())
         n++ ; nPercent=n/nFileCount
         GaugeUpdate(hGauge,nPercent)
   enddo
   @ 13,05 clear to 14,74
   @ 13,05 say Transform(nFileCount,"99")+" index file(s) reindexed."
   Message("Press any key to return to Main Menu....")
   Inkey(0)
   DbCloseAll()
   CloseWindow(wReindex)
return nil

function CopyFile(nMode)
local wCopy,hGauge,aDirectory,cName,n,nFileCount:=nTotalSize:=nPercent:=0
local bSaveHandler,error,wError,nKey,wDirMask
   Message("Enter source & target drives, press ESC to abort.")
   if nMode==1
      cSource:="E:\GLDATA\"+Space(20)
      cTarget:="D:\GLDATA\"+Space(20)
      wDirMask:=OpenWindow(09,14,13,66,"Backup Databases")
   elseif nMode==2
      cSource:="D:\GLDATA\"+Space(20)
      cTarget:="E:\GLDATA\"+Space(20)
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

// end-of-file