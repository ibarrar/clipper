#include "fileio.ch"
#include "inkey.ch"
#include "box.ch"
#include "achoice.ch"
#include "Janus.ch"
#include "Setcurs.ch"
#include "Memoedit.ch"

#define BAR " "+chr(27)+chr(18)+chr(26)+"-Navigate   F10-Print   ESC-Abort"
#define  C_BLOCK  140
#define  MY_COLOR "GR+/B,W+/N+"

#define  T_ROW1 4
#define  T_COL1 40
#define  T_ROW2 9
#define  T_COL2 55

#define X_ROW1  (T_ROW1+nRChoice)
#define X_COL1  46
#define X_ROW2  (T_ROW1+nRChoice+3)
#define X_COL2  55

// For the cluster menu.
#define CL_ROW1 7
#define CL_COL1 28
#define CL_COL2 37

static aClusterChoices:={}, rel_elem, rel_row, nChoice
static aScrollBar,dEndDate,dStartDate

memvar GetList,DbfFile,cReport

function Display_()
local aPos := { " Terminal   ",;
                " Department ",;
                " PLU        ",;
                " Hourly     ",;
                " Cashier    ",;
                " Server     " }
local color
local cBuffer := savescreen ( T_ROW1-1, T_COL1-1, T_ROW2+2, T_COL2 + 2 )
local cBuff, wMode, xMode := {"X","Z"}
local aMode := {" X-Mode ",;
                " Z-Mode " }
static nRChoice :=1, x := 1
 // Check for password entry.

 color := setcolor(MY_COLOR)

 cBuff := savescreen( maxrow()-1, 0, maxrow()-1, maxcol() )
 Message( "Pick the Type of Reading" )

 @ T_ROW1-1, T_COL1-1, T_ROW2+1, T_COL2+1 Box B_DOUBLE+" "
 shadow(T_ROW1-1, T_COL1-1, T_ROW2+1, T_COL2+1)

 // Menu for choosing type of reading.
 do while  ( ( nRChoice := aChoice(T_ROW1, T_COL1, T_ROW2, T_COL2,aPos,,,nRChoice)) > 0)
  wMode := savescreen( X_ROW1, X_COL1, X_ROW2+1, X_COL2+1 )
  Message( "Pick the Type of Reading" )
  @ X_ROW1, X_COL1, X_ROW2, X_COL2 Box B_SINGLE+" "
  shadow(X_ROW1, X_COL1, X_ROW2, X_COL2)
  do while ( ( x := aChoice(X_ROW1+1, X_COL1+1, X_ROW2-1, X_COL2-1,aMode,,,x)) > 0)
    if (!Display( nRChoice, xMode[x] ))
     exit
    endif
    Message( "Pick the Type of Reading" )
  enddo
  restscreen(X_ROW1, X_COL1, X_ROW2+1, X_COL2+1,wMode)
 enddo
 restscreen( maxrow()-1, 0, maxrow()-1, maxcol(), cBuff )

 //  Restore parameters changed.
 restscreen( T_ROW1-1, T_COL1-1, T_ROW2 + 2, T_COL2 + 2, cBuffer )
 setcolor(color)
return nil

static function Display( nRChoice, cMode)
local nHandle, aCCode := {}, aISCnum := {}, i, cISCNo, aSungot := {}
local cBuffer := space (C_BLOCK), aISCStat:={}
local cClus,x

 // Open the file containing the database
  if cMode =="Z"
   if NetUse("REPORTZ",DB_SHARED,NUM_SECONDS)
      Set index to REPORTZ
   endif
  else
   if NetUse("REPORTX",DB_SHARED,NUM_SECONDS)
      Set index to REPORTX
   endif
  endif

  DbfFile:=Alias()

 //  Use the assignment file.
 if NetUse("ISCMAP",DB_SHARED,NUM_SECONDS)
    Set index to ISCODE,ISCMAP
 endif

 // Check for an existence of the configuration file.
 if ( lastrec() < 1 )
   alert ("Configuration file does not exist. Configure first.")
   (DbfFile)->(DbCloseArea())
   return .F.    // not my type rci. this is not "C"
 endif

 // Resize the main array and cluster choices.
 asize( aClusterChoices, 0 )

 ISCMAP->(DbGotop())
 do while ISCMAP->(!EOF())
   if aScan( aCCode , ISCMAP->CLUSTER ) == 0
     aadd ( aCCode, ISCMAP->CLUSTER)     // For achoice() to process.
     aadd ( aClusterChoices, padr ( padl( ISCMAP->CLUSTER, 5, " " ), 8, " ") )
   endif
   ISCMAP->(DBSkip())
 enddo

 // Close the assignment file and reselect work area.
 ISCMAP->(DbCloseArea())

 asort( aClusterChoices,,, { |a,b| a < b } ) // Sort.

 // Create box for choosing cluster codes.
 cBuffer := savescreen ( CL_ROW1, CL_COL1, min( CL_ROW1+len(aClusterChoices),;
                         maxrow()-4 ) + 2, CL_COL2 + 2 )
 @ CL_ROW1, CL_COL1, min( CL_ROW1+len(aClusterChoices), maxrow()-4 ) + 1,;
          CL_COL2 Box  B_SINGLE_DOUBLE+" "
 @ CL_ROW1, CL_COL1 + 1 SAY "CLUSTER"
 shadow ( CL_ROW1, CL_COL1, min( CL_ROW1+len(aClusterChoices), maxrow()-4 ) + 1, CL_COL2 )
 aScrollBar:=ScrollBarNew(CL_ROW1,CL_COL2,min( CL_ROW1+len(aClusterChoices), maxrow()-4 ) + 1,;
             setcolor(),1)
 ScrollBarDisplay(aScrollBar)
 ScrollBarUpdate(aScrollBar,1,len(aClusterChoices),.T.)

 Message ( "Choose Cluster Code to Display")
 rel_elem := rel_row := 1
 do while .T.   // Loop for reading a cluster.
   do while .T. // Loop for achoice.
     nChoice:= achoice( CL_ROW1 + 1, CL_COL1 + 1, min( CL_ROW1 + len( aClusterChoices ), maxrow()-4 ),;
              CL_COL2 - 1, aClusterChoices,'Key2Handler',rel_elem,rel_row)
     if lastkey() == K_ENTER .OR. lastkey() == K_ESC
       exit
     endif
   enddo
   // Check to see if Esc was pressed.
   if ( nChoice == 0 )
     exit
   endif
    Message(BAR)
    SetCursor(SC_NORMAL)
    Report_Display(nRChoice, aClusterChoices[nChoice], cMode )
    SetCursor(SC_NONE)
  Message ( "Choose Cluster Code to Process...")
 enddo
 restscreen ( CL_ROW1, CL_COL1, min( CL_ROW1+len(aClusterChoices), maxrow()-4 ) + 2, CL_COL2 + 2, cBuffer)
 (DbfFile)->(DbCloseArea())
return .T.

/* Just to disable the abort process when left and right arrow keys
   were pressed. */
function Key2Handler( nStatus, nCurrElem, nCurrRow )
local nKey := lastkey(), nRetVal := AC_CONT, i
 ScrollBarUpdate(aScrollBar,nCurrElem,len(aClusterChoices),.F.)
 do case
    case nKey == K_LEFT
       rel_elem := nCurrElem
       rel_row := nCurrRow
       nRetVal := AC_ABORT
    case nKey == K_RIGHT
       rel_elem := nCurrElem
       rel_row := nCurrRow
       nRetVal := AC_ABORT
    case nKey == K_END
       rel_elem := len( aClusterChoices )
       nRetVal := AC_ABORT
    case nKey == K_HOME
       rel_elem := 1
       nRetVal := AC_ABORT
    case nKey == K_ENTER
       nChoice := nCurrElem
       rel_elem := nCurrElem
       rel_row := nCurrRow
       nRetVal := AC_ABORT
    case nKey == K_ESC
       nChoice := 0
       nRetVal := AC_ABORT
 endcase
return nRetVal

function Report_Display(nRep, cClus, cMode )
local filename,NewName,clr:=Setcolor()
local wWindBuff, aTitles := { " Terminal Report Display ",;
                              " Department Report Display ",;
                              " PLU/SDP Report Display ", ;
                              " Hourly Report Display ",  ;
                              " Cashier Report Display ", ;
                              " Server Report Display " }
local aRepNames := { "RS", "DP", "PL", "HR", "CS", "SV" }
local aMacs := { "34", "35", "45", "55" }
 cReport := ""
 if GetDates()
   wWindBuff:=OpenWindow(2,2,23,77,aTitles[nRep])
   Filename := aRepNames[nRep] + aMacs[val(substr(cClus,4,1))]
   Newname := (alltrim(filename)+alltrim(cClus)+alltrim(cMode))
    (DbfFile)->(DbGotop())
    (DbfFile)->(DbSeek(Newname))
   do while (DbfFile)->REP_FILE == NewName .and. (DBfFile)->(!Eof())
     if (DbfFile)->REP_DATE >= dStartDate .and. (DbfFile)->REP_DATE <= dEndDate ;
        .and. (DbfFile)->(!Deleted())
         cReport += (DBfFile)->REP_DATA
     endif
     (DbfFile)->(DbSkip())
   enddo

   if !empty(cReport)
    MemoEdit(cReport,3,3,22,76,.f.,'EditorFunc',if(nRep=5.or.nRep=6,270,80) )
/*    if ( alert("*** Delete this file ***",{"  No  ","  Yes  "}) == 2 )
      (DbfFile)->(FilLock(0))
      (DbfFile)->(DbDelete())
      (DbfFile)->(DbCommit())
      (DbfFile)->(DbUnlock())
    endif                    */
   else
    alert(" Error:00006 File "+NewName+" does not exist")
   endif
   Setcolor(clr)
  CloseWindow(wWindBuff)
 endif
return (lastkey()==K_ESC)

function EditorFunc(nMode,nLine,nCol)
memvar initRow,initCol,initRelRow,initRelCol
local nRetVal,lKey,nKey,isReady,nLines,nCurrLine,n,nLineCtr:=0
local cLine,cColor
   initRow:=nLine ; initCol:=nCol ; initRelRow:=Row()-1 ; initRelCol:=Col()-1
   if nMode==ME_IDLE
      SetCursor(SC_NONE)
      cColor:=SetColor("W+/RB")
      @ 02,58 say "Line"+Transform(nLine,"9999")+"  Col"+;
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
         otherwise
            nRetVal:=ME_DEFAULT
      endcase
   endif
return nRetVal

function RepCon(rep,cClust,nMode)
local  term,Existing := "",mRepDate := Date()
 // Filenames start with these prefix.
static aFiles := { "RS", "DP", "PL", "HR", "CS", "SV" }
static aTerms := { "34", "35", "45", "55"}
  if nMode =="Z"
   if NetUse("REPORTZ",DB_SHARED,NUM_SECONDS)
      Set index to REPORTZ
   endif
  else
   if NetUse("REPORTX",DB_SHARED,NUM_SECONDS)
      Set index to REPORTX
   endif
  endif

  DbfFile:=Alias()
  term := val(substr(alltrim(cClust),1,1))

  if file ( aFiles[rep] + aTerms[term] + alltrim(cClust) + alltrim(nMode) )
     Existing :=  aFiles[rep] + aTerms[term] + alltrim(cClust) + alltrim(nMode)

    (DbfFile)->(DbGotop())
    (DbfFile)->(DbSeek(Existing))

    do while alltrim((DbfFile)->REP_FILE) == alltrim(EXISTING) .and. (DbfFile)->(!Eof())
       if (DbfFile)->REP_DATE == mRepDate
         exit
       endif
       (DbfFile)->(DbSkip())
    enddo

    (DbfFile)->(FilLock(0))
    if (DbfFile)->REP_FILE != EXISTING .or. (DbfFile)->REP_DATE != mRepDate
       (DbfFile)->(AddRec(0))
       (DbfFile)->REP_FILE := EXISTING
       (DbfFile)->REP_DATE := mRepDate
    endif
       (DbfFile)->REP_DATA := memoread(Existing)
    (DbfFile)->(dbCommit())
    (DbfFIle)->(dbUnlock())

  endif
 (DbfFile)->(DbCloseArea())

 // Erase the temporary file and those read for conversion.
 if rep == 3 .or. rep == 5 .or. rep == 6
   FErase(Existing)  // Erase only those that are not converted.
 endif
 tone(100,2)
 message("Done.")

return nil

static function GetDates()
local wDate,color:=setcolor()
 dStartDate:=dEndDate:=date()
 Message("Enter dates to cover report")
 wDate:=OpenWindow(09,15,13,64,"Date Information Box")
 @ 11,17 say " Enter starting date (MM-DD-YY format)" get dStartDate
 @ 12,17 say "         Ending date (MM-DD-YY format)" get dEndDate
 SetCursor(SC_NORMAL)
 HEYTHERE()
 Read
 SetCursor(SC_NONE)
 CloseWindow(wDate)
 setcolor(color)
return if(LastKey()==K_ESC,.F.,.T.)
