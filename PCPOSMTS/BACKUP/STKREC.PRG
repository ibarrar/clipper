
#include "box.ch"
#include "its.ch"
#include "inkey.ch"
#include "Janus.ch"
#include "aChoice.ch"
#include "setcurs.ch"

#ifdef COLOR_STAT
#define BAR "F2-Add  F3-Edit  F4-[Del/Undel]  F5-Search  F6-Items  ESC-Abort"
#else
#define BAR "F2-Add  F3-Edit  F4-[Del/Undel]  F5-Search  F6-Items  ESC-Abort"
#endif

memvar getlist

static xGetVar[10],aPicture1
static aChoices := {}
static cPrompts := { ;
   "Receiving Report Number ",;
   "    IP Reference Number ",;     
   "          Supplier Code ",;
   "          Supplier Name ",;
   "    Receiving Personnel ",;          
   "       Transaction Date ",;
   "          Date Received ",;
   "         Reference Type ",;
   "       Reference Number ",;
   "         Reference Date "}

function do_StkReceipt()
local wWindow, nkey
   aPicture1 := array(7,3)
   aPicture1[1,1] := FieldBlock("RRI_LINK")
   aPicture1[1,2] := "@!"
   aPicture1[1,3] := .f.
   aPicture1[2,1] := FieldBlock("RRI_ITEM")
   aPicture1[2,2] := "@K "+repl("X",PLU_CODE_LEN)   
   aPicture1[2,3] := .t.
   aPicture1[3,1] := { || if(ITEM->I_001 == RR_ITEMS->RRI_ITEM, ITEM->I_002," ") }
   aPicture1[3,2] := "@! "+repl("X",PLU_DESC_LEN)   
   aPicture1[3,3] := .f.
   aPicture1[4,1] := FieldBlock("RRI_URET")
   aPicture1[4,2] := "99,999.99"
   aPicture1[4,3] := .f.   
   aPicture1[5,1] := FieldBlock("RRI_COST")
   aPicture1[5,2] := "99,999.99"
   aPicture1[5,3] := .f.   
   aPicture1[6,1] := FieldBlock("RRI_QREC")
   aPicture1[6,2] := "99,999,999"
   aPicture1[6,3] := .t.
   aPicture1[7,1] := FieldBlock("RRI_AGEC")
   aPicture1[7,2] := "999999"
   aPicture1[7,3] := .F.

#ifdef FM_ITEMS   
   if NetUse("FM",DB_SHARED,NUM_SECONDS)
      set index to FM
   endif   
#endif

   if netUse("V",DB_SHARED,NUM_SECONDS)
      set index to V_001
   endif

   if netUse("CL",DB_SHARED,NUM_SECONDS)
      set index to CL_001
   endif
   if Netuse("IV",DB_SHARED,NUM_SECONDS)
      set index to IV_LINK
   endif      
   if NetUse("ITEM.DBF",DB_SHARED,NUM_SECONDS)
      set index to I_001,I_020
   endif
   if NetUse("PO",DB_SHARED,NUM_SECONDS)
      set index to PO_001
   endif   
   if NetUse("PO_ITEMS",DB_SHARED,NUM_SECONDS)
     set index to POI_LINK
   endif   
   if NetUse("RR_ITEMS",DB_SHARED,NUM_SECONDS)
      set index to RRI_LINK  // , RRI_COST
   endif                     
   if NetUse("RR",DB_SHARED,NUM_SECONDS)
      set index to RR_001 //,RR_008
   endif   

// set order to 1

   wWindow := OpenWindow(04,06,16,73,"Stock Receipts File")   
   if RR->(reccount())==0 ; Screen_Form(APPEND_MODE) ; endif
   if lastKey()!=K_ESC
      do while (nkey!=K_ESC)
         Screen_Form(VIEW_MODE)
         nkey:=inkey(0)
         do case
            case nkey==K_DOWN
               RR->(Dbskip())
               if RR->(eof())
                  RR->(Dbgobottom())
                  tone(100,3)
                  Message("End of file reached....")
                  inkey(1)
               endif
            case nKey==K_UP
               RR->(Dbskip(-1))
               if RR->(bof())
                  RR->(Dbgotop())
                  tone(100,3)
                  Message("Beginning of file reached....")
                  inkey(1)
               endif
            case nKey==K_CTRL_PGDN
               RR->(Dbskip(NUM_TO_SKIP))
               if RR->(eof())
                  RR->(Dbgobottom())
                  tone(100,3)
                  Message("End of file reached....")
                  inkey(1)
               endif
            case nKey==K_CTRL_PGUP
               RR->(Dbskip(-NUM_TO_SKIP))
               if RR->(bof())
                  RR->(Dbgotop())
                  tone(100,3)
                  Message("Beginning of file reached....")
                  inkey(1)
               endif
            case nKey==K_END
               RR->(Dbgobottom())
                  Message("Moving to end of file....")
                  inkey(1)
            case nKey==K_HOME
               RR->(Dbgotop())
                  Message("Moving to beginning of file....")
                  inkey(1)
            case nKey==K_F2
                  Screen_Form(APPEND_MODE)
            case nKey==K_F3
               if RR->(!Deleted())
                  if RR->RR_010 == 0
                    Screen_Form(EDIT_MODE)
                  else
                    RR_ITEMS->(aBrowse1(RR->RR_001,aPicture1,EDIT_MODE))     
                    RR->(RecLock(0))
                    RR->RR_010 := 7
                    RR->(DbUnlock(0))
                  endif  
               endif
            case nKey==K_F4
             if RR->RR_010 == 0
               if RR->(Deleted())
                 Message("Press ENTER to Undelete record, ESC to abort.")
                 if inkey(0)==K_ENTER
                    Message("Undeleting current record....")
                    RR_ITEMS->(DbSeek(RR->RR_001))
                    RR_ITEMS->(FilLock(0)) 
                    while RR_ITEMS->(!Eof()) .and. RR_ITEMS->RRI_LINK == RR->RR_001                 
                       RR_ITEMS->(DbRecall())
                       RR_ITEMS->(DbSkip())
                    enddo                 
                    RR_ITEMS->(DbUnlock())                    
                    RR->(RecLock(0))
                    RR->(DbRecall())
                    RR->RR_013 := 4
                    RR->(Dbunlock())
                 endif
               else
                  Message("Press ENTER to delete record, ESC to abort.")
                 if inkey(0)==K_ENTER
                    Message("Deleting current record....")
                    RR_ITEMS->(DbSeek(RR->RR_001))
                    RR_ITEMS->(FilLock(0)) 
                    while RR_ITEMS->(!Eof()) .and. RR_ITEMS->RRI_LINK == RR->RR_001                 
                       RR_ITEMS->(DbDelete())                  
                       RR_ITEMS->(DbSkip())
                    enddo                 
                    RR_ITEMS->(DbUnlock())                    
                    RR->(RecLock(0))
                    RR->(Dbdelete())
                    RR->RR_013 := 4
                    RR->(Dbunlock())
                 endif
               endif
             endif  
            case nKey==K_F5
               RR->(Search_Form("Receipt No",8))
            case nKey==K_F6
               if (RR->(Lastrec()) > 0)
                 RR->(Reclock())
                 RR->RR_013 := 2
                 RR->(Dbunlock())
                 RR_ITEMS->(aBrowse1(RR->RR_001,aPicture1,EDIT_MODE))               
               endif 
         endcase
      enddo
   endif
   Message("Closing Databases....")
   DbCloseAll()
   aChoices := {}
   CloseWindow(wWindow)
   if NetUse("RR_ITEMS",DB_EXCLUSIVE,NUM_SECONDS)
      RR_ITEMS->(RecLock(0))
      RR_ITEMS->(__DbPack())
      RR_ITEMS->(DbUnlock())
      index on RR_ITEMS->RRI_LINK to RRI_LINK
      RR_ITEMS->(DbCloseArea())
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
      if RR->(Deleted()) 
        @ 04,35 say "<deleted>"
      elseif RR->RR_010 != 0  
        @ 04,35 say " <posted>" 
      else  
        @ 04,35 say "         "
      endif
      @ 04, 62 say "Rec #"+transform(RR->(recno()),"9999")
   endif

   setcolor( clr )

   @ 06,      14 say cPrompts[1] get xGetVar[1] PICT "@K 99999999" WHEN refno(nMode) VALID VldtReceipts(nMode)
   @ row()+1, 14 say cPrompts[2] get xGetVar[2] PICT "@K 99999999"  WHEN VldtPOLnk() VALID PostVldtPO()
   @ row()+1, 14 say cPrompts[3] get xGetVar[3] PICT "@K 999"  WHEN VldtVLnk() VALID PostVldtV()
   @ row()+1, 14 say cPrompts[4] get xGetVar[4] PICT "@K " when .f. VALID !empty(xGetVar[4]) // WHEN PreVldtItem()
   @ row()+1, 14 SAY cPrompts[5] get xGetVar[5] PICT "@!X" VALID !empty(xGetVar[5]) // 9,999.999" VALID (xGetVar[4] > 0)
   @ row()+1, 14 SAY cPrompts[6] get xGetVar[6] PICT "@K " VALID !empty(xGetVar[6])
   @ row()+1, 14 SAY cPrompts[7] get xGetVar[7] PICT "@K " VALID !empty(xGetVar[7])
   @ row()+1, 14 SAY cPrompts[8] get xGetVar[8] PICT "@K 9" RANGE 1,7
   @ row()+1, 14 SAY cPrompts[9] get xGetVar[9] PICT "@K " VALID !empty(xGetVar[9]) // WHEN refno(nMode) VALID !empty(xGetVar[9])
   @ row()+1, 14 SAY cPrompts[10] get xGetVar[10] PICT "@K " VALID !empty(xGetVar[10])
                                                                                                       
   if (nMode==APPEND_MODE) .or. (nMode==EDIT_MODE)
      crs := setcursor(SC_NORMAL)
      read
      if lastkey()!=K_ESC
         Screen_Save(nMode)
         if (RR->(Lastrec()) > 0) 
          RR_ITEMS->(aBrowse1(RR->RR_001,aPicture1,EDIT_MODE))
         endif 
      endif
      setcursor( crs )
   else
      clear gets
   endif
return nil

static function refno(nMode)
local nrecno := RR->(Recno())


   if nMode == APPEND_MODE
      if RR->(LastRec()) == 0
         xGetvar[1] := STR(1)
      endif
      RR->(DbGoBottom())
      xGetvar[1] := STR(VAL(RR->RR_001) + 1)
      RR->(DbGoto(nRecNo))
   endif
   xGetVar[1] :=  padl( alltrim(xGetVar[1]),8,"0")
return .T.


static function VldtReceipts(Mode)
local lRetVal:= .t.,nRecNo:= RR->(RecNo())
 if empty(xGetVar[1])
    return .f.
 endif
 xGetVar[1] :=  padl( alltrim(xGetVar[1]),8,"0")
 if (Mode == APPEND_MODE) .or. (Mode == EDIT_MODE .and. xGetVar[1] != RR->RR_001)
   RR->(DbSeek(xGetVar[1]))
   if (RR->(found()))
    lRetVal := .f.
    Message(" Receiving Receipts Number : "+xGetVar[1]+" already exist...")      
    Tone(300,3)
    Tone(500,3)
    Inkey(3)
    Tone(200,2)
   endif
   RR->(DbGoto(nRecNo))
   MsgBar(BAR)
 endif
return lRetVal

static function VldtPOLnk()
local lVal := .t. ,n:= 0
local bMyBlock,lSet
local nRecNo := PO->(RecNO())  

 Message(" Please Wait...") 
 bMyblock := {|| padr(" "+PO->PO_001+" " ,(maxcol()-45-2))}

 lSet := Set(_SET_DELETED,.t.) 
 PO->(DbSetFilter( {|| PO->PO_007 < 1 } ))
 if (PO->(DbfLookUp(7,45,bMyBlock,"IP Reference Link",xGetVar[2])) != 0)
     xGetVar[2] := PO->PO_001
     xGetVar[3] := PO->PO_002
     if V->(DbSeek(PO->PO_002))
      xGetVar[4] := V->V_002
     endif 
     lVal := .f.
 endif
 PO->(DbClearFilter())
 Set(_SET_DELETED,lSet)
 PO->(DbGoto(nRecNo))
return lVal     
     

static function PostVldtPO()
local lVal := .t.
 if empty(xGetVar[2])
    return .T.
 endif
 xGetVar[2] :=  padl( alltrim(xGetVar[2]),8,"0")
 PO->(DBgotop())
 if !PO->(DbSeek(xGetVar[2]))
   lVal := .f.
   Message(" I.P. Reference Number "+xGetVar[2]+" does not exist.... ")
   Tone(500,3)
   Inkey(1)
   Tone(200,2)
 endif
  MsgBar(BAR)
return lVal

static function VldtVLnk()
local lVal := .t. ,n:= 0
local bMyBlock,lSet
local nRecNo := V->(RecNO())  

if !empty(xGetVar[2])
   return .f.
endif   

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

static function Screen_Init(nMode)
 if nMode==APPEND_MODE
   xGetVar[ 1] := SPACE(8)
   xGetVar[2] := SPACE(8)
   xGetVar[ 3] := SPACE(3)
   xGetVar[ 4] := SPACE(30)
   xGetVar[ 5] := SPACE(15)
   xGetVar[ 6] := DATE()
   xGetVar[ 7] := DATE()
   xGetVar[ 8] := 0
   xGetVar[ 9] := space(10)
   xGetVar[10] := DATE()   
 else
   xGetVar[ 1] := RR->RR_001
   xGetVar[ 2] := RR->RR_012
   xGetVar[ 3] := RR->RR_002
   xGetVar[ 4] := RR->RR_003
   xGetVar[ 5] := RR->RR_004
   xGetVar[ 6] := RR->RR_005
   xGetVar[ 7] := RR->RR_006
   xGetVar[ 8] := RR->RR_007
   xGetVar[ 9] := RR->RR_008
   xGetVar[10] := RR->RR_009                 
 endif
return nil

static function Screen_Save(nMode)
   Message("Saving entries...")
   if nMode==APPEND_MODE
      RR->(FilLock(0))
      RR->(Dbappend())
      RR->RR_013 := 1
      RR->(DbUnLock())
   else
      RR->(RecLock(0))
      RR->RR_013 := 2
      RR->(DbUnLock())   
   endif
      RR->(RecLock(0))
      RR->RR_001 := xGetVar[1]
      RR->RR_012 := xGetVar[2]
      RR->RR_002 := xGetVar[3]
      RR->RR_003 := xGetVar[4]
      RR->RR_004 := xGetVar[5]
      RR->RR_005 := xGetVar[6]
      RR->RR_006 := xGetVar[7]
      RR->RR_007 := xGetVar[8]
      RR->RR_008 := xGetVar[9]
      RR->RR_009 := xGetVar[10]
      RR->(DbUnlock())
      RR->(DbCommit())
return nil


//end-of-file
