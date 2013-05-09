/* fm file Lengths */
#define FM_TRANNO_LEN 8
#define FM_OPCODE_LEN 2
#define FM_FILEID_LEN 2
#define FM_RECORD_LEN 244

#define FM_TRANNO_OFF 1  /*                                Trans no. Seq                            */
#define FM_OPCODE_OFF 9  /* FM_TRANNO_OFF + FM_TRANNO_LEN  Operation code 01-Add;02-Overwrite;03Del */
#define FM_FILEID_OFF 11 /* FM_OPCODE_OFF + FM_OPCODE_LEN  File ID                                  */
#define FM_RECORD_OFF 13 /* FM_FILEID_OFF + FM_FILEID_LEN  Record (PLU;FCUR;)                       */

#define FMF_SIZE     256 /* ((FM_RECORD_OFF + FM_RECORD_LEN ) - FM_TRANNO_OFF)                      */



