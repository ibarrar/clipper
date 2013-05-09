// Filename:      ABROWSE.PRG
// Author:        Arnold P. Caoile
// Module:        Array Browse.
// Date-Started:  April 03, 1992
// Last-Update:   June 25, 1992

#include "inkey.ch"
#include "Setcurs.ch"
#include "Mode.ch"

#xtrans GetSetBlock(<v>)=>{|x| iif(x==NIL,<v>,<v>:=x)}

#define AB_RECNO       1
#define AB_DELETED     2
#define AB_TOT_PHP     12
#define AB_TOT_USD     13

#define MY_HEADSEP      "мям"
#define MY_COLSEP       " Ё "
#define MY_FOOTSEP      chr(205)+chr(207)+chr(205)

#define DELETED_MARK   Chr(4)

static _element,aScrollBar,aFields:={}

function ABrowse(nPONo,nMode,aPicture,nHelpIndex)
local xx,tb
   aFields:=InitArray(nPONo)
   Message("Esc-Abort")
   Tone(300,1)
   wBrowse:=OpenWindow(08,05,22,75,"More Info")
   aScrollBar:=ScrollBarNew(09,75,22,"N/W",1)
   ScrollBarDisplay(aScrollBar)
   ScrollBarUpdate(aScrollBar,1,Len(aFields),.T.)
   tb:=TBrowseArray(10,06,21,74,aFields,GetSetBlock(xx))
   tb:headSep:=MY_HEADSEP
   tb:footSep:=MY_FOOTSEP
   tb:colSep:=MY_COLSEP
   tb:addColumn(TBColumnNew("",{||aFields[xx][2]}))
   tb:addColumn(TBColumnNew("Passenger",      {||aFields[xx][3]}))
   tb:addColumn(TBColumnNew("Airfare PHP",    {||aFields[xx][4]}))
   tb:addColumn(TBColumnNew("Airfare USD",    {||aFields[xx][5]}))
   tb:addColumn(TBColumnNew("Transmittal PHP",{||aFields[xx][6]}))
   tb:addColumn(TBColumnNew("Transmittal USD",{||aFields[xx][7]}))
   tb:addColumn(TBColumnNew("Comm PHP",       {||aFields[xx][8]}))
   tb:addColumn(TBColumnNew("Comm USD",       {||aFields[xx][9]}))
   tb:addColumn(TBColumnNew("Remit PHP",      {||aFields[xx][10]}))
   tb:addColumn(TBColumnNew("Remit USD",      {||aFields[xx][11]}))
   tb:addColumn(TBColumnNew("Tax PHP",        {||aFields[xx][12]}))
   tb:addColumn(TBColumnNew("Tax USD",        {||aFields[xx][13]}))
   tb:addColumn(TBColumnNew("Others PHP",     {||aFields[xx][14]}))
   tb:addColumn(TBColumnNew("Others USD",     {||aFields[xx][15]}))
   BrowseKey(tb,aFields,nMode,@nPONo,aPicture,nHelpIndex)
   CloseWindow(wBrowse)
return NIL

static function BrowseKey(tb,aFields,nMode,nPONo,aPicture,nHelpIndex)
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
      if !DbSeek(nPONo) ; is_Append:=.T. ; endif
      DbGoTo(aFields[_element][AB_RECNO])
      nbal_php:= nbal_usd:= 0
      for n:=1 to _element
         nbal_php += Val(StrTran(aFields[n][AB_TOT_PHP],",",""))
         nbal_usd += Val(StrTran(aFields[n][AB_TOT_USD],",",""))
      next
      nRow:=Row() ; nCol:=Col()
      @ 22,30 say "Balance ----> "+Transform(nbal_php,"@( 9,999,999.99")+;
                  "   "+Transform(nbal_usd,"@( 9,999,999.99")+"    "
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
         case nKey==K_F2 .and. (nMode!=VIEW_MODE)
            aAdd(aFields,{RecCount()+1," ",Space(6),0.00,0.00;
                 ,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00})
            _element:=Len(aFields)
            tb:goBottom()
            tb:home()
            while !tb:stabilize();End
            _flds:=aPicture[tb:colPos][1]
            _gets:=aFields[_element][tb:colPos+1]
            AddRec(0)
            RecLock(0)
            replace PO_NO with nPONo
            DbUnlock()
            tb:refreshCurrent()
            aFields:=InitArray(nPONo)
            tb:refreshAll()
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
               if PO_NO!=nPONo
                  AddRec(0)
                  RecLock(0)
                  replace PO_NO with nPONo
                  DbUnlock()
                  nMode:=EDIT_MODE
               endif
               FilLock(0)
               Repl &_flds With _gets
               DbUnlock()
               aFields[_element][tb:colPos+1]:= ;
                  Transform(_gets,aPicture[tb:colPos][2])
               tb:refreshCurrent()
            endif
            aFields:=InitArray(nPONo)
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

function InitArray(nPOno)
   ASize(aFields,0)
   if !DbSeek(nPOno) ; DbGoTop() ; endif
   do while (nPOno==PO_NO) .and. (!Eof())
      if (REMIT_PHP != FARE_PHP+OTHERS_PHP) .or. (REMIT_USD != FARE_USD+OTHERS_USD)
        RecLock(0)
        replace REMIT_PHP with FARE_PHP+OTHERS_PHP
        replace REMIT_USD with FARE_USD+OTHERS_USD
        DbUnlock(0)
      endif
      aAdd(aFields,{RecNo(),if(Deleted(),DELETED_MARK," "),PAX_NAME, ;
         Transform(FARE_PHP,"9,999,999.99"),  Transform(FARE_USD,"9,999,999.99"), ;
         Transform(XMIT_PHP,"9,999,999.99"),  Transform(XMIT_USD,"9,999,999.99"), ;
         Transform(COMM_PHP,"9,999,999.99"),  Transform(COMM_USD,"9,999,999.99"), ;
         Transform(REMIT_PHP,"9,999,999.99"), Transform(REMIT_USD,"9,999,999.99"), ;
         Transform(TAX_PHP,"9,999,999.99"),   Transform(TAX_USD,"9,999,999.99"), ;
         Transform(OTHERS_PHP,"9,999,999.99"),Transform(OTHERS_USD,"9,999,999.99"), ;
      })
      DbSkip()
   enddo
   if Len(aFields)==0
      aAdd(aFields,{RecCount()+1," ",Space(40),;
         Transform(0,"9,999,999.99"), Transform(0,"9,999,999.99"), ;
         Transform(0,"9,999,999.99"), Transform(0,"9,999,999.99"), ;
         Transform(0,"9,999,999.99"), Transform(0,"9,999,999.99"), ;
         Transform(0,"9,999,999.99"), Transform(0,"9,999,999.99"), ;
         Transform(0,"9,999,999.99"), Transform(0,"9,999,999.99"), ;
         Transform(0,"9,999,999.99"), Transform(0,"9,999,999.99"), ;
      })
   endif
return aFields

// end-of-file