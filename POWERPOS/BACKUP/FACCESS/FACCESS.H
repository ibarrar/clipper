#undef  DEBUG
#define FM_FILE
#define CS_FILE
#define PL_FILE 
#define DP_FILE
#define CK_FILE
#define RT_FILE
#undef  RR_FILE
#define PT_FILE

#define AUTO_CREATE
#define BROWSE_FUNCTIONS

#define FA_CMD_SRCHFND 1
#define FA_CMD_SRCHGET 2
#define FA_CMD_SRCHPUT 3
#define FA_CMD_SRCHDEL 4
#define FA_CMD_FREEINQ 5
#define FA_CMD_CREATEF 6
#define FA_CMD_GETCNTR 7
#define FA_CMD_PUTCNTR 8
#define FA_CMD_REPORTF 9
#define FA_CMD_BACKUPF 10
#define FA_CMD_RESETFL 11
#define FA_CMD_GETLAST 12
#define FA_CMD_GETFRST 13
#define FA_CMD_GETNEXT 14
#define FA_CMD_GETPREV 15
#define FA_CMD_CLOSEFL 16

/*
 * netw_err.h -- NetWare/BTRIEVE error definition
*/

#define NORMAL             0
#define FILE_OPEN_ERR      1
#define FILE_READ_ERR      2
#define FILE_WRITE_ERR     3
#define CODE_NOT_FOUND     4
#define MEM_ALLOC_ERR      5
#define FILE_CREATE_ERR    6
#define INVALID_PARAM      7
#define BTRIEVE_OPEN_ERR   8
#define BTRIEVE_UPDATE_ERR 9
#define BTRIEVE_INSERT_ERR 10
#define BTRIEVE_CREATE_ERR 11
#define FILE_DELETE_ERR    12
#define INV_SEND_PARAM     13
#define INV_RECV_PARAM     14
#define INV_CMMD_PARAM     15
#define INV_FILE_ID_PARAM  16
#define INV_PATH_PARAM     17   
#define FILE_NOT_FOUND     18
#define INVALID_REC_NO     19
#define RECORD_NO_ZERO     20
#define DEL_NON_ZERO_ERR   21
#define BTRIEVE_DELETE_ERR 22
#define BTRIEVE_ENDOFFILE  23
#define BTRIEVE_BEGOFFILE  24

typedef union 
{
  double n;
  char s[8];
} ieee;

/* external function prototypes... */
void BCDTOA(char *ascii, unsigned char *bcd, int bcd_len);
void ATOBCD(char *ascii, unsigned char *bcd, int ascii_len);

int itemtran_append ( void far *data, unsigned datalen, char far *machno,
                      void far *path, unsigned pathlen, int parm );

#ifdef FM_FILE
int fmf_search_and_get (void far *receive_buffer, unsigned recvlen,
                        void far *data, unsigned datalen,
                        void far *path, unsigned pathlen );                        
int fmf_delete(void far *path, unsigned pathlen);
int fmf_comp_last_trans_no(void far *receive_buffer, unsigned recvLen,
                           char far *path, unsigned pathLen);
#ifdef BROWSE_FUNCTIONS                            
int fmf_get_first(void far *receive_buffer, unsigned recvLen,
                      char far *path, unsigned pathlen );
int fmf_get_next( void far *receive_buffer, unsigned recvLen,
                      char far *path, unsigned pathlen );
int fmf_get_previous( void far *receive_buffer, unsigned recvLen,
                      char far *path, unsigned pathlen );
int fmf_get_last( void far *receive_buffer, unsigned recvLen,
                      char far *path, unsigned pathlen );
#endif                           
int  fmf_close_file( void );                           
#endif
#ifdef CS_FILE
int cashier_search_and_get( void far *receive_buffer, unsigned recvLen,
                            void far *data, unsigned dataLen,
                            char far *path, unsigned pathlen );
int cashier_search_and_put( void far *data, unsigned dataLen,
                            char far *path, unsigned pathlen );
int cashier_search_and_del( void far *data, unsigned dataLen,
                            char far *path, unsigned pathlen );
#ifdef BROWSE_FUNCTIONS                            
int cashier_get_first(void far *receive_buffer, unsigned recvLen,
                      char far *path, unsigned pathlen );
int cashier_get_next( void far *receive_buffer, unsigned recvLen,
                      char far *path, unsigned pathlen );
int cashier_get_previous( void far *receive_buffer, unsigned recvLen,
                      char far *path, unsigned pathlen );
int cashier_get_last( void far *receive_buffer, unsigned recvLen,
                      char far *path, unsigned pathlen );
#endif
int cashier_create(void far *path, unsigned pathlen);
#endif
#ifdef PL_FILE
int plu_create(void far *path, unsigned pathlen );
int plu_search_and_put(void far *data, unsigned datalen,
                       void far *path, unsigned pathlen);
int plu_search_and_get(void far *receive_buffer, unsigned recvLen,
                        void far *data, unsigned sendLen,
                        void far *path, unsigned pathlen,
                        unsigned parameter);
int plu_search_and_delete(void far *data, unsigned datalen,
                          void far *path, unsigned pathlen );
int plucount_search_and_get(void far *receive_buffer, unsigned recvlen,
                            void far *data, unsigned datalen,
                            void far *path, unsigned pathlen,int parameter );
int plucount_search_and_put(void far *data, unsigned datalen,
                            void far *path, unsigned pathlen,int parameter );
int plucount_close_file(void);                            
int plu_search_and_delete(void far *data, unsigned datalen,                          
                          void far *path, unsigned pathlen );                          
#ifdef BROWSE_FUNCTIONS                          
int plu_get_first(void far *receive_buffer, unsigned recvLen,
                          void far *path, unsigned pathlen,
                          unsigned parameter);
int plu_get_next(void far *receive_buffer, unsigned recvLen,
                          void far *path, unsigned pathlen,
                          unsigned parameter);                          
int plu_get_previous(void far *receive_buffer, unsigned recvLen,
                          void far *path, unsigned pathlen,
                          unsigned parameter);                           
int plu_get_last(void far *receive_buffer, unsigned recvLen,
                          void far *path, unsigned pathlen,
                          unsigned parameter);
#endif                          
int plu_close_file( void );
                          
#endif
#ifdef DP_FILE
int dept_create(void far *path, unsigned pathlen);

int dept_search_and_get(void far *receive_buffer, unsigned recvLen,
                        void far *data, unsigned sendLen,
                        void far *path, unsigned pathlen );
int dept_search_and_put(void far *data, unsigned datalen,
                        void far *path, unsigned pathlen );
int dept_search_and_delete(void far *data, unsigned datalen,
                           void far *path, unsigned pathlen );
int dpcount_search_and_get(void far *data, unsigned datalen,
                           void far *receive_buffer, unsigned recvlen,
                           void far *path, unsigned pathlen, int parameter );
int dpcount_search_and_put(void far *data, unsigned datalen,
                           void far *path, unsigned pathlen, int par);
#ifdef BROWSE_FUNCTIONS                        
int dept_get_first(void far *receive_buffer, unsigned recvLen,
                        void far *path, unsigned pathlen);
int dept_get_next(void far *receive_buffer, unsigned recvLen,
                        void far *path, unsigned pathlen);
int dept_get_previous(void far *receive_buffer, unsigned recvLen,
                        void far *path, unsigned pathlen);
int dept_get_last(void far *receive_buffer, unsigned recvLen,
                        void far *path, unsigned pathlen);
#endif
#endif
#ifdef CK_FILE
int clerk_create(void far *path, unsigned pathlen);

int clerk_search_and_get(void far *receive_buffer, unsigned recvLen,
                        void far *data, unsigned sendLen,
                        void far *path, unsigned pathlen );
int clerk_search_and_put(void far *data, unsigned datalen,
                        void far *path, unsigned pathlen );
int clerk_search_and_delete(void far *data, unsigned datalen,
                           void far *path, unsigned pathlen );
#ifdef BROWSE_FUNCTIONS                        
int clerk_get_first(void far *receive_buffer, unsigned recvLen,
                        void far *path, unsigned pathlen);
int clerk_get_next(void far *receive_buffer, unsigned recvLen,
                        void far *path, unsigned pathlen);
int clerk_get_previous(void far *receive_buffer, unsigned recvLen,
                        void far *path, unsigned pathlen);
int clerk_get_last(void far *receive_buffer, unsigned recvLen,
                        void far *path, unsigned pathlen);
#endif
#endif                                                                          
#ifdef RR_FILE
int rtrn_create(void far *path, unsigned pathlen );
int rtrn_search_and_get(void far *receive_buffer, unsigned recvLen,
                       void far *data, unsigned sendLen,
                       void far *path, unsigned pathlen );
int rtrn_search_and_put(void far *data, unsigned datalen,
                       void far *path, unsigned pathlen );
int rtrn_search_and_delete(void far *data, unsigned datalen,
                           void far *path, unsigned pathlen );
int rtrn_get_first(void far *receive_buffer, unsigned recvLen,
                   void far *path, unsigned pathlen );
int rtrn_get_next(void far *receive_buffer, unsigned recvLen,
                  void far *path, unsigned pathlen );
int rtrn_get_previous(void far *receive_buffer, unsigned recvLen,
                      void far *path, unsigned pathlen );
int rtrn_get_last(void far *receive_buffer, unsigned recvLen,
                  void far *path, unsigned pathlen );
#endif
#ifdef RT_FILE
int return_create(void far *path, unsigned pathlen );
int return_search_and_get(void far *receive_buffer, unsigned recvLen,
                          void far *data, unsigned sendLen,
                          void far *path, unsigned pathlen );
int return_search_and_put(void far *data, unsigned datalen,
                          void far *path, unsigned pathlen );
int return_search_and_delete(void far *data, unsigned datalen,
                             void far *path, unsigned pathlen );
int return_get_first(void far *receive_buffer, unsigned recvLen,
                     void far *path, unsigned pathlen );
int return_get_next(void far *receive_buffer, unsigned recvLen,
                    void far *path, unsigned pathlen );
int return_get_previous(void far *receive_buffer, unsigned recvLen,
                        void far *path, unsigned pathlen );
int return_get_last(void far *receive_buffer, unsigned recvLen,
                    void far *path, unsigned pathlen );
#endif

#ifdef PT_FILE
int plutmp_create(void far *path, unsigned pathlen );
int plutmp_search_and_put(void far *data, unsigned datalen,
                          void far *path, unsigned pathlen );
int plutmp_search_and_find(void far *receive_buffer, unsigned recvLen,
                           void far *data, unsigned sendLen,
                           void far *path, unsigned pathlen );   
int plutmp_search_and_delete(void far *data, unsigned datalen,
                             void far *path, unsigned pathlen );
#endif                          

