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
#include "c501_mod.ch"

#define DATA_PATH   "d:\csdata\;d:\vchrdata"
#define F_LAND      110
#define F_AIR       120
#define F_ROOM      130
#define F_EXIT      160
#define C_PACKAGE   210
#define C_ROOM      220
#define R_LAND      410
#define R_AIR       420
#define R_ROOM      430
#define R_CPACK     440
#define R_CROOM     450
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
   Heading("Super Travel, Inc. - Costing Software")
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
         Set(_SET_CANCEL,.T.)
         do case
           case nChoice==A_ABOUT
              About()                        // About the system.
*           case nChoice==A_HELP
*              Ctv_Help()
           case nChoice==F_LAND
              use land
              do_land(.F.)
              select land
              pack
              close land
           case nChoice==F_AIR
              use air
              do_air(.F.)
              select air
              pack
              close air
           case nChoice==C_PACKAGE
              do_pkg()
           case nChoice==C_ROOM
              do_room()
           case nChoice==R_LAND
              Land_Report()
           case nChoice==R_AIR
              Air_Report()
           case nChoice==R_ROOM
              Room_Report()
           case nChoice==R_CPACK
              Print_Pack()
           case nChoice==R_CROOM
              Print_Room()
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
   ? "Exit from Costing Software..."
   ?
return nil

static function CreateBar()
   // Create empty bar menu
   hBar := BarNew()
   // Create empty menus
   hAboutMenu := MenuNew(chr(240))
   hTariffMenu:= MenuNew("~Tariff")
   hCostmenu  := MenuNew("~Costing")
   hReportMenu:= MenuNew("~Reports")
   hMaintMenu := MenuNew("~Maint")
   // Add prompts
   // About Menu
   PromptAdd( hAboutMenu,A_ABOUT,"~About CTV  ")
*  PromptAdd( hAboutMenu,A_HELP ,"~Help       ")
   // Files Menu
   PromptAdd( hTariffMenu,F_LAND , "~Land Tariff      ")
   PromptAdd( hTariffMenu,F_AIR  , "~Air Tariff       ")
*  PromptAdd( hTariffMenu,F_ROOM , "~Room Tariff      ")
   PromptAddLine(hTariffMenu)
   PromptAdd(hTariffMenu,F_EXIT, "E~xit      Alt-X  ")
   // Costing Menu
   PromptAdd(hCostMenu,C_PACKAGE, "~Package Costing  ")
   PromptAdd(hCostMenu,C_ROOM, "~Room Costing  ")
   // Report Menu
   PromptAdd(hReportMenu,R_LAND  ,"~Land Tariff ")
   PromptAdd(hReportMenu,R_AIR   ,"~Air Tariff  ")
   PromptAdd(hReportMenu,R_ROOM  ,"~Room Tariff ")
   PromptAddLine(hReportMenu)
   PromptAdd(hReportMenu,R_CPACK ,"~Package Costing  ")
   PromptAdd(hReportMenu,R_CROOM ,"~Room Costing  ")
   // Maint Menu
   PromptAdd(hMaintMenu,M_BACKUP, "~Backup   ")
   PromptAdd(hMaintMenu,M_RESTORE,"~Restore  ")
   PromptAddLine(hMaintMenu)
   PromptAdd(hMaintMenu,M_HOTEL, "~Hotel    ")
   PromptAdd(hMaintMenu,M_AGENCY,"~Agency   ")
   // Add menus to menubar
   MenuAdd(hBar,hAboutMenu)
   MenuAdd(hBar,hTariffMenu)
   MenuAdd(hBar,hCostMenu)
   MenuAdd(hBar,hReportMenu)
   MenuAdd(hBar,hMaintMenu)
   // Add quick key or shortcuts
   PromptQuickKey(hbar,hTariffMenu,F_EXIT,K_ALT_X)
return nil

static function About()
local wAbout
   Message("Press any key to continue....")
   wAbout:=OpenWindow(07,19,16,60,"About CS")
   @ 09,21 say "    Super Travel - Costing Software   "
   @ 10,21 say "                                      "
   @ 11,21 say "           Developed for              "
   @ 12,21 say "         Super Travel, Inc.           "
   @ 13,21 say "                by                    "
   @ 14,21 say "        Rolando C. Ibarra Jr.         "
   @ 15,21 say "           May 28, 1993               "
   Inkey(0)
   CloseWindow(wAbout)
return nil

function Get_USD(cCurr)
local wUSD
   cUsdOp := "D"   ; nUsdRate := 0.00
   Message("Enter Dollar Rates....")
   wDate:=OpenWindow(08,25,14,55,"Dollar Convertion Box")
   @ 10,27 say "  Currency :" + cCurr
   @ 11,27 say "      Rate :" get nUsdRate pict "99.99"
   @ 12,27 say " Operation :" get cUsdOp   pict "!"
   @ 13,27 say "  (D-Divide, M-Multiply)"
   SetCursor(SC_NORMAL)
   read
   SetCursor(SC_NONE)
   CloseWindow(wDate)
return (Lastkey()!=K_ESC)

function ToUsd(nValue)
return  (if(cUsdOp == 'D',nValue/nUsdRate,nValue*nUsdRate))

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