/*BUNDY Clock */

#include "inkey.ch"
#include "setcurs.ch"
#include "set.ch"
#include "Janus.ch"

static aTime,aStatus,mDate
#define FULL        .t.
#define EMPTY       .f.


function Do_Bundy()
local lExit,OkOut:=.f.
local maxdlst:={31,28,31,30,31,30,31,31,30,31,30,31}
local wBundy,bColor,nkey,cell:=1,stat:=1,pPos:=2,p1stat:=1
private mName,mSlot:={0,0}
private aPos:={15,28,41,54},cellPos:={18,31,44,57}
private aUTstat:={"Door Closed","Deductable "," Not Appl. ","<<<Empty>>>"}
private aOTstat:={" Applicable"," Not Appl. "," 4 Aproval ","<<<Empty>>>"}
aTime:=array(4)
aStatus:=array(5)
mDate:=DATE()
mTime:=TIME()
lExit:=ReadExit(.t.)
  Message("Opening Databases...")
  if NetUse("PAYTRANS",DB_SHARED,NUM_SECONDS)
     set index to PAYTRANS,PAYDATE
  endif
  if NetUse("PAYMAST",DB_SHARED,NUM_SECONDS)
     set index to PAYMAST,PAYSLOT
  endif
  wBundy:=OpenWindow(05,13,14,67,"Bundy Clock")
     @ 07,20 say "Date:                Time:"
     @ 09,15 say "Slot No."
     @ 09,30 say "Name "
     bColor:=SetColor("W/N")
     @ 11   ,15      say " Punch in  "
     @ row(),col()+2 say " Punch out "
     @ row(),col()+2 say " Punch in  "
     @ row(),col()+2 say " Punch out "
     setColor(bColor)
*     Message("")
     MODE:=InitVar(PAYMAST->(RecNo()))
     SetKey(K_F2,{ || ShowStatus() })
  do while lastkey()!=K_ESC
  /* display them all */
   DispAll()
  do case
     case pPos==1
        Message("<PgUp/PgDn>-Inc/Dec  <ENTER>-Accept & Search  <ESC>-Abort  <F2>-Status")
        tDate:=mDate
        tDate:=dtoc(tDate)
        mm:=val(substr(tdate,1,2))
        dd:=val(substr(tdate,4,2))
        yr:=val(substr(tdate,7,2))
        do while !OkOut
          setcolor("W+/GR")
          @ 07,26 say tDate
          setcolor("N/W")
          datekey:=TInkey(1)
          @ 07,26 say tDate
          setcolor(bcolor)
          do case
             *case datekey==K_UP
              * pPos:=5;OkOut:=.t.
             case datekey==K_DOWN .or. datekey==K_ESC
               pPos:=2;OkOut:=.t.
             case datekey==K_PGUP
                dd++
             case dateKey==K_PGDN
                dd--
          endcase
          if dd > maxdlst[mm]
            dd:=1;mm++
          elseif dd < 1
           if mm=1
             mm:=12;yr--
           else
             mm--
           endif
            dd:=maxdlst[mm]
          endif
          if mm > 12
            mm:=1;yr++
          endif
          tDate:=ctod(str(mm)+"-"+str(dd)+"-"+str(yr))
        enddo
        if lastkey()!=K_ESC
         mDate:=tDate
         Mode:=InitVar(PAYMAST->(RecNo()))
        endif
        OkOut:= .f.
     case pPos==2
      do while !OkOut
        do case
           case p1stat ==1
              Message("Enter Slot # of employee.. <ENTER>-Accept  <Right>-Name  <ESC>-Abort  ")
              @ 09,15 say "Slot No."
              mSlot:=ReadSlot(mSlot[1])
              if empty(mSlot[1])
               mSlot[1]:=0
              endif
              if mSlot[2] = K_ESC
                  OkOut:=.t.
              elseif mSlot[2] = K_RIGHT
                  p1stat:=2
              elseif mSlot[2] = K_UP
                  pPos:=1;OkOut:=.t.
              elseif mSlot[2] = K_DOWN
                  pPos:=3;OkOut:=.t.
              elseif SbySlot(mSlot[1])
                  MODE:=InitVar(PAYMAST->(RecNo()))
                  pPos++;OkOut:=.t.
              endif
            case p1stat ==2
              Message("Enter Name of employee...  <ENTER>-Accept   <Left>-Slot No.   <ESC>-Abort")
              @ 09,30 say "Name "
              mName:=ReadName()
              if empty(mName[1])
                 mName[1]:=space(30)
              endif
              if mName[2] = K_ESC
                OkOut:=.t.
              elseif mName[2] = K_LEFT
                p1stat:=1
              elseif mName[2] = K_UP
                pPos:=1;OkOut:=.t.
              elseif mName[2] = K_DOWN
                pPos:=3;OkOut:=.t.
              elseif SearchEmp(mName[1])
                MODE:=InitVar(PAYMAST->(RecNo()))
                pPos++;OkOut:=.t.
              endif
           endcase
        enddo
         OkOut:=.f.
     case pPos==3
     Message("<Left or Right>-Choose   <ENTER>-Set time   <ESC>-Abort   <F2>-Status")
     do while !oKout
       SetColor("W+/N")
       @ 11,aPos[stat] say chr(16)+if(stat%2==0,"Punch out","Punch in ")+chr(17)
       SetColor("W/N")
       nkey:=TInkey(1)
       @ 11,aPos[stat] say if(stat%2==0," Punch out "," Punch in  ")
       setcolor(bColor)
       do case
          case nkey==K_ESC
               OkOut:=.t.
          case nkey==K_UP
               pPos:=2
               Okout:=.t.
          case nKey==K_DOWN
               pPos:=4
               Okout:=.t.
          case nkey==K_LEFT
               stat:=if(stat=1,4,stat-1)
          case nkey==K_RIGHT
               stat:=if(stat=4,1,stat+1)
          case nkey==K_ENTER
               aTime[stat]:= time()
               @ 12,aPos[stat]+3 say aTime[stat] pict "99:99"
       endcase
     enddo
     OkOut:=.f.
     case pPos=4
      Message("<Edit keys>-Change  <Left/Right>-Select   <Enter or Up/Down>-Set time   <ESC>-Abort")
      do while !OkOut
      mTemp:="00:00"
      setcolor("W/N")
      @ 12 , cellPos[stat] say transform(aTime[stat],"99:99")
      setcolor(bColor)
      ckey:=TInkey(1)
      @ 12 , cellPos[stat] say transform(aTime[stat],"99:99")
      do case
         case nkey==K_ESC
              OkOut:=.t.
         case ckey ==K_LEFT
              stat:=if(stat=1,4,stat-1)
         case ckey ==K_RIGHT
              stat:=if(stat=4,1,stat+1)
         case ckey ==K_DOWN
              pPos:= 5
              OkOut:=.t.
         case ckey ==K_UP
              pPos:= 3
              OkOut:=.t.
         case Isdata(ckey) .or. ckey ==K_ENTER
              if Isdata(ckey); keyboard chr(ckey) ;endif
              @ 12,cellPos[stat] get mTemp pict "99:99"
              setcursor(1)
              read
              setcursor(0)
              if lastkey() != K_ESC
                 aTime[stat]:= mTemp
                 Updatestatus(stat)
                 PAYTRANS->(SaveEntries(MODE))
              else ; OkOut:=.t. ; endif
      endcase
      enddo
      Okout:=.f.
     case pPos==5
      Message("<PgUp/PgDn>-Change Status   <ENTER or Up/Dn>-Set Status   <ESC>-Abort")
      do while !OkOut
      mTmp:=1
      setcolor("W/N")
      @ 13,aPos[stat] say if(stat=4,if(aStatus[4]=2,aUtstat[2],;
      aOTstat[aStatus[5]]),aUTstat[aStatus[stat]])
      setcolor(bColor)
      ckey:=TInkey(1)
      @ 13,aPos[stat] say if(stat=4,if(aStatus[4]=2,aUtstat[2],;
      aOTstat[aStatus[5]]),aUTstat[aStatus[stat]])
      do case
         case nkey==K_ESC
              OkOut:=.t.
         case ckey ==K_LEFT
              stat:=if(stat=1,4,stat-1)
         case ckey ==K_RIGHT
              stat:=if(stat=4,1,stat+1)
         case ckey ==K_DOWN
              pPos:= 1
              OkOut:=.t.
         case ckey ==K_UP
              pPos:= 4
              OkOut:=.t.
         case ckey == K_PGDN
              aStatus[stat]:=if(aStatus[stat]=3,1,aStatus[stat]+1)
         case ckey == K_PGUP
              aStatus[stat]:=if(aStatus[stat]=1,3,aStatus[stat]-1)
      endcase
      enddo
      if lastKey() != K_ESC
       PAYTRANS->(SaveEntries(FULL))
      endif
      Okout:=.f.
  endcase
 enddo
 SetKey(K_F2)
 PAYMAST->(DbCloseArea())
 PAYTRANS->(DbCloseArea())
 ReadExit(lExit)
 CloseWindow(wBundy)
return nil

static function InitVar(nRec)
local temp,mMODE:=FULL
 Message("Searching records...")
 mName:={substr(PAYMAST->emp_Name,1,30),0}
 if empty(mName)
    mSlot:= {0,0}
    mName:= {space(30),0}
 end
 if !PAYTRANS->(DbSeek(nRec)); PAYTRANS->(DbGotop()) ; endif
 do while (PAYTRANS->Rec_No = nRec) .and. (PAYTRANS->Tr_date != mDate) .and.;
    PAYTRANS->(!eof())
    PAYTRANS->(DbSkip())
 enddo
 if nRec = PAYTRANS->REC_NO .and. mDate = PAYTRANS->TR_DATE
   aTime[1]  := PAYTRANS->Tr_AMin
   aTime[2]  := PAYTRANS->Tr_AMout
   aTime[3]  := PAYTRANS->Tr_PMin
   aTime[4]  := PAYTRANS->Tr_PMout
   temp:= val(PAYTRANS->Tr_AminUs)
   astatus[1]:= if((temp < 1).or.(temp >4), 4, temp)
   temp:= val(PAYTRANS->Tr_AmoutUs)
   astatus[2]:= if((temp < 1).or.(temp >4), 4, temp)
   temp:= val(PAYTRANS->Tr_PminUs)
   astatus[3]:= if((temp < 1).or.(temp >4), 4, temp)
   temp:= val(PAYTRANS->Tr_PmOutUs)
   astatus[4]:= if((temp < 1).or.(temp >4), 4, temp)
   temp:= val(PAYTRANS->Tr_PmOutOs)
   astatus[5]:= if((temp < 1).or.(temp >4), 4, temp)
 else
   aTime[1]:="00:00"
   aTime[2]:="00:00"
   aTime[3]:="00:00"
   aTime[4]:="00:00"
   aStatus[1]:= aStatus[2]:= aStatus[3]:= aStatus[4]:= aStatus[5]:= 4
   mMODE:=EMPTY
 endif
return mMODE

static function DispAll()
 @ 07,26 say mDate
 color:=setcolor("W/N")
 @ 09,36 say substr(PAYMAST->emp_name,1,30)
 @ 09,24 say transform(PAYMAST->emp_slot,"999")
 setcolor(color)
 @ 12,cellPos[1] say aTime[1]
 @ 12,cellPos[2] say aTime[2]
 @ 12,cellPos[3] say aTime[3]
 @ 12,cellPos[4] say aTime[4]
 @ 13,aPos[1]    say aUTstat[aStatus[1]]
 @ 13,aPos[2]    say aUTstat[aStatus[2]]
 @ 13,aPos[3]    say aUTstat[aStatus[3]]
 @ 13,aPos[4]    say if(aStatus[4]=2,aUTstat[2],aOTstat[aStatus[5]])
return nil

static function Updatestatus(st)
do case
   case st = 1
    aStatus[1]:=if(MinDiff("08:30",aTime[1])>0,2,3)
   case st = 2
    aStatus[2]:=3
   case st = 1
    aStatus[3]:=if(MinDiff(aTime[2],aTime[3])>60,2,3)
   case st = 4
    aStatus[4]:=if(MinDiff(aTime[4],"17:30")>0,2,3)
   case st = 5
    aStatus[5]:=if(MinDiff("17:30",aTime[4])>0,3,2)
endcase
@ 12,cellPos[st] say aTime[st]
@ 13,aPos[st] say if(st=4,if(aStatus[4]=2,aUTstat[2],aOTstat[aStatus[5]]),;
                   aUTstat[aStatus[st]])
return nil

static function SaveEntries(MODE)
  if !MODE
      AddRec(0)
      PAYTRANS->Rec_No :=PAYMAST->(RecNo())
      PAYTRANS->Tr_Date:= mDate
      PAYTRANS->Tr_Slot:=PAYMAST->Emp_Slot
  endif
  if (PAYTRANS->Tr_Date = mDate) .and. (PAYTRANS->Rec_No = PAYMAST->(RecNo()))
  RecLock(0)
   PAYTRANS->Tr_AMin   := aTime[1]
   PAYTRANS->Tr_AMout  := aTime[2]
   PAYTRANS->Tr_PMin   := aTime[3]
   PAYTRANS->Tr_PMout  := aTime[4]
   PAYTRANS->Tr_AminUs := str(aStatus[1])
   PAYTRANS->Tr_AmoutUs:= str(aStatus[2])
   PAYTRANS->Tr_PminUs := str(aStatus[3])
   PAYTRANS->Tr_Pmoutus:= str(aStatus[4])
   PAYTRANS->Tr_PmOutOs:= str(aStatus[5])
  DbUnlock(0)
  else
  ? "Error occurred... Pls. notify the programmer."
  Quit
  endif
return nil

static function TInkey(nsec)
local cblock,key
local lastsec:=seconds()
local lastcur,noy:=Row(),nox:=Col()
local lastcol:=setcolor("W+*/GR")
if nsec = 0
scchar:=savescreen(noy,nox,noy,nox)
char:=substr(scchar,1,1)
if char == " "
char:="Û"
endif
@ noy,nox say char
setpos(noy,nox)
endif
 setcolor("W/N")
 do while nextkey()=0
  lastcur:=setcursor(0)
    @ 07,48 say time()
  setcursor(lastcur)
    setpos(noy,nox)
 enddo
if nsec = 0
restscreen(noy,nox,noy,nox,scchar)
endif
 setColor(lastCol)
 key:=Inkey(0)
 cblock:=setkey(key)
 if cblock != nil
    eval(cblock,procname(1),procline(1),'Tinkey')
 endif
return key

static function readSlot(slot)
local sSlot:=substr(str(slot),1,3)
color:=setcolor("W/N")
 ctr:=1
 if empty(sSlot); sSlot:= "  0" ; endif
 row:=row()
 col:=col()
 @ row,col+1 say "   "
 @ row,col+1 say sSlot pict "999"
 setpos(row,col+1)
 cchar:=0
 do while cchar != K_ESC .and. cchar != K_ENTER .and. cchar!=K_DOWN .and.;
    cchar!=K_RIGHT .and. cchar != K_UP .and. ctr < 4
    cchar:=Tinkey(0)
   do case
      case cchar==K_BS
      if col() > col+1 .and. ctr > 1
         ctr--
         sSlot:=stuff(sSLot,ctr,1,"")
         sSlot:=padr(sSlot,3)
      endif
    case IsDigit(chr(cchar))
     if ctr== 1
        sSlot:=""
     endif
     sSlot:=stuff(sSlot,ctr,1,chr(cchar))
     sSlot:=substr(sSlot,1,3)
     ctr++
 endcase
     @ row,Col+1 say "   "
     @ row,Col+1 say sSlot
     setpos(row,Col+ctr)
enddo
@ row,col+1 say transform(val(sSlot),"999")
setcolor(color)
return {val(sSlot),cchar}

static function ReadName()
static sName
color:=setcolor("W/N")
 ctr:=1
 if empty(sName) ;sName:=space(30); endif
 row:=row()
 col:=col()
 @ row,col+1 say sName
 setpos(row,col+1)
 cchar:=0
do while cchar != K_ESC .and. cchar != K_ENTER .and. cchar!=K_DOWN .and.;
 cchar != K_LEFT .and. cchar != K_UP .and. ctr < 31
  cchar:=Tinkey(0)
 do case
    case cchar==K_BS
    if col() > col+1 .and. ctr > 1
     ctr--
     sName:=stuff(sName,ctr,1,"")
     sName:=padr(sName,30)
    endif
    case IsAlpha(chr(cchar)) .or. cchar=32
     sName:=stuff(sName,ctr,1,Upper(chr(cchar)))
     sName:=substr(sName,1,30)
     ctr++
 endcase
     @ row,Col+1 say sName
     setpos(row,Col+ctr)
enddo
@ row,col+1 say sName
setcolor(color)
return {sName,cchar}

static function SearchEmp(cEmployee)
local nRecno := PAYMAST->(recno())
        cEmployee := alltrim(cEmployee)
        if !PAYMAST->(Dbseek(cEmployee))
           Message("Name not found...")
           tone(100,3)
           tone(15,2)
           PAYMAST->(Dbgoto(nRecno))
           color:=setcolor("W/N")
           @ 09,36 say substr(PAYMAST->emp_name,1,30)
           @ 09,24 say transform(PAYMAST->emp_slot,"999")
           setcolor(color)
        endif
return PAYMAST->(found())

static function SbySlot(nSlot)
local lfound := .f.
local nRecno := PAYMAST->(recno())
        PAYMAST->(DbSetOrder(2))
        PAYMAST->(Dbseek(nSlot))
          do while !empty(PAYMAST->emp_out) .and. (nSlot=PAYMAST->emp_slot) .and.;
           PAYMAST->(!eof())
            PAYMAST->(DbSkip())
          enddo
        if (PAYMAST->emp_slot = nSLot )
           lFound:=.t.
        else
           Message("Slot not in use....")
           tone(100,3)
           tone(15,2)
           PAYMAST->(Dbgoto(nRecno))
        endif
        PAYMAST->(DbSetOrder(1))
return lfound

//eof---------------------->