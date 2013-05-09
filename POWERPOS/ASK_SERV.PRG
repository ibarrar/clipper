*
* System......... POWERPOS for Spectrum
* Program I.D.... ASK_SERV.prg
* Description.... Do some server and local activities like :
*                 - free inquiry
*                 - file maintenance file (fmf) read
*                 - local PLU updates: ADD, UPDATE, DELETE
*                 - control file update (CNTRL_FMF_EOF)
* Remarks........ (Client-Server) version

#include "config.ch"
#include "file_acc.ch"
#include "fm_file.ch"
#include "message.ch"
#include "keymap.ch"
#include "spec_key.ch"
#include "plu_file.ch"
#include "pfl_clip.ch"

#define NO_OF_RETRIES  10

static nCntrl_FMF := 0
  
#ifdef MIDDAY_ITEM_UPDATE

  function lPending()
  local nFile_FMF := free_inquiry ()
   if nFile_FMF < nCntrl_FMF
      nCntrl_FMF := 0
      updateFMF(nFile_FMF)
   endif
  return nFile_FMF > nCntrl_FMF 

  function GoforOne()
  static nRetry := 0

     if fm_read (nCntrl_FMF+1,.F.) == NORMAL                 
       // update control file's last FMF trans. no...
        nCntrl_FMF++     
        updateFMF(nCntrl_FMF)            
        nRetry := 0
     else
        if nRetry < val(config(POS_NUM_RETS))
          nRetry++
        else
          nRetry := 0
          nCntrl_FMF++
          updateFMF(nCntrl_FMF)
          error_log("ON-LINE FM_TRANS error command failed at FM#: "+padl(nCntrl_FMF-1,8,"0"))        
*          A_RJS_PRNT(1,1,0,"FM_TRANS error command failed at FM#: "+padl(nCntrl_FMF-1,8,"0"),0)        
        endif      
     endif   
	
  return nil
#endif

function ask_server ( mode )
local nFile_FMF := 0
local nRetries := 0

   //
   // inform user of the start-up routine...
   //
   DISPTEXTXY (2, 1, 0, 0, 1, 1, "PLS. WAIT, UPDATING")
   DISPTEXTXY (3, 1, 0, 0, 2, 1, "LOCAL FILES...     ")

   // Get the NVCNTRL FMF last record update
   nCntrl_FMF := getFMF()
   if nCntrl_FMF < 0
      nCntrl_FMF := 0
   endif   
     
   // call a free inquiry to server...
   //
   if (( nFile_FMF := free_inquiry() ) > 0)   
      // now if the local nvcntrl fm counter is greater than the 
      // result in free inquiry reset the nvram counter to 0.
      if nFile_FMF < nCntrl_FMF             
         nCntrl_FMF := 0
         updateFMF(nCntrl_FMF)
      endif     
      ? "Free Inquiry trans. no.   :" + str(nFile_FMF-nCntrl_FMF)
      ? "Value of CNTRL trans. no. :" + str(nCntrl_FMF)
      ? "Value of FMF trans. no.   :" + str(nFile_FMF)
      ? "Press Any key to continue ..."
#ifdef DEF_DISP4X20
       DISPTEXTXY (3,1,0,0,1,1, "LOCAL FMF# :" + padl(nCntrl_FMF,8))
       DISPTEXTXY (2,1,0,0,2,1, "REMOTE FMF#:" + padl(nFile_FMF,8))
       DISPTEXTXY (1,1,0,0,0,0, "NO FREE INQ:" + padl(nFile_FMF-nCntrl_FMF,8))
       DISPTEXTXY (4,1,0,0,0,0,  MSG_D030)
#endif      
      inkey(20)

      // check first if an update is needed...
      if nCntrl_FMF < nFile_FMF 
          
         // compare control file's fm trans. no. to server's fm trans. no....
         while nFile_FMF > nCntrl_FMF 
              
            // try to read the FMF and execute whatever operation it asks
            // or if no. of retries is consumed, update the control file's
            // fmf trans. no....
            if fm_read (++nCntrl_FMF,.T.) == NORMAL
                 
               // update control file's last FMF trans. no...
               updateFMF(nCntrl_FMF)                 

               // evrything A. OK. reset retry flag..
               nRetries := 0
            else                 
               if nRetries < val(config(POS_NUM_RETS))
                  nCntrl_FMF-- // get back to the record where the error occured
                  nRetries ++
               else   
                  error_log("FM_TRANS error command failed at FM#: "+padl(nCntrl_FMF-1,8,"0"))
*                  A_RJS_PRNT(1,1,0,"FM_TRANS error command failed at FM#: "+padl(nCntrl_FMF-1,8,"0"),0)
                  nRetries := 0         
                  // update control file's last FMF trans. no...
                  updateFMF(nCntrl_FMF)
               endif   
               loop    
            endif
         enddo
      endif   // is update needed
     
   endif  // is free inquery ok..
     
return nil

function free_inquiry ()
*******************************************************************
local status := 0
local i      := 0
local fm_trans_no
local cOutdata 
local cIndata := space(FA_FRAME_LEN)
local cPath

cOutData := "00000000"

#ifdef STAND_ALONE_MODE
  cPath := "A:\"
  set_key_sound(OFF)       
#else
  cPath := GetServer_Path()
#endif

// call file access for several tries...
//
status := file_access(FA_CMD_FREEINQ, FA_PRM_ZERO, FA_FN_FMF,FA_SZ_FMF ,cOutData,@cIndata , cPath )

? "Status of free inquiry : " 
if status == NORMAL
 ?? "NORMAL"
else
 ?? "NOT NORMAL" 
 ?? status
endif

fm_trans_no := val(cIndata)

#ifdef STAND_ALONE_MODE
   set_key_sound(ON)   
#endif       

return fm_trans_no 

static function fm_read ( cntrl_fm_trans,lDisplay )
*************************************************
local status      := 7
local data_record := ""
local i           := 0
local cOutData    := padl(cntrl_fm_trans,8,"0")
local cIndata     := space(FA_FRAME_LEN)
local cHeader     := space(25)
local nReport_type:=0
local lPrint      := .F.
local lBackup     := .F.
local lReset      := .F.             
local cFilename,k
local lStatus     := .F.

  // call file access for several tries...  
  //
  status := file_access(FA_CMD_SRCHGET, FA_PRM_ZERO, FA_FN_FMF,FA_FRAME_LEN, cOutData, @cIndata, GetServer_Path())
  
  if status == NORMAL

    // check if request is successful...
    //
    if val(subs(cIndata, FM_TRANNO_OFF, FM_TRANNO_LEN)) > 0

       // Check File ID to produce appropriate DATA Struct
       do case
          case subs(cIndata, FM_FILEID_OFF, FM_FILEID_LEN ) == FA_FN_PLU
            cOutData := formPLU(@cIndata)
            ? "PLU code   : " + subs(cIndata, FM_PLU_CODE_OFF, PLU_CODE_LEN)
            ? "Descriptor : " + subs(cIndata, FM_PLU_DESC_OFF, PLU_DESC_LEN)
            ? "Retail Price:"
            ?? val(substr(cIndata, FM_PLU_PRIC_OFF, 10)) * 0.01 
            ? "Wholesale  : " 
            ?? val(substr(cIndata, FM_PLU_PRI1_OFF, 10)) * 0.01 
            ? "Unit Cost  : " 
            ?? val(substr(cIndata, FM_PLU_PRI6_OFF, 10)) * 0.01 
            if lDisplay            
              DISPTEXTXY(1,1,0,0,1,1,"PLU:  "+subs(cIndata, FM_PLU_CODE_OFF, PLU_CODE_LEN))
              DISPTEXTXY(2,1,0,0,2,1,subs(cIndata, FM_PLU_DESC_OFF, PLU_DESC_LEN))            
#ifdef DEF_DISP4X20
              DISPTEXTXY(3,1,0,0,0,0,"PRICE:"+trans(val(substr(cIndata, FM_PLU_PRIC_OFF, PLU_PRIC_LEN)) * 0.01,"999,999,999.99"))
              DISPTEXTXY(4,1,0,0,0,0,"FMF "+padl(cntrl_fm_trans,8,"0")+" :"+if(status==NORMAL,"NORMAL",tran(status,"999999")))             
#endif		    
            endif              
          case subs(cIndata, FM_FILEID_OFF, FM_FILEID_LEN ) == FA_FN_DPT
           cOutData :=  formDept(@cIndata)
          case subs(cIndata, FM_FILEID_OFF, FM_FILEID_LEN ) == FA_FN_STR 
               /* just acknowledge the presence of this reports */   
	  case subs(cIndata, FM_FILEID_OFF, FM_FILEID_LEN ) == FA_FN_FCR
	         ? "Foreign Currency Update..."
     	    	fcur_set(cIndata)
          otherwise 
            ? 
            ? "File ID "+subs( cIndata, FM_FILEID_OFF, FM_FILEID_LEN ) + ;
              "Maintenance not supported ..."
            BUMMER()  
       endcase
       //
       // evaluate the kind of operation...
       //
       do case
          case subs(cIndata,FM_OPCODE_OFF, FM_OPCODE_LEN ) == "01" .or. ; // record level, ADD...
               subs(cIndata,FM_OPCODE_OFF, FM_OPCODE_LEN ) == "02"        // or EDIT   
          do case
             case subs( cIndata, FM_FILEID_OFF, FM_FILEID_LEN ) == FA_FN_PLU
                cHeader := formHeader(FC_SRCHPUT,FP_ZERO,FA_FN_PLU)   
                status := f_access(@cHeader,cOutData,@cIndata,GetLocal_Path())
                ? "PLU Append/Update reply : " + if(Status==NORMAL,"NORMAL",str(status))
             case subs( cIndata, FM_FILEID_OFF, FM_FILEID_LEN ) == FA_FN_DPT
                cHeader := formHeader(FC_SRCHPUT,FP_ZERO,FA_FN_DPT)             
                status := f_access(@cHeader,cOutData,@cIndata,GetLocal_Path())                      
                ? "Dept Append/Update reply : " + if(Status==NORMAL,"NORMAL",str(status))                
          endcase                
          case subs(cIndata,FM_OPCODE_OFF, FM_OPCODE_LEN ) == "03"   // record level, DELETE...
          do case 
             case subs( cIndata, FM_FILEID_OFF, FM_FILEID_LEN ) == FA_FN_PLU   // PLU file...
                cOutdata := subs(cIndata, FM_PLU_CODE_OFF, PLU_CODE_LEN)
                status := file_access ( FA_CMD_SRCHDEL,FA_PRM_ZERO,FA_FN_PLU, FA_SZ_PLU, cOutData, @cIndata, GetLocal_Path() )
                ? "PLU Delete reply : " + if(Status==NORMAL,"NORMAL","NOT NORMAL:"+str(status))
          endcase
#ifdef NOTHING		
          case subs(cIndata,FM_OPCODE_OFF, FM_OPCODE_LEN ) == "A4"

          k := 0 
          while subs(cIndata,FM_RECORD_OFF + (k*10) + 4, 2 ) != "00"

             lStatus   := .F.              
             cFileName := subs(cIndata,FM_RECORD_OFF + (k*10) + 4, 2 )
             
             lPrint  := subs(cIndata,FM_RECORD_OFF+(k*10)+6,1) == "1"
             lBackup := subs(cIndata,FM_RECORD_OFF+(k*10)+7,1) == "1"
             lReset  := subs(cIndata,FM_RECORD_OFF+(k*10)+8,1) == "1"  
             
             do case
                case cFileName == FA_FN_TRF
                  if lReset
        	    if Sales_to_Server() // just redundantly send anyway...            
		       MsgAreadisp("DEPARTMENT REPORT...") 
		       dept_report( .T. )
		       MsgAreaDisp("TERMINAL REPORT Please Wait ...")       
		       Term_Report( .T. )
		       MsgAreadisp("CASHIER REPORT WAIT.")
		       String_Cash( .T. )
		       MsgAreaDisp("PLU REPORT PLS. WAIT")
		       plu_report(  .T. , .T. )           
		       MsgAreaDisp("Hourly report please wait...")
		       hourly_report(keylock()==KEY_LOCK_POS4)            
		       MsgAreaDisp("End-Of-Day Reports Done....")
		       HeyThere()
		    endif   
		  endif   
		  nReport_type := 1 // terminal
		case cFileName == FA_FN_CSF             
		  nReport_type := 2
		otherwise             
		  ? " report required not yet supported ...: "+ cFileName
		  nReport_type := 0  // invalid parameter
		  k++
		  loop
             endcase             
             
             if lStatus             
	        A_RJS_FEED(1, 1, 0, 1)
	        A_RJS_PRNT(1, 1, 0, "*REMOTE REQUEST TERMINAL <" + ;
										subs(cIndata,FM_RECORD_OFF,4) + ">*", 0)
	        A_RJS_FEED(1, 1, 0, 1)                                              
                
	        do case 
	           case nReport_type == 1
	            if lBackup
	              ? "Will back-up terminal report"
	            endif
	            if lPrint                            // check if to be printed
	              Term_Report( lReset )             // reset ?
	            endif
	           case nReport_type == 2 
	            if lBackup
	              ? "Will back-up cashier report"
	            endif
	            if lPrint                            // check if to be printed
	              String_Cash( lReset )             // reset ?
	            endif                                    
	         endcase                          
             else
                ? "Reports  reply : " + if(Status==NORMAL,"NORMAL","NOT NORMAL:"+str(status))
             endif             

             k++
          enddo
#endif		
       endcase
    endif
 else 
    ? "Error reading FM_TRANS.TXT "
    ? "FMF "+padl(cntrl_fm_trans,8,"0")+" read status : " + str(status)
    ?
    BUMMER()
 endif // status not normal 
 if status != NORMAL
   error_log("FM DATA ERROR:<"+cIndata+">")
 endif
return status


* eop 01/03/96 
