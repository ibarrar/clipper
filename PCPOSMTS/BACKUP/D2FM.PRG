*** D2FM.PRG ***
//this module is added by jzo04-03-98

#include "box.ch"
#include "its.ch"
#include "inkey.ch"
#include "Janus.ch"
#include "aChoice.ch"
#include "setcurs.ch"
/*
#ifdef COLOR_STAT
#define BAR "F2-Add F3-Edit F4-Delete F5-Code F6-Desc F7-Stock F8-Vendor ESC-Abort"
#else
#define BAR "F2-Add F3-Edit F4-Delete F5-Code F6-Desc F7-Stock F8-Vendor ESC-Abort"
#endif
*/
#undef CLASS_LINK

static getlist := {}
memvar nUnit 

static xGetVar,aPicture3,nCheck
#ifdef CLASS_LINK
static aClass := {}
#else
static aDept := {}
#endif

static aChoices := {}
static aCosts := {}

static dstrt,dend //jzo

function d2fm(dep)
local wWindow, nkey ,cDpno
   xGetVar := array(39)
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
      V->(Dbsetindex("V_001"))
   endif 
   if NetUse("IV",DB_SHARED,NUM_SECONDS)
      IV->(Dbsetindex("IV_LINK"))
   endif
   if NetUse("DP",DB_SHARED,NUM_SECONDS)
      DP->(Dbsetindex("DP_001"))
   endif
#ifdef CLASS_LINK
   if NetUse("CL",DB_SHARED,NUM_SECONDS)
      CL->(Dbsetindex("CL_001"))
   endif
#endif   
   if NetUse("UITEMS",DB_SHARED,NUM_SECONDS)
      Set Index to UITEMS
   endif   
   if NetUse("ITEM.DBF",DB_SHARED,NUM_SECONDS)
//jzo05-15-98      Set Index to I_001,I_002,I_006,I_033
      Set Index to I_006
   endif   
   

ITEM->(DbSEEK(dep))
do while !ITEM->(eof()) .and. dep!=subst(ITEM->I_006,1,2)
cDpno:=subst(ITEM->I_006,1,2)
//Message("cDpno "+cDpno+" dep "+dep)
//inkey(1)
  if alltrim(cDpno)==alltrim(dep)
    Init()   
    Save()
  endif 
   ITEM->(DbSkip())
enddo

   Message("Closing Databases....")
   ITEM->(DbCloseArea())
   UITEMS->(DbCloseArea())
#ifdef CLASS_LINK
   CL->(DbCloseArea())
#endif   
//   DP->(DbCloseArea())
//   V->(DbCloseArea()) 
   IV->(DbCloseArea())
//#ifdef FM_ITEMS   
//   FM->(DbCloseArea())
//#endif                  


return nil



static function Save()
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
/*
      if nMode == APPEND_MODE
         UITEMS->(DbAppend())
         UITEMS->UI_MAX_BAL := xGetVar[10]
         UITEMS->UI_MIN_BAL := xGetVar[11]
         UITEMS->UI_REORDER := xGetVar[12]
         UITEMS->UI_OP_FLAG := 1
      else
*/      
         if !UITEMS->(DbSeek(xGetVar[1]))
            UITEMS->(DbAppend())
            UITEMS->UI_MAX_BAL := xGetVar[10]
            UITEMS->UI_MIN_BAL := xGetVar[11]
            UITEMS->UI_REORDER := xGetVar[12]
            
         endif
         UITEMS->UI_OP_FLAG := 2
/*
      endif
*/
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
/*
   if nMode==APPEND_MODE
      ITEM->(FilLock(0))
      ITEM->(Dbappend())
      ITEM->I_039 := 1
      ITEM->(DbUnLock())
   ELSE
*/   
      ITEM->(RecLock(0))
      ITEM->I_039 := 2
      ITEM->(DbUnLock())   
/*
   endif
*/
      ITEM->(RecLock(0))
      ITEM->I_001 := xGetVar[ 1]
      ITEM->I_002 := xGetVar[ 2]
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
      ITEM->(DbCommit())
      ITEM->(DbUnlock())

   xGetVar[03]:=compucost(xGetVar[03]) //jzo
      
#ifdef FM_ITEMS
     FM->(FilLock())
     FM->(DbAppend())
     FM->TRANSNO := FMNext()
     FM->OP_CODE := "02" // OVERWRITE
     FM->OP_FLAG := 1
     FM->FILE_ID := "PL" // File ID Item
     FM->RECDATA := GetData()
     FM->POSTDATE:= Date()
     FM->POSTSTAT:= 0
     FM->(DbUnLock())
#endif
return nil


static function Init()
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

return nil


static function compucost(nret)
local npcent:=0,npercent:=0

DP->(DBSEEK(xGetVar[06]))

if date()>=DP->DP_006 .and. date()<=DP->DP_007
   if nret==0
      return 0
   endif
//   if DP->(dbSeek(xGetvar[06]))
      nPercent := DP->DP_009
//   endif

   npcent := 100 - npercent
   xGetVar[03] := nret * (npcent/100)
else
   return nret
endif      
return xGetVar[03]


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
      
//      cData += padl(alltrim(strtran(str(ITEM->I_003),".","")),10,"0") // selling price
//jzo04-01-98
      cData += padl(alltrim(strtran(str( round(xGetVar[03],2) ),".","")),10,"0") // selling price

      cData += repl("0",10) // price level 1
      cData += repl("0",10) // price level 2
      cData += repl("0",10) // price level 3
      cData += repl("0",10) // price level 4
      cData += repl("0",10) // price level 5
      cData += padl(alltrim(strtran(str(ITEM->I_007),".","")),10,"0") // unit cost

      cData += repl("0",4)  // time start
      cData += repl("0",4)  // time end

    
//jzo       
DP->(DBSEEK(xGetVar[06]))
      dstrt:=DP->DP_006
      dend:=DP->DP_007
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

return pad(cData,244,"0")

