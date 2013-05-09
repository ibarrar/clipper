/************************************************/
/* Filename:      FILES.PRG2                    */
/* System-Name:   Purchase Order Filing Program */
/* Module:        Data Entry Module             */
/* Author:        Arnold P. Caoile              */
/* Date-Started:  February 15, 1992             */
/* Last-Update:   February 24, 1992             */
/************************************************/

#include "Inkey.ch"
#include "Setcurs.ch"
#include "Mode.ch"

#define PO_BAR  "F2-Add  F3-Edit  F4-Delete  F5-Search  F6-Cancel  ALT/A-Agency  ESC-Abort"

static mPO,mDate,mRoute1,mRoute2,mXhgRate,mCancelled
static mBillDate,mBillNo,mBillPeso,mBillUsd
static mOrDate,mOrNo,mOrPeso,mOrUsd
static mRaDate,mRaNo,mRaPeso,mRaUsd
static mAgency,aPicture

function Do_PO()
local wPO, nKey
public cSearchpax := space(40), cSearchDir := 'F'
   aPicture:=Array(14,2)
   aPicture[1][1]:="PO_EXT->PO_NO"
   aPicture[1][2]:="@!"
   aPicture[2][1]:="PO_EXT->PAX_NAME"
   aPicture[2][2]:=Replicate("X",40)
   aPicture[3][1]:="PO_EXT->FARE_PHP"
   aPicture[3][2]:="9,999,999.99"
   aPicture[4][1]:="PO_EXT->FARE_USD"
   aPicture[4][2]:="9,999,999.99"
   aPicture[5][1]:="PO_EXT->XMIT_PHP"
   aPicture[5][2]:="9,999,999.99"
   aPicture[6][1]:="PO_EXT->XMIT_USD"
   aPicture[6][2]:="9,999,999.99"
   aPicture[7][1]:="PO_EXT->COMM_PHP"
   aPicture[7][2]:="9,999,999.99"
   aPicture[8][1]:="PO_EXT->COMM_USD"
   aPicture[8][2]:="9,999,999.99"
   aPicture[9][1]:="PO_EXT->REMIT_PHP"
   aPicture[9][2]:="9,999,999.99"
   aPicture[10][1]:="PO_EXT->REMIT_USD"
   aPicture[10][2]:="9,999,999.99"
   aPicture[11][1]:="PO_EXT->TAX_PHP"
   aPicture[11][2]:="9,999,999.99"
   aPicture[12][1]:="PO_EXT->TAX_USD"
   aPicture[12][2]:="9,999,999.99"
   aPicture[13][1]:="PO_EXT->OTHERS_PHP"
   aPicture[13][2]:="9,999,999.99"
   aPicture[14][1]:="PO_EXT->OTHERS_USD"
   aPicture[14][2]:="9,999,999.99"
   if NetUse("AGENCY",DB_SHARED,NUM_SECONDS)
      set index to AGENCY
   endif
   if NetUse("PO",DB_SHARED,NUM_SECONDS)
      set index to PO, PO_AGENT
   endif
   if NetUse("PO_EXT",DB_SHARED,NUM_SECONDS)
      set index to PO_EXT,PO_PAX
   endif
   set key K_ALT_A to GetAgent()
   wPO:=OpenWindow(03,15,14,65,"Purchase Order")
   if PO->(RecCount())==0 ; POForm(APPEND_MODE) ; endif
   if LastKey()!=K_ESC
      do while (nKey!=K_ESC)
         Message(PO_BAR)
         POForm(VIEW_MODE)
         nKey:=Inkey(0)
         do case
            case nKey==K_DOWN
               PO->(DbSkip())
               if PO->(Eof())
                  PO->(DbGoBottom())
                  Tone(100,3)
                  Message("End of file reached....")
                  Inkey(1)
               endif
            case nKey==K_UP
               PO->(DbSkip(-1))
               if PO->(Bof())
                  PO->(DbGoTop())
                  Tone(100,3)
                  Message("Beginning of file reached....")
                  Inkey(1)
               endif
            case nKey==K_CTRL_PGDN
               PO->(DbSkip(NUM_TO_SKIP))
               if PO->(Eof())
                  PO->(DbGoBottom())
                  Tone(100,3)
                  Message("End of file reached....")
                  Inkey(1)
               endif
            case nKey==K_CTRL_PGUP
               PO->(DbSkip(-NUM_TO_SKIP))
               if PO->(Bof())
                  PO->(DbGoTop())
                  Tone(100,3)
                  Message("Beginning of file reached....")
                  Inkey(1)
               endif
            case nKey==K_END
               PO->(DbGoBottom())
                  Message("Moving to end of file....")
                  Inkey(1)
            case nKey==K_HOME
               PO->(DbGoTop())
                  Message("Moving to beginning of file....")
                  Inkey(1)
            case nKey==K_PGDN
                  PO_EXT->(Abrowse(PO->PO_NO,VIEW_MODE,aPicture))
            case nKey==K_F2
               Message("Press ENTER to add new record.")
               inkey(0)
               if LastKey()==K_ENTER
                  POForm(APPEND_MODE)
               endif
            case nKey==K_F3
               POForm(EDIT_MODE)
            case nKey==K_F4
               Message("Press ENTER to delete record, ESC to abort.")
               if InKey(0)==K_ENTER
                  Message("Deleting current record....")
                  PO->(FilLock(0))
                  PO->(DbDelete())
                  PO->(DbUnlock())
               endif
            case nKey==K_F5
               PO->(SearchPax())
            case nKey==K_F6
               if mCancelled
                   Message("Press ENTER to cancel record, ESC to abort.")
               else
                   Message("Press ENTER to uncancel record, ESC to abort.")
               endif
               if InKey(0)==K_ENTER
                   PO->(RecLock(0))
                   PO->CANCELLED := !PO->CANCELLED
                   PO->AGENT     := "000"
                   PO->(DbUnLock())
               endif
         endcase
      enddo
   endif
   Message("Closing Databases....")
   set key K_ALT_A to
   PO->(DbCloseArea())
   PO_EXT->(DbCloseArea())
   AGENCY->(DbCloseArea())
   CloseWindow(wPO)
return nil

static function POForm(nMode)
local n
   Tone(300,1)
   InitVariables(nMode)
   Message(PO_BAR)
   cColor:=SetColor("N/BG")
   if PO->(Deleted()) ; @ 03,35 say "<deleted>"
   else ; @ 03,35 say "         " ; endif
   @ 03,53 say "Rec# " + ;
        Transform(If(nMode==APPEND_MODE,PO->(RecCount()+1),;
        +PO->(RecNo())),"99999")
   SetColor(cColor)
   if PO->CANCELLED ; @ 04,31 say "C A N C E L L E D"
   else ; @ 04,31 say "                 " ; endif
   @ 05,17 say "PO. #" get mPO
   @ 05,50 say "Date" get mDate picture "@!"
   if nMode != VIEW_MODE
       @ 06,17 say repl(" ",46)
       @ 06,17 say "Agent" get mAgent picture "@!"
   else
       @ 06,17 say "Agent" get mAgency picture repl("x",40)
   endif
   @ 07,17 say "Route" get mRoute1 picture repl("x",40)
   @ 08,17 say "     " get mRoute2 picture repl("x",40)
   @ 09,17 say "Rate of Exchange" get mXhgRate picture "99.99"
   @ 10,17 say "     Date      No.      Peso Amt    Dollar Amt"
   @ 11,17 say "Bill" get mBillDate
   @ 11,col()+2 get mBillNo pict "999999999"
   @ 11,col()+2 get mBillPeso  pict "999,999.99"
   @ 11,col()+2 get mBillUsd  pict "999,999.99"
   @ 12,17 say "O.R." get mORDate
   @ 12,col()+2 get mORNo pict "999999999"
   @ 12,col()+2 get mORPeso pict "999,999.99"
   @ 12,col()+2 get mORUsd pict "999,999.99"
   @ 13,17 say "R.A." get mRADate
   @ 13,col()+2 get mRANo pict "999999999"
   @ 13,col()+2 get mRAPeso pict "999,999.99"
   @ 13,col()+2 get mRAUsd pict "999,999.99"
   if (nMode==APPEND_MODE) .or. (nMode==EDIT_MODE)
      SetCursor(SC_NORMAL)
      read
      if LastKey()!=K_ESC
         SaveVariables(nMode)
         PO_EXT->(Abrowse(PO->PO_NO,nMode,aPicture))
         PO_EXT->(DbCommit())
      endif
      SetCursor(SC_NONE)
   else
      clear gets
   endif
return nil

static function InitVariables(nMode)
local n
   if nMode==APPEND_MODE
      mPO:=Space(5)
      mDate:=ctod("")
      mAgent:=Space(3)
      mRoute1:=Space(40)
      mRoute2:=Space(40)
      mXhgRate:=0.00
      mBillDate:=Space(7)
      mBillNo:=Space(12)
      mBillPeso:=0.00
      mBillUsd:=0.00
      mOrDate:=Space(7)
      mOrNo:=Space(12)
      mOrPeso:=0.00
      mOrUsd:=0.00
      mRaDate:=Space(7)
      mRaNo:=Space(12)
      mRaPeso:=0.00
      mRaUsd:=0.00
      mCancelled:=.F.
   else
      mPO:=PO->PO_NO
      mDate:=PO->DATE
      mAgent:=PO->AGENT
      if AGENCY->(DbSeek(mAgent))
          mAgency:=AGENCY->AGENCY
      else
          mAgency:=space(40)
      endif
      mRoute1:=substr(PO->ROUTE,1,40)
      mRoute2:=substr(PO->ROUTE,41)
      mXhgRate:=PO->XHG_RATE
      mBillDate:=PO->BILL_DATE
      mBillNo:=PO->BILL_NO
      mBillPeso:=PO->BILL_PESO
      mBillUsd:=PO->BILL_USD
      mOrDate:=PO->OR_DATE
      mOrNo:=PO->OR_NO
      mOrPeso:=PO->OR_PESO
      mOrUsd:=PO->OR_USD
      mRaDate:=PO->RA_DATE
      mRaNo:=PO->RA_NO
      mRaPeso:=PO->RA_PESO
      mRaUsd:=PO->RA_USD
      mCancelled:=PO->CANCELLED
   endif
return nil

static function SaveVariables(nMode)
   Message("Saving entries...")
   PO->(FilLock(0))
   if nMode==APPEND_MODE
      PO->(DbAppend())
   endif
   replace PO->PO_NO with mPO,           PO->DATE with mDate
   replace PO->AGENT with mAgent,        PO->XHG_RATE with mXhgRate
   replace PO->BILL_NO with mBillNo,     PO->BILL_DATE with mBillDate
   replace PO->BILL_PESO with mBillPeso, PO->BILL_USD with mBillUsd
   replace PO->OR_NO with mOrNo,         PO->OR_DATE with mOrDate
   replace PO->OR_PESO with mOrPeso,     PO->OR_USD with mOrUsd
   replace PO->RA_NO with mRaNo,         PO->RA_DATE with mRaDate
   replace PO->RA_PESO with mRaPeso,     PO->RA_USD with mRaUsd
   replace PO->CANCELLED with mCancelled,PO->ROUTE with mRoute1+mRoute2
   PO->(DbCommit())
   PO->(DbUnlock())
return nil

static function SearchPax()
local wSearch, nSkip := 0
   nRecNo:=PO->(RecNo())
   Message("Enter information to search for...")
   wSearch:=OpenWindow(08,18,14,61,"Search Mode")
   @ 10,20 say "Enter Passenger's Name to search"
   @ 11,20 get cSearchPax picture "@!"
   @ 13,20 say "Direction (F/B) " get cSearchDir valid cSearchDir $ "FB"
   SetCursor(SC_NORMAL)
   read
   CloseWindow(wSearch)
   SetCursor(SC_NONE)
   if LastKey()!=K_ESC
      nSkip := if(cSearchDir=='F',1,-1)
      lFound:=.F.
      DbSkip(nSkip)
      do while (!Eof() .and. !Bof()) .and. !lFound
         Message("Searching Rec#"+transform(RecNo(),"99999")+"...")
         PO_EXT->(DbSeek(PO->PO_NO))
         do while (PO->PO_NO==PO_EXT->PO_NO) .and. PO_EXT->(!Eof()) .and.;
            !lFound
            if alltrim(cSearchPax) $ upper(PO_EXT->PAX_NAME)
               lFound := .T.
            endif
            if !lFound ;  PO_EXT->(DbSkip())  ;  endif
         enddo
         if !lFound ;  PO->(DbSkip(nSkip))  ;  endif
      enddo
      if !lFound
         if Eof()
            Dbskip(-1)
            Message("End of file reached...")
         else
            Message("Beginning of file reached...")
         endif
         Tone(100,3)
         inkey(2)
      else
         Message("Found...")
         Tone(300,1)
         inkey(1)
      endif
   endif
return nil

//end-of-file
