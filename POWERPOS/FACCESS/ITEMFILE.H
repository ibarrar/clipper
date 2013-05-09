/*
 * cashier.h -- Cashier record and key structures...    
*/
#define ITEMTRAN_FILE_NAME "ITEM"
#define ITEMTRAN_FILE_NAME "ITEM"


/* Structure of the standard btrieve file
 * that will serve as an index to the DOS text file...
*/

/* Structure of CASHIER record... */

typedef struct {
	char pos_no[4];
	char date[8];
	char time[8];
	char trans_no[8];
	char reserved1;
	char trans_flag;
	char cash_code[6];
	char clerk_code[6];
	char reg_method;
	char pr_method;
	char reserved2[2];
	char plu_code[14];
	char item_code[12];
	char dept_code[4];
	char conc[4];
	char color[2];
	char size[2];
	char sls_amount[12];
	char quantity[10];
	char pay_type[4];
	char order_no[12];
	char reserved3[4];
	char crlf[2];
} ITEMRECORD;



