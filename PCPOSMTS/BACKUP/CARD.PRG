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

memvar getlist

static xGetVar[2]
STATIC cPrompts := { ;
   "   Bank Code",;
   "   Bank Name" }

function do_card()
local wVendor, nkey
   if netUse("CC",DB_SHARED,NUM_SECONDS)
      set index to CC_001
   endif
   wVendor := OpenWindow(06,15,10,60,"Credit Card File")
   if CC->(reccount())==0 ; Card_Form(APPEND_MODE) ; endif
   if lastKey()!=K_ESC
      do while (nkey!=K_ESC)
         Card_Form(VIEW_MODE)
         nkey:=inkey(0)
         do case
            case nkey==K_DOWN
               CC->(Dbskip())
               if CC->(eof())
                  CC->(Dbgobottom())
                  tone(100,3)
                  Message("End of file reached....")
                  inkey(1)
               endif
            case nKey==K_UP
               CC->(Dbskip(-1))
               if CC->(bof())
                  CC->(Dbgotop())
                  tone(100,3)
                  Message("Beginning of file reached....")
                  inkey(1)
               endif
            case nKey==K_CTRL_PGDN
               CC->(Dbskip(NUM_TO_SKIP))
               if CC->(eof())
                  CC->(Dbgobottom())
                  tone(100,3)
                  Message("End of file reached....")
                  inkey(1)
               endif
            case nKey==K_CTRL_PGUP
               CC->(Dbskip(-NUM_TO_SKIP))
               if CC->(bof())
                  CC->(Dbgotop())
                  tone(100,3)
                  Message("Beginning of file reached....")
                  inkey(1)
               endif
            case nKey==K_END
               CC->(Dbgobottom())
                  Message("Moving to end of file....")
                  inkey(1)
            case nKey==K_HOME
               CC->(Dbgotop())
                  Message("Moving to beginning of file....")
                  inkey(1)
            case nKey==K_F2
                  Card_Form(APPEND_MODE)
            case nKey==K_F3
                  Card_Form(EDIT_MODE)
            case nKey==K_F4
             if CC->(Deleted())
               Message("Press ENTER to Undelete record, ESC to abort.")
               if inkey(0)==K_ENTER
                  Message("Undeleting current record....")
                  CC->(RecLock(0))
                  CC->(DbRecall())
                  CC->(Dbunlock())
               endif
             else
                Message("Press ENTER to delete record, ESC to abort.")
               if inkey(0)==K_ENTER
                  Message("Deleting current record....")
                  CC->(RecLock(0))
                  CC->(Dbdelete())
                  CC->(Dbunlock())
               endif
             endif
            case nKey==K_F5
               CC->(Search_Crd("Credit Card",4))
            case nKey==K_F6
         endcase
      enddo
   endif
   Message("Closing Databases....")
   CC->(DbCloseArea())
   CloseWindow(wVendor)
return nil

static function Card_Form(nMode)
local clr, crs
   tone(300,1)
   Card_Init(nMode)
   MsgBar(BAR)
   clr := setcolor(TITLE_ATTR)
   if CC->(Deleted()) ; @ 06,35 say "<deleted>"
   else ; @ 06,35 say "         " ; endif
   if nMode==APPEND_MODE
       @ 06, 50 say "< New >   "
   else
       @ 06, 50 say "Rec #"+transform(CC->(recno()),"9999")
   endif
   setcolor( clr )
   @ 08,      16 say  cPrompts[1]  get xGetVar[1] PICT "@K 9999" VALID VldtCard(nMode)
   @ row()+1, 16 say  cPrompts[2]  get xGetVar[2] PICT "@! "+repl("X",20) VALID !empty(xGetVar[2])
   if (nMode==APPEND_MODE) .or. (nMode==EDIT_MODE)
      crs := setcursor(SC_NORMAL)
      read
      if lastkey()!=K_ESC
         Card_Save(nMode)
      endif
      setcursor( crs )
   else
      clear gets
   endif
return nil

static function VldtCard(Mode)
local lRetVal:= .t.,nRecno := CC->(RecNo())
 if empty(xGetVar[1])
    return .f.
 endif
 xGetVar[1] :=  padl( alltrim(xGetVar[1]),4,"0")
 if (Mode == APPEND_MODE) .or. (Mode == EDIT_MODE .and. xGetVar[1] != CC->CC_001)
   CC->(DbSeek(xGetVar[1]))
   if (CC->(found()))
    lRetVal := .f.
    Message(" Bank Card code : "+xGetVar[1]+" already exist...")
    Tone(300,3)
    Tone(500,3)
    Inkey(3)
    Tone(200,2)
   endif
   CC->(DbGoto(nRecNo))
   MsgBar(BAR)
 endif
return lRetVal


static function Card_Init(nMode)
   if nMode==APPEND_MODE
      xGetVar[ 1] := SPACE(4)
      xGetVar[ 2] := SPACE(20)
   else
      xGetVar[1]  := CC->CC_001
      xGetVar[2]  := CC->CC_002
   endif
return nil

static function Card_Save(nMode)
   Message("Saving entries...")
   if nMode==APPEND_MODE
      CC->(FilLock(0))
      CC->(Dbappend())
      CC->(DbUnLock())
   endif
   CC->(RecLock(0))
   CC->CC_001 := xGetVar[ 1]
   CC->CC_002 := xGetVar[ 2]
   CC->(DbUnlock())
   CC->(DbCommit())
return nil

function Search_Crd(cTitle,nlen)
local wSearch, nRecno := Recno()
static cString 
     if empty(cString)
        cString := space(nLen)
     else
        cString := padl(cString,nlen)
     endif      
     wSearch := openwindow(09,23,13,57,"Search "+cTitle)
     @ 11, 25 say "Enter " + cTitle + " Code to search"
     @ 12, 25 get cString pict "@K "+repl("9",nLen)
     setcursor(SC_NORMAL)
     read
     setcursor(SC_NONE)
     closewindow(wSearch)
     
     if lastkey() != K_ESC
        cString := padl(alltrim(cString),nLen,"0")
        if !Dbseek(cString)
           Message("Code " +cString+ " not found...")
           tone(100,1.5)
           inkey(2)           
           Dbgoto(nRecno)
        else
           Message(" Found ! ")
           HEYTHERE()   
        endif
     endif
return nil

//end-of-file
