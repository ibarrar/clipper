#include "Janus.ch"
#include "inkey.ch"
#include "setcurs.ch"
#include "memoedit.ch"
#include "fileio.ch"
#include "directry.ch"
#include "its.ch"

#ifdef MARGIN
 #undef MARGIN
#endif

#define MARGIN      Space(5) 
#define REPORTFILE  "ITLST_BR.PRN"
#define MAX_SIZE    65535
#define MAX_LINE    50    
#define EJECT_FROM_FILE
#define DEBUG
#define THIS_WIDTH (85 + PLU_CODE_LEN + PLU_DESC_LEN +PLU_CODE_LEN ) + LEFT_MARGIN 
 
memvar n,dStartDate,dEndDate,nLimit, GetList, cReport
static cBrandName

/*=========================================*/
function ItLstBr()
/*=========================================*/
local cRef,wWindBuff
local nMaxrow := maxrow()+1, nMaxCol := maxcol()+1
local aFsize := {}
// Gauge variables
local nRecCtr := 0, hGauge, nPercent, nGaugeCtr:=1, wUpdate, dDate
local cName := space(20), dFile, code
local lNewPage := 0, nLineCtr := 0, nLinelen  := 57+41+6-23+20, nPageCtr := 1
local nPageslstot := 0, nPageslsqty := 0, cWindow
local nReccount := 0, nCtr := 1, ccolor, coldpath
local nRunslstot := 0, nRunslsqty := 0, count := 0, amount := 0
local cPname := space(20),  prevdept := space(2), prevdesc := space(20)
local lFirst := .f., ldate := .t., ncount := 0, namount := 0.00
local nDPslsqty:=0,nDPslstot:=0,nDPretqty:=0,nDPrettot:=0,nDPvoidqty:=0,nDPvoidtot:=0,nDPdisctot:=0
local nPageretqty:=0,nPagerettot:=0,nPagevoidqty:=0,nPagevoidtot:=0,nPagedisctot:=0
local nRunretqty:=0,nRunrettot:=0,nRunvoidqty:=0,nRunvoidtot:=0,nRundisctot:=0

/*
if !Getvalid()
  BUMMER() ; return nil 
endif 
*/

if !GetDept()
  BUMMER() ; return nil 
endif 


if netuse("ITEM.DBF", DB_SHARED, NUM_SECONDS)
    set index to I_041
else
   alert("File 'ITEM.DBF' cannot be accessed",{"Quit"})
   return nil    
endif	 


if netuse("DP", DB_SHARED, NUM_SECONDS)
    set index to DP_001
else
   alert("File 'DP.DBF' cannot be accessed",{"Quit"})
   return nil    
endif	 

cOldPath := SET(_SET_PATH)

Message("Preparing Item List Report By Department...")


SET ALTERNATE TO ".\"+REPORTFILE
SET ALTERNATE ON
SET CONSOLE OFF
SET PRINTER OFF

window( 19, 1, 22, 60, CONFIRM_COLOR )

lNewPage := .t.
lFirst := .t.

ITEM->(DBSEEK(alltrim(cBrandName)))
Do While ITEM->(!Eof()) .AND. ALLTRIM(cBrandName) $ ITEM->I_041
if ITEM->(!deleted())
  @ 1, 1 wsay " Creating " + "Item List Report By Brand Name" + "  Please wait ..."
  @ 2, 1 wsay " Item Code: " + ITEM->I_001 + "    "


  // Create header if new page  
  if lNewPage  
   // Create header if new page  
   ? MARGIN + "ITEM LIST REPORT"
   ?
   ? MARGIN +chr(254)+ SYS_NAME
   ? MARGIN +"Item List Report"
//   ? MARGIN +"From "+dtoc(dStartDate)+" to "+dtoc(dEndDate)
   ? MARGIN +"As of "+dtoc(date())+", "+time()
   ? MARGIN +"By Brand - " + cBrandName 
   ?
?
? MARGIN   + PADR("CODE",14)
??SPACE(2) + PADR("DESCRIPTION",40)
??SPACE(2) + PADL("COST",15)
??SPACE(2) + PADL("SRP",15)
??SPACE(2) + PADR("MARK-UP %",10)

? MARGIN + REPL("-",nLinelen)

   ?
   ?

   lNewpage := .f.
   nLineCtr := 13
  endif   
/*
if prevdept != subs(ITEM->I_006,1,2)
   prevdept:=subs(ITEM->I_006,1,2)
   DP->(DBSEEK(prevdept))
   prevdesc:=subs(DP->DP_002,1,20)
   ? MARGIN + prevdept +" "+ prevdesc
   nLineCtr+=1
endif
*/
? MARGIN + ITEM->I_001
??space(2) + ITEM->I_037
??space(2) + trans(ITEM->I_007," 999,999,999.99")
??space(2) + trans(ITEM->I_003," 999,999,999.99")
??space(2) + trans(ITEM->I_043,"999.99")
nLineCtr+=1
  // check if footer is needed, eject
  // reset counters
  if nLineCtr >= MAX_LINE 
     lNewPage := .t.
    // eject
    ? chr(12)
  endif
endif

 ITEM->(DbSkip())
enddo  

  if lNewPage  
   // Create header if new page  
   ? MARGIN + "ITEM LIST REPORT"
   ?
   ? MARGIN +chr(254)+ SYS_NAME
   ? MARGIN +"Item List Report"
//   ? MARGIN +"From "+dtoc(dStartDate)+" to "+dtoc(dEndDate)
   ? MARGIN +"As of "+dtoc(date())+", "+time()
   ? MARGIN +"By Brand - " + cBrandName 
   ?
?
? MARGIN   + PADR("CODE",14)
??SPACE(2) + PADR("DESCRIPTION",40)
??SPACE(2) + PADL("COST",15)
??SPACE(2) + PADL("SRP",15)
??SPACE(2) + PADR("MARK-UP %",10)

? MARGIN + REPL("-",nLinelen)

   ?
   ?

   endif   

 ? 
 ?
 ? MARGIN+padc("********** End of Report **********",nLineLen )  
 ?
 ? chr(12)  

CLOSE ALTERNATE
SET ALTERNATE OFF
SET CONSOLE ON

aFsize := directory(REPORTFILE)

// check if repot file is < 64K
// direct to printer if greater   

if aFsize[1][2] < MAX_SIZE

  cReport:=memoread(REPORTFILE)
  if !empty(cReport)
   if !setmode(50,80) .and. !setmode(43,80)
      setmode(nMaxrow,nMaxcol)
   else
      _logo()   
   endif       
   Message("Use cursor keys to navigate, press F10 to print, "+ ;
              "Esc to abort.")
   wWindBuff:=OpenWindow(1,2,maxrow()-1,maxcol()-2,"Item List Report ")
   MemoEdit(cReport,2,3,maxrow()-2,maxcol()-3,.f.,'EditorFunc',120 )
   CloseWindow(wWindBuff)
   setcursor(SC_NONE)
   setmode(nMaxrow,nMaxcol)
  endif
 
else

 if alert("Report too large to edit, will be directed to printer", {"Print","Quit"}) == 1 
    Direct2Prn(REPORTFILE) 
 endif  
 
endif  


cReport := "" //Free memory      
  
DbCloseAll()
return nil




static function GetDept()
local wValid
cBrandName:=space(25)
    Message("Enter Brand Name to cover reports")
    wValid := OpenWindow(09,12,15,66,"Printing Validation Box")
    @ 10,12 to 15,66 double    
      @ 12,17 say "Enter Brand Name" get cBrandName pict "@!"
      SetCursor(SC_NORMAL)
      HeyThere()
      read
      SetCursor(SC_NONE)
    CloseWindow(wValid)
return if(LastKey()==K_ESC,.F.,.T.)
