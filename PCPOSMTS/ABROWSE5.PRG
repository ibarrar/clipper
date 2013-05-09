*** ABROWSE5.PRG ***
/* Module for Browsing Editing Stock Transfer Items */

#include "inkey.ch"
#include "setcurs.ch"
#include "Janus.ch"
#include "its.ch"
#include "abrowse.ch"

static _element,aScrollBar,aFields:={}
static access
static aChoices := {}

memvar getlist

function ABrowse5(nRecno,aPicture,nMode)
local xx,tb,wBrowse
   aFields:=InitArray(nRecno)
   access := nMode
   MsgBar(BAR)
   Tone(300,1)
   wBrowse:=OpenWindow(08,02,21,55,"Stock Transfer Items File")
   aScrollBar:=ScrollBarNew(08,55,21,"N/W",1)
   ScrollBarDisplay(aScrollBar)
   ScrollBarUpdate(aScrollBar,1,Len(aFields),.T.)
   tb:=TBrowseArray(10,03,21,53,aFields,GetSetBlock(xx))
   tb:headSep:=MY_HEADSEP
   tb:colSep:=MY_COLSEP
   tb:footSep:=MY_FOOTSEP
   tb:addColumn(TBColumnNew(""         ,    {||aFields[xx][2]}))
   tb:addColumn(TBColumnNew("Item Code",    {||aFields[xx][3]}))
   tb:addColumn(TBColumnNew("Qty. Transfered",{||aFields[xx][4]}))
   tb:addColumn(TBColumnNew("Unit Cost",   {||aFields[xx][5]}))
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
            if (aFields[_element][6] == 0)
               FilLock(0)
               if(Deleted(),DbRecall(),DbDelete())
               DbUnlock()
               aFields[_element][AB_DELETED]:=if(Deleted(),DELETED_MARK," ")
               tb:refreshAll()
            else
              message("Item already Posted...")
              BUMMER()
            endif      
         case nKey==K_INS .and. access != VIEW_MODE
            aAdd(aFields,{RecCount()+1," ",space(PLU_CODE_LEN),tran(0,"99,999,999"),tran(0,"999,999.99"),0})
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
              if (aFields[_element][6] == 0)
                  IF nKey!=K_ENTER ; KEYBOARD Chr(nKey) ; endif
                  _gets:=Eval(aPicture[tb:colPos][1])
                  lLastExit:=ReadExit(.T.)

                  if tb:colPos == 2
                   @ Row(),Col() GET _gets Picture aPicture[tb:colPos][2] WHEN PreVldtItem(@_gets) VALID PostVldtItem(_gets)
                  else 
                   @ Row(),Col() GET _gets Picture aPicture[tb:colPos][2]
                  endif

                  SetCursor(SC_NORMAL)
                  Read
                  SetCursor(SC_NONE)
                  ReadExit(lLastExit)
                  nKey:=LastKey()
                  IF (nKey!=K_ESC)
                     if ST_ITEMS->STI_LINK!=nRecno
                        FilLock(0)
                        AddRec(0)
                        replace ST_ITEMS->STI_LINK with nRecno
                        DbUnlock()
                     endif
                     FilLock(0)
                     Eval(aPicture[tb:colPos][1],_gets)
                     if tb:colPos == 2 .and. ITEM->(DbSeek(ST_ITEMS->STI_ITEM))
                       // Place Value aCCORDING TO physical count
                       Eval(aPicture[3,1],0)  //(ITEM->I_011 - ITEM->I_008))                     
                       // Just the Unit Cost
                       Eval(aPicture[4,1],ITEM->I_007)
                       tb:ColPos := 2
                     endif
                     DbUnlock()
                     aFields[_element][tb:colPos+1]:= ;
                        Transform(_gets,aPicture[tb:colPos][2])
                     tb:colpos += 1   
                     tb:refreshCurrent()
                  endif
                  aFields:=InitArray(nRecno)
                  tb:refreshAll()
              else
               message("Item already Posted...")
               BUMMER()
              endif     
      endcase
      MsgBar(BAR)
   enddo
return nKey


static function PreVldtItem(mVar)
local n:=0,lVal:= .t.
 if empty(aChoices)
  Message(" Please wait ....")
   ITEM->(DbGoTop())
   ITEM->(DbSetOrder(2))
   ITEM->(DbSeek(ST->ST_007))
  while ITEM->(!eof()) .and. ITEM->I_020 == ST->ST_007
     if ITEM->(!Deleted())  .and. (((n :=aScan( aFields, { |a_| a_[3] == ITEM->I_001} )) == 0) .or. aFields[n][6] != 0)
      aAdd(aChoices," "+ITEM->I_002+" "+ITEM->I_001+" " +ITEM->I_005+" "+ltrim(trans(ITEM->I_007,"99,999.99"))+" "+ltrim(trans(ITEM->I_003,"99,999.99"))+" " )
//      aAdd(aCosts,ITEM->I_007) 
//      aAdd(aRets,ITEM->I_003) 
     endif
     ITEM->(DbSkip())
  enddo
  ITEM->(DbSetOrder(1))
  MsgBar(BAR)
 endif 
 if ((n:=LookUp(07,15,aChoices,"Supplier "+ST->ST_007+" Item Link",mVar)) != 0)
      mVar := subs(aChoices[n],23,PLU_CODE_LEN)
//      mDesc := subs(aChoices[n],17,20)
//      mUM := subs(aChoices[n],38,10)
//      mRet := aRets[n]   
//      mCosts := aCosts[n]   
      
      aDel(aChoices,n)
      aSize(aChoices,len(aChoices)-1)
/*      aDel(aCosts,n)
      aSize(aCosts,len(aCosts)-1)      
      aDel(aRets,n)
      aSize(aRets,len(aRets)-1)      */
     // litm0 := .t.
      lVal := .f.     
 else
  //  litm0 := .f.     
 endif
return lVal

static function PostVldtItem(mVar)
local lVal := .t.,n:= 0
 if empty(mVar)
    return .f.
 endif
 mVar :=  padl( alltrim(mVar),PLU_CODE_LEN,"0")
 ITEM->(DbGotop())
 if !ITEM->(DbSeek(mVar)) .or. ((n := aScan(aFields,{|a_| a_[3] == mVar }))> 0)
   lVal := .f.
   if (n > 0)
     Message(" Item Link Number already used.... ") 
   else
     Message(" Item Link Number "+mVar+" does not exist.... ")
   endif
   Tone(500,3)
   Inkey(1)
   Tone(200,2)
 endif
 MsgBar(BAR)
return lVal 


/* static function PreVldtItem(mVar)
local n:=0,lVal:= .t.
 if empty(aChoices)
  Message(" Please wait ....")
  IV->(DbGotop())
  while IV->(!eof())
     if (IV->(!Deleted()) .and. IV->IV_CODE == ST->ST_007)  .and. (((n :=aScan( aFields, { |a_| a_[3] == IV->IV_LINK} )) == 0))
      aAdd(aChoices," "+IV->IV_LINK+" "+if(ITEM->(DbSeek(IV->IV_LINK)),subs(ITEM->I_002,1,PLU_DESC_LEN),"!Found in Master")+" " )

     endif
     IV->(DbSkip())
  enddo
  MsgBar(BAR)
 endif 
 if ((n:=LookUp(07,28,aChoices,"Supplier "+ST->ST_007+" Item Link",mVar)) != 0)
      mVar := subs(aChoices[n],2,PLU_CODE_LEN)
      aDel(aChoices,n)
      aSize(aChoices,len(aChoices)-1)
      lVal := .f.     
 endif
return lVal

static function PostVldtItem(mVar)
local lVal := .t.,n:= 0
 if empty(mVar)
    return .f.
 endif
 mVar :=  padl( alltrim(mVar),PLU_CODE_LEN,"0")
 ITEM->(DbGotop())
 if !ITEM->(DbSeek(mVar)) .or. ((n := aScan(aFields,{|a_| a_[3] == mVar }))> 0)
   lVal := .f.
   if (n > 0)
     Message(" Item Link Number already used.... ") 
   else
     Message(" Item Link Number "+mVar+" does not exist.... ")
   endif
   Tone(500,3)
   Inkey(1)
   Tone(200,2)
 endif
 MsgBar(BAR)
return lVal */



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
   do while (nRecno==ST_ITEMS->STI_LINK) .and. (!Eof())
      aAdd(aFields, { RecNo(), if(Deleted(),DELETED_MARK," "),;
                  ST_ITEMS->STI_ITEM,tran(ST_ITEMS->STI_QADJ,"99,999,999"),;
                  tran(ST_ITEMS->STI_UPRC,"999,999.99"),ST_ITEMS->STI_POST})           
      DbSkip()
   enddo
   if Len(aFields)==0
      aAdd(aFields,{RecCount()+1," ",space(PLU_CODE_LEN),tran(0,"99,999,999"),tran(0,"999,999.99"),0})
   endif
return aFields

// end-of-file
