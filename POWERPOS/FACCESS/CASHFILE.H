/*
 * cashier.h -- Cashier record and key structures...    
*/
#define CASHIER_FILE_NAME "CASHIER.TXT"

#define uc  unsigned char

/* Structure of the standard btrieve file
 * that will serve as an index to the DOS text file...
*/

/* Structure of CASHIER record... */
typedef struct {
   char cashier_code[3];
   char cashier_scrt[3];
   char cashier_name[20];
   char time_in[6];
   char time_out[6];
   char pos_no[4];
   char deleted;
   char line_feed[2];
} CASHRECORD;



