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

static xGetVar[12+4]
STATIC cPrompts := { ;
   " Supplier Code",;
   "    Supplier 1",;
   "       Address",;
   "     Telephone",;
   "       Fax No.",;
   "Contact Person",;
   " Tax ID Number",;
   "    VAT Number",;
   "  Credit Terms",;
   " Supplier Type",;
   " Item Supplied",;
   "       Percent",;
   "    Supplier 2",;
   "    Supplier 3",;
   "    Supplier 4",;
   "    Supplier 5"}

function do_vendor()
local wVendor, nkey
   if netUse("V",DB_SHARED,NUM_SECONDS)
      set index to V_001
   endif
   wVendor := OpenWindow(04,06,13+4,73,"Supplier File")
   if V->(reccount())==0 ; Vendor_Form(APPEND_MODE) ; endif
   if lastKey()!=K_ESC
      do while (nkey!=K_ESC)
         Vendor_Form(VIEW_MODE)
         nkey:=inkey(0)
         do case
            case nkey==K_DOWN
               V->(Dbskip())
               if V->(eof())
                  V->(Dbgobottom())
                  tone(100,3)
                  Message("End of file reached....")
                  inkey(1)
               endif
            case nKey==K_UP
               V->(Dbskip(-1))
               if V->(bof())
                  V->(Dbgotop())
                  tone(100,3)
                  Message("Beginning of file reached....")
                  inkey(1)
               endif
            case nKey==K_CTRL_PGDN
               V->(Dbskip(NUM_TO_SKIP))
               if V->(eof())
                  V->(Dbgobottom())
                  tone(100,3)
                  Message("End of file reached....")
                  inkey(1)
               endif
            case nKey==K_CTRL_PGUP
               V->(Dbskip(-NUM_TO_SKIP))
               if V->(bof())
                  V->(Dbgotop())
                  tone(100,3)
                  Message("Beginning of file reached....")
                  inkey(1)
               endif
            case nKey==K_END
               V->(Dbgobottom())
                  Message("Moving to end of file....")
                  inkey(1)
            case nKey==K_HOME
               V->(Dbgotop())
                  Message("Moving to beginning of file....")
                  inkey(1)
            case nKey==K_F2
                  Vendor_Form(APPEND_MODE)
            case nKey==K_F3
                  Vendor_Form(EDIT_MODE)
            case nKey==K_F4
             if V->(Deleted())
               Message("Press ENTER to Undelete record, ESC to abort.")
               if inkey(0)==K_ENTER
                  Message("Undeleting current record....")
                  V->(RecLock(0))
                  V->(DbRecall())
                  V->V_013 := 4
                  V->(Dbunlock())
               endif
             else
                Message("Press ENTER to delete record, ESC to abort.")
               if inkey(0)==K_ENTER
                  Message("Deleting current record....")
                  V->(RecLock(0))
                  V->(Dbdelete())
                  V->V_013 := 3
                  V->(Dbunlock())
               endif
             endif
            case nKey==K_F5
               V->(Search_Form("Supplier",3))
            case nKey==K_F6
         endcase
      enddo
   endif
   Message("Closing Databases....")
   V->(DbCloseArea())
   CloseWindow(wVendor)
return nil

static function Vendor_Form(nMode)
local clr, crs
   tone(300,1)
   Vendor_Init(nMode)
   MsgBar(BAR)
   clr := setcolor(TITLE_ATTR)
   if V->(Deleted()) ; @ 04,35 say "<deleted>"
   else ; @ 04,35 say "         " ; endif
   if nMode==APPEND_MODE
       @ 04, 62 say "< New >   "
   else
       @ 04, 62 say "Rec #"+transform(V->(recno()),"@B 9999")
   endif
   setcolor( clr )
   @ 06,      08 say  cPrompts[1]  get xGetVar[1] PICT "@K 999" VALID VldtVen(nMode)
   @ row()+1, 08 say  cPrompts[2]  get xGetVar[2] PICT "@S20! " 

   @ row()+1, 08 say  cPrompts[13]  get xGetVar[13] PICT "@S20! " 
   @ row()+1, 08 say  cPrompts[14]  get xGetVar[14] PICT "@S20! " 
   @ row()+1, 08 say  cPrompts[15]  get xGetVar[15] PICT "@S20! " 
   @ row()+1, 08 say  cPrompts[16]  get xGetVar[16] PICT "@S20! " 


   @ row()+1, 08 say  cPrompts[11]  get xGetVar[11] PICT "@! "+repl("X",20) // VALID !empty(xGetVar[11])
   @ row()+1, 08 say  cPrompts[6]  get xGetVar[6] PICT "@! "+repl("X",20) //VALID !empty(xGetVar[6])
   @ row()+1, 08 say  cPrompts[3]  get xGetVar[3] PICT "@S25! " //VALID !empty(xGetVar[3])
   @ row()+1, 08 say  cPrompts[4]  get xGetVar[4] PICT "@S30! " //VALID !empty(xGetVar[4])
   @ row()+1, 08 say  cPrompts[5]  get xGetVar[5] PICT "@R 9999999999" //VALID !empty(xGetVar[5])

   @ 06,      45 say  cPrompts[7]  get xGetVar[7] PICT "@! "+repl("X",12) VALID VldtTin(nMode)
   @ row()+1, 45 say  cPrompts[8]  get xGetVar[8] PICT "@! "+repl("X",12) VALID VldtVat(nMode)
   @ row()+1, 45 say  cPrompts[10] get xGetVar[10] PICT "9" WHEN VldtType() RANGE 1,LEN_VENDOR_TYPE
   @ row()+1, 45 say  cPrompts[9]  get xGetVar[9] PICT "9" WHEN VldtTerms() RANGE 1,LEN_ARRAY_ITEMS
   @ row()+1, 45 say  cPrompts[12]  get xGetVar[12] PICT "99.99" // WHEN VldtTerms() RANGE 1,LEN_ARRAY_ITEMS
   
   
   if (nMode==APPEND_MODE) .or. (nMode==EDIT_MODE)
      crs := setcursor(SC_NORMAL)
      read
      if lastkey()!=K_ESC
         Vendor_Save(nMode)
      endif
      setcursor( crs )
   else
      clear gets
   endif
return nil

static function VldtVen(Mode)
local lRetVal:= .t.,nRecno := V->(RecNo())
 if empty(xGetVar[1])
    return .f.
 endif
 xGetVar[1] :=  padl( alltrim(xGetVar[1]),3,"0")
 if (Mode == APPEND_MODE) .or. (Mode == EDIT_MODE .and. xGetVar[1] != V->V_001)
   V->(DbSeek(xGetVar[1]))
   if (V->(found()))
    lRetVal := .f.
    Message(" Supplier code : "+xGetVar[1]+" already exist...")
    Tone(300,3)
    Tone(500,3)
    Inkey(3)
    Tone(200,2)
   endif
   V->(DbGoto(nRecNo))
   MsgBar(BAR)
 endif
return lRetVal

static function VldtTin(Mode)
local nRecno := V->(Recno())
local lRetVal := .t.
 if empty(xGetVar[7])
    return .t.
 endif

 if (Mode == APPEND_MODE) .or. (Mode == EDIT_MODE .and. xGetVar[7] != V->V_007)
   V->(DbGotop())
   while V->(!Eof())
    if V->V_007 == xGetVar[7]
      lRetVal := .f.
      Message(" Duplicate in TIN : "+xGetVar[7] )
      Tone(300,3)
      Tone(500,3)
      Inkey(3)
      Tone(200,2)
      exit
    endif
    V->(DbSkip())
   enddo
   V->(DbGoto(nRecno))
   MsgBar(BAR)
 endif
return lRetVal

static function VldtVat(Mode)
local nRecno := V->(Recno())
local lRetVal := .t.
 if empty(xGetVar[8])
    return .t.
 endif
 if (Mode == APPEND_MODE) .or. (Mode == EDIT_MODE .and. xGetVar[8] != V->V_008)
   V->(DbGotop())
   while V->(!Eof())
    if V->V_008 == xGetVar[8]
      lRetVal := .f.
      Message(" Duplicate in VAT No.: "+xGetVar[8] )
      Tone(300,3)
      Tone(500,3)
      Inkey(3)
      Tone(200,2)
      exit
    endif
    V->(DBSkip())
   enddo
   V->(DbGoto(nRecno))
   MsgBar(BAR)
 endif
return lRetVal

static function VldtTerms()
local lValid:= .t.,n:= 0
local aChoices_ := ARRAY_TERMS

if xGetvar[10] == 2
   xGetVar[9] := n
  lValid :=  .f.
else

 for n := 1 to len(aChoices_)
   aChoices_[n]  := padc(aChoices_[n],10)
 next n
 n :=  LookUp( 09, 60,aChoices_,"Terms" )

 if (!empty(n))
  xGetVar[9] := n
  lValid :=  .f.
 endif
endif
return lValid

static function VldtType()
local lValid:= .t.,n:= 0
local aChoices_ := VENDOR_TYPES

 for n := 1 to len(aChoices_)
   aChoices_[n]  := padc(aChoices_[n],16)
 next n

if (( n := LookUp(10,62, aChoices_,"Supplier Types") )!= 0)
   xGetVar[10] := n
    lValid :=  .f.
 endif
return lValid

static function Vendor_Init(nMode)
   if nMode==APPEND_MODE
      xGetVar[ 1] := SPACE(3)
      xGetVar[ 2] := SPACE(30)
      xGetVar[ 3] := SPACE(50)
      xGetVar[ 4] := SPACE(30)
      xGetVar[ 5] := SPACE(10)
      xGetVar[ 6] := SPACE(20)
      xGetVar[ 7] := SPACE(12)
      xGetVar[ 8] := SPACE(12)
      xGetVar[ 9] := 1
      xGetVar[10] := 1
      xGetVar[11] := space(20)
      xGetVar[12] := 0

      xGetVar[13] := SPACE(30)
      xGetVar[14] := SPACE(30)
      xGetVar[15] := SPACE(30)
      xGetVar[16] := SPACE(30)

   else
      xGetVar[1]  := V->V_001
      xGetVar[2]  := V->V_002
      xGetVar[3]  := V->V_003
      xGetVar[4]  := V->V_004
      xGetVar[5]  := V->V_005
      xGetVar[6]  := V->V_006
      xGetVar[7]  := V->V_007
      xGetVar[8]  := V->V_008
      xGetVar[9]  := V->V_009
      xGetVar[10] := V->V_010
      xGetVar[11] := V->V_011
      xGetVar[12] := V->V_012

      xGetVar[13] := V->V_014
      xGetVar[14] := V->V_015
      xGetVar[15] := V->V_016
      xGetVar[16] := V->V_017
                        
   endif
return nil

static function Vendor_Save(nMode)
   Message("Saving entries...")
   if nMode==APPEND_MODE
      V->(FilLock(0))
      V->(Dbappend())
      V->V_013 := 1
      V->(DbUnLock())
   else
      V->(RecLock(0)) 
      V->V_013 := 2
      V->(DbUnlock())
   endif
   
   V->(RecLock(0))
   V->V_001 := xGetVar[ 1]
   V->V_002 := xGetVar[ 2]
   V->V_003 := XGetVar[ 3]
   V->V_004 := XGetVar[ 4]
   V->V_005 := XGetVar[ 5]
   V->V_006 := XGetVar[ 6]
   V->V_007 := XGetVar[ 7]
   V->V_008 := XGetVar[ 8]
   V->V_009 := XGetVar[ 9]
   V->V_010 := XGetVar[10]
   V->V_011 := XGetVar[11]
   V->V_012 := XGetVar[12]

   V->V_014 := XGetVar[13]
   V->V_015 := XGetVar[14]
   V->V_016 := XGetVar[15]
   V->V_017 := XGetVar[16]
      
   
   V->(DbUnlock())
   V->(DbCommit())
return nil

function Search_Form(cTitle,nlen)
local wSearch, nRecno := Recno()
static cString 
     if empty(cString)
        cString := space(nLen)
     else
        cString := padl(cString,nlen)
     endif      
     wSearch := openwindow(11,23,15,57,"Search "+cTitle)
     @ 13, 25 say "Enter " + cTitle + " Code to search"
     @ 14, 25 get cString pict "@K "+repl("X",nLen)
     setcursor(SC_NORMAL)
     read
     setcursor(SC_NONE)

     
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
     
     closewindow(wSearch)     
return nil

//end-of-file
