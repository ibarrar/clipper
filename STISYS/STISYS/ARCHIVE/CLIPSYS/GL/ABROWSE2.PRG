// Filename:      ABROWSE2.PRG
// Author:        Arnold P. Caoile
// Module:        Array Browse for Subsidiary Ledger.
// Date-Started:  May 15, 1992
// Last-Update:   June 25, 1992

#include "Inkey.ch"
#include "Setcurs.ch"
#include "Mode.ch"

#xtrans GetSetBlock(<v>)=>{|x| iif(x==NIL,<v>,<v>:=x)}

#define AB_RECNO       1
#define AB_DELETED     2
#define AB_DATE        3
#define AB_FOLIO       4
#define AB_DEBIT       5
#define AB_CREDIT      6
#define AB_DETAILS_1   7
#define AB_DETAILS_2   8

#define MY_HEADSEP     "мям"
#define MY_COLSEP      " Ё "
#define MY_FOOTSEP     chr(205)+chr(207)+chr(205)

#define DELETED_MARK   chr(7)

static _element,aScrollBar,aFields:={}

function ABrowse2(nRecNo,nMode,aPicture,nHelpIndex)
local xx,tb
   aFields:=InitArray2(nRecNo)
   Message("F10-Acct Titles  Esc-Abort")
   Tone(300,1)
   wBrowse:=OpenWindow(06,02,21,62,"Accounts")
   aScrollBar:=ScrollBarNew(06,62,21,"N/W",1)
   ScrollBarDisplay(aScrollBar)
   ScrollBarUpDate(aScrollBar,1,Len(aFields),.T.)
   tb:=TBrowseArray(08,03,19,60,aFields,GetSetBlock(xx))
   tb:headSep:=MY_HEADSEP
   tb:footSep:=MY_FOOTSEP
   tb:colSep:=MY_COLSEP
   tb:addColumn(TBColumnNew("",{||aFields[xx][2]}))
   tb:addColumn(TBColumnNew("Date",{||aFields[xx][3]}))
   tb:addColumn(TBColumnNew("Folio",{||aFields[xx][4]}))
   tb:addColumn(TBColumnNew("Debit",{||aFields[xx][5]}))
   tb:addColumn(TBColumnNew("Credit",{||aFields[xx][6]}))
   tb:addColumn(TBColumnNew("Details 1",{||aFields[xx][7]}))
   tb:addColumn(TBColumnNew("Details 2",{||aFields[xx][8]}))
   BrowseKey(tb,aFields,nMode,@nRecNo,aPicture,nHelpIndex)
   CloseWindow(wBrowse)
return NIL

static function BrowseKey(tb,aFields,nMode,nRecNo,aPicture,nHelpIndex)
local nKey,nPrtKey,nRow,nCol,lReady:=.F.
   tb:freeze:=1
   do while .T.
      if tb:colPos<=tb:freeze
         tb:colPos:=tb:freeze+1
      endif
      while !tb:stabilize()
         IF NextKey()!=0 ; EXIT ; endif
      end
      is_Append:=.F.
      if !DbSeek(nRecNo) ; is_Append:=.T. ; endif
      DbGoTo(aFields[_element][AB_RECNO])
      nBalance:=0
      for n:=1 to _element
         nBalance+=Val(StrTran(aFields[n][AB_DEBIT],",","")) - ;
            Val(StrTran(aFields[n][AB_CREDIT],",",""))
      next
      nRow:=Row() ; nCol:=Col()
      @ 20,47 clear to 20,59
      @ 20,33 say "Balance ----> "+Transform(nBalance,"@( 9,999,999.99")
      @ nRow,nCol say ""
      nKey:=InKey(0)
      do case
         case nKey==K_DEL
            FilLock(0)
            if(Deleted(),DbRecall(),DbDelete())
            DbUnlock()
            aFields[_element][AB_DELETED]:=if(Deleted(),DELETED_MARK," ")
            tb:refreshCurrent()
         case nKey==K_UP    ; tb:up()
         case nKey==K_DOWN  ; tb:down()
         case nKey==K_LEFT  ; tb:left()
         case nKey==K_RIGHT ; tb:right()
         case nKey==K_PGUP  ; tb:pageup()
         case nKey==K_PGDN  ; tb:pagedown()
         case nKey==K_HOME
            tb:gotop()
            _element:=1
         case nKey==K_END
            _element:=Len(aFields)
            tb:gobottom()
         case nKey==K_ESC
            EXIT
         case nKey==K_F2 .and. ((nMode==APPEND_MODE) .or. (nMode==EDIT_MODE))
            aAdd(aFields,{RecCount()+1," ",Space(8),Space(10),0.00,0.00, ;
               Space(40),Space(40)})
            _element:=Len(aFields)
            tb:gobottom()
            tb:home()
            while !tb:stabilize();End
            _flds:=aPicture[tb:colPos][1]
            _gets:=aFields[_element][tb:colPos+1]
            FilLock(0)
            AddRec(0)
            replace REC_NO with nRecNo
            DbUnlock()
            tb:refreshCurrent()
            aFields:=InitArray2(nRecNo)
            tb:refreshAll()
         case nKey==K_F10
            CHART->(ChartLookUp())
         case ((nKey==K_ENTER) .or. (IsData(nKey))) .and. ;
            (nMode!=VIEW_MODE) .and. (!Deleted())
            IF nKey!=K_ENTER ; KEYBOARD Chr(nKey) ; endif
            _flds:=aPicture[tb:colPos][1]
            _gets:=&_flds
            lLastExit:=ReadExit(.T.)
            @ Row(),Col() GET _gets Picture aPicture[tb:colPos][2]
            Read
            ReadExit(lLastExit)
            nKey:=LastKey()
            IF Updated() .and. (nKey!=K_ESC)
               if REC_NO!=nRecNo
                  AddRec(0)
                  FilLock(0)
                  replace REC_NO with nRecNo
                  DbUnlock()
                  nMode:=EDIT_MODE
               endif
               FilLock(0)
               Repl &_flds With _gets
               DbUnLock()
               aFields[_element][tb:colPos+1]:= ;
                  Transform(_gets,aPicture[tb:colPos][2])
               tb:refreshCurrent()
            endif
            aFields:=InitArray2(nRecNo)
            tb:refreshAll()
      endcase
   enddo
return nKey

static function TBrowseArray(nTr,nLc,nBr,nRc,aArray,bGetSetIndex)
local tb:=TBrowseNew(nTr,nLc,nBr,nRc)
   _element:=1
   IF Eval(bGetSetIndex)==nil
      Eval(bGetSetIndex,1)
   endif
   tb:goTopBlock:={|| Eval(bGetSetIndex,1)}
   tb:goBottomBlock:={|| Eval(bGetSetIndex,Len(aArray))}
   tb:skipBlock:={|nMove| SkipElement(nMove, aArray, bGetSetIndex)}
return tb

static function SkipElement(nMove,aArray,bIndex)
   IF nMove > 0
      nMove:=Min(nMove, Len(aArray) - Eval(bIndex))
   else
      nMove:=Max(nMove, 1 - Eval(bIndex) )
   endif
   Eval( bIndex, Eval(bIndex) + nMove )
   _element+=nMove
   ScrollBarUpDate(aScrollBar,_element,Len(aFields),.F.)
return nMove

function InitArray2(nRecNo)
   ASize(aFields,0)
   if !DbSeek(nRecNo) ; DbGoTop() ; endif
   do while (REC_NO==nRecNo) .and. (!Eof())
      aAdd(aFields,{RecNo(),if(Deleted(),DELETED_MARK," "),DATE,FOLIO, ;
         Transform(DEBIT,"9,999,999.99"),Transform(CREDIT,"9,999,999.99"), ;
         DETAILS_1,DETAILS_2})
      DbSkip()
   enddo
   if Len(aFields)==0
      aAdd(aFields,{RecCount()+1," ",Space(8),Space(10), ;
         Transform(0,"9,999,999.99"),Transform(0,"9,999,999.99"), ;
         Space(40),Space(40)})
   endif
   aFields:=aSort(aFields,,,{|x,y|ctod(x[AB_DATE]) < ctod(y[AB_DATE]) } )
return aFields

// end-of-file