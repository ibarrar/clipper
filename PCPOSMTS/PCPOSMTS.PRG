/*============================================================================

   (c) 1995 FEMA BUSINESS SYSTEMS CORPORATION

   This module contains information proprietary to FEMA BUSINESS SYSTEMS
   CORPORATION, and should be treated confidential.

   PCPOSMTS.PRG - top module for Inventory Tracking System (MTS) FOR PCPOS
        Module for demo purposes only (Not for sale ....!)

   RCI / 10.20.95

============================================================================*/
#include "inkey.ch"
#include "setcurs.ch"
#include "set.ch"
#include "Janus.ch"
#include "box.ch"
#include "its.ch"
#include "fileio.ch"

#undef  SERIAL
#ifndef DEMO // DEMO is defined in ITS.ch
 #define  DEMO
#endif 
#define ACTIVE

#define FILL_CHAR chr(176)
#define BACK_COL if(IsColor(),"B/W","N+/W")

#define DATA_PATH  chr(65+curdrv())+":\"+curdir()+"\"   

#define DEFAULT_PATH   "MTSDATA"
#define WAREHOUSE_PATH "MTSDATA.000"
#define BACKUP_PATH   "BACKUP"
#define DOWN_PATH   "DOWNLOAD"
#define UP_PATH   "UPLOAD"

#define FOREIGN

#define A_ABOUT      01000
#define A_ALERT      01010
#define A_SELEC      01020  
#define A_EXIT       01030  

#define PF_DEPARTM   02020
#define PF_CLASS     02030
#define PF_CASHIER   02040
#define PF_CLERK     02050
#define PF_ITEMS     02060
#define PF_FORCUR    02070
#define PF_FMFILE    02080
#define PF_UPDTDBF   02090
#define PF_READPOS   02091
#define PF_IMPORT    02092
#define PF_ONLINE    02093
#define PF_CARD      02094

#define IF_VENDORS   02010
#define IF_BRAND     02011
#define IF_PCOUNT    03010 
#define IF_PURCORD   03020
#define IF_STCKREC   03030
#define IF_STCKRET   03040
#define IF_STCKADJ   03050
#define IF_STCKTRN   03060

#define R_FLASH      04010
#define R_PLU        04020
#define RFS_DEPT     04030
#define RFS_VPRV     04090
#define RFS_BRMV     04091
#define RFS_ITMV     04092
#define RFS_CHPR     04093
#define RFS_ILR      04080
#define RFS_ILRD     04081
#define RFS_ILRB     04082
#define RFS_DSR      04070
#define RFS_ADSR      04071
#define RFS_RDSR      04072
#define RFS_CONC     04040
#define RF_PLU       04050
#define RFA_PLU      04051
#define RFP_PLU      04052
#define RFA_FPLU     04053
#define RFA_FMQ     04057
#define RFA_FMA     04058
#define RFA_SPLU     04054
#define RFA_SMQ     04059
#define RFA_SMA     04060
#define NF_PLU       04055
#define NF_CONCESS   04056
#define NF_ACONC     04157
#define NF_PCONC     04158

#define NF_CONSIGN   04061
#define NF_ACONS     04062
#define NF_PCONS     04163

#define RS_CLERK     06020
#define R_TERM       06021
#define R_CTERM      06022
#define R_ITERM      06023
#define R_CASH       06024
#define R_CCASH      06025
#define R_ICASH      06026
#define R_HOUR       06027
#define R_CHOUR      06028
#define R_IHOUR      06029

#define RS_STORE     06030
#define RS_TERM      06035
#define RS_CASHIER   06031
#define R_CACT       06033
#define R_IACT       06034
#define R_CALL       06036
#define RS_CREDITC   06140
#define R_CREDITC   06141
#define R_CREDITI   06142
#define R_CREDITA   06143
#define R_AACT      06036 //bing
           
#define R_INVEN      05010
#define RI_INVEN     05020
#define RI_PHYSIC    05040
#define RI_PURORD    05050
#define RI_DELIVR    05060
#define RD_PSUP      05061
#define RD_ASUP      05062
#define RI_STKRET    05070
#define RT_PSUP      05071
#define RT_ASUP      05072
#define RI_STKADJ    05080
#define ADJ_PSUP     05081
#define ADJ_ASUP     05082
#define RI_STKTRN    05090
#define TRN_PSUP     05091
#define TRN_ASUP     05092
#define RI_STKSTS    05100
#define STS_PSUP     05101
#define STS_ASUP     05102
#define RI_STKOUT    05110
#define SO_PSUP      05111
#define SO_ASUP      05112
#define RI_STKREO    05120
#define REO_PSUP     05121
#define REO_ASUP     05122
#define RI_STKINV    05130
#define STK_PSUP     05131
#define STK_ASUP     05132
#define RI_INVVAR    05140
#define RIV_PSUP     05141
#define RIV_ASUP     05142

#define R_DIREC      07010
#define RD_VENDIR    07020
#define RD_ITMDIR    07030
#define RID_PSUP     07031
#define RID_ASUP     07032
#define RD_CLSDIR    07040
#define RD_DPTDIR    07050
#define RD_ALLDIR    07060
 
#define P_DPOST      09010
#define I_DPOST      09011
#define S_DPOST      09012
#define P_MPOST      09020
#define P_APOST      09030

#define U_UNITS      10010
#define U_REINDEX    10020 
#define U_BACKUP     10030
#define U_RESTORE    10040
#define U_DELETE     10050
#define U_DELDBF     10060
#define U_DOWN       10070
#define U_UP         10080
#define U_NFND       10090
#define U_RDOWN      10100  //jzo

#ifdef COLOR_STAT
#define BAR "F10-Menu   Alt_U-Unit Select   Alt_X-Exit"
#else
#define BAR "F10-Menu   Alt_U-Unit Select   Alt_X-Exit"
#endif
memvar dToday, GetList, dStartDate, dEndDate, nUnit, password

static cMainColor := "R/W,W+/R,,N/W,N/W"
static cRecColor  := "B/W,W+/B,,N/B,N/B"
static cCMDVColor := "GR/W,GR+/GR,,N/W,N/W"

static hBar,hAboutMenu,hPosFileMenu,hReportMenu,hUtilMenu,hUtilityMenu
static hInvFileMenu,hQSupMenu,hMPostMenu,hTRnMenu,hCashMenu
static hDirecMenu,hMonthMenu,hPeriodMenu,hFlashMenu,hInvenMenu,hSalesMenu
static hItemMenu,hTermMenu,hHourMenu,hSupMenu, hRtSupMenu, hReoSupMenu,hAdjMenu
static hSoSupMenu, hStkSupMenu, hIdSupMenu, hIvSupMenu, hStsSupMenu, hDpostMenu
static hMSupMenu,hMRtSupMenu,hMReoSupMenu,hMSoSupMenu,hMStkSupMenu,hMIvSupMenu,hMStsSupMenu
static hChargeMenu,hCasActMenu,hFIMenu,hSIMenu,hILRDMenu,hConcMenu,hConsMenu
static hDlyslsMenu

function Main()
local nChoice,nox,noy,cOriginal
local exitRequested:=.f.
local ans := "Y", aDbf := {}
local verify, sdate := date(), vBrowse, ncntrl := 0
public dStartDate, dEndDate, nUnit := 0, password

// added july 29, 1995 getserial
#ifdef SERIAL
 verify := verifysrl()

 if verify == 1
   ? "Sorry must run this software on hard disk..."
   ?
   quit
 elseif verify == 2
   ? "Unauthorized Copy..."
   ?
   quit
 elseif verify != 0
   ? " Serial Internal Error..." + str(verify)
   ?
   quit
 endif
#endif

// Check System Date and Time
   ? SYS_TITLE
   ?
   tone (  900, 1 )
   tone ( 1500, 1 )
   
   dToday := date ()
   ? " Today is " + dtoc ( dToday )
   ? " The time is " + time()
   ?
   @ row(), 0 say  " Is this correct? (y/n) " get ans picture "Y"
   read
   
   IF ( upper (ans) != 'Y' .or. Lastkey() == K_ESC )
      tone ( 300, 1 )
      ?
      tone ( 250, 1 )
      ? "Please adjust the system date and time."
      tone ( 200, 2 )
      ?
      tone ( 150, 1 )
      RETURN (-1)
   ENDIF
      
   secure()   
   
   if !InitPass()
      ?
      return -1
   endif 
   
   ?
   ? "  Starting up system.  Please wait ..."
   
#ifdef MAKE_DATA

   if l_mkdir ( DEFAULT_PATH ) == 0  // Create the central subdirectory.

      // No central & warehouse yet. First installation.

      // Go to the central subdirectory.
      l_chdir ( DEFAULT_PATH )

      aDbf := makedbf1() // Create the array entries.
      createdbf ( aDbf, 0 ) // Create the DBFs.
      createntx ( aDbf, 0 ) // Create the NTXes.

           // Go back to the work directory.
      l_chdir ( ".." )
   endif
      
   if l_mkdir ( WAREHOUSE_PATH ) == 0  // Create the central subdirectory.
   
      // Go to the warehouse subdirectory.
      l_chdir ( WAREHOUSE_PATH )
      
      aDbf := makedbf2() // Create the array entries.
      createdbf ( aDbf, 0 ) // Create the DBFs.
      createntx ( aDbf, 0 ) // Create the NTXes.

      // Go back to the work directory.
      l_chdir ( ".." )
            
   endif

   if l_mkdir ( BACKUP_PATH ) == 0  // Create the central subdirectory.
   
      // Go to the warehouse subdirectory.
      l_chdir ( BACKUP_PATH )
      
      // Go back to the work directory.
      l_chdir ( ".." )
   endif

   if l_mkdir ( DOWN_PATH ) == 0  // Create the central subdirectory.
   
      // Go to the warehouse subdirectory.
      l_chdir ( DOWN_PATH )
      
      // Go back to the work directory.
      l_chdir ( ".." )
   endif

   if l_mkdir ( UP_PATH ) == 0  // Create the central subdirectory.
   
      // Go to the warehouse subdirectory.
      l_chdir ( UP_PATH )
      
      // Go back to the work directory.
      l_chdir ( ".." )
   endif
   
   if l_mkdir("BACKUP") == 0  // Create back-up for download data...
   endif
   
#endif
   
   ?? "   Done."

   aDbf := {} // Free this loaded variable after use

   set (_SET_DEFAULT,DATA_PATH+DEFAULT_PATH+"\")   
   
   set(_SET_SCOREBOARD,.F.)
   set(_SET_WRAP,.T.)
   set(_SET_PATH,DATA_PATH+WAREHOUSE_PATH+"\")
   set(_SET_DATEFORMAT,"mm-dd-yy")
   set(_SET_DELETED,.F.)
   set(_SET_EXACT,.T.)
   set(_SET_SOFTSEEK,.T.)
   set(_SET_CONFIRM,.T.)
   setcancel(.f.)             // disable alt-c
   setcursor(SC_NONE)
   readinsert(.F.)
   nOx := col() ; nOy :=row()
   cOriginal := SetColor(cMainColor)
   cls
   _logo()
   heading(SYS_TITLE)
   SetColor(DATA_COLORS)
   setCursor(SC_NONE)
   createbar()
   bardisplay(hBar)
   About()
   MsgBar(BAR)
   message(,nUnit)      
   baractivate(hBar,K_F10)
   nChoice := BarMenuChoice(hBar)
   do while nChoice != A_EXIT
      if lastkey()!=K_ESC .and. lastkey() != K_LEFT .and. lastkey() != K_RIGHT
         do case
            case nChoice == A_ABOUT
                 _logo()
                 About()                 
            case nChoice == A_ALERT
                 Security()

#ifdef ACTIVE    
   DO CASE
       
      CASE whatlevel() == 2  
         Promptgray(hAboutMenu, A_ALERT, "~Security      ")
         PromptgrayLine(hAboutMenu)


         // Inventory Files
   
         Promptgray(hInvFileMenu,IF_PCOUNT, "~Physical Count    ") 
         Promptgray(hInvFileMenu,IF_PURCORD,"Purchase ~Order    ")
         Promptgray(hInvFileMenu,IF_STCKREC,"Stock ~Deliveries  ")
         Promptgray(hInvFileMenu,IF_STCKRET,"Stock ~Returns     ")
         Promptgray(hInvFileMenu,IF_STCKADJ,"Stock ~Adjustments ")
         Promptgray(hInvFileMenu,IF_STCKTRN,"Stock ~Transfers   ")   

         PromptgraySub(hReportMenu,R_INVEN,hInvenMenu)
         PromptgraySub(hInvenMenu,RI_DELIVR,hSupMenu)
         PromptgraySub(hInvenMenu,RI_STKRET,hRtSupMenu)
         PromptgraySub(hInvenMenu,RI_STKADJ,hAdjMenu)  
         PromptgraySub(hInvenMenu,RI_STKTRN,hTrnMenu)  
         PromptgraySub(hInvenMenu,RI_STKSTS,hStsSupMenu)
         PromptgraySub(hInvenMenu,RI_STKOUT,hSoSupMenu)
         PromptgraySub(hInvenMenu,RI_STKREO,hReoSupMenu)
         PromptgraySub(hInvenMenu,RI_STKINV,hStkSupMenu)
         PromptgraySub(hInvenMenu,RI_INVVAR,hIvSupMenu)

         //Utilities
         Promptgray(hUtilMenu,U_UNITS,  "~Unit Maintenance ")
         PromptgrayLine(hUtilMenu)
         Promptgray(hUtilMenu,U_BACKUP ,"~Backup      ")
         Promptgray(hUtilMenu,U_RESTORE,"Re~store     ")
         Promptgray(hUtilMenu,U_DELETE,"~Delete Files ")

      CASE whatlevel() == 3  

         // POS Files
         Promptgray(hPosFileMenu,IF_VENDORS,"~Supplier          ")   
         Promptgray(hPosFileMenu,PF_DEPARTM,"~Department        ")
         Promptgray(hPosFileMenu,PF_ITEMS,  "~Items             ")           
         PromptgrayLine(hPosFileMenu)
         Promptgray(hPosFileMenu,PF_CASHIER,"C~ashier           ")
         Promptgray(hPosFileMenu,PF_CARD,   "C~redit Card       ")
      CASE whatlevel() == 4  
         // Add Prompts
         // About Menu
         Promptgray(hAboutMenu, A_ALERT, "~Security      ")
         PromptgrayLine(hAboutMenu)

         // POS Files
         Promptgray(hPosFileMenu,IF_VENDORS,"~Supplier          ")   
         Promptgray(hPosFileMenu,PF_DEPARTM,"~Department        ")
         Promptgray(hPosFileMenu,PF_ITEMS,  "~Items             ")           
         PromptgrayLine(hPosFileMenu)
         Promptgray(hPosFileMenu,PF_CASHIER,"C~ashier           ")
         Promptgray(hPosFileMenu,PF_CARD,   "C~redit Card       ")
         PromptgrayLine(hPosFileMenu)
         Promptgray(hPosFileMenu,PF_READPOS,"A~pply End of Day  ")
         Promptgray(hPosFileMenu,PF_IMPORT, "Imp~ort Data (POS) ")
	   //jzo04-18-98         Promptgray(hPosFileMenu,PF_ONLINE, "Monitor ~Transaction ")
         Promptgray(hPosFileMenu,PF_FMFILE, "F~M File           ")
   
         // Reports
         PromptgraySub(hReportMenu,R_FLASH,hFlashMenu)
         PromptgraySub(hFlashMenu,R_PLU,hQSupMenu)
         PromptgraySub(hFlashMenu,R_TERM,hTermMenu)
         PromptgraySub(hFlashMenu,R_CASH,hCashMenu)
         PromptgraySub(hFlashMenu,R_HOUR,hHourMenu)
         Promptgray(hFlashMenu,RFS_DEPT,"~Department Sales ")
         Promptgray(hFlashMenu,RFS_CONC,"~Supplier Summary Report")

         PromptgraySub(hFlashMenu,RS_CREDITC,hChargeMenu)         
         Promptgray(hFlashMenu,RS_TERM,"Ter~minal Accountability")           
         Promptgray(hFlashMenu,RS_STORE,"Sto~re Accountability")           
         PromptgraySub(hFlashMenu,RS_CASHIER,hCasActMenu)           

         //Utilities
         Promptgray(hUtilMenu,U_UNITS,  "~Unit Maintenance ")
         PromptgrayLine(hUtilMenu)
         Promptgray(hUtilMenu,U_REINDEX,"~Reindex All ")   
         Promptgray(hUtilMenu,U_BACKUP ,"~Backup      ")
         Promptgray(hUtilMenu,U_RESTORE,"Re~store     ")
         Promptgray(hUtilMenu,U_DELETE,"~Delete Files ")

      
      CASE whatlevel() == 5  
         // gray Prompts
         // About Menu
         Promptgray(hAboutMenu, A_ALERT, "~Security      ")
         PromptgrayLine(hAboutMenu)
         
         // Inventory Files
   
         Promptgray(hInvFileMenu,IF_PCOUNT, "~Physical Count    ") 
         Promptgray(hInvFileMenu,IF_PURCORD,"Purchase ~Order    ")
         Promptgray(hInvFileMenu,IF_STCKREC,"Stock ~Deliveries  ")
         Promptgray(hInvFileMenu,IF_STCKRET,"Stock ~Returns     ")
         Promptgray(hInvFileMenu,IF_STCKADJ,"Stock ~Adjustments ")
         Promptgray(hInvFileMenu,IF_STCKTRN,"Stock ~Transfers   ")   
         PromptgraySub(hReportMenu,R_INVEN,hInvenMenu)
         PromptgraySub(hInvenMenu,RI_DELIVR,hSupMenu)
         PromptgraySub(hInvenMenu,RI_STKRET,hRtSupMenu)
         PromptgraySub(hInvenMenu,RI_STKADJ,hAdjMenu)  
         PromptgraySub(hInvenMenu,RI_STKTRN,hTrnMenu)  
         PromptgraySub(hInvenMenu,RI_STKSTS,hStsSupMenu)
         PromptgraySub(hInvenMenu,RI_STKOUT,hSoSupMenu)
         PromptgraySub(hInvenMenu,RI_STKREO,hReoSupMenu)
         PromptgraySub(hInvenMenu,RI_STKINV,hStkSupMenu)
         PromptgraySub(hInvenMenu,RI_INVVAR,hIvSupMenu)

         //Periodic Updates
         Promptgray(hPeriodMenu,S_DPOST,"~Sales Posting")
         Promptgray(hPeriodMenu,I_DPOST,"~Inventory Posting")
         Promptgray(hPeriodMenu,P_MPOST,"~Monthly Closing")
         Promptgray(hPeriodMenu,P_APOST,"~Annual Closing  ")     
   

         //Utilities
         Promptgray(hUtilMenu,U_UNITS,  "~Unit Maintenance ")
         PromptgrayLine(hUtilMenu)
         Promptgray(hUtilMenu,U_BACKUP ,"~Backup      ")
         Promptgray(hUtilMenu,U_RESTORE,"Re~store     ")
         Promptgray(hUtilMenu,U_DELETE,"~Delete Files ")

   ENDCASE   
   

      
#endif  
            case nChoice == A_EXIT
                 message("Good Bye...",nUnit)
                 
            case nChoice == PF_DEPARTM
                 do_Depart()
            case nChoice == PF_CARD
                 do_card()
            case nChoice == PF_ONLINE
                 Monitor()     
            case nChoice == PF_ITEMS
              if pass() == password
                do_Items()         
              else
                BUMMER();BUMMER()
                alert("Access denied invalid password ",{"Abort"})   
              endif            
            case nChoice == PF_CASHIER
                 do_Cashier()     
            case nChoice == PF_FMFILE    
                 fmfile()
	       case nChoice == PF_FORCUR		  
		       do_Foreign()
            case nChoice == IF_VENDORS
                 do_Vendor()                
            case nChoice == IF_BRAND
                 do_brand()                                 
            case nChoice == IF_PCOUNT
                 do_PCount()     
            case nChoice == IF_PURCORD
                 do_PO()
            case nChoice == IF_STCKREC
                 do_StkReceipt()
            case nChoice == IF_STCKRET
                 do_StkReturn()
            case nChoice == IF_STCKADJ
                 do_StkAdjust()                 
            case nChoice == IF_STCKTRN
                 do_StkTransfer()     
            case nChoice == PF_READPOS 
                  GetData() 
            case nChoice == PF_IMPORT
                 SET CURSOR ON
                vBrowse := OpenWindow(10,30,12,50," ")
                @ 10,35 say "DATE ENTRY "
                @ 11,33 say "Date: "Get sdate
                read
                if lastkey() == K_ESC
                    SET CURSOR OFF
                    CloseWindow(vBrowse)
                    // return nil
                endif   
   
                SET CURSOR OFF
                CloseWindow(vBrowse)
                if lastkey() != K_ESC
                tone ( 2000, 1 )
                if netuse("CNTRL", DB_SHARED, NUM_SECONDS)
                   SET INDEX TO CNTRL,CDATE
                   CNTRL->(DbGoBottom())
                   ncntrl := CNTRL->CONTRL_NO  
                   CNTRL->(RecLock(0))
                   CNTRL->(DbAppend())
                   CNTRL->CONTRL_NO := nCntrl + 1
                   CNTRL->DATE      := sdate
                   CNTRL->OP_FLAG   := 1
                   CNTRL->(DbUnLock())
                   CNTRL->(DbCloseArea())               
                endif    
                
                 plu_imp(sdate)   
                 term_imp(sdate)
                 cash_imp(sdate)
                 dept_imp(sdate)
                 hour_imp(sdate) 
                 ret_imp(sdate)
                 //ccd_imp(sdate)
                 itemv_imp()
                 reindex()
               endif
                 
// This consecutive sequences are of reports modules 
            case nChoice == R_CTERM
					  rCTerm()
            case nChoice == R_ITERM
					  rIterm()     
            case nChoice == R_CCASH
					  rCCashier()
            case nChoice == R_ICASH
					  rICashier()          
            case nChoice == R_CHOUR
					  rChour()
            case nChoice == R_IHOUR
					  rIhour()               
            case nChoice == RFS_DEPT
					  rDept()
            case nChoice == RFS_VPRV
					  voidprev()
            case nChoice == RFS_BRMV
					  br_moven()
            case nChoice == RFS_ITMV
					  br_movei()
            case nChoice == RFS_CHPR
					  changepr()                                          
            case nChoice == RFS_ILRD
					  ItLstDP()                 
            case nChoice == RFS_ILRB
					  ItLstBr()                                  
            case nChoice == RFS_ADSR
					  dlyslsrpt()               
            case nChoice == RFS_DSR
					  r_slsrpt()
/*            case nChoice == RFS_CONC
                 rSupplier()*/
            case nChoice == RFA_PLU
                 RItem()
            case nChoice == RFP_PLU
                 RPitem()     
            case nChoice == RFA_FMQ
                 RFItem()
            case nChoice == RFA_FMA
                 RFAmt()                 
            case nChoice == RFA_SMQ
                 RSItem()
            case nChoice == RFA_SMA
                 RSAmt()
            case nChoice == NF_PLU
                 NFItem()   
	    case nChoice == NF_ACONC
	    	 r_Concess()
	    case nChoice == NF_PCONC
	    	 p_Concess()          
	    case nChoice == NF_ACONS
	    	 r_Consign()
	    case nChoice == NF_PCONS
	    	 p_Consign()          
            case nChoice == R_CREDITC
                 do_R_Credit() 
            case nChoice == R_CREDITI
                 do_I_Credit() 
            case nChoice == R_CREDITA
                 do_A_Credit()           
                 
            case nChoice == R_CACT 
                 Cash_Acct()
            case nChoice == R_IACT 
                 Cash_IAcct()    
            case nChoice == R_CALL
                 Cash_All()         
            case nChoice == RS_STORE
                 Store_Acct()
            case nChoice == RI_PURORD
                  it3100(21)            
            case nChoice == RD_PSUP
                   it3100(1)
            case nChoice == RD_ASUP
                   it3100(2)  
            case nChoice == RT_PSUP
                   it3100(3)
            case nChoice == RT_ASUP
                   it3100(4)       
            case nChoice == TRN_PSUP
                   do_PR_StkTrn()
            case nChoice == TRN_ASUP
                   do_R_StkTrn()       
            case nChoice == STS_PSUP
                   it3100(5)
            case nChoice == STS_ASUP
                   it3100(20)       
            case nChoice == SO_PSUP
                   it3100(6)
            case nchoice == SO_ASUP
                   it3100(17)       
            case nChoice == REO_PSUP
                   it3100(7)
            case nChoice == REO_ASUP
                   it3100(8)       
            case nChoice == ADJ_PSUP
                   it3100(9)     
            case nChoice == ADJ_ASUP
                   it3100(22)            
            case nChoice == STK_PSUP
                   it3100(10)
            case nChoice == STK_ASUP
                   it3100(18)       
            case nChoice == RIV_PSUP
                   it3100(11)
            case nChoice == RIV_ASUP
                   it3100(19)       
            case nChoice == RS_CREDITC
                 do_R_Credit() 
            case nChoice == RD_VENDIR
                 it3200(1)
            case nChoice == RID_PSUP
                   it3200(2)
            case nChoice == RID_ASUP
                  it3200(7)       
            case nChoice == RD_DPTDIR
                 it3200(5)
            case nChoice == RD_ALLDIR
                 it3200(6)
            case nChoice == I_DPOST // Inventory Posting
                 if alert(" Daily Posting Routine;"+;
                 " closes sales transaction for the day  ;"+;
                 " Proceed ?", {" Proceed "," Cancel "}) == 1
                   IDailyPost()   // Daily Posting
                 endif  
            case nChoice == S_DPOST // Sales Posting
                 if alert(" Daily Posting Routine;"+;
                 " closes sales transaction for the day  ;"+;
                 " Proceed ?", {" Proceed "," Cancel "}) == 1
                   SDailyPost()   // Daily Posting
                 endif                   
            case nChoice == P_MPOST
                 if alert(" Monthly Posting Routine;"+;
                 " closes sales transaction for the month;"+;
                 " Proceed ?", {" Proceed "," Cancel "}) == 1
                 MClosing()   // Monthly Posting
                 endif     
            case nChoice == P_APOST
                 if alert(" Annual Posting Routine;"+;
                 " closes sales transaction for the year ;"+;
                 " Proceed ?", {" Proceed "," Cancel "}) == 1            
                 AClosing()   // Annual Posting
                 endif
                 
            case nChoice == U_UNITS
                 do_units()          
            case nChoice == U_REINDEX
                 Reindex()
            case nChoice == U_BACKUP
                 REPOST()
            case nChoice == U_RESTORE
                 RETRV()
            case nChoice == U_DELETE
                 alis()     
            case nChoice == U_DELDBF
                 Reset()          
            case nChoice == U_DOWN
                 DownLoad()               
            case nChoice == U_UP
                 UpLoad()                    
            case nChoice == U_NFND
	         do_nplu()		 
            case nChoice == U_RDOWN   //jzo
                 ReDownLoad()                           

         endcase
      endif
      MsgBar(BAR)
      message(,nUnit)
      nChoice := BarMenuChoice(hBar,0)
      nChoice := baractivate(hBar)
   enddo
   readinsert(.F.)
   setCursor(SC_NORMAL)
   setcolor(cOriginal)
   set(_SET_EXACT,.T.)
   set(_SET_DELETED,.F.)
   set(_SET_SCOREBOARD,.T.)
   cls
   Setpos(nOy,nOx)
   ? " "+SYS_TITLE
return nil

static function CreateBar()
   // Create empty Bat Menu
   hBar := BarNew()
   // Create empty Menus
   hAboutMenu   := MenuNew("~"+chr(240))   
   hPOSFileMenu := MenuNew("POS ~Files")
   hInvFileMenu := MenuNew("~Inventory")
   hReportMenu  := MenuNew("~Reports")
   hPeriodMenu  := MenuNew("~Posting")
   hUtilMenu    := MenuNew("~Maintenance")

//jzo04-18-98   hUtilityMenu := MenuNew("Uti~lity")

   hFlashMenu   := MenuNew("~Accounting Reports ") 
   hInvenMenu   := MenuNew("~Merchandizing Reports    ")

//jzo04-18-98   hHourMenu    := MenuNew("~Hourly Sales Report ")

   hDirecMenu   := MenuNew("~Directories  ")

//jzo04-18-98   hTermMenu    := MenuNew("~Terminal Reports  ")
//jzo04-18-98     hCashMenu    := MenuNew("~Cashier Reports  ")

   hSupMenu     := MenuNew("Stock ~Deliveries  ")
   hRtSupMenu   := MenuNew("Stock ~Returns     ")
   hAdjMenu     := MenuNew("Stock ~Adjustment  ")
   hTRNMenu     := MenuNew("Stock ~Transfer    ")
   hReoSupMenu  := MenuNew("Stock R~eOrder     ")
   hSoSupMenu   := MenuNew("Stock O~ut Report  ")
   hStkSupMenu  := MenuNew("Stock A~ging Report ")
   hIdSupMenu   := MenuNew("~Item Directory   ")
   hIvSupMenu   := MenuNew("~Inventory Variance Report ")
   hStsSupMenu  := MenuNew("Stock ~Level Report  ")
   hDpostMenu   := MenuNew("~Daily Posting        ")
   hQSupMenu    := MenuNew("~Item Sales Report   ")
   hConcMenu    := MenuNew("~Concessionaire   ")
   hConsMenu    := MenuNew("Consi~gnment    ")
   hCasActMenu    := MenuNew("Cashier ~Accountability")
   hChargeMenu  := MenuNew("Char~ge Sales Report")
   hFIMenu       := MenuNew("~Fast Moving Items")
   hSIMenu       := MenuNew("~Slow Moving Items")
   hILRDMenu     := MenuNew("I~tem List Report")

//   hDlyslsMenu  := MenuNew("Dail~y Sales Report")
   
   // Add Prompts
   // About Menu
   PromptAdd(hAboutMenu, A_ABOUT, "~About         ")
   PromptAdd(hAboutMenu, A_ALERT, "~Security      ")
   PromptAdd(hAboutMenu, A_SELEC, "Select ~Unit  Alt-U ")      
   PromptAction(hAboutMenu,A_SELEC, { || WhatUnit() })
   PromptAddLine(hAboutMenu)
   PromptAdd(hAboutMenu, A_EXIT,  "E~xit   Alt-X  ")

   // POS Files
   PromptAdd(hPosFileMenu,IF_VENDORS,"~Supplier          ")   
   PromptAdd(hPosFileMenu,IF_BRAND,   "~Brand             ")   
   PromptAdd(hPosFileMenu,PF_DEPARTM,"~Department        ")
#ifdef CLASS_LINK
   PromptAdd(hPosFileMenu,PF_CLASS,  "~Class             ")   
#endif   
   PromptAdd(hPosFileMenu,PF_ITEMS,  "~Items             ")           
   PromptAddLine(hPosFileMenu)
   PromptAdd(hPosFileMenu,PF_CASHIER,"C~ashier           ")
#ifdef CLERK   
//jzo04-18-98   PromptAdd(hPosFileMenu,PF_CLERK,  "C~lerk             ")
#endif
   PromptAdd(hPosFileMenu,PF_CARD,   "C~redit Card       ")
#ifdef FOREIGN   
   PromptAdd(hPosFileMenu,PF_FORCUR,  "~Foreign Currency ")
#endif
   PromptAddLine(hPosFileMenu)
   PromptAdd(hPosFileMenu,PF_READPOS,"A~pply End of Day  ")
   PromptAdd(hPosFileMenu,PF_IMPORT, "Imp~ort Data (POS) ")
//jzo04-18-98   PromptAdd(hPosFileMenu,PF_ONLINE, "Monitor ~Transaction ")
   PromptAdd(hPosFileMenu,PF_FMFILE, "F~M File           ")
//   PromptAdd(hPosFileMenu,PF_DLOADFC,"Foreign ~Exchange File ")   

   // Inventory Files
   
   PromptAdd(hInvFileMenu,IF_PCOUNT, "~Physical Count    ") 
   PromptAdd(hInvFileMenu,IF_PURCORD,"Purchase ~Order    ")
   PromptAdd(hInvFileMenu,IF_STCKREC,"Stock ~Deliveries  ")
   PromptAdd(hInvFileMenu,IF_STCKRET,"Stock ~Returns     ")
   PromptAdd(hInvFileMenu,IF_STCKADJ,"Stock ~Adjustments ")
   PromptAdd(hInvFileMenu,IF_STCKTRN,"Stock ~Transfers   ")   
   
   // Reports

   PromptAddSub(hReportMenu,R_FLASH,hFlashMenu)
     PromptAddSub(hFlashMenu,R_PLU,hQSupMenu)
       PromptAdd(hQSupMenu,RFP_PLU,"Item ~Per Supplier ")
       PromptAdd(hQsupMenu,RFA_PLU,"Item ~All Supplier ")
       PromptAddSub(hQsupMenu,RFA_FPLU,hFIMenu)
       PromptAdd(hFIMenu,RFA_FMQ,"By ~Quantity")
       PromptAdd(hFIMenu,RFA_FMA,"By ~Amount")

//       PromptAdd(hQsupMenu,RFA_SPLU,"~Slow Moving Items ")
       PromptAddSub(hQsupMenu,RFA_SPLU,hSIMenu)
       PromptAdd(hSIMenu,RFA_SMQ,"By ~Quantity")
       PromptAdd(hSIMenu,RFA_SMA,"By ~Amount")
              

       PromptAdd(hQsupMenu,NF_PLU,"~Not Found PLU ")
       PromptAddSub(hQsupMenu,NF_CONCESS,hConcMenu)
       PromptAdd(hConcMenu,NF_ACONC,"~All Supplier")
       PromptAdd(hConcMenu,NF_PCONC,"~Per Supplier")       

       PromptAddSub(hQsupMenu,NF_CONSIGN,hConsMenu)
       PromptAdd(hConsMenu,NF_ACONS,"~All Supplier")
       PromptAdd(hConsMenu,NF_PCONS,"~Per Supplier")

/*jzo04-18-98
       PromptAddSub(hFlashMenu,R_TERM,hTermMenu)
         PromptAdd(hTermMenu,R_CTERM,"~Consolidated ")
         PromptAdd(hTermMenu,R_ITERM,"~Individual ")
       PromptAddSub(hFlashMenu,R_CASH,hCashMenu)
         PromptAdd(hCashMenu,R_CCASH,"~Consolidated ")
         PromptAdd(hCashMenu,R_ICASH,"~Individual ")  
       PromptAddSub(hFlashMenu,R_HOUR,hHourMenu)
         PromptAdd(hHourMenu,R_CHOUR,"~Consolidated ")
         PromptAdd(hHourMenu,R_IHOUR,"~Individual ")    
*/
       
		 PromptAdd(hFlashMenu,RFS_DEPT,"~Department Total Report")
		 PromptAdd(hFlashMenu,RFS_DSR,"Dail~y Sales Report" )
*		 PromptAdd(hDlyslsMenu,RFS_ADSR,"~All Department" )
*		 PromptAdd(hDlyslsMenu,RFS_RDSR,"~Per Department" )
		 
		 PromptAddSub(hFlashMenu,RFS_ILR,hILRDMenu)
       PromptAdd(hILRDMenu,RFS_ILRD,"By ~Department")
       PromptAdd(hILRDMenu,RFS_ILRB,"By ~Brand")
/*
		 PromptAdd(hFlashMenu,RFS_BRMV,"~Brand Movement")
		 PromptAdd(hFlashMenu,RFS_ITMV,"Item ~Movement")
           PromptAdd(hFlashMenu,RFS_CHPR,"~Change Price Report")               
		 PromptAdd(hFlashMenu,RFS_VPRV,"~Void Previous Report")
*/
       
       PromptAdd(hFlashMenu,RFS_CONC,"~Supplier Summary Report")
		 #ifdef CLERK
//jzo04-18-98         PromptAdd(hFlashMenu,RS_CLERK,  "C~lerk Sales Report  " )
       #endif      
       // PromptAdd(hFlashMenu,RS_CREDITC,"~Credit Card Sales ")           
       PromptAddSub(hFlashMenu,RS_CREDITC,hChargeMenu)         
         PromptAdd(hChargeMenu,R_CREDITC,"~Consolidated ")
         PromptAdd(hChargeMenu,R_CREDITI,"~Individual ")
         PromptAdd(hChargeMenu,R_CREDITA,"~All Charge Report")  
       
//jzo04-18-98       PromptAdd(hFlashMenu,RS_TERM,"Ter~minal Accountability")           
       PromptAdd(hFlashMenu,RS_STORE,"Sto~re Accountability")           
       PromptAddSub(hFlashMenu,RS_CASHIER,hCasActMenu)           
         PromptAdd(hCasActMenu,R_CACT,"~Consolidated ")
         PromptAdd(hCasActMenu,R_IACT,"~Individual ")
         PromptAdd(hCasActMenu,R_CALL,"~All Cashier Report")

//jzo04-17-98
   PromptGray(hReportMenu,R_FLASH,hFlashMenu)
     
   PromptAddSub(hReportMenu,R_INVEN,hInvenMenu)
     PromptAdd(hInvenMenu,RI_PURORD,"Purchase ~Orders  ")
   PromptAddSub(hInvenMenu,RI_DELIVR,hSupMenu)
     PromptAdd(hSupMenu,RD_PSUP,"~Per Supplier ")
     PromptAdd(hSupMenu,RD_ASUP,"~All Supplier ")   
     
   PromptAddSub(hInvenMenu,RI_STKRET,hRtSupMenu)
     PromptAdd(hRtSupMenu,RT_PSUP,"~Per Supplier ")
     PromptAdd(hRtSupMenu,RT_ASUP,"~All Supplier ") 
   PromptAddSub(hInvenMenu,RI_STKADJ,hAdjMenu)  
     PromptAdd(hAdjMenu,ADJ_PSUP,"~Per Supplier ")
     PromptAdd(hAdjMenu,ADJ_ASUP,"~All Supplier ")
   PromptAddSub(hInvenMenu,RI_STKTRN,hTrnMenu)  
     PromptAdd(hTRnMenu,TRN_PSUP,"~Per Supplier ")
     PromptAdd(hTRnMenu,TRN_ASUP,"~All Supplier ")
   PromptAddSub(hInvenMenu,RI_STKSTS,hStsSupMenu)
     PromptAdd(hStsSupMenu,STS_PSUP,"~Per Supplier")
     PromptAdd(hStsSupMenu,STS_ASUP,"~All Supplier")   
   PromptAddSub(hInvenMenu,RI_STKOUT,hSoSupMenu)
     PromptAdd(hSoSupMenu,SO_PSUP,"~Per Supplier")
     PromptAdd(hSoSupMenu,SO_ASUP,"~All Supplier")
     
   PromptAddSub(hInvenMenu,RI_STKREO,hReoSupMenu)
     PromptAdd(hReoSupMenu,REO_PSUP,"~Per Supplier")
     PromptAdd(hReoSupMenu,REO_ASUP,"~All Supplier")
   PromptAddSub(hInvenMenu,RI_STKINV,hStkSupMenu)
     PromptAdd(hStkSupMenu,STK_PSUP,"~Per Supplier")
     PromptAdd(hStkSupMenu,STK_ASUP,"~All Supplier")
   PromptAddSub(hInvenMenu,RI_INVVAR,hIvSupMenu)
     PromptAdd(hIvSupMenu,RIV_PSUP,"~Per Supplier")
     PromptAdd(hIvSupMenu,RIV_ASUP,"~All Supplier")
     
     
   PromptAddSub(hReportMenu,R_DIREC,hDirecMenu)  
     PromptAdd(hDirecMenu,RD_VENDIR,"~Supplier Directory ")
   PromptAddSub(hDirecMenu,RD_ITMDIR,hIdSupMenu)
     PromptAdd(hIdSupMenu,RID_PSUP,"~Per Supplier")
     PromptAdd(hIdSupMenu,RID_ASUP,"~All Supplier")   

#ifdef CLASS_LINK     
     PromptAdd(hDirecMenu,RD_CLSDIR,"~Class Directory ")
#endif     
     PromptAdd(hDirecMenu,RD_DPTDIR,"~Department Directory ")
     PromptAdd(hDirecMenu,RD_ALLDIR,"~ALL Directories ")

   //Periodic Updates
   PromptAdd(hPeriodMenu,S_DPOST,"~Sales Posting")
   PromptAdd(hPeriodMenu,I_DPOST,"~Inventory Posting")
   PromptAdd(hPeriodMenu,P_MPOST,"~Monthly Closing")
   PromptAdd(hPeriodMenu,P_APOST,"~Annual Closing  ")     
   

   //Utilities
   PromptAdd(hUtilMenu,U_UNITS,  "~Unit Maintenance ")
   PromptAddLine(hUtilMenu)
   PromptAdd(hUtilMenu,U_REINDEX,"~Reindex All ")   
   PromptAdd(hUtilMenu,U_BACKUP ,"~Backup      ")
   PromptAdd(hUtilMenu,U_RESTORE,"Re~store     ")
   PromptAdd(hUtilMenu,U_DELETE,"~Delete Files ")
//   PromptAdd(hUtilMenu,U_DELDBF,"Reset D~atabase")

/*jzo04-18-98
   // Download/Upload
   PromptAdd(hUtilityMenu,U_DOWN,  "~Download ")
   PromptAdd(hUtilityMenu,U_UP,"~Upload   ")   
   PromptAdd(hUtilityMenu,U_NFND,"~Not Found PLU ")   
   PromptAdd(hUtilityMenu,U_RDOWN,"~Re-Download ")   //jzo

*/

   MenuAdd(hBar,hAboutMenu)
   MenuAdd(hBar,hPosFileMenu)
   MenuAdd(hBar,hInvFileMenu)
   MenuAdd(hBar,hReportMenu)
   MenuAdd(HBar,hPeriodMenu)
   MenuAdd(hBar,hUtilMenu)

//jzo04-18-98   MenuAdd(hBar,hUtilityMenu)

   // Add quick key or shortcuts
   PromptQuickKey(hBar,hAboutMenu,A_EXIT,K_ALT_X)
   PromptQuickKey(hBar,hAboutMenu,A_SELEC,K_ALT_U)

      DO CASE
      CASE whatlevel() == 2  
         Promptgray(hAboutMenu, A_ALERT, "~Security      ")
         PromptgrayLine(hAboutMenu)


         // Inventory Files
   
         Promptgray(hInvFileMenu,IF_PCOUNT, "~Physical Count    ") 
         Promptgray(hInvFileMenu,IF_PURCORD,"Purchase ~Order    ")
         Promptgray(hInvFileMenu,IF_STCKREC,"Stock ~Deliveries  ")
         Promptgray(hInvFileMenu,IF_STCKRET,"Stock ~Returns     ")
         Promptgray(hInvFileMenu,IF_STCKADJ,"Stock ~Adjustments ")
         Promptgray(hInvFileMenu,IF_STCKTRN,"Stock ~Transfers   ")   
         PromptgraySub(hReportMenu,R_INVEN,hInvenMenu)
         PromptgraySub(hInvenMenu,RI_DELIVR,hSupMenu)
         PromptgraySub(hInvenMenu,RI_STKRET,hRtSupMenu)
         PromptgraySub(hInvenMenu,RI_STKADJ,hAdjMenu)  
         PromptgraySub(hInvenMenu,RI_STKTRN,hTrnMenu)  
         PromptgraySub(hInvenMenu,RI_STKSTS,hStsSupMenu)
         PromptgraySub(hInvenMenu,RI_STKOUT,hSoSupMenu)
         PromptgraySub(hInvenMenu,RI_STKREO,hReoSupMenu)
         PromptgraySub(hInvenMenu,RI_STKINV,hStkSupMenu)
         PromptgraySub(hInvenMenu,RI_INVVAR,hIvSupMenu)
        

//jzo05-15-98
   Promptgray(hPeriodMenu,I_DPOST,"~Inventory Posting")
   Promptgray(hPeriodMenu,P_MPOST,"~Monthly Closing")
   Promptgray(hPeriodMenu,P_APOST,"~Annual Closing  ")     


         //Utilities
         Promptgray(hUtilMenu,U_UNITS,  "~Unit Maintenance ")
         PromptgrayLine(hUtilMenu)

//jzo05-19-98         Promptgray(hUtilMenu,U_BACKUP ,"~Backup      ")

         Promptgray(hUtilMenu,U_RESTORE,"Re~store     ")
         Promptgray(hUtilMenu,U_DELETE,"~Delete Files ")

      CASE whatlevel() == 3  

//jzo05-15-98
         Promptgray(hAboutMenu, A_ALERT, "~Security      ")
         PromptgrayLine(hAboutMenu)

         // POS Files
         Promptgray(hPosFileMenu,IF_VENDORS,"~Supplier          ")   
         Promptgray(hPosFileMenu,PF_DEPARTM,"~Department        ")
         Promptgray(hPosFileMenu,PF_ITEMS,  "~Items             ")           
         PromptgrayLine(hPosFileMenu)
         Promptgray(hPosFileMenu,PF_CASHIER,"C~ashier           ")
         #ifdef CLERK   
//jzo04-18-98            Promptgray(hPosFileMenu,PF_CLERK,  "C~lerk             ")
         #endif
         Promptgray(hPosFileMenu,PF_CARD,   "C~redit Card       ")
         #ifdef FOREIGN   
            Promptgray(hPosFileMenu,PF_FORCUR,  "~Foreign Currency ")
         #endif

//jzo05-15-98
         PromptgrayLine(hPosFileMenu)
         Promptgray(hPosFileMenu,PF_READPOS,"A~pply End of Day  ")
         Promptgray(hPosFileMenu,PF_IMPORT, "Imp~ort Data (POS) ")
//jzo04-18-98         Promptgray(hPosFileMenu,PF_ONLINE, "Monitor ~Transaction ")
         Promptgray(hPosFileMenu,PF_FMFILE, "F~M File           ")
//         Promptgray(hPosFileMenu,PF_DLOADFC, "Foreign ~Exchange File ")


         // Inventory Files
         Promptgray(hInvFileMenu,IF_STCKADJ,"Stock ~Adjustments ")


         //Periodic Updates
         Promptgray(hPeriodMenu,S_DPOST,"~Sales Posting")


         //Directories
         Promptgray(hReportMenu,R_DIREC,hDirecMenu)
     Promptgray(hDirecMenu,RD_VENDIR,"~Supplier Directory ")
   PromptgraySub(hDirecMenu,RD_ITMDIR,hIdSupMenu)
     Promptgray(hIdSupMenu,RID_PSUP,"~Per Supplier")
     Promptgray(hIdSupMenu,RID_ASUP,"~All Supplier")   

     Promptgray(hDirecMenu,RD_DPTDIR,"~Department Directory ")
     Promptgray(hDirecMenu,RD_ALLDIR,"~ALL Directories ")
         

         //Utilities
         Promptgray(hUtilMenu,U_UNITS,  "~Unit Maintenance ")
         PromptgrayLine(hUtilMenu)

         Promptgray(hUtilMenu,U_BACKUP ,"~Backup      ")
         Promptgray(hUtilMenu,U_RESTORE,"Re~store     ")
         Promptgray(hUtilMenu,U_DELETE,"~Delete Files ")



         
      CASE whatlevel() == 4  
         // Add Prompts
         // About Menu
         Promptgray(hAboutMenu, A_ALERT, "~Security      ")
         PromptgrayLine(hAboutMenu)

         // POS Files
         Promptgray(hPosFileMenu,IF_VENDORS,"~Supplier          ")   
         Promptgray(hPosFileMenu,PF_DEPARTM,"~Department        ")
         Promptgray(hPosFileMenu,PF_ITEMS,  "~Items             ")           
         PromptgrayLine(hPosFileMenu)
         Promptgray(hPosFileMenu,PF_CASHIER,"C~ashier           ")
         Promptgray(hPosFileMenu,PF_CARD,   "C~redit Card       ")
         Promptgray(hPosFileMenu,PF_FORCUR,  "~Foreign Currency ")
         PromptgrayLine(hPosFileMenu)
         Promptgray(hPosFileMenu,PF_READPOS,"A~pply End of Day  ")
         Promptgray(hPosFileMenu,PF_IMPORT, "Imp~ort Data (POS) ")
//jzo04-18-98         Promptgray(hPosFileMenu,PF_ONLINE, "Monitor ~Transaction ")
         Promptgray(hPosFileMenu,PF_FMFILE, "F~M File           ")
//         Promptgray(hPosFileMenu,PF_DLOADFC, "Foreign ~Exchange File ")
         
         // Reports
         PromptgraySub(hReportMenu,R_FLASH,hFlashMenu)
         PromptgraySub(hFlashMenu,R_PLU,hQSupMenu)
         PromptgraySub(hFlashMenu,R_TERM,hTermMenu)
         PromptgraySub(hFlashMenu,R_CASH,hCashMenu)
         PromptgraySub(hFlashMenu,R_HOUR,hHourMenu)
         Promptgray(hFlashMenu,RFS_DEPT,"~Department Sales ")
         Promptgray(hFlashMenu,RFS_CONC,"~Supplier Summary Report")
		   #ifdef CLERK
//jzo04-18-98            Promptgray(hFlashMenu,RS_CLERK,  "C~lerk Sales Report  " )
         #endif      
         PromptgraySub(hFlashMenu,RS_CREDITC,hChargeMenu)         
         Promptgray(hFlashMenu,RS_TERM,"Ter~minal Accountability")           
         Promptgray(hFlashMenu,RS_STORE,"Sto~re Accountability")           
         PromptgraySub(hFlashMenu,RS_CASHIER,hCasActMenu)           

         //Utilities
         Promptgray(hUtilMenu,U_UNITS,  "~Unit Maintenance ")
         PromptgrayLine(hUtilMenu)
         Promptgray(hUtilMenu,U_REINDEX,"~Reindex All ")   
         Promptgray(hUtilMenu,U_BACKUP ,"~Backup      ")
         Promptgray(hUtilMenu,U_RESTORE,"Re~store     ")
         Promptgray(hUtilMenu,U_DELETE,"~Delete Files ")

      
      CASE whatlevel() == 5  
         // gray Prompts
         // About Menu
         Promptgray(hAboutMenu, A_ALERT, "~Security      ")
         PromptAction(hAboutMenu,A_SELEC, { || WhatUnit() })
         PromptgrayLine(hAboutMenu)
         
         // Inventory Files
   
         Promptgray(hInvFileMenu,IF_PCOUNT, "~Physical Count    ") 
         Promptgray(hInvFileMenu,IF_PURCORD,"Purchase ~Order    ")
         Promptgray(hInvFileMenu,IF_STCKREC,"Stock ~Deliveries  ")
         Promptgray(hInvFileMenu,IF_STCKRET,"Stock ~Returns     ")
         Promptgray(hInvFileMenu,IF_STCKADJ,"Stock ~Adjustments ")
         Promptgray(hInvFileMenu,IF_STCKTRN,"Stock ~Transfers   ")   
         PromptgraySub(hReportMenu,R_INVEN,hInvenMenu)
         PromptgraySub(hInvenMenu,RI_DELIVR,hSupMenu)
         PromptgraySub(hInvenMenu,RI_STKRET,hRtSupMenu)
         PromptgraySub(hInvenMenu,RI_STKADJ,hAdjMenu)  
         PromptgraySub(hInvenMenu,RI_STKTRN,hTrnMenu)  
         PromptgraySub(hInvenMenu,RI_STKSTS,hStsSupMenu)
         PromptgraySub(hInvenMenu,RI_STKOUT,hSoSupMenu)
         PromptgraySub(hInvenMenu,RI_STKREO,hReoSupMenu)
         PromptgraySub(hInvenMenu,RI_STKINV,hStkSupMenu)
         PromptgraySub(hInvenMenu,RI_INVVAR,hIvSupMenu)

         //Periodic Updates
         Promptgray(hPeriodMenu,S_DPOST,"~Sales Posting")
         Promptgray(hPeriodMenu,I_DPOST,"~Inventory Posting")
         Promptgray(hPeriodMenu,P_MPOST,"~Monthly Closing")
         Promptgray(hPeriodMenu,P_APOST,"~Annual Closing  ")     
   

         //Utilities
         Promptgray(hUtilMenu,U_UNITS,  "~Unit Maintenance ")
         PromptgrayLine(hUtilMenu)
         Promptgray(hUtilMenu,U_BACKUP ,"~Backup      ")
         Promptgray(hUtilMenu,U_RESTORE,"Re~store     ")
         Promptgray(hUtilMenu,U_DELETE,"~Delete Files ")

   ENDCASE   


return nil

static function About()
local wAbout
  Message("Press any key continue....",nUnit)
  wAbout:=OpenWindow(((maxrow()*0.5)-4),19,((maxrow()*0.5)+5),60,"About the System")
  @ ((maxrow()*0.5)-2),21 say "          SPECTRUM PCPOS 3000           "
  @ row()+1,21 say            "  Merchandize Tracking System Ver 2.0   "
  @ row()+1,21 say            "             Developed for              "
  @ row()+1,21 say padc(CLIENT_NAME,38)
  @ row()+1,21 say            "                  by:                   "
  @ row()+1,21 say            "    Technosoft Philippines Corp 1998    "
  @ row()+1,21 say            "             "+chr(225)+"eta Release               "
  @ ((maxrow()*0.5)-3),19 to ((maxrow()*0.5)+5),60 double
  Inkey(0)
  CloseWindow(wAbout)
return nil

function GetDates()
/*
   Purpose : Accepts dates from the user, to cover the report(s)
             to be prepared.
*/
local wDate
local cOldColr := setcolor(), cScr := savescreen(maxrow()-1, 0, maxrow(), maxcol()) 
   dStartDate:=dEndDate:= date()  // CToD("")
   Message("Enter dates to cover report")
   wDate:=OpenWindow(09,15,13,64,"Date Information Box")
   @ 11,17 say " Enter starting date (MM/DD/YY format)" get dStartDate
   @ 12,17 say "         Ending date (MM/DD/YY format)" get dEndDate
   SetCursor(SC_NORMAL)
   HeyThere()
   read
   SetCursor(SC_NONE)
   CloseWindow(wDate)
   setcolor(cOldColr)
   restscreen(maxrow()-1, 0, maxrow(), maxcol(), cScr) 
return If(LastKey()==K_ESC,.F.,.T.)

function _logo()
local oCol:=SetColor("W+/N")
#ifdef COLOR_STAT
 @ 2,0, maxrow()-1, maxcol() BOX repl(FILL_CHAR,9) COLOR BACK_COL
#else
 @ 2,0 CLEAR TO maxrow()-1, maxcol()
#endif 
SetColor(oCol)
return nil

static function WhatUnit()
  if SelectUnit() == 0
      PromptEnable(hInvFileMenu,IF_PURCORD )
      PromptEnable(hInvFileMenu,IF_STCKREC )
      PromptEnable(hInvFileMenu,IF_STCKRET )
      PromptEnable(hReportMenu,R_FLASH )
     // PromptEnable(hInvFileMenu,IF_STCKTRN )   
     // PromptGray(hReportMenu,R_FLASH )

//jzo04-17-98
   PromptGray(hReportMenu,R_FLASH,hFlashMenu)

  else
      PromptGray(hInvFileMenu,IF_PURCORD )
      PromptGray(hInvFileMenu,IF_STCKREC )
      PromptGray(hInvFileMenu,IF_STCKRET )
     // PromptGray(hInvFileMenu,IF_STCKTRN )  
    if Whatlevel() == 4 .or. Whatlevel() == 8
      if Whatlevel() == 4 
         PromptEnable(hInvFileMenu,IF_PURCORD )
         PromptEnable(hInvFileMenu,IF_STCKREC )
         PromptEnable(hInvFileMenu,IF_STCKRET )
       //  PromptEnable(hInvFileMenu,IF_STCKTRN )   
      endif
      PromptGray(hReportMenu,R_FLASH )
    else
      PromptEnable(hReportMenu,R_FLASH )
    endif  
  endif      
return nil

