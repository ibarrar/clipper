*
* System......... Powerpos for Spectrum
* Filename....... spec_key.ch
* Description.... Definitions of the Spectrum POS 3000 keyboard
*
*
#include "keymap.ch"

// users...
//
#define CASHIER          KEY_CASHIER
#define SALES_CLERK      KEY_CLK

// PLUs...
//
#define PLU              KEY_PLU
#define QTY              KEY_QTY
#define CLR              KEY_CLEAR 
#define ENTER            KEY_ENTER 

// cash payment...
//
#define SUBTOTAL         KEY_SUBTOTAL 
#define CASH             KEY_CASH 

// charge payments...
//
*#define MISC_KEY        KEY_MISC

// void...
//
#define VOID             KEY_CVOID 
#define MGR_VOID         KEY_MVOID

// line feeds...
//
#define STEP_REC         KEY_REC 
#define STEP_JOURNAL     KEY_JOUR
#define STEP_SLIP        KEY_SLIP 

// POS functions...
//
#define DISCOUNT         KEY_DISC
#define SSD              KEY_SSDISC
#define ADD_ON_AMT       KEY_SAMT_ADDN 
#define ADD_ON_RATE      KEY_SPCT_ADDN
#define VALIDATE         KEY_VALID 
#define SUSPEND          KEY_SUSPEND 
#define RESUME           KEY_RESUME
#define CUST_DEP         KEY_CUSTDEP
#define RET_EXC          KEY_RET_EXC


// foreign currency key
//
#define HOME             KEY_HOME
#define UP               KEY_UP
#define DOWN             KEY_DOWN
#define ESC              KEY_ESC
#define YES              KEY_YES
#define NO               KEY_NO
#define TRIAL            KEY_TRIAL
#define ONE              KEY_ONE
#define ZERO             KEY_ZERO

// additional key
//
#define IPCT_DISC        KEY_IPCT_DISC
#define SPCT_DISC        KEY_SPCT_DISC
#define IAMT_DISC        KEY_IAMT_DISC
#define SAMT_DISC        KEY_SAMT_DISC
#define SPCT_ADDN        KEY_SPCT_ADDN
#define IAMT_ADDN        KEY_IAMT_ADDN
#define SAMT_ADDN        KEY_SAMT_ADDN
#define REFUND           KEY_ITMREFUND
#define GEN_REFUND       KEY_GENREFUND
#define ERRCORR          KEY_ERRCORR
#define TRANSCAN         KEY_TRANSCAN
#define SUB_DEPT         KEY_SUB_DEPT

// ESC KEY TO DOS
//
#define ESC_DOS          KEY_ESC_DOS

// additional key for opening of cash drawer
//
#define NO_SALE          KEY_NO_SALE
#define BACK_SPACE       KEY_BACK_SP

// others...
//
#define SCANNER          9999 
#define ALPHA            KEY_ALPHA

#define NON_ADD          KEY_NON_ADD
#define OTH_INC          KEY_OTH_INC
#define PICK_UP          KEY_PICK_UP
#define PAID_OUT         KEY_PAID_OUT
#define LOAN             KEY_LOAN
#define TRAN_VOID        KEY_TRAN_VOID
#define REPRINT          KEY_RE_PRINT
#define PRICE_ADJUST     KEY_PRICE_ADJ
#define LETTER_SPACE     KEY_SPACE
#define CASH_IN_DRAWER   KEY_CASH_ID
#define PLEVEL           KEY_PRC_LEVEL
#define PO		     KEY_PO
#define PESO			KEY_PESO
#define USD			KEY_USD

// for price leveling
#define LEVEL_ONE        KEY_LEVEL_ONE
#define LEVEL_TWO        KEY_LEVEL_TWO
#define LEVEL_THREE      KEY_LEVEL_THREE  
#define LEVEL_FOUR       KEY_LEVEL_FOUR
#define LEVEL_FIVE       KEY_LEVEL_FIVE
#define LEVEL_SIX        KEY_LEVEL_SIX
