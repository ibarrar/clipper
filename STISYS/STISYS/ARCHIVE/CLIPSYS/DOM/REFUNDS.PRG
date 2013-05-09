// Filename: Refunds.Prg
// System-Name : PR-Domestic Ticketing System
// Module  : File Handling Module for Refunds file
// Author  : Rolando C. Ibarra Jr.
// Date-Started : Dec 07, 1993
// Date-Ended : Dec ,1993

#include "Inkey.ch"
#include "Setcurs.ch"
#include "Mode.Ch"
#include "cl501_60.ch"

#define  OFFS space(3)
#define BAR   "F1-Help F2-Add F3-Edit F4-Delete F5-Name F6-Ticket F7-Print Sheet  Esc-Abort"

static mPax_Name, mRef_Date, mRef_Tkt, mCPN_No, mRoute1, mRoute2
static mRef_Amt, mRef_ASF, mRef_TFee, mRef_Schg, mRef_Comm, mRef_Net
static mRef_Fare, mRef_Used, mRef_NSC, mRef_2Pax, mRef_Tax, mDate_Prep

function Refunds()
local  nKey:=0 ,wRefund
   REFUND->(DbGotop())
   wRefund := OpenWindow(03,06,21,72,"Refunds Process Sheet")
   if RecCount()==0 ; RefundScreen(APPEND_MODE) ; endif
   if LastKey()!=K_ESC
      do while (nKey!=K_ESC)
         RefundScreen(VIEW_MODE)
         nKey:=inKey(0)
         do case
            case nKey==K_DOWN
               REFUND->(DbSkip())
               if Eof()
                  REFUND->(DbGoBottom())
                  Tone(200,1)
                  Message("End of file reached....")
                  Inkey(1)
               endif
            case nKey==K_UP
               REFUND->(DbSkip(-1))
               if REFUND->(Bof())
                  REFUND->(DbGoTop())
                  Tone(200,1)
                  Message("Beginning of file reached....")
                  Inkey(1)
               endif
            case nKey==K_CTRL_PGDN
               REFUND->(DbSkip(NUM_TO_SKIP))
               if REFUND->(Eof())
                  REFUND->(DbGoBottom())
                  Tone(200,1)
                  Message("End of file reached....")
                  Inkey(1)
               endif
            case nKey==K_CTRL_PGUP
               REFUND->(DbSkip(-NUM_TO_SKIP))
               if REFUND->(Bof())
                  REFUND->(DbGoTop())
                  Tone(200,1)
                  Message("Beginning of file reached....")
                  Inkey(1)
               endif
            case nKey==K_END
                REFUND->(DbGoBottom())
                Message("Moving to end of file....")
                Inkey(1)
            case nKey==K_HOME
                REFUND->(DbGoTop())
                Message("Moving to beginning of file....")
                Inkey(1)
            case nKey==K_F1
                More_Keys()
            case nKey==K_F2
                Message("Press ENTER to Add, ESC to abort.")
                if Inkey(0)==K_ENTER
                   RefundScreen(APPEND_MODE)
                endif
            case nKey==K_F3
                Message("Press ENTER to Edit, ESC to abort.")
                if Inkey(0)==K_ENTER
                   RefundScreen(EDIT_MODE)
                endif
            case nKey==K_F4
                Message("Press ENTER to Delete, ESC to abort.")
                if Inkey(0)==K_ENTER
                    REFUND->(FilLock(0))
                    REFUND->(DbDelete())
                    REFUND->(DbUnlock())
                endif
            case nKey==K_F5
                Search_Pax()
            case nKey==K_F6
                Search_Ticket()
            case nKey==K_F7
                Sheet()
            case nKey==K_F8
                Message("Press ENTER to Insert, ESC to abort.")
                if Inkey(0)==K_ENTER
                   Message("Inserting New record...")
                   REFUND->(FilLock(0))
                   REFUND->(DbInsert())
                   REFUND->(DbUnlock())
                endif
            case nKey==K_F9
                Message("Press ENTER to Reindex, ESC to abort.")
                if Inkey(0)==K_ENTER
                   Message("Reindexing, please wait...")
                   REFUND->(FilLock(0))
                   REFUND->(DbReindex())
                   REFUND->(DbUnlock())
                endif

           endcase
      enddo
   endif
   CloseWindow(wRefund)
return nil

static function RefundScreen(nMode)
local nKey
   InitVars(nMode)
   Message(BAR)
   Tone(300,1)
   cColor:=SetColor("N/GB")
   if REFUND->(Deleted()) ; @ 03,35 say "<deleted>"
   else ; @ 03,35 say "         " ; endif
   @ 03,59 say "Rec# " + ;
   Transform(If(nMode==APPEND_MODE,REFUND->(LastRec())+1,REFUND->(RecNo())),"9999")+;
   "/"+Transform(REFUND->(LastRec()),"@B 9999")
   SetColor(cColor)
   @ 05,08 say "Date Tkt/MCO Issuance:" get mRef_Date
   @ row(),col()+02 say "Tkt/MCO No.:" get mRef_Tkt
   @ row()+2,08 say "Pax Name:" get mPax_Name
   @ row()+1,08 say "Routing/Fare Basis:"
   @ row()+1,08 say "       " get mRoute1 PICT "@!"
   @ row()+1,08 say "       " get mRoute2 PICT "@!"
*   @ 09     ,48 say "Date prepared:" get mDate_Prep
   @ 09     ,52 say "CPN.No(s).:" get mCPN_No
   @ 13     ,08 say "Fare Paid             " get mRef_Fare  pict NUM_PIC2
   @ row()+1,08 say "Less: Used Portions(s)" get mRef_Used  pict NUM_PIC2
   @ row()+1,08 say "Refundable Amount     " get mRef_Amt   pict NUM_PIC2  when compRefAmt()

   @ 12     ,42 say "   Add:  Tax       " get mREf_Tax pict NUM_PIC2
   @ row()+1,42 say "         ASF       " get mRef_ASF pict NUM_PIC2
   @ row()+1,42 say "         T-FEE     " get mRef_TFee  pict NUM_PIC2
   @ row()+1,42 say "Less:Refund Svc.Fee" get mRef_Schg  pict NUM_PIC2
   @ row()+1,42 say "No Show Surcharge  " get mRef_NSC   pict NUM_PIC2

   @ row()+2,16 say "Net Refundable Amount to Pax " get mRef_2PAx pict NUM_PIC2 when comp2PAX()
   @ row()+1,19 say "   Less:Recall Commission " get mRef_Comm  pict NUM_PIC2 when compComm()
   @ row()+1,19 say "   Net Refundable Amount  " get mRef_Net   pict NUM_PIC2 when compNEt()

   if nMode!=VIEW_MODE
      SetCursor(SC_NORMAL)
      read
      if Lastkey()!=K_ESC
          SaveVars(nMode)
      endif
   else
      clear gets
   endif
   SetCursor(SC_NONE)
return nil

static function InitVars(nMode)
    if nMode!=APPEND_MODE
       mRef_Date:=REFUND->REF_DATE
       mPax_Name:=REFUND->REF_PAX
       mRef_Tkt :=REFUND->REF_TICK
       mCPN_No  :=REFUND->CPN_NO
       mRoute1  :=REFUND->REF_ROUTE1
       mRoute2  :=REFUND->REF_ROUTE2
       mRef_Amt :=REFUND->REF_AMT
       mRef_ASF :=REFUND->REF_ASF
       mRef_TFee:=REFUND->REF_TFEE
       mRef_Schg:=REFUND->REF_SCHG
       mRef_Comm:=REFUND->REF_COMM
       mRef_Net :=REFUND->REF_NET
       mRef_Fare:=REFUND->REF_FARE
       mRef_Used:=REFUND->REF_USED
       mRef_NSC :=REFUND->REF_NSC
       mRef_Tax :=REFUND->REF_TAX
       mRef_2Pax:=REFUND->REF_2PAX
*       mDate_prep:=REFUND->DATE
    else
       mRef_Date:=ctod("")
*       mDate_Prep:=date()
       mPax_Name:=space(40)
       mRef_Tkt :=space(17)
       mCPN_No  :=space(07)
       mRoute1  :=space(30)
       mRoute2  :=space(30)
       mRef_Amt :=0.00
       mRef_ASF :=0.00
       mRef_TFee:=0.00
       mRef_Schg:=0.00
       mRef_Comm:=0.00
       mRef_Net :=0.00
       mRef_Fare:=0.00
       mRef_Used:=0.00
       mRef_NSC :=0.00
       mRef_Tax :=0.00
       mRef_2Pax:=0.00
    endif
return nil

static function SaveVars(nMode)
   Message("Saving entries...")
   if nMode==APPEND_MODE   ;   REFUND->(AddRec(0))   ;   endif
   REFUND->(FilLock(0))
   REFUND->REF_DATE  := mRef_Date
   REFUND->REF_PAX   := mPax_Name
   REFUND->REF_TICK  := mRef_Tkt
   REFUND->CPN_NO    := mCPN_No
   REFUND->REF_ROUTE1:= mRoute1
   REFUND->REF_ROUTE2:= mRoute2
   REFUND->REF_AMT   := mRef_Amt
   REFUND->REF_ASF   := mRef_ASF
   REFUND->REF_TFEE  := mRef_TFee
   REFUND->REF_SCHG  := mRef_Schg
   REFUND->REF_COMM  := mRef_Comm
   REFUND->REF_NET   := mRef_Net
   REFUND->REF_FARE  := mRef_Fare
   REFUND->REF_USED  := mRef_Used
   REFUND->REF_TAX   := mRef_Tax
   REFUND->REF_NSC   := mRef_NSC
   REFUND->REF_2PAX  := mRef_2Pax
*   REFUND->DATE      := mDate_Prep
   REFUND->(DbUnlock())
return nil

static function Search_Pax()
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
      DbSeek(AllTrim(cName))
      nKey:=0
      if Found()
         do while (cName==substr(upper(REF_PAX),1,len(cName))) .and. (nKey!=K_ESC)
            RefundScreen(VIEW_MODE)
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
   endif
return nil

static function Search_Tkt()
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
      DbSeek(AllTrim(cTicket))
      nKey:=0
      if Found()
         do while (cTicket==substr(upper(REF_TICK),1,len(cTicket))) .and.;
            (nKey!=K_ESC)
            RefundScreen(VIEW_MODE)
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

static function compRefAmt()
mRef_Amt:= (mRef_Fare - mRef_Used)
return .t.

static function comp2pax()
mRef_2Pax := mRef_Amt + ((mRef_Tax + mRef_ASF + mRef_TFee) - ;
           (mRef_Schg + mRef_NSC))  // Net refundable amount to Pax computed
return .t.

static function compComm()
mRef_Comm := mRef_Amt * (2.5/100)
return .t.

static function compnet()
mRef_Net := (mRef_2Pax - mRef_Comm) // Net Amount to be computed
return .t.

static function Put079()
if empty(mRef_Tkt)
keyboard chr(48)+chr(55)+chr(57)+chr(95)
endif
return .t.

static function Sheet()
local wInfo,nKey,IsReady:=IsPrinter()
local cMemo,mDate,sRepNo,sOr,sRR1,sRR2
 mName1:= "Azucena Grijaldo"
 mPos1:=  "  Accountant    "
 mName2:= " Yvette Chua    "
 mPos2:=  " Travel Manager "
 mDate:=if(empty(REFUND->DATE),Date(),REFUND->DATE)
 sOr:=   REFUND->ORNO
 sRepNo:=REFUND->REPNO
 sRR1:=  REFUND->FLIGHT1
 sRR2:=  REFUND->FLIGHT2
 cMemo:= REFUND->NOTES
 Message("Enter transaction infos. press ESC to abort.")
 wInfo:=Openwindow(08,10,if(empty(mRef_NSC),14,16),67,"Information Box")
 @ 10,12 say "Processed By  :" get mName1
 @ 11,12 say "Position/Title:" get mPos1
 @ 12,12 say "Approved By   :" get mName2
 @ 13,12 say "Position/Title:" get mPos2
 @ 10,46 say     "O.R.Issued:" get sOr    pict "@!"
 @ 11,46 say     "Report No.:" get sRepNo pict "@!"
 @ 12,46 say     "      Date:" get mDate  pict "@D"
 if !empty(mRef_NSC)
 @ 14,12 say "Flight Number :" get sRR1
 @ 15,12 say "             & " get sRR2
 endif
 SetCursor(1)
 read
 setcursor(0)
 CloseWindow(wInfo)
 nkey:=lastkey()
 if lastkey()!= K_ESC
    cMemo:=Notes(cMemo)
 endif
  if nkey != K_ESC
   REFUND->(FilLock(0))
     REFUND->DATE    := mDate
     REFUND->ORNO    := sOr
     REFUND->REPNO   := sRepNo
     REFUND->FLIGHT1 := sRR1
     REFUND->FLIGHT2 := sRR2
     REFUND->NOTES   := cMemo
   REFUND->(DbUnlock())
   do while (nKey!=K_ESC) .and. (!IsReady)
      Message("Printer not ready...")
      Tone(3243,1)
      Inkey(2)
      Message("Press any key to retry, ESC to abort....")
      nKey:=Inkey(0)
      IsReady:=IsPrinter()
    enddo
    if Isready
       Tone(440,1);Tone(440,1)
       Message("Insert 80 column form then press ENTER to print")
       nKey:=0
       do while nkey!= K_ENTER ; nKey:=Inkey(0) ; enddo
       Tone(880,1);Tone(880,1)
       Message("Printing please wait...!")
       Set(_SET_CONSOLE,.f.)
       Set(_SET_PRINTER,.t.)
       ?
       ?? chr(18)+chr(27)+chr(80) // Set Printer Normal 10 cpi
       ?? chr(27)+chr(120)+chr(1) // NLQ on
       ?? chr(27)+chr(107)+chr(0) // Roman Style
       ?
       ?? chr(27)+chr(87)+chr(1)   // Double Width
       ?? chr(27)+chr(119)+chr(1)  // Double Height
       ?? chr(27)+chr(71)          // Double Strike
       ?  space(11) + "Philippine Airlines"
       ?  space(10) + repl(chr(196),21)
       ?? chr(27)+chr(72)          // Double Strike off
       ?? chr(27)+chr(119)+chr(0)  // Normal Height
       ?  space(10) + "REFUNDS PROCESS SHEET"
       ?? chr(27)+chr(87)+chr(0)   // Normal Width
       ?
       ?
       ?
       ?? chr(27) + chr(48) //skip less
       ?  OFFS,"PAX NAME:"
       ?? PrtUnderline(padc(alltrim(mPax_Name),33),33)
       ?? space(1) + "DATE TKT/MCO ISSUANCE:"
       ?? PrtUnderline(padc(expand(mRef_Date),09),09)
       ?
       ?  OFFS,"TKT/MCO NO(S). :"
       ?? PrtUnderline(pad(alltrim(mRef_Tkt),29),29)
       ?? space(1) + "CPN.NO(S) : _"
       ?? PrtUnderline(pad(alltrim(mCPN_No),15),15)
       ?
       ?  OFFS,"ROUTING/FARE BASIS:"
       ?? PrtUnderline(pad(allTrim(mRoute1)+" "+allTrim(mRoute2),55),55)
       ?
       ?
       ?
       ?
       ?
       ? OFFS,space(09) + "FARE PAID                                "
       ?? PrtUnderline(transform(mRef_Fare,NUM_PIC),19)
       ?
       ? OFFS,space(09) + "LESS:  USED PORTION(S)                   "
       ?? PrtUnderline(transform(mRef_Used,NUM_PIC),19)
       ?
       ? OFFS,space(09) + "REFUNDABLE AMOUNT                        "
       ?? PrtUnderline(transform(mRef_Amt,NUM_PIC),19)
       ?
       ? OFFS,space(09) + "ADD:  TAX                                "
       ?? PrtUnderline(transform(mRef_Tax,NUM_PIC),19)
       ?
       ? OFFS,space(09) + "      ASF                                "
       ?? PrtUnderline(transform(mRef_ASF,NUM_PIC),19)
       ?
       ? OFFS,space(09) + "      T-FEE                              "
       ?? PrtUnderline(transform(mRef_TFee,NUM_PIC),19)
       ?
       ? OFFS,space(09) + "LESS: RFND.SVC.FEE                       "
       ?? PrtUnderline(transform(mRef_Schg,NUM_PIC),19)
       ?
       ? OFFS,space(09) + "      NO SHOW SCHG.-"+if(empty(mRef_NSC),space(20),;
       PrtUnderline(pad(sRR1,20),20) ) + " "
       ?? PrtUnderline(transform(mRef_NSC,NUM_PIC),19)
       ?
      if !empty(mRef_NSC) .and. !empty(sRR2)
       ? OFFS,space(09) + "                    "+ PrtUnderline(sRR2,20)
       ?
      endif
       ? OFFS,space(09) + "NET REFUNDABLE AMOUNT TO PAX             "
       ?? PrtUnderline(transform(mRef_2Pax,NUM_PIC),19)
       ?
       ? OFFS,space(09) + "LESS: RECALL COMMISSION                  "
       ?? PrtUnderline(transform(mRef_Comm,NUM_PIC),19)
       ?
       ? OFFS,space(09) + "NET REFUNDABLE AMOUNT                    "
       ?? PrtUnderline(transform(mRef_Net,NUM_PIC),19)
       ? chr(27) + chr(50) //skip full
       ?
       ?
*       cMemo:=Memoread("Refund.Nts")
       nNoteLines:=MlCount(cMemo,91)
       for r:=1 to nNoteLines
           cNoteLine:=MemoLine(cMemo,91,r,7)
           ? OFFS,cNoteLine
       next
       ?
       ?
       ? OFFS,"NAME OF AGENT :" + PrtUnderline(padc("SUPER TRAVEL, INC.",31),31)
       ?? space(1) + "AGENT'S CODE : " + PrtUnderline("  YEE",12)
       ?
       ? OFFS,"PROCESSED BY:" + PrtUnderline(padc(mName1,18),18)
       ?? space(1) + "DATE :" + PrtUnderline(padc(expand(mDate),7),7)
       ?? space(1) + "O.R. ISSUED : _" + PrtUnderline(sOR,13)
       ?? chr(27)+chr(83)+chr(0)+chr(27)+chr(48)
       ?  chr(27)+chr(50)
       ?? OFFS,"              " + Padc(mPos1,18)
       ?? chr(27)+chr(84)
       ? OFFS,"APPROVED BY:" + PrtUnderline(padc(mName2,18),18)
       ?? space(0) + "DATE :" + PrtUnderline(space(7),7)
       ?? space(1) + "REMITTANCE REPORT NO.:" + PrtUnderline(padc(sRepNo,8),8)
       ?? chr(27)+chr(83)+chr(0)+chr(27)+chr(48)
       ?  chr(27)+chr(50)
       ?? OFFS,"            " + Padc(mPos2,18)
       ?? chr(27)+chr(84)
       ?
       ?
       ?
       ?
       ?
       ?
       ?
       ?
       ?
       ?
       ?
       ?
       ? space(4)+repl("Ä",74)
       ? OFFS,space(2)+"DISTRIBUTION:  Copy 1 - DPRAD   Copy 2 - Agent "
       ?
       eject
       Set(_SET_CONSOLE,.t.)
       Set(_SET_PRINTER,.f.)
       PopSound()
       Alert("Refunds Process Sheet Report done...")
       UnPopSound()
     else
       Message("Printing Aborted...")
       BUMMER()
       Inkey(2)
     endif
   endif
return nil

static function more_keys()
local  wMore
   wMore:=OpenWindow(06,40,19,77,"Help Window")
   @ 07, 42 say ""
   @ row()+1, 42 say "F1 - Help Screen"
   @ row()+1, 42 say "F2 - Add a New Record to File"
   @ row()+1, 42 say "F3 - Edit Displayed Record"
   @ row()+1, 42 say "F4 - Delete Displayed Record"
   @ row()+1, 42 say "F5 - Insert a New Record"
   @ row()+1, 42 say "F6 - Reindex Database"
   @ row()+1, 42 say "F7 - Print Refund Process Sheet"
   @ row()+1, 42 say "PgDn/PgUp - Move from Pages"
   @ row()+1, 42 say "Up/Down - Previous/Next Record"
   @ row()+1, 42 say "Ctrl-[Up/Down] - Jump 20 Records"
   @ row()+1, 42 say "ESC - Go Back to Main Menu"
   inkey(0)
   CLoseWindow(wMore)
return nil

// <EOF> - REFUNDS.PRG //
