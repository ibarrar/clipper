/*
                Filename :  PIS.PRG
             System Name :  Passenger Information System
                  Module :  Main Menu
                  Author :  Rolando C. Ibarra Jr.
            Date-Started :  Sept. 18, 1993
*/

#include "Inkey.ch"
#include "SetCurs.ch"
#include "Set.ch"
#include "Janus.ch"

#define DATA_PATH   "d:\pidata"
#define A_ABOUT     999
#define F_EXIT      998
#define F_PASS      100
#define M_BACKUP    310
#define M_RESTORE   320
#define M_REINDEX   330

static hBar,hFileMenu,hReportMenu,hMaintMenu,hAboutMenu

// Main program.
function Main()
local nChoice
local wOriginal,exitRequested:=.F.
public dStartDate, dEndDate, cCity, cUsdOp, nUsdRate
   Set(_SET_SCOREBOARD,.F.)
   Set(_SET_WRAP,.T.)
   Set(_SET_PATH,DATA_PATH)
   Set(_SET_DATEFORMAT,"mm-dd-yy")
   Set(_SET_DELETED,.T.)
   Set(_SET_EXACT,.F.)
   Set(_SET_SOFTSEEK,.T.)
   Set(_SET_CONFIRM,.T.)
   Set(_SET_DELIMITERS,.T.)
   Set(_SET_DELIMCHARS,"[]")
   SetCursor(SC_NONE)
   ReadInsert(.T.)
   nOx:=col()   ;   nOy:=row()
   cOriginal:=SetColor()
   wOriginal:=BkgndScreen()
   Heading("Super Travel, Inc. - Passenger Information System")
   SetColor(DATA_COLORS)
   Sti_Logo()
   SetCursor(SC_NONE)
   CreateBar()
   BarDisplay(hBar)
   About()
   Message("F10-Menu   Arrow Keys-Navigate   Enter-Select   Alt+X-Exit")
   BarActivate(hBar,lastkey())
   nChoice:=BarMenuChoice(hBar)
   do while nChoice!=F_EXIT
      if LastKey()!=K_ESC
         do case
           case nChoice==A_ABOUT
              About()                        // About the system.
           case nChoice==F_PASS
              Do_Passenger()
           case nChoice==M_BACKUP
              CopyFile(1)
         case nChoice==M_RESTORE
              CopyFile(2)
         endcase
      endif
      Message("F10-Menu   Arrow Keys-Navigate   Enter-Select   Alt+X-Exit")
      nChoice:=0
      BarActivate(hBar)
      nChoice:=BarMenuChoice(hBar)
   enddo
   ReadInsert(.F.)
   SetCursor(SC_NORMAL)
   SetColor(cOriginal)
   Set(_SET_EXACT,.T.)
   Set(_SET_DELETED,.F.)
   Set(_SET_SCOREBOARD,.T.)
   RestoreScreen(wOriginal)
   @ nOy, nOx say ""
   ? "Exit from Passenger Information System..."
   ?
return nil

static function CreateBar()
   // Create empty bar menu
   hBar := BarNew()
   // Create empty menus
   hAboutMenu  := MenuNew(chr(240))
   hFileMenu   := MenuNew("~Files")
   hMaintMenu  := MenuNew("~Maint")
   // Add prompts
   // About Menu
   PromptAdd(hAboutMenu,A_ABOUT,"~About PIS  ")
   // File Menu
   PromptAdd(hFileMenu,F_PASS,"~Passengers File  Alt-P  ")
   PromptAddLine(hFileMenu)
   PromptAdd(hFileMenu,F_EXIT, "E~xit            Alt-X  ")
   // Maint Menu
   PromptAdd(hMaintMenu,M_BACKUP, "~Backup   ")
   PromptAdd(hMaintMenu,M_RESTORE,"~Restore  ")
   // Add menus to Menubar
   MenuAdd(hBar,hAboutMenu)
   MenuAdd(hBar,hFileMenu)
   MenuAdd(hBar,hMaintMenu)
   // Add quick key or shortcuts
   PromptQuickKey(hbar,hFileMenu,F_EXIT,K_ALT_X)
   PromptQuickKey(hbar,hFileMenu,F_PASS,K_ALT_P)
return nil

static function About()
local wAbout
   Message("Press any key to continue....")
   wAbout:=OpenWindow(07,19,16,60,"About VCHR")
   @ 09,21 say "  STI - Passenger Information System  "
   @ 10,21 say "                                      "
   @ 11,21 say "           Developed for              "
   @ 12,21 say "         Super Travel, Inc.           "
   @ 13,21 say "                by                    "
   @ 14,21 say "       Rolando C. Ibarra Jr.          "
   @ 15,21 say "        September 18, 1993            "
   Inkey(0)
   CloseWindow(wAbout)
return nil

// end-of-file
