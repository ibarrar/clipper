#include "Inkey.ch"
#include "setcurs.ch"
#include "fileio.ch"
#include "aChoice.ch"
#include "Box.ch"
#include "Janus.ch"

#define BAR "F2-Add  F3-Edit  F4-Del/Undel  F5-Search  F6-DownLoad  ESC-Abort"

#define UPDATE_FILE
#define CFILE       "CASHIER.TXT"
#define REC_LENGTH   45

#define ROOT_PATH  chr(65+curdrv())+":\"+curdir()+"\"   

memvar GETLIST, level
static _Cash_Code, _Name, _Time_In, _Time_Out, _Pos_no, _Reserved, _Flag
static aScrollBar,aPicture

function DO_Cashier()
local wMast, nKey,cpath:=space(35)
local level := 1



  if NetUse("CASHIER",DB_SHARED,NUM_SECONDS)
     set index to CASHIER
  endif

  setcolor("N/W,GR+/N")   
  wMast := OpenWindow(06,06,14,73,"Cashier File")
  @ 07,06 to 14,73 double
  
  if CASHIER->(reccount()) == 0; Screen(APPEND_MODE); endif
  if lastkey() != K_ESC
     do while (nkey!=K_ESC)
        Screen(VIEW_MODE)
        nkey:=inkey(0)
        do case
           case nkey==K_DOWN
             CASHIER->(Dbskip())
             if CASHIER->(eof())
                CASHIER->(DbGobottom())
                tone(100,3)
                Message("End of file reached....")
                inkey(1)
             endif
           case nkey==K_UP
             CASHIER->(Dbskip(-1))
             if CASHIER->(bof())
                CASHIER->(Dbgotop())
                tone(100,3)
                Message("Beginning of file reached....")
                inkey(1)
             endif
           case nkey==K_CTRL_PGDN
             CASHIER->(Dbskip(NUM_TO_SKIP))
             if CASHIER->(eof())
                CASHIER->(Dbgobottom())
                tone(100,3)
                Message("End of file reached....")
                inkey(1)
             endif
           case nkey==K_CTRL_PGUP
             CASHIER->(Dbskip(-NUM_TO_SKIP))
             if CASHIER->(bof())
                CASHIER->(Dbgotop())
                tone(100,3)
                Message("Beginning of file reached....")
                inkey(1)
             endif
           case nkey==K_END
             Message("Moving to end of file....")
             CASHIER->(Dbgobottom())
             inkey(1)
           case nkey==K_HOME
             Message("Moving to beginning of file...")
             CASHIER->(Dbgotop())
             inkey(1)
           case nkey==K_F2
             if level < 3 .and. CASHIER->(!Deleted())
               Message("Press ENTER to add new record.")
               if inkey(0)==K_ENTER
                  Screen(APPEND_MODE)
               endif
             else
               Message("Access Denied.")
               tone(300,3)
             endif    

           case nkey==K_F3
             if level < 3 .and. CASHIER->(!Deleted())
              Screen(EDIT_MODE)
             else
              Message("Access Denied.")
              tone(300,3) 
             endif
           case nkey==K_F4
             if level < 3
               if CASHIER->(Deleted())
                  Message("Press ENTER to undelete record, ESC to Abort.")
                  if inkey(0)==K_ENTER
                     Message("Undeleting current record....")
                     CASHIER->(RecLock(0))
                     CASHIER->(DbRecall())
                     CASHIER->(DbUnlock())
                  endif
               else
                  Message("Press ENTER to delete record, ESC to Abort.")
                  if inkey(0)==K_ENTER
                     Message("Deleting current record....")
                     CASHIER->(RecLock(0))
                     CASHIER->(Dbdelete())
                     CASHIER->(DbUnlock())
                  endif
               endif
            else
             Message("Access Denied.")
             tone(300,3)
            endif    
           case nkey==K_F5
             CASHIER->(M_Search())
           case nkey==K_F6
                MkTxtCashr()               
        endcase
     enddo
  endif
  Message("Closing Databases....")
  CASHIER->(DbCloseArea())
  CloseWindow(wMast)
return nil

static function Screen(nMode)
local crs, clr
  tone(300,1)
  M_Init(nMode)
  Message(BAR)
  clr := setcolor("W+/RB")
  if CASHIER->(Deleted()); @ 06,35 say "<deleted>"
  else ; @06,35 say "         " ; endif
//  setcolor("W+/RB")
  if nMode==APPEND_MODE
     @ 06,62 say "< New >  "
  else
     @ 06,62 say "Rec #"+transform(CASHIER->(recno()),"9999")
  endif
  setcolor( clr )
  @      08,14 say "       Cashier Code" get _Cash_Code pict "@!K 999999" valid(CheckCode(nMode,_Cash_Code))
  @ row()+1,14 say "       Cashier Name" get _Name pict "@!K "+repl("X",20) valid(!empty(_Name))
  @ row()+1,14 say "            Time In" get _Time_In valid(!empty(_Time_In))
  @ row()+1,14 say "           Time Out" get _Time_Out valid(!empty(_Time_Out))
  @ row()+1,14 say "             POS No" get _Pos_No pict "@!K XXXX"
  @ row()+1,14 say "           Reserved" get _Reserved pict "@K X"
*  @ row()+1,14 say "        Status Flag" get _Flag pict "@!K 9"

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
    _Cash_Code := space(6)
    _Name      := space(20) 
    _Time_In   := space(6)
    _Time_Out  := space(6)
    _Pos_No    := space(4)
    _Reserved  := space(1)
*    _Flag      := space(1)
 else
    _Cash_Code := CASHIER->cash_code
    _Name      := CASHIER->name
    _Time_In   := CASHIER->time_in
    _Time_Out  := CASHIER->time_out
    _Pos_No    := CASHIER->pos_no
    _Reserved  := CASHIER->reserved
*    _Flag      := CASHIER->Flag
  endif
return nil

static function M_Save(nMode)
 Message("Saving Entries....")
 if nMode==APPEND_MODE
    CASHIER->(FilLock(0))
    CASHIER->(Dbappend())
    CASHIER->(DbUnlock())
 endif
 CASHIER->(RecLock(0))
    CASHIER->cash_code   := _Cash_Code
    CASHIER->name        := _Name 
    CASHIER->time_in     := _Time_In
    CASHIER->time_out    := _Time_Out
    CASHIER->pos_no      := _Pos_No
    CASHIER->reserved    := _Reserved
*    CASHIER->flag        := _Flag
 CASHIER->(DbUnlock())
 CASHIER->(DbCommit())
return nil


static function M_Search()
local wSearch, nRecno :=CASHIER->(Recno())
static cKey := "      "
  cKey:=padr(cKey,6)
  wSearch := OpenWindow(09,23,13,57,"Search Tenant Code")
  @ 11, 25 say "Enter Cashier Code to search"
  @ 12, 25 get cKey picture "@! 999999"
  setcursor(SC_NORMAL)
  read
  setcursor(SC_NONE)
  closeWindow(wSearch)
  if lastkey() != K_ESC
     cKey := alltrim(cKey)
     if CASHIER->(DbSeek(cKey))
        do while (cKey $ CASHIER->cash_code) .and. CASHIER->(!eof())
          CASHIER->(Screen(VIEW_MODE))
          Message("Press any key to search for more, ESC to Abort...")
          inkey(0)
          if lastkey()==K_ESC
             exit
          else
             CASHIER->(DbSkip())
          endif
        enddo
     else
      Message("Code Not Found...")
      tone(100,4)
      CASHIER->(Dbgoto(nRecno))
     endif
  endif
return nil

static function CheckCode(nMode,nCode)
local nRecno := CASHIER->(RecNo()), lOkCode := .T.,crs
  if nMode == APPEND_MODE
   if (len(alltrim(nCode))==6)
      CASHIER->(DbGotop())
      CASHIER->(DbSeek(nCode))
      do while ((CASHIER->cash_code == nCode) .and. (CASHIER->(!Eof())) .and. (lOkCode))
         *if !(CASHIER->(Deleted()))
          crs := setcursor( SC_NONE )
          Message(" Cashier's Code Already in use....")
          tone(500,4)
          setcursor(crs)
          lOkCode := .f.
         *endif
      enddo
  else
   lOkcode := .f.
  endif
 endif
  CASHIER->(DbGoto(nRecNo))
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

function FMNext()
local nREcNo := FM->(Recno())
local nLast 
  FM->(DbGoBottom())  
  nLast := FM->TRANSNO + 1
  FM->(DbGoto(nRecNo))
return nLast



static function  MkTxtCashr()

local aItem := {}, nFHandle, wChange
local nCount := 0, nFH, nMoveTo , nFHandle1
local i, j, r,cStr := "", cPath, nbytes := 0
local wLinks, hGauge, nRecCount := 0, nPercent, nCtr := 1
local nDebugCtr := 0, nFSize, lNoWrite1 := .T.
local nRecno := CASHIER->(Recno())
cpath := space(35)

//get path
if file((ROOT_PATH)+"cashier.id")
  nFh:=fopen((ROOT_PATH)+"cashier.id")
  cpath := freadstr(nFh,35)
  fclose(nFh)
endif     
cpath := padr(alltrim(cpath),35) 

wChange := OpenWindow(5,15,9,72,"Data Path Editing")
setcursor(SC_NORMAL)
@  6,15 to 9,72 double
@  7,17 say "ENTER DATA PATH : " get cPath pict "@! " +REPL("X",35)
read
if lastkey() == K_ESC
   CloseWindow(wChange)  
   setcursor(SC_NONE) 
   CASHIER->(DbGoto(nREcNo)) 
   return nil
endif   
CloseWindow(wChange)  
setcursor(SC_NONE) 
cPath := ALLTRIM(cPath)
if substr(cpath,len(cPath),1) != "\"
  cPath += "\"
endif  

// save new path to file
 if lastkey() != K_ESC
   if file("cashier.id")
     ferase("cashier.id")
   endif  
   nFh := fcreate("cashier.id",FC_NORMAL)
   fwrite(nFh,cpath)
   fclose(nFh)          
 else
   BUMMER()
   return nil
 endif


if (nCount := GetLast((cpath) + CFILE)) != -1 
   aSize(aItem, 6)
   
   // open cashier.txt
   
   if file((cpath)+CFILE)
     RENAME (cPath)+CFILE to (cPath)+"CASHTXT.OLD"
     nFH   := fcreate((cpath)+CFILE,FC_NORMAL)
   else
    nFH     := fcreate((cpath)+CFILE,FC_NORMAL)
   endif 
     

   Message("Creating CASHIER.TXT ....please wait!")
  
  //
  // CREATE FROM CASHIER FILE UPDATES
  // 

    CASHIER->(DbGoTop())
    while CASHIER->(!eof()) 
     if cashier->(!Deleted())

      aItem[1]  := padl(alltrim(CASHIER->CASH_CODE),6,"0")       // cash code
      if CASHIER->NAME != SPACE(20)
         aItem[2]  := CASHIER->NAME                            // cashier desc
      else
          aItem[2]  := repl(" ",20)                            // cashier desc     
      endif       
      if CASHIER->TIME_IN != SPACE(6)
         aItem[3]  := CASHIER->TIME_IN      // time in
      else
         aItem[3]  := SPACE(6)      // time in
      endif
      if CASHIER->TIME_OUT != SPACE(6)      
         aItem[4]  := CASHIER->TIME_OUT       // time out
      else 
         aItem[4]  := SPACE(6)      // time out  
      endif
      if CASHIER->POS_NO != SPACE(4)         
         aItem[5]  := CASHIER->POS_NO       // pos no
      else
         aItem[5]  := SPACE(4)       // pos no
      endif   
      aItem[6]  := padl(alltrim(CASHIER->RESERVED),1,"0")       // reserved
       

        for j:= 1 to len(aItem)
           cStr += aItem[j]
        next j
          

        // write to output file (cashier.txt)       
        cStr := padr(cStr, 43)
        
         nbytes := fwriteln(nFh,cStr) 
         /* if nbytes != len(cStr)
            exit
         endif */  

        nDebugCtr += 1
        cStr := ""

     endif // flag
     CASHIER->(dbskip())
    enddo
   CASHIER->(DbCommit()) 
   nFSize := filesize(nFH)
   fclose(nFH)
 endif


 HEYTHERE() ; OKDONE()
 inkey(1)
 CASHIER->(DbGoto(nREcNo)) 

return nil


static function GetLast(cFname)
 local nFH, nFMCnt := 0, nMoveBy
 local nCounter

 if file(cFname)
   nFH := fopen(cFname, FO_READWRITE)  
 else
   nFH := fcreate(cFname, FC_NORMAL)
   fclose(nFH)
   return 0
 endif  
 
 // check if no error opening
 if nFH == -1
  Alert("Error opening file : '"+cFname+"'", {"Return"})
  return nFH 
 endif
 
 nMoveBy  := filesize(nFH) - REC_LENGTH 
 nFMCnt   := fseek(nFH,nMoveBy,FS_SET) 
 nCounter := val(freadstr(nFH,8))
 

 fclose(nFH)
 
 #ifndef UPDATE_FILE
  ferase(cFname)
 #endif 

return nCounter


/*-*-*-*-*-*-*-<End of File>-*-*-*-*-*-*-*/