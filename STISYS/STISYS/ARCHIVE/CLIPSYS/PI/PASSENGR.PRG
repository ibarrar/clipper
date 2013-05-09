/*
       Filename:  Passengr.Prg
         Author:  Rollie  C. Ibarra Jr.
    Date-Started:  March 25, 1993
    Last-Update:  march 25, 1993
*/
#include "Inkey.ch"
#include "Setcurs.ch"
#include "Achoice.ch"
#include "Janus.Ch"
#include "Epson.Ch"

#define STATUS_BAR  ;
"F1-Help  F2-Add  F3-Edit  F5-Search  F7-Print Label  F8-BDay List  ESC-Abort"

static _Name, _Age, _Birth, _Tel, _Ctzhp, _AddrCoy, _AddrRmBldg
static _AddrNoSt, _AddrDist, _AddCtyCtry, _Seat, _Meal

function Do_Passenger()
local wPass, nKey
   if NetUse("PASSENGR",DB_SHARED,NUM_SECONDS)
      set index to PASSENGR,PASSB
   endif
   wPass := OpenWindow(03,06,20,73,"Passenger File")
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
                    Tone(100,3)
                    Message("End of file reached....")
                    Inkey(1)
                 endif
            case nKey==K_UP
                 PASSENGR->(DbSkip(-1))
                 if PASSENGR->(Bof())
                    PASSENGR->(DbGoTop())
                    Tone(100,3)
                    Message("Beginning of file reached....")
                    Inkey(1)
                 endif
            case nKey==K_CTRL_PGDN
                 PASSENGR->(DbSkip(NUM_TO_SKIP))
                 if PASSENGR->(Eof())
                    PASSENGR->(DbGoBottom())
                    Tone(100,3)
                    Message("End of file reached....")
                    Inkey(1)
                 endif
            case nKey==K_CTRL_PGUP
                 PASSENGR->(DbSkip(-NUM_TO_SKIP))
                 if PASSENGR->(Bof())
                    PASSENGR->(DbGoTop())
                    Tone(100,3)
                    Message("Beginning of file reached....")
                    Inkey(1)
                 endif
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
                    PASSENGR->(DbDelete())
                 endif
            case nKey==K_F5
                 PASSENGR->(PassSearch())
            case nKey==K_F7
                 PASSENGR->(PassLabel())
            case nKey==K_F8
                 PASSENGR->(BDayList())
         endcase
      enddo
   endif
   Message("Closing Databases....")
   PASSENGR->(DbCloseArea())
   CloseWindow(wPass)
return nil

static function PassForm(nMode)
local n
   Tone(300,1)
   PassInit(nMode)
   Message(STATUS_BAR)
   cColor:=SetColor("N/BG")
   if PASSENGR->(Deleted()) ; @ 03,35 say "<deleted>"
   else ; @ 03,35 say "         " ; endif
    if nMode==APPEND_MODE
       @ 03, 62 say "< New >"
    else
       @ 03, 62 say "       "
       @ 03, 62 say "Rec #"+transform(PASSENGR->(RecNo()),"9999")
    endif
   SetColor(cColor)
   @ 05,      13 say "    Name"    get _Name
   @ row()+2, 13 say "BirthDay"    get _Birth valid evalid(_Birth)
   @ row(),   32 say "Citizenship" get _Ctzhp
   @ row()+2, 13 say "Tel Nos."    get _Tel
   @ row()+2, 11 say "  Company "  get _AddrCoy
   @ row()+1, 11 say "  Rm/Bldg."  get _AddrRmBldg
   @ row()+1, 11 say "  No.& St." get _AddrNoSt
   @ row()+1, 11 say "  District"  get _AddrDist
   @ row()+1, 11 say "City/Ctry."  get _AddCtyCtry
   @ row()+2, 11 say "      Seat"    get _Seat
   @ row()+2, 11 say "      Meal"    get _Meal
   if (nMode==APPEND_MODE) .or. (nMode==EDIT_MODE)
      SetCursor(SC_NORMAL)
      read
      if LastKey()!=K_ESC
         PassSave(nMode)
      endif
      SetCursor(SC_NONE)
   else
      clear gets
   endif
return nil

static function PassInit(nMode)
   if nMode==APPEND_MODE
      _Name       := space(40)
      _Age        := 0
      _Birth      := space(7)
      _Tel        := space(40)
      _Ctzhp      := space(15)
      _AddrCoy    := space(40)
      _AddrRmBldg := space(40)
      _AddrNoSt    := space(40)
      _AddrDist   := space(40)
      _AddCtyCtry:= space(40)
      _Seat  := space(40)
      _Meal  := space(40)
   else
      _Name  := PASSENGR->Pass_Name
      _Age   := PASSENGR->Pass_Age
      _Birth := dtoe(PASSENGR->Pass_Birth)
      _Tel   := PASSENGR->Pass_Tel
      _Ctzhp := PASSENGR->Pass_Ctzhp
      _AddrCoy    := PASSENGR->ADDRCOY
      _AddrRmBldg := PASSENGR->ADDRRMBLDG
      _AddrNoSt    := PASSENGR->ADDRNOST
      _AddrDist   := PASSENGR->ADDRDIST
      _AddCtyCtry:= PASSENGR->ADDCTYCTRY
      _Seat  := PASSENGR->Pass_Seat
      _Meal  := PASSENGR->Pass_Meal
   endif
return nil

static function PassSave(nMode)
   Message("Saving entries...")
   if nMode==APPEND_MODE
      PASSENGR->(DbAppend())
   endif
   PASSENGR->(RecLock(0))
   PASSENGR->Pass_Name  := _Name
   PASSENGR->Pass_Age   := _Age
   PASSENGR->Pass_Birth := etod(_Birth)
   PASSENGR->Pass_Tel   := _Tel
   PASSENGR->Pass_Ctzhp := _Ctzhp
   PASSENGR->ADDRCOY    := _AddrCoy
   PASSENGR->ADDRRMBLDG := _AddrRmBldg
   PASSENGR->ADDRNOST   := _AddrNOSt
   PASSENGR->ADDRDIST   := _AddrDist
   PASSENGR->ADDCTYCTRY := _AddCtyCtry
   PASSENGR->Pass_Seat  := _Seat
   PASSENGR->Pass_Meal  := _Meal
   PASSENGR->(DbUnlock())
return nil

static function PassSearch()
local wSearch, nKey, cPaxName := space(40)
   nRecNo:=RecNo()
   wSearch:=OpenWindow(08,18,12,61,"Search Mode")
   @ 10,20 say "Passenger's Name"
   @ 11,20 get cPaxName picture "@!"
   SetCursor(SC_NORMAL)
   read
   CloseWindow(wSearch)
   SetCursor(SC_NONE)
   lFound:=.F.
   if LastKey() # K_ESC
      cPaxName := alltrim(cPaxName)
      PASSENGR->(DbGotop())
      do while PASSENGR->(!Eof())
         if cPaxName $ upper(PASSENGR->PASS_NAME)
            PassForm(VIEW_MODE)
            Message("Press ENTER to continue, ESC to stop...")
            nKey := 0
            do while nKey # K_ENTER .and. nKey # K_ESC
               nkey := inkey(0)
            enddo
            if nKey == K_ESC  ;  exit  ;  endif
         endif
         PASSENGR->(DbSkip())
      enddo
      if PASSENGR->(Eof())
         Message("End of File reached...")
         Tone(100,3)
         Inkey(2)
         PASSENGR->(DbGoto(nRecNo))
      endif
   endif
return nil

static function PassLabel()
local nRecno := RecNo()
   aItems := {}; aRecs := {}
   DbGotop()
   do while !Eof()
      aAdd(aItems, "  "+ Pass_Name)
      aAdd(aRecs,Recno())
      DbSkip()
   enddo
   wLookUp := OpenWindow(10,03,22,45,"Print Labels")
   aScrollBar:=ScrollBarNew(11,45,22,"N/W",1)
   ScrollBarDisplay(aScrollBar)
   ScrollBarUpdate(aScrollBar,1,Len(aItems),.T.)
   Message("Press [ENTER] to toggle select, [ESC] to abort,"+;
           " [CTRL+ENTER] to print...")
   AChoice(12,04,21,43,aItems,,"HandleMenu")
   CloseWindow(wLookUp)
   if lastKey() # K_ESC
      if PrintReady()
          Message("Printing label, please wait...")
         set console off
         set printer on
         ?? _PRN_RESET
         for n := 1 to len(aItems)
            if substr(aItems[n],1,1) == chr(251)
               DbGoto(aRecs[n])
               ??? "   ", _PRN_EMPHON +formatName(Pass_Name)+ _PRN_EMPHOFF
               if !empty(ADDRCOY)    ; ??? "   ", ADDRCOY    ;endif
               if !empty(ADDRRMBLDG) ; ??? "   ", ADDRRMBLDG ;endif
               if !empty(ADDRNOST)   ; ??? "   ", ADDRNOST   ;endif
               if !empty(ADDRDIST)   ; ??? "   ", ADDRDIST   ;endif
               if !empty(ADDCTYCTRY) ; ??? "   ", ADDCTYCTRY ;endif
               ???
               ???
            endif
         next
         set printer off
         set console on
         tone(300,1)
         inkey(2)
      endif
   endif
   DbGoto(nRecNo)
   return nil

function HandleMenu(nMode,nCurElem,nRelPos)
local nRetVal,nKey
   ScrollBarUpdate(aScrollBar,nCurElem,Len(aItems),.F.)
   do case
      case nMode==AC_EXCEPT            // Is key stroke used by AChoice?
         nKey:=LastKey()               // No -- get last key pressed.
         do case
            case nKey==K_ESC           // Esc key pressed?
               nRetVal:=AC_ABORT       // Yes -- abort menu selection.
            case nKey==K_CTRL_RET         //
               nRetVal:=AC_SELECT      // Yes -- make selection.
            case nKey==K_RETURN
               if substr(aItems[nCurElem],1,1) # chr(251)
                  aItems[nCurElem] := chr(251) + substr(aItems[nCurElem],2)
               else
                  aItems[nCurElem] := " " + substr(aItems[nCurElem],2)
               endif
               nRetVal:=AC_CONT
            otherwise                  // Other keys pressed.
               nRetVal:=AC_CONT        // Continue selection.
         endcase
      otherwise                        // Keystoke used by Achoice.
         nRetVal:=AC_CONT              // ....continue selection.
   endcase
return nRetVal


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
         cMonth := substr(dtoc(date()),1,2) + "00"
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
      PASSENGR->(DbSetOrder(2))
      PASSENGR->(DbGotop())
      PASSENGR->(DbSeek(cMonth + "00"))
      do while PASSENGR->(!Eof()) .and. cMonth == substr(dtoc(PASSENGR->Pass_Birth),1,2)
                ? substr(dtoc(PASSENGR->Pass_Birth),4,2) + "  "
                ?? PASSENGR->Pass_Name
                ?? chr(15)
                if !empty(PASSENGR->AddrCoy); ?? ' ',alltrim(PASSENGR->AddrCoy); endif
                if !empty(PASSENGR->AddrRmBldg); ?? ' ',alltrim(PASSENGR->AddrRmBldg); endif
                if len(alltrim(PASSENGR->AddrCoy)) +;
                   len(alltrim(PASSENGR->AddrRmBldg)) + len(alltrim(PASSENGR->AddrNoSt)) > 90
                   ? space(75) + alltrim(PASSENGR->AddrNoSt)
                   if !empty(PASSENGR->AddrDist); ?? ' ',alltrim(PASSENGR->AddrDist); endif
                   if len(alltrim(PASSENGR->AddrNoSt)) +;
                      len(alltrim(PASSENGR->AddrDist)) + len(alltrim(PASSENGR->AddCtyCtry)) > 90
                      ? space(75) + alltrim(PASSENGR->AddCtyCtry)
                   else
                      ?? ' ',alltrim(PASSENGR->AddCtyCtry)
                   endif
                else
                  if !empty(PASSENGR->AddrNoSt); ?? ' ',alltrim(PASSENGR->AddrNoSt); endif
                  if len(alltrim(PASSENGR->AddrCoy)) +len(alltrim(PASSENGR->AddrRmBldg)) +;
                     len(alltrim(PASSENGR->AddrNoSt))+len(Alltrim(AddrDist)) > 90
                     ? space(75) + alltrim(PASSENGR->AddrDist)
                      ?? ' ',alltrim(PASSENGR->AddCtyCtry)
                  else
                    if !empty(PASSENGR->AddrDist); ?? ' ',alltrim(PASSENGR->AddrDist); endif
                    if len(alltrim(PASSENGR->AddrCoy)) +len(alltrim(PASSENGR->AddrRmBldg)) +;
                       len(alltrim(PASSENGR->AddrNoSt))+len(Alltrim(AddrDist)) +;
                       len(alltrim(PASSENGR->AddCtyCtry)) > 90
                       ? space(75) + alltrim(PASSENGR->AddCtyCtry)
                    else
                       ?? ' ',alltrim(PASSENGR->AddCtyCtry)
                    endif
                  endif
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
         tone(300,1)
         inkey(2)
      endif
   endif
   return .f.

static function formatName(sName)
local x,aName:={}
local Title:={"Mr.","Mrs.","Ms.","Mist.","Mstr."}
  x:=0
  for i:= 1 to len(Title)
   pos:= at(Upper(Title[i]),Upper(sName))
   if pos > 0
     sName:=substr(sName,1,pos-2)
     x:=i
   endif
  next
 if "," $ sName
   aName:= {substr(sName, 1, at(",",sName) -1),;
            substr(sName,at(",",sName) +2),;
            if(x=0,"",Title[x])}
 else
   aName:= {sName,"",if(x=0,"",Title[x])}
 endif
return aName[3]+" "+trim(aName[2])+" "+alltrim(aName[1])

// end-of-file