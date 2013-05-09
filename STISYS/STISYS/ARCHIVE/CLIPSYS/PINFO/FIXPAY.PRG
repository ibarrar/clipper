
#include "Inkey.ch"
#include "SetCurs.Ch"
#include "Janus.Ch"

static mName, mSlot, mAddr, mPhone, mDept, mSSS, mTan, mIn, mOut
static mRecNo, mDate, mGross, mWtax, mSSS2, mMed, mNet
#define BG_ATTR  "W+/B"
#define T_ATTR   "W+/R"
#define SCR_ATTR "W+/G,N/G,,,W+/G"
#define  K_SPACE      32
#define  K_CTRL_ENTER 10
#define  lstr(n) ltrim(str(n))


function main()
local wScreen, xPos, yPos
    set talk off
    set echo off
    set score off
    set path to "d:\psdata\","f:\psdata\"
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
    setpos( 2,24); dispout(" PAYROLL FIX UTILITY SOFTWARE ")
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
   if netuse("history",DB_SHARED,NUM_SECONDS)
      set index to history
   endif
   if netuse("paymast",DB_SHARED,NUM_SECONDS)
      set index to paymast
   endif
   SayMsg("")
   if PAYMAST->(LastRec()) == 0  ;   ShowRec(APPEND_MODE)   ;  endif
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
              PAYMAST->(DbDelete())
              if RecNo() # LastRec()
                 PAYMAST->(DbSkip())
              else
                 PAYMAST->(DbSkip(-1))
              endif
           endif
         case nKey == K_HOME
           SayMsg("Jumping to Beginning of File...")
           PAYMAST->(DbGotop())
           Inkey(1)
         case nKey == K_END
           SayMsg("Jumping to End of File...")
           PAYMAST->(DbGoBottom())
           Inkey(1)
         case nKey == K_UP
           PAYMAST->(DbSkip(-1))
           if Bof()
              SayMsg("Beginning of File reached...")
              PAYMAST->(DbGoTop())
              inkey(1)
           endif
         case nKey == K_DOWN
           PAYMAST->(DbSkip())
           if Eof()
              SayMsg("End of File reached...")
              PAYMAST->(DbGoBottom())
              inkey(1)
           endif
         case nKey == K_PGUP
           PAYMAST->(DbSkip(-10))
           if Bof()
              SayMsg("Beginning of File reached...")
              PAYMAST->(DbGoTop())
              inkey(1)
           endif
         case nKey == K_PGDN
           HISTORY->(ShowRec2(VIEW_MODE))
      endcase
   enddo
   SayMsg("Closing Databases...")
   PayMast->(DbCloseArea())
   History->(DbCloseArea())
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
   @  7, 9 say "Name"     get mName  //pict "@s56"
   @  9, 9 say "SLOT #."  get mSlot  //pict "@s52"
   @ 11, 9 say "Address"  get mAddr  //pict "@s53"
   @ 12, 9 say "Tel.No."  get mPhone //pict "@s53"
   @ 13, 9 say "Dept   "  get mDept  //pict "@s53"
   @ 14, 9 say "SSS    "  get mSSS   //pict "@s53"
   @ 16, 9 say "TAN    "  get mTan   //pict "@s45"
   @ 18, 9 say "IN :   "  get mIn //pict "@s8"
   @ 18,50 say "Out :  "  get mOut
   if nMode == VIEW_MODE
       clear gets
   else
       crs := setcursor(SC_NORMAL)
       read
       setcursor(crs)
       if lastkey() # K_ESC
          SaveRec(nMode)
          HISTORY->(ShowRec2(nMode))
       endif
   endif
return nil

static function MemRec(nMode)
   if nMode == APPEND_MODE
      mName  := space(30)
      mSlot  := space(05)
      mAddr  := space(50)
      mPhone := space(10)
      mDept  := space(15)
      mSSS   := space(15)
      mTan   := space(15)
      mIn    := space(08)
      mOut   := space(08)
   else
      mName  := PAYMAST->EMP_NAME
      mSlot  := PAYMAST->EMP_SLOT
      mAddr  := PAYMAST->EMP_ADDR
      mPhone := PAYMAST->EMP_PHONE
      mDept  := PAYMAST->EMP_DEPT
      mSSS   := PAYMAST->EMP_SSS
      mTan   := PAYMAST->EMP_TAN
      mIn    := PAYMAST->EMP_IN
      mOut   := PAYMAST->EMP_OUT
   endif
return nil

static function SaveRec(nMode)
   if nMode == APPEND_MODE
      AddRec(0)
   endif
   RecLock(0)
   replace PAYMAST->EMP_NAME    with mName
   replace PAYMAST->EMP_SLOT    with mSlot
   replace PAYMAST->EMP_ADDR    with mAddr
   replace PAYMAST->EMP_PHONE   with mPhone
   replace PAYMAST->EMP_DEPT    with mDept
   replace PAYMAST->EMP_SSS     with mSSS
   replace PAYMAST->EMP_TAN     with mTan
   replace PAYMAST->EMP_IN      with mIn
   replace PAYMAST->EMP_OUT     with mOut
   DbUnlock()
   DbCommit()
return nil
*******************************for HISTORY*********************

static function ShowRec2(nMode)
local crs,wHol
   wHol:=OpenWindow(09,3,20,76,"WAGE HISTORY")
   setcolor(SCR_ATTR)
   MemRec2(nMode)
   DispRecNum(nMode)
   @ 10, 9 say "Rec. No. "+ str(mRecNo)  //pict
   @ 11, 9 say "DATE     "+ mDate   //pict
   @ 12, 9 say "GROSS   " get mGross  //pict
   @ 13, 9 say "WTAX    " get mWtax  //pict
   @ 14, 9 say "SSS     " get mSSS2  //pict
   @ 15, 9 say "MED     " get mMed   //pict
   @ 16, 9 say "NET     " get mNet   //pict "@s45"
   if nMode == VIEW_MODE
       clear gets
   else
       crs := setcursor(SC_NORMAL)
       read
       setcursor(crs)
       if lastkey() # K_ESC
          SaveRec2(nMode)
       endif
   endif
return nil

static function MemRec2(nMode)
   if nMode == APPEND_MODE
      mRecNo := space(04)
      mDate  := space(08)
      mGross := space(09)
      mWtax  := space(09)
      mSSS2  := space(09)
      mMed   := space(09)
      mNet   := space(09)
   else
      mRecNo := HISTORY->REC_NO
      mDate  := dtoc(HISTORY->DATE)
      mGross := HISTORY->GROSS
      mWtax  := HISTORY->WTAX
      mSSS2  := HISTORY->SSS
      mMed   := HISTORY->MED
      mNet   := HISTORY->NET
   endif
return nil

static function SaveRec2(nMode)
   if nMode == APPEND_MODE
      AddRec(0)
   endif
   RecLock(0)
   replace HISTORY->REC_NO with mRecNo
   replace HISTORY->DATE   with mDate
   replace HISTORY->GROSS  with mGross
   replace HISTORY->WTAX   with mWtax
   replace HISTORY->SSS    with mSSS2
   replace HISTORY->MED    with mMed
   replace HISTORY->NET    with mNet
   DbUnlock()
   DbCommit()
return nil

set talk on
set echo on

