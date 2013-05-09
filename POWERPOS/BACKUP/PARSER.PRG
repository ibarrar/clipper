#include "config.ch"
#include "itemtran.ch"
#include "fileio.ch"

#define ITEMTRAN_NAME  (GetLocal_Path()+"ITEM" + padl(right(alltrim(config(POS_TERM_NUM)),4),4,"0")+".LOC")

static itemOffset := -1

function parsetran( nVal )
local cRetBuff 
local nHandle
local lRetVal := .F.
local file_size
local nOffset
local nTran_No := 0

 //  first open the file for parsing....
 nHandle :=  fopen(ITEMTRAN_NAME,FO_READ)
 
 if ( ferror() == 0 )
    // now seek for the nVal transaction no.
    file_size := fseek(nHandle,0,FS_END)
    // move to the last transno and read
    itemOffset := file_size - ITEM_SIZE_TOT 
    nOffset := iTemOffset + ITEM_TRNO_OFF - 1
    if fseek(nHandle, nOffset, FS_SET ) != nOffset
       fclose( nHandle )
       return .F.
    endif   
    cRetBuff := space( ITEM_TRNO_LEN )
    fread(nHandle, @cRetBuff, ITEM_TRNO_LEN )
    nTran_No :=  val(cRetBuff)
    if nVal <= nTran_No  
       while nVal != nTran_No .and. nTran_No > 0  
         iTemOffset -= (nTran_No - nVal) * ITEM_SIZE_TOT
         // try its data
         nOffset := iTemOffset + ITEM_TRNO_OFF -1
         if fseek(nHandle, nOffset, FS_SET ) != nOffset
            exit
         endif   
         cRetBuff := space( ITEM_TRNO_LEN )
         fread(nHandle, @cRetBuff, ITEM_TRNO_LEN )
         nTran_No :=  val(cRetBuff)         
       enddo
    endif     
    while nVal == nTran_No
      // move backwards or go to the first item with this trans no
      nOffset := iTemOffset - ITEM_SIZE_TOT  + ITEM_TRNO_OFF -1
      fseek(nHandle, nOffset, FS_SET )
      cRetBuff := space( ITEM_TRNO_LEN )
      fread(nHandle, @cRetBuff, ITEM_TRNO_LEN )
      nTran_No := val(cRetBuff)
      if nVal == nTran_No
         itemOffset -= ITEM_SIZE_TOT
      else
         exit 
      endif 
      lRetVal := .T.
    enddo

    if lRetVal
      MsgAreaDisp("Transaction "+padl(nVal,8,"0")+" Found !!!")
      if fseek(nHandle,iTemOffset,FS_SET) != iTemOffset
         lRetVal := .F.
      else
         cRetBuff := space(ITEM_POSN_LEN+ITEM_DATE_LEN)
         fread(nHandle, @cRetBuff, ITEM_POSN_LEN+ITEM_DATE_LEN )
         if ferror() != 0
           lRetVal := .F.
         else
           if date() != ctod(subs(cRetBuff,ITEM_DATE_OFF,ITEM_TIME_LEN))
              lRetVal := .F.
              ErrorDisp("Not able to process Previous Transaction Date")
           endif     
         endif           
      endif                     
    else
      ErrorDisp("Transaction "+padl(nVal,8,"0")+" Not Found !")
    endif  
    fclose( nHandle )
 endif 
 
return  lRetVal

function getnext(nVal)
local cRetBuff := ""
local cTempBuff := space( ITEM_TRNO_LEN )
local nHandle := fopen(ITEMTRAN_NAME,FO_READ)

    if ferror() == 0
       if fseek(nHandle,iTemOffset,FS_SET) == iTemOffset
          cRetBuff := space( ITEM_SIZE_TOT )
          fread(nHandle, @cRetBuff, ITEM_SIZE_TOT )
          cTempBuff := subs(cRetBuff,ITEM_TRNO_OFF,ITEM_TRNO_LEN)
          if nVal == val(cTempBuff)
             iTemOffset += ITEM_SIZE_TOT
          else
             iTemOffset := -1
             cRetBuff := ""
          endif   
       endif

    endif   

    fClose( nHandle )    

return cRetBuff

