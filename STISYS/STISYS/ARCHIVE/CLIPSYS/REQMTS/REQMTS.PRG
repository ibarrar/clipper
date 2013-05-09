/****************************************************************************/
/* Filename:      VISA.PRG                                                  */
/* System-name:   Visa Requirements Information System (Accounting Version) */
/* Module:        Main Menu                                                 */
/* Author:        Rolando C. Ibarra Jr.                                     */
/* Date-Started:  January  31, 1992                                         */
/* Last-Update:   February 13, 1992                                         */
/****************************************************************************/

#include "Inkey.ch"
#include "Achoice.ch"
#include "Setcurs.ch"

#define DATA_COLORS     "N/W,N/BG"
#define ENTER_CHAR      chr(17)+chr(196)+chr(217)
#define ARROW_KEYS      chr(27)+chr(24)+chr(25)+chr(26)
#define DBF_PATH       "D:\VISADATA\"
#define VISA_OPTION     1
#define PPT_OPTION      2
#define OTHER_OPTION    3
#define QUIT_OPTION     4
#define VISA_MODE       1
#define PPT_MODE        2
#define OTHER_MODE      3
#define EDIT_OPTION     1
#define DELETE_OPTION   2
#define BACKUP_OPTION   3
#define RESTORE_OPTION  4

function VisaReqmts()
local wVisa,wSubMenu,wAdd,wMaint,wFiles,cColor,nChoice,nLen,exitRequested:=.F.
local aVisa,aPassport,aOthers,aMaint,aFiles,n,n2,cRecord,cName:=space(40)
   Set(_SET_SCOREBOARD,.F.)
   Set(_SET_WRAP,.T.)
   Set(_SET_MESSAGE,24)
   Set(_SET_PATH,DBF_PATH)
   wVisa:=BkgndScreen()
   SetCursor(SC_NONE)
   Header("Visa Requirements Information System (Accounting Version)")
   cColor:=SetColor(DATA_COLORS)
   do while !exitRequested
      Message("Use "+ARROW_KEYS+" to move highlight, press "+;
              ENTER_CHAR+" to select.")
      @ 01,05 prompt "Visa"
      @ 01,Col()+3 prompt "Passport"
      @ 01,Col()+3 prompt "Others"
      @ 01,Col()+3 prompt "Quit"
      menu to nChoice
      do case
         case nChoice==VISA_OPTION
            aVisa:={}	; nLen:=0
            use VISA index VISA new
            do while !eof()
               AAdd(aVisa,VISA->EMBASSY)
               if nLen<Len(RTrim(VISA->EMBASSY))
                  nLen:=Len(RTrim(VISA->EMBASSY))
               endif
               skip
            enddo
            for n:=1 to Len(aVisa)
               aVisa[n]:=SubStr(aVisa[n],1,nLen)
            next
            Message("Use "+ARROW_KEYS+" to move highlight, "+;
                    "press "+ENTER_CHAR+" to select.")
            wSubMenu:=OpenWindow(2,3,3+Len(aVisa),4+nLen,"")
            n:=AChoice(3,4,(3+Len(aVisa))-1,(4+nLen)-1,aVisa,.T.,;
               "HandleMenu",1,1)
            CloseWindow(wSubMenu)
            if (LastKey()!=K_ESC) .and. (LastKey()!=K_LEFT) .and. ;
               (LastKey()!=K_RIGHT)
               VISA->(DbSeek(RTrim(aVisa[n])))
               Editor(VISA_MODE)
            endif
            VISA->(DbCloseArea())
         case nChoice==PPT_OPTION
            aPassport:={}	; nLen:=0
            use PASSPORT index PASSPORT new
            do while !eof()
               AAdd(aPassport,PASSPORT->OFFICE)
               if nLen<Len(RTrim(PASSPORT->OFFICE))
                  nLen:=Len(RTrim(PASSPORT->OFFICE))
               endif
               skip
            enddo
            for n:=1 to Len(aPassport)
               aPassport[n]:=SubStr(aPassport[n],1,nLen)
            next
            Message("Use "+ARROW_KEYS+" to move highlight, "+;
                    "press "+ENTER_CHAR+" to select.")
            wSubMenu:=OpenWindow(2,9,3+Len(aPassport),10+nLen,"")
            n:=AChoice(3,10,(3+Len(aPassport))-1,(10+nLen)-1,aPassport,.T.,;
               "HandleMenu",1,1)
            CloseWindow(wSubMenu)
            if (LastKey()!=K_ESC) .and. (LastKey()!=K_LEFT) .and. ;
               (LastKey()!=K_RIGHT)
               PASSPORT->(DbSeek(RTrim(aPassport[n])))
               Editor(PPT_MODE)
            endif
            PASSPORT->(DbCloseArea())
         case nChoice==OTHER_OPTION
            aOthers:={}	; nLen:=0
            use OTHERS index OTHERS new
            do while !eof()
               AAdd(aOthers,OTHERS->OFFICE)
               if nLen<Len(RTrim(OTHERS->OFFICE))
                  nLen:=Len(OTHERS->OFFICE)
               endif
               skip
            enddo
            for n:=1 to Len(aOthers)
               aOthers[n]:=SubStr(aOthers[n],1,nLen)
            next
            Message("Use "+ARROW_KEYS+" to move highlight, "+;
                    "press "+ENTER_CHAR+" to select.")
            wSubMenu:=OpenWindow(2,20,3+Len(aOthers),21+nLen,"")
            n:=AChoice(3,21,(3+Len(aOthers))-1,(21+nLen)-1,aOthers,.T.,;
               "HandleMenu",1,1)
            CloseWindow(wSubMenu)
            if (LastKey()!=K_ESC) .and. (LastKey()!=K_LEFT) .and. ;
               (LastKey()!=K_RIGHT)
               OTHERS->(DbSeek(RTrim(aOthers[n])))
               Editor(OTHER_MODE)
            endif
            OTHERS->(DbCloseArea())
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
            case (nKey==K_LEFT) .or. (nKey==K_RIGHT)
               nRetVal:=AC_ABORT
            otherwise
               nRetVal:=AC_CONT
         endcase
      otherwise
         nRetVal:=AC_CONT
   endcase
return nRetVal

// end-of-file
