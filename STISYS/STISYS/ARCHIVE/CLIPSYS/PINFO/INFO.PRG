#define BG_ATTR  "W+/B"
#define T_ATTR   "W+/R"
#define SCR_ATTR "W+/G,N/G,,,W+/G"

#include "Inkey.ch"
#include "SetCurs.Ch"
#include "Janus.Ch"

static mName, mTelNo, mAddr1, mAddr2, mAddr3, mAddr4, mSeatPref, mMealReq

function main()
local wScreen, xPos, yPos
    set talk off
    set echo off
    set score off
    set delim on
    set delim to "[]"
    xPos := col()
    yPos := row()
    wScreen := savescreen(00,00,24,79)
    SetUpScreen()
    DoProcessKeys()
    restscreen(00,00,24,79,wScreen)
    set color to
    setpos(ypos,xpos)
    set delim off
    set score on
    set echo on
    set talk on
return nil

static function SayMsg(msg)
local clr
    clr := setcolor(BG_ATTR)
    setpos(maxrow()-1, 0);  dispout(space(80))
    setpos(maxrow()-1, 0);  dispout(msg)
    setcolor(clr)
return nil

static function GetResp(msg)
local clr, crs, nResp := 0
    clr := setcolor(BG_ATTR)
    setpos(maxrow()-1, 0);  dispout(space(80))
    setpos(maxrow()-1, 0);  dispout(msg)
    crs := setcursor(SC_NORMAL)
    nResp := inkey(0)
    dispout(chr(nResp))
    setcolor(clr)
    setcursor(crs)
return ( upper(chr(nResp)) == 'Y')

static function SetUpScreen()
local x
    setcursor(SC_NONE)
    setcolor(BG_ATTR)
    cls
    // Show status
    setcolor("W/R")
    setpos(maxrow(), 2); dispout("Help  ")
    setpos(maxrow(),10); dispout("Add   ")
    setpos(maxrow(),18); dispout("Edit  ")
    setpos(maxrow(),26); dispout("Delete")
    setpos(maxrow(),34); dispout("      ")
    setpos(maxrow(),42); dispout("      ")
    setpos(maxrow(),50); dispout("      ")
    setpos(maxrow(),58); dispout("      ")
    setpos(maxrow(),66); dispout("      ")
    setpos(maxrow(),75); dispout("Quit ")
    setcolor("W/N")
    setpos(maxrow(), 0); dispout("F1")
    setpos(maxrow(), 8); dispout("F2")
    setpos(maxrow(),16); dispout("F3")
    setpos(maxrow(),24); dispout("F4")
    setpos(maxrow(),32); dispout("F5")
    setpos(maxrow(),40); dispout("F6")
    setpos(maxrow(),48); dispout("F7")
    setpos(maxrow(),56); dispout("F8")
    setpos(maxrow(),64); dispout("F9")
    setpos(maxrow(),72); dispout("F10")
    // Show System Name
    setcolor(T_ATTR)
    setpos( 1,24); dispout("     Super Travel, Inc.       ")
    setpos( 2,24); dispout(" Passenger Information System ")
    setcolor("N/B")
    setpos( 1,54); dispout("Ü")
    setpos( 2,54); dispout("Û")
    setpos( 3,25); dispout("ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß")
    // Show record window
    setcolor(SCR_ATTR)
    @  5, 5 clear to 20,74
    @  5, 5 to 20,74
    setcolor("N/B")
    setpos( 5,75); dispout("Ü")
    for x:= 6 to 20
       setpos( x,75); dispout("Û")
    next
    setpos(21, 6); dispout(replicate("ß",70))
    // Show record number
    setcolor(T_ATTR)
    setpos( 4,57);  dispout(" Record # 0000 ")
    setcolor("N/B")
    setpos( 4,72); dispout("Ü")
    setcolor("N/G")
    setpos( 5,58); dispout("ßßßßßßßßßßßßßßß")
return nil

static function DoProcessKeys()
local nkey := 0
   SayMsg("Opening Database...")
   if netuse("passinfo",DB_SHARED,NUM_SECONDS)
      set index to passname
   endif
   SayMsg("")
   if LastRec() == 0  ;   ShowRec(APPEND_MODE)   ;  endif
   do while nKey # K_F10
      SayMsg("")
      ShowRec(VIEW_MODE)
      nKey := inkey(0)
      do case
*         case nKey == K_F1
*           GetHelp()
         case nkey == K_F2
           if GetResp("Add New Record ? (y/n) ")
              ShowRec(APPEND_MODE)
           endif
         case nKey == K_F3
           ShowRec(EDIT_MODE)
         case nKey == K_F4
           if GetResp("Delete This Record ? (y/n) ")
              DbDelete()
              if RecNo() # LastRec()
                 DbSkip()
              else
                 DbSkip(-1)
              endif
           endif
         case nKey == K_HOME
           SayMsg("Jumping to Beginning of File...")
           DbGotop()
           Inkey(1)
         case nKey == K_END
           SayMsg("Jumping to End of File...")
           DbGoBottom()
           Inkey(1)
         case nKey == K_UP
           DbSkip(-1)
           if Bof()
              SayMsg("Beginning of File reached...")
              DbGoTop()
              inkey(1)
           endif
         case nKey == K_DOWN
           DbSkip()
           if Eof()
              SayMsg("End of File reached...")
              DbGoBottom()
              inkey(1)
           endif
         case nKey == K_PGUP
           DbSkip(-10)
           if Bof()
              SayMsg("Beginning of File reached...")
              DbGoTop()
              inkey(1)
           endif
         case nKey == K_PGDN
           DbSkip(10)
           if Eof()
              SayMsg("End of File reached...")
              DbGoBottom()
              inkey(1)
           endif
      endcase
   enddo
   SayMsg("Closing Database...")
   PassInfo->(DbCloseArea())
   SayMsg("")
return nil

static function DispRecNum(nMode)
local clr
   clr := setcolor(T_ATTR)
   if nMode == APPEND_MODE
      setpos(4, 57);  dispout("< New Record > ")
   else
      setpos(4, 57);  dispout(" Record # " + ;
             right(str(RecNo() + 10000),4) + " ")
   endif
   setcolor(clr)
return nil

static function ShowRec(nMode)
local crs
   setcolor(SCR_ATTR)
   MemRec(nMode)
   DispRecNum(nMode)
   @  7, 9 say "Name"     get mName   pict "@s56"
   @  9, 9 say "Tel Nos." get mTelNo  pict "@s52"
   @ 11, 9 say "Address"  get mAddr1  pict "@s53"
   @ 12, 9 say "       "  get mAddr2  pict "@s53"
   @ 13, 9 say "       "  get mAddr3  pict "@s53"
   @ 14, 9 say "       "  get mAddr4  pict "@s53"
   @ 16, 9 say "Seat Preference"   get mSeatPref  pict "@s45"
   @ 18, 9 say "Meal Requirements" get mMealReq   pict "@s43"
   if nMode == VIEW_MODE
       clear gets
   else
       crs := setcursor(SC_NORMAL)
       read
       setcursor(crs)
       if lastkey() # K_ESC
          SaveRec(nMode)
       endif
   endif
return nil

static function MemRec(nMode)
   if nMode == APPEND_MODE
      mName := space(70)
      mTelNo := space(70)
      mAddr1 := space(70)
      mAddr2 := space(70)
      mAddr3 := space(70)
      mAddr4 := space(70)
      mSeatPref := space(70)
      mMealReq := space(70)
   else
      mName  := Pi_Name
      mTelNo := Pi_TelNo
      mAddr1 := Pi_Addr1
      mAddr2 := Pi_Addr2
      mAddr3 := Pi_Addr3
      mAddr4 := Pi_Addr4
      mSeatPref := Pi_SeatPrf
      mMealReq  := Pi_MealReq
   endif
return nil

static function SaveRec(nMode)
   if nMode == APPEND_MODE
      AddRec(0)
   endif
   RecLock(0)
   replace Pi_Name    with mName
   replace Pi_TelNo   with mTelNo
   replace Pi_Addr1   with mAddr1
   replace Pi_Addr2   with mAddr2
   replace Pi_Addr3   with mAddr3
   replace Pi_Addr4   with mAddr4
   replace Pi_SeatPrf with mSeatPref
   replace Pi_MealReq with mMealReq
   DbUnlock()
   DbCommit()
return nil