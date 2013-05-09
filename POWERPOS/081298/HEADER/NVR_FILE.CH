*
* System......... POWERPOS for Spectrum
* Filename....... NVR_FILE.ch
* Description.... Definitions of Non volatile RAM files
*

#define  NVCNTRL_NAME "NVCNTRL"

// NVR_FUNC functions return values

#define NVR_NORMAL      0
#define NVR_NOT_OPEN   -1
#define NVR_OPEN_ERR   -2
#define NVR_NO_SPACE   -3
#define NVR_CREAT_ERR  -4
#define NVR_SAVE_ERR   -5
#define NVR_READ_ERR   -6 
#define NVR_CORRUPTED  -7

// control file...
#define NVR_CRC_LEN    4
#define NVR_STS_LEN    1
#define NVR_CSH_LEN    6
#define NVR_USD_LEN    8
#define NVR_PHP_LEN    8
#define NVR_TRN_LEN    8
#define NVR_ITM_LEN    4   // No of records in NVR trans file
#define NVR_QTY_LEN    8   // No of unit in the transaction
#define NVR_STT_LEN    8
#define NVR_SUS_LEN    1
#define NVR_SWP_LEN    1
#define NVR_ITP_LEN    1
#define NVR_TRP_LEN    1
#define NVR_RES_LEN    1
#define NVR_FMF_LEN    8

#define NVF_CRC_OFF    0
#define NVF_STS_OFF    4  // NVF_CRC_OFF + NVR_CRC_LEN
#define NVF_CSH_OFF    5  // NVF_STS_OFF + NVR_STS_LEN
#define NVF_USD_OFF   11  // NVF_CSH_OFF + NVR_CSH_LEN
#define NVF_PHP_OFF   19  // NVF_USD_OFF + NVR_USD_LEN
#define NVF_TRN_OFF   27  // NVF_PHP_OFF + NVR_PHP_LEN
#define NVF_ITM_OFF   35  // NVF_TRN_OFF + NVR_TRN_LEN
#define NVF_QTY_OFF   39  // NVF_ITM_OFF + NVR_ITM_LEN
#define NVF_STT_OFF   47  // NVF_QTY_OFF + NVR_QTY_LEN
#define NVF_SUS_OFF   55  // NVF_STT_OFF + NVR_STT_LEN
#define NVF_SWP_OFF   56  // NVF_SUS_OFF + NVR_SUS_LEN
#define NVF_ITP_OFF   57  // NVF_SWP_OFF + NVR_SWP_LEN
#define NVF_TRP_OFF   58  // NVF_ITP_OFF + NVR_ITP_LEN
#define NVF_RES_OFF   59  // NVF_TRP_OFF + NVR_TRP_LEN
#define NVF_FMF_OFF   60  // NVF_RES_OFF + NVR_RES_LEN
        
#define NVR_CRC_OFF    1
#define NVR_STS_OFF    5  // NVR_CRC_OFF + NVR_CRC_LEN
#define NVR_CSH_OFF    6  // NVR_STS_OFF + NVR_STS_LEN
#define NVR_USD_OFF   12  // NVR_CSH_OFF + NVR_CSH_LEN
#define NVR_PHP_OFF   20  // NVR_USD_OFF + NVR_USD_LEN
#define NVR_TRN_OFF   28  // NVR_PHP_OFF + NVR_PHP_LEN
#define NVR_ITM_OFF   36  // NVR_TRN_OFF + NVR_TRN_LEN
#define NVR_QTY_OFF   40  // NVR_ITM_OFF + NVR_ITM_LEN
#define NVR_STT_OFF   48  // NVR_QTY_OFF + NVR_QTY_LEN
#define NVR_SUS_OFF   56  // NVR_STT_OFF + NVR_STT_LEN
#define NVR_SWP_OFF   57  // NVR_SUS_OFF + NVR_SUS_LEN
#define NVR_ITP_OFF   58  // NVR_SWP_OFF + NVR_SWP_LEN
#define NVR_TRP_OFF   59  // NVR_ITP_OFF + NVR_ITP_LEN
#define NVR_RES_OFF   60  // NVR_TRP_OFF + NVR_TRP_LEN
#define NVR_FMF_OFF   61  // NVR_RES_OFF + NVR_RES_LEN

#define NVR_CNTRL_SIZE  68 //  (NVR_FMF_OFF + NVR_FMF_LEN - NVR_CRC_OFF)

/*----------------*-------------*-----------------*/
// transaction entry...
//
#define TRAN_REQ_LEN     1  // Delete flag
#define TRAN_PFLG_LEN    1  // Reserved for special operation flags
#define TRAN_FLAG_LEN    1  // Transaction Flag
#define TRAN_PRCM_LEN    2  // Pricing Method
#define TRAN_SALE_LEN    8  // Sale amount 
#define TRAN_CNTR_LEN    8  // Quantity w/ decimal Point
*                      -21-
/*-------------------------------------------------*/

#define TRAN_PLU_LEN    14  // PLU Code
#define TRAN_ITEM_LEN   12  // Item Code
#define TRAN_DEPT_LEN    4  // Department Code
#define TRAN_REGM_LEN    1  // Registry method
#define TRAN_CONC_LEN    4  // Concessionaire's code
#define TRAN_COLO_LEN    2  // Color
#define TRAN_SIZE_LEN    2  // Size
#define TRAN_CLRK_LEN    6  // Clerk number for item purchased.
#define TRAN_DESC_LEN   20  // Descriptor for displays only
#define TRAN_PRIC_LEN    8  // special kind
#define TRAN_QTY_LEN     8  // special clipper function
#define TRAN_CRGO_LEN   12  // Multi purpose cargo field 
#define TRAN_PRLV_LEN    2  // price level used
#define TRAN_RESV_LEN    1  // reserved for future use
*                      -96- 
/*--------------------------------------------------*/

#define TRAN_CRG1_LEN   20  
#define TRAN_CRG2_LEN   20
#define TRAN_CRG3_LEN   20
#define TRAN_CRG4_LEN   36  // reserved for future use
*                      -96-
/*---------------------------------------------------*/

#define TRAN_REQ_OFF     1  
#define TRAN_PFLG_OFF    2 /* TRAN_REQ_OFF  + TRAN_REQ_LEN  */
#define TRAN_FLAG_OFF    3 /* TRAN_PFLG_OFF + TRAN_PFLG_LEN */
#define TRAN_PRCM_OFF    4 /* TRAN_FLAG_OFF + TRAN_FLAG_LEN */
#define TRAN_SALE_OFF    6 /* TRAN_PRCM_OFF + TRAN_PRCM_LEN */
#define TRAN_CNTR_OFF   14 /* TRAN_SALE_OFF + TRAN_SALE_LEN */

#define TRAN_PLU_OFF    22 /* TRAN_CNTR_OFF + TRAN_CNTR_LEN */
#define TRAN_ITEM_OFF   36 /* TRAN_PLU_OFF  + TRAN_PLU_LEN  */
#define TRAN_DEPT_OFF   48 /* TRAN_ITEM_OFF + TRAN_ITEM_LEN */
#define TRAN_REGM_OFF   52 /* TRAN_DEPT_OFF + TRAN_DEPT_LEN */
#define TRAN_CONC_OFF   53 /* TRAN_REGM_OFF + TRAN_REGM_LEN */
#define TRAN_COLO_OFF   57 /* TRAN_CONC_OFF + TRAN_CONC_LEN */
#define TRAN_SIZE_OFF   59 /* TRAN_COLO_OFF + TRAN_COLO_LEN */
#define TRAN_CLRK_OFF   61 /* TRAN_SIZE_OFF + TRAN_SIZE_LEN */
#define TRAN_DESC_OFF   67 /* TRAN_CLRK_OFF + TRAN_CLRK_LEN */
#define TRAN_PRIC_OFF   87 /* TRAN_DESC_OFF + TRAN_DESC_LEN */
#define TRAN_QTY_OFF    95 /* TRAN_PRIC_OFF + TRAN_PRIC_LEN */
#define TRAN_CRGO_OFF  103 /* TRAN_QTY_OFF  + TRAN_QTY_LEN  */
#define TRAN_PRLV_OFF  115 /* TRAN_CRGO_OFF + TRAN_CRGO_LEN */
#define TRAN_RESV_OFF  117 /* TRAN_PRLV_OFF + TRAN_PRLV_LEN */ 

*

/*---------------------------------------------------*/

#define TRAN_CRG1_OFF   22 /* TRAN_CNTR_OFF + TRAN_CNTR_LEN */
#define TRAN_CRG2_OFF   42 /* TRAN_CRG1_OFF + TRAN_CRG1_LEN */
#define TRAN_CRG3_OFF   62 /* TRAN_CRG2_OFF + TRAN_CRG2_LEN */
#define TRAN_CRG4_OFF   82 /* TRAN_CRG3_OFF + TRAN_CRG3_LEN */
 
#define NVR_TRANS_SIZE 117 /* (TRAN_RESV_OFF + TRAN_RESV_LEN - TRAN_REQ_OFF) */


#define NVR_MAXIMUM_PLU 200 // compute for this see explanations below

/*
   MAXIMUN_PLU := 
                  ((DiskSpace(RAMDRIVE)-FAT_SPACE)  
                                   -   CNTRL_SIZE 
                                   -    TERM_SIZE
                                   - CASHIER_SIZE )
                   --------------------------------                     
                                   %  TRANSIZE                       */

                                   
// for 33Kb (33,792 bytes) of available DISKSPACE Default by NVRAM
// FAT_SPACE is approximately 5632 bytes
// and using    TRAN_SIZE = 118
//             CNTRL_SIZE =  69
//              TERM_SIZE = 736
//           CASHIER_SIZE = 890                                
// > ((33792-5632) - (69+736+890)) / 116
// > 28160/117 Maximum PLU Accomodated by NVRAM or NVCTRL file.
// which i think is more than enough to work....

