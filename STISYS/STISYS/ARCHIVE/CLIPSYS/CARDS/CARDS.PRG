
/* Filename Cards.prg
 * Module   For Computerized Data Retrieval System
 * Author   Rolando C. Ibarra Jr.
 * Date     July 10,1993
 */


#include "inkey.ch"
#include "SetCurs.ch"

#define DATA_PATH   "d:\pidata"
#define COLOR1 if(isColor(),"W/N,W+/B,N,N,G+/N","W/N,W+/B,N,N,W/N")
#define REVCOL if(isColor(),"N/W,W+/B,N,N,G+/N","N/W,W+/B,N,N,W/N")

#define BAR    " F10-Menu  "+chr(27)+chr(18)+chr(26)+"-Navigate  Enter"+chr(17)+;
               chr(217)+"-Select  Alt+X-Exit"

#define A_ABOUT     10
#define A_HELP      20
#define F_EXIT      30
#define F_PASS      40
#define M_BACKUP    50
#define M_RESTORE   60
#define M_REINDEX   70

static hBar,hFileMenu,hReportMenu,hMaintMenu,hAboutMenu

function main()
public Exit:= .f.
*public dStartDate, dEndDate, cCity, cUsdOp, nUsdRate
  Set(_SET_SCOREBOARD,.F.)
  Set(_SET_WRAP,.T.)
  Set(_SET_PATH,DATA_PATH)
  Set(_SET_DATEFORMAT,"mm-dd-yy")
  Set(_SET_DELETED,.T.)
  Set(_SET_EXACT,.F.)
  Set(_SET_SOFTSEEK,.T.)
  Set(_SET_CONFIRM,.T.)
  SetCursor(SC_NONE)
  cls
  ReadInsert(.T.)
  cOriginal:=SetColor()
  Heading("Super Travel, Inc. - Passenger Information System")
  SetColor(COLOR1)
  Stilogo()
   CreateBar()
   BarDisplay(hBar)
   About()
   Message(BAR)
   BarActivate(hBar,lastkey())
   nChoice:=BarMenuChoice(hBar)
   do while nChoice!=F_EXIT
      if LastKey()!=K_ESC
         do case
           case nChoice==A_ABOUT
              About()                        // About the system.
           case nChoice==A_HELP
              Help()
           case nChoice==F_PASS
              Do_Passenger()
           case nChoice==M_BACKUP
              CopyFile(1)
         case nChoice==M_RESTORE
              CopyFile(2)
         endcase
      endif
      Message(BAR)
      nChoice:=0
      BarActivate(hBar)
      nChoice:=BarMenuChoice(hBar)
   enddo
   SetColor(cOriginal)
   ending()
   ReadInsert(.F.)
   SetCursor(SC_NORMAL)
   Set(_SET_EXACT,.T.)
   Set(_SET_DELETED,.F.)
   Set(_SET_SCOREBOARD,.T.)
   ? "Exit from Passenger Information System..."
return nil

static function CreateBar()
   // Create empty bar menu
   hBar := BarNew()
   // Create empty menus
   hAboutMenu  := MenuNew(chr(240))
   hFileMenu   := MenuNew("~Files")
   hMaintMenu  := MenuNew("~Maint")
   // Add prompts
   // About Menu
   PromptAdd(hAboutMenu,A_ABOUT,"~About PIS  ")
   PromptAddLine(hAboutMenu)
   PromptAdd(hAboutMenu,A_HELP,"~Help  F1   ")
   // File Menu
   PromptAdd(hFileMenu,F_PASS,"~Passengers File  Alt-P  ")
   PromptAddLine(hFileMenu)
   PromptAdd(hFileMenu,F_EXIT,"E~xit            Alt-X  ")
   // Maint Menu
   PromptAdd(hMaintMenu,M_BACKUP, "~Backup   ")
   PromptAdd(hMaintMenu,M_RESTORE,"~Restore  ")
   // Add menus to Menubar
   MenuAdd(hBar,hAboutMenu)
   MenuAdd(hBar,hFileMenu)
   MenuAdd(hBar,hMaintMenu)
   // Add quick key or shortcuts
   PromptQuickKey(hbar,hFileMenu,F_EXIT,K_ALT_X)
   PromptQuickKey(hbar,hFileMenu,F_PASS,K_ALT_P)
   PromptQuickKey(hBar,hAboutMenu,A_HELP,K_F1)
return nil


static function About()
local wabout,wAny
      BEGIN SEQUENCE
     xcol:=setcolor()
     SayMsg("Press any key to continue....")
     wAbout:= OpenWindow(07,19,17,60,"About the System")
     @ 09,21 say "         Passengers Cards           "
     @ 10,21 say " Computerized Data Retrieval System "
     @ 11,21 say "          (Version 1.00)            "
     @ 12,21 say "           Developed for            "
     @ 13,21 say "         Super Travel, Inc.         "
     @ 14,21 say "                By:                 "
     @ 15,21 say "       Rolando C. Ibarra Jr.        "
     @ 16,21 say "        Still not Finished          "
     @ 08,19 to 17,60 double
     inkey(25)
     if EndBreak(); BREAK; endif
     CloseWindow(wAbout)
     setcolor(xcol)
     END SEQUENCE
return nil

static function ending()
msg:="Press any key to exit... "
cls
@ 0,0 say""
@ row()+1,0 say "                         ÉÍÍËÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍ»"
@ row()+1,0 say "                         ºİ                                          Şº"
@ row()+1,0 say "                         ºİ                                          Şº"
@ row()+1,0 say "                         ºİ        Super Travel, Incorporated        Şº"
@ row()+1,0 say "                         ºİ                  Cards                   Şº"
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

function DtoE( dDate )
local aMonth := {"JAN","FEB","MAR","APR","MAY","JUN",;
                 "JUL","AUG","SEP","OCT","NOV","DEC"}
   if empty(dDate)  ;  return  space(7)  ;  endif
   return  substr( dtos( dDate ),7,2 ) +;
           aMonth[ val( substr( dtos( dDate ),5,2 )) ] +;
           substr( dtos( dDate ),3,2 )

function EtoD( cDate )
local aMonth := {"JAN","FEB","MAR","APR","MAY","JUN",;
                 "JUL","AUG","SEP","OCT","NOV","DEC"}
   if aScan( aMonth,substr( upper(cDate),3,3 ) ) # 0
      return ctod( str( aScan( aMonth,substr( cDate,3,3 ) ), 2) + "/" +;
                   substr( cDate,1,2 ) + "/" +;
                   substr( cDate,6,2 )  )
   endif
   return  ctod("")

function Evalid( cDate )
   if empty(cDate)
      return .T.
   endif
   return !empty( etod( cDate ) )

function ComputeAge()
local nRec:= Recno()
 Message("Updating Passenger's Age at Rec.# ")
 (DbSetFilter({ || PASSENGR->Pass_Birth != ctod("  -  -  ") } ))
 (DbGotop())
 do while (!eof())
  @ MaxRow(), 35 say transform(Recno(),"@B 99999")
   (RecLock(0))
   PASSENGR->Pass_Age:=Age(PASSENGR->Pass_Birth)
   (DbUnLock())
  skip
 enddo
 (DbClearFilter())
 (DbGoto(nRec))
return nil


function Age(VarDate)
local SysDate:=date()
local SysYr:=year(SysDate),Yr:=year(VarDate)
local SysDys,NofDys,xAge
   xAge:=00
   SysDys:=abs(SysDate-ctod("01-01-"+str(SysYr,4)))
   NofDys:=abs((VarDate)-(ctod("01-01-"+str(Yr,4))))
   xAge:=(SysYr - Yr)
   if (SysDys < NofDys);xAge--;endif
return xAge

//eofile=>
