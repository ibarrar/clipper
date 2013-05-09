#include "grfx_all.ch"
#include "config.ch"

#define ITEM2_LEN     20
#define ITEM3_LEN     3
#define ITEM4_LEN     10
#define ITEM5_LEN     10   

function screen_init()

  gDrawText(24, 36, padc("DESCRIPTION",ITEM2_LEN), TRIPLEX_FONT, 2, 0, MSCALE, MFIX, LEFT_TEXT, ULINE_ON)
  gDrawText(24, 51, padc("QTY"        ,ITEM3_LEN), TRIPLEX_FONT, 2, 0, MSCALE, MFIX, LEFT_TEXT, ULINE_ON)
  gDrawText(24, 71, padc("UNIT PRICE" ,ITEM4_LEN), TRIPLEX_FONT, 2, 0, MSCALE, MFIX, LEFT_TEXT, ULINE_ON)
  gDrawText(24, 94, padc("AMOUNT"     ,ITEM5_LEN), TRIPLEX_FONT, 2, 0, MSCALE, MFIX, LEFT_TEXT, ULINE_ON)        
  
return nil
/*
function screen_update()
local nLines := nvr_nITMitem()
local k,cFlag
local outtext 

  for k := nLines - MAX_ITEM_DISP to nLines
    tran_init(k)
    cFlag := tran_cFlag()    
    if cFlag == "G" .or. cFlag == "V"
    endif
    do case
       case cFlag == "D"
          outtext := trans(tran_nQty(),"@Z 99% ") + "DISCOUNT"
          gDrawText(k-MAX_ITEM_DISP*3,10,outtext,SMALL_FONT,8,CFG_DNORM,MSCALE,LEFT_TEXT)
          outtext := trans(tran_nSale(),"999,999.99")
          gDrawText(k-MAX_ITEM_DISP*3,40,outtext,SMALL_FONT,8,CFG_DNORM,MSCALE,LEFT_TEXT)                                
       otherwise
          // Display Item descriptor
          outtext := subs(tran_cDesc(),1,15)
          gDrawText(k-MAX_ITEM_DISP*3, 3,outtext,SMALL_FONT,8,CFG_DNORM,MSCALE,LEFT_TEXT)          
          // display item qunatity sold            
          outtext := transform(tran_nQty(), "999.99")          
          gDrawText(k-MAX_ITEM_DISP*3,22,outtext,SMALL_FONT,8,CFG_DNORM,MSCALE,LEFT_TEXT)                    
          // display the unit price per item   
          outtext := transform(Tran_nPric(), "999,999.99")
          gDrawText(k-MAX_ITEM_DISP*3,29,outtext,SMALL_FONT,8,CFG_DNORM,MSCALE,LEFT_TEXT)
          // display the total cost per item          
          outtext := transform(Tran_nSale(), "9,999,999.99")
          gDrawText(k-MAX_ITEM_DISP*3,38,outtext,SMALL_FONT,8,CFG_DNORM,MSCALE,LEFT_TEXT)                    
          if cFlag == "E" .or. cFlag == "A"
           gDrawText(k-MAX_ITEM_DISP*3, 2, cFlag,SMALL_FONT,8,CFG_DNORM,MSCALE,RIGHT_TEXT)
          endif 
                      
    endcase   

  next k
   
return nil
*/

function OpenWindow(nTop,nLeft,nBot,nRight,cTitle)
local cWindow,k := 0
local nCenter,status
local cFilename 
local n1,n2,n3,n4

  if empty(cTitle)
     cTitle := ""
  endif   

  if empty(config(POS_RAMDRIVE)) .or. "NO"$config(POS_RAMDRIVE)
    cFileName := "E"
  else
    if "YES" $ config(POS_RAMDRIVE)
       cFileName := "E"
    else   
       cFileName := subs(config(POS_RAMDRIVE),1,1)
    endif
  endif

  cFileName += ":\" + "GRAPHSWP."     

  while k < 1000
   if !file(cFilename+padl(ltrim(str(k)),3,"0"))
       cFilename += padl(ltrim(str(k)),3,"0")
      exit
   endif
   k++
  enddo        

  cWindow := chr(nLeft) + chr(nTop) + cFilename

  status := gScrnSave(nTop,nLeft,nBot,nRight, cFilename, MSCALE)

  if status == -3
     cFileName := "GRAPHSCR.SWP"
  endif
  
  if status == 0
    nCenter := nTop + ((nBot - nTop) / 2)      
    // palabok
    n1 := nCenter + 1
    n2 := nLeft + ((nRight - nLeft) / 2) + 1
    n3 := n1
    n4 := n2
        
    for k := n3 to nBot-1
      gDrawBox(n1, n2, n3, n4, 5,,,1, 7, MSCALE, 10)
      n1-= 1
      n3+= 1
      if n4 < nRight-1
        n2-= 1
        n4+= 1
      endif  
    next
    
    // Draw Button-Style BOX
    gDrawBox(nTop, nLeft, nBot, nRight, BUTTON_UP_LINE,,, ;
	     SOLID_FILL, 7, MSCALE, 10)    

    if !empty(cTitle)
       cTitle := subs(cTitle,1,29)
       // Draw Box Title using TRIPLEX_FONT 3
       gDrawText(nLeft+2, nCenter, cTitle, TRIPLEX_FONT, 3, BLUE, MSCALE, CENTER_TEXT) 
       // Draw Box Title Line
       gDrawLine(nTop+2, nLeft+8, nBot-2, nLeft+8, BUTTON_UP_LINE, NORM_WIDTH, LIGHTGRAY, MSCALE)
    endif                
  else
    ErrorDisp("Open Window fault :"+str(status))
    error_log("Open Window fault :"+str(status))
  endif


return cWindow  

function ClearBox(nTop,nLeft,nBot,nRight)

    // Draw Button-Style BOX
    gDrawBox(nTop, nLeft, nBot, nRight, USERBIT_LINE,,, ;
	     SOLID_FILL, 7, MSCALE, 10)
          
return nil              

function CloseWindow(cWindow)
local nTop,nLeft
local cFilename
local status

   nTop := asc(subs(cWindow,1,1))
   nLeft:= asc(subs(cWindow,2,1))
   cFilename := subs(cWindow,3)

   status := gScrnRest(nLeft,nTop, cFilename, COPY_PUT, 1, MSCALE)
   
   if status != 0
     ErrorDisp("Close Window fault :"+str(status))
     error_log("Close Window fault :"+str(status))
   endif  
         
return nil


* eof ------------>ÿ
