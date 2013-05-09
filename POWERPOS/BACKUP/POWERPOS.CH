/*
    FILENAME : Powerpos.ch
    AUTHOR   : Rollie Ibarra Junior
    MODULE   : Powerpos Front-End 
*/

#ifndef POWERPOS

#ifndef DEF_GRAPHICS
  #define  DEF_GRAPHICS
#endif
*#undef  DEF_DISP4X20
*#undef  DEF_DISP1X09 

#define  DEF_SCANNER
#define  DEF_KEY_LOCK
#define  DEFAULT_KEY_POS          0
#define  KEY_SOUND
#define  USD_CURRENCY
#define  ERASE_FMTRANS
#undef   DEBUG
#undef   STAND_ALONE_MODE
#undef   ONESHOT_PLU
#undef   SLIP_PRNT
#define  MIDDAY_ITEM_UPDATE
#define  ALPHA_NUMERIC
#define  NUMERIC_KEY_FIX
#undef   SPECTRUM_586_MACHINE

#ifdef DEF_KEY_LOCK
  #define KEY_LOCK_POS0           0
  #define KEY_LOCK_POS1           1
  #define KEY_LOCK_POS2           2
  #define KEY_LOCK_POS3           3
  #define KEY_LOCK_POS4           4
#else  
  #define KEY_LOCK_POS0           DEFAULT_KEY_POS
  #define KEY_LOCK_POS1           DEFAULT_KEY_POS
  #define KEY_LOCK_POS2           DEFAULT_KEY_POS
  #define KEY_LOCK_POS3           DEFAULT_KEY_POS
  #define KEY_LOCK_POS4           DEFAULT_KEY_POS
#endif  

/*Displays*/
#undef  DEF_DISP2X20

#define MAXIMUM_INPUT_LEN       20
#define DECIMAL_NUMBERS         2

#define POSITIVE_OPER_FLAG      "NMPOA"
#define NEGATIVE_OPER_FLAG      "DSVGE"   
#define DONOTHING_OPER_FLAG     "CX0UZ123456789!?*"

#define OP_NPLU_FLAG            "N"
#define OP_OINC_FLAG            "O"
#define OP_VOID_FLAG            "V" 
#define OP_MGRV_FLAG            "G" 
#define OP_IDSC_FLAG            "D" 
#define OP_SDSC_FLAG            "S"
#define OP_TRCL_FLAG            "0"
#define OP_ITCL_FLAG            "C"
#define OP_OPEN_FLAG            "M"
#define OP_REXC_FLAG            "E"
#define OP_NOTF_FLAG            "P"
#define OP_ADON_FLAG            "A"
#define OP_RFND_FLAG            "R"
#define OP_TVOD_FLAG            "T"

#define ON                      .Y.
#define OFF                     .N.

// Process Definitions ....
#define START_MODE              0
#ifndef NORMAL
 #define NORMAL                 0
#endif 

#define  INCLUDE_FOREIGN_CURR
#define ADD_IF_UPDATE_ERR

#define QTY_LALO                0
#define QTY_HALO                999
#define AMT_LALO                0
#define AMT_HALO                999999.99
#define TOTQTY_HALO             999999.99
#define TOTAMT_HALO             999999.99

#define FILE_OPEN_MODE          .T. // Exclusive
#define NUM_SECONDS             5   // 5 retries  before quitting
#define API_BUFF_LEN            19
#define DATA_PATH               ".\DATA"

#define VERSION_ID              "PowerPOS ver 2.1f"

#define TOTAL_OFF         // DISPTEXTXY(0,0,1,1,0,0, "#")
#define TOTAL_ON          // TOTAL_OFF
#define TENDER_OFF        // DISPTEXTXY(0,0,1,1,0,0, "@")
#define TENDER_ON         // TENDER_OFF
#define CHANGE_OFF        // DISPTEXTXY(0,0,1,1,0,0, "!") 
#define CHANGE_ON         // CHANGE_OFF


#xtranslate PLAYTUNE ( <a> )            ;
            => aeval ( <a>, { |t| tone( t\[1], t\[2] ) } )

#xtranslate BEEP_1 ( )                  ;
            => playtune( { {680, .5}, {850, .2}, {900, .1} } )

#xtranslate BEEP_2 ( )                  ;
            => playtune( { {735, .7}, {975, .3} } )

#xtranslate BEEP_3 ( )                 ;
            => playtune( { {808, .2}, {570, .1} } )            

#xtranslate BEEP_4 ( )                  ;
            => playtune( { {874, .05}, {703, .07}, {615, .10} } )            

#xtranslate BUMMER()                                                       ;
            => PlayTune({ {392,1}, {98,1}, {49,5} })

#xtranslate HEYTHERE()                                                     ;
            => PlayTune({ {392,1}, {880,1} })

#xtranslate OKDONE()                                                       ;
            => PlayTune({ {784,1}, {784,1} })
            
#xtranslate KEY_STROKE_SOUND ( )        ;
            => tone(1500,1)            
            
#define POWERPOS            
#endif            
*e------o-------f>

