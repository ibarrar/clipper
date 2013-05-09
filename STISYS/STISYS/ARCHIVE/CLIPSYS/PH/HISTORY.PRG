/*
       Filename:  HISTORY.Prg
         Author:  Rollie Castro Ibarra Junior
         Module:  Passenger's History of Accts. System
   Date-Started:  July 08, 1993
    Last-Update:  July 28, 1993
*/
#include "Inkey.ch"
#include "Setcurs.ch"
*#include "Achoice.ch"
#include "Janus.ch"
#include "Epson.ch"
#include "MemoEdit.ch"

#define AB_RECNO     1
#define AB_DELETE    2
#define AB_DATE      3
#define AB_FOLIO     4
#define AB_DEBIT     5
#define AB_CREDIT    6
#define AB_DETAILS_1 7
#define AB_DETAILS_2 8
#define OFFSET  space(5)
#define K_SPACE      32
#define THUD         tone(240,0.25);tone(120,0.25)
#define STATUS_BAR  "F1-Help  F5-Search  F7-Report  F8-Update  ESC-Abort"

static nDbfArea,nTransArea,mName, mlName, mfName, mDate, mAirAgency, mAirline
static aScrollBar, aFields:={}

function Do_History()
local wPass, nKey
   Message("Opening Master File....")
   if NetUse("d:\gldata\AIRLINE",DB_SHARED,NUM_SECONDS)
      set index to "d:\gldata\AIR_CODE","d:\gldata\AIRLINE"
   endif
   if NetUse("MASTER",DB_SHARED,NUM_SECONDS)
      set index to BY_LNAME,BY_FNAME
   endif
   wPass := OpenWindow(03,08,11,66,"Passenger History File")
   if MASTER->(Lastrec())==0
    if config(); PassUpdate(); endif
   endif
   if LastKey()!=K_ESC
      do while nKey!=K_ESC .and. nkey!=K_ALT_X
         Message(STATUS_BAR)
         PassScreen(VIEW_MODE)
         nKey:=Inkey(0)
         do case
            case nKey==K_F1
                 Help(1)
            case nKey==K_DOWN .or. nKey==K_PGDN
                 MASTER->(DbSkip())
                 if MASTER->(Eof())
                    MASTER->(DbGoBottom())
                    Tone(100,0.10)
                    Message("End of file reached....")
                    Inkey(1)
                 endif
            case nKey==K_UP .or. nKey==K_PGUP
                 MASTER->(DbSkip(-1))
                 if MASTER->(Bof())
                    MASTER->(DbGoTop())
                    Tone(100,0.10)
                    Message("Beginning of file reached....")
                    Inkey(1)
                 endif
            case nKey==K_CTRL_PGDN
                 MASTER->(DbSkip(NUM_TO_SKIP))
                 if MASTER->(Eof())
                    MASTER->(DbGoBottom())
                    Tone(150,.25)
                    Message("End of file reached....")
                    Inkey(1)
                 endif
            case nKey==K_CTRL_PGUP
                 MASTER->(DbSkip(-NUM_TO_SKIP))
                 if MASTER->(Bof())
                    MASTER->(DbGoTop())
                    Tone(25,.5)
                    Message("Beginning of file reached....")
                    Inkey(1)
                 endif
            case nKey==K_END
                 MASTER->(DbGoBottom())
                 Message("Moving to end of file....")
                 Inkey(1)
            case nKey==K_HOME
                 MASTER->(DbGoTop())
                 Message("Moving to beginning of file....")
                 Inkey(1)
            case nKey==K_F2
                 Message("Press ENTER to add new record.")
                 if inkey(0)==K_ENTER
                    PassScreen(APPEND_MODE)
                 endif
            case nKey==K_F3
                 Message("Press ENTER to Edit record.")
                 if inkey(0)==K_ENTER
                    PassScreen(EDIT_MODE)
                 endif
            case nKey==K_F4
                 Message("Press ENTER to delete record, ESC to abort.")
                 if InKey(0)==K_ENTER
                    Message("Deleting current record....")
                    MASTER->(FilLock(0))
                    MASTER->(DbDelete())
                    MASTER->(DbUnLock())
                 endif
            case nKey==K_F5
                 PassSearch()
            case nKey==K_F7
                 loption:=.f.
                 PassInfo(rtrim(MASTER->L_NAME),;
                          rtrim(MASTER->F_NAME))
            case nKey==K_F8
                 if config(.t.)
                 MASTER->(PassUpDate())
                 endif
            otherwise
                 THUD
         endcase
      enddo
   endif
   Message("Closing Databases....")
   AIRLINE->(DbCloseArea())
   MASTER->(DbCloseArea())
   CloseWindow(wPass)
return nil

static function PassScreen(nMode)
local n
   Tone(300,1)
   PassInit(nMode)
   Message(STATUS_BAR)
   cColor:=SetColor("N/R")
   if MASTER->(Deleted()) ; @ 03,35 say "<deleted>"
   else ; @ 03,35 say "         " ; endif
    if nMode==APPEND_MODE
       @ 03, 54 say "     < New >"
    else
       @ 03, 51 say "        "
       @ 03, 51 say "Rec #"+transform(MASTER->(RecNo()),"99999")+;
                    "/"+transform(MASTER->(LastRec()),"@B 99999")
    endif
   SetColor(cColor)
   @ 05,      10 say "     Name"  get mName picture "@!"
  @ row()+2, 10 say "     Date"  get mDate picture "@D"
   @ row()+2, 10 say "     Airline/Agency"
    if nMode==VIEW_MODE
       mAirline:=mAirAgency
       if !empty(mAirAgency)
        AIRLINE->(DbSeek(AllTrim(mAirAgency)))
        if AIRLINE->(FOUND())
           mAIRLINE:=AIRLINE->AIRLINE
        endif
       endif
       @ row()+1, 20 get mAirline
    else
       @ row()+1, 20 get mAirAgency picture "@!"
    endif
    if (nMode==APPEND_MODE) .or. (nMode==EDIT_MODE)
      Message("Esc-Abort")
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
      mName     := space(40)
      mDate     := date()
      mAirAgency:=Space(40)
   else
      mName     := alltrim(MASTER->L_NAME)
      mName     += if(!empty(MASTER->F_NAME),", "+alltrim(MASTER->F_NAME),"")
      mName     += space(40-len(mName))
      mDate     := MASTER->DATE
      mAirAgency:=MASTER->AIR_AGENCY
   endif
return nil

static function PassSave(nMode)
   Message("Saving entries...")
   if nMode==APPEND_MODE
      MASTER->(DbAppend())
   endif
   MASTER->(RecLock(0))
   MASTER->L_NAME     := substr(mName,1,at(",",mName) -1)
   MASTER->F_NAME     := substr(mName,at(",", mName) +2)
   MASTER->DATE       := DtoC(mDate)
   MASTER->AIR_AGENCY := mAirAgency
   MASTER->(DbUnlock())
return nil

static function PassSearch()
static cfN,clN,nRec
local wSearch, nKey
   nRecNo:=RecNo()
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
           MASTER->(DbSeek(clN))
        if MASTER->(found())
          nRec:=RecNo()
          do while clN $ MASTER->L_NAME .and. !(cfn $ MASTER->F_NAME) .and. !EOF()
             MASTER->(DbSkip())
          enddo
          if !(cfN $ MASTER->F_NAME)
             MASTER->(DbGoTo(nRec))
             do while clN $ MASTER->L_NAME .and. nKey!=K_ESC
                PassScreen(VIEW_MODE)
                Message("Firstname not found., Press ENTER to continue, ESC to stop...")
                nKey := 0
                do while nKey # K_ENTER .and. nKey # K_ESC
                   nkey := inkey(0)
                enddo
                lFound:= .t.
                if nKey == K_ESC; exit ;  endif
                Message("Searching...")
               MASTER->(DbSkip())
            enddo
          else
             lFound:=.t.
          endif      //not found by skip
        endif        //not found by seek
     elseif lRef   // if lname only
         cPaxName :=  alltrim(cPaxName)
         MASTER->(DbSeek(cPaxName))
           if MASTER->(found())
              do while cPaxName $ MASTER->L_NAME .and. nKey != K_ESC
                   PassScreen(VIEW_MODE)
                   Message("Press ENTER to continue, ESC to stop...")
                   nKey := 0
                   do while nKey # K_ENTER .and. nKey # K_ESC
                      nkey := inkey(0)
                   enddo
                  lFound:= .t.
                  if nKey == K_ESC; exit ;  endif
                  Message("Searching...")
                 MASTER->(DbSkip())
              enddo
           endif
     else
        cPaxName := alltrim(cPaxName)
        MASTER->(DbSetOrder(2))
        MASTER->(DbSeek(cPaxName))
        if MASTER->(found())
           do while cPaxName $ MASTER->F_NAME .and. nKey != K_ESC
               PassScreen(VIEW_MODE)
               Message("Press ENTER to continue, ESC to stop...")
               nKey := 0
               do while nKey # K_ENTER .and. nKey # K_ESC
                 nkey := inkey(0)
               enddo
               lFound:= .t.
               if nKey == K_ESC; exit ;  endif
               Message("Searching...")
             MASTER->(DbSkip())
           enddo
        endif
      MASTER->(DbsetOrder(1))
     endif
       if  !lFound
         Message("End of File reached...")
         Tone(100,3)
         Inkey(1)
         MASTER->(DbGoto(nRecNo))
       endif
   endif
return nil

function PassInfo
parameter mL_NAME,mF_NAME
local nDebit,nCredit,wInfo
public lastRow,cReport
  Message("Preparing Report....")
  Set(_SET_CONSOLE,.F.)
  Set(_SET_ALTFILE,"INFO.TXT")
  Set(_SET_ALTERNATE,.t.)
  ? " þPassenger's History of Accounts"
  ? "  Name: "+mL_NAME+if(empty(mF_NAME),"",", ")+mF_NAME
********************** Subsidiaries... *********************************
 if aChek_[1]
    Report("ARTI","ARTITRAN",;
    "Accounts Receivable - Travel (Individual)")
 endif
 if aChek_[2]
    Report("ARTA","ARTATRAN",;
    "Accounts Receivable - Travel (Agency)")
 endif
 if aChek_[3]
    Report("ARA","ARATRAN",;
    "Accounts Receivable - Airlines")
 endif
 if aChek_[4]
    Report("ARO","AROTRAN",;
    "Accounts Receivable - Others")
 endif
 if aChek_[5]
    Report("AFP","AFPTRAN",;
    "Advances for Passengers")
 endif
 if aChek_[6]
    Report("APO","APOTRAN",;
    "Accounts Payables - Others")
 endif
 if aChek_[7]
    Report("PRI","PRITRAN",;
    "Passenger Refund (Individual)")
 endif
 if aChek_[8]
    Report("PRA","PRATRAN",;
    "Passenger Refund (Agency)")
 endif
 if aChek_[9]
    Report("AEX","AEXTRAN",;
    "Accrued Expenses")
 endif
 Unbill_paid(mL_NAME,mF_NAME)
  Set(_SET_CONSOLE,.t.)
  Set(_SET_ALTFILE,"")
  Set(_SET_ALTERNATE,.f.)
  close alternate
************* Set to screen By MemoEdit *************
  Message("Use cursor keys to navigate, press F10 to print, Esc to Abort.")
  SetCursor(SC_NORMAL)
  tone(138.60,1);tone(277.20,1);tone(523.30,2)
  wInfo:= OpenWindow(3,1,22,77, "Passenger History Information")
  if Mem_chk("Info.Txt")
  cReport:= MemoRead("INFO.TXT")
  if (len(cReport) < memory(1)*1024)
  lastRow:= MLCount(cReport,135)
  MemoEdit(cReport,4,1,22,76,.f.,"EditorFunc",135)
  else;Help(6);endif
  else
  Help(6)
  endif
  CloseWindow(wInfo)
  SetCursor(SC_NONE)

static function Report(cDbfName,cTIndx1,cTitle)
private clname,cfname
  if NetUse("d:\gldata\"+cDbfName+"TRAN",DB_SHARED,NUM_SECONDS)
     set index to &("d:\gldata\"+cTIndx1)
   endif
  nTransArea:=Select()
  if NetUse("d:\gldata\"+cDbfName,DB_SHARED,NUM_SECONDS)
     set index to &("d:\gldata\"+cDbfName)
  endif
  nDbfArea:=Select()
 if (nDbfArea)->(DbSeek(mL_NAME))
    initName()
    do while mL_NAME $ clname .and. !Eof()
      if clname == mL_NAME .and. (empty(mF_NAME) .or. ;
      cfname = mF_NAME .or. mF_NAME $ cfname )
        ?
        ? MARGIN,cTitle
         if !empty(mAirline)
            ? MARGIN,"     Airline/Agency: "
            ?? mAirline
         endif
         if loption
         ? Space(1)+(nDbfArea)->PARTICULAR
         ?? "Date : "+(nDbfArea)->DATE
         endif
         ? MARGIN,"  Date     Folio           Debit      Credit   "
         ?? "Details"//1                                "
*         ?? "Details2                              "
         aTrans:= (nTransArea)->(InitArray2((nDbfArea)->(RecNo())))
         nDebit:= nCredit := 0
         for n:= 1 to Len(atrans)
             ? MARGIN,atrans[n][3]+Space(2)+aTrans[n][4]+Space(0)
             ?? aTrans[n][5]+Space(0)+aTrans[n][6]+Space(3)
             ?? rTrim(aTrans[n][7])+Space(1)+rTrim(aTrans[n][8])
             nDebit += val(delchar(aTrans[n][5],','))
             nCredit += val(delchar(aTrans[n][6],','))
         next
         ? space(31)+"---------------"
         ? MARGIN+space(13-len(cDbfName)),"    Balance("+cDbfName+") ---> "
         ?? transform(nDebit - nCredit,"@( 9,999,999.99")
      endif
       (nDbfArea)->(DbSkip())
       initName()
    enddo
  endif
  (nDbfArea)->(DbCloseArea())
  (nTransArea)->(DbCloseArea())

static function initName()
  if "," $ (nDbfArea)->PARTICULAR
    clname:=substr((nDbfArea)->PARTICULAR, 1, at(",",(nDbfArea)->PARTICULAR) -1 )
    cfname:=rtrim(substr((nDbfArea)->PARTICULAR,at(",",(nDbfArea)->PARTICULAR) +2 ))
  else
    clname:=rTrim((nDbfArea)->PARTICULAR)
    cfname:= ""
  endif
return nil

return nil

return nil


function EditorFunc(nMode,nLine,nCol)
local relPos,nRetVal,lKey,nKey,isReady,nLines,nCurrLine,n,nLineCtr:=0
 if nMode==ME_IDLE
    SetCursor(SC_NONE)
    cColor:=SetColor("N/BG")
    @ 03,55 say "Line:"+transform(nLine,"999")+"/"+transform(lastRow+1,"@B 999")+"   Col:"+;
                 transform(nCol+1,"@B 999")
    for k:= 5 to 21
      @ k,78 say "°" //±177²178°176
    next
    @ 04,78 say if(nLine > 1,chr(24),"±")
    @ 22,78 say if(lastRow > 18 .and. nLine+18 < lastRow,;
                chr(25),"±")
    relPos:= if(nLine=1,0,min(round((nLine/lastRow)*16,0),16))
    @ 5+relPos,78 say "²"
    SetColor(cColor)
    SetCursor(SC_NORMAL)
 else
  lKey:= LastKey()
  do case
     case lKey==K_F10
        Message("Press ENTER to print, ESC to abort...")
        nKey:=0
        do while (nKey!=K_ENTER) .and.  (nKey!=K_ESC)
           nKey:=Inkey(0)
        enddo
        if nKey=K_ENTER
           isReady:= .f.
           do while (nKey!=K_ESC) .and. (!isReady)
              isReady:= IsPrinter()
              if isReady
                 Message("Insert 80 column form then press ENTER to print.")
                 nKey:= 0
                 do while nKey!=K_ENTER ; nKey:=InKey(0) ; enddo
                 nLineCtr:=0
                 Message("Printing....please wait!")
                 Set(_SET_CONSOLE,.f.)
                 Set(_SET_PRINTER,.t.)
                 nLine:=MLCount(cReport,135)
                 ?? chr(27) + chr(120) + chr(1) //select NLQ
                 ?? chr(27) + chr(107) + chr(0) //select Roman
                 ?? chr(27) + chr(119) + chr(1) //turn on double Height
                 for nCurrLine:=2 to 3
                    cLines:=MemoLine(cReport,135,nCurrLine)
                    ? cLines
                    ?
                 next
                 ?? chr(27)+chr(119)+chr(0) //turn off Double height
                 ?? chr(27)+chr(120)+chr(0)
                 ?? chr(15)
                 npage:=2
                 for nCurrLine:= 4 to nLine
                    cLines:= MemoLine(cReport,135,nCurrLine)
                    if nLineCtr > 55
                       eject
                       ?
                       ? "    Page No.",transform(npage,"99")
                       ? "   -------------"
                       ?
                       ?
                       npage++
                       nLineCtr:=2
                    endif
                    ? "  ",cLines
                    nLineCtr++
                 next
                 eject
                 Set(_SET_CONSOLE,.t.)
                 Set(_SET_PRINTER,.f.)
                 Set(_SET_ALTFILE,"")
                 Set(_SET_ALTERNATE,.f.)
                 Close Alternate
              else
                 Message("Printer not Ready....")
                 Tone(100,3)
                 Inkey(2)
                 Message("Press any key to retry, ESC to abort....")
                 nKey:=Inkey(0)
                 Message("")
              endif
            enddo
          endif
          Message("Use cursor keys to navigate, press F10 to print,"+;
                  " ESC to abort.")
       otherwise
            nRetVal:=ME_DEFAULT
       endcase
 endif
return nRetVal

function InitArray2(nRecNo)
   ASize(aFields,0)
   if !DbSeek(nRecNo) ; DbGoTop() ; endif
   do while (REC_NO==nRecNo) .and. (!Eof())
      aAdd(aFields,{RecNo(),if(Deleted(),DELETED_MARK," "),DATE,FOLIO, ;
         Transform(DEBIT,"9,999,999.99"),Transform(CREDIT,"9,999,999.99"), ;
         DETAILS_1,DETAILS_2})
      DbSkip()
   enddo
   if Len(aFields)==0
      aAdd(aFields,{RecCount()+1," ",Space(8),Space(10), ;
         Transform(0,"9,999,999.99"),Transform(0,"9,999,999.99"), ;
         Space(40),Space(40)})
   endif
   aFields:=aSort(aFields,,,{|x,y|ctod(x[AB_DATE]) < ctod(y[AB_DATE]) } )
return aFields

function delchar(cString, cChar)
    ctemp:= ""
    for x:=1 to len(cString)
        if substr(cString,x,1) != cChar
            ctemp := ctemp + substr(cString,x,1)
        endif
    next
return ctemp

function keystroke()
 @ row(),col()-40 say ""
 do while inkey(0)==K_F9
   Searchref(.t.);@ 11,20 say ""
 enddo
 if (lastkey() > K_SPACE) .and. (lastkey() < 256)
    keyboard(chr(K_CTRL_Y)+chr(lastkey()))
 else
    keyboard(chr(lastKey()))
 endif
return .t.

static function Mem_chk(param)
nHandle:=fOpen(param)
param:=fSeek(nHandle,0,2)
fClose(nHandle)
return (param < 65519)

// end-of-file  =>