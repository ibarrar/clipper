#define RETURN_FILE_NAME "RETNFILE.IDX"


typedef struct {
   unsigned char return_code[8];
   unsigned char item_code[14];
   unsigned char descriptor[20];
   unsigned char dept_code[4];
   unsigned char approval_code[8];   
   unsigned char deleted;
   ieee quantity;
   ieee amount;
   ieee unit_cost;
}  RETURN_RECORD;
    
   