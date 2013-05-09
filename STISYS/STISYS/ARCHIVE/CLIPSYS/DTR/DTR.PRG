/*
           Filename: DTR.PRG
        System-Name: Daily Time Record System
             Module: Main Menu
             Author: Rolando C. Ibarra Jr.
       Date-Started: November 7,1993
        Last-Update: November 7,1993
*/

#include "inkey.ch"
#include "setcurs.ch"
#include "set.ch"
#include "memoedit.ch"
#include "Janus.Ch"

#define DATA_PATH   "d:\dtrdata\;c:\dtrdata\"
#define A_ABOUT     910
#define F_MC        110
#define F_BUNDY     120
#define F_EXIT      990
#define R_DOOR      210
#define R_PAYTIME   220
#define R_PAYTIME1  215
#define R_PAYTIME2  216
#define M_BACKUP    310
#define M_RESTORE   320
#define M_REINDEX   330


static hBar,hFileMenu,hAboutMenu,hReportMenu,hMaintMenu

// Main program.
function Main()
local nChoice
local wOriginal,exitRequested:=.F.
public dStartDate, dEndDate
   set(_SET_SCOREBOARD,.F.)
   set(_SET_WRAP,.T.)
   set(_SET_PATH,DATA_PATH)
   set(_SET_DATEFORMAT,"mm-dd-yy")
   set(_SET_DELETED,.T.)
   set(_SET_EXACT,.F.)
   set(_SET_SOFTSEEK,.T.)
   set(_SET_CONFIRM,.T.)
   setcursor(SC_NONE)
   readinsert(.T.)
   nox := col()   ;   noy := row()
   coriginal := setcolor()
   woriginal := bkgndscreen()
   heading("Daily Time Record System")
   setcolor(DATA_COLORS)
#ifdef rbsm
   rbsm_logo()
#endif
   setcursor(SC_NONE)
   createbar()
   bardisplay(hbar)
   about()
   message("F10-Menu   Alt X-Exit")
   baractivate(hbar,lastkey())
   nchoice:=barmenuchoice(hbar)
   do while nchoice!=F_EXIT
      if lastkey()!=K_ESC
         do case
           case nChoice==A_ABOUT
              about()                        // About the system.
           case nChoice==F_MC
              do_mc()
           case nChoice==F_BUNDY
              do_Bundy()
           case nChoice==R_PAYTIME1
              UnderOverRep("RD",.t.)
           case nChoice==R_PAYTIME2
              UNderOverRep("P",.f.)
           case nChoice==R_DOOR
              DoorCloseRep()
           case nChoice==M_BACKUP
              CopyFile(1)                    // Backup Databases.
           case nChoice==M_RESTORE
              CopyFile(2)                    // Restore Databases.
           case nChoice==M_REINDEX
              ReIndexIt()
         endcase
      endif
      message("F10-Menu   Alt X-Exit")
      nchoice:=0
      baractivate(hBar)
      nchoice:=barmenuchoice(hbar)
   enddo
   readinsert(.f.)
   setcursor(SC_NORMAL)
   setcolor(coriginal)
   set(_SET_EXACT,.t.)
   set(_SET_DELETED,.f.)
   set(_SET_SCOREBOARD,.t.)
   restorescreen(woriginal)
   @ noy, nox say ""
   ? "Exit from Daily Time Record System..."
   ?
return nil

static function CreateBar()
   // Create empty bar menu
   hBar:=BarNew()
   // Create empty menus
   hAboutMenu:=MenuNew(chr(240))
   hFileMenu:=MenuNew("~Files")
   hReportMenu:=MenuNew("~Reports")
   hPaySub2:=MenuNew("~Undertime/Overtime Report ")
   hMaintMenu:=MenuNew("~Maint")
   // Add prompts
   // About Menu
   PromptAdd(hAboutMenu, A_ABOUT, "~About   ")
   // Files Menu
   PromptAdd(hFileMEnu,F_BUNDY, "~Bundy Clock    ")
   PromptAdd(hFileMenu,F_MC,    "~Master File    ")
   PromptAddline(hFileMenu)
   PromptAdd(hFileMenu,  F_EXIT,"E~xit      Alt-X")
   // REports Menu
   PromptAddSub(hREportMenu,R_PAYTIME,hPaySub2)
       PromptAdd(hPaySub2,R_PAYTIME1,"~Regular Employees ")
       PromptAdd(hPaySub2,R_PAYTIME2,"~Probationary/Trainees ")
   PromptAdd(hReportMenu,R_DOOR,"~Door Closed Report")
   // Maint Menu
   PromptAdd(hMaintMenu,M_BACKUP, "~Backup   ")
   PromptAdd(hMaintMenu,M_RESTORE,"~Restore  ")
   PromptAdd(hMaintMenu,M_REINDEX,"Re~Index   ")
   MenuAdd(hBar,hAboutMenu)
   MenuAdd(hBar,hFileMenu)
   MenuAdd(hBar,hReportMenu)
   MenuAdd(hBar,hMaintMenu)
   // Add quick key or shortcuts
   PromptQuickKey(hbar,hFileMenu,F_EXIT,K_ALT_X)
return nil

static function About()
local wAbout,mAuthor
   mAuthor:=chr(82)+chr(111)+chr(108)+chr(108)+chr(105)+chr(101)+;
   chr(32)+chr(38)+;
   " "+"Pinky"
   Message("Press any key to continue....")
   wAbout:=OpenWindow(07,19,16,61,"About the system")
   @ 09,21 say "       Daily Time Record System        "
   @ 10,21 say "                                       "
   @ 11,21 say "           Developed for               "
   @ 12,21 say "      Rural Bank of San Miguel         "
   @ 13,21 say "                by                     "
   @ 14,21 say space((34-len(mAuthor))/2)+mAuthor
   @ 15,21 say "         November 11, 1993             "
   @ 08,19 to 16,61 double
   Inkey(0)
   CloseWindow(wAbout)
return nil

// end-of-file
