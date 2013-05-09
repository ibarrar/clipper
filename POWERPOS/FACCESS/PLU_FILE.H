/*
 * plu_file.h -- PLU record, buffer, and key structures
*/

#include "plu_file.ch"

#define PLU_IDX_FILE_NAME "PLUITEMS.IDX"

/*
 * Structure of the standard btrieve file
 * that will serve as an index to the DOS text file...
 */

typedef struct {
   char plu_code [PLU_CODE_LEN]; 
   char item_code[PLU_ITEM_LEN];
   char item_desc[PLU_DESC_LEN];
   char size_code[PLU_SIZE_LEN];
   char colo_code[PLU_COLO_LEN];
   char clas_code[PLU_CLAS_LEN];
   char dept_code[PLU_DEPT_LEN];
   char conc_code[PLU_CONC_LEN];
   ieee unit_pric;
   ieee pric_lev1;
   ieee pric_lev2;
   ieee pric_lev3;
   ieee pric_lev4;
   ieee pric_lev5;
   ieee unit_cost;
   char time_strt[PLU_STRT_LEN];
   char time_end [PLU_ENDT_LEN];
   char base_qty [PLU_BQTY_LEN];
   char dayo_week[PLU_DOWK_LEN];
   ieee disc_rate;
   ieee disc_amt;
   ieee ssd_rate;
   ieee ssd_amt;
   ieee add_tax1;
   char status_b [PLU_STAT_LEN];    
   char deleted;   
   ieee stock;
} PLURECORD;


