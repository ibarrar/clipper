*** ABROWSE2.PRG ***
/* Stock Returns */

#include "inkey.ch"
#include "setcurs.ch"
#include "Janus.ch"
#include "its.ch"
#include "abrowse.ch"

static _element,aScrollBar,aFields:={}
static access,agecode ,mRet, mCosts
static aChoices := {}, aCosts := {}, aRets := {}

memvar getlist

function ABrowse2(nRecno,aPicture,nMode)
local xx,tb,wBrowse
   aFields:=InitArray(nRecno)
   access := nMode
   MsgBar(BAR)
   Tone(300,1)
   wBrowse:=OpenWindow(08,02,21,70,"Stock Returns Items File")
   aScrollBar:=ScrollBarNew(08,70,21,"N/W",1)
   ScrollBarDisplay(aScrollBar)
   ScrollBarUpdate(aScrollBar,1,Len(aFields),.T.)
   tb:=TBrowseArray(10,03,21,68,aFields,GetSetBlock(xx))
   tb:headSep:=MY_HEADSEP
   tb:colSep:=MY_COLSEP
   tb:footSep:=MY_FOOTSEP
   tb:addColumn(TBColumnNew(""         ,    {||aFields[xx][2]}))
   tb:addColumn(TBColumnNew("Item Code",    {||aFields[xx][3]}))
   tb:addColumn(TBColumnNew("Descriptor",   {||aFields[xx][4]}))
   tb:addColumn(TBColumnNew("Unit Retail",    {||aFields[xx][5]}))
   tb:addColumn(TBColumnNew("Unit Cost",    {||aFields[xx][6]}))
   tb:addColumn(TBColumnNew("Qty. Returned",{||aFields[xx][7]}))   
   tb:addColumn(TBColumnNew("Age Code",{||aFields[xx][8]}))   
   BrowseKey(tb,aFields,@nRecNo,aPicture)
   aChoices := {}
   aCosts := {}
   aRets := {}
   aFields  := {}
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
            if (aFields[_element][9] == 0)
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
            agecode := substr(dtoc(date()),1,2) + substr(dtoc(date()),7,2)
            aAdd(aFields,{RecCount()+1," ",space(PLU_CODE_LEN),space(PLU_DESC_LEN),0,0,;
                tran(0,"99,999,999"),agecode, 0 })
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
              agecode := substr(dtoc(date()),1,2) + substr(dtoc(date()),7,2)
              if (aFields[_element][9] == 0)
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
                     if RJ_ITEMS->RJI_LINK!=nRecno
                        FilLock(0)
                        AddRec(0)
                        replace RJ_ITEMS->RJI_LINK with nRecno
                        DbUnlock()
                     endif
                     FilLock(0)
                      RJ_ITEMS->RJI_AGEC := Agecode
                      Eval(aPicture[tb:colPos][1],_gets)   
                      if tb:colpos == 2
                       Eval(aPicture[4,1],mRet)
                       Eval(aPicture[5,1],mCosts)
                       tb:colpos := 3
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
local n:=0,lVal := .t.
 if empty(aChoices)
   Message("Please wait ....")
   RR_ITEMS->(DbGoTop())
   if RR_ITEMS->(DbSeek(RJ->RJ_002))
    while RR_ITEMS->(!eof()) .and. RR_ITEMS->RRI_LINK == RJ->RJ_002 
      if RR_ITEMS->(!Deleted()) .and. (((n := aScan(aFields, {|a_| a_[3] == RR_ITEMS->RRI_ITEM})) == 0) .or. aFields[n][9] != 0)
        aAdd(aChoices," "+if(ITEM->(DbSeek(RR_ITEMS->RRI_ITEM)),subs(ITEM->I_002,1,16),"Missing Code")+" "+RR_ITEMS->RRI_ITEM+;
                       " " + LTRIM(TRANS(RR_ITEMS->RRI_URET,"99,999.99")) +;
                       " " + LTRIM(TRANS(RR_ITEMS->RRI_COST,"99,999.99")) + " ")
        aAdd(aCosts,RR_ITEMS->RRI_COST) 
        aAdd(aRets,RR_ITEMS->RRI_URET)               
      ENDIF
      RR_ITEMS->(DbSkip())
    enddo
   else 
     ITEM->(DbGoTop())
     ITEM->(DbSetOrder(2))
     ITEM->(DbSeek(RJ->RJ_003))
     while ITEM->(!eof()) .and. ITEM->I_020 == RJ->RJ_003 
      if ITEM->(!Deleted()) .and. (((n := aScan(aFields, {|a_| a_[3] == ITEM->I_001})) == 0) .or. aFields[n][9] != 0)
        aAdd(aChoices," "+SUBSTR(ITEM->I_002,1,16)+" "+ITEM->I_001+;
               " " + LTRIM(TRANS(ITEM->I_003,"99,999.99")) +;
               " " + LTRIM(TRANS(ITEM->I_007,"99,999.99")) + " ") 
        aAdd(aCosts,ITEM->I_007) 
        aAdd(aRets,ITEM->I_003)       
      ENDIF
      ITEM->(DbSkip())
    enddo
   endif
   ITEM->(DbSetOrder(1))
   MsgBar(BAR)
 endif  
 if ((n:=LookUp(06,20,aChoices,"R.R. Item Link",mVar)) != 0)
      mVar := subs(aChoices[n],19,PLU_CODE_LEN)
      mRet := aRets[n]   
      mCosts := aCosts[n]   
      
      aDel(aChoices,n)
      aSize(aChoices,len(aChoices)-1)
      aDel(aCosts,n)
      aSize(aCosts,len(aCosts)-1)      
      aDel(aRets,n)
      aSize(aRets,len(aRets)-1)      
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
return lVal 


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
agecode := substr(dtoc(date()),1,2) + substr(dtoc(date()),7,2)
   ASize(aFields,0)
   if !DbSeek(nRecno) ; DbGoTop() ; endif
   do while (nRecno==RJ_ITEMS->RJI_LINK) .and. (!Eof())
      aAdd(aFields,{ RecNo(), if(Deleted(),DELETED_MARK," "),;
           RJ_ITEMS->RJI_ITEM,;
           if(ITEM->(DbSeek(RJ_ITEMS->RJI_ITEM)),ITEM->I_002,""),; 
           trans(RJ_ITEMS->RJI_URET,"99,999.99"),;
           trans(RJ_ITEMS->RJI_COST,"99,999.99"),;
           tran(RJ_ITEMS->RJI_QRET,"99,999,999"),;
           RJ_ITEMS->RJI_AGEC,RJ_ITEMS->RJI_POST } )
      DbSkip()
   enddo
   if Len(aFields)==0
      aAdd(aFields,{RecCount()+1," ",space(PLU_CODE_LEN),space(PLU_DESC_LEN),0,0,;
         tran(0,"99,999,999"), agecode, 0  })
   endif
//   aSort(aFields,,,{ |x,y| x[3] < y[3] })
return aFields

// end-of-file
