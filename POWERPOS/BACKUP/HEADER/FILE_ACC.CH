/* header size of communication protocol... */

#ifndef FILE_ACCESS_HEADER

#define FA_CMD_SRCHFND "01"
#define FA_CMD_SRCHGET "02"
#define FA_CMD_SRCHPUT "03"
#define FA_CMD_SRCHDEL "04"
#define FA_CMD_FREEINQ "05"
#define FA_CMD_CREATEF "06"
#define FA_CMD_GETCNTR "07"
#define FA_CMD_PUTCNTR "08"
#define FA_CMD_REPORTF "09"
#define FA_CMD_BACKUPF "10"
#define FA_CMD_RESETFL "11"
#define FA_CMD_GETLAST "12"
#define FA_CMD_GETFRST "13"

#define FC_SRCHFND     chr(1)
#define FC_SRCHGET     chr(2)
#define FC_SRCHPUT     chr(3)
#define FC_SRCHDEL     chr(4)
#define FC_FREEINQ     chr(5)
#define FC_CREATEF     chr(6)
#define FC_GETCNTR     chr(7)
#define FC_PUTCNTR     chr(8)
#define FC_REPORTF     chr(9)
#define FC_BACKUPF     chr(16)
#define FC_RESETFL     chr(17)
#define FC_GETLAST     chr(18)
#define FC_GETFRST     chr(19)
#define FC_GETNEXT     chr(20)
#define FC_GETPREV     chr(21)
#define FC_CLOSEFL     chr(22)


#define FA_PRM_ZERO    "00"
#define FA_PRM_ONE     "01"

#define FP_ZERO       chr(0)
#define FP_ONE        chr(1)

#define FA_FN_FMF      "FM"
#define FA_FN_PLU      "PL"
#define FA_FN_PLT      "PT" // PLU TEMP
#define FA_FN_DPT      "DP"
#define FA_FN_CLK      "CK"
#define FA_FN_IHC      "IH"
#define FA_FN_INV      "IV"
#define FA_FN_FCR      "FC"  
#define FA_FN_CSH      "CS"  
#define FA_FN_ITM      "IT"  
#define FA_FN_RTN      "RT"

/* report files           */
#define FA_FN_TRF      "TR"
#define FA_FN_CSF      "CR"
#define FA_FN_HRF      "HR"
#define FA_FN_STR      "XX"

#define FA_SZ_FMF      256
#define FA_SZ_PLU      206
#define FA_SZ_PLT       65
#define FA_SZ_DPT      128
#define FA_SZ_CLK       64 
#define FA_SZ_IHC      128
#define FA_SZ_INV       64
#define FA_SZ_FCR       64
#define FA_SZ_CSH       45
#define FA_SZ_ITM      128
#define FA_SZ_RTN      112

#define FA_FRAME_LEN   256
                           /* TCP/IP error codes... */

#define ETIMEDOUT        4 /* timeout error         */
#define ENOCONNECT       8 /* socket not connected  */

#define FILE_ACCESS_HEADER
#endif