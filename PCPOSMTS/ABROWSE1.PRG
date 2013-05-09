*** ABROWSE1.PRG ***
/* stock DelEviries */

#include "inkey.ch"
#include "setcurs.ch"
#include "Janus.ch"
#include "its.ch"
#include "abrowse.ch"

static _element,aScrollBar,aFields:={}
static access,agecode ,mRet, mCosts
static aChoices := {}, aCosts := {}, aRets := {}

memvar getlist

function ABrowse1(nRecno,aPicture,nMode)
local xx,tb,wBrowse
   
   aFields:=InitArray(nRecno)
   access := nMode
   MsgBar(BAR)
   Tone(300,1)
   wBrowse:=OpenWindow(08,02,21,70,"Stock Receipts Items File")
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
   tb:addColumn(TBColumnNew("Qty. Received",{||aFields[xx][7]}))   
   tb:addColumn(TBColumnNew("Age Code",{||aFields[xx][8]}))   
   BrowseKey(tb,aFields,@nRecNo,aPicture)
   aChoices := {}
   aCosts   := {}
   aRets    := {}
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
            agecode := substr(dtoc(date()),1,2) + substr(dtoc(date()),7,2)
            aAdd(aFields,{RecCount()+1," ",space(PLU_CODE_LEN),space(PLU_DESC_LEN),0,0,;
                tran(0,"99,999,999"),agecode, 0 })
            _element:=Len(aFields)
            tb:refreshCurrent()
            while !tb:stabilize();End
            tb:ColPos := 2
            KEYBOARD chr(K_ENTER)
            tb:goBottom()
         case ((nKey==K_ENTER) .or. (IsData(nKey))) .and. (!Deleted()) ;
              .and. access != VIEW_MODE .and. (aPicture[tb:colPos][3]) ;
              .or.  is_Append
              agecode := substr(dtoc(date()),1,2) + substr(dtoc(date()),7,2)
              if (aFields[_element][9] == 0 )
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
                    if RR_ITEMS->RRI_LINK!=nRecno
                       FilLock(0)
                       AddRec(0)
                       replace RR_ITEMS->RRI_LINK with nRecno
                       DbUnlock()
                    endif
                    FilLock(0)
                    
                    RR_ITEMS->RRI_AGEC := Agecode
                    Eval(aPicture[tb:colPos][1],_gets)   
                    if tb:colpos == 2
                     Eval(aPicture[4,1],mRet)
                     Eval(aPicture[5,1],mCosts)
                     tb:colpos := 3
                    endif  
                    
                    DbUnlock()
                /*    IF ITEM->(Dbseek(RR_ITEMS->RRI_ITEM))
                     if empty(ITEM->I_038)
                      ITEM->(Reclock(0))
                      ITEM->I_007 := RR_ITEMS->RRI_COST
                      ITEM->I_003 := RR_ITEMS->RRI_URET
                      ITEM->I_038 := RR_ITEMS->RRI_AGEC
                      ITEM->I_039 := 2
                      ITEM->(DbUnLock())
                      #ifdef FM_ITEMS                    
                        FM->(FilLock())
                        FM->(DbAppend())
                        FM->TRANSNO := FMNext()
                        FM->OP_CODE := "02" // EDIT
                        FM->OP_FLAG := 2
                        FM->FILE_ID := "PL" // File ID Item
                        FM->RECDATA := GetData()
                        FM->POSTDATE:= Date()
                        FM->POSTSTAT:= 0
                        FM->(DbUnLock())
                      #endif                
                     endif
                    ENDIF */
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

static function PreVldtItem(mVar)
local n:=0,lVal := .t.
 if empty(aChoices)
   Message("Please wait ....")
   PO_ITEMS->(DbGoTop())
   if PO_ITEMS->(DbSeek(RR->RR_012))
    while PO_ITEMS->(!eof()) .and. PO_ITEMS->POI_LINK == RR->RR_012 
      if PO_ITEMS->(!Deleted()) .and. (((n := aScan(aFields, {|a_| a_[3] == PO_ITEMS->POI_ITEM})) == 0) .or. aFields[n][9] != 0)
        aAdd(aChoices," "+if(ITEM->(DbSeek(PO_ITEMS->POI_ITEM)),subs(ITEM->I_002,1,16),"Missing Code")+" "+PO_ITEMS->POI_ITEM+;
                       " " + LTRIM(TRANS(PO_ITEMS->POI_URET,"99,999.99")) +;
                       " " + LTRIM(TRANS(PO_ITEMS->POI_COST,"99,999.99")) + " ")
        aAdd(aCosts,PO_ITEMS->POI_COST) 
        aAdd(aRets,PO_ITEMS->POI_URET)               
      ENDIF
      PO_ITEMS->(DbSkip())
    enddo
   else 
     ITEM->(DbGoTop())
     ITEM->(DbSetOrder(2))
     ITEM->(DbSeek(RR->RR_002))
     while ITEM->(!eof()) .and. ITEM->I_020 == RR->RR_002 
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
 if ((n:=LookUp(06,20,aChoices,"I.P. Item Link",mVar)) != 0)
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
   do while (nRecno==RR_ITEMS->RRI_LINK) .and. (!Eof())
      aAdd(aFields,{ RecNo(), if(Deleted(),DELETED_MARK," "),;
           RR_ITEMS->RRI_ITEM,;
           if(ITEM->(DbSeek(RR_ITEMS->RRI_ITEM)),ITEM->I_002,""),; 
           trans(RR_ITEMS->RRI_URET,"99,999.99"),;
           trans(RR_ITEMS->RRI_COST,"99,999.99"),;
           tran(RR_ITEMS->RRI_QREC,"99,999,999"),;
           RR_ITEMS->RRI_AGEC,RR_ITEMS->RRI_POST } )
      DbSkip()
   enddo
   if Len(aFields)==0
      aAdd(aFields,{RecCount()+1," ",space(PLU_CODE_LEN),space(PLU_DESC_LEN),0,0,;
         tran(0,"99,999,999"), agecode, 0  })
   endif
//   aSort(aFields,,,{ |x,y| x[3] < y[3] })
return aFields


static function GetData()
local cData


      cData := ITEM->I_001      // PLU item Code 
      cData += SUBSTR(ITEM->I_033,3,12)    // Stock Code,
      cData += ITEM->I_002      // PLU Descriptor
      cData += "00"                  // Size
      cData += "00"                  // Color
      #ifdef CLASS_LINK 
         cData += right(ITEM->I_006,4)       // Class Code      
      #else
         cData += right(ITEM->I_006,4)       // Department Code
      #endif    
      #ifdef CLASS_LINK
         if CL->(DbSeek(ITEM->I_006)) 
             cData += "00"+right(CL->CL_003,2)   // Associated Department
         else
             cData += "0000"
         endif      
      #else
         cData += "00"+right(ITEM->I_006,2)
      #endif             
      cData += "0"+right(ITEM->I_020,3)          // Vendor Code
      cData += padl(alltrim(strtran(str(ITEM->I_003),".","")),10,"0") // selling price
      cData += repl("0",10) // price level 1
      cData += repl("0",10) // price level 2
      cData += repl("0",10) // price level 3
      cData += repl("0",10) // price level 4
      cData += repl("0",10) // price level 5
      cData += padl(alltrim(strtran(str(ITEM->I_007),".","")),10,"0") // unit cost
      cData += repl("0",4)  // time start
      cData += repl("0",4)  // time end
      cData += repl("0",4)  // base qty
      cData += repl("0",8)  // day of week
      cData += repl("0",4)  // discount rate
      cData += repl("0",10) // discount amount
      cData += repl("0",4)  // ssd rate
      cData += repl("0",10) // ssd amount
      cData += repl("0",10) // ad tax1
      cData += repl("0",10) // ad tax2
      cData += repl("0",16) // status bytes
      cData += repl("0",30) // reserved
      
return padr(cData,244,"0")


// end-of-file
