// Filename:      GL.PRG
// System-Name:   Accounting System (General Ledger & Financial Statement)
// Module:        Main Menu
// Author:        Arnold P. Caoile
// Date-Started:  April 02, 1992
// Last-Update:   June 29, 1992

#include "OMenu.ch"
#include "Inkey.ch"
#include "SetCurs.ch"
#include "Set.ch"
#include "MemoEdit.ch"
#include "Mode.ch"
#include "Help.ch"
#include "C501_mod.ch"

#define DATA_PATH   "d:\GLDATA\"
#define B_CDB       110
#define B_CRB       120
#define B_SB        130
#define B_EXIT      140
#define V_PCV       210
#define V_JV        220
#define S_ARTI      305
#define S_ARTA      310
#define S_ARA       315
#define S_ARO       320
#define S_AP        325
#define S_APO       330
#define S_PRI       335
#define S_PRA       340
#define S_AE        345
#define FS_IS       410
#define FS_BS       420
#define FS_AS       430
#define FS_SUM      440
#define FS_SCHED    450
#define M_DATABASE  510
#define M_BACKUP    520
#define M_RESTORE   530
#define M_CHART     540
#define M_AIRLINES  550
#define M_AGENCY    560
#define A_ABOUT     610
#define A_HELP      620
#define R_CDB       710
#define R_CRB       720
#define R_SB        730
#define R_JV        740
#define R_PCV       750

static hBar,hBookMenu,hVoucherMenu,hSchedMenu,hFSMenu,hMaintMenu,hAboutMenu,hReportMenu
static hSubDbase

// Main program.
function GL()
local nChoice
local wOriginal,exitRequested:=.F.
public mAirline,mAcctCode,mAgent,mAirCode,dStartDate,dEndDate,cOutput,cReport,nLFactor:=1
public cCurrYear,cPrevYear,nCurrDebit,nCurrCredit,nPrevDebit,nPrevCredit
public aCodes:={},aCurrAccts:={},aPrevAccts:={},aCurrMonth:={},aPrevMonth:={}
public aLedgerCode:={"01-121","01-122","01-131","01-142","04-131","04-141","04-181","04-171"}
public aLedgerName:={   "ART",   "ARA",   "ARO",   "AFP",   "APO",   "AEX",    "PR",   "ART"}
   Set(_SET_SCOREBOARD,.F.)
   Set(_SET_WRAP,.T.)
   Set(_SET_PATH,DATA_PATH)
   Set(_SET_DATEFORMAT,"mm-dd-yy")
   Set(_SET_DELETED,.T.)
   Set(_SET_EXACT,.F.)
   nOx:=col();   nOy:=row()
   SetCursor(SC_NONE)
   ReadInsert(.T.)
   cOriginal:=SetColor()
   wOriginal:=BkgndScreen()
   tone(523,2);tone(698,2);tone(880,2);tone(1046,4);tone(880,2);tone(1046,7)
   Sti_Logo()
   Heading("Super Travel, Inc. - Accounting System")
   SetColor(DATA_COLORS)
   CreateBar()
   SetCursor(SC_NONE)
   BarDisplay(hBar)
   About()
   Message("F10-Menu  "+chr(27)+chr(18)+chr(26)+"-Navigate   Enter"+chr(17)+chr(217)+"-Select  Alt+X-Exit")
   BarActivate(hBar,LastKey())
   nChoice:=BarMenuChoice(hBar)
   do while nChoice!=B_EXIT
      if LastKey()!=K_ESC
         Set(_SET_CANCEL,.T.)
         do case
           case nChoice==A_ABOUT
              About()                        // About the system.
           case nChoice==B_CDB
              CDB()                          // Cash Disbursement Book.
           case nChoice==B_CRB
              CRB()                          // Cash Receipt Book.
           case nChoice==B_SB
              SB()                           // Sales Book.
           case nChoice==V_PCV
              PCV()                          // Petty Cash Vouchers.
           case nChoice==V_JV
              JV()                           // Journal Vouchers.
           case nChoice==S_ARTI
              Ledger("ARTI","ARTITRAN", ;
                 "Accounts Receivable - Travel (Individual)")
           case nChoice==S_ARTA
              Ledger2("ARTA","ARTATRAN", ;
                 "Accounts Receivable - Travel (Agency)")
           case nChoice==S_ARA
              Ledger2("ARA","ARATRAN", ;
                 "Accounts Receivable - Airlines")
           case nChoice==S_ARO
              Ledger("ARO","AROTRAN", ;
                 "Accounts Receivable - Others")
           case nChoice==S_AP
              Ledger("AFP","AFPTRAN", ;
                 "Advances for Passengers")
           case nChoice==S_APO
              Ledger("APO","APOTRAN", ;
                 "Accounts Payable - Others")
           case nChoice==S_PRI
              Ledger("PRI","PRITRAN", ;
                 "Passenger Refund (Individual)")
           case nChoice==S_PRA
              Ledger2("PRA","PRATRAN", ;
                 "Passenger Refund (Agency)")
           case nChoice==S_AE
              Ledger("AEX","AEXTRAN", ;
                 "Accrued Expenses")
           case nChoice==FS_AS
              PrintAS()                      // Assembly Sheet.
           case nChoice==FS_BS
              PrintBS()                      // Balance Sheet.
           case nChoice==FS_IS
              PrintIS()                      // Income Statement.
           case nChoice==FS_SUM
              UpdateAccts()                  // Accounts Summary
           case nChoice==FS_SCHED
              Sched()                        // Schedule of Acccounts
           case nChoice==R_CDB
              CDB_Summary()
           case nChoice==R_CRB
              CRB_Summary()
           case nChoice==R_SB
              SB_Summary()
           case nChoice==R_JV
              JV_Summary()
           case nChoice==R_PCV
              PCV_Summary()
           case nChoice==M_BACKUP
              CopyFile(1)                    // Backup Databases.
           case nChoice==M_RESTORE
              CopyFile(2)                    // Restore Databases.
           case nChoice==M_CHART
              NetUse("CHART",DB_SHARED,NUM_SECONDS)
              CHART->(DbBrowse(03,02,21,77,"Chart of Accounts",.F.))
              Message("Reindexing Chart of Accounts....")
              index on SubStr(CHART->ACCT_CODE,1,5) to &(DATA_PATH+"CHT_CODE")
              index on CHART->ACCT_TITLE to &(DATA_PATH+"CHART")
              index on CHART->ACCT_CODE to &(DATA_PATH+"CHT_ACCT")
              CHART->(DbCloseArea())
           case nChoice==M_AIRLINES
              NetUse("AIRLINE",DB_SHARED,NUM_SECONDS)
              AIRLINE->(DbBrowse(03,02,21,77,"Airlines",.F.))
              Message("Reindexing Airline Database....")
              index on AIRLINE->AIRLINE to &(DATA_PATH+"AIRLINE")
              index on AIRLINE->AIR_CODE to &(DATA_PATH+"AIR_CODE")
              AIRLINE->(DbCloseArea())
           case nChoice==M_AGENCY
              NetUse("AGENCY",DB_SHARED,NUM_SECONDS)
              AGENCY->(DbBrowse(03,02,21,77,"Agencies",.F.))
              Message("Reindexing Agency Database....")
              index on AGENCY->AGENT_NAME to &(DATA_PATH+"AGENCY")
              AGENCY->(DbCloseArea())
         endcase
         Set(_SET_CANCEL,.F.)
      endif
      Message("F10-Menu  "+chr(27)+chr(18)+chr(26)+"-Navigate   Enter"+chr(17)+chr(217)+"-Select  Alt+X-Exit")
      nChoice:= 0
      BarActivate(hBar)
      nChoice:=BarMenuChoice(hBar)
   enddo
   ReadInsert(.F.)
   SetCursor(SC_NORMAL)
   SetColor(cOriginal)
   clear screen
   Set(_SET_EXACT,.T.)
   Set(_SET_DELETED,.F.)
   Set(_SET_SCOREBOARD,.T.)
   RestoreScreen(wOriginal)
   @ nOy, nOx say ""
   ? "Exit from General Ledger & Financial System 1.01..."
   ?
return nil

static function CreateBar()
   // Create empty bar menu
   hBar:=BarNew()
   // Create empty menus
   hAboutMenu:=MenuNew(chr(240))
   hBookMenu:=MenuNew("~Books")
   hVoucherMenu:=MenuNew("~Vouchers")
   hReportMenu:=MenuNew("~Reports")
   hSchedMenu:=MenuNew("~Ledger")
   hFSMenu:=MenuNew("~FS")
   hMaintMenu:=MenuNew("~Maint")
   hSubDbase:=MenuNew("~Databases")
   // Add prompts
   // About Menu
   PromptAdd(hAboutMenu,A_ABOUT,"~About GL  ")
   PromptAddLine(hAboutMenu)
   PromptAdd(hAboutMenu,B_EXIT, "E~xit  Shft-X  ")
   // Books Menu
   PromptAdd(hBookMenu,B_CDB, "Cash ~Disbursement Book  ")
   PromptAdd(hBookMenu,B_CRB, "Cash ~Revenue Book       ")
   PromptAdd(hBookMenu,B_SB,  "~Sales Book              ")
*   PromptAddLine(hBookMenu)
*   PromptAdd(hBookMenu,B_EXIT,"E~xit             Alt-X  ")
   // Vouchers Menu
   PromptAdd(hVoucherMenu,V_PCV,"~Petty Cash Voucher  ")
   PromptAdd(hVoucherMenu,V_JV, "~Journal Voucher     ")
   // Reports Menu
   PromptAdd(hReportMenu,R_CDB, "Cash ~Disbursement Book  ")
   PromptAdd(hReportMenu,R_CRB, "Cash ~Revenue Book  ")
   PromptAdd(hReportMenu,R_SB,  "~Sales Book  ")
   PromptAdd(hReportMenu,R_PCV,"~Petty Cash Voucher  ")
   PromptAdd(hReportMenu,R_JV, "~Journal Voucher     ")
   // Sched Menu
   PromptAdd(hSchedMenu,S_ARTI,  "A/R Travel (Individual)  ")
   PromptAdd(hSchedMenu,S_ARTA,  "A/R Travel (Agency)      ")
   PromptAdd(hSchedMenu,S_ARA,   "A/R Airlines             ")
   PromptAdd(hSchedMenu,S_ARO,   "A/R Others               ")
   PromptAdd(hSchedMenu,S_AP,    "Advances for Pax         ")
   PromptAdd(hSchedMenu,S_APO,   "A/P Others               ")
   PromptAdd(hSchedMenu,S_PRI,   "Pax Refund (Individual)  ")
   PromptAdd(hSchedMenu,S_PRA,   "Pax Refund (Agency)      ")
   PromptAdd(hSchedMenu,S_AE,    "Accrued Expenses         ")
   // FS Menu
   PromptAdd(hFSMenu,FS_AS,   "~Assembly Sheet       ")
   PromptAdd(hFSMenu,FS_BS,   "~Balance Sheet        ")
   PromptAdd(hFSMenu,FS_IS,   "~Income Statement     ")
   PromptAddLine(hFSMenu)
   PromptAdd(hFSMenu,FS_SUM,"Su~mmary of Accounts  ")
   PromptAdd(hFSMenu,FS_SCHED,"~Schedule of Accounts  ")
   // Maint Menu
   PromptAddSub(hMaintMenu,M_DATABASE,hSubDbase)
   PromptAdd(hSubDbase,M_BACKUP, "~Backup   ")
   PromptAdd(hSubDbase,M_RESTORE,"~Restore  ")
   PromptAddLine(hMaintMenu)
   PromptAdd(hMaintMenu,M_AIRLINES,"Air~lines           ")
   PromptAdd(hMaintMenu,M_AGENCY,  "~Agencies           ")
   PromptAdd(hMaintMenu,M_CHART,   "~Chart of Accounts  ")
   // Add menus to menubar
   MenuAdd(hBar,hAboutMenu)
   MenuAdd(hBar,hBookMenu)
   MenuAdd(hBar,hVoucherMenu)
   MenuAdd(hBar,hReportMenu)
   MenuAdd(hBar,hSchedMenu)
   MenuAdd(hBar,hFSMenu)
   MenuAdd(hBar,hMaintMenu)
   // Add quick key or shortcuts
   PromptQuickKey(hbar,hAboutMenu,B_EXIT,K_ALT_X)
*   PromptQuickKey(hBar,hAboutMenu,A_HELP,K_F1)
return nil

static function About()
local wAbout
   Message("Press any key to continue....")
   wAbout:=OpenWindow(07,19,17,60,"About GL")
   @ 09,21 say "         Accounting System            "
   @ 10,21 say "(General Ledger & Financial Statement)"
   @ 11,21 say "          (Version 1.01)              "
   @ 12,21 say "           Developed for              "
   @ 13,21 say "         Super Travel, Inc.           "
   @ 14,21 say "                by                    "
   @ 15,21 say "        Rollie C. Ibarra Jr.          "
   @ 16,21 say "           June 9, 1993               "
   @ 08,19 to 17,60 double
   Inkey(0)
   CloseWindow(wAbout)
return nil

function GetHelp(nHelpIndex)
local wHelp,cTitle
   Message("Press any key to continue....")
   do case
      case nHelpIndex==H_CDB ; cTitle:="Cash Disbursement Book"
      case nHelpIndex==H_CRB ; cTitle:="Cash Receipts Book"
      case nHelpIndex==H_SB  ; cTitle:="Sales Book"
      case nHelpIndex==H_PCV ; cTitle:="Petty Cash Vouchers"
      case nHelpIndex==H_JV  ; cTitle:="Journal Vouchers"
   endcase
   wHelp:=OpenWindow(05,15,21,64,"Help for "+cTitle)
   Inkey(0)
   CloseWindow(wHelp)
return nil

function GetDates()
local wDate
   dStartDate:=dEndDate:=CToD("  -  -  ")
   cOutput:="N"
   Message("Enter transaction dates, press Esc to abort.")
   wDate:=OpenWindow(09,15,14,63,"Date Information Box")
   @ 11,17 say "Enter starting date (MM/DD/YY format)" get dStartDate
   @ 12,17 say "        Ending date (MM/DD/YY format)" get dEndDate
   @ 13,17 say " Output report to line printer (Y,N)?" get cOutput picture "Y"
   SetCursor(SC_NORMAL)
   read
   SetCursor(SC_NONE)
   CloseWindow(wDate)
return If(LastKey()==K_ESC,.F.,.T.)

function GetBegBal()
local wBal
   cCurrYear:=Transform(Year(dEndDate),"9999")
   cPrevYear:=Transform(Year(dEndDate)-1,"9999")
   nCurrDebit:=nCurrCredit:=nPrevDebit:=nPrevCredit:=0.00
   Message("Enter transaction dates, press Esc to abort.")
   wBal:=OpenWindow(09,15,14,63,"Beginning Balance Information Box")
   @ 11,37 say "Debit          Credit"
   @ 12,17 say "December "+cCurrYear
   @ 12,34 get nCurrDebit picture "9,999,999.99"
   @ 12,49 get nCurrCredit picture "9,999,999.99"
   @ 13,17 say "December "+cPrevYear
   @ 13,34 get nPrevDebit picture "9,999,999.99"
   @ 13,49 get nPrevCredit picture "9,999,999.99"
   SetCursor(SC_NORMAL)
   read
   SetCursor(SC_NONE)
   CloseWindow(wBal)
return If(LastKey()==K_ESC,.F.,.T.)

function EditorFunc(nMode,nLine,nCol)
memvar initRow,initCol,initRelRow,initRelCol
local nRetVal,lKey,nKey,isReady,nLines,nCurrLine,n,nLineCtr:=0
   initRow:=nLine ; initCol:=nCol ; initRelRow:=Row()-1 ; initRelCol:=Col()-1
   if nMode==ME_IDLE
      SetCursor(SC_NONE)
      cColor:=SetColor("N/BG")
      @ 03,55 say "Line"+Transform(nLine,"9999")+"  Col"+;
        Transform(nCol+1,"9999")
      SetColor(cColor)
      SetCursor(SC_NORMAL)
   else
      lKey:=LastKey()
      do case
         case lKey==K_F10
            Message("Press ENTER to print report, ESC to abort....")
            nKey:=0
            do while (nKey!=K_ENTER) .and. (nKey!=K_ESC)
               nKey:=Inkey(0)
            enddo
            if nKey=K_ENTER
               isReady:=.F.
               do while (nKey!=K_ESC) .and. (!isReady)
                  isReady:=IsPrinter()
                  if isReady
                     Message("Insert 80 column form then press "+;
                        "ENTER to print.")
                     nKey:=0
                     do while nKey!=K_ENTER ; nKey:=Inkey(0) ; enddo
                     nLineCtr:=0
                     Message("Printing....please wait!")
                     Set(_SET_CONSOLE,.F.)
                     Set(_SET_PRINTER,.T.)
                     nLines:=MLCount(cReport,110)
                     ?? chr(27) + chr(120) + chr(1)   // select NLQ
                     ?? chr(27) + chr(107) + chr(0)   // select Roman
                     ?? chr(27) + chr(119) + chr(1)   // turn on Double heigth
                     for nCurrLine:=2 to 4
                        cLine:=MemoLine(cReport,110,nCurrLine)
                        ? cLine
                        ?
                     next
                     ?? chr(27) + chr(119) + chr(0)   // turn off Double heigth
                     for nCurrLine:=5 to nLines
                        cLine:=MemoLine(cReport,110,nCurrLine)
                        if nLineCtr>50
                           eject
                           nLineCtr:=0
                        endif
                        ? cLine
                        nLineCtr++
                     next
                     eject
                     Set(_SET_CONSOLE,.T.)
                     Set(_SET_PRINTER,.F.)
                     Set(_SET_ALTFILE,"")
                     Set(_SET_ALTERNATE,.F.)
                     close alternate
                  else
                     Message("Printer not ready....")
                     Tone(100,3)
                     Inkey(2)
                     Message("Press any key to retry, Esc to abort....")
                     nKey:=Inkey(0)
                     Message("")
                  endif
               enddo
            endif
            Message("Use cursor keys to navigate, press F10 to print, "+ ;
               "Esc to abort.")
         otherwise
            nRetVal:=ME_DEFAULT
      endcase
   endif
return nRetVal

function Print_Header()
    lPrt := Set(_SET_PRINTER,.T.)
    ?? chr(18)                       // select 10 pitch & normal size
    ?? chr(27) + chr(120) + chr(1)   // select NLQ
    ?? chr(27) + chr(107) + chr(0)   // select Roman
    ?? chr(27) + chr(87)  + chr(1)   // turn on Double width
    ?? chr(27) + chr(119) + chr(1)   // turn on Double heigth
    ? if(nLFactor==1,replicate('Э',41),replicate('Э',68))

    ?? chr(27) + chr(119) + chr(0)   // turn off Double heigth
    ?? chr(27) + chr(69)             // select Emphasized
    ?
    ? if(nLFactor==1,replicate(' ',11),replicate(' ',25))
    ?? "Super Travel, Inc."
    ?? chr(27) + chr(87)  + chr(0)   // turn off Double width
    ?? chr(15)                       // select Condensed
    ?? chr(27) + chr(70)             // cancel Emphasized
    ?  replicate(' ',46*nLFactor) + "             Ground Floor, VIP Building"
    ?  replicate(' ',46*nLFactor) + " 1154 Roxas Boulevard, Ermita, Manila, Philippines"
    ?  replicate(' ',46*nLFactor) + "       Tel. No. 59-60-02 to 05, 50-96-46 to 47 "
    ?? chr(18)                       // cancel Condensed
    ?
    ?? chr(27) + chr(87)  + chr(1)   // turn on Double width
    ?? chr(27) + chr(119) + chr(1)   // turn on Double heigth
    ? if(nLFactor==1,replicate('Э',41),replicate('Э',68))
    ?? chr(27) + chr(87)  + chr(0)   // turn off Double width
    ?? chr(27) + chr(119) + chr(0)   // turn off Double heigth
    ?
    ?
    set(_SET_PRINTER,lPrt)
return nil

function GetDateCode()
local wDate
   dStartDate:=dEndDate:=CToD("  /  /  ")
   mAcctCode:=Space(6)
   set key K_F10 to ChartLookUp()
   Message("")
   wDate:=OpenWindow(09,15,14,64,"Date Information Box")
   @ 11,17 say " Enter starting date (MM/DD/YY format)" get dStartDate
   @ 12,17 say "         Ending date (MM/DD/YY format)" get dEndDate
   @ 13,17 say "Account Code (Press F10 to list codes)" get mAcctCode
   SetCursor(SC_NORMAL)
   read
   SetCursor(SC_NONE)
   CloseWindow(wDate)
   set key K_F10 to
return If(LastKey()==K_ESC,.F.,.T.)

function sti_logo()
   setcolor("R/B")
   @ 02, 00 say ""
   @ row()+1,0 say "   кФФФФФФФФФФФФФФФФФФФФФФФФФФФП                                           "
   @ row()+1,0 say "   Г            ммммм          УФП                                         "
   @ row()+1,0 say "   Г          млллллллм        Г Г   мммм  мм  мм ммммм  ммммм ммммм       "
   @ row()+1,0 say "   Г     ммм  плллллллп        Г Г  лл  пп лл  лл лл  лл лл    лл  лл      "
   @ row()+1,0 say "   Г    лллллм  ппппп          Г Г   пллм  лл  лл ллммлп ллмм  ллммлп      "
   @ row()+1,0 say "   Г     плллллм               Г Г  мм  лл лл  лл лл     лл    лл  лл      "
   @ row()+1,0 say "   Г       плллллм             Г Г   пппп   пппп  пп     ппппп пп  пп      "
   @ row()+1,0 say "   Г     ммм плллллм           Г Г  мммммм ммммм   мммм  мм  мм ммммм мм   "
   @ row()+1,0 say "   Г    лллллм плллллм         Г Г    лл   лл  лл лл  лл лл  лл лл    лл   "
   @ row()+1,0 say "   Г     плллллм плллллм       Г Г    лл   ллммлп ллммлл лл  лл ллмм  лл   "
   @ row()+1,0 say "   Г       плллллм плллллм     Г Г    лл   лл  лл лл  лл  лммл  лл    лл   "
   @ row()+1,0 say "   Г         плллллм пллллл    Г Г    пп   пп  пп пп  пп   пп   ппппп ппппп"
   @ row()+1,0 say "   Г           плллллм ппп     Г Г   мммм мм  мм  мммм                     "
   @ row()+1,0 say "   Г             плллллм       Г Г    лл  ллл лл лл  лл                    "
   @ row()+1,0 say "   Г               плллллм     Г Г    лл  лл ллл лл                        "
   @ row()+1,0 say "   Г          ммммм  пллллл    Г Г    лл  лл  лл лл  лл                    "
   @ row()+1,0 say "   Г        млллллллм  ппп     Г Г   пппп пп  пп  пппп  п                  "
   @ row()+1,0 say "   Г        плллллллп          Г Г                                         "
   @ row()+1,0 say "   Г          ппппп            Г Г                                         "
   @ row()+1,0 say "   РФТФФФФФФФФФФФФФФФФФФФФФФФФФй Г                                         "
   @ row()+1,0 say "     РФФФФФФФФФФФФФФФФФФФФФФФФФФФй                                         "
   @ 02,00 to row()+1,79 double
return nil
// end-of-file //