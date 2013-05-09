/*
 * dept.h -- Department record and key structures
*/
#include "deptfile.ch"

#define DEPT_IDX_FILE_NAME "DEPT.IDX"

/*
 * Structure of the standard btrieve file
 * that will serve as an index to the DOS text file...
*/

/* Structure of DEPT. record... */

typedef struct {
   char dp_code[DEP_CODE_LEN];
   char dp_desc[DEP_DESC_LEN];
   char dp_conc[DEP_CONC_LEN];
   char dp_sttm[DEP_STTM_LEN];
   char dp_entm[DEP_ENTM_LEN];
   char dp_stat[DEP_STAT_LEN];
   ieee dp_halo;
   ieee dp_lalo;
   ieee dp_add1;
   ieee dp_add2;
   char dp_drte[DEP_DISC_LEN];
   ieee dp_damt;
   char dp_cust[DEP_CUST_LEN];
   char deleted;
   ieee quantity;
   ieee amount;
   ieee discount;
   ieee ptd_qty;
   ieee ptd_amt;
   ieee ptd_dsc;   
} DEPT_RECORD;

typedef struct {
  char dept_code[DEP_CODE_LEN];
  ieee quantity;        
  ieee amount;  
  ieee discount;
} DP_COUNT_IN ;

typedef struct {
  char dept_code[DEP_CODE_LEN];
  char dept_desc[DEP_DESC_LEN];
  ieee quantity;        
  ieee amount;  
  ieee discount;
  ieee ptd_qty;
  ieee ptd_amt;
  ieee ptd_dsc;  
} DP_COUNT_OUT;

