
/*============================================================================

   (c) 1993  TECHNO SOFTWARE CORPORATION

   This module contains information proprietary to TECHNO SOFTWARE
   CORPORATION, and should be treated confidential.

   its.ch - General Header file for Inventory Tracking System (ITS)

   acr / 03.20.93

============================================================================*/
* #define  DEMO
#undef  MTS5550

#undef   CLASS_LINK
#undef   CLERK
#define  MAKE_DATA

#undef CENTRALIZED_CASHIER

#define  COLOR_STAT

#define TITLE_ATTR  If(IsColor(),"W+/RB+","W+/N")

#ifdef DEMO
 #define CLIENT_NAME "DEMO COPY NOT FOR SALE !!!"
 #define SYS_NAME    "Demo Copy Not For Sale !!!"
#else
 #define CLIENT_NAME "***    O R I E N T A L   ***"
 #define SYS_NAME  "ORIENTAL"
#endif

#define NET_WORK_PATH "S:\"

#ifdef MTS5550
  #define SYS_TITLE "SPECTRUM PCPOS 3000 Merchandize Tracking System "
#else 
  #define SYS_TITLE "Merchandize Tracking System (MTS) Ver 2.0 - FEMA Business Systems Corp."
#endif 

#undef  FM_CASHIER
#undef  FM_CLASS
#define  FM_FOREIGN
#define FM_DEPT
#define FM_ITEMS

#define ARRAY_TERMS { "C.O.D.  ",;
                      "C.W.O   ",; 
                      "15 Days ",;
                      " 7 Days ",;
                      "30 Days ",;
                      "60 Days ",;
                      "90 Days ",;
                      "180 Days",;
                      "30 PDC  ",;
                      "60 PDC  ",;
                      "90 PDC  " }
#define LEN_ARRAY_ITEMS 11                                            
                      
/*#define VENDOR_TYPES { " Local         ",;
                       " Imported      ",;
                       " CDI           ",;
                       " Open 1        ",;
                       " Open 2        ",;
                       " Consignment 1 ",;
                       " Consignment 2 " }*/
                       
#define VENDOR_TYPES {" Outright       ",;
                      " Concessionaire ",;
                      " Consignment    " }
                       
#define LEN_VENDOR_TYPE 3

//#define POITEM_MODE   101             
//#define RETURN_MODE   102
//#define RECEIVE_MODE  103                  

// Color table.
#define MAIN_COLOR "R/W,W+/R,,N/W,N/W"
#define REC_COLOR  "B/W,W+/B,,N/B,N/B"
#define CMDV_COLOR "GR/W,GR+/GR,,N/W,N/W"

#define CONFIRM_COLOR "BG+*/B,GR+/R+,,,W+/R+"

#define BG_COLOR "N/BG"
#define BN_COLOR "W+/B"

// Additional color sets.
#define COLOR_SET_1 "N/W,W+/N,,N/W,N/W"
#define COLOR_SET_2 "W+/W,BG+/B,,N/G,N/BG"

// Separator strings for the browse display.
#define HEADSEP      "мям"
#define COLSEP       " Ё "
#define FOOTSEP      "мом"

// DBF array descriptors.
#define SYS_DBFNAME 1
#define SYS_COMMENT 2
#define SYS_STRU 3
#define SYS_NTX 4

// STRUCTURE array descriptors.
#define STRU_NAME    1
#define STRU_TYPE    2
#define STRU_LEN     3
#define STRU_DEC     4
#define STRU_COMMENT 5

// INDEX array descriptors.
#define NTX_NAME    1
#define NTX_KEY     2
#define NTX_COMMENT 3

// Printer Control.
#define COND_ON  qqout(chr(15))
#define COND_OFF qqout(chr(18))
#define CPS_10   qqout(chr(27)+chr(80))
#define CPS_12   qqout(chr(27)+chr(77))
#define INIT_PRN qqout(chr(27)+chr(64))
#define RING_BEL qqout(chr(7)+chr(7)+chr(7))

// Default printer page definitions.
#define PAGE_LEN      55                        // 62 - eso 09.24.95
#define WIDE_PAGE    142
#define VERY_WIDE    264
#define NORM_PAGE     80
#define TOP_MARGIN     4
#define BOT_MARGIN     3
#define LEFT_MARGIN    0
#define MARGIN        ""// space(LEFT_MARGIN)
#define RIGHT_MARGIN   0

#define PLU_DESC_LEN 20    //16 //20 //12
#define PLU_CODE_LEN 14

#define TO_FILE

// User Defined Commands.

#xcommand @ <row>, <col> SSAY <xpr> => ;
   SetPos ( <row>, <col> ); DispOut ( <xpr> )

#xcommand @ <row>, <col> WSAY <xpr> ;
      [COLOR <color>]      ;
      => it999055 ( <row>, <col>, <xpr> [, <color>] )

#xcommand @ <row>, <col> WPROMPT <xpr> ;
      => it999056 ( <row>, <col>, <xpr> )
