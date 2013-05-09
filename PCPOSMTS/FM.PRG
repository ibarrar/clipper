#include "Its.ch"
#include "janus.ch"
#include "Box.ch"
#include "setcurs.ch"
#include "inkey.ch"
#include "Set.ch"
#include "FileIO.ch"

#define BLOCK_LEN  256

memvar Getlist

function Load()
local nHandle,cData 
local cpath, nctr := 0 

  if NetUse("ITEM.DBF",DB_SHARED,NUM_SECONDS)
     Set Index to I_001
  endif
  if NetUse("CL",DB_SHARED,NUM_SECONDS)
     Set Index to CL_001
  endif

cPath := pad(cPath,35)  
cPath := GetPath("Down Load FM File",cPath)

 while !empty(cPath) 
    if File(cPath) 
        nHandle := fopen(cPath,FO_READWRITE)
    else
        nHandle := fcreate(cPath,FC_NORMAL)
    endif 
    
    if nHandle == -1
       if Alert("Error Opening:"+cPath+";DOS ERROR NO: "+alltrim(str(ferror())),{" Retry "," Abort "}) == 1
          cPath := GetPath("Down Load FM File",cPath)
          loop
       else
          exit
       endif      
    endif   

    fSeek(nHandle,0,FS_END) // Move to End of File
    nctr := 0
    ITEM->(DbGotop())
    do While ITEM->(!Eof())
       if ITEM->(!Deleted())
          nctr += 1
          cData := padl(alltrim(str(nctr)),8,"0")
          cData += "01"
          cData += "PL"
          cData += ITEM->I_001      // PLU item Code 
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
       cData += padl(alltrim(strtran(str(ITEM->I_003),".","")),10,"0") // selling price
       cData += repl("0",10) // price level 1
       cData += repl("0",10) // price level 2
       cData += repl("0",10) // price level 3
       cData += repl("0",10) // price level 4
       cData += repl("0",10) // price level 5
       cData += padl(alltrim(strtran(str(ITEM->I_007),".","")),10,"0") // unit cost
       cData += repl("0",4)  // time start
       cData += repl("0",4)  // time end
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
      
        padr(cData,256,"0")
          
          if fwrite(nHandle,cData,BLOCK_LEN) == BLOCK_LEN
             Message("Writing Transaction: "+str(nctr))
          else
             Message("Error Writing Transaction: "+str(nCtr))
             fClose(nHandle)
             return nil
          endif
       endif
       ITEM->(DbSkip())
    enddo

    fClose(nHandle)
    exit

 enddo  
 
return nil

static Function GetPath(cTitle,cPath)
local wPath,cColor := SetColor("W+/W,GR+/B")
local nfhandle

if file(".\"+"rtt.ID")
  nFHandle:=fopen(".\"+"rtt.ID")
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
   if file("rtt.ID")
     ferase("rtt.ID")
   endif  
   nFHandle := fcreate("rtt.ID",FC_NORMAL)
   fwrite(nFHandle,cPath)
   fclose(nFHandle)          
 else
   BUMMER()
   return nil
 endif
    
return if(LastKey()==K_ESC,"",cPath)



      
      