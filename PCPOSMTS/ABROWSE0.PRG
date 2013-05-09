/*** 
   FILE NAME : ABROWSE0.PRG 
      MODULE : ARRAY browse Function for Purchase Order
***/

#include "inkey.ch"
#include "setcurs.ch"
#include "Janus.ch"
#include "its.ch"
#include "abrowse.ch"

static _element,aScrollBar,aFields:={}
static access,mCosts,mDesc,mUM,nRet
static aChoices := {},mRet, aRets := {}
static aCosts   :=  {}, nitems

memvar getlist

function ABrowse0(nRecno,aPicture,nMode)
local xx,tb,wBrowse

   nitems := 0
   aFields:=InitArray(nRecno)
   access := nMode
   MsgBar(BAR)
   Tone(300,1)
   wBrowse:=OpenWindow(08,02,22,70,"PO Items File")
   aScrollBar:=ScrollBarNew(11,70,18,"N/W",1)
   ScrollBarDisplay(aScrollBar)
   ScrollBarUpdate(aScrollBar,1,Len(aFields),.T.)
   tb:=TBrowseArray(10,03,18,69,aFields,GetSetBlock(xx))
   tb:headSep:=MY_HEADSEP
   tb:colSep:=MY_COLSEP
   tb:footSep:=MY_FOOTSEP
   tb:addColumn(TBColumnNew(""         ,    {||aFields[xx][2]}))
   tb:addColumn(TBColumnNew("Item Code",    {||aFields[xx][3]}))
   tb:addColumn(TBColumnNew("Item Description",    {||aFields[xx][4]}))
   tb:addColumn(TBColumnNew("Unit Measure",    {||aFields[xx][5]}))
   tb:addColumn(TBColumnNew("Unit Retail",    {||aFields[xx][6]}))
   tb:addColumn(TBColumnNew("Unit Cost",    {||aFields[xx][7]}))
   tb:addColumn(TBColumnNew("Qty. Ordered", {||aFields[xx][8]}))
//   tb:addColumn(TBColumnNew("Qty. Received",{||aFields[xx][9]}))
//   tb:addColumn(TBColumnNew("Qty. Returned",{||aFields[xx][10]}))
   BrowseKey(tb,aFields,@nRecNo,aPicture)
   aChoices := {}
   aCosts   := {}
   aRets    := {}
   aFields  := {}
   CloseWindow(wBrowse)
return NIL

static function BrowseKey(tb,aFields,nRecno,aPicture)
local nKey,nRow,nCol,_gets
local is_Append,lLastexit,n,ntotal,nTCost, nTRetl 
   tb:freeze:=2
   do while .T.
     
      if tb:colPos<=tb:freeze
         tb:colPos:=tb:freeze 
      endif
      while !tb:stabilize()
//         IF NextKey()!=0 ; EXIT ; endif
      end
      nTotal:=0
      nTCost:=0
      nTRetl:=0

      PO_ITEMS->(DbGoTop())

      is_Append:=.F.

      if !DbSeek(nRecno) 
          is_Append:=.T. 
      else
         Do While PO_ITEMS->POI_LINK == nRecno
            nTCost += PO_ITEMS->POI_COST * PO_ITEMS->POI_QORD
            nTRetl += PO_ITEMS->POI_URET * PO_ITEMS->POI_QORD
            do Case
               Case PO->PO_010 == 0 .and. PO->PO_011 == 0
                  nTotal := nTCost
               Case PO->PO_010 == 0 .and. PO->PO_011 <> 0   
                  nTotal :=  nTCost - (nTCost * (PO->PO_011/100))
               Case PO->PO_010 <> 0 
                  nTotal := nTretl - ((nTRetl * (PO->PO_010/100)) +;
                     (nTRetl * (PO->PO_011/100)))
            endcase
            
            PO_ITEMS->(DbSkip())
         enddo
      endif
      
      DbGoTo(aFields[_element][AB_RECNO])
      
      nRow:=Row() ; nCol:=Col()
      @ 20,34 clear to 22,58
      @ 20,34 say "Total Cost   --> " + Transform(nTCost,"@( 9,999,999.99")
      @ 21,34 say "Total Retail --> " + Transform(nTRetl,"@( 9,999,999.99")
      @ 22,34 say "Amt. Payable --> " + Transform(nTotal,"@( 9,999,999.99")
      SetPos(nRow,nCol)
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
         case nKey==K_ESC .or. nKey==K_CTRL_END
            EXIT
         case ( nKey==K_DEL .and. access != VIEW_MODE )
            if (aFields[_element][9] == 0 )
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
           
            nitems += 1
            if nitems > 10
              if  alert("Maximum No. of Items reached",{"End"},"w+/b") == 1
                exit
              endif
            endif
            aAdd(aFields,{RecCount()+1," ",space(PLU_CODE_LEN),space(20),space(10),;
              tran(0,"99,999.99"),tran(0,"99,999.99"),tran(0,"99,999,999"),0})
             // tran(0,"99,999,999"),tran(0,"99,999,999"),0})
            _element:=Len(aFields)
            tb:refreshCurrent()
            while !tb:stabilize();End
            tb:ColPos := 2
            tb:goBottom()
            KEYBOARD chr(K_ENTER)
            
           

         case ((nKey==K_ENTER) .or. (IsData(nKey))) .and. (!Deleted()) ;
              .and. access != VIEW_MODE .and. (aPicture[tb:colPos][3]) ;
              .and. ((tb:colpos == 2) .or. (!empty(aFields[_element,3]) .and. tb:colPos != 2)) ;
              .or.  is_Append 

              if (aFields[_element][9] == 0)
                IF nKey!=K_ENTER ; KEYBOARD Chr(nKey) ; endif
                _gets:=Eval(aPicture[tb:colPos][1])
                lLastExit:=ReadExit(.T.)

                if tb:colPos == 2
                  @ Row(),Col() GET _gets Picture aPicture[tb:colPos][2] WHEN PreVldtItem(@_gets) VALID PostVldtItem(_gets)
                else
                  IF tb:colpos == 5
                     @ Row(),Col() GET _gets Picture aPicture[tb:colPos][2] // VALID (retcost(@_gets))
                  else
                     @ Row(),Col() GET _gets Picture aPicture[tb:colPos][2]
                  endif
                endif  
                
                SetCursor(SC_NORMAL)
                Read
                SetCursor(SC_NONE)
                ReadExit(lLastExit)
                nKey:=LastKey()
                if (nKey!=K_ESC)
                   if PO_ITEMS->POI_LINK!=nRecno // .and. litm0 == .t.
                      FilLock(0)
                      AddRec(0)
                      replace PO_ITEMS->POI_LINK with nRecno
                      DbUnlock()
                   endif
                   FilLock(0)
                   Eval(aPicture[tb:colPos][1],_gets)
                   if tb:colPos == 2
                      Eval(aPicture[3,1],mDesc)
                      Eval(aPicture[4,1],mUM)
                      Eval(aPicture[5,1],mRet)
                      Eval(aPicture[6,1],mCosts)
                      // Eval(aPicture[8,1], 0) //(ITEM->I_011 - ITEM->I_008))
                      tb:ColPos := 4
                   endif
                   DbUnlock()
                  
                   aFields[_element][tb:colPos+1]:= ;
                   Transform(_gets,aPicture[tb:colPos][2])
                   tb:ColPos += 1  
                   tb:refreshCurrent()
                endif
                aFields:=InitArray(nRecno)
                tb:refreshAll()
              else
                message("Item already posted...")
                BUMMER()
              endif  
      endcase
      MsgBar(BAR)
   enddo
return nKey


static function retcost(nret)
local retval := .f., npcent := 0
if nret > PO_ITEMS->POI_COST
   npcent := 100 - PO->PO_010
   PO_ITEMS->(Reclock(0))
   PO_ITEMS->POI_COST := nret * (npcent/100)
   PO_ITEMS->(DbUnLock())
   retval := .t.
endif

return retval

static function PreVldtItem(mVar)
local n:=0,lVal:= .t.
 if empty(aChoices)
  Message(" Please wait ....")
   ITEM->(DbGoTop())
   ITEM->(DbSetOrder(2))
   ITEM->(DbSeek(PO->PO_002))
  while ITEM->(!eof()) .and. ITEM->I_020 == PO->PO_002
     if ITEM->(!Deleted())  .and. (((n :=aScan( aFields, { |a_| a_[3] == ITEM->I_001} )) == 0) .or. aFields[n][9] != 0)
      aAdd(aChoices,padr(ITEM->I_037,40)+" "+ITEM->I_001+" " +substr(ITEM->I_005,1,5)+ltrim(trans(ITEM->I_007,"99,999.99"))+" "+ltrim(trans(ITEM->I_003,"99,999.99")))
      aAdd(aCosts,ITEM->I_007) 
      aAdd(aRets,ITEM->I_003) 
     endif
     ITEM->(DbSkip())
  enddo
  ITEM->(DbSetOrder(1))
  MsgBar(BAR)
 endif 
 if ((n:=LookUp(14,00,aChoices,"Supplier "+PO->PO_002+" Item Link",mVar)) != 0)
      mVar := subs(aChoices[n],42,PLU_CODE_LEN)
      mDesc := subs(aChoices[n],1,40)
      mUM := subs(aChoices[n],57,5)
      mRet := aRets[n]   
      mCosts := aCosts[n]   
      
      aDel(aChoices,n)
      aSize(aChoices,len(aChoices)-1)
      aDel(aCosts,n)
      aSize(aCosts,len(aCosts)-1)      
      aDel(aRets,n)
      aSize(aRets,len(aRets)-1)      
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
   do while (nRecno==PO_ITEMS->POI_LINK) .and. (!Eof())
      aAdd(aFields,{ RecNo(), if(Deleted(),DELETED_MARK," "),;
           PO_ITEMS->POI_ITEM,PO_ITEMS->POI_DESC,PO_ITEMS->POI_UM,;
           transform(PO_ITEMS->POI_URET,"99,999.99"),;
           transform(PO_ITEMS->POI_COST,"99,999.99"),;
           transform(PO_ITEMS->POI_QORD,"99,999,999"),;
           PO_ITEMS->POI_POST })
         //  transform(PO_ITEMS->POI_QREC,"99,999,999"),;
         //  transform(PO_ITEMS->POI_QRET,"99,999,999"),;
           
      DbSkip()
   enddo
   if Len(aFields)==0
      aAdd(aFields,{RecCount()+1," ",space(PLU_CODE_LEN),SPACE(20),SPACE(10),;
              tran(0,"99,999.99"),tran(0,"99,999.99"),;
              tran(0,"99,999,999"),0})              
             // tran(0,"9,999.9999"),tran(0,"99,999,999"),;
              
   endif
//   aSort(aFields,,,{ |x,y| x[3] < y[3] })
return aFields

function Help()
local wHelp,ccur,col:=49
 wHelp:=OpenWindow(07,48,17,78,"Help Window")
 ccur:=setcursor(0)
inkey(0)
CloseWindow(wHelp)
Setcursor(ccur)
return nil

// end-of-file
