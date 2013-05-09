/* Filename Ainfo.prg
 * Module   Airline information retrieval
 * Author   Rolando C. Ibarra Jr.
 * Date     August 10,1993
 */


#define BG_ATTR  "W+/B"
#define T_ATTR   "W+/R"
#define SCR_ATTR "W+/G,N/G,,,W+/G"

#include "Inkey.ch"
#include "SetCurs.Ch"
#include "Janus.Ch"

static mName, mTelNo, mAddr1, mAddr2, mAddr3, mAddr4
//, mSeatPref, mMealReq

function main()
local wScreen, xPos, yPos
    set talk off
    set echo off
    set score off
    set delim on
    set delim to "[]"
    set path to "d:\airinfo"
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
    setpos(maxrow(),35); dispout("Search")
    setpos(maxrow(),43); dispout("      ")
    setpos(maxrow(),51); dispout("      ")
    setpos(maxrow(),59); dispout("      ")
    setpos(maxrow(),67); dispout("Print ")
    setpos(maxrow(),76); dispout("Quit ")
    setcolor("W/N")
    setpos(maxrow(), 0); dispout("F1")
    setpos(maxrow(), 8); dispout("F2")
    setpos(maxrow(),16); dispout("F3")
    setpos(maxrow(),24); dispout("F4")
    setpos(maxrow(),33); dispout("F5")
    setpos(maxrow(),43); dispout("F6")
    setpos(maxrow(),50); dispout("F7")
    setpos(maxrow(),58); dispout("F8")
    setpos(maxrow(),66); dispout("F9")
    setpos(maxrow(),74); dispout("F10")
    // Show System Name
    setcolor(T_ATTR)
    setpos( 1,24); dispout("     Super Travel, Inc.     ")
    setpos( 2,24); dispout(" Airline Information System ")
    setcolor("N/B")
    setpos( 1,52); dispout("Ü")
    setpos( 2,52); dispout("Û")
    setpos( 3,26); dispout("ßßßßßßßßßßßßßßßßßßßßßßßßßßß")
    // Show record window
    setcolor(SCR_ATTR)
    @  5, 5 clear to 16,74
    @  5, 5 to 16,74
    setcolor("N/B")
*   setpos( 5,75); dispout("Ü")
    for x:= 6 to 16
       setpos( x,75); dispout("Û")
    next
    setpos(17, 6); dispout(replicate("ß",70))
    // Show record number
    setcolor(T_ATTR)
    setpos( 4,57);  dispout("Record # 000/")

    setcolor("N/B")
    setpos( 4,73); dispout("Ü")
    setcolor("N/G")
    setpos( 5,58); dispout("ßßßßßßßßßßßßßßßß")
return nil

static function DoProcessKeys()
local nkey := 0
   SayMsg("Opening Database...")
   if netuse("Airinfo",DB_SHARED,NUM_SECONDS)
      set index to Airinfo
   endif
   SayMsg("")
   if LastRec() == 0  ;   ShowRec(APPEND_MODE)   ;  endif
   do while nKey # K_F10
      SayMsg("")
      ShowRec(VIEW_MODE)
      nKey := inkey(0)
      do case
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
         case nKey == K_F5
           SearchPax()
         case nKey == K_F9
           Print()
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
   AirInfo->(DbCloseArea())
   SayMsg("")
return nil

static function DispRecNum(nMode)
local clr
   clr := setcolor(T_ATTR)
   if nMode == APPEND_MODE
      setpos(4, 54);  dispout("< New Record > ")
   else
      setpos( 4,66);  dispout(transform(RecNo(),"999"))
      setpos( 4,70); dispout(transform(Lastrec(),"@B 999"))
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
      mName := space(50)
      mTelNo := space(50)
      mAddr1 := space(50)
      mAddr2 := space(50)
      mAddr3 := space(50)
   else
      mName  := AIRLINE
      mTelNo := PHONE
      mAddr1 := Address1
      mAddr2 := Address2
      mAddr3 := Address3
   endif
return nil

static function SaveRec(nMode)
   if nMode == APPEND_MODE
      AddRec(0)
   endif
   RecLock(0)
   replace AIRLINE    with mName
   replace PHONE      with mTelNo
   replace Address1   with mAddr1
   replace Address2   with mAddr2
   replace Address3   with mAddr3
   DbUnlock()
   DbCommit()
return nil

function print()
local nKey,isReady,aLIst_:={}
 SayMsg("Printing...")
 set(_SET_CONSOLE,.f.)
 mdate := date()
 ctime := AmPm(time())
 SayMsg("Press ENTER to print report, Esc to abort...")
 nkey:= 0
 do while (nKey!=K_ENTER) .and. (nKey!=K_ESC)
    nKey:=inkey(0)
 enddo
 if nkey==K_ENTER
    isReady:=.f.
    do while (nKey!=K_ESC) .and. (!isReady)
       isReady:=IsPrinter()
       if isReady
       SayMsg("Insert 80 column form then press ENTER to print.")
       nkey:=0
       do while nkey!=K_ENTER; nKey:=INKEY(); enddo
       SayMsg("Please wait...")
       set(_SET_PRINTER,.t.)
       ?? chr(27)+chr(120)+chr(1)
       ?? chr(27)+chr(107)+chr(0)
       ?? chr(27)+chr(77)
       ?? chr(18)
       ?? chr(27)+chr(119)+chr(1)
       ? "þAirline Information List"
       ?
       ? " As of "+CMonth(mdate)+" "+str(Day(mdate))+", "+str(Year(mdate))+;
       "  "+CDoW(mdate)+"  Time: "+ctime
       ?? chr(27)+chr(119)+chr(0)
       ?? chr(15)

     do while !Eof()
        ix:=1; aSize(aList_,0)
       do while ix <= 18  .and. !Eof()
         aAdd(aList_,recNo())
         skip ; ix++
       enddo
       i:=1
       nrec:= recno()
       do while i <= 9 .and. len(aList_) > 0
         ?
        if len(aList_) >= i
         goto aList_[i]
         ? chr(27)+chr(69)+chr(27)+chr(71)
         ?? "   "+AIRLINE
         ??chr(27)+chr(70)+chr(27)+chr(72)+space(77-len(AIRLINE))
        endif
         if len(aList_) >=i+9
          goto aLIst_[i+9]
          ?? chr(27)+chr(69)+chr(27)+chr(71)
          ?? "   "+AIRLINE
          ??chr(27)+chr(70)+chr(27)+chr(72)
         endif
        if len(aList_) >= i
         goto aLIst_[i]
          ? "   "+Address1+space(77-len(Address1))
        endif
         if len(aList_)>=i+9
          goto aList_[i+9]
          ?? "   "+Address1
         endif
        if len(aList_) >= i
         goto aList_[i]
          ? "   "+Address2+space(77-len(Address2))
        endif
         if len(aList_)>=i+9
          goto aList_[i+9]
          ?? "   "+Address2
         endif
        if len(aList_) >= i
         goto aList_[i]
          ? "   "+Address3+space(77-len(Address3))
        endif
         if len(aList_)>=i+9
          goto aList_[i+9]
           ?? "   "+Address3
         endif
        if len(aList_) >= i
         goto aList_[i]
          ? "   Tel:"+PHONE+space(73-len(PHONE))
        endif
         if len(aList_)>=i+9
          goto aList_[i+9]
           ?? "   Tel:"+PHONE
         endif
       i++
       enddo
       eject
       goto nrec
     enddo
       eject
       set(_SET_PRINTER,.f.)
       set(_SET_CONSOLE,.t.)
       SayMsg("Done...")
     else
       SayMsg("Printer not ready....")
       Tone(100,3)
       inkey(2)
       SayMsg("Press any key to retry, Esc to Abort....")
       nKey:=Inkey(0)
       SayMsg("")
     endif
    enddo
  endif
return nil

static function SearchPax()
local nRecNo,wSearch,nkey,cName:=Space(40)
  nRecNo:=RecNo()
  wSearch:= OpenWindow(08,18,12,61,"Search Mode")
  @ 10,20 say "Enter name to search"
  @ 11,20 get cName picture "@!"
  Setcursor(0)
  read
  cName:=AllTrim(cName)
  CloseWindow(wSearch)
  Setcursor(1)
  if LastKey()!=K_ESC
   Seek(cName)
   if found()
     do while (cName==substr(upper(Airline),1,len(cName))) .and. (nKey!=K_ESC)
       ShowRec(VIEW_MODE)
       SayMsg("Press Enter to continue search, ESC to abort...")
       nkey := 0
       do while (nkey!=K_ENTER) .and. (nkey!=K_ESC)
          nkey:=Inkey(0)
       enddo
       if nKey==K_ENTER ; skip; endif
     enddo
   else
   Message("Name not found...")
   Tone(150,2)
   Message("Name not found...")
   Goto(nRecNo)
   Inkey(1.5)
   endif
 endif
return nil


// end of file -->