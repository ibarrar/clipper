*** CLASS.PRG ***

#include "box.ch"
#include "its.ch"
#include "inkey.ch"
#include "Janus.ch"
#include "aChoice.ch"
#include "setcurs.ch"

#ifdef COLOR_STAT
#define BAR "F2-Add   F3-Edit   F4-[Del/Undel]   F5-Search   ESC-Abort"
#else
#define BAR "F2-Add   F3-Edit   F4-[Del/Undel]   F5-Search   ESC-Abort"
#endif

memvar getlist,aScrollBar

static aTable
static xGetVar[5]
static aChoices_ := {}
static searchstr := ""
static nLen,nInitial
static y1,r2

#ifdef CLASS_LINK

function do_Class()
local wWindow, nkey
#ifdef FM_CLASS     
   if NetUse("FM",DB_SHARED,NUM_SECONDS)
      set index to FM
   endif
#endif
   if NetUse("DP",DB_SHARED,NUM_SECONDS)
      set index to DP_001
   endif
   if NetUse("CL",DB_SHARED,NUM_SECONDS)
      set index to CL_001
   endif
   wWindow := OpenWindow(04,06,12,73,"Class File")
   @ 10,8 say repl("-",64)
   if CL->(reccount())==0 ; Class_Form(APPEND_MODE) ; endif
   if lastKey()!=K_ESC
      do while (nkey!=K_ESC)
         Class_Form(VIEW_MODE)
         nkey:=inkey(0)
         do case
            case nkey==K_DOWN
               CL->(Dbskip())
               if CL->(eof())
                  CL->(Dbgobottom())
                  tone(100,3)
                  Message("End of file reached....")
                  inkey(1)
               endif
            case nKey==K_UP
               CL->(Dbskip(-1))
               if CL->(bof())
                  CL->(Dbgotop())
                  tone(100,3)
                  Message("Beginning of file reached....")
                  inkey(1)
               endif
            case nKey==K_CTRL_PGDN
               CL->(Dbskip(NUM_TO_SKIP))
               if CL->(eof())
                  CL->(Dbgobottom())
                  tone(100,3)
                  Message("End of file reached....")
                  inkey(1)
               endif
            case nKey==K_CTRL_PGUP
               CL->(Dbskip(-NUM_TO_SKIP))
               if CL->(bof())
                  CL->(Dbgotop())
                  tone(100,3)
                  Message("Beginning of file reached....")
                  inkey(1)
               endif
            case nKey==K_END
               CL->(Dbgobottom())
                  Message("Moving to end of file....")
                  inkey(1)
            case nKey==K_HOME
               CL->(Dbgotop())
                  Message("Moving to beginning of file....")
                  inkey(1)
            case nKey==K_F2
                  Class_Form(APPEND_MODE)
            case nKey==K_F3
                  Class_Form(EDIT_MODE)
            case nKey==K_F4
             if CL->(Deleted())
               Message("Press ENTER to Undelete record, ESC to abort.")
               if inkey(0)==K_ENTER
                  Message("Undeleting current record....")
                  CL->(RecLock(0))
                  CL->(DbRecall())
                  CL->CL_006 := 4
                  CL->(Dbunlock())
#ifdef FM_CLASS     
                  FM->(FilLock())
                  FM->(DbAppend())
                  FM->TRANSNO := FMNext()
                  FM->OP_CODE := "01" //ADD
                  FM->FILE_ID := "04" // Cashier ID 04 class
                  FM->RECDATA := GetData()
                  FM->POSTDATE:= Date()
                  FM->POSTSTAT:= 0
                  FM->(DbUnLock())                  
#endif            
               endif
             else
                Message("Press ENTER to delete record, ESC to abort.")
               if inkey(0)==K_ENTER
                  Message("Deleting current record....")
                  CL->(RecLock(0))
                  CL->(Dbdelete())
                  CL->CL_006 := 3
                  CL->(Dbunlock())
#ifdef FM_CLASS                       
                  FM->(FilLock())
                  FM->(DbAppend())
                  FM->TRANSNO := FMNext()
                  FM->OP_CODE := "03" //Delete
                  FM->FILE_ID := "04" // Cashier ID
                  FM->RECDATA := GetData()
                  FM->POSTDATE:= Date()
                  FM->POSTSTAT:= 0
                  FM->(DbUnLock())                  
#endif            
               endif
             endif
            case nKey==K_F5
               CL->(Search_Form("Class",4))
         endcase
      enddo
   endif
   Message("Closing Databases....")
   CL->(DbCloseArea())
   DP->(DbCloseArea())
#ifdef FM_CLASS        
   FM->(DbCloseArea())
#endif
   aChoices_ := {}
   CloseWindow(wWindow)
return nil

static function Class_Form(nMode)
local clr, crs
   tone(300,1)
   Class_Init(nMode)
   MsgBar(BAR)
   clr := setcolor(TITLE_ATTR)
   if CL->(Deleted()) ; @ 04,35 say "<deleted>"
   else ; @ 04,35 say "         " ; endif
   if nMode==APPEND_MODE
       @ 04, 62 say "< New >   "
   else
       @ 04, 62 say "Rec #"+transform(CL->(recno()),"9999")
   endif
   setcolor( clr )
   @ 06, 18 say  "Department Link   " get xGetVar[3] PICT "@K 99" WHEN VldtDpLnk() VALID PostVldtDp()
   @ row()+1, 18 say  "Class Code        " get xGetVar[1] PICT "@K 9999" VALID VldtClass(nMode)
   @ row()+1, 18 say  "Class Description " get xGetVar[2] PICT "@K! "+repl("X",30) VALID !empty(xGetVar[2])
   @ row()+1, 18 say  "Open to Buy Budget" get xGetVar[4] PICT "@R 99,999,999.99" VALID (ChkAmt(xGetVar[4],nMode))  //!empty(xGetVar[4])

   @ 11, 15 say    "Open to Buy Available" get xGetVar[4] PICT "@R 99,999,999.99" WHEN .f.
   if (nMode==APPEND_MODE) .or. (nMode==EDIT_MODE)
      crs := setcursor(SC_NORMAL)
      read
      if lastkey()!=K_ESC
         Class_Save(nMode)
      endif
      setcursor( crs )
   else
      clear gets
   endif
return nil

static function ChkAmt(GetVar,nMode)
local lRetval := .t., nAmt := 0, ClAmt := 0
local nRecno := CL->(RecNo()), prevamt := 0

prevamt := Cl->CL_004

/* if empty(xGetVar[4])
   return .f. 
endif*/

if DP->(DbSeek(xGetvar[3]))
   nAmt := DP->DP_004
endif

CL->(DbGotop())
Do While CL->(!Eof())
   if xGetvar[3] == CL->CL_003
      ClAmt += CL->CL_004   
   endif
CL->(DbSkip())   
Enddo   
if nMode != APPEND_MODE
   ClAmt := ClAmt - prevamt
endif
  
clAmt := ClAmt + Getvar

if ClAmt > nAmt
   Message(" Open to Buy Budget is greater than Department's Amount Limit")
   Tone(300,3)
   Tone(500,3)
   Inkey(3)
   Tone(200,2)   
   lRetval := .f.
endif
CL->(DbGoto(nRecNo))
MsgBar(BAR)

return lRetVal

static function VldtClass(Mode)
local lRetVal:= .t.,nRecno := CL->(RecNo())
 if empty(xGetVar[1])
    return .f.
 endif
 xGetVar[1] := xGetvar[3] + substr(xGetVar[1],3,2)
 if substr(xGetVar[1],3,2) == "  "
    Message(" InSufficient No. of digits for Class Code  ")
    Tone(300,3)
    Tone(500,3)
    Inkey(3)
    return .f.
 endif
 
 // xGetVar[1] :=  padl( alltrim(xGetVar[1]),4,"0")

 if (Mode==APPEND_MODE) .or. (Mode==EDIT_MODE .and. xGetVar[1] != CL->CL_001 )
   CL->(DbSeek(xGetVar[1]))
   if (CL->(found()))
    lRetVal := .f.
    Message(" Class code : "+xGetVar[1]+" already exist...")
    Tone(300,3)
    Tone(500,3)
    Inkey(3)
    Tone(200,2)
   endif
   CL->(DbGoto(nRecNo))
   MsgBar(BAR)
 endif
return lRetVal

static function VldtDpLnk()
local lVal:= .t.,n:=0

 if empty(aChoices_)
   DP->(DbGotop())
   while DP->(!eof()) 
      if DP->(!Deleted())
       aAdd(aChoices_," "+DP->DP_001+" "+DP->DP_002+" ")
      endif
      DP->(DbSkip())
   enddo
 endif  
 
 if ((n:=LookUp( 08,48, aChoices_,"Department Link",xGetVar[3])) != 0)
    xGetVar[3] := subs(aChoices_[n],2,2)
    xGetVar[1] := xGetVar[3] + subs(xGetVar[1],2,2)
    lVal :=  .f.
 endif
return lVal

static function PostVldtDp()
local lVal := .t.
 if empty(xGetVar[3])
    return .f.
 endif
 xGetVar[3] :=  padl( alltrim(xGetVar[3]),2,"0")
 DP->(DbGotop())
 if !DP->(DbSeek(xGetVar[3]))
   lVal := .f.
   Message(" Department Link Number "+xGetVar[3]+" does not exist.... ")
   Tone(500,3)
   Inkey(1)
   Tone(200,2)
 endif
  MsgBar(BAR)
return lVal

static function Class_Init(nMode)
   if nMode==APPEND_MODE
      xGetVar[1] := SPACE(4)
      xGetVar[2] := SPACE(30)
      xGetVar[3] := SPACE(2)
      xGetVar[4] := 0
      xGetVar[5] := 0
   else
      xGetVar[1]  := CL->CL_001
      xGetVar[2]  := CL->CL_002
      xGetVar[3]  := CL->CL_003
      xGetVar[4]  := CL->CL_004
      xGetVar[5]  := CL->CL_005
   endif
return nil

static function Class_Save(nMode)
local cKeyCode
   Message("Saving entries...")
   if nMode==APPEND_MODE
      CL->(FilLock(0))
      CL->(Dbappend())
      CL->CL_006 := 1
      CL->(DbUnLock())
   else
      CL->(RecLock(0))
      CL->CL_006 := 2
      CL->(DbUnLock())   
   endif
   CL->(RecLock(0))
   CL->CL_001 := xGetVar[ 1]
   CL->CL_002 := xGetVar[ 2]
   CL->CL_003 := XGetVar[ 3]
   CL->CL_004 := XGetVar[ 4]
   CL->CL_005 := XGetVar[ 4]
   CL->(DbUnlock())
   CL->(DbCommit())
#ifdef FM_CLASS
   FM->(FilLock())
   FM->(DbAppend())
   FM->TRANSNO := FMNext()
   FM->OP_CODE := if (APPEND_MODE==nMode,"01","02") // ADD,OVERWRITE
   FM->FILE_ID := "04" // Cashier ID
   FM->RECDATA := GetData()
   FM->POSTDATE:= Date()
   FM->POSTSTAT:= 0
   FM->(DbUnLock())
#endif
      
return nil

static function GetData()
local cData
      cData := CL->CL_001   // "C"  6
      cData += CL->CL_002   // "C" 20
      cData += CL->CL_003   // "C"  2
      cData += padl(alltrim(str(int(CL->CL_004*100))),10,"0") // 10
      cData += padl(alltrim(str(int(CL->CL_005*100))),10,"0") // 10
      cData += repl("0",10)
return pad(cData,244,"0")

#endif

function LookUp(row,col,aAray_,cTitle,cString)
local RetVal:= nil,wLookUp,n:=0,nlong:=0
local r1:=row,y2,cColor := if(IsColor(),"W+/G+,W+/GR","N/W,W+/N")
local oCol,cSearch:=cString,nStrLen := if(empty(cString),0,len(cString))

 y1:=col
 aTable := aAray_
 cTitle := alltrim(cTitle)
 Message(" Choose " +cTitle+ " ...")
 if empty(aTable)
    Message(" No Available "+cTitle+" Yet... ")
    Tone(300,2)
    Tone(500,2)
    Tone(700,3)
 else
    r2:= r1+1+len(aTable)
    if r2 > (maxrow()-1)
       r2 := (maxrow()-1)
    endif  
    nlong := 0
    aeval(aTable,{|s| nlong := max(len(s),nlong)})
    y2:= y1+1+nlong
    if y2 > maxcol()-1
      y2 := maxcol()-1
    endif  
    wLookUp :=  savescreen(r1,y1,r2+1,y2+1)
    Shadow(r1,y1,r2,y2)
    oCol := SetColor(cColor)
    @ r1, y1, r2, y2 Box B_DOUBLE + " "
    nLen := y2-y1
    if Len(cTitle) > nLen
      cTitle := substr(cTitle,1,nLen)
    endif  
    @ r1,y1+((nLen-len(cTitle))*0.5) Say cTitle

    nInitial := aScan(aAray_,{ |a_| subs(a_,2,nStrLen) = cString  } )
    if empty(nInitial)
       nInitial := 1
    endif   
    
    aScrollBar := ScrollBarNew(r1,y2,r2,cColor,nInitial)
    ScrollBarDisplay(aScrollBar)
    ScrollBarUpdate(aScrollBar,nInitial,Len(aTable),.t.)

    while .t.
     n:=aChoice(r1+1,y1+1,r2-1,y2-1,aTable,,"aChoiceHandle",nInitial,1)
     if lastkey() == K_ENTER .or. lastkey() == K_ESC
        exit
     endif
    enddo 
    
    RestScreen(r1,y1,r2+1,y2+1,wLookUp)
    SetColor(oCol)
 endif

return n 

function aChoiceHandle(nMode,nCurElem,nRelPos)
local nRetVal,nKey,telem
   ScrollBarUpdate(aScrollBar,nCurElem,Len(aTable),.F.)
   do case
      case nMode==AC_EXCEPT            // Is key stroke used by AChoice?
         nKey:=LastKey()               // No -- get last key pressed.
         do case
            case nKey==K_ESC           // Esc key pressed?
               searchstr := ""
               nRetVal:=AC_ABORT       // Yes -- abort menu selection.
            case nKey==K_ENTER         // Enter key pressed?
               searchstr := ""
               nRetVal:=AC_SELECT      // Yes -- make selection.
            case IsAlpha(chr(nKey)) .or. IsDigit(chr(nKey))
               searchstr += upper(chr(nKey))
               telem := ascan2(aTable,searchstr)   
               nInitial := if(telem ==0,nCurElem,telem)
               @ r2,y1+1 say "[" +padr(searchstr,nLen-4)+ "]"
               nRetVal := AC_ABORT
            case nKey == K_BS .or. nKey == K_LEFT
               if len(searchstr) > 0
                  searchstr := subs(searchstr,1,len(searchstr)-1)
                  telem := ascan2(aTable,searchstr)
                  nInitial := if(telem ==0, nCurElem, telem)
               endif
               @ r2,y1+1 say if(len(searchstr) == 0,;
                             replicate(chr(205),nLen-2),;
                             "[" + padr(searchstr,nLen-4)+ "]")
               nRetVal := AC_ABORT                                      
            otherwise 
               // Other keys pressed.
               nRetVal:=AC_CONT        // Continue selection.               
         endcase
      otherwise                        // Keystoke used by Achoice.
         nRetVal:=AC_CONT              // ....continue selection.
   endcase
return nRetVal

function aScan2(array,value)
return ascan(Array, { |a| value $ a  }, 1)


//end-of-file
