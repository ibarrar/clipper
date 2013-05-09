// Filename:      MEMOS.PRG
// System-Name:   Bank Settlement Plan System
// Module:        File Handling Module for MEMO file
// Author:        Rollie C. Ibarra
// Date-Started:  August 17, 1993
// Last-Update:   August 25, 1993

#include "Inkey.ch"
#include "Achoice.ch"
#include "Setcurs.ch"
#include "Mode.Ch"
#include "c501_mod.ch"

#define MEMO_BAR   "F1-Help  F2-Add  F3-Edit  F4-Delete  F7-Airline  F8-Folio  Esc-Abort"
static mDate, mAirCode, mFolio, mAPeso, mADollar, mAirline

function Memo()
local  nKey:=0 ,wMemo
   MEMO->(DbGotop())
   wMemo := OpenWindow(05,15,12,64,"Airline Memos")
   if RecCount()==0 ; MemoScreen(APPEND_MODE) ; endif
   if LastKey()!=K_ESC
      do while (nKey!=K_ESC)
         MemoScreen(VIEW_MODE)
         nKey:=inKey(0)
         do case
            case nKey==K_DOWN
               MEMO->(DbSkip())
               if Eof()
                  MEMO->(DbGoBottom())
                  Tone(200,1)
                  Message("End of file reached....")
                  Inkey(1)
               endif
            case nKey==K_UP
               MEMO->(DbSkip(-1))
               if MEMO->(Bof())
                  MEMO->(DbGoTop())
                  Tone(200,1)
                  Message("Beginning of file reached....")
                  Inkey(1)
               endif
            case nKey==K_CTRL_PGDN
               MEMO->(DbSkip(NUM_TO_SKIP))
               if MEMO->(Eof())
                  MEMO->(DbGoBottom())
                  Tone(200,1)
                  Message("End of file reached....")
                  Inkey(1)
               endif
            case nKey==K_CTRL_PGUP
               MEMO->(DbSkip(-NUM_TO_SKIP))
               if MEMO->(Bof())
                  MEMO->(DbGoTop())
                  Tone(200,1)
                  Message("Beginning of file reached....")
                  Inkey(1)
               endif
            case nKey==K_END
                MEMO->(DbGoBottom())
                Message("Moving to end of file....")
                Inkey(1)
            case nKey==K_HOME
                MEMO->(DbGoTop())
                Message("Moving to beginning of file....")
                Inkey(1)
            case nKey==K_F1
                More_Keys()
            case nKey==K_F2
                Message("Press ENTER to Add, ESC to abort.")
                if Inkey(0)==K_ENTER
                   MemoScreen(APPEND_MODE)
                endif
            case nKey==K_F3
                Message("Press ENTER to Edit, ESC to abort.")
                if Inkey(0)==K_ENTER
                   MemoScreen(EDIT_MODE)
                endif
            case nKey==K_F4
                Message("Press ENTER to Delete, ESC to abort.")
                if Inkey(0)==K_ENTER
                    MEMO->(FilLock(0))
                    MEMO->(DbDelete())
                    MEMO->(DbUnlock())
                endif
            case nKey==K_F5
                Message("Press ENTER to Insert, ESC to abort.")
                if Inkey(0)==K_ENTER
                   Message("Inserting New record...")
                   MEMO->(FilLock(0))
                   MEMO->(DbInsert())
                   MEMO->(DbUnlock())
                endif
            case nKey==K_F6
                Message("Press ENTER to Reindex, ESC to abort.")
                if Inkey(0)==K_ENTER
                   Message("Reindexing, please wait...")
                   MEMO->(FilLock(0))
                   MEMO->(DbReindex())
                   MEMO->(DbUnlock())
                endif
            case nKey==K_F8
                Search_Folio()
           endcase
      enddo
   endif
   CloseWindow(wMemo)
return nil

static function MemoScreen(nMode)
local nKey
   InitVars(nMode)
   Message(MEMO_BAR)
   Tone(300,1)
   cColor:=SetColor("N/GB")
   if MEMO->(Deleted()) ; @ 05,35 say "<deleted>"
   else ; @ 05,35 say "         " ; endif
   @ 05,50 say "Rec# " + ;
   Transform(If(nMode==APPEND_MODE,MEMO->(LastRec())+1,MEMO->(RecNo())),"9999")+;
   "/"+Transform(MEMO->(LastRec()),"9999")
   SetColor(cColor)
   set key K_F7 to Air_Look
   @ 07, 17 say "ACM DATE" get mDate
   @ row(), 37 say "FOLIO" get mFolio
   @ row()+2, 17 say repl(" ",45)
   if nMode==VIEW_MODE
      @ row(), 17 say "AIRLINE" get mAirline
   else
      @ row(),   17 say "AIR CODE" get mAirCode pict "999"
   endif
   @ row()+2, 17 say "PESO AMT" get mAPeso pict "9,999,999.99"
   @ row()  , 41 say "DOLL. AMT" get mADollar pict "9,999,999.99"
   if nMode!=VIEW_MODE
      SetCursor(SC_NORMAL)
      read
      if updated() .and. Lastkey()!=K_ESC
          SaveVars(nMode)
      endif
   else
      clear gets
   endif
   set key K_F7 to
   SetCursor(SC_NONE)
return nil

static function InitVars(nMode)
    if nMode!=APPEND_MODE
       mDate:=MEMO->DATE
       mAirCode:=MEMO->AIR_CODE
       AIRLINE->(DbSeek(mAirCode))
       mAirline:=AIRLINE->AIRLINE
       mFolio:=MEMO->FOLIO
       mAPeso:=MEMO->AMOUNT_P
       mADollar:=MEMO->AMOUNT_D
    else
       mDate:=ctod("")
       mAirCode:=space(3)
       mFolio:=space(20)
       mAPeso:=0.00
       mADollar:=0.00
    endif
return nil

static function SaveVars(nMode)
   Message("Saving entries...")
   if nMode==APPEND_MODE   ;   MEMO->(AddRec(0))   ;   endif
   MEMO->(FilLock(0))
   MEMO->DATE:=mDate
   MEMO->AIR_CODE:=mAirCode
   MEMO->FOLIO:=mFolio
   MEMO->AMOUNT_P:=mAPeso
   MEMO->AMOUNT_D:=mADollar
   MEMO->(DbUnlock())
return nil

function Air_Look( cProc, cLine, cVar)
local wAir, x
   aItems := {}
   if (cVar == "MAIRCODE") .or. (cVar == "CAIRCODE")
      Message("Esc-Abort  Enter-Select")
      wAir:=OpenWindow(08,35,21,77,"Airline Look-up")
      AIRLINE->(DbGotop())
      do while AIRLINE->(!Eof())
          aAdd(aItems,AIRLINE->AIR_CODE+"  "+AIRLINE->AIRLINE)
          AIRLINE->(DbSkip())
      enddo
      aScrollBar:=ScrollBarNew(09,77,21,"N/W",1)
      ScrollBarDisplay(aScrollBar)
      ScrollBarUpdate(aScrollBar,1,Len(aItems),.T.)
      Message(SELECT_BAR)
      x:=aChoice(10,36,20,75,aItems,,"HandleMenu")
      CloseWindow(wAir)
      Message(MEMO_BAR)
      if LastKey()!=K_ESC
         KEYBOARD chr(K_CTRL_Y)+substr(aItems[x],1,3)
      endif
   else
      tone(500,1)
   endif
return nil

function HandleMenu(nMode,nCurElem,nRelPos)
local nRetVal,nKey
   ScrollBarUpdate(aScrollBar,nCurElem,Len(aItems),.F.)
   do case
      case nMode==AC_EXCEPT            // Is key stroke used by AChoice?
         nKey:=LastKey()               // No -- get last key pressed.
         do case
            case nKey==K_ESC           // Esc key pressed?
               nRetVal:=AC_ABORT       // Yes -- abort menu selection.
            case nKey==K_ENTER         // Enter key pressed?
               nRetVal:=AC_SELECT      // Yes -- make selection.
            otherwise                  // Other keys pressed.
               nRetVal:=AC_CONT        // Continue selection.
         endcase
      otherwise                        // Keystoke used by Achoice.
         nRetVal:=AC_CONT              // ....continue selection.
   endcase
return nRetVal

static function Search_Folio()
local wSearch,nRecNo:=MEMO->(RecNo())
   Message("Searching Records...")
   MEMO->(DbGotop())
   aFolio:={}  ;   aItems :={}
   do while MEMO->(!Eof())
      aAdd(aFolio,{MEMO->(RecNo()),MEMO->FOLIO})
      MEMO->(DbSkip())
   enddo
   aSort(aFolio,,, {|x,y| x[2] < y[2] })
   for x:=1 to len(aFolio)
      aAdd(aItems,"  "+aFolio[x][2])
   next
   wSearch:=OpenWindow(08,35,21,77,"Search Folio")
   aScrollBar:=ScrollBarNew(09,77,21,"N/W",1)
   ScrollBarDisplay(aScrollBar)
   ScrollBarUpdate(aScrollBar,1,Len(aItems),.T.)
   Message(SELECT_BAR)
   x:=aChoice(10,37,20,75,aItems,,"HandleMenu")
   CloseWindow(wSearch)
   if x!=0
      MEMO->(DbGoto(aFolio[x][1]))
   else
      MEMO->(DbGoto(nRecNo))
   endif
   aFolio:={}  ;  aItems:={}
return nil

static function more_keys()
local  wMore
   wMore:=OpenWindow(06,40,19,77,"Help Window")
   @ 07, 42 say ""
   @ row()+1, 42 say "F1 - Help Screen"
   @ row()+1, 42 say "F2 - Add a New Record to File"
   @ row()+1, 42 say "F3 - Edit Displayed Record"
   @ row()+1, 42 say "F4 - Delete Displayed Record"
   @ row()+1, 42 say "F5 - Insert a New Record"
   @ row()+1, 42 say "F6 - Reindex Database"
   @ row()+1, 42 say "F7 - Airline Codes (Edit/Add only)"
   @ row()+1, 42 say "PgDn/PgUp - Move from Pages"
   @ row()+1, 42 say "Up/Down - Previous/Next Record"
   @ row()+1, 42 say "Ctrl-[Up/Down] - Jump 20 Records"
   @ row()+1, 42 say "ESC - Go Back to Main Menu"
   inkey(0)
   CLoseWindow(wMore)
return nil

// <EOF> - MEMOS.PRG //
