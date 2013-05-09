/*
        Filename: MASTER.PRG
     System-Name: Master File Handler
          Author: Rolando C. Ibarra Jr.
    Date-Started: August 3, 1994
     Last-Update: August 3, 1994
*/
#include "Inkey.ch"
#include "setcurs.ch"
#include "aChoice.ch"
#include "fileio.ch"
#include "Box.ch"
#include "Janus.ch"

#define BAR "F2-Add  F3-Edit  F4-Del/Undel  F5-Search  F6-Download  ESC-Abort"

memvar GETLIST, level
static _clrk_Code, _Name, _slstot:=0, _slsknt:=0, _itmknt:=0, _Reserved
static aScrollBar,aPicture

function ClkMaint()
local wMast, nKey
local level := 1

  if NetUse("CLRK",DB_SHARED,NUM_SECONDS)
     set index to CLRK
  endif

  setcolor("N/W,GR+/N")   
  wMast := OpenWindow(04,06,13,73,"Clerk File")
  @ 05,06 to 13,73 double
  if CLRK->(reccount()) == 0; Screen(APPEND_MODE); endif
  if lastkey() != K_ESC
     do while (nkey!=K_ESC)
        Screen(VIEW_MODE)
        nkey:=inkey(0)
        do case
           case nkey==K_DOWN
             CLRK->(Dbskip())
             if CLRK->(eof())
                CLRK->(DbGobottom())
                tone(100,3)
                Message("End of file reached....")
                inkey(1)
             endif
           case nkey==K_UP
             CLRK->(Dbskip(-1))
             if CLRK->(bof())
                CLRK->(Dbgotop())
                tone(100,3)
                Message("Beginning of file reached....")
                inkey(1)
             endif
           case nkey==K_CTRL_PGDN
             CLRK->(Dbskip(NUM_TO_SKIP))
             if CLRK->(eof())
                CLRK->(Dbgobottom())
                tone(100,3)
                Message("End of file reached....")
                inkey(1)
             endif
           case nkey==K_CTRL_PGUP
             CLRK->(Dbskip(-NUM_TO_SKIP))
             if CLRK->(bof())
                CLRK->(Dbgotop())
                tone(100,3)
                Message("Beginning of file reached....")
                inkey(1)
             endif
           case nkey==K_END
             Message("Moving to end of file....")
             CLRK->(Dbgobottom())
             inkey(1)
           case nkey==K_HOME
             Message("Moving to beginning of file...")
             CLRK->(Dbgotop())
             inkey(1)
           case nkey==K_F2
             if level < 3 .and. CLRK->(!Deleted())
               Message("Press ENTER to add new record.")
               if inkey(0)==K_ENTER
                  Screen(APPEND_MODE)
               endif
             else
               Message("Access Denied.")
               tone(300,3)
             endif    

           case nkey==K_F3
             if level < 3 .and. CLRK->(!Deleted())
              Screen(EDIT_MODE)
             else
              Message("Access Denied.")
              tone(300,3) 
             endif
           case nkey==K_F4
             if level < 3
               if CLRK->(Deleted())
                  Message("Press ENTER to undelete record, ESC to Abort.")
                  if inkey(0)==K_ENTER
                     Message("Undeleting current record....")
                     CLRK->(RecLock(0))
                     CLRK->(DbRecall())
                     CLRK->(DbUnlock())
                  endif
               else
                  Message("Press ENTER to delete record, ESC to Abort.")
                  if inkey(0)==K_ENTER
                     Message("Deleting current record....")
                     CLRK->(RecLock(0))
                     CLRK->(Dbdelete())
                     CLRK->(DbUnlock())
                  endif
               endif
            else
             Message("Access Denied.")
             tone(300,3)
            endif    
           case nkey==K_F5
             CLRK->(M_Search())
/*           case nkey==K_F6
             MkBtrClrk()             
*/        endcase
     enddo
  endif
  Message("Closing Databases....")
  CLRK->(DbCloseArea())
  CloseWindow(wMast)
return nil

static function Screen(nMode)
local crs, clr
  tone(300,1)
  M_Init(nMode)
  Message(BAR)
  clr := setcolor("W+/RB")
  if CLRK->(Deleted()); @ 04,35 say "<deleted>"
  else ; @04,35 say "         " ; endif
//  setcolor("W+/RB")
  if nMode==APPEND_MODE
     @ 04,62 say "< New >  "
  else
     @ 04,62 say "Rec #"+transform(CLRK->(recno()),"9999")
  endif
  setcolor( clr )
  @      06,14 say "         Clerk Code" get _clrk_Code pict "@!K XXXXXX " valid(CheckCode(nMode,_CLRK_Code))
  @ row()+1,14 say "         Clerk Name" get _Name pict "@!K XXXXXXXXXXXXXXXXXXXX"
  @ row()+1,14 say "        Sales Total" get _slstot pict "9,999,999.99"
  @ row()+1,14 say "        Sales Count" get _slsknt pict "9999"
  @ row()+1,14 say "         Item Count" get _itmknt pict "9999"  
  @ row()+1,14 say "           Reserved" get _Reserved pict "@K XXXXXXXXXXXXXXXXXXXX"

  if (nMode==APPEND_MODE) .or. (nMode==EDIT_MODE)
     crs := setcursor(SC_NORMAL)
     read
     if lastkey() != K_ESC
        M_Save(nMode)
     endif
     setcursor( crs )
  else
   clear gets
  endif

return nil


static function M_Init(nMode)
 if nMode==APPEND_MODE
    _CLRK_Code := space(6)
    _Name      := space(20)
    _slstot    := 0
    _slsknt    := 0
    _itmknt    := 0
    _Reserved  := space(20)
 else
    _CLRK_Code := CLRK->CLERK_CODE
    _Name      := CLRK->CLERK_NAME
    _slstot    := CLRK->SLSTOT
    _slsknt    := CLRK->SLSKNT
    _itmknt    := CLRK->ITMKNT
    _Reserved  := CLRK->RESERVED
 endif
return nil

static function M_Save(nMode)
 Message("Saving Entries....")
 if nMode==APPEND_MODE
    CLRK->(FilLock(0))
    CLRK->(Dbappend())
    CLRK->(DbUnlock())
 endif
 CLRK->(RecLock(0))
   CLRK->CLERK_CODE := _CLRK_Code
   CLRK->CLERK_NAME := _Name
   CLRK->SLSTOT     := _slstot
   CLRK->SLSKNT     := _slsknt
   CLRK->ITMKNT     := _itmknt
   CLRK->RESERVED   := _Reserved
 CLRK->(DbUnlock())
 CLRK->(DbCommit())
return nil


static function M_Search()
local wSearch, nRecno :=CLRK->(Recno())
static cKey := "    "
  cKey:=padr(cKey,6)
  wSearch := OpenWindow(09,23,13,57,"Search Tenant Code")
  @ 11, 25 say "Enter CLRK Code to search"
  @ 12, 25 get cKey picture "@! 999999"
  setcursor(SC_NORMAL)
  read
  setcursor(SC_NONE)
  closeWindow(wSearch)
  if lastkey() != K_ESC
     cKey := alltrim(cKey)
     if CLRK->(DbSeek(cKey))
        do while (cKey $ CLRK->CLERK_code) .and. CLRK->(!eof())
          CLRK->(Screen(VIEW_MODE))
          Message("Press any key to search for more, ESC to Abort...")
          inkey(0)
          if lastkey()==K_ESC
             exit
          else
             CLRK->(DbSkip())
          endif
        enddo
     else
      Message("Code Not Found...")
      tone(100,4)
      CLRK->(Dbgoto(nRecno))
     endif
  endif
return nil

static function CheckCode(nMode,nCode)
local nRecno := CLRK->(RecNo()), lOkCode := .T.,crs
  if nMode == APPEND_MODE
   if (len(alltrim(nCode))==6)
      CLRK->(DbGotop())
      CLRK->(DbSeek(nCode))
      do while ((CLRK->CLERK_code == nCode) .and. (CLRK->(!Eof())) .and. (lOkCode))
         //if !(CLRK->(Deleted()))
          crs := setcursor( SC_NONE )
          Message(" CLERK's Code Already in use....")
          tone(500,4)
          setcursor(crs)
          lOkCode := .f.
         //endif
      enddo
  else
   lOkcode := .f.
  endif
 endif
  CLRK->(DbGoto(nRecNo))
return lOkCode

static function HandleMenu(nMode,nCurElem,nRelPos)
local nRetVal,nKey
   do case
      case nMode==AC_EXCEPT
           nKey:=Lastkey()
           do case
              case nKey==K_ESC
                   nRetVal:=AC_ABORT
              case nKey==K_ENTER
                   nRetVal:=AC_SELECT
              otherwise
                   nRetVal:=AC_CONT
           endcase
       otherwise
          nRetVal:=AC_CONT
   endcase
return nRetVal

#ifdef NOTHING

static function MkBtrClrk()
local command  // create
local send_dat := space(64)
local path_dat, nFh, wchange 
local retval := 0, nRecno:= CLRK->(Recno())


path_dat := space(35)
wChange := OpenWindow(5,15,9,72,"Data Path Editing")
setcursor(SC_NORMAL)
@  6,15 to 9,72 double
@  7,17 say "ENTER DATA PATH : " get path_dat pict "@! " +REPL("X",35)
read
if lastkey() == K_ESC
   CloseWindow(wChange)  
   setcursor(SC_NONE) 
   CLRK->(DbGoto(nREcNo)) 
   return nil
endif   
CloseWindow(wChange)  
setcursor(SC_NONE) 
path_dat := ALLTRIM(path_dat)
if substr(path_dat,len(path_dat),1) != "\"
  path_dat += "\"
endif  


  // check first if the file exist...
  if !File(path_dat +"CLERK.BTR") .or. !File(path_dat + "CLERK.IDX")
     // create the file
     command := "01" // to create the file...
     send_dat := space(64)
      ? " about to call to file_access ... "
      ? " command : "  + command
      ? " send buff: " + send_dat
      ? " path buff: " + path_dat 

     retval := f_access(command,send_dat,path_dat)
     ? "return value" + str(retval)
     if retval != 0
        ALERT("Error Creating File...", {"Return"})
        // return nil
     endif   
     
  endif


  // now add all the data in the array
  Message("Creating Clerk Files... Pls. Wait") 
  CLRK->(DbGoTop())
  Do While CLRK->(!Eof())
   if CLRK->(!DELETED())  
    command := "02"  // to add or edit
   else 
    command := "03"  // delete
   endif 
   send_dat := CLRK->CLERK_CODE+CLRK->CLERK_NAME+STR(CLRK->SLSTOT)+STR(CLRK->SLSKNT)+;
               STR(CLRK->ITMKNT)+CLRK->RESERVED

   // ? " about to call to file_access ... "
   // ? " command : "  + command
   // ? " send buff: " + send_dat
   // ? " path buff: " + path_dat 
   
   retval := f_access(command,send_dat,path_dat)
  // ? " Available memory for use :"
  // ?? BLIMEMAVL()  
   if retval != 0
      Message("error in record additions...")     
   endif       
   //? "retval : "
   //?? retval    
   //?
   //?
   
   CLRK->(DbSkip())
  enddo
  CLRK->(DbGoto(nrecno))
     
return nil

#endif
/*-*-*-*-*-*-*-<End of File>-*-*-*-*-*-*-*/