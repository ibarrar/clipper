/*
 * clerk.h -- Clerk record and key structures...
*/

#define CLERK_IDX_FILE_NAME "CLERK.IDX"

/* Structure of the standard btrieve file */

typedef struct {
	char clerk_code[6];
	char clerk_name[20];
   char localtion[2];
   char deleted;        
   ieee quantity;
   ieee amount;
   ieee discount;
   ieee ptd_qty;
   ieee ptd_amt;
   ieee ptd_dsc;
} CLERK_RECORD;
