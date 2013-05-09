/*
 * plu_temp.h -- PLU_TEMP record, buffer, and key structures
*/

#include "plu_file.ch"

#define PLUTEMP_FILE_NAME "PLU_TEMP.IDX"

/*
 * Structure of the standard btrieve file
 * that will serve as an index and as data file...
*/
typedef struct {            
  char plu_code[PLU_CODE_LEN];  
  char plu_dept[PLU_DEPT_LEN];   
  char plu_desc[PLU_DESC_LEN];
  ieee plu_pric;
  ieee quantity;   
  ieee amount;     
  ieee discount;
  ieee pl0_qty;
  ieee pl0_amt;
  ieee pl1_qty;
  ieee pl1_amt;
  ieee pl2_qty;
  ieee pl2_amt;
  ieee pl3_qty;
  ieee pl3_amt;
  ieee pl4_qty;
  ieee pl4_amt;
  ieee pl5_qty;
  ieee pl5_amt;
  char reserved;  
  
} PLUTEMP_RECORD;

typedef struct {            
  char plu_code[PLU_CODE_LEN];  
  char plu_dept[PLU_DEPT_LEN];   
  char plu_desc[PLU_DESC_LEN];
  ieee plu_pric;
  ieee quantity;   
  ieee discount;
  ieee level;
} PLUTEMP_INPUT;  
  

/* Eof */
