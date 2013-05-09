/* Cashier Header File :cashier.ch */

#define  CASH_CODE_LEN   6
#define  CASH_NAME_LEN   20
#define  CASH_TIME1_LEN  6 
#define  CASH_TIME2_LEN  6
#define  CASH_POSNO_LEN  4
#define  CASH_RSRVD_LEN  1

#define  CASH_CODE_OFF   1
#define  CASH_NAME_OFF   CASH_CODE_OFF + CASH_CODE_LEN
#define  CASH_TIME1_OFF  CASH_NAME_OFF + CASH_NAME_LEN
#define  CASH_TIME2_OFF  CASH_TIME1_OFF + CASH_TIME1_LEN
#define  CASH_POSNO_OFF  CASH_TIME2_OFF + CASH_TIME2_LEN
#define  CASH_RSRVD_OFF  CASH_POSNO_OFF + CASH_POSNO_LEN

#define  CASHIER_SIZE  (CASH_RSRVD_OFF + CASH_RSRVD_LEN - CASH_CODE_OFF)

#define  CS_CODE_LEN    3
#define  CS_SECR_LEN    3
#define  CS_NAME_LEN   20 
#define  CS_TERM_LEN    4
#define  CS_TMIN_LEN    6
#define  CS_TOUT_LEN    6
#define  CS_DATA_LEN    (CS_FIELD_KNT * 8)

#define  CS_CODE_OFF   1
#define  CS_SECR_OFF   CS_CODE_OFF + CS_CODE_LEN 
#define  CS_NAME_OFF   CS_SECR_OFF + CS_SECR_LEN 
#define  CS_TERM_OFF   CS_NAME_OFF + CS_NAME_LEN 
#define  CS_TMIN_OFF   CS_TERM_OFF + CS_TERM_LEN 
#define  CS_TOUT_OFF   CS_TMIN_OFF + CS_TMIN_LEN 
#define  CS_DATA_OFF   CS_TOUT_OFF + CS_TOUT_LEN

#define  LOCAL_CASH_SIZE  CS_DATA_OFF + CS_DATA_LEN - CS_CODE_OFF

#define  CS_DSLS_TOT    1
#define  CS_DSLS_KNT    2
#define  CS_CASH_TOT    3
#define  CS_DEPT_TOT    4
#define  CS_FCUR_TOT    5
#define  CS_FCUR_KNT    6
#define  CS_MC01_TOT    7
#define  CS_MC01_KNT    8
#define  CS_MC02_TOT    9
#define  CS_MC02_KNT   10
#define  CS_MC03_TOT   11 
#define  CS_MC03_KNT   12 
#define  CS_MC04_TOT   13 
#define  CS_MC04_KNT   14 
#define  CS_MC05_TOT   15 
#define  CS_MC05_KNT   16 
#define  CS_MC06_TOT   17 
#define  CS_MC06_KNT   18 
#define  CS_MC07_TOT   19 
#define  CS_MC07_KNT   20 
#define  CS_MC08_TOT   21 
#define  CS_MC08_KNT   22 
#define  CS_MC09_TOT   23 
#define  CS_MC09_KNT   24 
#define  CS_MC10_TOT   25 
#define  CS_MC10_KNT   26 
#define  CS_MC11_TOT   27 
#define  CS_MC11_KNT   28 
#define  CS_MC12_TOT   29 
#define  CS_MC12_KNT   30 
#define  CS_MC13_TOT   31 
#define  CS_MC13_KNT   32 
#define  CS_MC14_TOT   33 
#define  CS_MC14_KNT   34 
#define  CS_MC15_TOT   35 


#define  CS_MC15_KNT   36 
#define  CS_MC16_TOT   37 
#define  CS_MC16_KNT   38 
#define  CS_MC17_TOT   39 
#define  CS_MC17_KNT   40 
#define  CS_MC18_TOT   41 
#define  CS_MC18_KNT   42 
#define  CS_MC19_TOT   43 
#define  CS_MC19_KNT   44 
#define  CS_MC20_TOT   45 
#define  CS_MC20_KNT   46 

#define  CS_VOID_TOT   47 
#define  CS_VOID_KNT   48 
#define  CS_MGRV_TOT   49 
#define  CS_MGRV_KNT   50 
#define  CS_IDSC_TOT   51 
#define  CS_IDSC_KNT   52 
#define  CS_SDSC_TOT   53 
#define  CS_SDSC_KNT   54 
#define  CS_ADON_TOT   55 
#define  CS_ADON_KNT   56 
#define  CS_SESD_TOT   57 
#define  CS_SESD_KNT   58 
#define  CS_SADO_TOT   59 
#define  CS_SADO_KNT   60 
#define  CS_REXC_TOT   61 
#define  CS_REXC_KNT   62 
#define  CS_RFND_TOT   63 
#define  CS_RFND_KNT   64 
#define  CS_OINC_TOT   65 
#define  CS_OINC_KNT   66 
#define  CS_TRCL_TOT   67 
#define  CS_TRCL_KNT   68 
#define  CS_TRVD_TOT   69 
#define  CS_TRVD_KNT   70 
#define  CS_TRSU_TOT   71 
#define  CS_TRSU_KNT   72 
#define  CS_LAYA_TOT   73 
#define  CS_LAYA_KNT   74 
#define  CS_PKUP_TOT   75 
#define  CS_PKUP_KNT   76 
#define  CS_PDOT_TOT   77 
#define  CS_PDOT_KNT   78 
#define  CS_LOAN_TOT   79 
#define  CS_LOAN_KNT   80 
#define  CS_RONA_TOT   81 
#define  CS_RONA_KNT   82 
#define  CS_BOTD_TOT   83 
#define  CS_BOTD_KNT   84 
#define  CS_OFFL_TOT   85 
#define  CS_OFFL_KNT   86 


#define  CS_TRNG_TOT   87 
#define  CS_REEN_TOT   88 
#define  CS_OLDG_TOT   89 
#define  CS_NEWG_TOT   90 
#define  CS_XCTR_TOT   91 
#define  CS_ZCTR_TOT   92 
#define  CS_SCAN_TOT   93        // Scan sales
#define  CS_SCAN_KNT   94        // count
#define  CS_DUTY_TIM   95        // Total duty time
#define  CS_ATRN_TIM   96        // Actual transaction time..

