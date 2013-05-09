#include "box.ch"
#include "its.ch"
#include "inkey.ch"
#include "Janus.ch"
#include "aChoice.ch"
#include "setcurs.ch"

#ifdef COLOR_STAT
#define BAR "F3-Entry  F5-Search   ESC-Abort"
#else
#define BAR "F3-Entry  F5-Search   ESC-Abort"
#endif

memvar getlist,nUnit

static xGetVar[2]

function do_Pcount()
local wWindow, nkey,n
local aUnits := {}

   aUnits := GetUnits()
   if ((n := aScan(aUnits,{|x| x[1] == padl(alltrim(str(nUnit)),3,"0") })) != 0)
      Set(_SET_PATH,aUnits[n][3])
   else
      alert("Error : Cannot Use ITEMS on unit "+alltrim(str(nUnit))+"...")  
   endif     
   if NetUse("UITEMS",DB_SHARED,NUM_SECONDS)
      Set Index to UITEMS
   endif   
   if NetUse("ITEM.DBF",DB_SHARED,NUM_SECONDS)
      set index to I_001
   endif
   wWindow := OpenWindow(04,06,08,73,"Physical Count Entry file")   
   if ITEM->(reccount()) > 0 
      if lastKey()!=K_ESC
         do while (nkey!=K_ESC)
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
               case nKey==K_F3
                   Screen_Form(EDIT_MODE)
               case nKey==K_F5
                  ITEM->(Search_Form("Item",14))
            endcase
         enddo
      endif
   else
     Alert("No Existing PLU record...")     
   endif
   Message("Closing Databases....")
   ITEM->(DbCloseArea())
   UITEMS->(DbCloseArea())
   CloseWindow(wWindow)
return nil

static function Screen_Form(nMode)
local clr, crs
   tone(300,1)
   Screen_Init(nMode)
   MsgBar(BAR)
   clr := setcolor(TITLE_ATTR)

      if ITEM->(Deleted()) 
        @ 04,35 say "<deleted>"
      else  
        @ 04,35 say "         "
      endif
      @ 04, 62 say "Rec #"+transform(ITEM->(recno()),"9999")
      
   setcolor( clr ) 
   
   @ 06,      17 say "     Item Code " get xGetVar[1] PICT "@K "+repl("9",PLU_CODE_LEN)  WHEN .f. 
   @ row()+1, 17 say	"Physical Count " get xGetVar[2] PICT "@K 999,999.999"   VALID !Empty(xGEtvar[2])       
                                                                                                       
   if (nMode==EDIT_MODE)
      crs := setcursor(SC_NORMAL)
      read
      if lastkey()!=K_ESC
         Screen_Save(nMode)
      endif
      setcursor( crs )
   else
      clear gets
   endif
return nil

static function Screen_Init(nMode)
 	xGetVar[ 1] := ITEM->I_001
*	xGetVar[ 2] := ITEM->I_013
   if UITEMS->(DbSeek(ITEM->I_001))
   	xGetVar[ 2] := UITEMS->UI_P_COUNT
   endif   
return nil

static function Screen_Save(nMode)
   Message("Saving entries...")
/* ITEM->(RecLock(0))
   ITEM->I_001 := xGetVar[1]
   ITEM->I_013 := xGetVar[2]
   ITEM->(DbUnlock())
   ITEM->(DbCommit()) */
   UITEMS->(RecLock(0))
   UITEMS->UI_P_COUNT := xGetVar[2]
   UITEMS->(DbCommit())
   UITEMS->(DbUnLock())
return nil

//end-of-file
