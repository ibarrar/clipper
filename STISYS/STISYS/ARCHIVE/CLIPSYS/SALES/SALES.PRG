/************************************************/
/* Filename:      PO.PRG                        */
/* System-Name:   Purchase Order Filing Program */
/* Module:        Main Program                  */
/* Author:        Arnold P. Caoile              */
/* Date-Started:  February 15, 1992             */
/* Last-Update:   February 24, 1992             */
/************************************************/

#include "Inkey.ch"
#include "Setcurs.ch"

#define F_PO        110
#define F_EXIT      120
#define R_REPORT    210
#define R_SALES     220
#define R_SUMMARY   230
#define M_BACKUP    310
#define M_RESTORE   320
#define A_ABOUT     910
#define DATA_COLORS "N/W,N/BG"
#define DATA_PATH   "D:\PODATA\"
#define APPEND_MODE   1
#define EDIT_MODE     2
#define VIEW_MODE     3
#define DELETE_MODE   4
#define CANCEL_MODE   5
#define PESO_MODE     1
#define DOLLAR_MODE   2

static hBar,hFileMenu,hAboutMenu,hReportsMenu,hMaintMenu

function PurchaseOrder()
local wPO,nChoice,exitRequested:=.F.
public mAgent
   Set(_SET_SCOREBOARD,.F.)
   Set(_SET_PATH,DATA_PATH)
   Set(_SET_WRAP,.T.)
   Set(_SET_DELETED,.T.)
   Set(_SET_DATEFORMAT,"MM-DD-YY")
   wPO:=BkgndScreen()
   Heading("Super Travel, Inc. - Agency Sales Report Program ")
   Sti_Logo()
   SetColor(DATA_COLORS)
   SetCursor(SC_NONE)
   CreateBar()
   BarDisplay(hBar)
   About()
   Message("F10-Main Menu   Alt X-Exit")
   BarActivate(hBar,LastKey())
   nChoice:=BarMenuChoice(hBar)
   do while nChoice!=F_EXIT
      if LastKey()!=K_ESC
         do case
            case nChoice==A_ABOUT     ; About()
            case nChoice==F_PO        ; Do_PO()
            case nChoice==R_SALES     ; Report()
            case nChoice==R_SUMMARY   ; Summary()
            case nChoice==M_BACKUP    ; Backup()
            case nChoice==M_RESTORE   ; Restore()
         endcase
      endif
      Message("F10-Main Menu   Alt X-Exit")
      BarActivate(hBar)
      nChoice:=BarMenuChoice(hBar)
   enddo
   RestoreScreen(wPO)
   SetCursor(SC_NORMAL)
return nil

static function CreateBar()
   // Create empty bar menu
   hBar:=BarNew()
   // Create empty menus
   hAboutMenu:=MenuNew("ð")
   hFileMenu:=MenuNew("~File")
   hReportsMenu:=MenuNew("~Reports")
   hMaintMenu:=MenuNew("~Maint")
   // Add prompts
   // About Menu
   PromptAdd(hAboutMenu,A_ABOUT,   "~About  ")
   // File Menu
   PromptAdd(hFileMenu,F_PO,   "~Purchase Order")
   PromptAddLine(hFileMenu)
   PromptAdd(hFileMenu,F_EXIT,  "E~xit    Alt-X  ")
   // Reports Menu
*   PromptAdd(hReportsMenu,R_REPORT,   "Sales ~Report      ")
   PromptAdd(hReportsMenu,R_SALES,    "~Agency Sales      ")
   PromptAdd(hReportsMenu,R_SUMMARY,  "Sales ~Summary     ")
   // Maint Menu
   PromptAdd(hMaintMenu,M_BACKUP, "~Backup   ")
   PromptAdd(hMaintMenu,M_RESTORE,"~Restore  ")
   // Add menus to menubar
   MenuAdd(hBar,hAboutMenu)
   MenuAdd(hBar,hFileMenu)
   MenuAdd(hBar,hReportsMenu)
   MenuAdd(hBar,hMaintMenu)
   // Add quick key or shortcuts
   PromptQuickKey(hbar,hFileMenu,F_EXIT,K_ALT_X)
return nil

static function About()
local wAbout
   Message("Press any key to continue....")
   wAbout:=OpenWindow(07,20,16,59,"About Sales")
   @ 09 , 21 say "       Purchase Order Program         "
   @ 10 , 21 say "                                      "
   @ 11 , 21 say "            Developed for             "
   @ 12 , 21 say "          Super Travel, Inc.          "
   @ 13 , 21 say "                 by                   "
   @ 14 , 21 say "       Rollie Castro Ibarra Jr.       "
   @ 15 , 21 say "          November 20, 1993           "
   inkey(0)
   CloseWindow(wAbout)
return nil

function ConvertDate(cStrDate)
local cMonth,MM,DD,YY
   cMonth:=SubStr(cStrDate,3,3)
   do case
      case cMonth=="JAN" ; MM:="01"
      case cMonth=="FEB" ; MM:="02"
      case cMonth=="MAR" ; MM:="03"
      case cMonth=="APR" ; MM:="04"
      case cMonth=="MAY" ; MM:="05"
      case cMonth=="JUN" ; MM:="06"
      case cMonth=="JUL" ; MM:="07"
      case cMonth=="AUG" ; MM:="08"
      case cMonth=="SEP" ; MM:="09"
      case cMonth=="OCT" ; MM:="10"
      case cMonth=="NOV" ; MM:="11"
      case cMonth=="DEC" ; MM:="12"
      otherwise  ;  MM := space(3)
   endcase
   DD:=SubStr(cStrDate,1,2)
   YY:=SubStr(cStrDate,6,2)
return  CToD(MM+"/"+DD+"/"+YY)

function DateConvert(date)
    if date == ctod("  -  -  ")
       return space(7)
    endif
    mo:=substr(dtoc(date),1,2)
    yr:=substr(dtoc(date),7,2)
    dy:=substr(dtoc(date),4,2)
    do case
      case mo=='01'     ;   mo:='JAN'
      case mo=='02'     ;   mo:='FEB'
      case mo=='03'     ;   mo:='MAR'
      case mo=='04'     ;   mo:='APR'
      case mo=='05'     ;   mo:='MAY'
      case mo=='06'     ;   mo:='JUN'
      case mo=='07'     ;   mo:='JUL'
      case mo=='08'     ;   mo:='AUG'
      case mo=='09'     ;   mo:='SEP'
      case mo=='10'     ;   mo:='OCT'
      case mo=='11'     ;   mo:='NOV'
      case mo=='12'     ;   mo:='DEC'
    endcase
return (dy+mo+yr)

function sti_logo()
   setcolor("R/B")
   @ 02, 00 say ""
   @ row()+1,0 say "   ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿                                           "
   @ row()+1,0 say "   ³            ÜÜÜÜÜ          ÃÄ¿                                         "
   @ row()+1,0 say "   ³          ÜÛÛÛÛÛÛÛÜ        ³ ³   ÜÜÜÜ  ÜÜ  ÜÜ ÜÜÜÜÜ  ÜÜÜÜÜ ÜÜÜÜÜ       "
   @ row()+1,0 say "   ³     ÜÜÜ  ßÛÛÛÛÛÛÛß        ³ ³  ÛÛ  ßß ÛÛ  ÛÛ ÛÛ  ÛÛ ÛÛ    ÛÛ  ÛÛ      "
   @ row()+1,0 say "   ³    ÛÛÛÛÛÜ  ßßßßß          ³ ³   ßÛÛÜ  ÛÛ  ÛÛ ÛÛÜÜÛß ÛÛÜÜ  ÛÛÜÜÛß      "
   @ row()+1,0 say "   ³     ßÛÛÛÛÛÜ               ³ ³  ÜÜ  ÛÛ ÛÛ  ÛÛ ÛÛ     ÛÛ    ÛÛ  ÛÛ      "
   @ row()+1,0 say "   ³       ßÛÛÛÛÛÜ             ³ ³   ßßßß   ßßßß  ßß     ßßßßß ßß  ßß      "
   @ row()+1,0 say "   ³     ÜÜÜ ßÛÛÛÛÛÜ           ³ ³  ÜÜÜÜÜÜ ÜÜÜÜÜ   ÜÜÜÜ  ÜÜ  ÜÜ ÜÜÜÜÜ ÜÜ   "
   @ row()+1,0 say "   ³    ÛÛÛÛÛÜ ßÛÛÛÛÛÜ         ³ ³    ÛÛ   ÛÛ  ÛÛ ÛÛ  ÛÛ ÛÛ  ÛÛ ÛÛ    ÛÛ   "
   @ row()+1,0 say "   ³     ßÛÛÛÛÛÜ ßÛÛÛÛÛÜ       ³ ³    ÛÛ   ÛÛÜÜÛß ÛÛÜÜÛÛ ÛÛ  ÛÛ ÛÛÜÜ  ÛÛ   "
   @ row()+1,0 say "   ³       ßÛÛÛÛÛÜ ßÛÛÛÛÛÜ     ³ ³    ÛÛ   ÛÛ  ÛÛ ÛÛ  ÛÛ  ÛÜÜÛ  ÛÛ    ÛÛ   "
   @ row()+1,0 say "   ³         ßÛÛÛÛÛÜ ßÛÛÛÛÛ    ³ ³    ßß   ßß  ßß ßß  ßß   ßß   ßßßßß ßßßßß"
   @ row()+1,0 say "   ³           ßÛÛÛÛÛÜ ßßß     ³ ³   ÜÜÜÜ ÜÜ  ÜÜ  ÜÜÜÜ                     "
   @ row()+1,0 say "   ³             ßÛÛÛÛÛÜ       ³ ³    ÛÛ  ÛÛÛ ÛÛ ÛÛ  ÛÛ                    "
   @ row()+1,0 say "   ³               ßÛÛÛÛÛÜ     ³ ³    ÛÛ  ÛÛ ÛÛÛ ÛÛ                        "
   @ row()+1,0 say "   ³          ÜÜÜÜÜ  ßÛÛÛÛÛ    ³ ³    ÛÛ  ÛÛ  ÛÛ ÛÛ  ÛÛ                    "
   @ row()+1,0 say "   ³        ÜÛÛÛÛÛÛÛÜ  ßßß     ³ ³   ßßßß ßß  ßß  ßßßß  ß                  "
   @ row()+1,0 say "   ³        ßÛÛÛÛÛÛÛß          ³ ³                                         "
   @ row()+1,0 say "   ³          ßßßßß            ³ ³                                         "
   @ row()+1,0 say "   ÀÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ ³                                         "
   @ row()+1,0 say "     ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ                                         "
return nil

function GetAgent()
local n,wAgent,nRow,cColor,aAgent:={}
   AGENCY->(DBGoTop())
   do while AGENCY->(!Eof())
      AAdd(aAgent,AGENCY->AGENT_CODE + "   " + AGENCY->AGENCY)
      AGENCY->(DbSkip())
   enddo
   Message("Use cursor keys to move highlight, press ENTER to select.")
   wAgent:=OpenWindow(05,40,19,78,"Agency LookUp")
   n:=AChoice(06,41,18,77,aAgent)
   CloseWindow(wAgent)
   if (LastKey()!=K_ESC) .and. (n>0)
      mAgent:=substr(aAgent[n],1,3)
   endif
return nil

//end-of-file
// end-of-file
