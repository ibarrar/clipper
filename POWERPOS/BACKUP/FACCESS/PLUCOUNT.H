/*
 *  plucount.h
 * 
 */

#include "plu_file.ch" 

#define PLU_CTR_FILE_NAME "PLUITEMS.CTR"

typedef struct {
   char plu_code [PLU_CODE_LEN];
   ieee quantity;
   ieee amount;
   ieee discount;
   ieee level;
} PLU_CTR_IN;

typedef struct {
   char plu_code [PLU_CODE_LEN];
   char item_code[PLU_ITEM_LEN];
   char item_desc[PLU_DESC_LEN];
   ieee stock;
   ieee plu_qty;
   ieee plu_amt;
   ieee plu_cst;
   ieee plu_dsc;
   ieee pl0_qty;
   ieee pl0_amt;
   ieee pl0_cst;
   ieee pl0_dsc;
   ieee pl1_qty;
   ieee pl1_amt;
   ieee pl1_cst;
   ieee pl1_dsc;
   ieee pl2_qty;
   ieee pl2_amt;
   ieee pl2_cst;
   ieee pl2_dsc;
   ieee pl3_qty;
   ieee pl3_amt;
   ieee pl3_cst;
   ieee pl3_dsc;
   ieee pl4_qty;
   ieee pl4_amt;
   ieee pl4_cst;
   ieee pl4_dsc;
   ieee pl5_qty;
   ieee pl5_amt;
   ieee pl5_cst;
   ieee pl5_dsc;         
}  PLU_CTR_OUT;   


typedef struct {
   char plu_code [PLU_CODE_LEN];
   ieee plu_qty;
   ieee plu_amt;
   ieee plu_cst;
   ieee plu_dsc;
   ieee pl0_qty;
   ieee pl0_amt;
   ieee pl0_cst;
   ieee pl0_dsc;
   ieee pl1_qty;
   ieee pl1_amt;
   ieee pl1_cst;
   ieee pl1_dsc;
   ieee pl2_qty;
   ieee pl2_amt;
   ieee pl2_cst;
   ieee pl2_dsc;
   ieee pl3_qty;
   ieee pl3_amt;
   ieee pl3_cst;
   ieee pl3_dsc;
   ieee pl4_qty;
   ieee pl4_amt;
   ieee pl4_cst;
   ieee pl4_dsc;
   ieee pl5_qty;
   ieee pl5_amt;
   ieee pl5_cst;
   ieee pl5_dsc;         
}  PLUCOUNTER;   
  
