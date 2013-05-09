// Filename:      ACR.PRG
// System-Name:   Bank Settlement Plan System
// Module:        Airline Conversion Rate File
// Author:        Rollie C. Ibarra
// Date-Started:  August 17, 1993
// Last-Update:   August 25, 1993

#include "Inkey.ch"
#include "Achoice.ch"
#include "Setcurs.ch"
#include "Mode.Ch"
#include "c501_mod.ch"

#define ACR_BAR   "F1-Help   F2-Add   F3-Edit   F4-Delete   F7-Summary   ESC-Abort"
static mDateFrom, mDateTo, mAmount

function ACR()
local  nKey:=0 ,wACR
   ACR->(DbGotop())
   wACR := OpenWindow(05,15,11,64,"ACR")
   if RecCount()==0 ; ACRScreen(APPEND_MODE) ; endif
   if LastKey()!=K_ESC
      do while (nKey!=K_ESC)
         ACRScreen(VIEW_MODE)
         nKey:=inKey(0)
         do case
            case nKey==K_DOWN
               ACR->(DbSkip())
               if Eof()
                  ACR->(DbGoBottom())
                  Tone(200,1)
                  Message("End of file reached....")
                  Inkey(1)
               endif
            case nKey==K_UP
               ACR->(DbSkip(-1))
               if ACR->(Bof())
                  ACR->(DbGoTop())
                  Tone(200,1)
                  Message("Beginning of file reached....")
                  Inkey(1)
               endif
            case nKey==K_CTRL_PGDN
               ACR->(DbSkip(NUM_TO_SKIP))
               if ACR->(Eof())
                  ACR->(DbGoBottom())
                  Tone(200,1)
                  Message("End of file reached....")
                  Inkey(1)
               endif
            case nKey==K_CTRL_PGUP
               ACR->(DbSkip(-NUM_TO_SKIP))
               if ACR->(Bof())
                  ACR->(DbGoTop())
                  Tone(200,1)
                  Message("Beginning of file reached....")
                  Inkey(1)
               endif
            case nKey==K_END
                ACR->(DbGoBottom())
                Message("Moving to end of file....")
                Inkey(1)
            case nKey==K_HOME
                ACR->(DbGoTop())
                Message("Moving to beginning of file....")
                Inkey(1)
            case nKey==K_F2
                Message("Press ENTER to Add, ESC to abort.")
                if Inkey(0)==K_ENTER
                   ACRScreen(APPEND_MODE)
                endif
            case nKey==K_F3
                Message("Press ENTER to Edit, ESC to abort.")
                if Inkey(0)==K_ENTER
                   ACRScreen(EDIT_MODE)
                endif
            case nKey==K_F4
                Message("Press ENTER to Delete, ESC to abort.")
                if Inkey(0)==K_ENTER
                    ACR->(FilLock(0))
                    ACR->(DbDelete())
                    ACR->(DbUnlock())
                endif
            case nKey == K_F7
                ACR_Report()
           endcase
      enddo
   endif
   CloseWindow(wACR)
return nil

static function ACRScreen(nMode)
local nKey
   InitVars(nMode)
   Message(ACR_BAR)
   Tone(300,1)
   cColor:=SetColor("N/GB")
   if ACR->(Deleted()) ; @ 05,35 say "<deleted>"
   else ; @ 05,35 say "         " ; endif
   @ 05,55 say "Rec# " + ;
   Transform(If(nMode==APPEND_MODE,ACR->(LastRec())+1,ACR->(RecNo())),"999")
   SetColor(cColor)
   @ 07,      17 say "     From" get mDateFrom
   @ row()  , 42 say "To"        get mDateTo
   @ row()+2, 17 say "              Rate" get mAmount pict "99.99"
   @ row()+1, 17 say "        (Peso equiv. against 1 USD)"
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
       mDateFrom:=ACR->DATEFROM
       mDateTo  :=ACR->DATETO
       mAmount  :=ACR->AMOUNT
    else
       mDateFrom:=ctod("")
       mDateTo  :=ctod("")
       mAmount  :=0.00
    endif
return nil

static function SaveVars(nMode)
   Message("Saving entries...")
   if nMode==APPEND_MODE   ;   ACR->(AddRec(0))   ;   endif
   ACR->(FilLock(0))
   ACR->DATEFROM := mDateFrom
   ACR->DATETO   := mDateTo
   ACR->AMOUNT   := mAmount
   ACR->(DbUnlock())
return nil

function ACR_Report()
local nRecno := ACR->(RecNo())
   if GetDates()
      if IsPrinter()
         Set(_SET_CONSOLE,.F.)
         Set(_SET_PRINTER,.T.)
         STI_Header(1)
         ? chr(27) + chr(119)+ chr(1)     // Double Heigth
         ?? chr(27) + chr(107) + chr(0)   // select Roman
         ?? chr(27)+chr(120)+chr(1)       // NLQ on
         ?? "þAirline Conversion Rate Report"
         ?
         ? "Period :"+expand(dStartDate)+" to "+expand(dEndDate)
         ?
         ? chr(27) + chr(119)+ chr(0)     // Double Heigth off
         Set(_SET_MARGIN,15)
         ? " From  ",space(5),"  To   ",space(5),"Amount"
         ?
         ACR->(DbSeek(dStartDate))
         do while ACR->(!Eof()) .and. (ACR->DATEFROM < dEndDate)
            ? expand(ACR->DATEFROM),space(5),expand(ACR->DATETO),space(7)
            ?? transform(ACR->AMOUNT,"99.99")
            ACR->(DbSkip())
         enddo
         ? repl('=',37)
         ?? chr(27)+chr(120)+chr(0)       //NLQ off
         eject
         Set(_SET_MARGIN,0)
         Set(_SET_CONSOLE,.T.)
         Set(_SET_PRINTER,.F.)
         Message("Printing done...")
         tone(300,1)
         inkey(2)
      else
         Message("Printer not ready...")
         tone(100,3)
         inkey(2)
      endif
   endif
   ACR->(DbGoto(nRecNo))
return nil
// <EOF> - ACR.PRG //
