#include "return.ch"

#define RETURN_FILE_NAME "RETURN.IDX"

typedef struct {
  unsigned char plu_code[RET_PLUCODE_LEN];
  unsigned char item_code[RET_ITMCODE_LEN];
  unsigned char descriptor[RET_PLUDESC_LEN];
  unsigned char dept_code[RET_DEPCODE_LEN];
  ieee quantity;
  ieee amount;
  ieee costs;
} RETURN_RECORD;


 

  