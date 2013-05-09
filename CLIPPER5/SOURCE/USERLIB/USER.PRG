// Module for TUTOR.prg
// BY ROLANDO C. IBARRA JR.

#include "Inkey.ch"

#define COLOR1 if(isColor(),"W/N,W+/B,N,N,G+/N","W/N,W+/B,N,N,W/N")
#define REVCOL if(isColor(),"N/W,W+/B,N,N,G+/N","N/W,W+/B,N,N,W/N")

#define VIEW_MODE   0
#define EDIT_MODE   1
#define APPEND_MODE 2

#define ACTIVE     .t.
#define DEAD       .f.

#define INIT        0
#define ESC         1
#define ALTKEY      2
#define RIGHT       3
#define LEFT        4
#define ENTER       5
#define UP          6
#define DOWN        7
#define SHFKEY      8
#define UP10        10
#define DN10        11
#define HOME        12
#define ENDK        14
#define F2          15
#define EDIT        16
#define DEL         17

#define BAR         " F10-Menu  "+chr(27)+chr(18)+chr(26)+"-Navigate "+;
                    " Enter"+chr(17)+chr(217)+"-Select  Alt+X-Exit"
#define CDBAR       " F1-Help  F2-Add  F3-Edit  F4-Delete  F5-Search "+;
                    " F6-Totals  F9-Update  Esc-Abort"
static list:={{1,nil,{65,88}},;
             {4,K_ALT_B,{68,82,83}},;
             {11,K_ALT_V,{80,74}},;
             {20,K_ALT_R,{68,82,83,80,74}},;
             {28,K_ALT_L,{nil}},;
             {36,K_ALT_F,{65,66,73}},;
             {40,K_ALT_M,{66,82}}}

static aList_:={{ {"01-111",00,3000,.f.},;
                {"10-511",3000,00,.f.} }},;
       aList
static BarActive,SubActive,wSub,n,x

function files()
BEGIN SEQUENCE
wAny:= OpenW(11,,{"You have just performed an Option from the Main Menu.",;
                  "    Now you can use the Main Menu to open a file...",;
                  "        To activate Menu bar press F10.","",;
                  "Choose the 'Cash Disbursement Book' options under",;
                  "   'Books' on the Main menu then press ENTER.","",;
                  "    Consult your Manual or press F1 for Help."})

do while (x<>2) .or. (value<>1)
 ckey:=inkey(20)
  do case
     case ckey= K_F1
        Help()
        SayMsg(BAR)
     case ckey= K_CTRL_Q
        if alert(" Exit program now ? ",{" Yes "," No "})==1
           Exit:= .t.
           BREAK
        endif
        keyboard chr(K_ENTER)
     case ckey= K_F10
        value:=TestUser(ckey)
        if Exit ; BREAK; endif
        if (x<>2) .or. (value<>1)
           wTest:= OpenW(16,4,{"Normally, in this circustances it's Ok to",;
                               "choose other options in the Main Menu.","",;
                               "  But for now, just follow the instruction",;
                               "in the tutor box."})
           xDisp(Mainbar[x,2,value,1])
           if Exit ; BREAK; endif
           inkey(4.4)
           if EndBreak() ; BREAK; endif
           CloseWindow(wTest)
        endif
   otherwise
      feed2()
   endcase
if Exit ; BREAK; endif
enddo
CloseW(wAny)
CDB()
if Exit ; BREAK; endif
*SayMsg(BAR)
END SEQUENCE
return nil


function TestUser(nkey)
local select:=0,cpos:=2
BEGIN SEQUENCE
X := 1
OkOut:=DEAD
SubActive:=DEAD
BarActive:=DEAD
Do while !OkOut
SayMsg(BAR)
if nkey<>K_F10
   nKey := Inkey(0)
endif
   if EndBreak(); BREAK ; endif
   if nkey=K_F1 ; Help() ; endif
   if BarActive .or. nKey=K_F10
   if Exit ; BREAK; endif
      do case
         case nkey = K_F10
               DoMainBar(INIT)
         case nkey = K_UP   // Only if SubMenu is Active
              if SubActive
                 DoMainBar(UP)
              endif
         case nkey = K_DOWN // Only if SubMenu is Active
              if SubActive
                 DoMainBar(DOWN)
              endif
         case nkey = K_LEFT
              DoMainBar(LEFT)
         case nkey = K_RIGHT
              DoMainBar(RIGHT)
         case nkey = K_ENTER
              if SubActive ; OkOut := ACTIVE ; endif
              select:=DoMainBar(ENTER)
         case nkey = K_ESC
              DoMainBar(ESC)
         otherwise
              n:=aScan(list,{ |l_| nkey=l_[2] })
              if SubActive .and. n=0
                 n:=aScan(list[x,3],nkey)
                 if n>0
                   DoMainBar(SHFKEY)
                 endif
              elseif n>0
                DoMainBar(ALTKEY)
              endif
      endcase
   endif
   if Exit ; BREAK; endif
nkey:= 0
enddo
END SEQUENCE
return select


static function DoMainBar(Mode)
static position,maxl,Subx,ii
if x=1 ; position := 1; endif
if empty(Subx); Subx:=1; endif
if    Mode < 6
    Showbar(mainbar[x,1],1,position,.f.)
    if BarActive .and. SubActive
     restscreen(2,position,(4+len(mainbar[x,2])),(maxl+position+2),wSub)
    endif
else
showbar(padR(mainbar[x,2,Subx,1],maxl),2+Subx,position+1,.f.)
endif
do case
   case Mode = INIT
        SubActive:=if(BarActive,SubActive,.f.)
        BarActive:=!BarActive
        x:=if(BarActive,x,1)
   case Mode = RIGHT
        x:= if(x=7,1,x+1)
   case Mode = LEFT
        x:= if(x=1,7,x-1)
   case Mode = UP
        Subx:=if(Subx=1,len(mainbar[x,2]),Subx-1)
   case Mode = DOWN
        Subx:=if(Subx=len(mainbar[x,2]),1,Subx+1)
   case Mode = ENTER
        if SubActive
           BarActive:=DEAD
        else
           SubActive := .t.
        endif
   case Mode = ESC
        BarActive:=SubActive:=DEAD
        x:=if(BarActive,x,1)
   case Mode = ALTKEY
        x:=n; SubActive:= ACTIVE
   case Mode = SHFKEY
        Subx:= n
endcase
if Mode < 6
    position:=(list[x,1])
    Showbar(mainbar[x,1],1,position,BarActive)
    if SubActive .and. BarActive
        maxl:=0
        aEval(mainbar[x,2],{ |s_| maxl:= max(len(s_[1]),maxl) })
        wSub:=savescreen(2,position,(4+len(mainbar[x,2])),(maxl+position+2))
        shadow(2,position,(3+len(mainbar[x,2])),(maxl+position+1))
        setcolor(REVCOL)
        @ 2,position clear to (3+len(mainbar[x,2])),(maxl+position+1)
        @ 2,position to 3+len(mainbar[x,2]),maxl+position+1
        for ii:= 1 to len(mainbar[x,2])
        showbar(padR(mainbar[x,2,ii,1],maxl),2+ii,position+1,if(ii=1,.t.,.f.))
        next
        setcolor(COLOR1)
        Subx:=1
    endif
else
    showbar(padr(mainbar[x,2,Subx,1],maxl),2+Subx,position+1,.t.)
endif
return if(subactive,Subx,nil)

static function Help()
local wHelp
BEGIN SEQUENCE
wHelp:=OpenWindow(3,14,21,72,"Help Window ")
@ 4,16 say       "         Key Specification on Main Menu Set-Up."
@ row()+1,16 say "F10            - Activates or Deactivates Main Menu Bar"
@ row()+1,16 say "RightArrow Key - Moves the Highlighted Bar to the right"
@ row()+1,16 say "LeftArrow Key  - Moves the Highlighted  Bar to the left"
@ row()+1,16 say "UpArrow  Key   - Only applicable if  the  Sub-Menus are"
@ row()+1,16 say "                 active. Moves Highlighted Bar Upwards."
@ row()+1,16 say "DownArrow  Key - Only applicable if  the  Sub-Menus are"
@ row()+1,16 say "                 active. Moves Highlighted Bar Upwards."
@ row()+1,16 say "ENTER          - Accepts Selection, shows  Sub-Menus or"
@ row()+1,16 say "                 Executes highlighted option."
@ row()+1,16 say "ALT + char.    - Selects option  w/ corresponding char."
@ row()+1,16 say "                 and pull-down its  submenu or executes"
@ row()+1,16 say "                 the chosen option."
@ row()+1,16 say "SHIFT + char.  - Same as ALT+?  but this one works only"
@ row()+1,16 say "                 on Sub-Menus."
@ row()+1,16 say "ESCAPE Key     - Deactivates the Main Menu Bar."
@ row()+1,16 say "ALT-X          - Exits the program back to DOS prompt"
SayMsg("Press any key to go on....")
Inkey(20)
 if EndBreak() ; BREAK; endif
CloseWindow(wHelp)
END SEQUENCE
return nil

function start()
BEGIN SEQUENCE
wAny:= OpenW(11,,{"Now you can try out the Main Menu and Submenu",;
                  "system of this Super Travel, Inc. tutorial",;
                  "Program. To activate Menu bar press F10.","",;
                  "    Look for the 'About Sys.' options on the menu",;
                  "then press ENTER.",;
                  "    There are many ways of reaching this option",;
                  "through the Main Menu bar.","",;
                  "    Consult your Manual or press F1 for Help."})
do while (x<>1) .or. (value<>1)
 ckey:=inkey(20)
 do case
    case ckey= K_F1
      Help()
    case ckey= K_CTRL_Q
        if alert(" Exit program now ? ",{" Yes "," No "})==1
           Exit:= .t.
           BREAK
        endif
        keyboard chr(K_ENTER)
    case ckey= K_F10
        value:=TestUser(ckey)
        if Exit ; BREAK; endif
        if (x<>1) .or. (value<>1)
           wTest:= OpenW(16,4,{"Normally, in this circustances it's Ok to",;
                               "choose other options in the Main Menu.","",;
                               "  But for now, just follow the instruction",;
                               "in the tutor box."})
           xDisp(Mainbar[x,2,value,1])
           if Exit ; BREAK; endif
           inkey(4.4)
           if EndBreak() ; BREAK; endif
           CloseWindow(wTest)
        endif
   otherwise
      feed1()
   endcase
   if Exit; BREAK; endif
enddo
CloseW(wAny)
Eval(Mainbar[x,2,value,2])
if Exit ; BREAK; endif
SayMsg(BAR)
END SEQUENCE

function xDisp(msg)
BEGIN SEQUENCE
msg:=strtran(msg,"~","")
if x = 4
 msg := "Report on "+msg
endif
ccur:=setcursor(0)
wDisp:=OpenW(7,35,{padc("This Option Executes/Performs the",max(33,len(msg))),;
                    padc((msg),max(33,(len(msg)))),;
                   padc("procedure of the program.",max(33,len(msg)))," "})
Inkey(4)
if EndBreak() ; BREAK; endif
CloseW(wDisp)
setcursor(ccur)
END SEQUENCE
return nil

return nil

static function CDB()
local wCDB,nkey,colCDB
private ptr
private mVoucherNo:=padr("CV#23959 ",10),;
      mDate:="01-10-91",;
      mPayee:=padr("SANTOS, MARILE MS.",40),;
      mAgent:=padr("MARCO POLO",40),;
      mAirCode:=padr("Garuuda Indonesia",3),;
      mCheckNo:=padr("PCIB#439098",11),;
      mDetails1:=padr("PYMT FOR TRAVEL TAX FOR PAX SANTOS,",40),;
      mDetails2:=padr("MARILE MS. WITH ROUTE MNL-CKG-LAX.",40)
  BEGIN SEQUENCE
  if empty(ptr); ptr:= 1 ; endif
  aList:={{mVoucherNo,mDate,mPayee,mAgent,mAirCode,mCheckNo,mDetails1,mDetails2}}
  colCDB:=setColor(REVCOL)
  SayMsg("Opening Databases....")
  tone(15,2.5)
  wCDB:=OpenWindow(03,08,13,66,"Cash Disbursement Book")
  CDBScreen(VIEW_MODE)
  if Exit ; BREAK; endif
  notice()
  if Exit ; BREAK; endif
  if LastKey()!=K_ESC
     do While nkey<>K_ESC
        CDBScreen(if(len(aList)=0,APPEND_MODE,VIEW_MODE))
        nkey:=Inkey(0)
         if EndBReak(); BREAK; endif
        do case
           case nkey==K_DOWN
                if ptr==len(aList)
                  tone(300,0.72);tone(528.28,0.28)
                  SayMsg("End of file reached...")
                else
                  ptr++
                endif
                xDisp("Skip to next record")
           case nkey==K_UP
                if ptr==1
                  tone(300,0.78);tone(528.28,0.28)
                  SayMsg("Beginning of file reached...")
                else
                  ptr--
                endif
                xDisp("Skip to previous record")
           case nkey==K_CTRL_PGDN
                if (ptr+10) > len(aList)
                   tone(300,0.62);tone(528.28,0,38)
                   SAyMsg("End of file reached...")
                   ptr:=len(aList)
                else
                   ptr+=10
                endif
                xDisp("Skip to next TEN record")
           case nkey==K_CTRL_PGUP
                if (ptr-10) < 1
                   tone(300,0.38);tone(528.28,0,62)
                   SAyMsg("Beginning of file reached...")
                   ptr:=1
                else
                   ptr:=1
                endif
                xDisp("Skip to last TEN record")
           case nkey==K_END
                SayMsg("Moving to end of file...")
                xDisp("Move to End of file")
                ptr:=len(aList)
           case nkey==K_HOME
                SayMsg("Moving to beginning of file...")
                xDisp("Move to Beginning of file")
                ptr:=1
           case nkey==K_PGDN
                xDisp("Show, Edit, Add transaction")
                Page2(ptr,VIEW_MODE)
           case nkey==K_F1
                Help2()
           case nkey==K_F2
                xDisp("Add new record/s to the database")
                CDBScreen(APPEND_MODE)
           case nkey==K_F3
                xDisp("Edit current existing record")
                CDBScreen(EDIT_MODE)
           case nkey==K_F4
                SayMsg("Press Enter to delete record, ESC to Abort.")
                Inkey(15)
                if EndBReak(); BREAK; endif
                 do while lastkey()<>K_ENTER .and. lastkey()<>K_ESC
                  Inkey(0)
                  if EndBReak(); BREAK; endif
                 enddo
                if lastkey()==K_ENTER
                 xDisp("Delete the Current record from database")
                 aDel(aList,ptr)
                 aSize(aList,len(aList)-1)
                 aDel(aList_,ptr)
                 aSize(aList_,len(aList_)-1)
                endif
           case nkey==K_F5
                xDisp("Search a Particular record")
                SearchPax()
           case nkey==K_F6
                xDisp("Summation of all record Accounts")
           case nkey==K_F9
                xDisp("Update Subsidiary Ledger")
       endcase
       if Exit ; BREAK; endif
   enddo
  endif
  SayMsg("Closing Database...")
  Inkey(2)
  SayMsg(BAR)
if EndBreak(); BREAK; endif
  CloseWindow(wCDB)
  SetColor(colCDB)
  END SEQUENCE

  static function CDBScreen(nMODE)
    local mAirline:="Airline-Code converted to Airline  "
    BEGIN SEQUENCE
    Tone(300,1)
    InitVariables(nMode)
    SayMsg(CDBAR)
    SetColor("W+/BG")
    @ 03,54 say "Rec.# "+transform(If(nMode==APPEND_MODE,len(aList)+1,ptr),"999")+;
    "/"+transform(len(aList),"@B 999")
    SetColor(REVCOL)
    @ 05,10 say "  Voucher No." get mVoucherNo picture "@!"
    @ 06,10 say "         Date" get mDate picture "@D"
    @ 07,10 say "        Payee" get mPayee picture "@!"
    @ 08,10 say "       Agency" get mAgent picture "@!"
    if nMode = VIEW_MODE
       @ 09,10 say "      Airline" get  mAirline
    elseif (nMode==APPEND_MODE) .or. (nMode==EDIT_MODE)
       @ 09,10 clear to 09,58
       @ 09,10 say "      Airline" get mAirCode picture "@! XXX"
    endif
    @ 10,10 say "    Check No." get mCheckNo picture "@!"
    @ 11,10 say "Other Details" get mDetails1
    @ 12,10 say "             " get mDetails2
    if (nMode==APPEND_MODE) .or. (nMode==EDIT_MODE)
       SayMsg("F1-Help  F9-Agencies  F10-Airlines  Esc-Abort")
       SetCursor(1)
       setkey(K_F10,{ || xDisp("Display List of Airlines") })
       setkey(K_F9,{ || xDisp("Display List of Agencies") } )
       setkey(K_CTRL_Q,{ || if(EndBreak(),BREAK,) })
       read
       setkey(K_CTRL_Q)
       setkey(K_F10)
       setkey(K_F9)
       if Exit ; BREAK; endif
       if EndBReak(); BREAK; endif
       if lastkey()<>K_ESC
          if nMode==APPEND_MODE
             aAdd(aList,{nil,nil,nil,nil,nil,nil,nil,nil})
             ptr:=len(aList)
          endif
          if Updated()
           aList[ptr,1]:=mVoucherNo
           aList[ptr,2]:=DtoC(mDate)
           aList[ptr,3]:=mPayee
           aList[ptr,4]:=mAgent
           aList[ptr,5]:=mAirCode
           aList[ptr,6]:=mCheckNo
           aList[ptr,7]:=mDetails1
           aList[ptr,8]:=mDetails2
          endif
          page2(ptr,nMode)
          if Exit ; BREAK; endif
        setCursor(0)
       endif
    else
    clear gets
    endif
  END SEQUENCE
 return nil

  static function InitVariables(nMode)
   if (nMode==APPEND_MODE)
    mVoucherNo:=space(10)
    mDate:=CtoD("  -  -  ")
    mPayee:=Space(40)
    mAgent:=Space(40)
    mAirCode:=Space(3)
    mCheckNo:=Space(11)
    mDetails1:=Space(40)
    mDetails2:=Space(40)
   else
    mVoucherNo:=if(empty(aList[ptr,1]),space(10),padr(aList[ptr,1],10))
    mDate:=CtoD(if(empty(aList[ptr,2]),"  -  -  ",aList[ptr,2]))
    mPayee:=if(empty(aList[ptr,3]),space(40),padr(aList[ptr,3],40))
    mAgent:=if(empty(aList[ptr,4]),space(40),padr(aList[ptr,4],40))
    mAirCode:=padr(aList[ptr,5],3)
    mCheckNo:=if(empty(aList[ptr,6]),space(11),padr(aList[ptr,6],11))
    mDetails1:=if(empty(aList[ptr,7]),space(40),padr(aList[ptr,7],40))
    mDetails2:=if(empty(aList[ptr,8]),space(40),padr(aList[ptr,8],40))
   endif
  return nil

static function Help2()
local wHelp
BEGIN SEQUENCE
SayMsg("Press any key to go on....")
wHelp:=OpenWindow(3,31,23,78,"Help Window ")
@ 4,32 say       "            Keyboard Specification."
@ row()+1,32 say "F1    - Displays this Help Window."
@ row()+1,32 say "F2    - Add/Append record/s to Database."
@ row()+1,32 say "F3    - Update/Edit record/s on Database."
@ row()+1,32 say "F4    - Delete/Erase record/s on Database."
@ row()+1,32 say "F5    - Searches the Database for a record."
@ row()+1,32 say "F6    - Totals transactions of the Database."
@ row()+1,32 say "F9    - Includes the current record to the"
@ row()+1,32 say "        Subsidiary."
@ row()+1,32 say "Up Arrow    - Moves cursor one line Up."
@ row()+1,32 say "Down Arrow  - Moves cursor one line Down."
@ row()+1,32 say "Left Arrow  - Moves cursor one char. to left."
@ row()+1,32 say "Right Arrow - Moves cursor one char. to right."
@ row()+1,32 say "Page Down   - Show 2ng Page."
@ row()+1,32 say "SPACE Bar   - Adds a space."
@ row()+1,32 say "BACK SPACE  - Removes a space."
@ row()+1,32 say "            - Delete one character on left."
@ row()+1,32 say "DEL     - Delete character at cursor position."
@ row()+1,32 say "ESC     - Abort current operation and returns"
@ row()+1,32 say "          to the previous."
Inkey(20)
if EndBReak(); BREAK; endif
CloseWindow(wHelp)
END SEQUENCE
return nil

function EndBreak()
 if lastkey()==K_CTRL_Q
            if alert(" Exit program now ? ",{" Yes "," No "}) == 1
              Exit:= .t.
            endif
            keyboard chr(K_ENTER)
          endif
return exit

static function SearchPax()
local xn,tptr,nkey,cName:=Space(40)
BEGIN SEQUENCE
  wSearch:=OpenWindow(06,18,10,61,"Search Mode")
  @ 08,20 say "Enter name to search"
  @ 09,20 get cName picture "@!"
  SetCursor(1)
  setkey(K_CTRL_Q, { || IF(EndBreak(),BREAK,) })
  read
  setkey(K_CTRL_Q)
  cName:= Alltrim(cName)
     tPtr:=ptr
  CloseWindow(wSearch)
  SetCursor(0)
  xn:=1
  if lastkey() <> K_ESC
     do while xn <= len(aList)
       if aList[xn,3] = Upper(cName) ; Exit ; endif
       xn+=1
     enddo
     do while xn <= len(aList)
        ptr:=xn
        CDBScreen(VIEW_MODE)
        SayMsg("press ENTER to continue search,  ESC to abort...")
        nKey:= 0
        do while (nkey!=K_ENTER) .and. (nkey!=K_ESC)
           nkey:= Inkey(0)
           if EndBReak(); BREAK; endif
        enddo
     if nkey==K_ESC
        exit
     else
        xn++
        do while xn <= len(aList)
            if aList[xn,3] = Upper(cName);Exit;endif
        enddo
     endif
     enddo
     if  xn > len(aList)
      Tone(100,3)
      SayMsg("Name not found....")
      inkey(2)
      if EndBReak(); BREAK; endif
      ptr:=tptr
     endif
   else
      Tone(100,3)
      SayMsg("Name not found....")
      inkey(2)
      if EndBReak(); BREAK; endif
      ptr:=tptr
   endif
END SEQUENCE
return nil

return nil

static function page2(ptr,nMode)
local nkey,wbrowse
private nBalance,aPict_:={{"XXXXXX",8},{"9,999,999.99",20},{"9,999,999.99",35}}
BEGIN SEQUENCE
if nMode = VIEW_MODE
  SayMsg(" F10-Acct Titles  Esc-Abort")
else
  SayMsg(" F2-Add  F4-Delete  F10-Acct Titles  Esc-Abort")
endif
 Tone(300,1)
 wBrowse:=OpenWindow(06,02,21,50,"Accounts")
 @ 08,03 say "     Acct Code   Debit          Credit"
 @ 09,03 say "ออัออออออออออออัออออออออออออออัอออออออออออออออ"
 @ 19,03 say "ออฯออออออออออออฯออออออออออออออฯอออออออออออออออ"
 @ 06,50 say chr(24)
 for i:=07 to 20
     @  i,50 say chr(176)
 next
 @ 21,50 say chr(25)
 while ptr > len(aList_)
  aAdd(aList_,{{space(6),00,00,.f.}})
 enddo
 MoveCell(ptr,INIT)
 do while .t.
    nkey:= Inkey(0)
    if EndBReak(); BREAK; endif
    do case
       case nkey==K_UP
           MoveCell(ptr,UP)
       case nkey==K_DOWN
           MoveCell(ptr,DOWN)
       case nkey==K_LEFT
           MoveCell(ptr,LEFT)
       case nkey==K_RIGHT
           MoveCell(ptr,RIGHT)
       case nkey==K_PGUP
           MoveCell(ptr,UP10)
       case nkey==K_PGDN
           MoveCell(ptr,DN10)
       case nkey==K_HOME
           MoveCell(ptr,HOME)
       case nkey==K_END
           MoveCell(ptr,ENDK)
       case nkey==K_ESC
           EXIT
       case nkey==K_F10
           xDisp("Display List of Account Title w/ Codes")
       case (nkey==K_F2) .and. (nMode<>VIEW_MODE)
           xDisp("Add an Account in table")
           MoveCell(ptr,F2)
       case ((nkey==K_F4).or.(nkey==K_DEL)).and.(nMode!=VIEW_MODE).and.(len(aList_[ptr])>1)
           xDisp("Delete an Account in table")
           MoveCell(ptr,DEL)
       case ((nkey==K_ENTER) .or. (Isdata(nkey))) .and. (nMode<>VIEW_MODE)
           If nkey!=K_ENTER ; KeyBoard chr(nkey) ; endif
           MoveCell(ptr,EDIT)
    endcase
    if Exit ; BREAK; endif
  enddo
CloseWindow(wBrowse)
END SEQUENCE

static function MoveCell(ptr,Mode)
static xx,y,rely,relpos,nBalance
local ccol,temp
BEGIN SEQUENCE
  if empty(xx) .or. Mode=INIT ; xx:=1 ; endif
  if empty(y) .or. Mode=INIT ; y:=1 ; endif
  if empty(rely) .or. Mode=INIT ; rely:=1 ; endif
  if empty(relpos) .or. Mode=INIT ; relpos:= 1; endif
  @ (09+rely),(aPict_[xx,2]) say transform(aList_[ptr,y,xx],aPict_[xx,1])
    do case
       case Mode = INIT
         clean()
         for i:= 1 to min(Len(aList_[ptr]),9)
            for k:= 1 to 3
                @ (09+i),(aPict_[k,2]) say transform(alist_[ptr,i,k],aPict_[k,1])
            next
         @ (09+i),4 say if(alist_[ptr,i,4],chr(4)," ")
         next
       case Mode = UP
         if y > 1
            rely--
            if  rely = 0
                scroll(10,4,18,48,-1)
                @  10,03 say "  ณ            ณ              ณ                "
               rely:=1
               for k:= 1 to 3
        @ 09+rely,(aPict_[k,2]) say transform(alist_[ptr,y-1,k],aPict_[k,1])
               next
               @ 09+rely,4 say if(alist_[ptr,y-1,4],chr(4)," ")
            endif
            y--
         endif
       case Mode = DOWN
         if y < Len(aList_[ptr])
           rely++
           if y >= 9 .and. rely > 9
            scroll(10,4,18,48,1)
            @  18,03 say "  ณ            ณ              ณ                "
            rely:=9
            for k:= 1 to 3
        @ 09+rely,(aPict_[k,2]) say transform(alist_[ptr,y+1,k],aPict_[k,1])
            next
            @ 09+rely,4 say if(alist_[ptr,y+1,4],chr(4)," ")
           endif
           y+=1
         endif
       case Mode = LEFT
         xx:=if(xx>1,xx-1,1)
       case Mode = RIGHT
         xx:=if(xx<3,xx+1,3)
       case Mode = UP10
        @ 10,4 clear to 18,4
       for i:= 1 to len(aList_[ptr])
            if aList_[ptr,i,4]
            aDel(aList_[ptr],i)
            aSize(aList_[ptr],len(aList_[ptr])-1)
            i--
            endif
         next
         if empty(aList_[ptr])
            aAdd(aList_[ptr],{space(6),00,00,.f.})
            y:=rely:=1
         endif
         for i:=max(y-8,1) to min(len(aList_[ptr]),y)
            for k:= 1 to 3
             @ (10+(i-max(y-8,1))),(aPict_[k,2]) say transform(alist_[ptr,i,k],aPict_[k,1])
            next
         next
         y:=max(y-8,1);rely:=1
       case Mode = DN10
       clean()
       for i:= 1 to len(aList_[ptr])
            if aList_[ptr,i,4]
            aDel(aList_[ptr],i)
            aSize(aList_[ptr],len(aList_[ptr])-1)
            i--
            endif
         next
         if empty(aList_[ptr])
            aAdd(aList_[ptr],{space(6),00,00,.f.})
            y:=rely:=1
         endif
         for i:=y to min(len(aList_[ptr]),y+8)
            for k:= 1 to 3
             @ (10+i-y),(aPict_[k,2]) say transform(alist_[ptr,i,k],aPict_[k,1])
            next
         next
         rely:=if(len(aList_[ptr])<=1,1,i-y)
         y:=min(len(aList_[ptr]),y+8)
       case Mode = HOME
         y:=1; xx:=1
       case Mode = ENDK
         y:=len(aList_[ptr]); xx:=1
       case Mode = F2
         clean()
         for i:= 1 to len(aList_[ptr])
            if aList_[ptr,i,4]
            aDel(aList_[ptr],i)
            aSize(aList_[ptr],len(aList_[ptr])-1)
            i--
            endif
         next
         for i:= max(1,(len(aList_[ptr])-8)) to len(aList_[ptr])
            for k:= 1 to 3
             @ (10+(i-max(1,(len(aList_[ptr])-8)))),(aPict_[k,2]) say transform(alist_[ptr,i,k],aPict_[k,1])
            next
         next
         aAdd(aList_[ptr],{space(6),00,00,.f.})
         y:=len(aList_[ptr])
         xx:=1;rely:=y
         if y > 9
          scroll(10,4,18,48,1)
          @  18,03 say "  ณ            ณ              ณ                "
          rely:=9
         endif
         for k:= 1 to 3
          @ 09+rely,(aPict_[k,2]) say transform(alist_[ptr,y,k],aPict_[k,1])
         next
       case Mode = EDIT
         temp:= aList_[ptr,y,xx]
         lLastExit:=ReadExit(.t.)
         @ 09+rely,aPict_[xx,2] Get temp picture aPict_[xx,1]
         setkey(K_CTRL_Q,{ || if(Endbreak(),BREAK,)})
         read
         setkey(K_CTRL_Q)
         ReadExit(lLastExit)
         if Updated() .and. LastKey()!=K_ESC
          aList_[ptr,y,xx]:= temp
          if xx!= 3
           @ (09+rely),(aPict_[xx,2]) say transform(aList_[ptr,y,xx],aPict_[xx,1])
           xx++
          endif
         endif
       case Mode =DEL
         aList_[ptr,y,4]:=!aList_[ptr,y,4]
         @ 09+rely,04 say if(aList_[ptr,y,4],chr(4)," ")
    endcase
  ccol:=setcolor("W/N")
  @ (09+rely),(aPict_[xx,2]) say transform(aList_[ptr,y,xx],aPict_[xx,1])
  setcolor(ccol)
  tempos:=if(y=1,1,min((y/len(aList_[ptr]))*14,14))
  if tempos!=relpos
   @ (06+relpos),50 say chr(176)
   relpos := tempos
   @ (06+relpos),50 say chr(177)
  endif
  tBalance:=0
  for n:=1 to y
    tBalance+=((aList_[ptr,n,2]) - (aList_[ptr,n,3]))
  next
  if tBalance!=nBalance
    nBalance:=tBalance
    @ 20,35 clear to 20,47
    @ 20,21 say "Balance ----> "+Transform(nBalance,"@( 9,999,999.99")
  endif
  @ 09+rely,(aPict_[xx,2]) say ""
END SEQUENCE

static function clean()
  for i:=10 to 18
   @  i,03 say "  ณ            ณ              ณ                "
  next
return nil

return nil

static function feed1()
ywAny:=OPenW(6,,{"Press F10, choose  ' "+chr(240)+" '  Press Enter, and choose",;
                 " 'About Sys.' (press Shf+A), then Press Enter.","",;
                 "With cursors Press Left/Right arrow keys to Move",;
                 " the selection Horizontally to  ' "+chr(240)+" '  .",;
                 "Use Up/Down arrow keys to Move selection Vertically",;
                 " to 'About Sys.', then press Enter.",""})
inkey(15)
if EndBReak(); BREAK; endif
CloseW(ywAny)
return nil

static function feed2()
xwAny:=OPenW(6,,{"Press F10, choose Books (press Alt+B), Press Enter and ",;
                 "choose 'Cash Disbursment Books' (press Sft+D), then Enter.","",;
                 "With cursors, Press Left/Right arrow keys to Move",;
                 "      the selection to 'Books'.",;
                 "Press ENTER to activate SubMenu, Highlight 'Cash",;
                 "Disbursment Books' from selection then press Enter.",""})
inkey(15)
if EndBReak(); BREAK; endif
CloseW(xwAny)
return nil

function report()
BEGIN SEQUENCE
wCol:=Setcolor()
wAny:= OpenW(11,,{"Another common utility used in most of Super Travel,",;
                  "   Inc. programs are the REPORT form generator.",;
                  "        To activate Menu bar press F10.","",;
                  "Choose any of the Selection under the 'Report' option",;
                  "       on the Main menu then press ENTER.","",;
                  "    Consult your Manual or press F1 for Help."})
do while (x<>4) .or. (value>6) .or. (value<1)
 ckey:=inkey(20)
  do case
     case ckey= K_F1
        Help()
        SayMsg(BAR)
     case ckey= K_CTRL_Q
        if alert(" Exit program now ? ",{" Yes "," No "})==1
           Exit:= .t.
           BREAK
        endif
        keyboard chr(K_ENTER)
     case ckey= K_F10
        value:=TestUser(ckey)
        if Exit ; BREAK; endif
        if (x<>4) .or. (value>6) .or. (value<1)
           wTest:= OpenW(16,4,{"Normally, in this circustances it's Ok to",;
                               "choose other options in the Main Menu.","",;
                               "  But for now, just follow the instruction",;
                               "in the tutor box."})
           xDisp(Mainbar[x,2,value,1])
           if Exit ; BREAK; endif
           inkey(4.4)
           if EndBreak() ; BREAK; endif
           CloseWindow(wTest)
        endif
   otherwise
      feed3()
   endcase
if Exit ; BREAK; endif
enddo
CloseW(wAny)
   dStartDate:=dEndDate:=CToD("  -  -  ")
   cOutput:="N"
   Message("Enter transaction dates, press Esc to abort.")
   wDate:=OpenWindow(09,15,14,63,"Date Information Box")
   @ 11,17 say "Enter starting date (MM/DD/YY format)" get dStartDate
   @ 12,17 say "        Ending date (MM/DD/YY format)" get dEndDate
   @ 13,17 say " Output report to line printer (Y,N)?" get cOutput picture "Y"
   w1:=OpenW(16,,{"Dates on which the program will start",;
                  "and end processing records on specific",;
                  "Book or Voucher.","",;
                  " And optionally directs processed data",;
                  "to the line printer."})
   SetCursor(1)
   read
   SetCursor(0)
   CloseW(w1)
   CloseWindow(wDate)
If LastKey()!=K_ESC
  xDisp(Mainbar[x,2,value,1])
endif
if Exit ; BREAK; endif
setColor(wCol)
END SEQUENCE
return nil

//EOFILE-------------->