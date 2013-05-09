*** ABROWSE6.PRG ***
*** Module for the Maintenance of per unit machines ***
*** rci for FEMA 11-19-95 (sunday take note)
*** rci 12-25-95 (yes its christmas day)

#include "inkey.ch"
#include "setcurs.ch"
#include "Janus.ch"
#include "its.ch"
#include "abrowse.ch"

static _element,aScrollBar,aFields:={}
static access
static aChoices := {}

memvar getlist

function ABrowse6(nRecno,aPicture,nMode)
local xx,tb,wBrowse
   aFields:=InitArray(nRecno)
   access := nMode
   MsgBar(BAR)
   Tone(300,1)
   wBrowse:=OpenWindow(08,02,21,maxcol()-2,"Unit Branches Machines File")
   aScrollBar:=ScrollBarNew(08,maxcol()-2,21,"N/W",1)
   ScrollBarDisplay(aScrollBar)
   ScrollBarUpdate(aScrollBar,1,Len(aFields),.T.)
   tb:=TBrowseArray(10,03,21,maxcol()-4,aFields,GetSetBlock(xx))
   tb:headSep:=MY_HEADSEP
   tb:colSep:=MY_COLSEP
   tb:footSep:=MY_FOOTSEP
   tb:addColumn(TBColumnNew(""         ,   {||aFields[xx][2]}))
   tb:addColumn(TBColumnNew("Mac#",        {||aFields[xx][3]}))
   tb:addColumn(TBColumnNew("Remarks",     {||aFields[xx][4]}))
   tb:addColumn(TBColumnNew("Target Sales",{||aFields[xx][5]}))
   tb:addColumn(TBColumnNew("Complete Data Path",   {||aFields[xx][6]}))
   BrowseKey(tb,aFields,@nRecNo,aPicture)
   aChoices := {}
   aFields := {}
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
            aAdd(aFields,{RecCount()+1," ",space(2),space(20),;
                         tran(0,"99,999,999.99"),space(20)})
            _element:=Len(aFields)
            tb:refreshCurrent()
            while !tb:stabilize();End
            tb:Colpos := 2
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
                   @ Row(),Col() GET _gets Picture aPicture[tb:colPos][2] VALID PostVldtMac(@_gets)
                  elseif tb:colPos == 5                    
                   @ Row(),Col() GET _gets Picture aPicture[tb:colPos][2] VALID PostVldtPath(@_gets)                                      
                  else
                   @ Row(),Col() GET _gets Picture aPicture[tb:colPos][2]
                  endif

                  SetCursor(SC_NORMAL)
                  Read
                  SetCursor(SC_NONE)
                  ReadExit(lLastExit)
                  nKey:=LastKey()
                  IF (nKey!=K_ESC)
                     if UM->UNIT_LINK != nRecNo
                        FilLock(0)
                        AddRec(0)
                        replace UM->UNIT_LINK with  nRecno
                        DbUnlock()
                     endif
                     FilLock(0)
                     Eval(aPicture[tb:colPos][1],_gets)
                     if tb:colPos == 2
                         Eval(aPicture[5][1],NET_WORK_PATH)
                     endif
                     DbUnlock()
                     aFields[_element][tb:colPos+1]:= ;
                        Transform(_gets,aPicture[tb:colPos][2])
                     tb:colpos += 1   
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
   if Eval(bGetSetIndex)==nil
      Eval(bGetSetIndex,1)
   endif
   tb:goTopBlock    := {|| Eval(bGetSetIndex,1)}
   tb:goBottomBlock := {|| Eval(bGetSetIndex,Len(aArray))}
   tb:skipBlock     := {|nMove| SkipElement(nMove, aArray, bGetSetIndex)}
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
   do while (nRecno==UM->UNIT_LINK) .and. (!Eof())
      aAdd(aFields,{ RecNo(), if(Deleted(),DELETED_MARK," "),;
           UM->MACHINENO,trans(UM->REMARKS,"@KS20"),tran(UM->TARGETSLS,"99,999,999.99"),;
           trans(UM->UMAC_PATH,"@KS20")})
      DbSkip()
   enddo
   if Len(aFields)==0
      aAdd(aFields,{RecCount()+1," ",space(2),space(20),;
      tran(0,"99,999,999.99"),space(20)})
   endif
return aFields

static function PostVldtPath(mVar)
local cString,cString1,cString2

  Message("Please Wait Verifying Data Entry...")
  if Empty(mVar)
     Message("Please Enter The Path of Data Transactions...")
     BUMMER()
     return .f.
  endif
  
  mVar := rtrim(mVar)
  if (subs(mVar,len(mVar),1) != "\")
     mVar += "\"
  endif   

return .t.


static function PostVldtMac(mVar)
local lRetVal:= .t. ,nRecNo := Recno()

  Message("Please Wait Verifying Data Entry...")
  if Empty(mVar)
     Message("Please Enter Unique Machine ID Code...")
     BUMMER()
     return .f.
  endif

  mVar := padl(alltrim(mVar),2,"0")

  if access==APPEND_MODE .or. (mVar != UM->MACHINENO .and. access==EDIT_MODE)
    DbGotop()
    while !Eof() .and. lRetVal
      if UM->MACHINENO == mVar
         Message("Duplicate Machine ID Code: "+mVar+" Already in Use")
         BUMMER()
         lRetVal := .f.
      endif
      DBSkip()
    enddo
    DbGoto(nRecNo)
  endif
return lRetVal

// end-of-file
