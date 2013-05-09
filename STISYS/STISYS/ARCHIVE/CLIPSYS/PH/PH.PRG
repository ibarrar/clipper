/*
*          Filename :  PHAIS2.PRG
*       System Name :  Passenger History of Accounts Information System
*            Module :  Main Menu
*            Author :  Rollie Castro Ibarra Jr.
*      Date-Started :  July 8 1993
*     Date-Finished :  August 4 1993
*/

#include "Inkey.ch"
#include "SetCurs.ch"
#include "Set.ch"
#include "Janus.ch"

#define DATA_PATH   "d:\mdata"
#define A_ABOUT     026
#define A_HELP      027
#define F_EXIT      028
#define F_HIST      029
#define F_REPORT    030
#define F_SEARCH    031
#define U_UPDATE    032
#define U_CHECK     033
#define U_INCLUDE   034
#define M_BACKUP    035
#define M_RESTORE   036
#define M_REINDEX   037

#define K_SPACE     32
#define THUD       tone(480,0.25);tone(240,0.25)
static hBar,hFileMenu,hUpdateMenu,hMaintMenu,hAboutMenu


// Main program.
function Main()
local nChoice
local wOriginal,exitRequested:=.F.
public loption:=.f.,tName:=cPaxName:=space(40)
public lRef:=.t.,aChek_:={.t.,.t.,.t.,.t.,.t.,.t.,.t.,.t.,.t.}
   Set(_SET_SCOREBOARD,.F.)
   Set(_SET_WRAP,.T.)
   Set(_SET_PATH,DATA_PATH)
   Set(_SET_DATEFORMAT,"mm-dd-yy")
   Set(_SET_DELETED,.T.)
   Set(_SET_EXACT,.F.)
   Set(_SET_SOFTSEEK,.T.)
   Set(_SET_CONFIRM,.T.)
   SetCursor(SC_NONE)
   ReadInsert(.T.)
   nOx:=col(); nOy:=row()
   cOriginal:=SetColor()
   wOriginal:=BkgndScreen()
   Heading("Super Travel, Inc. - Passenger's History of Accounts System")
   SetColor(DATA_COLORS)
   Sti_Logo()
   SetCursor(SC_NONE)
   CreateBar()
   BarDisplay(hBar)
   About()
   Message("F1-Help F10-Menu  "+chr(27)+chr(18)+chr(26)+"-Navigate  Enter"+chr(17)+chr(217)+"-Select   Alt+X-Exit")
   BarActivate(hBar,lastkey())
   nChoice:=BarMenuChoice(hBar)
   do while nChoice!=F_EXIT
      if LastKey()!=K_ESC
         do case
           case nChoice==A_ABOUT
              About()                        // About the system.
           case nChoice==A_HELP
              Help(3)
           case nChoice==F_EXIT
              exit
           case nChoice==F_REPORT
              Do_Info()
           case nChoice==F_HIST
              Do_History()
           case nChoice==U_UPDATE
              Message("Opening Databases...")
              if NetUse("MASTER",DB_SHARED,NUM_SECONDS)
                 set index to BY_LNAME,BY_FNAME
              endif
              PassUpdate()
              MASTER->(DbCloseArea())
           case nChoice==U_INCLUDE
              Config(.f.)
           case nChoice==F_SEARCH
              Searchref(.f.)
           case nChoice==U_CHECK
              check()
           case nChoice==M_BACKUP
              CopyFile(1)
           case nChoice==M_RESTORE
              CopyFile(2)
           case nChoice==M_REINDEX
              Message("Press ENTER to Reindex MASTER File,  ESC to Abort...")
              inkey(0)
              if lastkey()==K_ENTER
                 fReindex()
              endif
           otherwise
              THUD
         endcase
      endif
      Message("F1-Help F10-Menu  "+chr(27)+chr(18)+chr(26)+"-Navigate  ENTER"+chr(17)+chr(217)+;
      "-Select   Alt+X-Exit")
         nChoice:=0
      BarActivate(hBar)
      nChoice:=BarMenuChoice(hBar)
   enddo
   ReadInsert(.F.)
   SetCursor(SC_NORMAL)
   SetColor(cOriginal)
   Set(_SET_EXACT,.T.)
   Set(_SET_DELETED,.F.)
   Set(_SET_SCOREBOARD,.T.)
   RestoreScreen(wOriginal)
   @ nOy, nOx say ""
   ? "Exit from Passenger's History of Accounts System..."
   ?
return nil

static function CreateBar()
   // Create empty bar menu
   hBar := BarNew()
   // Create empty menus
   hAboutMenu  := MenuNew(chr(240))
   hFileMenu   := MenuNew("~Files")
   hUpdateMenu := MenuNew("~Update")
   hMaintMenu  := MenuNew("~Maint")
   // Add prompts
   // About Menu
   PromptAdd(hAboutMenu,A_ABOUT,"~About PHAS  ")
   PromptAdd(hAboutMenu,A_HELP, "~Help    F1  ")
   // File Menu
   PromptAdd(hFileMenu,F_HIST,  "~Passengers File  Alt-P  ")
   PromptAdd(hFileMenu,F_REPORT,  "~Report Accounts Info.   ")
   PromptAdd(hFileMenu,F_SEARCH,"~Search Reference        ")
   PromptAddLine(hFileMenu)
   PromptAdd(hFileMenu,F_EXIT,  "E~xit            Alt-X  ")
   // Update Menu
   PromptAdd(hUpdateMenu,U_INCLUDE,"~Subsidiary Selection ")
   PromptAdd(hUpdateMenu,U_UPDATE, "~Update Master File   ")
   PromptAdd(hUpdateMenu,U_CHECK,  "~Check for Duplicate  ")
   // Maint Menu
   PromptAdd(hMaintMenu,M_BACKUP, "~Backup   ")
   PromptAdd(hMaintMenu,M_RESTORE,"~Restore  ")
   PromptAdd(hMaintMenu,M_REINDEX,"Reinde~x  ")
   // Add menus to Menubar
   MenuAdd(hBar,hAboutMenu)
   MenuAdd(hBar,hFileMenu)
   MenuAdd(hBAr,hUpdateMenu)
   MenuAdd(hBar,hMaintMenu)
   // Add quick key or shortcuts
   PromptQuickKey(hbar,hFileMenu,F_EXIT,K_ALT_X)
   PromptQuickKey(hbar,hFileMenu,F_HIST,K_ALT_P)
   PromptQuickKey(hbar,hAboutMenu,A_HELP,K_F1)
return nil


static function About()
local wAbout
   Message("F1-Help, any key to continue....")
   wAbout:=OpenWindow(07,19,16,61,"About PHAS")
   @ 09,21 say "  STI-Passenger's History of Accounts  "
   @ 10,21 say "         Information System.           "
   @ 11,21 say "            Developed for              "
   @ 12,21 say "          Super Travel, Inc.           "
   @ 13,21 say "                 by                    "
   @ 14,21 say "       Rollie Castro Ibarra Jr.        "
   @ 15,21 say "            July 8, 1993               "
   @ 08,19 to 16,61
   if Inkey(0)==K_F1; Help(2); endif
   CloseWindow(wAbout)
return nil

function config(x)
static wCon,cCon,rx
local cKey,list_:={"   A/R Travel (Individual)  ",;
                   "   A/R Travel (Agency)      ",;
                   "   A/R Airlines             ",;
                   "   A/R Others               ",;
                   "   Advances for Pax         ",;
                   "   A/P Others               ",;
                   "   Pax Refund (Individual)  ",;
                   "   Pax Refund (Agency)      ",;
                   "   Accrued Expenses         " }
   if x
     Message("Press Spacebar to Include/Exclude... ENTER to Update  ESC to Exit")
   else
     Message("Press Spacebar to Include/Exclude...  ESC to Exit")
   endif
   wCon:=OpenWindow(06,22,17,51,"Subsidiary Selection")
   @ 07,22 to 17,51
    for rx:= 01 to 09
    @ rx+07,23 say list_[rx]
    @ rx+07,24 say if(aChek_[rx],"û"," ")
   next
    rx:=1
    do while ckey != K_ESC .and. ckey!= K_ENTER
     cCon:=SetColor("N/B")
     @ rx+07,23 say list_[rx]
     @ rx+07,24 say if(aChek_[rx],"û"," ")
     SetColor(cCon)
     ckey:= 0
     do while cKey!=K_UP .and. cKey!=K_DOWN .and.ckey!=K_ENTER .and.;
              cKey!=K_SPACE .and. cKey!=K_ESC
      cKey:=Inkey(0)
     enddo
     if cKey!= K_ESC .and. ckey!= K_ENTER
       @ rx+07,23 say list_[rx]
       @ rx+07,24 say if(aChek_[rx],"û"," ")
     do case
        case cKey == K_UP
        if rx == 01
         rx:= 09
        else
         rx--
        endif
        case cKey == K_DOWN
        if rx == 09
         rx:= 01
        else
         rx++
        endif
        case cKey == K_SPACE
        aChek_[rx]:= !aChek_[rx]
        @ rx+07,23 say list_[rx]
        @ rx+07,24 say if(aChek_[rx],"û"," ")
        if rx == 09
         rx:= 01
        else
         rx++
        endif
     endcase
    endif
   enddo
   CloseWindow(WCon)
return lastKey()!=K_ESC


function SearchRef(lOn)
static wSea,cSea,cuSea,rx
local cKey,alist_:={"    Lastname       ",;
                    "    Firstname      " }
  Message("Choose Search Reference...   ESC- Exit")
  wSea:= OpenWindow(09,29,13,49,"Search Reference")
  cuSea:=setCursor(SC_NONE)
  @ 10,29 to 13,49
  for rx:=01 to 02
   @ rx+10,30 say alist_[rx]
   @ rx+10,32 say if(lRef,"û"," ")
  next
  ckey:= 0
   rx:= if(lRef,02,01)
   cSea:=SetColor("N/B")
   @ rx+10,30 say alist_[rx]
   if rx==02
   SetColor(cSea)
   @ 11,32 say if(lRef,"û"," ")
   cSea:=SetColor("N/B")
   else
   @ 11,32 say if(lRef,"û"," ")
   endif
   if rx==01
   SetColor(cSea)
   @ 12,32 say if(lRef," ","û")
   cSea:=SetColor("N/B")
   else
   @ 12,32 say if(lRef," ","û")
   endif
   SetColor(cSea)
     do while cKey!=K_ENTER .and. cKey!=K_ESC
      cKey:=Inkey(0)
     enddo
     if cKey!= K_ESC
     if ckey==K_ENTER
        if (lRef .and. rx==02)
          lRef:= .f.
        elseif (!lRef .and. rx==01)
          lRef:= .t.
        endif
       @ rx+10,30 say alist_[rx]
       @ 11,32 say if(lRef,"û"," ")
       @ 12,32 say if(lRef," ","û")
       inkey(.25)
     endif
    endif
   setCursor(cuSea)
   CloseWindow(wSea)
   if lOn
   @ 10,20 say "Passenger's "+if(lRef,"lastname ","firstname")
   endif
return nil

function Help(indx)
static nlen,ndeep
local nx,wHelp,aHlpLst_:={}
 do case
    case indx == 1
         aHlpLst_ :={"UP/DN ARROW - Previous/Next RECORD.   ",;
                     "PGUP/PGDN   - Previous/Next RECORD.   ",;
                     "HOME        - First RECORD on File.   ",;
                     "END         - Last RECORD on File.    ",;
                     "CTRL PGUP   - Skip Last 20 RECORDs.   ",;
                     "CTRL PGDN   - Skip Next 20 RECORDs.   ",;
                     "F1          - Help!.                  ",;
                     "F2          - Add RECORD.             ",;
                     "F3          - Edit RECORD.            ",;
                     "F4          - Delete RECORD.          ",;
                     "F5          - Search RECORD.          ",;
                     "F7          - Report History Info.    ",;
                     "F8          - Update Master file.     "}
    case indx == 2
         aHlpLst_ := {"  The Passenger's History of Account's system",;
                     "uses a  Master database file which  holds the",;
                     "compilation  of all Passenger  entries in the",;
                     "subsidiary ledger.  This Master File can only",;
                     "be used if the user is currently logged-in to",;
                     "the server via any workstation. "}
    case indx == 3
         aHlpLst_ := {" The different Menus and Sub-Menus are conrolled by",;
                     "these keys:",;
                     "     Up Arrow - This would move the high-lighted",;
                     "                bar Upwards.",;
                     "   Down Arrow - This would move the high-lighted",;
                     "                bar Downwards.",;
                     "     Home Key - This   would   move   the  high-",;
                     "                lighted bar to the Top-most menu",;
                     "                selection.",;
                     "      End Key - This   would   move   the  high-",;
                     "                lighted  bar to the  Bottom-most",;
                     "                menu selection.",;
                     "   Other Keys - Press  the  SHIFT  key plus  any",;
                     "                character   that  is   currently",;
                     "                High-lighted. This  will automa-",;
                     "                tically  execute the option.",;
                     "    ENTER Key - Accepts or execute an option.",;
                     "      ESC Key - Abort Entry.",;
                     "              *** Global Keys ***",;
                     "           F1 - Displays this Help window.,",;
                     "        Alt_P - Passengers' Master File.",;
                     "        Alt_F - Files options.",;
                     "        Alt_U - Update options.",;
                     "        Alt_M - Maint options.",;
                     "        Alt_X - Exits system; return to DOS. " }
    case indx == 4
         aHlpLst_ :={"This option is used to produce individual report of",;
                     "passenger that does not appear in  the Master File.",;
                     "Enter the  name of passenger and  this option  will",;
                     "look for entries  of that name or simillar to  that",;
                     "name in the subsidiaries and bsp unbilled files." }
    case indx == 5
         aHlpLst_ :={"Search Mode offers an efficient method of quick",;
                     "        search of passenger's  lastname, first-",;
                     "        name or both in the master file.",;
                     "             ***Control Keys***",;
                     "  F1        - Displays this Help Window.",;
                     "  F9        - Search Reference Choice Window.",;
                     "              ENTER  - Change reference.",;
                     "              ESC    - Retain reference.",;
                     "  Any Char. - Erases  old  name,  writes  the",;
                     "              character pressed.",;
                     "  ArrowKeys - Retains the old name & executes",;
                     "              the arrow action.",;
                     "  ENTER     - Accepts name and begin  search.",;
                     "  ESC       - Exits operation.",;
                     " ",;
                     " Note:always be sure that the name you  enter",;
                     "      corresponds  with  the  correct  search",;
                     "      reference." }
    case indx == 6
         aHlpLst_ :={"Error encountered....","",;
                     "Conventional Memory not enough to display",;
                     "   report. Please use Dos'Type command or",;
                     "   any  other file editor to view  report",;
                     "   file ( INFO.TXT )." }
    case indx == 7
         aHlpLst_ :={"Update Option  will  update the  Master file with",;
                     "     entries coming from the subsidiaries.",;
                     "Date Information Box requires a date to which all",;
                     "     updates are to begin. Setting  the  date  on",;
                     "     the Master File last update  will  make  the",;
                     "     update much  faster  because  it  will  only",;
                     "     consider those records from  the  subsidiary",;
                     "     that has the same or later dates." }
    case indx == 8
         aHlpLst_ :={"    Check for Duplicate  option provides a",;
                     "utility for the  Master File to  determine",;
                     "if there are existing  duplicate  records.",;
                     "If such is found, it will be automatically",;
                     "deleted to avoid confusion and maintain an",;
                     "accurate and minimal database file." }

 endcase

  nDeep:=len(aHlpLst_)
  nlen := 0
  aeval(aHlpLst_, { |s| nlen:= max(nlen,len(s)) })
  wHelp := oPenWindow(05, round(38-(nlen/2),0),;
            min((nDeep+7),21),round(41+(nlen/2),0),"Help Window")
  for nx:= 07 to min(ndeep+06,20)
   @ nx,round((80-nlen)/2,0) say aHlpLst_[nx-06]
  next
  @ 06,round(38-(nlen / 2),0) to min(nDeep+07,21),round(41+(nlen / 2),0) double
  if nDeep <= 13
  Message("Press any key to continue...")
  inkey(0)
  else
  nDeep:=1
  Message("Use Up/Dn arrow keys, Esc to continue.")
  do while lastkey() != K_ESC
    inkey(0)
   do case
      case lastkey() == K_DOWN .and. (nDeep+13)<len(aHlpLst_)
       nDeep++
       scroll(07,round(39-(nlen/2),0),20,round(40+(nlen/2),0),1)
       @ 20,round((80-nlen)/2,0) say aHlpLst_[nDeep+13]
      case lastkey() == K_UP .and. nDeep>1
       nDeep--
       scroll(07,round(39-(nlen/2),0),20,round(40+(nlen/2),0),-1)
       @ 07,round((80-nlen)/2,0) say aHlpLst_[nDeep]
   otherwise
       tone(100,0.25)
   endcase
  enddo
  endif

  closeWindow(wHelp)
return nil

static function fReindex()
local aNtx_:=directory("d:\mdata\BY_LNAME.ntx")
 Message("Reindexing....")
      use MASTER new
      if Lupdate() > aNtx_[1,3]
         index on upper(L_NAME) to d:\mdata\by_lname.ntx
      endif
      aNtx:= directory("d:\mdata\BY_FNAME.ntx")
      if Lupdate() > aNtx_[1,3]
         index on upper(F_NAME) to d:\mdata\by_fname.ntx
      endif
      close data
return nil

function Do_Info()
local wInfo,tlName,tfName:=space(40)
      tName += space(40-len(tname))
      Message("F1-Help")
      wInfo := OpenWindow(08,18,12,61,"Passengers' Accounts Information Report ")
      @ 10,20 say "Passengers Name"
      @ 11,20 get tName picture "@!" when keystroke()
      SetCursor(SC_NORMAL)
      setkey(K_F1,{|| Help(4)})
      read
      setkey(K_F1)
      SetCursor(SC_NONE)
      CloseWindow(wInfo)
      if "," $ tName
         tlName:=substr(tName,1,at(",",tName)-1)
         tfName:=rtrim(substr(tName,at(",",tName)+2))
      else
         tlName:=rtrim(tName)
         tfName:=""
      endif
      if lastkey() != K_ESC
      loption:=.t.
      PassInfo(tlName,tfName)
      endif
return nil

// end-of-file ->