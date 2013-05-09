#include "Inkey.ch"
#include "Setcurs.ch"
#include "Directry.ch"
#include "Error.ch"
#include "ITS.ch"
#include "Janus.ch"

#define DOWN_PATH  chr(65+curdrv())+":\"+curdir()+"\"   

function Redownload()

local wValid,dDate:=date(),aFiles:={},i,Getlist:={},cDate,ndate,cpath

    wValid := OpenWindow(09,12,14,66,"Re-Download Box")
    @ 10,12 to 14,66 double    
      @ 12,17 say "Enter Date to Re-Download" get dDate
      SetCursor(SC_NORMAL)
      HeyThere()
      read
      SetCursor(SC_NONE)
    CloseWindow(wValid)

if lastkey()==K_ESC
 return nil
endif
//message(curdir())
//inkey(0)
   cDate:=subs(cmonth(dDate),1,3)+alltrim(str(day(dDate)))
   cpath:=chr(65+curdrv())+":\"+curdir()
   if l_chdir("BACKUP\"+cDate+"\")!=0   
      Message("Directory does not exists. Download Files")
      inkey(0)
   else
      aFiles:=directory("*.dbf")
      for i:=1 to len(aFiles)
 copy file (cpath+"\backup\"+cDate+"\"+aFiles[i][F_NAME]) to (cpath+"\download\"+aFiles[i][F_NAME])
         message(aFiles[i][F_NAME])
      next i
      l_chdir("..")
      l_chdir("..")
      
//     message(curdir())
//     inkey(0)
   endif
   
return nil   





          