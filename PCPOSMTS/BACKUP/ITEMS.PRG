*** ITEMS.PRG ***

#include "box.ch"
#include "its.ch"
#include "inkey.ch"
#include "Janus.ch"
#include "aChoice.ch"
#include "setcurs.ch"

#ifdef COLOR_STAT
#define BAR "F2-Add F3-Edit F4-Delete F5-Code F6-Desc F7-Stock F8-Vendor ESC-Abort"
#else
#define BAR "F2-Add F3-Edit F4-Delete F5-Code F6-Desc F7-Stock F8-Supp. ESC-Abort"
#endif

static getlist := {}
memvar nUnit 

static xGetVar,aPicture3,nCheck,npercent,nPrice,nMark

#ifdef CLASS_LINK
static aClass := {}
#else
static aDept := {}
#endif
static aVen := {}
static aType := {}
static abrdn:={}
static aChoices := {}
static aCosts := {}

//jzo04-01-98
static dstrt,dend

function do_Items()
local wWindow, nkey
   nPercent := 0
   xGetVar := array(39+4)
   aPicture3 := array(5,3)
   aPicture3[1,1] := FieldBlock("IV_LINK")
   aPicture3[1,2] := "@!"
   aPicture3[1,3] := .f.
   aPicture3[2,1] := FieldBlock("IV_CODE")
   aPicture3[2,2] := "@K 999"
   aPicture3[2,3] := .t.   
   aPicture3[3,1] := FieldBlock("IV_NAME")
   aPicture3[3,2] := repl("X",20)
   aPicture3[3,3] := .f.
   aPicture3[4,1] := FieldBlock("IV_COST")
   aPicture3[4,2] := "@K 99,999.99"
   aPicture3[4,3] := .t.
   aPicture3[5,1] := FieldBlock("IV_OQTY")
   aPicture3[5,2] := "@K 999,999.999"
   aPicture3[5,3] := .t.         
   nCheck := 1
   Message("Opening Databases...")
#ifdef FM_ITEMS   
   if NetUse("FM",DB_SHARED,NUM_SECONDS)
      set index to FM
   endif   
#endif
   if NetUse("V",DB_SHARED,NUM_SECONDS)
      SET INDEX to V_001
   endif 
   if NetUse("IV",DB_SHARED,NUM_SECONDS)
      SET INDEX TO IV_LINK
   endif
   if NetUse("BR",DB_SHARED,NUM_SECONDS)
      SET INDEX TO BR_001
   endif   
   if NetUse("DP",DB_SHARED,NUM_SECONDS)
      SET INDEX TO DP_001
   endif
#ifdef CLASS_LINK
   if NetUse("CL",DB_SHARED,NUM_SECONDS)
      SET INDEX TO CL_001
   endif
#endif   
   if NetUse("UITEMS",DB_SHARED,NUM_SECONDS)
      Set Index to UITEMS
   endif   
   if NetUse("ITEM.DBF",DB_SHARED,NUM_SECONDS)
      Set Index to I_001,I_002,I_033,I_020
   endif   

   wWindow := OpenWindow(02,04,22,73,"Item File")
   @ 16-3, 08 say repl("-",64)
   if ITEM->(reccount())==0 ; Screen_Form(APPEND_MODE) ; endif
   if lastKey()!=K_ESC
      do while (nkey!=K_ESC)
         if !UITEMS->(DbSeek(ITEM->I_001)) 
            alert("ERROR in UNIT BRANCH link...;Data might not be accurate.;Rebuild Indices!!!")
         endif
         Screen_Form(VIEW_MODE)
         nkey:=inkey(0)
         do case
            case nkey==K_DOWN
               ITEM->(Dbskip())
               if ITEM->(eof())
                  ITEM->(Dbgobottom())
                  tone(100,3)
                  Message("End of file reached....")
                  inkey(1)
               endif
            case nKey==K_UP
               ITEM->(Dbskip(-1))
               if ITEM->(bof())
                  ITEM->(Dbgotop())
                  tone(100,3)
                  Message("Beginning of file reached....")
                  inkey(1)
               endif
            case nKey==K_CTRL_PGDN
               ITEM->(Dbskip(NUM_TO_SKIP))
               if ITEM->(eof())
                  ITEM->(Dbgobottom())
                  tone(100,3)
                  Message("End of file reached....")
                  inkey(1)
               endif
            case nKey==K_CTRL_PGUP
               ITEM->(Dbskip(-NUM_TO_SKIP))
               if ITEM->(bof())
                  ITEM->(Dbgotop())
                  tone(100,3)
                  Message("Beginning of file reached....")
                  inkey(1)
               endif
            case nKey==K_END
               ITEM->(Dbgobottom())
                  Message("Moving to end of file....")
                  inkey(1)
            case nKey==K_HOME
               ITEM->(Dbgotop())
                  Message("Moving to beginning of file....")
                  inkey(1)
            case nKey==K_F2
                  if nUnit != 0
                     Message("Cannot Append on UNIT; Select WAREHOUSE to add item records")
                     BUMMER()
                     HEYTHERE()
                     BUMMER()
                     OKDONE()
                  else
                    Screen_Form(APPEND_MODE)
                  endif
            case nKey==K_F3
                  if (ITEM->I_019 != 2)
                    Screen_Form(EDIT_MODE)
                  endif
            case nKey==K_F4
               if ITEM->(Deleted())
                 Message("Press ENTER to Undelete record, ESC to abort.")
                 if inkey(0)==K_ENTER
                    Message("Undeleting current record....")
                    DelRecall(0)
                    // have to do this also on other units
                    IV->(DbSeek(ITEM->I_001))
                    IV->(FilLock(0)) 
                    while IV->(!Eof()) .and. IV->IV_LINK == ITEM->I_001 
                       IV->(DbRecall())                       
                       IV->(DbSkip())
                    enddo
                    IV->(DbUnlock())                            
                    ITEM->(RecLock(0))
                    ITEM->(DbRecall())
                    ITEM->I_039 := 4
                    if ITEM->I_019 == 0
                       ITEM->I_019 := 0
                    elseif ITEM->I_019 == 9
                       ITEM->I_019 := 0
                    elseif ITEM->I_019 == 2
                       ITEM->I_019 := 9
                    endif
                    ITEM->(Dbunlock())
#ifdef FM_ITEMS                    
                  FM->(FilLock())
                  FM->(DbAppend())
                  FM->TRANSNO := FMNext()
                  FM->OP_CODE := "02" // EDIT
                  FM->OP_FLAG := 1
                  FM->FILE_ID := "PL" // File ID Item
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
                    DelRecall(1)
                    IV->(DbSeek(ITEM->I_001))
                    IV->(FilLock(0)) 
                    while IV->(!Eof()) .and. IV->IV_LINK == ITEM->I_001                 
                       IV->(DbDelete())
                       IV->(DbSkip())
                    enddo                   
                    IV->(DbUnlock())
                    ITEM->(RecLock(0))
                    ITEM->(DbDelete())
                    ITEM->I_039 := 3
                    if ITEM->I_019 == 0
                       ITEM->I_019 := 09
                    else
                       ITEM->I_019 := 02
                    endif
                    ITEM->(Dbunlock())
#ifdef FM_ITEMS                    
                   FM->(FilLock())
                   FM->(DbAppend())
                   FM->TRANSNO := FMNext()
                   FM->OP_CODE := "03" // Delete
                   FM->OP_FLAG := 1
                   FM->FILE_ID := "PL" // File ID item
                   FM->RECDATA := GetData()
                   FM->POSTDATE:= Date()
                   FM->POSTSTAT:= 0
                   FM->(DbUnLock())
#endif                   
                 endif
               endif
            case nKey==K_F5
               ITEM->(Search_Form("Item",PLU_CODE_LEN))
            case nKey==K_F6
               ITEM->(DbSetOrderto(2))
               ITEM->(Search_Desc("Descriptor",PLU_DESC_LEN))
               ITEM->(DbSetOrderto(1))
            case nKey==K_F7
               ITEM->(DbSetOrderto(3))
               ITEM->(Search_Form("Stock",PLU_CODE_LEN))
               ITEM->(DbSetOrderto(1))            
            case nKey==K_F8
              IV->(aBrowse3(ITEM->I_001,aPicture3,VIEW_MODE))
         endcase
      enddo
   endif
   Message("Closing Databases....")
   ITEM->(DbCloseArea())
   UITEMS->(DbCloseArea())
#ifdef CLASS_LINK
   CL->(DbCloseArea())
#endif   
   br->(dbclosearea())
   DP->(DbCloseArea())
   V->(DbCloseArea()) 
   IV->(DbCloseArea())
#ifdef FM_ITEMS   
   FM->(DbCloseArea())
#endif
#ifdef CLASS_LINK
   aClass    := {}  // Free all
#endif   
   aChoices  := {}  // memory allocated
   aCosts    := {}  // for the static
   getlist   := {}  // variables 
   xGetVar   := {}
   aPicture3 := {}

   aDept     := {}  //added by jzo04-01-98
   CloseWindow(wWindow)
return nil

static function Screen_Form(nMode)
local clr, crs
   tone(300,1)
   Screen_Init(nMode)
   MsgBar(BAR)
   clr := setcolor(TITLE_ATTR)
   if nMode==APPEND_MODE
       @ 04-2,62 say "< New >   "
       @ 04-2,35 say "         "
   else
      if (ITEM->(Deleted()))
        @ 04-2,35 say "<deleted>"
      else
        @ 04-2,35 say "         "
      endif
      @ 04-2, 62 say "Rec #"+transform(ITEM->(recno()),"99999")
   endif
   setcolor( clr )

   @ 06-2,     08 say  "Supplier Code:" get xGetVar[20] PICT "999" WHEN  VldtVen() VALID PostVldVen()
#ifdef CLASS_LINK   
   @ row()+1, 08 say " Class Number:" get xGetVar[06] PICT "@K 9999"   WHEN  VldtClsLnk() VALID PostVldtCl()
#else
   @ row()+1, 08 say "    Dept. No.:" get xGetVar[06] PICT "@K 99"   WHEN  VldtDeptLnk() VALID PostVldtDp()
#endif   
   
   @ row() + 1,      08 say "    Item Code:" get xGetVar[01] PICT "@K! "+repl("X",PLU_CODE_LEN)  VALID VldtItem(nMode)
   @ row(),      24+PLU_CODE_LEN get xGetVar[36] PICT "9" WHEN .f.

   @ row()+1, 08 say "   Brand Name:" get xGetVar[41] pict "@S20! " when vldtbrdn(xGetVAr[41]) valid postvldbrdn() // valid !empty(xGetVar[41])
         
   @ row()+1, 08 say "  Recpt Descr:" get xGetVar[02] PICT "@! "+ repl("X",PLU_DESC_LEN) VALID !EMPTY (xGetVar[2])
   @ row()+1, 08 say "     Tax Rate:" get xGetVar[04] PICT "@K 99" VALID(xGetVar[4] >= 0)
   @ row()+1, 08 say " Report Descr:" get xGetVar[37] PICT "@S16! " VALID !EMPTY (xGetVar[37])

   @ row()+1, 08 say " Unit of Msr.:" get xGetVar[05] PICT "@K! AAAAAAAAAA"

   @ row()+1, 08 say "Unit Per Case:" get xGetVar[42] pict "@K 9999" valid !empty(xGetVar[42])
   
   @ 06-2, 43 say "   Stock Code:" get xGetVar[33] PICT "@K "+repl("9",PLU_CODE_LEN) when VldtStock(nMode) Valid Stock(nMode)
//   @ row()+1, 43 say "        Color:" get xGetVar[23] PICT "@K! XXXXXXXXXXXX"
   @ row()+1, 43 say "         Type:" get xGetVar[24] PICT "@K! XXXXXXXXXXXX" when prevldtType() valid vldttype()

   @ row()+1, 43 say "    Unit Cost:" get xGetVar[07] PICT "@K 9,999.99"  // VALID (!empty(xGetvar[07])) // WHEN PreVldtCost(nMode) VALID (xGetVar[7] > 0)
   @ row()+1, 43 say "      Mark Up:" get xGetVar[43] pict "@K 999,999,999.99"
     

//   if nMode == APPEND_MODE .or. nMode == EDIT_MODE
//      nPrice := ( xGetVar[07] * (xGetVar[43]/100) ) + xGetVar[07]
//      xGetVar[3] := compucost(nPrice)
//   endif           // jlp.06.18.98.
     
   @ row()+1, 43 say "Selling Price:" get xGetVar[3] PICT "@K 999,999.99" WHEN CompuPrice(nMode) 

   @ row()+1, 43 say "Maximum Level:" get xGetVar[10] PICT "@K 999,999.999" // VALID (xGetVar[10] > 0)
   @ row()+1, 43 say "Minimum Level:" get xGetVar[11] PICT "@K 999,999.999" // VALID (xGetVar[11] > 0 .and. lChkVal(xGetVar[11], .t.))
   @ row()+1, 43 say "Reorder Level:" get xGetVar[12] PICT "@K 999,999.999" // VALID (xGetVar[12] > 0 .and. lChkVal(xGetVar[12], .f.))

   @ 17-2,    09 say "  Stock Balance:" get xGetVar[08] PICT "@K 9,999,999.999" WHEN .f.
   @ row()+1, 09 say " Beg. Inventory:" get xGetVar[09] PICT "@K 9,999,999.999" WHEN .f.
   @ row()+1, 09 say "  Date Received:" get xGetVar[14] WHEN .F.
   @ row()+1, 09 say " Stock Out Date:" get xGetVar[15] WHEN .F.
   @ row()+1, 09 say "   Reorder Date:" get xGetVar[16] WHEN .F.
   @ row()+1, 09 say "  Daily Sales %:" get xGetVar[34] PICT "999.999%" WHEN .f.
   @ row()+1, 09 say "Monthly Sales %:" get xGetVar[35] PICT "999.999%" WHEN .f.

//jzo05-12-98   @ 17-2   , 41 say "       AGE CODE:" get xGetVar[38] PICT "@K 9999 " WHEN .f.
   @ 17-2, 41 say "POS Amount Sold:" get xGetVar[18] PICT "@K 99,999,999.99" WHEN .F.
   @ row()+1, 41 say "   POS Quantity:" get xGetVar[17] PICT "@K 999,999.999" WHEN .F.
   @ row()+1, 41 say "  Monthly Sales:" get xGetVar[29] PICT "@K 99,999,999.99" WHEN .F.
   @ row()+1, 41 say "Monthly Qty Sls:" get xGetVar[30] PICT "@K 999,999.999" WHEN .F.
   @ row()+1, 41 say "   Annual Sales:" get xGetVar[31] PICT "@K 99,999,999.99" WHEN .F.
   @ row()+1, 41 say " Annual Qty Sls:" get xGetVar[32] PICT "@K 999,999.999" WHEN .F.

   if (nMode==APPEND_MODE) .or. (nMode==EDIT_MODE)
      crs := setcursor(SC_NORMAL)
      read
      if lastkey()!=K_ESC .and. (xGetvar[07] <> 0 .or. xGetvar[03] <> 0)
         if xGetVar[19] == 9
            xGetVar[19] := if(nMode==EDIT_MODE,1,0)
         endif
         Screen1_Save(nMode)
      endif
      setcursor( crs )
   else
      clear gets
   endif
return nil

/* validate minimum and reorder value */
static function lChkVal(nVal, lType)
 local stat := .f.
 if lType           // minimum
  if nVal >= xGetVar[10]
   xGetVar[11] := 0.00
   stat := .f.
   alert("Value must be lower than Maximum")
  else
   stat := .t.
  endif
 else               // reorder
  if nVal < xGetVar[11] .or. nVal > xGetVar[10]
   xGetVar[12] := 0.00
   stat := .f.
   alert("Must be less than Maximum and higher than Minimum")
  else
   stat := .t.
  endif
 endif
return stat


static function compucost(nret)
local npcent := 0
local npercent:=0
local nVal

  DP->(DBSEEK(xGetVar[06]))

  if date() >= DP->DP_006 .and. date() <= DP->DP_007

     if nret == 0   
       return 0
     endif 

//   if DP->(dbSeek(xGetvar[06]))
     nPercent := DP->DP_009
//   endif

     npcent := 100 - npercent
     nVal := nret * (npcent/100)
//     xGetVar[3] := nVal

   else
     return nret
   endif

return nVal


static function PreVldtType()
local  lVal:= .t.,n:=0
 if empty(aType)
     aAdd(aType," "+"BASIC    "+" ")
     aAdd(aType," "+"NON-BASIC"+" ")
 endif

 if (( n:= LookUp(9,60,aType,"Type",xGetVar[24])) != 0)
       xGetVar[24] := substr(aType[n],2)
       lVal :=  .f.
 endif
 MsgBar(BAR) 
return lVal

static function vldttype()
xGetVar[24] := padr(xGetVar[24],12)
return .t.


static function PreVldtCost(nMode)
local n:=0,mCursor

 mCursor := SetCursor(0)
 IV->(aBrowse3(xGetVar[1],aPicture3,nMode))
 SetCursor(mCursor)

 aChoices := {}
 aCosts   := {}
 IV->(DbSeek(xGetVar[1]))
 while IV->(!eof()) .and. IV->IV_LINK == xGetVar[1]
    if IV->(!Deleted())
       aAdd(aChoices," "+IV->IV_CODE+" "+IV->IV_NAME+" COST:"+trans(IV->IV_COST,"99,999.99")+" ")
       aAdd(aCosts,IV->IV_COST)
    endif
    IV->(DbSkip())
 enddo

 if (( n:= LookUp(09,35,aChoices,"Supplier Link",xGetVar[20])) != 0)
       xGetVar[20] := subs(aChoices[n],2,3)
       xGetVar[07] := aCosts[n]
 endif
return .f.


static function VldtItem(Mode)
local lRetVal:= .t.,nRecno := ITEM->(RecNo())
 if empty(xGetVar[1])
    return .f.
 endif

  xGetVar[1] := subs(alltrim(xGetvar[1]),1,PLU_CODE_LEN)
  xGetVar[1] := padl( alltrim(xGetVar[1]),PLU_CODE_LEN,"0")
 
 if (Mode == APPEND_MODE) .or. (Mode == EDIT_MODE .and. xGetVar[1] != ITEM->I_001)
   ITEM->(DbSeek(xGetVar[1]))
   if (ITEM->(found()))
    lRetVal := .f.
    Message(" Item code : "+xGetVar[1]+" already exist...")      
    Tone(300,3)
    Tone(500,2)
    Inkey(3)
    Tone(200)
   endif
   ITEM->(DbGoto(nRecNo))
   MsgBar(BAR)
 endif

 xGetvar[36] := getchkdgt(xGetVar[1])
 
return lRetVal

static function VldtStock(Mode)
local lRetVal:= .t.

 xGetVar[33] := xGetvar[1]

 if empty(xGetVar[33])
    return .f.
 endif

 
 xGetVar[33] := padl( alltrim(xGetVar[33]),PLU_CODE_LEN,"0")

return lRetVal

static function Stock(Mode)
local lRetval := .t.,nRecno := ITEM->(RecNo()) 
 
 if (Mode == APPEND_MODE) .or. (Mode == EDIT_MODE .and. xGetVar[33] != ITEM->I_033)
   ITEM->(DbSetOrderTo(3))
   ITEM->(DbSeek(xGetVar[33]))
   ITEM->(DbSetOrderTo(1))
   if (ITEM->(found()))
    lRetVal := .f.
    Message(" Stock code : "+xGetVar[33]+" already exist...")      
    Tone(300,3)
    Tone(500,2)
    Inkey(3)
    Tone(200)
   endif
   ITEM->(DbGoto(nRecNo))
   MsgBar(BAR)
 endif 
return lRetVal

function getchkdgt(cCode)
local nTotal1,nTotal2,k
local nTotal,cTotal
 nTotal1 := 0
 for k := 2 to len(cCode) step 2
    nTotal1 += val(subs(cCode,k,1))
 next k

 nTotal1 *= 3

 nTotal2 := 0 
 for k := 1 to len(cCode)-1 step  2
    nTotal2 += val(subs(cCode,k,1))
 next k

 nTotal := nTotal1 + nTotal2
 cTotal := alltrim(str(nTotal))

 nTotal := val(right(cTotal,1))

return  if(nTotal==0,0,(10 - nTotal))


static function Vldtbrdn(cbrand_name)
local  lVal:= .t.,n:=0
abrdn := {}

 if empty(abrdn)
   br->(DbGotop())
   while br->(!eof())
      if br->(!Deleted())
       aAdd(abrdn," "+br->br_001+" "+br->br_002+" ")
      endif
      br->(DbSkip())
   enddo
 endif
 if (( n:= LookUp(11,13,abrdn,"Brand Link",xGetVar[41])) != 0)
       xGetVar[41] := substr(abrdn[n],7,37)
       lVal :=  .f.
 endif
 MsgBar(BAR) 
return lVal


static function PostVldbrdn()
local lVal := .t.
 if empty(xGetVar[41])
    return .f.
 endif
 xGetVar[41] :=  padl( alltrim(xGetVar[41]),25)
 br->(DbGotop())
 if !br->(DbSeek(xGetVar[41]))
   lVal := .f.
   Message(" Brand Name Link "+alltrim(xGetVar[41])+" does not exist.... ")
   Tone(500,3)
   Inkey(1)
   Tone(200,2)
 endif  
 
  while Inkey() != 0 ; enddo
  MsgBar(BAR)
  xGetVar[41] := alltrim(xGetVar[41])
return lVal



static function VldtVen()
local  lVal:= .t.,n:=0
aVen := {}
 if empty(aVen)
   V->(DbGotop())
   while V->(!eof())
      if V->(!Deleted())
       aAdd(aVen," "+V->V_001+" "+V->V_002+" ")
      endif
      V->(DbSkip())
   enddo
 endif
 if (( n:= LookUp(11,13,aVen,"Supplier Link",xGetVar[20])) != 0)
       xGetVar[20] := substr(aVen[n],2,3)
       lVal :=  .f.
 endif
 MsgBar(BAR) 
return lVal


static function PostVldVen()
local lVal := .t.
 if empty(xGetVar[20])
    return .f.
 endif
 xGetVar[20] :=  padl( alltrim(xGetVar[20]),3,"0")
 V->(DbGotop())
 if !V->(DbSeek(xGetVar[20]))
   lVal := .f.
   Message(" Supplier Link Number "+xGetVar[20]+" does not exist.... ")
   Tone(500,3)
   Inkey(1)
   Tone(200,2)
 endif  
 
  while Inkey() != 0 ; enddo
  MsgBar(BAR)
return lVal


#ifdef CLASS_LINK
static function VldtClsLnk()
local  lVal:= .t.,n:=0
aClass := {}
 if empty(aClass)
   CL->(DbGotop())
   while CL->(!eof())
      if CL->(!Deleted())
       aAdd(aClass," "+CL->CL_001+" "+CL->CL_002+" ")
      endif
      CL->(DbSkip())
   enddo
 endif
 if (( n:= LookUp(11,13,aClass,"Class Link",xGetVar[6])) != 0)
       xGetVar[6] := subs(aClass[n],2,4)
       lVal :=  .f.
 endif
 MsgBar(BAR) 
return lVal

static function PostVldtCl()
local lVal := .t.
 if empty(xGetVar[6])
    return .f.
 endif
 xGetVar[6] :=  padl( alltrim(xGetVar[6]),4,"0")
 CL->(DbGotop())
 if !CL->(DbSeek(xGetVar[6]))
   lVal := .f.
   Message(" Class Link Number "+xGetVar[6]+" does not exist.... ")
   Tone(500,3)
   Inkey(1)
   Tone(200,2)
 endif  
 
  while Inkey() != 0 ; enddo
  MsgBar(BAR)
return lVal
#else
static function VldtDeptLnk()
local  lVal:= .t.,n:=0
 if empty(aDept)
   DP->(DbGotop())
   while DP->(!eof())
      if DP->(!Deleted())
       aAdd(aDept," "+DP->DP_001+" "+DP->DP_002+" ")
      endif
      DP->(DbSkip())
   enddo
 endif
 if (( n:= LookUp(11,13,aDept,"Department Link",xGetVar[6])) != 0)
       xGetVar[6] := subs(aDept[n],2,2)
       lVal :=  .f.
 endif
 MsgBar(BAR) 
return lVal

static function PostVldtDP()
local lVal := .t.
 if empty(xGetVar[6])
    return .f.
 endif
 xGetVar[6] :=  padl( alltrim(xGetVar[6]),2,"0")
 DP->(DbGotop())
 if !DP->(DbSeek(xGetVar[6]))
   lVal := .f.
   Message(" Department Link  Number "+xGetVar[6]+" does not exist.... ")
   Tone(500,3)
   Inkey(1)
   Tone(200,2)
 endif
  while Inkey() != 0 ; enddo
  MsgBar(BAR)
return lVal
#endif

static function Screen_Init(nMode)
 if nMode==APPEND_MODE
        xGetVar[ 1] := SPACE(PLU_CODE_LEN)
        xGetVar[ 2] := SPACE(PLU_DESC_LEN)
        xGetVar[ 3] := 0.00
        xGetVar[ 4] := 0
        xGetVar[ 5] := SPACE(10)

#ifdef CLASS_LINK
//        xGetVar[ 6] := SPACE(4)
        xGetVar[ 6] := SPACE(6)
#else   
        xGetVar[ 6] := SPACE(2)
#endif  
        xGetVar[ 7] := 0
        xGetVar[ 8] := 0
        xGetVar[ 9] := 0
        xGetVar[10] := 100000
        xGetVar[11] := 1000
        xGetVar[12] := 5000
        xGetVar[13] := 0
        xGetVar[14] := date()
        xGetVar[15] := date()
        xGetVar[16] := date()
        xGetVar[17] := 0
        xGetVar[18] := 0
        xGetVar[19] := 0
        xGetVar[20] := space(3)
/*      xGetVar[21] := 0
        xGetVar[22] := 0 */
        xGetVar[23] := space(12)
        xGetVar[24] := space(12)
        xGetVar[25] := 0
        xGetVar[26] := date()
        xGetVar[27] := 0
        xGetVar[28] := 0
        xGetVar[29] := 0
        xGetVar[30] := 0
        xGetVar[31] := 0
        xGetVar[32] := 0
        xGetVar[33] := space(PLU_CODE_LEN)
        xGetVar[34] := 0
        xGetVar[35] := 0
        xGetVar[36] := 0
        xGetVar[37] := space(40)
        xGetVar[38] := substr(dtoc(date()),1,2) + substr(dtoc(date()),7,2)

        xGetVar[40] := space(4)
        xGetVar[41] := space(25)
        xGetVar[42] := space(4)
        xGetVar[43] := 0
 else
        xGetVar[ 1] := ITEM->I_001
        xGetVar[ 2] := ITEM->I_002
        xGetVar[ 3] := ITEM->I_003
        xGetVar[ 4] := ITEM->I_004
        xGetVar[ 5] := ITEM->I_005
        xGetVar[ 6] := ITEM->I_006
        xGetVar[ 7] := ITEM->I_007
        xGetVar[ 8] := UITEMS->UI_STK_BAL //ITEM->I_008
        xGetVar[ 9] := UITEMS->UI_BEG_BAL //ITEM->I_009
        xGetVar[10] := UITEMS->UI_MAX_BAL //ITEM->I_010
        xGetVar[11] := UITEMS->UI_MIN_BAL //ITEM->I_011
        xGetVar[12] := UITEMS->UI_REORDER //ITEM->I_012
        xGetVar[13] := UITEMS->UI_P_COUNT //ITEM->I_013
        xGetVar[14] := UITEMS->UI_DATEREC //ITEM->I_014
        xGetVar[15] := UITEMS->UI_STK_OUT //ITEM->I_015
        xGetVar[16] := UITEMS->UI_REODATE //ITEM->I_016
        xGetVar[17] := UITEMS->UI_ECRDCNT 
        xGetVar[18] := UITEMS->UI_ECRDSLS 
        xGetVar[19] := ITEM->I_019
        xGetVar[20] := ITEM->I_020
/*      xGetVar[21] := ITEM->I_021
        xGetVar[22] := ITEM->I_022*/
        xGetVar[23] := ITEM->I_023
        xGetVar[24] := ITEM->I_024
        xGetVar[25] := ITEM->I_025
        xGetVar[26] := ITEM->I_026

        xGetVar[27] := UITEMS->UI_ACCDSLS // ITEM->I_027
        xGetVar[28] := UITEMS->UI_ACCDCNT // ITEM->I_028
        xGetVar[29] := UITEMS->UI_ECRMSLS // ITEM->I_029
        xGetVar[30] := UITEMS->UI_ECRMCNT // ITEM->I_030
        xGetVar[31] := UITEMS->UI_ECRASLS // ITEM->I_031
        xGetVar[32] := UITEMS->UI_ECRACNT // ITEM->I_032 
        xGetVar[33] := ITEM->I_033
        xGetVar[34] := UITEMS->UI_DSLRATE // ITEM->I_034
        xGetVar[35] := UITEMS->UI_MSLRATE // ITEM->I_035
        xGetVar[36] := ITEM->I_036
        xGetVar[37] := ITEM->I_037
        xGetVar[38] := ITEM->I_038

        xGetVar[40] := ITEM->I_040
        xGetVar[41] := ITEM->I_041
        xGetVar[42] := ITEM->I_042        
        xGetVar[43] := ITEM->I_043
   endif
return nil

static function Screen1_Save(nMode)
local aUnits := {},n
local oldPath := set(_SET_PATH)
local cKeyCode

   Message("Saving entries...")

   aUnits := getUnits()

   // then close this unit
   UITEMS->(DbCloseArea())

   for n:= 1 to len(aUnits)   
      Message("Saving entries to "+aUnits[n][2]+"...")
      set(_SET_PATH,aUnits[n][3])

      if NetUse("UITEMS",DB_SHARED,NUM_SECONDS)
        Set Index to "UITEMS"
      endif

      UITEMS->(FilLock(0))
      if nMode == APPEND_MODE
         UITEMS->(DbAppend())
         UITEMS->UI_MAX_BAL := xGetVar[10]
         UITEMS->UI_MIN_BAL := xGetVar[11]
         UITEMS->UI_REORDER := xGetVar[12]
         UITEMS->UI_OP_FLAG := 1
      else
         if !UITEMS->(DbSeek(xGetVar[1]))
            UITEMS->(DbAppend())
            UITEMS->UI_MAX_BAL := xGetVar[10]
            UITEMS->UI_MIN_BAL := xGetVar[11]
            UITEMS->UI_REORDER := xGetVar[12]
            
         endif
         UITEMS->UI_OP_FLAG := 2
      endif

      UITEMS->UI_PLUCODE := xGetVar[1]
      UITEMS->UI_STKCODE := xGetVar[33]

      UITEMS->(DbCommit())
      UITEMS->(DbUnlock())
      UITEMS->(DbCloseArea())
   next

   Message("Saving entries to central database...")

   set(_SET_PATH, oldPath)     // Restore Previous Active unit
   if NetUse("UITEMS",DB_SHARED,NUM_SECONDS)
      Set Index to "UITEMS"
   endif
   if UITEMS->(DbSeek(xGetvar[1]))
      UITEMS->(Reclock(0))
      UITEMS->UI_MAX_BAL := xGetVar[10]
      UITEMS->UI_MIN_BAL := xGetVar[11]
      UITEMS->UI_REORDER := xGetVar[12]
      // UITEMS->UI_OP_FLAG := 2
      UITEMS->(DbUnLock())
   endif

   if nMode==APPEND_MODE
      ITEM->(FilLock(0))
      ITEM->(Dbappend())
      ITEM->I_039 := 1
      ITEM->(DbUnLock())
   else
      ITEM->(RecLock(0))
      ITEM->I_039 := 2
      ITEM->(DbUnLock())   
   endif

      ITEM->(RecLock(0))
      ITEM->I_001 := xGetVar[ 1]
      ITEM->I_002 := xGetVar[ 2]

   // xGetvar[03]:=( xGetVar[07] * xGetVar[43] ) + xGetVar[07]
   // xGetVar[03]:=compucost(xGetVar[03]) //jzo


   // nPrice:=( xGetVar[07] * (xGetVar[43]/100) ) + xGetVar[07]
   // nPrice:=compucost(nPrice) //jzo

   // if nPrice > 0
   //    xGetVar[3]:=nPrice
   // endif

      ITEM->I_003 := xGetVar[ 3]
      ITEM->I_004 := xGetVar[ 4]
      ITEM->I_005 := xGetVar[ 5]
      ITEM->I_006 := xGetVar[ 6]
      ITEM->I_007 := xGetVar[ 7]

      ITEM->I_008 := xGetVar[ 8]
      ITEM->I_009 := xGetVar[ 9] 

      ITEM->I_010 := xGetVar[10]
      ITEM->I_011 := xGetVar[11]
      ITEM->I_012 := xGetVar[12]

//    ITEM->I_013 := xGetVar[13]
      ITEM->I_014 := xGetVar[14] 
      ITEM->I_015 := xGetVar[15] 

      ITEM->I_019 := xGetVar[19]  // Modified PLU
      ITEM->I_020 := xGetVar[20]

/*    ITEM->I_021 := xGetVar[21]
      ITEM->I_022 := xGetVar[22]*/

      ITEM->I_023 := xGetVar[23]
      ITEM->I_024 := xGetVar[24]
      ITEM->I_025 := xGetVar[25]
      ITEM->I_026 := xGetVar[26]

      ITEM->I_029 := xGetVar[29]
      ITEM->I_030 := xGetVar[30] 
      ITEM->I_031 := xGetVar[31]
      ITEM->I_032 := xGetVar[32] 

      ITEM->I_033 := xGetVar[33]

/*    ITEM->I_034 := xGetVar[34]
      ITEM->I_035 := xGetVar[35] */

      ITEM->I_036 := xGetVar[36]
      ITEM->I_037 := xGetVar[37]
      ITEM->I_038 := xGetVar[38]

      ITEM->I_040 := xGetVar[40]
      ITEM->I_041 := xGetVar[41]
      ITEM->I_042 := xGetVar[42]
      ITEM->I_043 := xGetVar[43]
      
      ITEM->(DbCommit())
      ITEM->(DbUnlock())

      // xGetVar[03]:=compucost(xGetVar[03]) //jzo  1.jlp.
      
#ifdef FM_ITEMS
     FM->(FilLock(1))
     FM->(DbAppend())
     FM->TRANSNO := FMNext()
     FM->OP_CODE := if (APPEND_MODE==nMode,"01","02") // ADD,OVERWRITE
     FM->OP_FLAG := 1
     FM->FILE_ID := "PL" // File ID Item
     FM->RECDATA := GetData()
     FM->POSTDATE:= Date()
     FM->POSTSTAT:= 0
     FM->(DbUnLock())
#endif
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

static function GetData()
local cData

      cData := ITEM->I_001      // PLU item Code 
      cData += SUBSTR(ITEM->I_033,3,12)    // Stock Code,
      cData += ITEM->I_002      // PLU Descriptor
      cData += "00"                  // Size
      cData += "00"                  // Color
      #ifdef CLASS_LINK 
         cData += right(ITEM->I_006,4)       // Class Code      
      #else
         cData += right(ITEM->I_006,4)       // Department Code
      #endif    
      #ifdef CLASS_LINK
         if CL->(DbSeek(ITEM->I_006)) 
             cData += "00"+right(CL->CL_003,2)   // Associated Department
         else
             cData += "0000"
         endif      
      #else
         cData += "00"+right(ITEM->I_006,2)
      #endif             
      cData += "0"+right(ITEM->I_020,3)          // Vendor Code
      
//    cData += padl(alltrim(strtran(str(ITEM->I_003),".","")),10,"0") // selling price
//jzo04-01-98
      cData += padl(alltrim(strtran(str(round(ITEM->I_003,2)),".","")),10,"0") // selling price

      cData += repl("0",10) // price level 1
      cData += repl("0",10) // price level 2
      cData += repl("0",10) // price level 3
      cData += repl("0",10) // price level 4
      cData += repl("0",10) // price level 5
      cData += padl(alltrim(strtran(str(ITEM->I_007),".","")),10,"0") // unit cost

      DP->(DBSEEK(xGetVar[06]))
      dstrt:=DP->DP_006
      dend:=DP->DP_007

      cData += subs(dtoc(dstrt),1,2)  // time start
      cData += subs(dtoc(dstrt),4,2)

      cData += subs(dtoc(dend),1,2)   // time end
      cData += subs(dtoc(dend),4,2)
            
     // cData += repl("0",4)  // time start
     // cData += repl("0",4)  // time end


//      Message("dstrt "+dtoc(dstrt)+" dend "+dtoc(dend))
//      inkey(0)
//jzo
/*      
      cData += subs(dtoc(dstrt),1,2)+;
               subs(dtoc(dstrt),4,2)+;
               subs(dtoc(dstrt),7,2)   // Start Date
      cData += subs(dtoc(dend),1,2)+;
               subs(dtoc(dend),4,2)+;
               subs(dtoc(dend),7,2)   // End  Date

*/

      cData += repl("0",4)  // base qty
      cData += repl("0",8)  // day of week
      cData += repl("0",4)  // discount rate
      cData += repl("0",10) // discount amount
      cData += repl("0",4)  // ssd rate
      cData += repl("0",10) // ssd amount
      cData += repl("0",10) // ad tax1
      cData += repl("0",10) // ad tax2
      cData += repl("0",16) // status bytes
      cData += repl("0",30) // reserved
      
return padr(cData,244,"0")

static function DelRecall(nMode)
local cOldPath := set(_SET_PATH)
local aUnits := {}
local nRecNo := UITEMS->(RecNo())
local n

    UITEMS->(DbCloseArea())
    aUnits :=  GetUnits()
    for n := 1 to len(aUnits)
       Message(ITEM->I_001+" "+ITEM->I_002+if(nMode==1," Deleted","Recalled")+" on "+aUnits[n][2])
       set(_SET_PATH,aUnits[n][3])
       if NetUse("UITEMS",DB_SHARED,NUM_SECONDS)
          Set Index to UITEMS
       endif
       if UITEMS->(DbSeek(ITEM->I_001))
          UITEMS->(RecLock(0))
          if nMode == 1 // for Deletion
            UITEMS->(DbDelete())
            UITEMS->UI_OP_FLAG := 3
          else  
            UITEMS->(DbRecall())
            UITEMS->UI_OP_FLAG := 4
          endif  
        else
          Alert("Item :"+ITEM->I_001+" "+ITEM->I_002+" not found on "+aUnits[n][2]) 
        endif         
       UITEMS->(DbUnLock()) 
       UITEMS->(DbCloseArea())   
    next            
    set(_SET_PATH,cOldPAth)
    if NetUse("UITEMS",DB_SHARED,NUM_SECONDS)
       Set Index to UITEMS
    endif
    UITEMS->(DbGoto(nRecNo))   
return nil

// to get last record of a class
static function GetLast(cClass)
local cVal := space(10), nCtr, prevnCtr := 0, ctr := 0    // counter
local cSeekCode := xGetvar[20] + alltrim(cClass) +  "0000001"

  if ITEM->(dbSeek(cSeekCode))
    while substr(ITEM->I_001,4,4) == cClass
      nCtr := val(substr(ITEM->I_001,8))
      ctr := nCtr -1 
      if prevnCtr != Ctr
         nCtr := prevnCtr 
         exit
      endif   
      prevnCtr := nCtr
      
      ITEM->(dbSkip())
    enddo
    cVal := xGetVar[20]+cClass+padl(nCtr+1,7,"0")
  else
    cVal := cSeekCode
  endif
return cVal


static function VLDTBRNDCODE(cBrndcode)
local lretval:=.f.

 if !empty(cBrndcode)
  xGetVar[40]:=padl(alltrim(cBrndcode),4,"0")
  lretval:=.t.
 endif
return lretval  


function ITEMNext()
local nREcNo := ITEM->(Recno())
local nLast 
  ITEM->(DbGoBottom())  
  nLast := ITEM->(LastRec()) + 1
  ITEM->(DbGoto(nRecNo))
return nLast

function CompuPrice(nMode)
local nPrice

 if nMode != VIEW_MODE
   nPrice := ( xGetVar[07] * (xGetVar[43]/100) ) + xGetVar[07]
   xGetVar[3] := compucost(nPrice)
 endif
 
return .T.

//end-of-file
