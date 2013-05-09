/***********************************************************/
/* Filename:      EDITOR.PRG                               */
/* System-name:   Travel Requirements Information System.  */
/* Module:        Requirements Memo Editor.                */
/* Author:        Arnold P. Caoile                         */
/* Date-Started:  January  31, 1992                        */
/* Last-Update:   February 04, 1992                        */
/***********************************************************/                 

#include "Inkey.ch"
#include "MemoEdit.ch"
#include "Setcurs.ch"

#define LINE_LENGTH 75
#define MAX_LINES   55 
#define PRINT_COL    5
#define MARGIN      Space(7)
#define DATA_COLORS "N/W,N/BG"
#define DRAFT_MODE  chr(27)+chr(120)+chr(0)
#define NLQ_MODE    chr(27)+chr(120)+chr(1)
#define ENTER_CHAR  chr(17)+chr(196)+chr(217)
#define VISA_MODE    1
#define PPT_MODE     2
#define OTHER_MODE   3
#define VIEW_MODE    1
#define EDIT_MODE    2

static mReqmts,nEditor,isSaved

function Editor(nMode)
local wEditor,reEnter:=.T.
private initRow:=1,initCol:=initRelRow:=initRelCol:=0
   isSaved:=.F.
   if nMode==VISA_MODE
      mReqmts:=VISA->REQMTS
      wEditor:=OpenWindow(03,02,22,77,"Visa Requirements")
   elseif nMode==PPT_MODE
      mReqmts:=PASSPORT->REQMTS
      wEditor:=OpenWindow(03,02,22,77,"Passport Requirements")
   elseif nMode==OTHER_MODE
      mReqmts:=OTHERS->REQMTS
      wEditor:=OpenWindow(03,02,22,77,"Other Requirements")
   endif
   Message("F1-Help  F3-Edit  F4-Print  Esc-Abort")
   nEditor:=VIEW_MODE
   mReqmts:=MemoEdit(mReqmts,04,03,21,76,.F.,"EditorFunc")
   if LastKey()==K_F3
      Message("F1-Help  F2-Save  F4-Print  Esc-Abort")
      nEditor:=EDIT_MODE
      do while reEnter
         mReqmts:=MemoEdit(mReqmts,04,03,21,76,.T.,"EditorFunc",,, ;
                         initRow,initCol,initRelRow,initRelCol)
         reEnter:=(LastKey()==K_F2)
         if reEnter
            if nMode==VISA_MODE
               replace VISA->REQMTS with mReqmts
            elseif nMode==PPT_MODE
               replace PASSPORT->REQMTS with mReqmts
            elseif nMode==OTHER_MODE
               replace OTHERS->REQMTS with mReqmts
            endif
            Message("Saving....")
            Inkey(1)
            if nEditor==VIEW_MODE
               Message("F1-Help  F3-Edit  F4-Print  Esc-Abort")
            elseif nEditor==EDIT_MODE
               Message("F1-Help  F2-Save  F4-Print  Esc-Abort")
            endif
         endif
      enddo
   endif
   CloseWindow(wEditor)
   SetCursor(SC_NONE)
return nil

function EditorFunc(nMode,nLine,nCol)
memvar initRow,initCol,initRelRow,initRelCol
local nRetVal,lKey,InsMode,nKey,isReady,nLines,nCurrLine,n,cPrintCode:=" "
local nLineCtr:=0
   initRow:=nLine ; initCol:=nCol ; initRelRow:=Row()-1 ; initRelCol:=Col()-1
   if nMode==ME_INIT
      SetColor("W/R")
      if nEditor==EDIT_MODE
         Set(_SET_INSERT,.T.)
         SetCursor(SC_INSERT)
         @ 03,30 say "Edit Mode"
         @ 03,65 say "  Insert   "
      elseif nEditor==VIEW_MODE
         @ 03,30 say "View Mode"
      endif
      SetColor("N/W")
      nRetVal:=ME_DEFAULT
   elseif nMode==ME_IDLE
      SetCursor(SC_NONE)
      SetColor("W/R")
      @ 03,45 say "Line"+Transform(nLine,"9999")+"  Col"+;
        Transform(nCol+1,"9999")
      SetColor("N/W")
      SetCursor(SC_NORMAL)
   else
      lKey:=LastKey()
      do case
         case lKey==K_ESC
            if !isSaved .and. (nEditor==EDIT_MODE)
               Message("Current text not saved!  Press F2 to save, "+;
                       "Esc to abort.")
               do while (nKey!=K_F2) .and. (nKey!=K_ESC)
                  nKey:=Inkey(0)
               enddo
               if nKey==K_F2
                  isSaved:=.T.
                  nRetVal:=K_CTRL_W
               elseif nKey==K_ESC
                  nRetVal:=ME_DEFAULT
               endif
            else
               nRetVal:=ME_DEFAULT
            endif
         case lKey==K_F1
            HelpWindow()
            if nEditor==VIEW_MODE
               Message("F1-Help  F3-Edit  F4-Print  Esc-Abort")
            elseif nEditor==EDIT_MODE
               Message("F1-Help  F2-Save  F4-Print  Esc-Abort")
            endif
         case lKey==K_F2
            if nEditor==VIEW_MODE
               nRetVal:=ME_DEFAULT
            elseif nEditor==EDIT_MODE
               isSaved:=.T.
               nRetVal:=K_CTRL_W
            endif
         case lKey==K_F3
            if nEditor==VIEW_MODE
               nRetVal:=K_ESC
            elseif nEditor==EDIT_MODE
               nRetVal:=ME_DEFAULT
            endif
         case lKey==K_F4
            wPrint:=OpenWindow(11,22,13,56,"")
            SetCursor(SC_NORMAL)
            SetColor("N/G")
            @ 11,22 clear to 13,56
            @ 12,24 say "Please enter print code ---->" ;
              get cPrintCode picture "@! X"
            read
            SetColor(DATA_COLORS)
            SetCursor(SC_INSERT)
            CloseWindow(wPrint)
            if LastKey()!=K_ESC
               isReady:=.F.
               do while (nKey!=K_ESC) .and. (!isReady)
                  isReady:=IsPrinter()
                  if isReady
                     wPrint:=OpenWindow(11,15,13,65,"")
                     SetColor("N/G")
                     @ 11,15 clear to 13,65
                     @ 12,17 say "Insert 80 column form then press "+;
                        ENTER_CHAR+" to print."
                     nKey:=0
                     do while nKey!=K_ENTER
                        nKey:=Inkey(0)
                     enddo
                     SetColor(DATA_COLORS)
                     CloseWindow(wPrint)
                     nLineCtr:=0
                     Message("Printing....please wait!")
                     Set(_SET_CONSOLE,.F.)
                     Set(_SET_PRINTER,.T.)
                     ? NLQ_MODE
                     nLines:=MLCount(mReqmts,LINE_LENGTH)
                     for nCurrLine:=1 to nLines
                        cLine:=MemoLine(mReqmts,LINE_LENGTH,nCurrLine)
                        if cPrintCode $ SubStr(cLine,1,PRINT_COL)
                           if nLineCtr>MAX_LINES
                              eject
                              nLineCtr:=0
                           endif
                           ? MARGIN,SubStr(cLine,PRINT_COL+1,Len(cLine)-PRINT_COL)
                           nLineCtr++
                        endif
                     next
                     ? DRAFT_MODE
                     eject
                     Set(_SET_CONSOLE,.T.)
                     Set(_SET_PRINTER,.F.)
                     Set(_SET_ALTFILE,"")
                     Set(_SET_ALTERNATE,.F.)
                     close alternate
                  else
                     Message("Printer not ready....")
                     Inkey(2)
                     Message("Press any key to retry, Esc to abort....")
                     nKey:=Inkey(0)
                     Message("")
                  endif
               enddo
               if nEditor==VIEW_MODE
                  Message("F1-Help  F3-Edit  F4-Print  Esc-Abort")
               elseif nEditor==EDIT_MODE
                  Message("F1-Help  F2-Save  F4-Print  Esc-Abort")
               endif
            endif
         case lKey==K_INS
            If nEditor==EDIT_MODE
               InsMode:=!Set(_SET_INSERT)
               SetCursor(if(InsMode,SC_INSERT,SC_NORMAL))
               SetColor("W/R")
               if InsMode
                  @ 03,65 say "  Insert   "
               else
                  @ 03,65 say " Overwrite "
               endif
               SetColor("N/W")
               nRetVal:=K_INS
            endif
         otherwise
           if isSaved==.T. ; isSaved:=.F. ; endif
            nRetVal:=ME_DEFAULT
      endcase
   endif
return nRetVal

// end-of-file
