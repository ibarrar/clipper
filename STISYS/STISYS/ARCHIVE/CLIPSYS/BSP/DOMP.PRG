/* Filename DOMP.prg
 * Module   Domestic Unbilled Printout Module
 * Author   Rolando C. Ibarra Jr.
 * Date     November 10,1993
 */


#include "Inkey.ch"
#include "Setcurs.ch"
#include "Mode.Ch"
#include "C501_MOD.ch"
#include "BSP.Ch"

#define PAGE1_BAR   "F1-Help  F2-Add  F3-Edit  F4-Dele  F5-Name  F6-Tkt F8-Total PgDn-Next"

static mFdate, mPassenger, mTicketNo, mRoute1, mRoute2, mAmount
static mTrans_p,mCrate_p,mRemit_p,mTax_p,mACM_p

function Do_UnBDom()
local  nKey:=0 ,wBSP
   if NetUse("UNBDOM",DB_SHARED,NUM_SECONDS)
    set index to UNBDOM
   endif
   UNBDOM->(DbGotop())
   wBSP := OpenWindow(03,10,17,69,"Unbilled Domestic Tkts.")
    if UNBDOM->(RecCount())==0 ; BSP_Page1(APPEND_MODE) ; endif
   if LastKey()!=K_ESC
      do while (nKey!=K_ESC)
         BSP_Page1(VIEW_MODE)
         nKey:=inKey(0)
         do case
            case nKey==K_DOWN
               UNBDOM->(DbSkip())
               if UNBDOM->(Eof())
                  UNBDOM->(DbGoBottom())
                  Tone(200,1)
                  Message("End of file reached....")
                  Inkey(1)
               endif
            case nKey==K_UP
               UNBDOM->(DbSkip(-1))
               if UNBDOM->(Bof())
                  UNBDOM->(DbGoTop())
                  Tone(200,1)
                  Message("Beginning of file reached....")
                  Inkey(1)
               endif
            case nKey==K_CTRL_PGDN
               UNBDOM->(DbSkip(NUM_TO_SKIP))
               if UNBDOM->(Eof())
                  UNBDOM->(DbGoBottom())
                  Tone(200,1)
                  Message("End of file reached....")
                  Inkey(1)
               endif
            case nKey==K_CTRL_PGUP
               UNBDOM->(DbSkip(-NUM_TO_SKIP))
               if UNBDOM->(Bof())
                  UNBDOM->(DbGoTop())
                  Tone(200,1)
                  Message("Beginning of file reached....")
                  Inkey(1)
               endif
            case nKey==K_END
                UNBDOM->(DbGoBottom())
                Message("Moving to end of file....")
                Inkey(1)
            case nKey==K_HOME
                UNBDOM->(DbGoTop())
                Message("Moving to beginning of file....")
                Inkey(1)
            case nKey==K_F1
               more_keys()
            case nKey==K_F2
                Message("Press ENTER to Add, ESC to abort.")
                if Inkey(0)==K_ENTER
                   Bsp_Page1(APPEND_MODE)
                   if LastKey()!=K_ESC   ;   UNBDOM->(SaveVariables(APPEND_MODE))   ;   endif
                endif
            case nKey==K_F3
                Message("Press ENTER to Edit, ESC to abort.")
                if Inkey(0)==K_ENTER
                   Bsp_Page1(EDIT_MODE)
                   if LastKey()!=K_ESC   ;   UNBDOM->(SaveVariables(EDIT_MODE))   ;   endif
                endif
            case nKey==K_F4
                Message("Press ENTER to Delete, ESC to abort.")
                if Inkey(0)==K_ENTER
                    UNBDOM->(Fillock())
                    UNBDOM->(DbDelete())
                    UNBDOM->(DbUnlock())
                endif
            case nKey==K_F5
                UNBDOM->(SearchPax())
            case nKey==K_F6
                UNBDOM->(SearchTkt())
            case nKey==K_F8
                UNBDOM->(Totals())
            case nKey==K_F9
                Message("Press ENTER to Reindex, ESC to abort.")
                if Inkey(0)==K_ENTER
                  Message("Reindexing, please wait....")
                  UNBDOM->(FilLock(0))
                  UNBDOM->(DbReindex())
                  UNBDOM->(DbUnlock())
                endif
            endcase
      enddo
   endif
   UNBDOM->(Print())
   CloseWindow(wBSP)
return nil

static function BSP_Page1(nMode)
local nKey
   UNBDOM->(InitVariables(nMode))
   Message(PAGE1_BAR)
   Tone(300,1)
   cColor:=SetColor("N/BG")
   if UNBDOM->(Deleted()) ; @ 03,35 say "<deleted>"
   else ; @ 03,35 say "         " ; endif
   @ 03,55 say "Rec# " + ;
   Transform(If(nMode==APPEND_MODE,UNBDOM->(LastRec())+1,UNBDOM->(RecNo())),"9999")+;
   "/"+Transform(UNBDOM->(LastRec()),"9999")
   SetColor(cColor)
   @ 05,      18      say "Date" get mFdate
   @ row(), col()+6 say "Ticket#" get mTicketNo
   @ row()+2, 18 say "Passenger" get mPassenger pict "@!"
   @ row()+2, 14 say "    Route" get mRoute1 pict "@!"
   @ row(),   55 say "               "
   @ row()+1, 14 say "         " get mRoute2 pict "@!"

   @ 11, 26 say "                Amount"
   @ row()+1, 26 say "    Transmittal"
   @ row()+1, 26 say "Commission Rate"
   @ row()+1, 26 say "     Remittance"
   @ row()+1, 26 say "            Tax"
   @ row()+1, 26 say " Commission Due"

   @ 11, 1 say ""
   @ row()+1, 42      get mTrans_p pict NUM_PIC2
   @ row()+1, 46      get mCrate_p pict "99.99"
   @ row()+1, 42      get mRemit_p pict NUM_PIC2 when Comp_RemP()
   @ row()+1, 42      get mTax_p pict NUM_PIC2
   @ row()+1, 42      get mACM_p pict NUM_PIC2
   if nMode!=VIEW_MODE
      SetCursor(SC_NORMAL)
      read
   else
      clear gets
   endif
   SetCursor(SC_NONE)
return nil


static function InitVariables(nMode)
    if nMode!=APPEND_MODE
       mFdate:=DATE
       mPassenger:=PASSENGER
       mTicketNo:=TICKET_NO
       mRoute1:=ROUTE_1
       mRoute2:=ROUTE_2
       mTrans_p:=TRANSMIT_P
       mCrate_p:=CRATE_P
       mRemit_p:=REMIT_P
       mTax_p:=TAX_P
       mACM_p:=ACM_P
    else
       mFdate:=ctod("")
       mPassenger:=space(35)
       mTicketNo:=space(18)
       mRoute1:=space(26)
       mRoute2:=space(26)
       mTrans_p:=0.00
       mCrate_p:=0.00
       mRemit_p:=0.00
       mTax_p:=0.00
       mACM_p:=0.00
    endif
return nil

static function SaveVariables(nMode)
   Message("Saving entries...")
   FilLock(0)
   if nMode==APPEND_MODE
     AddRec(0)
   endif
   replace DATE with mFdate
   replace PASSENGER with mPassenger
   replace TICKET_NO with mTicketNo
   replace ROUTE_1 with mRoute1
   replace ROUTE_2 with mRoute2
   replace TRANSMIT_P with mTrans_p
   replace CRATE_P with mCrate_p
   replace REMIT_P with mRemit_p
   replace TAX_P with mTax_p
   replace ACM_P with mACM_p
   DbUnlock()
   commit
return nil


static function SearchPax()
local nRecNo,wSearch,cName:=Space(40)
   nRecNo:=RecNo()
   wSearch:=OpenWindow(08,18,12,61,"Search Mode")
   @ 10,20 say "Enter name to search"
   @ 11,20 get cName picture "@!"
   SetCursor(SC_NORMAL)
   read
   cName:=Alltrim(cName)
   CloseWindow(wSearch)
   SetCursor(SC_NONE)
   if LastKey()!=K_ESC
      DbSetOrder(PAX_NDX)
      DbSeek(AllTrim(cName))
      nKey:=0
      if Found()
         do while (cName==substr(upper(PASSENGER),1,len(cName))) .and. (nKey!=K_ESC)
            BSP_Page1(VIEW_MODE)
            Message("Press ENTER to continue search, ESC to abort....")
            nKey:=0
            do while (nkey!=K_ENTER) .and. (nKey!=K_ESC)
               nKey:=Inkey(0)
            enddo
            if nKey==K_ENTER ; DbSkip() ; endif
        enddo
      else
         Tone(100,3)
         Message("Name not found....")
         DbGoTo(nRecNo)
         Inkey(2)
      endif
      DbSetOrder(TKT_NDX)
   endif
return nil

static function SearchTkt()
local nRecNo,wSearch,cTicket:=Space(40)
   nRecNo:=RecNo()
   wSearch:=OpenWindow(08,18,12,61,"Search Mode")
   @ 10,20 say "Enter Series No. to search"
   @ 11,20 get cTicket picture "@!"
   SetCursor(SC_NORMAL)
   read
   cTicket:=Alltrim(cTicket)
   CloseWindow(wSearch)
   SetCursor(SC_NONE)
   if LastKey()!=K_ESC
      DbSetOrder(TKT_NDX)
      DbSeek(AllTrim(cTicket))
      nKey:=0
      if Found()
         do while (cTicket==substr(upper(TICKET_NO),1,len(cTicket))) .and.;
            (nKey!=K_ESC)
            BSP_Page1(VIEW_MODE)
            Message("Press ENTER to continue search, ESC to abort....")
            nKey:=0
            do while (nkey!=K_ENTER) .and. (nKey!=K_ESC)
               nKey:=Inkey(0)
            enddo
            if nKey==K_ENTER ; DbSkip() ; endif
        enddo
      else
         Tone(100,3)
         Message("Ticket No. not found....")
         DbGoTo(nRecNo)
         Inkey(2)
      endif
      DbSetOrder(TKT_NDX)
   endif
return nil

static function Comp_RemP()
   mRemit_p := mTrans_p - (mTrans_p * (mCRate_p / 100 ))
return .t.

static function more_keys()
local  wMore
   wMore:=OpenWindow(06,40,21,77,"Help Window")
   @ 07, 42 say ""
   @ row()+1, 42 say "F1 - Help Screen"
   @ row()+1, 42 say "F2 - Add a New Record to File"
   @ row()+1, 42 say "F3 - Edit Displayed Record"
   @ row()+1, 42 say "F4 - Delete Displayed Record"
   @ row()+1, 42 say "F5 - Search File by Pax Name"
   @ row()+1, 42 say "F6 - Search File by Ticket"
   @ row()+1, 42 say "F7 - Print Reports"
   @ row()+1, 42 say "F8 - Insert a New Record"
   @ row()+1, 42 say "F9 - Reindex Database"
   @ row()+1, 42 say "PgDn/PgUp - Move from Pages"
   @ row()+1, 42 say "Up/Down - Previous/Next Record"
   @ row()+1, 42 say "Ctrl-[Up/Down] - Jump 20 Records"
   @ row()+1, 42 say "ESC - Go Back to Main Menu"
   inkey(0)
   CLoseWindow(wMore)
return nil

static function Totals()
   nRecno := UNBDOM->(RecNo())
   wTotals := OpenWindow(07,05,20,65,"Total Window")
   dStartDate := dEndDate := ctod("")
   cAirCode := "   "
   @ 09, 12 say "Starting Date"   get dStartDate
   @ 10, 12 say "  Ending Date"   get dEndDate
   @ 09, 40 say "Airline Code"    get cAirCode pict "999"
   @ 12, 38 say "Peso"
   @ 12, 53 say "Dollar"
   @ row()+1, 12 say "Transmittal Totals"
   @ row()+1, 12 say " Commission Totals"
   @ row()+1, 12 say " Remittance Totals"
   @ row()+1, 12 say "        Tax Totals"
   @ row()+1, 12 say "        ACM Totals"
   @ row()+1, 12 say "  Fare Diff Totals"
   SetCursor(SC_NORMAL)
   read
   SetCursor(SC_NONE)
   if LastKey() # K_ESC
      aTotals := afill(array(14),0)
      UNBDOM->(DbSetOrder(DATE_NDX))
      lseek := Set(_SET_SOFTSEEK,.T.)
      UNBDOM->(DbSeek(dStartDate))
      Message("Thinking...")
      do while UNBDOM->Date <= dEndDate .and. UNBDOM->(!Eof())
         if empty(cAirCode) .or. ;
            substr(UNBDOM->Ticket_No,1,3) == cAircode
            aTotals[ 3] += UNBDOM->TRANSMIT_P
            aTotals[ 5] += UNBDOM->CRATE_P
            aTotals[ 7] += UNBDOM->REMIT_P
            aTotals[ 9] += UNBDOM->TAX_P
            aTotals[11] += UNBDOM->ACM_P
         endif
         UNBDOM->(DbSkip())
      enddo
      Set(_SET_SOFTSEEK,lseek)
      UNBDOM->(DbSetOrder(TKT_NDX))
      @ 12, 12 say ""
      @ row()+1, 35 get aTotals[ 3] pict "9,999,999.99"
      @ row()+1, 35 get aTotals[ 5] pict "9,999,999.99"
      @ row()+1, 35 get aTotals[ 7] pict "9,999,999.99"
      @ row()+1, 35 get aTotals[ 9] pict "9,999,999.99"
      @ row()+1, 35 get aTotals[11] pict "9,999,999.99"
      clear gets
      Message("Press a key to continue...")
      inkey(0)
   endif
   CloseWindow(wTotals)
   UNBDOM->(DbGoto(nRecno))
return nil


// <EOF> - TICKETS.PRG //
