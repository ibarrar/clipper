#include "box.ch"
#include "its.ch"
#include "inkey.ch"
#include "Janus.ch"
#include "aChoice.ch"
#include "setcurs.ch"

#ifdef  COLOR_STAT
#define BAR "F2-Add   F3-Edit   F4-[Del/Undel]   F5-Search   F6-Items   ESC-Abort"
#else
#define BAR "F2-Add   F3-Edit   F4-[Del/Undel]   F5-Search   F6-Items   ESC-Abort"
#endif

memvar getlist

static xGetVar[9],aPicture2
static aChoices := {}

function do_StkReturn()
local wWindow, nkey
   aPicture2 := array(7,3)
   aPicture2[1,1] := FieldBlock("RJI_LINK")
   aPicture2[1,2] := "@!"
   aPicture2[1,3] := .f.
   aPicture2[2,1] := FieldBlock("RJI_ITEM")
   aPicture2[2,2] := "@K "+repl("X",PLU_CODE_LEN)
   aPicture2[2,3] := .t.
   aPicture2[3,1] := { || if(ITEM->I_001 == RJ_ITEMS->RJI_ITEM, ITEM->I_002," ") }
   aPicture2[3,2] := "@! "+repl("X",PLU_DESC_LEN)   
   aPicture2[3,3] := .f.
   aPicture2[4,1] := FieldBlock("RJI_URET")
   aPicture2[4,2] := "99,999.99"
   aPicture2[4,3] := .t.   
   aPicture2[5,1] := FieldBlock("RJI_COST")
   aPicture2[5,2] := "99,999.99"
   aPicture2[5,3] := .T.   
   aPicture2[6,1] := FieldBlock("RJI_QRET")
   aPicture2[6,2] := "99,999,999"
   aPicture2[6,3] := .t.
   aPicture2[7,1] := FieldBlock("RJI_AGEC")
   aPicture2[7,2] := "999999"
   aPicture2[7,3] := .T.
   Message("Opening Databases...")
   if netUse("V",DB_SHARED,NUM_SECONDS)
      set index to V_001
   endif
   if NetUse("ITEM.DBF",DB_SHARED,NUM_SECONDS)
      set index to I_001
   endif
   if NetUse("RR",DB_SHARED,NUM_SECONDS)
      set index to RR_001      
   endif
   if NetUse("RR_ITEMS",DB_SHARED,NUM_SECONDS)
      set index to RRI_LINK
   endif   
   if NetUse("RJ_ITEMS",DB_SHARED,NUM_SECONDS)
      set index to RJI_LINK 
   endif                  
   if NetUse("RJ",DB_SHARED,NUM_SECONDS)
      set index to RJ_001 // ,RJ_008      
   endif   

   set order to 1
   wWindow := OpenWindow(04,06,15,73,"Stock Returns File")   
   if RJ->(reccount())==0 ; Screen_Form(APPEND_MODE) ; endif
   if lastKey()!=K_ESC
      do while (nkey!=K_ESC)
         Screen_Form(VIEW_MODE)
         nkey:=inkey(0)
         do case
            case nkey==K_DOWN
               RJ->(Dbskip())
               if RJ->(eof())
                  RJ->(Dbgobottom())
                  tone(100,3)
                  Message("End of file reached....")
                  inkey(1)
               endif
            case nKey==K_UP
               RJ->(Dbskip(-1))
               if RJ->(bof())
                  RJ->(Dbgotop())
                  tone(100,3)
                  Message("Beginning of file reached....")
                  inkey(1)
               endif
            case nKey==K_CTRL_PGDN
               RJ->(Dbskip(NUM_TO_SKIP))
               if RJ->(eof())
                  RJ->(Dbgobottom())
                  tone(100,3)
                  Message("End of file reached....")
                  inkey(1)
               endif
            case nKey==K_CTRL_PGUP
               RJ->(Dbskip(-NUM_TO_SKIP))
               if RJ->(bof())
                  RJ->(Dbgotop())
                  tone(100,3)
                  Message("Beginning of file reached....")
                  inkey(1)
               endif
            case nKey==K_END
               RJ->(Dbgobottom())
                  Message("Moving to end of file....")
                  inkey(1)
            case nKey==K_HOME
               RJ->(Dbgotop())
                  Message("Moving to beginning of file....")
                  inkey(1)
            case nKey==K_F2
                  Screen_Form(APPEND_MODE)
            case nKey==K_F3
               if RJ->RJ_010 == 0
                 Screen_Form(EDIT_MODE)
               else
                 RJ_ITEMS->(aBrowse2(RJ->RJ_001,aPicture2,EDIT_MODE))   
                 RJ->(RecLock(0))
                 RJ->RJ_010 := 7
                 RJ->(DbUnlock())
               endif 
            case nKey==K_F4
               if RJ->RJ_010 == 0
                if RJ->(Deleted())
                  Message("Press ENTER to Undelete record, ESC to abort.")
                  if inkey(0)==K_ENTER
                     Message("Undeleting current record....")
                     RJ_ITEMS->(DbSeek(RJ->RJ_001))
                     RJ_ITEMS->(FilLock(0)) 
                     while RJ_ITEMS->(!Eof()) .and. RJ_ITEMS->RJI_LINK == RJ->RJ_001                 
                        RJ_ITEMS->(DbRecall())                  
                        RJ_ITEMS->(DbSkip())
                     enddo                 
                     RJ_ITEMS->(DbUnlock())                    
                     RJ->(RecLock(0))
                     RJ->(DbRecall())
                     RJ->RJ_012 := 4
                     RJ->(Dbunlock())
                  endif
                else
                   Message("Press ENTER to delete record, ESC to abort.")
                  if inkey(0)==K_ENTER
                     Message("Deleting current record....")
                     RJ_ITEMS->(DbSeek(RJ->RJ_001))
                     RJ_ITEMS->(FilLock(0)) 
                     while RJ_ITEMS->(!Eof()) .and. RJ_ITEMS->RJI_LINK == RJ->RJ_001                 
                        RJ_ITEMS->(DbDelete())                  
                        RJ_ITEMS->(DbSkip())
                     enddo                 
                     RJ_ITEMS->(DbUnlock())                     
                     RJ->(RecLock(0))
                     RJ->(Dbdelete())
                     RJ->RJ_012 := 3
                     RJ->(Dbunlock())
                  endif
                endif
              endif  
            case nKey==K_F5
               RJ->(Search_Form("Rej Ret No",8))
            case nKey==K_F6
               if (RJ->(Lastrec()) > 0)
                RJ->(Reclock()) 
                RJ->RJ_012 := 2
                RJ->(Dbunlock())
                RJ_ITEMS->(aBrowse2(RJ->RJ_001,aPicture2,EDIT_MODE))               
               endif 
         endcase
      enddo
   endif
   Message("Closing Databases....")
   DbCloseAll()
   aChoices := {}
   CloseWindow(wWindow)
   if NetUse("RJ_ITEMS",DB_EXCLUSIVE,NUM_SECONDS)
      RJ_ITEMS->(RecLock(0))
      RJ_ITEMS->(__DbPack())
      RJ_ITEMS->(DbUnlock())
      index on RJ_ITEMS->RJI_LINK to RJI_LINK
      RJ_ITEMS->(DbCloseArea())
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
      if RJ->(Deleted()) 
        @ 04,35 say "<deleted>"
      elseif RJ->RJ_010 != 0  
        @ 04,35 say " <posted>" 
      else  
        @ 04,35 say "         "
      endif
      @ 04, 62 say "Rec #"+transform(RJ->(recno()),"9999")
   endif
   
   setcolor( clr )
   @ 06,      09 say "       Return Number" get xGetVar[1] PICT "@K 99999999"  WHEN refno(nMode) VALID VldtReturns(nMode) 
   @ row()+1, 09 say " RR Reference Number" get xGetVar[2] PICT "@K 99999999"  WHEN PreVldtRec() VALID PostVldtRec()   
   @ row()+1, 09 say "       Supplier Code" get xGetVar[3] PICT "@K 999"  WHEN VldtVLnk() VALID PostVldtV()
   @ row()+1, 09 SAY "       Supplier Name" get xGetVar[4] PICT "@K " when .f. VALID !empty(xGetVar[4]) 
   @ row()+1, 09 SAY "    Transaction Date" get xGetVar[5] PICT "@K " VALID !empty(xGetVar[5])
   @ row()+1, 09 SAY "       Date Returned" get xGetVar[6] PICT "@K " VALID !empty(xGetVar[6])
   @ row()+1, 09 SAY "      Reference Type" get xGetVar[7] PICT "@K 9" RANGE 1,7
   @ row()+1, 09 SAY "    Reference Number" get xGetVar[8] PICT "@K " VALID !empty(xGetVar[8])  // WHEN refno(nMode) VALID !empty(xGetVar[8])
   @ row()+1, 09 SAY "      Reference Date" get xGetVar[9] PICT "@K " VALID !empty(xGetVar[9])
                                                                                                       
   if (nMode==APPEND_MODE) .or. (nMode==EDIT_MODE)
      crs := setcursor(SC_NORMAL)
      read
      if lastkey()!=K_ESC
         Screen_Save(nMode)
         if (RJ->(Lastrec()) > 0) 
            RJ_ITEMS->(aBrowse2(RJ->RJ_001,aPicture2,nMode))               
         endif 
      endif
      setcursor( crs )
   else
      clear gets
   endif
return nil

static function refno(nMode)
local nrecno := RJ->(Recno())


   if nMode == APPEND_MODE
      if RJ->(LastRec()) == 0
         xGetvar[1] := STR(1)
      endif
      RJ->(DbGoBottom())
      xGetvar[1] := STR(VAL(RJ->RJ_001) + 1)
      RJ->(DbGoto(nRecNo))
   endif
   xGetVar[1] :=  padl( alltrim(xGetVar[1]),8,"0")
return .T.


static function VldtReturn(Mode)
local lRetVal:= .t.,nRecNo:= RJ->(RecNo())
 if empty(xGetVar[1])
    return .f.
 endif
 xGetVar[1] :=  padl( alltrim(xGetVar[1]),8,"0")
 if (Mode == APPEND_MODE) .or. (Mode == EDIT_MODE .and. xGetVar[1] != RJ->RJ_001)
   RJ->(DbSeek(xGetVar[1]))
   if (RJ->(found()))
    lRetVal := .f.
    Message(" Rejection Return Number : "+xGetVar[1]+" already exist...")      
    Tone(300,3)
    Tone(500,3)
    Inkey(3)
    Tone(200,2)
   endif
   RJ->(DbGoto(nRecNo))
   MsgBar(BAR)
 endif
return lRetVal

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


static function PreVldtRec()
local lVal := .t. 
local bMyBlock,lSet
local nREcNo := RR->(RecNo())  

 Message(" Please Wait...") 
 bMyblock := {|| padr(" "+RR->RR_001+" Trans Date:"+dtoc(RR->RR_005),(maxcol()-46-2))}

 lSet := Set(_SET_DELETED,.t.) 
 RR->(DbSetFilter( {|| RR->RR_010 < 1 } ))
 if (RR->(DbfLookUp(8,45,bMyBlock,"RR Reference Link",xGetVar[2])) != 0)
     xGetVar[2] := RR->RR_001 
     xGetVar[3] := RR->RR_002
     if V->(DbSeek(RR->RR_002))
      xGetVar[4] := V->V_002
     endif 
     lVal := .f.
 endif
 Set(_SET_DELETED,lSet)
 RR->(DbGoto(nRecNo))
return lVal     


static function PostVldtRec()
local lRetVal:= .t.,nRecNo:= RR->(RecNo())

 if empty(xGetVar[2])
    return .t.
 endif
 
 xGetVar[2] :=  padl( alltrim(xGetVar[2]),8,"0")
 if !(RR->(DbSeek(xGetVar[2])))
    lRetVal := .f.
    Message(" Receiving Receipts Number : "+xGetVar[2]+" does not exist...")      
    Tone(300,3)
    Tone(500,3)
    Inkey(3)
    Tone(200,2)
     MsgBar(BAR)
 endif
 RR->(DbGoto(nRecNo))
return lRetVal

static function Screen_Init(nMode)
 if nMode==APPEND_MODE
	xGetVar[ 1] := SPACE(8)
	xGetVar[ 2] := SPACE(8)
	xGetVar[ 3] := SPACE(3)
	xGetVar[ 4] := SPACE(30)
	xGetVar[ 5] := DATE()
	xGetVar[ 6] := DATE()
	xGetVar[ 7] := 0
	xGetVar[ 8] := SPACE(10)
	xGetVar[ 9] := DATE()			       
 else
 	xGetVar[ 1] := RJ->RJ_001
	xGetVar[ 2] := RJ->RJ_002
	xGetVar[ 3] := RJ->RJ_003
	xGetVar[ 4] := RJ->RJ_004
	xGetVar[ 5] := RJ->RJ_005
	xGetVar[ 6] := RJ->RJ_006
	xGetVar[ 7] := RJ->RJ_007
	xGetVar[ 8] := RJ->RJ_008
	xGetVar[ 9] := RJ->RJ_009         			
 endif
return nil

static function Screen_Save(nMode)
   Message("Saving entries...")
   if nMode==APPEND_MODE
      RJ->(FilLock(0))
      RJ->(Dbappend())
      RJ->RJ_012 := 1
      RJ->(DbUnLock())
   else
      RJ->(RecLock(0))
      RJ->RJ_012 := 2   
      RJ->(DbUnLock())
   endif
      RJ->(RecLock(0))
      RJ->RJ_001 := xGetVar[1]
      RJ->RJ_002 := xGetVar[2]
      RJ->RJ_003 := xGetVar[3]
      RJ->RJ_004 := xGetVar[4]
      RJ->RJ_005 := xGetVar[5]
      RJ->RJ_006 := xGetVar[6]
      RJ->RJ_007 := xGetVar[7]
      RJ->RJ_008 := xGetVar[8]
      RJ->RJ_009 := xGetVar[9]
      RJ->(DbUnlock())
      RJ->(DbCommit())
return nil

//end-of-file
