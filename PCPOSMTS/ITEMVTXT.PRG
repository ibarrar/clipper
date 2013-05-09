#include "itm_move.ch"
#include "directry.ch"
#include "janus.ch"
#include "fileio.ch"
#include "inkey.ch"
#include "setcurs.ch"

#define DATA_PATH  chr(65+curdrv())+":\"+curdir()+"\MTSDATA\"   
#define ROOT_PATH  chr(65+curdrv())+":\"+curdir()+"\"   
#define BCKUP_PATH chr(65+curdrv())+":\"+curdir()+"\BACKUP\"   

memvar getlist
function ItemV_imp()
local cpath := space(35), i := 0, cFileName, aTxtDir := {}, nFHandle, cStr:=space(116), nFH, nfh2
local aflag:={  "R", "D", "V","C","G","J" }
local aChargeFlags := {"Z", "0", "1", "2", "3", "4", "5", "6", "7", "8", "9" }
local wChange
local cDate:=dtos(date())
local nPrev_PLSale := ""
local cPrev_PLCode := ""

if NetUse("UM",DB_SHARED,NUM_SECONDS)
    Set Index to UM
endif

if netuse("PLU", DB_SHARED, NUM_SECONDS)
    set index to PLU,DATEPLU,ITEMCNT,AMTCNT
endif

if netuse("CHARGE", DB_SHARED, NUM_SECONDS)
    set index to CHARGE
endif

while UM->(!Eof())

  if UM->(Deleted())
     UM->(DbSkip())
	loop
  endif	
 
  cpath := ALLTRIM(UM->UMAC_PATH)
  if substr(cpath,len(cpath),1) != "\"
    cpath += "\"
  endif  
   
  aTxtDir := directory(cPath+"ITEM*.TXT")

  if len(aTxtDir) == 0
    Message("No ITEM TEXT transaction file on Machine "+UM->MACHINENO)
  endif

  for  i:= 1 to len(aTxtDir)
     if file(cPath+ aTxtDir[i][F_NAME])
       COPY FILE (cPath)+(aTxtDir[i][F_NAME]) TO (BCKUP_PATH)+(subs(aTxtDir[i][F_NAME],1,4)+subs(cDate,5,4)+".J"+ alltrim(str(val(subs(aTxtDir[i][F_NAME],5,4)))) )
       RENAME (cPath)+aTxtDir[i][F_NAME] to (cPath)+substr(aTxtDir[i][F_NAME],1,8)
       COPY file (cPath)+substr(aTxtDir[i][F_NAME],1,8)  to (DATA_PATH)+ (aTxtDir[i][F_NAME]) 
       FERASE((cPath)+substr(aTxtDir[i][F_NAME],1,8))
     endif  
  next i

for i := 1 to len(aTxtDir)

  cFileName := aTxtDir[i][F_NAME]
  nFHandle := fopen((DATA_PATH)+ cFileName,FO_READ)

  if nFHandle == -1
    Alert("Error opening file : '"+cFileName+"'", {"Return"})
    loop 
  endif
  Message('Updating files "PLU.DBF " please wait...')

  while !feof(nFhandle)
     cStr := freadstr(nFHandle,128) 
	if aScan(aChargeFlags, TRANS_FLAG) != 0
     	if val(PAYMTYPE) != 0
			CHARGE->(dbAppend())
    			CHARGE->(RecLock())
    
    			CHARGE->POS_NO     := POSNO        
    			CHARGE->DATE       := CTOD(DATES)
    			CHARGE->TIME       := TIMES        
    			CHARGE->CASH_CODE  := CASH_CDE 
    			CHARGE->SLS_AMOUNT := cNcon(CUSTSALE) * 0.01
    			CHARGE->PAY_TYPE   := PAYMTYPE  
    			CHARGE->ACCT_NO    := CUSTCRG1
    			CHARGE->OP_FLAG    := TRANS_FLAG
    			CHARGE->(dbUnLock())    
   		endif 	
   	elseif aScan(aFlag, TRANS_FLAG) != 0 

		if (!PLU->(DbSeek(PLUCODE+dtos(ctod(DATES)))))
    		  PLU->(dbAppend())
		  PLU->DATE := ctod(DATES)
		  PLU->CODE := PLUCODE
		  PLU->ITEM_CODE := ITEMCODE
		endif  		
    		PLU->(RecLock())

		if TRANS_FLAG == "D"
		     if cPrev_PLCode == PLUCODE
			   PLU->DISC_QTY += 1
			   PLU->DISC_AMT += nPrev_PLSale * val(ITEMCNTR) * 0.01
			else
			  PLU->DISC_QTY += 1
			  PLU->DISC_AMT += cNcon(ITEMSALE) * 0.01
			endif  
		elseif (TRANS_FLAG == "J")
			if PREVFLAG == "D"
			  if cPrev_PLCode == PLUCODE
			     PLU->DISC_QTY -= 1
			     PLU->DISC_AMT -= (nPrev_PLSale * val(ITEMCNTR) * 0.01)
			  else
			     PLU->DISC_QTY -= 1
			     PLU->DISC_AMT -= (cNcon(ITEMSALE) * 0.01)
			  endif  
			endif 
        	elseif (TRANS_FLAG == "R" .or. TRANS_FLAG == "E" .or. TRANS_FLAG == "G" .or. TRANS_FLAG == "V" ) 
		     if PREVFLAG == "N" .and. TRANS_FLAG == "R"
			   PLU->RTN_QTY +=  val(ITEMCNTR)
			   PLU->RTN_AMT +=  cNcon(ITEMSALE) * 0.01
			elseif PREVFLAG == "D"
			  if TRANS_FLAG == "R"
  			    PLU->RTN_QTY -=  1 // val(ITEMCNTR)
			    PLU->RTN_AMT -=  cNcon(ITEMSALE) * 0.01
			  endif 
			  if cPrev_PLCode == PLUCODE
			     PLU->DISC_QTY -= 1
			     PLU->DISC_AMT -= nPrev_PLSale * val(ITEMCNTR) * 0.01
			  else
			     PLU->DISC_QTY -= 1
			     PLU->DISC_AMT -= cNcon(ITEMSALE) * 0.01
			  endif  
			endif
		elseif TRANS_FLAG == "N"	
			cPrev_PLCode := PLUCODE
			nPrev_PLSale := cNcon(ITEMSALE) * 0.01
		elseif TRANS_FLAG == "C" // RCI 11-22-98
		     if PREVFLAG == "D"
         	 	   if cPrev_PLCode == PLUCODE
			     PLU->DISC_QTY -= 1
  			     PLU->DISC_AMT -= nPrev_PLSale * val(ITEMCNTR) * 0.01
			   else
			     PLU->DISC_QTY -= 1
			     PLU->DISC_AMT -= cNcon(ITEMSALE) * 0.01
			   endif  	
			endif   
		endif		

    		PLU->(dbUnLock())

  	endif    
  enddo
    
  Fclose(nFHandle)
  HEYTHERE()
next i

  UM->(DbSkip())
enddo // 

CHARGE->(dbCommit())    
CHARGE->(DbCloseArea())
PLU->(dbCommit())    
PLU->(DbCloseArea())
UM->(DbCloseArea())

OKDONE()
inkey(1)      

return nil  


function cNcon(n)
return val(if("-" $ n,"-"+substr(n,at("-",n)+1),n))
