/*
        Filename: MASTER.PRG
     System-Name: Master File Handler
          Author: Rolando C. Ibarra Jr.
    Date-Started: August 3, 1994
     Last-Update: August 3, 1994
*/
#include "Inkey.ch"
#include "setcurs.ch"
#include "aChoice.ch"
#include "Box.ch"
#include "Janus.ch"

#define BAR "F2-Add  F3-Edit  F4-Del/Undel  F5-Search  F6-Machines  ESC-Abort"

memvar GETLIST
static _TCode, _TName, _OName, _OAddr, _OTel, _TermCount, _MacCode, _ClusCode
static _SArea, _BRate,_CRate
static aItems,aScrollBar,aPicture

function Master()
local wMast, nKey
  DefinePics()
  if NetUse("MASTER",DB_SHARED,NUM_SECONDS)
     set index to MASTER
  endif
  if NetUse("ISCMAP",DB_SHARED,NUM_SECONDS)
     set index to ISCMAP,ISCODE
  endif
  wMast := OpenWindow(04,06,18,73,"Master File")
  if MASTER->(reccount()) == 0; Screen(APPEND_MODE); endif
  if lastkey() != K_ESC
     do while (nkey!=K_ESC)
        Screen(VIEW_MODE)
        nkey:=inkey(0)
        do case
           case nkey==K_DOWN
             MASTER->(Dbskip())
             if MASTER->(eof())
                MASTER->(DbGobottom())
                tone(100,3)
                Message("End of file reached....")
                inkey(1)
             endif
           case nkey==K_UP
             MASTER->(Dbskip(-1))
             if MASTER->(bof())
                MASTER->(Dbgotop())
                tone(100,3)
                Message("Beginning of file reached....")
                inkey(1)
             endif
           case nkey==K_CTRL_PGDN
             MASTER->(Dbskip(NUM_TO_SKIP))
             if MASTER->(eof())
                MASTER->(Dbgobottom())
                tone(100,3)
                Message("End of file reached....")
                inkey(1)
             endif
           case nkey==K_CTRL_PGUP
             MASTER->(Dbskip(-NUM_TO_SKIP))
             if MASTER->(bof())
                MASTER->(Dbgotop())
                tone(100,3)
                Message("Beginning of file reached....")
                inkey(1)
             endif
           case nkey==K_END
             Message("Moving to end of file....")
             MASTER->(Dbgobottom())
             inkey(1)
           case nkey==K_HOME
             Message("Moving to beginning of file...")
             MASTER->(Dbgotop())
             inkey(1)
           case nkey==K_F2
             Message("Press ENTER to add new record.")
             if inkey(0)==K_ENTER
                Screen(APPEND_MODE)
             endif
           case nkey==K_F3
             Screen(EDIT_MODE)
           case nkey==K_F4
             if MASTER->(Deleted())
                Message("Press ENTER to undelete record, ESC to Abort.")
                if inkey(0)==K_ENTER
                   Message("Undeleting current record....")
                   MASTER->(RecLock(0))
                   MASTER->(DbRecall())
                   MASTER->(DbUnlock())
                endif
              else
                 Message("Press ENTER to delete record, ESC to Abort.")
                 if inkey(0)==K_ENTER
                    Message("Deleting current record....")
                    MASTER->(RecLock(0))
                    MASTER->(Dbdelete())
                    MASTER->(DbUnlock())
                  endif
               endif
           case nkey==K_F5
             MASTER->(M_Search())
           case nkey==K_F6
             ISCMAP->(abrowse(MASTER->(Recno()),aPicture,VIEW_MODE))
        endcase
     enddo
  endif
  Message("Closing Databases....")
  MASTER->(DbCloseArea())
  ISCMAP->(DbCloseArea())
  CloseWindow(wMast)
return nil

static function Screen(nMode)
local clr, crs
  tone(300,1)
  M_Init(nMode)
  Message(BAR)
  clr := setcolor("W*/RB")
  if MASTER->(Deleted()); @ 04,35 say "<deleted>"
  else ; @04,35 say "         " ; endif
  setcolor("W+/RB")
  if nMode==APPEND_MODE
     @ 04,62 say "< New >  "
  else
     @ 04,62 say "Rec #"+transform(MASTER->(recno()),"9999")
  endif
  setcolor( clr )
  @ 06,     08 say "       Tenants Code" get _TCode pict "@!K A99999" valid(CheckCode(nMode,_TCode))
  @ row()+1,08 say "       Tenants Name" get _TName valid(!empty(_TName))
  @ row()+1,08 say "       Owner's Name" get _OName valid(!empty(_OName))
  @ row()+1,08 say "            Address" get _OAddr valid(!empty(_OAddr))
  @ row()+1,08 say "        Telephone #" get _OTel  pict repl("X",14)
  @ row()+1,08 say "Number of Terminals" get _TermCount pict "@K 99" valid(_TermCount>0.and._TermCount<63)
  @ row()+1,08 say "       Machine Code" get _MacCode   when(MacLookUp()) picture "9"
  @ row()+1,08 say "       Cluster Code" get _ClusCode when(Dispcode())
  @ row()+1,08 say "         Sales Area" get _SArea pict "999.99"
  @ row()+1,08 say "       Billing Rate" get _BRate pict "99.99"
  @ row()+1,08 say "    Conversion Rate" get _CRate pict "99.999999"

  if (nMode==APPEND_MODE) .or. (nMode==EDIT_MODE)
     crs := setcursor(SC_NORMAL)
     read
     if lastkey() != K_ESC
        M_Save(nMode)
        ISCMAP->(abrowse(MASTER->(Recno()),aPicture,nMode))
     endif
     setcursor( crs )
  else
   clear gets
  endif
return nil

static function DispCode()
local clust, getlist := {}
local lLastReadExit
 clust := substr(_ClusCode,2,1)
 @ 13,28 say _MacCode pict "9"
 @ 13,29 get clust pict "@K 9" valid(val(clust)>0 .and. val(clust)<10)
 lLastReadExit := ReadExit(.T.)
 read
 ReadExit(lLastReadExit)
 // Cluster Code
 _ClusCode := str(_MacCode,1) + transform(alltrim(clust),"9")
return .F.

static function M_Init(nMode)
 if nMode==APPEND_MODE
    _TCode     := space(6)
    _TName     := space(20)
    _OName     := space(20)
    _OAddr     := space(30)
    _OTel      := space(14)
    _TermCount := 1
    _MacCode   := 1
    _ClusCode  := space(2)
    _SArea     := 0
    _BRate     := 0
 else
    _TCode     := MASTER->TCODE
    _TName     := MASTER->OTNAME
    _OName     := MASTER->ONAME
    _OAddr     := MASTER->OADDR
    _OTel      := MASTER->OTNUM
    _TermCount := MASTER->NUMTER
    _MacCode   := MASTER->MCODE
    _ClusCode  := MASTER->CCODE
    _SArea     := MASTER->SAREA
    _BRate     := MASTER->BRATE
    _CRate     := MASTER->CRATE
  endif
return nil

static function M_Save(nMode)
 Message("Saving Entries....")
 if nMode==APPEND_MODE
    MASTER->(FilLock(0))
    MASTER->(Dbappend())
    MASTER->(DbUnlock())
 endif
 MASTER->(RecLock(0))
 MASTER->TCODE       := _TCode
 MASTER->OTNAME      := _TName
 MASTER->ONAME       := _OName
 MASTER->OADDR       := _OAddr
 MASTER->OTNUM       := _OTel
 MASTER->NUMTER      := _TermCount
 MASTER->MCODE       := _MacCode
 MASTER->CCODE       := _ClusCode
 MASTER->BRATE       := _BRate
 MASTER->SAREA       := _SArea
 MASTER->CRATE       := _CRate
 MASTER->(DbUnlock())
 MASTER->(DbCommit())
return nil

static function M_Search()
local wSearch, nRecno :=MASTER->(Recno())
static cKey := "      "
  cKey:=padr(cKey,6)
  wSearch := OpenWindow(09,23,13,57,"Search Tenant Code")
  @ 11, 25 say "Enter Tenant's Code to search"
  @ 12, 25 get cKey picture "@!K A99999"
  setcursor(SC_NORMAL)
  read
  setcursor(SC_NONE)
  closeWindow(wSearch)
  if lastkey() != K_ESC
     cKey := alltrim(cKey)
     if MASTER->(DbSeek(cKey))
        do while (cKey $ MASTER->TCODE) .and. MASTER->(!eof())
          MASTER->(Screen(VIEW_MODE))
          Message("Press any key to search for more, ESC to Abort...")
          inkey(0)
          if lastkey()==K_ESC
             exit
          else
             MASTER->(DbSkip())
          endif
        enddo
     else
      Message("Code Not Found...")
      tone(100,4)
      MASTER->(Dbgoto(nRecno))
     endif
  endif
return nil

static function CheckCode(nMode,nCode)
local nRecno := MASTER->(RecNo()), lOkCode := .T.,crs
  if nMode == APPEND_MODE
   if (len(alltrim(nCode))==6)
      MASTER->(DbGotop())
      MASTER->(DbSeek(nCode))
      do while ((MASTER->TCODE == nCode) .and. (MASTER->(!Eof())) .and. (lOkCode))
         if !(MASTER->(Deleted()))
          crs := setcursor( SC_NONE )
          Message(" Tenants Code Already in use....")
          tone(500,4)
          setcursor(crs)
          lOkCode := .f.
         endif
      enddo
  else
   lOkcode := .f.
  endif
 endif
  MASTER->(DbGoto(nRecNo))
return lOkCode

static function MacLookUp()
local n,wLookUp, clr
aItems := {"  RS-3460  ",;
           "  RS-3510  ",;
           "  RS-4540  ",;
           "  RS-5550  "}
    wLookUp:= savescreen( 08,31,08+len(aItems)+2,46 )
    clr := setcolor("W+/RB,N/W")
    @ 08,31,08+len(aItems)+1,45 box B_SINGLE + " "
    Shadow( 08,31,08+len(aItems)+1,45 )
    @ 08,32 say "Machine Codes"
    aScrollBar:=ScrollBarNew(09,45,09+len(aItems),"W+/RB",1)
    ScrollBarDisplay(aScrollBar)
    ScrollBarUpdate(aScrollBar,1,Len(aItems),.T.)
    n:=AChoice(09,32,09+len(aItems),44,aItems,,"HandleMenu",,_MacCode)
    if (n > 0)
     _MacCode := n
    endif
    setcolor( clr )
    restscreen( 08,31,08+len(aItems)+2,46,wLookUp )
return .T.

function HandleMenu(nMode,nCurElem,nRelPos)
local nRetVal,nKey
   ScrollBarUpdate(aScrollBar,nCurElem,len(aItems),.F.)
   do case
      case nMode==AC_EXCEPT
           nKey:=Lastkey()
           do case
              case nKey==K_ESC
                   nRetVal:=AC_ABORT
              case nKey==K_ENTER
                   nRetVal:=AC_SELECT
              otherwise
                   nRetVal:=AC_CONT
           endcase
       otherwise
          nRetVal:=AC_CONT
   endcase
return nRetVal

static function DefinePics()
 aPicture:=array(5,2)
 aPicture[1,1] := FieldBlock("REC_NO")
 aPicture[1,2] := "@!"
 aPicture[2,1] := FieldBlock("ISC_NO")
 aPicture[2,2] := "99"
 aPicture[3,1] := FieldBlock("TCODE")
 aPicture[3,2] := "X99999"
 aPicture[4,1] := FieldBlock("CLUSTER")
 aPicture[4,2] := "99"
 aPicture[5,1] := FieldBlock("REMARKS")
 aPicture[5,2] := replicate("X",20)
return nil

/*-*-*-*-*-*-*-<End of File>-*-*-*-*-*-*-*/