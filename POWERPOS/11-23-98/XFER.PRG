#include "fileio.ch"
#define F_BLOCK  4096

memvar getlist

function main(cParm)
local nbytesread,fh,fd
local cBuffer
local hGauge,totalbytes,nPercent,readbytes
local aDir := {}
local lError := .F.
private cSource,cDest,dDate,cTime

  set exact on
  scroll()

  if file("XFER.MEM")
     RESTORE FROM XFER.MEM ADDITIVE
  else
     cSource := ".\"
     cDest := ".\"
     dDate := ctod("")
     cParm := "/CONFIG"
  endif

  if !empty(cParm) 
     if  upper(cParm) ==  "/CONFIG" .or. upper(subs(cParm,1,2)) == "/C"
        cSource := pad(cSource,50)
        cDest := pad(cDest,50)
        ? 
        ?
        ?
        ?
        @ row()-2,1 say "Enter Source path :" get cSource pict "@!S35"  
        @ row()+1,1 say "  Enter Dest path :" get cDest pict "@!S35"  
        read     
        ?
        cSource := alltrim(cSource)
        cDest := alltrim(cDest)
        if subs(cSource,len(cSource),1) != "\"
            cSource += "\"
        endif
        if subs(cDest,len(cDest),1) != "\"    
            cDest += "\"
        endif
        if ( cSource == cDest )
          ? 
          ? " Cannot copy PLUITEMS.IDX to itself..."
          quit
        endif
     else
       ? 
       ? "XFER.EXE pluitems.idx transfer utility ver1.0"
       ? "         copyright @ 1997 FEMA Bussiness Sys. Corp."
       ?
       ? "  SYNTAX : XFER [/CONFIG] " 
       ?
       ? " switches:"
       ? "           /CONFIG - configuration."
       ?
       quit
     endif   
  endif

  // check if items needs to be adjusted
  aDir := directory(cSource+"PLUITEMS.IDX")
  if empty(aDir)
     ?
     ? "Source PLUITEMS.IDX not found..."
     quit
  endif

  if ( dDate != aDir[1,3] .or. cTime != aDir[1,4] .or. !file(cDest+"PLUITEMS.IDX") )

    fh := fopen(cSource+"PLUITEMS.IDX",FO_READ)
    if ferror() != 0
       ? 
       ? "Error Opening PLUITEMS.IDX...."
       quit
    endif
    if file(cDest+"PLUITEMS.IDX")
      ferase(cDest + "PLUITEMS.BAK" )
      frename(cDest+"PLUITEMS.IDX",cDest+"PLUITEMS.BAK")   
    endif     

    fd := fcreate(cDest+"PLUITEMS.IDX",FC_NORMAL)
    if ferror() != 0
       ?
       ? "Error Opening Destination File...."
       fclose(fh)
       ? "Restoring Backup File... Please Wait...."
       copy file (cDest+"PLUITEMS.BAK")  to (cDest+"PLUITEMS.IDX")
       quit
    endif
    
    hGauge := GaugeNew( 10, 5, 12, MAXCOL() - 5, "W/N", "W+/N" )
    GaugeDisplay( hGauge )
    nPercent := 0      
    readbytes := 0
    totalbytes := fseek(fh,0,FS_END)
    fseek(fh,0,FS_SET)
    cBuffer := space(F_BLOCK)
    nbytesread := F_BLOCK
    while nbytesread > 0
        nbytesread :=  fread(fh, @cBuffer, F_BLOCK )

        if ferror() != 0
           ? 
           ? "Error in updating pluitems.idx..."
           fclose(fh)
           fclose(fd)
           lError := .T.           
           ferase(cDest+"PLUITEMS.IDX")
           ? "Restoring Backup File... Please Wait...."           
           copy file (cDest+"PLUITEMS.BAK")  to (cDest+"PLUITEMS.IDX")           
           exit
        endif     

        fwrite( fd, cBuffer, nbytesread )

        if ferror() != 0
           ? 
           ? "Error in updating pluitems.idx..."
           lError := .T.
           fclose(fh)
           fclose(fd)
           ferase(cDest+"PLUITEMS.IDX")
           ? "Restoring Backup File... Please Wait...."           
           copy file (cDest+"PLUITEMS.BAK")  to (cDest+"PLUITEMS.IDX")                      
           exit
        endif  
        
        readbytes += nbytesread        
        nPercent := (readbytes/totalbytes)
        GaugeUpdate( hGauge, nPercent )
    enddo

    if !lError
      dDate := aDir[1,3]
      cTime := aDir[1,4]
    endif  

    fclose(fh)
    fclose(fd)   
    ?;?
    
  else 
    ? 
    ? "***   PLUITEMS.IDX is up-to-date....   ***"
    ?
  endif 
  
  SAVE ALL to XFER.MEM  
return nil