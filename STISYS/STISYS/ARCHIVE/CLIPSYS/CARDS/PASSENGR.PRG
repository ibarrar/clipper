/*
       Filename:  Passengr.Prg
         Author:  Rollie C. Ibarra Jr.
   Date-Started:  Oct. 26, 1993
    Last-Update:  Nov. 3, 1993
*/
#include "Inkey.ch"
#include "Setcurs.ch"
#include "Achoice.ch"
#include "Janus.Ch"
#include "Epson.Ch"

#define STATUS_BAR  ;
"F2-Add F3-Edit F4-Delete F5-Search F6-Age F7-Print Label F8-BDay List ESC-Abort"
#define K_SPACE    32
static mAge, mBirth, mTel, mCtzhp, mAddr1, mAddr2
static mAddr3, mSeat, mMeal, mName, lRef, fullName

function Do_Passenger()
local wPass, nKey
   if NetUse("PASSENGR",DB_SHARED,NUM_SECONDS)
      set index to P_LNAME,P_FNAME,P_BIRTH
   endif
   if NetUse("CARDS",DB_SHARED,NUM_SECONDS)
      set index to CARDS
   endif
   aPicture:=Array(18,2)
   aPicture[1,1]:="CARDS->LINK"
   aPicture[1,2]:="@!"
   aPicture[2,1]:="CARDS->FLIGHT"
   aPicture[2,2]:="@!"+Repl("X",6)
   aPicture[3,1]:="CARDS->CLASS"
   aPicture[3,2]:="@!"+Repl("X",1)
   aPicture[4,1]:="CARDS->DATE"
   aPicture[4,2]:="@!"+Repl("X",7)
   aPicture[5,1]:="CARDS->FROM"
   aPicture[5,2]:="@!"+Repl("X",3)
   aPicture[6,1]:="CARDS->TO"
   aPicture[6,2]:="@!"+Repl("X",3)
   aPicture[7,1]:="CARDS->ETD"
   aPicture[7,2]:="@!"+Repl("X",4)
   aPicture[8,1]:="CARDS->ETA"
   aPicture[8,2]:="@!"+Repl("X",4)
   aPicture[9,1]:="CARDS->DATE_RSVD"
   aPicture[9,2]:="@!"+Repl("X",7)
   aPicture[10,1]:="CARDS->STAT1"
   aPicture[10,2]:="@!"+Repl("X",2)
   aPicture[11,1]:="CARDS->RQ_TO1"
   aPicture[11,2]:="@!"+Repl("X",4)
   aPicture[12,1]:="CARDS->PNR_TL"
   aPicture[12,2]:="@!"+Repl("X",9)
   aPicture[13,1]:="CARDS->HOTEL"
   aPicture[13,2]:="@!"+Repl("X",15)
   aPicture[14,1]:="CARDS->ACCT_TYPE"
   aPicture[14,2]:="@!"+Repl("X",4)
   aPicture[15,1]:="CARDS->RATE"
   aPicture[15,2]:="@!"+Repl("X",4)
   aPicture[16,1]:="CARDS->STAT2"
   aPicture[16,2]:="@!"+Repl("X",2)
   aPicture[17,1]:="CARDS->RQ_TO2"
   aPicture[17,2]:="@!"+Repl("X",4)

   wPass := OpenWindow(03,10,16,69,"Passenger File")
   if PASSENGR->(RecCount())==0 ; PassForm(APPEND_MODE) ; endif
   if LastKey()!=K_ESC
      do while (nKey!=K_ESC)
         Message(STATUS_BAR)
         PassForm(VIEW_MODE)
         nKey:=Inkey(0)
         do case
            case nKey==K_DOWN
                 PASSENGR->(DbSkip())
                 if PASSENGR->(Eof())
                    PASSENGR->(DbGoBottom())
                    Tone(1523.30,1.28)
                    Message("End of file reached....")
                    Inkey(1)
                 endif
            case nKey==K_UP
                 PASSENGR->(DbSkip(-1))
                 if PASSENGR->(Bof())
                    PASSENGR->(DbGoTop())
                    Tone(1523.30,1.28)
                    Message("Beginning of file reached....")
                    Inkey(1)
                 endif
            case nKey==K_CTRL_PGDN
                 PASSENGR->(DbSkip(NUM_TO_SKIP))
                 if PASSENGR->(Eof())
                    PASSENGR->(DbGoBottom())
                    Tone(1523.30,1.28)
                    Message("End of file reached....")
                    Inkey(1)
                 endif
            case nKey==K_CTRL_PGUP
                 PASSENGR->(DbSkip(-NUM_TO_SKIP))
                 if PASSENGR->(Bof())
                    PASSENGR->(DbGoTop())
                    Tone(1523.30,1.28)
                    Message("Beginning of file reached....")
                    Inkey(1)
                 endif
            case nkey==K_PGDN
                 CARDS->(CARDS(PASSENGR->LINK,VIEW_MODE,aPicture))
            case nKey==K_END
                 PASSENGR->(DbGoBottom())
                 Message("Moving to end of file....")
                 Inkey(1)
            case nKey==K_HOME
                 PASSENGR->(DbGoTop())
                 Message("Moving to beginning of file....")
                 Inkey(1)
            case nKey==K_F2
                 Message("Press ENTER to add new record.")
                 if inkey(0)==K_ENTER
                    PassForm(APPEND_MODE)
                 endif
            case nKey==K_F3
                 PassForm(EDIT_MODE)
            case nKey==K_F4
                 Message("Press ENTER to delete record, ESC to abort.")
                 if InKey(0)==K_ENTER
                    Message("Deleting current record....")
                    PASSENGR->(FilLock(0))
                    PASSENGR->(DbDelete())
                    PASSENGR->(DbUnLock())
                 endif
            case nKey==K_F5
                 PASSENGR->(PassSearch())
            case nkey==K_F6
                 PASSENGR->(ComputeAge())
            case nKey==K_F7
                 PASSENGR->(PassLabel())
            case nKey==K_F8
                 PASSENGR->(BDayList())
            case nKey==K_ESC
                 if alert(" Exit Passenger's File ? ",{" Yes "," No "}) == 2
                    nkey:=0
                 endif
         endcase
      enddo
   endif
   Message("Closing Databases....")
   PASSENGR->(DbCloseArea())
   CloseWindow(wPass)
return nil

function getfull()
local full := ''
 full:= alltrim(PASSENGR->Pass_LName)
 full+= if(!empty(PASSENGR->Pass_FName),", "+alltrim(PASSENGR->Pass_FName),"")
return  (full + space(40-len(full)))

static function PassForm(nMode)
local n
   Tone(523.30,1.28)
   PassInit(nMode)
   Message(STATUS_BAR)
   cColor:=SetColor("N/BG")
   if PASSENGR->(Deleted()) ; @ 03,35 say "<deleted>"
   else ; @ 03,35 say "         " ; endif
    if nMode==APPEND_MODE
       @ 03, 53 say "         < New >"
    else
       @ 03, 53 say "                "
       @ 03, 53 say "Rec #"+transform(PASSENGR->(RecNo()),"99999")+;
                        "/"+transform(PASSENGR->(LastRec()),"@B 99999")
    endif
   SetColor(cColor)
   @ 05,      12   say "        Name"  get mName  picture "@!"
   @ row()+1, 12   say "    Birthday"  get mBirth valid evalid(mBirth) picture "@!"
   @ row(),col()+10 say "Age"          get mAge when putage() picture "99"
   @ row()+1, 12   say " Citizenship"  get mCtzhp picture "@!"
   @ row()+1, 12   say "Contact Nos."  get mTel   picture "@!"
   @ row()+2, 12   say "     Address"  get mAddr1
   @ row()+1, 12   say "            "  get mAddr2
   @ row()+1, 12   say "            "  get mAddr3
   @ row()+2, 12   say "        Seat"  get mSeat
   @ row()+1, 12   say "        Meal"  get mMeal
   if (nMode==APPEND_MODE) .or. (nMode==EDIT_MODE)
      SetCursor(SC_NORMAL)
      read
      if LastKey()!=K_ESC
         PassSave(nMode)
      endif
      CARDS->(CARDS(PASSENGR->LINK,nMode,aPicture))
      SetCursor(SC_NONE)
   else
      clear gets
   endif
return nil

static function PassInit(nMode)
   if nMode==APPEND_MODE
      mName  := space(40)
      mAge   := 0
      mBirth := space(7)
      mTel   := space(40)
      mCtzhp := space(15)
      mAddr1 := space(40)
      mAddr2 := space(40)
      mAddr3 := space(40)
      mSeat  := space(40)
      mMeal  := space(40)
   else
      mName  := getfull()
      mAge   := PASSENGR->Pass_Age
      mBirth := dtoe(PASSENGR->Pass_Birth)
      mTel   := PASSENGR->Pass_Tel
      mCtzhp := PASSENGR->Pass_Ctzhp
      mAddr1 := PASSENGR->Pass_Addr1
      mAddr2 := PASSENGR->Pass_Addr2
      mAddr3 := PASSENGR->Pass_Addr3
      mSeat  := PASSENGR->Pass_Seat
      mMeal  := PASSENGR->Pass_Meal
   endif
return nil

static function PassSave(nMode)
local sysdate:=date(),lrec:=LastRec()
   Message("Saving entries...")
   if nMode==APPEND_MODE
      PASSENGR->(DbAppend())
   endif
   PASSENGR->(RecLock(0))
   PASSENGR->Pass_LName := if("," $ mName,substr(mName,1,at(",",mName)-1),mName)
   PASSENGR->Pass_FName := if("," $ mName,substr(mName,at(",", mName) +2),"")
   PASSENGR->Pass_Age   := mAge
   PASSENGR->Pass_Birth := etod(mBirth)
   PASSENGR->Pass_Tel   := mTel
   PASSENGR->Pass_Ctzhp := mCtzhp
   PASSENGR->Pass_Addr1 := mAddr1
   PASSENGR->Pass_Addr2 := mAddr2
   PASSENGR->Pass_Addr3 := mAddr3
   PASSENGR->Pass_Seat  := mSeat
   PASSENGR->Pass_Meal  := mMeal
   if nMode==APPEND_MODE .and. empty(PASSENGR->(Link))
   PASSENGR->Link := val(substr(str(year(sysdate)),4)+substr(str(lrec),8))
   endif
   PASSENGR->(DbUnlock())
return nil

static function PassSearch()
static cPaxName
local cfN,clN,nRec
local wSearch, nKey
   nRecNo:=RecNo()
   if empty(lRef) ; lRef := .t. ; endif
   if empty(cpaxName) ; cPaxName:= "" ; endif
   cPaxName+=space(40-len(cPaxName))
   wSearch:=OpenWindow(08,18,12,61,"Search Mode           F9-Search Reference")
   @ 10,20 say "Passenger's "+if(lRef,"lastname","firstname")
   @ 11,20 get cPaxName picture "@!" when keystroke()
   SetCursor(SC_NORMAL)
   setkey(K_F9,{||SearchRef(.t.)})
   setkey(K_F1,{||Help(5)})
   read
   setkey(K_F1)
   setkey(K_F9)
   CloseWindow(wSearch)
   SetCursor(SC_NONE)
   lFound:=.f.
   if LastKey() # K_ESC
   Message("Searching....")
       if "," $ cPaxName     // if both fname lname
           clN:= alltrim(substr(cPaxName, 1, at(",", cPaxName) -1 ))
           cfN:= alltrim(substr(cPaxName, at(",", cPaxName) +2 ))
           PASSENGR->(DbSeek(clN))
        if PASSENGR->(found())
          nRec:=RecNo()
          do while clN $ PASSENGR->Pass_LNAME .and. !(cfn $ PASSENGR->Pass_FNAME) .and. !EOF()
             PASSENGR->(DbSkip())
          enddo
          if !(cfN $ PASSENGR->pass_FNAME)
             PASSENGR->(DbGoTo(nRec))
             do while clN $ PASSENGR->Pass_LNAME .and. nKey!=K_ESC
                PassForm(VIEW_MODE)
                Message("Firstname not found., Press ENTER to continue, ESC to stop...")
                nKey := 0
                do while nKey # K_ENTER .and. nKey # K_ESC
                   nkey := inkey(0)
                enddo
                lFound:= .t.
                if nKey == K_ESC; exit ;  endif
                Message("Searching...")
               PASSENGR->(DbSkip())
            enddo
          else
             lFound:=.t.
          endif      //not found by skip
        endif        //not found by seek
     elseif lRef   // if lname only
         cPaxName :=  alltrim(cPaxName)
         PASSENGR->(DbSeek(cPaxName))
           if PASSENGR->(found())
              do while cPaxName $ PASSENGR->Pass_LNAME .and. nKey != K_ESC
                   PassForm(VIEW_MODE)
                   Message("Press ENTER to continue, ESC to stop...")
                   nKey := 0
                   do while nKey # K_ENTER .and. nKey # K_ESC
                      nkey := inkey(0)
                   enddo
                  lFound:= .t.
                  if nKey == K_ESC; exit ;  endif
                  Message("Searching...")
                 PASSENGR->(DbSkip())
              enddo
           endif
     else
        cPaxName := alltrim(cPaxName)
        PASSENGR->(DbSetOrder(2))
        PASSENGR->(DbSeek(cPaxName))
        if PASSENGR->(found())
           do while cPaxName $ PASSENGR->Pass_FNAME .and. nKey != K_ESC
               PassForm(VIEW_MODE)
               Message("Press ENTER to continue, ESC to stop...")
               nKey := 0
               do while nKey # K_ENTER .and. nKey # K_ESC
                 nkey := inkey(0)
               enddo
               lFound:= .t.
               if nKey == K_ESC; exit ;  endif
               Message("Searching...")
             PASSENGR->(DbSkip())
           enddo
        endif
      PASSENGR->(DbsetOrder(1))
     endif
       if  !lFound
         Message("End of File reached...")
         Tone(1523.30,3.28)
         Inkey(1)
         PASSENGR->(DbGoto(nRecNo))
       endif
   endif
return nil

function keystroke()
 @ row(),col()-40 say ""
 do while inkey(0)==K_F9
   Searchref(.t.);@11,20 say ""
 enddo
 if (lastkey() > K_SPACE) .and. (lastkey() <256)
    keyboard(chr(K_CTRL_Y)+chr(lastkey()))
 else
    keyboard(chr(lastkey()))
 endif
return .t.


function SearchRef(lOn)
local wSea,cSea,cuSea,rx
local ckey:=0,alist_:={"    Lastname       ",;
                       "    Firstname      " }
  Message("Choose Search Reference... ESC- Exit")
  wSea:= OpenWindow(09,29,13,49,"Search Reference")
  cuSea:=setCursor(SC_NONE)
  @ 10,29 to 13,49
  @ 11,30 say alist_[1]
  @ 12,30 say alist_[2]
  rx:= if(lRef,02,01)
  cSea:=SetColor("N/B")
  @ rx+10,30 say alist_[rx]
  if lRef
  SetColor(cSea)
  @ 11,32 say if(lRef,"û"," ")
  cSea:=Setcolor("N/B")
  else
  @ 11,32 say if(lREf,"û"," ")
  endif
  if !lRef
  Setcolor(cSea)
  @ 12,32 say if(lref," ","û")
  cSea:=SetColor("N/B")
  else
  @ 12,32 say if(lRef," ","û")
  endif
  SetColor(cSea)
    do while ckey!=K_ENTER .and. ckey!=K_ESC
     ckey:=Inkey(0)
    enddo
    if ckey!= K_ESC
    if ckey==K_ENTER
       if (lRef .and. rx==02)
          lREf:= .f.
       elseif (!lRef .and. rx==01)
          lRef:= .t.
       endif
      @ rx+10,30 say alist_[rx]
      @ 11,32 say if(lRef,"û"," ")
      @ 12,32 say if(lRef," ","û")
      inkey(.25)
     endif
    endif
   setcursor(cuSea)
   CloseWindow(wSea)
   if lOn
   @ 10,20 say "Passenger's "+if(lRef,"lastname ","firstname")
   endif
 return nil

static function PassLabel()
   if lastKey() # K_ESC
      if PrintReady()
          Message("Printing label, please wait...")
         set console off
         set printer on
         ?? _PRN_RESET
               ??? "To:", _PRN_EMPHON + getfull() + _PRN_EMPHOFF
               ??? "   ", Pass_Addr1
               ??? "   ", Pass_Addr2
               ??? "   ", Pass_Addr3
               ???
               ???
               ???
         set printer off
         set console on
         Tone(1523.30,1.28)
         inkey(2)
      endif
   endif
 return nil

static function BDayList()
local wList, cMonth := "  ", nRecNo := PASSENGR->(RecNo())
   wList := OpenWindow(08,18,11,61,"Birthday List")
   Message("Enter month desired, or leave it blank for current month...")
   @ 10,25 say "For what month (MM)" get cMonth pict "99"
   SetCursor(SC_NORMAL)
   read
   CloseWindow(wList)
   SetCursor(SC_NONE)
   if LastKey() # K_ESC
      Message("Printing birthday list...")
      if empty(cMonth)
         cMonth := substr(dtoc(date()),1,2)+"00"
      endif
      set console off
      set printer on
      ?? _PRN_RESET
      ?? _PRN_HDBLE
      ?? "Passengers' Birthday List"
      ?
      ? "For the Month of :", cMonth(ctod(cMonth+"/01/00"))
      ?
      ?? _PRN_HNORM
      ? "Day             Passenger's Name           "
      ?? "         Mailing Address              "
      PASSENGR->(DbSetOrder(3))
      PASSENGR->(DbGotop())
      PASSENGR->(DbSeek((cMonth + "00")))
      do while PASSENGR->(!Eof()) .and. cMonth == substr(dtoc(PASSENGR->Pass_Birth),1,2)
            ? substr(dtoc(PASSENGR->Pass_Birth),4,2) + "  "
           ?? getfull()
           ?? chr(15)
           ?? ' ',alltrim(PASSENGR->Pass_Addr1)
           ?? ' ',alltrim(PASSENGR->Pass_Addr2)
           if len(alltrim(PASSENGR->Pass_Addr1)) + len(alltrim(PASSENGR->Pass_Addr2)) +;
              len(alltrim(PASSENGR->Pass_Addr3)) > 90
              ? space(75) + alltrim(PASSENGR->Pass_Addr3)
           else
              ?? ' ',alltrim(PASSENGR->Pass_Addr3)
           endif
           ?? chr(18)
         PASSENGR->(DbSkip())
      enddo
      ?
      ? "*** End of Report ***"
      ? _PRN_FFEED
      set printer off
      set console on
      PASSENGR->(DbSetOrder(1))
      PASSENGR->(DbGoto(nRecNo))
   endif
return nil


static function helpme()
local w_help
    w_help := openwindow(03,20,22,60,"Help Window")
    @ 05,     22 say "ARROW UP/DN - Previous/Next PASSENGR."
    @ row()+1,22 say "PGUP/PGDN   - Previous/Next PASSENGR."
    @ row()+1,22 say "HOME        - First PASSENGR on File."
    @ row()+1,22 say "END         - Last PASSENGR on File."
    @ row()+1,22 say "CTRL PGUP   - Skip Last 20 PASSENGRs."
    @ row()+1,22 say "CTRL PGDN   - Skip Next 20 PASSENGRs."
    @ row()+1,22 say "F1          - Help!."
    @ row()+1,22 say "F2          - Add PASSENGR."
    @ row()+1,22 say "F3          - Edit PASSENGR."
    @ row()+1,22 say "F4          - Delete PASSENGR."
    @ row()+1,22 say "F5          - Search PASSENGR."
    @ row()+1,22 say "F6          - Cancel PASSENGR."
    @ row()+1,22 say "F7          - Print PASSENGR."
    @ row()+1,22 say "F8          - PASSENGR Checklist."
    @ row()+1,22 say "ALT+A       - Agency Lookup."
    @ row()+1,22 say "ALT+H       - Hotel Lookup."
    @ row()+1,22 say "ESC         - Exit Tour PASSENGR."
    message("Press any key...")
    inkey(0)
    closewindow(w_help)
return nil

static function PrintReady()
   if isprinter()
      return .t.
   else
      Message("Waiting for printer to come on-line, press ESC to cancel...")
      while inkey() # K_ESC .and. !isprinter()  ;  end
      if isprinter()
         return .t.
      else
         Message("Printing cancelled by user...")
         Tone(1523.30,1.28)
         inkey(2)
      endif
   endif
   return .f.

function putAge()
if etod(mBirth) != ctod("  -  -  ")
 mAge:=Age(etod(mBirth))
endif
return .t.

// end-of-file