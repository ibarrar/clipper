/************************************************/
/* Filename:      MAINT.PRG                     */
/* System-name:   Purchase Order Filing Program */
/* Module:        Database Maintenance          */
/* Author:        Arnold P. Caoile              */
/* Date-Started:  February 20, 1992             */
/* Last-Update:   February 24, 1992             */
/************************************************/

#include "Inkey.ch"
#include "Setcurs.ch"

#define BACKUP_DRIVE "B:\"
#define DBF_PATH     "D:\PODATA\"

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
      copy file PO.DBF to &(BACKUP_DRIVE+"PO.DBF")
      copy file PO.NTX to &(BACKUP_DRIVE+"PO.NTX")
      copy file AGENT.NTX to &(BACKUP_DRIVE+"AGENT.NTX")
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
      copy file &(BACKUP_DRIVE+"PO.DBF") to &(DBF_PATH+"PO.DBF")
      copy file &(BACKUP_DRIVE+"PO.NTX") to &(DBF_PATH+"PO.NTX")
      copy file &(BACKUP_DRIVE+"AGENT.NTX") to &(DBF_PATH+"AGENT.NTX")
      @ 10,24 say " Files are successfully copied. "
      Message("Press any key to return to main menu....")
      Inkey(0)
   endif
   CloseWindow(wRestore)
   SetCursor(SC_NONE)
return nil

// end-of-file
