/*
           Filename: PAYROLL.PRG
        System-Name: Super Travel Payroll System
             Module: Main Menu
             Author: Rolando C. Ibarra Jr.
       Date-Started: January 7,1993
        Last-Update: January 7,1993
*/

#include "inkey.ch"
#include "setcurs.ch"
#include "set.ch"
#include "memoedit.ch"
#include "Janus.Ch"

/*#define DATA_PATH   "d:\psdata\;.\data\"*/
#define DATA_PATH "D:\PSDATA\"
#define A_ABOUT     101
#define F_MC        102
#define F_EXIT      103
#define R_PAYROLL   104
#define R_PAYREP    105
#define R_PAYREP1   106
#define R_PAYREP2   107
#define R_TWICE     108
#define R_TWICEP    109
#define R_TWICEP1   110
#define R_TWICEP2   111
#define R_TWICEUO   112
#define R_TWICEUO1  113
#define R_TWICEUO2  114
#define R_PAYTIME   115
#define R_PAYTIME1  116
#define R_PAYTIME2  117
#define R_DOOR      118
#define R_13MONTH   119
#define R_13MONTH1  120
#define R_13MONTH2  121
#define R_13MONTH3  122
#define R_5DAY      123
#define R_WTAX      124
#define R_PAYSLIP   125
#define R_PAYSLIP1  126
#define R_PAYSLIP2  127
#define R_PAYSLIP3  128
#define M_BACKUP    129
#define M_RESTORE   130
#define M_REINDEX   131

static hBar,hFileMenu,hAboutMenu,hReportMenu,hMaintMenu

// Main program.
function Main()
local nChoice
local wOriginal,exitRequested:=.F.
public dStartDate, dEndDate, cOutput
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
   sti_logo()
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
              Pay13Report(1)
           case nChoice==R_13MONTH2
              Pay13Report(2)
           case nChoice==R_13MONTH3
              Pay13Report(3)
           case nChoice==R_5DAY
              Pay5DayReport()
           case nChoice==R_WTAX
              WTaxReport()
           case nChoice==R_PAYREP1
              PrintPayroll("RD",.T.)
           case nChoice==R_PAYREP2
              PrintPayroll("P",.F.)
           case nChoice==R_TWICEP1
              TwicePayroll("RD",.t.)
           case nChoice==R_TWICEP2
              TwicePayroll("P",.f.)
           case nChoice==R_TWICEUO1
              TwiceUndOvr("RD",.t.)
           case nChoice==R_TWICEUO2
              TwiceUndOvr("P",.f.)
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
   hTwiceSub:=MenuNew("~Between Period Appraisal ")
   hTwicePSub:=MenuNew("Payroll Period Report ")
   hTwiceUOSub:=MenuNew("Under/Overtime Report ")
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
      PromptAdd(h13mSub,R_13MONTH3," Re~Signed Employees ")
   PromptAdd(hReportMenu,R_5DAY, "5 ~Day Incentive Report ")
   PromptAdd(hReportMenu,R_WTAX, "~WithHolding Tax Report ")

   PromptAddSub(hReportMenu,R_TWICE,hTwiceSub)
      PromptAddSub(hTwiceSub,R_TWICEP,hTwicePSub)
         PromptAdd(hTwicePSub,R_TWICEP1, "~Regular Employees ")
         PromptAdd(hTwicePSub,R_TWICEP2,"~Probationary/Trainees  ")
      PromptAddSub(hTwiceSub,R_TWICEUO,hTwiceUOSub)
         PromptAdd(hTwiceUOSub,R_TWICEUO1,"~Regular Employees ")
         PromptAdd(hTwiceUOSub,R_TWICEUO2,"~Probationary/Trainees  ")

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
   @ 14,21 say "        Rolando C. Ibarra Jr.         "
   @ 15,21 say "          January 7, 1993             "
   @ 08,19 to 16,60 double
   Inkey(0)
   CloseWindow(wAbout)
return nil

// end-of-file
