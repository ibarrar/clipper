/* Filename TUTOR.prg
 * Module   Tutorial Module
 * Author   Rolando C. Ibarra Jr.
 */


#include "inkey.ch"
#include "SetCurs.ch"

#define COLOR1 if(isColor(),"W/N,W+/B,N,N,G+/N","W/N,W+/B,N,N,W/N")
#define REVCOL if(isColor(),"N/W,W+/B,N,N,G+/N","N/W,W+/B,N,N,W/N")
#define WG     if(isColor(),"N/W,W+/B,N,N,G+/N","W/N,W+/B,N,N,W/N")
#define PRESS  chr(16)+" Press any key to go on..."
#define BAR    " F10-Menu  "+chr(27)+chr(18)+chr(26)+"-Navigate  Enter"+chr(17)+;
               chr(217)+"-Select  Alt+X-Exit"

function main()
local aIst_:= {"°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°",;
               "°°°°°°°°°ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ°°°°°°°°ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿°°",;
               "°°°°°°°°°ÛÛÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»ÛÛ°°°°°°°°³ Copyright (c) 1993 by       ³ °",;
               "°°°°°°°°°ÛÛº       TUTORIAL         ºÛÛ°°°°°°°°³ Super Travel, Inc.          ³ °",;
               "°°°°°°°°°ÛÛº         for            ºÛÛ°°°°°°°°³                             ³ °",;
               "°°°°°°°°°ÛÛº  ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿  ºÛÛ°°°°°°°°³ All products are trademarks ³ °",;
               "°°°°°°°°°ÛÛºÚÄÙSuper Travel, Inc.ÀÄ¿ºÛÛ°°°°°°°°³ or registered trademark of  ³ °",;
               "°°°°°°°°°ÛÛº³Integrated Development³ºÛÛ°°°°°°°°³ Super Travel, Inc.          ³ °",;
               "°°°°°°°°°ÛÛºÀÄÄÄÄ¿Environment ÚÄÄÄÄÙºÛÛ°°°°°°°°³                             ³ °",;
               "°°°°°°°°°ÛÛÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼ÛÛ°°°°°°°°³ "+chr(16)+" Press any key to go on... ³ °",;
               "°°°°°°°°°ßßßÛßßßßßßßßßßßßßßßßßßßßßßÛßßß°°°°°°°°³ *** Control+ Q  to Exit *** ³ °",;
               "°°°°ÉÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÏÍÑÍÍÍÍÍÍÍÍÍÍ»°°°ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ °",;
               "°°°°ºÕÍÍ¸  øPower////////// ÚÄ¿ ³ÚÄÄÄÄÄÄÄÄ¿º°°°°                               °",;
               "°°°°ºÔÍÍ¾ øTurbo//////////  ³Å³ ³ÔÍÍÍÍÍÍÍÍ¾º°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°",;
               "°°°°º    øH.Disk/////////   ³Å³ ÃÄÄÄÄÄÄÄÄÄÄÇ¿°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°",;
               "°°@@º  ê O O ///////////    ÀÄÙ ³ ÍÍÍÍÍÍÏÍ ÇÙ°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°",;
               "°°@°ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍ¼°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°",;
               "°@@°°°°°°°°°°°°°°°°°°°ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿°°°°°°°°°°°°°°°°°°°°°°°°",;
               "@@°°°°°°°°°°°°°°°°°°@@³Ú¿ ÚÚÚÚÚ ÚÚÚÚÚ ÚÚÚÚÚ Ú¿Ú¿Ú¿ß ß ß³°°°°°°°°°°°°°°°°°°°°°°°°",;
               "°@@°°°°°°°°°°°°°°°°@@°³Ú¿Ú¿Ú¿Ú¿Ú¿Ú¿Ú¿Ú¿Ú¿ÚÄ¿Ä¿Ä¿Ä¿ÚÚÚÚÚ³°°°°°°°°°°°°°°°°°°°°°°°°",;
               "°°@@°°°°°°°°°°°°°°°°@@³ÚÄ¿Ú¿Ú¿Ú¿Ú¿Ú¿Ú¿Ú¿¿ÚÄ¿Ä¿Ä¿Ä¿ÚÚÚÚÚ³°°°°°°°°°°°°°°°°°°°°°°°°",;
               "°°°@@@°°@@@°°°°°°°@@@°³ÚÄ¿¿Ú¿Ú¿Ú¿Ú¿Ú¿Ú¿ÚÚÙ ³  Ä¿  ÚÚÚÚÚ³°°°°°°°°°°°°°°°°°°°°°°°°",;
               "°°°°°@@@@°@@@°°°°@@°°°³Ú¿ ÚÄ¿ÚÄÄÄÄÄÄÄ¿ÚÄ¿ÚÄ¿Ä¿Ä¿Ä¿ÚÄ¿Ú³³°°°°°°°°°°°°°°°°°°°°°°°°",;
               "°°°°°°°°°°°°°@@@@°°°°°ÀÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÙ°°°°°°°°°°°°°°°°°°°°°°°°",;
               "°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°"}

public Exit:= .f.
public MainBar:={{" ğ ",{{" ~About Sys.  ",{ || About(.f.) }},;
                         {" E~xit Shft-X ",{ || xDisp() }} }},;
                {" ~Books ",{{" Cash ~Disbursement Book ",{ || xDisp() }},;
                             {" Cash ~Revenue Book      ",{ || xDisp() }},;
                             {" ~Sales Book             ",{ || xDisp() }}}},;
                {" ~Voucher ",{{" ~Petty Cash Voucher ",{ || xDisp() }},;
                               {" ~Journal Voucher    ",{ || xDisp() }}}},;
                {" ~Report ",{{" Cash ~Disbursement Book ",{ || xDisp() }},;
                              {" Cash ~Revenue Book ",{ || xDisp() }},;
                              {" ~Sales Book ",{ || xDisp() }},;
                              {" ~Petty Cash Voucher ",{ || xDisp() }},;
                              {" ~Journal Voucher",{ || xDisp() }}}},;
                {" ~Ledger ",{{" A/R Travel (Individual) ",{ || xDisp() }},;
                              {" A/R Travel (Agency)",{ || xDisp() }},;
                              {" A/R Airlines",{ || xDisp() }},;
                              {" A/R Others",{ || xDisp() }},;
                              {" Advances for Pax ",{ || xDisp() }},;
                              {" A/P Others",{ || xDisp() }},;
                              {" Pax Refund (Individual) ",{ || xDisp() }},;
                              {" Pax Refund (Agency)",{ || xDisp() }},;
                              {" Accrued Expenses",{ || xDisp()  }}}},;
                {" ~FS ",{{" ~Assembly Sheet",{ || xDisp() }},;
                          {" ~Balance sheet",{ || xDisp() }},;
                          {" ~Income Statement",{ || xDisp() }}}},;
                {" ~Maint ",{{" ~BackUp ",{ || xDisp() }},;
                             {" ~Restore ",{ || xDisp() }}}} }

 set scor off
 setCursor(SC_NONE)
 set date format to "mm-dd-yy"
 setcancel(.f.)
 ReadInsert(.t.)
 cOriginal:=SetColor("W+/N+")
 cls
 i:=len(aIst_)
 clea type
 while i >= 1 .and. nextkey()=0
    k:=0
    while k <= i .and. nextkey()=0
     @ k,0 say aIst_[i]
     for kk:=0 to 7000
     next kk
     @k-1,0 say "°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°"
     k++
    enddo
    @ k-2,0 say aIst_[i]
    i--
 enddo
BEGIN SEQUENCE
 inkey(25)
 if EndBreak(); BREAK; endif
 setcolor(COLOR1)
 cls
 Prompt()
 if Exit ; BREAK; endif
 CLEA
 Heading("Super Travel, Inc. - Tutorial Program")
 Sti_logo()
 activatebar(1)
 if Exit ; BREAK; endif
 About(.t.)
 if Exit ; BREAK; endif
 SayMsg(BAR)
 setcolor(COLOR1)
 activateBar(2)
 if Exit ; BREAK; endif
 activateBar(3)
 if Exit ; BREAK; endif
 activeMess()
 if Exit ; BREAK; endif
 start()
 if Exit ; BREAK; endif
 files()
 if Exit ; BREAK; endif
 report()
 if Exit ; BREAK; endif
 SayMsg(" Thats all folks, press any key to exit...")
 clear type
 inkey(25)
 CLS
 ending()
 SetColor(cOriginal)
 SetCursor(SC_NORMAL)
 @ 24,0 say "  Exit From Super Travel Tutorial Program..."
 END SEQUENCE
 if Exit
   setColor(COLOR1)
   cls
   @ 0,0 say ""
 endif
return nil

static function Prompt()
local path:= curdir()
local sam:=""
 OpenW(,,{"To start a Super Travel, Inc. Program, you type",;
          "it's filename at DOS prompt.","",;
          "But for now we will just use a sample program.",;
          "Go ahead and start a Program.","",+chr(16)+;
          " Type SAMPLE and press Enter"})
 Path:="C:\"+path+if(empty(path),">","\>")
 Arrow(8,38,1,(len(path)+3))
 @ 0,0 say path
 setcursor(SC_NORMAL)
 nkey:= 0
 BEGIN SEQUENCE
 do while nkey!= K_ENTER
   nkey:=Inkey(12)
   if EndBreak(); BREAK ; endif
    do case
       case nkey == K_BS
        if col() > len(path) .and. !empty(sam)
         sam:=substr(sam,1,(len(sam)-1))
         @ row(),Col()-1 say " "
         @ row(),Col()-1 say ""
        endif
       case (nkey > 32) .and. (nkey < 256)
         sam += chr(nkey)
         @ row(),Col() say chr(nkey)
       otherwise
         if !(Upper(Sam) == "SAMPLE")
         c:=col()
         setcursor(SC_NONE)
         OpenW(18,1,{"Type SAMPLE, then press Enter. If you make",;
                     "a mistake, use the Backspace Key to erase,",;
                      "then type SAMPLE.",""})
         Inkey(5)
         if EndBreak(); BREAK ; endif
         setcursor(SC_NORMAL)
         @ 18,1 clear
         @ 0,C say ""
            nkey := 0
         endif
    endcase
 enddo
 END SEQUENCE
setcursor(SC_NONE)

function OpenW(T,L,aList_)
local cWindow,icol,len:= 0
 aeval(aList_, { |s| len := max(len(s),len )} )
 if T = nil ; T := 8 ; endif
 if L = nil ; L := (72-len)/2 ; endif
 B:= T+2+(len(alist_))
 R:= L+len+8
 cWindow:= chr(T)+chr(L)+chr(B+1)+chr(R+1)+Savescreen(T,L,B+1,R+1)
 icol := setcolor(if(iscolor(),"R/W","W+/N"))
  @ T+((B-T)/2),L+((R-L)/2) say "Û"
  tone(5015,.18)
  @ T+((B-T)/3),L+((R-L)/3),B-((B-T)/3),R-((R-L)/3) box "ÛßÛÛÛÜÛÛ "
  tone(15,.46)
  @ T+((B-T)/4),L+((R-L)/4),B-((B-T)/4),R-((R-L)/4) box "ÛßÛÛÛÜÛÛ "
  tone(3015,.78)
  @ T,L,B,R box "ÛßÛÛÛÜÛÛ "
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
    @ i,if(i>midR,StartC,EndCol) say "³"
   next
      @ MidR,min(StartC,EndCol) say repl("Ä",max(StartC,EndCol)-;
                                             (min(StartC,EndCol)))

      @ midR,StartC say if(StartC<EndCol,"Ú","¿")
      @ midR,EndCol say if(StartC<EndCol,"Ù","À")
      @ EndR,EndCol say chr(30)
else
   for i:= StartR to EndR-1
    @ i,if(i<midR,StartC,EndCol) say "³"
   next
      @ MidR,min(StartC,EndCol) say repl("Ä",(max(StartC,EndCol) -;
                                         (min(StartC,EndCol))))

      @ midR,StartC say if(StartC<EndCol,"À","Ù")
      @ midR,EndCol say if(StartC<EndCol,"¿","Ú")
      @ EndR,EndCol say chr(31)
endif

if erase != nil
inkey(erase)
EndBreak()
restscreen(min(StartR,EndR),min(StartC,EndCol),;
           max(StartR,EndR),max(StartC,EndCol),wArrow)
endif
return nil

function activatebar(mode)
local wAny2,i,Rpos:=Cpos:= 1
do case
   case mode == 1
   xcol:=setcolor(REVCOL)
   @ 1,0 clear to 1,80
   Rpos:=Cpos:=1
   for i:=1 to len(mainBar)
    Cpos:=showbar(mainbar[i,1],Rpos,Cpos,.f.)
   next
   setcolor(xcol)
  case mode == 2
  BEGIN SEQUENCE
  wAny:=OpenW(,,{"The Menu bar is the starting pad for the",;
        "user to execute an action. Here is where",;
        "all possible actions are available.",;
        "    To go to the Menu bar from the initial",;
        "window, you just press F10","","" })
   for i:=1 to len(mainbar)-1
       showbar(mainbar[i,1],Rpos,Cpos,.t.)
       arrow(8,38,Rpos+1,Cpos,0.5)
       Cpos:=showbar(mainbar[i,1],Rpos,Cpos,.f.)
         inkey(.5)
          if EndBreak(); BREAK ; endif
   next
   showbar(mainbar[i,1],Rpos,Cpos,.t.)
   arrow(8,38,Rpos+1,Cpos,1.2)
   setcolor(WG)
   @ 16,20 say PRESS
   setcolor(COLOR1)
   inkey(20)
     if EndBreak(); BREAK ; endif
   showbar(mainbar[i,1],Rpos,Cpos,.f.)
   CloseW(wAny)
  END SEQUENCE
  case mode == 3
  BEGIN SEQUENCE
  wAny:=OpenW(15,,{"The menus provide lists of commands that",;
                   "initiate some action--such as opening",;
                   "another menu or bringing up a File on",;
                   "screen.","",""})
   for i:=1 to len(mainbar)
       showbar(mainbar[i,1],Rpos,Cpos,.t.)
       maxlen:=0
       aeval(mainbar[i,2],{ |s_| maxlen:=max(maxlen,len(s_[1])) })
       wAny2:=savescreen(2,Cpos,(4+len(mainbar[i,2])),(maxlen+Cpos+2))
       shadow(2,Cpos,(3+len(mainbar[i,2])),(maxlen+Cpos+1))
       setcolor(REVCOL)
       @ 2,Cpos clear to 3+len(mainbar[i,2]),maxlen+Cpos+1
       @ 2,Cpos to 3+len(mainbar[i,2]),maxlen+Cpos+1
       setcolor(COLOR1)
       for ii:=1 to len(mainbar[i,2])
          showbar(mainbar[i,2,ii,1],2+ii,Cpos+1,if(ii=1,.t.,.f.))
       next
       arrow(15,38,(len(mainbar[i,2])+3),(Cpos+4),0.9)
       if i == len(mainbar)
         setcolor(WG)
         @ 22,20 say PRESS
         setcolor(COLOR1)
         inkey(20)
         if EndBreak(); BREAK ; endif
       endif
         restscreen(2,Cpos,(4+len(mainbar[i,2])),(maxlen+Cpos+2),wAny2)
         Cpos:=showbar(mainbar[i,1],Rpos,Cpos,.f.)
         inkey(.5)
         if EndBreak(); BREAK ; endif
   next
   CloseW(wAny)
   END SEQUENCE
endcase
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

static function About(d)
local wabout,wAny
      BEGIN SEQUENCE
     xcol:=setcolor()
     SayMsg("Press any key to continue....")
     wAbout:= OpenWindow(07,19,17,60,"About the System")
     @ 09,21 say "          Name of Program           "
     @ 10,21 say "    Specification of the Program    "
     @ 11,21 say "             (Version)              "
     @ 12,21 say "           Developed for            "
     @ 13,21 say "         Super Travel, Inc.         "
     @ 14,21 say "                By:                 "
     @ 15,21 say "        Rolando C. Ibarra Jr.       "
     @ 16,21 say "   Date the Program was completed   "
     @ 08,19 to 17,60 double
if d
     inkey((.28)+(.28))
     if EndBreak(); BREAK ; endif
     wAny:=OpenW(14,,{"You're now in the Super Travel, Inc. Menu bar System.",;
                "The Menu bar is where you choose and execute your",;
                "program options.",;
                "",;
                "Hang on for a quick look at the main component of this",;
                "sample program's Menu bar Set-Up.","",PRESS })
     Inkey(15)
     if EndBreak(); BREAK ; endif
     CloseW(wAny)
else
     Inkey(15)
     if EndBreak(); BREAK ; endif
endif
     CloseWindow(wAbout)
     setcolor(xcol)
     END SEQUENCE
return nil

function ActiveMess()
   BEGIN SEQUENCE
  wAny:= OpenW(4,,{"This is the Message Bar. This status line informs the user",;
        "of what the program is currently doing, what are the possible",;
        "actions that can be taken and available hot keys with their",;
        "summarized function.","",;
        "And it is sometimes accompanied by a warning sound to inform",;
        "that an illegal action was taken.","",""})
  arrow(16,39,23,04,1.5)
  if Exit; BREAK; endif
  arrow(16,39,23,14,1.5)
  if Exit; BREAK; endif
  arrow(16,39,23,32,1.5)
  if Exit; BREAK; endif
  arrow(16,39,23,46,1.5)
  if Exit; BREAK; endi
  setcolor(WG)
  @ 14,26 say PRESS
  setcolor(COLOR1)
  Inkey(20)
     if EndBreak(); BREAK ; endif
  CloseW(wAny)
  END SEQUENCE
return nil

function notice()
BEGIN SEQUENCE
wAny:=OpenW(,,{"This is an example of Database window. Here is",;
       "where the records and transaction of any parti-",;
       "cular are viewed, edited, deleted, added and/or",;
       "processed.",;
       "    Similar programs used by the company uses this",;
       "kind of screen display and program functions. But",;
       "some functions are slightly different on one",;
       "program to another due to implementation.","",;
       "    This Sample program does not use any database"})

aNext:={"files in any way. This is just a tool to simulate",;
        "a database functions and procedures. This does not",;
        "alter or damage any database stored in server, so",;
        "you are encouraged to experiment","",;
        "    Try to Add, Edit and Delete both Database and",;
        "Transaction page.","",""}
clea type
inkey(4.5)
if EndBreak(); BREAK ; endif
lastcol:=setcolor(WG)
for i:= 1 to 9
  scroll(9,12,19,68,1)
  @ 19,15 say aNext[i]
  Inkey(2.5)
  if EndBreak(); BREAK ; endif
next
  @ 19,15 say PRESS
setcolor(Lastcol)
inkey(20)
if EndBreak(); BREAK ; endif
CloseW(wAny)
END SEQUENCE
return nil

function feed3()
xwAny:=OPenW(6,,{"Press F10, choose Reports (press Alt+R), Press Enter and ",;
                 "choose any one from the selection (press Sft+?), then Enter.","",;
                 "    With cursors, Press Left/Right arrow keys to Move",;
                 "              the selection to 'REPORTS'.",;
                 "Press ENTER to activate SubMenu, Highlight any option from",;
                 " the selection then press Enter.",""})
inkey(20)
if EndBReak(); BREAK; endif
CloseW(xwAny)
return nil

static function ending()
msg:="Press any key to exit... "
cls
@ 0,0 say""
@ row()+1,0 say "                         ÉÍÍËÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍ»"
@ row()+1,0 say "                         ºİ                                          Şº"
@ row()+1,0 say "                         ºİ                                          Şº"
@ row()+1,0 say "                         ºİ        Super Travel, Incorporated        Şº"
@ row()+1,0 say "                         ºİ              Tutorial/Demo               Şº"
@ row()+1,0 say "                         ºİ                 Program                  Şº"
@ row()+1,0 say "                         ºİ                    by:                   Şº"
@ row()+1,0 say "                         ºİ          Rollie Castro Ibarra Jr.        Şº"
@ row()+1,0 say "                         ºİ                                          Şº"
@ row()+1,0 say " ÚÄ¿                     ºİ                     ÉÍÍÍÍÍÍÍÍÍÍÍ»        Şº"
@ row()+1,0 say " ³ ³                     ºİ                     º           º        Şº"
@ row()+1,0 say " ³ ÆÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»ÒÒÒÒÒÒÒÒÒÒÒÒÒÒÒÒÒÒÒÒÒº  The End  ºÒÒÒÒÚÄÄÄÄÄÄÄÄÄÄÄÒÄ¿"
@ row()+1,0 say " ³ ÃÄ· ÚÒ¿ÚÄÒ¿ Ú¿  ÚÄÒ¿  Ú¶ºººººººººººººººººººººº           ººººº³°°°°°°°°°°°º°³"
@ row()+1,0 say "ß³ ³ ÇÂ´ºÃ´ºÃÄ´ÃÒÂ´±ºÃÄÂ´ºßßßßßßßßßßßßßßßßßßßßßÈÍÍÍÍÍÍÍÍÍÍÍ¼ßßßß³°°°°°°°°°°°º°³"
@ row()+1,0 say " ³ ³ ºÆµºÆµ º³=³³ºÆµ±º³°Æµº                   ÕÍÍÏÍÍÍÍÍÍÑÍÍÏÍÍÍ¸ ³°°°°°°°°°°°º°³"
@ row()+1,0 say " ³ ³ º³³º³³ º³ ³³º³³±º³°³³º  ÚÂ¿        ÕÍÍÍÍ¸³ş \\\\\\\³______³ ³°°°°°°°°°°°º°³"
@ row()+1,0 say " ³ ÆÍÊÏÏÊÏÏÍÊÏÍÏÏÊÏÏÍÊÏÍÏÏ¹ ÉµÃÙ       ßßßßßÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛ³°°°°°°°°°°°º°³"
@ row()+1,0 say " ³ ÃÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂÂ¶ ºÀÙ             µ³                   ³°°°°°°°°°°°º°³"
@ row()+1,0 say " ³ ³Æµ³ÆµÆØµÆµ³³ÆµÆµÆµ³ÆµÆ¹ ÛÜÜÜÜÜÜÜÜÜÜÜÜ   Ã´                   ³°°°°°°°°°°°º°³"
@ row()+1,0 say " ³ ³³³³³³³³³³³³³³³³³³³³³³³º  ÀÁÄÄÄÒÄÄÄÁÙ    µ³                   ³°°°°°°°°°°°º°³"
@ row()+1,0 say "Ä´ ÆÏÏÏÏÏÏÏÏÏÏÏÏÏÏÏÏÏÏÏÏÏÏ¹ÄÄÄÉÍÍÍÎÍÍÍ»ÄÄÄÄÄÃ´                   ³°°°°°°°°°°°º°³"
@ row()+1,0 say " ³ ÆÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼   0   º   0     µ³                   ³°°°°°°°°°°°º°³"
@ row()+1,0 say " ÛÛÛ                              0         ÀÁÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛ"
ccol:=setcolor("W+*/N")
@ 12,51 say "The End"
setcolor(ccol)
nkey:= 0
start:=1
while nkey == 0 .and. start < 11
  nkey:=inkey(0.170)
  strMsg:=substr(msg,1,start)
  strMsg:=padl(strMsg,11)
  @ 13,49 say strMsg
  start++
enddo
start:=1
while nkey == 0
  nkey:=inkey(0.170)
  if start == (len(msg)+1); start:= 1; endif
  strMsg:=Substr(msg,start,11)
  if (len(msg)-start) < 11
  strMsg:=strMsg+substr(msg,1,10-(len(msg)-start))
  endif
  @ 13,49 say strMsg
  start++
enddo
  @ 13,49 say "           "
  @ maxrow()-1,maxcol() say ""
return nil

//eofile=>
