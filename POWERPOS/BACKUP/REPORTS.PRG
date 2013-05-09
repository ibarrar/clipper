#include "cashier.ch"
#include "config.ch"
#include "spec_key.ch"
#include "powerpos.ch"
#include "file_acc.ch"
#include "terminal.ch"
#include "deptfile.ch"
#include "fileio.ch"
#include "grfx_all.ch"
#include "return.ch"
#include "get_grfx.ch"
#include "directry.ch"

#define CRLF  chr(13)+chr(10)
#define F_BLOCK  1024

function reports()
local array                 
local n := 1
local cCashCode
local cTitle
local keyLockPos := keylock()
local aFilename := {}
local afiles:={}
 
    if keyLockPos == 4                 
        array := { "End-Of-Day REPORTS",;
                   "CASHIER REPORT",;  
                   "DEPARTMENT REPORT",;               
                   "INDV.CASHIER RPT",;                 
                   "PLU Zero Skip RPT",;
                   "PLU Range REPORT",;
                   "HOURLY REPORT",;                   
                   "TRAINING MODE",;
                   "EXIT POWERPOS" }
        cTitle := "Z-Reading"
    else
        array := { "TERMINAL REPORTS",;
                   "CASHIER REPORT" , ;
                   "DEPARTMENT REPORT",;               
                   "INDV.CASHIER RPT",;
                   "PLU Zero Skip RPT",;
                   "PLU Range REPORT",;
                   "HOURLY REPORT" }
        cTitle := "X-Reading"           
    endif   
    
    n := aLookUp(30,35,array,cTitle)

    do case
       case n == 1
        if (keyLockPos == KEY_LOCK_POS4)
           if Sales_to_Server() // just redundantly send anyway...            
              MsgAreaDisp("TERMINAL REPORT Please Wait ...")       
              Term_Report( .T. )
              MsgAreadisp("CASHIER REPORT WAIT.")
              String_Cash( .T. )
              // MsgAreaDisp("Hourly report please wait...")
              // hourly_report(keyLockPos==KEY_LOCK_POS4)
	      fopen(Getreport_path()+"NUL.ID")
              if ferror() == 2
                 afiles:=directory("*.RPT")
                 aEval( afiles, { |e| ferase(e[F_NAME]) } )
              endif   
              MsgAreaDisp("End-Of-Day Reports Done....")
              HeyThere()
           endif   
        else
           ccd_report(.f.)
           Term_Report( .F. )
           MsgAreaDisp("TERMINAL REPORT DONE")
        endif                                      
      case n == 2
        MsgAreadisp("CASHIER REPORT WAIT.")
        if (keyLockPos == KEY_LOCK_POS4) 
          if form_cashier(.F.) 
            //produce rpt for resetting
            aAdd(aFilename,"CASHIER.RPT")
          endif  
        endif
        String_Cash(keyLockPos==KEY_LOCK_POS4)
        MsgAreadisp("CASHIER REPORT DONE.")      
      case n == 3  
        MsgAreadisp("DEPARTMENT REPORT...") 
        if keyLockPos == KEY_LOCK_POS4
           if form_dept(.F.)
              aAdd(aFilename,"DEPT.RPT")
           endif   
        endif   
        dept_report(keyLockPos==KEY_LOCK_POS4)
        MsgAreadisp("DEPARTMENT REPORT DONE...") 
      case n == 4
        MsgAreaDisp("ENTER CASHIER CODE..")
        DISPTEXTXY(1, 1, 0, 0, 1, 1, "CASHIER CODE :      ")
        cCashCode := ReadData(1, 16, 1, 1, 1, 16, { |x| (!empty(is_number(x)) .and. x != KEY_PERIOD ) } , 3, "ENTER CASHIER CODE.." )
        if !empty(cCashCode)
           if !Cash_Report(keyLockPos==KEY_LOCK_POS4,cCashCode)
               ErrorDisp("* CODE NOT FOUND ! *")                 
           else
               MsgAreadisp("CASHIER REPORT DONE.")
           endif 
        endif
      case n == 5  .or. n == 6
        MsgAreaDisp("PLU REPORT PLS. WAIT")
        if keyLockPos == KEY_LOCK_POS4 
          if form_PLU(.f.)
             aAdd(aFilename,"PLUITEMS.RPT")
          endif 
        endif 
        plu_report(n == 5,keyLockPos==KEY_LOCK_POS4)
        MsgAreaDisp("* PLU REPORT DONE * ")  
      case n == 7
        MsgAreaDisp("Hourly report please wait...")
        if keyLockPos == KEY_LOCK_POS4 
           if form_hourly(.f.)
             aAdd( aFilename, "HOURLY,RPT" )
           endif  
        endif  
        hourly_report(keyLockPos==KEY_LOCK_POS4)
        MsgAreaDisp("Hourly report done !!!")  
      case n == 8  
        MsgAreaDisp("Activate Training Mode")
        train_mode()
   endcase
   
   if !empty(aFilename)
      if file(".\CCDR.RPT")
           aAdd( aFilename,"CCDR.RPT")
      endif   
      Sales_to_Network(aFilename)
   endif  
              
return ( n == 9 )

/*
function Isdrive(drv_letter)
local fh
// disable sound...
//
#ifdef KEY_SOUND
  set_key_sound(OFF)
#endif
  fh  := Fopen(drv_letter+":\NUL:")
  // enable sound...
  //
#ifdef KEY_SOUND  
  set_key_sound(ON)
#endif  
return ( ferror() <> 3 ) 

function Sales_To_HardDisk(aFilename)
local i
local lRetVal := Get_Password() 
  
  if lRetVal 
     MsgAreaDisp("Report Files Temporarily Saved to Harddisk...")
  else
     BUMMER()         
     BUMMER()             
     BUMMER()                 
     for i := 1 to len(aFilename)
       ferase(aFilename[i])
     next     
  endif

return  lRetVal
*/

function Sales_to_Network(aFilename)
local i,status := NORMAL
local cDate := dtoc(date())
local cFilename
local nHandle,nShandle
local cBuffer := space(F_BLOCK)
local nReadBytes := F_BLOCK

    if empty(aFilename)
      return NORMAL
    endif   
    
    DISPTEXTXY(2,1,0,0,1,1,"SALES THRU NETWORK....")       
    MsgAreaDisp("Sales Thru Network...")
    HeyThere()

    for i := 1 to len(aFilename)
        cFilename := GetReport_Path()+subs(aFilename[i],1,4)
        cFilename += subs(cDate,1,2)+subs(cDate,4,2)+"."+subs(cDate,7,2)+"0"

        nHandle := fopen( cFilename,FO_READWRITE )
        
        if ferror() == 2 // file not found
           nHandle := fcreate( cFilename, FC_NORMAL )
        endif      

        if ferror() != NORMAL
          return ferror()
        endif

        fseek( nHandle, 0, FS_END)
        
        nShandle := fopen( aFilename[i], FO_READWRITE )

        if ferror() != 0  // Error opening aFilename[i]...
           fclose(nHandle)
           return ferror()
        endif      

        cBuffer := space(F_BLOCK)   // actual Data transfer from RPT files...
        nReadBytes := F_BLOCK
        while (ferror() == NORMAL .and. nReadBytes == F_BLOCK)
           nReadBytes := fread( nShandle,@cBuffer, F_BLOCK ) 
           fwrite(nHandle, cBuffer, nReadBytes)
        enddo
        status := ferror()

        fclose(nHandle)
        fclose(nShandle)

        if status != NORMAL
          Error_Log("Error Saving reports :" +str(status)+":"+cFilename)
        else  
         // ferase(aFilename[i])
        endif
    next                           

return status

function  Sales_To_Server()
local i,status  := NORMAL
local aFilename := {} 
local cWindow
#ifdef MODEM_CONNECT
local cDialNum := config(POS_DIAL_NUMBER)
local nRetries := val(config(POS_NUM_RETS))
local nComPort := val(config(POS_MODEM_COMPORT))

   if empty(nRetries)
      nRetries := 3
   endif

   if empty(nComport)
      nComPort := 2
   endif  
#else
local fh    

   if !Get_Password() 
     return .F.
   endif

   MsgAreaDisp(" Trying Network Connectivity. Please Wait... ")    
   fh := fopen(GetReport_Path()+"NUL")
   MsgAreaDisp()            
   if ( ferror() == 3 )
      clearkeys()
      isServer_Mode(.F.)
      Disp_Comm(.F.)      
      cWindow := OpenWindow(22, 32, 81, 72, "Warning:Network is Offline !!!")
      MsgAreaDisp("Press CLR to abort or ENTER to proceed")
      
      @ 45, 30 say "System Warning Message : 00001" 
      @ 49, 30 say "Unable to connect to Network  "
      @ 53, 30 say "         Resource/s. "
      @ 57, 30 say "Contact Network Administrator "
      @ 61, 30 say "     or Retry Connection."
      input()
      CloseWindow(cWindow)
      if lastinput() != ENTER
        return .F.
      endif
   endif                    
   fclose(fh)
   
#endif
      
   MsgAreaDisp(" Cash Declaration Report ..." )     
   if form_ccd( .t. ) .or. file(".\CCDR.RPT")
      aAdd( aFilename, "CCDR.RPT")
   endif      

   MsgAreaDisp(" Creating Terminal report ..." )  
   if form_terminal() 
      aAdd( aFilename, "TERMINAL.RPT" )
   endif   
   
   MsgAreaDisp(" Creating Cashier report ..." )     
   if form_cashier() 
      aAdd( aFilename, "CASHIER.RPT")
   endif   

   MsgAreaDisp(" Creating Department report ..." )     
   if form_dept(.T.) 
      aAdd( aFilename, "DEPT.RPT")
   endif      

   MsgAreaDisp(" Creating PLU Items report ..." )     
   if form_PLU(.T.) 
      aAdd( aFilename, "PLUITEMS.RPT")
   endif      

   MsgAreaDisp(" Creating Return report ..." )     
   if form_Return(.T.)
      aAdd( aFilename, "RETURN.RPT")
   endif         

   MsgAreaDisp(" Creating Hourly report ..." )     
   if form_Hourly(.t.)
      aAdd( aFilename, "HOURLY.RPT")
   endif            

#ifdef MODEM_CONNECT

   if !empty(cDialNum) 
   
		 cWindow := OpenWindow(20, 34, 78, 66,"MODEM CONNECTIVITY")

		 gDrawText(14, 0, "Setup Modem,Line and",      DEFAULT_FONT, 2, 15, MFIX, CENTER_TEXT)
		 gDrawText(15, 0, "Connections for HOST",      DEFAULT_FONT, 2, 15, MFIX, CENTER_TEXT)
		 gDrawText(16, 0, " reports generation.",      DEFAULT_FONT, 2, 15, MFIX, CENTER_TEXT)
		 gDrawText(17, 0, "Dial # :"+pad(cDialNum,12), DEFAULT_FONT, 2, 15, MFIX, CENTER_TEXT)

		 MsgAreaDisp("Press Any Key to Continue...")
		 input()      

		 MsgAreaDisp("Connecting to HOST!  Please Wait..." )                     
               
		 status := xfer_file(nComport,9600,P8N1,cDialNum,aFilename,len(aFilename),nRetries,YMODEM)

		 i := 1
		 while status != NORMAL .and. i < nRetries 

		      ClearBox(22, 42, 76, 63)
		      gDrawText(14, 0, "Trying to Reconnect ",      DEFAULT_FONT, 2, 15, MFIX, CENTER_TEXT)
		      gDrawText(15, 0, "  to HOST computer  ",      DEFAULT_FONT, 2, 15, MFIX, CENTER_TEXT)
		      gDrawText(16, 0, "Dial#:"+padc(cDialNum,14),      DEFAULT_FONT, 2, 15, MFIX, CENTER_TEXT)
		      gDrawText(17, 0, "No of retries :"+trans(i,"9999"), DEFAULT_FONT, 2, 15, MFIX, CENTER_TEXT)
      
		      MsgAreaDisp("Reconnecting to HOST!  Please Wait..." )
                                    
		      status := xfer_file(nComport,9600,P8N1,cDialNum,aFilename,len(aFilename),nRetries,YMODEM)
	 	      i++
                 enddo      

		 CloseWindow(cWindow)

   endif   
#else
   status := Sales_to_Network(aFileName)     
#endif   
      
   ScrollOff()
   disp_clr()   
   if status != NORMAL

        BUMMER()         
        BUMMER()             
        BUMMER()                 
#ifdef MODEM_CONNECT
        ErrorDisp("Modem Fault :"+tran(status,"999")+" will try disk...")
#else
        ErrorDisp("Server Fault :"+tran(status,"999")+" will try local disk...")
#endif  
        MsgAreaDisp("Report Files Temporarily Saved to Harddisk...")      

        A_RJS_FEED(1,1,0,1)
        rpt_prnt(1,1,0,"*** REPORTS GEN.OFFLINE MODE ***",1)
        A_RJS_FEED(1,1,0,1)        
        
        status := NORMAL
   endif
   ScrollOn()   

return (status == NORMAL)

function form_terminal()
local cDate := strtran(dtoc(Term_nData(TR_DATE_NOW)),"-","/")
local cData 
local cBuffer
local nGross_Sls := 0
local fhandle := -1
local cFilename := "TERMINAL.RPT"
local new_grand_tot := Term_nData(TR_OLDG_TOT)
local cash_sales := 0
local nDaily_sls := 0
local ctr,cline,lappend:=.F.
local ntemp,nbytes

      nGross_Sls := Term_nData(TR_DEPT_TOT) + Term_nData(TR_OINC_TOT) + Term_nData(TR_ADON_TOT)
      nDaily_sls := nGross_sls - Term_nData(TR_TRVD_TOT) - ;
                    Term_nData(TR_REXC_TOT) - Term_nData(TR_RFND_TOT) - ;
                  ( Term_nData(TR_IDSC_TOT) + Term_nData(TR_SDSC_TOT) )
      new_grand_tot += nDaily_sls   // Term_nData(TR_DSLS_TOT)  jlp.02.09.98

      cData := "TERMINAL Z-RPT <"+config(POS_TERM_NUM)+">"+CRLF
      cData += cDate+space(8)+subs(time(),1,5)+CRLF
      cBuffer := "001  "+padl(alltrim(trans(Term_nData(TR_DSLS_KNT),"9999")),4,"0")      
      // cBuffer += strim_pad(Term_nData(TR_DSLS_TOT))+CRLF
      cBuffer += strim_pad(nDaily_sls)+CRLF
      cData += cBuffer
      cash_sales := (Term_nData(TR_CASH_TOT) + Term_nData(TR_OINC_TOT) + ;
                     Term_nData(TR_PKUP_TOT) - Term_nData(TR_LOAN_TOT))
      cBuffer := "002"+space(6)+strim_pad(cash_sales)+CRLF
      cData += cBuffer
      // nGross_Sls := Term_nData(TR_DEPT_TOT) + Term_nData(TR_OINC_TOT) + Term_nData(TR_ADON_TOT)
      cBuffer := "003"+space(6)+strim_pad(nGross_Sls)+CRLF
      cData += cBuffer
      cBuffer := "004"+space(6)+strim_pad(Term_nData(TR_DEPT_TOT))+CRLF
      cData += cBuffer      
      cBuffer := "005  "+padl(alltrim(trans(Term_nData(TR_FCUR_KNT),"9999")),4,"0")
      cBuffer += strim_pad(Term_nData(TR_FCUR_TOT))+CRLF
      cData += cBuffer      
      cBuffer := "006  "+padl(alltrim(trans(Term_nData(TR_MC01_KNT),"9999")),4,"0")
      cBuffer += strim_pad(Term_nData(TR_MC01_TOT))+CRLF
      cData += cBuffer      
      cBuffer := "007  "+padl(alltrim(trans(Term_nData(TR_MC02_KNT),"9999")),4,"0")
      cBuffer += strim_pad(Term_nData(TR_MC02_TOT))+CRLF
      cData += cBuffer      
      cBuffer := "008  "+padl(alltrim(trans(Term_nData(TR_MC03_KNT),"9999")),4,"0")
      cBuffer += strim_pad(Term_nData(TR_MC03_TOT))+CRLF
      cData += cBuffer      
      cBuffer := "009  "+padl(alltrim(trans(Term_nData(TR_MC04_KNT),"9999")),4,"0")
      cBuffer += strim_pad(Term_nData(TR_MC04_TOT))+CRLF
      cData += cBuffer      
      cBuffer := "010  "+padl(alltrim(trans(Term_nData(TR_MC05_KNT),"9999")),4,"0")
      cBuffer += strim_pad(Term_nData(TR_MC05_TOT))+CRLF
      cData += cBuffer      
      cBuffer := "011  "+padl(alltrim(trans(Term_nData(TR_MC06_KNT),"9999")),4,"0")
      cBuffer += strim_pad(Term_nData(TR_MC06_TOT))+CRLF
      cData += cBuffer      
      cBuffer := "012  "+padl(alltrim(trans(Term_nData(TR_MC07_KNT),"9999")),4,"0")
      cBuffer += strim_pad(Term_nData(TR_MC07_TOT))+CRLF
      cData += cBuffer      
      cBuffer := "013  "+padl(alltrim(trans(Term_nData(TR_MC08_KNT),"9999")),4,"0")
      cBuffer += strim_pad(Term_nData(TR_MC08_TOT))+CRLF
      cData += cBuffer      
      cBuffer := "014  "+padl(alltrim(trans(Term_nData(TR_MC09_KNT),"9999")),4,"0")
      cBuffer += strim_pad(Term_nData(TR_MC09_TOT))+CRLF
      cData += cBuffer      
      cBuffer := "015  "+padl(alltrim(trans(Term_nData(TR_MC10_KNT),"9999")),4,"0")
      cBuffer += strim_pad(Term_nData(TR_MC10_TOT))+CRLF
      cData += cBuffer      
      cBuffer := "016  "+padl(alltrim(trans(Term_nData(TR_MC11_KNT),"9999")),4,"0")
      cBuffer += strim_pad(Term_nData(TR_MC11_TOT))+CRLF
      cData += cBuffer      
      cBuffer := "017  "+padl(alltrim(trans(Term_nData(TR_MC12_KNT),"9999")),4,"0")
      cBuffer += strim_pad(Term_nData(TR_MC12_TOT))+CRLF
      cData += cBuffer      
      cBuffer := "018  "+padl(alltrim(trans(Term_nData(TR_MC13_KNT),"9999")),4,"0")
      cBuffer += strim_pad(Term_nData(TR_MC13_TOT))+CRLF
      cData += cBuffer      
      cBuffer := "019  "+padl(alltrim(trans(Term_nData(TR_MC14_KNT),"9999")),4,"0")
      cBuffer += strim_pad(Term_nData(TR_MC14_TOT))+CRLF
      cData += cBuffer      
      cBuffer := "020  "+padl(alltrim(trans(Term_nData(TR_MC15_KNT),"9999")),4,"0")
      cBuffer += strim_pad(Term_nData(TR_MC15_TOT))+CRLF
      cData += cBuffer      
      cBuffer := "021  "+padl(alltrim(trans(Term_nData(TR_MC16_KNT),"9999")),4,"0")
      cBuffer += strim_pad(Term_nData(TR_MC16_TOT))+CRLF
      cData += cBuffer      
      cBuffer := "022  "+padl(alltrim(trans(Term_nData(TR_MC17_KNT),"9999")),4,"0")
      cBuffer += strim_pad(Term_nData(TR_MC17_TOT))+CRLF
      cData += cBuffer      
      cBuffer := "023  "+padl(alltrim(trans(Term_nData(TR_MC18_KNT),"9999")),4,"0")
      cBuffer += strim_pad(Term_nData(TR_MC18_TOT))+CRLF
      cData += cBuffer      
      cBuffer := "024  "+padl(alltrim(trans(Term_nData(TR_MC19_KNT),"9999")),4,"0")
      cBuffer += strim_pad(Term_nData(TR_MC19_TOT))+CRLF
      cData += cBuffer
      cBuffer := "025  "+padl(alltrim(trans(Term_nData(TR_MC20_KNT),"9999")),4,"0")
      cBuffer += strim_pad(Term_nData(TR_MC20_TOT))+CRLF
      cData += cBuffer
      cBuffer := "026  "+padl(alltrim(trans(Term_nData(TR_MC21_KNT),"9999")),4,"0")
      cBuffer += strim_pad(Term_nData(TR_MC21_TOT))+CRLF
      cData += cBuffer      
      cBuffer := "027  "+padl(alltrim(trans(Term_nData(TR_MC22_KNT),"9999")),4,"0")
      cBuffer += strim_pad(Term_nData(TR_MC22_TOT))+CRLF
      cData += cBuffer      
      cBuffer := "028  "+padl(alltrim(trans(Term_nData(TR_MC23_KNT),"9999")),4,"0")
      cBuffer += strim_pad(Term_nData(TR_MC23_TOT))+CRLF
      cData += cBuffer      
      cBuffer := "029  "+padl(alltrim(trans(Term_nData(TR_MC24_KNT),"9999")),4,"0")
      cBuffer += strim_pad(Term_nData(TR_MC24_TOT))+CRLF
      cData += cBuffer      
      cBuffer := "030  "+padl(alltrim(trans(Term_nData(TR_MC25_KNT),"9999")),4,"0")
      cBuffer += strim_pad(Term_nData(TR_MC25_TOT))+CRLF
      cData += cBuffer      
      cBuffer := "031  "+padl(alltrim(trans(Term_nData(TR_MC26_KNT),"9999")),4,"0")
      cBuffer += strim_pad(Term_nData(TR_MC26_TOT))+CRLF
      cData += cBuffer      
      cBuffer := "032  "+padl(alltrim(trans(Term_nData(TR_MC27_KNT),"9999")),4,"0")
      cBuffer += strim_pad(Term_nData(TR_MC27_TOT))+CRLF
      cData += cBuffer      
      cBuffer := "033  "+padl(alltrim(trans(Term_nData(TR_MC28_KNT),"9999")),4,"0")
      cBuffer += strim_pad(Term_nData(TR_MC28_TOT))+CRLF
      cData += cBuffer      
      cBuffer := "034  "+padl(alltrim(trans(Term_nData(TR_MC29_KNT),"9999")),4,"0")
      cBuffer += strim_pad(Term_nData(TR_MC29_TOT))+CRLF
      cData += cBuffer      
      cBuffer := "035  "+padl(alltrim(trans(Term_nData(TR_MC30_KNT),"9999")),4,"0")
      cBuffer += strim_pad(Term_nData(TR_MC30_TOT))+CRLF
      cData += cBuffer      
      cBuffer := "036  "+padl(alltrim(trans(Term_nData(TR_MC31_KNT),"9999")),4,"0")
      cBuffer += strim_pad(Term_nData(TR_MC31_TOT))+CRLF
      cData += cBuffer      
      cBuffer := "037  "+padl(alltrim(trans(Term_nData(TR_MC32_KNT),"9999")),4,"0")
      cBuffer += strim_pad(Term_nData(TR_MC32_TOT))+CRLF
      cData += cBuffer      
      cBuffer := "038  "+padl(alltrim(trans(Term_nData(TR_MC33_KNT),"9999")),4,"0")
      cBuffer += strim_pad(Term_nData(TR_MC33_TOT))+CRLF
      cData += cBuffer      
      cBuffer := "039  "+padl(alltrim(trans(Term_nData(TR_MC34_KNT),"9999")),4,"0")
      cBuffer += strim_pad(Term_nData(TR_MC34_TOT))+CRLF
      cData += cBuffer      
      cBuffer := "040  "+padl(alltrim(trans(Term_nData(TR_MC35_KNT),"9999")),4,"0")
      cBuffer += strim_pad(Term_nData(TR_MC35_TOT))+CRLF
      cData += cBuffer      
      cBuffer := "041  "+padl(alltrim(trans(Term_nData(TR_MC36_KNT),"9999")),4,"0")
      cBuffer += strim_pad(Term_nData(TR_MC36_TOT))+CRLF
      cData += cBuffer      
      cBuffer := "042  "+padl(alltrim(trans(Term_nData(TR_MC37_KNT),"9999")),4,"0")
      cBuffer += strim_pad(Term_nData(TR_MC37_TOT))+CRLF
      cData += cBuffer      
      cBuffer := "043  "+padl(alltrim(trans(Term_nData(TR_MC38_KNT),"9999")),4,"0")
      cBuffer += strim_pad(Term_nData(TR_MC38_TOT))+CRLF
      cData += cBuffer      
      cBuffer := "044  "+padl(alltrim(trans(Term_nData(TR_MC39_KNT),"9999")),4,"0")
      cBuffer += strim_pad(Term_nData(TR_MC39_TOT))+CRLF
      cData += cBuffer
      cBuffer := "045  "+padl(alltrim(trans(Term_nData(TR_MC40_KNT),"9999")),4,"0")
      cBuffer += strim_pad(Term_nData(TR_MC40_TOT))+CRLF
      cData += cBuffer
      cBuffer := "046  "+padl(alltrim(trans(Term_nData(TR_MC41_KNT),"9999")),4,"0")
      cBuffer += strim_pad(Term_nData(TR_MC41_TOT))+CRLF
      cData += cBuffer      
      cBuffer := "047  "+padl(alltrim(trans(Term_nData(TR_MC42_KNT),"9999")),4,"0")
      cBuffer += strim_pad(Term_nData(TR_MC42_TOT))+CRLF
      cData += cBuffer      
      cBuffer := "048  "+padl(alltrim(trans(Term_nData(TR_MC43_KNT),"9999")),4,"0")
      cBuffer += strim_pad(Term_nData(TR_MC43_TOT))+CRLF
      cData += cBuffer      
      cBuffer := "049  "+padl(alltrim(trans(Term_nData(TR_MC44_KNT),"9999")),4,"0")
      cBuffer += strim_pad(Term_nData(TR_MC44_TOT))+CRLF
      cData += cBuffer      
      cBuffer := "050  "+padl(alltrim(trans(Term_nData(TR_MC45_KNT),"9999")),4,"0")
      cBuffer += strim_pad(Term_nData(TR_MC45_TOT))+CRLF
      cData += cBuffer      
      cBuffer := "051  "+padl(alltrim(trans(Term_nData(TR_MC46_KNT),"9999")),4,"0")
      cBuffer += strim_pad(Term_nData(TR_MC46_TOT))+CRLF
      cData += cBuffer      
      cBuffer := "052  "+padl(alltrim(trans(Term_nData(TR_MC47_KNT),"9999")),4,"0")
      cBuffer += strim_pad(Term_nData(TR_MC47_TOT))+CRLF
      cData += cBuffer      
      cBuffer := "053  "+padl(alltrim(trans(Term_nData(TR_MC48_KNT),"9999")),4,"0")
      cBuffer += strim_pad(Term_nData(TR_MC48_TOT))+CRLF
      cData += cBuffer      
      cBuffer := "054  "+padl(alltrim(trans(Term_nData(TR_MC49_KNT),"9999")),4,"0")
      cBuffer += strim_pad(Term_nData(TR_MC49_TOT))+CRLF
      cData += cBuffer      
      cBuffer := "055  "+padl(alltrim(trans(Term_nData(TR_MC50_KNT),"9999")),4,"0")
      cBuffer += strim_pad(Term_nData(TR_MC50_TOT))+CRLF
      cData += cBuffer      
      cBuffer := "056  "+padl(alltrim(trans(Term_nData(TR_VOID_KNT),"9999")),4,"0")
      cBuffer += strim_pad(Term_nData(TR_VOID_TOT))+CRLF
      cData += cBuffer
      cBuffer := "057  "+padl(alltrim(trans(Term_nData(TR_MGRV_KNT),"9999")),4,"0")
      cBuffer += strim_pad(Term_nData(TR_MGRV_TOT))+CRLF
      cData += cBuffer
      cBuffer := "058  "+padl(alltrim(trans(Term_nData(TR_IDSC_KNT),"9999")),4,"0")
      cBuffer += strim_pad(Term_nData(TR_IDSC_TOT))+CRLF
      cData += cBuffer
      cBuffer := "059  "+padl(alltrim(trans(Term_nData(TR_SDSC_KNT),"9999")),4,"0")
      cBuffer += strim_pad(Term_nData(TR_SDSC_TOT))+CRLF
      cData += cBuffer                        
      cBuffer := "060  "+padl(alltrim(trans(Term_nData(TR_ADON_KNT),"9999")),4,"0")
      cBuffer += strim_pad(Term_nData(TR_ADON_TOT))+CRLF
      cData += cBuffer
      cBuffer := "061  "+padl(alltrim(trans(Term_nData(TR_SESD_KNT),"9999")),4,"0")
      cBuffer += strim_pad(Term_nData(TR_SESD_TOT))+CRLF
      cData += cBuffer
      cBuffer := "062  "+padl(alltrim(trans(Term_nData(TR_SADO_KNT),"9999")),4,"0")
      cBuffer += strim_pad(Term_nData(TR_SADO_TOT))+CRLF
      cData += cBuffer
      cBuffer := "063  "+padl(alltrim(trans(Term_nData(TR_REXC_KNT),"9999")),4,"0")      
      cBuffer += strim_pad(Term_nData(TR_REXC_TOT))+CRLF
      cData += cBuffer      
      cBuffer := "064  "+padl(alltrim(trans(Term_nData(TR_RFND_KNT),"9999")),4,"0")
      cBuffer += strim_pad(Term_nData(TR_RFND_TOT))+CRLF
      cData += cBuffer
      cBuffer := "065  "+padl(alltrim(trans(Term_nData(TR_OINC_KNT),"9999")),4,"0")
      cBuffer += strim_pad(Term_nData(TR_OINC_TOT))+CRLF
      cData += cBuffer
      cBuffer := "066  "+padl(alltrim(trans(Term_nData(TR_TRCL_KNT),"9999")),4,"0")
      cBuffer += strim_pad(Term_nData(TR_TRCL_TOT))+CRLF
      cData += cBuffer
      cBuffer := "067  "+padl(alltrim(trans(Term_nData(TR_TRVD_KNT),"9999")),4,"0")
      cBuffer += strim_pad(Term_nData(TR_TRVD_TOT))+CRLF
      cData += cBuffer                        
      cBuffer := "068  "+padl(alltrim(trans(Term_nData(TR_TRSU_KNT),"9999")),4,"0")
      cBuffer += strim_pad(Term_nData(TR_TRSU_TOT))+CRLF
      cData += cBuffer
      cBuffer := "069  "+padl(alltrim(trans(Term_nData(TR_LAYA_KNT),"9999")),4,"0")
      cBuffer += strim_pad(Term_nData(TR_LAYA_TOT))+CRLF
      cData += cBuffer
      cBuffer := "070  "+padl(alltrim(trans(Term_nData(TR_PKUP_KNT),"9999")),4,"0")
      cBuffer += strim_pad(Term_nData(TR_PKUP_TOT))+CRLF
      cData += cBuffer
      cBuffer := "071  "+padl(alltrim(trans(Term_nData(TR_PDOT_KNT),"9999")),4,"0")
      cBuffer += strim_pad(Term_nData(TR_PDOT_TOT))+CRLF
      cData += cBuffer      
      cBuffer := "072  "+padl(alltrim(trans(Term_nData(TR_LOAN_KNT),"9999")),4,"0")
      cBuffer += strim_pad(Term_nData(TR_LOAN_TOT))+CRLF
      cData += cBuffer
      cBuffer := "073  "+padl(alltrim(trans(Term_nData(TR_RONA_KNT),"9999")),4,"0")
      cBuffer += strim_pad(Term_nData(TR_RONA_TOT))+CRLF
      cData += cBuffer
      cBuffer := "074  "+padl(alltrim(trans(Term_nData(TR_BOTD_KNT),"9999")),4,"0")
      cBuffer += strim_pad(Term_nData(TR_BOTD_TOT))+CRLF
      cData += cBuffer
      cBuffer := "075"+space(6)+strim_pad(Term_nData(TR_TRNG_TOT))+CRLF
      cData += cBuffer                        
      cBuffer := "076"+space(6)+strim_pad(Term_nData(TR_OFFL_TOT))+CRLF
      cData += cBuffer
      cBuffer := "077"+space(6)+strim_pad(Term_nData(TR_REEN_TOT))+CRLF
      cData += cBuffer
      cBuffer := "078"+space(6)+strim_pad(Term_nData(TR_OLDG_TOT))+CRLF
      cData += cBuffer
      cBuffer := "079"+space(6)+strim_pad(new_grand_tot)+CRLF
      cData += cBuffer      
      cBuffer := "080  "+padl(alltrim(trans(Term_nData(TR_XCTR_TOT),"999999")),6,"0")+space(10)+CRLF
      cData += cBuffer
      cBuffer := "081  "+padl(alltrim(trans(Term_nData(TR_ZCTR_TOT),"999999")),6,"0")+space(10)+CRLF
      cData += cBuffer         

/*      // first copy the report file if it exist
      if File( GetReport_Path()+cFilename )
         __copyfile( GetReport_Path()+cFilename, ".\"+cFilename)
      endif 
*/
      
      fhandle := fopen( ".\"+cFilename,FO_READWRITE )

      if ferror() == 2
         fhandle := fcreate( ".\"+cFilename, FC_NORMAL )
      else
	 ctr:=0
         fseek( fhandle, 0 , FS_SET)
         while !feof(fhandle)
  	    cline:=space(23)
	    fread(fhandle,@cline,len(cline))
	    cline:=space(23)
	    fread(fhandle,@cline,len(cline))
	    if substr(cline,1,8) == alltrim(cDate)
	       exit
	    else   
	       ctr += 1
	       while !feof(fhandle)
	         cline:=space(23)
   	         fread(fhandle,@cline,len(cline))
	         if substr(cline,1,3) == "081"
	            exit
	         endif   
	       enddo
	    endif   
	 enddo   
         while !feof(fhandle)
            cline:=space(23)
            fread(fhandle,@cline,len(cline))
            if substr(cline,1,3) == "081" 
	      if val(substr(cline,6,6)) == Term_nData(TR_ZCTR_TOT)
	         MsgAreaDisp("Terminal already Reset...")
	         lAppend:=.T.
	         exit
	      else 
	         ctr += 1
	      endif
            endif 
         enddo 
      endif

      if fhandle < 1
         MsgAreaDisp(" Error Opening output file ")
         tone(300,6)
         return .F.
      endif

      if lAppend   // Erase Data that has double sales...
         if file("TEMP.ID")
	    ferase("TEMP.ID")
	 endif
         nTemp:=fcreate("TEMP.ID")
         fseek(fhandle,0,FS_SET)
	 while ctr > 0 
	       cline:=space(23)
               fread(fhandle,@cline,len(cline))
	       if substr(cline,1,3) == "081"
	          ctr := ctr - 1
               endif   	       
	       fwrite(nTemp,cline,len(cline))
	 enddo
	 fclose(fhandle)
	 ferase(".\"+cFileName)
         fhandle:=fcreate( ".\"+cFilename, FC_NORMAL )

	 fseek(nTemp,0,FS_SET)
	 while !feof(nTemp)
               cline:=space(23)
	       fread(nTemp,@cline,len(cline))
	       fwrite(fhandle,cline,len(cline))
	 enddo      
	 fclose(nTemp)
	 ferase("TEMP.ID")
      endif
   
      fseek( fhandle, 0 , FS_END)
      fwrite( fhandle, cData, len(cData))
      
      fclose( fhandle )            
      
return .T.


#define CASHIER_FILE     (subs(config(POS_NVRAM_DRV),1,1)+":\CASHIER.POS")
#define LOCAL_CASH_FILE  GetLocal_path()+"CASHIER.LOC"

#define  CS_FIELD_KNT   CS_ATRN_TIM // last field in the local cashier file 

function form_cashier()
local fhandle,cs_handle
local cBuffer ,nbytes
local aData_ := {}
local aCash_ := {}
local cData := ""
local k,i
local cFilename := "CASHIER.RPT"
local nGross_Sales := 0
local cDate := strtran(dtoc(Term_nData(TR_DATE_NOW)),"-","/")
local cash_sales := 0
local ctr,cline,lappend:=.F.
local nTemp,lexisting:=.F.
local nDaily_Sls,nCname:=0

   // Search for the key code entered
   if (( cs_handle := FOPEN ( LOCAL_CASH_FILE , FO_READWRITE ) ) < 1 )  
        error_log("Err Open "+LOCAL_CASH_FILE+": "+;
                       ltrim(str(ferror())) + '.')                 
   else  
      // Seek for the Cashier code to place in nvram
      i := 0
      FSEEK( cs_handle, 0 , FS_SET )
      cBuffer := space(LOCAL_CASH_SIZE)
      while FREAD( cs_handle, @cBuffer, LOCAL_CASH_SIZE ) == LOCAL_CASH_SIZE
         aadd( aCash_, cBuffer )
         i += LOCAL_CASH_SIZE
         FSEEK( cs_handle, i, FS_SET)
         cBuffer := space(LOCAL_CASH_SIZE)
      enddo         
   endif

   fclose(cs_handle)

/*
   // first copy the report file if it exist
   if File( GetReport_Path()+cFilename )
         __copyfile( GetReport_Path()+cFilename, ".\"+cFilename)
   endif 
*/

   fhandle := fopen( ".\"+cFilename,FO_READWRITE )

   if ferror() == 2
      fhandle := fcreate( ".\"+cFilename, FC_NORMAL )
   else
      lexisting:=.T.
   endif

   if fhandle < 1
      MsgAreaDisp(" Error Opening output file ")
      tone(300,6)
      return .F.
   endif

   fseek( fhandle, 0, FS_END ) 
   cline:=padr("CASHIER Z-REPORT <"+padl(right(alltrim(config(POS_TERM_NUM)),4),4,"0")+">",1275)+CRLF
//   fwrite( fhandle, "CASHIER Z-REPORT <"+padl(right(alltrim(config(POS_TERM_NUM)),4),4,"0")+">"+CRLF ,25)   
   fwrite( fhandle, cline, len(cline) )
   cline:=padr( cDate+ space(10) + subs(time(),1,5),1275) + CRLF
//   fwrite( fhandle, cDate+ space(10) + subs(time(),1,5)+CRLF,25)
   fwrite( fhandle, cline, len(cline) )

   // output the data from file to file
   for k := 1 to len(aCash_)   

#ifdef DEF_GRAPHICS   
     DISPTEXTXY(3,1,0,0,0,0,"TESTING CASHIER :"+padl(aCash_[k],3,"0"))
#else
     MsgAreaDisp("TESTING CASHIER :"+padl(aCash_[k],3,"0"))
#endif  

     cData := subs(aCash_[k],CS_CODE_OFF,CS_CODE_LEN) 
     cData += subs(aCash_[k],CS_NAME_OFF,CS_NAME_LEN) 

     aSize( aData_,CS_FIELD_KNT )
     afill( aData_, 0 )
     for i := 1 to CS_FIELD_KNT
          aData_[i] := realiee( subs( aCash_[k],CS_DATA_OFF+(i-1)*8,8))
     next     

     if aData_[CS_DSLS_TOT] <= 0  // zero.skip.jlp.01.28.98  
        loop
     endif	

     if lexisting                 // Hardest.part.jlp.02.18.98
        ctr:=0
        fseek(fhandle,0,FS_SET)

        while !feof(fhandle)

	cline:=space(1277)
        fread(fhandle,@cline,len(cline))
        cline:=space(1277)
        fread(fhandle,@cline,len(cline))

	if feof(fhandle)
	   exit
	endif   

	if substr(cline,1,8) != alltrim(cDate)   //skip until today...
	   cline:=space(1277)
           fread(fhandle,@cline,len(cline))
	   nCname += 1
	   cline:=space(1277)
           fread(fhandle,@cline,len(cline))
	   if feof(fhandle)
	      exit
	   endif
	   if substr(cline,1,4) == "CASH"
	      fseek(fhandle,-1277,FS_RELATIVE)
  	      ctr += 1
	      loop
	   else
	      nCname += 1
	      loop   
	   endif   
	else
           cline:=space(1277)
           fread(fhandle,@cline,len(cline))
	   
    	   if substr(cline,1,3) == substr(cData,1,3)    // cashier code...
              if val(substr(alltrim(cline),1272,4)) == aData_[CS_ZCTR_TOT]
                 MsgAreaDisp("Cashier RPT Already reset...")
	         lexisting:=.F.
                 lappend:=.T.   // repeated cashier report...
	         exit
	      else
  	         lexisting:=.F.
	         lappend:=.F.
	         nCname += 1       // Nag-read.kaninang.umaga...
	         ctr += 1	 
		 loop
	      endif  
	   else
              lexisting:=.F.
	      lappend:=.F.
	      nCname += 1       // Nag-read.kaninang.umaga...
	      ctr += 1
	      loop
	   endif
	endif

        enddo

     endif	

     if lappend
        if file("TEMP.ID")
           ferase("TEMP.ID")
        endif
        nTemp:=fcreate("TEMP.ID")
        fseek(fhandle,0,FS_SET)

        if ctr > 0
	   ctr += 1
	endif
	   
	while ctr > 0
	  MsgAreaDisp("Reading to final RPT file...")

          cline:=space(1277)
          fread(fhandle,@cline,len(cline))

	  if substr(cline,1,4) == "CASH"
	     ctr := ctr - 1
	     if ctr <= 0
	        exit
	     endif	
	  endif   
	  
          fwrite(nTemp,cline,len(cline))

        enddo	

	fclose(fhandle)      // Erase.Rpt.file.to.change.it.to.new.one...
	ferase(".\"+cFileName)
        fhandle := fcreate( ".\"+cFilename, FC_NORMAL ) 	

	fseek(nTemp,0,FS_SET)
	while !feof(nTemp)
	   MsgAreaDisp("Writing to final RPT file...")

	   cline:=space(1277)
	   fread(nTemp,@cline,len(cline)) 
	   fwrite(fhandle,cline,len(cline))
	   
	enddo

	MsgAreaDisp("RPT Successfully transfered...")   
	fclose(nTemp)
	ferase("TEMP.ID")
        fseek( fhandle, 0, FS_END ) 
        cline:=padr("CASHIER Z-REPORT <"+padl(right(alltrim(config(POS_TERM_NUM)),4),4,"0")+">",1275)+CRLF
        fwrite( fhandle, cline, len(cline) )
        cline:=padr( cDate+ space(10) + subs(time(),1,5),1275) + CRLF
        fwrite( fhandle, cline, len(cline) )
        lappend:=.F.
     endif	

     nGross_Sales := (aData_[CS_DEPT_TOT] + aData_[CS_OINC_TOT] + aData_[CS_ADON_TOT])
                    // GS - TransVoid - Return - Refund - Disc. 
     nDaily_Sls := nGross_Sales - aData_[CS_TRVD_TOT] - ;
                   aData_[CS_REXC_TOT] - aData_[CS_RFND_TOT] - ;
		   (aData_[CS_IDSC_TOT] + aData_[CS_SDSC_TOT])

     //aData_[CS_NEWG_TOT] := aData_[CS_OLDG_TOT] + aData_[CS_DSLS_TOT]
     aData_[CS_NEWG_TOT] := aData_[CS_OLDG_TOT] + nDaily_Sls

     cBuffer := padl(alltrim(trans(aData_[CS_DSLS_KNT],"9999")),4,"0")
     cData += cBuffer
     cData += strim_pad(aData_[CS_DSLS_TOT])
     cash_sales := (aData_[CS_CASH_TOT] + aData_[CS_OINC_TOT] + ;
                    aData_[CS_PKUP_TOT] - aData_[CS_LOAN_TOT])
     cData += strim_pad(cash_sales)
     //nGross_Sales := (aData_[CS_DEPT_TOT] + aData_[CS_OINC_TOT] + aData_[CS_ADON_TOT])
     cData += strim_pad(nGross_Sales)
     cData += strim_pad(aData_[CS_DEPT_TOT])     
     cBuffer := padl(alltrim(trans(aData_[CS_FCUR_KNT],"9999")),4,"0")
     cData += cBuffer     
     cData += strim_pad(aData_[CS_FCUR_TOT])     
     cBuffer := padl(alltrim(trans(aData_[CS_MC01_KNT],"9999")),4,"0")
     cData += cBuffer
     cData += strim_pad(aData_[CS_MC01_TOT])          
     cBuffer := padl(alltrim(trans(aData_[CS_MC02_KNT],"9999")),4,"0")
     cData += cBuffer
     cData += strim_pad(aData_[CS_MC02_TOT])     
     cBuffer := padl(alltrim(trans(aData_[CS_MC03_KNT],"9999")),4,"0")
     cData += cBuffer
     cData += strim_pad(aData_[CS_MC03_TOT])     
     cBuffer := padl(alltrim(trans(aData_[CS_MC04_KNT],"9999")),4,"0")
     cData += cBuffer
     cData += strim_pad(aData_[CS_MC04_TOT])     
     cBuffer := padl(alltrim(trans(aData_[CS_MC05_KNT],"9999")),4,"0")
     cData += cBuffer
     cData += strim_pad(aData_[CS_MC05_TOT])     
     cBuffer := padl(alltrim(trans(aData_[CS_MC06_KNT],"9999")),4,"0")
     cData += cBuffer
     cData += strim_pad(aData_[CS_MC06_TOT])     
     cBuffer := padl(alltrim(trans(aData_[CS_MC07_KNT],"9999")),4,"0")
     cData += cBuffer
     cData += strim_pad(aData_[CS_MC07_TOT])     
     cBuffer := padl(alltrim(trans(aData_[CS_MC08_KNT],"9999")),4,"0")
     cData += cBuffer
     cData += strim_pad(aData_[CS_MC08_TOT])     
     cBuffer := padl(alltrim(trans(aData_[CS_MC09_KNT],"9999")),4,"0")
     cData += cBuffer
     cData += strim_pad(aData_[CS_MC09_TOT])     
     cBuffer := padl(alltrim(trans(aData_[CS_MC10_KNT],"9999")),4,"0")
     cData += cBuffer
     cData += strim_pad(aData_[CS_MC10_TOT])     
     cBuffer := padl(alltrim(trans(aData_[CS_MC11_KNT],"9999")),4,"0")
     cData += cBuffer
     cData += strim_pad(aData_[CS_MC11_TOT])     
     cBuffer := padl(alltrim(trans(aData_[CS_MC12_KNT],"9999")),4,"0")
     cData += cBuffer
     cData += strim_pad(aData_[CS_MC12_TOT])     
     cBuffer := padl(alltrim(trans(aData_[CS_MC13_KNT],"9999")),4,"0")
     cData += cBuffer
     cData += strim_pad(aData_[CS_MC13_TOT])     
     cBuffer := padl(alltrim(trans(aData_[CS_MC14_KNT],"9999")),4,"0")
     cData += cBuffer
     cData += strim_pad(aData_[CS_MC14_TOT])     
     cBuffer := padl(alltrim(trans(aData_[CS_MC15_KNT],"9999")),4,"0")
     cData += cBuffer
     cData += strim_pad(aData_[CS_MC15_TOT])     
     cBuffer := padl(alltrim(trans(aData_[CS_MC16_KNT],"9999")),4,"0")
     cData += cBuffer
     cData += strim_pad(aData_[CS_MC16_TOT])     
     cBuffer := padl(alltrim(trans(aData_[CS_MC17_KNT],"9999")),4,"0")
     cData += cBuffer
     cData += strim_pad(aData_[CS_MC17_TOT])     
     cBuffer := padl(alltrim(trans(aData_[CS_MC18_KNT],"9999")),4,"0")
     cData += cBuffer
     cData += strim_pad(aData_[CS_MC18_TOT])     
     cBuffer := padl(alltrim(trans(aData_[CS_MC19_KNT],"9999")),4,"0")
     cData += cBuffer
     cData += strim_pad(aData_[CS_MC19_TOT])     
     cBuffer := padl(alltrim(trans(aData_[CS_MC20_KNT],"9999")),4,"0")
     cData += cBuffer
     cData += strim_pad(aData_[CS_MC20_TOT])     
     cBuffer := padl(alltrim(trans(aData_[CS_MC21_KNT],"9999")),4,"0")
     cData += cBuffer
     cData += strim_pad(aData_[CS_MC21_TOT])          
     cBuffer := padl(alltrim(trans(aData_[CS_MC22_KNT],"9999")),4,"0")
     cData += cBuffer
     cData += strim_pad(aData_[CS_MC22_TOT])     
     cBuffer := padl(alltrim(trans(aData_[CS_MC23_KNT],"9999")),4,"0")
     cData += cBuffer
     cData += strim_pad(aData_[CS_MC23_TOT])     
     cBuffer := padl(alltrim(trans(aData_[CS_MC24_KNT],"9999")),4,"0")
     cData += cBuffer
     cData += strim_pad(aData_[CS_MC24_TOT])     
     cBuffer := padl(alltrim(trans(aData_[CS_MC25_KNT],"9999")),4,"0")
     cData += cBuffer
     cData += strim_pad(aData_[CS_MC25_TOT])     
     cBuffer := padl(alltrim(trans(aData_[CS_MC26_KNT],"9999")),4,"0")
     cData += cBuffer
     cData += strim_pad(aData_[CS_MC26_TOT])     
     cBuffer := padl(alltrim(trans(aData_[CS_MC27_KNT],"9999")),4,"0")
     cData += cBuffer
     cData += strim_pad(aData_[CS_MC27_TOT])     
     cBuffer := padl(alltrim(trans(aData_[CS_MC28_KNT],"9999")),4,"0")
     cData += cBuffer
     cData += strim_pad(aData_[CS_MC28_TOT])     
     cBuffer := padl(alltrim(trans(aData_[CS_MC29_KNT],"9999")),4,"0")
     cData += cBuffer
     cData += strim_pad(aData_[CS_MC29_TOT])     
     cBuffer := padl(alltrim(trans(aData_[CS_MC30_KNT],"9999")),4,"0")
     cData += cBuffer
     cData += strim_pad(aData_[CS_MC30_TOT])     
     cBuffer := padl(alltrim(trans(aData_[CS_MC31_KNT],"9999")),4,"0")
     cData += cBuffer
     cData += strim_pad(aData_[CS_MC31_TOT])     
     cBuffer := padl(alltrim(trans(aData_[CS_MC32_KNT],"9999")),4,"0")
     cData += cBuffer
     cData += strim_pad(aData_[CS_MC32_TOT])     
     cBuffer := padl(alltrim(trans(aData_[CS_MC33_KNT],"9999")),4,"0")
     cData += cBuffer
     cData += strim_pad(aData_[CS_MC33_TOT])     
     cBuffer := padl(alltrim(trans(aData_[CS_MC34_KNT],"9999")),4,"0")
     cData += cBuffer
     cData += strim_pad(aData_[CS_MC34_TOT])     
     cBuffer := padl(alltrim(trans(aData_[CS_MC35_KNT],"9999")),4,"0")
     cData += cBuffer
     cData += strim_pad(aData_[CS_MC35_TOT])     
     cBuffer := padl(alltrim(trans(aData_[CS_MC36_KNT],"9999")),4,"0")  
     cData += cBuffer
     cData += strim_pad(aData_[CS_MC36_TOT])     
     cBuffer := padl(alltrim(trans(aData_[CS_MC37_KNT],"9999")),4,"0")
     cData += cBuffer
     cData += strim_pad(aData_[CS_MC37_TOT])     
     cBuffer := padl(alltrim(trans(aData_[CS_MC38_KNT],"9999")),4,"0")
     cData += cBuffer
     cData += strim_pad(aData_[CS_MC38_TOT])     
     cBuffer := padl(alltrim(trans(aData_[CS_MC39_KNT],"9999")),4,"0")
     cData += cBuffer
     cData += strim_pad(aData_[CS_MC39_TOT])     
     cBuffer := padl(alltrim(trans(aData_[CS_MC40_KNT],"9999")),4,"0")
     cData += cBuffer
     cData += strim_pad(aData_[CS_MC40_TOT])
     cBuffer := padl(alltrim(trans(aData_[CS_MC41_KNT],"9999")),4,"0")
     cData += cBuffer
     cData += strim_pad(aData_[CS_MC41_TOT])          
     cBuffer := padl(alltrim(trans(aData_[CS_MC42_KNT],"9999")),4,"0")
     cData += cBuffer
     cData += strim_pad(aData_[CS_MC42_TOT])     
     cBuffer := padl(alltrim(trans(aData_[CS_MC43_KNT],"9999")),4,"0")
     cData += cBuffer
     cData += strim_pad(aData_[CS_MC43_TOT])     
     cBuffer := padl(alltrim(trans(aData_[CS_MC44_KNT],"9999")),4,"0")
     cData += cBuffer
     cData += strim_pad(aData_[CS_MC44_TOT])     
     cBuffer := padl(alltrim(trans(aData_[CS_MC45_KNT],"9999")),4,"0")
     cData += cBuffer
     cData += strim_pad(aData_[CS_MC45_TOT])     
     cBuffer := padl(alltrim(trans(aData_[CS_MC46_KNT],"9999")),4,"0")
     cData += cBuffer
     cData += strim_pad(aData_[CS_MC46_TOT])     
     cBuffer := padl(alltrim(trans(aData_[CS_MC47_KNT],"9999")),4,"0")
     cData += cBuffer
     cData += strim_pad(aData_[CS_MC47_TOT])     
     cBuffer := padl(alltrim(trans(aData_[CS_MC48_KNT],"9999")),4,"0")
     cData += cBuffer
     cData += strim_pad(aData_[CS_MC48_TOT])     
     cBuffer := padl(alltrim(trans(aData_[CS_MC49_KNT],"9999")),4,"0")
     cData += cBuffer
     cData += strim_pad(aData_[CS_MC49_TOT])     
     cBuffer := padl(alltrim(trans(aData_[CS_MC50_KNT],"9999")),4,"0")
     cData += cBuffer
     cData += strim_pad(aData_[CS_MC50_TOT])     
     cBuffer := padl(alltrim(trans(aData_[CS_VOID_KNT],"9999")),4,"0")
     cData += cBuffer
     cData += strim_pad(aData_[CS_VOID_TOT])     
     cBuffer := padl(alltrim(trans(aData_[CS_MGRV_KNT],"9999")),4,"0")
     cData += cBuffer
     cData += strim_pad(aData_[CS_MGRV_TOT])     
     cBuffer := padl(alltrim(trans(aData_[CS_IDSC_KNT],"9999")),4,"0")
     cData += cBuffer
     cData += strim_pad(aData_[CS_IDSC_TOT])     
     cBuffer := padl(alltrim(trans(aData_[CS_SDSC_KNT],"9999")),4,"0")
     cData += cBuffer
     cData += strim_pad(aData_[CS_SDSC_TOT])     
     cBuffer := padl(alltrim(trans(aData_[CS_ADON_KNT],"9999")),4,"0")
     cData += cBuffer
     cData += strim_pad(aData_[CS_ADON_TOT])     
     cBuffer := padl(alltrim(trans(aData_[CS_SESD_KNT],"9999")),4,"0")
     cData += cBuffer
     cData += strim_pad(aData_[CS_SESD_TOT])     
     cBuffer := padl(alltrim(trans(aData_[CS_SADO_KNT],"9999")),4,"0")
     cData += cBuffer
     cData += strim_pad(aData_[CS_SADO_TOT])     
     cBuffer := padl(alltrim(trans(aData_[CS_REXC_KNT],"9999")),4,"0")
     cData += cBuffer
     cData += strim_pad(aData_[CS_REXC_TOT])     
     cBuffer := padl(alltrim(trans(aData_[CS_RFND_KNT],"9999")),4,"0")
     cData += cBuffer
     cData += strim_pad(aData_[CS_RFND_TOT])     
     cBuffer := padl(alltrim(trans(aData_[CS_OINC_KNT],"9999")),4,"0")
     cData += cBuffer
     cData += strim_pad(aData_[CS_OINC_TOT])     
     cBuffer := padl(alltrim(trans(aData_[CS_TRCL_KNT],"9999")),4,"0")
     cData += cBuffer
     cData += strim_pad(aData_[CS_TRCL_TOT])     
     cBuffer := padl(alltrim(trans(aData_[CS_TRVD_KNT],"9999")),4,"0")
     cData += cBuffer
     cData += strim_pad(aData_[CS_TRVD_TOT])     
     cBuffer := padl(alltrim(trans(aData_[CS_TRSU_KNT],"9999")),4,"0")
     cData += cBuffer
     cData += strim_pad(aData_[CS_TRSU_TOT])     
     cBuffer := padl(alltrim(trans(aData_[CS_LAYA_KNT],"9999")),4,"0")
     cData += cBuffer
     cData += strim_pad(aData_[CS_LAYA_TOT])     
     cBuffer := padl(alltrim(trans(aData_[CS_PKUP_KNT],"9999")),4,"0")
     cData += cBuffer
     cData += strim_pad(aData_[CS_PKUP_TOT])     
     cBuffer := padl(alltrim(trans(aData_[CS_PDOT_KNT],"9999")),4,"0")
     cData += cBuffer
     cData += strim_pad(aData_[CS_PDOT_TOT])     
     cBuffer := padl(alltrim(trans(aData_[CS_LOAN_KNT],"9999")),4,"0")
     cData += cBuffer
     cData += strim_pad(aData_[CS_LOAN_TOT])     
     cBuffer := padl(alltrim(trans(aData_[CS_RONA_KNT],"9999")),4,"0")
     cData += cBuffer
     cData += strim_pad(aData_[CS_RONA_TOT])     
     cBuffer := padl(alltrim(trans(aData_[CS_BOTD_KNT],"9999")),4,"0")
     cData += cBuffer
     cData += strim_pad(aData_[CS_BOTD_TOT])  
     cData += strim_pad(aData_[CS_CIDR_TOT])        
     cData += strim_pad(aData_[CS_TRNG_TOT])
     cData += strim_pad(aData_[CS_OFFL_TOT])
     cData += strim_pad(aData_[CS_REEN_TOT])
     cData += strim_pad(aData_[CS_OLDG_TOT])     
     cData += strim_pad(aData_[CS_NEWG_TOT])     
     cBuffer := padl(alltrim(trans(aData_[CS_XCTR_TOT],"9999")),4,"0")
     cData += cBuffer
     cBuffer := padl(alltrim(trans(aData_[CS_ZCTR_TOT],"9999")),4,"0")
     cData += cBuffer         
     cData += CRLF

     fseek( fhandle, 0, FS_END)
     fwrite( fhandle, cData, len(cdata) )       
      
   next k       

   fclose( fhandle )
   
      
return .T.

function form_dept(lReset)
local fhandle := -1
local cFilename := "DEPT.RPT"
local cDate := strtran(dtoc(Term_nData(TR_DATE_NOW)),"-","/")
local nCounter,nTotals,k
local cData
local cIndata,cOutData
local status := NORMAL
local cHeader

  if empty( lReset )
     lReset := .F.
  endif   

/*
   // first copy the report file if it exist
   if File( GetReport_Path()+cFilename )
         __copyfile( GetReport_Path()+cFilename, ".\"+cFilename)
   endif 
*/   

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
   fwrite( fhandle, "DEPARTMENT Z-REPORT"+space(21)+"<"+padl(right(alltrim(config(POS_TERM_NUM)),4),4,"0")+">"+CRLF ,48)   
   fwrite( fhandle, cDate+ space(33) + subs(time(),1,5)+CRLF,48)
   cOutData := "0000"
   while status == NORMAL
     cIndata := space(DEPT_CNTR_SIZE)
     cHeader  := formHeader(FC_GETCNTR,FP_ZERO,FA_FN_DPT)    
     status := f_access(@cHeader,cOutdata,@cIndata,GetLocal_Path())
     
     if  status == NORMAL .or. status == 9
        // "Department " + cOutData +" Found !!!"
        // check if zero skip then if zero then skip  
        nCounter := realiee(subs( cIndata ,DEP_CNTR_OFF, DEP_CNTR_LEN))
        nTotals := realiee(subs( cIndata ,DEP_SALE_OFF, DEP_SALE_LEN))

        cData := subs(cIndata,DEP_CODE_OFF,DEP_CODE_LEN)
        cData += subs(cIndata,DEP_DESC_OFF,DEP_DESC_LEN) 
        cData += padl(alltrim(strtran(trans(nCounter,"9999999.999"),".","")),10,"0")
        cData += padl(alltrim(strtran(trans(nTotals, "9999999999.99"),".","")),12,"0")        
        cData += CRLF
        
        fwrite( fhandle, cData, len(cData) )
        
        if lReset

           cOutData := subs(cIndata,DEP_CODE_OFF,DEP_CODE_LEN)
           cOutData += ieereal(0)
           cOutData += ieereal(0)
           cOutData += ieereal(0)
   
           cInData := ""
           cHeader := formHeader(FC_PUTCNTR,FP_ONE,FA_FN_DPT)
           f_access(@cHeader,cOutData,@cIndata,GetLocal_Path())
           
        endif       
        
     endif
     cOutData := "++++"       
   enddo

   fclose( fhandle )

return .T.

function form_return(lReset)
local fhandle := -1
local cFilename := "RETURN.RPT"
local cDate := strtran(dtoc(Term_nData(TR_DATE_NOW)),"-","/")
local cData,cCode
local cIndata,cOutData
local status := NORMAL
local cHeader
local aRets_ := {}

   if empty(lReset)
      lReset := .F.
   endif   

/*
   // first copy the report file if it exist
   if File( GetReport_Path()+cFilename )
         __copyfile( GetReport_Path()+cFilename, ".\"+cFilename)
   endif 
*/   
   
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
   fwrite( fhandle, "RETURN ITEMS Z-REPORT"+space(35)+"<"+padl(right(alltrim(config(POS_TERM_NUM)),4),4,"0")+">"+CRLF ,64)   
   fwrite( fhandle, cDate+ space(49) + subs(time(),1,5)+CRLF,64)

   cOutData := repl("0",RET_PLUCODE_LEN)
   cHeader := formHeader(FC_GETFRST,FP_ZERO, FA_FN_RTN )
   cInData := space(RET_REC_SIZE)

   while status == NORMAL
     
    status := f_access(@cHeader,cOutData,@cIndata,GetLocal_Path())
       
    if status == NORMAL  // BTRIEVE_ENDOFFILE 

      cData := subs(cIndata,RET_PLUCODE_OFF,RET_PLUCODE_LEN)
      cData += subs(cIndata,RET_ITMCODE_OFF,RET_ITMCODE_LEN)
      cData += subs(cIndata,RET_PLUDESC_OFF,RET_PLUDESC_LEN)       
      cData += subs(cIndata,RET_DEPCODE_OFF,RET_DEPCODE_LEN)       
      
      cData += strtran(padl(realiee(subs(cIndata,RET_ITOTQTY_OFF,RET_ITOTQTY_LEN)),11,"0"),".","")
      
      cData += strtran(padl(realiee(subs(cIndata,RET_ITOTAMT_OFF,RET_ITOTAMT_LEN)),13,"0"),".","")
      cData += strtran(padl(realiee(subs(cIndata,RET_IUCOSTS_OFF,RET_IUCOSTS_LEN)),13,"0"),".","")
      cData += CRLF

      fwrite( fhandle, cData, len(cData) )      

      aAdd( aRets_ , subs(cIndata,RET_PLUCODE_OFF,RET_PLUCODE_LEN) )
    endif
    
    if status != NORMAL .and. status != 23
      MsgAreaDisp(" Unable to retrieve Return.IDX counter : "+str(status))
      error_log(" Unable to retrieve Return.IDX counter : "+str(status))
    endif   

    cHeader := formHeader(FC_GETNEXT,FP_ZERO, FA_FN_RTN )
    cInData := space(RET_REC_SIZE)
       
  enddo  

  fclose(fhandle)

  if lReset

    for status := 1 to len(aRets_)

       cOutData :=  aRets_[status]
       cHeader := formHeader(FC_SRCHDEL,FP_ONE,FA_FN_RTN)
       // reset status
       f_access(@cHeader,cOutData,@cIndata,GetLocal_Path())
           
    next
    
  endif
  
return .T.

/*
function Sales_To_Floppy(aFilename)
local status,lRetVal := .T.
local cKey,i,k
local cOutdata
local cIndata := "1"
local cDate := dtoc(date())
local cFilename 
local aChkFile := {}
                                         
  ScrollOff()             
  if get_password()    
     while .T.
        DISPTEXTXY(3,1,0,0,1,1,"INS. DISK ON DRIVE A")
        MsgAreaDisp("Enter to Confirm ...")
        cKey := input()
        if ckey == ENTER  
           if IsDrive("A")
              exit
           else
              MsgAreaDisp("* DRIVE NOT READY! *")
              tone(300,16)
              loop                                   
           endif   
        else
           exit
        endif
     enddo  
     if cKey == ENTER    
#ifdef KEY_SOUND
        set_key_sound(OFF)
#endif                           
        for i := 1 to len(aFilename)  
           if rat("\",aFilename[i]) > 0
             cFilename := subs(aFilename[i],rat("\",aFilename[i])+1)
           else 
             cFilename := aFilename[i]
           endif    
           __Copyfile(aFilename[i],"A:\"+cFilename)
           aAdd(aChkfile,"A:\"+cFilename)
           // check if all files are copied
        next
#ifdef KEY_SOUND  
        set_key_sound(ON)
#endif                               
        for i := 1 to len(aChkfile)
           if file(aChkfile[i])
              if rat("\",aFilename[i]) > 0              
                cFilename := subs(aFilename[i],1,rat("\",aFilename[i])+4)
              else
                cFilename := subs(aFilename[i],1,4)
              endif    
              cFilename += subs(cDate,1,2)+subs(cDate,4,2)+"."+subs(cDate,7,2)
              k := 0
              while file(cFilename+tran(k,"9")) .and. k < 10
                 k++
              enddo
              cFilename += tran(k,"9")
              frename(aFilename[i],cFilename)              
           else
              lRetVal := .F.
              exit              
           endif 
        next           
     else   
        ErrorDisp("REPORT GEN. ABORTED!")                            
        disp_clr()
        lRetVal := .F.
     endif   
  else
    lRetVal := .F.   
  endif                         
  ScrollOn()             

  if !lRetVal
     for i := 1 to len(aFilename)
       ferase(aFilename[i])
     next
  endif
  
return lRetVal
*/

function train_mode()
local choice := 0
local cWindow

   cWindow := OpenWindow(20, 34, 78, 66,"TRAINING MODE")

   if !nvr_lTRNG_Mode()

      gDrawText(49, 44, "WANT TO ENABLE  ", TRIPLEX_FONT, 3, CFG_DHLITE, MSCALE, CENTER_TEXT)
      gDrawText(55, 44, "TRAINING MODE ? ", TRIPLEX_FONT, 3, CFG_DHLITE, MSCALE, CENTER_TEXT)
     
      MsgAreaDisp("Use Arrow keys then ENTER... ")  
     
      while choice == 0
          choice := aLookUp(50,62,{"YES","NO"})
      enddo     
      
      MsgAreaDisp() // clear displays      

      if choice == 1
         nvr_lTRNG_Mode(.T.)
      else
         Tone(300,16)
      endif         
   
   else
  
      gDrawText(49, 44, "WANT TO DISABLE  ", TRIPLEX_FONT, 3, CFG_DHLITE, MSCALE, CENTER_TEXT)
      gDrawText(55, 44, "TRAINING MODE ? ", TRIPLEX_FONT, 3, CFG_DHLITE, MSCALE, CENTER_TEXT)
     
      MsgAreaDisp("Use Arrow keys then ENTER... ")  
     
      while choice == 0
         choice := aLookUp(50,62,{"YES","NO"})
      enddo     
      
      MsgAreaDisp()       

      if choice == 1
        nvr_lTRNG_Mode(.F.)
      else
        Tone(300,16)
      endif         
   endif  
   CloseWindow(cWindow)
return nil


function strim_pad(nData)
return padl(alltrim(strtran(trans(nData,"999999999.99"),".","")),12,"0")

static function Validate_Rpt(cFile)
local lvalid:=.F.
local lerase:=.F.
local nfile,ctr:=0
local cbuff,ntemp

  if file(cFile)
     nfile:=fopen(cFile,FO_READWRITE)
     fseek(nfile,0,FS_SET)

     while !feof(nfile)
     cbuff:=space(23)
     fread(nfile,@cbuff,len(cbuff))
     cbuff:=space(23)
     fread(nfile,@cbuff,len(cbuff))
     
     if substr(cbuff,1,8) != strtran(dtoc(Term_nData(TR_DATE_NOW)),"-","/")
        while !feof(nfile)
	cbuff:=space(23)
        fread(nfile,@cbuff,len(cbuff))
	if substr(cbuff,1,3) == "081"
	   ctr += 1
	   lvalid:=.F.
	   exit
	endif
	enddo
     else                    //same.date...
        while !feof(nfile)
	cbuff:=space(23)
        fread(nfile,@cbuff,len(cbuff))
	if substr(cbuff,1,3) == "081"
	   if val(substr(cbuff,6,6)) == Term_nData(TR_ZCTR_TOT)
    	   lvalid:=.F.
	   lerase:=.T.
	   exit
	   else
	   lvalid:=.T.
	   lerase:=.F.
	   ctr+=1
	   endif
	endif
	enddo
     endif

     if lerase .or. feof(nfile)
        exit
     endif

     enddo

     if file("TEMP.ID")
        ferase("TEMP.ID")
     endif
     nTemp:=fcreate("TEMP.ID")
     fseek(nfile,0,FS_SET)

     if lvalid
        while ctr > 0
        cbuff:=space(23)
	fread(nfile,@cbuff,len(cbuff))
	if substr(cbuff,1,3) == "081"
	   ctr -= 1
	   if ctr <= 0 .or. feof(nfile)
	      exit
	   endif
	endif
        fwrite(nTemp,cbuff,len(cbuff))	
	enddo
        fclose(nFile)
	ferase(cFile)
	
	nFile:=fcreate(cFile)
        fseek(nTemp,0,FS_SET)
        while !feof(nTemp)
  	   cbuff:=space(23)
	   fread(nTemp,@cbuff,len(cbuff))
	   fwrite(nFile,cbuff,len(cbuff))
	enddo
     endif	

     if lerase
        //erase.all.rpt.with.the.same.date...
     endif             
     
  endif	
     
return .T.
/* eof */
