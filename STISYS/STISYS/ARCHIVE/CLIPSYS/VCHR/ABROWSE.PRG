// Filename:      ABROWSE.PRG
// Author:        Arnold P. Caoile
// Module:        Array Browse.
// Date-Started:  April 03, 1993
// Last-Update:   June 25, 1993

#include "inkey.ch"
#include "Setcurs.ch"
#include "Mode.ch"

#xtrans GetSetBlock(<v>)=>{|x| iif(x==NIL,<v>,<v>:=x)}

#define AB_RECNO       1
#define AB_DELETED     2

#define MY_HEADSEP      "мям"
#define MY_COLSEP       " Ё "

#define DELETED_MARK   Chr(7)

static _element,aScrollBar,aFields:={}

function ABrowse(cVoucherNo,nMode,aPicture,nHelpIndex)
local xx,tb
   aFields:=InitArray(cVoucherNo)
   Message("F1-Help    F2-Add    F4-Delete    Esc-Abort")
   Tone(300,1)
   wBrowse:=OpenWindow(09,30,22,77,"Namelist Window")
   aScrollBar:=ScrollBarNew(10,77,22,"N/W",1)
   ScrollBarDisplay(aScrollBar)
   ScrollBarUpdate(aScrollBar,1,Len(aFields),.T.)
   tb:=TBrowseArray(11,31,21,76,aFields,GetSetBlock(xx))
   tb:headSep:=MY_HEADSEP
   tb:colSep:=MY_COLSEP
   tb:addColumn(TBColumnNew("",{||aFields[xx][2]}))
   tb:addColumn(TBColumnNew("Passengers",{||aFields[xx][3]}))
   BrowseKey(tb,aFields,nMode,@cVoucherNo,aPicture,nHelpIndex)
   CloseWindow(wBrowse)
return NIL

static function BrowseKey(tb,aFields,nMode,cVoucherNo,aPicture,nHelpIndex)
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
      if !DbSeek(cVoucherNo) ; is_Append:=.T. ; endif
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
         case nkey == K_F1
            helpme()
         case nKey==K_F2 .and. (nMode!=VIEW_MODE)
            aAdd(aFields,{RecCount()+1," ",Space(40)})
            _element:=Len(aFields)
            tb:home()
            tb:goBottom()
            while !tb:stabilize();End
             _flds:=aPicture[tb:colPos-1][1]
            _gets:=aFields[_element][tb:colPos+1]
            AddRec(0)
            FilLock(0)
            replace VOUCHER_NO with cVoucherNo
            DbUnlock()
            tb:refreshCurrent()
            aFields:=InitArray(cVoucherNo)
            tb:refreshAll()
         case ((nKey==K_ENTER) .or. (IsData(nKey))) .and. ;
            (nMode!=VIEW_MODE) .and. (!Deleted())
            IF nKey!=K_ENTER ; KEYBOARD Chr(nKey) ; endif
            _flds:=aPicture[tb:colPos-1][1]
            _gets:=&_flds
            lLastExit:=ReadExit(.T.)
            @ Row(),Col() GET _gets Picture aPicture[tb:colPos-1][2]
            Read
            ReadExit(lLastExit)
            nKey:=LastKey()
            IF Updated() .and. (nKey!=K_ESC)
               if VOUCHER_NO!=cVoucherNo
                  AddRec(0)
                  FilLock(0)
                  replace VOUCHER_NO with cVoucherNo
                  DbUnlock()
                  nMode:=EDIT_MODE
               endif
               FilLock(0)
               Repl &_flds With _gets
               DbUnlock()
               aFields[_element][tb:colPos+1]:= ;
                  Transform(_gets,aPicture[tb:colPos-1][2])
               tb:refreshCurrent()
            endif
            aFields:=InitArray(cVoucherNo)
            tb:refreshAll()
         case nKey==K_F4
            FilLock(0)
            if(Deleted(),DbRecall(),DbDelete())
            DbUnlock()
            aFields[_element][AB_DELETED]:=if(Deleted(),DELETED_MARK," ") +;
                  substr(aFields[_element][AB_DELETED],2,2)
            tb:refreshCurrent()
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

static function InitArray(cVoucherNo)
local x:=0
   ASize(aFields,0)
   if !DbSeek(cVoucherNo) ; DbGoTop() ; endif
   do while (cVoucherNo==VOUCHER_NO) .and. (!Eof())
      aAdd(aFields,{RecNo(),if(Deleted(),DELETED_MARK,""),NAME})
      DbSkip()
   enddo
   if Len(aFields)==0
      aAdd(aFields,{RecCount()+1,"",space(40)})
   endif
   aEval(aFields,{ |z| x++, z[2] := transform(x,"999") })
return aFields

static function helpme()
local w_help
    w_help := openwindow(05,20,20,60,"Help Window")
    @ 07,     22 say "ARROW UP/DN - Previous/Next Page."
    @ row()+1,22 say "PGUP/PGDN   - Previous/Next Page."
    @ row()+1,22 say "HOME        - First Record on Page."
    @ row()+1,22 say "END         - Last Record on Page."
    @ row()+1,22 say "ENTER*      - Edit Record."
    @ row()+1,22 say "F1          - Help!"
    @ row()+1,22 say "F2*         - Add Record."
    @ row()+1,22 say "F4          - Delete Highlighted Record."
    @ row()+1,22 say "ESC         - Close Namelist Window."
    @ row()+2,22 say "* - available only in edit mode (cur-"
    @ row()+1,22 say "  sor is visible, can be done by pre-"
    @ row()+1,22 say "  ssing F3 first on the Main Window."
    message("Press any key...")
    inkey(0)
    closewindow(w_help)
    Message("F1-Help    F2-Add    F4-Delete    Esc-Abort")
return nil

// end-of-file
