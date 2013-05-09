
**************************ADDED BY JZO 04-07-98****************************

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

#define FC_PATH    "S:\"
#define FC_FILE    "FOREX.TXT"
#define BLOCK_LEN  22

#ifdef COLOR_STAT
#define BAR "Arrow Keys-Navigate  ENTER-View  F2-DownLoad"
#else
#define BAR "Arrow Keys-Navigate  ENTER-View  F2-DownLoad"
#endif

memvar Getlist

function forex_file()
local bBlock,mStart:=""
local n := 99
local lSet := set(_SET_DELETED,.t.)
local oCur, wLookup, browse, column, nKey
local oCol,cColor := if(Iscolor(),"W+/B,W+/GR","N+/W,W+/N")
local nup := 0, ndown := 0

  if NetUse("FC_HIST",DB_SHARED,NUM_SECONDS)
     Set Index to FC_HIST
  endif


  if (LastRec() > 0)  
  
    Message("Please Wait...")
//    bBlock := { || " "+padl(alltrim(str(FM->TRANSNO)),8,"0")+" "+FM->OP_CODE+" "+FM->FILE_ID+" "+dtoc(FM->POSTDATE)+" " }
    bBlock := { || " "+FC_HIST->FILE_ID+" "+FC_HIST->OP_CODE+" "+dtoc(FC_HIST->DATE)+" "}
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
      GoGet(FC_HIST->FILE_ID)      
      Do case
         case nKey == K_UP
              browse:up()
              nDown := 0
              nup += 1
              if nup == 1
               FC_HIST->(DbSkip(-1))
               GoGet(FC_HIST->FILE_ID)      
              endif 
         case nKey == K_DOWN
              browse:down()
              nup := 0
              ndown += 1
              if ndown == 1
               FC_HIST->(DbSkip())
               GoGet(FC_HIST->FILE_ID)      
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
              GoGet(FC_HIST->FILE_ID)
*              FM->(DbSkip())
         case nKey == K_F2
              DownLoad_FC()
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
    Message(" No Available FC_HIST Record Yet... ")
    Tone(300,2)
    Tone(500,2)
    Tone(700,3)               
  endif

  FC_HIST->(DbCLoseArea())

return nil


static function GoGet(nFileCode)
local xGetVar[1]
local cColor :=SetColor(if(IsColor(),"N/W,GR+/B","N/W,W/N"))
local nOffSet
/*
   Scroll(R1+1,C2+2,R2-1,maxCol()-3)
*/
   Scroll(R1+1,C2+2,R2-1,maxCol()-2)
   @ R1+1,C2+2 say "FILE ID : "+ "FC" 
        @ row(), col() say " FOREIGN CURRENCY "              
        aSize(xGetVar,06)
        nOffSet := 1    
        xGetVar[1] := FC_HIST->FCH_CODE // 03 Foreign Code
        xGetVar[2] := FC_HIST->FCH_ABBR // 06 Foreign ABBR
        xGetVar[3] := FC_HIST->FCH_DESC // 26 Foreign Desc
        xGetVar[4] := FC_HIST->NEWRATE  // 41 Foreign rate
        xGetVar[5] := FC_HIST->OLDRATE // 51 Foreign oldrate
        xGetVar[6] := FC_HIST->FCH_DECPOS // 53 Decimal pos
       * xGetVar[7] := subs(mData,nOffSet,10);nOffSet+=10 // 63 RESERVED 
//jzo        @ row()+1, LEFT say "           " get xGetVar[3]
        @ row()+1, LEFT say "                       " get xGetVar[3]
        @ row()+1, LEFT say "FOREIGN CURRENCY CODE :" get xGetVar[1]               
        @ row()+1, LEFT say "FOREIGN CURRENCY ABBR :" get xGetVar[2]               

      * @ row()+1, LEFT say "FOREIGN CURRENCY DESC :" get xGetVar[3]               

        @ row()+1, LEFT say "FOREIGN CURRENCY RATE :" get xGetVar[4]               
        @ row()+1, LEFT say "F. CURRENCY OLD RATE  :" get xGetVar[5]               
        @ row()+1, LEFT say "F. CURRENCY DEC. POS  :" get xGetVar[6]               

        @ row()+1, LEFT say "EXCHANGE RATE DATE    :" get FC_HIST->DATE
     *  @ row()+1, LEFT say "RESERVED              :" get xGetVar[7]               
   clear gets 
   setColor(cColor)
     
return nil

static function DownLoad_FC()
local nHandle,cData 
local cpath 

cPath := pad(cPath,35)  
cPath := GetPath("Down Load FC File",cPath)

 while !empty(cPath) 
    if File(cPath) 
/*jzo04-07-98
        nHandle := fopen(cPath,FO_READWRITE)
*/      ferase(cPath)
        nHandle := fcreate(cPath,FC_NORMAL)
    else
        nHandle := fcreate(cPath,FC_NORMAL)
    endif 
    
    if nHandle == -1
       if Alert("Error Opening:"+cPath+";DOS ERROR NO: "+alltrim(str(ferror())),{" Retry "," Abort "}) == 1
          cPath := GetPath("Down Load FC File",cPath)
          loop
       else
          exit
       endif      
    endif   
/*jzo04-07-98
    fSeek(nHandle,0,FS_END) // Move to End of File
*/


    FC_HIST->(DbGotop())
    While FC_HIST->(!Eof())
       if FC_HIST->(!Deleted())
    fSeek(nHandle,0,FS_SET) // Move to Start of File       
          cData := padl(alltrim(FC_HIST->FCH_CODE),4,"0")
          cData += padl(alltrim(strtran(str(round(FC_HIST->OLDRATE,2)),".","")),5,"0")
          cData += padl(alltrim(strtran(str(round(FC_HIST->NEWRATE,2)),".","")),5,"0")
          cData += dtoc(FC_HIST->DATE)+CHR(10)

          if fwrite(nHandle,cData,BLOCK_LEN) == BLOCK_LEN
             Message("Writing Transaction... ")
             FC_HIST->(RecLock())
             FC_HIST->(DbDelete())
             FC_HIST->(DbUnLock())
          else
             Message("Error Writing Transaction... ")
             fClose(nHandle)
             return nil
          endif
       endif
       FC_HIST->(DbSkip())
    enddo

    fClose(nHandle)
    exit

 enddo  
 
return nil

static Function GetPath(cTitle,cPath)
local wPath,cColor := SetColor("W+/W,GR+/B")
local nfhandle

if file(".\"+"FC.ID")
  nFHandle:=fopen(".\"+"FC.ID")
  cPath := freadstr(nFHandle,35)
  fclose(nFHandle)
endif     

cPath := padr(alltrim(cPath),35) 
   
    wPath := OpenWindow(10,22,14,58,cTitle)
    @ 12, 25 say "Enter Path and Filename"
    @ 13, 25 Get cPath Picture "@KS30"

    setCurSor(SC_NORMAL)
    read
    setCurSor(SC_NONE)

    CloseWindow(wPath)
    SetColor(cColor)

    
// save new path to file
 if lastkey() != K_ESC
   if file("FC.ID")
     ferase("FC.ID")
   endif  
   nFHandle := fcreate("FC.ID",FC_NORMAL)
   fwrite(nFHandle,cPath)
   fclose(nFHandle)          
 else
   BUMMER()
   return nil
 endif
    
return if(LastKey()==K_ESC,"",cPath)
