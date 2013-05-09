/*
 * fmf_file.h -- define the file maintenance file structure...
*/

typedef struct {
   char trans_no[8];
   char opcode[2];
   char file_id[2];
   char fm_record[244];
} FMF_RECORD;

#define FMF_FILE_NAME "FM_TRANS.TXT"
