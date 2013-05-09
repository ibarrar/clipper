// Filename:      VOUCHER.PRG
// Author:        Rollie C. Ibarra Jr.
// Date-Started:  December 28, 1993
// Last-Update:   December 28, 1993
// Revisions:

#include "Inkey.ch"
#include "Setcurs.ch"
#include "Achoice.ch"
#include "Mode.Ch"
#include "Printer.Ch"


#define TV_BAR  "F1-Help  F2-Add  F3-Edit  F5-Search  F6-Cancel  F7-Print  ESC-Abort"
#define PAX_BAR "F1-Help    F2-Add     F4-Delete    ESC-Abort"

static mVoucherNo,mAgency,mDate,mDuration,mHotel,mTwnBed1,mTwnBed2
static mSglBed1,mSglBed2,mXtrBed1,mXtrBed2,mHotelDt1,mHotelDt2
static mMeals,mMealDt1,mMealDt2,mArrFlt,mArrDate,mDepFlt,mDepDate
static mRemarks1,mRemarks2,mBilled,mCancelled,mABF,mOwTransfer
static mTour,mRtTransfer,aPicture,aPax,cOfficer
static nTotalAmt,mCompleteAgency,mCompleteHotel

function Do_Voucher()
local wTV, nKey
public cSearchPax := cSearchAgent := space(40), cDir := ' '
   aPicture:=Array(1,2)
   aPicture[1][1] := "PAX->NAME"
   aPicture[1][2] := repl('x',40)
   use agency index agency new
   use hotel index hotel new
   use pax index pax new
   use voucher index voucher new
   wTV:=OpenWindow(03,06,20,73,"Tour Voucher")
   if VOUCHER->(RecCount())==0 ; TVForm(APPEND_MODE) ; endif
   if LastKey()!=K_ESC
      do while (nKey!=K_ESC)
         Message(TV_BAR)
         TVForm(VIEW_MODE)
         nKey:=Inkey(0)
         do case
            case nKey==K_DOWN
                 VOUCHER->(DbSkip())
                 if VOUCHER->(Eof())
                    VOUCHER->(DbGoBottom())
                    Tone(100,3)
                    Message("End of file reached....")
                    Inkey(1)
                 endif
            case nKey==K_UP
                 VOUCHER->(DbSkip(-1))
                 if VOUCHER->(Bof())
                    VOUCHER->(DbGoTop())
                    Tone(100,3)
                    Message("Beginning of file reached....")
                    Inkey(1)
                 endif
            case nKey==K_CTRL_PGDN
                 VOUCHER->(DbSkip(NUM_TO_SKIP))
                 if VOUCHER->(Eof())
                    VOUCHER->(DbGoBottom())
                    Tone(100,3)
                    Message("End of file reached....")
                    Inkey(1)
                 endif
            case nKey==K_CTRL_PGUP
                 VOUCHER->(DbSkip(-NUM_TO_SKIP))
                 if VOUCHER->(Bof())
                    VOUCHER->(DbGoTop())
                    Tone(100,3)
                    Message("Beginning of file reached....")
                    Inkey(1)
                 endif
            case nKey==K_END
                 VOUCHER->(DbGoBottom())
                 Message("Moving to end of file....")
                 Inkey(1)
            case nKey==K_HOME
                 VOUCHER->(DbGoTop())
                 Message("Moving to beginning of file....")
                 Inkey(1)
            case nKey==K_PGDN
                 PAX->(Abrowse(VOUCHER->VOUCHER_NO,VIEW_MODE,aPicture))
            case nKey==K_F1
                 Helpme()
            case nKey==K_F2
                 Message("Press ENTER to add new record.")
                 if inkey(0)==K_ENTER
                    TVForm(APPEND_MODE)
                 endif
            case nKey==K_F3  //edit vchr only if !printed & !cancelled
                 if VOUCHER->CANCELLED
                    tone(328.28,3)
                    Message("Voucher was Cancelled, cannot be Edited...                         F1 - Help ")
                    inkey(2)
                 elseif VOUCHER->BILLED
                    tone(328.28,3)
                    Message("Voucher was Printed, cannot be Edited...                           F1 - Help ")
                    inkey(2)
                 else
                    TVForm(EDIT_MODE)
                 endif
/*            case nKey==K_F4
                 Message("Press ENTER to delete record, ESC to abort.")
                 if InKey(0)==K_ENTER
                    Message("Deleting current record....")
                    if PAX->(DbSeek(VOUCHER->VOUCHER_NO))
                       do while (PAX->VOUCHER_NO==VOUCHER->VOUCHER_NO)
                          PAX->(DbDelete())
                          PAX->(DbSkip())
                       enddo
                    endif
                    VOUCHER->(DbDelete())
                    sele pax
                    pack
                    sele voucher
                    pack
                 endif
*/
            case nKey==K_F5
                 VOUCHER->(SearchPax())
            case nKey==K_F6
                 if !mCancelled
                    Message("Press ENTER to cancel record, ESC to abort.                        F1 - Help")
                    if InKey(0)==K_ENTER
                      VOUCHER->CANCELLED := .t.
                    endif
                 else
                    Message("Voucher was already cancelled....                                  F1 - Help")
                    tone(328.28,3)
                    inkey(2)
                 endif
            case nKey==K_F7
                 if !mCancelled
                    Message("Printing Tour Voucher....")
                    test:=PrtVchr()
                    do while test=2
                       TVForm(EDIT_MODE)
                       test:=PrtVchr()
                       if !VOUCHER->BILLED; test=2 ;endif
                    enddo
                    if test=1
                       Message("Printed, press any key...")
                       inkey(0)
                    endif
                 else
                    Message("Tour Voucher was Cancelled, cannot be Printed...                   F1 - Help")
                    tone(328.28,3)
                    inkey(2)
                 endif
            case nKey==K_F8
                 MoreInfo()
            case nKey==K_ALT_A
                 Agent_Look()
            case nKey==K_ALT_H
                 Hotel_Look()
         endcase
      enddo
   endif
   Message("Closing Databases....")
   VOUCHER->(DbCloseArea())
   PAX->(DbCloseArea())
   AGENCY->(DbCloseArea())
   HOTEL->(DbCloseArea())
   CloseWindow(wTV)
return nil

static function TVForm(nMode)
local n
   Tone(300,1)
   InitVariables(nMode)
   Message(TV_BAR)
   cColor:=SetColor("N/BG")
   if VOUCHER->(Deleted()) ; @ 03,35 say "<deleted>"
   else ; @ 03,35 say "         " ; endif
    if nMode==APPEND_MODE
       @ 03, 62 say "< New >"
    else
       @ 03, 62 say "       "
*       @ 03, 62 say "Rec #"+transform(VOUCHER->(RecNo()),"9999")
    endif
   SetColor(cColor)
   @ 04,31 say "                 "
   if mBilled; @ 04,33 say "P R I N T E D" ; endif
   if mCancelled ; @ 04,31 say "C A N C E L L E D"  ; endif
   @ 05,55 say "Voucher #" + mVoucherNo
   @ 06,08 say "Agent" get mAgency picture if(nMode==VIEW_MODE,repl('x',40),'!!!'+repl('x',37))
   @ row(),col()+2 say "  Date" get mDate picture "@!"
   @ 07,08 say "Hotel" get mHotel picture  if(nMode==VIEW_MODE,repl('x',40),'!!!'+repl('x',37))
   @ 08,08 say "      Duration" get mDuration picture "@!"
   @ row(),col()+11 say "Date" get mHotelDt1 picture "@!"
   @ row(),col()+1  say "-" get mHotelDt2 picture "@!"
   @ 10,08 say "Adult->" get mTwnBed1 pict "99"
   @ row(), col() say "HTwn" get mSglBed1 pict "99"
   @ row(), col() say "Sglb" get mXtrBed1 pict "99"
   @ row(), col() say "Xbed       Child->" get mTwnBed2 pict "99"
   @ row(), col() say "HTwn" get mSglBed2 pict "99"
   @ row(), col() say "Xbed" get mXtrBed2 pict "99"
   @ row(), col() say "Nbed"
   @ 12,08 say "Meals" get mMeals pict repl('x',40)
   @ 13,08 say "      Date" get mMealDt1 pict "@!"
   @ row(), col()+1 say "-" get mMealDt2 pict "@!"
   @ 15,08 say "  Arrival Transfer-Flight" get mArrFlt picture "@!"
   @ row(), col()+5 say "Date" get mArrDate picture "@!"
   @ 16,08 say "Departure Transfer-Flight" get mDepFlt picture "@!"
   @ row(), col()+5 say "Date" get mDepDate picture "@!"
   @ 18,08 say "Remarks" get mRemarks1 pict "@S55"
   @ 19,08 say "       " get mRemarks2 pict "@S55"
   if (nMode==APPEND_MODE) .or. (nMode==EDIT_MODE)
      set key K_ALT_A to Agent_Look()
      set key K_ALT_H to Hotel_Look()
      SetCursor(SC_NORMAL)
      read
      if LastKey()!=K_ESC
         SaveVariables(nMode)
         PAX->(Abrowse(mVoucherNo,nMode,aPicture))
      endif
      SetCursor(SC_NONE)
      set key K_ALT_A to
      set key K_ALT_H to
   else
      clear gets
   endif
return nil

static function InitVariables(nMode)
   if nMode==APPEND_MODE
      cNum := ltrim(transform( VOUCHER->(LastRec())+1,"9999" ))
      mVoucherNo := substr(dtoc(date()),7,2) + "-" +;
                    substr("0000",1,4-len(cNum) ) + cNum
      mAgency    := space(40)
      mDate      := space(7)
      mDuration  := space(7)
      mHotel     := space(40)
      mTwnBed1   := 0.00
      mTwnBed2   := 0.00
      mSglBed1   := 0.00
      mSglBed2   := 0.00
      mXtrBed1   := 0.00
      mXtrBed2   := 0.00
      mHotelDt1  := space(7)
      mHotelDt2  := space(7)
      mMeals     := space(40)
      mMealDt1   := space(7)
      mMealDt2   := space(7)
      mArrFlt    := space(6)
      mArrDate   := space(7)
      mDepFlt    := space(6)
      mDepDate   := space(7)
      mRemarks1  := space(85)
      mRemarks2  := space(85)
      mBilled    := .F.
      mCancelled := .F.
      mABF       := .F.
      mOwTransfer:= .F.
      mTour      := .F.
      mRtTransfer:= .F.
   else
      mVoucherNo := VOUCHER->VOUCHER_NO
      mAgency    := VOUCHER->AGENCY
      mDate      := DtoE( VOUCHER->DAY_ISSUED )
      mDuration  := VOUCHER->DURATION
      mHotel     := VOUCHER->HOTEL
      mTwnbed1   := val(VOUCHER->TWN_BED1)
      mTwnBed2   := val(VOUCHER->TWN_BED2)
      mSglbed1   := val(VOUCHER->SGL_BED1)
      mSglBed2   := val(VOUCHER->SGL_BED2)
      mXtrbed1   := val(VOUCHER->XTR_BED1)
      mXtrBed2   := val(VOUCHER->XTR_BED2)
      mHotelDt1  := DtoE( VOUCHER->HOTEL_FROM )
      mHotelDt2  := DtoE( VOUCHER->HOTEL_TO )
      mMeals     := VOUCHER->MEALS
      mMealDt1   := DtoE( VOUCHER->MEAL_FROM )
      mMealDt2   := DtoE( VOUCHER->MEAL_TO )
      mArrFlt    := VOUCHER->ARR_FLIGHT
      mArrDate   := DtoE( VOUCHER->ARR_DATE )
      mDepFlt    := VOUCHER->DEP_FLIGHT
      mDepDate   := DtoE( VOUCHER->DEP_DATE )
      mRemarks1  := VOUCHER->REMARKS_1
      mRemarks2  := VOUCHER->REMARKS_2
      mBilled    := VOUCHER->BILLED
      mCancelled := VOUCHER->CANCELLED
      mABF       := VOUCHER->ABF
      mOwTransfer:= VOUCHER->OWTRANSFER
      mTour      := VOUCHER->TOUR
      mRtTransfer:= VOUCHER->RTTRANSFER
      AGENCY->(DbSeek(mAgency))
      mCompleteAgency:=AGENCY->AGENT
      HOTEL->(DbSeek(mHotel))
      mCompleteHotel:=HOTEL->HOTEL
      if nMode==VIEW_MODE
         mAgency:=mCompleteAgency
         mHotel:=mCompleteHotel
      else
         mAgency := padr(mAgency,40)
         mHotel  := padr(mHotel,40)
      endif
   endif
return nil

static function SaveVariables(nMode)
   Message("Saving entries...")
   if nMode==APPEND_MODE
      VOUCHER->(DbAppend())
   endif
   VOUCHER->VOUCHER_NO  := mVoucherNo
   VOUCHER->AGENCY      := mAgency
   VOUCHER->DAY_ISSUED  := EtoD( mDate )
   VOUCHER->DURATION    := mDuration
   VOUCHER->HOTEL       := mHotel
   VOUCHER->TWN_BED1    := transform(mTwnBed1,"99")
   VOUCHER->TWN_BED2    := transform(mTwnBed2,"99")
   VOUCHER->SGL_BED1    := transform(mSglBed1,"99")
   VOUCHER->SGL_BED2    := transform(mSglBed2,"99")
   VOUCHER->XTR_BED1    := transform(mXtrBed1,"99")
   VOUCHER->XTR_BED2    := transform(mXtrbed2,"99")
   VOUCHER->HOTEL_FROM  := EtoD( mHotelDt1 )
   VOUCHER->HOTEL_TO    := EtoD( mHotelDt2 )
   VOUCHER->MEALS       := mMeals
   VOUCHER->MEAL_FROM   := Etod( mMealDt1 )
   VOUCHER->MEAL_TO     := Etod( mMealDt2 )
   VOUCHER->ARR_FLIGHT  := mArrFlt
   VOUCHER->ARR_DATE    := Etod( mArrDate )
   VOUCHER->DEP_FLIGHT  := mDepFlt
   VOUCHER->DEP_DATE    := EtoD( mDepDate )
   VOUCHER->REMARKS_1   := mRemarks1
   VOUCHER->REMARKS_2   := mRemarks2
   VOUCHER->BILLED      := mBilled
   VOUCHER->CANCELLED   := mCancelled
   VOUCHER->ABF         := mABF
   VOUCHER->OWTRANSFER  := mOWtransfer
   VOUCHER->TOUR        := mTour
   VOUCHER->RTTRANSFER  := mRTtransfer
   VOUCHER->(DbCommit())
return nil

static function SearchPax()
local wSearch, nKey := 0
   nRecNo:=RecNo()
   Message("Enter info, ALT-A for Agencies, ESC to abort...")
   wSearch:=OpenWindow(08,18,15,61,"Search Mode")
   @ 10,20 say "Agent Name to search"
   @ 11,20 get cSearchAgent picture "@!"
   @ 12,20 say "Pax Name to search"
   @ 13,20 get cSearchPax picture "@!"
   @ 14,20 say "Forward/Backward" get cDir pict '!' valid cDir $ "FB"
   SetCursor(SC_NORMAL)
   set key K_ALT_A to Agent_Look()
   read
   set key K_ALT_A
   cSearchPax:=cSearchPax
   CloseWindow(wSearch)
   SetCursor(SC_NONE)
   lFound:=.F.
   if LastKey()!=K_ESC
      VOUCHER->(DbSkip(if(cDir=='F',1,-1) ))
      do while VOUCHER->(!Eof()) .and. VOUCHER->(!Bof()) .and. !lFound
         Message("Searching Record #"+transform(VOUCHER->(RecNo()),"9999") )
         PAX->(DbSeek(VOUCHER->VOUCHER_NO))
         do while PAX->(!Eof()) .and. (PAX->VOUCHER_NO==VOUCHER->VOUCHER_NO);
            .and. !lFound
            if (alltrim(cSearchPax) $ upper(PAX->NAME)) .and. ;
               ((alltrim(cSearchAgent)==VOUCHER->HOTEL) .or. empty(cSearchAgent))
               Tone(300,1)
               lFound:=.T.
            else
               PAX->(DbSkip())
            endif
         enddo
         if !lFound
            VOUCHER->(DbSkip(if(cDir=='F',1,-1) ))
         endif
      enddo
      if VOUCHER->(Eof())
         Message("End of File reached, Search failed...")
         Tone(100,3)
         Inkey(2)
         VOUCHER->(DbSkip(-1))
      elseif VOUCHER->(Bof())
         Message("Beginning of File reached, Search failed...")
         Tone(100,3)
         Inkey(2)
      endif
   endif
return nil

static function PrtVchr()
local lRetVal:= 0
   if GetInfo()
      if PrintWait()
         nPax := len(aPax)
         lExceed:=.F.
         Message("Printing....please wait!")
         Set(_SET_CONSOLE,.F.)
         Set(_SET_PRINTER,.T.)
         ?? chr(27) + chr(56)
         SetPrinter(_SET_SIZE,P_NORMAL)
         SetPrinter(_SET_PITCH,P_12_PITCH)
         SetPrinter(_SET_QUALITY,P_NLQ)
         SetPrinter(_SET_TYPESTYLE,P_ROMAN)
         SetPrinter(_SET_HEIGHT,P_DOUBLE)
         SetPrinter(_SET_WIDTH,P_DOUBLE)
         SetPrinter(_SET_EMPHASIZED,.T.)
         ?? Space(15),"Super Travel, Inc."
         SetPrinter(_SET_EMPHASIZED,.F.)
         SetPrinter(_SET_WIDTH,P_NORMAL)
         SetPrinter(_SET_HEIGHT,P_NORMAL)
         SetPrinter(_SET_SIZE,P_CONDENSED)
         ? Space(70),"Ground Floor, VIP Building"
         ? Space(57),"1154 Roxas Boulevard, Ermita, Manila, Philippines"
         ? Space(64),"Tel. 59-60-02 to 05, 50-96-46 to 47"
         SetPrinter(_SET_SIZE,P_NORMAL)
         SetPrinter(_SET_WIDTH,P_DOUBLE)
         ? Space(18),"TOUR VOUCHER       No.",mVoucherNo
         SetPrinter(_SET_WIDTH,P_NORMAL)
         ? space(4),"To:",mCompleteAgency        //shold convert to Agency complete
         ? space(4),"    Tel: ",AGENCY->PHONE
         ? space(4),"    Attn:",AGENCY->CONTACT,Space(27)
         ?? "Date",PrtUnderline( cMonth(etod(mDate))+;
              transform(day(etod(mDate)),"999")+", "+;
              transform(year(etod(mDate)),"99999"),20)
         if nPax<=10
            if nPax <= 5
               for n:=1 to 5-Len(aPax) ; ? ; next
               for n:=1 to Len(aPax)-1 ; ? space(4),Space(14),aPax[n] ; next
               ? space(4),"Please provide",PrtUnderline(aPax[Len(aPax)],62)," "
            else
               while len(aPax) < 10 ; aAdd(aPax,space(40)) ; end
               for n := 1 to 4
                  ? space(4),space(14),substr(aPax[n],1,35)+substr(aPax[n+5],1,35)
               next
               ? space(4),"Please provide",;
                 PrtUnderline(substr(aPax[5],1,35)+aPax[10],63)," "
            endif
         else
            lExceed:=.T.
            for n:=1 to 4 ; ? ; next
            ? space(4),"Please provide"
            ?? PrtUnderline("   PLEASE SEE ATTACHED NAMELIST.",62)," "
         endif
         ?? "No. of Psgr",PrtUnderline(transform(nPax,"99"),2)
         ?
         ? space(4),"Accomm at",PrtUnderline(mCompleteHotel,18),"Htl or similar " //also should be
         nTwn := Int( (mTwnBed1 + mTwnBed2) / 2)
         ?? PrtUnderLine(blank_ifzero(nTwn,"9"),2) + "TWNB "
         ?? PrtUnderLine(blank_ifzero(mSglBed1,"9"),2) + "SGLB "
         ?? PrtUnderLine(blank_ifzero(mXtrBed1+mSglBed2,"9"),2) + "XBED "
         ?? PrtUnderLine(blank_ifzero(mXtrBed2,"9"),2) + "NBED"
         ?? "  Date",PrtUnderline(mHotelDt1+"-"+mHotelDt2,15)
         ?
         ? space(4),"Meals",PrtUnderLine(mMeals,65)
         ?? "  Date",PrtUnderline(mMealDt1+"-"+mMealDt2,15)
         ?
         ? space(4),"Arrival Transfer-Flt",PrtUnderLine(mArrFlt,8)
         ?? "  Date",PrtUnderLine(mArrDate,7)
         ?? "     Departure Transfer-Flt",PrtUnderLine(mDepFlt,8)
         ?? "  Date",PrtUnderLine(mDepDate,7)
         ?
         ? space(4),"Remarks",PrtUnderline(mRemarks1,85)
         ?
         ? space(4),"       ",PrtUnderline(mRemarks2,85)
         ?
         ? space(4),Space(68),"Super Travel, Inc. by:"
         ?
         ? space(4),Space(66),PrtUnderLine(padc(alltrim(cOfficer),26),26)
         SetPrinter(_SET_SIZE,P_CONDENSED)
         SetPrinter(_SET_SUPERSCRIPT,.T.)
         ? space(8),"Issued subject to the condition that only items "
         ?? "indicated above are for the account of Super Travel, Inc.    All "
         ?? "other items shall be chargeable direct"
         ? space(8),"to the passengers."
         ?? chr(27) + chr(57)
         SetPrinter(_SET_SIZE,P_NORMAL)
         SetPrinter(_SET_SUPERSCRIPT,.F.)
         if lExceed
            SetPrinter(_SET_FORMFEED)
            ? ; ?
            ? space(4),"Passenger Namelist for Tour Voucher No. ",mVoucherNo
            ?
            for n:=1 to Len(aPax)
               ? space(4),Space(3),Transform(n,"99"),". ",aPax[n]
            next
         endif
         SetPrinter(_SET_SIZE,P_NORMAL)
         SetPrinter(_SET_PITCH,P_10_PITCH)
         SetPrinter(_SET_QUALITY,P_DRAFT)
         SetPrinter(_SET_FORMFEED)
         Set(_SET_CONSOLE,.T.)
         Set(_SET_PRINTER,.F.)
         if !(VOUCHER->BILLED)
            Message("Printed...   Press SPACE to see Voucher.")
            VOUCHER->BILLED := Checkifok()
         endif
         lRetVal := if(VOUCHER->BILLED,1,2)
      else
         Message("Printer not ready...")
         Tone(100,3)
         inkey(2)
      endif
   endif
return lRetVal

static function GetInfo()
local wInfo
   cBooked := cOfficer:= space(30)  ;  aPax := {}  ; dBooked := space(7)
   Message("Enter necessary information, press Esc to abort.")
   wInfo:=OpenWindow(09,10,14,68,"Tour Information Box")
   @ 11,12 say "   Booking Confirmed by" get cBooked
   @ 12,12 say "                   Date" get dBooked
   @ 13,12 say "  Super Travel, Inc. by" get cOfficer
   SetCursor(SC_NORMAL)
   read
   SetCursor(SC_NONE)
   CloseWindow(wInfo)
   if LastKey()!=K_ESC
      PAX->(DbSeek(VOUCHER->VOUCHER_NO))
      do while (PAX->VOUCHER_NO==VOUCHER->VOUCHER_NO) .and. PAX->(!Eof())
         aAdd(aPax,PAX->NAME)
         PAX->(DbSkip())
      enddo
   endif
return If(LastKey()==K_ESC,.F.,.T.)

static function MoreInfo()
local wMore
   wMore:=OpenWindow(08,19,16,58,"CheckList")
   @ 10,     25 say "             Billed" get VOUCHER->BILLED     pict "Y"  when !(VOUCHER->BILLED)
   @ row()+1,25 say "          Cancelled" get VOUCHER->CANCELLED  pict "Y"  when !(VOUCHER->CANCELLED)
   @ row()+1,25 say "               Tour" get VOUCHER->TOUR       pict "Y"
   @ row()+1,25 say "Round Trip Transfer" get VOUCHER->RTTRANSFER pict "Y"
   @ row()+1,25 say "   One Way Transfer" get VOUCHER->OWTRANSFER pict "Y"
   @ row()+1,25 say "(Enter 'Y' if true, 'N' if not)"
   SetCursor(SC_NORMAL)
   read
   SetCursor(SC_NONE)
   CloseWindow(wMore)
return nil

static function helpme()
local nx,w_Help,aHlpLst_:={ "Program Revisions        Dated: Aug.21,1993 ",;
                            "",;
                            "  * A Tour Voucher Record can no longer be ",;
                            " edited once it is printed.  But it can be ",;
                            " reprinted as many times as needed.","",;
                            "  * If a printed Tour Voucher have errors, ",;
                            " that voucher must be  cancelled by press- ",;
                            " ing F6. Then a new voucher can be created ",;
                            " by pressing F2.","",;
                            "  * Once a Voucher record is cancelled, it ",;
                            " can no longer be changed nor printed.",;
                            "",;
                            "Note : There is no way  of  Uncancelling a ",;
                            "       Cancelled Tour Voucher .",;
                            "",;
                            "            **Control Keys**",;
                            "   ARROW UP/DN - Previous/Next Voucher.",;
                            "   PGUP/PGDN   - Previous/Next Voucher.",;
                            "   HOME        - First Voucher on File.",;
                            "   END         - Last Voucher on File.",;
                            "   CTRL PGUP   - Skip Last 20 Vouchers.",;
                            "   CTRL PGDN   - Skip Next 20 Vouchers.",;
                            "   F1          - Help!.",;
                            "   F2          - Add Voucher.",;
                            "   F3          - Edit Voucher.",;
                            "   F4          - Delete Voucher.",;
                            "   F5          - Search Voucher.",;
                            "   F6          - Cancel Voucher.",;
                            "   F7          - Print Voucher.",;
                            "   F8          - Voucher Checklist.",;
                            "   ALT+A       - Agency Lookup.",;
                            "   ALT+H       - Hotel Lookup.",;
                            "   ESC         - Exit Tour Voucher." }
    nDeep := Len(aHlpLst_)
    nlen := 0
    aEval(aHlpLst_,{ |s| nlen:= max(nlen,len(s)) })
    w_help := openwindow(05,round((38-nlen/2),0),;
              min(nDeep+7,21),round(40+(nlen/2),0),"Help Window")
    for nx:= 07 to min(ndeep+06,20)
        @ nx,round((80-nlen)/2,0) say aHlpLst_[nx-06]
    next
    @ 06,round(38-(nlen /2),0) to min(nDeep+07,21),round(40+(nlen /2),0) double
    nDeep:=1
    @ 20,round(40+(nlen /2),0) say chr(25)
    Message("Use Up/Dn arrow keys, Esc to continue.")
   do while lastkey() != K_ESC
      inkey(0)
      do case
         case lastkey() == K_DOWN .and. (nDeep+13)<len(aHlpLst_)
              if nDeep+13==33
              @ 20,round(40+(nlen /2),0) say "º"
              elseif nDeep==1
              @ 07,round(40+(nlen /2),0) say chr(24)
              endif
              nDeep++
              scroll(07,round(39-(nlen/2),0),20, round(39+(nlen/2),0),1)
              @ 20,round((80-nlen)/2,0) say aHlpLst_[nDeep+13]
         case lastkey() == K_UP .and. nDeep>1
              if nDeep+13==35
              @ 20,round(40+(nlen /2),0) say chr(25)
              elseif nDeep==2
              @ 07,round(40+(nlen /2),0) say "º"
              endif
              nDeep--
              scroll(07,round(39-(nlen/2),0),20,round(39+(nlen/2),0),-1)
              @ 07,round((80-nlen)/2,0) say aHlpLst_[nDEEP]
         otherwise
              if nextkey() != Lastkey();tone(528.28,0.28);endif
      endcase
   enddo
    closewindow(w_help)
return nil

function TourPay()
local lFound
   if Get3Info()
      if IsPrinter()
          use PAX index PAX new
          use VOUCHER index VOUCHER new
          use LAND new
          Message("Thinking...")
          Set(_SET_ALTFILE,"PAYABLES.RPT")
          Set(_SET_CONSOLE,.F.)
          Set(_SET_ALTERNATE,.T.)
          ?? "Super Travel, Inc."
          ? "þ Tour Voucher Payables" + if(!empty(mAgency),"  ("+mAgency+")","")
          ? "Period :", dStartDate,"to",dEndDate
          ?
          ?  "     Voucher#  Htl    Date      Dur                "
          ?? "Passenger(s)                      Adult     Child      Total"
          ?
          nTotalAmt:=0
          do while VOUCHER->(!Eof())
            if ((VOUCHER->AGENCY==mAgency) .or. empty(mAgency)) .and. ;
               (VOUCHER->HOTEL_FROM >= dStartDate) .and. ;
               (VOUCHER->HOTEL_FROM <= dEndDate) .and. ;
               !VOUCHER->CANCELLED .and. VOUCHER->BILLED
                Message("Reading Voucher Rec #"+;
                     transform(VOUCHER->(RecNo()),"9999") )
               LAND->( dbgotop() )
               lFound := .F.
               do while LAND->( !eof() ) .and. !lFound
                  if (LAND->EFF_TO   >= VOUCHER->HOTEL_FROM) .and. ;
                     (LAND->EFF_FROM <= VOUCHER->HOTEL_FROM) .and. ;
                     (LAND->EFF_TILL >= VOUCHER->DAY_ISSUED) .and. ;
                     (LAND->AGENCY == VOUCHER->AGENCY) .and. ;
                     (LAND->HOTEL == VOUCHER->HOTEL)
                     lFound := .T.
                  endif
                  LAND->( dbskip() )
               enddo
               if lFound
                  ProcessVoucher()
               endif
            endif
            VOUCHER->(DbSkip())
         enddo
         ? repl('-',114)
         ? "Totals ------->",space(87),transform(nTotalAmt,"999999.99")
         Set(_SET_ALTERNATE,.F.)
         Set(_SET_CONSOLE,.T.)
         Set(_SET_ALTFILE,"")
         PAX->(DbCloseArea())
         VOUCHER->(DbCloseArea())
         LAND->(DbCloseArea())
         Message("Insert 80 column paper and presss any key...")
         inkey(0)
         Message("Printing...")
         cReport:=MemoRead("PAYABLES.RPT")
         nLines:=MLCount(cReport,225)
         Set(_SET_CONSOLE,.F.)
         Set(_SET_PRINTER,.T.)
         ?? chr(27) + chr(80) + chr(18)
         SetPrinter(_SET_HEIGHT,P_DOUBLE)
         SetPrinter(_SET_EMPHASIZED,.T.)
         SetPrinter(_SET_QUALITY,P_NLQ)
         ?? MemoLine(cReport,70,1)
         ?
         ?  MemoLine(cReport,70,2)
         ?
         ?  MemoLine(cReport,70,3)
         SetPrinter(_SET_HEIGHT,P_NORMAL)
         SetPrinter(_SET_SIZE,P_CONDENSED)
         Set(_SET_MARGIN,10)
         ?
         ? "Page : 1"
         Head1 := MemoLine(cReport,120,5)
         Head2 := MemoLine(cReport,120,6)
         ?  Head1  ;  ? Head2
         SetPrinter(_SET_QUALITY,P_DRAFT)
         SetPrinter(_SET_EMPHASIZED,.F.)
         nLCount:=7  ; nPage := 1
         for x:=7 to nLines
             ? MemoLine(cReport,120,x)
             nLCount ++
             if nLCount > 57
                eject
                nPage ++
                SetPrinter(_SET_EMPHASIZED,.T.)
                SetPrinter(_SET_QUALITY,P_NLQ)
                ? "Page :"+transform(nPage,"99")
                ?  Head1  ;  ? Head2
                SetPrinter(_SET_QUALITY,P_DRAFT)
                SetPrinter(_SET_EMPHASIZED,.F.)
                nLcount := 3
             endif
         next
         eject
         Set(_SET_MARGIN,0)
         Set(_SET_PRINTER,.F.)
         Set(_SET_CONSOLE,.T.)
         Message("Printing Done...")
         Tone(300,1)
         Inkey(2)
      else
         Message("Printer Not Ready...")
         Tone(100,3)
         Inkey(2)
      endif
   endif
return nil

static function ProcessVoucher()
local  nAmtADT := nAmtCHD := 0
   if val(VOUCHER->TWN_BED1) > 0 ; nAmtADT += GetAdtCost(1) * val(VOUCHER->TWN_BED1) ; endif
   if val(VOUCHER->SGL_BED1) > 0 ; nAmtADT += GetAdtCost(2) * val(VOUCHER->SGL_BED1) ; endif
   if val(VOUCHER->XTR_BED1) > 0 ; nAmtADT += GetAdtCost(3) * val(VOUCHER->XTR_BED1) ; endif
   if val(VOUCHER->TWN_BED2) > 0 ; nAmtCHD += GetAdtCost(1) * val(VOUCHER->TWN_BED2) ; endif
   if val(VOUCHER->SGL_BED2) > 0 ; nAmtCHD += GetAdtCost(2) * val(VOUCHER->SGL_BED2) ; endif
   if val(VOUCHER->XTR_BED2) > 0 ; nAmtCHD += GetAdtCost(3) * val(VOUCHER->XTR_BED2) ; endif
   nTotalAmt += nAmtADT + nAmtCHD
   PAX->(DbSeek( VOUCHER->VOUCHER_NO ))
   ? space(4),VOUCHER->VOUCHER_NO," ",VOUCHER->HOTEL,"  "
   ?? dtoe( VOUCHER->HOTEL_FROM ),"  ",VOUCHER->DURATION," ",PAX->NAME,"  "
   ?? transform(nAmtADT,"9999.99")," ",transform(nAmtCHD,"9999.99"),"  "
   ?? transform(nAmtADT+nAmtCHD,"99999.99")
   PAX->(DbSkip())
   do while PAX->(!Eof()) .and. (VOUCHER->VOUCHER_NO == PAX->VOUCHER_NO)
      ? space(41),PAX->NAME
      PAX->(DbSkip())
   enddo
return nil

static function GetADTCost(nMode)
local nAmt := 0
   if "4D3N" $ VOUCHER->DURATION
       do case
           case nMode==1 ; nAmt :=LAND->HTWN_4D3NA
           case nMode==2 ; nAmt :=LAND->SGLB_4D3NA
           case nMode==3 ; nAmt :=LAND->XTRB_4D3NA
       endcase
       if !VOUCHER->ABF        ; nAmt -= LAND->HOTEL_ABF * 3 ; endif
       if !VOUCHER->TOUR       ; nAmt -= LAND->TOUR          ; endif
       if !VOUCHER->RTTRANSFER ; nAmt -= LAND->OW_TRSF * 2   ; endif
       IF !VOUCHER->OWTRANSFER ; nAmt -= LAND->OW_TRSF       ; endif
   elseif "3D2N" $ VOUCHER->DURATION
       do case
           case nMode==1 ; nAmt :=LAND->HTWN_3D2N
           case nMode==2 ; nAmt :=LAND->SGLB_3D2N
           case nMode==3 ; nAmt :=LAND->XTRB_3D2N
       endcase
       if !VOUCHER->ABF        ; nAmt -= LAND->HOTEL_ABF * 2 ; endif
       if !VOUCHER->TOUR       ; nAmt -= LAND->TOUR          ; endif
       if !VOUCHER->RTTRANSFER ; nAmt -= LAND->OW_TRSF * 2   ; endif
       IF !VOUCHER->OWTRANSFER ; nAmt -= LAND->OW_TRSF       ; endif
   else
       nNights := val( substr(VOUCHER->DURATION,3,1) )
       do case
           case nMode==1 ; nAmt :=LAND->HTWN_4D3NA + (LAND->XN_HTWN * (nNights-3))
           case nMode==2 ; nAmt :=LAND->SGLB_4D3NA + (LAND->XN_SGLB * (nNights-3))
           case nMode==3 ; nAmt :=LAND->XTRB_4D3NA + (LAND->XN_XTRB * (nNights-3))
       endcase
       if !VOUCHER->ABF        ; nAmt -= LAND->HOTEL_ABF * nNights ; endif
       if !VOUCHER->TOUR       ; nAmt -= LAND->TOUR                ; endif
       if !VOUCHER->RTTRANSFER ; nAmt -= LAND->OW_TRSF * 2         ; endif
       IF !VOUCHER->OWTRANSFER ; nAmt -= LAND->OW_TRSF             ; endif
   endif
return nAmt

static function GetCHDCost(nMode)
local nAmt := 0
   if "4D3N" $ VOUCHER->DURATION
       do case
           case nMode==1 ; nAmt :=LAND->HTWN_4D3NC
           case nMode==2 ; nAmt :=LAND->XTRB_4D3NC
           case nMode==3 ; nAmt :=LAND->NOB_4D3NC
       endcase
       if !VOUCHER->ABF        ; nAmt -= LAND->HOTEL_ABF * 3 ; endif
       if !VOUCHER->TOUR       ; nAmt -= LAND->TOUR          ; endif
       if !VOUCHER->RTTRANSFER ; nAmt -= LAND->OW_TRSF * 2   ; endif
       IF !VOUCHER->OWTRANSFER ; nAmt -= LAND->OW_TRSF       ; endif
   elseif "3D2N" $ VOUCHER->DURATION
       do case
           case nMode==1 ; nAmt :=LAND->HTWN_4D3NC - LAND->XN_HTWN
           case nMode==2 ; nAmt :=LAND->XTRB_4D3NC - LAND->XN_XTRB
           case nMode==3 ; nAmt :=LAND->NOB_4D3NC
       endcase
       if !VOUCHER->ABF        ; nAmt -= LAND->HOTEL_ABF * 2 ; endif
       if !VOUCHER->TOUR       ; nAmt -= LAND->TOUR          ; endif
       if !VOUCHER->RTTRANSFER ; nAmt -= LAND->OW_TRSF * 2   ; endif
       IF !VOUCHER->OWTRANSFER ; nAmt -= LAND->OW_TRSF       ; endif
   else
       nNights := val( substr(VOUCHER->DURATION,3,1) )
       do case
           case nMode==1 ; nAmt :=LAND->HTWN_4D3NC + (LAND->XN_HTWN * (nNights-3))
           case nMode==2 ; nAmt :=LAND->XTRB_4D3NC + (LAND->XN_XTRB * (nNights-3))
           case nMode==3 ; nAmt :=LAND->NOB_4D3NA
       endcase
       if !VOUCHER->ABF        ; nAmt -= LAND->HOTEL_ABF * nNights ; endif
       if !VOUCHER->TOUR       ; nAmt -= LAND->TOUR                ; endif
       if !VOUCHER->RTTRANSFER ; nAmt -= LAND->OW_TRSF * 2         ; endif
       IF !VOUCHER->OWTRANSFER ; nAmt -= LAND->OW_TRSF             ; endif
   endif
return Amt

static function Get3Info()
local wDates
   dStartDate1:=dEndDate:=space(7) ; mAgency:=Space(3)
   SetCursor(SC_NORMAL)
   Message("Enter transaction dates,   ALT+A-Agency   Esc-abort.")
   wDates:=OpenWindow(08,14,13,64,"Print Accounts Payable")
   @ 10,19 say " Enter starting date (ddmmmyy)" get dStartDate picture "99!!!99"
   @ 11,19 say "         ending date (ddmmmyy)" get dEndDate picture "99!!!99"
   @ 12,19 say "      Travel Agency code (xxx)" get mAgency picture "@!"
   set key K_ALT_A to Agent_Look()
   read
   set Key K_ALT_A to
   CloseWindow(wDates)
   SetCursor(SC_NONE)
   Message("")
   dStartDate := etod( dStartDate )
   dEndDate   := etod( dEndDate )
return if(LastKey()==K_ESC,.F.,.T.)

static function PrintWait()
   if isprinter()
      return .t.
   else
      Message("Waiting for printer to come on-line, press a key to cancel...")
      while inkey()==0 .and. !isprinter()  ;  end
      if isprinter()
         return .t.
      else
         Message("Printing cancelled by user...")
         tone(300,1)
         inkey(2)
      endif
   endif
   return .f.

static function Checkifok()
local i,nkey
local wOk,colOk,aOk_:= {"    Ok    ",;
                        "   Edit   "}
  wOk:=OpenWindow(08,22,13,58,"       Printer output ok?")
  @ 09,22 to 13,58 double
  colOk:=setcolor("B/W")
  @ 12,27 say "ßßßßßßßßßßßß"
  @ 11,38 say "Ü"
  @ 12,43 say "ßßßßßßßßßßßß"
  @ 11,54 say "Ü"
  setcolor("N/RB")
  @ 11,42 say " "+aOk_[2]+" "
  i:=1
  do while nkey!=K_ENTER
     @ 11,if(i=1,26,42) say chr(16)+aOk_[i]+chr(17)
     nkey:=inkey(0)
     @ 11,if(i=1,26,42) say " "+aOk_[i]+" "
     if (nkey=K_UP) .or. (nkey=K_DOWN) .or. (nkey=K_LEFT) .or. ;
        (nkey=K_RIGHT)
             if i = 2 ; i:=1
             else; i++; endif
     elseif nkey = 32
         wOk2:= SaveScreen(08,22,14,59)
         RestScreen(Asc(Substr(wOk,1,1)),;
                    Asc(Substr(wOk,2,1)),;
                    Asc(Substr(wOk,3,1)),;
                    Asc(Substr(wOk,4,1)),;
                    Substr(wOk,5)         )
         Message("Printed...   Press any key to continue.")
         inkey(0)
         Message("Printed...   Press SPACE to see Voucher.")
         RestScreen(08,22,14,59,wOk2)
     elseif nkey = K_ENTER
         setcolor(colOk)
         @ 11,if(i=1,26,42) say "             "
         setcolor("N/RB")
         @ 12,if(i=1,27,43) say chr(16)+aOk_[i]+chr(17)
         tone(828,0.28)
         inkey(0.15)
     endif
  enddo
  closeWindow(wOk)
  Setcolor(colOk)
return if(i=1,.t.,.f.)

// end-of-file