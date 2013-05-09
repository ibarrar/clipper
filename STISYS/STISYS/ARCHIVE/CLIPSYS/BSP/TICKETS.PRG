// Filename:      TICKETS.PRG
// System-Name:   Bank Settlement Plan System
// Module:        File Handling Module
// Author:        Rollie C. Ibarra
// Date-Started:  August 17, 1993
// Last-Update:   August 27, 1993

#include "Inkey.ch"
#include "Setcurs.ch"
#include "Mode.Ch"
#include "C501_MOD.ch"
#include "BSP.Ch"

#define PAGE1_BAR   "F1-Help  F2-Add  F3-Edit  F4-Dele  F5-Name  F6-Tkt F7-Print F8-Total PgDn-Next"
#define PAGE2_BAR   "PgUp-Prev Page   PgDn-Next Page"
#define PAGE3_BAR   "PgUp-Prev Page"

static mFdate, mPassenger, mTicketNo, mRoute1, mRoute2, mAmount
static mAirfare_p,mAirFare_d,mAir_Rmrk,mTrans_p,mTrans_d,mTrans_Rmrk,;
       mCrate_p,mCrate_d,mCrate_Rmrk,mRemit_p,mRemit_d,mRemit_Rmrk,;
       mTax_p,mTax_d,mTax_Rmrk,mACM_p,mACM_d,mDif_P,mDif_D
static mBl_1date,mBl_1no,mBl_1amtp,mBl_1amtd,;
       mBl_2date,mBl_2no,mBl_2amtp,mBl_2amtd,;
       mOR_1date,mOR_1no,mOR_1amtp,mOR_1amtd,;
       mOR_2date,mOR_2no,mOR_2amtp,mOR_2amtd,;
       mDate_1last,mRA_1no,mRN_1no,mACM_1no,mAmt_1p,mAmt_1d,;
       mDate_2last,mRA_2no,mRN_2no,mACM_2no,mAmt_2p,mAmt_2d

function Do_Bsp()
local  nKey:=0 ,wBSP
public cTitle
   do case
      case cDbf == "MCO"       ;   cTitle = "Misc. Charge Order"
      case cDbf == "SERIES2"   ;   cTitle = "Series 2 Tickets"
      case cDbf == "SERIES4"   ;   cTitle = "Series 4 Tickets"
      case cDbf == "APOLLO"    ;   cTitle = "Optat Apollo"
      case cDbf == "ABACUS"    ;   cTitle = "Optat Abacus"
   endcase
   (cDbf)->(DbGotop())
   wBSP := OpenWindow(03,10,if(cDbf!="MCO",18,19),69,cTitle)
    if (cDbf)->(RecCount())==0 ; BSP_Page1(APPEND_MODE) ; endif
   if LastKey()!=K_ESC
      do while (nKey!=K_ESC)
         BSP_Page1(VIEW_MODE)
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
                Bsp_Page2(VIEW_MODE)
            case nKey==K_F1
               more_keys()
            case nKey==K_F2
                Message("Press ENTER to Add, ESC to abort.")
                if Inkey(0)==K_ENTER
                   Bsp_Page1(APPEND_MODE)
                   if LastKey()!=K_ESC   ;   (cDbf)->(SaveVariables(APPEND_MODE))   ;   endif
                endif
            case nKey==K_F3
                Message("Press ENTER to Edit, ESC to abort.")
                if Inkey(0)==K_ENTER
                   Bsp_Page1(EDIT_MODE)
                   if LastKey()!=K_ESC   ;   (cDbf)->(SaveVariables(EDIT_MODE))   ;   endif
                endif
            case nKey==K_F4
                Message("Press ENTER to Delete, ESC to abort.")
                if Inkey(0)==K_ENTER
                    (cDbf)->(Fillock())
                    (cDbf)->(DbDelete())
                    (cDbf)->(DbUnlock())
                endif
            case nKey==K_F5
                (cDbf)->(SearchPax())
            case nKey==K_F6
                (cDbf)->(SearchTkt())
            case nKey==K_F7
                (cDbf)->(Reports())
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
   CloseWindow(wBSP)
return nil

static function BSP_Page1(nMode)
local nKey
   (cDbf)->(InitVariables(nMode))
   Message(PAGE1_BAR)
   Tone(300,1)
   cColor:=SetColor("N/BG")
   if (cDbf)->(Deleted()) ; @ 03,35 say "<deleted>"
   else ; @ 03,35 say "         " ; endif
   @ 03,55 say "Rec# " + ;
   Transform(If(nMode==APPEND_MODE,(cDbf)->(LastRec())+1,(cDbf)->(RecNo())),"9999")+;
   "/"+Transform((cDbf)->(LastRec()),"9999")
   SetColor(cColor)
   @ 05,      18      say "Date" get mFdate  valid getrate(mFdate)
   @ row(), col()+6 say "Ticket#" get mTicketNo
   @ row()+2, 18 say "Passenger" get mPassenger pict "@!"
   @ row()+2, 14 say "    Route" get mRoute1 pict "@!"
   @ row(),   55 say "               "
   @ row()+1, 14 say "         " get mRoute2 pict "@!"

   @ 11, 11 say "                Peso       Dollar     Remark"
   if (cDbf == "MCO")   ;   @ row()+1, 11 say "        Airfare"   ;   endif
   @ row()+1, 11 say "    Transmittal"
   @ row()+1, 11 say "Commission Rate"
   @ row()+1, 11 say "     Remittance"
   @ row()+1, 11 say "            Tax"
   @ row()+1, 11 say " Commission Due"
   @ row()+1, 11 say "      Fare Diff"

   @ 11, 1 say ""
   if (cDbf == "MCO")
      @ row()+1, 27 get mAirFare_p pict NUM_PIC2
      @ row(),   col()+2 get mAirFare_d pict NUM_PIC2
      @ row(),   col()+2 get mAir_Rmrk pict "@S20"
   endif
   @ row()+1, 27      get mTrans_p pict NUM_PIC2
   @ row(),   col()+2 get mTrans_d pict NUM_PIC2
   @ row(),   col()+2 get mTrans_Rmrk pict "@S20"
   @ row()+1, 33      get mCrate_p pict "999"
   @ row(),   col()+8 get mCrate_d pict "999"
   @ row(),   col()+2 get mCrate_Rmrk pict "@S20"
   @ row()+1, 27      get mRemit_p pict NUM_PIC2 when Comp_RemP()
   @ row(),   col()+2 get mRemit_d pict NUM_PIC2 when Comp_RemD()
   @ row(),   col()+2 get mRemit_Rmrk pict "@S20"
   @ row()+1, 27      get mTax_p pict NUM_PIC2
   @ row(),   col()+2 get mTax_d pict NUM_PIC2
   @ row(),   col()+2 get mTax_Rmrk pict "@S20"
   @ row()+1, 27      get mACM_p pict NUM_PIC2
   @ row(),   col()+2 get mACM_d pict NUM_PIC2
   @ row()+1, 27      get mDif_P pict  NUM_PIC2
   @ row(),   col()+2 get mDif_D pict NUM_PIC2
   if nMode!=VIEW_MODE
      SetCursor(SC_NORMAL)
      read
      if Lastkey()==K_PGDN
         Bsp_Page2(nMode)
      endif
   else
      clear gets
   endif
   SetCursor(SC_NONE)
return nil

function getrate(x)
static found
 found := .t.
 ACR->(DbGoBottom())
 @ 09,55 say "Thinking..."
 do while  x < ACR->(DATEFROM) .and. ACR->(!BOF())
  ACR->(DbSkip(-1))
 enddo
 if ACR->(!BOF()) .and. x <= ACR->(DATETO)
 mAmount:=ACR->(AMOUNT)
 else
   found := .f.
   mAmount:=000000
 endif
 @ 09,55 say "Rate "
 @ 09,60 get mAmount pict "999.99" when .f.
return found


static function InitVariables(nMode)
    if nMode!=APPEND_MODE
       mFdate:=DATE
       mPassenger:=PASSENGER
       mTicketNo:=TICKET_NO
       mRoute1:=ROUTE_1
       mRoute2:=ROUTE_2
       mAirfare_p:=AIRFARE_P
       mAirFare_d:=AIRFARE_D
       mAir_Rmrk:=AIR_RMRK
       mTrans_p:=TRANSMIT_P
       mTrans_d:=TRANSMIT_D
       mTrans_Rmrk:=TRANS_RMRK
       mCrate_p:=CRATE_P
       mCrate_d:=CRATE_D
       mCrate_Rmrk:=CRATE_RMRK
       mRemit_p:=REMIT_P
       mRemit_d:=REMIT_D
       mRemit_Rmrk:=REMIT_RMRK
       mTax_p:=TAX_P
       mTax_d:=TAX_D
       mTax_Rmrk:=TAX_RMRK
       mACM_p:=ACM_P
       mACM_d:=ACM_D
       mDif_P:=DIFF_P
       mDif_D:=DIFF_D
       mBl_1date:=BILL_1DATE
       mBl_1no:=BILL_1NO
       mBl_1amtp:=BILL_1AMTP
       mBl_1amtd:=BILL_1AMTD
       mBl_2date:=BILL_2DATE
       mBl_2no:=BILL_2NO
       mBl_2amtp:=BILL_2AMTP
       mBl_2amtd:=BILL_2AMTD
       mOR_1date:=OR_1DATE
       mOR_1no:=OR_1NO
       mOR_1amtp:=OR_1AMTP
       mOR_1amtd:=OR_1AMTD
       mOR_2date:=OR_2DATE
       mOR_2no:=OR_2NO
       mOR_2amtp:=OR_2AMTP
       mOR_2amtd:=OR_2AMTD
       mDate_1last:=DATE_1LAST
       mRA_1no:=RA_1NO
       mRN_1no:=RN_1NO
       mACM_1no:=ACM_1NO
       mAmt_1p:=AMT_1P
       mAmt_1d:=AMT_1D
       mDate_2last:=DATE_2LAST
       mRA_2no:=RA_2NO
       mRN_2no:=RN_2NO
       mACM_2no:=ACM_2NO
       mAmt_2p:=AMT_2P
       mAmt_2d:=AMT_2D
    else
       mFdate:=ctod("")
       mPassenger:=space(35)
       mTicketNo:=space(if(cDbf=="MCO",19,18))
       mRoute1:=space(26)
       mRoute2:=space(26)
       mAirfare_p:=0.00
       mAirFare_d:=0.00
       mAir_Rmrk:=space(30)
       mTrans_p:=0.00
       mTrans_d:=0.00
       mTrans_Rmrk:=space(30)
       mCrate_p:=0.00
       mCrate_d:=0.00
       mCrate_Rmrk:=space(30)
       mRemit_p:=0.00
       mRemit_d:=0.00
       mRemit_Rmrk:=space(30)
       mTax_p:=0.00
       mTax_d:=0.00
       mTax_Rmrk:=space(30)
       mACM_p:=0.00
       mACM_d:=0.00
       mDif_P:=0.00
       mDif_D:=0.00
       mBl_1date:=ctod("")
       mBl_1no:=space(8)
       mBl_1amtp:=0.00
       mBl_1amtd:=0.00
       mBl_2date:=ctod("")
       mBl_2no:=space(8)
       mBl_2amtp:=0.00
       mBl_2amtd:=0.00
       mOR_1date:=ctod("")
       mOR_1no:=space(8)
       mOR_1amtp:=0.00
       mOR_1amtd:=0.00
       mOR_2date:=ctod("")
       mOR_2no:=space(8)
       mOR_2amtp:=0.00
       mOR_2amtd:=0.00
       mDate_1last:=ctod("")
       mRA_1no:=space(8)
       mRN_1no:=space(8)
       mACM_1no:=space(8)
       mAmt_1p:=0.00
       mAmt_1d:=0.00
       mDate_2last:=ctod("")
       mRA_2no:=space(8)
       mRN_2no:=space(8)
       mACM_2no:=space(8)
       mAmt_2p:=0.00
       mAmt_2d:=0.00
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
   replace AIRFARE_P with mAirfare_p
   replace AIRFARE_D with mAirFare_d
   replace AIR_RMRK with mAir_Rmrk
   replace TRANSMIT_P with mTrans_p
   replace TRANSMIT_D with mTrans_d
   replace TRANS_RMRK with mTrans_Rmrk
   replace CRATE_P with mCrate_p
   replace CRATE_D with mCrate_d
   replace CRATE_RMRK with mCrate_Rmrk
   replace REMIT_P with mRemit_p
   replace REMIT_D with mRemit_d
   replace REMIT_RMRK with mRemit_Rmrk
   replace TAX_P with mTax_p
   replace TAX_D with mTax_d
   replace TAX_RMRK with mTax_Rmrk
   replace ACM_P with mACM_p
   replace ACM_D with mACM_d
   replace DIFF_P with mDif_P
   replace DIFF_D with mDif_D
   replace BILL_1DATE with mBl_1date
   replace BILL_1NO with mBl_1no
   replace BILL_1AMTP with mBl_1amtp
   replace BILL_1AMTD with mBl_1amtd
   replace BILL_2DATE with mBl_2date
   replace BILL_2NO with mBl_2no
   replace BILL_2AMTP with mBl_2amtp
   replace BILL_2AMTD with mBl_2amtd
   replace OR_1DATE with mOR_1date
   replace OR_1NO with mOR_1no
   replace OR_1AMTP with mOR_1amtp
   replace OR_1AMTD with mOR_1amtd
   replace OR_2DATE with mOR_2date
   replace OR_2NO with mOR_2no
   replace OR_2AMTP with mOR_2amtp
   replace OR_2AMTD with mOR_2amtd
   replace DATE_1LAST with mDate_1last
   replace RA_1NO with mRA_1no
   replace RN_1NO with mRN_1no
   replace ACM_1NO with mACM_1no
   replace AMT_1P with mAmt_1p
   replace AMT_1D with mAmt_1d
   replace DATE_2LAST with mDate_2last
   replace RA_2NO with mRA_2no
   replace RN_2NO with mRN_2no
   replace ACM_2NO with mACM_2no
   replace AMT_2P with mAmt_2p
   replace AMT_2D with mAmt_2d
   DbUnlock()
   commit
return nil

static function BSP_Page2(nMode)
local wBSP2, nSrow := 12, nKey
   Tone(300,1)
   Message(PAGE3_BAR)
   wBSP2 := OpenWindow(11,05,21,74,"Page 2")
   @ nSrow,   07 say "                  Date      Number    Amount(P)  Amount($)"
   @ row()+1, 07 say "Billings:"
   @ row()+2, 07 say "Official Receipts: "
   @ row()+3, 07 say " Date       RA#        RN#        ACM#       Amount(P)   Amount($)"

   @ nSrow+1, 25 get mBl_1date pict "@!"
   @ row()  , col()+2 get mBl_1no pict "@!"
   @ row()  , col()+2 get mBl_1amtp pict NUM_PIC2
   @ row()  , col()+2 get mBl_1amtd pict NUM_PIC2
   @ row()+1, 25 get mBl_2date pict "@!"
   @ row()  , col()+2 get mBl_2no pict "@!"
   @ row()  , col()+2 get mBl_2amtp pict NUM_PIC2
   @ row()  , col()+2 get mBl_2amtd pict NUM_PIC2
   @ row()+1, 25 get mOR_1date pict "@!"
   @ row()  , col()+2 get mOR_1no pict "@!"
   @ row()  , col()+2 get mOR_1amtp pict NUM_PIC2
   @ row()  , col()+2 get mOR_1amtd pict NUM_PIC2
   @ row()+1, 25 get mOR_2date pict "@!"
   @ row()  , col()+2 get mOR_2no pict "@!"
   @ row()  , col()+2 get mOR_2amtp pict NUM_PIC2
   @ row()  , col()+2 get mOR_2amtd pict NUM_PIC2

   @ row()+3, 08 get mDate_1last pict "@!"
   @ row()  , col()+3 get mRA_1no pict "@!"
   @ row()  , col()+3 get mRN_1no pict "@!"
   @ row()  , col()+3 get mACM_1no pict "@!"
   @ row()  , col()+3 get mAmt_1p pict NUM_PIC2
   @ row()  , col()+3 get mAmt_1d pict NUM_PIC2
   @ row()+1, 08 get mDate_2last pict "@!"
   @ row()  , col()+3 get mRA_2no pict "@!"
   @ row()  , col()+3 get mRN_2no pict "@!"
   @ row()  , col()+3 get mACM_2no pict "@!"
   @ row()  , col()+3 get mAmt_2p pict NUM_PIC2
   @ row()  , col()+3 get mAmt_2d pict NUM_PIC2
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
   CloseWindow(wBSP2)
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

static function Comp_RemD()
   mRemit_d := mTrans_d - (mTrans_d * (mCRate_d / 100 ))
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
   wTotals := OpenWindow(07,05,20,65,"Total Window")
   dStartDate := dEndDate := ctod("")
   cAirCode := "   "
   @ 09, 12 say "Starting Date"   get dStartDate
   @ 10, 12 say "  Ending Date"   get dEndDate
   @ 09, 40 say "Airline Code"    get cAirCode pict "999"
   @ 12, 38 say "Peso"
   @ 12, 53 say "Dollar"
   if cDbf == "MCO"
      @ row()+1, 12 say "    Airfare Totals"
   endif
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
      (cDbf)->(DbSetOrder(DATE_NDX))
      lseek := Set(_SET_SOFTSEEK,.T.)
      (cDbf)->(DbSeek(dStartDate))
      Message("Thinking...")
      do while (cDbf)->Date <= dEndDate .and. (cDbf)->(!Eof())
         if empty(cAirCode) .or. ;
            substr((cDbf)->Ticket_No,1,3) == cAircode
            aTotals[ 1] += (cDbf)->AIRFARE_P
            aTotals[ 2] += (cDbf)->AIRFARE_D
            aTotals[ 3] += (cDbf)->TRANSMIT_P
            aTotals[ 4] += (cDbf)->TRANSMIT_D
            aTotals[ 5] += (cDbf)->CRATE_P
            aTotals[ 6] += (cDbf)->CRATE_D
            aTotals[ 7] += (cDbf)->REMIT_P
            aTotals[ 8] += (cDbf)->REMIT_D
            aTotals[ 9] += (cDbf)->TAX_P
            aTotals[10] += (cDbf)->TAX_D
            aTotals[11] += (cDbf)->ACM_P
            aTotals[12] += (cDbf)->ACM_D
            aTotals[13] += (cDbf)->DIFF_P
            aTotals[14] += (cDbf)->DIFF_D
         endif
         (cDbf)->(DbSkip())
      enddo
      Set(_SET_SOFTSEEK,lseek)
      (cDbf)->(DbSetOrder(TKT_NDX))
      @ 12, 12 say ""
      if cDbf == "MCO"
         @ row()+1, 35 get aTotals[ 1] pict "9,999,999.99"
         @ row(),   50 get aTotals[ 2] pict "9,999,999.99"
      endif
      @ row()+1, 35 get aTotals[ 3] pict "9,999,999.99"
      @ row(),   50 get aTotals[ 4] pict "9,999,999.99"
      @ row()+1, 35 get aTotals[ 5] pict "9,999,999.99"
      @ row(),   50 get aTotals[ 6] pict "9,999,999.99"
      @ row()+1, 35 get aTotals[ 7] pict "9,999,999.99"
      @ row(),   50 get aTotals[ 8] pict "9,999,999.99"
      @ row()+1, 35 get aTotals[ 9] pict "9,999,999.99"
      @ row(),   50 get aTotals[10] pict "9,999,999.99"
      @ row()+1, 35 get aTotals[11] pict "9,999,999.99"
      @ row(),   50 get aTotals[12] pict "9,999,999.99"
      @ row()+1, 35 get aTotals[13] pict "9,999,999.99"
      @ row(),   50 get aTotals[14] pict "9,999,999.99"
      clear gets
      Message("Press a key to continue...")
      inkey(0)
   endif
   CloseWindow(wTotals)
   (cDbf)->(DbGoto(nRecno))
return nil


// <EOF> - TICKETS.PRG //
