// Filename:      BRS.PRG
// System-Name:   BRS (Bank Reconciliation Statement);
// Module:        Main Menu
// Author:        Rollie C. Ibarra Jr.
// Date-Started:  June 13, 1993
// Last-Update:   June 26, 1993

#include "OMenu.ch"
#include "Inkey.ch"
#include "SetCurs.ch"
#include "Set.ch"
#include "MemoEdit.ch"
#include "Mode.ch"
#include "Printer.ch"

#define DATA_COLORS "N/W,W+/G,,,N/G"
#define BRS_PATH    "d:\BRSDATA\;d:\GLDATA\"
#define DBF_PATH    "d:\BRSDATA\"
#define F_SA        110
#define F_CA        120
#define F_DT        130
#define F_OC        140
#define F_EXIT      160
#define R_BRS       205
#define R_SOC       210
#define M_BDBF      305
#define M_RDBF      310
#define M_IDBF      315
#define A_ABOUT     610

static hBar,hFileMenu,hReportMenu,hMaintMenu,hAboutMenu
static hSubDbase, nOx, nOy

// Main program.
function BRS()
local nChoice
local wOriginal,exitRequested:=.F.
public dStartDate, dEndDate, cBCode, cBank:="   "
public nBankBal:=nBookBal:=0,cReport
   Set(_SET_SCOREBOARD,.F.)
   Set(_SET_WRAP,.T.)
   Set(_SET_PATH,BRS_PATH)
   Set(_SET_DATEFORMAT,"mm-dd-yy")
   Set(_SET_DELETED,.T.)
   Set(_SET_SOFTSEEK,.T.)
   Set(_SET_CONFIRM,.T.)
   nOx:=col()
   nOy:=row()
   Set(_SET_EXACT,.F.)
   SetCursor(SC_NONE)
   cOriginal:=SetColor()
   wOriginal:=BkgndScreen()
   Sti_Logo()
   Heading("Super Travel, Inc. - Bank Reconciliation System")
   SetColor(DATA_COLORS)
   Message("F10-Menu   Alt X-Exit")
   CreateBar()
   SetCursor(SC_NONE)
   BarDisplay(hBar)
   About()
   BarActivate(hBar,LastKey())
   nChoice:=BarMenuChoice(hBar)
   do while nChoice!=F_EXIT
      if LastKey()!=K_ESC
         do case
           case nChoice==A_ABOUT
              About()                        // About the system.
           case nChoice==F_SA
              if netuse("SAVINGS",DB_SHARED,NUM_SECONDS)
                 set index to SAV_DATE
                 set order to 0
              endif
              SAVINGS->(SaBrowse(04,05,20,74,"Savings Accounts",.F.))
              SAVINGS->(DBCloseArea())
           case nChoice==F_CA
              if netuse("CURRENT",DB_SHARED,NUM_SECONDS)
                 set index to CUR_DATE, CUR_CHK
                 set order to 0
              endif    
              CURRENT->(CuBrowse(04,05,20,74,"Current Accounts",.F.))
              CURRENT->(DBCloseArea())
           case nChoice==F_DT
              if netuse("TRANSIT",DB_SHARED,NUM_SECONDS)
                 set index to TRA_DATE
                 set order to 0
              endif
              TRANSIT->(DbBrowse(04,05,20,74,"Deposit in Transit",.F.))
              TRANSIT->(DBCloseArea())
           case nChoice==F_OC
              if netuse("OUT_MAST",DB_SHARED,NUM_SECONDS)
                 set index to OUT_DATE
                 set order to 0
              endif
              OUT_MAST->(DbBrowse(04,05,20,74,"Outstanding Checks",.F.))
              OUT_MAST->(DBCloseArea())
           case nChoice==R_BRS
              BRSReport()
           case nChoice==R_SOC
              Checks_Sched()
           case nChoice==M_BDBF
              CopyFile(1)
           case nChoice==M_RDBF
              CopyFile(2)
           case nChoice==M_IDBF
              Reindex()
         endcase
      endif
      Message("F10-Menu   Alt X-Exit")
      nChoice:=0
      BarActivate(hBar)
      nChoice:=BarMenuChoice(hBar)
   enddo
   SetCursor(SC_NORMAL)
   SetColor(cOriginal)
   Set(_SET_EXACT,.T.)
   Set(_SET_SOFTSEEK,.F.)
   Set(_SET_DELETED,.F.)
   Set(_SET_SCOREBOARD,.T.)
   RestoreScreen(wOriginal)
   @ nOy, nOx say ""
   ? "Exit from Bank Reconciliation System..."
   ?
return nil

static function CreateBar()
   // Create empty bar menu
   hBar:=BarNew()
   // Create empty menus
   hAboutMenu:=MenuNew(chr(240))
   hFileMenu:=MenuNew("~Files")
   hReportMenu:=MenuNew("~Reports")
   hMaintMenu:=MenuNew("~Maintenance")
   // Add prompts
   // About Menu
   PromptAdd(hAboutMenu,A_ABOUT,"~About BRS  ")
   // Files Menu
   PromptAdd(hFileMenu,F_SA, "~Savings Account")
   PromptAdd(hFileMenu,F_CA, "~Current Account")
   PromptAddLine(hFileMenu)
   PromptAdd(hFileMenu,F_DT, "~Deposit in Transit  ")
   PromptAdd(hFileMenu,F_OC, "~Outstanding Checks  ")
   PromptAddLine(hFileMenu)
   PromptAdd(hFileMenu,F_EXIT,"E~xit             Alt-X  ")
   // Report Menu
   PromptAdd(hReportMenu,R_BRS,"~Bank Reconciliation Statement  ")
   PromptAdd(hReportMenu,R_SOC,"~Schedule of Outstanding Check  ")
   // Maint Menu
   PromptAdd(hMaintMenu,M_BDBF,  "~Backup Databases  ")
   PromptAdd(hMaintMenu,M_RDBF,  "~Restore Databases  ")
   PromptAdd(hMaintMenu,M_IDBF,  "Re~index Databases  ")

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
   wAbout:=OpenWindow(07,20,16,59,"About BRS")
   @ 09 , 21 say "      Bank Reconciliation System      "
   @ 10 , 21 say "                                      "
   @ 11 , 21 say "            Developed for             "
   @ 12 , 21 say "          Super Travel, Inc.          "
   @ 13 , 21 say "                 by                   "
   @ 14 , 21 say "       Rolando Castro Ibarra Jr.      "
   @ 15 , 21 say "            June 13, 1993             "
   inkey(0)
   CloseWindow(wAbout)
return nil

function EditorFunc(nMode,nLine,nCol)
memvar initRow,initCol,initRelRow,initRelCol
local nRetVal,lKey,nKey,isReady,nLines,nCurrLine,n,nLineCtr:=0
   initRow:=nLine ; initCol:=nCol ; initRelRow:=Row()-1 ; initRelCol:=Col()-1
   if nMode==ME_IDLE
      SetCursor(SC_NONE)
      SetColor("W/R")
      @ 03,55 say "Line"+Transform(nLine,"9999")+"  Col"+;
        Transform(nCol+1,"9999")
      SetColor("N/W")
      SetCursor(SC_NORMAL)
   else
      lKey:=LastKey()
      do case
         case lKey==K_F2
            if transform(nBankBal,"9,999,999.99") == ;
               transform(nBookBal,"9,999,999.99")
               PopSound()
               if Win_YesNo({"Do you wish to update the databases",;
                             "using the current figures ?"})
                   message("Updating Outstanding Checks File...")
                   netuse("OUT_TEMP",DB_SHARED,NUM_SECONDS)
                   netuse("OUT_MAST",DB_EXCLUSIVE,NUM_SECONDS)
                   ZAP
                   Append from OUT_TEMP
                   OUT_MAST->(DBCloseArea())
                   OUT_TEMP->(DBCloseArea())
                   message("Updating Bank Balances File...")
                   netuse("BALANCE",DB_SHARED,NUM_SECONDS)
                   BALANCE->(DBSetIndex("BAL_DATE"))
                   BALANCE->(DBSeek(YrMo(dStartDate)))
                   if BALANCE->(!Found())
                      BALANCE->(AddRec(0))
                   endif
                   BALANCE->(FilLock(0))
                   do case
                   case cBank = "PCI"
                      replace BALANCE->PCIB with nBankBal
                   case cBank = "CBC"
                      replace BALANCE->CBC with nBankBal
                   endcase
                   replace BALANCE->DATE with dEndDate
                   BALANCE->(DBUnlock())
                   BALANCE->(DBCloseArea())
                   PopSound()
                   Win_Ok({"Update sequence done..."})
                   unPopSound()
               endif
               unPopSound()
            endif
            Message("Cursor keys - Navigate, F10 - Print, F2 - Update, ESC - Abort.")
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
                     Print_Header()
                     Set(_SET_CONSOLE,.F.)
                     Set(_SET_PRINTER,.T.)
                     setprinter(_SET_QUALITY,P_NLQ)
                     setprinter(_SET_HEIGHT,P_DOUBLE)
                     ? "Bank Reconciliation Statement - (", cBank, ")"
                     ?
                     ? "For the Month of :" + cmont(ctod(dStartDate)) + " 19" +;
                        substr(dStartDate,7,2)
                     setprinter(_SET_HEIGHT,P_NORMAL)
                     ?
                     nLines:=MLCount(cReport,90)
                     for nCurrLine:=5 to nLines
                        cLine:=MemoLine(cReport,90,nCurrLine)
                        if nLineCtr>50
                           eject
                           nLineCtr:=0
                        endif
                        ? MARGIN,cLine
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
                     ErrorSound()
                     Inkey(2)
                     Message("Press any key to retry, Esc to abort....")
                     nKey:=Inkey(0)
                     Message("")
                  endif
               enddo
            endif
            Message("Cursor keys - Navigate, F10 - Print, F2 - Update, ESC - Abort.")
         otherwise
            nRetVal:=ME_DEFAULT
      endcase
   endif
return nRetVal

function Print_Header()
    set(_SET_CONSOLE,.F.)
    set(_SET_PRINTER,.T.)
    setprinter(_SET_SIZE,P_NORMAL)
    setprinter(_SET_QUALITY,P_NLQ)
    setprinter(_SET_TYPESTYLE,P_ROMAN)
    setprinter(_SET_WIDTH,P_DOUBLE)
    setprinter(_SET_HEIGHT,P_DOUBLE)
    ? replicate('Э',41)
    setprinter(_SET_HEIGHT,P_NORMAL)
    setprinter(_SET_EMPHASIZED,.T.)
    ?
    ? replicate(' ',13) + "Super Travel, Inc."
    setprinter(_SET_WIDTH,P_NORMAL)
    setprinter(_SET_SIZE,P_CONDENSED)
    setprinter(_SET_EMPHASIZED,.F.)
    ?  replicate(' ',50) + "             Ground Floor, VIP Building"
    ?  replicate(' ',50) + " 1154 Roxas Boulevard, Ermita, Manila, Philippines"
    ?  replicate(' ',50) + "       Tel. No. 59-60-02 to 05, 50-96-46 to 47 "
    setprinter(_SET_SIZE,P_NORMAL)
    ?
    setprinter(_SET_WIDTH,P_DOUBLE)
    setprinter(_SET_HEIGHT,P_DOUBLE)
    ? replicate('Э',41)
    ?
    ? CHR(27) +CHR(64)
    set(_SET_PRINTER,.F.)
    set(_SET_CONSOLE,.T.)
return nil

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
return nil

//end-of-file
