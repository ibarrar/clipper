/****************************************************************************/
/* Filename:      EDITOR.PRG																												                    */
/* System-name:   Visa Requirements Information System (Accounting Version) */
/* Module:	       Requirements Memo Editor.                                 */
/* Author: 	      Rolando C. Ibarra Jr.                                     */
/* Date-Started:  January  31, 1992                                         */ 
/* Last-Update:   February 13, 1992                                         */
/****************************************************************************/                 

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

static mReqmts,nEditor

function Editor(nMode)
local wEditor,nCurLine,nLineCount,mTempReq:=""
			if nMode==VISA_MODE
   			mReqmts:=VISA->REQMTS
						Message("Reading visa requirements....please wait!")
      wEditor:=OpenWindow(03,02,22,77,"Visa Requirements")
			elseif nMode==PPT_MODE
   			mReqmts:=PASSPORT->REQMTS
						Message("Reading passport requirements....please wait!")
      wEditor:=OpenWindow(03,02,22,77,"Passport Requirements")
			elseif nMode==OTHER_MODE
   			mReqmts:=OTHERS->REQMTS
						Message("Reading other requirements....please wait!")
      wEditor:=OpenWindow(03,02,22,77,"Other Requirements")
   endif
 		nLineCount:=MLCount(mReqmts,LINE_LENGTH)
			for nCurLine:=1 to nLineCount
			   if "*" $ MemoLine(mReqmts,LINE_LENGTH,nCurLine)
						   mTempReq:=mTempReq+MemoLine(mReqmts,LINE_LENGTH-1,nCurLine)
      endif
   next
   mReqmts:=mTempReq
   Message("F1-Help  F4-Print  Esc-Abort")
			mReqmts:=MemoEdit(mReqmts,04,03,21,76,.F.,"EditorFunc")
   CloseWindow(wEditor)
			SetCursor(SC_NONE)
return nil

function EditorFunc(nMode,nLine,nCol)
memvar initRow,initCol,initRelRow,initRelCol
local nRetVal,lKey,InsMode,nKey,isReady,nLines,nCurrLine,n,cPrintCode:=" "
local nLineCtr:=0
   if nMode==ME_INIT
			   SetColor("W/R")
						@ 03,30 say "View Mode"
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
            nRetVal:=ME_DEFAULT
									case lKey==K_F1
            HelpWindow()
            Message("F1-Help  F4-Print  Esc-Abort")
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
               Message("F1-Help  F4-Print  Esc-Abort")
									   endif
         otherwise
            nRetVal:=ME_DEFAULT                                              
      endcase                          
			endif
return nRetVal

// end-of-file
