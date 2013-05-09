**** UNIT MAINTENANCE ****

#include "its.ch"
#include "janus.ch"
#include "setcurs.ch"
#include "inkey.ch"
#include "set.ch"

#ifdef COLOR_STAT
#define BAR "F2-Add   F3-Edit   F4-[Del/Undel]   F5-Search   ESC-Abort"
#else
#define BAR "F2-Add   F3-Edit   F4-[Del/Undel]   F5-Search   ESC-Abort"
#endif
#define DATA_PATH    ".\MTSDATA\"

memvar getlist,nUnit

static xGetVar[13]
static aPicture

function do_units()
local wWindow, nKey
  aPicture := array(5,3)
  aPicture[1,1] := FieldBlock("UNIT_LINK")
  aPicture[1,2] := "@K 999"
  aPicture[1,3] := .F.
  aPicture[2,1] := FieldBlock("MACHINENO")
  aPicture[2,2] := "@K 99"
  aPicture[2,3] := .t.
  aPicture[3,1] := FieldBlock("REMARKS")
  aPicture[3,2] := "@!KS20"
  aPicture[3,3] := .t.
  aPicture[4,1] := FieldBlock("TARGETSLS")
  aPicture[4,2] := "@K 99,999,999.99"
  aPicture[4,3] := .t.
  aPicture[5,1] := FieldBlock("UMAC_PATH")
  aPicture[5,2] := "@!KS20"
  aPicture[5,3] := .t.
  Message("Opening DataBase...")
  if NetUse("UNIT",DB_SHARED,NUM_SECONDS)
     Set Index to UNIT
  endif
  if NetUse("UM", DB_SHARED,NUM_SECONDS)
     Set Index to UM
  endif   
  wWindow := OpenWindow(04,06,15,73,"Unit Maintenance File")
  if UNIT->(LastRec())==0; Unit_Form(APPEND_MODE); endif
  if LastKey() != K_ESC
     do while (nKey != K_ESC)
        Unit_Form(VIEW_MODE)
        nkey := inkey(0)
        do case
           case nkey == K_DOWN
            UNIT->(DbSkip())
            if UNIT->(eof())
                UNIT->(Dbgobottom())
                tone(100,3)
                Message("End of file reached....")
                inkey(1)
            endif
           case nKey==K_UP
               UNIT->(Dbskip(-1))
               if UNIT->(bof())
                  UNIT->(Dbgotop())
                  tone(100,3)
                  Message("Beginning of file reached....")
                  inkey(1)
               endif
            case nKey==K_CTRL_PGDN
               UNIT->(Dbskip(NUM_TO_SKIP))
               if UNIT->(eof())
                  UNIT->(Dbgobottom())
                  tone(100,3)
                  Message("End of file reached....")
                  inkey(1)
               endif
            case nKey==K_CTRL_PGUP
               UNIT->(Dbskip(-NUM_TO_SKIP))
               if UNIT->(bof())
                  UNIT->(Dbgotop())
                  tone(100,3)
                  Message("Beginning of file reached....")
                  inkey(1)
               endif
            case nKey==K_END
               UNIT->(Dbgobottom())
                  Message("Moving to end of file....")
                  inkey(1)
            case nKey==K_HOME
               UNIT->(Dbgotop())
                  Message("Moving to beginning of file....")
                  inkey(1)
            case nKey==K_F2
                  Unit_Form(APPEND_MODE)
            case nKey==K_F3
                  Unit_Form(EDIT_MODE)
            case nKey==K_F4
             if UNIT->(Deleted())
               Message("Press ENTER to Undelete record, ESC to abort.")
               if inkey(0)==K_ENTER
                  Message("Undeleting current record....")
                  if UM->(DbSeek(UNIT->UNIT_CODE))
                     UM->(FilLock()) 
                     while UM->(!Eof()) .and. UM->UNIT_LINK == UNIT->UNIT_CODE
                       UM->(DbRecall())
                       UM->(DbSkip())
                     enddo
                     UM->(DbUnLock())                      
                  endif   
                  UNIT->(RecLock(0))
                  UNIT->(DbRecall())
                  UNIT->OP_FLAG := 4
                  UNIT->(Dbunlock())
               endif
             else
                Message("Press ENTER to delete record, ESC to abort.")
               if inkey(0)==K_ENTER
                  Message("Deleting current record....")
                  if UM->(DbSeek(UNIT->UNIT_CODE))
                     UM->(FilLock(0)) 
                     while UM->(!Eof()) .and. UM->UNIT_LINK == UNIT->UNIT_CODE
                       UM->(DbDelete())
                       UM->(DbSkip())
                     enddo
                     UM->(DbUnLock())                      
                  endif                     
                  UNIT->(RecLock(0))
                  UNIT->(Dbdelete())
                  UNIT->OP_FLAG := 3
                  UNIT->(Dbunlock())
               endif
             endif
            case nKey==K_F5
               UNIT->(Search_Form("Unit",3))
            case nKey==K_F6
               if (UNIT->(LastRec()) > 0)
                  UM->(abrowse6(UNIT->UNIT_CODE,aPicture,VIEW_MODE))   
               endif   
         endcase
      enddo
   endif
   Message("Closing Databases....")
   UNIT->(DbCloseArea())
   UM->(DbCloseARea())
   aPicture := {} // Free memory
   CloseWindow(wWindow)
return nil    

static function Unit_Form(nMode)
local clr, crs
    tone(300,1)
    Unit_init(nMode)
    MsgBar(BAR)
    clr := setcolor(TITLE_ATTR)
    if UNIT->(Deleted()) ; @ 04, 35 say "<deleted>"
    else ; @ 04,35 say "         " ; endif
    if nMode == APPEND_MODE
       @ 04, 62 say "< New >   "
    else
       @ 04, 62 say "Rec #"+tran(UNIT->(recno()),"9999")
    endif
    setcolor( clr )
    @ 06,     18 say "Unit Number Code:" get xGetVar[1] PICT "@K 999" VALID VldtUnit(nMode) WHEN .f.
    @ row()+1,18 say "       Unit Name:" get xGetVar[2] PICT "@K! "+repl("X",25) VALID !empty(xGetVar[2])
    @ row()+1,18 say "         Address:" get xGetVar[3] PICT "@K! "+repl("X",25)
    @ row()+1,18 say "    Target Sales:" get xGetVar[4] PICT "@K  99,999,999.99"
    @ row()+1,07 say repl("-",66)

    @ row()+1,08 say "  Daily Dept Sum:" get xGetVar[9 ] PICT "@K 99,999,999.99" WHEN .F.
    @ row()+1,08 say "Monthly Dept Sum:" get xGetVar[10] PICT "@K 99,999,999.99" WHEN .F.
    @ row()+1,08 say " Annual Dept Sum:" get xGetVar[11] PICT "@K 99,999,999.99" WHEN .F.
    @ row()+1,08 say "  Unit Selling %:" get xGetVar[13] PICT "@K 999.999" WHEN .F.

    @ 11     ,40 say "  Daily Sales TTL:" get xGetVar[5] PICT "@K 99,999,999.99" WHEN .F.
    @ row()+1,40 say "  Daily Sales CNT:" get xGetVar[6] PICT "@K 999,999.999" WHEN .F.
    @ row()+1,40 say "Monthly Sales TTL:" get xGetVar[7] PICT "@K 99,999,999.99" WHEN .F.
    @ row()+1,40 say " Annual Sales TTL:" get xGetVar[8] PICT "@K 99,999,999.99" WHEN .F.

    if (nMode==APPEND_MODE) .or. (nMode==EDIT_MODE)
        crs := setcursor(SC_NORMAL)
        read
        if lastkey() != K_ESC
          UNIT_Save(nMode)
          if (UNIT->(LastRec()) > 0)
            UM->(abrowse6(UNIT->UNIT_CODE,aPicture,nMode))
          endif
        endif
        setcursor( crs )
    else
        clear gets
    endif
return nil

static function VldtUnit(Mode)
local lRetVal:= .t.,nRecno := UNIT->(RecNo())
 if empty(xGetVar[1])
    return .f.
 endif
 xGetVar[1] := padl(alltrim(xGetVar[1]),3,"0")
 if (Mode==APPEND_MODE) .or. (Mode==EDIT_MODE .and. xGetVar[1] != UNIT->UNIT_CODE )
   UNIT->(DbSeek(xGetVar[1]))
   if (UNIT->(found()))
    lRetVal := .f.
    Message(" Unit Branch Code : "+xGetVar[1]+" already exist...")
    Tone(300,3)
    Tone(500,3)
    Inkey(3)
    Tone(200,2)
   endif
   UNIT->(DbGoto(nRecNo))
   MsgBar(BAR)
 endif
return lRetVal

static function Unit_Init(nMode)
local nKey,n:=2
   if nMode==APPEND_MODE
      nKey := "001"
      while (UNIT->(DbSeek(nKey)))
        nKey := padl(alltrim(str(n++)),3,"0")
      enddo 
      xGetVar[ 1] := nKey
      xGetVar[ 2] := SPACE(25)
      xGetVar[ 3] := SPACE(25)
      xGetVar[ 4] := 0
      xGetVar[ 5] := 0
      xGetVar[ 6] := 0
      xGetVar[ 7] := 0
      xGetVar[ 8] := 0
      xGetVar[ 9] := 0
      xGetVar[10] := 0
      xGetVar[11] := 0
      xGetVar[12] := space(50)
      xGetVar[13] := 0
   else
      xGetVar[ 1] := UNIT->UNIT_CODE
      xGetVar[ 2] := UNIT->UNIT_NAME
      xGetVar[ 3] := UNIT->UNIT_ADDR
      xGetVar[ 4] := UNIT->UNIT_TSLS
      xGetVar[ 5] := UNIT->UNIT_DSLS
      xGetVar[ 6] := UNIT->UNIT_DCNT
      xGetVar[ 7] := UNIT->UNIT_DSUM
      xGetVar[ 8] := UNIT->UNIT_MSLS
      xGetVar[ 9] := UNIT->UNIT_ASLS
      xGetVar[10] := UNIT->UNIT_MDSUM
      xGetVar[11] := UNIT->UNIT_ADSUM
      xGetVar[12] := UNIT->UNIT_PATH
      xGetVar[13] := UNIT->UNIT_RATE
   endif
return nil

static function UNIT_Save(nMode)
local aDbf := {}
local cTemp, cTemp1, cTempPath

   Message("Saving entries...")
   if nMode==APPEND_MODE
      cTemp1 := "MTSDATA."+xGetVar[1]      
      cTemp := chr(65+curdrv())+":\"+curdir()+"\MTSDATA."+xGetVar[1]+"\"
      UNIT->(FilLock(0))
      UNIT->(Dbappend())
      UNIT->UNIT_PATH := cTemp
      UNIT->OP_FLAG := 1
      UNIT->(DbUnLock())
   ELSE
      UNIT->(RecLock(0))
      UNIT->OP_FLAG := 2
      UNIT->(DbUnLock())   
   endif
   UNIT->(RecLock(0))
   UNIT->UNIT_CODE  := xGetVar[ 1]
   UNIT->UNIT_NAME  := xGetVar[ 2]
   UNIT->UNIT_ADDR  := xGetVar[ 3]
   UNIT->UNIT_TSLS  := xGetVar[ 4]
   UNIT->UNIT_DSLS  := xGetVar[ 5]
   UNIT->UNIT_DCNT  := xGetVar[ 6]
   UNIT->UNIT_DSUM  := xGetVar[ 7]
   UNIT->UNIT_MSLS  := XGetVar[ 8]
   UNIT->UNIT_ASLS  := xGetVar[ 9]
   UNIT->UNIT_MDSUM := xGetVar[10]
   UNIT->UNIT_ADSUM := xGetVar[11]
   UNIT->(DbUnlock())   
   UNIT->(DbCommit())

   if nMode == APPEND_MODE
      message(" Setting up new unit. Please wait ...")
      

#ifdef MAKE_DATA
      if (l_mkdir ( cTemp1 ) == 0)
      
         l_chdir ( cTemp1 ) 

         cTempPath := set(_SET_DEFAULT, cTemp)
      
         aDbf := makedbf2() // Create the array entries.
         createdbf ( aDbf, 0 ) // Create the DBFs.
         createntx ( aDbf, 0 ) // Create the NTXes.

         // Go back to the work directory.
         l_chdir ( ".." )      

         set(_SET_DEFAULT, cTempPath)

         cTempPath := set (_SET_PATH, cTemp )         

         if NetUse("UITEMS",DB_SHARED,NUM_SECONDS)
            Set Index to UITEMS
         endif  

         if NetUse("ITEM.DBF",DB_SHARED,NUM_SECONDS)
            Set Index to I_001
         endif

         ITEM->(DbGotop())    
         UITEMS->(FilLock(0))     
         while ITEM->(!EOF()) 
           UITEMS->(AddRec(0))           
           UITEMS->UI_PLUCODE := ITEM->I_001
           UITEMS->UI_STKCODE := ITEM->I_033
           if ITEM->(Deleted())
              UITEMS->(Delete())
           endif   
           ITEM->(DbSkip())           
         enddo 
         UITEMS->(DbUnlock())

         ITEM->(DbCloseArea()) 
         UITEMS->(DbCloseArea())         

         set (_SET_PATH, cTempPath )         

      endif   
#endif 
      
   endif     
return nil

function GetUnits(nPar)
local aUnits := {}

   if nPar == NIL .or. nPar != 0
     aAdd(aUnits,{"000", "*** UNIT WAREHOUSE ***", chr(65+curdrv())+":\"+curdir()+"\MTSDATA.000\" } )   
   endif     
   
   if nPar == NIL .or. nPar != 1
      if NetUse("UNIT",DB_SHARED,NUM_SECONDS)
         Set Index to UNIT
      endif    

      while UNIT->(!Eof())
        if UNIT->(!Deleted())
          aAdd(aUnits, { UNIT->UNIT_CODE,UNIT->UNIT_NAME,UNIT->UNIT_PATH } )
        endif  
        UNIT->(DbSkip())
      enddo        

      UNIT->(DbCloseArea())
   endif   

return aUnits

function SelectUnit()
local aVectors_:= {},n
local aPaths_ := {}

   aAdd(aVectors_, " 000 "+"*** WAREHOUSE *** " )

#ifdef DATA_PATH
   aAdd(aPaths_, chr(65+curdrv())+":\"+curdir()+"\MTSDATA.000" )
#else
   aAdd(aPaths_, "C:\"+curdir()+"\MTSDATA.000" )
#endif   
     
   if NetUse("UNIT",DB_SHARED,NUM_SECONDS)
      Set Index to UNIT
   endif    

   while UNIT->(!Eof())
     if UNIT->(!Deleted())
       aAdd(aVectors_," "+UNIT->UNIT_CODE+" "+UNIT->UNIT_NAME )
       aAdd(aPaths_, UNIT->UNIT_PATH )
     endif  
     UNIT->(DbSkip())
   enddo        

   UNIT->(DbCloseArea())

 if (( n:= LookUp(6,15, aVectors_,"Unit Selections",padl(alltrim(str(nUnit)),"0"))) != 0) 
    nUnit := val(subs(aVectors_[n],2,3))
    SET(_SET_PATH,aPaths_[n])
 endif    

return nUnit
