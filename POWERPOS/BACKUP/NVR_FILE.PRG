#include "fileio.ch"
#include "nvr_file.ch"
#include "config.ch"

static fh_cntrl
static lOpen := .F.

#define F_BLOCK  1024
#define NORMAL   0

function NVR_init()
local drive_no := asc(upper(subs(config(POS_NVRAM_DRV),1,1))) - asc("@")
local filename := subs(config(POS_NVRAM_DRV),1,1)+":\" + NVCNTRL_NAME
local cCtrl_Line
local nLine_Size,i
local nRetVal := NVR_NORMAL

 if empty(lOpen) // just to make sure that lOpen will not create a 
    lOpen := .f. // run time error 
 endif   
 
 if !lOpen   // try to open the NVCNTRL file only if it is not open
    if File(filename) 

      if (( fh_cntrl := FOPEN ( filename, FO_READWRITE )) < 1)
            nRetVal := NVR_OPEN_ERR 
            error_log("File: "+filename+" open failed "+;
                       ltrim(str(ferror())) + '.')            
      else

         // file exists try to check for integrity ...
         // by CRC-16 Calculation ... if not reset and erase file
              
         lOpen := .T. // This is good normal open
      endif
      
    endif  

    // file is still not open or CORRUPTED ....
    if !lOpen 
      // check first if there is enough space available in NVRAM     
      if diskspace(drive_no) < (NVR_TRANS_SIZE * NVR_MAXIMUM_PLU) + NVR_CNTRL_SIZE
         nRetVal := NVR_NO_SPACE
      else            
         // Proceed with creating the NVCNTRL File...
         if ((fh_cntrl := FCREATE( filename , FC_NORMAL ) ) < 1)              
            nRetVal := NVR_CREAT_ERR 
         else  
           lOpen := .T.
           // position pointer at the beginning of file...
           FSEEK (fh_cntrl, 0, FS_SET)
           nLine_Size := NVR_CNTRL_SIZE
 
           // write initial values to it...
           // idle mode, no cashier code, zero trans. no., and not suspended...
           cCtrl_Line :=            ; // Desc                   offset   len
                 "0000"        + ; // NVCNTR CRC16 checksum       1     4
                 "0"           + ; // Control File Status         5     1 
                 "OFFOFF"      + ; // Cashier Code                6     6
                 "  -  -  "    + ; // Date                       12     8  
                 "  :  :  "    + ; // Time                       20     8
                 "00000001"      + ; // Transaction Number       28     8
                 "0000"        + ; // Current item no.           36     4
                 ieereal(0)    + ; // Total quantity             40     8
                 ieereal(0)    + ; // Total subtotal             48     8
                 "0"           + ; // Suspended Level            56     1
                 "0"           + ; // Swapped Level              57     1
                 "0"           + ; // Item Purging Level         58     1 
                 "0"           + ; // Transaction Purging Level  59     1
                 "0"           + ; // Training mode status       60     1
                 "00000000"        // FMF_EOF                   _61_____8_
                                   // NVR_CTRL_SIZE  +---------=>      69
              
           c_fwrite (fh_cntrl, cCtrl_Line, @nLine_Size)

           if nLine_Size != NVR_CNTRL_SIZE
                 // post to error file...
                 error_log("NV RAM control file writing failed during NVR set, " + ;
                          ltrim(str(ferror())) + '.')
                 nRetVal := NVR_SAVE_ERR
           endif

           // rci 01.21.96
           // just use the maximum size and allocate it
           FSEEK(fh_cntrl, NVR_CNTRL_SIZE, FS_SET)
           nLine_Size := NVR_TRANS_SIZE      

           for i := 1 to NVR_MAXIMUM_PLU

              c_fwrite (fh_cntrl, space(NVR_TRANS_SIZE) , @nLine_Size)
   
              if nLine_Size != NVR_TRANS_SIZE
                 // post to error file...
                 error_log("NV RAM control file writing failed during NVR set, " + ;
                        ltrim(str(ferror())) + '.')
                   nRetVal := NVR_SAVE_ERR                                                  
              endif   
    
           next // Maximum plu loop
         endif
      endif  // diskspace  
    endif // Normal Open  lOpen == .T.
 endif //  Already open do nothing...
 
return nRetVal

function getFMF()
local nRetVal := NVR_NOT_OPEN
local buffer  := space(NVR_FMF_LEN)

 if lOpen
   FSEEK (fh_cntrl, NVF_FMF_OFF, FS_SET) // Just to make sure
   if FREAD (fh_cntrl, @buffer, NVR_FMF_LEN) != NVR_FMF_LEN
      // post to error file...
      nRetVal := NVR_READ_ERR
      error_log("NV RAM control file reading failed at start-up routine, " +;
                ltrim(str(ferror())) + '.')
   endif
   nRetVal := val(buffer)  
 endif
   
return nRetVal

function updateFMF(nVal)
local nLine_size

  FSEEK (fh_cntrl, NVF_FMF_OFF, FS_SET)
  nLine_size := NVR_FMF_LEN
  c_fwrite (fh_cntrl, padl(nVal,NVR_FMF_LEN,"0"), @nLine_size)
  
  if nLine_size != NVR_FMF_LEN // size of fm_trans_no in fm_trans.txt
     // post to error file...
     error_log("NVCNTRL Error updating FMF counter at " + pad(nVal,8) + ", FERROR:"+;
               ltrim(str(ferror())) + '.')
  endif

return nil         

function get_cntrl()
local buffer  := space(NVR_CNTRL_SIZE)

  FSEEK (fh_cntrl, 0, FS_SET) // Reset File Pointer
  if FREAD (fh_cntrl, @buffer, NVR_CNTRL_SIZE) != NVR_CNTRL_SIZE
      // post to error file...
      error_log("ERROR NVCNTRL file reading, " +ltrim(str(ferror())) + '.',1)
  endif
     
return buffer

function put_cntrl(buffer)
local nLine_size := NVR_CNTRL_SIZE

  FSEEK (fh_cntrl, 0, FS_SET) // Reset File Pointer
  c_fwrite (fh_cntrl, buffer , @nLine_size)

  if nLine_size  != NVR_CNTRL_SIZE
      // post to error file...
      error_log("ERROR NVCNTRL put_cntrl(155) , " +ltrim(str(ferror())) ,1)
  endif
  
return nil  

function get_Trans(nItem)
local buffer  := space(NVR_TRANS_SIZE)
local nOffset 
  
  nItem := nvr_swap(nItem)
  
  nOffset := NVR_CNTRL_SIZE + ((nItem-1)*(NVR_TRANS_SIZE))
  
  FSEEK (fh_cntrl, nOffset , FS_SET) // Reset File Pointer
  if FREAD (fh_cntrl, @buffer, NVR_TRANS_SIZE) != NVR_TRANS_SIZE
      // post to error file...
      error_log("ERROR NVCNTRL file reading, " +ltrim(str(ferror())) + '.',1)
  endif
     
return buffer

function put_Trans(nItem,buffer)
local nLine_size := NVR_TRANS_SIZE
local nOffset

  nItem := nvr_swap(nItem)

  nOffset := NVR_CNTRL_SIZE + ((nItem-1)*(NVR_TRANS_SIZE))
  
  FSEEK( fh_cntrl,nOffset , FS_SET) // Reset File Pointer
  c_fwrite (fh_cntrl, buffer ,@nLine_size)

  if nLine_size != NVR_TRANS_SIZE
     // post to error file
     error_log (" ERROR NVCNTRL put_Trans(185), " +ltrim(str(ferror())) +".",1)
  endif

return nil

function NVR_off()
 fclose(fh_cntrl)
return nil


function nvr_swap( nitems )
local nMin,nMax 
local status := NORMAL
   
   nMin := nvr_nSWPlevel() * NVR_MAXIMUM_PLU 
   nMax := nvr_nSWPlevel() * NVR_MAXIMUM_PLU + NVR_MAXIMUM_PLU

   while nitems < nMin .or. nitems > nMax

     if nitems > nMax
        status := swap_put(nvr_nSWPlevel())
        status += swap_get(nvr_nSWPlevel()+1)
        if status == NORMAL
           nMax += NVR_MAXIMUM_PLU
           nMin += NVR_MAXIMUM_PLU
           nvr_nSWPlevel(nvr_nSWPlevel()+1)
        endif
     elseif nitems < nMin
        status := swap_put(nvr_nSWPlevel())
        status += swap_get(nvr_nSWPlevel()-1)
        if status == NORMAL
           nMax -= NVR_MAXIMUM_PLU
           nMin -= NVR_MAXIMUM_PLU
           nvr_nSWPlevel(nvr_nSWPlevel()-1)
        endif
     endif
     
   enddo
   
return (nitems - nMin)

function swap_put(nSwap)
local status := NORMAL
local nHandle
local cFilename := "C:\NVR_SWAP."+padl(nSwap,3,"0")
local nbytesread := F_BLOCK
local cBuffer := space(F_BLOCK)

  nHandle := fopen(cFilename,FO_READWRITE)

  if ferror() == 2 // file was not found
     nHandle := fcreate( cFilename, FC_NORMAL )
  endif

  status := ferror()

  if status == NORMAL
     //reset destination file
     fseek(nHandle, 0 , FS_SET)
     fseek(fh_cntrl,NVR_CNTRL_SIZE,FS_SET)
     while nbytesread == F_BLOCK .and. ferror() == NORMAL
       nbytesread := fread(fh_cntrl,@cBuffer,F_BLOCK)
       fwrite(nHandle,cBuffer,nbytesread)
     enddo
     status := ferror()
  endif   
  
  fclose(nHandle)
return status


function swap_get(nSwap)
local status := NORMAL
local nHandle,i
local cFilename := "C:\NVR_SWAP."+padl(nvr_nSUSlevel(),2,"0")+padl(nSwap,1,"0")
local nbytesread := F_BLOCK
local cBuffer := space(F_BLOCK)

  nHandle := fopen(cFilename,FO_READWRITE)

  if ferror() == 2 // file was not found
     nHandle := fcreate( cFilename, FC_NORMAL )
     for i := 1 to NVR_MAXIMUM_PLU
         fwrite(nHandle,space(NVR_TRANS_SIZE),NVR_TRANS_SIZE)
     next i     
  endif

  status := ferror()

  if status == NORMAL
     //reset destination file
     fseek(fh_cntrl,NVR_CNTRL_SIZE,FS_SET)
     fseek(nHandle, 0 , FS_SET)
     while nbytesread == F_BLOCK .and. ferror() == NORMAL
       nbytesread := fread(nHandle,@cBuffer,F_BLOCK)
       fwrite(fh_cntrl,cBuffer,nbytesread)
     enddo
     status := ferror()
  endif     
  fclose(nHandle)
return status

*eof---->


