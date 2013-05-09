/***********************************************************/
/* Filename:      DOCS.PRG                                 */
/* System-name:   Travel Requirements Information System.  */
/* Module:        Main Menu                                */
/* Author:        Rollie C. Ibarra Jr.                     */
/* Date-Started:  May  31, 1993                            */
/* Last-Update:   June 25, 1993                            */
/***********************************************************/

#include "Inkey.ch"
#include "Achoice.ch"
#include "Setcurs.ch"

#define DATA_COLORS     "N/W,N/BG"
#define ENTER_CHAR      chr(17)+chr(196)+chr(217)
#define LEFT_RIGHT      chr(27)+chr(26)
#define UP_DOWN         chr(24)+chr(25)
#define ARROW_KEYS      chr(27)+chr(24)+chr(25)+chr(26)
#define DBF_PATH       "D:\VISADATA\"
#define VISA_OPTION     1
#define PPT_OPTION      2
#define OTHER_OPTION    3
#define MAINT_OPTION	   4
#define QUIT_OPTION     5
#define VISA_MODE       1
#define PPT_MODE        2
#define OTHER_MODE      3
#define EDIT_OPTION     1
#define DELETE_OPTION   2
#define BACKUP_OPTION   3
#define RESTORE_OPTION  4
#define REINDEX_OPTION  5

function VisaReqmts()
local wVisa,wSubMenu,wAdd,wMaint,wFiles,cColor,nChoice,nLen,exitRequested:=.F.
local aVisa,aPassport,aOthers,aMaint,aFiles,n,n2,cRecord,cName:=space(40)
local nRow
   Set(_SET_SCOREBOARD,.F.)
   Set(_SET_WRAP,.T.)
   Set(_SET_MESSAGE,24)
   Set(_SET_PATH,DBF_PATH)
   wVisa:=BkgndScreen()
   SetCursor(SC_NONE)
   Header("Travel Requirements Information System")
   cColor:=SetColor(DATA_COLORS)
   do while !exitRequested
      Message("Use "+LEFT_RIGHT+" to move highlight, press "+;
              ENTER_CHAR+" to select.")
      @ 01,05 prompt "Visa"
      @ 01,Col()+3 prompt "Passport"
      @ 01,Col()+3 prompt "Others"
      @ 01,Col()+3 prompt "Maint"
      @ 01,Col()+3 prompt "Quit"
      menu to nChoice
      do case
         case nChoice==VISA_OPTION
            aVisa:={}; nLen:=16
            use VISA index VISA new
            do while !eof()
               AAdd(aVisa,VISA->EMBASSY)
               if nLen<Len(RTrim(VISA->EMBASSY))
                  nLen:=Len(RTrim(VISA->EMBASSY))
               endif
               skip
            enddo
            AAdd(aVisa,"<Add new record>")
            for n:=1 to Len(aVisa)
               aVisa[n]:=SubStr(aVisa[n],1,nLen)
            next
            nRow:=3+Len(aVisa)
            if nRow>21 ; nRow:=21 ; endif
            Message("Use "+UP_DOWN+" to move highlight, "+;
                    "press "+ENTER_CHAR+" to select, Esc to abort.")
            wSubMenu:=OpenWindow(2,3,nRow,4+nLen,"")
            n:=AChoice(3,4,nRow-1,(4+nLen)-1,aVisa,,"HandleMenu",1,1)
            CloseWindow(wSubMenu)
            if (LastKey()!=K_ESC) .and. (LastKey()!=K_LEFT) .and. ;
               (LastKey()!=K_RIGHT)
               if AllTrim(aVisa[n])=="<Add new record>"
                  cName:=space(40)
                  Message("Add a new Visa requirement record....")
                  SetCursor(SC_NORMAL)
                  wAdd:=OpenWindow(11,08,13,72,"")
                  @ 12,10 say "Enter embassy name" get cName
                  read
                  SetCursor(SC_NONE)
                  CloseWindow(wAdd)
                  if LastKey()!=K_ESC
                     VISA->(DbAppend())
                     replace VISA->EMBASSY with cName
                     VISA->(DbSeek(RTrim(cName)))
                     Editor(VISA_MODE)
                  endif
               else
                  VISA->(DbSeek(RTrim(aVisa[n])))
                  Editor(VISA_MODE)
               endif
            endif
            VISA->(DbCloseArea())
         case nChoice==PPT_OPTION
            aPassport:={}; nLen:=16
            use PASSPORT index PASSPORT new
            do while !eof()
               AAdd(aPassport,PASSPORT->OFFICE)
               if nLen<Len(RTrim(PASSPORT->OFFICE))
                  nLen:=Len(RTrim(PASSPORT->OFFICE))
               endif
               skip
            enddo
            AAdd(aPassport,"<Add new record>")
            for n:=1 to Len(aPassport)
               aPassport[n]:=SubStr(aPassport[n],1,nLen)
            next
            nRow:=3+Len(aPassport)
            if nRow>21 ; nRow:=21 ; endif
            Message("Use "+UP_DOWN+" to move highlight, "+;
                    "press "+ENTER_CHAR+" to select, Esc to abort.")
            wSubMenu:=OpenWindow(2,9,nRow,10+nLen,"")
            n:=AChoice(3,10,nRow-1,(10+nLen)-1,aPassport,,"HandleMenu",1,1)
            CloseWindow(wSubMenu)
            if (LastKey()!=K_ESC) .and. (LastKey()!=K_LEFT) .and. ;
               (LastKey()!=K_RIGHT)
               if AllTrim(aPassport[n])=="<Add new record>"
                  cName:=space(40)
                  Message("Add a new Passport requirement record....")
                  wAdd:=OpenWindow(11,08,13,72,"")
                  SetCursor(SC_NORMAL)
                  @ 12,10 say "Enter office name " get cName
                  read
                  SetCursor(SC_NONE)
                  CloseWindow(wAdd)
                  if LastKey()!=K_ESC
                  PASSPORT->(DbAppend())
                     replace PASSPORT->OFFICE with cName
                     PASSPORT->(DbSeek(RTrim(cName)))
                     Editor(PPT_MODE)
                  endif
               else
                  PASSPORT->(DbSeek(RTrim(aPassport[n])))
                  Editor(PPT_MODE)
               endif
            endif
            PASSPORT->(DbCloseArea())
         case nChoice==OTHER_OPTION
            aOthers:={}; nLen:=16
            use OTHERS index OTHERS new
            do while !eof()
               AAdd(aOthers,OTHERS->OFFICE)
               if nLen<Len(RTrim(OTHERS->OFFICE))
                  nLen:=Len(OTHERS->OFFICE)
               endif
               skip
            enddo
            AAdd(aOthers,"<Add new record>")
            for n:=1 to Len(aOthers)
               aOthers[n]:=SubStr(aOthers[n],1,nLen)
            next
            nRow:=3+Len(aOthers)
            if nRow>21 ; nRow:=21 ; endif
            Message("Use "+UP_DOWN+" to move highlight, "+;
                    "press "+ENTER_CHAR+" to select, Esc to abort.")
            wSubMenu:=OpenWindow(2,20,nRow,21+nLen,"")
            n:=AChoice(3,21,nRow-1,(21+nLen)-1,aOthers,,"HandleMenu",1,1)
            CloseWindow(wSubMenu)
            if (LastKey()!=K_ESC) .and. (LastKey()!=K_LEFT) .and. ;
               (LastKey()!=K_RIGHT)
               if AllTrim(aOthers[n])=="<Add new record>"
                  cName:=space(40)
                  Message("Add a new requirement record....")
                  SetCursor(SC_NORMAL)
                  wAdd:=OpenWindow(11,08,13,72,"")
                  @ 12,10 say "Enter office name " get cName
                  read
                  SetCursor(SC_NONE)
                  CloseWindow(wAdd)
                  if LastKey()!=K_ESC
                     OTHERS->(DbAppend())
                     replace OTHERS->OFFICE with cName
                     OTHERS->(DbSeek(RTrim(cName)))
                     Editor(OTHER_MODE)
                  endif
               else
                  OTHERS->(DbSeek(RTrim(aOthers[n])))
                  Editor(OTHER_MODE)
               endif
            endif
            OTHERS->(DbCloseArea())
         case nChoice==MAINT_OPTION
            aMaint:={} ; cRecord:=""
            AAdd(aMaint," Edit a record.   ")
            AAdd(aMaint," Delete a record. ")
            AAdd(aMaint," Backup to disk.  ")
            AAdd(aMaint,"Restore from disk.")
            AAdd(aMaint,"Reindex databases.")
            wMaint:=OpenWindow(02,30,08,49,"")
            n:=AChoice(03,31,07,48,aMaint,,"HandleMenu",1,1)
            if ((n==EDIT_OPTION) .or. (n==DELETE_OPTION)) .and. ;
               (LastKey()!=K_ESC)
               aFiles:={"Visa","Passport","Others"}
               wFiles:=OpenWindow(03+n,23,07+n,33,"")
               n2:=AChoice(04+n,24,06+n,32,aFiles,,"HandleMenu",1,1)
               if LastKey()!=K_ESC
                  cRecord:=ReadRecords(aFiles[n2])
               endif
               CloseWindow(wFiles)
            endif
            CloseWindow(wMaint)
            if (LastKey()!=K_ESC) .and. (LastKey()!=K_LEFT) .and. ;
               (LastKey()!=K_RIGHT) .and. (RTrim(cRecord)!="No record found!")
               do case
                  case n==EDIT_OPTION
                     EditRecord(aFiles[n2],cRecord)
                  case n==DELETE_OPTION
                     DeleteRecord(aFiles[n2],cRecord)
                  case n==REINDEX_OPTION
                     Reindex()
                  case n==BACKUP_OPTION
                     Backup()
                  case n==RESTORE_OPTION
                     Restore()
               endcase
            endif
      case nChoice==QUIT_OPTION
            exitRequested:=.T.
      endcase
   enddo
   RestoreScreen(wVisa)
   SetCursor(SC_NORMAL)
   Set(_SET_WRAP,.F.)
   Set(_SET_SCOREBOARD,.T.)
   SetColor(cColor)
return nil

function HandleMenu(nMode)
local nRetVal,nKey
   do case
      case nMode==AC_EXCEPT
         nKey:=LastKey()
         do case
            case nKey==K_ESC
               nRetVal:=AC_ABORT
            case nKey==K_ENTER
               nRetVal:=AC_SELECT
            otherwise
               nRetVal:=AC_CONT
         endcase
      otherwise
         nRetVal:=AC_CONT
   endcase
return nRetVal

// end-of-file
