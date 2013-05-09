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
   "    Brand Code",;
   "    Brand Name" }
   
function do_brand()
local wBrand, nkey
   if netUse("BR",DB_SHARED,NUM_SECONDS)
      set index to BR_001,BR_002
   endif
   wBrand := OpenWindow(04,06,10,70,"Brand File")
   if br->(reccount())==0 ; Brand_Form(APPEND_MODE) ; endif
   if lastKey()!=K_ESC
      do while (nkey!=K_ESC)
         Brand_Form(VIEW_MODE)
         nkey:=inkey(0)
         do case
            case nkey==K_DOWN
               br->(Dbskip())
               if br->(eof())
                  br->(Dbgobottom())
                  tone(100,3)
                  Message("End of file reached....")
                  inkey(1)
               endif
            case nKey==K_UP
               br->(Dbskip(-1))
               if br->(bof())
                  br->(Dbgotop())
                  tone(100,3)
                  Message("Beginning of file reached....")
                  inkey(1)
               endif
            case nKey==K_CTRL_PGDN
               br->(Dbskip(NUM_TO_SKIP))
               if br->(eof())
                  br->(Dbgobottom())
                  tone(100,3)
                  Message("End of file reached....")
                  inkey(1)
               endif
            case nKey==K_CTRL_PGUP
               br->(Dbskip(-NUM_TO_SKIP))
               if br->(bof())
                  br->(Dbgotop())
                  tone(100,3)
                  Message("Beginning of file reached....")
                  inkey(1)
               endif
            case nKey==K_END
               br->(Dbgobottom())
                  Message("Moving to end of file....")
                  inkey(1)
            case nKey==K_HOME
               br->(Dbgotop())
                  Message("Moving to beginning of file....")
                  inkey(1)
            case nKey==K_F2
                  Brand_Form(APPEND_MODE)
            case nKey==K_F3
                  Brand_Form(EDIT_MODE)
            case nKey==K_F4
             if br->(Deleted())
               Message("Press ENTER to Undelete record, ESC to abort.")
               if inkey(0)==K_ENTER
                  Message("Undeleting current record....")
                  br->(RecLock(0))
                  br->(DbRecall())
//                  br->br_013 := 4
                  br->(Dbunlock())
               endif
             else
                Message("Press ENTER to delete record, ESC to abort.")
               if inkey(0)==K_ENTER
                  Message("Deleting current record....")
                  br->(RecLock(0))
                  br->(Dbdelete())
//                  br->br_013 := 3
                  br->(Dbunlock())
               endif
             endif
            case nKey==K_F5
               br->(dbsetorderto(2))
               br->(Search_Desc("Brand Name",30))
               br->(dbsetorderto(1))
            case nKey==K_F6
         endcase
      enddo
   endif
   Message("Closing Databases....")
   br->(DbCloseArea())
   CloseWindow(wBrand)
return nil


static function Search_Desc(cTitle,nlen)
local wSearch
static cString
     if empty(cString)
        cString := space(nLen)
     else
        cString := padl(cString,nlen)
     endif      
     wSearch := openwindow(09,23,13,57,"Search "+cTitle)
     @ 11, 25 say "Enter " + cTitle + " to search"
     @ 12, 25 get cString pict "@K! "+repl("X",nLen)
     setcursor(SC_NORMAL)
     read
     setcursor(SC_NONE)
     closewindow(wSearch)
     
     if lastkey() != K_ESC
        if !Dbseek(cString)
           Message("Descriptor " +alltrim(cString)+ " not found...")
           tone(100,1.5)
           inkey(2)
        else
           Message(" Found ! ")
           HEYTHERE()   
        endif
     endif
return nil

static function Brand_Form(nMode)
local clr, crs
   tone(300,1)
   Brand_Init(nMode)
   MsgBar(BAR)
   clr := setcolor(TITLE_ATTR)
   if br->(Deleted()) ; @ 04,35 say "<deleted>"
   else ; @ 04,35 say "         " ; endif
   if nMode==APPEND_MODE
       @ 04, 62 say "< New >   "
   else
       @ 04, 62 say "Rec #"+transform(br->(recno()),"@B 9999")
   endif
   setcolor( clr )
   @ 07,      08 say  cPrompts[1]  get xGetVar[1] PICT "@K 9999" VALID VldtBrdn(nMode)
   @ row()+1, 08 say  cPrompts[2]  get xGetVar[2] PICT "@S20! " valid checkbr(nMode,xGetVar[2])

   if (nMode==APPEND_MODE) .or. (nMode==EDIT_MODE)
      crs := setcursor(SC_NORMAL)
      read
      if lastkey()!=K_ESC
         Brand_Save(nMode)
      endif
      setcursor( crs )
   else
      clear gets
   endif
return nil

static function VldtBrdn(Mode)
local lRetVal:= .t.,nRecno := br->(RecNo())
 if empty(xGetVar[1])
    return .f.
 endif
 xGetVar[1] :=  padl( alltrim(xGetVar[1]),4,"0")
 if (Mode == APPEND_MODE) .or. (Mode == EDIT_MODE .and. xGetVar[1] != br->br_001)
   br->(DbSeek(xGetVar[1]))
   if (br->(found()))
    lRetVal := .f.
    Message(" Brand Code : "+xGetVar[1]+" already exist...")
    Tone(300,3)
    Tone(500,3)
    Inkey(3)
    Tone(200,2)
   endif
   br->(DbGoto(nRecNo))
   MsgBar(BAR)
 endif
return lRetVal

static function Brand_Init(nMode)
   if nMode==APPEND_MODE
      xGetVar[ 1] := SPACE(4)
      xGetVar[ 2] := SPACE(30)

   else
      xGetVar[1]  := br->br_001
      xGetVar[2]  := br->br_002
                        
   endif
return nil

static function Brand_Save(nMode)
   Message("Saving entries...")
   if nMode==APPEND_MODE
      br->(FilLock(0))
      br->(Dbappend())
//      br->br_013 := 1
      br->(DbUnLock())
   else
      br->(RecLock(0)) 
//      br->br_013 := 2
      br->(DbUnlock())
   endif
   
   br->(RecLock(0))
   br->br_001 := xGetVar[ 1]
   br->br_002 := xGetVar[ 2]
      
   
   br->(DbUnlock())
   br->(DbCommit())
return nil



static function Checkbr(nMode,nName)
local nRecno := br->(RecNo()), lOkCode := .T.,crs
br->(dbsetorderto(2))

  if nMode == APPEND_MODE
br->(DbSeek(nName))
      do while ( nName==br->br_002 .and. (br->(!Eof())) .and. (lOkCode))
         *if !(CASHIER->(Deleted()))
          crs := setcursor( SC_NONE )
          Message(" Brand Name Already in use....")
          tone(500,4)
          setcursor(crs)
          lOkCode := .f.
         *endif
      enddo
 endif
br->(dbsetorderto(1))
  br->(DbGoto(nRecNo))
return lOkCode

//end-of-file
