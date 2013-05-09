#include "spec_key.ch"
#include "grfx_all.ch"
#include "message.ch"

#define BACK_COLOR   LIGHTGRAY
#define HIBK_COLOR       WHITE
#define HIFR_COLOR        BLUE
#define GETB_COLOR   LIGHTGRAY
#define GETF_COLOR       BLACK
#define SAY_COLOR        BLACK
#define HORIZONTAL_FIX       3
#define DEF_COL1            50
#define DEF_COL2            73

memvar getlist 

// row, col, variable, len

#define SAY_ROW   1
#define SAY_COL   2
#define SAY_VAR   3
#define GET_ROW   4
#define GET_COL   5
#define GET_VAR   6
#define GET_PIC   7
#define GET_MSG   8
#define GET_PRE   9
#define GET_PST  10

function readmodal()
local nitems := len(getlist)
local k,curritem
local x1,x2,y1,y2,ckey
local nWidth
local cEditBuff := "",cDispBuff,cData:=""
local nEditLen  := 0
local curs_pntr 
local cType,lInsert := .F.
local l1st_number := .t.
local l1st_Pass := .t.
  
  for k := 1 to nItems
       /* initially display all say if it exist */
       if len(getlist[k,SAY_VAR]) > 0
          getlist[k,GET_COL] := getlist[k,SAY_COL] + (len(getlist[k,SAY_VAR]) * 1.4) 
          gDrawText(getlist[k,SAY_ROW],getlist[k,SAY_COL],getlist[k,SAY_VAR], SMALL_FONT, 6,SAY_COLOR, MSCALE, LEFT_TEXT)
       endif    
       x1 := getlist[k,GET_COL]
       if valtype(Eval(getlist[k,GET_VAR])) == "N"
        if empty(getlist[k,GET_PIC])
           getlist[k,GET_PIC] := "9999999999"            
        endif
        cEditBuff := trans(Eval(getlist[k,GET_VAR]),getlist[k,GET_PIC])
       else
        cEditBuff := Eval(getlist[k,GET_VAR])
       endif 
       x2 := x1 + (1.45 * len(cEditBuff)) 
       y1 := getlist[k,GET_ROW] 
       y2 := y1 + HORIZONTAL_FIX 
       gDrawBox(x1,y1,x2,y2,0,0,GETB_COLOR,SOLID_FILL,GETB_COLOR,MSCALE,0)
       gDrawText(getlist[k,GET_ROW],getlist[k,GET_COL],cEditBuff, SMALL_FONT, 6,GETF_COLOR, MSCALE, LEFT_TEXT)
  next   
  
  curritem := 1
  while .t.
     if valtype(getlist[curritem,GET_PRE]) == "B" .and. !Eval(getlist[curritem,GET_PRE]) 
         curritem++
         if curritem > nItems 
            exit
         else
            loop   
         endif   
     endif    
     cType := valtype(Eval(getlist[curritem,GET_VAR]))     
     x1 := getlist[curritem,GET_COL]
     if cType == "N"
       cEditBuff := trans(Eval(getlist[curritem,GET_VAR]),getlist[curritem,GET_PIC])
     else
       cEditBuff := Eval(getlist[curritem,GET_VAR])
     endif 
     nEditLen  := len(cEditBuff)
     x2 := x1 + (1.45 * nEditLen) 
     y1 := getlist[curritem,GET_ROW] 
     y2 := y1 + HORIZONTAL_FIX 
     
     gDrawBox(x1,y1,x2,y2,0,0,HIBK_COLOR,SOLID_FILL,HIBK_COLOR,MSCALE,0)
     gDrawText(getlist[curritem,GET_ROW],getlist[curritem,GET_COL],cEditBuff, SMALL_FONT, 6,HIFR_COLOR, MSCALE, LEFT_TEXT)
     MsgAreaDisp(getlist[curritem,GET_MSG])
     DISPTEXTXY(0,0,0,0,1,1,pad(getlist[curritem,GET_MSG],20))
     DISPTEXTXY(0,0,0,0,2,1,MSG_CLEAR)
     cKey := input()
     gDrawBox(x1,y1,x2,y2,0,0,GETB_COLOR,SOLID_FILL,GETB_COLOR,MSCALE,0)
     gDrawText(getlist[curritem,GET_ROW],getlist[curritem,GET_COL],cEditBuff, SMALL_FONT, 6, GETF_COLOR, MSCALE, LEFT_TEXT)
     
     do case 
        case cKey == CLR            
           if empty(Eval(getlist[curritem,GET_VAR]))
             exit
           endif             
        case cKey == UP     // .or. cKey == LEFT
           curritem := if(curritem > 1,curritem-1,curritem)
        case cKey == DOWN   // .or. cKey == RIGHT
           curritem := if(curritem < nItems,curritem+1,curritem)
        case cKey == ENTER .or. cKey == CLR .or. len(is_number(@ckey)) > 0 .or. len(is_alpha(@ckey)) > 0 .or. len(cDeptCode(cKey)) > 0 
           curs_pntr := 1
           l1st_number := .T.
           l1st_Pass := .T.
           while .t.
              gDrawBox(x1,y1,x2,y2,0,0,HIBK_COLOR,SOLID_FILL,HIBK_COLOR,MSCALE,0)
              gDrawText(getlist[curritem,GET_ROW],getlist[curritem,GET_COL],cEditBuff, SMALL_FONT, 6,HIFR_COLOR, MSCALE, LEFT_TEXT)                 
              gDrawText(getlist[curritem,GET_ROW],getlist[curritem,GET_COL],subs(cEditBuff,1,curs_pntr-1)+if(lInsert,chr(220),"_"), SMALL_FONT, 6,HIFR_COLOR, MSCALE, LEFT_TEXT)
              DISPTEXTXY(0,0,0,0,2,1,pad(pad(alltrim(cEditBuff)+"_",nEditLen)+"<",20))

              if !l1st_Pass 
                cKey := input()                               
              endif                
              l1st_Pass := .F.                 
              do case
                 case cKey == ENTER .or. cKey == UP .or. cKey == DOWN
                    if cType == "N"     

                      // evaluate for decimal position
                      cEditBuff := alltrim(cEditBuff)
                      if len(cEditBuff) > 0
                        if !("." $ cEditBuff )
                           if len(cEditBuff) < 3   
                               cEditBuff := padl(cEditBuff,3,"0")
                           endif
                           cEditBuff := stuff(cEditBuff,len(cEditBuff)-1,0,".")
                        endif                                  
                      endif
                      
                      Eval(getlist[curritem,GET_VAR],val(cEditBuff))
                      cEditBuff := trans(Eval(getlist[curritem,GET_VAR]),getlist[curritem,GET_PIC])
                    else  
                      Eval(getlist[curritem,GET_VAR],cEditBuff)
                    endif   
                    gDrawBox(x1,y1,x2,y2,0,0,GETB_COLOR,SOLID_FILL,GETB_COLOR,MSCALE,0)
                    gDrawText(getlist[curritem,GET_ROW],getlist[curritem,GET_COL],cEditBuff, SMALL_FONT, 6,GETF_COLOR, MSCALE, LEFT_TEXT)
                                        
                    if valtype(getlist[curritem,GET_PST]) == "B"
                      if Eval(getlist[curritem,GET_PST]) 
                         if cKey == UP 
                            curritem := if(curritem > 1,curritem-1,curritem)
                         else
                           curritem++
                         endif  
                      endif   
                    else
                      if cKey == UP 
                        curritem := if(curritem > 1,curritem-1,curritem)
                      else
                        curritem++
                      endif                        
                    endif
                    exit
                 case len(is_number(@cKey)) > 0 .or. len(is_alpha(@cKey)) > 0 .or. len(cDeptCode(cKey)) > 0 .or. len(cDeptCode(cKey)) > 0 
                      if l1st_number .and. cType == "N"
                         cEditBuff := space(nEditLen)
                         l1st_number := .F.
                      endif   
                      if len(cData := is_number(@cKey)) > 0
                      elseif len(cData := is_alpha(@cKey)) > 0
                      elseif len(cData := cDeptCode(cKey)) > 0
                      else
                         cData := ""
                      endif                                      
                      if lInsert
                         cEditBuff := stuff(cEditBuff,curs_pntr,0,cData)
                      else                    
                         cEditBuff := stuff(cEditBuff,curs_pntr,len(cData),cData)
                      endif   
                      cEditBuff := pad(cEditBuff,nEditLen)                      
                      curs_pntr += len(cData)
                      if curs_pntr > nEditLen
                         curs_pntr := nEditLen
                      endif
                 case cKey == BACK_SPACE
                    if curs_pntr > 1
                       curs_pntr--
                       cEditBuff := stuff(cEditBuff,curs_pntr,1,"")
                       cEditBuff := pad(cEditBuff,nEditLen)
                    endif          
                 case cKey == CLR
                    if empty(cEditBuff)
                      exit
                    endif  
                    cEditBuff := space(nEditLen)       
                    curs_pntr := 1
                 case cKey == ESC_DOS                  
                    exit   
              endcase      
           enddo
      endcase                        
      if curritem > nItems .or. cKey == CLR
         exit
      endif   
  enddo

  getlist := {}
  DISPTEXTXY(0,0,0,0,1,1,MSG_CLEAR)
  DISPTEXTXY(0,0,0,0,2,1,MSG_CLEAR)

return nil


function SayString(row,col,msg)
local x1 := col
local x2 := col + (1.45 * len(msg)) 
local y1 := row 
local y2 := y1 + HORIZONTAL_FIX 

  gDrawBox(x1,y1,x2,y2,0,0,GETB_COLOR,SOLID_FILL,GETB_COLOR,MSCALE,0)
  gDrawText(row,col,msg, SMALL_FONT, 6,GETF_COLOR, MSCALE, LEFT_TEXT)

return nil
