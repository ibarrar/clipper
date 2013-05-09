#include "box.ch"
#include "its.ch"
#include "inkey.ch"
#include "Janus.ch"
#include "aChoice.ch"
#include "setcurs.ch"

#ifdef COLOR_STAT
#define BAR "F2-Add   F3-Edit   F4-[Del/Undel]   F5-Search   F6-Items   ESC-Abort"
#else
#define BAR "F2-Add   F3-Edit   F4-[Del/Undel]   F5-Search   ESC-Abort"
#endif

memvar getlist

static xGetVar[6]
static aChoices := {}
static aUnits_ := {}
static aPicture 

function do_StkTransfer()
local wWindow, nkey
   aPicture := array(4,3)
   aPicture[1,1] := FieldBlock("STI_LINK")
   aPicture[1,2] := "@!"
   aPicture[1,3] := .f.
   aPicture[2,1] := FieldBlock("STI_ITEM")
   aPicture[2,2] := repl("9",PLU_CODE_LEN)
   aPicture[2,3] := .t.   
   aPicture[3,1] := FieldBlock("STI_QADJ")
   aPicture[3,2] := "99,999,999"
   aPicture[3,3] := .t.   
   aPicture[4,1] := FieldBlock("STI_UPRC")
   aPicture[4,2] := "999,999.99"
   aPicture[4,3] := .f.   
   Message("Opening Databases.......")
   if NetUse("ITEM.DBF",DB_SHARED,NUM_SECONDS)
      set index to I_001,I_020
   endif
   if netUse("V",DB_SHARED,NUM_SECONDS)
      set index to V_001
   endif
   if Netuse("IV",DB_SHARED,NUM_SECONDS)
      set index to IV_LINK
   endif      
   if NetUse("ST",DB_SHARED,NUM_SECONDS)
      set index to ST_001
   endif                 
   if NetUse("ST_ITEMS",DB_SHARED,NUM_SECONDS)
      set Index to STI_LINK
   endif    
   wWindow := OpenWindow(04,06,12,73,"Stock Transfer File")   
   if ST->(reccount())==0 ; Screen_Form(APPEND_MODE) ; endif
   if lastKey()!=K_ESC
      do while (nkey!=K_ESC)
         Screen_Form(VIEW_MODE)
         nkey:=inkey(0)
         do case
            case nkey==K_DOWN
               ST->(Dbskip())
               if ST->(eof())
                  ST->(Dbgobottom())
                  tone(100,3)
                  Message("End of file reached....")
                  inkey(1)
               endif
            case nKey==K_UP
               ST->(Dbskip(-1))
               if ST->(bof())
                  ST->(Dbgotop())
                  tone(100,3)
                  Message("Beginning of file reached....")
                  inkey(1)
               endif
            case nKey==K_CTRL_PGDN
               ST->(Dbskip(NUM_TO_SKIP))
               if ST->(eof())
                  ST->(Dbgobottom())
                  tone(100,3)
                  Message("End of file reached....")
                  inkey(1)
               endif
            case nKey==K_CTRL_PGUP
               ST->(Dbskip(-NUM_TO_SKIP))
               if ST->(bof())
                  ST->(Dbgotop())
                  tone(100,3)
                  Message("Beginning of file reached....")
                  inkey(1)
               endif
            case nKey==K_END
               ST->(Dbgobottom())
                  Message("Moving to end of file....")
                  inkey(1)
            case nKey==K_HOME
               ST->(Dbgotop())
                  Message("Moving to beginning of file....")
                  inkey(1)
            case nKey==K_F2
                  Screen_Form(APPEND_MODE)
            case nKey==K_F3
               if ST->ST_005 == 0
                Screen_Form(EDIT_MODE)
               endif 
            case nKey==K_F4
             if ST->ST_005 == 0
               if ST->(Deleted())
                 Message("Press ENTER to Undelete record, ESC to abort.")
                 if inkey(0)==K_ENTER
                    Message("Undeleting current record....")
                    ST_ITEMS->(DbSeek(ST->ST_001))
                    ST_ITEMS->(FilLock(0))
                    while ST_ITEMS->(!EOF()) .and. ST_ITEMS->STI_LINK == ST->ST_001
                         ST_ITEMS->(DbRecall())
                         ST_ITEMS->(DbSkip())
                    enddo     
                    ST_ITEMS->(DbUnLock())
                    ST->(RecLock(0))
                    ST->(DbRecall())
                    ST->ST_009 := 4
                    ST->(Dbunlock())
                 endif
               else
                  Message("Press ENTER to delete record, ESC to abort.")
                 if inkey(0)==K_ENTER
                    Message("Deleting current record....")
                    ST_ITEMS->(DbSeek(ST->ST_001))
                    ST_ITEMS->(FilLock(0))
                    while ST_ITEMS->(!EOF()) .and. ST_ITEMS->STI_LINK == ST->ST_001
                         ST_ITEMS->(DbDelete())
                         ST_ITEMS->(DbSkip())
                    enddo     
                    ST_ITEMS->(DbUnLock())                    
                    ST->(RecLock(0))
                    ST->(Dbdelete())
                    ST->ST_009 := 3
                    ST->(Dbunlock())
                 endif
               endif
             endif  
            case nKey==K_F5
               ST->(Search_Form("Stock Adj.#",8))
            case nKey==K_F6
               if (ST->(LASTREC()) > 0)
                 ST->(Reclock())
                 ST->ST_009 := 2
                 ST->(Dbunlock())
                 ST_ITEMS->(abrowse5(ST->ST_001,aPicture,EDIT_MODE))
               endif  
         endcase
      enddo
   endif
   Message("Closing Databases....")
   DbCloseAll()
   aChoices := {} // Free
   aUnits_ := {}   // Memory
   CloseWindow(wWindow)
   if NetUse("ST_ITEMS",DB_EXCLUSIVE,NUM_SECONDS)
      ST_ITEMS->(RecLock(0))
      ST_ITEMS->(__DbPack())
      ST_ITEMS->(DbUnlock())
      index on ST_ITEMS->STI_LINK to STI_LINK
      ST_ITEMS->(DbCloseArea())
   endif  
return nil

static function Screen_Form(nMode)
local clr, crs
   tone(300,1)
   Screen_Init(nMode)
   MsgBar(BAR)
   clr := setcolor(TITLE_ATTR)

   if nMode==APPEND_MODE
       @ 04,62 say "< New >   "
       @ 04,35 say "         "
   else
      if ST->(Deleted()) 
        @ 04,35 say "<deleted>"
      elseif ST->st_005 != 0  
        @ 04,35 say " <posted>" 
      else  
        @ 04,35 say "         "
      endif
      @ 04, 62 say "Rec #"+transform(ST->(recno()),"9999")
   endif
      
   setcolor( clr ) 
   
   @ 06,      14 say "Stock Transfer Number " get xGetVar[1] PICT "@K 99999999"  WHEN refno(nMode) VALID VldtAdjust(nMode)    
   @ row()+1, 14 say "        Supplier Code " get xGetVar[5] PICT "@K 999"  WHEN VldtVLnk() VALID PostVldtV()
   @ row()+1, 14 say "        Supplier Name " get xGetVar[6] PICT "@K " VALID !empty(xGetVar[4]) 
   @ row()+1, 14 say "          Source Unit " get xGetVar[2] PICT "@K 999"  WHEN VldtUNIT(2) VALID ( !empty(xGetVar[2]) )
   @ row()+1, 14 say "     Destination Unit " get xGetVar[3] PICT "@K 999"  WHEN VldtUNIT(3) VALID ( !empty(xGetVar[3]).and. !(xGetVar[3]==xGetVar[2]) )
   @ row()+1, 14 say	"     Transaction Date " get xGetVar[4] PICT "@K D"    VALID (!empty(xGetVar[2]) .and. !empty(xGetVar[3]) .and. !empty(xGetVar[4])) 

   if (nMode==APPEND_MODE) .or. (nMode==EDIT_MODE)
      crs := setcursor(SC_NORMAL)
      read
      if lastkey()!=K_ESC
         Screen_Save(nMode)
         if (ST->(LastRec()) > 0)
           ST_ITEMS->(abrowse5(ST->ST_001,aPicture,nMode))
         endif
      endif
      setcursor( crs )
   else
      clear gets
   endif
return nil

static function VldtVLnk()
local lVal := .t. ,n:= 0
local bMyBlock,lSet
local nRecNo := V->(RecNO())  

 Message(" Please Wait...") 
 bMyblock := {|| padr(" "+V->V_001+" "+if(V->(Dbseek(V->V_001)),V->V_002,"Supplier Code "+V->V_001),(maxcol()-45-2))}

 lSet := Set(_SET_DELETED,.t.) 
 // V->(DbSetFilter( {|| V->V_001 <1 } ))
 if (V->(DbfLookUp(8,45,bMyBlock,"Supplier Link",xGetVar[3])) != 0)
     xGetVar[5] := V->V_001
     XGetVar[6] := V->V_002
     lVal := .f.
 endif
 V->(DbClearFilter())
 Set(_SET_DELETED,lSet)
 V->(DbGoto(nRecNo))
return lVal     
     

static function PostVldtV()
local lVal := .t.
 if empty(xGetVar[5])
    return .f.
 endif
 xGetVar[5] :=  padl( alltrim(xGetVar[5]),3,"0")
 V->(DBgotop())
 if !V->(DbSeek(xGetVar[5]))
   lVal := .f.
   Message(" Supplier Code "+xGetVar[3]+" does not exist.... ")
   Tone(500,3)
   Inkey(1)
   Tone(200,2)
 endif
  MsgBar(BAR)
return lVal

static function refno(nMode)
local nrecno := ST->(Recno())


   if nMode == APPEND_MODE
      if ST->(LastRec()) == 0
         xGetvar[1] := STR(1)
      endif
      ST->(DbGoBottom())
      xGetvar[1] := STR(VAL(ST->ST_001) + 1)
      ST->(DbGoto(nRecNo))
   endif
   xGetVar[1] :=  padl( alltrim(xGetVar[1]),8,"0")
return .T.


static function VldtAdjust(Mode)
local lRetVal:= .t.,nRecNo:= ST->(RecNo())
 if empty(xGetVar[1])
    return .f.
 endif
 xGetVar[1] :=  padl( alltrim(xGetVar[1]),8,"0")

 if (Mode == APPEND_MODE) .or. (Mode == EDIT_MODE .and. xGetVar[1] != ST->ST_001)
   ST->(DbSeek(xGetVar[1]))
   if (ST->(found()))
    lRetVal := .f.
    Message(" Receiving Receipts Number : "+xGetVar[1]+" already exist...")      
    Tone(300,3)
    Tone(500,3)
    Inkey(3)
    Tone(200,2)
   endif
   ST->(DbGoto(nRecNo))
   MsgBar(BAR)
 endif 
 
return lRetVal

static function Screen_Init(nMode)
 if nMode==APPEND_MODE
 	xGetVar[1] := space(8)
	xGetVar[2] := space(3)
   xGetVar[3] := space(3)
   xGetVar[4] := date()
   xGetVar[5] := space(3)
   xGetVar[6] := space(20)
 else
 	xGetVar[1] := ST->ST_001
	xGetVar[2] := ST->ST_002
   xGetVar[3] := ST->ST_003
   xGetVar[4] := ST->ST_004
   xGetVar[5] := ST->ST_007
   xGetVar[6] := ST->ST_008
 endif
return nil

static function Screen_Save(nMode)
   Message("Saving entries...")
   if nMode==APPEND_MODE
      ST->(FilLock(0))
      ST->(Dbappend())
      ST->ST_009 := 1
      ST->(DbUnLock())
   else
      ST->(RecLock(0))
      ST->ST_009 := 2   
      ST->(DbUnLock())
   endif
      ST->(RecLock(0))
      ST->ST_001 := xGetVar[1]
      ST->ST_002 := xGetVar[2]
      ST->ST_003 := xGetVar[3]
      ST->ST_004 := xGetVar[4]
      ST->ST_007 := xGetVar[5]
      ST->ST_008 := xGetVar[6]
      ST->(DbUnlock())
      ST->(DbCommit())
return nil

static function VldtUnit(nVar)
local n:=0
local aUnits := {}

  if  empty(aUnits_)
     aUnits := getUnits()
     for n := 1 to len(aUnits)
        aAdd(aUnits_," "+aUnits[n][1]+" "+aUnits[n][2]+" ")
     next   
  endif   
  
      
  if ((n:=LookUp( 06+nVar,19, aUnits_,"Unit Link",xGetVar[nVar])) != 0)
    xGetVar[nVar] := subs(aUnits_[n],2,3)
  endif
 
return .f.

//end-of-file
