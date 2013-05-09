#include "grfx_all.ch"
#include "config.ch"
#include "keymap.ch"
#include "spec_key.ch"
#include "message.ch"

#define MAX_ROW    12

function  aLookUp(nRow,nCol,aArray_,cTitle)
local nElements := len(aArray_)
local nDept := 0
local nWidth := 0
local cKey := 0
local iCenter,nTop,iBoxAdj
local nX1,nY1,nX2,nY2
local nElemTop := 1,m := 0
local nCurrElem := 0,yRow := 0
local nCurrRow := 0
local lRefresh := .F.
local cFilename 

  if empty(config(POS_RAMDRIVE)) .or. "NO"$config(POS_RAMDRIVE)
    cFileName := ""
  else
    if "YES" $ config(POS_RAMDRIVE)
       cFileName := "E"
    else   
       cFileName := subs(config(POS_RAMDRIVE),1,1)
    endif
  endif

   cFileName += ":\" + "GRAPHSWP."  

   while m < 1000
    if !file(cFilename+padl(ltrim(str(m)),3,"0"))
        cFilename += padl(ltrim(str(m)),3,"0")
       exit
    endif
    m++
   enddo          

   // check if the array exceed the max. row
   yRow := iif(nElements > MAX_ROW, MAX_ROW, nElements)
   if nElements > MAX_ROW
     nDept := (MAX_ROW * 4)
   else
     nDept := (nElements*4)
   endif      

   gDrawText(0,0, "",TRIPLEX_FONT, 2, 7, MPIXEL, LEFT_TEXT)   
   aeval( aArray_, { |s| nWidth := max(gGrfxConfg(CHAR_WIDTH_CFG,s), nWidth) } )   
   nWidth += (2*gGrfxConfg(CHAR_WIDTH_CFG,"W"))    

   nX1 := ROUND(nCol * SCALE_X / SCR_SCALE, 0)      
   nY1 := ROUND(nRow * SCALE_Y / SCR_SCALE, 0)
   nX2 := nX1 + nWidth
   nY2 := ROUND((nRow+nDept) * SCALE_Y / SCR_SCALE, 0)
   
   // Calculate for Box border adjustments
   iBoxADJ := ROUND( SCALE_Y * ( SCR_SCALE / 6) / SCALE_X, 0)

   iCenter := nX1 + ((nX2 - nX1) / 2)   

   if !empty(cTitle)

      gScrnSave(nCol-2,nRow-3, nCol+(nWidth/6)+2, nRow+nDept+10, DEF_SCR_SWAP, MSCALE) 

      // Draw Button-Style BOX
      gDrawBox(nX1-iBoxAdj, nY1-iBoxAdj, nX2+iBoxAdj, nY2+34+iBoxAdj,BUTTON_UP_LINE,,, SOLID_FILL, 7, MPIXEL, 10)
      
      // Draw Box Title using TRIPLEX_FONT 3
      gDrawText(nY1-3, iCenter, cTitle, ;
                TRIPLEX_FONT, 2, 15, MPIXEL, CENTER_TEXT)

      nY1 += 21 + iBoxAdj
      nY2 += 21 + iBoxAdj

      // Draw Box Title Line
      gDrawLine(nX1-1, nY1-7, nX2+1, nY1-7, ;
                BUTTON_UP_LINE, THICK_WIDTH, 7, MPIXEL)                    
                   
   else
      gScrnSave(nCol-2,nRow-3, nCol+(nWidth/6)+2, nRow+nDept+3, DEF_SCR_SWAP, MSCALE)                
      // Draw Button-Style BOX
      gDrawBox(nX1-iBoxAdj, nY1-iBoxAdj, nX2+iBoxAdj, nY2+iBoxAdj,BUTTON_UP_LINE,,, SOLID_FILL, 0, MPIXEL, 10)         
   endif      
      
   for m := 1 to yRow
      nTop   := nY1 + ROUND((m-1)*4 *  SCALE_Y / SCR_SCALE, 0) 
      gDrawBox(nX1, nTop, nX2, nTop+20,0,,,SOLID_FILL, 0,MPIXEL ,10)
      gDrawText(nTop,iCenter, aArray_[m+nElemTop-1],TRIPLEX_FONT, 2, 7, MPIXEL, CENTER_TEXT)
   next m
      
   nCurrElem := 1
   nCurrRow  := 1
 
   while cKey != ENTER      
      if lRefresh
        for m := 1 to yRow
          nTop   := nY1 + ROUND((m-1)*4 *  SCALE_Y / SCR_SCALE, 0) 
          gDrawBox(nX1, nTop, nX2, nTop+20,0,,,SOLID_FILL, 0,MPIXEL ,10)
          gDrawText(nTop,iCenter, aArray_[m+nElemTop-1],TRIPLEX_FONT, 2, 7, MPIXEL, CENTER_TEXT)
        next m
        lRefresh := .F.
      endif  
      nTop   := nY1 + ROUND((nCurrRow-1)*4 *  SCALE_Y / SCR_SCALE, 0) 
      gDrawBox(nX1, nTop, nX2, nTop+20,5,,,SOLID_FILL, 13,MPIXEL ,10)
      gDrawText(nTop,iCenter, aArray_[nCurrElem],TRIPLEX_FONT, 2, 15, MPIXEL, CENTER_TEXT)
      cKey := input()
      gDrawBox(nX1, nTop, nX2, nTop+20,0,,,SOLID_FILL,  0,MPIXEL ,10)
      gDrawText(nTop,iCenter, aArray_[nCurrElem],TRIPLEX_FONT, 2, 7, MPIXEL, CENTER_TEXT)
      
      do case
         case IS_KEYCHANGE(cKey) 
            MsgAreaDisp(MSG_CLEAR) // clear display area
            nCurrElem := 0
            exit
         case cKey == DOWN
           if nCurrElem < nElements
             nCurrElem++
             if nCurrRow < yRow
                nCurrRow++
             else
                nElemTop++
                nCurrRow := yRow
                lRefresh := .T.
             endif     
           endif  
         case cKey == UP
           if nCurrElem > 1
              nCurrElem--
              if nCurrRow > 1
                 nCurrRow--
              else
                 if nElemTop > 1
                   nElemTop--
                   nCurrRow := 1
                   lRefresh := .T.
                 endif
              endif
           endif               
         case cKey == CLR
            nCurrElem := 0 
            exit   
      endcase
      
   enddo          

  gScrnRest(nCol-2,nRow-3, DEF_SCR_SWAP, COPY_PUT, 1, MSCALE)   
  
return nCurrElem
