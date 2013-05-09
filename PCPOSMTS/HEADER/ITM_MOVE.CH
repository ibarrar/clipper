#include "itemtran.ch"

#define POSNO       substr(cStr,ITEM_POSN_OFF,ITEM_POSN_LEN)
#define DATES       substr(cStr,ITEM_DATE_OFF,ITEM_DATE_LEN)
#define TIMES       substr(cStr,ITEM_TIME_OFF,ITEM_TIME_LEN)           
#define TRANSNO     substr(cStr,ITEM_TRNO_OFF,ITEM_TRNO_LEN)           
#define PREVFLAG    substr(cStr,ITEM_PFLG_OFF,ITEM_PFLG_LEN)
#define TRANS_FLAG   substr(cStr,ITEM_FLAG_OFF,ITEM_FLAG_LEN)
#define CASH_CDE    substr(cStr,ITEM_CASH_OFF,ITEM_CASH_LEN)
#define CLRK_CDE    substr(cStr,ITEM_CLRK_OFF,ITEM_CLRK_LEN)
#define REGMETHD    substr(cStr,ITEM_REGM_OFF,ITEM_REGM_LEN)
#define PAYMTYPE    substr(cStr,ITEM_PRCM_OFF,ITEM_PRCM_LEN)
#define PLUCODE     substr(cStr,ITEM_PLUC_OFF,ITEM_PLUC_LEN)
#define ITEMCODE    substr(cStr,ITEM_ITEM_OFF,ITEM_ITEM_LEN)
#define ITEMSALE    substr(cStr,ITEM_SALE_OFF,ITEM_SALE_LEN)
#define ITEMCNTR    substr(cStr,ITEM_CNTR_OFF,ITEM_CNTR_LEN)

#define CUSTSALE    substr(cStr,CUST_SALE_OFF,CUST_SALE_LEN)
#define CUSTCNTR    substr(cStr,CUST_CNTR_OFF,CUST_CNTR_LEN)
#define CUSTCRG1    substr(cStr,CUST_CRG1_OFF,CUST_CRG1_LEN)


