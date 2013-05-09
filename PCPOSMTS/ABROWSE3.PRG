*** ABROWSE3.PRG ***
/* Module for Item Vendors */

#include "inkey.ch"
#include "setcurs.ch"
#include "Janus.ch"
#include "its.ch"
#include "abrowse.ch"

static _element,aScrollBar,aFields:={}
static access
static aChoices := {}

memvar getlist

function ABrowse3(nRecno,aPicture,nMode)
local xx,tb,wBrowse
   aFields:=InitArray(nRecno)
   access := nMode
   MsgBar(BAR)
   Tone(300,1)
   wBrowse:=OpenWindow(09,02,22,62,"Items Supplier File")
   aScrollBar:=ScrollBarNew(09,62,22,"N/W",1)
   ScrollBarDisplay(aScrollBar)
   ScrollBarUpdate(aScrollBar,1,Len(aFields),.T.)
   tb:=TBrowseArray(11,03,22,61,aFields,GetSetBlock(xx))
   tb:headSep:=MY_HEADSEP
   tb:colSep:=MY_COLSEP
   tb:footSep:=MY_FOOTSEP
   tb:addColumn(TBColumnNew("",        {||aFields[xx][2]}))
   tb:addColumn(TBColumnNew("Code",    {||aFields[xx][3]}))
   tb:addColumn(TBColumnNew("Name",    {||aFields[xx][4]}))
   tb:addColumn(TBColumnNew("Unit Cost",{||aFields[xx][5]}))
   tb:addColumn(TBColumnNew("Min Qty",{||aFields[xx][6]}))
   BrowseKey(tb,aFields,@nRecNo,aPicture)
   aChoices := {} // Part of rci optimization
   aFields := {}  // Free allocated memory
   CloseWindow(wBrowse)
return NIL

static function BrowseKey(tb,aFields,nRecno,aPicture)
local nKey,nRow,nCol,_gets
local is_Append,lLastexit
   tb:freeze:=2
   do while .T.
      if tb:colPos<=tb:freeze
         tb:colPos:=tb:freeze 
      endif
      while !tb:stabilize() ; end
      is_Append:=.F.
      if !DbSeek(nRecno) ; is_Append:=.T. ; endif
      DbGoTo(aFields[_element][AB_RECNO])
      nKey:=InKey(0)
      do case
         case nKey==K_F1    ; Help()
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
         case nKey==K_ESC .or. nKey == K_CTRL_END
            EXIT
         case ( nKey==K_DEL .and. access != VIEW_MODE )
            FilLock(0)
            if(Deleted(),DbRecall(),DbDelete())
            DbUnlock()
            aFields[_element][AB_DELETED]:=if(Deleted(),DELETED_MARK," ")
            tb:refreshAll()
         case nKey==K_INS .and. access != VIEW_MODE
            aAdd(aFields,{RecCount()+1," ",space(3),;
              space(20),tran(0,"99,999.99"),tran(0,"999,999,999") })
            _element:=Len(aFields)
            tb:refreshCurrent()
            while !tb:stabilize();End
            tb:colPos := 2
            KEYBOARD chr(K_ENTER)
            tb:goBottom()
         case ((nKey==K_ENTER) .or. (IsData(nKey))) .and. (!Deleted()) ;
              .and. access != VIEW_MODE .and. (aPicture[tb:colPos][3]) ;
              .and. ((tb:colpos == 2) .or. (!empty(aFields[_element,3]) .and. tb:colPos != 2));
              .or. is_Append
            IF nKey!=K_ENTER ; KEYBOARD Chr(nKey) ; endif
            _gets:=Eval(aPicture[tb:colPos][1])
            lLastExit:=ReadExit(.T.)

            if tb:colPos == 2
             @ Row(),Col() GET _gets Picture aPicture[tb:colPos][2] WHEN VldtVenLnk(@_gets) VALID PostVldtVen(@_gets)
            else
             @ Row(),Col() GET _gets Picture aPicture[tb:colPos][2]
            endif

            SetCursor(SC_NORMAL)
            Read
            SetCursor(SC_NONE)
            ReadExit(lLastExit)
            nKey:=LastKey()
            IF (nKey!=K_ESC)
               if IV->IV_LINK!=nRecno
                  FilLock(0)
                  AddRec(0)
                  replace IV->IV_LINK with nRecno
                  DbUnlock()
               endif
               FilLock(0)
               Eval(aPicture[tb:colPos][1],_gets)
               if tb:ColPos == 2 .and. V->(DbSeek(IV->IV_CODE))
                 Eval(aPicture[3][1],V->V_002)
                 tb:ColPos := 4
               else
                 if tb:colPos < 5
                  tb:Colpos += 1  
                 endif 
               endif
               DbUnlock()
               aFields[_element][tb:colPos+1]:= ;
                  Transform(_gets,aPicture[tb:colPos][2])
               tb:refreshCurrent()
            endif
            aFields:=InitArray(nRecno)
            tb:refreshAll()
      endcase
      MsgBar(BAR)
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
   while (nRecno==IV->IV_LINK) .and. (!Eof())
      aAdd(aFields,{ RecNo(), if(Deleted(),DELETED_MARK," "),;
           IV->IV_CODE,IV->IV_NAME,;
           transform(IV->IV_COST,"99,999.99"),;
           transform(IV->IV_OQTY,"999,999,999") })
      DbSkip()
   enddo
   if Len(aFields)==0
      aAdd(aFields,{RecCount()+1," ",space(3),;
           space(20),tran(0,"99,999.99"),tran(0,"999,999,999") })
   endif
//   aSort(aFields,,,{ |x,y| x[3] < y[3] })
return aFields

/*static function Help()
local wHelp,ccur,col:=49
 wHelp:=OpenWindow(07,48,17,78,"Help Window")
 ccur:=setcursor(0)
inkey(0)
CloseWindow(wHelp)
Setcursor(ccur)
return nil*/

static function VldtVenLnk(mVar)
local lVal:= .t.,n:=0
 if empty(aChoices)
   Message("Please wait ....")
   V->(DbGotop())
   while V->(!eof())
      if V->(!Deleted()) // .and. (aScan( aFields, { |a_| a_[3] == V->V_001 } ) == 0)
        aAdd(aChoices," "+V->V_001+" "+V->V_002+" ")
      endif
      V->(DbSkip())     
   enddo
   MsgBar(BAR)
 endif  
 if (( n:=Lookup(11,47,aChoices,"Supplier Link",mVar)) != 0)
       mVar:= subs(aChoices[n],2,3)
       aDel(aChoices,n)
       aSize(aChoices,len(aChoices)-1)
       lVal :=  .f.
 endif
return lVal

function PostVldtVen(mVar)
local lVal := .t. ,n := 0
 if empty(mVar)
    return .f.
 endif
 mVar :=  padl( alltrim(mVar),3,"0")
 V->(DbGotop())
 if !V->(DbSeek(mVar)) .or. ( (n := aScan(aFields, { |a_| a_[3] == mVar } )) > 0 )
   lVal := .f.
   if (n > 0)
    Message(" Supplier Code Number already used.... ")
   else
    Message(" Supplier Code Number "+mVar+" does not exist.... ")
   endif
   Tone(500,3)
   Inkey(1)
   Tone(200,2)
 endif
  MsgBar(BAR)
return lVal


// end-of-file
