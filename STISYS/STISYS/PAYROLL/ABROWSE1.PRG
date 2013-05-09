// Filename:      ABROWSE.PRG
// Author:        Arnold P. Caoile
// Module:        Array Browse.
// Date-Started:  April 03, 1992
// Last-Update:   June 25, 1992

#include "inkey.ch"
#include "Setcurs.ch"
#include "Janus.Ch"

#xtrans GetSetBlock(<v>)=>{|x| iif(x==NIL,<v>,<v>:=x)}

#define AB_RECNO       1
#define AB_DELETED     2

#define MY_HEADSEP      "мям"
#define MY_COLSEP       " Ё "
#define MY_FOOTSEP      "мом"

#define DELETED_MARK   Chr(7)

static _element,aScrollBar,aFields:={}

function ABrowse1(nRecno,aPicture)
local xx,tb
   aFields:=InitArray(nRecno)
   Message("INS-Add    DEL-Delete    Esc-Abort")
   Tone(300,1)
   wBrowse:=OpenWindow(08,12,21,60,"Wage History")
   aScrollBar:=ScrollBarNew(08,60,21,"N/W",1)
   ScrollBarDisplay(aScrollBar)
   ScrollBarUpdate(aScrollBar,1,Len(aFields),.T.)
   tb:=TBrowseArray(10,13,21,58,aFields,GetSetBlock(xx))
   tb:headSep:=MY_HEADSEP
   tb:colSep:=MY_COLSEP
   tb:footSep:=MY_FOOTSEP
   tb:addColumn(TBColumnNew(""      ,{||aFields[xx][2]}))
   tb:addColumn(TBColumnNew("Date"  ,{||aFields[xx][3]}))
   tb:addColumn(TBColumnNew("Gross" ,{||aFields[xx][4]}))
   tb:addColumn(TBColumnNew("WTax"  ,{||aFields[xx][5]}))
   tb:addColumn(TBColumnNew("SSS"   ,{||aFields[xx][6]}))
   tb:addColumn(TBColumnNew("MED"   ,{||aFields[xx][7]}))
   tb:addColumn(TBColumnNew("Net"   ,{||aFields[xx][8]}))
   BrowseKey(tb,aFields,@nRecNo,aPicture)
   CloseWindow(wBrowse)
return NIL

static function BrowseKey(tb,aFields,nRecno,aPicture)
local nKey,nRow,nCol
   tb:freeze:=1
   do while .T.
      if tb:colPos<=tb:freeze
         tb:colPos:=tb:freeze+1
      endif
      while !tb:stabilize()
         IF NextKey()!=0 ; EXIT ; endif
      end
      is_Append:=.F.
      if !DbSeek(nRecno) ; is_Append:=.T. ; endif
      DbGoTo(aFields[_element][AB_RECNO])
      nKey:=InKey(0)
      do case
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
         case nKey==K_DEL
            FilLock(0)
            if(Deleted(),DbRecall(),DbDelete())
            DbUnlock()
            aFields[_element][AB_DELETED]:=if(Deleted(),DELETED_MARK," ")
            tb:refreshAll()
         case nKey==K_INS
            aAdd(aFields,{RecCount()+1," ",ctod(""),;
                transform(0,"9,999.99"),  transform(0,"9,999.99"), ;
                transform(0,"9,999.99"),  transform(0,"9,999.99"), ;
                transform(0,"9,999.99")  })
            _element:=Len(aFields)
            tb:refreshCurrent()
            while !tb:stabilize();End
            tb:home()
            tb:goBottom()
         case ((nKey==K_ENTER) .or. (IsData(nKey))) .and. ;
            (!Deleted())
            IF nKey!=K_ENTER ; KEYBOARD Chr(nKey) ; endif
            _gets:=Eval(aPicture[tb:colPos][1])
            lLastExit:=ReadExit(.T.)
            @ Row(),Col() GET _gets Picture aPicture[tb:colPos][2]
            SetCursor(SC_NORMAL)
            Read
            SetCursor(SC_NONE)
            ReadExit(lLastExit)
            nKey:=LastKey()
            IF Updated() .and. (nKey!=K_ESC)
               if rec_no!=nRecno
                  FilLock(0)
                  AddRec(0)
                  replace rec_no with nRecno
                  DbUnlock()
               endif
               FilLock(0)
               Eval(aPicture[tb:colPos][1],_gets)
               DbUnlock()
               aFields[_element][tb:colPos+1]:= ;
                  Transform(_gets,aPicture[tb:colPos][2])
               tb:refreshCurrent()
            endif
            aFields:=InitArray(nRecno)
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
      nMove:=Min(nMove, Len(aArray) - ;
      Eval(bIndex))
   else
      nMove:=Max(nMove, 1 - Eval(bIndex) )
   endif
   Eval( bIndex, Eval(bIndex) + nMove )
   _element+=nMove
   ScrollBarUpdate(aScrollBar,_element,Len(aFields),.F.)
return nMove

static function InitArray(nRecno)
local x:=0
   ASize(aFields,0)
   if !DbSeek(nRecno) ; DbGoTop() ; endif
   do while (nRecno==REC_NO) .and. (!Eof())
      aAdd(aFields,{ RecNo(), if(Deleted(),DELETED_MARK," "), Date,;
           transform(Gross,"9,999.99"),  transform(WTax,"9,999.99"), ;
           transform(SSS,  "9,999.99"),  transform(MED, "9,999.99"), ;
           transform(Net,  "9,999.99")  })
      DbSkip()
   enddo
   if Len(aFields)==0
      aAdd(aFields,{RecCount()+1," ",ctod(""),;
           transform(0,"9,999.99"),  transform(0,"9,999.99"), ;
           transform(0,"9,999.99"),  transform(0,"9,999.99"), ;
           transform(0,"9,999.99")  })
   endif
   aSort(aFields,,,{ |x,y| x[3] < y[3] })
return aFields

// end-of-file
