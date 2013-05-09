// Filename:      LOOKUP.PRG
// Module:        Array Lookup
// Author:        Arnold P. Caoile
// Date-Started:  April 14, 1992
// Updated by:    Rollie C. Ibarra Jr.
// Last-Update:   May 27, 1992/JUne 9,1993

#include "Inkey.ch"
#include "Achoice.ch"

#define ISCHAR(a)  valtype(a) == "C"
#define UP_CHAR chr(24)
#define DN_CHAR chr(25)
#define LOOKUP_BAR chr(24)+chr(25)+"-Move highlight  PgDn/PgUp-"+;
   "Next/Prev Page  "+chr(17)+chr(196)+chr(217)+"-Select  Esc-Abort"

static aScrollBar,aItems

function ChartLookUp()
local wLookUp,n
   aItems:={}
   CHART->(DbSetOrder(2))
   CHART->(DbGoTop())
   do while CHART->(!Eof())
      AAdd(aItems,CHART->ACCT_CODE+" "+CHART->ACCT_TITLE)
      CHART->(DbSkip())
   enddo
*   Message(LOOKUP_BAR)
   Tone(300,1)
   wLookUp:=OpenWindow(05,19,19,77,"Account Codes & Titles")
   aScrollBar:=ScrollBarNew(05,77,19,"N/W",1)
   ScrollBarDisplay(aScrollBar)
   ScrollBarUpdate(aScrollBar,1,Len(aItems),.T.)
   n:=AChoice(07,21,18,75,aItems,,"HandleMenu")
   CloseWindow(wLookUp)
   if LastKey()!=K_ESC
      CHART->(DbSeek(SubStr(aItems[n],8,Len(aItems[n])-8)))
      if CHART->(Found()) ; mAcctCode:=CHART->ACCT_CODE ; endif
   endif
   CHART->(DbSetOrder(1))
return nil

function AirLookUp()
local wLookUp,n
   aItems:={}
   AIRLINE->(DbSetOrder(2))
   AIRLINE->(DbGoTop())
   do while AIRLINE->(!Eof())
      AAdd(aItems,AIRLINE->AIRLINE)
      AIRLINE->(DbSkip())
   enddo
*   Message(LOOKUP_BAR)
*   wLookUp:=OpenWindow(05,20,20,60,"Airlines")
    wLookUp:=OpenWindow(05,38,20,78,"Airlines")
   aScrollBar:=ScrollBarNew(05,78/*60*/,20,"N/W",1)
   ScrollBarDisplay(aScrollBar)
   ScrollBarUpdate(aScrollBar,1,Len(aItems),.T.)
*  n:=AChoice(07,22,19,58,aItems,,"HandleMenu")
   n:=AChoice(07,40,19,76,aItems,,"HandleMenu")
   CloseWindow(wLookUp)
   if LastKey()!=K_ESC
      AIRLINE->(DbSeek(aItems[n]))
      if AIRLINE->(Found()) ; mAirCode:=AIRLINE->AIR_CODE ; endif
   endif
   AIRLINE->(DbSetOrder(1))
return nil

function AgtLookUp()
local wLookUp,n
   aItems:={}
   AGENCY->(DbGoTop())
   do while AGENCY->(!Eof())
      AAdd(aItems,AGENCY->AGENT_NAME)
      AGENCY->(DbSkip())
   enddo
*   Message(LOOKUP_BAR)
*   wLookUp:=OpenWindow(05,20,20,60,"Agencies")
   wLookUp:=Openwindow(05,38,20,78,"Agencies")
   aScrollBar:=ScrollBarNew(05,/*60*/78,20,"N/W",1)
   ScrollBarDisplay(aScrollBar)
   ScrollBarUpdate(aScrollBar,1,Len(aItems),.T.)
*   n:=AChoice(07,22,19,58,aItems,,"HandleMenu")
   n:=Achoice(07,40,19,76,aItems,,"HandleMenu")
   CloseWindow(wLookUp)
   if LastKey()!=K_ESC ;mAgent:=aItems[n]; endif
return nil

function HandleMenu(nMode,nCurElem,nRelPos)
local nRetVal,nKey,telem
static searchstr := []
   ScrollBarUpdate(aScrollBar,nCurElem,Len(aItems),.F.)
   do case
      case nMode==AC_EXCEPT            // Is key stroke used by AChoice?
         nKey:=LastKey()               // No -- get last key pressed.
         do case
            case nKey==K_ESC           // Esc key pressed?
               nRetVal:=AC_ABORT       // Yes -- abort menu selection.
            case nKey==K_ENTER         // Enter key pressed?
               nRetVal:=AC_SELECT      // Yes -- make selection.
            case IsAlpha(chr(nKey))    // letter key - search
               searchstr += chr(nkey)
               telem := ascan2(aItems,searchstr)
               nRelPos:=if(telem == 0,nCurElem,telem)
               nRetVal :=AC_GOTO
            otherwise                  // Other keys pressed.
               nRetVal:=AC_CONT        // Continue selection.
         endcase
      otherwise                        // Keystoke used by Achoice.
         nRetVal:=AC_CONT              // ....continue selection.
   endcase
return nRetVal

/* Ascan2() - Case-insensitive Ascan() */
static function AScan2(array,value)
return ascan(array, { |a| if(ISCHAR(a),;
                       upper(a) == upper(value), .F.) }, 1)
// end-of-file
