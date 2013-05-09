/*
ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
บ  System          :  PowerPOS for Specialty Shop                         บ
บ  Program I.D.    :  POS_DEFS.CH                                         บ
บ  Description     :  PowerPOS Definition File                            บ
บ                                                                         บ
บ  Author          :  jay ocampo                                          บ
บ  Date Started    :  November 1994                                       บ
บ  Last Revision   :                                                      บ
บ  Dialect         :  Clipper plus Extend Libraries from Turbo C++        บ
บ  Remarks         :                                                      บ
ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
*/

// *** Define System Wide Constants

/*#define  CRLF            ( CHR(13) + CHR(10) )            // Control Line Feed
#define  DEF_POSNAME     "PowerPOS ver 1.0"               // PowerPOS version number
#define  DEF_BRANCH_NO   "055"                            // Branch Code


// *** Define Transaction specific constants

#define  QTY_LIMIT            9999                        // quantity limit
#define  MAX_LIMIT       999999.99                        // max. limit
#define  MIN_LIMIT       -99999.99                        // max. limit
#define  MIN_ITEM_DISP           1                        // Minimum no. of items to display
#define  MAX_ITEM_DISP          18                        // Maximum no. of items to display
#define  MAX_TRAN_NO        999999                        // max transaction number
*/

// *** Define System File Drives and File names

#define  DEF_SWAPDRIVE   ""                                // Define Swap Drive, preferably a RAM Drive
#define  DEF_SCR_SWAP    DEF_SWAPDRIVE + "SCR_SWAP.IMG"    // Screen Image Swap File
#define  DEF_MGR_SWAP    DEF_SWAPDRIVE + "MGR_SWAP.IMG"    // Screen Image Swap File for Manager's Function
#define  DEF_DATAPATH    "DATA\"                           // Data path
#define  DEF_NVCTRL      "CT"                              // Suspended Control File Prefix
#define  DEF_NVTRAN      "TR"                              // Suspended Transaction File Prefix




// *** Define Configuration Constants ***

// 2x20 Welcome Display
/*#define  DEF_DISP21           config_[01]                  // Line 1
#define  DEF_DISP22           config_[02]                  // Line 2
*/

// 4x20 Welcome Display
/*#define  DEF_DISP41           config_[03]                  // Line 1
#define  DEF_DISP42           config_[04]                  // Line 2
#define  DEF_DISP43           config_[05]                  // Line 3
#define  DEF_DISP44           config_[06]                  // Line 4
*/

// Receipt Heading
/*#define  DEF_HEAD1            config_[07]                  // Receipt Header # 1
#define  DEF_HEAD2            config_[08]                  // Receipt Header # 1
#define  DEF_HEAD3            config_[09]                  // Receipt Header # 1

#define  DEF_TRAIN_MODE       config_[10]                  // Training Mode
*/

// Available Displays
/*#define  DEF_LDISP1X9         config_[11]                  // 1x9 Display
#define  DEF_LDISP2X20        config_[12]                  // 2x20 Display
#define  DEF_LDISP4X20        config_[13]                  // 4x20 Display
#define  DEF_LDISPFULL        config_[14]                  // Full Screen Display
*/

// Available Printers
/*#define  DEF_LRCPT_PRT        config_[15]                  // Receipt Printer
#define  DEF_LJRNAL_PRT       config_[16]                  // Journal Printer
#define  DEF_LVALID_PRT       config_[17]                  // Validation Printer
#define  DEF_LEX_SLIP_PRT     config_[18]                  // External Slip Printer
#define  DEF_LIN_SLIP_PRT     config_[19]                  // Internal Slip Printer
*/

// Keyboard Type
/*#define  DEF_LSTANDARD_KEY    config_[20]                  // Standard Keyboard
#define  DEF_LDEPT_KEY        config_[21]                  // Dept./Supermarket Keyboard
#define  DEF_LREST_KEY        config_[22]                  // Restaurant Keyboard
*/

// Other POS Device
/*#define  DEF_LSCANNER         config_[23]                  // Scanner
#define  DEF_LCARDREADER      config_[24]                  // Magnetic Card Reader
#define  DEF_LNVRAM           config_[25]                  // NVRAM
*/

// Database Access
/*#define  DEF_ID_ITEM          config_[26]                  // Item File
#define  DEF_ID_CUSTOMER      config_[27]                  // Customer File
#define  DEF_ID_USER          config_[28]                  // User File
#define  DEF_ID_TERMINAL      config_[29]                  // Terminal Report File
*/

// Terminal Assignment
/*#define  DEF_TERMINAL_NO      config_[30]                  // Terminal Number
#define  DEF_ID_SERVER1       config_[31]                  // SERVER 1 I.D.
#define  DEF_ID_SERVER2       config_[32]                  // SERVER 2 I.D.
#define  DEF_ID_SERVER3       config_[33]                  // SERVER 3 I.D.
#define  DEF_ID_BACKUP1       config_[34]                  // BACKUP SERVER 1 I.D.
#define  DEF_ID_BACKUP2       config_[35]                  // BACKUP SERVER 2 I.D.
#define  DEF_ID_BACKUP3       config_[36]                  // BACKUP SERVER 3 I.D.

#define  DEF_RETRY_NO         config_[37]                  // No. of server access attempts
*/

// Priority of server acces
/*#define  DEF_LLOCAL_SERV      config_[38]                  // LOCAL Server
#define  DEF_LMAIN_SERV       config_[39]                  // MAIN Server
#define  DEF_LBACKUP_SERV     config_[40]                  // BACKUP Server
#define  DEF_LOPERATOR        config_[41]                  // OPERATOR
*/

// PLU configuration
/*#define  DEF_PLU_CODE         config_[42]                  // PLU CODE (NUMERIC/ALPHA-NUMERIC)
#define  DEF_PLUCODE_LEN      config_[43]                  // PLU CODE Length
#define  DEF_DESCR_LEN        config_[44]                  // PLU Descriptor Length
*/

// DEPARTMENT configuration
/*#define  DEF_LHALO            config_[45]                  // HALO (High Amt. Lock-Out) ?
#define  DEF_HALO_AMT         config_[46]                  // HALO AMOUNT
#define  DEF_LLALO            config_[47]                  // LALO (Low Amt. Lock-Out) ?
#define  DEF_LALO_AMT         config_[48]                  // LALO AMOUNT
*/

// CASHIER configuration
/*#define  DEF_TEMPSIGNOFF      "999999"                     // Cashier Temporary Sign-off constant
#define  DEF_LCASH_REP        config_[49]                  // Send Cashier Report After Sign-Off ?
#define  DEF_SIGNOFF          config_[50]                  // Sign-Off Code
#define  DEF_KNOWN_CODE       config_[51]                  // Cashier known code
#define  DEF_SECRET_CODE      config_[52]                  // Cashier secret code
#define  DEF_LTEMPSIGNOFF     config_[53]                  // Temporary Sign-Off Allowed ?
#define  DEF_LMGR_SIGNOFF     config_[54]                  // Manager Special Sign-Off Allowed ?
*/

// CLERK configuration
//#define  DEF_CLERK_LEN        config_[55]                  // Clerk Entry Code Length


// ACCOUNTS configuration
/*#define  DEF_LACCT_HOUSE      config_[56]                  // In-house account allowed ?
#define  DEF_LACCT_NEG        config_[57]                  // Negative account allowed ?
#define  DEF_ACCTNO_LEN       config_[58]                  // Valid Account Number digits
*/

// Transaction Entry configuration
/*#define  DEF_LDEPT_ENTRY      config_[59]                  // DEPT. Entry Allowed
#define  DEF_LPLU_ENTRY       config_[60]                  // PLU/SD Entry Allowed
#define  DEF_MIXMATCH_TYPE    config_[61]                  // Mix&Match Pricing Method (<S>pecial or <P>ackage)
#define  DEF_SCANCODE_LEN     config_[62]                  // Number of Digits in Scan code
#define  DEF_PRICE_OFFSET     config_[63]                  // Price Offset */


// Validation
/*#define  DEF_LVLD_CLERK       config_[64]                  // Validate Clerk
#define  DEF_NVLD_SDRAFT      config_[65]                  // No. of line validation in SALESDRAFT
#define  DEF_NVLD_GC          config_[66]                  // No. of Line validation in GIFT CHEQUE
#define  DEF_NVLD_GC_SPACE    config_[67]                  // No. of SPACES before printing GIFT CHEQUE
*/

// Other Functions
/*#define  DEF_LADD_ON          config_[68]                  // Add-On Allowed ?
#define  DEF_NADDON_AMT       config_[69]                  // Add-On Amount
#define  DEF_LMGR_VOID        config_[70]                  // Selective Item void in Manager's void
#define  DEF_LDISC_AMT        config_[71]                  // Peso Discount Allowed ?
#define  DEF_NDISC_AMT        config_[72]                  // Peso Discount Amount
#define  DEF_NDISC_PCT        config_[73]                  // Percent Discount
#define  DEF_LSUBTL_KEY       config_[74]                  // Mandatory Subtotal key press before payment
#define  DEF_NADDON_PCT       10                           // Automatic surcharge/add-on percentage
#define  DEF_MAX_DISC_PCT     99                           // Maximum percentage discount
*/

// Descriptor on Receipt Tape
/*#define  DEF_MMATCH_DESCR     config_[75]                  // Mix and Match Descriptor on Receipt Tape
#define  DEF_TPRICE_DESCR     config_[76]                  // Time Price Descriptor on Receipt Tape
*/

// NVRAM
//#define  DEF_NVRAMPATH        config_[77]                  // NVRAM data path

