#include "pfl_clip.ch"
#include "fileio.ch"
#include "terminal.ch"
#include "config.ch"
#include "powerpos.ch"

#define SET_REC          1
static fhandle := -1
static hhandle := -1
static aTerm_ := {}
static aHour_ := {}

function term_init()
local nRetVal := NORMAL
local cBuffer := space(TERMINAL_SIZE)
local i

  aSize(aTerm_,TERM_FIELDS+1) // the plus one is the terminal date

  if (( fhandle := FOPEN ( TERMINAL_FILE , FO_READWRITE ) ) < 1 )
     ? 
     ? " Im re-Writing the "
     ?? TERMINAL_FILE
     tone(300,18)
#ifdef DEBUG     
     Inkey(0)                 
#endif     
     if diskspace()  <  TERMINAL_SIZE
        nRetVal := TERM_NO_SPACE
        error_log("Err Open "+TERMINAL_FILE+" diskspace "+;
                       ltrim(str(ferror())) + '.')                 
     else // Proceed w/ the creation of the TERMINAL REPORT FILE ...
        if (( fhandle := FCREATE( TERMINAL_FILE, FC_HIDDEN+FC_NORMAL ) ) < 1)
             nRetVal := TERM_CREAT_ERR
             error_log("Error Create "+TERMINAL_FILE+" check disk space "+;
                       ltrim(str(ferror())) + '.')          
        else // Terminal file successfully created... now initialize
             Reset_term()
        endif             
     endif
  else  
      // now initialize all the variables.
      FSEEK (fhandle, 0, FS_SET) // Just to make sure
      if FREAD (fhandle, @cBuffer, TERMINAL_SIZE) != TERMINAL_SIZE
         // post to error file...
         nRetVal := TERM_READ_ERR
         error_log("TERMINAL file reading failed at initialization, " +;
                ltrim(str(ferror())) + '.')
      else
         // now put all the files data to the array aTerm_
         for i := TR_DSLS_TOT to TERM_FIELDS                  
             aTerm_[i] := realiee(subs(cBuffer,(i-1)*8+1,8))
         next       

         // now get the date on the file...
         aTerm_[TR_DATE_NOW] := ctod(subs(cBuffer,TERM_DATE_OFF,TERM_DATE_LEN))
                  
      endif
                 
  endif      
  
  ? " Term init Date : "
  ??  subs( cBuffer, TERM_DATE_OFF, TERM_DATE_LEN )
         
  if ltr_Reset() .or. empty(ctod(subs(cBuffer,TERM_DATE_OFF,TERM_DATE_LEN)))
     if ctod(subs(cBuffer,TERM_DATE_OFF,TERM_DATE_LEN)) != date()
         aTerm_[TR_BCTR_TOT] := 1
//         aTerm_[TR_ZCTR_TOT] := 1
     endif    
     aTerm_[TR_DATE_NOW] := date() 
  endif            

  ? " Converted to : "
  ?? aTerm_[TR_DATE_NOW]         

  if aTerm_[TR_BCTR_TOT] > 9
     aTerm_[TR_BCTR_TOT] := 9
  endif   
  
  ? " Batch no read was :"
  ?? aTerm_[TR_BCTR_TOT]

/*************************** H O U R L Y *******************************/

  cBuffer := space(HOURLY_SIZE)
  
  // initialize hourly counter....
  aSize( aHour_, HOURLY_FIELDS )
  
  if (( hhandle := FOPEN ( HOURLY_FILE , FO_READWRITE ) ) < 1 )
     ? 
     ? " Im re-Writing the "
     ?? HOURLY_FILE
     tone(300,18)
     
     if diskspace()  <  TERMINAL_SIZE
        nRetVal := TERM_NO_SPACE
        error_log("Err Open "+HOURLY_FILE+" diskspace "+;
                       ltrim(str(ferror())) + '.')                 
     else // Proceed w/ the creation of the HOURLY REPORT FILE ...
        if (( hhandle := FCREATE( HOURLY_FILE, FC_HIDDEN+FC_NORMAL ) ) < 1)
             nRetVal := TERM_CREAT_ERR
             error_log("Error Create "+HOURLY_FILE+" check disk space "+;
                       ltrim(str(ferror())) + '.')          
        else // Hourly file successfully created... now initialize
             Reset_Hour()
        endif             
     endif
  else  
      // now initialize all the variables.
      FSEEK (hhandle, 0, FS_SET) // Just to make sure
      if FREAD (hhandle, @cBuffer, HOURLY_SIZE) != HOURLY_SIZE
         // post to error file...
         nRetVal := TERM_READ_ERR
         error_log("HOURLY file reading failed at initialization, " +;
                ltrim(str(ferror())) + '.')
      else
         // now put all the files data to the array aHour_
         for i := 1 to HOURLY_FIELDS
             aHour_[i] := realiee(subs(cBuffer,(i-1)*8+1,8))
         next       
      endif
                 
  endif         
          
return nRetVal



static function Update_term()
local nLine_Size := TERMINAL_SIZE 
local cBuffer := ""
local i

   for i := TR_DSLS_TOT to TERM_FIELDS
       cBuffer += ieereal(aTerm_[i])
   next

   if empty(aTerm_[TR_DATE_NOW])
     aTerm_[TR_DATE_NOW] := date()
   endif

   cBuffer += pad(dtoc(aTerm_[TR_DATE_NOW]),TERM_DATE_LEN)        
   
#ifdef DEBUG
   ? "Length of terminal file :"
   ?? len(cBuffer)   

   if len(cBuffer) != TERMINAL_SIZE
      ? "Error buffer length mismatch.."
   endif   
#endif     
   
   FSEEK( fhandle, 0 , FS_SET) // Reset File Pointer
   c_fwrite (fhandle, cBuffer ,@nLine_size)

   if nLine_size != TERMINAL_SIZE
       // post to error file
       error_log ("Error Terminal update, " +ltrim(str(ferror())) +".",1)
   endif

return nil       

static function Reset_term()
local nLine_Size := TERMINAL_SIZE 
local cBuffer := ""
local i

   for i := TR_DSLS_TOT to TERM_FIELDS
       if i == TR_XCTR_TOT .or. i == TR_ZCTR_TOT .or. i == TR_BCTR_TOT
          aTerm_[ i ] := 1
          cBuffer += ieereal(1)
       else   
          aTerm_[ i ] := 0
          cBuffer += ieereal(0)
       endif   
   next

   // not forgetting the date...
   aTerm_[TR_DATE_NOW] := date()   
   cBuffer += dtoc(date())
   
   FSEEK( fhandle, 0 , FS_SET) // Reset File Pointer
   c_fwrite (fhandle, cBuffer ,@nLine_size)

   if nLine_size != TERMINAL_SIZE
       // post to error file
       error_log ("Error Terminal reset, " +ltrim(str(ferror())) +".",1)
   endif

return nil       

static function Update_Hour()
local nLine_Size := HOURLY_SIZE 
local cBuffer := ""
local i

   for i := 1 to HOURLY_FIELDS
       cBuffer += ieereal(aHour_[i])       
   next

   FSEEK( hhandle, 0 , FS_SET) // Reset File Pointer
   c_fwrite (hhandle, cBuffer ,@nLine_size)

   if nLine_size != HOURLY_SIZE
       // post to error file
       error_log ("Error Hourly reset, " +ltrim(str(ferror())) +".",1)
   endif

return nil       

static function Reset_Hour()
local nLine_Size := HOURLY_SIZE 
local cBuffer := ""
local i

   for i := 1 to HOURLY_FIELDS
       aHour_[ i ] := 0
       cBuffer += ieereal(0)
   next

   FSEEK( hhandle, 0 , FS_SET) // Reset File Pointer
   c_fwrite (hhandle, cBuffer ,@nLine_size)

   if nLine_size != HOURLY_SIZE
       // post to error file
       error_log ("Error Hourly reset, " +ltrim(str(ferror())) +".",1)
   endif

return nil       

function Term_nData(nVar,nAmount)

  if nAmount != NIL 
     if nvr_lTRNG_Mode()
        // just check if it is for daily sales
        if nVar == TR_DSLS_TOT 
           // if it is then increment the training mode counters
           aTerm_[TR_TRNG_TOT] += nAmount
           // don't forget her/his own cashiers counter 
           Cash_nData(TR_TRNG_TOT,nAmount)
        endif
     else
       // update terminal counters
       aTerm_[nVar] += nAmount   

       // now update the cashier sales
       // Terminal Batch no is not included in cashier
       //  RONA is cash declaration 

       if (nVar < TR_BCTR_TOT .and. nVar != TR_RONA_TOT .and. nVar != TR_RONA_KNT)
          Cash_nData(nVar,nAmount)
       endif  

       if nVar == TR_DEPT_TOT
         Hour_nData(nAmount)
       elseif nVar == TR_DSLS_KNT
         Hour_nCntr(nAmount) 
       endif  
       Update_Hour()

     endif      

     Update_Term() 

  endif 
      
return aTerm_[nVar]

function Hour_nData(nAmount)
local nHour := val(subs(time(),1,2))

  if empty(nHour); nHour := 24;  endif  
  nHour := ((nHour-1)*2)+1
  aHour_[nHour] += nAmount
  
return nil

function Hour_nCntr(nAmount)
local nHour := val(subs(time(),1,2))

  if empty(nHour) ; nHour := 24 ;  endif  
  nHour := ((nHour-1)*2)+2  
  aHour_[nHour] += nAmount
  
return nil


function Term_off()
  fclose(fhandle)
return nil
  
function Term_Report(lType) // .F. -X; .T. -Z 
local status := 0
local i
local outdata
local total_charges := 0
local gross_sales := 0
local excess := 0
local cash_sales := 0
local daily_sales := 0

  // compute for the total charges for the day 
  total_charges := aTerm_[TR_MC01_TOT] + aTerm_[TR_MC02_TOT] + aTerm_[TR_MC03_TOT] + ;
                   aTerm_[TR_MC04_TOT] + aTerm_[TR_MC05_TOT] + aTerm_[TR_MC06_TOT] + ;
                   aTerm_[TR_MC07_TOT] + aTerm_[TR_MC08_TOT] + aTerm_[TR_MC09_TOT] + ; 
                   aTerm_[TR_MC10_TOT] + aTerm_[TR_MC11_TOT] + aTerm_[TR_MC12_TOT] + ;
                   aTerm_[TR_MC13_TOT] + aTerm_[TR_MC14_TOT] + aTerm_[TR_MC15_TOT] + ;
                   aTerm_[TR_MC16_TOT] + aTerm_[TR_MC17_TOT] + aTerm_[TR_MC18_TOT] + ;
                   aTerm_[TR_MC19_TOT] + aTerm_[TR_MC20_TOT] + aTerm_[TR_MC21_TOT] + ;
                   aTerm_[TR_MC22_TOT] + aTerm_[TR_MC23_TOT] + aTerm_[TR_MC24_TOT] + ;
                   aTerm_[TR_MC25_TOT] + aTerm_[TR_MC26_TOT] + aTerm_[TR_MC27_TOT] + ;
                   aTerm_[TR_MC28_TOT] + aTerm_[TR_MC29_TOT] + aTerm_[TR_MC30_TOT] + ; 
                   aTerm_[TR_MC31_TOT] + aTerm_[TR_MC32_TOT] + aTerm_[TR_MC33_TOT] + ;
                   aTerm_[TR_MC34_TOT] + aTerm_[TR_MC35_TOT] + aTerm_[TR_MC36_TOT] + ;
                   aTerm_[TR_MC37_TOT] + aTerm_[TR_MC38_TOT] + aTerm_[TR_MC39_TOT] + ;
                   aTerm_[TR_MC40_TOT] + aTerm_[TR_MC41_TOT] + aTerm_[TR_MC42_TOT] + ;
                   aTerm_[TR_MC43_TOT] + aTerm_[TR_MC44_TOT] + aTerm_[TR_MC45_TOT] + ;                   
                   aTerm_[TR_MC46_TOT] + aTerm_[TR_MC47_TOT] + aTerm_[TR_MC48_TOT] + ;                   
                   aTerm_[TR_MC49_TOT] + aTerm_[TR_MC50_TOT]

  while chk_jrnal() == PAPER_ERR
       MsgAreaDisp("Receipt/Journal Paper Error")
       tone(600,6) // Error sound
       MsgAreaDisp()       
  enddo                   
                   
  if rpt_prnt(SET_REC, 1, 0, "TERMINAL REPORT", 0) == 0 

     // Update the New Grand Total
//     aTerm_[TR_NEWG_TOT] := aTerm_[TR_OLDG_TOT] + aTerm_[TR_DSLS_TOT]

     gross_sales := (aTerm_[TR_DEPT_TOT] + aTerm_[TR_OINC_TOT] + aTerm_[TR_ADON_TOT])
// START of revisions RCI 10/11/98 	
/*     daily_sales := gross_sales - aTerm_[129] - aTerm_[121] - aTerm_[123] - ;
                      ( aTerm_[111] + aTerm_[113] ) */
     daily_sales := gross_sales - aTerm_[TR_TRVD_TOT] - ;
	                             aTerm_[TR_REXC_TOT] - ;
						    aTerm_[TR_RFND_TOT] - ;
						    aTerm_[TR_IDSC_TOT] - ;
						    aTerm_[TR_SDSC_TOT] 
// END of revisions RCI				
		    // gs - transvoid - return - refund - disc.  .jlp.02.03.98
     aTerm_[TR_NEWG_TOT] := aTerm_[TR_OLDG_TOT] + daily_sales
     ?
     if lType
       outdata := "(Z - "+ alltrim(trans(aTerm_[TR_ZCTR_TOT],"@B 99999"))+ ")"
     else       
       outdata := "(X - "+ alltrim(trans(aTerm_[TR_XCTR_TOT],"@B 99999"))+ ")"
     endif            
     status += rpt_prnt(SET_REC,1,0, outdata, 0)
     ? outdata

//     outdata := "Daily Sales       " + trans(aTerm_[TR_DSLS_TOT]," 99,999,999.99")    
     outdata := "Daily Sales       " + trans(daily_sales," 99,999,999.99")    
     status += rpt_prnt(SET_REC,1,0, outdata, 0)
     ? outdata     

     outdata :=  padl(trans(aTerm_[TR_DSLS_KNT],"999,999,999"),32)
     status += rpt_prnt(SET_REC,1,0, outdata, 0)
     ? outdata

     outdata := "Dept. Sales       " + trans(aTerm_[TR_DEPT_TOT]," 99,999,999.99")
     status += rpt_prnt(SET_REC,1,0, outdata, 0)
     ? outdata     

     //gross_sales := (aTerm_[TR_DEPT_TOT] + aTerm_[TR_OINC_TOT] + aTerm_[TR_ADON_TOT])
     outdata := "Gross Sales       " + trans(gross_sales," 99,999,999.99")
     status += rpt_prnt(SET_REC,1,0, outdata, 0)
     ? outdata     

     cash_sales := (aTerm_[TR_CASH_TOT] + aTerm_[TR_OINC_TOT] + aTerm_[TR_PKUP_TOT] - aTerm_[TR_LOAN_TOT])
     outdata := "Cash Totals       " + trans(cash_sales," 99,999,999.99")
     status += rpt_prnt(SET_REC,1,0, outdata, 0)
     ? outdata
     outdata := "Charge Sales      " + trans(total_charges," 99,999,999.99")
     status += rpt_prnt(SET_REC,1,0, outdata, 0)

/*     outdata := "Cash Declaration  " + trans(aTerm_[141]," 99,999,999.99")
     status += rpt_prnt(SET_REC,1,0, outdata, 0)
     ? outdata                                
     outdata := padl(trans(aTerm_[142],"999,999,999"),32)
     status += rpt_prnt(SET_REC,1,0, outdata, 0)
     ? outdata                                
  
     excess := aTerm_[TR_RONA_TOT] - ((aTerm_[TR_DSLS_TOT] + aTerm_[TR_LOAN_TOT]) - aTerm_[TR_PKUP_TOT])
     outdata := "Over/Short        " + trans(excess," 99,999,999.99")
     status += rpt_prnt(SET_REC,1,0, outdata, 0)
*/
     outdata :=  "Peso Sales        " + trans(aTerm_[TR_FCUR_TOT]," 99,999,999.99")         
     status += rpt_prnt(SET_REC,1,0, outdata, 0)
     ? outdata                             
     outdata := padl(trans(aTerm_[TR_FCUR_KNT],"999,999,999"),32)
     status += rpt_prnt(SET_REC,1,0, outdata, 0)
     ? outdata             
	   
     if 0 != (aTerm_[TR_MC01_TOT] + aTerm_[TR_MC01_KNT])
        outdata := pad(if(empty(GetMDesc(1)),"MISC. 1",GetMDesc(1)),18) + ;
                         trans(aTerm_[TR_MC01_TOT]," 99,999,999.99")
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata                              
        outdata := padl(trans(aTerm_[TR_MC01_KNT],"999,999,999"),32)
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata                                      
     endif    
     if 0 != (aTerm_[TR_MC02_TOT] + aTerm_[TR_MC02_KNT])      
        outdata := pad(if(empty(GetMDesc(2)),"MISC. 2",GetMDesc(2)),18) +;
                                  trans(aTerm_[TR_MC02_TOT]," 99,999,999.99")
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata                                                                
        outdata := padl(trans(aTerm_[TR_MC02_KNT],"999,999,999"),32)
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata                                      
     endif    
     if 0 != (aTerm_[11] + aTerm_[12])
        outdata := pad(if(empty(GetMDesc(3)),"MISC. 3",GetMDesc(3)),18) +;     
                                  trans(aTerm_[11]," 99,999,999.99")
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata                                                                
        outdata := padl(trans(aTerm_[12],"999,999,999"),32)
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata                                      
     endif    
     if 0 != (aTerm_[13] + aTerm_[14])
        outdata := pad(if(empty(GetMDesc(4)),"MISC. 4",GetMDesc(4)),18) +;     
                                  trans(aTerm_[13]," 99,999,999.99")
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata                                                                
        outdata := padl(trans(aTerm_[14],"999,999,999"),32)
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata                                      
     endif    
     if 0 != (aTerm_[15] + aTerm_[16])
        outdata :=  pad(if(empty(GetMDesc(5)),"MISC. 5",GetMDesc(5)),18) +;     
                                  trans(aTerm_[15]," 99,999,999.99")
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata                                                                
        outdata := padl(trans(aTerm_[16],"999,999,999"),32)
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata                                      
     endif    
     if 0 != (aTerm_[17] + aTerm_[18])
        outdata :=  pad(if(empty(GetMDesc(6)),"MISC. 6",GetMDesc(6)),18) +;     
                                  trans(aTerm_[17]," 99,999,999.99")
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata
        outdata :=  padl(trans(aTerm_[18],"999,999,999"),32)
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata
     endif    
     if 0 != (aTerm_[19] + aTerm_[20])
        outdata :=  pad(if(empty(GetMDesc(7)),"MISC. 7",GetMDesc(7)),18) +;     
                                  trans(aTerm_[19]," 99,999,999.99")
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata                                  
        outdata :=  padl(trans(aTerm_[20],"999,999,999"),32)
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata        
     endif    
     if 0 != (aTerm_[21] + aTerm_[22])
        outdata :=  pad(if(empty(GetMDesc(8)),"MISC. 8",GetMDesc(8)),18) +;     
                                  trans(aTerm_[21]," 99,999,999.99")
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata                                  
        outdata :=  padl(trans(aTerm_[22],"999,999,999"),32)
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata        
     endif    
     if 0 != (aTerm_[23] + aTerm_[24])
        outdata :=  pad(if(empty(GetMDesc(9)),"MISC. 9",GetMDesc(9)),18) +;     
                                  trans(aTerm_[23]," 99,999,999.99")
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata                                  
        outdata :=  padl(trans(aTerm_[24],"999,999,999"),32)
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata        
     endif    
     if 0 != (aTerm_[25] + aTerm_[26])
        outdata :=  pad(if(empty(GetMDesc(10)),"MISC. 10",GetMDesc(10)),18) +;     
                                  trans(aTerm_[25]," 99,999,999.99")
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata                                  
        outdata := padl(trans(aTerm_[26],"999,999,999"),32)
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata        
     endif    
     if 0 != (aTerm_[27] + aTerm_[28])
        outdata :=  pad(if(empty(GetMDesc(11)),"MISC. 11",GetMDesc(11)),18) +;     
                                  trans(aTerm_[27]," 99,999,999.99")
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata                                  
        outdata := padl(trans(aTerm_[28],"999,999,999"),32)
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata        
     endif    
     if 0 != (aTerm_[29] + aTerm_[30])
        outdata :=  pad(if(empty(GetMDesc(12)),"MISC. 12",GetMDesc(12)),18) +;     
                                  trans(aTerm_[29]," 99,999,999.99")
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata                                  
        outdata :=  padl(trans(aTerm_[30],"999,999,999"),32)
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata        
     endif    
     if 0 != (aTerm_[31] + aTerm_[32])
        outdata :=  pad(if(empty(GetMDesc(13)),"MISC. 13",GetMDesc(13)),18) +;     
                                  trans(aTerm_[31]," 99,999,999.99")
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata                                  
        outdata := padl(trans(aTerm_[32],"999,999,999"),32)
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata        
     endif    
     if 0 != (aTerm_[33] + aTerm_[34])
        outdata := pad(if(empty(GetMDesc(14)),"MISC. 14",GetMDesc(14)),18) +;     
                                  trans(aTerm_[33]," 99,999,999.99")
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata                                  
        outdata := padl(trans(aTerm_[34],"999,999,999"),32)
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata        
     endif    
     if 0 != (aTerm_[35] + aTerm_[36])
        outdata := pad(if(empty(GetMDesc(15)),"MISC. 15",GetMDesc(15)),18) +;     
                                  trans(aTerm_[35]," 99,999,999.99")
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata                                  
        outdata := padl(trans(aTerm_[36],"999,999,999"),32)
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata        
     endif    
     if 0 != (aTerm_[37] + aTerm_[38])
        outdata := pad(if(empty(GetMDesc(16)),"MISC. 16",GetMDesc(16)),18) +;     
                                          trans(aTerm_[37]," 99,999,999.99")
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata                                          
        outdata := padl(trans(aTerm_[38],"999,999,999"),32)
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata        
     endif    
     if 0 != (aTerm_[39] + aTerm_[40])
        outdata :=  pad(if(empty(GetMDesc(17)),"MISC. 17",GetMDesc(17)),18) +;     
                                  trans(aTerm_[39]," 99,999,999.99")
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata                                  
        outdata :=  padl(trans(aTerm_[40],"999,999,999"),32)
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata        
     endif    
     if 0 != (aTerm_[41] + aTerm_[42])
        outdata := pad(if(empty(GetMDesc(18)),"MISC. 18",GetMDesc(18)),18) +;     
                                  trans(aTerm_[41]," 99,999,999.99")
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata                                  
        outdata := padl(trans(aTerm_[42],"999,999,999"),32)
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata        
     endif    
     if 0 != (aTerm_[43] + aTerm_[44])
        outdata :=  pad(if(empty(GetMDesc(19)),"MISC. 19",GetMDesc(19)),18) +;     
                                  trans(aTerm_[43]," 99,999,999.99")
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata                                  
        outdata :=  padl(trans(aTerm_[44],"999,999,999"),32)
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata        
     endif    
     if 0 != (aTerm_[45] + aTerm_[46])
        outdata := pad(if(empty(GetMDesc(20)),"MISC. 20",GetMDesc(20)),18) +;     
                                  trans(aTerm_[45]," 99,999,999.99")   
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata                                  
        outdata := padl(trans(aTerm_[46],"999,999,999"),32)
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata        
     endif    
     if 0 != (aTerm_[47] + aTerm_[48])
        outdata := pad(if(empty(GetMDesc(21)),"MISC. 21",GetMDesc(21)),18) + ;
                         trans(aTerm_[47]," 99,999,999.99")
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata                              
        outdata := padl(trans(aTerm_[48],"999,999,999"),32)
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata                                      
     endif    
     if 0 != (aTerm_[49] + aTerm_[50])      
        outdata := pad(if(empty(GetMDesc(22)),"MISC. 22",GetMDesc(22)),18) +;
                                  trans(aTerm_[49]," 99,999,999.99")
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata                                                                
        outdata := padl(trans(aTerm_[50],"999,999,999"),32)
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata                                      
     endif    
     if 0 != (aTerm_[51] + aTerm_[52])
        outdata := pad(if(empty(GetMDesc(23)),"MISC. 23",GetMDesc(23)),18) +;     
                                  trans(aTerm_[51]," 99,999,999.99")
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata                                                                
        outdata := padl(trans(aTerm_[52],"999,999,999"),32)
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata                                      
     endif    
     if 0 != (aTerm_[53] + aTerm_[54])
        outdata := pad(if(empty(GetMDesc(24)),"MISC. 24",GetMDesc(24)),18) +;     
                                  trans(aTerm_[53]," 99,999,999.99")
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata                                                                
        outdata := padl(trans(aTerm_[54],"999,999,999"),32)
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata                                      
     endif    
     if 0 != (aTerm_[55] + aTerm_[56])
        outdata :=  pad(if(empty(GetMDesc(25)),"MISC. 25",GetMDesc(25)),18) +;     
                                  trans(aTerm_[55]," 99,999,999.99")
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata                                                                
        outdata := padl(trans(aTerm_[56],"999,999,999"),32)
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata                                      
     endif    
     if 0 != (aTerm_[57] + aTerm_[58])
        outdata :=  pad(if(empty(GetMDesc(26)),"MISC. 26",GetMDesc(26)),18) +;     
                                  trans(aTerm_[57]," 99,999,999.99")
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata
        outdata :=  padl(trans(aTerm_[58],"999,999,999"),32)
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata
     endif    
     if 0 != (aTerm_[59] + aTerm_[60])
        outdata :=  pad(if(empty(GetMDesc(27)),"MISC. 27",GetMDesc(27)),18) +;     
                                  trans(aTerm_[59]," 99,999,999.99")
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata                                  
        outdata :=  padl(trans(aTerm_[60],"999,999,999"),32)
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata        
     endif    
     if 0 != (aTerm_[61] + aTerm_[62])
        outdata :=  pad(if(empty(GetMDesc(28)),"MISC. 28",GetMDesc(28)),18) +;     
                                  trans(aTerm_[61]," 99,999,999.99")
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata                                  
        outdata :=  padl(trans(aTerm_[62],"999,999,999"),32)
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata        
     endif    
     if 0 != (aTerm_[63] + aTerm_[64])
        outdata :=  pad(if(empty(GetMDesc(29)),"MISC. 29",GetMDesc(29)),18) +;     
                                  trans(aTerm_[63]," 99,999,999.99")
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata                                  
        outdata :=  padl(trans(aTerm_[64],"999,999,999"),32)
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata        
     endif    
     if 0 != (aTerm_[65] + aTerm_[66])
        outdata :=  pad(if(empty(GetMDesc(30)),"MISC. 30",GetMDesc(10)),18) +;     
                                  trans(aTerm_[65]," 99,999,999.99")
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata                                  
        outdata := padl(trans(aTerm_[66],"999,999,999"),32)
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata        
     endif    
     if 0 != (aTerm_[67] + aTerm_[68])
        outdata :=  pad(if(empty(GetMDesc(31)),"MISC. 31",GetMDesc(31)),18) +;     
                                  trans(aTerm_[67]," 99,999,999.99")
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata                                  
        outdata := padl(trans(aTerm_[68],"999,999,999"),32)
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata        
     endif    
     if 0 != (aTerm_[69] + aTerm_[70])
        outdata :=  pad(if(empty(GetMDesc(32)),"MISC. 32",GetMDesc(32)),18) +;     
                                  trans(aTerm_[69]," 99,999,999.99")
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata                                  
        outdata :=  padl(trans(aTerm_[70],"999,999,999"),32)
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata        
     endif    
     if 0 != (aTerm_[71] + aTerm_[72])
        outdata :=  pad(if(empty(GetMDesc(73)),"MISC. 33",GetMDesc(33)),18) +;     
                                  trans(aTerm_[71]," 99,999,999.99")
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata                                  
        outdata := padl(trans(aTerm_[72],"999,999,999"),32)
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata        
     endif    
     if 0 != (aTerm_[73] + aTerm_[74])
        outdata := pad(if(empty(GetMDesc(34)),"MISC. 34",GetMDesc(34)),18) +;     
                                  trans(aTerm_[73]," 99,999,999.99")
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata                                  
        outdata := padl(trans(aTerm_[74],"999,999,999"),32)
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata        
     endif    
     if 0 != (aTerm_[75] + aTerm_[76])
        outdata := pad(if(empty(GetMDesc(35)),"MISC. 35",GetMDesc(35)),18) +;     
                                  trans(aTerm_[75]," 99,999,999.99")
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata                                  
        outdata := padl(trans(aTerm_[76],"999,999,999"),32)
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata        
     endif    
     if 0 != (aTerm_[77] + aTerm_[78])
        outdata := pad(if(empty(GetMDesc(36)),"MISC. 36",GetMDesc(36)),18) +;     
                                          trans(aTerm_[77]," 99,999,999.99")
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata                                          
        outdata := padl(trans(aTerm_[78],"999,999,999"),32)
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata        
     endif    
     if 0 != (aTerm_[79] + aTerm_[80])
        outdata :=  pad(if(empty(GetMDesc(37)),"MISC. 37",GetMDesc(37)),18) +;     
                                  trans(aTerm_[79]," 99,999,999.99")
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata                                  
        outdata :=  padl(trans(aTerm_[80],"999,999,999"),32)
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata        
     endif    
     if 0 != (aTerm_[81] + aTerm_[82])
        outdata := pad(if(empty(GetMDesc(38)),"MISC. 38",GetMDesc(38)),18) +;     
                                  trans(aTerm_[81]," 99,999,999.99")
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata                                  
        outdata := padl(trans(aTerm_[82],"999,999,999"),32)
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata        
     endif    
     if 0 != (aTerm_[83] + aTerm_[84])
        outdata :=  pad(if(empty(GetMDesc(39)),"MISC. 39",GetMDesc(39)),18) +;     
                                  trans(aTerm_[83]," 99,999,999.99")
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata                                  
        outdata :=  padl(trans(aTerm_[84],"999,999,999"),32)
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata        
     endif    
     if 0 != (aTerm_[85] + aTerm_[86])
        outdata := pad(if(empty(GetMDesc(40)),"MISC. 20",GetMDesc(40)),18) +;     
                                  trans(aTerm_[85]," 99,999,999.99")   
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata                                  
        outdata := padl(trans(aTerm_[86],"999,999,999"),32)
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata        
     endif    
     if 0 != (aTerm_[87] + aTerm_[88])
        outdata := pad(if(empty(GetMDesc(41)),"MISC. 41",GetMDesc(41)),18) + ;
                         trans(aTerm_[87]," 99,999,999.99")
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata                              
        outdata := padl(trans(aTerm_[88],"999,999,999"),32)
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata                                      
     endif    
     if 0 != (aTerm_[89] + aTerm_[90])      
        outdata := pad(if(empty(GetMDesc(42)),"MISC. 42",GetMDesc(42)),18) +;
                                  trans(aTerm_[89]," 99,999,999.99")
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata                                                                
        outdata := padl(trans(aTerm_[70],"999,999,999"),32)
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata                                      
     endif    
     if 0 != (aTerm_[91] + aTerm_[92])
        outdata := pad(if(empty(GetMDesc(43)),"MISC. 43",GetMDesc(43)),18) +;     
                                  trans(aTerm_[91]," 99,999,999.99")
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata                                                                
        outdata := padl(trans(aTerm_[92],"999,999,999"),32)
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata                                      
     endif    
     if 0 != (aTerm_[93] + aTerm_[94])
        outdata := pad(if(empty(GetMDesc(44)),"MISC. 44",GetMDesc(44)),18) +;     
                                  trans(aTerm_[93]," 99,999,999.99")
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata                                                                
        outdata := padl(trans(aTerm_[94],"999,999,999"),32)
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata                                      
     endif    
     if 0 != (aTerm_[95] + aTerm_[96])
        outdata :=  pad(if(empty(GetMDesc(45)),"MISC. 45",GetMDesc(45)),18) +;     
                                  trans(aTerm_[95]," 99,999,999.99")
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata                                                                
        outdata := padl(trans(aTerm_[96],"999,999,999"),32)
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata                                      
     endif    
     if 0 != (aTerm_[97] + aTerm_[98])
        outdata :=  pad(if(empty(GetMDesc(46)),"MISC. 46",GetMDesc(46)),18) +;     
                                  trans(aTerm_[97]," 99,999,999.99")
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata
        outdata :=  padl(trans(aTerm_[98],"999,999,999"),32)
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata
     endif    
     if 0 != (aTerm_[99] + aTerm_[100])
        outdata :=  pad(if(empty(GetMDesc(47)),"MISC. 47",GetMDesc(47)),18) +;     
                                  trans(aTerm_[99]," 99,999,999.99")
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata                                  
        outdata :=  padl(trans(aTerm_[100],"999,999,999"),32)
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata        
     endif    
     if 0 != (aTerm_[101] + aTerm_[102])
        outdata :=  pad(if(empty(GetMDesc(48)),"MISC. 48",GetMDesc(48)),18) +;     
                                  trans(aTerm_[101]," 99,999,999.99")
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata                                  
        outdata :=  padl(trans(aTerm_[102],"999,999,999"),32)
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata        
     endif    
     if 0 != (aTerm_[103] + aTerm_[104])
        outdata :=  pad(if(empty(GetMDesc(49)),"MISC. 49",GetMDesc(49)),18) +;     
                                  trans(aTerm_[103]," 99,999,999.99")
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata                                  
        outdata :=  padl(trans(aTerm_[104],"999,999,999"),32)
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata        
     endif    
     if 0 != (aTerm_[105] + aTerm_[106])
        outdata :=  pad(if(empty(GetMDesc(50)),"MISC. 50",GetMDesc(50)),18) +;     
                                  trans(aTerm_[105]," 99,999,999.99")
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata                                  
        outdata := padl(trans(aTerm_[106],"999,999,999"),32)
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata        
     endif    


     if 0 != (aTerm_[107] + aTerm_[108])
        outdata := "Item Void         " + trans(aTerm_[107]," 99,999,999.99")
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata        
        outdata :=  padl(trans(aTerm_[108],"999,999,999"),32)
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata        
     endif    
     if 0 != (aTerm_[109] + aTerm_[110])
        outdata := "Manager Void      " + trans(aTerm_[109]," 99,999,999.99")
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata                        
        outdata := padl(trans(aTerm_[110],"999,999,999"),32)
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata                
     endif    
     if 0 != (aTerm_[111] + aTerm_[112])
        outdata := "Item Discount     " + trans(aTerm_[111]," 99,999,999.99")
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata                
        outdata := padl(trans(aTerm_[112],"999,999,999"),32)
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata                
     endif    
     if 0 != (aTerm_[113] + aTerm_[114])
        outdata :=  "Subtotal Discount " + trans(aTerm_[113]," 99,999,999.99") 
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata                
        outdata := padl(trans(aTerm_[114],"999,999,999"),32)
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata                
     endif    
     if 0 != (aTerm_[115] + aTerm_[116])
        outdata := "Add-On Total      " + trans(aTerm_[115]," 99,999,999.99")
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata                
        outdata := padl(trans(aTerm_[116],"999,999,999"),32)
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata                        
     endif     
     if 0 != (aTerm_[117] + aTerm_[118])
        outdata :=  "Selective STT Disc" + trans(aTerm_[117]," 99,999,999.99")
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata                                
        outdata :=  padl(trans(aTerm_[118],"999,999,999"),32)
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata                                
     endif    
     if 0 != (aTerm_[119] + aTerm_[120])
        outdata := "Subtotal Discount " + trans(aTerm_[119]," 99,999,999.99")
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata                                
        outdata := padl(trans(aTerm_[120],"999,999,999"),32)
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata                                
     endif    
     if 0 != (aTerm_[121] + aTerm_[122])
        outdata := "Return Exchange   " + trans(aTerm_[121]," 99,999,999.99")
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata                                
        outdata := padl(trans(aTerm_[122],"999,999,999"),32)
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata                                
     endif    
     if 0 != (aTerm_[123] + aTerm_[124])
        outdata := "Refunds           " + trans(aTerm_[123]," 99,999,999.99")
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata                                
        outdata := padl(trans(aTerm_[124],"999,999,999"),32)
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata                                
     endif    
     if 0 != (aTerm_[125] + aTerm_[126])
        outdata := "Other Income      " + trans(aTerm_[125]," 99,999,999.99")
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata                                
        outdata := padl(trans(aTerm_[126],"999,999,999"),32)
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata                                
     endif    
     if 0 != (aTerm_[127] + aTerm_[128])
        outdata := "Transaction Cancel" + trans(aTerm_[127]," 99,999,999.99")
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata                                
        outdata := padl(trans(aTerm_[128],"999,999,999"),32)
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata                                
     endif    
     if 0 != (aTerm_[129] + aTerm_[130])
        outdata := "Transaction Void  " + trans(aTerm_[129]," 99,999,999.99")
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata                                
        outdata := padl(trans(aTerm_[130],"999,999,999"),32)
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata                                
     endif    
     if 0 != (aTerm_[131] + aTerm_[132])
        outdata := "Trans. Suspend    " + trans(aTerm_[131]," 99,999,999.99")
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata                                
        outdata := padl(trans(aTerm_[132],"999,999,999"),32)
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata                                
     endif    
     if 0 != (aTerm_[133] + aTerm_[134])
        outdata := "Lay-Away Amt      " + trans(aTerm_[133]," 99,999,999.99")
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata                                
        outdata := padl(trans(aTerm_[134],"999,999,999"),32)
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata                                
     endif    
     if 0 != (aTerm_[135] + aTerm_[136])
        outdata := "Pick-Up           " + trans(aTerm_[135]," 99,999,999.99")
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata                                
        outdata := padl(trans(aTerm_[136],"999,999,999"),32)
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata                                
     endif    
     if 0 != (aTerm_[137] + aTerm_[138])
        outdata := "Paid-Out          " + trans(aTerm_[137]," 99,999,999.99")
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata                                
        outdata := padl(trans(aTerm_[138],"999,999,999"),32)
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata                                
     endif    
     if 0 != (aTerm_[139] + aTerm_[140])
        outdata := "Loan              " + trans(aTerm_[139]," 99,999,999.99")
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata                                
        outdata := padl(trans(aTerm_[140],"999,999,999"),32)
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata                                
     endif    
     if 0 != (aTerm_[143] + aTerm_[144])
        outdata := "Bottle Deposit    " + trans(aTerm_[143]," 99,999,999.99")
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata                                
        outdata := padl(trans(aTerm_[144],"999,999,999"),32)
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata                                
     endif    
/*     
     ?  "Offline Total     " + trans(aTerm_[145]," 99,999,999.99")
     ?                   padl(aTerm_[146],32)           
*/   
     if 0 != (aTerm_[145] + aTerm_[146])
        outdata := "Negative Cash     " + trans(aTerm_[145]," 99,999,999.99")
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata                                
        outdata := padl(trans(aTerm_[146],"999,999,999"),32)  
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata                       
     endif                   
*#endif           

     if 0 != (aTerm_[147])
        outdata := "Training Mode     " + trans(aTerm_[147]," 99,999,999.99")
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata                                
     endif
     if 0 != (aTerm_[148])     
        outdata := "Reenter Total     " + trans(aTerm_[148]," 99,999,999.99")
        status += rpt_prnt(SET_REC,1,0, outdata, 0)
        ? outdata                                
     endif 
     ?
     outdata := "Old Grand Total " + trans(aTerm_[149],"9,999,999,999.99")
     status += rpt_prnt(SET_REC,1,0, outdata, 0)
     ? outdata                             
     outdata := "New Grand Total " + trans(aTerm_[150],"9,999,999,999.99")
     status += rpt_prnt(SET_REC,1,0, outdata, 0)
     ? outdata                        
             
     // check if the printing function of 
     // both the receipt and journal was successfull....
     if lType 
       if status == 0 // all printing is normal

          if trbkup_backup()
          
             // Make the new grand total as Old grand total
             // if the Grand total hits the 10,000,000.00 mark reset for next
             aTerm_[TR_OLDG_TOT] := aTerm_[TR_NEWG_TOT]     
        
             for i := TR_DSLS_TOT to TR_REEN_TOT
               aTerm_[i] := 0
             next

             // increment the Z counter
               aTerm_[TR_ZCTR_TOT] += 1 

             if aTerm_[TR_DATE_NOW] != date()
                aTerm_[TR_BCTR_TOT] := 1
                aTerm_[TR_DATE_NOW] := date() 
             endif        

             for i := nvr_nSUSlevel() to 0
               ferase(".\SUSP"+padl(i,4,"0")+".TXT")
             next 

             // reset all suspended transactions             
             nvr_nSUSlevel(0) 

//             if config(POS_TRANNO_RESET)
                 // reset transaction counter
//               nvr_nTranReset()               
//             endif  
            
          else
            DISPTEXTXY(3,1,0,0,0,0,"BACK-UP UNSUCCESSFUL")            
            tone(300,16)            
            MsgAreaDisp("* RETRY Z-READING! *")                      
          endif
       else
          DISPTEXTXY(3,1,0,0,0,0,"PRINT NOT COMPLETED!")
          tone(300,16)                    
          MsgAreaDisp("* RETRY Z-READING! *")
       endif   
    else
          // increment the X counter
          aTerm_[TR_XCTR_TOT] += 1        
     endif
     // now write all updates to the report file      
     Update_term()     
     prnt_end()
     // delay for a moment
     tone(15,54)     
  endif   
  
  
return nil   

function trbkup_backup()
local i
local cBuffer := ""

   for i := TR_DSLS_TOT to TERM_FIELDS
       cBuffer += ieereal(aTerm_[i])
   next

   cBuffer += dtoc(aTerm_[TR_DATE_NOW])
          
return trbkup_append(cBuffer)

function ltr_reset()
local nAccum := 0
local k := TR_DSLS_TOT

   while k <= TR_BOTD_KNT
     nAccum +=  aTerm_[k]
     if nAccum != 0
       exit          
     endif  
     k++
   enddo

   nAccum += aTerm_[TR_TRNG_TOT]
   nAccum += aTerm_[TR_REEN_TOT]
      
return nAccum == 0


function lprev_Reset()
local lRetVal  := .F.
local cMsg1 := "PREVIOUS SALES DATA"
local cMsg2 := "** WAS NOT RESET **"
local cMsg3 := "Please Reset Before"
local cMsg4 := "* Cashier Sign-On *"

  ScrollOff()  
  if !ltr_reset() .and. aTerm_[TR_DATE_NOW] != date()
     disp_clr()     
     DISPTEXTXY(1,1,0,0,1,1,"PREVIOUS SALES DATA")
     DISPTEXTXY(2,1,0,0,2,1,"** WAS NOT RESET **")     
     Display_Msg(cMsg1,cMsg2,cMsg3,cMsg4)
  else     
     lRetVal := .T.
  endif
  ScrollOn()  
   
return lRetVal


function hourly_report(lReset)
local outdata := "HOURLY REPORT " 
local k
local nGrandTot := 0
local nGrandCnt := 0

 outdata += space(9)
 outdata += if(lReset,"Z","X")
 outdata += "-READING"  

 rpt_prnt(1, 1, 0,  outdata, 0)

 // skip line/s
 A_RJS_FEED(1, 0, 0, 1)    

 for k:= 1 to 24
    A_RJS_FEED(1, 0, 0, 1)    
    outdata := padl(k,2,"0")+ ":00 - "+padl(k,2,"0")+ ":59" +space(5)
    outdata += trans(aHour_[((k-1)*2+1)],"999,999,999.99")    
    rpt_prnt(1, 1, 0, outdata, 0)
    outdata := padl(trans(aHour_[((k-1)*2+1)+1],"999,999,999"),32)
    rpt_prnt(1, 1, 0, outdata, 0)
    nGrandTot += aHour_[((k-1)*2+1)]
    nGrandCnt += aHour_[((k-1)*2+1)+1]
 next

 if lReset
   Reset_Hour()
 endif

 A_RJS_FEED(1,1,0,1)
 rpt_prnt(1,1,0, repl("-",32),0)
 outdata := "TOTAL"+space(13)+trans(nGrandTot,"999,999,999.99")
 rpt_prnt(1,1,0,outdata,0)
 outdata := padl(trans(nGrandCnt,"999,999,999"),32)
 rpt_prnt(1, 1, 0, outdata, 0)

 prnt_end() 
  
return nil

#define CRLF  chr(13)+chr(10)

function form_hourly(lReset)
local fhandle := -1
local cFilename := "HOURLY.RPT"
local cDate := strtran(dtoc(Term_nData(TR_DATE_NOW)),"-","/")
local cData,k

    // first copy the report file if it exist
   if File( GetReport_Path()+cFilename )
     __copyfile( GetReport_Path()+cFilename, ".\"+cFilename)
   endif 

   fhandle := fopen( ".\"+cFilename,FO_READWRITE )

   if ferror() == 2
      fhandle := fcreate( ".\"+cFilename, FC_NORMAL )
   endif

   if fhandle < 1
      MsgAreaDisp(" Error Opening output file ")
      tone(300,6)
      return .F.
   endif

   fseek( fhandle, 0, FS_END ) 
   fwrite( fhandle, "HOURLY Z-REPORT   <"+padl(right(alltrim(config(POS_TERM_NUM)),4),4,"0")+">"+CRLF,26)   
   fwrite( fhandle, cDate+ space(11) + subs(time(),1,5)+CRLF,26)

   for k := 1 to 24   
      cData := padl(alltrim(str(k)),2,"0")
      cData += padl(alltrim(strtran(trans(aHour_[((k-1)*2+1)+1],"9999999.999"),".","")),10,"0")
      cData += padl(alltrim(strtran(trans(aHour_[((k-1)*2+1)],"9999999999.99"),".","")),12,"0")    
      cData += CRLF      
      fwrite(fhandle, cData, len(cData) )
   next   

   fclose( fhandle )
   
   if lReset
     Reset_Hour()
   endif

return .T.



/*------------eof------------*/

    