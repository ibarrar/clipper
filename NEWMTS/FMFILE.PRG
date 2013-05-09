#include "Its.ch"
#include "janus.ch"
#include "Box.ch"
#include "setcurs.ch"
#include "inkey.ch"
#include "Set.ch"
#include "FileIO.ch"


#define R1 03
#define C1 02
#define R2 maxrow()-3
#define C2 C1+26

#define LEFT C2+2

#define FM_PATH    "S:\"
#define FM_FILE    "FM_TRANS.TXT"
#define BLOCK_LEN  256

#ifdef COLOR_STAT
#define BAR "Arrow Keys-Navigate  ENTER-View  F2-DownLoad"
#else
#define BAR "Arrow Keys-Navigate  ENTER-View  F2-DownLoad"
#endif

memvar Getlist

function fmfile()
local bBlock,mStart:=""
local n := 99
local lSet := set(_SET_DELETED,.F.)
local oCur, wLookup, browse, column, nKey
local oCol,cColor := if(Iscolor(),"W+/B,W+/GR","N+/W,W+/N")
local nup := 0, ndown := 0

  if NetUse("FM",DB_SHARED,NUM_SECONDS)
     Set Index to FM
  endif

  if (LastRec() > 0)  
  
    Message("Please Wait...")
    bBlock := { || " "+padl(alltrim(str(FM->TRANSNO)),8,"0")+" "+FM->OP_CODE+" "+FM->FILE_ID+" "+dtoc(FM->POSTDATE)+" " }

    wLookUp := savescreen(R1,C1,maxrow()-2,maxcol())
    Shadow(R1,C1,R2,maxcol()-2)

    oCur := SetCursor(0)
    oCol := SetColor("W+/W")
/*jzo
    Scroll(R1,C2+1,R2,maxCol()-2)
    DispBox(R1,C2+1,R2,maxcol()-2,B_DOUBLE)
*/    
    Scroll(R1,C2+1,R2,maxCol()-1)
    DispBox(R1,C2+1,R2,maxcol()-1,B_DOUBLE)
    
    SetColor(cColor)
    Scroll(R1,C1,R2,C2)
    DispBox(R1,C1,R2,C2,B_DOUBLE)
    
    browse := TBrowseDB(R1+1,C1+1,R2-1,C2-1)
    //Assign browse attributes.
    browse:headsep := ""
    browse:colSep := ""
    browse:footSep := ""
    browse:colorSpec := cColor //"N/W,N/BG,B/W,B/BG,R/W,B/R"

    column:=TBColumnNew("",bBlock ) 

    browse:addColumn(column)

    browse:freeze := 1

*    GoGet(FM->FILE_ID,FM->RECDATA)      
    nup := 0
    ndown := 0
    while .t.
      MsgBar(BAR)
      while !browse:stabilize()
         if nextkey() != 0
            Exit
         endif
      enddo
            
      nKey := inkey(0)
      GoGet(FM->FILE_ID,FM->RECDATA)      
      Do case
         case nKey == K_UP
              browse:up()
              nDown := 0
              nup += 1
              if nup == 1
               FM->(DbSkip(-1))
               GoGet(FM->FILE_ID,FM->RECDATA)      
              endif 
         case nKey == K_DOWN
              browse:down()
              nup := 0
              ndown += 1
              if ndown == 1
               FM->(DbSkip())
               GoGet(FM->FILE_ID,FM->RECDATA)      
              endif 
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
              Message("Exiting....")
              HEYTHERE()
              Exit
         case nkey == K_ENTER
              GoGet(FM->FILE_ID,FM->RECDATA)
*              FM->(DbSkip())
         case nKey == K_F2
              DownLoad()
              Message("Done Downloading...")
              OKDONE()
              Exit
      endcase
*      GoGet(FM->FILE_ID,FM->RECDATA)      
    enddo                       

    RestScreen(R1,C1,maxrow()-2,maxcol(),wLookUp)
    SetCursor(oCur)
    SetColor(oCol)
    set(_SET_DELETED,lSet)    
  
  else
    Message(" No Available FM Record Yet... ")
    Tone(300,2)
    Tone(500,2)
    Tone(700,3)               
  endif

  FM->(DbCLoseArea())

return nil

static function GoGet(nFileCode,mData)
local xGetVar[1]
local cColor :=SetColor(if(IsColor(),"N/W,GR+/B","N/W,W/N"))
local nOffSet
/*
   Scroll(R1+1,C2+2,R2-1,maxCol()-3)
*/
   Scroll(R1+1,C2+2,R2-1,maxCol()-2)
   @ R1+1,C2+2 say "FILE ID : "+ nFileCode 
   do case 
      case nFileCode == "PL" // PLU/SDF
        @ row(), col() say " PLU/SDF FILE "
        aSize(xGetVar,26)        
        nOffset := 1                                     //Offset Desc 
        xGetVar[01]:= subs(mData,nOffSet,14);nOffSet+=14 //  plu code 
        xGetVar[02]:= subs(mData,nOffSet,12);nOffSet+=12 //  stock code
        xGetVar[03]:= subs(mData,nOffSet,20);nOffSet+=20 //  descriptor
        xGetVar[04]:= subs(mData,nOffSet,02);nOffSet+=02 //  size
        xGetVar[05]:= subs(mData,nOffSet,02);nOffSet+=02 //  color
        xGetVar[06]:= subs(mData,nOffSet,04);nOffSet+=04 //  class_code
        xGetVar[07]:= subs(mData,nOffSet,04);nOffSet+=04 //  dept code
        xGetVar[08]:= subs(mData,nOffSet,04);nOffSet+=04 //  conc code
        xGetVar[09]:= subs(mData,nOffSet,10);nOffSet+=10 //  selling price
        xGetVar[10]:= subs(mData,nOffSet,10);nOffSet+=10 //  price level 1   
        xGetVar[11]:= subs(mData,nOffSet,10);nOffSet+=10 //  price level 2   
        xGetVar[12]:= subs(mData,nOffSet,10);nOffSet+=10 //  price level 3   
        xGetVar[13]:= subs(mData,nOffSet,10);nOffSet+=10 //  price level 4   
        xGetVar[14]:= subs(mData,nOffSet,10);nOffSet+=10 //  price level 5   
        xGetVar[15]:= subs(mData,nOffSet,10);nOffSet+=10 //  price level 6   
        xGetVar[16]:= subs(mData,nOffSet,04);nOffSet+=04 //  time start
        xGetVar[17]:= subs(mData,nOffSet,04);nOffSet+=04 //  time end
        xGetVar[18]:= subs(mData,nOffSet,04);nOffSet+=04 //  base qty
        xGetVar[19]:= subs(mData,nOffSet,08);nOffSet+=08 //  day of week
        xGetVar[20]:= subs(mData,nOffSet,04);nOffSet+=04 //  disct rate
        xGetVar[21]:= subs(mData,nOffSet,10);nOffSet+=10 //  disct amount
        xGetVar[22]:= subs(mData,nOffSet,04);nOffSet+=04 //  ssd rate
        xGetVar[23]:= subs(mData,nOffSet,10);nOffSet+=10 //  ssd amount
        xGetVar[24]:= subs(mData,nOffSet,10);nOffSet+=10 //  ad tax1
        xGetVar[25]:= subs(mData,nOffSet,10);nOffSet+=10 //  ad tax2
        xGetVar[26]:= subs(mData,nOffSet,16);nOffSet+=16 //  status bytes
        @ row()+1, LEFT say "ASSO. DEPT    :" get xGetVar[07]
        @ row(), col()+2 say "CONCESSIONAIRE:" get xGetVar[08]
        @ row()+1, LEFT say "CLASS CODE    :" get xGetVar[06]
        @ row()+1, LEFT say "PLU/SDF CODE  :" get xGetVar[01]
        @ row(), col()+2 say "SIZE:" get xGetVar[04]        
        @ row()+1, LEFT say "STOCK CODE    :" get xGetVar[02]
        @ row()+1, LEFT say "DESCRIPTOR    :" get xGetVar[03]
        @ row()+1, LEFT say "QUANTITY      :" get xGetVar[18]
        @ row()+1, LEFT say "UNIT PRICE    :" get xGetVar[09]
        @ row()+1, LEFT say "TIME PRICE    :" get xGetVar[10]
/*jzo
        @ row()+1, LEFT say "TIME START    :" get xGetVar[16]
        @ row(), col()+2 say "TIME END :" get xGetVar[17]
*/
        @ row()+1, LEFT say "START DATE    :" get xGetVar[16]
        @ row(), col()+2 say "END DATE :" get xGetVar[17]
        
        @ row()+1, LEFT say "DAY OF WEEK   :" get xGetVar[19]
        @ row(), col()+2 say "BASE QUANTITY :" get xGetVar[18]
        @ row()+1, LEFT say "PACKAGE PRICE :" get xGetVar[11]
        @ row()+1, LEFT say "SINGLE PRICE  :" get xGetVar[12]
        @ row(), col()+2 say "ITEM DISC % :" get xGetVar[20]
        @ row()+1, LEFT say "Selective SubTtl. Disc %:" get xGetVar[22]
        @ row()+1, LEFT say "TAX1:" get xGetVar[24]

/*jzo04-07-98
        @ row(), COL()+2 say "TAX2:" get xGetVar[25]
        @ row(), COL()+2 say "TAX3:" get xGetVar[21]
*/

        @ row(), COL() say "TAX2:" get xGetVar[25]
        @ row(), COL() say "TAX3:" get xGetVar[21]
        
        @ row()+1, LEFT say "CHARGE PRICE  :" get xGetVar[14]
*        @ row(), col()+2 say "LEVEL:" get xGetVar[23]
        @ row()+1, LEFT say "STATUS BYTES  :" get xGetVar[26]
      case nFileCode == "02" // Cashier
        @ row(), col() say " CASHIER "
        aSize(xGetVar,05)
        nOffset := 1                                     //Offset Desc 
        xGetVar[01]:= subs(mData,nOffSet,03);nOffSet+=03 //4  Cashier Known Code
        xGetVar[02]:= subs(mData,nOffSet,03);nOffSet+=03 //7  Cashier Secret Code
        xGetVar[03]:= subs(mData,nOffSet,06);nOffSet+=06 //13 Sign-On Time 
        xGetVar[04]:= subs(mData,nOffSet,04);nOffSet+=04 //17 POS Terminal No.
        xGetVar[05]:= subs(mData,nOffSet,02);nOffSet+=02 //19 Reserved (undoc)
        @ row()+1, LEFT say "CASHIER CODE    :" 
        @ row()+1, LEFT say "KNOWN CODE      :" get xGetVar[1]        
        @ row()+1, LEFT say "SECRET CODE     :" get xGetVar[2]        
        @ row()+1, LEFT say "SIGN-ON TIME    :" get xGetVar[3]
        @ row()+1, LEFT say "POS TERMINAL NO.:" get xGetVar[4]        
        @ row()+1, LEFT say "RESERVED        :" get xGetVar[5]        

        @ row()+1, LEFT say "CASHIER KNOWN CODE : " get xGetVar[2]
        @ row()+1, LEFT say "CASHIER SECRET CODE : " get xGetVar[3]
        @ row()+1, LEFT  say "OPERATION CODE:" get xGetVar[1]
      case nFileCode == "DP" // Department
        @ row(), col() say " DEPARTMENT "
        aSize(xGetVar,10)
        nOffset := 1                                     //Offset Desc 
        xGetVar[01]:= subs(mData,nOffSet,04);nOffSet+=04 //5 Department Code 

        xGetVar[03]:= subs(mData,nOffSet,20);nOffSet+=20 //29 Descriptor Code 
        xGetVar[02]:= subs(mData,nOffSet,04);nOffSet+=04 //9 Concessnaire Code 

        xGetVar[04]:= subs(mData,nOffSet,06);nOffSet+=06 //35 Time Start
        xGetVar[05]:= subs(mData,nOffSet,06);nOffSet+=06 //41 Time End
        xGetVar[06]:= subs(mData,nOffSet,02);nOffSet+=02 //43 Tax Rate
        xGetVar[07]:= subs(mData,nOffSet,02);nOffSet+=02 //45 Discount Rate
        xGetVar[08]:= subs(mData,nOffSet,10);nOffSet+=10 //55 HALO
        xGetVar[09]:= subs(mData,nOffSet,10);nOffSet+=10 //65 LALO
        xGetVar[10]:= subs(mData,nOffSet,20);nOffSet+=10 //85 Undocumented        
        @ row()+1, LEFT say "DEPARTMENT CODE    :" get xGetVar[1]        
        @ row()+1, LEFT say "DEPT. DESCRIPTOR   :" get xGetVar[3] 
        @ row()+1, LEFT say "CONCESSIONAIRE CODE:" get xGetVar[2]
                       
/*jzo
        @ row()+1, LEFT say "TIME START         :" get xGetVar[4]
        @ row()+1, LEFT say "TIME END           :" get xGetVar[5]        
*/
        @ row()+1, LEFT say "START DATE         :" get xGetVar[4]
        @ row()+1, LEFT say "END DATE           :" get xGetVar[5]        
        @ row()+1, LEFT say "TAX RATE           :" get xGetVar[6]
        @ row()+1, LEFT say "DISCOUNT RATE      :" get xGetVar[7]        
        @ row()+1, LEFT say "HIGH AMT. LOCK OUT :" get xGetVar[8]
        @ row()+1, LEFT say "LOW AMT. LOCK OUT  :" get xGetVar[9]        
        @ row()+1, LEFT say "RESERVED           :" get xGetVar[10]        
      case nFileCode == "04" // Class Code
        @ row(), col() say " CLASS "      
        aSize(xGetVar,6)    
        nOffSet := 1    
        xGetVar[1] := subs(mData,nOffSet,06);nOffSet+=06 // 07 Class Code
        xGetVar[2] := subs(mData,nOffSet,20);nOffSet+=20 // 27 Descriptor Code
        xGetVar[3] := subs(mData,nOffSet,02);nOffSet+=02 // 29 Dept link
        xGetVar[4] := subs(mData,nOffSet,10);nOffSet+=10 // 39 OTB Budget
        xGetVar[5] := subs(mData,nOffSet,10);nOffSet+=10 // 49 OTB Available
        xGetVar[6] := subs(mData,nOffSet,10);nOffSet+=10 // 49 Reserved
        @ row()+1, LEFT say "CLASS CODE   :" get xGetVar[1]                
        @ row()+1, LEFT say "DESCRIPTOR   :" get xGetVar[2]
        @ row()+1, LEFT say "DEPT. LINKS  :" get xGetVar[3]
        @ row()+1, LEFT say "OTB BUDGET   :" get xGetVar[4]
        @ row()+1, LEFT say "OTB AVAILABLE:" get xGetVar[5]
        @ row()+1, LEFT say "RESERVED     :" get xGetVar[6]
      case nFileCode == "FC" // Foreign Currency
        @ row(), col() say " FOREIGN CURRENCY "              
        aSize(xGetVar,07)
        nOffSet := 1    
        xGetVar[1] := subs(mData,nOffSet,02);nOffSet+=02 // 03 Foreign Code
        xGetVar[2] := subs(mData,nOffSet,03);nOffSet+=03 // 06 Foreign ABBR
        xGetVar[3] := subs(mData,nOffSet,20);nOffSet+=20 // 31 Foreign Desc
        xGetVar[4] := subs(mData,nOffSet,10);nOffSet+=10 // 41 Foreign rate
        xGetVar[5] := subs(mData,nOffSet,10);nOffSet+=10 // 51 Foreign oldrate
        xGetVar[6] := subs(mData,nOffSet,02);nOffSet+=02 // 53 Decimal pos
        xGetVar[7] := subs(mData,nOffSet,10);nOffSet+=10 // 63 RESERVED 
        @ row()+1, LEFT say "           " get xGetVar[3]               
        @ row()+1, LEFT say "FOREIGN CURRENCY CODE :" get xGetVar[1]               
        @ row()+1, LEFT say "FOREIGN CURRENCY ABBR :" get xGetVar[2]               
       * @ row()+1, LEFT say "FOREIGN CURRENCY DESC :" get xGetVar[3]               
        @ row()+1, LEFT say "FOREIGN CURRENCY RATE :" get xGetVar[4]               
        @ row()+1, LEFT say "F. CURRENCY OLD RATE  :" get xGetVar[5]               
        @ row()+1, LEFT say "F. CURRENCY DEC. POS  :" get xGetVar[6]               
        @ row()+1, LEFT say "RESERVED              :" get xGetVar[7]               
   endcase   

   clear gets 
   setColor(cColor)
     
return nil

static function DownLoad()
local nHandle,cData 
local cpath 

cPath := pad(cPath,35)  
/* cPath := GetPath("Down Load FM File",cPath) */

 if NetUse("UM",DB_SHARED,NUM_SECONDS)
    Set index to UM
 endif

 cPath := alltrim(UM->UMAC_PATH)
 
 while !empty(cPath) .and. UM->(!EOF())

    if subs(cPath,len(cPath),1) != "\"
       cPath += "\"
    endif

    cPath += "FM_TRANS.TXT"
    
    if File(cPath) 
        nHandle := fopen(cPath,FO_READWRITE + FO_SHARED)
    else
        nHandle := fcreate(cPath,FC_NORMAL)
    endif 
    
    if ferror() != 0
       if Alert("Error Opening:"+cPath+";DOS ERROR NO: "+alltrim(str(ferror())),{" Retry "," Abort "}) == 1
          cPath := GetPath("Down Load FM File",cPath)
          loop
       else
          exit
       endif      
    endif   

    fSeek(nHandle,0,FS_END) // Move to End of File

    FM->(DbGotop())
    While FM->(!Eof())
/*       if FM->(!Deleted()) */
          cData := padl(alltrim(str(FM->TRANSNO)),8,"0")
          cData += FM->OP_CODE
          cData += FM->FILE_ID
          cData += FM->RECDATA          
          if fwrite(nHandle,cData,BLOCK_LEN) == BLOCK_LEN
             Message("Writing Transaction: "+str(FM->TRANSNO))
             FM->(RecLock())
             FM->(DbDelete())
             FM->(DbUnLock())
          else
             Message("Error Writing Transaction: "+str(FM->TRANSNO))
             fClose(nHandle)
             return nil
          endif
 /*      endif */
       FM->(DbSkip())
    enddo

    fClose(nHandle)
    exit

    UM->(DbSkip())
    cPath := alltrim(UM->UMAC_PATH)

 enddo  

 UM->(DbCloseArea())
  
return nil

Function GetPath(cTitle,cPath)
local wPath,cColor := SetColor("W+/W,GR+/B")
local nfhandle

  if file(".\"+"FM.ID")
     nFHandle:=fopen(".\"+"FM.ID")
     cPath := freadstr(nFHandle,40)
     fclose(nFHandle)
  endif     

    cPath := padr(alltrim(cPath),40) 
   
    wPath := OpenWindow(10,22,14,68,cTitle)
    @ 12, 25 say "Enter Path and Filename"
    @ 13, 25 Get cPath Picture "@KS40"

    setCurSor(SC_NORMAL)
    read
    setCurSor(SC_NONE)

    CloseWindow(wPath)
    SetColor(cColor)

    
// save new path to file
 if lastkey() != K_ESC
   if file("FM.ID")
     ferase("FM.ID")
   endif  
   nFHandle := fcreate("FM.ID",FC_NORMAL)
   fwrite(nFHandle,cPath)
   fclose(nFHandle)          
 else
   BUMMER()
   return nil
 endif
    
return if(LastKey()==K_ESC,"",cPath)


