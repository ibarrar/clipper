// Filename:      FILE.PRG
// Author:        Rolando C. Ibarra JR.
// Module:        For Cards .prg
// Date-Started:  Oct. 30, 1993
// Last-Update:   Oct. 30, 1993

#include "inkey.ch"
#include "Setcurs.ch"
#include "Mode.ch"

#xtrans GetSetBlock(<v>)=>{|x| iif(x==NIL,<v>,<v>:=x)}

#define AB_RECNO       1
#define AB_DELETED     2
#define AB_FLIGHT      3
#define AB_CLASS       4
#define AB_DATE        5
#define AB_FROM        6
#define AB_TO          2
#define AB_ETD         3
#define AB_ETA         4
#define AB_DATERSVD    5
#define AB_STAT1       6
#define AB_RQTO        7
#define AB_PNR_TL      8
#define AB_HOTEL       9
#define AB_ACCTTYPE   10
#define AB_RATE       11
#define AB_STAT2      12
#define AB_RQTO2      13

#define MY_HEADSEP      "мям"
#define MY_COLSEP       " Ё "
#define MY_FOOTSEP      chr(205)+chr(207)+chr(205) //мом

#define DELETED_MARK   Chr(4)

static _element,aScrollBar,aFields:={}

function Cards(nLink,nMode,aPicture,nHelpIndex)
local xx,tb
   aFields:=InitArray(nLink)
   Message("Esc-Abort")
   Tone(300,1)
   wBrowse:=OpenWindow(06,02,21,73,"Cards")
*   aScrollBar:=ScrollBarNew(06,50,21,"N/W",1)
*   ScrollBarDisplay(aScrollBar)
*   ScrollBarUpdate(aScrollBar,1,Len(aFields),.T.)
   tb:=TBrowseArray(07,03,21,72,aFields,GetSetBlock(xx))
   tb:headSep:=MY_HEADSEP
   tb:footSep:=MY_FOOTSEP
   tb:colSep:=MY_COLSEP
   tb:addColumn(TBColumnNew("",      {||aFields[xx][2]}))
   tb:addColumn(TBColumnNew("Flight",{||aFields[xx][3]}))
   tb:addColumn(TBColumnNew("Class", {||aFields[xx][4]}))
   tb:addColumn(TBColumnNew("Date",  {|| DtoE(aFields[xx][5]) }))
   tb:addColumn(TBColumnNew("From",  {||aFields[xx][6]}))
   tb:addColumn(TBColumnNew("To",    {||aFields[xx][7]}))
   tb:addColumn(TBColumnNew("ETD",   {||aFields[xx][8]}))
   tb:addColumn(TBColumnNew("ETA",   {||aFields[xx][9]}))
   tb:addColumn(TBColumnNew("Date Rsvd", {|| DtoE(aFields[xx][10]) }))
   tb:addColumn(TBColumnNew("Status",    {||aFields[xx][11]}))
   tb:addColumn(TBColumnNew("Rq.To",     {||aFields[xx][12]}))
   tb:addColumn(TBColumnNew("PNR T/L",   {||aFields[xx][13]}))
   tb:addColumn(TBColumnNew("HOTEL",     {||aFields[xx][14]}))
   tb:addColumn(TBColumnNew("Acct.Type", {||aFields[xx][15]}))
   tb:addColumn(TBColumnNew("Rate",      {||aFields[xx][16]}))
   tb:addColumn(TBColumnNew("Status",    {||aFields[xx][17]}))
   tb:addColumn(TBColumnNew("Rq.To",     {||aFields[xx][18]}))

   BrowseKey(tb,aFields,nMode,@nLink,aPicture,nHelpIndex)
   CloseWindow(wBrowse)
return NIL

static function BrowseKey(tb,aFields,nMode,nLink,aPicture,nHelpIndex)
local nKey,nRow,nCol
   tb:freeze:=1
   do while .T.
      if tb:colPos<=tb:freeze
         tb:colPos:=tb:freeze+1
      endif
      while !tb:stabilize()
         IF NextKey()!=0 ; EXIT ; endif
      end                                    //while
      is_Append:=.F.
      if !DbSeek(nLink) ; is_Append:=.T. ; endif
      DbGoTo(aFields[_element][AB_RECNO])
      nRow:=Row() ; nCol:=Col()
      @ nRow,nCol say ""
      nKey:=InKey(0)
      do case
         case nKey==K_DEL
            FilLock(0)
            if(Deleted(),DbRecall(),DbDelete())
            DbUnlock()
            aFields[_element][AB_DELETED]:=if(Deleted(),DELETED_MARK," ")
            tb:refreshCurrent()
         case nKey==K_UP    ;if _element != 1; tb:up() ;endif
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
            aAdd(aFields,{RecCount()+1," ",space(6),space(1),space(7),;
                  space(3),space(3),space(4),space(4),;
                  space(7),space(2),space(4),space(9),;
                  space(15),space(4),space(4),space(2),space(4)})
            _element:=Len(aFields)
            tb:goBottom()
            tb:home()
            while !tb:stabilize(); enddo
            _flds:=aPicture[tb:colPos][1]
            _gets:=aFields[_element][tb:colPos+1]
            AddRec(0)
            FilLock(0)
            replace LINK with nLink
            DbUnlock()
            tb:refreshCurrent()
            aFields:=InitArray(nLink)
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
               if LINK!=nLink
                  AddRec(0)
                  FilLock(0)
                  replace LINK with nLink
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
            aFields:=InitArray(nLink)
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
*   ScrollBarUpdate(aScrollBar,_element,Len(aFields),.F.)
return nMove

function InitArray(nLink)
 Asize(aFields,0)
 if !DbSeek(nLink); DbGotop();endif
 do while (nLink==LINK) .and. (!Eof())
   aAdd(aFields,{RecNo(),if(Deleted(),chr(4)," "),Flight,Class,DtoE(Date),From,To,;
                 ETD,ETA,dtoe(DATE_RSVD),STAT1,RQ_TO1,PNR_TL,;
                 HOTEL,ACCT_TYPE,RATE,STAT2,RQ_TO2})
   DbSkip()
 enddo
 if Len(AFields)==0
    aAdd(aFields,{LastRec()+1," ",space(6),space(1),space(7),;
                  space(3),space(3),space(4),space(4),;
                  space(7),space(2),space(4),space(9),;
                  space(15),space(4),space(4),space(2),space(4)})
  endif
return aFields

//EOFILE-------------->

