#include "box.ch"
#include "its.ch"
#include "inkey.ch"
#include "Janus.ch"
#include "aChoice.ch"
#include "setcurs.ch"

#ifdef COLOR_STAT 
#define BAR "F2-Add   F3-Edit   F4-[Del/Undel]   F5-Search   F6-Items   ESC-Abort"
#else
#define BAR "F2-Add   F3-Edit   F4-[Del/Undel]   F5-Search   F6-Items   ESC-Abort"
#endif

memvar getlist,nUnit

static xGetVar[4]
static aChoices := {}
static aUntCsts := {}
static aPicture 

function do_StkAdjust()
local wWindow, nkey
   aPicture := array(5,3)
   aPicture[1,1] := FieldBlock("SAI_LINK")
   aPicture[1,2] := "@!"
   aPicture[1,3] := .f.
   aPicture[2,1] := FieldBlock("SAI_UNIT")
   aPicture[2,2] := "999"
   aPicture[2,3] := .t.   
   aPicture[3,1] := FieldBlock("SAI_ITEM")
   aPicture[3,2] := repl("9",PLU_CODE_LEN)
   aPicture[3,3] := .t.   
   aPicture[4,1] := FieldBlock("SAI_QADJ")
   aPicture[4,2] := "99,999,999"
   aPicture[4,3] := .t.   
   aPicture[5,1] := FieldBlock("SAI_UPRC")
   aPicture[5,2] := "999,999.99"
   aPicture[5,3] := .f.
   Message("Opening Databases.......")
   if NetUse("UNIT",DB_SHARED,NUM_SECONDS)
      set Index to UNIT
   endif  
   if UNIT->(DbSeek(padl(alltrim(str(nUnit)),3,"0"))) 
      Set(_SET_PATH,UNIT->UNIT_PATH)
   endif   
   if NetUse("UITEMS",DB_SHARED,NUM_SECONDS)
      Set Index to UITEMS
   endif   
   if NetUse("ITEM.DBF",DB_SHARED,NUM_SECONDS)
      set index to I_001,I_020
   endif
   if netUse("V",DB_SHARED,NUM_SECONDS)
      set index to V_001
   endif
   if Netuse("IV",DB_SHARED,NUM_SECONDS)
      set index to IV_LINK
   endif      
   if NetUse("SA",DB_SHARED,NUM_SECONDS)
      set index to SA_001
   endif                 
   if NetUse("SA_ITEMS",DB_SHARED,NUM_SECONDS)
      set Index to SAI_LINK
   endif    
   wWindow := OpenWindow(04,06,10,73,"Stock Adjustment File")   
   if SA->(reccount())==0 ; Screen_Form(APPEND_MODE) ; endif
   if lastKey()!=K_ESC
      do while (nkey!=K_ESC)
         Screen_Form(VIEW_MODE)
         nkey:=inkey(0)
         do case
            case nkey==K_DOWN
               SA->(Dbskip())
               if SA->(eof())
                  SA->(Dbgobottom())
                  tone(100,3)
                  Message("End of file reached....")
                  inkey(1)
               endif
            case nKey==K_UP
               SA->(Dbskip(-1))
               if SA->(bof())
                  SA->(Dbgotop())
                  tone(100,3)
                  Message("Beginning of file reached....")
                  inkey(1)
               endif
            case nKey==K_CTRL_PGDN
               SA->(Dbskip(NUM_TO_SKIP))
               if SA->(eof())
                  SA->(Dbgobottom())
                  tone(100,3)
                  Message("End of file reached....")
                  inkey(1)
               endif
            case nKey==K_CTRL_PGUP
               SA->(Dbskip(-NUM_TO_SKIP))
               if SA->(bof())
                  SA->(Dbgotop())
                  tone(100,3)
                  Message("Beginning of file reached....")
                  inkey(1)
               endif
            case nKey==K_END
               SA->(Dbgobottom())
                  Message("Moving to end of file....")
                  inkey(1)
            case nKey==K_HOME
               SA->(Dbgotop())
                  Message("Moving to beginning of file....")
                  inkey(1)
            case nKey==K_F2
                  Screen_Form(APPEND_MODE)
            case nKey==K_F3
               if SA->SA_003 == 0
                Screen_Form(EDIT_MODE)
               endif 
            case nKey==K_F4
             if SA->SA_003 == 0
               if SA->(Deleted())
                 Message("Press ENTER to Undelete record, ESC to abort.")
                 if inkey(0)==K_ENTER
                    Message("Undeleting current record....")
                    if SA_ITEMS->(DbSeek(SA->SA_001))
                       SA_ITEMS->(FilLock())
                       while SA_ITEMS->(!Eof()) .and. SA_ITEMS->SAI_LINK == SA->SA_001
                           SA_ITEMS->(DbRecall())
                           SA_ITEMS->(DbSkip())
                       enddo
                       SA_ITEMS->(DbUnLock())
                    endif     
                    SA->(RecLock(0))
                    SA->(DbRecall())
                    SA->SA_007 := 4
                    SA->(Dbunlock())
                 endif
               else
                  Message("Press ENTER to delete record, ESC to abort.")
                 if inkey(0)==K_ENTER
                    Message("Deleting current record....")
                    if SA_ITEMS->(DbSeek(SA->SA_001))
                       SA_ITEMS->(FilLock())
                       while SA_ITEMS->(!Eof()) .and. SA_ITEMS->SAI_LINK == SA->SA_001
                           SA_ITEMS->(DbDelete())
                           SA_ITEMS->(DbSkip())
                       enddo
                       SA_ITEMS->(DbUnLock())
                    endif                         
                    SA->(RecLock(0))
                    SA->(Dbdelete())
                    SA->SA_007 := 3
                    SA->(Dbunlock())
                 endif
               endif
             endif  
            case nKey==K_F5
               SA->(Search_Form("Stock Adj.#",8))
            case nKey==K_F6
               if (SA->(LASTREC()) > 0)
                 SA->(Reclock())
                 SA->SA_007 := 2
                 SA->(Dbunlock())
                 SA_ITEMS->(aBrowse4(SA->SA_001,aPicture,EDIT_MODE))
               endif  
         endcase
      enddo
   endif
   Message("Closing Databases....")
   DbcloseAll()
   aChoices := {}
   aUntCsts := {}
   CloseWindow(wWindow)
   if NetUse("SA_ITEMS",DB_EXCLUSIVE,NUM_SECONDS)
      SA_ITEMS->(RecLock(0))
      SA_ITEMS->(__DbPack())
      SA_ITEMS->(DbUnlock())
      index on SA_ITEMS->SAI_LINK to SAI_LINK
      SA_ITEMS->(DbCloseArea())
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
      if SA->(Deleted()) 
        @ 04,35 say "<deleted>"
      elseif SA->SA_003 != 0  
        @ 04,35 say " <posted>" 
      else  
        @ 04,35 say "         "
      endif
      @ 04, 62 say "Rec #"+transform(SA->(recno()),"9999")
   endif
      
   setcolor( clr ) 
   
   @ 06,      14 say "Stock Adjustment Number " get xGetVar[1] PICT "@K 99999999" WHEN REFNO(nMode) VALID VldtAdjust(nMode)    
   @ row()+1, 14 say "          Supplier Code " get xGetVar[3] PICT "@K 999"  WHEN VldtVLnk() VALID PostVldtV()
   @ row()+1, 14 say "          Supplier Name " get xGetVar[4] PICT "@K " VALID !empty(xGetVar[4]) 
   @ row()+1, 14 say	"       Transaction Date " get xGetVar[2] PICT "@K D" VALID !EMPTY(xGetVar[2])
                                                                                                       
   if (nMode==APPEND_MODE) .or. (nMode==EDIT_MODE)
      crs := setcursor(SC_NORMAL)
      read
      if lastkey()!=K_ESC
         Screen_Save(nMode)
         if (SA->(LastRec()) > 0)
           SA_ITEMS->(aBrowse4(SA->SA_001,aPicture,nMode))
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
     xGetVar[3] := V->V_001
     XGetVar[4] := V->V_002
     lVal := .f.
 endif
 V->(DbClearFilter())
 Set(_SET_DELETED,lSet)
 V->(DbGoto(nRecNo))
return lVal     
     

static function PostVldtV()
local lVal := .t.
 if empty(xGetVar[3])
    return .f.
 endif
 xGetVar[3] :=  padl( alltrim(xGetVar[3]),3,"0")
 V->(DBgotop())
 if !V->(DbSeek(xGetVar[3]))
   lVal := .f.
   Message(" Supplier Code "+xGetVar[3]+" does not exist.... ")
   Tone(500,3)
   Inkey(1)
   Tone(200,2)
 endif
  MsgBar(BAR)
return lVal


static function refno(nMode)
local nrecno := SA->(Recno())


   if nMode == APPEND_MODE
      if SA->(LastRec()) == 0
         xGetvar[1] := STR(1)
      endif
      SA->(DbGoBottom())
      xGetvar[1] := STR(VAL(SA->SA_001) + 1)
      SA->(DbGoto(nRecNo))
   endif
   xGetVar[1] :=  padl( alltrim(xGetVar[1]),8,"0")
return .T.

static function VldtAdjust(Mode)
local lRetVal:= .t.,nRecNo:= SA->(RecNo())
 if empty(xGetVar[1])
    return .f.
 endif
 xGetVar[1] :=  padl( alltrim(xGetVar[1]),8,"0")

 if (Mode == APPEND_MODE) .or. (Mode == EDIT_MODE .and. xGetVar[1] != SA->SA_001)
   SA->(DbSeek(xGetVar[1]))
   if (SA->(found()))
    lRetVal := .f.
    Message(" Receiving Receipts Number : "+xGetVar[1]+" already exist...")      
    Tone(300,3)
    Tone(500,3)
    Inkey(3)
    Tone(200,2)
   endif
   SA->(DbGoto(nRecNo))
   MsgBar(BAR)
 endif 
 
return lRetVal

static function Screen_Init(nMode)
 if nMode==APPEND_MODE
 	xGetVar[1] := space(17)
	xGetVar[2] := date()
   xGetVar[3] := space(3)
   xGetvar[4] := space(20)
 else
 	xGetVar[1] := SA->SA_001
	xGetVar[2] := SA->SA_002
   xGetVar[3] := SA->SA_005
   xGetVar[4] := SA->SA_006
 endif
return nil

static function Screen_Save(nMode)
   Message("Saving entries...")
   if nMode==APPEND_MODE
      SA->(FilLock(0))
      SA->(Dbappend())
      SA->SA_007 := 1
      SA->(DbUnLock())
   else
      SA->(RecLock(0))
      SA->SA_007 := 2
      SA->(DbUnLock())   
   endif
      SA->(RecLock(0))
      SA->SA_001 := xGetVar[1]
      SA->SA_002 := xGetVar[2]
      SA->SA_005 := xGetVar[3]
      SA->SA_006 := xGetVar[4]
      SA->(DbUnlock())
      SA->(DbCommit())
return nil

//end-of-file
