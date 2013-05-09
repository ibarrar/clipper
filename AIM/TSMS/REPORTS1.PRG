#include "inkey.ch"
#include "setcurs.ch"
#include "box.ch"
#include "ERROR.CH"

#define OUTTERM if(x = 1,"TERMX.RPT","TERMZ.RPT")
#define OUTDEPT if(x = 1,"DEPTX.RPT","DEPTZ.RPT")
#define OUTHOUR if(x = 1,"HOURX.RPT","HOURZ.RPT")
#define OUTZSTS "Z-STATS.RPT"
#define OUTMNTH "MONTHLY.RPT"

#define MAX_LINE 50
#define MY_COLOR "GR+/B,W+/N+"
#define BAR " "+chr(27)+chr(18)+chr(26)+"-Navigate   F10-Print   ESC-Abort"

#define HEADING if ( cBrowsePrompts == nil, fieldname(n), cBrowsePrompts[n] )
#define PR_ROW1 4
#define PR_COL1 45
#define PR_ROW2 8
#define PR_COL2 69

#define X_ROW1  (PR_ROW1+nChoice)
#define X_COL1  (PR_COL1+18)
#define X_ROW2  (PR_ROW1+nChoice+3)
#define X_COL2  (X_COL1+10) //(46-62)

static NewName

memvar cReport

// Main menu for type of reports.
FUNCTION PRINTING( nAno )
 // Save parameters.
 static nChoice := 1,x := 1
 local cOldWin,wMode,color,xMode := {"X","Z"}
 local aMode := {" X-Mode ",;
                 " Z-Mode "}

 color := setcolor(MY_COLOR)

 cOldWin := savescreen (PR_ROW1-1, PR_COL1-1, PR_ROW2 + 2, PR_COL2 + 2)
 @ PR_ROW1-1,PR_COL1-1,PR_ROW2+1,PR_COL2+1 Box B_DOUBLE+" "
 shadow(PR_ROW1-1,PR_COL1-1,PR_ROW2+1,PR_COL2+1)

 DO WHILE ( ( nChoice := aChoice ( PR_ROW1, PR_COL1, PR_ROW2, PR_COL2,;
                                   { " Daily Sales Report ",;
                                     " Department Sales Report ",;
                                     " Hourly Sales Report ",;
                                     " Z Counter Status ",;
                                     " Monthly Sales Report " },,,nChoice) ) !=  0 )
 wMode := savescreen( X_ROW1, X_COL1, X_ROW2+1, X_COL2+1 )
 Message( "Pick the Type of Report" )

 if (nChoice < 4)
   @ X_ROW1, X_COL1, X_ROW2, X_COL2 Box B_SINGLE+" "
   shadow(X_ROW1, X_COL1, X_ROW2, X_COL2)
   x := aChoice(X_ROW1+1, X_COL1+1, X_ROW2-1, X_COL2-1,aMode,,,x)
   restscreen(X_ROW1, X_COL1, X_ROW2+1, X_COL2+1,wMode)
 endif

 if (LastKey() != K_ESC )
     Message ("Generating Reports...")
     cReport := ""

     DO CASE
     /* Get the type of report and generate the database file for browsing
        the specified reports */
       CASE nChoice == 1
         Create_Dsale_Report (xMode[x])
         NewName := OUTTERM
       CASE nChoice == 2
         Create_Dep_Report(xMode[x])
         NewName := OUTDEPT
       CASE nChoice == 3
         Create_Hour_Report(xMode[x])
         NewName := OUTHOUR
       CASE nChoice == 4
         Create_ZStatus_Report()
         NewName := OUTZSTS
       CASE nChoice == 5
         Create_Msale_Report()
         NewName := OUTMNTH
     ENDCASE

   cReport:=memoread(NewName)

     IF (nAno == 2)
      Message(BAR)
      SetCursor(SC_NORMAL)
      Sc_Rep ()  // Screen reports.
      SetCursor(SC_NONE)
     ENDIF
     IF ( nAno == 1 )
      Pr_Rep () // Printer reports.
     ENDIF

   Message( "Pick the Type of Reading" )

 endif

 ENDDO

 // Restore parameters.
 restscreen ( PR_ROW1-1, PR_COL1-1, PR_ROW2 + 2, PR_COL2 + 2, cOldWin )
 setcolor(color)
RETURN nil

// Screen display of a report using Memoedit.
function SC_Rep()
local clr:=Setcolor()
local wWindBuff
 wWindBuff:=OpenWindow(2,2,23,77,Mdy(date()))

 if !empty(cReport)
    MemoEdit(cReport,3,3,22,76,.f.,'EditorFunc',150 )
 else
    alert(" Error:00006 File "+NewName+" does not exist")
 endif
  Setcolor(clr)
  CloseWindow(wWindBuff)
return (lastkey()==K_ESC)

// Printer output reports.
FUNCTION PR_REP ( )
local PrevHandler := ErrorBlock()
local nKey,isReady,nLineCtr,nLines,nCurrLine,cLine

ErrorBlock( {|e| P_Handler(12,30,e,PrevHandler) } )

BEGIN SEQUENCE
if !empty(cReport)
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
                     Message("Insert paper on printer then press "+;
                        "ENTER to print.")
                     nKey:=0
                     do while nKey!=K_ENTER ; nKey:=Inkey(0) ; enddo
                     nLineCtr:=0
                     Message("Printing....please wait!")
                     Set(_SET_CONSOLE,.F.)
                     Set(_SET_PRINTER,.T.)
                     nLines:=MLCount(cReport,200)
                     ?  chr(27) + chr(120) + chr(1)   // select NLQ
                     ?? chr(15)
                     ?? chr(27) + chr(107) + chr(0)   // select Roman
                     for nCurrLine:=2 to nLines
                        cLine:=MemoLine(cReport,200,nCurrLine)
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
else
  alert(" Error Reading "+NewName+"...")
endif

END SEQUENCE

ErrorBlock(PrevHandler)

RETURN nil

/*   <cMonth> <nDay>, <nYear>.
   e.g. : 10/04/93 ---> October 04, 1993    */
FUNCTION MDY ( dDate )
 LOCAL cString := " " + cMonth(dDate)
 cString += " "
 cString += alltrim ( str ( day (dDate ) ) )
 cString += tran( year (dDate ),", 9999")
RETURN cString


//======= Printer Error handler
STATIC FUNCTION P_Handler( nRow, nColumn, Err, passAlong)

LOCAL PrinterOk,retval:=1

IF Err:genCode == EG_PRINT

 DO WHILE !ISPRINTER() .AND. (retval == 1)
  retval := Alert(" Printer not ready !!! ", { "Retry", "Cancel"} )
 ENDDO
 IF retval == 1
  RETURN .T.
 ENDIF
 Set(_SET_CONSOLE,.T.)
 Set(_SET_PRINTER,.F.)
 Set(_SET_ALTFILE,"")
 Set(_SET_ALTERNATE,.F.)
 close alternate
 BREAK

ELSE

 RETURN ( eval( passAlong, Err ) )

ENDIF

RETURN nil
