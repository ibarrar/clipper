/*****************************************************************************
  PFL_CLIP.CH

  Header file containing standard definitions of PFL (POS Function Library)
  for CLIPPER.

*****************************************************************************/

/* PFL (Generic) Error Codes correspond to the following situations:

   NORMAL            - Generic API function performed normally;
   HARD_ERR          - General hardware error;
   NO_DRIVER         - Driver not installed;
   DEV_EXIST         - POS device already initialized;
   DEV_NOT_EXIST     - POS device not initialized or Wrong file handle;
   DEV_NOT_READY     - POS device not ready;
   INVP              - Invalid parameter or invalid command;
   PAPER_ERR         - Paper error;
   RCPT_END          - End of paper, receipt;
   RCPT_NTEND        - Not end of paper, receipt;
   JRNL_END_TORN     - Journal torn and end of paper;
   JRNL_END_NTORN    - Journal not torn but end of paper;
   JRNL_NTEND_TORN   - Journal not end of paper but journal torn;
   JRNL_NTEND_NTORN  - Journal not end of paper and not torn;
   DOC_IN_END        - Document inserted but end of paper;
   DOC_IN_NTEND      - Document inserted and not end of paper;
   DOC_OUT           - Document not inserted;
   COVER_OPEN        - Printer cover open;
   DRAWER_OPEN       - Cash drawer already open;
   DRAWER_CLOSED     - Cash drawer already closed;
   TRACK_EMPTY       - A track on a magnetic card is empty or not present;
   CRC_ERR           - Parity check error or LRC error at swipecard reader;
   END_OF_DATA       - EOF or All existing data has already been read;
   POWER_ERR         - Power failure occurred;
   POWER_OK          - Normal power;
   MEM_OUT           - Not enough space in memory;
   NV_FILE_EXISTS    - NVRAM file already exists;
   NV_USERDATA_ERR   - NVRAM user data area corrupted;
   NV_FILE_NOT_EXIST - NVRAM file does not exist;
   SLIP_PAPER_OUT    - (optional) slip printer paper error;
   TIMEOUT_ERR       - Timeout status occurred;
   READ_ERR          - Read operation error;
   WRITE_ERR         - Write operation error;
   CANCEL_OP         - Read/Write operation cancelled;
   
*/
#ifndef  NORMAL
  #define  NORMAL             0
#endif  
  
#define  HARD_ERR           1
#define  NO_DRIVER          2 
#define  DEV_EXIST          3
#define  DEV_NOT_EXIST      4
#define  DEV_NOT_READY      5
#define  INVP               6
#define  PAPER_ERR          7
#define  RCPT_END           8
#define  RCPT_NTEND         9
#define  JRNL_END_TORN      10
#define  JRNL_END_NTORN     11
#define  JRNL_NTEND_TORN    12
#define  JRNL_NTEND_NTORN   13
#define  DOC_IN_END         14
#define  DOC_IN_NTEND       15
#define  DOC_OUT            16
#define  COVER_OPEN         17
#define  DRAWER_OPEN        18
#define  DRAWER_CLOSED      19
#define  TRACK_EMPTY        20
#define  CRC_ERR            21
#define  END_OF_DATA        22
#define  POWER_ERR          23
#define  POWER_OK           24
#define  MEM_OUT            25
#define  NV_FILE_EXISTS     26
#define  NV_USERDATA_ERR    27
#define  NV_FILE_NOT_EXIST  28
#define  SLIP_PAPER_OUT     29
#define  BTRFILE_OPEN_ERR   30
#define  BTRFILE_READ_ERR   31
#define  BTRCODE_NOTFOUND   32
#define  NET_SEND_FAIL      33
#define  NET_RECEIVE_FAIL   34
#define  TIMEOUT_ERR        35
#define  READ_ERR           36
#define  WRITE_ERR          37
#define  CANCEL_OP          38
#define  SCAN_ERR           39


/* Symbolic Constant for the POS Devices */

#define  POS_PRINTER       0     /* POS printer                   */
#define  POS_CASH_DRAW     1     /* cash drawer                   */
#define  POS_CARD_READ     2     /* magnetic card reader          */
#define  POS_KEYBOARD      3     /* POS keyboard                  */
#define  POS_CKEYLOCK      4     /* POS Central keylock           */
#define  POS_CUST_DISP2    5     /* customer display (additional) */
#define  POS_SCAN          6     /* scanner or optical reader     */
#define  OPT_SLIP_PRNTR    7     /* Optional Slip printer         */

#define  POS_CUST_DISP1    8     /* customer display (integrated) */
#define  POS_CASH_DISP     9     /* cashier or operator display   */


