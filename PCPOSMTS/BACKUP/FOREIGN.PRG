**** FOREIGN ****

#include "janus.ch"
#include "setcurs.ch"
#include "inkey.ch"
#include "its.ch"

#ifdef COLOR_STAT
#define BAR "F2-Add   F3-Edit   F4-[Del/Undel]   F5-Search   ESC-Abort"
#else
#define BAR "F2-Add   F3-Edit   F4-[Del/Undel]   F5-Search   ESC-Abort"
#endif

memvar getlist

static xGetVar

function do_Foreign()
local wWindow, nKey
   xGetVar := array(12)
#ifdef FM_FOREIGN
   if NetUse("FM",DB_SHARED,NUM_SECONDS)
      set index to FM
   endif  
   if NetUse("FC_HIST",DB_SHARED,NUM_SECONDS)
      set index to FC_HIST
   endif  
#endif
  if NetUse("FOREIGN",DB_SHARED,NUM_SECONDS)
     Set Index to FOREIGN
  endif
  wWindow := OpenWindow(04,06,16,73,"Foreign Currency File")
  if FOREIGN->(LastRec())==0; Foreign_Form(APPEND_MODE); endif
  if LastKey() != K_ESC
     do while (nKey != K_ESC)
        Foreign_Form(VIEW_MODE)
        nkey := inkey(0)
        do case
           case nkey == K_DOWN
            FOREIGN->(DbSkip())
            if FOREIGN->(eof())
                FOREIGN->(Dbgobottom())
                tone(100,3)
                Message("End of file reached....")
                inkey(1)
            endif
           case nKey==K_UP
               FOREIGN->(Dbskip(-1))
               if FOREIGN->(bof())
                  FOREIGN->(Dbgotop())
                  tone(100,3)
                  Message("Beginning of file reached....")
                  inkey(1)
               endif
            case nKey==K_CTRL_PGDN
               FOREIGN->(Dbskip(NUM_TO_SKIP))
               if FOREIGN->(eof())
                  FOREIGN->(Dbgobottom())
                  tone(100,3)
                  Message("End of file reached....")
                  inkey(1)
               endif
            case nKey==K_CTRL_PGUP
               FOREIGN->(Dbskip(-NUM_TO_SKIP))
               if FOREIGN->(bof())
                  FOREIGN->(Dbgotop())
                  tone(100,3)
                  Message("Beginning of file reached....")
                  inkey(1)
               endif
            case nKey==K_END
               FOREIGN->(Dbgobottom())
                  Message("Moving to end of file....")
                  inkey(1)
            case nKey==K_HOME
               FOREIGN->(Dbgotop())
                  Message("Moving to beginning of file....")
                  inkey(1)
            case nKey==K_F2
                  Foreign_Form(APPEND_MODE)
            case nKey==K_F3
                  Foreign_Form(EDIT_MODE)
            case nKey==K_F4
             if FOREIGN->(Deleted())
               Message("Press ENTER to Undelete record, ESC to abort.")
               if inkey(0)==K_ENTER
                  Message("Undeleting current record....")
                  FOREIGN->(RecLock(0))
                  FOREIGN->(DbRecall())
                  FOREIGN->(Dbunlock())
#ifdef FM_FOREIGN 
                  FM->(FilLock())
                  FM->(DbAppend())
                  FM->TRANSNO := FMNext()
                  FM->OP_CODE := "01" // ADD
                  FM->FILE_ID := "FC" // Cashier ID
                  FM->RECDATA := GetData()
                  FM->POSTDATE:= Date()
                  FM->POSTSTAT:= 0
                  FM->(DbUnLock())                  

                  FC_HIST->(FilLock())
                  FC_HIST->(DbAppend())

                  FC_HIST->OP_CODE := "01" // ADD
                  FC_HIST->FILE_ID := "FC" // Cashier ID
                  FC_HIST->FCH_CODE := FOREIGN->F_CODE // C 2 //Foreign Curr. Code
                  FC_HIST->FCH_ABBR := FOREIGN->F_ABBR // C 3
                  FC_HIST->FCH_DESC := subs(FOREIGN->F_DESC,1,20) // C 25
                  FC_HIST->OLDRATE := padl(alltrim(str(int(FOREIGN->F_DXCHG*1000000))),10,"0") // XCHG DLR 10
                  FC_HIST->NEWRATE := padl(alltrim(str(int(FOREIGN->F_PDXCG*1000000))),10,"0") // XCHG OLD 10
                  FC_HIST->FCH_DECPOS := padl(alltrim(str(FOREIGN->F_DECPOS)),2,"0")       // DEC POS  2 
                  FC_HIST->DATE:= Date()

                  FC_HIST->(DbUnLock())                  
#endif            
               endif
             else
                Message("Press ENTER to delete record, ESC to abort.")
               if inkey(0)==K_ENTER
                  Message("Deleting current record....")
                  FOREIGN->(RecLock(0))
                  FOREIGN->(Dbdelete())
                  FOREIGN->(Dbunlock())
#ifdef FM_FOREIGN                  
                  FM->(FilLock())
                  FM->(DbAppend())
                  FM->TRANSNO := FMNext()
                  FM->OP_CODE := "03" // Delete 
                  FM->FILE_ID := "FC" // Cashier ID
                  FM->RECDATA := GetData()
                  FM->POSTDATE:= Date()
                  FM->POSTSTAT:= 0
                  FM->(DbUnLock())
                  FC_HIST->(FilLock())
                  FC_HIST->(DbAppend())

                  FC_HIST->OP_CODE := "03" // Delete
                  FC_HIST->FILE_ID := "FC" // Cashier ID
                  FC_HIST->FCH_CODE :=  FOREIGN->F_CODE // C 2 //Foreign Curr. Code
                  FC_HIST->FCH_ABBR := FOREIGN->F_ABBR // C 3
                  FC_HIST->FCH_DESC := subs(FOREIGN->F_DESC,1,20) // C 25
                  FC_HIST->OLDRATE := padl(alltrim(str(int(FOREIGN->F_DXCHG*1000000))),10,"0") // XCHG DLR 10
                  FC_HIST->NEWRATE := padl(alltrim(str(int(FOREIGN->F_PDXCG*1000000))),10,"0") // XCHG OLD 10
                  FC_HIST->FCH_DECPOS := padl(alltrim(str(FOREIGN->F_DECPOS)),2,"0")       // DEC POS  2 
                  FC_HIST->DATE:= FOREIGN->F_DATE

                  FC_HIST->(DbUnLock())                  
#endif                                                   
               endif
             endif             
            case nKey==K_F5
               FOREIGN->(Search())
         endcase
      enddo
   endif
   Message("Closing Databases....")
   FOREIGN->(DbCloseArea())
#ifdef FM_FOREIGN	
   FM->(DbCloseArea())
   FC_HIST->(DbCloseArea())
#endif
   xGetVar := {}
   CloseWindow(wWindow)
return nil    

static function Foreign_Form(nMode)
local clr, crs
    tone(300,1)
    Foreign_init(nMode)
    MsgBar(BAR)
    clr := setcolor(TITLE_ATTR)
    if FOREIGN->(Deleted()) ; @ 04, 35 say "<deleted>"
    else ; @ 04,35 say "         " ; endif
    if nMode == APPEND_MODE
       @ 04, 62 say "< New >   "
    else
       @ 04, 62 say "Rec #"+tran(FOREIGN->(recno()),"9999")
    endif
    setcolor( clr )

//jzo04-18-98    
if nMode==APPEND_MODE
    @ 06,     15 say "    Foreign Currency Code:" get xGetVar[1] PICT "@K 99" VALID VldtFCur(nMode)    
else
    @ 06,     15 say "    Foreign Currency Code:" get xGetVar[1] PICT "@K 99" VALID VldtFCur(nMode)    
    clear gets    
endif
    @ row()+1,15 say "   Foreign Currency Abbr.:" get xGetVar[2] PICT "@K! XXX" VALID !empty(xGetVar[2])
    @ row()+1,15 say "      Currency Descriptor:" get xGetVar[3] PICT "@K! "+repl("X",25) VALID !empty(xGetVar[3])   
    @ row()+1,15 say "Exchange Rate against USD:" get xGetVar[4] PICT "@K 999.999999"
//jzo
    @ row()+1,15 say "       Exchange Rate Date:" get xGetVar[12] 
*    @ row()+1,15 say "  No. of Decimal Position:" get xGetVar[11] PICT "@K 9" 
        
    @ row()+1,08 say repl("-",64)
    @ row()+1,15 say "  Accumulated Daily Sales:" get xGetVar[6] PICT "99,999,999.99" WHEN .F.
    @ row()+1,15 say "Accumulated Monthly Sales:" get xGetVar[7] PICT "99,999,999.99" WHEN .F.
    @ row()+1,15 say " Accumulated Annual Sales:" get xGetVar[8] PICT "99,999,999.99" WHEN .F.
    @ row()+1,15 say "   Previous USD XCHG Rate:" get xGetVar[9] PICT "999.999999" WHEN .F.


    if (nMode==APPEND_MODE) .or. (nMode==EDIT_MODE)
        crs := setcursor(SC_NORMAL)
        read
        if lastkey() != K_ESC
          Foreign_Save(nMode)
        endif
        setcursor( crs )
    else
        clear gets
    endif
return nil

static function VldtFCur(Mode)
local lRetVal:= .t.,nRecno := FOREIGN->(RecNo())
 if empty(xGetVar[1])
    return .f.
 endif
 xGetVar[1] := padl(alltrim(xGetVar[1]),2,"0")
 if (Mode==APPEND_MODE) .or. (Mode==EDIT_MODE .and. xGetVar[1] != FOREIGN->F_CODE )
   FOREIGN->(DbSeek(xGetVar[1]))
   if (FOREIGN->(found()))
    lRetVal := .f.
    Message(" Currency Code : "+xGetVar[1]+" already exist...")
    Tone(300,3)
    Tone(500,3)
    Inkey(3)
    Tone(200,2)
   endif
   FOREIGN->(DbGoto(nRecNo))
   MsgBar(BAR)
 endif
return lRetVal

static function Foreign_Init(nMode)
   if nMode==APPEND_MODE
      xGetVar[1] := SPACE(2)
      xGetVar[2] := SPACE(3)
      xGetVar[3] := SPACE(25)
      xGetVar[4] := 0
*      xGetVar[5] := 0
      xGetVar[6] := 0
      xGetVar[7] := 0
      xGetVar[8] := 0
      xGetVar[9] := 0     
*      xGetVar[10] := 0
      xGetVar[11] := 0
//jzo
      xGetVar[12] := date()
   else
      xGetVar[1] := FOREIGN->F_CODE
      xGetVar[2] := FOREIGN->F_ABBR
      xGetVar[3] := FOREIGN->F_DESC
      xGetVar[4] := FOREIGN->F_DXCHG
*      xGetVar[5] := FOREIGN->F_PXCHG
      xGetVar[6] := FOREIGN->F_DSLST
      xGetVar[7] := FOREIGN->F_MSLST
      xGetVar[8] := FOREIGN->F_ASLST
      xGetVar[9] := FOREIGN->F_PDXCG
*      xGetVar[10] := FOREIGN->F_PPXCG      
      xGetVar[11] := FOREIGN->F_DECPOS
//jzo
      xGetVar[12] := FOREIGN->F_DATE
   endif
return nil

static function Foreign_Save(nMode)
local cKeyCode
   Message("Saving entries...")
   if nMode==APPEND_MODE
      FOREIGN->(FilLock(0))
      FOREIGN->(Dbappend())
      FOREIGN->(DbUnLock())
   endif
   FOREIGN->(RecLock(0))
   FOREIGN->F_CODE  := xGetVar[1]
   FOREIGN->F_ABBR  := xGetVar[2]
   FOREIGN->F_DESC  := xGetVar[3]
   if FOREIGN->F_DXCHG != xGetVar[4] 
      FOREIGN->F_PDXCG := FOREIGN->F_DXCHG
      FOREIGN->F_DXCHG := xGetVar[4]
   endif   

   FOREIGN->F_DSLST := XGetVar[6]
   FOREIGN->F_MSLST := xGetVar[7]
   FOREIGN->F_ASLST := xGetVar[8]      
   FOREIGN->F_DECPOS := xGetVar[11]
//jzo
   FOREIGN->F_DATE:=xGetVar[12]
   
   FOREIGN->(DbUnlock())   
   FOREIGN->(DbCommit())

#ifdef FM_FOREIGN
   FM->(FilLock())
   FM->(DbAppend())
   FM->TRANSNO := FMNext()
   FM->OP_CODE := if (APPEND_MODE==nMode,"01","02") // ADD,OVERWRITE
   FM->FILE_ID := "FC" // Cashier ID
   FM->RECDATA := GetData()
   FM->POSTDATE:= Date()
   FM->POSTSTAT:= 0
   FM->(DbUnLock())      

   FC_HIST->(FilLock())
   FC_HIST->(DbAppend())
   FC_HIST->OP_CODE := if (APPEND_MODE==nMode,"01","02") // ADD,OVERWRITE
   FC_HIST->FILE_ID := "FC" // Cashier ID
   FC_HIST->FCH_CODE :=  FOREIGN->F_CODE // C 2 //Foreign Curr. Code
   FC_HIST->FCH_ABBR := FOREIGN->F_ABBR // C 3
   FC_HIST->FCH_DESC := subs(FOREIGN->F_DESC,1,20) // C 25

   FC_HIST->OLDRATE := FOREIGN->F_PDXCG // XCHG OLD 10
   FC_HIST->NEWRATE := FOREIGN->F_DXCHG // XCHG DLR 10

   FC_HIST->FCH_DECPOS := padl(alltrim(str(FOREIGN->F_DECPOS)),2,"0")       // DEC POS  2 
   FC_HIST->DATE := xGetVar[12]
   FC_HIST->TIME := time()   
   FC_HIST->(DbUnLock())         
#endif 
return nil

static function Search()
local wSearch
static cString 
     if empty(cString)
        cString := space(3)
     endif      
     wSearch := openwindow(09,23,13,57,"Search Currency Code")
     @ 11, 25 say "Enter Currency Code to search"
     @ 12, 38 get cString pict "@K! XX"
     setcursor(SC_NORMAL)
     read
     setcursor(SC_NONE)
     closewindow(wSearch)     
     if lastkey() != K_ESC
        if FOREIGN->(!Dbseek(cString))
           Message("Currency Code "+cString+" not found...")
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
      cData := FOREIGN->F_CODE // C 2
      cData += FOREIGN->F_ABBR // C 3
      cData += subs(FOREIGN->F_DESC,1,20) // C 25
/*
      cData += padl(alltrim(str(int(FOREIGN->F_DXCHG*1000000))),9,"0") // XCHG DLR 10
      cData += padl(alltrim(str(int(FOREIGN->F_PDXCG*1000000))),13,"0") // XCHG OLD 10
      cData += padl(alltrim(str(FOREIGN->F_DECPOS)),2,"0")       // DEC POS  2
*/
      cData += padl(alltrim(str(int(FOREIGN->F_DXCHG*1000000))),10,"0") // XCHG DLR 10
      cData += padl(alltrim(str(int(FOREIGN->F_PDXCG*1000000))),10,"0") // XCHG OLD 10
      cData += padl(alltrim(str(FOREIGN->F_DECPOS)),2,"0")       // DEC POS  2
return padr(cData,244,"0")

/* Eof() */