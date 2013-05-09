// Filename:      ABROW.PRG
// Author:        Rollie C. Ibarra Jr.
// Module:        Array Browse.
// Date-Started:  June 16, 1993
// Last-Update:   June 16, 1993

#include "inkey.ch"
#include "Setcurs.ch"
#include "Mode.ch"

#xtrans GetSetBlock(<v>)=>{|x| iif(x==NIL,<v>,<v>:=x)}

#define AB_RECNO       1
#define AB_DELETED     2
#define AB_ACCTCODE    3
#define AB_DEBIT       4
#define AB_CREDIT      5

#define MY_HEADSEP      "мям"
#define MY_COLSEP       " Ё "
#define MY_FOOTSEP      chr(205)+chr(207)+chr(205)

#define DELETED_MARK   Chr(7)

static _element,aScrollBar,aFields:={}

function ABrowse(nRecNo,nMode,aPicture,nHelpIndex)
local xx,tb
   aFields:=InitArray(nRecNo)
   Message("F10-Acct Titles  F2-Add  F4-Delete  Esc-Abort")
   Tone(300,1)
   wBrowse:=OpenWindow(06,02,21,50,"Accounts")
 *  aScrollBar:=ScrollBarNew(06,50,21,"N/W",1)
 *  ScrollBarDisplay(aScrollBar)
 *  ScrollBarUpdate(aScrollBar,1,Len(aFields),.T.)
   tb:=TBrowseArray(08,03,19,48,aFields,GetSetBlock(xx))
   tb:headSep:=MY_HEADSEP
   tb:footSep:=MY_FOOTSEP
   tb:colSep:=MY_COLSEP
   tb:addColumn(TBColumnNew(nil,        {||aFields[xx][2]}))
   tb:addColumn(TBColumnNew("Acct Code",{||aFields[xx][3]}))
   tb:addColumn(TBColumnNew("Debit",    {||aFields[xx][4]}))
   tb:addColumn(TBColumnNew("Credit",   {||aFields[xx][5]}))
   BrowseKey(tb,aFields,nMode,@nRecNo,aPicture,nHelpIndex)
   CloseWindow(wBrowse)
return NIL

static function BrowseKey(tb,aFields,nMode,nRecNo,aPicture,nHelpIndex)
local nKey,nRow,nCol
  /* tb:freeze:=1 */
   do while .T.
   /*   if tb:colPos<=tb:freeze   //I know nothing about
         tb:colPos:=tb:freeze+1
      endif */
      while !tb:stabilize()
         IF NextKey()!=0 ; EXIT ; endif //Exit if there is pending keypressed
      end
      is_Append:=.F.
      if !DbSeek(nRecNo) ; is_Append:=.T. ; endif //Check if there recno exist
      DbGoTo(aFields[_element][AB_RECNO])         //if not exist add new rec.
      nBalance:=0                    // initialize...
      for n:=1 to _element
         nBalance+=Val(StrTran(aFields[n][AB_DEBIT],",","")) - ;
            Val(StrTran(aFields[n][AB_CREDIT],",",""))
      next
      nRow:=Row() ; nCol:=Col()
      @ 20,35 clear to 20,47
      @ 20,21 say "Balance ----> "+Transform(nBalance,"@( 9,999,999.99")
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
         case nKey==K_F10
            CHART->(ChartLookUp())
            if LastKey()!=K_ESC
               if REC_NO!=nRecNo
                  AddRec(0)
                  FilLock(0)
                  replace REC_NO with nRecNo
                  DbUnlock()
               endif
               FilLock(0)
               replace ACCT_CODE with mAcctCode
               DbUnlock()
               tb:refreshCurrent()
               aFields:=InitArray(nRecNo)
               tb:refreshAll()
            endif
         case nKey==K_F2 .and. (nMode!=VIEW_MODE)
            aAdd(aFields,{RecCount()+1," ",Space(6),0.00,0.00})
            _element:=Len(aFields)
            tb:goBottom()
            tb:home()
            while !tb:stabilize();End
            _flds:=aPicture[tb:colPos][1]
            _gets:=aFields[_element][tb:colPos+1]
            AddRec(0)
            FilLock(0)
            replace REC_NO with nRecNo
            DbUnlock()
            tb:refreshCurrent()
            aFields:=InitArray(nRecNo)
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
               if REC_NO!=nRecNo
                  AddRec(0)
                  FilLock(0)
                  replace REC_NO with nRecNo
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
            aFields:=InitArray(nRecNo)
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
   tb:skipblock := { |nMove| SkipRec(nMove) }
 *  tb:skipBlock:= {|nMove| SkipElement(nMove, aArray, bGetSetIndex)}
return tb

/*static function SkipElement(nMove,aArray,bIndex)
   IF nMove > 0
      nMove:=Min(nMove, Len(aArray) - ;
      Eval(bIndex))
   else
      nMove:=Max(nMove, 1 - Eval(bIndex) )
   endif
   Eval( bIndex, Eval(bIndex) + nMove )
   _element+=nMove
   ScrollBarUpdate(aScrollBar,_element,Len(aFields),.F.)
return nMove   */

static function Skiprec(howMany)
 local actual := 0
  do case
   case howMany < 0
   do while (actual > howMany) .and. (.not. bof())
     skip-1
      if .not. bof()
       actual--
      endif
   enddo
   case howMany > 0
   do while (actual < howMany) .and. (.not. eof())
     skip+1
     if .not. eof()
        actual++
     endif
   enddo
   if eof()
    skip -1
   endif
  otherwise
   skip 0
  endcase
 return actual


function InitArray(nRecNo)
   ASize(aFields,0)
   if !DbSeek(nRecNo) ; DbGoTop() ; endif
   do while (nRecNo==REC_NO) .and. (!Eof())
      aAdd(aFields,{RecNo(),if(Deleted(),DELETED_MARK," "),ACCT_CODE, ;
         Transform(DEBIT,"9,999,999.99"),Transform(CREDIT,"9,999,999.99")})
      DbSkip()
   enddo
   if Len(aFields)==0
      aAdd(aFields,{RecCount()+1," ",Space(6),Transform(0,"9,999,999.99"), ;
        Transform(0,"9,999,999.99")})
   endif
return aFields

// end-of-file