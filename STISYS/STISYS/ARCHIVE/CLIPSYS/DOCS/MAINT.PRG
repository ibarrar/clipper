/**********************************************************/
/* Filename:      MAINT.PRG                               */
/* System-name:   Travel Requirements Information System. */
/* Module:        Database Maintenance                    */
/* Date-Started:  February 03, 1992                       */
/* Last-Update:   February 08, 1992                       */
/**********************************************************/

#include "Inkey.ch"
#include "Setcurs.ch"
#include "Directry.ch"

#define BACKUP_DRIVE "B:\"
#define DBF_PATH     "D:\VISADATA\"

function Reindex()
local wReindex,hGauge,aDirectory,cAlias,n,nFileCount:=nTotalSize:=nPercent:=0
   use DATABASE index DB_DBF new
   aDirectory:=Directory(DBF_PATH)
   for n:=1 to Len(aDirectory) ; nTotalSize+=aDirectory[n,F_SIZE] ; next
   Message("Reindexing databases....please wait!")
   wReindex:=OpenWindow(06,03,16,76,"Reindex Databases")
   hGauge:=GaugeNew(10,05,12,74,"N/W","N/W",chr(177))
   GaugeDisplay(hGauge)
   @ 09,05 say DBF_PATH
   for n:=1 to Len(aDirectory)
      DATABASE->(DbSeek(RTrim(aDirectory[n,F_NAME])))
      if DATABASE->(Found())
         cAlias:=SubStr(DATABASE->DBF_NAME,1,AT(".",DATABASE->DBF_NAME)-1)
         do while RTrim(DATABASE->DBF_NAME)==RTrim(aDirectory[n,F_NAME])
            nFileCount++
            @ 13,05 clear to 13,74
            @ 13,05 say aDirectory[n,F_NAME]
            @ 13,20 say Transform(aDirectory[n,F_SIZE],"9,999,999")+" bytes"
            @ 13,43 say Cmonth(aDirectory[n,F_DATE])+" "+;
              Transform(Day(aDirectory[n,F_DATE]),"99")+", "+;
              Transform(Year(aDirectory[n,F_DATE]),"9999")
            @ 14,05 clear to 14,74
            @ 14,05 say DATABASE->NTX_NAME
            use (DATABASE->DBF_NAME) new
            index on &(DATABASE->FIELD_NAME) to (DBF_PATH+DATABASE->NTX_NAME)
            &(cAlias)->(DbCloseArea())
            DATABASE->(DbSkip())
         enddo
      endif
      nPercent+=aDirectory[n,F_SIZE]/nTotalSize
      GaugeUpdate(hGauge,nPercent)
   next
   @ 13,05 clear to 14,74
   @ 13,05 say Transform(nFileCount,"99")+" index file(s) reindexed."
   Message("Press any key to return to Main Menu....")
   Inkey(0)
   DbCloseAll()
   CloseWindow(wReindex)
return nil

function Backup()
local wBackup,cColor,cAns:="N"
   SetCursor(SC_NORMAL)
   Message("Press Y to backup, N or Esc to abort.")
   wBackup:=OpenWindow(04,19,12,62,"System Databases Backup")
   @ 06,23 say "Please insert backup disk on drive B."
   @ 08,26 say "Do you wish to continue?" get cAns picture "Y"
   read
   Message("")
   if cAns=="Y"
      @ 10,24 say "Backing up files....please wait!"
      copy file VISA.DBF to &(BACKUP_DRIVE+"VISA.DBF")
      copy file VISA.DBT to &(BACKUP_DRIVE+"VISA.DBT")
      copy file VISA.NTX to &(BACKUP_DRIVE+"VISA.NTX")
      copy file PASSPORT.DBF to &(BACKUP_DRIVE+"PASSPORT.DBF")
      copy file PASSPORT.DBT to &(BACKUP_DRIVE+"PASSPORT.DBT")
      copy file PASSPORT.NTX to &(BACKUP_DRIVE+"PASSPORT.NTX")
      copy file OTHERS.DBF to &(BACKUP_DRIVE+"OTHERS.DBF")
      copy file OTHERS.DBT to &(BACKUP_DRIVE+"OTHERS.DBT")
      copy file OTHERS.NTX to &(BACKUP_DRIVE+"OTHERS.NTX")
      @ 10,24 say " Files are successfully copied. "
      Message("Press any key to return to main menu....")
      Inkey(0)
   endif
   CloseWindow(wBackup)
   SetCursor(SC_NONE)
return nil

function Restore()
local wRestore,cColor,cAns:="N"
   SetCursor(SC_NORMAL)
   Message("Press Y to restore, N or Esc to abort.")
   wRestore:=OpenWindow(04,19,12,62,"System Databases Restore")
   @ 06,23 say "Please insert backup disk on drive B."
   @ 08,26 say "Do you wish to continue?" get cAns picture "Y"
   read
   Message("")
   if cAns=="Y"
      @ 10,24 say "Restoring files....please wait!"
      copy file &(BACKUP_DRIVE+"VISA.DBF") to &(DBF_PATH+"VISA.DBF")
      copy file &(BACKUP_DRIVE+"VISA.DBT") to &(DBF_PATH+"VISA.DBT")
      copy file &(BACKUP_DRIVE+"VISA.NTX") to &(DBF_PATH+"VISA.NTX")
      copy file &(BACKUP_DRIVE+"PASSPORT.DBF") to &(DBF_PATH+"PASSPORT.DBF")
      copy file &(BACKUP_DRIVE+"PASSPORT.DBT") to &(DBF_PATH+"PASSPORT.DBT")
      copy file &(BACKUP_DRIVE+"PASSPORT.NTX") to &(DBF_PATH+"PASSPORT.NTX")
      copy file &(BACKUP_DRIVE+"OTHERS.DBF") to &(DBF_PATH+"OTHERS.DBF")
      copy file &(BACKUP_DRIVE+"OTHERS.DBT") to &(DBF_PATH+"OTHERS.DBT")
      copy file &(BACKUP_DRIVE+"OTHERS.NTX") to &(DBF_PATH+"OTHERS.NTX")
      @ 10,24 say " Files are successfully copied. "
      Message("Press any key to return to main menu....")
      Inkey(0)
   endif
   CloseWindow(wRestore)
   SetCursor(SC_NONE)
return nil

function EditRecord(cFile,cRecord)
local wEdit,cName
   use &(cFile) index &(cFile) new
   seek cRecord
   if cFile=="Visa" ; cName:=EMBASSY ; else ; cName:=OFFICE ; endif
   Message("Edit current record....")
   SetCursor(SC_NORMAL)
   wEdit:=OpenWindow(11,08,13,72,"")
   if cFile=="Visa"
      cName:=EMBASSY
      @ 12,10 say "Enter embassy name " get cName
   else
      cName:=OFFICE
      @ 12,10 say "Enter office name  " get cName
   endif
   read
   SetCursor(SC_NONE)
   CloseWindow(wEdit)
   if LastKey()!=K_ESC
      if cFile=="Visa"
         replace EMBASSY with cName
      else
         replace OFFICE with cName
      endif
   endif
   &(cFile)->(DbCloseArea())
return nil

function DeleteRecord(cFile,cRecord)
local wDelete,nKey:=0
   use &(cFile) index &(cFile) new
   seek cRecord
   wDelete:=OpenWindow(10,14,13,64,"")
   @ 11,40-(Len(cRecord)/2) say cRecord
   @ 12,15 say "is to deleted.  Press F5 to delete, Esc to abort."
   do while (nKey!=K_ESC) .and. (nKey!=K_F5)
      nKey:=Inkey(0)
   enddo
   if nKey==K_F5
      Message("Deleting "+cRecord+"....")
      delete
      pack
   endif
   CloseWindow(wDelete)
   &(cFile)->(DbCloseArea())
return nil

function ReadRecords(cFile)
local wRead,n,nTop,nLeft,nBottom,nRight,nLen:=0,aRecord:={}
   use &(cFile) index &(cFile) new
   do while !eof()
      if cFile=="Visa"
         AAdd(aRecord,EMBASSY)
         if nLen<Len(RTrim(EMBASSY))
            nLen:=Len(RTrim(EMBASSY))
         endif
      else
         AAdd(aRecord,OFFICE)
         if nLen<Len(RTrim(OFFICE))
            nLen:=Len(RTrim(OFFICE))
         endif
      endif
      skip
   enddo
   if Len(aRecord)=0 ; AAdd(aRecord,"No record found!") ; endif
   for n:=1 to Len(aRecord)
      aRecord[n]:=SubStr(aRecord[n],1,nLen)
   next
   &(cFile)->(DbCloseArea())
   nTop:=06 ; nLeft:=35
   nBottom:=nTop+1+Len(aRecord) ; nRight:=nLeft+1+nLen
   if nBottom>19 ; nBottom:=19 ; endif
   if nRight>77  ; nRight:=77  ; endif
   wRead:=OpenWindow(nTop,nLeft,nBottom,nRight,"")
   n:=AChoice(nTop+1,nLeft+1,nBottom-1,nRight-1,aRecord,,"HandleMenu",1,1)
   CloseWindow(wRead)
return if(LastKey()==K_ESC,nil,RTrim(aRecord[n]))

// end-of-file
