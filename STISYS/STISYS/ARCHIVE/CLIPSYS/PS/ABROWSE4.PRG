// Filename:      ABROWSE.PRG
// Author:        Arnold P. Caoile
// Module:        Array Browse.
// Date-Started:  April 03, 1992
// Last-Update:   June 25, 1992

#include "inkey.ch"
#include "Setcurs.ch"
#include "Janus.Ch"

#xtrans GetSetBlock(<v>)=>{|x| iif(x==NIL,<v>,<v>:=x)}

#define AB_RECNO       1
#define AB_DELETED     2

#define MY_HEADSEP      "อัอ"
#define MY_COLSEP       " ณ "
#define MY_FOOTSEP      "อฯอ"

#define DELETED_MARK   Chr(7)

static _element,aScrollBar,aFields:={}

function ABrowse4(nRecno,aPicture)
local xx,tb
   aFields:=InitArray(nRecno)
   Message("F1-Help   INS-Add   DEL-Delete   F2-Status   Esc-Abort")
   Tone(300,1)
   wBrowse:=OpenWindow(08,20,21,75,"Daily Time Record")
   aScrollBar:=ScrollBarNew(08,75,21,"N/W",1)
   ScrollBarDisplay(aScrollBar)
   ScrollBarUpdate(aScrollBar,1,Len(aFields),.T.)
   tb:=TBrowseArray(09,21,21,73,aFields,GetSetBlock(xx))
   tb:headSep:=MY_HEADSEP
   tb:colSep:=MY_COLSEP
   tb:footSep:=MY_FOOTSEP
   tb:addColumn(TBColumnNew(""      ,{||aFields[xx][2]}))
   tb:addColumn(TBColumnNew("Date"  ,{||aFields[xx][3]}))
   tb:addColumn(TBColumnNew("AM in",{||aFields[xx][4]}))
   tb:addColumn(TBColumnNew("AM out",{||aFields[xx][5]}))
   tb:addColumn(TBColumnNew("PM in",{||aFields[xx][6]}))
   tb:addColumn(TBColumnNew("PM out",{||aFields[xx][7]}))
   tb:addColumn(TBColumnNew("AM in UT",{||aFields[xx][8]}))
   tb:addColumn(TBColumnNew("AM out UT",{||aFields[xx][9]}))
   tb:addColumn(TBColumnNew("PM in UT",{||aFields[xx][10]}))
   tb:addColumn(TBColumnNew("PM out UT",{||aFields[xx][11]}))
   tb:addColumn(TBColumnNew("PM out OT",{||aFields[xx][12]}))
   BrowseKey(tb,aFields,@nRecNo,aPicture)
   CloseWindow(wBrowse)
return NIL

static function BrowseKey(tb,aFields,nRecno,aPicture)
local nKey,nRow,nCol
   tb:freeze:=1
   do while .T.
      Message("INS-Add    DEL-Delete    F2-Status    Esc-Abort")
      if tb:colPos<=tb:freeze
         tb:colPos:=tb:freeze+1
      endif
      while !tb:stabilize()
         IF NextKey()!=0 ; EXIT ; endif
      end
      is_Append:=.F.
      if !DbSeek(nRecno) ; is_Append:=.T. ; endif
      DbGoTo(aFields[_element][AB_RECNO])
      nKey:=InKey(0)
      do case
         case nKey==K_F1
              Help()
         case nKey==K_F2
              ShowStatus()
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
         case nKey==K_DEL
            FilLock(0)
            if(Deleted(),DbRecall(),DbDelete())
            DbUnlock()
            aFields[_element][AB_DELETED]:=if(Deleted(),DELETED_MARK," ")
            tb:refreshAll()
         case nKey==K_INS
            AddRec(0)
            RecLock(0)
            replace rec_no with nRecno
            DbUnlock()
            aFields:=InitArray(nRecno)
            _element := 1
            tb:refreshAll()
            while !tb:stabilize();End
            tb:home()
         case ((nKey==K_ENTER) .or. (IsData(nKey))) .and. ;
            (!Deleted())
            IF nKey!=K_ENTER ; KEYBOARD Chr(nKey) ; endif
            _gets:=Eval(aPicture[tb:colPos][1])
            lLastExit:=ReadExit(.T.)
            @ Row(),Col() GET _gets Picture aPicture[tb:colPos][2]
            SetCursor(SC_NORMAL)
            Read
            SetCursor(SC_NONE)
            ReadExit(lLastExit)
            nKey:=LastKey()
            IF Updated() .and. (nKey!=K_ESC)
               RecLock(0)
               Eval(aPicture[tb:colPos][1],_gets)
               DbUnlock()
               aFields[_element][tb:colPos+1]:= ;
                  Transform(_gets,aPicture[tb:colPos][2])
               tb:refreshCurrent()
               if tb:colpos == 2
                  aFields:=InitArray(nRecno)
                  _element := 1
                  tb:refreshAll()
                  while !tb:stabilize();End
                  tb:home()
               endif
            endif
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

static function InitArray(nRecno)
local x:=0
   ASize(aFields,0)
   if !DbSeek(nRecno) ; DbGoTop() ; endif
   Message("Searching records...")
   do while (nRecno==REC_NO) .and. (!Eof())
      aAdd(aFields,{ RecNo(), if(Deleted(),DELETED_MARK," "), Tr_Date,;
           Tr_Amin, Tr_Amout, Tr_PmIn, Tr_PmOut,;
           Tr_AmInUs, Tr_AmOutUs, Tr_PmInUs, Tr_PmOutUs, Tr_PmOutOs })
      DbSkip()
   enddo
   if Len(aFields)==0
      aAdd(aFields,{RecCount()+1," ",ctod(""),;
           space(5),space(5),space(5),space(5),;
           ' ', ' ', ' ', ' ', ' ' })
   endif
   aSort(aFields,,,{ |x,y| x[3] < y[3] })
return aFields


static function ShowStatus()
local wScreen, aMins := array(5), aStatus := array(5)
local UTstat := {"Deductable to Keyholder","Deductable to Employee","Not Deductable"}
local OTstat := {"Applicable","Not Applicable"}
if !empty(Tr_AmInUs)
    aMins[1] := transform(MinDiff("08:30",Tr_Amin ),"999")
    aMins[2] := transform(MinDiff(Tr_Amout,"12:00"),"999")
    aMins[3] := transform(MinDiff("13:00",Tr_Pmin ),"999")
    aMins[4] := transform(MinDiff(Tr_Pmout,"17:30"),"999")
    aMins[5] := transform(MinDiff("17:30",Tr_Pmout),"999")
    aStatus[1] := UTstat[val(Tr_AmInUs) ]
    aStatus[2] := UTstat[val(Tr_AmOutUs)]
    aStatus[3] := UTstat[val(Tr_PmInUs) ]
    aStatus[4] := UTstat[val(Tr_PmOutUs)]
    aStatus[5] := OTstat[val(Tr_PmOutOs)]
    Message("Press any key to continue...")
    wScreen := OpenWindow(07,10,18,70,"Undertime/Overtime Status")
    @ 09, 12 say "Date : " + cMonth(Tr_Date) + " " + ;
                 substr(dtos(Tr_Date),7,2) + ", " + ;
                 substr(dtos(Tr_Date),1,4) + " - " + cDow(Tr_Date)
    cdow(Tr_Date)
    @ 11, 12 say "             Time     UT/OT Mins           Status          "
    @ 12, 12 say "อออออออออัออออออออออัออออออออออออัออออออออออออออออออออออออ "
    @ 13, 12 say " AM IN   ณ  "+ Tr_AmIn  +"   ณ  "+ aMins[1] +" mins  ณ "+ aStatus[1]
    @ 14, 12 say " AM OUT  ณ  "+ Tr_AmOut +"   ณ  "+ aMins[2] +" mins  ณ "+ aStatus[2]
    @ 15, 12 say " PM IN   ณ  "+ Tr_PmIn  +"   ณ  "+ aMins[3] +" mins  ณ "+ aStatus[3]
    @ 16, 12 say " PM OUT  ณ  "+ Tr_PmOut +"   ณ  "+ aMins[4] +" mins  ณ "+ aStatus[4]
    @ 17, 12 say " OT (PM) ณ  "+ Tr_PmOut +"   ณ  "+ aMins[5] +" mins  ณ "+ aStatus[5]
    @ 18, 12 say "อออออออออฯออออออออออฯออออออออออออฯออออออออออออออออออออออออ "
    inkey(0)
    CloseWindow(wScreen)
 else
   Message("Empty slot...")
   Bummer()
   inkey(1)
 endif
return nil

static function Help()
local ccur,wHelp,col:=2
 ccur:= setcursor(0)
 wHelp:=OpenWindow(03,1,22,51,"Help Window")
 Message(" F2 for individual Status")
 setpos(04,col)
 @ row()+1,col say "Date   - The date of work in (mm-dd-yr)"
 @ row()+1,col say "AM in  - Time of Punched-in in AM (hr:mn)"
 @ row()+1,col say "AM out - Time of Punched-out in Noon (12:00)"
 @ row()+1,col say "PM in  - Time of Punched-in after Lunch (13:00)"
 @ row()+1,col say "PM out - Time of Punched-out in PM (hr:mn)"
 @ row()+1,col say "AM in UT  - Undertime = (AM in) less (08:30)"
 @ row()+1,col say "AM out UT - Undertime = (12:00) less (AM out)"
 @ row()+1,col say "PM in UT  - Undertime = (PM in) less (13:00)"
 @ row()+1,col say "PM out UT - Undertime = (17:30) less (PM out)"
 @ row()+1,col say "PM out OT - Overtime = (PM out) less (17:30)"
 @ row()+1,col say "๙:UT&OT are processed accrdng to status(1,2 or 3)"
 @ row()+1,col say "***** Status Reference :"
 @ row()+1,col say "  1 - Door Closed Deductable to KeyHolder "
 @ row()+1,col say "  2 - Undertime Deductable to Employee or "
 @ row()+1,col say "      If Overtime is Approved"
 @ row()+1,col say "  3 - Not Applicable. If Undertime is lessthan or"
 @ row()+1,col say "      equal to 0 or if Overtime is Disapproved."
 Inkey(0)
CloseWindow(wHelp)
Setcursor(ccur)
return nil

// end-of-file
