// Filename:      COSTING.PRG
// System-Name:   Super Travel Costing Software
// Module:        Main Menu
// Author:        Rollie C. Ibarra Jr.
// Date-Started:  Sept 18, 1993
// Last-Update:   Sept 18, 1993

#include "OMenu.ch"
#include "Inkey.ch"
#include "SetCurs.ch"
#include "Set.ch"
#include "MemoEdit.ch"
#include "Mode.ch"
#include "Help.ch"
#include "c501_mod.ch"

#define DATA_PATH   "d:\vchrdata\;d:\csdata"
#define V_TOUR      310
#define V_PAYS      320
#define V_EXIT      330
#define M_REINDEX   510
#define M_BACKUP    520
#define M_RESTORE   540
#define M_HOTEL     550
#define M_AGENCY    560
#define A_ABOUT     910
#define A_HELP      920

static hBar,hTariffMenu,hCostMenu,hVoucherMenu,hReportMenu,hMaintMenu,hAboutMenu

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
   Set(_SET_CANCEL,.F.)
   SetCursor(SC_NONE)
   ReadInsert(.T.)
   nOx:=col()   ;   nOy:=row()
   cOriginal:=SetColor()
   wOriginal:=BkgndScreen()
   Heading("Super Travel, Inc. - Tour Voucher Software")
   SetColor(DATA_COLORS)
   Sti_Logo()
   SetCursor(SC_NONE)
   CreateBar()
   BarDisplay(hBar)
   About()
   Message("F10-Menu   Arrow Keys-Navigate   Enter-Select   Alt+X-Exit")
   BarActivate(hBar,lastkey())
   nChoice:=BarMenuChoice(hBar)
   do while nChoice!=V_EXIT
      if LastKey()!=K_ESC
         Set(_SET_CANCEL,.T.)
         do case
           case nChoice==A_ABOUT
              About()                        // About the system.
           case nChoice==V_TOUR
              Do_Voucher()
           case nChoice==V_PAYS
              TourPay()
           case nChoice==M_BACKUP
              CopyFile(1)
         case nChoice==M_RESTORE
              CopyFile(2)
           case nChoice==M_HOTEL
              use Hotel index Hotel new
              HOTEL->(DbBrowser(05,10,19,70,"Hotel File",.F.))
              HOTEL->(DbCloseArea())
           case nChoice==M_AGENCY
              use Agency index Agency new
              AGENCY->(DbBrowser(05,10,19,70,"Agency File",.F.))
              AGENCY->(DbCloseArea())
         endcase
         Set(_SET_CANCEL,.F.)
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
   ? "Exit from Tour Voucher Software..."
   ?
return nil

static function CreateBar()
   // Create empty bar menu
   hBar:=BarNew()
   // Create empty menus
   hAboutMenu:=MenuNew(chr(240))
   hVoucherMenu:=MenuNew("~Voucher")
   hMaintMenu:=MenuNew("~Maint")
   // Add prompts
   // About Menu
   PromptAdd(hAboutMenu,A_ABOUT,"~About VCHR  ")
   // Voucher menu
   PromptAdd(hVoucherMenu,V_TOUR , "~Tour Voucher   ")
   PromptAdd(hVoucherMenu,V_PAYS , "~Payables   ")
   PromptAddLine(hVoucherMenu)
   PromptAdd(hVoucherMenu,V_EXIT, "E~xit      Alt-X  ")
   // Maint Menu
   PromptAdd(hMaintMenu,M_BACKUP, "~Backup   ")
   PromptAdd(hMaintMenu,M_RESTORE,"~Restore  ")
   PromptAddLine(hMaintMenu)
   PromptAdd(hMaintMenu,M_HOTEL, "~Hotel    ")
   PromptAdd(hMaintMenu,M_AGENCY,"~Agency   ")
   // Add menus to menubar
   MenuAdd(hBar,hAboutMenu)
   MenuAdd(hBar,hVoucherMenu)
   MenuAdd(hBar,hMaintMenu)
   // Add quick key or shortcuts
   PromptQuickKey(hbar,hVoucherMenu,V_EXIT,K_ALT_X)
return nil

static function About()
local wAbout
   Message("Press any key to continue....")
   wAbout:=OpenWindow(07,19,16,60,"About VCHR")
   @ 09,21 say " Super Travel - Tour Voucher Software "
   @ 10,21 say "                                      "
   @ 11,21 say "           Developed for              "
   @ 12,21 say "         Super Travel, Inc.           "
   @ 13,21 say "                by                    "
   @ 14,21 say "       Rolando C. Ibarra Jr.          "
   @ 15,21 say "        September 18, 1993            "
   Inkey(0)
   CloseWindow(wAbout)
return nil

function Agent_Look()
local wAgent,aAgent:={}
   nDbf := Select()
   lClose := .F.
   if Select("AGENCY") == 0
      lClose := .T.
      use AGENCY index AGENCY new
   endif
   AGENCY->(DBGoTop())
   do while AGENCY->(!Eof())
      AAdd(aAgent,AGENCY->AGENT_CODE + "   " + AGENCY->AGENT)
      AGENCY->(DbSkip())
   enddo
   wAgent:=OpenWindow(05,40,19,78,"Agency LookUp")
   AChoice(07,41,18,77,aAgent)
   CloseWindow(wAgent)
   if lClose
      AGENCY->(DbCloseArea())
   endif
   Select (nDbf)
return nil

function Hotel_Look()
local wHotel,aHotel:={}
   nDbf := Select()
   lClose := .F.
   if Select("HOTEL") == 0
      lClose := .T.
      use HOTEL index HOTEL new
   endif
   HOTEL->(DBGoTop())
   do while HOTEL->(!Eof())
      AAdd(aHotel,HOTEL->HOTEL_CODE + "   " + HOTEL->HOTEL)
      HOTEL->(DbSkip())
   enddo
   wHotel:=OpenWindow(05,40,19,78,"Hotel LookUp")
   AChoice(07,41,18,77,aHotel)
   CloseWindow(wHotel)
   if lClose
      HOTEL->(DbCloseArea())
   endif
   Select (nDbf)
return nil

// end-of-file
