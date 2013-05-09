*** DBFLKUP.PRG ***

#include "Box.ch"
#include "its.ch"
#include "inkey.ch"
#include "Janus.ch"

function DbfLookUp(nTop,nLeft,bBlock,cTitle,cString)
local RetVal:= nil,oCur, wLookup,nLen:= 0
local browse, column, nKey,n:= 0
local r1:= nTop,y1:= nLeft,r2, y2,cColor := if(iscolor(),"W+/G+,W+/GR","N/W,W+/N")
local searchStr := ""
local oCol,cSearch:=cString,nStrLen := len(cString)
local lSet := set(_SET_DELETED,.t.)
*local nRecNo := RecNo()
  
 cTitle := alltrim(cTitle)
 Message(" Choose " +cTitle+ " ...")
 if (Lastrec() == 0)
    Message(" No Available "+cTitle+" Yet... ")
    Tone(300,2)
    Tone(500,2)
    Tone(700,3)
    RetVal := 0
 else
    r2:= r1+1+lastrec()
    if r2 > (maxrow()-1)
      r2 := (maxrow()-1)
    endif      
    y2 := min(y1+len(Eval(bBlock)),maxcol()-1)
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
    browse:headsep := ""
    browse:colSep := ""
    browse:footSep := ""
    browse:colorSpec := cColor //"N/W,N/BG,B/W,B/BG,R/W,B/R"

    column:=TBColumnNew("",bBlock ) 

    browse:addColumn(column)

    browse:freeze := 1

    if !DbSeek(cString)
      DbGotop()
    endif  

    while .t.
      while !browse:stabilize()
         if nextkey() != 0
            Exit
         endif
      enddo

      nKey := inkey(0)

      Do case
         case nKey == K_UP
              browse:up()
         case nKey == K_DOWN
              browse:down()
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
         case nkey == K_ENTER
              RetVal := RecNo()
              Exit
         case ISDIGIT(chr(nkey)) .or. nKey == K_BS .or. nKey == K_LEFT

              while (nKey !=  K_ESC .and. nKey != K_ENTER )

               if nKey == K_BS .or. nKey == K_LEFT
                 searchstr := subs(searchstr,1,len(searchstr)-1)
               else
                 searchstr += upper(chr(nKey))
               endif
               @ r2,y1+1 say if(len(searchstr) == 0,;
                             replicate(chr(205),nLen-2),;
                             "[" + padr(searchstr,nLen-4)+ "]")
                             
               if len(searchstr) == nStrLen
                  nKey  := K_ENTER
                  exit
               endif    
                             
               while .t.         
                nKey := inkey(0)                      
                if ISDIGIT(chr(nKey)) .or. nKEy == K_ESC .or. nKey == K_ENTER .or. nKEy == K_BS
                   exit
                endif
               enddo

              enddo

              searchstr := padl(searchstr,nStrLen,"0")

              if nKey != K_ESC .and. !DBseek(searchstr)
                  HEYTHERE()
                  *KEYBOARD (CHR(K_ENTER))
                  @ r2,y1+1 say if(len(searchstr) == 0,;
                             replicate(chr(205),nLen-2),;
                            "[" + padr(searchstr+" Not Found !",nLen-4)+ "]")
                  DbGoTop()                            
              else
                  @ r2,y1+1 say repl(chr(205),nLen-2)
              endif
              searchstr := ""

              browse:invalidate()
              browse:RefreshAll()
  // No Searching for Now maybe tomorrow
      endcase
    enddo

    RestScreen(r1,y1,r2+1,y2+1,wLookUp)
    SetCursor(oCur)
    SetColor(oCol)
    set(_SET_DELETED,lSet)
  endif  
*  DbGoto(nRecNo)
return RetVal    
