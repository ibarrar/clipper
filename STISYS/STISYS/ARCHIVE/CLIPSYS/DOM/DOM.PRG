// Filename:      DOM.PRG
// System-Name:   Philippine Airline Domestic Tickets System
// Module:        Main Menu
// Author:        Rolando Castro Ibarra Jr.
// Date-Started:  November 08, 1993
// Date-Finished: November 10, 1993

#include "OMenu.ch"
#include "Inkey.ch"
#include "SetCurs.ch"
#include "Set.ch"
#include "MemoEdit.ch"
#include "Mode.ch"
#include "Help.ch"
#include "Bsp.ch"
#include "cl501_60.ch"

#define DATA_PATH   "D:\DOMDATA\"
#define F_MCO       010
#define F_SERIES1   020
#define F_SERIES2   030
#define F_SERIES4   040
#define F_MISC      042
#define F_CDMEMOS   045
#define F_REFUNDS   050
#define F_EXIT      060
#define R_SALES     065
#define R_SALES1    070
#define R_SALES2    080
#define R_REFUNDS   083
#define R_REMITT    085
#define R_UNBILL    090
#define R_UNPAID    100
#define M_BACKUP    110
#define M_RESTORE   120
#define M_REINDEX   130
#define M_UPDATE    140
#define A_ABOUT     150
#define A_HELP      160


static hBar,hFileMenu,hMemoMenu,hReportMenu,hMaintMenu,hAboutMenu,hSubSales

// Main program.
function Dom()
local nChoice
local wOriginal,exitRequested:=.F.
public dStartDate, dEndDate, cDbf, nPgno, nTotPg
public mName1,mName2,mPos1,mPos2
   Set(_SET_SCOREBOARD,.F.)
   Set(_SET_WRAP,.T.)
   Set(_SET_PATH,DATA_PATH)
   Set(_SET_DATEFORMAT,"mm-dd-yy")
   Set(_SET_DELETED,.f.)
   Set(_SET_EXACT,.F.)
   Set(_SET_SOFTSEEK,.T.)
   Set(_SET_CONFIRM,.T.)
   ReadInsert(.T.)
   nOx:=col()   ;   nOy:=row()
   cOriginal:=SetColor()
   wOriginal:=BkgndScreen()
   Heading("Super Travel, Inc. - PR Domestic Tickets System")
   Sti_Logo()
   SetColor(DATA_COLORS)
   CreateBar()
   SetCursor(SC_NONE)
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
              cDbf:=OpenTickets(1)
              (cDbf)->(Do_Dom())
              (cDbf)->(DbCloseArea())
           case nChoice==F_SERIES1
              cDbf:=OpenTickets(2)
              (cDbf)->(Do_Dom())
              (cDbf)->(DbCloseArea())
           case nChoice==F_SERIES2
              cDbf:=OpenTickets(3)
              (cDbf)->(Do_Dom())
              (cDbf)->(DbCloseArea())
           case nChoice==F_SERIES4
              cDbf:=OpenTickets(4)
              (cDbf)->(Do_Dom())
              (cDbf)->(DbCloseArea())
           case nChoice == F_MISC
              if NetUse("MISC",DB_SHARED,NUM_SECONDS)
                 set index to MISC
              endif
              MISC->(Misc())
              MISC->(DbCloseArea())
           case nChoice == F_CDMEMOS
              if NetUse("MEMO",DB_SHARED,NUM_SECONDS)
                 set index to MEMO
              endif
              MEMO->(Memos())
              MEMO->(DbCloseArea())
           case nChoice == F_REFUNDS
              if NetUse("REFUND",DB_SHARED,NUM_SECONDS)
                 set index to REF_PAX,REFUND
              endif
              REFUND->(Refunds())
              REFUND->(DbCloseArea())
           case nChoice == R_SALES1
               Sales_Report(.t.)
           case nChoice == R_SALES2
               Sales_Report(.f.)
           case nChoice == R_REFUNDS
               Refunds_Rep()
           case nChoice == R_REMITT
               Remittance()
           case nChoice == R_UNBILL
*              Print_Unbilled()
           case nChoice == R_UNPAID
*              Print_Unpaid()
           case nChoice==M_BACKUP
              CopyFile(1)                    // Backup Databases.
           case nChoice==M_RESTORE
              CopyFile(2)                    // Restore Databases.
           case nChoice==M_REINDEX
              ReIndexIt()                    // Reindex Databases.
           case nChoice==M_UPDATE
*              UpdateBills()
         endcase
      endif
      Message("F10-Menu   Alt X-Exit")
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
   ? "Exit from Philipine Airline Domestic Tickets System..."
   ?
return nil

static function CreateBar()
   // Create empty bar menu
   hBar:=BarNew()
   // Create empty menus
   hAboutMenu:=MenuNew(chr(240))
   hFileMenu:=MenuNew("~Database")
   hReportMenu:=MenuNew("~Reports")
   hMaintMenu:=MenuNew("~Maint")
   hSubSales:=MenuNew("Sales ~Reports  ")
   // Add prompts
   // About Menu
   PromptAdd(hAboutMenu,A_ABOUT,"~About DOM  ")
   PromptAddLine(hAboutMenu)
   PromptAdd(hAboutMenu,F_EXIT,"E~xit             Alt-X  ")
   // Files Menu
   PromptAdd(hFileMenu,F_MCO,    "~Miscellaneous Charge Order ")
   PromptAdd(hFileMenu,F_SERIES1,"Series ~1 Tickets           ")
   PromptAdd(hFileMenu,F_SERIES2,"Series ~2 Tickets           ")
   PromptAdd(hFileMenu,F_SERIES4,"Series ~4 Tickets           ")
   PromptAddLine(hFileMenu)
   PromptAdd(hFileMenu,F_MISC   ,"~Miscellaneous Collection   ")
   PromptAdd(hFileMenu,F_CDMEMOS,"~Credit/Debit Memos         ")
   PromptAdd(hFileMenu,F_REFUNDS,"~Refunds Process Sheets     ")
   // Report Menu
   PromptAddSub(hReportMenu,R_SALES, hSubSales )
   PromptAdd(hReportMenu,R_REFUNDS,"Refunds Report  ")
   PromptAdd(hReportMenu,R_REMITT, "Remittance Report  " )
   // Sales Sub Menu
   PromptAdd(hSubSales,R_SALES1,"Sales Report (~Screen) ")
   PromptAdd(hSubSales,R_SALES2,"Sales Report (~Printer) ")
*   PromptAdd(hReportMenu,R_UNBILL,"~Unbilled MCO/Ticket Report ")
*   PromptAdd(hReportMenu,R_UNPAID,"Un~paid MCO/Ticket Report   ")
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
   PromptQuickKey(hbar,hAboutMenu,F_EXIT,K_ALT_X)
return nil

static function About()
local wAbout
   Message("Press any key to continue....")
   wAbout:=OpenWindow(07,19,16,61,"About DOM")
   @ 09,21 say " Phil. Airline Domestic Tickets System "
   @ 10,21 say "             Version 1.0               "
   @ 11,21 say "            Developed for              "
   @ 12,21 say "          Super Travel, Inc.           "
   @ 13,21 say "                 by                    "
   @ 14,21 say "      Rolando Castro Ibarra Jr.        "
   @ 15,21 say "          November 07, 1992            "
   @ 08,19 to 16,61 double
   Inkey(0)
   CloseWindow(wAbout)
return nil

function OpenTickets(nFnum)
    do case
       case nFnum==1
          if NetUSe("MCO",DB_SHARED,NUM_SECONDS)
             set index to MCO,MCOPAX,MCOTKT
             set order to TKT_NDX
          endif
       case nFnum==2
          if NetUSe("SERIES1",DB_SHARED,NUM_SECONDS)
             set index to SERIES1,SERIES1P,SERIES1T
             set order to TKT_NDX
          endif
       case nFnum==3
          if NetUSe("SERIES2",DB_SHARED,NUM_SECONDS)
             set index to SERIES2,SERIES2P,SERIES2T
             set order to TKT_NDX
          endif
       case nFnum==4
          if NetUSe("SERIES4",DB_SHARED,NUM_SECONDS)
             set index to SERIES4,SERIES4P,SERIES4T
             set order to TKT_NDX
          endif
    endcase
return (Alias())


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

//EOF : <DOM.PRG> //
