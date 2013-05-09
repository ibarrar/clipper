*** DEPARTME.PRG ***

#include "box.ch"
#include "its.ch"
#include "inkey.ch"
#include "Janus.ch"
#include "aChoice.ch"
#include "setcurs.ch"

#ifdef COLOR_STAT
#define BAR "F2-Add F3-Edit F4-[Del/Undel] F5-Search F8-Update  ESC-Abort"
#else
#define BAR "F2-Add  F3-Edit  F4-[Del/Undel]  F5-Search  F6-Update  ESC-Abort"
#endif

memvar getlist

static xGetVar[11],ndisc_rate

function do_Depart()
local wDept, nkey
   Message("Opening Database...")
#ifdef FM_DEPT   
   if NetUse("FM",DB_SHARED,NUM_SECONDS)
      Set Index to FM
   endif
#endif   
   if NetUse("V",DB_SHARED,NUM_SECONDS)
      Set Index to V_001
   endif  
   if NetUse("DP",DB_SHARED,NUM_SECONDS)
      set index to DP_001
   endif
   wDept := OpenWindow(04,06,10,73,"Department File")
   if DP->(reccount())==0 ; Dept_Form(APPEND_MODE) ; endif
   if lastKey()!=K_ESC
      do while (nkey!=K_ESC)
         Dept_Form(VIEW_MODE)
         nkey:=inkey(0)
         do case
            case nkey==K_DOWN
               DP->(Dbskip())
               if DP->(eof())
                  DP->(Dbgobottom())
                  tone(100,3)
                  Message("End of file reached....")
                  inkey(1)
               endif
            case nKey==K_UP
               DP->(Dbskip(-1))
               if DP->(bof())
                  DP->(Dbgotop())
                  tone(100,3)
                  Message("Beginning of file reached....")
                  inkey(1)
               endif
            case nKey==K_CTRL_PGDN
               DP->(Dbskip(NUM_TO_SKIP))
               if DP->(eof())
                  DP->(Dbgobottom())
                  tone(100,3)
                  Message("End of file reached....")
                  inkey(1)
               endif
            case nKey==K_CTRL_PGUP
               DP->(Dbskip(-NUM_TO_SKIP))
               if DP->(bof())
                  DP->(Dbgotop())
                  tone(100,3)
                  Message("Beginning of file reached....")
                  inkey(1)
               endif
            case nKey==K_END
               DP->(Dbgobottom())
                  Message("Moving to end of file....")
                  inkey(1)
            case nKey==K_HOME
               DP->(Dbgotop())
                  Message("Moving to beginning of file....")
                  inkey(1)
            case nKey==K_F2
                  Dept_Form(APPEND_MODE)
            case nKey==K_F3
               Dept_Form(EDIT_MODE)
               if lastkey()!=K_ESC
                 if ndisc_rate != xGetVar[9]
                  d2fm(xGetVar[01]) //added by jzo03-31-98
                 endif
               endif   
            case nKey==K_F4
             if DP->(Deleted())
               Message("Press ENTER to Undelete record, ESC to abort.")
               if inkey(0)==K_ENTER
                  Message("Undeleting current record....")
                  DP->(RecLock(0))
                  DP->(DbRecall())
                  DP->DP_012 := 4
                  DP->(Dbunlock())
#ifdef FM_DEPT                  
                  FM->(FilLock())
                  FM->(DbAppend())
                  FM->TRANSNO := FMNext()
                  FM->OP_CODE := "01"   // ADD
                  FM->OP_FLAG := 1
                  FM->FILE_ID := "DP" // Cashier ID 03 Dept
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
                  DP->(RecLock(0))
                  DP->(Dbdelete())
                  DP->DP_012 := 3
                  DP->(Dbunlock())
#ifdef FM_DEPT                  
                  FM->(FilLock())
                  FM->(DbAppend())
                  FM->TRANSNO := FMNext()
                  FM->OP_CODE := "03" // Delete
                  FM->OP_FLAG := 1
                  FM->FILE_ID := "DP" // Cashier ID 03 Dept
                  FM->RECDATA := GetData()
                  FM->POSTDATE:= Date()
                  FM->POSTSTAT:= 0
                  FM->(DbUnLock())                  
#endif                  
               endif
             endif
            case nKey==K_F5
               DP->(Search_Form("Department",2))
            case nKey==K_F8
	       Update()
         endcase
      enddo
   endif
   Message("Closing Databases....")
   DP->(DbCloseArea())
#ifdef FM_DEPT   
   FM->(DbCloseArea())
#endif   
   V->(DbCloseArea())
   CloseWindow(wDept)
return nil

static function Dept_Form(nMode)
local clr, crs
   tone(300,1)
   Dept_Init(nMode)
   MsgBar(BAR)
   clr := setcolor(TITLE_ATTR)
   if DP->(Deleted()) ; @ 04,35 say "<deleted>"
      else ; @ 04,35 say "         " ; endif
   if nMode==APPEND_MODE
       @ 04, 62 say "< New >   "
   else
       @ 04, 62 say "Rec #"+transform(DP->(recno()),"9999")
   endif
   setcolor( clr )
   @ 06,      09 say "Department Code" get xGetVar[1] PICT "@K 99" VALID VldtDept(nMode)
   @ row()+1, 09 say "Department Name" get xGetVar[2] PICT "@K!S16" VALID !empty(xGetVar[2])
   @ row()+1, 09 say "   Group Number" get xGetVar[3] PICT "@K 99" RANGE 0,99
   @ row()+1, 09 say "            OTB" get xGetVar[4] PICT "@KR 99,999,999.99" // VALID !empty(xGetVar[4])
   @ 06,      42 say "     Start Date" get xGetVar[6] 
   @ row()+1, 42 say "       End Date" get xGetVar[7] 
   @ row()+1, 42 say "       Tax Rate" get xGetVar[8] PICT "@K 99"
   @ row()+1, 42 say "  Discount Rate" get xGetVar[9] PICT "@K 99"
/*   
   @ row()+1, 41 say "High Amt Lockout" get xGetVar[10] PICT "@K 99,999,999.99"
   @ row()+1, 41 say "Low Amt Lockout " get xGetVar[11] PICT "@K 99,999,999.99"
*/
   if (nMode==APPEND_MODE) .or. (nMode==EDIT_MODE)
      crs := setcursor(SC_NORMAL)
      read
      if lastkey()!=K_ESC
         Dept_Save(nMode)
      endif
      setcursor( crs )
   else
      clear gets
   endif
return nil

static function VldtDept(Mode)
local lRetVal:= .t.,nRecno := DP->(RecNo())
 if empty(xGetVar[1])
    return .f.
 endif
 xGetVar[1] :=  padl( alltrim(xGetVar[1]),2,"0")
 if (Mode == APPEND_MODE) .or.(Mode==EDIT_MODE .and. xGetVar[1] != DP->DP_001)
   DP->(DbSeek(xGetVar[1]))
   if (DP->(found()))
    lRetVal := .f.
    Message(" Department code : "+xGetVar[1]+" already exist...")
    Tone(300,3)
    Tone(500,3)
    Tone(200,2)
   endif
   DP->(DbGoto(nRecNo))
   MsgBar(BAR)
 endif
return lRetVal

/*
function PreVldtVen()
local bMyBlock,lVal := .t.
local nREcNo := V->(REcNo())

 Message(" Please Wait...")
 bMyblock := {|| " "+V->V_001+" "+V->V_002+" "}
 if (V->(DbfLookUp(7,45,bMyBlock,"Supplier Reference Link",xgetVar[5])) != 0)
     xGetVar[5] := V->V_001
     lVal := .f.
 endif
 V->(DbGoto(nRecNo))
return lVal
*/
 
static function Dept_Init(nMode)
   if nMode==APPEND_MODE
      xGetVar[ 1] := SPACE(2)
      xGetVar[ 2] := SPACE(25)
      xGetVar[ 3] := 0
      xGetVar[ 4] := 0
      xGetVar[ 5] := space(3)
      xGetVar[ 6] := date()
      xGetVar[ 7] := date()
      xGetVar[ 8] := 0
      xGetVar[ 9] := 0
      xGetVar[10] := 0
      xGetVar[11] := 0            
   else
      xGetVar[ 1] := DP->DP_001
      xGetVar[ 2] := DP->DP_002
      xGetVar[ 3] := DP->DP_003
      xGetVar[ 4] := DP->DP_004
      xGetVar[ 5] := DP->DP_005
      xGetVar[ 6] := DP->DP_006
      xGetVar[ 7] := DP->DP_007
      xGetVar[ 8] := DP->DP_008
      xGetVar[ 9] := DP->DP_009      

ndisc_rate:=xGetVar[ 9]

      xGetVar[10] := DP->DP_010
      xGetVar[11] := DP->DP_011         
   endif
return nil

static function Dept_Save(nMode)
local cKeyCode
   Message("Saving entries...")   
   if nMode==APPEND_MODE
      DP->(FilLock(0))
      DP->(Dbappend())
      DP->DP_012 := 1
      DP->(DbUnLock())
   else
      DP->(RecLock(0))
      DP->DP_012 := 2
      DP->(DbUnLock())
   endif
   DP->(RecLock(0))
   DP->DP_001 := xGetVar[ 1]
   DP->DP_002 := xGetVar[ 2]
   DP->DP_003 := xGetVar[ 3]
   DP->DP_004 := xGetVar[ 4]
   DP->DP_005 := xGetVar[ 5] 
   DP->DP_006 := xGetVar[ 6] 
   DP->DP_007 := xGetVar[ 7] 
   DP->DP_008 := xGetVar[ 8] 
   DP->DP_009 := xGetVar[ 9] 
   DP->DP_010 := xGetVar[10]
   DP->DP_011 := xGetVar[11]         
   DP->(DbUnlock())
   DP->(DbCommit())

#ifdef FM_DEPT
   FM->(FilLock())
   FM->(DbAppend())
   FM->TRANSNO := FMNext()
   FM->OP_CODE := if (APPEND_MODE==nMode,"01","02") // ADD,OVERWRITE
   FM->FILE_ID := "DP" // Cashier ID
   FM->OP_FLAG := 1
   FM->RECDATA := GetData()
   FM->POSTDATE:= Date()
   FM->POSTSTAT:= 0
   FM->(DbUnLock())
#endif   

return nil

static function GetData()
local cData
      cData := "00"+DP->DP_001       // Dept Code    BCD
      cData += substr(DP->DP_002,1,20)       // Desc         CHR      
      cData += "0000"   // Vendor code  BCD
      cData += subs(dtoc(DP->DP_006),1,2)+;
               subs(dtoc(DP->DP_006),4,2)+;
               subs(dtoc(DP->DP_006),7,2)   // Start Date
      cData += subs(dtoc(DP->DP_007),1,2)+;
               subs(dtoc(DP->DP_007),4,2)+;
               subs(dtoc(DP->DP_007),7,2)   // End  Date
if DP->DP_008 >= 10.00
      cData += substr(alltrim(strtran(str(DP->DP_008),".","")),1,2)
else
      cData += padl(alltrim(str(val(strtran(strtran(str(DP->DP_008),"0",""),".","")))),2,"0")
endif
if DP->DP_009 >= 10.00
      cData += substr(alltrim(strtran(str(DP->DP_009),".","")),1,2)
else
      cData += padl(alltrim(str(val(strtran(strtran(str(DP->DP_009),"0",""),".","")))),2,"0")
endif
      cData += padl(alltrim(str(int(DP->DP_010*100))),10,"0") // HALO
      cData += padl(alltrim(str(int(DP->DP_011*100))),10,"0") // LALO
return padr(cData,244,"0")

static function Update()
local nRecno:=DP->(Recno())
local cwin:=Openwindow(09,23,13,57,"Department Code")
local nPrice

 @ 11,25 say "Department Code : " + DP->DP_001
 message("Press [Enter] to confirm [Esc] to abort...")

 if inkey(0) != K_ENTER 
    closewindow(cwin)
    bummer()
    return nil
 endif

 if DP->DP_006 > date() .and. DP->DP_007 < date()
    closeWindow(cWin)
    bummer()
    alert("Discount date is not effective!",{" O K "})
    return nil
 endif

#ifdef CLASS_LINK
   if NetUse("CL",DB_SHARED,NUM_SECONDS)
      SET INDEX TO CL_001
   endif
#endif   
 if Netuse("ITEM.DBF",DB_SHARED,NUM_SECONDS)
    Set Index to I_001,I_002,I_033,I_020
 endif

 ITEM->(dbgotop())
 while ITEM->(!eof())

  if subs(ITEM->I_006,1,2) == DP->DP_001
     ITEM->(reclock())

     nPrice := (ITEM->I_007 * (ITEM->I_043/100)) + ITEM->I_007

     if nPrice > 0
        ITEM->I_003 := nPrice - (nPrice * (DP->DP_009 * .01))
     else
        ITEM->I_003 := ITEM->I_003 - (ITEM->I_003 * (DP->DP_009 * .01))
     endif	

     ITEM->I_039 := 2
     ITEM->(dbUnlock())
          
#ifdef FM_ITEMS
     FM->(FilLock(1))
     FM->(DbAppend())
     FM->TRANSNO := FMNext()
     FM->OP_CODE := "02"    // OVERWRITE
     FM->OP_FLAG := 1
     FM->FILE_ID := "PL"   // File ID Item
     FM->RECDATA := GetPl_Data()
     FM->POSTDATE:= Date()
     FM->POSTSTAT:= 0
     FM->(DbUnLock())
#endif
      
  endif

  message("Item Code: "+ITEM->I_001)
  ITEM->(dbskip())
 enddo

 ITEM->(dbcommit())
 ITEM->(dbcloseArea())
 CL->(dbcloseArea())
    
 closewindow(cwin)
 DP->(dbgoto(nRecno))
return nil


static function GetPl_Data()
local cData
local dstrt,dend

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

      // DP->(DBSEEK(xGetVar[06]))
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

//end-of-file
