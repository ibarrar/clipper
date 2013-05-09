// Filename:      TICKETS.PRG
// System-Name:   Philippine Airline Domestic Tickets System
// Module:        File Handling Module
// Author:        Rolando C. Ibarra
// Date-Started:  Nov.07,1993
// Last-Update:   Nov.10,1993

#include "Inkey.ch"
#include "Setcurs.ch"
#include "Mode.Ch"
#include "Cl501_60.ch"
#include "BSP.Ch"

#define PAGE1_BAR   "F1-Help  F2-Add  F3-Edit  F4-Del/Undel  F5-Name  F6-Tkt  F8-Total  PgDn-Next"
#define PAGE2_BAR   "PgUp-Prev Page   PgDn-Next Page"
#define PAGE3_BAR   "PgUp-Prev Page"

static mFdate, mPassenger, mTicketNo, mRoute1, mRoute2, mPax_Type
static mSales,mCrate,mDue,mASF,mTerm_Fee,mMisc,mComm_Due,;
       mExc_Tkt,mRemarks1,mRemarks2,mRemarks3
static mBl_1date,mBl_1no,mBl_1amtp,;
       mBl_2date,mBl_2no,mBl_2amtp,;
       mOR_1date,mOR_1no,mOR_1amtp,;
       mOR_2date,mOR_2no,mOR_2amtp,;
       mDate_1last,mRA_1no,mRN_1no,mACM_1no,mAmt_1p,;
       mDate_2last,mRA_2no,mRN_2no,mACM_2no,mAmt_2p

function Do_Dom()
local  nKey:=0 ,wDom
public cTitle
   do case
      case cDbf == "MCO"       ;   cTitle = "Misc. Charge Order"
      case cDbf == "SERIES1"   ;   cTitle = "Series 1 Tickets"
      case cDbf == "SERIES2"   ;   cTitle = "Series 2 Tickets"
      case cDbf == "SERIES4"   ;   cTitle = "Series 4 Tickets"
   endcase
   (cDbf)->(DbGotop())
   wDom := OpenWindow(03,10,19,69,cTitle)
    if (cDbf)->(RecCount())==0 ; Dom_Page1(APPEND_MODE)
       if LastKey()!=K_ESC
          (cDbf)->(SaveVariables(APPEND_MODE))
       endif
    endif
   if LastKey()!=K_ESC
      do while (nKey!=K_ESC)
         DOM_Page1(VIEW_MODE)
         nKey:=inKey(0)
         do case
            case nKey==K_DOWN
               (cDbf)->(DbSkip())
               if (cDbf)->(Eof())
                  (cDbf)->(DbGoBottom())
                  Tone(200,1)
                  Message("End of file reached....")
                  Inkey(1)
               endif
            case nKey==K_UP
               (cDbf)->(DbSkip(-1))
               if (cDbf)->(Bof())
                  (cDbf)->(DbGoTop())
                  Tone(200,1)
                  Message("Beginning of file reached....")
                  Inkey(1)
               endif
            case nKey==K_CTRL_PGDN
               (cDbf)->(DbSkip(NUM_TO_SKIP))
               if (cDbf)->(Eof())
                  (cDbf)->(DbGoBottom())
                  Tone(200,1)
                  Message("End of file reached....")
                  Inkey(1)
               endif
            case nKey==K_CTRL_PGUP
               (cDbf)->(DbSkip(-NUM_TO_SKIP))
               if (cDbf)->(Bof())
                  (cDbf)->(DbGoTop())
                  Tone(200,1)
                  Message("Beginning of file reached....")
                  Inkey(1)
               endif
            case nKey==K_END
                (cDbf)->(DbGoBottom())
                Message("Moving to end of file....")
                Inkey(1)
            case nKey==K_HOME
                (cDbf)->(DbGoTop())
                Message("Moving to beginning of file....")
                Inkey(1)
            case nKey==K_PGDN
                DOM_Page2(VIEW_MODE)
            case nKey==K_F1
               more_keys()
            case nKey==K_F2
                Message("Press ENTER to Add, ESC to abort.")
                if Inkey(0)==K_ENTER
                   DOM_Page1(APPEND_MODE)
                   if LastKey()!=K_ESC   ;   (cDbf)->(SaveVariables(APPEND_MODE))   ;   endif
                endif
            case nKey==K_F3
                Message("Press ENTER to Edit, ESC to abort.")
                if Inkey(0)==K_ENTER
                   DOM_Page1(EDIT_MODE)
                   if LastKey()!=K_ESC   ;   (cDbf)->(SaveVariables(EDIT_MODE))   ;   endif
                endif
            case nKey==K_F4
                Message("Press ENTER to Delete/Undelete, ESC to abort.")
                if Inkey(0)==K_ENTER
                    (cDbf)->(Fillock())
                    if (cDbf)->(Deleted())
                      (cDbf)->(DbRecall())
                    else
                      (cDbf)->(DbDelete())
                    endif
                    (cDbf)->(DbUnlock())
                endif
            case nKey==K_F5
                (cDbf)->(SearchPax())
            case nKey==K_F6
                (cDbf)->(SearchTkt())
            case nKey==K_F8
                (cDbf)->(Totals())
            case nKey==K_F9
                Message("Press ENTER to Reindex, ESC to abort.")
                if Inkey(0)==K_ENTER
                  Message("Reindexing, please wait....")
                  (cDbf)->(FilLock(0))
                  (cDbf)->(DbReindex())
                  (cDbf)->(DbUnlock())
                endif
            endcase
      enddo
   endif
   CloseWindow(wDOM)
return nil

static function DOM_Page1(nMode)
local nKey
   (cDbf)->(InitVariables(nMode))
   Message(PAGE1_BAR)
   Tone(300,1)
   cColor:=SetColor("N/BG")
   if (cDbf)->(Deleted()) ; @ 03,35 say "<deleted>"
   else ; @ 03,35 say "         " ; endif
   @ 03,55 say "Rec# " + ;
   Transform(If(nMode==APPEND_MODE,(cDbf)->(LastRec())+1,(cDbf)->(RecNo())),"9999")+;
   "/"+Transform((cDbf)->(LastRec()),"@B 9999")
   SetColor(cColor)
   @ 05,      18      say "Date" get mFdate
   @ row(),   36 say "Ticket#" get mTicketNo when put079()
   @ row()+2, 13 say "Passenger" get mPassenger pict "@!"
   @ row()+2, 14 say "    Route" get mRoute1 pict "@!"
   @ row()+1, 14 say "         " get mRoute2 pict "@!"
   @ row()-1, 53 say "Pax Type" get mPax_Type pict "@!" valid (mPax_Type $ "ACI-")

   @ 12, 13 say      "                Amount     Exchange Ticket#"
   @ row()+1, 13 say "    Transmittal"
   @ row()+1, 13 say "Commission Rate"
   @ row(), col()+12 say "Commission Due"
   @ row()+1, 13 say "            ASF"
   @ row()+1, 13 say "   Terminal Fee"
   @ row(), col()+12 say "Remarks "
   @ row()+1, 13 say "     Remittance"
   @ row()+1, 13 say "    Misc. Coll."

   @ 12, 1 say ""
   @ row()+1, 29      get mSales pict NUM_PIC2
   @ row()+1, 33      get mCrate pict "99.99"
   @ row()+1, 29      get mASF pict NUM_PIC2  when forceASF()
   @ row()+1, 29      get mTerm_Fee pict NUM_PIC2
   @ row()+1, 29      get mDue pict NUM_PIC2  when Comp_Due()
   @ row()+1, 29      get mMisc pict NUM_PIC2

   @ 13,      40  get mExc_Tkt
   @ row()+2, 40  get mComm_Due pict NUM_PIC2
   @ row()+2, 40  get mRemarks1 pict "@S20"
   @ row()+1, 40  get mRemarks2 pict "@S20"

   if nMode!=VIEW_MODE
      SetCursor(SC_NORMAL)
      read
      if Lastkey()==K_PGDN
         DOM_Page2(nMode)
      endif
   else
      clear gets
   endif
   SetCursor(SC_NONE)
return nil

static function InitVariables(nMode)
    if nMode!=APPEND_MODE
       mFdate:=DATE
       mPax_Type:=PAX_TYPE
       mPassenger:=PASSENGER
       mTicketNo:=TICKET_NO
       mRoute1:=ROUTE_1
       mRoute2:=ROUTE_2
       mSales:=SALES
       mCrate:=CRATE
       mComm_Due:=COMM
       mDue:=DUE
       mASF:=ASF
       mTerm_Fee:=TERM_FEE
       mMisc:=MISC
       mExc_Tkt:=EXC_TKT
       mRemarks1:=REMARKS1
       mRemarks2:=REMARKS2
       mBl_1date:=BILL_1DATE
       mBl_1no:=BILL_1NO
       mBl_1amtp:=BILL_1AMTP
       mBl_2date:=BILL_2DATE
       mBl_2no:=BILL_2NO
       mBl_2amtp:=BILL_2AMTP
       mOR_1date:=OR_1DATE
       mOR_1no:=OR_1NO
       mOR_1amtp:=OR_1AMTP
       mOR_2date:=OR_2DATE
       mOR_2no:=OR_2NO
       mOR_2amtp:=OR_2AMTP
       mDate_1last:=DATE_1LAST
       mRA_1no:=RA_1NO
       mRN_1no:=RN_1NO
       mACM_1no:=ACM_1NO
       mAmt_1p:=AMT_1P
       mDate_2last:=DATE_2LAST
       mRA_2no:=RA_2NO
       mRN_2no:=RN_2NO
       mACM_2no:=ACM_2NO
       mAmt_2p:=AMT_2P
    else
       if empty(mFdate); mFdate:=date() ; endif
       mPax_Type:="A"
       mPassenger:=space(40)
       mTicketNo:=space(if(cDbf=="MCO",19,18))
       mRoute1:=space(26)
       mRoute2:=space(26)
       mSales:=0.00
       mCrate:=2.5
       mComm_Due:=0.00
       mDue:=0.00
       do case
         case (cDbf) == "SERIES1"
           mASF := 03.00
         case (cDbf) == "SERIES2"
           mASF := 06.00
         case (cDbf) == "SERIES4"
           mASF := 12.00
         otherwise
           mASF := 0.00
       endcase
       if empty(mTerm_Fee); mTerm_fee:=0.00 ; endif
       mMisc:=0.00
       mExc_Tkt:=space(19)
       mRemarks1:=space(30)
       mRemarks2:=space(30)
       mBl_1date:=ctod("")
       mBl_1no:=space(8)
       mBl_1amtp:=0.00
       mBl_2date:=ctod("")
       mBl_2no:=space(8)
       mBl_2amtp:=0.00
       mOR_1date:=ctod("")
       mOR_1no:=space(8)
       mOR_1amtp:=0.00
       mOR_2date:=ctod("")
       mOR_2no:=space(8)
       mOR_2amtp:=0.00
       mDate_1last:=ctod("")
       mRA_1no:=space(8)
       mRN_1no:=space(8)
       mACM_1no:=space(8)
       mAmt_1p:=0.00
       mDate_2last:=ctod("")
       mRA_2no:=space(8)
       mRN_2no:=space(8)
       mACM_2no:=space(8)
       mAmt_2p:=0.00
    endif
return nil

static function SaveVariables(nMode)
   Message("Saving entries...")
   FilLock(0)
   if nMode==APPEND_MODE
     AddRec(0)
   endif
   replace DATE with mFdate
   replace PAX_TYPE with mPax_Type
   replace PASSENGER with mPassenger
   replace TICKET_NO with mTicketNo
   replace ROUTE_1 with mRoute1
   replace ROUTE_2 with mRoute2
   replace SALES with mSales
   replace CRATE with mCrate
   replace COMM with mComm_Due
   replace DUE with mDue
   replace ASF with mASF
   replace TERM_FEE with mTerm_Fee
   replace MISC with mMisc
*   replace MISC_RMRK with mMisc_Rmrk
   replace EXC_TKT with mExc_Tkt
   replace REMARKS1 with mRemarks1
   replace REMARKS2 with mRemarks2
*   replace REMARKS3 with mRemarks3
   replace BILL_1DATE with mBl_1date
   replace BILL_1NO with mBl_1no
   replace BILL_1AMTP with mBl_1amtp
   replace BILL_2DATE with mBl_2date
   replace BILL_2NO with mBl_2no
   replace BILL_2AMTP with mBl_2amtp
   replace OR_1DATE with mOR_1date
   replace OR_1NO with mOR_1no
   replace OR_1AMTP with mOR_1amtp
   replace OR_2DATE with mOR_2date
   replace OR_2NO with mOR_2no
   replace OR_2AMTP with mOR_2amtp
   replace DATE_1LAST with mDate_1last
   replace RA_1NO with mRA_1no
   replace RN_1NO with mRN_1no
   replace ACM_1NO with mACM_1no
   replace AMT_1P with mAmt_1p
   replace DATE_2LAST with mDate_2last
   replace RA_2NO with mRA_2no
   replace RN_2NO with mRN_2no
   replace ACM_2NO with mACM_2no
   replace AMT_2P with mAmt_2p
   DbUnlock()
   commit
return nil

static function DOM_Page2(nMode)
local wDOM2, nSrow := 12, nKey
   Tone(300,1)
   Message(PAGE3_BAR)
   wDOM2 := OpenWindow(11,10,21,69,"Page 2")
   @ nSrow,   15 say "                  Date      Number    Amount"
   @ row()+1, 13 say "Billings:"
   @ row()+2, 13 say "Official Receipts: "
   @ row()+3, 15 say " Date       RA#        RN#        ACM#       Amount"

   @ nSrow+1, 33 get mBl_1date pict "@!"
   @ row()  , col()+2 get mBl_1no pict "@!"
   @ row()  , col()+2 get mBl_1amtp pict NUM_PIC2
   @ row()+1, 33 get mBl_2date pict "@!"
   @ row()  , col()+2 get mBl_2no pict "@!"
   @ row()  , col()+2 get mBl_2amtp pict NUM_PIC2
   @ row()+1, 33 get mOR_1date pict "@!"
   @ row()  , col()+2 get mOR_1no pict "@!"
   @ row()  , col()+2 get mOR_1amtp pict NUM_PIC2
   @ row()+1, 33 get mOR_2date pict "@!"
   @ row()  , col()+2 get mOR_2no pict "@!"
   @ row()  , col()+2 get mOR_2amtp pict NUM_PIC2

   @ row()+3, 13 get mDate_1last pict "@!"
   @ row()  , col()+3 get mRA_1no pict "@!"
   @ row()  , col()+3 get mRN_1no pict "@!"
   @ row()  , col()+3 get mACM_1no pict "@!"
   @ row()  , col()+3 get mAmt_1p pict NUM_PIC2
   @ row()+1, 13 get mDate_2last pict "@!"
   @ row()  , col()+3 get mRA_2no pict "@!"
   @ row()  , col()+3 get mRN_2no pict "@!"
   @ row()  , col()+3 get mACM_2no pict "@!"
   @ row()  , col()+3 get mAmt_2p pict NUM_PIC2
   if nMode!=VIEW_MODE
      SetCursor(SC_NORMAL)
      read
   else
      clear gets
      do while (nKey!=K_ESC) .and. (nKey!=K_PGUP)
         nKey:=inkey(0)
      enddo
   endif
   SetCursor(SC_NONE)
   CloseWindow(wDOM2)
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
            DOM_Page1(VIEW_MODE)
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
            DOM_Page1(VIEW_MODE)
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

static function Comp_Due()
mComm_due := mSales * (mCrate/100)
mDue := ((mSales - mComm_Due) + (mASF + mTerm_Fee))
return .t.

static function forceASF()
if "VOID" $ upper(mRoute1)
 mASF:= 0.00
endif
return .t.

static function Put079()
if empty(mTicketNo)
keyboard chr(48)+chr(55)+chr(57)+chr(45)
endif
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
   nRecno := (cDbf)->(RecNo())
   wTotals := OpenWindow(06,19,18,59,"Total Window")
   dStartDate := dEndDate := ctod("")
   @ 08, 28 say "Starting Date"   get dStartDate
   @ 09, 28 say "  Ending Date"   get dEndDate
   @ row()+3, 21 say "      Sales Totals"
   @ row()+1, 21 say " Commission Totals"
   @ row()+1, 21 say "  Sales Due Totals"
   @ row()+1, 21 say "        Tax Totals"
   @ row()+1, 21 say "Misc. Coll. Totals"
   SetCursor(SC_NORMAL)
   read
   SetCursor(SC_NONE)
   if LastKey() # K_ESC
      aTotals := afill(array(05),0)
      (cDbf)->(DbSetOrder(DATE_NDX))
      lseek := Set(_SET_SOFTSEEK,.T.)
      (cDbf)->(DbSeek(dStartDate))
      Message("Thinking...")
      do while (cDbf)->Date <= dEndDate .and. (cDbf)->(!Eof())
            aTotals[1] += (cDbf)->SALES
            aTotals[2] += (cDbf)->COMM
            aTotals[3] += (cDbf)->DUE
            aTotals[4] += (cDbf)->ASF + (cDbf)->TERM_FEE
            aTotals[5] += (cDbf)->MISC
         (cDbf)->(DbSkip())
      enddo
      Set(_SET_SOFTSEEK,lseek)
      (cDbf)->(DbSetOrder(TKT_NDX))
      @      12, 44 get aTotals[1] pict "9,999,999.99"
      @ row()+1, 44 get aTotals[2] pict "9,999,999.99"
      @ row()+1, 44 get aTotals[3] pict "9,999,999.99"
      @ row()+1, 44 get aTotals[4] pict "9,999,999.99"
      @ row()+1, 44 get aTotals[5] pict "9,999,999.99"
      clear gets
      Message("Press a key to continue...")
      inkey(0)
   endif
   CloseWindow(wTotals)
   (cDbf)->(DbGoto(nRecno))
return nil


// <EOF> - TICKETS.PRG //
