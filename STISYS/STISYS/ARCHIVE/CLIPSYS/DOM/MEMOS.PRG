// Filename:      MEMOS.PRG
// System-Name:   PR Domestic Ticketing System
// Module:        File Handling Module for MEMO file
// Author:        Rolando Castro Ibarra Junior
// Date-Started:  Dec 07, 1993
// Last-Update:   Dec 25, 1993

#include "Inkey.ch"
#include "Achoice.ch"
#include "Setcurs.ch"
#include "Mode.Ch"
#include "cl501_60.ch"

#define MEMO_BAR   "F1-Help  F2-Add  F3-Edit  F4-Delete  F8-Folio  Esc-Abort"
#define MISC_BAR   "F1-Help  F2-Add  F3-Edit  F4-Delete  F8-Particular  Esc-Abort"
static mDate, mFolio, mAmount , mPar

function Memos()
local  nKey:=0 ,wMemo
   MEMO->(DbGotop())
   wMemo := OpenWindow(05,15,10,64,"Memos")
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
   "/"+Transform(MEMO->(LastRec()),"@B 9999")
   SetColor(cColor)
   @ 07   , 17     say "DATE"   get mDate  pict "@D"
   @ row(),col()+14 say "FOLIO"  get mFolio pict "@!"
   @ row()+2,30    say "AMOUNT" get mAmount pict "9,999,999.99"
   if nMode!=VIEW_MODE
      SetCursor(SC_NORMAL)
      read
      if updated() .and. Lastkey()!=K_ESC
          SaveVars(nMode)
      endif
   else
      clear gets
   endif
   SetCursor(SC_NONE)
return nil

static function InitVars(nMode)
    if nMode!=APPEND_MODE
       mDate:=MEMO->DATE
       mFolio:=MEMO->FOLIO
       mAMount:=MEMO->AMOUNT
    else
       mDate:=ctod("")
       mFolio:=space(10)
       mAmount:=0.00
    endif
return nil

static function SaveVars(nMode)
   Message("Saving entries...")
   if nMode==APPEND_MODE   ;   MEMO->(AddRec(0))   ;   endif
   MEMO->(FilLock(0))
   MEMO->DATE:=mDate
   MEMO->FOLIO:=mFolio
   MEMO->AMOUNT:=mAmount
   MEMO->(DbUnlock())
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

static function Search_Particular()
local wSearch,nRecNo:=MISC->(RecNo())
   Message("Searching Records...")
   MISC->(DbGotop())
   aFolio:={}  ;   aItems :={}
   do while MISC->(!Eof())
      aAdd(aFolio,{MISC->(RecNo()),MISC->PARTICULAR})
      MISC->(DbSkip())
   enddo
   aSort(aFolio,,, {|x,y| x[2] < y[2] })
   for x:=1 to len(aFolio)
      aAdd(aItems,"  "+aFolio[x][2])
   next
   wSearch:=OpenWindow(08,35,21,77,"Search Particular")
   aScrollBar:=ScrollBarNew(09,77,21,"N/W",1)
   ScrollBarDisplay(aScrollBar)
   ScrollBarUpdate(aScrollBar,1,Len(aItems),.T.)
   Message(SELECT_BAR)
   x:=aChoice(10,37,20,75,aItems,,"HandleMenu")
   CloseWindow(wSearch)
   if x!=0
      MISC->(DbGoto(aFolio[x][1]))
   else
      MISC->(DbGoto(nRecNo))
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

function Misc()
local  nKey:=0 ,wMisc
   MISC->(DbGotop())
   wMisc := OpenWindow(05,15,10,64,"Miscelleanous")
   if RecCount()==0 ; MiscScreen(APPEND_MODE) ; endif
   if LastKey()!=K_ESC
      do while (nKey!=K_ESC)
         MiscScreen(VIEW_MODE)
         nKey:=inKey(0)
         do case
            case nKey==K_DOWN
               MISC->(DbSkip())
               if Eof()
                  MISC->(DbGoBottom())
                  Tone(200,1)
                  Message("End of file reached....")
                  Inkey(1)
               endif
            case nKey==K_UP
               MISC->(DbSkip(-1))
               if MISC->(Bof())
                  MISC->(DbGoTop())
                  Tone(200,1)
                  Message("Beginning of file reached....")
                  Inkey(1)
               endif
            case nKey==K_CTRL_PGDN
               MISC->(DbSkip(NUM_TO_SKIP))
               if MISC->(Eof())
                  MISC->(DbGoBottom())
                  Tone(200,1)
                  Message("End of file reached....")
                  Inkey(1)
               endif
            case nKey==K_CTRL_PGUP
               MISC->(DbSkip(-NUM_TO_SKIP))
               if MISC->(Bof())
                  MISC->(DbGoTop())
                  Tone(200,1)
                  Message("Beginning of file reached....")
                  Inkey(1)
               endif
            case nKey==K_END
                MISC->(DbGoBottom())
                Message("Moving to end of file....")
                Inkey(1)
            case nKey==K_HOME
                MISC->(DbGoTop())
                Message("Moving to beginning of file....")
                Inkey(1)
            case nKey==K_F1
                More_Keys()
            case nKey==K_F2
                Message("Press ENTER to Add, ESC to abort.")
                if Inkey(0)==K_ENTER
                   MiscScreen(APPEND_MODE)
                endif
            case nKey==K_F3
                Message("Press ENTER to Edit, ESC to abort.")
                if Inkey(0)==K_ENTER
                   MiscScreen(EDIT_MODE)
                endif
            case nKey==K_F4
                Message("Press ENTER to Delete, ESC to abort.")
                if Inkey(0)==K_ENTER
                    MISC->(FilLock(0))
                    MISC->(DbDelete())
                    MISC->(DbUnlock())
                endif
            case nKey==K_F5
                Message("Press ENTER to Insert, ESC to abort.")
                if Inkey(0)==K_ENTER
                   Message("Inserting New record...")
                   MISC->(FilLock(0))
                   MISC->(DbInsert())
                   MISC->(DbUnlock())
                endif
            case nKey==K_F6
                Message("Press ENTER to Reindex, ESC to abort.")
                if Inkey(0)==K_ENTER
                   Message("Reindexing, please wait...")
                   MISC->(FilLock(0))
                   MISC->(DbReindex())
                   MISC->(DbUnlock())
                endif
            case nKey==K_F8
                Search_Particular()
           endcase
      enddo
   endif
   CloseWindow(wMisc)
return nil

static function MiscScreen(nMode)
local nKey
   InitMisc(nMode)
   Message(MISC_BAR)
   Tone(300,1)
   cColor:=SetColor("N/GB")
   if MISC->(Deleted()) ; @ 05,35 say "<deleted>"
   else ; @ 05,35 say "         " ; endif
   @ 05,50 say "Rec# " + ;
   Transform(If(nMode==APPEND_MODE,MISC->(LastRec())+1,MISC->(RecNo())),"9999")+;
   "/"+Transform(MISC->(LastRec()),"@B 9999")
   SetColor(cColor)
   @ 07   , 17     say "DATE"   get mDate  pict "@D"
   @ row(),col()+12 say "PARTICULAR" get mPar pict "@!"
   @ row()+2,30    say "AMOUNT" get mAmount pict "9,999,999.99"
   if nMode!=VIEW_MODE
      SetCursor(SC_NORMAL)
      read
      if updated() .and. Lastkey()!=K_ESC
          SaveMisc(nMode)
      endif
   else
      clear gets
   endif
   SetCursor(SC_NONE)
return nil

static function InitMisc(nMode)
    if nMode!=APPEND_MODE
       mDate:=MISC->DATE
       mPar:=MISC->PARTICULAR
       mAMount:=MISC->AMOUNT
    else
       mDate:=ctod("")
       mPar:=space(10)
       mAmount:=0.00
    endif
return nil

static function SaveMisc(nMode)
   Message("Saving entries...")
   if nMode==APPEND_MODE   ;   MISC->(AddRec(0))   ;   endif
   MISC->(FilLock(0))
   MISC->DATE:=mDate
   MISC->PARTICULAR:=mPar
   MISC->AMOUNT:=mAmount
   MISC->(DbUnlock())
return nil

// <EOF> - MEMOS.PRG //
