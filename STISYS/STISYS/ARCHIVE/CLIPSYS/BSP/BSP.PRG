// Filename:      BSP.PRG
// System-Name:   Bank Settlement Plan System
// Module:        Main Menu
// Author:        Rollie C. Ibarra Jr.
// Date-Started:  August 17, 1993
// Last-Update:   August 17, 1993

#include "OMenu.ch"
#include "Inkey.ch"
#include "SetCurs.ch"
#include "Set.ch"
#include "MemoEdit.ch"
#include "Mode.ch"
#include "Help.ch"
#include "c501_mod.ch"
#include "bsp.ch"

#define DATA_PATH   "D:\BSPDATA\;D:\GLDATA;.\"
#define F_MCO       110
#define F_SERIES2   120
#define F_SERIES4   130
#define F_APOLLO    140
#define F_ABACUS    150
#define F_MEMO      160
#define F_ACR       170
#define F_EXIT      199
#define F_AUTOTKT   180
#define R_SINPAX    310
#define R_ALLPAX    320
#define R_UNBILL    330
#define R_UNPAID    340
#define R_SALES     350
#define R_MONTH     351
#define R_QUARTER   352
#define R_YEAR      353
#define R_PERIOD    354
#define R_COMPARE   355
#define R_ALL       360
#define R_AIR       370
#define M_BACKUP    410
#define M_RESTORE   420
#define M_REINDEX   430
#define M_UPDATE    440
#define A_ABOUT     510
#define A_HELP      520

static hBar,hFileMenu,hMemoMenu,hReportMenu,hMaintMenu,hAboutMenu,hSubSales
// Main program.
function Main()
local nChoice
local wOriginal,exitRequested:=.F.
public dStartDate, dEndDate, cOutput, vDRate, cAircode, cDbf
   Set(_SET_SCOREBOARD,.F.)
   Set(_SET_WRAP,.T.)
   Set(_SET_PATH,DATA_PATH)
   Set(_SET_DATEFORMAT,"mm-dd-yy")
   Set(_SET_DELETED,.T.)
   Set(_SET_EXACT,.F.)
   Set(_SET_SOFTSEEK,.T.)
   Set(_SET_CONFIRM,.T.)
   SetCursor(SC_NONE)
   ReadInsert(.T.)
   nOx:=col()   ;   nOy:=row()
   cOriginal:=SetColor()
   wOriginal:=BkgndScreen()
   Heading("Super Travel, Inc. - Bank Settlement Plan System")
   Sti_Logo()
   SetColor(DATA_COLORS)
   CreateBar()
   SetCursor(SC_NONE)
   if NetUse("AIRLINE",DB_SHARED,NUM_SECONDS)
      set index to "AIR_CODE"
   endif
   if NetUse("ACR",DB_SHARED,NUM_SECONDS)
      set index to ACR
   endif
   BarDisplay(hBar)
   About()
   Message("F10-Menu   Alt X-Exit")
   BarActivate(hBar,LastKey())
   nChoice:=BarMenuChoice(hBar)
   do while nChoice!=F_EXIT
      if LastKey()!=K_ESC
         do case
           case nChoice==A_ABOUT
              About()                        // About the system.
           case nChoice==F_MCO
              cDbf:=OpenBSP(1)
              (cDbf)->(Do_BSP())
              (cDbf)->(DbCloseArea())
           case nChoice==F_SERIES2
              cDbf:=OpenBSP(2)
              (cDbf)->(Do_BSP())
              (cDbf)->(DbCloseArea())
           case nChoice==F_SERIES4
              cDbf:=OpenBSP(3)
              (cDbf)->(Do_BSP())
              (cDbf)->(DbCloseArea())
           case nChoice==F_APOLLO
              cDbf:=OpenBSP(4)
              (cDbf)->(Do_BSP())
              (cDbf)->(DbCloseArea())
           case nChoice==F_ABACUS
              cDbf:=OpenBSP(5)
              (cDbf)->(Do_BSP())
              (cDbf)->(DbCloseArea())
           case nChoice == F_MEMO
              if NetUse("MEMO",DB_SHARED,NUM_SECONDS)
                 set index to MEMO
              endif
              MEMO->(Memo())
              MEMO->(DbCloseArea())
           case nChoice == F_ACR
              if NetUse("ACR",DB_SHARED,NUM_SECONDS)
                 set index to ACR
              endif
              ACR->(ACR())
              ACR->(DbCloseArea())
           case nChoice == R_SINPAX
              Indi_Repo()
           case nChoice == R_ALLPAX
              Sum_Repo()
           case nChoice == R_UNBILL
              Print_Unbilled()
           case nChoice == R_UNPAID
              Print_Unpaid()
           case nChoice == R_MONTH
              Sales_Report(1)
           case nChoice == R_QUARTER
              Sales_Report(2)
           case nChoice == R_YEAR
              Sales_Report(3)
           case nChoice == R_PERIOD
              Sales_Report(4)
           case nChoice == R_ALL
              YearSum()
           case nChoice == R_COMPARE
              CompSum()
           case nChoice == R_AIR
              AirSummary()
           case nChoice==M_BACKUP
              CopyFile(1)                    // Backup Databases.
           case nChoice==M_RESTORE
              CopyFile(2)                    // Restore Databases.
           case nChoice==M_REINDEX
              ReIndexIt()                    // Reindex Databases.
           case nChoice==M_UPDATE
              UpdateBills()
         endcase
      endif
      Message("F10-Menu   Alt X-Exit")
      nChoice:=0
      BarActivate(hBar)
      nChoice:=BarMenuChoice(hBar)
   enddo
   AIRLINE->(DbCloseArea())
   ReadInsert(.F.)
   SetCursor(SC_NORMAL)
   SetColor(cOriginal)
   Set(_SET_EXACT,.T.)
   Set(_SET_DELETED,.F.)
   Set(_SET_SCOREBOARD,.T.)
   RestoreScreen(wOriginal)
   @ nOy, nOx say ""
   ? "Exit from Bank Settlement Plan System..."
   ?
return nil

static function CreateBar()
   // Create empty bar menu
   hBar:=BarNew()
   // Create empty menus
   hAboutMenu:=MenuNew(chr(240))
   hFileMenu:=MenuNew("~Files")
   hReportMenu:=MenuNew("~Reports")
   hMaintMenu:=MenuNew("~Maint")
   hSubSales:=MenuNew("Sales ~Reports")
   // Add prompts
   // About Menu
   PromptAdd(hAboutMenu,A_ABOUT,"~About BSP  ")
   // Files Menu
   PromptAdd(hFileMenu,F_MCO,    "~Miscellaneous Charge Order  ")
   PromptAdd(hFileMenu,F_SERIES2,"Series ~2 Tickets            ")
   PromptAdd(hFileMenu,F_SERIES4,"Series ~4 Tickets            ")
   PromptAdd(hFileMenu,F_APOLLO, "Optat A~POLLO       ")
   PromptAdd(hFileMenu,F_ABACUS, "Optat A~BACUS       ")
   PromptAddLine(hFileMenu)
   PromptAdd(hFileMenu,F_MEMO,  "~Airline Credit/Debit Memos  ")
   PromptAdd(hFileMenu,F_ACR,   "Airline Conversion ~Rates  ")
   PromptAddLine(hFileMenu)
   PromptAdd(hFileMenu,F_EXIT,"E~xit             Alt-X  ")
   // Report Menu
   PromptAdd(hReportMenu,R_SINPAX,"Summary Report (~Single Pax)  ")
   PromptAdd(hReportMenu,R_ALLPAX,"Summary Report (~BSP Transmittal) ")
   PromptAdd(hReportMenu,R_UNBILL,"~Unbilled MCO/Ticket Report   ")
   PromptAdd(hReportMenu,R_UNPAID,"Un~paid MCO/Ticket Report   ")
   PromptAddLine(hReportMenu)
   PromptAddSub(hReportMenu,R_SALES,hSubSales)
   PromptAdd(hReportMenu,R_ALL,"~Yearly Summary/Percentage  ")
   PromptAdd(hReportMenu,R_AIR,"~Airline Summary  ")
   PromptAdd(hReportMenu,R_COMPARE,"~Comparative Summary  ")
   PromptAdd(hSubSales,R_MONTH,"~Monthly Report  ")
   PromptAdd(hSubSales,R_QUARTER,"~Quarterly Report  ")
   PromptAdd(hSubSales,R_YEAR,"~Yearly Report  ")
   PromptAdd(hSubSales,R_PERIOD,"~Periodic Report  ")

   // Maint Menu
   PromptAdd(hMaintMenu,M_BACKUP, "~Backup   ")
   PromptAdd(hMaintMenu,M_RESTORE,"~Restore  ")
   PromptAdd(hMaintMenu,M_REINDEX,"Re~Index  ")
   PromptAdd(hMaintMenu,M_UPDATE,"~Update Billings  ")
   // Add menus to menubar
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
   wAbout:=OpenWindow(07,19,16,60,"About BSP")
   @ 09,21 say "   Bank Settlement Plan System ver2   "
   @ 10,21 say "                                      "
   @ 11,21 say "            Developed for             "
   @ 12,21 say "          Super Travel, Inc.          "
   @ 13,21 say "                 by                   "
   @ 14,21 say "         Rolando C. Ibarra Jr.        "
   @ 15,21 say "          August 17, 1993             "
   Inkey(0)
   CloseWindow(wAbout)
return nil

function OpenBSP(nFnum)
    do case
       case nFnum==1
          if NetUSe("MCO",DB_SHARED,NUM_SECONDS)
             set index to MCO,MCOPAX,MCOTKT
             set order to TKT_NDX
          endif
       case nFnum==2
          if NetUSe("SERIES2",DB_SHARED,NUM_SECONDS)
             set index to SERIES2,SERIES2P,SERIES2T
             set order to TKT_NDX
          endif
       case nFnum==3
          if NetUSe("SERIES4",DB_SHARED,NUM_SECONDS)
             set index to SERIES4,SERIES4P,SERIES4T
             set order to TKT_NDX
          endif
       case nFnum==4
          if NetUSe("APOLLO",DB_SHARED,NUM_SECONDS)
             set index to APOLLO,APOLLOP,APOLLOT
             set order to TKT_NDX
          endif
       case nFnum==5
          if NetUSe("ABACUS",DB_SHARED,NUM_SECONDS)
             set index to ABACUS,ABACUSP,ABACUST
             set order to TKT_NDX
          endif
    endcase
return (Alias())

//EOF : <BSP.PRG> //
