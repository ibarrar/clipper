/*
      Filename: TSMS.PRG
   System-Name: Tenants Sales Monitoring for ORIENTAL SHOPPING COMPLEX
        Module: Main Menu
 Date-Startted: August 3, 1994
   Last-Update: August 3, 1994

*/

#include "inkey.ch"
#include "setcurs.ch"
#include "set.ch"
#include "memoedit.ch"
#include "janus.ch"

#undef  SERIAL
#undef  DEMO
#define FILL_CHAR chr(176)

#ifndef DEMO
 #define LOGO  "Oriental Shopping Complex - Tenants Sales Monitoring System"
 #define LOGO1 padc("*** ORIENTAL SHOPPING COMPLEX ***",40)
 #define rollie "OSC"
 #define ASC_TOTAL 9634
#else
 #define LOGO  "DEMO COPY Not For Sale !!! -Tenants Sales Monitoring System"
 #define LOGO1 "      DEMO COPY NOT FOR SALE !!!      "
 #define rollie "ssdtsc"
 #define ASC_TOTAL 8243
#endif

#define DATA_PATH ".\data\"
#define A_ABOUT     100
#define F_MASTER    101
#define F_VIEW      102
#define F_RESET     111
#define F_EXIT      103
#define C_TAG       104
#define C_MAP       105
#define E_INDI      106
#define E_CONFIG    107
#define R_PRINTER   108
#define R_SCREEN    109
#define R_DISPLAY   110

#define BAR "F10-Menu  "+chr(27)+chr(18)+chr(26)+"-Navigate  "+chr(17)+chr(217);
             +"-Select   Alt+X-Exit"

static hBar,hFileMenu,hAboutMenu,hConfigMenu,hReportMenu,hReadMenu
static hTermSub,hHourSub

function Main()
local nChoice,noy,nox,cOriginal,nReset
local wOriginal,exitRequested:=.F.
local cKey,I,cEnteredPass:="",nTotal:= 0
local verify
public DbfFile,cReport

#ifdef SERIAL
 verify := verifysrl()

 if verify == 1
   ? "Sorry must run tsms on hard disk..."
   ?
   quit
 elseif verify == 2
   ? "Unauthorized Copy..."
   ?
   quit
 elseif verify != 0
   ? " Serial Internal Error..." + str(verify)
   ?
   quit
 endif
#endif


 // Check the realibility of the EXE file.
 FOR i := 1 TO len(LOGO)
   nTotal += asc( substr( LOGO, i, 1 ) )
 NEXT i
 FOR i := 1 TO len(LOGO1)
   nTotal += asc( substr( LOGO, i, 1 ) )
 NEXT i
 FOR i := 1 TO len(rollie)
   nTotal += asc( substr( LOGO, i, 1 ) )
 NEXT i
* ? str(nTOtal)

 // Don't touch the EXE!
 IF ( nTotal != ASC_TOTAL )
  ? "Internal Error : Call for Technical Support."
  ? chr(7)+chr(7)
  RETURN nil
 ENDIF

// Check for the correct date and time settings.
 ? " Today is " + cdow(date()) + ", " + cMonth(date())+tran(day(date())," 99")+ tran(year(date()),", 9999")
 ? " The time is " + time()
 ?
 ?? " Is this correct ? (Y/N) "

 // Make sound.
 FOR i := 1 TO 5 STEP 3
   tone( int( 1110 + i ), 1 )
   tone( int( 1110 + 100), 1 )
 NEXT i



 // Get answer.
 DO WHILE !( ( cKey :=chr (inkey(0) ) ) $ "YyNn" )
 ENDDO

 ?? upper(cKey)

 IF  cKey == "N" .OR. cKey == "n"
   // Exit and remind user to set correct date and time.
   ?
   ? " Please correct system date and time."
   ?
   tone (300, 3)
   RETURN nil
 ENDIF

 // Get Password.
 ?
 ?? " Enter Password : "
 DO WHILE ( ( cKey := inkey( 0 ) ) != K_ENTER )
   cEnteredPass += chr( cKey )
 ENDDO

 // Check password.
 IF ( substr( upper( cEnteredPass ), 1, len(rollie) ) !=  upper(rollie) );
    .OR. ( len( cEnteredPass ) != len(rollie) )
  tone ( 300, 1 )
  ?
  tone ( 250, 1 )
  ? "Sorry wrong password, try again."
  tone ( 200, 2 )
  ?
  tone (150, 1)
  RETURN nil
 ENDIF

 set(_SET_SCOREBOARD,.F.)
 set(_SET_WRAP,.T.)
 set(_SET_PATH,DATA_PATH)
 set(_SET_DATEFORMAT,"mm-dd-yy")
 set(_SET_DELETED,.F.)
 set(_SET_EXACT,.F.)
 set(_SET_SOFTSEEK,.T.)
 set(_SET_CONFIRM,.T.)
 set(_SET_CANCEL,.F.)
 SETCURSOR(SC_NONE)
 readinsert(.T.)
 nox := col() ; noy := row()
 coriginal := setcolor()
 woriginal := bkgndscreen()
 heading(LOGO)
 setcolor(DATA_COLORS)
 tsms_logo()
 setcursor(SC_NONE)
 createbar()
 bardisplay(hbar)
 about()
 message(BAR)
 baractivate(hbar,lastkey())
 nchoice:=barmenuchoice(hbar)
 do while nchoice!=F_EXIT
    if lastkey()!=K_ESC
       do case
          case nchoice==A_ABOUT
              tsms_logo()
              setcolor("W/N")
              heading(LOGO)
              bardisplay(hbar)
              setcursor(SC_NONE)
              about()
          case nchoice==F_MASTER
              Master()
          case nchoice==F_RESET
              Closing()    
          case nchoice==F_VIEW
              View_Master()
          case nchoice==C_TAG
              Config(1)
          case nchoice==C_MAP
              Config(2)
          case nchoice==E_INDI
              Read(1)
          case nchoice==E_CONFIG
              Read(2)
          case nchoice==R_SCREEN
              Printing(2)
          case nchoice==R_PRINTER
              Printing(1)
          case nChoice==R_DISPLAY
              Display_()
       endcase
     endif
    message(BAR)
    nchoice:=0
    baractivate(hBar)
    nchoice:=barmenuchoice(hbar)
    if nChoice == F_EXIT
      nReset:= Alert("*** Reset Files ? ***",{" Return "," No "," Yes "})
      do case
         case nReset == 3
          Reset()
         case nReset == 2
          /* Do Nothing */
         case nReset == 1 .or. nReset == 0
          nChoice := 0
      endcase
    endif
 enddo
 readinsert(.F.)
 setcursor(SC_NORMAL)
 setcolor(coriginal)
 set(_SET_CANCEL,.T.)
 set(_SET_EXACT,.T.)
 set(_SET_DELETED,.F.)
 set(_SET_SCOREBOARD,.T.)
 restorescreen(woriginal)
 setpos(noy,nox)
 ? "Exit from T.S.M.System..."
 ?
return nil

static function CreateBar()
  // Create an empty bar menu
  hBar:=BarNew()
  // Create empty menus
  hAboutMenu :=MenuNew(chr(240))
  hFileMenu  :=MenuNew("~Files")
  hConfigMenu:=MenuNew("~Configuration")
  hReadMenu  :=MenuNew("Read ~ECR")
  hReportMenu:=MenuNew("~Reports")
  hTermSub   :=MenuNew("~Terminal Reports")
  hHourSub   :=MenuNew("~Hourly Reports")
  // Add Prompts
  // About Menu
  PromptAdd(hAboutMenu, A_ABOUT,  "~About   ")
  // Files Menu
  PromptAdd(hFileMenu,  F_MASTER, "~Master File      ")
  PromptAdd(hFileMenu,  F_RESET,  "~Closing Function ")
  PromptAdd(hFileMenu,  F_VIEW,   "~View File        ")
  PromptAddLine(hFileMenu)
  PromptAdd(hFileMenu,  F_EXIT,   "E~xit      Alt-X  ")
  // Configuration Menu
  PromptAdd(hConfigMenu,  C_TAG,  "~Tag ISC nos. in Cluster  ")
  PromptAdd(hConfigMenu,  C_MAP,  "Cluster ~Mapping          ")
  // Read ECR Menu
  PromptAdd(hReadMenu, E_INDI,    "~Individual     ")
  PromptAdd(hReadMenu, E_CONFIG,   "~Configuration  ")
  // Reports Menu
  PromptAdd(hReportMenu, R_PRINTER,"~Printed Reports  " )
  PromptAdd(hReportMenu, R_SCREEN, "~Screen Reports  " )
  PromptAddLine(hReportMenu)
  PromptAdd(hReportMenu, R_DISPLAY,"~View Output File  ")
  MenuAdd(hBar,hAboutMenu)
  MenuAdd(hBar,hFileMenu)
  MenuAdd(hBar,hConfigMenu)
  MenuAdd(hBar,hReadMenu)
  MenuAdd(hBar,hReportMenu)
  // Add quick key short cuts
  PromptQuickKey(hBar,hFileMenu,F_EXIT,K_ALT_X)
return nil

static function About()
local wAbout
  Message("Press any key to continue....")
  wAbout:=OpenWindow(07,19,16,60,"About the system")
  @ 09,21 say      "   Tenant's Sales Monitoring System   "
  @ row()+1,21 say "              Version 2               "
  @ row()+1,21 say "            Developed for             "
  @ row()+1,21 say LOGO1
  @ row()+1,21 say "                 by                   "
  @ row()+1,21 say "  Technosoft Philippines Corporation  "
  @ row()+1,21 say "         September 20, 1994           "
  @ 08,19 to 16,60 double
  Inkey(0)
  CloseWindow(wAbout)
return nil

static function tsms_logo()
@ 1,0, maxrow()-1, maxcol() BOX repl(FILL_CHAR,9) COLOR "W/G+"
return nil

static function star_trek()
 tone(261,7);tone(349,3);tone(493,20);tone(440,4);tone(392,3)
 tone(349,3);tone(329,2);tone(311,29)
return nil

static function popeye()
 tone(294,1);tone(274,1);tone(294,1);tone(0,1)
 tone(150,1);tone(0,1);tone(220,1);tone(193,1);tone(187,1)
 tone(220,1);tone(294,1);tone(0,1);tone(294,1)
return nil

static function die()
 tone(150,2);tone(150,2);tone(150,1);tone(150,2);tone(180,2)
 tone(168,1);tone(168,2);tone(150,1);tone(150,2);tone(143,1)
 tone(150,2)
return nil

static function et()
 tone(330,5);tone(367,5);tone(294,5);tone(150,5);tone(220,5)
return nil















