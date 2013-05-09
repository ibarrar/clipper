/*
  FileName: ABROWSE.PRG
  Author: Rollie Castro Ibarra Junior
  Module: Array Browse
  Date-Started: August 4, 1994 // Nini's Birthday
  Last-Update: June 25, 1994
*/
#include "inkey.ch"
#include "setcurs.ch"
#include "Janus.ch"
#xtrans GetSetBlock(<v>)=>{|x|iif(x==NIL,<v>,<v>:=x)}

#define AB_RECNO    1
#define AB_DELETED  2
#define MY_HEADSEP  "мям"
#define MY_COLSEP   " Ё "
#define MY_FOOTSEP  "мом"

#define DELETED_MARK chr(7)

memvar GETLIST
static _element,aScrollBar,aFields:={}

function ABrowse(nRecno,aPicture,nMode)
local xx,tb,wBrowse
  InitDbf(nRecno,nMode)
  aFields:=InitArray(nRecno)
  Message("ESC-Abort")
  tone(300,1)
  wBrowse:=OpenWindow(08,02,21,55,"ISC Machines")
  aScrollBar:=ScrollBarNew(08,55,21,"N/W",1)
  ScrollBarDisplay(aScrollBar)
  ScrollBarUpdate(aScrollBar,1,Len(aFields),.t.)
  tb:=TBrowseArray(10,03,21,53,aFields,GetSetBlock(xx))
  tb:headSep:= MY_HEADSEP
  tb:colSep := MY_COLSEP
  tb:footSep:= MY_FOOTSEP
  tb:addColumn(TBColumnNew(""       ,{||aFields[xx][2]}))
  tb:addColumn(TBColumnNew("ISC#"   ,{||aFields[xx][3]}))
  tb:addColumn(TBColumnNew(" Code " ,{||aFields[xx][4]}))
  tb:addColumn(TBColumnNew("Cluster",{||aFields[xx][5]}))
  tb:addColumn(TBColumnNew("Remarks",{||aFields[xx][6]}))
  BrowseKey(tb,aFields,@nRecNo,aPicture)
  CloseWindow(wBrowse)
return nil

static function BrowseKey(tb,aFields,nRecno,aPicture)
local nkey,nRow,nCol,is_Append,_gets,lLastExit
  tb:freeze:=1
  tb:colPos:=5 /*and stay there*/
  do while .t.
    if tb:colPos<=tb:freeze
       tb:colPos:=tb:freeze+1
    endif
    while !tb:stabilize()
       if NextKey()!=0; Exit; endif
    enddo
    is_Append:=.F.
    if !DbSeek(nRecno); is_Append:=.T.; endif
    DbGoto(aFields[_element][AB_RECNO])
    nKey:=Inkey(0)
    do case
       case nkey==K_F1  ; Help()
       case nkey==K_UP  ; tb:up()
       case nkey==K_DOWN; tb:down()
/*       case nkey==K_LEFT; tb:left()
       case nkey==K_RIGHT;tb:right() */
       case nkey==K_PGUP; tb:pageup()
       case nkey==K_PGDN; tb:pagedown()
       case nkey==K_HOME
            tb:gotop()
            _element:=1
       case nkey==K_END
            _element:=Len(aFields)
            tb:gobottom()
       case nkey==K_ESC
            exit
/*       case nkey==K_DEL
            FilLock(0)
            if(Deleted(),DbRecall(),DbDelete())
            DbUnLock()
            aFields[_element][AB_DELETED]:=if(Deleted(),DELETED_MARK," ")
            tb:refreshAll() */
/*       case nkey==K_INS
            aAdd(aFields,{RecCount()+1,"00","00",space(20)})
            _element:=len(aFields)
            tb:refreshCurrent()
            while !tb:stabilize(); enddo
            tb:home()
            tb:gobottom() */
         case ((nkey==K_ENTER) .or. (IsData(nKey))) .and. (!Deleted()) ;
            .and. tb:colPos == 5
            if nkey!=K_ENTER; KEYBOARD Chr(nkey) ; endif
            _gets:=Eval(aPicture[tb:colPos,1])
            lLastExit:=ReadExit(.T.)
            @ row(),col() get _gets Pict aPicture[tb:colPos][2]
            SetCursor(SC_NORMAL)
            Read
            SetCursor(SC_NONE)
            ReadExit(lLastExit)
            nkey:=Lastkey()
            if Updated() .and. (nkey!=K_ESC)
               if ISCMAP->REC_NO!=nRecno
                  ISCMAP->(FilLock(0))
                  ISCMAP->(AddRec(0))
                  replace rec_no with nrecno
                  ISCMAP->(DbCommit())
                  ISCMAP->(DbUnlock())
               endif
               ISCMAP->(FilLock(0))
               Eval(aPicture[tb:colPos,1],_gets)
               ISCMAP->(DbUnlock())
               aFields[_element,tb:colPos+1]:=;
                 Transform(_gets,aPicture[tb:colPos,2])
               tb:refreshCurrent()
            endif
            aFields:=InitArray(nRecno)
            tb:refreshAll()
        endcase
     enddo
 return nkey

static function TBrowseArray(nTr,nLc,nBr,nRc,aArray,bGetSetIndex)
local tb:=TBrowseNew(nTr,nLc,nBr,nRc)
   _element:=1
   if Eval(bGetSetIndex)==nil
      Eval(bGetSetIndex,1)
   endif
   tb:goTopBlock:={|| Eval(bGetSetIndex,1)}
   tb:goBottomBlock:={|| Eval(bGetSetIndex,Len(aArray))}
   tb:skipBlock:={|nMove| SkipElement(nMove, aArray, bGetSetIndex)}
return tb

static function SkipElement(nMove,aArray,bIndex)
  if nMove > 0
     nMove:=Min(nMove, Len(aArray)-;
     Eval(bIndex))
  else
     nMove:=Max(nMove, 1-Eval(bIndex) )
  endif
  Eval( bINdex, Eval(bIndex) + nMove )
  _element+=nMove
  ScrollBarUpdate(aScrollBar,_element,len(aFields),.F.)
return nMove

static function InitArray(nRecno)
local x:=0
  aSize(aFields,0)
  if !Dbseek(nRecno) ; DbGotop(); endif
  do while (nRecno==ISCMAP->REC_NO) .and. (!Eof())
     aAdd(aFields,{ ISCMAP->(Recno()), if(Deleted(),DELETED_MARK," "),ISCMAP->ISC_NO,;
         ISCMAP->TCODE,ISCMAP->CLUSTER,ISCMAP->REMARKS })
     ISCMAP->(DbSkip())
  enddo
     if Len(aFields)==0
       aAdd(aFields,{RecCount()+1," ","99",;
       MASTER->TCODE,MASTER->CCODE,space(20)})
     endif
  aSort(aFields,,,{ |x,y| x[3] <y[3] })
return aFields

static function InitDBF(nRecno,nMode)
local i,x
local aISCs := {}
    if !DbSeek(nRecNo) ; DbGotop(); endif
    do while (nRecNo==ISCMAP->REC_NO) .and. ISCMAP->(!Eof())
       aAdd(aISCs,ISCMAP->(RecNo()))
       if nMode==EDIT_MODE
          ISCMAP->(RecLock())
          replace ISCMAP->CLUSTER with MASTER->CCODE
          replace ISCMAP->TCODE   with MASTER->TCODE
          ISCMAP->(DbCommit())
          ISCMAP->(DbUnlock())
       endif
       ISCMAP->(DbSkip())
    enddo
    x := Len(aISCs)
    if nMode==VIEW_MODE
      if x > MASTER->NUMTER
        Message("Press F3 to edit...")
        tone(300,3)
        alert("Error 0001: This Tenant has "+;
               transform(x-MASTER->NUMTER,"99")+" excess terminal/s")
      elseif x < MASTER->NUMTER
        Message("Press F3 to edit...")
        tone(300,3)
        alert("Error 0001: This Tenant lacks "+;
                   transform(MASTER->NUMTER-x,"99")+" terminal/s")
      endif
    else
     if x > MASTER->NUMTER
      Message("Deleting Excess Terminals")
      for i:=(x-1) to MASTER->NUMTER step -1
       ISCMAP->(DbSkip(-1))
       if nRecNo == ISCMAP->REC_NO
         ISCMAP->(RecLock())
         ISCMAP->(DbDelete())
         ISCMAP->(DbUnlock())
       endif
      next i
      /****** Must Close And Reopen under Exclusive mode *****/
      ISCMAP->(DbCloseArea())
      if NetUse("ISCMAP",DB_EXCLUSIVE,NUM_SECONDS)
         Set Index to ISCMAP,ISCODE
      endif
       pack                  /***********PACKING************/
      ISCMAP->(DbCloseArea())
      if NetUse("ISCMAP",DB_SHARED,NUM_SECONDS)
        Set Index to ISCMAP,ISCODE
      endif
      /*******************************************************/
     elseif x < MASTER->NUMTER
      ISCMAP->(FilLock(0))
      for i:=(x+1)  to MASTER->NUMTER
        ISCMAP->(AddRec(0))
        replace ISCMAP->REC_NO with nRecNo
        replace ISCMAP->TCODE  with MASTER->TCODE
        replace ISCMAP->ISC_NO  with "99"
        replace ISCMAP->CLUSTER with MASTER->CCODE
        replace ISCMAP->REMARKS with space(20)
      next i
      ISCMAP->(DbUnLock())
     endif
  endif
return nil

static function Help()
local wHelp,cCur,col:=49
whelp:=OpenWindow(07,48,17,78,"Help Window")
ccur:=setcursor(0)
setpos(08,col)
inkey(0)
CloseWindow(whelp)
SetCursor(ccur)
return nil

/*-*-*-*-*-*-*-*-*-*-End of File-*-*-*-*-*-*-*-*-*/