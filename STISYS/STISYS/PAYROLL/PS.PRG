/*
           Filename: PAYROLL.PRG
        System-Name: Super Travel Payroll System
             Module: Main Menu
             Author: Ronan J. Paredes
       Date-Started: January 7,1993
        Last-Update: January 7,1993
*/

#include "inkey.ch"
#include "setcurs.ch"
#include "set.ch"
#include "memoedit.ch"
#include "Janus.Ch"

#define DATA_PATH   "d:\psdata\;.\data\"
#define A_ABOUT     910
#define F_MC        110
#define F_EXIT      990
#define R_PAYROLL   210
#define R_PAYREP       211
#define R_PAYREP1         212
#define R_PAYREP2         213
#define R_PAYTIME      214
#define R_PAYTIME1        215
#define R_PAYTIME2        216
#define R_DOOR         217
#define R_13MONTH   220
#define R_13MONTH1     221
#define R_13MONTH2     222
#define R_5DAY      230
#define R_WTAX      240
#define R_PAYSLIP   250
#define R_PAYSLIP1     251
#define R_PAYSLIP2     252
#define R_PAYSLIP3     253
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
   heading("Super Travel, Inc. - Payroll System")
   setcolor(DATA_COLORS)
//   sti_logo()
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
           case nchoice==A_ABOUT
              about()                        // About the system.
           case nchoice==F_MC
              do_mc()
           case nChoice==R_13MONTH1
              Pay13Report(.F.)
           case nChoice==R_5DAY
              Pay5DayReport()
           case nChoice==R_WTAX
              WTaxReport()
           case nChoice==R_PAYREP1
              PrintPayroll("RD",.T.)
           case nChoice==R_PAYREP2
              PrintPayroll("P",.F.)
           case nChoice==R_PAYTIME1
              UnderOverRep("RD",.T.)
           case nChoice==R_PAYTIME2
              UnderOverRep("P",.F.)
           case nChoice==R_DOOR
              DoorCloseRep()
           case nChoice==R_PAYSLIP1
              PaySlip()
           case nChoice==R_PAYSLIP2
              PaySlip2()
           case nChoice==R_PAYSLIP3
              PaySlip3()
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
   ? "Exit from Payroll System..."
   ?
return nil

static function CreateBar()
   // Create empty bar menu
   hBar:=BarNew()
   // Create empty menus
   hAboutMenu:=MenuNew(chr(240))
   hFileMenu:=MenuNew("~Files")
   hReportMenu:=MenuNew("~Reports")
   hPaySub:=MenuNew("~Payroll Reports")
   hPaySub1:=MenuNew("~Payroll Period Report")
   hPaySub2:=MenuNew("~Undertime/Overtime Report  ")
   h13mSub:= MenuNew("13th ~Month Salary Report")
   hSlipSub:= MenuNew("Pay~slips")
   hMaintMenu:=MenuNew("~Maint")
   // Add prompts
   // About Menu
   PromptAdd(hAboutMenu, A_ABOUT, "~About   ")
   // Files Menu
   PromptAdd(hFileMenu,  F_MC,    "~Master File             ")
   PromptAddline(hFileMenu)
   PromptAdd(hFileMenu,  F_EXIT,  "E~xit             Alt-X  ")
   // Reports Menu
   PromptAddSub(hReportMenu,R_PAYROLL,hPaySub)
      PromptAddSub(hPaySub,R_PAYREP,hPaySub1)
         PromptAdd(hPaySub1,R_PAYREP1,"~Regular Employees ")
         PromptAdd(hPaySub1,R_PAYREP2,"~Probationary/Trainees  ")
      PromptAddSub(hPaySub,R_PAYTIME,hPaySub2)
         PromptAdd(hPaySub2,R_PAYTIME1,"~Regular Employees ")
         PromptAdd(hPaySub2,R_PAYTIME2,"~Probationary/Trainees  ")
      PromptAdd(hPaySub,R_DOOR, "~Door Close Report")
   PromptAddSub(hReportMenu,R_13MONTH,h13mSub)
      PromptAdd(h13mSub,R_13MONTH1," ~Regular Employees ")
      PromptAdd(h13mSub,R_13MONTH2," ~Probationary/Trainees  ")
   PromptAdd(hReportMenu,R_5DAY, "5 ~Day Incentive Report ")
   PromptAdd(hReportMenu,R_WTAX, "~WithHolding Tax Report ")
   PromptAddSub(hReportMenu,R_PAYSLIP,hSlipSub)
      PromptAdd(hSlipSub,R_PAYSLIP1," ~Payroll Payslips  ")
      PromptAdd(hSlipSub,R_PAYSLIP2," ~13 Month Payslips  ")
      PromptAdd(hSlipSub,R_PAYSLIP3," ~5 Day Incentive Payslips  ")
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
local wAbout
   Message("Press any key to continue....")
   wAbout:=OpenWindow(07,19,16,60,"About the system")
   @ 09,21 say "    Super Travel - Payroll System     "
   @ 10,21 say "                                      "
   @ 11,21 say "           Developed for              "
   @ 12,21 say "         Super Travel, Inc.           "
   @ 13,21 say "                by                    "
   @ 14,21 say "        Rollie C. Ibarra Jr.          "
   @ 15,21 say "            May 28, 1992              "
   Inkey(0)
   CloseWindow(wAbout)
return nil

// end-of-file
