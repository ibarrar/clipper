#include "cashterm.ch"
#include "directry.ch"
#include "janus.ch"
#include "fileio.ch"
#include "inkey.ch"
#include "setcurs.ch"
#include "aChoice.ch"
#include "set.ch"
#include "box.ch"
#include "abrowse.ch"

static browse,cDesc,cStr
static nFhandle
static nkey
static aflag := {"Z", "0", "1", "2", "3", "4", "5", "6", "7", "8", "9" }

memvar getlist


function Monitor()

local RetVal:= nil,oCur, wLookup,nLen:= 0
local column, nKey
local r1:= 5,y1:= 5,r2, y2,cColor := if(iscolor(),"W+/G+,W+/GR","N/W,W+/N")
local oCol, cTitle := "ON-LINE PLU"
local lSet := set(_SET_DELETED,.t.)
local cpath, i := space(2) , cFileName, aChoices_ := {}, nMoveto
local n := 0, nAchoice
local aTrans := {}, aTmp := {}
local bMyBlock

     aAdd(aTmp ,{ "TRANS_NO",   "C", 08  , 0 } )
     aAdd(aTmp ,{ "ITEM_CODE",    "C", 20  , 0 } )
     aAdd(aTmp ,{ "TRANSACTION",  "C", 20  , 0 } )
     aAdd(aTmp ,{ "ACCT_NO",   "C", 20  , 0 } )
     aAdd(aTmp ,{ "QUANTITY",    "N", 4   , 0 } )
     aAdd(aTmp ,{ "AMOUNT",    "N", 10  , 2 } ) 
     
     

     DbCreate("ONLINE", aTmp)




 if NetUse("UM",DB_SHARED,NUM_SECONDS)
    Index on UM->MACHINENO TO machine
 endif

  if NetUse("ONLINE",DB_SHARED,NUM_SECONDS)
  endif 


   UM->(DbGotop())
   while UM->(!eof()) 
     aAdd(aChoices_," TERMINAL NO.  " + UM->MACHINENO+" ")
     UM->(DbSkip())
   enddo
 
 n:= LookUp( 10,30, aChoices_,"MACHINE NO.")
 i := substr(aChoices_[n],16,2)

 
 
 
/* UM->(DbGotop())
 if UM->(DbSeek(i))
    cpath := alltrim(UM->UMAC_PATH)
 endif
*/
message("Machine No. " + i) 
CPATH := "S:\MTS_POS\FM_TRANS\"
  
  cFileName := (cpath) +"ITEM00"+ i +".TXT"
  
  nFHandle := fopen(cFileName,FO_READ+FO_SHARED)
  
  if nFHandle == -1
    Alert("Error opening file : '"+cFileName+"'", {"Return"})
    return -1 
  endif

//  nMoveTo := fseek(nFHandle, 0, FS_END)


 ONLINE()   
 Message("                                               ")
  
 cTitle := alltrim(cTitle)
/* if (Lastrec() == 0)
    Message(" No Available "+cTitle+" Yet... ")
    Tone(300,2)
    Tone(500,2)
    Tone(700,3)
    RetVal := 0
 else
    r2 := r1+1+lastrec()
    if r2 > (maxrow()-1)
      r2 := (maxrow()-1)
    endif      
    y2 := y1+ 70 */

    r2 := 20
    y2 := 75
    wLookUp :=  savescreen(r1,y1,r2+1,y2+1)
    Shadow(r1,y1,r2,y2)
    oCol := SetColor(cColor)
    oCur := SetCursor(0)
    @ r1, y1, r2, y2 Box B_DOUBLE + " "
    nLen := y2-y1
    if Len(cTitle) > nLen
      cTitle := substr(cTitle,1,nLen)
    endif
    @ r1,y1+((nLen-len(cTitle))*0.5) Say cTitle
    
    //Create a new browse object.
    browse := TBrowseDB(r1+1,y1+1,r2-1,y2-1)
    //Assign browse attributes.
    browse:headsep := MY_HEADSEP
    browse:colSep := MY_COLSEP
    browse:footSep := "" 
    browse:colorSpec := cColor //"N/W,N/BG,B/W,B/BG,R/W,B/R"

   for i := 1 to FCount() 
    column:=TBColumnNew(Field(i),fieldBlock(field(i)) ) 
    browse:addColumn(column)
   next 

    browse:freeze := 1
    


    while .t.
    
      while !browse:stabilize()
         if nextkey() != 0
            Exit
         endif
      enddo

      if online()
         browse:invalidate()
         browse:refreshall()
      endif

      nKey := inkey(0.5)

      Do case
         case nKey == K_UP
              browse:up()
         case nKey == K_DOWN
              browse:down()
         case nKey == K_LEFT
              browse:left()
         case nKey == K_RIGHT
              browse:right()     
         case nKey == K_PGUP
              browse:pageUp()
         case nKey == K_PGDN
              browse:pageDown()              
         case nKey == K_HOME
              browse:home()
         case nKey == K_END
              browse:end()
         case nKey == K_CTRL_PGUP
              browse:gotop()
         case nKey == K_CTRL_PGDN
              browse:gobottom()
         case nKey == K_ESC
              RetVal :=  0
              Exit
  // No Searching for Now maybe tomorrow
      endcase
    enddo

    RestScreen(r1,y1,r2+1,y2+1,wLookUp)
    SetCursor(oCur)
    SetColor(oCol)
    set(_SET_DELETED,lSet)
//  endif  

  Fclose(nFHandle)


DbCloseAll()
HEYTHERE() ; OKDONE()
INKEY(1)      
return NIL



static function online()

local aflag := {"Z", "0", "1", "2", "3", "4", "5", "6", "7", "8", "9" }
local nQty := 0, nAmt := 0

    cStr := space(128)
    
    if fread(nFHandle,@cStr,128) != 128
        return .F.
    endif   

    DO CASE
      CASE TRANSFLAG == "N"           // normal
          cDesc := "NORMAL"
          nQty :=   QTTY
          nAmt :=   SLSAMOUNT
      CASE TRANSFLAG == "P"           // not found
          cDesc := "NOT FOUND"
          nQty :=   QTTY
          nAmt :=   SLSAMOUNT
      CASE TRANSFLAG == "M"           // open department  
          cDesc := "OPEN DEPARTMENT"
          nQty :=   QTTY
          nAmt :=   SLSAMOUNT
      CASE TRANSFLAG == "E"           // return/exchange
          cDesc := "RETURN/EXCHANGE" 
          nQty :=   QTTY * -1
          nAmt :=   SLSAMOUNT * -1
      CASE TRANSFLAG == "R"           // refund
          cDesc := "REFUND"
          nQty :=   QTTY * -1
          nAmt :=   SLSAMOUNT * -1    
      CASE TRANSFLAG == "D"           // item discount
          cDesc := "DISCOUNT"
          nAmt :=   SLSAMOUNT * -1
      CASE TRANSFLAG == "S"           // subtotal discount
          cDesc := "SUBTOTAL DISCT."
          nAmt :=   SLSAMOUNT * -1
      CASE TRANSFLAG == "O"           // other income
          cDesc := "OTHER INCOME"
          nAmt :=  SLSAMOUNT
      CASE TRANSFLAG == "V"          // cashier's void
          cDesc := "ITEM VOID"
          nAmt :=   SLSAMOUNT * -1   
      CASE TRANSFLAG == "G"           // manager's void
          cDesc := "MANAGER'S VOID"
          nAmt :=  SLSAMOUNT * -1
      CASE TRANSFLAG == "C"           // cancel
          cDesc := "CANCEL"
          nAmt :=  SLSAMOUNT 
      CASE TRANSFLAG == "Z"           // Z flag
          if PAYMTYPE != "0000"
            cDesc := "CARD"
          else
            cDesc := "CASH"
          endif
          nAmt :=  SLSAMT 
      CASE  aScan(aFlag, TRANSFLAG) != 0         // split payment
          if PAYMTYPE != "0000"
            cDesc := "CARD-SPLIT PAYMENT"
          else
            cDesc := "CASH-SPLIT PAYMENT"
          endif
          nAmt :=  SLSAMT         
      CASE TRANSFLAG == "!"              // sign on
          cDesc := "SIGN-ON"
          nAmt :=  SLSAMT         
      CASE TRANSFLAG == "?"             // sign off
          cDesc := "SIGN-OFF"
          nAmt :=  SLSAMT                 
    ENDCASE 


    ONLINE->(DbAppend())
    ONLINE->(RecLock(0))
    ONLINE->TRANS_NO := TRANSNO

    DO CASE
      CASE TRANSFLAG == "Z" .OR. aScan(aFlag, TRANSFLAG) != 0  
        ONLINE->ITEM_CODE := SPACE(20)
      CASE TRANSFLAG == "!"
         ONLINE->ITEM_CODE := substr(cStr,37,20)
      CASE TRANSFLAG == "?"  
         ONLINE->ITEM_CODE := substr(cStr,37,20)
      OTHERWISE
         ONLINE->ITEM_CODE := PLUCODE
    ENDCASE
    
    ONLINE->TRANSACTION := cDesc
    if TRANSFLAG == "Z" .OR. aScan(aFlag, TRANSFLAG) != 0  
      ONLINE->ACCT_NO := C1
    ELSE  
      ONLINE->ACCT_NO := space(20)
    ENDIF  
    ONLINE->QUANTITY := nQty
    ONLINE->AMOUNT := nAmt
    ONLINE->(DbUnLock())

    Tone(300,1) // HEYTHERE()
    
    
return .T.