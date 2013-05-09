
#define CONFIG_POS_FILE     "SYSTEM.CFG"
#define CONFIG_POS_LEN      69

#define POS_2X20_DISP1      001
#define POS_2X20_DISP2      002 
#define POS_4X20_DISP1      003
#define POS_4X20_DISP2      004 
#define POS_4X20_DISP3      005
#define POS_4X20_DISP4      006
#define POS_REC_HEAD1       007
#define POS_REC_HEAD2       008
#define POS_REC_HEAD3       009
#define POS_REC_HEAD4       010
#define POS_TRAIN_MODE      011
#define POS_1X09_DISP       012
#define POS_2X20_DISP       013
#define POS_4X20_DISP       014
#define POS_FULL_SCRN       015
#define POS_REC_PRINT       016  
#define POS_JRN_PRINT       017
#define POS_VAL_PRINT       018
#define POS_XSLIP_PRN       019   
#define POS_ISLIP_PRN       020
#define POS_STD_KEY         021
#define POS_RETAILKEY       022 
#define POS_RESTAURAN       023
#define POS_SCANNER         024
#define POS_MCR             025
#define POS_ITEM_FILE       026
#define POS_IDLE_TIME       027
#define POS_FLOATING        028 
#define POS_TERM_FILE       029
#define POS_TERM_NUM        030 
#define POS_SERVER1         031 
#define POS_SERVER2         032
#define POS_SERVER3         033 
#define POS_NUM_RETS        034 
#define POS_HALO            035
#define POS_LALO            036
#define POS_VLD_CLRK        037
#define POS_ADDON           038
#define POS_ADDON_AMT       039 
#define POS_PRCNT_DISC      040
#define POS_M_STTL_KEY      041
#define POS_MIX_MATCH       042 
#define POS_TIME_PRIC       043
#define POS_RAMDRIVE        044   
#define POS_NVRAM_DRV       045
#define POS_SERVER_MD       046
#define POS_SERVER_PATH     047
#define POS_CENTRAL_PATH    048
#define POS_LOCAL_PATH      049
#define POS_SCAN_SUFX       050   
#define POS_SCAN_IRQ        051
#define POS_CSHR_IV_ALWD    052
#define POS_CSHR_SIV_ALWD   053
#define POS_CSHR_TRV_ALWD   054
#define POS_LOCAL_IP_ADDR   055  
#define POS_SERV_IP_ADDR    056
#define POS_KEY_LOCK        057
#define POS_CASH_DRAWER     058
#define POS_PRINT_SUBTOTAL  059
#define POS_MANUAL_KEY      060
#define POS_LESSEE_NO       061
#define POS_REPORT_PATH     062
#define POS_PASSWORD        063
#define POS_DIAL_NUMBER     064
#define POS_MODEM_COMPORT   065
#define POS_PRICE_DEFAULT   066
#define POS_BOTTOM_LINE1    067
#define POS_BOTTOM_LINE2    068
#define POS_BOTTOM_LINE3    069


#define CONFIG_POS_LINES   { "WELCOME DISPLAY 2X20 LINE 1",;
/*           002  */         "WELCOME DISPLAY 2X20 LINE 2",;
/*           003  */         "WELCOME DISPLAY 4X20 LINE 1",;
/*           004  */         "WELCOME DISPLAY 4X20 LINE 2",;
/*           005  */         "WELCOME DISPLAY 4X20 LINE 3",;
/*           006  */         "WELCOME DISPLAY 4X20 LINE 4",;
/*           007  */         "RECEIPT HEADING 1",;
/*           008  */         "RECEIPT HEADING 2",;
/*           009  */         "RECEIPT HEADING 3",;
/*           010  */         "RECEIPT HEADING 4",;
/*           011  */         "TRAINING MODE",;
/*           012  */         "1X9  DISPLAY",;
/*           013  */         "2X20 DISPLAY",;
/*           014  */         "4X20 DISPLAY",;
/*           015  */         "FULL SCREEN",;
/*           016  */         "RECEIPT PRINTER",;
/*           017  */         "JOURNAL PRINTER",;
/*           018  */         "VALIDATION PRINTER",;
/*           019  */         "EXTERNAL SLIP PRINTER",;
/*           020  */         "INTERNAL SLIP PRINTER",;
/*           021  */         "STANDARD KEYBOARD",;
/*           022  */         "DEPT./SUPERMARKET",;
/*           023  */         "RESTAURANT",;
/*           024  */         "SCANNER",;
/*           025  */         "MAGNETIC CARD READER",;
/*           026  */         "ITEM FILE",;
/*           027  */         "IDLE TIME",;
/*           028  */         "CASHIER FILE",;
/*           029  */         "TERMINAL REPORT FILE",;
/*           030  */         "TERMINAL NO.",;
/*           031  */         "SERVER 1 I.D.",;
/*           032  */         "SERVER 2 I.D.",;
/*           033  */         "SERVER 3 I.D.",;
/*           034  */         "NUMBER OF RETRIES",;
/*           035  */         "HALO (HIGH AMT. LOCK-OUT)",;
/*           036  */         "LALO (LOW AMT. LOCK-OUT)",;
/*           037  */         "VALIDATE CLERK",;
/*           038  */         "ADD-ON ALLOWED",;
/*           039  */         "ADD-ON MAX AMT",;
/*           040  */         "PERCENT DISCOUNT",;
/*           041  */         "MANDATORY SUBTOTAL KEY PRESS BEFORE PAYMENT",;
/*           042  */         "MIX & MATCH",;
/*           043  */         "TIME PRICE PLU",;
/*           044  */         "USE_RAMDRIVE",;
/*           045  */         "NVRAM LOGICAL DRIVE",;
/*           046  */         "SERVER MODE",;
/*           047  */         "SERVER_PATH",;
/*           048  */         "CENTRAL_PATH",;
/*           049  */         "LOCAL_PATH",;
/*           050  */         "SCANNER'S SUFFIX",;
/*           051  */         "SCANNER'S IRQ FLAG (0/1)",;
/*           052  */         "ALLOW CASHIER ITEM VOID",;
/*           053  */         "ALLOW CASHIER SELECTIVE ITEM VOID",;
/*           054  */         "ALLOW CASHIER TRANSACTION VOID",;
/*           055  */         "LOCAL_IP_ADDRESS",;
/*           056  */         "SERVER_IP_ADDRESS",;
/*           057  */         "KEY_LOCK_CHK",;
/*           058  */         "CASH_DRAWER",;
/*           059  */         "PRINT_SUBTOTAL",;
/*           060  */         "MANUAL_KEY_POS",;
/*           061  */         "LESSEE_NUMBER",;
/*           062  */         "REPORT_PATH" ,;
/*           063  */         "PASSWORD",;
/*           064  */         "DIAL_NUMBER",;
/*           065  */         "MODEM_COM_PORT",;
/*           066  */         "PRICE DEFAULT",;
/*           067  */         "BOTTOM_LINE1",;
/*           068  */         "BOTTOM_LINE2",;
/*           069  */         "BOTTOM_LINE3"  }

