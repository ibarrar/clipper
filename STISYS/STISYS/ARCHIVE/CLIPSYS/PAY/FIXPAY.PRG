/*
                Filename: MASTER.PRG
             System-Name: Super Travel Payroll System
                  Module: Master Card File Handler
                  Author: Ronan J. Paredes
            Date-Started: January 7,1993
             Last-Update: March 19,1993
*/

#include "inkey.ch"
#include "setcurs.ch"
#include "achoice.ch"
#include "box.ch"
#include "Janus.Ch"


#define MC_STAT "F2-Add   F3-Edit   F4-Delete   F5-Search   F6-Sub-Records   ESC-Abort"

static _Name, _Slot, _Addr, _Phone, _Dept, _Sss, _Tan, _In, _Out
static aPicture0, aPicture1, aPicture2, aPicture3, aPicture4
function do_mc()
local wMc, nkey
   DefinePics()
   if netUse("WAGE",DB_SHARED,NUM_SECONDS)
      set index to WAGE
   endif
   if netUse("HISTORY",DB_SHARED,NUM_SECONDS)
      set index to HISTORY
   endif
   if netUse("ACCRCV",DB_SHARED,NUM_SECONDS)
      set index to ACCRCV
   endif
   if netUse("LOAN",DB_SHARED,NUM_SECONDS)
      set index to LOAN
   endif
   if netUse("PAYTRANS",DB_SHARED,NUM_SECONDS)
      set index to PAYTRANS, PAYDATE
   endif
   if netUse("PAYMAST",DB_SHARED,NUM_SECONDS)
      set index to PAYMAST, PAYSLOT
   endif
   wMc := OpenWindow(04,06,12,73,"Master File")
   if PAYMAST->(reccount())==0 ; Mc_Form(APPEND_MODE) ; endif
   if lastKey()!=K_ESC
      do while (nkey!=K_ESC)
         Mc_Form(VIEW_MODE)
         nkey:=inkey(0)
         do case
            case nkey==K_DOWN
               PAYMAST->(Dbskip())
               if PAYMAST->(eof())
                  PAYMAST->(Dbgobottom())
                  tone(100,3)
                  Message("End of file reached....")
                  inkey(1)
               endif
            case nKey==K_UP
               PAYMAST->(Dbskip(-1))
               if PAYMAST->(bof())
                  PAYMAST->(Dbgotop())
                  tone(100,3)
                  Message("Beginning of file reached....")
                  inkey(1)
               endif
            case nKey==K_CTRL_PGDN
               PAYMAST->(Dbskip(NUM_TO_SKIP))
               if PAYMAST->(eof())
                  PAYMAST->(Dbgobottom())
                  tone(100,3)
                  Message("End of file reached....")
                  inkey(1)
               endif
            case nKey==K_CTRL_PGUP
               PAYMAST->(Dbskip(-NUM_TO_SKIP))
               if PAYMAST->(bof())
                  PAYMAST->(Dbgotop())
                  tone(100,3)
                  Message("Beginning of file reached....")
                  inkey(1)
               endif
            case nKey==K_END
               PAYMAST->(Dbgobottom())
                  Message("Moving to end of file....")
                  inkey(1)
            case nKey==K_HOME
               PAYMAST->(Dbgotop())
                  Message("Moving to beginning of file....")
                  inkey(1)
            case nKey==K_F2
               Message("Press ENTER to add new record.")
               if inkey(0)==K_ENTER
                  Mc_Form(APPEND_MODE)
               endif
            case nKey==K_F3
               Mc_Form(EDIT_MODE)
            case nKey==K_F4
               Message("Press ENTER to delete record, ESC to abort.")
               if inkey(0)==K_ENTER
                  Message("Deleting current record....")
                  if WAGE->(Dbseek(PAYMAST->(recno()) ))
                     do while WAGE->rec_no == PAYMAST->(recno())
                        WAGE->(RecLock(0))
                        WAGE->(Dbdelete())
                        WAGE->(Dbskip())
                        WAGE->(DbUnlock())
                     enddo
                  endif
                  PAYMAST->(RecLock(0))
                  PAYMAST->(Dbdelete())
                  PAYMAST->(Dbunlock())
               endif
            case nKey==K_F5
               PAYMAST->(Mc_Search())
            case nKey==K_F6
               McSubRecs()
         endcase
      enddo
   endif
   Message("Closing Databases....")
   PAYMAST->(DbCloseArea())
   PAYTRANS->(DbCloseArea())
   LOAN->(DbCloseArea())
   ACCRCV->(DbCloseArea())
   HISTORY->(DbCloseArea())
   WAGE->(DbCloseArea())
   CloseWindow(wMc)
return nil

static function Mc_Form(nMode)
local clr, crs
   tone(300,1)
   Mc_Init(nMode)
   Message(MC_STAT)
   clr := setcolor("N/BG")
   if PAYMAST->(Deleted()) ; @ 04,35 say "<deleted>"
   else ; @ 04,35 say "         " ; endif
   if nMode==APPEND_MODE
       @ 04, 62 say "< New >   "
   else
       @ 04, 62 say "Rec #"+transform(PAYMAST->(recno()),"9999")
   endif
   setcolor( clr )
   @ 06,      08 say  "Employee Name" get _Name  picture repl('x',30)
   @ row()+1, 08 say  "     Slot No." get _Slot  picture "999" ;
        valid CheckSlot(nMode,_Slot)
   @ row()+1, 08 say  "      Address"  get _Addr  picture repl('x',50)
   @ row()+1, 08 say  "    Phone No."  get _Phone picture repl('x',10)
   @ row(),   40 say  "   Department"  get _Dept  picture repl('x',15)
   @ row()+1, 08 say  "      SSS No."  get _Sss   picture repl('x',15)
   @ row(),   40 say  "      TAN No."  get _Tan   picture repl('x',15)
   @ row()+1, 08 say  "Date Employed"  get _In
   @ row(),   40 say  "Date Resigned"  get _Out
   if (nMode==APPEND_MODE) .or. (nMode==EDIT_MODE)
      crs := setcursor(SC_NORMAL)
      read
      if lastkey()!=K_ESC
         Mc_Save(nMode)
      endif
      setcursor( crs )
   else
      clear gets
   endif
return nil

static function Mc_Init(nMode)
   if nMode==APPEND_MODE
      _Name  := space(30)
      _Slot  := 0
      _Addr  := space(50)
      _Phone := space(10)
      _Dept  := space(15)
      _Sss   := space(15)
      _Tan   := space(15)
      _In    := ctod("")
      _Out   := ctod("")
   else
      _Name  := PAYMAST->Emp_Name
      _Slot  := PAYMAST->Emp_Slot
      _Addr  := PAYMAST->Emp_Addr
      _Phone := PAYMAST->Emp_Phone
      _Dept  := PAYMAST->Emp_Dept
      _Sss   := PAYMAST->Emp_Sss
      _Tan   := PAYMAST->Emp_Tan
      _In    := PAYMAST->Emp_In
      _Out   := PAYMAST->Emp_Out
   endif
return nil

static function Mc_Save(nMode)
   Message("Saving entries...")
   if nMode==APPEND_MODE
      PAYMAST->(FilLock(0))
      PAYMAST->(Dbappend())
      PAYMAST->(DbUnLock())
   endif
   PAYMAST->(RecLock(0))
   PAYMAST->Emp_Name  := _Name
   PAYMAST->Emp_Slot  := _Slot
   PAYMAST->Emp_Addr  := _Addr
   PAYMAST->Emp_Phone := _Phone
   PAYMAST->Emp_Dept  := _Dept
   PAYMAST->Emp_Sss   := _Sss
   PAYMAST->Emp_Tan   := _Tan
   PAYMAST->Emp_In    := _In
   PAYMAST->Emp_Out   := _Out
   PAYMAST->(DbUnlock())
   PAYMAST->(DbCommit())
return nil

static function Mc_Search()
local wSearch, nRecno := PAYMAST->(recno()), cEmployee := space(30)
     wSearch := openwindow(09,23,13,57,"Search Employee")
     @ 11, 25 say "Enter employee name to search"
     @ 12, 25 get cEmployee pict "@!"
     setcursor(SC_NORMAL)
     read
     setcursor(SC_NONE)
     closewindow(wSearch)
     if lastkey() != K_ESC
        cEmployee := alltrim(cEmployee)
        if PAYMAST->(Dbseek(cEmployee))
           do while (cEmployee $ PAYMAST->emp_name) .and. PAYMAST->(!eof())
              PAYMAST->(Mc_Form(VIEW_MODE))
              Message("Press any key to search for more, Esc to abort...")
              inkey(0)
              if lastkey()==K_ESC
                 exit
              else
                 PAYMAST->(Dbskip())
              endif
           enddo
        else
           Message("Name not found...")
           tone(100,3)
           inkey(2)
           PAYMAST->(Dbgoto(n_recno))
        endif
     endif
return nil

static function CheckSlot(nMode,nSlot)
local nRecNo := PAYMAST->(RecNo()), lOkSlot := .T., crs
    if nMode == APPEND_MODE
       PAYMAST->(DbGotop())
       do while PAYMAST->(!Eof()) .and. lOkSlot
          if nSlot == PAYMAST->Emp_Slot .and. ;
             empty(PAYMAST->Emp_Out)
             lOkSlot := .F.
          endif
          PAYMAST->(DbSkip())
       enddo
       if !lOkSlot
          crs := setcursor( SC_NONE )
          Message("Slot number currently used by another employee...")
          tone(100,5)
          inkey(2)
          Message("")
          setcursor( crs )
       endif
    endif
    PAYMAST->(DbGoto(nRecNo))
return lOkSlot

function ValidSlot(nSlot)
local nRecNo := PAYMAST->(Recno()), wLookUp, clr
  if LastKey() == K_TAB
     aItems := {}
     PAYMAST->(DbGotop())
     do while PAYMAST->(!Eof())
        aAdd( aItems, str( PAYMAST->EMP_SLOT, 3) + "  " + PAYMAST->EMP_NAME )
        PAYMAST->(DbSkip())
     enddo
     PAYMAST->(DbGoto(nRecno))
     wLookUp := savescreen( 06,40,20,78 )
     clr := setcolor( "W+/R,N/W" )
     @ 06, 40, 19, 77 box B_SINGLE + " "
     Shadow( 06,40,19,77 )
     @ 06, 53 say " Slot Nos. "
     aScrollBar:=ScrollBarNew(07,77,18,"W+/R",1)
     ScrollBarDisplay(aScrollBar)
     ScrollBarUpdate(aScrollBar,1,Len(aItems),.T.)
     n:=AChoice(07,42,18,75,aItems,,"HandleMenu")
     setcolor( clr )
     restscreen( 06,40,20,78,wLookUp)
     if LastKey()!=K_ESC
        nSlot := val( substr( aItems[n],1,3 ) )
        return .F.
     endif
  endif
  return .T.

function HandleMenu(nMode,nCurElem,nRelPos)
local nRetVal,nKey
   ScrollBarUpdate(aScrollBar,nCurElem,Len(aItems),.F.)
   do case
      case nMode==AC_EXCEPT            // Is key stroke used by AChoice?
         nKey:=LastKey()               // No -- get last key pressed.
         do case
            case nKey==K_ESC           // Esc key pressed?
               nRetVal:=AC_ABORT       // Yes -- abort menu selection.
            case nKey==K_ENTER         // Enter key pressed?
               nRetVal:=AC_SELECT      // Yes -- make selection.
            otherwise                  // Other keys pressed.
               nRetVal:=AC_CONT        // Continue selection.
         endcase
      otherwise                        // Keystoke used by Achoice.
         nRetVal:=AC_CONT              // ....continue selection.
   endcase
return nRetVal

static function TimeAsMins(cTime)
   return (val(cTime) * 60) + val(substr(cTime,4,2))

function MinDiff(cStartTime,cEndTime)
return if( TimeAsMins(cEndTime) > TimeAsMins(cStartTime),;
           TimeAsMins(cEndTime) - TimeAsMins(cStartTime), 0)

static function DefinePics()
   aPicture0:=array(6,2)
   aPicture0[1][1] := FieldBlock("Rec_No")
   aPicture0[1][2] := "@!"
   aPicture0[2][1] := FieldBlock("Date")
   aPicture0[2][2] := "@!"
   aPicture0[3][1] := FieldBlock("Wg_BPay")
   aPicture0[3][2] := "9,999.99"
   aPicture0[4][1] := FieldBlock("Wg_Stat")
   aPicture0[4][2] := "!"
   aPicture0[5][1] := FieldBlock("Wg_Taxc")
   aPicture0[5][2] := "!!!"
   aPicture0[6][1] := FieldBlock("Wg_Key")
   aPicture0[6][2] := "Y"
   aPicture1:=array(6,2)
   aPicture1[1][1] := FieldBlock("Rec_No")
   aPicture1[1][2] := "@!"
   aPicture1[2][1] := FieldBlock("Date")
   aPicture1[2][2] := "@!"
   aPicture1[3][1] := FieldBlock("Gross")
   aPicture1[3][2] := "9,999.99"
   aPicture1[4][1] := FieldBlock("Wtax")
   aPicture1[4][2] := "9,999.99"
   aPicture1[5][1] := FieldBlock("SSS")
   aPicture1[5][2] := "9,999.99"
   aPicture1[6][1] := FieldBlock("MED")
   aPicture1[6][2] := "9,999.99"
   aPicture1[6][1] := FieldBlock("Net")
   aPicture1[6][2] := "9,999.99"
   aPicture2:=array(3,2)
   aPicture2[1][1] := FieldBlock("Rec_No")
   aPicture2[1][2] := "@!"
   aPicture2[2][1] := FieldBlock("AR_Date")
   aPicture2[2][2] := "@!"
   aPicture2[3][1] := FieldBlock("AR_Amount")
   aPicture2[3][2] := "9,999.99"
   aPicture3:=array(7,2)
   aPicture3[1][1] := FieldBlock("Rec_No")
   aPicture3[1][2] := "@!"
   aPicture3[2][1] := FieldBlock("Ln_Date")
   aPicture3[2][2] := "@!"
   aPicture3[3][1] := FieldBlock("Ln_Month")
   aPicture3[3][2] := "99"
   aPicture3[4][1] := FieldBlock("Ln_Amount")
   aPicture3[4][2] := "99,999.99"
   aPicture3[5][1] := FieldBlock("Ln_Remit")
   aPicture3[5][2] := "99,999.99"
   aPicture3[6][1] := FieldBlock("Ln_Balance")
   aPicture3[6][2] := "99,999.99"
   aPicture3[7][1] := FieldBlock("Ln_LastDed")
   aPicture3[7][2] := "99,999.99"
   aPicture4:=array(11,2)
   aPicture4[1][1] := FieldBlock("Rec_No")
   aPicture4[1][2] := "@!"
   aPicture4[2][1] := FieldBlock("Tr_Date")
   aPicture4[2][2] := "@!"
   aPicture4[3][1] := FieldBlock("Tr_AmIn")
   aPicture4[3][2] := "99:99"
   aPicture4[4][1] := FieldBlock("Tr_AmOut")
   aPicture4[4][2] := "99:99"
   aPicture4[5][1] := FieldBlock("Tr_PmIn")
   aPicture4[5][2] := "99:99"
   aPicture4[6][1] := FieldBlock("Tr_PmOut")
   aPicture4[6][2] := "99:99"
   aPicture4[7][1] := FieldBlock("Tr_AmInUs")
   aPicture4[7][2] := "9"
   aPicture4[8][1] := FieldBlock("Tr_AmOutUs")
   aPicture4[8][2] := "9"
   aPicture4[9][1] := FieldBlock("Tr_PmInUs")
   aPicture4[9][2] := "9"
   aPicture4[10][1] := FieldBlock("Tr_PmOutUs")
   aPicture4[10][2] := "9"
   aPicture4[11][1] := FieldBlock("Tr_PmOutOs")
   aPicture4[11][2] := "9"
return nil

static function McSubRecs()
local cSub, aMenu := {"  Daily Time Record   ","  Wage File       ",;
                      "  Wage History        ","  Accounts Receivable  ",;
                      "  SSS Loan File       "}
   n := 1
   wSub := OpenWindow(11,04,18,35,"Sub-Records")
   do while n # 0
      Message(SELECT_BAR)
      n:=AChoice(13,06,17,33,aMenu,,,n)
      if n # 0
         do case
         case n == 1
            PAYTRANS->(abrowse4(PAYMAST->(recno()),aPicture4))
         case n == 2
            WAGE->(abrowse0(PAYMAST->(recno()),aPicture0))
         case n == 3
            HISTORY->(abrowse1(PAYMAST->(recno()),aPicture1))
         case n == 4
            ACCRCV->(abrowse2(PAYMAST->(recno()),aPicture2))
         case n == 5
            LOAN->(abrowse3(PAYMAST->(recno()),aPicture3))
         endcase
      endif
   enddo
   CloseWindow(wSub)
return nil

//end-of-file
