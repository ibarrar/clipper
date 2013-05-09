//File: Module.prg
//Author Rollie C. Ibarra Jr.
//

#include "Inkey.ch"

#define COLOR1 if(isColor(),"W/N,W+/B,N,N,G+/N","W/N,W+/B,N,N,W/N")
#define REVCOL if(isColor(),"N/W,W+/B,N,N,G+/N","N/W,W+/B,N,N,W/N")
#define WG     if(isColor(),"N/W,W+/B,N,N,G+/N","W/N,W+/B,N,N,W/N")

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

static BarActive,SubActive,wSub,n,x

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
        x:= if(x=len(list),1,x+1)
   case Mode = LEFT
        x:= if(x=1,len(list),x-1)
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
return if(subactive,{x,Subx},nil)

function Help()
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

function Help2()
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

function OpenW(T,L,aList_)
local cWindow,icol,len:= 0
 aeval(aList_, { |s| len := max(len(s),len )} )
 if T = nil ; T := 8 ; endif
 if L = nil ; L := (72-len)/2 ; endif
 B:= T+2+(len(alist_))
 R:= L+len+8
 cWindow:= chr(T)+chr(L)+chr(B+1)+chr(R+1)+Savescreen(T,L,B+1,R+1)
 icol := setcolor(if(iscolor(),"R/W","W+/N"))
  @ T+((B-T)/2),L+((R-L)/2) say "л"
  tone(5015,.18)
  @ T+((B-T)/3),L+((R-L)/3),B-((B-T)/3),R-((R-L)/3) box "лплллмлл "
  tone(15,.46)
  @ T+((B-T)/4),L+((R-L)/4),B-((B-T)/4),R-((R-L)/4) box "лплллмлл "
  tone(3015,.78)
  @ T,L,B,R box "лплллмлл "
  setcolor(WG)
 for i:= 1 to len(aList_)
  @ T+i+1,L+4 say aList_[i]
 next i
 shadow(T,L,B,R)
 setcolor(icol)
return cWindow

function CloseW(cWindow)
 RestScreen(Asc(Substr(cWindow,1,1)),;
            Asc(Substr(cWindow,2,1)),;
            Asc(Substr(cWindow,3,1)),;
            Asc(Substr(cWindow,4,1)),;
            Substr(cWindow,5))
return nil

function arrow(StartR,StartC,EndR,EndCol,Erase)
 midR:= Max(EndR,StartR)-int(abs(startR-EndR)/2)
if Erase != nil
wArrow:=savescreen(min(StartR,EndR),min(StartC,EndCol),;
                   max(StartR,EndR),max(StartC,EndCol))
endif
if StartR>EndR
   for i:= StartR-1 to EndR step-1
    @ i,if(i>midR,StartC,EndCol) say "Г"
   next
      @ MidR,min(StartC,EndCol) say repl("Ф",max(StartC,EndCol)-;
                                             (min(StartC,EndCol)))

      @ midR,StartC say if(StartC<EndCol,"к","П")
      @ midR,EndCol say if(StartC<EndCol,"й","Р")
      @ EndR,EndCol say chr(30)
else
   for i:= StartR to EndR-1
    @ i,if(i<midR,StartC,EndCol) say "Г"
   next
      @ MidR,min(StartC,EndCol) say repl("Ф",(max(StartC,EndCol) -;
                                         (min(StartC,EndCol))))

      @ midR,StartC say if(StartC<EndCol,"Р","й")
      @ midR,EndCol say if(StartC<EndCol,"П","к")
      @ EndR,EndCol say chr(31)
endif

if erase != nil
inkey(erase)
EndBreak()
restscreen(min(StartR,EndR),min(StartC,EndCol),;
           max(StartR,EndR),max(StartC,EndCol),wArrow)
endif
return nil

function activateBar()
local xcol
   xcol:= setcolor(REVCOL)
   @ 1,0 clear to 1,80
   Rpos:=Cpos:=1
   for i:=1 to len(MainBar)
   Cpos:= Showbar(mainbar[i,1],Rpos,Cpos,.f.)
   next
   setcolor(xcol)
return nil

function showbar(Rawbar,row,col,active)
local color
static x
       x:=at( "~" , Rawbar )
       if x > 0
          Bar:=stuff(rawbar,x,1,"")
          char:=substr(Bar,x,1)
       else
          Bar := rawbar
       endif
       color:=setcolor(if(active,COLOR1,REVCOL))
       @ row,col say Bar
       if x > 0
          setcolor(if(active,"W+/B","B/W"))
          @ row,col+x-1 say char
       endif
       setcolor(color)
       col+= len(bar)
return col

function SayMsg(Msg)
Msgcol:=setcolor("X/W")
  @ 24,0 clear to 24,79
  @ 24,0 say Msg
  setcolor(MsgCol)
return nil
