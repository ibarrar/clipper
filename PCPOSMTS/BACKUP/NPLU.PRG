#include "box.ch"
#include "its.ch"
#include "inkey.ch"
#include "Janus.ch"
#include "aChoice.ch"
#include "setcurs.ch"

#ifdef COLOR_STAT
#define BAR "F3-Edit   F5-Search   ESC-Abort"
#else
#define BAR "F3-Edit   F5-Search   ESC-Abort"
#endif

memvar getlist

static xGetVar[6]
STATIC cPrompts := { ;
   "          Date",;
   "      PLU Code",;
   "     Item Code",;
   "   Description",;
   "      Qty Sold",;
   "   Amount Sold"}

function do_nplu()
local wVendor, nkey
   if netUse("NPLU",DB_SHARED,NUM_SECONDS)
      set index to NPLU
   endif
   if netUse("PLU",DB_SHARED,NUM_SECONDS)
      set index to PLU, DATEPLU, ITEMCNT
   endif
  
   wVendor := OpenWindow(04,15,13,60,"Not Found PLU File")
   if NPLU->(reccount())==0 ; Vendor_Form(APPEND_MODE) ; endif
   if lastKey()!=K_ESC
      do while (nkey!=K_ESC)
         Vendor_Form(VIEW_MODE)
         nkey:=inkey(0)
         do case
            case nkey==K_DOWN
               NPLU->(Dbskip())
               if NPLU->(eof())
                  NPLU->(Dbgobottom())
                  tone(100,3)
                  Message("End of file reached....")
                  inkey(1)
               endif
            case nKey==K_UP
               NPLU->(Dbskip(-1))
               if NPLU->(bof())
                  NPLU->(Dbgotop())
                  tone(100,3)
                  Message("Beginning of file reached....")
                  inkey(1)
               endif
            case nKey==K_CTRL_PGDN
               NPLU->(Dbskip(NUM_TO_SKIP))
               if NPLU->(eof())
                  NPLU->(Dbgobottom())
                  tone(100,3)
                  Message("End of file reached....")
                  inkey(1)
               endif
            case nKey==K_CTRL_PGUP
               NPLU->(Dbskip(-NUM_TO_SKIP))
               if NPLU->(bof())
                  NPLU->(Dbgotop())
                  tone(100,3)
                  Message("Beginning of file reached....")
                  inkey(1)
               endif
            case nKey==K_END
               NPLU->(Dbgobottom())
                  Message("Moving to end of file....")
                  inkey(1)
            case nKey==K_HOME
               NPLU->(Dbgotop())
                  Message("Moving to beginning of file....")
                  inkey(1)
            case nKey==K_F3
                  Vendor_Form(EDIT_MODE)
            case nKey == K_F5
               NPLU->(Search_Form("PLU Code",14))
            case nKey==K_F6
         endcase
      enddo
   endif
   Message("Closing Databases....")
   NPLU->(DbCommit())
   NPLU->(DbCloseArea())
   PLU->(DbCommit())
   PLU->(DbCloseArea())
   if netUse("NPLU",DB_EXCLUSIVE,NUM_SECONDS)
      set index to NPLU
      NPLU->(__DbPack())	
      NPLU->(DbCommit())
      NPLU->(DbCloseArea())
   endif
   CloseWindow(wVendor)
return nil

static function Vendor_Form(nMode)
local clr, crs, nrecord := 0
   tone(300,1)
   Vendor_Init(nMode)
   MsgBar(BAR)
   clr := setcolor(TITLE_ATTR)
   @ 04, 49 say "Rec #"+transform(NPLU->(recno()),"9999")
   setcolor( clr )
   @ 06,      17 say  cPrompts[1]  get xGetVar[1] when .f.
   @ row()+1, 17 say  cPrompts[2]  get xGetVar[2] when .f.
   @ row()+1, 17 say  cPrompts[3]  get xGetVar[3] PICT "@! "+repl("X",12) VALID !empty(xGetVar[3])
   @ row()+1, 17 say  cPrompts[4]  get xGetVar[4] PICT "@! "+repl("X",20) VALID !empty(xGetVar[4])
   @ row()+1, 17 say  cPrompts[5]  get xGetVar[5] when .f.
   @ row()+1, 17 say  cPrompts[6]  get xGetVar[6] when .f.
   
   
   if (nMode==EDIT_MODE)
      crs := setcursor(SC_NORMAL)
      read
      if lastkey()!=K_ESC
         nRecord := NPLU->(Recno())
         Vendor_Save(nMode,nRecord)
      endif
      setcursor( crs )
   else
      clear gets
   endif
return nil


static function Vendor_Init(nMode)
      xGetVar[1]  := NPLU->DATE
      xGetVar[2]  := NPLU->CODE
      xGetVar[3]  := SPACE(12)
      xGetVar[4]  := SPACE(20)
      xGetVar[5]  := NPLU->ICOUNT
      xGetVar[6]  := NPLU->IAMOUNT
return nil

static function Vendor_Save(nMode,nRecord)
   Message("Saving entries...")
   PLU->(RecLock(0))
   PLU->(DbAppend())
   PLU->DATE := xGetVar[ 1]
   PLU->CODE := xGetVar[ 2]
   PLU->ITEM_CODE := XGetVar[ 3]
   PLU->DESC := XGetVar[ 4]
   PLU->ICOUNT := XGetVar[ 5]
   PLU->IAMOUNT := XGetVar[ 6]
   PLU->(DbUnlock())
   
   NPLU->(DbGoto(nRecord))
   NPLU->(Reclock(0))
   NPLU->(DbDelete()) 
   NPLU->(DbUnlock())
   
return nil


//end-of-file
